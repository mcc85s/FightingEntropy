$Name     = "FightingEntropy"
$Version  = "2021.6.0"
$Company  = "Secure Digits Plus LLC"

# [Default Path]
$Default  = $Env:PSModulePath -Split ";" | ? { (Test-Path $_) -and (Get-ChildItem $_ | ? Name -match FightingEntropy) }
If (!$Default)
{
    Write-Host "[!] Missing module"
}

# [Registry Path]
$RegPath  = "HKLM:\Software\Policies\$Company\$Name\$Version"
If (!(Test-Path $RegPath))
{
    Write-Host "[!] Missing registry"
}

# [Property Value]
$RegValue = Get-ItemProperty $RegPath -EA 0
$ModPath  = "$Default\FightingEntropy"
$DataPath = "$Env:ProgramData\$Company\$Name"
$Trunk    = Get-ItemProperty $RegPath

"Classes","Control","Functions","Graphics" | % {

    Remove-Item "$DataPath\$_" -Recurse -Force -Verbose
}

Remove-Item "$ModPath\$Version" -Recurse -Force -Verbose
Remove-Item $RegPath -Recurse -Force -Verbose
