# About (2023/08/15)
# Get-ViperBomb takes a fair amount of time to load. Not to mention, the ControlTemplate classes each require the
# $Console variable to be present, which is effectively duplicating that object, whereby making the process take
# a lot longer to load. Merging the following class types and then relocating the SetMode method to the outside
# ViperBombController scope WILL allow this function to work a LOT faster.

Enum PrivacyType
{
    Telemetry
    WifiSense
    SmartScreen
    LocationTracking
    Feedback
    AdvertisingID
    Cortana
    CortanaSearch
    ErrorReporting
    AutologgerFile
    DiagTrack
    WAPPush
}

Enum WindowsUpdateType
{
    UpdateMSProducts
    CheckForWindowsUpdate
    WinUpdateType
    WinUpdateDownload
    UpdateMSRT
    UpdateDriver
    RestartOnUpdate
    AppAutoDownload
    UpdateAvailablePopup
}

Enum ServiceType
{
    UAC
    SharingMappedDrives
    AdminShares
    Firewall
    WinDefender
    HomeGroups
    RemoteAssistance
    RemoteDesktop
}

Enum ContextType
{
    CastToDevice
    PreviousVersions
    IncludeInLibrary
    PinToStart      
    PinToQuickAccess
    ShareWith       
    SendTo
}

Enum TaskbarType
{
    BatteryUIBar
    ClockUIBar
    VolumeControlBar
    TaskbarSearchBox
    TaskViewButton
    TaskbarIconSize
    TaskbarGrouping
    TrayIcons
    SecondsInClock
    LastActiveClick
    TaskbarOnMultiDisplay
    TaskbarButtonDisplay
}

Enum StartMenuType
{
    StartMenuWebSearch
    StartSuggestions
    MostUsedAppStartMenu
    RecentItemsFrequent
    UnpinItems
}

Enum ExplorerType
{
    AccessKeyPrompt
    F1HelpKey
    AutoPlay
    AutoRun
    PidInTitleBar
    RecentFileQuickAccess
    FrequentFoldersQuickAccess
    WinContentWhileDrag
    StoreOpenWith
    LongFilePath
    ExplorerOpenLoc
    WinXPowerShell
    AppHibernationFile
    Timeline
    AeroSnap
    AeroShake
    KnownExtensions
    HiddenFiles
    SystemFiles
    TaskManagerDetails
    ReopenAppsOnBoot
}

Enum ThisPCIconType
{
    Desktop
    Documents
    Downloads
    Music
    Pictures
    Videos
    ThreeDObjects
}

Enum DesktopIconType
{
    ThisPC
    Network
    RecycleBin
    Profile
    ControlPanel
}

Enum LockScreenType
{
    Toggle
    Password
    PowerMenu
    Camera
}

Enum MiscellaneousType
{
    ScreenSaver
    AccountProtectionWarn
    ActionCenter
    StickyKeyPrompt
    NumlockOnStart
    F8BootMenu
    RemoteUACAcctToken
    HibernatePower
    SleepPower
}

Enum PhotoViewerType
{
    FileAssociation
    OpenWithMenu
}

Enum WindowsAppsType
{
    OneDrive
    OneDriveInstall
    XboxDVR
    MediaPlayer
    WorkFolders
    FaxAndScan
    LinuxSubsystem
}

Enum ListItemType
{
    PrivacyType
    WindowsUpdateType
    ServiceType
    ContextType
    TaskbarType
    StartMenuType
    ExplorerType
    ThisPCIconType
    DesktopIconType
    LockScreenType
    MiscellaneousType
    PhotoViewerType
    WindowsAppsType
}

