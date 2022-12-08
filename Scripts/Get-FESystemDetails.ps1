

Function Get-FESystemDetails
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)]
        [Parameter(Mandatory,ParameterSetName=1)]
        [Parameter(Mandatory,ParameterSetName=2)][UInt32]$Mode,
        [Parameter(Mandatory,ParameterSetName=1)][String]$Path,
        [Parameter(Mandatory,ParameterSetName=2)][Object]$InputObject
    )

    Class SystemProperty
    {
        [UInt32] $Index
        [UInt32] $Rank
        [String] $Source
        [String] $Name
        [UInt32] $Buffer
        [Object] $Value
        SystemProperty([UInt32]$Index,[UInt32]$Rank,[String]$Source,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.Source = $Source
            $This.Name   = $Name
            $This.Buffer = $Name.Length
            $This.Value  = $Value
        }
        SetBuffer([UInt32]$Width)
        {
            If ($This.Buffer -lt $Width)
            {
                $This.Buffer = $Width
            }
        }
        [String] ToString()
        {
            Return "{0} {1}" -f $This.Name.PadRight($This.Buffer," "), $This.Value
        }
    }

    # // _____________________________________________________________
    # // | Takes a snapshot of the system with date/time, guid, etc. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Snapshot
    {
        [String] $Start
        [String] $ComputerName
        [String] $DisplayName
        [String] $Guid
        [UInt32] $Complete
        [String] $Elapsed
        Snapshot()
        {
            $Current           = [DateTime]::Now
            $This.Start        = $Current
            $This.ComputerName = [Environment]::MachineName
            $This.DisplayName  = "{0}-{1}" -f $Current.ToString("yyyy-MMdd-HHmmss"), $This.ComputerName
            $This.Guid         = [Guid]::NewGuid().ToString()
        }
        Snapshot([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        MarkComplete()
        {
            $This.Complete     = 1 
            $This.Elapsed      = [String][Timespan]([DateTime]::Now-[DateTime]$This.Start)
        }
        [String] ToString()
        {
            Return "{0}" -f $This.ComputerName
        }
    }

    # // _______________________________________________________
    # // | Bios Information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class BiosInformation
    {
        [String] $Name
        [String] $Manufacturer
        [String] $SerialNumber
        [String] $Version
        [String] $ReleaseDate
        [Bool]   $SmBiosPresent
        [String] $SmBiosVersion
        [String] $SmBiosMajor
        [String] $SmBiosMinor
        [String] $SystemBiosMajor
        [String] $SystemBiosMinor
        BiosInformation()
        {
            $Bios                 = Get-CimInstance Win32_Bios
            $This.Name            = $Bios.Name
            $This.Manufacturer    = $Bios.Manufacturer
            $This.SerialNumber    = $Bios.SerialNumber
            $This.Version         = $Bios.Version
            $This.ReleaseDate     = $Bios.ReleaseDate
            $This.SmBiosPresent   = $Bios.SmBiosPresent
            $This.SmBiosVersion   = $Bios.SmBiosBiosVersion
            $This.SmBiosMajor     = $Bios.SmBiosMajorVersion
            $This.SmBiosMinor     = $Bios.SmBiosMinorVersion
            $This.SystemBiosMajor = $Bios.SystemBiosMajorVersion
            $This.SystemBIosMinor = $Bios.SystemBiosMinorVersion
        }
        BiosInformation([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Name
        }
    }

    # // ___________________________________________________________________
    # // | Operating system information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class OperatingSystem
    {
        [String] $Caption
        [String] $Version
        [String] $Build
        [String] $Serial
        [UInt32] $Language
        [UInt32] $Product
        [UInt32] $Type
        OperatingSystem()
        {
            $OS            = Get-CimInstance Win32_OperatingSystem
            $This.Caption  = $OS.Caption
            $This.Version  = $OS.Version
            $This.Build    = $OS.BuildNumber
            $This.Serial   = $OS.SerialNumber
            $This.Language = $OS.OSLanguage
            $This.Product  = $OS.OSProductSuite
            $This.Type     = $OS.OSType
        }
        OperatingSystem([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return "{0} {1}-{2}" -f $This.Caption, $This.Version, $This.Build
        }
    }

    # // __________________________________________________________________
    # // | Computer system information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ComputerSystem
    {
        [String] $Manufacturer
        [String] $Model
        [String] $Product
        [String] $Serial
        [String] $Memory
        [String] $Architecture
        [String] $UUID
        [String] $Chassis
        [String] $BiosUefi
        [Object] $AssetTag
        ComputerSystem()
        {
            $Computer          = @{ 
             
                System         = Get-CimInstance Win32_ComputerSystem 
                Product        = Get-CimInstance Win32_ComputerSystemProduct
                Board          = Get-CimInstance Win32_BaseBoard
                Form           = Get-CimInstance Win32_SystemEnclosure
            }

            $This.Manufacturer = $Computer.System.Manufacturer
            $This.Model        = $Computer.System.Model
            $This.Memory       = "{0:n2} GB" -f ($Computer.System.TotalPhysicalMemory/1GB)
            $This.UUID         = $Computer.Product.UUID 
            $This.Product      = $Computer.Product.Version
            $This.Serial       = $Computer.Board.SerialNumber -Replace "\.",""
            $This.BiosUefi     = Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                "UEFI"
            }
            Catch
            {
                "BIOS"
            }

            $This.AssetTag     = $Computer.Form.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$Computer.Form.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[[Environment]::GetEnvironmentVariable("Processor_Architecture")]
        }
        ComputerSystem([Object]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Model
        }
    }

    # // ____________________________________________________________
    # // | Processor information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Processor
    {
        Hidden [UInt32] $Rank
        [String] $Manufacturer
        [String] $Name
        [String] $Caption
        [UInt32] $Cores
        [UInt32] $Used
        [UInt32] $Logical
        [UInt32] $Threads
        [String] $ProcessorId
        [String] $DeviceId
        [UInt32] $Speed
        Processor([UInt32]$Rank,[Object]$CPU)
        {
            $This.Rank         = $Rank
            $This.Manufacturer = Switch -Regex ($CPU.Manufacturer) { Intel { "Intel" } Amd { "AMD" } }
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.Cores        = $CPU.NumberOfCores
            $This.Used         = $CPU.NumberOfEnabledCore
            $This.Logical      = $CPU.NumberOfLogicalProcessors 
            $This.Threads      = $CPU.ThreadCount
            $This.ProcessorID  = $CPU.ProcessorId
            $This.DeviceID     = $CPU.DeviceID
            $This.Speed        = $CPU.MaxClockSpeed
        }
        Processor([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Rank         = $Rank

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // __________________________________________
    # // | Processor container, handles 1 or more |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Processors
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Processors()
        {
            $This.Name    = "Processor(s)"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetProcessors()
        {
            $This.Output   = @( )
            $This.Count    = 0
            ForEach ($Processor in Get-CimInstance Win32_Processor)
            {
                $This.Output += [Processor]::New($This.Output.Count,$Processor)
                $This.Count  ++
            }
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output  += [Processor]::New($Rank,$Pairs,[Switch]$True)
            $This.Count   ++
        }
        RemoveProcessor([UInt32]$Rank)
        {
            $This.Output  = $This.Output | ? Rank -ne $Rank
            $This.Count  --
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, $This.Name
        }
    }

    # // __________________________________________________________________
    # // | Drive/partition information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Partition
    {
        [UInt32]      $Rank
        [String]      $Type
        [String]      $Name
        [String]      $Size
        [UInt32]      $Boot
        [UInt32]   $Primary
        [UInt32]      $Disk
        [UInt32] $Partition
        Partition([UInt32]$Rank,[Object]$Partition)
        {
            $This.Rank       = $Rank
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.Size       = $Partition.Size
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.Partition  = $Partition.Index
        }
        Partition([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Rank       = $Rank

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return "[{0}/{1}]" -f $This.Name, $This.Size
        }
    }

    # // ________________________________________________________________
    # // | Specifically for single/multiple partitions on a given drive |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Partitions
    {
        [UInt32] $Count
        [Object] $Output
        Partitions()
        {
            $This.Output = @( )
        }
        Add([UInt32]$Rank,[Object]$Partition)
        {
            $This.Output += [Partition]::New($Rank,$Partition)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output += [Partition]::New($Rank,$Pairs,[Switch]$True)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ___________________________________________________________________________________________
    # // | Specifically for a single volume on a given drive, meant for injecting with a partition |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Volume
    {
        [UInt32] $Rank
        [String] $DriveID
        [String] $Description
        [String] $Filesystem
        [Object] $Partition
        [String] $VolumeName
        [String] $VolumeSerial
        Hidden [UInt64] $FreespaceBytes
        [String] $Freespace
        Hidden [UInt64] $UsedBytes
        [String] $Used
        Hidden [UInt64] $SizeBytes
        [String] $Size
        Volume([UInt32]$Rank,[Object]$Drive)
        {
            $This.Rank              = $Rank
            $This.DriveID           = $Drive.Name
            $This.Description       = $Drive.Description
            $This.Filesystem        = $Drive.Filesystem
            $This.VolumeName        = $Drive.VolumeName
            $This.VolumeSerial      = $Drive.VolumeSerial
            # $This.FreespaceBytes    = $Drive.Freespace
            # $This.UsedBytes         = $Drive.Size-$Drive.Freespace
            # $This.SizeBytes         = $Drive.Size
        }
        Volume([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Rank              = $Rank

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return "[{0}\ {1}]" -f $This.DriveID, $This.Size
        }
    }

    # // _____________________________________________________________
    # // | Specifically for single/multiple volumes on a given drive |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Volumes
    {
        [UInt32] $Count
        [Object] $Output
        Volumes()
        {
            $This.Output  = @( )
        }
        Add([UInt32]$Rank,[Object]$Drive)
        {
            $This.Output += [Volume]::New($Rank,$Drive)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output += [Volume]::New($Rank,$Pairs,[Switch]$True)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ________________________________________
    # // | Extended information for hard drives |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Disk
    {
        Hidden [UInt32]       $Rank
        [UInt32]             $Index
        [String]              $Disk
        [String]             $Model
        [String]            $Serial
        [String]    $PartitionStyle
        [String]  $ProvisioningType
        [String] $OperationalStatus
        [String]      $HealthStatus
        [String]           $BusType
        [String]          $UniqueId
        [String]          $Location
        [Object]         $Partition
        [Object]            $Volume
        Disk([UInt32]$Rank,[Object]$Disk)
        {
            $This.Rank              = $Rank
            $This.Index             = $Disk.Index
            $This.Disk              = $Disk.DeviceId
            $This.Partition         = [Partitions]::New()
            $This.Volume            = [Volumes]::New()

            $MSFTDISK               = Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $Disk.Index
            If (!$MSFTDISK)
            {
                Throw "Unable to set the drive data"
            }

            $This.Model             = $MSFTDISK.Model
            $This.Serial            = $MSFTDISK.SerialNumber.TrimStart(" ")
            $This.PartitionStyle    = $MSFTDISK.PartitionStyle
            $This.ProvisioningType  = $MSFTDISK.ProvisioningType
            $This.OperationalStatus = $MSFTDISK.OperationalStatus
            $This.HealthStatus      = $MSFTDISK.HealthStatus
            $This.BusType           = $MSFTDISK.BusType
            $This.UniqueId          = $MSFTDISK.UniqueId
            $This.Location          = $MSFTDISK.Location
            
            $DiskPartition          = @( )
            ForEach ($Partition in Get-CimInstance Win32_DiskPartition | ? DiskIndex -eq $Disk.Index)
            { 
                $DiskPartition += [Partition]::New($DiskPartition.Count,$Partition)
            }

            Switch ($DiskPartition.Count)
            {
                0
                {
                    Write-Host "No disk partitions detected"
                }
                Default
                {
                    ForEach ($Item in $DiskPartition)
                    {
                        $Item.Size          = $This.GetSize($Item.Size)
                        $This.Partition.Add($This.Partition.Output.Count,$Item)
                    }
                }
            }

            $LogicalDisk            = @( )
            ForEach ($Disk in Get-CimInstance Win32_LogicalDisk | ? DriveType -eq 3)
            { 
                $LogicalDisk += [Volume]::New($LogicalDisk.Count,$Disk)
            }

            Switch ($LogicalDisk.Count)
            {
                0
                {
                    Write-Host "No disk volumes detected"
                }
                Default
                {
                    ForEach ($Logical in Get-CimInstance Win32_LogicalDiskToPartition | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name})
                    {
                        $Part = $DiskPartition | ? Name    -eq $Logical.Antecedent.DeviceID
                        $Item = $LogicalDisk   | ? DriveID -eq $Logical.Dependent.DeviceID
                        If ($Part -and $Item)
                        {
                            $Item.Partition      = $Part
                            $Item.Freespace      = $This.GetSize($Item.FreespaceBytes)
                            $Item.Used           = $This.GetSize($Item.UsedBytes)
                            $Item.Size           = $This.GetSize($Item.SizeBytes)
                            $This.Volume.Add($This.Volume.Output.Count,$Item)
                        }
                    }
                }
            }
        }
        Disk([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Rank = $Rank

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }

            $This.Partition         = [Partitions]::New()
            $This.Volume            = [Volumes]::New()
        }
        LoadPartition([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Partition.Add($Rank,$Pairs,[Switch]$True)
        }
        LoadVolume([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Volume.Add($Rank,$Pairs,[Switch]$True)
        }
        [String] GetSize([Int64]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -lt 1GB}
                {
                    "{0:n2} MB" -f ($Size/1MB)
                }
                {$_ -ge 1GB -and $_ -lt 1TB}
                {
                    "{0:n2} GB" -f ($Size/1GB)
                }
                {$_ -ge 1TB}
                {
                    "{0:n2} TB" -f ($Size/1TB)
                }
            })
        }
        [Void] WriteCheck()
        {
            If ($This.Mode -ne 0)
            {
                Throw "Invalid operation"
            }
        }
        [String] ToString()
        {
            Return "{0}({1})" -f $This.Model, $This.Rank
        }
    }
    
    # // _____________________________________________________________________________________
    # // | Drive/file formatting information (container), for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Disks
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Disks()
        {
            $This.Name    = "Disk(s)"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetDisks()
        {
            $This.Output   = @( )
            $This.Count    = 0
            ForEach ($Disk in Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed)
            {
                $This.Output += [Disk]::New($This.Output.Count,$Disk)
                $This.Count  ++
            }
        }
        AddDisk([Object]$Disk)
        {
            $This.Output += $Disk
            $This.Count   = $This.Output.Count
        }
        RemoveDisk([UInt32]$Index)
        {
            $This.Output  = $This.Output | ? Index -ne $Index
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, $This.Name
        }
    }

    # // ________________________________________________
    # // | Connected/Online Network adapter information |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Network
    {
        [UInt32] $Rank
        [String] $Name
        [String] $IPAddress
        [String] $SubnetMask
        [String] $Gateway
        [String] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([UInt32]$Rank,[Object]$If)
        {
            $This.Rank            = $Rank
            $This.Name            = $If.Description
            If ($If.IPEnabled)
            {
                $This.IPAddress   = $If.IPAddress             | ? {$_ -match "(\d+\.){3}\d+"}
                $This.SubnetMask  = $If.IPSubnet              | ? {$_ -match "(\d+\.){3}\d+"}
                If ($If.DefaultIPGateway)
                {
                    $This.Gateway = $If.DefaultIPGateway      | ? {$_ -match "(\d+\.){3}\d+"}
                }
                $This.DnsServer   = ($If.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}) -join ", "
                $This.DhcpServer  = $If.DhcpServer            | ? {$_ -match "(\d+\.){3}\d+"}
            }
            $This.MacAddress      = $If.MacAddress
        }
        Network([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Rank              = $Rank

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ____________________________________
    # // | Network adapter container object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Networks
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Networks()
        {
            $This.Name        = "Network(s)"
            $This.Count       = 0
            $This.Output      = @( )
        }
        GetNetworks()
        {
            $This.Output      = @( )
            $This.Count       = 0
            ForEach ($Network in Get-CimInstance Win32_NetworkAdapterConfiguration)
            {
                $This.Output += [Network]::New($This.Output.Count,$Network)
                $This.Count   = $This.Output.Count
            }
        }
        Add([Object[]]$Network,[Switch]$Flags)
        {
            $This.Output     += [Network]::New($This.Output.Count,$Network,[Switch]$True)
            $This.Count       = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, $This.Name
        }
    }

    # // _____________________________________________________
    # // | System snapshot, the primary focus of the utility |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class System
    {
        [Object] $Snapshot
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object] $ComputerSystem
        [Object] $Processor
        [Object] $Disk
        [Object] $Network
        System()
        {
            $This.Snapshot         = [Snapshot]::New()
            $This.BiosInformation  = [BiosInformation]::New()
            $This.OperatingSystem  = [OperatingSystem]::New() 
            $This.ComputerSystem   = [ComputerSystem]::New()
            $This.Processor        = [Processors]::New()
            $This.Processor.GetProcessors()
            $This.Disk             = [Disks]::New()
            $This.Disk.GetDisks()
            $This.Network          = [Networks]::New()
            $This.Network.GetNetworks()
        }
        System([Switch]$Flag)
        {

        }
        [Object] SystemProperty([UInt32]$Index,[UInt32]$Rank,[String]$Source,[String]$Name,[Object]$Value)
        {
            Return [SystemProperty]::New($Index,$Rank,$Source,$Name,$Value)
        }
        [Object] Output()
        {
            $Out    = @( )

            # Snapshot, BiosInfo, OperatingSystem, ComputerSystem
            ForEach ($Source in "Snapshot","BiosInformation","OperatingSystem","ComputerSystem")
            {
                $Label              = @{

                    Snapshot        = "Snapshot"
                    BiosInformation = "Bios Information"
                    OperatingSystem = "Operating System"
                    ComputerSystem  = "Computer System"

                }[$Source]

                $Out      += $This.SystemProperty($Out.Count,0,"Header","-","")
                $Out      += $This.SystemProperty($Out.Count,0,"Header",$Label,"")
                $Out      += $This.SystemProperty($Out.Count,0,"Header","-","")
                $Out      += $This.SystemProperty($Out.Count,0,"Header","","")
                $Rank      = 0
                $This.$Source.PSObject.Properties | % {

                    $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                    $Rank ++
                }
                $Out      += $This.SystemProperty($Out.Count,0,"Footer","","")
            }

            # Processor
            $Step          = 0
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            $Out          += $This.SystemProperty($Out.Count,0,"Header","Processor(s)",$This.Processor.Count)
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            ForEach ($Processor in $This.Processor.Output)
            {
                $Source    = "Processor$Step"
                $Rank      = 0

                # Label
                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"","")
                $Rank     ++

                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,$Source,"")
                $Rank     ++

                # Properties
                $Processor.PSObject.Properties | % { 

                    $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                    $Rank ++
                }

                $Step     ++
            }
            $Out          += $This.SystemProperty($Out.Count,0,"Footer","","")

            # Disk
            $Step          = 0
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            $Out          += $This.SystemProperty($Out.Count,0,"Header","Disk(s)",$This.Disk.Count)
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            ForEach ($Disk in $This.Disk.Output)
            {
                $Source    = "Disk$Step"
                $Rank      = 0

                # Label
                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"","")
                $Rank     ++

                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,$Source,"")
                $Rank     ++

                # Properties
                $Disk.PSObject.Properties | % { 

                    If ($_.Name -eq "Partition")
                    {
                        $Part          = 0
                        ForEach ($Partition in $Disk.Partition.Output)
                        {
                            # Label
                            $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"","")
                            $Rank     ++

                            $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"Partition$Part","")
                            $Rank     ++

                            # Properties
                            $Partition.PSObject.Properties | % { 

                                $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                                $Rank ++
                            }
                            $Part     ++
                        }
                    }

                    ElseIf ($_.Name -eq "Volume")
                    {
                        $Vol           = 0
                        ForEach ($Volume in $Disk.Volume.Output)
                        {
                            # Label
                            $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"","")
                            $Rank     ++

                            $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"Volume$Vol","")
                            $Rank     ++

                            # Properties
                            $Volume.PSObject.Properties | % { 

                                $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                                $Rank ++
                            }
                            $Vol      ++
                        }
                    }

                    Else
                    {
                        # Properties
                        $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                        $Rank ++
                    }
                }

                $Step     ++
            }
            $Out          += $This.SystemProperty($Out.Count,0,"Footer","","")

            # Network
            $Step = 0
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            $Out          += $This.SystemProperty($Out.Count,0,"Header","Network(s)",$This.Network.Count)
            $Out          += $This.SystemProperty($Out.Count,0,"Header","-","")
            ForEach ($Network in $This.Network.Output)
            {
                $Source    = "Network$Step"
                $Rank      = 0

                # Label
                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,"","")
                $Rank     ++

                $Out      += $This.SystemProperty($Out.Count,$Rank,$Source,$Source,"")
                $Rank     ++

                # Properties
                $Network.PSObject.Properties | % { 

                    $Out  += $This.SystemProperty($Out.Count,$Rank,$Source,$_.Name,$_.Value)
                    $Rank ++
                }

                $Step     ++
            }
            $Out          += $This.SystemProperty($Out.Count,0,"Footer","","")

            $Max  = ($Out | Sort-Object Buffer)[-1]
            $Hash = @{ }
            ForEach ($Item in $Out)
            {
                $Item.SetBuffer($Max.Buffer)
                If ($Item.Source -eq "Header" -and $Item.Name -eq "-")
                {
                    $Line = @("-") * 120 -join ''
                }
                Else
                {
                    $Line = $Item.ToString()
                }

                $Hash.Add($Hash.Count,$Line)
            }

            Return $Hash[0..($Hash.Count-1)]
        }
        [String] ToString()
        {
            Return "{0}, {1} | {2}, {3} {4}-{5}" -f $This.Snapshot.ComputerName, $This.ComputerSystem.Manufacturer, $This.ComputerSystem.Model, 
            $This.OperatingSystem.Caption, $This.OperatingSystem.Version, $This.OperatingSystem.Build
        }
    }

    # // _________________________________________________
    # // | Parses each individual line of the outputfile |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ParseLine
    {
        [UInt32] $Index
        [UInt32]  $Rank
        [UInt32]  $Type
        [String]  $Line
        ParseLine([UInt32]$Index,[UInt32]$Rank,[UInt32]$Type,[String]$Line)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Type  = $Type
            $This.Line  = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    Class ParseBody
    {
        Hidden [Object] $Content
        [Object] $Process
        [UInt32] $Buffer
        [Object] $Output
        [Object] $System
        ParseBody([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid path"
            }

            # Import input file from path, assign to content property
            $This.Content = [System.IO.File]::ReadAllLines($Path) | % TrimEnd " "

            $This.Init()
        }
        ParseBody([Object]$InputObject,[Switch]$Flags)
        {
            # Assign memory object to content property
            $This.Content = $InputObject

            $This.Init()
        }
        Init()
        {
            $This.Process = @( )
            $This.Output  = @( )
            $This.System  = [System]::New([Switch]$True)

            # Convert all of the input object content into ranked process objects
            $Rank         = 0
            ForEach ($X in 0..($This.Content.Count-1))
            {
                $Line = $This.Content[$X]
                Switch -Regex ($Line)
                {
                    "^Snapshot$"
                    {
                        $Rank = 0
                        $This.Add($Rank,0,$Line)
                    } 
                    "^Bios Information$"
                    {
                        $Rank = 1
                        $This.Add($Rank,0,$Line)
                    }
                    "^Operating System$"
                    {
                        $Rank = 2
                        $This.Add($Rank,0,$Line)
                    }
                    "^Computer System$"
                    {
                        $Rank = 3
                        $This.Add($Rank,0,$Line)
                    }
                    "^Processor\(s\)\s+\d+$"
                    {
                        $Rank = 4
                        $This.Add($Rank,0,$Line)
                    }
                    "^Disk\(s\)\s+\d+$"
                    {
                        $Rank = 5
                        $This.Add($Rank,0,$Line)
                    }
                    "^Network\(s\)\s+\d+$"
                    {
                        $Rank = 6
                        $This.Add($Rank,0,$Line)
                    }
                    "^Log Providers\s+\d+$"
                    {
                        $Rank = 7
                        $This.Add($Rank,0,$Line)
                    }
                    "^-{120}$"
                    {

                    }
                    Default
                    {
                        $This.Add($Rank,1,$Line)
                    }
                }
            }

            # Determine the buffer width by locating the longest property name
            $This.Buffer = ($This.Process.Line | ? Length -gt 0 | % { $_.Split(" ")[0] } | Sort-Object Length)[-1].Length + 1

            # Remove spaces from the headers for (Snapshot, BiosInformation, OperatingSystem, ComputerSystem)
            ForEach ($Item in $This.Process | ? Type -eq 0 | ? Line -notmatch "(Processor|Disk|Network)")
            {
                $Item.Line = $Item.Line.Replace(" ","")
            }

            # For process objects within rank 0-3 (Snapshot, Bios, OS, Computer System), convert into output w/ source
            ForEach ($X in 0..3)
            {
                $Section = $This.Process | ? Rank -eq $X
                $Source  = $Section[0].Line -Replace " ",""
                ForEach ($Item in $Section | ? Type -ne 0 | ? { $_.Line.Length -gt 0 } | % Line)
                {
                    If ($Item.Length -le $This.Buffer)
                    {
                        $Value = $Null
                        $Name  = $Item.TrimEnd(" ")
                    }
                    Else
                    {
                        $Value = $Item.Substring($This.Buffer).TrimStart(" ")
                        $Name  = $Item.Replace($Value,"").TrimEnd(" ")
                    }
                    $This.Output += $This.SystemProperty($This.Output.Count,$X,$Source,$Name,$Value)
                }
            }

            # Assign output objects into system property objects (loaded)
            $This.System.Snapshot        = [Snapshot]::New(($This.Output | ? Source -eq Snapshot))
            $This.System.BiosInformation = [BiosInformation]::New(($This.Output | ? Source -eq BiosInformation))
            $This.System.OperatingSystem = [OperatingSystem]::New(($This.Output | ? Source -eq OperatingSystem))
            $This.System.ComputerSystem  = [ComputerSystem]::New(($This.Output | ? Source -eq ComputerSystem))

            # Assign output objects into system property objects (unloaded)
            $This.System.Processor       = [Processors]::New()
            $This.System.Disk            = [Disks]::New()
            $This.System.Network         = [Networks]::New()

            # // ________________
            # // | Processor(s) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            # To load the processor(s) into the container, process objects equal to rank 4 (Processor), into output w/ source
            $Section    = $This.Process | ? Rank -eq 4
            $List       = $Section | ? Type -ne 0 | ? {$_.Line.Length -gt 0}
            $Source     = $Null

            ForEach ($Line in $List.Line)
            {
                If ($Line -match "^Processor\d+$")
                {
                    $Source = $Line
                    $Rank   = [UInt32]($Line -Replace "Processor","")
                    $X      = 0
                }
                Else
                {
                    If ($Line.Length -le $This.Buffer)
                    {
                        $Value = $Null
                        $Name  = $Line.TrimEnd(" ")
                    }
                    Else
                    {
                        $Value = $Line.Substring($This.Buffer)
                        $Name  = $Line.Replace($Value,"").TrimEnd(" ")
                    }
                    $This.Output += $This.SystemProperty($This.Output.Count,$X,$Source,$Name,$Value)
                    $X ++
                }
            }

            # Load the total number of processor objects into the system.processor output container
            ForEach ($Source in $This.Output | ? Source -match Processor | % Source | Select-Object -Unique)
            {
                $Pairs = $This.Output | ? Source -match $Source
                $This.System.Processor.Add($This.System.Processor.Output.Count,$Pairs,[Switch]$True)
            }

            # // ____________
            # // | Disks(s) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯

            # To load the disk(s) into the container, process objects equal to rank 5 (Disk), into output w/ source
            $Section    = $This.Process | ? Rank -eq 5
            $List       = $Section | ? Type -ne 0 | ? {$_.Line.Length -gt 0}
            $Disk       = $Null
            $Source     = $Null

            ForEach ($Line in $List.Line)
            {
                If ($Line -match "^Disk\d+$")
                {
                    $Disk   = [UInt32]($Line -Replace "Disk","")
                    $Source = $Line
                    $Rank   = $Disk
                    $X      = 0
                }
                ElseIf ($Line -match "^Partition\d+$")
                {
                    $Source = "Disk$Disk.$Line"
                    $Rank   = [UInt32]($Line -Replace "Partition","")
                    $X      = 0
                }
                ElseIf ($Line -match "^Volume\d+")
                {
                    $Source = "Disk$Disk.$Line"
                    $Rank   = [UInt32]($Line -Replace "Volume","")
                    $X      = 0
                }
                Else
                {
                    If ($Line.Length -le $This.Buffer)
                    {
                        $Value = $Null
                        $Name  = $Line.TrimEnd(" ")
                    }
                    Else
                    {
                        $Value = $Line.Substring($This.Buffer)
                        $Name  = $Line.Replace($Value,"").TrimEnd(" ")
                    }
                    $This.Output += $This.SystemProperty($This.Output.Count,$X,$Source,$Name,$Value)
                    $X ++
                }
            }
            
            # Load the total number of disk objects into the system.disk output container
            $Disks = $This.Output | ? Source -match ^Disk\d+$ | % Source | Select-Object -Unique
            ForEach ($Disk in $Disks)
            {
                $List       = $This.Output | ? Source -match $Disk

                # Process current disks' main properties
                $Pairs      = $List | ? Source -eq $Disk
                $Temp       = [Disk]::New($This.System.Disk.Output.Count,$Pairs,[Switch]$True)

                # Process Partition(s)
                $Partitions = $List | ? Source -match "$Disk.Partition\d+" | % Source | Select-Object -Unique
                ForEach ($Partition in $Partitions)
                {
                    $Index  = [UInt32]($Partition -Replace "$Disk\.Partition", "")
                    $Pairs  = $List | ? Source -eq $Partition
                    $Temp.Partition.Add($Index,$Pairs,[Switch]$True)
                }

                # Process Volume(s)
                $Volumes    = $List | ? Source -match "$Disk.Volume\d+" | % Source | Select-Object -Unique
                ForEach ($Volume in $Volumes)
                {
                    $Index  = [UInt32]($Volume -Replace "$Disk\.Volume", "")
                    $Pairs  = $List | ? Source -eq $Volume
                    $Temp.Volume.Add($Index,$Pairs,[Switch]$True)
                }

                $This.System.Disk.AddDisk($Temp)
            }

            # // ______________
            # // | Network(s) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            # To load the network adapter(s) into the container, process objects equal to rank 6 (Network), into output w/ source
            $Section    = $This.Process | ? Rank -eq 6
            $List       = $Section | ? Type -ne 0 | ? {$_.Line.Length -gt 0}
            $Source     = $Null

            ForEach ($Line in $List.Line)
            {
                If ($Line -match "^Network\d+$")
                {
                    $Source = $Line
                    $Rank   = [UInt32]($Line -Replace "Network","")
                    $X      = 0
                }
                Else
                {
                    If ($Line.Length -le $This.Buffer)
                    {
                        $Value = $Null
                        $Name  = $Line.TrimEnd(" ")
                    }
                    Else
                    {
                        $Value = $Line.Substring($This.Buffer)
                        $Name  = $Line.Replace($Value,"").TrimEnd(" ")
                    }
                    $This.Output += $This.SystemProperty($This.Output.Count,$X,$Source,$Name,$Value)
                    $X ++
                }
            }

            # Load the total number of network objects into the system.network output container
            ForEach ($Source in $This.Output | ? Source -match Network\d+ | % Source | Select-Object -Unique)
            {
                $Pairs = $This.Output | ? Source -match $Source
                $This.System.Network.Add($Pairs,[Switch]$True)
            }
        }
        Add([UInt32]$Rank,[UInt32]$Type,[String]$Line)
        {
            $This.Process += $This.ParseLine($This.Process.Count,$Rank,$Type,$Line)
        }
        [Object] ParseLine([UInt32]$Index,[UInt32]$Rank,[UInt32]$Type,[String]$Line)
        {
            Return [ParseLine]::New($Index,$Rank,$Type,$Line)
        }
        [Object] SystemProperty([UInt32]$Index,[UInt32]$Rank,[String]$Source,[String]$Name,[Object]$Value)
        {
            Return [SystemProperty]::New($Index,$Rank,$Source,$Name,$Value)
        }
    }

    Switch ($Pscmdlet.ParameterSetName)
    {
        0
        {
            [System]::New()
        }
        1
        {
            [ParseBody]::New($Path).System
        }
        2
        {
            [ParseBody]::New($InputObject,[Switch]$Flags).System
        }
    }
}

# $System = Get-FESystemDetails
# $Out    = $System.Output()
# [System.IO.File]::WriteAllLines("$Home\Desktop\Master.txt",$Out)
