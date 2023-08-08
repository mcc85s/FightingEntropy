<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:41:15                                                                  //
 \\==================================================================================================// 

    FileName   : Get-AssemblyList.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : This function collects the currently loaded assemblies in the PowerShell host.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A 

.Example
#>

Function Get-AssemblyList
{
    Class AssemblyEntry
    {
        [String]                 $Name
        [Version]             $Version
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
            $Split                    = $Assembly.Fullname.Split(",")
            $This.Name                = $Split[0]
            $This.Version             = Switch -Regex ($Split[1])
            {
                "=" { $Split[1].Split("=")[1] } Default { $Split[1] }
            }
            
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
    }

    Class AssemblyList
    {
        [Object] $Output
        AssemblyList()
        {
            $This.Output = @( )
            
            ForEach ($Assembly in [System.AppDomain]::CurrentDomain.GetAssemblies())
            {
                $This.Add($Assembly)
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
