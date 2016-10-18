$Cmdlets_Location = Join-Path $PSScriptRoot "Cmdlets"

$Cmdlets = Get-ChildItem -Path $Cmdlets_Location

$Configuration_Location = join-path $PSScriptRoot "Config"

# import all files in the Cmdlets directory
foreach ($Cmdlet in $Cmdlets){
    . $Cmdlet.FullName
}