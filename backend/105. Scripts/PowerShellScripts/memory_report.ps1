#  Parameter for Search Functionality
param(
    [string]$SearchProcess
)

# Create an arraylist to hold memory -intensive processes
$MemoryIntensiveProcesses = [System.Collections.ArrayList]::new()

# Get All Running processes and check their memory usage
$allProcesses = Get-Process

# Loop Through each process and check if it is using more than 100 MB of memory, if so add it to the arraylist
foreach ($process in $allProcesses) {
    # Check if the process is using more than 100 MB of memory
    if ($process.WorkingSet64 -gt 100MB) {
        # Add the process to the arraylist
        [void]$MemoryIntensiveProcesses.Add($process) | Out-Null
    }
}

# Display Report Header
Write-Output "Memory Intensive Processes Report"
Write-Output "-------------------------------"
Write-Output "Total Memory Intensive Processes: $($MemoryIntensiveProcesses.Count)"

# Sort Processors by memory usage
$sortedProcessors = $MemoryIntensiveProcesses | Sort-Object -Property WorkingSet64 -Descending


# Loop through the memory intensive processes and output their names, IDs, and memory usage
foreach ($process in $MemoryIntensiveProcesses) {
    $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
    Write-Output "Process: $($process.ProcessName), ID: $($process.Id), Memory Usage: $memoryUsageMB MB"
}

# Calculate and Display the total memory usage of all memory intensive processes
$totalMemoryUsage = ($MemoryIntensiveProcesses | Measure-Object -Property WorkingSet64 -Sum).Sum / 1GB
$totalMemoryUsageRounded = [math]::Round($totalMemoryUsage, 2)
Write-Output "Total Memory Usage of Memory Intensive Processes: $totalMemoryUsageRounded GB"


# Add the Search Functionality to filter the memory intensive processes based on the process name provided by the user
if ($SearchProcess) {
    $filteredProcesses = $MemoryIntensiveProcesses | Where-Object { $_.ProcessName -like "*$SearchProcess*" }
    
    if ($filteredProcesses.Count -gt 0) {
        Write-Output "Filtered Memory Intensive Processes (Search: '$SearchProcess')"
        Write-Output "---------------------------------------------"
        foreach ($process in $filteredProcesses) {
            $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
            Write-Output "Process: $($process.ProcessName), ID: $($process.Id), Memory Usage: $memoryUsageMB MB"
        }
    }
    else {
        Write-Output "No memory intensive processes found matching the search term '$SearchProcess'."
    }
}

# Another way to implement the search functionality using a loop and conditional statements

if($SearchProcess){
    Write-Output "Searcing for processes matching: $SearchProcess"
    $foundProcess= $false
    foreach ($process in $MemoryIntensiveProcesses) {
        if ($process.ProcessName -like "*$SearchProcess*") {
            $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
            Write-Output "Process: $($process.ProcessName), ID: $($process.Id), Memory Usage: $memoryUsageMB MB"
            $foundProcess = $true
            exit
        }
    }
    if (-not $foundProcess) {
        Write-Output "No memory intensive processes found matching the search term '$SearchProcess'."
        exit
    }
}