function Update-EmetApplicationRegistry()
{
    Param(
    [string]$ApplicationRegistryLocation = (Join-Path (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname "EMET_Application_Registry.xml"),
    [string[]]$ProtectedApplications,
    [switch]$SearchFileSystemForApplications = $true
    )
    
    # If the registry exists we will 
    if (test-path $ApplicationRegistryLocation)
    {
        if ($ProtectedApplications)
        {
            Edit-EmetApplicationRegistry -Action Add -Application $ProtectedApplications
        }
        
        if ($SearchFileSystemForApplications)
        {
            Edit-EmetApplicationRegistry -Action Add -Application (Find-EmetProtectedApplication -EmetConfiguration (Get-EmetConfiguration))
        } 
    }
    else
    {
        if ($ProtectedApplications)
        {
            New-EmetApplicationRegistry -EmetProtectedApplications $ProtectedApplications
        }
        
        if ($SearchFileSystemForApplications)
        {
            New-EmetApplicationRegistry -EmetProtectedApplications (Find-EmetProtectedApplication -EmetConfiguration (Get-EmetConfiguration))
        }
    }
}