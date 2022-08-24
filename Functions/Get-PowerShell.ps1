<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName: Get-PowerShell.ps1
          Solution: FightingEntropy
          Purpose: Gets the current releases for PowerShell from the official PowerShell Github Repository
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-08-24
          Modified: 2022-08-24
          Version - 0.0.0 - () - Finalized functional version 1.
          TODO:
.Example
#>
Function Get-PowerShell
{
    Class Architecture
    {
        Hidden [String] $Slot
        [String] $Type
        Architecture([String]$Slot)
        {
            $This.Slot = $Slot
            $This.Type = Switch -Regex ($Slot)
            {
                "(x64\.|amd64\.)" {    "x64" } "x86\."   {   "x86" } "deb_amd64\." { "x86_64" }
                "rh\.x86_64\."    { "x86_64" } "arm64\." { "arm64" } "arm86\."     {  "arm86" }
            }
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class Release
    {
        Hidden [Object] $Release
        [String]             $OS
        [Object]           $Arch
        [String]           $Type
        [Version]       $Version
        [String]            $URL
        Release([Object]$Release)
        {
            $This.Release  = $Release
            $This.OS       = Switch -Regex ($Release.Href)
            {
                win { "Windows" } deb { "Debian" } .rh { "RHEL" } linux { "Linux" } osx { "macOS" }
            }
            $This.Type    = @("Stable","Preview")[$Release.Href -match "Preview"]
            $This.Version = [Version][Regex]::matches($Release.Href,"v\d+\.\d+\.\d+").Value.Trim("v")
            $This.URL     = $Release.Href
        }
        [Object] Arch([String]$Arch)
        {
            Return [Architecture]$Arch
        }
    }

    Class PowerShell
    {
        [String] $Base    = "https://github.com/PowerShell/PowerShell"
        [Object] $Content
        [Object] $Releases
        PowerShell()
        {
            $This.Content  = Invoke-WebRequest $This.Base
            $This.Releases = $This.Content.Links | ? {$_ -match "releases/download" } | % { [Release]$_ }
        }
    }

    [Powershell]::New().Releases
}
