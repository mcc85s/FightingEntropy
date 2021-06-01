$RegPath  = 'HKLM:\software\Policies\Secure Digits Plus LLC\FightingEntropy'
$Version  = Get-ChildItem $RegPath | % PSChildName | Select-Object -Last 1
$Trunk    = Get-ItemProperty "$RegPath\$Version"
$DataPath = $Trunk.Path
$ModPath  = "$($Env:PSModulePath -Split ";" | ? { (Test-Path $_) -and (Get-ChildItem $_ | ? Name -match FightingEntropy)})\FightingEntropy"

"Classes","Control","Functions","Graphics" | % {

    Remove-Item "$DataPath\$_" -Recurse -Force -Verbose
}

Remove-Item "$ModPath\$Version" -Recurse -Force -Verbose
Remove-Item "$RegPath\$Version" -Recurse -Force -Verbose
