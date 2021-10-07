import-module ActiveDirectory
$save = "C:\ABT\BothPDriveOut.csv"
$enabledusers = get-aduser -filter {Enabled -eq "True"} -properties Homedirectory |where {$_.HomeDirectory -ne $null}
$Result = @()
foreach ($user in $enabledusers)
{
$first = $user.givenname
$last = $user.surname
$fullname = "$first $last"
$sam = $user.samaccountname
$Pdrive = $user.homedirectory
$UserDN = $user.distinguishedname
$Person = [ADSI] "LDAP://$UserDN"
$property = "TerminalServicesHomeDirectory"
$property2 = "terminalservicesprofilepath"
try{
if($Person.psbase.invokeget($property) -ne $null)
    {
        $RDPPdrive = $Person.psbase.invokeget($property)
    }
if($Person.psbase.invokeget($property) -eq $null)
    {
        $RDPPdrive = "No"
    }
}
Catch
{
[System.Exception]
$RDPPdrive = "No"
}

try{
if($Person.psbase.invokeget($property2) -ne $null)
    {
        $RDPPhome = $Person.psbase.invokeget($property2)
    }
if($Person.psbase.invokeget($property2) -eq $null)
    {
        $RDPPhome = "No"
    }
}
Catch
{
[System.Exception]
$RDPPhome = "No"
}

$o = new-object PSObject
$o | add-member NoteProperty Name $fullname
$o | add-member NoteProperty Username $sam
$o | add-member NoteProperty HomeDrive $Pdrive
$o | add-member NoteProperty RDPProfile $RDPPdrive
$o | add-member NoteProperty RDPHome $RDPPhome
$Result += $o
}
$Result | export-csv $save -notype -append