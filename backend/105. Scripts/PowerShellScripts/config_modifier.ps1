# Define Path to the configuration file
$configFilePath = "C:\path\to\your\config.json"

# Define the new content of the configuration file
$newConfigContent = "This is a configuration file for the application. Please modify it according to your needs."

# Attempt to back up the existing configuration file
Write-Host "Backing up the existing configuration file..."
Copy-Item -Path $configFilePath -Destination "$configFilePath.bak" -ErrorAction SilentlyContinue

# Modify the configuration file with new content
Write-Host "Modifying the configuration file..."
Set-Content -Path $configFilePath -Value $newConfigContent

Write-Host "Configuration file has been modified successfully." -ForegroundColor Green