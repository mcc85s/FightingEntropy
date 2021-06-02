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
    Remove-Item $RegPath
}

# [Property Value]
$ModPath  = "$Default\FightingEntropy"
$DataPath = "$Env:ProgramData\$Company\$Name"
$Trunk    = Get-ItemProperty $RegPath

"Classes","Control","Functions","Graphics" | % {

    Remove-Item "$DataPath\$_" -Recurse -Force -Verbose
}

Remove-Item "$ModPath\$Version" -Recurse -Force -Verbose
Remove-Item $RegPath -Recurse -Force -Verbose
