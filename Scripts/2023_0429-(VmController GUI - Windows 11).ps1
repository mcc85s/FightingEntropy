<#
    [April 2023]

            _____________________________
            |¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|
            | S | M | T | W | T | F | S |
    ________|___|___|___|___|___|___|___|
    |¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|¯¯¯|
    | 04/02 :   |   |   |   |   |   |   |
    | 04/09 :   |   |   |   | X |   | X |
    | 04/16 : X | X |   | X | X | X | X |
    | 04/23 : X | X |   | X | X | X | X |
    | 04/30 :   |   |   |   |   |   |   |
    |___________|___|___|___|___|___|___|
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    [04/29/23]: [VmController - GUI Development]

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

# [Select Windows 11 image/edition]
$Selected             = $Ctrl.VmControllerImage()
$Selected.Image       = $Ctrl.Xaml.IO.ImageStore.SelectedItem
$Selected.Edition     = $Ctrl.Xaml.IO.ImageStoreContent.SelectedItem
$Span                 = $Selected.Edition.Index - 1

# [Create the <VmNodeObject>]
$Vm                   = $Ctrl.Node.Create(0)

# [Reserialize the accounts]
$Vm.Account           = $Vm.Account | % { $Ctrl.Credential.VmCredentialItem($_) }

# // Object instantiation
$Vm.New()

# // Windows 11 enable TPM w/ key protector
If (!$Vm.Security.Property.TpmEnabled)
{
    $Vm.Security.ToggleTpm()
}

$Vm.AddVmDvdDrive()
$Vm.LoadIso($Vm.Iso)
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
$Vm.TypeChain(@(@(40) * $Span))
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
$Vm.TypeKey(13) # [Yes]
$Vm.Idle(5,2)

# // [Keyboard layout, default = US]
$Vm.TypeKey(13) # [Yes]
$Vm.Timer(1)
$Vm.TypeKey(13) # [Skip]
$Vm.Timer(3)
$Vm.Idle(5,2)

# // [System Name] [Skip for now]
$Vm.TypeKey(9)
$Vm.TypeKey(32)
$Vm.Idle(5,2)

# // [How would you like to set up this device]
9,9,32,13 | % { 

    $Vm.TypeKey($_)
    $Vm.Timer(1)
}
$Vm.Idle(5,2)

# // [Unlock your Microsoft experience]
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // [Let's add your Microsoft account]
$Account = $Vm.Account | ? Type -eq Microsoft
$Vm.TypeLine($Account.Username)
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // Password
$Vm.TypePassword($Account)
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // Welcome back, <Person~!> [If not a new account]
# $Vm.ShiftKey(9)
# $Vm.TypeKey(13)
# $Vm.Idle(5,2)

# // Create a PIN
$Vm.TypeKey(13)
$Vm.Idle(5,2)

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
        $Vm.Idle(5,2)

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
        $Vm.Idle(5,2)
    }
}

# // [Chose privacy settings]
$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Timer(2)

$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // [Let's customize your experience]
$Vm.TypeChain(@(9)*6)
$Vm.TypeKey(32)
$Vm.Idle(5,2)

# // [Use your Android phone from your PC]
$Vm.TypeChain(@(9)*3)
$Vm.TypeKey(32)
$Vm.Idle(5,2)

# // [Access granted Office 365 trial]
$Vm.TypeChain(@(9,9,32))
$Vm.Idle(5,2)

# // [Get 100 GB more cloud storage]
$Vm.TypeChain(@(9,32))
$Vm.Idle(5,2)

# // [Get your first month of PC Game Pass]
9,9,9,32 | % { 

    $Vm.TypeKey($_)
    $Vm.Timer(1)
}
$Vm.Idle(5,2)

# // [Checking for updates]

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Configuration [~] Post-Installation                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Ctrl.Module.Write("Configuration [~] Post Installation: [$($Vm.Name)]")

# // [Launch PowerShell]
$Vm.LaunchPs()

$Content = @'
$Index = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex
$Interface = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $Index
$Interface | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:0 -Verbose
$Interface | Remove-NetRoute -AddressFamily IPv4 -Confirm:0 -Verbose
$Splat = @{

    InterfaceIndex  = $Index
    AddressFamily   = "IPv4"
    PrefixLength    = {Prefix}
    ValidLifetime   = [Timespan]::MaxValue
    IPAddress       = "{IpAddress}"
    DefaultGateway  = "{Gateway}"

}
New-NetIPAddress @Splat
Set-DnsClientServerAddress -InterfaceIndex $Index -ServerAddresses {Dns} -Verbose

$Base = "https://github.com/mcc85s/FightingEntropy"
$Url = "$Base/blob/main/Version/2023.4.0/Functions/Start-TCPSession.ps1?raw=true"
Invoke-RestMethod $Url | Invoke-Expression

'@

# // [Set static IP address]
ForEach ($Line in $Content.Split("`n"))
{
    If ($Line -match "\{\w+}")
    {
        $Property = $Matches[0] -Replace "(\{|\})",""
        $Line = $Line -Replace "\{$Property\}", $Vm.Network.$Property
    }
    $Vm.TypeLine($Line)
}

# [04/29/2023 16:03]
