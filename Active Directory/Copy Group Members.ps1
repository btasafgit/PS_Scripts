$srcGRP = "Citrix-App-Forescout"
$dstGRP = "CTX-App-Forescout"
$members = Get-ADGroupMember $srcGRP
Add-ADGroupMember $dstGRP -Members $members