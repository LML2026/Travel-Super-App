#!/usr/bin/env pwsh
cd "c:\Projects\TravelSuperApp"
Write-Host "Adding changes..."
git add .
Write-Host "Committing..."
git commit -m "Add reusable home header"
Write-Host "Pushing to main..."
git push -u origin main
Write-Host "Done!"
