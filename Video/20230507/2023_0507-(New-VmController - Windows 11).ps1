<#
    [April/May 2023]

            _____________________________
            |¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|
            | S | M | T | W | T | F | S |
    ________|___|___|___|___|___|___|___|
    |¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|
    | 04/02 :   |   |   |   |   |   |   |
    | 04/09 :   |   |   |   | X |   | X |
    | 04/16 : X | X |   | X | X | X | X |
    | 04/23 : X | X |   | X | X | X | X |
    | 04/30 : X | X | X | X | X | X | X |
    | 05/07 : X |   |   |   |   |   |   |
    |___________|___|___|___|___|___|___|
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    [05/07/23]: [New-VmController - Windows 11] (Formerly GUI development)

[Information]: I have covered the concept of [GUI development] as well
as managing things with [PowerShell], such as:
[+] [networking]
[+] [virtualization]
[+] [system administration]

[Objective]: Use [Visual Studio Code] as well as [Visual Studio], to
develop a [graphical user interface] that can manage multiple virtual
machines using: 

[+] [XAML/Extensible Application Markup Language]

[Note]: Use the classes from either the previous virtualization lab
videos, or the New-FEInfrastructure demonstration from this video:
________________________________________________________________________
| 12/04/2021 | New-FEInfrastructure | https://www.youtu.be/6yQr06_rA4I |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Specifically, at the time: [https://youtu.be/6yQr06_rA4I?t=355]

In that particular video, I had to use a [long list of techniques] to be
able to build the 1) graphical user interface, 2) administrate the server,
3) calculate all of the potential sites + networks + Active Directory nodes
+ virtual machine nodes...

...and I want to [streamline] that process, in order to [focus] on the 
[virtual machines] in particular.

[To Do]: Implement a way to orchestrate Windows Client versus Windows Server,
versus non-Windows initial setup information. Include stuff like the region,
language, time zone, security options for the account, etc.
#>

$Ctrl = New-VmController

# [GUI portion]
$Ctrl.StageXaml()
$Ctrl.Invoke()

# [Create the <VmNodeObject>, can initiate logging]
$Vm                   = $Ctrl.Node.Create(0)

# This file allows for the VM to be picked up with its various controls and et cetera.
$Vm                 = $Ctrl.Node.Control("C:\FileVm\desktop01.fex")

# // [Deserialize the accounts]
$Vm.Update(0,"[Deserialize the accounts]")
$Vm.Account           = $Vm.Account | % { $Ctrl.Credential.VmCredentialItem($_) }

# // [Object instantiation]
$Vm.Update(0,"[Object instantiation]")
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

# // [Start Machine, grab keyboard]
$Vm.Update(0,"[Start Machine]")
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name

# // [Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]
$Vm.Update(0,"[Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]")
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // [Wait for <Install Windows> menu]
$Vm.Update(0,"[Wait for <Install Windows> menu]")
$Vm.Idle(5,5)

# // [Hit <N>ext]
$Vm.Update(0,"[Hit <N>ext]")
$Vm.SpecialKey(78)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Idle(5,5)

# // [Enter Product Key or skip]
$Vm.Update(0,"[Enter Product Key or skip]")
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Timer(2)

# // [Select version of Windows]
$Vm.Update(0,"[Select version of Windows]")
$Vm.TypeChain(@(@(40) * ($Vm.Image.Edition.Index - 1)))
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [<Accept> license terms]
$Vm.Update(0,"[<Accept> license terms]")
$Vm.TypeKey(32)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"N")
$Vm.Timer(2)

# // [Select <custom install>]
$Vm.Update(0,"[Select <custom install>]")
$Vm.SpecialKey([UInt32][Char]"C")
$Vm.Timer(2)

# // [Set <partition>]
$Vm.Update(0,"[Set <partition>]")
$Vm.SpecialKey([UInt32][Char]"N")

# // [Installing, catch and release ISO upon reboot]
$Vm.Update(0,"[Installing, catch and release ISO upon reboot]")
$Vm.Uptime(0,5)
$Vm.UnloadIso()

# // [Wait for the computer to perform inital setup, and reboot]
$Vm.Update(0,"[Wait for the computer to perform inital setup, and reboot]")
$Vm.Timer(5)
$Vm.Uptime(0,5)

# // [Wait for (OOBE/Out-of-Box Experience) screen]
$Vm.Update(0,"[Wait for (OOBE/Out-of-Box Experience) screen]")
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
$Vm.Update(0,"[Region, default = United States]")
$Vm.TypeKey(13) # [Yes]
$Vm.Idle(5,5)

