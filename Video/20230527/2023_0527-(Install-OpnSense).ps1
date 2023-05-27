<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-05-27 12:26:02                                                                  //
 \\==================================================================================================// 

    FileName   : Install-OpnSense.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Download & install OpnSense using Hyper-V
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-05-27
    Modified   : 2023-05-27
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
[Image Acquisition: (OpnSense 23.1) -> Quintessential Quail (DVD)]
  - Source : https://mirrors.nycbug.org/pub/opnsense/releases/23.1/OPNsense-23.1-OpenSSL-dvd-amd64.iso.bz2]
  - Hash   : f25c10113ef1ea13c031fc6102f8e6caf73a7296b12bcc287670026cab29c7c7

Class HashItem
{
    [String] $Algorithm = "SHA256"
    [String] $Hash
    [String] $Path
    HashItem([String]$Hash,[String]$Source)
    {
        $This.Hash      = $Hash.ToUpper()
        $This.Path      = $Source
    }
    HashItem([String]$Path)
    {
        $This.Hash      = (Get-FileHash -Path $Path -Algorithm $This.Algorithm).Hash
        $This.Path      = $Path
    }
    [String] ToString()
    {
        Return "<Hash[Item]: $(Split-Path -Leaf $This.Path)>"
    }
}

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

Class OpnSenseImage
{
    [Object] $Repository
    [Object] $Archive
    [Object] $File
    [String] $Name
    [String] $Fullname
    [UInt32] $Match
    [Object] $Size
    [UInt32] $Converted
    OpnSenseImage([String]$Hash,[String]$Source,[String]$Target)
    {
        If (![System.IO.Directory]::Exists($Target))
        {
            Throw "Invalid target path"
        }

        $This.Repository = $This.HashItem($Hash,$Source)
        $This.Name       = $This.GetName($This.Repository.Path)

        # String interpolation
        $This.Fullname   = "{0}\{1}" -f $Target, $This.Name

        $Ctrl.StartBitsTransfer()
        $Ctrl.Validate()
        $Ctrl.Convert()
    }
    [Object] HashItem([String]$Hash,[String]$Source)
    {
        Return [HashItem]::New($Hash,$Source)
    }
    [Object] HashItem([String]$Path)
    {
        Return [HashItem]::New($Path)
    }
    [String] GetName([String]$Entry)
    {
        Return Split-Path -Leaf $Entry
    }
    StartBitsTransfer()
    {
        $Splat          = @{ 

            Source      = $This.Repository.Path
            Destination = $This.Fullname
            DisplayName = $This.Name
        }

        Start-BitsTransfer @Splat
    }
    Validate()
    {
        If (![System.IO.File]::Exists($This.Fullname))
        {
            Throw "File does not exist"
        }
        
        # Status to console
        [Console]::WriteLine("Validating [~] $($This.Fullname)")

        # Runs the command (Get-FileHash)
        $This.Archive = $This.HashItem($This.Fullname)

        # Deletes the file and throws an error if it does not match the hash value
        If ($This.Archive.Hash -ne $This.Repository.Hash)
        {
            [System.IO.File]::Delete($This.Fullname)
            Throw "Hashes do not match"
        }

        # Status to console if passes
        [Console]::WriteLine("Validated [+] $($This.Fullname)")

        # Sets the match property to 1 from 0, and the file length
        $This.Match = 1
        $This.Size  = $This.ByteSize()
    }
    Convert()
    {
        $Splat = @{
            
            FilePath     = "C:\ProgramData\chocolatey\lib\bzip2\tools\bzip2.exe"
            ArgumentList = "-d $($This.Archive.Path)"
        }

        $Start = [DateTime]::Now
        [Console]::WriteLine("Starting [~] $($Start)")
        Start-Process @Splat -NoNewWindow

        Do
        {
            [Console]::WriteLine([TimeSpan]([DateTime]::Now-$Start))
            Start-Sleep 5
        }
        Until (![System.IO.File]::Exists($This.Archive.Path))

        $Target             = $This.Archive.Path.Replace(".bz2","")
        [Console]::WriteLine("Complete [+] $Target")
        If ([System.IO.File]::Exists($Target))
        {
            $This.Converted = 1
            $This.Fullname  = $This.Archive.Path.Replace(".bz2","")
            $This.Name      = $This.GetName($This.Fullname)
            $This.Size      = $This.ByteSize()
            $This.File      = $This.HashItem($This.Fullname)
        }
        Else
        {
            Throw "An error occurred"
        }
    }
    [Object] ByteSize()
    {
        Return [ByteSize]::New("Image",[System.IO.File]::ReadAllBytes($This.Fullname).Count)
    }
}

# I could expand upon this and make it possible to handle other image types.

[OpnSenseImage]::New($Hash,$Source,$Target)

Right now it's scanning all of the potential hosts for that network.
Pretty sure that it's 
#>

$Ctrl = New-VmController

# [GUI portion]
$Ctrl.StageXaml()
$Ctrl.Invoke()

