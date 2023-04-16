<#
    [04/13/23]: [VmController - GUI Development]
    [04/15/23]: [VmController - GUI Development]
    [04/16/23]: [VmController - GUI Development]

[Information]: I have covered the concept of [GUI development] as well
as managing things with [PowerShell], such as:
[+] [networking]
[+] [virtualization]
[+] [system administration]

[Objective]: Use [Visual Studio Code] as well as [Visual Studio], to
develop a [graphical user interface] that can manage multiple virtual
machines using: 

[+] [XAML/Extensible Application Markup Language]

[Note]: Use the classes from either the previous virtualization lab
videos, or the New-FEInfrastructure demonstration from this video:
________________________________________________________________________
| 12/04/2021 | New-FEInfrastructure | https://www.youtu.be/6yQr06_rA4I |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Specifically, at the time: [https://youtu.be/6yQr06_rA4I?t=355]

In that particular video, I had to use a [long list of techniques] to be
able to build the 1) graphical user interface, 2) administrate the server,
3) calculate all of the potential sites + networks + Active Directory nodes
+ virtual machine nodes...

...and I want to [streamline] that process, in order to [focus] on the 
[virtual machines] in particular.

[Todo]: Add TPM method for Windows 11
#>

Import-Module FightingEntropy

Function VmXaml
{
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

            $This.Xaml               = $Xaml
            $This.Xml                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Types              = @( )
            $This.Node               = [System.Xml.XmlNodeReader]::New($This.Xml)
            $This.IO                 = [System.Windows.Markup.XamlReader]::Load($This.Node)
            
            ForEach ($X in 0..($This.Names.Count-1))
            {
                $Name                = $This.Names[$X]
                $Object              = $This.IO.FindName($Name)
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If (!!$Object)
                {
                    $This.Types     += $This.XamlProperty($This.Types.Count,$Name,$Object)
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

    Class VmControllerXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" ',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ',
        '        Title="[FightingEntropy]://(VmController)"',
        '        Height="480"',
        '        Width="640"',
        '        Topmost="True"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen"',
        '        FontFamily="Consolas"',
        '        Background="LightYellow">',
        '    <Window.Resources>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="TabItem">',
        '',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="TabItem">',
        '                        <Border Name="Border"',
        '                                BorderThickness="2"',
        '                                BorderBrush="Black"',
        '                                CornerRadius="5"',
        '                                Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite"',
        '                                              VerticalAlignment="Center"',
        '                                              HorizontalAlignment="Right"',
        '                                              ContentSource="Header"',
        '                                              Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected" ',
        '                                     Value="True">',
        '                                <Setter TargetName="Border" ',
        '                                        Property="Background" ',
        '                                        Value="#4444FF"/>',
        '                                <Setter Property="Foreground" ',
        '                                        Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected" ',
        '                                     Value="False">',
        '                                <Setter TargetName="Border" ',
        '                                        Property="Background" ',
        '                                        Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground" ',
        '                                        Value="#000000"/>',
        '                            </Trigger>',
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Heavy"/>',
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
        '        <Style TargetType="TextBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="Foreground" Value="#000000"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
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
        '            <Setter Property="Margin" ',
        '                    Value="5"/>',
        '            <Setter Property="AutoGenerateColumns"',
        '                    Value="False"/>',
        '            <Setter Property="AlternationCount"',
        '                    Value="2"/>',
        '            <Setter Property="HeadersVisibility"',
        '                    Value="Column"/>',
        '            <Setter Property="CanUserResizeRows"',
        '                    Value="False"/>',
        '            <Setter Property="CanUserAddRows"',
        '                    Value="False"/>',
        '            <Setter Property="IsReadOnly"',
        '                    Value="True"/>',
        '            <Setter Property="IsTabStop"',
        '                    Value="True"/>',
        '            <Setter Property="IsTextSearchEnabled"',
        '                    Value="True"/>',
        '            <Setter Property="SelectionMode"',
        '                    Value="Extended"/>',
        '            <Setter Property="ScrollViewer.CanContentScroll"',
        '                    Value="True"/>',
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="VerticalContentAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="TextBlock.VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="Height" Value="20"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" ',
        '                         Value="0">',
        '                    <Setter Property="Background" ',
        '                            Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" ',
        '                            Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '                <Trigger Property="IsMouseOver" Value="True">',
        '                    <Setter Property="ToolTip">',
        '                        <Setter.Value>',
        '                            <TextBlock TextWrapping="Wrap" ',
        '                                       Width="400" ',
        '                                       Background="#000000" ',
        '                                       Foreground="#00FF00"/>',
        '                        </Setter.Value>',
        '                    </Setter>',
        '                    <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '',
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
        '        <Style x:Key="LabelGray" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="DarkSlateGray"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="LabelRed" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="IndianRed"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="Line" TargetType="Border">',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="0"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <TabControl Grid.Row="0">',
        '            <TabItem Header="Master">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Grid.Row="0" Name="MasterConfig">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Status"      Binding="{Binding Status}"      Width="50"/>',
        '                            <DataGridTextColumn Header="Alias"       Binding="{Binding Alias}"       Width="200"/>',
        '                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="0" Content="[Path]:"/>',
        '                        <TextBox Grid.Column="1" Name="MasterPath"/>',
        '                        <Image   Grid.Column="2" Name="MasterPathIcon"/>',
        '                        <Button  Grid.Column="3" Name="MasterPathBrowse" Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="2*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="0" Content="[Domain]:"/>',
        '                        <TextBox Grid.Column="1" Name="MasterDomain"/>',
        '                        <Image   Grid.Column="2" Name="MasterDomainIcon"/>',
        '                        <Label   Grid.Column="3" Content="[NetBios]:"/>',
        '                        <TextBox Grid.Column="4" Name="MasterNetBios"/>',
        '                        <Image   Grid.Column="5" Name="MasterNetBiosIcon"/>',
        '                        <Button  Grid.Column="7" Name="MasterCreate" Content="Create"/>',
        '                    </Grid>',
        '                    <TabControl Grid.Row="3">',
        '                        <TabItem Header="Config">',
        '                            <DataGrid Name="MasterConfigOutput">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                        <TabItem Header="Base">',
        '                            <DataGrid Name="MasterBase">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                        <TabItem Header="Range">',
        '                            <DataGrid Name="MasterRange">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
        '                                    <DataGridTextColumn Header="Count"    Binding="{Binding Count}"    Width="100"/>',
        '                                    <DataGridTextColumn Header="Netmask"  Binding="{Binding Netmask}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Notation" Binding="{Binding Notation}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                        <TabItem Header="Hosts">',
        '                            <DataGrid Name="MasterHosts">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"     Binding="{Binding Index}"     Width="50"/>',
        '                                    <DataGridTemplateColumn Header="Status" Width="45">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Status}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="[-]"/>',
        '                                                    <ComboBoxItem Content="[+]"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Type"      Binding="{Binding Type}"      Width="80"/>',
        '                                    <DataGridTextColumn Header="IpAddress" Binding="{Binding IpAddress}" Width="120"/>',
        '                                    <DataGridTextColumn Header="Hostname"  Binding="{Binding Hostname}"  Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                        <TabItem Header="Dhcp">',
        '                            <DataGrid Name="MasterDhcp">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Template">',
        '                <Grid Margin="10">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="150"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="Name"/>',
        '                            <TextBox Grid.Column="1" Name="TemplateName"/>',
        '                            <Label Grid.Column="2" Content="Role"/>',
        '                            <ComboBox Grid.Column="3" Name="TemplateRole">',
        '                                <ComboBoxItem Content="Server"/>',
        '                                <ComboBoxItem Content="Client"/>',
        '                                <ComboBoxItem Content="Unix"/>',
        '                            </ComboBox>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="25"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label   Grid.Column="0" Content="Path"/>',
        '                            <TextBox Grid.Column="1" Name="TemplatePath"/>',
        '                            <Image   Grid.Column="2" Name="TemplatePathIcon"/>',
        '                            <Button  Grid.Column="3" Name="TemplatePathBrowse" Content="Browse"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="Memory/GB"/>',
        '                            <ComboBox Grid.Column="1"  Name="TemplateMemory" SelectedIndex="0">',
        '                                <ComboBoxItem Content="2"/>',
        '                                <ComboBoxItem Content="4"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="2" Content="Drive/GB"/>',
        '                            <ComboBox Grid.Column="3" Name="TemplateHardDrive" SelectedIndex="1">',
        '                                <ComboBoxItem Content="32"/>',
        '                                <ComboBoxItem Content="64"/>',
        '                                <ComboBoxItem Content="96"/>',
        '                                <ComboBoxItem Content="128"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="4" Content="Generation"/>',
        '                            <ComboBox Grid.Column="5" Name="TemplateGeneration" SelectedIndex="1">',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="6" Content="CPU/Core"/>',
        '                            <ComboBox Grid.Column="7" Name="TemplateCore" SelectedIndex="1">',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                                <ComboBoxItem Content="3"/>',
        '                                <ComboBoxItem Content="4"/>',
        '                            </ComboBox>',
        '                        </Grid>',
        '                        <Grid Grid.Row="3">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="Switch"/>',
        '                            <ComboBox Grid.Column="1" Name="TemplateSwitch"/>',
        '                            <TextBlock Grid.Column="2" Foreground="Black" VerticalAlignment="Center" Text="[Virtual switch to use]"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="4">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="25"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="Image/Iso"/>',
        '                            <TextBox Grid.Column="1" Name="TemplateImagePath"/>',
        '                            <Image   Grid.Column="2" Name="TemplateImagePathIcon"/>',
        '                            <Button  Grid.Column="3" Name="TemplateImagePathBrowse" Content="Browse"/>',
        '                        </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Content="Add" Name="TemplateAdd"/>',
        '                        <Button Grid.Column="1" Content="Remove" Name="TemplateRemove"/>',
        '                        <Button Grid.Column="2" Content="Export" Name="TemplateExport"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="6" Name="TemplateOutput">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="40"/>',
        '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="100"/>',
        '                            <DataGridTextColumn Header="Role"     Binding="{Binding Role}"     Width="60"/>',
        '                            <DataGridTextColumn Header="Memory"   Binding="{Binding Memory}"   Width="60"/>',
        '                            <DataGridTextColumn Header="Hdd"      Binding="{Binding Hdd}"      Width="60"/>',
        '                            <DataGridTextColumn Header="Gen"      Binding="{Binding Gen}"      Width="40"/>',
        '                            <DataGridTextColumn Header="Core"     Binding="{Binding Core}"     Width="40"/>',
        '                            <DataGridTextColumn Header="SwitchId" Binding="{Binding SwitchId}" Width="100"/>',
        '                            <DataGridTextColumn Header="Image"    Binding="{Binding Image}"    Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Node" Height="32" VerticalAlignment="Top">',
        '                <TabControl>',
        '                    <TabItem Header="Current">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="Virtual Switch(es)"/>',
        '                                <Button Grid.Column="1" Content="Refresh" Name="NodeSwitchRefresh"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="1" Name="NodeSwitch">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"       Binding="{Binding Index}" Width="50"/>',
        '                                    <DataGridTextColumn Header="Name"        Binding="{Binding Name}"  Width="125"/>',
        '                                    <DataGridTextColumn Header="Type"        Binding="{Binding Type}"  Width="100"/>',
        '                                    <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="Virtual Host(s)"/>',
        '                                <Button Grid.Column="1" Content="Refresh" Name="NodeHostRefresh"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="3" Name="NodeHost">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"       Binding="{Binding Index}" Width="50"/>',
        '                                    <DataGridTextColumn Header="Name"        Binding="{Binding Name}"  Width="125"/>',
        '                                    <DataGridTextColumn Header="SwitchName"  Binding="{Binding SwitchName}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Import">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="Template(s)"/>',
        '                                <TextBox Grid.Column="1" Name="NodeTemplatePath"/>',
        '                                <Button Grid.Column="2" Content="Import" Name="NodeTemplateImport"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="1" Name="NodeTemplate">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="40"/>',
        '                                    <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="100"/>',
        '                                    <DataGridTextColumn Header="Role"     Binding="{Binding Role}"     Width="60"/>',
        '                                    <DataGridTextColumn Header="Memory"   Binding="{Binding Memory}"   Width="60"/>',
        '                                    <DataGridTextColumn Header="Hdd"      Binding="{Binding Hdd}"      Width="60"/>',
        '                                    <DataGridTextColumn Header="Gen"      Binding="{Binding Gen}"      Width="40"/>',
        '                                    <DataGridTextColumn Header="Core"     Binding="{Binding Core}"     Width="40"/>',
        '                                    <DataGridTextColumn Header="SwitchId" Binding="{Binding SwitchId}" Width="100"/>',
        '                                    <DataGridTextColumn Header="Image"    Binding="{Binding Image}"    Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <DataGrid Grid.Row="2" Name="NodeTemplateExtension">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="150"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                </TabControl>',
        '            </TabItem>',
        '            <TabItem Header="Credential">',
        '                <Grid Margin="20">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="120"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label    Grid.Column="0" Content="[Type]:"/>',
        '                            <ComboBox Grid.Column="1" Name="CredentialType" SelectedIndex="0">',
        '                                <ComboBoxItem Content="Setup"/>',
        '                                <ComboBoxItem Content="System"/>',
        '                                <ComboBoxItem Content="Service"/>',
        '                                <ComboBoxItem Content="User"/>',
        '                            </ComboBox>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="[Username]:"/>',
        '                            <TextBox Grid.Column="1" Name="CredentialUsername"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="[Password]:"/>',
        '                            <TextBox Grid.Column="1" Name="CredentialPassword"/>',
        '                            <Button  Grid.Column="2" Name="CredentialGenerate" Content="Generate"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="1" Name="CredentialOutput">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="90"/>',
        '                            <DataGridTextColumn Header="Username" Binding="{Binding Username}" Width="*"/>',
        '                            <DataGridTextColumn Header="Password" Binding="{Binding Password}" Width="150"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '        <TextBlock Grid.Row="2" Name="Console"/>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    [XamlWindow][VmControllerXaml]::Content
}

Function VmMaster
{
    Class VmMain
    {
        [String]    $Path
        [String]  $Domain
        [String] $NetBios
        VmMain([String]$Path,[String]$Domain,[String]$NetBios)
        {
            $This.Path    = $Path
            $This.Domain  = $Domain.ToLower()
            $This.NetBios = $NetBios.ToUpper()
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmMain>"
        }
    }

    Class VmNetworkConfig
    {
        Hidden [Object]        $Config
        [String]         $ComputerName
        [String]                $Alias
        [String]          $Description
        [String]               $CompID
        [String]      $CompDescription
        [String]           $MacAddress
        [String]               $Status
        [String]                 $Name
        [String]             $Category
        [String]     $IPv4Connectivity
        [String]          $IPv4Address
        [String]           $IPv4Prefix
        [String]   $IPv4DefaultGateway
        [String]     $IPv4InterfaceMtu
        [String]    $IPv4InterfaceDhcp
        [String[]]      $IPv4DnsServer
        [String]     $IPv6Connectivity
        [String] $IPv6LinkLocalAddress
        [String]   $IPv6DefaultGateway
        [String]     $IPv6InterfaceMtu
        [String]    $IPv6InterfaceDhcp
        [String[]]      $IPv6DnsServer
        VmNetworkConfig([Object]$Config)
        {
            $This.Config                 = $Config
            $This.ComputerName           = $Config.ComputerName
            $This.Alias                  = $Config.InterfaceAlias
            $This.Description            = $Config.InterfaceDescription
            $This.CompID                 = $Config.NetCompartment.CompartmentId
            $This.CompDescription        = $Config.NetCompartment.CompartmentDescription
            $This.MacAddress             = $Config.NetAdapter.LinkLayerAddress
            $This.Status                 = $Config.NetAdapter.Status
            $This.Name                   = $Config.NetProfile.Name
            $This.Category               = $Config.NetProfile.NetworkCategory
            $This.IPv4Connectivity       = $Config.NetProfile.IPv4Connectivity
            $This.IPv4Address            = $Config.IPv4Address.IpAddress
            $This.IPv4Prefix             = $Config.IPv4Address.PrefixLength
            $This.IPv4DefaultGateway     = $Config.IPv4DefaultGateway.NextHop
            $This.IPv4InterfaceMtu       = $Config.NetIPv4Interface.NlMTU
            $This.IPv4InterfaceDhcp      = $Config.NetIPv4Interface.DHCP
            $This.IPv4DnsServer          = $Config.DNSServer | ? AddressFamily -eq 2 | % ServerAddresses
            $This.IPv6Connectivity       = $Config.NetProfile.IPv6Connectivity
            $This.IPv6DefaultGateway     = $Config.IPv6DefaultGateway.NextHop
            $This.IPv6LinkLocalAddress   = $Config.IPv6LinkLocalAddress
            $This.IPv6InterfaceMtu       = $Config.NetIPv6Interface.NlMTU
            $This.IPv6InterfaceDhcp      = $Config.NetIPv6Interface.DHCP
            $This.IPv6DnsServer          = $Config.DNSServer | ? AddressFamily -eq 23 | % ServerAddresses
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Config]>"
        }
    }

    Class VmNetworkHost
    {
        [UInt32]         $Index
        [UInt32]        $Status
        [String]          $Type = "Host"
        [String]     $IpAddress
        [String]      $Hostname
        [String[]]     $Aliases
        [String[]] $AddressList
        VmNetworkHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = $Reply.Result.Status -match "Success"
            $This.IpAddress      = $IpAddress
        }
        VmNetworkHost([UInt32]$Index,[String]$IpAddress)
        {
            $This.Index          = $Index
            $This.Status         = 0
            $This.IpAddress      = $IpAddress
        }
        Resolve()
        {
            $Item                = [System.Net.Dns]::Resolve($This.IpAddress)
            $This.Hostname       = $Item.Hostname
            $This.Aliases        = $Item.Aliases
            $This.AddressList    = $Item.AddressList
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Host]>"
        }
    }

    Class VmNetworkBase
    {
        [String]    $Domain
        [String]   $NetBios
        [String]   $Network
        [String] $Broadcast
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]  $Wildcard
        [String]   $Gateway
        [String[]]     $Dns
        VmNetworkBase([Object]$Main,[Object]$Config)
        {
            $This.Domain    = $Main.Domain
            $This.NetBios   = $Main.NetBios
            $This.Trusted   = $Config.IPV4Address
            $This.Prefix    = $Config.IPv4Prefix

            # Binary
            $This.GetConversion()

            $This.Gateway   = $Config.IPV4DefaultGateway
            $This.Dns       = $Config.IPv4DnsServer
        }
        GetConversion()
        {
            # Convert IP and PrefixLength into binary, netmask, and wildcard
            $xBinary       = 0..3 | % { (($_*8)..(($_*8)+7) | % { @(0,1)[$_ -lt $This.Prefix] }) -join '' }
            $This.Netmask  = ($xBinary | % { [Convert]::ToInt32($_,2 ) }) -join "."
            $This.Wildcard = ($This.Netmask.Split(".") | % { (256-$_) }) -join "."
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Base]>"
        }
    }

    Class VmNetworkDhcp
    {
        [String]          $Name
        [String]    $SubnetMask
        [String]       $Network
        [String]    $StartRange
        [String]      $EndRange
        [String]     $Broadcast
        [String[]]   $Exclusion
        VmNetworkDhcp([Object]$Base,[Object]$Hosts)
        {
            $This.Network     = $Base.Network   = $Hosts[0].IpAddress
            $This.Broadcast   = $Base.Broadcast = $Hosts[-1].IpAddress
            $This.Name        = "{0}/{1}" -f $This.Network, $Base.Prefix
            $This.SubnetMask  = $Base.Netmask
            $Range            = $Hosts | ? Type -eq Host
            $This.StartRange  = $Range[0].IpAddress
            $This.EndRange    = $Range[-1].IpAddress
            $This.Exclusion   = $Range | ? Status | % IpAddress
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Dhcp]>"
        }
    }

    Class VmNetworkNode
    {
        [UInt32]     $Index
        [String]      $Name
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        VmNetworkNode([UInt32]$Index,[String]$Name,[String]$IpAddress,[Object]$Hive)
        {
            $This.Index     = $Index
            $This.Name      = $Name
            $This.IpAddress = $IpAddress
            $This.Domain    = $Hive.Domain
            $This.NetBios   = $Hive.NetBios
            $This.Trusted   = $Hive.Trusted
            $This.Prefix    = $Hive.Prefix
            $This.Netmask   = $Hive.Netmask
            $This.Gateway   = $Hive.Gateway
            $This.Dns       = $Hive.Dns
            $This.Dhcp      = $Hive.Dhcp
        }
        VmNetworkNode([Object]$File)
        {
            $This.Index     = $File.Index
            $This.Name      = $File.Name
            $This.IpAddress = $File.IpAddress
            $This.Domain    = $File.Domain
            $This.NetBios   = $File.NetBios
            $This.Trusted   = $File.Trusted
            $This.Prefix    = $File.Prefix
            $This.Netmask   = $File.Netmask
            $This.Gateway   = $File.Gateway
            $This.Dns       = $File.Dns
            $This.Dhcp      = $File.Dhcp
        }
        [String] Hostname()
        {
            Return "{0}.{1}" -f $This.Name, $This.Domain
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Node]>"
        }
    }

    Class VmNetworkRange
    {
        [UInt32]     $Index
        [String]     $Count
        [String]   $Netmask
        [String]  $Notation
        [Object]    $Output
        VmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Count,[String]$Notation)
        {
            $This.Index    = $Index
            $This.Count    = $Count
            $This.Netmask  = $Netmask
            $This.Notation = $Notation
            $This.Output   = @( )
        }
        Expand()
        {
            $Split     = $This.Notation.Split("/")
            $HostRange = @{ }
            ForEach ($0 in $Split[0] | Invoke-Expression)
            {
                ForEach ($1 in $Split[1] | Invoke-Expression)
                {
                    ForEach ($2 in $Split[2] | Invoke-Expression)
                    {
                        ForEach ($3 in $Split[3] | Invoke-Expression)
                        {
                            $HostRange.Add($HostRange.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.Output    = $HostRange[0..($HostRange.Count-1)]
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Range]>"
        }
    }

    Class VmNetworkControl
    {
        [Object]   $Config
        [Object]     $Base
        [Object]    $Range
        [Object]    $Hosts
        [Object]     $Dhcp
        VmNetworkControl([Object]$Main,[Object]$Config)
        {
            $This.Config   = $Config
            $This.Base     = $This.VmNetworkBase($Main,$Config)
            $This.Range    = @( )
            $This.Hosts    = @( )

            $This.GetNetworkRange()
        }
        [Object] VmNetworkBase([Object]$Main,[Object]$Config)
        {
            Return [VmNetworkBase]::New($Main,$Config)
        }
        [Object] VmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Count,[String]$Notation)
        {
            Return [VmNetworkRange]::New($Index,$Netmask,$Count,$Notation)
        }
        [Object] VmNetworkDhcp([Object]$Base,[Object[]]$Hosts)
        {
            Return [VmNetworkDhcp]::New($Base,$Hosts)
        }
        [Object] VmNetworkHost([UInt32]$Index,[String]$IpAddress)
        {
            Return [VmNetworkHost]::New($Index,$IpAddress)
        }
        AddList([UInt32]$Count,[String]$Notation)
        {
            $This.Range += $This.VmNetworkRange($This.Range.Count,$This.Base.Netmask,$Count,$Notation)
        }
        GetNetworkRange()
        {
            $Address       = $This.Base.Trusted.Split(".")

            $xNetmask      = $This.Base.Netmask  -split "\."
            $xWildCard     = $This.Base.Wildcard -split "\."
            $Total         = $xWildcard -join "*" | Invoke-Expression

            # Convert wildcard into total host range
            $Hash          = @{ }
            ForEach ($X in 0..3)
            { 
                $Value = Switch ($xWildcard[$X])
                {
                    1       
                    { 
                        $Address[$X]
                    }
                    Default
                    {
                        ForEach ($Item in 0..255 | ? { $_ % $xWildcard[$X] -eq 0 })
                        {
                            "{0}..{1}" -f $Item, ($Item+($xWildcard[$X]-1))
                        }
                    }
                    255
                    {
                        "{0}..{1}" -f $xNetmask[$X],($xNetmask[$X]+$xWildcard[$X])
                    }
                }

                $Hash.Add($X,$Value)
            }

            # Build host range
            $xRange   = @{ }
            ForEach ($0 in $Hash[0])
            {
                ForEach ($1 in $Hash[1])
                {
                    ForEach ($2 in $Hash[2])
                    {
                        ForEach ($3 in $Hash[3])
                        {
                            $xRange.Add($xRange.Count,"$0/$1/$2/$3")
                        }
                    }
                }
            }

            Switch ($xRange.Count)
            {
                0
                {
                    "Error"
                }
                1
                {
                    $This.AddList($Total,$xRange[0])
                }
                Default
                {
                    ForEach ($X in 0..($xRange.Count-1))
                    {
                        $This.AddList($Total,$xRange[$X])
                    }
                }
            }

            # Subtract network + broadcast addresses
            ForEach ($Network in $This.Range)
            {
                $Network.Expand()
                If ($This.Base.Trusted -in $Network.Output)
                {
                    $xHost               = @{ }
                    ForEach ($Item in $Network.Output)
                    {
                        $xHost.Add($xHost.Count,$This.VmNetworkHost($xHost.Count,$Item))
                    }
                    $This.Hosts          = $xHost[0..($xHost.Count-1)]
                    $This.Hosts[ 0].Type = "Network"
                    $This.Hosts[-1].Type = "Broadcast"
                }
                Else
                {
                    $Network.Output      = @( )
                }
            }
        }
        SetDhcp()
        {
            $This.Dhcp     = $This.VmNetworkDhcp($This.Base,$This.Hosts)
        }
        [String] FirstAvailableIPAddress()
        {
            $Address = $Null
            $List    = $This.Hosts | ? Type -eq Host | ? Status -eq 0
            If ($List.Count -gt 0)
            {
                $Address = $List[0].IPAddress
            }
            
            Return $Address
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Control]>"
        }
    }

    Class VmNetworkMaster
    {
        [Object]       $Main
        [Object]     $Config
        [Object]    $Network
        VmNetworkMaster()
        {
            $This.Config = $This.VmNetworkConfig()
        }
        [Object[]] NetIPConfig()
        {
            Return Get-NetIPConfiguration -Detailed | ? IPV4DefaultGateway
        }
        [Object] VmMain([String]$Path,[String]$Domain,[String]$NetBios)
        {
            Return [VmMain]::New($Path,$Domain,$NetBios)
        }
        [Object[]] VmNetworkConfig()
        {
            Return $This.NetIPConfig() | % { [VmNetworkConfig]::New($_) }
        }
        [Object] VmNetworkControl([Object]$Main,[Object]$Config)
        {
            Return [VmNetworkControl]::New($Main,$Config)
        }
        SetMain([String]$Path,[String]$Domain,[String]$NetBios)
        {
            $This.Main = $This.VmMain($Path,$Domain,$NetBios)
        }
        SetNetwork([UInt32]$Index)
        {
            If (!$This.Main)
            {
                Throw "Must set (Path/Domain/NetBios) info first"
            }

            ElseIf ($Index -gt $This.Config.Count)
            {
                Throw "Invalid index"
            }

            $This.Network = $This.VmNetworkControl($This.Main,$This.Config[$Index])
        }
        InternalPingSweep()
        {
            If ($This.Network.Range.Output.Count -eq 0)
            {
                Throw "Unable to run the scan"
            }

            $xHosts   = $This.Network.Hosts.IPAddress 
            $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
            $Option   = New-Object System.Net.NetworkInformation.PingOptions
            $Ping     = @{ }
            ForEach ($X in 0..($xHosts.Count-1))
            {
                $Item = New-Object System.Net.NetworkInformation.Ping
                $Ping.Add($X,$Item.SendPingAsync($xHosts[$X],100,$Buffer,$Option))
            }

            ForEach ($X in 0..($Ping.Count-1))
            {
                $This.Network.Hosts[$X].Status = [UInt32]($Ping[$X].Result.Status -eq "Success")
            }
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Master]>"
        }
    }

    [VmNetworkMaster]::New()
}

