# Define the parameters of the script
param (
    # Define the process name parameter as mandatory and in the first position
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$ProcessName,
    # Define the action parameter with a set of valid values and in the second position
    [Parameter(Position = 1)]
    [ValidateSet("Start", "Stop", "Restart", "Info", "None")]
    [string]$Action = "None"
)

# use the Switch statement to perform the action based on the value of the Action parameter
switch ($Action) {
    "Start" {

        # Check if the process is already running before starting it
        if (Get-Process -Name $ProcessName) {
            Write-Host "Process '$ProcessName' is already running."
        }
        else {
            # If the process is not running, start it
            Write-Host "Starting process '$ProcessName'."
            # Start-Process -FilePath $ProcessName
        }
    }
    "Stop" {

        # Check if the process is running before trying to stop it
        if (Get-Process -Name $ProcessName) {
            # If running, stop the process
            Stop-Process -Name $ProcessName - Force
            Write-Host "Process '$ProcessName' has been stopped."
        }
        else {
            Write-Host "Process '$ProcessName' is not running."
        }
    }
    "Restart" {
        # Check if the process is running before trying to restart it
        if (Get-Process -Name $ProcessName) {
            # If running, stop the process and then restart it
            Stop-Process -Name $ProcessName - Force
            Write-Host "Process '$ProcessName' has been stopped."
            Write-Host "Restarting process '$ProcessName'."
            Start-Process $ProcessName
        }
        else {
            # If not running, just start the process
            Write-Host "Process '$ProcessName' is not running. Starting it now."
            Start-Process $ProcessName
        }
    }
    "Info" {
        # Try to get information about the process, and handle the case where the process is not running
        $process = Get-Process -Name $ProcessName 

        if ($process) {
            # If process exists, display its information
            Write-Host "Information about process '$ProcessName':"
            $process | Format-List *
            Write-Host "Process Name: $($process.ProcessName)"
            Write-Host "Process ID: $($process.Id)"
            Write-Host "CPU Usage: $($process.CPU) seconds"
            Write-Host "Memory Usage: $($process.WorkingSet64 / 1MB) MB"
        }
        else {
            Write-Host "Process '$ProcessName' is not running. No information available."
        }
    }
    "None" {
        Write-Host "No action specified for process '$ProcessName'."
    }
}