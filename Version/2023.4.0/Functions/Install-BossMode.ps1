<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 10:05:19                                                                  //
 \\==================================================================================================// 

    FileName   : Install-BossMode.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Installs custom theme for Visual Studio Code (cross platform...)
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
Function Install-BossMode
{
    # // ====================================================
    # // | Property object which includes source and index  |
    # // ====================================================

    Class OSProperty
    {
        [String] $Source
        Hidden [UInt32] $Index
        [String] $Name
        [Object] $Value
        OSProperty([String]$Source,[UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Source = $Source
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OSProperty>"
        }
    }

    # // ==========================================================
    # // | Container object for indexed OS (property/value) pairs |
    # // ==========================================================
    
    Class OSPropertySet
    {
        Hidden [UInt32] $Index
        [String] $Source
        [Object] $Property
        OSPropertySet([UInt32]$Index,[String]$Source)
        {
            $This.Index     = $Index
            $This.Source    = $Source
            $This.Property  = @( )
        }
        Add([String]$Name,[Object]$Value)
        {
            $This.Property += [OSProperty]::New($This.Source,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            $D = ([String]$This.Property.Count).Length
            Return "({0:d$D}) <FightingEntropy.Module.OSPropertySet[{1}]>" -f $This.Property.Count, $This.Source
        }
    }

    # // =======================================================
    # // | Collects various details about the operating system |
    # // | specifically for cross-platform compatibility       |
    # // =======================================================

    Class OS
    {
        [Object]   $Caption
        [Object]  $Platform
        [Object] $PSVersion
        [Object]      $Type
        [Object]    $Output
        OS()
        {
            $This.Output = @( )

            # // ===============
            # // | Environment |
            # // ===============

            $This.AddPropertySet("Environment")

            Get-ChildItem Env:              | % { $This.Add(0,$_.Key,$_.Value) }
            
            # // ============
            # // | Variable |
            # // ============

            $This.AddPropertySet("Variable")

            Get-ChildItem Variable:         | % { $This.Add(1,$_.Name,$_.Value) }

            # // ========
            # // | Host |
            # // ========

            $This.AddPropertySet("Host")

            (Get-Host).PSObject.Properties  | % { $This.Add(2,$_.Name,$_.Value) }
            
            # // ==============
            # // | PowerShell |
            # // ==============

            $This.AddPropertySet("PowerShell")

            (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add(3,$_.Name,$_.Value) }

            If ($This.Tx("PowerShell","PSedition") -eq "Desktop")
            {
                Get-CimInstance Win32_OperatingSystem | % { $This.Add(3,"OS","Microsoft Windows $($_.Version)") }
                $This.Add(3,"Platform","Win32NT")
            }

            # // ====================================
            # // | Assign hashtable to output array |
            # // ====================================

            $This.Caption   = $This.Tx("PowerShell","OS")
            $This.Platform  = $This.Tx("PowerShell","Platform")
            $This.PSVersion = $This.Tx("PowerShell","PSVersion")
            $This.Type      = $This.GetOSType()
        }
        [Object] Tx([String]$Source,[String]$Name)
        {
            Return $This.Output | ? Source -eq $Source | % Property | ? Name -eq $Name | % Value
        }
        Add([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Output[$Index].Add($Name,$Value)
        }
        AddPropertySet([String]$Name)
        {
            $This.Output += [OSPropertySet]::New($This.Output.Count,$Name)
        }
        [String] GetWinCaption()
        {
            Return "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption"
        }
        [String] GetWinType()
        {
            Return @(Switch -Regex (Invoke-Expression $This.GetWinCaption())
            {
                "Windows (10|11)" { "Win32_Client" } "Windows Server" { "Win32_Server" }
            })
        }
        [String] GetOSType()
        {
            Return @( If ($This.Version.Major -gt 5)
            {
                If (Get-Item Variable:\IsLinux | % Value)
                {
                    (hostnamectl | ? { $_ -match "Operating System" }).Split(":")[1].TrimStart(" ")
                }

                Else
                {
                    $This.GetWinType()
                }
            }

            Else
            {
                $This.GetWinType()
            })
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OS>"
        }
    }

    Class BossMode
    {
        [String]      $Base = "https://github.com/mcc85sx/FightingEntropy/blob/master/bossmode"
        [String[]] $Folders = ".vscode","themes"
        [String[]]   $Files = "CHANGELOG.md","README.md","index.txt","package.json","vsc-extension-quickstart.md",".vscode/launch.json","themes/BossMode-color-theme.json"
        BossMode([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            $This.Folders   | ? { !(Test-Path "$Path/$_") } | % { New-Item "$Path/$_" -ItemType Directory -Verbose }
            ForEach ($File in $This.Files)
            {
                $URL        = ("{0}/{1}?raw=true" -f $This.Base, $File)
                $Dest       = "$Path/$File"
                Invoke-RestMethod $URL -Outfile $Dest -Verbose
            }
        }
    }

    $OS     = [OS]::New()
    $Target = "$Home/.vscode/extensions/bossmode".Split("/")
    $Path   = $Target[0]
    ForEach ($X in 1..($Target.Count-1))
    {
        $Path = $Path,$Target[$X] -join '/'
        If (!(Test-Path $Path))
        {
            New-Item $Path -ItemType Directory -Verbose
        }
    }
    If ($OS.Platform -match "Win")
    {
        $Path = $Path -Replace "\/","\"
    }

    ".vscode","themes" | ? { !(Test-Path "$Path/$_") } | % {

        New-Item "$Path/$_" -ItemType Directory -Verbose
    }
    
    [BossMode]::New($Path)
}
