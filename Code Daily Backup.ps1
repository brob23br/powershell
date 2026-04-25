$source = "C:\VS Code"
$destination = "C:\Users\brob2\OneDrive\VS Code\AMD-BR"

# Create the destination directory if it doesn't exist
if (!(Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination
}

# Copy only changed or new files from source to destination
try {
    # Your code that might throw an error
    Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}