Class _File
{
    [String]                $Mode
    [DateTime]              $Date
    [Int32]                $Depth
    [String]                $Name
    [String]            $FullName

    _File([String]$Path)
    {
        [System.IO.FileInfo]::New($Path) | % {

            $This.Mode            = $_.Mode
            $This.Date            = $_.LastWriteTime
            $This.Depth           = $_.FullName.Split("\").Count - 2
            $This.Name            = $_.Name
            $This.FullName        = $_.FullName
        }
    }
}
