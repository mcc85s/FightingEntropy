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
          FileName: Search-WirelessNetwork.ps1
          Solution: FightingEntropy Module
          Purpose: For scanning wireless networks (eventually for use in a PXE environment)
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2022-04-02
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:
.Example
#>
# Adds type for the PresentationFramework/GUI
Add-Type -AssemblyName PresentationFramework

Class Privelege
{
    [Object] $Principal
    [Bool]   $IsAdmin
    [Object] $Execution
    [Object] $Version
    [Bool]   $IsDesktop
    [Object] $Module
    [String] $Function
    Privelege()
    {
        # Checks the current Windows Identity
        $This.Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        If (!$This.Principal.IsInRole("Administrators"))
        {   
            # Throws if it's not a member of Administrators, prevents unauthorized usage  
            Throw "Insufficient privileges to run this program"
        }

        # Sets the IsAdmin flag
        $This.IsAdmin   = $True

        $This.Exec()
    }
    Requirements()
    {
        $This.Version   = Get-Variable PSVersionTable | % Value
        If ($This.Version.PSEdition -ne "Desktop")
        {
            Throw "Must use a Windows PowerShell v5.1 host, in order to use this function."
        }
        $This.IsDesktop = $True

        Try
        {
            Import-Module FightingEntropy -EA 0
            $This.Module = Get-FEModule
        }
        Catch
        {
            Throw "[FightingEntropy(π)][!] not installed, visit https://github.com/mcc85s/FightingEntropy" 
        }
    }
    Exec()
    {
        $This.Execution = Get-ExecutionPolicy
    }
}

