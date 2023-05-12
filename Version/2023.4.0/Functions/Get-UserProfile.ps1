<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-05-12 01:13:29                                                                  //
 \\==================================================================================================// 

    FileName   : Get-UserProfile.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For collecting information and profiles from a given system.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s 
    Primary    : @mcc85s 
    Created    : 2023-04-05
    Modified   : 2023-05-12
    Demo       : N/A 
    Version    : 0.0.0 - () - Finalized functional version 1.
    TODO       : 
.Example

# [A. Bertram] : https://www.ipswitch.com/blog/how-to-accurately-enumerate-windows-user-profiles-with-powershell
#>

Function Get-UserProfile
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode=0)

    Class ProfileByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        ProfileByteSize([String]$Name,[UInt64]$Bytes)
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

    Class ProfileFile
    {
        Hidden [UInt32]    $Index
        [String]            $Type
        Hidden [String]  $Created
        [String]        $Accessed
        Hidden [String] $Modified
        [Object]            $Size
        [String]            $Name
        Hidden [String] $Fullname
        ProfileFile([UInt32]$Index,[Object]$Object)
        {
            $This.Index    = $Index
            $This.Type     = $This.GetType($Object.Mode)
            $This.Created  = $This.GetDate($Object.CreationTime)
            $This.Accessed = $This.GetDate($Object.LastAccessTime)
            $This.Modified = $This.GetDate($Object.LastWriteTime)
            $This.Name     = $Object.Name
            $This.Fullname = $Object.Fullname
            $This.Size     = $This.ProfileByteSize($Object.Length)
        }
        [String] GetDate([DateTime]$Date)
        {
            Return $Date.ToString("MM/dd/yyyy HH:mm:ss")
        }
        [String] GetType([String]$Mode)
        {
            <#
                d----- Directory
                d-r--- Directory
                dar--l Directory
                d----l Directory
                -a---- File
                -a---- File
                -a---l File
                -a---l File
                -ar--l File
                -a---l File
            #>

            $Item = Switch -Regex ($Mode)
            {
                "^d" { "Directory" } "^-a" { "File" }
            }

            Return $Item
        }
        [Object] ProfileByteSize([UInt64]$Bytes)
        {
            If ($This.Type -eq "Directory")
            {
                $Bytes = 0
            }

            Return [ProfileByteSize]::New($This.Type,$Bytes)
        }
    }

    Class ProfileProperty
    {
        [UInt32]       $Index
        Hidden [String] $Type
        [String]        $Name
        [Object]       $Value
        ProfileProperty([UInt32]$Index,[Object]$Property)
        {
            $This.Index = $Index
            $This.Type  = $Property.TypeNameOfValue
            $This.Name  = $Property.Name
            $This.Value = $Property.Value
        }
        [String] ToString()
        {
            Return "<FEModule.Profile[Property]>"
        }
    }

    Class ProfileSid
    {
        Hidden [Object]  $Wmi
        Hidden [String] $Path
        [String]        $Type
        [String]        $Name
        [String]    $Fullname
        [String]     $Account
        [String]      $Domain
        [Byte[]]      $Binary
        [UInt32]      $Length
        [Object]         $Sid
        [Object]    $Property
        ProfileSid([String]$Path)
        {
            $This.Path     = $Path
            $This.Name     = Split-Path -Leaf $Path
            $This.Fullname = $Path -Replace "HKEY_LOCAL_MACHINE", "HKLM:"
            $This.Wmi      = $This.GetWmi()
            $This.Name     = $This.Wmi.Sid
            $This.Account  = $This.Wmi.AccountName
            $This.Domain   = $This.Wmi.ReferencedDomainName
            $This.Binary   = $This.Wmi.BinaryRepresentation
            $This.Length   = $This.Binary.Length
            $This.Sid      = $This.GetSid($This.Binary)

            $This.Refresh()

            If (!$This.Account)
            {
                $This.Account = $This.GetAccount()
            }

            If (!$This.Domain)
            {
                $This.Domain  = $This.GetHostname()
            }
        }
        Clear()
        {
            $This.Property = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Property in $This.GetProperty())
            {
                $This.Add($Property)
            }

            $This.Type = Switch ($This.Property.Count)
            {
                3 { "Service" } 5 { "System" } Default { "User" }
            }
        }
        Add([Object]$Property)
        {
            $This.Property += $This.ProfileProperty($This.Property.Count,$Property)
        }
        [String] GetWmiPath()
        {
            Return "Root\CimV2:Win32_Sid.Sid='{0}'" -f $This.Name
        }
        [Object] GetWmi()
        {
            Return [WMI]$This.GetWmiPath()
        }
        [Object] GetSid([Byte[]]$Byte)
        {
            Return [System.Security.Principal.SecurityIdentifier]::new($Byte,0)
        }
        [String] GetHostname()
        {
            Return [Environment]::MachineName
        }
        [Object] GetProperty([String]$Property)
        {
            Return $This.Property | ? Name -eq ProfileImagePath | % Value
        }
        [Object[]] GetProperty()
        {
            Return (Get-ItemProperty $This.Fullname).PSObject.Properties | ? Name -notmatch ^PS
        }
        [Object] GetAccount()
        {
            $Item = Try
            {
                $This.Sid.Sid.Translate([System.Security.Principal.NTAccount]) | % Value
            }
            Catch
            {
                Split-Path -Leaf $This.GetProperty("ProfileImagePath")
            }

            Return $Item
        }
        [Object] ProfileProperty([UInt32]$Index,[Object]$Property)
        {
            Return [ProfileProperty]::New($Index,$Property)
        }
        [String] ToString()
        {
            Return "<FEModule.Profile[Sid]>"
        }
    }

    Class ProfileItem
    {
        [UInt32]   $Index
        [Object]     $Sid
        [String]    $Type
        [String]    $Name
        [Object] $Account
        [String]    $Path
        [Object] $Content
        [Object]    $Size
        ProfileItem([Object]$Path)
        {
            $This.Sid         = $This.ProfileSid($Path)
            $This.Type        = $This.Sid.Type
            $This.Name        = $This.Sid.Account
            $This.Account     = "{0}\{1}" -f $This.Sid.Domain, $This.Name
            $This.Path        = $This.Sid.GetProperty("ProfileImagePath")
        }
        [Object] ProfileSid([String]$Path)
        {
            Return [ProfileSid]::New($Path)
        }
        [Object] ProfileFile([UInt32]$Index,[Object]$Object)
        {
            Return [ProfileFile]::New($Index,$Object)
        }
        [Object] ProfileByteSize([UInt64]$Bytes)
        {
            Return [ProfileByteSize]::New("Profile",$Bytes)
        }
        GetContent()
        {
            If ($This.Type -ne "User")
            {
                Throw "Invalid profile type"
            }
            
            $Root = Get-Item $This.Path
            If ($Root)
            {
                $Hash  = @{ }
                $Bytes = 0
                $List  = Get-ChildItem $This.Path -Recurse | Sort-Object FullName
                $Line  = "User: [{0}], Path: [{1}], ({2}) files" -f $This.Name, $This.Path, $List.Count
                [Console]::WriteLine($Line)

                ForEach ($File in $List)
                {
                    $Item  = $This.ProfileFile($Hash.Count,$File)
                    $Hash.Add($Hash.Count,$Item)
                    $Bytes = $Bytes + $Item.Size.Bytes
                }

                $This.Size    = $This.ProfileByteSize($Bytes)
                $This.Content = $Hash[0..($Hash.Count-1)]

                [Console]::WriteLine($This.Size)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Profile[Item]>"
        }
    }

    Class ProfileList
    {
        [String] $Name
        [UInt32] $Count
        [Object] $Output
        ProfileList([String]$Name)
        {
            $This.Name = $Name
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "<FEModule.Profile[List]>"
        }
    }

    Class ProfileController
    {
        Hidden [UInt32] $Mode
        Hidden [String] $Root
        [Object]      $System
        [Object]     $Service
        [Object]        $User
        ProfileController([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Root = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
            $This.Refresh()
        }
        [Object] ProfileItem([Object]$Item)
        {
            Return [ProfileItem]::New($Item)
        }
        [Object] ProfileList([String]$Type)
        {
            Return [ProfileList]::New($Type)
        }
        [Object[]] GetProfile()
        {
            Return Get-ChildItem $This.Root
        }
        Clear()
        {
            $This.System  = $This.ProfileList("System")
            $This.Service = $This.ProfileList("Service")
            $This.User    = $This.ProfileList("User")
        }
        Refresh()
        {
            $This.Clear()

            # Get profiles for [System/Service/User]    
            ForEach ($Profile in $This.GetProfile())
            {
                $Item = $This.ProfileItem($Profile)
                $List = Switch ($Item.Type)
                {
                    System  { $This.System  }
                    Service { $This.Service }
                    User    { $This.User    }
                }

                $Item.Index = $List.Count
                $List.Add($Item)
            }

            If ($This.Mode -ne 0)
            {
                # Get Content of user profiles
                ForEach ($Item in $This.User)
                {
                    [Console]::WriteLine("Collecting [~] [User: $($Item.Name)]")
                    $Item.GetContent()
                }
            }
        }
        [Object] List([String]$Type)
        {
            Return $This.$Type.Output
        }
        [String] ToString()
        {
            Return "<FEModule.Profile[Controller]>"
        }
    }
    
    [ProfileController]::New($Mode)
}
