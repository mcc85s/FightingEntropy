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
    - Configure a <virtual machine template> using the (New-VmController) <graphical user interface>
      for (New-VmController)... the template will be saved to a file that can be used to perform
      <advanced control> over the <virtual machine template>
    - install [FightingEntropy(π)][2024.1.0] to use <additional functions> for <system configuration>
    - set <virtual machine template> properties to <persist> BEFORE promoting the <virtual server> to:
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
    - configure a custom <organizational unit>, <security group>, and <user> as <domain admin>
    - allow [Remote Desktop] connection for that <user>
    - allow [WinRM console connection] for that <user>
    - show off a couple of other really cool and relevant functions in [FightingEntropy(π)][2024.1.0],
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
    and the <virtual machine guest/server>, and will be demonstrating how that works, as it
    accomplishes many of the criteria that (Start-TCPSession) does.
    
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

    - Microsoft is currently the most valuable company in the world with an estimated value of about [$2.9T]
#>

$Ctrl = New-VmController # <- using this function returns the node controller which can STILL launch the GUI

<# [To invoke the GUI]
$Ctrl.Reload()
#>

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
$Vm.CheckpointNew()

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
'$Module.Install()';
'Import-Module FightingEntropy')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.Timer(60)
$Vm.Idle(5,10)

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

# // Instantiate Initialize-VmNode
$Vm.Update(0,"[~] Instantiate Initialize-VmNode")
$Scriptlet = @(
'$Path = "{0}\{1}"' -f $Vm.Smb.RemotePath, $File.Name;
"{0}" -f $Vm.InitializeVmNode($V);
"{0}" -f $Vm.InitializeVmNodeDhcp($V);
'{0}.Instantiate()' -f $V;
'{0}.SetSmb($Splat)' -f $V
'{0}.Status("[+] Initialize-VmNode over Smb")' -f $V)

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

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

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

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(240)

# // Install KB4486129: Microsoft .NET Framework 4.8 for Windows Server 2016
$Vm.Update(0,"[~] Install: KB4486129 - Microsoft .NET Framework 4.8 for Windows Server 2016")
$Scriptlet = @(
'$Script = {';
'param({0})' -f $V;
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
'& $Script {0}' -f $V)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(400)

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
'. (Get-ItemProperty $Env:FEComputerInfo).Function';
'{0} = Initialize-VmNode -Reinitialize' -f $V;
'If ({0}.Smb.Connected)' -f $V;
'{';
'    {0}.Status("[+] Reinitialized VmNode")' -f $V;
'}')

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(30)

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
            # [Installs FightingEntropy module]
            $Script = $Vm.Script.Get("InstallFeModule")
            $Scriptlet = @(
            '$Script = {';
            'param({0})' -f $V;
            '$Start = [DateTime]::Now'
            $Script.Content.Line;
            '$Status = Switch ([UInt32]!!(Get-Module FightingEntropy))';
            '{';
            '    0 { "[!] FightingEntropy not installed" }';
            '    1 { "[+] FightingEntropy installed" }';
            '}';
            '$Elapsed = [TimeSpan]([DateTime]::Now-$Start)'
            '{0}.Status("$Status [$Elapsed]")' -f $V;
            '}';
            '& $Script {0}' -f $V)
            $Script.Clear()

            ForEach ($Line in $Scriptlet)
            {
                $Script.Add($Line)
            }

            $Vm.RunScript()
            $Vm.SmbIdle($Script.Timeout)
            
            If ($Vm.Console.Last().Status -match "\[\+\] FightingEntropy installed")
            {
                $Caption = "Set Screen Resolution"
                $Title   = "This section requires manual entry, proceed?"
                $Options = "&Yes","&No"
                $Default = 0
                
                $Vm.Update(0,"[~] $Caption")
                Switch ($Host.UI.PromptForChoice($Caption,$Title,$Options,$Default))
                {
                    0
                    {
                        # [Changes screen resolution to 720p]
                        $Vm.TypeLine("Set-ScreenResolution -Width 1280 -Height 720")
                        $Vm.TypeKey(13)
                        $Vm.Idle(5,5)
                    }
                    1
                    {
    
                    }
                }   
            }
        }
        InstallVsCode
        {
            $Script = $Vm.Script.Get("InstallVsCode")
            $Scriptlet = @( 
            '$Script = {';
            'param({0})' -f $V
            '$Start = [DateTime]::Now';
            $Script.Content.Line[0,1];
            '$Test = choco';
            '$Status = Switch ([UInt32]!!$Test)';
            '{';
            '    0 { "[!] Chocolatey not installed" }';
            '    0 { "[+] Chocolatey installed" }';
            '}';
            '$Elapsed = [TimeSpan]([DateTime]::Now-$Start)';
            '{0}.Status("$Status [$Elapsed]")' -f $V;
            '}';
            '& $Script {0}' -f $V)

            $Script.Clear()

            ForEach ($Line in $Scriptlet)
            {
                $Script.Add($Line)
            }

            $Vm.RunScript()
            $Vm.SmbIdle($Script.Timeout)
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
            '. (Get-ItemProperty $Env:FEComputerInfo).Function';
            '{0} = Initialize-VmNode -Reinitialize' -f $V;
            'If ({0}.Smb.Connected)' -f $V;
            '{';
            '    {0}.Status("[+] Reinitialized VmNode")' -f $V;
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

# Reinitialize VmNode
$Vm.Update(0,"[~] Reinitialize VmNode")
$Scriptlet = @(
'. (Get-ItemProperty $Env:FEComputerInfo).Function';
'{0} = Initialize-VmNode -Reinitialize' -f $V;
'If ({0}.Smb.Connected)' -f $V;
'{';
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
$Scriptlet = @(
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
'    Set-DhcpServerV4OptionValue -OptionId 6 -Value $Item -Verbose'
'}'
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

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(120)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Initialize-FEAdInstance [+] Active Directory Configuration                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

$Vm.Update(0,"[~] Initialize-FEAdInstance -> Active Directory Configuration")
$User = ($Vm.Account | ? Type -eq User)[0]

$Vm.TypeLine("`$Password = Read-Host `"<Enter Password>`" -AsSecureString")
$Vm.TypeKey(13)
$Vm.TypePassword($User)
$Vm.TypeKey(13)
$Vm.TypeLine('$Credential  = [PSCredential]::New("{0}",$Password)' -f $User.Username)
$Vm.TypeKey(13)

# // Set remote variable(s)
If ('$Ad' -notin $Vm.Variable.Output.Name)
{
    $Vm.Variable.Add("Remote",'$Ad',"Initialize-FeAdInstance")
}
$W = $Vm.Variable.Get(1).Name

$Scriptlet = @(
'$Script = {';
'param($Credential,{0})' -f $V
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
'$User.SetAccountPassword($Credential.Password)';
'{0}.AddAdGroupMember($Group,$User)' -f $W
'$User.SetPrimaryGroup($Group)';
'{0}.Status("[+] Initialize-FeAdInstance completed")' -f $V
'}'
'& $Script $Password {0}' -f $V)

ForEach ($Line in $Scriptlet)
{
    $Vm.TypeLine($Line)
    $Vm.TypeKey(13)
}

$Vm.SmbIdle(120)

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


