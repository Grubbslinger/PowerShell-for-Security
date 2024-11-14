#Populates Users in AD and Creates Apporiate Settings as Necessary for Labs
$Domain = "@sparklekitten.local"
Import-Csv -Delimiter "," -Path C:\ADusers.csv | ForEach-Object{
    $userSAM=$_.SamAccountName
    $upn = $userSAM + $domain
    $uname= $_.UserName
    New-ADUser -Name $uname -DisplayName $uname -GivenName $_.FirstName -SurName $_.LastName -Title $_.JobTitle -UserPrincipalName $upn -SamAccountName $userSAM -Path $_.OU -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force) -Enabled $true
}

$policyParams = @{
    Name = "Executive Password Policy"
    ComplexityEnabled = $false
    LockoutDuration = "00:30:00"
    LockoutObservationWindow = "00:30:00"
    LockoutThreshold = "0"
    MaxPasswordAge = "00:00:00"
    MinPasswordAge = "00:00:00"
    MinPasswordLength = "0"
    PasswordHistoryCount = "0"
    Precedence = "1"
    ReversibleEncryptionEnabled = $false
    ProtectedFromAccidentalDeletion = $true
}
New-ADFineGrainedPasswordPolicy @policyParams 
Add-ADFineGrainedPasswordPolicySubject -Identity "Executive Password Policy" -Subjects Snacks
