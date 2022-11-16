<#
.SYNOPSIS
        Allows for the management of wireless networks from a PowerShell based graphical user interface.
.DESCRIPTION
        After seeing various scripts on the internet related to wireless network management, I decided
        to build a graphical user interface that is able to 1) scan for wirelss networks, 2) create profiles,
        and 3) handle everything from the GUI. Still workin' on it... but- I imagine this will probably be
        pretty fun to learn from.
.LINK
          Inspiration:   https://www.reddit.com/r/sysadmin/comments/9az53e/need_help_controlling_wifi/
          Also: jcwalker https://github.com/jcwalker/WiFiProfileManagement/blob/dev/Classes/AddNativeWiFiFunctions.ps1
                jcwalker wrote most of the C# code, I have implemented it and edited his original code, as parsing
                the output of netsh just wasn't my cup of tea... 
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Search-WirelessNetwork.ps1                                                               //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : For scanning wireless networks (eventually for use in a PXE environment).                //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-15                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                   ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-15-2022 13:49:19    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Search-WirelessNetwork
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode)

    # // _____________________________________________________________________________________________________________
    # // | ## | Type  | Name                   | Description                                                         |
    # // |----|-------|------------------------|---------------------------------------------------------------------|
    # // |  0 | Class | WirelessNetworkXaml    | Main GUI/Xaml string                                                |
    # // |  1 | Class | PassphraseXaml         | Passphrase GUI/Xaml                                                 |
    # // |  2 | Class | XamlProperty           | Used to index/catalog the Xaml control objects                      |
    # // |  3 | Class | XamlWindow             | Constructs the XamlWindow object                                    |
    # // |  4 | Enum  | PhysicalType           | Enum for an SSID's physical network type                            |
    # // |  5 | Class | PhysicalSlot           | Object for an SSID's physical network type                          |
    # // |  6 | Class | PhysicalList           | A list of potential SSID physical network types                     |
    # // |  7 | Enum  | AuthenticationType     | Enum for an SSID's authentication type                              |
    # // |  8 | Class | AuthenticationSlot     | Object for an SSID's authentication type                            |
    # // |  9 | Class | AuthenticationList     | A list of potential SSID's authentication types                     |
    # // | 10 | Enum  | EncryptionType         | Enum for an SSID's encryption type                                  |
    # // | 11 | Class | EncryptionSlot         | Object for an SSID's encryption type                                |
    # // | 12 | Class | EncryptionList         | A list of potential SSID's encryption types                         | 
    # // | 13 | Class | SsidSubcontroller      | Subcontroller for Ssid information injection                        |
    # // | 14 | Class | Ssid                   | Representation of each SSID collected by the wireless radio(s)      |
    # // | 15 | Class | WiFiProfile            | Handles the profile objects                                         |
    # // | 16 | Class | InterfaceObject        | Represents an individual wireless interface on the host             |
    # // | 17 | Class | WlanInterface          | Parses WLAN adapter information returned from the netsh             |
    # // | 18 | Class | RtMethod               | Specifically for selecting/filtering a Runtime IAsyncTask           |
    # // | 19 | Class | ConnectionModeResolver | Better than a hashtable                                             |
    # // | 20 | Class | Wireless               | Controller class for the function, this encapsulates the XAML/GUI   |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WirelessNetworkXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Wireless Network Scanner" Width="800" Height="650" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\icon.ico" FontFamily="Consolas" WindowStartupLocation="CenterScreen">',
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
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <Grid Margin="5">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="*"/>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="50"/>',
        '            </Grid.RowDefinitions>',
        '            <Grid Grid.Row="0">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="130"/>',
        '                    <ColumnDefinition Width="120"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="120"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label Grid.Column="0" Content="[Search/Filter]:"/>',
        '                <ComboBox Grid.Column="1" Name="Type" SelectedIndex="0">',
        '                    <ComboBoxItem Content="Name"/>',
        '                    <ComboBoxItem Content="Index"/>',
        '                    <ComboBoxItem Content="BSSID"/>',
        '                    <ComboBoxItem Content="Type"/>',
        '                    <ComboBoxItem Content="Encryption"/>',
        '                    <ComboBoxItem Content="Strength"/>',
        '                </ComboBox>',
        '                <TextBox Grid.Column="2" Name="Filter"/>',
        '                <Button Grid.Column="3" Content="Refresh" Name="Refresh"/>',
        '            </Grid>',
        '            <DataGrid Grid.Row="1" Grid.Column="0" Name="Output">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="#"  Width="25"  Binding="{Binding Index}"/>',
        '                    <DataGridTextColumn Header="Name"   Width="240" Binding="{Binding Name}"/>',
        '                    <DataGridTextColumn Header="Bssid"  Width="120" Binding="{Binding Bssid}"/>',
        '                    <DataGridTemplateColumn Header="Phy." Width="40">',
        '                        <DataGridTemplateColumn.CellTemplate>',
        '                            <DataTemplate>',
        '                                <ComboBox SelectedIndex="{Binding Physical.Index}" ToolTip="{Binding Physical.Description}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                    <ComboBoxItem Content="Unknown"/>',
        '                                    <ComboBoxItem Content="Fhss"/>',
        '                                    <ComboBoxItem Content="Dsss"/>',
        '                                    <ComboBoxItem Content="IRBaseband"/>',
        '                                    <ComboBoxItem Content="Ofdm"/>',
        '                                    <ComboBoxItem Content="Hrdsss"/>',
        '                                    <ComboBoxItem Content="Erp"/>',
        '                                    <ComboBoxItem Content="HT"/>',
        '                                    <ComboBoxItem Content="Vht"/>',
        '                                    <ComboBoxItem Content="Dmg"/>',
        '                                    <ComboBoxItem Content="HE"/>',
        '                                </ComboBox>',
        '                            </DataTemplate>',
        '                        </DataGridTemplateColumn.CellTemplate>',
        '                    </DataGridTemplateColumn>',
        '                    <DataGridTextColumn Header="Uptime" Width="100" Binding="{Binding Uptime}"/>',
        '                    <DataGridTemplateColumn Header="Auth." Width="60">',
        '                        <DataGridTemplateColumn.CellTemplate>',
        '                            <DataTemplate>',
        '                                <ComboBox SelectedIndex="{Binding Authentication.Index}"  ToolTip="{Binding Authentication.Description}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                    <ComboBoxItem Content="None"/>',
        '                                    <ComboBoxItem Content="Unknown"/>',
        '                                    <ComboBoxItem Content="Open80211"/>',
        '                                    <ComboBoxItem Content="SharedKey80211"/>',
        '                                    <ComboBoxItem Content="Wpa"/>',
        '                                    <ComboBoxItem Content="WpaPsk"/>',
        '                                    <ComboBoxItem Content="WpaNone"/>',
        '                                    <ComboBoxItem Content="Rsna"/>',
        '                                    <ComboBoxItem Content="RsnaPsk"/>',
        '                                    <ComboBoxItem Content="Ihv"/>',
        '                                    <ComboBoxItem Content="Wpa3Enterprise192Bits"/>',
        '                                    <ComboBoxItem Content="Wpa3Sae"/>',
        '                                    <ComboBoxItem Content="Owe"/>',
        '                                    <ComboBoxItem Content="Wpa3Enterprise"/>',
        '                                </ComboBox>',
        '                            </DataTemplate>',
        '                        </DataGridTemplateColumn.CellTemplate>',
        '                    </DataGridTemplateColumn>',
        '                    <DataGridTemplateColumn Header="Enc." Width="60">',
        '                        <DataGridTemplateColumn.CellTemplate>',
        '                            <DataTemplate>',
        '                                <ComboBox SelectedIndex="{Binding Encryption.Index}" ToolTip="{Binding Encryption.Description}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                    <ComboBoxItem Content="None"/>',
        '                                    <ComboBoxItem Content="Unknown"/>',
        '                                    <ComboBoxItem Content="Wep"/>',
        '                                    <ComboBoxItem Content="Wep40"/>',
        '                                    <ComboBoxItem Content="Wep104"/>',
        '                                    <ComboBoxItem Content="Tkip"/>',
        '                                    <ComboBoxItem Content="Ccmp"/>',
        '                                    <ComboBoxItem Content="WpaUseGroup"/>',
        '                                    <ComboBoxItem Content="RsnUseGroup"/>',
        '                                    <ComboBoxItem Content="Ihv"/>',
        '                                    <ComboBoxItem Content="Gcmp"/>',
        '                                    <ComboBoxItem Content="Gcmp256"/>',
        '                                </ComboBox>',
        '                            </DataTemplate>',
        '                        </DataGridTemplateColumn.CellTemplate>',
        '                    </DataGridTemplateColumn>',
        '                    <DataGridTemplateColumn Header="Str." Width="40">',
        '                        <DataGridTemplateColumn.CellTemplate>',
        '                            <DataTemplate>',
        '                                <ComboBox SelectedIndex="{Binding Strength}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                    <ComboBoxItem Content="0"/>',
        '                                    <ComboBoxItem Content="1"/>',
        '                                    <ComboBoxItem Content="2"/>',
        '                                    <ComboBoxItem Content="3"/>',
        '                                    <ComboBoxItem Content="4"/>',
        '                                    <ComboBoxItem Content="5"/>',
        '                                </ComboBox>',
        '                            </DataTemplate>',
        '                        </DataGridTemplateColumn.CellTemplate>',
        '                    </DataGridTemplateColumn>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '            <Grid Grid.Row="2">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="105"/>',
        '                    <ColumnDefinition Width="300"/>',
        '                    <ColumnDefinition Width="110"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="75"/>',
        '                    <ColumnDefinition Width="40"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label Grid.Column="0" Content="[Interface]:"/>',
        '                <ComboBox Grid.Column="1" Name="Interface"/>',
        '                <Label Grid.Column="2" Content="[MacAddress]:"/>',
        '                <TextBox Grid.Column="3" Name="MacAddress" IsReadOnly="True"/>',
        '                <Label Grid.Column="4" Content="[Index]:"/>',
        '                <TextBox Grid.Column="5" Name="Index" IsReadOnly="True"/>',
        '            </Grid>',
        '            <Grid Grid.Row="3">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="105"/>',
        '                    <ColumnDefinition Width="300"/>',
        '                    <ColumnDefinition Width="110"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label Grid.Column="0" Content="[SSID/Name]:"/>',
        '                <TextBox Grid.Column="1" Name="SSID" IsReadOnly="True"/>',
        '                <Label Grid.Column="2" Content="[BSSID]:"/>',
        '                <TextBox Grid.Column="3" Name="BSSID" IsReadOnly="True"/>',
        '            </Grid>',
        '            <Grid Grid.Row="4">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Button Grid.Row="1" Grid.Column="0" Name="Connect"    Content="Connect"    IsEnabled="False"/>',
        '                <Button Grid.Row="1" Grid.Column="1" Name="Disconnect" Content="Disconnect" IsEnabled="False"/>',
        '                <Button Grid.Row="1" Grid.Column="2" Name="Cancel"     Content="Cancel"/>',
        '            </Grid>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }
    
    Class PassphraseXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Enter Passphrase" Width="400" Height="160" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\background.jpg"/>',
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

    Class XamlProperty
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Type
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
    
    Enum PhysicalType
    {
        Unknown
        Fhss
        Dsss
        IRBaseband
        Ofdm
        Hrdsss
        Erp
        HT
        Vht
        Dmg
        HE
    }
    
    Class PhysicalSlot
    {
        [UInt32]         $Index
        [String]          $Type
        [String[]] $Description
        PhysicalSlot([String]$Type)
        {
            $This.Type        = [PhysicalType]::$Type
            $This.Index       = [UInt32][PhysicalType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }
    
    Class PhysicalList
    {
        [Object] $Output
        PhysicalList()
        {
            $This.Output = @( ) 
            [System.Enum]::GetNames([PhysicalType]) | % { $This.Add($_) }
        }
        Add([String]$Name)
        {
            $Item             = [PhysicalSlot]::New($Name)
            $Item.Description = Switch ($Name)
            {
                Unknown     { "Unspecified physical type"                      }
                Fhss        { "(FHSS/Frequency-Hopping Spread-Spectrum)"       }
                Dsss        { "(DSSS/Direct Sequence Spread-Spectrum)"         }
                IRBaseband  { "(IR/Infrared baseband)"                         }
                Ofdm        { "(OFDM/Orthogonal Frequency Division Multiplex)" }
                Hrdsss      { "(HRDSSS/High-rated DSSS)"                       }
                Erp         { "(ERP/Extended Rate)"                            }
                HT          { "(HT/High Throughput [802.11n])"                 }
                Vht         { "(VHT/Very High Throughput [802.11ac])"          }
                Dmg         { "(DMG/Directional Multi-Gigabit [802.11ad])"     }
                HE          { "(HEW/High-Efficiency Wireless [802.11ax])"      }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][PhysicalType]::$Type]
        }
    }
    
    Enum AuthenticationType
    {
        None
        Unknown
        Open80211
        SharedKey80211
        Wpa
        WpaPsk
        WpaNone
        Rsna
        RsnaPsk
        Ihv
        Wpa3
        Wpa3Sae
        Owe
        Wpa3Enterprise
    }
    
    Class AuthenticationSlot
    {
        [UInt32]         $Index
        [String]          $Type
        [String[]] $Description
        AuthenticationSlot([String]$xType)
        {
            If ($xType -eq "Wpa3Enterprise192Bits")
            {
                $xType = "Wpa3"
            }
            $This.Type        = [AuthenticationType]::$xType
            $This.Index       = [UInt32][AuthenticationType]::$xType
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }
    
    Class AuthenticationList
    {
        [Object] $Output
        AuthenticationList()
        {
            $This.Output  = @( )
            [System.Enum]::GetNames([AuthenticationType]) | % { $This.Add($_) }
        }
        Add([String]$Type)
        {
            $Item             = [AuthenticationSlot]::New($_)
            $Item.Description = Switch -Regex ($Item.Type)
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
                    "Cipher keys are dynamically derived through the auth. process."
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
                    "SAE provides: synchronous authentication, and stronger protections for users against",
                    "password-guessing attempts by third parties."
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
                    "WPA3-Enterprise uses IEEE 802.1X in a similar way as (RSNA/Robust Security Network Association).",
                    "However, it provides increased security through the use of mandatory certificate validation and protected management frames."
                }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][AuthenticationType]::$Type]
        }
    }
    
    Enum EncryptionType
    {
        None
        Unknown
        Wep
        Wep40
        Wep104
        Tkip
        Ccmp
        WpaUseGroup
        RsnUseGroup
        Ihv
        Gcmp
        Gcmp256
    }
    
    Class EncryptionSlot
    {
        [UInt32]         $Index
        [String]          $Type
        [String[]] $Description
        EncryptionSlot([String]$Type)
        {
            $This.Type  = [EncryptionType]::$Type
            $This.Index = [UInt32][EncryptionType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }
    
    Class EncryptionList
    {
        [Object] $Output
        EncryptionList()
        {
            $This.Output = @( )
            [System.Enum]::GetNames([EncryptionType]) | % { $This.Add($_) }
        }
        Add([String]$Type)
        {
            $Item             = [EncryptionSlot]::New($Type)
            $Item.Description = Switch ($Item.Type)
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
            $This.Output     += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][EncryptionType]::$Type]
        }
    }
    
    Class SsidSubcontroller
    {
        [Object] $Physical
        [Object] $Authentication
        [Object] $Encryption
        SsidSubcontroller()
        {
            $This.Physical       = [PhysicalList]::New()
            $This.Authentication = [AuthenticationList]::New()
            $This.Encryption     = [EncryptionList]::New()
        }
        Load([Object]$Ssid)
        {
            $Ssid.Physical       = $This.Physical.Get($Ssid.Ssid.PhyKind)
            $Ssid.Uptime         = $This.GetUptime($Ssid.Ssid.Uptime)
            $Ssid.Authentication = $This.Authentication.Get($Ssid.Ssid.SecuritySettings.NetworkAuthenticationType)
            $Ssid.Encryption     = $This.Encryption.Get($Ssid.Ssid.SecuritySettings.NetworkEncryptionType)
        }
        [String] GetUptime([Object]$Uptime)
        {
            Return @( Switch ($Uptime)
            {
                {$_.Days -gt 0}
                {
                    $Uptime | % { "{0}d {1}h {2}m {3}s" -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds }
                }
                {$_.Days -eq 0 -and $_.Hours -gt 0}
                {
                    $Uptime | % { "{0}h {1}m {2}s" -f $_.Hours, $_.Minutes, $_.Seconds }
                }
                {$_.Hours -eq 0 -and $_.Seconds -gt 0}
                {
                    $Uptime | % { "{0}m {1}s" -f $_.Minutes, $_.Seconds }
                }
            })
        }
    }
    
    Class Ssid
    {
        [UInt32]            $Index
        Hidden [Object]      $Ssid
        [String]             $Name
        [Object]            $Bssid
        [Object]         $Physical
        [Object]          $Network
        [Object]           $Uptime
        [Object]   $Authentication
        [Object]       $Encryption
        [UInt32]         $Strength
        [String]   $BeaconInterval
        [Double] $ChannelFrequency
        [Bool]       $IsWifiDirect
        Ssid([UInt32]$Index,[Object]$Object)
        {
            $This.Index              = $Index
            $This.Ssid               = $Object
            $This.Name               = If (!$Object.Ssid) { "<Hidden>" } Else { $Object.Ssid }
            $This.Bssid              = $Object.Bssid.ToUpper()
            $This.Network            = $Object.NetworkKind
            $This.Strength           = $Object.SignalBars
            $This.BeaconInterval     = $Object.BeaconInterval
            $This.ChannelFrequency   = $Object.ChannelCenterFrequencyInKilohertz
            $This.IsWiFiDirect       = $Object.IsWiFiDirect
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    Class WiFiProfile
    {
        [Object] $Interface
        [String] $Name
        [String] $Flags
        [Object] $Detail
        WiFiProfile([Object]$Interface,[Object]$ProfileInfo)
        {
            $This.Interface = $Interface
            $This.Name      = $ProfileInfo.strProfileName
            $This.Flags     = $ProfileInfo.ProfileFlags
            $This.Detail    = $Null
        }
        [String[]] ToString()
        {
            Return @(
            " ",
            "Interface       : $($This.Interface.Name)",
            "Guid            : $($This.Interface.Guid)",
            "Description     : $($This.Interface.Description)",
            "IfIndex         : $($This.Interface.ifIndex)",
            "Status          : $($This.Interface.Status)",
            "MacAddress      : $($This.Interface.MacAddress)",
            "LinkSpeed       : $($This.Interface.LinkSpeed)",
            "State           : $($This.Interface.State)",
            "----"
            "SSID            : $($This.Name)",
            "Flags           : $($This.Flags)",
            "ProfileName     : $($This.Detail.ProfileName)",
            "ConnectionMode  : $($This.Detail.ConnectionMode)",
            "Authentication  : $($This.Detail.Authentication)",
            "Encryption      : $($This.Detail.Encryption)",
            "Password        : $($This.Detail.Password)",
            "HiddenSSID      : $($This.Detail.ConnectHiddenSSID)",
            "EAPType         : $($This.Detail.EAPType)",
            "ServerNames     : $($This.Detail.ServerNames)",
            "TrustedRootCA   : $($This.Detail.TrustedRootCA)",
            "----",
            "XML             : $($This.Detail.Xml)",
            " "
            )
        }
    }
    
    Class InterfaceObject
    {
        [String] $Name
        [String] $Guid
        [String] $Description
        [UInt32] $ifIndex 
        [String] $Status
        [String] $MacAddress
        [String] $LinkSpeed
        [String] $State
        InterfaceObject([Object]$Info,[Object]$Interface)
        {
            $This.Name        = $Interface.Name
            $This.Guid        = $Info.Guid
            $This.Description = $Info.Description
            $This.ifIndex     = $Interface.ifIndex
            $This.Status      = $Interface.Status
            $This.MacAddress  = $Interface.MacAddress.Replace("-",":")
            $This.LinkSpeed   = $Interface.LinkSpeed
            $This.State       = $Info.State
        }
    }
    
    Class WlanInterface
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
        WlanInterface([String[]]$Select)
        {
            $This.Select                 = $Select
            $This.Name                   = $This.Find("Name")
            $This.Description            = $This.Find("Description")
            $This.GUID                   = $This.Find("GUID")
            $This.MacAddress             = $This.Find("Physical address")
            $This.InterfaceType          = $This.Find("Interface type")
            $This.State                  = $This.Find("State")
            $This.Ssid                   = $This.Find("SSID")
            $This.Bssid                  = $This.Find("BSSID") | % ToUpper
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
    
    Class RtMethod
    {
        [String] $Name
        [Object] $Params
        [Object] $Count
        [Object] $Object
        RtMethod([Object]$Object)
        {
            $This.Object = $Object
            $This.Params = $Object.GetParameters()
            $This.Count  = $This.Params.Count
            $This.Name   = $This.Params[0].ParameterType.Name
        }
    }
    
    Class ConnectionModeResolver
    {
        [String] $Profile           = "WLAN_CONNECTION_MODE_PROFILE"
        [String] $TemporaryProfile  = "WLAN_CONNECTION_MODE_TEMPORARY_PROFILE"
        [String] $DiscoverySecure   = "WLAN_CONNECTION_MODE_DISCOVERY_SECURE"
        [String] $Auto              = "WLAN_CONNECTION_MODE_AUTO"
        [String] $DiscoveryUnsecure = "WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE"
    }

    Class Wireless
    {
        Hidden [UInt32]    $Mode
        Hidden [Object]  $Module
        Hidden [String] $OEMLogo
        Hidden [Object]     $Sub
        Hidden [Object]    $Xaml
        [Object]       $Adapters
        [Object]        $Request
        [Object]         $Radios
        [Object]           $List
        [Object]         $Output
        [Object]       $Selected
        [Object]      $Connected
        [Object] GetWirelessNetworkXaml()
        {
            Return [XamlWindow][WirelessNetworkXaml]::Content
        }
        [Object] GetPassphraseXaml()
        {
            Return [XamlWindow][PassphraseXaml]::Content
        }
        [Object] GetSsidSubcontroller()
        {
            Return [SsidSubcontroller]::New()
        }
        [Object] Task()
        {
            Return [System.WindowsRuntimeSystemExtensions].GetMethods() | ? Name -eq AsTask | % { 

                [RtMethod]$_ 
            
            } | ? Count -eq 1 | ? Name -eq IAsyncOperation``1 | % Object
        }
        [Object] RxStatus()
        {
            Return [Windows.Devices.Radios.RadioAccessStatus]
        }
        [Object[]] RxAsync()
        {
            Return [Windows.Devices.Radios.Radio]::RequestAccessAsync()
        }
        [Object] RsList()
        {
            Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]
        }
        [Object[]] RsAsync()
        {
            Return [Windows.Devices.Radios.Radio]::GetRadiosAsync()
        }
        [Object] RaList()
        {
            Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]]
        }
        [Object[]] RaAsync()
        {
            Return [Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync()
        }
        [Object] RadioRequestAccess()
        {
            Return $This.Task().MakeGenericMethod($This.RxStatus()).Invoke($Null,$This.RxAsync())
        }        
        [Object] RadioSynchronization()
        {
            Return $This.Task().MakeGenericMethod($This.RsList()).Invoke($Null, $This.RsAsync())
        }
        [Object] RadioFindAllAdaptersAsync()
        {
            Return $This.Task().MakeGenericMethod($This.RaList()).Invoke($Null, $This.RaAsync())
        }
        [Object] NetshShowInterface([String]$Name)
        {
            Return [WlanInterface]::New((netsh wlan show interface $Name))
        }
        [String] Win32Exception([UInt32]$ReasonCode)
        {   
            Return [System.ComponentModel.Win32Exception]::New($ReasonCode)
        }
        [Object] WlanProfileInfoObject()
        {
            Return New-Object WiFi.ProfileManagement+ProfileInfo
        }
        [Object] WlanConnectionParams()
        {
            Return New-Object WiFi.ProfileManagement+WLAN_CONNECTION_PARAMETERS
        }
        [Object] WlanConnectionMode([String]$ConnectionMode)
        {   
            # [System.Enum]::GetNames([WiFi.ProfileManagement+WLAN_CONNECTION_MODE])
            # WLAN_CONNECTION_MODE_PROFILE
            # WLAN_CONNECTION_MODE_TEMPORARY_PROFILE 
            # WLAN_CONNECTION_MODE_DISCOVERY_SECURE  
            # WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE
            # WLAN_CONNECTION_MODE_AUTO
            # WLAN_CONNECTION_MODE_INVALID

            Return (New-Object WiFi.ProfileManagement+WLAN_CONNECTION_MODE)::$ConnectionMode
        }
        [Object] WlanDot11BssType([String]$Dot11BssType)
        {
            # [System.Enum]::GetNames([WiFi.ProfileManagement+DOT11_BSS_TYPE])
            # Infrastructure
            # Independent
            # Any

            Return (New-Object WiFi.ProfileManagement+DOT11_BSS_TYPE)::$Dot11BssType
        }
        [Object] WlanConnectionFlag([String]$Flag)
        {
            # [System.Enum]::GetNames([WiFi.ProfileManagement+WlanConnectionFlag])
            # Default
            # HiddenNetwork
            # AdhocJoinOnly
            # IgnorePrivacyBit
            # EapolPassThrough
            # PersistDiscoveryProfile
            # PersistDiscoveryProfileConnectionModeAuto
            # PersistDiscoveryProfileOverwriteExisting

            Return (New-Object WiFi.ProfileManagement+WlanConnectionFlag)::$Flag
        }
        [Object] WlanSetProfile([UInt32]$CH,[Guid]$IG,[UInt32]$F,[IntPtr]$PX,[IntPtr]$PS,
                                [Bool]$O,[IntPtr]$PR,[IntPtr]$pdw)
        {
            # // ___________________________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | F: Flags | PX: ProfileXml        |
            # // | PS: ProfileSecurity | O: Overwrite | PR: pReserved | PDW: pdwReasonCode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return (New-Object WiFi.ProfileManagement)::WlanSetProfile($CH,$IG,$F,$PX,$PS,$O,$PR,$PDW)
        }
        [Void] WlanDeleteProfile([IntPtr]$CH,[Guid]$IG,[String]$PN,[IntPtr]$PR)
        {
            # // __________________________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | PN: ProfileName | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            (New-Object WiFi.ProfileManagement)::WlanDeleteProfile($CH,$IG,$PN,$PR)
        }
        [Void] WlanDisconnect([IntPtr]$HCH,[Guid]$IG,[IntPtr]$PR)
        {
            # // __________________________________________________________
            # // | HCH: hClientHandle | IG: InterfaceGuid | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            (New-Object WiFi.ProfileManagement)::WlanDisconnect($HCH,$IG,$PR)
        }
        [Void] WlanConnect([IntPtr]$HCH,[Guid]$IG,[Object]$CP,[IntPtr]$PR)
        {
            # // _____________________________________________________________________________________
            # // | HCH: hClientHandle | IG: InterfaceGuid | CP: ConnectionParameters | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            (New-Object WiFi.ProfileManagement)::WlanConnect($HCH,$IG,$CP,$PR)
        }
        [String] WiFiReasonCode([IntPtr]$RC)
        {
            # // __________________
            # // | RC: ReasonCode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $SB          = [Text.StringBuilder]::New(1024)
            $Result      = (New-Object WiFi.ProfileManagement)::WlanReasonCodeToString(
                            $RC.ToInt32(),
                            $SB.Capacity,
                            $SB,
                            [IntPtr]::Zero)
            
            If ($Result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }
            
            Return $SB.ToString()
        }
        [IntPtr] NewWifiHandle()
        {
            # // ____________________________________________________________
            # // | MC: MaxClient | NV: NegotiatedVersion | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $MC       = 2
            [Ref] $NV = 0
            $Ch       = [IntPtr]::Zero
            $Result   = (New-Object WiFi.ProfileManagement)::WlanOpenHandle(
                         $Mc,
                         [IntPtr]::Zero,
                         $Nv,
                         [Ref]$Ch)
            
            If ($result -eq 0)
            {
                Return $CH
            }
            Else
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Void] RemoveWifiHandle([IntPtr]$ClientHandle)
        {
            $Result = (New-Object WiFi.ProfileManagement)::WlanCloseHandle(
                      $ClientHandle,
                      [IntPtr]::Zero)
            
            If ($Result -ne 0)
            {
                $Message = $This.Win32Exception($Result)
                Throw "$Message / $Result"
            }
        }
        [Object] GetWiFiInterfaceGuid([String]$WFAN)
        {
            # // _____________________________________________________________________
            # // | WFAN: WiFiAdapterName | IG: InterfaceGuid | WFAI: WiFiAdapterInfo |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $IG   = $Null
            Switch ([Environment]::OSVersion.Version -ge [Version]6.2)
            {
                $True
                {
                    $IG   = Get-NetAdapter -Name $WFAN -EA 0 | % InterfaceGuid
                }
                $False
                {
                    $WFAI = Get-WmiObject Win32_NetworkAdapter | ? NetConnectionID -eq $WFAN
                    $IG   = Get-WmiObject Win32_NetworkAdapterConfiguration | ? { 
            
                        $_.Description -eq $WFAI.Name | % SettingID
                    }
                }
            }
            
            Return [System.Guid]$IG
        }
        [Object[]] GetWiFiInterface()
        {
            # // _____________________________________________________________________________________
            # // | IL: InterfaceListPtr | CH: ClientHandle | WFIL: WiFiInterfaceList | IF: Interface |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $IL            = 0
            $CH            = $This.NewWiFiHandle()
            $This.Adapters = $This.RefreshAdapterList()
            $Return        = @( )
            Try
            {
                [Void] (New-Object WiFi.ProfileManagement)::WlanEnumInterfaces($CH,[IntPtr]::Zero,[Ref]$IL)
                $WFIL = New-Object WiFi.ProfileManagement+WLAN_INTERFACE_INFO_LIST $IL
                ForEach ($IF in $WFIL.wlanInterfaceInfo)
                {
                    $Info             = New-Object WiFi.ProfileManagement+WLAN_INTERFACE_INFO
                    $Info.Guid        = $IF.Guid
                    $Info.Description = $IF.Description
                    $Info.State       = $IF.State
                    $Interface        = $This.Adapters | ? InterfaceDescription -eq $Info.Description
                    $Return          += [InterfaceObject]::New($Info,$Interface)
                }
            }
            Catch
            {
                Write-Host "No wireless interface(s) found"
                $Return += $Null
            }
            Finally
            {
                $This.RemoveWiFiHandle($CH)
            }
            
            Return @($Return)
        }
        [Object[]] GetWiFiProfileList([String]$Name)
        {
            # // ________________________________________________________________________________
            # // | PLP: ProfileListPointer | IF: Interface | CH: ClientHandle | PL: ProfileList |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $PLP    = 0
            $IF     = $This.GetWifiInterface() | ? Name -match $Name
            $CH     = $This.NewWifiHandle()
            $Return = @( )
            
            (New-Object WiFi.ProfileManagement)::WlanGetProfileList($CH,$IF.GUID,[IntPtr]::Zero,[Ref]$PLP)
            
            $PL     = (New-Object WiFi.ProfileManagement+WLAN_PROFILE_INFO_LIST $PLP).ProfileInfo
            
            ForEach ($ProfileName in $PL)
            {
                $Item           = [WiFiProfile]::New($IF,$ProfileName)
                $Item.Detail    = $This.GetWiFiProfileInfo($Item.Name,$IF.Guid)
                $Return        += $Item
            }
            
            $This.RemoveWiFiHandle($CH)
            
            Return $Return
        }
        [Object] GetWiFiProfileInfo([String]$PN,[Guid]$IG,[Int16]$WPF)
        {
            # // __________________________________________________________________________________
            # // | PN: ProfileName | IG: InterfaceGuid | WPF: WlanProfileFlags | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [IntPtr]$CH              = $This.NewWifiHandle()
            $WlanProfileFlagsInput   = $WPF
            $Return                  = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($CH)
            Return $Return
        }
        [Object] GetWifiProfileInfo([String]$PN,[Guid]$IG)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | IG: InterfaceGuid | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [IntPtr]$CH            = $This.NewWifiHandle()
            $WlanProfileFlagsInput = 0
            $Return                = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($CH)
            Return $Return
        }
        [Object] WiFiProfileInfo([String]$PN,[Guid]$IG,[IntPtr]$CH,[Int16]$WPFI)
        {
            # // __________________________________________________________________________________
            # // | PN: ProfileName | IG: IntGuid | CH: ClientHandle | WPFI: WlanProfileFlagsInput |
            # // | PS: pstrProfileXml | WA: WlanAccess | WlanPF: WlanProfileFlags | PW: Password  | 
            # // | CHSSID: ConnectHiddenSSID | EAP: EapType | X: XmlPtr | SN: ServerNames         |
            # // | TRCA: TrustedRootCA | WP: WlanProfile                                          |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [String] $PS = $Null
            $WA          = 0
            $WlanPF      = $WPFI
            $Result      = (New-Object WiFi.ProfileManagement)::WlanGetProfile($CH,
                           $IG,$PN,[IntPtr]::Zero,[Ref]$PS,[Ref]$WlanPF,[Ref]$WA)
            $PW          = $Null
            $CHSSID      = $Null
            $Eap         = $Null
            $XmlPtr      = $Null
            $SN          = $Null
            $TRCA        = $Null
            $Return      = $Null
            
            If ($Result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }
            
            $WP          = [Xml]$PS
            
            # // __________________
            # // | Parse password |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($WPFI -eq 13)
            {
                $PW      = $WP.WlanProfile.Msm.Security.SharedKey.KeyMaterial
            }
            If ($WPFI -ne 13)
            {
                $PW            = $Null
            }
            
            # // ___________________________
            # // | Parse nonBroadcast flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ([Bool]::TryParse($WP.WlanProfile.SsidConfig.NonBroadcast,[Ref]$Null))
            {
                $CHSSID = [Bool]::Parse($WP.WlanProfile.SsidConfig.NonBroadcast)
            }
            Else
            {
                $CHSSID = $false
            }
            
            # // __________________
            # // | Parse EAP type |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($WP.WlanProfile.Msm.Security.AuthEncryption.UseOneX -eq $true)
            {
                $WP.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.EapMethod.Type.InnerText | % { 
            
                    $EAP   = Switch ($_) { 13 { 'TLS'  } 25 { 'PEAP' }  Default { 'Unknown' } }
                                            # 13: EAP-TLS | 25: EAP-PEAP (MSCHAPv2)
                }
            }
            Else
            {
                $EAP = $Null
            }
            
            # // ________________________________
            # // | Parse Validation Server Name |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If (!!$Eap)
            {
                $Cfg = $WP.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config 
                Switch ($Eap)
                {
                    PEAP
                    {
            
                        $SN   = $Cfg.Eap.EapType.ServerValidation.ServerNames
                    } 
            
                    TLS
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                        $SN   = $Node[0].InnerText
                    }
                }
            }
            
            # // __________________________________
            # // | Parse Validation TrustedRootCA |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If (!!$EAP)
            {
                $Cfg = $WP.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
                Switch ($EAP)
                {
                    PEAP
                    {
                        $TRCA = $Cfg.Eap.EapType.ServerValidation.TrustedRootCA.Replace(' ','') | % ToLower
                    }
                    TLS
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $TRCA = $Node[0].InnerText.Replace(' ','') | % ToLower
                    }
                }
            }
            
            $Return                   = $This.WlanProfileInfoObject()
            $Return.ProfileName       = $WP.WlanProfile.SsidConfig.Ssid.name
            $Return.ConnectionMode    = $WP.WlanProfile.ConnectionMode
            $Return.Authentication    = $WP.WlanProfile.Msm.Security.AuthEncryption.Authentication
            $Return.Encryption        = $WP.WlanProfile.Msm.Security.AuthEncryption.Encryption
            $Return.Password          = $PW
            $Return.ConnectHiddenSSID = $CHSSID
            $Return.EAPType           = $EAP
            $Return.ServerNames       = $SN
            $Return.TrustedRootCA     = $TRCA
            $Return.Xml               = $PS
            
            $XmlPtr                   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($PS)
            (New-Object WiFi.ProfileManagement)::WlanFreeMemory($XmlPtr)
            
            Return $Return
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
        {
            # // ____________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType | F: Flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return $This.WifiConnectionParameter($PN,$CM,$D,$F)
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return $This.WifiConnectionParameter($PN,$CM,$D,"Default")
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM)
        {
            # // ________________________________________
            # // | PN: ProfileName | CM: ConnectionMode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return $This.WifiConnectionParameter($PN,$CM,"Any","Default")
        }
        [Object] GetWiFiConnectionParameter([String]$PN)
        {
            # // ___________________
            # // | PN: ProfileName |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return $This.WifiConnectionParameter($PN,"Profile","Any","Default")
        }
        [Object] WifiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
            # // | F: Flag | CMR: ConnectionModeResolver | P: Profile     |
            # // | CP: ConnectionParameters                               |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Try
            {
                $CMR                   = [ConnectionModeResolver]::New()
            
                $CP                    = $This.WlanConnectionParams()
                $CP.StrProfile         = $PN
                $CP.WlanConnectionMode = $This.WlanConnectionMode($CMR[$CM])
                $CP.Dot11BssType       = $This.WlanDot11BssType($D)
                $CP.dwFlags            = $This.WlanConnectionFlag($F)
            }
            Catch
            {
                Throw "An error occurred while setting connection parameters"
            }
            
            Return $CP
        }
        [Object] FormatXml([Object]$Content)
        {
            $StringWriter          = [System.IO.StringWriter]::New()
            $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
            $XmlWriter.Formatting  = "Indented"
            $XmlWriter.Indentation = 4
            ([Xml]$Content).WriteContentTo($XmlWriter)
            $XmlWriter.Flush()
            $StringWriter.Flush()
            Return $StringWriter.ToString()
        }
        [Object] XmlTemplate([UInt32]$Type)
        {
            $xList = (0,"Personal"),(1,"EapPeap"),(2,"EapTls") | % { "($($_[0]): $($_[1]))" }
            
            If ($Type -notin 0..2)
            {
                Throw "Select a valid type: [$($xList -join ", ")]"
            }
            
            $P = "http://www.microsoft.com/provisioning"
            
            $xProfile = Switch ($Type)
            {
                0 # WiFiProfileXmlPersonal
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                    '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                    'uthentication>'),'<encryption>{4}</encryption>','<useOneX>false</useOneX>',('</authEncry'+
                    'ption>'),'<sharedKey>','<keyType>passPhrase</keyType>','<protected>false</protected>',
                    '<keyMaterial>{5}</keyMaterial>','</sharedKey>','</security>','</MSM>',('<MacRandomizatio'+
                    'n xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">'),('<enableRandomization>'+
                    'false</enableRandomization>'),"</MacRandomization>",'</WLANProfile>'
                }
                1 # WiFiProfileXmlEapPeap
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>',('</SSIDConfig>'),'<connectionType>ESS</connectionType>',('<connectionMo'+
                    'de>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}<'+
                    '/authentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncr'+
                    'yption>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMK'+
                    'CacheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http'+
                    '://www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPC'+
                    'onfig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapH"+
                    "ostConfig'>25</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns"+
                    "='$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMe'+
                    'thod>'),"<Config xmlns='$P/EapHostConfig'>",("<Eap xmlns='$P/BaseEapConnectionProperties"+
                    "V1'>"),'<Type>25</Type>',"<EapType xmlns='$P/MsPeapConnectionPropertiesV1'>",('<ServerVa'+
                    'lidation>'),('<DisableUserPromptForServerValidation>false</DisableUserPromptForServerVal'+
                    'idation>'),'<ServerNames></ServerNames>','<TrustedRootCA></TrustedRootCA>',('</ServerVal'+
                    'idation>'),'<FastReconnect>true</FastReconnect>',('<InnerEapOptional>false</InnerEapOpti'+
                    'onal>'),"<Eap xmlns='$P/BaseEapConnectionPropertiesV1'>",'<Type>26</Type>',("<EapType xm"+
                    "lns='$P/MsChapV2ConnectionPropertiesV1'>"),('<UseWinLogonCredentials>false</UseWinLogonC'+
                    'redentials>'),'</EapType>','</Eap>',('<EnableQuarantineChecks>false</EnableQuarantineChe'+
                    'cks>'),'<RequireCryptoBinding>false</RequireCryptoBinding>','<PeapExtensions>',("<Perfor"+
                    "mServerValidation xmlns='$P/MsPeapConnectionPropertiesV2'>true</PerformServerValidation>"+
                    ""),"<AcceptServerName xmlns='$P/MsPeapConnectionPropertiesV2'>true</AcceptServerName>",
                    "<PeapExtensionsV2 xmlns='$P/MsPeapConnectionPropertiesV2'>",("<AllowPromptingWhenServerC"+
                    "ANotFound xmlns='$P/MsPeapConnectionPropertiesV3'>true</AllowPromptingWhenServerCANotFou"+
                    "nd>"),'</PeapExtensionsV2>','</PeapExtensions>','</EapType>','</Eap>','</Config>',('</Ea'+
                    'pHostConfig>'),'</EAPConfig>','</OneX>','</security>','</MSM>',('<MacRandomization xmlns'+
                    '="http://www.microsoft.com/networking/WLAN/profile/v3">'),("<enableRandomization>false</"+
                    "enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
                }
                2 # WiFiProfileXmlEapTls
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                    '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                    'uthentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncryp'+
                    'tion>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMKCa'+
                    'cheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http:/'+
                    '/www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPCon'+
                    'fig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapHos"+
                    "tConfig'>13</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns='"+
                    "$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMeth'+
                    'od>'),("<Config xmlns:baseEap='$P/BaseEapConnectionPropertiesV1' xmlns:eapTls='$P/EapTls"+
                    "ConnectionPropertiesV1'>"),'<baseEap:Eap>','<baseEap:Type>13</baseEap:Type>',('<eapTls:E'+
                    'apType>'),'<eapTls:CredentialsSource>','<eapTls:CertificateStore />',('</eapTls:Credenti'+
                    'alsSource>'),'<eapTls:ServerValidation>',('<eapTls:DisableUserPromptForServerValidation>'+
                    'false</eapTls:DisableUserPromptForServerValidation>'),('<eapTls:ServerNames></eapTls:Ser'+
                    'verNames>'),'<eapTls:TrustedRootCA></eapTls:TrustedRootCA>','</eapTls:ServerValidation>',
                    '<eapTls:DifferentUsername>false</eapTls:DifferentUsername>','</eapTls:EapType>',('</base'+
                    'Eap:Eap>'),'</Config>','</EapHostConfig>','</EAPConfig>','</OneX>','</security>','</MSM>',
                    '<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',("<enabl"+
                    "eRandomization>false</enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
                }
            }
            
            Return $This.FormatXml($xProfile)
        }
        [String] Hex([String]$PN)
        {
            # // ___________________
            # // | PN: ProfileName |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return ([Char[]]$PN | % { '{0:X}' -f [Int]$_ }) -join ''
        }
        [String] NewWiFiProfileXmlPsk([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                    [SecureString]$PW)
        {
            # // ___________________________________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | PW: Password |
            # // | PP: PlainPassword | PX: ProfileXml | SS: SecureStringToBstr | RN: RefNode | XN: XmlNode | 
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $PP           = $Null
            $PX           = $Null
            $Hex          = $This.Hex($PN)
            Try
            {
                If ($PW)
                {
                    $SS   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PW)
                    $PW   = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SS)
                }
                
                $PX       = [XML]($This.XmlTemplate(0) -f $PN, $Hex, $CM, $A, $E, $PP)
                If (!$PP)
                {
                    $Null = $PX.WlanProfile.Msm.Security.RemoveChild($PX.WlanProfile.Msm.Security.SharedKey)
                }
            
                If ($A -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
                    $N  = [System.Xml.XmlNamespaceManager]::new($PX.NameTable)
                    $N.AddNamespace('WLANProfile',$PX.DocumentElement.GetAttribute('xmlns'))
                    $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                    $XN = $PX.CreateElement('transitionMode', 
                                            'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XN.InnerText = 'True'
                    $null         = $RN.AppendChild($XN)
                }
            
                Return $This.FormatXml($PX.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [String] NewWifiProfileXmlEap([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                    [String]$Eap,[String[]]$SN,[String]$TRCA)
        {
            # // ___________________________________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | EAP: EapType |
            # // | SN: ServerNames | TRCA: TrustedRootCa | PX: ProfileXml |  RN: RefNode | XN: XmlNode     | 
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $Px  = $Null
            $Hex = $This.Hex($PN)
            Try
            {
                If ($Eap -eq 'PEAP')
                {
                    $Px = [Xml]($This.XmlTemplate(1) -f $PN, $Hex, $CM, $A, $E)
                    $Cfg = $PX.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
            
                    If ($SN)
                    {
                        $Cfg.Eap.EapType.ServerValidation.ServerNames = $SN
                    }
            
                    If ($TRCA)
                    {
                        $Cfg.Eap.EapType.ServerValidation.TrustedRootCA = $TRCA.Replace('..','$& ')
                    }
                }
                ElseIf ($Eap -eq 'TLS')
                {
                    $PX  = [Xml]($This.XmlTemplate(2) -f $PN, $Hex, $CM, $A, $E)
                    $Cfg = $PX.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
            
                    If ($SN)
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                        $Node[0].InnerText = $SN
                    }
            
                    If ($TRCA)
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $Node[0].InnerText = $TRCA.Replace('..','$& ')
                    }
                }
            
                If ($A -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
                    $N = [System.Xml.XmlNamespaceManager]::New($PX.NameTable)
                    $N.AddNamespace('WLANProfile', $PX.DocumentElement.GetAttribute('xmlns'))
                    $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                    $XN = $PX.CreateElement('transitionMode', 
                                            'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XN.InnerText = 'true'
                    $null = $RN.AppendChild($XN)
                }
            
                Return $This.FormatXml($PX.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $CM = 'Auto'
            $A  = 'WPA2PSK'
            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$PW)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $A  = 'WPA2PSK'
            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$E,[String]$WFAN)
        {
            # // ___________________________________________________________________________
            # // | PN: ProfileName | PW: Password | CM: ConnectionMode | A: Authentication |
            # // | E: Encryption | WFAN: WiFiAdapterName | PT: ProfileTemp                 |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $PT     = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $CM   = 'Auto'
            $A    = 'WPA2PSK'
            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $A    = 'WPA2PSK'
            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                                [String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $TRCA     = $Null
            $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                                [String]$TRCA,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileXml([String]$PX,[String]$WFAN,[Bool]$O)
        {
            # // _________________________________________________________
            # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Return $This.NewWifiProfile($PX,$WFAN)
        }
        NewWifiProfile([String]$PX,[String]$WFAN,[Bool]$O)
        {
            # // _____________________________________________________________________________
            # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite | IG: InterfaceGuid |
            # // | CH: ClientHandle | F: Flags | PP: ProfilePointer                          |
            # // | RSC: ReasonCode | RSCM: ReasonCodeMessage                                 |
            # // | RTC: ReturnCode | RTCM: ReturnCodeMessage                                 |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Try
            {
                $IG   = $This.GetWiFiInterfaceGuid($WFAN)
                $CH   = $This.NewWiFiHandle()
                $F    = 0
                $RSC  = [IntPtr]::Zero
                $PP   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($PX)    
                $RTC  = $This.WlanSetProfile($CH,[Ref]$IG,$F,$PP,[IntPtr]::Zero,$O,[IntPtr]::Zero,[Ref]$RSC)
                $RTCM = $This.Win32Exception($RTC)
                $RSCM = $This.WiFiReasonCode($RSC)
            
                If ($RTC -eq 0)
                {
                    Write-Verbose -Message $RTCM
                }
                Else
                {
                    Throw $RTCM
                }
            
                Write-Verbose -Message $RSCM
            }
            Catch
            {
                Throw "Failed to create the profile"
            }
            Finally
            {
                If ($CH)
                {
                    $This.RemoveWiFiHandle($CH)
                }
            }
        }
        RemoveWifiProfile([String]$PN)
        {
            # // ______________________________________
            # // | PN: ProfileName | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $CH = $This.NewWiFiHandle()
            (New-Object WiFi.ProfileManagement)::WlanDeleteProfile($CH,[Ref]$This.Selected.Guid,$PN,[IntPtr]::Zero)
            $This.RemoveWifiHandle($CH)
        }
        Scan()
        {
            $This.List               = @( )
            $This.Output             = @( )
            
            [Void][Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime]
            $This.List               = $This.RadioFindAllAdaptersAsync()
            $This.List.Wait(-1) > $Null
            $This.List.Result
            
            $This.List.Result.NetworkReport.AvailableNetworks | % {
            
                $Item                = [Ssid]::New($This.Output.Count,$_)
                $This.Sub.Load($Item)
                $This.Output        += $Item
            }
            
            $This.Output             = $This.Output | Sort-Object Strength -Descending
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
        Wireless([UInt32]$Mode)
        {
            $This.Mode     = $Mode

            # // ____________________________
            # // | Load the module location |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Module   = Get-FEModule -Mode 1
            $This.OEMLogo  = $This.Module._Graphic("OEMLogo.bmp").Fullname

            # // _________________________________________
            # // | Load the wireless profile type/object |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Add-Type -Path $This.Module._Control("Wifi.cs").Fullname -ErrorAction Continue
            
            # // _______________________________
            # // | Load the Ssid Subcontroller |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Sub      = $This.GetSsidSubController()

            If ($This.Mode -eq 1)
            {
                $This.Xaml = $This.GetWirelessNetworkXaml()
            }
            
            $This.Refresh()
        }
        Refresh()
        {
            # // __________________________
            # // | Load the runtime types |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [Void][Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType=WindowsRuntime]
            [Void][Windows.Devices.Radios.RadioAccessStatus, Windows.System.Devices, ContentType=WindowsRuntime]
            [Void][Windows.Devices.Radios.RadioState, Windows.System.Devices, ContentType=WindowsRuntime]
            
            # // _______________________________________
            # // | Get access to any wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Adapters = $This.RefreshAdapterList()
            
            # // __________________________________________
            # // | Throw if no existing wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($This.Adapters.Count -eq 0)
            {
                Throw "No existing wireless adapters on this system"
            }

            If ($This.Mode -eq 1)
            {
                $This.Xaml.IO.Interface.Items.Clear()
                ForEach ($Adapter in $This.Adapters)
                {
                    $This.Xaml.IO.Interface.Items.Add($Adapter.InterfaceDescription)
                }
            }
            
            # // ___________________________
            # // | Requesting Radio Access |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Request = $This.RadioRequestAccess()
            $This.Request.Wait(-1) > $Null
            
            # // _______________________________________
            # // | Throw if unable to ascertain access |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($This.Request.Result -ne "Allowed")
            {
                Throw "Unable to request radio access"
            }
            
            # // ___________________________________
            # // | Establish radio synchronization |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Radios = $This.RadioSynchronization()
            $This.Radios.Wait(-1) > $Null
            
            # // _________________________________________
            # // | Throw if unable to synchronize radios |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If (!($This.Radios.Result | ? Kind -eq WiFi))
            {
                Throw "Unable to synchronize wireless radio(s)"
            }

            Start-Sleep -Milliseconds 150
            $This.Scan()
            
            If ($This.Mode -eq 1)
            {
                $This.Xaml.IO.Output.Items.Clear()
            }

            Write-Progress -Activity Scanning -Status Starting -PercentComplete 0  
            
            $C = 0
            $This.Output | % { 
            
                $Status  = "($C/$($This.Output.Count-1)"
                $Percent =  ([long]($C * 100 / $This.Output.Count))
            
                Write-Progress -Activity Scanning -Status $Status -PercentComplete $Percent
            
                $C ++
            }
            
            If ($This.Mode -eq 1)
            {
                ForEach ($Object in $This.Output)
                {
                    $This.Xaml.IO.Output.Items.Add($Object)
                }
            }
            Write-Progress -Activity Scanning -Status Complete -Completed
            Start-Sleep -Milliseconds 50
        }
        Select([String]$D)
        {
            # // __________________
            # // | D: Description |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            # // ___________________________________________
            # // | Select the adapter from its description |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Selected                      = $This.GetWifiInterface() | ? Description -eq $D
            
            # // _________________________
            # // | Set other Xaml fields |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Mode -gt 0)
            {
                $This.Xaml.IO.Index.Text        = $This.Selected.ifIndex
                $This.Xaml.IO.MacAddress.Text   = $This.Selected.MacAddress
            }

            $This.Update()
        }
        Unselect()
        {
            $This.Selected                      = $Null
            If ($This.Mode -gt 0)
            {
                $This.Xaml.IO.Index.Text        = $Null
                $This.Xaml.IO.MacAddress.Text   = $Null
            }

            $This.Update()
        }
        Update()
        {
            # // __________________________________
            # // | Determine/Set connection state |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Switch -Regex ($This.Selected.Status)
            {
                Up
                {
                    $This.Connected                        = $This.NetshShowInterface($This.Selected.Name)
                    If ($This.Mode -eq 1)
                    {
                        $This.Xaml.IO.Ssid.Text            = $This.Connected.Ssid
                        $This.Xaml.IO.Bssid.Text           = $This.Connected.Bssid
                        $This.Xaml.IO.Disconnect.IsEnabled = 1
                        $This.Xaml.IO.Connect.IsEnabled    = 0
                    }
                }
                Default
                {
                    $This.Connected                        = $Null
                    If ($This.Mode -eq 1)
                    {                    
                        $This.Xaml.IO.Ssid.Text            = "<Not connected>"
                        $This.Xaml.IO.Bssid.Text           = "<Not connected>"
                        $This.Xaml.IO.Disconnect.IsEnabled = 0
                        $This.Xaml.IO.Connect.IsEnabled    = 0
                    }
                }
            }
        }
        Disconnect()
        {
            If (!$This.Selected)
            {
                Write-Host "No network selected"
            }

            If ($This.Selected.State -eq "CONNECTED")
            {
                $CH                      = $This.NewWiFiHandle()
                $This.WlanDisconnect($CH,[Ref]$This.Selected.Guid,[IntPtr]::Zero)
                $This.RemoveWifiHandle($CH)
            
                $This.Connected                    = $Null
            
                $Splat                             = @{
            
                    Type    = "Image"
                    Mode    = 2
                    Image   = $This.OEMLogo
                    Message = "Disconnected: $($This.Selected.SSID)"
                }
            
                Show-ToastNotification @Splat
            
                $Link                              = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)
            }
        }
        Connect([Object]$Target)
        {
            If (!$This.Selected)
            {
                Write-Host "Must select an active interface"
            }
            
            If ($This.Selected)
            {
                $Link                              = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)
            
                If ($This.Selected.State -ne "CONNECTED")
                {
                    $Result    = $This.GetWifiProfileInfo($Target.Name,$This.Selected.Guid)
                    If ($Result)
                    {
                        $Param = $This.GetWiFiConnectionParameter($Target.Name)
                        $CH    = $This.NewWiFiHandle()
                        $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                        $This.RemoveWifiHandle($CH)
            
                        $Link   = $This.Selected.Description
                        $This.Unselect()
                        $This.Select($Link)
            
                        $This.Update()
            
                        $Splat                             = @{
            
                            Type    = "Image"
                            Mode    = 2
                            Image   = $This.OEMLogo
                            Message = "Connected: $($Target.Name)"
                        }
            
                        Show-ToastNotification @Splat
                    }
                    If (!$Result)
                    {
                        $Network = $This.Output.SelectedItem
                        If ($Network.Authentication -match "psk")
                        {
                            $This.Passphrase($Network)
                        }
                        Else
                        {
                            Write-Host "Eas/Peap not yet implemented"
                        }
                    }
                }
                If ($This.Selected.State -eq "CONNECTED")
                {
                    [System.Windows.MessageBox]::Show("Already connected to a network, disconnect first")
                }
            }
        }
        ShowToast([String]$Message)
        {
            $Splat = @{ 

                Type    = "Image"
                Mode    = 2
                Image   = $This.OEMLogo
                Message = $Message
            }

            Show-ToastNotification @Splat
        }
        Passphrase([Object]$Target)
        {
            $Auth      = $Null
            $Enc       = $Null

            If ($Target.Authentication -match "RsnaPsk")
            {
                $Auth  = "WPA2PSK"
            }
            If ($Target.Encryption -match "Ccmp")
            {
                $Enc   = "AES"
            }

            If ($This.Mode -eq 0)
            {
                $PW    = Read-Host -AsSecureString -Prompt "Enter passphrase for Network: [$($Target.SSID)]"

                $ProfileXml = $This.NewWifiProfileXmlPsk($Target.Name,"Manual",$Auth,$Enc,$PW)
                $This.NewWifiProfile($ProfileXml,$This.Selected.Name,$True)
                
                $Param = $This.GetWiFiConnectionParameter($Target.Name)
                $CH    = $This.NewWiFiHandle()
                $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                $This.RemoveWifiHandle($CH)
                
                Start-Sleep 3
                $Link  = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)
                
                $This.Update()
                Switch ([UInt32]!!$This.Connected)
                {
                    0 
                    { 
                        $This.ShowToast("Connected: $($Target.Name)") 
                    }
                    1 
                    { 
                        $This.RemoveWifiProfile($Target.Name)
                        $This.ShowToast("Unsuccessful: Passphrase failure")
                    }
                }
            }

            If ($This.Mode -eq 1)
            {
                $Pass    = $This.GetPassphraseXaml()
                $Pass.IO.Connect.Add_Click(
                {
                    If ($Target.Authentication -match "RsnaPsk")
                    {
                        $Auth      = "WPA2PSK"
                    }
                    If ($Target.Encryption -match "Ccmp")
                    {
                        $Enc       = "AES"
                    }

                    $Password      = $Pass.IO.Passphrase.Password
                    $PW            = $Password | ConvertTo-SecureString -AsPlainText -Force
                    $ProfileXml    = $This.NewWifiProfileXmlPsk($Network.Name,"manual",$Auth,$Enc,$PW)
                    $This.NewWifiProfile($ProfileXml,$Ctrl.Selected.Name,$True)
                        
                    $Param         = $This.GetWiFiConnectionParameter($Target.Name)
                    $ClientHandle  = $This.NewWiFiHandle()
                    $This.WlanConnect($ClientHandle,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                    $This.RemoveWifiHandle($ClientHandle)
    
                    Start-Sleep 3
                    $Link           = $This.Selected.Description
                    $This.Unselect()
                    $This.Select($Link)
    
                    $This.Update()
                    If ($This.Connected)
                    {
                        $Pass.IO.DialogResult = 1
                        $This.ShowToast("Connected: $($Target.Name)")
                    }
                    If (!$This.Connected)
                    {
                        $This.RemoveWifiProfile($Target.Name)
                        $This.ShowToast("Unsuccessful: Passphrase failure")
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
        [Object[]] RefreshAdapterList()
        {
            Return Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)"
        }
    }

    Switch ($Mode)
    {
        0
        {
            [Wireless]::New(0)
        }
        1
        {
            $Wifi = [Wireless]::New(1)

            # // __________________
            # // | Event Handlers |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Wifi.Xaml.IO.Interface.Add_SelectionChanged(
            {
                $Wifi.Select($Wifi.Xaml.IO.Interface.SelectedItem)
            })
        
            $Wifi.Xaml.IO.Output.Add_SelectionChanged(
            {
                If (!$Wifi.Connected)
                {
                    $Wifi.Xaml.IO.Disconnect.IsEnabled     = 0
        
                    If ($Wifi.Xaml.IO.Output.SelectedIndex -eq -1)
                    {
                        $Wifi.Xaml.IO.Connect.IsEnabled    = 0
                    }
        
                    If ($Wifi.Xaml.IO.Output.SelectedIndex -ne -1)
                    {
                        $Wifi.Xaml.IO.Connect.IsEnabled    = 1
                    }
                }
                If ($Wifi.Connected)
                {
                    $Wifi.Xaml.IO.Connect.IsEnabled        = 0
                    $Wifi.Xaml.IO.Disconnect.IsEnabled     = 1
                }
            })
        
            $Wifi.Xaml.IO.Refresh.Add_Click(
            {
                $Wifi.Refresh()
                $Wifi.SearchFilter()
            })
        
            $Wifi.Xaml.IO.Filter.Add_TextChanged(
            {
                $Wifi.SearchFilter()
            })
        
            $Wifi.Xaml.IO.Connect.Add_Click(
            {
                If (!$Wifi.Connected -and $Wifi.Xaml.IO.Output.SelectedIndex -ne -1)
                {
                    $Test = $Wifi.GetWifiProfileInfo($Wifi.Xaml.IO.Output.SelectedItem.Name,$Wifi.Selected.Guid)
                    If ($Test -notmatch "Element not found")
                    {
                        $Wifi.Connect($Wifi.Xaml.IO.Output.SelectedItem.Name)
                        $Count             = 0
                        Do
                        {
                            Start-Sleep 1
                            $Wifi.Adapters = $Wifi.RefreshAdapterList()
                            $Link          = $Wifi.Selected.Description
                            $Wifi.Unselect()
                            $Wifi.Select($Link)
                            $Wifi.Update()
                            $Count ++
                        }
                        Until ($Wifi.Connected -or $Count -gt 5)
        
                    }
                    If ($Test -match "Element not found")
                    {
                        $Network = $Wifi.Xaml.IO.Output.SelectedItem
                        $Wifi.Passphrase($Wifi,$Network)
                        $Wifi.Update()
                    }
                }
                If ($Wifi.Connected)
                {
                    $Wifi.Update()
                }
            })
        
            $Wifi.Xaml.IO.Disconnect.Add_Click(
            {
                If ($Wifi.Connected)
                {
                    $Wifi.Disconnect()
                    Do
                    {
                        Start-Sleep 1
                        $Wifi.Adapters = $Wifi.RefreshAdapterList()
                        $Link          = $Wifi.Selected.Description
                        $Wifi.Unselect()
                        $Wifi.Select($Link)
                        $Wifi.Update()
                    }
                    Until ($Wifi.Selected.State -eq "DISCONNECTED")
        
                    $Wifi.Refresh()
                }
                If (!$Wifi.Connect)
                {
                    $Wifi.Xaml.IO.Disconnect.IsEnabled = 0
                }
            })
        
            $Wifi.Xaml.IO.Cancel.Add_Click(
            {
                $Wifi.Xaml.IO.DialogResult = $False
            })
        
            $Wifi.Xaml.IO.Interface.SelectedIndex   = 0
        
            $Wifi.Xaml.Invoke()
        }
    }
}


<# Test Area


    $Target = $Wifi.Output[23]
    $Test   = $Wifi.GetWifiProfileInfo($Target.Name,$Wifi.Selected.Guid)
    Switch -Regex ($Test.GetType().Name)
    {
        ProfileInfo
        {
            $Wifi.Connect($Wifi.Xaml.IO.Output.SelectedItem.Name)
            $Count             = 0
            Do
            {
                Start-Sleep 1
                $Wifi.Adapters = $Wifi.RefreshAdapterList()
                $Link          = $Wifi.Selected.Description
                $Wifi.Unselect()
                $Wifi.Select($Link)
                $Wifi.Update()
                $Count ++
            }
            Until ($Wifi.Connected -or $Count -gt 5)
        }
        String
        {
            $Wifi.Passphrase($Target)
            $Wifi.Update()
        }
    }

#>
