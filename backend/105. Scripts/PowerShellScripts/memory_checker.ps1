# Process Name
$processName = "notepad"
$memoryThresholdMB = $0MB


# Start with do while loop to monitor memory usage
do {
    # Get the process information
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process) {
        # Calculate current memory usage in MB
        $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
        Write-Host "Current memory usage of ${processName}: $memoryUsageMB MB" -ForegroundColor Cyan

        # Check if memory usage exceeds the threshold
        if ($memoryUsageMB -gt $memoryThresholdMB) {
            Write-Host "Warning: Memory usage of ${processName} exceeds the threshold! Current usage: $memoryUsageMB MB" -ForegroundColor Red
            
        }
    }
    else {
        Write-Host "Process ${processName} is not running." -ForegroundColor Yellow
    }
    # Continue the loop while the process exists and memory usage is below the threshold
} while ($process -and $memoryUsageMB -lt $memoryThresholdMB)


# After the lop ends, check why it ended and display appropriate message
if ($process -and $memoryUsageMB -ge $memoryThresholdMB) {
    Write-Host "Memory usage of ${processName} has exceeded the threshold. Current usage: $memoryUsageMB MB" -ForegroundColor Red
}else{
    Write-Host "Process ${processName} is no longer running. Exiting memory monitor." -ForegroundColor Yellow
}