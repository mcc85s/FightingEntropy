<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName : Get-FEOS.ps1
          Solution : FightingEntropy Module
          Purpose  : For detecting the currently running operating system, meant for cross compatibility
          Author   : Michael C. Cook Sr.
          Contact  : @mcc85s
          Primary  : @mcc85s
          Created  : 2021-10-09
          Modified : 2022-08-24
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO:
.Example
#>
Function Get-FEOS
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

    Class HostnameCtl
    {
        [String] $Hostname
        [String] $Icon
        [String] $MachineID
        [String] $BootID
        [String] $OS
        [String] $Arch
        [String] $Vendor
        [String] $Model
        [String] $Version
        HostnameCtl()
        {
            $Ctl            = "hostnamectl" | Invoke-Expression | % Split "`n" | % Substring 18
            $This.Hostname  = $Ctl[0]
            $This.Icon      = $Ctl[1]
            $this.MachineID = $Ctl[2]
            $This.BootID    = $Ctl[3]
            $This.OS        = $Ctl[4]
            $This.Arch      = $Ctl[5]
            $This.Vendor    = $Ctl[6]
            $This.Model     = $Ctl[7]
            $This.Version   = $Ctl[8]
        }
    }

    Class OS
    {
        [Object] $Env
        [Object] $Var
        [Object] $PS
        [Object] $Ver
        [Object] $Major
        [String] $Type
        OS()
        {
            $Hash       = @{ 
                
                Env     = Get-ChildItem Env:\      | % { [EnumType]::New($_.Key,$_.Value) }
                Var     = Get-ChildItem Variable:\ | % { [EnumType]::New($_.Name,$_.Value) }
            }
            $This.Env   = $Hash.Env
            $This.Var   = $Hash.Var
            $This.PS    = $Hash.Var | ? Name -eq PSVersionTable | % Value | % GetEnumerator | % { [EnumType]::New($_.Name,$_.Value) }
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
        [Object] GetOSType()
        {
            $hash = @{ 
                
                Linux = Get-Item Variable:\IsLinux | % Value
                MacOS = Get-Item Variable:\IsMacOS | % Value
            }

            $Return = @(If ($This.Major -gt 5)
            {
                If ($Hash.Linux)
                {
                    Switch -Regex ([HostnameCtl]::new().OS)
                    {
                        Kali
                        {
                            "Debian"
                        }
                        CentOS
                        {
                            "RHEL"
                        }
                        Default
                        {
                            "Linux"
                        }
                    }
                }
                ElseIf ($Hash.MacOS)
                {
                    "MacOS"
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

            Return $Return
        }
        [String] ToString()
        {
            Return ("[{0}/{1}]" -f $This.Type, $This.Ver)
        }
    }

    [OS]::New()
}
