<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:54:03                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PowerShell.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Gets the current releases from the official PowerShell Github repository
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
Function Get-PowerShell
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [ValidateSet("Stable","Preview")]
    [Parameter(ParameterSetName=1)][String]$Type,
    [Parameter(ParameterSetName=1)][String]$Version,
    [ValidateSet("Windows","RHEL","Debian","Linux","macOS")]
    [Parameter(ParameterSetName=1)][String]$OS,
    [ValidateSet("x86","x64","x86_64","arm64","arm32")]
    [Parameter(ParameterSetName=1)][String]$Architecture
    )

    Class Architecture
    {
        Hidden [String] $Slot
        [String] $Type
        Architecture([String]$Url)
        {
            $This.Type = Switch -Regex ($Url)
            {
                "(x64\.)"      {    "x64" } "x86\."   {   "x86" } "\.deb_amd64\." { "x86_64" }
                "rh\.x86_64\." { "x86_64" } "arm64\." { "arm64" } "arm32\."       {  "arm32" }
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
        [UInt32]          $Index
        [String]           $Type
        [Version]       $Version
        [String]             $OS
        [Object]           $Arch
        [String]           $File
        [String]            $URL
        Release([UInt32]$Index,[Object]$Release)
        {
            $This.Index    = $Index
            $This.Release  = $Release
            $This.OS       = Switch -Regex ($Release.Href)
            {
                win { "Windows" } deb { "Debian" } .rh { "RHEL" } linux { "Linux" } osx { "macOS" }
            }
            $This.Arch    = $This.Architecture($Release.Href)
            $This.Type    = @("Stable","Preview")[$Release.Href -match "Preview"]
            $This.Version = [Version][Regex]::matches($Release.Href,"v\d+\.\d+\.\d+").Value.Trim("v")
            $This.URL     = $Release.Href
            $This.File    = $This.URL | Split-Path -Leaf
        }
        [Object] Architecture([String]$Arch)
        {
            Return [Architecture]$Arch
        }
        [String] ToString()
        {
            Return $This.File
        }
    }

    Class PowerShell
    {
        [String] $Base    = "https://github.com/PowerShell/PowerShell"
        [Object] $Content
        [Object] $Output
        PowerShell()
        {
            $This.Content = Invoke-WebRequest $This.Base -UseBasicParsing
            $Hash         = @{ }
            
            # Add found links to temp hashtable
            $This.Content.Links | ? {$_ -match "releases/download" } | % { 
                
                $Hash.Add($Hash.Count,[Release]::New($Hash.Count,$_))
            }

            # Filter unique entries, then sort by version
            $This.Output = @( )
            ForEach ($X in 0..($Hash.Count-1))
            {
                If ($Hash[$X].URL -notin $This.Output.Url)
                {
                    $This.Output += $Hash[$X]
                }
            }

            # Sort by version
            $This.Output = $This.Output | Sort-Object Version

            # Rerank the indexes
            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Output.Count -gt 1)
            {
                ForEach ($X in 0..($This.Output.Count-1))
                { 
                    $This.Output[$X].Index = $X
                }
            }
            If ($This.Output.Count -eq 1)
            {
                $This.Output[0].Index = 0
            }
        }
    }

    $Item = [Powershell]::New()

    If ($psCmdLet.ParameterSetName -eq 1)
    {
        If ($Type)
        {
            $Item.Output = $Item.Output | ? Type -eq $Type
        }

        If ($Version)
        {
            If ([Version]$Version -notin $Item.Version)
            {
                Throw "Invalid version"
            }
            Else
            {
                $Item.Output = $Item.Output | ? Version -eq ([Version]$Version)
            }
        }

        If ($OS)
        {
            $Item.Output = $Item.Output | ? OS -eq $OS
        }

        If ($Architecture)
        {
            $Item.Output = $Item.Output | ? Arch -eq $Architecture
        }
    }

    If ($Item.Output.Count -gt 0)
    {
        $Item.Rerank()
        Return $Item.Output
    }
    Else
    {
        Return $Null
    }
}
