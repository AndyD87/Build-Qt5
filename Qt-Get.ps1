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
Import-Module "$PSScriptRoot\Common\Perl.ps1"
Perl-GetEnv -Mandatory

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

git clone git://code.qt.io/qt/qt5.git $QtDir

cd $QtDir

if([string]::IsNullOrEmpty($Version) -ne $false)
{
    git checkout v$Version
    if($LASTEXITCODE -ne 0)
    {
        throw "Failed: git checkout v$Version"
    }
}
perl init-repository
if($LASTEXITCODE -ne 0)
{
    throw "Failed: perl init-repository"
}

cd $CurrentDir