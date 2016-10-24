if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    write-host "
Not running with administrative priviledges.
This script will not be able to make the scheduled
task needed to trigger EmetAnalyzer without admin
priviledges.
"
    exit
}

# Move the folder containing EMT to a proper known powershell module location
Copy-Item -Path ($PSScriptRoot | Split-Path -Parent) -Destination $env:PSModulePath.split(';')[1] -Container -Recurse -Force
Write-Host ("Recursively copied the folder: " + ($PSScriptRoot | Split-Path -Parent))
write-host ("Forcefully wrote the copied folder to: " + $env:PSModulePath.split(';')[1])

if (-not(Get-WinEvent -ListLog Microsoft-Windows-EMET-JSON/Operational)){

    New-EventLog -LogName Microsoft-Windows-EMET-JSON/Operational -Source EMT
    Write-Host "Created new event log for EMET Events: Microsoft-Windows-EMET-JSON/Operational"
}
else{
    
    Write-Host "Event Log Microsoft-Windows-EMET-JSON/Operational already exists"
}

Import-Module EMT

$EMT_Configuration = Get-EmtConfiguration -ConfigurationFileLocation (join-path $env:PSModulePath.split(';')[1] "EMT\Config\EMT_Config.json")

$Subscription = @"
<QueryList>
    <Query Id="0" Path="Application">
      <Select Path="Application">*[System[Provider[@Name='EMET'] and (Level=2) and (EventID=2)]]</Select>
    </Query>
</QueryList>
"@

if (-not(Get-ScheduledTask -TaskName "EMET Analyzer"))
{
    $splat = @{
    "TaskName" = 'EMET Analyzer';
    "TaskDescription" = 'Parses the Event long when EMET triggers and determines if EMET needs reconfigured';
    "TaskCommand" = (join-path $PSHOME 'powershell.exe');
    "TaskArg" = ('-ExecutionPolicy Bypass -File "' + (join-path $env:PSModulePath.split(';')[1] 'EMT\Scripts\EMET_Analyzer.ps1"'));
    "Subscription" = $Subscription;
    "TriggerType" = 0
    }

    New-ScheduledTaskComObject @splat
}

if (-not(Get-ScheduledTask -TaskName 'EMET Event Converter'))
{
    $splat = @{
    "TaskName" = 'EMET Event Converter';
    "TaskDescription" = 'Parses the Event long when EMET triggers and reformat them into easily consumable event with json objects as message fields';
    "TaskCommand" = (join-path $PSHOME 'powershell.exe');
    "TaskArg" = ('-ExecutionPolicy Bypass -File "' + (join-path $env:PSModulePath.split(';')[1] 'EMT\Scripts\EMET_Event_Converter.ps1"'));
    "Subscription" = $Subscription;
    "TriggerType" = 0
    }

    New-ScheduledTaskComObject @splat
}