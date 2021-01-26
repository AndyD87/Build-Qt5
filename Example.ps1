###############################################################################
# Example to build many different types of one Version
###############################################################################

$Version       = "5.15.2"
$VisualStudios = @("2015", "2017", "2019")
$Architectures = @("x64", "x86")
$Static        = $false
$StaticRuntime = $false
$DebugToo      = $true
$DoPackage     = $true

Set-Content "Build.log" ""

$global:oAllEnv = Get-ChildItem Env:

function CleanupEnv
{
    $oCurrentEnv = Get-ChildItem Env:
    foreach($oCurrent in $oCurrentEnv)
    {
        $bFound = $false
        foreach($oAll in $oCurrentEnv)
        {
            if($oAll.Name -eq $oCurrent.NAME)
            {
                $bFound = $true
                break
            }
        }
        if($bFound)
        {
            [System.Environment]::SetEnvironmentVariable($oAll.Name, $oAll.Value)
        }
        else
        {
            Remove-Item ("Env:\" + $oCurrent.Name)
        }
    }
}

foreach($VisualStudio in $VisualStudios)
{
    foreach($Architecture in $Architectures)
    {
        CleanupEnv
        .\Make.ps1 -VisualStudio $VisualStudio -Version $Version -Architecture $Architecture -Static $Static -StaticRuntime $StaticRuntime -DoPackage $DoPackage
        if($LASTEXITCODE -eq 0)
        {
            Add-Content "Build.log" "Succeeded"
        }
        else
        {
            Add-Content "Build.log" "Failed"
        }
    }
}
