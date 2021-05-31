Function New-EnvironmentKey
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(Mandatory,ParameterSetName=0)][Object]$Key,
    [Parameter(Mandatory,ParameterSetName=1)][String]$Path)

    If (($Path) -and (Test-Path $Path))
    {
        $Key = Get-Content -Path $Path
    }

    $Key = ( $Key | ConvertFrom-Json )
    
    Class _TelemetryObject
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

        _TelemetryObject([Object]$Key)
        {
            $This.ExternalIP       = Invoke-RestMethod "http://ifconfig.me/ip"
            $This.Ping             = Invoke-RestMethod "http://ipinfo.io/$($This.ExternalIP)"
            $This.Organization     = $Key.Organization
            $This.CommonName       = $Key.CommonName
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

    Class _CompanyObject
    {
        [Object]        $Telemetry
        [String]             $Name
        [String]       $Background
        [String]             $Logo
        [String]            $Phone
        [String]          $Website
        [String]            $Hours

        _CompanyObject([Object]$Telemetry,[Object]$Key)
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
            $This.Phone         = If (!$Key.Phone) { "N/A" } Else { $Key.Phone }
            $This.Website       = If(!$Key.Website) { "https://www.securedigitsplus.com" } Else { $Key.Website }
            $This.Hours         = If(!$Key.Hours  ) { "N/A" } Else { $Key.Hours }
        }

        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    Class _Icons
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

        _Icons([Int32]$Computer,[Int32]$ControlPanel,[Int32]$Documents,[Int32]$Libraries,[Int32]$Network)
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
            ForEach ( $I in "Computer ControlPanel Documents Libraries Network".Split(" ") )
            {
                Set-ItemProperty -Path $This.Path -Name $This.Hash.$I -Value $This.$I -Verbose
            }
        }

        [String] ToString()
        {
            Return @( $This.Hash.Keys )
        }
    }

    Class _BrandingState
    {
        [String] $Path
        [String] $Name
        [Object] $Value

        _BrandingState([String]$Path,[String]$Name,[Object]$Value)
        {
            $This.Path  = $Path
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class _BrandingObject
    {
        [Object]       $Provider
        [Object]        $Company
        Hidden [String[]] $Names = ("{0};{0}Style;Logo;Manufacturer;{1}Phone;{1}Hours;{1}URL;LockScreenImage;OEMBackground") -f "Wallpaper","Support" -Split ";"
        Hidden [Object]   $Items 
        Hidden [Object]  $Values
        [Object]    $Certificate 
        [Object]         $Branch
        [String]       $SiteLink
        [String]     $Background
        [String]           $Logo
        [String]        $Website
        [String]          $Phone
        [String]          $Hours
        [Object]          $Icons
        [Object]         $Output

        [String[]]     $FilePath = ("{0}\{1};{0}\{1}\{2};{0}\{1}\{2}\Backgrounds;{0}\Web\Screen;{0}\Web\Wallpaper\Windows;C:\ProgramData\Microsoft\" + 
                                    "User Account Pictures") -f "C:\Windows" , "System32" , "OOBE\Info" -Split ";"

        [String[]] $RegistryPath = @(("HKCU:\{0}\{1}\Policies\System;HKLM:\{0}\{1}\OEMInformation;HKLM:\{0}\{1}\Authentication\LogonUI\Background;" +
                                      "HKLM:\{0}\Policies\Microsoft\Windows\Personalization") -f "Software","Microsoft\Windows\CurrentVersion" -Split ";")

        _BrandingObject([Object]$Company)
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
            $This.Icons          = [_Icons]::New(0,1,0,1,0)
            $This.Items           = $This.RegistryPath[0,0,1,1,1,1,1,3,2]
            $This.Values          = @($This.Background,2,$This.Logo,$This.Provider,$This.Phone,$This.Hours,$This.Website,$This.Background,1)
            $This.Output          = @( 0..8 | % { [_BrandingState]::New($This.Items[$_],$This.Names[$_],$This.Values[$_]) })
        }

        BuildFilePath()
        {
            $OOBE = "{0}\OOBE" -f [Environment]::SystemDirectory

            If (!(Test-Path $OOBE))
            {
                New-Item $OOBE -ItemType Directory -Verbose
            }

            ForEach ( $I in 0..( $This.FilePath.Count - 1 ) )
            {                
                If ( ! ( Test-Path $This.FilePath[$I] ) )
                {
                    New-Item -Path $This.FilePath[$I] -ItemType Directory -Verbose -EA 0
                }
            }
        }

        BuildRegistryPath()
        {
            ForEach ( $I in 0..( $This.RegistryPath.Count - 1 ) )
            {
                $Item            = $This.RegistryPath[$I]

                If ( !(Test-Path $Item))
                {
                    New-Item -Path ($Item | Split-Path -Parent) -Name ($Item | Split-Path -Leaf) -Verbose
                }
            }
        }
            
        Copy()
        {
            0..5 | % { Copy-Item -Path @( $This.Logo, $This.Background )[0,0,1,1,1,0][$_] -Destination $This.FilePath[$_] -Verbose }
        }
         
        Set()
        {
            $This.Output  | % { Set-ItemProperty -Path $_.Path -Name $_.Name -Value $_.Value -Verbose }
        }

        Apply()
        {
            $This.BuildFilePath()
            $This.BuildRegistryPath()
            $This.Copy()
            $This.Set()
            $This.Icons.Set()
            
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewShadow -Value 1 -Verbose
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewShadow -Value 1 -Verbose
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0 -Verbose
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Verbose

            $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
            $networkConfig.SetDnsDomain($This.Company.Telemetry.CommonName)
            $networkConfig.SetDynamicDNSRegistration($true,$true)
            ipconfig /registerdns

            RunDll32 User32.Dll, UpdatePerUserSystemParameters
        }
    }

    $Graphics           = Get-FEModule -Graphics
    $Telemetry          = [_TelemetryObject]::New($Key)
    $Company            = [_CompanyObject]::New($Telemetry,$Key)

    [_BrandingObject]::New($Company)
}
