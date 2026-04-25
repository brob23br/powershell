# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation

# Display the menu options to the user
function menuDisplay {
    Write-Host ""
    Write-Host "Choose an option:"
    Write-Host "1 - Find .log files and append to DailyLog.txt"
    Write-Host "2 - List folder contents and save to C916contents.txt"
    Write-Host "3 - Show CPU and memory usage"
    Write-Host "4 - Show running processes sorted by virtual memory"
    Write-Host "5 - Exit"
}

# List .log files in the folder and append to DailyLog.txt with timestamp
function logFiles {
    param (
        [string]$folderPath,
        [string]$logFilePath
    )
        $todaysDate = Get-Date
        Add-Content -Path $logFilePath -Value "`n$($todaysDate.ToString('yyyy-MM-dd HH:mm:ss'))"

        Get-ChildItem -Path $folderPath | Where-Object { $_.Name -match '\.log$' } | ForEach-Object {
            Add-Content -Path $logFilePath -Value $_.Name
        }
}

# List folder contents in ascending order and output to C916contents.txt
function folderContents {
    param (
        [string]$folderPath
        )

        Get-ChildItem -Path $folderPath | Sort-Object Name |
            Format-Table Name, Length, LastWriteTime | Out-File "$folderPath\C916contents.txt"
    }

# List current CPU and memory usage
function systemResources {

    $cpuLoad = (Get-WmiObject Win32_Processor).LoadPercentage
    $memLoad = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize - (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory
    $memPercent = ($memLoad / (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize) * 100
    
    Write-Host "CPU Load: $($cpuLoad)%"
    Write-Host ("Memory Used: {0:N2}%" -f $memPercent)
}

# List running processes sorted by virtual memory usage and display in grid view
function processList {
    try {
        Get-Process | Sort-Object VirtualMemorySize -Descending | Out-GridView
    } catch [System.OutOfMemoryException] {
        Write-Host "Error: Out of memory while listing processes." 
        exit 1
    }
}

# MAIN LOOP
$folderPath = "$PSScriptRoot\Requirements1"
$logFilePath = "$folderPath\DailyLog.txt"

do {
    menuDisplay
    $choice = Read-Host "Enter your choice (1-5)"
    switch ($choice) {
        "1" { logFiles -folderPath $folderPath -logFilePath $logFilePath }
        "2" { folderContents -folderPath $folderPath }
        "3" { systemResources }
        "4" { processList }
        "5" { Write-Host "Exiting script..." }
        default { Write-Host "Invalid selection. Please choose 1 to 5." }
    }
} while ($choice -ne "5")
