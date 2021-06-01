Function FightingEntropy
{
    $base             = "github.com/mcc85s/FightingEntropy"
    $SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol 

    [Net.ServicePointManager]::SecurityProtocol = 3072

    Class _File
    {
        [String] $Type
        [String] $Name
        [String] $Path
        Hidden [String] $URL
        [Object] $Content

        _File([String]$Name,[String]$Type,[String]$Root)
        {
            $This.Name    = $Name
            $This.Type    = $Type
            $This.Path    = "$Root\$Name"
        }

        _Content([String]$Base)
        {
            $This.URL     = "$Base\$($This.Type)\$($This.Name)?raw=true"
            $This.Content = Invoke-WebRequest -Uri $This.URL -UseBasicParsing | % Content
        }

        _Write()
        {
            If ( $This.Name -match "\.+(jpg|jpeg|png|bmp|ico)" )
            {
                Set-Content -Path $This.Path -Value ([Byte[]]$This.Content) -Encoding Byte
            }

            Else
            {
                Set-Content -Path $This.Path -Value $This.Content
            }
        }
    }

    Class _OS
    {
        [Object] $Env
        [Object] $Var
        [Object] $PS
        [Object] $Ver
        [Object] $Major
        [Object] $Type

        _OS()
        {
            $This.Env   = Get-ChildItem Env:\
            $This.Var   = Get-ChildItem Variable:\
            $This.PS    = Get-Item Variable:\PSVersionTable | % Value
            $This.Ver   = Get-Item Variable:\PSVersionTable | % Value | % PSVersion
            $This.Major = $This.Ver.Major
            $This.Type  = $This.GetOSType()
        }

        [Object] GetItem([String]$Item)
        {
            $Return = @{ }

            ForEach ( $X in ( Get-Item -Path $Item | % GetEnumerator ) )
            { 
                $Return.Add($X.Name,$X.Value)
            }

            Return $Return
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
                    "RHELCentOS"
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

    Class _Manifest
    {
        [String[]]    $Classes = @(("Manifest Hive Root Install Module OS Info RestObject Host FirewallRule Drive Drives ViperBomb File Cache Icons",
                "Shortcut Brand Branding DNSSuffix DomainName ADLogin ADConnection FEDCPromo Certificate Company Key RootVar Share Source",
                "Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS Image Images Updates Role Win32_Client Win32_Server",
                "UnixBSD RHELCentOS DCFound" -join ' ') -Split " " | % { "_$_.ps1" })

        [String[]]    $Control = "Computer.png DefaultApps.xml $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "

        [String[]]  $Functions = ("Add-ACL","Complete-IISServer","Export-Ini","Get-Certificate","Get-DiskInfo","Get-FEDCPromo","Get-FEDCPromoProfile",
                "Get-FEHive","Get-FEHost","Get-FEImage","Get-FEManifest","Get-FEModule","Get-FENetwork","Get-FEOS","Get-FEService","Get-FEShare",
                "Get-MadBomb","Get-MDTModule","Get-ServerDependency","Get-ViperBomb","Get-XamlWindow","Import-FEImage","Install-FEModule",
                "Install-IISServer","New-ACLObject","New-Company","New-EnvironmentKey","New-FEImage","New-FEShare","Remove-FEModule","Remove-FEShare",
                "Show-ToastNotification","Update-FEShare","Write-Theme","Get-MDTOData","New-FEDeploymentShare","Start-VMGroup",
                "Install-VMGroup" | % { "$_.ps1" })

        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "

        _Manifest()
        {

        }
    }

    Class _Registry
    {
        [String] $Name
        [String] $Date
        [String] $Path
        [String] $Provider
        [String] $Status
        [String] $Type
        [String] $Version

        _Registry([String]$Company,[String]$Name,[String]$Version,[String]$Type)
        {
            $This.Name        = $Name
            $This.Date        = Get-Date -UFormat "%Y_%m%d-%H%M%S"
            $This.Provider    = $Company
            $This.Status      = "Initialized"
            $This.Type        = $Type
            $This.Version     = $Version

            ForEach ( $Item in $Company, $Name, $Version )
            {
                If ( $This.Path -eq $Null )
                {
                    $This.Path = "HKLM:\Software\Policies\$Item"
                }

                Else
                {
                    $This.Path = $This.Path, $Item -join "\"
                }

                If (!(Test-Path $This.Path))
                {
                    New-Item -Path (Split-Path $This.Path) -Name $Item -Verbose
                }
            }

            ForEach ( $Key in "Date Name Path Provider Status Type Version".Split(" ") )
            {
                If ((Get-ItemProperty $This.Path ).$Key -ne $This.$Key )
                {
                    Set-ItemProperty $This.Path -Name $Key -Value $This.$Key -Verbose
                }
            }
        }
    }

    Class _Module
    {
        [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
        [String]        $Name = "FightingEntropy"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]        $GUID = "ccd91f81-eec0-4a77-9fe2-0447245a9f54"
        [String]     $Version 
        [Object]          $OS = [_OS]::New()
        [Object]    $Manifest = [_Manifest]::New()
        [Object]    $Registry
        [String]     $Default
        [String]        $Main
        [String]       $Trunk
        [String]     $ModPath
        [String]     $ManPath
        [String]        $Path
        [Object]        $Tree
        [Object[]]   $Classes
        [Object[]]   $Control
        [Object[]] $Functions
        [Object[]]  $Graphics

        _Build()
        {
            $_Path = $Null

            ForEach ( $Item in $This.Path.Split("\") )
            {
                If ( $_Path -eq $Null )
                {
                    $_Path = $Item
                }

                Else
                {
                    $_Path = "$_Path\$Item"
                }

                If (!(Test-Path $_Path))
                {
                    New-Item $_Path -ItemType Directory -Verbose
                }
            }

            "Classes","Control","Functions","Graphics" | % { 

                If (!(Test-Path "$_Path\$_"))
                {
                    New-Item "$_Path\$_" -ItemType Directory -Verbose
                }
            }
        }

        Gather()
        {
            $O = 1
            ForEach ( $Object in $This.Classes, 
                                 $This.Control, 
                                 $This.Functions, 
                                 $This.Graphics )
            {
                $Type = "Classes Control Functions Graphics".Split(" ")[$O-1]
                Write-Host "Gathering $Type [$O/4]"
                $I = 1

                ForEach ( $Item in $Object )
                {
                    Write-Host "Downloading $Type [$I/$($Object.Count)] $($Item.Name)"
                    $Item._Content($This.Base)
                    $I ++
                }

                $O ++
            }
        }

        Save()
        {
            $O = 1
            ForEach ( $Object in $This.Classes, 
                                 $This.Control, 
                                 $This.Functions, 
                                 $This.Graphics )
            {
                $Type = "Classes Control Functions Graphics".Split(" ")[$O-1]
                Write-Host "Saving $Type [$O/4]"
                $I = 1

                ForEach ( $Item in $Object )
                {
                    Write-Host "Writing $Type [$I/$($Object.Count)] $($Item.Name)"
                    $Item._Write()
                    $I++
                }

                $O ++
            }
        }

        Write()
        {
            $Module        = @( )
            $Module       += "# Downloaded from {0}" -f $This.Base
            $Module       += "# {0}" -f $This.Root
            $Module       += "# {0}" -f $This.Version

            $Module       += "# <Classes>"

            $This.Classes    | % { 

                $Module   += "# <{0}/{1}>" -f $_.Type, $_.Name
                $Module   += "# {0}" -f $_.Path
                $Module   += $_.Content
                $Module   += "# </{0}/{1}>" -f $_.Type, $_.Name
            }

                $Module       += "# </Classes>"
                $Module       += "# <Functions>"

                $This.Functions  | % { 

                    $Module   += "# <{0}/{1}>" -f $_.Type, $_.Name
                    $Module   += "# {0}" -f $_.Path
                    $Module   += $_.Content
                    $Module   += "# </{0}/{1}>" -f $_.Type, $_.Name
                }

                $Module       += "# </Functions>"
                $Module         += "Write-Theme `"Loaded Module [+] FightingEntropy [$($This.Version)]`" 10,3,15,0"

                $This.Default    = $Env:PSModulePath -Split ";" | ? { $_ -match "Program Files" }
                $This.Main       = $This.Default,"FightingEntropy" -join "\"
                $This.Trunk      = $This.Main, $This.Version -join "\"
                $This.ModPath    = $This.Trunk, "FightingEntropy.psm1" -join "\"
                $This.ManPath    = $This.Trunk, "FightingEntropy.psd1" -join "\"

                If ( !(Test-Path $This.Main))
                {
                    New-Item $This.Main -ItemType Directory -Verbose
                }

                If ( !(Test-Path $This.Trunk))
                {
                    New-Item $This.Trunk -ItemType Directory -Verbose
                }

                Set-Content -Path $This.ModPath -Value $Module -Verbose

                $Item                    = @{  

                    GUID                 = $This.GUID
                    Path                 = $This.ManPath
                    ModuleVersion        = $This.Version
                    Copyright            = "(c) 2021 mcc85sx. All rights reserved."
                    CompanyName          = "Secure Digits Plus LLC" 
                    Author               = "mcc85sx / Michael C. Cook Sr."
                    Description          = "Beginning the fight against Identity Theft, and Cybercriminal Activities"
                    RootModule           = $This.ModPath   
                }

                New-ModuleManifest @Item
            }

        _Module([String]$Version)
        {
            $This.Version    = $Version
            $This.Path       = $Env:ProgramData,$This.Company,$This.Name,$Version -join "\"
            $This.Registry   = [_Registry]::New($This.Company,$This.Name,$Version,$This.OS.Type)
            $This.Default    = $Env:PSModulePath -Split ";" | ? { $_ -match "Program Files" }
            $This.Main       = $This.Default,"FightingEntropy" -join "\"
            $This.Trunk      = $This.Main, $Version -join "\"
            $This.ModPath    = $This.Trunk, "FightingEntropy.psm1" -join "\"
            $This.ManPath    = $This.Trunk, "FightingEntropy.psd1" -join "\"

            $This._Build()

            ForEach ( $Name in "Classes","Control","Functions","Graphics" )
            {
                $_Path = "$($This.Path)\$Name"

                If (!(Test-Path $_Path))
                {
                    New-Item $_Path -ItemType Directory -Verbose
                }

                $This.$Name = $This.Manifest.$Name | % { [_File]::New($_,$Name,$_Path) }
            }

            $This.Gather()
            $This.Save()
            $This.Write()

            $This.Tree = Get-ChildItem $This.Path -Recurse
        }
    }

    [_Module]::New("2021.6.0")

    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
}

$Install = FightingEntropy
$Install 
