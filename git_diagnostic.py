#!/usr/bin/env python3
import subprocess
import os

os.chdir("c:\\Projects\\TravelSuperApp")

output = []

# Check git status
result = subprocess.run(["git", "status", "--short"], capture_output=True, text=True)
output.append(f"=== GIT STATUS ===\n{result.stdout}\n{result.stderr}\n")

# Check last commits
result = subprocess.run(["git", "log", "--oneline", "-3"], capture_output=True, text=True)
output.append(f"=== LAST COMMITS ===\n{result.stdout}\n{result.stderr}\n")

# Check current branch
result = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True)
output.append(f"=== CURRENT BRANCH ===\n{result.stdout}\n{result.stderr}\n")

# Write to file
with open("git_diagnostic.txt", "w") as f:
    f.write("\n".join(output))

print("Diagnostic written to git_diagnostic.txt")
