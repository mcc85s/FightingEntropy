Function Get-FEDCPromo
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [ValidateSet(0,1,2,3)]
    [Parameter(ParameterSetName=0)][UInt32]$Mode = 0,
    [ValidateSet("Forest","Tree","Child","Clone")]
    [Parameter(ParameterSetname=1)][String]$Type,
    [Parameter()][Switch]$Test)

    $ADDS = Get-WindowsFeature | ? Name -match AD-Domain-Services
    
    If ( $ADDS.InstallState -eq "Available" )
    {
        Write-Theme "Exception [!] Must have ADDS installed first" 12,4,15,0
        
        Switch($Host.UI.PromptForChoice("Exception [!] ","Must have ADDS installed first, install it?",
        [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes","&No"),0))
        {
            0 
            {  
                Install-WindowsFeature -Name $ADDS.Name -IncludeAllSubFeature -IncludeManagementTools
            } 
            
            1 
            {  
                Throw "Exception [!] Must have ADDS installed first" 
            }
        }
    }

    Class _DomainName
    {
        [String]             $String
        [String]               $Type
    
        Hidden [Object]        $Slot = @{ NetBIOS = @{ Min = 1; Max = 15 }; Domain = @{ Min = 2; Max = 63 }; SiteName = @{ Min = 2; Max = 63 } }
        Hidden [Char[]]       $Allow = [Char[]]@(45,46;48..57;65..90;97..122)
        Hidden [Char[]]        $Deny = [Char[]]@(32..44;47;58..64;91..96;123..126)
        Hidden [Hashtable] $Reserved = @{
    
            Words             = ( "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GROUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;" + 
                                  "DIALUP;DIGEST AUTH;INTERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN;NTLM AU" + 
                                  "TH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZ" + 
                                  "ATION;USERS;WORLD") -Split ";"
            DNSHost           = ( "-GATEWAY","-GW","-TAC" )
            SDDL              = ( "AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS," + 
                                  "RU,SA,SI,SO,SU,SY,WD") -Split ','
        }

        _DomainName([String]$Type,[String]$String)
        {
            If ( $Type -notin $This.Slot.Keys )
            {
                Throw "Invalid type"
            }

            $This.String = $String
            $This.Type   = $Type
            $This.Slot   = $This.Slot["$($Type)"]

            If ( $This.String -in $This.Reserved.Words )
            {
                Throw "Entry is reserved"
            }

            If ( $This.String.Length -le $This.Slot.Min )
            {
                Throw "Input does not meet minimum length"
            }

            If ( $This.String.Length -ge $This.Slot.Max )
            {
                Throw "Input exceeds maximum length"
            }

            If ( $This.String.ToCharArray() | ? { $_ -notin $This.Allow -or $_ -in $This.Deny } )
            { 
                Throw "Name has invalid characters"
            }
        
            If ( $This.String[0,-1] -notmatch "(\w)" )
            {
                Throw "First/Last Character not alphanumeric" 
            }

            Switch($This.Type)
            {
                NetBIOS  
                { 
                    If ( "." -in $This.String.ToCharArray() ) 
                    { 
                        Throw "Period found in NetBIOS Domain Name, breaking" 
                    }
                }

                Domain
                { 
                    If ( $This.String.Split('.').Count -lt 2 )
                    {
                        Throw "Not a valid domain name, single label domain names are disabled"
                    }
                
                    If ( $This.String -in $This.Reserved.SDDL )
                    { 
                        Throw "Name is reserved" 
                    }

                    If ( ( $This.String.Split('.')[-1].ToCharArray() | ? { $_ -match "(\D)" } ).Count -eq 0 )
                    {
                        Throw "Top Level Domain must contain a non-numeric."   
                    }
                }

                Default {}
            }
        }
    }

    Class _ServerFeature
    {
        [String] $Name
        [String] $DisplayName
        [Bool]   $Installed

        _ServerFeature([String]$Name,[String]$DisplayName,[Int32]$Installed)
        {
            $This.Name           = $Name -Replace "-","_"
            $This.DisplayName    = $Displayname
            $This.Installed      = $Installed
        }
    }

    Class _ServerFeatures
    {
        Static [String[]] $Names = ("AD-Domain-Services DHCP DNS GPMC RSAT RSAT-AD-AdminCenter RSAT-AD-PowerShell RSAT-AD-T" +
                                    "ools RSAT-ADDS RSAT-ADDS-Tools RSAT-DHCP RSAT-DNS-Server RSAT-Role-Tools WDS WDS-Admin" + 
                                    "Pack WDS-Deployment WDS-Transport").Split(" ")
        [Object[]]       $Output

        _ServerFeatures()
        { 
            $This.Output         =  @( )
            Get-WindowsFeature   | ? Name -in ([_ServerFeatures]::Names) | % { 
        
                $This.Output    += [_ServerFeature]::New($_.Name, $_.DisplayName, $_.Installed)
            }    
        }
    }

    Class _DCFound
    {
        [Object]  $Window
        [Object]      $IO
        [Object] $Control

        _DCFound([Object]$Connection)
        {
            $This.Window  = Get-XamlWindow -Type FEDCFound
            $This.IO      = $This.Window.IO
            $This.Control = $Connection
        }
    }

    Class _FEDCPromo
    {
        [Object]                              $Window
        [Object]                                  $IO
        [Object]                             $Control
        [Object]                             $HostMap
        [Object]                          $Connection
        [Object]                            $Features
        [String]                             $Command
        [Int32]                                 $Mode
        [Object]                             $Profile
        [Object]                          $ForestMode
        [Object]                          $DomainMode
        [Object]                          $DomainType
        [Object]                          $InstallDNS
        [Object]                 $CreateDNSDelegation
        [Object]                     $NoGlobalCatalog
        [Object]             $CriticalReplicationOnly
        [Object]                    $ParentDomainName
        [Object]                          $DomainName
        [Object]                   $DomainNetBIOSName
        [Object]                       $NewDomainName
        [Object]                $NewDomainNetBIOSName
        [Object]                 $ReplicationSourceDC
        [Object]                            $SiteName
        [Object]                        $DatabasePath
        [Object]                             $LogPath
        [Object]                          $SysvolPath
        [Object]       $SafeModeAdministratorPassword
        [Object]                          $Credential

        [Object]                              $Output

        _FEDCPromo()
        {
            $This.Window                            = Get-XamlWindow -Type FEDCPromo
            $This.IO                                = $This.Window.IO
            $This.Control                           = Get-FENetwork

            If ( !$This.Control )
            {
                Throw "No network detected"
            }

            Write-Host "Scanning [~] Detected network hosts for NetBIOS Nodes"
                
            $This.Control                           | % NetBIOSScan
            $This.HostMap                           = $This.Control.NbtScan | ? NetBIOS | ? { $_.NBT.ID -match "(1B|1C)" }
            $This.Features                          = [_ServerFeatures]::New().Output

            $This.IO.DataGrid.ItemsSource           = $This.Features

            "$Env:SystemRoot\NTDS"                  | % {

                $This.DatabasePath                  = $_
                $This.IO.DatabasePath.Text          = $_
                $This.LogPath                       = $_
                $This.IO.LogPath.Text               = $_
                $This.SysvolPath                    = $_.Replace("NTDS","SYSVOL")
                $This.IO.SysvolPath.Text            = $_.Replace("NTDS","SYSVOL")
            }
        }

        SetMode([Int32]$Mode)
        {
            $This.Command                              = ("{0}Forest {0}{1} {0}{1} {0}{1}Controller" -f "Install-ADDS","Domain").Split(" ")[$Mode]
            $This.Mode                                 = $Mode
            $This.Profile                              = (Get-FEDCPromoProfile -Mode $Mode)

            $This.IO.Forest.IsChecked                  = $False
            $This.IO.Tree.IsChecked                    = $False
            $This.IO.Child.IsChecked                   = $False
            $This.IO.Clone.IsChecked                   = $False

            $This.IO.$($This.Profile.Slot).IsChecked   = $True

            # Domain Type/Parent/RepDC
            ForEach ( $Type in $This.Profile.Type )
            {
                $This.IO."_$($Type.Name)".Visibility   = @("Collapsed","Visible")[$Type.IsEnabled]
            
                If ( $Type.IsEnabled )
                {
                    $Type.Value                        = Switch($Type.Name)
                    {
                        ForestMode          { $This.IO.ForestMode.SelectedIndex  }
                        DomainMode          { $This.IO.DomainMode.SelectedIndex  }
                        ParentDomainName    {                         "<Domain>" }
                        ReplicationSourceDC {                            "<Any>" }
                    }
                }

                Else 
                {
                    $Type.Value                        = ""
                }

                $This.IO.$($Type.Name).IsEnabled       = $Type.IsEnabled
            
                @("Text","SelectedIndex")[$Type.Name -match "Mode"] | % { 
            
                    $This.IO.$($Type.Name).$($_)       = $Type.Value
                }
            }

            # Domain/Text
            ForEach ( $Text in $This.Profile.Text )
            {
                $This.IO.$(   $Text.Name ).IsEnabled  = $Text.IsEnabled
                $This.IO."_$( $Text.Name )".Visibility = @("Collapsed","Visible")[$Text.IsEnabled]
                $This.IO.$(   $Text.Name ).Text       = $Text.Text
            }

            # Roles
            ForEach ( $Role in $This.Profile.Role )
            {
                $This.IO.$( $Role.Name ).IsEnabled     = $Role.IsEnabled
                $This.IO.$( $Role.Name ).IsChecked     = $Role.IsChecked
            }

            # Credential
            If ( $Mode -eq 0 )
            {
                $This.IO._Credential.Visibility        = "Collapsed"
                $This.IO.Credential.Text               = ""
                $This.IO.Credential.IsEnabled          = $False
            }

            Else
            {
                $This.IO._Credential.Visibility        = "Visible"
                $This.IO.Credential.Text               = $This.Connection.Credential | ? Username | % Username
                $This.IO.Credential.IsEnabled          = $False
            }

            $This.Output                               = @( )
        }
    
        GetADConnection()
        {
            $This.Connection                         = [_ADConnection]::New($This.Hostmap)
        }
    }

    Write-Host "Loading Network [~] FightingEntropy Domain Controller Promotion Tool"

    $UI                   = [_FEDCPromo]::New()
    If ($Type)
    {
        $Mode = Switch ($Type) { Forest {0} Tree {1} Child {2} Clone {3} }
    }

    $UI.SetMode($Mode)

    $UI.IO.Forest.Add_Click({$UI.SetMode(0)})
    $UI.IO.Tree.Add_Click({$UI.SetMode(1)})
    $UI.IO.Child.Add_Click({$UI.SetMode(2)})
    $UI.IO.Clone.Add_Click({$UI.SetMode(3)})
    $UI.IO.Cancel.Add_Click({$UI.IO.DialogResult = $False})

    $Max                  = Switch -Regex ($UI.Module.Role.Caption)
    {
        "(2000)"         { 0 }
        "(2003)"         { 1 }
        "(2008)+(R2){0}" { 2 }
        "(2008 R2){1}"   { 3 }
        "(2012)+(R2){0}" { 4 }
        "(2012 R2){1}"   { 5 }
        "(2016|2019)"    { 6 }
    }

    $UI.IO.ForestMode.SelectedIndex = $Max
    $UI.IO.DomainMode.SelectedIndex = $Max
    $UI.GetADConnection()

    $UI.IO.CredentialButton.Add_Click({

        $UI.Connection.Target           = $Null
        $DC                             = [_DCFound]::New($UI.Connection)
        $DC.IO.DataGrid.ItemsSource     = $DC.Control.Output
        $DC.IO.DataGrid.SelectedIndex   = 0
        [Void]$DC.IO.DataGrid.Focus()

        $DC.IO.Cancel.Add_Click(
        {
            $DC.IO.DialogResult         = $False
        })

        $DC.IO.Ok.Add_Click(
        {
            $UI.Connection.Target       = $UI.Connection.Output[$DC.IO.DataGrid.SelectedIndex]
            $DC.IO.DialogResult         = $True
        })

        $DC.Window.Invoke()

        If ($DC.IO.DialogResult -eq $True -and $UI.Connection.Target -ne $Null)
        {
            $DC                         = [_ADLogin]::New($UI.Connection.Target)

            $DC.IO.Switch.Add_Click({

                $DC.IO.Port.IsEnabled = $True
            })

            $DC.IO.Cancel.Add_Click(
            {
                $UI.Credential          = $Null
                $UI.IO.Credential.Text  = ""
                $DC.IO.DialogResult     = $False
            })

            $DC.IO.Ok.Add_Click(
            {
                $DC.CheckADCredential()

                If ( $DC.Test.distinguishedName )
                {
                    $DC.Searcher            = [System.DirectoryServices.DirectorySearcher]::New()
                    $DC.Searcher            | % { 
                    
                        $_.SearchRoot       = [System.DirectoryServices.DirectoryEntry]::New($DC.Directory,$DC.Credential.Username,$DC.Credential.GetNetworkCredential().Password)
                        $_.PageSize         = 1000
                        $_.PropertiestoLoad.Clear()
                    }

                    $DC.Result              = $DC.Searcher | % FindAll
                    $DC.IO.DialogResult     = $True
                }

                Else
                {
                    [System.Windows.MessageBox]::Show("Invalid Credentials")
                }
            })

            $DC.Window.Invoke()

            $UI.Credential             = $DC.Credential
                                         $DC.ClearADCredential()

            $UI.Connection.Return      = $DC
            $UI.IO.Credential          | % {
                
                $_.Text                = $UI.Credential.UserName
                $_.IsEnabled           = $False
            }

            Switch ($UI.Mode)
            {
                0
                {
                    $UI.IO.ParentDomainName.Text     = ""
                    $UI.IO.DomainName.Text           = "<New Forest Name>"
                    $UI.IO.DomainNetBIOSName.Text    = "<New Forest NetBIOS Name>"
                    $UI.IO.SiteName.Text             = "<New Forest Sitename>"
                    $UI.IO.NewDomainName.Text        = ""
                    $UI.IO.NewDomainNetBIOSName.Text = ""
                    $UI.ReplicationSourceDC.Text     = ""
                }

                1
                {
                    $UI.IO.ParentDomainName.Text     = $DC.Domain
                    $UI.IO.DomainName.Text           = ""
                    $UI.IO.DomainNetBIOSName.Text    = ""
                    $UI.IO.Sitename.Text             = $DC.GetSiteName()
                    $UI.IO.NewDomainName.Text        = "<New Domain Name>"
                    $UI.IO.NewDomainNetBIOSName.Text = "<New Domain NetBIOS Name"
                    $UI.IO.ReplicationSourceDC.Text  = ""
                }

                2
                {
                    $UI.IO.ParentDomainName.Text     = $DC.Domain
                    $UI.IO.DomainName.Text           = ""
                    $UI.IO.DomainNetBIOSName.Text    = ""
                    $UI.IO.Sitename.Text             = $DC.GetSiteName()
                    $UI.IO.NewDomainName.Text        = "<New Domain Name>"
                    $UI.IO.NewDomainNetBIOSName.Text = "<New Domain NetBIOS Name"
                    $UI.IO.ReplicationSourceDC.Text  = ""
                }

                3
                {
                    $UI.IO.ParentDomainName.Text     = ""
                    $UI.IO.DomainName.Text           = $DC.Domain
                    $UI.IO.DomainNetBIOSName         = $DC.GetNetBIOSName()
                    $UI.IO.SiteName.Text             = $DC.GetSiteName()
                    $UI.IO.NewDomainName.Text        = ""
                    $UI.IO.NewDomainNetBIOSName.Text = ""
                    $UI.IO.ReplicationSourceDC.Text  = $UI.Connection.Target.Hostname
                }
            }
        }
    })

    $UI.IO.Start.Add_Click(
    {
        $Password                             = $UI.IO.SafeModeAdministratorPassword
        $Confirm                              = $UI.IO.Confirm

        If (!$Password.Password)
        {
            [System.Windows.MessageBox]::Show("Invalid password")
        }

        ElseIf ($Password.Password -ne $Confirm.Password)
        {
            [System.Windows.Messagebox]::Show("Password does not match")
        }

        Else
        {
            $UI.SafeModeAdministratorPassword = $Password.SecurePassword
            # Types

            $UI.DomainType = @("-","TreeDomain","ChildDomain","-")[$UI.Mode]

            ForEach ( $Type in $UI.Profile.Type )
            {
                If ($Type.IsEnabled)
                {
                    Switch ($Type.Name)
                    {
                        ForestMode          
                        { 
                            $UI.ForestMode          = $UI.IO.ForestMode.SelectedIndex
                        }

                        DomainMode
                        { 
                            $UI.DomainMode          = $UI.IO.DomainMode.SelectedIndex
                        }

                        ReplicationSourceDC 
                        {
                            $UI.ReplicationSourceDC = [_DomainName]::New("Domain",$UI.IO.ReplicationSourceDC.Text).String
                        }

                        ParentDomainName    
                        { 
                            $UI.ParentDomainName    = [_DomainName]::New("Domain",$UI.IO.ParentDomainName.Text).String
                        }
                    }
                }

                If (!$Type.IsEnabled)
                {
                    Switch($Type.Name)
                    {
                        ForestMode          { $UI.ForestMode          = "-" }
                        DomainMode          { $UI.DomainMode          = "-" }
                        ReplicationSourceDC { $UI.ReplicationSourceDC = "-" }
                        ParentDomainName    { $UI.ParentDomainName    = "-" }
                    }
                }
            }

            ForEach ( $Type in $UI.Profile.Text )
            {
                If ( $Type.IsEnabled )
                {
                    Switch ($Type.Name)
                    {
                        ParentDomainName     
                        { 
                            $UI.ParentDomainName     = [_DomainName]::New("Domain",$UI.IO.ParentDomainName.Text).String
                        }

                        DomainName
                        {
                            $UI.DomainName           = [_DomainName]::New("Domain",$UI.IO.DomainName.Text).String
                        }

                        DomainNetBIOSName
                        { 
                            $UI.DomainNetBIOSName    = [_DomainName]::New("NetBIOS",$UI.IO.DomainNetBIOSName.Text).String
                        }

                        SiteName             
                        {
                            $UI.SiteName             = [_DomainName]::New("SiteName",$UI.IO.SiteName.Text).String
                        }

                        NewDomainName        
                        { 
                            $UI.NewDomainName        = [_DomainName]::New("Domain",$UI.IO.NewDomainName.Text).String
                        }

                        NewDomainNetBIOSName 
                        { 
                            $UI.NewDomainNetBIOSName = [_DomainName]::New("NetBIOS",$UI.IO.NewDomainNetBIOSName.Text).String
                        }
                    }
                }

                If (!$Type.IsEnabled)
                {
                    Switch($Type.Name)
                    {
                        ParentDomainName     { $UI.ForestMode           = "-" }
                        DomainName           { $UI.DomainMode           = "-" }
                        DomainNetBIOSName    { $UI.DomainNetBIOSName    = "-" }
                        Sitename             { $UI.ParentDomainName     = "-" }
                        NewDomainName        { $UI.NewDomainName        = "-" }
                        NewDomainNetBIOSName { $UI.NewDomainNetBIOSName = "-" }
                    }
                }
            }

            ForEach ( $Type in $UI.Profile.Role )
            {
                If ( $Type.IsEnabled )
                {
                    Switch ($Type.Name)
                    {
                        InstallDns              
                        {
                            $UI.InstallDNS              = $UI.IO.InstallDNS.IsChecked
                        }

                        CreateDnsDelegation     
                        {
                            $UI.CreateDnsDelegation     = $UI.IO.CreateDnsDelegation.IsChecked
                        }

                        CriticalReplicationOnly
                        {
                            $UI.CriticalReplicationOnly = $UI.IO.CriticalReplicationOnly.IsChecked
                        }

                        NoGlobalCatalog         
                        {
                            $UI.NoGlobalCatalog         = $UI.IO.NoGlobalCatalog.IsChecked
                        }
                    }
                }

                If (!$Type.IsEnabled)
                {
                    Switch($Type.Name)
                    {
                        InstallDns               { $UI.InstallDNS              = $False }
                        CreateDnsDelegation      { $UI.CreateDNSDelegation     = $False }
                        CriticalReplicationOnly  { $UI.CriticalReplicationOnly = $False }
                        NoGlobalCatalog          { $UI.NoGlobalCatalog         = $False }
                    }
                }
            }

            $UI.IO.DialogResult               = $True
        }
    })

    $UI.Window.Invoke()

    If ($UI.IO.DialogResult)
    {
        $Reboot = 0

        ForEach ( $Feature in $UI.Features )
        {
            $Feature.Name = $Feature.Name -Replace "_","-"
            
            If (!$Feature.Installed)
            {
                If ($Test) 
                { 
                    Write-Host "Install-WindowsFeature -Name $($Feature.Name) -IncludeAllSubFeature -IncludeManagementTools" -F Cyan
                } 
                
                Else 
                {
                    $X = Install-WindowsFeature -Name $($Feature.Name) -IncludeAllSubFeature -IncludeManagementTools
                    If ($X.RestartNeeded)
                    {
                        $Reboot = 1
                    }
                }
            }

            If ($Feature.Installed)
            {
                Write-Host "$($Feature.Name) is already installed." -F Red
            }
        }

        $UI.Output = @{ }

        ForEach ( $Group in $UI.Profile.Type, $UI.Profile.Role, $UI.Profile.Text )
        {
            ForEach ( $Item in $Group )
            {
                If ( $Item.IsEnabled )
                {
                    If ( !$UI.Output[$Item.Name] )
                    {
                        $UI.Output.Add($Item.Name,$UI.$($Item.Name))
                    }
                }
            }
        }

        "Database Log Sysvol".Split(" ") | % { "$_`Path"} | % { $UI.Output.Add($_,$UI.$_) }

        If ( $UI.Credential )
        {
            $UI.Output.Add("Credential",$UI.Credential)
            $UI.Output.Add("SafeModeAdministratorPassword",$UI.SafeModeAdministratorPassword)
        }

        $Splat = $UI.Output

        If ($Reboot -eq 1)
        {
            Write-Host "Reboot [!] required to proceed."

            $Value = @(
            "Remove-Item $Env:Public\script.ps1 -Force -EA 0",
            "Unregister-ScheduledTask -TaskName FEDCPromo -Confirm:`$False"
            "@{"," "
            ForEach ( $Item in $Splat.GetEnumerator() )
            {
                Switch ($Item.Name)
                {
                    SafeModeAdministratorPassword 
                    { 
                        "    SafeModeAdministratorPassword = '{0}' | ConvertTo-SecureString -AsPlainText -Force" -f $UI.IO.Confirm.Password 
                    }
                    Credential 
                    { 
                        "    Credential = [System.Management.Automation.PSCredential]::New('{0}',('{1}' | ConvertTo-SecureString -AsPlainText -Force))" -f $UI.Credential.UserName,$UI.Credential.GetNetworkCredential().Password 
                    }

                    Default    
                    { 
                        If ( $Item.Value -in "True","False")
                        {
                            "    {0}=$`{1}" -f $Item.Name,$Item.Value
                        }

                        Else
                        {
                            "    {0}='{1}'" -f $Item.Name,$Item.Value
                        }
                    }
                }
            }
            " ","} | % { $($UI.Command) @_ -Force }")

            Set-Content "$Env:Public\script.ps1" -Value $Value -Force
            $Action = New-ScheduledTaskAction -Execute PowerShell -Argument "-ExecutionPolicy Bypass -Command (& $Env:Public\script.ps1)"
            $Trigger = New-ScheduledTaskTrigger -AtLogon
            Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName FEDCPromo -Description "Restarting, then promote system"
            Restart-Computer
        }
        
        If ($Test)
        {
            Switch ($UI.Mode)
            {
                0 { Test-ADDSForestInstallation @Splat }
                1 { Test-ADDSDomainInstallation @Splat }
                2 { Test-ADDSDomainInstallation @Splat }
                3 { Test-ADDSDomainControllerInstallation @Splat }
            }
        }

        Else
        {
            Switch ( $UI.Mode )
            {
                0 { Install-ADDSForest @Splat }
                1 { Install-ADDSDomain @Splat }
                2 { Install-ADDSDomain @Splat }
                3 { Install-ADDSDomainController @Splat }
            }
        }
    }

    Else
    {
        Write-Theme "Exception [!] Either the user cancelled, or the dialog failed" 12,4,15,0
    }
}
