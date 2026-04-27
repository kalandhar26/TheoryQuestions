$file = New-Item -Path "C:\Path\To\File.txt" -ItemType File
$stream = [System.IO.StreamWriter]::new($file.FullName)
$stream1 = $file.OpenWrite()
Remove-Item -Path $file.FullName -ErrorAction SilentlyContinue
$stream.WriteLine("This is a test file.")
$stream.Close()