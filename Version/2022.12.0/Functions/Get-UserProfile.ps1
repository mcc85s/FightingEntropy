<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-03-27 16:56:36                                                                  //
 \\==================================================================================================// 

    FileName   : Get-UserProfile.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : For collecting information and profiles from a given system.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s 
    Primary    : @mcc85s 
    Created    : 2023-03-26 
    Modified   : 2023-03-27
    Demo       : N/A 
    Version    : 0.0.0 - () - Finalized functional version 1.
    TODO       : 
.Example

# [A. Bertram] : https://www.ipswitch.com/blog/how-to-accurately-enumerate-windows-user-profiles-with-powershell
#>

Function Get-UserProfile
{
    Class SystemProfile
    {
        [String]             $Name
        [UInt32]            $Flags
        [String] $ProfileImagePath
        [UInt32]         $RefCount
        [Byte[]]              $Sid
        [UInt32]            $State
        SystemProfile([Object]$Object)
        {
            $This.Flags            = $Object.GetProperty("Flags")
            $This.ProfileImagePath = $Object.GetProperty("ProfileImagePath")
            $This.RefCount         = $Object.GetProperty("RefCount")
            $This.Sid              = $Object.GetProperty("Sid")
            $This.State            = $Object.GetProperty("State")

            $This.Name             = Split-Path $This.ProfileImagePath -Leaf
        }
    }

    Class ServiceProfile
    {
        [String]             $Name
        [UInt32]            $Flags
        [String] $ProfileImagePath
        [UInt32]            $State
        ServiceProfile([Object]$Object)
        {
            $This.Flags            = $Object.GetProperty("Flags")
            $This.ProfileImagePath = $Object.GetProperty("ProfileImagePath")
            $This.State            = $Object.GetProperty("State")

            $This.Name             = Split-Path $This.ProfileImagePath -Leaf
        }
    }

    Enum UserProfileExtensionType
    {
        LocalProfileLoadTimeLow
        LocalProfileLoadTimeHigh
        ProfileAttemptedProfileDownloadTimeLow
        ProfileAttemptedProfileDownloadTimeHigh
        ProfileLoadTimeLow
        ProfileLoadTimeHigh
        NextLogonCacheable
        RunLogonScriptSync
        LocalProfileUnloadTimeLow
        LocalProfileUnloadTimeHigh
    }

    Class UserProfileExtensionItem
    {
        [String] $Name
        [Object] $Value
        UserProfileExtensionItem([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class UserProfile
    {
        [String]             $Name
        [String] $ProfileImagePath
        [UInt32]            $Flags
        [UInt32]      $FullProfile
        [UInt32]            $State
        [Byte[]]              $Sid
        [String]             $Guid
        [Object]        $Extension
        UserProfile([Object]$Object)
        {
            $This.ProfileImagePath = $Object.GetProperty("ProfileImagePath")
            $This.Flags            = $Object.GetProperty("Flags")
            $This.FullProfile      = $Object.GetProperty("FullProfile")
            $This.State            = $Object.GetProperty("State")
            $This.Sid              = $Object.GetProperty("Sid")

            # Check Guid
            If ("Guid" -in $Object.Property.Name)
            {
                $This.Guid         = $Object.GetProperty("Guid")
            }

            # Check Extended Variables
            $This.GetExtension($Object)

            $This.Name             = Split-Path $This.ProfileImagePath -Leaf
        }
        [Object] UserProfileExtensionItem([String]$Name,[Object]$Value)
        {
            Return [UserProfileExtensionItem]::New($Name,$Value)
        }
        GetExtension([Object]$Object)
        {
            $This.Extension = @( )

            ForEach ($Item in [System.Enum]::GetNames([UserProfileExtensionType]))
            {
                $This.Extension += $this.UserProfileExtensionItem($Item,$Object.GetProperty($Item))
            }
        }
    }

    Class UserProfileProperty
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Property
        UserProfileProperty([UInt32]$Index,[String]$Name,[Object]$Property)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Property = $Property
        }
    }

    Class UserProfileObject
    {
        Hidden [Object] $Profile
        [UInt32]          $Index
        [String]           $Name
        [String]       $Fullname
        [Object]       $Property
        UserProfileObject([UInt32]$Index,[Object]$xProfile)
        {
            $This.Profile  = $xProfile
            $This.Index    = $Index
            $This.Name     = $xProfile.PSChildName
            $This.Fullname = $xProfile.Name -Replace "HKEY_LOCAL_MACHINE", "HKLM:"
            $This.Refresh()
        }
        Clear()
        {
            $This.Property = @() 
        }
        [Object] UserProfileProperty([UInt32]$Index,[String]$Name,[Object]$Property)
        {
            Return [UserProfileProperty]::New($Index,$Name,$Property)
        }
        [Object[]] GetPropertyList()
        {
            Return (Get-ItemProperty $This.Fullname).PSObject.Properties | ? Name -notmatch ^PS
        }
        [Object] GetProperty([String]$Name)
        {
            $Item = $This.Property | ? Name -eq $Name | % Property

            If ($Item)
            {
                Return $Item
            }
            Else
            {
                Return $Null
            }
        }
        Add([String]$Name,[Object]$Property)
        {
            $This.Property += $This.UserProfileProperty($This.Property.Count,$Name,$Property)
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Property in $This.GetPropertyList())
            {
                $This.Add($Property.Name,$Property.Value)
            }
        }
    }

    Class UserProfileFile
    {
        [UInt32] $Index
        [String] $Name
        [String] $Fullname
        [UInt64] $Length
        UserProfileFile([UInt32]$Index,[Object]$File)
        {
            $This.Index    = $Index
            $This.Name     = $File.Name
            $This.Fullname = $File.Fullname
            $This.Length   = $File.Length
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class UserProfileOutput
    {
        [String]    $Name
        [String]    $Path
        [Object]     $Sid
        [Object]    $Guid
        [Object] $Content
        [String]    $Size
        UserProfileOutput([Object]$Object)
        {
            $This.Name    = $Object.Name
            $This.Path    = $Object.ProfileImagePath
            $This.Sid     = $This.GetSid($Object.Sid)
            $This.Guid    = $Object.Guid
            $This.Content = $This.GetContent()
            $This.GetSize()
        }
        [Object] GetSid([Byte[]]$Sid)
        {
            Return [System.Security.Principal.SecurityIdentifier]::new($Sid,0)
        }
        [Object] UserProfileFile([UInt32]$Index,[Object]$File)
        {
            Return [UserProfileFile]::New($Index,$File)
        }
        [Object[]] GetContent()
        {
            Return Get-ChildItem $This.Path -Recurse
        }
        GetSize()
        {
            $Bytes = 0

            ForEach ($File in $This.Content)
            {
                $Bytes = $Bytes + $File.Length
            }

            $This.Size = "{0:n2} GB" -f ($Bytes/1GB)
        }
    }

    Class UserProfileController
    {
        [String]    $Name
        [String]    $Path
        [Object] $Profile
        [Object]  $System
        [Object] $Service
        [Object]    $User
        UserProfileController()
        {
            $This.Name   = "UserProfileController"
            $This.Path   = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
            $This.Refresh()
        }
        [Object] UserProfileObject([UInt32]$Index,[Object]$Object)
        {
            Return [UserProfileObject]::New($Index,$Object)
        }
        [Object[]] GetProfile()
        {
            Return Get-ChildItem $This.Path   
        }
        [Object] ServiceProfile([Object]$Object)
        {
            Return [ServiceProfile]::New($Object)
        }
        [Object] SystemProfile([Object]$Object)
        {
            Return [SystemProfile]::New($Object)
        }
        [Object] UserProfile([Object]$Object)
        {
            Return [UserProfile]::New($Object)
        }
        [Object] UserProfileOutput([Object]$Object)
        {
            Return [UserProfileOutput]::New($Object)
        }
        Clear()
        {
            $This.Profile = @( )
            $This.System  = @( )
            $This.Service = @( )
            $This.User    = @( )
        }
        Add([UInt32]$Slot,[Object]$Object)
        {
            Switch ($Slot)
            {
                0 { $This.Profile += $This.UserProfileObject($This.Profile.Count,$Object) }
                1 { $This.Service += $This.ServiceProfile($Object)                        }
                2 { $This.System  += $This.SystemProfile($Object)                         }
                3 { $This.User    += $This.UserProfile($Object)                           }
            }
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Object in $This.GetProfile())
            {
                $This.Add(0,$Object)
            }

            ForEach ($Object in $This.Profile)
            {
                $Token = Switch ($Object.Property.Count)
                {
                    3 { 1 } 5 { 2 } Default { 3 }
                }

                $This.Add($Token,$Object)
            }
        }
        [Object] Prepare([UInt32]$Index)
        {
            If ($Index -gt $This.User.Count)
            {
                Throw "Invalid user index"
            }

            Return $This.UserProfileOutput($This.User[$Index])
        }
    }

    [UserProfileController]::New()
}
