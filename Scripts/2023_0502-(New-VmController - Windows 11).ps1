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
    | 04/30 : X | X | X |   |   |   |   |
    |___________|___|___|___|___|___|___|
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    [05/02/23]: [New-VmController - Windows 11] (Formerly GUI development)

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

# [Create the <VmNodeObject>]
$Vm                   = $Ctrl.Node.Create(0)

# This file allows for the VM to be picked up with its various controls and et cetera.
# $Vm                 = $Ctrl.Node.Control("C:\FileVm\desktop01.fex")

# [Deserialize the accounts]
$Vm.Account           = $Vm.Account | % { $Ctrl.Credential.VmCredentialItem($_) }

# // Object instantiation
$Vm.New()

# // Windows 11 enable TPM w/ key protector
If (!$Vm.Security.Property.TpmEnabled)
{
    $Vm.Security.ToggleTpm()
}

$Vm.AddVmDvdDrive()
$Vm.LoadIso()
$Vm.SetIsoBoot()
$Vm.Connect()

# // Start Machine
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard") | ? Path -match $Vm.Control.Name

# // Wait for "Press enter to boot from CD/DVD", then press enter, then start [64-bit]
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // Wait for "Install Windows" menu
$Vm.Idle(5,5)

# // Hit [N]ext
$Vm.SpecialKey(78)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Idle(5,5)

# // Enter Product Key or skip.
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Timer(2)

# // Select version of Windows
$Vm.TypeChain(@(@(40) * ($Vm.Image.Edition.Index - 1)))
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // Accept license terms
$Vm.TypeKey(32)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"N")
$Vm.Timer(2)

# // Select custom install
$Vm.SpecialKey([UInt32][Char]"C")
$Vm.Timer(2)

# // Set partition
$Vm.SpecialKey([UInt32][Char]"N")

# // Catch and release ISO upon reboot
$Vm.Uptime(0,5)
$Vm.UnloadIso()

# // Wait for the computer to perform inital setup, and reboot
$Vm.Timer(5)
$Vm.Uptime(0,5)

# // Wait for (OOBE/Out-of-Box Experience) screen
$Vm.Idle(5,5)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Installation [~] System Preparation [Region]                                                   ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Ctrl.Module.Write("Installation [~] System Preparation [Region]")

# // [Region, default = United States]
$Vm.TypeKey(13) # [Yes]
$Vm.Idle(5,5)

# // [Keyboard layout, default = US]
$Vm.TypeKey(13) # [Yes]
$Vm.Timer(1)
$Vm.TypeKey(13) # [Skip]
$Vm.Timer(3)
$Vm.Idle(5,5)

# // [System Name] [Skip for now]
$Vm.TypeKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [How would you like to set up this device]
9,9,32,13 | % { 

    $Vm.TypeKey($_)
    $Vm.Timer(1)
}
$Vm.Idle(5,5)

# // [Unlock your Microsoft experience]
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Let's add your Microsoft account]
$Account = $Vm.Account | ? Type -eq Microsoft
$Vm.TypeLine($Account.Username)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // Password
$Vm.TypePassword($Account)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // Welcome back, <Person~!> [If not a new account]
$Vm.ShiftKey(9)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // Create a PIN
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // Set up a PIN
Switch ([UInt32]($Account.Pin -match "[0-9]+"))
{
    0
    {
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
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(9)
        $Vm.TypeMask($Account.Pin)
        $Vm.TypeKey(13)
        $Vm.Idle(5,5)
    }
}

# // [Chose privacy settings]
$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Let's customize your experience]
$Vm.TypeChain(@(9)*6)
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [Use your Android phone from your PC]
$Vm.TypeChain(@(9,9))
$Vm.TypeKey(32)
$Vm.Idle(5,5)

# // [Access granted Office 365 trial]
$Vm.TypeChain(@(9,9,32))
$Vm.Idle(5,5)

# // [Get 100 GB more cloud storage]
$Vm.TypeChain(@(9,32))
$Vm.Idle(5,5)

# // [Get your first month of PC Game Pass]
9,9,9,32 | % { 

    $Vm.TypeKey($_)
    $Vm.Timer(1)
}
$Vm.Idle(5,5)

# // [Checking for updates]

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Configuration [~] Post-Installation                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Ctrl.Module.Write("Configuration [~] Post Installation: [$($Vm.Name)]")

# // [Load scriptblock engine]
$Vm.Load()

# // [Launch PowerShell]
$Vm.LaunchPs()

# // [Initialize Network + Module]
ForEach ($Line in $Vm.Initialize())
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}
$Vm.Idle(5,2)

# // [Import FE Module]
ForEach ($Line in $Vm.ImportFeModule())
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}
$Vm.Idle(5,2)

# // [Transmit script #0 : SetPersistentInfo]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #1 : SetTimeZone]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #2 : SetComputerInfo]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #3 : SetIcmpFirewall]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Skip script #4 : SetInterfaceNull]
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Skip script #5 : SetStaticIp]
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Run script #6 : SetWinRm]
$Vm.RunScript()

# // [Transmit script #7 : SetWinRmFirewall]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Transmit script #8 : SetRemoteDesktop]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Skip script #9 : InstallFeModule]
$Vm.Script.Current().Complete ++
$Vm.Script.Selected           ++

# // [Run script #10 : InstallChoco]
$Vm.RunScript()
$Vm.Idle(5,2)

# // [Run script #11 : InstallFeModule]
$Vm.RunScript()

# // [Run script #12 : InstallBossMode]
$Vm.RunScript()

# // [Transmit script #13 : InstallPsExtension]
$Vm.TransmitScript()
$Vm.Idle(5,2)

# // [Run script #14 : Restart computer]
$Vm.RunScript()
