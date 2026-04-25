# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation


# B1: Check for and recreate the Finance OU
function checkAndRecreateOU {
    param ()
    $ouPath = "OU=Finance,DC=consultingfirm,DC=com"
    $domainPath = "DC=consultingfirm,DC=com"

    try {
        # Check if the OU exists
        Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction Stop

        Write-Host "OU 'Finance' already exists. Deleting it now..."
        Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false
        Write-Host "OU 'Finance' deleted successfully."
    } catch {
        Write-Host "OU 'Finance' does not exist. Proceeding to create it."
    }

    try {
        New-ADOrganizationalUnit -Name "Finance" -Path $domainPath
        Write-Host "OU 'Finance' created successfully."
    } catch {
        Write-Host "Error creating OU: $($_.Exception.Message)"
    }
}

# B2: Import users from financePersonnel.csv
function importUsersToFinanceOU {
    param ()
    $ouPath = "OU=Finance,DC=consultingfirm,DC=com"
    try {
        $users = Import-Csv ".\Requirements2\financePersonnel.csv"
        foreach ($user in $users) {
            $displayName = "$($user.FirstName) $($user.LastName)"
            New-ADUser `
                -GivenName $user.FirstName `
                -Surname $user.LastName `
                -DisplayName $displayName `
                -PostalCode $user.PostalCode `
                -OfficePhone $user.OfficePhone `
                -MobilePhone $user.MobilePhone `
                -Name $displayName `
                -Path $ouPath `
                -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
                -Enabled $true
        }
        Write-Host "Users successfully imported into the Finance OU."
    } catch {
        Write-Host "Error importing users: $($_.Exception.Message)"
    }
}

# B3: Export AD user data from Finance OU
function exportADResults {
    param ()
    $ouPath = "OU=Finance,DC=consultingfirm,DC=com"
    try {
        Get-ADUser -Filter * -SearchBase $ouPath -Properties DisplayName,PostalCode,OfficePhone,MobilePhone |
            Out-File ".\Requirements2\AdResults.txt"
        Write-Host "AD results exported to AdResults.txt"
    } catch {
        Write-Host "Error exporting AD results: $($_.Exception.Message)"
    }
}