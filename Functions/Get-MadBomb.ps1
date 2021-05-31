Function Get-MadBomb
{
    Class _ListItem
    {
        [String] $ID
        [Object] $Slot

        _ListItem([String]$ID,[Object]$Slot)
        {
            $This.ID   = $ID
            $This.Slot = $Slot
        }
    }

    Class _Privacy
    {
        Hidden [String[]]       $Names = ("Telemetry WiFiSense SmartScreen LocationTracking Feedback AdvertisingID " +
                                        "Cortana CortanaSearch ErrorReporting AutoLogging DiagnosticsTracking Win" + 
                                        "dowsApp WindowsAppAutoDL").Split(" ")

        [UInt32]            $Telemetry = 1
        [UInt32]            $WiFiSense = 1
        [UInt32]          $SmartScreen = 1
        [UInt32]     $LocationTracking = 1
        [UInt32]             $Feedback = 1
        [UInt32]        $AdvertisingID = 1
        [UInt32]              $Cortana = 1
        [UInt32]        $CortanaSearch = 1
        [UInt32]       $ErrorReporting = 1
        [UInt32]          $AutoLogging = 1
        [UInt32]  $DiagnosticsTracking = 1
        [UInt32]           $WindowsApp = 1
        [UInt32]     $WindowsAppAutoDL = 0
        [Object]               $Output

        _Privacy()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Service
    {
        Hidden [String[]]             $Names = ("UAC SMBDrives AdminShares Firewall WinDefender HomeGroups" + 
                                                " RemoteAssistance RemoteDesktop").Split(" ")
        [UInt32]                        $UAC = 2
        [UInt32]                  $SMBDrives = 2
        [UInt32]                $AdminShares = 1
        [UInt32]                   $Firewall = 1
        [UInt32]                $WinDefender = 1
        [UInt32]                 $HomeGroups = 1
        [UInt32]           $RemoteAssistance = 1
        [UInt32]              $RemoteDesktop = 2
        
        [Object]                     $Output

        _Service()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Context
    {
        Hidden [String[]]             $Names = ("CastToDevice PreviousVersions IncludeInLibrary PinToStart PinToQuickAccess ShareWith SendTo").Split(" ") 

        [UInt32]               $CastToDevice = 1
        [UInt32]           $PreviousVersions = 1
        [UInt32]           $IncludeinLibrary = 1
        [UInt32]                 $PinToStart = 1
        [UInt32]           $PinToQuickAccess = 1
        [UInt32]                  $ShareWith = 1
        [UInt32]                     $SendTo = 1

        [Object]                     $Output

        _Context()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _StartMenu 
    {
        Hidden [String[]] $Names = ("StartMenuWebSearch StartSuggestions MostUsedAppStartMenu RecentItemsFrequent UnpinItems").Split(" ")

        [UInt32]         $StartMenuWebSearch = 1
        [UInt32]           $StartSuggestions = 1
        [UInt32]       $MostUsedAppStartMenu = 1
        [UInt32]        $RecentItemsFrequent = 1
        [UInt32]                 $UnpinItems = 0

        [Object]                     $Output
        
        _StartMenu()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Taskbar
    {
        Hidden [String[]] $Names = ("BatteryUIBar ClockUIBar VolumeControlBar TaskbarSearchBox " +
                                    "TaskViewButton TaskbarIconSize TaskbarGrouping TrayIcons S" + 
                                    "econdsInClock LastActiveClick").Split(" ")

        [UInt32]               $BatteryUIBar = 1
        [UInt32]                 $ClockUIBar = 1
        [UInt32]           $VolumeControlBar = 1
        [UInt32]           $TaskbarSearchBox = 1
        [UInt32]             $TaskViewButton = 1
        [UInt32]            $TaskbarIconSize = 1
        [UInt32]            $TaskbarGrouping = 2
        [UInt32]                  $TrayIcons = 1
        [UInt32]             $SecondsInClock = 2
        [UInt32]            $LastActiveClick = 2
        [UInt32]      $TaskBarOnMultiDisplay = 1

        [Object]                     $Output

        _Taskbar()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }
	
    Class _Explorer
    {
        Hidden [String[]]             $Names = ("RecentFileQuickAccess FrequentFoldersQuickAccess WinContentWhileDrag " + 
                                                "StoreOpenWith LongFilePath ExplorerOpenLoc WinXPowerShell AppHibernat" + 
                                                "ionFile PidTitleBar AccessKeyPrompt Timeline AeroSnap AeroShake Known" + 
                                                "Extensions HiddenFiles SystemFiles AutoPlay AutoRun TaskManager F1Hel" + 
                                                "pKey ReopenApps").Split(" ")
        [UInt32]      $RecentFileQuickAccess = 1
        [UInt32] $FrequentFoldersQuickAccess = 1
        [UInt32]        $WinContentWhileDrag = 1
        [UInt32]              $StoreOpenWith = 1
        [UInt32]               $LongFilePath = 2
        [UInt32]            $ExplorerOpenLoc = 1
        [UInt32]             $WinXPowerShell = 1
        [UInt32]         $AppHibernationFile = 1
        [UInt32]                $PidTitleBar = 2
        [UInt32]            $AccessKeyPrompt = 1
        [UInt32]                   $Timeline = 1
        [UInt32]                   $AeroSnap = 1
        [UInt32]                  $AeroShake = 1
        [UInt32]            $KnownExtensions = 2
        [UInt32]                $HiddenFiles = 2
        [UInt32]                $SystemFiles = 2
        [UInt32]                   $AutoPlay = 1
        [UInt32]                    $AutoRun = 1
        [UInt32]                $TaskManager = 2
        [UInt32]                  $F1HelpKey = 1
        [UInt32]                 $ReopenApps = 1

        [Object]                     $Output

        _Explorer()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Icons
    {
        Hidden [String[]]             $Names = "MyComputer Network RecycleBin Documents ControlPanel".Split(" ")

        [UInt32]                 $MyComputer = 2
        [UInt32]                    $Network = 2
        [UInt32]                 $RecycleBin = 1
        [UInt32]                  $Documents = 2
        [UInt32]               $ControlPanel = 2

        [Object]                     $Output

        _Icons()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Paths
    {
        Hidden [String[]]             $Names = "Desktop Documents Downloads Music Pictures Videos 3DObjects".Split(" ")
        [UInt32]                    $Desktop = 1
        [UInt32]                  $Documents = 1
        [UInt32]                  $Downloads = 1
        [UInt32]                      $Music = 1
        [UInt32]                   $Pictures = 1
        [UInt32]                     $Videos = 1
        [UInt32]                  $3DObjects = 1

        [Object]                     $Output

        _Paths()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _PhotoViewer 
    {
        Hidden [String[]]             $Names = "PhotoViewerFileAssociation PhotoViewerOpenWithMenu".Split(" ")
      	[UInt32] $PhotoViewerFileAssociation = 2
        [UInt32]    $PhotoViewerOpenWithMenu = 2
        [Object]                     $Output

        _PhotoViewer()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _LockScreen
    {
        Hidden [String[]]             $Names = 'LockScreen PowerMenuLockScreen CameraOnLockScreen'.Split(" ")

        [UInt32]                 $LockScreen = 1
        [UInt32]        $PowerMenuLockScreen = 1
        [UInt32]         $CameraOnLockScreen = 1
        [Object]                     $Output

        _LockScreen()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _Miscellaneous
    {
        Hidden [String[]]             $Names = 'AccountProtectionWarn ActionCenter StickyKeyPrompt NumblockOnStart F8BootMenu RemoteUACAccountToken SleepPower'.Split(" ")
        
        [UInt32]      $AccountProtectionWarn = 1
        [UInt32]               $ActionCenter = 1
        [UInt32]            $StickyKeyPrompt = 1
        [UInt32]            $NumblockOnStart = 2
        [UInt32]                 $F8BootMenu = 1
        [UInt32]      $RemoteUACAccountToken = 2
        [UInt32]                 $SleepPower = 1

        [Object]                     $Output

        _Miscellaneous()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _WindowsApps
    {
        Hidden [String[]] $Names = 'OneDrive OneDriveInstall XboxDVR MediaPlayer WorkFolders FaxAndScan LinuxSubsystem'.Split(" ")
        [UInt32]                   $OneDrive = 1
        [UInt32]            $OneDriveInstall = 1
        [UInt32]                    $XboxDVR = 1
        [UInt32]                $MediaPlayer = 1
        [UInt32]                $WorkFolders = 1
        [UInt32]                 $FaxAndScan = 1
        [UInt32]             $LinuxSubsystem = 2
        
        [Object]                     $Output

        _WindowsApps()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _WindowsUpdate
    {
        Hidden [String[]]             $Names = ('CheckForWinUpdate WinUpdateType WinUpdateDownload UpdateMSRT UpdateDriver ' + 
                                                'RestartOnUpdate AppAutoDownload UpdateAvailablePopup').Split(" ")

        [UInt32]          $CheckForWinUpdate = 1
        [UInt32]              $WinUpdateType = 3
        [UInt32]          $WinUpdateDownload = 1
        [UInt32]                 $UpdateMSRT = 1
        [UInt32]               $UpdateDriver = 1
        [UInt32]            $RestartOnUpdate = 1
        [UInt32]            $AppAutoDownload = 1
        [UInt32]       $UpdateAvailablePopup = 1

        [Object]                     $Output

        _WindowsUpdate()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [_ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class _AppXObject
    {
        Hidden [String[]] $Line
        [String] $AppXName
        [String] $CName
        [String] $VarName
        
        _AppXObject([String]$Line)
        {
            $This.Line     = $Line.Split(";")
            $This.AppXName = $This.Line[0]
            $This.CName    = $This.Line[1]
            $This.VarName  = "`${0}" -f $This.Line[2]
        }
    }

    Class _AppXCollection
    {
        [String] $List     = ('Microsoft.3DBuilder;3DBuilder;APP_3DBuilder,Microsoft.Microsoft3DViewer;3DViewer;APP_3DViewer,Microsoft' +
                              '.BingWeather;Bing Weather;APP_BingWeather,Microsoft.CommsPhone;Phone;APP_CommsPhone,Microsoft.windowsco' +
                              'mmunicationsapps;Calendar & Mail;APP_Communications,Microsoft.GetHelp;Microsofts Self-Help;APP_GetHelp,' +
                              'Microsoft.Getstarted;Get Started Link;APP_Getstarted,Microsoft.Messaging;Messaging;APP_Messaging,Micros' + 
                              'oft.MicrosoftOfficeHub;Get Office Link;APP_MicrosoftOffHub,Microsoft.MovieMoments;Movie Moments;APP_Mov' + 
                              'ieMoments,4DF9E0F8.Netflix;Netflix;APP_Netflix,Microsoft.Office.OneNote;Office OneNote;APP_OfficeOneNot' + 
                              'e,Microsoft.Office.Sway;Office Sway;APP_OfficeSway,Microsoft.OneConnect;One Connect;APP_OneConnect,Micr' + 
                              'osoft.People;People;APP_People,Microsoft.Windows.Photos;Photos;APP_Photos,Microsoft.SkypeApp;Skype;APP_' + 
                              'SkypeApp1,Microsoft.MicrosoftSolitaireCollection;Microsoft Solitaire;APP_SolitaireCollect,Microsoft.Mic' + 
                              'rosoftStickyNotes;Sticky Notes;APP_StickyNotes,Microsoft.WindowsSoundRecorder;Voice Recorder;APP_VoiceR' + 
                              'ecorder,Microsoft.WindowsAlarms;Alarms and Clock;APP_WindowsAlarms,Microsoft.WindowsCalculator;Calculat' +
                              'or;APP_WindowsCalculator,Microsoft.WindowsCamera;Camera;APP_WindowsCamera,Microsoft.WindowsFeedback;Win' + 
                              'dows Feedback;APP_WindowsFeedbak1,Microsoft.WindowsFeedbackHub;Windows Feedback Hub;APP_WindowsFeedbak2' +
                              ',Microsoft.WindowsMaps;Maps;APP_WindowsMaps,Microsoft.WindowsPhone;Phone Companion;APP_WindowsPhone,Mic' +
                              'rosoft.WindowsStore;Microsoft Store;APP_WindowsStore,Microsoft.Wallet;Stores Credit and Debit Card Info' +
                              'rmation;APP_WindowsWallet,$Xbox_Apps;Xbox Apps (All);APP_XboxApp,Microsoft.ZuneMusic;Groove Music;APP_Z' +
                              'uneMusic,Microsoft.ZuneVideo;Groove Video;APP_ZuneVideo')
        [Object] $Output
        
        _AppXCollection()
        {
            $This.Output = @( )

            ForEach ( $Item in $This.List -Split "," )
            {
                $This.Output += [_AppxObject]::New($Item)
            }
        }
    }

    Class _Config
    {
        [Object]                    $Privacy
	    [Object]                    $Service
        [Object]                    $Context
        [Object]                    $Taskbar
        [Object]                   $Explorer
        [Object]                  $StartMenu
        [Object]                      $Paths
        [Object]                      $Icons
        [Object]                 $LockScreen
        [Object]              $Miscellaneous
        [Object]                $PhotoViewer
        [Object]                $WindowsApps
        [Object]              $WindowsUpdate
        [Object]                       $AppX

        _Config()
        {
            $This.Reset()
        }

        Reset()
        {
            $This.Privacy                    = [_Privacy]::New().Output
            $This.Service                    = [_Service]::New().Output
            $This.Context                    = [_Context]::New().Output
            $This.Taskbar                    = [_Taskbar]::New().Output
            $This.Explorer                   = [_Explorer]::New().Output
            $This.StartMenu                  = [_StartMenu]::New().Output
            $This.Paths                      = [_Paths]::New().Output
            $This.Icons                      = [_Icons]::New().Output
            $This.LockScreen                 = [_LockScreen]::New().Output
            $This.Miscellaneous              = [_Miscellaneous]::New().Output
            $This.PhotoViewer                = [_PhotoViewer]::New().Output
            $This.WindowsApps                = [_WindowsApps]::New().Output
            $This.WindowsUpdate              = [_WindowsUpdate]::New().Output
            $This.AppX                       = [_AppXCollection]::New().Output
        }
    }

    Class _Script
    {
        # Script Revised by mcc85sx
        [String] $Author  = 'MadBomb122|mcc85sx'
        [String] $Version = '4.0.0'
        [String] $Date    = 'Feb-08-2021'
        [String] $Release = 'Test'
        [String] $Site    = 'tbd'
        [String] $URL

        _Script()
        {

        }
    }

    Class _Control
    {
        [Object] $RestorePoint
        [Object] $ShowSkipped
        [Object] $Restart
        [Object] $VersionCheck
        [Object] $InternetCheck
        [Object] $Save
        [Object] $Load
        [Object] $WinDefault
        [Object] $ResetDefault

        _Control()
        {

        }
    }

    Class _Madbomb
    {
        [Object]                     $Window
        [Object]                         $IO
        [Object]                     $Config
        [Object]                     $Script
        [Object]                    $Control

        _MadBomb()
        {
            $This.Window                     = Get-XamlWindow -Type MBWin10
            $This.IO                         = $This.Window.IO
            $This.Config                     = [_Config]::New()
            $This.Script                     = [_Script]::New()
            $This.Control                    = [_Control]::New()
        }

        [Void] Toggle([Object]$Item)
        {
            $Item = Switch ($Item)
            {
                0 { 1 }
                1 { 0 }
            }
        }
    }

    $UI = [_MadBomb]::New()
    $UI.IO._Feedback.Add_Click({      Start https://github.com/madbomb122/Win10Script/issues })
    $UI.IO._FAQ.Add_Click({           Start https://github.com/madbomb122/Win10Script/blob/master/README.md })
    $UI.IO._About.Add_Click({         [System.Windows.Messagebox]::Show('This script performs various settings/tweaks for Windows 10.','About','OK') })
    $UI.IO._Copyright.Add_Click({     [System.Windows.Messagebox]::Show($Copyright) })
    $UI.IO._Contact.Add_Click({ })
    $UI.IO._Donation.Add_Click({      Start https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/ })
    $UI.IO._Madbomb.Add_Click({       Start https://github.com/madbomb122/ })
    
    $UI.IO._RestorePoint.Add_Click({  $UI.Toggle($UI.Control.RestorePoint)  })  
    $UI.IO._ShowSkipped.Add_Click({   $UI.Toggle($UI.Control.ShowSkipped)   }) 
    $UI.IO._Restart.Add_Click({       $UI.Toggle($UI.Control.Restart)       }) 
    $UI.IO._VersionCheck.Add_Click({  $UI.Toggle($UI.Control.VersionCheck)  }) 
    $UI.IO._InternetCheck.Add_Click({ $UI.Toggle($UI.Control.InternetCheck) }) 
    $UI.IO._Save.Add_Click({          $UI.Toggle($UI.Control.Save)          }) 
    $UI.IO._Load.Add_Click({          $UI.Toggle($UI.Control.Load)          }) 
    $UI.IO._WinDefault.Add_Click({    $UI.Toggle($UI.Control.WinDefault)    }) 
    $UI.IO._ResetDefault.Add_Click({  $UI.Toggle($UI.Control.ResetDefault)  }) 

    $UI.IO._Privacy.ItemsSource       = $UI.Config.Privacy
    $UI.IO._Service.ItemsSource       = $UI.Config.Service
    $UI.IO._Context.ItemsSource       = $UI.Config.Context
    $UI.IO._Taskbar.ItemsSource       = $UI.Config.Taskbar
    $UI.IO._Explorer.ItemsSource      = $UI.Config.Explorer
    $UI.IO._StartMenu.ItemsSource     = $UI.Config.StartMenu
    $UI.IO._Paths.ItemsSource         = $UI.Config.Paths
    $UI.IO._Icons.ItemsSource         = $UI.Config.Icons
    $UI.IO._LockScreen.ItemsSource    = $UI.Config.LockScreen
    $UI.IO._Miscellaneous.ItemsSource = $UI.Config.Miscellaneous
    $UI.IO._PhotoViewer.ItemsSource   = $UI.Config.PhotoViewer
    $UI.IO._WindowsStore.ItemsSource  = $UI.Config.WindowsApps
    $UI.IO._WindowsUpdate.ItemsSource = $UI.Config.WindowsUpdate
    $UI.IO._AppX.ItemsSource          = $UI.Config.AppX

    $UI.Window.Invoke()
}
