Class _Icons
{
    [Object]         $Item
    [String]         $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    [Object]     $Property

    [Hashtable]      $Hash = @{
    
        Computer           = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        ControlPanel       = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
        Documents          = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
        Libraries          = "{031E4825-7B94-4dc3-B131-E946B44C8DD5}"
        Network            = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
    }

    [Int32]      $Computer
    [Int32]  $ControlPanel
    [Int32]     $Documents
    [Int32]     $Libraries
    [Int32]       $Network

    _Icons([Int32]$Computer,[Int32]$ControlPanel,[Int32]$Documents,[Int32]$Libraries,[Int32]$Network)
    {
        $This.Computer     = $Computer
        $This.ControlPanel = $ControlPanel
        $This.Documents    = $Documents
        $This.Libraries    = $Libraries
        $This.Network      = $Network

        $This.Item         = Get-Item         -Path $This.Path
        $This.Property     = Get-ItemProperty -Path $This.Path

        ForEach ( $I in "Computer ControlPanel Documents Libraries Network".Split(" ") )
        {
            Set-ItemProperty -Path $This.Path -Name $This.Hash.$I -Value $This.$I -Verbose
        }
    }
}
