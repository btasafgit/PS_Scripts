$cred = Get-Credential
$UserToAdd = "" #Type the email address of the user to allow (i.e. "user@ormat.com")
Invoke-Command -ComputerName Ormat-mbx16.ormat.com -Credential $cred -ArgumentList $UserToAdd -ScriptBlock{

    Get-DistributionGroup oneormat |Set-DistributionGroup -AcceptMessagesOnlyFrom @{Add=$args[0]}
    Get-DistributionGroup OrmatInternalUsers |Set-DistributionGroup -AcceptMessagesOnlyFrom @{Add=$args[0]}
    Get-DistributionGroup abroad |Set-DistributionGroup -AcceptMessagesOnlyFrom @{Add=$args[0]}
    Get-DistributionGroup ormatinternalemp |Set-DistributionGroup -AcceptMessagesOnlyFrom @{Add=$args[0]}
}

Invoke-Command -ComputerName Ormat-DirSync -Credential $cred -ScriptBlock {
    Start-ADSyncSyncCycle -PolicyType Delta
}