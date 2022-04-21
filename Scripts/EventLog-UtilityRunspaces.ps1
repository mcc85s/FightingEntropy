# Example classes to keep the lesson/experiment structured

# Get-SystemDetails gets a capture of the system running the utility
Function Get-SystemDetails
{
    Class DGList
    {
        [String] $Name
        [Object] $Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name = $Name
            $This.Value = Switch ($Value.Count) { 0 { $Null } 1 { $Value } Default { $Value -join "`n" } }
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class Network
    {
        [String]$Name
        [UInt32]$Index
        [String]$IPAddress
        [String]$SubnetMask
        [String]$Gateway
        [String[]] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([Object]$If)
        {
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway     | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = $IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DhcpServer = $IF.DhcpServer           | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,($_.Value -join ",")) })
        }
    }

    Class DiskDrive
    {
        [Object] $Disk
        [Object] $Meta
        [Object[]] $Partition
        [Object]   $Drive
        DiskDrive([Object]$Disk)
        {
            $This.Disk      = $Disk
            $This.Meta      = Get-CimInstance -ClassName MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $This.Disk.Index
            $This.Partition = Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition -InputObject $This.Disk
            $This.Drive     = $This.Partition | % { Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk -InputObject $_ -EA 0 }
        }
    }

    Class Partition
    {
        [String] $Type
        [String] $Name
        Hidden [BigInt] $SizeBytes
        [String] $Size
        [Bool] $Boot
        [Bool] $Primary
        [UInt32] $Disk
        [UInt32] $Partition
        Partition([Object]$Partition)
        {
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.SizeBytes  = $Partition.Size
            $This.Size       = Switch ($Partition.Size)
            {
                {$_ -lt 1GB}
                {
                    "{0:n2} MB" -f ($Partition.Size/1MB)
                }
                {$_ -ge 1GB -and $_ -lt 1TB}
                {
                    "{0:n2} GB" -f ($Partition.Size/1GB)
                }
                {$_ -ge 1TB}
                {
                    "{0:n2} TB" -f ($Partition.Size/1TB)
                }
            }
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.Partition  = $Partition.Index
        }
    }

    Class Drive
    {
        [String] $Name
        [String] $DriveLetter
        [String] $Description
        [String] $Filesystem
        [String] $VolumeName
        [String] $VolumeSerial
        Hidden [UInt64] $FreespaceBytes
        [String] $Freespace
        Hidden [UInt64] $UsedBytes
        [String] $Used
        Hidden [UInt64] $SizeBytes
        [String] $Size
        [Bool]   $Compressed
        Drive([Object]$Drive)
        {
            $This.Name           = $Drive.Name
            $This.DriveLetter    = $Drive.Name.Trim(":")
            $This.Description    = $Drive.Description
            $This.VolumeName     = $Drive.VolumeName
            $This.VolumeSerial   = $Drive.VolumeSerial
            $This.FreespaceBytes = $Drive.Freespace
            $This.Freespace      = $This.GetSize($This.FreespaceBytes)
            $This.UsedBytes      = $Drive.Size - $Drive.Freespace
            $This.Used           = $This.GetSize($This.UsedBytes)
            $This.SizeBytes      = $Drive.Size
            $This.Size           = $This.GetSize($This.SizeBytes)
            $This.Compressed     = $Drive.Compressed
            $This.Filesystem     = $Drive.Filesystem
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
    }

    Class Disk
    {
        [UInt32] $Index
        [String] $Name
        [String] $DriveLetter
        [String] $Description
        [String] $Filesystem
        [String] $VolumeName
        [String] $VolumeSerial 
        [String] $Freespace
        [String] $Used
        [String] $Size
        [Bool] $Compressed
        [String] $Disk
        [String] $Model
        [String] $Serial
        [String] $PartitionStyle
        [String] $ProvisioningType
        [String] $OperationalStatus
        [String] $HealthStatus
        [String] $BusType
        [String] $UniqueId
        [String] $Location
        [Object[]] $Partition
        Hidden [Object] $Drive
        Disk([Object]$DD)
        {
            $This.Index             = $DD.Disk.Index
            $This.Drive             = $DD.Drive | % {[Drive]$_}
            $This.Name              = $This.Drive.Name
            $This.DriveLetter       = $This.Drive.DriveLetter
            $This.Description       = $This.Drive.Description
            $This.Filesystem        = $This.Drive.Filesystem
            $This.VolumeName        = $This.Drive.VolumeName
            $This.VolumeSerial      = $This.Drive.VolumeSerial
            $This.Freespace         = $This.Drive.Freespace
            $This.Used              = $This.Drive.Used
            $This.Size              = $This.Drive.Size
            $This.Compressed        = $This.Drive.Compressed
            $This.Disk              = $DD.Disk.DeviceID
            $This.Model             = $DD.Disk.Model
            $This.Serial            = $DD.Disk.SerialNumber
            $This.PartitionStyle    = $DD.Meta.PartitionStyle
            $This.ProvisioningType  = $DD.Meta.ProvisioningType
            $This.OperationalStatus = $DD.Meta.OperationalStatus
            $This.HealthStatus      = $DD.Meta.HealthStatus
            $This.BusType           = $DD.Meta.BusType
            $This.UniqueId          = $DD.Meta.UniqueId
            $This.Location          = $DD.Meta.Location
            $This.Partition         = $DD.Partition | % { [Partition]$_ }
        }
        [Object[]] ToString()
        {
            $Collect = @( )
            ForEach ($Item in $This.PSObject.Properties)
            {
                Switch -Regex ($Item.Name)
                {
                    Default
                    {
                        $Collect += [DGList]::New($Item.Name,$Item.Value)
                    }
                    "(^Partition$)"
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New($Item.Name+"(s)"," ")
                        $Collect += [DGList]::New(" "," ")
                        ForEach ($Subitem in $Item.Value)
                        {
                            $SubItem.PSObject.Properties | % { $Collect += [DGList]::New($_.Name,$_.Value) }
                            $Collect += [DGList]::New(" "," ")
                        }
                    }
                }
            }
            Return $Collect
        }
    }

    Class Processor
    {
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
        Processor([Object]$CPU)
        {
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
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    Class Bios
    {
        [String] $Name
        [String] $Manufacturer
        [String] $SerialNumber
        [String] $Version
        [String] $ReleaseDate
        [Bool]   $SmBiosPresent
        [String] $SmBiosVersion
        [UInt32] $SmBiosMajor
        [UInt32] $SmBiosMinor
        [UInt32] $SystemBiosMajor
        [UInt32] $SystemBiosMinor
        Bios()
        {
            $Bios                = Get-CimInstance Win32_Bios
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
        [Object[]] ToString()
        {
            Return $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) }
        }
    }

    Class OS
    {
        [String] $Caption
        [String] $Version
        [String] $Build
        [String] $Serial
        [UInt32] $Language
        [UInt32] $Product
        [UInt32] $Type
        OS()
        {
            $OS            = Get-WmiObject Win32_OperatingSystem
            $This.Caption  = $OS.Caption
            $This.Version  = $OS.Version
            $This.Build    = $OS.BuildNumber
            $This.Serial   = $OS.SerialNumber
            $This.Language = $OS.OSLanguage
            $This.Product  = $OS.OSProductSuite
            $This.Type     = $OS.OSType
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    Class CS
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
        CS()
        {
            $Sys               = Get-WmiObject Win32_ComputerSystem 
            $This.Manufacturer = $Sys.Manufacturer
            $This.Model        = $Sys.Model
            $This.Memory       = "{0} GB" -f ($Sys.TotalPhysicalMemory/1GB)
            $This.UUID         = (Get-WmiObject Win32_ComputerSystemProduct).UUID 
            
            $Sys               = Get-WmiObject Win32_BaseBoard
            $This.Product      = $Sys.Product
            $This.Serial       = $Sys.SerialNumber -Replace "\.",""
            
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }

            $Sys               = Get-WmiObject Win32_SystemEnclosure
            $This.AssetTag     = $Sys.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$Sys.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[[Environment]::GetEnvironmentVariable("Processor_Architecture")]
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    Class System
    {
        [Object] $Name
        [Object] $Bios
        [Object] $OS
        [Object] $CS
        [Object[]] $Processor
        [Object[]] $Disk
        [Object[]] $Network
        System()
        {
            $This.Name             = [Environment]::MachineName
            $This.Bios             = [Bios]::New()
            $This.OS               = [OS]::New() 
            $This.CS               = [CS]::New()
            $This.Processor        = Get-WmiObject -Class Win32_Processor | % { [Processor]$_ }
            $This.Disk             = Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed | % { [DiskDrive]$_ } | % { [Disk]$_ }
            $This.Network          = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ? DefaultIPGateway | % { [Network]$_ }
        }
        [Object[]] ToString()
        {
            $Collect = @( )
            ForEach ($Item in $This.PSObject.Properties)
            {
                Switch ($Item.Name)
                {
                    Name
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("------------"," ")
                        $Collect += [DGList]::New("ComputerName",$This.Name)
                        $Collect += [DGList]::New("------------"," ")
                        $Collect += [DGList]::New(" "," ")
                        $Collect += $This.Bios.ToString()
                    }
                    OS
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("----------------"," ")
                        $Collect += [DGList]::New("Operating System"," ")
                        $Collect += [DGList]::New("----------------"," ")
                        $Collect += [DGList]::New(" "," ")
                        $Collect += $This.OS.ToString()
                    }
                    CS
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("---------------"," ")
                        $Collect += [DGList]::New("Computer System"," ")
                        $Collect += [DGList]::New("---------------"," ")
                        $Collect += [DGList]::New(" "," ")
                        $Collect += $This.CS.ToString()
                    }
                    Processor
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("------------"," ")
                        $Collect += [DGList]::New("Processor(s)"," ")
                        $Collect += [DGList]::New("------------"," ")
                        $Collect += [DGList]::New(" "," ")
                        If ($This.Processor.Count -eq 1)
                        {
                            $Collect += $This.Processor[0].ToString() 
                        }
                        If ($This.Processor.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Processor.Count-1))
                            {
                                If ($X -ne 1)
                                {
                                    $Collect += [DGList]::New(" "," ")
                                }
                                $Collect += $This.Processor[$X].ToString()
                            }
                        }
                    }
                    Disk
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("-------"," ")
                        $Collect += [DGList]::New("Disk(s)"," ")
                        $Collect += [DGList]::New("-------"," ")
                        $Collect += [DGList]::New(" "," ")
                        If ($This.Disk.Count -eq 1)
                        { 
                            $Collect += $This.Disk[0].ToString() 
                        }
                        If ($This.Disk.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Disk.Count-1))
                            {
                                If ($X -ne 1)
                                {
                                    $Collect += [DGList]::New(" "," ")
                                }
                                $Collect += $This.Disk[$X].ToString()
                            }
                        }
                    }
                    Network
                    {
                        $Collect += [DGList]::New(" "," ")
                        $Collect += [DGList]::New("-------"," ")
                        $Collect += [DGList]::New("Network"," ")
                        $Collect += [DGList]::New("-------"," ")
                        $Collect += [DGList]::New(" "," ")
                        If ($This.Network.Count -eq 1)
                        {
                            $Collect += $This.Network[0].ToString() 
                        }
                        If ($This.Network.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Network.Count-1))
                            {
                                If ($X -ne 0)
                                {
                                    $Collect += [DGList]::New(" "," ")
                                }
                                $Collect += $This.Network[$X].ToString()
                            }
                        }
                    }
                }
            }
            $Buffer      = ($Collect.Name | Sort-Object Length)[-1].Length
            $Return      = @( )
            $Return     += " "
            ForEach ($X in 0..($Collect.Count-1))
            {
                $Item    = $Collect[$X]
                If ($Item.Name -match "\-{4,}")
                {
                    $Return += ("-" * 120 -join '')
                }
                Else
                {
                    $Return += ("{0}{1} {2}" -f $Item.Name, (" " * ($Buffer-$Item.Name.Length) -join ""), $Item.Value)
                }
            }
            $Return     += " "
            Return $Return
        }
    }
    [System]::New()
}

