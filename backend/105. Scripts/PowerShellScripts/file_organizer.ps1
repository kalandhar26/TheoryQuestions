# Define the path for error log file
$errorLogPath = "$PWD\error_log.txt"

# Create the error log file if it does not exist
if (-not (Test-Path -Path $errorLogPath)) {
    Write-Host "Creating error log file at: $errorLogPath"
    New-Item -ItemType File -Path $errorLogPath -ErrorAction SilentlyContinue | Out-Null
}

# Example of using a if-elseif statement to filter processes based on memory usage
if ($file.Extension -eq ".txt" -or $file.Extension -eq ".docx" -or $file.Extension -eq ".pdf") {
    $destinationPath = "C:\OrganizedFiles\Documents"
}
elseif ($file.Extension -eq ".jpeg" -or $file.Extension -eq ".png") {
    $destinationPath = "C:\OrganizedFiles\ImageFiles"
}

# Create a hashtable to store unknown file extensions and their count
$unknownFileExtensions = @{}

#Define a hash table to store the file extensions and their corresponding destination
# This allows for easy categorization of files based on their extensions
$extensionMap = @{
    ".txt"  = "Documents"
    ".docx" = "Documents"
    ".pdf"  = "Documents"
    ".jpeg" = "ImageFiles"
    ".png"  = "ImageFiles"
    ".mp4"  = "Videos"
    ".avi"  = "Videos"
    ".mkv"  = "Videos"
    ".mp3"  = "AudioFiles"
    ".wav"  = "AudioFiles"
    ".aac"  = "AudioFiles"
}

# Print a value from a Key
Write-Host $extensionMap[".txt"]

# function to move a file to its category folder based on its extension
function Move-FileToCategory ($file, $category) {
    # Construct the path for destination foler
    # $PWD represents the current working directory, and we are creating a subfolder for each category within it
    $destinationFolder = "$PWD\$category"

    # Create the destination folder if it does not exist and move the file to the appropriate category folder
    # The [void] supress the output of New-Itenm cmdlet, and Out-Null is used to discard the output of Move-Item cmdlet
    if (-not (Test-Path -Path $destinationPath)) {
        [void](New-Item -ItemType Directory -Path $destinationFolder -WhatIf -ErrorAction Stop | Out-Null)
    }

    # Construct the full destination Path for the file.
    # This represents the original file name.
    $destinationPath = "$destinationFolder\$($file.Name)"

    # Move the file (with WhatIf for safety)
    # Remove the -WhatIf parameter to actually move the files instead of simulating the move operation
    Move-Item -Path $file.FullName -Destination $destinationPath -WhatIf -ErrorAction Continue | Out-Null

    # Output a message indicating which file was moved and to which category
    Write-Host "Moved file: $($file.Name) to category: $category"
}


# Initializ a counter for categorized files
# This will help provide a summary of how many files were categorized at the end of the script
$categorizedFilesCount = 0

#Loop through all the files in the current directory and categorize them based on their extensions
# Get-ChildItem -File ensures we only process files, not directories

foreach ($file in Get-ChildItem -File -ErrorAction SilentlyContinue) {
    try {
        # Get the file extension and check if it matches any of the extensions defined in the $fileCategories hash table
        # If a match is found, the file is moved to the corresponding category folder using the
        # Move-FileToCategory function, and the categorized files counter is incremented
        $extension = $file.Extension.ToLower()
        $category = $extensionMap[$extension]

        if ($extensionMap.ContainsKey($extension)) {
            Move-FileToCategory -file $file -category $category
            $categorizedFilesCount++
        }
        else {
            # Move files to "Miscellaneous" folder if their extensions do not match any of the defined categories
            $destinationFolder = "$PWD\Miscellaneous"
            if (-not (Test-Path -Path $destinationFolder)) {
                [void](New-Item -ItemType Directory -Path $destinationFolder -WhatIf | Out-Null)
            }
            Move-FileToCategory $file -category "Miscellaneous"
            $categorizedFilesCount++
            # Keep track of unknown file extensions and their count in the $unknownFileExtensions hashtable
            if ($unknownFileExtensions.ContainsKey($file.Extension)) {
                $unknownFileExtensions[$file.Extension]++       
            }
            else {
                $unknownFileExtensions[$file.Extension] = 1
            }
        }
    }
    catch {
        # If an error occurs during the file categorization process, log the error message to the error log file
        $errorMessage = "Error processing file: $($file.FullName) - $_"
        Add-Content -Path $errorLogPath -Value $errorMessage
        Write-Host "An error occurred while processing file: $($file.FullName). Check the error log for details."
    }
}

#Output the total count of categorized files at the end of the script to provide a summary of the categorization process
Write-Host "Total categorized files: $categorizedFilesCount"

#Output the unknown file extensions and their counts
Write-Host "Unknown file extensions:"
foreach ($extension in $unknownFileExtensions.Keys) {
    Write-Host "${extension}: $($unknownFileExtensions[$extension])"
}


# Check and report errors
if (Test-Path -Path $errorLogPath) {
    $errorCount = (Get-Content -Path $errorLogPath).Count
    if ($errorCount -gt 0) {
        Write-Host "Total errors logged: $errorCount. Check the error log for details."
    }
    else {
        Write-Host "No errors logged during the file organization process."
    }
}else{
    Write-Host "Error log file not found. No errors were logged during the file organization process."
}

