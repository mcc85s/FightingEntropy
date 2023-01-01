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
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Promotion" Width="550" Height="440" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
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
        '                    <DataGrid Grid.Row="0" Grid.ColumnSpan="2" Name="OperatingSystemCaption" HeadersVisibility="None">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Caption" Width="*" Binding="{Binding Caption}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <DataGrid Grid.Row="1" Grid.ColumnSpan="2"  Name="OperatingSystemExtension">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Version"  Width="80" Binding="{Binding Version}"/>',
        '                            <DataGridTextColumn Header="Build"    Width="50"  Binding="{Binding Build}"/>',
        '                            <DataGridTextColumn Header="Serial"   Width="*" Binding="{Binding Serial}"/>',
        '                            <DataGridTextColumn Header="Language" Width="50"  Binding="{Binding Language}"/>',
        '                            <DataGridTextColumn Header="Product"  Width="50"  Binding="{Binding Product}"/>',
        '                            <DataGridTextColumn Header="Type"     Width="50"   Binding="{Binding Type}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Border   Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="3" Grid.Column="0" Content="Forest Mode" Style="{StaticResource LabelGray}"/>',
        '                    <ComboBox Grid.Row="3" Grid.Column="1" Name="ForestMode" SelectedIndex="0">',
        '                        <ComboBoxItem Content="Windows Server 2000 (Default)"/>',
        '                        <ComboBoxItem Content="Windows Server 2003"/>',
        '                        <ComboBoxItem Content="Windows Server 2008"/>',
        '                        <ComboBoxItem Content="Windows Server 2008 R2"/>',
        '                        <ComboBoxItem Content="Windows Server 2012"/>',
        '                        <ComboBoxItem Content="Windows Server 2012 R2"/>',
        '                        <ComboBoxItem Content="Windows Server 2016"/>',
        '                        <ComboBoxItem Content="Windows Server 2019"/>',
        '                        <ComboBoxItem Content="Windows Server 2022"/>',
        '                    </ComboBox>',
        '                    <Label    Grid.Row="4" Grid.Column="0" Content="Domain Mode" Style="{StaticResource LabelGray}"/>',
        '                    <ComboBox Grid.Row="4" Grid.Column="1" Name="DomainMode" SelectedIndex="0">',
        '                        <ComboBoxItem Content="Windows Server 2000 (Default)"/>',
        '                        <ComboBoxItem Content="Windows Server 2003"/>',
        '                        <ComboBoxItem Content="Windows Server 2008"/>',
        '                        <ComboBoxItem Content="Windows Server 2008 R2"/>',
        '                        <ComboBoxItem Content="Windows Server 2012"/>',
        '                        <ComboBoxItem Content="Windows Server 2012 R2"/>',
        '                        <ComboBoxItem Content="Windows Server 2016"/>',
        '                        <ComboBoxItem Content="Windows Server 2019"/>',
        '                        <ComboBoxItem Content="Windows Server 2022"/>',
        '                    </ComboBox>',
        '                    <Border   Grid.Row="5" Grid.Column="0" Grid.ColumnSpan="2" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="6" Grid.Column="0" Content="Parent Domain" Style="{StaticResource LabelGray}"/>',
        '                    <Grid     Grid.Row="6" Grid.Column="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Image   Grid.Column="0" Name="ParentDomainNameIcon"/>',
        '                        <TextBox Grid.Column="1" Name="ParentDomainName"/>',
        '                    </Grid>',
        '                    <Border   Grid.Row="7" Grid.Column="0" Grid.ColumnSpan="2" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="8" Grid.Column="0" Content="Replication DC" Style="{StaticResource LabelGray}"/>',
        '                    <ComboBox Grid.Row="8" Grid.Column="1" Name="ReplicationSourceDC"/>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Features">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label    Grid.Row="0" Content="[Windows Server features to be installed]:"/>',
        '                    <DataGrid Grid.Row="1" Name="Feature" ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Type" Width="50"  Binding="{Binding Type}" CanUserSort="True" IsReadOnly="True"/>',
        '                            <DataGridTextColumn Header="Name" Width="*" Binding="{Binding Name}" CanUserSort="True" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Install" Width="60">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <CheckBox IsEnabled="{Binding Enabled}" Margin="0" Height="18" HorizontalAlignment="Left"/>',
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
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label    Grid.Row="0" Content="[Domain controller roles, and Active Directory partition info]"/>',
        '                    <Border   Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Style="{StaticResource Line}"/>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="32"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <CheckBox Grid.Column="0" Grid.Row="0" Name="InstallDNS" />',
        '                        <Label    Grid.Column="1" Grid.Row="0" Content="Install DNS" Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="0" Grid.Row="1" Name="CreateDNSDelegation"/>',
        '                        <Label    Grid.Column="1" Grid.Row="1" Content="Create DNS Delegation" Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="2" Grid.Row="0" Name="NoGlobalCatalog"/>',
        '                        <Label    Grid.Column="3" Grid.Row="0" Content="No Global Catalog" Style="{StaticResource LabelRed}"/>',
        '                        <CheckBox Grid.Column="2" Grid.Row="1" Name="CriticalReplicationOnly"/>',
        '                        <Label    Grid.Column="3" Grid.Row="1" Content="Critical Replication Only" Style="{StaticResource LabelRed}"/>',
        '                    </Grid>',
        '                    <Border   Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="2" Style="{StaticResource Line}"/>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Row="0" Grid.Column="0" Content="Database" Style="{StaticResource LabelGray}"/>',
        '                        <TextBox Grid.Row="0" Grid.Column="2" Name="DatabasePath"/>',
        '                        <Label   Grid.Row="1" Grid.Column="0" Content="SysVol" Style="{StaticResource LabelGray}"/>',
        '                        <TextBox Grid.Row="1" Grid.Column="2" Name="SysvolPath"/>',
        '                        <Label   Grid.Row="2" Grid.Column="0" Content="Log" Style="{StaticResource LabelGray}"/>',
        '                        <TextBox Grid.Row="2" Grid.Column="2" Name="LogPath"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Names">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label    Grid.Row="0" Grid.ColumnSpan="3" Content="[Necessary fields vary by command selection]"/>',
        '                    <Border   Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="Domain" Style="{StaticResource LabelGray}"/>',
        '                    <Image    Grid.Row="2" Grid.Column="1" Name="DomainNameIcon"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="2" Name="DomainName"/>',
        '                    <Label    Grid.Row="3" Grid.Column="0" Content="New Domain" Style="{StaticResource LabelGray}"/>',
        '                    <Image    Grid.Row="3" Grid.Column="1" Name="NewDomainNameIcon"/>',
        '                    <TextBox  Grid.Row="3" Grid.Column="2" Name="NewDomainName"/>',
        '                    <Border   Grid.Row="4" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="5" Grid.Column="0" Content="NetBIOS" Style="{StaticResource LabelGray}"/>',
        '                    <Image    Grid.Row="5" Grid.Column="1" Name="DomainNetBIOSNameIcon"/>',
        '                    <TextBox  Grid.Row="5" Grid.Column="2" Name="DomainNetBIOSName"/>',
        '                    <Label    Grid.Row="6" Grid.Column="0" Content="New NetBIOS" Style="{StaticResource LabelGray}"/>',
        '                    <Image    Grid.Row="6" Grid.Column="1" Name="NewDomainNetBIOSNameIcon"/>',
        '                    <TextBox  Grid.Row="6" Grid.Column="2" Name="NewDomainNetBIOSName"/>',
        '                    <Border   Grid.Row="7" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
        '                    <Label    Grid.Row="8" Grid.Column="0" Content="Site Name" Style="{StaticResource LabelGray}"/>',
        '                    <Image    Grid.Row="8" Grid.Column="1" Name="SiteNameIcon"/>',
        '                    <ComboBox Grid.Row="8" Grid.Column="2" Name="SiteName"/>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Credential">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0" Content="[Active Directory promotion credential]"/>',
        '                    <Border Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button  Grid.Column="0" Content="Credential" Name="CredentialButton"/>',
        '                        <Image   Grid.Column="1" Name="CredentialIcon"/>',
        '                        <TextBox Grid.Column="2" Name="Credential"/>',
        '                    </Grid>',
        '                    <Border   Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
        '                    <Label Grid.Row="4" Content="[(DSRM/Domain Services Restore Mode) Key]"/>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label       Grid.Column="0" Content="Password" Style="{StaticResource LabelGray}"/>',
        '                        <Image       Grid.Column="1" Name="SafeModeAdministratorPasswordIcon"/>',
        '                        <PasswordBox Grid.Column="2" Name="SafeModeAdministratorPassword"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label       Grid.Column="0" Content="Confirm" Style="{StaticResource LabelGray}"/>',
        '                        <Image       Grid.Column="1" Name="ConfirmIcon"/>',
        '                        <PasswordBox Grid.Column="2" Name="Confirm"/>',
        '                    </Grid>',
        '                    <Border   Grid.Row="7" Grid.Column="0" Grid.ColumnSpan="3" Style="{StaticResource Line}"/>',
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
        [UInt32]     $Index
        [String]      $Name
        [String]      $Type
        [String]  $Property
        [UInt32] $IsEnabled
        [Object]     $Value
        [UInt32]     $Check
        [String]    $Reason
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
            Return "<FEDCPromo.ProfileSlotList>"
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
            Return "<FEDCPromo.ProfileRoleList>"
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
            Return "<FEDCPromo.ProfilePasswordList>"
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
            $This.Slot        = $This.Get("ProfileSlotList")
            $This.Role        = $This.Get("ProfileRoleList")
            $This.DSRM        = $This.Get("ProfilePasswordList")

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
        [Object] Get([String]$Name)
        {
            $X = Switch ($Name)
            {
                ProfileSlotList     {     [ProfileSlotList]::New($This.Index) }
                ProfileRoleList     {     [ProfileRoleList]::New($This.Index) }
                ProfilePasswordList { [ProfilePasswordList]::New($This.Index) }
            }

            Return $X
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
    
    # (2/3) [Command.Item]
    Class CommandItem
    {
        [UInt32] $Index
        [String] $Type
        [String] $Name
        [String] $Description
        CommandItem([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            $This.Index       = $Index
            $This.Type        = $Type
            $This.Name        = $Name
            $This.Description = $Description
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandItem>"
        }
    }
    
    # (3/3) [Command.Controller]
    Class CommandController
    {
        [String]    $Name
        [UInt32]    $Slot = 0
        [Object] $Profile
        [Object]  $Output
        CommandController()
        {
            $This.Name    = "Command"
            $This.Profile = $Null
            $This.Stage()
            $This.SetProfile($This.Slot)
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
        [Object] CommandItem([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            Return [CommandItem]::New($Index,$Type,$Name,$Description)
        }
        [UInt32] Index([String]$Type)
        {
            Return [UInt32][CommandType]::$Type
        }
        [Object] ProfileControl([Object]$Current)
        {
            Return [ProfileController]::New($Current)
        }
        [Object] Current()
        {
            Return $This.Output[$This.Slot]
        }
        SetProfile([UInt32]$Index)
        {
            $This.Slot    = $Index
            $This.Profile = $This.ProfileControl($This.Current())
        }
        Add([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            $This.Output += $This.CommandItem($Index,$Type,$Name,$Description)
        }
        [String] ToString()
        {
            Return "<FEDCPromo.CommandList>"
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

    Class Connection
    {
        [String] $IPAddress
        [String] $DNSName
        [String] $Domain
        [String] $NetBIOS
        [PSCredential] $Credential
        Hidden [String] $Site
        [String[]] $Sitename
        [String[]] $ReplicationDC
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
    }

    Class FEDCPromoController
    {
        [Object]             $Console
        [UInt32]                $Mode
        [Object]              $Module
        [Object]              $System
        [Object]             $Network
        [Object]             $Feature
        [Object]             $Command
        [Object]                $Xaml
        Hidden [String]         $Pass
        Hidden [String]         $Fail
        [UInt32]             $Staging
        [String]             $Caption
        [UInt32]              $Server
        Hidden [Object]   $Credential
        [String]          $DomainType
        [Object]          $Connection
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
        FEDCPromoController([Switch]$Flags)
        {
            $This.Mode     = 1
            $This.StartConsole()
            $This.Xaml     = $This.GetFEDCPromoXaml()
            
            $Ctrl          = $This
            $Test          = 0,1,2,3
            $Ctrl.Reset($Ctrl.Xaml.IO.CommandSlot,$Test)

            $Ctrl.Xaml.IO.CommandSlot.Add_SelectionChanged(
            {
                $Ctrl.Update(0,$Ctrl.Xaml.IO.CommandSlot.SelectedItem)
            })
        }
        Main()
        {
            # Initialize console
            $This.StartConsole()

            # Primary components
            $This.Module   = $This.Get("FEModule")
            $This.System   = $This.Get("FESystem")
            $This.Network  = $This.Get("FENetwork")

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
                        Write-Host "Warning [!] Static IP Address not set"
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

            # Load features
            $This.Feature       = $This.Get("FEFeatureList")
            
            # Validate Adds installation
            $This.ValidateAdds()

            # Import Adds Module
            $This.ImportAdds()

            # Get Command/Profile controller
            $This.Command       = $This.Get("CommandController")

            # Load Xaml
            $This.Xaml          = $This.Get("FEDCPromoXaml")

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
            $Adds               = $This.Features | ? Name -eq AD-Domain-Services
            If ($Adds.Installed -eq 0)
            {
                $This.Update(0,"Processing [~] Installing: [Ad-Domain-Services]")
                Write-Theme $This.Status()

                $This.InstallAdds()

                If (!(Get-Module AddsDeployment))
                {
                    $This.Update(-1,"Failed [!] Installing: [Ad-Domain-Services]")
                    Throw "Exception [!] Could not load module [AddsDeployment]"
                }
                Else
                {
                    $This.Update(1,"Success [+] Installed: [Ad-Domain-Services]")
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
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                FEModule          { Get-FEModule -Mode 1                 }
                FESystem          { Get-FESystem -Mode 0 -Level 3        }
                FENetwork         { Get-FENetwork -Mode 7                }
                FEFeatureList     { [FeatureList]::New().Output          }
                FEDCPromoXaml     { [XamlWindow][FEDCPromoXaml]::Content }
                FEDCFoundXaml     { [XamlWindow][FEDCFoundXaml]::Content }
                CommandController { [CommandController]::New()           }
            }

            Switch (!!$Item)
            {
                $True  { $This.Update( 1,"Loaded [+] [$Name]") }
                $False { $This.Update(-1,"Failed [!] [$Name]") }
            }

            Return $Item
        }
        [String] SystemRoot()
        {
            Return [Environment]::GetEnvironmentVariable("SystemRoot")
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
        StageXaml()
        {
            $Ctrl          = $This

            # Graphics
            $Ctrl.Pass     = $Ctrl.Module._Control("success.png").Fullname
            $Ctrl.Fail     = $Ctrl.Module._Control("failure.png").FullName

            # Index/Mode
            $Ctrl.Reset($Ctrl.Xaml.IO.CommandSlot,$Ctrl.Command.Output.Type)

            # OS Caption
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystemCaption,$Ctrl.System.OperatingSystem)

            # OS Properties
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystemExtension,$Ctrl.System.OperatingSystem)

            # Forest/Domain mode
            $Ctrl.Xaml.IO.ForestMode.SelectedIndex = $Ctrl.Server
            $Ctrl.Xaml.IO.DomainMode.SelectedIndex = $Ctrl.Server

            # ReplicationSourceDC
            $Ctrl.Reset($Ctrl.Xaml.IO.ReplicationSourceDC,$Null)

            # Windows Features
            $Ctrl.Reset($Ctrl.Xaml.IO.Feature,$Ctrl.Feature)

            # Roles
            $Ctrl.XamlDefault("Role")

            # Paths
            $Ctrl.XamlDefault("Path")

            # Names
            $Ctrl.XamlDefault("Name")

            # Credential
            $Ctrl.XamlDefault("Credential")

            # Buttons
            $Ctrl.XamlDefault("Button")

            # Event handlers
            $Ctrl.Xaml.IO.ParentDomainName.Add_TextChanged(
            {
                $Ctrl.Check("ParentDomainName")
            })
            
            $Ctrl.Xaml.IO.DomainName.Add_TextChanged(
            {
                $Ctrl.Check("DomainName")
            })
            
            $Ctrl.Xaml.IO.NewDomainName.Add_TextChanged(
            {
                $Ctrl.Check("NewDomainName")
            })
            
            $Ctrl.Xaml.IO.DomainNetBIOSName.Add_TextChanged(
            {
                $Ctrl.Check("DomainNetBIOSName")
            })
        
            $Ctrl.Xaml.IO.NewDomainNetBIOSName.Add_TextChanged(
            {
                $Ctrl.Check("NewDomainNetBIOSName")
            })

            $Ctrl.Xaml.IO.SafeModeAdministratorPassword.Add_PasswordChanged(
            {
                $Name                        = "SafeModeAdministratorPassword"
                $Icon                        = "{0}Icon" -f $Name

                $Pass                        = $Ctrl.DSRM("Password")
                $Pass.Value                  = $Ctrl.Xaml.IO.$Name.Password
                $Ctrl.CheckDSRMPassword()
                $Pass                        = $Ctrl.Dsrm("Password")
                
                $Ctrl.Xaml.IO.$Icon.Source   = @($Ctrl.Fail,$Ctrl.Pass)[$Pass.Check]
                $Ctrl.Xaml.IO.$Icon.Tooltip  = $Pass.Reason 
                $Ctrl.Total()
            })
            
            $Ctrl.Xaml.IO.Confirm.Add_PasswordChanged(
            {
                $Name                        = "Confirm"
                $Icon                        = "{0}Icon" -f $Name

                $Pass                        = $Ctrl.Dsrm("Confirm")
                $Pass.Value                  = $Ctrl.Xaml.IO.$Name.Password
                $Ctrl.CheckDSRMConfirm()
                $Pass                        = $Ctrl.Dsrm("Confirm")

                $Ctrl.Xaml.IO.$Icon.Tooltip  = $Pass.Reason 
                $Ctrl.Xaml.IO.$Icon.Source   = @($Ctrl.Fail,$Ctrl.Pass)[$Pass.Check]
                $Ctrl.Total()
            })
            
            $Ctrl.Xaml.IO.CredentialButton.Add_Click(
            {
                $Ctrl.Login()
            })
            
            $Ctrl.Xaml.IO.Start.Add_Click(
            {
                $Ctrl.Complete()
                $Ctrl.Xaml.IO.DialogResult = 1
            })
            
            $Ctrl.Xaml.IO.Cancel.Add_Click(
            {
                $Ctrl.Xaml.IO.DialogResult = 0
            })

            # Command selection event handler
            $Ctrl.Xaml.IO.CommandSlot.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.CommandSlot.SelectedIndex
                $Ctrl.SetProfile($Index)
                $Ctrl.Reset($Ctrl.Xaml.IO.Command,$Ctrl.Command.Profile)
            })

            $Ctrl.Xaml.IO.CommandSlot.SelectedIndex = 0
        }
        XamlDefault([String]$Section)
        {
            $This.Update(0,"Setting [~] Defaults: [$Section]")
            Switch ($Section)
            {
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
        [Object] GetFEDCPromoXaml()
        {
            Return [XamlWindow][FEDCPromoXaml]::Content
        }
        [Object] GetFEDCFoundXaml()
        {
            Return [XamlWindow][FEDCFoundXaml]::Content
        }
        [Object] GetConnection([Object]$Connect)
        {
            Return [Connection]::New($Connect)
        }
        SetInputObject([Object]$In)
        {
            $This.SetMode($In.Mode)
            Switch ($In.Mode)
            {
                Default {}
                3
                {
                    $This.Credential                     = $In.Credential
                    $This.Xaml.IO.Credential.Text        = $In.Credential.Username
                    $This.Xaml.IO.SiteName.ItemsSource   = @( )
                    $This.Xaml.IO.SiteName.ItemsSource   = @($In.Sitename)
                    $This.Xaml.IO.SiteName.SelectedIndex = 0
                    $This.Xaml.IO.DomainName.Text        = $In.DomainName
                    $This.Xaml.IO.SafeModeAdministratorPassword.Password = $In.SafeModeAdministratorPassword.GetNetworkCredential().Password
                    $This.Xaml.IO.Confirm.Password       = $In.SafeModeAdministratorPassword.GetNetworkCredential().Password
                }
            }
        }
        [Object] Slot([String]$Name)
        {
            Return $This.Command.Profile.Slot.Output | ? Name -eq $Name
        }
        [Object] Role([String]$Name)
        {
            Return $This.Command.Profile.Role.Output | ? Name -eq $Name
        }
        [Object] DSRM([String]$Name)
        {
            Return $This.Command.Profile.DSRM.Output | ? Name -eq $Name
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
                    $This.Update(0,"Enabling [~} Staging mode")
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
            $This.Command.SetProfile($Index)

            # Enabled staging mode [prevents event handler spamming]
            $This.ToggleStaging()

            # DomainType
            $This.SetDomainType()

            # Credential
            $This.SetCredential()

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
            $This.Slot("ForestMode").Value = $This.Server
            $This.Slot("DomainMode").Value = $This.Server
        }
        SetDomainType()
        {
            $This.Update(0,"Setting [~] DomainType")
            $This.DomainType = @("-","Tree","Child","-")[$This.Command.Slot]
        }
        SetCredential()
        {
            $This.Update(0,"Setting [~] Credential button")
            $This.Xaml.IO.CredentialButton.IsEnabled = $This.Command.Slot -eq 0
        }
        SetRoles()
        {
            $This.Update(0,"Setting [~] Roles")
            ForEach ($Role in $This.Command.Profile.Role.Output)
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
                ForEach ($Item in $This.Command.Profile.Slot.Output | ? Type -eq $Type)
                {
                    $Name       = $Item.Name
                    $Control    = $This.Xaml.IO.$Name
                    $Rank       = $Item.IsEnabled
                    $Mark       = @(" ","X")[$Rank]

                    $This.Update(0,"Setting [~] Profile [$Mark], Slot: [$Name], Type: [$Type]")

                    $Control.Visibility = @("Collapsed","Visible")[$Rank]
                    $Control.IsEnabled  = $Rank

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
                            $Control.SelectedIndex = @($Item.Value,$This.Server)[$Name -match "Mode"]
                            $Control.IsEnabled     = 1
                        }
                        Else
                        {
                            $Control.SelectedIndex = 0
                        }
                    }
                    If ($Type -eq "TextBox")
                    {
                        $Icon                              = "{0}Icon" -f $Name

                        If ($Item.IsEnabled)
                        {
                            $Control.Text                  = $Item.Value
                            $Control.IsEnabled             = 1
    
                            $This.Xaml.IO.$Icon.Visibility = "Visible"
                        }
                        Else
                        {
                            If ($Control.Text)
                            {
                                $Control.Text              = ""
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
                Switch ($This.Command.Slot)
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
            If ($This.Command.Slot -eq 0)
            {
                $This.Update(0,"Clearing [~] Credential")
                $This.Xaml.IO.Credential.Text                       = ""
                $This.Xaml.IO.CredentialButton.IsEnabled            = 0
                $This.Credential                                    = $Null
            }

            If ($This.Command.Slot -ne 0 -and $This.Connection)
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
            $This.Connection = $Null
            $Dcs             = $This.Network.NBT.Output
            If ($DCs)
            {
                $DC          = $This.FEDCFoundXaml()

                $DC.IO.DomainControllers.ItemsSource = @( )
                $DC.IO.DomainControllers.ItemsSource = @($DCs)
                $DC.IO.DomainControllers.Add_SelectionChanged(
                {
                    If ($DC.IO.DomainControllers.SelectedIndex -ne -1)
                    {
                        $DC.IO.Ok.IsEnabled = 1
                    }
                })

                $DC.IO.Ok.IsEnabled = 0
                $DC.IO.Cancel.Add_Click(
                {
                    $DC.IO.DialogResult = $False
                })

                $DC.IO.Ok.Add_Click(
                {
                    $DC.IO.DialogResult = $True
                })

                $DC.Invoke()

                If ($DC.IO.DialogResult)
                {
                    $Connect = Get-FEADLogin -Target $DC.IO.DomainControllers.SelectedItem
                    If (!$Connect.Test.DistinguishedName)
                    {
                        $This.Connection = $Null
                    }
                    If ($Connect.Test.DistinguishedName)
                    {
                        $This.Connection = $This.GetConnection($Connect)
                        $This.Connection.AddReplicationDCs($DCs)
                    }
                }
            }
            If (!$DCs)
            {
                $Connect = Get-FEADLogin
                If (!$Connect.Test.DistinguishedName)
                {
                    $This.Connection = $Null
                }
                If ($Connect.Test.DistinguishedName)
                {
                    $This.Connection = $This.GetConnection($Connect)
                }
            }

            $This.SetMode($This.Mode)
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
        [String[]] SecurityDescriptors()
        {
            $Out = "AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS"+
            ",LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS,RU,SA,SI,SO,SU,SY,WD"
            
            Return $Out -Split ','
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

                    $This.CheckObject($Item)

                    $This.Xaml.IO.$Name.Visibility = "Visible"
                    $This.Xaml.IO.$Icon.Source     = @($This.Fail,$This.Pass)[$Item.Check]
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
        CheckDomain([Object]$Item)
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

            $Item.Validate($X)
            [Console]::WriteLine($Item.Reason)
        }
        CheckNetBIOS([Object]$Item)
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
            ElseIf ($Item.Value -in $This.SecurityDescriptors())
            {
                $X = "[!] Matches a security descriptor"
            }
            Else
            {
                $X = "[+] Passed"
            }

            $Item.Validate($X)
            [Console]::WriteLine($Item.Reason)
        }
        CheckTree([Object]$Item)
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

            $Item.Validate($X)
            [Console]::WriteLine($Item.Reason)
        }
        CheckChild([Object]$Item)
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

            $Item.Validate($X)
            [Console]::WriteLine($Item.Reason)
        }
        CheckObject([Object]$Item)
        {
            Switch ($Item.Name)
            {
                {$_ -in "ParentDomainName","DomainName"}
                { 
                    $This.CheckDomain($Item) 
                }
                {$_ -in "DomainNetBIOSName","NewDomainNetBIOSName"}
                {
                    $This.CheckNetBIOS($Item)
                }
                {$_ -eq "NewDomainName" -and $This.Command.Slot -eq 1}
                {
                    $This.CheckTree($Item)
                }
                {$_ -eq "NewDomainName" -and $This.Command.Slot -eq 2}
                {
                    $This.CheckChild($Item)
                }
            }
        }
        CheckDSRMPassword()
        {
            $Pattern  = "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
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

            If ($Password.Check -eq 1 -and $Confirm.Value -eq $Password.Value)
            {
                $Confirm.Validate("[+] Passed")
            }
            Else
            {
                $Confirm.Validate("[!] Confirmation error")
            }
        }
        Total()
        {
            $xSlot = $This.Command.Profile.Slot.Output | ? IsEnabled | ? Property -eq Text | ? Check 
            $xPass = $This.Command.Profile.DSRM.Output | ? Check

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

            ForEach ($Item in $This.Command.Profile.Role.Output)
            {
                $Name           = $Item.Name
                $Item.IsChecked = $Item.IsEnabled -and $This.Xaml.IO.$Name.IsChecked
            }

            If ($This.Command.Slot -eq 2)
            {
                $Item           = $This.Slot("NewDomainName")
                $Item.Value     = $Item.Value.Replace($This.Connection.Domain,"").TrimEnd(".")
            }

            $Item               = $This.DSRM("Password")
            $Item.Value         = $Item.Value | ConvertTo-SecureString -AsPlainText -Force

            ForEach ($Item in $This.Command.Profile.Role.Output)
            {
                $This.ToggleRole($Item.Name)
            }
        }
    }

    $Ctrl = [FEDCPromoController]::New(1)
    $Ctrl.Xaml.Invoke()
