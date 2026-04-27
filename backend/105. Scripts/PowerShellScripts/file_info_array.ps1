# Get All file in Specified Directory
$files = Get-ChildItem -Path "C:\Users\babak\Desktop\test" -File 

# Create a 2D array to store file information
$fileInfoArray = @()

# Loop through each file and display its name and path
foreach ($file in $files) {
    Write-Host "Found file: $($file.FullName)"
    #Create an array for each file to store its name, path, and size, extension and last modified date
    $fileInfo = @($file.Name, $file.FullName, $file.Length, $file.Extension, $file.LastWriteTime)
    # Add file information to the 2D array
    # $fileInfoArray += ,($file.Name, $file.FullName, $file.Length,$file.Extension, $file.LastWriteTime)
    $fileInfoArray += ,$fileInfo
}

# Display the 2D array of file information
Write-Host "File Information Array:"
foreach ($fileInfo in $fileInfoArray) {
    Write-Host "Name: $($fileInfo[0]), Path: $($fileInfo[1]), Size: $($fileInfo[2]) bytes, Extension: $($fileInfo[3]), Last Modified: $($fileInfo[4])"
}

# Another way to display file informatoin
Write-Host "File Information Array:"
foreach ($fileInfo in $fileInfoArray) {
    $fileName = $fileInfo[0]
    $filePath = $fileInfo[1]
    $fileSize = $fileInfo[2]
    $fileExtension = $fileInfo[3]
    $fileLastModified = $fileInfo[4]

    Write-Host "Name: $($fileName), Path: $($filePath), Size: $($fileSize) bytes, Extension: $($fileExtension), Last Modified: $($fileLastModified)"
}

# Sort files by size in descending order and display the top 5 largest files
$sortedFiles = $fileInfoArray | Sort-Object -Property { $_[2] } -Descending
Write-Host "Top 5 Largest Files:"
for ($i = 0; $i -lt [math]::Min(5, $sortedFiles.Count); $i++) {
    $fileInfo = $sortedFiles[$i]
    Write-Host "Name: $($fileInfo[0]), Path: $($fileInfo[1]), Size: $($fileInfo[2]) bytes, Extension: $($fileInfo[3]), Last Modified: $($fileInfo[4])"
}

foreach ($fileInfo in $sortedFiles) {
    if ($fileInfo[3] -eq ".txt") {
        Write-Host "Text File: Name: $($fileInfo[0]), Path: $($fileInfo[1]), Size: $($fileInfo[2]) bytes, Last Modified: $($fileInfo[4])"
    }
}




