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
Import-Module "$PSScriptRoot\Process.ps1"

<#
.SYNOPSIS
    Get an Visual Studio Environment for building C/C++ Projects.
.DESCRIPTION
.PARAMETER Version
.PARAMETER Architecture
#>
Function VisualStudio-GetEnv
{
    PARAM(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Version,
        [Parameter(Mandatory=$True, Position=2)]
        [string]$Architecture
    )

    function Invoke-CmdScript {
      param(
        [String] $scriptName
      )
      $cmdLine = """$scriptName"" $args & set"
      & cmd.exe /c $cmdLine |
      select-string '^([^=]*)=(.*)$' | foreach-object {
        $varName = $_.Matches[0].Groups[1].Value
        $varValue = $_.Matches[0].Groups[2].Value
        set-item Env:$varName $varValue
      }
    }

    switch($Architecture)
    {
        "x64" 
        { 
            if([System.Environment]::Is64BitOperatingSystem)
            {
                $Architecture = "amd64" 
            }
            else
            {
                $Architecture = "x86_amd64" 
            }
        }
        "x86"
        { 
            if([System.Environment]::Is64BitOperatingSystem)
            {
                $Architecture = "amd64_x86" 
            }
            else
            {
                $Architecture = "x86" 
            }
        }
        default { throw "Wrong Architecture: $Architecture"}
    }
    $VisualStuioEnvIdentify = $Version + " " + $Architecture

    Write-Output "Choosen Architecture for vcvarsall.bat: $Architecture"

    if( [string]::IsNullOrEmpty($env:VISUAL_STUDIO_ENV_SET) -ne $false -or 
        $VisualStuioEnvIdentify -ne $env:VISUAL_STUDIO_ENV_SET )
    {
        switch($Version)
        {
            "2017" 
            {
                if(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat")
                {
                    Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" $Architecture
                }
                elseif (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat")
                {
                    Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" $Architecture
                }
                else
                {
                    throw "Wether Community nor Professtional Edition of VS2017 was found"
                }
                if($LASTEXITCODE -ne 0)
                {
                    throw "Failed on calling vcvarsall.bat"
                }
            }
            "2015" 
            {
                if(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat")
                {
                    Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" $Architecture
                }
                else
                {
                    throw "Failed on calling vcvarsall.bat"
                }
        
                if($LASTEXITCODE -ne 0)
                {
                    throw "VS2015 not found"
                }
            }
            "2013" 
            {
                if(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat")
                {
                    Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" $Architecture
                }
                else
                {
                    throw "Failed on calling vcvarsall.bat"
                }
        
                if($LASTEXITCODE -ne 0)
                {
                    throw "VS2013 not found"
                }
            }
            "2012" 
            {
                if(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat")
                {
                    Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" $Architecture
                }
                else
                {
                    throw "Failed on calling vcvarsall.bat"
                }
        
                if($LASTEXITCODE -ne 0)
                {
                    throw "VS2012 not found"
                }
            }
        }
        $env:VISUAL_STUDIO_ENV_SET = $VisualStuioEnvIdentify
    }
    else
    {
        Write-Output "Visual Studio Environment already set."
    }
}

Function VisualStudio-GetPostFix
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$VisualStudio,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Architecture,
        [Parameter(Mandatory=$false, Position=3)]
        [bool]$Static = $false,
        [Parameter(Mandatory=$false, Position=4)]
        [bool]$DebugBuild = $false,
        [Parameter(Mandatory=$false, Position=5)]
        [bool]$StaticRuntime = $false
    )
    $OutputName     = "${VisualStudio}_${Architecture}"
    if($Static)
    {
        $OutputName += "_static"
    }
    if($DebugBuild)
    {
        $OutputName += "_debug"
    }
    if($StaticRuntime)
    {
        $OutputName += "_MT"
    }
    return $OutputName
}

Function VisualStudio-PostBuild
{
    Process-StopIfExists "vctip"
    Process-StopIfExists "mspdbsrv"
}