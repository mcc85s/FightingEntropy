Function Get-AssemblyList
{
    Class AssemblyEntry
    {
        [String]                 $Name
        [Version]             $Version
        [String]              $Culture
        [String]       $PublicKeyToken
        [String]             $Fullname
        [String]             $CodeBase
        [String[]]   $CustomAttributes
        [Object[]]       $DefinedTypes
        [Object]           $EntryPoint
        [String]      $EscapedCodeBase
        [Object]             $Evidence
        [Type[]]        $ExportedTypes
        [Boolean] $GlobalAssemblyCache
        [Int64]           $HostContext
        [String]  $ImageRuntimeVersion
        [Bool]              $IsDynamic
        [Bool]         $IsFullyTrusted
        [String]             $Location
        [Object]       $ManifestModule
        [Object[]]            $Modules
        [Object]        $PermissionSet
        [Bool]         $ReflectionOnly
        [Object]      $SecurityRuleSet
        AssemblyEntry([Object]$Assembly)
        {
            $Split                    = $Assembly.Fullname -Split ","
            $This.Name                = $Split[0]
            $This.Version             = $This.X($Split[1])
            $This.Culture             = $This.X($Split[2])
            $This.PublicKeyToken      = $This.X($Split[3])
            $This.CodeBase            = $Assembly.CodeBase 
            $This.CustomAttributes    = $Assembly.CustomAttributes 
            $This.DefinedTypes        = $Assembly.DefinedTypes 
            $This.EntryPoint          = $Assembly.EntryPoint 
            $This.EscapedCodeBase     = $Assembly.EscapedCodeBase 
            $This.Evidence            = $Assembly.Evidence 
            $This.ExportedTypes       = $Assembly.ExportedTypes 
            $This.FullName            = $Assembly.FullName 
            $This.GlobalAssemblyCache = $Assembly.GlobalAssemblyCache 
            $This.HostContext         = $Assembly.HostContext 
            $This.ImageRuntimeVersion = $Assembly.ImageRuntimeVersion 
            $This.IsDynamic           = $Assembly.IsDynamic 
            $This.IsFullyTrusted      = $Assembly.IsFullyTrusted 
            $This.Location            = $Assembly.Location 
            $This.ManifestModule      = $Assembly.ManifestModule 
            $This.Modules             = $Assembly.Modules 
            $This.PermissionSet       = $Assembly.PermissionSet 
            $This.ReflectionOnly      = $Assembly.ReflectionOnly 
            $This.SecurityRuleSet     = $Assembly.SecurityRuleSet 
        }
        [String] X([String]$String)
        {
            Return $String.Split("=")[1]
        }
    }
    Class AssemblyList
    {
        [Object] $Output
        AssemblyList()
        {
            $This.Output = @( )
            
            ForEach ($Assembly in [System.AppDomain]::CurrentDomain.GetAssemblies() | ? FullName -notmatch "^\\.+" | ? Location)
            {   
                $Assembly | ? Location | ? Fullname -notmatch ^\\.+ | % { $This.Add($Assembly) }
            }

            $This.Output = $This.Output | Sort-Object Name
        }
        Add([Object]$Assembly)
        {
            $This.Output += [AssemblyEntry]::New($Assembly)
        }
    }
    [AssemblyList]::New().Output
}