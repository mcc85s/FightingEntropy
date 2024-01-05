<#
    [Virtualization Lab - Desktop Development] -> NewVmController 2023.8.0 -> 2023.12.0

    In this video, I will be building a brand new Hyper-V VM using [New-VmController 2023.8.0],
    in order to deploy [Windows 10 22H2]. Although I have done this in previous videos...

    ...in order to update the module to [2023.12.0], I have to flesh out some of the issues
    I haven't resolved quite yet, and a part of doing that is to show the entire process from
    beginning to end, and then make necessary changes after [FightingEntropy(π)] is deployed.

    Todo: Some of the objects coming back from the virtual switch scanner are showing up blank.
#>

If (!(Get-Module FightingEntropy))
{
    Import-Module FightingEntropy -Force -Verbose
}

. "C:\Users\mcadmin\Documents\Scripts\2024_0105-(NewVmController).ps1"

# $Ctrl = [NewVmControllerMaster]::New()

$Vm = $Ctrl.Node.Control("C:\FileVm\testing.fex")

# // [Object instantiation]
$Vm.Update(0,"[~] Object instantiation")
$Vm.New()

# // [Windows 11 enable TPM w/ key protector]
If (!$Vm.Security.Property.TpmEnabled)
{
    $Vm.Security.ToggleTpm()
}

$Vm.AddVmDvdDrive()
$Vm.LoadIso()
$Vm.SetIsoBoot()
$Vm.Connect()

# // Start Machine, grab keyboard
$Vm.Update(0,"[~] Start Machine, grab keyboard")
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name
If (!!$Vm.Control -and !!$Vm.Keyboard)
{
    $Vm.Update(0,"[+] Started, grabbed keyboard")
}
Else
{
    $Vm.Update(100,"[!] Keyboard not found")
}

# // Wait for <Press enter to boot from CD/DVD>, then start <64-bit>
$Vm.Update(0,"[~] Wait for <Press enter to boot from CD/DVD>, then start <64-bit>")
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // Wait for <Install Windows> menu
$Vm.Update(0,"[~] Wait for <Install Windows> menu")
$Vm.Idle(5,5)

# // Hit <N>ext
$Vm.Update(0,"[+] Hit <N>ext")
$Vm.SpecialKey(78)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Idle(5,5)

# // Enter Product Key or skip
$Vm.Update(0,"[+] Enter Product Key or skip")
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Timer(2)

# // Selecting version of Windows
$Vm.Update(0,"[~] Selecting version of Windows")
$Vm.TypeChain(@(@(40) * ($Vm.Image.Edition.Index - 1)))
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // <Accept> license terms
$Vm.Update(0,"[+] <Accept> license terms")
$Vm.TypeKey(32)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"N")
$Vm.Timer(2)

# // Select <custom install>
$Vm.Update(0,"[~] Select <custom install>")
$Vm.SpecialKey([UInt32][Char]"C")
$Vm.Timer(2)

# // Set <partition>
$Vm.Update(0,"[~] Set <partition>")
$Vm.SpecialKey([UInt32][Char]"N")

# // Installing, catch and release ISO upon reboot
$Vm.Update(0,"[~] Installing, catch and release ISO upon reboot")
$Vm.Uptime(0,5)
$Vm.UnloadIso()

# // [Wait for the computer to perform inital setup, and reboot]
$Vm.Update(0,"[~] Wait for the computer to perform inital setup, and reboot")
$Vm.Timer(5)
$Vm.Uptime(0,5)

# // [Wait for (OOBE/Out-of-Box Experience) screen]
$Vm.Update(0,"[~] Wait for (OOBE/Out-of-Box Experience) screen")
$Vm.Uptime(1,60)
$Vm.Idle(5,2)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Installation [~] System Preparation [Region]                                                   ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Ctrl.Module.Write("Installation [~] System Preparation [Region]")

# // [Region, default = United States]
$Vm.Update(0,"[~] Region, default = United States")
$Vm.TypeKey(13) # [Yes]
$Vm.Idle(5,5)

# // [Keyboard layout, default = US]
$Vm.Update(0,"[~] Keyboard layout, <default = US>")
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(3)

# $Vm.Idle(5,5)

<# [Win11] // System Name <skip for now>
$Vm.Update(0,"[~] System Name <skip for now>]")
$Vm.TypeKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,5)
#>

# // Network, default = Automatic
# <expand here for non-networked>
# <apparently, now the setup restarts the computer>
$Vm.Update(0,"[~] Staging network, will reboot")
$Vm.Uptime(0,5)

$Vm.Update(0,"[~] Rebooted, waiting (1) minute")
$Vm.Uptime(1,60)
$Vm.Idle(5,2)

