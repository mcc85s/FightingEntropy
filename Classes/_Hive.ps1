
Class _Hive
{
    [String]        $Type
    [String]     $Version
    Hidden [String] $Name = "{0}\Secure Digits Plus LLC\FightingEntropy\{1}"
    Hidden [String] $File = "{0}\FightingEntropy.ps{1}1"
    [String[]]  $PSModule
    [String]        $Root
    [Object]        $Path
    [Object]    $Manifest
    [Object]      $Module

    [String[]] PSModule_()
    {
        Return @( Get-Item Env:\ | % GetEnumerator | ? Name -eq PSModulePath | % Value | % Split @{  
        
            Win32_Client = ";"
            Win32_Server = ";"
            RHELCentOS   = ":" 
            UnixBSD      = ":"
            
        }[$This.Type])
    }

    [String] Root_()
    {
        Return ($This.Name -f @{
        
            Win32_Client = "HKLM:\Software\Policies"
            Win32_Server = "HKLM:\Software\Policies"
            RHELCentOS   = "/etc/Maestro"
            UnixBSD      = "/etc/Maestro"
            
        }[$This.Type],$This.Version)
    }

    [String] Path_()
    {
        Return ($This.Name -f @{  
        
            Win32_Client = Get-Item Env:\ProgramData | % Value
            Win32_Server = Get-Item Env:\ProgramData | % Value
            RHELCentOS   = "/etc/FEUnix"
            UnixBSD      = "/etc/FEUnix"
            
        }[$This.Type],$This.Version)
    }

    [Void] Check([String]$Path)
    {
        $Items = $Path.Split("\")
        $Item  = $Items[0]

        ForEach ( $I in 1..( $Items.Count - 1 ) )
        {
            $Item += ( "\{0}" -f $Items[$I] )

            If ( ! ( Test-Path $Item ) )
            {
                New-Item $Item -ItemType Directory -Force -Verbose
            }
        }
    }

    _Hive([String]$Type,[String]$Version)
    {
        $This.Type      = $Type
        $This.Version   = $Version

        $This.PSModule  = $This.PSModule_()
        $This.Root      = $This.Root_()
        $This.Path      = $This.Path_()

        If ( $This.Type -eq "RHELCentOS" )
        {
            $This.Root  = $This.Root.Replace("\","/")
            $This.Path  = $This.Path.Replace("\","/")
        }

        $This.Check($This.Root)
        $This.Check($This.Path)

        $This.Manifest = $This.File -f $This.Path,"d"
        $This.Module   = $This.File -f $This.Path,"m"
    }
}
