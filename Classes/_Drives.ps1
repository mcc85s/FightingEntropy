Class _Drives
{
    [Object[]]           $PSDrives
    [Object[]]         $FileSystem
    [Object[]]            $Network
    [Object[]]          $CertStore
    [Object[]]              $Samba
        
    _Drives()
    {
        $This.PSDrives            = Get-PSDrive      | % { [_Drive]::New($_) } | Sort-Object Mode
        $This.FileSystem          = $This.PSDrives   | ? Mode -eq 0 | Sort-Object Root 
        $This.Network             = $This.FileSystem | ? DisplayRoot
        $This.CertStore           = $This.PSDrives   | ? Mode -eq 1
        $This.Samba               = Get-SMBShare     | Sort-Object Path
    }
}
