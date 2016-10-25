function Format-WinEvent()
{   
    Param (
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true)]
               [Diagnostics.Eventing.Reader.EventRecord[]]
               $Events,
    
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true)]
               [Validateset("EMET", "Sysmon")]
               [string]$Application
    )
  
    Begin
    {
        # The regex expressions that will be used to get the key value pairs, and mitigation name are defined
        $EMET_Regex = @{
            "Key_Value_Pattern" = '([ a-z0-9A-Z]*)(?: \t+: )(.+\n|.+)?';
            "Mitgation_Name_Pattern" = '^(?:[a-zA-Z]+ ){2}([a-zA-Z0-9 ]+)(?:mitigation)'
        }

        $SYSMON_Regex = @{
            "Key_Value_Pattern" = '(.*)(?:: )(.*)'
        }
        $Results = @()
    }
  
    Process
    {
        # We use a for loop so that we can process a single or many object that were passed into the cmdlet 
        foreach ($EVENT in $Events)
        {
            if ($Application -eq 'Sysmon')
            {
                $FormattedEvent = New-Object -TypeName PSObject
                $FormattedEvent | Add-Member -MemberType NoteProperty -Name MessageProperties -Value (New-Object -TypeName PSObject)
            
                foreach ($FIELD in ($EVENT | Get-Member -MemberType Property,NoteProperty).name)
                {
                    $FormattedEvent | Add-Member -MemberType NoteProperty -Name $FIELD -Value $EVENT.$FIELD
                }

                $Matches = ($EVENT.message | select-string -Pattern $SYSMON_Regex.Key_Value_Pattern -AllMatches).Matches

                foreach ($MATCH in $Matches){
    
                    $FormattedEvent.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.trim()
                }
                # Get the name of the rule that logged this event
                $FormattedEvent.MessageProperties | Add-Member -MemberType NoteProperty -Name Rule -Value $EVENT.TaskDisplayName.split(":")[1].split(")")[0].trim()
                
                $Results += $FormattedEvent
            }
            elseif ($Application -eq "EMET")
            {
                $FormattedEvent = New-Object -TypeName PSObject
                $FormattedEvent | Add-Member -MemberType NoteProperty -Name MessageProperties -Value (New-Object -TypeName PSObject)
            
                foreach ($FIELD in ($EVENT | Get-Member -MemberType Property,NoteProperty).name)
                {
                    $FormattedEvent | Add-Member -MemberType NoteProperty -Name $FIELD -Value $EVENT.$FIELD
                }

                $Matches = ($Event.Message | Select-String -Pattern $EMET_Regex.Key_Value_Pattern -AllMatches).Matches

                # The results of our regex are parsed and 
                # the key value pairs are added to the EventObj as property value combinations  
                foreach ($MATCH in $Matches){
                    
                    $FormattedEvent.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.trim()
                }

                # The processname is split out of the application name and the mitigation name is aquired with a specific regex
                $ProcessName = $FormattedEvent.MessageProperties.Application | Split-Path -leaf
                $FormattedEvent.MessageProperties | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $ProcessName

                $MitigationName = ($FormattedEvent.Message | select-string -pattern $EMET_Regex.Mitgation_Name_Pattern).Matches[0].Groups[1].Value.Trim()
                $FormattedEvent.MessageProperties | Add-Member -MemberType NoteProperty -Name 'MitigationName' -Value $MitigationName

                # The enriched EMET event is added to a list of parsed EMET objects
                $Results += $FormattedEvent
            }
        }
    }
  
    End
    {
        $Results
    }
}