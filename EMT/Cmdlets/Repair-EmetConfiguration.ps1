function Repair-EmetConfiguration()
{
    param(
    [parameter(Mandatory=$true)]
    [string]$ProcessName,

    [Parameter(Mandatory=$true)]
    [string]$MitigationName,

    [parameter(Mandatory=$true)]
    [string]$ProcessPath,

	[string]$EmetParentDirectory = (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname,
    [string]$EmetConfLocation = (join-path $EmetParentDirectory "EMET_Conf.exe"),
    [string]$EmetOverrideFile = (join-path $EmetParentDirectory (Join-Path "Deployment\Protection Profiles\Overrides" ($ProcessName.split(".")[0] + "_" + $MitigationName + "_Override.xml")))
    )

    if (-not(Test-Path "$EmetParentDirectory\Deployment\Protection Profiles\Overrides")) 
    {
        $null = New-Item "$EmetParentDirectory\Deployment\Protection Profiles\Overrides" -type directory
    }

    $EmetConfiguration = Get-EmetConfiguration

    foreach ($APPCONFIG in $EmetConfiguration.EMET.EMET_Apps.AppConfig)
    {
        if ($APPCONFIG.Executable.ToLower() -eq $ProcessName.ToLower())
        {
            foreach ($APPCONFIG_MITIGATION in $APPCONFIG.Mitigation)
            {
                if (($APPCONFIG_MITIGATION.Name.ToLower() -eq $MitigationName.ToLower()) -and $APPCONFIG_MITIGATION.Enabled.ToLower() -eq "true")
                {
                    if ($Path.Contains($APPCONFIG.Path.split("*")[1]))
                    {
                        $Version = $EmetConfiguration.EMET.Version
                        $null = .$EmetConfLocation --set (Join-Path $APPCONFIG.Path $ProcessName) -$MitigationName
                        Write-EmetOverrideFile -version $Version -ProcessPath $APPCONFIG.Path -ProcessName $ProcessName -MitigationName $MitigationName -EmetOverrideFile $EmetOverrideFile
                    }
                }
            }
        }
    }
}