class EmetEvents
{
    $Processes = @{}

    AddProcess($ProcessName)
    {
        $Process = New-Object ProcessSummary
        $Process.ProcessName = $ProcessName
        $this.Processes.Add($ProcessName, $Process)
    }
}

class ProcessSummary
{
    [string]$ProcessName
    $Mitigations = @{}
    
    AddMitigation($MitigationName)
    {
        $Mitigation = New-Object MitigationSummary
        $Mitigation.MitigationName = $MitigationName
        $this.Mitigations.add($MitigationName, $Mitigation)
    }
}

class MitigationSummary
{
    [string]$MitigationName
    [string]$Path 
    [int]$NumberOfTriggers = 1
    AddMitigationPath($MitigationPath)
    {
        $this.Path = $MitigationPath
    }
}

function New-EmetEventSummary()
{
    param(
    [Parameter(Mandatory=$true)]
    $EmetEvents
    )

    $EmetEventSummary = New-Object EmetEvents

    foreach ($EVENT in $EmetEvents)
    {   
        if (-not($EVENT.MessageProperties.ProcessName -in $EmetEventSummary.Processes.keys))
        {
            $EmetEventSummary.AddProcess($EVENT.MessageProperties.ProcessName)
            $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).AddMitigation($EVENT.MessageProperties.MitigationName)
            $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).Mitigations.($EVENT.MessageProperties.MitigationName).AddMitigationPath($EVENT.MessageProperties.Application)
        }
        elseif ($EVENT.MessageProperties.ProcessName -in $EmetEventSummary.Processes.keys -and 
                $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).Mitigations.($EVENT.MessageProperties.MitigationName))
        {
            $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).Mitigations.($EVENT.MessageProperties.MitigationName).NumberOfTriggers += 1
        }
        elseif ($EVENT.MessageProperties.ProcessName -in $EmetEventSummary.Processes.keys -and
                -not ($EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).Mitigations.($EVENT.MessageProperties.MitigationName)))
        {
            $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).AddMitigation($EVENT.MessageProperties.MitigationName)
            $EmetEventSummary.Processes.($EVENT.MessageProperties.ProcessName).Mitigations.($EVENT.MessageProperties.MitigationName).AddMitigationPath($EVENT.MessageProperties.Application)
        }
    }
    return $EmetEventSummary
}

