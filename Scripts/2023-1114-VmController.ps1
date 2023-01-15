
    Class AdminCredential
    {
        [String]         $UserName
        [PSCredential] $Credential
        AdminCredential([String]$Username)
        {
            $This.Username   = $Username
            $Length          = $This.Random(8,16)
            $Bytes           = [Byte[]]::New($Length)

            ForEach ($X in 0..($Length-1))
            {
                $Bytes[$X]   = $This.Random(32,126)
            }

            $Pass            = [Char[]]$Bytes -join '' | ConvertTo-SecureString -AsPlainText -Force
            $This.Credential = [PSCredential]::New($This.Username,$Pass)
        }
        [UInt32] Random([UInt32]$Min,[UInt32]$Max)
        {
            Return Get-Random -Min $Min -Max $Max
        }
        [String] Password()
        {
            Return $This.Credential.GetNetworkCredential().Password
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.AdminCredential>"
        }
    }

    Class V4PingResponse
    {
        Hidden [UInt32]   $Index
        Hidden [UInt32]  $Status
        [String]      $IpAddress
        [String]       $Hostname
        V4PingResponse([UInt32]$Index,[String]$Address,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = $Reply.Result.Status -match "Success"
            $This.IPAddress      = $Address
        }
        GetHostname()
        {
            $This.Hostname       = Try 
            { 
                [System.Net.Dns]::Resolve($This.IPAddress).Hostname 
            } 
            Catch 
            { 
                "<Unknown>" 
            }
        }
        Domain([String]$Domain)
        {
            If ($This.Hostname -match $Domain)
            {
                $This.Hostname = ("{0}.{1}" -f $This.Hostname, $Domain)
            }
        }
        [String] ToString()
        {
            Return $This.IPAddress
        }
    }

    Class Size
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String] $String
        Size([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.String = $This.GetSize($Bytes)
        }
        [String] GetSize([Int64]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -lt 1KB}                 {     "{0} B" -f $Size }
                {$_ -ge 1KB -and $_ -lt 1MB} { "{0:n2} KB" -f ($Size/1KB) }
                {$_ -ge 1MB -and $_ -lt 1GB} { "{0:n2} MB" -f ($Size/1MB) }
                {$_ -ge 1GB -and $_ -lt 1TB} { "{0:n2} GB" -f ($Size/1GB) }
                {$_ -ge 1TB}                 { "{0:n2} TB" -f ($Size/1TB) }
            })
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    Class NetworkNode
    {
        [UInt32]     $Index
        [String]    $Domain
        [String]   $NetBios
        [String]      $Name
        [String] $IpAddress
        [UInt32]    $Prefix
        [String]   $Gateway
        [String[]]     $Dns
        [String]   $Trusted
        NetworkNode([UInt32]$Index,[String]$Name,[String]$IpAddress,[Object]$Hive)
        {
            $This.Index     = $Index
            $This.Domain    = $Hive.Domain
            $This.NetBios   = $Hive.NetBios
            $This.Name      = $Name
            $This.IpAddress = $IpAddress
            $This.Prefix    = $Hive.Prefix
            $This.Gateway   = $Hive.Gateway
            $This.Dns       = $Hive.Dns
            $This.Trusted   = $Hive.Trusted
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.NetworkNode>"
        }
    }
    
    Class NetworkHive
    {
        Hidden [Object] $Config
        [String]        $Domain
        [String]       $NetBios
        [String]       $Trusted
        [UInt32]        $Prefix
        [String]       $Gateway
        [String[]]         $Dns
        [Object]         $Range
        [Object]        $Output
        NetworkHive([Object]$Config,[String]$Domain,[String]$NetBios)
        {
            $This.Config    = $Config
            $This.Domain    = $Domain
            $This.NetBios   = $NetBios
            $This.Trusted   = $This.Config.IPV4Address.IpAddress.ToString()
            $This.Prefix    = $This.Config.IPv4Address.PrefixLength
            $This.Gateway   = $This.Config.IPV4DefaultGateway.NextHop
            $This.Dns       = $This.Config.DnsServer | ? AddressFamily -eq 2 | % ServerAddresses
            $This.Range     = @( )
            $This.Output    = @( )

            $This.GetIPAddressRange()
        }
        [Object] NetworkNode([UInt32]$Index,[String]$Name,[String]$IpAddress,[Object]$Hive)
        {
            Return [NetworkNode]::New($Index,$Name,$IpAddress,$Hive)
        }
        AddNode([String]$Name)
        {
            $IpAddress      = $This.Range | ? { $_ -notin $This.Output.IpAddress } | Select-Object -First 1
            $This.Output += $This.NetworkNode($This.Output.Count,$Name,$IpAddress,$This)
        }
        GetIPAddressRange()
        {
            $PF       = $This.Config.IPv4Address.PrefixLength
            $IP       = [UInt32[]]($This.Config.IPv4Address.IPAddress -Split "\.")

            # Convert IP and PrefixLength into binary, netmask, and wildcard
            $Binary   = (0..31 | % { [Int32]($_ -lt $PF); If ($_ -in 7,15,23) {"."} }) -join ''
            $Netmask  = [UInt32[]]($Binary -Split "\." | % { [Convert]::ToInt32($_,2 ) })
            $Wildcard = $Netmask | % { (256-$_) - 1 }

            # Convert wildcard into total host range
            $Hash     = @{ } 
            ForEach ($X in 0..3)
            {
                Switch ($Wildcard[$X])
                {
                    0 
                    { 
                        $Hash.Add($X,$IP[$X])
                    }
                    Default
                    {
                        $Hash.Add($X,($Netmask[$X])..($Netmask[$X]+$Wildcard[$X]))
                    }
                }
            }

            # Build host range
            $xRange   = @{ }
            ForEach ($0 in $Hash[0])
            {
                ForEach ($1 in $Hash[1])
                {
                    ForEach ($2 in $Hash[2])
                    {
                        ForEach ($3 in $Hash[3])
                        {
                            $xRange.Add($xRange.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            # Subtract network + broadcast addresses
            $xRange = $xRange[1..($xRange.Count-2)]

            # Ping asynchronously
            If ($xRange.Count -gt 0)
            {
                $List = $This.V4PingSweep($xRange) | ? Status
            }

            ForEach ($Item in $xRange | ? {$_ -notin $List.IpAddress})
            {
                $This.Range += $Item
            }
        }
        [Object] V4PingOptions()
        {
            Return [System.Net.NetworkInformation.PingOptions]::New()
        }
        [Object] V4PingBuffer()
        {
            Return 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
        }
        [Object] V4Ping([String]$Ip)
        {
            $Item = [System.Net.NetworkInformation.Ping]::New()
            Return $Item.SendPingAsync($Ip,100,$This.V4PingBuffer(),$This.V4PingOptions())
        }
        [Object] V4PingResponse([UInt32]$Index,[Object]$Ip,[Object]$Ping)
        {
            Return [V4PingResponse]::New($Index,$Ip,$Ping)
        }
        [Object[]] V4PingSweep([String[]]$Hosts)
        {
            $Ping                = @{ }
            $Response            = @{ }

            If ($Hosts.Count -eq 1)
            {
                $Ping.Add(0,$This.V4Ping($Hosts[0]))
                $Response.Add(0,$This.V4PingResponse(0,$Hosts[0],$Ping[0]))
                Return $Response[0]
            }
            ElseIf ($Hosts.Count -gt 1)
            {
                ForEach ($X in 0..($Hosts.Count-1))
                { 
                    $Ping.Add($Ping.Count,$This.V4Ping($Hosts[$X]))
                }
        
                ForEach ($X in 0..($Ping.Count-1)) 
                {
                    $Response.Add($X,$This.V4PingResponse($X,$Hosts[$X],$Ping[$X]))
                }
        
                Return $Response[0..($Response.Count-1)]
            }
            Else
            {
                Return $Null
            }
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.NetworkHive>"
        }
    }

    Class VmNode
    {
        [UInt32]      $Index
        [Object]       $Name
        [Object]     $Memory
        [Object]       $Path
        [Object]        $Vhd
        [Object]    $VhdSize
        [Object] $Generation
        [UInt32]       $Core
        [Object] $SwitchName
        [Object]    $Network
        VmNode([Object]$Node,[Object]$Hive)
        {
            $This.Index      = $Node.Index
            $This.Name       = $Node.Name
            $This.Memory     = $Hive.Memory
            $This.Path       = $Hive.Base, $This.Name -join '\'
            $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $Hive.Base, $This.Name
            $This.VhdSize    = $This.Size("HDD",$Hive.HDD)
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.VmNode>"
        }
    }

    Class VmTemplate
    {
        [String]     $Base
        [UInt64]   $Memory
        [UInt64]      $Hdd
        [UInt32]      $Gen
        [UInt32]     $Core
        [String] $SwitchId
        [String]    $Image
        VmTemplate([String]$Path,[UInt64]$Ram,[UInt64]$Hdd,[UInt32]$Gen,[UInt32]$Core,[String]$Switch,[String]$Img)
        {
            $This.Base     = $Path
            $This.Memory   = $Ram
            $This.Hdd      = $Hdd
            $This.Gen      = $Gen
            $This.Core     = $Core
            $This.SwitchId = $Switch
            $This.Image    = $Img
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.VmTemplate>"
        }
    }

    Class VmObjectFile
    {
        [UInt32]     $Index
        [String]    $Domain
        [String]   $NetBios
        [String]      $Name
        [String] $IpAddress
        [UInt32]    $Prefix
        [String]   $Gateway
        [String[]]     $Dns
        [String]   $Trusted
        [String]      $Base
        [UInt64]    $Memory
        [UInt64]       $Hdd
        [UInt32]       $Gen
        [UInt32]      $Core
        [String]  $SwitchId
        [String]     $Image
        VmObjectFile([Object]$Node,[Object]$Template)
        {
            $This.Index     = $Node.Index
            $This.Domain    = $Node.Domain
            $This.NetBios   = $Node.NetBios
            $This.Name      = $Node.Name
            $This.IpAddress = $Node.IpAddress
            $This.Prefix    = $Node.Prefix
            $This.Gateway   = $Node.Gateway
            $This.Dns       = $Node.Dns
            $This.Trusted   = $Node.Trusted
            $This.Base      = $Template.Base
            $This.Memory    = $Template.Memory
            $This.Hdd       = $Template.Hdd
            $This.Gen       = $Template.Gen
            $This.Core      = $Template.Core
            $This.SwitchId  = $Template.SwitchId
            $This.Image     = $Template.Image
        }
    }

    # // Initial information
    Class VmController
    {
        [String]     $Path
        [String]   $Domain
        [String]  $NetBios
        [Object]    $Admin
        [Object]   $Config
        [Object]  $Network
        [Object] $Template
        VmController([String]$Path,[String]$Domain,[String]$NetBios)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                [System.IO.Directory]::CreateDirectory($Path)
            }

            $This.Path     = $Path
            $This.Domain   = $Domain
            $This.NetBios  = $NetBios
            $This.Admin    = $This.NewAdminCredential()
            $This.Config   = $This.GetNetIPConfiguration()
            $This.Network  = $This.NewNetworkHive()
            $This.Template = $This.NewVmTemplate()
        }
        [Object] NewAdminCredential()
        {
            Return [AdminCredential]::New("Administrator")
        }
        [Object] GetNetIPConfiguration()
        {
            Return Get-NetIPConfiguration -Detailed | ? IPV4DefaultGateway | Select-Object -First 1
        }
        [Object] NewNetworkHive()
        {
            Return [NetworkHive]::New($This.Config,$This.Domain,$This.NetBios)
        }
        [Object] NewVmTemplate()
        {
            Return [VmTemplate]::New("C:\VDI",
                                     2048MB,
                                     64GB,
                                     2,
                                     2,
                                     "External",
                                     "C:\Images\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO")
        }
        [Object] NewVmObjectFile([Object]$Node)
        {
            Return [VmObjectFile]::New($Node,$This.Template)
        }
        AddNode([String]$Name)
        {
            If ($Name -notin $This.Network.Output)
            {
                $This.Network.AddNode($Name)
            }
        }
        Export()
        {
            ForEach ($Node in $This.Network.Output)
            {
                $FilePath = "{0}\{1}-{2}.json" -f $This.Path, $Node.Index, $Node.Name

                [Console]::WriteLine("Exporting [~] File: [$FilePath]")

                $Value    = $This.NewVmObjectFile($Node) | ConvertTo-Json

                [System.IO.File]::WriteAllLines($FilePath,$Value)

                If ([System.IO.File]::Exists($FilePath))
                {
                    [Console]::WriteLine("Exported  [+] File: [$FilePath]")
                }
                Else
                {
                    Throw "Something failed... bye."
                }
            }
        }
        [String] ToString()
        {
            Return "<FEVirtualLab.VmController>"
        }
    }

    # // ==================================================================================
    # // | Spawn up a hive controller to create file system objects for each Hyper-V host |
    # // | to automate all of the stuff each VM node will be reproducing                  |
    # // ==================================================================================

    $Hive  = [VmController]::New("C:\Files","securedigitsplus.com","secured")

    0..2 | % { $Hive.AddNode("server0$_") }
