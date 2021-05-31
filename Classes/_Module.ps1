Class _Module
{
    [Object]                 $OS
    [Object]           $Manifest
    [Object]               $Hive
    
    [String]               $Name = "FightingEntropy"
    [String]            $Version = "2021.4.0"
    [String]           $Provider = "Secure Digits Plus LLC"
    [String]               $Date
    [String]             $Status
    [String]               $Type

    [String]           $Resource = "https://raw.githubusercontent.com/mcc85sx/FightingEntropy/master/2021.4.0"
    
    [Object[]]          $Classes
    [Object[]]        $Functions
    [Object[]]          $Control
    [Object[]]         $Graphics
    
    [Object]               $Role
    
    _Module()
    {
        $This.OS                 = (Get-FEOS)
        $This.Type               = $This.OS.Type
        $This.Manifest           = (Get-FEManifest -Version $This.Version)
        $This.Hive               = (Get-FEHive -Type $This.Type -Version $This.Version)

        If ( $This.Type -match "Win32_" )
        {
            Get-ItemProperty -Path $This.Hive.Root | % { 

                $This.Name       = $_.Name
                $This.Version    = $_.Version
                $This.Provider   = $_.Provider
                $This.Date       = $_.Date
                $This.Status     = $_.Status
            }
        }

        $This.Classes            = $This.Manifest.Classes   | % { Get-Item ( "{0}\Classes\$_"   -f $This.Hive.Path ) }
        $This.Control            = $This.Manifest.Control   | % { Get-Item ( "{0}\Control\$_"   -f $This.Hive.Path ) }
        $This.Functions          = $This.Manifest.Functions | % { Get-Item ( "{0}\Functions\$_" -f $This.Hive.Path ) } 
        $This.Graphics           = $This.Manifest.Graphics  | % { Get-Item ( "{0}\Graphics\$_"  -f $This.Hive.Path ) }

        $This.Role               = [_Role]::New($This.Type).Output
    }

    [Void] Load([String]$Type)
    {
        If ( $Type -notin "Function","Class")
        {
            Throw "Invalid Item"
        }
        
        $Collect = @( )
        Foreach ( $Item in @{ Function = $This.Functions ; Class = $This.Classes }[$Type] )
        {
            $Collect += (Get-Content $Item.FullName)
        }
        
        Invoke-Expression ( $Collect -join "`n" )
    }
}
