$DCs = Get-AllDCs

foreach ($DC in $DCs) {
    Write-Host $DC.DNSHostName
    Test-ADAuthentication -User "" -Password "" -Server $DC.DNSHostName
}

Test-ADAuthen