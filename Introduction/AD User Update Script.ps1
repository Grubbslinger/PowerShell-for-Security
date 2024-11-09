Import-Module ActiveDirectory
#Path must be changed to correct CSV file. 
$WorkObjects = Import-Csv -Delimiter "," -Path C:\ADusers.csv



foreach($WorkObject in $WorkObjects)

{
#CSV column headers must have same name as .fields after WorkObject Variable
set-aduser -identity $WorkObject.sAMAccountName -EmailAddress $WorkObject.mail

}
