# New version of Get-FESystem that implements some new approaches for module + logging integration

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Generic Classes    ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class ByteSize
{
    [String]   $Name
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    ByteSize([String]$Name,[UInt64]$Bytes)
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

Class GenericProperty
{
    [UInt32]  $Index
    [String]   $Name
    [Object]  $Value
    GenericProperty([UInt32]$Index,[Object]$Property)
    {
        $This.Index  = $Index
        $This.Name   = $Property.Name
        $This.Value  = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FESystem.Property>"
    }
}

Class GenericList
{
    [String] $Name
    [UInt32] $Count
    [Object] $Output
    GenericList([String]$Name)
    {
        $This.Name    = $Name
        $This.Clear()
    }
    Clear()
    {
        $This.Count   = 0
        $This.Output  = @( )
    }
    Add([Object]$Item)
    {
        $This.Output += $Item
        $This.Count   = $This.Output.Count
    }
    [String] ToString()
    {
        Return "({0}) <FESystem.{1}[List]>" -f $This.Count, $This.Name
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Bios Information   ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class BiosInformation
{
    Hidden [Object]     $Bios
    [String]            $Name
    [String]    $Manufacturer
    [String]    $SerialNumber
    [String]         $Version
    [String]     $ReleaseDate
    [Bool]     $SmBiosPresent
    [String]   $SmBiosVersion
    [String]     $SmBiosMajor
    [String]     $SmBiosMinor
    [String] $SystemBiosMajor
    [String] $SystemBiosMinor
    BiosInformation()
    {
        $This.Bios            = $This.GetBios()

        $This.Name            = $This.Bios.Name
        $This.Manufacturer    = $This.Bios.Manufacturer
        $This.SerialNumber    = $This.Bios.SerialNumber
        $This.Version         = $This.Bios.Version
        $This.ReleaseDate     = $This.Bios.ReleaseDate
        $This.SmBiosPresent   = $This.Bios.SmBiosPresent
        $This.SmBiosVersion   = $This.Bios.SmBiosBiosVersion
        $This.SmBiosMajor     = $This.Bios.SmBiosMajorVersion
        $This.SmBiosMinor     = $This.Bios.SmBiosMinorVersion
        $This.SystemBiosMajor = $This.Bios.SystemBiosMajorVersion
        $This.SystemBIosMinor = $This.Bios.SystemBiosMinorVersion
    }
    [Object] GetBios()
    {
        Return Get-CimInstance Win32_Bios
    }
    [String] ToString()
    {
        Return "<FESystem.BiosInformation>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Operating System   ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class OperatingSystem
{
    Hidden [Object]       $Os
    [String]         $Caption
    [String]         $Version
    [String]           $Build
    [String]          $Serial
    [UInt32]        $Language
    [UInt32]         $Product
    [UInt32]            $Type
    OperatingSystem()
    {
        $This.OS            = $This.GetOperatingSystem()

        $This.Caption       = $This.OS.Caption
        $This.Version       = $This.OS.Version
        $This.Build         = $This.OS.BuildNumber
        $This.Serial        = $This.OS.SerialNumber
        $This.Language      = $This.OS.OSLanguage
        $This.Product       = $This.OS.OSProductSuite
        $This.Type          = $This.OS.OSType

    }
    [Object] GetOperatingSystem()
    {
        Return Get-CimInstance Win32_OperatingSystem
    }
    [String] ToString()
    {
        Return "<FESystem.OperatingSystem>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Computer System    ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class ComputerSystem
{
    Hidden [Object] $Computer
    [String]    $Manufacturer
    [String]           $Model
    [String]         $Product
    [String]          $Serial
    [Object]          $Memory
    [String]    $Architecture
    [String]            $UUID
    [String]         $Chassis
    [String]        $BiosUefi
    [Object]        $AssetTag
    ComputerSystem()
    {
        $This.Computer     = @{ 
         
            System         = $This.Get("ComputerSystem")
            Product        = $This.Get("ComputerSystemProduct")
            Board          = $This.Get("BaseBoard")
            Form           = $This.Get("SystemEnclosure")
        }

        $This.Manufacturer = $This.Computer.System.Manufacturer
        $This.Model        = $This.Computer.System.Model
        $This.Memory       = $This.ByteSize("Memory",$This.Computer.System.TotalPhysicalMemory)
        $This.UUID         = $This.Computer.Product.UUID 
        $This.Product      = $This.Computer.Product.Version
        $This.Serial       = $This.Computer.Board.SerialNumber -Replace "\.",""
        $This.BiosUefi     = $This.Get("SecureBootUEFI")

        $This.AssetTag     = $This.Computer.Form.SMBIOSAssetTag.Trim()
        $This.Chassis      = Switch ([UInt32]$This.Computer.Form.ChassisTypes[0])
        {
            {$_ -in 8..12+14,18,21} {"Laptop"}
            {$_ -in 3..7+15,16}     {"Desktop"}
            {$_ -in 23}             {"Server"}
            {$_ -in 34..36}         {"Small Form Factor"}
            {$_ -in 30..32+13}      {"Tablet"}
        }

        $This.Architecture = @{x86="x86";AMD64="x64"}[$This.Get("Architecture")]
    }
    [Object] ByteSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [Object] Get([String]$Name)
    {
        $Item = Switch ($Name)
        {
            ComputerSystem
            {
                Get-CimInstance Win32_ComputerSystem 
            }
            ComputerSystemProduct
            {
                Get-CimInstance Win32_ComputerSystemProduct
            }
            Baseboard
            {
                Get-CimInstance Win32_Baseboard
            }
            SystemEnclosure
            {
                 Get-CimInstance Win32_SystemEnclosure
            }
            SecureBootUEFI
            {
                Try
                {
                    Get-SecureBootUEFI -Name SetupMode -EA 0
                    "UEFI"
                }
                Catch
                {
                    "BIOS"
                }
            }
            Architecture
            {
                [Environment]::GetEnvironmentVariable("Processor_Architecture")
            }
        }

        Return $Item
    }
    [String] ToString()
    {
        Return "<FESystem.ComputerSystem>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Current Version    ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class CurrentVersion
{
    Hidden [Object] $Current
    [String]             $Id
    [String]          $Label
    [Object]       $Property
    CurrentVersion()
    {
        $This.Refresh()
    }
    [Object] GenericProperty([UInt32]$Index,[Object]$Property)
    {
        Return [GenericProperty]::New($Index,$Property)
    }
    [Object] GetCurrentVersion()
    {
        Return Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    }
    Clear()
    {
        $This.Property = @( )
    }
    Refresh()
    {
        $This.Current  = $This.GetCurrentVersion()
        $This.Clear()

        ForEach ($Property in $This.Current.PSObject.Properties | ? Name -notmatch ^PS)
        {
            $This.Add($Property)
        }

        $This.Id    = $This.Get("DisplayVersion") | % Value
        $This.Label = "v{0}" -f $This.Id
    }
    Add([Object]$Property)
    {
        $This.Property += $this.GenericProperty($This.Property.Count,$Property)
    }
    [Object] Get([String]$Name)
    {
        Return $This.Property | ? Name -eq $Name
    }
    [String] ToString()
    {
        Return "<FESystem.CurrentVersion>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Win 10 Edition Classes ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Enum EditionType
{
    v1507
    v1511
    v1607
    v1703
    v1709
    v1803
    v1903
    v1909
    v2004
    v20H2
    v21H1
    v21H2
    v22H2
}

Class EditionItem
{
    [UInt32]       $Index
    [String]        $Name
    [UInt32]       $Build
    [String]    $Codename
    [String] $Description
    EditionItem([String]$Name)
    {
        $This.Index = [UInt32][EditionType]::$Name
        $This.Name  = [EditionType]::$Name
    }
    Inject([String]$Line)
    {
        $Split            = $Line -Split ","
        $This.Build       = $Split[0]
        $This.Codename    = $Split[1]
        $This.Description = $Split[2]
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class EditionController
{
    [Object] $Current
    [Object] $Output
    EditionController([Object]$Current)
    {
        $This.Refresh()
        $This.Current = $This.Output | ? Name -eq $Current.Label
    }
    [Object] EditionItem([String]$Name)
    {
        Return [EditionItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()
        
        ForEach ($Name in [System.Enum]::GetNames([EditionType]))
        {
            $Item = $This.EditionItem($Name)
            $Line = Switch ($Item.Name)
            {
                v1507 { "10240,Threshold 1,Release To Manufacturing"  }
                v1511 { "10586,Threshold 2,November Update"           }
                v1607 { "14393,Redstone 1,Anniversary Update"         }
                v1703 { "15063,Redstone 2,Creators Update"            }
                v1709 { "16299,Redstone 3,Fall Creators Update"       }
                v1803 { "17134,Redstone 4,April 2018 Update"          }
                v1809 { "17763,Redstone 5,October 2018 Update"        }
                v1903 { "18362,19H1,May 2019 Update"                  }
                v1909 { "18363,19H2,November 2019 Update"             }
                v2004 { "19041,20H1,May 2020 Update"                  }
                v20H2 { "19042,20H2,October 2020 Update"              }
                v21H1 { "19043,21H1,May 2021 Update"                  }
                v21H2 { "19044,21H2,November 2021 Update"             }
                v22H2 { "19045,22H2,2022 Update"                      }
            }

            $Item.Inject($Line)
            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FESystem.Edition[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Snapshot Struct    ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class Snapshot
{
    [String]               $Start
    [String]        $ComputerName
    [String]                $Name
    [String]         $DisplayName
    Hidden [UInt32] $PartOfDomain
    [String]                 $DNS
    [String]             $NetBIOS
    [String]            $Hostname
    [String]            $Username
    [Object]           $Principal
    [UInt32]             $IsAdmin
    [String]             $Caption
    [Version]            $Version
    [String]           $ReleaseID
    [UInt32]               $Build
    [String]         $Description
    [String]                 $SKU
    [String]             $Chassis
    [String]                $Guid
    [UInt32]            $Complete
    [String]             $Elapsed
    [String] ToString()
    {
        Return "<FESystem.Snapshot>"
    }
    [UInt32] CheckAdmin()
    {
        $Collect = ForEach ($Item in "Administrator","Administrators")
        {
            $This.Principal.IsInRole($Item)
        }

        Return $True -in $Collect
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ HotFix Classes ]______________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class HotFixItem
{
    Hidden [UInt32]  $Index
    Hidden [Object] $HotFix
    Hidden [String] $Source
    [String]      $HotFixID
    [String]   $Description
    [String]   $InstalledBy
    [String]   $InstalledOn
    HotFixItem([UInt32]$Index,[Object]$HotFix)
    {
        $This.Index       = $Index
        $This.HotFix      = $HotFix
        $This.Source      = $HotFix.PSComputerName
        $This.Description = $HotFix.Description
        $This.HotFixID    = $HotFix.HotFixID
        $This.InstalledBy = $HotFix.InstalledBy
        $This.InstalledOn = ([DateTime]$HotFix.InstalledOn).ToString("MM/dd/yyyy")
    }
    [String] ToString()
    {
        Return "<FESystem.HotFix[Item]>"
    }
}

Class HotFixController : GenericList
{
    [Object] $Profile
    HotFixController([String]$Name) : Base($Name)
    {

    }
    [Object[]] GetObject()
    {
        Return Get-HotFix
    }
    [Object] HotFixItem([UInt32]$Index,[Object]$HotFix)
    {
        Return [HotFixItem]::New($Index,$Hotfix)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($HotFix in $This.GetObject())
        {
            $This.Add($HotFix)
        }
    }
    Add([Object]$Hotfix)
    {
        $This.Output += $This.HotFixItem($This.Output.Count,$HotFix)
    }
    [String] ToString()
    {
        Return "<FESystem.HotFix[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Windows Optional Features Classes  ]__________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Enum WindowsOptionalStateType
{
    Disabled
    DisabledWithPayloadRemoved
    Enabled
}

Class WindowsOptionalStateSlot
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    WindowsOptionalStateSlot([String]$Name)
    {
        $This.Index = [UInt32][WindowsOptionalStateType]::$Name
        $This.Name  = [WindowsOptionalStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class WindowsOptionalStateList
{
    [Object] $Output
    WindowsOptionalStateList()
    {
        $This.Output = @( )
        [System.Enum]::GetNames([WindowsOptionalStateType]) | % { $This.Add($_) }
    }
    Add([String]$Name)
    {
        $Item             = [WindowsOptionalStateSlot]::New($Name)
        $Item.Description = Switch ($Name)
        {
            Disabled                   { "Feature is disabled"                     }
            DisabledWithPayloadRemoved { "Feature is disabled, payload is removed" }
            Enabled                    { "Feature is enabled"                      }
        }
        $This.Output += $Item
    }
}

Class WindowsOptionalFeatureItem
{
    [UInt32]                   $Index
    Hidden [Object]          $Feature
    [String]             $FeatureName
    [Object]                   $State
    [String]             $Description
    Hidden [String]             $Path
    Hidden [UInt32]           $Online
    Hidden [String]          $WinPath
    Hidden [String]     $SysDrivePath
    Hidden [UInt32]    $RestartNeeded
    Hidden [String]          $LogPath
    Hidden [String] $ScratchDirectory
    Hidden [String]         $LogLevel
    [UInt32]                 $Profile
    [Object]                  $Target
    WindowsOptionalFeatureItem([UInt32]$Index,[Object]$Feature)
    {
        $This.Index            = $Index
        $This.Feature          = $Feature
        $This.FeatureName      = $Feature.FeatureName
        $This.Path             = $Feature.Path
        $This.Online           = $Feature.Online
        $This.WinPath          = $Feature.WinPath
        $This.SysDrivePath     = $Feature.SysDrivePath
        $This.RestartNeeded    = $Feature.RestartNeeded
        $This.LogPath          = $Feature.LogPath
        $This.ScratchDirectory = $Feature.ScratchDirectory
        $This.LogLevel         = $Feature.LogLevel
    }
    [String] ToString()
    {
        Return "<FESystem.WindowsOptionalFeature[Item]>"
    }
}

Class WindowsOptionalFeatureController
{
    [Object]        $Profile
    [Object]          $State
    [Object]         $Output
    WindowsOptionalFeatureController()
    {
        $This.State   = $This.WindowsOptionalStateList()
    }
    [Object[]] GetObject()
    {
        Return Get-WindowsOptionalFeature -Online | Sort-Object FeatureName 
    }
    [Object] WindowsOptionalStateList()
    {
        Return [WindowsOptionalStateList]::New()
    }
    [Object] WindowsOptionalFeatureItem([UInt32]$Index,[Object]$Feature)
    {
        Return [WindowsOptionalFeatureItem]::New($Index,$Feature)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Feature in $This.GetWindowsOptionalFeature())
        {
            $This.Add($Feature)
        }
    }
    [String[]] ResourceLinks()
    {
        Return "https://www.thewindowsclub.com/windows-10-optional-features-explained",
        "https://en.wikipedia.org/wiki/"
    }
    Add([Object]$Feature)
    {
        $Item             = $This.WindowsOptionalFeatureItem($This.Output.Count,$Feature)
        $Item.Description = Switch ($Item.FeatureName)
        {
            AppServerClient
            {
                "Apparently this is related to [Parallels], which is a virtualization pack"+
                "age related to MacOS."
            }
            Client-DeviceLockdown
            {
                "Allows supression of Windows elements that appear when Windows starts or r"+
                "esumes."
            }
            Client-EmbeddedBootExp
            {
                "Allows supression of Windows elements that appear when Windows starts or re"+
                "sumes."
            }
            Client-EmbeddedLogon
            {
                "Allows use of custom logon feature to suppress Windows 10 UI elements relat"+
                "ed to (Welcome/shutdown) screen."
            }
            Client-EmbeddedShellLauncher
            {
                "Enables OEMs to set a (classic/non-UWP) app as the [system shell]."
            }
            ClientForNFS-Infrastructure
            {
                "Client for (NFS/Network File System) allowing file transfers between (W"+
                "indows Server/UNIX)."
            }
            Client-KeyboardFilter
            {
                "Enables controls that you can use to suppress undesirable key presses or ke"+
                "y combinations."
            }
            Client-ProjFS
            {
                "Windows Projected File System (ProjFS) allows user-mode application provi"+
                "der(s) to project hierarchical data from a backing data store into the fi"+
                "le system, making it [appear] as files and directories in the file system."
            }
            Client-UnifiedWriteFilter
            {
                "Helps to protect device configuration by (intercepting/redirecting) any wri"+
                "tes to the drive (app installations, settings changes, saved data) to a vir"+
                "tual overlay."
            }
            Containers
            {
                "Required to provide (services/tools) to (create/manage) [Windows Server"+
                " Containers]."
            }
            Containers-DisposableClientVM
            {
                "Windows Sandbox provides a lightweight desktop environment to safely run "+
                "applications in isolation."
            }
            DataCenterBridging
            {
                "Standards developed by IEEE for data centers."
            }
            DirectoryServices-ADAM-Client
            {
                "(ADAM/Active Directory Application Mode)"
            }
            DirectPlay
            {
                "DirectPlay is part of Microsoft's DirectX API. It is a network communication"+
                " library intended for computer game development, although it can be used for"+
                " other purposes."
            }
            HostGuardian
            {
                "(HGS/Host Guardian Service) is the centerpiece of the guarded fabric soluti"+
                "on. It ensures that Hyper-V hosts in the fabric are known to the [hoster/en"+
                "terprise], running [trusted software], and [managing key protectors] for [s"+
                "hielded VMs]."
            }
            HypervisorPlatform
            {
                "Used for Hyper-V and/or other virtualization software, allows hardware ba"+
                "sed virtualization components to be used."
            }
            IIS-ApplicationDevelopment
            {
                "(IIS/Internet Information Services) for application development."
            }
            IIS-ApplicationInit
            {
                "(IIS/Internet Information Services) for allowing application initialization."
            }
            IIS-ASP
            {
                "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages)."
            }
            IIS-ASPNET
            {
                "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                "that use the .NET Framework prior to v4.5."
            }
            IIS-ASPNET45
            {
                "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                "that use .NET Framework v4.5+."
            }
            IIS-BasicAuthentication
            {
                "(IIS/Internet Information Services) for enabling basic-authentication."
            }
            IIS-CertProvider
            {
                "(IIS/Internet Information Services) for enabling the certificate provider."
            }
            IIS-CGI
            {
                "(IIS/Internet Information Services) for enabling (CGI/Common Gateway Interface)."
            }
            IIS-ClientCertificateMappingAuthentication
            {
                "(IIS/Internet Information Services) for enabling client-based certificate "+
                "mapping authentication."
            }
            IIS-CommonHttpFeatures
            {
                "(IIS/Internet Information Services) for common HTTP features."
            }
            IIS-CustomLogging
            {
                "(IIS/Internet Information Services) for enabling custom logging."
            }
            IIS-DefaultDocument
            {
                "(IIS/Internet Information Services) for allowing default (website/document) "+
                "model."
            }
            IIS-DigestAuthentication
            {
                "(IIS/Internet Information Services) for enabling digest authentication."
            }
            IIS-DirectoryBrowsing
            {
                "(IIS/Internet Information Services) for allowing directory browsing to be used."
            }
            IIS-FTPExtensibility
            {
                "(IIS/Internet Information Services) for enabling the FTP service/server ext"+
                "ensions."
            }
            IIS-FTPServer
            {
                "(IIS/Internet Information Services) for enabling the FTP server."
            }
            IIS-FTPSvc
            {
                "(IIS/Internet Information Services) for enabling the FTP service."
            }
            IIS-HealthAndDiagnostics
            {
                "(IIS/Internet Information Services) for health and diagnostics."
            }
            IIS-HostableWebCore
            {
                "(WAS/Windows Activation Service) for the hostable web core package."
            }
            IIS-HttpCompressionDynamic
            {
                "(IIS/Internet Information Services) for dynamic compression components."
            }
            IIS-HttpCompressionStatic
            {
                "(IIS/Internet Information Services) for enabling static HTTP compression."
            }
            IIS-HttpErrors
            {
                "(IIS/Internet Information Services) for handling HTTP errors."
            }
            IIS-HttpLogging
            {
                "(IIS/Internet Information Services) for HTTP logging."
            }
            IIS-HttpRedirect
            {
                "(IIS/Internet Information Services) for HTTP redirection, similar to [WebDAV]."
            }
            IIS-HttpTracing
            {
                "(IIS/Internet Information Services) for tracing HTTP requests/etc."
            }
            IIS-IIS6ManagementCompatibility
            {
                "(IIS/Internet Information Services) for compatibility with IIS6*"
            }
            IIS-IISCertificateMappingAuthentication
            {
                "(IIS/Internet Information Services) for enabling IIS-based certificate map"+
                "ping authentication."
            }
            IIS-IPSecurity
            {
                "(IIS/Internet Information Services) for Internet Protocol security."
            }
            IIS-ISAPIExtensions
            {
                "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                "ication Programming Interface) extensions."
            }
            IIS-ISAPIFilter
            {
                "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                "ication Programming Interface) filters."
            }
            IIS-LegacyScripts
            {
                "(IIS/Internet Information Services) for enabling legacy scripts."
            }
            IIS-LegacySnapIn
            {
                "(IIS/Internet Information Services) for enabling legacy snap-ins."
            }
            IIS-LoggingLibraries
            {
                "(IIS/Internet Information Services) for logging libraries."
            }
            IIS-ManagementConsole
            {
                "(IIS/Internet Information Services) for enabling the management console."
            }
            IIS-ManagementScriptingTools
            {
                "(IIS/Internet Information Services) for webserver management scripting."
            }
            IIS-ManagementService
            {
                "(IIS/Internet Information Services) for enabling the management service."
            }
            IIS-Metabase
            {
                "(IIS/Internet Information Services) for (metadata/metabase)."
            }
            IIS-NetFxExtensibility
            {
                "(IIS/Internet Information Services) for .NET Framework extensibility."
            }
            IIS-NetFxExtensibility45
            {
                "(IIS/Internet Information Services) for .NET Framework v4.5+ extensibility."
            }
            IIS-ODBCLogging
            {
                "(IIS/Internet Information Services) for enabling (ODBC/Open Database Conne"+
                "ctivity) logging."
            }
            IIS-Performance
            {
                "(IIS/Internet Information Services) for performance-related components."
            }
            IIS-RequestFiltering
            {
                "(IIS/Internet Information Services) for request-filtering."
            }
            IIS-RequestMonitor
            {
                "(IIS/Internet Information Services) for monitoring HTTP requests."
            }
            IIS-Security
            {
                "(IIS/Internet Information Services) for security-related functions."
            }
            IIS-ServerSideIncludes
            {
                "(IIS/Internet Information Services) for enabling server-side includes."
            }
            IIS-StaticContent
            {
                "(IIS/Internet Information Services) for enabling static webserver content."
            }
            IIS-URLAuthorization
            {
                "(IIS/Internet Information Services) for authorizing (URL/Universal Resource"+
                " Locator)(s)"
            }
            IIS-WebDAV
            {
                "(IIS/Internet Information Services) for enabling the (WebDAV/Web Distributed"+
                " Authoring and Versioning) interface."
            }
            IIS-WebServer
            {
                "(IIS/Internet Information Services) [Web Server], installs the prerequisites"+
                " to run an IIS web server."
            }
            IIS-WebServerManagementTools
            {
                "(IIS/Internet Information Services) for webserver management tools."
            }
            IIS-WebServerRole
            {
                "(IIS/Internet Information Services) [Web Server Role], enables the role for "+
                "running an IIS web server."
            }
            IIS-WebSockets
            {
                "(IIS/Internet Information Services) for enabling web-based sockets."
            }
            IIS-WindowsAuthentication
            {
                "(IIS/Internet Information Services) for enabling Windows account authentication."
            }
            IIS-WMICompatibility
            {
                "(IIS/Internet Information Services) for (WMI/Windows Management Instrumenta"+
                "tion) compatibility/interop."
            }
            Internet-Explorer-Optional-amd64
            {
                "Internet Explorer"
            }
            LegacyComponents
            {
                "[DirectPlay] - Part of the [DirectX] application programming interface."
            }
            MediaPlayback
            {
                "(WMP/Windows Media Player) allows media playback."
            }
            Microsoft-Hyper-V
            {
                "(Hyper-V/Veridian)"
            }
            Microsoft-Hyper-V-All
            {
                "(Hyper-V/Veridian)"
            }
            Microsoft-Hyper-V-Hypervisor
            {
                "(Hyper-V/Veridian)"
            }
            Microsoft-Hyper-V-Management-Clients
            {
                "(Hyper-V/Veridian)"
            }
            Microsoft-Hyper-V-Management-PowerShell
            {
                "(Hyper-V/Veridian) + [PowerShell]"
            }
            Microsoft-Hyper-V-Services
            {
                "(Hyper-V/Veridian)"
            }
            Microsoft-Hyper-V-Tools-All
            {
                "(Hyper-V/Veridian)"
            }
            MicrosoftWindowsPowerShellV2
            {
                "[PowerShell]"
            }
            MicrosoftWindowsPowerShellV2Root
            {
                "[PowerShell]"
            }
            Microsoft-Windows-Subsystem-Linux
            {
                "Installs prerequisites for installing console-based Linux vitual machines."
            }
            MSMQ-ADIntegration
            {
                "(MSMQ/Microsoft Message Queue Server) for (AD/Active Directory) integration."
            }
            MSMQ-Container
            {
               "(MSMQ/Microsoft Message Queue Server) for enabling the container."
            }
            MSMQ-DCOMProxy
            {
                "(MSMQ/Microsoft Message Queue Server) for enabling the (DCOM/Distributed CO"+
                "M) proxy."
            }
            MSMQ-HTTP
            {
                "(MSMQ/Microsoft Message Queue Server) for HTTP integration."
            }
            MSMQ-Multicast
            {
                "(MSMQ/Microsoft Message Queue Server) for enabling multicast."
            }
            MSMQ-Server
            {
                "(MSMQ/Microsoft Message Queue Server) for enabling the server."
            }
            MSMQ-Triggers
            {
                "(MSMQ/Microsoft Message Queue Server) for enabling (trigger events/tasks)."
            }
            MSRDC-Infrastructure
            {
                "(MSRDC/Microsoft Remote Desktop Client)."
            }
            MultiPoint-Connector
            {
                "(Connector) MultiPoint Services allows multiple users to simultaneously sh"+
                "are one computer."
            }
            MultiPoint-Connector-Services
            {
                "(Services) MultiPoint Services allows multiple users to simultaneously sha"+
                "re one computer."
            }
            MultiPoint-Tools
            {
                "(Tools) MultiPoint Services allows multiple users to simultaneously share "+
                "one computer."
            }
            NetFx3
            {
                "(.NET Framework v3.*) This feature is needed to run applications that are wr"+
                "itten for various versions of .NET. Windows automatically installs them when"+
                " required."
            }
            NetFx4-AdvSrvs
            {
                "(.NET Framework v4.*)."
            }
            NetFx4Extended-ASPNET45
            {
                "(.NET Framework v4.*) with extensions for ASP.NET Framework v4.5+."
            }
            NFS-Administration
            {
                "(NFS/Network File System)"
            }
            Printing-Foundation-Features
            {
                "Allows use of (IPC/Internet Printing Client), (LPD/Line printer daemon), a"+
                "nd (LPR/Line printer remote) for using printers over the (internet/LAN)."
            }
            Printing-Foundation-InternetPrinting-Client
            {
                "(IPC/Internet Printing Client) helps you print files from a web browser us"+
                "ing a (connected/shared) printer on the (internet/LAN)."
            }
            Printing-Foundation-LPDPrintService
            {
                "(LPD/Line printer daemon) printer sharing service."
            }
            Printing-Foundation-LPRPortMonitor
            {
                "(LPR/Line printer remote) port monitor service."
            }
            Printing-PrintToPDFServices-Features
            {
                "Allows documents to be printed to (*.pdf) file(s)"
            }
            Printing-XPSServices-Features
            {
                "Allows documents to be printed to (*.xps) file(s)"
            }
            SearchEngine-Client-Package
            {
                "Windows searching & indexing."
            }
            ServicesForNFS-ClientOnly
            {
                "Services for (NFS/Network File System) allowing file transfers between "+
                "(Windows Server/UNIX)."
            }
            SimpleTCP
            {
                "Collection of old command-line tools that include character generator, dayti"+
                "me, discard, echo, etc."
            }
            SMB1Protocol
            {
                "(SMB/Server Message Block) network protocol."
            }
            SMB1Protocol-Client
            {
                "(SMB/Server Message Block) client network protocol."
            }
            SMB1Protocol-Deprecation
            {
                "(SMB/Server Message Block)."
            }
            SMB1Protocol-Server
            {
                "(SMB/Server Message Block) server network protocol."
            }
            SmbDirect
            {
                "(SMB/Server Message Block)."
            }
            TelnetClient
            {
                "Installs the [TELNET] legacy application."
            }
            TFTP
            {
                "A command-line tool that can be used to transfer files via the [Trivial File"+
                " Transfer Protocol]."
            }
            TIFFIFilter
            {
                "Index-and-search (TIFF/Tagged Image File Format) used for Optional Charact"+
                "er Recognition."
            }
            VirtualMachinePlatform
            {
                "Used for Hyper-V and managing individual virtual machines."
            }
            WAS-ConfigurationAPI
            {
                "(WAS/Windows Activation Service) for using the configuration API."
            }
            WAS-NetFxEnvironment
            {
                "(WAS/Windows Activation Service) for using .NET Framework elements."
            }
            WAS-ProcessModel
            {
                "(WAS/Windows Activation Service) for the process model WAS uses."
            }
            WAS-WindowsActivationService
            {
                "(WAS/Windows Activation Service) Used for message-based applications and co"+
                "mponents that are related to Internet Information Services (IIS)."
            }
            WCF-HTTP-Activation
            {
                "(WCF/Windows Communication Foundation) for [HTTP Activation], used for messa"+
                "ge-based applications and components that are related to Internet Informatio"+
                "n Services (IIS)."
            }
            WCF-HTTP-Activation45
            {
                "(WCF/Windows Communication Foundation) for HTTP activation that use .NET Fra"+
                "mework v4.5+."
            }
            WCF-MSMQ-Activation45
            {
                "(WCF/Windows Communication Foundation) for MSMQ activation that use .NET Fra"+
                "mework v4.5+."
            }
            WCF-NonHTTP-Activation
            {
                "Windows Communication Foundation [Non-HTTP Activation], used for message-bas"+
                "ed applications and components that are related to Internet Information Serv"+
                "ices (IIS)."
            }
            WCF-Pipe-Activation45
            {
                "(WCF/Windows Communication Foundation) for named-pipe activation that use .N"+
                "ET Framework v4.5+."
            }
            WCF-Services45
            {
                "(WCF/Windows Communication Foundation) services that use .NET Framework v4.5+"
            }
            WCF-TCP-Activation45
            {
                "(WCF/Windows Communication Foundation) for TCP activation that use .NET Fram"+
                "ework v4.5+."
            }
            WCF-TCP-PortSharing45
            {
                "(WCF/Windows Communication Foundation) for TCP port sharing that use .NET Fr"+
                "amework v4.5+."
            }
            Windows-Defender-ApplicationGuard
            {
                "(WDAG/Windows Defender Application Guard) uses [Hyper-V] to run [Micros"+
                "oft Edge] in an isolated container."
            }
            Windows-Defender-Default-Definitions
            {
                "Default [Windows Defender] definitions."
            }
            Windows-Identity-Foundation
            {
                "A software framework for building identity-aware applications. The .NET Fram"+
                "ework 4.5 includes a newer version of this framework."
            }
            WindowsMediaPlayer
            {
                "(WMP/Windows Media Player) enables the integrated media player."
            }
            WorkFolders-Client
            {
                "Windows Server role service for file servers."
            }
            Default
            {
                "Unknown"
            }
        }

        $This.Output += $Item
    }
    [String] ToString()
    {
        Return "<FEModule.WindowsOptionalFeature[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ AppX Classes   ]______________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Enum AppXStateType
{
    Skip
    Unhide
    Hide
    Uninstall
    Null
}
    
Class AppXStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    AppXStateItem([String]$Name)
    {
        $This.Index  = [UInt32][AppXStateType]::$Name
        $This.Name   = [AppXStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}
    
Class AppXStateList
{
    [Object] $Output
    AppXStateList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] AppXStateItem([String]$Name)
    {
        Return [AppXStateItem]::New($Name)
    }
    Add([Object]$Item)
    {
        $This.Output += $Item
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([AppXStateType]))
        {
            $Item             = $This.AppXStateItem($Name)
            $Item.Description = Switch ($Item.Index)
            {
                0 { "Skip this particular AppX application."      }
                1 { "Hide this particular AppX application."      }
                2 { "Unhide this particular AppX application."    }
                3 { "Uninstall this particular AppX application." }
                4 { "Null, or not applicable."                    }
            }

            $This.Add($Item)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.AppXState[List]>"
    }
}
    
Class AppXItem
{
    [UInt32]                   $Index
    Hidden [Object]             $AppX
    [String]                    $Name
    [String]             $DisplayName
    [String]             $Description
    [String]             $PackageName
    [String]                 $Version
    [String]             $PublisherID
    [Object]                   $State
    [UInt32]            $MajorVersion
    [UInt32]            $MinorVersion
    [UInt32]                   $Build
    [UInt32]                $Revision
    [UInt32]            $Architecture
    [String]              $ResourceID
    [String]         $InstallLocation
    [Object]                 $Regions
    Hidden [String]             $Path
    Hidden [UInt32]           $Online
    Hidden [String]          $WinPath
    Hidden [String]     $SysDrivePath
    Hidden [UInt32]    $RestartNeeded
    Hidden [String]          $LogPath
    Hidden [String] $ScratchDirectory
    Hidden [String]         $LogLevel
    [UInt32]                 $Profile
    [Object]                  $Target
    AppXItem([UInt32]$Index,[Object]$AppX)
    {
        $This.Index            = $Index
        $This.AppX             = $AppX
        $This.Version          = $AppX.Version
        $This.PackageName      = $AppX.PackageName
        $This.DisplayName      = $AppX.DisplayName
        $This.PublisherId      = $AppX.PublisherId
        $This.MajorVersion     = $AppX.MajorVersion
        $This.MinorVersion     = $AppX.MinorVersion
        $This.Build            = $AppX.Build
        $This.Revision         = $AppX.Revision
        $This.Architecture     = $AppX.Architecture
        $This.ResourceId       = $AppX.ResourceId
        $This.InstallLocation  = $AppX.InstallLocation
        $This.Regions          = $AppX.Regions
        $This.Path             = $AppX.Path
        $This.Online           = $AppX.Online
        $This.WinPath          = $AppX.WinPath
        $This.SysDrivePath     = $AppX.SysDrivePath
        $This.RestartNeeded    = $AppX.RestartNeeded
        $This.LogPath          = $AppX.LogPath
        $This.ScratchDirectory = $AppX.ScratchDirectory
        $This.LogLevel         = $AppX.LogLevel
    }
}
    
Class AppXController
{
    [Object]        $Profile
    [Object]          $State
    [Object]         $Output
    AppXController()
    {
        $This.State   = $This.AppXStateList()
    }
    [Object[]] GetObject()
    {
        Return Get-AppxProvisionedPackage -Online | Sort-Object DisplayName
    }
    [Object] AppXItem([UInt32]$Index,[Object]$AppX)
    {
        Return [AppXItem]::New($Index,$AppX)
    }
    [Object] AppXStateList()
    {
        Return [AppXStateList]::New()
    }
    Clear()
    {
        $This.Output  = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($AppX in $This.GetAppXProvisionedPackage())
        {
            $This.Add($AppX)
        }
    }
    Add([Object]$AppX)
    {
        $Item             = $This.AppXItem($This.Output.Count,$AppX)
        $Item.Description = Switch ($Item.DisplayName)
        {
            "Microsoft.549981C3F5F10"
            {
                "[Cortana], your personal productivity assistant, helps you stay on"+
                " top of what matters and save time finding what you need."
            }
            "Microsoft.BingWeather"
            {
                "[MSN Weather], get a [Microsoft Edge] on the latest weather condit"+
                "ions, see (10-day/hourly) forecasts."
            }
            "Microsoft.DesktopAppInstaller"
            {
                "[WinGet Package Manager], allows developers to install (*.appx/*.a"+
                "ppxbundle) files on their [Windows PC] without (PowerShell/CMD)."
            }
            "Microsoft.GetHelp"
            {
                "[Get-Help] command for [PowerShell], but also GUI driven help."
            }
            "Microsoft.Getstarted"
            {
                "In order to get down to business with [Office 365], you can use th"+
                "is to get started."
            }
            "Microsoft.HEIFImageExtension"
            {
                "Allows users to view [HEIF images] on [Windows]."
            }
            "Microsoft.Microsoft3DViewer"
            {
                "Allows users to (view/interact) with 3D models on your device."
            }
            "Microsoft.MicrosoftEdge.Stable"
            {
                "[Microsoft Edge] is a [Chromium]-based web browser, which offers m"+
                "any improvements over [Internet Explorer]."
            }
            "Microsoft.MicrosoftOfficeHub"
            {
                "Central location for all your [Microsoft Office] apps."
            }
            "Microsoft.MicrosoftSolitaireCollection"
            {
                "Collection of card games including [Klondike], [Spider], [FreeCell"+
                "], [Pyramid], and [TriPeaks]."
            }
            "Microsoft.MicrosoftStickyNotes"
            {
                "Note-taking application that allows users to create [notes], [typ"+
                "e], [ink], or [add a picture], [text formatting], stick them to t"+
                "he desktop, move them around freely, close them to the notes list"+
                ", and sync them across devices and apps like [OneNote Mobile], [M"+
                "icrosoft Launcher for Android], and [Outlook for Windows]."
            }
            "Microsoft.MixedReality.Portal"
            {
                "Provides main Windows Mixed Reality experience in [Windows 10] ver"+
                "sions (1709/1803) and is a key component of the [Windows 10] opera"+
                "ting system updated via [Windows Update]."
            }
            "Microsoft.MSPaint"
            {
                "Simple graphics editor that allows users to create and edit images"+
                " using various tools such as brushes, pencils, shapes, text, and m"+
                "ore."
            }
            "Microsoft.Office.OneNote"
            {
                "OneNote is a digital note-taking app that allows users to create a"+
                "nd organize notes, drawings, audio recordings, and more."
            }
            "Microsoft.People"
            {
                "Contact management app that allows users to store and manage their"+
                " contacts in one place."
            }
            "Microsoft.ScreenSketch"
            {
                "Screen Sketch is a screen capture and annotation tool that allows "+
                "users to take screenshots and annotate them with a pen or highligh"+
                "ter."
            }
            "Microsoft.SkypeApp"
            {
                "Skype is a communication app that allows users to make voice and v"+
                "ideo calls, send instant messages, and share files with other Skyp"+
                "e users."
            }
            "Microsoft.StorePurchaseApp"
            {
                "[Microsoft Store Purchase] app is used to purchase apps and games "+
                "from the [Microsoft Store]."
            }
            "Microsoft.VCLibs.140.00"
            {
                "Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 "+
                "nd 2019 version 14. Installs runtime components of Visual C++ Libr"+
                "aries required to run applications developed with Visual Studio."
            }
            "Microsoft.VP9VideoExtensions"
            {
                "VP9 Video Extensions for [Microsoft Edge]. These extensions are de"+
                "signed to take advantage of hardware capabilities on newer devices"+
                " and are used for streaming over the internet."
            }
            "Microsoft.Wallet"
            {
                "Microsoft Wallet is a mobile payment and digital wallet service by"+
                " Microsoft."
            }
            "Microsoft.WebMediaExtensions"
            {
                "Utilities & Tools App (UWP App/Microsoft Store Edition) that exten"+
                "s [Microsoft Edge] and [Windows] to support open source formats co"+
                "mmonly encountered on the web."
            }
            "Microsoft.WebpImageExtension"
            {
                "Enables viewing WebP images in [Microsoft Edge]. WebP provides (lo"+
                "ssless/lossy) compression for images."
            }
            "Microsoft.Windows.Photos"
            {
                "Easy to use (photo/video) management and editing application that "+
                "integrates well with [OneDrive]."
            }
            "Microsoft.WindowsAlarms"
            {
                "Alarm clock app that comes with [Windows] that allows setting (ala"+
                "rms/timers/reminders) for important events."
            }
            "Microsoft.WindowsCalculator"
            {
                "Calculator app that comes with [Windows], and provides standard, s"+
                "cientific, and programmer calculator functionality, as well as a s"+
                "et of converters between various units of measurement and currenci"+
                "es."
            }
            "Microsoft.WindowsCamera"
            {
                "Camera app that comes with [Windows], allows (taking photos/record"+
                "ing videos) using built-in camera or an external webcam."
            }
            "Microsoft.WindowsCommunicationsApps"
            {
                "(Email/calendar) app that comes with [Windows]."
            }
            "Microsoft.WindowsFeedbackHub"
            {
                "App that comes with [Windows] and allows providing feedback about "+
                "[Windows] and its features."
            }
            "Microsoft.WindowsMaps"
            {
                "App that comes with [Windows] and allows search navigation, voice "+
                "navigation, driving, transit, and walking directions."
            }
            "Microsoft.WindowsSoundRecorder"
            {
                "Audio recording program included in [Windows], allows recording au"+
                "dio for up to three hours per recording."
            }
            "Microsoft.WindowsStore"
            {
                "Official app store for [Windows], and allowing the download of app"+
                "s, games, music, movies, TV shows and more."
            }
            "Microsoft.Xbox.TCUI"
            {
                "Component of the [Xbox Live] in-game experience or [Xbox TCUI], al"+
                "lows playing games on PC, connecting with friends, and sharing gam"+
                "ing experiences."
            }
            "Microsoft.XboxApp"
            {
                "[Xbox Console Companion] is an app that allows you to play games o"+
                "n your PC, connect with friends, and share your gaming experiences."
            }
            "Microsoft.XboxGameOverlay"
            {
                "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                "ws] that allows you to access widgets and tools without leaving yo"+
                "ur game."
            }
            "Microsoft.XboxGamingOverlay"
            {
                "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                "ws] that allows you to access widgets and tools without leaving yo"+
                "ur game."
            }
            "Microsoft.XboxIdentityProvider"
            {
                "[Xbox Console Companion] is an app that allows you to play games o"+
                "n your PC, connect with friends, and share your gaming experiences."
            }
            "Microsoft.XboxSpeechToTextOverlay"
            {
                "[Xbox Game Bar], converts speech to text."
            }
            "Microsoft.YourPhone"
            {
                "App that allows directly connecting a smartphone to a PC."
            }
            "Microsoft.ZuneMusic"
            {
                "Zune Music is a discontinued music streaming service and software"+
                " from Microsoft."
            }
            "Microsoft.ZuneVideo"
            {
                "Zune Video is a discontinued video streaming service and software "+
                "from Microsoft."
            }
            Default
            {
                "Unknown"
            }
        }

        $This.Output     += $Item
    }
    [String] ToString()
    {
        Return "<FEModule.AppX[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Applications   ]______________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class ApplicationItem
{
    Hidden [UInt32]           $Index
    Hidden [Object]     $Application
    [String]                   $Type
    [String]            $DisplayName
    [String]         $DisplayVersion
    Hidden [String]         $Version
    Hidden [Int32]         $NoRemove
    Hidden [String]      $ModifyPath
    Hidden [String] $UninstallString
    Hidden [String] $InstallLocation
    Hidden [String]     $DisplayIcon
    Hidden [Int32]         $NoRepair
    Hidden [String]       $Publisher
    Hidden [String]     $InstallDate
    Hidden [Int32]     $VersionMajor
    Hidden [Int32]     $VersionMinor
    ApplicationItem([UInt32]$Index,[Object]$App)
    {
        $This.Index            = $Index
        $This.Type             = @("MSI","WMI")[$App.UninstallString -imatch "msiexec"]
        $This.DisplayName      = @("-",$App.DisplayName)[!!$App.DisplayName]
        $This.DisplayVersion   = @("-",$App.DisplayVersion)[!!$App.DisplayVersion]
        $This.Version          = @("-",$App.Version)[!!$App.Version]
        $This.NoRemove         = $App.NoRemove
        $This.ModifyPath       = $App.ModifyPath
        $This.UninstallString  = $App.UninstallString
        $This.InstallLocation  = $App.InstallLocation
        $This.DisplayIcon      = $App.DisplayIcon
        $This.NoRepair         = $App.NoRepair
        $This.Publisher        = $App.Publisher
        $This.InstallDate      = $App.InstallDate
        $This.VersionMajor     = $App.VersionMajor
        $This.VersionMinor     = $App.VersionMinor
    }
    ApplicationItem([UInt32]$Index,[String]$Type,[String]$DisplayName,[String]$DisplayVersion)
    {
        $This.Index            = $Index
        $This.Type             = $Type
        $This.DisplayName      = $DisplayName
        $This.DisplayVersion   = $DisplayVersion
    }
    [String] ToString()
    {
        Return "<FESystem.Application[Item]>"
    }
}

Class ApplicationController
{
    [Object] $Profile
    [Object]  $Output
    ApplicationController()
    {

    }
    [Object] Application([UInt32]$Index,[Object]$Application)
    {
        Return [ApplicationItem]::New($Index,$Application)
    }
    [Object[]] GetObject()
    {
        $Item = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        $Slot = Switch ([Environment]::GetEnvironmentVariable("Processor_Architecture"))
        {
            AMD64   { 0,1 } Default { 0 }
        }

        Return $Item[$Slot] | % { Get-ItemProperty $_ } | ? DisplayName | Sort-Object DisplayName
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Application in $This.GetObject())
        {
            $This.Add($Application)
        }
    }
    Add([Object]$Application)
    {
        $This.Output += $This.Application($This.Output.Count,$Application)
    }
    [String] ToString()
    {
        Return "<FESystem.Application[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Event Log Classes  ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class EventLogProviderItem
{
    Hidden [UInt32] $Index
    [String]         $Name
    [String]  $DisplayName
    EventLogProviderItem([UInt32]$Index,[String]$Name)
    {
        $This.Index       = $Index
        $This.Name        = "Provider$Index"
        $This.DisplayName = $Name
    }
    [String] ToString()
    {
        Return "<FESystem.EventLogProvider[Item]>"
    }
}

Class EventLogProviderController
{
    [Object]     $Profile
    [Object]      $Output
    EventLogProviderController()
    {

    }
    [Object] EventLogProviderItem([UInt32]$Index,[String]$Name)
    {
        Return [EventLogProviderItem]::New($Index,$Name)
    }
    [Object[]] GetObject()
    {
        Return Get-WinEvent -ListLog * | % LogName | Sort-Object
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Item in $This.GetObject())
        {
            $This.Add($Item)
        }
    }
    Add([String]$Name)
    {
        $This.Output += $This.EventLogProviderItem($This.Output.Count,$Name)
    }
    [String] ToString()
    {
        Return "<FESystem.EventLogProvider[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Scheduled Tasks    ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Enum ScheduledTaskStateType
{
    Disabled
    Ready
    Running
}

Class ScheduledTaskStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    ScheduledTaskStateItem([String]$Name)
    {
        $This.Index = [UInt32][ScheduledTaskStateType]::$Name
        $This.Name  = [ScheduledTaskStateType]::$Name        
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class ScheduledTaskStateList
{
    [Object] $Output
    ScheduledTaskStateList()
    {
        $This.Output = @( )
        ForEach ($Name in [System.Enum]::GetNames([ScheduledTaskStateType]))
        {
            $This.Add($Name)
        }
    }
    Add([String]$Type)
    {
        $Item             = [ScheduledTaskStateItem]::New($Type)
        $Item.Description = Switch ($Type)
        {
            Disabled { "The scheduled task is currently disabled."        }
            Ready    { "The scheduled task is enabled, and ready to run." }
            Running  { "The scheduled task is currently running."         }
        }

        $This.Output     += $Item
    }
}

Class ScheduledTaskItem
{
    Hidden [UInt32] $Index
    Hidden [Object]  $Task
    [String]         $Path
    [String]         $Name
    [Object]        $State
    ScheduledTaskItem([UInt32]$Index,[Object]$Task)
    {
        $This.Index = $Index
        $This.Task  = $Task
        $This.Path  = $Task.TaskPath
        $This.Name  = $Task.TaskName
    }
    [String] ToString()
    {
        Return "<FESystem.ScheduledTask[Item]>"
    }
}

Class ScheduledTaskController
{
    [Object] $Profile
    [Object]   $State
    [Object]  $Output
    ScheduledTaskController()
    {
        $This.State  = $This.ScheduledTaskStateList()
    }
    [Object] ScheduledTaskStateList()
    {
        Return [ScheduledTaskStateList]::New().Output
    }
    [Object[]] GetObject()
    {
        Return Get-ScheduledTask
    }
    [Object] GetScheduledTaskItem([UInt32]$Index,[Object]$Task)
    {
        Return [ScheduledTaskItem]::New($Index,$Task)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Task in $This.GetObject())
        {
            $This.Add($Task)
        }
    }
    Add([Object]$Task)
    {
        $Item         = $This.GetScheduledTaskItem($This.Output.Count,$Task)           
        $Item.State   = $This.State | ? Type -eq $Task.State
        $This.Output += $Item 
    }
    [String] ToString()
    {
        Return "<FESystem.ScheduledTask[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Processor Classes ]___________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class ProcessorItem
{
    [UInt32]            $Index
    Hidden [Object] $Processor
    [String]     $Manufacturer
    [String]             $Name
    [String]          $Caption
    [UInt32]            $Cores
    [UInt32]             $Used
    [UInt32]          $Logical
    [UInt32]          $Threads
    [String]      $ProcessorId
    [String]         $DeviceId
    [UInt32]            $Speed
    ProcessorItem([UInt32]$Index,[Object]$Processor)
    {
        $This.Index        = $Index
        $This.Processor    = $Processor
        $This.Manufacturer = Switch -Regex ($Processor.Manufacturer) 
        {
           Intel { "Intel" } Amd { "AMD" } Default { $Processor.Manufacturer }
        }
        $This.Name         = $Processor.Name -Replace "\s+"," "
        $This.Caption      = $Processor.Caption
        $This.Cores        = $Processor.NumberOfCores
        $This.Used         = $Processor.NumberOfEnabledCore
        $This.Logical      = $Processor.NumberOfLogicalProcessors 
        $This.Threads      = $Processor.ThreadCount
        $This.ProcessorID  = $Processor.ProcessorId
        $This.DeviceID     = $Processor.DeviceID
        $This.Speed        = $Processor.MaxClockSpeed
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class ProcessorController
{
    [Object]      $Output
    ProcessorController()
    {

    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Processor in $This.GetObject())
        {
            $This.Add($Processor)
        }
    }
    [Object[]] GetObject()
    {
        Return Get-CimInstance Win32_Processor
    }
    [Object] ProcessorItem([UInt32]$Index,[Object]$Processor)
    {
        Return [ProcessorItem]::New($Index,$Processor)
    }
    Add([Object]$Processor)
    {
        $This.Output += $This.ProcessorItem($This.Output.Count,$Processor)
    }
    [String] ToString()
    {
        Return "<FESystem.Processor[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Disk Classes ]________________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class PartitionItem
{
    [UInt32]            $Index
    Hidden [Object] $Partition
    Hidden [String]     $Label
    [String]             $Type
    [String]             $Name
    [Object]             $Size
    [UInt32]             $Boot
    [UInt32]          $Primary
    [UInt32]             $Disk
    [UInt32]        $PartIndex
    PartitionItem([UInt32]$Index,[Object]$Partition)
    {
        $This.Index      = $Index
        $This.Partition  = $Partition
        $This.Type       = $Partition.Type
        $This.Name       = $Partition.Name
        $This.Size       = $This.GetSize($Partition.Size)
        $This.Boot       = $Partition.BootPartition
        $This.Primary    = $Partition.PrimaryPartition
        $This.Disk       = $Partition.DiskIndex
        $This.PartIndex  = $Partition.Index
    }
    [Object] GetSize([UInt64]$Bytes)
    {
        Return [ByteSize]::New("Partition",$Bytes)
    }
    [String] ToString()
    {
        Return "<FESystem.Partition[Item]>"
    }
}

Class PartitionList : GenericList
{
    PartitionList([String]$Name) : base($Name)
    {
        
    }
}

Class VolumeItem
{
    [UInt32]            $Index
    Hidden [Object]     $Drive
    Hidden [Object] $Partition
    Hidden [String]     $Label
    [UInt32]             $Rank
    [String]          $DriveID
    [String]      $Description
    [String]       $Filesystem
    [String]       $VolumeName
    [String]     $VolumeSerial
    [Object]             $Size
    [Object]        $Freespace
    [Object]             $Used
    VolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
    {
        $This.Index             = $Index
        $This.Drive             = $Drive
        $This.Partition         = $Partition
        $This.DriveID           = $Drive.Name
        $This.Description       = $Drive.Description
        $This.Filesystem        = $Drive.Filesystem
        $This.VolumeName        = $Drive.VolumeName
        $This.VolumeSerial      = $Drive.VolumeSerialNumber
        $This.Size              = $This.GetSize("Total",$Drive.Size)
        $This.Freespace         = $This.GetSize("Free",$Drive.Freespace)
        $This.Used              = $This.GetSize("Used",($This.Size.Bytes - $This.Freespace.Bytes))
    }
    [Object] GetSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [String] ToString()
    {
        Return "<FESystem.Volume[Item]>"
    }
}

Class VolumeList : GenericList
{
    VolumeList([String]$Name) : base($Name)
    {
        
    }
}

Class DiskItem
{
    [UInt32]             $Index
    Hidden [Object]  $DiskDrive
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
    DiskItem([Object]$Disk)
    {
        $This.Index             = $Disk.Index
        $This.Disk              = $Disk.DeviceId
        $This.Partition         = $This.New("Partition")
        $This.Volume            = $This.New("Volume")
    }
    MsftDisk([Object]$MsftDisk)
    {
        $This.Model             = $MsftDisk.Model
        $This.Serial            = $MsftDisk.SerialNumber -Replace "^\s+",""
        $This.PartitionStyle    = $MsftDisk.PartitionStyle
        $This.ProvisioningType  = $MsftDisk.ProvisioningType
        $This.OperationalStatus = $MsftDisk.OperationalStatus
        $This.HealthStatus      = $MsftDisk.HealthStatus
        $This.BusType           = $MsftDisk.BusType
        $This.UniqueId          = $MsftDisk.UniqueId
        $This.Location          = $MsftDisk.Location
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Partition { [PartitionList]::New("Partition") }
            Volume    {    [VolumeList]::New("Volume")    }
        }

        Return $Item
    }
    [String] ToString()
    {
        Return "<FESystem.Disk[Item]>"
    }
}

Class DiskController
{
    Hidden [Object[]]         $DiskDrive
    Hidden [Object[]]          $MsftDisk
    Hidden [Object[]]     $DiskPartition
    Hidden [Object[]]       $LogicalDisk
    Hidden [Object[]] $LogicalDiskToPart
    [Object]                     $Output
    DiskController()
    {

    }
    Refresh()
    {
        $This.DiskDrive         = $This.Get("DiskDrive")
        $This.MsftDisk          = $This.Get("MsftDisk")
        $This.DiskPartition     = $This.Get("DiskPartition")
        $This.LogicalDisk       = $This.Get("LogicalDisk")
        $This.LogicalDiskToPart = $This.Get("LogicalDiskToPart")

        $This.Populate()
    }
    [Object[]] Get([String]$Name)
    {
        $Item = Switch ($Name)
        {
            DiskDrive         { Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed          }
            MsftDisk          { Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage }
            DiskPartition     { Get-CimInstance Win32_DiskPartition                                 }
            LogicalDisk       { Get-CimInstance Win32_LogicalDisk                                   }
            LogicalDiskToPart { Get-CimInstance Win32_LogicalDiskToPartition                        }
        }

        Return $Item
    }
    [Object] DiskItem([Object]$Disk)
    {
        Return [DiskItem]::New($Disk)
    }
    [Object] PartitionItem([UInt32]$Index,[Object]$Partition)
    {
        Return [PartitionItem]::New($Index,$Partition)
    }
    [Object] VolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
    {
        Return [VolumeItem]::New($Index,$Drive,$Partition)
    }
    Populate()
    {
        ForEach ($Drive in $This.DiskDrive | ? MediaType -match Fixed)
        {
            # [Disk Template]
            $Disk     = $This.DiskItem($Drive)

            # [MsftDisk]
            $Msft     = $This.MsftDisk | ? Number -eq $Disk.Index
            If ($Msft)
            {
                $Disk.MsftDisk($Msft)
            }

            # [Partitions]
            ForEach ($Partition in $This.DiskPartition | ? DiskIndex -eq $Disk.Index)
            {
                $Disk.Partition.Add($This.PartitionItem($Disk.Partition.Count,$Partition))
            }

            # [Volumes]
            ForEach ($Logical in $This.LogicalDiskToPart | ? { $_.Antecedent.DeviceID -in $This.DiskPartition.Name})
            {
                $Drive      = $This.LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                $Partition  = $This.DiskPartition | ? Name -eq $Logical.Antecedent.DeviceID
                If ($Drive -and $Partition)
                {
                    $Volume = $This.VolumeItem($Disk.Volume.Count,$Drive,$Partition)
                    $Disk.Volume.Add($Volume)
                }
            }

            $This.Output += $Disk
        }
    }
    [String] ToString()
    {
        Return "<FESystem.Disk[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Network Controller ]__________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class NetworkItem
{
    [UInt32]       $Index
    [String]        $Name
    [UInt32]      $Status
    [String]   $IPAddress
    [String]  $SubnetMask
    [String]     $Gateway
    [String]   $DnsServer
    [String]  $DhcpServer
    [String]  $MacAddress
    NetworkItem([UInt32]$Index,[Object]$Interface)
    {
        $This.Index               = $Index
        $This.Name                = $Interface.Description
        $This.Status              = $Interface.IPEnabled
        Switch ($This.Status)
        {
            0
            {
                $This.IPAddress   = "-"
                $This.SubnetMask  = "-"
                $This.Gateway     = "-"
                $This.DnsServer   = "-"
                $This.DhcpServer  = "-"
            }
            1
            {
                $This.IPAddress   = $this.Ip($Interface.IPAddress)
                $This.SubnetMask  = $This.Ip($Interface.IPSubnet)
                If ($Interface.DefaultIPGateway)
                {
                    $This.Gateway = $This.Ip($Interface.DefaultIPGateway)
                }

                $This.DnsServer   = ($Interface.DnsServerSearchOrder | % { $This.Ip($_) }) -join ", "
                $This.DhcpServer  = $This.Ip($Interface.DhcpServer)
            }     
        }

        $This.MacAddress          = ("-",$Interface.MacAddress)[!!$Interface.MacAddress]
    }
    [String] Ip([Object]$Property)
    {
        Return $Property | ? {$_ -match "(\d+\.){3}\d+"}
    }
    [String] ToString()
    {
        Return "<FESystem.Network[Item]>"
    }
}

Class NetworkController : GenericList
{
    NetworkController([String]$Name) : Base($Name)
    {

    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Network in $This.GetObject())
        {
            $This.Add($Network)
        }
    }
    [Object[]] GetObject()
    {
        Return Get-CimInstance Win32_NetworkAdapterConfiguration
    }
    [Object] NetworkItem([UInt32]$Index,[Object]$Network)
    {
        Return [NetworkItem]::New($Index,$Network)
    }
    [String] ToString()
    {
        Return "<FESystem.Network[Controller]>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Snapshot Controller    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class SnapshotController
{
    [Object]          $Module
    [Object] $BiosInformation
    [Object] $OperatingSystem
    [Object]  $ComputerSystem
    [Object]         $Current
    [Object]         $Edition
    [Object]        $Snapshot
    [Object]          $HotFix
    [Object]         $Feature
    [Object]            $AppX
    [Object]     $Application
    [Object]           $Event
    [Object]            $Task
    [Object]       $Processor
    [Object]            $Disk
    [Object]         $Network
    SnapshotController()
    {
        $This.Module = $This.Get("Module")
        $This.Main()
    }
    SystemController([Object]$Module)
    {
        $This.Module = $Module
        $This.Main()
    }
    Update([Int32]$State,[String]$Status)
    {
        $This.Module.Update($State,$Status)
        $Last = $This.Module.Console.Last()
        If ($This.Module.Mode -ne 0)
        {
            [Console]::WriteLine($Last.String)
        }
    }
    [String] Start()
    {
        Return $This.Module.Console.Start.Time.ToString("yyyy-MMdd-HHmmss")
    }
    [String] CurrentVersion()
    {
        Return "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    }
    Main()
    {
        $This.Module.Mode     = 1

        # [Firmware/System]
        $This.BiosInformation = $This.Get("Bios")
        $This.OperatingSystem = $This.Get("OS")
        $This.ComputerSystem  = $This.Get("CS")
        $This.Current         = $This.Get("Current")
        $This.Edition         = $This.Get("Edition")
        $This.Snapshot        = $This.Get("Snapshot")

        $This.PopulateSnapshot()

        # [Software]
        $This.HotFix          = $This.Get("HotFix")
        $This.Feature         = $This.Get("Feature")
        $This.AppX            = $This.Get("AppX")
        $This.Application     = $This.Get("Application")
        $This.Event           = $This.Get("Event")
        $This.Task            = $This.Get("Task")
        
        # [Hardware]
        $This.Processor       = $This.Get("Processor")
        $This.Disk            = $This.Get("Disk")
        $This.Network         = $This.Get("Network")

        $This.RefreshAll()
    }
    RefreshAll()
    {
        $This.PopulateSnapshot()

        ForEach ($Item in "HotFix Feature AppX Application Event Task Processor Disk Network" -Split " ")
        {
            $This.Refresh($Item)
        }
    }
    Refresh([String]$Name)
    {
        Switch ($Name)
        {
            HotFix      
            { 
                $This.Update(0,"Refreshing [~] Hot Fixes")

                $Object = $This.HotFix
                $Object.Clear()

                ForEach ($HotFix in $Object.GetObject())
                {
                    $Line = "[HotFix]: {0}" -f $HotFix.HotFixId
                    $This.Update(1,$Line)
                    $Object.Add($HotFix)
                }

                $This.Update(1,"Refreshed [+] Hot Fixes")
            }
            Feature
            {
                $This.Update(0,"Refreshing [~] Windows Optional Features")

                $Object = $This.Feature
                $Object.Clear()
            
                ForEach ($Feature in $Object.GetObject())
                {
                    $State = Switch ($Feature.State)
                    {
                        Disabled                   { "_" }
                        DisabledWithPayloadRemoved { "!" }
                        Enabled                    { "X" }                        
                    }

                    $Line = "[Feature]: [{0}] {1}" -f $State, $Feature.FeatureName
                    $This.Update(1,$Line)

                    $Object.Add($Feature)
                }
                
                $This.Update(0,"Refreshed [+] Windows Optional Features")
            }
            AppX
            { 
                $This.Update(0,"Refreshing [~] AppX Applications")

                $Object = $This.AppX
                $Object.Clear()
    
                ForEach ($AppX in $Object.GetObject())
                {
                    $Line = "[AppX]: {0}" -f $AppX.DisplayName
                    $This.Update(1,$Line)

                    $Object.Add($AppX)
                }

                $This.Update(1,"Refreshed [+] AppX Applications")
            }
            Application
            { 
                $This.Update(0,"Refreshing [~] Installed Applications")

                $Object = $This.Application 
                $Object.Clear()

                ForEach ($Application in $Object.GetObject())
                {
                    $Line = "[Application]: {0}" -f $Application.DisplayName
                    $This.Update(1,$Line)

                    $Object.Add($Application)
                }

                $This.Update(1,"Refreshed [+] Installed Applications")
            }
            Event
            {
                $This.Update(0,"Refreshing [~] Windows Event Logs")

                $Object = $This.Event
                $Object.Clear()

                ForEach ($WinEvent in $Object.GetObject())
                {
                    $Line = "[Event Log]: {0}" -f $WinEvent
                    $This.Update(1,$Line)
                    $Object.Add($WinEvent)
                }

                $This.Update(1,"Refreshed [+] Windows Event Logs")
            }
            Task
            {
                $This.Update(0,"Refreshing [~] Scheduled Tasks")

                $Object = $This.Task
                $Object.Clear()

                ForEach ($Task in $Object.GetObject())
                {
                    $State = Switch ($Task.State)
                    {
                        Ready    { "[+]" }
                        Running  { "[~]" }
                        Disabled { "[X]" }
                    }
                    $Line = "[Task]: {0} {1}" -f $State, $Task.TaskName
                    $This.Update(1,$Line)
                    $Object.Add($Task)
                }

                $This.Update(1,"Refreshed [+] Scheduled Tasks")
            }
            Processor
            {
                $This.Update(0,"Refreshing [~] Processor(s)")

                $Object = $This.Processor
                $Object.Clear()

                ForEach ($CPU in $Object.GetObject())
                {
                    $Line = "[Processor]: {0}" -f $CPU.Name
                    $This.Update(1,$Line)
                    $Object.Add($CPU)
                }

                $This.Update(1,"Refreshed [+] Processor(s)")
            }
            Network
            {
                $This.Update(0,"Refreshing [~] Network Adapter(s)")

                $Object = $This.Network
                $Object.Clear()

                ForEach ($Network in $Object.GetObject())
                {
                    $State = @("[ ]","[+]")[$Network.IpEnabled]
                    $Line  = "[Network]: {0} {1}" -f $State, $Network.Description
                    $This.Update(1,$Line)
                    $Object.Add($Network)
                }

                $This.Update(1,"Refreshed [+] Network Adapter(s)")
            }
        }
    }
    [Object] Get([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Module
            {
                Get-FEModule -Mode 1
            }
            Bios
            {
                $This.Update(0,"Getting [~] Bios Information")
                [BiosInformation]::New()
            }
            OS
            {
                $This.Update(0,"Getting [~] Operating System")
                [OperatingSystem]::New()
            }
            CS
            {
                $This.Update(0,"Getting [~] Computer System")
                [ComputerSystem]::New()
            }
            Current
            {
                $This.Update(0,"Getting [~] Current Version")
                [CurrentVersion]::New()
            }
            Edition
            {
                $This.Update(0,"Getting [~] Edition")
                [EditionController]::New($This.Current)
            }
            Snapshot
            {
                $This.Update(0,"Getting [~] Snapshot")
                [Snapshot]::New()
            }
            Principal
            {
                $This.Update(0,"Getting [~] Windows Principal")
                [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            }
            Guid
            {
                $This.Update(0,"Getting [~] GUID")
                [Guid]::NewGuid()
            }
            HotFix
            {
                $This.Update(0,"Getting [~] HotFix")
                [HotFixController]::New()
            }
            Feature
            {
                $This.Update(0,"Getting [~] Windows Optional Features")
                [WindowsOptionalFeatureController]::New()
            }
            AppX
            {
                $This.Update(0,"Getting [~] AppX")
                [AppXController]::New()
            }
            Application
            {
                $This.Update(0,"Getting [~] Applications")
                [ApplicationController]::New()
            }
            Task
            {
                $This.Update(0,"Getting [~] Scheduled Tasks")
                [ScheduledTaskController]::New()
            }
            Event
            {
                $This.Update(0,"Getting [~] Event Logs")
                [EventLogProviderController]::New()
            }
            Processor
            {
                $This.Update(0,"Getting [~] Processor(s)")
                [ProcessorController]::New()
            }
            Disk
            {
                $This.Update(0,"Getting [~] System Disk(s)")
                [DiskController]::New()
            }
            Network
            {
                $This.Update(0,"Getting [~] Network Adapter(s)")
                [NetworkController]::New("Network")
            }
        }

        Return $Item
    }
    [String] GetSku()
    {
        $Out = ("Undefined,Ultimate {0},Home Basic {0},Home Premium {0},{3} {0},Home Basic N {"+
        "0},Business {0},Standard {2} {0},Datacenter {2} {0},Small Business {2} {0},{3} {2} {0"+
        "},Starter {0},Datacenter {2} Core {0},Standard {2} Core {0},{3} {2} Core {0},{3} {2} "+
        "IA64 {0},Business N {0},Web {2} {0},Cluster {2} {0},Home {2} {0},Storage Express {2} "+
        "{0},Storage Standard {2} {0},Storage Workgroup {2} {0},Storage {3} {2} {0},{2} For Sm"+
        "all Business {0},Small Business {2} Premium {0},TBD,{1} {3},{1} Ultimate,Web {2} Core"+
        ",-,-,-,{2} Foundation,{1} Home {2},-,{1} {2} Standard No Hyper-V Full,{1} {2} Datacen"+
        "ter No Hyper-V Full,{1} {2} {3} No Hyper-V Full,{1} {2} Datacenter No Hyper-V Core,{1"+
        "} {2} Standard No Hyper-V Core,{1} {2} {3} No Hyper-V Core,Microsoft Hyper-V {2},Stor"+
        "age {2} Express Core,Storage {2} Standard Core,{2} Workgroup Core,Storage {2} {3} Cor"+
        "e,Starter N,Professional,Professional N,{1} Small Business {2} 2011 Essentials,-,-,-,"+
        "-,-,-,-,-,-,-,-,-,Small Business {2} Premium Core,{1} {2} Hyper Core V,-,-,-,-,-,-,-,"+
        "-,-,-,-,-,-,-,-,-,-,-,--,-,-,{1} Thin PC,-,{1} Embedded Industry,-,-,-,-,-,-,-,{1} RT"+
        ",-,-,Single Language N,{1} Home,-,{1} Professional with Media Center,{1} Mobile,-,-,-"+
        ",-,-,-,-,-,-,-,-,-,-,{1} Embedded Handheld,-,-,-,-,{1} IoT Core") -f "Edition",("Wind"+
        "ows"),"Server","Enterprise"
            
        Return $Out.Split(",")[$This.OperatingSystem.OS.OperatingSystemSku]
    }
    [String] Env([String]$Name)
    {
        Return [Environment]::$Name
    }
    PopulateSnapshot()
    {
        $This.Update(0,"Populating [~] Snapshot")

        $This.Snapshot.Start        = $This.Start()
        $This.Snapshot.ComputerName = $This.Env("MachineName")
        $This.Snapshot.Name         = $This.Snapshot.ComputerName.ToLower()
        $This.Snapshot.DisplayName  = "{0}-{1}" -f $This.Snapshot.Start, $This.Snapshot.ComputerName
        $This.Snapshot.PartOfDomain = $This.ComputerSystem.Computer.System.PartOfDomain
        $This.Snapshot.NetBIOS      = $This.Env("UserDomainName").ToLower()
        $This.Snapshot.Dns          = [Environment]::GetEnvironmentVariable("UserDNSDomain")
        $This.Snapshot.Hostname     = @($This.Snapshot.Name;"{0}.{1}" -f $This.Snapshot.Name, $This.Snapshot.Dns)[$This.Snapshot.PartOfDomain].ToLower()
        $This.Snapshot.Username     = $This.Env("UserName")
        $This.Snapshot.Principal    = $This.Get("Principal")
        $This.Snapshot.IsAdmin      = $This.Snapshot.CheckAdmin()
        $This.Snapshot.Caption      = $This.OperatingSystem.Caption
        $This.Snapshot.Version      = $This.Module.OS.Tx("Host","Version").ToString()
        $This.Snapshot.ReleaseId    = $This.Edition.Current.Codename
        $This.Snapshot.Build        = $This.Edition.Current.Build
        $This.Snapshot.Description  = $This.Edition.Current.Description
        $This.Snapshot.SKU          = $This.GetSKU()
        $This.Snapshot.Chassis      = $This.ComputerSystem.Chassis
        $This.Snapshot.Guid         = $This.Get("Guid")

        $This.Update(1,"Snapshot [+] $($This.Snapshot.Guid)")
    }
}

$Control = [SnapshotController]::New()
