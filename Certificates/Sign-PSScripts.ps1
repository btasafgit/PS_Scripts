<#
Required: Code signing certificate from CA

Based on a code signing certificate this script will sign a powershell script
#>


param(
    # Parameter help description
    [Parameter()]
    [string]
    $ScriptPath,
    # Parameter help description
    [Parameter(AttributeValues)]
    [string]
    $SignThumbprint
)


Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser -Confirm:$false

$cert=(dir cert:currentuser\my\ -CodeSigningCert) |where {$_.Thumbprint -eq $SignThumbprint}
Set-AuthenticodeSignature $ScriptPath -Certificate $cert


Get-AuthenticodeSignature $scriptPath