# Sample file for the experiment
Class ExperimentFile
{
    [String] $Name
    [String] $Fullname
    [Object] $Content
    ExperimentFile([String]$Base,[String]$Name)
    {
        $This.Name     = $Name
        $This.Fullname = "$Base\$Name"
        If (!(Test-Path $This.Fullname))
        {
            New-Item $This.Fullname -ItemType File
        }
        $This.Content  = @( )
    }
    AddContent([String]$Line)
    {
        $This.Content += $Line
        Add-Content -Path $This.Fullname -Value $Line
    }
}

# Experiment container
Class Experiment
{
    Hidden [Object] $Timer
    [String]         $Time
    [DateTime]      $Start
    [Object]       $System
    [String]  $DisplayName
    [UInt32]      $Threads
    [String]         $Guid
    [String]         $Path
    [Object]        $Files
    [Object]       $Object
    [Object]         $Logs
    [Object]       $Output
    Experiment()
    {
        # Start timer, count threads / max runspace pool size
        $This.Timer       = [System.Diagnostics.Stopwatch]::StartNew()

        # Set initial date/time
        $This.Start       = [DateTime]::Now
        $This.System      = Get-SystemDetails
        $This.DisplayName = "{0}-{1}" -f $This.Start.ToString("yyyy-MMdd-HHMMss"), $This.System.Name

        # Check thread count
        $This.Threads     = $This.System.Processor.Threads | Measure-Object -Sum | % Sum
        If ($This.Threads -lt 2)
        {
            Throw "CPU only has (1) thread"
        }

        # Use a GUID to create a new folder for the threads
        $This.Guid        = [GUID]::newGuid().GUID.ToUpper()
        $This.Path        = "{0}\{1}" -f [Environment]::GetEnvironmentVariable("temp"), $This.Guid

        # Test path and create (it shouldn't exist)
        If (!(Test-Path $This.Path))
        {
            New-Item $This.Path -ItemType Directory -Verbose

            # Create a subfolder for each stage
            ForEach ($Item in "Master","Logs","Events")
            {
                New-Item "$($This.Path)\$Item" -ItemType Directory -Verbose
            }
        }

        # Create an individual file for each thread, to evenly distribute the workload among the max threads 
        $This.Files      = 0..($This.Threads-1) | % { [ExperimentFile]::New($This.Path,"$_.txt") }
        $This.Object     = @( )
        $This.Logs       = @( )
        $This.Output     = @( )
    }
    Load([Object[]]$Object)
    {
        # Loads the provider names, but may be reusable
        ForEach ($X in 0..($Object.Count-1))
        {
            $File             = $This.Files[$X%$This.Threads]
            $Name             = $Object[$X]
            $Value            = "$X,$Name"
            $File.AddContent($Value)
            $This.Object     += $Name
        }
    }
    Delete()
    {
        $This.Path        | Remove-Item -Recurse -Verbose
        $This.Start       = [DateTime]::FromOADate(1)
        $This.System      = $Null
        $This.DisplayName = $Null
        $This.Timer       = $Null
        $This.Threads     = $Null
        $This.Guid        = $Null
        $This.Path        = $Null
        $This.Files       = $Null
        $This.Object      = $Null
        $This.Logs        = $Null
        $This.Output      = $Null
    }
    Master()
    {
        $Value  = @( )
        $Value += "[Start]: $($This.Start)"
        $Value += "[DisplayName]: $($This.DisplayName)"
        $Value += "[Guid]: $($This.Guid)"
        $Depth  = ([String]$This.Object.Count).Length
        ForEach ($X in 0..($This.Object.Count-1))
        {
            $Value += ("[Provider {0:d$Depth}]: {1}" -f $X, $This.Object[$X])
        }
        $SystemInfo = $This.System.ToString()
        ForEach ($X in 0..($SystemInfo.Count-1))
        {
            $Value += $SystemInfo[$X]
        }
        Set-Content "$($This.Path)\Master\Master.txt" -Value $Value -Force
    }
}

