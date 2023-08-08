<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-08 15:05:51                                                                  //
 \\==================================================================================================// 

    FileName   : Get-WhoisUtility.ps1
    Solution   : [FightingEntropy()][2023.8.0]
    Purpose    : For obtaining information related to a particular IP address
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-08-08
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-WhoisUtility
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(ParameterSetName=1,Mandatory)][String[]]$IpAddress)

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
        [String] ToString()
        {
            Return "<FEModule.States>"
        }
    }

    Class ZipCodeItem
    {
        [String]       $Zip
        [String]      $Type
        [String]      $Name
        [String]     $State
        [String]   $Country
        [String]      $Long
        [String]       $Lat
        ZipCodeItem([String]$Line)
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
        ZipCodeItem([UInt32]$Zip)
        {
            $This.Zip       = $Zip
            $This.Blank()
        }
        ZipCodeItem([Switch]$Flag,[String]$Zip)
        {
            $This.Zip       = $Zip
            $This.Blank()
        }
        Blank()
        {
            $This.Type      = "Invalid"
            $This.Name      = "N/A"
            $This.State     = "N/A"
            $This.Country   = "N/A"
            $This.Long      = "N/A"
            $This.Lat       = "N/A"
        }
        [String] ToString()
        {
            Return "<FEModule.ZipCode[Entry]>"
        }
    }

    Class ZipCodeList
    {
        [String]      $Path
        [Object]   $Content
        [Object]      $Hash
        ZipCodeList([String]$Path)
        {
            $This.Path    = $Path
            $This.Content = Get-Content $Path | ? Length -gt 0
            $This.Hash    = @{ }
            ForEach ($Item in $This.Content)
            {
                $This.Hash.Add($Item.Substring(0,5),$This.Hash.Count)
            }
        }
        [Object] ZipCodeItem([String]$Zip)
        {
            Return [ZipCodeItem]::New($Zip)
        }
        [Object] ZipCodeItem([UInt32]$Zip)
        {
            Return [ZipCodeItem]::New($Zip)
        }
        [Object] ZipCodeItem([Switch]$Flags,[String]$Zip)
        {
            Return [ZipCodeItem]::New($Flags,$Zip)
        }
        [Object] Zip([String]$Zip)
        {
            $Index = $This.Hash["$Zip"]
            If (!$Index)
            {
                If ($Zip -match "[a-zA-Z]")
                {
                    $Item = $This.ZipCodeItem([Switch]$False,$Zip)
                }
                Else
                {
                    $Item = $This.ZipCodeItem([UInt32]$Zip)
                }
            }
            Else
            {
                $Item = $This.ZipCodeItem($This.Content[$Index])
            }

            Return $Item
        }
        [String] ToString()
        {
            Return "<FEModule.ZipCode[List]>"
        }
    }

    Class DateTimeZone
    {
        [Object]   $Date
        [Object] $Offset
        DateTimeZone([String]$Date)
        {
            $This.Offset = [Timespan]$Date.Substring(19)
            $This.Date   = [DateTime]$Date
        }
        [String] ToString()
        {
            Return "<FEModule.DateTimeZone>"
        }
    }

    Class IPResultItem
    {
        Hidden [Object] $Object
        [String]     $IPAddress
        [String]        $Status
        [Object]           $Org
        IPResultItem([String]$IPAddress)
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
                $This.Org       = [WhoisOrganizationReference]$This.Object.Net.OrgRef
            }
        }
    }

    Class XamlProperty
    {
        [UInt32]   $Index
        [String]    $Name
        [Object]    $Type
        [Object] $Control
        XamlProperty([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Type    = $Object.GetType().Name
            $This.Control = $Object
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class XamlWindow
    {
        Hidden [Object]        $Xaml
        Hidden [Object]         $Xml
        [String[]]            $Names
        [Object]              $Types
        [Object]               $Node
        [Object]                 $IO
        [String]          $Exception
        XamlWindow([String]$Xaml)
        {           
            If (!$Xaml)
            {
                Throw "Invalid XAML Input"
            }
    
            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    
            $This.Xaml           = $Xaml
            $This.Xml            = [XML]$Xaml
            $This.Names          = $This.FindNames()
            $This.Types          = @( )
            $This.Node           = [System.Xml.XmlNodeReader]::New($This.Xml)
            $This.IO             = [System.Windows.Markup.XamlReader]::Load($This.Node)
            
            ForEach ($X in 0..($This.Names.Count-1))
            {
                $Name            = $This.Names[$X]
                $Object          = $This.IO.FindName($Name)
                $This.IO         | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If (!!$Object)
                {
                    $This.Types += $This.XamlProperty($This.Types.Count,$Name,$Object)
                }
            }
        }
        [String[]] FindNames()
        {
            Return [Regex]::Matches($This.Xaml,"( Name\=\`"\w+`")").Value -Replace "( Name=|`")",""
        }
        [Object] XamlProperty([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            Return [XamlProperty]::New($Index,$Name,$Object)
        }
        [Object] Get([String]$Name)
        {
            $Item = $This.Types | ? Name -eq $Name
            If ($Item)
            {
                Return $Item.Control
            }
            Else
            {
                Return $Null
            }
        }
        Invoke()
        {
            Try
            {
                $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
            }
            Catch
            {
                $This.Exception = $PSItem
            }
        }
        [String] ToString()
        {
            Return "<FEModule.XamlWindow[VmControllerXaml]>"
        }
    }

    Class WhoisUtilityXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[FightingEntropy]://Whois Utility"',
        '        Width="800"',
        '        Height="480"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen"',
        '        FontFamily="Consolas"',
        '        Background="LightYellow">',
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
        '                    <ColumnDefinition Width="110"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="90"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label Grid.Column="0" Content="[Address List]:"/>',
        '                <Border   Grid.Column="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                <Label Grid.Column="2" Content="[IP Address]:"/>',
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
        '                <Label Grid.Row="0" Content="[Location]:"/>',
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
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label    Grid.Row="0" Grid.Column="1" Content="[Date]"/>',
        '                    <Label    Grid.Row="0" Grid.Column="2" Content="[Time Zone]"/>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="[Registration]:"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="1" Name="RegDate"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="2" Name="RegZone"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="[Update]:"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Name="UpdateDate"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="2" Name="UpdateZone"/>',
        '                </Grid>',
        '                <Label Grid.Row="1" Content="[Action]:"/>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="2*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <TextBox Grid.Column="0" Name="Coordinates"/>',
        '                    <Button Grid.Column="1" Content="Start" Name="Start"/>',
        '                </Grid>',
        '            </Grid>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class WhoisOrganizationReference
    {
        [String]        $Handle
        [String]          $Name
        [Object]           $Url
        Hidden [Object] $Object
        [Object]  $Registration
        [Object]        $Update
        [Object]      $Location
        WhoisOrganizationReference([Object]$Org)
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
        [String] GetStreetAddress()
        {
            Return $This.Object.Org.StreetAddress.Line."#text"
        }
        SetLocation([Object]$Zipstack)
        {
            $This.Location = $Zipstack.Zip($This.Object.Org.PostalCode)
        }
        [String] ToString()
        {
            Return "<FEModule.Whois[OrgRef]>"
        }
    }

    Class WhoisRegistrarItem
    {
        [UInt32]               $Index
        Hidden [Object] $Ip
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
        WhoisRegistrarItem([UInt32]$Index,[Object]$IP)
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
                $This.City         = Switch ($Loc.Name)
                {
                    "N/A"   { $IP.Object.Net.City } Default { $Loc.Name    }
                }

                $This.State        = $Loc.State
                $This.Country      = $Loc.Country

                If ($Loc.Long -ne "N/A")
                {
                    $This.Long     = $Loc.Long
                }
                
                If ($Loc.Lat -ne "N/A")
                {
                    $This.Lat     = $Loc.Lat
                }
            }
        }
        [String] ToString()
        {
            Return "<FEModule.WhoisRegistrar[Item]>"
        }
    }

    Class WhoisProperty
    {
        [String]  $Name
        [Object] $Value
        WhoisProperty([Object]$Property)
        {
            $This.Name  = $Property.Name
            $This.Value = $Property.Value -join ", "
        }
        [String] ToString()
        {
            Return "<FEModule.Whois[Property]>"
        }
    }
    
    Class WhoisController
    {
        [Object] $Module
        Hidden [Object] $ZipCode
        [Object] $Xaml
        [Object] $Output
        WhoisController()
        {
            $This.Main()
        }
        WhoisController([String[]]$IpAddress)
        {
            $This.Main()

            ForEach ($Item in $IpAddress)
            {
                $This.ResolveIp($Item)
            }
        }
        Main()
        {
            $This.Module       = $This.Get("Module")
            $This.ZipCode      = $This.Get("ZipCodeList")
            $This.Xaml         = $This.Get("Xaml")

            $This.Output       = @( )
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Module      { Get-FEModule -Mode 1 }
                ZipCodeList { [ZipCodeList]::New($This.Module._Control("zipcode.txt").Fullname) }
                Xaml        { [XamlWindow][WhoisUtilityXaml]::Content }
            }

            Return $Item
        }
        [Object] Zip([String]$Zip)
        {
            Return $This.ZipCode.Zip($Zip)
        }
        [Object] IpResult([String]$IpAddress)
        {
            Return [IPResultItem]::New($IpAddress)
        }
        [Object] WhoisRegistrar([Object]$Result)
        {
            Return [WhoisRegistrarItem]::New($This.Output.Count,$Result)
        }
        [Object] WhoisProperty([Object]$Property)
        {
            Return [WhoisProperty]::New($Property)
        }
        ResolveIP([String]$IPAddress)
        {
            If ($IPAddress -notmatch "^(\d+\.){3}\d+$")
            {
                Throw "Invalid IP Address (IPV4 req'd)"
            }

            [Console]::WriteLine("Searching [~] $IPAddress")
            $Result = $This.IpResult($IpAddress)
            If ($Result)
            {
                [Console]::WriteLine("Found [+] $IPAddress")
                $Result.Org.SetLocation($This.ZipCode)
                If ($Result.Org.Location.Name -eq "N/A")
                {
                    $Result.Org.Location.Name = (Invoke-RestMethod $Result.Object.Net.OrgRef."#text").Org.City
                }
                $Return = $This.WhoisRegistrar($Result)
                If ($Return.IPAddress -notin $This.Output.IPAddress)
                {
                    $This.Output += $Return
                    [Console]::WriteLine("Adding [+] $($Return.IPAddress)")
                }
            }

            $This.Reset($This.Xaml.IO.AddressList,$This.Output)
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
        [String[]] Grid([String]$Name)
        {
            $Item = Switch ($Name)
            {
                "Default"
                {
                    "Zip",
                    "Type",
                    "City",
                    "State",
                    "Country",
                    "Long",
                    "Lat"
                }
            }

            Return $Item
        }
        [Object[]] Property([Object]$Object,[String[]]$Names)
        {
            $List = ForEach ($Item in $Object.PSObject.Properties | ? Name -in $Names)
            {
                $This.WhoisProperty($Item)
            }

            Return $List
        }
        Reset([Object]$xSender,[Object[]]$Content)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $Content)
            {
                $xSender.Items.Add($Item)
            }
        }
        StageXaml()
        {
            $Ctrl = $This

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

            $Ctrl.Xaml.IO.AddressList.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.AddressList.SelectedIndex

                # Handles the registration date information
                $Ctrl.Xaml.IO.RegDate.Text     = $Null
                $Ctrl.Xaml.IO.RegZone.Text     = $Null
                
                # Handles the last update date information
                $Ctrl.Xaml.IO.UpdateDate.Text  = $Null
                $Ctrl.Xaml.IO.UpdateZone.Text  = $Null
                
                # Handles the string to open the browser with to open location            
                $Ctrl.Xaml.IO.Coordinates.Text = $Null

                Switch ($Index)
                {
                    -1
                    {
                        # Handles the vertical datagrid key/values
                        $Ctrl.Reset($Ctrl.Xaml.IO.LocationList,$Null)
                    }
                    Default
                    {
                        $Item = $Ctrl.Output[$Index]
                        $List = $Ctrl.Property($Item,$Ctrl.Grid("Default"))

                        # Handles the vertical datagrid key/values
                        $Ctrl.Reset($Ctrl.Xaml.IO.LocationList,$List)
    
                        # Handles the registration date information
                        If ($Item.RegDate)
                        {
                            $Ctrl.Xaml.IO.RegDate.Text    = $Item.RegDate.ToString()
                        }
                        
                        If ($Item.RegZone)
                        {
                            $Ctrl.Xaml.IO.RegZone.Text     = $Item.RegZone.ToString()
                        }
    
                        # Handles the last update date information
                        If ($Item.UpdateDate)
                        {
                            $Ctrl.Xaml.IO.UpdateDate.Text  = $Item.UpdateDate.ToString()
                        }

                        If ($Item.UpdateZone)
                        {
                            $Ctrl.Xaml.IO.UpdateZone.Text  = $Item.UpdateZone.ToString()
                        }
    
                        # Handles the string to open the browser with to open location            
                        $Ctrl.Xaml.IO.Coordinates.Text = $Ctrl.Search($Index)
                    }
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
        }
        [String] ToString()
        {
            Return "<FEModule.Whois[Controller]>"
        }
    }

    $Ctrl = Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [WhoisController]::New()           }
        1 { [WhoisController]::New($IpAddress) }
    }
    
    $Ctrl.StageXaml()
    $Ctrl.Xaml.Invoke()
}
