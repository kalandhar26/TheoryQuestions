# Initialize a flag to determine if the process is responsive
$Unresponsive = $false

# Craete an ArrayList to store the unresponsive processes
$UnresponsiveProcesses = [System.Collections.ArrayList]::new()

# # Iterate tjrough each process and check if it is responding
# foreach ($process in Get-Process) {
#     # Check if process is not responding
#     if (!$process.Responding) {
#         # Output a message indicating which process is not responding
#         Write-Host "Process $($process.ProcessName) (ID: $($process.Id)) is not responding."
#         # Set the flag to indicate that at least one process is unresponsive
#         $Unresponsive = $true
#     }
# }

# Check if any unresponsive processes were found and output the total count
if ($UnresponsiveProcesses.Count -gt 0) {
    Write-Output "Total Unresponsive Processes: $($UnresponsiveProcesses.Count)"

    # Iterate through un-responsive processes and output their names and IDs
    foreach ($process in $UnresponsiveProcesses) {
        Write-Output "Process $($process.ProcessName) (ID: $($process.Id)) is not responding. Attempting to close and restart..."
        $process.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 5
        if (!$process.Responding) {
            Write-Output "Process $($process.ProcessName) (ID: $($process.Id)) is still not responding. Forcefully terminating..."
            $process.Kill() | Out-Null
        }
        else {
            Write-Output "Process $($process.ProcessName) (ID: $($process.Id)) has been closed successfully."
        }

        # Start the process again
        Start-Process -FilePath $process.MainModule.FileName -ArgumentList $process.StartInfo.Arguments | Out-Null
        Write-Output "Process $($process.ProcessName) (ID: $($process.Id)) has been restarted successfully."
    }
}
else {
    Write-Output "All processes are responsive."
}

# Examples
# remove first element from the array list
$UnresponsiveProcesses.RemoveAt(0)
$UnresponsiveProcesses.Remove($UnresponsiveProcesses[0])

# Insert an element at a specific index
$UnresponsiveProcesses.Insert(0, $process)

# Clear the entire ArrayList
$UnresponsiveProcesses.Clear()