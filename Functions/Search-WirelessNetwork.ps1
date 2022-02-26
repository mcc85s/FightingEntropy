<#
.SYNOPSIS

.DESCRIPTION

.LINK
          Inspiration: https://www.reddit.com/r/sysadmin/comments/9az53e/need_help_controlling_wifi/
.NOTES
          FileName: Search-WirelessNetwork.ps1
          Solution: FightingEntropy Module
          Purpose: For scanning wireless networks
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2022-02-25
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>

# Load assemblies
Add-Type -AssemblyName System.Runtime.WindowsRuntime, PresentationFramework

Function Search-WirelessNetwork
{
    # Declare classes
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

    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object[]]            $Types
        [Object]               $Node
        [Object]                 $IO
        [String]          $Exception
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 

                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If (!$Xaml)
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

            ForEach ($I in 0..($This.Names.Count - 1))
            {
                $Name                = $This.Names[$I]
                $Object              = $This.IO.FindName($Name)
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If ($Object -ne $Null)
                {
                    $This.Types         += [DGList]::New($Name,$This.IO.FindName($Name).GetType().Name)
                }
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
    }

    # GC $Home\Desktop\Wirelessnetwork.xaml | % { "        '$_'," } | Set-Clipboard
    Class GUI
    {
        Static [String] $Tab = (
            '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Wireless Network Scanner" Width="800" Height="650" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
            '        <Style TargetType="ComboBox">',
            '            <Setter Property="Height" Value="24"/>',
            '            <Setter Property="Margin" Value="5"/>',
            '            <Setter Property="FontSize" Value="12"/>',
            '            <Setter Property="FontWeight" Value="Normal"/>',
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
            '    <Grid>',
            '        <Grid.Background>',
            '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
            '        </Grid.Background>',
            '        <GroupBox>',
            '            <Grid Margin="5">',
            '                <Grid.RowDefinitions>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="*"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="50"/>',
            '                </Grid.RowDefinitions>',
            '                <Grid Grid.Row="0">',
            '                    <Grid.ColumnDefinitions>',
            '                        <ColumnDefinition Width="120"/>',
            '                        <ColumnDefinition Width="120"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="120"/>',
            '                    </Grid.ColumnDefinitions>',
            '                    <Label Grid.Column="0" Content="[Search/Filter]:"/>',
            '                    <ComboBox Grid.Column="1" Name="Type" SelectedIndex="0">',
            '                        <ComboBoxItem Content="Name"/>',
            '                        <ComboBoxItem Content="Index"/>',
            '                        <ComboBoxItem Content="BSSID"/>',
            '                        <ComboBoxItem Content="Type"/>',
            '                        <ComboBoxItem Content="Encryption"/>',
            '                        <ComboBoxItem Content="Strength"/>',
            '                    </ComboBox>',
            '                    <TextBox Grid.Column="2" Name="Filter"/>',
            '                    <Button Grid.Column="3" Content="Refresh" Name="Refresh"/>',
            '                </Grid>',
            '                <DataGrid Grid.Row="1" Grid.Column="0" Name="Output">',
            '                    <DataGrid.Columns>',
            '                        <DataGridTextColumn Header="Index"  Width="35"  Binding="{Binding Index}"/>',
            '                        <DataGridTextColumn Header="Name"   Width="150" Binding="{Binding Name}"/>',
            '                        <DataGridTextColumn Header="Bssid"  Width="110" Binding="{Binding Bssid}"/>',
            '                        <DataGridTextColumn Header="Type"   Width="60"  Binding="{Binding Type}"/>',
            '                        <DataGridTextColumn Header="Uptime" Width="140" Binding="{Binding Uptime}"/>',
            '                        <DataGridTemplateColumn Header="Authentication" Width="80">',
            '                            <DataGridTemplateColumn.CellTemplate>',
            '                                <DataTemplate>',
            '                                    <ComboBox SelectedIndex="{Binding AuthenticationSlot}"  ToolTip="{Binding AuthenticationDescription}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
            '                                        <ComboBoxItem Content="None"/>',
            '                                        <ComboBoxItem Content="Unknown"/>',
            '                                        <ComboBoxItem Content="Open80211"/>',
            '                                        <ComboBoxItem Content="SharedKey80211"/>',
            '                                        <ComboBoxItem Content="Wpa"/>',
            '                                        <ComboBoxItem Content="WpaPsk"/>',
            '                                        <ComboBoxItem Content="WpaNone"/>',
            '                                        <ComboBoxItem Content="Rsna"/>',
            '                                        <ComboBoxItem Content="RsnaPsk"/>',
            '                                        <ComboBoxItem Content="Ihv"/>',
            '                                        <ComboBoxItem Content="Wpa3Enterprise192Bits"/>',
            '                                        <ComboBoxItem Content="Wpa3Sae"/>',
            '                                        <ComboBoxItem Content="Owe"/>',
            '                                        <ComboBoxItem Content="Wpa3Enterprise"/>',
            '                                    </ComboBox>',
            '                                </DataTemplate>',
            '                            </DataGridTemplateColumn.CellTemplate>',
            '                        </DataGridTemplateColumn>',
            '                        <DataGridTemplateColumn Header="Encryption" Width="70">',
            '                            <DataGridTemplateColumn.CellTemplate>',
            '                                <DataTemplate>',
            '                                    <ComboBox SelectedIndex="{Binding EncryptionSlot}" ToolTip="{Binding EncryptionDescription}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
            '                                        <ComboBoxItem Content="None"/>',
            '                                        <ComboBoxItem Content="Unknown"/>',
            '                                        <ComboBoxItem Content="Wep"/>',
            '                                        <ComboBoxItem Content="Wep40"/>',
            '                                        <ComboBoxItem Content="Wep104"/>',
            '                                        <ComboBoxItem Content="Tkip"/>',
            '                                        <ComboBoxItem Content="Ccmp"/>',
            '                                        <ComboBoxItem Content="WpaUseGroup"/>',
            '                                        <ComboBoxItem Content="RsnUseGroup"/>',
            '                                        <ComboBoxItem Content="Ihv"/>',
            '                                        <ComboBoxItem Content="Gcmp"/>',
            '                                        <ComboBoxItem Content="Gcmp256"/>',
            '                                    </ComboBox>',
            '                                </DataTemplate>',
            '                            </DataGridTemplateColumn.CellTemplate>',
            '                        </DataGridTemplateColumn>',
            '                        <DataGridTemplateColumn Header="Strength" Width="50">',
            '                            <DataGridTemplateColumn.CellTemplate>',
            '                                <DataTemplate>',
            '                                    <ComboBox SelectedIndex="{Binding Strength}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
            '                                        <ComboBoxItem Content="0"/>',
            '                                        <ComboBoxItem Content="1"/>',
            '                                        <ComboBoxItem Content="2"/>',
            '                                        <ComboBoxItem Content="3"/>',
            '                                        <ComboBoxItem Content="4"/>',
            '                                        <ComboBoxItem Content="5"/>',
            '                                    </ComboBox>',
            '                                </DataTemplate>',
            '                            </DataGridTemplateColumn.CellTemplate>',
            '                        </DataGridTemplateColumn>',
            '                    </DataGrid.Columns>',
            '                </DataGrid>',
            '                <Grid Grid.Row="2">',
            '                    <Grid.ColumnDefinitions>',
            '                        <ColumnDefinition Width="100"/>',
            '                        <ColumnDefinition Width="300"/>',
            '                        <ColumnDefinition Width="110"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="70"/>',
            '                        <ColumnDefinition Width="40"/>',
            '                    </Grid.ColumnDefinitions>',
            '                    <Label Grid.Column="0" Content="[Interface]:"/>',
            '                    <ComboBox Grid.Column="1" Name="Interface"/>',
            '                    <Label Grid.Column="2" Content="[MacAddress]:"/>',
            '                    <TextBox Grid.Column="3" Name="MacAddress" IsReadOnly="True"/>',
            '                    <Label Grid.Column="4" Content="[Index]:"/>',
            '                    <TextBox Grid.Column="5" Name="Index" IsReadOnly="True"/>',
            '                </Grid>',
            '                <Grid Grid.Row="3">',
            '                    <Grid.ColumnDefinitions>',
            '                        <ColumnDefinition Width="100"/>',
            '                        <ColumnDefinition Width="300"/>',
            '                        <ColumnDefinition Width="110"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                    </Grid.ColumnDefinitions>',
            '                    <Label Grid.Column="0" Content="[SSID/Name]:"/>',
            '                    <TextBox Grid.Column="1" Name="SSID" IsReadOnly="True"/>',
            '                    <Label Grid.Column="2" Content="[BSSID]:"/>',
            '                    <TextBox Grid.Column="3" Name="BSSID" IsReadOnly="True"/>',
            '                </Grid>',
            '                <Grid Grid.Row="4">',
            '                    <Grid.ColumnDefinitions>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                    </Grid.ColumnDefinitions>',
            '                    <Button Grid.Row="1" Grid.Column="0" Name="Connect"    Content="Connect"    IsEnabled="False"/>',
            '                    <Button Grid.Row="1" Grid.Column="1" Name="Disconnect" Content="Disconnect" IsEnabled="False"/>',
            '                    <Button Grid.Row="1" Grid.Column="2" Name="Cancel"     Content="Cancel"/>',
            '                </Grid>',
            '            </Grid>',
            '        </GroupBox>',
            '    </Grid>',
            '</Window>' -join "`n")
    }

    # GC $Home\Desktop\EnterKey.xaml | % { "        '$_'," } | Set-Clipboard
    Class Passphrase
    {
        Static [String] $Tab = @(
            '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Enter Passphrase" Width="400" Height="160" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
            '            <Setter Property="PasswordChar" Value="*"/> ',
            '        </Style> ',
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
            '    <Grid>',
            '        <Grid.Background>',
            '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
            '        </Grid.Background>',
            '        <GroupBox>',
            '            <Grid>',
            '                <Grid.RowDefinitions>',
            '                    <RowDefinition Height="*"/>',
            '                    <RowDefinition Height="*"/>',
            '                </Grid.RowDefinitions>',
            '                <PasswordBox Grid.Row="0" Name="Passphrase"/>',
            '                <Grid Grid.Row="1">',
            '                    <Grid.ColumnDefinitions>',
            '                            <ColumnDefinition Width="*"/>',
            '                            <ColumnDefinition Width="*"/>',
            '                        </Grid.ColumnDefinitions>',
            '                    <Button Grid.Row="1" Grid.Column="0" Name="Connect" Content="Continue"/>',
            '                    <Button Grid.Row="1" Grid.Column="2" Name="Cancel"  Content="Cancel"/>',
            '                </Grid>',
            '            </Grid>',
            '        </GroupBox>',
            '    </Grid>',
            '</Window>' -join "`n") 
    }

    Class Ssid
    {
        [UInt32] $Index
        Hidden [Object] $Ssid
        [String] $Name
        [Object] $Bssid
        [String] $Type
        Hidden [UInt32] $TypeSlot
        Hidden [String] $TypeDescription
        [Object] $Uptime
        [String] $NetworkType
        [String] $Authentication
        Hidden [UInt32] $AuthenticationSlot
        Hidden [String] $AuthenticationDescription
        [String] $Encryption
        Hidden [UInt32] $EncryptionSlot
        Hidden [String] $EncryptionDescription
        [UInt32] $Strength
        [String] $BeaconInterval
        [Double] $ChannelFrequency
        [Bool]   $IsWifiDirect
        Ssid([UInt32]$Index,[Object]$Object)
        {
            $This.Index              = $Index
            $This.Ssid               = $Object
            $This.Name               = $Object.Ssid
            $This.Bssid              = $Object.Bssid.ToUpper()
            $This.GetPhyType($Object.PhyKind)
            $This.Uptime             = $This.GetUptime($Object.Uptime)
            $This.NetworkType        = $Object.NetworkKind
            $This.Authentication     = $Object.SecuritySettings.NetworkAuthenticationType
            $This.GetNetAuthType($This.Authentication)
            $This.Encryption         = $Object.SecuritySettings.NetworkEncryptionType
            $This.GetNetEncType($This.Encryption)
            $This.Strength           = $Object.SignalBars
            $This.BeaconInterval     = $Object.BeaconInterval
            $This.ChannelFrequency   = $Object.ChannelCenterFrequencyInKilohertz
            $This.IsWiFiDirect       = $Object.IsWiFiDirect
        }
        [String] ToString()
        {
            Return $This.Name
        }
        [String] GetUptime([String]$Uptime)
        {
            $Slot      = @( )
            $Total     = $Uptime -Split "(\:|\.)" | ? { $_ -match "\d+" }
            $Ticks     = $Total[-1].Substring(0,3)
            $Seconds   = "{0}s" -f $Total[-2]
            $Minutes   = "{0}m" -f $Total[-3]
            $Hours     = "{0}h" -f $Total[-4]
            If ($Total[-5])
            {
                $Days  = "{0}d" -f $Total[-5]
                $Slot += $Days
            }

            If ($Total[-4])
            {
                $Slot += $Hours
            }

            If ($Total[-3])
            {
                $Slot += $Minutes
            }

            If ($Total[-2])
            {
                $Slot += $Seconds
            }

            If ($Total[-1])
            {
                $Slot += $Ticks
            }
            Return @( $Slot -join " " )
        }
        GetPhyType([String]$PhyKind)
        {
            $This.TypeSlot           = ("Unknown Fhss Dsss IRBaseband Ofdm Hrdsss Erp HT Vht Dmg HE" -Split " ").IndexOf($PhyKind)
            $This.TypeDescription    = Switch ($PhyKind)
            {
                Unknown
                { 
                    "Unspecified physical type"
                }
                Fhss
                { 
                    "(FHSS/Frequency-Hopping Spread-Spectrum)"
                }
                Dsss
                { 
                    "(DSSS/Direct Sequence Spread-Spectrum)"
                }
                IRBaseband
                { 
                    "(IR/Infrared baseband)"
                }
                Ofdm
                { 
                    "(OFDM/Orthogonal Frequency Division Multiplex)"
                }
                Hrdsss
                { 
                    "(HRDSSS/High-rated DSSS)"
                }
                Erp
                { 
                    "(ERP/Extended Rate)"
                }
                HT
                { 
                    "(HT/High Throughput [802.11n])"
                }
                Vht
                { 
                    "(VHT/Very High Throughput [802.11ac])"
                }
                Dmg
                { 
                    " (DMG/Directional Multi-Gigabit [802.11ad])" 
                }
                HE         
                { 
                    "(HEW/High-Efficiency Wireless [802.11ax])"
                }
            }
            $This.Type               = @("Unknown",[Regex]::Matches($this.TypeDescription,"(802\.11\w+)").Value)[$This.TypeDescription -match 802.11]
        }
        GetNetAuthType([String]$Auth)
        {
            $This.AuthenticationSlot = ("None Unknown Open80211 SharedKey80211 Wpa WpaPsk WpaNone Rsna RsnaPsk Ihv Wpa3 Wpa3Enterprise192Bits Wpa3Sae Owe Wpa3Enterprise" -Split " ").IndexOf($Auth)
            $This.AuthenticationDescription = Switch -Regex ($Auth)
            {
                ^None$ 
                {
                    "No authentication enabled."
                }
                ^Unknown$ 
                {
                    "Authentication method unknown."
                }
                ^Open80211$ 
                {
                    "Open authentication over 802.11 wireless.",
                    "Devices are authenticated and can connect to an access point.",
                    "Communication w/ network requires matching (WEP/Wired Equivalent Privacy) key."
                }
                ^SharedKey80211$ 
                { 
                    "Specifies an IEEE 802.11 Shared Key authentication algorithm.",
                    "Requires pre-shared (WEP/Wired Equivalent Privacy) key for 802.11 authentication."
                }
                ^Wpa$            
                { 
                    "Specifies a (WPA/Wi-Fi Protected Access) algorithm.",
                    "IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server.",
                    "Cipher keys are dynamically derived through the authentication process."
                }
                ^WpaPsk$ 
                {
                    "Specifies a (WPA/Wi-Fi Protected Access) algorithm that uses (PSK/pre-shared key).",
                    "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                    "Cipher keys are dynamically derived through a PSK that is used on both the supplicant and authenticator."
                }
                ^WpaNone$ 
                {
                    "Wi-Fi Protected Access."
                }
                ^Rsna$
                {
                    "Specifies an IEEE 802.11i (RSNA/Robust Security Network Association) algorithm.",
                    "IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server.",
                    "Cipher keys are dynamically derived through the authentication process."
                }
                ^RsnaPsk$ 
                {
                    "Specifies an IEEE 802.11i RSNA algorithm that uses (PSK/pre-shared key).",
                    "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                    "Cipher keys are dynamically derived through a PSK that is used on both the supplicant and authenticator."
                }
                ^Ihv$ 
                {
                    "Specifies an authentication type defined by an (IHV/Independent Hardware Vendor)."
                }
                "(^Wpa3$|^Wpa3Enterprise192Bits$)" 
                { 
                    "Specifies a 192-bit encryption mode for (WPA3-Enterprise/Wi-Fi Protected Access 3 Enterprise) networks."
                }
                ^Wpa3Sae$ 
                {
                    "Specifies (WPA3 SAE/Wi-Fi Protected Access 3 Simultaneous Authentication of Equals) algorithm.",
                    "WPA3 SAE is the consumer version of WPA3. SAE is a secure key establishment protocol between devices;",
                    "SAE provides: synchronous authentication, and stronger protections for users against password-guessing attempts by third parties."
                }
                ^Owe$ 
                {
                    "Specifies an (OWE/Opportunistic Wireless Encryption) algorithm.",
                    "OWE provides opportunistic encryption over 802.11 wireless networks.",
                    "Cipher keys are dynamically derived through a (DH/Diffie-Hellman) key exchange-",
                    "Enabling data protection without authentication."
                }
                ^Wpa3Enterprise$ 
                {
                    "Specifies a (WPA3-Enterprise/Wi-Fi Protected Access 3 Enterprise) algorithm.",
                    "WPA3-Enterprise uses IEEE 802.1X in a similar way as (RSNA/Robust Security Network Association)-",
                    "However, it provides increased security through the use of mandatory certificate validation and protected management frames."
                }
            }
        }
        GetNetEncType([String]$Enc)
        {
            $This.EncryptionSlot = ("None Unknown Wep Wep40 Wep104 Tkip Ccmp WpaUseGroup RsnUseGroup Ihv Gcmp Gcmp256" -Split " ").IndexOf($Enc)
            $This.EncryptionDescription = Switch ($Enc)
            {
                None
                { 
                    "No encryption enabled."
                }
                Unknown
                {
                    "Encryption method unknown."
                }
                Wep
                {
                    "Specifies a WEP cipher algorithm with a cipher key of any length."
                }
                Wep40
                {
                    "Specifies an RC4-based (WEP/Wired Equivalent Privacy) algorithm specified in IEEE 802.11-1999.",
                    "This enumerator specifies the WEP cipher algorithm with a 40-bit cipher key."
                }
                Wep104
                {
                    "Specifies a (WEP/Wired Equivalent Privacy) cipher algorithm with a 104-bit cipher key."
                }
                Tkip
                {
                    "Specifies an RC4-based cipher (TKIP/Temporal Key Integrity Protocol) algorithm",
                    "This cipher suite that is based on algorithms defined in WPA + IEEE 802.11i-2004 standards.",
                    "This cipher also uses the (MIC/Message Integrity Code) algorithm for forgery protection."
                }
                Ccmp
                {
                    "Specifies an [IEEE 802.11i-2004 & RFC 3610] AES-CCMP algorithm standard.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
                WpaUseGroup
                {
                    "Specifies a (WPA/Wifi Protected Access) Use Group Key cipher suite.",
                    "For more information about the Use Group Key cipher suite, refer to:",
                    "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
                }
                RsnUseGroup
                {
                    "Specifies a (RSN/Robust Security Network) Use Group Key cipher suite.",
                    "For more information about the Use Group Key cipher suite, refer to:",
                    "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
                }
                Ihv
                {
                    "Specifies an encryption type defined by an (IHV/Independent Hardware Vendor)."
                }
                Gcmp
                {
                    "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 128-bit key.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
                Gcmp256
                { 
                    "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 256-bit key.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
            }
        }
    }

    Class WLANInterface
    {
        Hidden [String[]] $Select
        [String] $Name
        [String] $Description
        [String] $Guid
        [String] $MacAddress
        [String] $InterfaceType
        [String] $State
        [String] $Ssid
        [String] $Bssid
        [String] $NetworkType
        [String] $RadioType
        [String] $Authentication
        [String] $Cipher
        [String] $Connection
        [String] $Band
        [UInt32] $Channel
        [Float]  $Receive
        [Float]  $Transmit
        [String] $Signal
        [String] $Profile
        WLANInterface([String[]]$Select)
        {
            $This.Select                 = $Select
            $This.Name                   = $This.Find("Name")
            $This.Description            = $This.Find("Description")
            $This.GUID                   = $This.Find("GUID")
            $This.MacAddress             = $This.Find("Physical address")
            $This.InterfaceType          = $This.Find("Interface type")
            $This.State                  = $This.Find("State")
            $This.SSID                   = $This.Find("SSID")
            $This.BSSID                  = $This.Find("BSSID")
            $This.NetworkType            = $This.Find("Network type")
            $This.RadioType              = $This.Find("Radio type")
            $This.Authentication         = $This.Find("Authentication")
            $This.Cipher                 = $This.Find("Cipher")
            $This.Connection             = $This.Find("Connection mode")
            $This.Band                   = $This.Find("Band")
            $This.Channel                = $This.Find("Channel")
            $This.Receive                = $This.Find("Receive rate \(Mbps\)")
            $This.Transmit               = $This.Find("Transmit rate \(Mbps\)")
            $This.Signal                 = $This.Find("Signal")
            $This.Profile                = $This.Find("Profile")
        }
        [String] Find([String]$String)
        {
            Return @(($This.Select | ? { $_ -match "(^\s+$String\s+\:)" }).Substring(29))
        }
    }

    Class Wireless
    {
        Hidden [Object] $Xaml
        [Object] $Adapters
        [Object] $Request
        [Object] $Radios
        [Object] $List
        [Object] $Output
        [Object] $Selected
        [Object] $Connected
        [Object] Task()
        {
            Return @( ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'})[0] )
        }
        Select([String]$Adapter)
        {
            # Select the adapter from its description
            $This.Selected                  = Get-NetAdapter | ? InterfaceDescription -eq $Adapter

            # Set other Xaml fields
            $This.Xaml.IO.Index.Text        = $This.Selected.InterfaceIndex
            $This.Xaml.IO.MacAddress.Text   = $This.Selected.MacAddress.Replace("-",":")

            $This.Update()
        }
        Update()
        {
            # Determine/Set connection state
            Switch -Regex ($This.Selected.Status)
            {
                Up
                {
                    $This.Connected                    = [WLANInterface]::New((netsh wlan show interface $This.Selected.Name))
                    $This.Xaml.IO.Ssid.Text            = $This.Connected.Ssid
                    $This.Xaml.IO.Bssid.Text           = $This.Connected.Bssid
                    $This.Xaml.IO.Disconnect.IsEnabled = 1
                    $This.Xaml.IO.Connect.IsEnabled    = 0
                }
                Default
                {
                    $This.Connected                    = $Null
                    $This.Xaml.IO.Ssid.Text            = "<Not connected>"
                    $This.Xaml.IO.Bssid.Text           = "<Not connected>"
                    $This.Xaml.IO.Disconnect.IsEnabled = 0
                    $This.Xaml.IO.Connect.IsEnabled    = 0
                }
            }
            $This.Xaml.IO.Output.SelectedIndex         = -1
        }
        Wireless()
        {
            [Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType=WindowsRuntime] > $Null
            [Windows.Devices.Radios.RadioAccessStatus, Windows.System.Devices, ContentType=WindowsRuntime] > $Null 
            [Windows.Devices.Radios.RadioState, Windows.System.Devices, ContentType=WindowsRuntime] > $Null

            # Prime the Xaml object
            $This.Xaml     = [XamlWindow][GUI]::Tab

            # Get access to any wireless adapters
            $This.Adapters = $This.RefreshAdapterList()

            # Throw if no existing wireless adapters
            If ($This.Adapters.Count -eq 0)
            {
                Throw "No existing wireless adapters on this system"
            }

            # Populate the datagrid with the available adapters
            ForEach ($Adapter in $This.Adapters)
            {
                $This.Xaml.IO.Interface.Items.Add($Adapter.InterfaceDescription)
            }

            # Requesting Radio Access
            $This.Request = $This.Task().MakeGenericMethod([Windows.Devices.Radios.RadioAccessStatus]).Invoke($null, @([Windows.Devices.Radios.Radio]::RequestAccessAsync()))
            $This.Request.Wait(-1) > $Null

            # Throw if unable to ascertain access
            If ($This.Request.Result -ne "Allowed")
            {
                Throw "Unable to request radio access"
            }

            # Establish radio synchronization
            $This.Radios  = $This.Task().MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]).Invoke($null, @([Windows.Devices.Radios.Radio]::GetRadiosAsync()))
            $This.Radios.Wait(-1) > $Null

            # Throw if unable to synchronize radios
            If (!($This.Radios.Result | ? Kind -eq WiFi))
            {
                Throw "Unable to synchronize wireless radio(s)"
            }

            $This.Refresh()
        }
        [Object[]] RefreshAdapterList()
        {
            Return @( Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)" )
        }
        [Object] Query([Object]$Interface)
        {
            Return ((netsh wlan show interface $Interface.GUID) -match "^\s+State\s+\:").Substring(29)
        }
        Scan()
        {
            $This.List   = @( )
            $This.Output = @( )

            [Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime] > $Null
            $This.List   = $This.Task().MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]]).Invoke($null, @([Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync()))
            $This.List.Wait(-1) > $Null
            $This.List.Result

            $This.List.Result.NetworkReport.AvailableNetworks | % {

                $This.Output += [Ssid]::New($This.Output.Count,$_) 
            }

            $This.Output = $This.Output | Sort-Object Strength -Descending
            Switch ($This.Output.Count)
            {
                {$_ -gt 1}
                { 
                    ForEach ($X in 0..($This.Output.Count-1))
                    {
                        $This.Output[$X].Index = $X
                    }
                }
                {$_ -eq 1}
                {
                    $This.Output[0].Index = 0
                }
                {$_ -eq 0}
                {
                    Throw "No networks detected"
                }
            }
        }
        Refresh()
        {
            $This.Xaml.IO.Output.Items.Clear()

            Start-Sleep -Milliseconds 150
            $This.Scan()

            Write-Progress -Activity Scanning -Status Starting -PercentComplete 0  

            $C = 0
            $This.Output | % { 
                
                Write-Progress -Activity Scanning -Status "($C/$($This.Output.Count-1)" -PercentComplete ([long]($C * 100 / $This.Output.Count))
                $This.Xaml.IO.Output.Items.Add($_) 
                $C ++
            }

            Write-Progress -Activity Scanning -Status Complete -Completed
            Start-Sleep -Milliseconds 50

            If ($This.Xaml.IO.Filter.Text -ne "")
            {
                $This.Output | ? $This.Xaml.IO.Type.SelectedItem.Content -match $This.Xaml.IO.Filter.Text | % { $This.Xaml.IO.Output.Items.Add($_) }
            }
        }
        [String] NewProfile([String]$SSID,[String]$Key)
        {
            $Hex   = ($SSID.ToCharArray() | % { '{0:X}' -f [int]$_ }) -join ''
            $Value = @('<?xml version="1.0"?>',
            '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">',
            "        <name>$SSID</name>",
            "        <SSIDConfig>",
            "                <SSID>",
            "                        <hex>$Hex</hex>",
            "                        <name>$SSID</name>",
            "                </SSID>",
            "        </SSIDConfig>",
            "        <connectionType>ESS</connectionType>",
            "        <connectionMode>auto</connectionMode>",
            "        <MSM>",
            "                <security>",
            "                        <authEncryption>",
            "                                <authentication>WPA2PSK</authentication>",
            "                                <encryption>AES</encryption>",
            "                                <useOneX>false</useOneX>",
            "                        </authEncryption>",
            "                        <sharedKey>",
            "                                <keyType>passPhrase</keyType>",
            "                                <protected>false</protected>",
            "                                <keyMaterial>$Key</keyMaterial>",
            "                        </sharedKey>",
            "                </security>",
            "        </MSM>",
            '        <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',
            "                <enableRandomization>false</enableRandomization>",
            "        </MacRandomization>",
            "</WLANProfile>" -join "`n")

            Set-Content -Path ".\$($This.Selected.Name)-$SSID.xml" -Value $Value
            Return ".\$($This.Selected.Name)-$SSID.xml"
        }
        Disconnect()
        {
            netsh wlan disconnect $This.Selected.Name
            $This.Update()
        }
        Connect([String]$SSID)
        {
            $Attempt = netsh wlan connect $ssid $This.Selected.Name
            If ($Attempt -match "(no profile|does not exist)")
            {
                $Pass = [XamlWindow][Passphrase]::Tab
                $Pass.IO.Connect.Add_Click(
                {
                    If ($Pass.IO.Passphrase.Password -in @($Null,""))
                    {
                        [System.Windows.Messagebox]::Show("Invalid passphrase detected.","Error") 
                    }
                    Else
                    {
                        $path    = $Wifi.NewProfile($SSID,$Pass.IO.Passphrase.Password)
                        netsh wlan add profile filename="$path"
                        $Attempt = netsh wlan connect $ssid $This.Selected.Name 
                        If ($Attempt -match "Success")
                        {
                            $Pass.IO.DialogResult = $True
                        }
                        Else
                        {
                            $Pass.IO.DialogResult = $False
                        }
                    }
                })

                $Pass.IO.Cancel.Add_Click(
                {
                    $Pass.IO.DialogResult = $False
                })

                $Pass.Invoke()
            }
        }
        SearchFilter()
        {
            If ($This.Xaml.IO.Filter.Text -ne "" -and $This.Output.Count -gt 0)
            {
                Start-Sleep -Milliseconds 50
                $This.Xaml.IO.Output.Items.Clear()
                $This.Output | ? $This.Xaml.IO.Type.SelectedItem.Content -match $This.Xaml.IO.Filter.Text | % { $This.Xaml.IO.Output.Items.Add($_) }
            }
            Else
            {
                $This.Xaml.IO.Output.Items.Clear()
                $This.Output | % { $This.Xaml.IO.Output.Items.Add($_) }
            }
        }
    }

    $Wifi = [Wireless]::New()

    If (!$Wifi)
    {
        Throw "Unable to stage the GUI"
    }

    $Xaml = $Wifi.Xaml

    # Event handlers
    $Xaml.IO.Interface.Add_SelectionChanged(
    {
        $Wifi.Select($Xaml.IO.Interface.SelectedItem)
    })

    $Xaml.IO.Output.Add_SelectionChanged(
    {
        If ($Xaml.IO.Output.SelectedIndex -eq -1)
        {
            $Xaml.IO.Connect.IsEnabled        = 0
        }
        If ($Xaml.IO.Output.SelectedIndex -ne -1)
        {
            If ($Xaml.IO.Output.SelectedItem.Name -eq $Xaml.IO.SSID.Text)
            {
                $Xaml.IO.Disconnect.IsEnabled = 1
                $Xaml.IO.Connect.IsEnabled    = 0
            }
            If ($Xaml.IO.Output.SelectedItem.Name -ne $Xaml.IO.SSID.Text)
            {
                $Xaml.IO.Disconnect.IsEnabled = 0
                $Xaml.IO.Connect.IsEnabled    = 1
            }
        }
    })

    $Xaml.IO.Refresh.Add_Click(
    {
        $Wifi.Refresh()
        $Wifi.SearchFilter()
    })

    $Xaml.IO.Filter.Add_TextChanged(
    {
        $Wifi.SearchFilter()
    })

    $Xaml.IO.Connect.Add_Click(
    {
        If (!$Wifi.Connected -and $Xaml.IO.Output.SelectedIndex -ne -1)
        {
            $Wifi.Connect($Xaml.IO.Output.SelectedItem.Name)
        }
    })

    $Xaml.IO.Disconnect.Add_Click(
    {
        If ($Wifi.Connected)
        {
            $Wifi.Disconnect()
        }
    })

    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })

    # Initial adapter selection
    $Xaml.IO.Interface.SelectedIndex   = 0

    # Show Dialog
    $Xaml.Invoke()
}
