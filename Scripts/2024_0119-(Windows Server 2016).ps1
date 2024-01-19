<#
    [Virtualization Lab - Windows Server 2016] -> New-VmController 2023.8.0 -> 2024.1.0

    In this video, I will be building a brand new Hyper-V VM using [NewVmController],
    which is a series of classes that expand upon the function [New-VmController],
    in order to deploy [Windows Server 2016] as a <domain controller> through 
    [Get-FEDCPromo] to install a number of services, as well as [Initialize-FeAdInstance]
    with MY customized <organizational units>, <security groups>, and <user accounts>.
    
    Although I have used the function (New-VmController) in previous videos...

    /¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    \ Date     | Name                                      | Link                         /
    / 12/05/21 | [FightingEntropy(π)] New-FEInfrastructure | https://youtu.be/6yQr06_rA4I \
    \ 03/20/23 | Virtualization Lab - Desktop Deployment   | https://youtu.be/i2_fafoIx6I /
    / 04/03/23 | Virtualization Lab - TCP Session          | https://youtu.be/09c-fFbEQrU \
    \ 04/12/23 | Virtualization Lab - RHEL Deployment      | https://youtu.be/AucVPa_EpQc /
    / 04/30/23 | Virtualization Lab - Windows 11           | https://youtu.be/OmTRiYemQAI \
    \ 01/06/24 | Virtualization Lab - Windows 10 22H2      | https://youtu.be/g3GJe00WJLg /
     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ...in order to update the module to [2024.1.0], I had to flesh out some of the issues
    I was having with (New-VmController v2023.8.0), and this video is a [continuation] of
    this series of videos listed above.

    This demonstration is simply working with the newly written classes before posting an
    update to the module [FightingEntropy(π)], though some of the functions in the module
    that have NOT been updated, will be used to deploy a server that meets various criteria.

    [Criteria]:
    - Deploy operating system using the script file [2024_0110-(NewVmController).ps1]
    - Post-configuration should allow <Remote Desktop>, as well as <WinRM console connection>
      through a custom [engineering] account, <mcook85@securedigitsplus.com>
    - [Initialize-VmNode] is another function that can be downloaded to set (network + host)
    - [Get-FEDCPromo] is another function that installs the prerequisites to run an
      [Active Directory] server instance
    - [Initialize-AdInstance] is another function in the module that sets up (security groups),
      (organizational units), and (users) in [Active Directory]
    - [Get-MdtModule] is another function that installs the prerequisites to run a 
      [Michaelsoft Deployment Toolkit/System Center Configuration Manager] server to 
      <image/control/configure OTHER machines on a given (network/network of networks)>
    - All of these prerequisites will allow <New-FEInfrastructure> to be usable, and further
      developed (video link of previous iteration above)

    [Notes]:
    - The [Michaelsoft Deployment Toolkit] is actually called the [Microsoft Deployment Toolkit], and
      was originally the [Business Desktop Deployment], developed by a badass named [Michael T. Niehaus]
    - Another badass named [Jeffrey Snover] told red rover to move over, and now we have [PowerShell]
    - They are both former (head honchos/executives/wizards) at the [Microsoft Corporation] located at:
      [One Microsoft Way, Redmond Washington 98052]
    - They both had heavy involvement in the development of either [PowerShell] or [BDD/MDT/SCCM], 
      whereby setting the benchmark [quite high] in terms of building things that [work really well],
      and that do a LOT of [work].
#>

If (!(Get-Module FightingEntropy))
{
    Import-Module Hyper-V, FightingEntropy -Force -Verbose
}

. "C:\Users\mcadmin\Documents\Scripts\2024_0119-(NewVmController).ps1"
# $Ctrl.Reload()

# $Ctrl = [NewVmControllerMaster]::New()

$Vm = $Ctrl.Node.Control("C:\FileVm\server.fex")

# // Object instantiation
$Vm.Update(0,"[~] Object instantiation")
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

# // Start Machine, grab keyboard
$Vm.Update(0,"[~] Starting Vm: $($Vm.Name) @ $($Vm.Now())")
$Vm.Start()
$Vm.Timer(1)

