<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-03-28 15:55:19                                                                  //
 \\==================================================================================================// 

    FileName   : Initialize-FeAdInstance.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : Populate Active Directory with authorized nodes, users, and computers
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-01-23
    Modified   : 2023-03-28
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Finish and test

.Example
#>

Function Initialize-FeAdInstance
{
    Import-Module ActiveDirectory

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
        [Object] FeAdObjectItem([Object]$Object)
        {
            Return [FeAdObjectItem]::New($Object)
        }
        Add([Object]$Object)
        {
            $This.Output += $This.FeAdObjectItem($Object)
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
        FeAdOrganizationalUnit([Switch]$Flags,[Object]$Ou)
        {
            $This.Ou                = $Ou
            $This.Name              = $Ou.Name
            $This.DisplayName       = $Ou.DisplayName
            $This.Description       = $Ou.Description
            $This.StreetAddress     = $Ou.StreetAddress
            $This.City              = $Ou.City
            $This.State             = $Ou.State
            $This.PostalCode        = $Ou.PostalCode
            $This.Country           = $Ou.Country
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
        FeAdGroup([Switch]$Flags,[Object]$Group)
        {
            $This.Group         = $Group
            $This.Name          = $Group.Name
            $This.GroupCategory = $Group.GroupCategory
            $This.GroupScope    = $Group.GroupScope
            $This.Description   = $Group.Description
            $Label              = "CN={0}," -f $This.Name
            $This.Path          = $Group.DistinguishedName -Replace $Label, ""

            $This.DisplayName   = $Group.DisplayName
            
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
        [String]                  $Path
        [UInt32]               $Enabled
        [UInt32]                $Exists
        [String]     $DistinguishedName
        FeAdUser([String]$Given,[String]$Initials,[String]$Surname,[String]$Sam,[String]$Path)
        {
            $This.GivenName         = $Given
            $This.Initials          = $Initials
            $This.Surname           = $Surname
            $This.DisplayName       = Switch ([UInt32]!$Initials)
            {
                0 { "{0} {1}. {2}" -f $Given, $Initials, $Surname } 1 { "{0} {1}" -f $Given, $Surname }
            }

            $This.Name              = $This.DisplayName
            $This.SamAccountName    = $Sam
            $This.UserPrincipalName = "{0}@{1}" -f $Sam, $This.Domain()
            $This.Path              = $Path

            $This.Check()
        }
        FeAdUser([Switch]$Flags,[Object]$User)
        {
            $This.User              = $User
            $This.Name              = $User.Name
            $This.DisplayName       = $User.DisplayName
            $This.GivenName         = $User.GivenName
            $This.Initials          = $User.Initials
            $This.Surname           = $User.Surname
            $This.Description       = $User.Description
            $This.Office            = $User.Office
            $This.EmailAddress      = $User.EmailAddress
            $This.HomePage          = $User.HomePage
            $This.StreetAddress     = $User.StreetAddress
            $This.City              = $User.City
            $This.State             = $User.State
            $This.PostalCode        = $User.PostalCode
            $This.Country           = $User.Country
            $This.SamAccountName    = $User.SamAccountName
            $This.UserPrincipalName = $User.UserPrincipalName
            $This.ProfilePath       = $User.ProfilePath
            $This.ScriptPath        = $User.ScriptPath
            $This.HomeDirectory     = $User.HomeDirectory
            $This.HomeDrive         = $User.HomeDrive
            $This.HomePhone         = $User.HomePhone
            $This.OfficePhone       = $User.OfficePhone
            $This.MobilePhone       = $User.MobilePhone
            $This.Fax               = $User.Fax
            $This.Title             = $User.Title
            $This.Department        = $User.Department
            $This.Company           = $User.Company

            $Label                  = "CN={0}," -f $This.Name
            $This.Path              = $User.DistinguishedName -Replace $Label, ""

            $This.Check()
        }
        Check()
        {
            $This.Get() | Out-Null
        }
        [Object] Get()
        {
            $This.User              = Get-AdUser -Filter * -Properties * -EA 0 | ? Name -eq $This.Name
            If ($This.User)
            {
                $This.Enabled       = [UInt32]$This.User.Enabled
            }
            $This.Exists            = !!$This.User
            $This.DistinguishedName = $This.User.DistinguishedName
            Return $This.User
        }
        Create()
        {
            $This.Check()
            If ($This.Exists)
            {
                Throw "Exception [!] User already exists"
            }

            $Splat                  = @{

                Name                = $This.Name
                DisplayName         = $This.DisplayName
                GivenName           = $This.GivenName
                Initials            = $This.Initials
                Surname             = $This.Surname
                SamAccountName      = $This.SamAccountName
                UserPrincipalName   = $This.UserPrincipalName
                Path                = $This.Path
            }

            New-AdUser @Splat -Verbose
            $This.Check()
        }
        Remove()
        {
            $This.Check()
            If (!$This.Exists)
            {
                Throw "Exception [!] User does not exist"
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
            $This.Description       = $Description
            $This.Office            = $Office
            $This.EmailAddress      = $Email
            $This.HomePage          = $Homepage

            $Splat                  = @{ }

            ForEach ($Name in "Description","Office","EmailAddress","HomePage")
            {
                If ($This.$Name)
                {
                    $Splat.Add($Name,$This.$Name)
                }
            }

            Set-AdUser -Identity $This.DistinguishedName @Splat -Verbose -EA 0
        }
        SetLocation([Object]$Location)
        {
            $This.StreetAddress     = $Location.StreetAddress
            $This.City              = $Location.City
            $This.State             = $Location.State
            $This.PostalCode        = $Location.PostalCode
            $This.Country           = $Location.Country

            $Splat                  = @{ }

            ForEach ($Name in "StreetAddress","City","State","PostalCode","Country")
            {
                If ($This.$Name)
                {
                    $Splat.Add($Name,$This.$Name)
                }
            }

            Set-AdUser -Identity $This.DistinguishedName @Splat -Verbose -EA 0
        }
        SetProfile([String]$Profile,[String]$Script,[String]$Dir,[String]$Drive)
        {
            $This.ProfilePath       = $Profile
            $This.ScriptPath        = $Script
            $This.HomeDirectory     = $Dir
            $This.HomeDrive         = $Drive

            $Splat                  = @{ }

            ForEach ($Name in "ProfilePath","ScriptPath","HomeDirectory","HomeDrive")
            {
                If ($This.$Name)
                {
                    $Splat.Add($Name,$This.$Name)
                }
            }

            Set-AdUser -Identity $This.DistinguishedName @Splat -Verbose -EA 0
        }
        SetTelephone([String]$xHome,[String]$Office,[String]$Mobile,[String]$Fax)
        {
            $This.HomePhone         = $xHome
            $This.OfficePhone       = $Office
            $This.MobilePhone       = $Mobile
            $This.Fax               = $Fax

            $Splat                  = @{ }

            ForEach ($Name in "HomePhone","OfficePhone","MobilePhone","Fax")
            {
                If ($This.$Name)
                {
                    $Splat.Add($Name,$This.$Name)
                }
            }

            Set-AdUser -Identity $This.DistinguishedName @Splat -Verbose -EA 0
        }
        SetOrganization([String]$Title,[String]$Department,[String]$Company)
        {
            $This.Title             = $Title
            $This.Department        = $Department
            $This.Company           = $Company

            $Splat                  = @{ }

            ForEach ($Name in "Title","Department","Company")
            {
                If ($This.$Name)
                {
                    $Splat.Add($Name,$This.$Name)
                }
            }

            Set-AdUser -Identity $This.DistinguishedName @Splat -Verbose -EA 0
        }
        SetAccountPassword([SecureString]$Pass)
        {
            $This.Check()

            If ($Pass.GetType().Name -ne "SecureString")
            {
                Throw "Invalid password entry"
            }

            If (!$This.Enabled)
            {
                Set-AdAccountPassword -Identity $This.DistinguishedName -NewPassword $Pass -Verbose -EA 0
                Set-AdUser -Identity $This.DistinguishedName -Enabled 1 -Verbose -EA 0
            }

            $This.Check()
        }
        SetPrimaryGroup([Object]$Group)
        {
            $Sid     = Get-AdObject -Identity $Group.DistinguishedName -Properties * | % ObjectSid
            $GroupId = $Sid.Value.Split("-")[-1]

            Set-AdObject -Identity $This.DistinguishedName -Replace @{ primaryGroupId = $GroupId } -Verbose 
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
        FeAdController()
        {
            $This.Types  = $This.FeAdObjectSlotList()
            $This.Object = $This.FeAdObjectList()
        }
        Refresh()
        {
            $This.Object.Refresh()
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
        [Object] FeAdOrganizationalUnit([String]$Name,[String]$Desc)
        {
            Return [FeAdOrganizationalUnit]::New($Name,$Desc,$This.Location)
        }
        [Object] FeAdOrganizationalUnit([Switch]$Flags,[Object]$Object)
        {
            Return [FeAdOrganizationalUnit]::New($Flags,$Object)
        }
        [Object] FeAdGroup([String]$Name,[String]$Category,[String]$Scope,[String]$Desc,[String]$Path)
        {
            Return [FeAdGroup]::New($Name,$Category,$Scope,$Desc,$Path)
        }
        [Object] FeAdGroup([Switch]$Flags,[Object]$Object)
        {
            Return [FeAdGroup]::New($Flags,$Object)
        }
        [Object] FeAdUser([String]$Given,[String]$Initials,[String]$Surname,[String]$Sam,[String]$Path)
        {
            Return [FeAdUser]::New($Given,$Initials,$Surname,$Sam,$Path)
        }
        [Object] FeAdUser([Switch]$Flags,[Object]$Object)
        {
            Return [FeAdUser]::New($Flags,$Object)
        }
        [Object[]] Get([UInt32]$Index)
        {
            # // Throws if the index is not within bounds
            If ($Index -gt $This.Types.Output.Count)
            {
                Throw $This.ErrorSupport()
            }

            # // Refreshes the Active Directory node tree
            $This.Refresh()

            # // Selects the specific type
            $Type = $This.Types.Output[$Index].Type

            # // Returns the total list of objects with that type
            Return $This.Object.Output | ? Type -eq $Type
        }
        [String] ErrorSupport()
        {
            Return "Exception [!] Only supporting: (0:OrganizationalUnit/1:Group/2:User)"
        }
        SetLocation([String]$Address,[String]$City,[String]$State,[String]$Zip,[String]$Country)
        {
            $This.Location = $This.FeAdLocation($Address,$City,$State,$Zip,$Country)
        }
        AddAdOrganizationalUnit([String]$Name,[String]$Desc)
        {
            # // (Checks for/throws if) it does exist
            $xObject = $This.Get(0) | ? Name -eq $Name
            If ($xObject)
            {
                Throw "Exception [!] Organizational unit already exists"
            }

            # // Instantiates the object
            $Ou     = $This.FeAdOrganizationalUnit($Name,$Desc)
            
            # // Creates the object
            $Ou.Create()
        }
        [Object] GetAdOrganizationalUnit([String]$Name)
        {
            # // (Checks for/throws if) it does not exist
            $xObject = $This.Get(0) | ? Name -eq $Name
            If (!$xObject)
            {
                Throw "Exception [!] Organizational unit does not exist"
            }

            # // Obtains the object by distinguished name
            $Ou     = Get-AdOrganizationalUnit -Identity $xObject.DistinguishedName -Properties *

            # // Returns an instantiated version of the object
            Return $This.FeAdOrganizationalUnit([Switch]$True,$Ou)
        }
        RemoveAdOrganizationalUnit([String]$Name)
        {
            # // (Checks/Returns) instantiated version of the object
            $Ou     = $This.GetAdOrganizationalUnit($Name)

            # // Removes if found
            If ($Ou)
            {
                $Ou.Remove()
            }
        }
        AddAdGroup([String]$Name,[String]$Category,[String]$Scope,[String]$Desc,[String]$Path)
        {
            # // (Checks for/throws if) it does exist
            $xObject = $This.Get(1) | ? Name -eq $Name
            If ($xObject)
            {
                Throw "Exception [!] Group already exists"
            }

            # // Instantiates the object
            $Group  = $This.FeAdGroup($Name,$Category,$Scope,$Desc,$Path)

            # // Creates the object
            $Group.Create()
        }
        [Object] GetAdGroup([String]$Name)
        {
            # // (Checks for/throws if) it does exist
            $xObject = $This.Get(1) | ? Name -eq $Name
            If (!$xObject)
            {
                Throw "Exception [!] Group does not exist"
            }

            # // Obtains the object by distinguished name
            $Group = Get-AdGroup -Identity $xObject.DistinguishedName -Properties *

            # // Returns an instantiated version of the object
            Return $This.FeAdGroup([Switch]$True,$Group)
        }
        RemoveAdGroup([String]$Name)
        {
            # // (Checks/Returns) instantiated version of the object
            $Group = $This.GetAdGroup($Name)
            If ($Group)
            {
                $Group.Remove()
            }
        }
        [Object[]] GetAdPrincipalGroupMembership([String]$Name)
        {
            $Group = $This.GetAdGroup($Name)
            
            Return Get-AdPrincipalGroupMembership -Identity $Group.DistinguishedName
        }
        AddAdPrincipalGroupMembership([String]$GroupName,[String[]]$Names)
        {
            $Group = $This.Get(1) | ? Name -eq $GroupName
            $List  = $This.GetAdPrincipalGroupMembership($GroupName)

            ForEach ($Name in $Names)
            {
                If ($Name -notin $List.Name)
                {
                    $Splat       = @{

                        Identity = $Group.DistinguishedName
                        MemberOf = $Name
                    }

                    Add-AdPrincipalGroupMembership @Splat -EA 0 -Verbose
                }
            }
        }
        AddAdUser([String]$Given,[String]$Initials,[String]$Surname,[String]$Sam,[String]$Path)
        {
            # // Set template object
            $Name = Switch ([UInt32]!$Initials)
            {
                0 { "{0} {1}. {2}" -f $Given, $Initials, $Surname }
                1 { "{0} {1}" -f $Given, $Surname }
            }

            # // (Checks for/throws if) it does exist
            $xObject = $This.Get(2) | ? Name -eq $Name
            If ($xObject)
            {
                Throw "Exception [!] User already exists"
            }

            # // Instantiates the object
            $User  = $This.FeAdUser($Given,$Initials,$Surname,$Sam,$Path)

            # // Creates the object
            $User.Create()
        }
        [Object] GetAdUser([String]$Given,[String]$Initials,[String]$Surname)
        {
            # // Set template object
            $Name = Switch ([UInt32]!$Initials)
            {
                0 { "{0} {1}. {2}" -f $Given, $Initials, $Surname }
                1 { "{0} {1}" -f $Given, $Surname }
            }

            # // (Checks for/throws if) it does exist
            $xObject = $This.Get(2) | ? Name -eq $Name
            If (!$xObject)
            {
                Throw "Exception [!] User does not exist"
            }

            # // Obtains the object by distinguished name
            $User = Get-AdUser -Identity $xObject.DistinguishedName -Properties *

            # // Returns an instantiated version of the object
            Return $This.FeAdUser([Switch]$True,$User)
        }
        RemoveAdUser([String]$Given,[String]$Initials,[String]$Surname)
        {
            # // (Checks/Returns) instantiated version of the object
            $User = $This.GetAdUser($Given,$Initials,$Surname)
            If ($User)
            {
                $User.Remove()
            }
        }
        [Object[]] GetAdGroupMember([Object]$Group)
        {
            Return Get-AdGroupMember -Identity $Group.DistinguishedName
        }
        AddAdGroupMember([Object]$Group,[Object]$User)
        {
            $List = $This.GetAdGroupMember($Group)
            
            If ($User.DistinguishedName -notin $List.DistinguishedName)
            {
                $Splat       = @{ 

                    Identity = $Group.DistinguishedName
                    Members  = $User.DistinguishedName
                }

                Add-AdGroupMember @Splat -Verbose -EA 0
            }
        }
    }

    [FeAdController]::New()
}
