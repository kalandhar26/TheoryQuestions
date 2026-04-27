# Start the infinite loop to monitor CPU usage
while ($true) {
    # Get the current CPU usage percentage
    $cpuUsage = (Get-CimInstance -ClassName Win32_Processor).LoadPercentage

    # Display the current CPU usage
    Write-Host "Current CPU Usage: $cpuUsage%" -ForegroundColor Cyan

    # Check if CPU usage exceeds 80%
    if ($cpuUsage -gt 80) {
        Write-Host "Warning: High CPU Usage detected! Current usage is $cpuUsage%" -ForegroundColor Red
        
        # Optionally, you can add actions here, such as logging the event, sending an email alert, or taking corrective measures to reduce CPU usage.
        # Example: Log the event
        # "$( Get-Date ): High CPU Usage detected at $cpuUsage%" | Out-File -FilePath "C:\Path\To\LogFile.txt" -Append
        # Example: Append to a log file
        # Add-Content -Append -Value "High CPU Usage detected at $(Get-Date): $cpuUsage%"
        # Example: Send an email alert (requires configuration of email settings)
        # Send-MailMessage -From "sender@example.com" -To "recipient@example.com" -Subject "High CPU Usage Alert" -Body "High CPU Usage detected at $(Get-Date): $cpuUsage%"
    }
    else {
        # Display normal CPU usage in green
        Write-Host "CPU Usage is within normal limits at $cpuUsage%" -ForegroundColor Green
    }

    # Wait for a specified interval before checking again (e.g., 5 seconds)
    Start-Sleep -Seconds 10
}