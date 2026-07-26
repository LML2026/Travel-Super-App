import subprocess
import os

os.chdir("c:\\Projects\\TravelSuperApp")

commands = [
    "git add .",
    'git commit -m "Add reusable home header"',
    "git push -u origin main"
]

for cmd in commands:
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(f"STDOUT: {result.stdout}")
    print(f"STDERR: {result.stderr}")
    print(f"Return code: {result.returncode}")
    print("---")
