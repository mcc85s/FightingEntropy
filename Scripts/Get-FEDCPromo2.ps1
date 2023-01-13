#Function Get-FEDCPromo2
#{
#    [CmdLetBinding()]Param(
#    [Parameter()][UInt32]$Mode=0,
#    [Parameter()][String]$InputPath)

    # Check for server operating system
    If (Get-CimInstance Win32_OperatingSystem | ? Caption -notmatch Server)
    {
        Throw "Must use Windows Server operating system"
    }

    # // =======================================================================
    # // | [Xaml.Property]: Allows each Xaml control to be indexed, uniquely   |
    # // | named, filterable by type, and its control may be directly accessed |
    # // =======================================================================

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

    # // ============================================================================
    # // | [Xaml.Window]: Provides an object for a chunk of Xaml to be instantiated |
    # // ============================================================================

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
            Return "<FightingEntropy.XamlWindow>"
        }
    }

    # // ===============================================================================
    # // | [Xaml.FEDCFound]: Xaml for found domain controllers (likely to be replaced) |
    # // ===============================================================================

    Class FEDCFoundXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" ',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ',
        '        Title="[FightingEntropy]://Domain Controller Found"',
        '        Width="550"',
        '        Height="260"',
        '        HorizontalAlignment="Center"',
        '        Topmost="True"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\icon.ico"',
        '        WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="10"/>',
        '            <Setter Property="Padding" Value="10"/>',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="GroupBox">',
        '                        <Border CornerRadius="10"',
        '                                Background="White"',
        '                                BorderBrush="Black"',
        '                                BorderThickness="3">',
        '                            <ContentPresenter x:Name="ContentPresenter"',
        '                                              ContentTemplate="{TemplateBinding ContentTemplate}"',
        '                                              Margin="5"/>',
        '                        </Border>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
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
        '        <Style TargetType="DataGridCell">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left" />',
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
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
        '                    Value="Auto"/>',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="None"',
        '                        ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox>',
        '            <Grid Margin="5">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="50"/>',
        '                </Grid.RowDefinitions>',
        '                <DataGrid Grid.Row="0" Grid.Column="0" Name="DomainControllers">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Address"',
        '                                            Width="140"',
        '                                            Binding="{Binding IPAddress}"/>',
        '                        <DataGridTextColumn Header="Hostname"',
        '                                            Width="200"',
        '                                            Binding="{Binding HostName}"/>',
        '                        <DataGridTextColumn Header="NetBIOS"',
        '                                            Width="140"',
        '                                            Binding="{Binding NetBIOS}"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="1">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Row="1"',
        '                            Grid.Column="0"',
        '                            Name="Ok"',
        '                            Content="Ok" />',
        '                    <Button Grid.Row="1"',
        '                            Grid.Column="1"',
        '                            Content="Cancel"',
        '                            Name="Cancel"/>',
        '                </Grid>',
        '            </Grid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    # // =====================================================
    # // | [Xaml.FEDCPromo]: Xaml for the utiilty, FEDCPromo |
    # // =====================================================
    
    Class FEDCPromoXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[FightingEntropy]://Domain Controller Promotion"',
        '        Width="550"',
        '        Height="450"',
        '        Topmost="True"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
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
        '                        <Border Name="Border"',
        '                                BorderThickness="2"',
        '                                BorderBrush="Black"',
        '                                CornerRadius="2"',
        '                                Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite"',
        '                                              VerticalAlignment="Center"',
        '                                              HorizontalAlignment="Right"',
        '                                              ContentSource="Header"',
        '                                              Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected" Value="True">',
        '                                <Setter TargetName="Border"',
        '                                        Property="Background" ',
        '                                        Value="#4444FF"/>',
        '                                <Setter Property="Foreground"',
        '                                        Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected" Value="False">',
        '                                <Setter TargetName="Border"',
        '                                        Property="Background" ',
        '                                        Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground" ',
        '                                        Value="#000000"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsEnabled" Value="False">',
        '                                <Setter TargetName="Border"',
        '                                        Property="Background"',
        '                                        Value="#6F6F6F"/>',
        '                                <Setter Property="Foreground"',
        '                                        Value="#9F9F9F"/>',
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
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
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
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="8"/>',
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
        '    <Grid Margin="5">',
        '        <Grid.Resources>',
        '            <Style TargetType="Grid">',
        '                <Setter Property="Background" Value="LightYellow"/>',
        '            </Style>',
        '        </Grid.Resources>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="40"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="100"/>',
        '                <ColumnDefinition Width="70"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Label Grid.Column="0"',
        '                   Content="[Command]:"',
        '                   HorizontalContentAlignment="Center"/>',
        '            <ComboBox Grid.Column="1" Name="CommandSlot">',
        '                <ComboBoxItem Content="Forest"/>',
        '                <ComboBoxItem Content="Tree"/>',
        '                <ComboBoxItem Content="Child"/>',
        '                <ComboBoxItem Content="Clone"/>',
        '            </ComboBox>',
        '            <DataGrid Grid.Column="2"',
        '                      Margin="10"',
        '                      Name="Command"',
        '                      HeadersVisibility="None">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="Description" ',
        '                                        Width="*" ',
        '                                        Binding="{Binding Description}"/>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '        </Grid>',
        '        <TabControl Grid.Row="1">',
        '            <TabItem Header="Mode">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="30"/>',
        '                        <RowDefinition Height="50"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Grid.Row="0"',
        '                              Name="OperatingSystemCaption"',
        '                              HeadersVisibility="None">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Caption"',
        '                                                Width="*"',
        '                                                Binding="{Binding Caption}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <DataGrid Grid.Row="1" Name="OperatingSystemExtension">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Version"',
        '                                                Width="80"',
        '                                                Binding="{Binding Version}"/>',
        '                            <DataGridTextColumn Header="Build"',
        '                                                Width="50"',
        '                                                Binding="{Binding Build}"/>',
        '                            <DataGridTextColumn Header="Serial"',
        '                                                Width="*"',
        '                                                Binding="{Binding Serial}"/>',
        '                            <DataGridTextColumn Header="Language"',
        '                                                Width="50"',
        '                                                Binding="{Binding Language}"/>',
        '                            <DataGridTextColumn Header="Product"',
        '                                                Width="50"',
        '                                                Binding="{Binding Product}"/>',
        '                            <DataGridTextColumn Header="Type"',
        '                                                Width="50"',
        '                                                Binding="{Binding Type}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="3" Name="ForestModeBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="50"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="Forest Mode"',
        '                               Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="2"',
        '                                  Name="ForestMode"',
        '                                  SelectedIndex="0">',
        '                            <ComboBox.ItemTemplate>',
        '                                <DataTemplate>',
        '                                    <TextBlock Text="{Binding Index}"',
        '                                               IsEnabled="{Binding Enabled}"/>',
        '                                </DataTemplate>',
        '                            </ComboBox.ItemTemplate>',
        '                        </ComboBox>',
        '                        <DataGrid Grid.Column="3"',
        '                                  Name="ForestModeExtension"',
        '                                  HeadersVisibility="None"',
        '                                  Margin="10">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"',
        '                                                    Binding="{Binding Name}"',
        '                                                    Width="100"/>',
        '                                <DataGridTextColumn Header="DisplayName"',
        '                                                    Binding="{Binding DisplayName}"',
        '                                                    Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Row="4" Name="DomainModeBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="50"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="Domain Mode"',
        '                               Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="2"',
        '                                  Name="DomainMode"',
        '                                  SelectedIndex="0">',
        '                            <ComboBox.ItemTemplate>',
        '                                <DataTemplate>',
        '                                    <TextBlock Text="{Binding Index}"',
        '                                               IsEnabled="{Binding Enabled}"/>',
        '                                </DataTemplate>',
        '                            </ComboBox.ItemTemplate>',
        '                        </ComboBox>',
        '                        <DataGrid Grid.Column="3"',
        '                                  Name="DomainModeExtension"',
        '                                  HeadersVisibility="None"',
        '                                  Margin="10">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"',
        '                                                    Binding="{Binding Name}"',
        '                                                    Width="100"/>',
        '                                <DataGridTextColumn Header="DisplayName"',
        '                                                    Binding="{Binding DisplayName}"',
        '                                                    Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6" Name="ReplicationSourceDCBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="50"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1"',
        '                                  Content="Replication DC"',
        '                                  Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="3" Name="ReplicationSourceDC"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="8" Name="SiteNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="50"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1"',
        '                                  Content="Site Name"',
        '                                  Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Column="2"',
        '                                  Name="SiteNameIcon"/>',
        '                        <ComboBox Grid.Column="3"',
        '                                  Name="SiteName"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Features">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label    Grid.Row="0"',
        '                              Content="[Windows Server features to be installed]:"/>',
        '                    <DataGrid Grid.Row="1"',
        '                              Name="Feature">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Type"',
        '                                                Width="60"',
        '                                                Binding="{Binding Type}"',
        '                                                CanUserSort="True"',
        '                                                IsReadOnly="True"/>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Width="*"',
        '                                                Binding="{Binding Name}"',
        '                                                CanUserSort="True"',
        '                                                IsReadOnly="True"',
        '                                                FontWeight="Bold"/>',
        '                            <DataGridTemplateColumn Header="Install" Width="40">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <CheckBox IsEnabled="{Binding Enable}"',
        '                                                  IsChecked="{Binding Install}"',
        '                                                  Margin="0"',
        '                                                  Height="18"',
        '                                                  HorizontalAlignment="Left"/>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Roles/Paths">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0" Content="[Domain controller roles]"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="InstallDNS"/>',
        '                        <Label    Grid.Column="2"',
        '                                  Content="Install DNS"',
        '                                  Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="3"',
        '                                  Name="NoGlobalCatalog"/>',
        '                        <Label    Grid.Column="4"',
        '                                  Content="No Global Catalog"',
        '                                  Style="{StaticResource LabelRed}"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="CreateDNSDelegation"/>',
        '                        <Label    Grid.Column="2"',
        '                                  Content="Create DNS Delegation"',
        '                                  Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="3"',
        '                                  Name="CriticalReplicationOnly"/>',
        '                        <Label    Grid.Column="4"',
        '                                  Content="Critical Replication Only"',
        '                                  Style="{StaticResource LabelRed}"/>',
        '                    </Grid>',
        '                    <Label Grid.Row="3"',
        '                           Content="[Active Directory partition target paths]"/>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button   Grid.Column="1"',
        '                                  Name="DatabaseBrowse"',
        '                                  Content="Database"/>',
        '                        <TextBox  Grid.Column="2"',
        '                                  Name="DatabasePath"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button   Grid.Column="1"',
        '                                  Name="SysvolBrowse"',
        '                                  Content="SysVol"/>',
        '                        <TextBox  Grid.Column="2"',
        '                                  Name="SysvolPath"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button  Grid.Column="1"',
        '                                 Name="LogBrowse"',
        '                                 Content="Log"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="LogPath"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Names">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="20"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0"',
        '                           Content="[Necessary fields vary by command selection]"/>',
        '                    <Grid Grid.Row="2" Name="ParentDomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="1"',
        '                                 Content="Parent Domain"',
        '                                 Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="ParentDomainNameIcon"/>',
        '                        <TextBox Grid.Column="3" ',
        '                                 Name="ParentDomainName"/>',
        '                    </Grid>',
        '                    <Grid   Grid.Row="3" Name="DomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="1"',
        '                                 Content="Domain"',
        '                                 Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="DomainNameIcon"/>',
        '                        <TextBox Grid.Column="3"',
        '                                 Name="DomainName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="4" Name="NewDomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="1"',
        '                                 Content="New Domain"',
        '                                 Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="NewDomainNameIcon"/>',
        '                        <TextBox Grid.Column="3"',
        '                                 Name="NewDomainName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5" Name="DomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="1"',
        '                                 Content="NetBIOS"',
        '                                 Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="DomainNetBIOSNameIcon"/>',
        '                        <TextBox Grid.Column="3"',
        '                                 Name="DomainNetBIOSName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6" Name="NewDomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="1"',
        '                                 Content="New NetBIOS"',
        '                                 Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="NewDomainNetBIOSNameIcon"/>',
        '                        <TextBox Grid.Column="3"',
        '                                 Name="NewDomainNetBIOSName"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Credential">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="20"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="20"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="20"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0"',
        '                           Content="[Active Directory promotion credential]"/>',
        '                    <Grid  Grid.Row="2" Name="CredentialBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button  Grid.Column="1"',
        '                                 Content="Credential"',
        '                                 Name="CredentialButton"/>',
        '                        <Image   Grid.Column="2"',
        '                                 Name="CredentialIcon"/>',
        '                        <TextBox Grid.Column="3"',
        '                                 Name="Credential"/>',
        '                    </Grid>',
        '                    <Label Grid.Row="4"',
        '                           Content="[(DSRM/Domain Services Restore Mode) Key]"/>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="Password"',
        '                               Style="{StaticResource LabelGray}"/>',
        '                        <Image Grid.Column="2"',
        '                               Name="SafeModeAdministratorPasswordIcon"/>',
        '                        <PasswordBox Grid.Column="3"',
        '                                     Name="SafeModeAdministratorPassword"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="7">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="Confirm"',
        '                               Style="{StaticResource LabelGray}"/>',
        '                        <Image Grid.Column="2"',
        '                               Name="ConfirmIcon"/>',
        '                        <PasswordBox Grid.Column="3"',
        '                                     Name="Confirm"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Summary">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0" Content="[Issues preventing promotion]"/>',
        '                    <DataGrid Grid.Row="1" Name="Summary">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="150"/>',
        '                            <DataGridTextColumn Header="Reason"',
        '                                                Binding="{Binding Reason}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="65"/>',
        '                <ColumnDefinition Width="65"/>',
        '                <ColumnDefinition Width="65"/>',
        '                <ColumnDefinition Width="10"/>',
        '                <ColumnDefinition Width="65"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0"',
        '                    Name="Start"',
        '                    Content="Start"/>',
        '            <Button Grid.Column="1"',
        '                    Name="Test"',
        '                    Content="Test"/>',
        '            <Button Grid.Column="2"',
        '                    Name="Save"',
        '                    Content="Save"/>',
        '            <Border Grid.Column="3" Background="Black" Margin="4"/>',
        '            <Button Grid.Column="4"',
        '                    Name="Load"',
        '                    Content="Load"/>',
        '            <TextBox Grid.Column="5" Name="InputPath" IsEnabled="False"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    # // ===============================================================
    # // | [InputObject.Controller]: Meant to instantiate an InputPath |
    # // ===============================================================

    Class InputObjectController
    {
        [UInt32]       $Slot
        [Object]    $Profile
        [Object] $Credential
        [Object]       $Dsrm
        InputObjectController([String]$Path)
        {
            $This.Slot       = $Null
            $This.Profile    = $Null
            $This.Credential = $Null
            $This.Dsrm       = $Null

            ForEach ($Item in Get-ChildItem $Path)
            {
                Switch -Regex ($Item.Name)
                {
                    Slot       { $This.Slot       = Get-Content   $Item.Fullname }
                    Profile    { $This.Profile    = Get-Content   $Item.Fullname | ConvertFrom-Json }
                    Credential { $This.Credential = Import-CliXml $Item.Fullname }
                    Dsrm       { $This.Dsrm       = Import-CliXml $Item.Fullname }
                }
            }

            If ($This.Profile.ForestMode -match "WinThreshold")
            {
                $This.Profile.ForestMode = 6
            }

            If ($This.Profile.DomainMode -match "WinThreshold")
            {
                $This.Profile.DomainMode = 6
            }

            If ($This.Dsrm)
            {
                $This.Profile.SafeModeAdministratorPassword = $This.Dsrm | ConvertTo-SecureString -AsPlainText -Force
            }

            If (Get-ScheduledTask -TaskName FEDCPromo -EA 0)
            {
                Unregister-ScheduledTask -TaskName FEDCPromo -Confirm:$False
            }

            Get-Process -Name ServerManager -EA 0 | Stop-Process -EA 0
        }
    }

    # // =====================================================================
    # // | [Feature.Item]: Windows optional features slated for installation |
    # // =====================================================================

    Class FeatureItem
    {
        [UInt32]   $Index
        [String]    $Type
        [String]    $Name
        [Object]   $State
        [UInt32]  $Enable
        [UInt32] $Install
        FeatureItem([UInt32]$Index,[String]$Type,[String]$Name)
        {
            $This.Index   = $Index
            $This.Type    = $Type
            $This.Name    = $Name
        }
        Set([Object]$Feature)
        {
            $This.State   = [UInt32]$Feature.Installed
            $This.Enable  = $This.State -ne 1
            $This.Install = $This.State -ne 1
        }
        Toggle()
        {
            $This.Install         = !$This.Install
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    # // ==================================================================
    # // | [Feature.Controller]: Creates a template for specific features |
    # // ==================================================================

    Class FeatureController
    {
        [String]     $Name
        [Object]   $Output
        FeatureController()
        {
            $This.Name       = "Feature"
            $This.Clear()
            $This.Stage()
        }
        FeatureController([Object]$Feature)
        {
            $This.Name       = "Feature"
            $This.Clear()

        }
        Clear()
        {
            $This.Output     = @( )
            $This.Output     = $This.GetTemplate()
        }
        Stage()
        {
            ForEach ($Feature in Get-WindowsFeature | ? Name -in $This.Output.Name)
            {
                $Item       = $This.Output | ? Name -eq $Feature.Name
                $Item.Set($Feature)
            }
        }
        [Object] GetTemplate()
        {
            $Out = @( )
            ForEach ($Type in "Main","WDS","IIS","Veridian")
            {
                $Slot        = Switch ($Type)
                {
                    Main     { $This.Main()     }
                    WDS      { $This.WDS()      }
                    IIS      { $This.IIS()      }
                    Veridian { $This.Veridian() }
                }
    
                ForEach ($Item in $Slot)
                {
                    $Out += $This.FeatureItem($Out.Count,$Type,$Item)
                }
            }
    
            Return $Out
        }
        [String[]] Main()
        {
            $Out = "AD-Domain-Services DHCP DNS GPMC ! !-AD-AdminCenter !-AD-PowerShell "+
            "!-AD-Tools !-ADDS !-ADDS-Tools !-DHCP !-DNS-Server !-Role-Tools" 
            
            Return $Out -Replace "!","RSAT" -Split " "
        }
        [String[]] WDS()
        {
            $Out = "! !-AdminPack !-Deployment !-Transport"
            
            Return $Out -Replace "!","WDS" -Split " "
        }
        [String[]] IIS()
        {
            $Out = "BITS BITS-IIS-Ext DSC-Service FS-SMBBW ManagementOData Net-Framework"+
            "-45-ASPNet Net-WCF-HTTP-Activation45 RSAT-BITS-Server WAS WAS-Config-APIs W"+
            "AS-Process-Model WebDAV-Redirector !HTTP-Errors !HTTP-Logging !HTTP-Redirec"+
            "t !HTTP-Tracing !App-Dev !AppInit !Asp-Net45 !Basic-Auth !Common-Http !Cust"+
            "om-Logging !DAV-Publishing !Default-Doc !Digest-Auth !Dir-Browsing !Filteri"+
            "ng !Health !Includes !Log-Libraries !Metabase !Mgmt-Console !Net-Ext45 !Per"+
            "formance !Request-Monitor !Security !Stat-Compression !Static-Content !Url-"+
            "Auth !WebServer !Windows-Auth !ISAPI-Ext !ISAPI-Filter !Server WindowsPower"+
            "ShellWebAccess"
            
            Return $Out -Replace "!","Web-" -Split " "
        }
        [String[]] Veridian()
        {
            $Out = "! RSAT-!-Tools !-Tools !-PowerShell"
    
            Return $Out -Replace "!","Hyper-V" -Split " "
        }
        [Object] FeatureItem([UInt32]$Index,[String]$Type,[String]$Name)
        {
            Return [FeatureItem]::New($Index,$Type,$Name)
        }
        [String] ToString()
        {
            Return "<FEDCPromo.FeatureController>"
        }
    }

    # // ==================================================================
    # // | [Windows.Server.Type]: Enum type meant for Forest/Domain modes |
    # // ==================================================================

    Enum WindowsServerType
    {
        Win2K
        Win2003
        Win2008
        Win2008R2
        Win2012
        Win2012R2
        Win2016
        Win2019
        Win2022
    }

    # // =================================================================
    # // | [Windows.Server.Item]: Item for detailing Windows Server mode |
    # // =================================================================

    Class WindowsServerItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $DisplayName
        [UInt32]      $Enable = 1
        WindowsServerItem([String]$Name)
        {
            $This.Index       = [UInt32][WindowsServerType]::$Name
            $This.Name        = $Name
        }
        [String] ToString()
        {
            Return $This.DisplayName
        }
    }

    # // ==================================================
    # // | [Windows.Server.List]: List of the above items |
    # // ==================================================

    Class WindowsServerList
    {
        [String]     $Name
        [UInt32] $Selected
        [Object]   $Output
        WindowsServerList([String]$Name)
        {
            $This.Name   = $Name
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([WindowsServerType]))
            {
                $This.Add($Name)
            }
        }
        [Object] WindowsServerItem([String]$Name)
        {
            Return [WindowsServerItem]::New($Name)
        }
        Add([String]$Name)
        {
            $Item             = $This.WindowsServerItem($Name)
            $Item.DisplayName = Switch ($Item.Index)
            {
                0 { "Windows Server 2000"    }
                1 { "Windows Server 2003"    }
                2 { "Windows Server 2008"    }
                3 { "Windows Server 2008 R2" }
                4 { "Windows Server 2012"    }
                5 { "Windows Server 2012 R2" }
                6 { "Windows Server 2016"    }
                7 { "Windows Server 2019"    }
                8 { "Windows Server 2022"    }
            }

            $This.Output     += $Item
        }
        SetMin([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid entry"
            }
                
            ForEach ($Item in $This.Output)
            {
                $Item.Enable = [UInt32]($Item.Index -ge $Index)
            }
        }
        [Object] Current()
        {
            Return $This.Output[$This.Selected]
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.WindowsServerList[{1}]>" -f $This.Output.Count, $This.Name
        }
    }

    # // =======================================================
    # // | [Profile.Type]: Enum type for profile Xaml controls |
    # // =======================================================

    Enum ProfileType
    {
        ForestMode
        DomainMode
        ReplicationSourceDC
        SiteName
        InstallDns
        CreateDnsDelegation
        CriticalReplicationOnly
        NoGlobalCatalog
        DatabasePath
        SysvolPath
        LogPath
        ParentDomainName
        DomainName
        DomainNetBIOSName
        NewDomainName
        NewDomainNetBIOSName
        SafeModeAdministratorPassword
        Confirm
    }

    # // ======================================================================
    # // | [Profile.Item]: Provides control over a profile (item/Xaml object) |
    # // ======================================================================

    Class ProfileItem
    {
        [UInt32]          $Index
        [String]           $Slot
        [UInt32]          $State
        [String]           $Name
        Hidden [Object] $Control
        [String]           $Type
        [String]       $Property
        [Object]          $Value
        [UInt32]          $Check
        [String]         $Reason
        ProfileItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Index    = $Index
            $This.Slot     = $Slot
            $This.Name     = $Name
            $This.Control  = $Control
            $This.Type     = $Control.GetType().Name
            $This.Property = Switch ($This.Type)
            {
                ComboBox    { "SelectedIndex" }
                TextBox     {          "Text" }
                CheckBox    {     "IsChecked" }
                PasswordBox {      "Password" }
            }
            
            $This.Value    = $This.GetValue()
        }
        [Object] GetValue()
        {
            Return $This.Control.$($This.Property)
        }
        SetValue([Object]$Value)
        {
            $This.Value                     = $Value
            $This.Control.$($This.Property) = $Value
        }
    }

    # // ===================================================================================
    # // | [ProfileBox.Type]: Enum type for boxes of objects that may need to be collapsed |
    # // ===================================================================================

    Enum ProfileBoxType
    {
        ForestModeBox
        DomainModeBox
        ReplicationSourceDCBox
        SiteNameBox
        ParentDomainNameBox
        DomainNameBox
        NewDomainNameBox
        DomainNetBiosNameBox
        NewDomainNetBiosNameBox
    }

    # // =====================================================================
    # // | [ProfileBox.Item]: Boxes of objects that may need to be collapsed |
    # // =====================================================================

    Class ProfileBoxItem
    {
        [UInt32]          $Index
        [String]           $Slot
        [UInt32]          $State
        [String]           $Name
        [String]           $Root
        Hidden [Object] $Control
        [String]           $Type
        [String]       $Property
        [Object]          $Value
        ProfileBoxItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Index    = $Index
            $This.Slot     = $Slot
            $This.Name     = $Name
            $This.Root     = $Name -Replace "Box", ""
            $This.Control  = $Control
            $This.Type     = $Control.GetType().Name
            $This.Property = "Visibility"
            $This.Value    = $This.GetValue()
        }
        [Object] GetValue()
        {
            Return $This.Control.$($This.Property)
        }
        SetValue([Object]$Value)
        {
            $This.Value                     = $Value
            $This.Control.$($This.Property) = $Value
        }
    }

    # // =================================================================
    # // | [Profile.Controller]: Provides control over all profile items |
    # // =================================================================

    Class ProfileController
    {
        [Int32]        $Index
        [String]        $Type
        [String]        $Name
        [String] $Description
        [Object]        $Item
        [Object]         $Box
        Hidden [Object]  $Max
        ProfileController([Object]$Xaml)
        {
            $This.Refresh($Xaml)
            
            $This.Max    = @{ 

                Name     = ($This.Item.Name     | Sort-Object Length)[-1]
                Type     = ($This.Item.Type     | Sort-Object Length)[-1]
                Property = ($This.Item.Property | Sort-Object Length)[-1]
            }
        }
        Clear()
        {
            $This.Item   = @( )
            $This.Box    = @( )
        }
        Refresh([Object]$Xaml)
        {
            $This.Clear()

            # Add items
            ForEach ($Name in [System.Enum]::GetNames([ProfileType]))
            {
                $Slot = Switch -Regex ($Name)
                {
                    "(ForestMode|DomainMode|ReplicationSourceDC|SiteName)"
                    {
                        "Mode"
                    }
                    "(InstallDns|CreateDnsDelegation|CriticalReplicationOnly|NoGlobalCatalog)"
                    {
                        "Role"
                    }
                    "(DatabasePath|SysvolPath|LogPath)"
                    {
                        "Path"
                    }
                    "(ParentDomainName|DomainName|DomainNetBiosName|NewDomainName|NewDomainNetBiosName)"
                    {
                        "Name"
                    }
                    "(SafeModeAdministratorPassword|Confirm)"
                    {
                        "Pass"
                    }
                }

                $This.Add($Slot,$Name,$Xaml.Get($Name))
            }

            # Add Boxes
            ForEach ($Name in [System.Enum]::GetNames([ProfileBoxType]))
            {
                $Slot = Switch -Regex ($Name)
                {
                    "(ForestModeBox|DomainModeBox|ReplicationSourceDCBox|SiteNameBox)"
                    {
                        "Mode"
                    }
                    "(ParentDomainNameBox|DomainNameBox|DomainNetBiosNameBox|NewDomainNameBox|NewDomainNetBiosNameBox)"
                    {
                        "Name"
                    }
                }

                $This.AddBox($Slot,$Name,$Xaml.Get($Name))
            }
        }
        [Object] Output()
        {
            $Out = @{ }
            ForEach ($Item in $This.Item | ? State -eq 1)
            {
                $Out.Add($Item.Name,$This.Item.Value)
            }

            Return $Out
        }
        [String] SystemRoot()
        {
            Return [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [Object] ProfileItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            Return [ProfileItem]::New($Index,$Slot,$Name,$Control)
        }
        [Object] ProfileBoxItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            Return [ProfileBoxItem]::New($Index,$Slot,$Name,$Control)
        }
        Add([String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Item += $This.ProfileItem($This.Item.Count,$Slot,$Name,$Control)
        }
        AddBox([String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Box  += $This.ProfileBoxItem($This.Box.Count,$Slot,$Name,$Control)
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfileController>"
        }
    }

    # // ===================================================
    # // | [Command.Type]: Enum type for each command type |
    # // ===================================================

    Enum CommandType
    {
        Forest
        Tree
        Child
        Clone
    }

    # // ==============================================================================
    # // | [Domain.Type.Item]: Rides off of the CommandType enum to select DomainType |
    # // ==============================================================================

    Class DomainTypeItem
    {
        [UInt32] $Index
        [String]  $Name
        [String] $Value
        DomainTypeItem([String]$Name)
        {
            $This.Index = [UInt32][CommandType]::$Name
            $This.Name  = $Name
            $This.Value = @("-",$Name)[$Name -in "Tree","Child"]
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ==========================================================
    # // | [Domain.Type.List]: List of the above DomainType items |
    # // ==========================================================

    Class DomainTypeList
    {
        [String]     $Name
        [UInt32] $Selected
        [Object]   $Output
        DomainTypeList()
        {
            $This.Name   = "DomainType"
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([CommandType]))
            {
                $This.Add($Name)
            }
        }
        [Object] DomainTypeItem([String]$Name)
        {
            Return [DomainTypeItem]::New($Name)
        }
        Add([String]$Name)
        {
            $This.Output += $This.DomainTypeItem($Name)
        }
        [Object] Current()
        {
            Return $This.Output[$This.Selected]
        }
        [String] ToString()
        {
            Return "<FEDCPromo.DomainTypeList>"
        }
    }
    
    # // ===========================================================================
    # // | [Command.Type.Item]: Extends the CommandType enum with name/description |
    # // ===========================================================================

    Class CommandTypeItem
    {
        [UInt32]       $Index
        [String]        $Type
        [String]        $Name
        [String] $Description
        CommandTypeItem([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            $This.Index       = $Index
            $This.Type        = $Type
            $This.Name        = $Name
            $This.Description = $Description
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandTypeItem>"
        }
    }

    # // =======================================================================
    # // | [Command.Type.List]: A list of the available DC Promo command types |
    # // =======================================================================

    Class CommandTypeList
    {
        [String]     $Name
        [UInt32] $Selected
        [Object]   $Output
        CommandTypeList()
        {
            $This.Name = "Command"
            $This.Stage()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Stage()
        {
            $This.Clear()

            ForEach ($Type in [System.Enum]::GetNames([CommandType]))
            {
                $X = Switch ($Type)
                {
                    Forest {           "Install-AddsForest" ,              "Creates a new Active Directory forest" }
                    Tree   {           "Install-AddsDomain" ,         "Creates a new Active Directory tree domain" }
                    Child  {           "Install-AddsDomain" ,        "Creates a new Active Directory child domain" }
                    Clone  { "Install-AddsDomainController" , "Adds a new domain controller to an existing domain" }
                }

                $This.Add($This.Index($Type),$Type,$X[0],$X[1])
            }
        }
        [Object] CommandTypeItem([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            Return [CommandTypeItem]::New($Index,$Type,$Name,$Description)
        }
        [UInt32] Index([String]$Type)
        {
            Return [UInt32][CommandType]::$Type
        }
        Add([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            $This.Output += $This.CommandTypeItem($Index,$Type,$Name,$Description)
        }
        [Object] Current()
        {
            Return $This.Output[$This.Selected]
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandTypeList>"
        }
    }
    
    # // =====================================================================================
    # // | [Connection.Item]: Returned info from a successful connection to Active Directory |
    # // =====================================================================================

    Class ConnectionItem
    {
        [String]        $IPAddress
        [String]          $DNSName
        [String]           $Domain
        [String]          $NetBIOS
        [PSCredential] $Credential
        Hidden [String]      $Site
        [String[]]       $Sitename
        [String[]]  $ReplicationDC
        ConnectionItem([Object]$Login)
        {
            $This.IPAddress            = $Login.IPAddress
            $This.DNSName              = $Login.DNSName
            $This.Domain               = $Login.Domain
            $This.NetBIOS              = $Login.NetBIOS
            $This.Credential           = $Login.Credential
            $This.Site                 = $Login.GetSitename()
            $Login.Directory           = $Login.Directory.Replace("CN=Partitions,","")
            $Login.Searcher.SearchRoot = $Login.Directory
            $Login.Result              = $Login.Searcher.FindAll()
            $This.Sitename             = @( )
            $This.Sitename            += $This.Site
            ForEach ($Item in $Login.Result | ? Path -Match "NTDS Site Settings")
            {
                $Item.Path.Split(",")[1].Replace("CN=","") | ? { $_ -ne $This.Site } | % { $This.Sitename += $_ }
            }
        }
        AddReplicationDCs([Object[]]$DCs)
        {
            $This.ReplicationDC        = $DCs.Hostname | Select-Object -Unique
        }
        [String] ToString()
        {
            Return "<FEDCPromo.Connection>"
        }
    }

    # // ===================================================================
    # // | [Validation.Item]: A single object for (domain/type) validation |
    # // ===================================================================
    
    Class ValidationItem
    {
        [UInt32] $Index
        [String] $Type
        [String] $Value
        ValidationItem([UInt32]$Index,[String]$Type,[String]$Value)
        {
            $This.Index = $Index
            $This.Type  = $Type
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return $This.Value
        }
    }

    # // ==========================================================
    # // | [Validation.Controller]: Contains all validation items |
    # // ==========================================================

    Class ValidationController
    {
        [String]   $Name
        [Object] $Output
        ValidationController()
        {
            $This.Name   = "Validation"
            $This.Stage()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Stage()
        {
            $This.Clear()
            ForEach ($Name in "Reserved","Legacy","SecurityDescriptor")
            {
                $This.Load($Name)
            }
        }
        Load([String]$Name)
        {
            ForEach ($Item in $This.Item($Name))
            {
                $This.Add($Name,$Item)
            }
        }
        [Object] ValidationItem([UInt32]$Index,[String]$Type,[String]$Value)
        {
            Return [ValidationItem]::New($Index,$Type,$Value)
        }
        Add([String]$Type,[String]$Value)
        {
            $This.Output += $This.ValidationItem($This.Output.Count,$Type,$Value)
        }
        [String[]] Item([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Reserved
                {
                    "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GR"+
                    "OUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;DIALUP;DIGEST AUTH;IN"+
                    "TERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AU"+
                    "THORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTE"+
                    "D;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORG"+
                    "ANIZATION;USERS;WORLD"
                }
                Legacy
                {
                    "-GATEWAY;-GW;-TAC"
                }
                SecurityDescriptor
                {
                    "AN;AO;AU;BA;BG;BO;BU;CA;CD;CG;CO;DA;DC;DD;DG;DU;EA;ED;HI;IU;LA;LG;L"+
                    "S;LW;ME;MU;NO;NS;NU;PA;PO;PS;PU;RC;RD;RE;RO;RS;RU;SA;SI;SO;SU;SY;WD"
                }
            }
            
            Return $Item -Split ";"
        }
        [String] Password()
        {
            Return "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.ValidationController>" -f $This.Output.Count
        }
    }

    # // ========================================================================================
    # // | [Execution.Controller]: Provides a controller specifically meant for execution phase |
    # // ========================================================================================

    Class ExecutionController
    {
        [String]     $Name
        [Object]  $Summary
        [Object]  $Feature
        [Object]   $Result
        [UInt32]  $Restart
        [Object]   $Output
        ExecutionController()
        {
            $This.Name    = "Execution"
            $This.Clear("Summary")
            $This.Clear("Feature")
            $This.Clear("Result")
            $This.Clear("Output")
        }
        Clear([String]$Name)
        {
            Switch ($Name)
            {
                Summary { $This.Summary = @( ) }
                Feature { $This.Feature = @( ) }
                Result  { $This.Result  = @( ) }
                Output  { $This.Output  = @{ } }
            }
        }
        [SecureString] Password([String]$String)
        {
            Return $String | ConvertTo-SecureString -AsPlainText -Force
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ExecutionController>"
        }
    }

    # // =========================================================================================
    # // | [Command.Controller]: Controller for (command/domain) type, and (forest/domain) modes |
    # // =========================================================================================

    Class CommandController
    {
        [String]       $Name
        [UInt32]       $Slot = 0
        [Object]    $Command
        [Object] $DomainType
        [Object] $ForestMode
        [Object] $DomainMode
        CommandController()
        {
            $This.Name       = "CommandController"
            $This.Command    = $This.New("Command")
            $This.DomainType = $This.New("DomainType")
            $This.ForestMode = $This.New("ForestMode")
            $This.DomainMode = $This.New("DomainMode")
        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Command     {   [CommandTypeList]::New()             }
                DomainType  {    [DomainTypeList]::New()             }
                ForestMode  { [WindowsServerList]::New("ForestMode") }
                DomainMode  { [WindowsServerList]::New("DomainMode") }
            }

            Return $Item
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Command    { $This.Command    }
                DomainType { $This.DomainType }
                ForestMode { $This.ForestMode }
                DomainMode { $This.DomainMode }
            }

            Return $Item
        }
        SetForestMode([UInt32]$Index)
        {
            $This.ForestMode.Selected = $Index
        }
        SetDomainMode([UInt32]$Index)
        {
            $This.DomainMode.Selected = $Index
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandController>"
        }
    }

    # // ====================================================================
    # // | [FEDCPromo.Controller]: Orchestrates all components of FEDCPromo |
    # // ====================================================================

    Class FEDCPromoController
    {
        [Object]    $Console
        [UInt32]       $Mode
        [UInt32]    $Staging
        [UInt32]       $Test
        [Object]       $Xaml
        [Object]    $Control
        [Object]    $Profile
        [Object]     $Module
        [Object]     $System
        [Object]    $Network
        [Object]    $Feature
        [String]    $Caption
        [UInt32]     $Server
        [Object] $Validation
        [Object]  $Execution
        [Object] $Connection
        [Object] $Credential
        FEDCPromoController([UInt32]$Mode)
        {
            $This.Mode     = $Mode
            If ($This.Mode -ge 2)
            {
                $This.Test = 1
            }

            $This.Main()
        }
        FEDCPromoController([UInt32]$Mode,[String]$InputPath)
        {
            $This.Mode     = $Mode
            If ($This.Mode -ge 2)
            {
                $This.Test = 1
            }

            $This.Main()

            $This.SetInputObject($InputPath)
        }
        FEDCPromoController([Switch]$Flags)
        {
            # This is meant for testing and using the embedded (methods/classes)
        }
        [Void] StartConsole()
        {
            # Instantiates and initializes the console
            $This.Console = New-FEConsole
            $This.Console.Initialize()
            $This.Status()
        }
        [Void] Status()
        {
            # If enabled, shows the last item added to the console
            If ($This.Mode -gt 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        [Void] Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        [Void] Error([String]$Status)
        {
            $This.Console.Update(-1,$Status)
            Throw $This.Console.Last().Status
        }
        Main()
        {
            # =============================== #
            # Console | Mode | Staging | Test #
            # =============================== #

            # Initialize console
            $This.StartConsole()

            # ======================== #
            # Xaml | Control | Profile #
            # ======================== #

            # Load Xaml interface
            $This.Xaml     = $This.New("Xaml")

            # Load Command controller
            $This.Control  = $This.New("Control")

            # Load Profile controller
            $This.Profile  = $This.New("Profile")
            
            # =================================== #
            # Module | System | Network | Feature #
            # =================================== #

            # Primary components
            $This.Module   = $This.New("Module")
            $This.System   = $This.New("System")
            $This.Network  = $This.New("Network")

            # Poll (network connectivity/DHCP)
            $Check         = $This.System.Network.Output | ? Status
            Switch ($Check.Count)
            {
                0
                {
                    $This.Error("[!] No network detected")
                }
                1
                {
                    If ($Check[0].DhcpServer -notmatch "(\d+\.){3}\d+")
                    {
                        $This.Update(0,"[!] Static IP Address not set")
                    }
                }
                Default
                {
                    If ($Check.DhcpServer -notmatch "(\d+\.){3}\d+")
                    {
                        $This.Update(0,"[!] Static IP Address not set")
                    }
                }
            }

            # Load features
            $This.Feature  = $This.New("Feature")

            # Check if system is a virtual machine
            If ($This.System.ComputerSystem.Model -match "Virtual")
            {
                $This.Update(0,"[!] Current system is a virtual machine")
                $This.Module.Write(1,$This.Console.Last().Status)

                ForEach ($Item in $This.Feature.Output | ? Type -eq Veridian)
                {
                    $Item.Enable  = 0
                    $Item.Install = 0
                }
            }

            # ================ #
            # Caption | Server #
            # ================ #

            # Server information
            $This.Caption  = $This.System.OperatingSystem.Caption
            $This.Server   = Switch -Regex ($This.Caption)
            {
                "(2000)"        { 0 } "(2003)"        { 1 } "(2008 (?!R2))" { 2 } 
                "(2008 R2)"     { 3 } "(2012 (?!R2))" { 4 } "(2012 R2)"     { 5 } 
                "(2016)"        { 6 } "(2019)"        { 7 } "(2022)"        { 8 } 
            }

            If ($This.Server -le 3)
            {
                $This.Update(0,"[!] This operating system may not support this function")
            }

            # Stage command (Forest/Domain) modes
            $This.Control.ForestMode.SetMin($This.Server)
            $This.Control.DomainMode.SetMin($This.Server)

            # ================================================ #
            # Validation | Execution | Connection | Credential #
            # ================================================ #

            # Get validation controller
            $This.Validation    = $This.New("Validation")

            # Load execution controller
            $This.Execution     = $This.New("Execution")

            # Set (connection + credential) to $Null
            $This.Connection    = $Null
            $This.Credential    = $Null
        }
        [Object] New([String]$Name)
        {
            # Returns an instantiation of the named (function/class)
            $Item = Switch ($Name)
            {
                Xaml       { [XamlWindow][FEDCPromoXaml]::Content           }
                Control    {         [CommandController]::New()             }
                Profile    {         [ProfileController]::New($This.Xaml)   }
                Module     { Get-FEModule -Mode 1                           }
                System     { Get-FESystem -Mode 0 -Level 3                  }
                Network    { Get-FENetwork -Mode 7                          }
                Feature    {         [FeatureController]::New()             }
                Validation {      [ValidationController]::New()             }
                Execution  {       [ExecutionController]::New()             }
                FEDCFound  { [XamlWindow][FEDCFoundXaml]::Content           }
            }

            # Logs the instantiation of the named (function/class)
            Switch ([UInt32]!!$Item)
            {
                0 { $This.Update(-1,"[!] Fail : [$Name]") }
                1 { $This.Update( 1,"[+] Pass : [$Name]") }
            }

            Return $Item
        }
        [Object] InputObjectController([String]$Path)
        {
            Return [InputObjectController]::New($Path)
        }
        [String] ProgramData()
        {
            # Returns the program data path
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] MachineName()
        {
            # Returns the machine name
            Return [Environment]::MachineName
        }
        [String] SystemRoot()
        {
            # Returns the system root path
            Return [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [UInt32] TestPath([String]$Path)
        {
            Return [System.IO.Directory]::Exists($Path)
        }
        [String] OutputFolder()
        {
            $List = $This.ProgramData(),
                    "Secure Digits Plus LLC",
                    "FEDCPromo",
                    $This.Console.Start.Time.ToString("yyyyMMdd")

            $Path = $List -join "\"

            If (!$This.TestPath($Path))
            {
                $Path = $List[0]
                ForEach ($Item in $List[1..3])
                {
                    $Path += "\$Item"
                    If (!$This.TestPath($Path))
                    {
                        [System.IO.Directory]::CreateDirectory($Path) | Out-Null
                    }
                }
            }

            Return $Path
        }
        [Object] InstallWindowsFeature([String]$Name)
        {
            # Installs a specified feature
            Return Install-WindowsFeature -Name $Name -IncludeAllSubfeature -IncludeManagementTools
        }
        [String] InsertLine([String]$Char)
        {
            $Line = "$($Char[0])"
            Return $Line.PadRight(80,$Line)
        }
        [String] ProfileControlStatus([Object]$Item)
        {
            $Line = "[{0}] {1:d2} {2} {3} {4} {5} {6}" 
            
            Return $Line -f @(" ","X")[$Item.State],
                            $Item.Index, 
                            $Item.Slot, 
                            $Item.Name.PadRight($This.Profile.Max.Name.Length," "),
                            $Item.Type.PadRight($This.Profile.Max.Type.Length," "),
                            $Item.Property.PadRight($This.Profile.Max.Property.Length," "),
                            $Item.Value
        }
        [String] Icon([UInt32]$Type)
        {
            # Returns the (success/failure) graphic based on the type 
            Return $This.Module._Control(@("failure.png","success.png")[$Type]).Fullname
        }
        [Object] Validate([String]$Type)
        {
            # Retrieves a list of specific item types from the validation controller
            Return $This.Validation.Output | ? Type -eq $Type | % Value
        }
        [Object] Reserved()
        {
            # Returns reserved items from the validation controller
            Return $This.Validate("Reserved")
        }
        [Object] Legacy()
        {
            # Returns legacy items from the validation controller
            Return $This.Validate("Legacy")
        }
        [Object] SecurityDescriptor()
        {
            # Returns security descriptor items from the validation controller
            Return $This.Validate("SecurityDescriptor")
        }
        [String] DefaultText([String]$Name)
        {
            # Returns the default string for the properties below
            $Item = Switch ($Name)
            {
                ParentDomainName     { "<Enter Domain Name> or <Credential>"  }
                DomainName           { "<Enter Domain Name> or <Credential>"  }
                DomainNetBIOSName    { "<Enter NetBIOS Name> or <Credential>" }
                NewDomainName        { "<Enter New Domain Name>"              }
                NewDomainNetBIOSName { "<Enter New NetBIOS Name>"             }
            }

            Return $Item
        }
        ToggleStaging()
        {
            # Toggles whether event handlers are (engaged/suppressed)
            $This.Staging = !$This.Staging
        }
        SetForestMode([UInt32]$Index)
        {
            $Item = $This.Control.ForestMode
            If ($Index -in $Item.Output.Index)
            {
                $Item.Selected = $Index
            }
            Else
            {
                $Item.Selected = ($Item.Output | ? Enable)[0].Index
            }

            $This.Get("ForestMode").SetValue($Item.Current().Index)
        }
        SetDomainMode([UInt32]$Index)
        {
            $Item = $This.Control.DomainMode
            If ($Index -in $Item.Output.Index)
            {
                $Item.Selected = $Index
            }
            Else
            {
                $Item.Selected = ($Item.Output | ? Enable)[0].Index
            }

            $This.Get("DomainMode").SetValue($Item.Current().Index)
        }
        SetProfile([UInt32]$Index)
        {
            $This.Update(0,$This.InsertLine("="))
            $This.Update(0,"[~] Profile -> [Command]")
            $This.Update(0,$This.InsertLine(" "))

            # Sets the currently selected profile
            $This.Control.Slot                = $Index
            $This.Control.Command.Selected    = $Index
            $This.Control.DomainType.Selected = $Index

            # Selects the currently selected command
            $Command                          = $This.Control.Command.Current()

            # Applies the currently selected command
            $This.Profile.Index               = $Command.Index
            $This.Profile.Type                = $Command.Type
            $This.Profile.Name                = $Command.Name
            $This.Profile.Description         = $Command.Description

            # Collects the current selection
            $Line  = @( )
            $Line += "Index       : {0}" -f $Command.Index
            $Line += "Type        : {0}" -f $Command.Type
            $Line += "Name        : {0}" -f $Command.Name
            $Line += "Description : {0}" -f $Command.Description

            # Writes the current selection collection to console
            $Line  | % { $This.Update(1,$_) }
            
            # Changes the selected command
            $Item                             = $This.Xaml.Get("CommandSlot")
            $Item.SelectedIndex               = $Index
            $This.Update(0,$This.InsertLine(" "))
    
            # Process each (profile/Xaml) object
            $This.Update(0,$This.InsertLine("="))
            $This.Update(0,"[~] Profile -> [Xaml]")
            $This.Update(0,$This.InsertLine(" "))

            $This.ToggleStaging()

            ForEach ($Item in $This.Profile.Output)
            {
                $Item.State           = Switch ($Item.Name)
                {
                    ForestMode                    { @(1,0,0,0)[$Index] }
                    DomainMode                    { @(1,1,1,0)[$Index] }
                    ReplicationSourceDc           { @(0,0,0,1)[$Index] }
                    Sitename                      { @(0,1,1,1)[$Index] }
                    InstallDns                    { @(1,1,1,1)[$Index] }
                    CreateDnsDelegation           { @(1,1,1,1)[$Index] }
                    CriticalReplicationOnly       { @(0,0,0,1)[$Index] }
                    NoGlobalCatalog               { @(1,1,1,1)[$Index] }
                    DatabasePath                  { @(1,1,1,1)[$Index] }
                    SysvolPath                    { @(1,1,1,1)[$Index] }
                    LogPath                       { @(1,1,1,1)[$Index] }
                    ParentDomainName              { @(0,1,1,0)[$Index] }
                    DomainName                    { @(1,0,0,1)[$Index] }
                    DomainNetBiosName             { @(1,0,0,0)[$Index] }
                    NewDomainName                 { @(0,1,1,0)[$Index] }
                    NewDomainNetBiosName          { @(0,1,1,0)[$Index] }
                    SafeModeAdministratorPassword { @(1,1,1,1)[$Index] }
                    Confirm                       { @(1,1,1,1)[$Index] }
                    Credential                    { @(0,1,1,1)[$Index] }
                }

                $Item.Control.IsEnabled = $Item.State

                $Value = Switch ($Item.Slot)
                {
                    Mode 
                    {
                        0
                    }
                    Role
                    {
                        Switch ($Item.Name)
                        {
                            InstallDns                { @(1,1,1,1)[$Index] }
                            CreateDnsDelegation       { @(0,0,1,0)[$Index] }
                            CriticalReplicationOnly   { @(0,0,0,0)[$Index] }
                            NoGlobalCatalog           { @(0,0,0,0)[$Index] }
                        }
                    }
                    Path
                    {
                        Switch ($Item.Name)
                        {
                            DataBasePath { "{0}\NTDS"   -f $This.SystemRoot() }
                            SysVolPath   { "{0}\SYSVOL" -f $This.SystemRoot() }
                            LogPath      { "{0}\NTDS"   -f $This.SystemRoot() }
                        }
                    }
                    Name
                    {
                        Switch ($Item.Name)
                        {
                            ParentDomainName     { "<Enter Domain Name> or <Credential>"  }
                            DomainName           { "<Enter Domain Name> or <Credential>"  }
                            DomainNetBIOSName    { "<Enter NetBIOS Name> or <Credential>" }
                            NewDomainName        { "<Enter New Domain Name>"              }
                            NewDomainNetBIOSName { "<Enter New NetBIOS Name>"             }
                        }
                    }
                    Pass
                    {
                        $Null
                    }
                }

                $Item.SetValue($Value)

                $Box = $This.Profile.Box | ? Root -eq $Item.Name
                If ($Box)
                {
                    $Box.SetValue(@("Collapsed","Visible")[$Item.State])
                }

                $This.Update(1,$This.ProfileControlStatus($Item))
            }

            $This.Update(0,$This.InsertLine(" "))

            $This.ToggleStaging()
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            # Resets the items within a given combobox or datagrid
            If ($This.Mode -gt 0)
            {
                $Line = "{0} [{1}]" -f $xSender.Name, $xSender.GetType().Name
                $This.Update(0,"[~] $Line")
            }

            $xSender.Items.Clear()
            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        [Object] Get([String]$Name)
        {
            # Returns the specified profile item from profile controller
            Return $This.Profile.Output | ? Name -eq $Name
        }
        Toggle([String]$Name)
        {
            $Item = $This.Get($Name)
            If ($Item.Type -eq "CheckBox")
            {
                $Item.SetValue(!$Item.GetValue())
            }

            $Line = "[{0}] {1}" -f @(" ","X")[$Item.State], $Item.Name
            $This.Update(1,$Line)
        }
        Validate([Object]$Item,[String]$Reason)
        {
            If ($Item.Type -in "TextBox","PasswordBox")
            {
                $Item.Check  = [UInt32]($Reason -eq "[+] Passed")
                $Item.Reason = $Reason
            }
        }
        Check([String]$Name)
        {
            $Item       = $This.Get($Name)
            $Item.Value = $Item.Control.Text
            $Icon       = $This.Xaml.Get("${Name}Icon")

            If (!$This.Staging)
            {
                Switch ($Item.State)
                {
                    0
                    {
                        $Item.Control.Visibility = "Collapsed"
                        $Icon.Source             = $Null
                        $Icon.Tooltip            = $Null
                        $Icon.Visibility         = "Collapsed"
                    }
                    1
                    {
                        $This.Update(0,"[~] Field [$Name]")

                        Switch ($Name)
                        {
                            {$_ -in "ParentDomainName","DomainName"}
                            { 
                                $This.CheckItem("Domain",$Item) 
                            }
                            {$_ -in "DomainNetBiosName","NewDomainNetBiosName"}
                            {
                                $This.CheckItem("NetBios",$Item)
                            }
                            {$_ -eq "NewDomainName" -and $This.Control.Slot -eq 1}
                            {
                                $This.CheckItem("Tree",$Item)
                            }
                            {$_ -eq "NewDomainName" -and $This.Control.Slot -eq 2}
                            {
                                $This.CheckItem("Child",$Item)
                            }
                        }
    
                        $Item.Control.Visibility = "Visible"
                        $Icon.Source             = $This.Icon($Item.Check)
                        $Icon.Tooltip            = $Item.Reason
                        $Icon.Visibility         = "Visible"
                    }
                }

                $This.Total()
            }
        }
        CheckItem([String]$Type,[Object]$Item)
        {
            $X = $Null
            Switch ($Type)
            {
                Domain
                {
                    If ($Item.Value.Length -lt 2 -or $Item.Value.Length -gt 63)
                    {
                        $X = "[!] Length not between 2 and 63 characters"
                    }
                    ElseIf ($Item.Value -in $This.Reserved())
                    {
                        $X = "[!] Entry is in reserved words list"
                    }
                    ElseIf ($Item.Value -in $This.Legacy())
                    {
                        $X = "[!] Entry is in the legacy words list"
                    }
                    ElseIf ($Item.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $X = "[!] Invalid characters"
                    }
                    ElseIf ($Item.Value[0,-1] -match "(\W)")
                    {
                        $X = "[!] First/Last Character cannot be a '.' or '-'"
                    }
                    ElseIf ($Item.Value.Split(".").Count -lt 2)
                    {
                        $X = "[!] Single label domain names are disabled"
                    }
                    ElseIf ($Item.Value.Split('.')[-1] -notmatch "\w")
                    {
                        $X = "[!] Top Level Domain must contain a non-numeric"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
                NetBios
                {
                    If ($Item.Value -eq $This.Connection.NetBIOS)
                    {
                        $X = "[!] New NetBIOS ID cannot be the same as the parent domain NetBIOS"
                    }
                    ElseIf ($Item.Value.Length -lt 1 -or $Item.Value.Length -gt 15)
                    {
                        $X = "[!] Length not between 1 and 15 characters"
                    }
                    ElseIf ($Item.Value -in $This.Reserved())
                    {
                        $X = "[!] Entry is in reserved words list"
                    }
                    ElseIf ($Item.Value -in $This.Legacy())
                    {
                        $X = "[!] Entry is in the legacy words list"
                    }
                    ElseIf ($Item.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $X = "[!] Invalid characters"
                    }
                    ElseIf ($Item.Value[0,-1] -match "(\W)")
                    {
                        $X = "[!] First/Last Character cannot be a '.' or '-'"
                    }                        
                    ElseIf ($Item.Value -match "\.")
                    {
                        $X = "[!] NetBIOS cannot contain a '.'"
                    }
                    ElseIf ($Item.Value -in $This.SecurityDescriptor())
                    {
                        $X = "[!] Matches a security descriptor"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
                Tree
                {
                    If ($Item.Value -match [Regex]::Escape($This.Get("ParentDomainName").Text))
                    {
                        $X = "[!] Cannot be a (child/host) of the parent"
                    }
                    ElseIf ($Item.Value.Split(".").Count -lt 2)
                    {
                        $X = "[!] Single label domain names are disabled"
                    }
                    ElseIf ($Item.Value.Split('.')[-1] -notmatch "\w")
                    {
                        $X = "[!] Top Level Domain must contain a non-numeric"
                    }
                    ElseIf ($Item.Value.Length -lt 2 -or $Item.Value.Length -gt 63)
                    {
                        $X = "[!] Length not between 2 and 63 characters"
                    }
                    ElseIf ($Item.Value -in $This.Reserved())
                    {
                        $X = "[!] Entry is in reserved words list"
                    }
                    ElseIf ($Item.Value -in $This.Legacy())
                    {
                        $X = "[!] Entry is in the legacy words list"
                    }
                    ElseIf ($Item.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $X = "[!] Invalid characters"
                    }
                    ElseIf ($Item.Value[0,-1] -match "(\W)")
                    {
                        $X = "[!] (First/Last) character cannot be either: (./-)"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
                Child
                {
                    If ($Item.Value -notmatch ".$($This.Get("ParentDomainName").Text)")
                    {
                        $X = "[!] Must be a (child/host) of the parent"
                    }
                    ElseIf ($Item.Value.Length -lt 2 -or $Item.Value.Length -gt 63)
                    {
                        $X = "[!] Length not between (2-63) characters"
                    }
                    ElseIf ($Item.Value -in $This.Reserved())
                    {
                        $X = "[!] Entry is reserved"
                    }
                    ElseIf ($Item.Value -in $This.Legacy())
                    {
                        $X = "[!] Entry is legacy"
                    }
                    ElseIf ($Item.Value -notmatch "([\.\-0-9a-zA-Z])")
                    {
                        $X = "[!] Invalid characters"
                    }
                    ElseIf ($Item.Value[0,-1] -match "(\W)")
                    {
                        $X = "[!] (First/Last) character cannot be either: (./-)"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
            }

            $This.Validate($Item,$X)

            $This.Update($Item.Check,$Item.Reason)
        }
        CheckPassword()
        {
            $Pattern        = $This.Validation.Password()
            $Password       = $This.Get("SafeModeAdministratorPassword")
            $Password.Value = $Password.Control.Password

            $Confirm        = $This.Get("Confirm")
            $Confirm.Value  = $Confirm.Control.Password

            Switch -Regex ($Password.Value)
            {
                Default
                {
                    $This.Validate($Password,"[!] 10 chars, and at least: (1) Uppercase, (1) Lowercase, (1) Special, (1) Number")
                }
                $Pattern
                {
                    $This.Validate($Password,"[+] Passed")
                }
            }

            Switch ($Password.Check)
            {
                0
                {
                    $This.Validate($Confirm,"[!] Password not valid")
                }
                1
                {
                    If ($Confirm.Value -ne $Password.Value)
                    {
                        $This.Validate($Confirm,"[!] Confirmation error")
                    }
                    ElseIf ($Confirm.Value -eq $Password.Value)
                    {
                        $This.Validate($Confirm,"[+] Passed")
                    }
                }
            }

            ForEach ($Item in $Password, $Confirm)
            {
                $Name         = $Item.Name + "Icon"
                $Icon         = $This.Get("${Name}Icon")

                $Icon.Source  = $This.Icon($Item.Check)
                $Icon.Tooltip = $Item.Reason
            }

            $This.Total()
        }
        Browse([String]$Name)
        {
            $List = $This.Profile | ? Slot -eq Path | % Name
            If ($Name -notin $List)
            {
                $This.Error(-1,"[!] Invalid <browse> option")
            }

            $Object                  = $This.Get($Name)
            $Item                    = New-Object System.Windows.Forms.FolderBrowserDialog
            $Item.ShowDialog()
        
            If (!$Item.SelectedPath)
            {
                $Item.SelectedPath   = $Object.Value
            }
            Else
            {
                $Object.SetValue($Item.SelectedPath)
            }
        }
        Total()
        {
            $This.Execution.Clear("Summary")
            
            ForEach ($Item in $This.Control.Profile.List("Slot") | ? IsEnabled | ? Property -eq Text)
            {
                $This.Execution.Summary += $Item
            }

            ForEach ($Item in $This.Control.Profile.List("DSRM"))
            {
                $This.Execution.Summary += $Item
            }

            $This.Reset($This.Xaml.IO.Summary,$This.Execution.Summary)

            $This.Xaml.IO.Start.IsEnabled = 0 -notin $This.Execution.Summary.Check
            $This.Xaml.IO.Test.IsEnabled  = 0 -notin $This.Execution.Summary.Check
            $This.Xaml.IO.Save.IsEnabled  = 0 -notin $This.Execution.Summary.Check

        }
        StageXaml()
        {
            $Ctrl          = $This

            # // ===========
            # // | Command |
            # // ===========

            # [ComboBox] Command slot 
            $Ctrl.Reset($Ctrl.Xaml.IO.CommandSlot,$Ctrl.Control.Command.Output.Type)

            # [ComboBox] Command slot (Event handler)
            $Ctrl.Xaml.IO.CommandSlot.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.CommandSlot.SelectedIndex
                $Ctrl.SetProfile($Index)
                $Ctrl.Reset($Ctrl.Xaml.IO.Command,$Ctrl.Control.Profile)
            })

            # // ========
            # // | Mode |
            # // ========

            # [DataGrid] OS Caption
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystemCaption,$Ctrl.System.OperatingSystem)

            # [Datagrid] OS Properties 
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystemExtension,$Ctrl.System.OperatingSystem)

            # [ComboBox] Forest mode
            $Ctrl.Reset($Ctrl.Xaml.IO.ForestMode,$Ctrl.Control.ForestMode.Output)

            # [ComboBox -> Ctrl.Control -> Datagrid] Forest mode (Event handler)
            $Ctrl.Xaml.IO.ForestMode.Add_SelectionChanged(
            {
                $Ctrl.Control.ForestMode.Selected = $Ctrl.Xaml.IO.ForestMode.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.ForestModeExtension,$Ctrl.Control.ForestMode.Current())
            })

            # [ComboBox] Domain mode
            $Ctrl.Reset($Ctrl.Xaml.IO.DomainMode,$Ctrl.Control.DomainMode.Output)

            # [ComboBox -> Ctrl.Control -> Datagrid] Domain mode (Event handler)
            $Ctrl.Xaml.IO.DomainMode.Add_SelectionChanged(
            {
                $Ctrl.Control.DomainMode.Selected = $Ctrl.Xaml.IO.DomainMode.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.DomainModeExtension,$Ctrl.Control.DomainMode.Current())
            })

            # [ComboBox] Replication Source DC
            $Ctrl.Reset($Ctrl.Xaml.IO.ReplicationSourceDC,$Null)

            # // ============
            # // | Features |
            # // ============

            # [DataGrid] Windows Features
            $Ctrl.Reset($Ctrl.Xaml.IO.Feature,$Ctrl.Feature.Output)

            # // =========
            # // | Roles |
            # // =========

            # [CheckBox] Install Dns (Event handler)
            $Ctrl.Xaml.IO.InstallDNS.Add_IsEnabledChanged(
            {
                $Ctrl.Toggle("InstallDns")
            })

            # [CheckBox] Create Dns Delegation (Event handler)
            $Ctrl.Xaml.IO.CreateDnsDelegation.Add_IsEnabledChanged(
            {
                $Ctrl.Toggle("CreateDnsDelegation")
            })

            # [CheckBox] No Global Catalog (Event handler)
            $Ctrl.Xaml.IO.NoGlobalCatalog.Add_IsEnabledChanged(
            {
                $Ctrl.Toggle("NoGlobalCatalog")
            })

            # [CheckBox] Critical Replication Only (Event handler)
            $Ctrl.Xaml.IO.CriticalReplicationOnly.Add_IsEnabledChanged(
            {
                $Ctrl.Toggle("CriticalReplicationOnly")
            })

            # // =========
            # // | Paths |
            # // =========

            # [Button] Database path (Event handler)
            $Ctrl.Xaml.IO.DatabaseBrowse.Add_Click(
            {
                $Ctrl.Browse("DatabasePath")
            })
            
            # [Button] Sysvol path (Event handler)
            $Ctrl.Xaml.IO.SysvolBrowse.Add_Click(
            {
                $Ctrl.Browse("SysvolPath")
            })

            # [Button] Log path (Event handler)
            $Ctrl.Xaml.IO.LogBrowse.Add_Click(
            {
                $Ctrl.Browse("LogPath")
            })

            # // =========
            # // | Names |
            # // =========

            # [TextBox] ParentDomainName (Text changed event handler)
            $Ctrl.Xaml.IO.ParentDomainName.Add_TextChanged(
            {
                $Ctrl.Check("ParentDomainName")
            })

            # [TextBox] ParentDomainName (Got focus event handler)
            $Ctrl.Xaml.IO.ParentDomainName.Add_GotFocus(
            {
                If ($Ctrl.Xaml.IO.ParentDomainName.Text -eq $Ctrl.DefaultText("ParentDomainName"))
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("ParentDomainName").SetValue("")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] ParentDomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.ParentDomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.ParentDomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("ParentDomainName").SetValue($Ctrl.DefaultText("ParentDomainName"))
                    $Ctrl.ToggleStaging()
                }
            })
            
            # [TextBox] DomainName (Text changed event handler)
            $Ctrl.Xaml.IO.DomainName.Add_TextChanged(
            {
                $Ctrl.Check("DomainName")
            })

            # [TextBox] DomainName (Got focus event handler)
            $Ctrl.Xaml.IO.DomainName.Add_GotFocus(
            {
                If ($Ctrl.Xaml.IO.DomainName.Text -eq $Ctrl.DefaultText("DomainName"))
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("DomainName").SetValue("")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] DomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.DomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.DomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("DomainName").SetValue($Ctrl.DefaultText("DomainName"))
                    $Ctrl.ToggleStaging()
                }
            })
            
            # [TextBox] NewDomainName (Event handler)
            $Ctrl.Xaml.IO.NewDomainName.Add_TextChanged(
            {
                $Ctrl.Check("NewDomainName")
            })

            # [TextBox] NewDomainName (Got focus event handler)
            $Ctrl.Xaml.IO.NewDomainName.Add_GotFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainName.Text -eq $Ctrl.DefaultText("NewDomainName"))
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("NewDomainName").SetValue("")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] NewDomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.NewDomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("NewDomainName").SetValue($Ctrl.DefaultText("NewDomainName"))
                    $Ctrl.ToggleStaging()
                }
            })
            
            # [TextBox] DomainNetBiosName (Event handler)
            $Ctrl.Xaml.IO.DomainNetBIOSName.Add_TextChanged(
            {
                $Ctrl.Check("DomainNetBiosName")
            })

            # [TextBox] DomainNetBiosName (Got focus event handler)
            $Ctrl.Xaml.IO.DomainNetBiosName.Add_GotFocus(
            {
                If ($Ctrl.Xaml.IO.DomainNetBiosName.Text -eq $Ctrl.DefaultText("DomainNetBiosName"))
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("DomainNetBiosName").SetValue("")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] DomainNetBiosName (Lost focus event handler)
            $Ctrl.Xaml.IO.DomainNetBiosName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.DomainNetBiosName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("DomainNetBiosName").SetValue($Ctrl.DefaultText("DomainNetBiosName"))
                    $Ctrl.ToggleStaging()
                }
            })
        
            # [TextBox] NewDomainNetBiosName (Event handler)
            $Ctrl.Xaml.IO.NewDomainNetBiosName.Add_TextChanged(
            {
                $Ctrl.Check("NewDomainNetBiosName")
            })

            # [TextBox] NewDomainNetBiosName (Got focus event handler)
            $Ctrl.Xaml.IO.NewDomainNetBiosName.Add_GotFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainNetBiosName.Text -eq $Ctrl.DefaultText("NewDomainNetBiosName"))
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("NewDomainNetBiosName").SetValue("")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] NewDomainNetBiosName (Lost focus event handler)
            $Ctrl.Xaml.IO.NewDomainNetBiosName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainNetBiosName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Get("NewDomainNetBiosName").SetValue($Ctrl.DefaultText("NewDomainNetBiosName"))
                    $Ctrl.ToggleStaging()
                }
            })

            # // ==============
            # // | Credential |
            # // ==============

            # [Button] Login (Event handler)
            $Ctrl.Xaml.IO.CredentialButton.Add_Click(
            {
                $Ctrl.Login()
            })

            # [TextBox] Dsrm Password (Event handler)
            $Ctrl.Xaml.IO.SafeModeAdministratorPassword.Add_PasswordChanged(
            {
                $Ctrl.CheckPassword()
            })
            
            # [TextBox] Dsrm Confirm (Event handler)
            $Ctrl.Xaml.IO.Confirm.Add_PasswordChanged(
            {
                $Ctrl.CheckPassword()
            })

            # // ==========
            # // | Bottom |
            # // ==========
            
            # [Button] Start (Event handler)
            $Ctrl.Xaml.IO.Start.Add_Click(
            {
                $Ctrl.Test = 0
                $Ctrl.Complete()
                $Ctrl.Xaml.IO.DialogResult = 1
            })

            # [Button] Test (Event handler)
            $Ctrl.Xaml.IO.Test.Add_Click(
            {
                $Ctrl.Test = 1
                $Ctrl.Complete()
                $Ctrl.Xaml.IO.DialogResult = 1
            })

            # [Button] Save (Event handler)
            $Ctrl.Xaml.IO.Save.Add_Click(
            {
                $Ctrl.Save()
            })

            $Ctrl.Xaml.IO.Load.Add_Click(
            {
                $Item                    = New-Object System.Windows.Forms.FolderBrowserDialog
                $Item.ShowDialog()
        
                If (!$Item.SelectedPath)
                {
                    $Item.SelectedPath                    = $Null
                    $Ctrl.Xaml.IO.InputPath.IsEnabled     = 0
                }
                Else
                {
                    $IO = $Ctrl.InputObjectController($Item.SelectedPath)
                    If (!!$IO.Profile)
                    {
                        $Ctrl.Xaml.IO.InputPath.IsEnabled = 1
                        $Ctrl.Xaml.IO.InputPath.Text      = $Item.SelectedPath
                    }
                    Else
                    {
                        $Item.SelectedPath                = $Null
                        $Ctrl.Xaml.IO.InputPath.IsEnabled = 0
                    }
                }
            })

            $Ctrl.SetForestMode($Ctrl.Server)
            $Ctrl.SetDomainMode($Ctrl.Server)

            $Ctrl.SetProfile(0)
        }
    }
#}

$Ctrl = [FEDCPromoController]::New(1)
$Ctrl.StageXaml()
$Ctrl.Xaml.Invoke()