Function VmTemplate
{
    Class VmByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        VmByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes/1    }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }
    Class VmRole
    {
        [UInt32]  $Index
        [String]   $Type
        VmRole([UInt32]$Index)
        {
            $This.Index = $Index
            $This.Type  = @("Server","Client","Unix")[$Index]
        }
        [String] ToString()
        {
            Return $This.Type
        } 
    }

    Class VmTemplateNetwork
    {
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        VmTemplateNetwork([Object]$Network)
        {
            $This.IPAddress = $Network.FirstAvailableIPAddress()
            $This.Domain    = $Network.Base.Domain
            $This.NetBios   = $Network.Base.NetBios
            $This.Trusted   = $Network.Base.Trusted
            $This.Prefix    = $Network.Base.Prefix
            $This.Netmask   = $Network.Base.Netmask
            $This.Gateway   = $Network.Base.Gateway
            $This.Dns       = $Network.Base.Dns
            $This.Dhcp      = $Network.Dhcp
        }
    }

    Class VmTemplateItem
    {
        [UInt32]    $Index
        [String]     $Name
        [Object]     $Role
        [String]     $Base
        [Object]   $Memory
        [Object]      $Hdd
        [UInt32]      $Gen
        [UInt32]     $Core
        [String] $SwitchId
        [String]    $Image
        VmTemplateItem(
        [UInt32]    $Index,
        [String]     $Name,
        [Object]     $Role,
        [String]     $Path,
        [Object]      $Ram,
        [Object]      $Hdd,
        [UInt32]      $Gen,
        [UInt32]     $Core,
        [String]   $Switch,
        [String]    $Image)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Role     = $Role
            $This.Base     = $Path
            $This.Memory   = $Ram
            $This.Hdd      = $Hdd
            $This.Gen      = $Gen
            $This.Core     = $Core
            $This.SwitchId = $Switch
            $This.Image    = $Image
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Template]>"
        }
    }

    Class VmTemplateFile
    {
        [UInt32]     $Index
        [String]      $Name
        [String]      $Role
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        [String]      $Base
        [UInt64]    $Memory
        [UInt64]       $Hdd
        [UInt32]       $Gen
        [UInt32]      $Core
        [String]  $SwitchId
        [String]     $Image
        VmTemplateFile([Object]$Template,[Object]$Network)
        {
            $This.Index     = $Template.Index
            $This.Name      = $Template.Name
            $This.IpAddress = $Network.IPAddress
            $This.Domain    = $Network.Domain
            $This.NetBios   = $Network.NetBios
            $This.Trusted   = $Network.Trusted
            $This.Prefix    = $Network.Prefix
            $This.Netmask   = $Network.Netmask
            $This.Gateway   = $Network.Gateway
            $This.Dns       = $Network.Dns
            $This.Dhcp      = $Network.Dhcp
            $This.Role      = $Template.Role
            $This.Base      = $Template.Base
            $This.Memory    = $Template.Memory.Bytes
            $This.Hdd       = $Template.Hdd.Bytes
            $This.Gen       = $Template.Gen
            $This.Core      = $Template.Core
            $This.SwitchId  = $Template.SwitchId
            $This.Image     = $Template.Image
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[File]>"
        }
    }

    Class VmTemplateMaster
    {
        [Object] $Output
        VmTemplateMaster()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VmTemplateFile([Object]$Template,[Object]$Network)
        {
            Return [VmTemplateFile]::New($Template,$This.VmTemplateNetwork($Network))
        }
        [Object] VmTemplateNetwork([Object]$Network)
        {
            Return [VmTemplateNetwork]::New($Network)
        }
        [Object] VmTemplateItem(
        [UInt32]   $Index,
        [String]    $Name,
        [Object]    $Type,
        [String]    $Path,
        [Object]     $Ram,
        [Object]     $Hdd,
        [UInt32]     $Gen,
        [UInt32]    $Core,
        [String]  $Switch,
        [String]   $Image)
        {
            Return [VmTemplateItem]::New($Index,
                                         $Name,
                                         $Type,
                                         $Path,
                                         $Ram,
                                         $Hdd,
                                         $Gen,
                                         $Core,
                                         $Switch,
                                         $Image)
        }
        [Object] VmRole([UInt32]$Index)
        {
            Return [VmRole]::New($Index)
        }
        [Object] VmByteSize([String]$Name,[UInt32]$Size)
        {
            Return [VmByteSize]::New($Name,$Size * 1GB)
        }
        Add(
        [String]    $Name,
        [UInt32]    $Type,
        [String]    $Path,
        [UInt32]     $Ram,
        [UInt32]     $Hdd,
        [UInt32]     $Gen,
        [UInt32]    $Core,
        [String]  $Switch,
        [String]   $Image)
        {
            If ($Name -in $This.Output.Name)
            {
                Throw "Item already exists"
            }

            $This.Output += $This.VmTemplateItem($This.Output.Count,
            $Name,
            $This.VmRole($Type),
            $Path,
            $This.VmByteSize("Memory",$Ram),
            $This.VmByteSize("Drive",$Hdd),
            $Gen,
            $Core,
            $Switch,
            $Image)
        }
        Export([String]$Path,[Object]$Network,[UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            $Template = $This.Output[$Index]
            $FilePath = "{0}\{1}.txt" -f $Path, $Template.Name
            $Value    = $This.VmTemplateFile($Template,$Network) | ConvertTo-Json
    
            [System.IO.File]::WriteAllLines($FilePath,$Value)
    
            If ([System.IO.File]::Exists($FilePath))
            {
                [Console]::WriteLine("Exported  [+] File: [$FilePath]")
            }
            Else
            {
                Throw "Something failed... bye."
            }
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Master]>"
        }
    }

    [VmTemplateMaster]::New()
}

