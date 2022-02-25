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
          Modified: 2022-02-24
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
# Load assemblies
Add-Type -AssemblyName System.Runtime.WindowsRuntime, PresentationFramework

# Load runtime(s)
"Radio RadioAccessStatus RadioState" -Split " " | % { Invoke-Expression "[Windows.Devices.Radios.$_, Windows.System.Devices, ContentType=WindowsRuntime]"}

# Declare functions
Function Get-AsTaskGeneric
{
    ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'})[0]
}

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
            '                        <DataGridTextColumn Header="Type"   Width="60"   Binding="{Binding Type}"/>',
            '                        <DataGridTextColumn Header="Uptime" Width="140"   Binding="{Binding Uptime}"/>',
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

    Class TxSsid
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
        TxSsid([UInt32]$Index,[Object]$Object)
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
                Unknown    { "Unspecified PHY type"                                }
                Fhss       { "Frequency-hopping, spread-spectrum (FHSS) PHY."      }
                Dsss       { "Direct sequence, spread-spectrum (DSSS) PHY."        }
                IRBaseband { "Infrared (IR) baseband PHY."                         }
                Ofdm       { "Orthogonal frequency division multiplex (OFDM) PHY." }
                Hrdsss     { "High-rated DSSS (HRDSSS) PHY."                       }
                Erp        { "Extended Rate (ERP) PHY." }
                HT         { "High Throughput (HT) PHY for 802.11n PHY." }
                Vht        { "Very High Throughput (VHT) PHY for 802.11ac PHY." }
                Dmg        { "Directional multi-gigabit (DMG) PHY for 802.11ad." }
                HE         { "High-Efficiency Wireless (HEW) PHY for 802.11ax." }
            }
            $This.Type               = @("Unknown",[Regex]::Matches($this.TypeDescription,"(802\.11\w+)").Value)[$This.TypeDescription -match 802.11]
        }
        GetNetAuthType([String]$Auth)
        {
            $This.AuthenticationSlot = ("None Unknown Open80211 SharedKey80211 Wpa WpaPsk WpaNone Rsna RsnaPsk Ihv Wpa3 Wpa3Enterprise192Bits Wpa3Sae Owe Wpa3Enterprise" -Split " ").IndexOf($Auth)
            $This.AuthenticationDescription = Switch -Regex ($Auth)
            {
                "(^None$)" {"No authentication enabled."}
                "(^Unknown$)" {"Authentication method unknown."}
                "(^Open80211$)" {"Open authentication over 802.11 wireless.Devices are authenticated and can connect to an access point, but communication with the network requires a matching Wired Equivalent Privacy (WEP) key."}
                "(^SharedKey80211$)" { "Specifies an IEEE 802.11 Shared Key authentication algorithm that requires the use of a pre-shared Wired Equivalent Privacy (WEP) key for the 802.11 authentication."}
                "(^Wpa$)"            { "Specifies a Wi-Fi Protected Access (WPA) algorithm. IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server. Cipher keys are dynamically derived through the authentication process."}
                "(^WpaPsk$)" {"Specifies a Wi-Fi Protected Access (WPA) algorithm that uses pre-shared keys (PSK). IEEE 802.1X port authorization is performed by the supplicant and authenticator. Cipher keys are dynamically derived through a pre-shared key that is used on both the supplicant and authenticator."}
                "(^WpaNone$)" {"Wi-Fi Protected Access."}
                "(^Rsna$)" {"Specifies an IEEE 802.11i Robust Security Network Association (RSNA) algorithm. IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server. Cipher keys are dynamically derived through the authentication process."}
                "(^RsnaPsk$)" {"Specifies an IEEE 802.11i RSNA algorithm that uses PSK. IEEE 802.1X port authorization is performed by the supplicant and authenticator. Cipher keys are dynamically derived through a pre-shared key that is used on both the supplicant and authenticator."}
                "(^Ihv$)" {"Specifies an authentication type defined by an independent hardware vendor (IHV)."}
                "(^Wpa3$|^Wpa3Enterprise192Bits$)" { "Specifies a 192-bit encryption mode for Wi-Fi Protected Access 3 Enterprise (WPA3-Enterprise) networks."}
                "(^Wpa3Sae$)" {"Specifies a Wi-Fi Protected Access 3 Simultaneous Authentication of Equals (WPA3 SAE) algorithm. WPA3 SAE is the consumer version of WPA3. Simultaneous Authentication of Equals (SAE) is a secure key establishment protocol between devices; it provides synchronous authentication, and stronger protections for users against password-guessing attempts by third parties."}
                "(^Owe$)" {"Specifies an opportunistic wireless encryption (OWE) algorithm. OWE provides opportunistic encryption over 802.11 wireless, where cipher keys are dynamically derived through a Diffie-Hellman key exchange; enabling data protection without authentication."}
                "(^Wpa3Enterprise$)" {"Specifies a Wi-Fi Protected Access 3 Enterprise (WPA3-Enterprise) algorithm. WPA3-Enterprise uses IEEE 802.1X in a similar way as RSNA, but provides increased security through the use of mandatory certificate validation and protected management frames."}
            }
        }
        GetNetEncType([String]$Enc)
        {
            $This.EncryptionSlot = ("None Unknown Wep Wep40 Wep104 Tkip Ccmp WpaUseGroup RsnUseGroup Ihv Gcmp Gcmp256" -Split " ").IndexOf($Enc)
            $This.EncryptionDescription = Switch ($Enc)
            {
                None        { "No encryption enabled."   }
                Unknown     {"Encryption method unknown."}
                Wep         {"Specifies a WEP cipher algorithm with a cipher key of any length."}
                Wep40       {"Specifies a Wired Equivalent Privacy (WEP) algorithm, which is the RC4-based algorithm that is specified in the IEEE 802.11-1999 standard. This enumerator specifies the WEP cipher algorithm with a 40-bit cipher key."}
                Wep104      {"Specifies a WEP cipher algorithm with a 104-bit cipher key."}
                Tkip        {"Specifies a Temporal Key Integrity Protocol (TKIP) algorithm, which is the RC4-based cipher suite that is based on the algorithms that are defined in the WPA specification and IEEE 802.11i-2004 standard. This cipher also uses the Michael Message Integrity Code (MIC) algorithm for forgery protection."}
                Ccmp        {"Specifies an AES-CCMP algorithm, as specified in the IEEE 802.11i-2004 standard and RFC 3610. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197."}
                WpaUseGroup {"Specifies a Wifi Protected Access (WPA) Use Group Key cipher suite. For more information about the Use Group Key cipher suite, refer to Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."}
                RsnUseGroup {"Specifies a Robust Security Network (RSN) Use Group Key cipher suite. For more information about the Use Group Key cipher suite, refer to Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."}
                Ihv         {"Specifies an encryption type defined by an independent hardware vendor (IHV)."}
                Gcmp        {"Specifies an AES-GCMP algorithm, as specified in the IEEE 802.11-2016 standard, with a 128-bit key. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197."}
                Gcmp256     { "Specifies an AES-GCMP algorithm, as specified in the IEEE 802.11-2016 standard, with a 256-bit key. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197." }
            }
        }
    }

    Class WLANInterface
    {
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
            $This.Name                   = ($Select | ? { $_ -match "(^\s+Name\s+\:)" }).Substring(29)
            $This.Description            = ($Select | ? { $_ -match "(^\s+Description\s+\:)" }).Substring(29)
            $This.GUID                   = ($Select | ? { $_ -match "(^\s+GUID\s+\:)" }).Substring(29)
            $This.MacAddress             = ($Select | ? { $_ -match "(^\s+Physical address\s+\:)" }).Substring(29).ToUpper()
            $This.InterfaceType          = ($Select | ? { $_ -match "(^\s+Interface type\s+\:)" }).Substring(29)
            $This.State                  = ($Select | ? { $_ -match "(^\s+State\s+\:)" }).Substring(29)
            $This.SSID                   = ($Select | ? { $_ -match "(^\s+SSID\s+\:)" }).Substring(29)
            $This.BSSID                  = ($Select | ? { $_ -match "(^\s+BSSID\s+\:)" }).Substring(29).ToUpper()
            $This.NetworkType            = ($Select | ? { $_ -match "(^\s+Network type\s+\:)" }).Substring(29)
            $This.RadioType              = ($Select | ? { $_ -match "(^\s+Radio type\s+\:)" }).Substring(29)
            $This.Authentication         = ($Select | ? { $_ -match "(^\s+Authentication\s+\:)" }).Substring(29)
            $This.Cipher                 = ($Select | ? { $_ -match "(^\s+Cipher\s+\:)" }).Substring(29)
            $This.Connection             = ($Select | ? { $_ -match "(^\s+Connection mode\s+\:)" }).Substring(29)
            $This.Band                   = ($Select | ? { $_ -match "(^\s+Band\s+\:)" }).Substring(29)
            $This.Channel                = ($Select | ? { $_ -match "(^\s+Channel\s+\:)" }).Substring(29)
            $This.Receive                = ($Select | ? { $_ -match "(^\s+Receive rate \(Mbps\)\s+\:)" }).Substring(29)
            $This.Transmit               = ($Select | ? { $_ -match "(^\s+Transmit rate \(Mbps\)\s+\:)" }).Substring(29)
            $This.Signal                 = ($Select | ? { $_ -match "(^\s+Signal\s+\:)" }).Substring(29)
            $This.Profile                = ($Select | ? { $_ -match "(^\s+Profile\s+\:)" }).Substring(29)
        }
    }

    Class Wireless
    {
        [Object] $Adapters
        [Object] $Request
        [Object] $Radios
        [Object] $List
        [Object] $Output
        [Object] $Connected
        Wireless()
        {
            # Get access to any wireless adapters
            $This.Adapters = Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)"

            # Requesting Radio Access
            $This.Request = (Get-AsTaskGeneric).MakeGenericMethod([Windows.Devices.Radios.RadioAccessStatus]).Invoke($null, @([Windows.Devices.Radios.Radio]::RequestAccessAsync()))
            $This.Request.Wait(-1) | Out-Null
            If ($This.Request.Result -ne "Allowed")
            {
                Throw "Unable to request radio access"
            }

            $This.Radios = (Get-AsTaskGeneric).MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]).Invoke($null, @([Windows.Devices.Radios.Radio]::GetRadiosAsync()))
            $This.Radios.Wait(-1) | Out-Null

            # Radios Async
            If (!($This.Radios.Result | ? Kind -eq WiFi))
            {
                Throw "Unable to synchronize wireless radio(s)"
            }
            Else
            {
                Write-Host "Wi-Fi [+] found, proceeding"
            }

            $This.List   = @( )
            $This.Output = @( )
            $This.Scan()
        }
        Scan()
        {
            $This.Output = @( ) 

            [Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime] | Out-Null
            $This.List   = (Get-AsTaskGeneric).MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]]).Invoke($null, @([Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync()))
            $This.List.Wait(-1) | Out-Null
            $This.List.Result

            $This.List.Result.NetworkReport.AvailableNetworks | % {

                $This.Output += [TxSsid]::New($This.Output.Count,$_) 
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
                    Write-Host "No networks detected"
                }
            }
        }
        Refresh()
        {
            $This.Scan()
        }
        [String] NewProfile([Object]$Interface,[String]$SSID,[String]$Key)
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

            Set-Content -Path ".\$($Interface.Name)-$SSID.xml" -Value $Value
            Return ".\$($Interface.Name)-$SSID.xml"
        }
        [Object] Query([Object]$Interface)
        {
            Return ((netsh wlan show interface $Interface.GUID) -match "^\s+State\s+\:").Substring(29)
        }
        Disconnect([Object]$Interface)
        {
            If ($This.Query($Interface) -ne "disconnected")
            {
                $Attempt = netsh wlan disconnect $Interface.Name
            }
        }
        Connect([String]$SSID,[Object]$Interface)
        {
            If ($This.Query($Interface) -ne "connected")
            {
                $Attempt = netsh wlan connect $ssid $Interface.Name
                If ($Attempt -match "no profile")
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
                            $path    = $Wifi.NewProfile($Interface,$SSID,$Pass.IO.Passphrase.Password)
                            netsh wlan add profile filename="$path"
                            $Attempt = netsh wlan connect $ssid $Interface.Name
                            $Pass.IO.DialogResult = $True
                        }
                    })
                    $Pass.IO.Cancel.Add_Click(
                    {
                        $Pass.IO.DialogResult = $False
                    })
                    $Pass.Invoke()
                }
            }
        }
        Update()
        {
            $This.Connected = Switch -Regex (((netsh wlan show interface) -match "(\s+State\s+\:)").Substring(29))
            {
                ^connected$ { [WLANInterface]::New((netsh wlan show interface)) } ^disconnected$ { $Null }
            }
        }
    }

    $Xaml = [XamlWindow][GUI]::Tab
    $Wifi = [Wireless]::New()

    If ($Wifi.Adapters.Count -eq 0)
    {
        Throw "No existing wireless adapters on this system"
    }

    ForEach ($Adapter in $Wifi.Adapters)
    {
        $Xaml.IO.Interface.Items.Add($Adapter.InterfaceDescription)
        # Will need to get this working for multiple WLAN adapters...
        If ($Adapter | ? Status -eq Up)
        {
            $Wifi.Update() 
        }
    }

    $Xaml.IO.SSID.Text            = If ($Wifi.Connected) { $Wifi.Connected.Ssid  } Else { $Null }
    $Xaml.IO.BSSID.Text           = If ($Wifi.Connected) { $Wifi.Connected.Bssid } Else { $Null }
    $Xaml.IO.Disconnect.IsEnabled = If ($Wifi.Connected) { 1 } Else { 0 }

    $Xaml.IO.Output.Add_SelectionChanged(
    {
        If ($Xaml.IO.Output.SelectedIndex -gt -1)
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
        If ($Xaml.IO.Output.SelectedIndex -eq -1)
        {
            $Xaml.IO.Connect.IsEnabled        = 0
        }
    })

    $Xaml.IO.Interface.Add_SelectionChanged(
    {
        If ($Xaml.IO.Interface.SelectedIndex -gt -1)
        {
            $Adapter                   = $Wifi.Adapters  | ? InterfaceDescription -eq $Xaml.IO.Interface.SelectedItem
            $Xaml.IO.Index.Text        = $Adapter.InterfaceIndex
            $Xaml.IO.MacAddress.Text   = $Adapter.MacAddress -Replace "-",":"
        }
        If ($Xaml.IO.Interface.SelectedIndex -eq -1)
        {
            $Xaml.IO.Index.Text        = $Null
            $Xaml.IO.MacAddress.Text   = $Null
        }
    })

    $Xaml.IO.Interface.SelectedIndex   = 0
    $Xaml.IO.Refresh.Add_Click(
    {
        $Xaml.IO.Output.Items.Clear()
        Start-Sleep -Milliseconds 150
        $Wifi.Scan()
        Write-Progress -Activity Scanning -Status Starting -PercentComplete 0  

        $C = 0
        $Wifi.Output | % { 
            
            Write-Progress -Activity Scanning -Status "($C/$($Wifi.Output.Count-1)" -PercentComplete ([long]($C * 100 / $Wifi.Output.Count))
            $Xaml.IO.Output.Items.Add($_) 
            $C ++
        }

        Write-Progress -Activity Scanning -Status Complete -Completed
        Start-Sleep -Milliseconds 50

        If ($Xaml.IO.Filter.Text -ne "")
        {
            $Wifi.Output | ? $Xaml.IO.Type.SelectedItem.Content -match $Xaml.IO.Filter.Text | % { $Xaml.IO.Output.Items.Add($_) }
        }
    })

    $Xaml.IO.Filter.Add_TextChanged(
    {
        Start-Sleep -Milliseconds 50
        $Xaml.IO.Output.Items.Clear()
        If ($Xaml.IO.Filter.Text -ne "" -and $Wifi.Output.Count -gt 0)
        {
            $Wifi.Output | ? $Xaml.IO.Type.SelectedItem.Content -match $Xaml.IO.Filter.Text | % { $Xaml.IO.Output.Items.Add($_) }
        }
        If ($Xaml.IO.Filter.Text -eq "" -and $Wifi.Output.Count -gt 0)
        {
            $Wifi.Output | % { $Xaml.IO.Output.Items.Add($_) }
        }
    })
    $Xaml.IO.Disconnect.Add_Click(
    {
        If ($Xaml.IO.Interface.SelectedItem -gt -1)
        {
            $Interface = $Wifi.Adapters | ? InterfaceDescription -eq $Xaml.IO.Interface.SelectedItem
            $Wifi.Disconnect($Interface)
            $Xaml.IO.Disconnect.IsEnabled = 0
            $Xaml.IO.Connect.IsEnabled    = 0
        }
    })
    $Xaml.IO.Connect.Add_Click(
    {
        If ($Xaml.IO.Interface.SelectedIndex -gt -1 -and $Xaml.IO.Output.SelectedIndex -gt -1)
        {
            $Interface = $Wifi.Adapters | ? InterfaceDescription -eq $Xaml.IO.Interface.SelectedItem
            $SSID      = $Xaml.IO.Output.SelectedItem.Name
            $Wifi.Connect($SSID,$Interface)
            $Xaml.IO.Connect.IsEnabled    = 0
            $Xaml.IO.Disconnect.IsEnabled = 1
        }
    })
    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })

    $Xaml.Invoke()
}
