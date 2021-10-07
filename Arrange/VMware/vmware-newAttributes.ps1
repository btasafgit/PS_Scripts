#Check if custom attributes exists
if(!(Get-CustomAttribute -Name "Main Application" -TargetType VirtualMachine -ErrorAction SilentlyContinue))
{
    New-CustomAttribute -Name "Main Application" -TargetType VirtualMachine
}

#Check if custom attributes exists
if(!(Get-CustomAttribute -Name "Server Use" -TargetType VirtualMachine -ErrorAction SilentlyContinue))
{
    New-CustomAttribute -Name "Server Use" -TargetType VirtualMachine
}

#Check if custom attributes exists
if(!(Get-CustomAttribute -Name "Contact" -TargetType VirtualMachine -ErrorAction SilentlyContinue))
{
    New-CustomAttribute -Name "Contact" -TargetType VirtualMachine
}

#Check if custom attributes exists
if(!(Get-CustomAttribute -Name "Tags" -TargetType VirtualMachine -ErrorAction SilentlyContinue))
{
    New-CustomAttribute -Name "Tags" -TargetType VirtualMachine
}

#Check if custom attributes exists
if(!(Get-CustomAttribute -Name "Authorized Access By" -TargetType VirtualMachine -ErrorAction SilentlyContinue))
{
    New-CustomAttribute -Name "Authorized Access By" -TargetType VirtualMachine
}

$csv = Import-Csv -Path c:\ABT\notes.csv

if(Get-CustomAttribute -Name "Main Application" -TargetType VirtualMachine -ErrorAction SilentlyContinue)
{
    $vm = get-vm $csv.VM
    $vm | Set-Annotation -CustomAttribute "Main Application" -Value $csv.MainApp
    $vm | Set-Annotation -CustomAttribute "Server Use" -Value $csv.ServerUse
    $vm | Set-Annotation -CustomAttribute "Contact" -Value $csv.Contact
    $vm | Set-Annotation -CustomAttribute "Authorized Access By" -Value $csv.AuthorizesAccess
    $vm | Set-Annotation -CustomAttribute "Tags" -Value $csv.Tags
}