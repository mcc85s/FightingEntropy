<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Install-BossMode.ps1
          Solution: FightingEntropy Module
          Purpose: Installs custom theme for Visual Studio Code
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-27
          Modified: 2021-10-27
          
          Version - 2021.10.0 - () - Finalized functional version 1.

.Example
#>
Function Install-BossMode
{
    Class EnumType
    {
        [String] $Name
        [Object] $Value
        EnumType([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class OS
    {
        [Object] $Env
        [Object] $Var
        [Object] $PS
        [Object] $Ver
        [Object] $Major
        [Object] $Type
        OS()
        {
            $This.Env   = Get-ChildItem Env:\      | % { [EnumType]::New($_.Key,$_.Value) }
            $This.Var   = Get-ChildItem Variable:\ | % { [EnumType]::New($_.Name,$_.Value) }
            $This.PS    = $This.Var | ? Name -eq PSVersionTable | % Value | % GetEnumerator | % { [EnumType]::New($_.Name,$_.Value) }
            $This.Ver   = $This.PS | ? Name -eq PSVersion | % Value
            $This.Major = $This.Ver.Major
            $This.Type  = $This.GetOSType()
        }
        [String] GetWinType()
        {
            Return @( Switch -Regex ( Invoke-Expression "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption" )
            {
                "Windows 10" { "Win32_Client" } "Windows Server" { "Win32_Server" }
            })
        }
        [String] GetOSType()
        {
            Return @(If ($This.Major -gt 5)
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

    $OS = [OS]::New()
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
    ".vscode","themes" | ? { !(Test-Path "$Path/$_") } | % {

        New-Item "$Path/$_" -ItemType Directory -Verbose
    }
    [BossMode]::New($Path)
}
