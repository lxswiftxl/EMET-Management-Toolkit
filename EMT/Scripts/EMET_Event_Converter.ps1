# install the custom event log for EMET events with json messages
#New-EventLog -LogName "Microsoft-Windows-EMET-JSON/Operational" -Source EMT

# Get all the events in the windows application event log and format them into objects
if (-not(Get-Module -Name EMT))
{
    Import-Module EMT
}

# Get all event in the last 6 hours. Format them so the message field is now Key Value Paird.
# This could probabaly be set to 1 hour or less.
$EmetEvents = Get-WinEvent -FilterHashtable @{logname='application'; providername='EMET'; ID=2; starttime=[datetime]::Now.AddHours(-6)} | Format-WinEvent -application EMET

# Create a list of flat objects that contain all properties from the event and its message field.
# Do not include the "message", "messageproperties", or "properties" properties because
# They are redundent.
$FormattedEvents = @()
foreach ($event in $EmetEvents)
{
    # Create an event with all the KV of the message field. Then add in all other properties from the event
    $NewEvent = $event.MessageProperties
    foreach ($FIELD in ($event | Get-Member | Where-Object {$_.membertype -eq "property"}).Name)
    {
        if ($FIELD -notcontains ("MessageProperties", "Message", "Properties"))
        {
            $NewEvent | Add-Member -MemberType NoteProperty -Name $FIELD -Value $event.$FIELD
        }
    }
    $FormattedEvents += $NewEvent
}

#Sysmon integration goes here
# TODO: We should make this a configurable duration so that it can deal with different deployments
$SysmonEvents = (Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-Sysmon/Operational"; providername='Microsoft-Windows-Sysmon'; starttime=[datetime]::Now.AddHours(-1)}) | Format-WinEvent -application Sysmon
foreach ($FORMATEDEVENT in $FormattedEvents)
{
    $RelatedEvents = $SysmonEvents | Where-Object {$_.messageproperties.processid -eq $FORMATEDEVENT.pid}
    break
}
exit
# Get all the events in the custom EMET event log and store them as objects
# TODO: We should make this a configurable duration so that it can deal with different deployments
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