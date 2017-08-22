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
Import-Module "$PSScriptRoot\Web.ps1"

Function Git-GetEnv
{
    if(Get-Command git -ErrorAction SilentlyContinue)
    {
        Write-Output "git already in PATH"
    }
    elseif((Test-Path "C:\Program Files\Git\bin"))
    {
        $env:PATH += ";C:\Program Files\Git\bin"
        Write-Output "git found at C:\Program Files\Git\bin"
    }
    ## Currently no portable version availabe, but it will follow soon
    #elseif($Mandatory)
    #{
    #    Write-Output "Mandatory git not found, try to download portable Version"
    #    $TempZip   = "$PSScriptRoot\Tools\git.zip"
    #    $Target    = "$PSScriptRoot\Tools\git"
    #    $TargetBin = "$Target"
    #    Import-Module "$PSScriptRoot\Web.ps1" -Force
    #    Import-Module "$PSScriptRoot\Compress.ps1" -Force
    #    if(-not (Test-Path "$PSScriptRoot\Tools"))
    #    {
    #        New-Item -ItemType Directory -Path "$PSScriptRoot\Tools"
    #    }
    #    if(Web-Download "http://mirror.adirmeier.de/projects/ThirdParty/git/..../git.portable.zip" $TempZip)
    #    {
    #        Compress-Unzip $TempZip $Target
    #        Remove-Item $TempZip
    #        Write-Output "git now available at TargetBin"
    #        $env:PATH += ";$TargetBin"
    #    }
    #    else
    #    {
    #        throw( "git not found, download failed" )
    #    }
    #}
    elseif($Mandatory)
    {
        throw "No git found"
    }
    else
    {
        Write-Output "No git found"
    }
}

Function Git-Execute
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Arguments
    )
    if(-not(Get-Command git -ErrorAction SilentlyContinue))
    {
        Git-GetEnv -Mandatory
    }
    Process-StartInlineAndThrow "git" "$Arguments"
}

Function Git-Clone
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Source,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Target
    )
    Git-Execute "clone `"$Source`" `"$Target`""
}

Function Git-Checkout
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Target,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Checkout
    )
    
    $CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

    cd $Target

    Git-Execute "checkout `"$Source`""

    cd $CurrentDir
}

Function Git-Clean
{
    PARAM(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Target
    )
    
    $CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

    cd $Target

    Git-Execute "submodule foreach --recursive `"git clean -dfx`""
    Git-Execute "clean -dfx"

    cd $CurrentDir
}