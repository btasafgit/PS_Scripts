#$username = "$env:USERDOMAIN"+"\"+"$env:USERNAME"
#$password = read-host "Enter a Password" -assecurestring
#File Location
#$file = Read-Host "Please Enter the location for the file to be saved"
$file = "C:\Users\btasaf\Desktop\AllMyScripts\getExchangemailbox permissions\ExchangeMailPerm-Uni.csv"
#Connecting to Exchange Server PowerShell
#$exServer = Read-Host "Enter your CAS server Name [FQDN]"
#$session = New-PSSession -Configurationname Microsoft.Exchange –ConnectionUri http://$exServer/powershell -Credential $username
$session = New-PSSession -Configurationname Microsoft.Exchange –ConnectionUri http://tom.ds-invest.local/powershell
Import-PSSession $session

clear-host

#Mailbox List by OU
$mailbox = Get-Mailbox -OrganizationalUnit "OU=Service Mailbox,OU=Users,OU=Meitav Dash Network,DC=DS-Invest,DC=Local"

# Run on every mailbox
for($i=0; $i -le $mailbox.count-1 ;$i++)
{
    #Count Down till the end
    clear-host
    $count = $mailbox.Count-$i
    write-host $count
    
    #Mailbox name
    $mailName = $mailbox[$i].Name
    #username
    $user = Get-MailboxPermission $mailName | select User,AccessRights

    #Writing to CSV
    for($g=0; $g -le $user.count-1 ;$g++)
    {
        #$user[$g].User
        #$user[$g].AccessRights
        ###Writing to CSV


        ## Excluding Administrative and default management users
        if(($user[$g].User -notlike "*NT AUTHORITY*")`
            -and ($user[$g].User -notlike "*ev_svc*")`
            -and ($user[$g].User -notlike "*btasaf*")`
            -and ($user[$g].User -notlike "*backup*")`
            -and ($user[$g].User -notlike "*Domain Admins*")`
            -and ($user[$g].User -notlike "*Enterprise Admins*")`
            -and ($user[$g].User -notlike "*Organization Management*")`
            -and ($user[$g].User -notlike "*Exchange Trusted Subsystem*")`
            -and ($user[$g].User -notlike "*Exchange Domain Servers*")`
            -and ($user[$g].User -notlike "*Public Folder Management*")`
            -and ($user[$g].User -notlike "*Exchange Servers*")`
            -and ($user[$g].User -notlike "*Delegated Setup*")`
            -and ($user[$g].User -notlike "*tamir*")`
            -and ($user[$g].User -notlike "*Dash*")
            )
            
            {
                New-Object -TypeName PSCustomObject -Property @{
                                                                "Mailbox" = $mailName = $mailbox[$i].Name
                                                                "Username" = $user[$g].User
                                                                "AccessRights" = $user[$g].AccessRights
                                                                } |select 'Mailbox','Username','AccessRights'| Export-csv $file -Append -Encoding Unicode
            }
     }

     
    

}

clear-host
write-host "Done!!!!!"
