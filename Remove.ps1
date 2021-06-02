$Name     = "FightingEntropy"
$Version  = "2021.6.0"
$Company  = "Secure Digits Plus LLC"
$ID       = Get-ItemProperty HKLM:\Software\Policies\$Company\$Name\$Version

# [Registry path values]
$RegPath  = $ID.RegPath

If (!(Test-Path $RegPath))
{
    Write-Host "[!] Missing registry"
}

Else
{
    Remove-Item $RegPath -Recurse -Force -Verbose
}

# [Module path values]
$Main     = $ID.Main
$ModPath  = $ID.Trunk

If (!(Test-Path $Trunk))
{
    Write-Host "[!] Module not found [!]"
}

Else
{
    Remove-Item $ModPath -Recurse -Force -Verbose
}

# [Data path values]
$DataPath = "$Env:ProgramData\$Company\$Name"

If (!(Test-Path $DataPath))
{
    Write-Host "[!] Missing data path [!]"
}

Else
{
    Remove-Item $DataPath -Recurse -Force -Verbose
}
