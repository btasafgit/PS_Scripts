#General Info
$errorLog = "\\na02\data$\IT\System\btasaf\Documents\Change Local Admin Password\LocalAdmin for Servers\Log.log"

#Connect to vCenter Server
$vServer = "md-vc"
Connect-VIServer $vServer

#vm Gueat Creds
$guestUser = "administrator"
$guestPass = ConvertTo-SecureString "xhxntneunh,23~" -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass

#vm Host Creds
$hostUser = "root"
$hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass

#Vm Geusts list
$vms = Get-VM btasaf-dev


#Copy Source
$fileFrom = "\\na02\data$\IT\System\btasaf\Documents\Change Local Admin Password\LocalAdmin for Servers\LocalAdminChangeSRV.exe"
#Copy Destination
$fileTo = "C:\"

foreach($vm in $vms)
{
    #vm Gueat Creds
    $guestUser = "administrator"
    $guestPass = ConvertTo-SecureString "xhxntneunh,23~" -AsPlainText -Force
    $guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass

    #Clear vars
    $ExitCode = 0
    #Remove-Variable err -Force -Confirm $false -ErrorAction SilentlyContinue
    #Remove-Variable warn -Force -Confirm $false -ErrorAction SilentlyContinue
    #Remove-Variable info -Force -Confirm $false -ErrorAction SilentlyContinue

    #Connect to vm and copy Change admin password file
        try
            {
                write-host "start copy file... "$vm.Name 
                Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -LocalToGuest -GuestCredential $guestCred -Force -ErrorAction Stop -ErrorVariable err -WarningVariable warn -InformationVariable info
                write-host "End copy file... "$vm.Name
            }
        catch
            {
                $out = (get-date -Format "dd/MM/yyyy-HH:mm:ss") + "," + $vm.Name + "," + $Error[0].Exception.InnerException.Message + "File Not Copied"
                Out-File $errorLog -InputObject $out -Append
                $ExitCode = 1
            }

    #Run LocalAdminChange file
    if($ExitCode -ne 1)
    {
        try
            {
                write-host "Start Running File... "$vm.Name
                #$script = '"cmd.exe" /C "c:\LocalAdminChangeSRV.exe"'
                $script = '"cmd.exe" /C "c:\LocalAdminChangeSRV.exe"'
                Invoke-VMScript -ScriptText $script -VM $vm -GuestCredential $guestCred -ScriptType Bat
                
                #After Pass Changed
                $guestUser = "administrator"
                $guestPass = ConvertTo-SecureString 'M$X80x0n3' -AsPlainText -Force
                $guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass

                

                Start-Sleep 3
                write-host "End Running File... "$vm.Name
            }
        catch
            {
                #$out = (get-date -Format "dd/MM/yyyy-HH:mm:ss") + "," + $vm.Name + "," + $Error[0].Exception.InnerException.Message + "Unable to run File"
                #Out-File $errorLog -InputObject $out -Append
                $ExitCode = 1
            }
    }#End of if Run LocalAdminChange file


    #Collect Data
    if($ExitCode -ne 1)
    {
        try{
        Write-Host "Getting file from Guest..."
        Copy-VMGuestFile -Source "C:\PassChange.log" -Destination "\\na02\data$\IT\System\btasaf\Documents\Change Local Admin Password\LocalAdmin for Servers\Logs\" -VM $vm -GuestToLocal -GuestCredential $guestCred -HostCredential $hostCred -Force  -ErrorAction stop
        sleep 5
        $logCont = Get-Content "\\na02\data$\IT\System\btasaf\Documents\Change Local Admin Password\LocalAdmin for Servers\Logs\PassChange.log"
        
        $logContDateTime = $logCont.Substring(0,$logCont.IndexOf(","))
        $logCont = $logCont.Substring($logCont.IndexOf(",")+1)
        
        $logContComputer = $logCont.Substring(0,$logCont.IndexOf(","))
        $logCont = $logCont.Substring($logCont.IndexOf(",")+1)
        
        $logContStatus = $logCont

        $out = (get-date -Format "dd/MM/yyyy-HH:mm:ss") + "," + $logContComputer.ToString() + "," + $logContStatus.ToString() + ",OK"
                Out-File $errorLog -InputObject $out -Append
        }
        catch{
                $out = (get-date -Format "dd/MM/yyyy-HH:mm:ss") + "," + $vm.Name + "," + $Error[0].Exception.InnerException.Message + ",Unable to get log File"
                Out-File $errorLog -InputObject $out -Append
                $ExitCode = 1
                }
    }

}

