#arrays
[System.Collections.ArrayList]$arrayA = @() #all events
[System.Collections.ArrayList]$arrayT = @() #todays events
[System.Collections.ArrayList]$arrayY = @() #yesterdays events


# get fresh data
Import-Module ActiveDirectory
 
$DaysInactive = 25

$inactivetime = (Get-Date).Adddays(-($DaysInactive))

$ADsrvDump = (Get-ADComputer -Filter {OperatingSystem -Like "*Server*" -and Enabled -eq "True"} -Properties Name,Description,OperatingSystem,CanonicalName,IPv4Address,LastLogonDate | select Name,Description,OperatingSystem,CanonicalName,IPv4Address,LastLogonDate )

$ADsrvDumpFiltered = ($ADsrvDump | Where-Object{$_.LastLogonDate -gt $inactivetime})

#$ADsrvDumpFiltered | Export-Csv -UseCulture -Path 'E:\1Automation\AD\adsrvDump.csv' -Force -NoTypeInformation


#
$ADsrvDumpFstr = $ADsrvDumpFiltered | Select-Object -ExpandProperty Name

#Invoke-Command -ComputerName $ADsrvDumpFstr {Get-WinEvent -ListLog 'Microsoft-Windows-NTLM/Operational'} -ThrottleLimit 300





#Filter and report

#Execute remotely:


# $starttime = [datetime]::today
$starttimeT = [datetime]::today
$starttimeY = $starttimeT.addDays(-1)

[System.Collections.ArrayList]$arrayA = @() #all events

$8003events = Get-WinEvent -FilterHashtable @{logname = 'Microsoft-Windows-NTLM/Operational'; ID = '8003'}

foreach($i in $8003events){
    
    [xml]$ixml = $i.toxml()
    
    #create prop
       $prop = @{Username = $ixml.Event.EventData.Data[0].'#text' ; 
        Domain = $ixml.Event.EventData.Data[1].'#text' ;
        Workstation = $ixml.Event.EventData.Data[2].'#text' ;
        CallerPID = $ixml.Event.EventData.Data[3].'#text';
        ProcessName = $ixml.Event.EventData.Data[4].'#text' ;
        LogonType = $ixml.Event.EventData.Data[5].'#text' ;
        TimeCreated = $i.TimeCreated
        }

        $obj = New-Object PSObject -Prop $prop
    
    $arrayA += $obj
    
}

#RESULTS look like this:

<#

    SEE FS03 FOR DETAILS.
    ALSO REFER TO SCRIPT IN REPOSITORY FOR USEFUL REFERENCES

PS U:\> $arrayA | Group-Object -Property Workstatio


#>