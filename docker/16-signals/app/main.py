import signal
import time

def ignore_signal(signum, frame):
    print(f"Ignoring signal: {signum}")

signal.signal(signal.SIGTERM, ignore_signal)

print("Application started")

while True:
    time.sleep(1)
