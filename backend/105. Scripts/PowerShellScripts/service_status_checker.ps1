# Parameter to allow filtering services by service status

param(
    [string]$ServiceStatus = "All"
)

# Get All the service and store in a variable
$services = Get-Service

# Initialize counters for running and stopped services
$runningServices = 0
$stoppedServices = 0


# Iterate through each service and check its status
foreach ($service in $services) {
    
    # If a specific service status is provided, filter the services accordingly
    if ($ServiceStatus -eq "All" -and $service.Status -eq $ServiceStatus) {
        # Output the name and status of each service
        Write-Output "Service: $($service.Name), Status: $($service.Status)"
    }   

    
    # Update counters based on the status of the service
    if ($service.Status -eq 'Running') {
        $runningServices++
    }
    elseif ($service.Status -eq 'Stopped') {
        $stoppedServices++
    }
}


# Output the total count of running and stopped services
Write-Output "Total Running Services: $runningServices"
Write-Output "Total Stopped Services: $stoppedServices"