$Srp = [Privelege]::New()
If ($Srp)
{
    If ($Srp.ExecutionPolicy -ne "Bypass")
    {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    }

    $Srp.Requirements()
    $Srp.Function = Invoke-RestMethod ("{0}/Scripts/Load-WirelessNetwork.ps1?raw=true" -f $Srp.Module.Base)
    If ($Srp.Function)
    {
        Invoke-Expression $Srp.Function
    }
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

    Class Wireless
    {
        Hidden [Object] $Module
        Hidden [String] $OEMLogo
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
        [String] Win32Exception([UInt32]$ReturnCode)
        {
            Return ("[System.ComponentModel.Win32Exception]::new($ReturnCode)" | Invoke-Expression)
        }
        [String] WiFiReasonCode([IntPtr]$ReasonCode)
        {
            $stringBuilder          = New-Object -TypeName Text.StringBuilder
            $stringBuilder.Capacity = 1024
            $result                 = [WiFi.ProfileManagement]::WlanReasonCodeToString($ReasonCode.ToInt32(),$stringBuilder.Capacity,$stringBuilder,[IntPtr]::zero)

            If ($result -ne 0)
            {
                Return $This.Win32Exception($result)
            }

            Return $stringBuilder.ToString()
        }
        [Void] WlanFreeMemory([IntPtr]$Pointer)
        {
            [WiFi.ProfileManagement]::WlanFreeMemory($Pointer)
        }
        [IntPtr] NewWifiHandle()
        {
            $maxClient               = 2
            [Ref] $negotiatedVersion = 0
            $clientHandle            = [IntPtr]::zero
            $result                  = [WiFi.ProfileManagement]::WlanOpenHandle($maxClient,[IntPtr]::Zero,$negotiatedVersion,[Ref]$clientHandle)

            If ($result -eq 0)
            {
                Return $clientHandle
            }
            Else
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Void] RemoveWifiHandle([IntPtr]$ClientHandle)
        {
            $result = [WiFi.ProfileManagement]::WlanCloseHandle($ClientHandle, [IntPtr]::zero)

            If ($result -ne 0)
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Object] GetWiFiInterfaceGuid([String]$WiFiAdapterName)
        {
            $InterfaceGuid   = $Null
            Switch ([Environment]::OSVersion.Version -ge [Version]6.2)
            {
                $True
                {
                    $InterfaceGuid   = Get-NetAdapter -Name $WiFiAdapterName -EA 0 | % InterfaceGuid
                }
                $False
                {
                    $wifiAdapterInfo = Get-WmiObject Win32_NetworkAdapter | ? NetConnectionID -eq $WiFiAdapterName
                    $InterfaceGuid   = Get-WmiObject Win32_NetworkAdapterConfiguration | ? Description -eq $WiFiAdapterInfo.Name | % SettingID
                }
            }
    
            Return [System.Guid]$InterfaceGuid
        }
        [Object[]] GetWiFiInterface()
        {
            $interfaceListPtr = 0
            $clientHandle     = $This.NewWiFiHandle()
            $This.Adapters    = $This.RefreshAdapterList()
            $Return           = @( )
            Try
            {
                [void][WiFi.ProfileManagement]::WlanEnumInterfaces($clientHandle, [IntPtr]::zero, [ref] $interfaceListPtr)
                $wiFiInterfaceList = [WiFi.ProfileManagement+WLAN_INTERFACE_INFO_LIST]::new($interfaceListPtr)
                ForEach ($wlanInterfaceInfo in $wiFiInterfaceList.wlanInterfaceInfo)
                {
                    $Info      = [WiFi.ProfileManagement+WLAN_INTERFACE_INFO]$wlanInterfaceInfo
                    $Interface = $This.Adapters | ? InterfaceDescription -eq $Info.Description
                    $Return   += [InterfaceObject]::New($Info,$Interface)
                }
            }
            Catch
            {
                Write-Host "No wireless interface(s) found"
                $Return += $Null
            }
            Finally
            {
                $This.RemoveWiFiHandle($clientHandle)
            }

            Return @($Return)
        }
        [Object[]] GetWiFiProfileList([String]$Name)
        {
            $profileListPointer = 0
            $Interface          = $This.GetWifiInterface() | ? Name -match $Name
            $ClientHandle       = $This.NewWifiHandle()
            $Return             = @( )

            [WiFi.ProfileManagement]::WlanGetProfileList($ClientHandle,$interface.GUID,[IntPtr]::zero,[ref] $profileListPointer)
            
            $ProfileList        = [WiFi.ProfileManagement+WLAN_PROFILE_INFO_LIST]::new($profileListPointer).ProfileInfo

            ForEach ($ProfileName in $ProfileList)
            {
                $Item           = [WiFiProfile]::New($Interface,$ProfileName)
                $Item.Detail    = $This.GetWiFiProfileInfo($Item.Name,$Interface.Guid)
                $Return        += $Item
            }

            $This.RemoveWiFiHandle($ClientHandle)

            Return $Return
        }
        [Object] GetWiFiProfileInfo([String]$ProfileName,[Guid]$InterfaceGuid,[Int16]$WlanProfileFlags)
        {
            [IntPtr]$ClientHandle    = $This.NewWifiHandle()
            $WlanProfileFlagsInput   = $WlanProfileFlags
            $Return                  = $This.WiFiProfileInfo($ProfileName,$InterfaceGuid,$ClientHandle,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($ClientHandle)
            Return $Return
        }
        [Object] GetWifiProfileInfo([String]$ProfileName,[Guid]$InterfaceGuid)
        {
            [IntPtr]$ClientHandle    = $This.NewWifiHandle()
            $WlanProfileFlagsInput   = 0
            $Return                  = $This.WiFiProfileInfo($ProfileName,$InterfaceGuid,$ClientHandle,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($ClientHandle)
            Return $Return
        }
        [Object] WiFiProfileInfo([String]$ProfileName,[Guid]$InterfaceGuid,[IntPtr]$ClientHandle,[Int16]$WlanProfileFlagsInput)
        {
            [String] $pstrProfileXml = $null
            $wlanAccess              = 0
            $WlanProfileFlags        = $WlanProfileFlagsInput
            $result                  = [WiFi.ProfileManagement]::WlanGetProfile($ClientHandle, $InterfaceGuid, $ProfileName, [IntPtr]::Zero, [ref] $pstrProfileXml, [ref] $WlanProfileFlags, [ref] $wlanAccess)
            $Password                = $Null
            $connectHiddenSSID       = $Null
            $EapType                 = $Null
            $xmlPtr                  = $Null
            $serverNames             = $Null
            $trustedRootCA           = $Null
            $Return                  = $Null

            If ($result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }

            $wlanProfile             = [xml] $pstrProfileXml

            # Parse password
            If ($WlanProfileFlagsInput -eq 13)
            {
                $Password            = $wlanProfile.WLANProfile.MSM.security.sharedKey.keyMaterial
            }
            If ($WlanProfileFlagsInput -ne 13)
            {
                $Password            = $Null
            }

            # Parse nonBroadcast flag
            If ([bool]::TryParse($wlanProfile.WLANProfile.SSIDConfig.nonBroadcast, [ref] $null))
            {
                $connectHiddenSSID   = [bool]::Parse($wlanProfile.WLANProfile.SSIDConfig.nonBroadcast)
            }
            Else
            {
                $connectHiddenSSID   = $false
            }

            # Parse EAP type
            If ($wlanProfile.WLANProfile.MSM.security.authEncryption.useOneX -eq $true)
            {
                $EapType = Switch ($wlanProfile.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.EapMethod.Type.InnerText)
                {   # 25 = EAP-PEAP (MSCHAPv2); 13 = EAP-TLS
                    25 { 'PEAP' } 13 { 'TLS'  } Default { 'Unknown' }
                }
            }
            Else
            {
                $EapType = $null
            }

            # Parse Validation Server Name
            If (!!$EapType)
            {
                Switch ($EapType)
                {
                    PEAP
                    { 
                        $serverNames = $wlanProfile.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.Eap.EapType.ServerValidation.ServerNames
                    }

                    TLS
                    {
                        $node        = $wlanProfile.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.SelectNodes("//*[local-name()='ServerNames']")
                        $serverNames = $node[0].InnerText
                    }
                }
            }
            
            # Parse Validation TrustedRootCA
            If (!!$EapType)
            {
                Switch ($EapType)
                {
                    PEAP
                    { 
                        $trustedRootCa = ([string] ($wlanProfile.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.Eap.EapType.ServerValidation.TrustedRootCA -replace ' ', [string]::Empty)).ToLower()
                    }

                    TLS
                    {
                        $node          = $wlanProfile.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $trustedRootCa = ([string] ($node[0].InnerText -replace ' ', [string]::Empty)).ToLower()
                    }
                }
            }

            $Return               = [WiFi.ProfileManagement+ProfileInfo]@{
                ProfileName       = $wlanProfile.WLANProfile.SSIDConfig.SSID.name
                ConnectionMode    = $wlanProfile.WLANProfile.connectionMode
                Authentication    = $wlanProfile.WLANProfile.MSM.security.authEncryption.authentication
                Encryption        = $wlanProfile.WLANProfile.MSM.security.authEncryption.encryption
                Password          = $password
                ConnectHiddenSSID = $connectHiddenSSID
                EAPType           = $EapType
                ServerNames       = $serverNames
                TrustedRootCA     = $trustedRootCa
                Xml               = $pstrProfileXml
            }
            
            $xmlPtr               = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($pstrProfileXml)
            $This.WlanFreeMemory($xmlPtr)

            Return $Return
        }
        [Object] GetWiFiConnectionParameter([String]$ProfileName,[String]$ConnectionMode,[String]$Dot11BssType,[String]$Flag)
        {
            Return $This.WifiConnectionParameter($ProfileName,$ConnectionMode,$Dot11BssType,$Flag)
        }
        [Object] GetWiFiConnectionParameter([String]$ProfileName,[String]$ConnectionMode,[String]$Dot11BssType)
        {
            $Flag           = "Default"
            Return $This.WifiConnectionParameter($ProfileName,$ConnectionMode,$Dot11BssType,$Flag)
        }
        [Object] GetWiFiConnectionParameter([String]$ProfileName,[String]$ConnectionMode)
        {
            $Dot11BssType   = "Any"
            $Flag           = "Default"
            Return $This.WifiConnectionParameter($ProfileName,$ConnectionMode,$Dot11BssType,$Flag)
        }
        [Object] GetWiFiConnectionParameter([String]$ProfileName)
        {
            $ConnectionMode = "Profile"
            $Dot11BssType   = "Any"
            $Flag           = "Default"
            Return $This.WifiConnectionParameter($ProfileName,$ConnectionMode,$Dot11BssType,$Flag)
        }
        [Object] WifiConnectionParameter([String]$ProfileName,[String]$ConnectionMode,[String]$Dot11BssType,[String]$Flag)
        {
            Try
            {
                $connectionModeResolver = @{
                    Profile           = 'WLAN_CONNECTION_MODE_PROFILE'
                    TemporaryProfile  = 'WLAN_CONNECTION_MODE_TEMPORARY_PROFILE'
                    DiscoverySecure   = 'WLAN_CONNECTION_MODE_DISCOVERY_SECURE'
                    DiscoveryUnsecure = 'WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE'
                    Auto              = 'WLAN_CONNECTION_MODE_AUTO'
                }

                $connectionParameters                    = [WiFi.ProfileManagement+WLAN_CONNECTION_PARAMETERS]::new()
                $connectionParameters.strProfile         = $ProfileName
                $connectionParameters.wlanConnectionMode = [WiFi.ProfileManagement+WLAN_CONNECTION_MODE]::$($connectionModeResolver[$ConnectionMode])
                $connectionParameters.dot11BssType       = [WiFi.ProfileManagement+DOT11_BSS_TYPE]::$Dot11BssType
                $connectionParameters.dwFlags            = [WiFi.ProfileManagement+WlanConnectionFlag]::$Flag
            }
            Catch
            {
                Throw "An error occurred while setting connection parameters"
            }

            Return $connectionParameters
        }
        [String] NewWifiXmlProfile_OldMethod([String]$SSID,[String]$Key)
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
        [Object] XmlTemplate([String]$Type)
        {
            $xList = "WiFiProfileXmlPersonal","WiFiProfileXmlEapPeap","WiFiProfileXmlEapTls"
            If ($Type -notin $xList)
            {
                Throw "Invalid type, select (1): [$($xList -join ", ")]"
            }
            
            $Return = Switch ($Type)
            {
                WiFiProfileXmlPersonal
                {
                    '<?xml version="1.0"?>',
                    '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">',
                    '  <name>{0}</name>',
                    '  <SSIDConfig>',
                    '    <SSID>',
                    '      <hex>{1}</hex>',
                    '      <name>{0}</name>',
                    '    </SSID>',
                    '  </SSIDConfig>',
                    '  <connectionType>ESS</connectionType>',
                    '  <connectionMode>{2}</connectionMode>',
                    '  <MSM>',
                    '    <security>',
                    '      <authEncryption>',
                    '        <authentication>{3}</authentication>',
                    '        <encryption>{4}</encryption>',
                    '        <useOneX>false</useOneX>',
                    '      </authEncryption>',
                    '      <sharedKey>',
                    '        <keyType>passPhrase</keyType>',
                    '        <protected>false</protected>',
                    '        <keyMaterial>{5}</keyMaterial>',
                    '      </sharedKey>',
                    '    </security>',
                    '  </MSM>',
                    '  <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',
                    "    <enableRandomization>false</enableRandomization>",
                    "  </MacRandomization>",
                    '</WLANProfile>'
                }
                WiFiProfileXmlEapPeap
                {
                    '<?xml version="1.0"?>',
                    '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">',
                    '  <name>{0}</name>',
                    '  <SSIDConfig>',
                    '    <SSID>',
                    '      <hex>{1}</hex>',
                    '      <name>{0}</name>',
                    '    </SSID>',
                    '  </SSIDConfig>',
                    '  <connectionType>ESS</connectionType>',
                    '  <connectionMode>{2}</connectionMode>',
                    '  <MSM>',
                    '    <security>',
                    '      <authEncryption>',
                    '        <authentication>{3}</authentication>',
                    '        <encryption>{4}</encryption>',
                    '        <useOneX>true</useOneX>',
                    '      </authEncryption>',
                    '      <PMKCacheMode>enabled</PMKCacheMode>',
                    '      <PMKCacheTTL>720</PMKCacheTTL>',
                    '      <PMKCacheSize>128</PMKCacheSize>',
                    '      <preAuthMode>disabled</preAuthMode>',
                    '      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">',
                    '        <authMode>machineOrUser</authMode>',
                    '        <EAPConfig>',
                    '          <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">',
                    '            <EapMethod>',
                    '              <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">25</Type>',
                    '              <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>',
                    '              <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>',
                    '              <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId>',
                    '            </EapMethod>',
                    '            <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">',
                    '              <Eap xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1">',
                    '                <Type>25</Type>',
                    '                <EapType xmlns="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1">',
                    '                  <ServerValidation>',
                    '                    <DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>',
                    '                    <ServerNames></ServerNames>',
                    '                    <TrustedRootCA></TrustedRootCA>',
                    '                  </ServerValidation>',
                    '                  <FastReconnect>true</FastReconnect>',
                    '                  <InnerEapOptional>false</InnerEapOptional>',
                    '                  <Eap xmlns="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1">',
                    '                    <Type>26</Type>',
                    '                    <EapType xmlns="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1">',
                    '                      <UseWinLogonCredentials>false</UseWinLogonCredentials>',
                    '                    </EapType>',
                    '                  </Eap>',
                    '                  <EnableQuarantineChecks>false</EnableQuarantineChecks>',
                    '                  <RequireCryptoBinding>false</RequireCryptoBinding>',
                    '                  <PeapExtensions>',
                    '                    <PerformServerValidation xmlns="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2">true</PerformServerValidation>',
                    '                    <AcceptServerName xmlns="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2">true</AcceptServerName>',
                    '                    <PeapExtensionsV2 xmlns="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2">',
                    '                      <AllowPromptingWhenServerCANotFound xmlns="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV3">true</AllowPromptingWhenServerCANotFound>',
                    '                    </PeapExtensionsV2>',
                    '                  </PeapExtensions>',
                    '                </EapType>',
                    '              </Eap>',
                    '            </Config>',
                    '          </EapHostConfig>',
                    '        </EAPConfig>',
                    '      </OneX>',
                    '    </security>',
                    '  </MSM>',
                    '  <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',
                    "    <enableRandomization>false</enableRandomization>",
                    "  </MacRandomization>",
                    '</WLANProfile>'
                }
                WiFiProfileXmlEapTls
                {
                    '<?xml version="1.0"?>',
                    '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">',
                    '  <name>{0}</name>',
                    '  <SSIDConfig>',
                    '    <SSID>',
                    '      <hex>{1}</hex>',
                    '      <name>{0}</name>',
                    '    </SSID>',
                    '  </SSIDConfig>',
                    '  <connectionType>ESS</connectionType>',
                    '  <connectionMode>{2}</connectionMode>',
                    '  <MSM>',
                    '    <security>',
                    '      <authEncryption>',
                    '        <authentication>{3}</authentication>',
                    '        <encryption>{4}</encryption>',
                    '        <useOneX>true</useOneX>',
                    '      </authEncryption>',
                    '      <PMKCacheMode>enabled</PMKCacheMode>',
                    '      <PMKCacheTTL>720</PMKCacheTTL>',
                    '      <PMKCacheSize>128</PMKCacheSize>',
                    '      <preAuthMode>disabled</preAuthMode>',
                    '      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">',
                    '        <authMode>machineOrUser</authMode>',
                    '        <EAPConfig>',
                    '          <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">',
                    '            <EapMethod>',
                    '              <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">13</Type>',
                    '              <VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorId>',
                    '              <VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0</VendorType>',
                    '              <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId>',
                    '            </EapMethod>',
                    '            <Config xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1" xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1">',
                    '              <baseEap:Eap>',
                    '                <baseEap:Type>13</baseEap:Type>',
                    '                <eapTls:EapType>',
                    '                  <eapTls:CredentialsSource>',
                    '                    <eapTls:CertificateStore />',
                    '                  </eapTls:CredentialsSource>',
                    '                  <eapTls:ServerValidation>',
                    '                    <eapTls:DisableUserPromptForServerValidation>false</eapTls:DisableUserPromptForServerValidation>',
                    '                    <eapTls:ServerNames></eapTls:ServerNames>',
                    '                    <eapTls:TrustedRootCA></eapTls:TrustedRootCA>',
                    '                  </eapTls:ServerValidation>',
                    '                  <eapTls:DifferentUsername>false</eapTls:DifferentUsername>',
                    '                </eapTls:EapType>',
                    '              </baseEap:Eap>',
                    '            </Config>',
                    '          </EapHostConfig>',
                    '        </EAPConfig>',
                    '      </OneX>',
                    '    </security>',
                    '  </MSM>',
                    '  <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',
                    "    <enableRandomization>false</enableRandomization>",
                    "  </MacRandomization>",
                    '</WLANProfile>'
                }
            }

            Return ($Return -join "`n") 
        }
        [String] NewWiFiProfileXmlPsk([String]$ProfileName,[String]$ConnectionMode='auto',[String]$Authentication='WPA2PSK',[String]$Encryption='AES',[SecureString]$Password)
        {
            $PlainPassword = $Null
            $ProfileXml    = $Null
            $Hex           = ($ProfileName.ToCharArray() | % { '{0:X}' -f [int]$_ }) -join ''
            Try
            {
                If ($Password)
                {
                    $secureStringToBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
                    $plainPassword      = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($secureStringToBstr)
                }
                
                $profileXml             = [XML]($This.XmlTemplate("WiFiProfileXmlPersonal") -f $ProfileName, $Hex, $ConnectionMode, $Authentication, $Encryption, $plainPassword)
                If (!$plainPassword)
                {
                    $null = $profileXml.WLANProfile.MSM.security.RemoveChild($profileXml.WLANProfile.MSM.security.sharedKey)
                }

                If ($Authentication -eq 'WPA3SAE')
                {
                    # Set transition mode as true for WPA3-SAE
                    $nsmg = [System.Xml.XmlNamespaceManager]::new($profileXml.NameTable)
                    $nsmg.AddNamespace('WLANProfile', $profileXml.DocumentElement.GetAttribute('xmlns'))
                    $refNode = $profileXml.SelectSingleNode('//WLANProfile:authEncryption', $nsmg)
                    $xmlnode = $profileXml.CreateElement('transitionMode', 'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $xmlnode.InnerText = 'true'
                    $null = $refNode.AppendChild($xmlnode)
                }

                Return $This.FormatXml($profileXml.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [String] NewWifiProfileXmlEap([String]$ProfileName,[String]$ConnectionMode='auto',[String]$Authentication='WPA2PSK',[String]$Encryption='AES',[String]$EAPType,[String[]]$ServerNames,[String]$TrustedRootCA)
        {
            $ProfileXml = $Null
            $Hex        = ($ProfileName.ToCharArray() | % { '{0:X}' -f [int]$_ }) -join ''
            Try
            {
                If ($EAPType -eq 'PEAP')
                {
                    $profileXml = [Xml] ($This.XmlTemplate("WiFiProfileXmlEap$EapType") -f $ProfileName, $Hex, $ConnectionMode, $Authentication, $Encryption)

                    If ($ServerNames)
                    {
                        $profileXml.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.Eap.EapType.ServerValidation.ServerNames = $ServerNames
                    }

                    If ($TrustedRootCA)
                    {
                        [String]$formattedCaHash = $TrustedRootCA -replace '..', '$& '
                        $profileXml.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config.Eap.EapType.ServerValidation.TrustedRootCA = $formattedCaHash
                    }
                }
                ElseIf ($EAPType -eq 'TLS')
                {
                    $profileXml = [Xml] ($This.XmlTemplate("WiFiProfileXmlEap$EapType") -f $ProfileName, $Hex, $ConnectionMode, $Authentication, $Encryption)

                    If ($ServerNames)
                    {
                        $node = $profileXml.WLANProfile.MSM.security.OneX.EapConfig.EapHostConfig.Config.SelectNodes("//*[local-name()='ServerNames']")
                        $node[0].InnerText = $ServerNames
                    }

                    If ($TrustedRootCA)
                    {
                        [String]$formattedCaHash = $TrustedRootCA -replace '..', '$& '
                        $node = $profileXml.WLANProfile.MSM.security.OneX.EapConfig.EapHostConfig.Config.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $node[0].InnerText = $formattedCaHash
                    }
                }

                If ($Authentication -eq 'WPA3SAE')
                {
                    # Set transition mode as true for WPA3-SAE
                    $nsmg = [System.Xml.XmlNamespaceManager]::new($profileXml.NameTable)
                    $nsmg.AddNamespace('WLANProfile', $profileXml.DocumentElement.GetAttribute('xmlns'))
                    $refNode = $profileXml.SelectSingleNode('//WLANProfile:authEncryption', $nsmg)
                    $xmlnode = $profileXml.CreateElement('transitionMode', 'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $xmlnode.InnerText = 'true'
                    $null = $refNode.AppendChild($xmlnode)
                }

                Return $This.FormatXml($profileXml.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [Object] NewWiFiProfilePsk([String]$ProfileName,[String]$Password,[String]$WiFiAdapterName)
        {
            $ConnectionMode  = 'auto'
            $Authentication  = 'WPA2PSK'
            $Encryption      = 'AES'
            $ProfileTemp     = $This.NewWifiProfileXmlPsk($ProfileName,$ConnectionMode,$Authentication,$Encryption,$Password)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWiFiProfilePsk([String]$ProfileName,[String]$Password,[String]$ConnectionMode,[String]$WiFiAdapterName)
        {
            $Authentication  = 'WPA2PSK'
            $Encryption      = 'AES'
            $ProfileTemp     = $This.NewWifiProfileXmlPsk($ProfileName,$ConnectionMode,$Authentication,$Encryption)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWiFiProfilePsk([String]$ProfileName,[String]$Password,[String]$ConnectionMode,[String]$Authentication,[String]$WiFiAdapterName)
        {
            $Encryption      = 'AES'
            $ProfileTemp     = $This.NewWifiProfileXmlPsk($ProfileName,$ConnectionMode,$Authentication,$Encryption,$WiFiAdapterName)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWiFiProfilePsk([String]$ProfileName,[String]$Password,[String]$ConnectionMode,[String]$Authentication,[String]$Encryption,[String]$WiFiAdapterName)
        {
            $ProfileTemp     = $This.NewWifiProfileXmlPsk($ProfileName,$ConnectionMode,$Authentication,$Encryption,$WiFiAdapterName)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$EapType,[String]$WifiAdapterName)
        {
            $ConnectionMode    = 'auto'
            $Authentication    = 'WPA2PSK'
            $Encryption        = 'AES'
            $ServerNames       = ''
            $TrustedRootCA     = $Null
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$ConnectionMode,[String]$EapType,[String]$WifiAdapterName)
        {
            $Authentication    = 'WPA2PSK'
            $Encryption        = 'AES'
            $ServerNames       = ''
            $TrustedRootCA     = $Null
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$ConnectionMode,[String]$Authentication,[String]$EapType,[String]$WifiAdapterName)
        {
            $Encryption        = 'AES'
            $ServerNames       = ''
            $TrustedRootCA     = $Null
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$ConnectionMode,[String]$Authentication,[String]$Encryption,[String]$EapType,[String]$WifiAdapterName)
        {
            $ServerNames       = ''
            $TrustedRootCA     = $Null
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$ConnectionMode,[String]$Authentication,[String]$Encryption,[String]$EapType,[String[]]$ServerNames,[String]$WifiAdapterName)
        {
            $TrustedRootCA     = $Null
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileEap([String]$ProfileName,[String]$ConnectionMode,[String]$Authentication,[String]$Encryption,[String]$EapType,[String[]]$ServerNames,[String]$TrustedRootCA,[String]$WifiAdapterName)
        {
            $ProfileTemp       = $This.NewWifiProfileXmlEap($ProfileName,$ConnectionMode,$Authentication,$Encryption,$EapType,$ServerNames,$TrustedRootCA)
            Return $This.NewWifiProfile($ProfileTemp,$WiFiAdapterName)
        }
        [Object] NewWifiProfileXml([String]$ProfileXml,[String]$WiFiAdapterName,[Bool]$Overwrite)
        {
            Return $This.NewWifiProfile($ProfileXml,$WiFiAdapterName)
        }
        [String] FormatXml([String]$ProfileXml)
        {
            $StringWriter          = [System.IO.StringWriter]::New()
            $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
            $XmlWriter.Formatting  = "indented"
            $XmlWriter.Indentation = 4
            ([Xml]$ProfileXml).WriteContentTo($XmlWriter)
            $XmlWriter.Flush()
            $StringWriter.Flush()
            Return $StringWriter.ToString()
        }
        NewWifiProfile([String]$ProfileXml,[String]$WiFiAdapterName,[Bool]$Overwrite)
        {
            Try
            {
                $interfaceGuid       = $This.GetWiFiInterfaceGuid($WiFiAdapterName)
                $clientHandle        = $This.NewWiFiHandle()
                $flags               = 0
                $reasonCode          = [IntPtr]::Zero
                $profilePointer      = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($profileXML)    
                $returnCode          = [WiFi.ProfileManagement]::WlanSetProfile($clientHandle,[ref] $interfaceGuid,$flags,$profilePointer,[IntPtr]::Zero,$Overwrite,[IntPtr]::Zero,[ref]$reasonCode)
                $returnCodeMessage   = $This.Win32Exception($ReturnCode)
                $reasonCodeMessage   = $This.WiFiReasonCode($ReasonCode)

                <#
                $interfaceGuid       = $Wifi.GetWiFiInterfaceGuid($WiFiAdapterName)
                $clientHandle        = $Wifi.NewWiFiHandle()
                $flags               = 0
                $reasonCode          = [IntPtr]::Zero
                $profilePointer      = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($profileXML)    
                $returnCode          = [WiFi.ProfileManagement]::WlanSetProfile($clientHandle,[ref] $interfaceGuid,$flags,$profilePointer,[IntPtr]::Zero,$Overwrite,[IntPtr]::Zero,[ref]$reasonCode)
                $returnCodeMessage   = $Wifi.Win32Exception($ReturnCode)
                $reasonCodeMessage   = $Wifi.WiFiReasonCode($ReasonCode)
                #>

                If ($returnCode -eq 0)
                {
                    Write-Verbose -Message $returnCodeMessage
                }
                Else
                {
                    throw $returnCodeMessage
                }

                Write-Verbose -Message $reasonCodeMessage
            }
            Catch
            {
                Throw "Failed to create the profile"
            }
            Finally
            {
                If ($clientHandle)
                {
                    $This.RemoveWiFiHandle($clientHandle)
                }
            }
        }
        RemoveWifiProfile([String]$ProfileName)
        {
            $ClientHandle = $This.NewWiFiHandle()
            [WiFi.ProfileManagement]::WlanDeleteProfile($clientHandle,[Ref]$This.Selected.Guid,$ProfileName,[IntPtr]::Zero)
            $This.RemoveWifiHandle($ClientHandle)
        }
        Select([String]$Description)
        {
            # Select the adapter from its description
            $This.Selected                  = $This.GetWifiInterface() | ? Description -eq $Description

            # Set other Xaml fields
            $This.Xaml.IO.Index.Text        = $This.Selected.ifIndex
            $This.Xaml.IO.MacAddress.Text   = $This.Selected.MacAddress

            $This.Update()
        }
        Unselect()
        {
            $This.Selected                  = $Null
            $This.Xaml.IO.Index.Text        = $Null
            $This.Xaml.IO.MacAddress.Text   = $Null

            $This.Update()
        }
        Disconnect()
        {
            If (!$This.Selected)
            {
                Write-Host "No network selected"
            }
            If ($This.Selected.State -eq "CONNECTED")
            {
                $ClientHandle                      = $This.NewWiFiHandle()
                [WiFi.ProfileManagement]::WlanDisconnect($ClientHandle, [Ref] $This.Selected.Guid, [IntPtr]::Zero)
                $This.RemoveWifiHandle($ClientHandle)

                <# For Testing
                $ClientHandle                      = $Wifi.NewWiFiHandle()
                [WiFi.ProfileManagement]::WlanDisconnect($ClientHandle, [Ref] $Wifi.Selected.Guid, [IntPtr]::Zero)
                $Wifi.RemoveWifiHandle($ClientHandle)
                #>

                $This.Connected                    = $Null
                Show-ToastNotification -Type Image -Mode 2 -Image $This.OEMLogo -Message "Disconnected: $($This.Xaml.IO.Ssid.Text)"

                $Link                              = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)
                $This.Xaml.IO.Ssid.Text            = "<Not connected>"
                $This.Xaml.IO.Bssid.Text           = "<Not connected>"
                $This.Xaml.IO.Disconnect.IsEnabled = 0
                $This.Xaml.IO.Connect.IsEnabled    = 0
                $This.Xaml.IO.Output.SelectedIndex = -1
            }
        }
        Connect([String]$SSID)
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
                    $Result = $This.GetWifiProfileInfo($SSID,$This.Selected.Guid)
                    If ($Result)
                    {
                        $Param  = $This.GetWiFiConnectionParameter($SSID)

                        $ClientHandle                      = $This.NewWiFiHandle()
                        [WiFi.ProfileManagement]::WlanConnect($ClientHandle, [Ref] $This.Selected.Guid, [Ref] $Param, [IntPtr]::Zero)
                        $This.RemoveWifiHandle($ClientHandle)

                        <# For Testing
                        $Param = $Wifi.GetWifiConnectionParameter($SSID)
                        $ClientHandle                      = $Wifi.NewWiFiHandle()
                        [WiFi.ProfileManagement]::WlanConnect($ClientHandle, [Ref] $Wifi.Selected.Guid, [Ref] $Param, [IntPtr]::Zero)
                        $Wifi.RemoveWifiHandle($ClientHandle)
                        #>

                        $Link                              = $This.Selected.Description
                        $This.Unselect()
                        $This.Select($Link)
                        
                        $This.Update()
                        Show-ToastNotification -Type Image -Mode 2 -Image $This.OEMLogo -Message "Connected: $SSID"
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
            }
        }
        Passphrase([Object]$Ctrl,[Object]$Network)
        {
            $Pass    = [XamlWindow][Passphrase]::Tab
            $Auth    = $Null
            $Enc     = $Null
            $Pass.IO.Connect.Add_Click(
            {
                If ($Network.Authentication -match "RsnaPsk")
                {
                    $Auth      = "WPA2PSK"
                }
                If ($Network.Encryption -match "Ccmp")
                {
                    $Enc       = "AES"
                }
                $Password      = $Pass.IO.Passphrase.Password
                $SP            = $Password | ConvertTo-SecureString -AsPlainText -Force
                $ProfileXml    = $Ctrl.NewWifiProfileXmlPsk($Network.Name,"manual",$Auth,$Enc,$SP)
                $Ctrl.NewWifiProfile($ProfileXml,$Ctrl.Selected.Name,$True)
                    
                $Param         = $Ctrl.GetWiFiConnectionParameter($Network.Name)
                $ClientHandle  = $Ctrl.NewWiFiHandle()
                [WiFi.ProfileManagement]::WlanConnect($ClientHandle, [Ref] $Ctrl.Selected.Guid, [Ref] $Param, [IntPtr]::Zero)
                $Ctrl.RemoveWifiHandle($ClientHandle)

                Start-Sleep 3
                $Link                              = $Ctrl.Selected.Description
                $Ctrl.Unselect()
                $Ctrl.Select($Link)

                $Ctrl.Update()
                If ($Ctrl.Connected)
                {
                    $Pass.IO.DialogResult = $True
                    Show-ToastNotification -Type Image -Mode 2 -Image $This.OEMLogo -Message "Connected: $($Network.Name)"
                }
                If (!$Ctrl.Connected)
                {
                    $Ctrl.RemoveWifiProfile($Network.Name)
                    Show-ToastNotification -Type Image -Mode 2 -Image $This.OEMLogo -Message "Unsuccessful: Passphrase failure"
                }
            })

            $Pass.IO.Cancel.Add_Click(
            {
                $Pass.IO.DialogResult = $False
            })

            $Pass.Invoke()
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
        }
        Wireless()
        {
            [Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType=WindowsRuntime] > $Null
            [Windows.Devices.Radios.RadioAccessStatus, Windows.System.Devices, ContentType=WindowsRuntime] > $Null 
            [Windows.Devices.Radios.RadioState, Windows.System.Devices, ContentType=WindowsRuntime] > $Null

            # Prime the module
            $This.Module   = Get-FEModule
            $This.OEMLogo  = $This.Module.Graphics | ? Name -eq OEMLogo.bmp | % Fullname

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
            Return @( Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)")
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
        If (!$Wifi.Connected)
        {
            $Xaml.IO.Disconnect.IsEnabled     = 0

            If ($Xaml.IO.Output.SelectedIndex -eq -1)
            {
                $Xaml.IO.Connect.IsEnabled    = 0
            }

            If ($Xaml.IO.Output.SelectedIndex -ne -1)
            {
                $Xaml.IO.Connect.IsEnabled    = 1
            }
        }
        If ($Wifi.Connected)
        {
            $Xaml.IO.Connect.IsEnabled        = 0
            $Xaml.IO.Disconnect.IsEnabled     = 1
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
            $Test = $Wifi.GetWifiProfileInfo($Xaml.IO.Output.SelectedItem.Name,$Wifi.Selected.Guid)
            If ($Test -notmatch "Element not found")
            {
                $Wifi.Connect($Xaml.IO.Output.SelectedItem.Name)
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
                $Network = $Xaml.IO.Output.SelectedItem
                $Wifi.Passphrase($Wifi,$Network)
                $Wifi.Update()
            }
        }
        If ($Wifi.Connected)
        {
            $Wifi.Update()
        }
    })

    $Xaml.IO.Disconnect.Add_Click(
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
            $Xaml.IO.Disconnect.IsEnabled = 0
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
