Function FightingEntropy
{
    [Net.ServicePointManager]::SecurityProtocol = 3072

    Class _Enum
    {
        [String] $Name
        [Object] $Value

        _Enum([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

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
            $This.URL     = "$Base/$($This.Type)/$($This.Name)?raw=true"
            $This.Content = Invoke-WebRequest -Uri $This.URL -UseBasicParsing | % Content
        }

        _Write([UInt32]$PSVersion)
        {
            If ( $This.Name -match "\.+(jpg|jpeg|png|bmp|ico)" )
            {
                Switch([UInt32]($PSVersion -le 5))
                {
                    0 { Set-Content -Path $This.Path -Value ([Byte[]]$This.Content) -AsByteStream  }
                    1 { Set-Content -Path $This.Path -Value ([Byte[]]$This.Content) -Encoding Byte }
                }
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
            $This.Env   = Get-ChildItem Env:\      | % { [_Enum]::New($_.Key,$_.Value) }
            $This.Var   = Get-ChildItem Variable:\ | % { [_Enum]::New($_.Name,$_.Value) }
            $This.PS    = $This.Var | ? Name -eq PSVersionTable | % Value | % GetEnumerator | % { [_Enum]::New($_.Name,$_.Value) }
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
        [String[]]      $Names = "Classes","Control","Functions","Graphics"

        [String[]]    $Classes = @(("FirewallRule Drive Drives ViperBomb File Cache Icons",
                "Shortcut Brand Branding DNSSuffix DomainName ADLogin ADConnection ADReplication FEDCPromo Certificate Company Key RootVar Share Source",
                "Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS Image Images Updates DCFound LocaleList LocaleItem" -join ' ') -Split " " | % { "_$_.ps1" })

        [String[]]    $Control = "Computer.png DefaultApps.xml header-image.png MDT_LanguageUI.xml $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "

        [String[]]  $Functions = ("Add-ACL","Complete-IISServer","Export-Ini","Get-FECertificate","Get-DiskInfo","Get-FEDCPromo","Get-FEDCPromoProfile",
                "Get-FEHive",
                "Get-FEHost",
                "Get-FEImage",
                "Get-FEManifest",
                "Get-FERole",
                "Get-FEInfo",
                "Get-FEModule",
                "Get-FENetwork",
                "Get-FEOS",
                "Get-FEService",
                "Get-FEShare",
                "Get-MadBomb","Get-MDTModule","Get-ServerDependency","Get-ViperBomb","Get-XamlWindow","Import-FEImage","Install-FEModule",
                "Install-IISServer","New-ACLObject","New-Company","New-EnvironmentKey","New-FEImage","New-FEShare","Remove-FEModule","Remove-FEShare",
                "Show-ToastNotification","Update-FEShare","Write-Theme","Get-MDTOData","New-FEDeploymentShare","Start-VMGroup",
                "Install-VMGroup","Invoke-KeyEntry","Copy-FileStream","Get-EnvironmentKey","Get-FEImageManifest","Invoke-cimdb",
                "Set-ScreenResolution" | % { "$_.ps1" })

        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "

        _Manifest()
        {

        }
    }

    Class _Registry
    {
        [String[]]        $Order = ("Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status Type" -Split " ")
        [String]           $Base
        [String]           $Name
        [String]    $Description
        [String]         $Author
        [String]        $Company
        [String]      $Copyright
        [String]           $GUID
        [String]        $Version
        [String]           $Date
        
        [String]        $RegPath
        [String]        $Default
        [String]           $Main
        [String]          $Trunk
        [String]        $ModPath
        [String]        $ManPath
        [String]           $Path
        
        [String]         $Status
        [String]           $Type

        _Registry([String]$Base, [String]$Name, [String]$Description, [String]$Author, [String]$Company, [String]$Copyright, [String]$GUID, 
        [String]$Version, [String]$Default, [String]$Main, [String]$Trunk, [String]$ModPath, [String]$ManPath, [String]$Path, [String]$Type)
        {
            $This.Base           = $Base
            $This.Name           = $Name
            $This.Description    = $Description
            $This.Author         = $Author
            $This.Company        = $Company
            $This.Copyright      = $Copyright
            $This.GUID           = $GUID
            $This.Version        = $Version
            $This.Date           = Get-Date -UFormat "%Y_%m%d-%H%M%S"
            $This.RegPath        = "HKLM:\Software\Policies"

            ForEach ( $Item in $Company, $Name, $Version )
            {
                $This.RegPath    = $This.RegPath, $Item -join "\"

                If (!(Test-Path $This.RegPath))
                {
                    New-Item -Path (Split-Path $This.RegPath) -Name $Item -Verbose
                }
            }

            $This.Default        = $Default
            $This.Main           = $Main
            $This.Trunk          = $Trunk
            $This.ModPath        = $ModPath
            $This.ManPath        = $ManPath

            $This.Path           = $Path
            $This.Type           = $Type
            $This.Status         = "Initialized"

            ForEach ( $Key in $This.Order )
            {
                If ((Get-ItemProperty $This.RegPath ).$Key -ne $This.$Key )
                {
                    Write-Host "[+] $Key set to [$($This.$Key)]"
                    Set-ItemProperty $This.RegPath -Name $Key -Value $This.$Key
                }

                Else 
                {
                    Write-Host "[!] $Key already set to [$($This.$Key)]"
                }
            }
        }
    }

    Class _Module
    {
        [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
        [String]        $Name = "FightingEntropy"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2021 (mcc85s/mcc85sx/sdp). All rights reserved."
        [String]        $GUID = "81320271-fd4a-4607-b164-4e66b12f8d3a"
        [String]     $Version = ""
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
        [Object]        $Role

        _Build()
        {
            $_Path = $Null
        
            ForEach ( $Item in $This.Path.Split("\") )
            {
                If (!($_Path))
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
        
            ForEach ( $Item in "Classes","Control","Functions","Graphics" )
            { 
                If (!(Test-Path "$_Path\$Item"))
                {
                    New-Item "$_Path\$Item" -ItemType Directory -Verbose
                }
            }
        }

        _Gather()
        {
            $O = 1
            ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
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

        _Save()
        {
            $O = 1
            ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
            {
                $Type = "Classes Control Functions Graphics".Split(" ")[$O-1]
                Write-Host "Saving $Type [$O/4]"
                $I = 1

                ForEach ( $Item in $Object )
                {
                    Write-Host "Writing $Type [$I/$($Object.Count)] $($Item.Name)"
                    $Item._Write($This.OS.Major)
                    $I++
                }

                $O ++
            }
        }

        _Write()
        {
            $Module        = @( )
            $Module       += "# Downloaded from {0}" -f $This.Base
            $Module       += "# {0}" -f $This.Path
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

            If (!(Test-Path $This.Main))
            {
                New-Item $This.Main -ItemType Directory -Verbose
            }

            If (!(Test-Path $This.Trunk))
            {
                New-Item $This.Trunk -ItemType Directory -Verbose
            }

            Set-Content -Path $This.ModPath -Value $Module -Verbose

            @{  
                GUID                 = $This.GUID
                Path                 = $This.ManPath
                ModuleVersion        = $This.Version
                Copyright            = $This.Copyright
                CompanyName          = $This.Company
                Author               = $This.Author
                Description          = $This.Description
                RootModule           = $This.ModPath
                RequiredAssemblies   = "PresentationFramework"
            }                        | % { New-ModuleManifest @_ }
        }

        _Module([String]$Version)
        {
            $This.Version            = $Version

            $This.Path               = $Env:ProgramData, $This.Company, $This.Name -join "\"
            Write-Host ("   Module: [{0}]" -f $This.Path)

            $This.Default            = $Env:PSModulePath -Split ";" | ? { $_ -match "Program Files" } | Select-Object -First 1
            $This.Main               = $This.Default + "\FightingEntropy"
            $This.Trunk              = $This.Main    + "\$Version"
            $This.ModPath            = $This.Trunk   + "\FightingEntropy.psm1"
            $This.ManPath            = $This.Trunk   + "\FightingEntropy.psd1"

            $This.Registry           = [_Registry]::New($This.Base, $This.Name, $This.Description, 
                                        $This.Author, $This.Company, $This.Copyright, $This.GUID, 
                                        $This.Version, $This.Default, $This.Main, $This.Trunk,
                                        $This.ModPath, $This.ManPath, $This.Path, $This.OS.Type )

            Write-Host "[+] Module Staging complete"

            $This._Build()

            ForEach ( $Item in "Classes","Control","Functions","Graphics")
            {
                Write-Host "Prestaging [$Item]"
                $This.$Item          = $This.Manifest.$Item | % { [_File]::New($_,$Item,"$($This.Path)\$Item") }
            }

            $This._Gather()
            $This._Save()
            $This._Write()

            $This.Tree                = Get-ChildItem $This.Path | ? Name -in $This.Manifest.Names
            $This.Role                = $This.OS.Type
        }
    }
    
    [_Module]::New("2021.8.0")
    
    $Path              = "$Env:Public\Desktop\FightingEntropy.lnk" 
    $Item              = (New-Object -ComObject WScript.Shell).CreateShortcut($Path)

    $Item.TargetPath   = "powershell"
    $Item.Arguments    = "-NoExit -ExecutionPolicy Bypass -Command `"Add-Type -AssemblyName PresentationFramework;Import-Module FightingEntropy;`$Module = Get-FEModule;`$Module`""
    $Item.Description  = "Beginning the fight against identity theft and cybercriminal activities."
    $Item.IconLocation = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico"
    $Item.Save()
    
    $bytes             = [System.IO.File]::ReadAllBytes($Path)
    $bytes[0x15]       = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

$Install = FightingEntropy
$Line    = (@("-")*120 -join "")
    
$Line, "[ Installation Details (stored under variable `$Install) ]"
$Install
$Line, "[ Command (Get-FEModule) provides an extension of the above information ]", $Line
