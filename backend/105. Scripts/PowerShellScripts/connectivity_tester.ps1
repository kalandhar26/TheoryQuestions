# Set the error action prefernce to ignore to prevent error messages from being displayed during ping attempts
$ErrorActionPreference = "Ignore"

# Define Variable
$server = "www.google.com"
$maxAttemps = 5
$successfulPings = $false

# Start the loop
for ($i = 1; $i -le $maxAttemps; $i++) {

    # Calculate timeout, increase by 1 second each attempt
    $timeout = $i
    Write-Host "Attempting to ping $server with a timeout of $timeout milliseconds (Attempt $i)"
    # Attempt to ping the server
    $pingResult = Test-Connection -ComputerName $server -Count 1 -TimeoutSeconds $timeout -ErrorAction SilentlyContinue

    if ($pingResult) {
        $successfulPings = $true
        Write-Host "Ping successful to $server (Attempt $i)" -ForegroundColor Green
        break
    }
    else {
        Write-Host "Ping failed to $server (Attempt $i)" -ForegroundColor Yellow
    }
}

# Final Result
if ($successfulPings) {
    Write-Host "Successfully connected to $server after $i attempt(s)." -ForegroundColor Green
}
else {
    Write-Host "Failed to connect to $server after $maxAttemps attempts." -ForegroundColor Red
}