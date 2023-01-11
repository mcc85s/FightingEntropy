Function Get-FEDCPromo2
{
    [CmdLetBinding()]Param(
    [Parameter()][UInt32]$Mode=0,
    [Parameter()][String]$InputPath)

    # Check for server operating system
    If (Get-CimInstance Win32_OperatingSystem | ? Caption -notmatch Server)
    {
        Throw "Must use Windows Server operating system"
    }

    # (1/4) [Xaml.Property]
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

    # (2/4) [Xaml.Window]
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

    # (3/4) [Xaml.FEDCFound]
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

    # (4/4) [Xaml.FEDCPromo]
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
        '                    <Grid Grid.Row="6" Name="ParentDomainNameBox">',
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
        '                    <Grid Grid.Row="8" Name="ReplicationSourceDCBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1"',
        '                                  Content="Replication DC"',
        '                                  Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="2" Name="ReplicationSourceDC"/>',
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
        '                    <Grid   Grid.Row="2" Name="DomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
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
        '                    <Grid Grid.Row="3" Name="NewDomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
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
        '                    <Grid Grid.Row="4" Name="DomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
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
        '                    <Grid Grid.Row="5" Name="NewDomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
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
        '                    <Grid Grid.Row="6" Name="SiteNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
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

    # (1/1) [Input.Object.Controller]
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

    # (1/2) [Feature.Item]
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
    
    # (2/2) [Feature.Controller]
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

    # (1/3) [Windows.Server.Type]
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

    # (2/3) [Windows.Server.Item]
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

    # (3/3) [Windows.Server.List]
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

    Class ProfileItem
    {
        [UInt32]          $Index
        [String]           $Slot
        [UInt32]          $State
        [String]           $Name
        [String]           $Type
        [String]       $Property
        [Object]          $Value
        Hidden [Object] $Control
        [UInt32]          $Check
        [String]         $Reason
        ProfileItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Index    = $Index
            $This.Slot     = $Slot
            $This.Name     = $Name
            $This.Type     = $Control.GetType().Name
            $This.Property = Switch ($This.Type)
            {
                ComboBox    { "SelectedIndex" }
                TextBox     {          "Text" }
                CheckBox    {     "IsChecked" }
                PasswordBox {      "Password" }
            }
            
            $This.Control  = $Control
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

    Class ProfileController
    {
        [Int32]        $Index
        [String]        $Type
        [String]        $Name
        [String] $Description
        [Object]      $Output
        ProfileController([Object]$Xaml)
        {
            $This.Refresh($Xaml)
        }
        SetProfile([Object]$Command)
        {
            $This.Index =  $X = $Command.Index
            $This.Type        = $Command.Type
            $This.Name        = $Command.Name
            $This.Description = $Command.Description

            ForEach ($Item in $This.Output)
            {
                $Item.State   = Switch ($Item.Name)
                {
                    ForestMode                    { @(1,0,0,0)[$X] }
                    DomainMode                    { @(1,1,1,0)[$X] }
                    ReplicationSourceDc           { @(0,0,0,1)[$X] }
                    Sitename                      { @(0,1,1,1)[$X] }
                    InstallDns                    { @(1,1,1,1)[$X] }
                    CreateDnsDelegation           { @(1,1,1,1)[$X] }
                    CriticalReplicationOnly       { @(0,0,0,1)[$X] }
                    NoGlobalCatalog               { @(1,1,1,1)[$X] }
                    DatabasePath                  { @(1,1,1,1)[$X] }
                    SysvolPath                    { @(1,1,1,1)[$X] }
                    LogPath                       { @(1,1,1,1)[$X] }
                    ParentDomainName              { @(0,1,1,0)[$X] }
                    DomainName                    { @(1,0,0,1)[$X] }
                    DomainNetBiosName             { @(1,0,0,0)[$X] }
                    NewDomainName                 { @(0,1,1,0)[$X] }
                    NewDomainNetBiosName          { @(0,1,1,0)[$X] }
                    SafeModeAdministratorPassword { @(1,1,1,1)[$X] }
                    Confirm                       { @(1,1,1,1)[$X] }
                }

                $Item.Control.IsEnabled = $Item.State

                $Value = Switch ($Item.Slot)
                {
                    Mode 
                    {
                        0
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
                    Role
                    {
                        Switch ($Item.Name)
                        {
                            InstallDns                { @(1,1,1,1)[$X] }
                            CreateDnsDelegation       { @(0,0,1,0)[$X] }
                            CriticalReplicationOnly   { @(0,0,0,0)[$X] }
                            NoGlobalCatalog           { @(0,0,0,0)[$X] }
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
                    Pass
                    {
                        $Null
                    }
                }

                $Item.SetValue($Value)
            }
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh([Object]$Xaml)
        {
            $This.Clear()

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
        }
        [String] SystemRoot()
        {
            Return [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [Object] ProfileItem([UInt32]$Index,[String]$Slot,[String]$Name,[Object]$Control)
        {
            Return [ProfileItem]::New($Index,$Slot,$Name,$Control)
        }
        Add([String]$Slot,[String]$Name,[Object]$Control)
        {
            $This.Output += $This.ProfileItem($This.Output.Count,$Slot,$Name,$Control)
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfileController>"
        }
    }

    # (1/3) [Command.Type]
    Enum CommandType
    {
        Forest
        Tree
        Child
        Clone
    }

    # (1/2) [Domain.Type.Item]
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

    # (2/2) [Domain.Type.List]
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
    
    # (2/3) [Command.Type.Item]
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

    # (2/3) [Command.Type.List]
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

    # (3/3) [Command.Controller]
    Class CommandController
    {
        [String]       $Name
        [UInt32]       $Slot = 0
        [Object]    $Command
        [Object] $DomainType
        [Object] $ForestMode
        [Object] $DomainMode
        [Object]       $Xaml
        [Object]    $Profile
        CommandController()
        {
            $This.Name       = "CommandController"
            $This.Command    = $This.New("Command")
            $This.DomainType = $This.New("DomainType")
            $This.ForestMode = $This.New("ForestMode")
            $This.DomainMode = $This.New("DomainMode")
            $This.Xaml       = $This.New("Xaml")
            $This.Profile    = $This.New("Profile")
            $This.SetProfile($This.Slot)
        }
        Clear()
        {
            $This.Command    = $Null
            $This.DomainType = $Null
            $This.ForestMode = $Null
            $This.DomainMode = $Null
            $This.Profile    = $Null
        }
        Stage()
        {
            $This.Clear()

        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Command     {           [CommandTypeList]::New()             }
                DomainType  {            [DomainTypeList]::New()             }
                ForestMode  {         [WindowsServerList]::New("ForestMode") }
                DomainMode  {         [WindowsServerList]::New("DomainMode") }
                Xaml        { [XamlWindow][FEDCPromoXaml]::Content           }
                Profile     {         [ProfileController]::New($This.Xaml)   }
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
        SetProfile([UInt32]$Index)
        {
            $This.Slot                = $Index
            $This.Command.Selected    = $Index
            $This.DomainType.Selected = $Index

            $This.Profile.SetProfile($This.Command.Current())
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandController>"
        }
    }
}