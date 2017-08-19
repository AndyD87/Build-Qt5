
Function Nasm-GetEnv
{
    PARAM(
        [switch]$Mandatory
    )

    if(Get-Command nasm.exe -ErrorAction SilentlyContinue)
    {
        Write-Output "NASM already in PATH"
    }
    elseif((Test-Path "C:\Program Files\NASM"))
    {
        $env:PATH += "C:\Program Files\NASM"
        Write-Output "NASM found at C:\Program Files\NASM"
    }
    elseif($Mandatory)
    {
        throw( "No NASM found" )
    }
    else
    {
        Write-Output "No NASM found"
    }
}
