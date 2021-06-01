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

    Class _Install
    {
        [String]           $Root = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        [String]           $Base = "github.com/mcc85s/FightingEntropy/blob/main"
        [String[]]        $Names = ("Classes Control Functions Graphics" -Split " ")
        [String]           $GUID = "ccd91f81-eec0-4a77-9fe2-0447245a9f54"
        [String]        $Version = "2021.6.0"
        [String]        $Default
        [String]           $Main
        [String]          $Trunk
        [String]        $ModPath
        [String]        $ManPath

        Hidden [Hashtable] $Hash = @{

            Classes   = ("Manifest Hive Root Install Module OS Info RestObject Host FirewallRule Drive Drives ViperBomb File Cache Icons",
            "Shortcut Brand Branding DNSSuffix DomainName ADLogin ADConnection FEDCPromo Certificate Company Key RootVar Share Source",
            "Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS Image Images Updates Role Win32_Client Win32_Server",
            "UnixBSD RHELCentOS DCFound" -join ' ') -Split " " | % { "_$_.ps1" }
            Control   = "Computer.png DefaultApps.xml $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "
            Functions = ("Add-ACL","Complete-IISServer","Export-Ini","Get-Certificate","Get-DiskInfo","Get-FEDCPromo","Get-FEDCPromoProfile",
            "Get-FEHive","Get-FEHost","Get-FEImage","Get-FEManifest","Get-FEModule","Get-FENetwork","Get-FEOS","Get-FEService","Get-FEShare",
            "Get-MadBomb","Get-MDTModule","Get-ServerDependency","Get-ViperBomb","Get-XamlWindow","Import-FEImage","Install-FEModule",
            "Install-IISServer","New-ACLObject","New-Company","New-EnvironmentKey","New-FEImage","New-FEShare","Remove-FEModule","Remove-FEShare",
            "Show-ToastNotification","Update-FEShare","Write-Theme","Get-MDTOData","New-FEDeploymentShare","Start-VMGroup",
            "Install-VMGroup" | % { "$_.ps1" })
            Graphics  = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "
        }

        [Object[]]   $Classes
        [Object[]]   $Control
        [Object[]] $Functions
        [Object[]]  $Graphics

        [String[]] List([String]$Type)
        {
            Return @( IRM "$($This.Base)/$Type/index.txt?raw=true" ) -Split "`n" | ? Length -gt 0
        }

        Build()
        {
            $Path = $Null

            ForEach ( $X in $This.Root.Split("\"))
            {
                If ( $Path -eq $Null )
                {
                    $Path = $X
                }

                Else
                {
                    $Path = "$Path\$X"
                }

                If (!(Test-Path $Path))
                {
                    New-Item $Path -ItemType Directory -Verbose
                }
            }
        }

        Gather()
        {
            $O = 1
            ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
            {
                $Type = $This.Names[$O-1]
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
            ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
            {
                $Type = $This.Names[$O-1]
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

        _Install()
        {
            $This.Build()

            ForEach ( $Name in $This.Names )
            {
                $Path = "$($This.Root)\$Name"

                If (!(Test-Path $Path))
                {
                    New-Item $Path -ItemType Directory -Verbose
                }

                $This.$Name = $This.Hash.$Name | % { [_File]::New($_,$Name,$Path) }
            }

            $This.Gather()
            $This.Save()
            $This.Write()
        }
    }

    [_Install]::New()

    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
}

FightingEntropy