# Thread object for runspace invocation 
Class ThreadObject
{
    [UInt32] $Id 
    Hidden [Object] $Timer
    Hidden [Object] $PowerShell
    Hidden [Object] $Handle
    [String] $Time
    [UInt32] $Complete
    Hidden [Object] $Data
    ThreadObject([UInt32]$Id,[Object]$PowerShell)
    {
        $This.Id             = $Id
        $This.Timer          = [System.Diagnostics.Stopwatch]::StartNew()
        $This.PowerShell     = $PowerShell
        $This.Handle         = $PowerShell.BeginInvoke()
        $This.Time           = $This.Timer.Elapsed.ToString()
        $This.Complete       = 0
        $This.Data           = $Null
    }
    IsComplete()
    {
        If ($This.Handle.IsCompleted)
        {
            $This.Complete   = 1
            $This.Data       = $This.PowerShell.EndInvoke($This.Handle)
            $This.Timer.Stop()
            $This.PowerShell.Dispose()
        }
        $This.Time           = $This.Timer.Elapsed.ToString() 
    }
}

# Thread collection object to track and chart progress of all thread objects
Class ThreadCollection
{
    Hidden [Object] $Timer
    [String] $Time
    [UInt32] $Complete
    [UInt32] $Total
    [Object] $Threads
    ThreadCollection()
    {
        $This.Timer    = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Time     = $This.Timer.Elapsed.ToString()
        $This.Threads  = @( )
    }
    [Bool] Query()
    {
        Return @( $False -in $This.Threads.Handle.IsCompleted )
    }
    AddThread([UInt32]$Index,[Object]$PowerShell)
    {
        $This.Threads += [ThreadObject]::New($_,$PowerShell)
        $This.Total    = $This.Threads.Count
    }
    IsComplete()
    {
        $This.Threads.IsComplete()
        $This.Complete = ($This.Threads | ? Complete -eq $True ).Count

        If ($This.Complete -eq $This.Total)
        {
            $This.Timer.Stop()
        }
        $This.Time     = $This.Timer.Elapsed.ToString()
        $This.ToString()
    }
    [String] ToString()
    {
        Return ( "Elapsed: [{0}], Completed ({1}/{2})" -f $This.Timer.Elapsed, $This.Complete, $This.Total )
    }
}

