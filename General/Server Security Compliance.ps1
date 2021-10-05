# Checks if a computer/Server has a share on it
$servers = Get-ADComputer -Filter * -SearchBase "OU=Bitlocker,DC=ORMAT,DC=com"

$tmp = @()
$err = @()
foreach($i in $Servers){
    write-host $i.DNSHostName " - OK"
    try{
    $shares = Get-WMIObject -ComputerName $i.DNSHostName -class Win32_share -ErrorAction SilentlyContinue
    foreach($g in $shares){
        $tmp += New-Object -TypeName PSObject -Property @{
            "Server Name" = $i.DNSHostName
            "Share Name" = $g.Name
            "Share Path" = $g.Path
            "Sahre Descriptiom" = $g.Description
        } #End of PS Custome Object
    } #End of Foreach Shares
    $tmp
} #End of Try
catch { 
    Write-host $i.DNSHostName " - Error"
    $err += $i.DNSHostName + " :: " + $Error[0]}
}#End of foreach Servers

$err | out-file '.\Servers Compliance\Computers-Shares-Errors.txt'
$tmp | sort 'Server Name' |Export-Csv '.\Servers Compliance\Computers-Shares.csv' -NoTypeInformation

# Verify SMB1 disabled
$obj = Get-ADGroupMember "GPO-Disable-SMB1 Client" | Get-ADComputer -Properties *

foreach($i in $obj){
    Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -ComputerName $obj[0].DNSHostName  -ErrorAction SilentlyContinue
    #write-host $i.DNSHostName
    try{
        $smb1Reg = Get-Item -ComputerName adori-vm HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -ErrorAction SilentlyContinue `
            | ForEach-Object {Get-ItemProperty $_.pspath} |select SMB1
            if($smb1Reg -ne "0"){ $smb1Reg = "2"}

        $tmp += New-Object -TypeName PSObject -Property @{
            "Server Name" = $i.DNSHostName
            "SMBVer" = $smb1Reg
        } #End of PS Custome Object

    write-host $tmp.'Server Name' "- SMBver = $SMBVer"
} #End of Try
catch { 
    Write-host $i.DNSHostName " - Error"
    $err += $i.DNSHostName + " :: " + $Error[0]}

}

# Function for getting ACLs of a share from server

$shares = Import-Csv "C:\ABT\ServersSharePermissions.csv"
    $errLog = @()
    $out = @()
    foreach ($i in $shares) {
        sleep 2
        try{
            if(($i.Share -ne "") ){ #-and ($i.Path -ne "C:\")
                    $ACLs = (Get-Acl -Path $i.Share).Access
                    #$sACL = $i |Get-SmbShareAccess

                    foreach($acl in $ACLs){
                        $out += New-Object -TypeName PSObject -Property @{
                        "Server Name" = $i.PSComputerName
                        "Path" = $i.Share
                        "FileSystemRights" = $acl.FileSystemRights
                        "AccessControlType" = $acl.AccessControlType
                        "IdentityReference" = $acl.IdentityReference
                        } #end of FOREACH ACL
                    }# end offoreach ACL

                    }# End of IF
                
            }
            catch{
                $errLog += $Error[0].Exception.Message
            }#End of Catch
        
        }# End of Foreach Share
    $out |export-csv -NoTypeInformation C:\ABT\SharesNTFSPermissions.csv
