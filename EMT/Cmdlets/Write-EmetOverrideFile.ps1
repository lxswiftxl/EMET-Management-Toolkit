function Write-EmetOverrideFile()
{
    param(
    [parameter(Mandatory=$true)]
    $version,
    [parameter(Mandatory=$true)]
    [string]$ProcessPath,
    [parameter(Mandatory=$true)]
    [string]$ProcessName,
    [parameter(Mandatory=$true)]
    [string]$MitigationName,
    [parameter(Mandatory=$true)]
    [string]$EmetOverrideFile
    )

# Generates the Override file the permantly changes the configuration of EMET
    $xml_file = @"
<EMET Version="$version">
  <Settings />
  <EMET_Apps>
    <AppConfig Path="$ProcessPath" Executable="$ProcessName">
      <Mitigation Name="$MitigationName" Enabled="false" />
    </AppConfig>
  </EMET_Apps>
</EMET>
"@ 
    out-file -filepath $EmetOverrideFile -InputObject $xml_file -Encoding ascii -force
}