# All of these versions do the same thing. I wrote it several ways to show how they all achieve the same end result.
# Version 1
# $Objects    = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
# $Ctrl       = [Experiment]::New()
# $Ctrl.Load($Objects)                                                                        # Reset the lab -> # $Ctrl.Remove() 

# Version 2
# $Ctrl       = [Experiment]::New()
# $Ctrl.Load((Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object))     # Reset the lab -> # $Ctrl.Remove()

# Version 3
# $Ctrl       = New-Object Experiment
# $Ctrl | % Load (Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object)  # Reset the lab -> # $Ctrl.Remove()

# Version 4
$Ctrl  = New-Object Experiment
$Names = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
$Ctrl.Load($Names)
$Ctrl.Master()

# -------------------------------------
# Output of the custom experiment class
# -------------------------------------
# PS C:\Users\admin> $Ctrl
# 
# Time         : 00:08:06.8751525
# Start        : 4/20/2022 06:48:05 AM
# System       : Get-SystemDetails
# DisplayName  : 2022_0420-064805-coolstorybro-x64
# Threads      : 8
# Guid         : E43750A8-FB88-434F-8418-99D7E6171DB6
# Path         : C:\Users\admin\AppData\Local\Temp\E43750A8-FB88-434F-8418-99D7E6171DB6
# Files        : {0.txt, 1.txt, 2.txt, 3.txt...}
# Object       : {Application, ForwardedEvents, HardwareEvents, Internet Explorer...}
# ----------------------------------------------------------------------------------------------

