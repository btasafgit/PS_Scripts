$Version = "Citadel Share Files Audit 0.01"

##########################################################

$startTime = Get-Date
write-host "Please run the script with administrative privileges!" -ForegroundColor Magenta

# get hostname to use as the folder name and file names
$hostname = hostname
# get the windows version
$winVersion = [System.Environment]::OSVersion.Version

# create new folder if it doesn't exists
if (!(Test-Path $hostname)) {New-Item $hostname -type directory | Out-Null}

#########################################################

# get shared folders
write-host Getting shared folders... -ForegroundColor Green
"============= Shared Folders =============" | Out-File $hostname\Shares_$hostname.txt
$shares = Get-WmiObject -Class Win32_Share
$shares | Out-File $hostname\Shares_$hostname.txt -Append
# get shared folders + share permissions + NTFS permissions with SmbShare module (exists only in Windows 8 or 2012 and above)
foreach ($share in $shares)
{
    $sharePath = $share.Path
    $shareName = $share.Name
    "`n============= Share Name: $shareName | Share Path: $sharePath =============" | Out-File $hostname\Shares_$hostname.txt -Append
    "Share Permissions:" | Out-File $hostname\Shares_$hostname.txt -Append
    # Get share permissions with SmbShare module (exists only in Windows 8 or 2012 and above)
    try
    {
        import-module smbshare -ErrorAction SilentlyContinue
        $share | Get-SmbShareAccess | Out-String -Width 180 | Out-File $hostname\Shares_$hostname.txt -Append
    }
    catch
    {
        $shareSecSettings = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -Filter "Name='$shareName'"
        if ($shareSecSettings -eq $null)
            {
            # Unfortunately, some of the shares security settings are missing from the WMI. Complicated stuff. Google "Count of shares != Count of share security"
            "Couldn't find share permissions, doesn't exist in WMI Win32_LogicalShareSecuritySetting.`n" | Out-File $hostname\Shares_$hostname.txt -Append}
        else
        {
            $DACLs = (Get-WmiObject -Class Win32_LogicalShareSecuritySetting -Filter "Name='$shareName'" -ErrorAction SilentlyContinue).GetSecurityDescriptor().Descriptor.DACL
            foreach ($DACL in $DACLs)
            {
                if ($DACL.Trustee.Domain) {$Trustee = $DACL.Trustee.Domain + "\" + $DACL.Trustee.Name}
                else {$Trustee = $DACL.Trustee.Name}
                $AccessType = [Security.AccessControl.AceType]$DACL.AceType
                $FileSystemRights = $DACL.AccessMask -as [Security.AccessControl.FileSystemRights]
                "Trustee: $Trustee | Type: $AccessType | Permission: $FileSystemRights" | Out-File $hostname\Shares_$hostname.txt -Append
            }
        }    
    }
    "NTFS Permissions:" | Out-File $hostname\Shares_$hostname.txt -Append
    try {(Get-Acl $sharePath).Access | ft | Out-File $hostname\Shares_$hostname.txt -Append}
    catch {"No NTFS permissions were found." | Out-File $hostname\Shares_$hostname.txt -Append}
}
