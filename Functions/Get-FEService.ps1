<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-FEService.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Collects the currently running services, and adds the service configurati                //   
   \\                     on template (Windows).                                                                   \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-10-10                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:43    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-FEService
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1,Mandatory)][Switch]$Output)

    Class FEService
    {
        [Int32]               $Index
        [String]               $Name 
        [Bool]                $Scope
        [Int32[]]           $Profile
        [Int32]                $Slot
        [Int32]    $DelayedAutoStart 
        [String]          $StartMode 
        [String]              $State 
        [String]             $Status 
        [String]        $DisplayName
        [String]           $PathName 
        [String]        $Description 
        FEService([Int32]$Index,[Object]$WMI)
        {
            $This.Index              = $Index
            $This.Name               = $WMI.Name
            $This.DelayedAutoStart   = $WMI.DelayedAutoStart
            $This.StartMode          = $WMI.StartMode
            $This.State              = $WMI.State
            $This.Status             = $WMI.Status
            $This.DisplayName        = $WMI.DisplayName
            $This.PathName           = $WMI.PathName
            $This.Description        = $WMI.Description
        }
        SetProfile([Int32]$Slot)
        {
            If ($Slot -notin 0..9)
            {
                Throw "Invalid selection"
            }
    
            $This.Slot               = $This.Profile[$Slot]
        }
    }

    Class FEServices
    {
        [String]       $QMark
        [Hashtable]   $Config = @{
            Names   = (("AJRouter;ALG;AppHostSvc;AppIDSvc;Appinfo;AppMgmt;AppReadiness;AppVClient;aspnet_state;AssignedAccessManagerSvc;" + 
                        "AudioEndpointBuilder;AudioSrv;AxInstSV;BcastDVRUserService_{0};BDESVC;BFE;BITS;BluetoothUserService_{0};Browser;B" +
                        "TAGService;BthAvctpSvc;BthHFSrv;bthserv;c2wts;camsvc;CaptureService_{0};CDPSvc;CDPUserSvc_{0};CertPropSvc;COMSysA" + 
                        "pp;CryptSvc;CscService;defragsvc;DeviceAssociationService;DeviceInstall;DevicePickerUserSvc_{0};DevQueryBroker;Dh" +
                        "cp;diagnosticshub.standardcollector.service;diagsvc;DiagTrack;DmEnrollmentSvc;dmwappushsvc;Dnscache;DoSvc;dot3svc" +
                        ";DPS;DsmSVC;DsRoleSvc;DsSvc;DusmSvc;EapHost;EFS;embeddedmode;EventLog;EventSystem;Fax;fdPHost;FDResPub;fhsvc;Font" +
                        "Cache;FontCache3.0.0.0;FrameServer;ftpsvc;GraphicsPerfSvc;hidserv;hns;HomeGroupListener;HomeGroupProvider;HvHost;" +
                        "icssvc;IKEEXT;InstallService;iphlpsvc;IpxlatCfgSvc;irmon;KeyIso;KtmRm;LanmanServer;LanmanWorkstation;lfsvc;Licens" + 
                        "eManager;lltdsvc;lmhosts;LPDSVC;LxssManager;MapsBroker;MessagingService_{0};MSDTC;MSiSCSI;MsKeyboardFilter;MSMQ;M" +
                        "SMQTriggers;NaturalAuthentication;NcaSVC;NcbService;NcdAutoSetup;Netlogon;Netman;NetMsmqActivator;NetPipeActivato" +
                        "r;netprofm;NetSetupSvc;NetTcpActivator;NetTcpPortSharing;NlaSvc;nsi;OneSyncSvc_{0};p2pimsvc;p2psvc;PcaSvc;PeerDis" +
                        "tSvc;PerfHost;PhoneSvc;pla;PlugPlay;PNRPAutoReg;PNRPsvc;PolicyAgent;Power;PrintNotify;PrintWorkflowUserSvc_{0};Pr" +
                        "ofSvc;PushToInstall;QWAVE;RasAuto;RasMan;RemoteAccess;RemoteRegistry;RetailDemo;RmSvc;RpcLocator;SamSs;SCardSvr;S" +
                        "cDeviceEnum;SCPolicySvc;SDRSVC;seclogon;SEMgrSvc;SENS;Sense;SensorDataService;SensorService;SensrSvc;SessionEnv;S" + 
                        "grmBroker;SharedAccess;SharedRealitySvc;ShellHWDetection;shpamsvc;smphost;SmsRouter;SNMPTRAP;spectrum;Spooler;SSD" + 
                        "PSRV;ssh-agent;SstpSvc;StiSvc;StorSvc;svsvc;swprv;SysMain;TabletInputService;TapiSrv;TermService;Themes;TieringEn" +
                        "gineService;TimeBroker;TokenBroker;TrkWks;TrustedInstaller;tzautoupdate;UevAgentService;UI0Detect;UmRdpService;up" + 
                        "nphost;UserManager;UsoSvc;VaultSvc;vds;vmcompute;vmicguestinterface;vmicheartbeat;vmickvpexchange;vmicrdv;vmicshu" +
                        "tdown;vmictimesync;vmicvmsession;vmicvss;vmms;VSS;W32Time;W3LOGSVC;W3SVC;WaaSMedicSvc;WalletService;WarpJITSvc;WA" +
                        "S;wbengine;WbioSrvc;Wcmsvc;wcncsvc;WdiServiceHost;WdiSystemHost;WebClient;Wecsvc;WEPHOSTSVC;wercplsupport;WerSvc;" + 
                        "WFDSConSvc;WiaRpc;WinHttpAutoProxySvc;Winmgmt;WinRM;wisvc;WlanSvc;wlidsvc;wlpasvc;wmiApSrv;WMPNetworkSvc;WMSVC;wo" + 
                        "rkfolderssvc;WpcMonSvc;WPDBusEnum;WpnService;WpnUserService_{0};wscsvc;WSearch;wuauserv;wudfsvc;WwanSvc;xbgm;XblA" + 
                        "uthManager;XblGameSave;XboxGipSvc;XboxNetApiSvc"))
            Masks   = (("0;1;2;3;3;4;3;5;3;6;2;2;3;3;3;2;7;3;3;0;0;0;0;3;3;4;7;2;0;3;2;8;3;3;3;3;3;2;3;3;2;3;1;2;7;3;2;3;3;3;2;3;3;3;2;2" + 
                        ";1;3;3;3;2;3;1;2;3;3;6;3;3;1;1;3;3;9;0;1;3;3;2;2;1;3;3;3;2;3;1;0;3;3;1;11;2;2;0;3;3;0;0;3;2;2;3;3;2;1;2;2;7;3;3;" + 
                        "2;8;3;1;3;3;3;3;3;2;3;3;2;3;3;3;3;12;12;1;3;1;2;12;1;1;3;3;1;2;6;13;13;13;0;7;1;3;2;12;3;1;1;3;2;3;3;3;3;3;3;3;2" + 
                        ";13;3;0;2;3;3;3;2;3;12;5;3;0;3;2;3;3;3;6;1;1;1;1;1;1;1;1;14;3;3;3;2;3;3;3;3;3;3;2;0;3;3;0;3;3;3;3;13;3;3;2;1;1;1" + 
                        "5;3;3;3;1;3;1;1;3;2;2;7;7;3;3;1;3;1;1;3;1").Split(";"))
            Values   = (("2,2,2,2,2,2,1,1,2,2;2,2,2,2,1,1,1,1,1,1;3,0,3,0,3,0,3,0,3,0;2,0,2,0,2,0,2,0,2,0;0,0,2,2,2,2,1,1,2,2;0,0,1,0,1,0" + 
                        ",1,0,1,0;0,0,2,0,2,0,2,0,2,0;4,0,4,0,4,0,4,0,4,0;0,0,2,2,1,1,1,1,1,1;3,3,3,3,3,3,1,1,3,3;4,4,4,4,1,1,1,1,1,1;0,0" + 
                        ",0,0,0,0,0,0,0,0;1,0,1,0,1,0,1,0,1,0;2,2,2,2,1,1,1,1,2,2;0,0,3,0,3,0,3,0,3,0;3,3,3,3,2,2,2,2,3,3").Split(";"))
        }
        [Hashtable]  $Template
        [Object[]]     $Output
        FEServices()
        {
            $This.QMark                = (Get-Service | ? ServiceType -eq 224 )[0].Name.Split('_')[-1]
            $This.Config.Names         = $This.Config.Names -f $This.QMark -Split ";"
            $This.Template             = @{ }

            ForEach ( $I in 0..( $This.Config.Names.Count - 1 ) )
            {
                $This.Template.Add($This.Config.Names[$I],$This.Config.Values[$This.Config.Masks[$I]])
            }

            $This.Output               = @( )

            Get-WMIObject -Class Win32_Service | Sort-Object Name | % {

                $Item                  = [FEService]::New($This.Output.Count,$_)
                If ($This.Template[$Item.Name])
                {
                    $Item.Scope        = 1
                    $Item.Profile      = $This.Template[$Item.Name] -Split ","
                }
                Else
                {
                    $Item.Scope        = 0
                    $Item.Profile      = @(0) * 10
                }
                $This.Output          += $Item
            }
        }
        SetProfile([Int32]$Slot)
        {
            ForEach ( $I in 0..( $This.Output.Count - 1 ) )
            {
                $This.Output[$I].Slot = $This.Output[$I].Profile[$Slot]
            }
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                State { 7 } Name { 32 } DisplayName { 45 }
            }
            If ($String.Length -gt $Buffer)
            {
                $String = $String.Substring(0,($Buffer-3)) + "..."
                Return $String
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @( 
            "Status  Name                             DisplayName                                  "
            "------  ----                             -----------                                  "
            ForEach ($Item in $This.Output)
            {
                $This.Buffer("State",$Item.State),
                $This.Buffer("Name",$Item.Name),
                $This.Buffer("DisplayName",$Item.DisplayName) -join ' '
            })
        }
    }

    $Object = [FeServices]::New()
    Switch($PSCmdLet.ParameterSetName)
    {
        0 { $Object.Output }
        1 { $Object.ToString() }
    }
}

