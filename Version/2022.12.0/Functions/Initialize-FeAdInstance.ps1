<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-01-23 22:07:07                                                                  //
 \\==================================================================================================// 

    FileName   : Initialize-FeAdInstance.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : Populate Active Directory with authorized nodes, users, and computers
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-01-23
    Modified   : 2023-01-23
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Finish and test

.Example
#>

Function Initialize-FeAdInstance
{
    # // ==================================================================
    # // | Selected object types from Active Directory object list [Enum] |
    # // ==================================================================

    Enum FeAdObjectSlotType
    {
        OrganizationalUnit
        Group
        User
    }

    # // ==================================================================
    # // | Selected object types from Active Directory object list [Item] |
    # // ==================================================================

    Class FeAdObjectSlotItem
    {
        [Uint32] $Index
        [String] $Type
        [String] $Description
        FeAdObjectSlotItem([String]$Type)
        {
            $This.Index = [UInt32][FeAdObjectSlotType]::$Type
            $This.Type  = $Type
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdObjectSlotItem>"
        }
    }

    # // ==================================================================
    # // | Selected object types from Active Directory object list [List] |
    # // ==================================================================

    Class FeAdObjectSlotList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        FeAdObjectSlotList()
        {
            $This.Name = "FeAdObjectSlotList"
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        [Object] FeAdObjectSlotItem([String]$Type)
        {
            Return [FeAdObjectSlotItem]::New($Type)
        }
        Add([String]$Type)
        {
            $Item             = $This.FeAdObjectSlotItem($Type)
            $Item.Description = Switch ($Type)
            {
                OrganizationalUnit { "Base Active Directory container object"         }
                Group              { "Subordinate Active Directory collection object" }
                User               { "Subordinate Active Directory user object"       }
            }

            $This.Output     += $Item
            $This.Count       = $This.Output.Count
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Type in [System.Enum]::GetNames([FeAdObjectSlotType]))
            {
                $This.Add($Type)
            }
        }
        [String] ToString()
        {
            Return "({0}) <FEModule.FeAdObjectSlotList>" -f $This.Count
        }
    }

    # // ==============================================
    # // | Represents an Active Directory node [Item] |
    # // ==============================================

    Class FeAdObjectItem
    {
        Hidden [Object]     $Object
        [String]              $Name
        [String]              $Type
        [String]            $Exists
        [String]              $Guid
        [String] $DistinguishedName
        FeAdObjectItem([Object]$Object)
        {
            $This.Object            = $Object
            $This.Name              = $Object.Name
            $This.Type              = $Object.ObjectClass
            $This.Exists            = !!$Object
            $This.Guid              = $Object.ObjectGuid
            $This.DistinguishedName = $Object.DistinguishedName
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdObjectItem>"
        }
    }

    # // ==============================================
    # // | Represents an Active Directory node [List] |
    # // ==============================================
    
    Class FeAdObjectList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        FeAdObjectList()
        {
            $This.Name   = "FeAdObjectList"
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        Refresh()
        {
            $This.Clear()
            ForEach ($Item in Get-AdObject -Filter *)
            {
                $This.Add($Item)
            } 
        }
        [Object] FeAdObject([Object]$Object)
        {
            Return [FeAdObject]::New($Object)
        }
        Add([Object]$Object)
        {
            $This.Output += $This.FeAdObject($Object)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FEModule.FeAdObjectList>" -f $This.Output.Count
        }
    }
    
    # // ====================================================
    # // | Represents an Active Directory location template |
    # // ====================================================

    Class FeAdLocation
    {
        [String] $DisplayName
        [String] $StreetAddress
        [String] $City
        [String] $State
        [String] $PostalCode
        [String] $Country
        FeAdLocation([String]$Address,[String]$City,[String]$State,[String]$Zip,[String]$Country)
        {
            $This.StreetAddress = $Address
            $This.City          = $City
            $This.State         = $State
            $This.PostalCode    = $Zip
            $This.Country       = $Country

            $This.DisplayName   = $This.ToDisplayName()
        }
        [String] ToDisplayName()
        {
            $Split              = $This.City -Split " " 
            $Item               = Switch ($Split.Count)
            {
                {$_ -eq 0} { $Null }
                {$_ -eq 1} { $This.City.Substring(0,2) }
                {$_ -gt 1} { ($Split | % { $_[0] }) -join '' }
            }

            Return "{0}-{1}-{2}-{3}" -f $Item, $This.State, $This.Country, $This.PostalCode
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdLocation>"
        }
    }
    
    # // ======================================================
    # // | Represents an Active Directory Organizational Unit |
    # // ======================================================
    
    Class FeAdOrganizationalUnit
    {
        Hidden [Object]         $Ou
        Hidden [Object]   $Location
        [String]              $Name
        [String]       $DisplayName
        [String]       $Description
        [String]     $StreetAddress
        [String]              $City
        [String]             $State
        [String]        $PostalCode
        [String]           $Country
        [UInt32]            $Exists
        [String] $DistinguishedName
        FeAdOrganizationalUnit([String]$Name,[String]$Description)
        {
            $This.Name              = $Name
            $This.DisplayName       = $This.ToDisplayName()
            $This.Description       = $Description
            $This.Check()
        }
        FeAdOrganizationalUnit([String]$Name,[String]$Description,[Object]$Location)
        {
            $This.Name              = $Name
            $This.DisplayName       = $This.ToDisplayName()
            $This.Description       = $Description
            $This.Location          = $Location
            $This.StreetAddress     = $Location.StreetAddress
            $This.City              = $Location.City
            $This.State             = $Location.State
            $This.PostalCode        = $Location.PostalCode
            $This.Country           = $Location.Country
            $This.Check()
        }
        Check()
        {
            $This.Get() | Out-Null
        }
        [Object] Get()
        {
            $This.Ou      = Get-AdOrganizationalUnit -Filter * -Properties * -EA 0 | ? Name -eq $This.Name
            $This.Exists  = !!$This.Ou
            $This.DistinguishedName = $This.Ou.DistinguishedName
            Return $This.Ou
        }
        Create()
        {
            $This.Check()
            If ($This.Exists)
            {
                Throw "Exception [!] Organizational unit already exists"
            }

            $Splat              = @{ 

                Name           = $This.Name
                DisplayName    = $This.DisplayName
                Description    = $This.Description
                StreetAddress  = $This.StreetAddress
                City           = $This.City
                State          = $This.State
                PostalCode     = $This.PostalCode
                Country        = $This.Country
            }

            New-AdOrganizationalUnit @Splat -Verbose
            $This.Check()
        }
        Remove()
        {
            $This.Check()
            If (!$This.Exists)
            {
                Throw "Exception [!] Organizational unit does not exist"
            }

            Set-ADObject    -Identity $This.DistinguishedName -ProtectedFromAccidentalDeletion 0 -EA 0
            Remove-ADObject -Identity $This.DistinguishedName -Confirm:0 -Recursive -Verbose     -EA 0
            $This.Check()
        }
        [String] ToDisplayName()
        {
            Return "[FightingEntropy({0})] <{1}>" -f [Char]960, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdOrganizationalUnit>"
        }
    }
    
    # // ========================================
    # // | Represents an Active Directory group |
    # // ========================================
    
    Class FeAdGroup
    {
        Hidden [Object]      $Group
        [String]              $Name
        [String]       $DisplayName
        [String]        $GroupScope
        [String]     $GroupCategory
        [String]       $Description
        [String]              $Path
        [UInt32]            $Exists
        [String] $DistinguishedName
        FeAdGroup([String]$Name,[String]$Category,[String]$Scope,[String]$Description,[String]$Path)
        {
            $This.Name          = $Name
            $This.GroupCategory = $Category
            $This.GroupScope    = $Scope
            $This.Description   = $Description
            $This.Path          = $Path

            $This.DisplayName   = $This.ToDisplayName()

            $This.Check()
        }
        Check()
        {
            $This.Get() | Out-Null
        }
        [Object] Get()
        {
            $This.Group   = Get-AdGroup -Filter * -Properties * -EA 0 | ? Name -eq $This.Name
            $This.Exists  = !!$This.Group
            $This.DistinguishedName = $This.Group.DistinguishedName
            Return $This.Group
        }
        Create()
        {
            $This.Check()
            If ($This.Exists)
            {
                Throw "Exception [!] Group already exists"
            }

            $Splat              = @{ 

                Name           = $This.Name
                DisplayName    = $This.DisplayName
                Description    = $This.Description
                GroupScope     = $This.GroupScope
                GroupCategory  = $This.GroupCategory
                Path           = $This.Path
            }

            New-AdGroup @Splat -Verbose
            $This.Check()
        }
        Remove()
        {
            $This.Check()
            If (!$This.Exists)
            {
                Throw "Exception [!] Group does not exist"
            }

            Set-ADObject    -Identity $This.DistinguishedName -ProtectedFromAccidentalDeletion 0 -EA 0
            Remove-ADObject -Identity $This.DistinguishedName -Confirm:0 -Verbose     -EA 0
            $This.Check()
        }
        [String] ToDisplayName()
        {
            Return "[FightingEntropy({0})] <{1}>" -f [Char]960, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdGroup>"
        }
    }

    # // =======================================
    # // | Represents an Active Directory user |
    # // =======================================

    Class FeAdUser
    {
        Hidden [Object]           $User
        [String]                  $Name
        [String]           $DisplayName
        [String]             $GivenName
        [String]              $Initials
        [String]               $Surname
        [String]           $Description
        [String]                $Office
        [String]          $EmailAddress
        [String]              $HomePage
        [String]         $StreetAddress
        [String]                  $City
        [String]                 $State
        [String]            $PostalCode
        [String]               $Country
        [String]        $SamAccountName
        [String]     $UserPrincipalName
        [String]           $ProfilePath
        [String]            $ScriptPath
        [String]         $HomeDirectory
        [String]             $HomeDrive
        [String]             $HomePhone
        [String]           $OfficePhone
        [String]           $MobilePhone
        [String]                   $Fax
        [String]                 $Title
        [String]            $Department
        [String]               $Company
        [SecureString] $AccountPassword
        [String]                  $Path
        [UInt32]                $Exists
        [String]     $DistinguishedName
        FeAdUser([String]$Given,[String]$Initials,[String]$Surname,[String]$Sam)
        {
            $This.GivenName              = $Given
            $This.Initials               = $Initials
            $This.Surname                = $Surname
            $This.DisplayName            = Switch ([UInt32]!$Initials)
            {
                0 { "{0} {1}. {2}" -f $Given, $Initials, $Surname } 1 { "{0} {1}" -f $Given, $Surname }
            }

            $This.Name                   = $This.DisplayName
            $This.SamAccountName         = $Sam
            $This.UserPrincipalName      = "{0}@{1}" -f $Sam, $This.Domain()

            $This.Check()
        }
        Check()
        {
            $This.Get() | Out-Null
        }
        [Object] Get()
        {
            $This.User    = Get-AdUser -Filter * -Properties * -EA 0 | ? Name -eq $This.Name
            $This.Exists  = !!$This.User
            $This.DistinguishedName = $This.User.DistinguishedName
            Return $This.User
        }
        Create()
        {
            $This.Check()
            If ($This.Exists)
            {
                Throw "Exception [!] Group already exists"
            }


            $Splat                = @{

                AccountPassword   = $This.AccountPassword
                Name              = $This.Name
                Path              = $This.Path
                Enable            = @(0,1)[!!$This.AccountPassword]
                GivenName         = $This.GivenName
                Initials          = $This.Initials
                Surname           = $This.Surname
                DisplayName       = $This.DisplayName
                Description       = $This.Description
                Office            = $This.Office
                EmailAddress      = $This.EmailAddress
                HomePage          = $This.HomePage
                StreetAddress     = $This.StreetAddress
                City              = $This.City
                State             = $This.State
                PostalCode        = $This.PostalCode
                Country           = $This.Country
                SamAccountName    = $This.SamAccountName
                UserPrincipalName = $This.UserPrincipalName
                ProfilePath       = $This.ProfilePath
                ScriptPath        = $This.ScriptPath
                HomeDirectory     = $This.HomeDirectory
                HomeDrive         = $This.HomeDrive
                HomePhone         = $This.HomePhone
                OfficePhone       = $This.OfficePhone
                MobilePhone       = $This.MobilePhone
                Fax               = $This.Fax
                Title             = $This.Title
                Department        = $This.Department
                Company           = $This.Company
            }

            New-AdUser @Splat -Verbose
            $This.Check()
        }
        Remove()
        {
            $This.Check()
            If (!$This.Exists)
            {
                Throw "Exception [!] Group does not exist"
            }

            Set-ADObject    -Identity $This.DistinguishedName -ProtectedFromAccidentalDeletion 0 -EA 0
            Remove-ADObject -Identity $This.DistinguishedName -Confirm:0 -Verbose     -EA 0
            $This.Check()
        }
        [String] ToDisplayName()
        {
            Return "[FightingEntropy({0})] <{1}>" -f [Char]960, $This.Name
        }
        SetGeneral([String]$Description,[String]$Office,[String]$Email,[String]$Homepage)
        {
            $This.Description            = $Description
            $This.Office                 = $Office
            $This.EmailAddress           = $Email
            $This.HomePage               = $Homepage
        }
        SetLocation([Object]$Location)
        {
            $This.StreetAddress          = $Location.StreetAddress
            $This.City                   = $Location.City
            $This.State                  = $Location.State
            $This.PostalCode             = $Location.PostalCode
            $This.Country                = $Location.Country
        }
        SetProfile([String]$xProfile,[String]$Script,[String]$Dir,[String]$Drive)
        {
            $This.ProfilePath            = $xProfile
            $This.ScriptPath             = $Script
            $This.HomeDirectory          = $Dir
            $This.HomeDrive              = $Drive
        }
        SetTelephone([String]$xHome,[String]$Office,[String]$Mobile,[String]$Fax)
        {
            $This.HomePhone              = $xHome
            $This.OfficePhone            = $Office
            $This.MobilePhone            = $Mobile
            $This.Fax                    = $Fax
        }
        SetOrganization([String]$Title,[String]$Department,[String]$Company)
        {
            $This.Title                  = $Title
            $This.Department             = $Department
            $This.Company                = $Company
        }
        SetAccountPassword([SecureString]$Pass)
        {
            If ($Pass.GetType().Name -ne "SecureString")
            {
                Throw "Invalid password entry"
            }

            $This.AccountPassword        = $Pass
        }
        SetPath([String]$Path)
        {
            $This.Path                   = $Path
        }
        [String] Domain()
        {
            Return [Environment]::GetEnvironmentVariable("UserDnsDomain").ToLower()
        }
        [String] ToString()
        {
            Return "<FEModule.FeAdUser>"
        }
    }

    # // ==================================================================
    # // | Controller for Active Directory object (navigation/population) |
    # // ==================================================================

    Class FeAdController
    {
        [Object]    $Types
        [Object]   $Object
        [Object] $Location
        [Object]   $Output
        FeAdController()
        {
            $This.Types  = $This.FeAdObjectSlotList()
            $This.Object = $This.FeAdObjectList()
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Object.Refresh()
        }
        [Object[]] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Types.Output.Count)
            {
                Throw $This.ErrorSupport()
            }

            $This.Refresh()

            $Type = $This.Types.Output[$Index].Type

            Return $This.Object.Output | ? Type -eq $Type
        }
        [Object] FeAdObjectSlotList()
        {
            Return [FeAdObjectSlotList]::New()
        }
        [Object] FeAdObjectList()
        {
            Return [FeAdObjectList]::New()
        }
        [Object] FeAdLocation([String]$Address,[String]$City,[String]$State,[String]$Zip,[String]$Country)
        {
            Return [FeAdLocation]::New($Address,$City,$State,$Zip,$Country)
        }
        [Object] FeAdOrganizationalUnit([String]$Name,[String]$Description)
        {
            Return [FeAdOrganizationalUnit]::New($Name,$Description,$This.Location)
        }
        [String] ErrorSupport()
        {
            Return "Exception [!] Only supporting: (0:OrganizationalUnit/1:Group/2:User)"
        }
        SetLocation([String]$Address,[String]$City,[String]$State,[String]$Zip,[String]$Country)
        {
            $This.Location = $This.FeAdLocation($Address,$City,$State,$Zip,$Country)
        }
        SetAccountPassword([SecureString]$Pass)
        {

        }
        AddOrganizationalUnit([String]$Name,[String]$Description)
        {
            $List = $This.Get(0)
            If ($Name -in $List.Name)
            {
                Throw "Exception [!] Organizational unit already exists"
            }

            $Item = $This.FeAdOrganizationalUnit($Name,$Description)
            $Item.Create()
        }
        RemoveOrganizationalUnit([String]$Name)
        {
            $List = $This.Get(0)
            If ($Name -notin $List.Name)
            {
                Throw "Exception [!] Organizational unit does not exist"
            }

            $Item = $This.FeAdOrganizationalUnit($Name,$Null)
            $Item.Remove()
        }
        AddGroup([String]$Name,[String]$Category,[String]$Scope,[String]$Description,[String]$Path)
        {
            $List = $This.Get(1)
            If ($Name -in $List.Name)
            {
                Throw "Exception [!] Group already exists"
            }

            $Item = $This.FeAdGroup($Name,$Category,$Scope,$Description,$Path)
            $Item.Create()
        }
        RemoveGroup([String]$Name)
        {
            $List = $This.Get(0)
            If ($Name -notin $List.Name)
            {
                Throw "Exception [!] Group does not exist"
            }

            $Item = $This.FeAdGroup($Name,$Null,$Null,$Null,$Null)
            $Item.Remove()
        }
    }

    [FeAdController]::New()
}