# Declare functions to memory, for each runspace to have access to
Function Get-EventLogConfigExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][UInt32]$Rank,
        [Parameter(Mandatory,ParameterSetName=0)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Config)

    Class EventLogConfigExtension
    {
        [UInt32] $Rank
        [String] $LogName
        [Object] $LogType
        [Object] $LogIsolation
        [Boolean] $IsEnabled
        [Boolean] $IsClassicLog
        Hidden [String] $SecurityDescriptor
        [String] $LogFilePath
        Hidden [Int64] $MaximumSizeInBytes
        [Object] $Maximum
        [Object] $Current
        [Object] $LogMode
        Hidden [String] $OwningProviderName
        [Object] $ProviderNames
        Hidden [Object] $ProviderLevel
        Hidden [Object] $ProviderKeywords
        Hidden [Object] $ProviderBufferSize
        Hidden [Object] $ProviderMinimumNumberOfBuffers
        Hidden [Object] $ProviderMaximumNumberOfBuffers
        Hidden [Object] $ProviderLatency
        Hidden [Object] $ProviderControlGuid
        Hidden [Object[]] $EventLogRecord
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Name)
        {
            $This.Rank                           = $Rank
            $Event                               = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($Name)
            $This.LogName                        = $Event.LogName 
            $This.LogType                        = $Event.LogType 
            $This.LogIsolation                   = $Event.LogIsolation 
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = "{0:n2} MB" -f ($Event.MaximumSizeInBytes/1MB) 
            $This.Current                        = If (!(Test-Path $This.LogFilePath)) { "0.00 MB" } Else { "{0:n2} MB" -f (Get-Item $This.LogFilePath | % { $_.Length/1MB }) }
            $This.LogMode                        = $Event.LogMode
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        EventLogConfigExtension([Object]$Event)
        {
            $This.Rank                           = $Event.Rank
            $This.Logname                        = $Event.LogName
            $This.LogType                        = $This.GetLogType($Event.LogType)
            $This.LogIsolation                   = $This.GetLogIsolation($Event.LogIsolation)
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath 
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = $Event.Maximum
            $This.Current                        = $Event.Current
            $This.LogMode                        = $This.GetLogMode($Event.LogMode)
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        GetEventLogRecord()
        {
            $This.Output = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
            $This.Total  = $This.Output.Count
            $Depth       = ([String]$This.Total.Count).Length
            If ($This.Total -gt 0)
            {
                $C = 0
                ForEach ($Record in $This.Output)
                {
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    Index -Value $Null
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Rank -Value $C 
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    LogId -Value $This.Rank
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name DateTime -Value $Record.TimeCreated
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Date -Value $Record.TimeCreated.ToString("yyyy-MMdd-HHMMss")
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Name -Value ("$($Record.Date)-$($This.Rank)-{0:d$Depth}" -f $C)
                    $C ++
                }
            }
        }
        [Object] GetLogType([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogType]::Administrative }
                1 { [System.Diagnostics.Eventing.Reader.EventLogType]::Operational }
                2 { [System.Diagnostics.Eventing.Reader.EventLogType]::Analytical }
                3 { [System.Diagnostics.Eventing.Reader.EventLogType]::Debug }  
            }
            Return $Return
        }
        [Object] GetLogIsolation([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Application }
                1 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::System }
                2 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Custom }
            }
            Return $Return
        }
        [Object] GetLogMode([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular   }
                1 { [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup }
                2 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain     }
            }
            Return $Return
        }
        [Object] Config()
        {
            Return $This | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,MaximumSizeInBytes,Maximum,Current,LogMode,
            OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,
            ProviderControlGuid
        }
    }
    
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogConfigExtension]::New($Rank,$Name) }
        1 { [EventLogConfigExtension]::New($Config)     }
    }
}

