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
    [bool]$StaticRuntime = $false,
    [Parameter(Mandatory=$false, Position=7)]
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

$ExitCode       = 0
$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$OutputName     = "qt5-$Version-${VisualStudio}-${Architecture}"
$Output         = "$CurrentDir\$OutputName"
$QtDir          = "$PSScriptRoot\qt5-$Version"

if([string]::IsNullOrEmpty($OverrideOutput))
{
    $Output         = "$CurrentDir\$OutputName"
    if($Static)
    {
        $Output += "_static"
        $OutputName += "_static"
    }

    if($DebugBuild)
    {
        $Output += "_debug"
        $OutputName += "_debug"
    }

    if($StaticRuntime)
    {
        $Output += "_MT"
        $OutputName += "_MT"
    }
}
else
{
    $Output     = $OverrideOutput
}

cd $PSScriptRoot

Try
{
    if($BuildOpenssl)
    {
        $OpensslDir = $Output
        .\Qt5-Openssl.ps1 $Version $OpensslDir $VisualStudio $Architecture $Static -StaticRuntime $StaticRuntime -NoClean $NoClean
    }
    if($BuildICU)
    {
        $IcuDir = $Output
        .\Qt5-Icu.ps1 $Version $IcuDir $VisualStudio $Architecture $Static -StaticRuntime $StaticRuntime -NoClean $NoClean
    }
    Write-Output "******************************"
    if( (Test-Path $QtDir) -eq $false )
    {
        Write-Output "* Download Qt $Version"
        Write-Output "******************************"
        .\Qt5-Get.ps1 $QtDir $Version -OutputTarget $Output
    }
    elseif ($NoClean -eq $false)
    {
        Write-Output "* Cleanup Qt"
        Write-Output "******************************"
        .\Qt5-Clean.ps1 $QtDir
    }
    else
    {
        Write-Output "* NoClean"
        Write-Output "******************************"
    }

    VisualStudio-GetEnv $VisualStudio $Architecture
    .\Qt5-Build.ps1 $QtDir $Output $Static $DebugBuild $AdditionalConfig -StaticRuntime $StaticRuntime -OpenSslDir $OpensslDir -IcuDir $IcuDir
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
