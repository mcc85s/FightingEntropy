Function Write-Xaml
{
    [CmdLetBinding()]Param([Parameter()][String]$Path)

    If (!([System.IO.File]::Exists($Path)))
    {
        Throw "Invalid path: [$Path]"
    }

    Class WriteXaml
    {
        [String] $Name
        [String] $Fullname
        [Object] $Content
        WriteXaml([String]$Path)
        {
            $Item          = Get-Item $Path
            $This.Name     = $Item.BaseName
            $This.Fullname = $Item.Fullname
            $This.Content  = [System.IO.File]::ReadAllLines($Item.Fullname)
        }
        [String] Output()
        {
            $Out  = @( )
            $Out += "Class {0}" -f $This.Name
            $Out += "{"
            $Out += "    Static [String] `$Content = @("
            ForEach ($X in 0..($This.Content.Count-2))
            {
                $Out += "    '{0}'," -f $This.Content[$X]
            }
            $Out += "    '{0}' -join `"``n`")" -f $This.Content[$X+1]
            $Out += "}"
            Return $Out -join "`n"
        }
    }

    [WriteXaml]::New($Path).Output()
}
