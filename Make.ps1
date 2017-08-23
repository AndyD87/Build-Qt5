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
    [bool]$BuildICU = $false,
    [string]$IcuDir = "",
    [bool]$BuildOpenssl = $false,
    [string]$OpensslDir = "",
    [string]$OverrideOutput = ""
)
# Include Common Powershell modules
Import-Module "$PSScriptRoot\Common\All.ps1" -Force

Write-Output "******************************"
Write-Output "* Start Qt Build"
Write-Output "******************************"

$ExitCode       = 0
$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$OutputName     = "qt5-$Version"
$Output         = "$CurrentDir\$OutputName"
$QtDir          = "$PSScriptRoot\$OutputName"

if([string]::IsNullOrEmpty($OverrideOutput))
{
    $VisualStudioPostFix = VisualStudio-GetPostFix -VisualStudio $VisualStudio -Architecture $Architecture -Static $Static -DebugBuild $DebugBuild -StaticRuntime $StaticRuntime
    $OutputName += "-$VisualStudioPostFix"
    $Output     =  "$CurrentDir\$OutputName"
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
