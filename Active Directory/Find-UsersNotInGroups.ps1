<#
        .SYNOPSIS
        Export a list of users that are members of a specific group/groups.

        .DESCRIPTION
        Export a list of users that are members of a specific group/groups.

        .PARAMETER GroupName
        Specifies the group name.

        .PARAMETER outPath
        Specifies the path to export the results.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        Exports a .csv file named UsersNotInGroups.csv

        .EXAMPLE
        PS> .\Find-UsersNotInGroups.ps1 -grpExpression sps -outPath C:\ABT
    #>
param(
    # Parameter help description
    [Parameter(Mandatory)]
    [string]
    $GroupName,
    # Parameter help description
    [Parameter(Mandatory)]
    [string]
    $outPath
)
Import-Module ActiveDirectory


$usrs = Get-ADUser -Filter * -Properties * | Where-Object {$_.employeeID -ne 0}
$out = @()
foreach($i in $usrs){
$groups = $i.MemberOf
$inGrp = 0
    foreach($grp in $groups){

        if($grp -like "*$GroupName*"){
            $inGrp = 1
            $out += New-Object -TypeName PSCustomObject -Property @{
            "UserName"    = $user.SamAccountName
            "Name" = $i.Name
            "inGrp" = $inGrp
            "SPSGroup" = $grp
            "Department" = $i.Department
            "DN" = $i.DistinguishedName
            "employeeID" = $i.employeeID

        } | Select-Object 'UserName', 'Name', 'inGrp', 'SPSGroup', 'Department', 'DN', 'employeeID'
            #write-host $i.Name" - is in SPS Group: "$grp
            break
        }
    }

    
    
}

$out | export-csv $outPath\UsersNotInGroups.csv -NoTypeInformation