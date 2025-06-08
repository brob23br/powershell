# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation

# Define menuDisplay function to display menu 
function menuDisplay {

    # Menu options to display to user
    Write-Host ""
    Write-Host "Choose an option:"
    Write-Host "1 - Find .log files and add to dailyLog.txt"
    Write-Host "2 - List folder contents and save to C916contents.txt"
    Write-Host "3 - Show CPU and memory usage"
    Write-Host "4 - Show running processes sorted by memory"
    Write-Host "5 - Exit"
}

# B1: Define logFiles function to list files within the Requirements1 folder. Find .log files and append to dailyLog.txt with current date
function logFiles {
    # Define string parameters
    param (
        [string]$folderPath,
        [string]$logFilePath
    )
    
    # Define variable todaysDate to save today's date
    $todaysDate = Get-Date

    # Add header on new line of log file that formats todaysDate to string with yyyy-MM-dd HH:mm:ss formatting
    Add-Content -Path $logFilePath -Value "`n$($todaysDate.ToString('yyyy-MM-dd HH:mm:ss'))"

    # Find .log files in the folder and, for each object with extension matching .log in the folder, append their names to the log file
    Get-ChildItem -Path $folderPath | Where-Object { $_.Name -like "*.log" } | ForEach-Object {
        Add-Content -Path $logFilePath -Value $_.Name
    }
}

# B2: Define folderContents function to list files inside Requirements1 folder in tab format. Output to new file C916contents.txt
function folderContents {
    # Define string parameters
    param (
        [string]$folderPath,
        [string]$saveFilePath
    )

    # Define variable folderContents which will get folder contents from folderPath, sort by name, and format as a table
    $folderContents = Get-ChildItem -Path $folderPath | Sort-Object Name | Format-Table Name, Length, LastWriteTime

    # Save the output of folderContents to new path saveFilePath
    $folderContents | Out-File -FilePath $saveFilePath
}

# B3: Define function systemResources to list the current CPU and memory usage
function systemResources {
 
    # Define variable cpuLoad to save CPU load percentage
    $cpuLoad = (Get-WmiObject Win32_Processor).LoadPercentage

    # Define variable memLoad to save memory usage
    $memLoad = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize - (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory

    # Define variable memPercent to save calculation of percentage used
    $memPercent = ($memLoad / (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize) * 100

    # Display CPU and memory results
    Write-Host "CPU Load: $($cpuLoad)%"
    Write-Host ("Memory Used: {0:N2}%" -f $memPercent)
}

# B4: Define function runningProcesses that lists all the different running processes sorted by memory
function runningProcesses {

# D1: Apply exception handling for System.OutOfMemoryException with try-catch
    try {
    # Define variable processes to get running processes and sort by virtual memory size
    $processes = Get-Process | Sort-Object VirtualMemorySize -Descending

    # Display processes results in a grid view
    $processes | Out-GridView
    }
    # Exit condition if out of memory occurs
    catch [System.OutOfMemoryException] {
        Write-Host "Out of memory exception"
    exit 1
    }
}

# Main program which loops until exit condition is met
while ($true) {
    # Exception handling if error occurs with try-catch
    try {
        # Call menuDisplay function and get user selection
        menuDisplay
        # Save user selection of integer between 1 and 5
        $userSelect = [int](Read-Host "Please select choice (1-5)")

# B5: Exit the script if user selects 5
        if ($userSelect -eq 5) {
            Write-Host "Goodbye"
            exit 0
        }
        
        # Handle user selection and call functions using switch statement. If user doesn't select 1-5, they're prompted to try again
        switch ($userSelect) {
            1 { logFiles -folderPath "$PSScriptRoot\Requirements1" -logFilePath "$PSScriptRoot\Requirements1\DailyLog.txt" }
            2 { folderContents -folderPath "$PSScriptRoot\Requirements1" -saveFilePath "$PSScriptRoot\Requirements1\C916contents.txt"}
            3 { systemResources }
            4 { runningProcesses }
            default { Write-Host "Invalid selection. Please try again." }
        }
    } 
    # Exit condition if error occurs
    catch {
        Write-Host "Error occurred: $($_.Message)"
        exit 1
    }
}
