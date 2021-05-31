Class _Brand
{
    [String] $Path
    [String] $Name
    [Object] $Value

    _Brand([String]$Path,[String]$Name,[Object]$Value)
    {
        $This.Path  = $Path
        $This.Name  = $Name
        $This.Value = $Value
    }
}
