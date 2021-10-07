#############################################################################################
#Name - GetGuestUserLastLogin
#date - 28/09/2018
#author - Samik Roy(samik.n.roy@gmail.com)
#purpose - To get the last log on details for the guest users in O365.
#Pre-requisites:
#1.AzureAd and Exchange Powershell modules to be imported.
#Install-Module -Name MSOnline
#2.Global Admin credential to be passed.
#3.Auditing for the O365 tennat should be enabled.
#############################################################################################

#Variables 
$startDate = "{0:yyyy-MM-dd}" -f (get-date).AddDays(-365)	#90 days prior date.
$endDate = "{0:yyyy-MM-dd}" -f (get-date)	#current date.
$externalUserExtention = "*#EXT#*"
#path for log file.
$filePath="<filepath>\logs.csv"

#Get Credentials
$credentials=Get-Credential
#Load Modules for exchange online
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession $session -DisableNameChecking -AllowClobber

#Log to text file.
function logtoText($filePath, $msg){$msg >> $filepath;}
#Log to text ends here.

#Get All External Users
Connect-MsolService -Credential $credentials
$allExternalUsers = Get-MsolUser -All  | Where-Object -FilterScript { $_.UserPrincipalName -Like $externalUserExtention }
#Get Unified Audit Log for all users.
ForEach($externalUser in $allExternalUsers)
{
#Get the last login date.
$lastLoginDate = Search-UnifiedAuditLog -UserIds  $externalUser.UserPrincipalName -StartDate $startDate -EndDate $endDate| Foreach-Object {$_.CreationDate = [DateTime]$_.CreationDate; $_} | Group-Object UserIds | Foreach-Object {$_.Group | Sort-Object CreationDate | Select-Object -Last 1} | Select CreationDate
#Log the details.

New-Object -TypeName PSCustomObject -Property @{
        "UserName"    = $externalUser.UserPrincipalName
        "Last Login Date"   = $lastLoginDate.CreationDate
    } | Select-Object 'UserName', 'FirstName', 'LastName', 'LicenseType' | Export-csv $filePath -Append -Encoding UTF8 -NoTypeInformation
}
#Get All External Users ends here