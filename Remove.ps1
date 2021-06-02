$Name     = "FightingEntropy"
$Version  = "2021.6.0"
$Company  = "Secure Digits Plus LLC"

# [Default Path]
$Default  = $Env:PSModulePath -Split ";" | ? { (Test-Path $_) -and (Get-ChildItem $_ | ? Name -match FightingEntropy) }
If (!$Default)
{
    Write-Host "[!] Missing module"
}
Else
{
    Remove-Item "$Default\FightingEntropy\$Version" -Recurse -Force -Verbose
}

# [Registry Path]
$RegPath  = "HKLM:\Software\Policies\$Company\$Name\$Version"
If (!(Test-Path $RegPath))
{
    Write-Host "[!] Missing registry"
}
Else
{
    Remove-Item $RegPath -Recurse -Force -Verbose
}

# [Module path]
$ModPath = $Default\FightingEntropy 

If (!(Test-Path $ModPath))
{
    Write-Host "[!] Missing module path"
}

Remove-Item $ModPath -Recurse -Force -Verbose

# [Data path]
Remove-Item "$Env:ProgramData\$Company\$Name" -Recurse -Force
