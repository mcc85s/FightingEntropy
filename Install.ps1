$base = "github.com/mcc85s/FightingEntropy"

[Net.ServicePointManager]::SecurityProtocol = 3072

Class _File
{
    [String] $Type
    [String] $Name
    [String] $Path
    [Object] $Content

    _File([String]$Name,[String]$Type,[String]$Root)
    {
        $This.Name    = $Name
        $This.Type    = $Type
        $This.Path    = "$Root\$Name"
    }

    _Content([String]$Base)
    {
        $This.Content = Invoke-WebRequest -Uri "$Base\$($This.Type)\$($This.Name)?raw=true" -UseBasicParsing -Verbose | % Content
    }

    _Write()
    {
        If ( $This.Name -match "\.+(jpg|jpeg|png|bmp|ico)" )
        {
            Set-Content -Path $This.Path -Value ([Byte[]]$This.Content) -Encoding Byte -Verbose
        }

        Else
        {
            Set-Content -Path $This.Path -Value $This.Content -Verbose
        }
    }
}

Class _Install
{
    [String]        $Root = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
    [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
    [String[]]     $Names = ("Classes Control Functions Graphics" -Split " ")
    [Hashtable]     $Hash = @{
        
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
                Write-Host "Downloading $Type [$I/$($Object.Count)]"
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
                Write-Host "Writing $Type [$I/$($Object.Count)]"
                $Item._Write()
                $I++
            }

            $O ++
        }
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
    }
}

$Install = [_Install]::New()