# This function is used to export the event logs from the system
Function Get-EventLogRecordExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][Object]$Record,
        [Parameter(Mandatory,ParameterSetName=1)][UInt32]$Index,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Entry)

    Class EventLogRecordExtension
    {
        [UInt32]   $Index
        Hidden [String] $Name
        Hidden [Object] $DateTime
        [String]   $Date
        [String]   $Log
        [UInt32]   $Rank
        [String]   $Provider
        [UInt32]   $Id
        [String]   $Type
        [String]   $Message
        Hidden [String[]] $Content
        Hidden [Object] $Version
        Hidden [Object] $Qualifiers
        Hidden [Object] $Level
        Hidden [Object] $Task
        Hidden [Object] $Opcode
        Hidden [Object] $Keywords
        Hidden [Object] $RecordId
        Hidden [Object] $ProviderId
        Hidden [Object] $LogName
        Hidden [Object] $ProcessId
        Hidden [Object] $ThreadId
        Hidden [Object] $MachineName
        Hidden [Object] $UserID
        Hidden [Object] $ActivityID
        Hidden [Object] $RelatedActivityID
        Hidden [Object] $ContainerLog
        Hidden [Object] $MatchedQueryIds
        Hidden [Object] $Bookmark
        Hidden [Object] $OpcodeDisplayName
        Hidden [Object] $TaskDisplayName
        Hidden [Object] $KeywordsDisplayNames
        Hidden [Object] $Properties
        EventLogRecordExtension([Object]$Record)
        {
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.ProviderName
            $This.DateTime    = $Record.TimeCreated
            $This.Date        = $Record.Date
            $This.Log         = $Record.LogId
            $This.Id          = $Record.Id
            $This.Type        = $Record.LevelDisplayName
            $This.InsertEvent($Record)
        }
        EventLogRecordExtension([UInt32]$Index,[Object]$Entry)
        {
            $Stream           = $Entry.Open()
            $Reader           = [System.IO.StreamReader]::New($Stream)
            $RecordEntry      = $Reader.ReadToEnd() 
            $Record           = $RecordEntry | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.DateTime    = [DateTime]$Record.DateTime
            $This.Date        = $Record.Date
            $This.Log         = $Record.Log
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.Provider
            $This.Id          = $Record.Id
            $This.Type        = $Record.Type
            $This.InsertEvent($Record)
        }
        InsertEvent([Object]$Record)
        {
            $FullMessage   = $Record.Message -Split "`n"
            Switch ($FullMessage.Count)
            {
                {$_ -gt 1}
                {
                    $This.Message  = $FullMessage[0] -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 1}
                {
                    $This.Message  = $FullMessage -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 0}
                {
                    $This.Message  = "-"
                    $This.Content  = "-"
                }
            }
            $This.Version              = $Record.Version
            $This.Qualifiers           = $Record.Qualifiers
            $This.Level                = $Record.Level
            $This.Task                 = $Record.Task
            $This.Opcode               = $Record.Opcode
            $This.Keywords             = $Record.Keywords
            $This.RecordId             = $Record.RecordId
            $This.ProviderId           = $Record.ProviderId
            $This.LogName              = $Record.LogName
            $This.ProcessId            = $Record.ProcessId
            $This.ThreadId             = $Record.ThreadId
            $This.MachineName          = $Record.MachineName
            $This.UserID               = $Record.UserId
            $This.ActivityID           = $Record.ActivityId
            $This.RelatedActivityID    = $Record.RelatedActivityID
            $This.ContainerLog         = $Record.ContainerLog
            $This.MatchedQueryIds      = @($Record.MatchedQueryIds)
            $This.Bookmark             = $Record.Bookmark
            $This.OpcodeDisplayName    = $Record.OpcodeDisplayName
            $This.TaskDisplayName      = $Record.TaskDisplayName
            $This.KeywordsDisplayNames = @($Record.KeywordsDisplayNames)
            $This.Properties           = @($Record.Properties.Value)
        }
        [Object] Export()
        {
            Return @( $This | ConvertTo-Json )
        }
        [Object] Config()
        {
            Return $This | Select-Object Index,Name,DateTime,Date,Log,Rank,Provider,Id,Type,Message,Content,
            Version,Qualifiers,Level,Task,Opcode,Keywords,RecordId,ProviderId,LogName,ProcessId,ThreadId,MachineName,
            UserID,ActivityID,RelatedActivityID,ContainerLog,MatchedQueryIds,Bookmark,OpcodeDisplayName,TaskDisplayName,
            KeywordsDisplayNames,Properties
        }
        [Void] SetContent([String]$Path)
        {
            [System.IO.File]::WriteAllLines($Path,$This.Export())
        }
        [Object] ToString()
        {
            Return @( $This.Export() | ConvertFrom-Json )
        }
    }
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogRecordExtension]::New($Record) }
        1 { [EventLogRecordExtension]::New(0,$Entry) }
    }
}

# Create initial session state object, function above is immediately available to any thread in the runspace pool
$Session         = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
ForEach ($Item in "Get-EventLogConfigExtension","Get-EventLogRecordExtension")
{
    $Content     = Get-Content "Function:\$Item" -ErrorAction Stop
    $Object      = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Item,$Content)
    $Session.Commands.Add($Object) 
}

# Open the runspacepool
$RunspacePool    = [RunspaceFactory]::CreateRunspacePool(1,$Ctrl.Threads,$Session,$Host)
$RunspacePool.Open()

# Declare the scriptblock each runspace will run independently
$ScriptBlock     = {
    Param ($Fullname)
    $List        = Get-Content $Fullname
    $Return      = @( )
    ForEach ($X in 0..($List.Count-1))
    {
        $Rank    = $List[$X].Split(",")[0]
        $Name    = $List[$X].Split(",")[1]
        $Item    = Get-EventLogConfigExtension -Rank $Rank -Name $Name
        $Item.GetEventLogRecord()
        $Return += $Item
    }
    Return $Return 
}

