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
    [string]$AdditionalConfig = "",

    [string]$IcuDir,
    [string]$OpenSslDir
)

Python-GetEnv 2.7 -Mandatory
Ninja-GetEnv
Perl-GetEnv

# Multiprocessor for building faster
$env:CL      = "/MP"

$Config =  "-opensource -confirm-license -nomake examples -nomake tests "
if($OutputTarget -ne "")
{
    $Config += "-prefix $OutputTarget "
}

if($Static)
{
    $Config += "-static -static-runtime "
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
    $env:INCLUDE = $env:INCLUDE+ ";$IcuDir\include"
    $env:LIB     = $env:LIB    + ";$IcuDir\lib"
    $env:LIB     = $env:LIB    + ";$IcuDir\bin"
    $env:PATH    = $env:PATH   + ";$IcuDir\bin"
    $env:PATH    = $env:PATH   + ";$IcuDir\lib"
    $Config += "-icu -I $IcuDir\include -L $IcuDir\lib "
}

$Config += $AdditionalConfig

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

cd $QtDir

Write-Output "******************************"
Write-Output "* Start Configuration"
Write-Output "******************************"
Process-StartInlineAndThrow "cmd" "/C configure.bat $Config"

Write-Output "******************************"
Write-Output "* Start Build"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake"

Write-Output "******************************"
Write-Output "* Start Install"
Write-Output "******************************"
Process-StartInlineAndThrow "nmake" "install"

cd $CurrentDir