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
          Modified: 2021-10-10
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEDCPromo
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [ValidateSet(0,1,2,3)]
    [Parameter(ParameterSetName=0)][UInt32]$Mode = 0,
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

    # Profile Classes
    Class ProfileItem
    {
        [String]                  $Name
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
    Class ProfileDSRM
    {
        [String] $Name
        [SecureString] $Password
        [SecureString] $Confirm
        [Object] $Check
        [Object] $Reason
        ProfileDSRM()
        {
            $This.Name = "DSRM"
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
            $This.DSRM              = [ProfileDSRM]::New()

            ForEach ($X in 0..($This.Item.Count-1))
            {
                $IX                 = $This.Item[$X]
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
        Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Domain Controller Promotion" Width="800" Height="780" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '        <Style TargetType="Label">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Margin" Value="3"/>',
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
        '            <ImageBrush Stretch="UniformToFill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="24"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <Menu Grid.Row="0" Height="20">',
        '            <MenuItem Header="Command">',
        '                <MenuItem Name="Forest" Header="Install-ADDSForest" IsCheckable="True"/>',
        '                <MenuItem Name="Tree" Header="Install-ADDSDomain(Tree)" IsCheckable="True"/>',
        '                <MenuItem Name="Child" Header="Install-ADDSDomain(Child)" IsCheckable="True"/>',
        '                <MenuItem Name="Clone" Header="Install-ADDSDomainController" IsCheckable="True"/>',
        '            </MenuItem>',
        '        </Menu>',
        '        <Grid Grid.Row="1">',
        '            <GroupBox>',
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
        '                            <TextBox Name="ParentDomainName" Text="&lt;Domain Name&gt;"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Name="_ReplicationSourceDC" Header="[Replication Source DC]" Visibility="Collapsed">',
        '                            <ComboBox Name="ReplicationSourceDC"/>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="1.5*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="400"/>',
        '                            <RowDefinition Height="200"/>',
        '                        </Grid.RowDefinitions>',
        '                        <GroupBox Grid.Row="0" Grid.Column="0" Header="[Required Features]">',
        '                            <DataGrid Name="Features">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="180" Binding="{Binding Name}" CanUserSort="True" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Install" Width="50">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <CheckBox IsEnabled="{Binding Installed}" IsChecked="True" Margin="0" Height="18" HorizontalAlignment="Left"/>',
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
        '                                <CheckBox Grid.Column="0" Grid.Row="0" Name="InstallDNS"/>',
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
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Row="0" Grid.Column="0" Content="Domain"/>',
        '                                    <TextBox  Grid.Row="0" Grid.Column="1" Name="DomainName"/>',
        '                                    <Label    Grid.Row="1" Grid.Column="0" Content="New Domain"/>',
        '                                    <TextBox  Grid.Row="1" Grid.Column="1" Name="NewDomainName"/>',
        '                                    <Label    Grid.Row="2" Grid.Column="0" Content="NetBIOS"/>',
        '                                    <TextBox  Grid.Row="2" Grid.Column="1" Name="DomainNetBIOSName"/>',
        '                                    <Label    Grid.Row="3" Grid.Column="0" Content="New NetBIOS"/>',
        '                                    <TextBox  Grid.Row="3" Grid.Column="1" Name="NewDomainNetBIOSName"/>',
        '                                    <Label    Grid.Row="4" Grid.Column="0" Content="Site"/>',
        '                                    <ComboBox Grid.Row="4" Grid.Column="1" Name="SiteName"/>',
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
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label   Grid.Row="0" Grid.Column="0" Content="Database"/>',
        '                                    <Label   Grid.Row="1" Grid.Column="0" Content="SysVol"/>',
        '                                    <Label   Grid.Row="2" Grid.Column="0" Content="Log"/>',
        '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="DatabasePath"/>',
        '                                    <TextBox Grid.Row="1" Grid.Column="1" Name="SysvolPath"/>',
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
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button  Grid.Column="0" Content="Credential" Name="CredentialButton"/>',
        '                                    <TextBox Grid.Column="1" Name="Credential"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="Password"/>',
        '                                    <PasswordBox Grid.Column="1" Name="SafeModeAdministratorPassword"/>',
        '                                    <PasswordBox Grid.Column="2" Name="Confirm"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button      Grid.Column="0" Name="Start" Content="Start" />',
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
        [String] $Name
        [String] $DisplayName
        [Bool]   $Installed
        ServerFeature([UInt32]$Index,[Object]$Object)
        {
            $This.Index          = $Index
            $This.Name           = $Object.Name
            $This.DisplayName    = $Object.Displayname
            $This.Installed      = $Object.Installed
        }
    }

    Class ServerFeatures
    {
        Static [String[]] $Names = ("AD-Domain-Services DHCP DNS GPMC RSAT RSAT-AD-AdminCenter RSAT-AD-PowerShell RSAT-AD-T" +
                                    "ools RSAT-ADDS RSAT-ADDS-Tools RSAT-DHCP RSAT-DNS-Server RSAT-Role-Tools WDS WDS-Admin" + 
                                    "Pack WDS-Deployment WDS-Transport").Split(" ")
        [Object[]]       $Output
        ServerFeatures()
        { 
            $This.Output         =  @( )
            ForEach ($Item in Get-WindowsFeature | ? Name -in ([ServerFeatures]::Names))
            { 
                $This.Output    += [ServerFeature]::New($This.Output.Count,$Item)
            }    
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
        [Object]            $Features
        [String]             $Caption = (Get-CimInstance -Class Win32_OperatingSystem | % Caption)
        [UInt32]              $Server
        Hidden [Object]         $Xaml
        [String]             $Command
        [String]          $DomainType
        [UInt32]                $Mode
        [Object]             $Profile
        [Object]             $Network
        [Object]          $Connection
        FEDCPromo()
        {
            # Collect features
            $This.Features                               = [ServerFeatures]::New().Output

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
            If ($This.Network)
            {
                Switch([System.Windows.MessageBox]::Show(("This will run a thorough scan for potential domain controllers.",
                "Depending on the number of adapters in the system, this process can be lengthy.",
                "-",
                "It is not necessary for a new forest, choose no if this is the case.",
                "-",
                "Otherwise, proceed?" -join "`n"),"NetBIOS Scan [~]","YesNo"))
                {
                    Yes { $This.Network.NetBIOSScan() } No { Break }
                }
            }
            If (!$This.Network)
            {
                Write-Theme "Error [!] No network detected" 12,4,15,0
                Break
            }
        }
        SetMode([UInt32]$Mode,[Object]$Xaml)
        {
            $This.Xaml      = $Xaml
            $This.Mode      = $Mode
            $This.Profile   = [Profile]::New($Mode)

            $This.Profile.Item[0].Value = $This.Server
            $This.Profile.Item[1].Value = $This.Server

            If ($Mode -eq 0)
            {
                $This.Profile.Item[5,6] | % { $_.Value = $_.Value -Replace " or \<Credential\>","" }
            }
            
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
            
            # Profile Items
            Write-Host "Profile Items"
            ForEach ($Item in $This.Profile.Item)
            {
                Write-Host $Item.Name
                If ($Item.Name -in $This.Profile.Item[0,1,2,4].Name)
                {
                    $This.Xaml.IO."_$($Item.Name)".Visibility  = @("Collapsed","Visible")[$Item.IsEnabled]
                }

                $This.Xaml.IO.$($Item.Name).IsEnabled         = $Item.IsEnabled

                If ($Item.Property -eq "SelectedIndex")
                {
                    If ($Item.Name -match "Mode")
                    {
                        $This.Xaml.IO.$($Item.Name).$($Item.Property) = $This.Server
                    }
                    If ($Item.Name -notmatch "Mode")
                    {
                        $This.Xaml.IO.$($Item.Name).$($Item.Property) = 0
                    }
                }
                If ($Item.Property -match "Text")
                {
                    $This.Xaml.IO.$($Item.Name).$($Item.Property) = @($Null,$Item.Value)[$Item.IsEnabled]
                }
            }
        }
        SetItem([String]$Name,[Object]$Value)
        {
            $This.Profile.SetItem($Name,$Value)
            $This.Profile | ? Name -eq $Name | % { 
                
                $This.IO.Xaml.$($Name).$($_.Property) = $_.Value
            }
        }
        Login()
        {
            $This.Connection = $Null
            $Dcs             = $This.Network.NBTScan | ? NetBIOS | ? {$_.NBT.ID -Match "1B|1C"}
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
            If ($This.Connection)
            {
                # [Set Credential]
                $This.Xaml.IO.Credential.Text            = $This.Connection.Credential.Username
                $This.Xaml.IO.CredentialButton.IsEnabled = 0

                # [Set Domain Name]
                If ($This.Mode -in 1,2)
                {
                    $This.Xaml.IO.ParentDomainName       = $This.Connection.Domain
                    $This.Profile.Item | ? Name -eq ParentDomainName | % { $_.Value = $This.Connection.Domain }
                }
                If ($This.Mode -eq 3)
                {
                    $This.Xaml.IO.DomainName.Text        = $This.Connection.Domain
                    $This.Profile.Item | ? Name -eq DomainName | % { $_.Value = $This.Connection.Domain }
                }

                # [Set NetBIOS]
                $This.Xaml.IO.DomainNetBIOSName.Text     = $This.Connection.NetBIOS
                $This.Profile.Item | ? Name -eq DomainNetBIOSName.Text = $This.Connection.NetBIOS

                # [Set Sitename]
                $This.Xaml.IO.SiteName.ItemsSource                = @( )
                $This.Xaml.IO.SiteName.ItemsSource                = @($This.Connection.Sitename)
                $This.Xaml.IO.SiteName.SelectedIndex              = 0

                # [Set Replication Source DCs]
                $This.Xaml.IO.ReplicationSourceDC.ItemsSource     = @( )
                If ($This.Connection.ReplicationDC.Count -gt 0)
                {
                    $This.Xaml.IO.ReplicationSourceDC.ItemsSource = @($DCs)
                }
                Else
                {
                    $This.Xaml.IO.ReplicationSourceDC.ItemsSource = @("<Any>")
                }
                $This.Xaml.IO.ReplicationSourceDC.SelectedIndex   = 0
            }
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
        CheckObject([Object]$Object)
        {
            Switch -Regex ($Object.Name)
            {
                "(ParentDomainName|DomainName)"
                {
                    If ($Object.Value.Length -lt 2 -or $Object.Value.Length -gt 63)
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Length not between 2 and 63 characters" 
                    }

                    ElseIf ($Object.Value -in $This.Reserved())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in reserved words list"
                    }

                    ElseIf ($Object.Value -in $This.Legacy())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in the legacy words list" 
                    }

                    ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $Object.Check  = $False
                        $Object.Reason = "[!] Invalid characters"
                    }
        
                    ElseIf ($Object.Value[0,-1] -match "(\W)")
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                    }
                    ElseIf ($Object.Value.Split(".").Count -lt 2)
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Single label domain names are disabled"
                    }
                        
                    ElseIf ($Object.Value.Split('.')[-1] -notmatch "\w")
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Top Level Domain must contain a non-numeric"
                    }
                    Else
                    {
                        $Object.Check  = $True
                        $Object.Reason = "[+] Passed"
                    }
                }
                "(DomainNetBIOSName|NewDomainNetBIOSName)"
                {
                    If ($This.Profile.Mode -in 1,2 -and $Object.Value -match $This.Connection.NetBIOS)
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] New NetBIOS ID cannot be the same as the parent domain NetBIOS"
                    }
                        
                    ElseIf ($Object.Value.Length -lt 1 -or $Object.Value.Length -gt 15)
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Length not between 1 and 15 characters" 
                    }

                    ElseIf ($Object.Value -in $This.Reserved())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in reserved words list"
                    }

                    ElseIf ($Object.Value -in $This.Legacy())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in the legacy words list" 
                    }

                    ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $Object.Check  = $False
                        $Object.Reason = "[!] Invalid characters"
                    }
        
                    ElseIf ($Object.Value[0,-1] -match "(\W)")
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                    }                        
                    ElseIf ($Object.Value -match "\.")
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] NetBIOS cannot contain a '.'"
                    }
                    ElseIf ($Object.Value -in $This.SecurityDescriptors())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Matches a security descriptor"
                    }
                    Else
                    {
                        $Object.Check  = $True
                        $Object.Reason = "[+] Passed"
                    }
                }
                NewDomainName
                {
                    Switch($This.Profile.Type)
                    {
                        1
                        {
                            If ($Object.Value -match ".$($This.Xaml.IO.ParentDomainName.Text)")
                            {
                                $Object.Check  = $False
                                $Object.Reason = "[!] Cannot be a (child/host) of the parent"
                            }
                            
                            ElseIf ($Object.Value.Split(".").Count -lt 2)
                            {
                                $Object.Check  = $False
                                $Object.Reason = "[!] Single label domain names are disabled"
                            }
                                
                            ElseIf ($Object.Value.Split('.')[-1] -notmatch "\w")
                            {
                                $Object.Check  = $False
                                $Object.Reason = "[!] Top Level Domain must contain a non-numeric"
                            }
                        }

                        2
                        {
                            If ($Object.Value -notmatch ".$($This.Xaml.IO.ParentDomainName.Text)")
                            {
                                $Object.Check  = $False
                                $Object.Reason = "[!] Must be a (child/host) of the parent"
                            }
                        }
                    }

                    ElseIf ($Object.Value.Length -lt 2 -or $Object.Value.Length -gt 63)
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Length not between 2 and 63 characters"
                    }

                    ElseIf ($Object.Value -in $This.Reserved())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in reserved words list"
                    }

                    ElseIf ($Object.Value -in $This.Legacy())
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] Entry is in the legacy words list" 
                    }

                    ElseIf ($Object.Value -notmatch "([\.\-0-9a-zA-Z])")
                    { 
                        $Object.Check  = $False
                        $Object.Reason = "[!] Invalid characters"
                    }
                    ElseIf ($Object.Value[0,-1] -match "(\W)")
                    {
                        $Object.Check  = $False
                        $Object.Reason = "[!] First/Last Character cannot be a '.' or '-'"
                    }

                    Else
                    {
                        $Object.Check  = $True
                        $Object.Reason = "[+] Passed"
                    }
                }
            }
        }
        CheckDSRM([Object]$Object)
        {
            If ($Object.Password -notmatch "([0-9a-zA-Z:punct:]{10})")
            {
                $Object.Check  = $False
                $Object.Reason = "[!] 10 chars, and at least: (1) Uppercase, (1) Lowercase, (1) Special, (1) Number" 
            }
            ElseIf ($Object.Password -notmatch $Object.Confirm)
            {
                $Object.Check  = $False
                $Object.Reason = "[!] Confirmation error"
            }
            Else
            {
                $Object.Check  = $True
                $Object.Reason = "[+] Passed"
            }
        }
        Total()
        {
            If (($This.Profile.Item | ? IsEnabled | ? Property -eq Text | ? Check -eq 0).Count -eq 0 -and ($This.Profile.DSRM | ? Check))
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
    $Xaml.IO.Credential.IsEnabled              = 0

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
        $Main.SetMode(0,$Xaml)
    })
    $Xaml.IO.Tree.Add_Checked(
    {
        $Main.SetMode(1,$Xaml)
    })
    $Xaml.IO.Child.Add_Checked(
    {
        $Main.SetMode(2,$Xaml)
    })
    $Xaml.IO.Clone.Add_Checked(
    {
        $Main.SetMode(3,$Xaml)
    })

    $Xaml.IO.ParentDomainName.Add_TextChanged(
    {
        $Object          = $Main.Profile.Item | ? Name -eq ParentDomainName
        $Object.Value    = $Xaml.IO.ParentDomainName.Text
        $Main.CheckObject($Object)
        $Main.Total()
    })

    $Xaml.IO.DomainName.Add_TextChanged(
    {
        $Object          = $Main.Profile.Item | ? Name -eq DomainName
        $Object.Value    = $Xaml.IO.DomainName.Text
        $Main.CheckObject($Object)
        $Main.Total()
    })

    $Xaml.IO.NewDomainName.Add_TextChanged(
    {
        $Object          = $Main.Profile.Item | ? Name -eq NewDomainName
        $Object.Value    = $Xaml.IO.NewDomainName.Text
        $Main.CheckObject($Object)
        $Main.Total()
    })

    $Xaml.IO.DomainNetBIOSName.Add_TextChanged(
    {
        $Object          = $Main.Profile.Item | ? Name -eq DomainNetBIOSName
        $Object.Value    = $Xaml.IO.DomainNetBIOSName.Text
        $Main.CheckObject($Object)
        $Main.Total()
    })

    $Xaml.IO.NewDomainNetBIOSName.Add_TextChanged(
    {
        $Object          = $Main.Profile.Item | ? Name -eq NewDomainNetBIOSName
        $Object.Value    = $Xaml.IO.NewDomainNetBIOSName.Text
        $Main.CheckObject($Object)
        $Main.Total()
    })

    $Xaml.IO.SafeModeAdministratorPassword.Add_PasswordChanged(
    {
        $Object          = $Main.Profile.DSRM
        $Object.Password = $Xaml.IO.SafeModeAdministratorPassword.Password
        $Main.CheckDSRM($Object)
        $Main.Total()
    })

    $Xaml.IO.Confirm.Add_PasswordChanged(
    {
        $Object          = $Main.Profile.DSRM
        $Object.Confirm  = $Xaml.IO.Confirm.Password
        $Main.CheckDSRM($Object)
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
        [System.Windows.MessageBox]::Show("All checks passed","Success")
        $Xaml.IO.DialogResult = $True
    })

    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })

    $Xaml.Invoke()
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