Function VmNode
{
    Class VmByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        VmByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes/1    }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Class VmNodeSwitch
    {
        [UInt32]         $Index
        Hidden [Object] $Object
        [String]          $Name
        [String]          $Type
        [String]   $Description
        VmNodeSwitch([UInt32]$Index,[Object]$Object)
        {
            $This.Index       = $Index
            $This.Object      = $Object
            $This.Name        = $Object.Name
            $This.Type        = $Object.SwitchType
            $This.Description = $Object.NetAdapterInterfaceDescription
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Switch]>"
        }
    }

    Class VmNodeHost
    {
        [UInt32]      $Index
        [Object]       $Name
        [Object]     $Memory
        [Object]       $Path
        [Object]        $Vhd
        [Object]    $VhdSize
        [Object] $Generation
        [UInt32]       $Core
        [Object] $SwitchName
        VmNodeHost([UInt32]$Index,[Object]$Node)
        {
            $This.Index      = $Node.Index
            $This.Name       = $Node.Name
            $This.Memory     = $Node.MemoryStartup
            $This.Path       = $Node.Path
            $This.Vhd        = $Node.HardDrives[0].Path
            $This.VhdSize    = $This.Size("HDD",$This.Drive())
            $This.Generation = $Node.Generation
            $This.Core       = $Node.ProcessorCount
            $This.SwitchName = $Node.NetworkAdapters[0].SwitchName
        }
        [UInt64] Drive()
        {
            Return Get-Item $This.Vhd | % Length
        }
        [Object] Size([String]$Name,[UInt64]$SizeBytes)
        {
            Return [VmByteSize]::New($Name,$SizeBytes)
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Host]>"
        }
    }

    Class VmNodeMaster
    {
        [Object] $Switch
        [Object]   $Host
        VmNodeMaster()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Switch = @( )
            $This.Host   = @( )
        }
        [Object] VmNodeSwitch([UInt32]$Index,[Object]$VmSwitch)
        {
            Return [VmNodeSwitch]::New($Index,$VmSwitch)
        }
        [Object] VmNodeHost([UInt32]$Index,[Object]$VmNode)
        {
            Return [VmNodeHost]::New($Index,$VmNode)
        }
        [Object[]] GetVmSwitch()
        {
            Return Get-VmSwitch
        }
        [Object[]] GetVm()
        {
            Return Get-Vm
        }
        AddSwitch([Object]$VmSwitch)
        {
            $This.Switch += $This.VmNodeSwitch($This.Switch.Count,$VmSwitch)
        }
        AddHost([Object]$Node)
        {
            $This.Host += $This.VmNodeHost($This.Host.Count,$Node)
        }
        Refresh()
        {
            $This.Clear()

            # Add switches
            ForEach ($Item in $This.GetVmSwitch())
            {
                $This.AddSwitch($Item)
            }

            # Add nodes
            ForEach ($Item in $This.GetVm())
            {
                $This.AddHost($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Master]>"
        }
    }

    [VmNodeMaster]::New()
}

