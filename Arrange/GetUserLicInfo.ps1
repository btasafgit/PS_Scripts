<#
.SYNOPSIS
  Exporting Office 365 License Info Users.
  Current Output for:
    - BI License information

.DESCRIPTION
  This script is used for exporting users information regarding BI License.
    - Export CSV to a cetrelized location

.PARAMETER Path
    Save path for saving Output result

.PARAMETER Verbose
    Script debugging only

.INPUTS
  Path
  Verbose

.OUTPUTS
  CSV file with results to Path location

.NOTES
  Version:        1.0
  Author:         Asaf Dori
  Creation Date:  11.10.2018
  Purpose/Change: Initial script development

.EXAMPLE
  .\GetUserLicInfo.ps1 -Path "\\ormat-dc7\Ormat-Data\BI\Source_Files\PBI_Audit\PBI_Audit_User_Details"
#>

param(
    [string]$Path,
    [boolean]$Verbose = $false
)

#$logPath = "c:\abt"
if ($Verbose -eq $true) {
    $Path = "C:\abt\O365"
    Start-Transcript -Path "$logPath\UsersInfo.log" -Append -Confirm:$false -Force -IncludeInvocationHeader -Verbose
}

$outFile = "$Path\LicResults.csv"

###Connect To MsolService###
$pass = cat C:\scripts\365securestring.txt | convertto-securestring                                                            
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "admin@ormat.onmicrosoft.com", $pass
$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $mycred -Authentication Basic -AllowRedirection 
Import-PSSession $O365Session -AllowClobber       
connect-msolservice -credential $mycred

<#
$adminUser = "adori@ormat.com"
$adminPass = ConvertTo-SecureString 'B@nupi1204!' -AsPlainText -Force
$adminCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $adminUser, $adminPass
$O365Cred = Get-Credential $adminCred
Connect-MsolService -Verbose -Credential $O365Cred
#>

$users = Get-MsolUser -All | Where-Object { ($_.licenses).AccountSkuId -match "ormat:POWER_BI_*" }

foreach ($user in $users) {

    if (($user.licenses).AccountSkuId -match 'ormat:POWER_BI_PRO') {
        $licType = "Pro"
    }
    else {
        $licType = "Std"
    }

    New-Object -TypeName PSCustomObject -Property @{
        "UserName"    = $user.UserPrincipalName
        "FirstName"   = $user.FirstName
        "LastName"    = $user.LastName
        "LicenseType" = $licType
    } | Select-Object 'UserName', 'FirstName', 'LastName', 'LicenseType' | Export-csv $outFile -Append -Encoding Unicode -NoTypeInformation
    #End of New Object 

    clear-variable licType -force
} #End of FOREACH


#}

Start-Sleep 3

if ($Verbose -eq $true) { Stop-Transcript }

