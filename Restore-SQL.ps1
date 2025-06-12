# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation

$sqlServerName = "SRV19-PRIMARY\SQLEXPRESS"
$db = "ClientDB"
$csvPath = "$PSScriptRoot\Requirements2\NewClientData.csv"

# Check if ClientDB exists, delete if it does, then create new
try {
    $dbExists = Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "IF DB_ID('$db') IS NOT NULL SELECT 1 ELSE SELECT 0"
    if ($dbExists -eq 1) {
        Write-Host "Database '$db' exists. Deleting..."
        Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "DROP DATABASE $db"
        Write-Host "Database '$db' deleted."
    } 
    else {
        Write-Host "Database '$db' does not exist."
    }

    Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "CREATE DATABASE $db"
    Write-Host "Database '$db' created."
} 
catch {
    Write-Host "Error managing database: $($_.Exception.Message)"
}

# Create table Client_A_Contacts
try {
    $createTable = @"
CREATE TABLE dbo.Client_A_Contacts (
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Company NVARCHAR(100)
)
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $db -Query $createTable
    Write-Host "Table 'Client_A_Contacts' created."
} 
catch {
    Write-Host "Error creating table: $($_.Exception.Message)"
}

# Import data from NewClientData.csv
try {
    $data = Import-Csv $csvPath
    foreach ($row in $data) {
        $insertQuery = "INSERT INTO dbo.Client_A_Contacts (FirstName, LastName, Email, Phone, Company)
                        VALUES ('$($row.FirstName)', '$($row.LastName)', '$($row.Email)', '$($row.Phone)', '$($row.Company)')"
        Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $db -Query $insertQuery
    }
    Write-Host "CSV data imported into Client_A_Contacts."
} 
catch {
    Write-Host "Error importing data: $($_.Exception.Message)"
}

# Export results to SqlResults.txt
try {
    Invoke-Sqlcmd -Database $db -ServerInstance $sqlServerName -Query "SELECT * FROM dbo.Client_A_Contacts" > "$PSScriptRoot\SqlResults.txt"
    Write-Host "Results exported to SqlResults.txt."
} 
catch {
    Write-Host "Error exporting results: $($_.Exception.Message)"
}
Invoke-Sqlcmd -Database ClientDB –ServerInstance .\SQLEXPRESS -Query ‘SELECT * FROM dbo.Client_A_Contacts’ > .\SqlResults.txt
