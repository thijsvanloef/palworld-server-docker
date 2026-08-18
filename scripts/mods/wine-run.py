#!/usr/bin/env python3
import fcntl
import os
import pty
import struct
import sys
import termios


def main():
  if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <executable> [args...]", file=sys.stderr)
    sys.exit(1)

  # Use the WINE_BIN environment variable if specified, otherwise default to "wine"
  wine_bin = os.environ.get("WINE_BIN", "wine")

  # Construct the command array by automatically prepending wine
  cmd = [wine_bin] + sys.argv[1:]

  pid, master = pty.fork()

  if pid == 0:
    # Child process: start with wine + specified arguments
    os.execvp(cmd[0], cmd)
  else:
    # Parent process: set terminal size to 500x500
    try:
      fcntl.ioctl(
          master, termios.TIOCSWINSZ, struct.pack("HHHH", 500, 500, 0, 0)
      )
    except Exception:
      pass

    # Output logs (stdout / stderr combined)
    while True:
      try:
        data = os.read(master, 1024)
        if not data:
          break
        sys.stdout.buffer.write(data)
        sys.stdout.buffer.flush()
      except OSError:  # Countermeasure for EIO error when PTY ends
        break

    # Get the exit status of the child process (Wine) and propagate it as the return value of the parent
    _, status = os.waitpid(pid, 0)
    if os.WIFEXITED(status):
      sys.exit(os.WEXITSTATUS(status))
    elif os.WIFSIGNALED(status):
      sys.exit(128 + os.WTERMSIG(status))


if __name__ == "__main__":
  main()
