# Destroy all VMs and redeploy Citrix Apps VMs

param(
    $ResetAllPools = $true,
    $debug = 0
)


$accIdPools = Get-AcctIdentityPool
$accIdPools.IdentityPoolName, $accIdPools.StartCount
#reset VM startCount
foreach($i in $accIdPools)
{
    try{Set-AcctIdentityPool -IdentityPoolName $i.IdentityPoolName -StartCount 1}
    catch{$Error[0]}
}


Set-AcctIdentityPool -IdentityPoolName $accIdPools -StartCount 1