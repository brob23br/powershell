# Name: Brandon Robinson | Student ID: 001260410 

# Run Get-Filehash at the end. Paste hash value in the comments section

# Display menu options to the user
function menuDisplay{
    Write-Host ""
    Write-Host "Select and option"
    Write-Host "1. Find .log files and add them to DailyLog.txt"
    Write-Host "2. List files inside Requirements1 and output to C916contenst.txt"
    Write-Host "3. List CPU and memory usage"
    Write-Host "4. Show running processes"
    Write-Host "5. Exit"
}
# List .log files in the Requirements1 folder and append them to the DailyLog.txt file with timestamp
function logFiles{
    param(
        [string]$folderPath,
        [string]$logFilePath
    )

        $todaysDate = Get-Date
        Add-Content -Path $logFilePath -Value "`n$($todaysDate.ToString('yyyy-MM-dd HH:mm:ss'))"

        Get-ChildItem -Path $folderPath | Where-Object {$_.Name -match '\.log$'} | ForEach-Object{
            Add-Content -Path $logFilePath -Value $_.Name}
}

# List the files in Requirements1 in ascending alphbetical order and output to C916contents.txt
function folderContents{
    param(
        [string]$folderPath
    )
    Get-ChildItem -Path $folderPath | Sort-Object | Format-Table Name, Length, LastWriteTime |
        Out-File "$folderPath\C916contents.txt"
}

# List CPU and memory usage
function cpuMemoryUsage{
    $cpuLoad = (Get-CimInstance Win32_Processor).LoadPercentage
    $memLoad = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize - (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
    $memPercent = ($memLoad / (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize) * 100

    Write-Host "CPU Load: $($cpuLoad)%"
    Write-Host ("Memory Used: {0:N2}%" -f $memPercent)
}

# List different running processes. Sort ouput by virtual memory size and display in grid format
function runningProcesses{
    try{
        Get-Process | Sort-Object -Property VirtualMemorySize64 | Select-Object Name, Id, CPU, VirtualMemorySize64 | Format-Table -Autosize | Out-String
    }
    catch [System.OutOfMemoryException]{
        Write-Host "Error: Out of memory while listing processes"
        exit 1
    }
}

# Main script loop with function calls
$folderPath = "$PSScriptRoot"
$logFilepath = "$folderPath\DailyLog.txt"

do{
    menuDisplay
    $choice = Read-Host "Enter your choice (1-5)"
    switch ($choice){
        "1" {logFiles -folderPath $folderPath -logFilePath $logFilepath}
        "2" { folderContents -folderPath $folderPath}
        "3" {cpuMemoryUsage}
        "4" {runningProcesses}
        "5" {Write-Host "Exiting script"}
        default {Write-Host "Invalid selection. Please choose 1 to 5"}
    }
}
while ($choice -ne "5")
