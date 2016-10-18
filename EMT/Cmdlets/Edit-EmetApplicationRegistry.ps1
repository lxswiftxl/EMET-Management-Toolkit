function Edit-EmetApplicationRegistry()
{
    Param(
    # This default is not good enough. The Path property is not always showing up = /
    [string]$ApplicationRegistryLocation = (join-path (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname "EMET_Application_Registry.xml"),
    [Parameter(Mandatory=$true)]
    [ValidateSet("Add", "Remove")]
    [string]$Action,
    [Parameter(Mandatory=$true)]
    $Application
    )

    $Application_Registry = Import-Clixml -Path $ApplicationRegistryLocation

    if ($Action -eq "Add")
    {
        foreach ($APP in $Application)
        {
            $App_Found_In_Registry = $false
            foreach ($REGISTEREDAPP in $Application_Registry)
            {
                if ($REGISTEREDAPP.VersionInfo.File -eq $APP.VersionInfo.File -and 
                    $REGISTEREDAPP.VersionInfo.FileVersion -eq $APP.VersionInfo.FileVersion)   
                {
                    $App_Found_In_Registry = $true               
                }
            }
         
            if ($App_Found_In_Registry -eq $false)
            {
                # If the file object doesnt have the firstseen property add it
                if (-not($APP.FirstSeen))
                {
                    $APP | Add-Member @{FirstSeen=[datetime]::Now} -Force 
                }
                # Add this object to the list of other objects in the registry
                $Application_Registry += $APP
            }
        }
        Export-Clixml -Path $ApplicationRegistryLocation -InputObject $Application_Registry -Force
    }
    

    # This needs to be a seperate module for adding and removing.
    # Removing could be done in many ways like Regex, *chrome.exe, or full path.
    # Then again I could try to match something in the object by all of the above.
    # I would rather flag the kind of object you are using but i am not sure how
    # to make some perameters relient on others being set first
    if ($Action -eq "Remove")
    {
        "Not functional yet" | Out-GridView
    }
}