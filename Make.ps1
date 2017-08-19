PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$VisualStudio,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Architecture,
    [Parameter(Mandatory=$true, Position=3)]
    [string]$Version,
    [Parameter(Mandatory=$false, Position=4)]
    [bool]$Static = $false,
    [Parameter(Mandatory=$false, Position=5)]
    [bool]$DebugBuild = $false,
    [Parameter(Mandatory=$false, Position=6)]
    [string]$AdditionalConfig = "",

    [bool]$NoClean = $false,
    [bool]$BuildICU,
    [string]$IcuDir = "",
    [bool]$BuildOpenssl,
    [string]$OpensslDir = ""
)
# Include Common Powershell modules
Import-Module "$PSScriptRoot\Common\All.ps1" -Force

Write-Output "******************************"
Write-Output "* Start Qt Build"
Write-Output "******************************"

$VisualStudioVersionString = "${VisualStudio}-${Architecture}"
if($Static)
{
    $VisualStudioVersionString += "_static"
}
if($DebugBuild)
{
    $VisualStudioVersionString += "_debug"
}

$ExitCode       = 0
$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$OutputName     = "qt-$Version-$VisualStudioVersionString"
$Output         = "$CurrentDir\$OutputName"
$QtDir          = "$PSScriptRoot\qt-$Version"

cd $PSScriptRoot

Try
{
    if($BuildOpenssl)
    {
        $OpensslDir = $Output
        .\Qt-Openssl.ps1 $Version $OpensslDir $VisualStudio $Architecture $Static -NoClean $NoClean
    }
    if($BuildICU)
    {
        $IcuDir = $Output
        .\Qt-Icu.ps1 $Version $IcuDir $VisualStudio $Architecture $Static -NoClean $NoClean
    }
    Write-Output "******************************"
    if( (Test-Path $QtDir) -eq $false )
    {
        Write-Output "* Download Qt $Version"
        .\Qt-Get.ps1 $QtDir $Version -OutputTarget $Output
    }
    elseif ($NoClean -eq $false)
    {
        Write-Output "* Cleanup Qt"
        .\Qt-Clean.ps1 $QtDir
    }
    else
    {
        Write-Output "* NoClean"
    }
    Write-Output "******************************"

    VisualStudio-GetEnv $VisualStudio $Architecture
    .\Qt-Build.ps1 $QtDir $Output $Static $DebugBuild $AdditionalConfig -OpenSslDir $OpensslDir -IcuDir $IcuDir
    Add-Content "$CurrentDir\Build.log" "Success: $OutputName"
}
Catch
{
    $ExitCode       = 1
    Write-Output $_.Exception.Message
    Add-Content "$CurrentDir\Build.log" "Failed: $OutputName"
}
Finally
{
    cd $CurrentDir
    # Always Endup visual studio
    VisualStudio-PostBuild
}

exit $ExitCode
