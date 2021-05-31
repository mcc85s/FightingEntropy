Function Get-ViperBomb
{
    Invoke-Expression "Using Namespace System.Windows.Markup"
    Add-Type -AssemblyName PresentationFramework

    Class _ViperBombConfig
    {
        [String]               $Name = "FightingEntropy/ViperBomb"
        [String]            $Version = "2021.4.0"
        [String]            $Release = "Development"
        [String]           $Provider = "Secure Digits Plus LLC"
        [String]                $URL = "https://github.com/mcc85sx/FightingEntropy"
        [String]            $MadBomb = "https://github.com/madbomb122/BlackViperScript"
        [String]         $BlackViper = "http://www.blackviper.com"
        [String]               $Site = "https://www.securedigitsplus.com"
        
                                     #  Original copyright
        Hidden [String[]] $Copyright = ("Copyright (c) 2019 Zero Rights Reserved;Services Configuration by Charles 'Black Viper' Sparks;;The MIT Licens" + 
                                        "e (MIT) + an added Condition;;Copyright (c) 2017-2019 Madbomb122;;[Black Viper Service Script];Permission is her" + 
                                        "eby granted, free of charge, to any person obtaining a ;copy of this software and associated documentation files" + 
                                        " (the Software),;to deal in the Software without restriction, including w/o limitation;the rights to: use/copy/m" + 
                                        "odify/merge/publish/distribute/sublicense,;and/or sell copies of the Software, and to permit persons to whom the" + 
                                        ";Software is furnished to do so, subject to the following conditions:;;The above copyright notice(s), this permi" + 
                                        "ssion notice and ANY original;donation link shall be included in all copies or substantial portions of;the Softw" + 
                                        "are.;;The software is provided 'As Is', without warranty of any kind, express;or implied, including but not limi" + 
                                        "ted to warranties of merchantibility,;or fitness for a particular purpose and noninfringement. In no event;shall" + 
                                        " the authors or copyright holders be liable for any claim, damages;or other liability, whether in an action of c" + 
                                        "ontract, tort or otherwise,;arising from, out of or in connection with the software or the use or;other dealings" + 
                                        " in the software.;;In other words, these terms of service must be accepted in order to use,;and in no circumstan" + 
                                        "ce may the author(s) be subjected to any liability;or damage resultant to its use.").Split(";")
        Hidden [String[]]     $About = ("This utility provides an interface to load and customize;service configuration profiles, such as:;;    Default" + 
                                        ": Black Viper (Sparks v1.0);    Custom: If in proper format;    Backup: Created via this utility").Split(";")
                                        
                                        # Not yet implemented
        Hidden [String[]]      $Help = (("[Basic];;_-atos___Accepts ToS;_-auto___Automates Process | Aborts upon user input/errors;;[Profile];;_-defaul" + 
                                        "t__Standard;_-safe___Sparks/Safe;_-tweaked__Sparks/Tweaked;_-lcsc File.csv  Loads Custom Service Configuration, " + 
                                        "File.csv = Name of your backup/custom file;;[Template];;_-all___ Every windows services will change;_-min___ Jus" + 
                                        "t the services different from the default to safe/tweaked list;_-sxb___ Skips changes to all XBox Services;;[Upd" + 
                                        "ate];;_-usc___ Checks for Update to Script file before running;_-use___ Checks for Update to Service file before" + 
                                        " running;_-sic___ Skips Internet Check, if you can't ping GitHub.com for some reason;;[Logging];;_-log___ Makes " + 
                                        "a log file named using default name Script.log;_-log File.log_Makes a log file named File.log;_-baf___ Log File " + 
                                        "of Services Configuration Before and After the script;;[Backup];;_-bscc___Backup Current Service Configuration C" + 
                                        "sv File;_-bscr___Backup Current Service Configuration, Reg File;_-bscb___Backup Current Service Configuration, C" + 
                                        "sv and Reg File;;[Display];;_-sas___ Show Already Set Services;_-snis___Show Not Installed Services;_-sss___ Sho" + 
                                        "wSkipped Services;;[Miscellaneous];;_-dry___ Runs the Script and Shows what services will be changed;_-css___ Ch" + 
                                        "ange State of Service;_-sds___ Stop Disabled Service;;[Experimental];;_-secp___Skips Edition Check by Setting Ed" + 
                                        "ition as Pro;_-sech___Skips Edition Check by Setting Edition as Home;_-sbc___ Skips Build Check;;[Development];;" + 
                                        "_-devl___Makes a log file with various Diagnostic information, Nothing is Changed;_-diag___Shows diagnostic info" + 
                                        "rmation, Stops -auto;_-diagf__   Forced diagnostic information, Script does nothing else;;[Help];;_-help___Shows" +
                                        " list of switches, then exits script.. alt -h;_-copy___Shows Copyright/License Information, then exits script" + 
                                        ";").Replace("_","    ")).Split(";")
                                        
        Hidden [String[]]      $Type = "10H:D+ 10H:D- 10P:D+ 10P:D- DT:S+ DT:S- DT:T+ DT:T- LT:S+ LT:S-".Split(" ")
        Hidden [String[]]     $Title = (("{0} Home | {1};{0} Pro | {1};{2} | Safe;{2} | Tweaked;Laptop | Safe" -f "Windows 10","Default","Desktop" -Split ";") | % { "$_ Max" , "$_ Min" })

        Hidden [Hashtable]  $Display = @{ 
                                Xbox = ("XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc xbgm" -Split " ")
                              NetTCP = ("Msmq Pipe Tcp" -Split " " | % { "Net$_`Activator" })
                                Skip = (@(("AppXSVC BrokerInfrastructure ClipSVC CoreMessagingRegistrar DcomLaunch EntAppSvc gpsvc LSM MpsSvc msiserver NgcCt" + 
                                           "nrSvc NgcSvc RpcEptMapper RpcSs Schedule SecurityHealthService sppsvc StateRepository SystemEventsBroker tiledata" + 
                                           "modelsvc WdNisSvc WinDefend") -Split " ";("BcastDVRUserService DevicePickerUserSvc DevicesFlowUserSvc PimIndexMai" +
                                           "ntenanceSvc PrintWorkflowUserSvc UnistoreSvc UserDataSvc WpnUserService") -Split " " | % { 
                                               "{0}_{1}" -f $_,(( Get-Service *_* | ? ServiceType -eq 224 )[0].Name -Split '_')[-1] }) | Sort-Object )
        }

        [String]         $PassedArgs = $Null
        [Int32]      $TermsOfService = 0
        [Int32]             $ByBuild = 0
        [Int32]           $ByEdition = 0
        [Int32]            $ByLaptop = 0
        [Int32]          $DispActive = 1
        [Int32]        $DispInactive = 1
        [Int32]         $DispSkipped = 1
        [Int32]        $MiscSimulate = 0
        [Int32]            $MiscXbox = 1
        [Int32]          $MiscChange = 0
        [Int32]    $MiscStopDisabled = 0
        [Int32]           $DevErrors = 0
        [Int32]              $DevLog = 0
        [Int32]          $DevConsole = 0
        [Int32]           $DevReport = 0
        [String]        $LogSvcLabel = "Service.log"
        [String]        $LogScrLabel = "Script.log"
        [String]           $RegLabel = "Backup.reg"
        [String]           $CsvLabel = "Backup.csv"
        [String]       $ServiceLabel = "Black Viper (Sparks v1.0)"
        [String]        $ScriptLabel = "DevOPS (MC/SDP v1.0)"

        [Object]            $Service
    
        _ViperBombConfig()
        {

        }
    }

    Class _ViperBomb
    {
        [Object]             $Window
        [Object]                 $IO
        [Object]               $Info
        [Object]             $Config
        [Object]            $Service

        _ViperBomb([Object]$Window)
        {
            $This.Window  = $Window
            $This.IO      = $Window.IO
            $This.Info    = (Get-FEModule | % Role)
            $This.Config  = [_ViperBombConfig]::New()
            $This.Service = (Get-FEService | % Output)
        }

        [Void] SetProfile([UInt32]$Slot)
        {
            ForEach ( $Service in $This.Service )
            {
                $Service.SetProfile($Slot)
            }
        }

        [Object[]] GetServices()
        {
            Return @( $This.Service )
        }

        [Object[]] FilterServices([Object]$Field,[Object]$String)
        {
            Return @( $This.Service | ? $Field -match $String )
        }
    }

    $UI                                  = [_ViperBomb]::New((Get-XamlWindow -Type FEService))
    $UI.IO.DataGrid.ItemsSource          = $UI.Service

    $UI.IO.Profile_0.Add_Click({ $UI.SetProfile(0) })
    $UI.IO.Profile_1.Add_Click({ $UI.SetProfile(1) })
    $UI.IO.Profile_2.Add_Click({ $UI.SetProfile(2) })
    $UI.IO.Profile_3.Add_Click({ $UI.SetProfile(3) })
    $UI.IO.Profile_4.Add_Click({ $UI.SetProfile(4) })
    $UI.IO.Profile_5.Add_Click({ $UI.SetProfile(5) })    
    $UI.IO.Profile_6.Add_Click({ $UI.SetProfile(6) })
    $UI.IO.Profile_7.Add_Click({ $UI.SetProfile(7) })    
    $UI.IO.Profile_8.Add_Click({ $UI.SetProfile(8) })
    $UI.IO.Profile_9.Add_Click({ $UI.SetProfile(9) })

    $UI.IO.Title                         = ("{0} v{1}" -f $UI.Config.Name, $UI.Config.Version)

    $UI.IO.URL.Add_Click({        Start $UI.Config.URL        })
    $UI.IO.MadBomb.Add_Click({    Start $UI.Config.MadBomb    })
    $UI.IO.BlackViper.Add_Click({ Start $UI.Config.BlackViper })
    $UI.IO.Site.Add_Click({       Start $UI.Config.Site       })
    $UI.IO.About.Add_Click({      [System.Windows.MessageBox]::Show(($UI.Config.About     -join "`n"),    "About")})
    $UI.IO.Copyright.Add_Click({  [System.Windows.MessageBox]::Show(($UI.Config.Copyright -join "`n"),"Copyright")})
    $UI.IO.Help.Add_Click({       [System.Windows.MessageBox]::Show(($UI.Config.Help      -join "`n"),     "Help")})

    $UI.IO.Caption.Content               = $UI.Info.Caption
    $UI.IO.ReleaseID.Content             = $UI.Info.ReleaseID
    $UI.IO.Version.Content               = $UI.Info.Version
    $UI.IO.Caption.Content               = $UI.Info.Caption

    ForEach ( $Item in ("DispActive DispInactive DispSkipped MiscSimulate MiscXbox MiscChange MiscStopDisabled " +
    "DevErrors DevLog DevConsole DevReport ByBuild").Split(" ") )
    { 
        $UI.IO.$Item.IsChecked               = $UI.Config.$Item
    } 

    $UI.IO.ByEdition.SelectedItem            = $UI.Config.ByEdition
    $UI.IO.ByLaptop.IsChecked                = $UI.Config.ByLaptop 
    $UI.IO.LogSvcSwitch.IsChecked            = 0
    $UI.IO.LogSvcBrowse.IsEnabled            = 0

    If ( $UI.IO.LogSvcSwitch.IsChecked -eq 0 ) { $UI.IO.LogSvcBrowse.IsEnabled    = 0 }
    If ( $UI.IO.LogSvcSwitch.IsChecked -eq 1 ) { $UI.IO.LogSvcBrowse.IsEnabled    = 1 }
        
    $UI.IO.LogScrSwitch.IsChecked        = 0
    $UI.IO.LogScrBrowse.IsEnabled        = 0
        
    If ( $UI.IO.LogScrSwitch.IsChecked -eq 1 ) { $UI.IO.LogScrBrowse.IsEnabled    = 1 }
    If ( $UI.IO.LogScrSwitch.IsChecked -eq 0 ) { $UI.IO.LogScrBrowse.IsEnabled    = 0 }
            
    $UI.IO.RegSwitch.IsChecked           = 0
    $UI.IO.RegBrowse.IsEnabled           = 0
        
    If ( $UI.IO.RegSwitch.IsChecked    -eq 0 ) { $UI.IO.RegBrowse.IsEnabled       = 0 }
    If ( $UI.IO.RegSwitch.IsChecked    -eq 1 ) { $UI.IO.RegBrowse.IsEnabled       = 1 }
        
    $UI.IO.CsvSwitch.IsChecked           = 0
    $UI.IO.CsvBrowse.IsEnabled           = 0
        
    If ( $UI.IO.CsvSwitch.IsChecked    -eq 1 ) { $UI.IO.CsvBrowse.IsEnabled       = 1 }
    If ( $UI.IO.CsvSwitch.IsChecked    -eq 0 ) { $UI.IO.CsvBrowse.IsEnabled       = 0 }
        
    $UI.IO.LogSvcFile.Text               = $UI.Config.LogSvcLabel
    $UI.IO.LogScrFile.Text               = $UI.Config.LogScrLabel
    $UI.IO.RegFile.Text                  = $UI.Config.RegLabel
    $UI.IO.CsvFile.Text                  = $UI.Config.CsvLabel 
        
    $UI.IO.LogSvcBrowse.IsEnabled        = 0
    $UI.IO.LogScrBrowse.IsEnabled        = 0
    $UI.IO.RegBrowse.IsEnabled           = 0
    $UI.IO.CsvBrowse.IsEnabled           = 0

    $UI.IO.Search.Add_TextChanged{
    
        $UI.IO.DataGrid.ItemsSource      = $UI.FilterServices($UI.IO.Select.SelectedItem.Content,$UI.IO.Search.Text)    
    }

    $UI.IO.Start.Add_Click{        
        
        [Console]::WriteLine("Dialog Successful")
        $UI.IO.DialogResult                      = $True
    }
    
    $UI.IO.Cancel.Add_Click{       
    
        [Console]::WriteLine("User Cancelled")
        $UI.IO.DialogResult                      = $False
    }

    $UI.Window.Invoke()
}
