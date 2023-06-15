<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Uid Category [+]                                                                               ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbUidRecordCategoryType
{
    Client
    Service
    Device
    Issue
    Purchase
    Inventory
    Expense
    Account
    Invoice
}

Class cimdbUidRecordCategoryItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbUidRecordCategoryItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbUidRecordCategoryType]::$Name
        $This.Name  = [cimdbUidRecordCategoryType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbUidRecordCategoryList
{
    [Object]      $Output
    cimdbUidRecordCategoryList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbUidRecordCategoryItem([String]$Name)
    {
        Return [cimdbUidRecordCategoryItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbUidRecordCategoryType]))
        {
            $Item             = $This.cimdbUidRecordCategoryItem($Name)
            $Item.Description = Switch ($Name)
            {
                Client     { "Tracks identity, phone(s), email(s), device(s), issue(s), and invoice(s)"  }
                Service    { "Tracks the name, description, rate/price of labor"                         }
                Device     { "Information such as make, model, serial number, etc."                      }
                Issue      { "Particular notes and statuses about a particular device"                   }
                Purchase   { "Item or service required for an issue or sale"                             }
                Inventory  { "Item specifically meant for sale"                                          }
                Expense    { "Good(s), service(s), or bill(s)"                                           }
                Account    { "Monetary silo or information for a particular vendor or external business" }
                Invoice    { "Representation of a sale"                                                  }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Uid.Record.Category[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Client Record [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbClientRecordSlotType
{
    Individual
    Business
    Unspecified
}

Class cimdbClientRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbClientRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbClientRecordSlotType]::$Name
        $This.Name  = [cimdbClientRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbClientRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbClientRecordSlotList()
    {
        $This.Index       = 0
        $This.Name        = "Client"
        $This.Description = "Represents all available client record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbClientRecordSlotItem([String]$Name)
    {
        Return [cimdbClientRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbClientRecordSlotType]))
        {
            $Item             = $This.cimdbClientRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Individual  { "Client is an individual, or a non-business entity" }
                Business    { "Client is a company/business entity"               }
                Unspecified { "Client falls into another category"                }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Client Status [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbClientStatusType
{
    Registered
    Unregistered
    Unspecified
}

Class cimdbClientStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbClientStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbClientStatusType]::$Name
        $This.Name  = [cimdbClientStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbClientStatusList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbClientStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbClientStatusItem([String]$Name)
    {
        Return [cimdbClientStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbClientStatusType]))
        {
            $Item             = $This.cimdbClientStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Registered   { "Client is registered"               }
                Unregistered { "Client is unregistered"             }
                Unspecified  { "Client falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Service Record [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbServiceRecordSlotType
{
    Rate
    Task
    Onsite
    Unspecified
}

Class cimdbServiceRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbServiceRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbServiceRecordSlotType]::$Name
        $This.Name  = [cimdbServiceRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbServiceRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbServiceRecordSlotList()
    {
        $This.Index       = 1
        $This.Name        = "Service"
        $This.Description = "Represents applicable service record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbServiceRecordSlotItem([String]$Name)
    {
        Return [cimdbServiceRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbServiceRecordSlotType]))
        {
            $Item             = $This.cimdbServiceRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Rate        { "Service is based on a paid rate"     }
                Task        { "Service is based on task completion" }
                Onsite      { "Service is based at a job site"      }
                Unspecified { "Service falls into another category" }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Service Status [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbServiceStatusType
{
    Authorized
    Unauthorized
    Unspecified
}

Class cimdbServiceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbServiceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbServiceStatusType]::$Name
        $This.Name  = [cimdbServiceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbServiceStatusList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbServiceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbServiceStatusItem([String]$Name)
    {
        Return [cimdbServiceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbServiceStatusType]))
        {
            $Item             = $This.cimdbServiceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Authorized   { "Service is authorized"               }
                Unauthorized { "Service is unauthorized"             }
                Unspecified  { "Service falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Device Record [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbDeviceRecordSlotType
{
    Desktop
    Laptop
    Smartphone
    Tablet
    Console
    Server
    Network
    Other
    Unspecified
}

Class cimdbDeviceRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbDeviceRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbDeviceRecordSlotType]::$Name
        $This.Name  = [cimdbDeviceRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbDeviceRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbDeviceRecordSlotList()
    {
        $This.Index       = 2
        $This.Name        = "Device"
        $This.Description = "Represents the chassis type for a particular device"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbDeviceRecordSlotItem([String]$Name)
    {
        Return [cimdbDeviceRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbDeviceRecordSlotType]))
        {
            $Item             = $This.cimdbDeviceRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Desktop      { "Device is a desktop form factor"        }
                Laptop       { "Device is a laptop/netbook."            }
                Smartphone   { "Device is a smartphone or derivative"   }
                Tablet       { "Device is a tablet"                     }
                Console      { "Device is a gaming console"             }
                Server       { "Device is a server form factor"         }
                Network      { "Device is networking related"           }
                Unspecified  { "Device falls within another category"   }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Device Status [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbDeviceStatusType
{
    Possessed
    Released
    Unspecified
}

Class cimdbDeviceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbDeviceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbDeviceStatusType]::$Name
        $This.Name  = [cimdbDeviceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbDeviceStatusList
{

    [Object] $Output
    cimdbDeviceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbDeviceStatusItem([String]$Name)
    {
        Return [cimdbDeviceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbDeviceStatusType]))
        {
            $Item             = $This.cimdbDeviceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Possessed   { "Device is currently in possession"  }
                Released    { "Device has been released"           }
                Unspecified { "Device falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Issue Record [+]                                                                               ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbIssueRecordSlotType
{
    Hardware
    Software
    Application
    Network
    Design
    Account
    Contract
    Unspecified
}

Class cimdbIssueRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbIssueRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbIssueRecordSlotType]::$Name
        $This.Name  = [cimdbIssueRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbIssueRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbIssueRecordSlotList()
    {
        $This.Index       = 3
        $This.Name        = "Issue"
        $This.Description = "Comprehensive list of issue record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbIssueRecordSlotItem([String]$Name)
    {
        Return [cimdbIssueRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbIssueRecordSlotType]))
        {
            $Item             = $This.cimdbIssueRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Hardware     { "Issue is hardware related"              }
                Software     { "Issue is (software/OS) related"         }
                Application  { "Issue is strictly an application"       }
                Network      { "Issue is network related"               }
                Design       { "Issue is design related"                }
                Account      { "Issue is account related"               }
                Contract     { "Issue is resolvable through a contract" }
                Unspecified  { "Issue falls into another category"      }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Issue Status [+]                                                                               ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbIssueStatusType
{
    New      
    Diagnosed
    Commit
    Complete
    NoGo
    Fail
    Transfer
    Unspecified
}

Class cimdbIssueStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbIssueStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbIssueStatusType]::$Name
        $This.Name  = [cimdbIssueStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbIssueStatusList
{

    [Object] $Output
    cimdbIssueStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbIssueStatusItem([String]$Name)
    {
        Return [cimdbIssueStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbIssueStatusType]))
        {
            $Item             = $This.cimdbIssueStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                New         { "Issue is brand new, or has not yet been processed" }
                Diagnosed   { "Issue has been diagnosed"                          }
                Commit      { "Issue has been submitted for service commitment"   }
                Complete    { "Issue has been completed"                          }
                NoGo        { "Issue was diagnosed, but was a no-go"              }
                Fail        { "Issue was diagnosed, but failed to be resolved"    }
                Transfer    { "Issue met a condition where it was transferred"    }
                Unspecified { "Issue falls into another category"                 }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Purchase Record [+]                                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPurchaseRecordSlotType
{
    Issue
    Sale
    Unspecified
}

Class cimdbPurchaseRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPurchaseRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPurchaseRecordSlotType]::$Name
        $This.Name  = [cimdbPurchaseRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPurchaseRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbPurchaseRecordSlotList()
    {
        $This.Index       = 4
        $This.Name        = "Purchase"
        $This.Description = "When items are purchased, they may be one of these record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbPurchaseRecordSlotItem([String]$Name)
    {
        Return [cimdbPurchaseRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPurchaseRecordSlotType]))
        {
            $Item             = $This.cimdbPurchaseRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Issue       { "Purchase is for a designated issue"   }
                Sale        { "Purchase is strictly for resale"      }
                Unspecified { "Purchase falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Purchase Status [+]                                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPurchaseStatusType
{
    Deposit
    Paid
    Ordered
    Delivered
}

Class cimdbPurchaseStatusItem
{
    [Uint32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPurchaseSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPurchaseStatusType]::$Name
        $This.Name  = [cimdbPurchaseStatusType]::$Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Status[Item]>"
    }
}

Class cimdbPurchaseStatusList
{
    [Object] $Output
    cimdbPurchaseSlotList()
    {
        $This.Refresh()
    }
    [Object] cimdbPurchaseStatusItem([String]$Name)
    {
        Return [cimdbPurchaseStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPurchaseStatusType]))
        {
            $Item             = $This.cimdbPurchaseStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Deposit     { "Item requires a deposit to be made"  }
                Paid        { "Item has made a deposit"             }
                Ordered     { "Item has been ordered"               }
                Delivered   { "Item has been delivered"             }
                Unspecified { "Item falls into some other category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Status[List]>"
    }
}


<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Inventory Record [+]                                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInventoryRecordSlotType
{
    Stock
	Purchase
	Salvage
	Unspecified
}

Class cimdbInventoryRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInventoryRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInventoryRecordSlotType]::$Name
        $This.Name  = [cimdbInventoryRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInventoryRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbInventoryRecordSlotList()
    {
        $This.Index       = 5
        $This.Name        = "Inventory"
        $This.Description = "When inventory is created, it will fall into one of these record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbInventoryRecordSlotItem([String]$Name)
    {
        Return [cimdbInventoryRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInventoryRecordSlotType]))
        {
            $Item             = $This.cimdbInventoryRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Stock       { "Inventory is a stock item"             }
                Purchase    { "Inventory is a purchased item"         }
                Salvage     { "Inventory was created from salvage"    }
                Unspecified { "Inventory falls into another category" }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Inventory Status [+]                                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInventoryStatusType
{
    Ready
    Await
    Unspecified
}

Class cimdbInventoryStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInventoryStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInventoryStatusType]::$Name
        $This.Name  = [cimdbInventoryStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInventoryStatusList
{

    [Object] $Output
    cimdbInventoryStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbInventoryStatusItem([String]$Name)
    {
        Return [cimdbInventoryStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInventoryStatusType]))
        {
            $Item             = $This.cimdbInventoryStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Ready       { "Inventory is ready for sale"      }
                Await       { "Inventory is waiting for <X>"     }
                Unspecified { "Inventory is in another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Expense Record [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbExpenseRecordSlotType
{
    Internal
    Payout
    Residual
    Unspecified
}

Class cimdbExpenseRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbExpenseRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbExpenseRecordSlotType]::$Name
        $This.Name  = [cimdbExpenseRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbExpenseRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbExpenseRecordSlotList()
    {
        $This.Index       = 6
        $This.Name        = "Expense"
        $This.Description = "When expenses are paid, they will fall into one of these record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbExpenseRecordSlotItem([String]$Name)
    {
        Return [cimdbExpenseRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbExpenseRecordSlotType]))
        {
            $Item             = $This.cimdbExpenseRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Internal    { "Expense is internal and to be used in accounting" }
                Payout      { "Expense is a refund or a cash/check payment"      }
                Residual    { "Expense is a planned expense"                     }
                Unspecified { "Expense falls into some other category"           }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Expense Status [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbExpenseStatusType
{
    Paid
    Unpaid
    Unspecified
}

Class cimdbExpenseStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbExpenseStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbExpenseStatusType]::$Name
        $This.Name  = [cimdbExpenseStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbExpenseStatusList
{

    [Object] $Output
    cimdbExpenseStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbExpenseStatusItem([String]$Name)
    {
        Return [cimdbExpenseStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbExpenseStatusType]))
        {
            $Item             = $This.cimdbExpenseStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Paid        { "Expense has been paid"               }
                Unpaid      { "Expense remains unpaid"              }
                Unspecified { "Expense falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Account Record [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbAccountRecordSlotType
{
    Bank
    Creditor
    Business
    Supplier
    Partner
    Unspecified
}

Class cimdbAccountRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbAccountRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbAccountRecordSlotType]::$Name
        $This.Name  = [cimdbAccountRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbAccountRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbAccountRecordSlotList()
    {
        $This.Index       = 7
        $This.Name        = "Account"
        $This.Description = "Handles an assortment of account record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbAccountRecordSlotItem([String]$Name)
    {
        Return [cimdbAccountRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbAccountRecordSlotType]))
        {
            $Item             = $This.cimdbAccountRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Bank        { "Account is specifically for a bank"   }
                Creditor    { "Account is a creditor"                }
                Business    { "Account is for a general business"    }
                Supplier    { "Account is for a supplier"            }
                Partner     { "Account is for a business partner"    }
                Unspecified { "Account falls in some other category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Account Status [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbAccountStatusType
{
    Active
    Inactive
    Unspecified
}

Class cimdbAccountStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbAccountStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbAccountStatusType]::$Name
        $This.Name  = [cimdbAccountStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbAccountStatusList
{

    [Object] $Output
    cimdbAccountStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbAccountStatusItem([String]$Name)
    {
        Return [cimdbAccountStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbAccountStatusType]))
        {
            $Item             = $This.cimdbAccountStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Active      { "Account is currently active"                      }
                Inactive    { "Account is (currently inactive/no longer active)" }
                Unspecified { "Account falls into another category"              }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Invoice Record [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInvoiceRecordSlotType
{
    Issue
	Purchase
	Inventory
	IssuePurchase
	IssueInventory
	PurchaseInventory
	All
	Unspecified
}

Class cimdbInvoiceRecordSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInvoiceRecordSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInvoiceRecordSlotType]::$Name
        $This.Name  = [cimdbInvoiceRecordSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInvoiceRecordSlotList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbInvoiceRecordSlotList()
    {
        $This.Index       = 8
        $This.Name        = "Invoice"
        $This.Description = "When invoices are generated, they will fall into one of these record types"
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbInvoiceRecordSlotItem([String]$Name)
    {
        Return [cimdbInvoiceRecordSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInvoiceRecordSlotType]))
        {
            $Item             = $This.cimdbInvoiceRecordSlotItem($Name)
            $Item.Description = Switch ($Name)
            {
                Issue                  { "Sale was a resolved issue"                  }
                Purchase               { "Sale was a purchased item"                  }
                Inventory              { "Sale was from inventory"                    }
                IssuePurchase          { "Sale was an issue and a purchase"           }
                IssueInventory         { "Sale was an issue and inventory"            }
                PurchaseInventory      { "Sale was a purchase, and inventory"         }
                All                    { "Sale was an issue, purchase, and inventory" }
                Unspecified            { "Sale falls into some other category"        }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice.Record.Slot[Item]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Invoice Status [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInvoiceStatusType
{
    Paid
    Unpaid
    Unspecified
}

Class cimdbInvoiceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInvoiceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInvoiceStatusType]::$Name
        $This.Name  = [cimdbInvoiceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInvoiceStatusList
{

    [Object] $Output
    cimdbInvoiceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbInvoiceStatusItem([String]$Name)
    {
        Return [cimdbInvoiceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInvoiceStatusType]))
        {
            $Item             = $This.cimdbInvoiceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Paid        { "Invoice has been paid"               }
                Unpaid      { "Invoice has not been paid"           }
                Unspecified { "Invoice falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Record Controller [+]                                                                          ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>



Class cimdbRecordTypeController
{
    [Object]    $Uid
    [Object] $Output
    cimdbRecordTypeController()
    {
        $This.Uid = $This.cimdbUidRecordSlotList()
        $This.Refresh()
    }
    [Object] cimdbUidRecordSlotList()
    {
        Return [cimdbUidRecordSlotList]::New()
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Client    {    [cimdbClientRecordSlotList]::New() }
            Service   {   [cimdbServiceRecordSlotList]::New() }
            Device    {    [cimdbDeviceRecordSlotList]::New() }
            Issue     {     [cimdbIssueRecordSlotList]::New() }
            Purchase  {  [cimdbPurchaseRecordSlotList]::New() }
            Inventory { [cimdbInventoryRecordSlotList]::New() }
            Expense   {   [cimdbExpenseRecordSlotList]::New() }
            Account   {   [cimdbAccountRecordSlotList]::New() } 
            Invoice   {   [cimdbInvoiceRecordSlotList]::New() }
        }

        Return $Item
    }
    [Object] Slot([String]$Name)
    {
        Return $This.Output | ? Name -eq $Name
    }
    Clear()
    {
        $This.Output = @()
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in $This.Uid.Output.Name)
        {
            $This.Output += $This.New($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Record.Type[Controller]>"
    }
}








Class cimdbRecordHandlerItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]        $Type
    [Object]      $Status
    cimdbRecordHandlerItem([Uint32]$Index,[String]$Name,[String]$Description,[Object]$Type,[Object]$Status)
    {

    }
}

Class cimdbRecordHandlerList
{
    [Object]    $Uid
    [Object] $Output
    cimdbRecordHandlerList()
    {

    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Status Controller [+]                                                                          ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbRecordStatusController
{
    [Object]    $Uid
    [Object] $Output
    cimdbRecordTypeController()
    {
        $This.Uid = $This.cimdbUidRecordSlotList()
        $This.Refresh()
    }
    [Object] cimdbUidRecordSlotList()
    {
        Return [cimdbUidRecordSlotList]::New()
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Client    {    [cimdbClientRecordSlotList]::New() }
            Service   {   [cimdbServiceRecordSlotList]::New() }
            Device    {    [cimdbDeviceRecordSlotList]::New() }
            Issue     {     [cimdbIssueRecordSlotList]::New() }
            Purchase  {  [cimdbPurchaseRecordSlotList]::New() }
            Inventory { [cimdbInventoryRecordSlotList]::New() }
            Expense   {   [cimdbExpenseRecordSlotList]::New() }
            Account   {   [cimdbAccountRecordSlotList]::New() } 
            Invoice   {   [cimdbInvoiceRecordSlotList]::New() }
        }

        Return $Item
    }
    [Object] Slot([String]$Name)
    {
        Return $This.Output | ? Name -eq $Name
    }
    Clear()
    {
        $This.Output = @()
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in $This.Uid.Output.Name)
        {
            $This.Output += $This.New($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Record.Type[Controller]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Mode [+]                                                                                       ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>
Enum cimdbModeSlotType
{
    ViewUid
    EditUid
    ViewClient
    EditClient 
    ViewService
    EditService
    ViewDevice 
    EditDevice
    ViewIssue
    EditIssue
    ViewPurchase
    EditPurchase
    ViewInventory
    EditInventory
    ViewExpense
    EditExpense
    ViewAccount
    EditAccount
    ViewInvoice
    EditInvoice
}

Class cimdbModeSlotItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbModeSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbModeSlotType]::$Name
        $This.Name  = [cimdbModeSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbModeSlotList
{
    [Object] $Output
    cimdbModeSlotList()
    {
        $This.Refresh()
    }
    [Object] cimdbModeSlotItem([String]$Name)
    {
        Return [cimdbModeSlotItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbModeSlotType]))
        {
            $This.Output += $This.cimdbModeSlotItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Mode.Slot[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Panel [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPanelSlotType
{
    UidPanel
    ClientPanel
    ServicePanel
    DevicePanel
    IssuePanel
    PurchasePanel
    InventoryPanel
    ExpensePanel
    AccountPanel
    InvoicePanel
}

Class cimdbPanelSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]        $Type
    cimdbPanelSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPanelSlotType]::$Name
        $This.Name  = [cimdbPanelSlotType]::$Name
        $This.Type  = $This.Name -Replace "Panel",""
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPanelSlotList
{
    [Object] $Output
    cimdbPanelSlotList()
    {
        $This.Refresh()
    }
    [Object] cimdbPanelSlotItem([String]$Name)
    {
        Return [cimdbPanelSlotItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPanelSlotType]))
        {
            $This.Output += $This.cimdbPanelSlotItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Panel.Slot[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Property Types [+]                                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum UidPropertyType
{
    Index
    Slot
    Uid
    Date
    Time
    Record
}
	
Enum ClientPropertyType
{
    Rank
    DisplayName
    Type
    Name
    Dob
    Gender
    Location
    Image
    Phone
    Email
    Device
    Issue
    Invoice
}

Enum ServicePropertyType
{
    Rank
    DisplayName
    Type
    Name
    Description
    Cost
}

Enum DevicePropertyType
{
    Rank
    DisplayName
    Type
    Vendor
    Model
    Specification
    Serial
    Client
}
	
Enum IssuePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Description
    Client
    Device
    Service
    Invoice
}
	
Enum PurchasePropertyType
{
    Rank
    DisplayName
    Type
    Distributor
    URL
    Vendor
    Model
    Specification
    Serial
    IsDevice
    Device
    Cost
}

Enum InventoryPropertyType
{
    Rank
    DisplayName
    Type
    Vendor
    Model
    Specification
    Serial
    Cost
    IsDevice
    Device
}
	
Enum ExpensePropertyType
{
    Rank
    DisplayName
    Type
    Recipient
    IsAccount
    Account
    Cost
}

Enum AccountPropertyType
{
    Rank
    DisplayName
    Type
    Organization
    Object
}
    
Enum InvoicePropertyType
{
    Rank
    DisplayName
    Type
    Client
    Issue
    Purchase
    Inventory
}

Class cimdbPropertyTypeItem
{
    [UInt32]  $Index
    [String] $Source
    [String]   $Name
    cimdbPropertyTypeItem([Uint32]$Index,[String]$Source,[String]$Name)
    {
        $This.Index  = $Index
        $This.Source = $Source
        $This.Name   = $Name
    }
    [String] ToString()
    {
        Return "{0}/{1}" -f $This.Source, $This.Name
    }
}

Class cimdbPropertyTypeList
{
    [Object] $Output
    cimdbPropertyTypeList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [String[]] List()
    {
        Return "Client Service Device Issue Purchase Inventory Expense Account Invoice" -Split " "
    }
    [Object] cimdbPropertyTypeItem([Uint32]$Index,[String]$Source,[String]$Name)
    {
        Return [cimdbPropertyTypeItem]::New($Index,$Source,$Name)
    }
    [Object] New([String]$Source,[String]$Name)
    {
        Return $This.cimdbPropertyTypeItem($This.Output.Count,$Source,$Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Entry in $This.List())
        {
            $ID = "{0}PropertyType" -f $Entry
            ForEach ($Name in [System.Enum]::GetNames($ID))
            {
                $This.Output += $This.New($Entry,$Name)
            }
        }
    }
    [String] ToString()
    {
        Return "<FEModule.Property.Type[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Gender [+]                                                                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbGenderSlotType
{
    Male
    Female
    Unspecified
}

Class cimdbGenderSlotItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbGenderSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbGenderSlotType]::$Name
        $This.Name  = [cimdbGenderSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbGenderSlotList
{
    [Object] $Output
    cimdbGenderSlotList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbGenderSlotItem([String]$Name)
    {
        Return [cimdbGenderSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbGenderSlotType]))
        {
            $This.Output += $This.cimdbGenderSlotItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Gender.Slot[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Phone [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPhoneSlotType
{
    Home
    Mobile
    Office
    Unspecified
}

Class cimdbPhoneSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPhoneSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPhoneSlotType]::$Name
        $This.Name  = [cimdbPhoneSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPhoneSlotList
{
    [Object] $Output
    cimdbPhoneSlotList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbPhoneSlotItem([String]$Name)
    {
        Return [cimdbPhoneSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPhoneSlotType]))
        {
            $Item             = $This.cimdbPhoneSlotItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Home        { "Phone number that constitutes a clients home" }
                Mobile      { "Client's mobile phone"                        }
                Office      { "Client's office or work phone"                }
                Unspecified { "Falls under some other phone number type"     }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Phone.Slot[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Email [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbEmailSlotType
{
    Personal
    Office
    Company
    Unspecified
}

Class cimdbEmailSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbEmailSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbEmailSlotType]::$Name
        $This.Name  = [cimdbEmailSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbEmailSlotList
{
    [Object] $Output
    cimdbEmailSlotList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbEmailSlotItem([String]$Name)
    {
        Return [cimdbEmailSlotItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbEmailSlotType]))
        {
            $Item             = $This.cimdbEmailSlotItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Personal    { "Indicates a clients personal email address"   }
                Office      { "Email address when in the office or at work"  }
                Company     { "Generally applicable for work related emails" }
                Unspecified { "Falls under some other category"              }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Email.Slot[List]>"
    }
}


<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Slot Controller [+]                                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbSlotController
{
    [Object]     $Mode
    [Object]    $Panel
    [Object]   $Record
    [Object] $Property
    [Object]   $Gender
    [Object]    $Phone
    [Object]    $Email
    [Object]  $Chassis
    [Object]    $Issue
    [Object] $Purchase
    [Object]  $Expense
    [Object]  $Account
    [Object]  $Invoice
    cimdbSlotController()
    {
        $This.Mode     = $This.New("Mode")
        $This.Record   = $This.New("Record")
        $This.Panel    = $This.New("Panel")
        $This.Property = $This.New("Property")
        $This.Gender   = $This.New("Gender")
        $This.Phone    = $This.New("Phone")
        $This.Email    = $This.New("Email")
        $This.Chassis  = $This.New("Chassis")
        $This.Issue    = $This.New("Issue")
        $This.Purchase = $This.New("Purchase")
        $This.Expense  = $This.New("Expense")
        $This.Account  = $This.New("Account")
        $This.Invoice  = $This.New("Invoice")
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Mode     {     [cimdbModeSlotList]::New() }
            Record   {   [cimdbRecordSlotList]::New() }
            Panel    {    [cimdbPanelSlotList]::New() }
            Property { [cimdbPropertyTypeList]::New() }
            Gender   {   [cimdbGenderSlotList]::New() }
            Phone    {    [cimdbPhoneSlotList]::New() }
            Email    {    [cimdbEmailSlotList]::New() }
            Chassis  {  [cimdbChassisSlotList]::New() }
            Issue    {    [cimdbIssueSlotList]::New() }
            Purchase { [cimdbPurchaseSlotList]::New() }
            Expense  {  [cimdbExpenseSlotList]::New() }
            Account  {  [cimdbAccountSlotList]::New() }
            Invoice  {  [cimdbInvoiceSlotList]::New() }
        }

        Return $Item
    }
    [Object] Get([String]$Type,[String]$Name)
    {
        Return $This.$Type.Output | ? Name -eq $Name
    }
    [Object[]] List([String]$Type)
    {
        Return $This.$Type.Output
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Slot[Controller]>"
    }
}


Class cimdbSlotController2
{
    [Object] $Record = [cimdbRecordTypeController]::New()
    [Object] $Gender
    [Object] 
}
