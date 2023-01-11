
    # Last edited : 2023-01-11 03:47:46
    # Purpose     : Automatically installs a Windows Server 2016 instance for configuration

    # [Objective]: Get (2) virtual servers to work together as an Active Directory domain controller cluster
    # by using [FightingEntropy(π)] Get-FEDCPromo.

    # Be really clever about it, too.
    # Use a mixture of virtualization, graphic design, networking, and programming...
    # ...to show everybody and their mother...
    # ...that you're an expert.

    # Even the guys at Microsoft will think this shit is WICKED cool...
    # https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0103-(Get-FEDCPromo).pdf

    # // =====================================================
    # // | Generates a random password for security purposes |
    # // =====================================================

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
    }

    # // ============================================
    # // | Object returned from a ping (sweep/scan) |
    # // ============================================

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

    # // ========================================================
    # // | Aggregates valid (static IP/prefix/gateway/dns) info |
    # // ========================================================
    
    Class NetworkInformation
    {
        Hidden [Object] $Config
        [String]       $Trusted
        [String]       $Address
        [UInt32]        $Prefix
        [String]       $Gateway
        [String]           $Dns
        NetworkInformation([Object]$Config)
        {
            $This.Config    = $Config
            $This.Trusted   = $Config.IPv4Address.IpAddress.ToString()
            $This.Prefix    = $Config.IPv4Address.PrefixLength
            $This.Gateway   = $Config.IPv4DefaultGateway.NextHop
            $This.Dns       = $This.GetDns()
            $This.Address   = $This.GetIpAddress()
        }
        [String] GetIpAddress()
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
            $Range   = @{ }
            ForEach ($0 in $Hash[0])
            {
                ForEach ($1 in $Hash[1])
                {
                    ForEach ($2 in $Hash[2])
                    {
                        ForEach ($3 in $Hash[3])
                        {
                            $Range.Add($Range.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            # Subtract network + broadcast addresses
            $Range = $Range[1..($Range.Count-2)]

            # Ping asynchronously
            If ($Range.Count -gt 0)
            {
                $List = $This.V4PingSweep($Range) | ? Status
            }

            Return ($Range | ? {$_ -notin $List.IpAddress})[0]
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
        [String] GetDns()
        {
            $S = $This.Config.DnsServer | ? AddressFamily -eq 2
            Return $S.ServerAddresses | Select-Object -First 1
        }
    }

    # // =======================================================================
    # // | Used to convert the byte size of a drive or partition into a string |
    # // =======================================================================

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

    # // ==========================================
    # // | Virtual Machine controller for Hyper-V |
    # // ==========================================

    Class VmObjectNode
    {
        Hidden [UInt32]     $Mode
        [Object]         $Console
        [Object]            $Name
        [Object]          $Memory
        [Object]            $Path
        [Object]             $Vhd
        [Object]         $VhdSize
        [Object]      $Generation
        [UInt32]            $Core
        [Object[]]    $SwitchName
        [Object]         $Network
        Hidden [String]      $Iso
        Hidden [String[]] $Script
        Hidden [Object] $Firmware
        [UInt32]          $Exists
        [Object]            $Guid
        Hidden [Object]  $Control
        Hidden [Object] $Keyboard
        VmObjectNode([Object]$Vm)
        {
            $This.Mode = 1
            $This.StartConsole()
            $This.Name = $Vm.Name
            $This.Path = $Vm.Path | Split-Path 
            $This.Vhd  = $Vm.HardDrives[0] | Get-Vhd | % Path
        }
        VmObjectNode([String]$Name,[String]$Base,[UInt64]$Memory,[UInt64]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
        {
            $This.Mode = 0
            $This.Main($Name,$Base,$Memory,$HDD,$Generation,$Core,$Switch)
        }
        VmObjectNode([UInt32]$Mode,[String]$Name,[String]$Base,[UInt64]$Memory,[UInt64]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
        {
            $This.Mode = $Mode
            $This.Main($Name,$Base,$Memory,$HDD,$Generation,$Core,$Switch)
        }
        Main([String]$Name,[String]$Base,[UInt64]$Memory,[UInt64]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
        {
            $This.StartConsole()

            $Item = Get-VM -Name $Name -EA 0
            If ($Item)
            {
                $This.Error(-1,"[!] Virtual machine: $Name [exists]")
            }

            $This.Name       = $Name
            $This.Memory     = $This.Size("Memory",$Memory)
            $This.Path       = "$Base\$($This.Name)"
            $This.Vhd        = "$Base\$($This.Name)\$($This.Name).vhdx"
            $This.VhdSize    = $This.Size("HDD",$HDD)
            $This.Generation = $Generation
            $This.Core       = $Core
            $This.SwitchName = @($Switch)
            $This.Exists     = 0
            $This.Guid       = $Null
            $This.Network    = $This.GetNetworkConfig()
        }
        StartConsole()
        {
            # Instantiates and initializes the console
            $This.Console = New-FEConsole
            $This.Console.Initialize()
            $This.Status()
        }
        [Void] Status()
        {
            # If enabled, shows the last item added to the console
            If ($This.Mode -gt 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        [Void] Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        Error([UInt32]$State,[String]$Status)
        {
            $This.Console.Update($State,$Status)
            Throw $This.Console.Last().Status
        }
        [Object] Get()
        {
            $Vm          = Get-VM -Name $This.Name -EA 0
            $This.Exists = $Vm.Count

            Return @(0,$Vm)[$Vm.Count]
        }
        [Object] Size([String]$Name,[UInt64]$SizeBytes)
        {
            Return [Size]::New($Name,$SizeBytes)
        }
        [String] Hostname()
        {
            Return [Environment]::MachineName
        }
        Connect()
        {
            $This.Update(0,"[~] Connecting : $($This.Name)")
            $Splat           = @{

                Filepath     = "vmconnect"
                ArgumentList = @($This.Hostname(),$This.Name)
                Verbose      = $True
                PassThru     = $True
            }

            Start-Process @Splat
        }
        New()
        {
            $Null = $This.Get()
            If ($This.Exists -ne 0)
            {
                $This.Error(-1,"[!] Exists : $($This.Name)")
            }

            $Object                = @{

                Name               = $This.Name
                MemoryStartupBytes = $This.Memory.Bytes
                Path               = $This.Path
                NewVhdPath         = $This.Vhd
                NewVhdSizeBytes    = $This.VhdSize.Bytes
                Generation         = $This.Generation
                SwitchName         = @($This.SwitchName,$This.SwitchName[0])[$This.SwitchName.GetType().Name -match "\[\]"]
            }

            $This.Update(0,"[~] Creating : $($This.Name)")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { New-VM @Object }
                2       { New-VM @Object -Verbose }
            }

            $This.Firmware         = $This.GetVmFirmware()
            $This.Exists           = 1
            $This.SetVMProcessor()
        }
        Start()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }
            
            ElseIf ($Vm.State -eq "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [already started]")
            }

            Else
            {
                $This.Update(1,"[~] Starting : $($This.Name)")

                # Verbosity level
                Switch ($This.Mode) 
                { 
                    Default { $Vm | Start-VM }
                    2       { $Vm | Start-VM -Verbose }
                }
            }
        }
        Stop()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($Vm.State -ne "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Stopping : $($This.Name)")
            
                # Verbosity level
                Switch ($This.Mode)
                {
                    Default { $This.Get() | ? State -ne Off | Stop-VM -Force }
                    2       { $This.Get() | ? State -ne Off | Stop-VM -Force -Verbose }
                }
            }
        }
        Reset()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($Vm.State -ne "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Restarting : $($This.Name)")
                $This.Stop()
                $This.Start()
                $This.Idle(5,5)
            }
        }
        Remove()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            $This.Update(0,"[~] Removing : $($This.Name)")

            If ($Vm.State -ne "Off")
            {
                $This.Update(0,"[~] State : $($This.Name) [attempting shutdown]")
                Switch -Regex ($Vm.State)
                {
                    "(^Paused$|^Saved$)"
                    { 
                        $This.Start()
                        Do
                        {
                            Start-Sleep 1
                        }
                        Until ($This.Get().State -eq "Running")
                    }
                }

                $This.Stop()
                Do
                {
                    Start-Sleep 1
                }
                Until ($This.Get().State -eq "Off")
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { $This.Get() | Remove-VM -Confirm:$False -Force  } 
                2       { $This.Get() | Remove-VM -Confirm:$False -Force -Verbose } 
            }
            
            $This.Firmware         = $Null
            $This.Exists           = 0
 
            $This.Update(0,"[~] Vhd  : [$($This.Vhd)]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Remove-Item $This.Vhd -Confirm:$False -Force } 
                2       { Remove-Item $This.Vhd -Confirm:$False -Force -Verbose } 
            }
            
            $This.Update(0,"[~] Path : [$($This.Path)]")
            ForEach ($Item in Get-ChildItem $This.Path -Recurse | Sort-Object -Descending)
            {
                $This.Update(0,"[~] $($Item.Fullname)")

                # Verbosity level
                Switch ($This.Mode)
                { 
                    Default { Remove-Item $Item.Fullname -Confirm:$False } 
                    2       { Remove-Item $Item.Fullname -Confirm:$False -Verbose } 
                }
            }

            $This.Update(1,"[ ] Removed : $($Item.Fullname)")

            $This.DumpConsole()
        }
        [Object] GetVmFirmware()
        {
            $This.Update(0,"[~] Getting VmFirmware : $($This.Name)")
            $Item = Switch ($This.Generation) 
            { 
                1 
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    { 
                        Default { Get-VmBios -VmName $This.Name } 
                        2       { Get-VmBios -VmName $This.Name -Verbose } 
                    }
                } 
                2 
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    {
                        Default { Get-VmFirmware -VmName $This.Name }
                        2       { Get-VmFirmware -VmName $This.Name -Verbose }
                    }
                } 
            }

            Return $Item
        }
        SetVmProcessor()
        {
            $This.Update(0,"[~] Setting VmProcessor (Count): [$($This.Core)]")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmProcessor -VMName $This.Name -Count $This.Core }
                2       { Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose }
            }
        }
        SetVmDvdDrive([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error(-1,"[!] Invalid path : [$Path]")
            }

            $This.Update(0,"[~] Setting VmDvdDrive (Path): [$Path]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Path } 
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose }
            }
        }
        SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $This.Update(0,"[~] Setting VmFirmware (Boot order) : [$1,$2,$3]")

            $Fw = $This.GetVmFirmware()
                
            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] } 
                2       { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] -Verbose } 
            }
        }
        AddVmDvdDrive()
        {
            $This.Update(0,"[+] Adding VmDvdDrive()")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Add-VmDvdDrive -VMName $This.Name }
                2       { Add-VmDvdDrive -VMName $This.Name -Verbose }
            }
        }
        LoadIso([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error(-1,"[!] Invalid ISO path : [$Path]")
            }

            Else
            {
                $This.Iso = $Path
                $This.SetVmDvdDrive($This.Iso)
            }
        }
        UnloadIso()
        {
            $This.Update(0,"[+] Unloading ISO")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Null }
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Null -Verbose }
            }
        }
        SetIsoBoot()
        {
            If (!$This.Iso)
            {
                $This.Error(-1,"[!] No (*.iso) file loaded")
            }

            ElseIf ($This.Generation -eq 2)
            {
                $This.SetVmBootOrder(2,0,1)
            }
        }
        TypeChain([UInt32[]]$Array)
        {
            ForEach ($Key in $Array)
            {
                $This.TypeKey($Key)
                Start-Sleep -Milliseconds 125
            }
        }
        TypeKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Typing key : [$Index]")
            $This.Keyboard.TypeKey($Index)
            Start-Sleep -Milliseconds 125
        }
        TypeText([String]$String)
        {
            $This.Update(0,"[+] Typing text : [$String]")
            $This.Keyboard.TypeText($String)
            Start-Sleep -Milliseconds 125
        }
        TypePassword([String]$Pass)
        {
            $This.Update(0,"[+] Typing password : [ActualPassword]")
            $This.Keyboard.TypeText($Pass)
            Start-Sleep -Milliseconds 125
        }
        PressKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Pressing key : [$Index]")
            $This.Keyboard.PressKey($Index)
        }
        ReleaseKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Releasing key : [$Index]")
            $This.Keyboard.ReleaseKey($Index)
        }
        SpecialKey([UInt32]$Index)
        {
            $This.Keyboard.PressKey(18)
            $This.Keyboard.TypeKey($Index)
            $This.Keyboard.ReleaseKey(18)
        }
        TypeCtrlAltDel()
        {
            $This.Update(0,"[+] Typing (CTRL + ALT + DEL)")
            $This.Keyboard.TypeCtrlAltDel()
        }
        Idle([UInt32]$Percent,[UInt32]$Seconds)
        {
            $This.Update(0,"[~] Idle : $($This.Name) [CPU <= $Percent% for $Seconds second(s)]")
            
            $C = 0
            Do
            {
                Switch ([UInt32]($This.Get().CpuUsage -le $Percent))
                {
                    0 { $C = 0 } 1 { $C ++ }
                }

                Start-Sleep -Seconds 1
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Idle complete")
        }
        Uptime([UInt32]$Seconds)
        {
            $This.Update(0,"[~] Uptime : $($This.Name) [Uptime <= $Seconds second(s)]")
            
            Do
            {
                Start-Sleep -Seconds 1
            }
            Until ($This.Get().Uptime.TotalSeconds -le $Seconds)

            $This.Update(1,"[+] Uptime complete")
        }
        Timer([UInt32]$Seconds)
        {
            $This.Update(0,"[~] Timer : $($This.Name) [Span = $Seconds]")

            $C = 0
            Do
            {
                Start-Sleep -Seconds 1
                $C ++
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Timer")
        }
        Connection()
        {
            $This.Update(0,"[~] Connection : $($This.Name) [Await response]")

            Do
            {
                Start-Sleep 1
            }
            Until (Test-Connection $This.Network.Address -EA 0)

            $This.Update(1,"[+] Connection")
        }
        SetAdmin([Object]$Admin)
        {
            $This.Update(0,"[~] Setting : Administrator password")
            ForEach ($X in 0..1)
            {
                $This.TypePassword($Admin.Password())
                $This.TypeKey(9)
                Start-Sleep -Milliseconds 125
            }

            $This.TypeKey(9)
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        Login([Object]$Admin)
        {
            $This.Update(0,"[~] Login : Administrator")
            $This.TypeCtrlAltDel()
            $This.Timer(5)
            $This.TypePassword($Admin.Password())
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        [Object] GetNetworkConfig()
        {
            $This.Update(0,"[~] Getting Network Configuration")
            $Cfg  = Get-NetIPConfiguration -Detailed | ? InterfaceAlias -match $This.SwitchName[0]
            $Item = [NetworkInformation]::New($Cfg)

            ForEach ($Prop in $Item.PSObject.Properties)
            {
                $This.Update(1,"[+] $($Prop.Name.PadRight(8," ")) : $($Prop.Value)")
            }

            Return $Item
        }
        SetSystemInfo()
        {
            $B          = @( )

            # Set Computer Info
            $B += '# Set Computer Info'
            $B += '$ComputerName   = "{0}"' -f $This.Name
            $B += '$TrustedHost    = "{0}"' -f $This.Network.Trusted
            $B += '$IPAddress      = "{0}"' -f $This.Network.Address
            $B += '$PrefixLength   = "{0}"' -f $This.Network.Prefix
            $B += '$DefaultGateway = "{0}"' -f $This.Network.Gateway
            $B += '$DnsAddress     = "{0}"' -f $This.Network.Dns
            $B += ''

            # Enable ICMPv4
            $B += '# Enable ICMPv4'
            $B += 'Get-NetFirewallRule | ? Description -match "(Printer.+ICMPv4)" | Enable-NetFirewallRule'
            $B += ''

            # Get InterfaceIndex, get/remove current (IP address + Net Route)
            $B += '# Get InterfaceIndex, get/remove current (IP address + Net Route)'
            $B += '$Index = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex'
            $B += '$Interface = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $Index'
            $B += '$Interface | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$False -Verbose'
            $B += '$Interface | Remove-NetRoute     -AddressFamily IPv4 -Confirm:$False -Verbose'
            $B += ''
            
            # Splat static IP Address
            $B += '# Splat static IP Address'
            $B += '$Splat             = @{'
            $B += ' '
            $B += '    InterfaceIndex = $Index'
            $B += '    AddressFamily  = "IPv4"'
            $B += '    PrefixLength   = $PrefixLength'
            $B += '    ValidLifetime  = [Timespan]::MaxValue'
            $B += '    IPAddress      = $IPAddress'
            $B += '    DefaultGateway = $DefaultGateway'
            $B += '}'
            $B += ''

            # Assign (static IP Address + Dns server)
            $B += '# Assign (static IP Address + Dns server)'
            $B += 'New-NetIPAddress @Splat'
            $B += 'Set-DnsClientServerAddress -InterfaceIndex $Index -ServerAddresses $DnsAddress'
            $B += ''

            # Assign to script, and process each line
            $B | % { $This.Script += $_ }

            ForEach ($Line in $B)
            {
                $This.TypeText($Line)
                If ($Line.Length -eq 0)
                {
                    $This.Idle(5,2)
                }
                Else
                {
                    $This.TypeKey(13)
                }
            }
        }
        SetWinRM()
        {
            # Enable WinRM/Remote management, Add TrustedHost
            $This.TypeText('winrm quickconfig')
            $This.TypeKey(13)

            $This.Timer(2)
            $This.TypeKey(89)
            $This.Timer(2)

            $This.TypeText('Set-Item WSMan:\localhost\Client\TrustedHosts -Value $TrustedHost')
            $This.TypeKey(13)
        }
        InstallFightingEntropy()
        {
            # Set (service point manager/TLS), execution policy
            $B += '# Set (service point manager/TLS), execution policy'
            $B += '[Net.ServicePointManager]::SecurityProtocol = 3072'
            $B += 'Set-ExecutionPolicy Bypass -Scope Process -Force'
            $B += ''

            # (Download/Instantiate/Execute/Import) FightingEntropy
            $B += '# (Download/Instantiate/Execute/Import) FightingEntropy'
            $B += '$Install = "https://github.com/mcc85s/FightingEntropy"'
            $B += '$Full    = "$Install/blob/main/Version/2022.12.0/FightingEntropy.ps1?raw=true"'
            $B += 'Invoke-RestMethod $Full | Invoke-Expression'
            $B += '$Module.Install()'
            $B += 'Import-Module FightingEntropy'
            $B += ''

            $B | % { $This.Script += $_ }

            ForEach ($Line in $B)
            {
                $This.TypeText($Line)
                If ($Line.Length -eq 0)
                {
                    $This.Idle(5,2)
                }
                Else
                {
                    $This.TypeKey(13)
                }
            }
        }
        RenameRestart()
        {
            # (Rename + restart) computer
            $B += '# (Rename + restart) computer'
            $B += 'Rename-Computer $ComputerName'
            $B += 'Restart-Computer'

            $B | % { $This.Script += $_ }

            ForEach ($Line in $B)
            {
                $This.TypeText($Line)
                If ($Line.Length -eq 0)
                {
                    $This.Idle(5,2)
                }
                Else
                {
                    $This.TypeKey(13)
                }
            }
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [Object] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [String] LogPath()
        {
            $xPath = $This.ProgramData()

            ForEach ($Folder in $This.Author(), "Logs")
            {
                $xPath = $xPath, $Folder -join "\"
                If (![System.IO.Directory]::Exists($xPath))
                {
                    [System.IO.Directory]::CreateDirectory($xPath)
                }
            }

            Return $xPath
        }
        DumpConsole()
        {
            $This.Console.Finalize()
            $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
            $This.Update(99,"[+] Dumping console: [$xPath]")
            
            $Value = $This.Console.Output | % ToString

            [System.IO.File]::WriteAllLines($xPath,$Value)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // Initial information
    $Admin    = [AdminCredential]::New("Administrator")
    $Name     = "server01"
    $Base     = "C:\VDI"
    $Memory   = 2048MB
    $Hdd      = 64GB
    $Gen      = 2
    $Core     = 2
    $SwitchID = "External"
    $Image    = "C:\Images\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

    # // Object instantiation
    $Vm       = [VmObjectNode]::New(1,$Name,$Base,$Memory,$Hdd,$Gen,$Core,$SwitchID)
    $Vm.New()
    $Vm.AddVmDvdDrive()
    $Vm.LoadIso($Image)
    $Vm.SetIsoBoot()
    $Vm.Connect()

    # // Start Machine
    $Vm.Start()
    $Vm.Control  = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $Vm.Name
    $Vm.Keyboard = Get-WmiObject -Query "ASSOCIATORS OF {$($Vm.Control.Path.Path)} WHERE resultClass = Msvm_Keyboard" -NS Root\Virtualization\V2

    # // Wait for "Press enter to boot from CD/DVD", then press enter
    $Vm.Timer(2)
    $Vm.TypeKey(13)

    # // Wait for "Install Windows" menu
    $Vm.Idle(5,2)

    # // Enter menu
    $Vm.TypeKey(13)
    $Vm.Timer(5)
    $Vm.TypeKey(13)

    # // Wait to select installation
    $Vm.Idle(5,5)

    # // Select installation
    $Vm.TypeChain(@(40,40,40,13))

    # // Wait to accept license terms
    $Vm.Idle(5,2)

    # // Accept license terms
    $Vm.TypeChain(@(32,9,9,9,9,13))

    # // Wait Windows Setup
    $Vm.Idle(5,2)

    # // Windows Setup
    $Vm.SpecialKey(67)

    # // Wait partition
    $Vm.Idle(5,2)

    # // Set partition
    $Vm.SpecialKey(78)

    # // Wait until Windows installation completes
    $Vm.Idle(5,5)

    # // Catch and release ISO upon reboot
    $Vm.Uptime(5)
    $Vm.UnloadIso()

    # // Wait for the login screen
    $Vm.Idle(5,8)

    # // Establish administrator account
    $Vm.SetAdmin($Admin)

    # Wait for actual login
    $Vm.Idle(5,5)

    # Enter (CTRL + ALT + DEL) to sign into Windows
    $Vm.Login($Admin)

    # Wait for operating system to do [FirstRun/FirstLogin] stuff
    $Vm.Idle(5,5)

    # Press enter for Network to allow pc to be discoverable
    $Vm.TypeKey(13)

    # Open Start Menu
    $Vm.TypeKey(91)
    $Vm.Timer(3)

    # Launch task manager
    $Vm.TypeText("taskmgr")
    $Vm.Timer(3)
    $Vm.TypeKey(13)
    $Vm.Timer(1)
    
    # [D]etails
    $Vm.SpecialKey(68)
    $Vm.Timer(2)

    # [F]ile
    $Vm.SpecialKey(70)
    $Vm.Timer(2)

    # New Task
    $Vm.TypeKey(13)
    $Vm.Timer(2)

    # Launch PowerShell w/ Administrative privileges
    $Vm.TypeText("PowerShell")
    $Vm.Timer(1)
    $Vm.TypeChain(@(9,32,9,13))

    # Wait for PowerShell engine to get ready for input
    $Vm.Idle(5,5)

    # Set System Info
    $Vm.SetSystemInfo()

    # Wait until connection is successful
    $Vm.Connection()
    
    # Set WinRM
    $Vm.SetWinRM()


    # Wait for reset
    $Vm.Idle(5,5)
