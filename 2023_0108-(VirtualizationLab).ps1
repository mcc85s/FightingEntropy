
    # Last edited : 2023-01-10 14:14:47
    # Purpose     : Automatically installs a Windows Server 2016 instance for configuration

    # [Objective]: Get (2) virtual servers to work together as an Active Directory domain controller cluster
    # by using [FightingEntropy(π)] Get-FEDCPromo.

    # Be really clever about it, too.
    # Use a mixture of virtualization, graphic design, networking, and programming...
    # ...to show everybody and their mother...
    # ...that you're an expert.

    # Even the guys at Microsoft will think this shit is WICKED cool...
    # https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0103-(Get-FEDCPromo).pdf

    $Pass = Read-Host "Enter password" -AsSecureString
    $Cred = [PSCredential]::New("Administrator",$Pass)

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
        Hidden [String]      $Iso
        Hidden [String]   $Script
        Hidden [Object] $Firmware
        [UInt32]          $Exists
        [Object]            $Guid
        Hidden [Object]  $Control
        Hidden [Object] $Keyboard
        VmObjectNode([String]$Name,[String]$Base,[UInt64]$Memory,[UInt64]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
        {
            $This.Mode = 1
            $This.StartConsole()

            $Item = Get-VM -Name $Name -EA 0
            If ($Item)
            {
                $This.Console.Update(0,"[!] Virtual machine: $Name [exists]")
                Throw $This.Console.Last().String
            }

            $This.Name               = $Name
            $This.Memory             = $This.Size("Memory",$Memory)
            $This.Path               = "$Base\$($This.Name)"
            $This.Vhd                = "$Base\$($This.Name)\$($This.Name).vhdx"
            $This.VhdSize            = $This.Size("HDD",$HDD)
            $This.Generation         = $Generation
            $This.Core               = $Core
            $This.SwitchName         = @($Switch)
            $This.Exists             = 0
            $This.Guid               = $Null
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
                $This.Update(-1,"[!] Exists : $($This.Name)")
                Throw $This.Console.Last().String
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
            New-VM @Object -Verbose

            $This.Firmware         = $This.GetVmFirmware()
            $This.Exists           = 1
            $This.SetVMProcessor()
        }
        Start()
        {
            $Vm = $This.Get()
            If (!!$Vm)
            {
                If ($Vm.State -ne "Running")
                {
                    $This.Update(1,"[~] Starting : $($This.Name)")
                    $Vm | Start-VM -Verbose
                }
            }
            ElseIf (!$Vm)
            {
                $This.Update(-1,"[!] Exception : $($This.Name) [does not exist]")
                Throw $This.Console.Last().String
            }
        }
        Remove()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Update(-1,"[!] Exception : $($This.Name) [does not exist]")
                Throw $this.Console.Last().String
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

            $This.Get() | Remove-VM -Force -Confirm:$False -Verbose
            $This.Firmware         = $Null
            $This.Exists           = 0
 
            $This.Update(0,"[~] Vhd  : [$($This.Vhd)]")
            Remove-Item $This.Vhd -Force -Verbose -Confirm:$False

            $This.Update(0,"[~] Path : [$($This.Path)]")
            ForEach ($Item in Get-ChildItem $This.Path -Recurse)
            {
                $This.Update(0,"[~] $($Item.Fullname)")
                Remove-Item $Item.Fullname -Confirm:$False
            }
        }
        Stop()
        {
            $This.Update(0,"[~] Stopping : $($This.Name)")
            $This.Get() | ? State -ne Off | Stop-VM -Verbose -Force
        }
        [Object] GetVmFirmware()
        {
            $This.Update(0,"[~] Getting VmFirmware : $($This.Name)")
            $Item = Switch ($This.Generation) 
            { 
                1 
                { 
                    Get-VmBios -VmName $This.Name 
                } 
                2 
                { 
                    Get-VmFirmware -VmName $This.Name
                } 
            }

            Return $Item
        }
        TypeKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Typing key : [$Index]")
            $This.Keyboard.TypeKey($Index)
        }
        TypeText([String]$String)
        {
            $This.Update(0,"[+] Typing text : [$String]")
            $This.Keyboard.TypeText($String)
        }
        TypePassword([String]$Pass)
        {
            $This.Update(0,"[+] Typing password : [ActualPassword]")
            $This.Keyboard.TypeText($Pass)
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
        SetVmProcessor()
        {
            $This.Update(0,"[~] Setting VmProcessor (Count): [$($This.Core)]")
            Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose
        }
        SetVmDvdDrive([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Update(-1,"[!] Invalid path : [$Path]")
                Throw $This.Console.Last().String
            }

            $This.Update(0,"[~] Setting VmDvdDrive (Path): [$Path]")
            Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose
        }
        SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $This.Update(0,"[~] Setting VmFirmware (Boot order) : [$1,$2,$3]")
            $This.GetVmFirmware() | % { Set-VMFirmware -VMName $This.Name -BootOrder $_.BootOrder[$1,$2,$3] }
        }
        AddVmDvdDrive()
        {
            $This.Update(0,"[+] Adding VmDvdDrive()")
            Add-VmDvdDrive -VMName $This.Name -Verbose
        }
        LoadIso([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Update(-1,"[!] Invalid ISO path : [$Path]")
                Throw $This.Console.Last().String
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
            Set-VmDvdDrive -VMName $This.Name -Path $Null -Verbose
        }
        SetIsoBoot()
        {
            If (!$This.Iso)
            {
                $This.Update(-1,"[!] No (*.iso) file loaded")
                Throw $This.Console.Last().String
            }

            ElseIf ($This.Generation -eq 2)
            {
                $This.SetVmBootOrder(2,0,1)
            }
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Function Wait-Idle ([Object]$Vm,[UInt32]$Percent,[UInt32]$Count)
    {
        $Vm.Update(0,"[~] Wait condition : $($Vm.Name), [CpuUsage : -le $Percent % | Seconds : $Count]")
        $C = 0
        Do
        {
            Switch ([UInt32]($Vm.Get().CpuUsage -le $Percent))
            {
                0 { $C = 0 } 1 { $C ++ }
            }

            Start-Sleep 1
        }
        Until ($C -ge $Count)
        $Vm.Update(1,"[+] Wait condition : Succeeded")
    }

    Function Wait-Uptime ([Object]$Vm,[UInt32]$Count)
    {
        $Vm.Update(0,"[~] Wait condition : $($Vm.Name), [Uptime : -le $Count seconds]")
        Do
        {
            Start-Sleep 1
        }
        Until ($Vm.Get().Uptime.TotalSeconds -le $Count)
        $Vm.Update(0,"[~] Wait condition : Succeeded")
    }

    # // Initial information
    $Name   = "server02"
    $Base   = "C:\VDI"
    $Memory = 2048MB
    $Hdd    = 64GB
    $Gen    = 2
    $Core   = 2
    $Switch = "External"
    $Image  = "C:\Images\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

    # // Object instantiation
    $Vm     = [VmObjectNode]::New($Name,$Base,$Memory,$Hdd,$Gen,$Core,$Switch)
    $Vm.New()
    $Vm.AddVmDvdDrive()
    $Vm.LoadIso($Image)
    $Vm.SetIsoBoot()
    $Vm.Connect()

    # // Start Machine
    $Vm.Start()
    $Vm.Control  = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $Vm.Name
    $Vm.Keyboard = Get-WmiObject -Query "ASSOCIATORS OF {$($Vm.Control.Path.Path)} WHERE resultClass = Msvm_Keyboard" -NS Root\Virtualization\V2

    # $Vm.Stop()
    Start-Sleep 2
    $Vm.TypeKey(13)

    # Wait for menu
    Wait-Idle $Vm 5 2

    # Enter Menu
    $Vm.TypeKey(13)
    Start-Sleep 5
    $Vm.TypeKey(13)

    # Wait to select installation
    Wait-Idle $Vm 5 5

    # Select installation
    40,40,40,13 | % {

        $Vm.TypeKey($_)
        Start-Sleep -Milliseconds 250
    }

    # Wait to accept license terms
    Wait-Idle $Vm 5 2

    # Accept license terms
    32,9,9,9,9,13 | % {

        $Vm.TypeKey($_)
        Start-Sleep -Milliseconds 250
    }

    # Wait Windows Setup
    Wait-Idle $Vm 5 2

    # Windows Setup
    $Vm.SpecialKey(67)

    # Wait partition
    Wait-Idle $Vm 5 2

    # Set partition
    $Vm.SpecialKey(78)

    # Wait until Windows installation completes
    Wait-Idle $Vm 5 5

    # When inactivity rises, it is about to reboot, catch and release ISO
    Wait-Uptime $Vm 5
    $Vm.UnloadIso()

    # Wait for the login screen
    Wait-Idle $Vm 5 10

    # Administrator creation, type somewhat secure password (2) times (or else)
    0..1 | % {

        $Vm.TypePassword($Cred.GetNetworkCredential().Password)
        $Vm.TypeKey(9)
        Start-Sleep -Milliseconds 250
    }
    
    $Vm.TypeKey(9)
    Start-Sleep -Milliseconds 250
    $Vm.TypeKey(13)

    # Wait for actual login
    Wait-Idle $Vm 5 5

    # Enter (CTRL + ALT + DEL) to sign into Windows
    $Vm.TypeCtrlAltDel()
    Start-Sleep 5
    $Vm.TypePassword($Cred.GetNetworkCredential().Password)
    Start-Sleep -Milliseconds 250
    $Vm.TypeKey(13)

    # Wait for operating system to do [FirstRun/FirstLogin] stuff
    Wait-Idle $Vm 5 5

    # Press enter for Network to allow pc to be discoverable
    $Vm.TypeKey(13)
    Start-Sleep -Milliseconds 250

    # Open Start Menu
    $Vm.TypeKey(91)
    Start-Sleep 3

    # Launch task manager
    $Vm.TypeText("taskmgr")
    Start-Sleep 3
    $Vm.TypeKey(13)
    Start-Sleep 1
    
    # [D]etails
    $Vm.SpecialKey(68)
    Start-Sleep 2

    # [F]ile
    $Vm.SpecialKey(70)
    Start-Sleep 2

    # New Task
    $Vm.TypeKey(13)
    Start-Sleep 2

    # Launch PowerShell w/ Administrative privileges
    $Vm.TypeText("PowerShell")
    Start-Sleep 1

    ForEach ($Key in 9,32,9,13)
    {
        $Vm.TypeKey($Key)
        Start-Sleep -Milliseconds 250
    }

    # Begin scripting

    # Enable ICMPv4
    $Vm.TypeText('Get-NetFirewallRule | ? Description -match "(Printer.+ICMPv4)" | Enable-NetFirewallRule')
    $Vm.TypeKey(13)
    Start-Sleep 3

    # IPConfig info
    $Kb.TypeText('$IPAddress      = "192.168.1.105"')
    $Kb.TypeKey(13)

    $Kb.TypeText('$DefaultGateway = "192.168.1.1"')
    $Kb.TypeKey(13)

    $Kb.TypeText('$DnsAddress     = $DefaultGateway')
    $Kb.TypeKey(13)

    # Get InterfaceIndex
    $Kb.TypeText('$InterfaceIndex = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex')
    $Kb.TypeKey(13)

    # Get current IP address (if any), and remove it
    $Kb.TypeText('Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $InterfaceIndex | Remove-NetIPAddress -Confirm:$False -Verbose')
    $Kb.TypeKey(13)

    # Get current Net Route (if any), and remove it
    $Kb.TypeText('Remove-NetRoute -InterfaceIndex $InterfaceIndex -Confirm:$False')
    $Kb.TypeKey(13)

    # Splat static IP Address
    $Kb.TypeText('$Splat = @{')
    $Kb.TypeKey(13)

    $Kb.TypeText('InterfaceIndex = $InterfaceIndex')
    $Kb.TypeKey(13)

    $Kb.TypeText('IPAddress = $IPAddress')
    $Kb.TypeKey(13)

    $Kb.TypeText('PrefixLength   = 24')
    $Kb.TypeKey(13)

    $Kb.TypeText('DefaultGateway = $DefaultGateway }')
    $Kb.TypeKey(13)

    # Assign static IP Address
    $Kb.TypeText('New-NetIPAddress @Splat')
    $Kb.TypeKey(13)

    # DnsAddress
    $Kb.TypeText('Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $DnsAddress')
    $Kb.TypeKey(13)

    # Service Point Manager/TLS
    $Kb.TypeText('[Net.ServicePointManager]::SecurityProtocol = 3072')
    $Kb.TypeKey(13)

    # Set Execution Policy 
    $Kb.TypeText('Set-ExecutionPolicy Bypass -Scope Process -Force')
    $Kb.TypeKey(13)
    
    # Download FightingEntropy
    $Kb.TypeText('Invoke-RestMethod github.com/mcc85s/FightingEntropy/blob/main/Version/2022.12.0/FightingEntropy.ps1?raw=true | iex')
    $Kb.TypeKey(13)

    # Install FightingEntropy
    $Kb.TypeText('$Module.Install()')
    $Kb.TypeKey(13)

    # Import FightingEntropy
    $Kb.TypeText('Import-Module FightingEntropy')
    $Kb.TypeKey(13)

    # Rename computer
    $Kb.TypeText('Rename-Computer $Name')
    $Kb.TypeKey(13)

    # Restart
    $Kb.TypeText('Restart-Computer')
    $Kb.TypeKey(13)

    

    # Desktop
    $Kb.PressKey(91)
    $Kb.TypeKey(68)
    $Kb.ReleaseKey(91)

    # FightingEntropy icon
    $Kb.TypeKey(40)
    
    $Kb.TypeKey(13)
    Start-Sleep 20
    
    $Kb.TypeKey(9)
    $Kb.TypeKey(27)

    $Kb.TypeKey(13)

    $Kb.TypeText("Rename-Computer $Name")
    $Kb.TypeKey(13)

    $Kb.TypeText("Restart-Computer")
    $Kb.TypeKey(13)


    # Enter CTRL + ALT + DEL to sign into Windows
    $Kb.TypeCtrlAltDel()
    Start-Sleep 5
    $Kb.TypeText($Cred.GetNetworkCredential().Password)
    Start-Sleep -Milliseconds 250
    $Kb.TypeKey(13)
    Start-Sleep 30
