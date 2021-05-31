Class _ViperBomb
{
    [String]               $Name = "FightingEntropy/ViperBomb"
    [String]            $Version = "2020.1.1"
    [String]            $Release = "Development"
    [String]           $Provider = "Secure Digits Plus LLC"
    [String]                $URL = "https://github.com/mcc85sx/FightingEntropy"
    [String]            $MadBomb = "https://github.com/madbomb122/BlackViperScript"
    [String]         $BlackViper = "http://www.blackviper.com"
    [String]               $Site = "https://www.securedigitsplus.com"
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
    Hidden [String[]]     $Title = (("{0} Home | {1};{0} Pro | {1};{2} | Safe;{2} | Tweaked;Laptop | Safe" -f "Windows 10","Default","Desktop"
                                 ).Split(";") | % { "$_ Max" , "$_ Min" })

    Hidden [Hashtable]  $Display = @{ 
                            Xbox = ("XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc xbgm" -Split " ")
                          NetTCP = ("Msmq Pipe Tcp" -Split " " | % { "Net$_`Activator" })
                            Skip = (@(("AppXSVC BrokerInfrastructure ClipSVC CoreMessagingRegistrar DcomLaunch EntAppSvc gpsvc LSM MpsSvc msiserver NgcCt" + 
                                       "nrSvc NgcSvc RpcEptMapper RpcSs Schedule SecurityHealthService sppsvc StateRepository SystemEventsBroker tiledata" + 
                                       "modelsvc WdNisSvc WinDefend") -Split " ";("BcastDVRUserService DevicePickerUserSvc DevicesFlowUserSvc PimIndexMai" +
                                       "ntenanceSvc PrintWorkflowUserSvc UnistoreSvc UserDataSvc WpnUserService") -Split " " | % { 
                                           "{0}_{1}" -f $_,(( Get-Service *_* | ? ServiceType -eq 224 )[0].Name -Split '_')[-1] 
                                        }) | Sort-Object )
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

    [Object]           $Services
    
    _ViperBomb()
    {
        
    }
}
