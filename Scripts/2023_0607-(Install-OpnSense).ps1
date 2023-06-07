<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-06-07 13:10:09                                                                  //
 \\==================================================================================================// 

    FileName   : Install-OpnSense.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Download & install OpnSense using Hyper-V
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-05-27
    Modified   : 2023-06-07
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
[Image Acquisition: (OpnSense 23.1) -> Quintessential Quail (DVD)]
  - Source : https://mirrors.nycbug.org/pub/opnsense/releases/23.1/OPNsense-23.1-OpenSSL-dvd-amd64.iso.bz2]
  - Hash   : f25c10113ef1ea13c031fc6102f8e6caf73a7296b12bcc287670026cab29c7c7

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
            ^Byte     {     "{0} B" -f  $This.Bytes      }
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

Class HashItem
{
    [UInt32]           $Index
    [UInt32]            $Type
    [String]           $Label
    [String]            $Name
    Hidden [String] $Fullname
    [UInt32]           $Exist
    [Object]            $Size
    [String]       $Algorithm = "SHA256"
    [String]            $Hash
    HashItem([UInt32]$Index,[String]$Hash,[String]$Source)
    {
        $This.Type      = 0
        $This.Label     = "Repository"
        $This.Hash      = $Hash
        $This.Main($Source)
    }
    HashItem([UInt32]$Index,[String]$Path)
    {
        $This.Type      = 1
        $This.Label     = "Archive/File"
        $This.Main($Path)
    }
    Main([String]$String)
    {
        $This.SetName($String)
        
        Switch ($This.Type) 
        { 
            0 
            { 
                $This.Hash  = $This.Hash.ToUpper()
                $This.Exist = [UInt32]($This.Fullname -match "^https")
                $This.Size  = $This.ByteSize(0)
            } 
            1 
            { 
                $This.Hash = $This.GetFileHash()
                Try
                {
                    $This.Exist = [UInt32][System.IO.File]::Exists($This.Fullname)
                    $This.Size  = $This.ByteSize($This.GetLength())
                }
                Catch
                {
                    $This.Exist = 0
                    $This.Size  = $This.ByteSize(0)
                }
            }
        }
    }
    SetName([String]$Path)
    {
        $This.Fullname  = $Path
        $This.Name      = $This.GetName()
    }
    [Object] GetFileHash()
    {
        Return (Get-FileHash -Path $This.Fullname -Algorithm $This.Algorithm).Hash
    }
    [String] GetName()
    {
        Return Split-Path -Leaf $This.Fullname
    }
    [UInt64] GetLength()
    {
        Return [System.IO.File]::ReadAllBytes($This.Fullname).Count
    }
    [Object] ByteSize([UInt64]$Length)
    {
        Return [ByteSize]::New("File",$Length)
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class OpnSenseImage
{
    [Object] $Output
    [UInt32] $Match
    [UInt32] $Converted
    OpnSenseImage([String]$Hash,[String]$Source,[String]$Target)
    {
        If (![System.IO.Directory]::Exists($Target))
        {
            Throw "Invalid target path"
        }

        $This.Clear()
        $This.Add($This.HashItem($Hash,$Source))

        $TargetPath = "{0}\{1}" -f $Target, $This.Output[0].Name
        $This.Add($This.HashItem($TargetPath))

        $TargetPath = $TargetPath.Replace(".bz2","")
        $This.Add($This.HashItem($TargetPath))
    }
    Clear()
    {
        $This.Output     = @( )
        $This.Match      = 0
        $This.Converted  = 0
    }
    Add([Object]$Item)
    {
        $This.Output    += $Item
    }
    [Object] HashItem([String]$Hash,[String]$Source)
    {
        Return [HashItem]::New($This.Output.Count,$Hash,$Source)
    }
    [Object] HashItem([String]$Path)
    {
        Return [HashItem]::New($This.Output.Count,$Path)
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

$Ctrl = [OpnSenseImage]::New("f25c10113ef1ea13c031fc6102f8e6caf73a7296b12bcc287670026cab29c7c7",
                             "https://mirrors.nycbug.org/pub/opnsense/releases/23.1/OPNsense-23.1-OpenSSL-dvd-amd64.iso.bz2",
                             "C:\Images")
#>

# [Stage everything in New-VmController GUI]
$Ctrl = New-VmController
$Ctrl.StageXaml()
$Ctrl.Invoke()

# [Ascertain the template]
$Vm   = $Ctrl.Node.Create(0)
# $Vm = $Ctrl.Node.Control("C:\FileVm\gateway.fex")

# // [Object instantiation]
$Vm.Update(0,"[Object instantiation]")
$Vm.New()

$Vm.LoadIso()
$Vm.SetIsoBoot()

# [Add second adapter]
$Vm.Update(0,"[Add second adapter]")
If ($Vm.Network.Count -gt 1)
{
    $X = 1
    Do
    {
        $Name = $Vm.Network[$X].Switch
        $Vm.AddVmNetworkAdapter($Name,$Name)
        $X ++
    }
    Until ($X -eq $Vm.Network.Count)
}
$Vm.Connect()

# // [Start Machine, grab keyboard]
$Vm.Update(0,"[Start Machine, grab keyboard]")
$Vm.Start()
$Vm.Control  = $Vm.Wmi("Msvm_ComputerSystem") | ? ElementName -eq $Vm.Name
$Vm.Keyboard = $Vm.Wmi("Msvm_Keyboard")       | ? Path -match $Vm.Control.Name

# // [Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]
$Vm.Update(0,"[Wait for <Press enter to boot from CD/DVD>, then start <64-bit>]")
0..1 | % { 
    
    $Vm.Timer(2)
    $Vm.TypeKey(13)
}

# // [Wait for uptime to be >50s]
$Vm.Update(0,"[Wait for uptime to be >50s]")
$Vm.Uptime(1,50)
$Vm.Idle(5,5)

# // [Manual Adapter Assignment]
$Vm.Update(0,"[Manual Adapter Assignment]")
$Vm.TypeKey(13)

# // [Configure LAGG]
$Vm.Update(0,"[Configure LAGG]")
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Configure VLAN]
$Vm.Update(0,"[Configure VLAN]")
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter WAN Interface Name]
$Vm.Update(0,"[Enter WAN Interface Name]")
$Vm.TypeText("hn0")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter LAN Interface Name]
$Vm.Update(0,"[Enter LAN Interface Name]")
$Vm.TypeText("hn1")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Press ENTER to continue]
$Vm.Update(0,"[Press ENTER to continue]")
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypeKey([UInt32][Char]"Y")
$Vm.TypeKey(13)

