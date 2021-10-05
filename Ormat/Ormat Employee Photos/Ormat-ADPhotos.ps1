Set-ExecutionPolicy Unrestricted -Force -Confirm:$false
Import-Module .\Resize-Image.psm1

<# Variables #>
$rPath = "C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\PS\Ormat Scripts\Projects\Ormat Employee Photos\"
$srcPath = $rPath + "Source\"
$sPath = $rPath + "Small\"
$mPath = $rPath + "Med\"
$lPath = $rPath + "Large\"

<# Connect to AAD-Exchange Online#>
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxyMethod=RPS -Credential (Get-Credential) -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

$pics = get-childitem $srcPath

<# Convert pic - SRC to Large#>
Resize-Image -ImagePath $pics[0].FullName -Percentage 50
<# Convert pic - SRC to Medium#>
Resize-Image -InputFile $pics[0].FullName -OutputFile ${lPath}"-25%.jpg" -Scale 25
<# Convert pic - SRC to Small#>
Resize-Image -InputFile $pics[0].FullName -OutputFile ${lPath}"-15%.jpg" -Scale 15


