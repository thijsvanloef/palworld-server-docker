import sys
import select
import os
import errno
import stat
import time
import signal
import re
import json
from datetime import datetime, timezone

# Constants
FIFO_PATH = "/home/steam/server/.palserver_log_fifo"
POLL_PERIOD = int(os.environ.get('PLAYER_LOGGING_POLL_PERIOD', 5))
TIMEOUT = POLL_PERIOD + 5
LOG_FORMAT_TYPE = os.environ.get('LOG_FORMAT_TYPE', 'default').lower()

# FIFO lifecycle (create/remove/chown) is managed by init.sh.
# pal_logger.py only opens and consumes the FIFO.
if not os.path.exists(FIFO_PATH):
    sys.stderr.write(f"FIFO does not exist: {FIFO_PATH}\n")
    sys.exit(1)
if not stat.S_ISFIFO(os.stat(FIFO_PATH).st_mode):
    sys.stderr.write(f"Path is not a FIFO: {FIFO_PATH}\n")
    sys.exit(1)

# Open FIFO in non-blocking mode for reading
# We need to open read-write to avoid EOF when the writer closes.
# This prevents the select loop from spinning at 100% CPU when no writers are connected.
try:
    fifo_fd = os.open(FIFO_PATH, os.O_RDWR | os.O_NONBLOCK)
except OSError as e:
    sys.stderr.write(f"Error opening FIFO: {e}\n")
    sys.exit(1)

buffer = ""
last_content = ""
count = 0
buffer_timing = 0

def get_iso_timestamp(timestamp_str=None):
    if timestamp_str:
        try:
            dt = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
            # Fallback to UTC if local timezone is not available
            local_tz = datetime.now().astimezone().tzinfo
            if local_tz:
                dt = dt.replace(tzinfo=local_tz)
            else:
                dt = dt.replace(tzinfo=timezone.utc)
        except ValueError:
            try:
                dt = datetime.fromisoformat(timestamp_str)
            except ValueError:
                dt = datetime.now().astimezone()
    else:
        dt = datetime.now().astimezone()
    return dt.isoformat(timespec='seconds')

def parse_log_line(line):
    # Remove ANSI escape sequences for non-colored formats
    if LOG_FORMAT_TYPE in ['json', 'logfmt', 'plain']:
        line = re.sub(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])', '', line)

    timestamp_str = None
    level = ""
    message = line

    # Check for logfmt style (e.g. supercron)
    # Example: time="2025-12-03T13:09:02+09:00" level=warning msg="..."
    match_logfmt = re.search(r'time="([^"]+)"\s+level=("?)([^"\s]+)\2\s+msg="((?:[^"\\]|\\.)*)"', line)
    if match_logfmt:
        timestamp_str = match_logfmt.group(1)
        level = match_logfmt.group(3)
        message = match_logfmt.group(4)
        return timestamp_str, level, message, line

    match_ts = re.match(r'^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] (.*)', line)
    if match_ts:
        timestamp_str = match_ts.group(1)
        remaining = match_ts.group(2)
        match_lvl = re.match(r'^\[([^\]]+)\] (.*)', remaining)
        if match_lvl:
            level = match_lvl.group(1)
            message = match_lvl.group(2)
        else:
            message = remaining
    else:
        match_lvl = re.match(r'^\[([^\]]+)\] (.*)', line)
        if match_lvl:
            level = match_lvl.group(1)
            message = match_lvl.group(2)

    # Bash xtrace output (set -x) starts with one or more '+' prefixes.
    # Classify it as DEBUG instead of falling back to INFO.
    if not level and re.match(r'^\+{1,}\s', line):
        level = "DEBUG"
        message = line

    return timestamp_str, level, message, line

def flush_buffer():
    global buffer, last_content, count
    if buffer:
        timestamp_str, level, message, _ = parse_log_line(buffer)
        
        # Normalize level to uppercase for consistency
        if level:
            level = level.upper()
        
        if count > 1:
            message_suffix = f" (x{count})"
        else:
            message_suffix = ""

        if LOG_FORMAT_TYPE == 'json':
            iso_time = get_iso_timestamp(timestamp_str)
            log_entry = {
                "time": iso_time,
                "level": level if level else "INFO",
                "message": message + message_suffix
            }
            print(json.dumps(log_entry, ensure_ascii=False))
        elif LOG_FORMAT_TYPE == 'logfmt':
            iso_time = get_iso_timestamp(timestamp_str)
            lvl = level if level else "INFO"
            msg = message + message_suffix
            msg_escaped = msg.replace('\\', '\\\\').replace('"', '\\"')
            print(f'time="{iso_time}" level="{lvl}" msg="{msg_escaped}"')
        elif LOG_FORMAT_TYPE in ['colored', 'plain']:
            # plain or colored
            if timestamp_str:
                time_output = timestamp_str
            else:
                time_output = datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S')
            
            lvl_output = level if level else "INFO"
            final_msg = message + message_suffix
            print(f"[{time_output}] [{lvl_output}] {final_msg}")
        else:
            # default: preserve raw output for unstructured lines, but keep level/timestamp
            # when a level was detected (e.g. bash xtrace classified as DEBUG).
            if level or timestamp_str:
                if timestamp_str:
                    time_output = timestamp_str
                else:
                    time_output = datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S')

                lvl_output = level if level else "INFO"
                final_msg = message + message_suffix
                print(f"[{time_output}] [{lvl_output}] {final_msg}")
            else:
                print(f"{buffer}{message_suffix}")

        sys.stdout.flush()
        buffer = ""
        last_content = ""
        count = 0

running = True

def cleanup():
    flush_buffer()
    try:
        os.close(fifo_fd)
    except (OSError, NameError):
        pass  # Ignore if fifo_fd was never opened

def signal_handler(signum, frame):
    global running
    running = False

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

def process_line(line):
    global buffer, last_content, count, buffer_timing
    
    # Use strip to remove \r, \n and trailing/leading whitespace
    line = line.strip()
    
    # Ignore empty lines to avoid breaking deduplication
    if not line:
        return

    now = time.time()
    
    # Parse content for deduplication
    # Use rstrip to remove \r and trailing whitespace
    line = line.rstrip()
    _, _, new_content, _ = parse_log_line(line)
    
    if buffer and new_content == last_content and (now - buffer_timing) < TIMEOUT:
        count += 1
    else:
        flush_buffer()
        last_content = new_content
        count = 1
        buffer = line
    
    buffer_timing = now

try:
    while running:
        # Wait for input on stdin or fifo
        # select blocks until one is ready
        # Add timeout to ensure signal handling works even if select doesn't wake up immediately
        r, _, _ = select.select([sys.stdin, fifo_fd], [], [], 1.0)

        # Check for timeout flush
        if buffer and (time.time() - buffer_timing) >= TIMEOUT:
            flush_buffer()

        if fifo_fd in r:
            # Flush request received
            try:
                data = os.read(fifo_fd, 4096)
                if data:
                    text = data.decode('utf-8', errors='replace')
                    lines = text.splitlines()
                    
                    for line in lines:
                        if line.startswith("LOG_FLUSH"):
                            flush_buffer()
                            continue
                        if line.startswith("LOG:"):
                            process_line(line[4:])
                        else:
                            process_line(line)
            except OSError as e:
                if e.errno != errno.EAGAIN and e.errno != errno.EWOULDBLOCK:
                    sys.stderr.write(f"Error reading from FIFO: {e}\n")

        if sys.stdin in r:
            line = sys.stdin.readline()
            if not line:
                break # EOF
            
            line = line.rstrip('\n')
            process_line(line)

finally:
    cleanup()
