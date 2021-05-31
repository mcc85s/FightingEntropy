Function Update-FEShare
{
    [CmdLetBinding()]Param(
    [Parameter(ParameterSetName=0,Mandatory)][String]$ShareName,
    [Parameter(ParameterSetName=1,Mandatory)][Object]$Share,
    [ValidateSet(0,1,2)]
    [Parameter()][UInt32]$Mode,
    [Parameter(Mandatory)][PSCredential]$Credential = (Get-Credential),
    [Parameter(Mandatory)][Object]$Key)

    # Load Credential
    If (!($Credential))
    {
        $Credential = Get-Credential
    }

    If (!($Credential))
    {
        Throw "Invalid entry"
    }

    Class _BootImage
    {
        [Object] $Path
        [Object] $Name
        [Object] $Type
        [Object] $ISO
        [Object] $WIM
        [Object] $XML

        _BootImage([String]$Path,[String]$Name)
        {
            $This.Path = $Path
            $This.Name = $Name
            $This.Type = Switch ([UInt32]($This.Name -match "\(x64\)")) { 0 { "x86" } 1 { "x64" } }
            $Regex     = "($($This.Name -Replace "\(","\(" -Replace "\)","\)"))"

            ForEach ( $Item in ( Get-ChildItem $Path | ? Name -match $Regex ) )
            { 
                Switch($Item.Extension)
                {
                    .iso { $This.ISO = $Item }
                    .wim { $This.WIM = $Item }
                    .xml { $This.XML = $Item }
                }
            }
        }
    }

    Class _BootImages
    {
        [Object] $Images

        _BootImages([Object]$Directory)
        {
            $This.Images = @( )

            ForEach ( $Item in Get-ChildItem $Directory | ? Extension | % BaseName | Select-Object -Unique )
            {
                $This.Images += [_BootImage]::New($Directory,$Item)
            }
        }
    }

    # Load MDT(Module)
    Import-Module (Get-MDTModule)

    # Load FEShare(SMBShare)
    If ( $ShareName )
    {
        $Share = Get-FEShare -Name $ShareName
    }

    If (!($Share))
    {
        Throw "Specified share was not detected"
    }

    # Load FEShare(PSDrive)
    If (!(Get-PSDrive -Name $Share.Label -EA 0 ))
    {
        New-PSDrive -Name $Share.Label -PSProvider MDTProvider -Root $Share.Path -Description $Share.Description
    }

    $Module  = Get-FEModule
    $Root    = "$($Share.Label):\"
    $Control = "$($Share.Path)\Control"
    $Script  = "$($Share.Path)\Scripts"

    ForEach ($File in $Key.Background, $Key.Logo)
    {
        $Name = $File | Split-Path -Leaf
        $Item = "$Script\$Name"

        If (!(Test-Path $Item))
        {
            Copy-Item -Path $File -Destination $Script -Verbose
        }

        If ($File -notlike $Key.NetworkPath)
        {
            $Item = ("{0}\Scripts\$Name" -f $Key.NetworkPath)
        }

        Switch ($File)
        {
            $Key.Logo       { $Key.Logo       = $Item }
            $Key.Background { $Key.Background = $Item }
        }
    }

    $Install = @( )
    $Install += "[Net.ServicePointManager]::SecurityProtocol = 3072"
    $Install += (Invoke-RestMethod https://github.com/mcc85sx/FightingEntropy/blob/master/Install.ps1?raw=true)
    $Install += "`$Key = '$($Key | ConvertTo-Json)'`n"
    $Install += "`New-EnvironmentKey -Key `$Key | % Apply `n"

    Set-Content -Path $Script\Install.ps1 -Value $Install -Force -Verbose

    # Share Settings
    Set-ItemProperty $Root -Name Comments    -Value $("[FightingEntropy({0})]{1}" -f [Char]960,(Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]") ) -Verbose
    Set-ItemProperty $Root -Name MonitorHost -Value $Share.HostName -Verbose

    # Image Names/Background
    $Names  = 64 , 86 | % { "Boot.x$_" } | % { "$_.Generate{0}ISO $_.{0}WIMDescription $_.{0}ISOName $_.BackgroundFile" -f "LiteTouch" -Split " " }
    $Values = 64 , 86 | % { "$($Module.Name)(x$_)" } | % { "True;$_;$_.iso;$($Key.Background)" -Split ";" }

    ForEach ( $X in 0..($Names.Count - 1 ) )
    {
        If ( ( Get-ItemProperty -Path $Root | % $Names[$X] ) -ne $Values[$X] )
        {
            Set-ItemProperty -Path $Root -Name $Names[$X] -Value $Values[$X] -Verbose
        }
    }

    # Bootstrap
    Export-Ini -Path $Control\Bootstrap.ini -Value @{ 

        Settings           = @{ Priority             = "Default"                      }
        Default            = @{ DeployRoot           = $Key.NetworkPath
                                UserID               = $Credential.UserName
                                UserPassword         = $Credential.GetNetworkCredential().Password
                                UserDomain           = $Key.CommonName
                                SkipBDDWelcome       = "YES"                          }
    } | % Output

    # CustomSettings
    Export-Ini -Path $Control\CustomSettings.ini -Value @{

        Settings           = @{ Priority             = "Default" 
                                Properties           = "MyCustomProperty" }
        Default            = @{ _SMSTSOrgName        = $Key.Organization
                                JoinDomain           = $Key.CommonName
                                DomainAdmin          = $Credential.Username
                                DomainAdminPassword  = $Credential.GetNetworkCredential().Password
                                DomainAdminDomain    = $Key.CommonName
                                SkipDomainMembership = "YES"
                                OSInstall            = "Y"
                                SkipCapture          = "NO"
                                SkipAdminPassword    = "YES" 
                                SkipProductKey       = "YES" 
                                SkipComputerBackup   = "NO" 
                                SkipBitLocker        = "YES" 
                                KeyboardLocale       = "en-US" 
                                TimeZoneName         = Get-TimeZone | % ID
                                EventService         = "http://{0}:9800" -f $Key.NetworkPath.Split("\")[2] }
    } | % Output

    # Update FEShare(MDT)
    Switch($Mode)
    {
        0 { Update-MDTDeploymentShare -Path "$($Share.Label):\"                  -Force -Verbose }
        1 { Update-MDTDeploymentShare -Path "$($Share.Label):\" -Compress $False -Force -Verbose }
        2 { Update-MDTDeploymentShare -Path "$($Share.Label):\" -Compress $True  -Force -Verbose }
    }

    # Update/Flush FEShare(Images)
    $ImageLabel = Get-ItemProperty -Path "$($Share.Label):\" | % { 

        @{  64 = $_.'Boot.x64.LiteTouchWIMDescription'
            86 = $_.'Boot.x86.LiteTouchWIMDescription' }
    }

    Get-ChildItem -Path "$($Share.Path)\Boot" | ? Extension | % { 

        $Label          = $ImageLabel[$(Switch -Regex ($_.Name) { 64 {64} 86 {86}})]
        $Image          = @{ 

            Path        = $_.FullName
            Name        = $_.Name
            NewName     = "{0}{1}" -f $Label,$_.Extension
            Extension   = $_.Extension
        }

        If ( $Image.Name -match "LiteTouchPE_" )
        {
            If ( Test-Path $Image.NewName )
            {
                Remove-Item -Path $Image.NewName -Force -Verbose
            }

            Rename-Item -Path $Image.Path -NewName $Image.NewName
        }
    }

    # Service Running..?
    If (!(Get-Service | ? Name -eq WDSServer))
    {
        Throw "WDS Server not installed"
    }

    # Update/Flush FEShare(WDS)
    ForEach ( $Image in [_BootImages]::New("$($Share.Path)\Boot").Images )
    {        
        If (Get-WdsBootImage -Architecture $Image.Type -ImageName $Image.Name )
        {
            Write-Theme "Detected [!] $($Image.Name), removing..." 12,4,15,0
            Remove-WDSBootImage -Architecture $Image.Type -ImageName $Image.Name
        }

        Write-Theme "Importing [~] $($Image.Name)" 11,3,15,0
        Import-WdsBootImage -Path $Image.Wim.FullName -NewDescription $Image.Name
    }

    Restart-Service -Name WDSServer
}
