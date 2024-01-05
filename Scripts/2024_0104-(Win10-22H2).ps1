<#
    [Virtualization Lab - Desktop Development] -> NewVmController 2023.8.0 -> 2023.12.0

    In this video, I will be building a brand new Hyper-V VM using [New-VmController 2023.8.0],
    in order to deploy [Windows 10 22H2]. Although I have done this in previous videos...

    ...in order to update the module to [2023.12.0], I have to flesh out some of the issues
    I haven't resolved quite yet, and a part of doing that is to show the entire process from
    beginning to end, and then make necessary changes after [FightingEntropy(π)] is deployed.

    Todo: Some of the objects coming back from the virtual switch scanner are showing up blank.
#>

<#
Import-Module FightingEntropy -Verbose

$WorkingPath = "C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Functions\New-VmController.ps1"
. $WorkingPath

# [Stage and deploy Windows 10 22H2]
$Ctrl = New-VmController
$Ctrl.StageXaml()
$Ctrl.Invoke()

$Index = $Ctrl.Node.Template | ? Name -eq Testing | % Index
# [Create the <VmNodeObject>, can initiate logging]
$Vm                   = $Ctrl.Node.Create($Index)

# This file allows for the VM to be picked up with its various controls and et cetera.
$Vm                 = $Ctrl.Node.Control("C:\FileVm\testing.fex")
#>

If (!(Get-Module FightingEntropy))
{
    Import-Module FightingEntropy -Force -Verbose
}

. "C:\Users\mcadmin\Documents\Scripts\2024_0104-(NewVmController).ps1"

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
$Ctrl.Module.Write("Configuration [~] Post Installation: [$($Vm.Name)]")

# // [Load scriptblock engine]
$Vm.Update(0,"[~] Load scriptblock engine")
$Vm.Load()
$Vm.Idle(5,5)

# // [Launch PowerShell]
$Vm.Update(0,"[+] Launch PowerShell")
$Vm.LaunchPs()

# // [Checkpoint]
<#
$Vm.Object | Checkpoint-Vm -SnapshotName ("{0}-{1}" -f $Vm.Name, $Vm.Now())
$Cp = Get-VmCheckpoint -VMName $Vm.Name | ? Name -match "\d{4}\-\d{4}_\d{6}"
$Vm.Checkpoint += $Vm.VmNodeCheckpoint(0,$Cp)
#>

# // [Restore checkpoint]
<#
$Vm.RestoreCheckpoint("2023-1207_213620")
$Vm.Idle(5,5)
#>

# // [Initialize Network + Module]
$Vm.Update(0,"[Initialize Network + Module]")
$Vm.TypeLine("irm $($Ctrl.Module.Source)/blob/main/Scripts/Initialize-VmNode.ps1?raw=true | iex")
$Vm.TypeKey(13)
$Vm.Timer(10)

$Line  = "`$Ctrl = Initialize-VmNode"
$Line += " -Index {0}"     -f 0
$Line += " -Name {0}"      -f $Vm.Name
$Line += " -IpAddress {0}" -f $Vm.Network.IpAddress
$Line += " -Domain {0}"    -f $Vm.Network.Domain
$Line += " -NetBios {0}"   -f $Vm.Network.NetBios
$Line += " -Trusted {0}"   -f $Vm.Network.Trusted
$Line += " -Prefix {0}"    -f $Vm.Network.Prefix
$Line += " -Netmask {0}"   -f $Vm.Network.Netmask
$Line += " -Gateway {0}"   -f "192.168.42.129"
$Line += " -Dns @('{0}')"  -f "192.168.42.129"
$Line += " -Transmit {0}"  -f "13000"
$Vm.TypeLine($Line)
$Vm.TypeKey(13)
$Vm.Timer(10)

$Vm.TypeLine('$Ctrl.Initialize()')
$Vm.TypeKey(13)
$Vm.Timer(5)

$Vm.TypeLine('$Ctrl.Persistence()')
$Vm.TypeKey(13)
$Vm.Timer(5)

$List = 1,2,3,7,8,9,10,11,12,13
# For each script, run this:
ForEach ($X in $List)
{
    $Vm.TypeLine('$Ctrl.Receive()')
    $Vm.TypeKey(13)

    $Splat      = @{ 

        Source  = $Vm.Network.IpAddress
        Port    = 13000
        Content = $Vm.Script.Output[$X].Content.Line
    }

    Start-TcpSession -Client @Splat | % Initialize
}

ForEach ($X in 0..($List.Count-1))
{
    $Vm.TypeLine("`$Ctrl.ScriptList[$X].Execute()")
    $Vm.TypeKey(13)
    $Vm.Timer(5)
}

# // [Initialize Network + Module]
$Vm.Update(0,"[Initialize Network + Module]")
$Vm.TypeLine("irm $($Ctrl.Module.Source)/blob/main/Scripts/Initialize-VmNode.ps1?raw=true | iex")
$Vm.TypeKey(13)
$Vm.Timer(10)

