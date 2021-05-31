Function Remove-FEModule
{
    [CmdLetBinding()]
    Param([Parameter(Mandatory)][Object]$Version)
    
    If ( $Version -match "(\d{4}\.\d+\.\d+)" )
    {
        "Secure Digits Plus LLC\FightingEntropy" | % {

            ($Env:PSModulePath -Split ";" | ? { Test-Path $_ } | Get-ChildItem | ? Name -match FightingEntropy | % FullName)
            Get-ChildItem -Path "$env:ProgramData\$_"        | ? Name -match $Version | % FullName
            Get-Item      -Path "HKLM:\SOFTWARE\Policies\$_" | ? Name -match $Version
        
        } | Remove-Item -Verbose -Recurse
    }
}
