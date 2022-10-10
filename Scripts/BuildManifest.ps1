Class BuildManifestItem
{
    [UInt32] $Index
    [String] $Name
    [String] $Fullname
    [UInt32] $Include
    [UInt32] $Exist
    BuildManifestItem([UInt32]$Index,[Object]$File)
    {
        $This.Index    = $Index
        $This.Name     = $File.Name
        $This.Fullname = $File.Fullname
        $This.Exist    = [System.IO.File]::Exists($This.Fullname)
    }
}

Class BuildManifest
{
    [String] $Path
    [Object] $Output
    BuildManifest([String]$Path,[String[]]$Items)
    {
        $This.Path   = $Path
        $This.Output = @( )

        $List        = Get-ChildItem $Path
        $Swap        = @{ }
        ForEach ($X in 0..($List.Count-1))
        {
            $Item         = [BuildManifestItem]::New($Swap.Count,$List[$X])
            $Item.Include = $List[$X].Name -in $Items
            $Swap.Add($Swap.Count,$Item)
        }

        $This.Output = @($Swap[0..($Swap.Count-1)])
    }
}

Class ManifestItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    ManifestItem([UInt32]$Index,[String]$Name,[String]$Description)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.Description = $Description
    }
}

Class ManifestList
{
    [String]   $Author
    [String]  $Contact
    [String]     $Date
    [Version] $Version
    [Object]   $Output
    ManifestList([String]$Version)
    {
        $This.Author  = "Michael C. Cook Sr."
        $This.Contact = "@mcc85s"
        $This.Date    = [DateTime]::Now.ToString("yyyy-MM-dd")
        $This.Version = [Version]::New($Version)
        $This.Output  = @( )
    }
    Add([String]$Name,[String]$Description)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Name: [$Name] already specified"
        }

        $This.Output += [ManifestItem]::New($This.Output.Count,$Name,$Description)
    }
    [Object] Get([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        Return $This.Output[$Index]
    }
}

