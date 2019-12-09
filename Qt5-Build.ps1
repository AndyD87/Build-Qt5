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
    [string]$QtDir = "",
    [Parameter(Mandatory=$false, Position=2)]
    [string]$OutputTarget = "",
    [Parameter(Mandatory=$false, Position=3)]
    [bool]$Static = $false,
    [Parameter(Mandatory=$false, Position=4)]
    [bool]$DebugBuild = $false,
    [Parameter(Mandatory=$false, Position=5)]
    [bool]$StaticRuntime = $false,
    [Parameter(Mandatory=$false, Position=6)]
    [string]$AdditionalConfig = "",

    [string]$IcuDir,
    [string]$OpenSslDir
)

Import-Module "$PSScriptRoot\Common\Perl.ps1" -Force
Import-Module "$PSScriptRoot\Common\Python.ps1" -Force
Import-Module "$PSScriptRoot\Common\WinFlexBison.ps1" -Force

WinFlexBison-GetEnv -Mandatory
Python-GetEnv 2.7 -Mandatory
# Qt base uses Perl scripts
Perl-GetEnv -Mandatory

# Multiprocessor for building faster
$env:CL      = "/MP"

$Config =  "-opensource -confirm-license -nomake examples -nomake tests "
if($OutputTarget -ne "")
{
    $Config += "-prefix $OutputTarget "
}

if($Static)
{
    $Config += "-static "

    if($StaticRuntime)
    {
        $Config += "-static-runtime "
    }
}
else
{
    if($StaticRuntime)
    {
        throw "Qt requires -static for -static-runtime"
    }
}

###############################################################################
# Setup OpenSSL if exists
###############################################################################
if(-not [string]::IsNullOrEmpty($OpenSslDir))
{
    $env:INCLUDE = $env:INCLUDE+ ";$OpenSslDir\include"
    $env:LIB     = $env:LIB    + ";$OpenSslDir\lib"
    $env:OPENSSL_LIBS="-L $OpenSslDir\lib -lssleay32 -llibeay32 -lGdi32 -lUser32"
    $Config += " -openssl -I $OpenSslDir\include -L $OpenSslDir\lib "
}

###############################################################################
# Setup ICU if exists
###############################################################################
if(-not [string]::IsNullOrEmpty($IcuDir))
{
    if($Static)
    {
        throw "Static ICU is not working on static Qt build"
    }
    else
    {
        $env:INCLUDE = $env:INCLUDE+ ";$IcuDir\include"
        $env:LIB     = $env:LIB    + ";$IcuDir\lib"
        $env:LIB     = $env:LIB    + ";$IcuDir\bin"
        $env:PATH    = $env:PATH   + ";$IcuDir\bin"
        $env:PATH    = $env:PATH   + ";$IcuDir\lib"
        $Config += "-icu -I $IcuDir\include -L $IcuDir\lib "
    }
}

$Config += $AdditionalConfig

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

cd $QtDir

Write-Output "******************************"
Write-Output "* Start Configuration"
Write-Output "******************************"
$iExitCode = Process-StartInline "cmd.exe" "/C configure.bat $Config"
if( $iExitCode -ne 1 -and 
    $iExitCode -ne 0
)
{
    throw "Configure failed with: configure.bat $Config"
}

Write-Output "******************************"
Write-Output "* Start Build"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake"

Write-Output "******************************"
Write-Output "* Start Install"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake" "install"

cd $CurrentDir