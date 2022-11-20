<#
.SYNOPSIS

    Allows for the management of wireless adapters, profiles, and networks from the 
    (CLI/command line interface), or (GUI/graphical user interface) via PowerShell.

.DESCRIPTION

    After seeing various scripts on the internet related to [wireless network] 
    management, I decided to build a hybrid (CLI/GUI) utility that is able to:

    1) provide a detailed enumeration of [wireless network] adapter(s),
    2) (create/manage/view) [wireless network] profile(s),
    3) scan for [wireless network](s),
    4) (connect to/disconnect from) [wireless network](s) as well as password prompts,
    5) either from the (command line interface/CLI) (mode 0), 
    6) or from the (graphical user interface/GUI) (mode 1).

    [jcwalker] wrote most of the C# code that accesses the wlanapi.dll file, through a manner that 
    is similar to P/Invoke. I have implemented his original code (largely verbatim), by modifying 
    the signature with the correct namespace and class name, and it is written to:
    __________________________________________________________
    | $Module   = Get-FEModule -Mode 1                       |
    | $FilePath = $Module.File("Control","Wifi.cs").Fullname |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    The file and its definitions, are accessible via Add-Type $FilePath, which is implemented by 
    the control class, [WirelessController], at the tail end of this function. 
    
    The [WirelessController] class actually has many methods that I've written, as well as some of 
    the functions that jcwalker ALSO wrote, to interact with the classes in the type definition.
    
    Prior to working with the files that interact with wlanapi.dll, I was using I/O from netsh
    and parsing all of it, in order to write the prior version of this function. Wasn't really
    doing a good job at being wicked consistent, because then each output needed to be scoped
    and prepared for, and that's when I realized "This method sorta sucks..."

    Netsh itself is an incredibly (powerful/useful) tool, but- it is complicated.

    As for this particular (function/class), I've added a lot of other components to what 
    jcwalker did with his module referenced below, in his Github project.
    
    The FUNCTIONS written in that module, made more sense to convert to METHODS of a 
    (base/factory) class... especially if the (CLI/GUI) controls are doing the same exact thing
    in the code behind.
    
    So, it felt like it'd be a pretty good idea to capitalize on, as it would be incredibly
    useful in a PXE environment (pretty sure that System Center Configuration Manager has something
    that does that, already).

    As for the PXE environment, that is sorta what I wanted to expand upon and build new features 
    for, when I originally recorded this demonstration on 01/25/2019:
    _____________________________________________________________________
    | 2019_0125-(Computer Answers - MDT) | https://youtu.be/5Cyp3pqIMRs |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    THAT particular video showcases how I was originally working with Oracle VirtualBox, to use the 
    Microsoft Deployment Toolkit to deploy the Windows operating system installations over a network 
    that I (managed/configured) between (2017-2019), at:
    _____________________________________________________
    | Computer Answers | 1602 Route 9, Clifton Park, NY |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Since then, the idea of capitalizing on (PowerShell + Veridian) was my main focus.
    However, this utility is also pretty important.

.LINK
    ______________
    | References |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    [ALL_FRONT_RANDOM/Reddit]
    https://www.reddit.com/r/sysadmin/comments/9az53e/need_help_controlling_wifi
    
    [jcwalker/Github]
    https://github.com/jcwalker/WiFiProfileManagement

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
   \\        Modified   : 2022-11-20                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                   ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-20-2022 15:29:24    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    _________________________________________________________________________________________________________
    | Type  | Name                     | Description                                                        |
    |-------|--------------------------|--------------------------------------------------------------------|
    | Class | WirelessNetworkXaml      | Main GUI/Xaml string                                               |
    | Class | PassphraseXaml           | Passphrase GUI/Xaml                                                |
    | Class | XamlProperty             | Used to index/catalog the Xaml control objects                     |
    | Class | XamlWindow               | Constructs the XamlWindow object                                   |
    | Enum  | PhysicalType             | Enum for an SSID's physical network type                           |
    | Class | PhysicalSlot             | Object for an SSID's physical network type                         |
    | Class | PhysicalList             | A list of potential SSID physical network types                    |
    | Enum  | AuthenticationType       | Enum for an SSID's authentication type                             |
    | Class | AuthenticationSlot       | Object for an SSID's authentication type                           |
    | Class | AuthenticationList       | A list of potential SSID's authentication types                    |
    | Enum  | EncryptionType           | Enum for an SSID's encryption type                                 |
    | Class | EncryptionSlot           | Object for an SSID's encryption type                               |
    | Class | EncryptionList           | A list of potential SSID's encryption types                        |
    | Class | Ssid                     | Representation of each SSID collected by the wireless radio(s)     |
    | Class | SsidSubcontroller        | Subcontroller for Ssid information injection                       |
    | Class | ConnectionModeResolver   | (Struct), better than a hashtable                                  |
    | Enum  | ConnectionModeType       | Enumerates the connection mode in profile object                   |
    | Class | ConnectionModeSlot       | Object for a profile's range of available options                  |
    | Class | ConnectionModeList       | A list for connection modes                                        |
    | Class | WifiProfileSubcontroller | Handles the profile objects                                        |
    | Class | WiFiProfile              | Shorthand version of the profile object                            |
    | Class | WifiProfileExtension     | Expanded version of the profile object, includes adapter/interface |
    | Class | WifiProfileList          | Object that handles a list of profiles on a given adapter          |
    | Class | WifiInterface            | This deals exclusively with Wireless network adapters              |
    | Class | WifiInterfaceNetsh       | This retrieves SOME information from netsh                         |
    | Class | RtMethod                 | Specifically for selecting/filtering a Runtime IAsyncTask          |
    | Class | Wireless                 | Controller class for the function, this encapsulates the XAML/GUI  |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
.Example
#>

