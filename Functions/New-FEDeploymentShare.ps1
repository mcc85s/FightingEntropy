Function New-FEDeploymentShare
{
    # Load Assemblies
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms
    Import-Module FightingEntropy

    # Check for server operating system
    If (Get-CimInstance Win32_OperatingSystem | ? Caption -notmatch Server)
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

    Class DcTopology
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]          $SiteLink
        [String]          $SiteName
        [UInt32]            $Exists
        [Object] $DistinguishedName
        DcTopology([Object]$SiteList,[Object]$SM)
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

    Class NwTopology
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]           $Network
        [UInt32]            $Exists
        [Object] $DistinguishedName
        NwTopology([Object]$SubnetList,[Object]$NW)
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

    Class SwTopologyBranch
    {
        [String]              $Type
        [String]              $Name
        [String] $DistinguishedName
        [Bool]              $Exists
        SwTopologyBranch([String]$Type,[String]$Name,[String]$Base,[Object]$OUList)
        {
            $This.Type              = $Type
            Switch($Type) 
            {
                Main 
                {
                    $This.Name              = $Name
                    $This.DistinguishedName = "OU=$Name,$Base"
                } 
                
                Leaf 
                { 
                    $This.Name              = $Name.Split("/")[1]
                    $This.DistinguishedName = "OU={1},OU={0},$Base" -f $Name.Split("/") 
                }
            }
            $This.Exists            = @(0,1)[$This.DistinguishedName -in $OUList.DistinguishedName] 
        }
    }

    Class SmTemplateItem
    {
        [String] $ObjectClass
        [Bool] $Create
        SmTemplateItem([String]$ObjectClass,[Bool]$Create)
        {
            $This.ObjectClass = $ObjectClass
            $This.Create      = $Create
        }
    }

    Class SmTemplate
    {
        Hidden [String[]] $Names = ("Gateway Server Computers Users Service" -Split " ")
        [Object] $Stack
        SmTemplate()
        {
            $This.Stack = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Stack += [SmTemplateItem]::New($Name,1)
            }
        }
    }

    Class Topology
    {
        [String] $Type
        [String] $DistinguishedName
        [Bool]   $Exists
        [String] $Name
        [String] $Location
        [String] $Region
        [String] $Country
        [String] $Postal
        [String] $TimeZone
        [String] $SiteLink
        [String] $SiteName
        [String] $Network
        [String] $Prefix
        [String] $Netmask
        [String] $Start
        [String] $End
        [String] $Range
        [String] $Broadcast
        Topology([String]$Type,[String]$DN,[Object]$Site)
        {
            $This.Type              = $Type
            $This.DistinguishedName = @{Gateway="CN=$($Site.Name),$DN";Server="CN=dc1-$($Site.Postal),$DN"}[$Type]
            $Return                 = Get-ADObject -Filter * | ? DistinguishedName -match $This.DistinguishedName
            $This.Exists            = $Return -ne $Null
            $This.Name              = $Site.Name
            $This.Location          = $Site.Location
            $This.Region            = $Site.Region
            $this.Country           = $Site.Country
            $This.Postal            = $Site.Postal
            $This.TimeZone          = $Site.TimeZone
            $This.SiteLink          = $Site.SiteLink
            $This.SiteName          = $Site.SiteName
            $This.Network           = $Site.Network
            $This.Prefix            = $Site.Prefix
            $This.Netmask           = $Site.Netmask
            $This.Start             = $Site.Start
            $This.End               = $Site.End
            $This.Range             = $Site.Range
            $This.Broadcast         = $Site.Broadcast
        }
    }

    Class DsShare
    {
        [String]$Name
        [String]$Root
        [Object]$Share
        [String]$Description
        [String]$Type
        DsShare([Object]$Drive)
        {
            $This.Name        = $Drive.Name
            $This.Root        = $Drive.Path
            $This.Share       = Get-SMBShare | ? Path -eq $Drive.Path | % Name
            $This.Description = $Drive.Description
            If (Test-Path "$($This.Root)\PSDResources")
            {
                $This.Type    = "PSD"
            }
            Else
            {
                $This.Type    = "MDT"
            }
        }
        DsShare([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
        {
            If (Get-SMBShare -Name $Share -EA 0)
            {
                Throw "Share name is already assigned"
            }

            $This.Name        = $Name
            $This.Root        = $Root
            $This.Share       = $Share
            $This.Description = $Description
            $This.Type        = @("MDT","PSD","-")[$Type]
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
        Certificate([String]$Organization,[String]$CommonName)
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

    Class VmSelect
    {
        [String] $Type
        [String] $Name
        [Bool]   $Create
        VmSelect([Object]$Item)
        {
            $This.Type   = $Item.Type
            $This.Name   = $Item.Name
            $This.Create = 1
        }
    }

    Class VmTest
    {
        [Object] $Name
        [Bool] $Exists
        VmTest([String]$Name)
        {
            $This.Name   = $Name
            $Return      = Get-VM -Name $Name -EA 0
            $This.Exists = $Return -ne $Null
        }
    }

    Class VmController
    {
        [String]$Name
        [String]$Status
        [String]$Username
        [String]$Credential
        VmController([String]$ID)
        {
            If ($ID -eq "localhost")
            {
                $ID = $Env:ComputerName
            }

            $This.Name       = Resolve-DNSName $ID | Select-Object -First 1 | % Name
            $This.Status     = Get-Service -Name vmms | % Status
            $This.Username   = $Env:Username
            $This.Credential = Get-Credential $Env:Username
        }
        VmController([String]$ID,[Object]$Credential)
        {
            If ($ID -eq "localhost")
            {
                $ID = $Env:ComputerName
            }

            $This.Name       = Resolve-DNSName $ID | Select-Object -First 1 | % Name
            $This.Status     = Get-Service -Name vmms -ComputerName $ID | % Status
            $This.Username   = $Credential.Username
            $This.Credential = $Credential
        }
    }

    Class VMObject
    {
        [Object]$Item
        [Object]$Name
        [Double]$MemoryStartupBytes
        [Object]$Path
        [Object]$NewVHDPath
        [Double]$NewVHDSizeBytes
        [Object]$Generation
        [Object]$SwitchName
        VMObject([Object]$Item,[UInt32]$Mem,[UInt32]$HD,[UInt32]$Gen,[String]$Switch)
        {
            $This.Item               = $Item
            $This.Name               = $Item.Name
            $This.MemoryStartupBytes = ([UInt32]$Mem)*1048576
            $This.Path               = "{0}\$($Item.Name).vmx"
            $This.NewVhdPath         = "{0}\$($Item.Name).vhdx"
            $This.NewVhdSizeBytes    = ([UInt32]$HD)*1073741824
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

            New-VM @Object -Verbose
            $Ct = @{Gateway=1;Server=2}[$This.Item.Type]
            Set-VMProcessor -VMName $This.Name -Count $Ct -Verbose
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

    Class ImageLabel
    {
        [String] $Name
        [String] $Index
        ImageLabel([Object]$ImageFile)
        {
            $This.Name  = $ImageFile.Name
            $This.Index = $ImageFile.Selected -join ","
        }
    }

    Class ImageSlot
    {
        Hidden [Object] $ImageFile
        Hidden [Object] $Arch
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [String] $Size
        [UInt32] $Architecture
        ImageSlot([Object]$ImageFile,[Object]$Arch,[Object]$Slot)
        {
            $This.ImageFile    = $ImageFile
            $This.Arch         = $Arch
            $This.Index        = $Slot.ImageIndex
            $This.Name         = $Slot.ImageName
            $This.Description  = $Slot.ImageDescription
            $This.Size         = "{0:n2} GB" -f ([Double]($Slot.ImageSize -Replace "(,|bytes|\s)","")/1073741824)
            $This.Architecture = @(86,64)[$Arch.Architecture -eq 9]
        }
    }

    Class ImageFile
    {
        [UInt32]      $Index
        [String]       $Type
        [String]       $Name
        [String]       $Path
        [Object[]]  $Content
        [UInt32[]] $Selected
        ImageFile([UInt32]$Index,[String]$Path)
        {
            $This.Index    = $Index
            $This.Name     = $Path | Split-Path -Leaf
            $This.Path     = $Path
            $This.Content  = @( )
            $This.Selected = @( )
        }
        LoadContent([Object[]]$Content)
        {
            $This.Type     = @("Client","Server")[$Content[0].Name -match "Server"]
            $This.Content  = $Content
        }
        LoadSelection([UInt32[]]$Index)
        {
            $This.Selected = @( )
            
            If (!($This.Content))
            {
                [System.Windows.MessageBox]::Show("Content has not been loaded yet","Image Error")
            }

            $This.Selected = @( $Index )
        }
    }

    Class ImageStack
    {
        [String] $Source
        [String] $Target
        [Object] $Store
        [Object] $Queue
        [Object] $Swap
        [Object] $Output
        ImageStack([String]$Source)
        {
            If (!(Test-Path $Source))
            {
                Throw "Invalid source path"
            }

            $This.Source = $Source
            $This.Store  = @( )

            ForEach ( $Item in Get-ChildItem $This.Source *.iso )
            {
                $This.Store += [ImageFile]::New($This.Store.Count,$Item.FullName)
            }

            If ( $This.Store.Count -eq 0 )
            {
                [System.Windows.MessageBox]::Show("No ISO's detected")
            }
        }
        LoadIso([UInt32]$Index)
        {
            If ( $This.Store.Count -eq 0 )
            {
                [System.Windows.MessageBox]::Show("No ISO's loaded")
                Break
            }
            
            $ImageFile = $This.Store[$Index]
            Write-Theme "Loading [~] [$($ImageFile.Name)]"
            $ImageFile.Path | Get-DiskImage | ? { !$_.Attached } | Mount-DiskImage

            $Letter = $ImageFile.Path | Get-DiskImage | Get-Volume | % DriveLetter
            $Path   = "${Letter}:\sources\install.wim"
            If (!(Test-Path $Path))
            {
                [System.Windows.MessageBox]::Show("Not a valid Windows Iso")
                $ImageFile.Path | Dismount-DiskImage
            }
            Else
            {
                $Arch    = Get-WindowsImage -ImagePath $Path -Index 1
                $Content = Get-WindowsImage -ImagePath $Path | % { [ImageSlot]::New($ImageFile.Path,$Arch,$_) }
                $ImageFile.LoadContent($Content)
            }
        }
        UnloadIso([UInt32]$Index)
        {
            $ImageFile = $This.Store[$Index]
            Dismount-DiskImage $ImageFile.Path
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

                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

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
        Static [String] $Tab = @(Get-Content $Home\Desktop\FEDeploymentShare.Xaml)
    }

    Class VmStack
    {
        [Object] $Host
        [Object] $Switch
        [Object] $External
        [Object] $Internal
        VmStack([Object]$VmHost,[Object]$VmSwitch)
        {
            $This.Host     = $VmHost
            $This.Switch   = $VmSwitch
            $This.External = $Vmswitch | ? SwitchType -eq External
            $This.Internal = $Vmswitch | ? SwitchType -eq Internal
        }
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
        [Object]        $Credential
        [Object]          $Template
        [String]        $SearchBase
        [Object]               $Win
        [Object]               $Reg
        [Object]            $Config
        [Object]                $IP
        [Object]              $Dhcp
        [Object]            $Drives
        [Object]        $EventPorts
        [Object]      $SiteLinkList
        [Object]          $SiteList
        [Object]        $SubnetList
        [Object]            $OUList
        [Object]        $SmTemplate
        [Object]            $Domain
        [Object]           $Network
        [Object]           $Sitemap
        [Object]           $Gateway
        [Object]            $Server
        [Object]           $Service
        [Object]              $ADDS
        [Object]           $Virtual
        [Object]                $Vm
        [Object]                $Sw
        [Object]                $Gw
        [Object]                $Sr
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

            $This.IP         = Get-NetIPAddress | % IPAddress
            $This.DHCP       = @{ 

                ScopeID      = Get-DHCPServerV4Scope | % ScopeID
                Options      = Get-DHCPServerV4OptionValue | Sort-Object OptionID
            }

            $This.SmTemplate = [SmTemplate]::New().Stack
            $This.Domain     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Network    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Sitemap    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Gateway    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Server     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Image      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Update     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Share      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.ADDS       = @{ 

                Gateway      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                Server       = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            }
            $This.Virtual    = @{ 

                Gateway      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                Server       = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            }

            $This.OUList     = Get-ADObject -Filter * | ? ObjectClass -eq OrganizationalUnit
        }
        [Void] GetSiteList()
        {
            $This.Sitelist      = Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetSiteLinkList()
        {
            $This.SitelinkList  = Get-ADObject -LDAPFilter "(objectClass=siteLink)" -Searchbase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetSubnetList()
        {
            $This.SubnetList    = Get-ADObject -LDAPFilter "(objectClass=subnet)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetOUList()
        {
            $This.OUList        = Get-ADObject -LDAPFilter "(objectClass=OrganizationalUnit)" -SearchBase $This.SearchBase 
        }
        [Object] NewCertificate()
        {
            Return @( [Certificate]::New($This.Org,$This.CN) )
        }
        [Void] LoadSite([String]$Organization,[String]$CommonName)
        {
            $This.Org           = $Organization
            $This.CN            = $CommonName
            $This.Template      = $This.NewCertificate()
            $This.SearchBase    = "DC=$( $CommonName.Split(".") -join ",DC=" )"

            $This.AddSiteName($This.Template.Postal)
            $This.GetSiteList()
            $This.GetSiteLinkList()
            $This.GetSubnetList()
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
            Return @( $List | % { [DcTopology]::New($This.SiteList,$_) } )
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
        [Void] AddSubnet([String]$Prefix) # Add further error handling on input
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
            Return @( $List | % { [NwTopology]::New($This.SubnetList,$_) } )
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
        [Void] LoadSitemap()
        {
            If ($This.Network.Count -lt $This.Domain.Count)
            {
                Throw "Insufficient networks"
            }

            $This.Sitemap = @( )

            ForEach ($X in 0..($This.Domain.Count - 1))
            {
                $This.Sitemap += [Site]::New($This.Domain[$X],$This.Network[$X])
            }
        }
        [Void] RemoveGateway([String]$DistinguishedName)
        {
            If ( $This.Gateway.Count -gt 1 )
            {
                If ($DistinguishedName -in $This.Gateway.DistinguishedName)
                {
                    $This.Gateway = @( $This.Gateway | ? DistinguishedName -ne $DistinguishedName )
                }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("Invalid operation, only one gateway remaining","Error")
            }
        }
        [Void] RemoveServer([String]$DistinguishedName)
        {
            If ( $This.Server.Count -gt 1 )
            {
                If ($DistinguishedName -in $This.Server.DistinguishedName)
                {
                    $This.Server = @( $This.Server | ? DistinguishedName -ne $DistinguishedName )
                }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("Invalid operation, only one gateway remaining","Error")
            }
        }
        [Void] LoadImagePath([String]$ImagePath)
        {
            If ((Test-Path $ImagePath) -and (Get-ChildItem $ImagePath *.iso).Count -gt 0 )
            {
                $This.Image = [ImageStack]::New($ImagePath)
            }
        }
        [Object[]] LoadUpdate([String]$Path)
        {
            Return @( Get-ChildItem $Path -Recurse | ? Extension -match .msu | % FullName )
        }
        [Void] LoadDrives([Object[]]$Drives)
        {
            $This.Drives = $Drives
        }
        [UInt32] GetNextEventPort()
        {
            $Collect = $This.Drives | % { Get-ItemProperty "$($_.Name):" }
            Return @( 9800..9899 | ? { $_ % 2 -eq 0 } | ? { $_ -notin $Collect.MonitorEventPort } | Select-Object -First 1 )
        }
        [Object] Enumerate([Hashtable]$Object)
        {
            $Output = @( )
            ForEach ( $Item in $Object.GetEnumerator() )
            {     
                If ( $Item.Value.GetType().Name -eq "Hashtable" )
                {
                    $Output += "[$($Item.Name)]"
                    $Object.$($Item.Name).GetEnumerator() | % { $Output += "$($_.Name)=$($_.Value)" }
                    $Output += ""
                }
            
                Else
                {
                    $Output += "$($Item.Name)=$($Item.Value)"
                    $Output += ""
                }
            }
            Return $Output
        }
        [Object] Bootstrap([UInt32]$Type,[String]$NetBIOS,[String]$UNC,[String]$UserID,[String]$Password)
        {
            $Output = $Null
            If ($Type -eq 0)
            {
                $Output                = @{ 
                    Settings           = @{ 
                        Priority       = "Default" }; 
                    Default            = @{
                        DeployRoot     = $UNC
                        UserID         = $UserID.Split("@")[0]
                        UserPassword   = $Password
                        UserDomain     = $NetBIOS
                        SkipBDDWelcome = "YES"
                    }
                }
            }

            If ($Type -eq 1)
            {
                $Output                = @{
                    Settings           = @{
                        Priority       = "Default"
                        Properties     = "PSDEployRoots"
                    }
                    Default            = @{ 
                        PSDeployRoots  = $UNC
                        UserID         = $UserID.Split("@")[0]
                        UserPassword   = $Password
                        UserDomain     = $NetBIOS
                    }
                }
            }

            Return $This.Enumerate($Output)
        }
        [Object] CustomSettings([UInt32]$Type,[String]$UNC,[String]$Org,[String]$NetBIOS,[String]$DNS,[String]$OU,[String]$UserID,[String]$Password)
        {
            $Output = $Null
            $Port   = $Null
            $Exists = Get-Item "$UNC\Control\CustomSettings.ini" -EA 0
            If ($Exists -eq $Null)
            {
                $Port = $This.GetNextEventPort()
            }
            If ($Exists -ne $Null)
            {
                $Port = [Regex]::Matches((Get-Content "$UNC\Control\CustomSettings.ini"),"\/\/.+\:\d{4}").Value.Split(":")[-1]
            }

            If ($Type -eq 0)
            {
                $Output                      = @{ 
                    Settings                 = @{
                        Priority             = "Default"
                        Properties           = "MyCustomProperty"
                    }
                    Default                  = @{
                        _SMSTSOrgName        = $Org
                        JoinDomain           = $DNS
                        DomainAdmin          = $UserID
                        DomainAdminPassword  = $Password
                        DomainAdminDomain    = $DNS
                        MachineObjectOU      = $OU
                        SkipDomainMembership = "YES" 
                        OSInstall            = "Y"
                        SkipCapture          = "NO"
                        SkipAdminPassword    = "YES"
                        SkipProductKey       = "YES"
                        SkipComputerBackup   = "NO"
                        SkipBitlocker        = "YES"
                        KeyboardLocale       = "en-US"
                        TimeZoneName         = "$(Get-Timezone | % ID)"
                        EventService         = "http://{0}:{1}" -f $UNC,$Port
                    }
                }
            }

            If ($Type -eq 1)
            {
                $Output                      = @{
                    Settings                 = @{
                        Priority             = "Default"
                        Properties           = "PSDeployRoots"
                    }
                    Default                  = @{
                        _SMSTSOrgName        = $Org
                        TimeZoneName         = "$(Get-Timezone | % ID)"
                        KeyboardLocale       = "en-US"
                        EventService         = "http://{0}:{1}" -f $UNC,$Port
                    }
                }
            }

            Return $This.Enumerate($Output)
        }
        [Object] PostConfig([String]$Key)
        {
            Return @("[Net.ServicePointManager]::SecurityProtocol = 3072",
            "Invoke-RestMethod https://github.com/mcc85s/FightingEntropy/blob/main/Install.ps1?raw=true | Invoke-Expression",
            "`$Module = Get-FEModule","`$Module.Role.LoadEnvironmentKey(`"$Key`")","`$Module.Role.Choco()")
        }
    }
    
    # These two variables do most of the work
    $Main                           = [Main]::New()
    $Xaml                           = [XamlWindow][FEDeploymentShareGUI]::Tab

    <# $Last = $Null
    $Xaml.Names | ? { $_ -notin "ContentPresenter","Border","ContentSite" } | % {
        
        $Item = $_[0,1] -join ""
        If ($Last -eq $Null -or $Item -ne $Last)
        {
            Write-Theme "$Item Tab" -Text
        }
        $X = "    # `$Xaml.IO.$_"
        $Y = $Xaml.IO.$_.GetType().Name 
        "{0}{1} # $Y" -f $X,(" "*(60-$X.Length) -join '')
        $Last = $_[0,1] -join ""
    
    } | Set-Clipboard #>

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
    # $Xaml.IO.CfgHyperV                # DataGrid
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
    $Xaml.IO.CfgHyperV.ItemsSource      = @( )
    $Xaml.IO.CfgWds.ItemsSource         = @( )
    $Xaml.IO.CfgMdt.ItemsSource         = @( )
    $Xaml.IO.CfgWinAdk.ItemsSource      = @( )
    $Xaml.IO.CfgWinPE.ItemsSource       = @( )
    $Xaml.IO.CfgIIS.ItemsSource         = @( )

    # [DataGrid]://PersistentDrives
    $Xaml.IO.DsAggregate.ItemsSource    = @( )

    # [CfgServices]://$Main.Config
    $Xaml.IO.CfgServices.ItemsSource    = @( $Main.Config )

    # [CfgMdt]://Installed ? -> Load persistent drives
    If ($Main.Config | ? Name -eq MDT | ? Value -eq $True)
    {   
        Get-MDTModule | Import-Module
        Restore-MDTPersistentDrive
        $Drives = Get-MDTPersistentDrive
        $Main.LoadDrives($Drives)
        ForEach ($Drive in $Main.Drives)
        {
            $Xaml.IO.DsAggregate.ItemsSource += [DsShare]$Drive
        }

        $Xaml.IO.DsAggregate.ItemsSource += [DsShare]::New("<New>","-",$Null,"-",2)
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
    # $Xaml.IO.DcTopology               # DataGrid
    # $Xaml.IO.DcGetTopology            # Button
    # $Xaml.IO.DcNewTopology            # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.DcAggregate.ItemsSource    = @( )
    $Xaml.IO.DcViewer.ItemsSource       = @( )
    $Xaml.IO.DcTopology.ItemsSource     = @( )

    # [Domain]://Events
    $Xaml.IO.DcGetSitename.Add_Click(
    {
        If (!$Xaml.IO.DcOrganization.Text)
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null organization entry","Error")
        }

        ElseIf (!$Xaml.IO.DcCommonName.Text)
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null common name entry","Error")
        }

        Else
        {   # $Main.LoadSite("Secure Digits Plus LLC","securedigitsplus.com")
            $Main.LoadSite($Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text)
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

    $Xaml.IO.DcGetTopology.Add_Click(
    {
        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopology]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmSiteCount.Text         = $Main.Domain.Count
    })
    
    $Xaml.IO.DcNewTopology.Add_Click(
    {
        ForEach ( $Item in $Xaml.IO.DcTopology.ItemsSource )
        {
            If ( $Item.Exists -eq 0 )
            {
                New-ADReplicationSite -Name $Item.Sitelink -Verbose
            }
        }

        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopology]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmSiteCount.Text         = $Main.Domain.Count
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
    # $Xaml.IO.NwTopology               # DataGrid
    # $Xaml.IO.NwGetNetwork             # Button
    # $Xaml.IO.NwNewNetwork             # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.NwAggregate.ItemsSource    = @( )
    $Xaml.IO.NwViewer.ItemsSource       = @( )
    $Xaml.IO.NwTopology.ItemsSource     = @( )

    # [Network]://Events
    $Xaml.IO.NwScopeLoad.Add_Click(
    {
        If ($Xaml.IO.NwScope.Text -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
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
            Return [System.Windows.MessageBox]::Show("Invalid subnet provided","Error")
        }
        ElseIf( $Prefix -in $Main.Network.Name )
        {
            Return [System.Windows.MessageBox]::Show("Prefix already exists","Error")
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
            Return [System.Windows.MessageBox]::Show("Select a subnet within the dialog box","Error")
        }
    })

    $Xaml.IO.NwGetSubnetName.Add_Click(
    {
        $Main.GetSubnetList()
        If (!$Main.SubnetList)
        {
            Throw "No valid networks detected"
        }
        
        $Xaml.IO.NwTopology.ItemsSource = @( )

        ForEach ( $Item in $Xaml.IO.NwAggregate.ItemsSource | % { [NwTopology]::New($Main.SubnetList,$_) } )
        {
            $Xaml.IO.NwTopology.ItemsSource += $Item 
            #[DGList]::New($Item.Name,$Item.DistinguishedName)
        }

        $Xaml.IO.SmNetworkCount.Text      = $Main.Network.Count 
    })

    $Xaml.IO.NwNewSubnetName.Add_Click(
    {
        ForEach ($Item in $Xaml.IO.NwTopology.ItemsSource)
        {
            If (!$Item.Exists)
            {
                New-ADReplicationSubnet -Name $Item.Name -Verbose
            }
        }

        $Tmp                              = @( $Main.GetNetwork($Main.Network) | % { [NwTopology]::New($Main.SubnetList,$_) } )
        $Xaml.IO.NwTopology.ItemsSource   = @( )
        $Xaml.IO.NwTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmNetworkCount.Text      = $Main.Network.Count
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Sitemap Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # $Xaml.IO.SmSiteCount               # TextBox
    # $Xaml.IO.SmNetworkCount            # TextBox
    # $Xaml.IO.SmLoadSitemap             # Button
    # $Xaml.IO.SmAggregate               # DataGrid
    # $Xaml.IO.SmTemplate                # DataGrid
    # $Xaml.IO.SmGetSitemap              # Button
    # $Xaml.IO.SmNewSitemap              # Button

    $Xaml.IO.SmTemplate.ItemsSource  = @( )
    $Xaml.IO.SmAggregate.ItemsSource = @( )
    $Xaml.IO.SmSiteLink.ItemsSource  = @( )
    $Xaml.IO.SmTopology.ItemsSource  = @( )

    $Xaml.IO.SmLoadSitemap.Add_Click(
    {
        If ($Main.Network.Count -lt $Main.Domain.Count)
        {
            Return [System.Windows.MessageBox]::Show("Insufficient networks","Error: Network count")
        }
    
        Else
        {
            $Main.LoadSitemap()
            $Xaml.IO.SmAggregate.ItemsSource = @( )
            $Xaml.IO.SmSiteLink.ItemsSource  = @( )
            $Xaml.IO.SmAggregate.ItemsSource = @( $Main.Sitemap )
            $Xaml.IO.SmSiteLink.ItemsSource  = @( $Main.Sitelinklist )
            If ( $Xaml.IO.SmAggregate.Items.Count -gt 0 )
            {
                $Xaml.IO.SmTemplate.ItemsSource  = @( $Main.SmTemplate )
            }
        }
    })

    $Xaml.IO.SmGetSitemap.Add_Click(
    {
        $Xaml.IO.SmTopology.ItemsSource = @( )

        ForEach ($Item in $Xaml.IO.SmAggregate.ItemsSource)
        {
            $Xaml.IO.SmTopology.ItemsSource += [SwTopologyBranch]::New("Main",$Item.Name,$Main.SearchBase,$Main.OUList)

            ForEach ($Name in $Xaml.IO.SmTemplate.Items | ? Create -eq 1)
            {
                $Xaml.IO.SmTopology.ItemsSource += [SwTopologyBranch]::New("Leaf","$($Item.Name)/$($Name.ObjectClass)",$Main.SearchBase,$Main.OUList)
            }
        }

        $Main.GetOUList()

        $Main.Sitelist                    = $Xaml.IO.SmTopology.ItemsSource
        $Main.Gateway                     = $Main.Sitelist | ? Name -eq Gateway
        $Main.Server                      = $Main.Sitelist | ? Name -eq Server

        $Xaml.IO.GwAggregate.ItemsSource  = $Main.Gateway
        $Xaml.IO.SrAggregate.ItemsSource  = $Main.Server
    })

    $Xaml.IO.SmNewSitemap.Add_Click(
    {
        ForEach ($X in 0..($Xaml.IO.SmTopology.ItemsSource.Count-1))
        {
            $Item               = $Xaml.IO.SmTopology.Items[$X]
            $Site               = $Main.Sitemap | ? Name -match ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ($Item.Exists -eq $False)
            {
                $OU             = @{

                    City        = $Site.Location
                    Country     = $Site.Country
                    Description = $Site.Hash.Network.Name
                    DisplayName = $Site.SiteName
                    PostalCode  = $Site.Postal
                    State       = $Site.Region
                    Name        = $Item.Name
                    Path        = $Item.DistinguishedName -Replace "OU=$($Item.Name),",""
                }        
                New-ADOrganizationalUnit @OU -Verbose
                Set-ADReplicationSiteLink -Identity $Xaml.IO.SmSiteLink.SelecteItem.DistinguishedName -SitesIncluded @{"Add"=$OU.Path} -Verbose
                $Location       = ("{0}, {1} {2}" -f $OU.City, $OU.State, $OU.PostalCode)
                Get-ADReplicationSubnet -Filter * | ? Name -match $OU.Description | Set-ADReplicationSubnet -Location $Location -Site $Item.Name -Verbose

                $Item.Exists    = $True
            }

            Else
            {
                Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
            }
        }
        
        $Main.Sitelist                    = $Xaml.IO.SmTopology.ItemsSource
        $Main.Gateway                     = $Main.Sitelist | ? Name -eq Gateway
        $Main.Server                      = $Main.Sitelist | ? Name -eq Server

        $Xaml.IO.GwAggregate.ItemsSource  = $Main.Gateway
        $Xaml.IO.SrAggregate.ItemsSource  = $Main.Server
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Gateway Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Gateway]://Variables
    # $Xaml.IO.GwSiteCount               # TextBox
    # $Xaml.IO.GwNetworkCount            # TextBox
    # $Xaml.IO.GwAggregate               # DataGrid
    # $Xaml.IO.GwAddGateway              # Button
    # $Xaml.IO.GwGateway                 # TextBox
    # $Xaml.IO.GwRemoveGateway           # Button
    # $Xaml.IO.GwViewer                  # DataGrid
    # $Xaml.IO.GwTopology                # DataGrid
    # $Xaml.IO.GwGetGateway              # Button
    # $Xaml.IO.GwNewGateway              # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.GwAggregate.ItemsSource    = @()
    $Xaml.IO.GwViewer.ItemsSource       = @()
    $Xaml.IO.GwTopology.ItemsSource     = @()

    # [Gateway]://Events

    $Xaml.IO.GwAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.GwViewer.ItemsSource     = @( )

        If ( $Xaml.IO.GwAggregate.SelectedIndex -gt -1 )
        {
            $Gateway                           = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.GwAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            
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
            $Tmp = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.GwAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ( $Tmp.Name -in $Main.Sitemap.Name)
            {
                $Main.RemoveGateway($Tmp.Name)
                $Xaml.IO.GwAggregate.ItemsSource = @( )
                $Xaml.IO.GwAggregate.ItemsSource = @( $Main.Gateway )
            }
        }
    })

    $Xaml.IO.GwGetGateway.Add_Click(
    {
        $Xaml.IO.GwTopology.ItemsSource = @( )
        $Main.ADDS.Gateway              = @( )

        ForEach ( $Item in $Xaml.IO.GwAggregate.ItemsSource )
        {
            $Main.ADDS.Gateway += $Main.Sitemap | ? Name -eq ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value) | % { [Topology]::New("Gateway",$Item.DistinguishedName,$_)}
        }

        $Xaml.IO.GwTopology.ItemsSource = @($Main.ADDS.Gateway)
    })

    $Xaml.IO.GwNewGateway.Add_Click(
    {
        ForEach ( $X in 0..($Xaml.IO.GwTopology.ItemsSource.Count - 1))
        {
            $Item = $Xaml.IO.GwTopology.Items[$X]
            If ($Item.Exists -eq $False)
            {
                $Split = $Item.DistinguishedName -Split ","
                $Path  = $Split[1..($Split.Count-1)] -join ","
                New-ADComputer -Name $Item.Name -DNSHostName $Item.Sitename -Path $Path -TrustedForDelegation:$True -Verbose
                $Item.Exists = $True
            }

            Else
            {
                Write-Host ("Item Exists [+] [{0}]" -f $Item.DistinguishedName) -F 10
            }
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Server Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Server]://Variables
    # $Xaml.IO.SrSiteCount               # TextBox
    # $Xaml.IO.SrNetworkCount            # TextBox
    # $Xaml.IO.SrAggregate               # DataGrid
    # $Xaml.IO.SrAddGateway              # Button
    # $Xaml.IO.SrGateway                 # TextBox
    # $Xaml.IO.SrRemoveGateway           # Button
    # $Xaml.IO.SrViewer                  # DataGrid
    # $Xaml.IO.SrTopology                # DataGrid
    # $Xaml.IO.SrGetGateway              # Button
    # $Xaml.IO.SrNewGateway              # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.SrAggregate.ItemsSource    = @()
    $Xaml.IO.SrViewer.ItemsSource       = @()
    $Xaml.IO.SrTopology.ItemsSource     = @()

    # [Server]://Events
    $Xaml.IO.SrAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.SrViewer.ItemsSource     = @( )

        If ( $Xaml.IO.SrAggregate.SelectedIndex -gt -1 )
        {
            $Server                           = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.SrAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            
            $List = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Server.$Item) 
            }

            $Xaml.IO.SrViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.SrRemoveServer.Add_Click(
    {
        If ( $Xaml.IO.SrAggregate.SelectedIndex -gt -1)
        {
            $Tmp = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.SrAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ( $Tmp.Name -in $Main.Sitemap.Name)
            {
                $Main.RemoveServer($Tmp.Name)
                $Xaml.IO.SrAggregate.ItemsSource = @( )
                $Xaml.IO.SrAggregate.ItemsSource = @( $Main.Server )
            }
        }
    })

    $Xaml.IO.SrGetServer.Add_Click(
    {
        $Xaml.IO.SrTopology.ItemsSource = @( )
        $Main.ADDS.Server               = @( )

        ForEach ( $Item in $Xaml.IO.SrAggregate.ItemsSource )
        {
            $Main.ADDS.Server += $Main.Sitemap | ? Name -eq ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value) | % { [Topology]::New("Server",$Item.DistinguishedName,$_)}
        }

        $Main.Adds.Server | % { $_.Name = $_.DistinguishedName.Split(",")[0].Replace("CN=","") }

        $Xaml.IO.SrTopology.ItemsSource = @($Main.ADDS.Server)
    })

    $Xaml.IO.SrNewServer.Add_Click(
    {
        ForEach ( $X in 0..($Xaml.IO.SrTopology.ItemsSource.Count - 1))
        {
            $Item      = $Xaml.IO.SrTopology.Items[$X]
            $Split     = $Item.DistinguishedName -Split ","
            $Path      = $Split[1..($Split.Count-1)] -join ","
            $Item.Name = $Split[0].Replace("CN=","")
            $Split     = $Item.SiteName -Split "."
            $DNSName   = $Item.Name,$Split[1..($Split.Count-1)] -join "."
            If ($Item.Exists -eq $False)
            {
                New-ADComputer -Name $Item.Name -DNSHostName $DNSName -Path $Path -TrustedForDelegation:$True -Verbose
                $Item.Exists = $True
            }

            Else
            {
                Write-Host ("Item Exists [+] [{0}]" -f $Item.DistinguishedName) -F 10
            }
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Virtual Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # $Xaml.IO.VmSelect                  # DataGrid
    # $Xaml.IO.VmHostSelect              # Button
    # $Xaml.IO.VmHost                    # TextBox
    # $Xaml.IO.VmPopulate                # Button
    # $Xaml.IO.VmGateway                 # DataGrid
    # $Xaml.IO.VmGatewayScriptSelect     # Button
    # $Xaml.IO.VmGatewayScript           # TextBox
    # $Xaml.IO.VmGatewayImageSelect      # Button
    # $Xaml.IO.VmGatewayImage            # TextBox
    # $Xaml.IO.VmGatewayMemory           # TextBox
    # $Xaml.IO.VmGatewayDrive            # TextBox
    # $Xaml.IO.VmServer                  # DataGrid
    # $Xaml.IO.VmServerScriptSelect      # Button
    # $Xaml.IO.VmServerScript            # TextBox
    # $Xaml.IO.VmServerImageSelect       # Button
    # $Xaml.IO.VmServerImage             # TextBox
    # $Xaml.IO.VmServerMemory            # TextBox
    # $Xaml.IO.VmServerDrive             # TextBox
    # $Xaml.IO.VmGetArchitecture         # Button
    # $Xaml.IO.VmNewArchitecture         # Button

    $Xaml.IO.VmSelect.ItemsSource        = @( )
    $Xaml.IO.VmHostSelect.Add_Click(
    {
        If ($Xaml.IO.VmHost.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter a server hostname or IP address","Error")
        }

        ElseIf ((Test-Connection -ComputerName $Xaml.IO.VmHost.Text -Count 1 -EA 0) -eq $Null)
        {
            Return [System.Windows.Messagebox]::Show("Not a valid server hostname or IP Address","Error")
        }

        Write-Host "Retrieving [~] VMHost"

        If ( $Xaml.IO.VmHost.Text -in @("localhost";$Main.IP))
        {
            $Main.Vm    = [VmStack]::New((Get-VMHost),(Get-VMSwitch))
            If (Get-Service -Name vmms -EA 0 | ? Status -ne Running)
            {
                Return [System.Windows.MessageBox]::Show("The Hyper-V Virtual Machine Management service is not (installed/running)","Error")
            }

            $Xaml.IO.VmController.ItemsSource         = @([VmController]::New($Xaml.IO.VmHost.Text))
            $Xaml.IO.VmControllerConfigVM.ItemsSource = @( Get-VM | % Name )
        }
        Else
        {
            $Credential = Get-Credential
            $Main.Vm    = [VmStack]::New((Get-VMHost -ComputerName $Xaml.IO.VmHost.Text -Credential $Credential),
                                    (Get-VmSwitch -ComputerName $Xaml.IO.VmHost.Text -Credenttial $Credential))
            If (Get-Service -ComputerName $Xaml.IO.VmHost.Text -Credential $Credential -Name vmms -EA 0 | ? Status -ne Running)
            {
                Return [System.Windows.MessageBox]::Show("The Hyper-V Virtual Machine Management service is not (installed/running)","Error")
            }

            $Xaml.IO.VmController.ItemsSource         = [VmController]::New($Xaml.IO.VmHost.Text,$Credential)
            $Xaml.IO.VmControllerConfigVM.ItemsSource = @( Get-VM -ComputerName $$Xaml.IO.VmHost.Text -Credential $Credential )
        }
        
        $Xaml.IO.VmControllerSwitch.ItemsSource   = @( $Main.Vm.External | % Name )
        $Xaml.IO.VmSelect.ItemsSource    = @( )
        $Collect                         = @( )

        If ( $Main.ADDS.Gateway.Count -gt 0 )
        {
            $Main.ADDS.Gateway           | % { $Collect += $_ }
        }

        If ( $Main.ADDS.Server.Count -gt 0 )
        {
            $Main.ADDS.Server            | % { $Collect += $_ }
        }

        $Xaml.IO.VmSelect.ItemsSource    = @([VmSelect[]]$Collect)

        
        Write-Host "Retrieved [+] VMHost"
    })

    $Xaml.IO.VmControllerSwitch.Add_SelectionChanged(
    {
        $NetRoute = Get-NetAdapter | ? Name -match $Xaml.IO.VmControllerSwitch.SelectedItem | Get-NetRoute -AddressFamily IPV4
        $Xaml.IO.VmControllerNetwork.Text = $NetRoute | ? NextHop -eq 0.0.0.0 | Select-Object -Last 1 | % DestinationPrefix
        $Xaml.IO.VmControllerGateway.Text = $NetRoute | ? NextHop -ne 0.0.0.0 | % NextHop
    })

    $Xaml.IO.VmGatewayScriptSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }

        $Xaml.IO.VmGatewayScript.Text = $Item.FileName
    })

    $Xaml.IO.VmGatewayImageSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }
    
        $Xaml.IO.VmGatewayImage.Text = $Item.FileName
    })

    $Xaml.IO.VmServerScriptSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }

        $Xaml.IO.VmServerScript.Text = $Item.FileName
    })

    $Xaml.IO.VmServerImageSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }
    
        $Xaml.IO.VmServerImage.Text = $Item.FileName
    })

    $Xaml.IO.VmGatewayMemory.Text        = "2048"
    $Xaml.IO.VmGatewayDrive.Text         = "20"
    $Xaml.IO.VmServerMemory.Text         = "4096"
    $Xaml.IO.VmServerDrive.Text          = "100"

    $Xaml.IO.VMGetArchitecture.Add_Click(
    {
        $Main.Virtual.Gateway            = @( )
        $Main.Virtual.Server             = @( )

        ForEach ( $Item in $Xaml.IO.VmSelect.Items )
        {
            Switch($Item.Type)
            {
                Gateway 
                { 
                    If ($Item.Create -eq 1 )
                    {
                        $Main.Virtual.Gateway += $Main.Adds.Gateway | ? Name -eq $Item.Name
                    } 
                }
                Server  
                { 
                    If ($Item.Create -eq 1 )
                    {     
                        $Main.Virtual.Server  += $Main.Adds.Server | ? Name -eq $Item.Name
                    } 
                }
            }
        }

        $Xaml.IO.VmGateway.ItemsSource   = @($Main.Virtual.Gateway | % { [VmTest]$_.Name } )
        $Xaml.IO.VmServer.ItemsSource    = @($Main.Virtual.Server  | % { [VmTest]$_.Name } )
    })
    
    # $Xaml.IO.DcOrganization.Text = "Secure Digits Plus LLC"; $Xaml.IO.DcCommonName.Text = "securedigitsplus.com"; $Xaml.IO.NwScope.Text = "172.16.0.0/19"
    
    $Xaml.IO.VMNewArchitecture.Add_Click(
    {
        If (!$Xaml.IO.VmGatewayImage.Text)
        {
            Return [System.Windows.MessageBox]::Show("Must input an image to install virtual gateway(s)","Error")
        }

        If (!(Test-Path $Xaml.IO.VmGatewayImage.Text) -or $Xaml.IO.VmGatewayImage.Text.Split(".")[-1] -ne "iso" )
        {
            Return [System.Windows.MessageBox]::Show("Not a valid image (path/file)","Error")
        }

        If (!$Xaml.IO.VmServerImage.Text)
        {
            Return [System.Windows.MessageBox]::Show("Must input an image to install virtual server(s)","Error")
        }

        If (!(Test-Path $Xaml.IO.VmServerImage.Text) -or $Xaml.IO.VmServerImage.Text.Split(".")[-1] -ne "iso" )
        {
            Return [System.Windows.MessageBox]::Show("Not a valid image (path/file)","Error")
        }

        If(!($Main.Vm))
        {
            Return [System.Windows.MessageBox]::Show("Must have Hyper-V running","Error")
        }

        $Main.Credential    = Get-Credential root

        # Create the virtual switches
        Write-Theme "Deploying [~] [VMSwitch[]]" 14,6,15
        $Main.Sw = @( )
        ForEach ( $X in 0..($Main.Virtual.Gateway.Count-1))
        {
            $Sw = $Main.Virtual.Gateway[$X]
            If (Get-VMSwitch -Name $Sw.Name -EA 0)
            {
                Write-Theme "Removing [~] [Switch: $($Sw.Name)]" 12,4,15
                Remove-VMSwitch -Name $Sw.Name -Verbose -Confirm:$False -Force
            }

            Write-Theme "Creating [~] [Switch: $($Sw.Name)]" 9,1,15
            $Main.Sw += New-VMSwitch -Name $Sw.Name -SwitchType Internal -Verbose
        }
        Write-Theme "Deployed [+] [VMSwitch[]]" 10,2,15
        Start-Sleep 2

        Write-Theme "Updating [~] `$Main.Vm.Switch"
        $Main.Vm.Switch = Get-VMSwitch

        # Create the virtual gateways
        Write-Theme "Creating [~] [VMGateway[]]" 14,6,15
        $Main.Gw = @( )
        ForEach ( $X in 0..($Main.Virtual.Gateway.Count-1))
        {
            $Gw = $Main.Virtual.Gateway[$X]
            If (Get-VM -Name $Gw.Name -EA 0)
            {
                Write-Theme "Removing [~] [Gateway: $($Gw.Name)]" 12,4,15
                Remove-VM -Name $Gw.Name -Verbose -Confirm:$False -Force
            }

            Write-Theme "Creating [~] [Gateway: $($Gw.Name)]" 9,1,15
            $Item     = [VMObject]::New($Gw,$Xaml.IO.VmGatewayMemory.Text,$Xaml.IO.VmGatewayDrive.Text,1,$Main.Vm.External.Name)
            $Item.New($Main.VM.Host.VirtualMachinePath)
            Add-VMNetworkAdapter -VMName $Item.Name -SwitchName $Item.Name -Verbose
            $Item.LoadISO($Xaml.IO.VmGatewayImage.Text)
            $Item.Start()
            $Item.Stop()
            $Main.Gw += $Item
        }

        Write-Theme "Created [+] [VMGateway[]]" 10,2,15
        Start-Sleep 2

        # Create the virtual servers
        Write-Theme "Creating [~] [VMServer[]]" 14,6,15
        $Main.Sr = @( )
        ForEach ( $X in 0..($Main.Virtual.Server.Count-1))
        {
            $Sr = $Main.Virtual.Server[$X]
            If (Get-VM -Name $Sr.Name -EA 0)
            {
                Write-Theme "Removing [~] [Server: $($Sr.Name)]" 12,4,15
                Remove-VM -Name $Sr.Name -Verbose -Confirm:$False -Force
            }
                    
            Write-Theme "Creating [~] [Server: $($Sr.Name)]" 9,1,15
            $Item     = [VMObject]::New($Sr,$Xaml.IO.VmServerMemory.Text,$Xaml.IO.VmServerDrive.Text,2,$Main.Sw[$X].Name)
            $Item.New($Main.VM.Host.VirtualMachinePath)
            $VM       = Get-VM -Name $Item.Name
            $VM       | Add-VMDVDDrive -Verbose
            $Item.LoadISO($Xaml.IO.VmServerImage.Text)
            $Item.Start()
            $Item.Stop()
            $BootOrder = $VM | Get-VMFirmware | % { $_.BootOrder[2,0,1] }
            $VM        | Set-VMFirmware -BootOrder $BootOrder -Verbose
            $Main.Sr  += $Item
        }

        Write-Theme "Created [+] [VMServer[]]" 10,2,15
        Start-Sleep 2

        # Preparing [DNS/DHCP/MacAddress Stuff]
        $DNS      = Get-DNSServerResourceRecord -Zonename $Main.CN

        ForEach ( $Name in $Main.Gw.Name )
        {
            $DNS  | ? HostName -match $Item | Remove-DNSServerResourceRecord -ZoneName $Main.CN -Verbose -Confirm:$False -Force
        }

        $ScopeID  = Get-DhcpServerv4Scope
        $DHCP     = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID

        $DHCP     | ? Name -match "((\w{2}-){3}(\d{5})|OPNsense)" | Remove-DHCPServerV4Reservation -Verbose -EA 0

        $DHCP     = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID
        $Slot     = $DHCP[-1].IPAddress.ToString().Split(".")

        If ( $Main.Gw.Count -gt 1 )
        {
            $Spot    = [UInt32]$Slot[3]

            ForEach ( $X in 0..($Main.Gw.Count - 1))
            {
                $Reserve = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID
                $Gw      = $Main.Gw[$X]
                $Item    = $Gw.Item
                $Mac     = Get-VMNetworkAdapter -VMName $Gw.Name | ? SwitchName -ne $Gw.Name | % MacAddress

                Write-Theme "Adding [~] DHCP Reservation [$($Item.Network)/$($Item.Prefix)]@[$($Item.Sitename)]" 10,2,15
                $Spot ++
                $Obj             = @{
        
                    ScopeID      = $ScopeID.ScopeID
                    IPAddress    = @($Slot[0,1,2];$Spot) -join '.'
                    ClientID     = $Mac
                    Name         = $Item.SiteLink
                    Description  = "[$($Item.Network)/$($Item.Prefix)]@[$($Item.Sitename)]"
                }
                Add-DhcpServerV4Reservation @Obj -Verbose
            }
        }

        Write-Theme "Added [+] DHCP Reservations"

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Gateway Template ]____________________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Writing [~] Gateway Objects"

        $Date       = Get-Date -UFormat %Y%m%d
        $Path       = "$Home\Desktop\VM($Date)\GW"
        $VMX        = $Main.Gw
        $Filter     = $Main | Select-Object CN, SearchBase, VM | ConvertTo-Json
        $Credential = $Main.Credential
        If (!(Test-Path $Path))
        {
            New-Item $Path -ItemType Directory -Verbose -Force
        }

        ForEach ( $X in 0..($Main.Sr.Count-1))
        {
            If (!(Test-Path "$Path\$X"))
            {
                New-Item "$Path\$X" -ItemType Directory -Verbose -Force
            }
            Set-Content -Path "$Path\$X\vmx.txt" -Value ( $VMX[$X] | ConvertTo-Json ) -Verbose -Force
            Set-Content -Path "$Path\$X\host.txt" -Value $Filter -Verbose -Force
            Export-CliXml -Path "$Path\$X\cred.txt" -InputObject $Credential -Verbose -Force
        }

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Server Template ]_____________________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Writing [~] Server Objects"

        $Date       = Get-Date -UFormat %Y%m%d
        $Path       = "$Home\Desktop\VM($Date)\SR"
        $VMX        = $Main.Sr
        $Filter     = $Main | Select-Object CN, SearchBase, VM | ConvertTo-Json
        $Credential = $Main.Credential
        If (!(Test-Path $Path))
        {
            New-Item $Path -ItemType Directory -Verbose -Force
        }

        ForEach ( $X in 0..($Main.Sr.Count-1))
        {
            If (!(Test-Path "$Path\$X"))
            {
                New-Item "$Path\$X" -ItemType Directory -Verbose -Force
            }
            Set-Content -Path "$Path\$X\vmx.txt" -Value ( $VMX[$X] | ConvertTo-Json ) -Verbose -Force
            Set-Content -Path "$Path\$X\host.txt" -Value $Filter -Verbose -Force
            Export-CliXml -Path "$Path\$X\cred.txt" -InputObject $Credential -Verbose -Force
        }

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Script Initialization  ]______________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Creating [~] Script Initialization"
    })

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
            Return [System.Windows.MessageBox]::Show("Invalid image root path","Error")
        }
    
        $Main.LoadImagePath($Xaml.IO.IsoPath.Text)
    
        If (!$Main.Image.Store)
        {
            Return [System.Windows.MessageBox]::Show("No images detected","Error")
        }
        Else
        {
            $Xaml.IO.IsoList.ItemsSource = @( $Main.Image.Store )
        }
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
            Return [System.Windows.MessageBox]::Show("No image selected","Error")
        }

        $Image = $Main.Image.Store[$Xaml.IO.IsoList.SelectedIndex]
        $Main.Image.LoadIso($Xaml.IO.IsoList.SelectedIndex)
        Do
        {
            Start-Sleep -Milliseconds 100
        }
        Until (Get-DiskImage $Image.Path | ? Attached)
        
        $Xaml.IO.IsoView.ItemsSource = $Main.Image.Store[$Xaml.IO.IsoList.SelectedIndex].Content
        $Xaml.IO.IsoList.IsEnabled       = 0
        $Xaml.IO.IsoDismount.IsEnabled   = 1
        Write-Theme "Mounting [$($Image.Path)]" 14,6,15
    })
    
    $Xaml.IO.IsoDismount.Add_Click(
    {
        $Image  = $Main.Image.Store[$Xaml.IO.IsoList.SelectedIndex]
        $Main.Image.UnloadIso($Xaml.IO.IsoList.SelectedIndex)
        Do
        {
            Start-Sleep -Milliseconds 100
        }
        Until (!(Get-DiskImage $Image.Path | ? Attached))

        $Xaml.IO.IsoView.ItemsSource         = $Null
        $Xaml.IO.IsoList.IsEnabled           = 1
        Write-Theme "Dismounting [$($Image.Path)]" 12,4,15

        $Image                               = $Null
    
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
            $Xaml.IO.WimIsoDown.IsEnabled   = 0
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
        If ($Xaml.IO.IsoList.SelectedItem.Path -in $Xaml.IO.WimIso.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("Image already selected","Error")
        }
    
        Else
        {
            $Image  = $Main.Image.Store[$Xaml.IO.IsoList.SelectedIndex]
            $Image.LoadSelection($Xaml.IO.IsoView.SelectedItems.Index)
            $Xaml.IO.WimIso.ItemsSource += [ImageLabel]::New($Image)
        }
    })
    
    $Xaml.IO.WimDequeue.Add_Click(
    {
        $Items = @( $Xaml.IO.WimIso.Items | ? Name -ne $Xaml.IO.WimIso.SelectedItem.Name )

        $Xaml.IO.WimIso.ItemsSource = @( )

        If ($Items)
        {
            $Xaml.IO.WimIso.ItemsSource = $Items
            $Items                      = $Null
        }
    
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled = 0
            $Xaml.IO.WimIso.ItemsSource = @( )
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
                            Get-ChildItem $Xaml.IO.WimPath.Text | Remove-Item -Recurse -Confirm:$False -Force -Verbose
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
    
        $Main.Image.Target = $Xaml.IO.WimPath.Text
    
        $X = 0
        ForEach ( $I in $Xaml.IO.WimIso.Items )
        {
            $Item = $Main.Image.Store | ? Name -eq $I.Name
            $Disk = Get-DiskImage -ImagePath $Item.Path
            If (!$Disk.Attached)
            {
                Write-Host "Mounting [~] $($Item.Path)"
                Mount-DiskImage -ImagePath $Item.Path -Verbose
                $Disk  = Get-DiskImage -ImagePath $Item.Path
            }

            $Path  = "{0}:\sources\install.wim" -f ($Disk | Get-Volume | % DriveLetter)

            ForEach ($U in $Item.Selected)
            {
                $Select = $Item.Content | ? Index -eq $U
                Switch($Item.Type)
                {
                    Server
                    {
                        $Year               = [Regex]::Matches($Select.Name,"(\d{4})").Value
                        Switch -Regex ($Select.Name) 
                        {
                            STANDARD
                            {
                                $Edition    = "Standard"
                                $Tag        = "SD" 
                            }
                            DATACENTER
                            {
                                $Edition    = "Datacenter"
                                $Tag        = "DC"
                            }
                        }
                        $DestinationName    = "Windows Server $Year $Edition (x64)"
                        $Label              = "{0}{1}" -f $Tag, $Year
                    }

                    Client
                    {
                        Switch -Regex ($Select.Name)
                        {
                            Education
                            {
                                $Tag        = "E"
                            }
                            Pro
                            {
                                $Tag        = "P"
                            }
                            Home
                            {
                                $Tag        = "H"
                            }
                        }
                        $DestinationName    = "{0} (x{1})" -f $Select.Name, $Select.Architecture
                        $Label              = "10{0}{1}" -f $Tag, $Select.Architecture
                    }
                }

                $ISO                        = @{

                    SourceIndex             = $U
                    SourceImagePath         = $Path
                    DestinationImagePath    = ("{0}\({1}){2}\{2}.wim" -f $Xaml.IO.WimPath.Text,$X,$Label)
                    DestinationName         = $DestinationName
                }

                New-Item ($Iso.DestinationImagePath | Split-Path -Parent) -ItemType Directory -Verbose

                Write-Host "Extracting [~] $($Iso.DestinationName)"
                Export-WindowsImage @ISO
                Write-Theme "Extracting [~] $($Iso.DestinationName)"
                $X ++
            }
            Get-DiskImage -ImagePath $Item.Path | Dismount-DiskImage
        }
        Write-Host "Complete [+] Images Collected"
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
    # $Xaml.IO.DsAggregate              # DataGrid

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
    $Xaml.IO.DsAggregate.Add_SelectionChanged(
    {
        $Item = $Xaml.IO.DsAggregate.SelectedItem
        If ( $Item.Name -match "(\<New\>)" )
        {
            $Xaml.IO.DsDriveName.Text          = ("FE{0:d3}" -f $Xaml.IO.DsAggregate.Items.Count)
            $Xaml.IO.DsRootPath.Text           = ""
            $Xaml.IO.DsShareName.Text          = ""
            $Xaml.IO.DsDescription.Text        = ("[FightingEntropy({0})][(2021.8.0)]" -f [char]960)
            $Xaml.IO.DsType.SelectedIndex      = 0
            $Xaml.IO.DsBootstrapPath.Text      = ""
            $Xaml.IO.DsCustomSettingsPath.Text = ""
            $Xaml.IO.DsPostConfigPath.Text     = ""
        }

        Else
        {
            $Xaml.IO.DsDriveName.Text          = $Item.Name
            $Xaml.IO.DsRootPath.Text           = $Item.Root
            $Xaml.IO.DsShareName.Text          = $Item.Share
            $Xaml.IO.DsDescription.Text        = $Item.Description
            $Xaml.IO.DsType.SelectedIndex      = $Item.Type
            $Xaml.IO.DsBootstrapPath.Text      = "$($Item.Root)\Control\Bootstrap.ini"
            $Xaml.IO.DsCustomSettingsPath.Text = "$($Item.Root)\Control\CustomSettings.ini"
            $Xaml.IO.DsPostConfigPath.Text     = "$($Item.Root)\Script\Install-FightingEntropy.ps1"
        }
    })

    $Xaml.IO.DsAddShare.Add_Click(
    {
        If ($Xaml.IO.DsDriveName.Text -notmatch "(\w|\d)+")
        {
            Return [System.Windows.MessageBox]::Show("Drive label can only contain alphanumeric characters","Error")
        }

        ElseIf ($Xaml.IO.DsRootPath.Text -in $Xaml.IO.DsAggregate.Items.Root )
        {
            Return [System.Windows.MessageBox]::Show("Selected path is already assigned to another deployment share","Error")
        }

        ElseIf ($Xaml.IO.DsRootPath | ? Text -in @("",$Null) )
        {
            Return [System.Windows.MessageBox]::Show("Selected path is invalid","Error")
        }

        ElseIf ($Xaml.IO.DsShareName.Text -in $Xaml.IO.DsAggregate.Items.Share)
        {
            Return [System.Windows.MessageBox]::Show("Selected share name is already assigned to another deployment share","Error")
        }

        Else
        {
            $Xaml.IO.DsAggregate.ItemsSource += [DsShare]::New($Xaml.IO.DsDriveName.Text,
            $Xaml.IO.DsRootPath.Text,
            $Xaml.IO.DsShareName.Text,
            $Xaml.IO.DsDescription.Text,
            $Xaml.IO.DsType.SelectedIndex)
        }
    })

    $Xaml.IO.DsRemoveShare.Add_Click(
    {
        If ( $Xaml.IO.DsAggregate.SelectedIndex -eq -1 )
        {
            Return [System.Windows.MessageBox]::Show("No share to remove...","Error")
        }

        ElseIf ($Xaml.IO.DsAggregate.SelectedItem.Name -eq "<New>")
        {
            Return [System.Windows.MessageBox]::Show("No deployment share selected","Error")
        }
        
        Else
        {
            $Items = @( $Xaml.IO.DsAggregate.ItemsSource | ? Name -ne $Xaml.IO.DsAggregate.SelectedItem.Name )
            $Xaml.IO.DsAggregate.ItemsSource = @( )
            $Xaml.IO.DsAggregate.ItemsSource = @( $Items )
        }
    })

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

    $Xaml.IO.DsGenerateBootstrap.Add_Click(
    {
        $Item = $Xaml.IO.DsAggregate.SelectedItem
        If ($Xaml.IO.DcNwNetBiosName.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Must enter the NetBIOS ID","Error")
        }
        ElseIf ($Xaml.IO.DsDcUsername.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin username","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin password","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -notmatch $Xaml.IO.DsDcConfirm.Password)
        {
            Return [System.Windows.Messagebox]::Show("Invalid password confirmation","Error")
        }
        Else
        {
            $Xaml.IO.DsBootstrap.Text = @($Main.Bootstrap($Item.Type,$Xaml.IO.DcNwNetBiosName.Text,$Item.Share,$Xaml.IO.DsDcUsername.Text,$Xaml.IO.DsDcPassword.Password))
        }
    }

    $Xaml.IO.DsGenerateCustomSettings.Add_Click(
    {
        $Item = $Xaml.IO.DsAggregate.SelectedItem
        If ($Xaml.IO.DcOrganization.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Invalid organization name","Error")
        }
        ElseIf($Xaml.IO.DsNwNetBiosName.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Invalid NetBIOS name","Error")
        }
        ElseIf($Xaml.IO.DsNwDnsName.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Invalid DNS name","Error")
        }
        ElseIf($Xaml.IO.DsNwMachineOUName.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Invalid computer OU designated","Error")
        }
        ElseIf ($Xaml.IO.DsDcUsername.Text -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin username","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -match $Null)
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin password","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -notmatch $Xaml.IO.DsDcConfirm.Password)
        {
            Return [System.Windows.Messagebox]::Show("Invalid password confirmation","Error")
        }

        $Xaml.IO.DsCustomSettings.Text = @($Main.CustomSettings($Item.Type,$Item.Share,$Xaml.IO.DcOrganization.Text,$Xaml.IO.DsNwNetBiosName.Text,
                                            $Xaml.IO.DsNwDnsName.Text,$Xaml.IO.DsNwMachineOUName.Text,$Xaml.IO.DsDcUsername.Text,$Xaml.IO.DsDcPassword.Password))
    })

    $Xaml.IO.DsGeneratePostConfig.Add_Click(
    {
        $Item = $Xaml.IO.DsAggregate.SelectedItem
        $Xaml.IO.DsPostConfig.Text = @($Main.GetPostConfig("\\$Env:ComputerName\$($Item.Share)\DSKey.csv"))
    }

    $Xaml.IO.DsSelectBootstrap.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsBootstrapPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsBootstrapPath.Text      = $Item.FileName
            $Xaml.IO.DsBootstrap.Text          = Get-Content $Item.Filename
        }
    })
    
    $Xaml.IO.DsSelectCustomSettings.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsCustomSettingsPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsCustomSettingsPath.Text = $Item.FileName
            $Xaml.IO.DsCustomSettings.Text     = Get-Content $Item.Filename
        }
    })

    $Xaml.IO.DsSelectPostConfig.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsPostConfigPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsPostConfigPath.Text     = $Item.FileName
            $Xaml.IO.DsPostConfig.Text         = Get-Content $Item.Filename
        }
    })

    $Xaml.IO.DsCreate.Add_Click(
    {
        If ($Xaml.IO.CfgServices.Items | ? Name -eq MDT | ? Value -ne $True)
        {
            Throw "Unable to initialize, MDT not installed"
        }

        ElseIf ($PSVersionTable.PSEdition -ne "Desktop")
        {
            Throw "Unable to initialize, use Windows PowerShell v5.1"
        }

        ElseIf($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a valid drive in the aggregate category box","Error")
        }

        ElseIf($Xaml.IO.DsAggregate.SelectedItem.Name -eq "<New>")
        {
            Return [System.Windows.MessageBox]::Show("Cannot use the <New> for the share, select another option","Error")
        }

        ElseIf ($Xaml.IO.DcOrganization.Text.Length -eq 0)
        {
            Return [System.Windows.MessageBox]::Show("Missing the organization name","Error")
        }

        ElseIf ($Xaml.IO.DcCommonName.Text.Length -eq 0)
        {
            Return [Systme.Windows.MessageBox]::Show("Missing the domain name/common name","Error")
        }

        ElseIf (!$Xaml.IO.DsDcUsername.Text)
        {
            Return [System.Windows.MessageBox]::Show("Missing the deployment share domain account name","Error")
        }

        ElseIf ($Xaml.IO.DsDcPassword.SecurePassword -notmatch $Xaml.IO.DsDcConfirm.SecurePassword)
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

        ElseIf (!(Get-ADOrganizationalUnit -Filter * | ? DistinguishedName -match $Xaml.IO.DsNwMachineOuName.Text))
        {
            Return [System.Windows.MessageBox]::Show("Invalid OU specified","Error")
        }

        ElseIf ($Xaml.IO.DsBootstrap.Text -match $Null)
        {
            Return [System.Windows.MessageBox]::Show("The bootstrap file was not generated or reviewed","Error")
        }

        ElseIf ($Xaml.IO.DsCustomSettings.Text -match $Null)
        {
            Return [System.Windows.MessageBox]::Show("The bootstrap file was not generated or reviewed","Error")
        }

        ElseIf ($Xaml.IO.DsPostconfig.Text -match $Null)
        {
            Return [System.Windows.MessageBox]::Show("The post config file was not generated or reviewed","Error")
        }

        Else
        {
            Write-Theme "Creating [~] Deployment Share"

            $Item = $Xaml.IO.DsAggregate.SelectedItem

            If (!(Test-Path $Item.Root))
            {
                New-Item $Item.Root -ItemType Directory -Verbose
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

            $MDT            = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \

            New-SMBShare @SMB
            New-PSDrive  @PSD -Verbose | Add-MDTPersistentDrive -Verbose

            If ($Item.Type -eq "PSD")
            {
                $ScriptRoot         = Get-PSDModule
                $ItemName           = "$($Item.Name:)"
                $ItemRoot           = $Item.Root
                $ItemShare          = $Item.Share

                # Create backup folder      
                Write-Host "Creating [~] backup folder"
                $Backup             = "$ItemRoot\Backup\Scripts"
                
                New-Item $Backup -ItemType Directory -Force -Verbose

                # Remove specific files
                Write-Host "Moving [~] unneeded files to backup location"
                ForEach ( $ItemX in "UDIWizard_Config.xml.app Wizard.hta Wizard.ico Wizard.css Autorun.inf BDD_Welcome_ENU.xml Credentials_ENU.xml Summary_Definition_ENU.xml DeployWiz_Roles.xsl" -Split " ")
                {   
                    $Path           = "$ItemRoot\Scripts\$ItemX"

                    If (Test-Path $Path)
                    {
                        Write-Host "Moving [~] $Path"
                        Move-Item -Path $Path -Destination "$Backup\$ItemX" -Verbose
                    }
                }

                # Cleanup old stuff from DeploymentShare
                ForEach ($ItemX in Get-ChildItem "$ItemRoot\Scripts" | ? Name -match "(vbs|wsf|DeployWiz|UDI|WelcomeWiz_)")
                {
                    Write-Host "Moving [~] $($ItemX.FullName)"
                    Move-Item -Path $ItemX.FullName -Destination "$Backup\$($ItemX.Name)" -Verbose
                }

                # Copy/Unblock PS1 Files
                Get-ChildItem "$ScriptRoot\Scripts" | ? Extension -match "(ps1|xaml)" | Copy-Item -Destination "$ItemRoot\Scripts" -Verbose

                # Copy/Unblock templates
                Get-ChildItem "$ScriptRoot\Templates" | Copy-Item -Destination "$ItemRoot\Templates" -Verbose

                # Copy/Unblock the modules
                Write-Host "Copying [~] PSD Modules to $ItemRoot......."
                ForEach ($File in "PSDGather PSDDeploymentShare PSDUtility PSDWizard" -Split " ")
                {
                    If (!(Test-Path "$ItemRoot\Tools\Modules\$File"))
                    {
                        New-Item "$ItemRoot\Tools\Modules\$File" -ItemType Directory -Verbose
                    }

                    Write-Host "Copying [~] Module:[$File] to $ItemRoot\Tools\Modules"
                    Copy-Item "$ScriptRoot\Scripts\$File.psm1" -Destination "$ItemRoot\Tools\Modules\$File" -Verbose
                }

                # Copy the PSProvider module files
                Write-Host "Copying [~] MDT provider files to $ItemRoot\Tools\Modules"
                If (!(Test-Path "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn"))
                {
                    New-Item "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn" -ItemType Directory -Verbose
                }

                ForEach ( $ItemX in "PSSnapIn" | % { "$_.dll $_.dll.config $_.dll-help.xml $_.Format.ps1xml $_.Types.ps1xml Core.dll Core.dll.config ConfigManager.dll" -Split " " } ) 
                {
                    Copy-Item "$Mdt\Bin\Microsoft.BDD.$ItemX" -Destination "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn" -Verbose
                }

                # Copy the provider template files
                Write-Host "Copying [~] PSD templates to $ItemRoot\Templates"
                If (!(Test-Path "$ItemRoot\Templates"))
                {
                    New-Item "$ItemRoot\Templates" -ItemType Directory -Verbose
                }

                ForEach ($ItemX in "Groups Medias OperatingSystems Packages SelectionProfiles TaskSequences Applications Drivers Groups LinkedDeploymentShares" -Split " ")
                {
                    Copy-Item "$MDT\Templates\$ItemX.xsd" "$ItemRoot\Templates" -Verbose
                }

                # Restore ZTIGather.XML
                Write-Host "Adding [~] ZTIGather.XML to correct folder"
                Copy-Item "$MDT\Templates\Distribution\Scripts\ZTIGather.xml" -Destination "$ItemRoot\Tools\Modules\PSDGather" -Verbose

                # Create folders
                Foreach ($ItemX in "Autopilot BootImageFiles\X86 BootImageFiles\X64 Branding Certificates CustomScripts DriverPackages DriverSources UserExitScripts BGInfo Prestart" -Split " ")
                {
                    Write-Host "Creating [~] [$ItemX] folder in $ItemShare\PSDResources"
                    New-Item "$ItemRoot\PSDResources\$ItemX" -ItemType Directory -Force -Verbose
                }

                # Copy PSDBackground to Branding folder
                Copy-Item -Path $ScriptRoot\Branding\PSDBackground.bmp -Destination $ItemRoot\PSDResources\Branding\PSDBackground.bmp -Force -Verbose

                # Copy PSDBGI to BGInfo folder
                Copy-Item -Path $ScriptRoot\Branding\PSD.bgi -Destination $ItemRoot\PSDResources\BGInfo\PSD.bgi -Force -Verbose

                # Copy BGInfo64.exe to BGInfo.exe
                Copy-Item -Path $ItemRoot\Tools\x64\BGInfo64.exe -Destination $ItemRoot\Tools\x64\BGInfo.exe -Verbose

                # Copy Prestart items
                Get-ChildItem $ScriptRoot\PSDResources\Prestart | Copy-Item -Destination $ItemRoot\PSDResources\Prestart -Verbose

                # Update the DeploymentShare properties
                If (!$Upgrade)
                {
                    Write-Host "Update [~] PSD Deployment Share properties"
                    86,64 | % { 

                        Set-ItemProperty $ItemName -Name "Boot.x$_.LiteTouchISOName" -Value "PSDLiteTouch_x$_.iso"
                        Set-ItemProperty $ItemName -Name "Boot.x$_.LiteTouchWIMDescription" -Value "PowerShell Deployment Boot Image (x$_)"
                        Set-ItemProperty $ItemName -Name "Boot.x$_.BackgroundFile" -Value "%DEPLOYROOT%\PSDResources\Branding\PSDBackground.bmp"
                    }

                    # Disable support for x86
                    Write-Host "Disable [~] Support for x86"
                    Set-ItemProperty $ItemName -Name "SupportX86" -Value "False"
                }

                # Relax Permissions on Deploymentfolder and DeploymentShare
                Write-Host "Relaxing [~] Permissons on $ItemShare"
                ForEach ($ItemX in "Users Administrators SYSTEM" -Split " ")
                {
                    icacls $ItemRoot /grant "`"$ItemX`":(OI)(CI)(RX)"
                }
                    
                Grant-SmbShareAccess -Name $ItemShare -AccountName "EVERYONE" -AccessRight Change -Force
                Revoke-SmbShareAccess -Name $ItemShare -AccountName "CREATOR OWNER" -Force

                Get-ChildItem $ItemRoot -Recurse | Unblock-File -Verbose
            }

            # Load Module / Share Drive Mount
            $Module                = Get-FEModule
            $Root                  = "$($PSD.Name):\"
            $Control               = "$($PSD.Root)\Control"
            $Script                = "$($PSD.Root)\Scripts"
            
            # Copies the background and logo if they were selected and are found
            ForEach ($File in $Xaml.IO.DsBrBackground.Text,$Xaml.IO.DsBrLogo.Text)
            {
                If (Test-Path $File)
                {
                    Copy-Item -Path $File -Destination $Script -Verbose

                    If ($File -eq $Key.Background)
                    {
                        $Key.Background = "$($PSD.NetworkPath)\Scripts\$($File | Split-Path -Leaf)"
                    }

                    If ($File -eq $Key.Logo)
                    {
                        $Key.Logo       = "$($PSD.NetworkPath)\Scripts\$($File | Split-Path -Leaf)"
                    }
                }
            }

            # For the PXE environment images
            ForEach ( $File in $Module.Control | ? Extension -eq .png )
            {
                Copy-Item -Path $File.Fullname -Destination $Script -Force -Verbose
            }

            # Copies custom template for FightingEntropy to post install/configure
            ForEach ( $File in $Module.Control | ? Name -match Mod.xml )
            {
                Copy-Item -Path $File.FullName -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
            }
            
            # [Collect Wim files/Images]
            Write-Theme "Collecting [~] images"
            $Images      = @( )
            
            # [Extract/order the WIM files and prime for MDT Injection]
            Get-ChildItem -Path $Xaml.IO.WimPath.Text -Recurse *.wim | % { 
                
                Write-Host "Processing [$($_.FullName)]"
                $Images += [WimFile]::New($Images.Count,$_.FullName) 
            }

            # [Import OS/TS to MDT Share]
            $OS          = "$($PSD.Name):\Operating Systems"
            $TS          = "$($PSD.Name):\Task Sequences"
            $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)][$($Item.Type)]"

            # [Create folders in the new MDT share]
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

            # [Inject the Wim files into the MDT share]
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
                    Name                = ( "{0} (x{1})" -f $Image.ImageName, $Image.Architecture)
                    Template            = "{0}{1}Mod.xml" -f $Item.Type, $Type
                    Comments            = $Comment
                    ID                  = $Image.Label
                    Version             = "1.0"
                    OperatingSystemPath = Get-ChildItem -Path $Path | ? Name -match $Image.Label | % { "{0}\{1}" -f $Path, $_.Name }
                    FullName            = $Xaml.IO.DcLmUsername.Text
                    OrgName             = $Xaml.IO.DcOrganization.Text
                    HomePage            = $Xaml.IO.DcBrWebsite.Text
                    AdminPassword       = $Xaml.IO.DcLmPassword.Password
                }

                Import-MDTTaskSequence @TaskSequence -Verbose
            }

            # [Clean up the Wim file directory]
            Write-Theme "OS/TS [+] Imported, removing Wim Swap directory" 11,3,15,0
            Remove-Item -Path $Xaml.IO.WimPath.Text -Recurse -Force -Verbose


            Write-Theme "Setting [~] Share properties [($Root)]"
            # Share Settings
            Set-ItemProperty $Root -Name Comments    -Value $("[FightingEntropy({0})]{1}[{2}]" -f [Char]960,(Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]"),$Item.Type ) -Verbose
            Set-ItemProperty $Root -Name MonitorHost -Value $HostName -Verbose

            # Image Names/Background
            ForEach ($x in 64,86)
            {
                $Names  = $X | % { "Boot.x$_" } | % { "$_.Generate{0}ISO $_.{0}WIMDescription $_.{0}ISOName $_.BackgroundFile" -f "LiteTouch" -Split " " }
                $Values = $X | % { "$($Module.Name)[$($Module.Version)][$($Item.Type)](x$_)" } | % { "True;$_;$_.iso;$($Xaml.IO.DsBrBackground.Text)" -Split ";" }
                0..3         | % { Set-ItemProperty -Path $Root -Name $Names[$_] -Value $Values[$_] -Verbose } 
            }

            $Encoding = New-Object System.Text.UTF8Encoding $False

            # [Bootstrap.ini]
            [System.IO.File]::WriteAllLines("$Control\Bootstrap.ini",$Xaml.IO.DsBootstrap.Text,$Encoding)

            # [CustomSettings.ini]
            [System.IO.File]::WriteAllLines("$Control\CustomSettings.ini",$Xaml.IO.DsBootstrap.Text,$Encoding)

            # [FightingEntropy Installation propogation]
            [System.IO.File]::WriteAllLines("$Script\Install-FightingEntropy.ps1",$Xaml.IO.DsPostConfig.Text,$Encoding)

            # [Propogate the variables as an environment keys for [server/client] child items to restore]
            $DS  = @($PSD.NetworkPath,$Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text,$Xaml.IO.DsBrBackground.Text,
                    $Xaml.IO.DsBrLogo.Text,$Xaml.IO.DsBrPhone.Text,$Xaml.IO.DsBrHours.Text,$Xaml.IO.DsBrWebsite.Text)
            $Key = [Key]$DS
        
            Set-Content -Path "$($PSD.Root)\DSKey.csv" -Value ($Key | ConvertTo-CSV) -Verbose

            # Update FEShare(MDT)
            Update-MDTDeploymentShare -Path $Root -Force -Verbose

            # Update/Flush FEShare(Images)
            $ImageLabel = Get-ItemProperty -Path $Root | % { 

                @{  64 = $_.'Boot.x64.LiteTouchWIMDescription'
                    86 = $_.'Boot.x86.LiteTouchWIMDescription' }
            }

            # Rename the Litetouch_ files
            Get-ChildItem -Path "$($Xaml.IO.DsRootPath.Text)\Boot" | ? Extension | % { 

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
            ForEach ( $Image in [BootImages]::New("$($Xaml.IO.DsRootPath.Text)\Boot").Images )
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
    $Xaml.IO.DsLmUsername.Text    = "Administrator"
    
    $Xaml.Invoke()
}
