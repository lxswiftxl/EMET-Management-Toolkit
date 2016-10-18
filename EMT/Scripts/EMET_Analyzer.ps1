Import-Module -Name EMT

# Get the static configuration from the EMT configuration file and enumerate some setting from
# the running EMET installation
$EMT_Configuration = Get-EmtConfiguration

Update-EmetApplicationRegistry

$FilterHashTable = @{LogName='Application'; ProviderName='EMET'; ID=2; starttime=$EMT_Configuration.Time_To_Parse_After}
$EmetEvents = (Get-WinEvent -FilterHashTable $FilterHashTable | Format-WinEvent -Application EMET)
$EmetApplicationRegistry = (Import-Clixml -path $EMT_Configuration.EMET_Application_Registry)
$ApplicationsInGracePeriod = (Check-EmetRegisteredApplicationGracePeriod -EmetApplicationRegistry $EmetApplicationRegistry -GracePeriod $EMT_Configuration.GracePeriod)

$splat = @{
"EmetEventSummary" = (New-EmetEventSummary -EmetEvents $EmetEvents);
"GracePeriod" = $EMT_Configuration.In_Grace_Period;
"ApplicationsInGracePeriod" = $ApplicationsInGracePeriod;
"Threshhold" = $EMT_Configuration.ThresholdToReconfigure
}

Analyze-EmetEventSummary @splat