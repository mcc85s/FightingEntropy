<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Virtualization Lab [~] Windows Server 2016 -> New-VmController 2024.1.0                        ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

\______________________________________________________________________________________________________________________/
 Introduction /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯

    In this video, I will be building a brand new Hyper-V VM using the function [New-VmController] in 
    [FightingEntropy(π)][2024.1.0], to deploy [Windows Server 2016] to meet the following criteria:
    ____________
    | Criteria |
    ¯¯¯¯¯¯¯¯¯¯¯¯
    - Configure the <virtual machine template> using the (New-VmController) <graphical user interface>
      for (New-VmController)... the template will be saved to a <file> that can be used to perform
      <advanced control> over the <virtual machine template>
    - Install [FightingEntropy(π)][2024.1.0] to use <additional functions> for <system configuration>
    - Set <virtual machine template> properties to <persist> BEFORE promoting the <virtual server> to:
      _________________________________________________________________
      | Id   | Name                             | Role                |
      |======|==================================|=====================|
      | ADDS | Active Directory Domain Services | <domain controller> |
      | DHCP | Dynamic Host Control Protocol    | <server>            |
      | DNS  | Domain Name Service              | <server>            |
      | IIS  | Internet Information Services    | <server>            |
      | WDS  | Windows Deployment Services      | <server>            |
      | MDT  | Michaelsoft Deployment Toolkit   | <server             |
      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    - Configure <organizational unit>, <security group>, <user [domain admin]>, and <group policy>
    - Allow [Remote Desktop] connection for that <user [domain admin]>
    - Allow [WinRM console connection] for that <user [domain admin]>
    - Show off a couple of other really cool and relevant functions in [FightingEntropy(π)][2024.1.0],
      like [Get-ViperBomb], and [Invoke-cimdb]

    In order to meet ALL of this criteria, I will be deploying [FightingEntropy(π)][2024.1.0] to
    the <virtual server>, and then using some of the OTHER functions in the module:

    [+] Initialize-VmNode
    [+] Get-FEDCPromo
    [+] Initialize-FeAdInstance
    [+] Get-MdtModule

    Doing ALL of these things in <order> will allow me to continue to develop [New-FEInfrastructure],
    which has NOT yet been updated, but will likely be updated within the next month or two.

    As for (New-VmController v2024.1.0), I've reimplemented a <control mechanism> that uses
    <SMB/server message block> to control the flow of information between the <virtual machine host>,
    and the <virtual machine guest [server]>, and will be demonstrating how that works. However,
    I will ALSO be using the function (Start-TCPSession) to transmit scripts to the <virtual machine>,
    and then <executing> those scripts.
    
    Here is a list of other videos that demonstrate what [New-VmController] (does/can do):

    /¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    \ Date     | Name                                      | Link                         /
    / 12/05/21 | [FightingEntropy(π)] New-FEInfrastructure | https://youtu.be/6yQr06_rA4I \
    \ 03/20/23 | Virtualization Lab - Desktop Deployment   | https://youtu.be/i2_fafoIx6I /
    / 04/03/23 | Virtualization Lab - TCP Session          | https://youtu.be/09c-fFbEQrU \
    \ 04/12/23 | Virtualization Lab - RHEL Deployment      | https://youtu.be/AucVPa_EpQc /
    / 04/30/23 | Virtualization Lab - Windows 11           | https://youtu.be/OmTRiYemQAI \
    \ 01/06/24 | Virtualization Lab - Windows 10 22H2      | https://youtu.be/g3GJe00WJLg /
     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                                                                                                         ______________/
\_______________________________________________________________________________________________________/ Introduction
 Notes /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯

    - The [Michaelsoft Deployment Toolkit] is actually called the [Microsoft Deployment Toolkit], and was originally
      [Business Desktop Deployment], developed by a <badass> named [Michael T. Niehaus]

    - Another <badass> named [Jeffrey Snover] told red rover to move over, and now we have [PowerShell]

    - They are both former (head honchos/executives/wizards) at the [Microsoft Corporation] located at:
      _______________________________________________
      | One Microsoft Way, Redmond Washington 98052 |
      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    - (Niehaus + Snover) BOTH had heavy involvement in the development of either [PowerShell] or [BDD/MDT/SCCM], 
      whereby setting the benchmark [quite high] in terms of building things that [work well] + do a LOT of [work].

    - Microsoft is currently the most valuable company in the world with an estimated value of about [$3T]
