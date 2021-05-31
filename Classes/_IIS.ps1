Class _IIS
{
    [String]      $Name
    [String]   $AppPool
    [String]      $Host
    [String] $Directory
    
    [String]    $System = $Env:SystemDrive
    [String]  $System32 = "$Env:SystemRoot\System32"
    [String]  $Hostname = $Env:ComputerName

    [String]      $Date = (Get-Date -UFormat "%m-%d-%Y")
    [String]       $Log = "$Env:Temp\ACL"
    [String]      $Root = "{0}\inetpub\{1}"
    [String]      $Site = "IIS:\Sites\{0}"
    [String]     $VHost = "{0}\{1}"
    [String]       $URL = "{0}.$($Env:UserDNSDomain.ToLower())"
    [String]   $AppData = "{0}\AppData"

    _IIS([String]$Name,[String]$AppPool,[String]$IISHost,[String]$Directory)
    {
        $This.Name      = $Name
        $This.AppPool   = $AppPool
        $This.Host      = $IISHost
        $This.Directory = $Directory
        $This.Root      = $This.Root    -f $This.System, $This.Name
        $This.Site      = $This.Site    -f $This.Name
        $This.VHost     = $This.VHost   -f $This.Site, $This.Host
        $This.URL       = $This.URL     -f $This.Name
        $This.AppData   = $This.Appdata -f $This.Root
    }
}
