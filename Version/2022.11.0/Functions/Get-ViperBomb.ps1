<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-ViperBomb.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : For managing system details, Windows services, and controls                              //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-23                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : AKA "System Control Extension Utility"                                                   //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-23-2022 19:57:01    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-ViperBomb
{
    Class ViperBombXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Name="Window" Title="[FightingEntropy]://System Control Extension Utility" Height="640" Width="800" Topmost="True" BorderBrush="Black" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\icon.ico" ResizeMode="NoResize" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '        <Style TargetType="ComboBox" x:Key="DGCombo">',
        '            <Setter Property="Margin" Value="0"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="18"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
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
        '            <ImageBrush Stretch="UniformToFill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.11.0\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <TabControl Margin="5">',
        '            <TabItem Header="System">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="60"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Grid.Row="0" Name="OS">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Caption"   Width="300"   Binding="{Binding Caption}"/>',
        '                            <DataGridTextColumn Header="Platform"  Width="150"   Binding="{Binding Platform}"/>',
        '                            <DataGridTextColumn Header="PSVersion" Width="150"   Binding="{Binding PSVersion}"/>',
        '                            <DataGridTextColumn Header="Type"      Width="*"     Binding="{Binding Type}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Bios Information">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="55"/>',
        '                                    <RowDefinition Height="130"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="BiosInformation">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"            Width="*" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Manufacturer"    Width="150" Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Serial"          Width="100" Binding="{Binding SerialNumber}"/>',
        '                                        <DataGridTextColumn Header="Version"         Width="125" Binding="{Binding Version}"/>',
        '                                        <DataGridTextColumn Header="Released"        Width="125" Binding="{Binding ReleaseDate}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="1" Name="BiosInformationExtension" HeadersVisibility="None">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Width="150" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value" Width="*"   Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Operating System">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="55"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="OperatingSystem">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Edition"         Width=  "*" Binding="{Binding Caption}"/>',
        '                                        <DataGridTextColumn Header="Version"         Width= "75" Binding="{Binding Version}"/>',
        '                                        <DataGridTextColumn Header="Build"           Width= "50" Binding="{Binding Build}"/>',
        '                                        <DataGridTextColumn Header="Serial"          Width="180" Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="Lang."           Width= "35" Binding="{Binding Language}"/>',
        '                                        <DataGridTextColumn Header="Prod."           Width= "35" Binding="{Binding Product}"/>',
        '                                        <DataGridTextColumn Header="Type"            Width= "35" Binding="{Binding Type}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Computer System">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="55"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="ComputerSystem">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Manufacturer"    Width=  "*" Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Model"           Width="150" Binding="{Binding Model}"/>',
        '                                        <DataGridTextColumn Header="Serial"          Width="150" Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="Memory"          Width= "50" Binding="{Binding Memory}"/>',
        '                                        <DataGridTextColumn Header="Arch."           Width=" 50" Binding="{Binding Architecture}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="1" Name="ComputerSystemExtension" HeadersVisibility="None">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"            Width="150" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"           Width=  "*" Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '',
        '                        </TabItem>',
        '                        <TabItem Header="Processor">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="150"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="Processor">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"         Width="*" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Manufacturer" Width= "75" Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Caption"      Width="*" Binding="{Binding Caption}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="1" Name="ProcessorExtension" HeadersVisibility="None">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Width="120" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value" Width= "*"  Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Disk">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="120"/>',
        '                                    <RowDefinition Height="80"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" RowHeaderWidth="0" Name="Disk">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index"             Width= "40" Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Disk"              Width="125" Binding="{Binding Disk}"/>',
        '                                        <DataGridTextColumn Header="Model"             Width="160" Binding="{Binding Model}"/>',
        '                                        <DataGridTextColumn Header="Serial"            Width="110" Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="PartitionStyle"    Width= "75" Binding="{Binding PartitionStyle}"/>',
        '                                        <DataGridTextColumn Header="ProvisioningType"  Width="100" Binding="{Binding ProvisioningType}"/>',
        '                                        <DataGridTextColumn Header="OperationalStatus" Width="140" Binding="{Binding OperationalStatus}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="1" Name="DiskExtension" HeadersVisibility="None">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"              Width="150" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"             Width="*"   Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="2" Name="DiskPartition">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"      Width="*" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Type"      Width="200" Binding="{Binding Type}"/>',
        '                                        <DataGridTextColumn Header="Size"      Width= "85" Binding="{Binding Size}"/>',
        '                                        <DataGridTextColumn Header="Boot"      Width= "50" Binding="{Binding Boot}"/>',
        '                                        <DataGridTextColumn Header="Primary"   Width= "50" Binding="{Binding Primary}"/>',
        '                                        <DataGridTextColumn Header="Disk"      Width= "50" Binding="{Binding Disk}"/>',
        '                                        <DataGridTextColumn Header="Partition" Width= "50" Binding="{Binding Partition}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="3" Name="DiskVolume">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="DriveID"     Width= "50" Binding="{Binding DriveID}"/>',
        '                                        <DataGridTextColumn Header="Description" Width="*" Binding="{Binding Description}"/>',
        '                                        <DataGridTextColumn Header="Filesystem"  Width= "70" Binding="{Binding Filesystem}"/>',
        '                                        <DataGridTextColumn Header="Partition"   Width="200" Binding="{Binding Partition}"/>',
        '                                        <DataGridTextColumn Header="Freespace"   Width= "75" Binding="{Binding Freespace}"/>',
        '                                        <DataGridTextColumn Header="Used"        Width= "75" Binding="{Binding Used}"/>',
        '                                        <DataGridTextColumn Header="Size"        Width= "75" Binding="{Binding Size}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Network">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="135"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="Network">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="IfIndex" Width="50" Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Name"    Width="*" Binding="{Binding Name}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <DataGrid Grid.Row="1" Name="NetworkExtension" RowHeaderWidth="0" HeadersVisibility="None">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Width="150" Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value" Width="*"  Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Service">',
        '                <TabControl>',
        '                    <TabItem Header="Configuration">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <ComboBox Grid.Column="0" Margin="5" Name="ServiceProperty" VerticalAlignment="Center">',
        '                                    <ComboBoxItem Content="Name" IsSelected="True"/>',
        '                                    <ComboBoxItem Content="DisplayName"/>',
        '                                </ComboBox>',
        '                                <TextBox Grid.Column="1" Margin="5" Name="ServiceFilter"/>',
        '                                <Label Grid.Column="2" Background="#66FF66" Foreground="Black" HorizontalContentAlignment="Center" Content="Compliant"/>',
        '                                <Label Grid.Column="3" Background="#FFFF66" Foreground="Black" HorizontalContentAlignment="Center" Content="Unspecified"/>',
        '                                <Label Grid.Column="4" Background="#FF6666" Foreground="Black" HorizontalContentAlignment="Center" Content="Non Compliant"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="1" Grid.Column="0" Name="Service"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.RowStyle>',
        '                                    <Style TargetType="{x:Type DataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="AlternationIndex" Value="0">',
        '                                                <Setter Property="Background" Value="White"/>',
        '                                            </Trigger>',
        '                                            <Trigger Property="AlternationIndex" Value="1">',
        '                                                <Setter Property="Background" Value="SkyBlue"/>',
        '                                            </Trigger>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="{Binding Description}" TextWrapping="Wrap" Width="400" Background="#000000" Foreground="#00FF00"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
        '                                                <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
        '                                            </Trigger>',
        '                                            <MultiDataTrigger>',
        '                                                <MultiDataTrigger.Conditions>',
        '                                                    <Condition Binding="{Binding Scope}" Value="True"/>',
        '                                                    <Condition Binding="{Binding Match}" Value="False"/>',
        '                                                </MultiDataTrigger.Conditions>',
        '                                                <Setter Property="Background" Value="#F08080"/>',
        '                                            </MultiDataTrigger>',
        '                                            <MultiDataTrigger>',
        '                                                <MultiDataTrigger.Conditions>',
        '                                                    <Condition Binding="{Binding Scope}" Value="False"/>',
        '                                                    <Condition Binding="{Binding Match}" Value="False"/>',
        '                                                </MultiDataTrigger.Conditions>',
        '                                                <Setter Property="Background" Value="#FFFFFF64"/>',
        '                                            </MultiDataTrigger>',
        '                                            <MultiDataTrigger>',
        '                                                <MultiDataTrigger.Conditions>',
        '                                                    <Condition Binding="{Binding Scope}" Value="True"/>',
        '                                                    <Condition Binding="{Binding Match}" Value="True"/>',
        '                                                </MultiDataTrigger.Conditions>',
        '                                                <Setter Property="Background" Value="LightGreen"/>',
        '                                            </MultiDataTrigger>',
        '                                        </Style.Triggers>',
        '                                    </Style>',
        '                                </DataGrid.RowStyle>',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"       Width="50"  Binding="{Binding Index}"/>',
        '                                    <DataGridTextColumn Header="Name"        Width="150" Binding="{Binding Name}"/>',
        '                                    <DataGridTextColumn Header="Scoped"      Width="75"  Binding="{Binding Scope}"/>',
        '                                    <DataGridTemplateColumn Header="Profile" Width="100">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Slot}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="Skip"/>',
        '                                                    <ComboBoxItem Content="Disabled"/>',
        '                                                    <ComboBoxItem Content="Manual"/>',
        '                                                    <ComboBoxItem Content="Auto"/>',
        '                                                    <ComboBoxItem Content="Auto (Delayed)"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Status"      Width="75"  Binding="{Binding Status}"/>',
        '                                    <DataGridTextColumn Header="StartType"   Width="75"  Binding="{Binding StartMode}"/>',
        '                                    <DataGridTextColumn Header="DisplayName" Width="250" Binding="{Binding DisplayName}"/>',
        '                                    <DataGridTextColumn Header="PathName"    Width="150" Binding="{Binding PathName}"/>',
        '                                    <DataGridTextColumn Header="Description" Width="150" Binding="{Binding Description}"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <DataGrid Grid.Row="2" Name="ServiceExtension" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Width="150" Binding="{Binding Name}"/>',
        '                                    <DataGridTextColumn Header="Value" Width="*"   Binding="{Binding Value}"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="3">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="ServiceGet" Content="Get"/>',
        '                                <Button Grid.Column="1" Name="ServiceSet" Content="Apply" IsEnabled="False"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Preferences">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="10"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[Bypass]"/>',
        '                                <CheckBox Grid.Row="1" Name="ServiceBypassBuild"   Content="Skip Build/Version Check"/>',
        '                                <ComboBox Grid.Row="2" Name="ServiceBypassEdition" VerticalAlignment="Center">',
        '                                    <ComboBoxItem Content="Override Edition Check" IsSelected="True"/>',
        '                                    <ComboBoxItem Content="Windows 10 Home"/>',
        '                                    <ComboBoxItem Content="Windows 10 Pro"/>',
        '                                </ComboBox>',
        '                                <CheckBox Grid.Row="3" Name="ServiceBypassLaptop" Content="Enable Laptop Tweaks"/>',
        '                                <Label Grid.Row="4" Content="[Display Services]"/>',
        '                                <Grid Grid.Row="5">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <CheckBox Grid.Column="0" Name="ServiceDisplayActive" Content="Active"/>',
        '                                    <CheckBox Grid.Column="1" Name="ServiceDisplayInactive" Content="Inactive"/>',
        '                                    <CheckBox Grid.Column="2" Name="ServiceDisplaySkipped" Content="Skipped"/>',
        '                                </Grid>',
        '                                <Label    Grid.Row= "6" Content="[Miscellaneous]" Margin="5"/>',
        '                                <CheckBox Grid.Row= "7" Name="ServiceMiscSimulate"      Content="Simulate Changes [Dry Run]"/>',
        '                                <CheckBox Grid.Row= "8" Name="ServiceMiscXbox"          Content="Skip All Xbox Services"/>',
        '                                <CheckBox Grid.Row= "9" Name="ServiceMiscChange"        Content="Allow Change of Service State"/>',
        '                                <CheckBox Grid.Row="10" Name="ServiceMiscStopDisabled"  Content="Stop Disabled Services"/>',
        '                            </Grid>',
        '                            <Border   Grid.Column="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Grid Grid.Column="2">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[Logging]: Create logs for changes made by this utility"/>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <CheckBox Grid.Column="0" Name="ServiceLogServiceSwitch" Content="Services" HorizontalContentAlignment="Right"/>',
        '                                    <TextBox  Grid.Column="1" Name="ServiceLogServiceFile" IsEnabled="False"/>',
        '                                    <Button   Grid.Column="2" Name="ServiceLogServiceBrowse" Content="Browse"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <CheckBox Grid.Column="0" Name="ServiceLogScriptSwitch" Content="Script" HorizontalContentAlignment="Right"/>',
        '                                    <TextBox  Grid.Column="1" Name="ServiceLogScriptFile" IsEnabled="False"/>',
        '                                    <Button   Grid.Column="2" Name="ServiceLogScriptBrowse" Content="Browse"/>',
        '                                </Grid>',
        '                                <Label Grid.Row="3" Content="[Backup]: Save your current service configuration"/>',
        '                                <Grid Grid.Row="4">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <CheckBox  Grid.Column="0" Name="ServiceRegSwitch" Content="*.reg" HorizontalContentAlignment="Right"/>',
        '                                    <TextBox   Grid.Column="1" Name="ServiceRegFile" IsEnabled="False"/>',
        '                                    <Button    Grid.Column="2" Name="ServiceRegBrowse" Content="Browse"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="5">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <CheckBox  Grid.Column="0" Name="ServiceCsvSwitch" Content="*.csv" HorizontalContentAlignment="Right"/>',
        '                                    <TextBox   Grid.Column="1" Name="ServiceCsvFile" IsEnabled="False"/>',
        '                                    <Button    Grid.Column="2" Name="ServiceCsvBrowse" Content="Browse"/>',
        '                                </Grid>',
        '                                <Label Grid.Row="6" Content="[Development]"/>',
        '                                <CheckBox Grid.Row= "7" Name="ServiceDevErrors" Content="Diagnostic Output [On Error]"/>',
        '                                <CheckBox Grid.Row= "8" Name="ServiceDevLog" Content="Enable Development Logging"/>',
        '                                <CheckBox Grid.Row= "9" Name="ServiceDevConsole" Content="Enable Console"/>',
        '                                <CheckBox Grid.Row="10" Name="ServiceDevReport" Content="Enable Diagnostic"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="About">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="55"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="55"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[About]: Original Authors"/>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="[BlackViper]:"/>',
        '                                <TextBox Grid.Column="1" Text="https://www.blackviper.com"/>',
        '                            </Grid>',
        '                            <TextBox Grid.Row="2" Height="45" Padding="5" VerticalContentAlignment="Top" Text="BlackViper is the original author of the Black Viper Service Configuration featured on his website. The original utility dealt with (*.bat) files to provide a service configuration template for Windows services, dating back to the days of Windows (2000/XP)."/>',
        '                            <Grid Grid.Row="3">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="[MadBomb122]:"/>',
        '                                <TextBox Grid.Column="1" Text="https://www.github.com/MadBomb122"/>',
        '                            </Grid>',
        '                            <TextBox Grid.Row="4" Height="45" Padding="5"  VerticalContentAlignment="Top" Text="MadBomb122 is the author of the Windows PowerShell (GUI/graphical user interface) tool that adopted Black Viper&quot;s service configuration (*.bat) files in a prior version of this utility, which is featured on his [GitHub] repository above."/>',
        '                        </Grid>',
        '',
        '                    </TabItem>',
        '                </TabControl>',
        '            </TabItem>',
        '            <TabItem Header="Control">',
        '                <TabControl TabStripPlacement="Left">',
        '                    <TabItem Header="Preferences">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Global]:"/>',
        '                            <CheckBox Grid.Row="1" Name="ControlGlobalRestorePoint" Content="Create Restore Point"/>',
        '                            <CheckBox Grid.Row="2" Name="ControlGlobalShowSkipped" Content="Show Skipped Items"/>',
        '                            <CheckBox Grid.Row="3" Name="ControlGlobalRestart" Content="Restart When Done (Restart is Recommended)"/>',
        '                            <CheckBox Grid.Row="4" Name="ControlGlobalVersionCheck" Content="Check for Update (If found, will run with current settings)"/>',
        '                            <CheckBox Grid.Row="5" Name="ControlGlobalInternetCheck" Content="Skip Internet Check"/>',
        '                            <Label Grid.Row="6" Content="[Backup]:" Margin="5"/>',
        '                            <Grid Grid.Row="7">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="ControlBackupSave" Content="Save Settings"/>',
        '                                <Button Grid.Column="1" Name="ControlBackupLoad" Content="Load Settings"/>',
        '                                <Button Grid.Column="2" Name="ControlBackupWinDefault" Content="Windows Default"/>',
        '                                <Button Grid.Column="3" Name="ControlBackupResetDefault" Content="Reset All Items"/>',
        '                            </Grid>',
        '                            <Label Grid.Row="8" Content="[Script]"/>',
        '                            <ComboBox Grid.Row="9" Margin="5" Height="24" IsEnabled="False">',
        '                                <ComboBoxItem Content="Rewrite Module Version" IsSelected="True"/>',
        '                            </ComboBox>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Privacy">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Privacy]"/>',
        '                            <DataGrid Name="ControlPrivacy" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Windows Update">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Windows Update]"/>',
        '                            <DataGrid Name="ControlWindowsUpdate" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Service">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Service]"/>',
        '                            <DataGrid Grid.Row="1" Name="ControlService">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Context Menu">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Context Menu]"/>',
        '                            <DataGrid Name="ControlContext"  Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Taskbar">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Taskbar]"/>',
        '                            <DataGrid Name="ControlTaskbar" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Explorer">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Explorer]"/>',
        '                            <DataGrid Name="ControlExplorer" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Start Menu">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Start Menu]"/>',
        '                            <DataGrid Name="ControlStartMenu" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="This PC">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[This PC]"/>',
        '                            <DataGrid Name="ControlThisPC" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Desktop">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Desktop]"/>',
        '                            <DataGrid Name="ControlDesktop" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Lock Screen">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Lock Screen]"/>',
        '                            <DataGrid Name="ControlLockScreen" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Miscellaneous">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Miscellaneous]"/>',
        '                            <DataGrid Name="ControlMiscellaneous" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Photo Viewer">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Photo Viewer]"/>',
        '                            <DataGrid Name="ControlPhotoViewer" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Windows Store">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Windows Store]"/>',
        '                            <DataGrid Name="ControlWindowsStore" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="400" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="AppX">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[AppX Catalog]"/>',
        '                            <DataGrid Name="ControlAppX" Grid.Row="1" HeadersVisibility="None">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="#"            Binding="{Binding Index}"        Width="40"/>',
        '                                    <DataGridTextColumn Header="Cfg"          Binding="{Binding Profile}"      Width="40"/>',
        '                                    <DataGridTextColumn Header="DisplayName"  Binding="{Binding DisplayName}"  Width="250"/>',
        '                                    <DataGridTextColumn Header="CName"        Binding="{Binding CName}"        Width="200"/>',
        '                                    <DataGridTextColumn Header="VarName"      Binding="{Binding VarName}"      Width="200"/>',
        '                                    <DataGridTextColumn Header="Version"      Binding="{Binding Version}"      Width="150"/>',
        '                                    <DataGridTextColumn Header="Arch"         Binding="{Binding Architecture}" Width="40"/>',
        '                                    <DataGridTextColumn Header="ResID"        Binding="{Binding ResourceID}"   Width="40"/>',
        '                                    <DataGridTextColumn Header="PackageName"  Binding="{Binding PackageName}"  Width="400"/>',
        '                                    <DataGridTemplateColumn Header="Slot" Width="80">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Path=Selected, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="Skip"/>',
        '                                                    <ComboBoxItem Content="Unhide"/>',
        '                                                    <ComboBoxItem Content="Hide"/>',
        '                                                    <ComboBoxItem Content="Uninstall"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                </TabControl>',
        '            </TabItem>',
        '        </TabControl>',
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

    Enum ServiceStartModeType
    {
        Auto
        Manual
        Disabled
    }

    Class ServiceStartModeSlot
    {
        [UInt32] $Index
        [String] $Type
        [String] $Description
        ServiceStartModeSlot([String]$Type)
        {
            $This.Type        = [ServiceStartModeType]::$Type
            $This.Index       = [UInt32][ServiceStartModeType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ServiceStartModeList
    {
        [Object] $Output
        ServiceStartModeList()
        {
            $This.Output = @( ) 
            [System.Enum]::GetNames([ServiceStartModeType]) | % { $This.Add($_) }
        }
        Add([String]$Name)
        {
            $Item             = [ServiceStartModeSlot]::New($Name)
            $Item.Description = Switch ($Name)
            {
                Auto     { "The service automatically starts"    }
                Manual   { "The service requires a manual start" }
                Disabled { "The service is totally disabled"     }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStartModeType]::$Type]
        }
    }

    Enum ServiceStateType
    {
        Running
        Stopped
    }

    Class ServiceStateSlot
    {
        [UInt32] $Index
        [String] $Type
        [String] $Description
        ServiceStateSlot([String]$Type)
        {
            $This.Type        = [ServiceStateType]::$Type
            $This.Index       = [UInt32][ServiceStateType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ServiceStateList
    {
        [Object] $Output
        ServiceStateList()
        {
            $This.Output = @( ) 
            [System.Enum]::GetNames([ServiceStateType]) | % { $This.Add($_) }
        }
        Add([String]$Name)
        {
            $Item             = [ServiceStateSlot]::New($Name)
            $Item.Description = Switch ($Name)
            {
                Running  { "The service is currently running"     }
                Stopped  { "The service is NOT currently running" }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStateType]::$Type]
        }
    }

    Class ServiceSubcontroller
    {
        [Object] $StartMode
        [Object] $State
        ServiceSubcontroller()
        {
            $This.StartMode = [ServiceStartModeList]::New()
            $This.State     = [ServiceStateList]::New()
        }
        Load([Object]$Service)
        {
            $Service.StartMode   = $This.StartMode.Get($Service.Wmi.StartMode)
            $Service.State       = $This.State.Get($Service.Wmi.State)
        }
    }

    Class ServiceObject
    {
        [UInt32]              $Index
        Hidden [Object]         $Wmi
        [String]               $Name 
        [UInt32]              $Scope
        [UInt32]               $Slot
        [UInt32]   $DelayedAutoStart 
        [Object]          $StartMode
        [Object]              $State
        [String]             $Status
        [String]        $DisplayName
        [String]           $PathName 
        [String]        $Description
        Hidden [UInt32]       $Match
        ServiceObject([Int32]$Index,[Object]$Wmi)
        {
            $This.Index              = $Index
            $This.Wmi                = $Wmi
            $This.Name               = $Wmi.Name
            $This.DelayedAutoStart   = $Wmi.DelayedAutoStart
            $This.Status             = $Wmi.Status
            $This.DisplayName        = $Wmi.DisplayName
            $This.PathName           = $Wmi.PathName
            $This.Description        = $Wmi.Description
        }
    }

    Class ServiceControl
    {
        Hidden [Object]         $Sub
        Hidden [String]       $QMark
        Hidden [Hashtable]   $Config = @{
            Names   = (("AJRouter;ALG;AppHostSvc;AppIDSvc;Appinfo;AppMgmt;AppReadiness;AppVClient;aspnet_state;AssignedAccessManagerSvc;" + 
                        "AudioEndpointBuilder;AudioSrv;AxInstSV;BcastDVRUserService_{0};BDESVC;BFE;BITS;BluetoothUserService_{0};Browser;B" +
                        "TAGService;BthAvctpSvc;BthHFSrv;bthserv;c2wts;camsvc;CaptureService_{0};CDPSvc;CDPUserSvc_{0};CertPropSvc;COMSysA" + 
                        "pp;CryptSvc;CscService;defragsvc;DeviceAssociationService;DeviceInstall;DevicePickerUserSvc_{0};DevQueryBroker;Dh" +
                        "cp;diagnosticshub.standardcollector.service;diagsvc;DiagTrack;DmEnrollmentSvc;dmwappushsvc;Dnscache;DoSvc;dot3svc" +
                        ";DPS;DsmSVC;DsRoleSvc;DsSvc;DusmSvc;EapHost;EFS;embeddedmode;EventLog;EventSystem;Fax;fdPHost;FDResPub;fhsvc;Font" +
                        "Cache;FontCache3.0.0.0;FrameServer;ftpsvc;GraphicsPerfSvc;hidserv;hns;HomeGroupListener;HomeGroupProvider;HvHost;" +
                        "icssvc;IKEEXT;InstallService;iphlpsvc;IpxlatCfgSvc;irmon;KeyIso;KtmRm;LanmanServer;LanmanWorkstation;lfsvc;Licens" + 
                        "eManager;lltdsvc;lmhosts;LPDSVC;LxssManager;MapsBroker;MessagingService_{0};MSDTC;MSiSCSI;MsKeyboardFilter;MSMQ;M" +
                        "SMQTriggers;NaturalAuthentication;NcaSVC;NcbService;NcdAutoSetup;Netlogon;Netman;NetMsmqActivator;NetPipeActivato" +
                        "r;netprofm;NetSetupSvc;NetTcpActivator;NetTcpPortSharing;NlaSvc;nsi;OneSyncSvc_{0};p2pimsvc;p2psvc;PcaSvc;PeerDis" +
                        "tSvc;PerfHost;PhoneSvc;pla;PlugPlay;PNRPAutoReg;PNRPsvc;PolicyAgent;Power;PrintNotify;PrintWorkflowUserSvc_{0};Pr" +
                        "ofSvc;PushToInstall;QWAVE;RasAuto;RasMan;RemoteAccess;RemoteRegistry;RetailDemo;RmSvc;RpcLocator;SamSs;SCardSvr;S" +
                        "cDeviceEnum;SCPolicySvc;SDRSVC;seclogon;SEMgrSvc;SENS;Sense;SensorDataService;SensorService;SensrSvc;SessionEnv;S" + 
                        "grmBroker;SharedAccess;SharedRealitySvc;ShellHWDetection;shpamsvc;smphost;SmsRouter;SNMPTRAP;spectrum;Spooler;SSD" + 
                        "PSRV;ssh-agent;SstpSvc;StiSvc;StorSvc;svsvc;swprv;SysMain;TabletInputService;TapiSrv;TermService;Themes;TieringEn" +
                        "gineService;TimeBroker;TokenBroker;TrkWks;TrustedInstaller;tzautoupdate;UevAgentService;UI0Detect;UmRdpService;up" + 
                        "nphost;UserManager;UsoSvc;VaultSvc;vds;vmcompute;vmicguestinterface;vmicheartbeat;vmickvpexchange;vmicrdv;vmicshu" +
                        "tdown;vmictimesync;vmicvmsession;vmicvss;vmms;VSS;W32Time;W3LOGSVC;W3SVC;WaaSMedicSvc;WalletService;WarpJITSvc;WA" +
                        "S;wbengine;WbioSrvc;Wcmsvc;wcncsvc;WdiServiceHost;WdiSystemHost;WebClient;Wecsvc;WEPHOSTSVC;wercplsupport;WerSvc;" + 
                        "WFDSConSvc;WiaRpc;WinHttpAutoProxySvc;Winmgmt;WinRM;wisvc;WlanSvc;wlidsvc;wlpasvc;wmiApSrv;WMPNetworkSvc;WMSVC;wo" + 
                        "rkfolderssvc;WpcMonSvc;WPDBusEnum;WpnService;WpnUserService_{0};wscsvc;WSearch;wuauserv;wudfsvc;WwanSvc;xbgm;XblA" + 
                        "uthManager;XblGameSave;XboxGipSvc;XboxNetApiSvc"))
            Masks   = (("0;1;2;3;3;4;3;5;3;6;2;2;3;3;3;2;7;3;3;0;0;0;0;3;3;4;7;2;0;3;2;8;3;3;3;3;3;2;3;3;2;3;1;2;7;3;2;3;3;3;2;3;3;3;2;2" + 
                        ";1;3;3;3;2;3;1;2;3;3;6;3;3;1;1;3;3;9;0;1;3;3;2;2;1;3;3;3;2;3;1;0;3;3;1;11;2;2;0;3;3;0;0;3;2;2;3;3;2;1;2;2;7;3;3;" + 
                        "2;8;3;1;3;3;3;3;3;2;3;3;2;3;3;3;3;12;12;1;3;1;2;12;1;1;3;3;1;2;6;13;13;13;0;7;1;3;2;12;3;1;1;3;2;3;3;3;3;3;3;3;2" + 
                        ";13;3;0;2;3;3;3;2;3;12;5;3;0;3;2;3;3;3;6;1;1;1;1;1;1;1;1;14;3;3;3;2;3;3;3;3;3;3;2;0;3;3;0;3;3;3;3;13;3;3;2;1;1;1" + 
                        "5;3;3;3;1;3;1;1;3;2;2;7;7;3;3;1;3;1;1;3;1").Split(";"))
            Values   = (("2,2,2,2,2,2,1,1,2,2;2,2,2,2,1,1,1,1,1,1;3,0,3,0,3,0,3,0,3,0;2,0,2,0,2,0,2,0,2,0;0,0,2,2,2,2,1,1,2,2;0,0,1,0,1,0" + 
                        ",1,0,1,0;0,0,2,0,2,0,2,0,2,0;4,0,4,0,4,0,4,0,4,0;0,0,2,2,1,1,1,1,1,1;3,3,3,3,3,3,1,1,3,3;4,4,4,4,1,1,1,1,1,1;0,0" + 
                        ",0,0,0,0,0,0,0,0;1,0,1,0,1,0,1,0,1,0;2,2,2,2,1,1,1,1,2,2;0,0,3,0,3,0,3,0,3,0;3,3,3,3,2,2,2,2,3,3").Split(";"))
        }
        Hidden [Hashtable]  $Template
        [Object]              $Output
        ServiceControl()
        {
            $This.Sub                  = [ServiceSubcontroller]::New()
            $This.QMark                = (Get-Service | ? ServiceType -eq 224)[0].Name.Split('_')[-1]
            $This.Config.Names         = $This.Config.Names -f $This.QMark -Split ";"
            $This.Template             = @{ }

            ForEach ($I in 0..($This.Config.Names.Count-1))
            {
                $This.Template.Add($This.Config.Names[$I],$This.Config.Values[$This.Config.Masks[$I]])
            }

            $This.Output               = @( )

            ForEach ($Object in Get-WMIObject -Class Win32_Service | Sort-Object Name)
            {
                $Item                  = [ServiceObject]::New($This.Output.Count,$Object)
                If ($This.Template[$Item.Name])
                {
                    $Item.Scope        = 1
                }
                Else
                {
                    $Item.Scope        = 0
                }
                $This.Load($Item)
                $This.Output          += $Item
            }
        }
        Load([Object]$Service)
        {
            $This.Sub.Load($Service)
        }
    }

    Class Registry
    {
        [String] $Path
        [String] $Name
        Registry([String]$Path)
        {
            $This.Path  = $Path
        }
        Registry([String]$Path,[String]$Name)
        {
            $This.Path  = $Path
            $This.Name  = $Name
        }
        [Object] Get()
        {
            $This.Test()
            If ($This.Name)
            {
                Return Get-ItemProperty -LiteralPath $This.Path -Name $This.Name
            }
            Else
            {
                Return Get-ItemProperty -LiteralPath $This.Path
            }
        }
        [Void] Test()
        {
            $Split = $This.Path.Split("\")
            $Path_ = $Split[0]
            ForEach ($Item in $Split[1..($Split.Count-1)])
            {
                $Path_ = $Path_, $Item -join '\'
                If (!(Test-Path $Path_))
                {
                    New-Item -Path $Path_ -Verbose
                }
            }
        }
        [Void] Clear()
        {
            $This.Name  = $Null
            $This.Type  = $Null
            $This.Value = $Null
        }
        [Void] Set([Object]$Value)
        {
            $This.Test()
            Set-ItemProperty -LiteralPath $This.Path -Name $This.Name -Type "DWord" -Value $Value -Verbose
        }
        [Void] Set([String]$Type,[Object]$Value)
        {
            $This.Test()
            Set-ItemProperty -LiteralPath $This.Path -Name $This.Name -Type $Type -Value $Value -Verbose
        }
        [Void] Remove()
        {
            $This.Test()
            If ($This.Name)
            {
                Remove-ItemProperty -LiteralPath $This.Path -Name $This.Name -Verbose
            }
            Else
            {
                Remove-Item -LiteralPath $This.Path -Verbose
            }
        }
    }
    Function PrivacyList
    {
        Class Telemetry
        {
            [String]        $Name = "Telemetry"
            [String] $DisplayName = "Telemetry"
            [UInt32]       $Value = 1
            [String] $Description = "Various location and tracking features"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]      $Stack
            Telemetry()
            {
                $This.Stack       = @( )

                ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection','AllowTelemetry'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','AllowTelemetry'),
                ('HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection','AllowTelemetry'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds','AllowBuildPreview'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform','NoGenTicket'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows','CEIPEnable'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat','AITEnable'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat','DisableInventory'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP','CEIPEnable'),
                ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC','PreventHandwritingDataSharing'),
                ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput','AllowLinguisticDataCollection') | % { 

                    $This.Registry($_[0],$_[1])
                }
            }
            Registry([String]$Path,[String]$Name)
            {
                $This.Stack += [Registry]::New($Path,$Name)
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Telemetry"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Telemetry"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                        If ([Environment]::Is64BitProcess)
                        {
                            $This.Stack[2].Set(0)
                        }
                        $This.Stack[ 3].Remove()
                        $This.Stack[ 4].Remove()
                        $This.Stack[ 5].Remove()
                        $This.Stack[ 6].Remove()
                        $This.Stack[ 7].Remove()
                        $This.Stack[ 8].Remove()
                        $This.Stack[ 9].Remove()
                        $This.Stack[10].Remove()
                        $This.TelemetryTask() | % { Enable-ScheduledTask -TaskName $_ }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Telemetry"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                        If ([Environment]::Is64BitProcess)
                        {
                            $This.Stack[2].Set(0)
                        }
                        $This.Stack[ 3].Set(0)
                        $This.Stack[ 4].Set(1)
                        $This.Stack[ 5].Set(0)
                        $This.Stack[ 6].Set(0)
                        $This.Stack[ 7].Set(1)
                        $This.Stack[ 8].Set(0)
                        $This.Stack[ 9].Set(1)
                        $This.Stack[10].Set(0)
                        $This.TelemetryTask() | % { Disable-ScheduledTask -TaskName $_ }
                    }
                }
            }
            [String[]] TelemetryTask()
            {
                Return @(('{0}\{2}\Microsoft Compatibility Appraiser;{0}\{2}\ProgramDataUpdater;{0}\Autochk\Proxy;{0}\{3}\Consolidator;{0}\{3}\UsbCeip;{0}\DiskDiagnostic',
                '\Microsoft-Windows-DiskDiagnosticDataCollector;{1}\Office ClickToRun Service Monitor;{1}\{4}FallBack2016;{1}\{4}LogOn2016' -join '') -f "Microsoft\Windows",
                "Microsoft\Office","Application Experience","Customer Experience Improvement Program","OfficeTelemetryAgent").Split(";")
            }
        }

        Class WiFiSense
        {
            [String]        $Name = "WifiSense"
            [String] $DisplayName = "Wi-Fi Sense"
            [UInt32]       $Value = 1
            [String] $Description = "Lets devices more easily connect to a WiFi network"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            WiFiSense()
            {
                $This.Stack = @( 
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting','Value')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowConnectToWiFiSenseHotspots','Value')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','AutoConnectAllowedOEM')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','WiFiSenseAllowed')
                )
            }
            SetMode([UInt32]$Mode,[Uint32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [-] Wi-Fi Sense"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Wi-Fi Sense"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                        $This.Stack[2].Set(0)
                        $This.Stack[3].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Wi-Fi Sense"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                        $This.Stack[2].Remove()
                        $This.Stack[3].Remove()
                    }
                }
            }
        }

        Class SmartScreen
        {
            [String]        $Name = "SmartScreen"
            [String] $DisplayName = "SmartScreen"
            [UInt32]       $Value = 1
            [String] $Description = "Cloud-based anti-phishing and anti-malware component"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            SmartScreen()
            {
                $Path = Switch($This.GetWinVersion() -ge 1703)
                { 
                    $False 
                    { 
                        $Null 
                    }
                    $True  
                    { 
                        Get-AppxPackage | ? Name -eq Microsoft.MicrosoftEdge | % PackageFamilyName
                    }
                }

                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","SmartScreenEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost","EnableWebContentEvaluation")
                [Registry]::New("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","EnabledV9")
                [Registry]::New("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","PreventOverride")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [-] SmartScreen Filter"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] SmartScreen Filter"
                        $This.Stack[0].Set("String","RequireAdmin")
                        1..3 | % { $This.Stack[$_].Remove() }
                    }
                    2
                    {
                        Write-Host "Disabling [~] SmartScreen Filter"
                        $This.Stack[0].Set("String","Off")
                        1..3 | % { $This.Stack[$_].Set(0) }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class LocationTracking
        {
            [String]        $Name = "LocationTracking"
            [String] $DisplayName = "Location Tracking"
            [UInt32]       $Value = 1
            [String] $Description = "Monitors the current location of the system and manages geofences"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            LocationTracking()
            {
                $This.Stack = @(
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}','SensorPermissionState')
                [Registry]::New('HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration','Status')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Location Tracking"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Location Tracking"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Location Tracking"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class Feedback
        {
            [String]        $Name = "Feedback"
            [String] $DisplayName = "Feedback"
            [UInt32]       $Value = 1
            [String] $Description = "System Initiated User Feedback"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            Feedback()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Siuf\Rules','NumberOfSIUFInPeriod')
                [Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','DoNotShowFeedbackNotifications')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Feedback"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Feedback"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        "Microsoft\Windows\Feedback\Siuf\DmClient" | % { $_,"$_`OnScenarioDownload" } | % { Enable-ScheduledTask -TaskName $_ | Out-Null }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Feedback"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(1)
                        "Microsoft\Windows\Feedback\Siuf\DmClient" | % { $_,"$_`OnScenarioDownload" } | % { Disable-ScheduledTask -TaskName $_ | Out-Null }
                    }
                }
            }
        }

        Class AdvertisingID
        {
            [String]        $Name = "AdvertisingID"
            [String] $DisplayName = "Advertising ID"
            [UInt32]       $Value = 1
            [String] $Description = "Allows Microsoft to display targeted ads"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AdvertisingID()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo','Enabled')
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy','TailoredExperiencesWithDiagnosticDataEnabled')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Advertising ID"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Advertising ID"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Set(2)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Advertising ID"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class Cortana
        {
            [String]        $Name = "Cortana"
            [String] $DisplayName = "Cortana"
            [UInt32]       $Value = 1
            [String] $Description = "(Master Chief/Microsoft)'s personal voice assistant"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            Cortana()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortanaAboveLock")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchPrivacy")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Preferences","VoiceActivationEnableAboveLockscreen")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization","AllowInputPersonalization")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Cortana"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Cortana"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        $This.Stack[2].Set(0)
                        $This.Stack[3].Set(0)
                        $This.Stack[4].Remove()
                        $This.Stack[5].Remove()
                        $This.Stack[6].Remove()
                        $This.Stack[7].Set(1)
                        $This.Stack[8].Remove()
                        $This.Stack[9].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Cortana"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(1)
                        $This.Stack[2].Set(1)
                        $This.Stack[3].Set(0)
                        $This.Stack[4].Set(0)
                        $This.Stack[5].Set(1)
                        $This.Stack[6].Set(3)
                        $This.Stack[7].Set(0)
                        $This.Stack[8].Set(0)
                        $This.Stack[9].Set(1)
                    }
                }
            }
        }

        Class CortanaSearch
        {
            [String]        $Name = "CortanaSearch"
            [String] $DisplayName = "Cortana Search"
            [UInt32]       $Value = 1
            [String] $Description = "Allows Cortana to create search indexing for faster system search results"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            CortanaSearch()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Cortana Search"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Cortana Search"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Cortana Search"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class ErrorReporting
        {
            [String]        $Name = "ErrorReporting"
            [String] $DisplayName = "Error Reporting"
            [UInt32]       $Value = 1
            [String] $Description = "If Windows has an issue, it sends Microsoft a detailed report"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            ErrorReporting()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting","Disabled"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Error Reporting"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Error Reporting"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Error Reporting"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class AutoLoggerFile
        {
            [String]        $Name = "AutoLoggerFile"
            [String] $DisplayName = "Automatic Logger File"
            [UInt32]       $Value = 1
            [String] $Description = "This feature lets you trace the actions of a trace provider while Windows is booting"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AutoLoggerFile()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener","Start")
                [Registry]::New("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}","Start")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] AutoLogger"
                        }
                    }
                    1
                    {
                        Write-Host "Unrestricting [~] AutoLogger"
                        icacls $Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger /grant:r SYSTEM:`(OI`)`(CI`)F #| Out-Null
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Removing [~] AutoLogger, and restricting directory"
                        icacls $Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger /deny SYSTEM:`(OI`)`(CI`)F #| Out-Null
                        Remove-Item $Env:ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl -EA 0 -Verbose
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class DiagTrack
        {
            [String]        $Name = "DiagTracking"
            [String] $DisplayName = "Diagnostics Tracking"
            [UInt32]       $Value = 1
            [String] $Description = "Connected User Experiences and Telemetry"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [String]       $Stack
            DiagTrack()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Diagnostics Tracking"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Diagnostics Tracking"
                        Get-Service -Name DiagTrack
                        Set-Service -Name DiagTrack -StartupType Automatic
                        Start-Service -Name DiagTrack
                    }
                    2
                    {
                        Write-Host "Disabling [~] Diagnostics Tracking"
                        Stop-Service -Name DiagTrack
                        Set-Service -Name DiagTrack -StartupType Disabled
                        Get-Service -Name DiagTrack
                    }
                }
            }
        }

        Class WAPPush
        {
            [String]        $Name = "WAPPush"
            [String] $DisplayName = "WAP Push"
            [UInt32]       $Value = 1
            [String] $Description = "Device Management Wireless Application Protocol"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack 
            WAPPush()
            {
                $This.Stack = @([Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] WAP Push"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] WAP Push Service"
                        Set-Service -Name dmwappushservice -StartupType Automatic
                        Start-Service -Name dmwappushservice
                        $This.Stack[0].Set(1)
                        Get-Service -Name dmwappushservice
                    }
                    2
                    {
                        Write-Host "Disabling [~] WAP Push Service"
                        Stop-Service -Name dmwappushservice
                        Set-Service -Name dmwappushservice -StartupType Disabled
                        Get-Service -Name dmwappushservice
                    }
                }
            }
        }

        Class Privacy
        {
            [String[]] $Names = ("Telemetry WifiSense SmartScreen LocationTracking Feedback AdvertisingID Cortana CortanaSearch ",
                                 "ErrorReporting AutologgerFile DiagTrack WAPPush" -join "").Split(" ")
            [Object]  $Output
            Privacy()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch($Name)
                    {
                        Telemetry        { [Telemetry]::New()        }
                        WiFiSense        { [WiFiSense]::New()        }
                        SmartScreen      { [SmartScreen]::New()      }
                        LocationTracking { [LocationTracking]::New() } 
                        Feedback         { [Feedback]::New()         }
                        AdvertisingID    { [AdvertisingID]::New()    } 
                        Cortana          { [Cortana]::New()          }
                        CortanaSearch    { [CortanaSearch]::New()    } 
                        ErrorReporting   { [ErrorReporting]::New()   }
                        AutologgerFile   { [AutologgerFile]::New()   } 
                        DiagTrack        { [DiagTrack]::New()        }
                        WAPPush          { [WAPPush]::New()          }
                    }
                }
            }
        }
        [Privacy]::New().Output
    }
    Function WindowsUpdateList
    {
        Class UpdateMSProducts
        {
            [String]        $Name = "UpdateMSProducts"
            [String] $DisplayName = "Update MS Products"
            [UInt32]       $Value = 2
            [String] $Description = "Searches Windows Update for Microsoft Products"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            UpdateMSProducts()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Update Microsoft Products"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Update Microsoft Products"
                        (New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
                    }
                    2
                    {
                        Write-Host "Disabling [~] Update Microsoft Products"
                        (New-Object -ComObject Microsoft.Update.ServiceManager).RemoveService("7971f918-a847-4430-9279-4a52d1efe18d")
                    }
                }
            }
        }

        Class CheckForWindowsUpdate
        {
            [String]        $Name = "CheckForWindowsUpdate"
            [String] $DisplayName = "Check for Windows Updates"
            [UInt32]       $Value = 1
            [String] $Description = "Allows Windows Update to work automatically"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            CheckForWindowsUpdate()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","SetDisableUXWUAccess")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Check for Windows Updates"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Check for Windows Updates"
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Check for Windows Updates"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class WinUpdateType
        {
            [String]        $Name = "WinUpdateType"
            [String] $DisplayName = "Windows Update Type"
            [UInt32]       $Value = 3
            [String] $Description = "Allows Windows Update to work automatically"
            [String[]]   $Options = "Skip", "Notify", "Auto DL", "Auto DL+Install*", "Manual"
            [Object]       $Stack
            WinUpdateType()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Windows Update Check Type"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Notify for Windows Update downloads, notify to install"
                        $This.Stack[0].Set(2)
                    }
                    2
                    {
                        Write-Host "Enabling [~] Automatically download Windows Updates, notify to install"
                        $This.Stack[0].Set(3)
                    }
                    3
                    {
                        Write-Host "Enabling [~] Automatically download Windows Updates, schedule to install"
                        $This.Stack[0].Set(4)
                    }
                    4
                    {
                        Write-Host "Enabling [~] Allow local administrator to choose automatic updates"
                        $This.Stack[0].Set(5)
                    }
                }
            }
        }

        Class WinUpdateDownload
        {
            [String]        $Name = "WinUpdateDownload"
            [String] $DisplayName = "Windows Update Download"
            [UInt32]       $Value = 1
            [String] $Description = "Selects a source from which to pull Windows Updates"
            [String[]]   $Options = "Skip", "P2P*", "Local Only", "Disable"
            [Object]       $Stack
            WinUpdateDownload()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","DODownloadMode")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","SystemSettingsDownloadMode")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization","SystemSettingsDownloadMode")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","DODownloadMode")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] "
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Unrestricting Windows Update P2P to Internet"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                    }
                    2
                    {
                        Write-Host "Enabling [~] Restricting Windows Update P2P only to local network"
                        $This.Stack[1].Set(3)
                        Switch($This.GetWinVersion())
                        {
                            1507
                            {
                                $This.Stack[0]
                            }
                            {$_ -gt 1507 -and $_ -le 1607}
                            {
                                $This.Stack[0].Set(1)
                            }
                            Default
                            {
                                $This.Stack[0].Remove()
                            }
                        }
                    }
                    3
                    {
                        Write-Host "Disabling [~] Windows Update P2P"
                        $This.Stack[1].Set(3)
                        Switch ($This.GetWinVersion())
                        {
                            1507
                            {
                                $This.Stack[0].Set(0)
                            }
                            Default
                            {
                                $This.Stack[3].Set(100)
                            }
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class UpdateMSRT
        {
            [String]        $Name = "UpdateMSRT"
            [String] $DisplayName = "Update MSRT"
            [UInt32]       $Value = 1
            [String] $Description = "Allows updates for the Malware Software Removal Tool"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            UpdateMSRT()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\MRT","DontOfferThroughWUAU"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Malicious Software Removal Tool Update"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Malicious Software Removal Tool Update"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Malicious Software Removal Tool Update"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class UpdateDriver
        {
            [String]        $Name = "UpdateDriver"
            [String] $DisplayName = "Update Driver"
            [UInt32]       $Value = 1
            [String] $Description = "Allows drivers to be downloaded from Windows Update"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            UpdateDriver()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching","SearchOrderConfig")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","ExcludeWUDriversInQualityUpdate")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata","PreventDeviceMetadataFromNetwork")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Driver update through Windows Update"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Driver update through Windows Update"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        $This.Stack[2].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Driver update through Windows Update"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(1)
                        $This.Stack[2].Set(1)
                    }
                }
            }
        }

        Class RestartOnUpdate
        {
            [String]        $Name = "RestartOnUpdate"
            [String] $DisplayName = "Restart on Update"
            [UInt32]       $Value = 1
            [String] $Description = "Reboots the machine when an update is installed and requires it"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            RestartOnUpdate()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings","UxOption")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","NoAutoRebootWithLoggOnUsers")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUPowerManagement")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Windows Update Automatic Restart"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Windows Update Automatic Restart"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Remove()
                        $This.Stack[2].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Windows Update Automatic Restart"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                        $This.Stack[2].Set(0)
                    }
                }
            }
        }

        Class AppAutoDownload
        {
            [String]        $Name = "AppAutoDownload"
            [String] $DisplayName = "Consumer App Auto Download"
            [UInt32]       $Value = 1
            [String] $Description = "Provisioned Windows Store applications are downloaded"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AppAutoDownload()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate","AutoDownload")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsConsumerFeatures")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] App Auto Download"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] App Auto Download"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] App Auto Download"
                        $This.Stack[0].Set(2)
                        $This.Stack[1].Set(1)
                        If ($This.GetWinVersion() -le 1803)
                        {
                            $Key  = Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse |`
                            ? Name -like "*windows.data.placeholdertilecollection\Current" | % PSPath
                            $Data = Get-ItemProperty -Path $Key | % Data
                            Set-ItemProperty -Path $Key -Name Data -Type Binary -Value $Data[0..15] -Verbose
                            Stop-Process -Name ShellExperienceHost -Force
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class UpdateAvailablePopup
        {
            [String]        $Name = "UpdateAvailablePopup"
            [String] $DisplayName = "Update Available Pop-up"
            [UInt32]       $Value = 1
            [String] $Description = "If an update is available, a (pop-up/notification) will appear"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            UpdateAvailablePopup()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Update Available Popup"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Update Available Popup"
                        $This.MUSNotify()  | % { 
                            ICACLS $_ /remove:d '"Everyone"'
                            ICACLS $_ /grant ('Everyone' + ':(OI)(CI)F')
                            ICACLS $_ /setowner 'NT SERVICE\TrustedInstaller'
                            ICACLS $_ /remove:g '"Everyone"'
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Update Available Popup"
                        $This.MUSNotify() | % {
                            
                            Takeown /f $_
                            ICACLS $_ /deny '"Everyone":(F)'
                        }
                    }
                }
            }
            [String[]] MUSNotify()
            {
                Return @("","ux" | % { "$Env:windir\System32\musnotification$_.exe" })
            }
        }

        Class WindowsUpdateList
        {
            [String[]] $Names = ("UpdateMSProducts CheckForWindowsUpdate WinUpdateType WinUpdateDownload UpdateMSRT UpdateDriver",
                                "RestartOnUpdate AppAutoDownload UpdateAvailablePopup" -join '' ).Split(" ")
            [Object]  $Output
            WindowsUpdateList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        UpdateMSProducts      { [UpdateMSProducts]::New()      }
                        CheckForWindowsUpdate { [CheckForWindowsUpdate]::New() }
                        WinUpdateType         { [WinUpdateType]::New()         }
                        WinUpdateDownload     { [WinUpdateDownload]::New()     }
                        UpdateMSRT            { [UpdateMSRT]::New()            }
                        UpdateDriver          { [UpdateDriver]::New()          }
                        RestartOnUpdate       { [RestartOnUpdate]::New()       }
                        AppAutoDownload       { [AppAutoDownload]::New()       }
                        UpdateAvailablePopup  { [UpdateAvailablePopup]::New()  }
                    }
                }
            }
        }
        [WindowsUpdateList]::New().Output
    }
    Function ServiceList
    {
        Class UAC
        {
            [String]        $Name = "UAC"
            [String] $DisplayName = "User Access Control"
            [UInt32]       $Value = 2
            [String] $Description = "Sets restrictions/permissions for programs"
            [String[]]   $Options = "Skip", "Lower", "Normal*", "Higher"
            [Object]       $Stack
            UAC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","ConsentPromptBehaviorAdmin")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] UAC Level"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] UAC Level (Low)"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)

                    }
                    2
                    {
                        Write-Host "Setting [~] UAC Level (Default)"
                        $This.Stack[0].Set(5)
                        $This.Stack[1].Set(1)
                    }
                    3
                    {
                        Write-Host "Setting [~] UAC Level (High)"
                        $This.Stack[0].Set(2)
                        $This.Stack[1].Set(1)
                    }
                }
            }
        }

        Class SharingMappedDrives
        {
            [String]        $Name = "SharingMappedDrives"
            [String] $DisplayName = "Share Mapped Drives"
            [UInt32]       $Value = 2
            [String] $Description = "Shares any mapped drives to all users on the machine"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            SharingMappedDrives()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLinkedConnections"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Sharing mapped drives between users"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Sharing mapped drives between users"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Sharing mapped drives between users"
                        $This.Stack[0].Remove()
                    }
                }
            }
        }

        Class AdminShares
        {
            [String]        $Name = "AdminShares"
            [String] $DisplayName = "Administrative File Shares"
            [UInt32]       $Value = 1
            [String] $Description = "Reveals default system administration file shares"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AdminShares()
            {
                $This.Stack = @([Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters","AutoShareWks"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Hidden administrative shares"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Hidden administrative shares"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Hidden administrative shares"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class Firewall
        {
            [String]        $Name = "Firewall"
            [String] $DisplayName = "Firewall"
            [UInt32]       $Value = 1
            [String] $Description = "Enables the default firewall profile"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            Firewall()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile','EnableFirewall'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Firewall Profile"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Firewall Profile"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Firewall Profile"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class WinDefender
        {
            [String]        $Name = "WinDefender"
            [String] $DisplayName = "Windows Defender"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles Windows Defender, system default anti-virus/malware utility"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            WinDefender()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender","DisableAntiSpyware")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","WindowsDefender")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","SecurityHealth")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SpynetReporting")
                [Registry]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SubmitSamplesConsent")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Windows Defender"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Windows Defender"
                        $This.Stack[0].Remove()
                        Switch ($This.GetWinVersion())
                        {
                            {$_ -lt 1703}
                            {
                                $This.Stack[1].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")
                            }
                            Default
                            {
                                $This.Stack[2].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")     
                            }
                        }
                        $This.Stack[3].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Windows Defender"
                        Switch ($This.GetWinVersion())
                        {
                            {$_ -lt 1703}
                            {
                                $This.Stack[1].Remove()
                            }
                            Default
                            {
                                $This.Stack[2].Remove()    
                            }
                        }
                        $This.Stack[0].Set(1)
                        $This.Stack[4].Set(0)
                        $This.Stack[5].Set(2)
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class HomeGroups
        {
            [String]        $Name = "HomeGroups"
            [String] $DisplayName = "Home Groups"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the use of home groups, essentially a home-based workgroup"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            HomeGroups()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Home groups services"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Home groups services"
                        Set-Service   -Name HomeGroupListener -StartupType Manual
                        Set-Service   -Name HomeGroupProvider -StartupType Manual
                        Start-Service -Name HomeGroupProvider
                    }
                    2
                    {
                        Write-Host "Disabling [~] Home groups services"
                        Stop-Service  -Name HomeGroupListener
                        Set-Service   -Name HomeGroupListener -StartupType Disabled
                        Stop-Service  -Name HomeGroupProvider
                        Set-Service   -Name HomeGroupProvider -StartupType Disabled
                    }
                }
            }
        }

        Class RemoteAssistance
        {
            [String]        $Name = "RemoteAssistance"
            [String] $DisplayName = "Remote Assistance"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the ability to use Remote Assistance"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            RemoteAssistance()
            {
                $This.Stack = @([Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Remote Assistance"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Remote Assistance"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Remote Assistance"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class RemoteDesktop
        {
            [String]        $Name = "RemoteDesktop"
            [String] $DisplayName = "Remote Desktop"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the ability to use Remote Desktop"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            RemoteDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server","fDenyTSConnections")
                [Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp","UserAuthentication")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Remote Desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Remote Desktop"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Remote Desktop"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                }
            }
        }

        Class ServiceList
        {
            [String[]] $Names = "UAC SharingMappedDrives AdminShares Firewall WinDefender HomeGroups RemoteAssistance RemoteDesktop".Split(" ")
            [Object]  $Output
            ServiceList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        UAC                 { [UAC]::New()                 }
                        SharingMappedDrives { [SharingMappedDrives]::New() }
                        AdminShares         { [AdminShares]::New()         } 
                        Firewall            { [Firewall]::New()            } 
                        WinDefender         { [WinDefender]::New()         }
                        Homegroups          { [HomeGroups]::New()          }
                        RemoteAssistance    { [RemoteAssistance]::New()    }
                        RemoteDesktop       { [RemoteDesktop]::New()       }
                    }
                }
            }
        }
        [ServiceList]::New().Output
    }
    Function ContextList
    {
        Class CastToDevice
        {
            [String]        $Name = "CastToDevice"
            [String] $DisplayName = "Cast To Device"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item for casting to a device"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            CastToDevice()
            {
                $This.Stack = @([Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked","{7AD84985-87B4-4a16-BE58-8B72A5B390F7}"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Cast to device' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Cast to device' context menu item"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Cast to device' context menu item"
                        $This.Stack[0].Set("String","Play to Menu")
                    }
                }
            }
        }

        Class PreviousVersions
        {
            [String]        $Name = "PreviousVersions"
            [String] $DisplayName = "Previous Versions"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to select a previous version of a file"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            PreviousVersions()
            {
                $This.Stack = @(
                [Registry]::New("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
                [Registry]::New("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
                [Registry]::New("HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
                [Registry]::New("HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Previous versions' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Previous versions' context menu item"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Get()
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Previous versions' context menu item"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        $This.Stack[2].Remove()
                        $This.Stack[3].Remove()
                    }
                }
            }
        }

        Class IncludeInLibrary
        {
            [String]        $Name = "IncludeInLibrary"
            [String] $DisplayName = "Include in Library"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to include a selection in library items"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            IncludeInLibrary()
            {
                $This.Stack = @([Registry]::New("HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location","(Default)"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Include in Library' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Include in Library' context menu item"
                        $This.Stack[0].Set("String","{3dad6c5d-2167-4cae-9914-f99e41c12cfa}")
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Include in Library' context menu item"
                        $This.Stack[0].Set("String","")
                    }
                }
            }
        }

        Class PinToStart
        {
            [String]        $Name = "PinToStart"
            [String] $DisplayName = "Pin to Start"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to pin an item to the start menu"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            PinToStart()
            {
                $This.Stack = @(
                [Registry]::New('HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}','(Default)')
                [Registry]::New('HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}','(Default)')
                [Registry]::New('HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
                [Registry]::New('HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
                [Registry]::New('HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
                [Registry]::New('HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Pin to Start' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Pin to Start' context menu item"
                        $This.Stack[0].Set("String","Taskband Pin")
                        $This.Stack[1].Set("String","Start Menu Pin")
                        $This.Stack[2].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                        $This.Stack[3].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                        $This.Stack[4].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                        $This.Stack[5].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Pin to Start' context menu item"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        $This.Stack[2].Set("String","")
                        $This.Stack[3].Set("String","")
                        $This.Stack[4].Set("String","")
                        $This.Stack[5].Set("String","")
                    }
                }
            }
        }

        Class PinToQuickAccess
        {
            [String]        $Name = "PinToQuickAccess"
            [String] $DisplayName = "Pin to Quick Access"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to pin an item to the Quick Access bar"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            PinToQuickAccess()
            {
                $This.Stack = @(
                [Registry]::New('HKCR:\Folder\shell\pintohome','MUIVerb')
                [Registry]::New('HKCR:\Folder\shell\pintohome','AppliesTo')
                [Registry]::New('HKCR:\Folder\shell\pintohome\command','DelegateExecute')
                [Registry]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','MUIVerb')
                [Registry]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','AppliesTo')
                [Registry]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command','DelegateExecute')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Pin to Quick Access' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Pin to Quick Access' context menu item"
                        $This.Stack[0].Set("String",'@shell32.dll,-51377')
                        $This.Stack[1].Set("String",'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}" AND System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}" AND System.IsFolder:=System.StructuredQueryType.Boolean#True')
                        $This.Stack[2].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                        $This.Stack[3].Set("String",'@shell32.dll,-51377')
                        $This.Stack[4].Set("String",'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}" AND System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}" AND System.IsFolder:=System.StructuredQueryType.Boolean#True')
                        $This.Stack[5].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Pin to Quick Access' context menu item"
                        $This.Stack[0].Name = $Null
                        $This.Stack[0].Remove()
                        $This.Stack[3].Name = $Null
                        $This.Stack[3].Remove()
                    }
                }
            }
        }

        Class ShareWith
        {
            [String]        $Name = "PinToQuickAccess"
            [String] $DisplayName = "Pin to Quick Access"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to share a file with..."
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            ShareWith()
            {
                $This.Stack = @(
                [Registry]::New('HKCR:\*\shellex\ContextMenuHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\Directory\shellex\ContextMenuHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\Directory\shellex\CopyHookHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\Drive\shellex\ContextMenuHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\Directory\shellex\PropertySheetHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing','(Default)')
                [Registry]::New('HKCR:\*\shellex\ContextMenuHandlers\ModernSharing','(Default)')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Share with' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Share with' context menu item"
                        0..7 | % { $This.Stack[$_].Set("String","{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}") }
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Share with' context menu item"
                        0..7 | % { $This.Stack[$_].Set("String","") }
                    }
                }
            }
        }

        Class SendTo
        {
            [String]        $Name = "SendTo"
            [String] $DisplayName = "Send To"
            [UInt32]       $Value = 1
            [String] $Description = "Adds a context menu item to send an item to..."
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            SendTo()
            {
                $This.Stack = @([Registry]::New("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo","(Default)"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Send to' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Send to' context menu item"
                        $This.Stack[0].Set("String","{7BA4C740-9E81-11CF-99D3-00AA004AE837}")
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Send to' context menu item"
                        $This.Stack[0].Name = $Null
                        $This.Stack[0].Remove()
                    }
                }
            }
        }

        Class ContextList
        {
            [String[]] $Names = "CastToDevice PreviousVersions IncludeInLibrary PinToStart PinToQuickAccess ShareWith SendTo".Split(" ") 
            [Object]  $Output
            ContextList()
            {
                $This.Output  = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        CastToDevice     { [CastToDevice]::New()     }
                        PreviousVersions { [PreviousVersions]::New() }
                        IncludeInLibrary { [IncludeInLibrary]::New() }
                        PinToStart       { [PinToStart]::New()       }
                        PinToQuickAccess { [PinToQuickAccess]::New() }
                        ShareWith        { [ShareWith]::New()        }
                        SendTo           { [SendTo]::New()           }
                    }
                }
            }
        }
        [ContextList]::New().Output
    }
    Function TaskBarList
    {
        Class BatteryUIBar
        {
            [String]        $Name = "BatteryUIBar"
            [String] $DisplayName = "Battery UI Bar"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the battery UI bar element style"
            [String[]]   $Options = "Skip", "New*", "Classic"
            [Object]       $Stack
            BatteryUIBar()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32BatteryFlyout'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Battery UI Bar"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Battery UI Bar (New)"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Setting [~] Battery UI Bar (Old)"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class ClockUIBar
        {
            [String]        $Name = "ClockUIBar"
            [String] $DisplayName = "Clock UI Bar"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the clock UI bar element style"
            [String[]]   $Options = "Skip", "New*", "Classic"
            [Object]       $Stack
            ClockUIBar()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32TrayClockExperience'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Clock UI Bar"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Clock UI Bar (New)"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Setting [~] Clock UI Bar (Old)"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class VolumeControlBar
        {
            [String]        $Name = "VolumeControlBar"
            [String] $DisplayName = "Volume Control Bar"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the volume control bar element style"
            [String[]]   $Options = "Skip", "New (X-Axis)*", "Classic (Y-Axis)"
            [Object]       $Stack
            VolumeControlBar()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC','EnableMtcUvc'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Volume Control Bar"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Volume Control Bar (Horizontal)"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Volume Control Bar (Vertical)"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class TaskBarSearchBox
        {
            [String]        $Name = "TaskBarSearchBox"
            [String] $DisplayName = "Taskbar Search Box"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the taskbar search box element"
            [String[]]   $Options = "Skip", "Show*", "Hide"
            [Object]       $Stack
            TaskBarSearchBox()
            {
                $This.Stack = @([Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Taskbar 'Search Box' button"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Taskbar 'Search Box' button"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Taskbar 'Search Box' button"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class TaskViewButton
        {
            [String]        $Name = "VolumeControlBar"
            [String] $DisplayName = "Volume Control Bar"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the volume control bar element style"
            [String[]]   $Options = "Skip", "New (X-Axis)*", "Classic (Y-Axis)"
            [Object]       $Stack
            TaskViewButton()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowTaskViewButton'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Task View button"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Task View button"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Task View button"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class TaskbarIconSize
        {
            [String]        $Name = "TaskbarIconSize"
            [String] $DisplayName = "Taskbar Icon Size"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the taskbar icon size"
            [String[]]   $Options = "Skip", "Normal*", "Small"
            [Object]       $Stack
            TaskbarIconSize()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Icon size in taskbar"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Icon size in taskbar"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Icon size in taskbar"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class TaskbarGrouping
        {
            [String]        $Name = "TaskbarGrouping"
            [String] $DisplayName = "Taskbar Grouping"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the grouping of icons in the taskbar"
            [String[]]   $Options = "Skip", "Never", "Always*","When needed"
            [Object]       $Stack
            TaskbarGrouping()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarGlomLevel'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Group Taskbar Items"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Group Taskbar Items (Never)"
                        $This.Stack[0].Set(2)
                    }
                    2
                    {
                        Write-Host "Setting [~] Group Taskbar Items (Always)"
                        $This.Stack[0].Set(0)
                    }
                    3
                    {
                        Write-Host "Setting [~] Group Taskbar Items (When needed)"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class TrayIcons
        {
            [String]        $Name = "TrayIcons"
            [String] $DisplayName = "Tray Icons"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles whether the tray icons are shown or hidden"
            [String[]]   $Options = "Skip", "Auto*", "Always show"
            [Object]       $Stack
            TrayIcons()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Tray Icons"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Tray Icons (Hiding)"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Setting [~] Tray Icons (Showing)"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class SecondsInClock
        {
            [String]        $Name = "SecondsInClock"
            [String] $DisplayName = "Seconds in clock"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the clock/time shows the seconds"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            SecondsInClock()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSecondsInSystemClock'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Seconds in Taskbar clock"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Seconds in Taskbar clock"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Seconds in Taskbar clock"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class LastActiveClick
        {
            [String]        $Name = "LastActiveClick"
            [String] $DisplayName = "Last Active Click"
            [UInt32]       $Value = 2
            [String] $Description = "Makes taskbar buttons open the last active window"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            LastActiveClick()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LastActiveClick'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Last active click"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Last active click"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Last active click"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class TaskbarOnMultiDisplay
        {
            [String]        $Name = "TaskbarOnMultiDisplay"
            [String] $DisplayName = "Taskbar on multiple displays"
            [UInt32]       $Value = 1
            [String] $Description = "Displays the taskbar on each display if there are multiple screens"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            TaskbarOnMultiDisplay()
            {
                $This.Stack = @([Registry]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarEnabled'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Taskbar on Multiple Displays"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Taskbar on Multiple Displays"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Taskbar on Multiple Displays"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class TaskbarButtonDisplay
        {
            [String]        $Name = "TaskbarButtonDisplay"
            [String] $DisplayName = "Multi-display taskbar"
            [UInt32]       $Value = 2
            [String] $Description = "Defines where the taskbar button should be if there are multiple screens"
            [String[]]   $Options = "Skip", "All", "Current Window*","Main + Current Window"
            [Object]       $Stack
            TaskbarButtonDisplay()
            {
                $This.Stack = @([Registry]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarMode'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Taskbar buttons on multiple displays"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Taskbar buttons on multiple displays (All taskbars)"
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] Taskbar buttons on multiple displays (Taskbar where window is open)"
                        $This.Stack[0].Set(2)
                    }
                    3
                    {
                        Write-Host "Setting [~] Taskbar buttons on multiple displays (Main taskbar and where window is open)"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }
        Class TaskbarList
        {
            [String[]] $Names = ("BatteryUIBar ClockUIBar VolumeControlBar TaskbarSearchBox TaskViewButton TaskbarIconSize TaskbarGrouping TrayIcons",
                                "SecondsInClock LastActiveClick" -join '').Split(" ")
            [Object]   $Output
            TaskbarList()
            {
                $This.Output  = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        BatteryUIBar     { [BatteryUIBar]::New()     }
                        ClockUIBar       { [ClockUIBar]::New()       }
                        VolumeControlBar { [VolumeControlBar]::New() }
                        TaskbarSearchBox { [TaskbarSearchBox]::New() }
                        TaskViewButton   { [TaskViewButton]::New()   }
                        TaskbarIconSize  { [TaskbarIconSize]::New()  }
                        TaskbarGrouping  { [TaskbarGrouping]::New()  }
                        TrayIcons        { [TrayIcons]::New()        }
                    }
                }
            }
        }
        [TaskbarList]::New().Output
    }
	Function StartMenuList
    {
        Class StartMenuWebSearch
        {
            [String]        $Name = "StartMenuWebSearch"
            [String] $DisplayName = "Start Menu Web Search"
            [UInt32]       $Value = 1
            [String] $Description = "Allows the start menu search box to search the internet"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            StartMenuWebSearch()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','BingSearchEnabled')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','DisableWebSearch')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Bing Search in Start Menu"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Bing Search in Start Menu"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Bing Search in Start Menu"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(1)
                    }
                }
            }
        }

        Class StartSuggestions
        {
            [String]        $Name = "StartSuggestions"
            [String] $DisplayName = "Start Menu Suggestions"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the suggested apps in the start menu"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            StartSuggestions()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","ContentDeliveryAllowed")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","OemPreInstalledAppsEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEverEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SilentInstalledAppsEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SystemPaneSuggestionsEnabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","Start_TrackProgs")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-314559Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-310093Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338387Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338388Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338389Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338393Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338394Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338396Enabled")
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338398Enabled")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Start Menu Suggestions"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Start Menu Suggestions"
                        0..15 | % { $This.Stack[$_].Set(1) }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Start Menu Suggestions"
                        0..15 | % { $This.Stack[$_].Set(0) }
                        If ($This.GetWinVersion() -ge 1803) 
                        {
                            $Key = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
                            Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Key.Data[0..15]
                            Stop-Process -Name ShellExperienceHost -Force
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class MostUsedAppStartMenu
        {
            [String]        $Name = "MostUsedAppStartMenu"
            [String] $DisplayName = "Most Used Applications"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the most used applications in the start menu"
            [String[]]   $Options = "Skip", "Show*", "Hide"
            [Object]       $Stack
            MostUsedAppStartMenu()
            {
                $This.Stack = @([Registry]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Start_TrackProgs'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Most used apps in Start Menu"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Most used apps in Start Menu"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Most used apps in Start Menu"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class RecentItemsFrequent
        {
            [String]        $Name = "RecentItemsFrequent"
            [String] $DisplayName = "Recent Items Frequent"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the most recent frequently used (apps/items) in the start menu"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            RecentItemsFrequent()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu',"Start_TrackDocs"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Recent items and frequent places"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Recent items and frequent places"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Recent items and frequent places"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class UnpinItems
        {
            [String]        $Name = "UnpinItems"
            [String] $DisplayName = "Unpin Items"
            [UInt32]       $Value = 0
            [String] $Description = "Toggles the unpin (apps/items) from the start menu"
            [String[]]   $Options = "Skip", "Enable"
            [Object]       $Stack
            UnpinItems()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Unpinning Items"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Unpinning Items"
                        If ($This.GetWinVersion() -le 1709) 
                        {
                            Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | % {
                                $data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
                                $data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
                                Set-ItemProperty -Path "$($_.PsPath)\Current" -Name Data -Type Binary -Value $data.Split(",")
                            }
                        }
                        Else 
                        {
                            $key     = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
                            $data    = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
                            Set-ItemProperty -Path $key.PSPath -Name Data -Type Binary -Value $data
                            Stop-Process -Name ShellExperienceHost -Force
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }
        Class StartMenuList
        {
            [String[]] $Names = ("StartMenuWebSearch StartSuggestions MostUsedAppStartMenu RecentItemsFrequent UnpinItems").Split(" ")
            [Object]  $Output
            StartMenuList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        StartMenuWebSearch   { [StartMenuWebSearch]::New()   }
                        StartSuggestions     { [StartSuggestions]::New()     }
                        MostUsedAppStartMenu { [MostUsedAppStartMenu]::New() }
                        RecentItemsFrequent  { [RecentItemsFrequent]::New()  }
                        UnpinItems           { [UnpinItems]::New()           }
                    }
                }
            }
        }
        [StartMenuList]::New().Output
    }
    Function ExplorerList
    {
        Class AccessKeyPrompt
        {
            [String]        $Name = "AccessKeyPrompt"
            [String] $DisplayName = "Access Key Prompt"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the accessibility keys (menus/prompts)"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AccessKeyPrompt()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\Control Panel\Accessibility\StickyKeys',"Flags")
                [Registry]::New('HKCU:\Control Panel\Accessibility\ToggleKeys',"Flags")
                [Registry]::New('HKCU:\Control Panel\Accessibility\Keyboard Response',"Flags")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Accessibility keys prompts"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Accessibility keys prompts"
                        $This.Stack[0].Set("String",510)
                        $This.Stack[1].Set("String",62)
                        $This.Stack[2].Set("String",126)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Accessibility keys prompts"
                        $This.Stack[0].Set("String",506)
                        $This.Stack[1].Set("String",58)
                        $This.Stack[2].Set("String",122)
                    }
                }
            }
        }

        Class F1HelpKey
        {
            [String]        $Name = "F1HelpKey"
            [String] $DisplayName = "F1 Help Key"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the F1 help menu/prompt"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            F1HelpKey()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0")
                [Registry]::New('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32',"(Default)")
                [Registry]::New('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64',"(Default)")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] F1 Help Key"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] F1 Help Key"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] F1 Help Key"
                        $This.Stack[1].Set("String","")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                        $This.Stack[2].Set("String","")  
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class AutoPlay
        {
            [String]        $Name = "AutoPlay"
            [String] $DisplayName = "AutoPlay"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles autoplay for inserted discs or drives"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AutoPlay()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Autoplay"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Autoplay"
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Autoplay"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class AutoRun
        {
            [String]        $Name = "AutoRun"
            [String] $DisplayName = "AutoRun"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles autorun for programs on an inserted discs or drives"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AutoRun()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer','NoDriveTypeAutoRun'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Autorun"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Autorun"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Autorun"
                        $This.Stack[0].Set(255)
                    }
                }
            }
        }

        Class PidInTitleBar
        {
            [String]        $Name = "PidInTitleBar"
            [String] $DisplayName = "Process ID"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the process ID in a window title bar"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            PidInTitleBar()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowPidInTitle'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Process ID on Title bar"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Process ID on Title bar"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Process ID on Title bar"
                        $This.Stack[0].Remove()
                    }
                }
            }
        }

        Class AeroSnap
        {
            [String]        $Name = "AeroSnap"
            [String] $DisplayName = "AeroSnap"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the ability to snap windows to the sides of the screen"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AeroSnap()
            {
                $This.Stack = @([Registry]::New('HKCU:\Control Panel\Desktop','WindowArrangementActive'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Aero Snap"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Aero Snap"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Aero Snap"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class AeroShake
        {
            [String]        $Name = "AeroShake"
            [String] $DisplayName = "AeroShake"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the ability to minimize all windows by jiggling the title bar of an active window"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AeroShake()
            {
                $This.Stack = @([Registry]::New('HKCU:\Software\Policies\Microsoft\Windows\Explorer','NoWindowMinimizingShortcuts'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Aero Shake"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Aero Shake"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Aero Shake"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class KnownExtensions
        {
            [String]        $Name = "KnownExtensions"
            [String] $DisplayName = "Known File Extensions"
            [UInt32]       $Value = 2
            [String] $Description = "Shows known (mime-types/file extensions)"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            KnownExtensions()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','HideFileExt'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Known File Extensions"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Known File Extensions"
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Known File Extensions"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class HiddenFiles
        {
            [String]        $Name = "HiddenFiles"
            [String] $DisplayName = "Show Hidden Files"
            [UInt32]       $Value = 2
            [String] $Description = "Shows all hidden files"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            HiddenFiles()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Hidden'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Hidden Files"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Hidden Files"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Hidden Files"
                        $This.Stack[0].Set(2)
                    }
                }
            }
        }

        Class SystemFiles
        {
            [String]        $Name = "SystemFiles"
            [String] $DisplayName = "Show System Files"
            [UInt32]       $Value = 2
            [String] $Description = "Shows all system files"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            SystemFiles()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSuperHidden'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] System Files"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] System Files"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] System Files"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class ExplorerOpenLoc
        {
            [String]        $Name = "ExplorerOpenLoc"
            [String] $DisplayName = "Explorer Open Location"
            [UInt32]       $Value = 1
            [String] $Description = "Default path/location opened with a new explorer window"
            [String[]]   $Options = "Skip", "Quick Access*", "This PC"
            [Object]       $Stack
            ExplorerOpenLoc()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LaunchTo'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Default Explorer view to Quick Access"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Default Explorer view to Quick Access"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Default Explorer view to Quick Access"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class RecentFileQuickAccess
        {
            [String]        $Name = "RecentFileQuickAccess"
            [String] $DisplayName = "Recent File Quick Access"
            [UInt32]       $Value = 1
            [String] $Description = "Shows recent files in the Quick Access menu"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            RecentFileQuickAccess()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Recent Files in Quick Access"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Recent Files in Quick Access (Showing)"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set("String","Recent Items Instance Folder")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[2].Set("String","Recent Items Instance Folder")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Recent Files in Quick Access (Hiding)"
                        $This.Stack[0].Set(0)
                    }
                    3
                    {
                        Write-Host "Setting [~] Recent Files in Quick Access (Removing)"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[2].Remove()
                        }
                    }
                }
            }
        }

        Class FrequentFoldersQuickAccess
        {
            [String]        $Name = "FrequentFoldersQuickAccess"
            [String] $DisplayName = "Frequent Folders Quick Access"
            [UInt32]       $Value = 1
            [String] $Description = "Show frequently used folders in the Quick Access menu"
            [String[]]   $Options = "Skip", "Show*", "Hide"
            [Object]       $Stack
            FrequentFoldersQuickAccess()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowFrequent'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Frequent folders in Quick Access"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Frequent folders in Quick Access"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Frequent folders in Quick Access"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class WinContentWhileDrag
        {
            [String]        $Name = "WinContentWhileDrag"
            [String] $DisplayName = "Window Content while dragging"
            [UInt32]       $Value = 1
            [String] $Description = "Show the content of a window while it is being dragged/moved"
            [String[]]   $Options = "Skip", "Show*", "Hide"
            [Object]       $Stack
            WinContentWhileDrag()
            {
                $This.Stack = @([Registry]::New('HKCU:\Control Panel\Desktop','DragFullWindows'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Window content while dragging"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Window content while dragging"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Window content while dragging"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class StoreOpenWith
        {
            [String]        $Name = "StoreOpenWith"
            [String] $DisplayName = "Store Open With..."
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the ability to use the Microsoft Store to open an unknown file/program"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            StoreOpenWith()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer','NoUseStoreOpenWith'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Search Windows Store for Unknown Extensions"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Search Windows Store for Unknown Extensions"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Search Windows Store for Unknown Extensions"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class WinXPowerShell
        {
            [String]        $Name = "WinXPowerShell"
            [String] $DisplayName = "Win X PowerShell"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles whether (Win + X) opens PowerShell or a Command Prompt"
            [String[]]   $Options = "Skip", "PowerShell*", "Command Prompt"
            [Object]       $Stack
            WinXPowerShell()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','DontUsePowerShellOnWinX'))
                If ($This.GetWinVersion() -lt 1703)
                {
                    $This.Value   = 2
                }
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] (Win+X) PowerShell/Command Prompt"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] (Win+X) PowerShell/Command Prompt"
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] (Win+X) PowerShell/Command Prompt"
                        $This.Stack[0].Set(1)
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class TaskManagerDetails
        {
            [String]        $Name = "TaskManagerDetails"
            [String] $DisplayName = "Task Manager Details"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles whether the task manager details are shown"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            TaskManagerDetails()
            {
                $This.Stack = @([Registry]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager',"Preferences"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Task Manager Details"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Task Manager Details"
                        $Path         = $This.Stack[0].Path
                        $Task         = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
                        $Collect      = @( )
                        $Timeout      = 0
                        $TM           = $Null
                        Do
                        {
                            Start-Sleep -Milliseconds 100
                            $TM       = Get-ItemProperty -Path $Path | % Preferences
                            $Collect += 100
                            $TimeOut  = $Collect -join "+" | Invoke-Expression
                        }
                        Until ($TM -or $Timeout -ge 30000)
                        Stop-Process $Task
                        $TM[28]       = 0
                        $This.Stack[0].Set("Binary",$TM)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Task Manager Details"
                        $TM           = $This.Stack[0].Get().Preferences
                        $TM[28]       = 1
                        $This.Stack[0].Set("Binary",$TM)
                    }
                }
            }
        }

        Class ReopenAppsOnBoot
        {
            [String]        $Name = "ReopenAppsOnBoot"
            [String] $DisplayName = "Reopen apps at boot"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles applications to reopen at boot time"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            ReopenAppsOnBoot()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','DisableAutomaticRestartSignOn'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                If ($This.GetWinVersion() -eq 1709)
                {
                    Switch ($Mode)
                    {
                        0
                        {
                            If ($ShowSkipped)
                            {
                                Write-Host "Skipping [!] Reopen applications at boot time"
                            }
                        }
                        1
                        {
                            Write-Host "Enabling [~] Reopen applications at boot time"
                            $This.Stack[0].Set(0)
                        }
                        2
                        {
                            Write-Host "Disabling [~] Reopen applications at boot time"
                            $This.Stack[0].Set(1)
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class Timeline
        {
            [String]        $Name = "Timeline"
            [String] $DisplayName = "Timeline"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles Windows Timeline, for recovery of items at a prior point in time"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            Timeline()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System','EnableActivityFeed'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                If ($This.GetWinVersion())
                {
                    Switch ($Mode)
                    {
                        0
                        {
                            If ($ShowSkipped)
                            {
                                Write-Host "Skipping [!] Windows Timeline"
                            }
                        }
                        1
                        {
                            Write-Host "Enabling [~] Windows Timeline"
                            $This.Stack[0].Set(1)
                        }
                        2
                        {
                            Write-Host "Disabling [~] Windows Timeline"
                            $This.Stack[0].Set(0)
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class LongFilePath
        {
            [String]        $Name = "LongFilePath"
            [String] $DisplayName = "Long File Path"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles whether file paths are longer, or not"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            LongFilePath()
            {
                $This.Stack = @(
                [Registry]::New('HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem','LongPathsEnabled')
                [Registry]::New('HKLM:\SYSTEM\ControlSet001\Control\FileSystem','LongPathsEnabled')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Long file path"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Long file path"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Long file path"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                    }
                }
            }
        }

        Class AppHibernationFile
        {
            [String]        $Name = "AppHibernationFile"
            [String] $DisplayName = "App Hibernation File"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the system swap file use"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AppHibernationFile()
            {
                $This.Stack = @([Registry]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management","SwapfileControl"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] App Hibernation File (swapfile.sys)"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] App Hibernation File (swapfile.sys)"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] App Hibernation File (swapfile.sys)"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }
        Class ExplorerList
        {
            [String[]] $Names = ("AccessKeyPrompt F1HelpKey AutoPlay AutoRun PidInTitleBar RecentFileQuickAccess FrequentFoldersQuickAccess ",
                                "WinContentWhileDrag StoreOpenWith LongFilePath ExplorerOpenLoc WinXPowerShell AppHibernationFile Timeline ",
                                "AeroSnap AeroShake KnownExtensions HiddenFiles SystemFiles TaskManager ReopenApps" -join '').Split(" ")
            [Object]  $Output
            ExplorerList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        AccessKeyPrompt            { [AccessKeyPrompt]::New()            }
                        F1HelpKey                  { [F1HelpKey]::New()                  }
                        AutoPlay                   { [AutoPlay]::New()                   }
                        AutoRun                    { [AutoRun]::New()                    }
                        PidInTitleBar              { [PidInTitleBar]::New()              }
                        RecentFileQuickAccess      { [RecentFileQuickAccess]::New()      }
                        FrequentFoldersQuickAccess { [FrequentFoldersQuickAccess]::New() }
                        WinContentWhileDrag        { [WinContentWhileDrag]::New()        }
                        StoreOpenWith              { [StoreOpenWith]::New()              }
                        LongFilePath               { [LongFilePath]::New()               }
                        ExplorerOpenLoc            { [ExplorerOpenLoc]::New()            }
                        WinXPowerShell             { [WinXPowerShell]::New()             }
                        AppHibernationFile         { [AppHibernationFile]::New()         }
                        Timeline                   { [Timeline]::New()                   }
                        AeroSnap                   { [AeroSnap]::New()                   }
                        AeroShake                  { [AeroShake]::New()                  }
                        KnownExtensions            { [KnownExtensions]::New()            }
                        HiddenFiles                { [HiddenFiles]::New()                }
                        SystemFiles                { [SystemFiles]::New()                }
                        TaskManagerDetails         { [TaskManagerDetails]::New()         }
                        ReopenAppsOnBoot           { [ReopenAppsOnBoot]::New()           }
                    }
                }
            }
        }
        [ExplorerList]::New().Output
    }
    Function ThisPCIconList
    {
        Class DesktopIconInThisPC
        {
            [String]        $Name = "DesktopIconInThisPC"
            [String] $DisplayName = "Desktop [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Desktop icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            DesktopIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Desktop folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Desktop folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Set("String","Show")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[3].Get()
                            $This.Stack[4].Get()
                            $This.Stack[5].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Desktop folder in This PC (Hidden)"
                        $This.Stack[2].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Desktop folder in This PC (None)"
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                        }
                    }
                }
            }
        }

        Class DocumentsIconInThisPC
        {
            [String]        $Name = "DocumentsIconInThisPC"
            [String] $DisplayName = "Documents [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Documents icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            DocumentsIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Documents folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Documents folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String","Show")
                        $This.Stack[4].Set("String","{FDD39AD0-238F-46AF-ADB4-6C85480369C7}")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Get()
                            $This.Stack[6].Get()
                            $This.Stack[7].Get()
                            $This.Stack[8].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Documents folder in This PC (Hidden)"
                        $This.Stack[3].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[8].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Documents folder in This PC (None)"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                            $This.Stack[6].Remove()
                        }
                    }
                }
            }
        }

        Class DownloadsIconInThisPC
        {
            [String]        $Name = "DownloadsIconInThisPC"
            [String] $DisplayName = "Downloads [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Downloads icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            DownloadsIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Downloads folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Downloads folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String","Show")
                        $This.Stack[4].Set("String","{374DE290-123F-4565-9164-39C4925E467B}")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Get()
                            $This.Stack[6].Get()
                            $This.Stack[7].Get()
                            $This.Stack[8].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Downloads folder in This PC (Hidden)"
                        $This.Stack[3].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[8].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Documents folder in This PC (None)"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                            $This.Stack[6].Remove()
                        }
                    }
                }
            }
        }

        Class MusicIconInThisPC
        {
            [String]        $Name = "MusicIconInThisPC"
            [String] $DisplayName = "Music [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Music icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            MusicIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Music folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Music folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String","Show")
                        $This.Stack[4].Set("String","{4BD8D571-6D19-48D3-BE97-422220080E43}")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Get()
                            $This.Stack[6].Get()
                            $This.Stack[7].Get()
                            $This.Stack[8].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Music folder in This PC (Hidden)"
                        $This.Stack[3].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[8].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Music folder in This PC (None)"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                            $This.Stack[6].Remove()
                        }
                    }
                }
            }
        }

        Class PicturesIconInThisPC
        {
            [String]        $Name = "PicturesIconInThisPC"
            [String] $DisplayName = "Pictures [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Pictures icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            PicturesIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Pictures folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Pictures folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String","Show")
                        $This.Stack[4].Set("String","{33E28130-4E1E-4676-835A-98395C3BC3BB}")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Get()
                            $This.Stack[6].Get()
                            $This.Stack[7].Get()
                            $This.Stack[8].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Pictures folder in This PC (Hidden)"
                        $This.Stack[3].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[8].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Pictures folder in This PC (None)"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                            $This.Stack[6].Remove()
                        }
                    }
                }
            }
        }

        Class VideosIconInThisPC
        {
            [String]        $Name = "VideosIconInThisPC"
            [String] $DisplayName = "Videos [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the Videos icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            VideosIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Videos folder in This PC"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Videos folder in This PC (Shown)"
                        $This.Stack[0].Get()
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String","Show")
                        $This.Stack[4].Set("String","{18989B1D-99B5-455B-841C-AB7C74E4DDFC}")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Get()
                            $This.Stack[6].Get()
                            $This.Stack[7].Get()
                            $This.Stack[8].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] Videos folder in This PC (Hidden)"
                        $This.Stack[3].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[8].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] Videos folder in This PC (None)"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Stack[5].Remove()
                            $This.Stack[6].Remove()
                        }
                    }
                }
            }
        }

        Class ThreeDObjectsIconInThisPC
        {
            [String]        $Name = "ThreeDObjectsIconInThisPC"
            [String] $DisplayName = "3D Objects [Explorer]"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the 3D Objects icon in 'This PC'"
            [String[]]   $Options = "Skip", "Show/Add*", "Hide", "Remove"
            [Object]       $Stack
            ThreeDObjectsIconInThisPC()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")
                [Registry]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                If ($This.GetWinVersion() -ge 1709)
                {
                    Switch ($Mode)
                    {
                        0
                        {
                            If ($ShowSkipped)
                            {
                                Write-Host "Skipping [!] 3D Objects folder in This PC"
                            }
                        }
                        1
                        {
                            Write-Host "Enabling [~] 3D Objects folder in This PC (Shown)"
                            $This.Stack[0].Get()
                            $This.Stack[1].Get()
                            $This.Stack[2].Set("String","Show")
                            If ([Environment]::Is64BitOperatingSystem)
                            {
                                $This.Stack[3].Get()
                                $This.Stack[4].Get()
                                $This.Stack[5].Set("String","Show")
                            }
                        }
                        2
                        {
                            Write-Host "Setting [~] 3D Objects folder in This PC (Hidden)"
                            $This.Stack[2].Set("String","Hide")
                            If ([Environment]::Is64BitOperatingSystem)
                            {
                                $This.Stack[5].Set("String","Hide")
                            }
                        }
                        3
                        {
                            Write-Host "Setting [~] 3D Objects folder in This PC (None)"
                            $This.Stack[1].Remove()
                            If ([Environment]::Is64BitOperatingSystem)
                            {
                                $This.Stack[5].Remove()
                            }
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }
        Class ThisPCList
        {
            [String[]] $Names = ("IconInThisPC" | % { "Desktop$_ Documents$_ Downloads$_ Music$_ Pictures$_ Videos$_ ThreeDObjects$_" }).Split(" ")
            [Object]  $Output
            ThisPCList()
            {
                $This.Output  = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        DesktopIconInThisPC       { [DesktopIconInThisPC]::New()       }
                        DocumentsIconInThisPC     { [DocumentsIconInThisPC]::New()     }
                        DownloadsIconInThisPC     { [DownloadsIconInThisPC]::New()     }
                        MusicIconInThisPC         { [MusicIconInThisPC]::New()         }
                        PicturesIconInThisPC      { [PicturesIconInThisPC]::New()      }
                        VideosIconInThisPC        { [VideosIconInThisPC]::New()        }
                        ThreeDObjectsIconInThisPC { [ThreeDObjectsIconInThisPC]::New() }
                    }
                }
            }
        }
        [ThisPCList]::New().Output
    }
    Function DesktopIconList
    {
        Class ThisPCOnDesktop
        {
            [String]        $Name = "ThisPCOnDesktop"
            [String] $DisplayName = "This PC [Desktop]"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the 'This PC' icon on the desktop"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            ThisPCOnDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] This PC Icon on desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] This PC Icon on desktop (Shown)"
                        $This.Stack[0].Set(0)
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] This PC Icon on desktop (Hidden)"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class NetworkOnDesktop
        {
            [String]        $Name = "NetworkOnDesktop"
            [String] $DisplayName = "Network [Desktop]"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the 'Network' icon on the desktop"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            NetworkOnDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}')
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Network Icon on desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Network Icon on desktop (Shown)"
                        $This.Stack[0].Set(0)
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] Network Icon on desktop (Hidden)"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class RecycleBinOnDesktop
        {
            [String]        $Name = "RecycleBinOnDesktop"
            [String] $DisplayName = "Recycle Bin [Desktop]"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the 'Recycle Bin' icon on the desktop"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            RecycleBinOnDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{645FF040-5081-101B-9F08-00AA002F954E}')
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{645FF040-5081-101B-9F08-00AA002F954E}')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Recycle Bin Icon on desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Recycle Bin Icon on desktop (Shown)"
                        $This.Stack[0].Set(0)
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] Recycle Bin Icon on desktop (Hidden)"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class UsersFileOnDesktop
        {
            [String]        $Name = "UsersFileOnDesktop"
            [String] $DisplayName = "My Documents [Desktop]"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the 'Users File' icon on the desktop"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            UsersFileOnDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}')
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Users file Icon on desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Users file Icon on desktop (Shown)"
                        $This.Stack[0].Set(0)
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] Users file Icon on desktop (Hidden)"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }

        Class ControlPanelOnDesktop
        {
            [String]        $Name = "ControlPanelOnDesktop"
            [String] $DisplayName = "Control Panel [Desktop]"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the 'Control Panel' icon on the desktop"
            [String[]]   $Options = "Skip", "Show", "Hide*"
            [Object]       $Stack
            ControlPanelOnDesktop()
            {
                $This.Stack = @(
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}')
                [Registry]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Control Panel Icon on desktop"
                        }
                    }
                    1
                    {
                        Write-Host "Setting [~] Control Panel Icon on desktop (Shown)"
                        $This.Stack[0].Set(0)
                        $This.Stack[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Setting [~] Control Panel Icon on desktop (Hidden)"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }
        Class DesktopIconList
        {
            [String[]] $Names = ("OnDesktop" | % { "ThisPC$_ Network$_ RecycleBin$_ UsersFile$_ ControlPanel$_" }).Split(" ")
            [Object]  $Output
            DesktopIconList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        ThisPCOnDesktop       { [ThisPCOnDesktop]::New()   }
                        NetworkOnDesktop      { [NetworkOnDesktop]::New()      }
                        RecycleBinOnDesktop   { [RecycleBinOnDesktop]::New()   }
                        UsersFileOnDesktop    { [UsersFileOnDesktop]::New()    }
                        ControlPanelOnDesktop { [ControlPanelOnDesktop]::New() }
                    }
                }
            }
        }
        [DesktopIconList]::New().Output
    }
    Function LockScreenList
    {
        Class LockScreen
        {
            [String]        $Name = "LockScreen"
            [String] $DisplayName = "Lock Screen"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the lock screen"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            LockScreen()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreen'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Lock Screen"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Lock Screen"
                        If ($This.GetWinVersion() -ge 1607)
                        {
                            Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$False -Verbose
                        }
                        Else
                        {
                            $This.Stack[0].Remove()
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Lock Screen"
                        If ($This.GetWinVersion() -ge 1607)
                        {
                            $Service             = New-Object -com Schedule.Service
                            $Service.Connect()
                            $Task                = $Service.NewTask(0)
                            $Task.Settings.DisallowStartIfOnBatteries = $False
                            $Trigger             = $Task.Triggers.Create(9)
                            $Trigger             = $Task.Triggers.Create(11)
                            $trigger.StateChange = 8
                            $Action              = $Task.Actions.Create(0)
                            $Action.Path         = 'reg.exe'
                            $Action.Arguments    = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
                            $Service.GetFolder('\').RegisterTaskDefinition('Disable LockScreen',$Task,6,'NT AUTHORITY\SYSTEM',$null,4)
                        }
                        Else
                        {
                            $This.Stack[0].Set(1)
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class LockScreenPassword
        {
            [String]        $Name = "LockScreenPassword"
            [String] $DisplayName = "Lock Screen Password"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the lock screen password"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            LockScreenPassword()
            {
                $This.Stack = @(
                [Registry]::New("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure")
                [Registry]::New("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Lock Screen Password"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Lock Screen Password"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Lock Screen Password"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class PowerMenuLockScreen
        {
            [String]        $Name = "PowerMenuLockScreen"
            [String] $DisplayName = "Power Menu Lock Screen"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the power menu on the lock screen"
            [String[]]   $Options = "Skip", "Show*", "Hide"
            [Object]       $Stack
            PowerMenuLockScreen()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','shutdownwithoutlogon'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Power Menu on Lock Screen"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Power Menu on Lock Screen"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Power Menu on Lock Screen"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class CameraOnLockScreen
        {
            [String]        $Name = "CameraOnLockScreen"
            [String] $DisplayName = "Camera On Lock Screen"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the camera on the lock screen"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            CameraOnLockScreen()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreenCamera'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Camera at Lockscreen"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Camera at Lockscreen"
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Camera at Lockscreen"
                        $This.Stack[0].Set(1)
                    }
                }
            }
        }
        Class LockScreenList
        {
            [String[]] $Names = 'LockScreen LockScreenPassword PowerMenuLockScreen CameraOnLockScreen'.Split(" ")
            [Object]  $Output
            LockScreenList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        LockScreen          { [LockScreen]::New()          }
                        LockScreenPassword  { [LockScreenPassword]::New()  }
                        PowerMenuLockScreen { [PowerMenuLockScreen]::New() }
                        CameraOnLockScreen  { [CameraOnLockScreen]::New()  }
                    }
                }
            }
        }
        [LockScreenList]::New().Output
    }
    Function MiscellaneousList
    {
        Class ScreenSaver
        {
            [String]        $Name = "ScreenSaver"
            [String] $DisplayName = "Screen Saver"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the screen saver"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            ScreenSaver()
            {
                $This.Stack = @([Registry]::New("HKCU:\Control Panel\Desktop","ScreenSaveActive"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Screensaver"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Screensaver"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Screensaver"
                        $This.Stack[0].Set(0)
                    }
                }
            }
        }

        Class AccountProtectionWarn
        {
            [String]        $Name = "AccountProtectionWarn"
            [String] $DisplayName = "Account Protection Warning"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles system security account protection warning"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            AccountProtectionWarn()
            {
                $This.Stack = @([Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows Security Health\State','AccountProtection_MicrosoftAccount_Disconnected'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                If ($This.GetWinVersion() -ge 1803)
                {
                    Switch ($Mode)
                    {
                        0
                        {
                            If ($ShowSkipped)
                            {
                                Write-Host "Skipping [!] Account Protection Warning"
                            }
                        }
                        1
                        {
                            Write-Host "Enabling [~] Account Protection Warning"
                            $This.Stack[0].Remove()
                        }
                        2
                        {
                            Write-Host "Disabling [~] Account Protection Warning"
                            $This.Stack[0].Set(1)
                        }
                    }
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class ActionCenter
        {
            [String]        $Name = "ActionCenter"
            [String] $DisplayName = "Action Center"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles system action center"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            ActionCenter()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer','DisableNotificationCenter')
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications','ToastEnabled')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Action Center"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Action Center"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Action Center"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class StickyKeyPrompt
        {
            [String]        $Name = "StickyKeyPrompt"
            [String] $DisplayName = "Sticky Key Prompt"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the sticky keys prompt/dialog"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            StickyKeyPrompt()
            {
                $This.Stack = @([Registry]::New('HKCU:\Control Panel\Accessibility\StickyKeys','Flags'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Sticky Key Prompt"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Sticky Key Prompt"
                        $This.Stack[0].Set("String",510)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Sticky Key Prompt"
                        $This.Stack[0].Set("String",506)
                    }
                }
            }
        }

        Class NumbLockOnStart
        {
            [String]        $Name = "NumbLockOnStart"
            [String] $DisplayName = "Number lock on start"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles whether the number lock key is engaged upon start"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            NumbLockOnStart()
            {
                $This.Stack = @([Registry]::New('HKU:\.DEFAULT\Control Panel\Keyboard','InitialKeyboardIndicators'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Num Lock on startup"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Num Lock on startup"
                        $This.Stack[0].Set(2147483650)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Num Lock on startup"
                        $This.Stack[0].Set(2147483648)
                    }
                }
            }
        }

        Class F8BootMenu
        {
            [String]        $Name = "F8BootMenu"
            [String] $DisplayName = "F8 Boot Menu"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles whether the F8 boot menu can be access upon boot"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            F8BootMenu()
            {
                $This.Stack = @()
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] F8 Boot menu options"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] F8 Boot menu options"
                        bcdedit /set `{current`} bootmenupolicy Legacy
                    }
                    2
                    {
                        Write-Host "Disabling [~] F8 Boot menu options"
                        bcdedit /set `{current`} bootmenupolicy Standard
                    }
                }
            }
        }

        Class RemoteUACAcctToken
        {
            [String]        $Name = "RemoteUACAcctToken"
            [String] $DisplayName = "Remote UAC Account Token"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the local account token filter policy to mitigate remote connections"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            RemoteUACAcctToken()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','LocalAccountTokenFilterPolicy'))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Remote UAC Local Account Token Filter"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Remote UAC Local Account Token Filter"
                        $This.Stack[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Remote UAC Local Account Token Filter"
                        $This.Stack[0].Remove()
                    }
                }
            }
        }

        Class HibernatePower
        {
            [String]        $Name = "HibernatePower"
            [String] $DisplayName = "Hibernate Power"
            [UInt32]       $Value = 0
            [String] $Description = "Toggles the hibernation power option"
            [String[]]   $Options = "Skip", "Enable", "Disable"
            [Object]       $Stack
            HibernatePower()
            {
                $This.Stack = @(
                [Registry]::New('HKLM:\SYSTEM\CurrentControlSet\Control\Power','HibernateEnabled')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings','ShowHibernateOption')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Hibernate Option"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Hibernate Option"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(1)
                        powercfg /HIBERNATE ON
                    }
                    2
                    {
                        Write-Host "Disabling [~] Hibernate Option"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                        powercfg /HIBERNATE OFF
                    }
                }
            }
        }

        Class SleepPower
        {
            [String]        $Name = "SleepPower"
            [String] $DisplayName = "Sleep Power"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the sleep power option"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            SleepPower()
            {
                $This.Stack = @([Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings',"ShowSleepOption"))
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Sleep Option"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Sleep Option"
                        $This.Stack[0].Set(1)
                        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                        powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                    }
                    2
                    {
                        Write-Host "Disabling [~] Sleep Option"
                        $This.Stack[0].Set(0)
                        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                        powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                    }
                }
            }
        }
        Class MiscellaneousList
        {
            [String[]] $Names = 'ScreenSaver AccountProtectionWarn ActionCenter StickyKeyPrompt NumblockOnStart F8BootMenu RemoteUACAcctToken HibernatePower SleepPower'.Split(" ")
            [Object]  $Output
            MiscellaneousList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        ScreenSaver           { [ScreenSaver]::New()           }
                        AccountProtectionWarn { [AccountProtectionWarn]::New() }
                        ActionCenter          { [ActionCenter]::New()          }
                        StickyKeyPrompt       { [StickyKeyPrompt]::New()       }
                        NumblockOnStart       { [NumblockOnStart]::New()       }
                        F8BootMenu            { [F8BootMenu]::New()            }
                        RemoteUACAcctToken    { [RemoteUACAcctToken]::New()    }
                        HibernatePower        { [HibernatePower]::New()        }
                        SleepPower            { [SleepPower]::New()            }
                    }
                }
            }
        }
        [MiscellaneousList]::New().Output
    }
    Function PhotoViewerList
    {
        Class PVFileAssociation
        {
            [String]        $Name = "PVFileAssociation"
            [String] $DisplayName = "Photo Viewer File Association"
            [UInt32]       $Value = 2
            [String] $Description = "Associates common image types with Photo Viewer"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            PVFileAssociation()
            {
                $This.Stack = @(
                [Registry]::New("HKCR:\Paint.Picture\shell\open","MUIVerb")
                [Registry]::New("HKCR:\giffile\shell\open","MUIVerb")
                [Registry]::New("HKCR:\jpegfile\shell\open","MUIVerb")
                [Registry]::New("HKCR:\pngfile\shell\open","MUIVerb")
                [Registry]::New("HKCR:\Paint.Picture\shell\open\command","(Default)")
                [Registry]::New("HKCR:\giffile\shell\open\command","(Default)")
                [Registry]::New("HKCR:\jpegfile\shell\open\command","(Default)")
                [Registry]::New("HKCR:\pngfile\shell\open\command","(Default)")
                [Registry]::New("HKCR:\giffile\shell\open","CommandId")
                [Registry]::New("HKCR:\giffile\shell\open\command","DelegateExecute")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Photo Viewer File Association"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Photo Viewer File Association"
                        0..3 | % { 

                            $This.Stack[$_  ].Set("ExpandString","@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
                            $This.Stack[$_+4].Set("ExpandString","%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1")
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Photo Viewer File Association"
                        $This.Stack[0] | % { $_.Clear(); $_.Remove() }
                        $This.Stack[1].Remove()
                        $This.Stack[2] | % { $_.Clear(); $_.Remove() }
                        $This.Stack[3] | % { $_.Clear(); $_.Remove() }
                        $This.Stack[5].Set("String","`"$Env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1")
                        $This.Stack[8].Set("String","IE.File")
                        $This.Stack[9].Set("String","{17FE9752-0B5A-4665-84CD-569794602F5C}")
                    }
                }
            }
        }

        Class PVOpenWithMenu
        {
            [String]        $Name = "PVOpenWithMenu"
            [String] $DisplayName = "Photo Viewer 'Open with' Menu"
            [UInt32]       $Value = 2
            [String] $Description = "Allows image files to be opened with Photo Viewer"
            [String[]]   $Options = "Skip", "Enable", "Disable*"
            [Object]       $Stack
            PVOpenWithMenu()
            {
                $This.Stack = @(
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open')
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open\command')
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget')
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open','MuiVerb')
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open\command','(Default)')
                [Registry]::New('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget','Clsid')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] 'Open with Photo Viewer' context menu item"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] 'Open with Photo Viewer' context menu item"
                        $This.Stack[1].Get()
                        $This.Stack[2].Get()
                        $This.Stack[3].Set("String",'@photoviewer.dll,-3043')
                        $This.Stack[4].Set("ExpandString","%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1")
                        $This.Stack[5].Set("String",'{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}')
                    }
                    2
                    {
                        Write-Host "Disabling [~] 'Open with Photo Viewer' context menu item"
                        $This.Stack[0].Remove()
                    }
                }
            }
        }
        Class PhotoViewerList
        {
            [String[]] $Names = "PVFileAssociation PVOpenWithMenu".Split(" ")
            [Object]  $Output
            PhotoViewerList()
            {
                $This.Output = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        PVFileAssociation { [PVFileAssociation]::New() }
                        PVOpenWithMenu    { [PVOpenWithMenu]::New()    }
                    }
                }
            }
        }
        [PhotoViewerList]::New().Output
    }
    Function WindowsAppsList
    {
        Class WindowsOptionalFeature
        {
            [String] $FeatureName
            [String] $State
            WindowsOptionalFeature([Object]$Object)
            {
                $This.FeatureName = $Object.FeatureName
                $This.State       = $Object.State
            }
        }

        Class WindowsOptionalFeatures
        {
            [Object] $Output
            WindowsOptionalFeatures()
            {
                $This.Output = Get-WindowsOptionalFeature -Online | % { [WindowsOptionalFeature]$_ }
            }
        }

        Class OneDrive
        {
            [String]        $Name = "OneDrive"
            [String] $DisplayName = "OneDrive"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles Microsoft OneDrive, which comes with the operating system"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            OneDrive()
            {
                $This.Stack = @(
                [Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive','DisableFileSyncNGSC')
                [Registry]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSyncProviderNotifications')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] OneDrive"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] OneDrive"
                        $This.Stack[0].Remove()
                        $This.Stack[1].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] OneDrive"
                        $This.Stack[0].Set(1)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }

        Class OneDriveInstall
        {
            [String]        $Name = "OneDriveInstall"
            [String] $DisplayName = "OneDriveInstall"
            [UInt32]       $Value = 1
            [String] $Description = "Installs/Uninstalls Microsoft OneDrive, which comes with the operating system"
            [String[]]   $Options = "Skip", "Installed*", "Uninstall"
            [Object]       $Stack
            OneDriveInstall()
            {
                $This.Stack = @(
                @("System32","SysWOW64")[[Environment]::Is64BitOperatingSystem] | % { "$Env:Windir\$_\OneDriveSetup.exe" }
                "$Env:USERPROFILE\OneDrive"
                "$Env:LOCALAPPDATA\Microsoft\OneDrive"
                "$Env:PROGRAMDATA\Microsoft OneDrive"
                "$Env:WINDIR\OneDriveTemp"
                "$Env:SYSTEMDRIVE\OneDriveTemp"
                [Registry]::New("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")
                [Registry]::New("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] OneDrive Install"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] OneDrive Install"
                        If ($This.TestPath()) 
                        {
                            Start-Process $This.Stack[0] -NoNewWindow 
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] OneDrive Install"
                        If ($THis.TestPath())
                        {
                            Stop-Process -Name OneDrive -Force
                            Start-Sleep -Seconds 3
                            Start-Process $This.Stack[0] "/uninstall" -NoNewWindow -Wait
                            Start-Sleep -Seconds 3
                            1..5 | % { Remove-Item $This.Stack[$_] -Force -Recurse }
                            $This.Stack[6].Remove()
                            $This.Stack[7].Remove()
                        }
                    }
                }
            }
            [Bool] TestPath()
            {
                Return Test-Path $This.Stack[0] -PathType Leaf
            }
        }

        Class XboxDVR
        {
            [String]        $Name = "XboxDVR"
            [String] $DisplayName = "Xbox DVR"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles Microsoft Xbox DVR"
            [String[]]   $Options = "Skip", "Enable*", "Disable"
            [Object]       $Stack
            XboxDVR()
            {
                $This.Stack = @(
                [Registry]::New('HKCU:\System\GameConfigStore','GameDVR_Enabled')
                [Registry]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR','AllowGameDVR')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Xbox DVR"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Xbox DVR"
                        $This.Stack[0].Set(1)
                        $This.Stack[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Xbox DVR"
                        $This.Stack[0].Set(0)
                        $This.Stack[1].Set(0)
                    }
                }
            }
        }
        
        Class MediaPlayer
        {
            [String]        $Name = "MediaPlayer"
            [String] $DisplayName = "Windows Media Player"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles Microsoft Windows Media Player, which comes with the operating system"
            [String[]]   $Options = "Skip", "Installed*", "Uninstall"
            [Object]       $Stack
            MediaPlayer([Object]$Features)
            {
                $This.Stack = @($Features | ? FeatureName -match MediaPlayback)
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Windows Media Player"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Windows Media Player"
                        $This.Stack[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Enabled"
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Windows Media Player"
                        $This.Stack[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Disabled"
                        }
                    }
                }
            }
        }

        Class WorkFolders
        {
            [String]        $Name = "WorkFolders"
            [String] $DisplayName = "Work Folders"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the WorkFolders-Client, which comes with the operating system"
            [String[]]   $Options = "Skip", "Installed*", "Uninstall"
            [Object]       $Stack
            WorkFolders([Object]$Features)
            {
                $This.Stack = @($Features | ? FeatureName -match WorkFolders-Client)
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Work Folders Client"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Work Folders Client"
                        $This.Stack[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Enabled"
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Work Folders Client"
                        $This.Stack[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Disabled"
                        }
                    }
                }
            }
        }

        Class FaxAndScan
        {
            [String]        $Name = "FaxAndScan"
            [String] $DisplayName = "Fax and Scan"
            [UInt32]       $Value = 1
            [String] $Description = "Toggles the FaxServicesClientPackage, which comes with the operating system"
            [String[]]   $Options = "Skip", "Installed*", "Uninstall"
            [Object]       $Stack
            FaxAndScan([Object]$Features)
            {
                $This.Stack = @($Features | ? FeatureName -match FaxServicesClientPackage)
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                Switch ($Mode)
                {
                    0
                    {
                        If ($ShowSkipped)
                        {
                            Write-Host "Skipping [!] Fax And Scan"
                        }
                    }
                    1
                    {
                        Write-Host "Enabling [~] Fax And Scan"
                        $This.Stack[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Enabled"
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Fax And Scan"
                        $This.Stack[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Stack[0].State = "Disabled"
                        }
                    }
                }
            }
        }

        Class LinuxSubsystem
        {
            [String]        $Name = "LinuxSubsystem"
            [String] $DisplayName = "Linux Subsystem (WSL)"
            [UInt32]       $Value = 2
            [String] $Description = "Toggles the Microsoft-Windows-Subsystem-Linux, which can be installed on Windows 1607 or later"
            [String[]]   $Options = "Skip", "Installed", "Uninstall*"
            [Object]       $Stack
            LinuxSubsystem([Object]$Features)
            {
                $This.Stack = @(
                $Features | ? FeatureName -match Microsoft-Windows-Subsystem-Linux
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock','AllowDevelopmentWithoutDevLicense')
                [Registry]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock','AllowAllTrustedApps')
                )
            }
            SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
            {
                If ($This.GetWinVersion() -gt 1607)
                {
                    Switch ($Mode)
                    {
                        0
                        {
                            If ($ShowSkipped)
                            {
                                Write-Host "Skipping [!] Linux Subsystem"
                            }
                        }
                        1
                        {
                            Write-Host "Enabling [~] Linux Subsystem"
                            $This.Stack[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart }
                            If ($? -eq $True)
                            {
                                $This.Stack[0].State = "Enabled"
                            }
                        }
                        2
                        {
                            Write-Host "Disabling [~] Linux Subsystem"
                            $This.Stack[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart }
                            If ($? -eq $True)
                            {
                                $This.Stack[0].State = "Disabled"
                            }
                        }
                    }
                }
                Else
                {
                    Write-Host "Error [!] This version of Windows does not support (WSL/Windows Subsystem for Linux)"
                }
            }
            [UInt32] GetWinVersion()
            {
                Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
            }
        }

        Class WindowsAppsList
        {
            [Object] $Features = [WindowsOptionalFeatures]::New().Output
            [String[]]  $Names = 'OneDrive OneDriveInstall XboxDVR MediaPlayer WorkFolders FaxAndScan LinuxSubsystem'.Split(" ")
            [Object]   $Output
            WindowsAppsList()
            {
                $This.Output   = ForEach ($Name in $This.Names)
                {
                    Switch ($Name)
                    {
                        OneDrive        { [OneDrive]::New()                      }
                        OneDriveInstall { [OneDriveInstall]::New()               }
                        XboxDVR         { [XboxDVR]::New()                       }
                        MediaPlayer     { [MediaPlayer]::New($This.Features)     }
                        WorkFolders     { [WorkFolders]::New($This.Features)     }
                        FaxAndScan      { [FaxAndScan]::New($This.Features)      }
                        LinuxSubsystem  { [LinuxSubsystem]::New($This.Features)  }
                    }
                }
            }
        }
        [WindowsAppsList]::New().Output
    }

    Class DisableVariousTasks
    {
        [UInt32] $Mode
        [Object] $Stack
        DisableVariousTasks()
        {
            $This.Stack = @()
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped,[Object[]]$TaskList)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        Write-Host "Skipping [!] Various Scheduled Tasks"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Various Scheduled Tasks"
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Enable-ScheduledTask }
                }
                2
                {
                    Write-Host "Disabling [~] Various Scheduled Tasks"
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask }
                }
            }
        }
    }

    Class ScreenSaverWaitTime
    {
        [UInt32] $Mode
        [Object] $Stack
        ScreenSaverWaitTime()
        {
            $This.Stack = @([Registry]::New('HKLM:\Software\Policies\Microsoft\Windows','ScreensaveTimeout'))
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        Write-Host "Skipping [!] ScreenSaver Wait Time"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] ScreenSaver Wait Time"
                }
                2
                {
                    Write-Host "Disabling [~] ScreenSaver Wait Time"
                }
            }
        }
    }
    Function AppXList
    {
        Class AppXTemplate
        {
            [String] $AppXName
            [String] $CName
            [String] $Varname
            AppXTemplate([String]$Line)
            {
                $Split = $Line.Split("/")
                $This.AppXName = $Split[0]
                $This.CName    = $Split[1]
                $This.Varname  = $Split[2]
            }
        }

        Class AppXProfile
        {
            [String[]] $Profile = (('{0}.3DBuilder/3DBuilder/APP_3DBuilder;{0}.{0}3DViewer/3DViewer/APP_3DViewer;{0}' +
            '.BingWeather/Bing Weather/APP_BingWeather;{0}.CommsPhone/Phone/APP_CommsPhone;{0}.windowscommunicationsapps' +
            '/Calendar & Mail/APP_Communications;{0}.GetHelp/{0}s Self-Help/APP_GetHelp;{0}.Getstarted/Get Started Lin' +
            'k/APP_Getstarted;{0}.Messaging/Messaging/APP_Messaging;{0}.{0}OfficeHub/Get Office Link/APP_{0}OffHub;{0}.M' + 
            'ovieMoments/Movie Moments/APP_MovieMoments;4DF9E0F8.Netflix/Netflix/APP_Netflix;{0}.Office.OneNote/Office O' + 
            'neNote/APP_OfficeOneNote;{0}.Office.Sway/Office Sway/APP_OfficeSway;{0}.OneConnect/One Connect/APP_OneConne' + 
            'ct;{0}.People/People/APP_People;{0}.Windows.Photos/Photos/APP_Photos;{0}.SkypeApp/Skype/APP_SkypeApp1;{0}.{' + 
            '0}SolitaireCollection/{0} Solitaire/APP_SolitaireCollect;{0}.{0}StickyNotes/Sticky Notes/APP_StickyNotes;{0' + 
            '}.WindowsSoundRecorder/Voice Recorder/APP_VoiceRecorder;{0}.WindowsAlarms/Alarms and Clock/APP_WindowsAlarm' + 
            's;{0}.WindowsCalculator/Calculator/APP_WindowsCalculator;{0}.WindowsCamera/Camera/APP_WindowsCamera;{0}.Win' + 
            'dowsFeedback/Windows Feedback/APP_WindowsFeedbak1;{0}.WindowsFeedbackHub/Windows Feedback Hub/APP_WindowsFe' + 
            'edbak2;{0}.WindowsMaps/Maps/APP_WindowsMaps;{0}.WindowsPhone/Phone Companion/APP_WindowsPhone;{0}.WindowsSt' + 
            'ore/{0} Store/APP_WindowsStore;{0}.Wallet/Stores Credit and Debit Card Information/APP_WindowsWallet;{0}.Xb' + 
            'ox.TCUI/Xbox Title-callable UI/App_XboxTCUI;{0}.XboxApp/Xbox App for Windows PC/App_XboxApp;{0}.XboxGameOve' + 
            'rlay/Xbox In-Game Overlay/App_XboxGameOverlay;{0}.XboxGamingOverlay/Xbox Gaming Overlay UI/App_XboxGamingOv' + 
            'erlay;{0}.XboxIdentityProvider/Xbox Identity Provider/App_XboxIdentityProvider;{0}.XboxSpeechtoTextOverlay/' + 
            'Xbox Speech-to-Text UI/App_XboxSpeechToText;{0}.ZuneMusic/Groove Music/APP_ZuneMusic;{0}.ZuneVideo/Groove V' + 
            'ideo/APP_ZuneVideo;') -f "Microsoft" -Split ";" )
            [Object] $Output
            AppXProfile()
            {
                $This.Output = $This.Profile | % { [AppXTemplate]$_ }
            }
        }

        Class AppXObject
        {
            Hidden [Object] $Object
            [UInt32]         $Index
            [String]       $Profile
            [String]         $CName
            [String]       $VarName
            [String]   $DisplayName
            [String]       $Version
            [String]  $Architecture
            [String]    $ResourceID
            [String]   $PackageName
            [Int32]          $Slot
            AppXObject([UInt32]$Index,[Object]$AppXProfile,[Object]$Object)
            {
                $This.Index        = $Index
                $This.Object       = $Object
                $This.DisplayName  = $Object.DisplayName
                $This.Version      = $Object.Version
                $This.Architecture = $Object.Architecture
                $This.ResourceID   = $Object.ResourceID
                $This.PackageName  = $Object.PackageName

                If ($Object.DisplayName -in $AppXProfile.AppXName)
                {
                    $Item              = $AppXProfile | ? AppXName -match $This.DisplayName
                    $This.Profile      = "+"
                    $This.CName        = $Item.CName
                    $This.VarName      = $Item.VarName
                    $This.Slot         = 0
                }
                Else
                {
                        $This.Profile      = "-"
                        $This.CName        = "-"
                        $This.VarName      = "-"
                        $This.Slot         = -1
                }
            }
        }

        Class AppXStack
        {
            [Object] $Profile = [AppXProfile]::New().Output
            [Object] $Output
            AppXStack()
            {
                $This.Output   = @( )
                Get-AppxProvisionedPackage -Online | % { $This.Output += [AppXObject]::New($This.Output.Count,$This.Profile,$_) }
            }
        }
        [AppXStack]::New().Output
    }

    Class Control
    {
        [Object]                    $Privacy
        [Object]              $WindowsUpdate
    	[Object]                    $Service
        [Object]                    $Context
        [Object]                    $Taskbar
        [Object]                  $StartMenu
        [Object]                   $Explorer
        [Object]                     $ThisPC
        [Object]                    $Desktop
        [Object]                 $LockScreen
        [Object]              $Miscellaneous
        [Object]                $PhotoViewer
        [Object]                $WindowsApps
        [Object]                       $AppX
        Control()
        {
            $This.Reset()
        }
        Reset()
        {
            $This.Privacy                    = PrivacyList
            $This.WindowsUpdate              = WindowsUpdateList
            $This.Service                    = ServiceList
            $This.Context                    = ContextList
            $This.Taskbar                    = TaskBarList
            $This.StartMenu                  = StartMenuList
            $This.Explorer                   = ExplorerList
            $This.ThisPC                     = ThisPCIconList
            $This.Desktop                    = DesktopIconList
            $This.LockScreen                 = LockScreenList
            $This.Miscellaneous              = MiscellaneousList
            $This.PhotoViewer                = PhotoViewerList
            $This.WindowsApps                = WindowsAppsList
            $This.AppX                       = AppXList
        }
        [Void] Toggle([Object]$Item)
        {
            $Item = Switch ($Item)
            {
                0 { 1 }
                1 { 0 }
            }
        }
    }

    Class ViperBombController
    {
        [Object] $Module
        [Object] $System
        [Object] $Xaml
        [String] $Caption
        [String] $Platform
        [String] $PSVersion
        [String] $Type
        [Object] $Service
        [Object] $Control
        ViperBombController()
        {
            $This.Module      = Get-FEModule -Mode 1
                                Import-Module AppX
            $This.Xaml        = [XamlWindow][ViperBombXaml]::Content
            $This.System      = Get-SystemDetails
            $This.System.ComputerSystem | % { $_.Memory = "{0} GB" -f [Regex]::Matches($_.Memory,"\d+\.\d{2}").Value }
            $This.Caption     = $This.Module.OS.Caption
            $This.Platform    = $This.Module.OS.Platform
            $This.PSVersion   = $This.Module.OS.PSVersion
            $This.Type        = $This.Module.OS.Type
            $This.Control     = [Control]::New()
        }
        GetServices()
        {
            $This.Service    = [ServiceControl]::New()
        }
        StageXamlEvent()
        {
            # [Provide alternate variable for event handlers]
            $Ctrl            = $This

            ######################## First Tab #############################
            # [Module OS items]
            $Ctrl.Xaml.IO.OS.Items.Clear()
            [Void]$Ctrl.Xaml.IO.OS.Items.Add($Ctrl.Module.OS)

            # [Bios Information]
            $Ctrl.Xaml.IO.BiosInformation.Items.Clear()
            [Void]$Ctrl.Xaml.IO.BiosInformation.Items.Add($Ctrl.System.BiosInformation)

            # [Bios Information Extension]
            $Ctrl.Xaml.IO.BiosInformationExtension.Items.Clear()
            ForEach ($Property in "SmBiosPresent","SmBiosVersion","SmBiosMajor","SmBiosMinor","SystemBiosMajor","SystemBiosMinor")
            {
                $Item = [PSNoteProperty]::New($Property,$Ctrl.System.BiosInformation.$Property)
                [Void]$Ctrl.Xaml.IO.BiosInformationExtension.Items.Add($Item)
            }

            # [Operating System]
            $Ctrl.Xaml.IO.OperatingSystem.Items.Clear()
            [Void]$Ctrl.Xaml.IO.OperatingSystem.Items.Add($Ctrl.System.OperatingSystem)

            # [Computer System]
            $Ctrl.Xaml.IO.ComputerSystem.Items.Clear()
            [Void]$Ctrl.Xaml.IO.ComputerSystem.Items.Add($Ctrl.System.ComputerSystem)

            # [Computer System Extension]
            $Ctrl.Xaml.IO.ComputerSystemExtension.Items.Clear()
            ForEach ($Property in "UUID","Chassis","BiosUefi","AssetTag")
            {
                $Item = [PSNoteProperty]::New($Property,$Ctrl.System.ComputerSystem.$Property)
                [Void]$Ctrl.Xaml.IO.ComputerSystemExtension.Items.Add($Item)
            }

            # [Processor]
            $Ctrl.Xaml.IO.Processor.Items.Clear()
            ForEach ($Item in $Ctrl.System.Processor.Output)
            {
                [Void]$Ctrl.Xaml.IO.Processor.Items.Add($Item)
            }

            # [Processor Event Trigger(s)]
            $Ctrl.Xaml.IO.Processor.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Processor.SelectedIndex
                If ($Index -ne -1)
                {
                    $Ctrl.Xaml.IO.ProcessorExtension.Items.Clear()
                    ForEach ($Property in "ProcessorId","DeviceId","Speed","Cores","Used","Logical","Threads")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Ctrl.System.Processor.Output[$Index].$Property)
                        [Void]$Ctrl.Xaml.IO.ProcessorExtension.Items.Add($Item)
                    }
                }
            })

            # [Disk]
            $Ctrl.Xaml.IO.Disk.Items.Clear()
            ForEach ($Item in $Ctrl.System.Disk.Output)
            {
                [Void]$Ctrl.Xaml.IO.Disk.Items.Add($Item)
            }

            # [Disk Event Trigger(s)]
            $Ctrl.Xaml.IO.Disk.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Disk.SelectedIndex
                If ($Index -ne -1)
                {
                    # [Disk Extension]
                    $Ctrl.Xaml.IO.DiskExtension.Items.Clear()
                    ForEach ($Property in "HealthStatus","BusType","UniqueId","Location")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Ctrl.System.Disk.Output[$Index].$Property)
                        [Void]$Ctrl.Xaml.IO.DiskExtension.Items.Add($Item)
                    }
                    # [Disk Partition(s)]
                    $Ctrl.Xaml.IO.DiskPartition.Items.Clear()
                    ForEach ($Item in $Ctrl.System.Disk.Output[$Index].Partition.Output)
                    {
                        [Void]$Ctrl.Xaml.IO.DiskPartition.Items.Add($Item)
                    }
                    
                    # [Disk Volume(s)]
                    $Ctrl.Xaml.IO.DiskVolume.Items.Clear()
                    ForEach ($Item in $Ctrl.System.Disk.Output[$Index].Volume.Output)
                    {
                        [Void]$Ctrl.Xaml.IO.DiskVolume.Items.Add($Item)
                    }
                }
            })

            # [Network]
            $Ctrl.Xaml.IO.Network.Items.Clear()
            ForEach ($Item in $Ctrl.System.Network.Output)
            {
                [Void]$Ctrl.Xaml.IO.Network.Items.Add($Item)
            }

            # [Network Event Trigger(s)]
            $Ctrl.Xaml.IO.Network.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Network.SelectedIndex
                If ($Index -ne -1)
                {
                    $Ctrl.Xaml.IO.NetworkExtension.Items.Clear()
                    ForEach ($Property in "IPAddress","SubnetMask","Gateway","DnsServer","DhcpServer","MacAddress")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Ctrl.System.Network.Output[$Index].$Property)
                        [Void]$Ctrl.Xaml.IO.NetworkExtension.Items.Add($Item)
                    }
                }
            })

            ######################## Second Tab #############################
            $Ctrl.Xaml.IO.ServiceGet.Add_Click(
            {
                $Ctrl.GetServices()
                $Ctrl.Xaml.IO.Service.Items.Clear()
                ForEach ($Item in $Ctrl.Service.Output)
                {
                    $Ctrl.Xaml.IO.Service.Items.Add($Item)
                }
            })

            $Ctrl.Xaml.IO.Service.Add_SelectionChanged(
            {
                $Slot = $Ctrl.Xaml.IO.Service.SelectedItem
                If ($Slot.Index -ne -1)
                {
                    $Ctrl.Xaml.IO.ServiceExtension.Items.Clear()
                    ForEach ($Property in "Name","DisplayName","PathName","Description")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Slot.$Property)
                        $Ctrl.Xaml.IO.ServiceExtension.Items.Add($Item)
                    }
                }        
            })

            $Ctrl.Xaml.IO.ServiceFilter.Add_TextChanged(
            {
                Start-Sleep -Milliseconds 50
                $Property  = $Ctrl.Xaml.IO.ServiceProperty.SelectedItem.Content
                $Text      = $Ctrl.Xaml.IO.ServiceFilter.Text
                $Ctrl.Xaml.IO.Service.Items.Clear()
                If ($Text -ne "")
                {
                    ForEach ($Item in $Ctrl.Service.Output | ? $Property -match $Text)
                    {
                        $Ctrl.Xaml.IO.Service.Items.Add($Item)
                    }
                }
                Else
                {
                    ForEach ($Item in $Ctrl.Service.Output)
                    {
                        $Ctrl.Xaml.IO.Service.Items.Add($Item)
                    }
                }
            })

            ################# Third Tab #########################
            # [Privacy]
            $Ctrl.Xaml.IO.ControlPrivacy.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Privacy)
            {
                $Ctrl.Xaml.IO.ControlPrivacy.Items.Add($Item)
            }

            #[Windows Update]
            $Ctrl.Xaml.IO.ControlWindowsUpdate.Items.Clear()
            ForEach ($Item in $Ctrl.Control.WindowsUpdate)
            {
                $Ctrl.Xaml.IO.ControlWindowsUpdate.Items.Add($Item)
            }

            #[Service]
            $Ctrl.Xaml.IO.ControlService.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Service)
            {
                $Ctrl.Xaml.IO.ControlService.Items.Add($Item)
            }

            #[Context]
            $Ctrl.Xaml.IO.ControlContext.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Context)
            {
                $Ctrl.Xaml.IO.ControlContext.Items.Add($Item)
            }

            #[Taskbar]
            $Ctrl.Xaml.IO.ControlTaskbar.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Taskbar)
            {
                $Ctrl.Xaml.IO.ControlTaskbar.Items.Add($Item)
            }

            #[Explorer]
            $Ctrl.Xaml.IO.ControlExplorer.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Explorer)
            {
                $Ctrl.Xaml.IO.ControlExplorer.Items.Add($Item)
            }

            #[StartMenu]
            $Ctrl.Xaml.IO.ControlStartMenu.Items.Clear()
            ForEach ($Item in $Ctrl.Control.StartMenu)
            {
                $Ctrl.Xaml.IO.ControlStartMenu.Items.Add($Item)
            }

            #[ThisPC]
            $Ctrl.Xaml.IO.ControlThisPC.Items.Clear()
            ForEach ($Item in $Ctrl.Control.ThisPC)
            {
                $Ctrl.Xaml.IO.ControlThisPC.Items.Add($Item)
            }

            #[Desktop]
            $Ctrl.Xaml.IO.ControlDesktop.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Desktop)
            {
                $Ctrl.Xaml.IO.ControlDesktop.Items.Add($Item)
            }

            #[LockScreen]
            $Ctrl.Xaml.IO.ControlLockScreen.Items.Clear()
            ForEach ($Item in $Ctrl.Control.LockScreen)
            {
                $Ctrl.Xaml.IO.ControlLockScreen.Items.Add($Item)
            }

            #[Miscellaneous]
            $Ctrl.Xaml.IO.ControlMiscellaneous.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Miscellaneous)
            {
                $Ctrl.Xaml.IO.ControlMiscellaneous.Items.Add($Item)
            }

            #[PhotoViewer]
            $Ctrl.Xaml.IO.ControlPhotoViewer.Items.Clear()
            ForEach ($Item in $Ctrl.Control.PhotoViewer)
            {
                $Ctrl.Xaml.IO.ControlPhotoViewer.Items.Add($Item)
            }

            #[WindowsStore]
            $Ctrl.Xaml.IO.ControlWindowsStore.Items.Clear()
            ForEach ($Item in $Ctrl.Control.WindowsStore)
            {
                $Ctrl.Xaml.IO.ControlWindowsStore.Items.Add($Item)
            }

            #[AppX]
            $Ctrl.Xaml.IO.ControlAppX.Items.Clear()
            ForEach ($Item in $Ctrl.Control.AppX)
            {
                $Ctrl.Xaml.IO.ControlAppX.Items.Add($Item)
            }
        }
    }

    $Ctrl = [ViperBombController]::New()
    $Ctrl.StageXamlEvent()
    $Ctrl.Xaml.Invoke()
}
