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
    [string]$QtDir,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Version = "",
    [Parameter(Mandatory=$false, Position=3)]
    [string]$OutputTarget,
    [Parameter(Mandatory=$false, Position=4)]
    [bool]$Static = $false
)
Import-Module "$PSScriptRoot\Common\Process.ps1"
Import-Module "$PSScriptRoot\Common\Perl.ps1"
Import-Module "$PSScriptRoot\Common\Git.ps1"

Git-GetEnv -Mandatory
Perl-GetEnv -Mandatory

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

Git-Clone "git://code.qt.io/qt/qt5.git" $QtDir

cd $QtDir

if([string]::IsNullOrEmpty($Version) -ne $false)
{
    Git-Checkout $QtDir "checkout v$Version"
}

if((Process-StartInline "perl" "init-repository") -ne 0)
{
    throw "Failed: perl init-repository"
}

cd $CurrentDir