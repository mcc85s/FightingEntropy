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
    }

    Class Manifest
    {
        [String[]]      $Names = "Classes","Control","Functions","Graphics"
        [String[]]    $Classes = @(("FirewallRule Drive Drives ViperBomb File Cache Icons",
                "Shortcut Brand Branding DNSSuffix DomainName ADLogin ADConnection ADReplication FEDCPromo Certificate Company Key RootVar Share Source",
                "Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS Image Images Updates DCFound LocaleList LocaleItem" -join ' ') -Split " " | % { "_$_.ps1" })
        [String[]]    $Control = "Computer.png DefaultApps.xml header-image.png MDT_LanguageUI.xml zipcode.txt $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "
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
                "Set-ScreenResolution","Get-PSDModule","New-FEInfrastructure" | % { "$_.ps1" })
        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "
        Manifest()
        {

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
        Registry(
        [String]$Base, 
        [String]$Name, 
        [String]$Description, 
        [String]$Author, 
        [String]$Company, 
        [String]$Copyright, 
        [String]$GUID, 
        [String]$Version, 
        [String]$Default, 
        [String]$Main, 
        [String]$Trunk, 
        [String]$ModPath, 
        [String]$ManPath, 
        [String]$Path, 
        [String]$Type)
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

            If ($Type -match "Win")
            {
                $This.RegPath    = "HKLM:\Software\Policies",$This.Company,$This.Name,$This.Version -join '\'
            }
            If ($Type -notmatch "Win")
            {
                $This.RegPath    = "/etc",$This.Company,$This.Name,$This.Version -join '/'
            }

            $This.Default        = $Default
            $This.Main           = $Main
            $This.Trunk          = $Trunk
            $This.ModPath        = $ModPath
            $This.ManPath        = $ManPath
            $This.Path           = $Path
            $This.Type           = $Type.Replace(" ","_")
            $This.Status         = "Initialized"

            $This.TestPath()
            $This.GetObject()
        }
        TestPath()
        {
            If ($This.Type -match "Win")
            {
                $Split           = $This.RegPath.Split("\")
                $_Path           = $Split[0]
                ForEach ($X in 1..($Split.Count-1))
                {
                    $_Path           = $_Path, $_Path[$X] -join "\"
    
                    If (!(Test-Path $_Path))
                    {
                        New-Item -Path (Split-Path $_Path) -Name $Split[$X] -Verbose
                    }
                }
            }
            If ($This.Type -notmatch "Win")
            {
                $Split           = $This.RegPath.Split("/")
                $_Path           = "/$($Split[1])"
                ForEach ($X in 2..($Split.Count-1))
                {
                    $_Path       = $_Path, $Split[$X] -join "/"

                    If ((Test-Path "$_Path") -eq $False)
                    {
                        New-Item -Path (Split-Path $_Path) -Name $Split[$X] -ItemType Directory -Verbose
                    }
                }
                $This.WriteLinuxHive()
            }
        }
        WriteLinuxHive()
        {
            $Conf           = "$($This.RegPath)/linux.conf"
            $FEModule       = "$($This.RegPath)/FEModule.ps1"
            $File           = @{

                Order       = $This.Order
                Base        = $This.Base
                Name        = $This.Name
                Description = $This.Description
                Author      = $This.Author
                Company     = $This.Company
                Copyright   = $This.Copyright
                GUID        = $This.GUID
                Version     = $This.Version
                Date        = $This.Date
                RegPath     = $This.Path
                Default     = $This.Default
                Main        = $This.Main
                Trunk       = $This.Trunk
                ModPath     = $This.ModPath
                ManPath     = $This.ManPath
                Path        = $This.Path
                Status      = $This.Status
                Type        = $This.Type
            }
            $Value          = ForEach ($Key in $This.Order)
            {
                "[$Key]=`"$($File.$Key)`""
            }
            
            Set-Content -Path $Conf     -Value $Value -Verbose
            Set-Content -Path $FEModule -Value @'
            Function FEModule
            {
                [CmdLetBinding()]Param([String]$Conf)
                Class ItemProperty
                {
                    [String] $Name
                    [String] $Value
                    ItemProperty([String]$Line)
                    {
                        $This.Name  = [Regex]::Matches($Line,"^\[\w+\]").Value -Replace "(\[|\])",""
                        $This.Value = $Line -Replace $This.Name,"" -Replace '^\[\]\=','' -Replace '"',''
                    }
                }

                Class FEModule
                {
                    Hidden [String]    $Conf
                    Hidden [Object]    $Hive
                    Hidden [String[]] $Order = ("Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status Type" -Split " ")
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
                    FEModule([String]$Conf)
                    {
                        If (!(Test-Path $Conf))
                        {
                            Throw "Configuration file not present"
                        }
    
                        $This.Conf        = $Conf
                        $This.Hive        = Get-Content $Conf | % { [ItemProperty]$_ } 
                        $This.Base        = $This.Hive | ? Name -eq Base        | % Value
                        $This.Name        = $This.Hive | ? Name -eq Name        | % Value
                        $This.Description = $This.Hive | ? Name -eq Description | % Value
                        $This.Author      = $This.Hive | ? Name -eq Author      | % Value
                        $This.Company     = $This.Hive | ? Name -eq Company     | % Value
                        $This.Copyright   = $This.Hive | ? Name -eq Copyright   | % Value
                        $This.GUID        = $This.Hive | ? Name -eq GUID        | % Value
                        $This.Version     = $This.Hive | ? Name -eq Version     | % Value
                        $This.Date        = $This.Hive | ? Name -eq Date        | % Value
                        $This.RegPath     = $This.Hive | ? Name -eq RegPath     | % Value
                        $This.Default     = $This.Hive | ? Name -eq Default     | % Value
                        $This.Main        = $This.Hive | ? Name -eq Main        | % Value
                        $This.Trunk       = $This.Hive | ? Name -eq Trunk       | % Value
                        $This.ModPath     = $This.Hive | ? Name -eq ModPath     | % Value
                        $This.ManPath     = $This.Hive | ? Name -eq ManPath     | % Value
                        $This.Path        = $This.Hive | ? Name -eq Path        | % Value
                        $This.Status      = $This.Hive | ? Name -eq Status      | % Value
                        $This.Type        = $This.Hive | ? Name -eq Type        | % Value
                    }
                    SetItemProperty([String]$Property,[Object]$Value)
                    {
                        $This.Hive | ? Name -eq $Property | % { $_.Value = $Value }
                        Write-Host "Setting [~] [$Property] to [$Value]"
                        $This.Save()
                    }
                    [Object] GetItemProperty([String]$Property)
                    {
                        Return @( $This.Hive | ? Name -eq $Property )
                    }
                    Save()
                    {
                        $File           = @{

                            Order       = $This.Order
                            Base        = $This.Base
                            Name        = $This.Name
                            Description = $This.Description
                            Author      = $This.Author
                            Company     = $This.Company
                            Copyright   = $This.Copyright
                            GUID        = $This.GUID
                            Version     = $This.Version
                            Date        = $This.Date
                            RegPath     = $This.Path
                            Default     = $This.Default
                            Main        = $This.Main
                            Trunk       = $This.Trunk
                            ModPath     = $This.ModPath
                            ManPath     = $This.ManPath
                            Path        = $This.Path
                            Status      = $This.Status
                            Type        = $This.Type
                        }
                        $Value          = ForEach ($Key in $This.Order)
                        {
                            "[$Key]=`"$($File.$Key)`""
                        }

                        Set-Content -Path $This.Conf -Value $Value
                    }
                }
                [FEModule]::New($Conf)
            }
