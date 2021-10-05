Class Version
{
    [UInt32] $Exists
    [UInt32] $Year
    [UInt32] $Month
    [UInt32] $Slot
    [String] $RegPath
    Version([Object]$Object)
    {
        $ID           = $Object.PSChildName.Split(".")
        $This.Year    = $ID[0]
        $This.Month   = $ID[1] 
        $This.Slot    = $ID[2]
        $This.RegPath = $Object.GetValue("RegPath")
        $This.Exists  = 0
        If ($This.Regpath)
        {
            $This.Exists = Test-Path $This.RegPath
        }
    }
}
        
$Name      = "FightingEntropy"
$Company   = "Secure Digits Plus LLC"
$Default   = "HKLM:\Software\Policies\$Company\$Name"
If (!(Test-Path $Default))
{
    Throw "Installation not found"
}
    
$Child     = Get-ChildItem $Default | % { [Version]::New($_) } | ? Exists | Sort-Object Year | Select-Object -First 1
If (!$Child)
{
    Throw "No version detected"
}

$RegPath   = Get-ItemProperty $Child.RegPath

If(!$RegPath)
{
    Write-Host "[!] Registry path invalid [!]"
}

If ($RegPath)
{
    $Main    = $RegPath.Main
    If (!(Test-Path $Main))
    {
        Write-Host "[!] Module references missing"
    }
    Remove-Item $Main -Recurse -Force -Verbose -EA 0
    Remove-Item $Child.RegPath -Recurse -Force -EA 0
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
