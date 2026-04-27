# Define parameters for the script
param(
    # Define an array of file extensions to search for
    [string[]]$extensions = @("*.txt", "*.log", "*.csv","*.xml", "*.json","*.html", "*.htm", "*.md", "*.ps1", "*.psm1", "*.psd1", "*.docx", "*.xlsx", "*.pptx"),
    
    # Define the directory to search in
    [string]$directory = "C:\Users\babak\Desktop\test"
)

# Adding total Count functionality
$totalFiles = 0

# Loop through each extension and search for files
foreach ($extension in $extensions) {
    # Get all files with the current extension in the specified directory and its subdirectories
    $files = Get-ChildItem -Path $directory -Filter $extension -Recurse
    $count = $files.Count
    Write-Host "Found $count files with extension '$extension' in directory '$directory'."

    # Add to the running total of files found
    $totalFiles += $count

    # Calculate the total files size in MB
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
    Write-Host "Total size of '$extension' files: $totalSizeMB MB"

    # Display information for the current file extension
    Write-Host "Number of $extension files: $count, Total size: $totalSizeMB MB"

    # Loop through each file and display its name and path
    foreach ($file in $files) {
        Write-Host "Found file: $($file.FullName)"
    }
}
Write-Host "Total files found: $totalFiles"