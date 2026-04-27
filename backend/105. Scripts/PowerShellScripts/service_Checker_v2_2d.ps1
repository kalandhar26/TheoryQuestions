# Function to check the status of given service
function Check-ServiceStatus {
    param (
        # Define the service name parameter as mandatory and in the first position
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$serviceName
    )

    # Get the status of the service and display it
    $service_status = (Get-Service -Name $serviceName).Status

    if ($service_status -eq 'Stopped') {
        return $false
    }
    else {
        return $true
    }
}

# Multidimensional array of service names to check
$services_2d = @(
    @("wuauserv", "Windows Update", "Critical for keeping the system up to date with security patches and updates."),
    @("BITS", "Background Intelligent Transfer Service", "Critical for downloading updates and other files in the background without disrupting the user's experience."),
    @("WinDefend", "Windows Defender Advanced Threat Protection", "Critical for providing real-time protection against malware and other security threats."),
    @("Spooler", "Print Spooler", "Non-critical for most users, but necessary for printing functionality. If stopped, users will not be able to print documents."),
    @("Themes", "Themes", "Ignoring this service is generally safe, as it is responsible for managing visual themes and does not impact critical system functionality.")
)

# Accessing individual elements using index value
Write-Host "First service to check: $($services_2d[0][0]) - $($services_2d[0][1])"

# Modifying array elements
$services_2d[3][0] = "Spooler" # Change the service name of the fourth element to "Spooler" 
Write-Host "Updated fourth service to check: $($services_2d[3][0]) - $($services_2d[3][1])"

# Slicing the array to get a subset of services
$subset_services = $services_2d[0..2] # Get the first three services
Write-Host "Subset of services to check: $subset_services"       
foreach ($service in $subset_services) {
    Write-Host "$($service[0]) - $($service[1])"
}

# Iterate 2 D array using nested loops
foreach ($service in $services_2d) {
    # Extrac information from inner array
    $serviceName = $service[0]
    $serviceDescription = $service[1]
    $serviceAction = $service[2]
    # Check the status of the service and display the result
    if (Check-ServiceStatus $serviceName) {
        # If the service is running, display a message indicating that it is running
        Write-Host "Service '$serviceName' is running. Description: $serviceDescription. Action: $serviceAction"
    }
    else {
        # If the service is stopped, display a message indicating that it is stopped
        Write-Host "Service '$serviceName' is stopped. Description: $serviceDescription. Action: $serviceAction"
    }
    
    # perform an action based on the status of the service
    if(serviceAction -eq "TryStart") {
        Write-Host "Attempting to start service '$serviceName'..."
        # Start-Service -Name $serviceName
    }elseif ($serviceName -eq "AlertOnly") {
       Write-Host "Alert: Service '$serviceName' is stopped. This may have implications for system functionality. Please investigate further."
    }else{
        Write-Host "No action needed for service '$serviceName' ($serviceDescriptionl̥)."
    }
}
