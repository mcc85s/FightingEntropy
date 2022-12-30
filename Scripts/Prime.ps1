Class Property
{
    [String]       $Source
    [UInt32]         $Rank
    [String]         $Type
    [String]         $Name
    [Object]        $Value
    Property([String]$Source,[UInt32]$Rank,[String]$Type,[String]$Name)
    {
        $This.Source = $Source
        $This.Rank   = $Rank
        $This.Type   = $Type
        $This.Name   = $Name
    }
}

Class Section
{
    Hidden [UInt32] $Mode
    [UInt32]       $Index
    Hidden [UInt32] $Slot
    [String]        $Name
    [UInt32]       $Count
    [Object]    $Property
    Section([UInt32]$Mode,[UInt32]$Index,[UInt32]$Slot,[String]$Name)
    {
        $This.Mode     = $Mode
        $This.Index    = $Index
        $This.Slot     = $Slot
        $This.Name     = $Name
        $This.Clear()
    }
    Clear()
    {
        $This.Count    = 0
        $This.Property = @( )
    }
    [String] Label()
    {
        Return "[$($This.Name)]"
    }
    AddProperty([Object]$Property)
    {
        $This.Property += $Property
        $This.Count     = $This.Property.Count
    }
}

Class Table
{
    Hidden [UInt32] $Mode
    [String]        $Name
    [UInt32]       $Count
    [Object]     $Section
    Table([UInt32]$Mode,[String]$Name)
    {
        $This.Mode    = $Mode
        $This.Name    = $Name
        $This.Clear()
    }
    Clear()
    {
        $This.Count   = 0
        $This.Section = @( )
    }
    [Object] NewSection([UInt32]$Slot,[String]$Name)
    {
        Return [Section]::New($This.Mode,$This.Output.Count,$Slot,$Name)
    }
    [Object] NewProperty([String]$Source,[UInt32]$Rank,[String]$Type,[String]$Name)
    {
        Return [Property]::New($Source,$Rank,$Type,$Name)
    }
    AddSection([UInt32]$Slot,[String]$Name)
    {
        If ($Name -in $This.Section.Name)
        {
            Throw "Section already exists"
        }

        $This.Section += $This.NewSection($Slot,$Name)
        $This.Count    = $This.Section.Count
    }
    AddProperty([UInt32]$Index,[String]$Type,[String]$Name)
    {
        If ($Index -gt $This.Section.Count)
        {
            Throw "Invalid source index"
        }

        ElseIf ($Name -in $This.Section[$Index].Output.Name)
        {
            Throw "Property already exists"
        }

        $Item         = $This.Section[$Index]
        $Prop         = $This.NewProperty($Item.Name,$Item.Count,$Type,$Name)
        $Item.AddProperty($Prop)
    }
}
