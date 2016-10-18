# install the custom event log for EMET events with json messages
#New-EventLog -LogName "Microsoft-Windows-EMET-JSON/Operational" -Source EMT

# Get all the events in the windows application event log and format them into objects

Import-Module EMT

$EmetEvents = Get-WinEvent -FilterHashtable @{logname='application'; providername='EMET'; ID=2; starttime=[datetime]::Now.AddHours(-6)} | Format-WinEvent -application EMET

$FormattedEvents = @()
foreach ($event in $EmetEvents)
{
    $NewEvent = $event.MessageProperties
    foreach ($FIELD in ($event | Get-Member | Where-Object {$_.membertype -eq "property"}).Name)
    {
        if ($FIELD -notcontains ("MessageProperties", "Message", "Properties"))
        {
            Write-Host $FIELD
            $NewEvent | Add-Member -MemberType NoteProperty -Name $FIELD -Value $event.$FIELD
        }
    }
    $FormattedEvents += $NewEvent
}

# Get all the events in the custom EMET event log and store them as objects

$CustomEmetEvents = Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-EMET-JSON/Operational"; providername='EMT'; starttime=[datetime]::Now.AddHours(-6)}

# compare the two lists against each other and write the new emet events to the custom emet event log

foreach ($NEWEVENT in $FormattedEvents)
{
    $MatchingEvents = $CustomEmetEvents | Where-Object {($_.message | convertfrom-json).RecordId -eq $NEWEVENT.RecordId}

    if (-not($MatchingEvents))
    {
        Write-EventLog -LogName Microsoft-Windows-EMET-JSON/Operational -Source EMT -EntryType Error -EventId 02 -Category 0 -Message ($NEWEVENT | convertto-json)
    }
}