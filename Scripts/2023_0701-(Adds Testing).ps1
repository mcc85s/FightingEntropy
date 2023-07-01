Class cimdbClientAdUser
{
    [Object]                                 $Client
    [String]                            $DisplayName
    [String]                              $GivenName
    [String]                               $Initials
    [String]                                $Surname
    [String]                              $OtherName
    [String]                                   $Name
    [String]                          $StreetAddress
    [String]                                   $City
    [String]                                  $State
    [String]                             $PostalCode
    [String]                                $Country
    [String]                                  $POBox
    [String]                           $EmailAddress
    [String]                              $HomePhone
    [String]                            $MobilePhone
    [String]                            $OfficePhone
    [String]                           $Organization
    [String]                                  $Title
    [String]                                $Company
    [String]                               $Division
    [String]                             $Department
    [Object]                                $Manager
    [String]                             $EmployeeID
    [String]                         $EmployeeNumber
    [String]                            $Description
    [DateTime]                $AccountExpirationDate
    [UInt32]                    $AccountNotDelegated
    [SecureString]                  $AccountPassword
    [UInt32]      $AllowReversiblePasswordEncryption
    [Object]                   $AuthenticationPolicy
    [Object]               $AuthenticationPolicySilo
    [Switch]                               $AuthType
    [UInt32]                   $CannotChangePassword
    [Object[]]                         $Certificates
    [UInt32]                  $ChangePasswordAtLogon
    [UInt32]              $CompoundIdentitySupported
    [Object]                             $Credential
    [UInt32]                                $Enabled
    [String]                                    $Fax
    [String]                          $HomeDirectory
    [String]                              $HomeDrive
    [String]                               $HomePage
    [Object]                               $Instance
    [Switch]                 $KerberosEncryptionType
    [String]                      $LogonWorkstations
    [String]                                 $Office
    [Hashtable]                     $OtherAttributes
    [Switch]                               $PassThru
    [UInt32]                   $PasswordNeverExpires
    [UInt32]                    $PasswordNotRequired
    [String]                                   $Path
    [Object[]] $PrincipalsAllowedToDelegateToAccount
    [String]                            $ProfilePath
    [String]                         $SamAccountName
    [String]                             $ScriptPath
    [String]                                 $Server
    [String[]]                $ServicePrincipalNames
    [UInt32]                 $SmartcardLogonRequired
    [UInt32]                   $TrustedForDelegation
    [String]                                   $Type
    [String]                      $UserPrincipalName
    [Object]                                    $Dob
    [UInt32]                                 $Exists
    cimdbClientAdUser([Object]$Client)
    {
        # Record
        $This.Client          = $Client

        # Name
        $This.DisplayName     = $Client.Record.Name.DisplayName
        $This.GivenName       = $Client.Record.Name.GivenName
        $This.Initials        = $Client.Record.Name.Initials
        $This.Surname         = $Client.Record.Name.Surname
        $This.OtherName       = $Client.Record.Name.OtherName
        $This.Name            = $Client.Record.Name.DisplayName

        # Location
        $This.StreetAddress   = $Client.Record.Location.StreetAddress
        $This.City            = $Client.Record.Location.City
        $This.State           = $Client.Record.Location.Region
        $This.PostalCode      = $Client.Record.Location.PostalCode
        $This.Country         = $Client.Record.Location.Country
        $This.POBox           = $Null

        # Gender <In @{OtherAttributes}> Do not implement for now
        # Dob <In @{OtherAttributes}>
        $This.Dob             = $Client.Record.Dob

        # Contact
        If (0 -in $Client.Record.Phone.Output.Type)
        {
            $This.HomePhone   = ($Client.Record.Phone.Output | ? Type -eq 0)[0].Number
        }

        If (1 -in $Client.Record.Phone.Output.Type)
        {
            $This.OfficePhone = ($Client.Record.Phone.Output | ? Type -eq 1)[0].Number
        }

        If (2 -in $Client.Record.Phone.Output.Type)
        {
            $This.MobilePhone = ($Client.Record.Phone.Output | ? Type -eq 2)[0].Number
        }

        $This.EmailAddress    = ($Client.Record.Email.Output)[0].Handle

        # Company <Yet to implement>
        $This.Organization    = $Null
        $This.Title           = $Null
        $This.Company         = $Null
        $This.Division        = $Null
        $This.Department      = $Null
        $This.Manager         = $Null
        $This.EmployeeID      = $Null
        $This.EmployeeNumber  = $Null
    }
    Irrelevant()
    {
        $This.Description                          = $Null
        $This.AccountExpirationDate                = $Null
        $This.AccountNotDelegated                  = $Null
        $This.AccountPassword                      = $Null
        $This.AllowReversiblePasswordEncryption    = $Null
        $This.AuthenticationPolicy                 = $Null
        $This.AuthenticationPolicySilo             = $Null
        $This.AuthType                             = $Null
        $This.CannotChangePassword                 = $Null
        $This.Certificates                         = $Null
        $This.ChangePasswordAtLogon                = $Null
        $This.CompoundIdentitySupported            = $Null
        $This.Credential                           = $Null
        $This.Enabled                              = $Null
        $This.Fax                                  = $Null
        $This.HomeDirectory                        = $Null
        $This.HomeDrive                            = $Null
        $This.HomePage                             = $Null
        $This.Instance                             = $Null
        $This.KerberosEncryptionType               = $Null
        $This.LogonWorkstations                    = $Null
        $This.Office                               = $Null
        $This.OtherAttributes                      = $Null
        $This.PassThru                             = $Null
        $This.PasswordNeverExpires                 = $Null
        $This.PasswordNotRequired                  = $Null
        $This.Path                                 = $Null
        $This.PrincipalsAllowedToDelegateToAccount = $Null
        $This.ProfilePath                          = $Null
        $This.SamAccountName                       = $Null
        $This.ScriptPath                           = $Null
        $This.Server                               = $Null
        $This.ServicePrincipalNames                = $Null
        $This.SmartcardLogonRequired               = $Null
        $This.TrustedForDelegation                 = $Null
        $This.Type                                 = $Null
        $This.UserPrincipalName                    = $Null
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client[AdUser]>"
    }
}

