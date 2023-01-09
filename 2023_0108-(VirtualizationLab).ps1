
    # [Objective]: Get (2) virtual servers to work together as an Active Directory domain controller cluster
    # by using [FightingEntropy(π)] Get-FEDCPromo.

    # Be really clever about it, too.
    # Use a mixture of virtualization, graphic design, networking, and programming...
    # ...to show everybody and their mother...
    # ...that you're an expert.

    # Even the guys at Microsoft will think this shit is WICKED cool...
    # https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0103-(Get-FEDCPromo).pdf

    $Pass   = Read-Host "Enter password" -AsSecureString
    $Cred   = [PSCredential]::New("Administrator",$Pass)

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
        VmObjectNode([String]$Name)
        {
            $This.Name               = $Name
        }
        Stage([String]$Path,[UInt64]$Memory,[UInt64]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
        {
            $This.Memory             = $This.Size("Memory",$Memory)
            $This.Path               = "$Path\$($This.Name)"
            $This.Vhd                = "$Path\$($This.Name)\$($This.Name).vhdx"
            $This.VhdSize            = $This.Size("HDD",$HDD)
            $This.Generation         = $Generation
            $This.Core               = $Core
            $This.SwitchName         = @($Switch)
            $This.Exists             = 0
            $This.Guid               = $Null
        }
        [Object] Size([String]$Name,[UInt64]$SizeBytes)
        {
            Return [Size]::New($Name,$SizeBytes)
        }
        [Object] Get()
        {
            $Vm     = Get-VM -Name $This.Name -EA 0
            Return @(0,$Vm)[$Vm.Count]
        }
        New()
        {
            $Vm = $This.Get()
            If (!!$Vm)
            {
                Throw "[!] Virtual machine : $($This.Name) [exists]"
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

            New-VM @Object -Verbose
            $This.Firmware         = $This.GetVmFirmware()
            $This.Exists           = 1
            $This.SetVMProcessor()
        }
        Start()
        {
            $Vm = $This.Get()
            If ($Vm)
            {
                $Vm | ? State -ne Running | Start-VM -Verbose
            }
        }
        Remove()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                Throw "Invalid virtual machine"
            }

            If ($Vm.State -ne "Off")
            {
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

            $This.Get()            | Remove-VM -Force -Confirm:$False -Verbose
            $This.Firmware         = $Null
            $This.Exists           = 0
            
            Remove-Item $This.Vhd -Force -Verbose -Confirm:$False
            Remove-Item $This.Path -Force -Recurse -Verbose -Confirm:$False
            Remove-Item ($This.Path | Split-Path -Parent) -Force -Verbose -Confirm:$False
        }
        Stop()
        {
            Get-VM -Name $This.Name | ? State -ne Off | Stop-VM -Verbose -Force
        }
        Update()
        {
            $Vm = $This.Get()
            Switch (!$Vm)
            {
                0
                {
                    $This.Memory     = 0
                    $This.Path       = $Null
                    $This.Vhd        = $Null
                    $This.VhdSize    = 0
                    $This.Generation = $Null
                    $This.Core       = 0
                    $This.SwitchName = @( )
                    $This.Iso        = $Null
                    $This.Firmware   = $Null
                    $This.Exists     = 0
                    $This.Guid       = $Null
                }
                1
                {
                    $This.Memory     = $This.Size($Vm.MemoryStartup)
                    $This.Path       = $Vm.Path
                    $This.Vhd        = $Vm.HardDrives[0].Path
                    $This.VhdSize    = $This.Size((Get-Vhd -Path $This.Vhd).Size)
                    $This.Generation = $Vm.Generation
                    $This.Core       = $Vm.ProcessorCount
                    $This.SwitchName = $Vm.NetworkAdapters.SwitchName
                    $This.Firmware   = $This.GetVmFirmware()
                    $This.Exists     = 1
                    $This.Guid       = $Vm.Id
                }
            }
        }
        [Object] GetVmFirmware()
        {
            $Item = Switch ($This.Generation) 
            { 
                1 
                { 
                    Get-VMBios -VmName $This.Name 
                } 
                2 
                { 
                    Get-VmFirmware -VmName $This.Name
                } 
            }

            Return $Item
        }
        SetVmProcessor()
        {
            Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose
        }
        SetVmDvdDrive([String]$Path)
        {
            Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose
        }
        SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $This.GetVmFirmware() | % { Set-VMFirmware -VMName $This.Name -BootOrder $_.BootOrder[$1,$2,$3] }
        }
        AddVmDvdDrive()
        {
            Add-VmDvdDrive -VMName $This.Name -Verbose
        }
        LoadIso([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid ISO path"
            }

            Else
            {
                $This.Iso = $Path
                $This.SetVmDvdDrive($This.Iso)
            }
        }
        UnloadIso()
        {
            Set-VMDVDDrive -VMName $This.Name -Path $Null -Verbose
        }
        SetIsoBoot()
        {
            If (!$This.Iso)
            {
                Throw "No (*.iso) file loaded"
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

    Class KeyboardInterface
    {
        [String] $Name
        [Object] $Ctrl
        [Object]   $KB
        KeyboardInterface([String]$Name)
        {
            $This.Name = $Name
            $This.Ctrl = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $This.Name
            $This.Kb   = Get-WmiObject -Query "ASSOCIATORS OF {$($This.Ctrl.Path.Path)} WHERE resultClass = Msvm_Keyboard" -NS Root\Virtualization\V2
        }
        Stroke([Object]$Object)
        {
            If ($Object.Length -gt 1)
            {
                $Object = [Char[]]$Object
            }

            ForEach ($Key in $Object)
            {
                If ($Key -cin $This.Special() + $This.Capital())
                {
                    $This.KB.PressKey(16) | Out-Null
                    $This.KB.TypeKey($This.SKey["$Key"]) | Out-Null
                    $This.KB.ReleaseKey(16) | Out-Null
                }
                Else
                {
                    $This.KB.TypeKey($This.Key["$Key"]) | Out-Null
                }
    
                Start-Sleep -Milliseconds 50
            }
        }
        [Char[]] Capital()
        {
            Return [Char[]]"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        [Char[]] Lower()
        {
            Return [Char[]]"abcdefghijklmnopqrstuvwxyz"
        }
        [Char[]] Special()
        {
            Return [Char[]]")!@#$%^&*(:+<_>?~{|}`""
        }
        [Object] SKey([Char]$Key)
        {
            Return @{

               "A" =  65; "B" =  66; "C" =  67; "D" =  68; "E" =  69; "F" =  70; 
               "G" =  71; "H" =  72; "I" =  73; "J" =  74; "K" =  75; "L" =  76; 
               "M" =  77; "N" =  78; "O" =  79; "P" =  80; "Q" =  81; "R" =  82; 
               "S" =  83; "T" =  84; "U" =  85; "V" =  86; "W" =  87; "X" =  88;
               "Y" =  89; "Z" =  90; ")" =  48; "!" =  49; "@" =  50; "#" =  51; 
               "$" =  52; "%" =  53; "^" =  54; "&" =  55; "*" =  56; "(" =  57; 
               ":" = 186; "+" = 187; "<" = 188; "_" = 189; ">" = 190; "?" = 191; 
               "~" = 192; "{" = 219; "|" = 220; "}" = 221; '"' = 222 

            }[$Key]
        }
        [Object] Key([Char]$Key)
        {
            Return @{ 

                " " =  32; [Char]706 =  37; [Char]708 =  38; [char]707 =  39; [Char]709 =  40; 
                "0" =  48; "1" =  49; "2" =  50; "3" =  51; "4" =  52; "5" =  53; "6" =  54; 
                "7" =  55; "8" =  56; "9" =  57; "a" =  65; "b" =  66; "c" =  67; 
                "d" =  68; "e" =  69; "f" =  70; "g" =  71; "h" =  72; "i" =  73; 
                "j" =  74; "k" =  75; "l" =  76; "m" =  77; "n" =  78; "o" =  79; 
                "p" =  80; "q" =  81; "r" =  82; "s" =  83; "t" =  84; "u" =  85; 
                "v" =  86; "w" =  87; "x" =  88; "y" =  89; "z" =  90; ";" = 186; 
                "=" = 187; "," = 188; "-" = 189; "." = 190; "/" = 191; '`' = 192; 
                "[" = 219; "\" = 220; "]" = 221; "'" = 222;
            
            }[$Key]
        }
    }

    # // Initial information
    $Name   = "server02"
    $Path   = "C:\VDI"
    $Memory = 2048MB
    $Hdd    = 64GB
    $Gen    = 2
    $Core   = 2
    $Switch = "External"
    $Image  = "C:\Images\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

    # // Object instantiation
    $Vm     = [VmObjectNode]::New($Name)
    $Vm.Stage($Path,$Memory,$Hdd,$Gen,$Core,$Switch)
    $Vm.New()
    $Vm.AddVmDvdDrive()
    $Vm.LoadIso($Image)
    $Vm.SetIsoBoot()

    # Start Machine
    $Vm.Start()

    # // Use the keyboard class to automate the VM installation
    $Ctrl      = Get-WMIObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $Name
    $KB        = Get-WmiObject -Query "ASSOCIATORS OF {$($Ctrl.Path.Path)} WHERE resultClass = Msvm_Keyboard" -Namespace "root\virtualization\v2"

    # $Vm.Stop()
    Start-Sleep 2
    $Kb.PressKey(13)

    # Wait for menu
    Start-Sleep 10
    $Kb.PressKey(13)
    Start-Sleep 5
    $Kb.PressKey(13)

    # Wait to select installation
    Start-Sleep 10
    $Kb.PressKey(40)
    Start-Sleep -Milliseconds 250
    $Kb.PressKey(40)
    Start-Sleep -Milliseconds 250
    $Kb.PressKey(40)
    Start-Sleep -Milliseconds 250
    $Kb.PressKey(13)

    # Wait to accept license terms (off rails)
    Start-Sleep 3
    $KB.PressKey(32)
    Start-Sleep -Milliseconds 250
    $KB.PressKey(9)
    Start-Sleep -Milliseconds 250
    $KB.PressKey(9)
    Start-Sleep -Milliseconds 250
    $KB.PressKey(9)
    Start-Sleep -Milliseconds 250
    $KB.PressKey(9)
    Start-Sleep -Milliseconds 250
    $Kb.PressKey(13)

    # Windows Setup
    Start-Sleep 3
    $Kb.PressKey(18)
    $Kb.PressKey(67)

    Start-Sleep 3
    $Kb.PressKey(18)
    $Kb.PressKey(78)

    # Wait until Windows installation completes
    $C = @( )
    Do
    {
        $Item = $Vm.Get()
        If ($Item.CpuUsage -le 5)
        {
            $C += 1
        }
        Else
        {
            $C  = @( )
        }
        Start-Sleep 1
    }
    Until ($C.Count -ge 5)

    # When inactivity rises, it is about to reboot, catch it to release the ISO
    Do
    {
        $Item = $VM.Get()
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -le 5)
    $Vm.UnloadIso()

    # Waits for the login screen
    $C = @( )
    Do
    {
        $Item = $Vm.Get()
        If ($Item.CpuUsage -le 5)
        {
            $C += 1
        }
        Else
        {
            $C  = @( )
        }
        Start-Sleep 1
    }
    Until ($C.Count -ge 5)

    # Type somewhat secure password (2) times
    $Kb.TypeText($Cred.GetNetworkCredential().Password)
    $Kb.TypeKey(9)
    Start-Sleep -Milliseconds 250
    $Kb.TypeText($Cred.GetNetworkCredential().Password)
    $Kb.TypeKey(9)
    Start-Sleep -Miliseconds 250
    $Kb.TypeKey(9)
    Start-Sleep -Miliseconds 250
    $Kb.TypeKey(13)
    Start-Sleep 5

    # Enter CTRL + ALT + DEL to sign into Windows
    $Kb.TypeCtrlAltDel()
    Start-Sleep 5
    $Kb.TypeText($Cred.GetNetworkCredential().Password)
    Start-Sleep -Milliseconds 250
    $Kb.TypeKey(13)
    Start-Sleep 30

    # Press enter for Network to allow pc to be discoverable
    $Kb.TypeKey(13)
    Start-Sleep -Milliseconds 250

    # Open Start Menu
    $Kb.TypeKey(91)
    Start-Sleep 3

    # Enter task manager
    $Kb.TypeText("taskmgr")
    Start-Sleep 3
    $Kb.TypeKey(13)
    
    # More details
    $Kb.PressKey(18)
    $Kb.TypeKey(68)
    Start-Sleep 2

    # File
    $Kb.PressKey(18)
    $Kb.TypeKey(70)
    $Kb.ReleaseKey(18)
    Start-Sleep 2

    # New Task
    $Kb.TypeKey(13)
    Start-Sleep 2

    # Launch PowerShell w/ Administrative privileges
    $Kb.TypeText("PowerShell")
    Start-Sleep 1
    $Kb.TypeKey(9)
    Start-Sleep -Milliseconds 250
    $Kb.TypeKey(32)
    Start-Sleep -Milliseconds 250
    $Kb.TypeKey(9)
    Start-Sleep -Milliseconds 250
    $Kb.TypeKey(13)

    <# Begin scripting
       [don't proceed past this point, this stuff needs additional testing and it's hardware specific]

    "A" =  65; "B" =  66; "C" =  67; "D" =  68; "E" =  69; "F" =  70; 
    "G" =  71; "H" =  72; "I" =  73; "J" =  74; "K" =  75; "L" =  76; 
    "M" =  77; "N" =  78; "O" =  79; "P" =  80; "Q" =  81; "R" =  82; 
    "S" =  83; "T" =  84; "U" =  85; "V" =  86; "W" =  87; "X" =  88;
    "Y" =  89; "Z" =  90; ")" =  48; "!" =  49; "@" =  50; "#" =  51; 
    "$" =  52; "%" =  53; "^" =  54; "&" =  55; "*" =  56; "(" =  57; 
    ":" = 186; "+" = 187; "<" = 188; "_" = 189; ">" = 190; "?" = 191; 
    "~" = 192; "{" = 219; "|" = 220; "}" = 221; '"' = 222; "6" =  54; 
    " " =  32; [Char]706 =  37; [Char]708 =  38; [char]707 =  39; [Char]709 =  40; 
    "0" =  48; "1" =  49; "2" =  50; "3" =  51; "4" =  52; "5" =  53; 
    "7" =  55; "8" =  56; "9" =  57; "a" =  65; "b" =  66; "c" =  67; 
    "d" =  68; "e" =  69; "f" =  70; "g" =  71; "h" =  72; "i" =  73; 
    "j" =  74; "k" =  75; "l" =  76; "m" =  77; "n" =  78; "o" =  79; 
    "p" =  80; "q" =  81; "r" =  82; "s" =  83; "t" =  84; "u" =  85; 
    "v" =  86; "w" =  87; "x" =  88; "y" =  89; "z" =  90; ";" = 186; 
    "=" = 187; "," = 188; "-" = 189; "." = 190; "/" = 191; '`' = 192; 
    "[" = 219; "\" = 220; "]" = 221; "'" = 222;

    #>

    
    # Enable ICMPv4
    $Kb.TypeText('Get-NetFirewallRule | ? Description -match "(Printer.+ICMPv4)" | Enable-NetFirewallRule')
    $Kb.TypeKey(13)
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
