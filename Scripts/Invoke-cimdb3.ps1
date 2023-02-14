# Objective
# =========

# Primary   -> Extract all classes that only instantiate the code behind, not the user interface
# Secondary -> Extend the classes and types within each category

Enum DatabaseType
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

Class DatabaseSlot
{
    [UInt32]       $Index
    [String]        $Type
    [String] $Description
    DatabaseSlot([String]$Type)
    {
        $This.Index = [UInt32][DatabaseType]::$Type
        $This.Type  = $Type
    }
    [String] ToString()
    {
        Return $This.Type
    }
}

Class DatabaseList
{
    [String]   $Name
    [Uint32]  $Count
    [Object] $Output
    DatabaseList()
    {
        $This.Name   = "DatabaseList"
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

        ForEach ($Type in [System.Enum]::GetNames([DatabaseType]))
        {
            $This.Add($Type)
        }
    }
    [Object] DatabaseSlot([String]$Type)
    {
        Return [DatabaseSlot]::New($Type)
    }
    Add([String]$Type)
    {
        $Item             = $This.DatabaseSlot($Type)
        $Item.Description = Switch ($Item.Type)
        {
            Client    
            { 
                "Tracks identity, phone number(s), email address(es), device(s), issue(s), and invoice(s)"
            }
            Service   
            { 
                "Tracks the name, description, rate/price of labor"
            }
            Device    
            { 
                "Information such as make, model, serial number, etc."
            }
            Issue     
            { 
                "Particular notes and statuses about a particular device"
            }
            Purchase  
            { 
                "Item or service required for an issue or sale"
            }
            Inventory 
            { 
                "Item specifically meant for sale"
            }
            Expense   
            { 
                "Good(s), service(s), or bill(s)"
            }
            Account   
            { 
                "Monetary silo or information for a particular vendor or external business"
            }
            Invoice   
            { 
                "Representation of a sale"
            }
        }

        $This.Output += $Item
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseList>"
    }
}

Class DatabaseItemList
{
    [String]   $Name
    [UInt32]  $Count
    [Object] $Output
    DatabaseItemList([String]$Name)
    {
        $This.Name   = $Name
        $This.Clear()
    }
    Clear()
    {
        $This.Count  = 0
        $This.Output = @( )
    }
    Add([Object]$Object)
    {
        $This.Output += $Object
        $This.Count   = $This.Output.Count
    }
    [String] ToString()
    {
        Return "({0}) <{1}>" -f $This.Count, $This.Name
    }
}

Class DatabasePerson
{
    [String] $DisplayName
    [String]   $GivenName
    [String]    $Initials
    [String]     $Surname
    [String]   $OtherName
    DatabasePerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.GivenName   = $GivenName
        $This.Initials    = $Initials
        $This.Surname     = $Surname
        $This.OtherName   = $OtherName
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $Return = $Null
        If ($This.Initials -eq "" -and $This.OtherName -eq "")
        {
            $Return = "{0} {1}" -f $This.GivenName, $This.Surname
        }

        ElseIf ($This.Initials -eq "" -and $This.OtherName -ne "")
        {
            $Return = "{0} {1} {2}" -f $This.GivenName, $This.Surname, $This.OtherName
        }

        ElseIf ($This.Initials -ne "" -and $This.Othername -eq "")
        {
            $Return = "{0} {1}. {2}" -f $This.GivenName, $This.Initials, $This.Surname
        }

        ElseIf ($This.Initials -ne "" -and $This.Othername -ne "")
        {
            $Return = "{0} {1}. {2} {3}" -f $This.GivenName, $This.Initials, $This.Surname, $This.OtherName
        }

        Return $Return
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

Class DatabaseDob
{
    [String]   $Dob
    [UInt32] $Month
    [UInt32]  $Date
    [UInt32]  $Year
    DatabaseDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        $This.Month = $Month
        $This.Date  = $Date
        $This.Year  = $Year
        $This.Dob   = "{0:d2}/{1:d2}/{2:d4}" -f $This.Month, $This.Date, $This.Year
    }
    [String] ToString()
    {
        Return $This.Dob
    }
}

Class DatabaseLocation
{
    [String] $StreetAddress
    [String]          $City
    [String]         $State
    [String]    $PostalCode
    [String]       $Country
    DatabaseLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        $This.StreetAddress = $StreetAddress
        $This.City          = $City
        $This.State         = $State
        $This.PostalCode    = $PostalCode
        $This.Country       = $Country
    }
    [String] ToString()
    {
        Return "{0}`n{1}, {2} {3}" -f $This.StreetAddress, $This.City, $This.State, $This.PostalCode
    }
}