# // [Allow system to autoconfigure and get to menu]
$Vm.Update(0,"[Allow system to autoconfigure and get to menu]")
$Vm.Idle(5,5)

# // [Use installer to login and install]
$Vm.Update(0,"[Use installer to login and install]")
$Account = $Vm.Account | ? Username -eq installer
$Vm.TypeText($Account.Username)
$Vm.TypeKey(13)
$Vm.Timer(1)
$Vm.TypePassword($Account)
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [Keymap Selection]
$Vm.Update(0,"[Keymap Selection]")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Choose task, Install (UFS)]
$Vm.Update(0,"[Choose task, Install (UFS)]")
$Vm.TypeKey(13)
$Vm.Idle(5,5)

# // [UFS Configuration]
$Vm.Update(0,"[UFS Configuration]")
$Vm.TypeKey(40)
$Vm.Timer(1)
$Vm.TypeKey(13)

# // [Continue w/ 8GB swap partition]
$Vm.Update(0,"[Continue w/ 8GB swap partition]")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [LAST CHANCE DUDE... Destroy content of DA0?]
$Vm.Update(0,"[LAST CHANCE DUDE... Destroy content of DA0?]")
$Vm.TypeKey(37)
$Vm.Timer(1)
$Vm.TypeKey(13)

# // [Installing]
$Vm.Update(0,"[Installing]")
$Vm.Idle(5,5)
$Vm.Timer(10)

# // [Done installing, set root password...?]
$Vm.Update(0,"[Done installing, set root password...?]")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Set Root Password]
$Vm.Update(0,"[Set Root Password]")
$Account = $Vm.Account | ? Username -eq root
0..1 | % { 
    
    $Vm.TypePassword($Account)
    $Vm.TypeKey(13)
    $Vm.Timer(1)
}
$Vm.Timer(5)
$Vm.Idle(5,5)

# // [Complete Install]
$Vm.Update(0,"[Complete Install]")
$Vm.TypeKey(40)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Uptime(0,5)

# // [Release ISO upon reboot]
$Vm.Update(0,"[Release ISO upon reboot]")
$Vm.UnloadIso()
$Vm.Uptime(1,60)

# // [Login as root]
$Vm.Update(0,"[Login as root]")
$Vm.TypeText($account.Username)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Password]
$Vm.Update(0,"[Password]")
$Vm.TypePassword($Account)
$Vm.Timer(1)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Set interface IP address]
$Vm.TypeKey([UInt32][Char]"2")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Select LAN]
$Vm.TypeKey([UInt32][Char]"1")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Dhcp N]
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter new LAN IPv4 Address]
$Network = $Vm.Network[1]
$Vm.TypeText($Network.IpAddress)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter new LAN IPv4 Prefix]
$Vm.TypeText($Network.Prefix)
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Enter upstream address, <ENTER> for none]
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Config IPv6 LAN via WAN tracking]
$Vm.TypeKey([UInt32][Char]"Y")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Configure DHCP server on LAN?] <Expand later>
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Revert to HTTP from HTTPS?]
$Vm.TypeKey([UInt32][Char]"N")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Generate new SSC?]
$Vm.TypeKey([UInt32][Char]"Y")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // [Restore web GUI access defaults?]
$Vm.TypeKey([UInt32][Char]"Y")
$Vm.TypeKey(13)
$Vm.Timer(1)

# // Wait for configuration...
$Vm.Idle(5,5)
