Function Get-EmtConfiguration()
{
    param(
    [string] $ConfigurationFileLocation = (join-path ($PSScriptRoot | Split-Path -Parent) "Config\EMT_Config.json")
    )

    $EMT_Configuration = Get-Content -Path $ConfigurationFileLocation -Raw | ConvertFrom-Json

    $EMT_Configuration | add-member -MemberType NoteProperty -Name EmetParentDirectory -Value ((Get-ItemPropertyValue -Name ImagePath -path $EMT_Configuration.EmetRegistryKeyPath).split('"')[1] | Split-Path -Parent)

    $EMT_Configuration | add-member -MemberType NoteProperty -Name Time_To_Parse_After -Value ([datetime]::Now.AddHours(-1 * $EMT_Configuration.HoursOfLogsToParse))

    $EMT_Configuration | add-member -MemberType NoteProperty -Name Configuration_Location -Value ($EMT_Configuration.EmetParentDirectory + '\Deployment\Protection Profiles\' + $EMT_Configuration.ConfigurationFileName)

    $EMT_Configuration | add-member -MemberType NoteProperty -Name EMET_Conf_Binary_Location -Value (Join-Path $EMT_Configuration.EmetParentDirectory 'EMET_Conf.exe')

    $EMT_Configuration | add-member -MemberType NoteProperty -Name Configuration_File_Creation_Time -Value ([datetime](Get-ItemProperty -Path $EMT_Configuration.Configuration_Location).CreationTime)

    $EMT_Configuration | add-member -MemberType NoteProperty -Name EMET_Application_Registry -Value (Join-Path $EMT_Configuration.EmetParentDirectory $EMT_Configuration.ApplicationRegistryFileName)

    $EMT_Configuration | add-member -MemberType NoteProperty -Name In_Grace_Period -Value $false

    if ([datetime]::Now -lt $EMT_Configuration.Configuration_File_Creation_Time.AddDays($EMT_Configuration.Grace_Period))
    {
        $EMT_Configuration.In_Grace_Period = $true
    }

    return $EMT_Configuration
}