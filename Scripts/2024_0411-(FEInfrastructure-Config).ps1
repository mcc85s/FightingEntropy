
# General
Class DataGridProperty
{
    [String]  $Name
    [Object] $Value
    DataGridProperty([String]$Name,[Object]$Value)
    {
        $This.Name  = $Name
        $This.Value = $Value
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DataGrid.Property>"
    }
}

Class ByteSize
{
    [String]   $Name
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    ByteSize([String]$Name,[UInt64]$Bytes)
    {
        $This.Name   = $Name
        $This.Bytes  = $Bytes
        $This.GetUnit()
        $This.GetSize()
    }
    GetUnit()
    {
        $This.Unit   = Switch ($This.Bytes)
        {
            {$_ -lt 1KB}                 {     "Byte" }
            {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
            {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
            {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
            {$_ -ge 1TB}                 { "Terabyte" }
        }
    }
    GetSize()
    {
        $This.Size   = Switch -Regex ($This.Unit)
        {
            ^Byte     {     "{0} B" -f  $This.Bytes      }
            ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
            ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
            ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
            ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
        }
    }
    [String] ToString()
    {
        Return $This.Size
    }
}

# System
Class SystemPanel
{
    [Object]        $Snapshot
    [Object] $BiosInformation
    [Object]  $ComputerSystem
    [Object] $OperatingSystem
    SystemPanel([Object]$System)
    {
        $This.Snapshot = $System.Snapshot
        $This.BiosInformation = $System.BiosInformation
        $This.ComputerSystem  = $System.ComputerSystem
        $This.OperatingSystem = $System.OperatingSystem
    }
    [String] ToString()
    {
        Return "{0}, {1} | {2}, {3} {4}-{5}" -f $This.Snapshot.ComputerName, 
        $This.ComputerSystem.Manufacturer, 
        $This.ComputerSystem.Model, 
        $This.OperatingSystem.Caption, 
        $This.OperatingSystem.Version, 
        $This.OperatingSystem.Build
    }
}

# Feature
Class WindowsFeatureItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $DisplayName
    [UInt32]   $Installed
    WindowsFeatureItem([UInt32]$Index,[Object]$Feature)
    {
        $This.Index       = $Index
        $This.Name        = $Feature.Name
        $This.DisplayName = $Feature.DisplayName
        $This.Installed   = $Feature.InstallState -eq "Installed"
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WindowsFeature.Item>"
    }
}

Class WindowsFeatureMaster
{
    [Object] $Output
    WindowsFeatureMaster()
    {
        $Features    = $This.GetWindowsFeature()
        $Registry    = @( "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" })

        $This.Output = @( )

        # Default features
        ForEach ($Name in $This.DefaultFeatures())
        {
            $Value        = [UInt32]($Features | ? Name -eq $Name | % Installed)

            $This.Output += $This.DataGridProperty($Name,$Value)
        }
        
        # Non-default features
        ForEach ($Name in $This.NonDefaultFeatures())
        {
            $Slot         = Switch ($Name)
            {
                MDT    { $Registry[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                WinADK { $Registry[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                WinPE  { $Registry[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
            }

            $Value        = [UInt32]!!(Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2])

            $This.Output += $This.DataGridProperty($Name,$Value)
        }
    }
    [Object] DataGridProperty([String]$Name,[Object]$Value)
    {
        Return [DataGridProperty]::New($Name,$Value)
    }
    [String[]] DefaultFeatures()
    {
        Return "Dhcp","Dns","AD-Domain-Services","Hyper-V","Wds","Web-WebServer"
    }
    [String[]] NonDefaultFeatures()
    {
        Return "Mdt","WinAdk","WinPe"
    }
    [Object[]] GetWindowsFeature()
    {
        Return Get-WindowsFeature
    }
    [Object] WindowsFeatureItem([UInt32]$Index,[Object]$Feature)
    {
        Return [WindowsFeatureItem]::New($Index,$Feature)
    }
    [Object] Get([String]$Name)
    {
        Return $This.Output | ? Name -eq $Name
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WindowsFeature.Item>"
    }
}

# Ip Configuration
Class IpConfigurationItem
{
    [String]         $Alias
    [UInt32]         $Index
    [String]   $Description
    [String]       $Profile
    [String[]] $IPV4Address
    [String]   $IPV4Gateway
    [String[]] $IPV6Address
    [String]   $IPV6Gateway
    [String[]]   $DnsServer
    IpConfigurationItem([Object]$Config)
    {
        $This.Alias       = $Config.InterfaceAlias
        $This.Index       = $Config.InterfaceIndex
        $This.Description = $Config.InterfaceDescription
        $This.Profile     = $Config.NetProfile.Name
        $This.IPV4Address = $Config.IPV4Address | % IPAddress
        $This.IPV4Gateway = $Config.IPV4DefaultGateway | % NextHop
        $This.IPV6Address = $Config.IPV6Address | % IPAddress
        $This.IPV6Address = $Config.IPV6DefaultGateway | % NextHop
        $This.DNSServer   = $Config.DNSServer | % ServerAddresses
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IpConfiguration.Item>"
    }
}

Class IpConfigurationMaster
{
    [Object] $Output
    IpConfigurationMaster()
    {
        $This.Refresh()
    }
    [Object[]] GetNetIpConfiguration()
    {
        Return Get-NetIPConfiguration
    }
    [Object] IpConfigurationItem([Object]$Config)
    {
        Return [IpConfigurationItem]::New($Config)
    }
    Refresh()
    {
        $This.Output = @( )

        $xConfigurations = $This.GetNetIPConfiguration()

        ForEach ($Configuration in $xConfigurations)
        {
            $This.Output += $This.IpConfigurationItem($Configuration)
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IpConfiguration.Master>"
    }
}

# Dhcp
Class DhcpServerV4ExclusionRange
{
    [String] $ScopeId
    [String] $StartRange
    [String] $EndRange
    DhcpServerV4ExclusionRange([Object]$Exclusion)
    {
        $This.ScopeId    = $Exclusion.ScopeId
        $This.StartRange = $Exclusion.StartRange
        $This.EndRange   = $Exclusion.EndRange
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DhcpServer.V4ExclusionRange>"
    }
}

Class DhcpServerV4Reservation
{
    [String]   $IpAddress
    [String]    $ClientID
    [String]        $Name
    [String] $Description
    DhcpServerV4Reservation([Object]$Reservation)
    {
        $This.IpAddress   = $Reservation.IpAddress
        $This.ClientID    = $Reservation.ClientID
        $This.Name        = $Reservation.Name
        $This.Description = $Reservation.Description
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DhcpServer.V4Reservation>"
    }
}

Class DhcpServerV4OptionValue
{
    [UInt32] $OptionID
    [String]     $Name
    [String]     $Type
    [String]    $Value
    DhcpServerV4OptionValue([Object]$Option)
    {
        $This.OptionID = $Option.OptionID
        $This.Name     = $Option.Name
        $This.Type     = $Option.Type
        $This.Value    = $Option.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DhcpServer.V4OptionValue>"
    }
}

Class DhcpServerv4Scope
{
    [String]     $ScopeID
    [String]  $SubnetMask
    [String]        $Name
    [UInt32]       $State
    [String]  $StartRange
    [String]    $EndRange
    [Object]   $Exclusion
    [Object] $Reservation
    [Object]      $Option
    DhcpServerv4Scope([Object]$Scope)
    {
        $This.ScopeID      = $Scope.ScopeID
        $This.SubnetMask   = $Scope.SubnetMask
        $This.Name         = $Scope.Name
        $This.State        = $Scope.State -eq "Active"
        $This.StartRange   = $Scope.StartRange
        $This.EndRange     = $Scope.EndRange

        $This.Refresh()
    }
    Refresh()
    {
        $This.Exclusion    = @( )
        $This.Reservation  = @( )
        $This.Option       = @( )

        $xExclusions       = $This.GetExclusion()
        $xReservations     = $This.GetReservation()
        $xOptions          = $This.GetOptionValue()

        ForEach ($Exclusion in $xExclusions)
        {
            $This.Exclusion += $This.DhcpServerV4ExclusionRange($Exclusion)
        }
        ForEach ($Reservation in $xReservations)
        {
            $This.Reservation += $This.DhcpServerV4Reservation($Reservation)
        }

        ForEach ($Option in $xOptions)
        {
            $This.Option += $This.DhcpServerV4OptionValue($Option)
        }
    }
    [Object[]] GetExclusion()
    {
        Return Get-DhcpServerV4ExclusionRange -ScopeId $This.ScopeId -EA 0
    }
    [Object[]] GetReservation()
    {
        Return Get-DhcpServerV4Reservation -ScopeId $This.ScopeId -EA 0
    }
    [Object[]] GetOptionValue()
    {
        Return Get-DhcpServerV4OptionValue -ScopeId $This.ScopeId -EA 0
    }
    [Object] DhcpServerV4ExclusionRange([Object]$Exclusion)
    {
        Return [DhcpServerV4ExclusionRange]::New($Exclusion)
    }
    [Object] DhcpServerv4Reservation([Object]$Reservation)
    {
        Return [DhcpServerV4Reservation]::New($Reservation)
    }
    [Object] DhcpServerV4OptionValue([Object]$Option)
    {
        Return [DhcpServerV4OptionValue]::New($Option)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DhcpServer.V4Scope>"
    }
}

Class DhcpServer
{
    [String] $Server
    [Object] $Scope
    DhcpServer()
    {
        $This.Server = $This.GetHostname()
        $This.Refresh()
    }
    [String] GetHostname()
    {
        $xName = $Env:COMPUTERNAME

        If ($Env:USERDNSDOMAIN)
        {
            $xName = "{0}.{1}" -f $xName, $Env:UserDnsDomain
        }

        Return $xName.ToLower()
    }
    Refresh()
    {
        $This.Scope = @( )

        $xScope = $This.GetScope()

        ForEach ($Scope in $xScope)
        {
            $This.Scope += $This.DhcpServerV4Scope($Scope)
        }
    }
    [Object[]] GetScope()
    {
        Return Get-DhcpServerV4Scope
    }
    [Object] DhcpServerV4Scope([Object]$Scope)
    {
        Return [DhcpServerV4Scope]::New($Scope)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DhcpServer>"
    }
}

# Dns
Class DnsServerCache
{
    [TimeSpan]                         $MaxTTL
    [TimeSpan]                 $MaxNegativeTTL
    [UInt32]                        $MaxKBSize
    [UInt32]        $EnablePollutionProtection
    [UInt32]                   $LockingPercent
    [UInt32] $StoreEmptyAuthenticationResponse
    [UInt32]                   $IgnorePolicies
    DnsServerCache([Object]$Cache)
    {
        $This.MaxTTL                           = $Cache.MaxTTL
        $This.MaxNegativeTTL                   = $Cache.MaxNegativeTTL
        $This.MaxKBSize                        = $Cache.MaxKBSize
        $This.EnablePollutionProtection        = $Cache.EnablePollutionProtection
        $This.LockingPercent                   = $Cache.LockingPercent
        $This.StoreEmptyAuthenticationResponse = $Cache.StoreEmptyAuthenticationResponse
        $This.IgnorePolicies                   = $Cache.IgnorePolicies
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Cache>"
    }
}

Class DnsServerClientSubnet
{
    [UInt32]      $Index
    [String]       $Name
    [Object] $IPV4Subnet
    [Object] $IPV6Subnet
    DnsServerClientSubnet([UInt32]$Index,[Object]$Subnet)
    {
        $This.Index      = $Index
        $This.Name       = $Subnet.HostName
        $This.IpV4Subnet = $Subnet.IpV4Subnet
        $This.IpV6Subnet = $Subnet.IpV6Subnet
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ClientSubnet>"
    }
}

Class DnsServerDiagnostics
{
    [UInt32]          $SaveLogsToPersistentStorage
    [UInt32]                              $Queries
    [UInt32]                              $Answers
    [UInt32]                        $Notifications
    [UInt32]                               $Update
    [UInt32]                 $QuestionTransactions
    [UInt32]                    $UnmatchedResponse
    [UInt32]                          $SendPackets
    [UInt32]                       $ReceivePackets
    [UInt32]                           $TcpPackets
    [UInt32]                           $UdpPackets
    [UInt32]                          $FullPackets
    [Object]                  $FilterIPAddressList
    [UInt32]                        $EventLogLevel
    [UInt32]                    $UseSystemEventLog
    [UInt32]                  $EnableLoggingToFile
    [UInt32]                $EnableLogFileRollover
    [String]                          $LogFilePath
    [UInt32]                        $MaxMBFileSize
    [UInt32]                         $WriteThrough
    [UInt32]     $EnableLoggingForLocalLookupEvent
    [UInt32]       $EnableLoggingForPluginDllEvent
    [UInt32] $EnableLoggingForRecursiveLookupEvent
    [UInt32]    $EnableLoggingForRemoteServerEvent
    [UInt32] $EnableLoggingForServerStartStopEvent
    [UInt32]       $EnableLoggingForTombstoneEvent
    [UInt32]   $EnableLoggingForZoneDataWriteEvent
    [UInt32]     $EnableLoggingForZoneLoadingEvent
    DnsServerDiagnostics([Object]$Diagnostics)
    {
        $This.SaveLogsToPersistentStorage          = $Diagnostics.SaveLogsToPersistentStorage
        $This.Queries                              = $Diagnostics.Queries
        $This.Answers                              = $Diagnostics.Answers
        $This.Notifications                        = $Diagnostics.Notifications
        $This.Update                               = $Diagnostics.Update
        $This.QuestionTransactions                 = $Diagnostics.QuestionTransactions
        $This.UnmatchedResponse                    = $Diagnostics.UnmatchedResponse
        $This.SendPackets                          = $Diagnostics.SendPackets
        $This.ReceivePackets                       = $Diagnostics.ReceivePackets
        $This.TcpPackets                           = $Diagnostics.TcpPackets
        $This.UdpPackets                           = $Diagnostics.UdpPackets
        $This.FullPackets                          = $Diagnostics.FullPackets
        $This.FilterIPAddressList                  = $Diagnostics.FilterIPAddressList
        $This.EventLogLevel                        = $Diagnostics.EventLogLevel
        $This.UseSystemEventLog                    = $Diagnostics.UseSystemEventLog
        $This.EnableLoggingToFile                  = $Diagnostics.EnableLoggingToFile
        $This.EnableLogFileRollover                = $Diagnostics.EnableLogFileRollover
        $This.LogFilePath                          = $Diagnostics.LogFilePath
        $This.MaxMBFileSize                        = $Diagnostics.MaxMBFileSize
        $This.WriteThrough                         = $Diagnostics.WriteThrough
        $This.EnableLoggingForLocalLookupEvent     = $Diagnostics.EnableLoggingForLocalLookupEvent
        $This.EnableLoggingForPluginDllEvent       = $Diagnostics.EnableLoggingForPluginDllEvent
        $This.EnableLoggingForRecursiveLookupEvent = $Diagnostics.EnableLoggingForRecursiveLookupEvent
        $This.EnableLoggingForRemoteServerEvent    = $Diagnostics.EnableLoggingForRemoteServerEvent
        $This.EnableLoggingForServerStartStopEvent = $Diagnostics.EnableLoggingForServerStartStopEvent
        $This.EnableLoggingForTombstoneEvent       = $Diagnostics.EnableLoggingForTombstoneEvent
        $This.EnableLoggingForZoneDataWriteEvent   = $Diagnostics.EnableLoggingForZoneDataWriteEvent
        $This.EnableLoggingForZoneLoadingEvent     = $Diagnostics.EnableLoggingForZoneLoadingEvent
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Diagnostics>"
    }
}

Class DnsServerDsSetting
{
    [UInt32]                        $PollingInterval
    [TimeSpan]                    $TombstoneInterval
    [TimeSpan] $DirectoryPartitionAutoEnlistInterval
    [UInt32]                     $LazyUpdateInterval
    [UInt32]           $MinimumBackgroundLoadThreads
    [UInt32]                 $RemoteReplicationDelay
    DnsServerDsSetting([Object]$DsSetting)
    {
        $This.PollingInterval                      = $DsSetting.PollingInterval
        $This.TombstoneInterval                    = $DsSetting.TombstoneInterval
        $This.DirectoryPartitionAutoEnlistInterval = $DsSetting.DirectoryPartitionAutoEnlistInterval
        $This.LazyUpdateInterval                   = $DsSetting.LazyUpdateInterval
        $This.MinimumBackgroundLoadThreads         = $DsSetting.MinimumBackgroundLoadThreads
        $This.RemoteReplicationDelay               = $DsSetting.RemoteReplicationDelay
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.DsSetting>"
    }
}

Class DnsServerEDns
{
    [TimeSpan]  $CacheTimeout
    [UInt32]    $EnableProbes
    [UInt32] $EnableReception
    DnsServerEDns([Object]$EDns)
    {
        $This.CacheTimeout    = $EDns.CacheTimeout
        $This.EnableProbes    = $EDns.EnableProbes
        $This.EnableReception = $EDns.EnableReception
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.EDns>"
    }
}

Class DnsServerForwarder
{
    [UInt32]              $Index
    [UInt32]        $UseRootHint
    [UInt32]            $Timeout
    [UInt32]   $EnableReordering
    [String]          $IpAddress
    [String] $ReorderedIpAddress
    DnsServerForwarder([UInt32]$Index,[Object]$Forwarder)
    {
        $This.Index              = $Index
        $This.UseRootHint        = $Forwarder.UseRootHint
        $This.Timeout            = $Forwarder.Timeout
        $This.EnableReordering   = $Forwarder.EnableReordering
        $This.IpAddress          = $Forwarder.IpAddress
        $This.ReorderedIpAddress = $Forwarder.ReorderedIpAddress
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Forwarder>"
    }
}

Class DnsServerGlobalNameZone
{
    [UInt32] $Enable
    [UInt32] $GlobalOverLocal
    [UInt32] $PreferAAAA
    [UInt32] $AlwaysQueryServer
    [UInt32] $EnableEDnsProbes
    [UInt32] $BlockUpdates
    [UInt32] $SendTimeout
    [TimeSpan] $ServerQueryInterval
    DnsServerGlobalNameZone([Object]$Global)
    {
        $This.Enable              = $Global.Enable
        $This.GlobalOverLocal     = $Global.GlobalOverLocal
        $This.PreferAAAA          = $Global.PreferAAAA
        $This.AlwaysQueryServer   = $Global.AlwaysQueryServer
        $This.EnableEDnsProbes    = $Global.EnableEDnsProbes
        $This.BlockUpdates        = $Global.BlockUpdates
        $This.SendTimeout         = $Global.SendTimeout
        $This.ServerQueryInterval = $Global.ServerQueryInterval
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.GlobalNameZone>"
    }
}

Class DnsServerGlobalQueryBlockList
{
    [UInt32] $Enable
    [String[]] $List
    DnsServerGlobalQueryBlockList([Object]$Query)
    {
        $This.Enable = $Query.Enable
        $This.List   = $Query.List
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.GlobalQueryBlockList>"
    }
}

Class DnsServerQueryResolutionPolicy
{
    [UInt32]           $Index
    [String]          $Action
    [String]       $AppliesOn
    [String]       $Condition
    [Object]         $Content
    [Object]        $Criteria
    [UInt32]       $IsEnabled
    [String]           $Level
    [String]            $Name
    [UInt32] $ProcessingOrder
    [String]        $ZoneName
    DnsServerQueryResolutionPolicy([UInt32]$Index,[Object]$Policy)
    {
        $This.Index                 = $Index
        $This.Action                = $Policy.Action
        $This.AppliesOn             = $Policy.AppliesOn
        $This.Condition             = $Policy.Condition
        $This.Content               = $Policy.Content
        $This.Criteria              = $Policy.Criteria
        $This.IsEnabled             = $Policy.IsEnabled
        $This.Level                 = $Policy.Level
        $This.Name                  = $Policy.Name
        $This.ProcessingOrder       = $Policy.ProcessingOrder
        $This.ZoneName              = $Policy.ZoneName
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.QueryResolution.Policy>"
    }
}

Class DnsServerZoneTransferPolicy
{
    [UInt32] $Index
    [String] $Name
    [UInt32] $ProcessingOrder
    [UInt32] $IsEnabled
    [String] $Action
    DnsServerZoneTransferPolicy([UInt32]$Index,[Object]$Policy)
    {
        $This.Index           = $Index
        $This.Name            = $Policy.Name
        $This.ProcessingOrder = $Policy.ProcessingOrder
        $This.IsEnabled       = $Policy.IsEnabled
        $This.Action          = $Policy.Action
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ZoneTransfer.Policy>"
    }
}

Class DnsServerRecursion
{
    [UInt32] $Enable
    [UInt32] $AdditionalTimeout
    [UInt32] $RetryInterval
    [UInt32] $Timeout
    [UInt32] $SecureResponse
    DnsServerRecursion([Object]$Recursion)
    {
        $This.Enable            = $Recursion.Enable
        $This.AdditionalTimeout = $Recursion.AdditionalTimeout
        $This.RetryInterval     = $Recursion.RetryInterval
        $This.Timeout           = $Recursion.Timeout
        $This.SecureResponse    = $Recursion.SecureResponse
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Recursion>"
    }
}

Class DnsServerRecursionScope
{
    [UInt32] $Index
    [String] $Name
    [String] $Forwarder
    [UInt32] $EnableRecursion
    DnsServerRecursionScope([UInt32]$Index,[Object]$Scope)
    {
        $This.Index           = $Index
        $This.Name            = $Scope.Name
        $This.Forwarder       = $Scope.Forwarder
        $This.EnableRecursion = $Scope.EnableRecursion
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.RecursionScope>"
    }
}

Class DnsServerResponseRateLimiting
{
    [UInt32]           $ResponsesPerSec
    [UInt32]              $ErrorsPerSec
    [UInt32]               $WindowInSec
    [UInt32]          $IPv4PrefixLength
    [UInt32]          $IPv6PrefixLength
    [UInt32]                  $LeakRate
    [UInt32]              $TruncateRate
    [UInt32] $MaximumResponsesPerWindow 
    [String]                      $Mode 
    DnsServerResponseRateLimiting([Object]$Response)
    {
        $This.ResponsesPerSec           = $Response.ResponsesPerSec
        $This.ErrorsPerSec              = $Response.ErrorsPerSec
        $This.WindowInSec               = $Response.WindowInSec
        $This.IPv4PrefixLength          = $Response.IpV4PrefixLength
        $This.IPv6PrefixLength          = $Response.IpV6PrefixLength
        $This.LeakRate                  = $Response.LeakRate
        $This.TruncateRate              = $Response.TruncateRate
        $This.MaximumResponsesPerWindow = $Response.MaximumResponsesPerWindow
        $This.Mode                      = $Response.Mode
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ResponseRateLimiting>"
    }
}

Class DnsServerRootHint
{
    [UInt32] $Index
    [String] $NameServer
    [String] $IpAddress
    DnsServerRootHint([UInt32]$Index,[Object]$RootHint)
    {
        $This.Index      = $Index
        $This.NameServer = $RootHint.NameServer
        $This.IpAddress  = $RootHint.IpAddresas
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.RootHint>"
    }
}

Class DnsServerScavenging
{
    [Timespan]  $NoRefreshInterval
    [TimeSpan]    $RefreshInterval
    [TimeSpan] $ScavengingInterval
    [UInt32]      $ScavengingState
    [String]     $LastScavengeTime
    DnsServerScavenging([Object]$Scavenge)
    {
        $This.NoRefreshInterval  = $Scavenge.NoRefreshInterval
        $This.RefreshInterval    = $Scavenge.RefreshInterval
        $This.ScavengingInterval = $Scavenge.ScavengingInterval
        $This.ScavengingState    = $Scavenge.ScavengingState
        $This.LastScavengeTime   = $Scavenge.LastScavengeTime
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Scavenging>"
    }
}

Class DnsServerSetting
{
    [String]                              $ComputerName
    [UInt32]                              $MajorVersion
    [UInt32]                              $MinorVersion
    [UInt32]                               $BuildNumber
    [UInt32]                              $IsReadOnlyDC
    [UInt32]                              $EnableDnsSec
    [UInt32]                                $EnableIPv6
    [UInt32]                       $EnableOnlineSigning
    [UInt32]                             $NameCheckFlag
    [UInt32]                        $AddressAnswerLimit
    [UInt32]                         $XfrConnectTimeout
    [UInt32]                                $BootMethod
    [UInt32]                               $AllowUpdate
    [UInt32]                             $UpdateOptions
    [UInt32]                               $DsAvailable
    [UInt32]                    $DisableAutoReverseZone
    [UInt32]                           $AutoCacheUpdate
    [UInt32]                                $RoundRobin
    [UInt32]                          $LocalNetPriority
    [UInt32]                         $StrictFileParsing
    [UInt32]                          $LooseWildcarding
    [UInt32]                           $BindSecondaries
    [UInt32]                          $WriteAuthorityNS
    [UInt32]                        $ForwardDelegations
    [UInt32]                       $AutoConfigFileZones
    [UInt32]                 $EnableDirectoryPartitions
    [UInt32]                               $RpcProtocol
    [UInt32]                        $EnableVersionQuery
    [UInt32]           $EnableDuplicateQuerySuppression
    [TimeSpan]                       $LameDelegationTTL
    [UInt32]                      $AutoCreateDelegation
    [UInt32]                            $AllowCnameAtNs
    [UInt32]                       $RemoteIPv4RankBoost
    [UInt32]                       $RemoteIPv6RankBoost
    [UInt32]                          $EnableRsoForRodc
    [UInt32]                 $MaximumRodcRsoQueueLength
    [UInt32]            $MaximumRodcRsoAttemptsPerCycle
    [UInt32]                     $OpenAclOnProxyUpdates
    [UInt32]                       $NoUpdateDelegations
    [UInt32]                    $EnableUpdateForwarding
    [UInt32]       $MaxResourceRecordsInNonSecureUpdate
    [UInt32]                               $EnableWinsR
    [UInt32]                      $LocalNetPriorityMask
    [UInt32]                         $DeleteOutsideGlue
    [UInt32]                   $AppendMsZoneTransferTag
    [UInt32]                 $AllowReadOnlyZoneTransfer
    [UInt32]                      $MaximumUdpPacketSize
    [UInt32]                      $TcpReceivePacketSize
    [UInt32]                $EnableSendErrorSuppression
    [UInt32]                                  $SelfTest
    [UInt32]                     $XfrThrottleMultiplier
    [UInt32]        $SilentlyIgnoreCnameUpdateConflicts
    [UInt32]            $EnableIQueryResponseGeneration
    [UInt32]                            $SocketPoolSize
    [UInt32]                           $AdminConfigured
    [Object]              $SocketPoolExcludedPortRanges
    [String]          $ForestDirectoryPartitionBaseName
    [String]          $DomainDirectoryPartitionBaseName
    [Object]                      $ServerLevelPluginDll
    [Object]                        $EnableRegistryBoot
    [UInt32]                            $PublishAutoNet
    [UInt32]                    $QuietRecvFaultInterval
    [UInt32]                      $QuietRecvLogInterval
    [UInt32]                           $ReloadException
    [UInt32]                          $SyncDsZoneSerial
    [String]                                  $SendPort
    [TimeSpan]              $MaximumSignatureScanPeriod
    [TimeSpan] $MaximumTrustAnchorActiveRefreshInterval
    [String[]]                      $ListeningIPAddress
    [String[]]                            $AllIPAddress
    [TimeSpan]                   $ZoneWritebackInterval
    [String]                       $RootTrustAnchorsURL
    [UInt32]                          $ScopeOptionValue
    [UInt32]                 $IgnoreServerLevelPolicies
    [UInt32]                         $IgnoreAllPolicies
    [UInt32]         $VirtualizationInstanceOptionValue
    DnsServerSetting([Object]$Setting)
    {
        $This.ComputerName                            = $Setting.ComputerName
        $This.MajorVersion                            = $Setting.MajorVersion
        $This.MinorVersion                            = $Setting.MinorVersion
        $This.BuildNumber                             = $Setting.BuildNumber
        $This.IsReadOnlyDC                            = $Setting.IsReadOnlyDC
        $This.EnableDnsSec                            = $Setting.EnableDnsSec
        $This.EnableIPv6                              = $Setting.EnableIPv6
        $This.EnableOnlineSigning                     = $Setting.EnableOnlineSigning
        $This.NameCheckFlag                           = $Setting.NameCheckFlag
        $This.AddressAnswerLimit                      = $Setting.AddressAnswerLimit
        $This.XfrConnectTimeout                       = $Setting.XfrConnectTimeout
        $This.BootMethod                              = $Setting.BootMethod
        $This.AllowUpdate                             = $Setting.AllowUpdate
        $This.UpdateOptions                           = $Setting.UpdateOptions
        $This.DsAvailable                             = $Setting.DsAvailable
        $This.DisableAutoReverseZone                  = $Setting.DisableAutoReverseZone
        $This.AutoCacheUpdate                         = $Setting.AutoCacheUpdate
        $This.RoundRobin                              = $Setting.RoundRobin
        $This.LocalNetPriority                        = $Setting.LocalNetPriority
        $This.StrictFileParsing                       = $Setting.StrictFileParsing
        $This.LooseWildcarding                        = $Setting.LooseWildcarding
        $This.BindSecondaries                         = $Setting.BindSecondaries
        $This.WriteAuthorityNS                        = $Setting.WriteAuthorityNS
        $This.ForwardDelegations                      = $Setting.ForwardDelegations
        $This.AutoConfigFileZones                     = $Setting.AutoConfigFileZones
        $This.EnableDirectoryPartitions               = $Setting.EnableDirectoryPartitions
        $This.RpcProtocol                             = $Setting.RpcProtocol
        $This.EnableVersionQuery                      = $Setting.EnableVersionQuery
        $This.EnableDuplicateQuerySuppression         = $Setting.EnableDuplicateQuerySupression
        $This.LameDelegationTTL                       = $Setting.LameDelegationTTL
        $This.AutoCreateDelegation                    = $Setting.AutoCreateDelegation
        $This.AllowCnameAtNs                          = $Setting.AllowCnameAtNs
        $This.RemoteIPv4RankBoost                     = $Setting.RemoteIPv4RankBoost
        $This.RemoteIPv6RankBoost                     = $Setting.RemoteIPv6RankBoost
        $This.EnableRsoForRodc                        = $Setting.EnableRsoForRodc
        $This.MaximumRodcRsoQueueLength               = $Setting.MaximumRodcRsoQueueLength
        $This.MaximumRodcRsoAttemptsPerCycle          = $Setting.MaximumRodcRsoAttemptsPerCycle
        $This.OpenAclOnProxyUpdates                   = $Setting.OpenAclOnProxyUpdates
        $This.NoUpdateDelegations                     = $Setting.NoUpdateDelegations
        $This.EnableUpdateForwarding                  = $Setting.EnableUpdateForwarding
        $This.MaxResourceRecordsInNonSecureUpdate     = $Setting.MaxResourceRecordsInNonSecureUpdate
        $This.EnableWinsR                             = $Setting.EnableWinsR
        $This.LocalNetPriorityMask                    = $Setting.LocalNetPriorityMask
        $This.DeleteOutsideGlue                       = $Setting.DeleteOutsideGlue
        $This.AppendMsZoneTransferTag                 = $Setting.AppendMsZoneTransferTag
        $This.AllowReadOnlyZoneTransfer               = $Setting.AllowReadOnlyZoneTransfer
        $This.MaximumUdpPacketSize                    = $Setting.MaximumUdpPacketSize
        $This.TcpReceivePacketSize                    = $Setting.TcpReceivePacketSize
        $This.EnableSendErrorSuppression              = $Setting.EnableSendErrorSuppression
        $This.SelfTest                                = $Setting.SelfTest
        $This.XfrThrottleMultiplier                   = $Setting.XfrThrottleMultiplier
        $This.SilentlyIgnoreCnameUpdateConflicts      = $Setting.SilentlyIgnoreCnameUpdateConflicts
        $This.EnableIQueryResponseGeneration          = $Setting.EnableIQueryResponseGeneration
        $This.SocketPoolSize                          = $Setting.SocketPoolSize
        $This.AdminConfigured                         = $Setting.AdminConfigured
        $This.SocketPoolExcludedPortRanges            = $Setting.SocketPoolExcludedPortRanges
        $This.ForestDirectoryPartitionBaseName        = $Setting.ForestDirectoryPartitionBaseName
        $This.DomainDirectoryPartitionBaseName        = $Setting.DomainDirectoryPartitionBaseName
        $This.ServerLevelPluginDll                    = $Setting.ServerLevelPluginDll
        $This.EnableRegistryBoot                      = $Setting.EnableRegistryBoot
        $This.PublishAutoNet                          = $Setting.PublishAutoNet
        $This.QuietRecvFaultInterval                  = $Setting.QuietRecvFaultInterval
        $This.QuietRecvLogInterval                    = $Setting.QuietRecvLogInterval
        $This.ReloadException                         = $Setting.ReloadException
        $This.SyncDsZoneSerial                        = $Setting.SyncDsZoneSerial
        $This.SendPort                                = $Setting.SendPort
        $This.MaximumSignatureScanPeriod              = $Setting.MaximumSignatureScanPeriod
        $This.MaximumTrustAnchorActiveRefreshInterval = $Setting.MaximumTrustAnchorActiveRefreshInterval
        $This.ListeningIPAddress                      = $Setting.ListeningIPAddress
        $This.AllIPAddress                            = $Setting.AllIPAddress
        $This.ZoneWritebackInterval                   = $Setting.ZoneWritebackInterval
        $This.RootTrustAnchorsURL                     = $Setting.RootTrustAnchorsURL
        $This.ScopeOptionValue                        = $Setting.ScopeOptionValue
        $This.IgnoreServerLevelPolicies               = $Setting.IgnoreServerLevelPolicies
        $This.IgnoreAllPolicies                       = $Setting.IgnoreAllPolicies
        $This.VirtualizationInstanceOptionValue       = $Setting.VirtualizationInstanceOptionValue
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Setting>"
    }
}

Class DnsServerResourceRecord
{
    [Object] $Record
    [String]   $Type
    [String]   $Name
    DnsServerResourceRecord([Object]$Type,[Object]$Record)
    {
        $This.Record = $Record
        $This.Type   = $Type

        $Property    = Switch ($Type)
        {
            NS    { "NameServer"      } SOA   { "PrimaryServer"   }
            MX    { "MailExchange"    } CNAME { "HostNameAlias"   }
            SRV   { "DomainName"      } A     { "IPV4Address"     }
            AAAA  { "IPV6Address"     } PTR   { "PTRDomainName"   }
            TXT   { "DescriptiveText" } DHCID { "DHCID"           }
        }

        $This.Name   = $Record.$Property
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ResourceRecord>"
    }
}

Class DnsServerHostRecord
{
    [UInt32]      $Index
    [String] $RecordType
    [String]   $HostName
    [UInt32]       $Type
    [Object] $RecordData
    DnsServerHostRecord([UInt32]$Index,[Object]$Record)
    {
        $This.Index      = $Index
        $This.RecordType = $Record.RecordType
        $This.HostName   = $Record.HostName
        $This.Type       = $Record.Type
        $This.RecordData = $This.DnsServerResourceRecord($Record.RecordType,$Record.RecordData)
    }
    [Object] DnsServerResourceRecord([Object]$Type,[Object]$Record)
    {
        Return [DnsServerResourceRecord]::New($Type,$Record)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.HostRecord>"
    }
}

Class DnsServerZone
{
    [UInt32]               $Index
    [String]            $ZoneType
    [String]            $ZoneName
    [UInt32]       $IsAutoCreated
    [UInt32]      $IsDsIntegrated
    [UInt32] $IsReverseLookupZone
    [UInt32]            $IsSigned
    [Object]                $Host
    DnsServerZone([UInt32]$Index,[Object]$Zone)
    {
        $This.Index               = $Index
        $This.ZoneType            = $Zone.ZoneType
        $This.ZoneName            = $Zone.ZoneName
        $This.IsAutoCreated       = $Zone.IsAutoCreated
        $This.IsDsIntegrated      = $Zone.IsDsIntegrated
        $This.IsReverseLookupZone = $Zone.IsReverseLookupZone
        $This.IsSigned            = $Zone.IsSigned
        $This.Refresh()
    }
    [Object[]] GetDnsServerResourceRecord()
    {
        Return Get-DnsServerResourceRecord -ZoneName $This.Zonename
    }
    [Object] DnsServerHostRecord([UInt32]$Index,[Object]$Record)
    {
        Return [DnsServerHostRecord]::New($Index,$Record)
    }
    Refresh()
    {
        $This.Host = @( )

        $xHosts = $This.GetDnsServerResourceRecord()
        
        ForEach ($xHost in $xHosts)
        {
            $This.Host += $This.DnsServerHostRecord($This.Host.Count,$xHost)
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.Zone>"
    }
}

Class DnsServerZoneAging
{
    [UInt32]                $Index
    [String]             $ZoneName
    [UInt32]         $AgingEnabled
    [Object] $AvailForScavengeTime
    [TimeSpan]    $RefreshInterval
    [TimeSpan]  $NoRefreshInterval
    [Object]      $ScavengeServers
    DnsServerZoneAging([UInt32]$Index,[Object]$Aging)
    {
        $This.Index                = $Index
        $This.ZoneName             = $Aging.ZoneName
        $This.AgingEnabled         = $Aging.AgingEnabled
        $This.AvailForScavengeTime = $Aging.AvailForScavengeTime
        $This.RefreshInterval      = $Aging.RefreshInterval
        $This.NoRefreshInterval    = $Aging.NoRefreshInterval
        $This.ScavengeServers      = $Aging.ScavengeServers
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ZoneAging>"
    }
}

Class DnsServerZoneScope
{
    [UInt32]     $Index
    [String] $ZoneScope
    [String]  $FileName
    DnsServerZoneScope([UInt32]$Index,[Object]$Scope)
    {
        $This.Index     = $Index
        $This.ZoneScope = $Scope.ZoneScope
        $This.FileName  = $Scope.FileName
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer.ZoneScope>"
    }
}

Class DnsServer
{
    [Object] $Cache
    [Object] $ClientSubnet
    [Object] $Diagnostics
    [Object] $DsSetting
    [Object] $EDns
    [Object] $Forwarder
    [Object] $GlobalNameZone
    [Object] $GlobalQueryBlockList
    [Object] $Policies
    [Object] $Recursion
    [Object] $RecursionScope
    [Object] $ResponseRateLimiting
    [Object] $ResponseRateLimitingExceptionlists
    [Object] $RootHint
    [Object] $Scavenging
    [Object] $Setting
    [Object] $Zone
    [Object] $ZoneAging
    [Object] $ZoneScope
    [Object] $VirtualizedServer
    DnsServer()
    {
        $Server                                  = Get-DnsServer

        $This.Cache                              = $This.DnsServerCache($Server.ServerCache)

        # Client Subnets
        $This.GetClientSubnet($Server.ServerClientSubnets)

        $This.Diagnostics                        = $This.DnsServerDiagnostics($Server.ServerDiagnostics)
        $This.DsSetting                          = $This.DnsServerDsSetting($Server.ServerDsSetting)
        $This.EDns                               = $This.DnsServerEDns($Server.ServerEDns)

        # Forwarders
        $This.GetForwarder($Server.ServerForwarder)

        $This.GlobalNameZone                     = $This.DnsServerGlobalNameZone($Server.ServerGlobalNameZone)
        $This.GlobalQueryBlockList               = $This.DnsServerGlobalQueryBlockList($Server.ServerGlobalQueryBlockList)

        # Policies...
        $This.Policies                           = $Server.ServerPolicies

        $This.Recursion                          = $This.DnsServerRecursion($Server.ServerRecursion)

        # Recursion Scopes
        $This.GetRecursionScope($Server.ServerRecursionScopes)

        $This.ResponseRateLimiting               = $This.DnsServerResponseRateLimiting($Server.ServerResponseRateLimiting)

        # Response Rate Limiting Exception Lists...
        $This.ResponseRateLimitingExceptionLists = $Server.ServerResponseRateLimitingExceptionLists

        $This.GetRootHint($Server.ServerRootHint)

        $This.Scavenging                         = $This.DnsServerScavenging($Server.ServerScavenging)
        $This.Setting                            = $This.DnsServerSetting($Server.ServerSetting)

        # Zones
        $This.GetZone($Server.ServerZone)
        $This.GetZoneAging($Server.ServerZoneAging)
        $This.GetZoneScope($Server.ServerZoneScope)

        $This.VirtualizedServer                  = $Server.VirtualizedServer
    }
    GetClientSubnet([Object]$Instance)
    {
        $This.ClientSubnet                       = @( )
        $xClientSubnets                          = @($Instance)

        ForEach ($ClientSubnet in $xClientSubnets)
        {
            $This.ClientSubnet                  += $This.DnsServerClientSubnet($This.ClientSubnet.Count,$ClientSubnet)
        }
    }
    GetForwarder([Object]$Instance)
    {
        $This.Forwarder                          = @( )
        $xForwarders                             = @($Instance)

        ForEach ($Forwarder in $xForwarders)
        {
            $This.Forwarder                     += $This.DnsServerForwarder($This.Forwarder.Count,$Forwarder)
        }
    }
    GetRecursionScope([Object]$Instance)
    {
        $This.RecursionScope                     = @( )
        $xScopes                                 = @($Instance)

        ForEach ($Scope in $xScopes)
        {
            $This.RecursionScope                += $This.DnsServerRecursionScope($This.RecursionScope.Count,$Scope)
        }
    }
    GetRootHint([Object]$Instance)
    {
        $This.RootHint                           = @( )
        $xRootHints                              = @($Instance)

        ForEach ($RootHint in $xRootHints)
        {
            $This.RootHint                      += $This.DnsServerRootHint($This.RootHint.Count,$RootHint)   
        }
    }
    GetZone([Object]$Instance)
    {
        $This.Zone                               = @( )
        $xZones                                  = @($Instance)

        ForEach ($Zone in $xZones)
        {
            $This.Zone                          += $This.DnsServerZone($This.Zone.Count,$Zone)
        }
    }
    GetZoneAging([Object]$Instance)
    {
        $This.ZoneAging                          = @( )
        $xZoneAging                              = @($Instance)

        ForEach ($ZoneAging in $xZoneAging)
        {
            $This.ZoneAging                     += $This.DnsServerZoneAging($This.ZoneAging.Count,$ZoneAging)
        }
    }
    GetZoneScope([Object]$Instance)
    {
        $This.ZoneScope                          = @( )
        $xZoneScopes                             = @($Instance)

        ForEach ($ZoneScope in $xZoneScopes)
        {
            $This.ZoneScope                     += $This.DnsServerZoneScope($This.ZoneScope.Count,$ZoneScope)
        }
    }
    [Object] GetDnsServer()
    {
        Return Get-DnsServer
    }
    [Object] DnsServerCache([Object]$Cache)
    {
        Return [DnsServerCache]::New($Cache)
    }
    [Object] DnsServerClientSubnet([UInt32]$Index,[Object]$Subnet)
    {
        Return [DnsServerClientSubnet]::New($Index,$Subnet)
    }
    [Object] DnsServerDiagnostics([Object]$Diagnostics)
    {
        Return [DnsServerDiagnostics]::New($Diagnostics)
    }
    [Object] DnsServerDsSetting([Object]$DsSetting)
    {
        Return [DnsServerDsSetting]::New($DsSetting)
    }
    [Object] DnsServerEDns([Object]$EDns)
    {
        Return [DnsServerEDns]::New($EDns)
    }
    [Object] DnsServerForwarder([UInt32]$Index,[Object]$Forwarder)
    {
        Return [DnsServerForwarder]::New($Index,$Forwarder)
    }
    [Object] DnsServerGlobalNameZone([Object]$Global)
    {
        Return [DnsServerGlobalNameZone]::New($Global)
    }
    [Object] DnsServerGlobalQueryBlockList([Object]$Query)
    {
        Return [DnsServerGlobalQueryBlockList]::New($Query)
    }
    [Object] DnsServerQueryResolutionPolicy([UInt32]$Index,[Object]$Policy)
    {
        Return [DnsServerQueryResolutionPolicy]::New($Index,$Policy)
    }
    [Object] DnsServerZoneTransferPolicy([UInt32]$Index,[Object]$Policy)
    {
        Return [DnsServerZoneTransferPolicy]::New($Index,$Policy)
    }
    [Object] DnsServerRecursion([Object]$Recursion)
    {
        Return [DnsServerRecursion]::New($Recursion)
    }
    [Object] DnsServerRecursionScope([UInt32]$Index,[Object]$Scope)
    {
        Return [DnsServerRecursionScope]::New($Index,$Scope)
    }
    [Object] DnsServerResponseRateLimiting([Object]$Response)
    {
        Return [DnsServerResponseRateLimiting]::New($Response)
    }
    [Object] DnsServerRootHint([UInt32]$Index,[Object]$RootHint)
    {
        Return [DnsServerRootHint]::New($Index,$RootHint)
    }
    [Object] DnsServerScavenging([Object]$Scavenge)
    {
        Return [DnsServerScavenging]::New($Scavenge)
    }
    [Object] DnsServerSetting([Object]$Setting)
    {
        Return [DnsServerSetting]::New($Setting)
    }
    [Object] DnsServerZone([UInt32]$Index,[Object]$Zone)
    {
        Return [DnsServerZone]::New($Index,$Zone)
    }
    [Object] DnsServerZoneAging([UInt32]$Index,[Object]$Aging)
    {
        Return [DnsServerZoneAging]::New($Index,$Aging)
    }
    [Object] DnsServerZoneScope([UInt32]$Index,[Object]$Scope)
    {
        Return [DnsServerZoneScope]::New($Index,$Scope)
    }
    InsertObjectsAbove()
    {
        # Insert extension classes above
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.DnsServer>"
    }
}

# Adds
Class AddsObject
{
    [String]              $Name
    [String]             $Class
    [String]              $Guid
    [String] $DistinguishedName
    AddsObject([Object]$Object)
    {
        $This.Name              = $Object.Name
        $This.Class             = $Object.ObjectClass
        $This.Guid              = $Object.ObjectGUID
        $This.DistinguishedName = $Object.DistinguishedName
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class AddsDomain
{
    [String]   $HostName
    [String]     $DCMode
    [String] $DomainMode
    [String] $ForestMode
    [String]       $Root
    [String]     $Config
    [String]     $Schema
    [Object[]]     $Site
    [Object[]] $SiteLink
    [Object[]]   $Subnet
    [Object[]]     $DHCP
    [Object[]]       $OU
    [Object[]] $Computer
    AddsDomain()
    {
        $Domain          = $This.GetActiveDirectory()
        $This.Hostname   = $Domain.DNSHostName
        $This.DCMode     = $Domain.domainControllerFunctionality
        $This.DomainMode = $Domain.domainFunctionality
        $This.ForestMode = $Domain.forestFunctionality
        $This.Root       = $Domain.rootDomainNamingContext
        $This.Config     = $Domain.configurationNamingContext
        $This.Schema     = $Domain.schemaNamingContext
        $This.Refresh()
    }
    [Object] GetActiveDirectory()
    {
        Return Get-Item AD:
    }
    [Object[]] GetADObject()
    {
        Return Get-ADObject -Filter *
    }
    [Object[]] GetAdObject([String]$SearchBase)
    {
        Return Get-AdObject -Filter * -SearchBase $SearchBase
    }
    [Object[]] GetAdObject([String]$SearchBase,[String]$ObjectClass)
    {
        Return Get-AdObject -Filter * -SearchBase $SearchBase | ? ObjectClass -match $ObjectClass
    }
    [Object] AddsObject([Object]$Object)
    {
        Return [AddsObject]::New($Object)
    }
    Refresh()
    {
        $Cfg             = $This.GetAdObject($This.Config,"(Site|Sitelink|Subnet|Dhcpclass)") | % { $This.AddsObject($_) }
        $Base            = $This.GetAdObject($This.Root,"(OrganizationalUnit|Computer)") | % { $This.AddsObject($_) }

        $This.Site       = $Cfg  | ? Class -eq Site
        $This.SiteLink   = $Cfg  | ? Class -eq Sitelink
        $This.Subnet     = $Cfg  | ? Class -eq Subnet
        $This.Dhcp       = $Cfg  | ? Class -eq DhcpClass
        $This.OU         = $Base | ? Class -eq OrganizationalUnit
        $This.Computer   = $Base | ? Class -eq Computer
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.AddsDomain>"
    }
}

# Veridian
Class VmVhd
{
    [UInt32]   $Index
    [String]    $Path
    [String]  $Format
    [String]    $Type
    [Object] $Current
    [Object] $Maximum
    VmVhd([UInt32]$Index)
    {
        $This.Index   = $Index
        $This.Path    = "<Null>"
        $This.Format  = "<Null>"
        $This.Type    = "<Null>"
        $This.Current = $This.VmNodeByteSize("Current",0)
        $This.Maximum = $This.VmNodeByteSize("Maximum",0)
    }
    VmVhd([UInt32]$Index,[Object]$Vhd)
    {
        $This.Index   = $Index
        $This.Path    = $Vhd.Path
        $This.Format  = $Vhd.VhdFormat
        $This.Type    = $Vhd.VhdType
        $This.Current = $This.VmNodeByteSize("Current",$Vhd.FileSize)
        $This.Maximum = $This.VmNodeByteSize("Maximum",$Vhd.Size)
    }
    [Object] ByteSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Control.VmVhd>"
    }
}

Class VmNode
{
    [Object]       $Name
    [Object]       $Guid
    [Object]       $Path
    [Object] $Generation
    [UInt32]       $Core
    [Object]     $Memory
    [Object]        $Vhd
    [Object]       $Size
    [Object]     $Switch
    VmNode([Object]$Node)
    {
        $This.Name       = $Node.Name
        $This.Guid       = $Node.Id.Guid
        $This.Path       = $Node.Path
        $This.Generation = $Node.Generation
        $This.Core       = $Node.ProcessorCount
        $This.Memory     = $This.VmNodeByteSize("Ram",$Node.MemoryStartup)
        $This.Vhd        = @( )
        $This.Size       = $This.VmNodeByteSize("Hdd",0)
        $This.Switch     = @($Node.NetworkAdapters.SwitchName)
    }
    AddVhd([Object]$Vhd)
    {
        If (!$Vhd)
        {
            $This.Vhd   += $This.VmVhd($This.Vhd.Count)
        }
        Else
        {
            $This.Vhd   += $This.VmVhd($This.Vhd.Count,$Vhd)
        }

        $Total           = $This.Vhd.Current.Bytes -join "+" | Invoke-Expression
        $This.Size       = $This.VmNodeByteSize("Hdd",$Total)
    }
    [Object] VmVhd([UInt32]$Index)
    {
        Return [VmVhd]::New($Index)
    }
    [Object] VmVhd([UInt32]$Index,[Object]$Vhd)
    {
        Return [VmVhd]::New($Index,$Vhd)
    }
    [Object] VmNodeByteSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.VmNode>"
    }
}

Class VmHost
{
    [String]      $Name
    [UInt32] $Processor
    [String]    $Memory
    [String]   $VhdPath
    [String]    $VmPath
    [UInt32]    $Switch
    [UInt32]        $Vm
    VmHost([Object]$Control,[Object]$VmHost)
    {
        $This.Name      = $Control.TargetName
        $This.Processor = $VMHost.LogicalProcessorCount
        $This.Memory    = "{0:n2} GB" -f ($VMHost.MemoryCapacity/1GB)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Control.VmHost>"
    }
}

Class VmControl
{
    [UInt32]     $Domain
    [String]   $HostName
    [String] $TargetName
    [Object] $Credential
    [Object]    $Session
    [Object]       $Host
    [Object]       $Node
    VmControl()
    {
        $This.Domain   = $This.PartOfDomain()
        $This.HostName = $This.SystemName()
        $This.Node     = @( )
    }
    [UInt32] PartOfDomain()
    {
        Return Get-CimInstance Win32_ComputerSystem | % PartOfDomain
    }
    [String] SystemName()
    {
        $System = [Environment]::GetEnvironmentVariable("ComputerName")

        If ($This.Domain)
        {
            $System += (".{0}" -f [Environment]::GetEnvironmentVariable("UserDnsDomain"))
        }

        Return $System.ToLower()
    }
    SetCredential([String]$Username,[SecureString]$Password)
    {
        $This.Credential = $This.PSCredential($Username,$Password)
    }
    SetTargetName([String]$Target)
    {
        $This.TargetName = $Target
    }
    [Object] PSCredential([String]$Username,[SecureString]$Password)
    {
        Return [PSCredential]::New($Username,$Password)
    }
    [Object] VmHost([Object]$VmHost)
    {
        Return [VmHost]::New($This,$VmHost)
    }
    [Object] VmNode([Object]$Node)
    {
        Return [VmNode]::New($Node)
    }
    GetVmHost()
    {
        If (!$This.Session)
        {
            Throw "[!] Not connected"
        }

        Try
        {
            [Console]::WriteLine("Getting [~] Virtual Machine Host")

            $xVmHost   = Get-VmHost -ComputerName $This.TargetName -Credential $This.Credential
            $This.Host = $This.VmHost($xVmHost)
        }
        Catch
        {
            Throw "[!] Connection failed"
        }
    }
    GetVm()
    {
        If (!$This.Session)
        {
            Throw "[!] Not connected"
        }

        Try
        {
            [Console]::WriteLine("Getting [~] Virtual Machine Guest(s)")

            $xVmGuest = Get-Vm -ComputerName $This.TargetName -Credential $This.Credential -EA 0

            ForEach ($xGuest in $xVmGuest)
            {
                $Item = $This.VmNode($xGuest)
                $Vhd  = Get-Vhd -VmId $Item.Guid -ComputerName $This.TargetName -Credential $This.Credential -EA 0
                If ($Vhd)
                {
                    ForEach ($xVhd in $Vhd)
                    {
                        $Item.AddVhd($xVhd)
                    }
                }
                Else
                {
                    $Item.AddVhd($Null)
                }
            
                $This.Node += $Item

                [Console]::WriteLine("Found [+] VM: ($($xGuest.Name)), Size: ($($Item.Size))")
            }

            [Console]::WriteLine("Retrieved [+] Virtual Machine Guest(s), ($($This.Node.Count))")
        }
        Catch
        {
            Throw "[!] Connection failed"
        }
    }
    Connect()
    {
        If (!$This.TargetName)
        {
            [Console]::WriteLine("[!] Target name not set")
        }
        ElseIf (!$This.Credential)
        {
            [Console]::WriteLine("[!] Credential not set")
        }
        Else
        {
            [Console]::WriteLine("Connecting [~] Host: ($($This.TargetName)), Credential: ($($This.Credential.Username))")

            $xSession     = Get-PSSession | ? ComputerName -eq $This.TargetName
            
            If (!$xSession -or $xSession.State -ne "Opened")
            {
                If ($xSession.State -ne "Opened")
                {
                    $xSession | Remove-PSSession
                }

                $xSession = New-PSSession -ComputerName $This.TargetName -Credential $This.Credential
            }

            $This.Session = $xSession
        }
    }
    Disconnect()
    {
        If (!$This.Session)
        {
            Throw "[!] Not connected"
        }

        [Console]::WriteLine("Disconnecting [~] Host: ($($This.TargetName))")

        Get-PSSession | ? ComputerName -eq $This.TargetName | Remove-PSSession

        $This.Session = $Null
    }
    Dispose()
    {
        [Console]::WriteLine("Disposing [~] Virtual Machine Control")

        If ($This.Session)
        {
            $This.Disconnect()
        }

        $This.Credential = $Null
        $This.Host       = $Null
        $This.Node       = @( )
    }
    Populate()
    {
        $This.GetVmHost()
        $This.GetVm()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.VmControl>"
    }
}

# WDS
Class WdsServerConfig
{
    [String]    $Version
    [String]       $Mode
    [String] $Standalone
    [String]       $Path
    WdsServerConfig([String[]]$Config)
    {
        $This.Version    = $This.Pull($Config,"OS Version")
        $This.Mode       = $This.Pull($Config,"WDS operational mode")
        $This.Standalone = $This.Pull($Config,"Standalone configuration")
        $This.Path       = $This.Pull($Config,"RemoteInstall location")
    }
    [String] Pull([String[]]$Config,[String]$Label)
    {
        Return ($Config -match $Label -Split ": ")[1]
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.Config>"
    }
}

Class WdsServerService
{
    [String]      $Status
    [String]        $Name
    [String] $DisplayName
    WdsServerService([Object]$Service)
    {
        $This.Status      = $Service.Status
        $This.Name        = $Service.Name
        $This.DisplayName = $Service.DisplayName
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.Service>"
    }
}

Class WdsServerRegistryItem
{
    [String]        $Name
    [String] $DisplayName
    [String]        $Path
    [String]    $Property
    [String]        $Type
    [Object]       $Value
    WdsServerRegistryItem([String]$DisplayName,[String]$Path,[String]$Property,[String]$Type,[Object]$Value)
    {
        $This.Name        = $DisplayName -Replace " ",""
        $This.DisplayName = $DisplayName
        $This.Path        = $Path
        $This.Property    = $Property
        $This.Type        = $Type
        $This.Value       = $Value
    }
    [Object] GetProperty()
    {
        $xProperty        = @( )

        If ($This.Path -match "\<\w+\>")
        {
            $xPath = $This.Path -Replace "<\w+>",""
            ForEach ($Item in Get-ChildItem $xPath)
            {
                $xProperty += Get-ItemProperty "$xPath\$($Item.Name)" -Property $This.Property
            }
        }

        Else
        {
            $xProperty += Get-ItemProperty -Path $This.Path -Property $This.Property
        }

        Return $xProperty
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.Registry.Item>"
    }
}

Class WdsServerBootImageItem
{
    [Object] $Path
    [Object] $Name
    [Object] $Type
    [Object]  $Iso
    [Object]  $Wim
    [Object]  $Xml
    WdsServerBootImageItem([String]$Path,[String]$Name)
    {
        $This.Path = $Path
        $This.Name = $Name
        $This.Type = @("x86","x64")[$This.Name -match "\(x64\)"]
        $This.ISO  = "$Path\$Name.iso"
        $This.WIM  = "$Path\$Name.wim"
        $This.XML  = "$Path\$Name.xml"
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.BootImage.Item>"
    }
}

Class WdsServerImageItem
{
    [String]        $Type
    [String]        $Arch
    [String]     $Created
    [String]    $Language
    [String] $Description
    [UInt32]     $Enabled
    [String]    $FileName
    [String]          $ID
    WdsServerImageItem([Object]$Type,[Object]$Image)
    {
        $This.Type        = $Type
        $This.Arch        = @("x86","x64")[$Image.Architecture -eq 3]
        $This.Created     = $Image.CreationTime
        $This.Language    = $Image.DefaultLanguage
        $This.Description = $Image.Description
        $This.Enabled     = @(0,1)[$Image.Enabled -eq $True]
        $This.FileName    = $Image.FileName
        $This.ID          = $Image.ID
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.Image.Item>"
    }
}

Class WdsServerImageMaster
{
    [String] $Directory
    [Object]    $Images
    [Object]   $Install
    [Object]      $Boot
    WdsServerImageMaster([Object]$Directory)
    {
        $This.Directory = $Directory
        $This.Refresh()
    }
    Clear()
    {
        $This.Images  = @( )
        $This.Install = @( )
        $This.Boot    = @( )
    }
    Refresh()
    {
        $This.Clear()

        $List = Get-ChildItem $This.Directory | ? Extension | % BaseName | Select-Object -Unique

        ForEach ($Item in $List)
        {
            $This.Images += $This.WdsServerBootImageItem($This.Directory,$Item)
        }
    }
    RefreshInstallImage()
    {
        $This.Install = @( )

        [Console]::WriteLine("Collecting [~] Wds Server Install Images")

        $List = $This.GetWdsInstallImage()

        ForEach ($Item in $List)
        {
            $This.Install += $This.WdsServerImageItem("Install",$Item)
        }
    }
    RefreshBootImage()
    {
        $This.Boot = @( )

        [Console]::WriteLine("Collecting [~] Wds Server Boot Images")

        $List = $This.GetWdsBootImage()

        ForEach ($Item in $List)
        {
            $This.Boot += $This.WdsServerImageItem("Boot",$Item)
        }
    }
    RefreshImageStore()
    {
        $This.RefreshInstallImage()
        $This.RefreshBootImage()
    }
    [Object[]] GetWdsInstallImage()
    {
        Return Get-WdsInstallImage -EA 0
    }
    [Object[]] GetWdsBootImage()
    {
        Return Get-WdsBootImage -EA 0
    }
    [Object] WdsServerBootImageItem([String]$Path,[String]$Name)
    {
        Return [WdsServerBootImageItem]::New($Path,$Name)
    }
    [Object] WdsServerImageItem([Object]$Type,[Object]$Image)
    {
        Return [WdsServerImageItem]::New($Type,$Image)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer.Image.Master>"
    }
}

Class WdsServer
{
    [String]  $Server
    [Object]  $Config
    [String]    $Path
    [Object] $Service
    [Object] $Control
    [Object]   $Image
    WdsServer()
    {
        $This.Refresh("Name")
        $This.Refresh("Config")
        $This.Refresh("Path")
        $This.Refresh("Service")
        $This.Refresh("Control")
        $This.Refresh("Image")
    }
    [String] GetServerHostname()
    {
        $Name = $Env:COMPUTERNAME

        If ($Env:USERDNSDOMAIN)
        {
            $Name = "{0}.{1}" -f $Name, $Env:UserDnsDomain
        }

        Return $Name.ToLower()
    }
    [String[]] GetWdsUtilConfig()
    {
        Return wdsutil /get-server /show:config
    }
    [Object] WdsServerConfig([String[]]$Config)
    {
        Return [WdsServerConfig]::New($Config)
    }
    [Object] WdsServerService([Object]$Service)
    {
        Return [WdsServerService]::New($Service)
    }
    [Object] WdsServerRegistryItem([String]$DisplayName,[String]$Path,[String]$Property,[String]$Type,[Object]$Value)
    {
        Return [WdsServerRegistryItem]::New($DisplayName,$Path,$Property,$Type,$Value)
    }
    [Object] WdsServerImageMaster([Object]$Directory)
    {
        Return [WdsServerImageMaster]::New($Directory)
    }
    [Object] GetConfig()
    {
        $xConfig     = $This.GetWdsUtilConfig()

        Return $This.WdsServerConfig($xConfig)
    }
    InitializeWdsUtil([String]$Path)
    {
        $This.Refresh("Config")
        $This.Refresh("Path")

        If ($This.Config.Mode -ne "Not Configured")
        {
            Throw "[!] Wds Server is already initialized"
        }

        $Parent = $Path | Split-Path -Parent

        If (![System.IO.Directory]::Exists($Parent))
        {
            [Console]::WriteLine("[!] Target location parent does not exist")
        }

        ElseIf ([System.IO.Directory]::Exists($Path))
        {
            [Console]::WriteLine("[!] Target location already exists")
        }

        Else
        {
            Try
            {
                [Console]::WriteLine("Initializing [~] Wds Server: [$Path]")

                wdsutil /initialize-server /reminst:$Path

                Switch ([UInt32]$?)
                {
                    0
                    {
                        [Console]::WriteLine("[!] Wds Server not initialized...")
                    }
                    1
                    {
                        [Console]::WriteLine("Initialized [+] Wds Server")

                        $This.Refresh("Config")
                        $This.Refresh("Path")
                        $This.Refresh("Server")
                    }
                }
            }
            Catch
            {
                [Console]::WriteLine("[!] Wds Server not initialized...")
            }
        }
    }
    UninitializeWdsUtil()
    {
        $This.Refresh("Config")
        $This.Refresh("Path")

        If ($This.Config.Mode -eq "Not Configured")
        {
            Throw "[!] Wds Server is not initialized"
        }

        Try
        {
            [Console]::WriteLine("Uninitializing [~] Wds Server")

            wdsutil /uninitialize-server

            Switch ([UInt32]$?)
            {
                0
                {
                    [Console]::WriteLine("[!] Wds Server not uninitialized...")
                }
                1
                {
                    [Console]::WriteLine("Uninitialized [+] Wds Server")

                    Remove-Item $This.Path -Recurse -Force -Verbose

                    $This.Refresh("Config")
                    $This.Refresh("Path")
                    $This.Refresh("Server")
                }
            }
        }
        Catch
        {
            [Console]::WriteLine("[!] Wds Server not uninitialized...")
        }
    }
    Refresh([String]$Property)
    {
        Switch ($Property)
        {
            Name
            {
                $This.Server  = $This.GetServerHostname()
            }
            Config
            {
                $This.Config  = $This.GetConfig()
            }
            Path
            {
                If ($This.Config.Mode -eq "Not Configured")
                {
                    [Console]::WriteLine("[!] Wds not initialized, must initialize remote installation path")
                }

                $This.Path    = $This.Config.Path
            }
            Service
            {
                $This.Service = $This.GetService()
            }
            Control
            {
                $This.Control = $This.GetRegistry()
            }
            Image
            {
                If (!$This.Image -and $This.Path)
                {
                    $This.Image   = $This.WdsServerImageMaster($This.Path)
                }
            }
        }
    }
    [Object] GetService()
    {
        $xService    = Get-Service -Name WDSServer -EA 0

        Return $This.WdsServerService($xService)
    }
    [Object[]] GetRegistry()
    {
        # Modified version of https://www.windows-noob.com/forums/topic/617-windows-deployment-services-registry-entries/

        $Hash = @( )

        # | Critical Providers |

        $Hash += $This.WdsServerRegistryItem("Critical Providers",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsDcMgr",
        "IsCritical","REG_DWORD",@{0="Not critical";1="Critical"})

        # | Client Answer Policy |

        # Windows Deployment Services has a global on/off policy that controls whether or not client requests are answered
        $Hash += $This.WdsServerRegistryItem("Client Answer Requests",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "netbootAnswerRequests","REG_SZ",@{$False="Client requests will not be answered";$True="Client requests will be answered"})

        # You can configure Windows Deployment Services to answer all incoming PXE requests or only those from prestaged 
        # clients (for example, WDSUTIL /Set-Server /AnswerClients:All).
        $Hash += $This.WdsServerRegistryItem("Client Answer Valid Clients",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "netbootAnswerOnlyValidClients","REG_SZ",@{$False="All client requests will be answered";$True="Only prestaged clients will be answered"})

        # Logging for the Windows Deployment Services Client
        # The values for logging level are stored in the following keys of the Windows Deployment Services server:
        $Hash += $This.WdsServerRegistryItem("Client Logging Bool",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging",
        "Enabled","REG_DWORD", @{0="DISABLED";1="ENABLED"})

        # | Client Logging |

        $Hash += $This.WdsServerRegistryItem("Client Logging Level",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging",
        "LogLevel","REG_DWORD",@{0="OFF";1="ERRORS";2="WARNINGS";3="INFO"})

        # | DHCP Authorization |

        # Specifies the amount of time (in seconds) that the PXE server will wait before rechecking its authorization. 
        # This time is only used when a successful authorization process has been performed, irrespective of whether the server was previously authorized.
        $Hash += $This.WdsServerRegistryItem("DHCP Auth Recheck Time",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "AuthRecheckTime","REG_DWORD",3600)

        # Specifies the amount of time (in seconds) that the PXE server will wait if any step of authorization fails
        $Hash += $This.WdsServerRegistryItem("DHCP Auth Timeout",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "AuthFailureRetryTime","REG_DWORD",30)

        # Rogue Detection
        $Hash += $This.WdsServerRegistryItem("Rogue Detection Bool",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "DisableRogueDetection","REG_DWORD",@{0="Enabled";1="Disabled"})

        # Whenever the PXE server successfully queries AD DS, the results are cached under HKLM\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\AuthCache as follows:
        $Hash += $This.WdsServerRegistryItem("DHCP Authorization Cache",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\AuthCache",
        $Env:UserDnsDomain.ToLower(),"REG_DWORD",@{0="Failed communication with ADDS, server not authorized";1="Successful communication with ADDS, server authorized"})

        # Toggles whether the DHCP server ignores port 67
        $Hash += $This.WdsServerRegistryItem("Toggle DHCP Port 67",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "UseDHCPPorts","REG_DWORD",@{0="PXE server DOES NOT listen on port 67";1="PXE server DOES listen on port 67"})

        # Architecture Detection
        $Hash += $This.WdsServerRegistryItem("Architecture Detection",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "DisableArchDisc","REG_DWORD",@{0="Architecture discovery ENABLED";1="Architecture discovery is DISABLED"})

        # PXE Response Delay
        $Hash += $This.WdsServerRegistryItem("PXE Response Delay",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "ResponseDelay","REG_DWORD",0) # <delay time, in seconds>

        # Banned GUIDs
        # Tells certain GUIDs that they're tentatively banned from going to the WDS's birthday party
        $Hash += $This.WdsServerRegistryItem("Banned Guids",
        "HKLM:\SYSTEM\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "BannedGuids","REG_MULTI_SZ","{00000000000000000000000000000000}") 

        # Order of PXE Providers
        # A registering provider can select its order in the existing provider list. The provider order is maintained in the registry at the following location:
        $Hash += $This.WdsServerRegistryItem("PXE Provider Order",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "ProvidersOrder","MULTI_SZ","WDSDCPXE") # Default / Ordered list of providers

        # Registered PXE Providers
        $Hash += $This.WdsServerRegistryItem("PXE Providers Registered",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\<Custom Provider Name>",
        "ProviderDLL","REG_SZ","%systemroot%\system32\wdspxe.dll") # Default / The full path and file name of the provider .dll

        # Bind Policy for Network Interfaces
        $Hash += $This.WdsServerRegistryItem("Bind Policy Network Interfaces",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "BindPolicy","REG_DWORD",@{0="Defined bind interfaces EXCLUDED";1="Defined bind interfaces INCLUDED"})

        # BindInterfaces
        $Hash += $This.WdsServerRegistryItem("Bind Interface List",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
        "BindInterfaces","REG_MULTI_SZ",@{-1=$Null;0="Exclude, set BindInterfaces to IP/MAC for interfaces to INCLUDE";1="Include, set BindInterfaces to IP/MAC for interfaces to EXCLUDE"})

        # Location of TFTP Files
        # The TFTP root is the parent folder that contains all files available for download by client computers. 
        # By default, the TFTP root is set to the RemoteInstall folder as specified in the following registry setting:
        $Hash += $This.WdsServerRegistryItem("TFTP File Path",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsTftp",
        "RootFolder","REG_SZ","C:\RemoteInstall") # Default / <full path and folder name of the TFTP root>

        # Unattended installation
        # This policy is defined in the Windows Deployment Services server registry at the following location:
        $Hash += $This.WdsServerRegistryItem("Unattend Install Bool",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\WdsImgSrv\Unattend",
        "Enabled","REG_DWORD",@{0="Disabled";1="Enabled"})

        # Per-Architecture Unattend Policy
        # Unattend files are architecture specific, so you need a unique file for each architecture. 
        # These values are stored in the registry at the following location (where <arch> is either x86, x64, or ia64):
        $Hash += $This.WdsServerRegistryItem("Per Arch Unattend Path",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\WdsImgSrv\Unattend\<arch>",
        "WDSUnattendFilePath","REG_SZ",$Null) 
        # The file path to the Windows Deployment Services client unattend file (for example, D:\RemoteInstall\WDSClientUnattend\WDSClientUnattend.xml)

        # Network Boot Programs
        $Hash += $This.WdsServerRegistryItem("Network Boot Programs:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm",
        "Default","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Network Boot Programs:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64",
        "Default","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Network Boot Programs:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64",
        "Default","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Network Boot Programs:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86",
        "Default","REG_SZ",$Null)

        # The relative path to the default NBP that all booting clients of this architecture should receive (for example, boot\x86\pxeboot.com)

        # Per-Client NBP
        $Hash += $This.WdsServerRegistryItem("Relative Client NBP Path:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Relative Client NBP Path:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Relative Client NBP Path:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Relative Client NBP Path:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86",
        ".n12","REG_SZ",$Null)

        # The relative path to the NBP that will be sent by using the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12)

        # Unknown Clients Automatically PXE Boot
        $Hash += $This.WdsServerRegistryItem("Unknown Clients Auto PXE Boot",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\",
        "AllowN12ForNewClients","REG_DWORD",@{0="Not Enabled";1="Unknown allowed"})

        # .n12 NBP
        # WDS sends defined (.n12 NBP) according to registry settings (where <arch> is either x86, x64, or IA64)
        # The relative path to the NBP that will be sent according to the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12).
        $Hash += $This.WdsServerRegistryItem("N12 NBP:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("N12 NBP:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("N12 NBP:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64",
        ".n12","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("N12 NBP:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86",
        ".n12","REG_SZ",$Null)

        # | Resetting the NBP to the Default on the Next Boot |
        $Hash += $This.WdsServerRegistryItem("Reset NBP Default Next Boot",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "ResetBootProgram","REG_DWORD",@{0="No Action";1="Reset netbootMachineFilePath"})

        # | Auto Approval |
        $Hash += $This.WdsServerRegistryItem("Auto Device Approval",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove",
        "Policy","REG_DWORD",@{0="No action";1="Pending"})
        
        # | Auto-Add Policy |
        $Hash += $This.WdsServerRegistryItem("Auto Add Policy",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove",
        "PendingMessage","REG_SZ",$Null)

        # | Time-Out Value |

        <# The client state is not maintained on the server. Rather, the Wdsnbp.com program polls the server
           for the settings in the following keys after it has paused the client's boot. The values for these
           settings are sent to the client by the server in the DHCP options field of the DHCP acknowledge
           control packet (ACK). The default setting for these values is to poll the server every 10 seconds
           for 2,160 tries, bringing the total default time-out to six hours. #>
        $Hash += $This.WdsServerRegistryItem("Time Out Value",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove",
        "PollInterval","REG_DWORD",$Null) # <- The amount of time (in seconds) between polls of the server.

        # | Max Retry Count |

        $Hash += $This.WdsServerRegistryItem("Max Retry Count",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove",
        "PollMaxRetry","REG_DWORD",2160)

        # | Referral server |

        # The name of the Windows Deployment Services server that the client should download the NBP from
        $Hash += $This.WdsServerRegistryItem("Referral Server:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "ReferralServer","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Referral Server:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "ReferralServer","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Referral Server:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "ReferralServer","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Referral Server:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "ReferralServer","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Referral Server:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "ReferralServer","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Referral Server:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "ReferralServer","REG_SZ",$Null)

        # The name of the server to refer the client to. The default setting is for this value to be blank (no server name).

        # | Boot Program Path |

        # The name of the NBP that the client should download
        $Hash += $This.WdsServerRegistryItem("Boot Program Path:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "BootProgramPath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Program Path:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "BootProgramPath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Program Path:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "BootProgramPath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Program Path:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "BootProgramPath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Program Path:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "BootProgramPath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Program Path:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "BootProgramPath","REG_SZ",$Null)

        # | Boot Image Path |

        # Name of boot image that client should receive (default = blank/no boot image)
        # Setting this value means client won't see boot menu since image will be processed automatically
        $Hash += $This.WdsServerRegistryItem("Boot Image Path:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "BootImagePath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Image Path:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "BootImagePath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Image Path:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "BootImagePath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Image Path:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "BootImagePath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Image Path:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "BootImagePath","REG_SZ",$Null)

        $Hash += $This.WdsServerRegistryItem("Boot Image Path:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "BootImagePath","REG_SZ",$Null)

        # | Domain Administrator Account |

        # The primary user associated with the generated computer account.
        # This user will be granted JoinRights authorization, as defined later in this section
        $Hash += $This.WdsServerRegistryItem("Domain Administrator:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "User","REG_SZ","Domain Admins")

        $Hash += $This.WdsServerRegistryItem("Domain Administrator:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "User","REG_SZ","Domain Admins")

        $Hash += $This.WdsServerRegistryItem("Domain Administrator:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "User","REG_SZ","Domain Admins")

        $Hash += $This.WdsServerRegistryItem("Domain Administrator:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "User","REG_SZ","Domain Admins")

        $Hash += $This.WdsServerRegistryItem("Domain Administrator:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "User","REG_SZ","Domain Admins")

        $Hash += $This.WdsServerRegistryItem("Domain Administrator:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "User","REG_SZ","Domain Admins")

        # | Join Domain |

        # Computer should (0 = be / 1 = not be) joined to the domain
        $Hash += $This.WdsServerRegistryItem("Join Domain:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        $Hash += $This.WdsServerRegistryItem("Join Domain:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        $Hash += $This.WdsServerRegistryItem("Join Domain:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        $Hash += $This.WdsServerRegistryItem("Join Domain:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        $Hash += $This.WdsServerRegistryItem("Join Domain:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        $Hash += $This.WdsServerRegistryItem("Join Domain:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})

        # | Join Rights |

        # JoinOnly - requires the admin to reset the computer account before the user can join the computer to the domain
        # Full     - gives full permissions to the user (including the right to join the domain)
        $Hash += $This.WdsServerRegistryItem("Join Rights:arm",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        $Hash += $This.WdsServerRegistryItem("Join Rights:ia64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        $Hash += $This.WdsServerRegistryItem("Join Rights:x64",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        $Hash += $This.WdsServerRegistryItem("Join Rights:x64uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        $Hash += $This.WdsServerRegistryItem("Join Rights:x86",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        $Hash += $This.WdsServerRegistryItem("Join Rights:x86uefi",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi",
        "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})

        # | Default Server |

        $Hash += $This.WdsServerRegistryItem("Default Server",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "DefaultServer","REG_SZ",$This.Server)

        # | Global Catalog |

        # (NETBIOS/FQDN) name of the [global catalog] that [WDS] should use.
        $Hash += $This.WdsServerRegistryItem("Default Global Catalog",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "DefaultGCServer","REG_SZ",$This.Server)

        # | Search Order |
        $Hash += $This.WdsServerRegistryItem("Active Directory Search Order",
        "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
        "ADSearchOrder","REG_SZ",@{0="Search global catalog First";1="Search domain controller first"})

        Return $Hash
    }
    StartService()
    {
        If ($This.Service.Status -ne "Running")
        {
            [Console]::WriteLine("Starting [~] Wds Server")

            Set-Service -Name WDSServer -Status Running -EA 0

            If (!$?)
            {
                [Console]::WriteLine("[!] Unable to start service, initialize server w/ remote install path")
            }

            $This.Refresh("Service")
        }
    }
    StopService()
    {
        If ($This.Service.Status -eq "Running")
        {
            [Console]::WriteLine("Stopping [~] Wds Server")

            Set-Service -Name WDSServer -Status Stopped

            If (!$?)
            {
                [Console]::WriteLine("[!] Unable to stop service")
            }
        }

        $This.Refresh("Service")
    }
    InitializeService()
    {
        $This.SetService()

        If (!$This.Service)
        {
            Throw "[!] WDS Server not installed"
        }

        If ($This.Service.Status -ne "Running")
        {
            $This.StartService()
        }
    }
    SetIpAddress([String[]]$IpAddress)
    {
        $This.IpAddress = $IpAddress
    }
    ClearIpAddress()
    {
        $This.IpAddress = @( )
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.WdsServer>"
    }
}

# Mdt
Enum MdtServerObjectType
{
    Groups
    Medias
    OperatingSystems
    Packages
    SelectionProfiles
    TaskSequences
    Applications
    Drivers
    LinkedDeploymentShares
}

Class MdtServerWimFile
{
    [UInt32]             $Rank
    [Object]            $Label
    [String]             $Size
    [Object]             $Date
    [UInt32]       $ImageIndex = 1
    [String]        $ImageName
    [String] $ImageDescription
    [String]          $Version
    [String]     $Architecture
    [String] $InstallationType
    [String]  $SourceImagePath
    MdtServerWimFile([UInt32]$Rank,[String]$Image)
    {
        If (![System.IO.File]::Exists($Image))
        {
            Throw "[!] Invalid Path"
        }

        $Item                  = Get-Item $Image
        $This.Size             = "{0:n2} GB" -f ($Item.Length/1GB)
        $This.Date             = $Item.LastWriteTime.GetDateTimeFormats()[5]
        $SDate                 = $This.Date.Split("-")
        $This.SourceImagePath  = $Image
        $This.Rank             = $Rank

        $xImage                = $This.GetWindowsImage()

        $This.Version          = $xImage.Version
        $This.Architecture     = @(86,64)[$xImage.Architecture -eq 9]
        $This.InstallationType = $xImage.InstallationType
        $This.ImageName        = $xImage.ImageName
        $This.Label            = $Item.BaseName
        $This.ImageDescription = "[{0}-{1}{2} (MCC/SDP)][{3}]" -f $SDate[0], $SDate[1], $SDate[2], $This.Label
    }
    [Object[]] GetWindowsImage([String]$Path)
    {
        Return Get-WindowsImage -ImagePath $Path -Index 1
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.WimFile>"
    }
}

Class MdtServerBrand
{
    [String]    $Wallpaper
    [String]         $Logo
    [String] $Manufacturer
    [String] $SupportPhone
    [String] $SupportHours
    [String]   $SupportURL
    MdtServerBrand()
    {
        $System            = $This.GetItemProperty("System")
        $OEM               = $This.GetItemProperty("OEM")

        $This.Wallpaper    = $System.Wallpaper
        $This.Logo         = $Oem.Logo
        $This.Manufacturer = $Oem.Manufacturer
        $This.SupportPhone = $Oem.SupportPhone
        $This.SupportHours = $Oem.SupportHours
        $This.SupportURL   = $Oem.SupportURL
    }
    MdtServerBrand(
    [String]    $Wallpaper ,
    [String]         $Logo ,
    [String] $Manufacturer ,
    [String]        $Phone ,
    [String]        $Hours ,
    [String]          $URL )
    {
        $This.Wallpaper    = $Wallpaper
        $This.Logo         = $Logo
        $This.Manufacturer = $Manufacturer
        $This.SupportPhone = $Phone
        $This.SupportHours = $Hours
        $This.SupportURL   = $URL
    }
    [Object] Registry([String]$Type)
    {
        $Item = Switch ($Type)
        {
            System { "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" }
            OEM    { "HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation"  }
        }

        Return Get-ItemProperty $Item -EA 0
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.Brand>"
    }
}
    
Class MdtServerShareKey
{
    [String]     $NetworkPath
    [String]    $Organization
    [String]      $CommonName
    [String]      $Background
    [String]            $Logo
    [String]           $Phone
    [String]           $Hours
    [String]         $Website
    MdtServerShareKey([String]$Path)
    {
        $Root                 = Import-Csv $Path
        $This.NetworkPath     = $Root.NetworkPath
        $This.Organization    = $Root.Organization
        $This.CommonName      = $Root.CommonName
        $This.Background      = $Root.Background 
        $This.Logo            = $Root.Logo
        $This.Phone           = $Root.Phone
        $This.Hours           = $Root.Hours
        $This.Website         = $Root.Website
    }
    MdtServerShareKey([Object]$Object)
    {
        $This.NetworkPath     = $Object[0].Split('"')[1]
        $This.Organization    = $Object[1].Split('"')[1]
        $This.CommonName      = $Object[2].Split('"')[1]
        $This.Background      = $Object[3].Split('"')[1]
        $This.Logo            = $Object[4].Split('"')[1]
        $This.Phone           = $Object[5].Split('"')[1]
        $This.Hours           = $Object[6].Split('"')[1]
        $This.Website         = $Object[7].Split('"')[1]
    }
    MdtServerShareKey(
    [String]  $NetworkPath ,
    [String] $Organization ,
    [String]   $CommonName ,
    [String]   $Background ,
    [String]         $Logo ,
    [String]        $Phone ,
    [String]        $Hours ,
    [String]      $Website )
    {
        $This.Networkpath     = $NetworkPath
        $This.Organization    = $Organization
        $This.CommonName      = $CommonName
        $This.Background      = $Background
        $This.Logo            = $Logo
        $This.Phone           = $Phone
        $This.Hours           = $Hours
        $This.Website         = $Website
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.ShareKey>"
    }
}

Class MdtServerDomain
{
    [Object] $Credential
    [String]    $NetBIOS
    [String]    $DnsName
    [String]  $MachineOU
    MdtServerDomain([String]$Username,[SecureString]$Password,[String]$NetBIOS,[String]$DnsName,[String]$OUName)
    {
        $This.Credential = $This.Credential($Username,$Password)
        $This.NetBIOS    = $NetBIOS
        $This.DnsName    = $DnsName
        $This.MachineOU  = $OUName
    }
    [PSCredential] Credential([String]$Username,[SecureString]$Password)
    {
        Return [PSCredential]::New($Username,$Password)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.Domain>"
    }
}

Class MdtServerBootImageItem
{
    [Object] $Path
    [Object] $Name
    [Object] $Type
    [Object]  $Iso
    [Object]  $Wim
    [Object]  $Xml
    MdtServerBootImageItem([String]$Path,[String]$Name)
    {
        $This.Path = $Path
        $This.Name = $Name
        $This.Type = @("x86","x64")[[UInt32]($This.Name -match "\(x64\)")]
        $This.Iso  = "$Path\$Name.iso"
        $This.Wim  = "$Path\$Name.wim"
        $This.Xml  = "$Path\$Name.xml"
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.BootImage.Item>"
    }
}

Class MdtServerBootImageMaster
{
    [String] $Directory
    [Object] $Images
    MdtServerBootImageMaster([Object]$Directory)
    {
        $This.Directory = $Directory
        $This.Refresh()
    }
    Clear()
    {
        $This.Images = @( )
    }
    Refresh()
    {
        $This.Clear()

        [Console]::WriteLine("Refreshing [~] Mdt Server Boot Images")

        $List = Get-ChildItem $This.Directory | ? Extension | % BaseName | Select-Object -Unique

        ForEach ($Item in $List)
        {
            $This.Images += $This.MdtServerBootImageItem($This.Directory,$Item)
        }
    }
    [Object] MdtServerBootImageItem([String]$Path,[String]$Name)
    {
        Return [MdtServerBootImageItem]::New($Path,$Name)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.BootImage.Master"
    }
}

Class MdtServerPersistentDriveImageMaster
{
    [Object] $Current
    [Object]  $Import
    MdtServerPersistentDriveImageMaster()
    {
        $This.Clear()
    }
    Clear()
    {
        $This.Current = @( )
        $This.Import  = @( )
    }
    [Object] MdtServerWimFile([UInt32]$Rank,[String]$Image)
    {
        Return [MdtServerWimFile]::New($Rank,$Image)
    }
    Load([String]$Type,[String]$Path)
    {
        [Console]::WriteLine("Loading [~] Mdt Server Wim File(s)")

        $Files        = Get-ChildItem $Path *.wim -Recurse

        If ($Files.Count -gt 0)
        {
            ForEach ($File in $Files)
            {
                [Console]::WriteLine("Importing [~] ($($File.Name))")

                $Count = @($This.Current.Count,$This.Import.Count)[$Type]
                $Item  = $This.MdtServerWimFile($Count,$File.Fullname)

                Switch ($Type)
                {
                    Current { $This.Current += $Item }
                    Import  { $This.Import  += $Item }
                }
            }
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive.Image.Master>"
    }
}

Class MdtServerPersistentDriveConfigItem
{
    [String]      $Name
    [String]      $Path
    [String[]] $Content
    [Object]    $Object
    MdtServerPersistentDriveConfigItem([String]$Name,[String]$Path)
    {
        $This.Name    = $Name
        $This.Path    = $Path

        If ([System.IO.File]::Exists($Path))
        {
            If ($Name -match "DSKey") 
            {
                $This.Content = (Import-Csv $Path).PSObject.Properties | % { "$($_.Name)=`"$($_.Value)`"" }
            } 
            Else 
            { 
                $This.Content = [System.IO.File]::ReadAllLines($Path)
            }
        }
        Else
        {
            [System.IO.File]::Create($Path).Dispose()
        }
    }
    [Object] MdtServerShareKey([Object]$Content)
    {
        Return [MdtServerShareKey]::New($Content)
    }
    SetContent([Object]$Content)
    {
        $This.Content  = $Content

        If ($This.Name -eq "DSKey")
        {
            Export-Csv -Path $This.Path -InputObject $This.MdtServerShareKey($This.Content) -Verbose
        }
        Else
        {
            [System.IO.File]::WriteAllLines($This.Path,$This.Content,[System.Text.UTF8Encoding]$False)
        }
    }
    [Object] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive.Config.Item>"
    }
}

Class MdtServerPersistentDriveConfigMaster
{
    [String]   $Path
    [Object] $Config
    MdtServerPersistentDriveConfigMaster([String]$Path)
    {
        $This.Path    = $Path

        $This.Config  = @( )
        $This.Config += $This.GetConfig("Bootstrap","$Path\Control\Bootstrap.ini")
        $This.Config += $This.GetConfig("CustomSettings","$Path\Control\Customsettings.ini")
        $This.Config += $This.GetConfig("Postconfig","$Path\Scripts\Install-FightingEntropy.ps1")
        $This.Config += $This.GetConfig("DSKey","$Path\DSKey.csv")
    }
    [Object] GetConfig([String]$Type,[String]$Path)
    {
        Return [MdtServerPersistentDriveConfigItem]::New($Type,$Path)
    }
    [Object] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive.Config.Master>"
    }
}

Class MdtServerPersistentDriveItem
{
    Hidden [Object] $Node
    [String]        $Name
    [String]        $Guid
    [String]        $Path
    MdtServerPersistentDriveItem([Object]$Object)
    {
        $This.Node = $Object
        $This.Guid = $Object.Guid
        $This.Name = $Object.PSChildName
        $This.Path = $Object.PSPath.Substring(40)
    }
    [Object] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive.Item>"
    }
}

Class MdtServerPersistentDriveContent
{
    [String]    $Type
    [String]    $Path
    [Object] $Content
    MdtServerPersistentDriveContent([String]$Path)
    {
        $This.Type    = $Path.Split("\")[1]
        $This.Path    = $Path

        $This.Refresh()
    }
    Clear()
    {
        $This.Content = @( ) 
    }
    Refresh()
    {
        $This.Clear()

        $Items = Get-ChildItem $This.Path -Recurse | ? PSIsContainer -eq 0 
        
        ForEach ($Item in $Items)
        {
            $This.Content += $This.MdtServerPersistentDriveItem($Item)
        }
    }
    [Object] MdtServerPersistentDriveItem([Object]$Object)
    {
        Return [MdtServerPersistentDriveItem]::New($Object)
    }
    [Object] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive.Item>"
    }
}

Class MdtServerPersistentDrive
{
    [String]          $Name
    [String]          $Root
    [Object]         $Share
    [String]   $Description
    [String]          $Type
    [Object]      $Property
    [Object]       $Content
    [Object]        $Config
    [Object]        $Images
    [Object]         $Brand
    [Object]        $Domain
    [Object]    $Connection
    [String] $Administrator
    [String]      $Password
    MdtServerPersistentDrive()
    {
        $This.Name        = "<New>"
        $This.Root        = "-"
        $This.Share       = "-"
        $This.Description = "-"
        $This.Type        = "-"
        $This.Property    = $Null
        $This.Content     = $Null
        $This.Config      = $Null
        $This.Images      = $Null
    }
    MdtServerPersistentDrive([Object]$Drive)
    {
        $This.Name        = $Drive.Name
        $This.Root        = $Drive.Path
        $This.Share       = Get-SMBShare | ? Path -eq $Drive.Path | % Name
        $This.Description = $Drive.Description
        $This.Type        = @("MDT","PSD")[[UInt32][System.IO.Directory]::Exists("$($This.Root)\PSDResources")]
        $This.Property    = $This.GetDriveProperties()
        $This.Content     = $This.GetDriveContent()
        $This.Config      = $This.MdtServerPersistentDriveConfigMaster($This.Root)
        $This.Images      = $This.MdtServerPersistentDriveImageMaster()

        $This.Images.Load("Current","$($This.Root)\Operating Systems")
    }
    MdtServerPersistentDrive([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
    {
        If (Get-SMBShare -Name $Share -EA 0)
        {
            Throw "Share name is already assigned"
        }

        $This.Name          = $Name
        $This.Root          = $Root
        $This.Share         = $Share
        $This.Description   = $Description
        $This.Type          = @("MDT","PSD","-")[$Type]

        If (![System.IO.Directory]::Exists($This.Root))
        {
            [System.IO.Directory]::CreateDirectory($This.Root)
        }

        $SMB            = @{

            Name        = $This.Share
            Path        = $This.Root
            Description = $This.Description
            FullAccess  = "Administrators"
        }

        $PSD            = @{ 
    
            Name        = $This.Name
            PSProvider  = "MDTProvider"
            Root        = $This.Root
            Description = $This.Description
            NetworkPath = ("\\{0}\{1}" -f $This.GetHostname(), $This.Share)
        }

        New-SMBShare @SMB
        New-PSDrive  @PSD -Verbose | Add-MDTPersistentDrive -Verbose

        $This.Property    = $This.GetDriveProperties()
        $This.Content     = $This.GetDriveContent()
        $This.Config      = $This.MdtServerPersistentDriveConfigMaster($This.Root)
        $This.Images      = $This.MdtServerPersistentDriveImageMaster()
    }
    [Object] MdtServerPersistentDriveConfigMaster([String]$Path)
    {
        Return [MdtServerPersistentDriveConfigMaster]::New($Path)
    }
    [Object] MdtServerPersistentDriveImageMaster()
    {
        Return [MdtServerPersistentDriveImageMaster]::New()
    }
    [Object] MdtServerPersistentDriveContent([String]$Path)
    {
        Return [MdtServerPersistentDriveContent]::New($Path)
    }
    SetDefaults([Object]$Module)
    {
        $Mod = $Module.Manifest.Output[0].Item | ? Name -match "(.png|Mod.xml)"
        $Gfx = $Module.Manifest.Output[2].Item | ? Name -match "(background.jpg|OEMlogo.bmp)"

        # Copies the background and logo if they were selected and are found
        ForEach ($File in $Gfx)
        {
            Copy-Item -Path $File.Fullname -Destination "$($This.Root)\Script" -Verbose
        }

        # For the PXE environment images
        ForEach ($File in $Mod | ? Name -match .png)
        {
            Copy-Item -Path $File.Fullname -Destination "$($This.Root)\Script" -Force -Verbose
        }

        # Copies custom template for FightingEntropy to post install/configure
        ForEach ($File in $Mod | ? Name -match Mod.xml)
        {
            Copy-Item -Path $File.Path -Destination "$Env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
        }
    }
    [Object] GetDriveProperties()
    {
        Restore-MDTPersistentDrive

        Return (Get-ItemProperty -Path "$($This.Name):").PSObject.Properties | Select-Object Name, Value
    }
    SetDriveProperty([String]$Name,[Object]$Value)
    {
        Restore-MDTPersistentDrive

        If ($This.Property | ? Name -eq $Name)
        {
            Set-ItemProperty -Path "$($This.Name):" -Name $Name -Value $Value
        }

        $This.Property = $This.GetDriveProperties()
    }
    [Object] GetDriveProperty([String]$Name)
    {
        Restore-MDTPersistentDrive

        Return (Get-ItemProperty -Path "$($This.Name):" -Name $Name)
    }
    [String[]] Directives()
    {
        Return @("Applications",
        "Operating Systems",
        "Out-of-Box Drivers",
        "Packages",
        "Task Sequences",
        "Selection Profiles",
        "Linked Deployment Shares",
        "Media" | % { "$($This.Name):\$_" })
    }
    [Object] GetDriveContent()
    {
        Restore-MDTPersistentDrive

        $xContent = @( )

        ForEach ($Item in $This.Directives())
        {
            $xContent += $This.MdtServerPersistentDriveContent($Item)
        }

        Return $xContent
    }
    [Object[]] Select([String]$Type)
    {
        Return @($This.Content | ? Type -eq $Type | % Content)
    }
    [Object] SelectConfig([String]$Type)
    {
        Return ($This.Config | ? Name -eq $Type)
    }
    [String] GetHostname()
    {
        $xName = $Env:COMPUTERNAME

        If ($Env:USERDNSDOMAIN)
        {
            $xName = "{0}.{1}" -f $xName, $Env:UserDnsDomain
        }

        Return $xName.ToLower()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer.PersistentDrive>"
    }
}

Class MdtServer
{
    [Object]       $Module
    [Object]    $MdtModule
    [String]       $Server
    [String[]]  $IpAddress
    [String] $Organization
    [String]   $CommonName
    [Object]        $Drive
    MdtServer([Object]$Module)
    {
        $This.Module    = $Module
        $This.MdtModule = Get-MdtModule
        $This.Server    = $This.GetServerHostname()

        If (!$This.MdtModule.Status)
        {
            Throw "[!] (Mdt/WinAdk/WinPe) not installed"
        }
    }
    [String] GetServerHostname()
    {
        $Name = $Env:COMPUTERNAME

        If ($Env:USERDNSDOMAIN)
        {
            $Name = "{0}.{1}" -f $Name, $Env:UserDnsDomain
        }

        Return $Name.ToLower()
    }
    SetIpAddress([String[]]$IpAddress)
    {
        $This.IpAddress = $IpAddress
    }
    Refresh()
    {
        If (![System.IO.File]::Exists($This.MdtModule.Path))
        {
            Throw "[!] Path to MicrosoftDeploymentToolkit.psd1 is invalid"
        }

        $This.MdtModule.Path | Import-Module

        Restore-MDTPersistentDrive

        $List       = $This.GetMdtPersistentDrive()
        $This.Drive = @( )
        $This.Drive.Add($This.MdtServerPersistentDrive()) # <- Blank template Mdt drive

        ForEach ($Object in $List) 
        { 
            $This.Drive.Add($This.MdtServerPersistentDrive($Object))
        }
    }
    [Object[]] GetMdtPersistentDrive()
    {
        Return Get-MdtPersistentDrive
    }
    SetDomain([String]$Organization,[String]$CommonName)
    {
        $This.Organization = $Organization
        $This.CommonName   = $CommonName
    }
    [String[]] PsdOldFiles()
    {
        Return "UdiWizard_Config.xml.app",
        "Wizard.hta",
        "Wizard.ico",
        "Wizard.css",
        "Autorun.inf",
        "Bdd_Welcome_Enu.xml",
        "Credentials_Enu.xml",
        "Summary_Definition_Enu.xml",
        "DeployWiz_Roles.xsl"
    }
    [String[]] PsdModules()
    {
        Return "PsdGather",
        "PsdDeploymentShare",
        "PsdUtility",
        "PsdWizard"
    }
    [String[]] PsdSnapIns()
    {
        Return "PSSnapIn.dll",
        "PSSnapIn.dll.config",
        "PSSnapIn.dll-help.xml",
        "PSSnapIn.Format.ps1xml",
        "PSSnapIn.Types.ps1xml",
        "Core.dll",
        "Core.dll.config",
        "ConfigManager.dll"
    }
    [String[]] PsdFolders()
    {
        Return "Autopilot",
        "BootImageFiles\x86",
        "BootImageFiles\x64",
        "Branding",
        "Certificates",
        "CustomScripts",
        "DriverPackages",
        "DriverSources",
        "UserExitScripts",
        "BGInfo",
        "Prestart"
    }
    [String[]] PsdAccounts()
    {
        Return "Users",
        "Administrators",
        "SYSTEM"
    }
    [String] GetDriveComment([String]$Type)
    {
        Return "{0}[{1} (SDP)][{2}]" -f $This.Module.Label(), $This.Module.DateTime(), $Type
    }
    [String] GetImageLabel([String]$Type)
    {
        Return "{0}[{1}][{2}]" -f $This.Module.Label(), $This.Module.Now(), $Type
    }
    [Object[]] UpdateDriveProperties([String]$Type,[String]$Background)
    {
        $Label  = $This.GetImageLabel($Type,$Background)
        $Names  = "Boot.x64.GenerateLiteTouchISO",
        "Boot.x64.LiteTouchWIMDescription",
        "Boot.x64.LiteTouchISOName",
        "Boot.x64.BackgroundFile",
        "Boot.x86.GenerateLiteTouchISO",
        "Boot.x86.LiteTouchWIMDescription",
        "Boot.x86.LiteTouchISOName",
        "Boot.x86.BackgroundFile"

        $Values = ForEach ($Item in 64, 86)
        {
            "True";
            "{0}({1})" -f $Label, $Item;
            "{0}({1}).iso" -f $Label, $Item;
            "%DEPLOYROOT%\Graphics\$Background";
        }

        $Output = ForEach ($X in 0..7)
        {
            [PSNoteProperty]::New($Names[$X],$Values[$X])
        }

        Return $Output | Select-Object Name, Value
    }
    PsdShare([String]$Name)
    {
        $Select = $This.GetDrive($Name)
        $This.MdtModule | Import-Module

        Restore-MdtPersistentDrive -Verbose

        $Psd    = Get-PsdModule
        $Name   = "$($Select.Name):"
        $Root   = $Select.Root
        $Share  = $Select.Share
        $Backup = "$Root\Backup\Scripts"

        # Create backup folder
        If (![System.IO.Directory]::Exists($Backup))
        {
            [System.IO.Directory]::CreateDirectory($Backup)
        }

        # Remove specific files
        ForEach ($Item in $This.PsdOldFiles())
        {   
            $Target           = "$Root\Scripts\$Item"

            If ([System.IO.File]::Exists($Target))
            {
                [System.IO.File]::Move($Target,"$Backup\$Item")
            }
        }

        # Cleanup old stuff from DeploymentShare
        ForEach ($Item in Get-ChildItem "$Root\Scripts" | ? Name -match "(vbs|wsf|DeployWiz|UDI|WelcomeWiz_)")
        {
            [System.IO.File]::Move($Item.Fullname,"$Backup\$($Item.Name)")
        }

        # Copy (*.ps1) Files
        ForEach ($Item in Get-ChildItem "$Psd\Scripts" | ? Extension -match "(ps1|xaml)")
        {
            [System.IO.File]::Copy($Item.Fullname,"$Root\Scripts\$($Item.Name)")
        }

        # Copy templates
        ForEach ($Item in Get-ChildItem "$PSD\Templates")
        {
            [System.IO.File]::Copy($Item.Fullname,"$Root\Templates\$($Item.Name)")
        }

        # Copy modules
        ForEach ($Item in $This.PsdModules())
        {
            $Folder = "$Root\Tools\Modules\$Item"
            If (![System.IO.Directory]::Exists($Folder))
            {
                [System.IO.Directory]::CreateDirectory($Folder)
            }

            [System.IO.File]::Copy("$Psd\Scripts\$Item.psm1","$Folder\$($Item.Name)")
        }

        # Copy the PSProvider module files
        $SnapIn = "$Root\Tools\Modules\Microsoft.BDD.PSSnapIn"
        If (![System.IO.Directory]::Exists($SnapIn))
        {
            [System.IO.Directory]::CreateDirectory($SnapIn)
        }

        $xPath = $This.MdtModule.Path | Split-Path
        ForEach ($Item in $This.PsdSnapIn())
        {
            [System.IO.File]::Copy("$xPath\Microsoft.BDD.$Item","$SnapIn\$Item")
        }

        # Copy the provider template files
        If (![System.IO.Directory]::Exists("$Root\Templates"))
        {
            [System.IO.Directory]::CreateDirectory("$Root\Templates")
        }

        $xPath = $xPath | Split-Path

        ForEach ($Item in [System.Enum]::GetNames([MdtServerObjectType]))
        {
            [System.IO.File]::Copy("$xPath\Templates\$Item.xsd","$Root\Templates")
        }

        # Restore ZtiGather.xml
        [System.IO.File]::Copy("$xPath\Templates\Distribution\Scripts\ZtiGather.xml","$Root\Tools\Modules\PsdGather")

        # Create folders
        Foreach ($Item in $This.PsdFolders())
        {
            [System.IO.Directory]::CreateDirectory("$Root\PsdResources\$Item")
        }

        # Copy PSDBackground to Branding folder
        [System.IO.File]::Copy("$Psd\Branding\PSDBackground.bmp","$Root\PsdResources\Branding\PsdBackground.bmp")

        # Copy PSDBGI to BGInfo folder
        [System.IO.File]::Copy("$Psd\Branding\PSD.bgi","$Root\PSDResources\BGInfo\Psd.bgi")

        # Copy BGInfo64.exe to BGInfo.exe
        [System.IO.File]::Copy("$Root\Tools\x64\BGInfo64.exe","$Root\Tools\x64\BGInfo.exe")

        # Copy Prestart items
        ForEach ($Item in Get-ChildItem "$Psd\PsdResources\Prestart")
        {
            [System.IO.File]::Copy($Item.Fullname,"$Root\PsdResources\Prestart\$($Item.Name)")
        }

        # Update the DeploymentShare properties
        [Console]::WriteLine("Update [~] Psd Deployment Share properties")

        ForEach ($Item in 86,64)
        {
            ("Boot.x$Item.LiteTouchIsoName","PsdLiteTouch_x$Item.iso"),
            ("Boot.x$Item.LiteTouchWimDescription","PowerShell Deployment Boot Image (x$Item)"),
            ("Boot.x$Item.BackgroundFile", "%DEPLOYROOT%\PsdResources\Branding\PsdBackground.bmp") | % {

                Set-ItemProperty $Name -Name $_[0] -Value $_[1]
            }
        }

        # Disable support for x86
        Set-ItemProperty $Name -Name SupportX86 -Value False

        # Relax Permissions on Deploymentfolder and DeploymentShare
        ForEach ($Item in $This.PsdAccounts())
        {
            icacls $Root /grant "`"$Item`":(OI)(CI)(RX)" 
        }
            
        Grant-SmbShareAccess -Name $Share -AccountName EVERYONE -AccessRight Change -Force
        Revoke-SmbShareAccess -Name $Share -AccountName "CREATOR OWNER" -Force

        Get-ChildItem $Root -Recurse | Unblock-File -Verbose

        [Console]::WriteLine("Complete [+] PSD modification installed")
    }
    SelectDrive([String]$Drive)
    {
        $This.Selected = $This.Drive | ? Name -eq $Drive
    }
    [Object] GetDrive([String]$Name)
    {
        Return $This.Drive | ? Name -eq $Name
    }
    AddDrive([Object]$Object)
    {
        If ($Object.Name -in $This.Drive.Name)
        {
            Throw "[!] Drive already exists"
        }
        Else
        {
            $This.Drive.Add($This.MdtServerPersistentDrive($Object))
        }
    }
    AddDrive([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
    {
        If ($Name -in $This.Drive.Name)
        {
            Throw "Drive already exists"
        }
        Else
        {
            $This.Drive.Add($This.MdtServerPersistentDrive($Name,$Root,$Share,$Description,$Type))

            [Console]::WriteLine("Added [+] Persistent Drive ($Name)")
        }
    }
    RemoveDrive([String]$Name)
    {
        $Select = $This.GetDrive($Name)
        Restore-MdtPersistentDrive

        If ($Select)
        {
            Remove-Item -Path $Select.Root -Force -Recurse -Confirm:0  -Verbose
            Remove-SmbShare -Name $Select.Share -Force -Confirm:0 -Verbose
            Remove-MdtPersistentDrive -Name $Select.Name -Verbose

            $This.Drive.Remove($Select)

            [Console]::WriteLine("Removed [!] Persistent Drive ($($Select.Name))")
        }
    }
    UpdateDrive([String]$Name,[UInt32]$Mode)
    {
        $Select   = $This.GetDrive($Name)
        Restore-MdtPersistentDrive

        [Console]::WriteLine("Updating [~] Deployment Share [$($Select.Name)]")

        # Share Settings
        ("Comments",$This.GetDriveComment($Select.Type)),
        ("MonitorHost",$This.Server) | % { 

            Set-ItemProperty "$($Select.Name):" -Name $_[0] -Value $_[1] -Verbose
        }

        # DsKey
        $Key      = Import-Csv ($Select.Config | ? Name -eq DsKey | % Path)
        $Branding = "$($Select.Root)\Graphics"

        # Creates branding folder
        If (![System.IO.Directory]::Exists($Branding))
        {
            [System.IO.Directory]::CreateDirectory($Branding)
        }

        # Insert default module background if path is (null/invalid)
        If (![System.IO.File]::Exists($Key.Background))
        {
            [Console]::WriteLine("[!] Background not found, using <default>")
            $Key.Background = $This.Module._Graphic("OEMbg.jpg").Fullname
        }

        # Insert default module logo if path is (null/invalid)
        If (![System.IO.File]::Exists($Key.Logo))
        {
            [Console]::WriteLine("[!] Logo not found, using <default>")
            $Key.Logo       = $This.Module._Graphic("OEMlogo.bmp").Fullname
        }

        $Background         = $Key.Background | Split-Path -Leaf
        $Logo               = $Key.Logo       | Split-Path -Leaf

        # Copy (background + logo) to branding folder
        [System.IO.File]::Copy($Key.Background,"$Branding\$Background")
        [System.IO.File]::Copy($Key.Background,"$Branding\$Logo")

        # Set persistent drive properties
        ForEach ($Property in $This.UpdateDriveProperties($Select.Type,$Background))
        {
            Set-ItemProperty -Path "$($Select.Name):" -Name $Property.Name -Value $Property.Value -Verbose 
        }

        # Pass the command to update deployment share
        Switch ($Mode)
        {
            0 { Update-MdtDeploymentShare -Path "$($Select.Name):"    -Force -Verbose }
            1 { Update-MdtDeploymentShare -Path "$($Select.Name):"           -Verbose }
            2 { Update-MdtDeploymentShare -Path "$($Select.Name):" -Compress -Verbose }
        }

        $Label       = "$($Select.Name):"
        $Property    = Get-ItemProperty -Path $Label
        $BootPath    = "$($Select.Root)\Boot"
        
        # Remove Duplicate (Xml/Wim)
        ForEach ($Arch in "x86","x64")
        {
            ForEach ($File in "wim","xml")
            {
                $Item      = "{0}.{1}" -f $Property."Boot.$Arch.LiteTouchWimDescription", $File
                $ImagePath = "$BootPath/$Item"

                If (Get-Item -LiteralPath $ImagePath -EA 0)
                {
                    Remove-Item -LiteralPath $ImagePath -Verbose
                }

                If (Get-Item -LiteralPath "$BootPath\LiteTouchPE_$Arch.$File" -EA 0)
                {
                    Rename-Item -LiteralPath "$BootPath\LiteTouchPE_$Arch.$File" -NewName $Item
                }
            }
        }

        # Update/Flush FEShare (WDS) <- Should be handled by the [Wds controller]
        ForEach ($Image in $This.MdtServerBootImageMaster("$($Select.Root)\Boot").Images)
        {        
            ForEach ($Item in Get-WdsBootImage -Architecture $Image.Type | ? ImageName -eq $Image.Name)
            {
                [Console]::WriteLine("Detected [!] ($($Item.Name)), removing...")
                $Item | Remove-WdsBootImage -Verbose
            }

            [Console]::WriteLine("Importing [~] ($($Image.Name))")

            Try 
            {
                Import-WdsBootImage -Path $Image.Wim -NewDescription $Image.Name -Verbose
            }
            Catch
            {
                [Console]::WriteLine("Exception [!] ($($Image.Name)) Not enabled")
            }
        }

        Restart-Service -Name WdsServer

        [Console]::WriteLine("Updated [+] Mdt Deployment Share ($($Select.Name))")
    }
    [String] GuidPattern()
    {
        Return (8,4,4,4,12 | % { "[0-9a-f]{$_}" }) -join "-"
    }
    [String] ExtractGuid([String]$Path)
    {
        Return [Regex]::Matches([System.IO.File]::ReadAllLines("$Path\ts.xml"),$This.GuidPattern()).Value[0]
    }
    [String] NewLabel()
    {
        Return (1..99 | % { "FE{0:d3}" -f $_ } | ? { $_ -notin $This.Drive.Name } | Select-Object -First 1)
    }
    [String] GetNetworkPath([String]$Name)
    {
        Return ("\\{0}\{1}" -f $This.Server, $This.GetDrive($Name).Share)
    }
    ImportImages([UInt32]$Mode)
    {
        If (!$This.Selected.Brand)
        {
            Throw "[!] Create a brand first"
        }
        ElseIf (!$This.Selected.Administrator)
        {
            Throw "[!] Enter local administrator username first"
        }
        ElseIf (!$This.Selected.Password)
        {
            Throw "[!] Enter local administrator password"
        }
        ElseIf ($This.Selected.Images.Import.Count -eq 0)
        {
            Throw "[!] Images not yet selected"
        }

        Restore-MdtPersistentDrive

        ForEach ($Image in $This.Selected.Images.Import)
        {
            $Item   = $This.Selected.Images.Current | ? Label -eq $Image.Label

            Switch ([UInt32]!!$Item)
            {
                0
                {
                    $Image.Rank                    = $This.Selected.Images.Current.Count
                    $This.Selected.Images.Current += $Image
                }
                1
                {
                    [Console]::WriteLine("Removing [~] ($($Image.Label))")

                    $Ts = $This.Selected.Select("Task Sequences")    | ? Name -eq $Item.ImageName
                    $Os = $This.Selected.Select("Operating Systems") | ? GUID -eq "{$($This.ExtractGUID($Ts.Node.GetPhysicalSourcePath()))}"
    
                    Remove-Item -Path $Ts.Path -Verbose
                    Remove-Item -Path $Os.Path -Verbose
    
                    $Image.Rank = $Item.Rank
                    $This.Selected.Images.Current[$Item.Rank] = $Image
                }
            }

            $Root       = "$($This.Selected.Name):"
            $Os         = "$Root\Operating Systems"
            $Ts         = "$Root\Task Sequences"

            # [Create folders in the new MDT share]
            ForEach ($Slot in $Os, $Ts)
            {
                If (!(Test-Path "$Slot\$($Image.InstallationType)"))
                {
                    New-Item -Path $Slot -Enable True -Name $Image.InstallationType -Comments $Image.Description -ItemType Folder -Verbose
                }
                If (!(Test-Path "$Slot\$($Image.InstallationType)\$($Image.Version)"))
                {
                    New-Item -Path "$Slot\$($Image.InstallationType)" -Enable True -Name $Image.Version -Comments $Image.Description -ItemType Folder -Verbose
                }
            }
      
            # [Inject the Wim files into the MDT share]
            $OsPath                 = "$Os\$($Image.InstallationType)\$($Image.Version)"
            $OperatingSystem        = @{

                Path                = $OsPath
                SourceFile          = $Image.SourceImagePath
                DestinationFolder   = $Image.Label
            }
            
            Switch ($Mode)
            {
                0 
                { 
                    Import-MdtOperatingSystem @OperatingSystem -Verbose 
                }
                1 
                { 
                    Import-MdtOperatingSystem @OperatingSystem -Move -Verbose
                    Remove-Item -Path ($Image.SourceImagePath | Split-Path) -Verbose -Force
                }
            }

            $TaskSequence           = @{ 
                    
                Path                = "$Ts\$($Image.InstallationType)\$($Image.Version)"
                Name                = $Image.ImageName
                Template            = "{0}{1}Mod.xml" -f $This.Selected.Type, $Image.InstallationType
                Comments            = $Image.ImageDescription
                ID                  = $Image.Label
                Version             = "1.0"
                OperatingSystemPath = Get-ChildItem -Path $OsPath | ? Name -match $Image.Label | % { "{0}\{1}" -f $OsPath, $_.Name }
                FullName            = $This.Selected.Administrator
                OrgName             = $This.Selected.Brand.Manufacturer
                HomePage            = $This.Selected.Brand.SupportURL
                AdminPassword       = $This.Selected.Password
            }

            Import-MdtTaskSequence @TaskSequence -Verbose
        }

        $This.Selected.Images.Import = @( )
        $This.RerankImages()
    }
    RemoveImages([Object[]]$File)
    {
        Restore-MdtPersistentDrive

        Switch ($File.Count)
        {
            {$_ -eq 1}
            {
                $Ts       = $This.Selected.Select("Task Sequences") | ? Name -eq $File.ImageName
                $Guid     = $This.ExtractGUID($Ts.Node.GetPhysicalSourcePath())
                $Os       = $This.Selected.Select("Operating Systems") | ? Guid -eq "{$Guid}"
    
                Remove-Item -Path $Ts.Path -Verbose -Recurse
                Remove-Item -Path $Os.Path -Verbose -Recurse
    
                $This.Selected.Images.Current = @($This.Selected.Images.Current | ? ImageName -ne $File.ImageName)
            }
            {$_ -gt 1}
            {
                $Files    = $File
                ForEach ($File in $Files)
                {
                    $Ts   = $This.Selected.Select("Task Sequences") | ? Name -eq $File.ImageName
                    $Guid = $This.ExtractGuid($Ts.Node.GetPhysicalSourcePath())
                    $Os   = $This.Selected.Select("Operating Systems") | ? Guid -eq "{$Guid}"
    
                    Remove-Item -Path $Ts.Path -Verbose -Recurse
                    Remove-Item -Path $Os.Path -Verbose -Recurse

                    $This.Selected.Images.Current = @($This.Selected.Images.Current | ? ImageName -ne $File.ImageName)
                }
            }
        }

        If ($This.Selected.Images.Current.Count -eq 0)
        {
            $This.Selected.Images.Current = @( )
        }

        $This.RerankImages()
    }
    RerankImages()
    {
        If ($This.Selected.Images.Current.Count -gt 0)
        {
            $X = 0
            Do
            {
                $This.Selected.Images.Current[$X].Rank = $X
                $X ++
            }
            Until ($X -eq $This.Selected.Images.Current.Count)
        }
    }
    [Object] Enumerate([Hashtable]$Object)
    {
        $Output = @( )

        ForEach ($Item in $Object.GetEnumerator())
        {
            Switch ($Item.Value.GetType().Name)
            {
                Hashtable
                {
                    $Output += "[$($Item.Name)]"
                    $Object.$($Item.Name).GetEnumerator() | % { $Output += "$($_.Name)=$($_.Value)" }
                    $Output += ""
                }
                Default
                {
                    $Output += "$($Item.Name)=$($Item.Value)"
                    $Output += ""
                }
            }
        }

        Return ($Output -join "`n")
    }
    [Object] Bootstrap([String]$Type,[String]$NetBIOS,[String]$UNC,[String]$UserID,[String]$Password)
    {
        $Output = $Null

        If ($Type -eq "MDT")
        {
            $Output                = @{

                Settings           = @{

                    Priority       = "Default" 
                }

                Default            = @{

                    DeployRoot     = $UNC
                    UserID         = $UserID.Split("@")[0]
                    UserPassword   = $Password
                    UserDomain     = $NetBIOS
                    SkipBDDWelcome = "YES"
                }
            }
        }

        If ($Type -eq "PSD")
        {
            $Output                = @{

                Settings           = @{

                    Priority       = "Default"
                    Properties     = "PSDDeployRoots"
                }

                Default            = @{

                    PSDDeployRoots = $UNC
                    UserID         = $UserID.Split("@")[0]
                    UserPassword   = $Password
                    UserDomain     = $NetBIOS
                }
            }
        }

        Return $This.Enumerate($Output)
    }
    [Object] CustomSettings([String]$Type,[String]$UNC,[String]$Org,[String]$NetBIOS,[String]$DNS,[String]$Server,[String]$OU,[String]$UserID,[String]$Password)
    {
        Restore-MdtPersistentDrive

        $Output = $Null
        $Port   = Get-ItemProperty -Path "$($This.Drive):" -Name MonitorEventPort | % MonitorEventPort

        If (!$Port)
        {
            $Port = 9800
        }

        If ($Type -eq "MDT")
        {
            $Output                      = @{

                Settings                 = @{

                    Priority             = "Default"
                    Properties           = "MyCustomProperty"
                }

                Default                  = @{

                    _SMSTSOrgName        = $Org
                    JoinDomain           = $NetBIOS
                    DomainAdmin          = $UserID.Split("@")[0]
                    DomainAdminPassword  = $Password
                    DomainAdminDomain    = $NetBIOS
                    MachineObjectOU      = $OU
                    SkipDomainMembership = "YES" 
                    OSInstall            = "Y"
                    SkipCapture          = "NO"
                    SkipAdminPassword    = "YES"
                    SkipProductKey       = "YES"
                    SkipComputerBackup   = "NO"
                    SkipBitlocker        = "YES"
                    KeyboardLocale       = "en-US"
                    TimeZoneName         = $This.GetTimeZoneId()
                    EventService         = ("http://{0}:{1}" -f $Server,$Port)
                    Home_Page            = $This.Selected.Brand.SupportURL
                }
            }
        }

        If ($Type -eq "PSD")
        {
            $Output                      = @{

                Settings                 = @{

                    Priority             = "Default"
                    Properties           = "PSDDeployRoots"
                }

                Default                  = @{

                    _SMSTSOrgName        = $Org
                    JoinDomain           = $NetBIOS
                    DomainAdmin          = $UserID.Split("@")[0]
                    DomainAdminPassword  = $Password
                    DomainAdminDomain    = $NetBIOS
                    MachineObjectOU      = $OU
                    KeyboardLocale       = "en-US"
                    TimeZoneName         = $This.GetTimeZoneId()
                    EventService         = ("http://{0}:{1}" -f $Server,$Port)
                    Home_Page            = $This.Selected.Brand.SupportURL
                }
            }
        }

        Return $This.Enumerate($Output)
    }
    [Object] GetTimeZoneId()
    {
        Return Get-TimeZone | % Id
    }
    [Object] PostConfig([String]$KeyPath)
    {
        Return @('Set-ExecutionPolicy Bypass -Scope Process -Force';
        '[Net.ServicePointManager]::SecurityProtocol = 3072';
        '$Source = Invoke-RestMethod {0}/blob/main/FightingEntropy.ps1?raw=true' -f $This.Module.Source;
        'Invoke-RestMethod $Source.TrimEnd("`n") | Invoke-Expression';
        'New-EnvironmentKey -Path "{0}" | % Apply' -f $KeyPath)
    }
    [Object] MdtServerBrand()
    {
        Return [MdtServerBrand]::New()
    }
    [Object] MdtServerBrand(
    [String]    $Wallpaper ,
    [String]         $Logo ,
    [String] $Manufacturer ,
    [String]        $Phone ,
    [String]        $Hours ,
    [String]          $URL )
    {
        Return [MdtServerBrand]::New($Wallpaper,$Logo,$Manufacturer,$Phone,$Hours,$URL)
    }
    [Object] MdtServerShareKey([String]$Path)
    {
        Return [MdtServerShareKey]::New([String]$Path)
    }
    [Object] MdtServerShareKey([Object]$Object)
    {
        Return [MdtServerShareKey]::New([Object]$Object)
    }
    [Object] MdtServerShareKey(
    [String]  $NetworkPath ,
    [String] $Organization ,
    [String]   $CommonName ,
    [String]   $Background ,
    [String]         $Logo ,
    [String]        $Phone ,
    [String]        $Hours ,
    [String]      $Website )
    {
        Return [MdtServerShareKey]::New($NetworkPath,$Organization,$CommonName,$Background,$Logo,$Phone,$Hours,$Website)
    }
    [Object] MdtServerDomain([String]$Username,[SecureString]$Password,[String]$NetBIOS,[String]$DnsName,[String]$OUName)
    {
        Return [MdtServerDomain]::New($Username,$Password,$NetBIOS,$DnsName,$OUName)
    }
    [Object] MdtServerBootImageMaster([Object]$Directory)
    {
        Return [MdtServerBootImageMaster]::New($Directory)
    }
    [Object] MdtServerPersistentDriveImageMaster()
    {
        Return [MdtServerPersistentDriveImageMaster]::New()
    }
    [Object] MdtServerPersistentDriveConfigMaster([String]$Path)
    {
        Return [MdtServerPersistentDriveConfigMaster]::New($Path)
    }
    [Object] MdtServerPersistentDriveItem([Object]$Object)
    {
        Return [MdtServerPersistentDriveItem]::New($Object)
    }
    [Object] MdtServerPersistentDrive()
    {
        Return [MdtServerPersistentDrive]::New()
    }
    [Object] MdtServerPersistentDrive([Object]$Drive)
    {
        Return [MdtServerPersistentDrive]::New($Drive)
    }
    [Object] MdtServerPersistentDrive([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
    {
        Return [MdtServerPersistentDrive]::New($Name,$Root,$Share,$Description,$Type)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.MdtServer>"
    }
}

# IIS
Class IISServerSiteBinding
{
    [UInt32]    $Index
    [String] $Protocol
    [String]  $Binding
    [String] $SslFlags
    IISServerSiteBinding([UInt32]$Index,[Object]$Bind)
    {
        $This.Index    = $Index
        $This.Protocol = $Bind.Protocol
        $This.Binding  = $Bind.BindingInformation
        $This.SslFlags = $Bind.SslFlags
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IISServer.SiteBinding>"
    }
}

Class IISServerSite
{
    [String]      $Name
    [UInt32]        $Id
    [String]     $State
    [String]      $Path
    [Object]  $Bindings
    [UInt32] $BindCount
    IISServerSite([Object]$Site)
    {
        $This.Name     = $Site.Name
        $This.ID       = $Site.ID
        $This.State    = $Site.State
        $This.Path     = $Site.Applications[0].VirtualDirectories[0].PhysicalPath
        $This.Bindings = @( )

        If ($Site.Bindings.Count -gt 1)
        {
            ForEach ($Binding in $Site.Bindings)
            {
                $This.Bindings += $This.IISServerSiteBinding($This.Bindings.Count,$Binding)
            }
        }
        Else
        {
            $This.Bindings += $This.IISServerSiteBinding(0,$Site.Bindings)
        }

        $This.BindCount = $This.Bindings.Count
    }
    [Object] IISServerSiteBinding([UInt32]$Index,[Object]$Binding)
    {
        Return [IISServerSiteBinding]::New($Index,$Binding)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IISServer.Site>"
    }
}

Class IISServerAppPool
{
    [String]         $Name
    [String]       $Status
    [String]    $AutoStart
    [String]   $CLRVersion
    [String] $PipelineMode
    [String]    $StartMode
    IISServerAppPool([Object]$AppPool)
    {
        $This.Name         = $AppPool.Name
        $This.Status       = $AppPool.State
        $This.AutoStart    = $AppPool.Attributes | ? Name -eq autoStart             | % Value
        $This.CLRVersion   = $AppPool.Attributes | ? Name -eq managedRuntimeVersion | % Value
        $This.PipelineMode = $AppPool.ManagedPipelineMode
        $This.StartMode    = $AppPool.StartMode
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IISServer.AppPool>"
    }
}

Class IISServer
{
    [Object]     $AppDefaults
    [Object] $AppPoolDefaults
    [Object]    $SiteDefaults
    [Object] $VirtualDefaults
    [Object]        $AppPools
    [Object]           $Sites
    IISServer()
    {
        $IIS                  = $This.GetIISServerManager()

        $This.AppDefaults     = $IIS.ApplicationDefaults
        $This.AppPoolDefaults = $IIS.ApplicationPoolDefaults
        $This.AppPools        = $This.Refresh("AppPools",$IIS.ApplicationPools)
        $This.SiteDefaults    = $IIS.SiteDefaults
        $This.Sites           = $This.Refresh("Sites",$IIS.Sites)
    }
    [Object] GetIISServerManager()
    {
        Return Get-IISServerManager
    }
    [Object] IISServerSite([Object]$Site)
    {
        Return [IISServerSite]::New($Site)
    }
    [Object] IISServerAppPool([Object]$AppPool)
    {
        Return [IISServerAppPool]::New($AppPool)
    }
    Refresh([String]$Type,[Object]$Object)
    {
        Switch ($Type)
        {
            AppPools
            {
                $This.AppPools = @( )

                ForEach ($Item in $Object)
                {
                    $This.AppPools += $This.IISServerAppPool($Item)
                }
            }
            Sites
            {
                $This.Sites = @( )

                ForEach ($Item in $Object)
                {
                    $This.Sites += $This.IISServerSite($Item)
                }
            }
        }
    }

    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IISServer>"
    }
}

# Image
Class ImageSlot
{
    [UInt32]           $Index
    [String]            $Type
    [String]         $Version
    [String]            $Name
    [String]     $Description
    [String]            $Size
    [String]            $Arch
    [String] $DestinationName
    [String]           $Label
    [UInt32]        $Selected
    ImageSlot([Object]$Slot)
    {
        $This.Index       = $Slot.ImageIndex
        $This.Name        = $Slot.ImageName -replace "Evaluation", "Eval"
        $This.Description = ($Slot.ImageDescription -Split "\.")[0]
        $This.Size        = "{0:n2} GB" -f (($Slot.ImageSize -Replace "\D")/1gb)  
        $This.Arch        = @("x86","x64")[$Slot.Architecture -eq 9]
        $This.Type        = $Slot.InstallationType
        $This.Version     = $Slot.Version

        Switch -Regex ($This.Type)
        {
            Server
            {
                $Year        = [Regex]::Matches($This.Name,"(\d{4})").Value
                $Edition     = $This.Name -Split " " | ? { $_ -match "(Standard|Datacenter)" }
    
                Switch ([UInt32]($This.Name -match "\(Desktop Experience\)"))
                {
                    0
                    {
                        $Edition = "$Edition Core"
                    }
                    1
                    {
                        $This.Name = $This.Name -Replace " \(Desktop Experience\)"
                    }
                }

                $Tag         = Switch -Regex ($Edition) 
                {
                    "^Standard Core$"   { "SDX" }
                    "^Standard$"        { "SD"  }
                    "^Datacenter Core$" { "DCX" }
                    "^Datacenter$"      { "DC"  }
                }

                $This.DestinationName = "Windows Server $Year $Edition (x64)"
                $This.Label           = "{0}{1}-{2}-{3}" -f $Tag, $Year, $This.Arch,$This.Version
            }

            Default
            {
                $X                    = [Regex]::Matches($This.Name,"\d{2}").Value
                $ID                   = $This.Name -Replace "Windows (10|11) "
                $Tag                  = Switch -Regex ($ID)
                {
                    "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                    "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                    "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                    "^Pro N$"            { "PRO_N"      } "^Pro Education$"     { "PRO_EDUC" }
                    "^Pro Education N$"  { "PRO_EDUC_N" } "^Pro for Work.+$"    { "PRO_WS"   }
                    "^Pro N for Work.+$" { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                }

                $This.DestinationName = "{0} ({1})" -f $This.Name, $This.Arch
                $This.Label           = "{0}{1}-{2}-{3}" -f $X, $Tag, $This.Arch, $This.Version
            }
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.ImageSlot>"
    }
}

Class ImageFile
{
    [UInt32]           $Index
    [String]            $Type = "-"
    [String]            $Name
    [String]        $Fullname
    Hidden [UInt32] $Attached
    Hidden [String]   $Letter
    [Object]         $Content
    ImageFile([UInt32]$Index,[String]$Fullname)
    {
        $This.Index     = $Index
        $This.Name      = $Fullname | Split-Path -Leaf
        $This.Fullname  = $Fullname
        $This.Clear()
    }
    Clear()
    {
        $This.Content   = @( )
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.ImageFile>"
    }
}

Class ImageController
{
    [String]   $Source
    [String]   $Target
    [Int32]  $Selected
    [Object]   $Output
    ImageController()
    {
        $This.Clear()
    }
    Clear()
    {
        $This.Selected = -1
        $This.Output = @( )
    }
    Select([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            [Console]::WriteLine("[!] Invalid index")
        }
        Else
        {
            $This.Selected = $Index
        }
    }
    [Object] Current()
    {
        Return $This.Output[$This.Selected]
    }
    SetSource([String]$Source)
    {
        If (![System.IO.Directory]::Exists($Source))
        {
            [Console]::WriteLine("[!] Invalid source path")
        }
        ElseIf ((Get-ChildItem $Source *.iso).Count -eq 0)
        {
            [Console]::WriteLine("No (*.iso) files found")
        }
        Else
        {
            $This.Source = $Source
            $This.Output = @( )
    
            ForEach ($Item in Get-ChildItem $This.Source *.iso)
            {
                $This.Output += $This.ImageFile($This.Output.Count,$Item.FullName)
            }
        }
    }
    SetTarget([String]$Target)
    {
        If (![System.IO.Directory]::Exists(($Target | Split-Path)))
        {
            [Console]::WriteLine("[!] Parent path does not exist")
        }
        ElseIf ([System.IO.Directory]::Exists($Target))
        {
            [Console]::WriteLine("[!] Target path already exists")
        }
        Else
        {
            $This.Target = $Target
        }
    }
    [Object] ImageSlot([Object]$Slot)
    {
        Return [ImageSlot]::New($Slot)
    }
    [Object] ImageFile([UInt32]$Index,[String]$Fullname)
    {
        Return [ImageFile]::New($Index,$Fullname)
    }
    GetDiskImage()
    {
        $ImageFile          = $This.Current()

        $Image              = Get-DiskImage -ImagePath $ImageFile.Fullname
        $ImageFile.Attached = $Image.Attached
        $ImageFile.Letter   = @($Null;$Image | Get-Volume | % DriveLetter)[$Image.Attached]

        If ($Image.Attached)
        {
            $Install        = Get-ChildItem "$($ImageFile.Letter):" -Recurse | ? Name -match "(install\.(wim|esd))"
            $ImageFile.Type = Switch ($Install.Count)
            {
                0 { "Non-Windows" } Default { "Windows" }
            }
        }
    }
    MountDiskImage()
    {
        $ImageFile          = $This.Current()

        If (!$ImageFile.Attached)
        {
            [Console]::WriteLine("Mounting [~] $($ImageFile.Name)")
            Mount-DiskImage -ImagePath $ImageFile.Fullname
            $This.GetDiskImage()
        }
    }
    DismountDiskImage()
    {
        $ImageFile          = $This.Current()

        If ($ImageFile.Attached)
        {
            [Console]::WriteLine("Dismounting [~] $($ImageFile.Name)")
            Dismount-DiskImage -ImagePath $ImageFile.FullName
            $This.GetDiskImage()
        }
    }
    GetWindowsImage()
    {
        $ImageFile          = $This.Current()

        If ($ImageFile.Attached -and $ImageFile.Type -eq "Windows")
        {
            [Console]::WriteLine("Getting [~] Windows Image(s)")
            $Install        = Get-ChildItem "$($ImageFile.Letter):" -Recurse | ? Name -match "(install\.(wim|esd))"

            If ($Install.Count -gt 1)
            {
                $Install = $Install | ? Fullname -match x64
            }

            $ImageFile.Content = @( )
            $X                 = 1
            Do
            {
                Try
                {
                    $Item               = Get-WindowsImage -ImagePath $Install.Fullname -Index $X
                    $ImageFile.Content += $This.ImageSlot($Item)
                    $X ++
                }
                Catch
                {
                    $X = 0
                }
            }
            Until ($X -eq 0)
        }
    }
    Extract()
    {
        If (!$This.Target)
        {
            Throw "[!] Must set target path"
        }

        [Console]::WriteLine("Extracting [~] Windows Image(s)")

        $X        = 0
        ForEach ($Item in $This.Output)
        {
            $This.Select($Item.Index)
            $List = $Item.Content | ? Selected
            If ($List.Count -gt 0)
            {
                $This.GetDiskImage()
                If (!$This.Current().Attached)
                {
                    $This.MountDiskImage()
                }
        
                $Install = Get-ChildItem "$($This.Current().Letter):" -Recurse | ? Name -match "(install\.(wim|esd))"
            
                ForEach ($File in $List)
                {
                    $Iso                     = @{
        
                        SourceIndex          = $File.Index
                        SourceImagePath      = @($Install;$Install | ? Fullname -match $File.Arch)[$Install.Count -gt 1].Fullname
                        DestinationImagePath = "{0}\({1}){2}\{2}.wim" -f $This.Target, $X, $File.Label
                        DestinationName      = $File.DestinationName
                    }
        
                    [System.IO.Directory]::CreateDirectory(($Iso.DestinationImagePath | Split-Path))
        
                    Export-WindowsImage @Iso
        
                    [Console]::WriteLine("Extracted [~] $($File.DestinationName)")
        
                    $X ++
                }

                $This.DismountDiskImage()
            }
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.ImageController>"
    }
}

# Config

Import-Module ActiveDirectory, WebAdministration, Hyper-V

Class Config
{
    [Object]   $Module
    [Object]   $System
    [Object]  $Feature
    [Object] $IPConfig
    [Object]     $Dhcp
    [Object]      $Dns
    [Object]     $Adds
    [Object]   $HyperV
    [Object]      $Wds
    [Object]      $IIS
    [Object]      $Mdt
    [Object]    $Image
    Config([Object]$Module)
    {
        $This.Module   = $Module

        $This.Update(0,"[~] System")
        $This.System   = $This.GetFESystem()

        $This.Update(0,"[~] Windows Features")
        $This.Feature  = $This.WindowsFeatureMaster()

        $This.Update(0,"[~] IP Configuration(s)")
        $This.IPConfig = $This.IpConfigurationMaster()

        $This.Load("DhcpServer")
        $This.Load("DnsServer")
        $This.Load("AddsDomain")
        $This.Load("VmController")
        $This.Load("WdsServer")
        $This.Load("IISServer")
        $This.Load("MdtServer")

        $This.Image = $This.ImageController()
    }
    Load([String]$Slot)
    {
        Switch ($Slot)
        {
            DhcpServer
            {
                Switch ($This.Feature.Get("Dhcp").Value)
                {
                    0 { $This.Update(0,"[!] Dhcp") }
                    1 { $This.Dhcp = $This.DhcpServer()
                        $This.Update(1,"[+] Dhcp") }
                }
            }
            DnsServer
            {
                Switch ($This.Feature.Get("Dns").Value)
                {
                    0 { $This.Update(0,"[!] Dns") }
                    1 { $This.Dns =  $This.DnsServer()
                        $This.Update(1,"[+] Dns") }
                }
            }
            AddsDomain
            {
                Switch ($This.Feature.Get("AD-Domain-Services").Value)
                {
                    0 { $This.Update(0,"[!] Adds") }
                    1 { $This.Adds = $This.AddsDomain() 
                        $This.Update(1,"[+] Adds") }
                }        
            }
            VmController
            {
                Switch ($This.Feature.Get("Hyper-V").Value)
                {
                    0 { $This.Update(0,"[!] Veridian") }
                    1 { $This.HyperV = $This.VmControl()
                        $This.Update(1,"[+] Veridian") }
                }
            }
            WdsServer
            {
                Switch ($This.Feature.Get("Wds").Value)
                {
                    0 { $This.Update(0,"[!] Wds") }
                    1 { $This.Wds = $This.WdsServer()
                        $This.Update(1,"[+] Wds") }
                }
            }
            IISServer
            {
                Switch ($This.Feature.Get("Web-WebServer").Value)
                {
                    0 { $This.Update(0,"[!] IIS") }
                    1 { $This.IIS = $This.IISServer()
                        $This.Update(1,"[+] IIS") }
                }
            }
            MdtServer
            {
                Switch ($This.Feature.Get("Mdt").Value)
                {
                    0 { $This.Update(0,"[!] Mdt/WinPE/WinAdk") }
                    1 { $This.Mdt = $This.MdtServer($This.Module)
                        $This.Update(1,"[+] Mdt/WinPE/WinAdk") }
                }
            }
        }
    }
    Update([Int32]$State,[String]$Status)
    {
        $This.Module.Update($State,$Status)
        If ($This.Module.Mode -gt 0)
        {
            [Console]::WriteLine($This.Module.Console.Status)
        }
    }
    [Object] GetFESystem()
    {
        $Output = Get-FESystem -Mode 0 -Level 2

        Return $This.SystemPanel($Output)
    }
    [Object] SystemPanel([Object]$System)
    {
        Return [SystemPanel]::New($System)
    }
    [Object] WindowsFeatureMaster()
    {
        Return [WindowsFeatureMaster]::New()
    }
    [Object] IpConfigurationMaster()
    {
        Return [IpConfigurationMaster]::New()
    }
    [Object] DhcpServer()
    {
        Return [DhcpServer]::New()
    }
    [Object] DnsServer()
    {
        Return [DnsServer]::New()
    }
    [Object] AddsDomain()
    {
        Return [AddsDomain]::New()
    }
    [Object] VmControl()
    {
        Return [VmControl]::New()
    }
    [Object] WdsServer()
    {
        Return [WdsServer]::New()
    }
    [Object] MdtServer([Object]$Module)
    {
        Return [MdtServer]::New($Module)
    }
    [Object] IISServer()
    {
        Return [IISServer]::New()
    }
    [Object] ImageController()
    {
        Return [ImageController]::New()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config>"
    }
}

$Module = Get-FEModule -Mode 1
$Config = [Config]::New($Module)

<#
$Password = Read-Host -AsSecureString "Password"
$Target   = "l420-x64.securedigitsplus.com"
$Account  = "l420-x64\mcadmin"
#>

$Config.HyperV = $Config.VmControl()

If (!$Target -or !$Account -or !$Password)
{
    Throw "[!] Assign commented variable(s)"
}

$Config.HyperV.SetTargetName($Target)
$Config.HyperV.SetCredential($Account,$Password)
$Config.HyperV.Connect()
$Config.HyperV.Populate()

# $Config.Dispose()

$Path = "C:\Images"
$Config.Image.SetSource($Path)
ForEach ($Item in $Config.Image.Output)
{
    $Config.Image.Select($Item.Index)
    $Config.Image.MountDiskImage()
    $Config.Image.GetWindowsImage()
    $Config.Image.DismountDiskImage()
}

<# Shows all of the (*.wim) files
$Config.Image.Output.Content | Select Type, Version, Name, Size, Arch, DestinationName, Label | FT

Type        Version         Name                                Size     Arch DestinationName                           Label
----        -------         ----                                ----     ---- ---------------                           -----
Server Core 10.0.20348.587  Windows Server 2022 Standard Eval   7.78 GB  x64  Windows Server 2022 Standard Core (x64)   SDX2022-x64-10.0.20348.587     
Server      10.0.20348.587  Windows Server 2022 Standard Eval   13.40 GB x64  Windows Server 2022 Standard (x64)        SD2022-x64-10.0.20348.587      
Server Core 10.0.20348.587  Windows Server 2022 Datacenter Eval 7.78 GB  x64  Windows Server 2022 Datacenter Core (x64) DCX2022-x64-10.0.20348.587
Server      10.0.20348.587  Windows Server 2022 Datacenter Eval 13.40 GB x64  Windows Server 2022 Datacenter (x64)      DC2022-x64-10.0.20348.587
Client      10.0.22621.525  Windows 11 Home                     15.06 GB x64  Windows 11 Home (x64)                     11HOME-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Home N                   14.44 GB x64  Windows 11 Home N (x64)                   11HOME_N-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Home Single Language     15.04 GB x64  Windows 11 Home Single Language (x64)     11HOME_SL-x64-10.0.22621.525   
Client      10.0.22621.525  Windows 11 Education                15.33 GB x64  Windows 11 Education (x64)                11EDUC-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Education N              14.72 GB x64  Windows 11 Education N (x64)              11EDUC_N-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Pro                      15.35 GB x64  Windows 11 Pro (x64)                      11PRO-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Pro N                    14.72 GB x64  Windows 11 Pro N (x64)                    11PRO_N-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Pro Education            15.33 GB x64  Windows 11 Pro Education (x64)            11PRO_EDUC-x64-10.0.22621.525  
Client      10.0.22621.525  Windows 11 Pro Education N          14.72 GB x64  Windows 11 Pro Education N (x64)          11PRO_EDUC_N-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Pro for Workstations     15.33 GB x64  Windows 11 Pro for Workstations (x64)     11PRO_WS-x64-10.0.22621.525
Client      10.0.22621.525  Windows 11 Pro N for Workstations   14.72 GB x64  Windows 11 Pro N for Workstations (x64)   11PRO_N_WS-x64-10.0.22621.525
Client      10.0.19041.2006 Windows 10 Home                     14.06 GB x64  Windows 10 Home (x64)                     10HOME-x64-10.0.19041.2006     
Client      10.0.19041.2006 Windows 10 Home N                   13.34 GB x64  Windows 10 Home N (x64)                   10HOME_N-x64-10.0.19041.2006
Client      10.0.19041.2006 Windows 10 Home Single Language     14.06 GB x64  Windows 10 Home Single Language (x64)     10HOME_SL-x64-10.0.19041.2006
Client      10.0.19041.2006 Windows 10 Education                14.38 GB x64  Windows 10 Education (x64)                10EDUC-x64-10.0.19041.2006     
Client      10.0.19041.2006 Windows 10 Education N              13.67 GB x64  Windows 10 Education N (x64)              10EDUC_N-x64-10.0.19041.2006
Client      10.0.19041.2006 Windows 10 Pro                      14.38 GB x64  Windows 10 Pro (x64)                      10PRO-x64-10.0.19041.2006
Client      10.0.19041.2006 Windows 10 Pro N                    13.67 GB x64  Windows 10 Pro N (x64)                    10PRO_N-x64-10.0.19041.2006    
Server Core 10.0.14393.0    Windows Server 2016 Standard Eval   8.60 GB  x64  Windows Server 2016 Standard Core (x64)   SDX2016-x64-10.0.14393.0
Server      10.0.14393.0    Windows Server 2016 Standard Eval   14.25 GB x64  Windows Server 2016 Standard (x64)        SD2016-x64-10.0.14393.0        
Server Core 10.0.14393.0    Windows Server 2016 Datacenter Eval 8.60 GB  x64  Windows Server 2016 Datacenter Core (x64) DCX2016-x64-10.0.14393.0
Server      10.0.14393.0    Windows Server 2016 Datacenter Eval 14.26 GB x64  Windows Server 2016 Datacenter (x64)      DC2016-x64-10.0.14393.0     
#>

# Now, select all of the desired images for the extraction queue [Windows (10/11) Pro + Windows Server 2022 Datacenter]
$Config.Image.Output[0].Content[3].Selected = 1
$Config.Image.Output[1].Content[5].Selected = 1
$Config.Image.Output[2].Content[5].Selected = 1

# Set target path + extract (*.wim) files(s)
$Config.Image.SetTarget("C:\Wim")
$Config.Image.Extract()
#>

Class SiteMapState
{
    Static [Hashtable] $List            = @{

        "Alabama"                       = "AL" ; "Alaska"                        = "AK" ;
        "Arizona"                       = "AZ" ; "Arkansas"                      = "AR" ;
        "California"                    = "CA" ; "Colorado"                      = "CO" ;
        "Connecticut"                   = "CT" ; "Delaware"                      = "DE" ;
        "Florida"                       = "FL" ; "Georgia"                       = "GA" ;
        "Hawaii"                        = "HI" ; "Idaho"                         = "ID" ;
        "Illinois"                      = "IL" ; "Indiana"                       = "IN" ;
        "Iowa"                          = "IA" ; "Kansas"                        = "KS" ;
        "Kentucky"                      = "KY" ; "Louisiana"                     = "LA" ;
        "Maine"                         = "ME" ; "Maryland"                      = "MD" ;
        "Massachusetts"                 = "MA" ; "Michigan"                      = "MI" ;
        "Minnesota"                     = "MN" ; "Mississippi"                   = "MS" ;
        "Missouri"                      = "MO" ; "Montana"                       = "MT" ;
        "Nebraska"                      = "NE" ; "Nevada"                        = "NV" ;
        "New Hampshire"                 = "NH" ; "New Jersey"                    = "NJ" ;
        "New Mexico"                    = "NM" ; "New York"                      = "NY" ;
        "North Carolina"                = "NC" ; "North Dakota"                  = "ND" ;
        "Ohio"                          = "OH" ; "Oklahoma"                      = "OK" ;
        "Oregon"                        = "OR" ; "Pennsylvania"                  = "PA" ;
        "Rhode Island"                  = "RI" ; "South Carolina"                = "SC" ;
        "South Dakota"                  = "SD" ; "Tennessee"                     = "TN" ;
        "Texas"                         = "TX" ; "Utah"                          = "UT" ;
        "Vermont"                       = "VT" ; "Virginia"                      = "VA" ;
        "Washington"                    = "WA" ; "West Virginia"                 = "WV" ;
        "Wisconsin"                     = "WI" ; "Wyoming"                       = "WY" ;
        "American Samoa"                = "AS" ; "District of Columbia"          = "DC" ;
        "Guam"                          = "GU" ; "Marshall Islands"              = "MH" ;
        "Northern Mariana Island"       = "MP" ; "Puerto Rico"                   = "PR" ;
        "Virgin Islands"                = "VI" ; "Armed Forces Africa"           = "AE" ;
        "Armed Forces Americas"         = "AA" ; "Armed Forces Canada"           = "AE" ;
        "Armed Forces Europe"           = "AE" ; "Armed Forces Middle East"      = "AE" ;
        "Armed Forces Pacific"          = "AP" ;
    }
    Static [String] GetName([String]$Code)
    {
        Return @([SiteMapState]::List | % GetEnumerator | ? Value -match $Code | % Name)
    }
    Static [String] GetCode([String]$Name)
    {
        Return @([SiteMapState]::List | % GetEnumerator | ? Name -eq $Name | % Value)
    }
    SiteMapState()
    {

    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.State>"
    }
}

Class SiteMapZipEntry
{
    [String]     $Zip
    [String]    $Type
    [String]    $Name
    [String]   $State
    [String] $Country
    [String]    $Long
    [String]     $Lat
    SiteMapZipEntry([Object]$Object)
    {
        If ($Object -match "^\d{5}$")
        {
            $This.Zip       = $Object
            $This.Type      = "Invalid"
            $This.Name      = "N/A"
            $This.State     = "N/A"
            $This.Country   = "N/A"
            $This.Long      = "N/A"
            $This.Lat       = "N/A"
        }
        Else
        {
            $String         = $Object -Split "`t"
        
            $This.Zip       = $String[0]
            $This.Type      = @("UNIQUE","STANDARD","PO_BOX","MILITARY")[$String[1]]
            $This.Name      = $String[2]
            $This.State     = $String[3]
            $This.Country   = $String[4]
            $This.Long      = $String[5]
            $This.Lat       = $String[6]
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.ZipEntry>"
    }
}

Class SiteMapZipMaster
{
    [String]    $Path
    [Object] $Content
    [Object]  $Output
    SiteMapZipMaster([String]$Path)
    {
        $This.Path    = $Path
        $This.Content = [System.IO.File]::ReadAllLines($Path) | ? Length -gt 0
        $This.Output  = @{ }

        ForEach ($Item in $This.Content)
        {
            $This.Output.Add($Item.Substring(0,5),$This.Output.Count)
        }
    }
    [Object] SiteMapZipEntry([String]$Line)
    {
        Return [SiteMapZipEntry]::New($Line)
    }
    [Object] SiteMapZipEntry([UInt32]$Zip)
    {
        Return [SiteMapZipEntry]::New($Zip)
    }
    [Object] Zip([Object]$Zip)
    {
        $Index = $This.Output["$Zip"]

        If (!$Index)
        {
            Return $This.SiteMapZipEntry($Zip)
        }
        Else
        {
            Return $This.SiteMapZipEntry($This.Content[$Index])
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.ZipMaster>"
    }
}

Class SiteMapLocation
{
    [String]  $Organization
    [String]    $CommonName
    Hidden [String]   $Type
    [String]      $Location
    [String]        $Region
    [String]       $Country
    [Int32]         $Postal
    [String]      $SiteLink
    [String]      $SiteName
    Hidden [Object] $SiteDN
    SiteMapLocation([String]$Organization,[String]$CommonName,[Object]$Zip)
    {
        $This.Organization     = $Organization
        $This.CommonName       = $CommonName
        $This.Type             = $Zip.Type
        $This.Location         = $Zip.Name
        $This.Country          = $Zip.Country
        $This.Postal           = $Zip.Zip

        If ($Zip.Type -ne "Invalid")
        {
            $This.Region           = $Zip.State
            $This.GetSiteLink()
            $This.Region           = $This.GetStateNameByCode($Zip.State)
        }
        If ($Zip.Type -eq "Invalid")
        {
            $This.Region           = "N/A"
            $This.SiteName         = "-"
            $This.Sitelink         = "-"
        }
    }
    [Object] GetStateNameByCode([String]$Code)
    {
        Return [SiteMapState]::GetName($Code)
    }
    [Object] GetStateCodeByName([String]$Name)
    {
        Return [SiteMapState]::GetCode($Name)
    }
    GetSiteLink()
    {
        $Return                = @{ }

        # City
        $Return.Add(0,@(Switch -Regex ($This.Location)
        {
            "\s"
            {
                ( $This.Location | % Split " " | % { $_[0] } ) -join ''
            }
            Default
            {
                $This.Location[0,1] -join ''
            }

        }).ToUpper())

        # State
        $Return.Add(1,$This.Region)

        # Country
        $Return.Add(2,$This.Country)

        # Zip
        $Return.Add(3,$This.Postal)

        $This.SiteLink = ($Return[0..3] -join "-").ToUpper()
        $This.SiteName = ("{0}.{1}" -f ($Return[0..3] -join "-"),$This.CommonName).ToLower()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.Location>"
    }
}

Class SiteMapTopology
{
    [UInt32]             $Index
    [String]              $Name
    [String]          $SiteName
    [UInt32]            $Exists
    [Object] $DistinguishedName
    SiteMapTopology([UInt32]$Index,[Object]$Site,[String]$Base)
    {
        $This.Index             = $Index
        $This.Name              = $Site.Sitelink
        $This.DistinguishedName = "CN=$($Site.SiteLink),$Base"
        $This.Sitename          = $Site.Sitename
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.Topology>"
    }
}

Class SiteMapMaster
{
    [String] $Organization
    [String]   $CommonName
    [Object]       $Postal
    [Object]    $Aggregate
    [Object]     $Topology
    SiteMapMaster([String]$Path)
    {
        $This.Postal    = $This.SiteMapZipMaster($Path)
        $This.Aggregate = @( )
        $This.Topology  = @( )
    }
    [Object] SiteMapZipMaster([String]$Path)
    {
        Return [SiteMapZipMaster]::New($Path)
    }
    [Object] SiteMapLocation([UInt32]$ZipCode)
    {
        Return [SiteMapLocation]::New($This.Organization,$This.CommonName,$This.Postal.Zip($ZipCode))
    }
    [Object] SiteMapTopology([UInt32]$Index,[Object]$Site,[String]$Base)
    {
        Return [SiteMapTopology]::New($Index,$Site,$Base)
    }
    [Object] GetExternalIP()
    {
        Return Invoke-RestMethod http://ifconfig.me/ip
    }
    [Object] GetLocation()
    {
        Return Invoke-RestMethod http://ipinfo.io/$($This.GetExternalIP())
    }
    SetDomain([String]$Organization,[String]$CommonName)
    {
        $This.Organization = $Organization
        $This.CommonName   = $CommonName
    }
    AddSite([UInt32]$Postal)
    {
        If (!$This.Organization -or !$This.CommonName)
        {
            Throw '[!] Must set the domain via $This.SetDomain($Org,$CN)'
        }
        ElseIf ($Postal -in $This.Aggregate.Postal)
        {
            Throw '[!] Location is already designated'
        }
        Else
        {
            $This.Aggregate += $This.SiteMapLocation($Postal)
        }
    }
    RemoveSite([UInt32]$Postal)
    {
        If ($Postal -notin $This.Aggregate.Postal)
        {
            Throw '[!] Invalid location designated'
        }
        Else
        {
            $This.Aggregate  = @($This.Aggregate | ? Postal -ne $Postal)
        }
    }
    [String] SearchBase()
    {
        Return "CN=Sites,CN=Configuration,{0}" -f (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
    }
    GetSiteMap()
    {
        $This.Topology      = @( )
        $List               = Get-ADObject -LDAPFilter "(ObjectClass=Site)" -SearchBase $This.SearchBase()

        ForEach ($Site in $This.Aggregate)
        {
            $Item           = $This.SiteMapTopology($This.Topology.Count,$Site,$This.SearchBase())
            $Item.Exists    = @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
            $Site.SiteDN    = $Item
            $This.Topology += $Item
        }
    }
    NewSiteMap()
    {
        ForEach ($Site in $This.Topology)
        {
            $Location = $This.Aggregate | ? Sitelink -match $Site.Name | % { "{0}, {1} {2}" -f $_.Location, $_.Region, $_.Postal }
            Switch ($Site.Exists)
            {
                0
                {
                    New-ADReplicationSite -Name $Site.Name -Description $Site.Sitename -OtherAttributes @{ Location = $Location } -Verbose
                    $Site.Exists = 1
                }
                1
                {
                    [Console]::WriteLine("Item [+] Exists [$($Site.DistinguishedName)]")
                }
            }
        }
    }
    DeleteSiteMap()
    {
        ForEach ($Site in $This.Topology)
        {
            Switch ($Site.Exists)
            {
                0
                {
                    [Console]::WriteLine("Item [!] Does not exist [$($Site.DistinguishedName)]")
                }
                1
                {
                    Try
                    {
                        Remove-ADObject -Identity $Site.DistinguishedName -Verbose -Confirm:0 -Recursive
                        $Site.Exists = 0
                    }
                    Catch
                    {
                        [Console]::WriteLine("[!] The DSA object cannot be deleted")
                    }
                }
            }
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.SiteMap.Master>"
    }
}

$Path    = $Module._Control("zipcode.txt").Fullname
$SiteMap = [SiteMapMaster]::New($Path)
