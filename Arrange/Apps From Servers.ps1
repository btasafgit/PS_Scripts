#Create an Array Object
$appTbl = @()
#Set path for CSV file Output
$csvPath = "c:\abt\Apps.csv"

# Get list of relevant computers
$comps = Get-ADComputer -Filter {operatingSystem -like "*Server*"} -Properties *

#Loop through the copmuter list
foreach($comp in $comps){

if((Test-Connection -ComputerName $comp.Name -Count 1).StatusCode -eq 0)
    {
    $apps = Get-WmiObject -Class Win32_Product -ComputerName $comp.Name
        
        # Loop through list of apps per server
        foreach($app in $apps)
        {
        $TargetProperties = @{CompName=$comp.Name; CompStatus="OK"; AppName=$app.Name; Vendor=$app.Vendor; AppVersion=$app.Version; AppCaption=$app.Caption}
        $TargetObject = New-Object PSObject –Property $TargetProperties
        $appTbl += $TargetObject
        } #End of Foreach
    Write-host $comp.Name "OK"
    } #End of IF
else
    {
    $TargetProperties = @{CompName=$comp.Name; CompStatus="Failed"; AppName=$null; Vendor=$null; AppVersion=$null; AppCaption=$null}
    $TargetObject = New-Object PSObject –Property $TargetProperties
    $appTbl += $TargetObject
    
    Write-host $comp.Name " Not OK"
    } # End of Else
} #End of FOREACH
$appTbl |export-csv $csvPath -NoTypeInformation -Append
