<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-FEOS.ps1                                                                             //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : For detecting the currently running operating system, meant for cross com                //   
   \\                     patibility.                                                                              \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-10-10                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:43    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
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
            Return @( If ( $This.Major -gt 5 )
            {
                If ( Get-Item Variable:\IsLinux | % Value )
                {
                    (hostnamectl | ? { $_ -match "Operating System" }).Split(";")[1].TrimStart(" ")
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
            Return ("[{0}/{1}]" -f $This.Type, $This.Ver)
        }
    }
    [OS]::New()
}

