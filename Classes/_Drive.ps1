Class _Drive
{
    [Object]                $Name
    [String]        $FullProvider
    [String]            $Provider
    [String]                $Root
    [String]         $DisplayRoot
    [String]         $Description
    [Int32]                 $Mode
    
    _Drive([Object]$Drive)
    {
        $This.Name                = $Drive.Name
        $This.FullProvider        = $Drive.Provider
        $This.Provider            = Split-Path -Leaf $Drive.Provider
        $This.Root                = $Drive.Root
        $This.DisplayRoot         = $Drive.DisplayRoot
        $This.Description         = $Drive.Description | % { ($_,"-")[!$_] }
        $This.Mode                = Switch ( Split-Path -Leaf $Drive.Provider )
        { 
            FileSystem   {0} Certificate  {1} Environment  {2} Registry     {3} Temp         {4} 
            Alias        {5} Function     {6} Variable     {7} WSMan        {8} Default     {-1} 
        }
    }
}
