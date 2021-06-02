$Name     = "FightingEntropy"
$Version  = "2021.6.0"
$Company  = "Secure Digits Plus LLC"
$RegPath  = "HKLM:\Software\Policies\$Company\$Name\$Version"
$ID       = Get-Item $RegPath -EA 0

# [Registry path values]
$RegPath  = $ID.RegPath

If (!$RegPath)
{
    Write-Host "[!] Registry path null [!]"
}

ElseIf(!(Test-Path $RegPath))
{
    Write-Host "[!] Registry path invalid [!]"
}

Else
{
    Remove-Item $RegPath -Recurse -Force -Verbose
}

# [Module path values]
$Main     = $ID.Main
$ModPath  = $ID.Trunk

If(!$ModPath)
{
    Write-Host "[!] Module path null [!]"
}

ElseIf (!(Test-Path $Trunk))
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
