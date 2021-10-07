#Delete File from C:\
    if($ExitCode -ne 1)
    {
        
        try
        {
            write-host "Start Delete File... "$vm.Name
            $script = '"cmd.exe" /C "del /Q /F c:\LocalAdminChangeSRV.exe"'
            Invoke-VMScript -ScriptText $script -VM $vm -HostCredential $hostCred -GuestCredential $guestCred -ScriptType Bat -ErrorAction stop -InformationAction SilentlyContinue
            Start-Sleep 3
        }
        catch
        {
            $out = (get-date -Format "dd/MM/yyyy-HH:mm:ss") + "," + $vm.Name + "," + $Error[0].Exception.InnerException.Message + "Unable to delete File"
            Out-File $errorLog -InputObject $out -Append
            $ExitCode = 1
        }
    }




$hostUser = "root"
$hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass


$guestUser = "administrator"
$guestPass = ConvertTo-SecureString "xhxntneunh,23~" -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass


Copy-VMGuestFile -Source "C:\PassChange.log" -Destination "C:\ABT\LocalAdminChange" -VM btasaf-dev -GuestToLocal -GuestCredential $guestCred -HostCredential $hostCred -Force 




