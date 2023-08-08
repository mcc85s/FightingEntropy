<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-07 20:47:31                                                                  //
 \\==================================================================================================// 

   FileName   : Get-FEDevice.ps1
   Solution   : [FightingEntropy()][2023.8.0]
   Purpose    : Loads the FightingEntropy module
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2023-08-07
   Modified   : 2023-08-07
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : Enumerates the devices on a system

.Example
#>

Function Get-FEDevice
{
    Enum DeviceCategoryType
    {
        AudioEndpoint
        Battery
        Camera
        Computer
        DiskDrive
        Display
        EhStorSilo
        HDC
        HIDClass
        Keyboard
        MEDIA
        Monitor
        Mouse
        Net
        Ports
        Printer
        PrintQueue
        Processor
        SCSIAdapter
        SDHost
        SecurityDevices
        SmartCardFilter
        SmartCardReader
        SoftwareDevice
        System
        USB
        Volume
    }

    Class DeviceCategoryItem
    {
        [UInt32] $Index
        [String] $Name
        DeviceCategoryItem([String]$Name)
        {
            $This.Index = [UInt32][DeviceCategoryType]::$Name
            $This.Name  = [DeviceCategoryType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class DeviceCategoryList
    {
        [Object] $Output
        DeviceCategoryList()
        {
            $This.Refresh()
        }
        [Object] DeviceCategoryItem([String]$Name)
        {
            Return [DeviceCategoryItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([DeviceCategoryType]))
            {
                $This.Output += $This.DeviceCategoryItem($Name)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Device.Category[List]>"
        }
    }

    Class DeviceItem
    {
        [UInt32]           $Index
        [Object]        $Category
        Hidden [Object]   $Device
        [String]            $Name
        [String[]]            $Id
        [String[]]      $Hardware
        DeviceItem([UInt32]$Index,[Object]$Category,[Object]$Device)
        {
            $This.Index    = $Index
            $This.Category = $Category
            $This.Device   = $Device
            $This.Name     = $Device.Name
            $This.Id       = $Device.DeviceId
            $This.Hardware = $Device.HardwareId
        }
        [String] ToString()
        {
            Return "<FEModule.Device[Object]>"
        }
    }

    Class DeviceController
    {
        Hidden [Object] $Category
        [Object]          $Output
        DeviceController()
        {
            $This.Category = $This.DeviceCategoryList()
            $This.Refresh()
        }
        [Object] DeviceCategoryList()
        {
            Return [DeviceCategoryList]::New()
        }
        [Object] DeviceItem([UInt32]$Index,[Object]$Category,[Object]$Device)
        {
            Return [DeviceItem]::New($Index,$Category,$Device)
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object[]] GetObject()
        {
            Return Get-PnpDevice -PresentOnly | ? Class | Sort-Object Class
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Device in $This.GetObject())
            {
                $xCategory = $This.Category.Output | ? Name -eq $Device.Class
                
                $This.Output += $This.DeviceItem($This.Output.Count,$xCategory,$Device)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Device[Controller]>"
        }
    }

    [DeviceController]::New()
}
