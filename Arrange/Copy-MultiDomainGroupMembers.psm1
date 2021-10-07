function Copy-MultiDomainGroupMembers(){
<#
.SYNOPSIS
    Copies group members from one group to another in a multidomain environment.
.DESCRIPTION
    In a multidomain environments a specific DC referal is needed.
    The following scenarios apply:
        - Universal group containing members/groups from the entire forest (Domain Trust and an Enterprise admin required)
        - Domain global groups from diferent domains
.PARAMETER SouceGroup
    A source group to copy from.
.PARAMETER DestinationGroup
    A destination group to copy to.
.INPUTS
    None.
.OUTPUTS
    None.
.EXAMPLE
    GroupA from DomainA (root domain) contains 3000 users and groups from 400 domains in the forest.
    You create a new group named GroupB in the same root domain, as a part of envirnment cleanup.
    Copy-MultiDomainGroupMembers -SouceGroup GroupA -DestinationGroup GroupB
    Go drink a cup of coffee :)
.NOTES
    Author: Asaf Dori
    Date: 06.05.2021
    Version: 1.0
#>

param(
    $SouceGroup,
    $DestinationGroup
)

$members = (Get-ADGroup $SouceGroup -Properties member).member
$DNs = @()

#Looping through domains to create a referal list
$domains = (Get-ADForest).Domains
foreach($d in $domains){
    $DNs += Get-ADDomain $d |select DistinguishedName,PDCEmulator,DNSRoot
}#End of FOREACH domain


foreach($m in $members){
   <#Internal temp Vars#>
   #uDom - Extracts the domain DN to find the correct server to work with
   $uDom = [system.String]::Join(",", ($m.Split(",") |Where-Object {$_ -Like "DC=*"}))
   #uServer - Gets server to query based on object DN
   $uServer = ($DNs |where {$_.DistinguishedName -eq $uDom}).PDCEmulator
   
   #Verifying object type and using the correct PS cmdlet
   if((Get-ADObject $m -ErrorAction SilentlyContinue -Server $uServer).ObjectClass -eq 'user')
    {
        Add-ADGroupMember $DestinationGroup -Members (Get-ADUser -Identity $m -Server $uServer)
    }#end of If user
   
   if((Get-ADObject $m -ErrorAction SilentlyContinue  -Server $uServer).ObjectClass -eq 'group')
    {
        Add-ADGroupMember $DestinationGroup -Members (Get-ADGroup -Identity $m -Server $uServer)
    } #end of IF computer
} #end of FOREACH members
}#End of Function