# Declare the thread collection object
$List1            = New-Object ThreadCollection

# Initialize the threads, add the scriptblock, insert an argument for filepath
0..($Ctrl.Threads-1) | % {

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($scriptblock).AddArgument($Ctrl.Files[$_].Fullname) | Out-Null
    $PowerShell.RunspacePool = $RunspacePool

    $List1.AddThread($_,$PowerShell)
}

# Code to run while waiting for threads to finish
While ($List1.Query())
{
    $List1.Threads | Format-Table
    Write-Host $List1
    Start-Sleep 5
    Clear-Host
    $List1.IsComplete()
}
Write-Host $List1
$List1.IsComplete()

# (Sort -> Write) log config file
Write-Host "Sorting [~] Logs: (Index/Rank), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Ctrl.Logs      = $List1.Threads.Data | Sort-Object Rank
Set-Content "$($Ctrl.Path)\Logs\Logs.txt" -Value ($Ctrl.Logs.Config() | ConvertTo-Json)

# Now we have all of the log entries on the system 1) ranked, and also 2) sorted by TimeCreated
Write-Host "Sorting (Events by TimeCreated) [~] (Logs/Output), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Ctrl.Output   = $Ctrl.Logs.Output | Sort-Object TimeCreated
$RunspacePool.Dispose()

# Almost time to index the files...
Write-Host "Indexing [~] (Output), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Count          = $Ctrl.Output.Count
$Depth          = ([String]$Count).Length

# Set up hashtable for threads and $T variable for threads (an error kept occurring) 
$Load           = @{ }
$T              = [Environment]::GetEnvironmentVariable("Number_of_processors")

# Autocalc the # of hashtables respective to cores available
ForEach ($X in 0..($T-1))
{
    $Load.Add($X,[Hashtable]@{ })
}

# Now perform indexing as well as dividing the workload to separate hashtables
ForEach ($X in 0..($Ctrl.Output.Count-1))
{
    $Item       = $Ctrl.Output[$X]
    $Item.Index = $X
    $Item.Name  = "{0:d$Depth}-{1}" -f $X, $Item.Name

    # The index ($X % $T) switches the corresponding hashtable per iteration
    $Load[$X%$T].Add($Load[$X%$T].Count,$Ctrl.Output[$X])
}

# Open the runspacepool
$RunspacePool    = [RunspaceFactory]::CreateRunspacePool(1,$Ctrl.Threads,$Session,$Host)
$RunspacePool.Open()

# Scriptblock instructs each thread to get the event log record extension, then sets the content
$ScriptBlock     = {

    Param ($Target,$Load,$Threads,$Step)
    ForEach ($X in 0..($Load.Count-1))
    {
        $Item = Get-EventLogRecordExtension -Record $Load[$X]
        $Item.SetContent("$Target\$($Item.Name).log")
    }
}

# Declare new thread collection object
$List2            = New-Object ThreadCollection

# Initialize the threads, add the scriptblock, insert an argument for filepath
0..($Ctrl.Threads-1) | % {

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($scriptblock).AddArgument("$($Ctrl.Path)\Events").AddArgument($Load[$_]).AddArgument($Ctrl.Threads).AddArgument($_) | Out-Null
    $PowerShell.RunspacePool = $RunspacePool

    $List2.AddThread($_,$PowerShell)
}

# Code to run while waiting for threads to finish
While ($List2.Query())
{
    $List2.Threads | Format-Table
    Write-Host $List2
    Start-Sleep 5
    Clear-Host
    $List2.IsComplete()
}
Write-Host $List2
$List2.IsComplete()

# Dispose the runspace
$RunspacePool.Dispose()

# Get ready to archive the files
Add-Type -Assembly System.IO.Compression.Filesystem

$Phase       = [System.Diagnostics.Stopwatch]::StartNew()
$Destination = "$($Ctrl.Path)\$($Ctrl.DisplayName).zip"
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Create").Dispose()
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Update")

# Inject master file
$MasterPath  = "$($Ctrl.Path)\Master\Master.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$MasterPath,"Master.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Inject logs file
$LogPath     = "$($Ctrl.Path)\Logs\Logs.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$LogPath,"Logs.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Prepare event files
$EventPath   = "$($Ctrl.Path)\Events"
$EventFiles  = Get-ChildItem $EventPath

# Create progress loop
$Complete   = @( )
$Count      = $EventFiles.Count
ForEach ($X in 0..($EventFiles.Count-1))
{
    $File    = $EventFiles[$X]
    $Percent = [Math]::Round($X*100/$Count)
    If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
    {
        $Complete += $Percent
        If ($Percent -ne 0)
        {
            $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
        }
        
        Write-Host "Exporting ($Percent.00%) [~] Elapsed: [$($Phase.Elapsed)], Remain: [$Remain]"
    }
    # Inject event files
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$File.Fullname,$File.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
}

