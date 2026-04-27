# Set the Error action Preference to stop on errors to prevent error messages from being displayed during the archiving and cleaning process.
# This will cause non-terminating errors to be treated as terminating errors, which will stop the script execution and display the error message. This is useful for debugging and ensuring that any issues during the archiving and cleaning process are properly handled and not ignored.
$ErrorActionPreference = "Stop"

# Define Paths
$configFilePath = "C:\Path\To\ConfigFile.txt"
$backupDirectory = "C:\Path\To\BackupDirectory"
$errorLogPath = "C:\Path\To\ErrorLog.txt"

# Advanced logging function
function Log-Error {
    param(
        [string]$ErrorRecord,
        [string]$customMessage
    )

    # Here-String for datailed error information

    $errorDetails = @"
    Date: $(Get-Date)
    Custom Message: $customMessage
    Error Message: $($ErrorRecord.Exception.Message)
    Stack Trace: $($ErrorRecord.Exception.StackTrace)
    Error Type: $($ErrorRecord.Exception.GetType().FullName)
    Script Line: $($ErrorRecord.ScriptLineNumber)
    Script Name: $($ErrorRecord.ScriptName)
"@

    # Log the error details to the error log file
    $errorDetails | Out-File -FilePath $errorLogPath -Append -ErrorAction SilentlyContinue

    # Append error details to log file
    Add-Content -Path $errorLogPath -Value $errorDetails -ErrorAction SilentlyContinue
    Write-Host "Error logged. See $errorLogPath for details." -ForegroundColor Red
}

# Create error log file if it does not exist
if (-Not (Test-Path -Path $errorLogPath)) {
    New-Item -ItemType File -Path $errorLogPath -ErrorAction Stop | Out-Null
    Write-Host "Created error log file: $errorLogPath" -ForegroundColor Green
}

try {
    # Check if the config file exists
    if (-Not (Test-Path -Path $configFilePath)) {
        Write-Host "Config file does not exist: $configFilePath" -ForegroundColor Red
        Exit-PSHostProcess
    }

    # Create backup directory if it does not exist
    if (-Not (Test-Path -Path $backupDirectory)) {
        New-Item -ItemType Directory -Path $backupDirectory -ErrorAction Stop | Out-Null
        Write-Host "Created backup directory: $backupDirectory" -ForegroundColor Green
    }
}
catch {
    # Log the error using Log-Error function and exit the script if there is an issue with checking the config file or creating the backup directory
    $customMessage = "An error occurred while checking the config file or creating the backup directory.Error: $_"
    Log-Error -ErrorRecord $_ -customMessage $customMessage
    Exit-PSHostProcess
}

try {
    # Genearte a unique backup file name using the current date and time to prevent overwriting previous backups
    $backupFileName = "ConfigFileBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $backupFilePath = Join-Path -Path $backupDirectory -ChildPath $backupFileName

    # copy the config file to the backup directory with the unique backup file name
    Copy-Item -Path $configFilePath -Destination $backupFilePath -ErrorAction Stop

    Write-Host "Config file backed up successfully to: $backupFilePath" -ForegroundColor Green
}
catch {
    # Log the error using Log-Error function and attempt an alternative backup method if there is an issue with copying the config file, such as file permissions or if the file is locked by another process
    $customMessage = "An error occurred while copying the config file. Attempting alternative backup method. Error: $_"
    Log-Error -ErrorRecord $_ -customMessage $customMessage


    # Alternate backuo method using Get-Content and Out-File to read the content of the config file and write it to the backup file, which can be useful if there are issues with file permissions or if the config file is locked by another process, preventing Copy-Item from successfully copying the file.
    try {
        Write-Warning "Failed to create backup using Copy-Item. Error: $_"
        $content = Get-Content -Path $configFilePath -ErrorAction Stop
        $content | Out-File -FilePath $backupFilePath -ErrorAction Stop
        Write-Host "Config file backed up successfully using alternative method at: $backupFilePath" -ForegroundColor Green
    }
    catch {
        # Log the error using Log-Error function and display an error message if there is an issue with the alternative backup method
        $customMessage = "An error occurred while backing up the config file using the alternative method. All backup attempts Failed. Error: $_"
        Log-Error -ErrorRecord $_ -customMessage $customMessage
        Exit-PSHostProcess
    }
}
finally {
    Write-Host "Backup Operation completed. Exiting Script"
    exit
}



