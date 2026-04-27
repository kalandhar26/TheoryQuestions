# Set the error action prefernce to silently continue to prevent error messages from being displayed during information gathering.
$ErrorActionPreference = "SilentlyContinue" 

# Get the system Information
Write-Host "Gathering system information..." -ForegroundColor Cyan
$computername = $env:COMPUTERNAME
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$cpuInfo = Get-CimInstance -ClassName Win32_Processor
$memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory
$diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" # Only local disks
$totalMemoryGB = [math]::Round(($memoryInfo.Capacity | Measure-Object -Sum).Sum / 1GB, 2)
$freeMemoryGB = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
$totalDiskGB = [math]::Round(($diskInfo.Size | Measure-Object -Sum).Sum / 1GB, 2)
$freeDiskGB = [math]::Round(($diskInfo.FreeSpace | Measure-Object -Sum).Sum / 1GB, 2)
$totalSpaceGB = [math]::Round(($diskInfo.Size | Measure-Object -Sum).Sum / 1GB, 2)
$freeSpaceGB = [math]::Round(($diskInfo.FreeSpace | Measure-Object -Sum).Sum / 1GB, 2)  


# Calculate System UpTime
$uptime = (Get-Date) - $osInfo.LastBootUpTime
$uptimeDays = [math]::Floor($uptime.TotalDays)
$uptimeHours = [math]::Floor($uptime.TotalHours % 24)
$uptimeMinutes = [math]::Floor($uptime.TotalMinutes % 60)
$uptimeSeconds = [math]::Floor($uptime.TotalSeconds % 60)

# Generate the report
$report = @"
System Health Report
======================
Computer Name: $computername
Operating System: $($osInfo.Caption) $($osInfo.OSArchitecture)
CPU: $($cpuInfo.Name)
Total Memory: $totalMemoryGB GB
Free Memory: $freeMemoryGB GB
Total Disk Space: $totalDiskGB GB
Free Disk Space: $freeDiskGB GB
System Uptime: $uptimeDays days, $uptimeHours hours, $uptimeMinutes minutes, $uptimeSeconds seconds
"@     
# Output the report to the console
Write-Host $report -ForegroundColor Green

# Optionally, save the report to a file
$reportFilePath = "C:\SystemHealthReport.txt"
$report | Out-File -Append $reportFilePath -Encoding UTF8
Write-Host "System health report has been saved to $reportFilePath" -ForegroundColor Green
