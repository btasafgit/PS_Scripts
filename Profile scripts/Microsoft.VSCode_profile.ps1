<# Aliases #>

Function Start-DirSync(){
    Invoke-Command -ComputerName Ormat-DirSync -credential $credOnPrem -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta} 
}
New-Alias -Name DirSync -Value Start-DirSync


<# Short directory Path#>
function prompt {
  $host.ui.rawui.WindowTitle = "PS $pwd"
  $p = 'PS ' + ($pwd -split '\\')[0]+' '+$(($pwd -split '\\')[-1] -join '\') + '> '
  return $p
}
$Host.UI.RawUI.WindowTitle =  $PWD.Path

# Function to Get Custom Directory path
Function Get-CustomDirectory
{
    [CmdletBinding()]
    [Alias("CDir")]
    [OutputType([String])]
    Param
    (
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Path = $PWD.Path
    )
    
    Begin
    {
        #Custom directories as a HashTable
        $CustomDirectories = @{

            $env:TEMP                                   ='Temp'
            $env:APPDATA                                ='AppData'
        } 
    }
    Process
    {
        Foreach($Item in $Path)
        {
            $Match = ($CustomDirectories.GetEnumerator().name | ?{$Item -eq "$_" -or $Item -like "$_*"} |`
            select @{n='Directory';e={$_}},@{n='Length';e={$_.length}} |sort Length -Descending |select -First 1).directory
            If($Match)
            {
                [String]($Item -replace [regex]::Escape($Match),$CustomDirectories[$Match])            
            }
            ElseIf($pwd.Path -ne $Item)
            {
                $Item
            }
            Else
            {
                $pwd.Path
            }
        }
    }
    End
    {
    }
}

# Custom Powershell Host Prompt()
Function Prompt
{
    Write-Host "I " -NoNewline; Write-Host "$([char]9829) " -ForegroundColor Red -NoNewline; Write-Host "PS " -NoNewline
    Write-Host $(Get-CustomDirectory) -ForegroundColor Green  -NoNewline        
    Write-Host " >_" -NoNewline -ForegroundColor Yellow
    return " "
}


#Connect to vCenter
# How to ignore certificate
#https://be-virtual.net/powercli-10-0-0-error-invalid-server-certificate/
Import-Module activedirectory,MSOnline,VMware.PowerCLI |out-null
<#Module install and import #>

if(-not( get-module ExchangeOnlineManagement))
{
    Install-Module ExchangeOnlineManagement -Confirm:$false -Force -ErrorAction SilentlyContinue
    import-module ExchangeOnlineManagement -ErrorAction SilentlyContinue |out-null
}
else { write-host "MSOnline Module is imported"}

if(-not( get-module VMware.PowerCLI))
{
    Install-Module -Name VMware.PowerCLI -Force -RequiredVersion (Find-Module -Name VMware.PowerCLI).Version -ErrorAction SilentlyContinue
    import-module VMware.PowerCLI -ErrorAction SilentlyContinue |out-null
    Set-PowerCLIConfiguration -Scope User -ParticipateInCeip:$false -InvalidCertificateAction Ignore -Confirm:$false -DisplayDeprecationWarnings:$false |out-null
}
else { write-host "VMware.PowerCLI Module is imported"}


if(-not( get-module MSOnline))
{
    Install-Module MSOnline -Confirm:$false -Force -ErrorAction SilentlyContinue
    import-module MSOnline -ErrorAction SilentlyContinue |out-null
}
else { write-host "MSOnline Module is imported"}



if(-not( get-module activedirectory))
{
    Install-WindowsFeature RSAT-AD-PowerShell -Confirm:$false -Force -ErrorAction SilentlyContinue
    import-module activedirectory -ErrorAction SilentlyContinue |out-null
}
else { write-host "Active Directory Module is imported"}


if(-not( get-module azureadpreview))
{
    Install-Module AzureADPreview -Scope CurrentUser -Confirm:$false -Force -ErrorAction SilentlyContinue
    import-module AzureADPreview -ErrorAction SilentlyContinue |out-null
}
else { write-host "AzureADPreview Module is imported"}


if(-not( get-module MicrosoftTeams))
{
    Install-Module MicrosoftTeams -Scope CurrentUser -Confirm:$false -Force -ErrorAction SilentlyContinue
    import-module MicrosoftTeams -ErrorAction SilentlyContinue |out-null
}
else { write-host "MicrosoftTeams Module is imported"}



########vmware Module installation
#Save-Module -Name VMware.PowerCLI -Path "C:\Users\Adori\Documents\WindowsPowerShell\Modules" -RequiredVersion 6.5.4.7155375
#Install-Module -Name VMware.PowerCLI -RequiredVersion 11.4.0.14413515

###################



$greeting = "
      ________________.  ___     .______
     /                | /   \    |   _  \
    |   (-----|  |----`/  ^  \   |  |_)  |
     \   \    |  |    /  /_\  \  |      /
.-----)   |   |  |   /  _____  \ |  |\  \-------.
|________/    |__|  /__/     \__\| _| `.________|
 ____    __    ____  ___     .______    ________.
 \   \  /  \  /   / /   \    |   _  \  /        |
  \   \/    \/   / /  ^  \   |  |_)  ||   (-----`
   \            / /  /_\  \  |      /  \   \
    \    /\    / /  _____  \ |  |\  \---)   |
     \__/  \__/ /__/     \__\|__| `._______/

Please Enter your OnPrem password
"

$credOnPrem = Get-Credential -UserName asafpm@ormat.com -m $greeting
$ilVC = "ormat-vc.ormat.com"
$usVC = "us-vcenter.us.ormat.com"
$exOnPrem = "http://ormat-mbx16.ormat.com/PowerShell/"

if($credOnPrem -ne $null) {
	<# Connect to IL vCenter#>
	Connect-VIServer -Server $ilVC -Credential $credOnPrem |out-null
    Write-host "Connected to IL vCenter"
    sleep 1
	Connect-VIServer -Server $usVC -Credential $credOnPrem |out-null
    Write-host "Connected to US vCenter"
    sleep 1
    <# Connect to On-Prem Exchange#>
    $OPExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exOnPrem -Credential $credOnPrem -Authentication Kerberos  -AllowRedirection -WarningAction SilentlyContinue 
	Import-PSSession $OPExSession -AllowClobber -DisableNameChecking|out-null
	Write-host "Connected to Exchange 2016 On-Prem"
}
else{
	Write-host "Domain Cred is NULL"
}


$greetingCloud = "
          .-~~~-.
  .- ~ ~-(       )_ _
 /                     ~ -.
|                           \
 \                         .'
   ~- . _____________ . -~

"
$credO365 = Get-Credential -UserName adori@ormat.com -m $greetingCloud

$SPOAdminSite = "https://ormat-admin.sharepoint.com"
$O365AdminSite = "https://outlook.office365.com/powershell-liveid/"

if($credO365 -ne $null) {
	<# Connect to O365 Service#>
	Connect-MsolService -Credential $credO365 |out-null
    Write-host "Connected to MS Online Services"
	<# Connect to Exchange Online management#>
	Connect-SPOService $SPOAdminSite -Credential $credO365 |out-null
	Write-host "Connected to Sharepoint Online"
	<# Connect to Exchange Online management#>
	Connect-ExchangeOnline -Credential $credO365
	Write-host "Connected to Exchange Online"
    Connect-AzureAD -Credential $credO365
    Write-host "Connected to Azure Ad"
    Connect-MicrosoftTeams -Credential $credO365
    Write-host "Connected to Microsoft Teams"
	sleep 1
	Import-PSSession $O365ExOSession -AllowClobber -DisableNameChecking|out-null
}
else{
	Write-host "Cloud Cred is NULL"
}
#


# SIG # Begin signature block
# MIIQ9gYJKoZIhvcNAQcCoIIQ5zCCEOMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUextvl7gTQJCOe5P6ztcB0FO1
# FH6ggg46MIIGvDCCBKSgAwIBAgITVQAAAAI1afLFjg4zKgAAAAAAAjANBgkqhkiG
# 9w0BAQsFADBBMQswCQYDVQQGEwJJTDEOMAwGA1UEBxMFWWF2bmUxDjAMBgNVBAoT
# BU9ybWF0MRIwEAYDVQQDEwlPcm1hdCBSQ0EwHhcNMTgwMzExMDk0ODQ5WhcNMjkw
# MzExMDk1ODQ5WjBtMQswCQYDVQQGEwJJTDETMBEGCgmSJomT8ixkARkWA2NvbTEV
# MBMGCgmSJomT8ixkARkWBU9STUFUMQ4wDAYDVQQHEwVZYXZuZTEOMAwGA1UEChMF
# T3JtYXQxEjAQBgNVBAMTCU9ybWF0IFNDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAIZq5qD1PvcYGYL4eM3inScedsrUy96U7QoJ4826ZeBxQTYPCi+V
# p67EZtJ7/vXFZbq/omfww3cs80m0dHQscAEeY4lYhr4qdXWmloDCxvn6PBXbnzF2
# Ioqao6YwMkrnlU0J8D4y6lXJ+swG/pWA67Wzgh8GokXndSN+I6O56UGSVLoP0KLr
# nL27YPik/tWM2hvp/yDDqXz2qHJCIzK7tXpVRD9OfFEXtmLAgTAJK0wkDWxcpkU+
# ycyhgCbHQr7EfxHJD3mYR+bvsTCrR0W8f8r0W6u/bn1722A8D+bgbZMJQ0C6L6uP
# oxJfwAk5iVYCMQOnZDKtaZqdh3p3iHWg+Lt381gpKDDOFaev1oL9zJNt1W2dTy/G
# KJyF3gPLmQlxFQLp9eJwhqiZfEXF+MJkHYnUEVOAslK8zwbbpteRSHmXOL/pqJki
# JM9Z29t7v2jRr/+cIznYQDrWBo/i/SOFSi+BmbSfxWjYOzoNUk7LfgEyvbsNS2j0
# kfGXUA93SOaUVFNhXiAEvEiNk7WEWLMh00rvg990mpVsEgVE0TbrrunQKYKghMFu
# IC3ISlSu5/d2pxCphrGx+/XDscSFhAJQWuY7O3gpvsHjYz8ZT5wOKIj6sciarDQn
# ZVxeGcJNVaLKXgq+rBpaFQB//WA9+T+9OvzLmmue7bUpfHnxlTHWpd0NAgMBAAGj
# ggF/MIIBezAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU9NBqqPWnZrg6pg0+
# A/5NLhky7fIwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGG
# MA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU3054m4jd/znAx75Nk773aM8D
# 1lYwYQYDVR0fBFowWDBWoFSgUoYnaHR0cDovL2NkcDAxLm9ybWF0LmNvbS9jZHAv
# b3JtYXRyY2EuY3JshidodHRwOi8vY2RwMDIub3JtYXQuY29tL2NkcC9vcm1hdHJj
# YS5jcmwwgYoGCCsGAQUFBwEBBH4wfDA8BggrBgEFBQcwAoYwaHR0cDovL2NkcDAx
# Lm9ybWF0LmNvbS9jZHAvT1JNQVRSQ0FfT3JtYXRSQ0EuY3J0MDwGCCsGAQUFBzAC
# hjBodHRwOi8vY2RwMDIub3JtYXQuY29tL2NkcC9PUk1BVFJDQV9Pcm1hdFJDQS5j
# cnQwDQYJKoZIhvcNAQELBQADggIBAEPIFRPUtQ6BZZvakRXt0zncLr8lTw5jopYP
# /lbFm8uupk+yszEG3otSNecdOm13J5GNsRWDaIUvLDfcoDHPMmOC5PR9RAQyesCE
# ram/6Ff/sFqIPqoTf2nMbx2iPvLD1lR81LOALxGsFxBx3m2HnoR2QAfsjwQ2gc5C
# 25OoDIyHeaD+9SQw0oB60gzAxILGAJ7FHOJzXGU038+OVSeNXSN4M++yXfMcE6/8
# YCDpKVIxJbfX2vxlj0XdYiXGpo/k1hSqSstlmkFubi60BaSuRVPorDSEGGTIQF6b
# FUjpIJjxWULo0glW2pTY8Ko0BEek2Uvt9M+EA2+mYX8QHLonCqYhNBINT57my0K5
# UVZtmBpMMbU9fwx6ca1p8h0UXzAWC8Gv7obZMu7iObMLmOWBpbNjLENKNTHuKYQa
# nolQWfqxuHkNzX2LK3AZd+k3H+MXSOhFiAuvTLs34AiaXzoW7fxphj3seMEnUpwF
# U/EYEABG/431rOJNgs0l1+4u/LUhuLzpKYgNlZWYc76hisgVUerx/3IjaLZx0Uxl
# ByHdBfQanAdgwSXOdF89Ef61Ga/LY5OJevsrgY5Dh+zSF1t8pGfYgItzzisYodcm
# afELvSZbIralwCJQbfD3oRT7I8Oxq0TndpxUGZe/qwu4mD2UWfd92Kjjy2beQB/Q
# cRp+guQMMIIHdjCCBV6gAwIBAgITUQAAOzHXU5gmwg1RBwAAAAA7MTANBgkqhkiG
# 9w0BAQsFADBtMQswCQYDVQQGEwJJTDETMBEGCgmSJomT8ixkARkWA2NvbTEVMBMG
# CgmSJomT8ixkARkWBU9STUFUMQ4wDAYDVQQHEwVZYXZuZTEOMAwGA1UEChMFT3Jt
# YXQxEjAQBgNVBAMTCU9ybWF0IFNDQTAeFw0yMTAzMDQwODE0MDBaFw0yNDAzMDQw
# ODI0MDBaMEAxCzAJBgNVBAYTAklMMQ4wDAYDVQQKEwVPcm1hdDELMAkGA1UECxMC
# SVQxFDASBgNVBAMTC09ybWF0SVRDb2RlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEA6VLHSGMewjjTcrfeEVsUKfPlLVufuBtrm/OHCDC0FZBqVYSCj8ga
# Nw1PbUBM4cgo71I/CizMyK6MaZztcd8mxwYd6KHYGgyf67R+SzPzxKTZVto5dlTS
# fA4nV/pRBi9kZbxwhQ7iIquTgsReeCN0hjwY8Y6uABvx4YxFDcDKq1c/kPoabUQS
# GZozIDw9LHdNDl0iALQbW7vryf1qTa2fn5+SaPlFW5R2jXn2Zr4I+YvEnHGHGl4Y
# j5qRcnK4NnwbE+Z+wvaU7JIrULXBo/ZsCKYx9q84l1PjGYlIrBE9iRj3ewIaHCDM
# 11I0I2aqfumSeGdhvNpY7lOj0Mx6wKs0lQIDAQABo4IDOjCCAzYwPAYJKwYBBAGC
# NxUHBC8wLQYlKwYBBAGCNxUIgoqtVIf/iDDJnxyE859ihsC7cXOF+Zx/g7OrAQIB
# ZAIBAjATBgNVHSUEDDAKBggrBgEFBQcDAzALBgNVHQ8EBAMCB4AwGwYJKwYBBAGC
# NxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUJKkgnSN2qnAa1k4hCZgY2n16
# fBgwJgYDVR0RBB8wHaAbBgorBgEEAYI3FAIDoA0MC09ybWF0SVRDb2RlMB8GA1Ud
# IwQYMBaAFPTQaqj1p2a4OqYNPgP+TS4ZMu3yMIIBIgYDVR0fBIIBGTCCARUwggER
# oIIBDaCCAQmGJ2h0dHA6Ly9jZHAwMS5vcm1hdC5jb20vY2RwL29ybWF0c2NhLmNy
# bIYnaHR0cDovL2NkcDAyLm9ybWF0LmNvbS9jZHAvb3JtYXRzY2EuY3JshoG0bGRh
# cDovLy9DTj1Pcm1hdCUyMFNDQSxDTj1Pcm1hdC1TdWJDQSxDTj1DRFAsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1PUk1BVCxEQz1jb20/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNl
# P29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIBJwYIKwYBBQUHAQEE
# ggEZMIIBFTAzBggrBgEFBQcwAoYnaHR0cDovL2NkcDAxLm9ybWF0LmNvbS9jZHAv
# b3JtYXRzY2EuY3J0MDMGCCsGAQUFBzAChidodHRwOi8vY2RwMDIub3JtYXQuY29t
# L2NkcC9vcm1hdHNjYS5jcnQwgagGCCsGAQUFBzAChoGbbGRhcDovLy9DTj1Pcm1h
# dCUyMFNDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vy
# dmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1PUk1BVCxEQz1jb20/Y0FDZXJ0aWZp
# Y2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwDQYJ
# KoZIhvcNAQELBQADggIBACPo6T/z5dm96RehHAZ84lZl4wtKUr23htzRQpzHsdXo
# cBl7cfmjZ/j/dDOfdDs9wDLu2kHvBG4ljD2KE9kCTGAUiGVJQDqr5ETLm4Peltpq
# I03MDBg0AOx4ZEqeVlrrHl+z2nDMxaCn+LmBiGHR25180GhJSiL6D0/ZniRR2qZE
# uvP3lV2HzH4NgwBO1K6stkBuy4IglsqDuMF8lup7OEtrGir5wKd/hDN0KNua6xpK
# PscfyuXKYf/49TI9qz6ZTPn80eAeAg4SIpqbFmrf5Vt0OLF99KNF5R5AjxSi3k7I
# zgKOgBfW0B0vgr1f05toC/IJTp2tqAv9mtXAf3CMEomGbSr4MGJuDzkwWdQdDo6h
# Y1EA13+T02sGUtVQz23a+1NhWZuCmaU7Uc3QIE6xlSCuKaWyd4bvP7OZAm1rjAQ3
# pXEnXdNp2Tw5a6pUcwcakFRd5UMIaNBEwwsbdpiYJcXJk+gWsLmf9ekOADXQlC/g
# Qz2aHRyrL2npY4zta5QkFD730vYnb+0I7lLZmeqvy8J31ykgAs+CmFQmZAP/RtHh
# 34J/76KQGO03r+otu0CyTgYYlsb+x9ROEoEWhKxsx5HAsF2TOJ5ixbUmFaPxQTBh
# vetrpmvnGqUbl0/M4tajO8qFBq9rciH9mqQe/87hy0mxIhgv9NZd0vRgl3rIq3UK
# MYICJjCCAiICAQEwgYQwbTELMAkGA1UEBhMCSUwxEzARBgoJkiaJk/IsZAEZFgNj
# b20xFTATBgoJkiaJk/IsZAEZFgVPUk1BVDEOMAwGA1UEBxMFWWF2bmUxDjAMBgNV
# BAoTBU9ybWF0MRIwEAYDVQQDEwlPcm1hdCBTQ0ECE1EAADsx11OYJsINUQcAAAAA
# OzEwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFJqiErs03jN3nduGzrZIqXqKJJJJMA0GCSqGSIb3
# DQEBAQUABIIBAKGvyUljl1Y2jJKHqbob0phmAWqpt5E6d8900YKXmIyvJ8vP/91z
# Tq2R9uuxSL4GZmTHI6KOxAcH216ftUfHeU3ZveFZ6IaYZ7Rqq/i7NSj/10bRogX5
# zqdLoLAceyENWpA6GYdF77wiJFgpcGy3jrcnpeEhq1QhVvXODudk6s2JNWVV7nSc
# LqQm4KknzLS2M7tfBLWnfQEA4DbV1GAOIvtE1ZQTvBmlv7kaOj9/kMXuyDz0eJjw
# vuZRE6cxtZ6pIGwinl1kf1DUYrnL8Ok4mcKjQ8s9Mfdp+USRadkafvVcOW82sw9h
# DcWiPwHrvxUcJFT9YfJJUJtZwMDB5s3rga4=
# SIG # End signature block
