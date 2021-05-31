Class _Root
{
    Hidden [String[]]     $Names = ("Name Type Version Provider Date Path Status" -Split " ")
    [String]               $Type
    [String]               $Name
    [String]            $Version
    [String]           $Provider
    [String]               $Date
    [String]               $Path
    [String]             $Status

    _Root([String]$Registry,[String]$Type,[String]$Name,[String]$Version,[String]$Provider,[String]$Path)
    {
        $This.Type               = $Type
        $This.Name               = $Name
        $This.Version            = $Version
        $This.Provider           = $Provider
        $This.Date               = Get-Date -UFormat %Y_%m%d-%H%M%S
        $This.Path               = $Path
        $This.Status             = "Initialized"
        $This.Names              | % { Set-ItemProperty -Path $Registry -Name $_ -Value $This.($_) -Verbose }
    }
}
