###############################################################################
# Example to build many different types of one Version
###############################################################################

$Version       = "5.13.2"
$VisualStudios = @("2017", "2015")
$Architectures = @("x64", "x86")
$Static        = $false
$StaticRuntime = $false
$DebugToo      = $true

Set-Content "Log.txt" ""

foreach($VisualStudio in $VisualStudios)
{
    foreach($Architecture in $Architectures)
    {
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime
        if($LASTEXITCODE -eq 0)
        {
            Add-Content "Log.txt" "Succeeded: .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime"
        }
        else
        {
            Add-Content "Log.txt" "Failed: .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime"
        }
        if($DebugToo)
        {
            .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime -DebugBuild $true
            if($LASTEXITCODE -eq 0)
            {
                Add-Content "Log.txt" "Succeeded: .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime -DebugBuild $true"
            }
            else
            {
                Add-Content "Log.txt" "Failed: .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime -DebugBuild $true"
            }
        }
    }
}