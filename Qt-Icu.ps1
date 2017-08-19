PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$QtVersion,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$OutputDir,
    [Parameter(Mandatory=$true, Position=3)]
    [string]$VisualStudio,
    [Parameter(Mandatory=$true, Position=4)]
    [string]$Architecture,
    [Parameter(Mandatory=$false, Position=5)]
    [bool]$Static = $false,
    [bool]$NoClean = $false
)
Import-Module "$PSScriptRoot\Common\Process.ps1"

Function CreateMakeSession
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$VisualStudio,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Architecture,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$Version,
        [Parameter(Mandatory=$false, Position=4)]
        [bool]$Static = $false,
        [bool]$NoClean = $false,
        [string]$OverrideDir=""
    )
    $sStatic = "0"
    if($Static)
    {
        $sStatic = "1";
    }
    $sNoClean = "0"
    if($NoClean)
    {
        $sNoClean = "1";
    }
    $Cmd = "-command .\Make.ps1 -Version `"$Version`" -VisualStudio `"$VisualStudio`" -Architecture `"$Architecture`" -Static $sStatic -OverrideOutput `"$OverrideDir`" -NoClean $sNoClean "
    $Exitcode  = Process-StartInline "powershell.exe" -Arguments $Cmd
    if($ExitCode -ne 0)
    {
        throw "Make command failed: powershell.exe $Cmd"
    }
}

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

if(-not (Test-Path Build-ICU))
{
    git clone https://github.com/AndyD87/Build-ICU.git
    if($LASTEXITCODE -ne 0)
    {
        throw "Clone icu failed"
    }
}

cd Build-ICU

CreateMakeSession -VisualStudio $VisualStudio -Architecture $Architecture -Version "59.1" -Static $Static -OverrideDir $OutputDir -NoClean $NoClean

cd $CurrentDir