$List = [ManifestList]::New("2022.10.0")
$List.Add("Copy-FileStream.ps1","For copying larger files with a progress indicator.")
$List.Add("Get-AssemblyList.ps1","This function collects the currently loaded assemblies in the PowerShell host.")
$List.Add("Get-ControlExtension.ps1","Extends the graphical user interface controls handed off to the threading dispatcher.")
$List.Add("Get-DiskInfo.ps1","For retrieving information about installed hard drives.")
$List.Add("Get-EnvironmentKey.ps1","For retrieving and instantiating an environment key (branding, icons, certificates, etc.).")
$List.Add("Get-EventLogArchive.ps1","This basically compiles an archive of the event logs (like a PK3 file) so they can be (imported/exported).")
$List.Add("Get-EventLogConfigExtension.ps1","This function extends the functionality of the default EventLogConfig class, and (imports/exports).")
$List.Add("Get-EventLogController.ps1","Controller for the EventLog Utility (Xaml/Threading/GUI/Logging).")
$List.Add("Get-EventLogProject.ps1","A subcontroller for the EventLog Utility.")
$List.Add("Get-EventLogRecordExtension.ps1","This function extends the functionality of the default EventLogRecord class, and (imports/exports).")
$List.Add("Get-FEADLogin.ps1","For validating an ADDS login, and then accessing NTDS information.")
$List.Add("Get-FEDCPromo.ps1","For the promotion of a FightingEntropy (ADDS/Various) Domain Controller.")
$List.Add("Get-FEHost.ps1","For retrieving basic information about a system and the current user.")
$List.Add("Get-FEImageManifest.ps1","For retrieving a list of images to use on a forward FE Server.")
$List.Add("Get-FEInfo.ps1","For retrieving information about a Windows Operating system.")
$List.Add("Get-FEManifest.ps1","For retrieving classes, control objects, functions, and graphics from the FEModule path.")
$List.Add("Get-FEModule.ps1","Loads the FightingEntropy module.")
$List.Add("Get-FENetwork.ps1","For collecting network adapters, interfaces, as well as a network service controller.")
$List.Add("Get-FEOS.ps1","For detecting the currently running operating system, meant for cross compatibility.")
$List.Add("Get-FEProcess.ps1","Retrieves the currently running processes.")
$List.Add("Get-FERole.ps1","For extended information regarding the host operating system, and hosts specialized functions.")
$List.Add("Get-FEService.ps1","Collects the currently running services, and adds the service configuration template (Windows).")
$List.Add("Get-FESitemap.ps1","For populating a control object that removes all traces of specified Adds/Dhcp/Dns/Vm/VmSwitch instances.")
$List.Add("Get-MadBomb.ps1","For tweaking various Windows settings, featuring MadBomb122's customization script (not complete).")
$List.Add("Get-MDTModule.ps1","Retrieves the location of the main MDTToolkit.psd file, and installs (MDT/WinADK/WinPE) if they are not present.")
$List.Add("Get-PowerShell.ps1","Gets the current releases for PowerShell from the official PowerShell Github Repository.")
$List.Add("Get-PropertyItem.ps1","Essentially geared for a graphical user interface.")
$List.Add("Get-PropertyObject.ps1","This is specifically for a portion of the EventLogUtility GUI.")
$List.Add("Get-PSDLog.ps1","Retrieves the PowerShell Deployment modification by FriendsOfMDT and inserts FightingEntropy customizations.")
$List.Add("Get-PSDLogGUI.ps1","For parsing the PowerShell Deployment log items into GUI objects.")
$List.Add("Get-PSDModule.ps1","Retrieves the PowerShell Deployment modification by FriendsOfMDT and inserts FightingEntropy customizations.")
$List.Add("Get-SystemDetails.ps1","This function is the main function that collects system information and formats it all to export.")
$List.Add("Get-ViperBomb.ps1","For managing Windows services.")
$List.Add("Get-WhoisUtility.ps1","For obtaining information related to a particular IP address.")
$List.Add("Install-BossMode.ps1","Installs custom theme for Visual Studio Code.")
$List.Add("Install-IISServer.ps1","To install, stage, and configure an IIS Server for the Microsoft Deployment Toolkit/PSD modification.")
$List.Add("Invoke-cimdb.ps1","Launches the [FightingEntropy(p)] Company Inventory Management Database.")
$List.Add("Invoke-KeyEntry.ps1","For isolating keys in a virtual machine guest from a Hyper-V host.")
$List.Add("New-EnvironmentKey.ps1","Instantiates an environment key for FightingEntropy.")
$List.Add("New-FEInfrastructure.ps1","For managing the configuration AND distribution of ADDS nodes, virtual hive clusters, MDT/WDS shares, and sewing it all together.")
$List.Add("PSDController.psm1","Deploys the control module which orchestrates PowerShell Deployment.")
$List.Add("PSDDeploymentShare.psm1","Deployment share commands (Troubleshooting/Connection).")
$List.Add("PSDFinal.ps1","Finalizes a task sequence.")
$List.Add("PSDGather.psm1","Module for Wmi queries & processing rules into [tsenv:\] variables.")
$List.Add("PSDStart.ps1","To deploy operating systems w/ applications, drivers, profiles, and other cool stuff.")
$List.Add("PSDUtility.psm1","General utility calls for PSD (Logging/Pathing/Variables).")
$List.Add("PSDWizard.psm1","Initializes the (MDT Task Sequence Wizard [UI/User Interface]).")
$List.Add("Search-WirelessNetwork.ps1","For scanning wireless networks (eventually for use in a PXE environment).")
$List.Add("Set-ScreenResolution.ps1","Allows the resolution to be changed in a PXE environment, as well as in native Windows.")
$List.Add("Show-ToastNotification.ps1","Almost like Burnt Toast (which is probably cooler than this is).")
$List.Add("Update-PowerShell.ps1","Gets the current releases for PowerShell from the official PowerShell Github Repository.")
$List.Add("Write-Theme.ps1","The lifeblood of [FightingEntropy()]... With it? You can stylize the hell out a PowerShell command prompt console.")
