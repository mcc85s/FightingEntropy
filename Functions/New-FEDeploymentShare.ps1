Function New-FEDeploymentShare # based off of https://github.com/mcc85sx/FightingEntropy/blob/master/FEDeploymentShare/FEDeploymentShare.ps1
{
    # Load Assemblies
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window 
{
    [DllImport("user32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out WindowPosition lpRect);

    [DllImport("user32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);

    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr handle, int state);
}
public struct WindowPosition
{
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
"@

    # Check for server operating system
    If ( (Get-CimInstance Win32_OperatingSystem).Caption -notmatch "Server" )
    {
        Throw "Must use Windows Server operating system"
    }

    If ($PSVersionTable.PSEdition -eq "Core")
    {
        Throw "Must use PowerShell v5 for MDT"
    }

    Class States
    {
        Static [Hashtable] $List            = @{

            "Alabama"                       = "AL" ; "Alaska"                        = "AK" ;
            "Arizona"                       = "AZ" ; "Arkansas"                      = "AR" ;
            "California"                    = "CA" ; "Colorado"                      = "CO" ;
            "Connecticut"                   = "CT" ; "Delaware"                      = "DE" ;
            "Florida"                       = "FL" ; "Georgia"                       = "GA" ;
            "Hawaii"                        = "HI" ; "Idaho"                         = "ID" ;
            "Illinois"                      = "IL" ; "Indiana"                       = "IN" ;
            "Iowa"                          = "IA" ; "Kansas"                        = "KS" ;
            "Kentucky"                      = "KY" ; "Louisiana"                     = "LA" ;
            "Maine"                         = "ME" ; "Maryland"                      = "MD" ;
            "Massachusetts"                 = "MA" ; "Michigan"                      = "MI" ;
            "Minnesota"                     = "MN" ; "Mississippi"                   = "MS" ;
            "Missouri"                      = "MO" ; "Montana"                       = "MT" ;
            "Nebraska"                      = "NE" ; "Nevada"                        = "NV" ;
            "New Hampshire"                 = "NH" ; "New Jersey"                    = "NJ" ;
            "New Mexico"                    = "NM" ; "New York"                      = "NY" ;
            "North Carolina"                = "NC" ; "North Dakota"                  = "ND" ;
            "Ohio"                          = "OH" ; "Oklahoma"                      = "OK" ;
            "Oregon"                        = "OR" ; "Pennsylvania"                  = "PA" ;
            "Rhode Island"                  = "RI" ; "South Carolina"                = "SC" ;
            "South Dakota"                  = "SD" ; "Tennessee"                     = "TN" ;
            "Texas"                         = "TX" ; "Utah"                          = "UT" ;
            "Vermont"                       = "VT" ; "Virginia"                      = "VA" ;
            "Washington"                    = "WA" ; "West Virginia"                 = "WV" ;
            "Wisconsin"                     = "WI" ; "Wyoming"                       = "WY" ;
            "American Samoa"                = "AS" ; "District of Columbia"          = "DC" ;
            "Guam"                          = "GU" ; "Marshall Islands"              = "MH" ;
            "Northern Mariana Island"       = "MP" ; "Puerto Rico"                   = "PR" ;
            "Virgin Islands"                = "VI" ; "Armed Forces Africa"           = "AE" ;
            "Armed Forces Americas"         = "AA" ; "Armed Forces Canada"           = "AE" ;
            "Armed Forces Europe"           = "AE" ; "Armed Forces Middle East"      = "AE" ;
            "Armed Forces Pacific"          = "AP" ;
        }
        Static [String] Name([String]$Code)
        {
            Return @( [States]::List | % GetEnumerator | ? Value -match $Code | % Name )
        }
        Static [String] Code([String]$State)
        {
            Return @( [States]::List | % GetEnumerator | ? Name -eq $State | % Value )
        }
        States(){}
    }

    Class ZipEntry
    {
        [String]       $Zip
        [String]      $Type
        [String]      $Name
        [String]     $State
        [String]   $Country
        [Float]       $Long
        [Float]        $Lat
        ZipEntry([String]$Line)
        {
            $String         = $Line -Split "`t"
            
            $This.Zip       = $String[0]
            $This.Type      = @("UNIQUE","STANDARD","PO_BOX","MILITARY")[$String[1]]
            $This.Name      = $String[2]
            $This.State     = $String[3]
            $This.Country   = $String[4]
            $This.Long      = $String[5]
            $This.Lat       = $String[6]
        }
    }

    Class ZipStack
    {
        [String]    $Path
        [Object] $Content
        [Object]   $Stack
        ZipStack([String]$Path)
        {
            $This.Path    = $Path
            $This.Content = Invoke-RestMethod $Path
            $This.Stack   = ForEach ( $Line in $This.Content.Split("`n") )
            {
                $Line.Substring(0,5)
            }
        }
        [Object[]] ZipTown([String]$Zip)
        {
            $Value = [Regex]::Matches($This.Content,"($Zip)+.+").Value 
            
            If ( $Value -eq $Null )
            {
                Throw "No result found"
            }

            Else
            {
                $Return = @( )

                ForEach ($Item in $Value)
                {
                    $Return += [ZipEntry]$Item    
                }

                Return $Return
            }   
        }
        [Object[]] TownZip([String]$Town)
        {
            $Value = [Regex]::Matches($This.Content,"\d{5}\t\d{1}\t($Town)+.+").Value 
            
            If (!$Value)
            {
                Throw "No result found"
            }

            Else
            {
                $Return = @( )

                ForEach ($Item in $Value)
                {
                    $Return += [ZipEntry]$Item    
                }

                Return $Return
            }  
        }
    }
    
    Class Scope
    {
        [String]  $Name
        [String]$Network
        Hidden [UInt32[]]$Network_
        [UInt32] $Prefix
        [String]$Netmask
        Hidden [UInt32[]]$Netmask_
        [UInt32]$HostCount
        [Object]$HostObject
        [String]$Start
        [String]$End
        [String]$Range
        [String]$Broadcast
        [Object] GetSubnetMask([UInt32]$Int)
        {
            $Bin   = @(0..($Int-1) | % {1};$Int..31| % {0})
            $Hash  = @{ }
            $Mask  = @{ }
            0..3 | % {

                $Hash.Add($_,$Bin[($_*8)..(($_*8) + 8)])
                $Mask.Add($_,(@(ForEach ($I in 0..7 )
                { 
                    Switch($Hash[$_][$I])
                    {
                        0 { 0 }
                        1 { (128,64,32,16,8,4,2,1)[$I] }
                    }
                }) -join "+" | Invoke-Expression ))
            }

            Return @( $Mask[0..3] -join '.' )
        }
        Scope([String]$Prefix)
        {
            $This.Name     = $Prefix
            $Object        = $Prefix.Split("/")
            $This.Network  = $Object[0]
            $This.Prefix   = $Object[1]
            $This.Netmask  = $This.GetSubnetMask($Object[1])
            $This.Remain()
        }
        Scope([String]$Network,[String]$Prefix,[String]$Netmask)
        {
            $This.Name       = "$Network/$Prefix"
            $This.Network    = $Network
            $This.Prefix     = $Prefix
            $This.Netmask    = $Netmask
            $This.Remain()
        }
        Remain()
        {
            $This.Network_   = $This.Network -Split "\."
            $This.Netmask_   = $This.Netmask -Split "\."

            $WC             = ForEach ( $X in 0..3 )
            { 
                Switch($This.Netmask_[$X])
                {
                    255 { 1 } 0 { 256 } Default { 256 - $This.Netmask_[$X] }
                }
            }

            $This.HostCount = (Invoke-Expression ($WC -join "*")) - 2
            $SRange = @{}

            ForEach ( $X in 0..3 )
            {
                $SRange.Add($X,@(Switch($WC[$X])
                {
                    1 { $This.Network_[$X] }
                    Default 
                    {
                        "{0}..{1}" -f $This.Network_[$X],(([UInt32]$This.Network_[$X] + (256-$This.Netmask_[$X]))-1)
                    }
                    256 { "0..255" }
                }))
            }

            $This.Range      = @( 0..3 | % { $SRange[$_] }) -join '/'

            $XRange          = @{ }

            ForEach ( $0 in $SRange[0] | Invoke-Expression )
            {
                ForEach ( $1 in $SRange[1] | Invoke-Expression )
                {
                    ForEach ( $2 in $SRange[2] | Invoke-Expression )
                    {
                        ForEach ( $3 in $SRange[3] | Invoke-Expression )
                        {
                            $XRange.Add($XRange.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.HostObject = @( 0..($XRange.Count-1) | % { $XRange[$_] } )
            $This.Start     = $This.HostObject[1]
            $This.End       = $This.HostObject[-2]
            $This.Broadcast = $This.HostObject[-1]
        }
        [String] ToString()
        {
            Return @($This.Network)
        }
    }
    
    Class Network
    {
        [String]$Network
        [String]$Prefix
        [String]$Netmask
        [Object[]]$Aggregate
        Network([String]$Network)
        {
            $Hash           = @{ }
            $NetworkHash    = @{ }
            $NetmaskHash    = @{ }
            $HostHash       = @{ }

            $This.Network   = $Network.Split("/")[0]
            $This.Prefix    = $Network.Split("/")[1]

            $NWSplit        = $This.Network.Split(".")
            $BinStr         = "{0}{1}" -f ("1" * $this.Prefix),("0" * (32-$This.Prefix))

            ForEach ( $I in 0..3 )
            {
                $Hash.Add($I,$BinStr.Substring(($I*8),8).ToCharArray())
            }

            ForEach ( $I in 0..3 )
            {
                Switch([UInt32]("0" -in $Hash[$I]))
                {
                    0
                    {
                        $NetworkHash.Add($I,$NWSplit[$I])
                        $NetmaskHash.Add($I,255)
                        $HostHash.Add($I,1)
                    }

                    1
                    {
                        $NwCt = ($Hash[$I] | ? { $_ -eq "1" }).Count
                        $HostHash.Add($I,(256,128,64,32,16,8,4,2,1)[$NwCt])

                        If ( $NwCt -eq 0)
                        {
                            $NetworkHash.Add($I,0)
                            $NetmaskHash.Add($I,0)
                        }

                        Else
                        {
                            $NetworkHash.Add($I,(128,64,32,16,8,4,2,1)[$NwCt-1])
                            $NetmaskHash.Add($I,(128,192,224,240,248,252,254,255)[$NwCt-1])
                        }
                    }
                }
            }

            $This.Netmask = $NetmaskHash[0..3] -join '.'

            $Hosts   = @{ }

            ForEach ( $I in 0..3 )
            {
                Switch ($HostHash[$I])
                {
                    1
                    {
                        $Hosts.Add($I,$NetworkHash[$I])
                    }

                    256
                    {
                        $Hosts.Add($I,0)
                    }

                    Default
                    {
                        $Hosts.Add($I,@(0..255 | ? { $_ % $HostHash[$I] -eq 0 }))
                    }
                }
            }

            $Wildcard = $HostHash[0..3] -join ','

            $Contain = @{ }

            ForEach ( $0 in $Hosts[0] )
            {
                ForEach ( $1 in $Hosts[1] )
                {
                    ForEach ( $2 in $Hosts[2] )
                    {
                        ForEach ( $3 in $Hosts[3] )
                        {
                            $Contain.Add($Contain.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.Aggregate = 0..( $Contain.Count - 1 ) | % { [Scope]::New($Contain[$_],$This.Prefix,$This.Netmask) }
        }
    }

    Class DcTopography
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]          $SiteLink
        [String]          $SiteName
        [UInt32]            $Exists
        [Object] $DistinguishedName
        DcTopography([Object]$SiteList,[Object]$SM)
        {
            $This.Name     = $SM.Sitename
            $This.Sitelink = $SM.Sitelink
            $This.Sitename = $SM.Sitename
            $Tmp           = $SiteList | ? Name -match $SM.SiteLink
            If ($Tmp)
            {
                $This.Exists = 1
                $This.DistinguishedName = $Tmp.DistinguishedName
            }
            Else
            {
                $This.Exists = 0
                $This.DistinguishedName = $Null
            }
        }
    }

    Class NwTopography
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]           $Network
        [UInt32]            $Exists
        [Object] $DistinguishedName
        NwTopography([Object]$SubnetList,[Object]$NW)
        {
            $This.Name     = $Nw.Name
            $This.Network  = $Nw.Network
            $Tmp           = $SubnetList | ? Name -match $Nw.Name
            If ($Tmp)
            {
                $This.Exists = 1
                $This.DistinguishedName = $Tmp.DistinguishedName
            }
            Else
            {
                $This.Exists = 0
                $This.DistinguishedName = $Null
            }
        }
    }

    Class GwTopography
    {
        Hidden [String[]] $Enum = "True","False"
        [String]              $Name
        [String]           $Network
        [String]          $SiteName
        [UInt32]            $Exists
        [Object] $DistinguishedName
        GwTopography([Object]$OuList,[Object]$Gw)
        {
            $This.Name     = $Gw.Name
            $This.Network  = $Gw.Network
            $This.Sitename = $Gw.Sitename
            $Tmp           = $OuList | ? Name -match $Gw.Name
            If ($Tmp)
            {
                $This.Exists = 1
                $This.DistinguishedName = $Tmp.DistinguishedName
            }
            Else
            {
                $This.Exists = 0
                $This.DistinguishedName = $Null
            }
        }
    }

    Class GwFile
    {
        [String]$Path
        [String]$Name
        [UInt32]$Index
        [String]$Slot
        [Object]$Content
        GwFile([Object]$File)
        {
            $This.Path    = $File.FullName
            $This.Slot    = [Regex]::Matches($File.Name,"^\(\d+\)").Value
            $This.Name    = $File.Name.Replace($This.Slot,"").Replace(".txt","")
            $This.Index   = $This.Slot.Replace("(","").Replace(")","")
            $This.Content = Get-Content $File.FullName | ConvertFrom-Json
        }
    }

    Class GwFiles
    {
        [Object] $Path
        [Object] $Items
        [Object] $Files
        GwFiles([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            $This.Path  = $Path
            $This.Items = Get-ChildItem $Path *.txt 
            $This.Files = @( $This.Items | % { [GwFile]::New($_) } )
        }
    }
    
    Class Certificate
    {
        Hidden[String] $ExternalIP
        Hidden[Object]       $Ping
        [String]     $Organization
        [String]       $CommonName
        [String]         $Location
        [String]           $Region
        [String]          $Country
        [Int32]            $Postal
        [String]         $TimeZone
        [String]         $SiteName
        [String]         $SiteLink
        Certificate(
        [String]     $Organization ,
        [String]       $CommonName )
        {
            $This.Organization     = $Organization
            $This.CommonName       = $CommonName  
            $This.Prime()
        }
        Certificate([Object]$Sitemap)
        {
            $This.Organization     = $Sitemap.Organization
            $This.CommonName       = $Sitemap.CommonName
            $This.Prime()
        }
        Prime()
        {
            # These (2) lines are from Chrissie Lamaire's script
            # https://gallery.technet.microsoft.com/scriptcenter/Get-ExternalPublic-IP-c1b601bb

            $This.ExternalIP       = Invoke-RestMethod http://ifconfig.me/ip 
            $This.Ping             = Invoke-RestMethod http://ipinfo.io/$($This.ExternalIP)

            $This.Location         = $This.Ping.City
            $This.Region           = $This.Ping.Region
            $This.Country          = $This.Ping.Country
            $This.Postal           = $This.Ping.Postal
            $This.TimeZone         = $This.Ping.TimeZone

            $This.GetSiteLink()
        }
        GetSiteLink()
        {
            $Return                = @{ }

            # City
            $Return.Add(0,@(Switch -Regex ($This.Location)
            {
                "\s"
                {
                    ( $This.Location | % Split " " | % { $_[0] } ) -join ''
                }

                Default
                {
                    $This.Location[0,1] -join ''
                }
    
            }).ToUpper())

            # State
            $Return.Add(1,[States]::List[$This.Region])

            # Country
            $Return.Add(2,$This.Country)

            # Zip
            $Return.Add(3,$This.Postal)

            $This.SiteLink = ($Return[0..3] -join "-").ToUpper()
            $This.SiteName = ("{0}.{1}" -f ($Return[0..3] -join "-"),$This.CommonName).ToLower()
        }
    }

    Function KeyEntry
    {
        [CmdLetBinding()]
        Param(
        [Parameter(Mandatory)][Object]$KB,
        [Parameter(Mandatory)][Object]$Object)
        Class KeyEntry
        {
            Static [Char[]] $Capital  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
            Static [Char[]]   $Lower  = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
            Static [Char[]] $Special  = ")!@#$%^&*(:+<_>?~{|}`"".ToCharArray()
            Static [Object]    $Keys  = @{
    
                " " =  32; [Char]706 =  37; [Char]708 =  38; [char]707 =  39; [Char]709 =  40; 
                "0" =  48; "1" =  49; "2" =  50; "3" =  51; "4" =  52; "5" =  53; "6" =  54; 
                "7" =  55; "8" =  56; "9" =  57; "a" =  65; "b" =  66; "c" =  67; 
                "d" =  68; "e" =  69; "f" =  70; "g" =  71; "h" =  72; "i" =  73; 
                "j" =  74; "k" =  75; "l" =  76; "m" =  77; "n" =  78; "o" =  79; 
                "p" =  80; "q" =  81; "r" =  82; "s" =  83; "t" =  84; "u" =  85; 
                "v" =  86; "w" =  87; "x" =  88; "y" =  89; "z" =  90; ";" = 186; 
                "=" = 187; "," = 188; "-" = 189; "." = 190; "/" = 191; '`' = 192; 
                "[" = 219; "\" = 220; "]" = 221; "'" = 222;
            }
            Static [Object]     $SKey = @{ 
    
                "A" =  65; "B" =  66; "C" =  67; "D" =  68; "E" =  69; "F" =  70; 
                "G" =  71; "H" =  72; "I" =  73; "J" =  74; "K" =  75; "L" =  76; 
                "M" =  77; "N" =  78; "O" =  79; "P" =  80; "Q" =  81; "R" =  82; 
                "S" =  83; "T" =  84; "U" =  85; "V" =  86; "W" =  87; "X" =  88;
                "Y" =  89; "Z" =  90; ")" =  48; "!" =  49; "@" =  50; "#" =  51; 
                "$" =  52; "%" =  53; "^" =  54; "&" =  55; "*" =  56; "(" =  57; 
                ":" = 186; "+" = 187; "<" = 188; "_" = 189; ">" = 190; "?" = 191; 
                "~" = 192; "{" = 219; "|" = 220; "}" = 221; '"' = 222;
            }
        }
        If ( $Object.Length -gt 1 )
        {
            $Object = $Object.ToCharArray()
        }
        ForEach ( $Key in $Object )
        {
            If ($Key -cin @([KeyEntry]::Special + [KeyEntry]::Capital))
            {
                $KB.PressKey(16) | Out-Null
                $KB.TypeKey([KeyEntry]::SKey["$Key"]) | Out-Null
                $KB.ReleaseKey(16) | Out-Null
            }
            Else
            {
                $KB.TypeKey([KeyEntry]::Keys["$Key"]) | Out-Null
            }

            Start-Sleep -Milliseconds 50
        }
    }

    Class VMGateway
    {
        Hidden [Object]$Item
        [Object]$Name
        [Object]$MemoryStartupBytes
        [Object]$Path
        [Object]$NewVHDPath
        [Object]$NewVHDSizeBytes
        [Object]$Generation
        [Object]$SwitchName
        VMGateway([Object]$Item,[Object]$Mem,[Object]$HD,[UInt32]$Gen,[String]$Switch)
        {
            $This.Item               = $Item
            $This.Name               = $Item.Name
            $This.MemoryStartupBytes = $Mem
            $This.Path               = "{0}\$($Item.Name).vmx"
            $This.NewVhdPath         = "{0}\$($Item.Name).vhdx"
            $This.NewVhdSizeBytes    = $HD
            $This.Generation         = $Gen
            $This.SwitchName         = $Switch
        }
    }
    
    Class VMServer
    {
        Hidden [Object]$Item
        [Object]$Name
        [Object]$MemoryStartupBytes
        [Object]$Path
        [Object]$NewVHDPath
        [Object]$NewVHDSizeBytes
        [Object]$Generation
        [Object]$SwitchName
        VMServer([Object]$Item,[Object]$Mem,[Object]$HD,[UInt32]$Gen,[String]$Switch)
        {
            $This.Item               = $Item
            $This.Name               = $Item.Name
            $This.MemoryStartupBytes = $Mem
            $This.Path               = "{0}\$($Item.Name).vmx"
            $This.NewVhdPath         = "{0}\$($Item.Name).vhdx"
            $This.NewVhdSizeBytes    = $HD
            $This.Generation         = $Gen
            $This.SwitchName         = $Switch
        }
        New([Object]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            ElseIf (Get-VM -Name $This.Name -EA 0)
            {
                Write-Host "VM exists..."
                If (Get-VM -Name $This.Name | ? Status -ne Off)
                {
                    $This.Stop()
                }

                $This.Remove()
            }

            $This.Path             = $This.Path -f $Path
            $This.NewVhdPath       = $This.NewVhdPath -f $Path

            If (Test-Path $This.Path)
            {
                Remove-Item $This.Path -Recurse -Confirm:$False -Verbose
            }

            If (Test-Path $This.NewVhdPath)
            {
                Remove-Item $This.NewVhdPath -Recurse -Confirm:$False -Verbose
            }

            $Object                = @{

                Name               = $This.Name
                MemoryStartupBytes = $This.MemoryStartupBytes
                Path               = $This.Path
                NewVhdPath         = $This.NewVhdPath
                NewVhdSizeBytes    = $This.NewVhdSizebytes
                Generation         = $This.Generation
                SwitchName         = $This.SwitchName
            }

            New-VM @Object -Verbose | Add-VMDVDDrive -Verbose
            Set-VMProcessor -VMName $This.Name -Count 2 -Verbose
        }
        Start()
        {
            Get-VM -Name $This.Name | ? State -eq Off | Start-VM -Verbose
        }
        Remove()
        {
            Get-VM -Name $This.Name | Remove-VM -Force -Confirm:$False -Verbose
        }
        Stop()
        {
            Get-VM -Name $This.Name | ? State -ne Off | Stop-VM -Verbose -Force
        }
        LoadISO([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid ISO path"
            }

            Else
            {
                Get-VM -Name $This.Name | % { Set-VMDVDDrive -VMName $_.Name -Path $Path -Verbose }
            }
        }
    }

    Class VMSilo
    {
        [Object] $Name
        [Object] $VMHost
        [Object] $Switch
        [Object] $Internal
        [Object] $External
        [Object] $Gateway
        [Object] $Server
        [Object] $VMC
        VMSilo([String]$Name,[Object[]]$Gateway)
        {
            $This.Name     = $Name
            $This.VMHost   = Get-VMHost
            $This.Switch   = Get-VMSwitch
            $This.Internal = $This.Switch | ? SwitchType -eq Private
            $This.External = $This.Switch | ? SwitchType -eq External
            $This.Gateway  = ForEach ( $X in 0..($Gateway.Count - 1))
            {        
                $Item            = [VMGateway]::New($Gateway[$X],1024MB,20GB,1,$This.External.Name)
                $Item.Path       = $Item.Path       -f $This.VMHost.VirtualMachinePath
                $Item.NewVhdPath = $Item.NewVhdPath -f $This.VMHost.VirtualHardDiskPath
                $Item
            }
            $This.VMC = @( )
        }
        Clear()
        {
            $VMList        = Get-VM | % Name

            ForEach ( $Item in $This.Gateway)
            {
                If ($Item.Name -in $VMList)
                {
                    Stop-VM -Name $Item.Name -Force -Verbose
                    Remove-VM -Name $Item.Name -Force -Verbose
                }
            }

            ForEach ( $Item in $This.Gateway)
            {
                If (Test-Path $Item.Path)
                {
                    Remove-Item $Item.Path -Recurse -Force -Verbose
                }

                If (Test-Path $Item.NewVhdPath)
                {
                    Remove-Item $Item.NewVhdPath -Recurse -Force -Verbose
                }
            }
        }
        Create([Object]$ISOPath)
        {
            ForEach ($X in 0..($This.Gateway.Count - 1))
            {
                $Item                      = $This.Gateway[$X] | % { 
                    
                    @{
                        Name               = $_.Name
                        MemoryStartupBytes = $_.MemoryStartupBytes
                        Path               = $_.Path
                        NewVhdPath         = $_.NewVhdPath
                        NewVhdSizeBytes    = $_.NewVhdSizeBytes
                        Generation         = $_.Generation
                        SwitchName         = $_.SwitchName
                    }
                }
                
                New-VM @Item -Verbose
                Add-VMNetworkAdapter -VMName $Item.Name -SwitchName $This.Internal.Name -Verbose
                Switch -Regex ($IsoPath.GetType().Name)
                {
                    "\[\]"
                    {
                        Set-VMDVDDrive -VMName $Item.Name -Path $IsoPath[($X % $IsoPath.Count)] -Verbose
                    }
                    Default
                    {
                        Set-VMDVDDrive -VMName $Item.Name -Path $ISOPath -Verbose
                    }
                }
                $Mac = $Null
                $ID  = $Item.Name 
                Start-VM -Name $ID
                Do
                {
                    Start-Sleep 1
                    $Item = Get-VM -Name $ID
                    $Mac  = $Item.NetworkAdapters | ? Switchname -eq $This.External.Name | % MacAddress
                }
                Until($Mac -ne 000000000000)
                Stop-VM -Name $ID -Confirm:$False -Force
                $This.VMC += $Mac
            }
        }
    }

    Class Site
    {
        Hidden [Object] $Hash
        [String]$Name
        [String]$Location
        [String]$Region
        [String]$Country
        [String]$Postal
        [String]$TimeZone
        [String]$SiteLink
        [String]$SiteName
        [String]$Network
        [String]$Prefix
        [String]$Netmask
        [String]$Start
        [String]$End
        [String]$Range
        [String]$Broadcast
        Site([Object]$Domain,[Object]$Network)
        {
            $This.Hash      = @{ Domain = $Domain; Network = $Network }
            $This.Name      = $Domain.SiteLink
            $This.Location  = $Domain.Location
            $This.Region    = $Domain.Region
            $This.Country   = $Domain.Country
            $This.Postal    = $Domain.Postal
            $This.TimeZone  = $Domain.TimeZone
            $This.SiteLink  = $Domain.SiteLink
            $This.Sitename  = $Domain.Sitename
            $This.Network   = $Network.Network
            $This.Prefix    = $Network.Prefix
            $This.Netmask   = $Network.Netmask
            $This.Start     = $Network.Start
            $This.End       = $Network.End
            $This.Range     = $Network.Range
            $This.Broadcast = $Network.Broadcast
        }
    }
    
    Class WindowsImage
    {
        [Uint32] $Index
        [String] $Name
        [String] $Description
        Hidden [Float]   $FileSize
        [String] $Size
        WindowsImage([Object]$Image)
        {
            If (!$Image)
            {
                Throw "No image input"
            }

            $This.Index       = $Image.ImageIndex
            $This.Name        = $Image.ImageName
            $This.Description = $Image.ImageDescription
            $This.FileSize    = $Image.ImageSize/1GB
            $This.Size        = "{0:n3} GB" -f $This.FileSize 
        }
    }

    Class ImageQueue
    {
        [String]  $Name
        [String]  $FullName
        [String]  $Index
        [String]  $Description
        ImageQueue([String]$FullName,[String]$Index,[String]$Description)
        {
            If (!$FullName -or !$Index)
            {
                Throw "Invalid selection"
            }

            $This.Name          = $FullName | Split-Path -Leaf
            $This.FullName      = $FullName
            $This.Index         = $Index
            $This.Description   = $Description
        }
    }

    Class ImageIndex
    {
        Hidden [UInt32] $Rank
        Hidden [UInt32] $SourceIndex
        Hidden [String] $SourceImagePath
        Hidden [String] $Path
        Hidden [String] $DestinationImagePath
        Hidden [String] $DestinationName
        Hidden [Object] $Disk
        [Object] $Label
        [UInt32] $ImageIndex            = 1
        [String] $ImageName
        [String] $ImageDescription
        [String] $Version
        [String] $Architecture
        [String] $InstallationType
        ImageIndex([Object]$Iso)
        {
            $This.SourceIndex           = $Iso.SourceIndex
            $This.SourceImagePath       = $Iso.SourceImagePath
            $This.DestinationImagePath  = $Iso.DestinationImagePath
            $This.DestinationName       = $Iso.DestinationName
            $This.Disk                  = Get-DiskImage -ImagePath $This.SourceImagePath
        }
        Load([String]$Target)
        {
            Get-WindowsImage -ImagePath $This.Path -Index $This.SourceIndex | % {

                $This.ImageName         = $_.ImageName
                $This.ImageDescription  = $_.ImageDescription
                $This.Architecture      = Switch ([UInt32]($_.Architecture -eq 9)) { 0 { 86 } 1 { 64 } }
                $This.Version           = $_.Version
                $This.InstallationType  = $_.InstallationType.Split(" ")[0]
            }

            Switch($This.InstallationType)
            {
                Server
                {
                    $Year    = [Regex]::Matches($This.ImageName,"(\d{4})").Value
                    $Edition = Switch -Regex ($This.ImageName) { STANDARD { "Standard" } DATACENTER { "Datacenter" } }
                    $This.DestinationName = "Windows Server $Year $Edition (x64)"
                    $This.Label           = "{0}{1}" -f $(Switch -Regex ($This.ImageName){Standard{"SD"}Datacenter{"DC"}}),[Regex]::Matches($This.ImageName,"(\d{4})").Value
                }

                Client
                {
                    $This.DestinationName = "{0} (x{1})" -f $This.ImageName, $This.Architecture
                    $This.Label           = "10{0}{1}"   -f $(Switch -Regex ($This.ImageName) { Pro {"P"} Edu {"E"} Home {"H"} }),$This.Architecture
                }
            }

            $This.DestinationImagePath    = "{0}\({1}){2}\{2}.wim" -f $Target,$This.Rank,$This.Label

            $Folder                       = $This.DestinationImagePath | Split-Path -Parent

            If (!(Test-Path $Folder))
            {
                New-Item -Path $Folder -ItemType Directory -Verbose
            }
        }
    }
    
    Class ImageFile
    {
        [ValidateSet("Client","Server")]
        [String]        $Type
        [String]        $Name
        [String] $DisplayName
        [String]        $Path
        [UInt32[]]     $Index
        ImageFile([String]$Type,[String]$Path)
        {
            $This.Type  = $Type

            If ( ! ( Test-Path $Path ) )
            {
                Throw "Invalid Path"
            }

            $This.Name        = ($Path -Split "\\")[-1]
            $This.DisplayName = "($Type)($($This.Name))"
            $This.Path        = $Path
            $This.Index       = @( )
        }
        AddMap([UInt32[]]$Index)
        {
            ForEach ( $I in $Index )
            {
                $This.Index  += $I
            }
        }
    }

    Class ImageStore
    {
        [String]   $Source
        [String]   $Target
        [Object[]]  $Store
        [Object[]]   $Swap
        [Object[]] $Output
        ImageStore([String]$Source,[String]$Target)
        {
            If ( ! ( Test-Path $Source ) )
            {
                Throw "Invalid image base path"
            }

            If ( !(Test-Path $Target) )
            {
                New-Item -Path $Target -ItemType Directory -Verbose
            }

            $This.Source = $Source
            $This.Target = $Target
            $This.Store  = @( )
        }
        AddImage([String]$Type,[String]$Name)
        {
            $This.Store += [ImageFile]::New($Type,"$($This.Source)\$Name")
        }
        GetSwap()
        {
            $This.Swap = @( )
            $Ct        = 0

            ForEach ( $Image in $This.Store )
            {
                ForEach ( $Index in $Image.Index )
                {
                    $Iso                     = @{ 

                        SourceIndex          = $Index
                        SourceImagePath      = $Image.Path
                        DestinationImagePath = ("{0}\({1}){2}({3}).wim" -f $This.Target, $Ct, $Image.DisplayName, $Index)
                        DestinationName      = "{0}({1})" -f $Image.DisplayName,$Index
                    }

                    $Item                    = [ImageIndex]::New($Iso)
                    $Item.Rank               = $Ct
                    $This.Swap              += $Item
                    $Ct                     ++
                }
            }
        }
        GetOutput()
        {
            $Last = $Null

            ForEach ( $X in 0..( $This.Swap.Count - 1 ) )
            {
                $Image       = $This.Swap[$X]

                If ( $Last -ne $Null -and $Last -ne $Image.SourceImagePath )
                {
                    Write-Theme "Dismounting... $Last" 12,4,15,0
                    Dismount-DiskImage -ImagePath $Last -Verbose
                }

                If (!(Get-DiskImage -ImagePath $Image.SourceImagePath).Attached)
                {
                    Write-Theme ("Mounting [+] {0}" -f $Image.SourceImagePath) 14,6,15,0
                    Mount-DiskImage -ImagePath $Image.SourceImagePath
                }

                $Image.Path = "{0}:\sources\install.wim" -f (Get-DiskImage -ImagePath $Image.SourceImagePath | Get-Volume | % DriveLetter)

                $Image.Load($This.Target)

                $ISO                        = @{

                    SourceIndex             = $Image.SourceIndex
                    SourceImagePath         = $Image.Path
                    DestinationImagePath    = $Image.DestinationImagePath
                    DestinationName         = $Image.DestinationName
                }

                Write-Theme "Extracting [~] $($Iso.DestinationImagePath)" 11,7,15,0
                Export-WindowsImage @ISO
                Write-Theme "Extracted [+] $($Iso.DestinationName)" 10,10,15,0

                $Last                       = $Image.SourceImagePath
                $This.Output               += $Image
            }

            Dismount-DiskImage -ImagePath $Last
        }
    }
    
    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object]               $Node
        [Object]                 $IO
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 

                ($_-Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If ( !$Xaml )
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ( $I in 0..( $This.Names.Count - 1 ) )
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }
    
    Class DGList
    {
        [String]$Name
        [Object]$Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class Domain
    {
        [String] $Organization
        [String] $CommonName
        [String] $Location
        [String] $Region
        [String] $Country
        [String] $Postal
        [String] $TimeZone
        [String] $SiteLink
        [String] $SiteName
        Domain([Object]$Domain)
        {

        }
    }
    
    Class Sitemap
    {
        [String]$Organization
        [String]$CommonName
        [Object]$Sitemap
        Sitemap([String]$Organization,$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
            $This.Sitemap      = @( )
        }
    }
    
    Class Key
    {
        [String]     $NetworkPath
        [String]    $Organization
        [String]      $CommonName
        [String]      $Background
        [String]            $Logo
        [String]           $Phone
        [String]           $Hours
        [String]         $Website
        Key([Object]$Root)
        {
            $This.NetworkPath     = $Root[0]
            $This.Organization    = $Root[1]
            $This.CommonName      = $Root[2]
            $This.Background      = $Root[3]
            $This.Logo            = $Root[4]
            $This.Phone           = $Root[5]
            $This.Hours           = $Root[6]
            $This.Website         = $Root[7]
        }
    }

    Class WimFile
    {
        [UInt32] $Rank
        [Object] $Label
        [UInt32] $ImageIndex            = 1
        [String] $ImageName
        [String] $ImageDescription
        [String] $Version
        [String] $Architecture
        [String] $InstallationType
        [String] $SourceImagePath
        WimFile([UInt32]$Rank,[String]$Image)
        {
            If ( ! ( Test-Path $Image ) )
            {
                Throw "Invalid Path"
            }

            $This.SourceImagePath       = $Image
            $This.Rank                  = $Rank

            Get-WindowsImage -ImagePath $Image -Index 1 | % {
                
                $This.Version           = $_.Version
                $This.Architecture      = @(86,64)[$_.Architecture -eq 9]
                $This.InstallationType  = $_.InstallationType
                $This.ImageName         = $_.ImageName
                $This.Label             = Switch($This.InstallationType)
                {
                    Server
                    {
                        "{0}{1}" -f $(Switch -Regex ($This.ImageName){Standard{"SD"}Datacenter{"DC"}}),[Regex]::Matches($This.ImageName,"(\d{4})").Value
                    }

                    Client
                    {
                        "10{0}{1}" -f $(Switch -Regex ($This.ImageName) { Pro {"P"} Edu {"E"} Home {"H"} }),$This.Architecture
                    }
                }

                $This.ImageDescription  = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)][$($This.Label)]"

                If ( $This.ImageName -match "Evaluation" )
                {
                    $This.ImageName     = $This.ImageName -Replace "Evaluation \(Desktop Experience\) ",""
                }
            }
        }
    }

    Class BootImage
    {
        [Object] $Path
        [Object] $Name
        [Object] $Type
        [Object] $ISO
        [Object] $WIM
        [Object] $XML
        BootImage([String]$Path,[String]$Name)
        {
            $This.Path = $Path
            $This.Name = $Name
            $This.Type = Switch ([UInt32]($This.Name -match "\(x64\)")) { 0 { "x86" } 1 { "x64" } }
            $This.ISO  = "$Path\$Name.iso"
            $This.WIM  = "$Path\$Name.wim"
            $This.XML  = "$Path\$Name.xml"
        }
    }

    Class BootImages
    {
        [Object] $Images
        BootImages([Object]$Directory)
        {
            $This.Images = @( )

            ForEach ( $Item in Get-ChildItem $Directory | ? Extension | % BaseName | Select-Object -Unique )
            {
                $This.Images += [BootImage]::New($Directory,$Item)
            }
        }
    }
    
    Class FEDeploymentShareGUI
    {
        Static [String] $Tab = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://New Deployment Share" Width="640" Height="780" Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">
        <Window.Resources>
            <Style TargetType="GroupBox" x:Key="xGroupBox">
                <Setter Property="TextBlock.TextAlignment" Value="Center"/>
                <Setter Property="Background" Value="Azure"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="GroupBox">
                            <Border CornerRadius="10" Background="Azure" BorderBrush="Black" BorderThickness="2">
                                <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="GroupBox">
                <Setter Property="Foreground" Value="Black"/>
                <Setter Property="BorderBrush" Value="DarkBlue"/>
                <Setter Property="BorderThickness" Value="2"/>
                <Setter Property="Padding" Value="2"/>
                <Setter Property="Margin" Value="2"/>
            </Style>
            <Style TargetType="Button">
                <Setter Property="TextBlock.TextAlignment" Value="Center"/>
                <Setter Property="VerticalAlignment" Value="Center"/>
                <Setter Property="FontWeight" Value="Medium"/>
                <Setter Property="Padding" Value="5"/>
                <Setter Property="Margin" Value="5"/>
                <Setter Property="Margin" Value="10,0,10,0"/>
                <Setter Property="Foreground" Value="White"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="Button">
                            <Border CornerRadius="10" Background="#007bff" BorderBrush="Black" BorderThickness="3">
                                <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="TabControl">
                <Setter Property="Background" Value="Azure"/>
            </Style>
            <Style TargetType="TabItem">
                <Setter Property="TextBlock.TextAlignment" Value="Center"/>
                <Setter Property="VerticalAlignment" Value="Center"/>
                <Setter Property="FontWeight" Value="Medium"/>
                <Setter Property="Padding" Value="10"/>
                <Setter Property="Margin" Value="10"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="TabItem">
                            <Border CornerRadius="10" Background="#007bff" BorderBrush="Black" BorderThickness="3">
                                <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="TextBox">
                <Setter Property="TextBlock.TextAlignment" Value="Left"/>
                <Setter Property="VerticalContentAlignment" Value="Center"/>
                <Setter Property="HorizontalContentAlignment" Value="Left"/>
                <Setter Property="Margin" Value="10,0,10,0"/>
                <Setter Property="TextWrapping" Value="Wrap"/>
                <Setter Property="Height" Value="24"/>
                <Setter Property="TextBlock.Effect">
                    <Setter.Value>
                        <DropShadowEffect ShadowDepth="1"/>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="DataGrid">
                <Setter Property="Margin" Value="5"/>
                <Setter Property="HorizontalAlignment" Value="Center"/>
                <Setter Property="AutoGenerateColumns" Value="False"/>
                <Setter Property="AlternationCount" Value="2"/>
                <Setter Property="HeadersVisibility" Value="Column"/>
                <Setter Property="CanUserResizeRows" Value="False"/>
                <Setter Property="CanUserAddRows" Value="False"/>
                <Setter Property="IsTabStop" Value="True" />
                <Setter Property="IsTextSearchEnabled" Value="True"/>
                <Setter Property="IsReadOnly" Value="True"/>
                <Setter Property="TextBlock.HorizontalAlignment" Value="Left"/>
                <Setter Property="TextBlock.Effect">
                    <Setter.Value>
                        <DropShadowEffect ShadowDepth="1"/>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="DataGridRow">
                <Setter Property="TextBlock.HorizontalAlignment" Value="Left"/>
                <Style.Triggers>
                    <Trigger Property="AlternationIndex" Value="0">
                        <Setter Property="Background" Value="White"/>
                    </Trigger>
                    <Trigger Property="AlternationIndex" Value="1">
                        <Setter Property="Background" Value="Azure"/>
                    </Trigger>
                </Style.Triggers>
            </Style>
            <Style TargetType="DataGridColumnHeader">
                <Setter Property="FontSize"   Value="10"/>
            </Style>
            <Style TargetType="DataGridCell">
                <Setter Property="TextBlock.TextAlignment" Value="Left"/>
            </Style>
            <Style TargetType="PasswordBox">
                <Setter Property="Height" Value="24"/>
                <Setter Property="HorizontalContentAlignment" Value="Left"/>
                <Setter Property="VerticalContentAlignment" Value="Center"/>
                <Setter Property="TextBlock.HorizontalAlignment" Value="Stretch"/>
                <Setter Property="Margin" Value="5"/>
                <Setter Property="PasswordChar" Value="*"/>
                <Setter Property="TextBlock.Effect">
                    <Setter.Value>
                        <DropShadowEffect ShadowDepth="1"/>
                    </Setter.Value>
                </Setter>
            </Style>
            <Style TargetType="ComboBox">
                <Setter Property="Margin" Value="10"/>
                <Setter Property="Height" Value="24"/>
                <Setter Property="TextBlock.Effect">
                    <Setter.Value>
                        <DropShadowEffect ShadowDepth="1"/>
                    </Setter.Value>
                </Setter>
            </Style>
        </Window.Resources>
        <Grid Background="White">
            <GroupBox Style="{StaticResource xGroupBox}"  Grid.Row="0" Margin="10" Padding="10" Foreground="Black" Background="White">
                <TabControl Grid.Row="1" BorderBrush="Black" Foreground="{x:Null}">
                    <TabControl.Resources>
                        <Style TargetType="TabItem">
                            <Setter Property="Template">
                                <Setter.Value>
                                    <ControlTemplate TargetType="TabItem">
                                        <Border Name="Border" BorderThickness="1,1,1,0" BorderBrush="Gainsboro" CornerRadius="4,4,0,0" Margin="2,0">
                                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="10,2"/>
                                        </Border>
                                        <ControlTemplate.Triggers>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter TargetName="Border" Property="Background" Value="LightSkyBlue"/>
                                            </Trigger>
                                            <Trigger Property="IsSelected" Value="False">
                                                <Setter TargetName="Border" Property="Background" Value="GhostWhite"/>
                                            </Trigger>
                                        </ControlTemplate.Triggers>
                                    </ControlTemplate>
                                </Setter.Value>
                            </Setter>
                        </Style>
                    </TabControl.Resources>
                    <TabItem Header="Config">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="200"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="60"/>
                            </Grid.RowDefinitions>
                            <GroupBox Grid.Row="0" Header="[CfgServices (Dependency Snapshot)]">
                                <DataGrid Name="CfgServices">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="Name"      Binding="{Binding Name}"  Width="150"/>
                                        <DataGridTextColumn Header="Installed/Meets minimum requirements" Binding="{Binding Value}" Width="*"/>
                                    </DataGrid.Columns>
                                </DataGrid>
                            </GroupBox>
                            <TabControl Grid.Row="1">
                                <TabItem Header="Dhcp">
                                    <GroupBox Header="[CfgDhcp (Dynamic Host Control Protocol)]">
                                        <DataGrid Name="CfgDhcp">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="Dns">
                                    <GroupBox Header="[CfgDns (Domain Name Service)]">
                                        <DataGrid Name="CfgDns">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="Adds">
                                    <GroupBox Header="[CfgAdds (Active Directory Directory Service)">
                                        <DataGrid Name="CfgAdds">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="Wds">
                                    <GroupBox Header="[CfgWds (Windows Deployment Services)]">
                                        <DataGrid Name="CfgWds">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="Mdt">
                                    <GroupBox Header="[CfgMdt (Microsoft Deployment Toolkit)]">
                                        <DataGrid Name="CfgMdt">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="WinAdk">
                                    <GroupBox Header="[CfgWinAdk (Windows Assessment and Deployment Kit)]">
                                        <DataGrid Name="CfgWinAdk">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="WinPE">
                                    <GroupBox Header="[CfgWinPE (Windows Preinstallation Environment Kit)]">
                                        <DataGrid Name="CfgWinPE">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                                <TabItem Header="IIS">
                                    <GroupBox Header="[CfgIIS (Internet Information Services)]">
                                        <DataGrid Name="CfgIIS">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>
                                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </GroupBox>
                                </TabItem>
                            </TabControl>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Domain" BorderBrush="{x:Null}">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="225"/>
                                <RowDefinition Height="150"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Grid Grid.Row="0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="120"/>
                                </Grid.ColumnDefinitions>
                                <GroupBox Grid.Column="0" Header="[DcOrganization]">
                                    <TextBox Name="DcOrganization"/>
                                </GroupBox>
                                <GroupBox Grid.Column="1" Header="[DcCommonName]">
                                    <TextBox Name="DcCommonName"/>
                                </GroupBox>
                                <Button Grid.Column="2" Name="DcGetSitename" Content="Get Sitename"/>
                            </Grid>
                            <GroupBox Grid.Row="1" Header="[DcAggregate]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="80"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="DcAggregate"
                                                  ScrollViewer.CanContentScroll="True"
                                                  ScrollViewer.IsDeferredScrollingEnabled="True"
                                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">
                                        <DataGrid.Columns>
    
                                            <DataGridTextColumn Header="Name"     Binding='{Binding SiteLink}' Width="120"/>
                                            <DataGridTextColumn Header="Location" Binding='{Binding Location}' Width="100"/>
                                            <DataGridTextColumn Header="Region"   Binding='{Binding Region}' Width="60"/>
                                            <DataGridTextColumn Header="Country"  Binding='{Binding Country}' Width="60"/>
                                            <DataGridTextColumn Header="Postal"   Binding='{Binding Postal}' Width="60"/>
                                            <DataGridTextColumn Header="TimeZone" Binding='{Binding TimeZone}' Width="120"/>
                                            <DataGridTextColumn Header="SiteName" Binding='{Binding SiteName}' Width="Auto"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1" Margin="5">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="50"/>
                                            <ColumnDefinition Width="50"/>
                                        </Grid.ColumnDefinitions>
                                        <GroupBox Grid.Column="0" Header="[DcAddSitenameTown]" IsEnabled="False">
                                            <TextBox Name="DcAddSitenameTown"/>
                                        </GroupBox>
                                        <GroupBox Grid.Column="1" Header="[DcAddSitenameZip]">
                                            <TextBox Name="DcAddSitenameZip"/>
                                        </GroupBox>
                                        <Button Grid.Column="2" Name="DcAddSitename" Content="+"/>
                                        <Button Grid.Column="3" Name="DcRemoveSitename" Content="-"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="2" Header="[DcViewer]">
                                <DataGrid Name="DcViewer">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="Name"  Binding='{Binding Name}'  Width="150"/>
                                        <DataGridTextColumn Header="Value" Binding='{Binding Value}' Width="*"/>
                                    </DataGrid.Columns>
                                </DataGrid>
                            </GroupBox>
                            <GroupBox Grid.Row="3" Header="[DcTopography]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="DcTopography"
                                                  ScrollViewer.CanContentScroll="True"
                                                  ScrollViewer.IsDeferredScrollingEnabled="True"
                                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name" Binding="{Binding SiteLink}" Width="150"/>
                                            <DataGridTextColumn Header="Sitename" Binding="{Binding SiteName}" Width="200"/>
                                            <DataGridTemplateColumn Header="Exists" Width="50">
                                                <DataGridTemplateColumn.CellTemplate>
                                                    <DataTemplate>
                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">
                                                            <ComboBoxItem Content="No"/>
                                                            <ComboBoxItem Content="Yes"/>
                                                        </ComboBox>
                                                    </DataTemplate>
                                                </DataGridTemplateColumn.CellTemplate>
                                            </DataGridTemplateColumn>
                                            <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="DcGetTopography" Content="Get"/>
                                        <Button Grid.Column="1" Name="DcNewTopography" Content="New"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            
                        </Grid>
                    </TabItem>
                    <TabItem Header="Network" BorderBrush="{x:Null}">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="225"/>
                                <RowDefinition Height="150"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Grid Grid.Row="0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="100"/>
                                </Grid.ColumnDefinitions>
                                <GroupBox Grid.Row="0" Header="[NwScope]">
                                    <TextBox Grid.Column="0" Name="NwScope"/>
                                </GroupBox>
                                <Button Grid.Column="1" Name="NwScopeLoad" Content="Load" IsEnabled="False"/>
                            </Grid>
                            <GroupBox Grid.Row="1" Header="[NwAggregate]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="80"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Name="NwAggregate"
                                                  ScrollViewer.CanContentScroll="True" 
                                                  ScrollViewer.IsDeferredScrollingEnabled="True"
                                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name"      Binding="{Binding Network}"   Width="100"/>
                                            <DataGridTextColumn Header="Netmask"   Binding="{Binding Netmask}"   Width="100"/>
                                            <DataGridTextColumn Header="HostCount" Binding="{Binding HostCount}" Width="60"/>
                                            <DataGridTextColumn Header="Start"     Binding="{Binding Start}"     Width="100"/>
                                            <DataGridTextColumn Header="End"       Binding="{Binding End}"       Width="100"/>
                                            <DataGridTextColumn Header="Broadcast" Binding="{Binding Broadcast}" Width="*"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1" Margin="5">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="50"/>
                                            <ColumnDefinition Width="50"/>
                                        </Grid.ColumnDefinitions>
                                        <GroupBox Grid.Column="0" Header="[NwSubnetName]">
                                            <TextBox Name="NwSubnetName"/>
                                        </GroupBox>
                                        <Button Grid.Column="1" Name="NwAddSubnetName" Content="+"/>
                                        <Button Grid.Column="2" Name="NwRemoveSubnetName" Content="-"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="2" Header="[NwViewer]">
                                <DataGrid Name="NwViewer">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="Name"   Binding="{Binding Name}"   Width="150"/>
                                        <DataGridTextColumn Header="Value"  Binding="{Binding Value}"   Width="*"/>
                                    </DataGrid.Columns>
                                </DataGrid>
                            </GroupBox>
                            <GroupBox Grid.Row="3" Header="[NwTopography]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="NwTopography"
                                                      ScrollViewer.CanContentScroll="True"
                                                      ScrollViewer.IsDeferredScrollingEnabled="True"
                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name"    Binding="{Binding Name}" Width="150"/>
                                            <DataGridTextColumn Header="Network" Binding="{Binding Network}" Width="200"/>
                                            <DataGridTemplateColumn Header="Exists" Width="50">
                                                <DataGridTemplateColumn.CellTemplate>
                                                    <DataTemplate>
                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">
                                                            <ComboBoxItem Content="No"/>
                                                            <ComboBoxItem Content="Yes"/>
                                                        </ComboBox>
                                                    </DataTemplate>
                                                </DataGridTemplateColumn.CellTemplate>
                                            </DataGridTemplateColumn>
                                            <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="NwGetSubnetName" Content="Get"/>
                                        <Button Grid.Column="1" Name="NwNewSubnetName" Content="New"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Gateway" BorderBrush="{x:Null}">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="225"/>
                                <RowDefinition Height="150"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Grid Grid.Row="0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="120"/>
                                </Grid.ColumnDefinitions>
                                <GroupBox Grid.Column="0" Header="[GwSiteCount]">
                                    <TextBox Name="GwSiteCount"/>
                                </GroupBox>
                                <GroupBox Grid.Column="1" Header="[GwNetworkCount]">
                                    <TextBox Name="GwNetworkCount"/>
                                </GroupBox>
                                <Button Grid.Column="2" Name="GwLoadGateway" Content="Load"/>
                            </Grid>
                            <GroupBox Grid.Row="1" Header="[GwAggregate]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="80"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Name="GwAggregate"
                                                  ScrollViewer.CanContentScroll="True" 
                                                  ScrollViewer.IsDeferredScrollingEnabled="True"
                                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name"      Binding="{Binding Name}"     Width="*"/>
                                            <DataGridTextColumn Header="Location"  Binding="{Binding Location}" Width="*"/>
                                            <DataGridTextColumn Header="Sitename"  Binding="{Binding SiteName}" Width="*"/>
                                            <DataGridTextColumn Header="Network"   Binding="{Binding Network}"  Width="*"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1" Margin="5">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="50"/>
                                            <ColumnDefinition Width="50"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="1" Name="GwAddGateway" Content="+"/>
                                        <GroupBox Grid.Column="0" Header="[GwGatewayName]">
                                            <TextBox Name="GwGateway"/>
                                        </GroupBox>
                                        <Button Grid.Column="2" Name="GwRemoveGateway" Content="-"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="2" Header="[GwViewer]">
                                <DataGrid Name="GwViewer">
                                    <DataGrid.Columns>
                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>
                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>
                                    </DataGrid.Columns>
                                </DataGrid>
                            </GroupBox>
                            <GroupBox Grid.Row="3" Header="[GwTopography]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="GwTopography">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="SiteName"  Binding="{Binding SiteName}" Width="200"/>
                                            <DataGridTextColumn Header="Network"    Binding="{Binding Network}" Width="150"/>
                                            <DataGridTemplateColumn Header="Exists" Width="50">
                                                <DataGridTemplateColumn.CellTemplate>
                                                    <DataTemplate>
                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">
                                                            <ComboBoxItem Content="No"/>
                                                            <ComboBoxItem Content="Yes"/>
                                                        </ComboBox>
                                                    </DataTemplate>
                                                </DataGridTemplateColumn.CellTemplate>
                                            </DataGridTemplateColumn>
                                            <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="GwGetGateway" Content="Get"/>
                                        <Button Grid.Column="1" Name="GwNewGateway" Content="New"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Imaging" BorderBrush="{x:Null}">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="200"/>
                                <RowDefinition Height="200"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <GroupBox Grid.Row="0" Header="[IsoPath (Source Directory)]">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="100"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="100"/>
                                    </Grid.ColumnDefinitions>
                                    <Button Name="IsoSelect" Grid.Column="0" Content="Select"/>
                                    <TextBox Name="IsoPath"  Grid.Column="1"/>
                                    <Button Name="IsoScan" Grid.Column="2" Content="Scan"/>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="1" Header="[IsoList (*.iso)]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="IsoList">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name" Binding='{Binding Name}' Width="*"/>
                                            <DataGridTextColumn Header="Path" Binding='{Binding Fullname}' Width="2*"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="IsoMount" Content="Mount" IsEnabled="False"/>
                                        <Button Grid.Column="1" Name="IsoDismount" Content="Dismount" IsEnabled="False"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            <Grid Grid.Row="2">
                                <GroupBox Grid.Row="2" Header="[IsoView (Image Viewer)]">
                                    <Grid>
                                        <Grid.RowDefinitions>
                                            <RowDefinition Height="*"/>
                                            <RowDefinition Height="60"/>
                                        </Grid.RowDefinitions>
                                        <DataGrid Grid.Row="0" Name="IsoView">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Index" Binding='{Binding Index}' Width="40"/>
                                                <DataGridTextColumn Header="Name"  Binding='{Binding Name}' Width="*"/>
                                                <DataGridTextColumn Header="Size"  Binding='{Binding Size}' Width="100"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                        <Grid Grid.Row="1">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Grid.Column="0" Name="WimQueue" Content="Queue" IsEnabled="False"/>
                                            <Button Grid.Column="1" Name="WimDequeue" Content="Dequeue" IsEnabled="False"/>
                                        </Grid>
                                    </Grid>
                                </GroupBox>
                            </Grid>
                            <GroupBox Grid.Row="3" Header="[WimIso (Queue)]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <Grid Grid.Row="0">
                                        <Grid.RowDefinitions>
                                            <RowDefinition Height="*"/>
                                            <RowDefinition Height="*"/>
                                        </Grid.RowDefinitions>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="50"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Row="0" Name="WimIsoUp" Content="˄"/>
                                        <Button Grid.Row="1" Name="WimIsoDown" Content="˅"/>
                                        <DataGrid Grid.Column="1" Grid.Row="0" Grid.RowSpan="2" Name="WimIso">
                                            <DataGrid.Columns>
                                                <DataGridTextColumn Header="Name"  Binding='{Binding FullName}' Width="*"/>
                                                <DataGridTextColumn Header="Index" Binding='{Binding Index}' Width="100"/>
                                            </DataGrid.Columns>
                                        </DataGrid>
                                    </Grid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="100"/>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="100"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Name="WimSelect" Grid.Column="0" Content="Select"/>
                                        <TextBox Grid.Column="1" Name="WimPath"/>
                                        <Button Grid.Column="2" Name="WimExtract" Content="Extract"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Updates" BorderBrush="{x:Null}">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="200"/>
                                <RowDefinition Height="225"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <GroupBox Grid.Row="0" Header="[UpdPath (Updates)]">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="100"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="100"/>
                                    </Grid.ColumnDefinitions>
                                    <Button Grid.Column="0" Name="UpdSelect" Content="Select"/>
                                    <TextBox Grid.Column="1" Name="UpdPath"/>
                                    <Button Grid.Column="2" Name="UpdScan" Content="Scan"/>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="1" Header="[UpdSelected]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="80"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0"  Name="UpdAggregate">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="200"/>
                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="UpdAddUpdate" Content="Add"/>
                                        <Button Grid.Column="1" Name="UpdRemoveUpdate" Content="Remove"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                            <GroupBox Grid.Row="2" Header="[UpdViewer]">
                                    <DataGrid Name="UpdViewer">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>
                                            <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>
                                            <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                </GroupBox>
                            <GroupBox Grid.Row="3" Header="[UpdWim]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="80"/>
                                    </Grid.RowDefinitions>
                                    <DataGrid Grid.Row="0" Name="UpdWim">
                                        <DataGrid.Columns>
                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>
                                            <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>
                                            <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>
                                        </DataGrid.Columns>
                                    </DataGrid>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="UpdInstallUpdate" Content="Install"/>
                                        <Button Grid.Column="1" Name="UpdUninstallUpdate" Content="Uninstall"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Share">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="80"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Grid Grid.Row="0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="100"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="150"/>
                                </Grid.ColumnDefinitions>
                                <Button Name="DsRootSelect" Grid.Column="0" Content="Select"/>
                                <GroupBox Grid.Column="1" Header="[DsRootPath (Root)]">
                                    <TextBox Name="DsRootPath"/>
                                </GroupBox>
                                <GroupBox Grid.Column="2" Header="[DsShareName (SMB)]">
                                    <TextBox Name="DsShareName"/>
                                </GroupBox>
                            </Grid>
                            <Grid Grid.Row="1">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="150"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="150"/>
                                </Grid.ColumnDefinitions>
                                <GroupBox Grid.Column="0" Header="[DsDriveName]">
                                    <TextBox Name="DsDriveName"/>
                                </GroupBox>
                                <GroupBox Grid.Column="1" Header="[DsDescription]">
                                    <TextBox Name="DsDescription"/>
                                </GroupBox>
                                <GroupBox Grid.Column="2" Header="[Legacy MDT/PSD]">
                                    <ComboBox Name="DsType">
                                        <ComboBoxItem Content="MDT" IsSelected="True"/>
                                        <ComboBoxItem Content="PSD"/>
                                    </ComboBox>
                                </GroupBox>
                            </Grid>
                            <GroupBox Grid.Row="2" Header="[DsShareConfig]">
                                <Grid>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="60"/>
                                    </Grid.RowDefinitions>
                                    <TabControl Grid.Row="0">
                                        <TabItem Header="Domain Admin">
                                            <Grid  VerticalAlignment="Top">
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                </Grid.RowDefinitions>
                                                <GroupBox Grid.Row="0" Header="[Domain Admin Username]">
                                                    <TextBox Name="DsDcUsername"/>
                                                </GroupBox>
                                                <GroupBox Grid.Row="1" Header="[Password/Confirm]">
                                                    <Grid>
                                                        <Grid.ColumnDefinitions>
                                                            <ColumnDefinition Width="*"/>
                                                            <ColumnDefinition Width="*"/>
                                                        </Grid.ColumnDefinitions>
                                                        <PasswordBox Grid.Column="0" Name="DsDcPassword" HorizontalContentAlignment="Left"/>
                                                        <PasswordBox Grid.Column="1" Name="DsDcConfirm"  HorizontalContentAlignment="Left"/>
                                                    </Grid>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                        <TabItem Header="Local Admin">
                                            <Grid VerticalAlignment="Top">
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                </Grid.RowDefinitions>
                                                <GroupBox Grid.Row="0" Header="[Local Admin Username]">
                                                    <TextBox Name="DsLmUsername"/>
                                                </GroupBox>
                                                <GroupBox Grid.Row="1" Header="[Password/Confirm]">
                                                    <Grid>
                                                        <Grid.ColumnDefinitions>
                                                            <ColumnDefinition Width="*"/>
                                                            <ColumnDefinition Width="*"/>
                                                        </Grid.ColumnDefinitions>
                                                        <PasswordBox Grid.Column="0" Name="DsLmPassword"  HorizontalContentAlignment="Left"/>
                                                        <PasswordBox Grid.Column="1" Name="DsLmConfirm"  HorizontalContentAlignment="Left"/>
                                                    </Grid>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                        <TabItem Header="Branding">
                                            <Grid>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                </Grid.RowDefinitions>
                                                <Grid Grid.Row="0">
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="100"/>
                                                        <ColumnDefinition Width="*"/>
                                                        <ColumnDefinition Width="*"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Button Name="DsBrCollect" Content="Collect" IsEnabled="True"/>
                                                    <GroupBox Grid.Column="1" Header="[BrPhone (Support Phone)]">
                                                        <TextBox Name="DsBrPhone"/>
                                                    </GroupBox>
                                                    <GroupBox Grid.Column="2" Header="[BrHours (Support Hours)]">
                                                        <TextBox Name="DsBrHours"/>
                                                    </GroupBox>
                                                </Grid>
                                                <GroupBox Grid.Row="1" Header="[BrWebsite (Support Website)]">
                                                    <TextBox Name="DsBrWebsite"/>
                                                </GroupBox>
                                                <GroupBox Grid.Row="2" Header="[BrLogo (120x120 Bitmap/*.bmp)]">
                                                    <Grid>
                                                        <Grid.ColumnDefinitions>
                                                            <ColumnDefinition Width="100"/>
                                                            <ColumnDefinition Width="*"/>
                                                        </Grid.ColumnDefinitions>
                                                        <Button Grid.Column="0" Name="DsBrLogoSelect" Content="Select"/>
                                                        <TextBox Grid.Column="1" Name="DsBrLogo"/>
                                                    </Grid>
                                                </GroupBox>
                                                <GroupBox Grid.Row="3" Header="[BrBackground (Common Image File)]">
                                                    <Grid>
                                                        <Grid.ColumnDefinitions>
                                                            <ColumnDefinition Width="100"/>
                                                            <ColumnDefinition Width="*"/>
                                                        </Grid.ColumnDefinitions>
                                                        <Button Grid.Column="0" Name="DsBrBackgroundSelect" Content="Select"/>
                                                        <TextBox Grid.Column="1" Name="DsBrBackground"/>
                                                    </Grid>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                        <TabItem Header="Network">
                                            <Grid VerticalAlignment="Top">
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                    <RowDefinition Height="80"/>
                                                </Grid.RowDefinitions>
                                                <GroupBox Grid.Row="0" Header="[DsNwNetBiosName]">
                                                    <TextBox Name="DsNwNetBiosName"/>
                                                </GroupBox>
                                                <GroupBox Grid.Row="1" Header="[DsNwDnsName]">
                                                    <TextBox Name="DsNwDnsName"/>
                                                </GroupBox>
                                                <GroupBox Grid.Row="2" Header="[DsNwMachineOuName]">
                                                    <TextBox Name="DsNwMachineOuName"/>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                        <TabItem Header="Bootstrap">
                                            <Grid>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="60"/>
                                                    <RowDefinition Height="*"/>
                                                </Grid.RowDefinitions>
                                                <Grid Grid.Row="0">
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="100"/>
                                                        <ColumnDefinition Width="*"/>
                                                        <ColumnDefinition Width="100"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Button Grid.Column="0" Name="DsGenerateBootstrap" Content="Generate"/>
                                                    <TextBox Grid.Column="1" Name="DsBootstrapPath"/>
                                                    <Button Grid.Column="2" Name="DsSelectBootstrap" Content="Select"/>
                                                </Grid>
                                                <GroupBox Grid.Row="1" Header="[Bootstrap.ini]">
                                                    <TextBlock Grid.Row="1" Background="White" Name="DsBootstrap" Margin="5" Padding="5">
                                                        <TextBlock.Effect>
                                                            <DropShadowEffect ShadowDepth="1"/>
                                                        </TextBlock.Effect>
                                                    </TextBlock>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                        <TabItem Header="CustomSettings">
                                            <Grid>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="60"/>
                                                    <RowDefinition Height="*"/>
                                                </Grid.RowDefinitions>
                                                <Grid Grid.Row="0">
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="100"/>
                                                        <ColumnDefinition Width="*"/>
                                                        <ColumnDefinition Width="100"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Button Grid.Column="0" Name="DsGenerateCustomSettings" Content="Generate"/>
                                                    <TextBox Grid.Column="1" Name="DsCustomSettingsPath"/>
                                                    <Button Grid.Column="2" Name="DsSelectCustomSettings" Content="Select"/>
                                                </Grid>
                                                <GroupBox Grid.Row="1" Header="[CustomSettings.ini]">
                                                    <TextBlock Grid.Row="1" Background="White" Name="DsCustomSettings" Margin="5" Padding="5">
                                                        <TextBlock.Effect>
                                                            <DropShadowEffect ShadowDepth="1"/>
                                                        </TextBlock.Effect>
                                                    </TextBlock>
                                                </GroupBox>
                                            </Grid>
                                        </TabItem>
                                    </TabControl>
                                    <Grid Grid.Row="1">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        <Button Grid.Column="0" Name="DsCreate" Content="Create"/>
                                        <Button Grid.Column="1" Name="DsUpdate" Content="Update"/>
                                    </Grid>
                                </Grid>
                            </GroupBox>
                        </Grid>
                    </TabItem>
                </TabControl>
            </GroupBox>
        </Grid>
    </Window>
"@
    }

    # Controller class
    Class Main
    {
        Static [String]       $Base = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        Static [String]        $GFX = "$([Main]::Base)\Graphics"
        Static [String]       $Icon = "$([Main]::GFX)\icon.ico"
        Static [String]       $Logo = "$([Main]::GFX)\OEMLogo.bmp"
        Static [String] $Background = "$([Main]::GFX)\OEMbg.jpg"
        Hidden [Object]   $ZipStack
        [String]               $Org
        [String]                $CN
        [Object]          $Template
        [String]        $SearchBase
        [Object]               $Win 
        [Object]               $Reg
        [Object]            $Config
        [Object]          $SiteList
        [Object]        $SubnetList
        [Object]            $OuList
        [Object]            $Domain
        [Object]           $Network
        [Object]           $Gateway
        [Object]            $Server
        [Object]             $Image
        [Object]            $Update
        [Object]             $Share
        Main()
        {
            $This.ZipStack          = [ZipStack]::New("github.com/mcc85sx/FightingEntropy/blob/master/scratch/zcdb.txt?raw=true")
            $This.Win               = Get-WindowsFeature
            $This.Reg               = "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
            $This.Config            = @(

                ForEach ( $Item in "DHCP","DNS","AD-Domain-Services","WDS","Web-WebServer")
                {
                    [DGList]::New( $Item, [Bool]( $This.Win | ? Name -eq $Item | % Installed ) )
                }
                
                ForEach ( $Item in "MDT","WinADK","WinPE")
                {
                    $Slot = Switch($Item)
                    {
                        MDT    { $This.Reg[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                        WinADK { $This.Reg[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                        WinPE  { $This.Reg[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
                    }
                        
                    [DGList]::New( $Item, [Bool]( Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2] ) )
                }
            )

            $This.Domain  = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Network = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Gateway = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Image   = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Update  = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Share   = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        [Void] GetSiteList()
        {
            $This.Sitelist      = Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetSubnetList()
        {
            $This.SubnetList    = Get-ADObject -LDAPFilter "(objectClass=subnet)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetOuList()
        {
            $This.OuList        = Get-ADObject -LDAPFilter "(objectClass=organizationalUnit)" -SearchBase $This.SearchBase
        }
        [Void] GetLists()
        {
            $This.GetSiteList()
            $This.GetSubnetList()
            $This.GetOuList()
        }
        [Object] NewCertificate()
        {
            Return @( [Certificate]::New($This.Org,$This.CN) )
        }
        [Void] LoadSitemap([String]$Organization,[String]$CommonName)
        {   # $Organization = "Secure Digits Plus LLC"; $CommonName = "securedigitsplus.com"
            $This.Org           = $Organization
            $This.CN            = $CommonName
            $This.Template      = $This.NewCertificate()
            $This.SearchBase    = "DC=$( $CommonName.Split(".") -join ",DC=" )"

            $This.AddSiteName($This.Template.Postal)
            $This.GetLists()
        }
        [Void] AddSitename([String]$Zip)
        {
            If ( $Zip -notin $This.Domain.Postal )
            {
                $Tmp                = [Certificate]::New($This.Org,$This.CN)
                $Item               = $This.ZipStack.ZipTown($Zip)

                $Tmp.Location       = $Item.Name
                $Tmp.Postal         = $Item.Zip
                $Tmp.Region         = [States]::Name($Item.State)

                $Tmp.GetSiteLink()

                $This.Domain       += @( $Tmp )
            }
        }
        [Void] RemoveSitename([String]$Zip)
        {
            If ( $This.Domain.Count -gt 1 )
            {
                If ( $Zip -in $This.Domain.Postal )
                {
                    $Tmp                = @( $This.Domain )
                    $This.Domain        = @( )
                    $This.Domain        = @( $Tmp | ? Postal -ne $Zip )
                }
            }
        }
        [Object[]] GetDomain([Object]$List)
        {
            $This.GetSiteList()
            Return @( $List | % { [DcTopography]::New($This.SiteList,$_) } )
        }
        [Void] NewDomain([Object]$List)
        {
            ForEach ( $Item in $This.GetDomain($List) )
            {
                If ( $Item.Exists -eq 0 )
                {
                    Switch([System.Windows.MessageBox]::Show("Create ADReplicationSite?","Item $($Item.Sitelink) does not exist.","YesNo"))
                    {
                        Yes { New-ADReplicationSite -Name $Item.Sitelink -Verbose } No { Write-Host "Skipping $($Item.Sitelink)" }
                    }
                }
            }
        }
        [Void] LoadNetwork([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( [Network]::New($Prefix).Aggregate )
                $This.Network    = @( )
                $This.Network    = @( $Tmp )
            }
        }
        [Void] AddSubnet([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( [Scope]$Prefix )
                $This.Network   += @( $Tmp )
            }
        }
        [Void] RemoveSubnet([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( $This.Network | ? Name -ne $Prefix )
                $This.Network    = @( )
                $This.Network    = @( $Tmp )
            }
        }
        [Object[]] GetNetwork([Object]$List)
        {
            $This.GetSubnetList()
            Return @( $List | % { [NwTopography]::New($This.SubnetList,$_) } )
        }
        [Void] NewNetwork([Object]$List)
        {
            ForEach ( $Item in $This.GetNetwork($List) )
            {
                If ( $Item.Exists -eq 0 )
                {
                    Switch([System.Windows.MessageBox]::Show("Create ADReplicationSubnet?","Item $($Item.Name) does not exist.","YesNo"))
                    {
                        Yes { New-ADReplicationSubnet -Name $Item.Name -Verbose } No { Write-Host "Skipping $($Item.Name)" }
                    }
                }
            }
        }
        [Void] LoadGateway()
        {
            If ($This.Network.Count -lt $This.Domain.Count)
            {
                Throw "Insufficient networks"
            }

            $This.Gateway = @( )

            ForEach ($X in 0..($This.Domain.Count - 1))
            {
                $This.Gateway += [Site]::New($This.Domain[$X],$This.Network[$X])
            }
        }
        [Void] RemoveGateway([String]$Name)
        {
            If ( $This.Gateway.Count -gt 1 )
            {
                If ($Name -in $This.Gateway.Name)
                {
                    $This.Gateway = @( $This.Gateway | ? Name -ne $Name )
                }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("Invalid operation, only one gateway remaining","Error")
            }
        }
        [Object[]] GetGateway([Object]$List)
        {
            $This.GetOuList()
            Return @( $List | % { [GwTopography]::New($This.OuList,$_) } )
        }
        [Object[]] LoadUpdate([String]$Path)
        {
            Return @( Get-ChildItem $Path -Recurse | ? Extension -match .msu | % FullName )
        }
    }
    
    # These two variables do most of the work
    $Main                           = [Main]::New()
    $Xaml                           = [XamlWindow][FEDeploymentShareGUI]::Tab

    <# $Xaml.Names | ? { $_ -notin "ContentPresenter","Border","ContentSite" } | % {
        $X = "    # `$Xaml.IO.$_"
        $Y = $Xaml.IO.$_.GetType().Name 
        "{0}{1} # $Y" -f $X,(" "*(40-$X.Length) -join '')
    }#>

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Configuration Tab  ]__________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Config]://Variables
    # $Xaml.IO.CfgServices              # DataGrid
    # $Xaml.IO.CfgDhcp                  # DataGrid
    # $Xaml.IO.CfgDns                   # DataGrid
    # $Xaml.IO.CfgAdds                  # DataGrid
    # $Xaml.IO.CfgWds                   # DataGrid
    # $Xaml.IO.CfgMdt                   # DataGrid
    # $Xaml.IO.CfgWinAdk                # DataGrid
    # $Xaml.IO.CfgWinPE                 # DataGrid
    # $Xaml.IO.CfgIIS                   # DataGrid

    # [DataGrid(s)]://Initialize
    $Xaml.IO.CfgServices.ItemsSource    = @( )
    $Xaml.IO.CfgDhcp.ItemsSource        = @( )
    $Xaml.IO.CfgDns.ItemsSource         = @( )
    $Xaml.IO.CfgAdds.ItemsSource        = @( )
    $Xaml.IO.CfgWds.ItemsSource         = @( )
    $Xaml.IO.CfgMdt.ItemsSource         = @( )
    $Xaml.IO.CfgWinAdk.ItemsSource      = @( )
    $Xaml.IO.CfgWinPE.ItemsSource       = @( )
    $Xaml.IO.CfgIIS.ItemsSource         = @( )

    # [CfgServices]://$Main.Config
    $Xaml.IO.CfgServices.ItemsSource    = @( $Main.Config )

    # [CfgMdt]://Installed ? -> Load persistent drives
    If ( $Main.Config | ? Name -eq MDT | ? Value -eq $True )
    {   
        $MDT     = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \
        Import-Module "$MDT\Bin\MicrosoftDeploymentToolkit.psd1"

        If (Get-MDTPersistentDrive)
        {
            Restore-MDTPersistentDrive
            $Persist = Get-MDTPersistentDrive
        }

        $Xaml.IO.DsDriveName.Text = ("FE{0:d3}" -f @($Persist.Count + 1))
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Domain Tab ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Domain]://Variables
    # $Xaml.IO.DcOrganization           # Text
    # $Xaml.IO.DcCommonName             # Text
    # $Xaml.IO.DcGetSitename            # Button
    # $Xaml.IO.DcAggregate              # DataGrid
    # $Xaml.IO.DcAddSitename            # Button
    # $Xaml.IO.DcAddSitenameZip         # Text
    # $Xaml.IO.DcAddSitenameTown        # Text
    # $Xaml.IO.DcRemoveSitename         # Button
    # $Xaml.IO.DcViewer                 # DataGrid
    # $Xaml.IO.DcTopography             # DataGrid
    # $Xaml.IO.DcGetTopography          # Button
    # $Xaml.IO.DcNewTopography          # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.DcAggregate.ItemsSource    = @( )
    $Xaml.IO.DcViewer.ItemsSource       = @( )
    $Xaml.IO.DcTopography.ItemsSource   = @( )

    # [Domain]://Events
    $Xaml.IO.DcGetSitename.Add_Click(
    {
        If (!$Xaml.IO.DcOrganization.Text)
        {
            [System.Windows.MessageBox]::Show("Invalid/null organization entry","Error")
        }

        ElseIf (!$Xaml.IO.DcCommonName.Text)
        {
            [System.Windows.MessageBox]::Show("Invalid/null common name entry","Error")
        }

        Else
        {   # $Main.LoadSitemap("Secure Digits Plus LLC","securedigitsplus.com")
            $Main.LoadSitemap($Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text)
            $Xaml.IO.DcAggregate.ItemsSource   = @( )
            $Xaml.IO.DcAggregate.ItemsSource   = @( $Main.Domain )
            $Xaml.IO.DcGetSitename.IsEnabled   = 0
            $Xaml.IO.NwScopeLoad.IsEnabled     = 1
        }
    })

    $Xaml.IO.DcAggregate.Add_SelectionChanged(
    {
        $Object = $Xaml.IO.DcAggregate.SelectedItem
        If ( $Object )
        {
            $Xaml.IO.DcViewer.ItemsSource = @( )
            $Xaml.IO.DcViewer.ItemsSource = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName" -Split " " )
            {
                [DGList]::New($Item,$Object.$Item)
            }
        }
    })    

    $Xaml.IO.DcAddSitename.Add_Click(
    {
        If ($Xaml.IO.DcAddSitenameZip.Text -notmatch "(\d{5})")
        {
            Return [System.Windows.MessageBox]::Show("Zipcode text entry error","Error")
        }

        ElseIf($Xaml.IO.DcAddSitenameZip.Text -notin $Main.ZipStack.Stack)
        {
            Return [System.Windows.MessageBox]::Show("Not a valid zip code","Error")
        }

        ElseIf($Xaml.IO.DcAddSitenameZip.Text -in $Main.Domain.Postal)
        {
            Return [System.Windows.MessageBox]::Show("Duplicate Zipcode entry","Error")
        }

        Else
        {
            $Main.AddSitename($Xaml.IO.DcAddSitenameZip.Text)
            $Xaml.IO.DcAggregate.ItemsSource  = @( )
            $Xaml.IO.DcAggregate.ItemsSource  = @( $Main.Domain )
            $Xaml.IO.DcAddSitenameZip.Text    = ""
        }
    })

    $Xaml.IO.DcRemoveSitename.Add_Click(
    {
        If ( $Xaml.IO.DcAggregate.SelectedIndex -gt -1)
        {
            Switch($Main.Domain.Count)
            {
                1
                { 
                    Return [System.Windows.MessageBox]::Show("Count cannot be 1","Last site remaining")
                }

                Default
                {
                    $Item                            = $Xaml.IO.DcAggregate.SelectedItem
                    $Main.Domain                     = ForEach ( $Object in $Main.Domain )
                    {
                        If ( $Object.Postal -notmatch $Item.Postal )
                        {
                            $Object
                        }
                    }
                    $Xaml.IO.DcAggregate.ItemsSource = @( )
                    $Xaml.IO.DcAggregate.ItemsSource = @( $Main.Domain )
                }
            }
        }
    })

    $Xaml.IO.DcGetTopography.Add_Click(
    {
        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopography]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopography.ItemsSource = @( )
        $Xaml.IO.DcTopography.ItemsSource = @( $Tmp )

        $Xaml.IO.GwSiteCount.Text         = $Main.Domain.Count
    })
    
    $Xaml.IO.DcNewTopography.Add_Click(
    {
        ForEach ( $Item in $Xaml.IO.DcTopography.ItemsSource )
        {
            If ( $Item.Exists -eq 0 )
            {
                New-ADReplicationSite -Name $Item.Sitelink -Verbose
            }
        }

        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopography]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopography.ItemsSource = @( )
        $Xaml.IO.DcTopography.ItemsSource = @( $Tmp )

        $Xaml.IO.GwSiteCount.Text         = $Main.Domain.Count
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Network Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Network]://Variables
    # $Xaml.IO.NwScope                  # Text
    # $Xaml.IO.NwScopeLoad              # Button
    # $Xaml.IO.NwAggregate              # DataGrid
    # $Xaml.IO.NwViewer                 # DataGrid
    # $Xaml.IO.NwAddNetwork             # Button
    # $Xaml.IO.NwRemoveNetwork          # Button
    # $Xaml.IO.NwTopography             # DataGrid
    # $Xaml.IO.NwGetNetwork             # Button
    # $Xaml.IO.NwNewNetwork             # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.NwAggregate.ItemsSource    = @( )
    $Xaml.IO.NwViewer.ItemsSource       = @( )
    $Xaml.IO.NwTopography.ItemsSource   = @( )

    # [Network]://Events
    $Xaml.IO.NwScopeLoad.Add_Click(
    {
        If ($Xaml.IO.NwScope.Text -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
        }

        Else
        {   # $Main.LoadNetwork("172.16.0.1/19")
            $Main.LoadNetwork($Xaml.IO.NwScope.Text)
            $Xaml.IO.NwScope.Text              = ""
            $Xaml.IO.NwAggregate.ItemsSource   = @( )
            $Xaml.IO.NwViewer.ItemsSource      = @( )
            $Xaml.IO.NwAggregate.ItemsSource   = @( $Main.Network )
        }
    })

    $Xaml.IO.NwAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.NwViewer.ItemsSource     = @( )

        If ( $Xaml.IO.NwAggregate.SelectedIndex -gt -1 )
        {
            $Network                           = @( $Main.Network | ? Network -match $Xaml.IO.NwAggregate.SelectedItem.Network )
            
            $List = ForEach ( $Item in "Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Network.$Item) 
            }

            $Xaml.IO.NwViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.NwAddSubnetName.Add_Click(
    {
        $Prefix = $Xaml.IO.NwSubnetName.Text
        If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            [System.Windows.MessageBox]::Show("Invalid subnet provided","Error")
        }
        ElseIf( $Prefix -in $Main.Network.Name )
        {
            [System.Windows.MessageBox]::Show("Prefix already exists","Error")
        }
        Else
        {
            $Main.AddSubnet($Prefix)
            $Xaml.IO.NwSubnetName.Text       = ""
            $Xaml.IO.NwAggregate.ItemsSource = @( )
            $Xaml.IO.NwAggregate.ItemsSource = @( $Main.Network )
        }
    })

    $Xaml.IO.NwRemoveSubnetName.Add_Click(
    {
        If ( $Xaml.IO.NwAggregate.SelectedIndex -gt -1 )
        {
            $Main.Network                     = $Main.Network | ? Name -ne $Xaml.IO.NwAggregate.SelectedItem.Name
            $Xaml.IO.NwAggregate.ItemsSource  = @( )
            $Xaml.IO.NwAggregate.ItemsSource  = @( $Main.Network )
        }

        Else
        {
            [System.Windows.MessageBox]::Show("Select a subnet within the dialog box","Error")
        }
    })

    $Xaml.IO.NwGetSubnetName.Add_Click(
    {
        $Main.GetSubnetList()
        If (!$Main.SubnetList)
        {
            Throw "No valid networks detected"
        }
        
        $Xaml.IO.NwTopography.ItemsSource = @( )

        ForEach ( $Item in $Xaml.IO.NwAggregate.ItemsSource | % { [NwTopography]::New($Main.SubnetList,$_) } )
        {
            $Xaml.IO.NwTopography.ItemsSource += $Item 
            #[DGList]::New($Item.Name,$Item.DistinguishedName)
        }

        $Xaml.IO.GwNetworkCount.Text      = $Main.Network.Count 
    })

    $Xaml.IO.NwNewSubnetName.Add_Click(
    {
        ForEach ( $Item in $Xaml.IO.NwTopography.ItemsSource )
        {
            If (!$Item.Exists)
            {
                New-ADReplicationSubnet -Name $Item.Name -Verbose
            }
        }

        $Tmp                              = @( $Main.GetNetwork($Main.Network) | % { [NwTopography]::New($Main.SubnetList,$_) } )
        $Xaml.IO.NwTopography.ItemsSource = @( )
        $Xaml.IO.NwTopography.ItemsSource = @( $Tmp )

        $Xaml.IO.GwNetworkCount.Text      = $Main.Network.Count 
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Gateway Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Gateway]://Variables
    # $Xaml.IO.GwSiteCount               # TextBox
    # $Xaml.IO.GwNetworkCount            # TextBox
    # $Xaml.IO.GwLoadGateway             # Button
    # $Xaml.IO.GwAggregate               # DataGrid
    # $Xaml.IO.GwAddGateway              # Button
    # $Xaml.IO.GwGateway                 # TextBox
    # $Xaml.IO.GwRemoveGateway           # Button
    # $Xaml.IO.GwViewer                  # DataGrid
    # $Xaml.IO.GwTopography              # DataGrid
    # $Xaml.IO.GwGetGateway              # Button
    # $Xaml.IO.GwNewGateway              # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.GwAggregate.ItemsSource    = @()
    $Xaml.IO.GwViewer.ItemsSource       = @()
    $Xaml.IO.GwTopography.ItemsSource   = @()

    # [Gateway]://Events
    $Xaml.IO.GwLoadGateway.Add_Click(
    {
        If ( $Main.Network.Count -lt $Main.Domain.Count )
        {
            [System.Windows.MessageBox]::Show("Insufficient networks","Error: Network count")
        }

        Else
        {
            $Main.LoadGateway()
            $Xaml.IO.GwAggregate.ItemsSource = @( )
            $Xaml.IO.GwAggregate.ItemsSource = @( $Main.Gateway )
        }
    })

    $Xaml.IO.GwAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.GwViewer.ItemsSource     = @( )

        If ( $Xaml.IO.GwAggregate.SelectedIndex -gt -1 )
        {
            $Gateway                           = @( $Main.Gateway | ? Network -match $Xaml.IO.GwAggregate.SelectedItem.Network )
            
            $List = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Gateway.$Item) 
            }

            $Xaml.IO.GwViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.GwRemoveGateway.Add_Click(
    {
        If ( $Xaml.IO.GwAggregate.SelectedIndex -gt -1)
        {
            $Tmp = $Xaml.IO.GwAggregate.SelectedItem
            If ( $Tmp.Name -in $Main.Gateway.Name)
            {
                $Main.RemoveGateway($Tmp.Name)
                $Xaml.IO.GwAggregate.ItemsSource = @( )
                $Xaml.IO.GwAggregate.ItemsSource = @( $Main.Gateway )
            }
        }
    })

    $Xaml.IO.GwGetGateway.Add_Click(
    {
        $Main.GetOuList()
        $Xaml.IO.GwTopography.ItemsSource = @( )

        ForEach ( $Item in $Xaml.IO.GwAggregate.ItemsSource | % { [GwTopography]::New($Main.OuList,$_) } )
        {
            $Xaml.IO.GwTopography.ItemsSource += $Item
        }
    })

    $Xaml.IO.GwNewGateway.Add_Click(
    {
        $Main.GetOuList()

        ForEach ( $Item in $Xaml.IO.GwAggregate.ItemsSource | % { [GwTopography]::New($Main.OuList,$_) } )
        {
            If (!$Item.Exists)
            {
                $Gateway = $Main.Gateway | ? Name -eq $Item.Name
                $OU             = @{ 

                    City        = $Gateway.Location
                    Country     = $Gateway.Country
                    Description = $Gateway.Hash.Network.Name
                    DisplayName = $Gateway.SiteName
                    PostalCode  = $Gateway.Postal
                    State       = $Gateway.Region
                    Name        = $Gateway.Name
                    Path        = $Main.SearchBase
                }
                New-ADOrganizationalUnit @OU -Verbose

                $OU.Path        = "OU={0},{1}" -f $OU.Name, $OU.Path

                0..4 | % { 
                    
                    $OU.Name        = ("Gateway","Server","Computers","Users","Service")[$_]
                    $OU.Description = ("(Routing/Remote Access)","(Domain Servers)","(Workstations)","(Domain Users)","(Service Accounts)")[$_]
                    New-ADOrganizationalUnit @OU -Verbose
                }

                New-ADComputer -Name $Gateway.Name -DNSHostName $Gateway.Sitename -Path "OU=Gateway,$($OU.Path)" -TrustedForDelegation:$True -Verbose
                New-ADComputer -Name "dc1-$($Gateway.Postal)"                     -Path "OU=Server,$($OU.Path)"  -TrustedForDelegation:$True -Verbose
                New-ADUser     -Name "svc1-$($Gateway.Postal)" -Path "OU=Service,$($OU.Path)"
            }
        }

        $Main.GetOuList()
        $Tmp                              = @( $Main.Gateway | % { [GwTopography]::New($Main.OuList,$_) } )
        $Xaml.IO.GwTopography.ItemsSource = @( )
        $Xaml.IO.GwTopography.ItemsSource = @( $Tmp )
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Sites Tab  ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    #$Xaml.IO.SLLoadSiteList.Add_Click(
    #{

    #})

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Imaging Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Imaging]://Variables
    # $Xaml.IO.IsoSelect                # Button
    # $Xaml.IO.IsoPath                  # Text
    # $Xaml.IO.IsoScan                  # Button
    # $Xaml.IO.IsoList                  # DataGrid
    # $Xaml.IO.IsoMount                 # Button
    # $Xaml.IO.IsoDismount              # Button
    # $Xaml.IO.IsoView                  # DataGrid
    # $Xaml.IO.WimQueue                 # Button
    # $Xaml.IO.WimDequeue               # Button
    # $Xaml.IO.WimIsoUp                 # Button
    # $Xaml.IO.WimIsoDown               # Button
    # $Xaml.IO.WimIso                   # DataGrid
    # $Xaml.IO.WimSelect                # Button
    # $Xaml.IO.WimPath                  # Text
    # $Xaml.IO.WimExtract               # Button

    # [DataGrid]://Initialize
    $Xaml.IO.IsoList.ItemsSource        = @( )
    $Xaml.IO.IsoView.ItemsSource        = @( )
    $Xaml.IO.WimIso.ItemsSource         = @( )

    # [Imaging]://Events
    $Xaml.IO.IsoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.IsoPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.IsoPath.Add_TextChanged(
    {
        If ( $Xaml.IO.IsoPath.Text -ne "" )
        {
            $Xaml.IO.IsoScan.IsEnabled = 1
        }
    
        Else
        {
            $Xaml.IO.IsoScan.IsEnabled = 0
        }
    })
    
    $Xaml.IO.IsoScan.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.IsoPath.Text))
        {
            [System.Windows.MessageBox]::Show("Invalid image root path","Error")
        }
    
        $Tmp = Get-ChildItem $Xaml.IO.IsoPath.Text *.iso | Select-Object Name, FullName
    
        If (!$Tmp)
        {
            [System.Windows.MessageBox]::Show("No images detected","Error")
        }

        $Xaml.IO.IsoList.ItemsSource = @( $Tmp )
    })
    
    $Xaml.IO.IsoList.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -gt -1 )
        {
            $Xaml.IO.IsoMount.IsEnabled = 1
        }
    
        Else
        {
            $Xaml.IO.IsoMount.IsEnabled = 0
        }
    })
    
    $Xaml.IO.IsoMount.Add_Click(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -eq -1)
        {
            [System.Windows.MessageBox]::Show("No image selected","Error")
        }
    
        $ImagePath  = $Xaml.IO.IsoList.SelectedItem.FullName
        Write-Host "Mounting [~] [$ImagePath]"
    
        Mount-DiskImage -ImagePath $ImagePath -Verbose
    
        $Letter    = Get-DiskImage $ImagePath | Get-Volume | % DriveLetter
        
        If (!$Letter)
        {
            [System.Windows.MessageBox]::Show("Image failed mounting to drive letter","Error")
        }
    
        ElseIf (!(Test-Path "${Letter}:\sources\install.wim"))
        {
            [System.Windows.MessageBox]::Show("Not a valid Windows disc/image","Error")
            Dismount-Diskimage -ImagePath $ImagePath
        }
    
        Else
        {
            $Xaml.IO.IsoView.ItemsSource     = Get-WindowsImage -ImagePath "${Letter}:\sources\install.wim" | % { [WindowsImage]$_ }
            $Xaml.IO.IsoList.IsEnabled       = 0
            $Xaml.IO.IsoDismount.IsEnabled   = 1
            Write-Host "Mounted [+] [$ImagePath]"
        }
    })
    
    $Xaml.IO.IsoDismount.Add_Click(
    {
        $ImagePath                           = $Xaml.IO.IsoList.SelectedItem.FullName
        Dismount-DiskImage -ImagePath $ImagePath
        $Xaml.IO.IsoView.ItemsSource         = $Null
        $Xaml.IO.IsoList.IsEnabled           = 1
    
        Write-Host "Dismounted [+] [$ImagePath]"
        $ImagePath                           = $Null
    
        $Xaml.IO.IsoDismount.IsEnabled       = 0
    })
    
    $Xaml.IO.IsoView.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoView.Items.Count -eq 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 0
        }
    
        If ( $Xaml.IO.IsoView.Items.Count -gt 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 1
        }
    })
    
    $Xaml.IO.WimIso.Add_SelectionChanged(
    {
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled   = 0
            $Xaml.IO.WimIsoUp.IsEnabled     = 0
            $xaml.IO.WimIsoDown.IsEnabled   = 0
        }
    
        If ( $Xaml.IO.WimIso.Items.Count -gt 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled   = 1
            $Xaml.IO.WimIsoUp.IsEnabled     = 1
            $xaml.IO.WimIsoDown.IsEnabled   = 1
        }
    })
    
    $Xaml.IO.WimQueue.Add_Click(
    {
        If ($Xaml.IO.IsoList.SelectedItem.Fullname -in $Xaml.IO.WimIso.Items.Name)
        {
            [System.Windows.MessageBox]::Show("Image already selected","Error")
        }
    
        Else
        {
            $Indexes      = $Xaml.IO.IsoView.SelectedItems.Index -join ","
            $Descriptions = $Xaml.IO.IsoView.SelectedItems.Description -join ","
            $Xaml.IO.WimIso.ItemsSource += [ImageQueue]::New($Xaml.IO.IsoList.SelectedItem.Fullname,$Indexes,$Descriptions)
        }
    })
    
    $Xaml.IO.WimDequeue.Add_Click(
    {
        $Grid = $Xaml.IO.WimIso.ItemsSource
        $Items = @( )
    
        ForEach ( $Item in $Grid )
        {
            If ( $Item -ne $Xaml.IO.WimIso.SelectedItem )
            {
                $Items += $Item
            }
        }
    
        $Xaml.IO.WimIso.ItemsSource = @( )
        $Xaml.IO.WimIso.ItemsSource = $Items
        $Grid                       = $Null
        $Items                      = $Null
    
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled = 0
        }
    })
    
    $Xaml.IO.WimIsoUp.Add_Click(
    {
        If ( $Xaml.IO.WimIso.Items.Count -gt 1 )
        {
            $Rank  = $Xaml.IO.WimIso.SelectedIndex
            $Grid  = $Xaml.IO.WimIso.ItemsSource
            $Items = 0..($Grid.Count-1)
    
            If ($Rank -ne 0)
            {
                ForEach ($I in 0..($Grid.Count-1))
                {
                    If ( $I -eq $Rank - 1 )
                    {
                        $Items[$I] = $Grid[$I+1]
                    }
    
                    ElseIf ( $I -eq $Rank )
                    {
                        $Items[$I] = $Grid[$I-1]   
                    }
    
                    Else
                    {
                        $Items[$I] = $Grid[$I]
                    }
                }
    
                $Xaml.IO.WimIso.ItemsSource = @( )
                $Xaml.IO.WimIso.ItemsSource = $Items
                $Items = $Null
                $Rank  = $Null
                $Grid  = $Null
            }
        }
    })
    
    $Xaml.IO.WimIsoDown.Add_Click(
    {
        If ( $Xaml.IO.WimIso.Items.Count -gt 1 )
        {
            $Rank  = $Xaml.IO.WimIso.SelectedIndex
            $Grid  = $Xaml.IO.WimIso.ItemsSource
            $Items = 0..($Grid.Count - 1)
    
            If ($Rank -ne $Grid.Count - 1)
            {
                ForEach ($I in 0..($Grid.Count-1))
                {
                    If ( $I -eq $Rank )
                    {
                        $Items[$I] = $Grid[$I+1]   
                    }
    
                    ElseIf ( $I -eq $Rank + 1 )
                    {
                        $Items[$I] = $Grid[$I-1]
                    }
    
                    Else
                    {
                        $Items[$I] = $Grid[$I]
                    }
                }
                
                $Xaml.IO.WimIso.ItemsSource = @( )
                $Xaml.IO.WimIso.ItemsSource = $Items
                $Items = $Null
                $Rank  = $Null
                $Grid  = $Null
            }
        }
    })
    
    $Xaml.IO.WimExtract.Add_Click(
    {
        If (Test-Path $Xaml.IO.WimPath.Text)
        {
            $Children = Get-ChildItem $Xaml.IO.WimPath.Text *.wim -Recurse | % FullName

            If ($Children.Count -gt 0)
            {
                Switch([System.Windows.MessageBox]::Show("Wim files detected at provided path.","Purge and rebuild?","YesNo"))
                {
                    Yes
                    {
                        ForEach ( $Child in $Children )
                        {
                            Remove-Item $Child -Force -Verbose
                        }
                    }

                    No
                    {
                        Break
                    }
                }
            }
        }

        If (!(Test-Path $Xaml.IO.WimPath.Text))
        {
            New-Item -Path $Xaml.IO.WimPath.Text -ItemType Directory -Verbose
        }
    
        $Images = [ImageStore]::New($Xaml.IO.IsoPath.Text,$Xaml.IO.WimPath.Text)
    
        $X      = 0
        ForEach ( $Item in $Xaml.IO.WimIso.Items )
        {
            $Type = Switch -Regex ($Item.Description)
            {
                Server { "Server" } Default { "Client" }
            }
    
            $Images.AddImage($Type,$Item.Name)
            $Images.Store[$X].AddMap($Item.Index.Split(","))
            $X ++
        }
    
        $Images.GetSwap()
        $Images.GetOutput()
        Write-Theme "Complete [+] Images Collected"
    })
    
    $Xaml.IO.WimSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.WimPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.WimPath.Add_TextChanged(
    {
        If ( $Xaml.IO.WimPath.Text -ne "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 1
        }
    
        If ( $Xaml.IO.WimPath.Text -eq "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 0
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Updates Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Updates]://Variables
    # $Xaml.IO.UpdSelect                 # Button
    # $Xaml.IO.UpdPath                   # TextBox
    # $Xaml.IO.UpdScan                   # Button
    # $Xaml.IO.UpdAggregate              # DataGrid
    # $Xaml.IO.UpdAddUpdate              # Button
    # $Xaml.IO.UpdRemoveUpdate           # Button
    # $Xaml.IO.UpdViewer                 # DataGrid
    # $Xaml.IO.UpdWim                    # DataGrid
    # $Xaml.IO.UpdInstallUpdate          # Button
    # $Xaml.IO.UpdUninstallUpdate        # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.UpdAggregate.ItemsSource   = @( )
    $Xaml.IO.UpdViewer.ItemsSource      = @( )
    $Xaml.IO.UpdWim.ItemsSource         = @( )

    # [Updates]://Events
    $Xaml.IO.UpdSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.UpdPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.UpdScan.Add_Click(
    {
        $Main.Update
        $Xaml.IO.UpdAggregate = @( )
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Share Tab  ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
    
    # [Share]://Variables
    # $Xaml.IO.DsRootSelect             # Button
    # $Xaml.IO.DsRootPath               # Text
    # $Xaml.IO.DsShareName              # Text
    # $Xaml.IO.DsDriveName              # Text
    # $Xaml.IO.DsDescription            # Text
    # $Xaml.IO.DsType                   # ComboBox
    # $Xaml.IO.DsDcUsername             # Text
    # $Xaml.IO.DsDcPassword             # Password
    # $Xaml.IO.DsDcConfirm              # Password
    # $Xaml.IO.DsLmUsername             # Text
    # $Xaml.IO.DsLmPassword             # Password
    # $Xaml.IO.DsLmConfirm              # Password
    # $Xaml.IO.DsBrCollect              # Button
    # $Xaml.IO.DsBrPhone                # Text
    # $Xaml.IO.DsBrHours                # Text
    # $Xaml.IO.DsBrWebsite              # Text
    # $Xaml.IO.DsBrLogoSelect           # Button
    # $Xaml.IO.DsBrLogo                 # Text
    # $Xaml.IO.DsBrBackgroundSelect     # Button
    # $Xaml.IO.DsBrBackground           # Text
    # $Xaml.IO.DsNetBiosName            # Text
    # $Xaml.IO.DsDnsName                # Text
    # $Xaml.IO.DsMachineOuName          # Text
    # $Xaml.IO.DsSelectBootstrap         # Button
    # $Xaml.IO.DsGetBootstrap            # Button
    # $Xaml.IO.DsBootstrap               # TextBlock
    # $Xaml.IO.DsSelectCustomSettings    # Button
    # $Xaml.IO.DsGetCustomSettings       # Button
    # $Xaml.IO.DsCustomSettings          # TextBlock
    # $Xaml.IO.DsCreate                  # Button
    # $Xaml.IO.DsUpdate                  # Button

    # [Share]://Events
    $Xaml.IO.DsBrCollect.Add_Click(
    {
        $OEM = Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation' -EA 0

        If ($OEM)
        {
            If ($OEM.Logo)
            {
                $Xaml.IO.DsBrLogo.Text = $Oem.Logo
            }

            If ($OEM.SupportPhone)
            {
                $Xaml.IO.DsBrPhone.Text = $Oem.SupportPhone
            }

            If ($OEM.SupportHours)
            {
                $Xaml.IO.DsBrHours.Text = $Oem.SupportHours
            }

            If ($OEM.SupportURL)
            {
                $Xaml.IO.DsBrWebsite.Text = $Oem.SupportURL
            }
        }

        $OEM = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -EA 0
        
        If ($OEM)
        {
            If ($OEM.Wallpaper)
            {
                $Xaml.IO.DsBrBackground.Text = $OEM.Wallpaper
            }
        }
    })

    $Xaml.IO.DsBrLogoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Logo
        }

        $Xaml.IO.DsBrLogo.Text = $Item.FileName
    })
    
    $Xaml.IO.DsBrBackgroundSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Background
        }

        $Xaml.IO.DsBrBackground.Text = $Item.FileName
    })

    $Xaml.IO.DsRootSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.DSRootPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.DsRootPath.Add_TextChanged(
    {
        If ( $Xaml.IO.DSRootPath.Text -ne "" )
        {
            $Xaml.IO.DSShareName.Text = ("{0}$" -f $Xaml.IO.DSRootPath.Text.Split("(\/|\.)")[-1] )
        }
    })

    $Xaml.IO.DsCreate.Add_Click(
    {
        If ( $Xaml.IO.CfgServices.Items | ? Name -eq MDT | ? Value -ne $True )
        {
            Throw "Unable to initialize, MDT not installed"
        }

        ElseIf ( $PSVersionTable.PSEdition -ne "Desktop" )
        {
            Throw "Unable to initialize, use Windows PowerShell v5.1"
        }

        ElseIf (!$Xaml.IO.DsDcUsername.Text)
        {
            Return [System.Windows.MessageBox]::Show("Missing the deployment share domain account name","Error")
        }

        ElseIf ($Xaml.IO.DsDCPassword.SecurePassword -notmatch $Xaml.IO.DsDCConfirm.SecurePassword)
        {
            Return [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        } 

        ElseIf (!$Xaml.IO.DsLmUsername.Text)
        {
            Return [System.Windows.MessageBox]::Show("Missing the child item local account name","Error")
        }

        ElseIf ($Xaml.IO.DsLmPassword.SecurePassword -notmatch $Xaml.IO.DsLmConfirm.SecurePassword)
        {
            Return [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        }

        ElseIf (!(Get-ADObject -LDAPFilter "(objectClass=organizationalUnit)" | ? DistinguishedName -eq $Xaml.IO.DsMachineOuName.Text))
        {
            Return [System.Windows.MessageBox]::Show("Invalid OU specified","Error")
        }

        Else
        {
            Write-Theme "Creating [~] Deployment Share"

            #$MDT     = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \
            #Import-Module "$MDT\Bin\MicrosoftDeploymentToolkit.psd1"
        }

        If (Get-MDTPersistentDrive)
        {
            $Persist = Restore-MDTPersistentDrive
        }

        $SMB     = Get-SMBShare
        $PSD     = Get-PSDrive

        If ($Xaml.IO.DsRootPath.Text -in $Persist.Root)
        {
            Return [System.Windows.MessageBox]::Show("That path belongs to an existing deployment share","Error")
        }

        ElseIf($Xaml.IO.DsShareName.Text -in $SMB.Name)
        {
            Return [System.Windows.MessageBox]::Show("That share name belongs to an existing SMB share","Error")
        }

        ElseIf ($Xaml.IO.DsDriveName.Text -in $PSD.Name)
        {
            Return [System.Windows.MessageBox]::Show("That (DSDrive|PSDrive) label is already being used","Error")
        }

        Else
        {
            If (!(Test-Path $Xaml.IO.DsRootPath.Text))
            {
                New-Item $Xaml.IO.DsRootPath.Text -ItemType Directory -Verbose
            }

            $Hostname       = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()

            $SMB            = @{

                Name        = $Xaml.IO.DsShareName.Text
                Path        = $Xaml.IO.DsRootPath.Text
                Description = $Xaml.IO.DsDescription.Text
                FullAccess  = "Administrators"
            }

            $PSD            = @{ 

                Name        = $Xaml.IO.DsDriveName.Text
                PSProvider  = "MDTProvider"
                Root        = $Xaml.IO.DsRootPath.Text
                Description = $Xaml.IO.DsDescription.Text
                NetworkPath = ("\\{0}\{1}" -f $Hostname, $Xaml.IO.DsShareName.Text)
            }

            New-SMBShare @SMB
            New-PSDrive  @PSD -Verbose | Add-MDTPersistentDrive -Verbose

            # Load Module / Share Drive Mount
            $Module                = Get-FEModule
            $Root                  = "$($PSD.Name):\"
            $Control               = "$($PSD.Root)\Control"
            $Script                = "$($PSD.Root)\Scripts"

            # To propogate the environment keys to child item [server/client]
            $DS                    = @($PSD.NetworkPath,
                $Xaml.IO.DcOrganization.Text,
                $Xaml.IO.DcCommonName.Text,
                $Xaml.IO.DsBrBackground.Text,
                $Xaml.IO.DsBrLogo.Text,
                $Xaml.IO.DsBrPhone.Text,
                $Xaml.IO.DsBrHours.Text,
                $Xaml.IO.DsBrWebsite.Text)
            $Key                   = [Key]$DS
            
            # Copies the background and logo if they were selected
            ForEach ($File in $Key.Background, $Key.Logo)
            {
                If (Test-Path $File)
                {
                    Copy-Item -Path $File -Destination $Script -Verbose

                    If ($File -eq $Key.Background)
                    {
                        $Key.Background = "$($Key.NetworkPath)\Scripts\$($Key.Background | Split-Path -Leaf)"
                    }

                    If ($File -eq $Key.Logo)
                    {
                        $Key.Logo       = "$($Key.NetworkPath)\Scripts\$($Key.Logo | Split-Path -Leaf)"
                    }
                }
            }

            # For the little computer icon in PXE
            ForEach ( $File in $Module.Control | ? Extension -eq .png )
            {
                Copy-Item -Path $File.Fullname -Destination $Script -Force -Verbose
            }

            # Copies custom template for FightingEntropy to post install/configure
            ForEach ( $File in $Module.Control | ? Name -match Mod.xml )
            {
                Copy-Item -Path $File.FullName -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
            }

            # Used to spawn the correct environment keys on child items
            Set-Content -Path "$($PSD.Root)\DSKey.csv" -Value ($Key | ConvertTo-CSV) -Verbose

            Write-Theme "Collecting [~] images"
            $Images      = @( )
            
            # Extract/order the WIM files and prime for MDT Injection
            Get-ChildItem -Path $Xaml.IO.WimPath.Text -Recurse *.wim | % { 
                
                Write-Host "Processing [$($_.FullName)]"
                $Images += [WimFile]::New($Images.Count,$_.FullName) 
            }

            # Import OS/TS to MDT Share
            $OS          = "$($PSD.Name):\Operating Systems"
            $TS          = "$($PSD.Name):\Task Sequences"
            $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]"

            # Create folders in the new MDT share
            ForEach ( $Type in "Server","Client" )
            {
                ForEach ( $Version in $Images | ? InstallationType -eq $Type | % Version | Select-Object -Unique )
                {
                    ForEach ( $Slot in $OS, $TS )
                    {
                        If (!(Test-Path "$Slot\$Type"))
                        {
                            New-Item -Path $Slot -Enable True -Name $Type -Comments $Comment -ItemType Folder -Verbose
                        }

                        If (!(Test-Path "$Slot\$Type\$Version"))
                        {
                            New-Item -Path "$Slot\$Type" -Enable True -Name $Version -Comments $comment -ItemType Folder -Verbose
                        }
                    }
                }
            }

            ForEach ( $Image in $Images )
            {
                $Type                   = $Image.InstallationType
                $Path                   = "$OS\$Type\$($Image.Version)"

                $OperatingSystem        = @{

                    Path                = $Path
                    SourceFile          = $Image.SourceImagePath
                    DestinationFolder   = $Image.Label
                }
                
                Import-MDTOperatingSystem @OperatingSystem -Move -Verbose

                $TaskSequence           = @{ 
                    
                    Path                = "$TS\$Type\$($Image.Version)"
                    Name                = $Image.ImageName
                    Template            = "FE{0}Mod.xml" -f $Type
                    Comments            = $Comment
                    ID                  = $Image.Label
                    Version             = "1.0"
                    OperatingSystemPath = Get-ChildItem -Path $Path | ? Name -match $Image.Label | % { "{0}\{1}" -f $Path, $_.Name }
                    FullName            = $Xaml.IO.DCLMUsername
                    OrgName             = $Xaml.IO.Organization
                    HomePage            = $Xaml.IO.Website
                    AdminPassword       = $Xaml.IO.DCLMPassword.Password
                }

                Import-MDTTaskSequence @TaskSequence -Verbose
            }

            Write-Theme "OS/TS [+] Imported, removing Wim Swap directory" 11,3,15,0
            Remove-Item -Path $Xaml.IO.WimPath.Text -Recurse -Force -Verbose

            # FightingEntropy(π) Installation propogation
            $Install = @( 
            "[Net.ServicePointManager]::SecurityProtocol = 3072",
            "Invoke-RestMethod https://github.com/mcc85s/FightingEntropy/blob/main/Install.ps1?raw=true | Invoke-Expression",
            "`$Key = '$( $Key | ConvertTo-Json )'",
            "New-EnvironmentKey -Key `$Key | % Apply",
            "`$Module = Get-FEModule",
            "`$Module.Role.Choco()",
            "choco install pwsh vscode microsoft-edge microsoft-windows-terminal ccleaner -y" -join ";`n")

            Set-Content -Path $Script\Install.ps1 -Value $Install -Force -Verbose

            Write-Theme "Setting [~] Share properties [($Root)]"

            # Share Settings
            Set-ItemProperty $Root -Name Comments    -Value $("[FightingEntropy({0})]{1}" -f [Char]960,(Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]") ) -Verbose
            Set-ItemProperty $Root -Name MonitorHost -Value $HostName -Verbose

            # Image Names/Background
            ForEach ($x in 64,86)
            {
                $Names  = $X | % { "Boot.x$_" } | % { "$_.Generate{0}ISO $_.{0}WIMDescription $_.{0}ISOName $_.BackgroundFile" -f "LiteTouch" -Split " " }
                $Values = $X | % { "$($Module.Name)[$($Module.Version)](x$_)" } | % { "True;$_;$_.iso;$($Xaml.IO.Background.Text)" -Split ";" }
                0..3         | % { Set-ItemProperty -Path $Root -Name $Names[$_] -Value $Values[$_] -Verbose } 
            }

            # Bootstrap.ini
            Export-Ini -Path $Control\Bootstrap.ini -Value @{ 

                Settings           = @{ Priority             = "Default"                      }
                Default            = @{ DeployRoot           = $Key.NetworkPath
                                        UserID               = $Xaml.IO.DsDcUserName.Text
                                        UserPassword         = $Xaml.IO.DsDcPassword.Password
                                        UserDomain           = $Xaml.IO.DsCommonName.Text
                                        SkipBDDWelcome       = "YES"                          }
            } | % Output

            # CustomSettings.ini
            Export-Ini -Path $Control\CustomSettings.ini -Value @{

                Settings           = @{ Priority             = "Default" 
                                        Properties           = "MyCustomProperty" }
                Default            = @{ _SMSTSOrgName        = $Xaml.IO.DcOrganization.Text
                                        JoinDomain           = $Xaml.IO.DcCommonName.Text
                                        DomainAdmin          = $Xaml.IO.DsDcUserName.Text
                                        DomainAdminPassword  = $Xaml.IO.DsDcPassword.Password
                                        DomainAdminDomain    = $Xaml.IO.DsCommonName.Text
                                        MachineObjectOU      = $Xaml.IO.DsMachineOuName.Text
                                        SkipDomainMembership = "YES"
                                        OSInstall            = "Y"
                                        SkipCapture          = "NO"
                                        SkipAdminPassword    = "YES" 
                                        SkipProductKey       = "YES" 
                                        SkipComputerBackup   = "NO" 
                                        SkipBitLocker        = "YES" 
                                        KeyboardLocale       = "en-US" 
                                        TimeZoneName         = "$(Get-TimeZone | % ID)"
                                        EventService         = ("http://{0}:9800" -f $Key.NetworkPath.Split("\")[2]) }
            } | % Output

            # Update FEShare(MDT)
            Update-MDTDeploymentShare -Path $Root -Force -Verbose

            # Update/Flush FEShare(Images)
            $ImageLabel = Get-ItemProperty -Path $Root | % { 

                @{  64 = $_.'Boot.x64.LiteTouchWIMDescription'
                    86 = $_.'Boot.x86.LiteTouchWIMDescription' }
            }

            # Rename the Litetouch_ files
            Get-ChildItem -Path "$($Xaml.IO.DSRootPath.Text)\Boot" | ? Extension | % { 

                $Label          = $ImageLabel[$(Switch -Regex ($_.Name) { 64 {64} 86 {86}})]
                $Image          = @{ 

                    Path        = $_.FullName
                    Name        = $_.Name
                    NewName     = "{0}{1}" -f $Label,$_.Extension
                    Extension   = $_.Extension
                }

                If ( $Image.Name -match "LiteTouchPE_" )
                {
                    If ( Test-Path $Image.NewName )
                    {
                        Remove-Item -Path $Image.NewName -Force -Verbose
                    }

                    Rename-Item -Path $Image.Path -NewName $Image.NewName
                }
            }

            If (!(Get-Service -Name WDSServer))
            {
                Throw "WDS Server not installed"
            }

            Get-Service -Name WDSServer | ? Status -ne Running | Start-Service -Verbose

            # Update/Flush FEShare(WDS)
            ForEach ( $Image in [BootImages]::New("$($Xaml.IO.DSRootPath.Text)\Boot").Images )
            {        
                If (Get-WdsBootImage -Architecture $Image.Type -ImageName $Image.Name -EA 0)
                {
                    Write-Theme "Detected [!] $($Image.Name), removing..." 12,4,15,0
                    Remove-WDSBootImage -Architecture $Image.Type -ImageName $Image.Name -Verbose
                }

                Write-Theme "Importing [~] $($Image.Name)" 11,3,15,0
                Import-WdsBootImage -Path $Image.Wim -NewDescription $Image.Name -Verbose
            }

            Restart-Service -Name WDSServer

            Write-Theme -Flag

            $Xaml.IO.DialogResult = $True
        }
    })

    # Set initial TextBox values
    $Xaml.IO.DsNwNetBIOSName.Text = $Env:UserDomain
    $Xaml.IO.DsNwDNSName.Text     = @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
    $Xaml.IO.DsDescription.Text   = "[FightingEntropy({0})][(2021.7.0)]" -f [char]960
    $Xaml.IO.DsLmUsername.Text    = "Administrator"
    
    $Xaml.Invoke()

    # [Gateway - Prepping Section II]
    If ($Main.Gateway)
    {
        $Gateway = $Main.Gateway
        $Scratch = "$Env:ProgramData\Secure Digits Plus LLC"
        $Date    = Get-Date -UFormat %Y%m%d
        $Path    = "$Scratch\Lab($Date)"
        If (!(Test-Path $Scratch))
        {
            New-Item -Path $Scratch -ItemType Directory -Verbose
        }
        If (!(Test-Path $Path))
        {
            New-Item -Path $Path -ItemType Directory -Verbose 
        }

        Get-ChildItem $Path | ? Extension -eq .txt | Remove-Item -Verbose

        ForEach ( $X in 0..($Gateway.Count - 1 ))
        {
            $Item = $Gateway[$X]
            $Item.Hash.Network.HostObject = $Null 
            $Item.Hash.Network.Network_   = $Null 
            $Item.Hash.Network.Netmask_   = $Null
            $Item.Hash.Domain.Ping        = $Null

            Set-Content -Path "$Path\($X)$($Item.Name).txt" -Value ($Item | ConvertTo-Json) -Verbose
        }
    }
}

#$Files = [GwFiles]::New($Path)

# Add-Type -AssemblyName PresentationFramework
# ( GC $Home\Desktop\New-FEDeploymentShare.ps1 -Encoding UTF8 ) -join "`n" | IEX
