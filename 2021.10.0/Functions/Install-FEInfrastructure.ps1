$Path        = Get-ChildItem $home\desktop | ? Name -match "(\d{8})" | % Fullname
$GW          = Get-ChildItem $Path\GW | % FullName
$SR          = Get-ChildItem $Path\SR | % FullName
Import-Module FightingEntropy
$Cred2       = Get-Credential

ForEach ( $X in 0..($GW.Count - 1 ))
{
    # $X = 6
    $Vm0         = Get-Content "$($Gw[$X])\vmx.txt" | ConvertFrom-Json
    $Mx0         = Get-Content "$($Gw[$X])\host.txt" | ConvertFrom-Json
    $Cred0       = Import-CliXml "$($Gw[$X])\cred.txt"
    $User0       = $Cred0.Username
    $Pass0       = $Cred0.GetNetworkCredential().Password
    $VMDisk0     = $Vm0.NewVHDPath
    $Id0         = $Vm0.Name
                
    $Vm1         = Get-Content "$($Sr[$X])\vmx.txt" | ConvertFrom-Json
    $Mx1         = Get-Content "$($Sr[$X])\host.txt" | ConvertFrom-Json
    $Cred1       = Import-CliXml "$($Sr[$X])\cred.txt"
    $User1       = $Cred1.Username
    $Pass1       = $Cred1.GetNetworkCredential().Password
    $VmDisk1     = $Vm1.NewVHDPath
    $Id1         = $Vm1.Name

    $Domain      = $Mx1.CN
    $Base        = $Mx1.SearchBase
    $Cfg         = "CN=Configuration,$Base"
    $DhcpOpt     = Get-DhcpServerV4OptionValue
    $External    = Get-NetAdapter | ? Name -match $Mx1.Vm.External.Name
    $Network     = $External | Get-NetRoute | ? DestinationPrefix -match "(\d+\.){3}\d+\/$($Vm1.Item.Prefix)" | % { $_.DestinationPrefix.Split("/")[0] }
    $DNS         = $External | Get-NetIPAddress | % IPAddress
    
    $Tx0         = [System.Diagnostics.Stopwatch]::StartNew()
    $Tx1         = [System.Diagnostics.StopWatch]::StartNew()
    $Lx0         = @{ }
    $Lx1         = @{ }      

    Start-VM $Id0 -Verbose
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] Starting [~] [$Id0]")
    Write-Host $Lx0[$Lx0.Count-1]

    $Ctrl0      = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $Id0
    $Kb0        = Get-WmiObject -Query "ASSOCIATORS OF {$($Ctrl0.Path.Path)} WHERE resultClass = Msvm_Keyboard" -Namespace "root\virtualization\v2"
    Start-Process vmconnect -ArgumentList ($Mx0.VM.Host.Name,$Vm0.Name)

    Start-VM $Id1 -Verbose
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)] Starting [~] [$Id1]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Ctrl1      = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $Id1
    $Kb1        = Get-WmiObject -Query "ASSOCIATORS OF {$($Ctrl1.path.path)} WHERE resultClass = Msvm_Keyboard" -Namespace "root\virtualization\v2"
    Start-Process vmconnect -ArgumentList ($Mx1.VM.Host.Name,$Vm1.Name)

    Do
    {
        $Item = Get-VM -Name $Id1
        Start-Sleep -Milliseconds 100 
    }
    Until ($Item.Uptime.TotalSeconds -ge 2)
    $Kb1.TypeKey(13)

    Start-Sleep 20

    0..2 | % { $Kb1.TypeKey(9); Start-Sleep -M 100 }
    $Kb1.TypeKey(13)
    Start-Sleep 1

    $Kb1.TypeKey(13)
    Start-Sleep 20

    40,40,40,40,9,13 | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }; Start-Sleep 5
    32,9,13,9,13     | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }; Start-Sleep 3
    9,9,9,9,13       | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }; Start-Sleep 1

    Do
    {
        $Item = Get-VM -Name $Id0
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][OPNSense [~] Initializing]")
        Write-Host $Lx0[$Lx0.Count-1]
        
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -gt 70)

    $C         = @( )
    Do
    {
        Start-Sleep -Seconds 1
                
        $Item     = Get-VM -Name $Id0
        Switch($Item.CPUUsage)
        {
            Default { $C  = @( ) } 0 { $C += 1 } 1 { $C += 1 }
        }
                
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNSense [~] Initializing [Inactivity:($($Sum))]")
        Write-Host $Lx0[$Lx0.Count-1]
    }
    Until($Sum -ge 35) # Manual assignment capture (35)
                
    # Manual Interface
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Configure VLans Now?
    Invoke-KeyEntry $Kb0 "n"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Enter WAN interface name
    Invoke-KeyEntry $Kb0 "hn0"
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Enter LAN Interface name
    Invoke-KeyEntry $Kb0 "hn1"
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Enter Optional interface name
    $Kb0.TypeKey(13)
    Start-Sleep 2
                
    # Proceed...?
    Invoke-KeyEntry $Kb0 "y"
    $Kb0.TypeKey(13)
                
    $C         = @( )
    Do
    {
        $Item     = Get-VM -Name $Id0
        Switch($Item.CPUUsage)
        {
            Default { $C  = @( ) } 0 { $C += 1 } 1 { $C += 1 }
        }
                
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNSense [~] Initializing [Inactivity:($($Sum))]")
        Write-Host $Lx0[$Lx0.Count-1]
                
        Start-Sleep -Seconds 1
    }
    Until($Sum -ge 50) # Initial login, must account for machine delay
                
    # Login
    Invoke-KeyEntry $Kb0 "installer"
    $Kb0.PressKey(13)
    Start-Sleep 1
                
    # Password
    Invoke-KeyEntry $Kb0 "opnsense"
    $Kb0.PressKey(13)
    Start-Sleep 3
                
    # Continue with default keymap
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] Accept defaults")
    Write-Host $Lx0[$Lx0.Count-1]
    Start-Sleep 2
                
    # Install (ZFS)
    $Kb0.TypeKey(40)
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] Install (ZFS)")
    Write-Host $Lx0[$Lx0.Count-1]
    Start-Sleep 8
                
    # ZFS Configuration (stripe)
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] ZFS Configuration (stripe)")
    Write-Host $Lx0[$Lx0.Count-1]
    Start-Sleep 2
                
    # Select a disk
    $Kb0.TypeKey(32)
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] Disk select")
    Write-Host $Lx0[$Lx0.Count-1]
    Start-Sleep 2
                
    # Install mode
    $Kb0.TypeKey(9)
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] Install mode")
    Write-Host $Lx0[$Lx0.Count-1]
                
    While ((Get-Item $VMDisk1).Length -lt 8.5GB)
    {
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][Installing [~] OPNSense 21.7]")
        Write-Host $Lx0[$Lx0.Count-1]
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Installing [~] Windows Server 2019][({0:n3}/8.500 GB)]" -f [Float]((Get-Item $VMDisk1).Length/1GB))
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep -Seconds 10
    }

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Finalizing [~] Windows Server 2019]")
    Write-Host $Lx1[$Lx1.Count-1]

    Do
    {
        $Item = Get-VM -Name $Id1
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)] [$Id1] [~] Finalizing...")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -le 5)
                
    # Disconnect DVD/ISO
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)] [~] Releasing DVD-ISO")
    Set-VMDvdDrive -VMName $Id1 -Path $Null -Verbose

    Do
    {
        $Item     = Get-VM -Name $Id0
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][Finalizing [~] OPNsense 21.7]")
        Write-Host $Lx0[$Lx0.Count-1]
                
        Start-Sleep -Seconds 1
    }
    Until((Get-Item $Item.HardDrives[0].Path).Length/1GB -gt 1.56)

    $C = 0
    Do
    {
        $Item     = Get-VM -Name $Id0
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][Finalizing [~] OPNsense 21.7][$C/200]")
        Write-Host $Lx0[$Lx0.Count-1]
        $C ++

        Start-Sleep -Seconds 1
    }
    Until($C -ge 200)

    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id0
        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 }
        }
                
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][Finalizing [~] OPNsense 21.7][Inactivity:($($Sum))]")
        Write-Host $Lx0[$Lx0.Count-1]
            
        Start-Sleep 1
    }
    Until ($Sum -ge 100)

    # Change root password
    $Kb0.TypeKey(40)
    Start-Sleep -M 100
    $Kb0.TypeKey(13)
    Start-Sleep 2
            
    # Enter root password
    Invoke-KeyEntry $Kb0 "$Pass0"
    $Kb0.TypeKey(13)
    Start-Sleep 1
            
    # Confirm root password
    Invoke-KeyEntry $Kb0 "$Pass0"
    $Kb0.TypeKey(13)
    Start-Sleep 1
            
    # Complete
    $Kb0.TypeKey(13)
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] Installed")
    Write-Host $Lx0[$Lx0.Count-1]

    Do
    {
        $Item = Get-VM -Name $Id0
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] [$Id0] [~] Rebooting...")
        Write-Host $Lx0[$Lx0.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -le 5)
            
    Stop-VM -Name $Id0 -Verbose -Force
            
    # Disconnect DVD/ISO
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] [~] Releasing DVD-ISO")
    Set-VMDvdDrive -VMName $Id0 -Path $Null -Verbose
            
    Start-VM -Name $Id0
    $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)] OPNsense [~] First boot...")
    Write-Host $Lx0[$Lx0.Count-1]

    # [Enter Password for the server]
    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(9)
    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(13)
    Start-Sleep 10
    
    $Kb1.TypeCtrlAltDel()
    Start-Sleep 5
    
    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(13)
    
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][First Login [@] ($(Get-Date))]")
    Write-Host $Lx1[$Lx1.Count-1]

    Do
    {
        $Item = Get-VM -Name $Id0
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][First Boot [~] OPNsense 21.7]")
        Write-Host $Lx0[$Lx0.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -ge 75)

    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id0
        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 }
        }
                
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
                
        $Lx0.Add($Lx0.Count,"[$($Tx0.Elapsed)][First Boot [~] OPNsense 21.7][Inactivity:($($Sum))]")
        Write-Host $Lx0[$Lx0.Count-1]
            
        Start-Sleep 1
    }
    Until ($Sum -ge 50)

    # [Final GW Config]
    Invoke-KeyEntry $Kb0 "root"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    Invoke-KeyEntry $Kb0 "$Pass0"
    $Kb0.TypeKey(13)
    Start-Sleep 3
                
    Invoke-KeyEntry $Kb0 "2"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    Invoke-KeyEntry $Kb0 "1"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Configure LAN via DHCP? (No)
    Invoke-KeyEntry $Kb0 "n"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # IPV4 Gateway (Subnet start address)
    Invoke-KeyEntry $Kb0 "$($Vm0.Item.Start)"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Subnet bit count/prefix (Subnet prefix)
    Invoke-KeyEntry $Kb0 "$($Vm0.Item.Prefix)"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Upstream gateway? (for WAN)
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # IPV6 WAN Tracking? (Can't hurt)
    Invoke-KeyEntry $Kb0 "y"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Enable DHCP? (No, save DHCP for Windows Server)
    Invoke-KeyEntry $Kb0 "n"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Revert to HTTP as the web GUI protocol? (No)
    Invoke-KeyEntry $Kb0 "n"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Generate a new self-signed web GUI certificate? (Yes)
    Invoke-KeyEntry $Kb0 "y"
    $Kb0.TypeKey(13)
    Start-Sleep 1
                
    # Restore web GUI defaults? (Yes)
    Invoke-KeyEntry $Kb0 "y"
    $Kb0.TypeKey(13)
    Start-Sleep 1

    # [Server Config]
    # For the 'join network' 
    $Kb1.TypeKey(27)
    Start-Sleep 2

    $Kb1.PressKey(18)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    $Kb1.TypeKey(27)
    Start-Sleep 2

    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(13)
    Start-Sleep 8
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    Start-Sleep 1

    $Kb1.TypeKey(13)
    Start-Sleep 1

    $Kb1.TypeKey(40)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(13)
    Start-Sleep 1
    
    $Kb1.PressKey(18)
    $Kb1.TypeKey(115)
    $Kb1.ReleaseKey(18)
    
    # Run PowerShell
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][PowerShell [~] Setup]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Kb1.PressKey(91)
    $Kb1.TypeKey(82)
    $Kb1.ReleaseKey(91)
    Start-Sleep 1
    $Kb1.TypeText("powershell")
    $Kb1.TypeKey(13)
    Start-Sleep 10

    $Kb1.TypeText("Set-DisplayResolution -Width 1440 -Height 900")
    $Kb1.TypeKey(13)
    Start-Sleep 12

    $Kb1.TypeText("y")
    $Kb1.TypeKey(13)
    Start-Sleep 3

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][PowerShell [~] Setup (IP/Gateway/DNS)]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Kb1.TypeText("`$ifIndex = Get-NetIPAddress -AddressFamily IPV4 | ? IPAddress -ne 127.0.0.1 | % InterfaceIndex;`$pfLength='$($Vm1.Item.Prefix)'")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    $Kb1.TypeText("`$Start = `"$($Vm1.Item.Start)`";`$Temp = `$Start.Split('.'); `$Temp[-1] = [UInt32]`$Temp[-1] + 1;")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    $Kb1.TypeText("`$Hash = @{ InterfaceIndex = `$ifIndex; AddressFamily='IPV4'; IPAddress=`$Temp -join '.'; PrefixLength=`$pfLength; DefaultGateway='$($Vm1.Item.Start)'}")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    $Kb1.TypeText("New-NetIPAddress @Hash -Verbose -EA 0")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    $Kb1.TypeText("Set-DNSclientServerAddress -InterfaceIndex `$ifIndex -ServerAddresses $DNS -Verbose;Start-Sleep 1")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    # [Start Internet Explorer]
    $Kb1.TypeText("`$IE = New-Object -ComObject InternetExplorer.Application")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    $Kb1.TypeText("`$IE.Visible = 1")
    $Kb1.TypeKey(13)
    Start-Sleep 3

    # [Alt/Tab]
    $Kb1.PressKey(18)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    # [Interact with Internet Explorer]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(76)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    $Kb1.TypeText("https://$($Vm1.Item.Start)")
    $Kb1.TypeKey(13)
    Start-Sleep 5

    # [Set up IE 11]
    $Kb1.TypeKey(13)
    Start-Sleep 15

    # [Close that default tab]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(87)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    # [More Information -> Enter Firewall]
    $Kb1.PressKey(16)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(16)
    Start-Sleep 1

    $Kb1.TypeKey(13)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(13)
    Start-Sleep 1

    $Kb1.TypeText("root")
    $Kb1.TypeKey(9)
    Start-Sleep 1

    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(13)
    Start-Sleep 1

    # [Disable remember password]
    9,9,9,13 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }

    # [Address bar]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(76)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    # [Navigate to wizard]
    $Kb1.TypeText("https://$($Vm1.Item.Start)/wizard.php?xml=system")
    $Kb1.TypeKey(13)
    Start-Sleep 3

    # [Select "Begin"]
    $Kb1.TypeKey(9)
    $Kb1.Presskey(16)
    9,9,9 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    Start-Sleep 3

    # [General Information]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..11 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeText($Vm1.Item.SiteLink)
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Vm1.Item.Sitename.Replace($Vm1.Item.Sitelink.ToLower()+'.',""))
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    If ( $DNS.getType().Name -notmatch "String\[\]" )
    {
        $Kb1.TypeText($DNS)
        $Kb1.TypeKey(9)
        $Kb1.TypeKey(9)
    }
    If ($DNS.getType().Name -match "String\[\]")
    {
        $Kb1.TypeText($DNS[0])
        $Kb1.TypeKey(9)
        $Kb1.TypeText($DNS[1])
        $Kb1.TypeKey(9)
    }
    32,9,9,9,9,32 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }
    Start-Sleep 2

    # [Time Server information]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..2 | % { $Kb1.TypeKey(9)}
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [WAN Interface (Keep set to DHCP, has a reservation tied to MAC address)]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..4 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    0..1 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [LAN Interface (Should be fine as is)]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..2 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [Set root password]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..2 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [Reload]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..2 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(32)
    Start-Sleep 10

    # [Get to firewall rules]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(76)
    $Kb1.ReleaseKey(17)
    Start-Sleep 2
    $Kb1.TypeText("https://$($Vm1.Item.Start)/firewall_rules.php?if=FloatingRules")
    Start-Sleep 1
    $Kb1.TypeKey(13)
    Start-Sleep 3

    # [Firewall Rules -> New Firewall Rule]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..7 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(13)
    Start-Sleep 4

    # [New Firewall rule]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..24 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    Start-Sleep 3

    $Kb1.TypeKey(38)
    $Kb1.TypeText("Network")
    $Kb1.TypeKey(13)
    Start-Sleep 1
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Network)
    Start-Sleep 1
    $Kb1.TypeKey(9)
    0..(32-([UInt32]$Vm1.Item.Prefix+1)) | % { $Kb1.TypeKey(40); Start-Sleep -M 200 }
    $Kb1.TypeKey(13)
    Start-Sleep 2

    0..20 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    Start-Sleep 1
    $Kb1.TypeKey(32)
    Start-Sleep 3

    # [Apply Firewall Rules]
    $Kb1.TypeKey(9)
    $Kb1.PressKey(16)
    0..13 | % { $Kb1.TypeKey(9); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(16)
    $Kb1.TypeKey(13)
    Start-Sleep 3

    # [Alt/Tab]
    $Kb1.PressKey(18)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    # [Kill IE11]
    $Kb1.TypeText("Get-Process -Name iexplore | Stop-Process")
    $Kb1.TypeKey(13)

    $Tx2 = [System.Diagnostics.Stopwatch]::StartNew()
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][PowerShell [~] Setup (FightingEntropy) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Kb1.TypeText("IRM github.com/mcc85s/FightingEntropy/blob/main/Install.ps1?raw=true | IEX")
    $Kb1.TypeKey(13)

    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id1

        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][PowerShell [~] Setup (FightingEntropy) ($($Tx2.Elapsed))][(Inactivity:$Sum/100)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 100)
    $Tx2.Reset()

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][System [~] (Hostname/Network/Domain) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
        
    $Kb1.PressKey(91)
    $Kb1.TypeKey(82)
    $Kb1.ReleaseKey(91)
    Start-Sleep 1
    $Kb1.TypeText("control panel")
    $Kb1.TypeKey(13)
    Start-Sleep 3
    $Kb1.PressKey(17)
    $Kb1.TypeKey(76)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1
    $Kb1.TypeText("Control Panel\System and Security\System")
    $Kb1.TypeKey(13)
    Start-Sleep 1
    $Kb1.TypeKey(32)
    Start-Sleep 1
    $Kb1.TypeText("[$Id1]://($($Vm1.Item.SiteLink))")
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)
    Start-Sleep 1
    $Kb1.TypeText($Id1)
    Start-Sleep 1
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)
    Start-Sleep 1
    $Kb1.TypeText($Mx1.CN)
    13,13,27,9,38,9 | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }
    $Kb1.TypeText($Mx1.CN)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(13)
    Start-Sleep 10
    $Kb1.TypeText("$User1@$Domain")
    $Kb1.TypeKey(9)
    Start-Sleep 1
    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(9)
    Start-Sleep 1

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][System [~] (Joining domain...) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
    $Kb1.TypeKey(13)
    Start-Sleep 25

    $Kb1.TypeKey(13)
    Start-Sleep 10

    $Kb1.TypeKey(13)
    Start-Sleep 1

    # [Alt + A] to apply
    $Kb1.PressKey(18)
    $Kb1.TypeKey(65)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    $Kb1.TypeKey(13)
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][System [+] (Hostname/Network/Domain) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
    $Tx2.Reset()

    # Wait for login
    Do
    {
        $Item = Get-VM -Name $Id1
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -lt 5)

    $Tx2.Start()
    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id1

        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Domain [~] First Login][(Inactivity:$Sum/100)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 100)

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Domain [+] (Joined to domain) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
    $Tx2.Reset()

    $Kb1.TypeCtrlAltDel()
    Start-Sleep 6
    9,9,9,13 | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }
    Start-Sleep 1

    $Kb1.TypeText("$User1@$Domain")
    $Kb1.TypeKey(9)
    Start-Sleep 1
    $Kb1.TypeText("$Pass1")
    $Kb1.TypeKey(13)
    Start-Sleep 35

    $Kb1.PressKey(91)
    $Kb1.TypeKey(82)
    $Kb1.ReleaseKey(91)
    Start-Sleep 2

    $Kb1.TypeText("%PUBLIC%\Desktop\FightingEntropy.lnk")
    $Kb1.TypeKey(13)
    Start-Sleep 8

    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(13)
    Start-Sleep 25

    $Kb1.TypeText("Stop-Process -Name ServerManager")
    $Kb1.TypeKey(13)

    # Install Dhcp
    $Kb1.TypeText("Get-WindowsFeature | ? Name -match DHCP | Install-WindowsFeature")
    $Kb1.TypeKey(13)

    Start-Sleep 120

    $Kb1.TypeText("`$Dhcp=@{StartRange=`"$($Vm1.Item.Start)`";EndRange=`"$($Vm1.Item.End)`";Name=`"$($Vm1.Item.Network)/$($Vm1.Item.Prefix)`";Description=`"$($Vm1.Item.Sitelink)`";SubnetMask=`"$($Vm1.Item.Netmask)`"}")
    $Kb1.TypeKey(13)

    # Add the Dhcp scope
    $Kb1.TypeText('Add-DhcpServerV4Scope @Dhcp -Verbose')
    $Kb1.TypeKey(13)
    Start-Sleep 2

    # Get NetIPConfig
    $Kb1.TypeText('$Config = Get-NetIPConfiguration -Detailed')
    $Kb1.TypeKey(13)
    Start-Sleep 10

    # [Get Router MacAddress]
    $Kb1.TypeText("`$ClientID = (arp -a | ? { `$_ -match '(dynamic|$($Vm1.Item.Start))'}).Substring(24,17).Replace('-','')")
    $Kb1.TypeKey(13)
    Start-Sleep 6

    # Set Initial DHCP Reservations
    $Kb1.TypeText("Add-DhcpServerv4Reservation -ScopeID $($Vm1.Item.Network) -IPAddress $($Vm1.Item.Start) -ClientID `$ClientID -Name Router -Verbose")
    $Kb1.TypeKey(13)
    Start-Sleep 4

    $Kb1.TypeText("Add-DhcpServerv4Reservation -ScopeID $($Vm1.Item.Network) -IPAddress `$Config.IPv4Address.IPAddress -ClientID `$Config.NetAdapter.LinkLayerAddress.Replace('-','').ToLower() -Name Server -Verbose")
    $Kb1.TypeKey(13)
    Start-Sleep 6

    # Set Dhcp Scope Options
    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 3 -Value `$Config.IPV4DefaultGateway.NextHop -Verbose") # (Router)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Value = ( $DhcpOpt | ? OptionID -eq 4 | % Value ) -join ','
    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 4 -Value $Value -Verbose") # (Time Servers)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Value = ( $DhcpOpt | ? OptionID -eq 5 | % Value ) -join ','
    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 5 -Value $Value -Verbose") # (Name Servers)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("`$Value = ( `$Config.DNSServer | ? AddressFamily -eq 2 | % ServerAddresses )")
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 6 -Value `$Value -Verbose") # (Dns Servers)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 15 -Value $($Mx1.CN) -Verbose") # (Dns Domain Name)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 28 -Value $($Vm1.Item.Broadcast) -Verbose") # (Broadcast Address)
    $Kb1.TypeKey(13)
    Start-Sleep 2
        
    $Kb1.TypeText("Set-DhcpServerv4OptionValue -OptionID 66 -Value `"$Id1.$($Mx1.CN)`" -Verbose") # (WDS Server Address)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Services [+] (Dhcp Configured) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
    $Tx2.Reset()

    $Kb1.TypeText("`$Module = Get-FEModule")
    $Kb1.TypeKey(13)

    $Kb1.TypeText("(`$Module.Classes | ? Name -match ServerFeature | Get-Content ) -join `"``n`" | IEX")
    $Kb1.TypeKey(13)

    # [Install Server Features]
    $Kb1.TypeText('[_ServerFeatures]::New().Output | ? { !($_.Installed) } | % { $_.Name.Replace("_","-") } | Install-WindowsFeature -Verbose')
    $Kb1.TypeKey(13)

    $C = 0
    Do
    {
        $Item = Get-VM -Name $Id1
        Start-Sleep 1
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Installing [~] (Adds/Rsat/Dhcp/Dns) Suite ($($Tx2.Elapsed))][(Timer:$C/180)]")
        Write-Host $Lx1[$Lx1.Count-1]

        $C ++
    }
    Until ($C -gt 180)

    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Installed [+] (Adds/Rsat/Dhcp/Dns) Suite ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]
    $Tx2.Reset()

    $Tx2.Start()
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Deploying [~] (Domain Controller) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Kb1.TypeText('Import-Module ADDSDeployment')
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("`$Pw = Read-Host 'Enter password' -AsSecureString")
    $Kb1.TypeKey(13)
    Start-Sleep 2

    Invoke-KeyEntry $Kb1 "$Pass1"
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("`$Credential=[System.Management.Automation.PSCredential]::New(`"$User1@$Domain`",`$Pw)")
    $Kb1.TypeKey(13)
    Start-Sleep 2

    $Kb1.TypeText("`$ADDS=@{NoGlobalCatalog=0;CreateDnsDelegation=0;Credential=`$Credential;CriticalReplicationOnly=0;DatabasePath='C:\Windows\NTDS';DomainName='$($Mx1.CN)';InstallDns=1;LogPath='C:\Windows\NTDS';NoRebootOnCompletion=0;SiteName='$($Vm1.Item.SiteLink)';SysVolPath='C:\Windows\SYSVOL';Force=1;SafeModeAdministratorPassword=`$Pw}")
    $Kb1.TypeKey(13)
    Start-Sleep 8

    $Kb1.TypeText("Install-ADDSDomainController @ADDS -Verbose")
    $Kb1.TypeKey(13)
    $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Deploying [~] (Domain Controller) ($($Tx2.Elapsed))]")
    Write-Host $Lx1[$Lx1.Count-1]

    $Tx2.Start()
    Do
    {
        $Item = Get-VM -Name $Id1
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Deploying [~] (Domain Controller) ($($Tx2.Elapsed))]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until($Item.Uptime.TotalSeconds -le 5)

    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id1

        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Booting [~] Domain Controller ($($Tx2.Elapsed))][(Inactivity:$Sum/100)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 100)

    

    $Kb1.TypeCtrlAltDel()
    Start-Sleep 10
    9,9,9,13 | % { $Kb1.TypeKey($_); Start-Sleep -M 100 }
    Start-Sleep 4

    $Kb1.TypeText("$User1@$Domain")
    $Kb1.TypeKey(9)
    Start-Sleep 1
    $Kb1.TypeText("$Pass1")
    $Kb1.TypeKey(13)
    Start-Sleep 25

    $Kb1.PressKey(91)
    $Kb1.TypeKey(82)
    $Kb1.ReleaseKey(91)
    Start-Sleep 2

    $Kb1.TypeText("%PUBLIC%\Desktop\FightingEntropy.lnk")
    $Kb1.TypeKey(13)
    Start-Sleep 8

    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(13)
    Start-Sleep 35

    $Kb1.TypeText("Stop-Process -Name ServerManager;`$Item='$($Vm1.Item | ConvertTo-Json)';Set-Content -Path `$Home\Desktop\server.txt -Value `$Item;start `$Env:Public\Desktop\FightingEntropy.lnk")
    $Kb1.TypeKey(13)

    $C = @( )
    Do
    {
        $Item = Get-VM -Name $Id1

        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 }
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Awaiting [~] Idle state ($($Tx2.Elapsed))][(Inactivity:$Sum/100)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 100)

    # [Shell 1]
    $Kb1.TypeText("Start-Sleep 10;`$Module = Get-FEModule;`$Module.Role.LoadEnvironmentKey(`"\\dsc0\FlightTest$\DSKey.csv`");Get-MDTModule;`$Module.Role.GetFeatures();Add-DHCPServerInDC;Add-DhcpServerSecurityGroup;Exit")
    $Kb1.TypeKey(13)
    Start-Sleep 2

    # [Shell 2]
    $Kb1.PressKey(18)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    $Kb1.TypeText("`$Images=`"\\dsc0\images`";")
    $Kb1.TypeText("`$Manifest=`"2021_0912-(FightingEntropy).txt`";"
    $Kb1.TypeText("`$Path=`"\\dsc0\images\2021_0912-(FightingEntropy).txt`";"
    $Kb1.TypeText("Get-FEImageManifest `$Images\`$Manifest `$Images C:\Images;")
    $Kb1.TypeText("`$Image=(Get-ChildItem C:\Images | ? Name -match 17763);")
    $Kb1.TypeText("Rename-Item `$Image.FullName -NewName `"Windows Server 2019.iso`";")
    $Kb1.TypeText("`$File=`"C:\Images\Windows Server 2019.iso`";")
    $Kb1.TypeText("Mount-DiskImage `$File;")
    $Kb1.TypeText('$Path="{0}:\sources\install.wim" -f (Get-DiskImage $File | Get-Volume | % DriveLetter);')
    $Kb1.TypeText("`$Group=(Get-Content `$home\desktop\server.txt | ConvertFrom-Json).SiteLink;")
    $Kb1.TypeText("`$ImageName=(Get-WindowsImage -ImagePath `$Path -Index 4 | % ImageName) -Replace `"Datacenter.+`",`"SERVERDATACENTER`";")
    $Kb1.TypeText("wdsutil /initialize-server /reminst:`"C:\RemoteInstall`";")
    $Kb1.TypeText("New-WDSInstallImageGroup -Name `$Group;")
    $Kb1.TypeText('64,86|%{irm "github.com/mcc85sx/FightingEntropy/blob/master/Boot/x$_/wdsmgfw.efi?raw=true" -Outfile "C:\RemoteInstall\Boot\x$_\wdsmgfw.efi"};')
    $Kb1.TypeText("Import-WDSInstallImage -ImageGroup `$Group -Path `$Path -ImageName `$ImageName -EA 0;")
    $Kb1.TypeKey(13)

    $C = @( )
    Do
    {
        $Item = Get-VM -VMName $Id1

        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][Image Server Setup [~] ($($Tx2.Elapsed))][Inactivity:($Sum/100)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 100)

    # [Configure WDS]
    $Kb1.TypeText("mmc")
    $Kb1.TypeKey(13)
    Start-Sleep 3

    $Kb1.PressKey(18)
    $Kb1.TypeKey(70)
    Start-Sleep 1
    $Kb1.TypeKey(77)
    $Kb1.ReleaseKey(18)
    Start-Sleep 4

    $Kb1.TypeKey(87)
    $Kb1.TypeKey(40)
    $Kb1.PressKey(18)
    $Kb1.TypeKey(65)
    $Kb1.ReleaseKey(18)
    $Kb1.TypeKey(13)
    Start-Sleep 3

    40,39,40,39,40,39,93,40,13 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }
    Start-Sleep 3

    # [General]
    39,9,40,40 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }
    $Kb1.PressKey(16)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(16)
    Start-Sleep 1

    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    # [Boot]
    $Kb1.PressKey(18)
    $Kb1.TypeKey(67)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1
    $Kb1.PressKey(18)
    $Kb1.TypeKey(80)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    # [Boot -> Multicast]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    # [Multicast (Speed)]
    $Kb1.PressKey(18)
    $Kb1.TypeKey(80)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    # [Multicast -> TFTP]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    Start-Sleep 1

    # [TFTP Block size]
    $Kb1.TypeText(16384)
    $Kb1.TypeKey(13)
    Start-Sleep 2

    # [Start Service]
    $Kb1.TypeKey(93)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(39)
    $Kb1.TypeKey(13)
    Start-Sleep 15

    # [OK]
    $Kb1.TypeKey(13)
    $Kb1.PressKey(18)
    $Kb1.TypeKey(115)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1

    # [Don't save MMC]
    $Kb1.TypeKey(39)
    $Kb1.TypeKey(13)
    Start-Sleep 1

    # [New-FEDeploymentShare]
    $Kb1.TypeText("New-FEDeploymentShare")
    $Kb1.TypeKey(13)
    $C = 0
    Do
    {
        $Item = Get-VM -VMName $Id1
        Switch($Item.CPUUsage)
        {
            Default { $C = 0 } 0 { $C += 1 } 1 { $C += 1 } 
        }
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][FEDeploymentShare [~] (Launching) ($($Tx2.Elapsed))]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 20)

    $Kb1.PressKey(18)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(18)
    Start-Sleep 1
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeText("Secure Digits Plus LLC")
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Domain)
    Start-Sleep 1

    # [Imaging]
    $Kb1.PressKey(17)
    9,9,9,9,9,9 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }
    $Kb1.ReleaseKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeText("C:\Images")
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)
    Start-Sleep 1

    # [IsoList]
    $Kb1.TypeKey(40)

    # [Server 2019 Iso]
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(40)

    # [Escape IsoList]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)

    # [Mount Server 2019 Iso]
    $Kb1.TypeKey(32)
    Start-Sleep 10

    # [Enter IsoView]
    40,9,40,40,40 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }

    # [Escape IsoView]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)

    # [Add Queue]
    $Kb1.TypeKey(32)

    # [Queue -> Dismount]
    $Kb1.TypeKey(38)
    $Kb1.TypeKey(38)
    $Kb1.TypeKey(39)

    # [Dismount]
    $Kb1.TypeKey(32)
    Start-Sleep 1

    # [Outside -> Extract]
    $Kb1.PressKey(16)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(16)
    Start-Sleep 1

    # [Extract -> IsoList][IsoList -> Select Win10]
    38,38,38,38,9,9 | % { $Kb1.TypeKey($_); Start-Sleep -M 200 }

    # [Escape IsoList]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)

    # [Mount Win10]
    $Kb1.TypeKey(32)
    Start-Sleep 16

    # [Mount -> IsoView][Select Win10 Pro]
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(9)
    Start-Sleep 1
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(40)

    # [Escape IsoView]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)

    # [Queue]
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [Queue -> Dismount]
    $Kb1.TypeKey(38)
    $Kb1.TypeKey(38)
    $Kb1.TypeKey(39)
    $Kb1.TypeKey(32)
    Start-Sleep 2

    # [Outside -> Extract]
    $Kb1.PressKey(16)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(16)
    Start-Sleep 1

    # [Goto Select]
    $Kb1.TypeKey(37)
    $Kb1.TypeText("C:\ImageSwap")
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)

    $C = 0
    Do
    {
        $Item = Get-VM -VMName $Id1
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][FEDeploymentShare [~] (Launching) ($($Tx2.Elapsed))][($C/150)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
        $C ++
    }
    Until ($C -ge 150)

    # [Goto -> Share Tab]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeText("C:\FlightTest")
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)
    $Kb1.TypeKey(38)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(40)
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)

    # [Network]
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Vm1.Item.DistinguishedName.Replace("CN=$($Vm1.Item.Name),OU=Server","OU=Computers"))

    # [Domain]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeText($Cred2.Username)
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Cred2.GetNetworkCredential().Password)
    $Kb1.TypeKey(9)
    $Kb1.TypeText($Cred2.GetNetworkCredential().Password)

    # [Local]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeKey(9)
    $Kb1.TypeText("password")
    $Kb1.TypeKey(9)
    $Kb1.TypeText("password")

    # [Branding]
    $Kb1.PressKey(17)
    $Kb1.TypeKey(9)
    $Kb1.ReleaseKey(17)
    $Kb1.TypeKey(32)
    Start-Sleep 1
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(32)
    Start-Sleep 4
    $Kb1.TypeKey(27)
    $Kb1.TypeKey(40)
    $Kb1.TypeKey(32)
    Start-Sleep 4
    $Kb1.TypeKey(27)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(9)
    $Kb1.TypeKey(32)

    # [Creating Share + Boot images]
    $C = @( )
    Do
    {
        $Item = Get-VM -VMName $Id1
        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
        $Lx1.Add($Lx1.Count,"[$($Tx1.Elapsed)][FEDeploymentShare [~] (Creating share/Boot images) ($($Tx2.Elapsed))][($Sum)]")
        Write-Host $Lx1[$Lx1.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 200)

    # [Workstation Test]
    $VmHost                = Get-VMHost
    $VmSwitch              = Get-VMSwitch
    $Zip                   = $Vm1.Item.Postal
    $Vw0                   = @{ 
        Name               = "ws1-$zip"
        MemoryStartupBytes = 2GB
        BootDevice         = "NetworkAdapter"
        NewVHDPath         = ("{0}\ws1-$zip.vhdx" -f $VMHost.VirtualHardDiskPath)
        NewVHDSizeBytes    = 20GB
        SwitchName         = ($VMSwitch | ? Name -match $Zip | % Name)
        Generation         = 2
    }
    New-VM @Vw0 -Verbose
    $IdW = $Vw0.Name
    $Tw0 = [System.Diagnostics.Stopwatch]::StartNew()
    $Lw0 = @{}
    Start-VM -VmName $Vw0.Name -Verbose  
    $Lw0.Add($Lw0.Count,"[$($Tw0.Time.Elapsed)] Starting [~] [$($IdW.Name)]")
    Write-Host $Lw0[$Lw0.Count-1]
    $CtrlW      = Get-WmiObject MSVM_ComputerSystem -NS Root\Virtualization\V2 | ? ElementName -eq $IdW
    $KbW        = Get-WmiObject -Query "ASSOCIATORS OF {$($CtrlW.Path.Path)} WHERE resultClass = Msvm_Keyboard" -Namespace "root\virtualization\v2"
    Start-Process vmconnect -ArgumentList ($Mx0.VM.Host.Name,$Vw0.Name)
    Do
    {
        $Item = Get-VM -VMName $IdW
        $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)] Starting [~] [$IdW]")
        Write-Host $Lw0[$Lw0.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -gt 135)
    $C = @( )
    Do
    {
        $Item = Get-VM -VMName $IdW
        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }
        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression
        $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)][FEDeploymentShare [~] (Testing)][($Sum)]")
        Write-Host $Lw0[$Lw0.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 200)
    9,9,9,32,9,32 | % { $KbW.TypeKey($_); Start-Sleep -M 200 }
    Start-Sleep 3
    $KbW.PressKey(18)
    $KbW.TypeKey(78)
    $KbW.ReleaseKey(18)
    Start-Sleep 4

    # [Computer Name]
    $Kbw.TypeText($IdW)
    $KbW.PressKey(18)
    $KbW.TypeKey(78)
    $KbW.ReleaseKey(18)
    Start-Sleep 4

    # [Move data/settings]
    $KbW.PressKey(18)
    $KbW.TypeKey(78)
    $KbW.ReleaseKey(18)
    Start-Sleep 4

    # [Restore data/settings]
    $KbW.PressKey(18)
    $KbW.TypeKey(78)
    $KbW.ReleaseKey(18)
    Start-Sleep 4

    # [Locale and Time]
    $KbW.PressKey(18)
    $KbW.TypeKey(71)
    $KbW.ReleaseKey(18)
    Start-Sleep 4

    # [Installation]
    Do
    {
        $Item = Get-VM -VMName $IdW
        $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)][FEDeploymentShare [~] (Testing)]")
        Write-Host $Lw0[$Lw0.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -le 5)
    Start-Sleep 5
    
    # [Sysprep]
    Do
    {
        $Item = Get-VM -VMName $IdW
        $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)][FEDeploymentShare [~] (Testing)]")
        Write-Host $Lw0[$Lw0.Count-1]
        Start-Sleep 1
    }
    Until ($Item.Uptime.TotalSeconds -le 5)

    # [First Run]
    $C = @( )
    Do
    {
        $Item = Get-VM -VMName $IdW
        Switch($Item.CPUUsage)
        {
            Default { $C = @( ) } 0 { $C += 1 } 1 { $C += 1 } 
        }

        $Sum = @( Switch($C.Count)
        {
            0 { 0 } 1 { $C } Default { (0..($C.Count-1) | % {$C[$_]*$_}) -join "+" }
        } ) | Invoke-Expression

        $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)][FEDeploymentShare [~] (First Run)][($Sum)]")
        Write-Host $Lw0[$Lw0.Count-1]
        Start-Sleep 1
    }
    Until ($Sum -gt 200)
    $KbW.PressKey(18)
    $KbW.TypeKey(9)
    $KbW.ReleaseKey(18)
    Start-Sleep 1
    $KbW.PressKey(18)
    $KbW.TypeKey(70)
    $KbW.ReleaseKey(18)
    Start-Sleep 1
    $KbW.TypeKey(91)
    Start-Sleep 2
    $KbW.TypeText("Resolution")
    Start-Sleep 4
    $KbW.TypeKey(13)
    Start-Sleep 7
    $KbW.PressKey(38)
    $KbW.PressKey(91)
    $KbW.TypeKey(82)
    $KbW.ReleaseKey(91)
    $KbW.TypeText("%PUBLIC%\Desktop\FightingEntropy.lnk")
    $KbW.TypeKey(13)
    Start-Sleep 20
    $KbW.TypeText("Set-DisplayResolution 1920 1080")
    $KbW.TypeKey(13)
    Start-Sleep 12

    $KbW.TypeText("y")
    $KbW.TypeKey(13)
    Start-Sleep 3

    $Lw0.Add($Lw0.Count,"[$($Tw0.Elapsed)][Installation [+] Complete]")
    Write-Host $Lw0[$Lw0.Count-1]
}