Function Search-WirelessNetwork
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode)

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
        '                <RowDefinition Height="80"/>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="40"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <DataGrid Grid.Row="0" Name="Adapter">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="#"           Width="25"  Binding="{Binding Index}"/>',
        '                    <DataGridTextColumn Header="Name"        Width="200" Binding="{Binding Name}"/>',
        '                    <DataGridTextColumn Header="Description" Width="*"   Binding="{Binding Description}"/>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '            <Grid Grid.Row="1">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="90"/>',
        '                    <ColumnDefinition Width="50"/>',
        '                    <ColumnDefinition Width="90"/>',
        '                    <ColumnDefinition Width="165"/>',
        '                    <ColumnDefinition Width="85"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Label   Grid.Column="0" Content="[Index]:"/>',
        '                <TextBox Grid.Column="1" Name="Index" IsReadOnly="True"/>',
        '                <Label   Grid.Column="2" Content="[Status]:"/>',
        '                <TextBox Grid.Column="3" Name="Status" IsReadOnly="True"/>',
        '                <Label   Grid.Column="4" Content="[Mac]:"/>',
        '                <TextBox Grid.Column="5" Name="MacAddress" IsReadOnly="True"/>',
        '            </Grid>',
        '            <Grid Grid.Row="2">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="85"/>',
        '                    <ColumnDefinition Width="310"/>',
        '                    <ColumnDefinition Width="85"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <Label   Grid.Column="0" Content="[SSID]:"/>',
        '                <TextBox Grid.Column="1" Name="SSID" IsReadOnly="True"/>',
        '                <Label   Grid.Column="2" Content="[BSSID]:"/>',
        '                <TextBox Grid.Column="3" Name="BSSID" IsReadOnly="True"/>',
        '            </Grid>',
        '            <TabControl Grid.Row="3">',
        '                <TabItem Header="Profile">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <DataGrid Grid.Row="0" RowHeaderWidth="0" Name="Profile">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn     Header="#"          Width="25"   Binding="{Binding Index}"/>',
        '                                <DataGridTextColumn     Header="Name"       Width="*"    Binding="{Binding ProfileName}"/>',
        '                                <DataGridTemplateColumn Header="Connection Mode" Width="140">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding ConnectionMode.Index}"  ToolTip="{Binding ConnectionMode.Description}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="Manual"/>',
        '                                                <ComboBoxItem Content="Auto"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTemplateColumn Header="Authentication" Width="140">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Authentication.Index}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="None"/>',
        '                                                <ComboBoxItem Content="Unknown"/>',
        '                                                <ComboBoxItem Content="Open80211"/>',
        '                                                <ComboBoxItem Content="SharedKey80211"/>',
        '                                                <ComboBoxItem Content="Wpa"/>',
        '                                                <ComboBoxItem Content="WpaPsk"/>',
        '                                                <ComboBoxItem Content="WpaNone"/>',
        '                                                <ComboBoxItem Content="Rsna"/>',
        '                                                <ComboBoxItem Content="RsnaPsk"/>',
        '                                                <ComboBoxItem Content="Ihv"/>',
        '                                                <ComboBoxItem Content="Wpa3Enterprise192Bits"/>',
        '                                                <ComboBoxItem Content="Wpa3Sae"/>',
        '                                                <ComboBoxItem Content="Owe"/>',
        '                                                <ComboBoxItem Content="Wpa3Enterprise"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTemplateColumn Header="Encryption" Width="140">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Encryption.Index}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="None"/>',
        '                                                <ComboBoxItem Content="Unknown"/>',
        '                                                <ComboBoxItem Content="Wep"/>',
        '                                                <ComboBoxItem Content="Wep40"/>',
        '                                                <ComboBoxItem Content="Wep104"/>',
        '                                                <ComboBoxItem Content="Tkip"/>',
        '                                                <ComboBoxItem Content="Ccmp"/>',
        '                                                <ComboBoxItem Content="WpaUseGroup"/>',
        '                                                <ComboBoxItem Content="RsnUseGroup"/>',
        '                                                <ComboBoxItem Content="Ihv"/>',
        '                                                <ComboBoxItem Content="Gcmp"/>',
        '                                                <ComboBoxItem Content="Gcmp256"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <DataGrid Grid.Row="1" Name="ProfileExtension" ScrollViewer.CanContentScroll="False" IsEnabled="False">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="100"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </TabItem>',
        '                <TabItem Header="Network">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label    Grid.Column="0" Content="[Filter]:"/>',
        '                            <ComboBox Grid.Column="1" Name="FilterProperty" SelectedIndex="0">',
        '                                <ComboBoxItem Content="Name"/>',
        '                                <ComboBoxItem Content="Index"/>',
        '                                <ComboBoxItem Content="BSSID"/>',
        '                                <ComboBoxItem Content="Type"/>',
        '                                <ComboBoxItem Content="Encryption"/>',
        '                                <ComboBoxItem Content="Strength"/>',
        '                            </ComboBox>',
        '                            <TextBox Grid.Column="2" Name="FilterText"/>',
        '                            <ProgressBar Grid.Column="3" Margin="10" Name="Progress"/>',
        '                            <Button  Grid.Column="4" Name="Refresh"  Content="(Scan/Refresh)"    IsEnabled="False"/>',
        '                        </Grid>',
        '                        <DataGrid Grid.Row="1" Grid.Column="0" Name="Network" RowHeaderWidth="0">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="#"        Width="25"  Binding="{Binding Index}"/>',
        '                                <DataGridTextColumn Header="Name"     Width="240" Binding="{Binding Name}"/>',
        '                                <DataGridTextColumn Header="Bssid"    Width="120" Binding="{Binding Bssid}"/>',
        '                                <DataGridTemplateColumn Header="Phy." Width="40">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Physical.Index}" ToolTip="{Binding Physical.Description}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="Unknown"/>',
        '                                                <ComboBoxItem Content="Fhss"/>',
        '                                                <ComboBoxItem Content="Dsss"/>',
        '                                                <ComboBoxItem Content="IRBaseband"/>',
        '                                                <ComboBoxItem Content="Ofdm"/>',
        '                                                <ComboBoxItem Content="Hrdsss"/>',
        '                                                <ComboBoxItem Content="Erp"/>',
        '                                                <ComboBoxItem Content="HT"/>',
        '                                                <ComboBoxItem Content="Vht"/>',
        '                                                <ComboBoxItem Content="Dmg"/>',
        '                                                <ComboBoxItem Content="HE"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="Uptime" Width="120" Binding="{Binding Uptime}"/>',
        '                                <DataGridTemplateColumn Header="Auth." Width="75">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Authentication.Index}"  ToolTip="{Binding Authentication.Description}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="None"/>',
        '                                                <ComboBoxItem Content="Unknown"/>',
        '                                                <ComboBoxItem Content="Open80211"/>',
        '                                                <ComboBoxItem Content="SharedKey80211"/>',
        '                                                <ComboBoxItem Content="Wpa"/>',
        '                                                <ComboBoxItem Content="WpaPsk"/>',
        '                                                <ComboBoxItem Content="WpaNone"/>',
        '                                                <ComboBoxItem Content="Rsna"/>',
        '                                                <ComboBoxItem Content="RsnaPsk"/>',
        '                                                <ComboBoxItem Content="Ihv"/>',
        '                                                <ComboBoxItem Content="Wpa3Enterprise192Bits"/>',
        '                                                <ComboBoxItem Content="Wpa3Sae"/>',
        '                                                <ComboBoxItem Content="Owe"/>',
        '                                                <ComboBoxItem Content="Wpa3Enterprise"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTemplateColumn Header="Enc." Width="75">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Encryption.Index}" ToolTip="{Binding Encryption.Description}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="None"/>',
        '                                                <ComboBoxItem Content="Unknown"/>',
        '                                                <ComboBoxItem Content="Wep"/>',
        '                                                <ComboBoxItem Content="Wep40"/>',
        '                                                <ComboBoxItem Content="Wep104"/>',
        '                                                <ComboBoxItem Content="Tkip"/>',
        '                                                <ComboBoxItem Content="Ccmp"/>',
        '                                                <ComboBoxItem Content="WpaUseGroup"/>',
        '                                                <ComboBoxItem Content="RsnUseGroup"/>',
        '                                                <ComboBoxItem Content="Ihv"/>',
        '                                                <ComboBoxItem Content="Gcmp"/>',
        '                                                <ComboBoxItem Content="Gcmp256"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTemplateColumn Header="Str." Width="40">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Strength}" Margin="0" Padding="2" Height="18" FontSize="10" IsEnabled="False">',
        '                                                <ComboBoxItem Content="0"/>',
        '                                                <ComboBoxItem Content="1"/>',
        '                                                <ComboBoxItem Content="2"/>',
        '                                                <ComboBoxItem Content="3"/>',
        '                                                <ComboBoxItem Content="4"/>',
        '                                                <ComboBoxItem Content="5"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Button Grid.Column="0" Name="Connect"    Content="Connect"    IsEnabled="False"/>',
        '                            <Button Grid.Column="1" Name="Disconnect" Content="Disconnect" IsEnabled="False"/>',
        '                            <Button Grid.Column="2" Name="Cancel"     Content="Cancel"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </TabItem>',
        '            </TabControl>',
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
        None                  = 0
        Unknown               = 1
        Open80211             = 2
        SharedKey80211        = 3
        Wpa                   = 4
        WpaPsk                = 5
        WpaNone               = 6
        Rsna                  = 7
        RsnaPsk               = 8
        Ihv                   = 9
        Wpa3                  = 10
        Wpa3Sae               = 11
        Owe                   = 12
        Wpa3Enterprise        = 13
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
        None        = 0
        Unknown     = 1
        Wep         = 2
        Wep40       = 3
        Wep104      = 4
        Tkip        = 5
        Ccmp        = 6
        WpaUseGroup = 7
        RsnUseGroup = 8
        Ihv         = 9
        Gcmp        = 10
        Gcmp256     = 11
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

    Class Ssid
    {
        [UInt32]            $Index
        [Object]             $Ssid
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
    
    Class SsidSubcontroller
    {
        [Object] $Physical
        [Object] $Authentication
        [Object] $Encryption
        [Object] $Output
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
            Return @(Switch ($Uptime)
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

    Class ConnectionModeResolver
    {
        [String] $Profile           = "WLAN_CONNECTION_MODE_PROFILE"
        [String] $TemporaryProfile  = "WLAN_CONNECTION_MODE_TEMPORARY_PROFILE"
        [String] $DiscoverySecure   = "WLAN_CONNECTION_MODE_DISCOVERY_SECURE"
        [String] $Auto              = "WLAN_CONNECTION_MODE_AUTO"
        [String] $DiscoveryUnsecure = "WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE"
    }

    Enum ConnectionModeType
    {
        Manual = 0
        Auto   = 1
    }

    Class ConnectionModeSlot
    {
        [UInt32] $Index
        [String] $Type
        [String] $Description
        ConnectionModeSlot([String]$Type)
        {
            $This.Type  = [ConnectionModeType]::$Type
            $This.Index = [UInt32][ConnectionModeType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ConnectionModeList
    {
        [Object] $Output
        ConnectionModeList()
        {
            $This.Output = @( )
            [System.Enum]::GetNames([ConnectionModeType]) | % { $This.Add($_) }
        }
        Add([String]$Type)
        {
            $Item             = [ConnectionModeSlot]::New($Type)
            $Item.Description = Switch ($Type)
            {
                Manual 
                { 
                    "Profile for this access point requires manual intervention"
                }
                Auto
                {
                    "Profile for this access point is automatic"
                }
            }
            $This.Output     += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ConnectionModeType]::$Type]
        }
    }

    Class WiFiProfile
    {
        [UInt32] $Index
        [String] $Name
        [String] $Flags
        [Object] $Detail
        WiFiProfile([UInt32]$Index,[Object]$xProfile)
        {
            $This.Index     = $Index
            $This.Name      = $xProfile.strProfileName
            $This.Flags     = $xProfile.ProfileFlags
            $This.Detail    = $Null
        }
    }

    Class WifiProfileExtensionProperty
    {
        [UInt32] $Index
        [String] $Name
        [String] $Value
        WifiProfileExtensionProperty([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Value = @(Switch ($Value.Count)
            {
                {$_ -eq 0}
                {
                    "-"
                }
                {$_ -eq 1}
                {
                    $Value
                }
                {$_ -gt 1}
                {
                    $Value -join "`n"
                }
            })
        }
    }

    Class WifiProfileExtension
    {
        [UInt32]               $Index
        Hidden [String]         $Name
        Hidden [Guid]           $Guid
        Hidden [String]  $Description
        Hidden [UInt32]      $IfIndex
        Hidden [String]       $Status
        Hidden [String]   $MacAddress
        Hidden [String]    $LinkSpeed
        Hidden [String]        $State
        [String]         $ProfileName
        [Object]      $ConnectionMode
        [Object]      $Authentication
        [Object]          $Encryption
        [String]            $Password
        [UInt32]   $ConnectHiddenSSID
        [String]             $EapType
        [String[]]       $ServerNames
        [String]       $TrustedRootCA
        [String]                 $Xml
        WifiProfileExtension([Object]$Interface)
        {
            $This.Name              = $Interface.Name
            $This.Guid              = $Interface.Guid
            $This.Description       = $Interface.Description
            $This.IfIndex           = $Interface.IfIndex
            $This.Status            = $Interface.Status
            $This.MacAddress        = $Interface.MacAddress
            $This.LinkSpeed         = $Interface.LinkSpeed
            $This.State             = $Interface.State
        }
        Load([Object]$xProfile)
        {
            $This.ProfileName       = $xProfile.ProfileName
            $This.Password          = $xProfile.Password
            $This.ConnectHiddenSSID = $xProfile.ConnectHiddenSSID
            $This.EapType           = $xProfile.EapType
            $This.ServerNames       = $xProfile.ServerNames
            $This.TrustedRootCA     = $xProfile.TrustedRootCA
            $This.Xml               = $xProfile.Xml
        }
        [Object] Profile()
        {
            $Object = @( )
            ForEach ($Item in "Password ConnectHiddenSSID EapType ServerNames TrustedRootCa Xml" -Split " ")
            {
                $Object += [WifiProfileExtensionProperty]::New($Object.Count,$Item,$This.$Item)
            }
            Return $Object
        }
    }

    Class WifiProfileList
    {
        [Object] $Interface
        [Object] $Process
        [Object] $Output
        WifiProfileList([Object]$Interface)
        {
            $This.Interface = $Interface
            $This.Process   = @( )
            $This.Output    = @( )
        }
        Add([Object]$xProfile)
        {
            $This.Process  += [WifiProfile]::New($This.Process.Count,$xProfile)
        }
    }

    Class WifiInterface
    {
        [UInt32] $Index
        [String] $Name
        [Guid]   $Guid
        [String] $Description
        [UInt32] $IfIndex 
        [String] $Status
        [String] $MacAddress
        [String] $LinkSpeed
        [String] $State
        [Object] $Profile
        WifiInterface([UInt32]$Index,[Object]$Interface)
        {
            $This.Index       = $Index
            $This.Name        = $Interface.Name
            $This.Guid        = $Interface.InterfaceGuid
            $This.Description = $Interface.InterfaceDescription
            $This.ifIndex     = $Interface.InterfaceIndex
            $This.Status      = $Interface.Status
            $This.MacAddress  = $Interface.MacAddress.Replace("-",":")
            $This.LinkSpeed   = $Interface.LinkSpeed
            $This.State       = Switch ($Interface.Status)
            {
                Up {"Connected"} Disconnected {"Disconnected"} Default {"Unknown"}
            }
            $This.Clear()
        }
        Add([Object]$xProfile)
        {
            $This.Profile.Add($xProfile)
        }
        Clear()
        {
            $This.Profile     = [WifiProfileList]::New($This)
        }
    }

    Class WifiInterfaceNetsh
    {
        [String] $Name
        [String] $Description
        [Guid]   $Guid
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
        WifiInterfaceNetsh([String[]]$In)
        {
            $This.Name                   = $This.Tx($In,"Name")
            $This.Description            = $This.Tx($In,"Description")
            $This.GUID                   = $This.Tx($In,"GUID")
            $This.MacAddress             = $This.Tx($In,"Physical address")
            $This.InterfaceType          = $This.Tx($In,"Interface type")
            $This.State                  = $This.Tx($In,"State")
            $This.Ssid                   = $This.Tx($In,"SSID")
            $This.Bssid                  = $This.Tx($In,"BSSID") | % ToUpper
            $This.NetworkType            = $This.Tx($In,"Network type")
            $This.RadioType              = $This.Tx($In,"Radio type")
            $This.Authentication         = $This.Tx($In,"Authentication")
            $This.Cipher                 = $This.Tx($In,"Cipher")
            $This.Connection             = $This.Tx($In,"Connection mode")
            $This.Band                   = $This.Tx($In,"Band")
            $This.Channel                = $This.Tx($In,"Channel")
            $This.Receive                = $This.Tx($In,"Receive rate \(Mbps\)")
            $This.Transmit               = $This.Tx($In,"Transmit rate \(Mbps\)")
            $This.Signal                 = $This.Tx($In,"Signal")
            $This.Profile                = $This.Tx($In,"Profile")
        }
        [String] Tx([Object]$In,[String]$String)
        {
            Return $In | ? { $_ -match "(^\s+$String\s+\:)" } | % Substring 29
        }
    }

    Class WifiProfileSubcontroller
    {
        [Object] $Connection
        [Object] $Authentication
        [Object] $Encryption
        WifiProfileSubcontroller()
        {
            $This.Connection         = [ConnectionModeList]::New()
            $This.Authentication     = [AuthenticationList]::New()
            $This.Encryption         = [EncryptionList]::New()
        }
        [Object] Load([UInt32]$Index,[Object]$Interface,[Object]$xProfile)
        {
            $Template                = [WifiProfileExtension]::New($Interface)
            $Template.Index          = $Index
            $Template.ConnectionMode = $This.Connection.Get($xProfile.Detail.ConnectionMode)
            
            Switch -Regex ($xProfile.Detail.Authentication)
            {
                ^Open$   { $xProfile.Detail.Authentication = "Open80211" }
                ^WPA2PSK { $xProfile.Detail.Authentication = "WpaPsk"    }
                Default  { }
            }

            $Template.Authentication = $This.Authentication.Get($xProfile.Detail.Authentication)

            Switch -Regex ($xProfile.Detail.Encryption)
            {
                ^AES$    { $xProfile.Detail.Encryption    = "Ccmp"       }
                Default  { }
            }

            $Template.Encryption     = $This.Encryption.Get($xProfile.Detail.Encryption)
            
            $Template.Load($xProfile.Detail)
            Return $Template
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

    Class WirelessController
    {
        Hidden [UInt32]    $Mode
        Hidden [Object]  $Module
        Hidden [String] $OEMLogo
        Hidden [Object]    $Ssid
        Hidden [Object] $Profile
        Hidden [Object]    $Xaml
        [Object]        $Adapter
        [Object]        $Request
        [Object]         $Radios
        [Object]           $List
        [Object]         $Output
        [Object]       $Selected
        [Object]      $Connected
        [Object]         $Target
        RefreshWirelessAdapterList()
        {
            $This.Adapter = @( ) 
            ForEach ($Adapter in Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)")
            {
                $Item          = [WifiInterface]::New($This.Adapter.Count,$Adapter)
                $This.GetWiFiProfileList($Item)
                $This.Adapter += $Item
            }
        }
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
        [Object] GetProfileSubcontroller()
        {
            Return [WifiProfileSubcontroller]::New()
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
            Return [WifiInterfaceNetsh]::New((netsh wlan show interface $Name))
        }
        [Object] Win32Exception([UInt32]$ReasonCode)
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
            Return (New-Object WiFi.ProfileManagement+WLAN_CONNECTION_MODE)::$ConnectionMode
        }
        [Object] WlanDot11BssType([String]$Dot11BssType)
        {
            Return (New-Object WiFi.ProfileManagement+DOT11_BSS_TYPE)::$Dot11BssType
        }
        [Object] WlanConnectionFlag([String]$Flag)
        {
            Return (New-Object WiFi.ProfileManagement+WlanConnectionFlag)::$Flag
        }
        [Object] WlanSetProfile([UInt32]$Handle,[Guid]$IFGuid,[UInt32]$Flags,[IntPtr]$ProfileXml,
        [IntPtr] $ProfileSecurity,[Bool]$Overwrite,[IntPtr]$pReserved,[IntPtr]$pdwReasonCode)
        {
            Return (New-Object WiFi.ProfileManagement)::WlanSetProfile($Handle,$IFGuid,$Flags,
            $ProfileXml,$ProfileSecurity,$Overwrite,$pReserved,$pdwReasonCode)
        }
        [Void] WlanDeleteProfile([IntPtr]$Handle,[Guid]$IFGuid,[String]$ProfileID,[IntPtr]$pReserved)
        {   
            (New-Object WiFi.ProfileManagement)::WlanDeleteProfile($Handle,$IFGuid,$ProfileID,$pReserved)
        }
        [Void] WlanDisconnect([IntPtr]$Handle,[Guid]$IFGuid,[IntPtr]$pReserved)
        {            
            (New-Object WiFi.ProfileManagement)::WlanDisconnect($Handle,$IFGuid,$pReserved)
        }
        [Void] WlanConnect([IntPtr]$Handle,[Guid]$IFGuid,[Object]$Params,[IntPtr]$pReserved)
        {
            (New-Object WiFi.ProfileManagement)::WlanConnect($Handle,$IFGuid,$Params,$pReserved)
        }
        [String] WiFiReasonCode([IntPtr]$Reason)
        {   
            $String = [Text.StringBuilder]::New(1024)
            $Result = (New-Object WiFi.ProfileManagement)::WlanReasonCodeToString(
                       $Reason.ToInt32(),$String.Capacity,$String,[IntPtr]::Zero)
            If ($Result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }
            
            Return $String.ToString()
        }
        [IntPtr] NewWifiHandle()
        {
            $Max       = 2
            [Ref] $Neg = 0
            $Handle    = [IntPtr]::Zero
            $Result    = (New-Object WiFi.ProfileManagement)::WlanOpenHandle($Max,[IntPtr]::Zero,$Neg,[Ref]$Handle)
            If ($Result -eq 0)
            {
                Return $Handle
            }
            Else
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Void] RemoveWifiHandle([IntPtr]$Handle)
        {
            $Result = (New-Object WiFi.ProfileManagement)::WlanCloseHandle($Handle,[IntPtr]::Zero)
            If ($Result -ne 0)
            {
                $Message = $This.Win32Exception($Result)
                Throw "$Message / $Result"
            }
        }
        GetWiFiProfileList([Object]$Adapter)
        {
            $Ptr       = 0
            $Handle    = $This.NewWifiHandle()
            
            # // _________________________________________
            # // | Get the profile list, save to pointer |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [Void](New-Object WiFi.ProfileManagement)::WlanGetProfileList($Handle,$Adapter.GUID,[IntPtr]::Zero,[Ref]$Ptr)
            
            # // _________________________________________
            # // | Process all profiles for this adapter |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            (New-Object WiFi.ProfileManagement+WLAN_PROFILE_INFO_LIST $Ptr).ProfileInfo | % { $Adapter.Add($_) }
            
            $This.RemoveWiFiHandle($Handle)
            
            # // ___________________________________
            # // | Obtain details for each profile |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            ForEach ($X in 0..($Adapter.Profile.Process.Count-1))
            {
                $xProfile               = $Adapter.Profile.Process[$X]
                [IntPtr]$Handle         = $This.NewWifiHandle()
                $Flags                  = 0
                $xProfile.Detail        = $This.WiFiProfileInfo($xProfile.Name,$Adapter.Guid,$Handle,$Flags)
                $This.RemoveWiFiHandle($Handle)
            
                $Adapter.Profile.Output += $This.Profile.Load($X,$Adapter,$xProfile)
            }
        }
        [Object] WiFiProfileInfo([String]$Tag,[Guid]$Guid,[IntPtr]$Handle,[Int16]$Flags)
        {            
            [String] $pstrXml  = $Null
            $WlanAccess        = 0
            $WlanPF            = $Flags
            $Result            = (New-Object WiFi.ProfileManagement)::WlanGetProfile(
                                  $Handle,$Guid,$Tag,[IntPtr]::Zero,
                                  [Ref]$pstrXml,[Ref]$WlanPF,[Ref]$WlanAccess)
            $Password          = $Null
            $ConnectHiddenSSID = $Null
            $EapType           = $Null
            $XmlPtr            = $Null
            $ServerNames       = $Null
            $RootCA            = $Null
            $Return            = $Null
            
            If ($Result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }
            
            $WlanProfile       = [Xml]$pstrXml
            
            # // __________________
            # // | Parse password |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($Flags -eq 13)
            {
                $Password      = $WlanProfile.WlanProfile.Msm.Security.SharedKey.KeyMaterial
            }
            If ($Flags -ne 13)
            {
                $Password      = $Null
            }
            
            # // ___________________________
            # // | Parse nonBroadcast flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ([Bool]::TryParse($WlanProfile.WlanProfile.SsidConfig.NonBroadcast,[Ref]$Null))
            {
                $ConnectHiddenSSID = [Bool]::Parse($WlanProfile.WlanProfile.SsidConfig.NonBroadcast)
            }
            Else
            {
                $ConnectHiddenSSID = $false
            }
            
            # // __________________
            # // | Parse EAP type |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($WlanProfile.WlanProfile.Msm.Security.AuthEncryption.UseOneX -eq $true)
            {
                $WlanProfile.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.EapMethod.Type.InnerText | % { 
            
                    $EAPType = Switch ($_) 
                    { 
                        13      {    'TLS'  } # EAP-TLS 
                        25      {    'PEAP' } # EAP-PEAP (MSCHAPv2)
                        Default { 'Unknown' } 
                    }
                }
            }
            Else
            {
                $EAPType = $Null
            }
            
            # // ________________________________
            # // | Parse Validation Server Name |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If (!!$EapType)
            {
                $Config = $WlanProfile.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config 
                Switch ($EapType)
                {
                    PEAP
                    {
            
                        $ServerNames = $Config.Eap.EapType.ServerValidation.ServerNames
                    } 
            
                    TLS
                    {
                        $Node        = $Config.SelectNodes("//*[local-name()='ServerNames']")
                        $ServerNames = $Node[0].InnerText
                    }
                }
            }
            
            # // __________________________________
            # // | Parse Validation TrustedRootCA |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If (!!$EAPType)
            {
                $Config = $WlanProfile.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
                Switch ($EAPType)
                {
                    PEAP
                    {
                        $RootCA = $Config.Eap.EapType.ServerValidation.TrustedRootCA.Replace(' ','') | % ToLower
                    }
                    TLS
                    {
                        $Node   = $Config.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $RootCA = $Node[0].InnerText.Replace(' ','') | % ToLower
                    }
                }
            }
            
            $Return                   = $This.WlanProfileInfoObject()
            $Return.ProfileName       = $WlanProfile.WlanProfile.SsidConfig.Ssid.name
            $Return.ConnectionMode    = $WlanProfile.WlanProfile.ConnectionMode
            $Return.Authentication    = $WlanProfile.WlanProfile.Msm.Security.AuthEncryption.Authentication
            $Return.Encryption        = $WlanProfile.WlanProfile.Msm.Security.AuthEncryption.Encryption
            $Return.Password          = $Password
            $Return.ConnectHiddenSSID = $ConnectHiddenSSID
            $Return.EAPType           = $EAPType
            $Return.ServerNames       = $ServerNames
            $Return.TrustedRootCA     = $RootCA
            $Return.Xml               = $pstrXml
            
            $XmlPtr                   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($pstrXml)
            (New-Object WiFi.ProfileManagement)::WlanFreeMemory($XmlPtr)
            
            Return $Return
        }
        [Object] GetWiFiProfileInfo([String]$Tag,[Guid]$Guid,[Int16]$Flags)
        {   
            [IntPtr]$Handle = $This.NewWifiHandle()
            $WlanFlags      = $Flags
            $Return         = $This.WiFiProfileInfo($Tag,$Guid,$Handle,$WlanFlags)
            $This.RemoveWiFiHandle($Handle)
            Return $Return
        }
        [Object] GetWifiProfileInfo([String]$Tag,[Guid]$Guid)
        {
            [IntPtr]$Handle = $This.NewWifiHandle()
            $WlanFlags      = 0
            $Return         = $This.WiFiProfileInfo($Tag,$Guid,$Handle,$WlanFlags)
            $This.RemoveWiFiHandle($Handle)
            Return $Return
        }
        [Object] GetWiFiConnectionParameter([String]$Tag,[String]$Mode,[String]$Type,[String]$Flag)
        {   
            Return $This.WifiConnectionParameter($Tag,$Mode,$Type,$Flag)
        }
        [Object] GetWiFiConnectionParameter([String]$Tag,[String]$Mode,[String]$Type)
        {   
            Return $This.WifiConnectionParameter($Tag,$Mode,$Type,"Default")
        }
        [Object] GetWiFiConnectionParameter([String]$Tag,[String]$Mode)
        {
            Return $This.WifiConnectionParameter($Tag,$Mode,"Any","Default")
        }
        [Object] GetWiFiConnectionParameter([String]$Tag)
        {
            Return $This.WifiConnectionParameter($Tag,"Profile","Any","Default")
        }
        [Object] WifiConnectionParameter([String]$Tag,[String]$Mode,[String]$Type,[String]$Flag)
        {
            Try
            {
                $Resolver                   = [ConnectionModeResolver]::New()
                $Connect                    = $This.WlanConnectionParams()
                $Connect.StrProfile         = $Tag
                $Connect.WlanConnectionMode = $This.WlanConnectionMode($Resolver.$Mode)
                $Connect.Dot11BssType       = $This.WlanDot11BssType($Type)
                $Connect.dwFlags            = $This.WlanConnectionFlag($Flag)
            }
            Catch
            {
                Throw "An error occurred while setting connection parameters"
            }
            
            Return $Connect
        }
        [Object] FormatXml([Object]$Content)
        {
            $Str             = [System.IO.StringWriter]::New()
            $Xml             = [System.Xml.XmlTextWriter]::New($Str)
            $Xml.Formatting  = "Indented"
            $Xml.Indentation = 4
            ([Xml]$Content).WriteContentTo($Xml)
            $Xml.Flush()
            $Str.Flush()
            Return $Str.ToString()
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
        [String] Hex([String]$Tag)
        {
            Return ([Char[]]$tag | % { '{0:X}' -f [Int]$_ }) -join ''
        }
        [String] NewWiFiProfileXmlPsk([String]$Tag,[String]$Mode='Auto',[String]$Auth='WPA2PSK',
        [String]$Enc='AES',[SecureString]$Pass)
        {
            $Plain          = $Null
            $ProfileXml     = $Null
            $Hex            = $This.Hex($Tag)
            Try
            {
                If ($Pass)
                {
                    $Secure = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass)
                    $Pass   = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Secure)
                }
                
                $ProfileXml = [XML]($This.XmlTemplate(0) -f $Tag, $Hex, $Mode, $Auth, $Enc, $Plain)
                If (!$Plain)
                {
                    $Null = $ProfileXml.WlanProfile.Msm.Security.RemoveChild($ProfileXml.WlanProfile.Msm.Security.SharedKey)
                }
            
                If ($Auth -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
                    $Names   = [System.Xml.XmlNamespaceManager]::new($ProfileXml.NameTable)
                    $Names.AddNamespace('WLANProfile',$ProfileXml.DocumentElement.GetAttribute('xmlns'))
                    $RefNode = $ProfileXml.SelectSingleNode('//WLANProfile:authEncryption', $Names)
                    $XmlNode = $ProfileXml.CreateElement('transitionMode','http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XmlNode.InnerText = 'True'
                    $Null    = $RefNode.AppendChild($XmlNode)
                }
            
                Return $This.FormatXml($ProfileXml.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [String] NewWifiProfileXmlEap([String]$Tag,[String]$MOde='Auto',[String]$Auth='WPA2PSK',
        [String]$Enc='AES',[String]$Eap,[String[]]$ServerNames,[String]$RootCA)
        {
            # // ___________________________________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | EAP: EapType |
            # // | SN: ServerNames | TRCA: TrustedRootCa | PX: ProfileXml |  RN: RefNode | XN: XmlNode     | 
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $ProfileXml = $Null
            $Hex        = $This.Hex($Tag)
            Try
            {
                If ($Eap -eq 'PEAP')
                {
                    $ProfileXml = [Xml]($This.XmlTemplate(1) -f $Tag, $Hex, $Mode, $Auth, $Enc)
                    $Config = $ProfileXml.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
            
                    If ($ServerNames)
                    {
                        $Config.Eap.EapType.ServerValidation.ServerNames = $ServerNames
                    }
            
                    If ($RootCA)
                    {
                        $Config.Eap.EapType.ServerValidation.TrustedRootCA = $RootCA.Replace('..','$& ')
                    }
                }
                ElseIf ($Eap -eq 'TLS')
                {
                    $ProfileXml = [Xml]($This.XmlTemplate(2) -f $Tag, $Hex, $Mode, $Auth, $Enc)
                    $Config     = $ProfileXml.WlanProfile.Msm.Security.OneX.EapConfig.EapHostConfig.Config
            
                    If ($ServerNames)
                    {
                        $Node   = $Config.SelectNodes("//*[local-name()='ServerNames']")
                        $Node[0].InnerText = $ServerNames
                    }
            
                    If ($RootCA)
                    {
                        $Node = $Config.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $Node[0].InnerText = $RootCA.Replace('..','$& ')
                    }
                }
            
                If ($Auth -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
                    $Names   = [System.Xml.XmlNamespaceManager]::New($ProfileXml.NameTable)
                    $Names.AddNamespace('WLANProfile', $ProfileXml.DocumentElement.GetAttribute('xmlns'))
                    $RefNode = $ProfileXml.SelectSingleNode('//WLANProfile:authEncryption', $Names)
                    $XmlNode = $ProfileXml.CreateElement('transitionMode','http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XmlNode.InnerText = 'true'
                    $Null    = $RefNode.AppendChild($XmlNode)
                }
            
                Return $This.FormatXml($ProfileXml.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [Object] NewWiFiProfilePsk([String]$Tag,[String]$Pass,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlPsk($Tag,'Auto','WPA2PSK','AES',$Pass)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWiFiProfilePsk([String]$Tag,[String]$Pass,[String]$Mode,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlPsk($Tag,$Mode,'WPA2PSK',"AES")
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWiFiProfilePsk([String]$Tag,[String]$Pass,[String]$Mode,[String]$Auth,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlPsk($Tag,$Mode,$Auth,'AES',$Name)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWiFiProfilePsk([String]$Tag,[String]$Pass,[String]$Mode,[String]$Auth,[String]$Enc,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlPsk($Tag,$Mode,$Auth,$Enc,$Name)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$EAP,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,'Auto','WPA2PSK','AES',$EAP,'',$Null)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$Mode,[String]$EAP,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,$Mode,'WPA2PSK','AES',$EAP,'',$Null)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$Mode,[String]$Auth,[String]$EAP,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,$Mode,$Auth,'AES',$EAP,'',$Null)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$Mode,[String]$Auth,[String]$Enc,[String]$EAP,[String]$Name)
        {            
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,$Mode,$Auth,$Enc,$EAP,'',$Null)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$Mode,[String]$Auth,[String]$Enc,[String]$Eap,
        [String[]]$ServerNames,[String]$Name)
        {   
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,$Mode,$Auth,$Enc,$EAP,$ServerNames,$Null)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileEap([String]$Tag,[String]$Mode,[String]$Auth,[String]$Enc,[String]$Eap,
        [String[]]$ServerNames,[String]$RootCA,[String]$Name)
        {
            $ProfileTemp = $This.NewWifiProfileXmlEap($Tag,$Mode,$Auth,$Enc,$EAP,$ServerNames,$RootCA)
            Return $This.NewWifiProfile($ProfileTemp,$Name)
        }
        [Object] NewWifiProfileXml([String]$Type,[String]$Name,[Bool]$Overwrite)
        {
            Return $This.NewWifiProfile($Type,$Name)
        }
        NewWifiProfile([String]$Type,[String]$Name,[Bool]$Overwrite)
        {
            Try
            {
                $IFGuid        = $This.Adapter | ? Name -match $Name
                $Handle        = $This.NewWiFiHandle()
                $Flags         = 0
                $ReasonCode    = [IntPtr]::Zero
                $Ptr           = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($Type)    
                $ReturnCode    = $This.WlanSetProfile($Handle,[Ref]$IFGuid,$Flags,$Ptr,[IntPtr]::Zero,
                                 $Overwrite,[IntPtr]::Zero,[Ref]$ReasonCode)
                $ReturnCodeMsg = $This.Win32Exception($ReturnCode)
                $ReasonCodeMsg = $This.WiFiReasonCode($ReasonCode)
            
                If ($ReturnCode -eq 0)
                {
                    Write-Verbose -Message $ReturnCodeMsg
                }
                Else
                {
                    Throw $ReturnCodeMsg
                }
            
                Write-Verbose -Message $ReasonCodeMsg
            }
            Catch
            {
                Throw "Failed to create the profile"
            }
            Finally
            {
                If ($Handle)
                {
                    $This.RemoveWiFiHandle($Handle)
                }
            }
        }
        RemoveWifiProfile([String]$Tag)
        {   
            $Handle = $This.NewWiFiHandle()
            (New-Object WiFi.ProfileManagement)::WlanDeleteProfile($Handle,[Ref]$This.Selected.Guid,$Tag,[IntPtr]::Zero)
            $This.RemoveWifiHandle($Handle)
        }
        StageXamlEvent()
        {
            If ($This.Mode -ne 1)
            {
                Throw "Invalid mode"
            }

            # // __________________
            # // | Event Triggers |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Wifi         = $This

            $This.Xaml.IO.Adapter.Add_SelectionChanged(
            {
                $Index = [UInt32]$Wifi.Xaml.IO.Adapter.SelectedItem.Index.ToString()
                If ($Index -gt -1)
                {
                    $Wifi.Select($Index)
                    If ($Wifi.Selected.Profile.Output.Count -gt 0)
                    {
                        $Wifi.Xaml.IO.Profile.Items.Clear()
                        $Wifi.Xaml.IO.ProfileExtension.Items.Clear()
                        $Wifi.Xaml.IO.ProfileExtension.IsEnabled = 0
                        ForEach ($Item in $Wifi.Selected.Profile.Output)
                        {
                            [Void]$Wifi.Xaml.IO.Profile.Items.Add($Item)
                        }
                    }

                    If ($Wifi.Selected.Status -eq "Connected")
                    {
                        $Wifi.Update()
                        $Wifi.Refresh()
                    }
                }
            })

            $This.Xaml.IO.Refresh.Add_Click(
            {
                $Wifi.Refresh()
                If ($Wifi.Xaml.IO.FilterText.Text -ne "")
                {
                    $Wifi.SearchFilter()
                }
            })

            $This.Xaml.IO.FilterText.Add_TextChanged(
            {
                If ($Wifi.Xaml.IO.Network.Count -gt 0)
                {
                    $Wifi.SearchFilter()
                }
            })

            $This.Xaml.IO.Profile.Add_SelectionChanged(
            {
                $Wifi.Xaml.IO.ProfileExtension.IsEnabled = $Wifi.Xaml.IO.Profile.SelectedIndex -ne -1
                If ($Wifi.Xaml.IO.Profile.SelectedIndex -ne -1)
                {
                    $Wifi.Xaml.IO.ProfileExtension.Items.Clear()
                    $Wifi.Xaml.IO.Profile.SelectedItem.Profile() | % {
                    
                        $Wifi.Xaml.IO.ProfileExtension.Items.Add($_)
                    }
                }
            })

            $This.Xaml.IO.Network.Add_SelectionChanged(
            {
                If (!$Wifi.Connected)
                {
                    $Wifi.Xaml.IO.Disconnect.IsEnabled     = 0
                    $Wifi.Xaml.IO.Connect.IsEnabled        = $Wifi.Xaml.IO.Network.SelectedIndex -gt -1
                }
                If ($Wifi.Connected)
                {
                    $Wifi.Xaml.IO.Connect.IsEnabled        = 0
                    $Wifi.Xaml.IO.Disconnect.IsEnabled     = 1
                }
            })

            $This.Xaml.IO.Connect.Add_Click(
            {
                If (!$Wifi.Connected -and $Wifi.Xaml.IO.Network.SelectedIndex -ne -1)
                {
                    # // __________________________________
                    # // | Establish restoration criteria |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Target  = $Wifi.Xaml.IO.Network.SelectedItem
                    $Adapter = $Wifi.Selected
                    $Guid    = $Wifi.Selected.Guid
                    $Count   = 0
                    $State   = $Null
                    
                    # // _______________________________
                    # // | Check if the profile exists |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    If ($Target.Name -in $Adapter.Profile.Output.ProfileName)
                    {
                        $Wifi.Connect($Target)
                        Do
                        {
                            $State         = $Wifi.NetshShowInterface($Wifi.Selected.Name)
                            If ($State.State -ne "Connected")
                            {
                                Start-Sleep 1
                                $Count ++
                            }
                        }
                        Until ($Wifi.Connected -or $Count -gt 5)

                        Switch ($Wifi.Connected)
                        {
                            $False
                            {
                                [System.Windows.MessageBox]::Show("Unable to connect","Error")
                            }
                            $True
                            {
                                $Wifi.RefreshWirelessAdapterList()
                                $Adapter       = $Wifi.Adapters | ? Guid -eq $Guid
                                $Wifi.Unselect()
                                $Wifi.Select($Adapter)
                                $Wifi.Update()
                            }
                        }
                    }
                    Else
                    {
                        $Wifi.Passphrase($Target)
                        $Wifi.Update()
                    }
                }
            })
        
            $This.Xaml.IO.Disconnect.Add_Click(
            {
                If ($Wifi.Connected)
                {
                    # // __________________________________
                    # // | Establish restoration criteria |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Adapter       = $Wifi.Selected
                    $Guid          = $Wifi.Selected.Guid
                    $Count         = 0
                    $State         = $Null
                    $Wifi.Disconnect()

                    Do
                    {
                        $State         = $Wifi.NetshShowInterface($Adapter.Name)
                        If ($State.State -ne "Disconnected")
                        {
                            Start-Sleep 1
                            $Count ++
                        }
                    }
                    Until ($Wifi.Connected -or $Count -gt 5)
                    
                    $Wifi.RefreshWirelessAdapterList()
                    $Adapter       = $Wifi.Adapters | ? Guid -eq $Guid
                    $Wifi.Unselect()
                    $Wifi.Select($Adapter)
                    $Wifi.Update()        
                    $Wifi.Refresh()
                }
                If (!$Wifi.Connect)
                {
                    $Wifi.Xaml.IO.Disconnect.IsEnabled = 0
                }
            })

            $This.Xaml.IO.Cancel.Add_Click(
            {
                $Wifi.Xaml.IO.DialogResult = $False
            })
        }
        Scan()
        {
            $This.List               = @( )
            $This.Output             = @( )
            
            [Void][Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime]
            $This.List               = $This.RadioFindAllAdaptersAsync()
            $This.List.Wait(-1) > $Null

            $Array                   = @($This.List.Result.NetworkReport.AvailableNetworks | Sort-Object -Descending SignalBars)
            $Ct                      = $Array.Count

            Switch ($This.Mode)
            {
                0 { Write-Progress -Activity Scanning -Status Scanning -PercentComplete 0 }
                1 { $This.Xaml.IO.Progress.Value = 0 }
            }
                    
            ForEach ($Network in $Array)
            {
                $This.Output        += $This.GetSsid($This.Output.Count,$Network)
                $Status              = "($($This.Output.Count)/$($Ct-1)"
                $Percent             =  [Long]($This.Output.Count * 100 / $Ct)

                Switch ($This.Mode)
                {
                    0 { Write-Progress -Activity Scanning -Status $Status -PercentComplete $Percent }
                    1 { $This.Xaml.IO.Progress.Value = $Percent }
                }
            }

            Switch ($This.Mode)
            {
                0 { Write-Progress -Activity Scanning -Status Complete -Completed }
                1 { $This.Xaml.IO.Progress.Value = 0 }
            }            
        }
        [Object] GetSsid([UInt32]$Index,[Object]$Network)
        {
            $Item                    = [Ssid]::New($This.Output.Count,$Network)
            $This.Ssid.Load($Item)
            Return $Item
        }
        WirelessController([UInt32]$Mode)
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
            
            $This.Ssid      = $This.GetSsidSubController()

            # // __________________________________
            # // | Load the Profile Subcontroller |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Profile   = $This.GetProfileSubcontroller()


            $This.Adapter   = @( )
            $This.Request   = @( )
            $This.Radios    = @( )
            $This.List      = @( )
            $This.Output    = @( )
            $This.Selected  = $Null
            $This.Connected = $Null
            $This.Target    = $Null

            # // _______________________________________
            # // | Get access to any wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.RefreshWirelessAdapterList()

            # // __________________________________________
            # // | Throw if no existing wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($This.Adapter.Count -eq 0)
            {
                Throw "No existing wireless adapters on this system"
            }

            If ($This.Mode -eq 1)
            {
                $This.Xaml = $This.GetWirelessNetworkXaml()
                
                $This.Xaml.IO.Adapter.Items.Clear()
                $This.Xaml.IO.Profile.Items.Clear()
                $This.Xaml.IO.ProfileExtension.Items.Clear()
                $This.Xaml.IO.Network.Items.Clear()

                # // ________________________
                # // | Populate adapter box |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($Adapter in $This.Adapter)
                {
                    $This.Xaml.IO.Adapter.Items.Add($Adapter)
                }

                # // _________________________________________
                # // | Set other various starting conditions |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                If ($This.Xaml.IO.Adapter.Count -gt 0)
                {
                    $This.Xaml.IO.Refresh.IsEnabled = 1
                }

                $This.StageXamlEvent()
            }
        }
        Refresh()
        {
            # // __________________________
            # // | Load the runtime types |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            [Void][Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType=WindowsRuntime]
            [Void][Windows.Devices.Radios.RadioAccessStatus, Windows.System.Devices, ContentType=WindowsRuntime]
            [Void][Windows.Devices.Radios.RadioState, Windows.System.Devices, ContentType=WindowsRuntime]
            
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
                $This.Xaml.IO.Network.Items.Clear()
                ForEach ($Object in $This.Output)
                {
                    $This.Xaml.IO.Network.Items.Add($Object)
                }
            }
        }
        Select([UInt32]$Index)
        {   
            # // ___________________________________________
            # // | Select the adapter from its description |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Selected = $This.Adapter[$Index]

            If ($This.Mode -eq 1)
            {
                $This.Xaml.IO.Index.Text           = $This.Selected.IfIndex
                $This.Xaml.IO.Status.Text          = $This.Selected.Status
                $This.Xaml.IO.MacAddress.Text      = $This.Selected.MacAddress
            }

            $This.Update()
        }
        Unselect()
        {
            $This.Selected                         = $Null
            $This.RefreshWirelessAdapterList()
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
            $Index    = $This.Selected.Index
            $xAdapter = $This.Adapter[$Index]
            $xSSID    = $This.NetshShowInterface($xAdapter.Name)

            If (!$This.Selected)
            {
                Write-Host "No adapter selected"
            }

            If ($This.Selected.State -eq "CONNECTED")
            {
                $Handle           = $This.NewWiFiHandle()
                (New-Object WiFi.ProfileManagement)::WlanDisconnect($Handle,[Ref]$xAdapter.Guid,[IntPtr]::Zero)
                $This.RemoveWifiHandle($Handle)
                $This.Connected   = $Null
            
                $This.ShowToast("Disconnected: ($($xSSID.SSID)/$($xSSID.BSSID))")
            
                $This.Unselect()
                $This.Select($Index)
            }
        }
        Connect([Object]$Target)
        {
            $Index          = $This.Selected.Index
            $This.Unselect()
            $This.Select($Index)
            
            If ($Target.Name -in $This.Selected.Profile.Output.ProfileName)
            {
                $Param  = $This.GetWiFiConnectionParameter($Target.Name)
                $Handle = $This.NewWiFiHandle()
                (New-Object WiFi.ProfileManagement)::WlanConnect($Handle,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                $This.RemoveWifiHandle($Handle)
        
                $This.Unselect()
                $This.Select($Index)
        
                $This.Update()
                $This.ShowToast("Connected: $($Target.Name)")
            }
            If ($Target.Name -notin $This.Selected.Profile.Output.ProfileName)
            {
                If ($Target.Authentication -match "PSK")
                {
                    $This.Passphrase($Target)
                }
                Else
                {
                    Write-Host "Eas/Peap not yet implemented"
                }
            }
        }
        ShowToast([String]$Message)
        {
            $Splat = @{ 

                Message = $Message
                Header  = [DateTime]::Now
                Body    = $Message
                Image   = $This.OEMLogo
            }

            Show-ToastNotification @Splat
        }
        Passphrase([Object]$Target)
        {
            $Index     = $This.Selected.Index
            $xAdapter  = $This.Selected
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

            # // __________________________________________________________________
            # // | Passphrase collection when using the command line interface... |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Mode -eq 0)
            {
                $PW     = Read-Host -AsSecureString -Prompt "Enter passphrase for Network: [$($Target.SSID)]"

                $ProfileXml = $This.NewWifiProfileXmlPsk($Target.Name,"Manual",$Auth,$Enc,$PW)
                $This.NewWifiProfile($ProfileXml,$This.Selected.Name,$True)
                
                $Param  = $This.GetWiFiConnectionParameter($Target.Name)
                $Handle = $This.NewWiFiHandle()
                $This.WlanConnect($Handle,[Ref]$xAdapter.Guid,[Ref]$Param,[IntPtr]::Zero)
                $This.RemoveWifiHandle($Handle)
                
                Start-Sleep 3
                $This.Unselect()
                $This.Select($Index)
                
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

            # // ____________________________________________________________________
            # // | Passphrase collection when using the graphical user interface... |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Mode -eq 1)
            {
                $Pass    = $This.GetPassphraseXaml()
                $Pass.IO.Connect.Add_Click(
                {
                    $Password      = $Pass.IO.Passphrase.Password
                    $PW            = $Password | ConvertTo-SecureString -AsPlainText -Force
                    $ProfileXml    = $This.NewWifiProfileXmlPsk($Network.Name,"manual",$Auth,$Enc,$PW)
                    $This.NewWifiProfile($ProfileXml,$Target.Name,$True)
                        
                    $Param         = $This.GetWiFiConnectionParameter($Target.Name)
                    $Handle        = $This.NewWiFiHandle()
                    $This.WlanConnect($Handle,[Ref]$xAdapter.Guid,[Ref]$Param,[IntPtr]::Zero)
                    $This.RemoveWifiHandle($Handle)
    
                    Start-Sleep 3
                    $This.Unselect()
                    $This.Select($Index)
    
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
            If ($This.Xaml.IO.FilterText.Text -ne "" -and $This.Output.Count -gt 0)
            {
                Start-Sleep -Milliseconds 50
                $This.Xaml.IO.Network.Items.Clear()
                $This.Output | ? $This.Xaml.IO.FilterProperty.SelectedItem.Content -match $This.Xaml.IO.FilterText.Text | % { $This.Xaml.IO.Network.Items.Add($_) }
            }
            Else
            {
                $This.Xaml.IO.Network.Items.Clear()
                $This.Output | % { $This.Xaml.IO.Network.Items.Add($_) }
            }
        }
    }

    Switch ($Mode)
    {
        0
        {
            [WirelessController]::New(0)
        }
        1
        {
            $Wifi      = [WirelessController]::New(1)
            $Wifi.Xaml.Invoke()
        }
    }
}
