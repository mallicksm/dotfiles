#!/usr/bin/env python3
import sys
import socket
import subprocess

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception as e:
        return f"Error: {e}"

def main():
    if len(sys.argv) == 2 and sys.argv[1] == '-i':
        print(get_local_ip())
    else:
        try:
            result = subprocess.run(['hostname'] + sys.argv[1:], capture_output=True, text=True, check=True)
            print(result.stdout.strip())
        except subprocess.CalledProcessError as e:
            print(e.stderr.strip(), file=sys.stderr)
            sys.exit(e.returncode)

if __name__ == "__main__":
    main()