Class RegistryItem
{
    [String]  $Path
    [String]  $Name
    [Object] $Value
    RegistryItem([String]$Path)
    {
        $This.Path  = $Path
    }
    RegistryItem([String]$Path,[String]$Name)
    {
        $This.Path  = $Path
        $This.Name  = $Name
    }
    [Object] Get()
    {
        $This.Test()
        If ($This.Name)
        {
            Return Get-ItemProperty -LiteralPath $This.Path -Name $This.Name
        }
        Else
        {
            Return Get-ItemProperty -LiteralPath $This.Path
        }
    }
    [Void] Test()
    {
        $Split = $This.Path.Split("\")
        $Path_ = $Split[0]
        ForEach ($Item in $Split[1..($Split.Count-1)])
        {
            $Path_ = $Path_, $Item -join '\'
            If (!(Test-Path $Path_))
            {
                New-Item -Path $Path_ -Verbose
            }
        }
    }
    [Void] Clear()
    {
        $This.Name  = $Null
        $This.Type  = $Null
        $This.Value = $Null
    }
    [Void] Set([Object]$Value)
    {
        $This.Test()
        Set-ItemProperty -LiteralPath $This.Path -Name $This.Name -Type "DWord" -Value $Value -Verbose
    }
    [Void] Set([String]$Type,[Object]$Value)
    {
        $This.Test()
        Set-ItemProperty -LiteralPath $This.Path -Name $This.Name -Type $Type -Value $Value -Verbose
    }
    [Void] Remove()
    {
        $This.Test()
        If ($This.Name)
        {
            Remove-ItemProperty -LiteralPath $This.Path -Name $This.Name -Verbose
        }
        Else
        {
            Remove-Item -LiteralPath $This.Path -Verbose
        }
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class ControlItem
{
    Hidden [Guid]     $Guid
    [String]        $Source
    [String]          $Name
    [String]   $DisplayName
    [UInt32]         $Value
    [String]   $Description
    [String[]]     $Options
    [Object]        $Output
    Hidden [String] $Status
    ControlItem([String]$Source,[String]$Name,[String]$DisplayName,[UInt32]$Value,[String]$Description,[String[]]$Options)
    {
        $This.Guid        = $This.NewGuid()
        $This.Source      = $Source
        $This.Name        = $Name
        $This.DisplayName = $DisplayName
        $This.Value       = $Value
        $This.Description = $Description
        $This.Options     = $Options
    }
    Clear()
    {
        $This.Output      = @( ) 
    }
    [Object] NewGuid()
    {
        Return [Guid]::NewGuid()
    }
    [Object] RegistryItem([String]$Path)
    {
        Return [RegistryItem]::New($Path)
    }
    [Object] RegistryItem([String]$Path,[String]$Name)
    {
        Return [RegistryItem]::New($Path,$Name)
    }
    Registry([String]$Path,[String]$Name)
    {
        $This.Output += $This.RegistryItem($Path,$Name)
    }
    SetStatus()
    {
        $This.Status = "[Control]: {0}: {1}" -f $This.Source, $This.Name
    }
    [String] ToString()
    {
        Return $This.Status
    }
}

Class SystemController
{
    [Object]    $Task
    [Object]    $AppX
    [Object] $Feature
    [Object] $Service
    [Object]  $Output
    SystemController()
    {
        $This.Refresh("Task")
        $This.Refresh("AppX")
        $This.Refresh("Feature")
        $This.Refresh("Service")
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] ControlItem([String]$Source,[String]$Name,[String]$DisplayName,[UInt32]$Value,[String]$Description,[String[]]$Options)
    {
        Return [ControlItem]::New($Source,$Name,$DisplayName,$Value,$Description,$Options)
    }
    Refresh([String]$Property)
    {
        Switch ($Property)
        {
            Task    { $This.Task    = Get-ScheduledTask                  }
            AppX    { $This.Appx    = Get-AppXPackage                    }
            Feature { $This.Feature = Get-WindowsOptionalFeature -Online }
            Service { $This.Service = Get-Service                        }
        }
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($xSource in [System.Enum]::GetNames([ListItemType]))
        {
            $Source = $xSource.Replace("Type","")
            ForEach ($Name in [System.Enum]::GetNames($xSource))
            {
                $X = Switch ($Source)
                {
                    Privacy
                    {
                        Switch ($Name)
                        {
                            Telemetry
                            {
                                "Telemetry",
                                "Telemetry",
                                1,
                                "Various location and tracking features",
                                @("Skip", "Enable*", "Disable")
                            }
                            WifiSense
                            {
                                "WifiSense",
                                "Wi-Fi Sense",
                                1,
                                "Lets devices more easily connect to a WiFi network",
                                @("Skip", "Enable*", "Disable")
                            }
                            SmartScreen
                            {
                                "SmartScreen",
                                "SmartScreen",
                                1,
                                "Cloud-based anti-phishing and anti-malware component",
                                @("Skip","Enable*","Disable")
                            }
                            LocationTracking
                            {
                                "LocationTracking",
                                "Location Tracking",
                                1,
                                "Monitors the current location of the system and manages geofences",
                                @("Skip", "Enable*", "Disable")
                            }
                            Feedback
                            {
                                "Feedback",
                                "Feedback",
                                1,
                                "System Initiated User Feedback",
                                @("Skip", "Enable*", "Disable")
                            }
                            AdvertisingID
                            {
                                "AdvertisingID",
                                "Advertising ID",
                                1,
                                "Allows Microsoft to display targeted ads",
                                @("Skip", "Enable*", "Disable")
                            }
                            Cortana
                            {
                                "Cortana",
                                "Cortana",
                                1,
                                "(Master Chief/Microsoft)'s personal voice assistant",
                                @("Skip", "Enable*", "Disable")
                            }
                            CortanaSearch
                            {
                                "CortanaSearch",
                                "Cortana Search",
                                1,
                                "Allows Cortana to create search indexing for faster system search results",
                                @("Skip", "Enable*", "Disable")
                            }
                            ErrorReporting
                            {
                                "ErrorReporting",
                                "Error Reporting",
                                1,
                                "If Windows has an issue, it sends Microsoft a detailed report",
                                @("Skip", "Enable*", "Disable")
                            }
                            AutologgerFile
                            {
                                "AutoLoggerFile",
                                "Automatic Logger File",
                                1,
                                "Lets you track trace provider actions while Windows is booting",
                                @("Skip", "Enable*", "Disable")
                            }
                            DiagTrack
                            {
                                "DiagTracking",
                                "Diagnostics Tracking",
                                1,
                                "Connected User Experiences and Telemetry",
                                @("Skip", "Enable*", "Disable")
                            }
                            WAPPush
                            {
                                "WAPPush",
                                "WAP Push",
                                1,
                                "Device Management Wireless Application Protocol",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    WindowsUpdate
                    {
                        Switch ($Name)
                        {
                            UpdateMSProducts
                            {
                                "UpdateMSProducts",
                                "Update MS Products",
                                2,
                                "Searches Windows Update for Microsoft Products",
                                @("Skip", "Enable", "Disable*")
                            }
                            CheckForWindowsUpdate
                            {
                                "CheckForWindowsUpdate",
                                "Check for Windows Updates",
                                1,
                                "Allows Windows Update to work automatically",
                                @("Skip", "Enable*", "Disable")
                            }
                            WinUpdateType
                            {
                                "WinUpdateType",
                                "Windows Update Type",
                                3,
                                "Allows Windows Update to work automatically",
                                @("Skip", "Notify", "Auto DL", "Auto DL+Install*", "Manual")
                            }
                            WinUpdateDownload
                            {
                                "WinUpdateDownload",
                                "Windows Update Download",
                                1,
                                "Selects a source from which to pull Windows Updates",
                                @("Skip", "P2P*", "Local Only", "Disable")
                            }
                            UpdateMSRT
                            {
                                "UpdateMSRT",
                                "Update MSRT",
                                1,
                                "Allows updates for the Malware Software Removal Tool",
                                @("Skip", "Enable*", "Disable")
                            }
                            UpdateDriver
                            {
                                "UpdateDriver",
                                "Update Driver",
                                1,
                                "Allows drivers to be downloaded from Windows Update",
                                @("Skip", "Enable*", "Disable")
                            }
                            RestartOnUpdate
                            {
                                "RestartOnUpdate",
                                "Restart on Update",
                                1,
                                "Reboots the machine when an update is installed and requires it",
                                @("Skip", "Enable*", "Disable")
                            }
                            AppAutoDownload
                            {
                                "AppAutoDownload",
                                "Consumer App Auto Download",
                                1,
                                "Provisioned Windows Store applications are downloaded",
                                @("Skip", "Enable*", "Disable")
                            }
                            UpdateAvailablePopup
                            {
                                "UpdateAvailablePopup",
                                "Update Available Pop-up",
                                1,
                                "If an update is available, a (pop-up/notification) will appear",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    Service
                    {
                        Switch ($Name)
                        {
                            UAC
                            {
                                "UAC",
                                "User Access Control",
                                2,
                                "Sets restrictions/permissions for programs",
                                @("Skip", "Lower", "Normal*", "Higher")
                            }
                            SharingMappedDrives
                            {
                                "SharingMappedDrives",
                                "Share Mapped Drives",
                                2,
                                "Shares any mapped drives to all users on the machine",
                                @("Skip", "Enable", "Disable*")
                            }
                            AdminShares
                            {
                                "AdminShares",
                                "Administrative File Shares",
                                1,
                                "Reveals default system administration file shares",
                                @("Skip", "Enable*", "Disable")
                            }
                            Firewall
                            {
                                "Firewall",
                                "Firewall",
                                1,
                                "Enables the default firewall profile",
                                @("Skip", "Enable*", "Disable")
                            }
                            WinDefender
                            {
                                "WinDefender",
                                "Windows Defender",
                                1,
                                "Toggles Windows Defender, system default anti-virus/malware utility",
                                @("Skip", "Enable*", "Disable")
                            }
                            HomeGroups
                            {
                                "HomeGroups",
                                "Home Groups",
                                1,
                                "Toggles the use of home groups, essentially a home-based workgroup",
                                @("Skip", "Enable*", "Disable")
                            }
                            RemoteAssistance
                            {
                                "RemoteAssistance",
                                "Remote Assistance",
                                1,
                                "Toggles the ability to use Remote Assistance",
                                @("Skip", "Enable*", "Disable")
                            }
                            RemoteDesktop
                            {
                                "RemoteDesktop",
                                "Remote Desktop",
                                2,
                                "Toggles the ability to use Remote Desktop",
                                @("Skip", "Enable", "Disable*")
                            }
                        }
                    }
                    Context
                    {
                        Switch ($Name)
                        {
                            CastToDevice
                            {
                                "CastToDevice",
                                "Cast To Device",
                                1,
                                "Adds a context menu item for casting to a device",
                                @("Skip", "Enable*", "Disable")
                            }
                            PreviousVersions
                            {
                                "PreviousVersions",
                                "Previous Versions",
                                1,
                                "Adds a context menu item to select a previous version of a file",
                                @("Skip", "Enable*", "Disable")
                            }
                            IncludeInLibrary
                            {
                                "IncludeInLibrary",
                                "Include in Library",
                                1,
                                "Adds a context menu item to include a selection in library items",
                                @("Skip", "Enable*", "Disable")
                            }
                            PinToStart      
                            {
                                "PinToStart",
                                "Pin to Start",
                                1,
                                "Adds a context menu item to pin an item to the start menu",
                                @("Skip", "Enable*", "Disable")
                            }
                            PinToQuickAccess
                            {
                                "PinToQuickAccess",
                                "Pin to Quick Access",
                                1,
                                "Adds a context menu item to pin an item to the Quick Access bar",
                                @("Skip", "Enable*", "Disable")
                            }
                            ShareWith       
                            {
                                "PinToQuickAccess",
                                "Pin to Quick Access",
                                1,
                                "Adds a context menu item to share a file with...",
                                @("Skip", "Enable*", "Disable")
                            }
                            SendTo
                            {
                                "SendTo",
                                "Send To",
                                1,
                                "Adds a context menu item to send an item to...",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    Taskbar
                    {
                        Switch ($name)
                        {
                            BatteryUIBar
                            {
                                "BatteryUIBar",
                                "Battery UI Bar",
                                1,
                                "Toggles the battery UI bar element style",
                                @("Skip", "New*", "Classic")
                            }
                            ClockUIBar
                            {
                                "ClockUIBar",
                                "Clock UI Bar",
                                1,
                                "Toggles the clock UI bar element style",
                                @("Skip", "New*", "Classic")
                            }
                            VolumeControlBar
                            {
                                "VolumeControlBar",
                                "Volume Control Bar",
                                1,
                                "Toggles the volume control bar element style",
                                @("Skip", "New (X-Axis)*", "Classic (Y-Axis)")
                            }
                            TaskbarSearchBox
                            {
                                "TaskBarSearchBox",
                                "Taskbar Search Box",
                                1,
                                "Toggles the taskbar search box element",
                                @("Skip", "Show*", "Hide")
                            }
                            TaskViewButton
                            {
                                "VolumeControlBar",
                                "Volume Control Bar",
                                1,
                                "Toggles the volume control bar element style",
                                @("Skip", "New (X-Axis)*", "Classic (Y-Axis)")
                            }
                            TaskbarIconSize
                            {
                                "TaskbarIconSize",
                                "Taskbar Icon Size",
                                1,
                                "Toggles the taskbar icon size",
                                @("Skip", "Normal*", "Small")
                            }
                            TaskbarGrouping
                            {
                                "TaskbarGrouping",
                                "Taskbar Grouping",
                                2,
                                "Toggles the grouping of icons in the taskbar",
                                @("Skip", "Never", "Always*","When needed")
                            }
                            TrayIcons
                            {
                                "TrayIcons",
                                "Tray Icons",
                                1,
                                "Toggles whether the tray icons are shown or hidden",
                                @("Skip", "Auto*", "Always show")
                            }
                            SecondsInClock
                            {
                                "SecondsInClock",
                                "Seconds in clock",
                                1,
                                "Toggles the clock/time shows the seconds",
                                @("Skip", "Show", "Hide*")
                            }
                            LastActiveClick
                            {
                                "LastActiveClick",
                                "Last Active Click",
                                2,
                                "Makes taskbar buttons open the last active window",
                                @("Skip", "Enable", "Disable*")
                            }
                            TaskbarOnMultiDisplay
                            {
                                "TaskbarOnMultiDisplay",
                                "Taskbar on multiple displays",
                                1,
                                "Displays the taskbar on each display if there are multiple screens",
                                @("Skip", "Enable*", "Disable")
                            }
                            TaskbarButtonDisplay
                            {
                                "TaskbarButtonDisplay",
                                "Multi-display taskbar",
                                2,
                                "Defines where the taskbar button should be if there are multiple screens",
                                @("Skip", "All", "Current Window*","Main + Current Window")
                            }
                        }
                    }
                    StartMenu
                    {
                        Switch ($Name)
                        {
                            StartMenuWebSearch
                            {
                                "StartMenuWebSearch",
                                "Start Menu Web Search",
                                1,
                                "Allows the start menu search box to search the internet",
                                @("Skip", "Enable*", "Disable")
                            }
                            StartSuggestions
                            {
                                "StartSuggestions",
                                "Start Menu Suggestions",
                                1,
                                "Toggles the suggested apps in the start menu",
                                @("Skip", "Enable*", "Disable")
                            }
                            MostUsedAppStartMenu
                            {
                                "MostUsedAppStartMenu",
                                "Most Used Applications",
                                1,
                                "Toggles the most used applications in the start menu",
                                @("Skip", "Show*", "Hide")
                            }
                            RecentItemsFrequent
                            {
                                "RecentItemsFrequent",
                                "Recent Items Frequent",
                                1,
                                "Toggles the most recent frequently used (apps/items) in the start menu",
                                @("Skip", "Enable*", "Disable")
                            }
                            UnpinItems
                            {
                                "UnpinItems",
                                "Unpin Items",
                                0,
                                "Toggles the unpin (apps/items) from the start menu",
                                @("Skip", "Enable")
                            }
                        }
                    }
                    Explorer
                    {
                        Switch ($Name)
                        {
                            AccessKeyPrompt
                            {
                                "AccessKeyPrompt",
                                "Access Key Prompt",
                                1,
                                "Toggles the accessibility keys (menus/prompts)",
                                @("Skip", "Enable*", "Disable")
                            }
                            F1HelpKey
                            {
                                "F1HelpKey",
                                "F1 Help Key",
                                1,
                                "Toggles the F1 help menu/prompt",
                                @("Skip", "Enable*", "Disable")
                            }
                            AutoPlay
                            {
                                "AutoPlay",
                                "AutoPlay",
                                1,
                                "Toggles autoplay for inserted discs or drives",
                                @("Skip", "Enable*", "Disable")
                            }
                            AutoRun
                            {
                                "AutoRun",
                                "AutoRun",
                                1,
                                "Toggles autorun for programs on an inserted discs or drives",
                                @("Skip", "Enable*", "Disable")
                            }
                            PidInTitleBar
                            {
                                "PidInTitleBar",
                                "Process ID",
                                2,
                                "Toggles the process ID in a window title bar",
                                @("Skip", "Show", "Hide*")
                            }
                            RecentFileQuickAccess
                            {
                                "RecentFileQuickAccess",
                                "Recent File Quick Access",
                                1,
                                "Shows recent files in the Quick Access menu",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            FrequentFoldersQuickAccess
                            {
                                "FrequentFoldersQuickAccess",
                                "Frequent Folders Quick Access",
                                1,
                                "Show frequently used folders in the Quick Access menu",
                                @("Skip", "Show*", "Hide")
                            }
                            WinContentWhileDrag
                            {
                                "WinContentWhileDrag",
                                "Window Content while dragging",
                                1,
                                "Show the content of a window while it is being dragged/moved",
                                @("Skip", "Show*", "Hide")
                            }
                            StoreOpenWith
                            {
                                "StoreOpenWith",
                                "Store Open With...",
                                1,
                                "Toggles the ability to use the Microsoft Store to open an unknown file/program",
                                @("Skip", "Enable*", "Disable")
                            }
                            LongFilePath
                            {
                                "LongFilePath",
                                "Long File Path",
                                1,
                                "Toggles whether file paths are longer, or not",
                                @("Skip", "Enable", "Disable*")
                            }
                            ExplorerOpenLoc
                            {
                                "ExplorerOpenLoc",
                                "Explorer Open Location",
                                1,
                                "Default path/location opened with a new explorer window",
                                @("Skip", "Quick Access*", "This PC")
                            }
                            WinXPowerShell
                            {
                                "WinXPowerShell",
                                "Win X PowerShell",
                                1,
                                "Toggles whether (Win + X) opens PowerShell or a Command Prompt",
                                @("Skip", "PowerShell*", "Command Prompt")
                            }
                            AppHibernationFile
                            {
                                "AppHibernationFile",
                                "App Hibernation File",
                                1,
                                "Toggles the system swap file use",
                                @("Skip", "Enable*", "Disable")
                            }
                            Timeline
                            {
                                "Timeline",
                                "Timeline",
                                1,
                                "Toggles Windows Timeline, for recovery of items at a prior point in time",
                                @("Skip", "Enable*", "Disable")
                            }
                            AeroSnap
                            {
                                "AeroSnap",
                                "AeroSnap",
                                1,
                                "Toggles the ability to snap windows to the sides of the screen",
                                @("Skip", "Enable*", "Disable")
                            }
                            AeroShake
                            {
                                "AeroShake",
                                "AeroShake",
                                1,
                                "Toggles ability to minimize ALL windows by jiggling the active window title bar",
                                @("Skip", "Enable*", "Disable")
                            }
                            KnownExtensions
                            {
                                "KnownExtensions",
                                "Known File Extensions",
                                2,
                                "Shows known (mime-types/file extensions)",
                                @("Skip", "Show", "Hide*")
                            }
                            HiddenFiles
                            {
                                "HiddenFiles",
                                "Show Hidden Files",
                                2,
                                "Shows all hidden files",
                                @("Skip", "Show", "Hide*")
                            }
                            SystemFiles
                            {
                                "SystemFiles",
                                "Show System Files",
                                2,
                                "Shows all system files",
                                @("Skip", "Show", "Hide*")
                            }
                            TaskManagerDetails
                            {
                                "TaskManagerDetails",
                                "Task Manager Details",
                                2,
                                "Toggles whether the task manager details are shown",
                                @("Skip", "Show", "Hide*")
                            }
                            ReopenAppsOnBoot
                            {
                                "ReopenAppsOnBoot",
                                "Reopen apps at boot",
                                1,
                                "Toggles applications to reopen at boot time",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    ThisPCIcon
                    {
                        Switch ($Name)
                        {
                            Desktop
                            {
                                "Desktop",
                                "Desktop [Explorer]",
                                1,
                                "Toggles the Desktop icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            Documents
                            {
                                "Documents",
                                "Documents [Explorer]",
                                1,
                                "Toggles the Documents icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            Downloads
                            {
                                "Downloads",
                                "Downloads [Explorer]",
                                1,
                                "Toggles the Downloads icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            Music
                            {
                                "Music",
                                "Music [Explorer]",
                                1,
                                "Toggles the Music icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            Pictures
                            {
                                "Pictures",
                                "Pictures [Explorer]",
                                1,
                                "Toggles the Pictures icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            Videos
                            {
                                "Videos",
                                "Videos [Explorer]",
                                1,
                                "Toggles the Videos icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                            ThreeDObjects
                            {
                                "ThreeDObjects",
                                "3D Objects [Explorer]",
                                1,
                                "Toggles the 3D Objects icon in 'This PC'",
                                @("Skip", "Show/Add*", "Hide", "Remove")
                            }
                        }
                    }
                    DesktopIcon
                    {
                        Switch ($Name)
                        {
                            ThisPC
                            {
                                "ThisPC",
                                "This PC [Desktop]",
                                2,
                                "Toggles the 'This PC' icon on the desktop",
                                @("Skip", "Show", "Hide*")
                            }
                            Network
                            {
                                "Network",
                                "Network [Desktop]",
                                2,
                                "Toggles the 'Network' icon on the desktop",
                                @("Skip", "Show", "Hide*")
                            }
                            RecycleBin
                            {
                                "RecycleBin",
                                "Recycle Bin [Desktop]",
                                2,
                                "Toggles the 'Recycle Bin' icon on the desktop",
                                @("Skip", "Show", "Hide*")
                            }
                            Profile
                            {
                                "Profile",
                                "My Documents [Desktop]",
                                2,
                                "Toggles the 'Users File' icon on the desktop",
                                @("Skip", "Show", "Hide*")
                            }
                            ControlPanel
                            {
                                "ControlPane",
                                "Control Panel [Desktop]",
                                2,
                                "Toggles the 'Control Panel' icon on the desktop",
                                @("Skip", "Show", "Hide*")
                            }
                        }
                    }
                    LockScreen
                    {
                        Switch ($Name)
                        {
                            Toggle
                            {
                                "Toggle",
                                "Toggle [Lock Screen]",
                                1,
                                "Toggles the lock screen",
                                @("Skip", "Enable*", "Disable")
                            }
                            Password
                            {
                                "Password",
                                "Password [Lock Screen]",
                                1,
                                "Toggles the lock screen password",
                                @("Skip", "Enable*", "Disable")
                            }
                            PowerMenu
                            {
                                "PowerMenu",
                                "Power Menu [Lock Screen]",
                                1,
                                "Toggles the power menu on the lock screen",
                                @("Skip", "Show*", "Hide")
                            }
                            Camera
                            {
                                "Camera",
                                "Camera [Lock Screen]",
                                1,
                                "Toggles the camera on the lock screen",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    Miscellaneous
                    {
                        Switch ($Name)
                        {
                            ScreenSaver
                            {
                                "ScreenSaver",
                                "Screen Saver",
                                1,
                                "Toggles the screen saver",
                                @("Skip", "Enable*", "Disable")
                            }
                            AccountProtectionWarn
                            {
                                "AccountProtectionWarn",
                                "Account Protection Warning",
                                1,
                                "Toggles system security account protection warning",
                                @("Skip", "Enable*", "Disable")
                            }
                            ActionCenter
                            {
                                "ActionCenter",
                                "Action Center",
                                1,
                                "Toggles system action center",
                                @("Skip", "Enable*", "Disable")
                            }
                            StickyKeyPrompt
                            {
                                "StickyKeyPrompt",
                                "Sticky Key Prompt",
                                1,
                                "Toggles the sticky keys prompt/dialog",
                                @("Skip", "Enable*", "Disable")
                            }
                            NumlockOnStart
                            {
                                "NumlockOnStart",
                                "Number lock on start",
                                2,
                                "Toggles whether the number lock key is engaged upon start",
                                @("Skip", "Enable", "Disable*")
                            }
                            F8BootMenu
                            {
                                "F8BootMenu",
                                "F8 Boot Menu",
                                2,
                                "Toggles whether the F8 boot menu can be access upon boot",
                                @("Skip", "Enable", "Disable*")
                            }
                            RemoteUACAcctToken
                            {
                                "RemoteUACAcctToken",
                                "Remote UAC Account Token",
                                2,
                                "Toggles the local account token filter policy to mitigate remote connections",
                                @("Skip", "Enable", "Disable*")
                            }
                            HibernatePower
                            {
                                "HibernatePower",
                                "Hibernate Power",
                                0,
                                "Toggles the hibernation power option",
                                @("Skip", "Enable", "Disable")
                            }
                            SleepPower
                            {
                                "SleepPower",
                                "Sleep Power",
                                1,
                                "Toggles the sleep power option",
                                @("Skip", "Enable*", "Disable")
                            }
                        }
                    }
                    PhotoViewer
                    {
                        Switch ($Name)
                        {
                            FileAssociation
                            {
                                "FileAssociation",
                                "Set file association [Photo Viewer]",
                                2,
                                "Associates common image types with Photo Viewer",
                                @("Skip", "Enable", "Disable*")
                            }
                            OpenWithMenu
                            {
                                "OpenWithMenu",
                                "Set 'Open with' in context menu [Photo Viewer]",
                                2,
                                "Allows image files to be opened with Photo Viewer",
                                @("Skip", "Enable", "Disable*")
                            }
                        }
                    }
                    WindowsApps
                    {
                        Switch ($Name)
                        {
                            OneDrive
                            {
                                "OneDrive",
                                "OneDrive",
                                1,
                                "Toggles Microsoft OneDrive, which comes with the operating system",
                                @("Skip", "Enable*", "Disable")
                            }
                            OneDriveInstall
                            {
                                "OneDriveInstall",
                                "OneDriveInstall",
                                1,
                                "Installs/Uninstalls Microsoft OneDrive, which comes with the operating system",
                                @("Skip", "Installed*", "Uninstall")
                            }
                            XboxDVR
                            {
                                "XboxDVR",
                                "Xbox DVR",
                                1,
                                "Toggles Microsoft Xbox DVR",
                                @("Skip", "Enable*", "Disable")
                            }
                            MediaPlayer
                            {
                                "MediaPlayer",
                                "Windows Media Player",
                                1,
                                "Toggles Microsoft Windows Media Player, which comes with the operating system",
                                @("Skip", "Installed*", "Uninstall")
                            }
                            WorkFolders
                            {
                                "WorkFolders",
                                "Work Folders",
                                1,
                                "Toggles the WorkFolders-Client, which comes with the operating system",
                                @("Skip", "Installed*", "Uninstall")
                            }
                            FaxAndScan
                            {
                                "FaxAndScan",
                                "Fax and Scan",
                                1,
                                "Toggles the FaxServicesClientPackage, which comes with the operating system",
                                @("Skip", "Installed*", "Uninstall")
                            }
                            LinuxSubsystem
                            {
                                "LinuxSubsystem",
                                "Linux Subsystem (WSL)",
                                2,
                                "For Windows 1607+, this toggles the Microsoft-Windows-Subsystem-Linux",
                                @("Skip", "Installed", "Uninstall*")
                            }
                        }
                    }
                }

                $This.Output += $This.ControlItem($Source,$X[0],$X[1],$X[2],$X[3],$X[4])
            }
        }
    }
    [Object] GetTask([String]$TaskName)
    {
        Return $This.Task | ? TaskName -eq $TaskName
    }
    EnableTask([String]$TaskName)
    {
        $xTask = $This.GetTask($TaskName)
        If ($xTask -and $xTask.State -ne 'Ready')
        {
            Enable-ScheduledTask -TaskName $TaskName -Verbose
        }
    }
    DisableTask([String]$TaskName)
    {
        $xTask = $This.GetTask($TaskName)
        If ($xTask -and $xTask.State -ne 'Disabled')
        {
            Disable-ScheduledTask -TaskName $TaskName -Verbose
        }
    }
    [Object] GetAppX([String]$PackageName)
    {
        Return $This.AppX | ? PackageName -eq $PackageName
    }
    [Object] GetFeature([String]$FeatureName)
    {
        Return $This.Feature | ? FeatureName -eq $FeatureName
    }
    EnableFeature([String]$FeatureName)
    {
        $xFeature = $This.GetFeature($FeatureName)
        If ($xFeature)
        {
            Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -Verbose
        }
    }
    DisableFeature([String]$FeatureName)
    {
        $xFeature = $This.GetFeature($FeatureName)
        If ($xFeature)
        {
            Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -Verbose
        }
    }
    [Object] GetService([String]$ServiceName)
    {
        Return $This.Service | ? Name -eq $ServiceName
    }
    StartService([String]$ServiceName)
    {
        $xService = $This.GetService($ServiceName)
        If ($xService -and $xService.Status -ne "Running")
        {
            Start-Service -Name $ServiceName -Verbose
        }
    }
    StopService([String]$ServiceName)
    {
        $xService = $This.GetService($ServiceName)
        If ($xService -and $xService.Status -ne "Stopped")
        {
            Stop-Service -Name $ServiceName -Verbose
        }
    }
    SetService([String]$ServiceName,[String]$StartupType)
    {
        $xService = $This.GetService($ServiceName)
        If ($xService -and $xService.StartupType -ne $StartupType)
        {
            Set-Service -Name $ServiceName -StartupType $StartupType -Verbose
        }
    }
    SetAcl([String]$Params)
    {
        $FilePath     = "icacls"
        $ArgumentList = "{0} {1}" -f $This.AutoLoggerPath(), $Params
        $This.StartProcess($FilePath,$ArgumentList)
    }
    SetBcdEdit([String]$Params)
    {
        $FilePath     = "bcdedit"
        $This.StartProcess($FilePath,$Params)
    }
    SetPowerCfg([String]$Params)
    {
        $FilePath     = "powercfg"
        $This.StartProcess($FilePath,$Params)
    }
    StartProcess([String]$FilePath,[String]$ArgumentList)
    {
        Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process
    }
    [UInt32] x64Bit()
    {
        Return [Environment]::Is64BitProcess
    }
    [UInt32] GetWinVersion()
    {
        Return Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | % ReleaseID
    }
    [String] AutoLoggerRegistry()
    {
        Return "HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener"
    }
    [String] AutoLoggerPath()
    {
        Return "{0}\Microsoft\Diagnosis\ETLLogs\AutoLogger" -f [Environment]::GetEnvironmentVariable("ProgramData")
    }
    [Object] ComMusm()
    {
        Return New-Object -ComObject Microsoft.Update.ServiceManager
    }
    [String] AppAutoCloudCache()
    {
        Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
    }
    [String] AppAutoPlaceholder() 
    {
        Return "*windows.data.placeholdertilecollection\Current"
    }
    [String[]] MUSNotify()
    {
        Return @("","ux" | % { "$Env:windir\System32\musnotification$_.exe" })
    }
    [String] QuickAccessParseName()
    {
        Return 'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}"', 
               'System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}"', 
               'System.IsFolder:=System.StructuredQueryType.Boolean#True' -join " AND "
    }
    [String] StartSuggestionsCloudCache()
    {
        Return "HKCU:","SOFTWARE","Microsoft","Windows","CurrentVersion","CloudStore","Store",
        "Cache","DefaultAccount","*windows.data.placeholdertilecollection","Current" -join '\'
    }
    [String] LockscreenArgument()
    {
        $Item = "HKLM","SOFTWARE","Microsoft","Windows","CurrentVersion","Authentication",
                "LogonUI","SessionData" -join "\"

        Return "add $Item /t REG_DWORD /v AllowLockScreen /d 0 /f"
    }
    Inject([Object]$Index)
    {
        $Item = $This.Output[$Index]
        
        Switch ($Item.Source)
        {
            Privacy
            {
                Switch ($Item.Name)
                {
                    Telemetry
                    {
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
                        'AllowTelemetry'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
                        'AllowTelemetry'),
                        ('HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
                        'AllowTelemetry'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds',
                        'AllowBuildPreview'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform',
                        'NoGenTicket'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows',
                        'CEIPEnable'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
                        'AITEnable'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
                        'DisableInventory'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP',
                        'CEIPEnable'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC',
                        'PreventHandwritingDataSharing'),
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput',
                        'AllowLinguisticDataCollection') | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    WifiSense
                    {
                        ('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting','Value'),
                        ('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowConnectToWiFiSenseHotspots','Value'),
                        ('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','AutoConnectAllowedOEM'),
                        ('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','WiFiSenseAllowed') | % {
                             
                            $This.Registry($_[0],$_[1])
                        }
                    }
                    SmartScreen
                    {
                        $String   = @($Null;"\"+$This.GetAppX("Microsoft.MicrosoftEdge").PackageFamilyName)[$This.GetWinVersion() -ge 1703]
                        $Phishing = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage{0}\MicrosoftEdge\PhishingFilter" -f $String
            
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
                        "SmartScreenEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost",
                        "EnableWebContentEvaluation"),
                        ($Phishing,
                        "EnabledV9"),
                        ($Phishing,
                        "PreventOverride") | % {
                        
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    LocationTracking
                    {
                        ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}','SensorPermissionState'),
                        ('HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration','Status') | % {
                        
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Feedback
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Siuf\Rules','NumberOfSIUFInPeriod'),
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','DoNotShowFeedbackNotifications') | % {
                    
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    AdvertisingID
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
                        'Enabled'),
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy',
                        'TailoredExperiencesWithDiagnosticDataEnabled') | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Cortana
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy"),
                        ("HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts"),
                        ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection"),
                        ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortanaAboveLock"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchPrivacy"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch"),
                        ("HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Preferences","VoiceActivationEnableAboveLockscreen"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization","AllowInputPersonalization"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    CortanaSearch
                    {
                        $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana")
                    }
                    ErrorReporting
                    {
                        $This.Registry("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting","Disabled")
                    }
                    AutologgerFile
                    {
                        ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener",
                        "Start"),
                        ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}",
                        "Start") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    DiagTrack
                    {
                        # (Null/No Registry)
                    }
                    WAPPush
                    {
                        $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart")
                    }
                }
            }
            WindowsUpdate
            {
                Switch ($Item.Name)
                {
                    UpdateMSProducts
                    {
                        # (Null/No Registry)
                    }
                    CheckForWindowsUpdate
                    {
                        $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","SetDisableUXWUAccess")
                    }
                    WinUpdateType
                    {
                        $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions")
                    }
                    WinUpdateDownload
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config",
                        "DODownloadMode"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
                        "SystemSettingsDownloadMode"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization",
                        "SystemSettingsDownloadMode"),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
                        "DODownloadMode") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    UpdateMSRT
                    {
                        $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\MRT","DontOfferThroughWUAU")
                    }
                    UpdateDriver
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching",
                        "SearchOrderConfig"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
                        "ExcludeWUDriversInQualityUpdate"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata",
                        "PreventDeviceMetadataFromNetwork") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    RestartOnUpdate
                    {
                        ("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings",
                        "UxOption"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
                        "NoAutoRebootWithLoggOnUsers"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
                        "AUPowerManagement") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    AppAutoDownload
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate",
                        "AutoDownload"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
                        "DisableWindowsConsumerFeatures") | % {
                
                            $This.Registry($_[0],$_[1])
                        }
                    }
                    UpdateAvailablePopup
                    {
                        # (Null/No Registry)
                    }
                }
            }
            Service
            {
                Switch ($Item.Name)
                {
                    UAC
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","ConsentPromptBehaviorAdmin"),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop") | % { 
                        
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    SharingMappedDrives
                    {
                        $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLinkedConnections")
                    }
                    AdminShares
                    {
                        $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters","AutoShareWks")
                    }
                    Firewall
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile','EnableFirewall')
                    }
                    WinDefender
                    {
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
                        "DisableAntiSpyware"),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                        "WindowsDefender"),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                        "SecurityHealth"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                        $Null),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                        "SpynetReporting"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                        "SubmitSamplesConsent") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    HomeGroups
                    {
                        # (Null/No Registry)
                    }
                    RemoteAssistance
                    {
                        $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp")
                    }
                    RemoteDesktop
                    {
                        ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server",
                        "fDenyTSConnections"),
                        ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp",
                        "UserAuthentication") | % {
                        
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
            Context
            {
                Switch ($Item.Name)
                {
                    CastToDevice
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked",
                        "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}") | % { 
                            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    PreviousVersions
                    {
                        ("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                        $Null),
                        ("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                        $Null),
                        ("HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                        $Null),
                        ("HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                        $Null) | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    IncludeInLibrary
                    {
                        $Item.Registry("HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location","(Default)")
                    }
                    PinToStart      
                    {
                        ('HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}',
                        '(Default)'),
                        ('HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}',
                        '(Default)'),
                        ('HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen',
                        '(Default)'),
                        ('HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen',
                        '(Default)'),
                        ('HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen',
                        '(Default)'),
                        ('HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen',
                        '(Default)') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    PinToQuickAccess
                    {
                        ('HKCR:\Folder\shell\pintohome',
                        'MUIVerb'),
                        ('HKCR:\Folder\shell\pintohome',
                        'AppliesTo'),
                        ('HKCR:\Folder\shell\pintohome\command',
                        'DelegateExecute'),
                        ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome',
                        'MUIVerb'),
                        ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome',
                        'AppliesTo'),
                        ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command',
                        'DelegateExecute') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    ShareWith
                    {
                        ('HKCR:\*\shellex\ContextMenuHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\Directory\shellex\ContextMenuHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\Directory\shellex\CopyHookHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\Drive\shellex\ContextMenuHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\Directory\shellex\PropertySheetHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing',
                        '(Default)'),
                        ('HKCR:\*\shellex\ContextMenuHandlers\ModernSharing',
                        '(Default)') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    SendTo
                    {
                        $Item.Registry("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo","(Default)")
                    }
                }
            }
            Taskbar
            {
                Switch ($Item.Name)
                {
                    BatteryUIBar
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32BatteryFlyout')
                    }
                    ClockUIBar
                    {
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell',
                        'UseWin32TrayClockExperience') | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    VolumeControlBar
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC','EnableMtcUvc')
                    }
                    TaskbarSearchBox
                    {
                        $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode")
                    }
                    TaskViewButton
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
                        'ShowTaskViewButton') | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    TaskbarIconSize
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons')
                    }
                    TaskbarGrouping
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarGlomLevel')
                    }
                    TrayIcons
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray'),
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    SecondsInClock
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSecondsInSystemClock')
                    }
                    LastActiveClick
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LastActiveClick')
                    }
                    TaskbarOnMultiDisplay
                    {
                        $Item.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarEnabled')
                    }
                    TaskbarButtonDisplay
                    {
                        $Item.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarMode')
                    }
                }
            }
            StartMenu
            {
                Switch ($Item.Name)
                {
                    StartMenuWebSearch
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','BingSearchEnabled'),
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','DisableWebSearch') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    StartSuggestions
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","ContentDeliveryAllowed"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","OemPreInstalledAppsEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEverEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SilentInstalledAppsEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SystemPaneSuggestionsEnabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","Start_TrackProgs"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-314559Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-310093Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338387Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338388Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338389Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338393Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338394Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338396Enabled"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338398Enabled") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    MostUsedAppStartMenu
                    {
                        $Item.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Start_TrackProgs')
                    }
                    RecentItemsFrequent
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu',
                        "Start_TrackDocs") | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    UnpinItems
                    {
                        # (Null/No Registry)
                    }
                }
            }
            Explorer
            {
                Switch ($Item.Name)
                {
                    AccessKeyPrompt
                    {
                        ('HKCU:\Control Panel\Accessibility\StickyKeys',
                        "Flags"),
                        ('HKCU:\Control Panel\Accessibility\ToggleKeys',
                        "Flags"),
                        ('HKCU:\Control Panel\Accessibility\Keyboard Response',
                        "Flags") | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    F1HelpKey
                    {
                        ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0",
                        $Null),
                        ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32",
                        "(Default)"),
                        ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64",
                        "(Default)") | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    AutoPlay
                    {
                        # (Null/No Registry)
                    }
                    AutoRun
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer','NoDriveTypeAutoRun')
                    }
                    PidInTitleBar
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowPidInTitle')
                    }
                    RecentFileQuickAccess
                    {
                        # (Null/No Registry)
                    }
                    FrequentFoldersQuickAccess
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowFrequent')
                    }
                    WinContentWhileDrag
                    {
                        $Item.Registry('HKCU:\Control Panel\Desktop','DragFullWindows')
                    }
                    StoreOpenWith
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer','NoUseStoreOpenWith')
                    }
                    LongFilePath
                    {
                        ('HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem',
                        'LongPathsEnabled'),
                        ('HKLM:\SYSTEM\ControlSet001\Control\FileSystem',
                        'LongPathsEnabled') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    ExplorerOpenLoc
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LaunchTo')
                    }
                    WinXPowerShell
                    {
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
                        'DontUsePowerShellOnWinX') | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    AppHibernationFile
                    {
                        ("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management",
                        "SwapfileControl") | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    KnownExtensions
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','HideFileExt')
                    }
                    HiddenFiles
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Hidden')
                    }
                    SystemFiles
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSuperHidden')
                    }
                    Timeline
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System','EnableActivityFeed')
                    }
                    AeroSnap
                    {
                        $Item.Registry('HKCU:\Control Panel\Desktop','WindowArrangementActive')
                    }
                    AeroShake
                    {
                        $Item.Registry('HKCU:\Software\Policies\Microsoft\Windows\Explorer','NoWindowMinimizingShortcuts')     
                    }
                    TaskManagerDetails
                    {
                        $Item.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager',"Preferences")
                    }
                    ReopenAppsOnBoot
                    {
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
                        'DisableAutomaticRestartSignOn') | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
            ThisPCIcon
            {
                Switch ($Item.Name)
                {
                    Desktop
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
                        $Null),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                        "ThisPCPolicy") | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Documents
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
                        $Null),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}",
                        $Null),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        "BaseFolderID"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                        "BaseFolderID") | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Downloads
                    {
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        "BaseFolderID"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                        "BaseFolderID") | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Music
                    {
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        "BaseFolderID"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                        "BaseFolderID") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Pictures
                    {
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        "BaseFolderID"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                        "BaseFolderID") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Videos
                    {
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        "BaseFolderID"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                        "BaseFolderID") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    ThreeDObjects
                    {
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                        "ThisPCPolicy"),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                        $Null),
                        ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                        "ThisPCPolicy") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
            DesktopIcon
            {
                Switch ($Item.Name)
                {
                    ThisPC
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                        "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                        "{20D04FE0-3AEA-1069-A2D8-08002B30309D}") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Network
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                        "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                        "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    RecycleBin
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                        "{645FF040-5081-101B-9F08-00AA002F954E}"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                        "{645FF040-5081-101B-9F08-00AA002F954E}") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    Profile
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                        "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                        "{59031a47-3f72-44a7-89c5-5595fe6b30ee}") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    ControlPanel
                    {
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                        "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"),
                        ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                        "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}") | % { 

                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
            LockScreen
            {
                Switch ($Item.Name)
                {
                    LockScreen
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreen')
                    }
                    Password
                    {
                        ("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
                        "ScreenSaverIsSecure"),
                        ("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
                        "ScreenSaverIsSecure") | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    PowerMenu
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','shutdownwithoutlogon')
                    }
                    Camera
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreenCamera')
                    }
                }
            }
            Miscellaneous
            {
                Switch ($Item.Name)
                {
                    ScreenSaver
                    {
                        $Item.Registry("HKCU:\Control Panel\Desktop","ScreenSaveActive")
                    }
                    AccountProtectionWarn
                    {
                        $Item.Registry('HKCU:\SOFTWARE\Microsoft\Windows Security Health\State','AccountProtection_MicrosoftAccount_Disconnected')
                    }
                    ActionCenter
                    {
                        ('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer',
                        'DisableNotificationCenter'),
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications',
                        'ToastEnabled') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    StickyKeyPrompt
                    {
                        $Item.Registry('HKCU:\Control Panel\Accessibility\StickyKeys','Flags')
                    }
                    NumlockOnStart
                    {
                        $Item.Registry('HKU:\.DEFAULT\Control Panel\Keyboard','InitialKeyboardIndicators')
                    }
                    F8BootMenu
                    {
                        # (Null/No Registry)
                    }
                    RemoteUACAcctToken
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','LocalAccountTokenFilterPolicy')
                    }
                    HibernatePower
                    {
                        ('HKLM:\SYSTEM\CurrentControlSet\Control\Power','HibernateEnabled'),
                        ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings','ShowHibernateOption') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    SleepPower
                    {
                        $Item.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings',"ShowSleepOption")
                    }
                }
            }
            PhotoViewer
            {
                Switch ($Item.Name)
                {
                    FileAssociation
                    {
                        ("HKCR:\Paint.Picture\shell\open",
                        "MUIVerb"),
                        ("HKCR:\giffile\shell\open",
                        "MUIVerb"),
                        ("HKCR:\jpegfile\shell\open",
                        "MUIVerb"),
                        ("HKCR:\pngfile\shell\open",
                        "MUIVerb"),
                        ("HKCR:\Paint.Picture\shell\open\command",
                        "(Default)"),
                        ("HKCR:\giffile\shell\open\command",
                        "(Default)"),
                        ("HKCR:\jpegfile\shell\open\command",
                        "(Default)"),
                        ("HKCR:\pngfile\shell\open\command",
                        "(Default)"),
                        ("HKCR:\giffile\shell\open",
                        "CommandId"),
                        ("HKCR:\giffile\shell\open\command",
                        "DelegateExecute") | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    OpenWithMenu
                    {
                        ('HKCR:\Applications\photoviewer.dll\shell\open',
                        $Null),
                        ('HKCR:\Applications\photoviewer.dll\shell\open\command',
                        $Null),
                        ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget',
                        $Null),
                        ('HKCR:\Applications\photoviewer.dll\shell\open',
                        'MuiVerb'),
                        ('HKCR:\Applications\photoviewer.dll\shell\open\command',
                        '(Default)'),
                        ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget',
                        'Clsid') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
            WindowsApps
            {
                Switch ($Item.Name)
                {
                    OneDrive
                    {
                        ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive',
                        'DisableFileSyncNGSC'),
                        ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
                        'ShowSyncProviderNotifications') | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    OneDriveInstall
                    {
                        ("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
                        $Null),
                        ("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
                        $Null) | % {
                
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    XboxDVR
                    {
                        ("HKCU:\System\GameConfigStore",
                        "GameDVR_Enabled"),
                        ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR",
                        "AllowGameDVR") | % {
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                    MediaPlayer
                    {
                        # (Null/No Registry)
                    }
                    WorkFolders
                    {
                        # (Null/No Registry)
                    }
                    FaxAndScan
                    {
                        # (Null/No Registry)
                    }
                    LinuxSubsystem
                    {
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock",'AllowDevelopmentWithoutDevLicense'),
                        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock",'AllowAllTrustedApps') | % { 
            
                            $Item.Registry($_[0],$_[1])
                        }
                    }
                }
            }
        }
    }
    [String] ToString()
    {
        Return "<FEModule.ViperBomb.System[Controller]>"
    }
}

$Ctrl = [SystemController]::New()

<# [Now translate the SetMode methods to the outside ViperBombController class]
    
    # // ================
    # // | Privacy (12) |
    # // ================

    Class Telemetry
    {
        Telemetry()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Telemetry")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Telemetry")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    If ([Environment]::Is64BitProcess)
                    {
                        $This.Output[2].Set(0)
                    }
                    3..10 | % { $This.Output[$_].Remove() }
                    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                   "Microsoft\Windows\Application Experience\ProgramDataUpdater",
                   "Microsoft\Windows\Autochk\Proxy",
                   "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                   "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                   "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                   "Microsoft\Office\Office ClickToRun Service Monitor",
                   "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
                   "Microsoft\Office\OfficeTelemetryAgentLogOn2016" | % { Enable-ScheduledTask -TaskName $_ }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Telemetry")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    If ([Environment]::Is64BitProcess)
                    {
                        $This.Output[2].Set(0)
                    }
                    $This.Output[ 3].Set(0)
                    $This.Output[ 4].Set(1)
                    $This.Output[ 5].Set(0)
                    $This.Output[ 6].Set(0)
                    $This.Output[ 7].Set(1)
                    $This.Output[ 8].Set(0)
                    $This.Output[ 9].Set(1)
                    $This.Output[10].Set(0)
                    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                   "Microsoft\Windows\Application Experience\ProgramDataUpdater",
                   "Microsoft\Windows\Autochk\Proxy",
                   "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                   "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                   "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                   "Microsoft\Office\Office ClickToRun Service Monitor",
                   "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
                   "Microsoft\Office\OfficeTelemetryAgentLogOn2016" | % { Disable-ScheduledTask -TaskName $_ }
                }
            }
        }
    }
    
    Class WiFiSense *
    {
        WiFiSense()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [-] Wi-Fi Sense")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Wi-Fi Sense")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                    $This.Output[3].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Wi-Fi Sense")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    $This.Output[2].Remove()
                    $This.Output[3].Remove()
                }
            }
        }
    }
    
    Class SmartScreen *
    {
        SmartScreen()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [-] SmartScreen Filter")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] SmartScreen Filter")
                    $This.Output[0].Set("String","RequireAdmin")
                    1..3 | % { $This.Output[$_].Remove() }
                }
                2
                {
                    $This.Update(2,"Disabling [~] SmartScreen Filter")
                    $This.Output[0].Set("String","Off")
                    1..3 | % { $This.Output[$_].Set(0) }
                }
            }
        }
    }
    
    Class LocationTracking *
    {
        LocationTracking()
        {
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Location Tracking")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Location Tracking")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Location Tracking")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Feedback *
    {
        Feedback()
        {
           
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Feedback")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Feedback")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                    {
                        Enable-ScheduledTask -TaskName $Item | Out-Null 
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Feedback")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                    {
                        Disable-ScheduledTask -TaskName $Item | Out-Null 
                    }
                }
            }
        }
    }
    
    Class AdvertisingID *
    {
        AdvertisingID()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Advertising ID")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Advertising ID")
                    $This.Output[0].Remove()
                    $This.Output[1].Set(2)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Advertising ID")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Cortana *
    {
        Cortana()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0, "Skipping [!] Cortana")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Cortana")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Set(0)
                    $This.Output[3].Set(0)
                    $This.Output[4].Remove()
                    $This.Output[5].Remove()
                    $This.Output[6].Remove()
                    $This.Output[7].Set(1)
                    $This.Output[8].Remove()
                    $This.Output[9].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Cortana")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(1)
                    $This.Output[3].Set(0)
                    $This.Output[4].Set(0)
                    $This.Output[5].Set(1)
                    $This.Output[6].Set(3)
                    $This.Output[7].Set(0)
                    $This.Output[8].Set(0)
                    $This.Output[9].Set(1)
                }
            }
        }
    }
    
    Class CortanaSearch *
    {
        CortanaSearch()
        {   

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Cortana Search")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Cortana Search")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Cortana Search")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class ErrorReporting *
    {
        ErrorReporting()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Error Reporting")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Error Reporting")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Error Reporting")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class AutoLoggerFile *
    {
        AutoLoggerFile()
        {

        }
        [String] WmiRegistry()
        {
            Return "HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener"
        }
        [String] AutoLogger()
        {
            Return "$Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] AutoLogger")
                    }
                }
                1
                {
                    $This.Update(1,"Unrestricting [~] AutoLogger")
                    $This.SetAcl("/grant:r SYSTEM:`(OI`)`(CI`)F")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Removing [~] AutoLogger, and restricting directory")
                    $This.SetAcl("/deny SYSTEM:`(OI`)`(CI`)F")
                    Remove-Item "$($This.AutoLogger())\AutoLogger-Diagtrack-Listener.etl" -EA 0 -Verbose
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class DiagTrack *
    {
        DiagTrack()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Diagnostics Tracking")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Diagnostics Tracking")
                    Get-Service -Name DiagTrack
                    Set-Service -Name DiagTrack -StartupType Automatic
                    Start-Service -Name DiagTrack
                }
                2
                {
                    $This.Update(2,"Disabling [~] Diagnostics Tracking")
                    Stop-Service -Name DiagTrack
                    Set-Service -Name DiagTrack -StartupType Disabled
                    Get-Service -Name DiagTrack
                }
            }
        }
    }
    
    Class WAPPush *
    {
        WAPPush()
        {
            $This.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart")
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] WAP Push")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] WAP Push Service")
                    Set-Service -Name dmwappushservice -StartupType Automatic
                    Start-Service -Name dmwappushservice
                    $This.Output[0].Set(1)
                    Get-Service -Name dmwappushservice
                }
                2
                {
                    $This.Update(2,"Disabling [~] WAP Push Service")
                    Stop-Service -Name dmwappushservice
                    Set-Service -Name dmwappushservice -StartupType Disabled
                    Get-Service -Name dmwappushservice
                }
            }
        }
    }


    # // ======================
    # // | Windows Update (8) |
    # // ======================
    

    Class UpdateMSProducts *
    {
        UpdateMSProducts()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Update Microsoft Products")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Update Microsoft Products")
                    $This.ComMusm().AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
                }
                2
                {
                    $This.Update(2,"Disabling [~] Update Microsoft Products")
                    $This.ComMusm().RemoveService("7971f918-a847-4430-9279-4a52d1efe18d")
                }
            }
        }
        [Object] ComMusm()
        {
            Return New-Object -ComObject Microsoft.Update.ServiceManager
        }
    }
    
    Class CheckForWindowsUpdate *
    {
        CheckForWindowsUpdate()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Check for Windows Updates")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Check for Windows Updates")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Check for Windows Updates")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class WinUpdateType *
    {
        WinUpdateType()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Windows Update Check Type")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Notify for Windows Update downloads, notify to install")
                    $This.Output[0].Set(2)
                }
                2
                {
                    $This.Update(2,"Enabling [~] Automatically download Windows Updates, notify to install")
                    $This.Output[0].Set(3)
                }
                3
                {
                    $This.Update(3,"Enabling [~] Automatically download Windows Updates, schedule to install")
                    $This.Output[0].Set(4)
                }
                4
                {
                    $This.Update(4,"Enabling [~] Allow local administrator to choose automatic updates")
                    $This.Output[0].Set(5)
                }
            }
        }
    }
    
    Class WinUpdateDownload *
    {
        WinUpdateDownload()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] ")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Unrestricting Windows Update P2P to Internet")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Enabling [~] Restricting Windows Update P2P only to local network")
                    $This.Output[1].Set(3)
                    Switch($This.GetWinVersion())
                    {
                        1507
                        {
                            $This.Output[0]
                        }
                        {$_ -gt 1507 -and $_ -le 1607}
                        {
                            $This.Output[0].Set(1)
                        }
                        Default
                        {
                            $This.Output[0].Remove()
                        }
                    }
                }
                3
                {
                    $This.Update(3,"Disabling [~] Windows Update P2P")
                    $This.Output[1].Set(3)
                    Switch ($This.GetWinVersion())
                    {
                        1507
                        {
                            $This.Output[0].Set(0)
                        }
                        Default
                        {
                            $This.Output[3].Set(100)
                        }
                    }
                }
            }
        }
    }
    
    Class UpdateMSRT *
    {
        UpdateMSRT()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Malicious Software Removal Tool Update")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Malicious Software Removal Tool Update")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Malicious Software Removal Tool Update")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class UpdateDriver *
    {
        UpdateDriver()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Driver update through Windows Update")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Driver update through Windows Update")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Driver update through Windows Update")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(1)
                }
            }
        }
    }
    
    Class RestartOnUpdate *
    {
        RestartOnUpdate()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Windows Update Automatic Restart")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Update Automatic Restart")
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Windows Update Automatic Restart")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                }
            }
        }
    }
    
    Class AppAutoDownload *
    {
        AppAutoDownload()
        {

        }
        [String] AppAutoCloudCache()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
        }
        [String] AppAutoPlaceholder() 
        {
            Return "*windows.data.placeholdertilecollection\Current"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] App Auto Download")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] App Auto Download")
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] App Auto Download")
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
                    If ($This.GetWinVersion() -le 1803)
                    {
                        $Key  = Get-ChildItem $This.AppAutoCloudCache() -Recurse | ? Name -like $This.AppAutoPlaceholder()
                        $Data = (Get-ItemProperty -Path $Key.PSPath).Data
                        Set-ItemProperty -Path $Key -Name Data -Type Binary -Value $Data[0..15] -Verbose
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }
    
    Class UpdateAvailablePopup *
    {
        UpdateAvailablePopup()
        {
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Update Available Popup")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Update Available Popup")
                    $This.MUSNotify()  | % { 
                        ICACLS $_ /remove:d '"Everyone"'
                        ICACLS $_ /grant ('Everyone' + ':(OI)(CI)F')
                        ICACLS $_ /setowner 'NT SERVICE\TrustedInstaller'
                        ICACLS $_ /remove:g '"Everyone"'
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Update Available Popup")
                    $This.MUSNotify() | % {
                        
                        Takeown /f $_
                        ICACLS $_ /deny '"Everyone":(F)'
                    }
                }
            }
        }
        [String[]] MUSNotify()
        {
            Return @("","ux" | % { "$Env:windir\System32\musnotification$_.exe" })
        }
    }
	
	    # // ===============
    # // | Service (8) |
    # // ===============

    Class UAC *
    {
        UAC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] UAC Level")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] UAC Level (Low)")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set
                }
                2
                {
                    $This.Update(2,"Setting [~] UAC Level (Default)")
                    $This.Output[0].Set(5)
                    $This.Output[1].Set(1)
                }
                3
                {
                    $This.Update(3,"Setting [~] UAC Level (High)")
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
    
    Class SharingMappedDrives *
    {
        SharingMappedDrives()
        {   

        }
        [String] RegPath()
        {
            Return 
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Sharing mapped drives between users")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sharing mapped drives between users")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sharing mapped drives between users")
                    $This.Output[0].Remove()
                }
            }
        }
    }
    
    Class AdminShares *
    {
        AdminShares()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Hidden administrative shares")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hidden administrative shares")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hidden administrative shares")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class Firewall *
    {
        Firewall()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Firewall Profile")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Firewall Profile")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Firewall Profile")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class WinDefender *
    {
        WinDefender()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Windows Defender")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Defender")
                    $This.Output[0].Remove()
                    Switch ($This.GetWinVersion())
                    {
                        {$_ -lt 1703}
                        {
                            $This.Output[1].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")
                        }
                        Default
                        {
                            $This.Output[2].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")     
                        }
                    }
                    $This.Output[3].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Windows Defender")
                    Switch ($This.GetWinVersion())
                    {
                        {$_ -lt 1703}
                        {
                            $This.Output[1].Remove()
                        }
                        Default
                        {
                            $This.Output[2].Remove()    
                        }
                    }
                    $This.Output[0].Set(1)
                    $This.Output[4].Set(0)
                    $This.Output[5].Set(2)
                }
            }
        }
    }
    
    Class HomeGroups *
    {
        HomeGroups()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Home groups services")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Home groups services")
                    Set-Service   -Name HomeGroupListener -StartupType Manual
                    Set-Service   -Name HomeGroupProvider -StartupType Manual
                    Start-Service -Name HomeGroupProvider
                }
                2
                {
                    $This.Update(2,"Disabling [~] Home groups services")
                    Stop-Service  -Name HomeGroupListener
                    Set-Service   -Name HomeGroupListener -StartupType Disabled
                    Stop-Service  -Name HomeGroupProvider
                    Set-Service   -Name HomeGroupProvider -StartupType Disabled
                }
            }
        }
    }
    
    Class RemoteAssistance *
    {
        RemoteAssistance()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Remote Assistance")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote Assistance")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote Assistance")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class RemoteDesktop *
    {
        RemoteDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Remote Desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote Desktop")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote Desktop")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
	
	    # // ===============
    # // | Context (7) |
    # // ===============

    Class CastToDevice *
    {
        CastToDevice()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Cast to device' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Cast to device' context menu item")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Cast to device' context menu item")
                    $This.Output[0].Set("String","Play to Menu")
                }
            }
        }
    }

    Class PreviousVersions *
    {
        PreviousVersions()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Previous versions' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Previous versions' context menu item")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Get()
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Previous versions' context menu item")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                    $This.Output[3].Remove()
                }
            }
        }
    }

    Class IncludeInLibrary *
    {
        IncludeInLibrary()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Include in Library' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Include in Library' context menu item")
                    $This.Output[0].Set("String","{3dad6c5d-2167-4cae-9914-f99e41c12cfa}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Include in Library' context menu item")
                    $This.Output[0].Set("String","")
                }
            }
        }
    }

    Class PinToStart *
    {
        PinToStart()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Pin to Start' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Pin to Start' context menu item")
                    $This.Output[0].Set("String","Taskband Pin")
                    $This.Output[1].Set("String","Start Menu Pin")
                    $This.Output[2].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[3].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[4].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[5].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Pin to Start' context menu item")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Set("String","")
                    $This.Output[3].Set("String","")
                    $This.Output[4].Set("String","")
                    $This.Output[5].Set("String","")
                }
            }
        }
    }

    Class PinToQuickAccess *
    {
        PinToQuickAccess()
        {

        }
        [String] QuickAccessParseName()
        {
            Return 'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}"', 
                   'System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}"', 
                   'System.IsFolder:=System.StructuredQueryType.Boolean#True' -join " AND "
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Pin to Quick Access' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Pin to Quick Access' context menu item")
                    $This.Output[0].Set("String",'@shell32.dll,-51377')
                    $This.Output[1].Set("String",$This.QuickAccessParseName())
                    $This.Output[2].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                    $This.Output[3].Set("String",'@shell32.dll,-51377')
                    $This.Output[4].Set("String",$This.QuickAccessParseName())
                    $This.Output[5].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Pin to Quick Access' context menu item")
                    $This.Output[0].Name = $Null
                    $This.Output[0].Remove()
                    $This.Output[3].Name = $Null
                    $This.Output[3].Remove()
                }
            }
        }
    }

    Class ShareWith *
    {
        ShareWith()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Share with' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Share with' context menu item")
                    0..7 | % { $This.Output[$_].Set("String","{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}") }
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Share with' context menu item")
                    0..7 | % { $This.Output[$_].Set("String","") }
                }
            }
        }
    }

    Class SendTo *
    {
        SendTo()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Send to' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Send to' context menu item")
                    $This.Output[0].Set("String","{7BA4C740-9E81-11CF-99D3-00AA004AE837}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Send to' context menu item")
                    $This.Output[0].Name = $Null
                    $This.Output[0].Remove()
                }
            }
        }
    }
	
	    # // ================
    # // | Taskbar (12) |
    # // ================

    Class BatteryUIBar *
    {
        BatteryUIBar()
        {
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Battery UI Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Battery UI Bar (New)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Setting [~] Battery UI Bar (Old)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class ClockUIBar *
    {
        ClockUIBar()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Clock UI Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Clock UI Bar (New)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Setting [~] Clock UI Bar (Old)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class VolumeControlBar *
    {
        VolumeControlBar()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Volume Control Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Volume Control Bar (Horizontal)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Volume Control Bar (Vertical)")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskBarSearchBox *
    {
        TaskBarSearchBox()
        {            
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Taskbar 'Search Box' button")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Taskbar 'Search Box' button")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Taskbar 'Search Box' button")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskViewButton *
    {
        TaskViewButton()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Task View button")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Task View button")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Task View button")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarIconSize *
    {
        TaskbarIconSize()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Icon size in taskbar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Icon size in taskbar")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Icon size in taskbar")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskbarGrouping *
    {
        TaskbarGrouping()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Group Taskbar Items")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Group Taskbar Items (Never)")
                    $This.Output[0].Set(2)
                }
                2
                {
                    $This.Update(2,"Setting [~] Group Taskbar Items (Always)")
                    $This.Output[0].Set(0)
                }
                3
                {
                    $This.Update(3,"Setting [~] Group Taskbar Items (When needed)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TrayIcons *
    {
        TrayIcons()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Tray Icons")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Tray Icons (Hiding)")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Setting [~] Tray Icons (Showing)")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class SecondsInClock *
    {
        SecondsInClock()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Seconds in Taskbar clock")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Seconds in Taskbar clock")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Seconds in Taskbar clock")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class LastActiveClick *
    {
        LastActiveClick()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Last active click")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Last active click")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Last active click")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarOnMultiDisplay *
    {
        TaskbarOnMultiDisplay()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Taskbar on Multiple Displays")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Taskbar on Multiple Displays")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Taskbar on Multiple Displays")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarButtonDisplay *
    {
        TaskbarButtonDisplay()
        {
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Taskbar buttons on multiple displays")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Taskbar buttons, multi-display (All taskbars)")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Taskbar buttons, multi-display (Taskbar where window is open)")
                    $This.Output[0].Set(2)
                }
                3
                {
                    $This.Update(3,"Setting [~] Taskbar buttons, multi-display (Main taskbar + where window is open)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
	
	
    # // =================
    # // | StartMenu (5) |
    # // =================

    Class StartMenuWebSearch *
    {
        StartMenuWebSearch()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Bing Search in Start Menu")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Bing Search in Start Menu")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Bing Search in Start Menu")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                }
            }
        }
    }

    Class StartSuggestions *
    {
        StartSuggestions()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Start Menu Suggestions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Start Menu Suggestions")
                    0..15 | % { $This.Output[$_].Set(1) }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Start Menu Suggestions")
                    0..15 | % { $This.Output[$_].Set(0) }
                    If ($This.GetWinVersion() -ge 1803) 
                    {
                        $Key = Get-ItemProperty -Path $This.StartSuggestionsCloudCache()
                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Key.Data[0..15]
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }

    Class MostUsedAppStartMenu *
    {
        MostUsedAppStartMenu()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Most used apps in Start Menu")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Most used apps in Start Menu")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Most used apps in Start Menu")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class RecentItemsFrequent *
    {
        RecentItemsFrequent()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Recent items and frequent places")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Recent items and frequent places")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Recent items and frequent places")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class UnpinItems *
    {
        UnpinItems()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Unpinning Items")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Unpinning Items")
                    $xPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
                    $xColl = "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
                    If ($This.GetWinVersion() -le 1709) 
                    {
                        ForEach ($Item in Get-ChildItem $xPath -Include *.group -Recurse)
                        {
                            $Path = "{0}\Current" -f $Item.PsPath
                            $Data = (Get-ItemProperty $Path -Name Data).Data -join ","
                            $Data = $Data.Substring(0, $Data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
                            Set-ItemProperty $Path -Name Data -Type Binary -Value $Data.Split(",")
                        }
                    }
                    Else 
                    {
                        $Key     = Get-ItemProperty -Path "$xPath\$xColl"
                        $Data    = $Key.Data[0..25] + ([Byte[]](202,50,0,226,44,1,1,0,0))
                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Data
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }
	
	    # // =================
    # // | Explorer (21) |
    # // =================

    Class AccessKeyPrompt *
    {
        AccessKeyPrompt()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Accessibility keys prompts")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Accessibility keys prompts")
                    $This.Output[0].Set("String",510)
                    $This.Output[1].Set("String",62)
                    $This.Output[2].Set("String",126)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Accessibility keys prompts")
                    $This.Output[0].Set("String",506)
                    $This.Output[1].Set("String",58)
                    $This.Output[2].Set("String",122)
                }
            }
        }
    }

    Class F1HelpKey *
    {
        F1HelpKey()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] F1 Help Key")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] F1 Help Key")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] F1 Help Key")
                    $This.Output[1].Set("String","")
                    If ($This.x64Bit())
                    {
                    $This.Output[2].Set("String","")  
                    }
                }
            }
        }
    }

    Class AutoPlay *
    {
        AutoPlay()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Autoplay")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Autoplay")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Autoplay")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class AutoRun *
    {
        AutoRun()
        {            
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Autorun")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Autorun")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Autorun")
                    $This.Output[0].Set(255)
                }
            }
        }
    }

    Class PidInTitleBar *
    {
        PidInTitleBar()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Process ID on Title bar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Process ID on Title bar")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Process ID on Title bar")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class RecentFileQuickAccess *
    {
        RecentFileQuickAccess()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Recent Files in Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Recent Files in Quick Access (Showing)")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set("String","Recent Items Instance Folder")
                    If ($This.x64Bit())
                    {
                        $This.Output[2].Set("String","Recent Items Instance Folder")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Recent Files in Quick Access (Hiding)")
                    $This.Output[0].Set(0)
                }
                3
                {
                    $This.Update(3,"Setting [~] Recent Files in Quick Access (Removing)")
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[2].Remove()
                    }
                }
            }
        }
    }

    Class FrequentFoldersQuickAccess *
    {
        FrequentFoldersQuickAccess()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Frequent folders in Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Frequent folders in Quick Access")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Frequent folders in Quick Access")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class WinContentWhileDrag *
    {
        WinContentWhileDrag()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Window content while dragging")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Window content while dragging")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Window content while dragging")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class StoreOpenWith *
    {
        StoreOpenWith()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Search Windows Store for Unknown Extensions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Search Windows Store for Unknown Extensions")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Search Windows Store for Unknown Extensions")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class LongFilePath *
    {
        LongFilePath()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Long file path")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Long file path")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Long file path")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
            }
        }
    }

    Class ExplorerOpenLoc *
    {
        ExplorerOpenLoc()
        {            
            
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Default Explorer view to Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Default Explorer view to Quick Access")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Default Explorer view to Quick Access")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class WinXPowerShell *
    {
        WinXPowerShell()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] (Win+X) PowerShell/Command Prompt")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] (Win+X) PowerShell/Command Prompt")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] (Win+X) PowerShell/Command Prompt")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class AppHibernationFile *
    {
        AppHibernationFile()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] App Hibernation File (swapfile.sys)")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] App Hibernation File (swapfile.sys)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] App Hibernation File (swapfile.sys)")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class KnownExtensions *
    {
        KnownExtensions()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Known File Extensions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Known File Extensions")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Known File Extensions")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class HiddenFiles *
    {
        HiddenFiles()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Hidden Files")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hidden Files")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hidden Files")
                    $This.Output[0].Set(2)
                }
            }
        }
    }

    Class SystemFiles *
    {
        SystemFiles()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] System Files")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] System Files")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] System Files")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class Timeline *
    {
        Timeline()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            If ($This.GetWinVersion())
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            $This.Update(0,"Skipping [!] Windows Timeline")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Windows Timeline")
                        $This.Output[0].Set(1)
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Windows Timeline")
                        $This.Output[0].Set(0)
                    }
                }
            }
        }
    }

    Class AeroSnap *
    {
        AeroSnap()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Aero Snap")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Aero Snap")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Aero Snap")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AeroShake *
    {
        AeroShake()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Aero Shake")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Aero Shake")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Aero Shake")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskManagerDetails *
    {
        TaskManagerDetails()
        {       

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Task Manager Details")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Task Manager Details")
                    $Path         = $This.Output[0].Path
                    $Task         = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
                    $Collect      = @( )
                    $Timeout      = 0
                    $TM           = $Null
                    Do
                    {
                        Start-Sleep -Milliseconds 100
                        $TM       = Get-ItemProperty -Path $Path | % Preferences
                        $Collect += 100
                        $TimeOut  = $Collect -join "+" | Invoke-Expression
                    }
                    Until ($TM -or $Timeout -ge 30000)
                    Stop-Process $Task
                    $TM[28]       = 0
                    $This.Output[0].Set("Binary",$TM)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Task Manager Details")
                    $TM           = $This.Output[0].Get().Preferences
                    $TM[28]       = 1
                    $This.Output[0].Set("Binary",$TM)
                }
            }
        }
    }

    Class ReopenAppsOnBoot *
    {
        ReopenAppsOnBoot()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            If ($This.GetWinVersion() -eq 1709)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            $This.Update(0,"Skipping [!] Reopen applications at boot time")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Reopen applications at boot time")
                        $This.Output[0].Set(0)
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Reopen applications at boot time")
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }
	
	    # // ==================
    # // | ThisPCIcon (7) |
    # // ==================

    Class DesktopIconInThisPC *
    {
        DesktopIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Desktop folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Desktop folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Set("String","Show")
                    If ($This.x64Bit())
                    {
                        $This.Output[3].Get()
                        $This.Output[4].Get()
                        $This.Output[5].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Desktop folder in This PC (Hidden)")
                    $This.Output[2].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Desktop folder in This PC (None)")
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                    }
                }
            }
        }
    }
    
    Class DocumentsIconInThisPC *
    {
        DocumentsIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Documents folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Documents folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{FDD39AD0-238F-46AF-ADB4-6C85480369C7}")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Documents folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Documents folder in This PC (None)")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }
    
    Class DownloadsIconInThisPC *
    {
        DownloadsIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Downloads folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Downloads folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{374DE290-123F-4565-9164-39C4925E467B}")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Downloads folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Documents folder in This PC (None)")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }
    
    Class MusicIconInThisPC *
    {
        MusicIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Music folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Music folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{4BD8D571-6D19-48D3-BE97-422220080E43}")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Music folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Music folder in This PC (None)")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }
    
    Class PicturesIconInThisPC *
    {
        PicturesIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Pictures folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Pictures folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{33E28130-4E1E-4676-835A-98395C3BC3BB}")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Pictures folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Pictures folder in This PC (None)")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }
    
    Class VideosIconInThisPC *
    {
        VideosIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Videos folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Videos folder in This PC (Shown)")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{18989B1D-99B5-455B-841C-AB7C74E4DDFC}")
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Videos folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ($This.x64Bit())
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Videos folder in This PC (None)")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ($This.x64Bit())
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }
    
    Class ThreeDObjectsIconInThisPC *
    {
        ThreeDObjectsIconInThisPC()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            If ($This.GetWinVersion() -ge 1709)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            $This.Update(0,"Skipping [!] 3D Objects folder in This PC")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] 3D Objects folder in This PC (Shown)")
                        $This.Output[0].Get()
                        $This.Output[1].Get()
                        $This.Output[2].Set("String","Show")
                        If ($This.x64Bit())
                        {
                            $This.Output[3].Get()
                            $This.Output[4].Get()
                            $This.Output[5].Set("String","Show")
                        }
                    }
                    2
                    {
                        $This.Update(2,"Setting [~] 3D Objects folder in This PC (Hidden)")
                        $This.Output[2].Set("String","Hide")
                        If ($This.x64Bit())
                        {
                            $This.Output[5].Set("String","Hide")
                        }
                    }
                    3
                    {
                        $This.Update(3,"Setting [~] 3D Objects folder in This PC (None)")
                        $This.Output[1].Remove()
                        If ($This.x64Bit())
                        {
                            $This.Output[5].Remove()
                        }
                    }
                }
            }
        }
    }
	
	
    # // ===================
    # // | DesktopIcon (5) |
    # // ===================

    Class ThisPCOnDesktop *
    {
        ThisPCOnDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] This PC Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] This PC Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] This PC Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class NetworkOnDesktop *
    {
        NetworkOnDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Network Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Network Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Network Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class RecycleBinOnDesktop *
    {
        RecycleBinOnDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Recycle Bin Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Recycle Bin Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Recycle Bin Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class ProfileOnDesktop *
    {
        ProfileOnDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Users file Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Users file Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Users file Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class ControlPanelOnDesktop *
    {
        ControlPanelOnDesktop()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Control Panel Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Control Panel Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Control Panel Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
	
	    # // ==================
    # // | LockScreen (4) |
    # // ==================

    Class LockScreen *
    {
        LockScreen()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Lock Screen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Lock Screen")
                    If ($This.GetWinVersion() -ge 1607)
                    {
                        Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$False -Verbose
                    }
                    Else
                    {
                        $This.Output[0].Remove()
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Lock Screen")
                    If ($This.GetWinVersion() -ge 1607)
                    {
                        $Service             = New-Object -ComObject Schedule.Service
                        $Service.Connect()
                        $Task                = $Service.NewTask(0)
                        $Task.Settings.DisallowStartIfOnBatteries = $False
                        $Trigger             = $Task.Triggers.Create(9)
                        $Trigger             = $Task.Triggers.Create(11)
                        $Trigger.StateChange = 8
                        $Action              = $Task.Actions.Create(0)
                        $Action.Path         = 'Reg.exe'
                        $Action.Arguments    = $This.LockscreenArgument()
                        $Service.GetFolder('\').RegisterTaskDefinition('Disable LockScreen',$Task,6,
                                                                       'NT AUTHORITY\SYSTEM',$Null,4)
                    }
                    Else
                    {
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class LockScreenPassword *
    {
        LockScreenPassword()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Lock Screen Password")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Lock Screen Password")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Lock Screen Password")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class PowerMenuLockScreen *
    {
        PowerMenuLockScreen()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Power Menu on Lock Screen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Power Menu on Lock Screen")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Power Menu on Lock Screen")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class CameraOnLockScreen *
    {
        CameraOnLockScreen()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Camera at Lockscreen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Camera at Lockscreen")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Camera at Lockscreen")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
	
    # // =====================
    # // | Miscellaneous (9) |
    # // =====================

    Class ScreenSaver *
    {
        ScreenSaver()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Screensaver")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Screensaver")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Screensaver")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AccountProtectionWarn *
    {
        AccountProtectionWarn()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            If ($This.GetWinVersion() -ge 1803)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            $This.Update(0,"Skipping [!] Account Protection Warning")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Account Protection Warning")
                        $This.Output[0].Remove()
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Account Protection Warning")
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class ActionCenter *
    {
        ActionCenter()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Action Center")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Action Center")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Action Center")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class StickyKeyPrompt *
    {
        StickyKeyPrompt()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Sticky Key Prompt")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sticky Key Prompt")
                    $This.Output[0].Set("String",510)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sticky Key Prompt")
                    $This.Output[0].Set("String",506)
                }
            }
        }
    }

    Class NumlockOnStart *
    {
        NumlockOnStart()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Num Lock on startup")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Num Lock on startup")
                    $This.Output[0].Set(2147483650)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Num Lock on startup")
                    $This.Output[0].Set(2147483648)
                }
            }
        }
    }

    Class F8BootMenu *
    {
        F8BootMenu()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] F8 Boot menu options")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] F8 Boot menu options")
                    $This.SetBcdEdit('/set {current} bootmenupolicy Legacy')
                }
                2
                {
                    $This.Update(0,"Disabling [~] F8 Boot menu options")
                    $This.SetBcdEdit('/set {current} bootmenupolicy Standard')
                }
            }
        }
    }

    Class RemoteUACAcctToken *
    {
        RemoteUACAcctToken()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Remote UAC Local Account Token Filter")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote UAC Local Account Token Filter")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote UAC Local Account Token Filter")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class HibernatePower *
    {
        HibernatePower()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Hibernate Option")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hibernate Option")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.SetPowerCfg("/HIBERNATE ON")
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hibernate Option")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    $This.SetPowerCfg("/HIBERNATE OFF")
                }
            }
        }
    }

    Class SleepPower *
    {
        SleepPower()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Sleep Option")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sleep Option")
                    $This.Output[0].Set(1)
                    $This.SetPowerCfg("/SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1")
                    $This.SetPowerCfg("/SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1")
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sleep Option")
                    $This.Output[0].Set(0)
                    $This.SetPowerCfg("/SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0")
                    $This.SetPowerCfg("/SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0")
                }
            }
        }
    }
	
    # // ===================
    # // | PhotoViewer (2) |
    # // ===================

    Class PVFileAssociation *
    {
        PVFileAssociation()
        {    

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Photo Viewer File Association")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Photo Viewer File Association")
                    0..3 | % { 
    
                        $This.Output[$_  ].Set("ExpandString",
                                               "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
                        $This.Output[$_+4].Set("ExpandString",
                                               '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1')
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Photo Viewer File Association")
                    $iExplore = '"{0}\{1}" %1' -f [Environment]::GetEnvironmentVariable("ProgramFiles"),"Internet Explorer\iexplore.exe"

                    $This.Output[0] | % { $_.Clear(); $_.Remove() }
                    $This.Output[1].Remove()
                    $This.Output[2] | % { $_.Clear(); $_.Remove() }
                    $This.Output[3] | % { $_.Clear(); $_.Remove() }
                    $This.Output[5].Set("String",$IExplore)
                    $This.Output[8].Set("String","IE.File")
                    $This.Output[9].Set("String","{17FE9752-0B5A-4665-84CD-569794602F5C}")
                }
            }
        }
    }

    Class PVOpenWithMenu *
    {
        PVOpenWithMenu()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Open with Photo Viewer' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Open with Photo Viewer' context menu item")
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String",
                                        "@photoviewer.dll,-3043")
                    $This.Output[4].Set("ExpandString",
                                        '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1')
                    $This.Output[5].Set("String",
                                        "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Open with Photo Viewer' context menu item")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    # // ===================
    # // | WindowsApps (7) |
    # // ===================

    Class OneDrive *
    {
        OneDrive()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] OneDrive")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] OneDrive")
                    $This.Output[0].Remove()
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] OneDrive")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class OneDriveInstall *
    {
        OneDriveInstall()
        {            

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] OneDrive Install")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] OneDrive Install")
                    $xPath = "$Env:Windir\{0}\OneDriveSetup.exe" -f ,@("System32","SysWOW64")[$This.x64Bit()]

                    If ([System.IO.File]::Exists($xPath)) 
                    {
                        Start-Process $Path -NoNewWindow 
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] OneDrive Install")
                    $xPath = "$Env:Windir\{0}\OneDriveSetup.exe" -f ,@("System32","SysWOW64")[$This.x64Bit()]
                    If ([System.IO.File]::Exists($xPath))
                    {
                        Stop-Process -Name OneDrive -Force
                        Start-Sleep -Seconds 3
                        Start-Process $xPath "/uninstall" -NoNewWindow -Wait
                        Start-Sleep -Seconds 3
    
                        ForEach ($Path in "$Env:USERPROFILE\OneDrive",
                                          "$Env:LOCALAPPDATA\Microsoft\OneDrive",
                                          "$Env:PROGRAMDATA\Microsoft OneDrive",
                                          "$Env:WINDIR\OneDriveTemp",
                                          "$Env:SYSTEMDRIVE\OneDriveTemp")
                        {    
                            Remove-Item $Path -Force -Recurse 
                        }
    
                        $This.Output[0].Remove()
                        $This.Output[1].Remove()
                    }
                }
            }
        }
    }

    Class XboxDVR *
    {
        XboxDVR()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Xbox DVR")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Xbox DVR")
                    $This.Output[0].Set(1)
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Xbox DVR")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class MediaPlayer *
    {
        MediaPlayer()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Windows Media Player")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Media Player")
                    $Name    = "WindowsMediaPlayer"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -ne "Enabled")
                    {
                        $This.EnableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Enabled"
                        }
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Windows Media Player")
                    $Name    = "WindowsMediaPlayer"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -eq "Enabled")
                    {
                        $This.DisableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Disabled"
                        }
                    }
                }
            }
        }
    }

    Class WorkFolders *
    {
        WorkFolders()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Work Folders Client")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Work Folders Client")
                    $Name    = "WorkFolders-Client"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -ne "Enabled")
                    {
                        $This.EnableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Enabled"
                        }
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Work Folders Client")
                    $Name    = "WorkFolders-Client"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -eq "Enabled")
                    {
                        $This.DisableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Disabled"
                        }
                    }
                }
            }
        }
    }

    Class FaxAndScan *
    {
        FaxAndScan()
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Fax And Scan")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Fax And Scan")
                    $Name = "FaxServicesClientPackage"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -ne "Enabled")
                    {
                        $This.EnableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Enabled"
                        }
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Fax And Scan")
                    $Name = "FaxServicesClientPackage"
                    $Feature = $This.GetFeature($Name)
                    If ($Feature.State -eq "Enabled")
                    {
                        $This.DisableFeature($Name)
                        If (!!$?)
                        {
                            $Feature.State = "Disabled"
                        }
                    }
                }
            }
        }
    }

    Class LinuxSubsystem *
    {
        LinuxSubsystem([Object]$Console) : Base($Console)
        {

        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            If ($This.GetWinVersion() -gt 1607)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            $This.Update(0,"Skipping [!] Linux Subsystem")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Linux Subsystem")
                        $Name = "Microsoft-Windows-Subsystem-Linux"
                        $Feature = $This.GetFeature($Name)
                        If ($Feature.State -ne "Enabled")
                        {
                            $This.EnableFeature($Name)
                            If (!!$?)
                            {
                                $Feature.State = "Enabled"
                            }
                        }
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Linux Subsystem")
                        $Name = "Microsoft-Windows-Subsystem-Linux"
                        $Feature = $This.GetFeature($Name)
                        If ($Feature.State -eq "Enabled")
                        {
                            $This.DisableFeature($Name)
                            If (!!$?)
                            {
                                $Feature.State = "Disabled"
                            }
                        }
                    }
                }
            }
            Else
            {
                $This.Update(-1,"Error [!] This version of Windows does not support (WSL/Windows Subsystem for Linux)")
            }
        }
    }

#>

<#
    Class DisableVariousTasks
    {
        [UInt32] $Mode
        [Object] $Output
        DisableVariousTasks()
        {
            $This.Output = @()
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped,[Object[]]$TaskList)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Various Scheduled Tasks")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Various Scheduled Tasks")
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Enable-ScheduledTask }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Various Scheduled Tasks")
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask }
                }
            }
        }
    }
    
    Class ScreenSaverWaitTime
    {
        [UInt32] $Mode
        [Object] $Output
        ScreenSaverWaitTime()
        {
            $This.Output = @([Registry]::New('HKLM:\Software\Policies\Microsoft\Windows','ScreensaveTimeout'))
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] ScreenSaver Wait Time")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] ScreenSaver Wait Time")
                }
                2
                {
                    $This.Update(0,"Disabling [~] ScreenSaver Wait Time"
                }
            }
        }
    }
    #>
