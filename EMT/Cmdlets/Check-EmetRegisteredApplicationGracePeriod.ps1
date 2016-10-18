function Check-EmetRegisteredApplicationGracePeriod()
{
    Param(
    [Parameter(Mandatory=$true)]
    $EmetApplicationRegistry,

    [Parameter(Mandatory=$true)]
    [int]$GracePeriod

    )
    
    begin
    {
        $ApplicationsInGracePeriod = @()
    }
    
    process
    {
        foreach ($RegisteredApplication in $EmetApplicationRegistry)
        {
            if ($RegisteredApplication.Firstseen -gt [datetime]::now.AddDays(-$GracePeriod))
            {
                $ApplicationsInGracePeriod += $RegisteredApplication
            }
        }
    }

    end
    {
        return $ApplicationsInGracePeriod
    }
}