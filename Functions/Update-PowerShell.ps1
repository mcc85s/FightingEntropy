<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName : Update-PowerShell.ps1
          Solution : FightingEntropy
          Purpose  : Gets the current releases for PowerShell from the official PowerShell Github Repository
          Author   : Michael C. Cook Sr.
          Contact  : @mcc85s
          Primary  : @mcc85s
          Created  : 2022-08-24
          Modified : 2022-08-24
          Version - 0.0.0 - () - Finalized functional version 1.
          TODO: # Check PSModulePath for FightingEntropy
                # If fails, manually retrieve information
                # Manual method (Complete...?)
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
                    "sudo dpkg -i $($This.Fullname)" | Invoke-Expression
                }
            }
        }
    }

    [Control]::New()
}
