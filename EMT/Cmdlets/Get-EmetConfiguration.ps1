function Get-EmetConfiguration()
{
    Param 
    (
    [string]$EmetParentPath = (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname,

    [string]$ExportedConfigurationLocation = (join-path $EmetParentPath "Exported_Configuration.xml"),

    [string]$EmetConfLocation = (join-path $EmetParentPath "EMET_Conf.exe")
    )
    
    begin
    {}

    process
    {
        # call emet_conf.exe to export the running configuration $current_config
        # EMET_Conf has stand output that needs trapped or it will get
        # Added to the return values and corrupt the variable.
        $null = (.$EmetConfLocation --export $ExportedConfigurationLocation)
    
        # read in the current configuration XML file that was just created
        # Add a try catch that can handle an exception raised by EMET_Conf.exe
	    $Export_Output = [XML](get-content $ExportedConfigurationLocation)
        
        Remove-Item $ExportedConfigurationLocation
        Export-Clixml -Path $ExportedConfigurationLocation -InputObject $Export_Output
        
        $Clixml_Configuration = Import-Clixml -Path $ExportedConfigurationLocation
        Remove-Item $ExportedConfigurationLocation
    }
    
    end
    {
        $Clixml_Configuration
    }
}