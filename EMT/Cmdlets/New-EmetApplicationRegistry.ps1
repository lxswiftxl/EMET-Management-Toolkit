function New-EmetApplicationRegistry()
{
    param(
    [parameter(Mandatory=$true)]
    $EmetProtectedApplications,

    [string]$ApplicationRegistryLocation = (join-path (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname "EMET_Application_Registry.xml")
    )
    
    begin
    {
        $Resulting_List = @()
    }

    process
    {
        foreach ($APPLICATION in $EmetProtectedApplications){
        
            if (-not($APPLICATION.FirstSeen)){

                $APPLICATION | Add-Member @{FirstSeen=[datetime]::Now} -Force 
            }

            $Resulting_List += $APPLICATION
        }
    }
    
    end
    {
        Export-Clixml -Path $ApplicationRegistryLocation -InputObject $Resulting_List
    }
}