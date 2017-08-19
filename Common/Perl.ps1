
Function Perl-GetEnv
{
    PARAM(
        [switch]$Mandatory
    )

    if(Get-Command perl.exe -ErrorAction SilentlyContinue)
    {
        Write-Output "Perl already in PATH"
    }
    elseif((Test-Path "C:\Tools\Perl\bin"))
    {
        $env:PATH += ";C:\Tools\Perl\bin"
        Write-Output "Perl found at C:\Tools\Perl\bin"
    }
    elseif((Test-Path "C:\Tools\Perl\perl\bin"))
    {
        $env:PATH += ";C:\Tools\Perl\perl\bin"
        Write-Output "Perl found at C:\Tools\Perl\perl\bin"
    }
    elseif($Mandatory)
    {
        throw( "No Perl found" )
    }
    else
    {
        Write-Output "No Perl found";
    }
}