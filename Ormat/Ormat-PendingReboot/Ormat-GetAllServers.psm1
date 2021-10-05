
<# Discover Forest and domains and returns a list of all #>
# Add Sort by Domain
function Ormat-GetAllServers {
    <#param(
        [boolean]$SortDomain = $false,
        [boolean]$SortName = $true
    )
if($SortDomain -eq $true){
    $SortName = $false
    $sortBy = 
}
#>
$sortBy = "DNSHostName"

$Servers = @()
$forest = Get-ADForest
$domains = $forest.Domains

foreach($domain in $domains){
    $Servers += Get-ADComputer -Filter * -Server (Get-ADDomainController -DomainName $domain -Discover) -Properties * `
    |Where-Object {$_.OperatingSystem -like "Windows Server*"} |Sort-Object -Property $sortBy

}
return $Servers
}


function Ormat-GetAllUsers {
    <#param(
        [boolean]$SortDomain = $false,
        [boolean]$SortName = $true
    )
if($SortDomain -eq $true){
    $SortName = $false
    $sortBy = 
}
#>
$sortBy = "Name"

$Users = @()
$forest = Get-ADForest
$domains = $forest.Domains

foreach($domain in $domains){
    $Users += Get-ADUser -Filter * -Server (Get-ADDomainController -DomainName $domain -Discover) -Properties * `
    |Sort-Object -Property $sortBy

}
    return $Users
}