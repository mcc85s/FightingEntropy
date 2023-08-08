<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 10:12:30                                                                  //
 \\==================================================================================================// 

    FileName   : New-EnvironmentKey.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Instantiates an environment key for FightingEntropy
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Needs testing in a domain

.Example
#>
Function New-EnvironmentKey
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(Mandatory,ParameterSetName=0)][Object]$Key,
    [Parameter(Mandatory,ParameterSetName=1)]
    [ValidateScript({Test-Path $_})]
    [String]$Path)

    If ($Path)
    {
        $Key = [System.IO.File]::ReadAllLines($Path) | ConvertFrom-Json
    }
    
    Class Telemetry
    {
        [String]       $ExternalIP
        Hidden [Object]      $Ping
        [String]     $Organization
        [String]       $CommonName
        [String]         $Location
        [String]           $Region
        [String]          $Country
        [Int32]            $Postal
        [String]         $TimeZone
        [String]         $SiteLink
        [String]           $Branch
        Telemetry([Object]$Key)
        {
            $This.Organization     = $Key.Organization
            $This.CommonName       = $Key.CommonName
            $This.Main()
        }
        Telemetry([String]$Organization,[String]$CommonName)
        {
            $This.Organization     = $Organization
            $This.CommonName       = $CommonName
            $This.Main()
        }
        Main()
        {
            $This.ExternalIP       = Invoke-RestMethod "http://ifconfig.me/ip"
            $This.Ping             = Invoke-RestMethod "http://ipinfo.io/$($This.ExternalIP)"
            $This.Location         = $This.Ping.City
            $This.Region           = $This.Ping.Region
            $This.Country          = $This.Ping.Country
            $This.Postal           = $This.Ping.Postal
            $This.TimeZone         = $This.Ping.TimeZone
            $This.SiteLink         = $This.GetSiteLink($This.Ping)
            $This.Branch           = $This.Sitelink.Replace("-",".").tolower(), $This.CommonName -join '.'
        }
        [String] GetSiteLink([Object]$Ping)
        {
            $Return = @( )
            $Return += ( $Ping.City -Split " " | % { $_[0] } ) -join ''
            $Return += ( $Ping.Region -Split " " | % { $_[0] } ) -join ''
            $Return += $Ping.Country
            $Return += $Ping.Postal

            Return $Return -join '-'
        }
        [String] ToString()
        {
            Return $This.SiteLink
        }
    }

    Class Company
    {
        [Object]        $Telemetry
        [String]             $Name
        [String]       $Background
        [String]             $Logo
        [String]            $Phone
        [String]          $Website
        [String]            $Hours
        Company([Object]$Telemetry,[Object]$Key)
        {
            $This.Telemetry     = $Telemetry
            $This.Name          = $Key.Organization

            $Graphics           = Get-FEModule -Graphics

            If (!($Key.Background) -or (!(Test-Path $Key.Background)))
            {
                $Key.Background = $Graphics | ? Name -match OEMbg.jpg | % FullName
            }
        
            If (!($Key.Logo) -or (!(Test-Path $Key.Logo)))
            {
                $Key.Logo       = $Graphics | ? Name -match OEMlogo.bmp | % FullName
            }

            $This.Background    = $Key.Background
            $This.Logo          = $Key.Logo
            $This.Phone         = @("N/A",$Key.Phone)[!!$Key.Phone]
            $This.Website       = @("https://www.securedigitsplus.com",$Key.Website)[!!$Key.Website]
            $This.Hours         = @("N/A",$Key.Hours)[!!$Key.Hours]
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    Class Icons
    {
        [Object]         $Item
        [String]         $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        [Object]     $Property
        [Hashtable]      $Hash = @{
    
            Computer           = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
            ControlPanel       = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
            Documents          = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
            Libraries          = "{031E4825-7B94-4dc3-B131-E946B44C8DD5}"
            Network            = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
        }
        [Int32]      $Computer
        [Int32]  $ControlPanel
        [Int32]     $Documents
        [Int32]     $Libraries
        [Int32]       $Network
        Icons([Int32]$Computer,[Int32]$ControlPanel,[Int32]$Documents,[Int32]$Libraries,[Int32]$Network)
        {
            $This.Computer     = $Computer
            $This.ControlPanel = $ControlPanel
            $This.Documents    = $Documents
            $This.Libraries    = $Libraries
            $This.Network      = $Network
            $This.Item         = Get-Item         -Path $This.Path
            $This.Property     = Get-ItemProperty -Path $This.Path
        }
        Set()
        {
            "Computer","ControlPanel","Documents","Libraries","Network" | % { 

                Set-ItemProperty -Path $This.Path -Name $This.Hash.$_ -Value $This.$_ -Verbose
            }
        }
        [String] ToString()
        {
            Return @($This.Hash.Keys)
        }
    }

    Class BrandingProperty
    {
        [UInt32] $Index
        [String] $Path
        [String] $Name
        [Object] $Value
        BrandingProperty([UInt32]$Index,[String]$Path,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Path  = $Path
            $This.Name  = $Name
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class BrandingTemplate
    {
        Hidden [String] $OOBE = "{0}\OOBE" -f [Environment]::SystemDirectory
        [String[]] $File
        [String[]] $Registry
        [String[]] $Names
        [String[]] $Item
        [Object] $Icon
        BrandingTemplate()
        {
            $This.Names    = "Wallpaper",
                             "WallpaperStyle",
                             "Logo",
                             "Manufacturer",
                             "SupportPhone",
                             "SupportHours",
                             "SupportURL",
                             "LockScreenImage",
                             "OEMBackground"
            $System        = [Environment]::SystemDirectory
            $This.File     = $System,
                             "$System\OOBE\Info",
                             "$System\OOBE\Info\Backgrounds",
                             "$Env:Windir\Web\Screen",
                             "$Env:Windir\Web\Wallpaper\Windows",
                             "$Env:ProgramData\Microsoft\User Account Pictures"
            $This.Registry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System",
                             "HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation",
                             "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background",
                             "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
            $This.Icon     = [Icons]::New(0,1,0,1,0)
        }
        Init([UInt32]$Mode)
        {
            Switch ($Mode)
            {
                0
                {
                    # // =============================================
                    # // | (Test/create) the intended registry paths |
                    # // =============================================

                    $This.Registry | % {

                        $Splat     = @{ Path = Split-Path $_ -Parent; Name = Split-Path $_ -Leaf }

                        If (!(Test-Path $_))
                        {
                            New-Item @Splat -Verbose
                        }
                    }
                }
                1
                {
                    # // =============================
                    # // | Create the OOBE directory |
                    # // =============================

                    If (!$This.Exists($This.OOBE))
                    {
                        $This.Create($This.OOBE)
                    }

                    # // =========================================
                    # // | (Test/create) the intended file paths |
                    # // =========================================

                    $This.File | ? { !$This.Exists($_) } | % { $This.Create($_) }
                }
            }
        }
        [UInt32] Exists([String]$Path)
        {
            Return [System.IO.Directory]::Exists($Path)
        }
        [Void] Create([String]$Path)
        {
            [System.IO.Directory]::CreateDirectory($Path)
        }
    }

    Class Branding
    {
        [Object]       $Provider
        [Object]        $Company
        [Object]    $Certificate
        [Object]         $Branch
        [String]       $SiteLink
        [String]     $Background
        [String]           $Logo
        [String]        $Website
        [String]          $Phone
        [String]          $Hours
        [Object]       $Template
        [Object]         $Output
        Branding([Object]$Company)
        {
            $This.Provider       = "Secure Digits Plus"
            $This.Company        = $Company
            $This.Certificate    = "<Obtain Certificate>"
            $This.Branch         = $Company.Telemetry.Branch
            $This.SiteLink       = $Company.Telemetry.SiteLink
            $This.Background     = $Company.Background
            $This.Logo           = $Company.Logo
            $This.Website        = $Company.Website
            $This.Phone          = $Company.Phone
            $This.Hours          = $Company.Hours
            $This.Template       = $This.Temp()
            $Items               = $This.Template.Registry[0,0,1,1,1,1,1,3,2]
            $Names               = $This.Template.Names
            $Values              = $This.Background,
                                   2,
                                   $This.Logo,
                                   $This.Provider,
                                   $This.Phone,
                                   $This.Hours,
                                   $This.Website,
                                   $This.Background,
                                   1
            $This.Output         = @( ) 
            
            ForEach ($X in 0..8)
            {
                $This.Add($Items[$X],$Names[$X],$Values[$X])
            }
        }
        Add([String]$Item,[String]$Name,[Object]$Value)
        {
            $This.Output        += [BrandingProperty]::New($This.Output.Count,$Item,$Name,$Value)
        }
        [Object] Temp()
        {
            Return [BrandingTemplate]::New()
        }   
        Copy()
        {
            $Path        = @($This.Logo,$This.Background)[0,0,1,1,1,0]
            $Destination = $This.Template.File
            ForEach ($X in 0..5)
            {
                Copy-Item -Path $Path[$X] -Destination $Destination[$X] -Verbose
            }
        }
        Set()
        {
            $This.Output | % { $This.SetItemProperty($_.Path,$_.Name,$_.Value) }
        }
        SetItemProperty([String]$Path,[String]$Name,[Object]$Value)
        {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Verbose
        }
        Apply()
        {
            $This.Init(0)
            $This.Init(1)
            $This.Copy()
            $This.Set()
            $This.Template.Icons.Set()
            
            $This.SetItemProperty("HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ListviewShadow",1)
            $This.SetItemProperty("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ListviewShadow",1)
            $This.SetItemProperty("HKLM:\System\CurrentControlSet\Control\Terminal Server","fDenyTSConnections",0)
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Verbose

            $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration | ? IPEnabled
            $networkConfig.SetDnsDomain($This.Company.Telemetry.CommonName)
            $networkConfig.SetDynamicDNSRegistration($true,$true)
            ipconfig /registerdns

            RunDll32 User32.Dll, UpdatePerUserSystemParameters
        }
    }

    $Graphics           = Get-FEModule -Graphics
    $Telemetry          = [Telemetry]::New($Key)
    $Company            = [Company]::New($Telemetry,$Key)

    [Branding]::New($Company)
}