#>

$Ctrl = New-VmController # <- using this function returns the node controller which can STILL launch the GUI

<# [To invoke the GUI]
$Ctrl.Reload()
#>

$Vm                  = $Ctrl.Node.Control("C:\FileVm\dsc0.fex")
$Vm.Role.Description = $Vm.Image.Edition.DestinationName

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
    0 { $Vm.Error("[!] Virtual machine not running")   }
    1 { $Vm.Update(1,"[+] Virtual machine is running") }
}

# // Get keyboard
$Vm.Update(0,"[~] Getting keyboard")
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name

Switch ([UInt32](!!$Vm.Control -and !!$Vm.Keyboard))
{
    0 { $Vm.Error("[!] Keyboard not found")           }
    1 { $Vm.Update(0,"[+] Started, grabbed keyboard") }
}

# // Wait for <Press enter to boot from CD/DVD>, then start <64-bit>
$Vm.Update(0,"[~] Wait for <Press enter to boot from CD/DVD>, then start <64-bit>")
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(2)
$Vm.TypeKey(13)

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
Try
{
    $Vm.CheckpointNew()
}
Catch
{
    Import-Module Hyper-V -Force
    $Vm.CheckpointRefresh()
}

<# // Restore checkpoint, reload scriptblock engine
$Vm.CheckpointRestore(1)
$Vm.Script.Clear()
$Vm.Load()
$Vm.Script.Selected = 0
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
    $Vm.Error("[!] No share")
}

$Vm.SetSmb($Share,$System)
$Vm.SetSmbMapping()

# // Install [FightingEntropy(π)][2024.1.0]
$Vm.Update(0,"[~] Install [FightingEntropy(π)][2024.1.0]")
$Version = Invoke-RestMethod ("{0}/blob/main/FightingEntropy.ps1?raw=true" -f $Ctrl.Module.Source)
$Install = "{0}?raw=true" -f $Version.TrimEnd("`n")
$Scriptlet = @(
"[Net.ServicePointManager]::SecurityProtocol = 3072";
"Set-ExecutionPolicy Bypass -Scope Process -Force";
"Invoke-RestMethod $Install | Invoke-Expression";
'$Module.Latest()';
'Import-Module FightingEntropy')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.Timer(30)
$Vm.Idle(5,10)

# // Set screen resolution 1280x720
$Vm.Update(0,"[~] Set screen resolution 1280x720")
$Vm.TypeLine("Set-ScreenResolution 1280 720")
$Vm.TypeKey(13)

<# // Initialize-VmNode over SMB
$Vm.Update(0,"[~] Initialize-VmNode over Smb")
$File = Get-ChildItem $Vm.Smb.LocalPath | ? Name -match "Initialize-VmNode.ps1"
Switch ([UInt32]!!$File)
{
    0 { $Vm.Error("[!] Initialize-VmNode.ps1 missing from Smb share")            }
    1 { $Vm.Update(1,"[+] Initialize-VmNode.ps1 found, will propagate over Smb") }
}#>

# // Set remote variable(s)
If ('$Ctrl' -notin $Vm.Variable.Output.Name)
{
    $Vm.Variable.Add("Remote",'$Ctrl',"Initialize-VmNode")
}
$V = $Vm.Variable.Get(0).Name

# // Instantiate Initialize-VmNode from [FightingEntropy(π)][2024.1.0]
$Vm.Update(0,"[~] Instantiate Initialize-VmNode from [FightingEntropy(π)][2024.1.0]")
$Scriptlet = @(
"{0}" -f $Vm.InitializeVmNode($V);
"{0}" -f $Vm.InitializeVmNodeDhcp($V);
'{0}.Instantiate()' -f $V;
'{0}.SetSmb($Splat)' -f $V
'{0}.Status("[+] Instantiate Initialize-VmNode from [FightingEntropy(π)][2024.1.0]")' -f $V)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# // Power Configuration
$Vm.Update(0,"[~] Power Configuration")

