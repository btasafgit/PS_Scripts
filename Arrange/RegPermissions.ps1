#$acl = Get-Acl 'HKLM:\Software\Juniper Networks'
#$user = "$env:USERDOMAIN\$env:USERNAME"
#$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($user,"FullControl","Allow")
#$acl.SetAccessRule($rule)
#$acl |Set-Acl -Path 'HKLM:\Software\Juniper Networks'





$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('Software\Juniper Networks',[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$acl = $key.GetAccessControl()
$user = "$env:USERDOMAIN\$env:USERNAME"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($user,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)
