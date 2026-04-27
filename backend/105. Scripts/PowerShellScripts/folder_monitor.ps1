#Set the Path of the folder to monitor
$folderPath = "C:\Path\To\Your\Folder"

# Get the initial file count in the folder
$initialFileCount = (Get-ChildItem -Path $folderPath).Count

# Displat initial information
Write-Host "Monitoring folder: $folderPath" -ForegroundColor Cyan
Write-Host "Initial file count: $initialFileCount" -ForegroundColor Cyan

# Start monitoring the folder
while ($true) {
    # Pause for 5 seconds to avoid excessive resource usage
    Start-Sleep -Seconds 5
    
    # Get the current file count in the folder
    $currentFileCount = (Get-ChildItem -Path $folderPath).Count

    # Check if the file count has changed
    if ($currentFileCount -ne $initialFileCount) {
        Write-Host "File count changed! Initial: $initialFileCount, Current: $currentFileCount" -ForegroundColor Green
        # Update the initial file count to the current count for the next comparison
        $initialFileCount = $currentFileCount
    }

    # Wait for a specified interval before checking again (e.g., 5 seconds)
    Start-Sleep -Seconds 5
}