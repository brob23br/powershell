# Name: Brandon Robinson | Student ID: 001260410 | Class: D411 Scripting and Automation

# Load Active Directory module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Active Directory module loaded."
} 
catch {
    Write-Host "Error: Active Directory module failed to load. Exiting..."
    exit 1
}

# Define paths
$ouPath = "OU=Finance,DC=consultingfirm,DC=com"
$domainPath = "DC=consultingfirm,DC=com"

# Check for OU, remove protection, delete if it exists, and create it
try {
    # Check if the Finance OU exists
    Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction Stop
    Write-Host "OU 'Finance' already exists. Removing protection and deleting..."

    # Remove accidental deletion protection
    Set-ADOrganizationalUnit -Identity $ouPath -ProtectedFromAccidentalDeletion $false

    # Delete the OU
    Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false
    Write-Host "OU 'Finance' deleted successfully."
} 
catch {
    Write-Host "OU 'Finance' does not exist. Proceeding to create it."
}

try {
    # Create the Finance OU
    New-ADOrganizationalUnit -Name "Finance" -Path $domainPath
    Write-Host "OU 'Finance' created successfully."
    
} 
catch {
    Write-Host "Error creating OU: $($_.Exception.Message)"
}

# Import users from financePersonnel.csv
try {
    $users = Import-Csv "$PSScriptRoot\Requirements2\financePersonnel.csv"
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
} 
catch {
    Write-Host "Error importing users: $($_.Exception.Message)"
}

# Export user data to AdResults.txt
try {
    Get-ADUser -Filter * -SearchBase $ouPath -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > "$PSScriptRoot\AdResults.txt"
    Write-Host "Exported user data to AdResults.txt"
} 
catch {
    Write-Host "Error exporting user data: $($_.Exception.Message)"
}
Get-ADUser -Filter * -SearchBase “ou=Finance,dc=consultingfirm,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > $PSScriptRoot\AdResults.txt
