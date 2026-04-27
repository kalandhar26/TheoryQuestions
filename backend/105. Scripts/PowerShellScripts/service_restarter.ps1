# Define Variables
# Name of the service to restart. In this case, we are using the Print Spooler service as an example. You can change this to any service you want to monitor and restart.l
$serviceName = "Spooler" 
# Maximum number of attempts to restart the service.
$maxAttempts = 5  
# Flag to track if service was restarted successfully. 
$serviceRestarted = $false

# Loop through the restart attempts
for ($i = 1; $i -le $maxAttempts; $i++) {
    Write-Host "Attempting to restart the $serviceName service (Attempt $i)" -ForegroundColor Cyan
    try {
        # Attempt to restart the service
        Restart-Service -Name $serviceName -Force -ErrorAction Stop
        Write-Host "Successfully restarted the $serviceName service (Attempt $i)" -ForegroundColor Green
        $serviceRestarted = $true
        break
    }
    catch {
        Write-Host "Failed to restart the $serviceName service (Attempt $i). Error: $_" -ForegroundColor Yellow
    }

    # Calculate and wait before the next attempt, increasing the wait time by 5 second for each attempt
    if ($i -lt $maxAttempts) {
        $waitTime = $i * 5
        Write-Host "Waiting for $waitTime seconds before the next attempt..." -ForegroundColor Cyan
        Start-Sleep -Seconds $waitTime
    }
}

# Check if the service was restarted successfully after all attempts
if ($serviceRestarted) {
    Write-Host "The $serviceName service was restarted successfully after $i attempt(s)." -ForegroundColor Green
} else {
    Write-Host "Failed to restart the $serviceName service after $maxAttempts attempts." -ForegroundColor Red
}

