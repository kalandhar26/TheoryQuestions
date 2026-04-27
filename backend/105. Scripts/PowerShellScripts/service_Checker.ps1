#
$ErrorActionPreference = "SilentlyContinue"

# Function to check the status of a service and perform an action based on the statusl̥
function Check-ServiceStatus {
    param (
        # Define the service name parameter as mandatory and in the first position
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$serviceName,
        # Define the action parameter with a set of valid values and in the second position
        [Parameter(Position = 1)]
        [ValidateSet("Start", "Stop", "None")]
        [string]$action="None"
    )

    $service_status = (Get-Service -Name $serviceName).Status

    if ($service_status -eq 'Stopped') {
        
        if ($action -eq 'Start') {
            Write-Host "Starting '$serviceName' service."
            # Start-Service -Name $serviceName
        }
    }
    else {
        if ($action -eq 'Stop') {
            Write-Host "Stopping '$serviceName' service."
            # Stop-Service -Name $serviceName
        }
    }
}

# Example usage of the function
# Check-ServiceStatus -serviceName "Spooler" -action "Start"
# Check-ServiceStatus -serviceName "Spooler" -action "Stop"

# Example usage of the function Another Way
# Check-ServiceStatus  "Spooler"  "Start"
# Check-ServiceStatus  "Spooler"  "Stop"