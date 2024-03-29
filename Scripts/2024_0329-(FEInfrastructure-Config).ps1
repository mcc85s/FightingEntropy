Import-Module ActiveDirectory

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
        [Console]::WriteLine("Getting [~] NetIpConfiguration(s)")

        $This.Output = @( )

        $xConfigurations = $This.GetNetIPConfiguration()

        ForEach ($Configuration in $xConfigurations)
        {
            $This.Output += $This.IpConfigurationItem($Configuration)
        }

        [Console]::WriteLine("Complete [+] NetIpConfiguration(s)")
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config.IpConfiguration.Master>"
    }
}

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
    [Object] $Scope
    DhcpServer()
    {
        $This.Refresh()
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
}

# Veridian
Class VmNodeByteSize
{
    [String]   $Name
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    VmNodeByteSize([String]$Name,[UInt64]$Bytes)
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
    [Object] VmNodeByteSize([String]$Name,[UInt64]$Bytes)
    {
        Return [VmNodeByteSize]::New($Name,$Bytes)
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
        Return [VmNodeByteSize]::New($Name,$Bytes)
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
        Return "<FEInfrastructure.Control.VmControl>"
    }
}

# WDS
Class WdsServer
{
    [String]      $Server
    [Object]     $Service
    [Object[]] $IpAddress
    WdsServer()
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
    SetServer([String]$Server)
    {
        $This.Server  = $Server
    }
    SetService()
    {
        $This.Service = Get-Service -Name WDSServer -EA 0
    }
    StartService()
    {
        If ($This.Service.Status -ne "Running")
        {
            [Console]::WriteLine("Starting [~] Wds Server")

            Set-Service -Name WDSServer -Status Running -EA 0
        }

        $This.SetService()
    }
    StopService()
    {
        If ($This.Service.Status -eq "Running")
        {
            [Console]::WriteLine("Stopping [~] Wds Server")

            Set-Service -Name WDSServer -Status Stopped -EA 0
        }
    }
    SetIpAddress([String[]]$IpAddress)
    {
        $This.IpAddress = $IpAddress
    }

    [String] ToString()
    {
        Return "<FEInfrstructure.Config.WdsServer>"
    }
}

# Config
$IpConfig = [IpConfigurationMaster]::New()
$Dhcp     = [DhcpServer]::New()
$Dns      = [DnsServer]::New()
$Adds     = [AddsDomain]::New()
$HyperV   = [VmControl]::New()
$Wds      = [WdsServer]::New()
