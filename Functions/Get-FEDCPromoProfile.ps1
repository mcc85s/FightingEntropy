Function Get-FEDCPromoProfile
{
    [CmdLetbinding()]
    Param([Parameter(Mandatory)][UInt32]$Mode = 0)

    Class _Type
    {
        [String]                  $Name
        [Bool]               $IsEnabled
        [Object]                 $Value

        _Type([String]$Name,[Bool]$IsEnabled)
        {
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
        }
    }

    Class _Text
    {
        [String]                  $Name
        [Bool]               $IsEnabled
        [String]                  $Text

        _Text([String]$Name,[Bool]$IsEnabled)
        {
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
            $This.Text      = ""
        }
    }

    Class _Role
    {
        [String] $Name
        [Bool]   $IsEnabled
        [Bool]   $IsChecked

        _Role([String]$Name,[Bool]$IsEnabled,[Bool]$IsChecked)
        {
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
            $This.IsChecked = $IsChecked
        }
    }

    Class _Profile
    {
        [UInt32]              $Mode
        Hidden [Hashtable]    $Tags = @{ 

            Slot                    = "Forest Tree Child Clone" -Split " "
            Type                    = "ForestMode DomainMode ReplicationSourceDC ParentDomainName" -Split " "
            Text                    = "Parent{0} {0} Domain{1} SiteName New{0} NewDomain{1}" -f "DomainName","NetBIOSName" -Split " "
            Role                    = "InstallDns CreateDnsDelegation CriticalReplicationOnly NoGlobalCatalog" -Split " "
        }

        [Object]              $Slot
        [Object]              $Type
        [Object]              $Text
        [Object]              $Role

        _Profile([UInt32]$Mode)
        {
            If ( $Mode -notin 0..3 )
            {
                Throw "Invalid Entry"
            }

            $This.Mode              = $Mode
            $This.Slot              = $This.Tags.Slot[$Mode]
            $This.Type              = $This.Tags.Type | % { $This.GetFEDCPromoType($Mode,$_) }
            $This.Text              = $This.Tags.Text | % { $This.GetFEDCPromoText($Mode,$_) }
            $This.Role              = $This.Tags.Role | % { $This.GetFEDCPromoRole($Mode,$_) }
        }

        [Object] GetFEDCPromoType([UInt32]$Mode,[String]$Type)
        {
            $Item                   = Switch($Type)
            {
                ForestMode            {1,0,0,0}
                DomainMode            {1,1,1,0}
                ParentDomainName      {0,1,1,0}
                ReplicationSourceDC   {0,0,0,1}
            }

            Return @([_Type]::New($Type,$Item[$Mode]) )
        }

        [Object] GetFEDCPromoText([UInt32]$Mode,[String]$Type)
        {
            $Item                   = Switch($Type)
            {
                ParentDomainName      {0,1,1,0}
	            DomainName            {1,0,0,1}
	            DomainNetBIOSName     {1,0,0,0}
	            SiteName              {0,1,1,1}
	            NewDomainName         {0,1,1,0}
	            NewDomainNetBIOSName  {0,1,1,0}
            }

            Return @([_Text]::New($Type,$Item[$Mode]))
        }

        [Object] GetFEDCPromoRole([UInt32]$Mode,[String]$Type)
        {
            $Item                   = Switch($Type)
            {
                InstallDNS              {(1,1,1,1),(1,1,1,1)}
                CreateDNSDelegation     {(1,1,1,1),(0,0,1,0)}
                NoGlobalCatalog         {(0,1,1,1),(0,0,0,0)}
                CriticalReplicationOnly {(0,0,0,1),(0,0,0,0)}
            }

            Return @([_Role]::New($Type,$Item[0][$Mode],$Item[1][$Mode]))
        }
    }

    [_Profile]::New($Mode)
}