$Scriptlet = @(
'powercfg -change -monitor-timeout-ac 0';
'powercfg -change -monitor-timeout-dc ([TimeSpan]"00:10:00")';
'powercfg -change -standby-timeout-ac 0';
'powercfg -change -standby-timeout-dc ([TimeSpan]"01:00:00")';
"{0}.Status('[+] Power Configuration')" -f $V)

$Content = $Vm.TransmitScript("SetPowerOptions","Set Power Options",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

$Vm.TypeLine("{0}.Execute(0)" -f $V)
$Vm.TypeKey(13)
$Vm.SmbIdle(30)

# // Download: KB4486129 - Microsoft .NET Framework 4.8 for Windows Server 2016
$Vm.Update(0,"[~] Download: KB4486129 - Microsoft .NET Framework 4.8 for Windows Server 2016")

$Source      = "https://download.visualstudio.microsoft.com/download/pr",
               "2d6bb6b2-226a-4baa-bdec-798822606ff1",
               "8494001c276a4b96804cde7829c04d7f",
               "ndp48-x86-x64-allos-enu.exe" -join "/"

$Scriptlet   = @(
"`$Source = '{0}'" -f $Source;
"`$Destination = '{0}\Downloads\{1}' -f `$Home, `$Source.Split('/')[-1]";
'$Script = {';
'param($Source,$Destination,{0})' -f $V;
"`$Start = [DateTime]::Now"
"Start-BitsTransfer -Source `$Source -Destination `$Destination -Description '{0}'" -f $Vm.Console.Last().Status;
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'$Status = Switch ([UInt32][System.IO.File]::Exists($Destination))';
'{';
'    0 { "[!] KB4486129 not downloaded" } 1 { "[+] KB4486129 downloaded" }';
'}';
'{0}.Status("$Status [$Elapsed]")' -f $V;
'}';
'& $Script $Source $Destination {0}' -f $V)

$Content = $Vm.TransmitScript("DownloadKB4486129","Download - Microsoft .NET Framework 4.8 for Windows Server 2016",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

$Vm.TypeLine("{0}.Execute(1)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(240)

# // Install KB4486129: Microsoft .NET Framework 4.8 for Windows Server 2016
$Vm.Update(0,"[~] Install: KB4486129 - Microsoft .NET Framework 4.8 for Windows Server 2016")

$Scriptlet = @(
"`$Source = '{0}'" -f $Source;
"`$Destination = '{0}\Downloads\{1}' -f `$Home, `$Source.Split('/')[-1]";
'$Scriptlet = {';
'param($Destination,{0})' -f $V;
'$Start = [DateTime]::Now';
'Start-Process -FilePath $Destination -ArgumentList "/q /norestart"';
'$Activity = "Install: KB4486129 - Microsoft .NET Framework 4.8 for Windows Server 2016"';
'$HotFix = $Null';
'$X = -1';
'Do';
'{';
'    If ($X -in -1,101)';
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
'{0}.Status("[+] Installed KB4486129 [$Elapsed]")' -f $V;
"}";
'& $Scriptlet $Destination {0}' -f $V)

$Content = $Vm.TransmitScript("InstallKB4486129","Install - Microsoft .NET Framework 4.8 for Windows Server 2016",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

$Vm.TypeLine("{0}.Execute(2)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(600)

# // Reboot: KB4486129 + ComputerName
$Vm.Update(0,"[~] Reboot: KB4486129 + ComputerName")
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
'{0} = Initialize-VmNode -Reinitialize' -f $V;
'If ({0}.Smb.Connected)' -f $V;
'{';
'    Get-ChildItem {0}.Smb.LocalPath | Out-Null' -f $V;
'    {0}.Status("[+] Reinitialized VmNode")' -f $V;
'}')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# // Execute scripts 0..4 + 6
# // Set Time zone | Set Icmp Firewall | Set WinRm | Set WinRm Firewall | Set Remote Desktop | Install Chocolatey
$Vm.Update(0,"Running [~] Timezone, Icmp, WinRm, Remote Desktop + Chocolatey scripts")
ForEach ($Script in $Vm.Script.Output[0..4+6])
{
    $Vm.Script.Selected = $Script.Index
    $Vm.RunScript()
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Get-FEDCPromo [+] Domain Controller Promotion                                                  ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

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
$Vm.Login($Setup)

# // Await for reboot and first domain controller boot
$Vm.Update(0,"[~] Await for reboot and first domain controller boot")
$Vm.Uptime(0,5)
$Vm.Uptime(1,360)
$Vm.Idle(5,5)

# // First login on Active Directory Domain Controller
$Vm.Update(0,"[~] First login on Active Directory Domain Controller")
$Vm.Login($Setup)
$Vm.Timer(30)
$Vm.Idle(5,5)
$Vm.LaunchPs()

# // Reinitialize VmNode
$Vm.Update(0,"[~] Reinitialize VmNode")
$Scriptlet = @(
'{0} = Initialize-VmNode -Reinitialize' -f $V;
'If ({0}.Smb.Connected)' -f $V;
'{';
'    Get-ChildItem {0}.Smb.LocalPath | Out-Null' -f $V;
'    {0}.Status("[+] Reinitialized VmNode")' -f $V;
'}')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

# // Complete initial Dhcp configuration
$Vm.Update(0,"[~] Complete initial Dhcp configuration")

$Scriptlet   = @(
'$Script = {';
'param({0})' -f $V
'$Network = {0}.Network' -f $V
'$Dhcp = $Network.Dhcp'
'$Splat = @{';
'    StartRange = $Dhcp.StartRange'
'    EndRange   = $Dhcp.EndRange'
'    Name       = $Dhcp.Name'
'    SubnetMask = $Dhcp.SubnetMask'
'}';
'Add-DhcpServerV4Scope @Splat -Verbose';
'Add-DhcpServerInDc -Verbose';
'ForEach ($Value in $Dhcp.Exclusion)'
'{';
'    $Splat = @{';
'        ScopeId    = $Dhcp.Network'
'        StartRange = "$Value"';
'        EndRange   = "$Value"';
'    }';
'    Add-DhcpServerV4ExclusionRange @Splat -Verbose';
'}';
'ForEach ($Item in (3,$Network.Gateway),';
'(15,$Network.Domain),'
'(28,$Dhcp.Broadcast))'
'{'
'    Set-DhcpServerV4OptionValue -OptionId $Item[0] -Value $Item[1] -Verbose';
'}';
'ForEach ($Item in $Network.Dns)';
'{'
'    Try';
'    {';
'        Set-DhcpServerV4OptionValue -OptionId 6 -Value $Item -Verbose';
'    }';
'    Catch';
'    {';
'    }';
'}';
'netsh dhcp add securitygroups';
'Restart-Service dhcpserver';
'$Splat    = @{';
' ';
'    Path  = "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12"';
'    Name  = "ConfigurationState"';
'    Value = 2';
'}';
'Set-ItemProperty @Splat -Verbose';
'{0}.Status("[+] Complete initial Dhcp configuration")' -f $V;
'}';
'& $Script {0}' -f $V);

$Content = $Vm.TransmitScript("ConfigureDhcp","Configure Dhcp",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

$Vm.TypeLine("{0}.Execute(0)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(600)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Initialize-FEAdInstance [+] Active Directory Configuration                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>
$Vm.CheckpointNew()

<# [Restore checkpoint #2]
$Vm.CheckpointRestore(2)
#>

$Vm.Update(0,"[~] Initialize-FEAdInstance -> Active Directory Configuration")
$User = ($Vm.Account | ? Type -eq User)[0]

# // Set password variable
$Vm.TypeLine("`$Password = Read-Host `"<Enter Password>`" -AsSecureString")
$Vm.TypeKey(13)
$Vm.TypePassword($User)
$Vm.TypeKey(13)

# // Set remote variable(s)
If ('$Ad' -notin $Vm.Variable.Output.Name)
{
    $Vm.Variable.Add("Remote",'$Ad',"Initialize-FeAdInstance")
}
$W = $Vm.Variable.Get(1).Name

$Scriptlet = @(
'$Script = {';
'param($Password,{0})' -f $V
'{0} = Initialize-FeAdInstance' -f $W
'{0}.SetLocation("1718 US-9","Clifton Park","NY",12065,"US")' -f $W;
'{0}.AddAdOrganizationalUnit("DevOps","Developer(s)/Operator(s)")' -f $W;
'$Ou = {0}.GetAdOrganizationalUnit("DevOps")'  -f $W;
'{0}.AddAdGroup("Engineering","Security","Global","Secure Digits Plus LLC",$Ou.DistinguishedName)' -f $W;
'$Group = {0}.GetAdGroup("Engineering")' -f $W;
'{0}.AddAdPrincipalGroupMembership($Group.Name,@("Administrators","Domain Admins"))' -f $W;
'{0}.AddAdUser("Michael","C","Cook","{1}",$Ou.DistinguishedName)' -f $W, $User.Username;
'$User = {0}.GetAdUser("Michael","C","Cook")' -f $W;
'$User.SetGeneral("Beginning the fight against ID theft and cybercrime",';
'"<Unspecified>",';
'"michael.c.cook.85@gmail.com",';
'"https://github.com/mcc85s/FightingEntropy")';
'$User.SetLocation({0}.Location)' -f $W;
'$User.SetProfile("","","","")';
'$User.SetTelephone("","518-406-8569","518-406-8569","")';
'$User.SetOrganization("CEO/Security Engineer","Engineering","Secure Digits Plus LLC")';
'$User.SetAccountPassword($Password)';
'{0}.AddAdGroupMember($Group,$User)' -f $W
'$User.SetPrimaryGroup($Group)';
'{0}.Policy.Add("Server Integrity","Sets LDAP signing requirements")' -f $W;
'$Policy = {0}.Policy.Get(2)' -f $W;
'$Policy.Create()';
'$Policy.AddProperty("Server Integrity","HKLM\System\CurrentControlSet\Services\NTDS\Parameters","LDAPServerIntegrity","DWord",2)';
'$Policy.SetProperty(0)';
'{0}.Status("[+] Initialize-FeAdInstance completed")' -f $V
'}'
'& $Script $Password {0}' -f $V)

$Content = $Vm.TransmitScript("InitializeFeAdInstance","Initialize FE Active Directory Instance",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

$Vm.TypeLine("{0}.Execute(1)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(120)

# // (Edit + Transmit) scriptblocks prestaged in node controller

<# [Restore checkpoint]
$Vm.CheckpointRestore(3)
#>

# // Install VSCode
$Vm.Update(0,"Transmitting [~] Install VSCode")
$Script    = $Vm.Script.Get("InstallVSCode")
$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
'# Install Visual Studio Code';
'$Start = [DateTime]::Now';
'choco install vscode -y';
'$Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"';
'$VSCode = Get-ItemProperty $Path | ? DisplayName -match "Visual Studio Code"';
'$Status = Switch ([UInt32]!!$VSCode)';
'{';
'    0 { "[!] Visual Studio Code NOT installed" }';
'    1 { "[+] Visual Studio Code ({0}) installed" -f $VSCode.DisplayVersion }';
'}';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("$Status [$Elapsed]")' -f $V;
'}';
'& $Script {0}' -f $V)

$Content   = $Vm.TransmitScript("InstallVsCode","Install Visual Studio Code",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

# // Install BossMode color theme
$Vm.Update(0,"Transmitting [~] Install BossMode color theme")
$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
'# Install BossMode (VS Code color theme)';
'$Start = [DateTime]::Now';
'$Name = "securedigitsplus.bossmode"';
'$FilePath = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
'$ArgumentList = "--install-extension $Name"';
'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewwindow';
'Do';
'{';
'    $Path    = "$home\.vscode\extensions\extensions.json"';
'    $Content = Get-Content $Path -EA 0';
'    $Object  = $Content | ConvertFrom-Json';
'    Start-Sleep 1';
'}';
'Until ($Name -in $Object.Identifier.Id)';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("[+] BossMode theme installed [$Elapsed]")' -f $V;
'}';
'& $Script {0}' -f $V)

$Content   = $Vm.TransmitScript("InstallBossMode","Install BossMode VSCode color theme",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

# // Install PowerShell Extension
$Vm.Update(0,"Transmitting [~] Install PowerShell Extension")
$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
'# Install Visual Studio Code (PowerShell Extension)';
'$Start = [DateTime]::Now';
'$Name = "ms-vscode.PowerShell"';
'$FilePath = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
'$ArgumentList = "--install-extension $Name"';
'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process';
'Do';
'{';
'    $Path    = "$home\.vscode\extensions\extensions.json"';
'    $Content = Get-Content $Path -EA 0';
'    $Object  = $Content | ConvertFrom-Json';
'    Start-Sleep 1';
'}';
'Until ($Name -in $Object.Identifier.Id)';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("PowerShell Extension installed [$Elapsed]")' -f $V;
'}';
'& $Script {0}' -f $V)

$Content   = $Vm.TransmitScript($Script.Name,$Script.DisplayName,$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

# // Install Microsoft Edge
$Vm.Update(0,"[~] Transmitting [~] Microsoft Edge")
$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
'# Install Microsoft Edge';
'$Start = [DateTime]::Now';
'choco install microsoft-edge -y';
'$Path = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"';
'$Edge = Get-ItemProperty $Path | ? DisplayName -match "Microsoft Edge"';
'$Status = Switch ([UInt32]!!$Edge)';
'{';
'    0 { "[!] Microsoft Edge NOT installed" }';
'    1 { "[+] Microsoft Edge ({0}) installed" -f $Edge.Version }';
'}';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("$Status [$Elapsed]")' -f $V;
'}';
'& $Script {0}' -f $V)

$Content   = $Vm.TransmitScript("InstallMsEdge","Install Microsoft Edge",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

# // Install Michaelsoft Deployment Toolkit + WinADK + WinPE
$Vm.Update(0,"[~] Transmitting [~] Michaelsoft Deployment Toolkit + WinADK + WinPE")
$Scriptlet = @(
'$Script = {'
'param({0})' -f $V;
'$Start = [DateTime]::Now'
'# Install the Michaelsoft Deployment Toolkit + WinADK + WinPE';
'$Mdt = Get-MdtModule',
'$Mdt.Install()';
'$Mdt.Refresh()';
'$Status = Switch ($Mdt.Status)'
'{'
'    0 { "[!] Michaelsoft Deployment Toolkit + WinADK + WinPE NOT installed" }'
'    1 { "[+] Michaelsoft Deployment Toolkit + WinADK + WinPE installed" }'
'}'
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)'
'{0}.Status("$Status [$Elapsed]")' -f $V
'}'
'& $Script {0}' -f $V)

$Content   = $Vm.TransmitScript("InstallMdtAdkPe","Install Michaelsoft Deployment Toolkit + WinADK + WinPE",$Scriptlet)

$Vm.TypeLine("{0}.Receive()" -f $V)
$Vm.TypeKey(13)

$Vm.TransmitTcp($Content)

# // Install all transmitted scripts

# // Vs Code
$Vm.Update(0,"[~] Install Visual Studio Code")
$Vm.TypeLine("{0}.Execute(2)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(240)

# // BossMode
$Vm.Update(0,"[~] Install BossMode color theme for Visual Studio Code")
$Vm.TypeLine("{0}.Execute(3)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(120)

# // PowerShell Extension
$Vm.Update(0,"[~] Install PowerShell Extension for Visual Studio Code")
$Vm.TypeLine("{0}.Execute(4)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(120)

# // Install Microsoft Edge
$Vm.Update(0,"[~] Install Microsoft Edge")
$Vm.TypeLine("{0}.Execute(5)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(400)

# // Install Michaelsoft Deployment Toolkit + WinAdk + WinPE
$Vm.Update(0,"[~] Install Michaelsoft Deployment Toolkit + WinAdk + WinPE")
$Vm.TypeLine("{0}.Execute(6)" -f $V)
$Vm.TypeKey(13)

$Vm.SmbIdle(3000)

# [+] WinRM
$Splat = $Vm.PSSession($User)
Enter-PSSession @Splat

# [+] Remote Desktop

<#
$Path = "$Env:windir\system32\drivers\etc\hosts"
$Content = [System.IO.File]::ReadAllLines($Path)
$Content[-1] = $Content[-1].Replace("192.168.4.2","192.168.42.1")
[System.IO.File]::WriteAllLines($Path,$Content)
#>

<# // Setup Smb share for image(s)
$Vm.Update(0,"[~] Setup Smb share for image(s)")
$Share = Get-SmbShare | ? Name -eq Images$
$Image = $Vm.NewVmControllerNodeSmbShare($Share,$System)

# // Password
$Vm.TypeLine('$Password = Read-Host "<Enter Password>" -AsSecureString')
$Vm.TypeKey(13)
$Vm.TypePassword($System)
$Vm.TypeKey(13)
$Vm.TypeLine('$Credential = [PSCredential]::New("{0}",$Password)' -f $System.Credential.Username)
$Vm.TypeKey(13)

# // Scriptlet
$Scriptlet = @(
'$Smb = Get-SmbMapping | % { $_.LocalPath.TrimEnd(":") }'
'$Volume = Get-Volume | ? DriveLetter | % DriveLetter';
'$Letters = @($Volume;$Smb)';
'$Letter = "{0}:" -f ([Char[]](90..65) | ? { $_ -notin $Letters })[0]';
'$Splat = @{';
'    LocalPath   = "$Letter"';
'    RemotePath  = "\\{0}\{1}"' -f $Image.Hostname, $Image.ShareName;
'    Username    = $Credential.Username';
'    Password    = $Credential.GetNetworkCredential().Password';
'}';
'New-SmbMapping @Splat -Verbose')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

# // Transfer images from manifest file
$Vm.Update(0,"[~] Transfer images from manifest file")
$File = Get-ChildItem "C:\Images" | ? Name -match Manifest

$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
'$Start = [DateTime]::Now';
'$Image = Get-SmbMapping | ? RemotePath -match Image';
'$File = Get-ChildItem $Image.LocalPath | ? Name -eq "{0}"' -f $File.Name;
'$Destination = "C:\Images"';
'If (![System.IO.Directory]::Exists($Destination))';
'{';
'    [System.IO.Directory]::CreateDirectory($Destination)';
'}';
'Get-FEImageManifest -Path $File.Fullname -Source $Image.LocalPath -Destination $Destination';
'$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
'{0}.Status("[+] Image Manifest transfer complete [$Elapsed]")' -f $V
'}';
'& $Script {0}' -f $V)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(1800)

<# [Enter-PSSession]

#>
      
<# [ ] Virtual Machine Host set up CredSSP
[Group Policy]
> Computer Configuration
> Administrative Templates
> System
> Credentials Delegation
  > Enabled, Vulnerable

[Registry]
$Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "CredSSP"
$Leaf = "Parameters"
If (!(Test-Path "$Path\$Name"))
{
    New-Item "$Path\$Name" -Verbose
}
If (!(Test-Path "$Path\$Name\$Leaf"))
{
    New-Item "$Path\$Name\$Leaf" -Verbose
}
New-ItemProperty "$Path\$Name\$Leaf" -Name AllowEncryptionOracle -Value 2
#>

<# // Perform second WinRM Configuration
$Vm.Update(0,"[~] Perform second WinRM Configuration")
$Scriptlet = @(
'$DnsName = {0}.Network.Hostname()' -f $V
'$Cert = New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation Cert:\LocalMachine\My'
'$Thumbprint = $Cert.Thumbprint'
'$Hash = "@{Hostname=`"$DnsName`";CertificateThumbprint=`"$Thumbprint`"}"'
"`$Str = `"winrm create winrm/config/Listener?Address=*+Transport=HTTPS '`$Hash'`""
'Invoke-Expression $Str')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

# // Enter PSSession
Enter-PSSession @Splat
#>
