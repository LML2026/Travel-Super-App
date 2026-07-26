#!/usr/bin/env pwsh
$ErrorActionPreference = 'Continue'

cd "c:\Projects\TravelSuperApp"

# Check if files exist
Write-Host "Files exist:"
Test-Path "lib\core\data\destinations.dart" | Write-Host
Test-Path "lib\core\models\destination.dart" | Write-Host

# Add files
Write-Host "Running: git add ."
& git add .

# Check status
Write-Host "Running: git status"
& git status --short > status.txt 2>&1
Get-Content status.txt

# Commit
Write-Host "Running: git commit"
& git commit -m "Add destination model and sample data" > commit.txt 2>&1
Get-Content commit.txt

# Push
Write-Host "Running: git push"
& git push > push.txt 2>&1
Get-Content push.txt

Write-Host "Done! Check status.txt, commit.txt, and push.txt for details."
