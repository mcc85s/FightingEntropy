<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FESystem.ps1
          Solution: FightingEntropy Module
          Purpose: So far, for renaming a computer and workgroup/domain
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-26
          Modified: 2021-10-26
          
          Version - 2021.10.0 - () - Began development 10/26/2021.

          TODO:

.Example
#>
Function Get-FESystem
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
    [Parameter(Mandatory,ParameterSetName=1)][Hashtable]$InputObject)
    
    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
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
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ( $I in 0..( $This.Names.Count - 1 ) )
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }

    Class DGList
    {
        [String]$Name
        [Object]$Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class SystemSetupGUI
    {
        Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[Fightingentropy]://System Setup" Height="600" Width="800">',
        '    <Window.Resources>',
        '        <Style TargetType="Grid">',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Height" Value="30"/>',
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
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
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
        '        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="Height" Value="24"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="TabItem">',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="TabItem">',
        '                        <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected" Value="True">',
        '                                <Setter TargetName="Border" Property="Background" Value="#4444FF"/>',
        '                                <Setter Property="Foreground" Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected" Value="False">',
        '                                <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground" Value="#000000"/>',
        '                            </Trigger>',
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="30"/>',
        '            <Setter Property="FontWeight" Value="Semibold"/>',
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
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="AutoGenerateColumns" Value="False"/>',
        '            <Setter Property="AlternationCount" Value="2"/>',
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
        '                    <Setter Property="Background" Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground"  Value="Black"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '         <TabControl Grid.Row="0">',
        '            <TabItem Header="System">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="280"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Header="[System]" Grid.Row="0">',
        '                        <Grid Margin="5">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="240"/>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Column 0 -->',
        '                            <Label       Grid.Row="0" Grid.Column="0" Content="[Manufacturer]:"/>',
        '                            <Label       Grid.Row="1" Grid.Column="0" Content="[Model]:"/>',
        '                            <Label       Grid.Row="2" Grid.Column="0" Content="[Processor]:"/>',
        '                            <Label       Grid.Row="3" Grid.Column="0" Content="[Architecture]:"/>',
        '                            <Label       Grid.Row="4" Grid.Column="0" Content="[UUID]:"/>',
        '                            <!-- Column 1 -->',
        '                            <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>',
        '                            <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>',
        '                            <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture"/>',
        '                            <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3"  Name="System_UUID"/>',
        '                            <!-- Column 2 -->',
        '                            <Label       Grid.Row="0" Grid.Column="2" Content="[Product]:"/>',
        '                            <Label       Grid.Row="1" Grid.Column="2" Content="[Serial]:"/>',
        '                            <Label       Grid.Row="2" Grid.Column="2" Content="[Memory]:"/>',
        '                            <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">',
        '                                <Label    Content="[Chassis]:"/>',
        '                                <CheckBox Name="System_IsVM" Content="VM" IsEnabled="False"/>',
        '                            </StackPanel>',
        '                            <!-- Column 3 -->',
        '                            <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>',
        '                            <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>',
        '                            <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis"/>',
        '                            <StackPanel  Grid.Row="5" Grid.Column="3" Orientation="Horizontal">',
        '                                <Label   Content="[BIOS/UEFI]:"/>',
        '                                <ComboBox Name="System_BiosUefi" Width="125"/>',
        '                            </StackPanel>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="1" Header="[Details]">',
        '                        <DataGrid Name="Role" Margin="5">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="150"/>',
        '                                <DataGridTextColumn Header="Value"      Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Domain">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="120"/>',
        '                        <RowDefinition Height="180"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0"  Header="[Control]">',
        '                        <Grid Margin="5">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="25"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Row 0 -->',
        '                            <Label       Grid.Row="0" Grid.Column="0" Content="[Domain Type]:"/>',
        '                            <ComboBox    Grid.Row="0" Grid.Column="1" Name="Domain_Type"/>',
        '                            <Label       Grid.Row="0" Grid.Column="2" Content="[Hostname]:"/>',
        '                            <TextBox     Grid.Row="0" Grid.Column="3" Name="Hostname"/>',
        '                            <Image       Grid.Row="0" Grid.Column="4" Name="HostnameIcon"/>',
        '                            <!-- Row 1 -->',
        '                            <Button      Grid.Row="1" Grid.Column="0" Name="Login" Content="Login"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="1" Name="Username"/>',
        '                            <Label       Grid.Row="1" Grid.Column="2" Name="WorkgroupLabel" Content="[Workgroup]:"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="3" Name="Workgroup"/>',
        '                            <Image       Grid.Row="1" Grid.Column="4" Name="WorkgroupIcon"/>',
        '                            <Label       Grid.Row="1" Grid.Column="2" Name="DomainLabel" Content="[Domain]:"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="3" Name="Domain"/>',
        '                            <Image       Grid.Row="1" Grid.Column="4" Name="DomainIcon"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <GroupBox Grid.Column="0"  Header="[Current]">',
        '                                <DataGrid Name="Current">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Binding="{Binding  Name}" Width="125"/>',
        '                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </GroupBox>',
        '                            <GroupBox Grid.Column="1" Header="[Target]">',
        '                                <DataGrid Name="Target">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Binding="{Binding  Name}" Width="125"/>',
        '                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </GroupBox>',
        '                        </Grid>',
        '                    <GroupBox Grid.Row="2" Header="[Template]">',
        '                        <Grid>',
        '                            <DataGrid Name="Template">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Grid Grid.Row="1">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="1" Name="Apply" Content="Apply"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ProfileItem
    {
        [UInt32]  $Index
        [String]   $Name
        [String]  $Value
        [Bool]    $Check
        [String] $Reason
        ProfileItem([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Check  = $False
            $This.Reason = "N/A"
        }
    }

    Class Profile
    {
        [Object] $Current
        [Object] $Target
        Profile()
        {
            $This.Current = @( )
            $This.Target  = @( )
            ForEach ($Name in "Hostname NetBIOS NetBIOSHostName Domain DomainHostName" -Split " ")
            {
                $Item          = [ProfileItem]::New($This.Current.Count,$Name)
                $Item.Reason   = "N/A"
                $This.Current += $Item
                $This.Target  += [ProfileItem]::New($This.Target.Count,$Name)
            }
        }
    }

    Class SystemSetup
    {
        [Object] $Module
        Hidden [String] $Pass
        Hidden [String] $Fail
        [Object] $Role
        [Object] $System
        [Object] $Computer
        [Object] $Network
        [String] $Name
        [String] $Mode
        [Object] $Connection
        Hidden [Object]$Xaml
        Hidden [Object]$Profile
        [Object] $Current
        [Object] $Target
        SystemSetup()
        {
            $This.Module   = Get-FEModule
            $This.Pass     = $This.Module.Control | ? Name -eq success.png | % FullName
            $This.Fail     = $This.Module.Control | ? Name -eq failure.png | % FullName
            $This.Role     = $This.Module.Role
            If (!$This.Role.IsAdmin)
            {
                Throw "Must run as an administrator"
            }
            $This.Role.GetSystem()
            $This.System   = $This.Role.System
            $This.Computer = Get-WMIObject -Class Win32_ComputerSystem
            $This.Network  = Get-WMIObject -Class Win32_NetworkAdapterConfiguration | ? DefaultIPGateway
            $This.Name     = $This.Computer.Name
            $This.Mode     = @("Workgroup","Domain")[$This.Computer.PartOfDomain]
            $This.Profile  = [Profile]::New()
            $This.Current  = $This.Profile.Current
            $This.Target   = $This.Profile.Target
        }
        LoadXaml([Object]$Xaml)
        {
            $This.Xaml     = $Xaml

            $This.Xaml.IO.System_Manufacturer.Text          = $This.System.Manufacturer
            $This.Xaml.IO.System_Manufacturer.IsEnabled     = 0

            $This.Xaml.IO.System_Model.Text                 = $This.System.Model
            $This.Xaml.IO.System_Model.IsEnabled            = 0

            $This.Xaml.IO.System_Processor.ItemsSource      = @($This.System.Processor.Name)
            $This.Xaml.IO.System_Processor.SelectedIndex    = 0

            $This.Xaml.IO.System_Architecture.ItemsSource   = @($This.System.Architecture)
            $This.Xaml.IO.System_Architecture.SelectedIndex = 0
            $This.Xaml.IO.System_Architecture.IsEnabled     = 0

            $This.Xaml.IO.System_UUID.Text                  = $This.System.UUID
            $This.Xaml.IO.System_UUID.IsEnabled             = 0

            $This.Xaml.IO.HostName.Text                     = $This.Computer.Name
            
            $This.Xaml.IO.System_IsVM.IsChecked             = $This.System.Model -match "(Virtual|VM)"
            $This.Xaml.IO.System_IsVM.IsEnabled             = 0
            
            $This.Xaml.IO.System_Product.Text               = $This.System.Product
            $This.Xaml.IO.System_Product.IsEnabled          = 0
             
            $This.Xaml.IO.System_Serial.Text                = $This.System.Serial
            $This.Xaml.IO.System_Serial.IsEnabled           = 0

            $This.Xaml.IO.System_Memory.Text                = $This.System.Memory
            $This.Xaml.IO.System_Memory.IsEnabled           = 1

            $This.Xaml.IO.System_Chassis.ItemsSource        = @($This.System.Chassis)
            $This.Xaml.IO.System_Chassis.SelectedIndex      = 0

            $This.Xaml.IO.System_BiosUefi.ItemsSource       = @($This.System.BiosUEFI)
            $This.Xaml.IO.System_BiosUefi.SelectedIndex     = 0

            $This.Xaml.IO.Role.ItemsSource                  = @( )
            $This.Xaml.IO.Role.ItemsSource                  = @( 
            ForEach ($Item in "Name DNS NetBIOS Hostname Username Principal Caption Version Build ReleaseID Code SKU" -Split " ")
            {
                [DGList]::New($Item,$This.Role.$Item)
            })

            If ($This.Mode -eq "Workgroup")
            {
                $This.Current[0].Value = $This.Computer.Name
                $This.Current[1].Value = $This.Computer.Domain
                $This.Current[2].Value = "{0}\{1}" -f $This.Computer.Domain, $This.Computer.Name
                $This.Current[3].Value = "-"
                $This.Current[4].Value = "-"
            }

            If ($This.Mode -eq "Domain")
            {
                $This.Current[0].Value = $This.Role.Name
                $This.Current[1].Value = $This.Role.NetBIOS.ToUpper()
                $This.Current[2].Value = "{0}\{1}" -f $This.Current[1].Value, $This.Role.Name
                $This.Current[3].Value = $This.Role.DNS
                $This.Current[4].Value = $This.Role.Hostname
            }

            0..4 | % { $This.Target[$_].Value = $This.Current[$_].Value }

            $This.Xaml.IO.Current.ItemsSource               = $This.Current
            $This.Xaml.IO.Target.ItemsSource                = $This.Target

            $This.Xaml.IO.Domain_Type.ItemsSource           = @("Workgroup","Domain")
            $This.Xaml.IO.Domain_Type.SelectedIndex         = [UInt32]($This.Mode -eq "Domain")

            $This.ToggleDomain($This.Mode)
            $This.Xaml.IO.Username.IsEnabled                = 0
        }
        ToggleDomain([String]$Type)
        {
            Switch([String]$Type)
            {
                Workgroup 
                {
                    $This.Xaml.IO.Workgroup.IsEnabled       = 1
                    $This.Xaml.IO.Workgroup.Visibility      = "Visible"
                    $This.Xaml.IO.WorkgroupLabel.Visibility = "Visible"
                    $This.Xaml.IO.WorkgroupIcon.Visibility  = "Visible"
                    $This.Xaml.IO.Domain.IsEnabled          = 0
                    $This.Xaml.IO.Domain.Visibility         = "Collapsed"
                    $This.Xaml.IO.DomainLabel.Visibility    = "Collapsed"
                    $This.Xaml.IO.DomainIcon.Visibility     = "Collapsed"
                    $This.Xaml.IO.Login.IsEnabled           = 0
                    $This.Xaml.IO.Login.Visibility          = "Collapsed"
                    $This.Xaml.IO.Username.Visibility       = "Collapsed"
                    $This.Connection                        = $Null
                }
                Domain
                {
                    $This.Xaml.IO.Workgroup.IsEnabled       = 0
                    $This.Xaml.IO.Workgroup.Visibility      = "Collapsed"
                    $This.Xaml.IO.WorkgroupLabel.Visibility = "Collapsed"
                    $This.Xaml.IO.WorkgroupIcon.Visibility  = "Collapsed"
                    $This.Xaml.IO.Domain.IsEnabled          = 1
                    $This.Xaml.IO.Domain.Visibility         = "Visible"
                    $This.Xaml.IO.DomainLabel.Visibility    = "Visible"
                    $This.Xaml.IO.DomainIcon.Visibility     = "Visible"
                    $This.Xaml.IO.Login.IsEnabled           = 1
                    $This.Xaml.IO.Login.Visibility          = "Visible"
                    $This.Xaml.IO.Username.Visibility       = "Visible"
                }
            }
        }
        SetTemplate([Object]$InputObject)
        {
            $This.Xaml.IO.Template.ItemsSource = @( )
            $This.Xaml.IO.Template.ItemsSource = @(
            ForEach ($Item in "Type","DistinguishedName","Name","Location","Region","Country","Postal",
            "TimeZone","SiteLink","SiteName","Network","Prefix","Netmask","Start","End","Range","Broadcast")
            {
                [DGList]::New($Item,$InputObject.$Item)
            })
        }
        Check([String]$Name)
        {
            If ($Name -eq "Hostname")
            {
                $Object                            = $This.Target | ? Name -eq Hostname
                $Object.Value                      = $This.Xaml.IO.Hostname.Text
                $This.CheckHostname($Object)

                $Object                            = $This.Target | ? Name -eq Hostname
                $This.Xaml.IO."$Name`Icon".Source  = @($This.Fail,$This.Pass)[$Object.Check]
                $This.Xaml.IO."$Name`Icon".ToolTip = $Object.Reason
            }
        }
        CheckDomainName()
        {
            
        }
        CheckHostname([Object]$Object)
        {
            If ($Object.Value.Length -le 1 -or $Object.Value.Length -gt 15)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Length not between 1 and 15 characters"
            }

            ElseIf ($Object.Value -in $This.Reserved())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the reserved words list"
            }

            ElseIf ($Object.Value -in $This.Legacy())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the legacy words list"
            }

            ElseIf ($Object.Value -in $This.SecurityDescriptors())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the security descriptors list"
            }

            ElseIf ($Object.Value -notmatch "([\.\-]*|0-9|a-z|A-Z)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Invalid characters"
            }

            ElseIf ($Object.Value[0] -match "(\W)" -or $Object.Value[-1] -match "(\W)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] First/Last character cannot be a '.' or '-'"
            }

            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
            }
        }
        SetWorkgroupTarget()
        {
            $This.Target[0].Value = $This.Xaml.IO.Hostname.Text
            $This.Target[1].Value = $This.Xaml.IO.Workgroup.Text
            $This.Target[2].Value = "{0}\{1}" -f $This.Xaml.IO.Workgroup.Text, $This.Xaml.IO.Hostname.Text
            $This.Target[3].Value = "-"
            $This.Target[4].Value = "-"

            $This.RefreshTarget()
        }
        SetDomainTarget()
        {
            $This.Target[0].Value = $This.Xaml.IO.Hostname.Text
            $This.Target[1].Value = $This.Connection.NetBIOS
            $This.Target[2].Value = "{0}\{1}" -f $This.Connection.NetBIOS, $This.Xaml.IO.Hostname.Text
            $This.Target[3].Value = $This.Connection.Domain
            $This.Target[4].Value = "{0}.{1}" -f $This.Xaml.IO.Hostname.Text, $This.Xaml.IO.Domain.Text

            $This.RefreshTarget()
        }
        RefreshTarget()
        {
            $This.Xaml.IO.Target.ItemsSource = @( )
            $This.Xaml.IO.Target.ItemsSource = @($This.Target)
        }
        [String[]] Reserved()
        {
            Return @(("ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GROUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;" + 
            "DIALUP;DIGEST AUTH;INTERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMO" +
            "TE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZATION;USERS;WORLD") -Split ";" )
        }
        [String[]] Legacy()
        {
            Return @("-GATEWAY","-GW","-TAC")
        }
        [String[]] SecurityDescriptors()
        {
            Return @(("AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS,RU,SA," +
            "SI,SO,SU,SY,WD") -Split ',')
        }
    }

    $Xaml = [XamlWindow][SystemSetupGUI]::Tab
    $Main = [SystemSetup]::New()

    $Xaml.IO.System_Processor.ItemsSource    = @( )
    $Xaml.IO.System_Architecture.ItemsSource = @( )
    $Xaml.IO.System_Chassis.ItemsSource      = @( )
    $Xaml.IO.Role.ItemsSource                = @( )
    $Xaml.IO.Domain_Type.ItemsSource         = @( )
    $Xaml.IO.Current.ItemsSource             = @( )
    $Xaml.IO.Target.ItemsSource              = @( )

    $Xaml.IO.Domain_Type.Add_SelectionChanged(
    {
        $Main.ToggleDomain($Xaml.IO.Domain_Type.SelectedItem)
    })

    $Xaml.IO.Login.Add_Click(
    {
        $Cred = Get-FEADLogin
        If ($Cred)
        {
            $Main.Connection = $Cred
            $Xaml.IO.Username.Text = $Main.Connection.Username
            $Main.Target[1].Value  = $Main.Connection.NetBIOS
            $Main.Target[2].Value  = ("{0}\{1}" -f $Main.Target[1].Value,$Main.Target[0].Value).ToUpper()
            $Main.Target[3].Value  = $Main.Connection.Domain
            $Main.Target[4].Value  = ("{0}.{1}" -f $Main.Target[0].Value,$Main.Target[3].Value).ToLower()
            $Main.RefreshTarget()
        }
    })

    $Xaml.IO.Hostname.Add_TextChanged(
    {
        $Main.Check("Hostname")
    })

    $Main.LoadXaml($Xaml)
    
    Switch ($PSCmdlet.ParameterSetName)
    {
        0 { }
        1 { $Main.SetTemplate($InputObject) }
    }

    $Xaml.Invoke()
}
