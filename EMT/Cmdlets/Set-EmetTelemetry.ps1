function Set-EmetTelemetry()
{
    Param(
    $EmetDirectory = (get-item (Get-ItemPropertyValue -Name ImagePath -path HKLM:\SYSTEM\CurrentControlSet\Services\EMET_Service).split('"')[1]).Directory.fullname,
    $LocalTelemetryPath = $EmetDirectory,
    $EmetRegistryLocation = "HKLM:\SOFTWARE\Microsoft\EMET",
    $EmetConfLocation = "$EmetDirectory\EMET_Conf.exe",
    
    [ValidateSet(   'MiniDumpNormal',
                    'MiniDumpWithDataSegs',
                    'MiniDumpWithFullMemory',
                    'MiniDumpWithHandleData',
                    'MiniDumpFilterMemory',
                    'MiniDumpScanMemory',
                    'MiniDumpWithUnloadedModules',
                    'MiniDumpWithIndirectlyReferencedMemory',
                    'MiniDumpFilterModulePaths',
                    'MiniDumpWithProcessThreadData',
                    'MiniDumpWithPrivateReadWriteMemory',
                    'MiniDumpWithoutOptionalData',
                    'MiniDumpWithFullMemoryInfo',
                    'MiniDumpWithThreadInfo',
                    'MiniDumpWithCodeSegs',
                    'MiniDumpWithoutAuxiliaryState',
                    'MiniDumpWithFullAuxiliaryState',
                    'MiniDumpWithPrivateWriteCopyMemory',
                    'MiniDumpIgnoreInaccessibleMemory',
                    'MiniDumpWithTokenInformation',
                    'MiniDumpWithModuleHeaders',
                    'MiniDumpFilterTriage',
                    'MiniDumpValidTypeFlags'
                    )]
    $MiniDumpSettings = 'MiniDumpNormal'
    )

    $Compiled_MiniDumpSetting = 0
    foreach ($MiniDumpSetting in $MiniDumpSettings)
    {
        switch ($MiniDumpSetting) 
        {
              'MiniDumpNormal'                          {$MiniDumpSetting = 0x00000000}
              'MiniDumpWithDataSegs'                    {$MiniDumpSetting = 0x00000001}
              'MiniDumpWithFullMemory'                  {$MiniDumpSetting = 0x00000002}
              'MiniDumpWithHandleData'                  {$MiniDumpSetting = 0x00000004}
              'MiniDumpFilterMemory'                    {$MiniDumpSetting = 0x00000008}
              'MiniDumpScanMemory'                      {$MiniDumpSetting = 0x00000010}
              'MiniDumpWithUnloadedModules'             {$MiniDumpSetting = 0x00000020}
              'MiniDumpWithIndirectlyReferencedMemory'  {$MiniDumpSetting = 0x00000040}
              'MiniDumpFilterModulePaths'               {$MiniDumpSetting = 0x00000080}
              'MiniDumpWithProcessThreadData'           {$MiniDumpSetting = 0x00000100}
              'MiniDumpWithPrivateReadWriteMemory'      {$MiniDumpSetting = 0x00000200}
              'MiniDumpWithoutOptionalData'             {$MiniDumpSetting = 0x00000400}
              'MiniDumpWithFullMemoryInfo'              {$MiniDumpSetting = 0x00000800}
              'MiniDumpWithThreadInfo'                  {$MiniDumpSetting = 0x00001000}
              'MiniDumpWithCodeSegs'                    {$MiniDumpSetting = 0x00002000}
              'MiniDumpWithoutAuxiliaryState'           {$MiniDumpSetting = 0x00004000}
              'MiniDumpWithFullAuxiliaryState'          {$MiniDumpSetting = 0x00008000}
              'MiniDumpWithPrivateWriteCopyMemory'      {$MiniDumpSetting = 0x00010000}
              'MiniDumpIgnoreInaccessibleMemory'        {$MiniDumpSetting = 0x00020000}
              'MiniDumpWithTokenInformation'            {$MiniDumpSetting = 0x00040000}
              'MiniDumpWithModuleHeaders'               {$MiniDumpSetting = 0x00080000}
              'MiniDumpFilterTriage'                    {$MiniDumpSetting = 0x00100000}
              'MiniDumpValidTypeFlags'                  {$MiniDumpSetting = 0x001fffff}
        }

        $Compiled_MiniDumpSetting += $MiniDumpSetting
    }

    $Compiled_MiniDumpSetting = [Convert]::ToString($Compiled_MiniDumpSetting, 16)

    if (Get-ItemProperty -Path $EmetRegistryLocation -Name LocalTelemetryPath)
    {
        Set-ItemProperty -Path $EmetRegistryLocation -Name LocalTelemetryPath -Value $LocalTelemetryPath
    }
    else
    {
        New-ItemProperty -Path $EmetRegistryLocation -Name LocalTelemetryPath -Value $LocalTelemetryPath
    }
    
    if (Get-ItemProperty -Path $EmetRegistryLocation -Name ReportingSettings)
    {
        Set-ItemProperty -Path $EmetRegistryLocation -Name ReportingSettings -Value $Compiled_MiniDumpSetting
    }
    else
    {
        New-ItemProperty -Path $EmetRegistryLocation -Name ReportingSettings -Value $Compiled_MiniDumpSetting -PropertyType DWORD
    }
}