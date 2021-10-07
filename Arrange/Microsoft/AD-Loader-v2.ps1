
$csv = Import-Csv 'C:\Users\btasaf\Desktop\AD Loader\AD-ManPower.csv'
$logPath = "C:\Users\btasaf\Desktop\AD Loader\Errorlog.log"
$changeLogPath = "C:\Users\btasaf\Desktop\AD Loader\Changes.csv"

#Start of For
for($i=0; $i -le $csv.Length-1 ;$i++)
{
$dt = Get-Date -Format dd/MM/yyyy-HH:mm:ss
#--Clear Variables
try{
Get-Variable -Name employeeSubDepartment -ErrorAction stop |Remove-Variable -ErrorAction stop
}
catch{
$out = $dt+","+"Clear-Variable employeeSubDepartment"+","+$Error[0].Exception.Message
out-file $logPath -Append unicode -InputObject $out
Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
}

try{
Get-Variable -Name employeeDepartment -ErrorAction stop|Remove-Variable -ErrorAction stop
}
catch{
$out = $dt+","+"Clear-Variable employeeDepartment"+","+$Error[0].Exception.Message
out-file $logPath -Append unicode -InputObject $out
Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
}

try{
Get-Variable -Name employeeDivision -ErrorAction stop|Remove-Variable -ErrorAction stop
}
catch{
$out = $dt+","+"Clear-Variable employeeDivision"+","+$Error[0].Exception.Message
out-file $logPath -Append unicode -InputObject $out
Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
}

try{
Get-Variable -Name usr -ErrorAction stop|Remove-Variable -ErrorAction stop
}
catch{
$out = $dt+","+"Clear-Variable usr"+","+$Error[0].Exception.Message
out-file $logPath -Append unicode -InputObject $out
Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
}





#Subdepartment: Office > Office
#Daprtment: Department > Department
#Division: Company > Company


#--Variables
$employeeDivision = $csv[$i].Company
$employeeDepartment = $csv[$i].Department
$employeeSubDepartment = $csv[$i].Office

try{

if($usr = Get-ADUser -Filter * -Properties * |? {$_.employeeNumber -eq $csv[$i].employeeNumber})
    {
        #--Before Changes
            New-Object -TypeName PSCustomObject -Property @{
                "FirstName" = $csv[$i].FirstName
                "LastName" = $csv[$i].LastName
                "employeeNumber" = $csv[$i].employeeNumber
              "After-Office" = $csv[$i].Office
               "Before-Departnemt" = $usr.Department
                "After-Departnemt" = $csv[$i].Department
                "Before-Company" = $usr.Company
                "After-Company" = $csv[$i].Company
            }| select 'FirstName','LastName','employeeNumber','employeeID','Before-Office','After-Office','Before-Departnemt','After-Departnemt','Before-Company','After-Company' | Export-Csv $changeLogPath -Encoding Unicode -Append
            

        try{
        $usr | Set-ADUser -Office $employeeSubDepartment -Department $employeeDepartment -Company $employeeDivision
        }
        catch{
            $out = $dt+","+"Get-ADUser "+$csv[$i].FirstName+" "+$csv[$i].lastName+","+$Error[0].Exception.Message
            out-file $logPath -Append unicode -InputObject $out
            Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
        }
    }
    else
    {
        $out = $dt+","+"Get-ADUser "+$csv[$i].FirstName+" "+$csv[$i].lastName+","+$Error[0].Exception.Message+ ",Missing EmployeeNumber"
            out-file $logPath -Append unicode -InputObject $out
            Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
    }

}
catch{
$out = $dt+","+"Get-ADUser "+$csv[$i].FirstName+" "+$csv[$i].lastName+","+$Error[0].Exception.Message
out-file $logPath -Append unicode -InputObject $out
Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
}

$left = $dt + " Objects Left: " + ($csv.Length-1).ToString() + " of : " + $i.ToString() 
out-file $logPath -Append unicode -InputObject $left

}#End of For