# // Account, default = Personal Use
# <expand here for (Active Directory/organization)>
$Vm.Update(0,"[~] Account, <default = Personal Use>")
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // OneDrive setup
$Vm.Update(0,"[~] OneDrive setup")
$Vm.TypeChain(@(9,9,9,9,32))
$Vm.Idle(5,2)

# // Limited Experience
$Vm.Update(0,"[~] Limited Experience")
$Vm.TypeChain(@(9,9,32))
$Vm.Idle(5,2)

# // Who's gonna use this PC...? Hm...?
$Vm.Update(0,"[~] Who's gonna use this PC...? Hm...?")
$Account = ($Vm.Account | ? Type -eq User)[0]

$Vm.Update(0,"[+] Account: $($Account.Username)")
$Vm.TypeText($Account.Username)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Create a super memorable password/Confirm]
0..1 | % { 

    $Vm.TypePassword($Account)
    $Vm.TypeKey(13)
    $Vm.Timer(2)
}

# // [Create security questions]
0..2 | % {

    $Vm.TypeKey(40)
    $Vm.TypeKey(9)
    $Vm.TypeText("Default")
    $Vm.TypeKey(13)
    $Vm.Timer(1)
}
$Vm.Idle(5,2)

# // Always have access to your recent browsing data
$Vm.Update(0,"[~] Always have access to your recent browsing data")
$Vm.TypeChain(@(9,9,32))
$Vm.Idle(5,2)

# // Chose privacy settings
$Vm.Update(0,"[~] Chose privacy settings")
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // Let's customize your experience
$Vm.Update(0,"[~] Let's customize your experience")
$Vm.TypeChain(@(9,9,9,9,9,9,9,9,13))
$Vm.Idle(5,2)

# // Let Cortana help you get s*** done
$Vm.Update(0,"[~] Let Cortana help you get s*** done")
$Vm.TypeKey(13)
$Vm.Idle(2,5)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Configuration [~] Post-Installation                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Vm.Update(1,"[+] Configuration, Post installation: [$($Vm.Name)]")
$Ctrl.Module.Write($Vm.Console.Last().Status)

# // [Load scriptblock engine]
$Vm.Update(0,"[~] Load scriptblock engine")
$Vm.Load()
$Vm.Idle(5,5)

# // [Launch PowerShell]
$Vm.Update(0,"[+] Launch PowerShell")
$Vm.LaunchPs()

# // [Checkpoint]
<#
Import-Module Hyper-V -Force -Verbose
$Vm.Object | Checkpoint-Vm -SnapshotName ("{0}-{1}" -f $Vm.Name, $Vm.Now())
$Cp = Get-VmCheckpoint -VMName $Vm.Name | ? Name -match "\d{4}\-\d{4}_\d{6}"
$Vm.Checkpoint += $Vm.NewVmControllerNodeCheckpoint(0,$Cp)
#>

# // [Restore checkpoint]
<#
$Vm.RestoreCheckpoint($Cp.Name)
$Vm.Idle(5,5)
#>

# // Initialize Network + Module
$Vm.Update(0,"[~] Initialize Network + Module]")
$Vm.TypeLine("irm $($Ctrl.Module.Source)/blob/main/Scripts/Initialize-VmNode.ps1?raw=true | iex")
$Vm.TypeKey(13)
$Vm.Timer(10)

# // Instantiate Initialize-VmNode
$Vm.Update(0,"[~] Instantiate Initialize-VmNode")
$Vm.TypeLine($Vm.InitializeVmNode())
$Vm.TypeKey(13)
$Vm.Timer(10)

# // Instantiate Dhcp settings
$Vm.Update(0,"[~] Instantiate Dhcp settings")
$Vm.TypeLine($Vm.InitializeVmNodeDhcp())
$Vm.TypeKey(13)
$Vm.Timer(10)

# // Initialize network settings
$Vm.Update(0,"[~] Initialize network settings")
$Vm.TypeLine('$Ctrl.Initialize()')
$Vm.TypeKey(13)
$Vm.Timer(10)

# // Initialize persistence
$Vm.Update(0,"[~] Initialize persistence")
$Vm.TypeLine('$Ctrl.Persistence()')
$Vm.TypeKey(13)
$Vm.Timer(5)

# // Transmit all separate scripts
<#
$Vm.Update(0,"[~] Transmit all separate scripts")
ForEach ($Script in $Vm.Script.Output)
{
    $Vm.TypeLine('$Ctrl.Receive()')
    $Vm.TypeKey(13)

    $Splat      = @{ 

        Source  = $Vm.Network.IpAddress
        Port    = 13000
        Content = $Script.Content.Line
    }

    Start-TcpSession -Client @Splat | % Initialize
}
#>

# // Run all separate scripts
$Vm.Update(0,"[~] Run all separate scripts")
ForEach ($Script in $Vm.Script.Output)
{
    $Vm.Update(0,"[~] $($Script.DisplayName)")
    $Vm.RunScript()
}
