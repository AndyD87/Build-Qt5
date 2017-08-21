PARAM(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$QtDir
)

$CurrentDir = ((Get-Item -Path ".\" -Verbose).FullName)

cd $QtDir

git submodule foreach --recursive "git clean -dfx"
if($LASTEXITCODE -ne 0)
{
    throw "git submodule foreach --recursive `"git clean -dfx`""
}
git clean -dfx
if($LASTEXITCODE -ne 0)
{
    throw "git clean -dfx"
}

cd $CurrentDir