Enum AdObjectSlotType
{
    BuiltInDomain
    ClassStore
    Computer
    Container
    DFSConfiguration
    DNSNode
    DNSZone
    DomainDNS
    DomainPolicy
    FileLinkTracking
    ForeignSecurityPrincipal
    Group
    GroupPolicyContainer
    InfrastructureUpdate
    IPSecFilter
    IPSecISAKMPPolicy
    IPSecNegotiationPolicy
    IPSecNFA
    IPSecPolicy
    LinkTrackObjectMoveTable
    LinkTrackVolumeTable
    LostAndFound
    MSDFSR_Content
    MSDFSR_ContentSet
    MSDFSR_GlobalSettings
    MSDFSR_LocalSettings
    MSDFSR_Member
    MSDFSR_ReplicationGroup
    MSDFSR_Subscriber
    MSDFSR_Subscription
    MSDFSR_Topology
    MSDS_PasswordSettingsContainer
    MSDS_QuotaContainer
    MSImaging_PSPs
    MSTPM_InformationObjectsContainer
    NTFRSSettings
    OrganizationalUnit
    RIDManager
    RIDSet
    RPCContainer
    SamServer
    User
}

Class AdObjectSlotItem
{
    [UInt32]              $Index
    [Object]               $Name
    Hidden [String] $DisplayName
    [String]        $Description
    AdObjectSlotItem([String]$Name)
    {
        $This.Index       = [UInt32][AdObjectSlotType]::$Name
        $This.Name        = [AdObjectSlotType]::$Name
        $This.DisplayName = $This.Name -Replace "_","-"
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

Class AdObjectSlotList
{
    [Object] $Output
    AdObjectSlotList()
    {
        $This.Refresh()
    }
    [Object] AdObjectSlotItem([String]$Name)
    {
        Return [AdObjectSlotItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([AdObjectSlotType]))
        {
            $Item             = $This.AdObjectSlotItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                BuiltInDomain
                {
                    "Built in domain"
                }
                ClassStore
                {
                    "Class store"
                }
                Computer
                {
                    "Computer object"
                }
                Container
                {
                    "Container object"
                }
                DFSConfiguration
                {
                    "Distributed Filesystem Configuration"
                }
                DNSNode
                {
                    "Domain Name Service Node"
                }
                DNSZone
                {
                    "Domain Name Service Zone"
                }
                DomainDNS
                {
                    "Domain level DNS record(s)"
                }
                DomainPolicy
                {
                    "Domain level policy"
                }
                FileLinkTracking
                {
                    "File link tracking"
                }
                ForeignSecurityPrincipal
                {
                    "Foreign Security Principal (remote domain principal)"
                }
                Group
                {
                    "Active Directory Group object"
                }
                GroupPolicyContainer
                {
                    "Active Directory Group Policy container"
                }
                InfrastructureUpdate
                {
                    "Active Directory Infrastructure Update"
                }
                IPSecFilter
                {
                    "Internet Protocol Security Filter"
                }
                IPSecISAKMPPolicy
                {
                    "Internet Protocol Security (ISAKMP)"
                }
                IPSecNegotiationPolicy
                {
                    "Internet Protocol Security Negotiation Policy"
                }
                IPSecNFA
                {
                    "Internet Protocol Security (NFA)"
                }
                IPSecPolicy
                {
                    "Internet Protocol Security Policy"
                }
                LinkTrackObjectMoveTable
                {
                    "Link track object move table"
                }
                LinkTrackVolumeTable
                {
                    "Link track volume table"
                }
                LostAndFound
                {
                    "Lost and found"
                }
                MSDFSR_Content
                {
                    "Microsoft Distributed File System Replication content"
                }
                MSDFSR_ContentSet
                {
                    "Microsoft Distributed File System Replication content set"
                }
                MSDFSR_GlobalSettings
                {
                    "Microsoft Distributed File System Replication global settings"
                }
                MSDFSR_LocalSettings
                {
                    "Microsoft Distributed File System Replication local settings"
                }
                MSDFSR_Member
                {
                    "Microsoft Distributed File System Replication member"
                }
                MSDFSR_ReplicationGroup
                {
                    "Microsoft Distributed File System Replication Replication group"
                }
                MSDFSR_Subscriber
                {
                    "Microsoft Distributed File System Replication subscriber"
                }
                MSDFSR_Subscription
                {
                    "Microsoft Distributed File System Replication subscription"
                }
                MSDFSR_Topology
                {
                    "Microsoft Distributed File System Replication topology"
                }
                MSDS_PasswordSettingsContainer
                {
                    "Microsoft (DS) password settings container"
                }
                MSDS_QuotaContainer
                {
                    "Microsoft (DS) quota container"
                }
                MSImaging_PSPs
                {
                    "Microsoft Imaging (PSP)s"
                }
                MSTPM_InformationObjectsContainer
                {
                    "Microsoft (Trusted Platform Module?) information objects container"
                }
                NTFRSSettings
                {
                    "New Technology File Replication System settings"
                }
                OrganizationalUnit
                {
                    "Active Directory Organizational Unit"
                }
                RIDManager
                {
                    "Replication ID manager"
                }
                RIDSet
                {
                    "Replication ID set"
                }
                RPCContainer
                {
                    "Remote Procedure Call container"
                }
                SamServer
                {
                    "Security Access Manager Server"
                }
                User
                {
                    "Active Directory User object"
                }
            }

            $This.Output += $Item
        }
    }
    [Object] Get([String]$Name)
    {
        Return $This.Output | ? DisplayName -eq $Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.AdObjectSlot[List]>"
    }
}

Class AdObjectItem
{
    [String]              $Name
    Hidden [Object]     $Object
    [Object]              $Slot
    [String]    $SamAccountName
    [String] $UserPrincipalName
    [Object] $DistinguishedName
    [String]       $Description
    AdObjectItem([Object]$Object)
    {
        $This.Name              = $Object.Name
        $This.Object            = $Object
        $This.SamAccountName    = $object.SamAccountName
        $This.UserPrincipalName = $Object.UserPrincipalName
        $This.DistinguishedName = $Object.DistinguishedName
        $This.Description       = $Object.Description
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class AdObjectController
{
    Hidden [Object] $Slot
    [Object]      $Import
    [Object]      $Output
    AdObjectController()
    {
        $This.Slot = $This.AdObjectSlotList()
    }
    [Object] AdObjectItem([Object]$Object)
    {
        Return [AdObjectItem]::New($Object)
    }
    [Object] AdObjectSlotList()
    {
        Return [AdObjectSlotList]::New()
    }
    [Object] cimdbClientAdUser([Object]$Client)
    {
        Return [cimdbClientAdUser]::New($Client)
    }
    [Object[]] GetObject()
    {
        Return Get-AdObject -Properties * -Filter * | Sort-Object Name
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Object in $This.GetObject())
        {
            $Item         = $This.AdObjectItem($Object)
            $Item.Slot    = $This.Slot.Output | ? DisplayName -eq $Item.Object.ObjectClass
            $This.Output += $Item
        }

        <#
        $Adds.Clear()
        $List = $Adds.GetObject()

        ForEach ($Object in $List)
        {
            $Item         = $Adds.AdObjectItem($Object)
            $Item.Slot    = $Adds.Slot.Output | ? DisplayName -eq $Item.Object.ObjectClass

            $Adds.Output += $Item
        }
        #>
    }
    [String] Domain()
    {
        Return [Environment]::GetEnvironmentVariable("USERDNSDOMAIN").ToLower()
    }
    [String] ClientPath()
    {
        Return Get-AdOrganizationalUnit -Properties * -Filter * | ? DistinguishedName -match Client
    }
    GenerateSam([Object]$Item)
    {
        # Attempt # 1
        $Hash = @{ }
        $Hash.Add(0,$Item.Client.Record.Name.GivenName.ToLower().SubString(0,1))
        $Hash.Add(1,$Item.Client.Record.Name.Surname.ToLower())
        $Hash.Add(2,$Item.Client.Record.Dob.Dob.Substring(8,2))

        $String = $Hash[0..2] -join ""
        $Ad     = $This.Output | ? SamAccountName -match $String

        If (!$Ad)
        {
            $Item.SamAccountName    = $String
            $Item.UserPrincipalName = "{0}@{1}" -f $String, $This.Domain()
        }
    }
    Check([Object]$Item)
    {
        If (!$Item.UserPrincipalName)
        {
            Throw "No user principal name set"
        }

        $This.Refresh()
        $Ad          = $This.Output | ? UserPrincipalName -eq $This.UserPrincipalName

        $Item.Exists = [UInt32]!!$Ad
    }
    Create([Object]$Item)
    {
        $This.Check($Item)

        If (!$Item.Exists)
        {
            $Splat                  = @{

                Name                = $Item.Name
                DisplayName         = $Item.DisplayName
                GivenName           = $Item.GivenName
                Initials            = $Item.Initials
                Surname             = $Item.Surname
                SamAccountName      = $Item.SamAccountName
                UserPrincipalName   = $Item.UserPrincipalName
                Path                = $This.ClientPath().DistinguishedName
            }

            New-AdUser @Splat -Verbose
        }

        $This.Check($Item)
    }
    ImportList([Object[]]$Clients)
    {
        $This.Import = @( )

        ForEach ($Client in $Clients)
        {
            $Item         = $This.cimdbClientAdUser($Client)
            $This.GenerateSam($Item)
            $This.Check($Item)

            Switch ($Item.Exists)
            {
                0
                {
                    $This.Import += $Item
                } 
                1
                {
                    [Console]::WriteLine("[$($Item.Name)] [!] Exists")
                }
            }
        }
    }
    [String] ToString()
    {
        Return "<FEModule.AdObject[Controller]>"
    }
}

$Adds = [AdObjectController]::New()

# Select the client list
$ClientList = $Ctrl.Database.GetRecordSlot("Client")

$Adds.ImportList($ClientList)
