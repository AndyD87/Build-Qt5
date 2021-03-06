##
# This file is part of Powershell-Common, a collection of powershell-scrips
# 
# Copyright (c) 2017 Andreas Dirmeier
# License   MIT
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##
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
    [Parameter(Mandatory=$false, Position=6)]
    [bool]$StaticRuntime = $false,
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
    $sStaticRuntime = "0"
    if($StaticRuntime)
    {
        $sStaticRuntime = "1";
    }
    $sNoClean = "0"
    if($NoClean)
    {
        $sNoClean = "1";
    }
    $Cmd = "-command .\Make.ps1 -Version `"$Version`" -VisualStudio `"$VisualStudio`" -Architecture `"$Architecture`" -Static $sStatic -StaticRuntime $sStaticRuntime -OverrideOutput `"$OverrideDir`" -NoClean $sNoClean "

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
