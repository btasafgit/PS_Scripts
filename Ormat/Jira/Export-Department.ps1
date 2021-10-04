<#
Written by: Asaf Dori

This script used by Jira for creating departments in IL only for New employee form

#>

<# Variables #>
$outFileUniqDept = "C:\scripts\Export-Dept.csv"
$outFileAll = "C:\scripts\Export-ADInfoAll.csv"

Import-Module ActiveDirectory
<# User list #>
$usr = Get-ADUser -Filter * -Properties *
$out = @()
$il = @()

foreach($i in $usr){
$out += New-Object -TypeName PSCustomObject -Property @{
    "Name" = $i.Name
    "GivenName" = $i.GivenName
    "Surname" = $i.Surname
    "Department" = $i.Department
    "Division" = $i.Division
    "EmployeeID" = $i.EmployeeID
    "Enabled" = $i.Enabled
    "State" = $i.State
    "StreetAddress" = $i.StreetAddress
    "SamAccountName" = $i.SamAccountName
    "countryCode" = $i.countryCode
    "co" = $i.co
    "country" = $i.country
    "c" = $i.c
}   |Select-Object 'Name','GivenName','Surname','Department','Division','EmployeeID','Enabled','State','StreetAddress','SamAccountName','countryCode','co','country','c'

}


for($i=0; $i -le $out.length-1 ;$i++){

    if($out[$i].c -like "IL"){
        $il += $out[$i].Department
        write-host "Dept - $i >"$out[$i].Department +" C -$i >"+ $out[$i].c
    }
}
$deptUniqIL = $il |select-Object -Property @{Name="Department";Expression={$_.Trim()}} -Unique
<# Export #>

# Department list only
$deptUniqIL | Export-Csv $outFileUniqDept -NoTypeInformation
#all other info above for future use
$out | Export-Csv $outFileAll -NoTypeInformation

