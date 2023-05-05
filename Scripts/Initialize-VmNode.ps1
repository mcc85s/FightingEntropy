<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-05-05 15:08:29                                                                  //
 \\==================================================================================================// 

    FileName   : 
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For implementing various [controls] and [persistence] in [deployed virtual machines].
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-05-05
    Modified   : 2023-05-05
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
        [String] $Content
        VmNodeScript([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
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
        SetDhcp([Object]$Dhcp)
        {
            $This.Dhcp = $Dhcp
        }
        [String] Hostname()
        {
            Return "{0}.{1}" -f $This.Name, $This.Domain
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Node]>"
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
                PrefixLength    = $This.Prefix
                ValidLifetime   = [Timespan]::MaxValue
                IPAddress       = $This.IpAddress
                DefaultGateway  = $This.Gateway
            }
        }
        [Hashtable] NewFirewallRule([UInt32]$Mode)
        {
            $Item = @{ 

                DisplayName = $This.Label()
                Description = $This.FirewallDescription($Mode)
                Direction   = @("Inbound","Outbound")[$Mode]
                Protocol    = "TCP"
                Action      = "Allow"
            }

            $Item.Add(@("LocalPort","RemotePort")[$Mode], $This.Network.Transmit)

            Return $Item
        }
        [Object] VmNetworkNode(
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
            Return [VmNetworkNode]::New($Index,$Name,$IpAddress,$Domain,$NetBios,$Trusted,$Prefix,$Netmask,$Gateway,$Dns,$Transmit)
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
        Initialize()
        {
            $This.SetNewIpAddress()
            $This.SetDnsClientServerAddress()

            $This.CheckFirewall(0)
            $This.CheckFirewall(1)
        }
        Receive()
        {
            $Script           = $This.SocketTcpServer()

            Try
            {
                $Script.Initialize()

                $Content          = $Script.Message.Content -join ''
                $This.ScriptList += $This.VmNodeScript($This.ScriptList.Count,$Content)
            }
            Catch
            {
                Throw "Exception [!] Transmission error occurred"
            }
        }
    }

    [VmNodeControl]::New($Index,$Name,$IpAddress,$Domain,$NetBios,$Trusted,$Prefix,$Netmask,$Gateway,$Dns)

    <#
    $Base = "https://www.github.com/mcc85s/FightingEntropy/blob/main/Version/2023.4.0"
