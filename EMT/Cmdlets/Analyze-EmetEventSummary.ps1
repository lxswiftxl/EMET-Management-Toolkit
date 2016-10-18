function Analyze-EmetEventSummary()
{
    Param(
    [parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    $EmetEventSummary,

    [parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [boolean]$GracePeriod,

    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [int]$Threshhold = 1,

    [string]$EmetConfLocation= (join-path (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname "EMET_Conf.exe"),

    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    $ApplicationsInGracePeriod
    )

    foreach($PROCESS in $EmetEventSummary.Processes.Keys)
    {
        foreach ($MITIGATION in $EmetEventSummary.Processes.$PROCESS.Mitigations.Keys)
        {
            if ($EmetEventSummary.Processes.$PROCESS.Mitigations.$MITIGATION.NumberOfTriggers -ge $Threshhold)
            {
                if ($GracePeriod -or ($PROCESS.tolower() -in $ApplicationsInGracePeriod.name.tolower()))
                {
                    $PATH = $EmetEventSummary.Processes.$PROCESS.Mitigations.$MITIGATION.Path
                    
                    Repair-EmetConfiguration -ProcessName $PROCESS -MitigationName $MITIGATION -ProcessPath $PATH
                }
            }            
        }
    }
}
    
    