# // [Keyboard layout, default = US]
$Vm.Update(0,"[Keyboard layout, default = US]")
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(3)
$Vm.Idle(5,5)

# // [System Name <skip for now>]
$Vm.Update(0,"[System Name <skip for now>]")
$Vm.TypeKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [How would you like to set up this device]
$Vm.Update(0,"[How would you like to set up this device]")
9,9,32,13 | % { 

    $Vm.TypeKey($_)
    $Vm.Timer(1)
}
$Vm.Idle(5,5)

# // [Unlock your Microsoft experience]
$Vm.Update(0,"[Unlock your Microsoft experience]")
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Let's add your Microsoft account]
$Vm.Update(0,"[Let's add your Microsoft account]")
$Account = $Vm.Account | ? Type -eq Microsoft
$Vm.TypeLine($Account.Username)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Enter <Password>]
$Vm.Update(0,"[Enter <Password>]")
$Vm.TypePassword($Account)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Welcome back, <Person~!> (If not a new account)]
$Vm.Update(0,"[Welcome back, <Person~!> (If not a new account)]")
$Vm.ShiftKey(9)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Create a PIN]
$Vm.Update(0,"[Create a PIN]")
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Set up a PIN]
Switch ([UInt32]($Account.Pin -match "[0-9]+"))
{
    0
    {
        # // [Numbers/Symbols in PIN]
        $Vm.Update(0,"[Numbers/Symbols in PIN]")
        $Vm.TypeKey(9)
        $Vm.TypeKey(9)
        $Vm.TypeKey(32)
        $Vm.ShiftKey(9)
        $Vm.ShiftKey(9)
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(9)
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(9)
        $Vm.TypeKey(9)
        $Vm.TypeKey(9)
        $Vm.TypeKey(13)
        $Vm.Idle(5,5)

        <# // [Something went wrong] [Skip for now]
        $Vm.TypeKey(9)
        $Vm.TypeKey(9)
        $Vm.TypeKey(9)
        $Vm.TypeKey(32)
        $Vm.Idle(5,5)
        #>
    }
    1
    {
        # // [Standard pin]
        $Vm.Update(0,"[Standard pin]")
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(9)
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(13)
        $Vm.Idle(5,5)
    }
}

# // [Chose privacy settings]
$Vm.Update(0,"[Chose privacy settings]")
$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Let's customize your experience]
$Vm.Update(0,"[Let's customize your experience]")
0..3 | % { 
    
    $Vm.Timer(1)
    $Vm.ShiftKey(9)
}
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [Use your Android phone from your PC] (Erratic behavior here)
$Vm.Update(0,"[Use your Android phone from your PC]")
$Vm.Timer(1)
$Vm.ShiftKey(9)
$Vm.Timer(1)
$Vm.ShiftKey(9)
$Vm.Timer(1)
$Vm.ShiftKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [Access granted Office 365 trial]
$Vm.Update(0,"[Access granted Office 365 trial]")
$Vm.ShiftKey(9)
$Vm.ShiftKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,2)

# // [Get 100 GB more cloud storage]
$Vm.Update(0,"[Get 100 GB more cloud storage]")
$Vm.ShiftKey(9)
$Vm.ShiftKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [Get your first month of PC Game Pass]
$Vm.Update(0,"[Get your first month of PC Game Pass]")
$Vm.ShiftKey(9)
$Vm.ShiftKey(9)
$Vm.TypeKey(32)

# // [Checking for updates]
$Vm.Update(0,"[Checking for updates]")
$Vm.Idle(5,5)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Configuration [~] Post-Installation                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Ctrl.Module.Write("Configuration [~] Post Installation: [$($Vm.Name)]")

# // [Load scriptblock engine]
$Vm.Update(0,"[Load scriptblock engine]")
$Vm.Load()
$Vm.Idle(5,5)

# // [Launch PowerShell]
$Vm.Update(0,"[Launch PowerShell]")
$Vm.LaunchPs()

# // [Checkpoint]
# $Vm.Object | Checkpoint-Vm -SnapshotName ("{0}-{1}" -f $Vm.Name, $Vm.Now())
# $Cp = Get-VmCheckpoint -VMName $Vm.Name | ? Name -match "\d{4}\-\d{4}_\d{6}"
# $Vm.Checkpoint += $Vm.VmNodeCheckpoint(0,$Cp)

# // [Restore checkpoint]
# $Vm.RestoreCheckpoint("2023-0507_173407")
# $Vm.Idle(5,5)

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