Class DatabasePhone
{
    [UInt32]  $Index
    [String]   $Type
    [String] $Number
    DatabasePhone([UInt32]$Index,[String]$Type,[String]$Number)
    {
        $This.Index  = $Index
        $This.Type   = $Type
        $This.Number = $Number
    }
    [String] ToString()
    {
        Return $This.Number
    }
}

Class DatabaseEmail
{
    [UInt32] $Index
    [String]  $Type
    [String] $Email
    DatabaseEmail([UInt32]$Index,[String]$Type,[String]$Email)
    {
        $This.Index = $Index
        $This.Type  = $Type
        $This.Email = $Email
    }
    [String] ToString()
    {
        Return $This.Email
    }
}

Class TemplateClient
{
    [Object]   $Person
    [Object]      $Dob
    [String]   $Gender
    [Object] $Location
    [Object]    $Phone
    [Object]    $Email
    TemplateClient()
    {
        $This.Phone = $This.DatabaseItemList("Phone")
        $This.Email = $This.DatabaseItemList("Email")
    }
    [Object] DatabasePerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        Return [DatabasePerson]::New($GivenName,$Initials,$Surname,$OtherName)
    }
    [Object] DatabaseDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        Return [DatabaseDob]::New($Month,$Date,$Year)
    }
    [Object] DatabaseLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        Return [DatabaseLocation]::New($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    [Object] DatabaseItemList([String]$Name)
    {
        Return [DatabaseItemList]::New($Name)
    }
    [Object] DatabasePhone([UInt32]$Index,[String]$Type,[String]$Number)
    {
        Return [DatabasePhone]::New($Index,$Type,$Number)
    }
    [Object] DatabaseEmail([UInt32]$Index,[String]$Type,[String]$Email)
    {
        Return [DatabaseEmail]::New($Index,$Type,$Email)
    }
    [UInt32] Status()
    {
        $C = 0
        If (!!$This.Person)
        {
            $C ++
        }

        If (!!$This.Dob)
        {
            $C ++
        }

        If (!!$This.Gender)
        {
            $C ++
        }

        If (!!$This.Location)
        {
            $C ++
        }
        
        If ($This.Phone.Count -gt 0)
        {
            $C ++
        }

        If ($This.Email.Count -gt 0)
        {
            $C ++
        }

        Return [UInt32]($C -eq 6)
    }
    SetPerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.Person   = $This.DatabasePerson($GivenName,$Initials,$Surname,$OtherName)
    }
    SetDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        $This.Dob      = $This.DatabaseDob($Month,$Date,$Year)
    }
    SetGender([UInt32]$Slot)
    {
        $This.Gender   = @("Male","Female")[$Slot]
    }
    SetLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        $This.Location = $This.DatabaseLocation($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    AddPhone([String]$Type,[String]$Number)
    {
        If ($Number -in $This.Phone.Output.Number)
        {
            Throw "Number already exists"
        }

        $This.Phone.Add($This.DatabasePhone($This.Phone.Count,$Type,$Number))
    }
    AddEmail([String]$Type,[String]$Email)
    {
        If ($Email -in $This.Email.Output.Email)
        {
            Throw "Number already exists"
        }

        $This.Email.Add($This.DatabaseEmail($This.Email.Count,$Type,$Email))
    }
}

