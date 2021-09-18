$Name       = "FightingEntropy"
$Version    = "2021.8.0"
$Company    = "Secure Digits Plus LLC"

$RegPath    = "HKLM:\Software\Policies\$Company\$Name\$Version"
If(!(Test-Path $RegPath))
{
    Write-Host "[!] Registry path invalid [!]"
}
Else
{
    $ID      = Get-ItemProperty $RegPath
    If(-not $ID)
    {
        Write-Host "[!] Registry properties missing [!]"
    }
    Else
    {
        $Main    = $ID.Main
        $ModPath = $ID.Trunk
        Remove-Item $RegPath -Recurse -Force -Verbose
     }
}

If(-not $ModPath)
{
    Write-Host "[!] Module path null [!]"
}

ElseIf (!(Test-Path $ModPath))
{
    Write-Host "[!] Module path invalid [!]"
}

Else
{
    Remove-Item $ModPath -Recurse -Force -Verbose
}

# [Data path values]
$DataPath = "$Env:ProgramData\$Company\$Name"

If(!$DataPath)
{
    Write-Host "[!] Data path null [!]"   
}

ElseIf (!(Test-Path $DataPath))
{
    Write-Host "[!] Data path invalid [!]"
}

Else
{
    Remove-Item $DataPath -Recurse -Force -Verbose
}