$Line  = "`$Ctrl = Initialize-VmNode"
$Line += " -Index {0}"     -f 0
$Line += " -Name {0}"      -f $Vm.Name
$Line += " -IpAddress {0}" -f $Vm.Network.IpAddress
$Line += " -Domain {0}"    -f $Vm.Network.Domain
$Line += " -NetBios {0}"   -f $Vm.Network.NetBios
$Line += " -Trusted {0}"   -f $Vm.Network.Trusted
$Line += " -Prefix {0}"    -f $Vm.Network.Prefix
$Line += " -Netmask {0}"   -f $Vm.Network.Netmask
$Line += " -Gateway {0}"   -f $Vm.Network.Gateway
$Line += " -Dns @('{0}')"  -f ($Vm.Network.Dns -join "','")
$Line += " -Transmit {0}"  -f $Vm.Network.Transmit
$Vm.TypeLine($Line)
$Vm.TypeKey(13)
$Vm.Timer(10)

$Vm.TypeLine('$Ctrl.Initialize()')
$Vm.TypeKey(13)
$Vm.Timer(5)

$Vm.TypeLine('$Ctrl.Persistence()')
$Vm.TypeKey(13)
$Vm.Timer(5)

$List = 1,2,3,7,8,9,10,11,12,13
# For each script, run this:
$List = 14
ForEach ($X in $List)
{
    $Vm.TypeLine('$Ctrl.Receive()')
    $Vm.TypeKey(13)

    $Splat      = @{ 

        Source  = $Vm.Network.IpAddress
        Port    = $Vm.Network.Transmit
        Content = $Vm.Script.Output[$X].Content.Line
    }

    Start-TcpSession -Client @Splat | % Initialize
}


ForEach ($X in 0..($List.Count-1))
{
    $Vm.TypeLine("`$Ctrl.ScriptList[$X].Execute()")
    $Vm.TypeKey(13)
    $Vm.Timer(5)
}

<# 

ForEach ($Line in $Vm.Initialize())
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}
$Vm.Idle(5,2)

# // [Import FE Module]
$Vm.Update(0,"[Import FE Module]")
ForEach ($Line in $Vm.ImportFeModule())
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}
$Vm.Idle(5,2)

# // [Transmit script #0 : SetPersistentInfo]
$Vm.Update(0,"[Transmit script #0 : SetPersistentInfo]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #1 : SetTimeZone]
$Vm.Update(0,"[Transmit script #1 : SetTimeZone]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #2 : SetComputerInfo]
$Vm.Update(0,"[Transmit script #2 : SetComputerInfo]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #3 : SetIcmpFirewall]
$Vm.Update(0,"[Transmit script #3 : SetIcmpFirewall]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Skip script #4 : SetInterfaceNull]
$Vm.Update(0,"[Skip script #4 : SetInterfaceNull]")
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Skip script #5 : SetStaticIp]
$Vm.Update(0,"[Skip script #5 : SetStaticIp]")
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Run script #6 : SetWinRm]
$Vm.Update(0,"[Run script #6 : SetWinRm]")
$Vm.RunScript()

# // [Transmit script #7 : SetWinRmFirewall]
$Vm.Update(0,"[Transmit script #7 : SetWinRmFirewall]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #8 : SetRemoteDesktop]
$Vm.Update(0,"[Transmit script #8 : SetRemoteDesktop]")
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Skip script #9 : InstallFeModule]
$Vm.Update(0,"[Skip script #9 : InstallFeModule]")
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Run script #10 : InstallChoco]
$Vm.Update(0,"[Run script #10 : InstallChoco]")
$Vm.RunScript()
$Vm.Idle(5,2)

# // [Run script #11 : InstallVsCode]
$Vm.Update(0,"[Run script #11 : InstallVsCode]")
$Vm.RunScript()
$Vm.Idle(5,5)

# // [Run script #12 : InstallBossMode]
$Vm.Update(0,"[Run script #12 : InstallBossMode]")
$Vm.RunScript()
$Vm.Idle(5,2)

# // [Transmit script #13 : InstallPsExtension]
$Vm.Update(0,"[Transmit script #13 : InstallPsExtension]")
$Vm.TransmitScript()
$Vm.Timer(5)
$Vm.Idle(5,2)

# // [Run script #14 : Restart computer]
$Vm.Update(0,"[Run script #14 : Restart computer]")
$Vm.RunScript()

# // [Await computer to restart]
$Vm.Update(0,"[Await computer to restart]")

# // [Login using PIN]
$Vm.Update(0,"[Login using PIN]")
$Vm.TypeCtrlAltDel()
$Vm.Timer(1)
$Vm.TypeMask($Account.Pin)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

#>
