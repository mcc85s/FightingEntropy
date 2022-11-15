<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Update-PowerShell.ps1                                                                    //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : Updates PowerShell                                                                       //
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-12                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-12-2022 16:18:18    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Update-PowerShell
{
    Class Script
    {
        [UInt32] $Index
        [String] $Name
        [String] $Path
        [Object] $Content
        Script([UInt32]$Index,[String]$Name,[String]$Base)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Path    = "$Base/blob/main/Functions/$Name.ps1"
            $This.Content = Invoke-RestMethod "$($This.Path)?raw=true"
        }
    }

    Class Control
    {
        [String] $Base     = "https://github.com/mcc85s/FightingEntropy"
        [Object] $Scripts  = @( )
        [Object] $OS
        [Object] $Release
        [String] $Path
        [String] $Fullname
        [UInt32] $Success
        Control()
        {
            ForEach ($Name in "Get-PowerShell","Get-FEOS")
            {
                $This.Scripts += [Script]::New($this.Scripts.Count,$Name,$This.Base)
                Write-Host "Invoking [~] $Name"
                $This.Scripts | ? Name -eq $Name | % { $_.Content } | Invoke-Expression
            }

            $This.OS      = Get-FEOS
            $This.Release = Get-PowerShell -Type Stable -OS $This.OS.Type
            $This.Path    = $This.OS.Env | ? Name -eq Home | % Value
            If (!$This.Path)
            {
                Write-Host "Home directory not found, using current path"
                $This.Path = $This.OS.Env | ? Name -eq PWD | % Value
            }

            If ($This.Release.Count -eq 0)
            {
                Throw "Unable to find this operating system type in releases"
            }
            If ($This.Release.Count -gt 1)
            {
                $This.Release = $This.Release[0]
            }

            $This.Fullname = "{0}/{1}" -f $This.Path, $This.Release.File

            $This.Execute()
            
            Switch ($This.Success)
            {
                0 { Write-Error "Installation [!] $($This.Release.Version) MAY have failed, restart PowerShell." }
                1 { Write-Host  "Installation [+] $($This.Release.Version) was successful, restart PowerShell." }
            }
        }
        Execute()
        {
            If (Test-Path $This.Fullname)
            {
                Throw "File exists [!] [$($This.Fullname)], remove then try again."
            }

            Invoke-RestMethod $This.Release.Url -OutFile $This.Fullname

            Switch ($This.OS.Type)
            {
                Debian
                {
                    Try
                    { 
                        "sudo dpkg -i $($This.Fullname)" | Invoke-Expression
                        $This.Success = 1
                    }
                    Catch 
                    {
                        Write-Error "Exception [!] Thrown"
                        $This.Success = 0
                    }
                }
            }
            
            If ($This.Success -eq 1)
            {
                Remove-Item $This.Fullname -Verbose
            }
        }
    }

    [Control]::New()
}
