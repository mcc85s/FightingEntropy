<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2024-01-05 14:03:22                                                                  //
 \\==================================================================================================// 

    FileName   : 
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For implementing various [controls] and [persistence] in [deployed virtual machines].
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-05-05
    Modified   : 2024-01-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Initialize-VmNode
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][String]     $Index,
    [Parameter(Mandatory)][String]      $Name,
    [Parameter(Mandatory)][String] $IpAddress,
    [Parameter(Mandatory)][String]    $Domain,
    [Parameter(Mandatory)][String]   $NetBios,
    [Parameter(Mandatory)][String]   $Trusted,
    [Parameter(Mandatory)][UInt32]    $Prefix,
    [Parameter(Mandatory)][String]   $Netmask,
    [Parameter(Mandatory)][String]   $Gateway,
    [Parameter(Mandatory)][String[]]     $Dns,
    [Parameter(Mandatory)][UInt32]  $Transmit)

    Class SocketTcpMessage
    {
        [UInt32]   $Index
        [Byte[]]    $Byte
        [UInt32]  $Length
        [String] $Message
        SocketTcpMessage([UInt32]$Index,[Byte[]]$Byte)
        {
            $This.Index        = $Index
            $This.Byte         = $Byte
            $This.Length       = $Byte.Length
            $This.Message      = $This.GetString()
        }
        [String] GetString()
        {
            Return [System.Text.Encoding]::UTF8.GetString($This.Byte,0,$This.Length)
        }
        [Byte[]] GetBytes()
        {
            Return [System.Text.Encoding]::UTF8.GetBytes($This.Message)
        }
    }

    Class SocketTcpServer
    {
        [Object]  $Server
        [Object]  $Client
        [Object]  $Stream
        [String]  $Source
        [UInt32]    $Port
        [UInt32]    $Mode
        [Object]   $Total
        [Object] $Content
        SocketTcpServer([String]$IPAddress,[UInt32]$Port)
        {
            $This.Server    = $Null
            $This.Source    = $IPAddress
            $This.Port      = $Port
            $This.Content   = @( )
        }
        SetServer()
        {
            $This.Server    = $This.TcpListener($This.Source,$This.Port)
        }
        Start()
        {
            $This.Server.Start()
        }
        Stop()
        {
            $This.Server.Stop()
        }
        Initialize()
        {
            # // TcpListener
            $This.SetServer()
    
            # // Starts listening for clients
            $This.Start()
    
            Try
            {
                $This.Write("Waiting for a connection... ")
    
                # // Perform a blocking call to accept requests
                $This.Client  = $This.Server.AcceptTcpClient()
    
                # // Show connection to remote IP endpoint
                $Ip           = $This.RemoteIp()
                $This.Write("Connected [$IP]")
    
                # // Get a stream object for (reading + writing)
                $This.Stream  = $This.Client.GetStream()

                # // Read initial message stream
                $This.Total   = $This.Rx(0)

                # // Write initial message stream
                $This.Tx($This.Total)

                # // Assign total to integer
                $Max          = [UInt32]$This.Total.Message

                Switch ($Max)
                {
                    {$_ -eq 1}
                    {
                        # // Read continuation
                        $Message       = $This.Rx(0)
                        $This.Content += $Message

                        # // Transmit Content
                        $This.Tx($Message)
                    }
                    {$_ -gt 1}
                    {
                        # // Loop through all content
                        ForEach ($X in 0..($Max-1))
                        {
                            # // Read continuation
                            $Message       = $This.Rx($X)
                            $This.Content += $Message

                            # // Transmit Content
                            $This.Tx($Message)
                        }
                    }
                }
            }
            Catch
            {
                $This.Write("Socket Exception")
                $This.Finalize()
            }
            Finally
            {
                $This.Finalize()
            }
        }
        Tx([Object]$Message)
        {
            # // Set the mode to 1
            $This.Mode = 1

            # // Write send message stream
            $This.Stream.Write($Message.Byte,0,$Message.Length)
        }
        [Object] Rx([UInt32]$Index)
        {
            # // Set the mode to 0
            $This.Mode = 0

            # // Write receive message stream
            $Array      = @( )
            Do
            {
                $Array += $This.Stream.ReadByte()
            }
            Until ($Array[-1] -eq 10)

            Return $This.TcpMessage($Index,$Array)
        }
        Finalize()
        {
            # // Explicitly close
            $This.Stop()
            $This.Stream.Close()
            $This.Client.Close()
        }
        [Object] TcpMessage([UInt32]$Index,[Byte[]]$Byte)
        {
            Return [SocketTcpMessage]::New($Index,$Byte)
        }
        [Object] TcpListener([String]$IpAddress,[UInt32]$Port)
        {
            Return [System.Net.Sockets.TcpListener]::New($IPAddress,$Port)
        }
        [String] RemoteIp()
        {
            Return $This.Client.Client.RemoteEndPoint.Address.ToString()
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        [String] GetString([Byte[]]$Bytes,[UInt32]$Index,[UInt32]$Count)
        {
            Return [System.Text.Encoding]::UTF8.GetString($Bytes,$Index,$Count)
        }
        [Byte[]] GetBytes([String]$Data)
        {
            Return [System.Text.Encoding]::UTF8.GetBytes($Data)
        }
        [String] ToString()
        {
            Return "<SocketTcpServer>"
        }
    }

    Class VmNodeScript
    {
        [UInt32] $Index
        [String] $Description
        [String] $Content
        VmNodeScript([UInt32]$Index,[String]$Content)
        {
            $This.Index       = $Index
            $This.Description = [Regex]::Matches($Content,"^#.+").Value
            $This.Content     = $Content
        }
        Execute()
        {
            $This.Content | Invoke-Expression
        }
    }

    Class VmNetworkDhcp
    {
        [String]        $Name
        [String]  $SubnetMask
        [String]     $Network
        [String]  $StartRange
        [String]    $EndRange
        [String]   $Broadcast
        [String[]] $Exclusion
        VmNetworkDhcp(
        [String]$Name,
        [String]$SubnetMask,
        [String]$Network,
        [String]$StartRange,
        [String]$EndRange,
        [String]$Broadcast,
        [String[]]$Exclusion)
        {
            $This.Name       = $Name
            $This.SubnetMask = $SubnetMask
            $This.Network    = $Network
            $This.StartRange = $StartRange
            $This.EndRange   = $EndRange
            $This.Broadcast  = $Broadcast
            $This.Exclusion  = $Exclusion
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Dhcp>"
        }
    }

    Class VmNetworkNode
    {
        [UInt32]     $Index
        [String]      $Name
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        [UInt32]  $Transmit
        VmNetworkNode(
        [String]     $Index,
        [String]      $Name,
        [String] $IpAddress,
        [String]    $Domain,
        [String]   $NetBios,
        [String]   $Trusted,
        [UInt32]    $Prefix,
        [String]   $Netmask,
        [String]   $Gateway,
        [String[]]     $Dns,
        [UInt32]  $Transmit)
        {
            $This.Index     = $Index
            $This.Name      = $Name
            $This.IpAddress = $IpAddress
            $This.Domain    = $Domain
            $This.NetBios   = $NetBios
            $This.Trusted   = $Trusted
            $This.Prefix    = $Prefix
            $This.Netmask   = $Netmask
            $This.Gateway   = $Gateway
            $This.Dns       = $Dns
            $This.Transmit  = $Transmit
        }
        [Object] VmNetworkDhcp(
        [String]$Name,
        [String]$SubnetMask,
        [String]$Network,
        [String]$StartRange,
        [String]$EndRange,
        [String]$Broadcast,
        [String[]]$Exclusion)
        {
            Return [VmNetworkDhcp]::New($Name,$SubnetMask,$Network,$StartRange,$EndRange,$Broadcast,$Exclusion)
        }
        SetDhcp(
        [String]$Name,
        [String]$SubnetMask,
        [String]$Network,
        [String]$StartRange,
        [String]$EndRange,
        [String]$Broadcast,
        [String[]]$Exclusion)
        {
            $This.Dhcp = $This.VmNetworkDhcp($Name,$SubnetMask,$Network,$StartRange,$EndRange,$Broadcast,$Exclusion)
        }
        [String] Hostname()
        {
            Return "{0}.{1}" -f $This.Name, $This.Domain
        }
        [String] ToString()
        {
            Return "<FEModule.VmNetwork.Node>"
        }
    }

    Class VmNodeControl
    {
        [Object] $Network
        [Object] $Adapter
        [UInt32] $Index
        [Object] $Interface
        [Object] $ScriptList
        VmNodeControl(
        [String]     $Index,
        [String]      $Name,
        [String] $IpAddress,
        [String]    $Domain,
        [String]   $NetBios,
        [String]   $Trusted,
        [UInt32]    $Prefix,
        [String]   $Netmask,
        [String]   $Gateway,
        [String[]]     $Dns,
        [UInt32]  $Transmit)
        {
            $This.Network    = $This.VmNetworkNode($Index,
                                                   $Name,
                                                   $IpAddress,
                                                   $Domain,
                                                   $NetBios,
                                                   $Trusted,
                                                   $Prefix,
                                                   $Netmask,
                                                   $Gateway,
                                                   $Dns,
                                                   $Transmit)

            $This.Adapter    = $This.GetNetAdapter()
            $This.Index      = $This.Adapter.InterfaceIndex
            $This.Interface  = $This.GetNetIpAddress()
            $This.ScriptList = @( )
        }
        [String] Label()
        {
            Return "[FightingEntropy(π)] Start-TcpSession"
        }
        [String] FirewallDescription([UInt32]$Mode)
        {
            Return 'Allows content to be {0} over TCP/{1}' -f @("sent","received")[$Mode], $This.Network.Transmit
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [String] Hostname()
        {
            Return [Environment]::MachineName
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [String] GuestName()
        {
            Return $This.Network.Hostname()
        }
        [String] GetRegistryPath()
        {
            Return "HKLM:\Software\Policies\Secure Digits Plus LLC"
        }
        [String] GetComputerInfoPath()
        {
            Return "{0}\ComputerInfo" -f $This.GetRegistryPath()
        }
        [Object] GetNetAdapter()
        {
            Return Get-NetAdapter | ? Status -eq Up
        }
        [Object] GetNetIpAddress()
        {
            Return Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $This.Index
        }
        [Object[]] GetDnsClientServerAddress()
        {
            Return Get-DnsClientServerAddress -InterfaceIndex $This.Index
        }
        [Object[]] GetNetFirewallRule()
        {
           Return Get-NetFirewallRule
        }
        [Hashtable] NewIpAddress()
        {
            Return @{

                InterfaceIndex  = $This.Index
                AddressFamily   = "IPv4"
                PrefixLength    = $This.Network.Prefix
                ValidLifetime   = [Timespan]::MaxValue
                IPAddress       = $This.Network.IpAddress
                DefaultGateway  = $This.Network.Gateway
            }
        }
        [Hashtable] NewFirewallRule([UInt32]$Mode)
        {
            $Dir  = @("Inbound","Outbound")[$Mode]

            $Item = @{ 

                Name        = "{0} ({1})" -f $This.Label(), $Dir
                DisplayName = $This.Label()
                Description = $This.FirewallDescription($Mode)
                Direction   = $Dir
                Protocol    = "TCP"
                Action      = "Allow"
            }

            $Item.Add(@("LocalPort","RemotePort")[$Mode], $This.Network.Transmit)

            Return $Item
        }
        [Object] VmNetworkNode(
        [String]      $Index ,
        [String]       $Name ,
        [String]  $IpAddress ,
        [String]     $Domain ,
        [String]    $NetBios ,
        [String]    $Trusted ,
        [UInt32]     $Prefix ,
        [String]    $Netmask ,
        [String]    $Gateway ,
        [String[]]      $Dns ,
        [UInt32]   $Transmit )
        {
            Return [VmNetworkNode]::New($Index,$Name,$IpAddress,$Domain,$NetBios,$Trusted,$Prefix,$Netmask,$Gateway,$Dns,$Transmit)
        }
        SetDhcp(
        [String]        $Name ,
        [String]  $SubnetMask ,
        [String]     $Network ,
        [String]  $StartRange ,
        [String]    $EndRange ,
        [String]   $Broadcast ,
        [String[]] $Exclusion )
        {
            $This.Network.SetDhcp($Name,$SubnetMask,$Network,$StartRange,$EndRange,$Broadcast,$Exclusion)
        }
        [Object] VmNodeScript([UInt32]$Index,[String]$Content)
        {
            Return [VmNodeScript]::New($Index,$Content)
        }
        [Object] SocketTcpServer()
        {
            Return [SocketTcpServer]::New($This.Network.IpAddress,$This.Network.Transmit)
        }
        [Void] RemoveNetIpAddress()
        {
            $This.Interface | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:0 -Verbose
        }
        [Void] RemoveNetRoute()
        {
            $This.Interface | Remove-NetRoute -AddressFamily IPv4 -Confirm:0 -Verbose
        }
        [Void] SetNewIpAddress()
        {
            If ($This.Interface.IpAddress -ne $This.Network.IpAddress)
            {
                $This.RemoveNetIpAddress()
                $This.RemoveNetRoute()

                $Splat = $This.NewIpAddress()

                New-NetIpAddress @Splat -Verbose
            }
        }
        [Void] SetDnsClientServerAddress()
        {
            If ($This.Network.DnsAddress -notin $This.GetDnsClientServerAddress().ServerAddresses)
            {
                Set-DnsClientServerAddress -InterfaceIndex $This.Index -ServerAddresses $This.Network.Dns -Verbose
            }
        }
        [Void] CheckFirewall([UInt32]$Mode)
        {
            $Label     = $This.Label()
            $Direction = @("Inbound","Outbound")[$Mode]
            $Item      = $This.GetNetFirewallRule() | ? DisplayName -match $Label | ? Direction -eq $Direction

            If (!$Item)
            {
                $Splat = $This.NewFirewallRule($Mode)
                New-NetFirewallRule @Splat -Verbose
            }
        }
        [Object] GetComputerInfo()
        {
            $Path      = $This.GetComputerInfoPath()
            $Item      = Get-ItemProperty $Path
            $Item.Dhcp = Get-ItemProperty "$Path\Dhcp"

            Return $Item
        }
        Initialize()
        {
            $This.SetNewIpAddress()
            $This.SetDnsClientServerAddress()

            $This.CheckFirewall(0)
            $This.CheckFirewall(1)
        }
        Persistence()
        {
            $Root = $This.GetRegistryPath()
            $Path = "$Root\ComputerInfo"

            If (!(Test-Path $Root))
            {
                New-Item -Path $Root -Verbose
            }

            If (!(Test-Path $Path))
            {
                New-Item -Path $Path -Verbose
            }

            ForEach ($Property in $This.Network.PSObject.Properties)
            {
                $Value = Switch -Regex ($Property.TypeNameOfValue)
                {
                    Default
                    {
                        $Property.Value
                    }
                    "\[\]"
                    {
                        '@([String[]]"{0}")))' -f ($Property.Value -join "`",`"")
                    }
                }

                If ($Property.Name -eq "Dhcp")
                {
                    New-Item "$Path\Dhcp" -Verbose -EA 0
                }

                Else
                {
                    Set-ItemProperty -Path $Path -Name $Property.Name -Value $Value -Verbose
                }
            }

            ForEach ($Property in $This.Network.Dhcp.PSObject.Properties)
            {
                $Value = Switch -Regex ($Property.TypeNameOfValue)
                {
                    Default
                    {
                        $Property.Value
                    }
                    "\[\]"
                    {
                        '@([String[]]"{0}")))' -f ($Property.Value -join "`",`"")
                    }
                }

                Set-ItemProperty -Path "$Path\Dhcp" -Name $Property.Name -Value $Value -Verbose
            }

            If ([Environment]::GetEnvironmentVariable("ComputerName") -ne $This.Network.Name)
            {
                Rename-Computer -NewName $This.Network.Name
            }
        }
        Receive()
        {
            $Script           = $This.SocketTcpServer()

            Try
            {
                $Script.Initialize() 

                $Content          = $Script.Content.Message -join ''
                $This.ScriptList += $This.VmNodeScript($This.ScriptList.Count,$Content)
            }
            Catch
            {
                Throw "Exception [!] Transmission error occurred"
            }
        }
        Execute()
        {
            ForEach ($Item in $This.ScriptList)
            {
                [Console]::WriteLine($Item.Description)
                $Item.Execute()
            }
        }
    }

    [VmNodeControl]::New($Index,$Name,$IpAddress,$Domain,$NetBios,$Trusted,$Prefix,$Netmask,$Gateway,$Dns,$Transmit)
}
