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

# ------------------ Start ----------------
# # Check the status of the Windows Update Service
# if (Check-ServiceStatus "wuauserv") {
#     Write-Host "Windows Update Service is running."
# }
# else {
#     Write-Host "Windows Update Service is stopped. This may prevent the system from receiving important updates and security patches. Attempting to Start..."
#     # Start the service ( Comment it)
#     # Start-Service -Name "wuauserv"

# }

# # Check the Status of Windows Defender Antivirus Service
# if (Check-ServiceStatus "WinDefend") {
#     Write-Host "Windows Defender Antivirus Service is running."
# }
# else {
#     Write-Host "Windows Defender Antivirus Service is stopped. This may leave the system vulnerable to malware and other security threats. Attempting to Start..."
#     # Start the service ( Comment it)
#     # Start-Service -Name "WinDefend"
# } 
# ------------------ End ----------------

# Array of service names to check
$services = @("wuauserv", "WinDefend", "Spooler", "BITS", "LanmanServer")

# Example of modifying array elements
$services[2] = "Spooler" # Change the third element to "Spooler"

# Example of accessing individual elements using index value
Write-Host "First service to check: $($services[0])"

# Example of access array elements using forEach loop
# Loop through each service in the array and check its status
foreach ($service in $services) {
    # Check the status of the service and display the result
    if (Check-ServiceStatus $service) {
        # If the service is running, display a message indicating that it is running
        Write-Host "Service '$service' is running."
    }
    else {
        # If the service is stopped, display a message indicating that it is stopped and may indicate a problem with the system or a potential security risk.
        Write-Host "Service '$service' is stopped. This may indicate a problem with the system or a potential security risk. Attempting to Start..."
        # Start the service ( Comment it)
        # Start-Service -Name $service
    }
}

# Example of slicing an array
$partialServices = $services[1..3] # Get the second to fourth elements
Write-Host "Partial list of services to check: $($partialServices -join ', ')"