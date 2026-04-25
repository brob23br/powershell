# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation

# B1: Check for and recreate ClientDB
function recreateSQLDatabase {
    $server = ".\SQLEXPRESS"
    try {
        $dbExists = Invoke-Sqlcmd -ServerInstance $server -Query "IF DB_ID('ClientDB') IS NOT NULL SELECT 1 ELSE SELECT 0"
        if ($dbExists -eq 1) {
            Write-Host "Database 'ClientDB' exists. Deleting..."
            Invoke-Sqlcmd -ServerInstance $server -Query "DROP DATABASE ClientDB"
            Write-Host "Database 'ClientDB' deleted."
        } else {
            Write-Host "Database 'ClientDB' does not exist."
        }

        Write-Host "Creating database 'ClientDB'..."
        Invoke-Sqlcmd -ServerInstance $server -Query "CREATE DATABASE ClientDB"
        Write-Host "Database 'ClientDB' created."
    } catch {
        Write-Host "Error managing database: $($_.Exception.Message)"
    }
}

# B2: Create new table in ClientDB
function createSQLTable {
    $server = ".\SQLEXPRESS"
    $createTableQuery = @"
CREATE TABLE dbo.Client_A_Contacts (
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Company NVARCHAR(100)
)
"@
    try {
        Invoke-Sqlcmd -ServerInstance $server -Database "ClientDB" -Query $createTableQuery
        Write-Host "Table 'Client_A_Contacts' created."
    } catch {
        Write-Host "Error creating table: $($_.Exception.Message)"
    }
}

# B3: Import data from CSV
function importCSVToTable {
    $server = ".\SQLEXPRESS"
    try {
        $data = Import-Csv ".\Requirements2\NewClientData.csv"
        foreach ($row in $data) {
            $insertQuery = @"
INSERT INTO dbo.Client_A_Contacts (FirstName, LastName, Email, Phone, Company)
VALUES ('$($row.FirstName)', '$($row.LastName)', '$($row.Email)', '$($row.Phone)', '$($row.Company)')
"@
            Invoke-Sqlcmd -ServerInstance $server -Database "ClientDB" -Query $insertQuery
        }
        Write-Host "Data successfully inserted into Client_A_Contacts."
    } catch {
        Write-Host "Error importing CSV data: $($_.Exception.Message)"
    }
}

# B4: Export SQL data to file
function exportSQLResults {
    $server = ".\SQLEXPRESS"
    try {
        Invoke-Sqlcmd -Database "ClientDB" -ServerInstance $server -Query "SELECT * FROM dbo.Client_A_Contacts" |
            Out-File ".\Requirements2\SqlResults.txt"
        Write-Host "SQL results exported to SqlResults.txt"
    } catch {
        Write-Host "Error exporting SQL results: $($_.Exception.Message)"
    }
}