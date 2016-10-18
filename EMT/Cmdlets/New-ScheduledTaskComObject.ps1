function New-ScheduledTaskComObject()
{

    # This fuction creates a com object, set its configuration, 
    Param(
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$TaskName,
    
    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$TaskDescription,
    
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$TaskCommand,
    
    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [string]$TaskArg,
    
    [boolean]$AllowDemandStart = $true,
    
    [boolean]$AllowHardTerminate = $true,
    
    $Compatibility = 2,
    
    [boolean]$DisallowStartIfOnBatteries = $false,
    
    [boolean]$Enabled = $true,
    
    $ExecutionTimeLimit = "PT5m",
    
    $Hidden = $false,
    
    $MultipleInstances = 1,
    
    $Priority = 10,
    
    $RestartCount = 3,
    
    $RestartInterval = "PT5M",
    
    [boolean]$StartWhenAvailable = $true,
    
    [boolean]$StopIfGoingOnBatteries = $false,
    
    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [Validateset(0,1)]
    $TriggerType = 1,
    
    [parameter(ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    $Subscription
    )
 
    # Create a variable with the scheduled.service object in it                
    $service = New-Object -ComObject("Schedule.Service")
    $service.Connect()

    # This needs researched and made in to a configurable option
    $rootFolder = $service.GetFolder("\")


    # Can the 0 be made in to an option?
    $TaskDefinition = $service.NewTask(0)
    $TaskDefinition.RegistrationInfo.Description = "$TaskDescription"
    $TaskDefinition.Settings.AllowDemandStart = $true
    $TaskDefinition.Settings.AllowHardTerminate = $true
    
    # Can this be made in to an option?
    $TaskDefinition.Settings.Compatibility = 2
    $TaskDefinition.Settings.DisallowStartIfOnBatteries = $false
    $TaskDefinition.Settings.Enabled = $true
    
    # I need a parser for this so that I can feed human readable values in to this instead of this 
    $TaskDefinition.Settings.ExecutionTimeLimit = "PT1H"
    $TaskDefinition.Settings.Hidden = $true

    # I need to understand what this means and make it in to a paramater
    $TaskDefinition.Settings.MultipleInstances = 1
    
    # I need to understand what this means and make it in to a paramater
    $TaskDefinition.Settings.Priority = 10
    $TaskDefinition.Settings.RestartCount = 3
    $TaskDefinition.Settings.RestartInterval = "PT5M"
    $TaskDefinition.Settings.StartWhenAvailable = $true
    $TaskDefinition.Settings.StopIfGoingOnBatteries = $false
    
    # Create(0) is specifically a event trigger. (1) would be a time trigger
    $triggers = $TaskDefinition.Triggers
    $trigger = $triggers.Create($TriggerType)  #  Event specific trigger
    $trigger.Enabled = $true
    
    # This section needs and if statement 
    $trigger.Subscription = $Subscription

    $Action = $TaskDefinition.Actions.Create(0)
    $Action.Path = "$TaskCommand"
    $Action.Arguments = "$TaskArg"

    # This needs to probabaly be a second command
    $err = $rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5)
}