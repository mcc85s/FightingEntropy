
    
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
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
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
        Static [String] $Content = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Found" Width="550" Height="260" HorizontalAlignment="Center" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="10"/>',
        '            <Setter Property="Padding" Value="10"/>',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="GroupBox">',
        '                        <Border CornerRadius="10" Background="White" BorderBrush="Black" BorderThickness="3">',
        '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="None" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox>',
        '            <Grid Margin="5">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="50"/>',
        '                </Grid.RowDefinitions>',
        '                <DataGrid Grid.Row="0" Grid.Column="0" Name="DomainControllers">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Address"  Width="140" Binding="{Binding IPAddress}"/>',
        '                        <DataGridTextColumn Header="Hostname" Width="200" Binding="{Binding HostName}"/>',
        '                        <DataGridTextColumn Header="NetBIOS"  Width="140" Binding="{Binding NetBIOS}"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="1">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Row="1" Grid.Column="0" Name="Ok"        Content="Ok" />',
        '                    <Button Grid.Row="1" Grid.Column="1" Content="Cancel" Name="Cancel"/>',
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
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Promotion" Width="550" Height="450" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '                            <Trigger Property="IsEnabled" Value="False">',
        '                                <Setter TargetName="Border" Property="Background" Value="#6F6F6F"/>',
        '                                <Setter Property="Foreground" Value="#9F9F9F"/>',
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
        '            ',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '            ',
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
        '            <Label Grid.Column="0" Content="[Command]:" HorizontalContentAlignment="Center"/>',
        '            <ComboBox Grid.Column="1" Name="CommandSlot">',
        '                <ComboBoxItem Content="Forest"/>',
        '                <ComboBoxItem Content="Tree"/>',
        '                <ComboBoxItem Content="Child"/>',
        '                <ComboBoxItem Content="Clone"/>',
        '            </ComboBox>',
        '            <DataGrid Grid.Column="2" Margin="10" Name="Command" HeadersVisibility="None">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="Description" Width="*" Binding="{Binding Description}"/>',
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
        '                    <DataGrid Grid.Row="0" Name="OperatingSystemCaption" HeadersVisibility="None">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Caption" Width="*" Binding="{Binding Caption}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <DataGrid Grid.Row="1" Name="OperatingSystemExtension">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Version"  Width="80"  Binding="{Binding Version}"/>',
        '                            <DataGridTextColumn Header="Build"    Width="50"  Binding="{Binding Build}"/>',
        '                            <DataGridTextColumn Header="Serial"   Width="*"   Binding="{Binding Serial}"/>',
        '                            <DataGridTextColumn Header="Language" Width="50"  Binding="{Binding Language}"/>',
        '                            <DataGridTextColumn Header="Product"  Width="50"  Binding="{Binding Product}"/>',
        '                            <DataGridTextColumn Header="Type"     Width="50"  Binding="{Binding Type}"/>',
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
        '                        <Label Grid.Column="1" Content="Forest Mode" Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="2" Name="ForestMode" SelectedIndex="0">',
        '                            <ComboBox.ItemTemplate>',
        '                                <DataTemplate>',
        '                                    <TextBlock Text="{Binding Index}" IsEnabled="{Binding Enabled}"/>',
        '                                </DataTemplate>',
        '                            </ComboBox.ItemTemplate>',
        '                        </ComboBox>',
        '                        <DataGrid Grid.Column="3" Name="ForestModeExtension" HeadersVisibility="None" Margin="10">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="100"/>',
        '                                <DataGridTextColumn Header="DisplayName" Binding="{Binding DisplayName}" Width="*"/>',
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
        '                        <Label Grid.Column="1" Content="Domain Mode" Style="{StaticResource LabelGray}"/>',
        '                        <ComboBox Grid.Column="2" Name="DomainMode" SelectedIndex="0">',
        '                            <ComboBox.ItemTemplate>',
        '                                <DataTemplate>',
        '                                    <TextBlock Text="{Binding Index}" IsEnabled="{Binding Enabled}"/>',
        '                                </DataTemplate>',
        '                            </ComboBox.ItemTemplate>',
        '                        </ComboBox>',
        '                        <DataGrid Grid.Column="3" Name="DomainModeExtension" HeadersVisibility="None" Margin="10">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="100"/>',
        '                                <DataGridTextColumn Header="DisplayName" Binding="{Binding DisplayName}" Width="*"/>',
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
        '                        <Label   Grid.Column="1" Content="Parent Domain" Style="{StaticResource LabelGray}"/>',
        '                        <Image   Grid.Column="2" Name="ParentDomainNameIcon"/>',
        '                        <TextBox Grid.Column="3" Name="ParentDomainName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="8" Name="ReplicationSourceDCBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1" Content="Replication DC" Style="{StaticResource LabelGray}"/>',
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
        '                    <Label    Grid.Row="0" Content="[Windows Server features to be installed]:"/>',
        '                    <DataGrid Grid.Row="1" Name="Feature">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Type" Width="60"  Binding="{Binding Type}" CanUserSort="True" IsReadOnly="True"/>',
        '                            <DataGridTextColumn Header="Name" Width="*" Binding="{Binding Name}" CanUserSort="True" IsReadOnly="True" FontWeight="Bold"/>',
        '                            <DataGridTemplateColumn Header="Install" Width="40">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <CheckBox IsEnabled="{Binding Enable}" IsChecked="{Binding Install}" Margin="0" Height="18" HorizontalAlignment="Left"/>',
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
        '                    <Label    Grid.Row="0" Content="[Domain controller roles]"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <CheckBox Grid.Column="1" Name="InstallDNS" />',
        '                        <Label    Grid.Column="2" Content="Install DNS" Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="3" Name="NoGlobalCatalog"/>',
        '                        <Label    Grid.Column="4" Content="No Global Catalog" Style="{StaticResource LabelRed}"/>',
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
        '                        <CheckBox Grid.Column="1" Name="CreateDNSDelegation"/>',
        '                        <Label    Grid.Column="2" Content="Create DNS Delegation" Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="3" Name="CriticalReplicationOnly"/>',
        '                        <Label    Grid.Column="4" Content="Critical Replication Only" Style="{StaticResource LabelRed}"/>',
        '                    </Grid>',
        '                    <Label    Grid.Row="3" Content="[Active Directory partition target paths (Click button to open dialog)]"/>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button   Grid.Column="1" Name="DatabaseBrowse" Content="Database"/>',
        '                        <TextBox  Grid.Column="2" Name="DatabasePath"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button   Grid.Column="1" Name="SysvolBrowse" Content="SysVol"/>',
        '                        <TextBox  Grid.Column="2" Name="SysvolPath"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button  Grid.Column="1" Name="LogBrowse" Content="Log"/>',
        '                        <TextBox Grid.Column="2" Name="LogPath"/>',
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
        '                    <Label  Grid.Row="0" Content="[Necessary fields vary by command selection]"/>',
        '                    <Grid   Grid.Row="2" Name="DomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1" Content="Domain" Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Column="2" Name="DomainNameIcon"/>',
        '                        <TextBox  Grid.Column="3" Name="DomainName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="3" Name="NewDomainNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="1" Content="New Domain" Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Column="2" Name="NewDomainNameIcon"/>',
        '                        <TextBox  Grid.Column="3" Name="NewDomainName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="4" Name="DomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Row="5" Grid.Column="1" Content="NetBIOS" Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Row="5" Grid.Column="2" Name="DomainNetBIOSNameIcon"/>',
        '                        <TextBox  Grid.Row="5" Grid.Column="3" Name="DomainNetBIOSName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5" Name="NewDomainNetBiosNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Row="6" Grid.Column="1" Content="New NetBIOS" Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Row="6" Grid.Column="2" Name="NewDomainNetBIOSNameIcon"/>',
        '                        <TextBox  Grid.Row="6" Grid.Column="3" Name="NewDomainNetBIOSName"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6" Name="SiteNameBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Row="8" Grid.Column="1" Content="Site Name" Style="{StaticResource LabelGray}"/>',
        '                        <Image    Grid.Row="8" Grid.Column="2" Name="SiteNameIcon"/>',
        '                        <ComboBox Grid.Row="8" Grid.Column="3" Name="SiteName"/>',
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
        '                    <Label  Grid.Row="0" Content="[Active Directory promotion credential]"/>',
        '                    <Grid   Grid.Row="2" Name="CredentialBox">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button  Grid.Column="1" Content="Credential" Name="CredentialButton"/>',
        '                        <Image   Grid.Column="2" Name="CredentialIcon"/>',
        '                        <TextBox Grid.Column="3" Name="Credential"/>',
        '                    </Grid>',
        '                    <Label Grid.Row="4" Content="[(DSRM/Domain Services Restore Mode) Key]"/>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label       Grid.Column="1" Content="Password" Style="{StaticResource LabelGray}"/>',
        '                        <Image       Grid.Column="2" Name="SafeModeAdministratorPasswordIcon"/>',
        '                        <PasswordBox Grid.Column="3" Name="SafeModeAdministratorPassword"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="7">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label       Grid.Column="1" Content="Confirm" Style="{StaticResource LabelGray}"/>',
        '                        <Image       Grid.Column="2" Name="ConfirmIcon"/>',
        '                        <PasswordBox Grid.Column="3" Name="Confirm"/>',
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
        '                            <DataGridTextColumn Header="Name"   Binding="{Binding Name}"   Width="100"/>',
        '                            <DataGridTextColumn Header="Type"   Binding="{Binding Type}"   Width="60"/>',
        '                            <DataGridTextColumn Header="Value"  Binding="{Binding Value}"  Width="100"/>',
        '                            <DataGridTextColumn Header="Reason" Binding="{Binding Reason}" Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button      Grid.Column="0" Name="Start" Content="Start"/>',
        '            <Button      Grid.Column="1" Name="Cancel" Content="Cancel"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
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

    # (1/10) [Profile.Slot.Type]
    Enum ProfileSlotType
    {
        ForestMode
        DomainMode
        ReplicationSourceDC
        SiteName
        ParentDomainName
        DomainName
        DomainNetBIOSName
        NewDomainName
        NewDomainNetBIOSName
    }

    # (2/10) [Profile.Slot.Item]
    Class ProfileSlotItem
    {
        [UInt32]      $Index
        [String]       $Name
        [String]       $Type
        [String]   $Property
        [UInt32]  $IsEnabled
        [Object]      $Value
        [UInt32]      $Check
        [String]     $Reason
        ProfileSlotItem([UInt32]$Index,[String]$Name,[Bool]$IsEnabled)
        {
            $This.Index     = $Index
            $This.Name      = $Name
            $This.Type      = @("TextBox","ComboBox"     )[[UInt32]($Index -in 0..3)]
            $This.Property  = @("Text"   ,"SelectedIndex")[[UInt32]($Index -in 0..3)]
            $This.IsEnabled = $IsEnabled
            $This.Check     = 0
        }
        Set([Object]$Value)
        {
            $This.Value     = $Value
        }
        Validate([String]$Reason)
        {
            If ($This.Type -eq "TextBox")
            {
                $This.Check  = [UInt32]($Reason -eq "[+] Passed")
                $This.Reason = $Reason
            }
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfileSlotItem>"
        }
    }

    # (3/10) [Profile.Slot.List]$
    Class ProfileSlotList
    {
        [UInt32]   $Mode
        [String]   $Name
        [Object] $Output
        ProfileSlotList([UInt32]$Mode)
        {
            $This.Mode   = $Mode
            $This.Name   = "Slot"
            $This.Stage()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Stage()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ProfileSlotType]))
            {
                $IsEnabled = @(Switch ($Name)
                {
                    ForestMode            {1,0,0,0}
                    DomainMode            {1,1,1,0}
                    ReplicationSourceDC   {0,0,0,1}
                    SiteName              {0,1,1,1}
                    ParentDomainName      {0,1,1,0}
                    DomainName            {1,0,0,1}
                    DomainNetBIOSName     {1,0,0,0}
                    NewDomainName         {0,1,1,0}
                    NewDomainNetBIOSName  {0,1,1,0}

                })[$This.Mode]

                $This.Add($Name,$IsEnabled)
            }
        }
        [Object] ProfileSlotItem([UInt32]$Index,[String]$Name,[UInt32]$IsEnabled)
        {
            Return [ProfileSlotItem]::New($Index,$Name,$IsEnabled)
        }
        [UInt32] Index([String]$Name)
        {
            Return [UInt32][ProfileSlotType]::$Name
        }
        Add([String]$Name,[UInt32]$IsEnabled)
        {
            $This.Output += $This.ProfileSlotItem($This.Output.Count,$Name,$IsEnabled)
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.ProfileSlotList>" -f $This.Output.Count
        }
    }

    # (4/10) [Profile.Role.Type]
    Enum ProfileRoleType
    {
        InstallDns
        CreateDnsDelegation
        CriticalReplicationOnly
        NoGlobalCatalog
    }

    # (5/10) [Profile.Role.Item]
    Class ProfileRoleItem
    {
        [UInt32]     $Index
        [String]      $Name
        [UInt32] $IsEnabled
        [UInt32] $IsChecked
        ProfileRoleItem([UInt32]$Index,[String]$Name,[Bool]$IsEnabled,[Bool]$IsChecked)
        {
            $This.Index     = $Index
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
            $This.IsChecked = $IsChecked
        }
        Check()
        {
            $This.IsChecked = Switch (!!$This.IsChecked) { 0 { 1 } 1 { 0 } }
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfileRoleItem>"
        }
    }

    # (6/10) [Profile.Role.List]
    Class ProfileRoleList
    {
        [UInt32]  $Mode
        [String]  $Name
        [Object] $Output
        ProfileRoleList([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Name = "Role"
            $This.Stage()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Stage()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ProfileRoleType]))
            {
                $Index = $This.Index($Name)
                $X     = Switch ($Name)
                {
                    InstallDNS              {(1,1,1,1),(1,1,1,1)}
                    CreateDNSDelegation     {(1,1,1,1),(0,0,1,0)}
                    NoGlobalCatalog         {(0,1,1,1),(0,0,0,0)}
                    CriticalReplicationOnly {(0,0,0,1),(0,0,0,0)}
                }

                $IsEnabled = $X[0][$This.Mode]
                $IsChecked = $X[1][$This.Mode]
    
                $This.Add($Index,$Name,$IsEnabled,$IsChecked)
            }
        }
        [Object] ProfileRoleItem([UInt32]$Index,[String]$Name,[UInt32]$IsEnabled,[UInt32]$IsChecked)
        {
            Return [ProfileRoleItem]::New($Index,$Name,$IsEnabled,$IsChecked)
        }
        [UInt32] Index([String]$Name)
        {
            Return [UInt32][ProfileRoleType]::$Name
        }
        Add([UInt32]$Index,[String]$Name,[UInt32]$IsEnabled,[UInt32]$IsChecked)
        {
            $This.Output += $This.ProfileRoleItem($Index,$Name,$IsEnabled,$IsChecked)
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.ProfileRoleList>" -f $This.Output.Count
        }
    }

    # (7/10) [Profile.Password.Type]
    Enum ProfilePasswordType
    {
        Password
        Confirm
    }

    # (8/10) [Profile.Password.Item]
    Class ProfilePasswordItem
    {
        [UInt32]  $Index
        [String]   $Name
        [Object]  $Value
        [UInt32]  $Check
        [String] $Reason
        ProfilePasswordItem([UInt32]$Index,[String]$Name)
        {
            $This.Index = $Index
            $This.Name  = $Name
        }
        Validate([String]$Reason)
        {
            $This.Check  = [UInt32]($Reason -eq "[+] Passed")
            $This.Reason = $Reason
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfilePasswordItem>"
        }
    }

    # (9/10) [Profile.Password.List]
    Class ProfilePasswordList
    {
        [UInt32]   $Mode
        [String]   $Name
        [Object] $Output
        ProfilePasswordList([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Name = "Password"
            $This.Stage()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Stage()
        {
            $This.Clear()

            ForEach ($Type in [System.Enum]::GetNames([ProfilePasswordType]))
            {
                $Index = $This.Index($Type)
                $This.Add($Index,$Type)
            }
        }
        [Object] ProfilePasswordItem([UInt32]$Index,[String]$Name)
        {
            Return [ProfilePasswordItem]::New($Index,$Name)
        }
        [UInt32] Index([String]$Name)
        {
            Return [UInt32][ProfilePasswordType]::$Name
        }
        Add([UInt32]$Index,[String]$Name)
        {
            $This.Output += $This.ProfilePasswordItem($Index,$Name)
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.ProfilePasswordList>" -f $This.Output.Count
        }
    }

    # (10/10) [Profile.Controller]
    Class ProfileController
    {
        [UInt32]       $Index
        [String]        $Name
        [String]        $Type
        [String] $Description
        [Object]        $Slot
        [Object]        $Role
        [Object]        $DSRM
        ProfileController([Object]$Command)
        {
            If ($Command.Index -notin 0,1,2,3)
            {
                Throw "Invalid Entry"
            }

            $This.Index       = $Command.Index
            $This.Name        = $Command.Name
            $This.Type        = $Command.Type
            $This.Description = $Command.Description
            $This.Slot        = $This.New("Slot")
            $This.Role        = $This.New("Role")
            $This.Dsrm        = $This.New("DSRM")

            $This.SlotDefault()
        }
        SlotDefault()
        {
            ForEach ($Item in $This.Slot.Output)
            {
                $Item.Value = Switch ($Item.Name)
                {
                    ForestMode           { 0 }
                    DomainMode           { 0 }
                    ReplicationSourceDC  { 0 }
                    SiteName             { 0 }
                    ParentDomainName     { "<Enter Domain Name> or <Credential>"  }
                    DomainName           { "<Enter Domain Name> or <Credential>"  }
                    DomainNetBIOSName    { "<Enter NetBIOS Name> or <Credential>" }
                    NewDomainName        { "<Enter New Domain Name>"              }
                    NewDomainNetBIOSName { "<Enter New NetBIOS Name>"             }
                }
            }
        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Slot {     [ProfileSlotList]::New($This.Index) }
                Role {     [ProfileRoleList]::New($This.Index) }
                Dsrm { [ProfilePasswordList]::New($This.Index) }
            }

            Return $Item
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Slot { $This.Slot }
                Role { $This.Role }
                Dsrm { $This.Dsrm }
            }

            Return $Item
        }
        [Object] List([String]$Name)
        {
            Return $This.Get($Name).Output
        }
        [String] ToString()
        {
            Return "<FEDCPromo.ProfileController[{0}]>" -f $This.Type
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
                $X     = Switch ($Type)
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
        [Object]    $Profile
        CommandController()
        {
            $This.Name    = "CommandController"
            $This.Stage()
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
        [Object] List([String]$Name)
        {
            Return $This.Get($Name).Output
        }
        [Object] ProfileController([Object]$Object)
        {
            Return [ProfileController]::New($Object)
        }
        [Object] Current([String]$Name)
        {
            Return $This.Get($Name).Current()
        }
        SetProfile([UInt32]$Index)
        {
            $This.Slot                = $Index
            $This.Command.Selected    = $Index
            $This.DomainType.Selected = $Index
            $This.Profile             = $This.ProfileController($This.Current("Command"))
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandController>"
        }
    }

    Class Execution
    {
        [Object] $Services
        [Object]   $Result
        [Object]   $Output
        Execution()
        {
            $This.Services = @( )
            $This.Result   = @( )
            $This.Output   = @{ }
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

    # (2/2) [Feature.List]
    Class FeatureList
    {
        [String]     $Name
        [Object]   $Output
        FeatureList()
        {
            $This.Name       = "Features"
            $This.Clear()
            $This.Stage()
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
    }

    # (1/1) [Connection]
    Class Connection
    {
        [String]        $IPAddress
        [String]          $DNSName
        [String]           $Domain
        [String]          $NetBIOS
        [PSCredential] $Credential
        Hidden [String]      $Site
        [String[]]       $Sitename
        [String[]]  $ReplicationDC
        Connection([Object]$Login)
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

            ForEach ($Item in $This.Reserved())
            {
                $This.Add("Reserved",$Item)
            }

            ForEach ($Item in $This.Legacy())
            {
                $This.Add("Legacy",$Item)
            }

            ForEach ($Item in $This.SecurityDescriptor())
            {
                $This.Add("SecurityDescriptor",$Item)
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
        [String[]] Reserved()
        {
            $Out = "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GRO"+
            "UP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;DIALUP;DIGEST AUTH;INTERACTIVE"+
            ";INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN"+
            ";NTLM AUTH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERV"+
            "ER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZATION;USERS;WORLD"
            
            Return $Out -Split ";"
        }
        [String[]] Legacy()
        {
            Return "-GATEWAY","-GW","-TAC"
        }
        [String[]] SecurityDescriptor()
        {
            $Out = "AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS"+
            ",LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS,RU,SA,SI,SO,SU,SY,WD"
            
            Return $Out -Split ','
        }
        [String] Password()
        {
            Return "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
        }
        [String] ToString()
        {
            Return "({0}) <FEDCPromo.ValidationController>"
        }
    }

    Class FEDCPromoController
    {
        [Object]             $Console
        [UInt32]                $Mode
        [UInt32]             $Staging
        [Object]              $Module
        [Object]              $System
        [Object]             $Network
        [String]             $Caption
        [UInt32]              $Server
        [Object]             $Feature
        [Object]             $Control
        [Object]          $Validation
        Hidden [Object]      $Summary
        [Object]                $Xaml
        [Object]          $Connection
        Hidden [Object]   $Credential
        FEDCPromoController()
        {
            $This.Mode     = 0
            $This.Main()
        }
        FEDCPromoController([UInt32]$Mode)
        {
            $This.Mode     = $Mode
            $This.Main()
        }
        Main()
        {
            # Initialize console
            $This.StartConsole()

            # Load features
            $This.Feature  = $This.New("FEFeatureList")
            
            # Validate Adds installation
            $This.ValidateAdds()

            # Import Adds Module
            $This.ImportAdds()

            # Primary components
            $This.Module   = $This.New("FEModule")
            $This.System   = $This.New("FESystem")
            $This.Network  = $This.New("FENetwork")

            # Validate connectivity, and whether DHCP is set
            $Check         = $This.System.Network.Output | ? Status
            Switch ($Check.Count)
            {
                0
                {
                    Write-Theme "Error [!] No network detected" 1
                    Break
                }
                1
                {
                    If ($Check[0].DhcpServer -notmatch "(\d+\.){3}\d+")
                    {
                        $This.Update(0,"Warning [!] Static IP Address not set")
                    }
                }
                Default
                {
                    If ($Check.DhcpServer -notmatch "(\d+\.){3}\d+")
                    {
                        $This.Update(0,"Warning [!] Static IP Address not set")
                    }
                }
            }

            # Check if system is a virtual machine
            If ($This.System.ComputerSystem.Model -match "Virtual")
            {
                ForEach ($Item in $This.Features | ? Type -eq Veridian)
                {
                    $Item.Enable = 0 
                }
            }

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
                Write-Error "<This operating system may be too old to support this function>"
            }

            # Get Command/Profile controller
            $This.Control       = $This.New("CommandController")

            # Stage command (Forest/Domain) modes
            $This.Control.Get("ForestMode").SetMin($This.Server)
            $This.Control.Get("DomainMode").SetMin($This.Server)

            # Get validation controller
            $This.Validation    = $This.New("ValidationController")

            # Load Xaml
            $This.Xaml          = $This.New("FEDCPromoXaml")

            # Continue with [Xaml]
            $This.StageXaml()
        }
        StartConsole()
        {
            $This.Console = New-FEConsole
            $This.Console.Initialize()
            $This.Status()
        }
        [Void] Status()
        {
            If ($This.Mode -gt 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        [Void] Update([Int32]$State,[String]$Status)
        {
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        ValidateAdds()
        {
            $This.Update(0,"Validating [~] Module: [AddsDeployment]")
            $Adds               = $This.Features | ? Name -eq AD-Domain-Services
            If ($Adds.Installed -eq 0)
            {
                $This.Update(0,"Processing [~] Installing: [AddsDeployment]")
                Write-Theme $This.Status()

                $This.InstallAdds()

                If (!(Get-Module AddsDeployment))
                {
                    $This.Update(-1,"Failed [!] Installing: [AddsDeployment]")
                    Throw $This.Console.Last()
                }
                Else
                {
                    $This.Update(1,"Success [+] Installed: [AddsDeployment]")
                }
            }
        }
        InstallAdds()
        {
            $This.Update(0,"Processing [~] Installing: [Ad-Domain-Services]")
            Install-WindowsFeature Ad-Domain-Services -Confirm:$False
        }
        ImportAdds()
        {
            $This.Update(0,"Importing [~] Module: [AddsDeployment]")
            Import-Module AddsDeployment
        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                FEModule             { Get-FEModule -Mode 1                 }
                FESystem             { Get-FESystem -Mode 0 -Level 3        }
                FENetwork            { Get-FENetwork -Mode 7                }
                FEADLogin            { Get-FEADLogin                        }
                FEFeatureList        { [FeatureList]::New()                 }
                FEDCPromoXaml        { [XamlWindow][FEDCPromoXaml]::Content }
                FEDCFoundXaml        { [XamlWindow][FEDCFoundXaml]::Content }
                CommandController    { [CommandController]::New()           }
                ValidationController { [ValidationController]::New()        }
            }

            Switch ([UInt32]!!$Item)
            {
                0 { $This.Update(-1,"Failed [!] [$Name]") }
                1 { $This.Update( 1,"Loaded [+] [$Name]") }
            }

            Return $Item
        }
        [Object] GetConnection([Object]$Connect)
        {
            Return [Connection]::New($Connect)
        }
        [Object] Slot([String]$Name)
        {
            Return $This.Control.Profile.Slot.Output | ? Name -eq $Name
        }
        [Object] Role([String]$Name)
        {
            Return $This.Control.Profile.Role.Output | ? Name -eq $Name
        }
        [Object] Dsrm([String]$Name)
        {
            Return $This.Control.Profile.Dsrm.Output | ? Name -eq $Name
        }
        [String] SystemRoot()
        {
            Return [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [String] Icon([UInt32]$Type)
        {
            Return $This.Module._Control(@("failure.png","success.png")[$Type]).Fullname
        }
        [Object] Validate([String]$Type)
        {
            Return $This.Validation.Output | ? Type -eq $Type | % Value
        }
        [Object] Reserved()
        {
            Return $This.Validate("Reserved")
        }
        [Object] Legacy()
        {
            Return $This.Validate("Reserved")
        }
        [Object] SecurityDescriptor()
        {
            Return $This.Validate("Reserved")
        }
        [String] DefaultText([String]$Name)
        {
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
        [String] DefaultPath([String]$Name)
        {
            $Item = Switch ($Name)
            {
                DataBasePath { "{0}\NTDS"    }
                SysVolPath   { "{0}\SYSVOL"  }
                LogPath      { "{0}\NTDS"    }
            }

            Return $Item -f $This.SystemRoot()
        }
        Browse([String]$Name)
        {
            If ($Name -notin "DatabasePath","SysvolPath","Logpath")
            {
                Throw "Invalid item"
            }

            $Item                    = New-Object System.Windows.Forms.FolderBrowserDialog
            $Item.ShowDialog()
        
            If (!$Item.SelectedPath)
            {
                $Item.SelectedPath   = $This.DefaultPath($Name)
            }
            
            $This.Xaml.IO.$Name.Text = $Item.SelectedPath
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            If ($This.Mode -gt 0)
            {
                $Line = "Xaml.IO.{0} [{1}]" -f $xSender.Name, $xSender.GetType().Name
                $This.Update(0,"Resetting [~] $Line")
            }

            $xSender.Items.Clear()
            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        XamlDefault([String]$Section)
        {
            $This.Update(0,"Setting [~] Defaults: [$Section]")
            Switch ($Section)
            {
                ComboBox
                {
                    $This.Xaml.IO.ForestMode.IsEnabled          = 0
                    $This.Xaml.IO.DomainMode.IsEnabled          = 0
                    $This.Xaml.IO.ReplicationSourceDc.IsEnabled = 0
                    $This.Xaml.IO.SiteName.IsEnabled            = 0
                }
                Role
                {
                    $This.Xaml.IO.InstallDNS.IsEnabled                    = 0
                    $This.Xaml.IO.CreateDNSDelegation.IsEnabled           = 0
                    $This.Xaml.IO.NoGlobalCatalog.IsEnabled               = 0
                    $This.Xaml.IO.CriticalReplicationOnly.IsEnabled       = 0
                }
                Credential
                {
                    $This.Xaml.IO.Credential.IsEnabled                    = 0
                    $This.Xaml.IO.SafeModeAdministratorPassword.IsEnabled = 0
                    $This.Xaml.IO.Confirm.IsEnabled                       = 0
                }
                Name
                {
                    $This.Xaml.IO.DomainName.IsEnabled                    = 0
                    $This.Xaml.IO.NewDomainName.IsEnabled                 = 0
                    $This.Xaml.IO.DomainNetBIOSName.IsEnabled             = 0
                    $This.Xaml.IO.NewDomainNetBIOSName.IsEnabled          = 0
                    $This.Xaml.IO.SiteName.IsEnabled                      = 0
                }
                Path
                {
                    $This.Xaml.IO.DataBasePath.Text  = "{0}\NTDS"   -f $This.SystemRoot()
                    $This.Xaml.IO.SysVolPath.Text    = "{0}\SYSVOL" -f $This.SystemRoot()
                    $This.Xaml.IO.LogPath.Text       = "{0}\NTDS"   -f $This.SystemRoot()
                }
                Button
                {
                    $This.Xaml.IO.Start.IsEnabled                         = 0
                    $This.Xaml.IO.CredentialButton.IsEnabled              = 0
                }
            }
        }
        SetInputObject([Object]$In)
        {
            $This.SetMode($In.Mode)
            Switch ($In.Mode)
            {
                Default {}
                3
                {
                    $Admin                               = "SafeModeAdministratorPassword"
                    $This.Credential                     = $In.Credential
                    $This.Xaml.IO.Credential.Text        = $In.Credential.Username

                    $This.Reset($This.Xaml.IO.SiteName,$In.Sitename)
                    
                    $This.Xaml.IO.SiteName.SelectedIndex = 0
                    $This.Xaml.IO.DomainName.Text        = $In.DomainName
                    $This.Xaml.IO.$Admin.Password        = $In.$Admin.GetNetworkCredential().Password
                    $This.Xaml.IO.Confirm.Password       = $In.$Admin.GetNetworkCredential().Password
                }
            }
        }
        ToggleRole([String]$Name)
        {
            $Item               = $This.Role($Name)

            If ($Item.IsEnabled)
            {
                $Role           = $This.Xaml.IO.$Name
                If ($Role.IsChecked -and !$Item.IsChecked)
                {
                    $This.Update(0,"Checking [~] [$Name]")
                    $Item.IsChecked = 1
                }
                ElseIf (!$Role.IsChecked -and $Item.IsChecked)
                {
                    $This.Update(0,"Unchecking [~] [$Name]")
                    $Item.IsChecked = 0
                }
            }
        }
        ToggleStaging()
        {
            Switch ($This.Staging)
            {
                0
                {
                    $This.Update(0,"Enabling [~] Staging mode")
                    $This.Staging = 1
                }
                1
                {
                    $This.Update(0,"Disabling [~} Staging mode")
                    $This.Staging = 0
                }
            }
        }
        SetProfile([UInt32]$Index)
        {
            $This.Update(0,"Changed [+] Selection [$Index]")
            $This.Control.SetProfile($Index)

            # Enabled staging mode [prevents event handler spamming]
            $This.ToggleStaging()

            # DomainType
            $This.SetDomainType()

            # Credential
            $This.SetCredential()

            # Features
            $This.SetFeatures()

            # Roles
            $This.SetRoles()

            # Slots
            $This.SetSlots()

            # Connection
            $This.SetConnection()

            # Administrator password entry
            $This.SetAdminPassword()

            # Disable staging mode
            $This.ToggleStaging()
        }
        SetMode()
        {
            $This.Update(0,"Setting [~] (Forest/Domain) modes")
            $This.Slot("ForestMode").Value = $This.Control.Get("ForestMode").Selected
            $This.Slot("DomainMode").Value = $This.Control.Get("DomainMode").Selected
        }
        SetDomainType()
        {
            $This.Update(0,"Setting [~] DomainType")
            $This.Control.Get("DomainType").Selected = $This.Control.Slot
        }
        SetCredential()
        {
            $This.Update(0,"Setting [~] Credential button")
            $This.Xaml.IO.CredentialButton.IsEnabled = $This.Control.Slot -ne 0
            $This.Xaml.IO.CredentialBox.IsEnabled    = $This.Control.Slot -ne 0
        }
        SetFeatures()
        {
            $This.Update(0,"Settings [~] Features")
        }
        SetRoles()
        {
            $This.Update(0,"Setting [~] Roles")
            ForEach ($Role in $This.Control.Profile.List("Role"))
            {
                $Name           = $Role.Name
                $This.Update(0,"Setting role: [$Name]")

                $Item           = $This.Xaml.IO.$Name
                $Item.IsEnabled = $Role.IsEnabled
                $Item.IsChecked = $Role.IsChecked

                $This.ToggleRole($Name)
            }
        }
        SetSlots()
        {
            $This.Update(0,"Setting [~] Profile slot")
            ForEach ($Type in "ComboBox","TextBox")
            {
                ForEach ($Item in $This.Control.Profile.List("Slot") | ? Type -eq $Type)
                {
                    $Name               = $Item.Name
                    $Object             = $This.Xaml.IO.$Name
                    $Box                = $This.Xaml.IO."$Name`Box"
                    $Rank               = $Item.IsEnabled
                    $Mark               = @(" ","X")[$Rank]

                    $This.Update(0,"Setting [~] Profile [$Mark], Slot: [$Name], Type: [$Type]")

                    $Object.Visibility  = @("Collapsed","Visible")[$Rank]
                    $Object.IsEnabled   = $Rank
                    $Box.Visibility     = @("Collapsed","Visible")[$Rank]
                    $Box.IsEnabled      = $Rank

                    Switch ($Type)
                    {
                        ComboBox 
                        { 
                            $Item.Value = @(0,$This.Server)[$Item.Name -match "Mode"] 
                        }
                        TextBox  
                        { 
                            $Item.Value = @("",$Item.Value)[$Item.IsEnabled] 
                        }
                    }

                    If ($Type -eq "ComboBox")
                    {
                        If ($Item.IsEnabled)
                        {
                            $Object.SelectedIndex = @($Item.Value,$This.Server)[$Name -match "Mode"]
                            $Object.IsEnabled     = 1
                        }
                        Else
                        {
                            $Object.SelectedIndex = 0
                        }
                    }
                    If ($Type -eq "TextBox")
                    {
                        $Icon                              = "{0}Icon" -f $Name

                        If ($Item.IsEnabled)
                        {
                            $Object.Text                  = $Item.Value
                            $Object.IsEnabled             = 1
    
                            $This.Xaml.IO.$Icon.Visibility = "Visible"
                        }
                        Else
                        {
                            If ($Object.Text)
                            {
                                $Object.Text              = ""
                            }

                            $Icon                          = "{0}Icon" -f $Name
                            $This.Xaml.IO.$Icon.Visibility = "Collapsed"
                            $This.Xaml.IO.$Icon.Source     = $Null
                        }
                    }
                }
            }
        }
        SetConnection()
        {
            $This.Update(0,"Setting [~] Connection")
            If ($This.Connection)
            {
                $This.Update(0,"Detected [+] Connction")
                Switch ($This.Control.Slot)
                {
                    0
                    {
                        $This.Connection = $Null
                    }

                    1
                    {
                        $This.Slot("ParentDomainName" ).Value = $This.Connection.Domain
                        $This.Slot("DomainNetBIOSName").Value = $This.Connection.NetBIOS
                    }

                    2
                    {
                        $This.Slot("ParentDomainName" ).Value = $This.Connection.Domain
                        $This.Slot("DomainNetBIOSName").Value = $This.Connection.NetBIOS
                    }

                    3
                    {
                        $This.Slot("DomainName"       ).Value = $This.Connection.Domain
                        $This.Slot("DomainNetBIOSName").Value = $This.Connection.NetBIOS
                    }
                }
            }

            # Connection Objects [Credential, Sitename, and ReplicationDCs]
            If ($This.Control.Slot -eq 0)
            {
                $This.Update(0,"Clearing [~] Credential")
                $This.Xaml.IO.Credential.Text                       = ""
                $This.Xaml.IO.CredentialButton.IsEnabled            = 0
                $This.Credential                                    = $Null
            }

            If ($This.Control.Slot -ne 0 -and $This.Connection)
            {
                $This.Update(0,"Selecting [~] Credential")
                $This.Xaml.IO.Credential.Text                       = $This.Connection.Credential.Username
                $This.Credential                                    = $This.Connection.Credential
                $This.Xaml.IO.CredentialButton.IsEnabled            = 1

                $Item = Switch ($This.Connection.Sitename.Count)
                {
                    0 { "-" } Default { $This.Connection.Sitename }
                }

                $This.Reset($This.Xaml.IO.SiteName,$Item)

                $Item = Switch ($This.Connection.ReplicationSourceDC.Count)
                {
                    0 { "<Any>" } Default { @($This.Connection.ReplicationDC;"<Any>") }
                }

                $This.Reset($This.Xaml.IO.ReplicationSourceDC,$Item)

                $This.Xaml.IO.Sitename.SelectedIndex                = 0
                $This.Xaml.IO.ReplicationSourceDC.SelectedIndex     = 0
            }
        }
        SetAdminPassword()
        {
            $This.Update(0,"Setting [~] DSRM password")
            $This.Xaml.IO.SafeModeAdministratorPassword.IsEnabled   = 1
            $This.Xaml.IO.Confirm.IsEnabled                         = 1
        }
        Login()
        {
            $This.Update(0,"Initializing [~] Ad login")
            $This.Connection         = $Null
            $Dcs                     = $This.Network.NBT.Output
                                     # $Ctrl.Network.Compartment.Output[0].Extension.Nbt.Output.Output | FT
                                     # $This.Network.Nbt.Output | ? {$_.Output.Id -match "(1B|1C)" }
                                     # $This.Network.Compartment
            Switch ([UInt32]!!$Dcs)
            {
                0
                {
                    $Connect         = $This.Get("FEADLogin")
                    $This.Connection = Switch ([UInt32]!!$Connect.Test.DistinguishedName)
                    {
                        0 
                        { 
                            $This.Update(-1,"Failed [!] Ad login")
                            $Null 
                        }
                        1 
                        {
                            $This.Update(1,"Success [+] Ad login")
                            $This.GetConnection($Connect) 
                        }
                    }
                }
                1
                {
                    $DC              = $This.Get("FDCFoundXaml")

                    $This.Reset($DC.IO.DomainControllers,$DCs)
                    $DC.IO.DomainControllers.Add_SelectionChanged(
                    {
                        If ($DC.IO.DomainControllers.SelectedIndex -ne -1)
                        {
                            $DC.IO.Ok.IsEnabled = 1
                        }
                    })
    
                    $DC.IO.Ok.IsEnabled     = 0
                    $DC.IO.Cancel.Add_Click(
                    {
                        $DC.IO.DialogResult = 0
                    })
    
                    $DC.IO.Ok.Add_Click(
                    {
                        $DC.IO.DialogResult = 1
                    })
    
                    $DC.Invoke()
    
                    Switch ($DC.IO.DialogResult)
                    {
                        0
                        {
                            $This.Update(-1,"Exception [!] Ad login: (user cancelled/dialog failed)")
                        }
                        1
                        {
                            $This.Update(-1,"Attempting [~] Ad login: testing supplied credentials")
                            $Connect = Get-FEADLogin -Target $DC.IO.DomainControllers.SelectedItem
                            Switch ([UInt32]!!$Connect.Test.DistinguishedName)
                            {
                                0
                                {
                                    $This.Update(-1,"Failed [!] Ad login: credential error")
                                    $This.Connection = $Null
                                }
                                1
                                {
                                    $This.Update(1,"Success [+] Ad login: credential good")
                                    $This.Connection = $This.GetConnection($Connect)
                                    $This.Connection.AddReplicationDCs($DCs)
                                }
                            }
                        }
                    }
                }
            }

            $This.SetProfile($This.Control.Slot)
        }
        Check([String]$Name)
        {
            $Item = $This.Slot($Name)
            $This.Check($Item)
        }
        Check([Object]$Item)
        {
            If (!$Item)
            {
                Throw "Null entry"
            }

            $Name = $Item.Name
            $Icon = "{0}Icon" -f $Name

            If (!$This.Staging)
            {
                If ($Item.IsEnabled)
                {
                    $This.Update(0,"Checking [~] Field: [$Name]")

                    $Item.Value                 = $This.Xaml.IO.$Name.Text

                    Switch ($Name)
                    {
                        {$_ -in "ParentDomainName","DomainName"}
                        { 
                            $This.CheckItem("Domain",$Item) 
                        }
                        {$_ -in "DomainNetBIOSName","NewDomainNetBIOSName"}
                        {
                            $This.CheckItem("NetBIOS",$Item)
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

                    $This.Xaml.IO.$Name.Visibility = "Visible"
                    $This.Xaml.IO.$Icon.Source     = $This.Icon($Item.Check)
                    $This.Xaml.IO.$Icon.Tooltip    = $Item.Reason
                    $This.Xaml.IO.$Icon.Visibility = "Visible"
                }

                If (!$Item.IsEnabled)
                {
                    $This.Xaml.IO.$Name.Visibility = "Collapsed"
                    $This.Xaml.IO.$Icon.Source     = $Null
                    $This.Xaml.IO.$Icon.Tooltip    = $Null
                    $This.Xaml.IO.$Icon.Visibility = "Collapsed"
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
                    If ($Item.Value -match [Regex]::Escape($This.Xaml.IO.ParentDomainName.Text))
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
                        $X = "[!] First/Last Character cannot be a '.' or '-'"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
                Child
                {
                    If ($Item.Value -notmatch ".$($This.Xaml.IO.ParentDomainName.Text)")
                    {
                        $X = "[!] Must be a (child/host) of the parent"
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
                        $X = "[!] First/Last Character cannot be a '.' or '-'"
                    }
                    Else
                    {
                        $X = "[+] Passed"
                    }
                }
            }

            $Item.Validate($X)
            Switch ([UInt32]!!$Item.Check)
            {
                0 { $This.Update(-1, "Failed $($Item.Reason)") }
                1 { $This.Update( 1,"Success $($Item.Reason)") }
            }
        }
        CheckDSRMPassword()
        {
            $Pattern  = $This.Validation.Password()
            $Password = $This.DSRM("Password")

            If ($Password.Value -notmatch $Pattern)
            {
                $Password.Validate("[!] 10 chars, and at least: (1) Uppercase, (1) Lowercase, (1) Special, (1) Number")
            }
            ElseIf ($Password.Value -match $Pattern)
            {
                $Password.Validate("[+] Passed")
            }
        }
        CheckDSRMConfirm()
        {
            $This.CheckDSRMPassword()
            $Password = $This.DSRM("Password")
            $Confirm  = $This.DSRM("Confirm")

            If ($Confirm.Value -ne $Password.Value)
            {
                $Confirm.Validate("[!] Confirmation error")
            }
            ElseIf ($Confirm.Value -eq $Password.Value -and $Password.Check -eq 1)
            {
                $Confirm.Validate("[+] Passed")
            }
        }
        Total()
        {
            $xSlot = $This.Control.Profile.List("Slot") | ? IsEnabled | ? Property -eq Text | ? Check 
            $xPass = $This.Control.Profile.List("DSRM") | ? Check

            $This.Xaml.IO.Start.IsEnabled = $xSlot.Count -ne 0 -and $xPass.Count -ne 0
        }
        Complete()
        {
            $Item               = $This.Slot("ForestMode")
            If ($Item.IsEnabled)
            {
                $Index          = $This.Xaml.IO.ForestMode.SelectedIndex
                $Item.Value     = @($Index,"WinThreshold")[$Index -ge 6]
            }

            $Item               = $This.Slot("DomainMode")
            If ($Item.IsEnabled)
            {
                $Index          = $This.Xaml.IO.DomainMode.SelectedIndex
                $Item.Value     = @($Index,"WinThreshold")[$Index -ge 6]
            }

            $Item               = $This.Slot("ReplicationSourceDC")
            If ($Item.IsEnabled)
            {
                $Item.Value     = $This.Xaml.IO.ReplicationSourceDC.SelectedItem
            }

            $Item               = $This.Slot("SiteName")
            If ($Item.IsEnabled)
            {
                $Item.Value     = $This.Xaml.IO.Sitename.SelectedItem
            }

            ForEach ($Item in $This.Control.Profile.List("Role"))
            {
                $Name           = $Item.Name
                $Item.IsChecked = $Item.IsEnabled -and $This.Xaml.IO.$Name.IsChecked
            }

            If ($This.Control.Slot -eq 2)
            {
                $Item           = $This.Slot("NewDomainName")
                $Item.Value     = $Item.Value.Replace($This.Connection.Domain,"").TrimEnd(".")
            }

            $Item               = $This.DSRM("Password")
            $Item.Value         = $Item.Value | ConvertTo-SecureString -AsPlainText -Force

            ForEach ($Item in $This.Control.Profile.List("Role"))
            {
                $This.ToggleRole($Item.Name)
            }
        }
        StageXaml()
        {
            $Ctrl          = $This

            # [ComboBox] Command slot 
            $Ctrl.Reset($Ctrl.Xaml.IO.CommandSlot,$Ctrl.Control.Command.Output.Type)

            # [ComboBox] Command slot (Event handler)
            $Ctrl.Xaml.IO.CommandSlot.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.CommandSlot.SelectedIndex
                $Ctrl.SetProfile($Index)
                $Ctrl.Reset($Ctrl.Xaml.IO.Command,$Ctrl.Control.Profile)
            })

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
                $Ctrl.Reset($Ctrl.Xaml.IO.ForestModeExtension,$Ctrl.Control.Current("ForestMode"))
            })

            # [ComboBox] Forest Mode (Default)
            $Ctrl.Xaml.IO.ForestMode.SelectedIndex = ($Ctrl.Control.ForestMode.Output | ? Enable)[0].Index

            # [ComboBox] Domain mode
            $Ctrl.Reset($Ctrl.Xaml.IO.DomainMode,$Ctrl.Control.DomainMode.Output)

            # [ComboBox -> Ctrl.Control -> Datagrid] Domain mode (Event handler)
            $Ctrl.Xaml.IO.DomainMode.Add_SelectionChanged(
            {
                $Ctrl.Control.DomainMode.Selected = $Ctrl.Xaml.IO.DomainMode.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.DomainModeExtension,$Ctrl.Control.Current("DomainMode"))
            })

            # [ComboBox] Domain mode (Default)
            $Ctrl.Xaml.IO.DomainMode.SelectedIndex = ($Ctrl.Control.DomainMode.Output | ? Enable)[0].Index

            # [ComboBox] Replication Source DC
            $Ctrl.Reset($Ctrl.Xaml.IO.ReplicationSourceDC,$Null)

            # [DataGrid] Windows Features
            $Ctrl.Reset($Ctrl.Xaml.IO.Feature,$Ctrl.Feature.Output)

            # [CheckBox[]] Roles
            $Ctrl.XamlDefault("Role")

            # [CheckBox] Install Dns (Event handler)
            # [CheckBox] Create Dns Delegation (Event handler)
            # [CheckBox] No Global Catalog (Event handler)
            # [CheckBox] Critical Replication Only (Event handler)

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

            # [TextBox[]] DatabasePath, SysvolPath, Logpath
            $Ctrl.XamlDefault("Path")

            # [TextBox[]] Domain Names
            $Ctrl.XamlDefault("Name")

            # [Button -> TextBox] Credential
            $Ctrl.XamlDefault("Credential")

            # [Button[]] Start, Cancel
            $Ctrl.XamlDefault("Button")

            # =(1/5)============================================================
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
                    $Ctrl.Xaml.IO.ParentDomainName.Text = ""
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] ParentDomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.ParentDomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.ParentDomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Xaml.IO.ParentDomainName.Text = $Ctrl.DefaultText("ParentDomainName")
                    $Ctrl.ToggleStaging()
                }
            })
            
            # =(2/5)============================================================
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
                    $Ctrl.Xaml.IO.DomainName.Text = ""
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] DomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.DomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.DomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Xaml.IO.DomainName.Text = $Ctrl.DefaultText("DomainName")
                    $Ctrl.ToggleStaging()
                }
            })
            
            # =(3/5)============================================================
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
                    $Ctrl.Xaml.IO.NewDomainName.Text = ""
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] NewDomainName (Lost focus event handler)
            $Ctrl.Xaml.IO.NewDomainName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Xaml.IO.NewDomainName.Text = $Ctrl.DefaultText("NewDomainName")
                    $Ctrl.ToggleStaging()
                }
            })
            
            # =(4/5)============================================================
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
                    $Ctrl.Xaml.IO.DomainNetBiosName.Text = ""
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] DomainNetBiosName (Lost focus event handler)
            $Ctrl.Xaml.IO.DomainNetBiosName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.DomainNetBiosName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Xaml.IO.DomainNetBiosName.Text = $Ctrl.DefaultText("DomainNetBiosName")
                    $Ctrl.ToggleStaging()
                }
            })
        
            # =(5/5)============================================================
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
                    $Ctrl.Xaml.IO.NewDomainNetBiosName.Text = ""
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] NewDomainNetBiosName (Lost focus event handler)
            $Ctrl.Xaml.IO.NewDomainNetBiosName.Add_LostFocus(
            {
                If ($Ctrl.Xaml.IO.NewDomainNetBiosName.Text -eq "")
                {
                    $Ctrl.ToggleStaging()
                    $Ctrl.Xaml.IO.NewDomainNetBiosName.Text = $Ctrl.DefaultText("NewDomainNetBiosName")
                    $Ctrl.ToggleStaging()
                }
            })

            # [TextBox] Dsrm Password (Event handler)
            $Ctrl.Xaml.IO.SafeModeAdministratorPassword.Add_PasswordChanged(
            {
                $Name                        = "SafeModeAdministratorPassword"
                $Icon                        = "{0}Icon" -f $Name

                $Pass                        = $Ctrl.Dsrm("Password")
                $Pass.Value                  = $Ctrl.Xaml.IO.$Name.Password
                $Ctrl.CheckDSRMPassword()
                $Pass                        = $Ctrl.Dsrm("Password")
                
                $Ctrl.Xaml.IO.$Icon.Source   = $Ctrl.Icon($Pass.Check)
                $Ctrl.Xaml.IO.$Icon.Tooltip  = $Pass.Reason 
                $Ctrl.Total()
            })
            
            # [TextBox] Dsrm Confirm (Event handler)
            $Ctrl.Xaml.IO.Confirm.Add_PasswordChanged(
            {
                $Name                        = "Confirm"
                $Icon                        = "{0}Icon" -f $Name

                $Pass                        = $Ctrl.Dsrm("Confirm")
                $Pass.Value                  = $Ctrl.Xaml.IO.$Name.Password
                $Ctrl.CheckDSRMConfirm()
                $Pass                        = $Ctrl.Dsrm("Confirm")

                $Ctrl.Xaml.IO.$Icon.Tooltip  = $Pass.Reason 
                $Ctrl.Xaml.IO.$Icon.Source   = $Ctrl.Icon($Pass.Check)
                $Ctrl.Total()
            })
            
            # [Button] Login (Event handler)
            $Ctrl.Xaml.IO.CredentialButton.Add_Click(
            {
                $Ctrl.Login()
            })
            
            # [Button] Start (Event handler)
            $Ctrl.Xaml.IO.Start.Add_Click(
            {
                $Ctrl.Complete()
                $Ctrl.Xaml.IO.DialogResult = 1
            })
            
            # [Button] Cancel (Event handler)
            $Ctrl.Xaml.IO.Cancel.Add_Click(
            {
                $Ctrl.Xaml.IO.DialogResult = 0
            })

            $Ctrl.Xaml.IO.CommandSlot.SelectedIndex = 0
        }
    }

    $Ctrl = [FEDCPromoController]::New(1)
    $Ctrl.Xaml.Invoke()
