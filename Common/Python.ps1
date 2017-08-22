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
Import-Module "$PSScriptRoot\Process.ps1" -Force

$Portable27Download  = "http://mirror.adirmeier.de/projects/ThirdParty/WinPython/binaries/2.7.13.1/WinPython.32bit.zip"
$Portable27TargetBin = "$PortableTarget\python-2.7.13"

$Portable36Download  = "http://mirror.adirmeier.de/projects/ThirdParty/WinPython/binaries/2.7.13.1/WinPython.32bit.zip"
$Portable36TargetBin = "$PortableTarget\python-2.7.13"

$PortableToolsDir  = "$PSScriptRoot\Tools"
$PortableTarget    = "$PortableToolsDir\WinPython"
$PortableTempZip   = "$PortableToolsDir\WinPython.zip"


Function Python-GetEnv
{
    PARAM(
        [Parameter(Mandatory=$False, Position=1)]
        [string]$Version = "3.6",
        [switch]$Mandatory
    )

    $VTarget = New-Object System.Version($Version)
    if($VTarget.Major -eq 2)
    {
        if(Get-Command python.exe -ErrorAction SilentlyContinue)
        {
            Write-Output "Python already in PATH"
        }
        # Test default location from BuildSystem
        elseif((Test-Path "C:\Tools\Python27"))
        {
            $env:PATH += ";C:\Tools\Python27"
            Write-Output "Python found at C:\Tools\Python27"
        }
        # Test default location from orignal Python-Setup 2.7.x
        elseif((Test-Path "C:\Python27"))
        {
            $env:PATH += ";C:\Python27"
            Write-Output "Python found at C:\Python27"
        }
        # Check for Portable Version downloaded
        elseif((Test-Path $script:Portable27TargetBin))
        {
            $env:PATH += ";$script:Portable27TargetBin"
            Write-Output "Python found at $script:Portable27TargetBin"
        }
        elseif($Mandatory)
        {
            Write-Output "Mandatory Python not found, try to download portable Version"
            Import-Module "$PSScriptRoot\Web.ps1" -Force
            Import-Module "$PSScriptRoot\Compress.ps1" -Force

            if(-not (Test-Path $script:PortableToolsDir))
            {
                New-Item -ItemType Directory -Path $script:PortableToolsDir
            }
            if(Web-Download $script:Portable27Download $script:PortableTempZip)
            {
                Compress-Unzip $script:PortableTempZip $script:PortableTarget
                Remove-Item $script:PortableTempZip
                $env:PATH += ";$script:Portable27TargetBin"
                Write-Output "Python now available at TargetBin"
            }
            else
            {
                throw( "Python not found, download failed" )
            }
        }
        else
        {
            Write-Output "No Python found"
        }
    }

    if($VTarget.Major -eq 3)
    {
        if(Get-Command python.exe -ErrorAction SilentlyContinue)
        {
            Write-Output "Python already in PATH"
        }
        # Test default location from BuildSystem
        elseif((Test-Path "C:\Tools\Python36"))
        {
            $env:PATH += ";C:\Tools\Python36"
            Write-Output "Python found at C:\Tools\Python36"
        }
        # Test default location from orignal Python-Setup 3.6.x
        elseif((Test-Path "C:\Program Files\Python36"))
        {
            $env:PATH += ";C:\Program Files\Python36"
            Write-Output "Python found at C:\Program Files\Python36"
        }
        # Test default location from orignal Python-Setup 3.4.x
        elseif((Test-Path "C:\Program Files\Python34"))
        {
            $env:PATH += ";C:\Program Files\Python34"
            Write-Output "Python found at C:\Program Files\Python34"
        }
        # Check for Portable Version downloaded
        elseif((Test-Path $script:Portable36TargetBin))
        {
            $env:PATH += ";$script:Portable36TargetBin"
            Write-Output "Python found at $script:Portable36TargetBin"
        }
        elseif($Mandatory)
        {
            Write-Output "Mandatory Python not found, try to download portable Version"
            Import-Module "$PSScriptRoot\Web.ps1" -Force
            Import-Module "$PSScriptRoot\Compress.ps1" -Force

            if(-not (Test-Path $script:PortableToolsDir))
            {
                New-Item -ItemType Directory -Path $script:PortableToolsDir
            }
            if(Web-Download $script:Portable36Download $script:PortableTempZip)
            {
                Compress-Unzip $script:PortableTempZip $script:PortableTarget
                Remove-Item $script:PortableTempZip
                $env:PATH += ";$script:Portable36TargetBin"
                Write-Output "Python now available at TargetBin"
            }
            else
            {
                throw( "Python not found, download failed" )
            }
        }
        else
        {
            Write-Output "No Python found"
        }
    }
}
