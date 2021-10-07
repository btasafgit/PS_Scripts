$a = import-csv C:\Users\btasaf\Desktop\mail.csv -Header group

for($i=0; $i -le $a.Length ;$i++)
{
    $b = Get-ADGroup $a[$i].group -Properties Name,Members -ErrorAction SilentlyContinue |select Members
        
    for($g=0; $g -le $b.Members.Count-1 ;$g++)
    {
        $groupName = $a[$i].group
        $usrInGroup = $b.Members
        $user = Get-ADUser $usrInGroup[$g]

        if($groupName -ne $a[$i].group)
                {
                    $groupName = $null
                    #Write-Host 1
                }
                else
                {
                    
                    $groupName = $a[$i].group
                    #Write-Host 2
                }

        ###Writing to CSV
                New-Object -TypeName PSCustomObject -Property @{
                "GroupName" = $groupName
                "UserName" = $user.Name
                            } |select   'GroupName',
                                        'UserName'|  export-csv 'C:\Users\btasaf\Desktop\UserinGroup.csv' -Append
                                        
                          
                          }
    

    #sleep 1
}



#| export-csv 'C:\Users\btasaf\Desktop\UserinGroup.csv' -Append



