
<#
.SYNOPSIS
  Backup of GPO with HTML output.

.DESCRIPTION
  This script is used for backing up GPO with multiple domains discovery.
    - Export GPOs to a cetrelized location
    - Export HTML File
    - Discover multi-domains within a forest
    - For multi-domains - creates folder for each domain under $path
.PARAMETER Retention
      How long to save previous versions. Default = 7 days
.PARAMETER Path
      Where to save the output. Default = current folder
.INPUTS

.OUTPUTS
  
.NOTES
  Version:        2.1
  Author:         Asaf Dori
  Creation Date:  19.08.2018
  Update Date: 18.12.2019

.EXAMPLE
  .\Ormat-GPOBackup.ps1 -Retention 10 -Path c:\GPOs
#>

param(
  [int]$Retention = 7,
  [string]$Path = (Get-Location)
)

Import-Module activedirectory

$time = (get-date).AddDays($Retention*-1)
$domains = (Get-ADForest).Domains

if(-not(Get-Item $Path -ErrorAction SilentlyContinue))
      {
        New-Item -Name (Split-Path $Path -Leaf) -Path (Split-Path $Path -Parent) -type directory -ErrorAction SilentlyContinue
      }

foreach($domain in $domains){
  
  $closestDC = Get-ADDomainController -DomainName $domain -Discover
    #Create a new Directory for each domain if not present
    if(-not(Get-Item $Path\$domain -ErrorAction SilentlyContinue))
      {
        New-Item -Name $domain -Path $Path -type directory -ErrorAction SilentlyContinue
      }
    $gpos = Get-GPO -Domain $domain -All
        foreach($gpo in $gpos)
            {
              $gpoName = $gpo.DisplayName
              if(-not(Get-Item $Path\$domain\$gpoName -ErrorAction SilentlyContinue))
                {
                  New-Item -Name $gpoName -Path $Path\$domain -type directory -ErrorAction SilentlyContinue
                }
                
                Backup-GPO -Name $gpoName -Server $closestDC -Domain $domain -Path $Path\$domain\$gpoName
                
                #Export the GPO config as an HTML file
                Get-GPOReport -Name $gpoName -Domain $domain -Server $closestDC -ReportType Html -Path $Path\$domain\$gpoName\$gpoName".html"

                #Retention Cleanup
                Get-ChildItem -literalPath $Path\$domain\$gpoName | Where-Object  {$_.LastWriteTime -lt $time} |Remove-Item -force -Recurse -confirm:$false 
            } #end of foreach GPO
} #end of foreach for Domains

