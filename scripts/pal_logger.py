import sys
import select
import os
import time
import signal

# Constants
FIFO_PATH = "/home/steam/server/.palserver_log_fifo"
POLL_PERIOD = int(os.environ.get('PLAYER_LOGGING_POLL_PERIOD', 5))
TIMEOUT = POLL_PERIOD + 5

# Setup FIFO
if os.path.exists(FIFO_PATH):
    try:
        os.remove(FIFO_PATH)
    except OSError:
        pass
try:
    os.mkfifo(FIFO_PATH)
except OSError:
    pass # Already exists?

# Open FIFO in non-blocking mode for reading
# We need to open read-write to avoid EOF when the writer closes, 
# OR re-open it in the loop. 
# Actually, for FIFO, if we open O_RDWR, select will block until data comes.
# If we open O_RDONLY | O_NONBLOCK, select works.
try:
    fifo_fd = os.open(FIFO_PATH, os.O_RDWR | os.O_NONBLOCK)
except OSError as e:
    sys.stderr.write(f"Error opening FIFO: {e}\n")
    sys.exit(1)

buffer = ""
last_content = ""
count = 0
buffer_timing = 0

def flush_buffer():
    global buffer, last_content, count
    if buffer:
        if count > 1:
            print(f"{buffer} (x{count})")
        else:
            print(buffer)
        sys.stdout.flush()
        buffer = ""
        last_content = ""
        count = 0

def cleanup(*args):
    flush_buffer()
    if os.path.exists(FIFO_PATH):
        try:
            os.remove(FIFO_PATH)
        except OSError:
            pass
    sys.exit(0)

signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)

try:
    while True:
        # Wait for input on stdin or fifo
        # select blocks until one is ready
        # Add timeout to ensure signal handling works even if select doesn't wake up immediately
        r, _, _ = select.select([sys.stdin, fifo_fd], [], [], 1.0)

        if fifo_fd in r:
            # Flush request received
            try:
                data = os.read(fifo_fd, 4096)
                if data:
                    text = data.decode('utf-8', errors='replace')
                    lines = text.splitlines()
                    
                    flush_buffer() # Flush buffer before printing external logs
                    
                    for line in lines:
                        if line == "LOG_FLUSH":
                            continue
                        if line.startswith("LOG:"):
                            print(line[4:])
                        else:
                            print(line)
                    sys.stdout.flush()
            except OSError:
                pass

        if sys.stdin in r:
            line = sys.stdin.readline()
            if not line:
                break # EOF
            
            line = line.rstrip('\n')
            now = time.time()
            
            # Parse content for deduplication
            # bash: new_content="${line#*] }"
            parts = line.split('] ', 1)
            new_content = parts[1] if len(parts) > 1 else line
            
            if new_content == last_content and (now - buffer_timing) < TIMEOUT:
                count += 1
            else:
                flush_buffer()
                last_content = new_content
                count = 1
                buffer = line
            
            buffer_timing = now

finally:
    cleanup()
