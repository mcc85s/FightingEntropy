<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:59:06                                                                  //
 \\==================================================================================================// 

    FileName   : Get-UserProfile.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For collecting information and profiles from a given system.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s 
    Primary    : @mcc85s 
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A 
    Version    : 0.0.0 - () - Finalized functional version 1.
    TODO       : 
.Example

# [A. Bertram] : https://www.ipswitch.com/blog/how-to-accurately-enumerate-windows-user-profiles-with-powershell
#>

Function Get-UserProfile
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode=0)

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
            Return $This.Name
        }
    }

    Class ProfileKey
    {
        [String]     $Name
        [String]     $Type
        [String] $Fullname
        [Object] $Property
        ProfileKey([Object]$Item)
        {
            $This.Name     = $Item.Name.Split("\")[-1]
            $This.Fullname = $Item.Name -Replace "HKEY_LOCAL_MACHINE", "HKLM:"
            $This.Refresh()
        }
        [Object] ProfileProperty([UInt32]$Index,[Object]$Property)
        {
            Return [ProfileProperty]::New($Index,$Property)
        }
        [Object[]] Properties()
        {
            Return (Get-ItemProperty $This.Fullname).PSObject.Properties | ? Name -notmatch ^PS
        }
        Clear()
        {
            $This.Property = @( )
        }
        Refresh()
        {
            $This.Clear() 

            ForEach ($Property in $This.Properties())
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
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class Profile
    {
        [UInt32]       $Index
        Hidden [Object]  $Key
        [String]        $Type
        [String]        $Name
        [Object]         $Sid
        [Object]     $Account
        [String]        $Path
        [Object]     $Content
        [String]        $Size
        Profile([UInt32]$Index,[Object]$Item)
        {
            $This.Index       = $Index
            $This.Key         = $This.GetProfileKey($Item)
            $This.Type        = $This.Key.Type
            $This.Name        = $This.GetProfileName()
            $xSid             = $This.GetProperty("Sid")

            If ($xSid)
            {
                $This.Sid     = $This.GetSid($xSid)
                $This.Account = $This.GetAccount()
            }

            $This.Path        = $This.GetProperty("ProfileImagePath")
        }
        [Object] GetProfileKey([Object]$Item)
        {
            Return [ProfileKey]::New($Item)
        }
        [Object] GetProperty([String]$Name)
        {
            $Item = $This.Key.Property | ? Name -eq $Name | % Value
            If ($Item)
            {
                Return $Item
            }
            Else
            {
                Return $Null
            }
        }
        [String] GetProfileName()
        {
            Return $This.GetProperty("ProfileImagePath") | Split-Path -Leaf
        }
        [Object] GetSid([Byte[]]$Sid)
        {
            Return [System.Security.Principal.SecurityIdentifier]::new($Sid,0)
        }
        [Object] GetAccount()
        {
            $Item = Try
            {
                ($This.Sid.Translate([System.Security.Principal.NTAccount])).Value
            }
            Catch
            {
                $Null
            }

            Return $Item
        }
        GetContent()
        {
            If (Get-Item $This.Path)
            {
                $Hash         = @{ }
                $Bytes        = 0

                ForEach ($File in Get-ChildItem $This.Path -Recurse)
                {
                    $Hash.Add($Hash.Count,$File)
                    $Bytes    = $Bytes + $File.Length
                }

                $This.Size    = "{0:n2} GB" -f ($Bytes/1GB)
                $This.Content = $Hash[0..($Hash.Count-1)]
            }
        }
    }

    Class ProfileController
    {
        Hidden [UInt32] $Mode
        [String]        $Root
        [Object]     $Profile
        [Object]        $User
        ProfileController([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Root = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
            $This.Refresh()
        }
        [Object] ProfileItem([UInt32]$Index,[Object]$Item)
        {
            Return [Profile]::New($Index,$Item)
        }
        [Object[]] GetProfile()
        {
            Return Get-ChildItem $This.Root
        }
        Clear()
        {
            $This.Profile = @( )
            $This.User    = @( )
        }
        Refresh()
        {
            $This.Clear()

            # Initial profiles [System/Service/User]
            ForEach ($Profile in $This.GetProfile())
            {
                $This.Add($Profile)
            }

            # Filter out user profiles
            $This.User          = $This.Profile | ? Type -eq User
            $This.Profile       = $This.Profile | ? Type -ne User

            # Rerank/classify profiles
            ForEach ($Object in $This.Profile, $This.User)
            {
                $C              = 0
                ForEach ($Item in $Object)
                {
                    $Item.Index = $C
                    $C          ++
                }
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
        Add([Object]$xProfile)
        {
            $This.Profile += $This.ProfileItem($This.Profile.Count,$xProfile)
        }
    }

    [ProfileController]::New($Mode)
}
