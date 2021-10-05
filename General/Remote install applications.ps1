$src = "\\ormat-sccm\sources\Security\CyberArk\EPM\11.7.1.359\CyberArkEPMAgent-x64.msi"

$c = "Gsharvit-X390.ormat.com"

try{
    
    $p = "\\"+$c+"\c$\support\"
    Copy-Item $src -Destination $p
    while(Test-Path "\\$c\c$\support\CyberArkEPMAgent-x64.msi"){
    Invoke-Command -ComputerName $c -scriptblock{
    msiexec /i "C:\Support\CyberArkEPMAgent-x64.msi" /qn INSTALLATIONKEY="G2C2cjMY&ZpE" /log C:\Support\install-EPM.log
    sleep 2
    Remove-Item "\\$c\c$\support\CyberArkEPMAgent-x64.msi"
    }
}
}
catch{
    $Error[0] | Out-File c:\abt\EPM-RemoteScript.log
}



[System.Collections.ArrayList]$epms = @("BWF-AHERNANDEZ-","BWF-GCOWAN2-LT","BWF-JAGUILAR-LT","BWF-JAMEST-LT","BWF-KIOSK3-DT","BWF-KIOSK4-DT","NWR-IEC01-LT","RC-AJOHNSON-LT","RC-AMCINNIS-LT",
"RC-AVIOLA-LT","RC-BJENKS-LT","RC-BORCUTT1-LT","RC-ITLOAN02-LT","RC-JCLARK2-LT","RC-OPEN11-LT","RC-PDRAKOS1-LT","RC-PSPIELMAN-LT","RC-PWALSHX1-LT","RC-QRICKS-LT",
"RC-RIMBASE02-LT","RC-RIMBASE04-LT","RC-ROREN2-LT","RC-NMAUS-LT","RC-SKESSLER3-LT","RC-TROACH-LT","SB-CQUENIAHAN-D","RC-JOLEE-LT","RC-ROREN2-LT","RC-KEARL1-LT",
"RC-KNGENE1-LT","RC-KNORRIS-LT","RC-PBAKANE2-LT","RC-RWRIGHT1-LT","RC-SSULLIVA-LT","SB-EVASQUEZ1-LT","SB-RMORENO-LT",
"RS-NORELLA-LT","BR-VPETERS-DT","ORM-EIC3-DT","TU-OPS3-DT","VE-JBUTT-LT","VE-MSTOUT-LT","VE-NBOZORGP-LT","VE-OPEN01-LT","VE-PMCGRATH-LT","VESI-ASUSNER-LT",
"OREG-BSMITH-LT","OREG-EWETTS2-LT","OREG-EWETTS-LT1","OREG-KBAIL-LT","OREG-RJENSEN1-L","OREG-RSCILL2-LT","PGV-DCABARLO-LT",
"PGV-GFREEMAN-LT","PGV-OPS1-LT","PGV-OPS2-LT","PGV-OPS4-LT","NHS-ICE-LT",
"RR-BMAYFIELD-LT","RR-DMAYFIELD-LT","HEB-ADMINSP-LT","HEB-AVELASCO-L5","HEB-EBARAJAS-LT","HEB-LALVARE-LT2",
"HEB-SPARE1-LT","GEO-DRIG4-LT","GEO-DRIG7-LT","GEO-JLOPEZ1-LT","GEO-JSUAMAT-LT","GEO-MRICHARD-LT","GEO-OPEN01-LT",
"GTM-EOROZCO-LT","GTM-JMIRANDA-LT","GTM-LESTRA-LT2","GTM-LPRADO-LT1","GTM-LVILLEG2-LT","GTM-NDELEON-LT","GTM-ORTITLA-LT1",
"GUA-AFICADIE-LT","GUA-NDEMARCK-DT","HON-KDERAS-LT","HON-TEMP4-LT","HON-TEMP5-LT","IN-FDERMAW-LT","NZ-BHAMBLYN-LT")

foreach($i in $epms){
    if((Test-NetConnection -ComputerName $i).PingSucceeded -eq $true){
        $c = $i
            Write-Host "Working on " $i -ForegroundColor Green
            try{
                Copy-Item $src -Destination "\\$c\c$\support\"
                sleep 10
                Invoke-Command -ComputerName $c -scriptblock{
                msiexec /i "C:\Support\CyberArkEPMAgent-x64.msi" /qn INSTALLATIONKEY="G2C2cjMY&ZpE" /log C:\Support\install-EPM.log
                sleep 10
                Remove-Item "\\$c\c$\support\CyberArkEPMAgent-x64.msi"
                $epms.Remove($c)
                } #End of Invoke
            } #End of try
            catch{
                $Error[0] | Out-File c:\abt\EPM-RemoteScript.log
            } #End of Catch
    }
    else{
        Write-Host $i " Host Unreashable" -ForegroundColor Red
    }
}