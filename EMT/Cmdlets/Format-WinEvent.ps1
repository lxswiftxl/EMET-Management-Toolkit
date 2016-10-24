function Format-WinEvent()
{   

    Param (
    [Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
                [Diagnostics.Eventing.Reader.EventRecord[]]
                $Events,
    
    [Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
                [validateset("EMET", "Sysmon")]
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
                $Matches = ($EVENT.message | select-string -Pattern $SYSMON_Regex.Key_Value_Pattern -AllMatches).Matches
                $EVENT | Add-Member -MemberType NoteProperty -Name MessageProperties -Value (New-Object -TypeName PSObject)
            
                foreach ($MATCH in $Matches){
    
                    $EVENT.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.trim()
                }
                # Get the name of the rule that logged this event
                $EVENT.MessageProperties | Add-Member -MemberType NoteProperty -Name Rule -Value $EVENT.TaskDisplayName.split(":")[1].split(")")[0].trim()
                
                $Results += $EVENT
            }

            if ($Application -eq "EMET")
            {
                $Matches = ($Event.Message | Select-String -Pattern $EMET_Regex.Key_Value_Pattern -AllMatches).Matches
                $EVENT | Add-Member -MemberType NoteProperty -Name MessageProperties -Value (New-Object -TypeName PSObject)

                # The results of our regex are parsed and 
                # the key value pairs are added to the EventObj as property value combinations  
                foreach ($MATCH in $Matches){
                    
                    <#
                    $MATCH.group[1].value.trim() | out-host
                    # look for the PID and TID values. Remove the hex and other formatting.
                    if ($MATCH.group[1].value.trim() -eq 'PID'){

                        $EVENT.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.split(' ')[1].split('(')[1].split(')')[0].trim()
                    }
                    elseif ($MATCH.group[1].value.trim() -eq 'TID'){

                        $EVENT.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.split(' ')[1].split('(')[1].split(')')[0].trim()
                    }
                    else{
                    #>
                        $EVENT.MessageProperties | Add-Member -MemberType NoteProperty -Name $MATCH.groups[1].value.trim() -Value $MATCH.groups[2].value.trim()
                    #}
                }

                # The processname is split out of the application name and the mitigation name is aquired with a specific regex
                $ProcessName = $EVENT.MessageProperties.Application | Split-Path -leaf
                $Event.MessageProperties | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $ProcessName

                $MitigationName = ($EVENT.Message | select-string -pattern $EMET_Regex.Mitgation_Name_Pattern).Matches[0].Groups[1].Value.Trim()
                $Event.MessageProperties | Add-Member -MemberType NoteProperty -Name 'MitigationName' -Value $MitigationName

                # The enriched EMET event is added to a list of parsed EMET objects
                $Results += $Event
            }
        }
    }
  
    End
    {
        $Results
    }
}