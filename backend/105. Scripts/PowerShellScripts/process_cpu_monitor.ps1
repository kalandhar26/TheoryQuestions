# Define the Processor to monitor
$processors = @("notepad", "chrome", "calculatorApp")

# Set the CPU usage threshold percentage
$cpuThreshold = 80

# Set the monitoring interval in seconds
$monitoringInterval = 10

# Start the infinite loop to monitor CPU usage
do {
    # Iterate through each processor in the list and check its CPU usage
    foreach ($processor in $processors) {
        # Get the process information for the specified processor
        $process = Get-Process -Name $processor -ErrorAction SilentlyContinue
        # Get the current CPU usage percentage for the specified processor
        $cpuUsage = (Get-CimInstance -ClassName Win32_PerfFormattedData_PerfProc_Process -Filter "Name='$processor'").PercentProcessorTime

        if ($process) {
            # Display the current CPU usage for the processor
            Write-Host "Current CPU Usage for ${processor}: $cpuUsage%" -ForegroundColor Cyan

            # Check if CPU usage exceeds the threshold
            if ($cpuUsage -gt $cpuThreshold) {
                Write-Host "Warning: High CPU Usage detected for ${processor}! Current usage is $cpuUsage%" -ForegroundColor Red
            }
            else {
                # Display normal CPU usage in green
                Write-Host "CPU Usage for ${processor} is within normal limits at $cpuUsage%" -ForegroundColor Green
            }

            # Display the current CPU usage for the processor
            Write-Host "Current CPU Usage for ${processor}: $cpuUsage%" -ForegroundColor Cyan

            # Check if CPU usage exceeds the threshold
            if ($cpuUsage -gt $cpuThreshold) {
                Write-Host "Warning: High CPU Usage detected for ${processor}! Current usage is $cpuUsage%" -ForegroundColor Red
            }
            else {
                # Display normal CPU usage in green
                Write-Host "CPU Usage for ${processor} is within normal limits at $cpuUsage%" -ForegroundColor Green
            }
        }
        else {
            # Process is not running, display a message in yellow
            Write-Host "Process ${processor} is not running." -ForegroundColor Yellow
        }
    }
        
    Start-Sleep -Seconds $monitoringInterval # Short sleep to avoid overwhelming the system when checking multiple processors
}while ($true)