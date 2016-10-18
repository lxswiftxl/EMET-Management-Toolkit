function Find-EmetProtectedApplication()
{
    param(
    $EmetApplicationPath, # Now supports lists of paths
    $EmetConfiguration, # This must be the configuration provided by Get-EmetConfiguration
    $DrivesToSearch = ((GET-WMIOBJECT –query “SELECT * from win32_logicaldisk where DriveType = '3'”).name)
    )
    # 1.) Recursing through all the applicaiton configurations and getting the paths
    # 2.) For each drive found we will creating a application path that can be searched by get-childitems
    # 3.) EMET doesnt have consistant path ending on its variables so we parse and correct as needed
    # 4.) The formated paths are saved as they are created
    
    if ($EmetConfiguration)
    {
        $Searchable_Application_Paths = @()
        foreach ($APP in $EmetConfiguration.EMET.EMET_Apps.AppConfig)
        {
            foreach ($DRIVE in $DrivesToSearch)
            {
                if ($APP.Path.EndsWith("*"))
	            {
                    $app_path = $DRIVE + "\" + $APP.Path + "\" + $APP.Executable
                }   
                else
	            {
                    $app_path = $DRIVE + "\" + $APP.Path + "*\" + $APP.Executable
                }
                $Searchable_Application_Paths += $app_path
            }
        }
        
        $Executables = @()
        if($Searchable_Application_Paths)
        {
            foreach ($PATH in $Searchable_Application_Paths)
            {
                # $Executables is a list of file objects returned by the search.
                $Executables += (Get-ChildItem -Path $PATH)
            }
        }
    }

    if($EmetApplicationPath)
    {
        $Executables = @()
        foreach($PATH in $EmetApplicationPath)
        {
            $Executables += (Get-ChildItem -Path $PATH)
        }
    }
    return $Executables
}