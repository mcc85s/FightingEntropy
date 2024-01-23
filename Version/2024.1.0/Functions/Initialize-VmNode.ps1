<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-23 00:07:39                                                                  //
 \\==================================================================================================// 

    FileName   : Initialize-VmNode.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : For implementing various [controls] and [persistence] in [deployed virtual machines].
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-05-05
    Modified   : 2024-01-22
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Initialize-VmNode
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(ParameterSetName=0,Position=0,Mandatory)][String]     $Index,
    [Parameter(ParameterSetName=0,Position=1,Mandatory)][String]      $Name,
    [Parameter(ParameterSetName=0,Position=2,Mandatory)][String] $IpAddress,
    [Parameter(ParameterSetName=0,Position=3,Mandatory)][String]    $Domain,
    [Parameter(ParameterSetName=0,Position=4,Mandatory)][String]   $NetBios,
    [Parameter(ParameterSetName=0,Position=5,Mandatory)][String]   $Trusted,
    [Parameter(ParameterSetName=0,Position=6,Mandatory)][UInt32]    $Prefix,
    [Parameter(ParameterSetName=0,Position=7,Mandatory)][String]   $Netmask,
    [Parameter(ParameterSetName=0,Position=8,Mandatory)][String]   $Gateway,
    [Parameter(ParameterSetName=0,Position=9,Mandatory)][String[]]     $Dns,
    [Parameter(ParameterSetName=0,Position=10,Mandatory)][UInt32]  $Transmit,
    [Parameter(ParameterSetName=1)][Switch]$Reinitialize)



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

    Class VmNodeSmbShare
    {
        [String] $Path
        [UInt32] $Exists
        [UInt32] $Connected
        [String] $LocalPath
        [String] $RemotePath
        [String] $Username
        [String] $Password
        VmNodeSmbShare([Hashtable]$Share)
        {
            $This.Path       = $Share.LocalPath
            $This.LocalPath  = $This.Path
            $This.RemotePath = $Share.RemotePath
            $This.Username   = $Share.Username
            $This.Password   = $Share.Password
            $This.Check()
        }
        [Hashtable] Splat()
        {
            Return @{ 

                LocalPath    = $This.LocalPath
                RemotePath   = $This.RemotePath
                Username     = $This.Username
                Password     = $This.Password
            }
        }
        Connect()
        {
            $Share   = Get-SmbMapping | ? RemotePath -eq $This.RemotePath
            If ($Share)
            {
                If ($Share.Status -ne "OK")
                {
                    net use /delete $This.LocalPath > $Null
                    $Share = $Null
                }
            }
            
            If (!$Share)
            {
                $Target     = ($This.RemotePath -Split "\\")[2]
                $Test       = Test-Connection -ComputerName $Target -Count 1
                
                If (!$Test)
                {
                    Throw "[!] Unable to connect to remote machine"
                }
            
                $Splat      = $This.Splat()
                $Share      = New-SmbMapping @Splat
            }

            $This.Connected = [UInt32]!!$Share
        }
        Check()
        {
            $This.Exists = [System.IO.Directory]::Exists($This.LocalPath)
        }
        [String] LocalStatusPath()
        {
            Return "{0}\status" -f $This.LocalPath
        }
        Write([String]$Status)
        {
            Set-Content -Path $This.LocalStatusPath() -Value $Status
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    Class VmNodeFunction
    {
        [String] $Path
        [UInt32] $Exists
        VmNodeFunction([String]$Path)
        {
            $This.Path   = $Path
            $This.Check()
        }
        Check()
        {
            $This.Exists = [System.IO.File]::Exists($This.Path)
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    Class VmNodeControl
    {
        [Object]   $Function
        [Object]    $Network
        [Object]    $Adapter
        [UInt32]      $Index
        [Object]  $Interface
        [Object] $ScriptList
        [Object]        $Smb
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
            If (!$This.IsVirtualMachine())
            {
                Throw "[!] This is not a Hyper-V VM"
            }

            $This.SetFunction()

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

            $This.Main()
        }
        VmNodeControl([Switch]$Flags)
        {
            If (!$This.IsVirtualMachine())
            {
                Throw "[!] This is not a Hyper-V VM"
            }

            $This.SetFunction()

            $Path      = $This.GetComputerInfoPath()
            $Item      = Get-ItemProperty $Path

            # [Dhcp]
            $Item.Dhcp = Get-ItemProperty $Path\Dhcp
            If ($Item.Dhcp)
            {
                $Item.Dhcp.Exclusion = $Item.Dhcp.Exclusion | Invoke-Expression
                If ($Item.IpAddress -notin $Item.Dhcp.Exclusion)
                {
                    $Item.Dhcp.Exclusion += $Item.IpAddress
                }

                $List = @( )
                ForEach ($IpAddress in $Item.Dhcp.Exclusion)
                {
                    $List += [IpAddress]"$IpAddress"
                }

                $Item.Dhcp.Exclusion = $List | Sort-Object Address | % IpAddressToString
            }

            # [Dns]
            $Item.Dns = $Item.Dns | Invoke-Expression

            # [Network]
            $This.Network = $This.VmNetworkNode($Item.Index,
                                                $Item.Name,
                                                $Item.IpAddress,
                                                $Item.Domain,
                                                $Item.NetBios,
                                                $Item.Trusted,
                                                $Item.Prefix,
                                                $Item.Netmask,
                                                $Item.Gateway,
                                                $Item.Dns,
                                                $Item.Transmit)

            If ($Item.Dhcp)
            {
                $This.Network.SetDhcp($Item.Dhcp.Name,
                                      $Item.Dhcp.SubnetMask,
                                      $Item.Dhcp.Network,
                                      $Item.Dhcp.StartRange,
                                      $Item.Dhcp.EndRange,
                                      $Item.Dhcp.Broadcast,
                                      $Item.Dhcp.Exclusion)
            }

            $This.Main()

            # [Smb]
            If ($Item.Smb)
            {
                $Item.Smb      = Get-ItemProperty $Item.Smb
                $Splat         = @{ 

                    LocalPath  = $Item.Smb.LocalPath
                    RemotePath = $Item.Smb.RemotePath
                    Username   = $Item.Smb.Username
                    Password   = $Item.Smb.Password
                }

                If (!(Test-Path $Splat.LocalPath))
                {
                    New-SmbMapping @Splat -Verbose -EA 0
                }

                $This.Smb      = $This.VmNodeSmbShare($Splat)
                If ($This.Smb.Connected -eq 0)
                {
                    $This.Smb.Connect()
                }
            }
        }
        SetFunction()
        {
            # Tests/Builds registry path
            If (!(Test-Path $This.GetComputerInfoPath()))
            {
                $This.BuildRegistryPath()
            }

            # Gets the registry information
            $Item = Get-ItemProperty $This.GetComputerInfoPath()

            # Automatically determine the function location
            If (!$Item.Function)
            {
                [Console]::WriteLine("[~] Getting available modules")
                $Installed    = Get-Module -ListAvailable
                $xModule      = $Installed | ? Name -eq FightingEntropy

                If ($xModule)
                {
                    # Module found, check typical path for Initialize-VmNode.ps1
                    $Version  = $xModule.Version.ToString()
                    $Resource = "{0}\{1}" -f $This.FunctionModulePath(), $Version
                    $File     = "$Resource\Functions\Initialize-VmNode.ps1"
                    Switch ([UInt32][System.IO.File]::Exists($File))
                    {
                        0
                        {
                            # File NOT found, write script block from memory and set the default path
                            $This.WriteFunctionFromMemory()
                            $This.Function = $This.VmNodeFunction($This.FunctionStandalonePath())
                        }
                        1
                        {
                            # File found, setting path
                           $This.Function = $This.VmNodeFunction($File)
                        }
                    }
                }
                Else
                {
                    # Module NOT found, write script block from memory and set the default path
                    $This.WriteFunctionFromMemory()
                    $This.Function = $This.VmNodeFunction($This.FunctionStandalonePath())
                }

                # Sets the property in the registry
                Set-ItemProperty -Path $This.GetComputerInfoPath() -Name Function -Value $This.Function.Path
            }
        }
        BuildRegistryPath()
        {
            $Split = $This.GetComputerInfoPath() -Split "\"
            $xPath = $Split[0]
            ForEach ($X in 1..($Split.Count-1))
            {
                $Item  = $Split[$X]
                $xPath = $xPath, $Item -join "\"
                If (!(Test-Path $xPath))
                {
                    New-Item -Path $xPath
                }
            }
        }
        WriteFunctionFromMemory()
        {
            $File     = $This.FunctionStandalonePath()
            $xFunction = Get-ChildItem Function:\Initialize-VmNode
            If (!$xFunction)
            {
                Throw "[!] Could not retrieve function from memory"
            }
            Else
            {
                Try
                {
                    [System.IO.File]::WriteAllLines($File,$xFunction.ScriptBlock)
                }
                Catch
                {
                    Throw "[!] Could not write function to file"
                }
            }
        }
        [Object] VmNodeFunction([String]$Path)
        {
            Return [VmNodeFunction]::New($Path)
        }
        [String] FunctionStandalonePath()
        {
            Return "$Env:ProgramData\Secure Digits Plus LLC\ComputerInfo\Initialize-VmNode.ps1"
        }
        [String] FunctionModulePath()
        {
            Return "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        }
        Main()
        {   
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
            Return "HKLM:\Software\Policies\{0}" -f $This.Author()
        }
        [String] GetComputerInfoPath()
        {
            Return "{0}\ComputerInfo" -f $This.GetRegistryPath()
        }
        [UInt32] IsVirtualMachine()
        {
            $Computer = Get-CimInstance Win32_ComputerSystem
            Return $Computer.Model -eq 'Virtual Machine'
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
        [Object] VmNodeSmbShare([Hashtable]$Drive)
        {
            Return [VmNodeSmbShare]::New($Drive)
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
            Return Get-ItemProperty $This.GetComputerInfoPath() -EA 0
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
            If ($Env:FEComputerInfo)
            {
                Throw "[!] Persistence is already set"
            }

            $Root = $This.GetRegistryPath()
            $Path = "$Root\ComputerInfo"

            If (!(Test-Path $Root))
            {
                New-Item -Path $Root -Verbose
            }

            If (!(Test-Path $Path))
            {
                New-Item -Path $Path -Verbose
                
                [System.Environment]::SetEnvironmentVariable("FEComputerInfo",$Path,"Machine")
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
                        '@([String[]]"{0}")' -f ($Property.Value -join "`",`"")
                    }
                }

                If ($Property.Name -eq "Dhcp")
                {
                    New-Item "$Path\Dhcp" -Verbose -EA 0
                    $Value = "$Path\Dhcp"
                }
                
                Set-ItemProperty -Path $Path -Name $Property.Name -Value $Value -Verbose
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
                        '@([String[]]"{0}")' -f ($Property.Value -join "`",`"")
                    }
                }

                Set-ItemProperty -Path "$Path\Dhcp" -Name $Property.Name -Value $Value -Verbose
            }

            If ([Environment]::GetEnvironmentVariable("ComputerName") -ne $This.Network.Name)
            {
                Rename-Computer -NewName $This.Network.Name
            }
        }
        SetPowerShellProfile()
        {
            $Script = @("# Set [TLS 1.2]","[Net.ServicePointManager]::SecurityProtocol = 3072")
            $Path   = "$Env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_Profile.ps1"
            $Parent = $Path | Split-Path -Parent

            # Ensure that the directory exists
            If (![System.IO.Directory]::Exists($Parent))
            {
                [System.IO.Directory]::CreateDirectory($Parent)
            }

            # Ensure that the file exists
            If (![System.IO.File]::Exists($Path))
            {
                [System.IO.File]::Create($Path).Dispose()
            }

            # Get file content
            $File    = [System.IO.File]::ReadAllLines($Path)

            # Capture profile to output array
            $Array   = @( )
            ForEach ($Line in $File)
            {
                $Array += $Line
            }

            # Ensure script lines are not duplicating items in file
            ForEach ($Line in $Script)
            {
                If ($Line -notin $Array)
                {
                    $Array += $Line
                }
            }

            # Write to file
            [System.IO.File]::WriteAllLines($Path,$Array)
        }
        Instantiate()
        {
            $This.Initialize()
            $This.Persistence()
            $This.SetPowerShellProfile()
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
        SetSmb([Hashtable]$Drive)
        {
            $This.Smb = $This.VmNodeSmbShare($Drive)
            If ($This.Smb.Exists)
            {
                $Root     = $This.GetRegistryPath()
                $Path     = "$Root\ComputerInfo"
                New-Item -Path "$Path\Smb"
                Set-ItemProperty -Path $Path -Name Smb -Value "$Path\Smb"

                $List     = $This.Smb.PSObject.Properties | ? Name -match "(LocalPath|RemotePath|Username|Password)"
                ForEach ($Property in $List)
                {
                    Set-ItemProperty -Path "$Path\Smb" -Name $Property.Name -Value $Property.Value
                }
            }
        }
        Status([String]$Status)
        {
            If (!$This.Smb.Exists)
            {
                Throw "[!] Smb not connected"
            }

            $This.Smb.Write($Status)
        }
        [String] ToString()
        {
            Return "<FEModule.Initialize.VmNode>"
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0
        {
            [VmNodeControl]::New($Index,$Name,$IpAddress,$Domain,$NetBios,$Trusted,$Prefix,$Netmask,$Gateway,$Dns,$Transmit)
        }
        1
        {
            [VmNodeControl]::New([Switch]$True)
        }
    }
}
