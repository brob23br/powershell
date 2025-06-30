# Name: Brandon Robinson | Student ID: 001260410

# Define SQL Server Instance name, database name, and CSV path

$sqlServerName = "SRV19-PRIMARY\SQLEXPRESS"
$db = "ClientDB"
$csvPath = "$PSScriptRoot\NewClientData.csv"

# Check if ClientDB exists, delete if it does, then create new DB

try{
    $dbCheck = Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "IF DB_ID('$db') IS NOT NULL SELECT 1 AS [Exists] ELSE SELECT 0 AS [Exists]"
    
    if ($dbCheck.Exists -eq 1){
        Write-Host "$db exists and will be deleted."
        Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "DROP DATABASE [$db]" -ErrorAction SilentlyContinue
        Write-Host "$db has been deleted."
        Start-Sleep -Seconds 3
    }
    else{
        Write-Host "$db does not exist"
    }   
    Invoke-Sqlcmd -ServerInstance $sqlServerName -Query "CREATE DATABASE [$db]" -ErrorAction SilentlyContinue
    Write-Host "$db has been created."
}
catch {
    Write-Host "Error managing database: $($_.Exception.Message)"
}

# Create table Client_A_Contact with column names from NewClientData.csv

try{
    $createTable = @"
    CREATE TABLE dbo.Client_A_Contacts(
        FirstName VARCHAR(50),
        LastName VARCHAR(50),
        City VARCHAR(50),
        County VARCHAR(50),
        ZIP VARCHAR(10),
        OfficePhone VARCHAR(20),
        MobilePhone VARCHAR(20)
    )
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $db -Query $createTable -ErrorAction SilentlyContinue
    Write-Host "Client_A_Contacts table has been created."
}
catch{
    Write-Host "Error creating table: $($_.Exception.Message)"
}

# Import data from NewClientData.csv into table

try{
    $data = Import-Csv $csvPath
    foreach ($row in $data){
        $insertQuery = @"
            INSERT INTO dbo.Client_A_Contacts (FirstName, LastName, City, County, ZIP, OfficePhone, MobilePhone)
            VALUES ('$($row.first_name)', '$($row.last_name)', '$($row.city)', '$($row.county)', '$($row.zip)', 
                        '$($row.officePhone)', '$($row.mobilePhone)')
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $db -Query $insertQuery
    }
    Write-Host "NewClientData.csv data has been imported into Client_A_Contacts table."
}
catch{
    Write-Host "Error importing data: $($_.Exception.Message)"
}

# Export query results to SqlResults.txt
try{
    Invoke-Sqlcmd -Database ClientDB -ServerInstance .\SQLEXPRESS -Query "SELECT * FROM dbo.Client_A_Contacts" > $PSScriptRoot\SqlResults.txt
    Write-Host "Results exported to SqlResults.txt"
}
catch{
    Write-Host "Error exporting results: $($_.Exception.Message)"
}
