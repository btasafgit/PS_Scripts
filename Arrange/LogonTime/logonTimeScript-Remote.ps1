#Only one computer
$comp = Get-ADComputer -Filter * |where {$_.Name -eq 'MD14018'}
#Multiple computers
#$comp = Get-ADComputer -Filter * |where {$_.Name -eq 'MDOIAG12' -or $_.Name -eq 'MDOIAG06'}
#Testing ONLY
#$comp = Get-ADComputer -Filter * |where {$_.Name -like "MDOIAG*"}
#$comp = Get-ADComputer -Filter * |where {$_.Name -like "MD13***"}
#$comp = Get-ADComputer -Filter *
$verbose = 0

if($comp -is [System.array])
{
    
        ##
        #=================Running on all compouter===================
        for($i=0; $i -le $comp.Count-1 ;$i++) #Start of per computer loop
        {
        
                # Testing if there are Explorer processes on the computer
                if($explorerProcess = get-WmiObject -ComputerName $comp[$i].Name -query "Select * from Win32_Process where Name = 'explorer.exe'" -ErrorAction SilentlyContinue)
                {
                    #If there are multiple explorer processes on the computer
                    if($explorerProcess -is [System.array])
                    {
                        for($g=0; $g -le $explorerProcess.count-1 ;$g++)
                        {
                            
                            ##Converting Explorer time and date to normal format
                            $explorerDateTime = [management.managementDateTimeConverter]::ToDateTime($explorerProcess[$g].CreationDate)
                            $explorerDate = [String]$explorerDateTime.Day +"/"+$explorerDateTime.Month+"/"+$explorerDateTime.Year
                            $explorerTime = [String]$explorerDateTime.Hour + ":" + $explorerDateTime.Minute + ":" + $explorerDateTime.Second
                            ##With Explorer Handle getting the logged on session assosciated with it
                            $explorerAssociators = [String]"associators of {Win32_Process.Handle=" + $explorerProcess[$g].Handle + "} where ResultClass = Win32_LogonSession"
                            ###Getting user Session Associated to explorer.exe
                            $userSession = Get-WmiObject -ComputerName $comp[$i].Name -query $explorerAssociators
                            ##Getting user Start logon process time and date and converting to normal format
                            $userLogonDateTime = [management.managementDateTimeConverter]::ToDateTime($userSession.StartTime)
                            $userLogonDate = [String]$userLogonDateTime.Day +"/"+$userLogonDateTime.Month+"/"+$userLogonDateTime.Year
                            $userLogonTime = [String]$userLogonDateTime.Hour + ":" + $userLogonDateTime.Minute + ":" + $userLogonDateTime.Second
                            if($verbose -eq 1)
                                {
                                    write-host $comp[$i].Name "Explorer Process is running - ARRAY"
                                    write-host "Explorer User Name: " $explorerProcess[$g].GetOwner().User
                                    write-host "Explorer Domain Name: " $explorerProcess[$g].GetOwner().Domain
                                    write-host "Explorer Process Name: " $explorerProcess[$g].Name
                                    write-host "Explorer SessionID: " $explorerProcess[$g].SessionID
                                    write-host "Explorer Handle: " $explorerProcess[$g].Handle
                                    write-host "Explorer Parent Process ID: " $explorerProcess[$g].ParentProcessId
                                    write-host "Explorer Start Date: " $explorerDate
                                    write-host "Explorer Start Time: " $explorerTime
                                    Write-Host "User Logon Start Date: " $userLogonDate
                                    Write-Host "User Logon Start Time: " $userLogonTime
                                }

                            ##calculating the diffrence between the Explorer process and the user logon time
        
                            $userLogonDiff = ($explorerDateTime.Hour - $userLogonDateTime.Hour)*3600 + ($explorerDateTime.Minute - $userLogonDateTime.Minute)*60 +($explorerDateTime.Second - $userLogonDateTime.Second)
                            write-host "User " $explorerProcess[$g].GetOwner().User " Logon process took: "$userLogonDiff "Seconds  on computer " $comp[$i].Name

                            ###Writing to CSV
                            New-Object -TypeName PSCustomObject -Property @{
                            "Username" = $explorerProcess[$g].GetOwner().User
                            "Domain" = $explorerProcess[$g].GetOwner().Domain
                            "Computername" = $comp[$i].Name
                            "LogonTime" = $userLogonDiff
                            "UserLogonDate" = $userLogonDate
                            "UserLogonTime" = $userLogonTime
                            } |select 'Username','Domain','Computername','LogonTime','UserLogonDate','UserLogonTime'| export-csv 'C:\Users\btasaf\Desktop\LogonTime\logonTime.csv' -Append
                            
                            #write-host "------------------------------------------------"


                        }
                    }
                    else # If there is a single Explorer process on the computer
                    {
                            
                            ##Converting Explorer time and date to normal format
                            $explorerDateTime = [management.managementDateTimeConverter]::ToDateTime($explorerProcess.CreationDate)
                            $explorerDate = [String]$explorerDateTime.Day +"/"+$explorerDateTime.Month+"/"+$explorerDateTime.Year
                            $explorerTime = [String]$explorerDateTime.Hour + ":" + $explorerDateTime.Minute + ":" + $explorerDateTime.Second

                            

                            ##With Explorer Handle getting the logged on session assosciated with it
                            $explorerAssociators = [String]"associators of {Win32_Process.Handle=" + $explorerProcess.Handle + "} where ResultClass = Win32_LogonSession"
                            ###Getting user Session Associated to explorer.exe
                            $userSession = Get-WmiObject -ComputerName $comp[$i].Name -query $explorerAssociators

                            ##Getting user Start logon process time and date and converting to normal format
                            $userLogonDateTime = [management.managementDateTimeConverter]::ToDateTime($userSession.StartTime)
                            $userLogonDate = [String]$userLogonDateTime.Day +"/"+$userLogonDateTime.Month+"/"+$userLogonDateTime.Year
                            $userLogonTime = [String]$userLogonDateTime.Hour + ":" + $userLogonDateTime.Minute + ":" + $userLogonDateTime.Second
                            
                            if($verbose -eq 1)
                                {
                                    write-host $comp[$i].Name "Explorer Process is running - NOT ARRAY"
                                    write-host "Explorer User Name: " $explorerProcess.GetOwner().User
                                    write-host "Explorer Domain Name: " $explorerProcess.GetOwner().Domain
                                    write-host "Explorer Process Name: " $explorerProcess.Name
                                    write-host "Explorer SessionID: " $explorerProcess.SessionID
                                    write-host "Explorer Handle: " $explorerProcess.Handle
                                    write-host "Explorer Parent Process ID: " $explorerProcess.ParentProcessId
                                    write-host "Explorer Start Date: " $explorerDate
                                    write-host "Explorer Start Time: " $explorerTime
                                    Write-Host "User Logon Start Date: " $userLogonDate
                                    Write-Host "User Logon Start Time: " $userLogonTime
                                }

                            ##calculating the diffrence between the Explorer process and the user logon time
        
                            $userLogonDiff = ($explorerDateTime.Hour - $userLogonDateTime.Hour)*3600 + ($explorerDateTime.Minute - $userLogonDateTime.Minute)*60 +($explorerDateTime.Second - $userLogonDateTime.Second)

                            write-host "User " $explorerProcess.GetOwner().User " Logon process took: "$userLogonDiff "Seconds on computer " $comp[$i].Name
                            #write-host "------------------------------------------------"

                             ###Writing to CSV
                            New-Object -TypeName PSCustomObject -Property @{
                            "Username" =  $explorerProcess.GetOwner().User
                            "Domain" = $explorerProcess.GetOwner().Domain
                            "Computername" = $comp[$i].Name
                            "LogonTime" = $userLogonDiff
                            "UserLogonDate" = $userLogonDate
                            "UserLogonTime" = $userLogonTime
                            } |select 'Username','Domain','Computername','LogonTime','UserLogonDate','UserLogonTime'| export-csv 'C:\Users\btasaf\Desktop\LogonTime\logonTime.csv' -Append
                            

                    }
            
                }
                else
                {
                    write-host "No user is logged on @" $comp[$i].Name
                    #write-host "------------------------------------------------"
                }

        } #End of per computer loop
}
else
{
    #When only one copmuter is tested after restart
    #if(Invoke-Command -ComputerName $comp.Name -ScriptBlock {Get-Process -Name 'explorer.exe'})
    for($i=0; !(get-WmiObject -ComputerName $comp.Name -query "Select * from Win32_Process where Name = 'explorer.exe'");$i++)
        {
            Write-Host "Trying to get Explorer.exe" $i
            Start-Sleep 1
            write-host "Still no user logged on"
            
        }
    if($explorerProcess = get-WmiObject -ComputerName $comp.Name -query "Select * from Win32_Process where Name = 'explorer.exe'")
    {
        #Getting Explorer Information
        
        ##Converting Explorer time and date to normal format
        $explorerDateTime = [management.managementDateTimeConverter]::ToDateTime($explorerProcess.CreationDate)
        $explorerDate = [String]$explorerDateTime.Day +"/"+$explorerDateTime.Month+"/"+$explorerDateTime.Year
        $explorerTime = [String]$explorerDateTime.Hour + ":" + $explorerDateTime.Minute + ":" + $explorerDateTime.Second
        ##Getting user Start logon process time and date and converting to normal format
        $userLogonDateTime = [management.managementDateTimeConverter]::ToDateTime($userSession.StartTime)
        $userLogonDate = [String]$userLogonDateTime.Day +"/"+$userLogonDateTime.Month+"/"+$userLogonDateTime.Year
        $userLogonTime = [String]$userLogonDateTime.Hour + ":" + $userLogonDateTime.Minute + ":" + $userLogonDateTime.Second
        ##With Explorer Handle getting the logged on session assosciated with it
        $explorerAssociators = [String]"associators of {Win32_Process.Handle=" + $explorerProcess.Handle + "} where ResultClass = Win32_LogonSession"
        ###Getting user Session Associated to explorer.exe
        $userSession = Get-WmiObject -ComputerName $comp.Name -query $explorerAssociators
        
            if($verbose -eq 1)
                    {
                        write-host "Explorer SessionID: " $explorerProcess.SessionID
                        write-host "Explorer Handle: " $explorerProcess.Handle
                        write-host "Explorer Parent Process ID: " $explorerProcess.ParentProcessId
                        write-host "Explorer Start Date: " $explorerDate
                        write-host "Explorer Start Time: " $explorerTime
                        write-host "Got Explorer Process"
                        write-host "Explorer User Name: " $explorerProcess.GetOwner().User
                        write-host "Explorer Domain Name: " $explorerProcess.GetOwner().Domain
                        write-host "Explorer Process Name: " $explorerProcess.Name
                        Write-Host "User Logon Start Date: " $userLogonDate
                        Write-Host "User Logon Start Time: " $userLogonTime
                    }

        ##calculating the diffrence between the Explorer process and the user logon time
        
        $userLogonDiff = ($explorerDateTime.Hour - $userLogonDateTime.Hour)*3600 + ($explorerDateTime.Minute - $userLogonDateTime.Minute)*60 +($explorerDateTime.Second - $userLogonDateTime.Second)

        write-host "User " $explorerProcess.GetOwner().User " Logon process took: "$userLogonDiff "Seconds on computer " $comp.Name
        #write-host "------------------------------------------------"
                        ###Writing to CSV
                            New-Object -TypeName PSCustomObject -Property @{
                            "Username" = $explorerProcess.GetOwner().User
                            "Domain" = $explorerProcess.GetOwner().Domain
                            "Computername" = $comp.Name
                            "LogonTime" = $userLogonDiff
                            "UserLogonDate" = $userLogonDate
                            "UserLogonTime" = $userLogonTime
                            } |select 'Username','Domain','Computername','LogonTime','UserLogonDate','UserLogonTime'| export-csv 'C:\Users\btasaf\Desktop\LogonTime\logonTime.csv' -Append
                            



    }
    else
    {
        write-host "No user is logged on @" $comp.Name
        #write-host "------------------------------------------------"
    }
}