# Archive creation just about complete
Write-Host "Saving (100.00%) [~] Elapsed: $($Phase.Elapsed), (Please wait, the program is writing the file to disk)"
$Zip.Dispose()

# Get the zip file information
$Zip = Get-Item $Destination
Switch (!!$Zip)
{
    $True
    {
        Write-Host ("Saved (100.00%) [+] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], Size: [$("{0:n3}MB" -f ($Zip.Length/1MB))]")
    }
    $False
    {
        Write-Host ("Failed (100.00%) [!] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], the file does not exist.")
    }
}

# At this point, deleting the makeshift directories/files might be a good idea outside of development


# This is specifically for restoring an archive of another machine, or the current machine.
Class RestoreArchive
{
    [Object] $Time
    [Object] $Start
    [Object] $System
    [Object] $DisplayName
    [UInt32] $Threads
    [String] $Guid
    [String] $Path
    [Object] $Files
    [Object] $Object
    [Object] $Logs
    [Object] $Output
    Hidden [Object] $Zip
    RestoreArchive([String]$ZipPath)
    {
        # Restore the zip file
        If (!(Test-Path $ZipPath) -or $ZipPath.Split(".")[-1] -notmatch "zip")
        {
            Throw "Invalid Path"
        }

        $This.Time         = [System.Diagnostics.Stopwatch]::StartNew()

        # Get zip content, pull master file
        $This.Zip          = [System.IO.Compression.Zipfile]::Open($ZipPath,"Read")
        $This.Path         = $ZipPath | Split-Path -Parent

        # Extract Master file
        $MasterEntry       = $This.Zip.GetEntry("Master.txt")
        $MasterPath        = "$($This.Path)\Master.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($MasterEntry,$MasterPath,$True)
        $MasterFile        = Get-Content $MasterPath

        # Extract Logs file
        $LogEntry          = $This.Zip.GetEntry("Logs.txt")
        $LogPath           = "$($This.Path)\Logs.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($LogEntry,$LogPath,$True)
        $LogFile           = Get-Content $LogPath | ConvertFrom-Json

        # Parse Master.txt
        $This.Start        = $MasterFile[0].Substring(9)
        $This.DisplayName  = $MasterFile[1].Substring(15)
        $Lines             = @( )
        ForEach ($X in 0..($MasterFile.Count-1))
        {
            $Line = [Regex]::Matches($MasterFile[$X],"\[Provider \d+\].+").Value
            If (!!$Line)
            { 
                $Lines    += $Line.Substring(16)
            }
        }
        $This.Object       = $Lines
        $This.System       = $MasterFile[($Lines.Count + 2)..($MasterFile.Count-1)]
        $This.Threads      = ($This.System | ? { $_ -match "Threads" }).Substring(18)

        # Parse Logs.txt
        $This.Logs         = @( )
        $Stash             = @{ }
        ForEach ($X in 0..($LogFile.Count-1))
        {
            $Item          = $LogFile[$X]
            $This.Logs    += Get-EventLogConfigExtension -Config $Item
            $Stash.Add($Item.LogName,@{ })
        }

        $Hash              = @{ }
        $Remain            = $Null

        # Collect Files
        $FileEntry            = $This.Zip.Entries | ? Name -notmatch "(Master|Logs).txt"

        # Create progress loop
        $Complete             = @( )
        $Phase                = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Importing (0.00%) [~] Files: ($($FileEntry.Count)) found."
        ForEach ($X in 0..($FileEntry.Count-1))
        {
            $Item             = Get-EventLogRecordExtension -Index $X -Entry $FileEntry[$X]
            $Hash.Add($X,$Item)

            $Stash[$Item.LogName].Add($Stash[$Item.LogName].Count,$X)
            
            $Percent          = [Math]::Round($X*100/$FileEntry.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain= ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Importing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        $Phase.Stop()
        Write-Host "Imported (100.00%) [+] Files: ($($FileEntry.Count)) found."
        $This.Output      = $Hash[0..($Hash.Count-1)]

        # Sort the logs
        $Complete          = @( )
        $Phase.Reset()
        Write-Host "Sorting (0.00%) [~] Logs: ($($This.Logs.Count)) found."
        ForEach ($X in 0..($This.Logs.Count-1))
        {
            $Name = $This.Logs[$X].LogName
            Switch ($Stash[$Name].Count)
            {
                0 
                {  
                    $This.Logs[$X].Output = @( )
                }
                1 
                {  
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0]])
                }
                Default
                { 
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0..($Stash[$Name].Count-1)]])
                }
            }
            $This.Logs[$X].Total          = $This.Logs[$X].Output.Count

            $Percent                      = [Math]::Round($X*100/$This.Logs.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        Write-Host "Sorted (100.00%) [+] Logs: ($($This.Logs.Count)) found."
        $This.Time.Stop()
    }
}
