

    # // _____________________________________________________________________________________
    # // | Scenario        : Microsoft account -> UNUSUAL sign-in activity...                |
    # // | Description     : Microsoft detected something UNUSUAL about a recent sign-in to: |
    # // |                   Microsoft account XXXX@XXXXXX.com                               |
    # // | Country/region  : United States                                                   |
    # // | IP address      : 8.48.253.109                                                    |
    # // | Date            : 8/23/2022 9:15 PM (GMT)                                         |
    # // | Platform        : -                                                               |
    # // | Browser         : Chrome                                                          |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // __________________________________________________________________________________________
    # // | Uh-oh. Microsoft detected something UNUSUAL about a recent sign-in...                  |
    # // | What can someone even DO about something like that...?                                 |
    # // | Time to whip out the trusty ol' WHOIS for that IP Address, and then make it COOL       |
    # // | looking with a graphical user interface.                                               |
    # // | Show people how the classes in PowerShell work, and then modify the GUI                |
    # // | I have a utility that I already developed which sorta does this ->                     |
    # // | https://github.com/mcc85s/FightingEntropy/blob/main/Scripts/Resolve-LogAddressList.ps1 |
    # // | However, that was designed for scanning IP addresses on an OPNsense firewall.          |
    # // | Now I wanna look at details for that IP above.                                         |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _________________________________________________________________
    # // | Class for the Xaml Window (Not exactly CURRENT, but it'll do) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object]              $Types
        [Object]               $Node
        [Object]                 $IO
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 
                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 
            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If ( !$Xaml )
            {
                Throw "Invalid XAML Input"
            }
            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Types              = @( )
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)
            ForEach ($I in 0..($This.Names.Count-1))
            {
                $Name                = $This.Names[$I]
                $Item                = $This.IO.FindName($Name)
                If ($Item -notin $This.Types)
                {
                    $This.Types     += [DGList]::New($Name,$Item.GetType().Name)
                }
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }
 
    # // __________________________________
    # // | Meant for splatting key/values |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class DGList
    {
        [String] $Name
        [Object] $Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value 
        }
    }

    # // ________________________________________________________________________________
    # // | This is the GUI that we'll be editing to bind with the PowerShell class data |
    # // | What I'm about to update                                                     |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # ( Get-Content $home\Desktop\WhoisUtility.xaml ).Replace("'",'"') | % { "        '$_'," } | Set-Clipboard
    Class WhoisUtilityGUI
    {
        Static [String] $Tab = @(        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Log Address List" Width="800" Height="480" Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="CanResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="DataGridCell">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="30"/>',
        '            <Setter Property="FontWeight" Value="Semibold"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Background" Value="#DFFFBA"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="{x:Type TextBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Foreground" Value="#000000"/>',
        '            <Setter Property="TextWrapping" Value="Wrap"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '        </Style>',
        '        <Style TargetType="TextBox" x:Key="Block">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontFamily" Value="Consolas"/>',
        '            <Setter Property="Height" Value="180"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '            <Setter Property="AcceptsReturn" Value="True"/>',
        '            <Setter Property="VerticalAlignment" Value="Top"/>',
        '            <Setter Property="TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Top"/>',
        '            <Setter Property="VerticalScrollBarVisibility" Value="Visible"/>',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="AutoGenerateColumns" Value="False"/>',
        '            <Setter Property="AlternationCount" Value="3"/>',
        '            <Setter Property="HeadersVisibility" Value="Column"/>',
        '            <Setter Property="CanUserResizeRows" Value="False"/>',
        '            <Setter Property="CanUserAddRows" Value="False"/>',
        '            <Setter Property="IsReadOnly" Value="True"/>',
        '            <Setter Property="IsTabStop" Value="True"/>',
        '            <Setter Property="IsTextSearchEnabled" Value="True"/>',
        '            <Setter Property="SelectionMode" Value="Extended"/>',
        '            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>',
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" Value="0">',
        '                    <Setter Property="Background" Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" Value="#FFC5E5EC"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="2">',
        '                    <Setter Property="Background" Value="#FFFDE1DC"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid Margin="5">',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="220"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <Grid Grid.Row="0">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="200"/>',
        '                    <ColumnDefinition Width="10"/>',
        '                    <ColumnDefinition Width="100"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="100"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label Grid.Column="0" Content="Address List"/>',
        '                <Border   Grid.Column="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                <Label Grid.Column="2" Content="IP Address"/>',
        '                <TextBox Grid.Column="3" Name="IPAddress"/>',
        '                <Button Grid.Column="4" Name="AddIpAddress" Content="Add"/>',
        '            </Grid>',
        '            <DataGrid Grid.Row="1" Name="AddressList">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="Index"      Binding="{Binding Index}"      Width="40"/>',
        '                    <DataGridTextColumn Header="IPAddress"  Binding="{Binding IPAddress}"  Width="150"/>',
        '                    <DataGridTextColumn Header="Handle"     Binding="{Binding Handle}"     Width="125"/>',
        '                    <DataGridTextColumn Header="Name"       Binding="{Binding Name}"       Width="200"/>',
        '                    <DataGridTextColumn Header="Url"        Binding="{Binding Url}"        Width="250"/>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '        </Grid>',
        '        <Grid Grid.Row="1">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="275"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Grid Grid.Column="0">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <Label Grid.Row="0" Content="Location"/>',
        '                <DataGrid Grid.Row="1" Name="LocationList">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="100"/>',
        '                        <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '            </Grid>',
        '            <Grid Grid.Column="1">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="90"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label    Grid.Row="0" Grid.Column="1" Content="Date"/>',
        '                    <Label    Grid.Row="0" Grid.Column="2" Content="Time Zone"/>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="Registration"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="1" Name="RegDate"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="2" Name="RegZone"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="Update"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Name="UpdateDate"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="2" Name="UpdateZone"/>',
        '                </Grid>',
        '                <GroupBox Grid.Row="1" Header="[Action]">',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="2*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <TextBox Grid.Column="0" Name="Coordinates"/>',
        '                        <Button Grid.Column="1" Content="Start" Name="Start"/>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </Grid>',
        '        </Grid>',
        '    </Grid>',
        '</Window>')
    }

    # // __________________________________________________________________
    # // | Class to organize United States states (not international yet) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class States
    {
        Static [Hashtable] $List            = @{

            "Alabama"                       = "AL" ; "Alaska"                        = "AK" ;
            "Arizona"                       = "AZ" ; "Arkansas"                      = "AR" ;
            "California"                    = "CA" ; "Colorado"                      = "CO" ;
            "Connecticut"                   = "CT" ; "Delaware"                      = "DE" ;
            "Florida"                       = "FL" ; "Georgia"                       = "GA" ;
            "Hawaii"                        = "HI" ; "Idaho"                         = "ID" ;
            "Illinois"                      = "IL" ; "Indiana"                       = "IN" ;
            "Iowa"                          = "IA" ; "Kansas"                        = "KS" ;
            "Kentucky"                      = "KY" ; "Louisiana"                     = "LA" ;
            "Maine"                         = "ME" ; "Maryland"                      = "MD" ;
            "Massachusetts"                 = "MA" ; "Michigan"                      = "MI" ;
            "Minnesota"                     = "MN" ; "Mississippi"                   = "MS" ;
            "Missouri"                      = "MO" ; "Montana"                       = "MT" ;
            "Nebraska"                      = "NE" ; "Nevada"                        = "NV" ;
            "New Hampshire"                 = "NH" ; "New Jersey"                    = "NJ" ;
            "New Mexico"                    = "NM" ; "New York"                      = "NY" ;
            "North Carolina"                = "NC" ; "North Dakota"                  = "ND" ;
            "Ohio"                          = "OH" ; "Oklahoma"                      = "OK" ;
            "Oregon"                        = "OR" ; "Pennsylvania"                  = "PA" ;
            "Rhode Island"                  = "RI" ; "South Carolina"                = "SC" ;
            "South Dakota"                  = "SD" ; "Tennessee"                     = "TN" ;
            "Texas"                         = "TX" ; "Utah"                          = "UT" ;
            "Vermont"                       = "VT" ; "Virginia"                      = "VA" ;
            "Washington"                    = "WA" ; "West Virginia"                 = "WV" ;
            "Wisconsin"                     = "WI" ; "Wyoming"                       = "WY" ;
            "American Samoa"                = "AS" ; "District of Columbia"          = "DC" ;
            "Guam"                          = "GU" ; "Marshall Islands"              = "MH" ;
            "Northern Mariana Island"       = "MP" ; "Puerto Rico"                   = "PR" ;
            "Virgin Islands"                = "VI" ; "Armed Forces Africa"           = "AE" ;
            "Armed Forces Americas"         = "AA" ; "Armed Forces Canada"           = "AE" ;
            "Armed Forces Europe"           = "AE" ; "Armed Forces Middle East"      = "AE" ;
            "Armed Forces Pacific"          = "AP" ;

        }
        Static [String] GetName([String]$Code)
        {
            Return @( [States]::List | % GetEnumerator | ? Value -match $Code | % Name )
        }
        Static [String] GetCode([String]$Name)
        {
            Return @( [States]::List | % GetEnumerator | ? Name -eq $Name | % Value )
        }
        States()
        {

        }
    }

    # // __________________________________________
    # // | Returns potential zip code information |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ZipEntry
    {
        [String]       $Zip
        [String]      $Type
        [String]      $Name
        [String]     $State
        [String]   $Country
        [String]      $Long
        [String]       $Lat
        ZipEntry([String]$Line)
        {
            $String         = $Line -Split "`t"
            
            $This.Zip       = $String[0]
            $This.Type      = @("UNIQUE","STANDARD","PO_BOX","MILITARY")[$String[1]]
            $This.Name      = $String[2]
            $This.State     = $String[3]
            $This.Country   = $String[4]
            $This.Long      = $String[5]
            $This.Lat       = $String[6]
        }
        ZipEntry([UInt32]$Zip)
        {
            $This.Zip       = $Zip
            $This.Type      = "Invalid"
            $This.Name      = "N/A"
            $This.State     = "N/A"
            $This.Country   = "N/A"
            $This.Long      = "N/A"
            $This.Lat       = "N/A"
        }
    }

    # // __________________________________________________
    # // | Converts the zipcode file into a usable object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ZipStack
    {
        [String]      $Path
        [Object]   $Content
        [Object]     $Stack
        ZipStack([String]$Path)
        {
            $This.Path    = $Path
            $This.Content = Get-Content $Path | ? Length -gt 0
            $This.Stack   = @{ }
            $X            = 0
            ForEach ( $Item in $This.Content )
            {
                $This.Stack.Add($Item.Substring(0,5),$X)
                $X ++
            }
        }
        [Object] Zip([String]$Zip)
        {
            $Index = $This.Stack["$Zip"]
            If (!$Index)
            {
                Return [ZipEntry][UInt32]$Zip
            }

            Return [ZipEntry]$This.Content[$Index]
        }
    }

    # // ________________________________________________________________________________
    # // | Extracts a string date with an offset, and converts to DateTime and Timespan |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class DateTimeZone
    {
        [Object] $Date
        [Object] $Offset
        DateTimeZone([String]$Date)
        {
            $This.Offset = [Timespan]$Date.Substring(19)
            $This.Date   = [DateTime]$Date
        }
    }

    # // __________________________________________________
    # // | Takes action on input from an IP lookup result |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WhoisOrgRef
    {
        [String] $Handle
        [String] $Name
        [Object] $Url
        Hidden [Object] $Object
        [Object] $Registration
        [Object] $Update
        [Object] $Location
        WhoisOrgRef([Object]$Org)
        {
            $This.Handle     = $Org.Handle
            $This.Name       = $Org.Name
            $This.Url        = $Org.'#text'
            Try
            {
                $This.Object = Invoke-RestMethod $This.Url -EA 0
            }
            Catch
            {
                $This.Object = $Null
            }

            If ($This.Object)
            {
                $This.Registration = [DateTimeZone]$This.Object.Org.RegistrationDate
                $This.Update       = [DateTimeZone]$This.Object.Org.UpdateDate
            }
        }
        SetLocation([Object]$Zipstack)
        {
            $This.Location = $Zipstack.Zip($This.Object.Org.PostalCode)
        }
    }

    # // ___________________________________________________________________
    # // | Flattens all of the various objects returned from Whois Lookup. |
    # // | This will be the desired object we'll want to bind to the GUI   | 
    # // | in order to view.                                               |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WhoisRegistrar
    {
        [UInt32]               $Index
        [IPAddress]        $IPAddress
        [String]              $Status
        [String]              $Handle
        [String]                $Name
        [Object]                 $Url
        Hidden [Object] $Registration
        [Object]             $RegDate
        [Object]             $RegZone
        Hidden [Object]       $Update
        [Object]          $UpdateDate
        [Object]          $UpdateZone
        Hidden [Object]     $Location
        [String]                 $Zip
        [String]                $Type
        [String]                $City
        [String]               $State
        [String]             $Country
        [Float]                 $Long
        [Float]                  $Lat
        WhoisRegistrar([UInt32]$Index,[Object]$IP)
        {
            $This.Index        = $Index
            $This.IPAddress    = [IPAddress]$IP.IPAddress
            $This.Status       = $IP.Status
            If ($IP.Status -eq "+")
            {
                $Reg               = $IP.Org.Registration
                $Upd               = $IP.Org.Update
                $Loc               = $IP.Org.Location
                $This.Handle       = $IP.Org.Handle
                $This.Name         = $IP.Org.Name
                $This.Url          = $IP.Org.Url
                $This.Registration = $Reg
                $This.RegDate      = $Reg.Date
                $This.RegZone      = $Reg.Offset
                $This.Update       = $Upd
                $This.UpdateDate   = $Upd.Date
                $This.UpdateZone   = $Upd.Offset
                $This.Location     = $Loc
                $This.Zip          = $Loc.Zip
                $This.Type         = $Loc.Type
                $This.City         = $Loc.Name
                $This.State        = $Loc.State
                $This.Country      = $Loc.Country
                $This.Long         = $Loc.Long
                $This.Lat          = $Loc.Lat
            }
        }
    }

    # // ___________________________________________________
    # // | This returns the initial IP whois lookup result |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class IPResult
    {
        Hidden [Object] $Object
        [String] $IPAddress
        [String] $Status
        [Object] $Org
        IPResult([String]$IPAddress)
        {
            If ($IPAddress -notmatch "^(\d+\.){3}\d+$")
            {
                Throw "Invalid IP Address (IPV4 req'd)"
            }

            $This.IPAddress     = $IPAddress
            $This.Object        = Invoke-RestMethod "http://whois.arin.net/rest/ip/$Ipaddress" -Headers @{ Accept = "application/xml" } -EA 0

            If (!$This.Object)
            {
                $This.Status    = "-"
            }
            If ($This.Object)
            {
                $This.Status    = "+"
                $This.Org       = [WhoisOrgRef]$This.Object.Net.OrgRef
            }
        }
    }

    # // ________________________________________________________________________
    # // | This is the controller class that basically orchestrates everything. |
    # // | We want to modify THIS class as well as the GUI, so that this class  |
    # // | will effectively be able to control the GUI                          |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WhoisControl
    {
        [Object] $Module
        Hidden [Object] $Zipstack
        [Object] $Xaml
        [Object] $Output
        WhoisControl()
        {
            $This.Module       = Get-FEModule
            $Path              = Get-ChildItem $This.Module.Path -Recurse | ? Name -eq zipcode.txt | % Fullname
            $This.Zipstack     = [Zipstack]::New($Path)
            $This.Xaml         = [XamlWindow][WhoisUtilityGUI]::Tab
            $This.Output       = @( )
        }
        [Object] Zip([String]$Zip)
        {
            Return $This.Zipstack.Zip($Zip)
        }
        ResolveIP([String]$IPAddress)
        {
            If ($IPAddress -notmatch "^(\d+\.){3}\d+$")
            {
                Throw "Invalid IP Address (IPV4 req'd)"
            }

            Write-Host "Searching [~] $IPAddress"
            $Result = [IPResult]::New($IPAddress)
            If ($Result)
            {
                Write-Host "Found [+] $IPAddress"
                $Result.Org.SetLocation($This.Zipstack)
                $Return = [WhoisRegistrar]::New($This.Output.Count,$Result)
                If ($Return.IPAddress -notin $This.Output.IPAddress)
                {
                    $This.Output += $Return
                    Write-Host "Adding [+] $($Return.IPAddress)"
                }
            }

            $This.Reset($This.Xaml.IO.AddressList.Items,$This.Output)
        }
        [String] Search([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }
            
            $X = $This.Output[$Index]

            Return "https://www.google.com/maps/@{0:n7},{1:n7},7.5z" -f $X.Lat, $X.Long
        }
        Reset([Object]$xSender,[Object[]]$Content)
        {
            $xSender.Clear()
            ForEach ($Item in $Content)
            {
                $xSender.Add($Item)
            }
        }
    }

    # // ________________________________________________
    # // | Testing variables, also, the "suspicious" IP |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $IPAddress = "8.48.253.109"
    $Ctrl      = [WhoisControl]::New()

    # When clicked on, it adds the information to the output table\
    $Ctrl.Xaml.IO.AddIpAddress.Add_Click(
    {
        $IPAddress = $Ctrl.Xaml.IO.IPAddress.Text
        If ($IPAddress -notmatch "^(\d+\.){3}\d+$")
        {
            [System.Windows.MessageBox]::Show("Invalid IP Address","Error")
        }

        ElseIf ($IPAddress -in $Ctrl.Output.IPAddress)
        {
            [System.Windows.MessageBox]::Show("Duplicate IP Address","Error")
        }

        $Ctrl.ResolveIP($IPAddress)
        $Ctrl.Xaml.IO.IPAddress.Text = $Null
    })

    # Output will be bound to this box (Needs event handler for onclick)
    $Ctrl.Xaml.IO.AddressList.Add_SelectionChanged(
    {
        $Index = $Ctrl.Xaml.IO.AddressList.SelectedIndex
        If ($Index -ne -1)
        {
            $Item = $Ctrl.Output[$Index]
            $Swap = "Zip","Type","City","State","Country","Long","Lat" | % {
                
                [DGList]::New($_,$Item.$_)
            }

            # Handles the vertical datagrid key/values
            $Ctrl.Reset($Ctrl.Xaml.IO.LocationList.Items,$Swap)

            # Handles the registration date information
            $Ctrl.Xaml.IO.RegDate.Text     = $Item.RegDate.ToString()
            $Ctrl.Xaml.IO.RegZone.Text     = $Item.RegZone.ToString()

            # Handles the last update date information
            $Ctrl.Xaml.IO.UpdateDate.Text  = $Item.UpdateDate.ToString()
            $Ctrl.Xaml.IO.UpdateZone.Text  = $Item.UpdateZone.ToString()

            # Handles the string to open the browser with to open location            
            $Ctrl.Xaml.IO.Coordinates.Text = $Ctrl.Search($Index)
        }

        If ($Index -eq -1)
        {
            # Handles the vertical datagrid key/values
            $Ctrl.Reset($Ctrl.Xaml.IO.LocationList,$Null)

            # Handles the registration date information
            $Ctrl.Xaml.IO.RegDate.Text     = $Null
            $Ctrl.Xaml.IO.RegZone.Text     = $Null

            # Handles the last update date information
            $Ctrl.Xaml.IO.UpdateDate.Text  = $Null
            $Ctrl.Xaml.IO.UpdateZone.Text  = $Null

            # Handles the string to open the browser with to open location            
            $Ctrl.Xaml.IO.Coordinates.Text = $Null
        }
    })

    $Ctrl.Xaml.IO.Coordinates.Add_TextChanged(
    {
        $Ctrl.Xaml.IO.Start.IsEnabled = @(0,1)[$Ctrl.Xaml.IO.Coordinates.Text -ne ""]
    })

    # Starts disabled, but if data is in the "Coordinates" box, then it becomes available
    $Ctrl.Xaml.IO.Start.Add_Click(
    {
        Start-Process $Ctrl.Xaml.IO.Coordinates.Text
    })

    $Ctrl.Xaml.Invoke()
