if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    write-host "
Not running with administrative priviledges.
This script will not be able to remove the scheduled
task, and event logs related to EMT without admin
priviledges.
"
    exit
}

# This needs change to pull the names from the configuration file 
# or some other location so that the uninstall script is resilient to change
schtasks.exe /DELETE /TN "EMET Analyzer" /F
schtasks.exe /DELETE /TN "EMET Event Converter" /F

# The name of the folder should be pulled from the .psd1 file 
# to get the name of the module
Remove-Item -Path (join-path $env:PSModulePath.split(";")[1] "EMT") -Recurse -Force

# The log name should be pulled from the configuration file to
# make the uninstaller resilent to change
Remove-EventLog -LogName Microsoft-Windows-EMET-JSON/Operational