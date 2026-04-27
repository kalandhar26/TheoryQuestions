# Process Checker Script
Write-Host "This Script checks if critical processes are running and generate a report about their status. It can also start, stop, or restart processes based on user input."



#Setup a global variable to store the last run time of the script even after closing the PowerShell session
$countFile = "runCount.txt"
if (Test-Path $countFile) {
    $fileContent = Get-Content $countFile

    # Use Regex to ensure this string only contains numbers // $fileContent like "*[0-9]*" -and $fileContent -notlike "*[a-zA-Z]*"
    if ($fileContent -match '^\d+$') {
        $global:scriptRunCount = [int]$fileContent
    }
    else {
        Write-Host "The content of the count file is not a valid number. Resetting the count to 0."
        $global:scriptRunCount = 0
    }
}
else {
    $global:scriptRunCount = 0
}
l̥
# Set up a run count
$global:scriptRunCount++;

# Initialize Counters
$runningCount = 0
$stoppedCount = 0

# Function to check if proceses are running or not.
function Check-ProcessStatus {
    param (
        # Define the process name parameter as mandatory and in the first position
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$ProcessName
    )

    # Try to get the process information, and handle the case where the process is not running
    $process = Get-Process -Name $ProcessName
    if ($process) {
        # process is running, display its information and increment the running count
        Write-Host "Process '$ProcessName' is running."
        $script:runningCount++
        return $true
    }
    else {
        # process is not running, display a message and increment the not stopped count
        Write-Host "Process '$ProcessName' is not running."
        $script:stoppedCount++
        return $false
    }
}

# Check Windows Explorer process
if (Check-ProcessStatus "explorer") {
    Write-Host "Windows Explorer is running."
}
else {
    Write-Host "Windows Explorer is not running. This is unusual and may indicate a problem with the system."
}

# Check Task Manager process
if (Check-ProcessStatus "taskmgr") {
    Write-Host "Task Manager is running."
}
else {
    Write-Host "Task Manager is not running. This is normal if the user has not opened it."
}   

# Check Windows Security process
if (Check-ProcessStatus "SecurityHealthySystray") {
    Write-Host "Windows Security is running."l̥
}
else {
    Write-Host "Windows Security is not running. This might be a security concern."
}

# Check Windows Search process
if (Check-ProcessStatus "SearchApp") {
    Write-Host "Windows Search is running."
}
else {
    Write-Host "Windows Search is not running. This may affect the search functionality on the system."
}


# Generate a report about the status of the processes
Write-Host "Process Status Report:"
Write-Host "----------------------"
Write-Host "Running Processes: $runningCount"
Write-Host "Stopped Processes: $stoppedCount"
Write-Host "Total Processes Checked: $runningCount + $stoppedCount"  


# Set the global variable to store the total number of processes checked at specified time
$global:lastRunTime = Get-Date
$global:totalProcessesChecked = $runningCount + $stoppedCount

# This is a example of a local variable
$local:localVariable = "I exists only within the current scope of the function or script block where it is defined."

# Display run count
Write-Host "This script has been run $global:scriptRunCount times."

# Save the run count to a file so it persists across sessions
Set-Content -Path $countFile -Value $global:scriptRunCount

$global:scriptRunCount | Out-File $countFile -Force