Class _RestObject
{
    [String]           $Path
    [String]           $Type
    [String]           $Name
    [Object]         $Object
    Hidden [String]     $URI
    
    _RestObject([String]$URI,[String]$Outfile)
    {
        $This.Path    = $Outfile.Replace("\","/")
        $This.Type    = $URI.Split("/")[-2]
        $This.Name    = $URI.Split("/")[-1]
        $This.URI     = $URI
        $This.Object  = Invoke-RestMethod -URI $This.URI -Outfile $This.Path -Verbose
    }
}
