# Used my baseline here: https://thwack.solarwinds.com/message/300039#300039
# Modified by Thwack user: Chad.Every
#
# Since the certificate in Orion for SWIS is self-signed we'll need this to ignore it.
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#Passing in the NodeID and the length of time to unmanage the node
$NodeID="N:$($args[0])"
$UnmanageTime=$args[1]

#Variables
$now =[DateTime ]::UtcNow
$hostname = "10.199.21.33"
$username = "admin"
$SecurePassword = ConvertTo-SecureString -AsPlainText -Force -String "Password1"
#$SecurePassword = Read-Host -Prompt "Enter password" -AsSecureString
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $Securepassword

$url = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.Nodes/Unmanage"

#Examples with minutes, hours and days.
$json = "[`"$NodeID`",`"$($now.AddSeconds(1))`",`"$($now.AddMinutes($UnmanageTime))`",`"false`"]"
#$json = "[`"$NodeID`",`"$($now.AddSeconds(1))`",`"$($now.AddHours($UnmanageTime))`",`"false`"]"
#$json = "[`"$NodeID`",`"$($now.AddSeconds(1))`",`"$($now.AddDays($UnmanageTime))`",`"false`"]"

#Formated example
#$json = "[`"N:668`",`"11/18/2015 11:37:25`",`"11/20/2015 11:35:25`",`"false`"]"


Invoke-WebRequest -Uri $url -Credential $cred -Method Post -Body $json -ContentType application/json

exit 0