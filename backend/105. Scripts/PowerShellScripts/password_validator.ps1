# Initialize variables
$attempts = 0
$maxAttempts = 3
$isValid = $false

do {
    $password = Read-Host "Enter password (min 8 chars, include A-Z, a-z, number, symbol)"
    $attempts++

    # Validate password
    if (
        $password.Length -ge 8 -and
        $password -match "[A-Z]" -and
        $password -match "[a-z]" -and
        $password -match "[0-9]" -and
        $password -match "[^a-zA-Z0-9]"
    ) {
        $isValid = $true
        break
    }
    else {
        Write-Host "Invalid password. Try again." -ForegroundColor Yellow
    }

} while ($attempts -lt $maxAttempts)

# Final outcome
if ($isValid) {
    Write-Host "Password is valid! Attempts used: $attempts" -ForegroundColor Green
}
else {
    Write-Host "Maximum attempts ($maxAttempts) reached. Exiting..." -ForegroundColor Red
}