$Vm   = $Ctrl.Node.Control("C:\FileVm\gateway.fex")

$Vm.Update(0,"[Deserialize the accounts]")
$Vm.Account = $Vm.Account | % { $Ctrl.Credential.VmCredentialItem($_) }

# // [Object instantiation]
$Vm.Update(0,"[Object instantiation]")
$Vm.New()

$Vm.LoadIso()
$Vm.SetIsoBoot()

# [Add second adapter]
$Vm.AddVmNetworkAdapter("Internal","Internal")
$Vm.Connect()

# // [Start Machine, grab keyboard]
$Vm.Update(0,"[Start Machine]")
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name

# // [Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]
$Vm.Update(0,"[Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]")
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // [Wait for uptime to be more than 60 seconds => this will vary]
$Vm.Uptime(1,50)
$Vm.Idle(5,5)

# // [Manual Adapter Assignment]
$Vm.TypeKey(13)

# // [Configure LAGG]
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Configure VLAN]
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter WAN Interface Name]
$Vm.TypeText("hn0")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter LAN Interface Name]
$Vm.TypeText("hn1")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Press ENTER to continue]
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey([UInt32][Char]"Y")
$Vm.TypeKey(13)

# // [Allow system to autoconfigure and get to menu]
$Vm.Idle(5,5)

# // [Use installer to login and install]
$Account = $Vm.Account | ? Type -eq Setup | ? Username -eq installer
$Vm.TypeText($Account.Username)
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypePassword($Account)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Keymap Selection]
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Choose task, Install (UFS)]
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [UFS Configuration]
$Vm.TypeKey(40)
$Vm.Timer(1)
$Vm.TypeKey(13)

# // [Continue w/ 8GB swap partition]
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [LAST CHANCE DUDE... Destroy content of DA0?]
$Vm.TypeKey(37)
$Vm.Timer(1)
$Vm.TypeKey(13)

# // [Installing]
$Vm.Idle(5,5)
$Vm.Timer(10)

# // [Root Password]
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Set Root Password]
$Account = $Vm.Account | ? Username -eq root
0..1 | % { 
    
    $Vm.TypePassword($Account)
    $Vm.TypeKey(13)
    $Vm.Timer(1)
}
$Vm.Idle(5,5)

# // [Complete Install]
$Vm.TypeKey(40)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Uptime(0,5)

# // [Release ISO upon reboot]
$Vm.UnloadIso()
$Vm.Uptime(1,60)

# // [Develop networking stuff that handles multiple adapters and networks]

Class VmMultiNetworkNode
{
    [String]          $Type
    [String]    $SwitchName
    [String]         $Alias
    Hidden [Object] $Switch
    Hidden [Object] $Config
    [String]        $Domain
    [String]       $NetBios
    [String]     $IpAddress
    [String]       $Network
    [String]     $Broadcast
    [String]       $Trusted
    [String]        $Prefix
    [String]       $Netmask
    [String]       $Gateway
    [String[]]         $Dns
    [Object]          $Dhcp
    [String]      $Transmit
    VmMultiNetworkNode([String]$Type,[String]$SwitchName)
    {
        $This.Type       = $Type
        $This.SwitchName = $SwitchName
        $This.Switch     = Get-VmSwitch | ? Name -eq $SwitchName
        $This.SetConfig()
    }
    VmMultiNetworkNode([Object]$Switch)
    {
        $This.Type       = $Switch.SwitchType
        $This.SwitchName = $Switch.Name
        $This.Switch     = $Switch
        $This.SetConfig()
    }
    SetConfig()
    {
        $This.Alias      = "vEthernet ({0})" -f $This.SwitchName
        $This.Config     = Get-NetIPConfiguration -Detailed | ? InterfaceAlias -eq $This.Alias
    }
    SetDomain([String]$Domain,[String]$NetBios)
    {
        $This.Domain    = $Domain
        $This.NetBios   = $NetBios
    }
    SetIpAddress(
    [String] $IpAddress,
    [String]   $Network,
    [String] $Broadcast,
    [String]   $Trusted,
    [UInt32]    $Prefix,
    [String]   $Netmask,
    [String]   $Gateway,
    [String[]]     $Dns)
    {
        $This.IpAddress = $IpAddress
        $This.Network   = $Network
        $This.Broadcast = $Broadcast
        $This.Trusted   = $Trusted
        $This.Prefix    = $Prefix
        $This.Netmask   = $Netmask
        $This.Gateway   = $Gateway
        $This.Dns       = $Dns
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmMultiNetwork[Node]>"
    }
}

$Network = [VmMultiNetworkNode]::New($VmSwitch)
$Network.SetDomain("securedigitsplus.com","SECURED")
$Network.SetIpAddress("172.16.0.3","172.16.0.0","172.16.255.255","172.16.0.1",16,"255.255.0.0","172.16.0.1","172.16.0.1")

# [Continue script building process]

# // [Login as root]
$Vm.TypeText($account.Username)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Password]
$Vm.TypePassword($Account)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(1)

# That's gonna do it for today...
