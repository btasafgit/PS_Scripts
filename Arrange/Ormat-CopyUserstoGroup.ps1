


function Migrate-UsersToGroup{
param(
[Parameter(Mandatory)]$SourceGroup,
[Parameter(Mandatory)]$DestinationGroup
)


Import-Module activedirectory
#get groups members
$fromMembers = Get-ADGroupMember $SourceGroup -Recursive
$toMembers = Get-ADGroupMember $DestinationGroup  -Recursive

# Copy all users from Source Group to Destination group
Add-ADGroupMember $toGroup -Members $fromMembers

}