Function VmCredential
{
    Enum VmCredentialType
    {
        Setup
        System
        Service
        User
    }
    
    Class VmCredentialSlot
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        VmCredentialSlot([String]$Name)
        {
            $This.Index = [UInt32][VmCredentialType]::$Name
            $This.Name  = [VmCredentialType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    Class VmCredentialList
    {
        [Object] $Output
        VmCredentialList()
        {
            $This.Refresh()
        }
        [Object] VmCredentialSlot([String]$Name)
        {
            Return [VmCredentialSlot]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()
    
            ForEach ($Name in [System.Enum]::GetNames([VmCredentialType]))
            {
                $Item             = $This.VmCredentialSlot($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    Setup   { "Meant for strictly setting up a system"          }
                    System  { "To be used at a system level or for maintenance" }
                    Service { "Allows a service to have access"                 }
                    User    { "Specifically for a user account"                 }
                }
    
                $This.Add($Item)
            }
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmCredential[Type[]]"
        }
    }
    
    Class VmCredentialItem
    {
        [UInt32]            $Index
        [Object]             $Type
        [String]         $Username
        Hidden [String]      $Pass
        [PSCredential] $Credential
        VmCredentialItem([UInt32]$Index,[Object]$Type,[PSCredential]$Credential)
        {
            $This.Index      = $Index
            $This.Type       = $Type
            $This.Username   = $Credential.Username
            $This.Credential = $Credential
            $This.Pass       = $This.Mask()
        }
        [String] Password()
        {
            Return $This.Credential.GetNetworkCredential().Password
        }
        [String] Mask()
        {
            Return "<SecureString>"
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmCredential[Item]>"
        }
    }
    
    Class VmCredentialMaster
    {
        [String]        $Name
        Hidden [Object] $Slot
        [UInt32]       $Count
        [Object]      $Output
        VmCredentialMaster()
        {
            $This.Name = "VmCredentialMaster"
            $This.Slot = $This.VmCredentialList()
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
            $This.Setup()
        }
        [Object] VmCredentialList()
        {
            Return [VmCredentialList]::New().Output
        }
        [Object] VmCredentialItem([UInt32]$Index,[String]$Type,[PSCredential]$Credential)
        {
            Return [VmCredentialItem]::New($Index,$Type,$Credential)
        }
        [PSCredential] SetCredential([String]$Username,[String]$Pass)
        {
            Return [PSCredential]::New($Username,$This.SecureString($Pass))
        }
        [PSCredential] SetCredential([String]$Username,[SecureString]$Pass)
        {
            Return [PSCredential]::New($Username,$Pass)
        }
        [SecureString] SecureString([String]$In)
        {
            Return $In | ConvertTo-SecureString -AsPlainText -Force
        }
        [String] Generate()
        {
            Do
            {
                $Length          = $This.Random(10,16)
                $Bytes           = [Byte[]]::New($Length)
    
                ForEach ($X in 0..($Length-1))
                {
                    $Bytes[$X]   = $This.Random(32,126)
                }
    
                $Pass            = [Char[]]$Bytes -join ''
            }
            Until ($Pass -match $This.Pattern())
    
            Return $Pass
        }
        [String] Pattern()
        {
            Return "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
        }
        [UInt32] Random([UInt32]$Min,[UInt32]$Max)
        {
            Return Get-Random -Min $Min -Max $Max
        }
        Setup()
        {
            If ("Administrator" -in $This.Output.Username)
            {
                Throw "Administrator account already exists"
            }
    
            $This.Add(0,"Administrator",$This.Generate())
        }
        Add([UInt32]$Type,[String]$Username,[String]$Pass)
        {
            If ($Type -gt $This.Slot.Count)
            {
                Throw "Invalid account type"
            }
    
            $Credential   = $This.SetCredential($Username,$Pass)
            $This.Output += $This.VmCredentialItem($This.Count,$This.Slot[$Type],$Credential)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Type,[String]$Username,[SecureString]$Pass)
        {
            If ($Type -gt $This.Slot.Count)
            {
                Throw "Invalid account type"
            }
            
            $Credential   = $This.SetCredential($Username,$Pass)
            $This.Output += $This.VmCredentialItem($This.Count,$This.Slot[$Type],$Credential)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmCredential[Master]"
        }
    }

    [VmCredentialMaster]::New()
}

Function VmOldController
{
    Class VmNodeItem
    {
        [UInt32]      $Index
        [Object]       $Name
        [Object]     $Memory
        [Object]       $Path
        [Object]        $Vhd
        [Object]    $VhdSize
        [Object] $Generation
        [UInt32]       $Core
        [Object] $SwitchName
        [Object]    $Network
        VmNodeItem([Object]$Node,[Object]$Hive)
        {
            $This.Index      = $Node.Index
            $This.Name       = $Node.Name
            $This.Memory     = $Hive.Memory
            $This.Path       = $Hive.Base, $This.Name -join '\'
            $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $Hive.Base, $This.Name
            $This.VhdSize    = $This.Size("HDD",$Hive.HDD)
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Item]>"
        }
    }

    Class VmNodeTemplate
    {
        [Object]     $Role
        [String]     $Base
        [UInt64]   $Memory
        [UInt64]      $Hdd
        [UInt32]      $Gen
        [UInt32]     $Core
        [String] $SwitchId
        [String]    $Image
        VmNodeTemplate([UInt32]$Type,[String]$Path,[UInt64]$Ram,[UInt64]$Hdd,[UInt32]$Gen,[UInt32]$Core,[String]$Switch,[String]$Img)
        {
            $This.Role     = $This.VmRole($Type)
            $This.Base     = $Path
            $This.Memory   = $Ram
            $This.Hdd      = $Hdd
            $This.Gen      = $Gen
            $This.Core     = $Core
            $This.SwitchId = $Switch
            $This.Image    = $Img
        }
        [Object] VmRole([UInt32]$Type)
        {
            Return $Null #[VmRole]::New($Type)
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Template]>"
        }
    }

    Class VmNodeFile
    {
        [UInt32]     $Index
        [String]      $Name
        [String]      $Role
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        [String]      $Base
        [UInt64]    $Memory
        [UInt64]       $Hdd
        [UInt32]       $Gen
        [UInt32]      $Core
        [String]  $SwitchId
        [String]     $Image
        VmNodeFile([Object]$Node,[Object]$Template)
        {
            $This.Index     = $Node.Index
            $This.Name      = $Node.Name
            $This.IpAddress = $Node.IpAddress
            $This.Domain    = $Node.Domain
            $This.NetBios   = $Node.NetBios
            $This.Trusted   = $Node.Trusted
            $This.Prefix    = $Node.Prefix
            $This.Netmask   = $Node.Netmask
            $This.Gateway   = $Node.Gateway
            $This.Dns       = $Node.Dns
            $This.Dhcp      = $Node.Dhcp
            $This.Role      = $Template.Role
            $This.Base      = $Template.Base
            $This.Memory    = $Template.Memory
            $This.Hdd       = $Template.Hdd
            $This.Gen       = $Template.Gen
            $This.Core      = $Template.Core
            $This.SwitchId  = $Template.SwitchId
            $This.Image     = $Template.Image
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[File]>"
        }
    }

    Class VmNodeController
    {
        [String]     $Path
        [String]   $Domain
        [String]  $NetBios
        [Object]    $Admin
        [Object]   $Config
        [Object]  $Network
        [Object] $Template
        VmNodeController([String]$Path,[String]$Domain,[String]$NetBios)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                [System.IO.Directory]::CreateDirectory($Path)
            }

            $This.Path     = $Path
            $This.Domain   = $Domain
            $This.NetBios  = $NetBios
            $This.Admin    = $This.NewVmAdminCredential()
            $This.Config   = $This.GetNetIPConfiguration()
            $This.Network  = $This.NewVmNetworkController()
        }
        VmNodeController([String]$Path,[String]$IpAddress,[UInt32]$Prefix,[String]$Gateway,[String[]]$Dns,[String]$Domain,[String]$NetBios)
        {
            $This.Path     = $Path
            $This.Domain   = $Domain
            $This.NetBios  = $NetBios
            $This.Admin    = $This.NewVmAdminCredential()
            $This.Config   = $null
            $This.Network  = $This.NewVmNetworkController($IpAddress,$Prefix,$Gateway,$Dns,$Domain,$NetBios)
        }
        [Object] NewVmAdminCredential()
        {
            Return $Null #[VmAdminCredential]::New("Administrator")
        }
        [Object] GetNetIPConfiguration()
        {
            Return $Null # -Detailed | ? IPV4DefaultGateway | Select-Object -First 1
        }
        [Object] NewVmNetworkController()
        {
            Return $Null #[VmNetworkController]::New($This.Config,$This.Domain,$This.NetBios)
        }
        [Object] NewVmNetworkController([String]$IpAddress,[UInt32]$Prefix,[String]$Gateway,[String[]]$Dns,[String]$Domain,[String]$NetBios)
        {
            Return $Null #[VmNetworkController]::New($IpAddress,$Prefix,$Gateway,$Dns,$Domain,$NetBios)
        }
        [Object] NewVmTemplate([UInt32]$Type,[String]$Base,[UInt64]$Ram,[UInt64]$Hdd,[Uint32]$Generation,[UInt32]$Core,[String]$VMSwitch,[String]$Path)
        {
            Return $Null #[VmNodeTemplate]::New($Type,$Base,$Ram,$Hdd,$Generation,$Core,$VmSwitch,$Path)
        }
        SetTemplate([UInt32]$Type,[String]$Base,[UInt64]$Ram,[UInt64]$Hdd,[Uint32]$Generation,[UInt32]$Core,[String]$VMSwitch,[String]$Path)
        {
            $This.Template = $This.NewVmTemplate($Type,$Base,$Ram,$Hdd,$Generation,$Core,$VmSwitch,$Path)
        }
        [Object] NewVmObjectFile([Object]$Node)
        {
            Return $Null #[VmNodeFile]::New($Node,$This.Template)
        }
        AddNode([String]$Name)
        {
            If ($Name -notin $This.Network.Nodes)
            {
                $This.Network.AddNode($Name)
            }
        }
        Export()
        {
            ForEach ($Node in $This.Network.Nodes)
            {
                $FilePath = "{0}\{1}.txt" -f $This.Path, $Node.Name
                $Value    = $This.NewVmObjectFile($Node) | ConvertTo-Json

                [System.IO.File]::WriteAllLines($FilePath,$Value)

                If ([System.IO.File]::Exists($FilePath))
                {
                    [Console]::WriteLine("Exported  [+] File: [$FilePath]")
                }
                Else
                {
                    Throw "Something failed... bye."
                }
            }
        }
        WriteAdmin()
        {
            $FilePath = "{0}\admin.txt" -f $This.Path 
            $Value    = $This.Admin.Credential.GetNetworkCredential().Password
            [System.IO.File]::WriteAllLines($FilePath,$Value)
            If ([System.IO.File]::Exists($FilePath))
            {
                [Console]::WriteLine("Exported  [+] File: [$FilePath]")
            }
            Else
            {
                Throw "Something failed... bye."
            }
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[Controller]>"
        }
    }

    Class VmNodeInputObject
    {
        [String]   $Path
        [Object] $Object
        [Object]  $Admin
        VmNodeInputObject([String]$Token,[String]$Path)
        {
            $This.Path   = $Path
            $This.Object = $This.SetObject($Token)
            $This.Admin  = $This.SetAdmin()
        }
        [String] GetChildItem([String]$Name)
        {
            $File = Get-ChildItem $This.Path | ? Name -eq $Name

            If (!$File)
            {
                Throw "Invalid entry"
            }

            Return $File.Fullname
        }
        [Object] SetObject([String]$Token)
        {
            $File        = $This.GetChildItem($Token)
            If (!$File)
            {
                Throw "Invalid token"
            }

            Return [System.IO.File]::ReadAllLines($File) | ConvertFrom-Json
        }
        [PSCredential] SetAdmin()
        {
            $File        = $This.GetChildItem("admin.txt")
            If (!$File)
            {
                Throw "No password detected"
            }

            Return [PSCredential]::New("Administrator",$This.GetPassword($File))
        }
        [SecureString] GetPassword([String]$File)
        {
            Return [System.IO.File]::ReadAllLines($File) | ConvertTo-SecureString -AsPlainText -Force
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNode[InputObject]>"
        }
    }

    Class VmScriptBlockLine
    {
        [UInt32] $Index
        [String]  $Line
        VmScriptBlockLine([UInt32]$Index,[String]$Line)
        {
            $This.Index = $Index
            $This.Line  = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    Class VmScriptBlockItem
    {
        [UInt32]       $Index
        [UInt32]       $Phase
        [String]        $Name
        [String] $DisplayName
        [Object]     $Content
        [UInt32]    $Complete
        VmScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
        {
            $This.Index       = $Index
            $This.Phase       = $Phase
            $This.Name        = $Name
            $This.DisplayName = $DisplayName
            
            $This.Load($Content)
        }
        Clear()
        {
            $This.Content     = @( )
        }
        Load([String[]]$Content)
        {
            $This.Clear()
            $This.Add("# $($This.DisplayName)")

            ForEach ($Line in $Content)
            {
                $This.Add($Line)
            }

            $This.Add('')
        }
        [Object] VmScriptBlockLine([UInt32]$Index,[String]$Line)
        {
            Return [VmScriptBlockLine]::New($Index,$Line)
        }
        Add([String]$Line)
        {
            $This.Content += $This.VmScriptBlockLine($This.Content.Count,$Line)
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmScriptBlock[Item]>"
        }
    }

    Class VmScriptBlockController
    {
        [String]     $Name
        [UInt32] $Selected
        [UInt32]    $Count
        [Object]   $Output
        VmScriptBlockController()
        {
            $This.Name = "ScriptBlock[Controller]"
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        Reset()
        {
            ForEach ($Item in $This.Output)
            {
                $Item.Complete = 0
            }

            $This.Selected = 0
        }
        [Object] VmScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
        {
            Return [VmScriptBlockItem]::New($Index,$Phase,$Name,$DisplayName,$Content)
        }
        Add([String]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
        {
            $This.Output += $This.VmScriptBlockItem($This.Output.Count,$Phase,$Name,$DisplayName,$Content)
            $This.Count   = $This.Output.Count
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        [Object] Current()
        {
            Return $This.Output[$This.Selected] 
        }
        [Object] Get([String]$Name)
        {
            Return $This.Output | ? Name -eq $Name
        }
        [Object] Get([UInt32]$Index)
        {
            Return $This.Output | ? Index -eq $Index
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmScriptBlock[Controller]>"
        }
    }

    Class VmPropertyItem
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Value
        VmPropertyItem([UInt32]$Index,[Object]$Property)
        {
            $This.Index = $Index
            $This.Name  = $Property.Name
            $This.Value = $Property.Value
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmProperty[Item]>"
        }
    }

    Class VmPropertyList
    {
        [String] $Name
        [UInt32] $Count
        [Object] $Output
        VmPropertyList()
        {
            $This.Name = "VmProperty[List]"
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VmPropertyItem([UInt32]$Index,[Object]$Property)
        {
            Return [VmPropertyItem]::($Index,$Property)
        }
        Add([Object]$Property)
        {
            $This.Output += $This.VmPropertyItem($This.Output.Count,$Property)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FEVirtual.VmProperty[List]>" -f $This.Count
        }
    }

    Class VmCheckpoint
    {
        Hidden [Object] $Checkpoint
        [UInt32]             $Index
        [String]              $Name
        [String]              $Type
        [DateTime]            $Time
        VmCheckPoint([UInt32]$Index,[Object]$Checkpoint)
        {
            $This.Checkpoint = $Checkpoint
            $This.Index      = $Index
            $This.Name       = $Checkpoint.Name
            $This.Type       = $Checkpoint.SnapshotType
            $This.Time       = $Checkpoint.CreationTime
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmCheckpoint>"
        }
    }

    Class VmObject
    {
        Hidden [UInt32]     $Mode
        Hidden [Object]     $Role
        [Object]         $Console
        [Object]            $Name
        [Object]          $Memory
        [Object]            $Path
        [Object]             $Vhd
        [Object]         $VhdSize
        [Object]      $Generation
        [UInt32]            $Core
        [Object]          $Switch
        [Object]        $Firmware
        [UInt32]          $Exists
        [Object]            $Guid
        [Object]         $Network
        [String]             $Iso
        [Object]          $Script
        [Object]      $Checkpoint
        Hidden [Object] $Property
        Hidden [Object]  $Control
        Hidden [Object] $Keyboard
        VmObject([Switch]$Flags,[Object]$Vm)
        {   
            # Meant for removal if found
            $This.Mode       = 1
            $This.StartConsole()

            $This.Name       = $Vm.Name
            $Item            = $This.Get()
            If (!$Item)
            {
                Throw "Vm does not exist"
            }

            $This.Memory     = $This.Size("Ram",$Item.MemoryStartup)
            $This.Path       = $Item.Path | Split-Path
            $This.Vhd        = $Item.HardDrives[0].Path
            $This.VhdSize    = $This.Size("Hdd",(Get-Vhd $This.Vhd).Size)
            $This.Generation = $Item.Generation
            $This.Core       = $Item.ProcessorCount
            $This.Switch     = @($Item.NetworkAdapters[0].SwitchName)
            $This.Firmware   = $This.GetVmFirmware()
        }
        VmObject([Object]$File)
        {
            # Meant to build a new VM
            $This.Mode       = 1
            $This.Role       = $File.Role
            $This.StartConsole()

            $This.Name       = $File.Name
            If ($This.Get())
            {
                Throw "Vm already exists"
            }

            $This.Memory     = $This.Size("Ram",$File.Memory)
            $This.Path       = "{0}\{1}" -f $File.Base, $This.Name
            $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $File.Base, $This.Name
            $This.VhdSize    = $This.Size("Hdd",$File.HDD)
            $This.Generation = $File.Gen
            $This.Core       = $File.Core
            $This.Switch     = @($File.SwitchId)
            $This.Network    = $This.GetNetworkNode($File)
            $This.Iso        = $File.Image
        }
        StartConsole()
        {
            # Instantiates and initializes the console
            $This.Console = New-FEConsole
            $This.Console.Initialize()
            $This.Status()
        }
        Status()
        {
            # If enabled, shows the last item added to the console
            If ($This.Mode -gt 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        Error([UInt32]$State,[String]$Status)
        {
            $This.Console.Update($State,$Status)
            Throw $This.Console.Last().Status
        }
        DumpConsole()
        {
            $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
            $This.Update(100,"[+] Dumping console: [$xPath]")
            $This.Console.Finalize()
            
            $Value = $This.Console.Output | % ToString

            [System.IO.File]::WriteAllLines($xPath,$Value)
        }
        [String] LogPath()
        {
            $xPath = $This.ProgramData()

            ForEach ($Folder in $This.Author(), "Logs")
            {
                $xPath = $xPath, $Folder -join "\"
                If (![System.IO.Directory]::Exists($xPath))
                {
                    [System.IO.Directory]::CreateDirectory($xPath)
                }
            }

            Return $xPath
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [Object] VmCheckPoint([UInt32]$Index,[Object]$Checkpoint)
        {
            Return [VmCheckPoint]::New($Index,$Checkpoint)
        }
        [Object] Get()
        {
            $Virtual     = Get-VM -Name $This.Name -EA 0
            $This.Exists = $Virtual.Count -gt 0
            $This.Guid   = @($Null,$Virtual.Id)[$This.Exists]

            Return @($Null,$Virtual)[$This.Exists]
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [Object] Size([String]$Name,[UInt64]$SizeBytes)
        {
            Return $Null # [VmByteSize]::New($Name,$SizeBytes)
        }
        [String] Hostname()
        {
            Return [Environment]::MachineName
        }
        [String] GuestName()
        {
            Return $This.Network.Hostname()
        }
        Connect()
        {
            $This.Update(0,"[~] Connecting : $($This.Name)")
            $Splat           = @{

                Filepath     = "vmconnect"
                ArgumentList = @($This.Hostname(),$This.Name)
                Verbose      = $True
                PassThru     = $True
            }

            Start-Process @Splat
        }
        New()
        {
            $Null = $This.Get()
            If ($This.Exists -ne 0)
            {
                $This.Error(-1,"[!] Exists : $($This.Name)")
            }

            $Object                = @{

                Name               = $This.Name
                MemoryStartupBytes = $This.Memory.Bytes
                Path               = $This.Path
                NewVhdPath         = $This.Vhd
                NewVhdSizeBytes    = $This.VhdSize.Bytes
                Generation         = $This.Generation
                SwitchName         = $This.Switch[0]
            }

            $This.Update(0,"[~] Creating : $($This.Name)")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { New-VM @Object }
                2       { New-VM @Object -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VMMemory -VmName $This.Name -DynamicMemoryEnabled 0 }
                2       { Set-VMMemory -VmName $This.Name -DynamicMemoryEnabled 0 -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Enable-VmResourceMetering -VmName $This.Name }
                2       { Enable-VmResourceMetering -VmName $This.Name -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-Vm -Name $This.Name -CheckpointType Standard } 
                2       { Set-Vm -Name $This.Name -CheckpointType Standard -Verbose -EA 0 } 
            }

            $Item                  = $This.Get()
            $This.Firmware         = $This.GetVmFirmware()
            $This.SetVMProcessor()

            $This.Script           = $This.NewVmScriptBlockController()
            $This.Property         = $This.NewVmPropertyList()

            ForEach ($Property in $Item.PSObject.Properties)
            {
                $This.Property.Add($Property)
            }
        }
        Start()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }
            
            ElseIf ($Vm.State -eq "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [already started]")
            }

            Else
            {
                $This.Update(1,"[~] Starting : $($This.Name)")

                # Verbosity level
                Switch ($This.Mode) 
                { 
                    Default { $Vm | Start-VM }
                    2       { $Vm | Start-VM -Verbose }
                }
            }
        }
        Stop()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($Vm.State -ne "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Stopping : $($This.Name)")
            
                # Verbosity level
                Switch ($This.Mode)
                {
                    Default { $This.Get() | ? State -ne Off | Stop-VM -Force }
                    2       { $This.Get() | ? State -ne Off | Stop-VM -Force -Verbose }
                }
            }
        }
        Reset()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($Vm.State -ne "Running")
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Restarting : $($This.Name)")
                $This.Stop()
                $This.Start()
                $This.Idle(5,5)
            }
        }
        Remove()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error(-1,"[!] Exception : $($This.Name) [does not exist]")
            }

            $This.Update(0,"[~] Removing : $($This.Name)")

            If ($Vm.State -ne "Off")
            {
                $This.Update(0,"[~] State : $($This.Name) [attempting shutdown]")
                Switch -Regex ($Vm.State)
                {
                    "(^Paused$|^Saved$)"
                    { 
                        $This.Start()
                        Do
                        {
                            Start-Sleep 1
                        }
                        Until ($This.Get().State -eq "Running")
                    }
                }

                $This.Stop()
                Do
                {
                    Start-Sleep 1
                }
                Until ($This.Get().State -eq "Off")
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { $This.Get() | Remove-VM -Confirm:$False -Force -EA 0 } 
                2       { $This.Get() | Remove-VM -Confirm:$False -Force -Verbose -EA 0 } 
            }
            
            $This.Firmware         = $Null
            $This.Exists           = 0

            $This.Update(0,"[~] Vhd  : [$($This.Vhd)]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Remove-Item $This.Vhd -Confirm:$False -Force -EA 0 } 
                2       { Remove-Item $This.Vhd -Confirm:$False -Force -Verbose -EA 0 } 
            }
            
            $This.Update(0,"[~] Path : [$($This.Path)]")
            ForEach ($Item in Get-ChildItem $This.Path -Recurse | Sort-Object -Descending)
            {
                $This.Update(0,"[~] $($Item.Fullname)")

                # Verbosity level
                Switch ($This.Mode)
                { 
                    Default { Remove-Item $Item.Fullname -Confirm:$False -EA 0 } 
                    2       { Remove-Item $Item.Fullname -Confirm:$False -Verbose -EA 0 } 
                }
            }

            $This.Update(1,"[ ] Removed : $($Item.Fullname)")

            $This.DumpConsole()
        }
        GetCheckpoint()
        {
            $This.Update(0,"[~] Getting Checkpoint(s)")

            $This.Checkpoint = @( )
            $List            = Switch ($This.Mode)
            { 
                Default { Get-VmCheckpoint -VMName $This.Name -EA 0 } 
                2       { Get-VmCheckpoint -VMName $This.Name -Verbose -EA 0 } 
            }
            
            If ($List.Count -gt 0)
            {
                ForEach ($Item in $List)
                {
                    $This.Checkpoint += $This.VmCheckpoint($This.Checkpoint.Count,$Item)
                }
            }
        }
        NewCheckpoint()
        {
            $ID = "{0}-{1}" -f $This.Name, $This.Now()
            $This.Update(0,"[~] New Checkpoint [$ID]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { $This.Get() | Checkpoint-Vm -SnapshotName $ID }
                2       { $This.Get() | Checkpoint-Vm -SnapshotName $ID -Verbose -EA 0 } 
            }

            $This.GetCheckpoint()
        }
        RestoreCheckpoint([UInt32]$Index)
        {
            If ($Index -gt $This.Checkpoint.Count)
            {
                Throw "Invalid index"
            }

            $Item = $This.Checkpoint[$Index]

            $This.Update(0,"[~] Restoring Checkpoint [$($Item.Name)]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Restore-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -EA 0 }
                2       { Restore-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -Verbose -EA 0 } 
            }
        }
        RestoreCheckpoint([String]$String)
        {
            $Item = $This.Checkpoint | ? Name -match $String

            If (!$Item)
            {
                Throw "Invalid entry"
            }
            ElseIf ($Item.Count -gt 1)
            {
                $This.Update(0,"[!] Multiple entries detected, select index or limit search string")

                $D = (([String[]]$Item.Index) | Sort-Object Length)[-1].Length
                $Item | % {

                    $Line = "({0:d$D}) [{1}]: {2}" -f $_.Index, $_.Time.ToString("MM-dd-yyyy HH:mm:ss"), $_.Name
                    [Console]::WriteLine($Line)
                }
            }
            Else
            {
                $This.RestoreCheckpoint($Item.Index)
            }
        }
        RemoveCheckpoint([UInt32]$Index)
        {
            If ($Index -gt $This.Checkpoint.Count)
            {
                Throw "Invalid index"
            }

            $Item = $This.Checkpoint[$Index]

            $This.Update(0,"[~] Removing Checkpoint [$($Item.Name)]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Remove-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -EA 0 }
                2       { Remove-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -Verbose -EA 0 } 
            }

            $This.GetCheckpoint()
        }
        [Object] Measure()
        {
            If (!$This.Exists)
            {
                Throw "Cannot measure a virtual machine when it does not exist"
            }

            Return Measure-Vm -Name $This.Name
        }
        [Object] Wmi([String]$Type)
        {
            Return Get-WmiObject $Type -NS Root\Virtualization\V2
        }
        [Object] GetNetworkNode([Object]$File)
        {
            Return $Null # [VmNetworkNode]::New($File)
        }
        [String] GetRegistryPath()
        {
            Return "HKLM:\Software\Policies\Secure Digits Plus LLC"
        }
        [Object] NewVmPropertyList()
        {
            Return [VmPropertyList]::New()
        }
        [Object] NewVmScriptBlockController()
        {
            Return [VmScriptBlockController]::New()
        }
        [Object] GetVmFirmware()
        {
            $This.Update(0,"[~] Getting VmFirmware : $($This.Name)")
            $Item = Switch ($This.Generation) 
            { 
                1
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    { 
                        Default { Get-VmBios -VmName $This.Name } 
                        2       { Get-VmBios -VmName $This.Name -Verbose } 
                    }
                }
                2 
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    {
                        Default { Get-VmFirmware -VmName $This.Name }
                        2       { Get-VmFirmware -VmName $This.Name -Verbose }
                    }
                } 
            }

            Return $Item
        }
        SetVmProcessor()
        {
            $This.Update(0,"[~] Setting VmProcessor (Count): [$($This.Core)]")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmProcessor -VMName $This.Name -Count $This.Core }
                2       { Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose }
            }
        }
        SetVmDvdDrive([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error(-1,"[!] Invalid path : [$Path]")
            }

            $This.Update(0,"[~] Setting VmDvdDrive (Path): [$Path]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Path } 
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose }
            }
        }
        SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $This.Update(0,"[~] Setting VmFirmware (Boot order) : [$1,$2,$3]")

            $Fw = $This.GetVmFirmware()
                
            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] } 
                2       { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] -Verbose } 
            }
        }
        SetVmSecureBoot([String]$Template)
        {
            $This.Update(0,"[~] Setting VmFirmware (Secure Boot) On, $Template")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VMFirmware -VMName $This.Name -EnableSecureBoot On -SecureBootTemplate $Template }
                2       { Set-VMFirmware -VMName $This.Name -EnableSecureBoot On -SecureBootTemplate $Template -Verbose }
            }
        }
        AddVmDvdDrive()
        {
            $This.Update(0,"[+] Adding VmDvdDrive")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Add-VmDvdDrive -VMName $This.Name }
                2       { Add-VmDvdDrive -VMName $This.Name -Verbose }
            }
        }
        LoadIso([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error(-1,"[!] Invalid ISO path : [$Path]")
            }

            Else
            {
                $This.Iso = $Path
                $This.SetVmDvdDrive($This.Iso)
            }
        }
        UnloadIso()
        {
            $This.Update(0,"[+] Unloading ISO")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Null }
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Null -Verbose }
            }
        }
        SetIsoBoot()
        {
            If (!$This.Iso)
            {
                $This.Error(-1,"[!] No (*.iso) file loaded")
            }

            ElseIf ($This.Generation -eq 2)
            {
                $This.SetVmBootOrder(2,0,1)
            }
        }
        [String[]] GetMacAddress()
        {
            $String = $This.Get().NetworkAdapters[0].MacAddress
            $Mac    = ForEach ($X in 0,2,4,6,8,10)
            {
                $String.Substring($X,2)
            }

            Return $Mac -join "-"
        }
        TypeChain([UInt32[]]$Array)
        {
            ForEach ($Key in $Array)
            {
                $This.TypeKey($Key)
                Start-Sleep -Milliseconds 125
            }
        }
        TypeKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Typing key : [$Index]")
            $This.Keyboard.TypeKey($Index)
            Start-Sleep -Milliseconds 125
        }
        TypeText([String]$String)
        {
            $This.Update(0,"[+] Typing text : [$String]")
            $This.Keyboard.TypeText($String)
            Start-Sleep -Milliseconds 125
        }
        TypePassword([Object]$Account)
        {
            $This.Update(0,"[+] Typing password : [ActualPassword]")
            $This.Keyboard.TypeText($Account.Password())
            Start-Sleep -Milliseconds 125
        }
        PressKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Pressing key : [$Index]")
            $This.Keyboard.PressKey($Index)
        }
        ReleaseKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Releasing key : [$Index]")
            $This.Keyboard.ReleaseKey($Index)
        }
        SpecialKey([UInt32]$Index)
        {
            $This.Keyboard.PressKey(18)
            $This.Keyboard.TypeKey($Index)
            $This.Keyboard.ReleaseKey(18)
        }
        [UInt32] GetKey([Char]$Char)
        {
            Return [UInt32][Char]$Char
        }
        ShiftKey([UInt32[]]$Index)
        {
            $This.Keyboard.PressKey(16)
            ForEach ($X in $Index)
            {
                $This.Keyboard.TypeKey($X)
            }
            $This.Keyboard.ReleaseKey(16)
        }
        TypeCtrlAltDel()
        {
            $This.Update(0,"[+] Typing (CTRL + ALT + DEL)")
            $This.Keyboard.TypeCtrlAltDel()
        }
        Idle([UInt32]$Percent,[UInt32]$Seconds)
        {
            $This.Update(0,"[~] Idle : $($This.Name) [CPU <= $Percent% for $Seconds second(s)]")
            
            $C = 0
            Do
            {
                Switch ([UInt32]($This.Get().CpuUsage -le $Percent))
                {
                    0 { $C = 0 } 1 { $C ++ }
                }

                Start-Sleep -Seconds 1
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Idle complete")
        }
        Uptime([UInt32]$Mode,[UInt32]$Seconds)
        {
            $Mark = @("<=",">=")[$Mode]
            $Flag = 0
            $This.Update(0,"[~] Uptime : $($This.Name) [Uptime $Mark $Seconds second(s)]")
            Do
            {
                Start-Sleep -Seconds 1
                $Uptime        = $This.Get().Uptime.TotalSeconds
                [UInt32] $Flag = Switch ($Mode) { 0 { $Uptime -le $Seconds } 1 { $Uptime -ge $Seconds } }
            }
            Until ($Flag)
            $This.Update(1,"[+] Uptime complete")
        }
        Timer([UInt32]$Seconds)
        {
            $This.Update(0,"[~] Timer : $($This.Name) [Span = $Seconds]")

            $C = 0
            Do
            {
                Start-Sleep -Seconds 1
                $C ++
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Timer")
        }
        Connection()
        {
            $This.Update(0,"[~] Connection : $($This.Name) [Await response]")

            Do
            {
                Start-Sleep 1
            }
            Until (Test-Connection $This.Network.IpAddress -EA 0)

            $This.Update(1,"[+] Connection")
        }
        [Void] AddScript([UInt32]$Phase,[String]$Name,[String]$DisplayName,[String[]]$Content)
        {
            $This.Script.Add($Phase,$Name,$DisplayName,$Content)
            $This.Update(0,"[+] Added (Script) : $Name")
        }
        [Object] GetScript([UInt32]$Index)
        {
            $Item = $This.Script.Get($Index)
            If (!$Item)
            {
                $This.Error("[!] Invalid index")
            }
            
            Return $Item
        }
        [Object] GetScript([String]$Name)
        {
            $Item = $This.Script.Get($Name)
            If (!$Item)
            {
                $This.Error(-1,"[!] Invalid name")
            }
            
            Return $Item
        }
        [Void] RunScript()
        {
            $Item = $This.Script.Current()

            If ($Item.Complete -eq 1)
            {
                $This.Error(-1,"[!] Exception (Script) : [$($Item.Name)] already completed")
            }

            $This.Update(0,"[~] Running (Script) : [$($Item.Name)]")
            ForEach ($Line in $Item.Content)
            {
                Switch -Regex ($Line)
                {
                    "^\<Pause\[\d+\]\>$"
                    {
                        $Line -match "\d+"
                        $This.Timer($Matches[0])
                    }
                    "^$"
                    {
                        $This.Idle(5,2)
                    }
                    Default
                    {
                        $This.TypeText($Line)
                        $This.TypeKey(13)
                    }
                }
            }

            $This.Update(1,"[+] Complete (Script) : [$($Item.Name)]")

            $Item.Complete = 1
            $This.Script.Selected ++
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class VmWindows : VmObject
    {
        VmWindows([Switch]$Flags,[Object]$Vm) : base($Flags,$Vm)
        {   
            
        }
        VmWindows([Object]$File) : base($File)
        {

        }
        [UInt32] NetworkSetupMode()
        {
            # [Windows (Server/Client)]
            $Arp = (arp -a) -match $This.GetMacAddress() -Split " " | ? Length -gt 0

            Return !!$Arp
        }
        SetAdmin([Object]$Account)
        {
            # [Windows (Server)]
            $This.Update(0,"[~] Setting : Administrator password")
            ForEach ($X in 0..1)
            {
                $This.TypePassword($Account)
                $This.TypeKey(9)
                Start-Sleep -Milliseconds 125
            }

            $This.TypeKey(9)
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        Login([Object]$Account)
        {
            # [Windows (Server/Client)]
            If ($Account.GetType().Name -notmatch "(VmAdminCredential|SecurityOptionController)")
            {
                $This.Error("[!] Invalid input object")
            }

            $This.Update(0,"[~] Login : [Account: $($Account.Username())")
            $This.TypeCtrlAltDel()
            $This.Timer(5)
            $This.TypePassword($Account)
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        LaunchPs()
        {
            # [Windows (Server/Client)]

            # Open Start Menu
            $This.PressKey(91)
            $This.TypeKey(88)
            $This.ReleaseKey(91)
            $This.Timer(1)

            Switch ($This.Role)
            {
                Server
                {
                    # Open Command Prompt
                    $This.TypeKey(65)
                    $This.Timer(2)

                    # Maximize window
                    $This.PressKey(91)
                    $This.TypeKey(38)
                    $This.ReleaseKey(91)
                    $This.Timer(1)

                    # Start PowerShell
                    $This.TypeText("PowerShell")
                    $This.TypeKey(13)
                    $This.Timer(1)
                }
                Client
                {
                    # // Open [PowerShell]
                    $This.TypeKey(65)
                    $This.Timer(2)
                    $This.TypeKey(37)
                    $This.Timer(2)
                    $This.TypeKey(13)
                    $This.Timer(2)

                    # // Maximize window
                    $This.PressKey(91)
                    $This.TypeKey(38)
                    $This.ReleaseKey(91)
                    $This.Timer(1)
                }
            }

            # Wait for PowerShell engine to get ready for input
            $This.Idle(5,5)
        }
        [String[]] PrepPersistentInfo()
        {
            # [Windows (Server/Client)]

            # Prepare the correct persistent information
            $List = @( ) 

            $List += '$P = @{ }'
            ForEach ($P in @($This.Network.PSObject.Properties | ? Name -ne Dhcp))
            { 
                $List += Switch -Regex ($P.TypeNameOfValue)
                {
                    Default
                    {
                        '$P.Add($P.Count,("{0}","{1}"))' -f $P.Name, $P.Value
                    }
                    "\[\]"
                    {
                        '$P.Add($P.Count,("{0}",@([String[]]"{1}")))' -f $P.Name, ($P.Value -join "`",`"")
                    }
                }
            }
            
            If ($This.Role -eq "Server")
            {
                $List += '$P.Add($P.Count,("Dhcp","$Dhcp"))'
            }
            
            $List += '$P[0..($P.Count-1)] | % { Set-ItemProperty -Path $Path -Name $_[0] -Value $_[1] -Verbose }'

            If ($This.Role -eq "Server")
            {
                $List += '$P = @{ }'
                
                ForEach ($P in @($This.Network.Dhcp.PSObject.Properties))
                {
                    $List += Switch -Regex ($P.TypeNameOfValue)
                    {
                        Default
                        {
                            '$P.Add($P.Count,("{0}","{1}"))' -f $P.Name, $P.Value
                        }
                        "\[\]"
                        {
                            '$P.Add($P.Count,("{0}",@([String[]]"{1}")))' -f $P.Name, ($P.Value -join "`",`"")
                        }
                    }
                }

                $List += '$P[0..($P.Count-1)] | % { Set-ItemProperty -Path $Dhcp -Name $_[0] -Value $_[1] -Verbose }'
            }

            Return $List
        }
        SetPersistentInfo()
        {
            # [Windows (Server/Client)]

            # [Phase 1] Set persistent information
            $This.Script.Add(1,"SetPersistentInfo","Set persistent information",@(
            '$Root      = "{0}"' -f $This.GetRegistryPath();
            '$Name      = "{0}"' -f $This.Name;
            '$Path      = "$Root\ComputerInfo"';
            'Rename-Computer $Name -Force';
            'If (!(Test-Path $Root))';
            '{';
            '    New-Item -Path $Root -Verbose';
            '}';
            'New-Item -Path $Path -Verbose';
            If ($This.Role -eq "Server")
            {
                '$Dhcp = "$Path\Dhcp"';
                'New-Item $Dhcp';
            }
            $This.PrepPersistentInfo()))
        }
        SetTimeZone()
        {
            # [Windows (Server/Client)]

            # [Phase 2] Set time zone
            $This.Script.Add(2,"SetTimeZone","Set time zone",@('Set-Timezone -Name "{0}" -Verbose' -f (Get-Timezone).Id))
        }
        SetComputerInfo()
        {
            # [Windows (Server/Client)]

            # [Phase 3] Set computer info
            $This.Script.Add(3,"SetComputerInfo","Set computer info",@(
            '$Item           = Get-ItemProperty "{0}\ComputerInfo"' -f $This.GetRegistryPath() 
            '$TrustedHost    = $Item.Trusted';
            '$IPAddress      = $Item.IpAddress';
            '$PrefixLength   = $Item.Prefix';
            '$DefaultGateway = $Item.Gateway';
            '$Dns            = $Item.Dns'))
        }
        SetIcmpFirewall()
        {
            # [Windows (Server/Client)]

            $Content = Switch ($This.Role)
            {
                Server
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose'
                }
                Client
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose',
                    'Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -Verbose'
                }
            }

            # [Phase 4] Enable IcmpV4
            $This.Script.Add(4,"SetIcmpFirewall","Enable IcmpV4",@($Content))
        }
        SetInterfaceNull()
        {
            # [Windows (Server/Client)]

            # [Phase 5] Get InterfaceIndex, get/remove current (IP address + Net Route)
            $This.Script.Add(5,"SetInterfaceNull","Get InterfaceIndex, get/remove current (IP address + Net Route)",@(
            '$Index              = Get-NetAdapter | ? Status -eq Up | % InterfaceIndex';
            '$Interface          = Get-NetIPAddress    -AddressFamily IPv4 -InterfaceIndex $Index';
            '$Interface          | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$False -Verbose';
            '$Interface          | Remove-NetRoute     -AddressFamily IPv4 -Confirm:$False -Verbose'))
        }
        SetStaticIp()
        {
            # [Windows (Server/Client)]

            # [Phase 6] Set static IP Address
            $This.Script.Add(6,"SetStaticIp","Set (static IP Address + Dns server)",@(
            '$Splat              = @{';
            ' ';
            '    InterfaceIndex  = $Index';
            '    AddressFamily   = "IPv4"';
            '    PrefixLength    = $Item.Prefix';
            '    ValidLifetime   = [Timespan]::MaxValue';
            '    IPAddress       = $Item.IPAddress';
            '    DefaultGateway  = $Item.Gateway';
            '}';
            'New-NetIPAddress @Splat';
            'Set-DnsClientServerAddress -InterfaceIndex $Index -ServerAddresses $Item.Dns'))
        }
        SetWinRm()
        {
            # [Windows (Server/Client)]

            # [Phase 7] Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)
            $This.Script.Add(7,"SetWinRm","Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)",@(
            'winrm quickconfig';
            '<Pause[2]>';
            'y';
            '<Pause[3]>';
            If ($This.Role -eq "Client")
            {
                'y';
                '<Pause[3]>';
            }
            'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $Item.Trusted';
            '<Pause[4]>';
            'y';
            '$Cert       = New-SelfSignedCertificate -DnsName $Item.IpAddress -CertStoreLocation Cert:\LocalMachine\My';
            '$Thumbprint = $Cert.Thumbprint';
            '$Hash       = "@{Hostname=`"$IPAddress`";CertificateThumbprint=`"$Thumbprint`"}"';
            "`$Str         = `"winrm create winrm/config/Listener?Address=*+Transport=HTTPS '{0}'`"";
            'Invoke-Expression ($Str -f $Hash)'))
        }
        SetWinRmFirewall()
        {
            # [Windows (Server/Client)]

            # [Phase 8] Set WinRm Firewall
            $This.Script.Add(8,"SetWinRmFirewall",'Set WinRm Firewall',@(
            '$Splat          = @{';
            ' ';
            '    Name        = "WinRM/HTTPS"';
            '    DisplayName = "Windows Remote Management (HTTPS-In)"';
            '    Direction   = "In"';
            '    Action      = "Allow"';
            '    Protocol    = "TCP"';
            '    LocalPort   = 5986';
            '}';
            'New-NetFirewallRule @Splat -Verbose'))
        }
        SetRemoteDesktop()
        {
            # [Windows (Server/Client)]

            # [Phase 9] Set Remote Desktop
            $This.Script.Add(9,"SetRemoteDesktop",'Set Remote Desktop',@(
            'Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0';
            'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'))
        }
        InstallFeModule()
        {
            # [Windows (Server/Client)]

            # [Phase 10] Install [FightingEntropy()]
            $This.Script.Add(10,"InstallFeModule","Install [FightingEntropy()]",@(
            '[Net.ServicePointManager]::SecurityProtocol = 3072'
            'Set-ExecutionPolicy Bypass -Scope Process -Force'
            '$Install = "https://github.com/mcc85s/FightingEntropy"'
            '$Full    = "$Install/blob/main/Version/2022.12.0/FightingEntropy.ps1?raw=true"'
            'Invoke-RestMethod $Full | Invoke-Expression'
            '$Module.Install()'
            'Import-Module FightingEntropy'))
        }
        InstallChoco()
        {
            # [Windows (Server/Client)]

            # [Phase 11] Install Chocolatey
            $This.Script.Add(11,"InstallChoco","Install Chocolatey",@(
            "Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression"))
        }
        InstallVsCode()
        {
            # [Windows (Server/Client)]

            # [Phase 12] Install Visual Studio Code
            $This.Script.Add(12,"InstallVsCode","Install Visual Studio Code",@("choco install vscode -y"))
        }
        InstallBossMode()
        {
            # [Windows (Server/Client)]

            # [Phase 13] Install BossMode (vscode color theme)
            $This.Script.Add(13,"InstallBossMode","Install BossMode (vscode color theme)",@("Install-BossMode"))
        }
        InstallPsExtension()
        {
            # [Windows (Server/Client)]

            # [Phase 14] Install Visual Studio Code (PowerShell Extension)
            $This.Script.Add(14,"InstallPsExtension","Install Visual Studio Code (PowerShell Extension)",@(
            '$FilePath     = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
            '$ArgumentList = "--install-extension ms-vscode.PowerShell"';
            'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process'))
        }
        RestartComputer()
        {
            # [Windows (Server/Client)]

            # [Phase 15] Restart computer
            $This.Script.Add(15,'Restart','Restart computer',@('Restart-Computer'))
        }
        ConfigureDhcp()
        {
            # [Windows (Server/Client)]

            # [Phase 16] Configure Dhcp
            $This.Script.Add(16,'ConfigureDhcp','Configure Dhcp',@(
            '$Root           = "{0}"' -f $This.GetRegistryPath()
            '$Path           = "$Root\ComputerInfo"'
            '$Item           = Get-ItemProperty $Path' 
            '$Item.Dhcp      = Get-ItemProperty $Item.Dhcp';
            ' ';
            '$Splat = @{ ';
            '   ';
            '    StartRange = $Item.Dhcp.StartRange';
            '    EndRange   = $Item.Dhcp.EndRange';
            '    Name       = $Item.Dhcp.Name';
            '    SubnetMask = $Item.Dhcp.SubnetMask';
            '}';
            '';
            'Add-DhcpServerV4Scope @Splat -Verbose';
            'Add-DhcpServerInDc -Verbose';
            ' ';
            'ForEach ($Value in $Item.Dhcp.Exclusion)';
            '{';
            '    $Splat         = @{ ';
            ' ';
            '        ScopeId    = $Item.Dhcp.Network';
            '        StartRange = $Value';
            '        EndRange   = $Value';
            '    }';
            ' ';
            '    Add-DhcpServerV4ExclusionRange @Splat -Verbose';
            ' ';
            '   (3,$Item.Gateway),';
            '   (6,$Item.Dns),';
            '   (15,$Item.Domain),';
            '   (28,$Item.Dhcp.Broadcast) | % {';
            '    ';
            '       Set-DhcpServerV4OptionValue -OptionId $_[0] -Value $_[1] -Verbose'
            '   }';
            '}';
            'netsh dhcp add securitygroups';
            'Restart-Service dhcpserver';
            ' ';
            '$Splat    = @{ ';
            ' ';
            '    Path  = "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12"';
            '    Name  = "ConfigurationState"';
            '    Value = 2';
            '}';
            ' ';
            'Set-ItemProperty @Splat -Verbose'))
        }
        InitializeFeAd([String]$Pass)
        {
            # [Windows (Server)]

            $This.Script.Add(17,'InitializeAd','Initialize [FightingEntropy()] AdInstance',@(
            '$Password = Read-Host "Enter password" -AsSecureString';
            '<Pause[2]>';
            '{0}' -f $Pass;
            '$Ctrl = Initialize-FeAdInstance';
            ' ';
            '# Set location';
            '$Ctrl.SetLocation("1718 US-9","Clifton Park","NY",12065,"US")';
            ' ';
            '# Add Organizational Unit';
            '$Ctrl.AddAdOrganizationalUnit("DevOps","Developer(s)/Operator(s)")';
            ' ';
            '# Get Organizational Unit';
            '$Ou     = $Ctrl.GetAdOrganizationalUnit("DevOps")';
            ' ';
            '# Add Group';
            '$Ctrl.AddAdGroup("Engineering","Security","Global","Secure Digits Plus LLC",$Ou.DistinguishedName)';
            ' ';
            '# Get Group';
            '$Group  = $Ctrl.GetAdGroup("Engineering")';
            ' ';
            '# Add-AdPrincipalGroupMembership';
            '$Ctrl.AddAdPrincipalGroupMembership($Group.Name,@("Administrators","Domain Admins"))';
            ' ';
            '# Add User';
            '$Ctrl.AddAdUser("Michael","C","Cook","mcook85",$Ou.DistinguishedName)';
            ' ';
            '# Get User';
            '$User   = $Ctrl.GetAdUser("Michael","C","Cook")';
            ' ';
            '# Set [User.General (Description, Office, Email, Homepage)]';
            '$User.SetGeneral("Beginning the fight against ID theft and cybercrime",';
            '                 "<Unspecified>",';
            '                 "michael.c.cook.85@gmail.com",';
            '                 "https://github.com/mcc85s/FightingEntropy")';
            ' ';
            '# Set [User.Address (StreetAddress, City, State, PostalCode, Country)] ';
            '$User.SetLocation($Ctrl.Location)';
            ' ';
            '# Set [User.Profile (ProfilePath, ScriptPath, HomeDirectory, HomeDrive)]';
            '$User.SetProfile("","","","")';
            ' ';
            '# Set [User.Telephone (HomePhone, OfficePhone, MobilePhone, Fax)]';
            '$User.SetTelephone("","518-406-8569","518-406-8569","")';
            ' ';
            '# Set [User.Organization (Title, Department, Company)]';
            '$User.SetOrganization("CEO/Security Engineer","Engineering","Secure Digits Plus LLC")';
            ' ';
            '# Set [User.AccountPassword]';
            '$User.SetAccountPassword($Password)';
            ' ';
            '# Add user to group';
            '$Ctrl.AddAdGroupMember($Group,$User)';
            ' ';
            '# Set user primary group';
            '$User.SetPrimaryGroup($Group)'))
        }
        Load()
        {
            # [Windows (Server/Client)]

            $This.SetPersistentInfo()
            $This.SetTimeZone()
            $This.SetComputerInfo()
            $This.SetIcmpFirewall()
            $This.SetInterfaceNull()
            $This.SetStaticIp()
            $This.SetWinRm()
            $This.SetWinRmFirewall()
            $This.SetRemoteDesktop()
            $This.InstallFeModule()
            $This.InstallChoco()
            $This.InstallVsCode()
            $This.InstallBossMode()
            $This.InstallPsExtension()
            $This.RestartComputer()
            $This.ConfigureDhcp()
        }
        [Object] PSSession([Object]$Account)
        {
            # [Windows (Server/Client)]

            # Attempt login
            $This.Update(0,"[~] PSSession Token")
            $Splat = @{

                ComputerName  = $This.Network.IpAddress
                Port          = 5986
                Credential    = $Account.Credential
                SessionOption = New-PSSessionOption -SkipCACheck
                UseSSL        = $True
            }

            Return $Splat
        }
    }

    Class VmLinux : VmObject
    {
        VmLinux([Switch]$Flags,[Object]$Vm) : base($Flags,$Vm)
        {   
            
        }
        VmLinux([Object]$File) : base($File)
        {

        }
        Login([Object]$Account)
        {
            # Login
            $This.Update(0,"Login [+] [$($This.Name): $([DateTime]::Now)]")
            $This.TypeKey(9)
            $This.TypeKey(13)
            $This.Timer(1)
            $This.LinuxPassword($Account.Password())
            $This.TypeKey(13)
            $This.Idle(0,5)
        }
        LinuxType([String]$Entry)
        {
            # [Linux]
            $This.Update(0,"[+] Type entry : [$Entry]")
            ForEach ($Char in [Char[]]$Entry)
            {
                $This.Update(0,"[+] Typing key : [$Char]")
                $This.LinuxKey($Char)
            }
        }
        LinuxPassword([String]$Entry)
        {
            # [Linux]
            $This.Update(0,"[+] Typing password : [<ActualPassword>]")

            ForEach ($Char in [Char[]]$Entry)
            {
                $This.LinuxKey($Char)
            }
        }
        LinuxKey([Char]$Char)
        {
            # [Linux]
            $Int = [UInt32]$Char
            
            If ($Int -in @(33..38+40..43+58+60+62..90+94+95+123..126))
            {
                Switch ($Int)
                {
                    {$_ -in 65..90}
                    {
                        # Lowercase
                        $Int = [UInt32][Char]([String]$Char).ToUpper()
                    }
                    {$_ -in 33,64,35,36,37,38,40,41,94,42}
                    {
                        # Shift+number symbols
                        $Int = Switch ($Int)
                        {
                            33  { 49 } 64  { 50 } 35  { 51 }
                            36  { 52 } 37  { 53 } 94  { 54 }
                            38  { 55 } 42  { 56 } 40  { 57 }
                            41  { 48 }
                        }
                    }
                    {$_ -in 58,43,60,95,62,63,126,123,124,125,34}
                    {
                        # Non-number symbols
                        $Int = Switch ($Int)
                        {
                            58  { 186 } 43  { 187 } 60  { 188 } 
                            95  { 189 } 62  { 190 } 63  { 191 } 
                            126 { 192 } 123 { 219 } 124 { 220 } 
                            125 { 221 } 34  { 222 }
                        }
                    }
                }

                $This.Keyboard.PressKey(16)
                Start-Sleep -Milliseconds 10
                
                $This.Keyboard.TypeKey($Int)
                Start-Sleep -Milliseconds 10

                $This.Keyboard.ReleaseKey(16)
                Start-Sleep -Milliseconds 10
            }
            Else
            {
                Switch ($Int)
                {
                    {$_ -in 97..122} # Lowercase
                    {
                        $Int = [UInt32][Char]([String]$Char).ToUpper()
                    }
                    {$_ -in 48..57} # Numbers
                    {
                        $Int = [UInt32][Char]$Char
                    }
                    {$_ -in 32,59,61,44,45,46,47,96,91,92,93,39}
                    {
                        $Int = Switch ($Int)
                        {
                            32  {  32 } 59  { 186 } 61  { 187 } 
                            44  { 188 } 45  { 189 } 46  { 190 }
                            47  { 191 } 96  { 192 } 91  { 219 }
                            92  { 220 } 93  { 221 } 39  { 222 }
                        }
                    }
                }

                $This.Keyboard.TypeKey($Int)
                Start-Sleep -Milliseconds 30
            }
        }
        [Void] RunScript()
        {
            $Item = $This.Script.Current()

            If ($Item.Complete -eq 1)
            {
                $This.Error(-1,"[!] Exception (Script) : [$($Item.Name)] already completed")
            }

            $This.Update(0,"[~] Running (Script) : [$($Item.Name)]")
            ForEach ($Line in $Item.Content)
            {
                Switch -Regex ($Line)
                {
                    "^\<Pause\[\d+\]\>$"
                    {
                        $Line -match "\d+"
                        $This.Timer($Matches[0])
                    }
                    "^\<Pass\[.+\]\>$"
                    {
                        $Line = $Matches[0].Substring(6).TrimEnd(">").TrimEnd("]")
                        $This.LinuxPassword($Line)
                        $This.TypeKey(13)
                    }
                    "^$"
                    {
                        $This.Idle(5,2)
                    }
                    Default
                    {
                        $This.LinuxType($Line)
                        $This.TypeKey(13)
                    }
                }
            }

            $This.Update(1,"[+] Complete (Script) : [$($Item.Name)]")

            $Item.Complete = 1
            $This.Script.Selected ++
        }
        Initial()
        {
            $This.Update(0,"Running [~] Initial Login")
            # Learn your way around...?

            $This.TypeKey(32)
            $This.Timer(1)
            $This.TypeKey(27)
            $This.Timer(1)
        }
        LaunchTerminal()
        {
            $This.Update(0,"Launching [~] Terminal")

            # // Launch terminal
            $This.TypeKey(91)
            $This.Timer(2)
            ForEach ($Key in [Char[]]"terminal")
            {
                $This.LinuxKey($Key)
                Start-Sleep -Milliseconds 25
            }
            $This.Timer(2)
            $This.TypeKey(13)
            $This.Timer(2)
            
            # // Maximize window
            $This.PressKey(91)
            $This.TypeKey(38)
            $This.ReleaseKey(91)
            $This.Idle(0,5)
        }
        Super([Object]$Account)
        {
            $This.Update(0,"Super User [~]")

            # // Accessing super user
            ForEach ($Key in [Char[]]"su -")
            {
                $This.LinuxKey($Key)
                Start-Sleep -Milliseconds 25
            }

            $This.TypeKey(13)
            $This.Timer(1)
            $This.LinuxPassword($Account.Password())
            $This.TypeKey(13)
            $This.Idle(5,2)
        }
        [String] RichFirewallRule()
        {
            $Line = "firewall-cmd --permanent --zone=public --add-rich-rule='"
            $Line += 'rule family="ipv4" '
            $Line += 'source address="{0}/{1}" ' -f $This.Network.Ipaddress, $This.Network.Prefix
            $Line += 'port port="3389" '
            $Line += "protocol=`"tcp`" accept'"

            Return $Line
        }
        SubscriptionInfo([Object]$User)
        {
            # [Phase 1] Set subscription service to access (yum/rpm)
            $This.Script.Add(1,"SetSubscriptionInfo","Set subscription information",@(
            "subscription-manager register";
            "<Pause[1]>";
            $User.Username;
            "<Pause[1]>";
            "<Pass[$($User.Password())]>";
            ))
        }
        GroupInstall()
        {
            # [Phase 2] Install groupinstall workgroup
            $This.Script.Add(2,"GroupInstall","Install groupinstall workgroup",@(
            "dnf groupinstall workstation -y";
            "";
            ))
        }
        InstallEpel()
        {
            # [Phase 3] (Set/Install) epel-release
            $This.Script.Add(3,"EpelRelease","Set EPEL Release Repo",@(
            'subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms';
            "<Pause[30]>";
            "";
            "dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y";
            "";
            ))
        }
        InstallPs()
        {
            # [Phase 4] (Set/Install) [PowerShell]
            $This.Script.Add(4,"InstallPs","(Set/Install) [PowerShell]",@(
            "curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo";
            "";
            "dnf install powershell -y"
            ))
        }
        InstallRdp()
        {
            # [Phase 5] Install [Remote Desktop] Tools
            $This.Script.Add(5,"InstallRdp","(Set/Install) [Remote Desktop] Tools",@(
            "dnf install tigervnc-server tigervnc -y";
            "<Pause[5]>";
            "";
            "yum --enablerepo=epel install xrdp -y";
            "<Pause[5]>";
            "";
            "systemctl start xrdp.service";
            "";
            "systemctl enable xrdp.service"
            ""
            ))
        }
        SetFirewall()
        {
            # [Phase 6] Set firewall
            $This.Script.Add(6,"SetFirewall","Set firewall rule and restart",@(
            $This.RichFirewallRule();
            "";
            "firewall-cmd --reload"
            ))
        }
        InstallVSCode()
        {
            # [Phase 7] Install [Visual Studio Code]
            $This.Script.Add(7,"InstallVsCode","(Set/Install) [Visual Studio Code]",@(
            '$Link  = "https://packages.microsoft.com"';
            '$Keys  = "{0}/keys/microsoft.asc" -f $Link';
            '$Repo  = "{0}/yumrepos/vscode" -f $Link';
            '$Path  = "/etc/yum.repos.d/vscode.repo"';
            '$Text  = @( )';
            '$Text += "[code]"';
            '$Text += "name=Visual Studio Code"';
            '$Text += "baseurl={0}" -f $Repo';
            '$Text += "enabled=1"';
            '$Text += "gpgcheck=1"';
            '$Text += "gpgkey={0}" -f $Keys';
            '[System.IO.File]::WriteAllLines($Path,$Text)';
            "";
            'rpm --import $Keys';
            "";
            'yum install code -y'
            ))
        }
        InstallPsExtension()
        {
            # [Phase 8] Install [PowerShell Extension]
            $This.Script.Add(7,"InstallPsExtension","Install [PowerShell Extension]",@(
            'code --install-extension ms-vscode.powershell'
            ))
        }
        Load([Object]$User)
        {
            $This.SubscriptionInfo($User)
            $This.GroupInstall()
            $This.InstallEpel()
            $This.InstallPs()
            $This.InstallRdp()
            $This.SetFirewall()
            $This.InstallVSCode()
            $This.InstallPsExtension()
        }
    }

    Class VmController
    {
        [String]       $Path
        [String]     $Domain
        [String]    $NetBios
        [Object] $Credential
        [Object]       $Node
        [Object]      $Admin
        [UInt32]   $Selected
        [Object[]]     $File
        VmController([String]$Path,[String]$Domain,[String]$NetBios)
        {
            $This.Path       = $Path
            $This.Domain     = $Domain
            $This.NetBios    = $NetBios
            $This.Credential = $This.VmCredentialList()
            $This.File       = @( )
        }
        [Object] VmNodeController()
        {
            Return $Null # [VmNodeController]::New($This.Path,$This.Domain,$This.NetBios)
        }
        [Object] VmCredentialList()
        {
            Return $Null # [VmCredentialList]::New()
        }
        [Object] VmNodeInputObject([Object]$Token)
        {
            Return $Null # [VmNodeInputObject]::New($Token,$This.Path)
        }
        [Object] VmAdminCredential()
        {
            $Item = Get-ChildItem $This.Path | ? Name -eq admin.txt
            If (!$Item)
            {
                Throw "Admin file not found"
            }

            Return $Null # [VmAdminCredential]::New($Item)
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.File.Count)
            {
                Throw "Index is too large"
            }

            $This.Selected = $Index
        }
        [Object] Current()
        {
            Return $This.File[$This.Selected]
        }
        [Object] VmObject()
        {
            $Object = $This.Current().Object
            $Object = Switch ($Object.Role)
            {
                Default
                {
                    [VmWindows]::New($Object)
                }
                Unix
                {
                    [VmLinux]::New($Object)
                }
            }

            Return $Object
        }
        [Object] VmObject([Switch]$Flags,[Object]$Item)
        {
            Return [VmObject]::New([Switch]$True,$Item)
        }
        GetNodeController()
        {
            $This.Node    = $This.VmNodeController()
        }
        GetNodeInputObject([String]$Token)
        {
            If ($Token -notin (Get-ChildItem $This.Path).Name)
            {
                Throw "Invalid file"
            }

            $This.File   += $This.VmNodeInputObject($Token)
        }
        GetNodeAdminCredential()
        {
            $This.Admin   = $This.VmAdminCredential()
        }
        Prime()
        {
            $Item         = Get-VM -Name $This.Current().Object.Name -EA 0
            If ($Item)
            {
                $Vm       = $This.VmObject([Switch]$True,$Item)
                $Vm.Update(1,"[_] Removing $($Vm.Name)")
                ForEach ($Property in $Vm.PSObject.Properties)
                {
                    $Line = "[_] {0} : {1}" -f $Property.Name.PadRight(10," "), $Property.Value
                    $Vm.Update(1,$Line)
                }
                $Vm.Remove()
            }
            If (!$Item)
            {
                $xPath = $This.Current().Object | % { "{0}\{1}" -f $_.Base, $_.Name } 
                If (Test-Path $xPath)
                {
                    Remove-Item $xPath -Recurse -Force -Verbose
                }
            }
        }
        BeepBeep()
        {
            ForEach ($X in 440, 880)
            {
                0..3 | % { [Console]::Beep($X,100) }
            } 
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmController>"
        }
    }
}

Class GridProperty
{
    [String]  $Name
    [Object] $Value
    GridProperty([Object]$Property)
    {
        $This.Name  = $Property.Name
        $This.Value = $Property.Value -join ", "
    }
}

Class ValidateFlag
{
    [UInt32] $Index
    [String] $Name
    [UInt32] $Status
    ValidateFlag([UInt32]$Index,[String]$Name)
    {
        $This.Index  = $Index
        $This.Name   = $Name
        $This.SetStatus(0)
    }
    SetStatus([UInt32]$Status)
    {
        $This.Status = $Status
    }
}



Class VmMasterController
{
    [Object]     $Module
    [Object]       $Xaml
    [Object]     $Master
    [Object]   $Template
    [Object]       $Node
    [Object] $Credential
    [Object]       $Flag
    VmMasterController()
    {
        $This.Module     = $This.GetFEModule()
        $This.Xaml       = $This.VmXaml()
        $This.Master     = $This.VmMaster()
        $This.Template   = $This.VmTemplate()
        $This.Node       = $This.VmNode()
        $This.Credential = $This.VmCredential()
        $This.Flag       = @( )

        ForEach ($Name in "MasterPath",
                          "MasterDomain",
                          "MasterNetBios",
                          "TemplatePath",
                          "TemplateImagePath",
                          "NodeTemplatePath")
        {
            $This.Flag += $This.ValidateFlag($This.Flag.Count,$Name)
        }
    }
    [Object] GetFEModule()
    {
        Return Get-FEModule -Mode 1
    }
    [Object] VmXaml()
    {
        Return VmXaml
    }
    [Object] VmCredential()
    {
        Return VmCredential
    }
    [Object] VmMaster()
    {
        Return VmMaster
    }
    [Object] VmTemplate()
    {
        Return VmTemplate
    }
    [Object] VmNode()
    {
        Return VmNode
    }
    [Object] ValidateFlag([UInt32]$Index,[String]$Name)
    {
        Return [ValidateFlag]::New($Index,$Name)
    }
    [Object] GridProperty([Object]$Property)
    {
        Return [GridProperty]::New($Property)
    }
    SetNetwork([UInt32]$Index)
    {
        $This.Master.SetNetwork($Index)
        $This.PingSweep($This.Master.Network.Hosts)
        $This.Master.Network.SetDhcp()
    }
    PingSweep([Object[]]$Range)
    {
        $Hosts        = $Range.IpAddress
        $RS           = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $PS           = [PowerShell]::Create()
        $PS.Runspace  = $RS
        $RS.Open()
        [Void]$PS.AddScript({

            Param ($Hosts)

            $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
            $Option   = New-Object System.Net.NetworkInformation.PingOptions
            $Ping     = @{ }
            ForEach ($X in 0..($Hosts.Count-1))
            {
                $Item = New-Object System.Net.NetworkInformation.Ping
                $Ping.Add($X,$Item.SendPingAsync($Hosts[$X],100,$Buffer,$Option))
            }

            $Ping[0..($Ping.Count-1)]
        })

        $PS.AddArgument($Hosts)
        $Async        = $PS.BeginInvoke()
        $Output       = $PS.EndInvoke($Async)
        $PS.Dispose()
        $RS.Dispose()

        ForEach ($X in 0..($Output.Count-1))
        {
            $Status           = [UInt32]($Output[$X].Result.Status -eq "Success")
            $Range[$X].Status = $Status
            If ($Status -eq 1)
            {
                $Range[$X].Resolve()
            }
        }
    }
    FolderBrowse([String]$Name)
    {
        $Object      = $This.Xaml.Get($Name)
        $Item        = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
    
        $Object.Text = @("<Select a path>",$Item.SelectedPath)[!!$Item.SelectedPath]
    }
    FileBrowse([String]$Name)
    {
        $Object      = $This.Xaml.Get($Name)
        $Item                   = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory  = $Env:SystemDrive
        $Item.Filter            = 'Image File (*.iso)| *.iso'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }
    
        $Object.Text = @("<Select an image>",$Item.FileName)[!!$Item.FileName]
    }
    [String[]] Reserved()
    {
        Return "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GR"+
        "OUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;DIALUP;DIGEST AUTH;IN"+
        "TERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AU"+
        "THORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTE"+
        "D;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORG"+
        "ANIZATION;USERS;WORLD" -Split ";"
    }
    [String[]] Legacy()
    {
        Return "-GATEWAY;-GW;-TAC" -Split ";"
    }
    [String[]] SecurityDescriptor()
    {
        Return "AN;AO;AU;BA;BG;BO;BU;CA;CD;CG;CO;DA;DC;DD;DG;DU;EA;ED;HI;IU;"+
        "LA;LG;LS;LW;ME;MU;NO;NS;NU;PA;PO;PS;PU;RC;RD;RE;RO;RS;RU;SA;SI;SO;S"+
        "U;SY;WD" -Split ";"
    }
    ToggleCreate()
    {
        $C = 0
        $D = 0
        ForEach ($Item in $This.Flag | ? Name -match "^Master")
        {
            If ($Item.Status -eq 1)
            {
                $C ++
            }
        }

        If ($This.Xaml.IO.MasterConfig.SelectedIndex -ne -1)
        {
            $D = 1
        }

        $This.Xaml.IO.MasterCreate.IsEnabled = $C -eq 3 -and $D -eq 1
    }
    ToggleAdd()
    {
        $C = 0
        ForEach ($Item in $This.Flag | ? Name -match "^Template")
        {
            If ($Item.Status -eq 1)
            {
                $C ++
            }
        }

        $this.Xaml.IO.TemplateAdd.IsEnabled = $C -eq 2
    }
    CheckPath([String]$Name)
    {
        $Item        = $This.Xaml.Get($Name)
        $Icon        = $This.Xaml.Get("$Name`Icon")

        $xFlag       = $This.Flag | ? Name -eq $Name
        $xFlag.SetStatus([UInt32][System.IO.Directory]::Exists($Item.Text))

        $Slot        = @("failure.png","success.png")[$xFlag.Status]
        $Icon.Source = $This.Module._Control($Slot).Fullname

        $This.ToggleCreate()
    }
    CheckDomain()
    {
        $Item = $This.Xaml.IO.MasterDomain.Text

        If ($Item.Length -lt 2 -or $Item.Length -gt 63)
        {
            $X = "[!] Length not between 2 and 63 characters"
        }
        ElseIf ($Item -in $This.Reserved())
        {
            $X = "[!] Entry is in reserved words list"
        }
        ElseIf ($Item -in $This.Legacy())
        {
            $X = "[!] Entry is in the legacy words list"
        }
        ElseIf ($Item -notmatch "(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)")
        { 
            $X = "[!] Invalid characters"
        }
        ElseIf ($Item[0,-1] -match "(\W)")
        {
            $X = "[!] First/Last Character cannot be a '.' or '-'"
        }
        ElseIf ($Item.Split(".").Count -lt 2)
        {
            $X = "[!] Single label domain names are disabled"
        }
        ElseIf ($Item.Split('.')[-1] -notmatch "\w")
        {
            $X = "[!] Top Level Domain must contain a non-numeric"
        }
        Else
        {
            $X = "[+] Passed"
        }

        $xFlag = $This.Flag | ? Name -eq MasterDomain
        $xFlag.SetStatus([UInt32]($X -eq "[+] Passed"))
        $Slot = @("failure.png","success.png")[$xFlag.Status]
        $This.Xaml.IO.MasterDomainIcon.Source = $This.Module._Control($Slot).Fullname

        $This.ToggleCreate()
    }
    CheckNetBios()
    {
        $Item = $This.Xaml.IO.MasterNetBios.Text

        If ($Item.Length -lt 1 -or $Item.Length -gt 15)
        {
            $X = "[!] Length not between 1 and 15 characters"
        }
        ElseIf ($Item -in $This.Reserved())
        {
            $X = "[!] Entry is in reserved words list"
        }
        ElseIf ($Item -in $This.Legacy())
        {
            $X = "[!] Entry is in the legacy words list"
        }
        ElseIf ($Item -notmatch "([\.\-0-9a-zA-Z])")
        { 
            $X = "[!] Invalid characters"
        }
        ElseIf ($Item[0,-1] -match "(\W)")
        {
            $X = "[!] First/Last Character cannot be a '.' or '-'"
        }                        
        ElseIf ($Item -match "\.")
        {
            $X = "[!] NetBIOS cannot contain a '.'"
        }
        ElseIf ($Item -in $This.SecurityDescriptor())
        {
            $X = "[!] Matches a security descriptor"
        }
        Else
        {
            $X = "[+] Passed"
        }

        $xFlag = $This.Flag | ? Name -eq MasterNetBios
        $xFlag.SetStatus([UInt32]($X -eq "[+] Passed"))
        $Slot = @("failure.png","success.png")[$xFlag.Status]

        $This.Xaml.IO.MasterNetBiosIcon.Source = $This.Module._Control($Slot).Fullname

        $This.ToggleCreate()
    }
    CheckTemplatePath()
    {
        $Item         = $This.Xaml.Get("TemplatePath")
        $xFlag        = $This.Flag | ? Name -eq TemplatePath
        $xFlag.Status = [UInt32][System.IO.Directory]::Exists($Item.Text)
        $Slot         = @("failure.png","success.png")[$xFlag.Status]

        $This.Xaml.IO.TemplatePathIcon.Source = $This.Module._Control($Slot).Fullname

        $This.ToggleAdd()
    }
    CheckTemplateImagePath()
    {
        $Item         = $This.Xaml.Get("TemplateImagePath")
        $xFlag        = $This.Flag | ? Name -eq TemplateImagePath
        $xFlag.Status = [UInt32][System.IO.Directory]::Exists($Item.Text)
        $Slot         = @("failure.png","success.png")[$xFlag.Status]

        $This.Xaml.IO.TemplatePathIcon.Source = $This.Module._Control($Slot).Fullname

        $This.ToggleAdd()
    }
    Reset([Object]$xSender,[Object]$Object)
    {
        $xSender.Items.Clear()
        ForEach ($Item in $Object)
        {
            $xSender.Items.Add($Item)
        }
    }
    [Object[]] Property([Object]$Object)
    {
        Return $Object.PSObject.Properties | % { $This.GridProperty($_) }
    }
    [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
    {
        $Item = Switch ($Mode)
        {
            0 { $Object.PSObject.Properties | ? Name -notin $Property }
            1 { $Object.PSObject.Properties | ? Name    -in $Property }
        }

        Return $Item | % { $This.GridProperty($_) }
    }
    StageXaml()
    {
        $Ctrl = $This

        <#
            ____    ____________________________________________________________________________________________________        
           //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
           \\__//¯¯¯ Master [~] Panel                                                                               ___//¯¯\\   
            ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
                ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
             0 MasterConfig            DataGrid  System.Windows.Controls.DataGrid Items.Count:1
             1 MasterPath              TextBox   System.Windows.Controls.TextBox: C:\FileVm
             2 MasterPathIcon          Image     System.Windows.Controls.Image
             3 MasterPathBrowse        Button    System.Windows.Controls.Button: Browse
             4 MasterDomain            TextBox   System.Windows.Controls.TextBox: securedigitsplus.com
             5 MasterDomainIcon        Image     System.Windows.Controls.Image
             6 MasterNetBios           TextBox   System.Windows.Controls.TextBox: secured
             7 MasterNetBiosIcon       Image     System.Windows.Controls.Image
             8 MasterCreate            Button    System.Windows.Controls.Button: Create
             9 MasterConfigOutput      DataGrid  System.Windows.Controls.DataGrid Items.Count:22
            10 MasterBase              DataGrid  System.Windows.Controls.DataGrid Items.Count:10
            11 MasterRange             DataGrid  System.Windows.Controls.DataGrid Items.Count:1
            12 MasterHosts             DataGrid  System.Windows.Controls.DataGrid Items.Count:256     
            13 MasterDhcp              DataGrid  System.Windows.Controls.DataGrid Items.Count:7
        #>

        $Ctrl.Reset($Ctrl.Xaml.IO.MasterConfig,$Ctrl.Master.Config)
        $Ctrl.Xaml.IO.MasterConfig.Add_SelectionChanged(
        {
            $Ctrl.ToggleCreate()
        })

        $Ctrl.Xaml.IO.MasterPath.Text = "<Select a path>"
        $Ctrl.Xaml.IO.MasterPath.Add_TextChanged(
        {
            $Ctrl.CheckPath("MasterPath")
        })

        $Ctrl.Xaml.IO.MasterPathBrowse.Add_Click(
        {
            $Ctrl.FolderBrowse("MasterPath")
        })

        $Ctrl.Xaml.IO.MasterDomain.Add_TextChanged(
        {
            $Ctrl.CheckDomain()
        })

        $Ctrl.Xaml.IO.MasterNetBios.Add_TextChanged(
        {
            $Ctrl.CheckNetBios()
        })

        $Ctrl.Xaml.IO.MasterCreate.IsEnabled = 0
        $Ctrl.Xaml.IO.MasterCreate.Add_Click(
        {
            $Ctrl.Master.SetMain($Ctrl.Xaml.IO.MasterPath.Text,
                                  $Ctrl.Xaml.IO.MasterDomain.Text,
                                  $Ctrl.Xaml.IO.MasterNetBios.Text)

            $Ctrl.SetNetwork($Ctrl.Xaml.IO.MasterConfig.SelectedIndex)

            ForEach ($Item in "Config","Path","Domain","NetBios","PathBrowse","Create")
            {
                $Ctrl.Xaml.Get("Master$Item").IsEnabled = 0
            }

            $Ctrl.Reset($Ctrl.Xaml.IO.MasterConfigOutput,$Ctrl.Property($Ctrl.Master.Network.Config))
            $Ctrl.Reset($Ctrl.Xaml.IO.MasterBase,$Ctrl.Property($Ctrl.Master.Network.Base))
            $Ctrl.Reset($Ctrl.Xaml.IO.MasterRange,$Ctrl.Master.Network.Range)
            $Ctrl.Reset($Ctrl.Xaml.IO.MasterHosts,$Ctrl.Master.Network.Hosts)
            $Ctrl.Reset($Ctrl.Xaml.IO.MasterDhcp,$Ctrl.Property($Ctrl.Master.Network.Dhcp))
        })

        <#
            ____    ____________________________________________________________________________________________________        
           //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
           \\__//¯¯¯ Template [~] Panel                                                                             ___//¯¯\\   
            ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
                ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
            14 TemplateName            TextBox  System.Windows.Controls.TextBox
            15 TemplateRole            ComboBox System.Windows.Controls.ComboBox Items.Count:3
            16 TemplatePath            TextBox  System.Windows.Controls.TextBox
            17 TemplatePathIcon        Image    System.Windows.Controls.Image
            18 TemplatePathBrowse      Button   System.Windows.Controls.Button: Browse
            19 TemplateMemory          ComboBox System.Windows.Controls.ComboBox Items.Count:2
            20 TemplateHardDrive       ComboBox System.Windows.Controls.ComboBox Items.Count:4
            21 TemplateGeneration      ComboBox System.Windows.Controls.ComboBox Items.Count:2
            22 TemplateCore            ComboBox System.Windows.Controls.ComboBox Items.Count:4
            23 TemplateSwitch          ComboBox System.Windows.Controls.ComboBox Items.Count:2
            24 TemplateImagePath       TextBox  System.Windows.Controls.TextBox
            25 TemplateImagePathIcon   Image    System.Windows.Controls.Image
            26 TemplateImagePathBrowse Button   System.Windows.Controls.Button: Browse

            27 TemplateAdd             Button   System.Windows.Controls.Button: Add
            28 TemplateRemove          Button   System.Windows.Controls.Button: Remove
            29 TemplateExport          Button   System.Windows.Controls.Button: Export
            30 TemplateOutput          DataGrid System.Windows.Controls.DataGrid Items.Count:0
        #>

        $Ctrl.Xaml.IO.TemplateRole.SelectedIndex = 0
        $Ctrl.Xaml.IO.TemplatePath.Add_TextChanged(
        {
            $Ctrl.CheckPath("TemplatePath")
        })

        $Ctrl.Xaml.IO.TemplatePathBrowse.Add_Click(
        {
            $Ctrl.FolderBrowse("TemplatePath")
        })

        $Ctrl.Xaml.IO.TemplateSwitch.SelectedIndex = 0

        $Ctrl.Xaml.IO.TemplateImagePath.Add_TextChanged(
        {
            $Ctrl.CheckPath("TemplateImagePath")
        })

        $Ctrl.Xaml.IO.TemplateImagePathBrowse.Add_Click(
        {
            $Ctrl.FileBrowse("TemplateImagePath")
        })

        ForEach ($Item in "TemplateAdd","TemplateRemove","TemplateExport")
        {
            $Ctrl.Xaml.Get($Item).IsEnabled = 0
        }

        $Ctrl.Xaml.IO.TemplateAdd.Add_Click(
        {
            If ($Ctrl.Xaml.IO.TemplateName.Text -notmatch "(\w|\d)")
            {
                Return [System.Windows.MessageBox]::Show("Must enter a name","Error")
            }

            Else
            {
                $Ctrl.Template.Add($Ctrl.Xaml.IO.TemplateName.Text,
                                   $Ctrl.Xaml.IO.TemplateRole.SelectedIndex,
                                   $Ctrl.Xaml.IO.TemplatePath.Text,
                                   $Ctrl.Xaml.IO.TemplateMemory.SelectedItem.Content,
                                   $Ctrl.Xaml.IO.TemplateHardDrive.SelectedItem.Content,
                                   $Ctrl.Xaml.IO.TemplateGeneration.SelectedItem.Content,
                                   $Ctrl.Xaml.IO.TemplateCore.SelectedItem.Content,
                                   $Ctrl.Xaml.IO.TemplateSwitch.SelectedItem.Content,
                                   $Ctrl.Xaml.IO.TemplateImagePath.Text)

                $Ctrl.Reset($Ctrl.Xaml.IO.TemplateOutput,$Ctrl.Template.Output)
            }
        })

        $Ctrl.Xaml.IO.TemplateOutput.Add_SelectionChanged(
        {
            $Ctrl.Xaml.IO.TemplateExport.IsEnabled = $Ctrl.Xaml.IO.TemplateOutput.Items.Count -gt 0
            $Ctrl.Xaml.IO.TemplateRemove.IsEnabled = $Ctrl.Xaml.IO.TemplateOutput.SelectedIndex -ne -1
        })

        $Ctrl.Xaml.IO.TemplateRemove.Add_Click(
        {
            $Ctrl.Template.Output = $Ctrl.Template.Output | ? Name -ne $Ctrl.Xaml.IO.TemplateOutput.SelectedItem.Name
            $Ctrl.Reset($Ctrl.Xaml.IO.TemplateOutput,$Ctrl.Template.Output)
        })

        $Ctrl.Xaml.IO.TemplateExport.Add_Click(
        {
            $Ctrl.Template.Export($Ctrl.Master.Main.Path,$Ctrl.Xaml.IO.TemplateOutput.SelectedItem.Index)
            $Ctrl.Template.Output = $Ctrl.Template.Output | ? Name -ne $Ctrl.Xaml.IO.TemplateOutput.SelectedItem.Index
            $C = 0
            $Ctrl.Template.Output | % { $_.Index = $C; $C ++ }
        })

        <#
            ____    ____________________________________________________________________________________________________        
           //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
           \\__//¯¯¯ Node [~] Panel                                                                                 ___//¯¯\\   
            ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
                ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
            31 NodeSwitchRefresh     Button   System.Windows.Controls.Button: Refresh       
            32 NodeSwitch            DataGrid System.Windows.Controls.DataGrid Items.Count:2
            33 NodeHostRefresh       Button   System.Windows.Controls.Button: Refresh       
            34 NodeHost              DataGrid System.Windows.Controls.DataGrid Items.Count:2
            35 NodeTemplatePath      TextBox  System.Windows.Controls.TextBox
            36 NodeTemplateImport    Button   System.Windows.Controls.Button: Import        
            37 NodeTemplate          DataGrid System.Windows.Controls.DataGrid Items.Count:0
            38 NodeTemplateExtension DataGrid System.Windows.Controls.DataGrid Items.Count:0
        #>

        $Ctrl.Reset($Ctrl.Xaml.IO.NodeSwitch,$Ctrl.Node.Switch)
        $Ctrl.Reset($Ctrl.Xaml.IO.NodeHost,$Ctrl.Node.Host)
        $Ctrl.Reset($Ctrl.Xaml.IO.TemplateSwitch,$Ctrl.Node.Switch.Name)

        <#
            ____    ____________________________________________________________________________________________________        
           //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
           \\__//¯¯¯ Credential [~] Panel                                                                           ___//¯¯\\   
            ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
                ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
            39 CredentialType     ComboBox System.Windows.Controls.ComboBox Items.Count:4
            40 CredentialUsername TextBox  System.Windows.Controls.TextBox
            41 CredentialPassword TextBox  System.Windows.Controls.TextBox
            42 CredentialGenerate Button   System.Windows.Controls.Button: Generate
            43 CredentialOutput   DataGrid System.Windows.Controls.DataGrid Items.Count:0
        #>

        
    }
}

$Ctrl = [VmMasterController]::New()
$Ctrl.StageXaml()
$Ctrl.Xaml.Invoke()

# $Ctrl.Template.Add("rhel00",2,"C:\VDI",2,64,2,2,"External","C:\Images\rhel-baseos-9.1-x86_64-dvd.iso")

<#
    $master = @{ }
    "Master",
    "Template",
    "Node",
    "Credential" | % { $Master.Add($Master.Count,(Write-Theme "$_ [~] Panel" -Text))}
#>
