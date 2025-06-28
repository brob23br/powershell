# Name: Brandon Robinson | Student ID: 001260410

# Define OU path and domain path
$financeOUPath = "OU=Finance,DC=consultingfirm,DC=com"
$domainPath = "DC=consultingfirm,DC=com"

# Check for Finance OU, remove delete protection and delete if exists, and create it

try{
    Get-ADOrganizationalUnit -Identity $financeOUPath -ErrorAction Stop
    Write-Host "Finance OU already exists. Removing deletion protection and deleting."

    Set-ADOrganizationalUnit -Identity $financeOUPath -ProtectedFromAccidentalDeletion $false

    Remove-ADAuthenticationPolicy -Identity $financeOUPath -Recursive -Confirm:$false
    Write-Host "Finance OU deleted successfully"
}
catch{
    Write-Host "Finance OU does not exist. Creating OU now."
}
# Create Finance OU
try{
    New-ADOrganizationalUnit -Name "Finance" -Path $domainPath
    Write-Host "Finance OU created successfully"

}
catch{
    Write-Host "Error creating OU: $($_.Exception.Message)."
}

# Import the financePersonnel.csv into AD Domain and directly into the Finance OU. 
# Include properties First Name, Last Name, Display Name(First Name+Last Name including space, Postal Code, Office Phone, Mobile Phone)

try{
    $users = Import-Csv "$PSScriptRoot\financePersonnel.csv"
    foreach ($user in $users){
        $displayName = "$($user.First_Name) $($user.Last_Name)"
        New-ADUser `
            -GivenName $user.First_Name `
            -Surname $user.Last_Name `
            -DisplayName $displayName `
            -PostalCode $user.PostalCode `
            -OfficePhone $user.OfficePhone `
            -MobilePhone $user.MobilePhone `
            -Name $displayName `
            -Path $financeOUPath `
            -AccountPassword (ConvertTo-SecureString "Pa$$w0rd" -AsPlainText -Force) `
            -Enabled $true
    }
    Write-Host "Users successfully imported into Finance OU from financePersonnel.csv"
}   
Catch{
    Write-Host "Error importing users: $($_.Exception.Message)"
}

try{
    Get-ADUser -Filter * -SearchBase “ou=Finance,dc=consultingfirm,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > $PSScriptRoot\AdResults.txt
    Write-Host "AdResults.txt file has been generated successfully."
}
catch{
    Write-Host "Error generating AdResults.txt: $($_.Exception.Message)"
}
