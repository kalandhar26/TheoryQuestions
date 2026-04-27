# Automated File Archiver and Cleaner Script
# This script is designed to automate the process of archiving files that are older than 30 days and Zip them and put in Archive folder and cleaning up files in a specified archve directory files that are older than 1 year.

$ErrorActionPreference = "Stop" # Set the error action preference to stop on errors to prevent error messages from being displayed during the archiving and cleaning process.
# Define Paths
$sourceDirectory = "C:\Path\To\SourceDirectory"
$archiveDirectory = "C:\Path\To\ArchiveDirectory"

# Check if source directory exists
if (-Not (Test-Path -Path $sourceDirectory)) {
    Write-Host "Source directory does not exist: $sourceDirectory" -ForegroundColor Red
    exit
}

# Create archive directory if it does not exist
if (-Not (Test-Path -Path $archiveDirectory)) {
    New-Item -ItemType Directory -Path $archiveDirectory -ErrorAction Stop | Out-Null
    Write-Host "Created archive directory: $archiveDirectory" -ForegroundColor Green
}

# Get files that are older than 30 days from the source directory
$filesToArchive = Get-ChildItem -Path $sourceDirectory -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }

# Archive files by moving them to the archive directory and zipping them
foreach ($file in $filesToArchive) {

    try {
        $destinationPath = Join-Path -Path $archiveDirectory -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destinationPath
        Write-Host "Archived file: $($file.FullName) to $destinationPath" -ForegroundColor Green

        # Zip the archived file and remove the original file after zipping
        $zipFilePath = "$destinationPath.zip"
        Compress-Archive -Path $destinationPath -DestinationPath $zipFilePath -ErrorAction Stop
        Write-Host "Zipped file: $destinationPath to $zipFilePath" -ForegroundColor Green
    }
    catch {
        # If compressing the file fails, attemp to copy the file to the archive directory
        Write-Error "Error compressing file: $($file.FullName). Attempting to copy the file to the archive directory instead. Error: $_"
        Copy-Item -Path $file.FullName -Destination $destinationPath -ErrorAction Stop
        Write-Host "Copied file: $($file.FullName) to $destinationPath" -ForegroundColor Yellow
    }
    finally {
        # Remove the original file after zipping or copying, regardless of whether the compression or copying was successful
        if (Test-Path -Path $destinationPath) {
            Remove-Item -Path $destinationPath -ErrorAction SilentlyContinue
            Write-Host "Removed original file: $destinationPath" -ForegroundColor Yellow
        }
    }



    # Clean up files in the archive directory that are older than 1 year
    $filesToClean = Get-ChildItem -Path $archiveDirectory -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddYears(-1) }
    foreach ($file in $filesToClean) {
        Remove-Item -Path $file.FullName
        Write-Host "Removed old archived file: $($file.FullName)" -ForegroundColor Yellow
    }

    # Generate a summary report
    $totalArchivedFiles = $filesToArchive.Count
    $totalCleanedFiles = $filesToClean.Count
    $report = @"
File Archiver and Cleaner Summary Report
========================================
Total Files Archived: $totalArchivedFiles
Total Files Cleaned: $totalCleanedFiles
"@

    Write-Host $report -ForegroundColor Green

    Write-Host "File archiving and cleaning process completed." -ForegroundColor Green