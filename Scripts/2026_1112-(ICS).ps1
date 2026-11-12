// PowerShell script to get ICS working on windows between source and target adapters

Enum DedicationState
{
    Unspecified
    Source
    Target
}

Enum SharingPrivacy
{
    Public
    Private
}

Enum ConnectionStatus
{
    Disconnected             = 0
    Connecting               = 1
    Connected                = 2
    Disconnecting            = 3
    HardwareNotPresent       = 4
    HardwareDisabled         = 5
    HardwareMalfunction      = 6
    MediaDisconnected        = 7
    Authenticating           = 8
    AuthenticationSucceeded  = 9
    AuthenticationFailed     = 10
    InvalidAddress           = 11
    CredentialsRequired      = 12
    ActionRequired           = 13
    ActionRequiredRetry      = 14
    ConnectFailed            = 15
}

Enum ConnectionMedia
{
    None                = 0
    Direct              = 1
    ISDN                = 2
    LAN                 = 3
    Phone               = 4
    Tunnel              = 5
    PPPOE               = 6
    Bridge              = 7
    SharedAccessHostLAN = 8
    SharedAccessHostRAS = 9
}

Class IcsInterface
{
    [UInt32]               $Index
    Hidden [Object]   $Connection
    Hidden [Object]      $Adapter
    Hidden [Object]        $Share
    [DedicationState] $Dedication = [DedicationState]::Unspecified
    [String]                $Name
    [String]         $DisplayName
    [Bool]               $Sharing
    [SharingPrivacy]     $Privacy
    [Guid]                  $Guid
    [ConnectionStatus]    $Status
    [ConnectionMedia]      $Media
    [Object]              $Config
    IcsInterface([UInt32]$Index,[Object]$Connection,[Object]$Adapter,[Object]$Share,[Object]$Prop)
    {
        $This.Index       = $Index
        $This.Connection  = $Connection
        $This.Adapter     = $Adapter
        $This.Share       = $Share
        $This.CheckSharing()
        $This.Name        = $Prop.Name
        $This.DisplayName = $Prop.DeviceName
        $This.Guid        = $Prop.Guid
        $This.Status      = [ConnectionStatus]$Prop.Status
        $This.Media       = [ConnectionMedia]$Prop.MediaType
    }
    CheckSharing()
    {
        $This.Sharing = [Bool]$This.Share.SharingEnabled
        $This.Privacy = [SharingPrivacy]$This.Share.SharingConnectionType

        $This.Dedication = [DedicationState]::Unspecified

        If ($This.Sharing)
        {
            $This.Dedication = [DedicationState]@(1,2)[$This.Privacy -eq [SharingPrivacy]::Private]
        }
    }
    EnableSharing([UInt32]$State)
    {
        $This.Share.EnableSharing($State) # 0 = Public NAT
    }
    DisableSharing()
    {
        $This.Share.DisableSharing()
    }
    [String] ToString()
    {
        return $This.Name
    }
}

Class IcsController
{
    [Object] $Connection
    [String] $Source
    [String] $Target
    [Object] $Manager
    IcsController([String]$Source,[string]$Target)
    {
        $This.Manager = $This.HNetCfgHNetShare()
        $This.SetSource($Source)
        $This.SetTarget($Target)
        $This.Refresh()
    }
    SetSource([String]$Source)
    {
        $This.Source = $source
    }
    SetTarget([String]$Target)
    {
        $This.Target = $Target
    }
    Refresh()
    {
        $This.GetConnections()

        ForEach ($Connection in $This.Connection)
        {
            If ($Connection.Name -eq $This.Source)
            {
                $Connection.Dedication = [DedicationState]::Source
            }

            elseif ($Connection.Name -eq $This.Target)
            {
                $Connection.Dedication = [DedicationState]::Target
            }
        }
    }
    [Object] HNetCfgHNetShare()
    {
        return @( try { New-Object -ComObject HNetCfg.HNetShare } catch { $Null } )
    }
    [Object] GetProperties([Object]$Connection)
    {
        return @( try { $This.Manager.NetConnectionProps($Connection) } catch { $null } )
    }
    [Object] GetAdapter([string]$Name)
    {
        return @( try { Get-NetAdapter -Name $Name -EA 0 } catch { $Null } )
    }
    [Object] GetSharing([Object]$Connection)
    {
        return @( try { $This.Manager.INetSharingConfigurationForINetConnection($Connection) } catch { $null } )
    }
    [Object] IcsInterface([UInt32]$Index,[Object]$Connection)
    {
        $Prop = $This.GetProperties($Connection)

        return [IcsInterface]::New($Index, $Connection, $This.GetAdapter($Prop.Name), $This.GetSharing($Connection), $Prop)
    }
    GetConnections()
    {
        $This.Connection = @( )

        ForEach ($Connection in $This.Manager.EnumEveryConnection())
        {
            $This.Connection += $This.IcsInterface($This.Connection.Count, $Connection)
        }
    }
    EnableShare()
    {
        $xSource = $This.Connection | ? Dedication -eq Source
        $xTarget = $This.Connection | ? Dedication -eq Target

        If (!$xSource.Sharing -and !$xTarget.Sharing)
        {
            $xSource.EnableSharing(0)
            $xTarget.EnableSharing(1)
        }

        $This.Refresh()
    }
    DisableShare()
    {
        $xSource = $This.Connection | ? Dedication -eq Source
        $xTarget = $This.Connection | ? Dedication -eq Target

        If ($xSource.Sharing -and $xTarget.Sharing)
        {
            $xSource.DisableSharing()
            $xTarget.DisableSharing()
        }

        $This.Refresh()
    }
    StopService()
    {
        Get-Service SharedAccess | ? Status -eq Running | Stop-Service -EA 0 -Force -Confirm:$False | Out-Null
    }
    StartService()
    {
        Get-Service SharedAccess | ? Status -eq Stopped | Start-Service -EA 0 -Force -Confirm:$False | Out-Null
    }
}

$Ics = [IcsController]::New($SourceAdapterName, $TargetAdapterName)

$Ics.EnableShare() # enables if connection sharing is not enabled 
$Ics.DisableShare() # disables if connection sharing is enabled
