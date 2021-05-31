Class _FEDCPromo
{
    [Object]                              $Window
    [Object]                                  $IO
    [Object]                              $Module
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

    _FEDCPromo([Object]$Module)
    {
        $This.Window                            = Get-XamlWindow -Type FEDCPromo
        $This.IO                                = $This.Window.IO
        $This.Module                            = $Module
        
        If ( !$This.Module.Role.Network)
        {
            $This.Module.Role.GetNetwork()

            $This.Control                       = $This.Module.Role.Network

            If ( !$This.Control )
            {
                Throw "No network detected"
            }

            Write-Host "Scanning [~] Detected network hosts for NetBIOS Nodes"
            $This.Control.NetBIOSScan()

            $This.HostMap                       = $This.Control.NbtScan | ? NetBIOS
        }

        $This.Features                          = [_ServerFeatures]::New().Output

        $This.IO.DataGrid.ItemsSource           = $This.Features

        $This.DatabasePath                      = "$Env:SystemRoot\NTDS"
        $This.IO.DatabasePath.Text              = $This.DatabasePath

        $This.LogPath                           = "$Env:SystemRoot\NTDS"
        $This.IO.LogPath.Text                   = $This.LogPath 

        $This.SysvolPath                        = "$Env:SystemRoot\SYSVOL"
        $This.IO.SysvolPath.Text                = $This.SysvolPath
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
