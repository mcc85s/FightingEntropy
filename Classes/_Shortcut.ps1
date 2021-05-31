Class _Shortcut
{
    [Object]               $Item
    
    _Shortcut(
    [String]               $Path ,
    [String]         $TargetPath ,
    [String[]]        $Arguments ,
    [String]       $IconLocation ,
    [String]        $Description ,
    [String]   $WorkingDirectory )
    {
        If ( ! ( Test-Path $Path ) )
        {
            Throw "Invalid Path"
        }

        If ( Test-Path $TargetPath )
        {
            Throw "Path exists"
        }

        $This.Item                  = (New-Object -ComObject WScript.Shell).CreateShortcut($TargetPath)

        $This.Item.TargetPath       = $Path
        $This.Item.Arguments        = $Arguments
        $This.Item.IconLocation     = $IconLocation
        $This.Item.Description      = $Description
        $This.Item.WorkingDirectory = $WorkingDirectory
        $This.Item.Save()
    }
}