Class DatabaseClient
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # Numerical index in all client objects
    [String]   $DisplayName # Certain formula for displaying the unique content of the object
    [Object]          $Name # Object -> (DisplayName, GivenName, Initials, Surname, OtherName)
    [Object]           $Dob # Object -> (Dob , Month , Date , Year)
    [String]        $Gender # Might make this an object, not sure.
    [Object]      $Location # Object -> (StreetAddress, City, State, PostalCode, Country)
    [Object]         $Image # Bitmap/Jpg/Graphic
    [Object]         $Phone # Object -> List of phone numbers, with name, type, etc. (requires at least 1) 
    [Object]         $Email # Object -> List of Email addresses, name, type, etc.    (requires at least 1)
    [Object]        $Device # Object -> List of devices, may be empty                (no requirements)
    [Object]         $Issue # Object -> List of issues, may be empty                 (no requirements)
    [Object]       $Invoice # Object -> List of invoices, may be empty               (no requirements)
    DatabaseClient([Object]$Uid)
    {
        $This.Uid    = $Uid.Uid
        $This.Clear() 
    }
    Clear()
    {
        $This.Phone   = $This.DatabaseItemList("Phone")
        $This.Email   = $This.DatabaseItemList("Email")
        $This.Device  = $This.DatabaseItemList("Device")
        $This.Issue   = $This.DatabaseItemList("Issue")
        $This.Invoice = $This.DatabaseItemList("Invoice")
    }
    [Object] DatabaseItemList([String]$Name)
    {
        Return [DatabaseItemList]::New($Name)
    }
    Apply([Object]$Template)
    {
        If ($Template.GetType().Name -ne "TemplateClient")
        {
            Throw "Invalid client template"
        }

        $This.Name        = $Template.Person
        $This.Dob         = $Template.Dob
        $This.Gender      = $Template.Gender
        $This.Location    = $Template.Location
        $This.Phone       = $Template.Phone
        $This.Email       = $Template.Email
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $ID               = $This.Name
        $Return           = $Null
        If ($ID.Initials -eq "" -and $ID.OtherName -eq "")
        {
            $Return       = "{0}, {1}" -f $This.Surname, $This.GivenName
        }

        ElseIf ($ID.Initials -eq "" -and $ID.OtherName -ne "")
        {
            $Return       = "{0} {1}, {2}" -f $ID.Surname, $ID.OtherName, $ID.GivenName
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -eq "")
        {
            $Return       = "{0} {1} {2}." -f $ID.Surname, $ID.GivenName, $ID.Initials
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -ne "")
        {
            $Return       = "{0} {1}, {2} {3}." -f  $ID.Surname, $ID.OtherName, $ID.GivenName, $ID.Initials
        }

        Return $Return
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseClient>"
    }
}

Class DatabaseService
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # Numerical index in all client objects
    [String]   $DisplayName # Certain formula for displaying the unique content of the object
    [String]          $Name # Service name
    [String]   $Description # Description
    [Float]           $Cost # How much the service costs
    DatabaseService([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseService>"
    }
}

Class DatabaseDevice
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [String]   $DisplayName # 
    [String]       $Chassis # 
    [String]        $Vendor # 
    [String]         $Model # 
    [String] $Specification # 
    [String]        $Serial # 
    [String]        $Client # Uid/reference to the client object
    DatabaseDevice([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseDevice>"
    }
}

Class DatabaseIssue
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [Object]   $DisplayName # 
    [Object]        $Status # 
    [String]   $Description # 
    [String]        $Client # Uid/reference to the client object
    [String]        $Device # Uid/reference to the client object
    [Object]       $Service # Object -> List of services,  may be empty               (no requirements)
    [Object]          $List # Object -> List of purchases, may be empty               (no requirements)
    DatabaseIssue([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseIssue>"
    }
}

Class DatabasePurchase
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [Object]   $DisplayName # 
    [Object]   $Distributor # 
    [Object]           $URL # 
    [String]        $Vendor # 
    [String]         $Model # 
    [String] $Specification # 
    [String]        $Serial # 
    [Bool]        $IsDevice # 
    [String]        $Device # 
    [Object]          $Cost # 
    DatabasePurchase([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabasePurchase>"
    }
}

Class DatabaseInventory
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [String]        $Vendor #
    [String]         $Model #
    [String]        $Serial #
    [Object]         $Title #
    [Object]          $Cost #
    [Bool]        $IsDevice #
    [Object]        $Device #
    DatabaseInventory([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseInventory>"
    }
}

Class DatabaseExpense
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [Object]   $DisplayName #
    [Object]     $Recipient #
    [Object]     $IsAccount #
    [Object]       $Account #
    [Object]          $Cost #
    DatabaseExpense([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseExpense>"
    }
}

Class DatabaseAccount
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [Object]        $Object #
    DatabaseAccount([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseAccount>"
    }
}

Class DatabaseInvoice
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [UInt32]          $Mode #
    [Object]        $Client #
    [Object]         $Issue #
    [Object]      $Purchase #
    [Object]     $Inventory #
    DatabaseInvoice([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseInvoice>"
    }
}

