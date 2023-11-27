# Install Cascadia Code
$Source      = "https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip"
$Name        = (Split-Path $Source -Leaf).Replace(".zip","")
$Base        = "$Home\Downloads"
$Destination = "$Base\$Name.zip"
$Extract     = "$Base\$Name"

Start-BitsTransfer -Source $Source -Destination $Destination -Verbose

If (Test-Path $Destination)
{
    Expand-Archive -Path $Destination -DestinationPath $Extract -Verbose
}

$List        = Get-ChildItem -Path "$Extract\ttf" | ? Extension -match ttf

If ($List.Count -gt 1)
{
    $Target      = (New-Object -ComObject Shell.Application).Namespace(0x14)
    ForEach ($Item in $List)
    {
        $Target.CopyHere($Item.Fullname,0x10)
    }
}

Remove-Item $Destination -Verbose
Remove-Item $Extract -Recurse -Confirm:0 -Verbose
