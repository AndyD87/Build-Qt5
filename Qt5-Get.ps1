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