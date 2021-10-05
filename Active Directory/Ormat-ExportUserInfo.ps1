$cred = Get-Credential
$usrs = get-aduser -filter * -Credential $cred -properties * |? {$_.enabled -eq $true -and ($_.employeeID -ne '0')}

$errors = @()
$obj = @()
foreach($usr in $usrs){
    $hasPhoto = "NA"
    $filePath = "c:\temp\"+$usr.Name+".jpg"

    if(Test-Path $filePath){$hasPhoto="V"}else{$hasPhoto="X"}
    $obj += New-Object -TypeName PSCustomObject -Property @{

        <#"Given Name" = $usr.GivenName
        "SurName" = $usr.sn
        "c" = $usr.c
        "co" = $usr.co
        "Country" = $usr.l
        "Street Address" = $usr.streetAddress
        "Company" = $usr.company
        "Department" = $usr.Department
        "Title" = $usr.Title
        "Employee ID" = $usr.EmployeeID
        "telephoneNumber" = $usr.telephoneNumber
        "mobile" = $usr.mobile#>
        "Name" = $usr.Name
        "Username" = $usr.samAccountName #username
        "UPN" = $usr.UserPrincipalName
        "Mail" = $usr.mail
        "Description" = $usr.Description
        "HasPhoto" = $hasPhoto
        "filePath" = $filePath
            } #end of New Object
            if($hasPhoto -eq "X"){ $errors += $usr.Name
                Write-Host -ForegroundColor Red $usr.Name}

        } #End of foreach

        
$obj|select "Name", "Username","Mail","HasPhoto","filePath" |Export-Csv "C:\Users\adori\OneDrive - Ormat\Documents\WindowsPowerShell\SF-Export-UserInfo.csv" -NoTypeInformation

$l = @("PunaCSC",
"SB-ENG-CntrlRm",
"recruiter",
"sbrecruiter",
"ofc2",
"Sfira17",
"Sfira14",
"Sfira10",
"Sfira11",
"Sfira15",
"Sfira18",
"Sfira12",
"Sfira13",
"Sfira16",
"Sfira19",
"Sfira21",
"Sfira22",
"Sfira23",
"weight",
"CitadelSoc",
"nsprings",
"PT_Admin",
"IT-CC",
"AfterSale",
"forescout",
"OrmatInfo",
"OrmatHR",
"rr-printer",
"Student7",
"Student8",
"sec-notification",
"Sfira01",
"Sfira02",
"Sfira03",
"Sfira04",
"Sfira05",
"Sfira06",
"Sfira07",
"Sfira08",
"Sfira09",
"Sfira20",
"Sfira40",
"sldadm",
"SAPServiceSLD",
"gytpolsvc",
"ersadm",
"SAPServiceERS",
"SynelInt",
"Drilling-Rig1",
"Drilling-Rig4",
"ormatsupport",
"masav",
"SolarWinds-Monitor",
"fpsvc",
"kpmg-gb3",
"DP23",
"Drilling-Rig2",
"Drilling-Rig3",
"Drilling-Rig8",
"Drilling-Rig7",
"It-Monitoring",
"ZoomTraining",
"vesi-spsystem",
"epmtestusr",
"JiraAdmin",
"SFTEST",
"ntxservice",
"SuccessFactorsRM",
"Cymulate",
"AndreyPM",
"SolarWindsBI",
"BackBox",
"AIP-Service-Azure",
"IT-Monitoring-Dev")

foreach($i in $l){
    #Get-ADUser $i -Credential $cred -Properties employeeID |Set-ADUser -EmployeeID 0
    Get-ADUser $i -Credential $cred -Properties employeeID|select employeeID
}

get-aduser "BackBox" -Properties employeeID 