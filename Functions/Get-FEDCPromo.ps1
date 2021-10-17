<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEDCPromo.ps1
          Solution: FightingEntropy Module
          Purpose: For the promotion of a FightingEntropy (ADDS/Various) Domain Controller
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-14
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEDCPromo
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [ValidateSet("Forest","Tree","Child","Clone")]
    [Parameter(ParameterSetname=1)][String]$Type,
    [Parameter()][Switch]$Test)

    # Load Assemblies
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms
    Import-Module FightingEntropy
    
    # Check for server operating system
    If (Get-CimInstance Win32_OperatingSystem | ? Caption -notmatch Server)
    {
        Throw "Must use Windows Server operating system"
    }

    # [System Classes]
    Class SysNetwork
    {
        [String]$Name
        [UInt32]$Index
        [String]$IPAddress
        [String]$SubnetMask
        [String]$Gateway
        [String[]] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        SysNetwork([Object]$If)
        {
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway     | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = $IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DhcpServer = $IF.DhcpServer           | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
    }

    Class SysDisk
    {
        [String] $Name
        [String] $Label
        [String] $FileSystem
        [String] $Size
        [String] $Free
        [String] $Used
        SysDisk([Object]$Disk)
        {
            $This.Name       = $Disk.DeviceID
            $This.Label      = $Disk.VolumeName
            $This.FileSystem = $Disk.FileSystem
            $This.Size       = "{0:n2} GB" -f ($Disk.Size/1GB)
            $This.Free       = "{0:n2} GB" -f ($Disk.FreeSpace/1GB)
            $This.Used       = "{0:n2} GB" -f (($Disk.Size-$Disk.FreeSpace)/1GB)
        }
    }

    Class SysProcessor
    {
        [String]$Name
        [String]$Caption
        [String]$DeviceID
        [String]$Manufacturer
        [UInt32]$Speed
        SysProcessor([Object]$CPU)
        {
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.DeviceID     = $CPU.DeviceID
            $This.Manufacturer = $CPU.Manufacturer
            $This.Speed        = $CPU.MaxClockSpeed
        }
    }

    Class System
    {
        [Object] $Manufacturer
        [Object] $Model
        [Object] $Product
        [Object] $Serial
        [Object[]] $Processor
        [String] $Memory
        [String] $Architecture
        [Object] $UUID
        [Object] $Chassis
        [Object] $BiosUEFI
        [Object] $AssetTag
        [Object[]] $Disk
        [Object[]] $Network
        System()
        {
            Write-Host "Collecting [~] Disks"
            $This.Disk             = Get-WmiObject -Class Win32_LogicalDisk    | % {     [SysDisk]$_ }
            
            Write-Host "Collecting [~] Network"
            $This.Network          = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ? DefaultIPGateway | % { [SysNetwork]$_ }
            
            Write-Host "Collecting [~] Processor"
            $This.Processor        = Get-WmiObject -Class Win32_Processor      | % { [SysProcessor]$_ }
            
            Write-Host "Collecting [~] Computer"
            Get-WmiObject Win32_ComputerSystem        | % { 

                $This.Manufacturer = $_.Manufacturer; 
                $This.Model        = $_.Model; 
                $This.Memory       = "{0}GB" -f [UInt32]($_.TotalPhysicalMemory/1GB)
            }

            Write-Host "Collecting [~] Product"
            Get-WmiObject Win32_ComputerSystemProduct | % { 
                $This.UUID         = $_.UUID 
            }

            Write-Host "Collecting [~] Motherboard"
            Get-WmiObject Win32_BaseBoard             | % { 
                $This.Product      = $_.Product
                $This.Serial       = $_.SerialNumber -Replace "\.",""
            }
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }
        
            Write-Host "Collecting [~] Chassis"
            Get-WmiObject Win32_SystemEnclosure | % {
                $This.AssetTag    = $_.SMBIOSAssetTag.Trim()
                $This.Chassis     = Switch([UInt32]$_.ChassisTypes[0])
                {
                    {$_ -in 8..12+14,18,21} {"Laptop"}
                    {$_ -in 3..7+15,16}     {"Desktop"}
                    {$_ -in 23}             {"Server"}
                    {$_ -in 34..36}         {"Small Form Factor"}
                    {$_ -in 30..32+13}      {"Tablet"}
                }
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[$Env:PROCESSOR_ARCHITECTURE]
        }
    }

    # Profile Classes
    Class ProfileItem
    {
        [String]                  $Name
        [String]                  $Type
        [Bool]               $IsEnabled
        [String]              $Property
        [Object]                 $Value
        [Object]                 $Check
        [Object]                $Reason
        ProfileItem([String]$Name,[Bool]$IsEnabled)
        {
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
            $This.Check     = $False
        }
    }
    Class ProfileRole
    {
        [String] $Name
        [Bool]   $IsEnabled
        [Bool]   $IsChecked
        ProfileRole([String]$Name,[Bool]$IsEnabled,[Bool]$IsChecked)
        {
            $This.Name      = $Name
            $This.IsEnabled = $IsEnabled
            $This.IsChecked = $IsChecked
        }
    }
    Class ProfilePassword
    {
        [String] $Name
        [Object] $Value
        [Object] $Check
        [Object] $Reason
        ProfilePassword([String]$Name)
        {
            $This.Name = $Name
        }
    }
    Class Profile
    {
        [UInt32]              $Mode
        Hidden [Hashtable]    $Tags = @{ 

            Slot                    = "Forest Tree Child Clone" -Split " "
            Item                    = "ForestMode DomainMode ReplicationSourceDC SiteName Parent{0} {0} Domain{1} New{0} NewDomain{1}" -f "DomainName","NetBIOSName" -Split " "
            Role                    = "InstallDns CreateDnsDelegation CriticalReplicationOnly NoGlobalCatalog" -Split " "
        }
        [Object]              $Slot
        [Object]              $Item
        [Object]              $Role
        [Object]              $DSRM
        Profile([UInt32]$Mode)
        {
            If ($Mode -notin 0..3)
            {
                Throw "Invalid Entry"
            }

            $This.Mode              = $Mode
            $This.Slot              = $This.Tags.Slot[$Mode]
            $This.Item              = $This.Tags.Item | % { $This.GetFEDCPromoItem($Mode,$_) }
            $This.Role              = $This.Tags.Role | % { $This.GetFEDCPromoRole($Mode,$_) }
            $This.DSRM              = "Password","Confirm" | % { [ProfilePassword]::New($_) }

            ForEach ($X in 0..($This.Item.Count-1))
            {
                $IX                 = $This.Item[$X]
                $IX.Type            = @("ComboBox","TextBox")[@(0,0,0,0,1,1,1,1,1)[$X]]
                $IX.Property        = @("SelectedIndex","Text")[@(0,0,0,0,1,1,1,1,1)[$X]]
                $IX.Value           = Switch ($IX.Name)
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
        [Object] GetFEDCPromoItem([UInt32]$Mode,[String]$Type)
        {
            $X                   = Switch($Type)
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
            }

            Return [ProfileItem]::New($Type,$X[$Mode])
        }
        [Object] GetFEDCPromoRole([UInt32]$Mode,[String]$Type)
        {
            $X                   = Switch($Type)
            {
                InstallDNS              {(1,1,1,1),(1,1,1,1)}
                CreateDNSDelegation     {(1,1,1,1),(0,0,1,0)}
                NoGlobalCatalog         {(0,1,1,1),(0,0,0,0)}
                CriticalReplicationOnly {(0,0,0,1),(0,0,0,0)}
            }

            Return [ProfileRole]::New($Type,$X[0][$Mode],$X[1][$Mode])
        }
        SetItem([String]$Name,[Object]$Value)
        {
            $This.Item | ? Name -eq $Name | % { $_.Value = $Value }
        }
    }

    Class Execution
    {
        [Object] $Services
        [Object] $Output
        Execution()
        {

        }
    }

    # Usable classes
    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object]               $Node
        [Object]                 $IO
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 

                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If ( !$Xaml )
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ( $I in 0..( $This.Names.Count - 1 ) )
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }

    # (Get-Content $Home\Desktop\FEDCFound.xaml) | % { "'$_'," } | Set-Clipboard
    Class FEDCFoundGUI
    {
        Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Found" Width="550" Height="260" HorizontalAlignment="Center" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
        '            <ImageBrush Stretch="None" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
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

    # (Get-Content $Home\Desktop\FEDCPromo.xaml) | % { "'$_'," } | Set-Clipboard
    Class FEDCPromoGUI
    {
        Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Promotion" Width="800" Height="800" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="GroupBox" x:Key="xGroupBox">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="Padding" Value="10"/>',
        '            <Setter Property="Margin" Value="10"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="GroupBox">',
        '                        <Border CornerRadius="10" Background="LightYellow" BorderBrush="Black" BorderThickness="3">',
        '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
        '                        </Border>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Margin" Value="3"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
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
        '            <Setter Property="PasswordChar" Value="*"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalAlignment" Value="Right"/>',
        '            <Setter Property="Margin" Value="3"/>',
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
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '        </Style>',
        '        <Style TargetType="TextBox" x:Key="Block">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="170"/>',
        '            <Setter Property="FontFamily" Value="System"/>',
        '            <Setter Property="FontSize" Value="12"/>',
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
        '        <Style TargetType="TextBlock">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
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
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" Value="0">',
        '                    <Setter Property="Background" Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="{x:Type ToolTip}">',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="LightGreen"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="UniformToFill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="24"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <Menu Grid.Row="0" Height="20">',
        '            <MenuItem Header="Command">',
        '                <MenuItem Name="Forest" Header="Install-ADDSForest"           IsCheckable="True"/>',
        '                <MenuItem Name="Tree"   Header="Install-ADDSDomain(Tree)"     IsCheckable="True"/>',
        '                <MenuItem Name="Child"  Header="Install-ADDSDomain(Child)"    IsCheckable="True"/>',
        '                <MenuItem Name="Clone"  Header="Install-ADDSDomainController" IsCheckable="True"/>',
        '            </MenuItem>',
        '        </Menu>',
        '        <Grid Grid.Row="1">',
        '            <GroupBox Style="{StaticResource xGroupBox}">',
        '                <GroupBox.Background>',
        '                    <SolidColorBrush Color="LightYellow"/>',
        '                </GroupBox.Background>',
        '                <Grid Margin="5">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Name="_ForestMode" Header="[Forest Mode]" Visibility="Collapsed">',
        '                            <ComboBox Name="ForestMode"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Name="_DomainMode" Header="[Domain Mode]" Visibility="Collapsed">',
        '                            <ComboBox Name="DomainMode"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="0" Name="_ParentDomainName" Header="[Parent Domain Name]" Visibility="Collapsed">',
        '                            <Grid>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="25"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <TextBox Grid.Column="0" Name="ParentDomainName"     Text="&lt;Domain Name&gt;"/>',
        '                                <Image   Grid.Column="1" Name="ParentDomainNameIcon"/>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Name="_ReplicationSourceDC" Header="[Replication Source DC]" Visibility="Collapsed">',
        '                            <ComboBox Name="ReplicationSourceDC"/>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="1.25*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="400"/>',
        '                            <RowDefinition Height="200"/>',
        '                        </Grid.RowDefinitions>',
        '                        <GroupBox Grid.Row="0" Grid.Column="0" Header="[Required Features]">',
        '                            <DataGrid Name="Features">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="180" Binding="{Binding Name}" CanUserSort="True" IsReadOnly="True"/>',
        '                                    <DataGridTextColumn Header="Type" Width="60"  Binding="{Binding Type}" CanUserSort="True" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Install" Width="50">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <CheckBox IsEnabled="{Binding Enabled}" IsChecked="{Binding Install,Mode=TwoWay,UpdateSourceTrigger=PropertyChanged,NotifyOnTargetUpdated=True}" Margin="0" Height="18" HorizontalAlignment="Left"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Row="1" Grid.Column="0" Header="[Roles]">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="24"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <CheckBox Grid.Column="0" Grid.Row="0" Name="InstallDNS" IsChecked="True"/>',
        '                                <CheckBox Grid.Column="0" Grid.Row="1" Name="CreateDNSDelegation"/>',
        '                                <CheckBox Grid.Column="0" Grid.Row="2" Name="NoGlobalCatalog"/>',
        '                                <CheckBox Grid.Column="0" Grid.Row="3" Name="CriticalReplicationOnly"/>',
        '                                <Label    Grid.Column="1" Grid.Row="0" Content="Install DNS"/>',
        '                                <Label    Grid.Column="1" Grid.Row="1" Content="Create DNS Delegation"/>',
        '                                <Label    Grid.Column="1" Grid.Row="2" Content="No Global Catalog"/>',
        '                                <Label    Grid.Column="1" Grid.Row="3" Content="Critical Replication Only"/>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                        <Grid Grid.Row="0" Grid.Column="1">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="240"/>',
        '                                <RowDefinition Height="160"/>',
        '                                <RowDefinition Height="160"/>',
        '                            </Grid.RowDefinitions>',
        '                            <GroupBox Grid.Row="0" Header="[Names]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Row="0" Grid.Column="0" Content="Domain" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox  Grid.Row="0" Grid.Column="1" Name="DomainName"/>',
        '                                    <Image    Grid.Row="0" Grid.Column="2" Name="DomainNameIcon"/>',
        '                                    <Label    Grid.Row="1" Grid.Column="0" Content="New Domain" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox  Grid.Row="1" Grid.Column="1" Name="NewDomainName"/>',
        '                                    <Image    Grid.Row="1" Grid.Column="2" Name="NewDomainNameIcon"/>',
        '                                    <Label    Grid.Row="2" Grid.Column="0" Content="NetBIOS" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox  Grid.Row="2" Grid.Column="1" Name="DomainNetBIOSName"/>',
        '                                    <Image    Grid.Row="2" Grid.Column="2" Name="DomainNetBIOSNameIcon"/>',
        '                                    <Label    Grid.Row="3" Grid.Column="0" Content="New NetBIOS" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox  Grid.Row="3" Grid.Column="1" Name="NewDomainNetBIOSName"/>',
        '                                    <Image    Grid.Row="3" Grid.Column="2" Name="NewDomainNetBIOSNameIcon"/>',
        '                                    <Label    Grid.Row="4" Grid.Column="0" Content="Site" HorizontalContentAlignment="Center"/>',
        '                                    <ComboBox Grid.Row="4" Grid.Column="1" Name="SiteName"/>',
        '                                    <Image    Grid.Row="4" Grid.Column="2" Name="SiteNameIcon"/>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                            <GroupBox Grid.Row="1" Header="[Paths]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label   Grid.Row="0" Grid.Column="0" Content="Database" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="DatabasePath"/>',
        '                                    <Label   Grid.Row="1" Grid.Column="0" Content="SysVol" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox Grid.Row="1" Grid.Column="1" Name="SysvolPath"/>',
        '                                    <Label   Grid.Row="2" Grid.Column="0" Content="Log" HorizontalContentAlignment="Center"/>',
        '                                    <TextBox Grid.Row="2" Grid.Column="1" Name="LogPath"/>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </Grid>',
        '                        <GroupBox Grid.Row="1" Grid.Column="1" Header="[Credential] - [Domain Services Restore Mode Password]">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button  Grid.Column="0" Content="Credential" Name="CredentialButton"/>',
        '                                    <TextBox Grid.Column="1" Name="Credential"/>',
        '                                    <Image   Grid.Column="2" Name="CredentialIcon"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label       Grid.Column="0" Content="Password" HorizontalContentAlignment="Center"/>',
        '                                    <PasswordBox Grid.Column="1" Name="SafeModeAdministratorPassword"/>',
        '                                    <Image       Grid.Column="2" Name="SafeModeAdministratorPasswordIcon"/>',
        '                                    <PasswordBox Grid.Column="3" Name="Confirm"/>',
        '                                    <Image       Grid.Column="4" Name="ConfirmIcon"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button      Grid.Column="0" Name="Start" Content="Start"/>',
        '                                    <Button      Grid.Column="1" Name="Cancel" Content="Cancel"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                </Grid>',
        '            </GroupBox>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ServerFeature
    {
        [UInt32] $Index
        [String] $Type
        [String] $Name
        [String] $DisplayName
        [Bool]   $Installed
        [Bool]   $Enabled
        [Bool]   $Install
        ServerFeature([Object]$Features,[UInt32]$Index,[String]$Type,[String]$Name)
        {
            $Object              = $Features | ? Name -eq $Name 
            $This.Index          = $Index
            $This.Type           = $Type
            $This.Name           = $Name
            $This.DisplayName    = $Object.Displayname
            $This.Installed      = $Object.Installed
            $This.Enabled        = If ($Object.Installed) {$False} Else {$True}
            $This.Install        = $This.Enabled
        }
        Check()
        {
            If ($This.Install)
            {
                $This.Install    = 0
            }
            If (!$This.Install)
            {
                $This.Install    = 1
            }
        }
    }

    Class BaseFeatures
    {
        Static [String[]] $Names = ("AD-Domain-Services DHCP DNS GPMC RSAT RSAT-AD-AdminCenter RSAT-AD-PowerShell RSAT-AD-T" +
        "ools RSAT-ADDS RSAT-ADDS-Tools RSAT-DHCP RSAT-DNS-Server RSAT-Role-Tools").Split(" ")
        BaseFeatures()
        {

        }
    }

    Class WDSFeatures
    {
        Static [String[]]  $Names = "WDS WDS-AdminPack WDS-Deployment WDS-Transport".Split(" ")
        WDSFeatures()
        {

        }
    }

    Class IISFeatures
    {
        Static [String[]] $Names = (("BITS BITS-IIS-Ext DSC-Service FS-SMBBW ManagementOData Net-Framework-45-ASPNet Net-WCF-HTTP-Activation45 " +
        "RSAT-BITS-Server WAS WAS-Config-APIs WAS-Process-Model WebDAV-Redirector {0}HTTP-Errors {0}HTTP-Logging {0}HTTP-Redirect {0}HTTP-Traci" +
        "ng {0}App-Dev {0}AppInit {0}Asp-Net45 {0}Basic-Auth {0}Common-Http {0}Custom-Logging {0}DAV-Publishing {0}Default-Doc {0}Digest-Auth {" +
        "0}Dir-Browsing {0}Filtering {0}Health {0}Includes {0}Log-Libraries {0}Metabase {0}Mgmt-Console {0}Net-Ext45 {0}Performance {0}Request-" +
        "Monitor {0}Security {0}Stat-Compression {0}Static-Content {0}Url-Auth {0}WebServer {0}Windows-Auth Web-ISAPI-Ext Web-ISAPI-Filter Web-" +
        "Server WindowsPowerShellWebAccess" -join " ") -f "Web-").Split(" ")
        IISFeatures()
        {

        }
    }

    Class VeridianFeatures
    {
        Static [String[]] $Names = "Hyper-V RSAT-Hyper-V-Tools Hyper-V-Tools Hyper-V-PowerShell".Split(" ")
        VeridianFeatures()
        {

        }
    }

    Class ServerFeatures
    {
        [Object]       $Registry
        [Object]       $Features
        [Object[]]       $Output
        ServerFeatures()
        {
            $This.Registry = @("" , "\WOW6432Node" | % { "HKLM:\SOFTWARE$_\Microsoft\Windows\CurrentVersion\Uninstall\*"  } | Get-ItemProperty)
            $This.Features = Get-WindowsFeature
            $This.Output   =  @( )
            ForEach ($Type in "Base","WDS","IIS","Veridian")
            { 
                ForEach ($Name in $This.GetSlot($Type))
                {
                    $This.Output    += [ServerFeature]::New($This.Features,$This.Output.Count,$Type,$Name)
                }
            }
        }
        [String[]] GetSlot([String]$Type)
        {
            Return @( Switch($Type)
            {
                Base     {[BaseFeatures]::Names}
                WDS      {[WDSFeatures]::Names}
                IIS      {[IISFeatures]::Names}
                Veridian {[VeridianFeatures]::Names}
            })
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

    Class FEDCPromo
    {
        [Object]              $System
        [Object]            $Features
        [String]             $Caption = (Get-CimInstance -Class Win32_OperatingSystem | % Caption)
        [UInt32]              $Server
        Hidden [Bool]        $Staging = $False
        Hidden [Object]         $Xaml
        Hidden [String]         $Pass = (Get-FEModule -Control | ? Name -eq success.png | % FullName)
        Hidden [String]         $Fail = (Get-FEModule -Control | ? Name -eq failure.png | % FullName)
        [String]             $Command
        [String]          $DomainType
        [UInt32]                $Mode
        [Object]             $Profile
        [Object]             $Network
        [Object]          $Connection
        FEDCPromo()
        {
            # Collect System
            $This.System                                 = [System]::New()

            # Collect features
            $This.Features                               = [ServerFeatures]::New().Output

            If ($This.System.Model -match "Virtual")
            {
                $This.Features | ? Type -eq Veridian | % { $_.Enabled = $False }
            }

            # Test Active Directory to import module
            If ($This.Features | ? Name -match AD-Domain-Services | ? Installed -eq 0)
            {
                Write-Theme "Exception [!] Must have ADDS installed first" 12,4,15,0
                Switch([System.Windows.MessageBox]::Show("Exception [!] ","Must have ADDS installed first, install it?","YesNo"))
                {
                    Yes {  Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools } 
                    No  {  Write-Theme "Error [!] ADDS was not installed" 12,4,15,0; Break }
                }
            }

            Import-Module ADDSDeployment -Verbose
            $This.Server                                 =  Switch -Regex ($This.Caption)
            {
                "(2000)"        { 0 } "(2003)"        { 1 } "(2008 (?!R2))" { 2 } 
                "(2008 R2)"     { 3 } "(2012 (?!R2))" { 4 } "(2012 R2)"     { 5 } 
                "(2016)"        { 6 } "(2019)"        { 7 } "(2022)"        { 8 } 
            }

            $This.Network = Get-FENetwork
            If (!$This.Network)
            {
                Write-Theme "Error [!] No network detected" 12,4,15,0
                Break
            }
        }
        LoadXaml([Object]$Xaml)
        {
            $This.Xaml      = $Xaml
        }
        SetMode([UInt32]$Mode)
        {
            $This.Mode      = $Mode
            $This.Profile   = [Profile]::New($Mode)
            $This.Staging   = $True

            $This.Profile.Item[0].Value = $This.Server
            $This.Profile.Item[1].Value = $This.Server
            
            # Command
            Write-Host "Command"
            $This.Command   = ("{0}Forest {0}{1} {0}{1} {0}{1}Controller" -f "Install-ADDS","Domain").Split(" ")[$Mode]

            # Menu Items
            Write-Host "Menu items"
            "Forest","Tree","Child","Clone" | ? { $_ -ne $This.Profile.Slot } | % {
            
                $This.Xaml.IO.$($_).IsChecked                = $False
            }

            # DomainType
            Write-Host "Domain Type"
            $This.DomainType                                 = @("-","Tree","Child","-")[$Mode]

            # Credential
            Write-Host "Credential"
            $This.Xaml.IO.CredentialButton.IsEnabled         = @(0,1)[[UInt32]($This.Mode -in 1..3)]

            # Roles
            Write-Host "Roles"
            ForEach ($Item in $This.Profile.Role)
            {
                $This.Xaml.IO.$($Item.Name).IsEnabled        = $Item.IsEnabled -eq $True
                $This.Xaml.IO.$($Item.Name).IsChecked        = $Item.IsChecked -eq $True
            }

            # Profile Main Items
            Write-Host "Profile Main Items"
            ForEach ($Item in $This.Profile.Item)
            {
                Write-Host $($Item.Name)

                # ComboBoxes
                If ($Item.Type -eq "ComboBox")
                {
                    $Item.Value   = @(0,$This.Server)[$Item.Name -Match "Mode"]
                }

                # TextBoxes
                If ($Item.Type -eq "TextBox")
                {
                    $Item.Value   = @("",$Item.Value)[$Item.IsEnabled]
                }
            }

            # Add connection values
            If ($This.Connection)
            {
                Switch($This.Mode)
                {
                    0
                    {
                        $This.Connection = $Null
                    }

                    1
                    {
                        $This.Profile.Item[4].Value = $This.Connection.Domain
                        $This.Profile.Item[6].Value = $This.Connection.NetBIOS
                    }

                    2
                    {
                        $This.Profile.Item[4].Value = $This.Connection.Domain
                        $This.Profile.Item[6].Value = $This.Connection.NetBIOS
                    }

                    3
                    {
                        $This.Profile.Item[5].Value = $This.Connection.Domain
                        $This.Profile.Item[6].Value = $This.Connection.NetBIOS
                    }
                }
            }

            # Connection Objects [Credential, Sitename, and ReplicationDCs]
            If ($This.Mode -ne 0 -and $This.Connection)
            {
                $This.Xaml.IO.Credential.Text                       = $This.Connection.Credential.Username
                $This.Xaml.IO.CredentialButton.IsEnabled            = 1
                If ($This.Connection.Sitename.Count -gt 0)
                {
                    $This.Xaml.IO.Sitename.ItemsSource              = @($This.Connection.Sitename)
                }
                If ($This.Connection.Sitename.Count -eq 0)
                {
                    $This.Xaml.IO.Sitename.ItemsSource              = @("-")
                }
                If ($This.Connection.ReplicationSourceDC.Count -gt 0)
                {
                    $This.Xaml.IO.ReplicationSourceDC.ItemsSource   = @($This.Connection.ReplicationDC;"<Any>")
                }
                If ($This.Connection.ReplicationSourceDC.Count -eq 0)
                {
                    $This.Xaml.IO.ReplicationSourceDC.ItemsSource   = @("<Any>")
                }
                $This.Xaml.IO.Sitename.SelectedIndex                = 0
                $This.Xaml.IO.ReplicationSourceDC.SelectedIndex     = 0
            }
            If ($This.Mode -eq 0)
            {
                $This.Xaml.IO.Credential.Text                       = ""
                $This.Xaml.IO.CredentialButton.IsEnabled            = 0
            }

            # Profile Xaml Items [Disabled]
            Write-Host "Profile Xaml Items [Disabled]"
            ForEach ($Item in $This.Profile.Item | ? IsEnabled -eq 0)
            {
                Write-Host "[-] $($Item.Name)"
                If ($Item.Name -in "ForestMode","DomainMode","ReplicationSourceDC","ParentDomainName")
                {
                    $This.Xaml.IO."_$($Item.Name)".Visibility       = "Collapsed"
                }

                If ($Item.Type -eq "TextBox")
                {
                    $This.Xaml.IO."$($Item.Name    )".Text          = ""
                    $This.Xaml.IO."$($Item.Name    )".IsEnabled     = 0
                    $This.Xaml.IO."$($Item.Name)Icon".Visibility    = "Collapsed" 
                }

                If ($Item.Type -eq "ComboBox")
                {
                    $This.Xaml.IO."$($Item.Name    )".SelectedIndex = 0
                    $This.Xaml.IO."$($Item.Name    )".IsEnabled     = 0
                }
            }

            # Profile Xaml Items [Enabled]
            Write-Host "Profile Xaml Items [Enabled]"
            ForEach ($Item in $This.Profile.Item | ? IsEnabled -eq 1)
            {
                Write-Host "[+] $($Item.Name)"
                If ($Item.Name -in "ForestMode","DomainMode","ReplicationSourceDC","ParentDomainName")
                {
                    $This.Xaml.IO."_$($Item.Name)".Visibility       = "Visible"
                }
                If ($Item.Type -eq "TextBox")
                {
                    $This.Xaml.IO."$($Item.Name    )".Text          = $Item.Value
                    $This.Xaml.IO."$($Item.Name    )".IsEnabled     = 1
                    $This.Xaml.IO."$($Item.Name)Icon".Visibility    = "Visible" 
                }

                If ($Item.Type -eq "ComboBox")
                {
                    $This.Xaml.IO."$($Item.Name    )".SelectedIndex = @($Item.Value,$This.Server)[$Item.Name -Match "Mode"]
                    $This.Xaml.IO."$($Item.Name    )".IsEnabled     = 1
                }
            }

            $This.Xaml.IO.SafeModeAdministratorPassword.IsEnabled   = 1
            $This.Xaml.IO.Confirm.IsEnabled                         = 1
            $This.Staging                                           = $False

            ForEach ($Item in $This.Profile.Item | ? Type -eq TextBox)
            {
                $This.Check($Item.Name)
            }
        }
        Login()
        {
            $This.Connection = $Null
            $Dcs             = $This.Network.NBT.Output
            If ($DCs)
            {
                $DC      = [XamlWindow][FEDCFoundGUI]::Tab
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
                        $This.Connection = [Connection]::New($Connect)
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
                    $This.Connection = [Connection]::New($Connect)
                }
            }
            $This.SetMode($This.Mode)
        }
        [Object] Get([String]$Name)
        {
            Return @( $This.Profile.Item | ? Name -eq $Name )
        }
        [Void] Set([String]$Name,[String]$Value)
        {
            $This.Profile.Item | ? Name -eq $Name | % { $_.Value = $Value }
        }
        [String[]] Reserved()
        {
            Return @(("ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GROUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;" + 
            "DIALUP;DIGEST AUTH;INTERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMO" +
            "TE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZATION;USERS;WORLD") -Split ";" )
        }
        [String[]] Legacy()
        {
            Return @("-GATEWAY","-GW","-TAC")
        }
        [String[]] SecurityDescriptors()
        {
            Return @(("AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS,RU,SA," +
            "SI,SO,SU,SY,WD") -Split ',')
        }
        Check([String]$Name)
        {
            If (!$This.Staging)
            {
                $Object                                        = $This.Profile.Item | ? Name -eq $Name
                Write-Host "[~] $($Object.Name)"
                If ($Object.IsEnabled)
                {
                    $This.Profile.Item | ? Name -eq $Name | % { $_.Value = $This.Xaml.IO.$Name.Text }
                    $This.CheckObject($Object)
                    $Object                                    = $This.Profile.Item | ? Name -eq $Name
                    $This.Xaml.IO."$Name`Icon".Source          = @($This.Fail,$This.Pass)[$Object.Check]
                    $This.Xaml.IO."$Name`Icon".Tooltip         = $Object.Reason
                }
                $This.Xaml.IO."$($Object.Name)".Visibility     = @("Collapsed","Visible")[$Object.IsEnabled]
                $This.Xaml.IO."$($Object.Name)Icon".Visibility = @("Collapsed","Visible")[$Object.IsEnabled]
                $This.Total()
            }
        }
        CheckDomain([Object]$Object)
        {
            If ($Object.Value.Length -lt 2 -or $Object.Value.Length -gt 63)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Length not between 2 and 63 characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Reserved())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in reserved words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Legacy())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the legacy words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
            { 
                $Object.Check  = $False
                $Object.Reason = "[!] Invalid characters"
                Write-Host $Object.Reason
            }

            ElseIf ($Object.Value[0,-1] -match "(\W)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value.Split(".").Count -lt 2)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Single label domain names are disabled"
                Write-Host $Object.Reason
            }
                
            ElseIf ($Object.Value.Split('.')[-1] -notmatch "\w")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Top Level Domain must contain a non-numeric"
                Write-Host $Object.Reason
            }
            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
                Write-Host $Object.Reason
            }
        }
        CheckNetBIOS([Object]$Object)
        {
            If ($Object.Value -eq $This.Connection.NetBIOS)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] New NetBIOS ID cannot be the same as the parent domain NetBIOS"
                Write-Host $Object.Reason
            }
                
            ElseIf ($Object.Value.Length -lt 1 -or $Object.Value.Length -gt 15)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Length not between 1 and 15 characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Reserved())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in reserved words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Legacy())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the legacy words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
            { 
                $Object.Check  = $False
                $Object.Reason = "[!] Invalid characters"
                Write-Host $Object.Reason
            }

            ElseIf ($Object.Value[0,-1] -match "(\W)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                Write-Host $Object.Reason
            }                        
            ElseIf ($Object.Value -match "\.")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] NetBIOS cannot contain a '.'"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.SecurityDescriptors())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Matches a security descriptor"
                Write-Host $Object.Reason
            }
            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
                Write-Host $Object.Reason
            }
        }
        CheckTree([Object]$Object)
        {
            If ($Object.Value -match "\.$($This.Xaml.IO.ParentDomainName.Text.Replace(".","\.").Replace("-","\-"))")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Cannot be a (child/host) of the parent"
                Write-Host $Object.Reason
            }
            
            ElseIf ($Object.Value.Split(".").Count -lt 2)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Single label domain names are disabled"
                Write-Host $Object.Reason
            }
                
            ElseIf ($Object.Value.Split('.')[-1] -notmatch "\w")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Top Level Domain must contain a non-numeric"
                Write-Host $Object.Reason
            }

            ElseIf ($Object.Value.Length -lt 2 -or $Object.Value.Length -gt 63)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Length not between 2 and 63 characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Reserved())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in reserved words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Legacy())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the legacy words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
            { 
                $Object.Check  = $False
                $Object.Reason = "[!] Invalid characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value[0,-1] -match "(\W)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                Write-Host $Object.Reason
            }
            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
                Write-Host $Object.Reason
            }
        }
        CheckChild([Object]$Object)
        {
            If ($Object.Value -notmatch ".$($This.Xaml.IO.ParentDomainName.Text)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Must be a (child/host) of the parent"
                Write-Host $Object.Reason
            }

            ElseIf ($Object.Value.Length -lt 2 -or $Object.Value.Length -gt 63)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Length not between 2 and 63 characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Reserved())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in reserved words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -in $This.Legacy())
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Entry is in the legacy words list"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
            { 
                $Object.Check  = $False
                $Object.Reason = "[!] Invalid characters"
                Write-Host $Object.Reason
            }
            ElseIf ($Object.Value[0,-1] -match "(\W)")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                Write-Host $Object.Reason
            }
            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
                Write-Host $Object.Reason
            }
        }
        CheckObject([Object]$Object)
        {
            If ($Object.Name -in "ParentDomainName","DomainName")
            {
                $This.CheckDomain($Object)
            }
            If ($Object.Name -in "DomainNetBIOSName","NewDomainNetBIOSName")
            {
                $This.CheckNetBIOS($Object)
            }
            If ($Object.Name -in "NewDomainName" -and $This.Profile.Mode -eq 1)
            {
                $This.CheckTree($Object)
            }
            If ( $Object.Name -in "NewDomainName" -and $This.Profile.Mode -eq 2)
            {
                $This.CheckChild($Object)
            }
        }
        CheckDSRM()
        {
            If ($This.Profile.DSRM[0].Value -notmatch "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}")
            {
                $This.Profile.DSRM[0].Check  = $False
                $This.Profile.DSRM[0].Reason = "[!] 10 chars, and at least: (1) Uppercase, (1) Lowercase, (1) Special, (1) Number" 
                Write-Host $This.Profile.DSRM[0].Reason
            }
            If ($This.Profile.DSRM[0].Value -match "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}")
            {
                $This.Profile.DSRM[0].Check  = $True
                $This.Profile.DSRM[0].Reason = "[+] Passed"
                Write-Host $This.Profile.DSRM[0].Reason
            }
            If ($This.Profile.DSRM[1].Value -notmatch "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}")
            {
                $This.Profile.DSRM[1].Check  = $False
                $This.Profile.DSRM[1].Reason = "[!] 10 chars, and at least: (1) Uppercase, (1) Lowercase, (1) Special, (1) Number" 
                Write-Host $This.Profile.DSRM[1].Reason
            }
            If ($This.Profile.DSRM[0].Value -ne $This.Profile.DSRM[1].Value)
            {
                $This.Profile.DSRM[1].Check  = $False
                $This.Profile.DSRM[1].Reason = "[!] Confirmation error"
                Write-Host $This.Profile.DSRM[1].Reason
            }
            If ($This.Profile.DSRM[0].Check -eq 1 -and $This.Profile.DSRM[0].Value -eq $This.Profile.DSRM[1].Value)
            {
                $This.Profile.DSRM[1].Check  = $True
                $This.Profile.DSRM[1].Reason = "[+] Passed"
                Write-Host $This.Profile.DSRM[1].Reason
            }
        }
        Role([String]$Name)
        {
            $This.Profile.Role | ? Name -eq $Name | % { 

                If ($_.IsEnabled)
                {
                    $_.IsChecked = @(1,0)[$This.Xaml.IO.$Name.IsChecked]
                }
            }
        }
        Total()
        {
            If (($This.Profile.Item | ? IsEnabled | ? Property -eq Text | ? Check -eq 0).Count -eq 0 -and ($This.Profile.DSRM | ? Check -eq 0).Count -eq 0)
            {
                $This.Xaml.IO.Start.IsEnabled = 1
            }
            Else
            {
                $This.Xaml.IO.Start.IsEnabled = 0
            }
        }
    }

    $Main                                      = [FEDCPromo]::New()
    $Xaml                                      = [XamlWindow][FEDCPromoGUI]::Tab
    $Xaml.IO.ForestMode.ItemsSource            = @( )
    $Xaml.IO.ForestMode.ItemsSource            = @("2000 (Default)","2003","2008","2008 R2","2012","2012 R2","2016","2019","2022" | % { "Windows Server $_" })
    $Xaml.IO.DomainMode.ItemsSource            = @( )
    $Xaml.IO.DomainMode.ItemsSource            = @("2000 (Default)","2003","2008","2008 R2","2012","2012 R2","2016","2019","2022" | % { "Windows Server $_" })
    $Xaml.IO.Features.ItemsSource              = @( )
    $Xaml.IO.Features.ItemsSource              = @($Main.Features)
    $Xaml.IO.ReplicationSourceDC.ItemsSource   = @()
    $Xaml.IO.ReplicationSourceDC.ItemsSource   = @("<Any>")
    $Xaml.IO.Sitename.ItemsSource              = @( )
    $Xaml.IO.Sitename.ItemsSource              = @("-")
    $Main.LoadXaml($Xaml)

    $Xaml.IO.Credential.IsEnabled              = 0
    $Xaml.IO.SafeModeAdministratorPassword.IsEnabled = 0
    $Xaml.IO.Confirm.IsEnabled = 0

    # Name Defaults
    $Xaml.IO.DomainName.IsEnabled              = 0
    $Xaml.IO.NewDomainName.IsEnabled           = 0
    $Xaml.IO.DomainNetBIOSName.IsEnabled       = 0
    $Xaml.IO.NewDomainNetBIOSName.IsEnabled    = 0
    $Xaml.IO.SiteName.IsEnabled                = 0

    # Path Defaults
    $Xaml.IO.DataBasePath.Text                 = "$Env:SystemRoot\NTDS"
    $Xaml.IO.SysVolPath.Text                   = "$Env:SystemRoot\SYSVOL"
    $Xaml.IO.LogPath.Text                      = "$Env:SystemRoot\NTDS"

    # Role Defaults
    $Xaml.IO.InstallDNS.IsEnabled              = 0
    $Xaml.IO.CreateDNSDelegation.IsEnabled     = 0
    $Xaml.IO.NoGlobalCatalog.IsEnabled         = 0
    $Xaml.IO.CriticalReplicationOnly.IsEnabled = 0

    # Button Defaults
    $Xaml.IO.Start.IsEnabled                   = 0
    $Xaml.IO.CredentialButton.IsEnabled        = 0

    <# $Last = $Null
    $Xaml.Names | ? { $_ -notin "ContentPresenter","Border","ContentSite" } | % {
        
        $X = "    # `$Xaml.IO.$_"
        $Y = $Xaml.IO.$_.GetType().Name 
        "{0}{1} # $Y" -f $X,(" "*(60-$X.Length) -join '')
    
    } | Set-Clipboard #>

    $Xaml.IO.Forest.Add_Checked(
    { 
        $Main.SetMode(0)
    })
    $Xaml.IO.Tree.Add_Checked(
    { 
        $Main.SetMode(1) 
    })
    $Xaml.IO.Child.Add_Checked(
    {
        $Main.SetMode(2)
    })
    $Xaml.IO.Clone.Add_Checked(
    {
        $Main.SetMode(3)
    })

    $Xaml.IO.ParentDomainName.Add_TextChanged(
    {
        $Main.Check("ParentDomainName")
    })

    $Xaml.IO.DomainName.Add_TextChanged(
    {
        $Main.Check("DomainName")
    })

    $Xaml.IO.NewDomainName.Add_TextChanged(
    {
        $Main.Check("NewDomainName")
    })

    $Xaml.IO.DomainNetBIOSName.Add_TextChanged(
    {
        $Main.Check("DomainNetBIOSName")
    })

    $Xaml.IO.NewDomainNetBIOSName.Add_TextChanged(
    {
        $Main.Check("NewDomainNetBIOSName")
    })

    $Xaml.IO.SafeModeAdministratorPassword.Add_PasswordChanged(
    {
        $Main.Profile.DSRM[0].Value                        = $Xaml.IO.SafeModeAdministratorPassword.Password
        $Main.CheckDSRM()
        $Xaml.IO.SafeModeAdministratorPasswordIcon.Source  = @($Main.Fail,$Main.Pass)[$Main.Profile.DSRM[0].Check]
        $Xaml.IO.SafeModeAdministratorPasswordIcon.Tooltip = $Main.Profile.DSRM[0].Reason 
        $Main.Total()
    })

    $Xaml.IO.Confirm.Add_PasswordChanged(
    {
        $Main.Profile.DSRM[1].Value                        = $Xaml.IO.Confirm.Password
        $Main.CheckDSRM()
        $Xaml.IO.ConfirmIcon.Source                        = @($Main.Fail,$Main.Pass)[$Main.Profile.DSRM[1].Check]
        $Xaml.IO.ConfirmIcon.Tooltip                       = $Main.Profile.DSRM[1].Reason 
        $Main.Total()
    })

    # $Xaml.IO.SafeModeAdministratorPassword                 # PasswordBox
    # $Xaml.IO.Confirm                                       # PasswordBox
    # $Xaml.IO.Start                                         # Button
    # $Xaml.IO.Cancel                                        # Button

    $Xaml.IO.CredentialButton.Add_Click(
    {
        $Main.Login()
    })

    $Xaml.IO.Start.Add_Click(
    {
        0,1 | % { 
            $Item = $Main.Profile.Item[$_]
            If ($Item.IsEnabled -and $Item.Value -gt 6)
            {
                $Item.Value = 6
            }
        }
        If ($Main.Profile.Item[2].IsEnabled)
        {
            $Main.Profile.Item[2].Value = $Xaml.IO.ReplicationSourceDC.SelectedItem
        }
        If ($Main.Profile.Item[3].IsEnabled)
        {
            $Main.Profile.Item[3].Value = $Xaml.IO.Sitename.SelectedItem
        }
        ForEach ($Item in $Main.Profile.Role)
        {
            $Item.IsChecked = $Item.IsEnabled -and $Xaml.IO.$($Item.Name).IsChecked
        }
        $Main.Profile.DSRM[0] | % { $_.Value = $_.Value | ConvertTo-SecureString -AsPlainText -Force }

        [System.Windows.MessageBox]::Show("All checks passed","Success")
        $Xaml.IO.DialogResult = $True
    })

    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })

    $Xaml.Invoke()

    If ($Xaml.IO.DialogResult)
    {
        $Execute = [Execution]::New()

        # [Install Features]
        $Execute.Services = $Main.Features | ? Enabled | ? Install

        # [Output]
        $Execute.Output = @{ }

        If ($Main.Mode -in 1,2)
        {
            $Execute.Output.Add("DomainType",$Main.DomainType)
        }

        # [Profile Items]
        $Main.Profile.Item | ? IsEnabled | % { 

            $Execute.Output.Add($_.Name,$_.Value)
        }

        # [Profile Roles]
        $Main.Profile.Role | ? IsEnabled | % {

            $Execute.Output.Add($_.Name,$_.IsChecked)
        }

        # [Database/Sysvol/Log Paths]
        "Database Log Sysvol".Split(" ") | % { "$_`Path"} | % { $Execute.Output.Add($_,$Xaml.IO.$_.Text) }
        $Execute.Output.Add("SafeModeAdministratorPassword",$Main.Profile.DSRM[0].Value)

        # Credential
        If ($Main.Connection.Credential)
        {
            $Execute.Output.Add("Credential",$Main.Connection.Credential)
        }

        $Execute
    }
}

    <#
    $UI.Window.Invoke()

    If ($UI.IO.DialogResult)
    {
        $Reboot = 0

        ForEach ( $Feature in $UI.Features )
        {
            $Feature.Name = $Feature.Name -Replace "_","-"
            
            If (!$Feature.Installed)
            {
                If ($Test) 
                { 
                    Write-Host "Install-WindowsFeature -Name $($Feature.Name) -IncludeAllSubFeature -IncludeManagementTools" -F Cyan
                } 
                
                Else 
                {
                    $X = Install-WindowsFeature -Name $($Feature.Name) -IncludeAllSubFeature -IncludeManagementTools
                    If ($X.RestartNeeded)
                    {
                        $Reboot = 1
                    }
                }
            }

            If ($Feature.Installed)
            {
                Write-Host "$($Feature.Name) is already installed." -F Red
            }
        }

        $UI.Output = @{ }

        ForEach ( $Group in $UI.Profile.Type, $UI.Profile.Role, $UI.Profile.Text )
        {
            ForEach ( $Item in $Group )
            {
                If ( $Item.IsEnabled )
                {
                    If ( !$UI.Output[$Item.Name] )
                    {
                        $UI.Output.Add($Item.Name,$UI.$($Item.Name))
                    }
                }
            }
        }

        "Database Log Sysvol".Split(" ") | % { "$_`Path"} | % { $UI.Output.Add($_,$UI.$_) }

        If ( $UI.Credential )
        {
            $UI.Output.Add("Credential",$UI.Credential)
            $UI.Output.Add("SafeModeAdministratorPassword",$UI.SafeModeAdministratorPassword)
        }

        $Splat = $UI.Output

        If ($Reboot -eq 1)
        {
            Write-Host "Reboot [!] required to proceed."

            $Value = @(
            "Remove-Item $Env:Public\script.ps1 -Force -EA 0",
            "Unregister-ScheduledTask -TaskName FEDCPromo -Confirm:`$False"
            "@{"," "
            ForEach ( $Item in $Splat.GetEnumerator() )
            {
                Switch ($Item.Name)
                {
                    SafeModeAdministratorPassword 
                    { 
                        "    SafeModeAdministratorPassword = '{0}' | ConvertTo-SecureString -AsPlainText -Force" -f $UI.IO.Confirm.Password 
                    }
                    Credential 
                    { 
                        "    Credential = [System.Management.Automation.PSCredential]::New('{0}',('{1}' | ConvertTo-SecureString -AsPlainText -Force))" -f $UI.Credential.UserName,$UI.Credential.GetNetworkCredential().Password 
                    }

                    Default    
                    { 
                        If ( $Item.Value -in "True","False")
                        {
                            "    {0}=$`{1}" -f $Item.Name,$Item.Value
                        }

                        Else
                        {
                            "    {0}='{1}'" -f $Item.Name,$Item.Value
                        }
                    }
                }
            }
            " ","} | % { $($UI.Command) @_ -Force }")

            Set-Content "$Env:Public\script.ps1" -Value $Value -Force
            $Action = New-ScheduledTaskAction -Execute PowerShell -Argument "-ExecutionPolicy Bypass -Command (& $Env:Public\script.ps1)"
            $Trigger = New-ScheduledTaskTrigger -AtLogon
            Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName FEDCPromo -Description "Restarting, then promote system"
            Restart-Computer
        }
        
        If ($Test)
        {
            Switch ($UI.Mode)
            {
                0 { Test-ADDSForestInstallation @Splat }
                1 { Test-ADDSDomainInstallation @Splat }
                2 { Test-ADDSDomainInstallation @Splat }
                3 { Test-ADDSDomainControllerInstallation @Splat }
            }
        }

        Else
        {
            Switch ( $UI.Mode )
            {
                0 { Install-ADDSForest @Splat }
                1 { Install-ADDSDomain @Splat }
                2 { Install-ADDSDomain @Splat }
                3 { Install-ADDSDomainController @Splat }
            }
        }
    }

    Else
    {
        Write-Theme "Exception [!] Either the user cancelled, or the dialog failed" 12,4,15,0
    }
}
#>