Class DatabaseUid
{
    [Object]    $Uid
    [Object]   $Type
    [UInt32]  $Index
    [Object]   $Date
    [Object]   $Time
    [UInt32]   $Sort
    [UInt32]   $Rank
    [Object] $Record
    DatabaseUid([Object]$Slot,[UInt32]$Index)
    {
        $This.Uid    = $This.NewGuid()
        $This.Type   = $Slot
        $This.Index  = $Index
        $This.Date   = $This.GetDate()
        $This.Time   = $This.GetTime()
        $This.Sort   = 0
    }
    [Object] GetDate()
    {
        Return [DateTime]::Now.ToString("MM/d/yyyy")
    }
    [Object] GetTime()
    {
        Return [DateTime]::Now.ToString("HH:mm:ss")
    }
    [Object] NewGuid()
    {
        Return [Guid]::NewGuid()
    }
    [String] ToString()
    {
        Return $This.Uid
    }
}

# [Start development controller]

Class DevelController
{
    [Object]   $List
    [Object] $Output
    DevelController()
    {
        $This.List = $This.DatabaseList()
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @()
    }
    [Object] DatabaseList()
    {
        Return [DatabaseList]::New().Output
    }
    [Object] Uid([UInt32]$Slot,[UInt32]$Index)
    {
        If ($Slot -notin $This.List.Index)
        {
            Throw "Invalid slot"
        }

        Return [DatabaseUid]::New($This.List[$Slot],$Index)
    }
    [Object] DatabaseClient([Object]$Uid)
    {
        Return [DatabaseClient]::New($Uid)
    }
    [Object] TemplateClient()
    {
        Return [TemplateClient]::New()
    }
    [Object] DatabaseService([Object]$Uid)
    {
        Return [DatabaseService]::New($Uid)
    }
    [Object] DatabaseDevice([Object]$Uid)
    {
        Return [DatabaseDevice]::New($Uid)
    }
    [Object] DatabaseIssue([Object]$Uid)
    {
        Return [DatabaseIssue]::New($Uid)
    }
    [Object] DatabasePurchase([Object]$Uid)
    {
        Return [DatabasePurchase]::New($Uid)
    }
    [Object] DatabaseInventory([Object]$Uid)
    {
        Return [DatabaseInventory]::New($Uid)
    }
    [Object] DatabaseExpense([Object]$Uid)
    {
        Return [DatabaseExpense]::New($Uid)
    }
    [Object] DatabaseAccount([Object]$Uid)
    {
        Return [DatabaseAccount]::New($Uid)
    }
    [Object] DatabaseInvoice([Object]$Uid)
    {
        Return [DatabaseInvoice]::New($Uid)
    }
    [Object] GetUid([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        Return $This.Output[$Index]
    }
    [Object] GetUid([String]$Uid)
    {
        If ($Uid -notin $This.Output.Uid)
        {
            Throw "Invalid UID"
        }

        Return $This.Output | ? Uid -eq $Uid
    }
    NewUid([UInt32]$Slot)
    {
        If ($Slot -gt $This.List.Count)
        {
            Throw "Invalid slot"
        }

        $Item         = $This.Uid($Slot,$This.Count)
        $This.Output += $Item
        $This.Count   = $This.Output.Count
    }
    New([Object]$Uid)
    {
        $Slot         = $Uid.Type
        $Uid.Record   = $This.$Slot($Uid)
    }
    NewClient([Object]$Client)
    {
        If ($Client.Status() -ne 1)
        {
            Throw "Client template status not complete"
        }

        $Count        = ($This.Output | ? Type -match Client).Count
        $Uid          = $This.Uid(0,$Count)
        $Uid.Record   = $This.DatabaseClient($Uid)
        $Uid.Record.Apply($Client)

        $This.Output += $Uid
    }
    NewService([Object]$Uid)
    {

    }
    NewDevice([Object]$Uid)
    {

    }
    NewIssue([Object]$Uid)
    {

    }
    NewPurchase([Object]$Uid)
    {

    }
    NewInventory([Object]$Uid)
    {

    }
    NewExpense([Object]$Uid)
    {

    }
    NewAccount([Object]$Uid)
    {

    }
    NewInvoice([Object]$Uid)
    {

    }
}

    $Ctrl     = [DevelController]::New()
    $Template = $Ctrl.TemplateClient()
    $Template.SetPerson("Michael","C","Cook","Sr.")
    $Template.SetDob(5,24,1985)
    $Template.SetGender(0)
    $Template.SetLocation("201D Halfmoon Circle","Clifton Park","NY",12065,"US")
    $Template.AddPhone("Home","518-406-8569")
    $Template.AddEmail("Personal","michael.c.cook.85@gmail.com")
    $Ctrl.NewClient($Template)
