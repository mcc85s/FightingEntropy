# Work in progress, Shell.Application interface with smartphone
# https://github.com/nosalan/powershell-mtp-file-transfer/blob/master/phone_backup.ps1
# https://github.com/nosalan/powershell-mtp-file-transfer/blob/master/phone_backup_recursive.ps1
# (^ Working on a more efficient way to do this, sorta making a custom PSDrive)

# // ____________________________________________________
# // | Class for managing the CScript Shell.Application |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Class Shell
{
    [Object] $App
    [Object] $Root
    Shell()
    {
        $This.App  = New-Object -ComObject Shell.Application
        $This.Root = $This.App.NameSpace(0x11)
    }
}

# // _______________________________________
# // | Unused right now, placeholder class |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Directory
{
    Hidden [Object]      $Com
    [String]            $Name
    Hidden [String]   $Parent
    Hidden [String] $Fullname
    Hidden [String] $BaseName
    Hidden [Object]    $Items
    Directory([Object]$Com)
    {
        $This.Com = $Com
    }
    [String] ToString()
    {
        Return $This.Fullname
    }
}

# // _______________________________________
# // | Unused right now, placeholder class |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Class File 
{
    Hidden [Object]      $Com
    [String]            $Mode
    [DateTime] $LastWriteTime
    [Uint64]          $Length
    [String]            $Name
    Hidden [String]   $Parent
    Hidden [String] $Fullname
    Hidden [String] $BaseName
    File([Object]$Com)
    {
        $This.Com    = $Com
        $This.Object
    }
}

# // ____________________________________
# // | Filesystem object, IS being used |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ComObject
{
    Hidden [Object]     $Com
    [String]           $Type
    [String]           $Name
    Hidden [Object[]] $Items
    [UInt32]          $Count
    [String]           $Path
    Hidden [String] $DevPath
    ComObject([String]$Path,[Object]$Com)
    {
        $This.Path    = $Path
        $This.Com     = $Com
        $This.Type    = @("File","Directory")[[UInt32]$Com.IsFolder]
        $This.Name    = $Com.Name
        $This.DevPath = $Com.Path
        $This.GetItems()
    }
    [Object] Folder()
    {
        Return $This.Com.GetFolder
    }
    GetItems()
    {
        $This.Items = @($This.Com.GetFolder | % Items)
        $This.Count = $This.Items.Count
    }
}

# // __________________________________________________________________________________
# // | This manages the connection to the device, and establishes a root, not unlike: |
# // | New-PSDrive -Name phone -PSProvider FileSystem -Root \\coolguy5000             |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class DeviceConnection
{
    Hidden [Object] $Device
    [String] $Name
    [Object] $Root
    [Hashtable] $Output
    DeviceConnection()
    {
        $This.Device       = Get-PnpDevice -PresentOnly | ? Class -eq WPD | ? InstanceID -match ^USB
        $This.Name         = $This.Device.FriendlyName
        $System            = [Shell]::New()
        $This.Root         = $System.Root.Items() | ? Name -eq $This.Name
        
        $This.Init()
    }
    [Object] ComObject([String]$Path,[Object]$Object)
    {
        Return [ComObject]::New($Path,$Object)
    }
    Init()
    {
        If ($This.Output.Count -gt 0)
        {
            Throw "Can only be used via initial construction"
        }

        $This.Output       = @{ }
        $Path              = '\\' + $This.Name
        $This.AddKey($Path,$This.Root)
    }
    AddKey([String]$Path,[Object]$Object)
    {
        $This.Output.Add($Path,$This.ComObject($Path,$Object))
    }
    AddKeys([String]$Path,[Object[]]$Object)
    {
        ForEach ($Obj in $Object)
        {
            $This.AddKey($Path,$Obj)
        }
    }
    Add([String]$Path,[Object[]]$Object)
    {
        If ($Object.Count -eq 1)
        {
            $This.AddKey($Path,$Object)
        }
        If ($Object.Count -gt 1)
        {
            $This.AddKeys($Path,$Object)
        }
    }
    [Object[]] Enumerate()
    {
        Return $This.Output.Keys | Sort-Object | % { $This.Output[$_] }
    }
}


$Dev = [DeviceConnection]::New()

# Shows the initial folders, gotta build out recursively without taking hours or tons of resources
$Dev.Enumerate() 
