Function FightingEntropy
{
    [Net.ServicePointManager]::SecurityProtocol = 3072

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

    Class File
    {
        [String] $Type
        [String] $Name
        [String] $Path
        Hidden [String] $URL
        [Object] $Content
        File([String]$Name,[String]$Type,[String]$Root)
        {
            $This.Name    = $Name
            $This.Type    = $Type
            $This.Path    = "$Root\$Name"
        }
        GetContent([String]$Base)
        {
            $This.URL     = "$Base/$($This.Type)/$($This.Name)?raw=true"
            $This.Content = Invoke-WebRequest -Uri $This.URL -UseBasicParsing | % Content
        }
        Write([UInt32]$PSVersion)
        {
            If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
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
            Return @( If ($This.Major -gt 5)
            {
                If (Get-Item Variable:\IsLinux | % Value)
                {
                    (hostnamectl | ? { $_ -match "Operating System" }).Split(":")[1].TrimStart(" ")
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

    Class Manifest
    {
        [String[]]      $Names = @("Classes","Control","Functions","Graphics")
        [String[]]    $Classes = @("_FirewallRule.ps1","_Drive.ps1","_Drives.ps1","_ViperBomb.ps1","_File.ps1","_Cache.ps1",
                                   "_Icons.ps1","_Shortcut.ps1")
        [String[]]    $Control = @("Computer.png","success.png","failure.png","DefaultApps.xml","header-image.png","MDT_LanguageUI.xml",
                                   "vendorlist.txt","zipcode.txt","FEClientMod.xml","FEServerMod.xml","MDTClientMod.xml","MDTServerMod.xml",
                                   "PSDClientMod.xml","PSDServerMod.xml")
        [String[]]  $Functions = @("Copy-FileStream.ps1","Get-AssemblyList.ps1","Get-ControlExtension.ps1","Get-DiskInfo.ps1",
                                   "Get-EnvironmentKey.ps1","Get-EventLogArchive.ps1","Get-EventLogConfigExtension.ps1",
                                   "Get-EventLogController.ps1","Get-EventLogProject.ps1","Get-EventLogRecordExtension.ps1",
                                   "Get-FEADLogin.ps1","Get-FEDCPromo.ps1","Get-FEHost.ps1","Get-FEImageManifest.ps1",
                                   "Get-FEInfo.ps1","Get-FEManifest.ps1","Get-FEModule.ps1","Get-FENetwork.ps1","Get-FEOS.ps1",
                                   "Get-FEProcess.ps1","Get-FERole.ps1","Get-FEService.ps1","Get-FESitemap.ps1","Get-MadBomb.ps1",
                                   "Get-MDTModule.ps1","Get-PowerShell.ps1","Get-PropertyItem.ps1","Get-PropertyObject.ps1",
                                   "Get-PSDLog.ps1","Get-PSDLogGUI.ps1","Get-PSDModule.ps1","Get-SystemDetails.ps1",
                                   "Get-ViperBomb.ps1","Get-WhoisUtility.ps1","Install-BossMode.ps1","Install-IISServer.ps1",
                                   "Install-PSD.ps1","Invoke-cimdb.ps1","Invoke-KeyEntry.ps1","New-EnvironmentKey.ps1",
                                   "New-FEInfrastructure.ps1","PSDController.psm1","PSDDeploymentShare.psm1","PSDFinal.ps1",
                                   "PSDGather.psm1","PSDStart.ps1","PSDUtility.psm1","PSDWizard.psm1","Load-WirelessNetwork.ps1",
                                   "Search-WirelessNetwork.ps1","Set-ScreenResolution.ps1","Show-ToastNotification.ps1",
                                   "Update-PowerShell.ps1","Use-Wlanapi.ps1","Write-Theme.ps1")
        [String[]]   $Graphics = @("background.jpg","banner.png","icon.ico","OEMbg.jpg","OEMlogo.bmp","sdplogo.png","PSDBackground.bmp")
        Manifest()
        {

        }
        [String] ToString()
        {
            Return "FEModuleManifest:\*"
        }
    }

    Class Registry
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
        Registry([String]$Base, [String]$Name, [String]$Description, [String]$Author, [String]$Company, [String]$Copyright, [String]$GUID, 
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
            ForEach ($Key in $This.Order)
            {
                If ((Get-ItemProperty $This.RegPath).$Key -ne $This.$Key)
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
        [String] ToString()
        {
            Return @($This.RegPath)
        }
    }

    Class FEModule
    {
        [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
        [String]        $Name = "FightingEntropy"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2022 (mcc85s/mcc85sx/sdp). All rights reserved."
        [String]        $GUID = "95023676-e2a6-405c-a9d3-dfa548c4d106"
        [String]     $Version = ""
        [Object]          $OS = [OS]::New()
        [Object]    $Manifest = [Manifest]::New()
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
        FEModule([String]$Version)
        {
            $This.Version            = $Version
            $This.Path               = $Env:ProgramData, $This.Company, $This.Name -join "\"
            Write-Host ("   Module: [{0}]" -f $This.Path)
            $This.Default            = $Env:PSModulePath -Split ";" | ? { $_ -match "Program Files" } | Select-Object -First 1
            $This.Main               = $This.Default + "\FightingEntropy"
            $This.Trunk              = $This.Main    + "\$Version"
            $This.ModPath            = $This.Trunk   + "\FightingEntropy.psm1"
            $This.ManPath            = $This.Trunk   + "\FightingEntropy.psd1"
            $This.Registry           = [Registry]::New($This.Base, $This.Name, $This.Description, 
                                        $This.Author, $This.Company, $This.Copyright, $This.GUID, 
                                        $This.Version, $This.Default, $This.Main, $This.Trunk,
                                        $This.ModPath, $This.ManPath, $This.Path, $This.OS.Type )

            Write-Host "[+] Module Staging complete"
            $This.Build()

            ForEach ( $Item in "Classes","Control","Functions","Graphics")
            {
                Write-Host "Prestaging [$Item]"
                $This.$Item          = $This.Manifest.$Item | % { [File]::New($_,$Item,"$($This.Path)\$Item") }
            }
            $This.Gather()
            $This.Save()
            $This.Write()

            $This.Tree                = Get-ChildItem $This.Path | ? Name -in $This.Manifest.Names
            $This.Role                = $This.OS.Type
        }
        Build()
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
            ForEach ($Item in "Classes","Control","Functions","Graphics")
            {
                If (!(Test-Path "$_Path\$Item"))
                {
                    New-Item "$_Path\$Item" -ItemType Directory -Verbose
                }
            }
        }
        Gather()
        {
            $O = 1
            ForEach ($Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics)
            {
                $Type = "Classes Control Functions Graphics".Split(" ")[$O-1]
                Write-Host "Gathering $Type [$O/4]"
                $I = 1
                ForEach ($Item in $Object)
                {
                    Write-Host "Downloading $Type [$I/$($Object.Count)] $($Item.Name)"
                    $Item.GetContent($This.Base)
                    $I ++
                }
                $O ++
            }
        }
        Save()
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
                    $Item.Write($This.OS.Major)
                    $I++
                }

                $O ++
            }
        }
        Write()
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
                RequiredAssemblies   = "PresentationFramework",
                                       "System.Runtime.WindowsRuntime",
                                       "System.IO.Compression", 
                                       "System.IO.Compression.Filesystem", 
                                       "System.Windows.Forms"
            }                        | % { New-ModuleManifest @_ }
        }
        [String] ToString()
        {
            Return $This.Version
        }
    }
    
    [FEModule]::New("2022.10.0")
    
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
Get-Item "Function:\FightingEntropy" | Remove-Item -Verbose
$Line    = (@("-")*120 -join "")
    
$Line, "[Installation Details (stored under variable `$Install)]"
$Install
$Line, "[Command (Get-FEModule) provides an extension of the above information]", $Line
