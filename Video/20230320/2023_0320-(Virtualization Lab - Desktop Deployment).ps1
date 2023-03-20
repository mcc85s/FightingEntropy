<# 
[03/20/23]: [Virtualization Lab - Desktop Deployment]

Create a standard [Windows 10] installation using [Hyper-V] and
[PowerShell Direct], and then [import] user profile information
#>

Import-Module FightingEntropy

Function ImageController
{
    Class ImageLabel
    {
        [String]          $Name
        [String]          $Type
        [String]       $Version
        [String] $SelectedIndex
        [Object[]]     $Content
        ImageLabel([Object]$Selected,[UInt32[]]$Index)
        {
            $This.Name          = $Selected.Path
            $This.Type          = $Selected.Type
            $This.Version       = $Selected.Version
            $This.SelectedIndex = $Index -join ","
            $This.Content       = @($Selected.Content | ? Index -in $Index)
            ForEach ($Item in $This.Content)
            {
                $This.Type      = $Selected.Type
                $This.Version   = $Selected.Version
            }
        }
    }

    Class ImageSlot
    {
        Hidden [Object] $ImageFile
        Hidden [Object]      $Arch
        [UInt32]            $Index
        [String]             $Type
        [String]          $Version
        [String]             $Name
        [String]      $Description
        [String]             $Size
        [UInt32]     $Architecture
        [String]  $DestinationName
        [String]            $Label
        ImageSlot([Object]$ImageFile,[UInt32]$Arch,[String]$Type,[String]$Version,[Object]$Slot)
        {
            $This.ImageFile    = $ImageFile
            $This.Arch         = $Arch
            $This.Type         = $Type
            $This.Version      = $Version
            $This.Index        = $Slot.ImageIndex
            $This.Name         = $Slot.ImageName
            $This.Description  = $Slot.ImageDescription
            $This.Size         = "{0:n2} GB" -f ([Double]($Slot.ImageSize -Replace "(,|bytes|\s)","")/1073741824)
            $This.Architecture = @(86,64)[$Arch -eq 9]
            Switch -Regex ($This.Type)
            {
                Server
                {
                    $Year               = [Regex]::Matches($This.Name,"(\d{4})").Value
                    $ID                 = $This.Name -Replace "Windows Server \d{4} SERVER",''
                    $Edition, $Tag      = Switch -Regex ($ID) 
                    {
                        "^STANDARDCORE$"   { "Standard Core",  "SDX" }
                        "^STANDARD$"       { "Standard",        "SD" }
                        "^DATACENTERCORE$" { "Datacenter Core","DCX" }
                        "^DATACENTER$"     { "Datacenter",      "DC" }
                    }
                    $This.DestinationName    = "Windows Server $Year $Edition (x64)"
                    $This.Label              = "{0}{1}-{2}" -f $Tag, $Year, $This.Version
                }

                Default
                {
                    $ID                 = $This.Name -Replace "Windows 10 "
                    $Tag                = Switch -Regex ($ID)
                    {
                        "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                        "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                        "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                        "^Pro N$"            { "PRO_N"      } "^Pro Education$"     { "PRO_EDUC" }
                        "^Pro Education N$"  { "PRO_EDUC_N" } "^Pro for Work.+$"    { "PRO_WS"   }
                        "^Pro N for Work.+$" { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                    }
                    $This.DestinationName    = "{0} (x{1})" -f $This.Name, $This.Architecture
                    $This.Label              = "10{0}{1}-{2}" -f $Tag, $This.Architecture, $This.Version
                }
            }
        }
    }

    Class ImageFile
    {
        [UInt32]      $Index
        [UInt32]       $Arch
        [String]    $Version
        [String]       $Type
        [String]       $Name
        [String]       $Path
        [String]     $Letter
        [Object[]]  $Content
        ImageFile([UInt32]$Index,[String]$Path)
        {
            $This.Index     = $Index
            $This.Name      = $Path | Split-Path -Leaf
            $This.Path      = $Path
            $This.Content   = @( )
        }
        [Object] GetDiskImage()
        {
            Return @( Get-DiskImage -ImagePath $This.Path )
        }
        [String] DriveLetter()
        {
            Return @( $This.GetDiskImage() | Get-Volume | % DriveLetter )
        }
        MountDiskImage()
        {
            If ($This.GetDiskImage() | ? Attached -eq 0)
            {
                Mount-DiskImage -ImagePath $This.Path
            }

            Do
            {
                Start-Sleep -Milliseconds 100
            }
            Until ($This.GetDiskImage() | ? Attached -eq 1)

            $This.Letter = $This.DriveLetter()
        }
        DismountDiskImage()
        {
            Dismount-DiskImage -ImagePath $This.Path
        }
        GetWindowsImage([String]$Path)
        { 
            Get-WindowsImage -ImagePath $Path -Index 1 | % { 

                $This.Arch    = $_.Architecture
                $This.Version = $_.Version
                $This.Type    = $_.InstallationType
            }

            $This.Content     = Get-WindowsImage -ImagePath $Path | % { [ImageSlot]::New($Path,$This.Arch,$This.Type,$This.Version,$_) }
        }
    }

    Class ImageController
    {
        [String]   $Source
        [String]   $Target
        [Object] $Selected
        [Object]    $Store
        [Object]    $Queue
        [Object]     $Swap
        [Object]   $Output
        ImageController()
        {
            $This.Source   = $Null
            $This.Target   = $Null
            $This.Selected = $Null
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        [Void] LoadSilo([String]$Source)
        {
            If (!(Test-Path $Source))
            {
                Throw "Invalid source path"
            }

            ElseIf ((Get-ChildItem $Source *.iso).Count -eq 0)
            {
                [System.Windows.MessageBox]::Show("No ISO's detected")
            }

            Else
            {
                $This.Store  = @( )
                $This.Source = $Source

                ForEach ($Item in Get-ChildItem $This.Source *.iso)
                {
                    $This.Store += [ImageFile]::New($This.Store.Count,$Item.FullName)
                }
            }
        }
        LoadIso([UInt32]$Index)
        {
            If ($This.Store.Count -eq 0)
            {
                [System.Windows.MessageBox]::Show("No ISO's detected")
            }

            $This.Selected = $This.Store[$Index]

            If ($This.Selected.GetDiskImage() | ? Attached -eq 0)
            {
                $This.Selected.MountDiskImage()
            }

            Do 
            {
                $This.Selected.Letter = $This.Selected.GetDiskImage() | Get-Volume | % DriveLetter
                Start-Sleep -Milliseconds 100
            } 
            Until ($This.Selected.Letter -in [Char[]]@(65..90))
        }
        [Void] UnloadIso()
        {
            $This.Selected.DismountDiskImage()
            $This.Selected = $Null
        }
        AddQueue([UInt32[]]$Index)
        {
            If ($This.Selected.Path -in $This.Queue.Name)
            {
                [System.Windows.MessageBox]::Show("That image is already in the queue - remove, and reindex","Error")
            }
            Else
            {
                $This.Queue += [ImageLabel]::New($This.Selected,$Index)
            }
        }
        [Void] DeleteQueue([String]$Name)
        {
            If ($Name -in $This.Queue.Name)
            {
                $This.Queue = @( $This.Queue | ? Name -ne $Name )
            }
        }
        SetTarget([String]$Target)
        {
            If (Test-Path $Target)
            {
                $Children = Get-ChildItem $Target *.wim -Recurse | % FullName
                If ($Children.Count -gt 0)
                {
                    Switch([System.Windows.MessageBox]::Show("Wim files detected at provided path.","Purge and rebuild?","YesNo"))
                    {
                        Yes
                        {
                            ForEach ( $Child in $Children )
                            {
                                Get-ChildItem $Target | Remove-Item -Recurse -Confirm:$False -Force -Verbose
                            }
                        }

                        No
                        {
                            Break
                        }
                    }
                }
            }

            If (!(Test-Path $Target))
            {
                New-Item -Path $Target -ItemType Directory -Verbose
            }

            $This.Target = $Target
        }
        [Object] Refresh([String]$Path)
        {
            Return Get-DiskImage -ImagePath $Path 
        }
        Extract()
        {
            $X               = 0
            $DestinationName = $Null
            $Label           = $Null

            ForEach ($File in $This.Queue)
            {
                $Disk        = $This.Refresh($File.Name)
                $Name        = $File.Name | Split-Path -Leaf
                If ($Name.Length -gt 65)
                {
                    $Name    = "$($Name.Substring(0,64))..."
                }
                If (!$Disk.Attached)
                {
                    Write-Theme "Mounting [~] $Name"
                    Mount-DiskImage -ImagePath $Disk.ImagePath -Verbose
                    Do
                    {
                        Start-Sleep -Milliseconds 250
                        $Disk = $This.Refresh($File.Name)
                    }
                    Until ($This.Refresh($File.Name).Attached)
                }

                $Disk         = $This.Refresh($File.Name)
                $Path         = "{0}:\sources\install.wim" -f ($Disk | Get-Volume | % DriveLetter)

                ForEach ($Item in $File.Content)
                {
                    $ISO                        = @{

                        SourceIndex             = $Item.Index
                        SourceImagePath         = $Path
                        DestinationImagePath    = ("{0}\({1}){2}\{2}.wim" -f $This.Target,$X,$Item.Label)
                        DestinationName         = $Item.DestinationName
                    }

                    New-Item ($Iso.DestinationImagePath | Split-Path -Parent) -ItemType Directory -Verbose

                    Write-Theme "Extracting [~] $($Item.DestinationName)" 14,6,15
                    Start-Sleep 1

                    Export-WindowsImage @ISO
                    Write-Theme "Extracted [~] $($Item.DestinationName)" 10,2,15
                    Start-Sleep 1

                    $X ++
                }
                Write-Theme "Dismounting [~] $Name" 12,4,15
                Start-Sleep 1

                $This.Refresh($File.Name) | Dismount-DiskImage -Verbose
            }
            Write-Theme "Complete [+] ($($This.Queue.Content.Count)) *.wim files Extracted" 10,2,15
        }
        [String] ToString()
        {
            Return '<ImageController>'
        }
    }
    [ImageController]::New()
}

Function SecurityOption
{
    Enum SecurityOptionType
    {
        FirstPet
        BirthCity
        ChildhoodNick
        ParentCity
        CousinFirst
        FirstSchool
    }

    Class SecurityOptionItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        SecurityOptionItem([String]$Name)
        {
            $This.Index = [UInt32][SecurityOptionType]::$Name
            $This.Name  = [SecurityOptionType]::$Name
        }
    }

    Class SecurityOptionList
    {
        [String]    $Name
        [Object]  $Output
        SecurityOptionList()
        {
            $This.Name = "SecurityOptionList"
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] SecurityOptionItem([String]$Name)
        {
            Return [SecurityOptionItem]::New($Name)
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
        }
        Refresh()
        {
            $This.Clear()
            ForEach ($Name in [System.Enum]::GetNames([SecurityOptionType]))
            {
                $Item             = $This.SecurityOptionItem($Name)
                $Item.Description = Switch ($Item.Index)
                {
                    0 { "What was your first pets name?"                      }
                    1 { "What's the name of the city where you were born?"    }
                    2 { "What was your childhood nickname?"                   }
                    3 { "What's the name of the city where your parents met?" }
                    4 { "What's the first name of your oldest cousin?"        }
                    5 { "What's the name of the first school you attended?"   }
                }

                $This.Add($Item)
            }
        }
    }

    Class SecurityOptionSelection
    {
        [UInt32]    $Index
        [String]     $Name
        [String] $Question
        [String]   $Answer
        SecurityOptionSelection([UInt32]$Index,[Object]$Item)
        {
            $This.Index    = $Index
            $This.Name     = $Item.Name
            $This.Question = $Item.Description
        }
        SetAnswer([String]$Answer)
        {
            $This.Answer   = $Answer
        }
    }

    Class SecurityOptionController
    {
        [Object]    $Account
        [Object] $Credential
        [Object]       $Slot
        [Object]     $Output
        SecurityOptionController()
        {
            $This.Slot    = $This.SecurityOptionList()
            $This.Clear()
        }
        [Object] SecurityOptionList()
        {
            Return [SecurityOptionList]::New().Output
        }
        [Object] SecurityOptionItem([UInt32]$Index,[String]$Name,[String]$Question)
        {
            Return [SecurityOptionItem]::New($Index,$Name,$Question)
        }
        [Object] SecurityOptionSelection([UInt32]$Index,[Object]$Item)
        {
            Return [SecurityOptionSelection]::New($Index,$Item)
        }
        [String] GetUsername()
        {
            If (!$This.Account)
            {
                Throw "Must insert an account"
            }

            Return "{0}{1}{2}" -f $This.Account.First.Substring(0,1).ToLower(),
                                  $This.Account.Last.ToLower(),
                                  $This.Account.Year.ToString().Substring(2,2)
        }
        [UInt32] Random()
        {
            Return Get-Random -Max 20
        }
        [String] Char()
        {
            Return "!@#$%^&*(){}[]:;,./\".Substring($This.Random(),1)
        }
        [String] GetPassword()
        {
            $R = $This.Char()
            $H = @{ }

            $H.Add($H.Count,$R)
            $H.Add($H.Count,$This.Account.First.Substring(0,1))
            $H.Add($H.Count,("{0:d2}" -f $This.Account.Month))
            If ($This.Account.MI)
            {
                $H.Add($H.Count,$This.Account.MI)
            }
            $H.Add($H.Count,("{0:d2}" -f $This.Account.Day))
            $H.Add($H.Count,$This.Account.Last.Substring(0,1))
            $H.Add($H.Count,$This.Account.Year.ToString().Substring(2,2))
            $H.Add($H.Count,$R)

            Return $H[0..($H.Count-1)] -join ""
        }
        [PSCredential] PSCredential([String]$Username,[SecureString]$SecureString)
        {
            Return [PSCredential]::New($Username,$SecureString)
        }
        [String] PW()
        {
            If (!$This.Credential)
            {
                Throw "No credential set"
            }

            Return $This.Credential.GetNetworkCredential().Password
        }
        [String] UN()
        {
            If (!$This.Credential)
            {
                Throw "No credential set"
            }

            Return $This.Credential.Username
        }
        SetCredential()
        {
            $SS              = $This.GetPassword() | ConvertTo-SecureString -AsPlainText -Force
            $This.Credential = $This.PSCredential($This.GetUsername(),$SS)
        }
        SetAccount([Object]$Account)
        {
            $This.Account = $Account
        }
        Clear()
        {
            $This.Output = @( )
        }
        Add([UInt32]$Rank,[String]$Answer)
        {
            $Temp = $This.SecurityOptionSelection($This.Output.Count,$This.Slot[$Rank])
            
            If ($Temp.Name -in $This.Output.Name)
            {
                Throw "Option already selected"
            }

            ElseIf ($Answer -eq "")
            {
                Throw "Cannot have a <null> answer"
            }

            $Temp.SetAnswer($Answer)
            $This.Output += $Temp
        }
    }

    [SecurityOptionController]::New()
}

Class VmAdminCredential
{
    [String]         $UserName
    [PSCredential] $Credential
    VmAdminCredential([String]$Username)
    {
        $This.Username   = $Username
        $This.Credential = $This.SetCredential($This.Generate())
    }
    VmAdminCredential([Object]$File)
    {
        $This.Username   = "Administrator"
        $This.Credential = $This.SetCredential($This.Content($File.Fullname))
    }
    [PSCredential] SetCredential([String]$String)
    {
        Return [PSCredential]::New($This.Username,$This.Secure($String))
    }
    [SecureString] Secure([String]$In)
    {
        Return $In | ConvertTo-SecureString -AsPlainText -Force
    }
    [String] Generate()
    {
        Do
        {
            $Length          = $This.Random(10,16)
            $Bytes           = [Byte[]]::New($Length)

            ForEach ($X in 0..($Length-1))
            {
                $Bytes[$X]   = $This.Random(32,126)
            }

            $Pass            = [Char[]]$Bytes -join ''
        }
        Until ($Pass -match $This.Pattern())

        Return $Pass
    }
    [String] Content([String]$Path)
    {
        Return [System.IO.File]::ReadAllLines($Path)
    }
    [String] Pattern()
    {
        Return "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
    }
    [UInt32] Random([UInt32]$Min,[UInt32]$Max)
    {
        Return Get-Random -Min $Min -Max $Max
    }
    [String] Password()
    {
        Return $This.Credential.GetNetworkCredential().Password
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmAdminCredential>"
    }
}

Class VmByteSize
{
    [String]   $Name
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    VmByteSize([String]$Name,[UInt64]$Bytes)
    {
        $This.Name   = $Name
        $This.Bytes  = $Bytes
        $This.GetUnit()
        $This.GetSize()
    }
    GetUnit()
    {
        $This.Unit   = Switch ($This.Bytes)
        {
            {$_ -lt 1KB}                 {     "Byte" }
            {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
            {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
            {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
            {$_ -ge 1TB}                 { "Terabyte" }
        }
    }
    GetSize()
    {
        $This.Size   = Switch -Regex ($This.Unit)
        {
            ^Byte     {     "{0} B" -f  $This.Bytes/1    }
            ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
            ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
            ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
            ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
        }
    }
    [String] ToString()
    {
        Return $This.Size
    }
}

Class VmNetworkV4Ping
{
    [UInt32]         $Index
    [UInt32]        $Status
    [String]          $Type = "Host"
    [String]     $IpAddress
    [String]      $Hostname
    [String[]]     $Aliases
    [String[]] $AddressList
    VmNetworkV4Ping([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
    {
        $This.Index          = $Index
        $This.Status         = $Reply.Result.Status -match "Success"
        $This.IpAddress      = $IpAddress
    }
    Resolve()
    {
        $Item                = [System.Net.Dns]::Resolve($This.IpAddress)
        $This.Hostname       = $Item.Hostname
        $This.Aliases        = $Item.Aliases
        $This.AddressList    = $Item.AddressList
    }
    [String] ToString()
    {
        Return $This.IPAddress
    }
}

Class VmNetworkNode
{
    [UInt32]     $Index
    [String]      $Name
    [String] $IpAddress
    [String]    $Domain
    [String]   $NetBios
    [String]   $Trusted
    [UInt32]    $Prefix
    [String]   $Netmask
    [String]   $Gateway
    [String[]]     $Dns
    [Object]      $Dhcp
    VmNetworkNode([UInt32]$Index,[String]$Name,[String]$IpAddress,[Object]$Hive)
    {
        $This.Index     = $Index
        $This.Name      = $Name
        $This.IpAddress = $IpAddress
        $This.Domain    = $Hive.Domain
        $This.NetBios   = $Hive.NetBios
        $This.Trusted   = $Hive.Trusted
        $This.Prefix    = $Hive.Prefix
        $This.Netmask   = $Hive.Netmask
        $This.Gateway   = $Hive.Gateway
        $This.Dns       = $Hive.Dns
        $This.Dhcp      = $Hive.Dhcp
    }
    VmNetworkNode([Object]$File)
    {
        $This.Index     = $File.Index
        $This.Name      = $File.Name
        $This.IpAddress = $File.IpAddress
        $This.Domain    = $File.Domain
        $This.NetBios   = $File.NetBios
        $This.Trusted   = $File.Trusted
        $This.Prefix    = $File.Prefix
        $This.Netmask   = $File.Netmask
        $This.Gateway   = $File.Gateway
        $This.Dns       = $File.Dns
        $This.Dhcp      = $File.Dhcp
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetwork[Node]>"
    }
}

Class VmNetworkList
{
    [UInt32]     $Index
    [String]     $Count
    [String]   $Netmask
    [String]  $Notation
    [Object]    $Output
    VmNetworkList([UInt32]$Index,[String]$Netmask,[UInt32]$Count,[String]$Notation)
    {
        $This.Index    = $Index
        $This.Count    = $Count
        $This.Netmask  = $Netmask
        $This.Notation = $Notation
        $This.Output   = @( )
    }
    Expand()
    {
        $Split     = $This.Notation.Split("/")
        $HostRange = @{ }
        ForEach ($0 in $Split[0] | Invoke-Expression)
        {
            ForEach ($1 in $Split[1] | Invoke-Expression)
            {
                ForEach ($2 in $Split[2] | Invoke-Expression)
                {
                    ForEach ($3 in $Split[3] | Invoke-Expression)
                    {
                        $HostRange.Add($HostRange.Count,"$0.$1.$2.$3")
                    }
                }
            }
        }

        $This.Output    = $HostRange[0..($HostRange.Count-1)]
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetwork[List]>"
    }
}

Class VmNetworkDhcp
{
    [String]          $Name
    [String]    $SubnetMask
    [String]       $Network
    [String]    $StartRange
    [String]      $EndRange
    [String]     $Broadcast
    [String[]]   $Exclusion
    VmNetworkDhcp([Object]$Network)
    {
        $This.Name        = "{0}/{1}" -f ($Network.Hosts | ? Type -eq Network), $Network.Prefix
        $This.SubnetMask  = $Network.Netmask
        $This.Network     = $Network.Hosts | ? Type -eq Network
        $Range            = $Network.Hosts | ? Type -eq Host
        $This.StartRange  = $Range[0].IpAddress
        $This.EndRange    = $Range[-1].IpAddress
        $This.Broadcast   = $Network.Hosts | ? Type -eq Broadcast
        $This.Exclusion   = $Range | ? Status | % IpAddress
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetwork[Dhcp]>"
    }
}

Class VmNetworkController
{
    Hidden [Object]   $Config
    [String]          $Domain
    [String]         $NetBios
    [String]         $Trusted
    [UInt32]          $Prefix
    [String]         $Netmask
    [String]        $Wildcard
    [String]         $Gateway
    [String[]]           $Dns
    [Object]            $Dhcp
    [Object]        $Networks
    [Object]           $Hosts
    [Object]           $Nodes
    VmNetworkController([Object]$Config,[String]$Domain,[String]$NetBios)
    {
        $This.Config    = $Config
        $This.Domain    = $Domain
        $This.NetBios   = $NetBios
        $This.Trusted   = $This.Config.IPV4Address.IpAddress.ToString()
        $This.Prefix    = $This.Config.IPv4Address.PrefixLength

        $This.GetConversion()

        $This.Gateway   = $This.Config.IPV4DefaultGateway.NextHop
        $This.Dns       = $This.Config.DnsServer | ? AddressFamily -eq 2 | % ServerAddresses

        $This.Networks  = @( )
        $This.Hosts     = @( )
        $This.Nodes     = @( )

        $This.GetNetworkLists()

        $This.Dhcp      = $This.VmNetworkDhcp()
    }
    [Object] VmNetworkNode([UInt32]$Index,[String]$Name,[String]$IpAddress,[Object]$Hive)
    {
        Return [VmNetworkNode]::New($Index,$Name,$IpAddress,$Hive)
    }
    [Object] VmNetworkList([UInt32]$Index,[String]$Netmask,[UInt32]$Count,[String]$Notation)
    {
        Return [VmNetworkList]::New($Index,$Netmask,$Count,$Notation)
    }
    [Object] VmNetworkDhcp()
    {
        Return [VmNetworkDhcp]::New($This)
    }
    AddNode([String]$Name)
    {
        $Item              = ($This.Hosts | ? Type -eq Host | ? Status -eq 0)[0]
        $This.Nodes       += $This.VmNetworkNode($This.Nodes.Count,$Name,$Item.IpAddress,$This)
        If ($Name -in $This.Nodes.Name)
        {
            $Item          = $This.Hosts[$Item.Index]
            $Item.Status   = 1
            $Item.Hostname = $Name
            [Console]::WriteLine("[+] Node [$Name] added")
        }
    }
    AddList([UInt32]$Count,[String]$Notation)
    {
        $This.Networks += $This.VmNetworkList($This.Networks.Count,$This.Netmask,$Count,$Notation)
    }
    GetConversion()
    {
        # Convert IP and PrefixLength into binary, netmask, and wildcard
        $xBinary       = 0..3 | % { (($_*8)..(($_*8)+7) | % { @(0,1)[$_ -lt $This.Prefix] }) -join '' }
        $This.Netmask  = ($xBinary | % { [Convert]::ToInt32($_,2 ) }) -join "."
        $This.Wildcard = ($This.Netmask.Split(".") | % { (256-$_) }) -join "."
    }
    GetNetworkLists()
    {
        $Address      = $This.Trusted.Split(".")

        $xNetmask      = $This.Netmask  -split "\."
        $xWildCard     = $This.Wildcard -split "\."
        $Total         = $xWildcard -join "*" | Invoke-Expression

        # Convert wildcard into total host range
        $Hash          = @{ }
        ForEach ($X in 0..3)
        { 
            $Value = Switch ($xWildcard[$X])
            {
                1       
                { 
                    $Address[$X]
                }
                Default
                {
                    ForEach ($Item in 0..255 | ? { $_ % $xWildcard[$X] -eq 0 })
                    {
                        "{0}..{1}" -f $Item, ($Item+($xWildcard[$X]-1))
                    }
                }
                255
                {
                    "{0}..{1}" -f $xNetmask[$X],($xNetmask[$X]+$xWildcard[$X])
                }
            }

            $Hash.Add($X,$Value)
        }

        # Build host range
        $xRange   = @{ }
        ForEach ($0 in $Hash[0])
        {
            ForEach ($1 in $Hash[1])
            {
                ForEach ($2 in $Hash[2])
                {
                    ForEach ($3 in $Hash[3])
                    {
                        $xRange.Add($xRange.Count,"$0/$1/$2/$3")
                    }
                }
            }
        }

        Switch ($xRange.Count)
        {
            0
            {
                "Error"
            }
            1
            {
                $This.AddList($Total,$xRange[0])
            }
            Default
            {
                ForEach ($X in 0..($xRange.Count-1))
                {
                    $This.AddList($Total,$xRange[$X])
                }
            }
        }

        # Subtract network + broadcast addresses
        ForEach ($Network in $This.Networks)
        {
            $Network.Expand()
            If ($This.Trusted -in $Network.Output)
            {
                $This.Hosts          = $This.V4PingSweep($Network)
                $This.Hosts[ 0].Type = "Network"
                $This.Hosts[-1].Type = "Broadcast"
            }
            Else
            {
                $Network.Output = $Null
            }
        }
    }
    Resolve()
    {
        If ($This.Output.Count -gt 2)
        {
            ForEach ($Item in $This.Hosts | ? Status)
            {
                $Item.Resolve()
            }
        }
    }
    [Object] V4PingOptions()
    {
        Return [System.Net.NetworkInformation.PingOptions]::New()
    }
    [Object] V4PingBuffer()
    {
        Return 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
    }
    [Object] V4Ping([String]$Ip)
    {
        $Item = [System.Net.NetworkInformation.Ping]::New()
        Return $Item.SendPingAsync($Ip,100,$This.V4PingBuffer(),$This.V4PingOptions())
    }
    [Object] V4PingResponse([UInt32]$Index,[Object]$Ip,[Object]$Ping)
    {
        Return [VmNetworkV4Ping]::New($Index,$Ip,$Ping)
    }
    [Object[]] V4PingSweep([Object]$Network)
    {
        $Ping                = @{ }
        $Response            = @{ }

        ForEach ($X in 0..($Network.Output.Count-1))
        { 
            $Ping.Add($Ping.Count,$This.V4Ping($Network.Output[$X]))
        }
    
        ForEach ($X in 0..($Ping.Count-1)) 
        {
            $Response.Add($X,$This.V4PingResponse($X,$Network.Output[$X],$Ping[$X]))
        }

        Return $Response[0..($Response.Count-1)]
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetwork[Controller]>"
    }
}

Class VmNodeItem
{
    [UInt32]      $Index
    [Object]       $Name
    [Object]     $Memory
    [Object]       $Path
    [Object]        $Vhd
    [Object]    $VhdSize
    [Object] $Generation
    [UInt32]       $Core
    [Object] $SwitchName
    [Object]    $Network
    VmNodeItem([Object]$Node,[Object]$Hive)
    {
        $This.Index      = $Node.Index
        $This.Name       = $Node.Name
        $This.Memory     = $Hive.Memory
        $This.Path       = $Hive.Base, $This.Name -join '\'
        $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $Hive.Base, $This.Name
        $This.VhdSize    = $This.Size("HDD",$Hive.HDD)
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNode[Item]>"
    }
}

Class VmNodeTemplate
{
    [String]     $Base
    [UInt64]   $Memory
    [UInt64]      $Hdd
    [UInt32]      $Gen
    [UInt32]     $Core
    [String] $SwitchId
    [String]    $Image
    VmNodeTemplate([String]$Path,[UInt64]$Ram,[UInt64]$Hdd,[UInt32]$Gen,[UInt32]$Core,[String]$Switch,[String]$Img)
    {
        $This.Base     = $Path
        $This.Memory   = $Ram
        $This.Hdd      = $Hdd
        $This.Gen      = $Gen
        $This.Core     = $Core
        $This.SwitchId = $Switch
        $This.Image    = $Img
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNode[Template]>"
    }
}

Class VmNodeFile
{
    [UInt32]     $Index
    [String]      $Name
    [String] $IpAddress
    [String]    $Domain
    [String]   $NetBios
    [String]   $Trusted
    [UInt32]    $Prefix
    [String]   $Netmask
    [String]   $Gateway
    [String[]]     $Dns
    [Object]      $Dhcp
    [String]      $Base
    [UInt64]    $Memory
    [UInt64]       $Hdd
    [UInt32]       $Gen
    [UInt32]      $Core
    [String]  $SwitchId
    [String]     $Image
    VmNodeFile([Object]$Node,[Object]$Template)
    {
        $This.Index     = $Node.Index
        $This.Name      = $Node.Name
        $This.IpAddress = $Node.IpAddress
        $This.Domain    = $Node.Domain
        $This.NetBios   = $Node.NetBios
        $This.Trusted   = $Node.Trusted
        $This.Prefix    = $Node.Prefix
        $This.Netmask   = $Node.Netmask
        $This.Gateway   = $Node.Gateway
        $This.Dns       = $Node.Dns
        $This.Dhcp      = $Node.Dhcp
        $This.Base      = $Template.Base
        $This.Memory    = $Template.Memory
        $This.Hdd       = $Template.Hdd
        $This.Gen       = $Template.Gen
        $This.Core      = $Template.Core
        $This.SwitchId  = $Template.SwitchId
        $This.Image     = $Template.Image
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNode[File]>"
    }
}

Class VmNodeController
{
    [String]     $Path
    [String]   $Domain
    [String]  $NetBios
    [Object]    $Admin
    [Object]   $Config
    [Object]  $Network
    [Object] $Template
    VmNodeController([String]$Path,[String]$Domain,[String]$NetBios)
    {
        If (![System.IO.Directory]::Exists($Path))
        {
            [System.IO.Directory]::CreateDirectory($Path)
        }

        $This.Path     = $Path
        $This.Domain   = $Domain
        $This.NetBios  = $NetBios
        $This.Admin    = $This.NewVmAdminCredential()
        $This.Config   = $This.GetNetIPConfiguration()
        $This.Network  = $This.NewVmNetworkController()
    }
    VmNodeController([String]$Path,[String]$IpAddress,[UInt32]$Prefix,[String]$Gateway,[String[]]$Dns,[String]$Domain,[String]$NetBios)
    {
        $This.Path     = $Path
        $This.Domain   = $Domain
        $This.NetBios  = $NetBios
        $This.Admin    = $This.NewVmAdminCredential()
        $This.Config   = $null
        $This.Network  = $This.NewVmNetworkController($IpAddress,$Prefix,$Gateway,$Dns,$Domain,$NetBios)
    }
    [Object] NewVmAdminCredential()
    {
        Return [VmAdminCredential]::New("Administrator")
    }
    [Object] GetNetIPConfiguration()
    {
        Return Get-NetIPConfiguration -Detailed | ? IPV4DefaultGateway | Select-Object -First 1
    }
    [Object] NewVmNetworkController()
    {
        Return [VmNetworkController]::New($This.Config,$This.Domain,$This.NetBios)
    }
    [Object] NewVmNetworkController([String]$IpAddress,[UInt32]$Prefix,[String]$Gateway,[String[]]$Dns,[String]$Domain,[String]$NetBios)
    {
        Return [VmNetworkController]::New($IpAddress,$Prefix,$Gateway,$Dns,$Domain,$NetBios)
    }
    [Object] NewVmTemplate([String]$Base,[UInt64]$Ram,[UInt64]$Hdd,[Uint32]$Generation,[UInt32]$Core,[String]$VMSwitch,[String]$Path)
    {
        Return [VmNodeTemplate]::New($Base,$Ram,$Hdd,$Generation,$Core,$VmSwitch,$Path)
    }
    SetTemplate([String]$Base,[UInt64]$Ram,[UInt64]$Hdd,[Uint32]$Generation,[UInt32]$Core,[String]$VMSwitch,[String]$Path)
    {
        $This.Template = $This.NewVmTemplate($Base,$Ram,$Hdd,$Generation,$Core,$VmSwitch,$Path)
    }
    [Object] NewVmObjectFile([Object]$Node)
    {
        Return [VmNodeFile]::New($Node,$This.Template)
    }
    AddNode([String]$Name)
    {
        If ($Name -notin $This.Network.Nodes)
        {
            $This.Network.AddNode($Name)
        }
    }
    Export()
    {
        ForEach ($Node in $This.Network.Nodes)
        {
            $FilePath = "{0}\{1}.txt" -f $This.Path, $Node.Name
            $Value    = $This.NewVmObjectFile($Node) | ConvertTo-Json

            [System.IO.File]::WriteAllLines($FilePath,$Value)

            If ([System.IO.File]::Exists($FilePath))
            {
                [Console]::WriteLine("Exported  [+] File: [$FilePath]")
            }
            Else
            {
                Throw "Something failed... bye."
            }
        }
    }
    WriteAdmin()
    {
        $FilePath = "{0}\admin.txt" -f $This.Path 
        $Value    = $This.Admin.Credential.GetNetworkCredential().Password
        [System.IO.File]::WriteAllLines($FilePath,$Value)
        If ([System.IO.File]::Exists($FilePath))
        {
            [Console]::WriteLine("Exported  [+] File: [$FilePath]")
        }
        Else
        {
            Throw "Something failed... bye."
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNode[Controller]>"
    }
}

Class VmNodeInputObject
{
    [String]   $Path
    [Object] $Object
    [Object]  $Admin
    VmNodeInputObject([String]$Token,[String]$Path)
    {
        $This.Path   = $Path
        $This.Object = $This.SetObject($Token)
        $This.Admin  = $This.SetAdmin()
    }
    [String] GetChildItem([String]$Name)
    {
        $File = Get-ChildItem $This.Path | ? Name -eq $Name

        If (!$File)
        {
            Throw "Invalid entry"
        }

        Return $File.Fullname
    }
    [Object] SetObject([String]$Token)
    {
        $File        = $This.GetChildItem($Token)
        If (!$File)
        {
            Throw "Invalid token"
        }

        Return [System.IO.File]::ReadAllLines($File) | ConvertFrom-Json
    }
    [PSCredential] SetAdmin()
    {
        $File        = $This.GetChildItem("admin.txt")
        If (!$File)
        {
            Throw "No password detected"
        }

        Return [PSCredential]::New("Administrator",$This.GetPassword($File))
    }
    [SecureString] GetPassword([String]$File)
    {
        Return [System.IO.File]::ReadAllLines($File) | ConvertTo-SecureString -AsPlainText -Force
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNode[InputObject]>"
    }
}

Class VmScriptBlockLine
{
    [UInt32] $Index
    [String]  $Line
    VmScriptBlockLine([UInt32]$Index,[String]$Line)
    {
        $This.Index = $Index
        $This.Line  = $Line
    }
    [String] ToString()
    {
        Return $This.Line
    }
}

Class VmScriptBlockItem
{
    [UInt32]       $Index
    [UInt32]       $Phase
    [String]        $Name
    [String] $DisplayName
    [Object]     $Content
    [UInt32]    $Complete
    VmScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
    {
        $This.Index       = $Index
        $This.Phase       = $Phase
        $This.Name        = $Name
        $This.DisplayName = $DisplayName
        
        $This.Load($Content)
    }
    Clear()
    {
        $This.Content     = @( )
    }
    Load([String[]]$Content)
    {
        $This.Clear()
        $This.Add("# $($This.DisplayName)")

        ForEach ($Line in $Content)
        {
            $This.Add($Line)
        }

        $This.Add('')
    }
    [Object] VmScriptBlockLine([UInt32]$Index,[String]$Line)
    {
        Return [VmScriptBlockLine]::New($Index,$Line)
    }
    Add([String]$Line)
    {
        $This.Content += $This.VmScriptBlockLine($This.Content.Count,$Line)
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmScriptBlock[Item]>"
    }
}

Class VmScriptBlockController
{
    [String]     $Name
    [UInt32] $Selected
    [UInt32]    $Count
    [Object]   $Output
    VmScriptBlockController()
    {
        $This.Name = "ScriptBlock[Controller]"
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
        $This.Count  = 0
    }
    [Object] VmScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
    {
        Return [VmScriptBlockItem]::New($Index,$Phase,$Name,$DisplayName,$Content)
    }
    Add([String]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
    {
        $This.Output += $This.VmScriptBlockItem($This.Output.Count,$Phase,$Name,$DisplayName,$Content)
        $This.Count   = $This.Output.Count
    }
    Select([UInt32]$Index)
    {
        If ($Index -gt $This.Count)
        {
            Throw "Invalid index"
        }

        $This.Selected = $Index
    }
    [Object] Current()
    {
        Return $This.Output[$This.Selected] 
    }
    [Object] Get([String]$Name)
    {
        Return $This.Output | ? Name -eq $Name
    }
    [Object] Get([UInt32]$Index)
    {
        Return $This.Output | ? Index -eq $Index
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmScriptBlock[Controller]>"
    }
}

Class VmPropertyItem
{
    [UInt32] $Index
    [String] $Name
    [Object] $Value
    VmPropertyItem([UInt32]$Index,[Object]$Property)
    {
        $This.Index = $Index
        $This.Name  = $Property.Name
        $This.Value = $Property.Value
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmProperty[Item]>"
    }
}

Class VmPropertyList
{
    [String] $Name
    [UInt32] $Count
    [Object] $Output
    VmPropertyList()
    {
        $This.Name = "VmProperty[List]"
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] VmPropertyItem([UInt32]$Index,[Object]$Property)
    {
        Return [VmPropertyItem]::($Index,$Property)
    }
    Add([Object]$Property)
    {
        $This.Output += $This.VmPropertyItem($This.Output.Count,$Property)
        $This.Count   = $This.Output.Count
    }
    [String] ToString()
    {
        Return "({0}) <FEVirtual.VmProperty[List]>" -f $This.Count
    }
}

Class VmObject
{
    Hidden [UInt32]     $Mode
    [Object]         $Console
    [Object]            $Name
    [Object]          $Memory
    [Object]            $Path
    [Object]             $Vhd
    [Object]         $VhdSize
    [Object]      $Generation
    [UInt32]            $Core
    [Object]          $Switch
    [Object]        $Firmware
    [UInt32]          $Exists
    [Object]            $Guid
    [Object]         $Network
    [String]             $Iso
    [Object]          $Script
    Hidden [Object] $Property
    Hidden [Object]  $Control
    Hidden [Object] $Keyboard
    VmObject([Switch]$Flags,[Object]$Vm)
    {   
        # Meant for removal if found
        $This.Mode       = 1
        $This.StartConsole()

        $This.Name       = $Vm.Name
        $Item            = $This.Get()
        If (!$Item)
        {
            Throw "Vm does not exist"
        }

        $This.Memory     = $This.Size("Ram",$Item.MemoryStartup)
        $This.Path       = $Item.Path | Split-Path
        $This.Vhd        = $Item.HardDrives[0].Path
        $This.VhdSize    = $This.Size("Hdd",(Get-Vhd $This.Vhd).Size)
        $This.Generation = $Item.Generation
        $This.Core       = $Item.ProcessorCount
        $This.Switch     = @($Item.NetworkAdapters[0].SwitchName)
        $This.Firmware   = $This.GetVmFirmware()
    }
    VmObject([Object]$File)
    {
        # Meant to build a new VM
        $This.Mode       = 1
        $This.StartConsole()

        $This.Name       = $File.Name
        If ($This.Get())
        {
            Throw "Vm already exists"
        }

        $This.Memory     = $This.Size("Ram",$File.Memory)
        $This.Path       = "{0}\{1}" -f $File.Base, $This.Name
        $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $File.Base, $This.Name
        $This.VhdSize    = $This.Size("Hdd",$File.HDD)
        $This.Generation = $File.Gen
        $This.Core       = $File.Core
        $This.Switch     = @($File.SwitchId)
        $This.Network    = $This.GetNetworkNode($File)
        $This.Iso        = $File.Image
    }
    StartConsole()
    {
        # Instantiates and initializes the console
        $This.Console = New-FEConsole
        $This.Console.Initialize()
        $This.Status()
    }
    [Void] Status()
    {
        # If enabled, shows the last item added to the console
        If ($This.Mode -gt 0)
        {
            [Console]::WriteLine($This.Console.Last())
        }
    }
    [Void] Update([Int32]$State,[String]$Status)
    {
        # Updates the console
        $This.Console.Update($State,$Status)
        $This.Status()
    }
    Error([UInt32]$State,[String]$Status)
    {
        $This.Console.Update($State,$Status)
        Throw $This.Console.Last().Status
    }
    [Object] Get()
    {
        $Virtual           = Get-VM -Name $This.Name -EA 0
        $This.Exists       = $Virtual.Count -gt 0
        $This.Guid         = @($Null,$Virtual.Id)[$This.Exists]

        Return @($Null,$Virtual)[$This.Exists]
    }
    [Object] Size([String]$Name,[UInt64]$SizeBytes)
    {
        Return [VmByteSize]::New($Name,$SizeBytes)
    }
    [String] Hostname()
    {
        Return [Environment]::MachineName
    }
    Connect()
    {
        $This.Update(0,"[~] Connecting : $($This.Name)")
        $Splat           = @{

            Filepath     = "vmconnect"
            ArgumentList = @($This.Hostname(),$This.Name)
            Verbose      = $True
            PassThru     = $True
        }

        Start-Process @Splat
    }
    New()
    {
        $Null = $This.Get()
        If ($This.Exists -ne 0)
        {
            $This.Error(-1,"[!] Exists : $($This.Name)")
        }

        $Object                = @{

            Name               = $This.Name
            MemoryStartupBytes = $This.Memory.Bytes
            Path               = $This.Path
            NewVhdPath         = $This.Vhd
            NewVhdSizeBytes    = $This.VhdSize.Bytes
            Generation         = $This.Generation
            SwitchName         = $This.Switch[0]
        }

        $This.Update(0,"[~] Creating : $($This.Name)")

        # Verbosity level
        Switch ($This.Mode)
        {
            Default { New-VM @Object }
            2       { New-VM @Object -Verbose }
        }

        # Verbosity level
        Switch ($This.Mode)
        {
            Default { Enable-VmResourceMetering -VmName $This.Name }
            2       { Enable-VmResourceMetering -VmName $This.Name -Verbose }
        }

        $Item                  = $This.Get()
        $This.Firmware         = $This.GetVmFirmware()
        $This.SetVMProcessor()

        $This.Script           = $This.NewVmScriptBlockController()
        $This.Property         = $This.NewVmPropertyList()

        ForEach ($Property in $Item.PSObject.Properties)
        {
            $This.Property.Add($Property)
        }
    }
    Start()
    {
        $Vm = $This.Get()
        If (!$Vm)
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
        }
        
        ElseIf ($Vm.State -eq "Running")
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [already started]")
        }

        Else
        {
            $This.Update(1,"[~] Starting : $($This.Name)")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { $Vm | Start-VM }
                2       { $Vm | Start-VM -Verbose }
            }
        }
    }
    Stop()
    {
        $Vm = $This.Get()
        If (!$Vm)
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
        }

        ElseIf ($Vm.State -ne "Running")
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
        }

        Else
        {
            $This.Update(0,"[~] Stopping : $($This.Name)")
        
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { $This.Get() | ? State -ne Off | Stop-VM -Force }
                2       { $This.Get() | ? State -ne Off | Stop-VM -Force -Verbose }
            }
        }
    }
    Reset()
    {
        $Vm = $This.Get()
        If (!$Vm)
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
        }

        ElseIf ($Vm.State -ne "Running")
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
        }

        Else
        {
            $This.Update(0,"[~] Restarting : $($This.Name)")
            $This.Stop()
            $This.Start()
            $This.Idle(5,5)
        }
    }
    Remove()
    {
        $Vm = $This.Get()
        If (!$Vm)
        {
            $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
        }

        $This.Update(0,"[~] Removing : $($This.Name)")

        If ($Vm.State -ne "Off")
        {
            $This.Update(0,"[~] State : $($This.Name) [attempting shutdown]")
            Switch -Regex ($Vm.State)
            {
                "(^Paused$|^Saved$)"
                { 
                    $This.Start()
                    Do
                    {
                        Start-Sleep 1
                    }
                    Until ($This.Get().State -eq "Running")
                }
            }

            $This.Stop()
            Do
            {
                Start-Sleep 1
            }
            Until ($This.Get().State -eq "Off")
        }

        # Verbosity level
        Switch ($This.Mode)
        {
            Default { $This.Get() | Remove-VM -Confirm:$False -Force -EA 0 } 
            2       { $This.Get() | Remove-VM -Confirm:$False -Force -Verbose -EA 0 } 
        }
        
        $This.Firmware         = $Null
        $This.Exists           = 0

        $This.Update(0,"[~] Vhd  : [$($This.Vhd)]")

        # Verbosity level
        Switch ($This.Mode) 
        { 
            Default { Remove-Item $This.Vhd -Confirm:$False -Force -EA 0 } 
            2       { Remove-Item $This.Vhd -Confirm:$False -Force -Verbose -EA 0 } 
        }
        
        $This.Update(0,"[~] Path : [$($This.Path)]")
        ForEach ($Item in Get-ChildItem $This.Path -Recurse | Sort-Object -Descending)
        {
            $This.Update(0,"[~] $($Item.Fullname)")

            # Verbosity level
            Switch ($This.Mode)
            { 
                Default { Remove-Item $Item.Fullname -Confirm:$False -EA 0 } 
                2       { Remove-Item $Item.Fullname -Confirm:$False -Verbose -EA 0 } 
            }
        }

        $This.Update(1,"[ ] Removed : $($Item.Fullname)")

        $This.DumpConsole()
    }
    [Object] Measure()
    {
        If (!$This.Exists)
        {
            Throw "Cannot measure a virtual machine when it does not exist"
        }

        Return Measure-Vm -Name $This.Name
    }
    [Object] Wmi([String]$Type)
    {
        Return Get-WmiObject $Type -NS Root\Virtualization\V2
    }
    [Object] NewVmPropertyList()
    {
        Return [VmPropertyList]::New()
    }
    [Object] NewVmScriptBlockController()
    {
        Return [VmScriptBlockController]::New()
    }
    [Object] GetVmFirmware()
    {
        $This.Update(0,"[~] Getting VmFirmware : $($This.Name)")
        $Item = Switch ($This.Generation) 
        { 
            1 
            {
                # Verbosity level
                Switch ($This.Mode)
                { 
                    Default { Get-VmBios -VmName $This.Name } 
                    2       { Get-VmBios -VmName $This.Name -Verbose } 
                }
            } 
            2 
            {
                # Verbosity level
                Switch ($This.Mode)
                {
                    Default { Get-VmFirmware -VmName $This.Name }
                    2       { Get-VmFirmware -VmName $This.Name -Verbose }
                }
            } 
        }

        Return $Item
    }
    SetVmProcessor()
    {
        $This.Update(0,"[~] Setting VmProcessor (Count): [$($This.Core)]")
        
        # Verbosity level
        Switch ($This.Mode)
        {
            Default { Set-VmProcessor -VMName $This.Name -Count $This.Core }
            2       { Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose }
        }
    }
    SetVmDvdDrive([String]$Path)
    {
        If (![System.IO.File]::Exists($Path))
        {
            $This.Error(-1,"[!] Invalid path : [$Path]")
        }

        $This.Update(0,"[~] Setting VmDvdDrive (Path): [$Path]")

        # Verbosity level
        Switch ($This.Mode) 
        { 
            Default { Set-VmDvdDrive -VMName $This.Name -Path $Path } 
            2       { Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose }
        }
    }
    SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
    {
        $This.Update(0,"[~] Setting VmFirmware (Boot order) : [$1,$2,$3]")

        $Fw = $This.GetVmFirmware()
            
        # Verbosity level
        Switch ($This.Mode) 
        { 
            Default { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] } 
            2       { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] -Verbose } 
        }
    }
    AddVmDvdDrive()
    {
        $This.Update(0,"[+] Adding VmDvdDrive")

        # Verbosity level
        Switch ($This.Mode)
        {
            Default { Add-VmDvdDrive -VMName $This.Name }
            2       { Add-VmDvdDrive -VMName $This.Name -Verbose }
        }
    }
    LoadIso([String]$Path)
    {
        If (![System.IO.File]::Exists($Path))
        {
            $This.Error(-1,"[!] Invalid ISO path : [$Path]")
        }

        Else
        {
            $This.Iso = $Path
            $This.SetVmDvdDrive($This.Iso)
        }
    }
    UnloadIso()
    {
        $This.Update(0,"[+] Unloading ISO")
        
        # Verbosity level
        Switch ($This.Mode)
        {
            Default { Set-VmDvdDrive -VMName $This.Name -Path $Null }
            2       { Set-VmDvdDrive -VMName $This.Name -Path $Null -Verbose }
        }
    }
    SetIsoBoot()
    {
        If (!$This.Iso)
        {
            $This.Error(-1,"[!] No (*.iso) file loaded")
        }

        ElseIf ($This.Generation -eq 2)
        {
            $This.SetVmBootOrder(2,0,1)
        }
    }
    TypeChain([UInt32[]]$Array)
    {
        ForEach ($Key in $Array)
        {
            $This.TypeKey($Key)
            Start-Sleep -Milliseconds 125
        }
    }
    TypeKey([UInt32]$Index)
    {
        $This.Update(0,"[+] Typing key : [$Index]")
        $This.Keyboard.TypeKey($Index)
        Start-Sleep -Milliseconds 125
    }
    TypeText([String]$String)
    {
        $This.Update(0,"[+] Typing text : [$String]")
        $This.Keyboard.TypeText($String)
        Start-Sleep -Milliseconds 125
    }
    TypePassword([String]$Pass)
    {
        $This.Update(0,"[+] Typing password : [ActualPassword]")
        $This.Keyboard.TypeText($Pass)
        Start-Sleep -Milliseconds 125
    }
    PressKey([UInt32]$Index)
    {
        $This.Update(0,"[+] Pressing key : [$Index]")
        $This.Keyboard.PressKey($Index)
    }
    ReleaseKey([UInt32]$Index)
    {
        $This.Update(0,"[+] Releasing key : [$Index]")
        $This.Keyboard.ReleaseKey($Index)
    }
    SpecialKey([UInt32]$Index)
    {
        $This.Keyboard.PressKey(18)
        $This.Keyboard.TypeKey($Index)
        $This.Keyboard.ReleaseKey(18)
    }
    [UInt32] GetKey([Char]$Char)
    {
        Return [UInt32][Char]$Char
    }
    TypeCtrlAltDel()
    {
        $This.Update(0,"[+] Typing (CTRL + ALT + DEL)")
        $This.Keyboard.TypeCtrlAltDel()
    }
    Idle([UInt32]$Percent,[UInt32]$Seconds)
    {
        $This.Update(0,"[~] Idle : $($This.Name) [CPU <= $Percent% for $Seconds second(s)]")
        
        $C = 0
        Do
        {
            Switch ([UInt32]($This.Get().CpuUsage -le $Percent))
            {
                0 { $C = 0 } 1 { $C ++ }
            }

            Start-Sleep -Seconds 1
        }
        Until ($C -ge $Seconds)

        $This.Update(1,"[+] Idle complete")
    }
    Uptime([UInt32]$Mode,[UInt32]$Seconds)
    {
        $Mark = @("<=",">=")[$Mode]
        $Flag = 0
        $This.Update(0,"[~] Uptime : $($This.Name) [Uptime $Mark $Seconds second(s)]")
        Do
        {
            Start-Sleep -Seconds 1
            $Uptime        = $This.Get().Uptime.TotalSeconds
            [UInt32] $Flag = Switch ($Mode) { 0 { $Uptime -le $Seconds } 1 { $Uptime -ge $Seconds } }
        }
        Until ($Flag)
        $This.Update(1,"[+] Uptime complete")
    }
    Timer([UInt32]$Seconds)
    {
        $This.Update(0,"[~] Timer : $($This.Name) [Span = $Seconds]")

        $C = 0
        Do
        {
            Start-Sleep -Seconds 1
            $C ++
        }
        Until ($C -ge $Seconds)

        $This.Update(1,"[+] Timer")
    }
    Connection()
    {
        $This.Update(0,"[~] Connection : $($This.Name) [Await response]")

        Do
        {
            Start-Sleep 1
        }
        Until (Test-Connection $This.Network.IpAddress -EA 0)

        $This.Update(1,"[+] Connection")
    }
    SetAdmin([Object]$Admin)
    {
        $This.Update(0,"[~] Setting : Administrator password")
        ForEach ($X in 0..1)
        {
            $This.TypePassword($Admin.Password())
            $This.TypeKey(9)
            Start-Sleep -Milliseconds 125
        }

        $This.TypeKey(9)
        Start-Sleep -Milliseconds 125
        $This.TypeKey(13)
    }
    Login([Object]$Admin)
    {
        If ($Admin.GetType().Name -ne "VmAdminCredential")
        {
            $This.Error("[!] Invalid input object")
        }

        $This.Update(0,"[~] Login : Administrator")
        $This.TypeCtrlAltDel()
        $This.Timer(5)
        $This.TypePassword($Admin.Password())
        Start-Sleep -Milliseconds 125
        $This.TypeKey(13)
    }
    LaunchPs()
    {
        # Open Start Menu
        $This.PressKey(91)
        $This.TypeKey(88)
        $This.ReleaseKey(91)
        $This.Timer(1)

        # Open Command Prompt
        $This.TypeKey(65)
        $This.Timer(1)

        # Maximize window
        $This.PressKey(91)
        $This.TypeKey(38)
        $This.ReleaseKey(91)
        $This.Timer(1)

        # Open PowerShell
        $This.TypeText("PowerShell")
        $This.TypeKey(13)
        $This.Timer(1)

        # Wait for PowerShell engine to get ready for input
        $This.Idle(5,5)
    }
    [Void] AddScript([UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
    {
        $This.Script.Add($Phase,$Name,$DisplayName,$Content)
        $This.Update(0,"[+] Added (Script) : $Name")
    }
    [Object] GetScript([UInt32]$Index)
    {
        $Item = $This.Script.Get($Index)
        If (!$Item)
        {
            $This.Error("[!] Invalid index")
        }
        
        Return $Item
    }
    [Object] GetScript([String]$Name)
    {
        $Item = $This.Script.Get($Name)
        If (!$Item)
        {
            $This.Error(-1,"[!] Invalid name")
        }
        
        Return $Item
    }
    [Void] RunScript()
    {
        $Item = $This.Script.Current()

        If ($Item.Complete -eq 1)
        {
            $This.Error(-1,"[!] Exception (Script) : [$($Item.Name)] already completed")
        }

        $This.Update(0,"[~] Running (Script) : [$($Item.Name)]")
        ForEach ($Line in $Item.Content)
        {
            Switch -Regex ($Line)
            {
                "^\<Pause\[\d+\]\>$"
                {
                    $Line -match "\d+"
                    $This.Timer($Matches[0])
                }
                "^$"
                {
                    $This.Idle(5,2)
                }
                Default
                {
                    $This.TypeText($Line)
                    $This.TypeKey(13)
                }
            }
        }

        $This.Update(1,"[+] Complete (Script) : [$($Item.Name)]")

        $Item.Complete = 1
        $This.Script.Selected ++
    }
    [Object] GetNetworkNode([Object]$File)
    {
        Return [VmNetworkNode]::New($File)
    }
    [String] GetRegistryPath()
    {
        Return "HKLM:\Software\Policies\Secure Digits Plus LLC"
    }
    SetPersistentInfo()
    {
        # [Phase 1] Set persistent information
        $This.Script.Add(1,"SetPersistentInfo","Set persistent information",@(
        '$Root      = "{0}"' -f $This.GetRegistryPath();
        '$Name      = "{0}"' -f $This.Name;
        '$Path      = "$Root\ComputerInfo"';
        'Rename-Computer $Name -Force';
        'If (!(Test-Path $Root))';
        '{';
        '    New-Item -Path $Root -Verbose';
        '}';
        'New-Item -Path $Path -Verbose';
        ForEach ($Prop in @($This.Network.PSObject.Properties))
        {
            $Line = 'Set-ItemProperty -Path $Path -Name {0} -Value {1}'
            Switch ($Prop.Name)
            {
                Default
                {
                    $Line -f $Prop.Name, $Prop.Value;
                }
                Dns
                {
                    $Value = "([String[]]@(`"{0}`"))" -f ($Prop.Value -join "`",`"")
                    $Line -f $Prop.Name, $Value
                }
                Dhcp
                {
                    '$Dhcp = "$Path\Dhcp"'
                    'New-Item $Dhcp'
                    'Set-ItemProperty -Path $Path -Name Dhcp -Value $Dhcp'
                    $Line = 'Set-ItemProperty -Path $Dhcp -Name {0} -Value {1}'
                    ForEach ($Item in $Prop.Value.PSObject.Properties)
                    {
                        If ($Item.Value.Count -eq 1)
                        {
                            $Line -f $Item.Name, $Item.Value
                        }
                        Else
                        {
                            $Value = "([String[]]@(`"{0}`"))" -f ($Item.Value -join "`",`"")
                            $Line -f $Item.Name, $Value
                        }
                    }
                }
            }
        }))
    }
    SetTimeZone()
    {
        # [Phase 2] Set time zone
        $This.Script.Add(2,"SetTimeZone","Set time zone",@('Set-Timezone -Name "{0}"' -f (Get-Timezone).Id))
    }
    SetComputerInfo()
    {
        # [Phase 3] Set computer info
        $This.Script.Add(3,"SetComputerInfo","Set computer info",@(
        '$Item           = Get-ItemProperty "{0}\ComputerInfo"' -f $This.GetRegistryPath() 
        '$TrustedHost    = $Item.Trusted';
        '$IPAddress      = $Item.IpAddress';
        '$PrefixLength   = $Item.Prefix';
        '$DefaultGateway = $Item.Gateway';
        '$Dns            = $Item.Dns'))
    }
    SetIcmpFirewall()
    {
        # [Phase 4] Enable IcmpV4
        $This.Script.Add(4,"SetIcmpFirewall","Enable IcmpV4",@(
        'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose'))
    }
    SetInterfaceNull()
    {
        # [Phase 5] Get InterfaceIndex, get/remove current (IP address + Net Route)
        $This.Script.Add(5,"SetInterfaceNull","Get InterfaceIndex, get/remove current (IP address + Net Route)",@(
        '$Index              = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex';
        '$Interface          = Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $Index';
        '$Interface          | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$False -Verbose';
        '$Interface          | Remove-NetRoute     -AddressFamily IPv4 -Confirm:$False -Verbose'))
    }
    SetStaticIp()
    {
        # [Phase 6] Set static IP Address
        $This.Script.Add(6,"SetStaticIp","Set (static IP Address + Dns server)",@(
        '$Splat              = @{';
        ' ';
        '    InterfaceIndex  = $Index';
        '    AddressFamily   = "IPv4"';
        '    PrefixLength    = $Item.Prefix';
        '    ValidLifetime   = [Timespan]::MaxValue';
        '    IPAddress       = $Item.IPAddress';
        '    DefaultGateway  = $Item.Gateway';
        '}';
        'New-NetIPAddress @Splat';
        'Set-DnsClientServerAddress -InterfaceIndex $Index -ServerAddresses $Item.Dns'))
    }
    SetWinRm()
    {
        # [Phase 7] Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)
        $This.Script.Add(7,"SetWinRm","Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)",@(
        'winrm quickconfig';
        '<Pause[2]>';
        'y';
        '<Pause[3]>';
        'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $Item.Trusted';
        '<Pause[4]>';
        'y';
        '$Cert       = New-SelfSignedCertificate -DnsName $Item.IpAddress -CertStoreLocation Cert:\LocalMachine\My';
        '$Thumbprint = $Cert.Thumbprint';
        '$Hash       = "@{Hostname=`"$IPAddress`";CertificateThumbprint=`"$Thumbprint`"}"';
        "`$Str         = `"winrm create winrm/config/Listener?Address=*+Transport=HTTPS '{0}'`"";
        'Invoke-Expression ($Str -f $Hash)'))
    }
    SetWinRmFirewall()
    {
        # [Phase 8] Set WinRm Firewall
        $This.Script.Add(8,"SetWinRmFirewall",'Set WinRm Firewall',@(
        '$Splat          = @{';
        ' ';
        '    Name        = "WinRM/HTTPS"';
        '    DisplayName = "Windows Remote Management (HTTPS-In)"';
        '    Direction   = "In"';
        '    Action      = "Allow"';
        '    Protocol    = "TCP"';
        '    LocalPort   = 5986';
        '}';
        'New-NetFirewallRule @Splat -Verbose'))
    }
    SetRemoteDesktop()
    {
        # [Phase 9] Set Remote Desktop
        $This.Script.Add(9,"SetRemoteDesktop",'Set Remote Desktop',@(
        'Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0';
        'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'))
    }
    InstallFeModule()
    {
        # [Phase 10] Install [FightingEntropy()]
        $This.Script.Add(10,"InstallFeModule","Install [FightingEntropy()]",@(
        '[Net.ServicePointManager]::SecurityProtocol = 3072'
        'Set-ExecutionPolicy Bypass -Scope Process -Force'
        '$Install = "https://github.com/mcc85s/FightingEntropy"'
        '$Full    = "$Install/blob/main/Version/2022.12.0/FightingEntropy.ps1?raw=true"'
        'Invoke-RestMethod $Full | Invoke-Expression'
        '$Module.Install()'
        'Import-Module FightingEntropy'))
    }
    InstallChoco()
    {
        # [Phase 11] Install Chocolatey
        $This.Script.Add(11,"InstallChoco","Install Chocolatey",@(
        "Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression"))
    }
    InstallVsCode()
    {
        # [Phase 12] Install Visual Studio Code
        $This.Script.Add(12,"InstallVsCode","Install Visual Studio Code",@("choco install vscode -y"))
    }
    InstallBossMode()
    {
        # [Phase 13] Install BossMode (vscode color theme)
        $This.Script.Add(13,"InstallBossMode","Install BossMode (vscode color theme)",@("Install-BossMode"))
    }
    InstallPsExtension()
    {
        # [Phase 14] Install Visual Studio Code (PowerShell Extension)
        $This.Script.Add(14,"InstallPsExtension","Install Visual Studio Code (PowerShell Extension)",@(
        '$FilePath     = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
        '$ArgumentList = "--install-extension ms-vscode.PowerShell"';
        'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process'))
    }
    RestartComputer()
    {
        # [Phase 15] Restart computer
        $This.Script.Add(15,'Restart','Restart computer',@('Restart-Computer'))
    }
    ConfigureDhcp()
    {
        # [Phase 16] Configure Dhcp
        $This.Script.Add(16,'ConfigureDhcp','Configure Dhcp',@(
        '$Root           = "{0}"' -f $This.GetRegistryPath()
        '$Path           = "$Root\ComputerInfo"'
        '$Item           = Get-ItemProperty $Path' 
        '$Item.Dhcp      = Get-ItemProperty $Item.Dhcp';
        ' ';
        '$Splat = @{ ';
        '   ';
        '    StartRange = $Item.Dhcp.StartRange';
        '    EndRange   = $Item.Dhcp.EndRange';
        '    Name       = $Item.Dhcp.Name';
        '    SubnetMask = $Item.Dhcp.SubnetMask';
        '}';
        '';
        'Add-DhcpServerV4Scope @Splat -Verbose';
        'Add-DhcpServerInDc -Verbose';
        ' ';
        'ForEach ($Value in $Item.Dhcp.Exclusion)';
        '{';
        '    $Splat         = @{ ';
        ' ';
        '        ScopeId    = $Item.Dhcp.Network';
        '        StartRange = $Value';
        '        EndRange   = $Value';
        '    }';
        ' ';
        '    Add-DhcpServerV4ExclusionRange @Splat -Verbose';
        ' ';
        '   (3,$Item.Gateway),';
        '   (6,$Item.Dns),';
        '   (15,$Item.Domain),';
        '   (28,$Item.Dhcp.Broadcast) | % {';
        '    ';
        '       Set-DhcpServerV4OptionValue -OptionId $_[0] -Value $_[1] -Verbose'
        '   }';
        '}';
        'netsh dhcp add securitygroups';
        'Restart-Service dhcpserver';
        ' ';
        '$Splat    = @{ ';
        ' ';
        '    Path  = "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12"';
        '    Name  = "ConfigurationState"';
        '    Value = 2';
        '}';
        ' ';
        'Set-ItemProperty @Splat -Verbose'))
    }
    InitializeFeAd([String]$Pass)
    {
        $This.Script.Add(17,'InitializeAd','Initialize [FightingEntropy()] AdInstance',@(
        '$Password = Read-Host "Enter password" -AsSecureString';
        '<Pause[2]>';
        '{0}' -f $Pass;
        '$Ctrl = Initialize-FeAdInstance';
        ' ';
        '# Set location';
        '$Ctrl.SetLocation("1718 US-9","Clifton Park","NY",12065,"US")';
        ' ';
        '# Add Organizational Unit';
        '$Ctrl.AddAdOrganizationalUnit("DevOps","Developer(s)/Operator(s)")';
        ' ';
        '# Get Organizational Unit';
        '$Ou     = $Ctrl.GetAdOrganizationalUnit("DevOps")';
        ' ';
        '# Add Group';
        '$Ctrl.AddAdGroup("Engineering","Security","Global","Secure Digits Plus LLC",$Ou.DistinguishedName)';
        ' ';
        '# Get Group';
        '$Group  = $Ctrl.GetAdGroup("Engineering")';
        ' ';
        '# Add-AdPrincipalGroupMembership';
        '$Ctrl.AddAdPrincipalGroupMembership($Group.Name,@("Administrators","Domain Admins"))';
        ' ';
        '# Add User';
        '$Ctrl.AddAdUser("Michael","C","Cook","mcook85",$Ou.DistinguishedName)';
        ' ';
        '# Get User';
        '$User   = $Ctrl.GetAdUser("Michael","C","Cook")';
        ' ';
        '# Set [User.General (Description, Office, Email, Homepage)]';
        '$User.SetGeneral("Beginning the fight against ID theft and cybercrime",';
        '                 "<Unspecified>",';
        '                 "michael.c.cook.85@gmail.com",';
        '                 "https://github.com/mcc85s/FightingEntropy")';
        ' ';
        '# Set [User.Address (StreetAddress, City, State, PostalCode, Country)] ';
        '$User.SetLocation($Ctrl.Location)';
        ' ';
        '# Set [User.Profile (ProfilePath, ScriptPath, HomeDirectory, HomeDrive)]';
        '$User.SetProfile("","","","")';
        ' ';
        '# Set [User.Telephone (HomePhone, OfficePhone, MobilePhone, Fax)]';
        '$User.SetTelephone("","518-406-8569","518-406-8569","")';
        ' ';
        '# Set [User.Organization (Title, Department, Company)]';
        '$User.SetOrganization("CEO/Security Engineer","Engineering","Secure Digits Plus LLC")';
        ' ';
        '# Set [User.AccountPassword]';
        '$User.SetAccountPassword($Password)';
        ' ';
        '# Add user to group';
        '$Ctrl.AddAdGroupMember($Group,$User)';
        ' ';
        '# Set user primary group';
        '$User.SetPrimaryGroup($Group)'))
    }
    Load()
    {
        $This.SetPersistentInfo()
        $This.SetTimeZone()
        $This.SetComputerInfo()
        $This.SetIcmpFirewall()
        $This.SetInterfaceNull()
        $This.SetStaticIp()
        $This.SetWinRm()
        $This.SetWinRmFirewall()
        $This.SetRemoteDesktop()
        $This.InstallFeModule()
        $This.InstallChoco()
        $This.InstallVsCode()
        $This.InstallBossMode()
        $This.InstallPsExtension()
        $This.RestartComputer()
        $This.ConfigureDhcp()
    }
    [String] ProgramData()
    {
        Return [Environment]::GetEnvironmentVariable("ProgramData")
    }
    [String] Author()
    {
        Return "Secure Digits Plus LLC"
    }
    [Object] Now()
    {
        Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
    }
    [String] LogPath()
    {
        $xPath = $This.ProgramData()

        ForEach ($Folder in $This.Author(), "Logs")
        {
            $xPath = $xPath, $Folder -join "\"
            If (![System.IO.Directory]::Exists($xPath))
            {
                [System.IO.Directory]::CreateDirectory($xPath)
            }
        }

        Return $xPath
    }
    [Object] PSSession([Object]$Admin)
    {
        # Attempt login
        $This.Update(0,"[~] PSSession")
        $Splat = @{

            ComputerName  = $This.Network.IpAddress
            Port          = 5986
            Credential    = $Admin.Credential
            SessionOption = New-PSSessionOption -SkipCACheck
            UseSSL        = $True
        }

        Return $Splat
    }
    DumpConsole()
    {
        $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
        $This.Update(100,"[+] Dumping console: [$xPath]")
        $This.Console.Finalize()
        
        $Value = $This.Console.Output | % ToString

        [System.IO.File]::WriteAllLines($xPath,$Value)
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class VmController
{
    [String]     $Path
    [String]   $Domain
    [String]  $NetBios
    [Object]     $Node
    [Object]    $Admin
    [UInt32] $Selected
    [Object[]]   $File
    [Object]    $Image
    VmController([String]$Path,[String]$Domain,[String]$NetBios)
    {
        $This.Path     = $Path
        $This.Domain   = $Domain
        $This.NetBios  = $NetBios
        $This.File     = @( )
        $This.Image    = $This.ImageController()
    }
    [Object] ImageController()
    {
        Return ImageController
    }
    [Object] VmNodeController()
    {
        Return [VmNodeController]::New($This.Path,$This.Domain,$This.NetBios)
    }
    [Object] VmNodeInputObject([Object]$Token)
    {
        Return [VmNodeInputObject]::New($Token,$This.Path)
    }
    [Object] VmAdminCredential()
    {
        $Item = Get-ChildItem $This.Path | ? Name -eq admin.txt
        If (!$Item)
        {
            Throw "Admin file not found"
        }

        Return [VmAdminCredential]::New($Item)
    }
    Select([UInt32]$Index)
    {
        If ($Index -gt $This.File.Count)
        {
            Throw "Index is too large"
        }

        $This.Selected = $Index
    }
    [Object] Current()
    {
        Return $This.File[$This.Selected]
    }
    [Object] VmObject()
    {
        Return [VmObject]::New($This.Current().Object)
    }
    [Object] VmObject([Switch]$Flags,[Object]$Item)
    {
        Return [VmObject]::New([Switch]$True,$Item)
    }
    GetNodeController()
    {
        $This.Node    = $This.VmNodeController()
    }
    GetNodeInputObject([String]$Token)
    {
        If ($Token -notin (Get-ChildItem $This.Path).Name)
        {
            Throw "Invalid file"
        }

        $This.File   += $This.VmNodeInputObject($Token)
    }
    GetNodeAdminCredential()
    {
        $This.Admin   = $This.VmAdminCredential()
    }
    Prime()
    {
        $Item         = Get-VM -Name $This.Current().Object.Name -EA 0
        If ($Item)
        {
            $Vm       = $This.VmObject([Switch]$True,$Item)
            $Vm.Update(1,"[_] Removing $($Vm.Name)")
            ForEach ($Property in $Vm.PSObject.Properties)
            {
                $Line = "[_] {0} : {1}" -f $Property.Name.PadRight(10," "), $Property.Value
                $Vm.Update(1,$Line)
            }
            $Vm.Remove()
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmController>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Creation Area [~]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

    // ==================================================================================
    // | Spawn up a hive controller to create file system objects for each Hyper-V host |
    // | to automate all of the stuff each VM node will be reproducing                  |
    // ==================================================================================

#>

# // Loads the module for various assets
$Module        = Get-FEModule -Mode 1
$Iso           = "C:\Images\Windows-22H2.iso"

# // Instantiates the virtual machine controller class factory
$Hive          = [VmController]::New("C:\FileVm","securedigitsplus.com","SECURED")
$Module.Write("Getting [~] Node Controller")
$Hive.GetNodeController()

# // Creates the virtual machine node template
$Module.Write("Setting [~] Node Template")
$Hive.Node.SetTemplate("C:\VDI",2048MB,64GB,2,2,"External",$Iso)

# // Extract the Windows image information from the (*.iso)
$Module.Write("Extracting [~] Iso Information")
$Hive.Image.LoadSilo("C:\Images")

$Token         = $Hive.Image.Store | ? Path -eq $Iso

# // Select the specifically defined (*.iso) file
$Module.Write("Loading [~] Iso: [$Iso]")
$Hive.Image.LoadIso($Token.Index)

# // Get the full path of the correct [install.(wim/esd)] file
$ImagePath     = "{0}:\" -f $Hive.Image.Selected.Letter
$List          = Get-ChildItem $ImagePath

If ("x64" -in $List.Name)
{
    $ImagePath = Get-Item "$ImagePath\x64\sources\install.*" | % Fullname
}

# // Extract the image information from the [install.(wim/esd)] file
$Module.Write("Getting [~] Windows Image(s)")
$Hive.Image.Selected.GetWindowsImage($ImagePath)

# // Display the total images in the [install.(wim/esd)] file
$Hive.Image.Selected.Content | % { Write-Output $_ }

$Target    = $Hive.Image.Selected.Content | ? Description -match "^Windows 10 Pro$"
$Span      = $Target.Index-1

Write-Theme -Title "Image selected" -InputObject $Target -Prompt "Edition: [$($Target.DestinationName)]" 

If ($Target)
{
    $Module.Write("Unloading [~] Iso: [$Iso]")
    $Hive.Image.UnloadIso()
}

# // Load security options, need (account information) from (cimdb)
$Security = SecurityOption
$Security.SetAccount($Account)
$Security.SetCredential()

# // Populates the factory class with (1) node
$Hive.Node.AddNode("desktop00")

# // Exports the file system objects
$Hive.Node.Export()
$Hive.Node.WriteAdmin()

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Action Area [~]                                                                                ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

# // Reinstantiates the file system information
$Token       = "desktop00.txt"

$Hive.GetNodeAdminCredential()
$Hive.GetNodeInputObject($Token)

# // Checks for existence of virtual machine by that name
$Hive.Prime()

# // Object instantiation
$Vm          = $Hive.VmObject()
$Vm.New()
$Vm.AddVmDvdDrive()
$Vm.LoadIso($Vm.Iso)
$Vm.SetIsoBoot()
$Vm.Connect()
    
# // Start Machine
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard") | ? Path -match $Vm.Control.Name

# // Wait for "Press enter to boot from CD/DVD", then press enter, then start [64-bit]
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // Wait for "Install Windows" menu
$Vm.Idle(5,5)

# // Hit [N]ext
$Vm.SpecialKey(78)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Idle(5,2)

# // Enter Product Key or skip.
$Vm.SpecialKey([UInt32][Char]"I")
$Vm.Timer(2)

# // Select version of Windows
$Vm.TypeChain(@(@(40) * $Span))
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // Accept license terms
$Vm.TypeKey(32)
$Vm.Timer(2)
$Vm.SpecialKey([UInt32][Char]"N")
$Vm.Timer(2)

# // Select custom install
$Vm.SpecialKey([UInt32][Char]"C")
$Vm.Timer(2)

# // Set partition
$Vm.SpecialKey([UInt32][Char]"N")

# // Wait until Windows installation completes
$Vm.Idle(5,5)

# // Catch and release ISO upon reboot
$Vm.Uptime(0,5)
$Vm.UnloadIso()

# // Wait for the computer to perform inital setup, and reboot
$Vm.Idle(5,5)

# // Wait for (OOBE/Out-of-Box Experience) screen
$Vm.Idle(5,5)

# // [Region, default = United States]
$Vm.TypeKey(13) # [Yes]
$Vm.Idle(5,2)

# // [Keyboard layout, default = US]
$Vm.TypeKey(13) # [Yes]
$Vm.Timer(1)
$Vm.TypeKey(13) # [Skip]
$Vm.Idle(5,2)

# // [Network, default = Automatic]
# <expand here for non-networked>

# // [Account, default = Personal Use]
# <expand here for Active Directory/organization>
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // [OneDrive setup]
$Vm.TypeChain(@(9,9,9,9,32))
$Vm.Idle(5,2)

# // [Limited Experience]
$Vm.TypeChain(@(9,9,32))
$Vm.Idle(5,2)

# // [Who's gonna use this PC...? Hm...?]
$Vm.TypeText($Security.Un())
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Create a super memorable password/Confirm]
0..1 | % { 

    $Vm.TypePassword($Security.Pw())
    $Vm.TypeKey(13)
    $Vm.Timer(2)
}

# // [Create security questions]
0..2 | % {

    $Vm.TypeKey(40)
    $Vm.TypeKey(9)
    $Vm.TypeText("Default")
    $Vm.TypeKey(13)
    $Vm.Timer(1)
}

# // [Chose privacy settings]
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // [Let's customize your experience]
$Vm.TypeChain(@(9,9,9,9,9,9,9,9))
$Vm.TypeKey(13)
$Vm.Idle(5,2)

# // [Let Cortana help you get s*** done]
$Vm.TypeKey(13)
$Vm.Idle(2,5)

# // [Launch PowerShell, establish OS version control]

# // Open Start Menu
$Vm.PressKey(91)
$Vm.TypeKey(88)
$Vm.ReleaseKey(91)
$Vm.Timer(1)

# // Open [PowerShell]
$Vm.TypeKey(65)
$Vm.Timer(2)
$Vm.TypeKey(37)
$Vm.Timer(2)
$Vm.TypeKey(13)
$Vm.Timer(2)

# // Maximize window
$Vm.PressKey(91)
$Vm.TypeKey(38)
$Vm.ReleaseKey(91)
$Vm.Timer(1)

# // Wait for [PowerShell] engine to get ready for input
$Vm.Idle(5,5)

# // [Server 2016]
# Loads all scripts
$Vm.Load()

# // Set persistent info
$Vm.RunScript()
$Vm.Timer(5)

# // Set time zone
$Vm.RunScript()
$Vm.Timer(1)

# // Set computer info
$Vm.RunScript()
$Vm.Timer(3)

# // Set Icmp Firewall
$Vm.RunScript()
$Vm.Timer(5)

# // Set network interface to null
$Vm.RunScript()
$Vm.Timer(5)

# // Set static IP
$Vm.RunScript()
$Vm.Connection()

# // Set WinRm
$Vm.RunScript()
$Vm.Timer(5)

# // Set WinRmFirewall
$Vm.RunScript()
$Vm.Timer(5)

# // Set Remote Desktop
$Vm.RunScript()
$Vm.Timer(5)

# // Install FightingEntropy
$Vm.RunScript()
$Vm.Idle(0,5)

# // Install Chocolatey
$Vm.RunScript()
$Vm.Idle(0,5)

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Split [~] Work area                                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

# // Install VsCode | (Timer + Idle) Network Metering needed here...
$Vm.RunScript()
$Vm.Idle(0,5)

# // Install BossMode
$Vm.RunScript()
$Vm.Idle(0,5)

# // Install PsExtension
$Vm.RunScript()
$Vm.Idle(0,5)

# // Restart computer
$Vm.RunScript()
$Vm.Uptime(0,5)
$Vm.Uptime(1,40)
$Vm.Idle(5,5)

# // Wait for (reboot/idle)
$Vm.Uptime(0,5)
$Vm.Idle(5,10)

# // [Login]
$Vm.TypeCtrlAltDel()
$Vm.Timer(1)
$Vm.TypeText($Security.Pw())
$Vm.TypeKey(13)
$Vm.Timer(1)
