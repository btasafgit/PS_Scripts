<#
Based on a csv list of computers, the script will remove all SMB1 Windows Features
#>



$a = Import-Csv 'C:\abt\Risks by Computer - SMB Version 2020-12-17.csv'
$logFile = "c:\abt\SMBfeature.log"


foreach($i in $a.Computer){
    try{
        
            $d = Invoke-Command -ComputerName $i -ScriptBlock -asJob {
            if((get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State -ne "Disabled"){
                Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Remove -NoRestart
                Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -Remove -NoRestart
                Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -Remove -NoRestart
                Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -Remove -NoRestart
                Start-Sleep 1
            } #End of Invoke-Command
            Write-host $i " OK"
            $d
        }# End of IF
    }#End of Try
    catch{
        $Error[0] | Out-File $logFile -Append
        Write-Host "Unable to remove SMBv1 feature for: $i"
    }#End of Catch
    Start-Sleep 2
}#End of Foreach
