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

$oQtVersion = New-Object System.Version($QtVersion)
if($oQtVersion.Major -eq 5)
{
    # look at http://wiki.qt.io/Qt_5.6_Tools_and_Versions
    switch($oQtVersion.Minor)
    {
        6 { $Version = "1.0.2d"; if( $oQtVersion.MajorRevision -gt 0 ){ $Version = "1.0.2g"; } break;}
        7 { $Version = "1.0.2g"; break;}
        8 { $Version = "1.0.2h"; break;}
        9 { $Version = "1.0.2h"; break;}
        default { $Version = "1.0.2h"}
    }
}
else
{
    throw "Wrong Qt Version"
}

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

    if((Process-StartInline "powershell.exe" $Cmd) -ne 0)
    {
        throw "Make command failed: powershell.exe $Cmd"
    }
}

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

if(-not (Test-Path Build-Openssl))
{
    git clone https://github.com/AndyD87/Build-Openssl.git
    if($LASTEXITCODE -ne 0)
    {
        throw "Clone openssl failed"
    }
}

cd Build-Openssl

CreateMakeSession -VisualStudio $VisualStudio -Architecture $Architecture -Version $Version -Static $Static -OverrideDir $OutputDir -NoClean $NoClean

cd $CurrentDir
