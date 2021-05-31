Class _Info
{
    [Object]          $OS = (Get-CimInstance -ClassName Win32_OperatingSystem)
    [Object]          $CS = (Get-CimInstance -ClassName Win32_ComputerSystem)
    [Object]         $Env = (Get-ChildItem Env:\)

    [Hashtable]     $Hash = @{ 

        Edition           = ("10240,Threshold 1,Release To Manufacturing;10586,Threshold 2,November {1};14393,{0} 1,Anniversary {1};15063," + 
                             "{0} 2,{2} {1};16299,{0} 3,Fall {2} {1};17134,{0} 4,April 2018 {1};17763,{0} 5,October 2018 {1};18362,19H1,Ma" + 
                             "y 2019 {1};18363,19H2,November 2019 {1};19041,20H1,May 2020 {1};19042,20H2,October 2020 {1}") -f 'Redstone',
                             'Update','Creators' -Split ";"

        Chassis           =  "N/A Desktop Mobile/Laptop Workstation Server Server Appliance Server Maximum" -Split " "
        SKU               = ("Undefined,Ultimate {0},Home Basic {0},Home Premium {0},{3} {0},Home Basic N {0},Business {0},Standard {2} {0" + 
                             "},Datacenter {2} {0},Small Business {2} {0},{3} {2} {0},Starter {0},Datacenter {2} Core {0},Standard {2} Cor" +
                             "e {0},{3} {2} Core {0},{3} {2} IA64 {0},Business N {0},Web {2} {0},Cluster {2} {0},Home {2} {0},Storage Expr" + 
                             "ess {2} {0},Storage Standard {2} {0},Storage Workgroup {2} {0},Storage {3} {2} {0},{2} For Small Business {0" + 
                             "},Small Business {2} Premium {0},TBD,{1} {3},{1} Ultimate,Web {2} Core,-,-,-,{2} Foundation,{1} Home {2},-,{" + 
                             "1} {2} Standard No Hyper-V Full,{1} {2} Datacenter No Hyper-V Full,{1} {2} {3} No Hyper-V Full,{1} {2} Datac" + 
                             "enter No Hyper-V Core,{1} {2} Standard No Hyper-V Core,{1} {2} {3} No Hyper-V Core,Microsoft Hyper-V {2},Sto" + 
                             "rage {2} Express Core,Storage {2} Standard Core,{2} Workgroup Core,Storage {2} {3} Core,Starter N,Profession" + 
                             "al,Professional N,{1} Small Business {2} 2011 Essentials,-,-,-,-,-,-,-,-,-,-,-,-,Small Business {2} Premium " + 
                             "Core,{1} {2} Hyper Core V,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,-,--,-,-,{1} Thin PC,-,{1} Embedded Industry,-,-" +
                             ",-,-,-,-,-,{1} RT,-,-,Single Language N,{1} Home,-,{1} Professional with Media Center,{1} Mobile,-,-,-,-,-,-" + 
                             ",-,-,-,-,-,-,-,{1} Embedded Handheld,-,-,-,-,{1} IoT Core") -f "Edition","Windows","Server","Enterprise" -Split ","
    }

    [Object]      $VTable = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion')
    [String]     $Caption
    [Object]     $Version
    [String]       $Build
    [Int32]    $ReleaseID
    [String]    $CodeName
    [String]        $Name
    [String]         $SKU
    [String]     $Chassis

    _Info()
    {
        $This.Version     = (Get-Host).Version.ToString()
        $This.ReleaseID   = $This.VTable.ReleaseID
        $ID               = Switch ($This.ReleaseID) 
        { 
            1507 {0} 1511 {1} 1607 {2} 1703 {3} 1709 {4} 1803 {5} 
            1809 {6} 1903 {7} 1909 {8} 2004 {9} 2009 {10} 
        }

        $This.Build, $This.CodeName, $This.Name = $This.Hash.Edition[$ID].Split(",")

        $This.Caption            = $This.OS.Caption
        $This.SKU                = $This.Hash.SKU[$This.OS.OperatingSystemSKU]
        $This.Chassis            = $This.Hash.Chassis[$This.CS.PCSystemType]
    }
}