# // Check if the machine is running...
$Vm.Update(0,"[~] Check if the machine is running...")
Switch ([UInt32]($Vm.Get().State -eq "Running"))
{
    0
    {
        $Vm.Update(-1,"[!] Virtual machine not running")
        $Vm.Remove()
        Throw $Vm.Console.Last()
    }
    1
    {
        $Vm.Update(1,"[+] Virtual machine is running")
    }
}

# // Get keyboard
$Vm.Update(0,"[~] Getting keyboard")
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name
If (!!$Vm.Control -and !!$Vm.Keyboard)
{
    $Vm.Update(0,"[+] Started, grabbed keyboard")
}
Else
{
    $Vm.Update(100,"[!] Keyboard not found")
    Throw $Vm.Console.Last().Status
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
   \\__//¯¯¯ Customize - Set default administrator account                                                  ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Vm.Update(0,"[~] Customize - Set default administrator account")
$Ctrl.Module.Write($Vm.Console.Last().Status)

$Setup = ($Vm.Account | ? Type -eq Setup)[0]

# // [Create a super memorable password/Confirm]
$Vm.TypePassword($Setup)
$Vm.TypeKey(9)
$Vm.TypePassword($Setup)
$Vm.TypeKey(13)
$Vm.Timer(15)
$Vm.Idle(5,5)

# Log in
$Vm.Update(0,"[~] Logging in")
$Vm.Login($Setup)
$Vm.Timer(30)
$Vm.Idle(5,5)

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

# // Save checkpoint
<#
$Vm.Object | Checkpoint-Vm -SnapshotName ("{0}-{1}" -f $Vm.Name, $Vm.Now())
$Cp = (Get-VmCheckpoint -VMName $Vm.Name | ? Name -match "\d{4}\-\d{4}_\d{6}")[-1]
$Vm.Checkpoint += $Vm.NewVmControllerNodeCheckpoint($Vm.Checkpoint.Count,$Cp)
#>

# // Restore checkpoint
<#
$Vm.RestoreCheckpoint($Cp.Name)
$Vm.Idle(5,5)
#>

# // Initialize Smb control mechanism
$Vm.Update(0,"[~] Initialize Smb control mechanism")
$System = $Vm.Account | ? Type -eq System
<#
$Splat          = @{

    Name        = "Transfer$"
    Path        = "C:\Transfer"
    Description = "Virtual Machine Host"
    FullAccess  = "Administrators","Everyone"
}
New-SmbShare @Splat -Verbose
#>

$Share  = Get-SmbShare | ? Name -eq Transfer$
If (!$Share)
{
    $Vm.Update(0,"[!] No share")
    Throw $Vm.Console.Last().Status
}

$Vm.SetSmb($Share,$System)
$Vm.SetSmbMapping()

# // Initialize-VmNode over SMB
$Vm.Update(0,"[~] Initialize-VmNode over Smb")
$File = Get-ChildItem $Vm.Smb.LocalPath | ? Name -match "Initialize-VmNode.ps1"
If (!$File)
{
    $Vm.Update(-1,"[!] Initialize-VmNode.ps1 missing from Smb share")
    Throw $Vm.Console.Last().Status
}
Else
{
    $Vm.Update(1,"[+] Initialize-VmNode.ps1 found, will propagate over Smb")
}

$Variable = '$Ctrl'
$Scriptlet = @(
"Set-ExecutionPolicy Bypass -Scope Process -Force";
'$Path = "{0}\{1}"' -f $Vm.Smb.RemotePath, $File.Name;
'$Function = [System.IO.File]::ReadAllLines($Path)';
'Invoke-Expression ($Function -join "`n")';
"{0}" -f $Vm.InitializeVmNode($Variable);
"{0}" -f $Vm.InitializeVmNodeDhcp($Variable);
'{0}.Instantiate()' -f $Variable;
'{0}.SetFunction($Function)' -f $Variable;
'{0}.SetSmb($Splat)' -f $Variable
'{0}.Status("[+] Initialize-VmNode over Smb")' -f $Variable)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# // Set powercfg settings
$Scriptlet = @(
'powercfg -change -monitor-timeout-ac 0';
'powercfg -change -monitor-timeout-dc ([TimeSpan]"00:10:00")';
'powercfg -change -standby-timeout-ac 0';
'powercfg -change -standby-timeout-dc ([TimeSpan]"01:00:00")';
"{0}.Status('[+] Power Configuration')" -f $Variable)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# // Download [KB4486129] Microsoft .NET Framework 4.8 for [Windows Server 2016]
$Vm.Update(0,"[~] Download [KB4486129] Microsoft .NET Framework 4.8 for [Windows Server 2016]")
$Source      = "https://download.visualstudio.microsoft.com/download/pr",
               "2d6bb6b2-226a-4baa-bdec-798822606ff1",
               "8494001c276a4b96804cde7829c04d7f",
               "ndp48-x86-x64-allos-enu.exe" -join "/"

$Scriptlet   = @(
"`$Source      = '$Source'";
"`$Destination = '{0}\Downloads\{1}' -f `$Home, `$Source.Split('/')[-1]";
'$Script = {';
'param($Source,$Destination,$Ctrl)';
"`$Start = [DateTime]::Now"
"Start-BitsTransfer -Source `$Source -Destination `$Destination -Description '{0}'" -f $Vm.Console.Last().Status;
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'$Status = Switch ([UInt32][System.IO.File]::Exists($Destination))';
'{';
'    0 { "[!] KB4486129 not downloaded" } 1 { "[+] KB4486129 downloaded" }';
'}';
'{0}.Status("$Status [$Elapsed]")' -f $Variable;
'}';
'&$Script $Source $Destination $Ctrl')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(240)

# // Install [KB4486129] Microsoft .NET Framework 4.8 for [Windows Server 2016]
$Vm.Update(0,"[~] Install [KB4486129] Microsoft .NET Framework 4.8 for [Windows Server 2016]")
$Scriptlet = @(
'$Script = {';
'param($Start,$Ctrl)';
'$Activity = "Installing : [KB4486129] Microsoft .NET Framework 4.8 for [Windows Server 2016]"';
'$HotFix = $Null';
'$X = -1';
'Do';
'{';
'    If ($X -in -1,100)';
'    {';
'        $X = 0';
'        $HotFix = Get-HotFix | ? HotFixId -eq KB4486129';
'    }';
'    Write-Progress -Activity $Activity -PercentComplete $X';
'    Start-Sleep -Milliseconds 125';
'    $X ++';
'}';
'Until ($HotFix)';
'Write-Progress -Activity $Activity -Complete';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("[+] Installed KB4486129 [$Elapsed]")' -f $Variable;
"}";
'$Start = [DateTime]::Now';
'Start-Process -FilePath $Destination -ArgumentList "/q /norestart"';
'& $Script $Start $Ctrl')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(400)

# Reboot for KB4486129 + ComputerName
$Vm.Update(0,"[~] Reboot for KB4486129 + ComputerName")
$Vm.TypeLine("shutdown -r -t 5")
$Vm.TypeKey(13)
$Vm.Uptime(0,5)
$Vm.Uptime(1,60)
$Vm.Idle(5,5)

# Login
$Vm.Login($Setup)
$Vm.Timer(30)
$Vm.Idle(5,5)
$Vm.LaunchPs()

# Reinitialize VmNode
$Vm.Update(0,"[~] Reinitialize VmNode")
$Scriptlet = @(
'. (Get-ItemProperty "HKLM:\Software\Policies\Secure Digits Plus LLC\ComputerInfo").Function';
'{0} = Initialize-VmNode -Reinitialize' -f $Variable;
'If ({0}.Smb.Connected)' -f $Variable;
'{';
'    {0}.Status("[+] Reinitialized VmNode")' -f $Variable;
'}')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# Everything from here down needs tweaking for the new Smb control mechanism

# // Run all separate scripts
$Vm.Update(0,"[~] Run all separate scripts")
ForEach ($Script in $Vm.Script.Output | ? Complete -eq 0)
{
    $Script = $Vm.Script.Current()
    $Vm.Update(0,"[~] $($Script.DisplayName)")

    Switch ($Script.Name)
    {
        InstallFeModule
        {
            $Vm.RunScript()
            $Vm.Timer(60)
            $Vm.Idle(5,5)

            $Caption = "Set Screen Resolution"
            $Title   = "This section requires manual entry, proceed?"
            $Options = "&Yes","&No"
            $Default = 0
            
            $Vm.Update(0,"[~] $Caption")
            Switch ($Host.UI.PromptForChoice($Caption,$Title,$Options,$Default))
            {
                0
                {
                    $Vm.TypeLine("Set-ScreenResolution -Width 1280 -Height 720")
                    $Vm.TypeKey(13)
                    $Vm.Idle(5,5)
                }
                1
                {

                }
            }
        }
        InstallVsCode
        {
            # Initialize script
            $Vm.RunScript()
            $Vm.Timer(90)
            $Vm.Idle(5,5)
        }
        Restart
        {
            # Initialize script
            $Vm.RunScript()
            $Vm.Uptime(0,5)
            $Vm.Uptime(1,60)
            $Vm.Idle(5,5)

            # Login
            $Vm.Login($Setup)
            $Vm.Timer(30)
            $Vm.Idle(5,5)
            $Vm.LaunchPs()

            # Reinitialize VmNode
            $Vm.Update(0,"[~] Reinitialize VmNode")
            $Scriptlet = @(
            '. (Get-ItemProperty "HKLM:\Software\Policies\Secure Digits Plus LLC\ComputerInfo").Function';
            '{0} = Initialize-VmNode -Reinitialize' -f $Variable;
            'If ({0}.Smb.Connected)' -f $Variable;
            '{';
            '    {0}.Status("[+] Reinitialized VmNode")' -f $Variable;
            '}')

            ForEach ($Line in $Scriptlet)
            {
                $Vm.TypeLine($Line)
                $Vm.TypeKey(13)
            }

            $Vm.SmbIdle(30)
        }
        Default
        {
            # Initialize script
            $Vm.RunScript()
        }
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Configure [~] Dhcp                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>
    $Caption = "Domain Controller Promotion"
    $Title   = "This section requires manual entry, proceed?"
    $Options = "&Yes","&No"
    $Default = 0
    
    $Vm.Update(0,"[~] $Caption")
    Switch ($Host.UI.PromptForChoice($Caption,$Title,$Options,$Default))
    {
        0
        {
            # // Launch Get-FEDCPromo -Mode 1
            $Vm.Update(1,"[+] Launch Get-FEDCPromo -Mode 1")
            $Vm.TypeLine("Get-FEDCPromo -Mode 1")
            $Vm.TypeKey(13)
            $Vm.Timer(30)
            $Vm.Idle(5,5)

            # // Install all required features, then restart
            $Vm.Update(0,"[~] Install all required features, then restart")
            $Vm.Uptime(0,5)
            $Vm.Uptime(1,60)
            $Vm.Idle(5,5)

            # // Login to promote server to domain controller
            $Vm.Update(0,"[~] Login to promote server to domain controller")
            $Vm.Login($Account)

            # // Await for reboot and first domain controller boot
            $Vm.Update(0,"[~] Await for reboot and first domain controller boot")
            $Vm.Uptime(0,5)
            $Vm.Uptime(1,360)
            $Vm.Idle(5,5)

            # // First login on Active Directory Domain Controller
            $Vm.Update(0,"[~] First login on Active Directory Domain Controller")
            $Vm.Login($Account)
            $Vm.Timer(30)
            $Vm.Idle(5,5)
            $Vm.LaunchPs()

            # // Continue setting up Dhcp
            $Vm.Update(0,"[~] Continue setting up Dhcp")

            $Vm.Script.Add($Vm.Script.Output.Count,'ConfigureDhcp','Configure Dhcp',@(
            '$Path      = "HKLM:\Software\Policies\Secure Digits Plus LLC\ComputerInfo"';
            '$Item      = Get-ItemProperty $Path';
            '$Item.Dhcp = Get-ItemProperty $Path\Dhcp';
            '$Item.Dhcp.Exclusion = $Item.Dhcp.Exclusion -Replace "@\(\[String\[\]\]","" -Replace "(`"|\))","" -Split ","';
            '$Item.Dns  = $Item.Dns -Replace "@\(\[String\[\]\]","" -Replace "(`"|\))","" -Split ", "';
            'If ($Item.IpAddress -notin $Item.Dhcp.Exclusion)';
            '{';
            '    $Item.Dhcp.Exclusion += $Item.IpAddress';
            '}';
            ' ';
            '$Splat = @{';
            ' ';
            '    StartRange = $Item.Dhcp.StartRange';
            '    EndRange   = $Item.Dhcp.EndRange';
            '    Name       = $Item.Dhcp.Name';
            '    SubnetMask = $Item.Dhcp.SubnetMask';
            '}';
            ' ';
            'Add-DhcpServerV4Scope @Splat -Verbose';
            '<Timer[5]>';
            'Add-DhcpServerInDc -Verbose';
            ' ';
            'ForEach ($Value in $Item.Dhcp.Exclusion)';
            '{';
            '    $Splat         = @{';
            ' ';
            '        ScopeId    = $Item.Dhcp.Network';
            '        StartRange = "$Value"';
            '        EndRange   = "$Value"';
            '    }';
            ' ';
            '    Add-DhcpServerV4ExclusionRange @Splat -Verbose';
            '}';
            ' ';
            '(3,$Item.Gateway),';
            '(6,$Item.Dns),';
            '(15,$Item.Domain),';
            '(28,$Item.Dhcp.Broadcast) | % {';
            ' ';
            '    Set-DhcpServerV4OptionValue -OptionId $_[0] -Value $_[1] -Verbose';
            '}';
            ' ';
            'netsh dhcp add securitygroups';
            'Restart-Service dhcpserver';
            ' ';
            '$Splat    = @{';
            ' ';
            '    Path  = "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12"';
            '    Name  = "ConfigurationState"';
            '    Value = 2';
            '}';
            ' ';
            'Set-ItemProperty @Splat -Verbose'))
            $Vm.RunScript()
        }
        1
        {
            # // User cancelled the dialog
            $Vm.Update(0,"[!] User cancelled the dialog")
            $Ctrl.Module.Write(1,$Vm.Console.Last().Status)
            $Vm.Script.Current().Completed ++
            $Vm.Script.Selected ++
        }
    }

    # InitializeFeAd ([Object]$Account)

    # [Phase 13] Initialize [FightingEntropy()] AdInstance
    $User = ($Vm.Account | ? Type -eq User)[0]
    $Scriptlet = @(
    '$Password = Read-Host "Enter password" -AsSecureString';
    '<Timer[2]>';
    '{0}' -f $User.Password();
    '$Ctrl = Initialize-FeAdInstance';
    '<Timer[10]>';
    '<Idle[5,5]>';
    '# Set location';
    '$Ctrl.SetLocation("1718 US-9","Clifton Park","NY",12065,"US")';
    ' ';
    '# Add Organizational Unit';
    '$Ctrl.AddAdOrganizationalUnit("DevOps","Developer(s)/Operator(s)")';
    ' ';
    '# Get Organizational Unit';
    '$Ou     = $Ctrl.GetAdOrganizationalUnit("DevOps")';
    ' ';
    '# Add Group';
    '$Ctrl.AddAdGroup("Engineering","Security","Global","Secure Digits Plus LLC",$Ou.DistinguishedName)';
    ' ';
    '# Get Group';
    '$Group  = $Ctrl.GetAdGroup("Engineering")';
    ' ';
    '# Add-AdPrincipalGroupMembership';
    '$Ctrl.AddAdPrincipalGroupMembership($Group.Name,@("Administrators","Domain Admins"))';
    ' ';
    '# Add User';
    '$Ctrl.AddAdUser("Michael","C","Cook","{0}",$Ou.DistinguishedName)' -f $User.Username;
    ' ';
    '# Get User';
    '$User   = $Ctrl.GetAdUser("Michael","C","Cook")';
    ' ';
    '# Set [User.General (Description, Office, Email, Homepage)]';
    '$User.SetGeneral("Beginning the fight against ID theft and cybercrime",';
    '                 "<Unspecified>",';
    '                 "michael.c.cook.85@gmail.com",';
    '                 "https://github.com/mcc85s/FightingEntropy")';
    ' ';
    '# Set [User.Address (StreetAddress, City, State, PostalCode, Country)] ';
    '$User.SetLocation($Ctrl.Location)';
    ' ';
    '# Set [User.Profile (ProfilePath, ScriptPath, HomeDirectory, HomeDrive)]';
    '$User.SetProfile("","","","")';
    ' ';
    '# Set [User.Telephone (HomePhone, OfficePhone, MobilePhone, Fax)]';
    '$User.SetTelephone("","518-406-8569","518-406-8569","")';
    ' ';
    '# Set [User.Organization (Title, Department, Company)]';
    '$User.SetOrganization("CEO/Security Engineer","Engineering","Secure Digits Plus LLC")';
    ' ';
    '# Set [User.AccountPassword]';
    '$User.SetAccountPassword($Password)';
    ' ';
    '# Add user to group';
    '$Ctrl.AddAdGroupMember($Group,$User)';
    ' ';
    '# Set user primary group';
    '$User.SetPrimaryGroup($Group)')

    # // Initialize [FightingEntropy(π)] Active Directory Instance
    $Vm.Update(0,"[~] Initialize [FightingEntropy(π)] Active Directory Instance")

    $User = ($Vm.Account | ? Type -eq User)[0]
    $Vm.InitializeFeAd($User)

$Script  = $Vm.Script.Current()
$Vm.Update(0,"[~] $($Script.DisplayName)")
$Vm.RunScript()

# // Install Microsoft Edge
$Vm.Update(0,"[~] Install Microsoft Edge")
$Vm.TypeLine("choco install microsoft-edge -y")
$Vm.TypeKey(13)
$Vm.Timer(240)
$Vm.Idle(5,5)

# // Install the Michaelsoft Deployment Toolkit (WinPe setup gets stuck...)
$Source    = "{0}/blob/main/Version/2024.1.0/Functions/Get-MdtModule.ps1?raw=true" -f $Ctrl.Module.Source
$Scriptlet = @("[Net.ServicePointManager]::SecurityProtocol = 3072",
"Invoke-RestMethod $Source | Invoke-Expression",
'$Mdt = Get-MdtModule',
'$Mdt.Install()')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}
$Vm.Idle(5,5)

# [ ] Setup a Samba share to upload (an) image(s)
$Scriptlet = @(
'$Path = "C:\Images"',
'$Name = "{0}$" -f $Path.Split("\")[-1]',
'If (![System.IO.Directory]::Exists($Path))',
'{',
'    [System.IO.Directory]::CreateDirectory($Path)',
'}',
' ',
'$Splat = @{',
' ',
'    Name        = "{0}$" -f $Name',
'    Path        = $Path',
'    Description = "Network ISO share"',
'    FullAccess  = "Administrators"',
' ',
'}',
'New-SmbShare @Splat -Verbose')

# [ ] Establish a PSDrive connection to transfer the images to remote Samba share
$Splat = @{ 

    Name        = "Images"
    PSProvider  = "Filesystem"
    Root        = "\\server\Images$"
    Description = "Network ISO Share"
    Credential  = $User.Credential
}

New-PsDrive @Splat -Verbose

# [ ] Copy the image(s) to the samba share, not the PSDrive
$Images = Get-ChildItem C:\Images -File

ForEach ($File in $Images)
{
    $Destination = "\\server\Images$\{0}" -f $Item.Name
    Copy-FileStream -Source $Item.Fullname -Destination $Destination
}

$Path = "C:\Images"
$Name = $Path.Split("\")[-1]
[System.IO.Directory]::CreateDirectory($Path)
New-SmbShare -Name $Name -Path $Path

# [ ] Connect to custom account using RDP
# [ ] Connect to custom account using WinRM