'@ -Verbose -Force
        }
        GetObject()
        {
            If ($This.Type -match "Win")
            {
                ForEach ($Key in $This.Order)
                {
                    If ((Get-ItemProperty $This.RegPath ).$Key -ne $This.$Key )
                    {
                        Write-Host "[+] [$Key] set to [$($This.$Key)]"
                        Set-ItemProperty $This.RegPath -Name $Key -Value $This.$Key
                    }

                    Else 
                    {
                        Write-Host "[!] [$Key] already set to [$($This.$Key)]"
                    }
                }
            }
            If ($This.Type -notmatch "Win")
            {
                $Conf     = "$($This.RegPath)/linux.conf"
                $FEModule = "$($This.RegPath)/FEModule.ps1"
                Import-Module $FEModule -Force
                $Property = FEModule $Conf

                ForEach ($Key in $This.Order)
                {
                    If ($Property.GetItemProperty($Key).Value -ne $This.$Key)
                    {
                        Write-Host "[+] $Key set to [$($This.$Key)]"
                        $Property.SetItemProperty($Key,$This.$Key)
                    }
                    Else
                    {
                        Write-Host "[!] $Key already set to [$($This.$Key)]"
                    }
                }
            }
        }
    }

    Class Module
    {
        [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
        [String]        $Name = "FightingEntropy"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2021 (mcc85s/mcc85sx/sdp). All rights reserved."
        [String]        $GUID = "64ab3ba6-064a-4929-b9a1-ffe27a55972a"
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
        Module([String]$Version)
        {
            $This.Version            = $Version

            If ($This.OS.Type -match "Win")
            {
                $This.Path               = $Env:ProgramData, $This.Company, $This.Name -join "\"
                Write-Host ("   Module: [{0}]" -f $This.Path)

                $This.Default            = $Env:PSModulePath -Split ";" | ? { $_ -match "Program Files" } | Select-Object -First 1
                $This.Main               = $This.Default + "\FightingEntropy"
                $This.Trunk              = $This.Main    + "\$Version"
                $This.ModPath            = $This.Trunk   + "\FightingEntropy.psm1"
                $This.ManPath            = $This.Trunk   + "\FightingEntropy.psd1"
            }

            If ($This.OS.Type -notmatch "Win")
            {
                $This.Path               = "/etc", $This.Company, $This.Name -join "/"
                Write-Host ("   Module: [{0}]" -f $This.Path)
                
                $This.Default            = $Env:PSModulePath.Split(":") | ? { $_ -match "[^\.]local" } | Select-Object -First 1
                $This.Main               = $This.Default + "/FightingEntropy"
                $This.Trunk              = $This.Main    + "/$Version"
                $This.ModPath            = $This.Trunk   + "/FightingEntropy.psm1"
                $This.ManPath            = $This.Trunk   + "/FightingEntropy.psd1"
            }

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
            #$This.Write()

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
        
            ForEach ( $Item in "Classes","Control","Functions","Graphics" )
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
            ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
            {
                $Type = "Classes Control Functions Graphics".Split(" ")[$O-1]
                Write-Host "Gathering $Type [$O/4]"
                $I = 1

                ForEach ( $Item in $Object )
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
                RequiredAssemblies   = "PresentationFramework"
            }                        | % { New-ModuleManifest @_ }
        }
    }
    
    $Module            = [Module]::New("2021.10.0")
    $Module
}