$Url = "$Base/FightingEntropy.ps1?raw=true"
Invoke-RestMethod $Url | Invoke-Expression
$Module.Latest()

        [String[]] ImportFeModule()
        {
            Return 'Set-ExecutionPolicy Bypass -Scope Process -Force', 'Import-Module FightingEntropy -Force -Verbose'
        }
        [String[]] PrepPersistentInfo()
        {
            # Prepare the correct persistent information
            $List = @( )


            $List += '$P = @{ }'
            ForEach ($P in @($This.Network.PSObject.Properties | ? Name -ne Dhcp))
            {
                $List += Switch -Regex ($P.TypeNameOfValue)
                {
                    Default
                    {
                        '$P.Add($P.Count,("{0}","{1}"))' -f $P.Name, $P.Value
                    }
                    "\[\]"
                    {
                        '$P.Add($P.Count,("{0}",@([String[]]"{1}")))' -f $P.Name, ($P.Value -join "`",`"")
                    }
                }
            }
           
            If ($This.Role -eq "Server")
            {
                $List += '$P.Add($P.Count,("Dhcp","$Dhcp"))'
            }
           
            $List += '$P[0..($P.Count-1)] | % { Set-ItemProperty -Path $Path -Name $_[0] -Value $_[1] -Verbose }'


            If ($This.Role -eq "Server")
            {
                $List += '$P = @{ }'
               
                ForEach ($P in @($This.Network.Dhcp.PSObject.Properties))
                {
                    $List += Switch -Regex ($P.TypeNameOfValue)
                    {
                        Default
                        {
                            '$P.Add($P.Count,("{0}","{1}"))' -f $P.Name, $P.Value
                        }
                        "\[\]"
                        {
                            '$P.Add($P.Count,("{0}",@([String[]]"{1}")))' -f $P.Name, ($P.Value -join "`",`"")
                        }
                    }
                }


                $List += '$P[0..($P.Count-1)] | % { Set-ItemProperty -Path $Dhcp -Name $_[0] -Value $_[1] -Verbose }'
            }


            Return $List
        }
        SetPersistentInfo()
        {
            # [Phase 1] Set persistent information
            $This.Script.Add(1,"SetPersistentInfo","Set persistent information",@(
            '$Root      = "{0}"' -f $This.GetRegistryPath();
            '$Name      = "{0}"' -f $This.Name;
            '$Path      = "$Root\ComputerInfo"';
            'Rename-Computer $Name -Force -EA 0';
            'If (!(Test-Path $Root))';
            '{';
            '    New-Item -Path $Root -Verbose';
            '}';
            'New-Item -Path $Path -Verbose';
            If ($This.Role -eq "Server")
            {
                '$Dhcp = "$Path\Dhcp"';
                'New-Item $Dhcp';
            }
            $This.PrepPersistentInfo()))
        }
        SetTimeZone()
        {
            # [Phase 2] Set time zone
            $This.Script.Add(2,"SetTimeZone","Set time zone",@('Set-Timezone -Name "{0}" -Verbose' -f (Get-Timezone).Id))
        }
        SetComputerInfo()
        {
            # [Phase 3] Set computer info
            $This.Script.Add(3,"SetComputerInfo","Set computer info",@(
            '$Item           = Get-ItemProperty "{0}\ComputerInfo"' -f $This.GetRegistryPath()
            '$TrustedHost    = $Item.Trusted';
            '$IPAddress      = $Item.IpAddress';
            '$PrefixLength   = $Item.Prefix';
            '$DefaultGateway = $Item.Gateway';
            '$Dns            = $Item.Dns'))
        }
        SetIcmpFirewall()
        {
            $Content = Switch ($This.Role)
            {
                Server
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose'
                }
                Client
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose',
                    'Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -Verbose'
                }
            }


            # [Phase 4] Enable IcmpV4
            $This.Script.Add(4,"SetIcmpFirewall","Enable IcmpV4",@($Content))
        }
        SetInterfaceNull()
        {
            # [Phase 5] Get InterfaceIndex, get/remove current (IP address + Net Route)
            $This.Script.Add(5,"SetInterfaceNull","Get InterfaceIndex, get/remove current (IP address + Net Route)",@(
            '$Index              = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex';
            '$Interface          = Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $Index';
            '$Interface          | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$False -Verbose';
            '$Interface          | Remove-NetRoute     -AddressFamily IPv4 -Confirm:$False -Verbose'))
        }
        SetStaticIp()
        {
            # [Phase 6] Set static IP Address
            $This.Script.Add(6,"SetStaticIp","Set (static IP Address + Dns server)",@(
            '$Splat              = @{';
            ' ';
            '    InterfaceIndex  = $Index';
            '    AddressFamily   = "IPv4"';
            '    PrefixLength    = $Item.Prefix';
            '    ValidLifetime   = [Timespan]::MaxValue';
            '    IPAddress       = $Item.IPAddress';
            '    DefaultGateway  = $Item.Gateway';
            '}';
            'New-NetIPAddress @Splat';
            'Set-DnsClientServerAddress -InterfaceIndex $Index -ServerAddresses $Item.Dns'))
        }
        SetWinRm()
        {
            # [Phase 7] Set WinRM (Config)
            $This.Script.Add(7,"SetWinRm","Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)",@(
            'winrm quickconfig';
            '<Timer[2]>';
            'y';
            '<Timer[3]>';
            If ($This.Role -eq "Client")
            {
                'y';
                '<Timer[3]>';
            }
            'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $Item.Trusted';
            '<Timer[4]>';
            'y'))
        }
        SetWinRmFirewall()
        {
            # [Phase 8] Set WinRm (Self-Signed Certificate/HTTPS Listener/Firewall)
            $This.Script.Add(8,"SetWinRmFirewall",'Set WinRm Firewall',@(
            '$Cert           = New-SelfSignedCertificate -DnsName $Item.IpAddress -CertStoreLocation Cert:\LocalMachine\My';
            '$Thumbprint     = $Cert.Thumbprint';
            '$Hash           = "@{Hostname=`"$IPAddress`";CertificateThumbprint=`"$Thumbprint`"}"';
            "`$Str            = `"winrm create winrm/config/Listener?Address=*+Transport=HTTPS '{0}'`"";
            'Invoke-Expression ($Str -f $Hash)'
            '$Splat          = @{';
            ' ';
            '    Name        = "WinRM/HTTPS"';
            '    DisplayName = "Windows Remote Management (HTTPS-In)"';
            '    Direction   = "In"';
            '    Action      = "Allow"';
            '    Protocol    = "TCP"';
            '    LocalPort   = 5986';
            '}';
            'New-NetFirewallRule @Splat -Verbose'))
        }
        SetRemoteDesktop()
        {
            # [Phase 9] Set Remote Desktop
            $This.Script.Add(9,"SetRemoteDesktop",'Set Remote Desktop',@(
            'Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0';
            'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'))
        }
        InstallFeModule()
        {
            # [Phase 10] Install [FightingEntropy()]
            $This.Script.Add(10,"InstallFeModule","Install [FightingEntropy()]",@(
            '[Net.ServicePointManager]::SecurityProtocol = 3072';
            'Set-ExecutionPolicy Bypass -Scope Process -Force';
            '$Install = "https://github.com/mcc85s/FightingEntropy/blob/main/Version/2023.4.0/FightingEntropy.ps1?raw=true"';
            'Invoke-RestMethod $Install | Invoke-Expression';
            '$Module.Latest()';
            '<Idle[5,5]>';
            'Import-Module FightingEntropy'))
        }
        InstallChoco()
        {
            # [Phase 11] Install Chocolatey
            $This.Script.Add(11,"InstallChoco","Install Chocolatey",@(
            "Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression"))
        }
        InstallVsCode()
        {
            # [Phase 12] Install Visual Studio Code
            $This.Script.Add(12,"InstallVsCode","Install Visual Studio Code",@("choco install vscode -y"))
        }
        InstallBossMode()
        {
            # [Phase 13] Install BossMode (vscode color theme)
            $This.Script.Add(13,"InstallBossMode","Install BossMode (vscode color theme)",@("Install-BossMode"))
        }
        InstallPsExtension()
        {
            # [Phase 14] Install Visual Studio Code (PowerShell Extension)
            $This.Script.Add(14,"InstallPsExtension","Install Visual Studio Code (PowerShell Extension)",@(
            '$FilePath     = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
            '$ArgumentList = "--install-extension ms-vscode.PowerShell"';
            'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process'))
        }
        RestartComputer()
        {
            # [Phase 15] Restart computer
            $This.Script.Add(15,'Restart','Restart computer',@('Restart-Computer'))
        }
        ConfigureDhcp()
        {
            # [Phase 16] Configure Dhcp
            $This.Script.Add(16,'ConfigureDhcp','Configure Dhcp',@(
            '$Root           = "{0}"' -f $This.GetRegistryPath()
            '$Path           = "$Root\ComputerInfo"'
            '$Item           = Get-ItemProperty $Path'
            '$Item.Dhcp      = Get-ItemProperty $Item.Dhcp';
            ' ';
            '$Splat = @{ ';
            '   ';
            '    StartRange = $Item.Dhcp.StartRange';
            '    EndRange   = $Item.Dhcp.EndRange';
            '    Name       = $Item.Dhcp.Name';
            '    SubnetMask = $Item.Dhcp.SubnetMask';
            '}';
            ' ';
            'Add-DhcpServerV4Scope @Splat -Verbose';
            'Add-DhcpServerInDc -Verbose';
            ' ';
            'ForEach ($Value in $Item.Dhcp.Exclusion)';
            '{';
            '    $Splat         = @{ ';
            ' ';
            '        ScopeId    = $Item.Dhcp.Network';
            '        StartRange = $Value';
            '        EndRange   = $Value';
            '    }';
            ' ';
            '    Add-DhcpServerV4ExclusionRange @Splat -Verbose';
            ' ';
            '   (3,$Item.Gateway),';
            '   (6,$Item.Dns),';
            '   (15,$Item.Domain),';
            '   (28,$Item.Dhcp.Broadcast) | % {';
            '    ';
            '       Set-DhcpServerV4OptionValue -OptionId $_[0] -Value $_[1] -Verbose'
            '   }';
            '}';
            'netsh dhcp add securitygroups';
            'Restart-Service dhcpserver';
            ' ';
            '$Splat    = @{ ';
            ' ';
            '    Path  = "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12"';
            '    Name  = "ConfigurationState"';
            '    Value = 2';
            '}';
            ' ';
            'Set-ItemProperty @Splat -Verbose'))
        }
    #>
}
