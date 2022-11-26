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
   \\        Modified   : 2022-11-25                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : AKA "System Control Extension Utility"                                                   //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-25-2022 19:16:56    ]______________________________________________________________________//¯¯¯        
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
        '                            <DataGrid Grid.Row="1" Grid.Column="0" Name="Service" RowHeaderWidth="0"',
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
        '                <TabControl>',
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
        '                    <TabItem Header="Settings">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Content="[System Control Settings]:"/>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="60"/>',
        '                                    <ColumnDefinition Width="130"/>',
        '                                    <ColumnDefinition Width="10"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="[Slot]:"/>',
        '                                <ComboBox Grid.Column="1" Name="ControlSlot" SelectedIndex="0">',
        '                                    <ComboBoxItem Content="All"/>',
        '                                    <ComboBoxItem Content="Privacy"/>',
        '                                    <ComboBoxItem Content="WindowsUpdate"/>',
        '                                    <ComboBoxItem Content="Service"/>',
        '                                    <ComboBoxItem Content="Context"/>',
        '                                    <ComboBoxItem Content="Taskbar"/>',
        '                                    <ComboBoxItem Content="StartMenu"/>',
        '                                    <ComboBoxItem Content="Explorer"/>',
        '                                    <ComboBoxItem Content="ThisPC"/>',
        '                                    <ComboBoxItem Content="Desktop"/>',
        '                                    <ComboBoxItem Content="LockScreen"/>',
        '                                    <ComboBoxItem Content="Miscellaneous"/>',
        '                                    <ComboBoxItem Content="PhotoViewer"/>',
        '                                    <ComboBoxItem Content="WindowsApps"/>',
        '                                </ComboBox>',
        '                                <Border Grid.Column="2" Margin="4" Background="Black"/>',
        '                                <ComboBox Grid.Column="3" Name="ControlProperty" SelectedIndex="0">',
        '                                    <ComboBoxItem Content="Name"/>',
        '                                    <ComboBoxItem Content="Description"/>',
        '                                </ComboBox>',
        '                                <TextBox Grid.Column="4" Name="ControlFilter"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="2" Name="ControlOutput">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding DisplayName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="Value" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" ItemsSource="{Binding Options}" Style="{StaticResource DGCombo}"/>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="*" Binding="{Binding Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <DataGrid Grid.Row="3" Name="ControlOutputExtension" HeadersVisibility="None" RowHeaderWidth="0">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="4">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="ControlOutputApply" Content="Apply" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="ControlOutputDontApply" Content="Do not apply..." IsEnabled="False"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Features">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Content="[Windows Features]:"/>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <ComboBox Grid.Column="0" Name="ControlFeatureProperty" SelectedIndex="0">',
        '                                    <ComboBoxItem Content="FeatureName"/>',
        '                                    <ComboBoxItem Content="State"/>',
        '                                </ComboBox>',
        '                                <TextBox Grid.Column="1" Name="ControlFeatureFilter"/>',
        '                            </Grid>',
        '                            <DataGrid Name="ControlFeature" Grid.Row="2">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Width="200" Binding="{Binding FeatureName}" IsReadOnly="True"/>',
        '                                    <DataGridTemplateColumn Header="State" Width="150">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding State.Index}" Style="{StaticResource DGCombo}">',
        '                                                    <ComboBoxItem Content="Disabled"/>',
        '                                                    <ComboBoxItem Content="DisabledWithPayloadRemoved"/>',
        '                                                    <ComboBoxItem Content="Enabled"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Description" Width="*" Binding="{Binding State.Description}" IsReadOnly="True"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <DataGrid Grid.Row="3" Name="ControlFeatureExtension" HeadersVisibility="None" RowHeaderWidth="0">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="4">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="ControlFeatureApply" Content="Apply" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="ControlFeatureDontApply" Content="Do not apply..." IsEnabled="False"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="AppX">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[AppX Catalog]"/>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <ComboBox Grid.Column="0" Name="ControlAppXProperty" SelectedIndex="0">',
        '                                    <ComboBoxItem Content="PackageName"/>',
        '                                    <ComboBoxItem Content="DisplayName"/>',
        '                                    <ComboBoxItem Content="PublisherID"/>',
        '                                    <ComboBoxItem Content="InstallLocation"/>',
        '                                </ComboBox>',
        '                                <TextBox Grid.Column="1" Name="ControlAppXFilter"/>',
        '                            </Grid>',
        '                            <DataGrid Name="ControlAppX" Grid.Row="2">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="#"        Binding="{Binding Index}"        Width="25"/>',
        '                                    <DataGridTemplateColumn Header="Profile" Width="45">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Profile}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="False"/>',
        '                                                    <ComboBoxItem Content="True"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="DisplayName"  Binding="{Binding DisplayName}" Width="2*"/>',
        '                                    <DataGridTextColumn Header="PublisherID"  Binding="{Binding PublisherID}" Width="*"/>',
        '                                    <DataGridTextColumn Header="Version"      Binding="{Binding Version}"     Width="100"/>',
        '                                    <DataGridTemplateColumn Header="Slot" Width="60">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Slot}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
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
        '                            <DataGrid Grid.Row="3" Name="ControlAppXExtension" HeadersVisibility="None" RowHeaderWidth="0">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="4">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="ControlAppXApply" Content="Apply" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="ControlAppXDontApply" Content="Do not apply..." IsEnabled="False"/>',
        '                            </Grid>',
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
    
    Class ControlTemplate
    {
        [String]      $Source
        [String]        $Name
        [String] $DisplayName
        [UInt32]       $Value
        [String] $Description
        [String[]]   $Options
        [Object]      $Output
        ControlTemplate()
        {
            $This.Output  = @( )
        }
        Registry([String]$Path,[String]$Name)
        {
            $This.Output += [Registry]::New($Path,$Name)
        }
        [UInt32] GetWinVersion()
        {
            Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
        }
    }
    
    Class Telemetry : ControlTemplate
    {
        Telemetry() : base()
        {
            $This.Name        = "Telemetry"
            $This.DisplayName = "Telemetry"
            $This.Value       = 1
            $This.Description = "Various location and tracking features"
            $This.Options     = "Skip", "Enable*", "Disable"
    
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
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    If ([Environment]::Is64BitProcess)
                    {
                        $This.Output[2].Set(0)
                    }
                    3..10 | % { $This.Output[$_].Remove() }
                    $This.TelemetryTask() | % { Enable-ScheduledTask -TaskName $_ }
                }
                2
                {
                    Write-Host "Disabling [~] Telemetry"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    If ([Environment]::Is64BitProcess)
                    {
                        $This.Output[2].Set(0)
                    }
                    $This.Ouptut[ 3].Set(0)
                    $This.Ouptut[ 4].Set(1)
                    $This.Ouptut[ 5].Set(0)
                    $This.Ouptut[ 6].Set(0)
                    $This.Ouptut[ 7].Set(1)
                    $This.Ouptut[ 8].Set(0)
                    $This.Ouptut[ 9].Set(1)
                    $This.Ouptut[10].Set(0)
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
    
    Class WiFiSense : ControlTemplate
    {
        WiFiSense()
        {
            $This.Name        = "WifiSense"
            $This.DisplayName = "Wi-Fi Sense"
            $This.Value       = 1
            $This.Description = "Lets devices more easily connect to a WiFi network"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting','Value'),
            ('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowConnectToWiFiSenseHotspots','Value'),
            ('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','AutoConnectAllowedOEM'),
            ('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','WiFiSenseAllowed') | % {
                 
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [-] Wi-Fi Sense"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Wi-Fi Sense"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                    $This.Output[3].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] Wi-Fi Sense"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    $This.Output[2].Remove()
                    $This.Output[3].Remove()
                }
            }
        }
    }
    
    Class SmartScreen : ControlTemplate
    {
        SmartScreen()
        {
            $This.Name        = "SmartScreen"
            $This.DisplayName = "SmartScreen"
            $This.Value       = 1
            $This.Description = "Cloud-based anti-phishing and anti-malware component"
            $This.Options     = "Skip","Enable*","Disable"
    
            $Path             = Switch ($This.GetWinVersion() -ge 1703)
            { 
                $False { $Null } $True { Get-AppxPackage | ? Name -eq Microsoft.MicrosoftEdge | % PackageFamilyName }
            }
    
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","SmartScreenEnabled"),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost","EnableWebContentEvaluation"),
            ("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","EnabledV9"),
            ("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","PreventOverride") | % {
            
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [-] SmartScreen Filter"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] SmartScreen Filter"
                    $This.Output[0].Set("String","RequireAdmin")
                    1..3 | % { $This.Output[$_].Remove() }
                }
                2
                {
                    Write-Host "Disabling [~] SmartScreen Filter"
                    $This.Output[0].Set("String","Off")
                    1..3 | % { $This.Output[$_].Set(0) }
                }
            }
        }
    }
    
    Class LocationTracking : ControlTemplate
    {
        LocationTracking()
        {
            $This.Name        = "LocationTracking"
            $This.DisplayName = "Location Tracking"
            $This.Value       = 1
            $This.Description = "Monitors the current location of the system and manages geofences"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}','SensorPermissionState'),
            ('HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration','Status') | % {
            
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Location Tracking"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Location Tracking"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Location Tracking"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Feedback : ControlTemplate
    {
        Feedback()
        {
            $This.Name        = "Feedback"
            $This.DisplayName = "Feedback"
            $This.Value       = 1
            $This.Description = "System Initiated User Feedback"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ('HKCU:\SOFTWARE\Microsoft\Siuf\Rules','NumberOfSIUFInPeriod'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','DoNotShowFeedbackNotifications') | % {
        
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Feedback"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Feedback"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    "Microsoft\Windows\Feedback\Siuf\DmClient" | % { $_,"$_`OnScenarioDownload" } | % { Enable-ScheduledTask -TaskName $_ | Out-Null }
                }
                2
                {
                    Write-Host "Disabling [~] Feedback"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    "Microsoft\Windows\Feedback\Siuf\DmClient" | % { $_,"$_`OnScenarioDownload" } | % { Disable-ScheduledTask -TaskName $_ | Out-Null }
                }
            }
        }
    }
    
    Class AdvertisingID : ControlTemplate
    {
        AdvertisingID()
        {
            $This.Name        = "AdvertisingID"
            $This.DisplayName = "Advertising ID"
            $This.Value       = 1
            $This.Description = "Allows Microsoft to display targeted ads"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo','Enabled'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy','TailoredExperiencesWithDiagnosticDataEnabled') | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Advertising ID"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Advertising ID"
                    $This.Output[0].Remove()
                    $This.Output[1].Set(2)
                }
                2
                {
                    Write-Host "Disabling [~] Advertising ID"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Cortana : ControlTemplate
    {
        Cortana()
        {
            $This.Name        = "Cortana"
            $This.DisplayName = "Cortana"
            $This.Value       = 1
            $This.Description = "(Master Chief/Microsoft)'s personal voice assistant"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKCU:\SOFTWARE\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy"),
            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts"),
            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection"),
            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortanaAboveLock"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchPrivacy"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch"),
            ("HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Preferences","VoiceActivationEnableAboveLockscreen"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization","AllowInputPersonalization"),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Cortana"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Cortana"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Set(0)
                    $This.Output[3].Set(0)
                    $This.Output[4].Remove()
                    $This.Output[5].Remove()
                    $This.Output[6].Remove()
                    $This.Output[7].Set(1)
                    $This.Output[8].Remove()
                    $This.Output[9].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] Cortana"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(1)
                    $This.Output[3].Set(0)
                    $This.Output[4].Set(0)
                    $This.Output[5].Set(1)
                    $This.Output[6].Set(3)
                    $This.Output[7].Set(0)
                    $This.Output[8].Set(0)
                    $This.Output[9].Set(1)
                }
            }
        }
    }
    
    Class CortanaSearch : ControlTemplate
    {
        CortanaSearch()
        {
            $This.Name        = "CortanaSearch"
            $This.DisplayName = "Cortana Search"
            $This.Value       = 1
            $This.Description = "Allows Cortana to create search indexing for faster system search results"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Cortana Search"
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class ErrorReporting : ControlTemplate
    {
        ErrorReporting()
        {
            $This.Name        = "ErrorReporting"
            $This.DisplayName = "Error Reporting"
            $This.Value       = 1
            $This.Description = "If Windows has an issue, it sends Microsoft a detailed report"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            $This.Registry("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting","Disabled")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Error Reporting"
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class AutoLoggerFile : ControlTemplate
    {
        AutoLoggerFile()
        {
            $This.Name        = "AutoLoggerFile"
            $This.DisplayName = "Automatic Logger File"
            $This.Value       = 1
            $This.Description = "This feature lets you trace the actions of a trace provider while Windows is booting"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener","Start"),
            ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}","Start") | % {
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] AutoLogger"
                    }
                }
                1
                {
                    Write-Host "Unrestricting [~] AutoLogger"
                    icacls $Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger /grant:r SYSTEM:`(OI`)`(CI`)F
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Removing [~] AutoLogger, and restricting directory"
                    icacls $Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger /deny SYSTEM:`(OI`)`(CI`)F
                    Remove-Item $Env:ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl -EA 0 -Verbose
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class DiagTrack : ControlTemplate
    {
        DiagTrack()
        {
            $This.Name        = "DiagTracking"
            $This.DisplayName = "Diagnostics Tracking"
            $This.Value       = 1
            $This.Description = "Connected User Experiences and Telemetry"
            $This.Options     = "Skip", "Enable*", "Disable"
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
    
    Class WAPPush : ControlTemplate
    {
        WAPPush()
        {
            $This.Name        = "WAPPush"
            $This.DisplayName = "WAP Push"
            $This.Value       = 1
            $This.Description = "Device Management Wireless Application Protocol"
            $This.Options     = "Skip", "Enable*", "Disable"
            $This.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart")
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
                    $This.Output[0].Set(1)
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
    
    Enum PrivacyType
    {
        Telemetry
        WifiSense
        SmartScreen
        LocationTracking
        Feedback
        AdvertisingID
        Cortana
        CortanaSearch
        ErrorReporting
        AutologgerFile
        DiagTrack
        WAPPush
    }
    
    Class PrivacyList
    {
        [Object]  $Output
        PrivacyList()
        {
            $This.Output      = @( )
            ForEach ($Name in [System.Enum]::GetNames([PrivacyType]))
            {
                $Item         = Switch ($Name)
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
                $Item.Source  = "Privacy"
                $This.Output += $Item
            }
        }
    }
    
    Class UpdateMSProducts : ControlTemplate
    {
        UpdateMSProducts()
        {
            $This.Name        = "UpdateMSProducts"
            $This.DisplayName = "Update MS Products"
            $This.Value       = 2
            $This.Description = "Searches Windows Update for Microsoft Products"
            $This.Options     = "Skip", "Enable", "Disable*"
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
    
    Class CheckForWindowsUpdate : ControlTemplate
    {
            CheckForWindowsUpdate()
            {
                $This.Name        = "CheckForWindowsUpdate"
                $This.DisplayName = "Check for Windows Updates"
                $This.Value       = 1
                $This.Description = "Allows Windows Update to work automatically"
                $This.Options     = "Skip", "Enable*", "Disable"
    
                $This.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","SetDisableUXWUAccess")
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
                        $This.Output[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Check for Windows Updates"
                        $This.Output[0].Set(1)
                    }
                }
            }
    }
    
    Class WinUpdateType : ControlTemplate
    {
        WinUpdateType()
        {
            $This.Name        = "WinUpdateType"
            $This.DisplayName = "Windows Update Type"
            $This.Value       = 3
            $This.Description = "Allows Windows Update to work automatically"
            $This.Options     = "Skip", "Notify", "Auto DL", "Auto DL+Install*", "Manual"
    
            $This.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions")
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
                    $This.Output[0].Set(2)
                }
                2
                {
                    Write-Host "Enabling [~] Automatically download Windows Updates, notify to install"
                    $This.Output[0].Set(3)
                }
                3
                {
                    Write-Host "Enabling [~] Automatically download Windows Updates, schedule to install"
                    $This.Output[0].Set(4)
                }
                4
                {
                    Write-Host "Enabling [~] Allow local administrator to choose automatic updates"
                    $This.Output[0].Set(5)
                }
            }
        }
    }
    
    Class WinUpdateDownload : ControlTemplate
    {
        WinUpdateDownload()
        {
            $This.Name        = "WinUpdateDownload"
            $This.DisplayName = "Windows Update Download"
            $This.Value       = 1
            $This.Description = "Selects a source from which to pull Windows Updates"
            $This.Options     = "Skip", "P2P*", "Local Only", "Disable"
    
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","DODownloadMode"),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","SystemSettingsDownloadMode"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization","SystemSettingsDownloadMode"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","DODownloadMode") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] "
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Unrestricting Windows Update P2P to Internet"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    Write-Host "Enabling [~] Restricting Windows Update P2P only to local network"
                    $This.Output[1].Set(3)
                    Switch($This.GetWinVersion())
                    {
                        1507
                        {
                            $This.Output[0]
                        }
                        {$_ -gt 1507 -and $_ -le 1607}
                        {
                            $This.Output[0].Set(1)
                        }
                        Default
                        {
                            $This.Output[0].Remove()
                        }
                    }
                }
                3
                {
                    Write-Host "Disabling [~] Windows Update P2P"
                    $This.Output[1].Set(3)
                    Switch ($This.GetWinVersion())
                    {
                        1507
                        {
                            $This.Output[0].Set(0)
                        }
                        Default
                        {
                            $This.Output[3].Set(100)
                        }
                    }
                }
            }
        }
    }
    
    Class UpdateMSRT : ControlTemplate
    {
        UpdateMSRT()
        {
            $This.Name        = "UpdateMSRT"
            $This.DisplayName = "Update MSRT"
            $This.Value       = 1
            $This.Description = "Allows updates for the Malware Software Removal Tool"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry("HKLM:\SOFTWARE\Policies\Microsoft\MRT","DontOfferThroughWUAU")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Malicious Software Removal Tool Update"
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class UpdateDriver : ControlTemplate
    {
        UpdateDriver()
        {
            $This.Name        = "UpdateDriver"
            $This.DisplayName = "Update Driver"
            $This.Value       = 1
            $This.Description = "Allows drivers to be downloaded from Windows Update"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching","SearchOrderConfig"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","ExcludeWUDriversInQualityUpdate"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata","PreventDeviceMetadataFromNetwork") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Driver update through Windows Update"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Driver update through Windows Update"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Driver update through Windows Update"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(1)
                }
            }
        }
    }
    
    Class RestartOnUpdate : ControlTemplate
    {
        RestartOnUpdate()
        {
            $This.Name        = "RestartOnUpdate"
            $This.DisplayName = "Restart on Update"
            $This.Value       = 1
            $This.Description = "Reboots the machine when an update is installed and requires it"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings","UxOption"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","NoAutoRebootWithLoggOnUsers"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUPowerManagement") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Windows Update Automatic Restart"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Windows Update Automatic Restart"
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Windows Update Automatic Restart"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                }
            }
        }
    }
    
    Class AppAutoDownload : ControlTemplate
    {
        AppAutoDownload()
        {
            $This.Name        = "AppAutoDownload"
            $This.DisplayName = "Consumer App Auto Download"
            $This.Value       = 1
            $This.Description = "Provisioned Windows Store applications are downloaded"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate","AutoDownload"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsConsumerFeatures") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] App Auto Download"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] App Auto Download"
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] App Auto Download"
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
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
    }
    
    Class UpdateAvailablePopup : ControlTemplate
    {
        UpdateAvailablePopup()
        {
            $This.Name        = "UpdateAvailablePopup"
            $This.DisplayName = "Update Available Pop-up"
            $This.Value       = 1
            $This.Description = "If an update is available, a (pop-up/notification) will appear"
            $This.Options     = "Skip", "Enable*", "Disable"
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
    
    Enum WindowsUpdateType
    {
        UpdateMSProducts
        CheckForWindowsUpdate
        WinUpdateType
        WinUpdateDownload
        UpdateMSRT
        UpdateDriverRestartOnUpdate
        AppAutoDownload
        UpdateAvailablePopup
    }
    
    Class WindowsUpdateList
    {
        [Object]  $Output
        WindowsUpdateList()
        {
            $This.Output     = @( ) 
            ForEach ($Name in [System.Enum]::GetNames([WindowsUpdateType]))
            {
                $Name
                $Item        = Switch ($Name)
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
                $This.Output += $Item
            }

            $This.Output | % { $_.Source = "WindowsUpdate" }
        }
    }
    
    Class UAC : ControlTemplate
    {
        UAC()
        {
            $This.Name        = "UAC"
            $This.DisplayName = "User Access Control"
            $This.Value       = 2
            $This.Description = "Sets restrictions/permissions for programs"
            $This.Options     = "Skip", "Lower", "Normal*", "Higher"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","ConsentPromptBehaviorAdmin"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop") | % { 
            
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] UAC Level"
                    }
                }
                1
                {
                    Write-Host "Setting [~] UAC Level (Low)"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set
                }
                2
                {
                    Write-Host "Setting [~] UAC Level (Default)"
                    $This.Output[0].Set(5)
                    $This.Output[1].Set(1)
                }
                3
                {
                    Write-Host "Setting [~] UAC Level (High)"
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
    
    Class SharingMappedDrives : ControlTemplate
    {
        SharingMappedDrives()
        {
            $This.Name        = "SharingMappedDrives"
            $This.DisplayName = "Share Mapped Drives"
            $This.Value       = 2
            $This.Description = "Shares any mapped drives to all users on the machine"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            $This.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLinkedConnections")
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Sharing mapped drives between users"
                    $This.Output[0].Remove()
                }
            }
        }
    }
    
    Class AdminShares : ControlTemplate
    {
        AdminShares()
        {
            $This.Name        = "AdminShares"
            $This.DisplayName = "Administrative File Shares"
            $This.Value       = 1
            $This.Description = "Reveals default system administration file shares"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            $This.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters","AutoShareWks")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Hidden administrative shares"
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class Firewall : ControlTemplate
    {
        Firewall()
        {
            $This.Name        = "Firewall"
            $This.DisplayName = "Firewall"
            $This.Value       = 1
            $This.Description = "Enables the default firewall profile"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile','EnableFirewall')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Firewall Profile"
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class WinDefender : ControlTemplate
    {
        WinDefender()
        {
            $This.Name        = "WinDefender"
            $This.DisplayName = "Windows Defender"
            $This.Value       = 1
            $This.Description = "Toggles Windows Defender, system default anti-virus/malware utility"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender","DisableAntiSpyware"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","WindowsDefender"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","SecurityHealth"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SpynetReporting"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SubmitSamplesConsent") | % {
    
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Windows Defender"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Windows Defender"
                    $This.Output[0].Remove()
                    Switch ($This.GetWinVersion())
                    {
                        {$_ -lt 1703}
                        {
                            $This.Output[1].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")
                        }
                        Default
                        {
                            $This.Output[2].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")     
                        }
                    }
                    $This.Output[3].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Windows Defender"
                    Switch ($This.GetWinVersion())
                    {
                        {$_ -lt 1703}
                        {
                            $This.Output[1].Remove()
                        }
                        Default
                        {
                            $This.Output[2].Remove()    
                        }
                    }
                    $This.Output[0].Set(1)
                    $This.Output[4].Set(0)
                    $This.Output[5].Set(2)
                }
            }
        }
    }
    
    Class HomeGroups : ControlTemplate
    {
        HomeGroups()
        {
            $This.Name        = "HomeGroups"
            $This.DisplayName = "Home Groups"
            $This.Value       = 1
            $This.Description = "Toggles the use of home groups, essentially a home-based workgroup"
            $This.Options     = "Skip", "Enable*", "Disable"
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
    
    Class RemoteAssistance : ControlTemplate
    {
        RemoteAssistance()
        {
            $This.Name        = "RemoteAssistance"
            $This.DisplayName = "Remote Assistance"
            $This.Value       = 1
            $This.Description = "Toggles the ability to use Remote Assistance"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp")
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Remote Assistance"
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class RemoteDesktop : ControlTemplate
    {
        RemoteDesktop()
        {
            $This.Name        = "RemoteDesktop"
            $This.DisplayName = "Remote Desktop"
            $This.Value       = 2
            $This.Description = "Toggles the ability to use Remote Desktop"
            $This.Options     = "Skip", "Enable", "Disable*"
    
            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server","fDenyTSConnections"),
            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp","UserAuthentication") | % {
            
                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Remote Desktop"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Remote Desktop"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] Remote Desktop"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
    
    Enum ServiceType
    {
        UAC
        SharingMappedDrives
        AdminShares
        Firewall
        WinDefender
        HomeGroups
        RemoteAssistance
        RemoteDesktop
    }
    
    Class ServiceList
    {
        [Object]  $Output
        ServiceList()
        {
            $This.Output     = @( )
            ForEach ($Name in [System.Enum]::GetNames([ServiceType]))
            {
                $Item        = Switch ($Name)
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
                $Item.Source  = "Service"
                $This.Output += $Item
            }
        }
    }

    Class CastToDevice : ControlTemplate
    {
        CastToDevice()
        {
            $This.Name        = "CastToDevice"
            $This.DisplayName = "Cast To Device"
            $This.Value       = 1
            $This.Description = "Adds a context menu item for casting to a device"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked","{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] 'Cast to device' context menu item"
                    $This.Output[0].Set("String","Play to Menu")
                }
            }
        }
    }

    Class PreviousVersions : ControlTemplate
    {
        PreviousVersions()
        {
            $This.Name        = "PreviousVersions"
            $This.DisplayName = "Previous Versions"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to select a previous version of a file"
            $This.Options     = "Skip", "Enable*", "Disable"

            ("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"),
            ("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"),
            ("HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"),
            ("HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] 'Previous versions' context menu item"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] 'Previous versions' context menu item"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Get()
                }
                2
                {
                    Write-Host "Disabling [~] 'Previous versions' context menu item"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                    $This.Output[3].Remove()
                }
            }
        }
    }

    Class IncludeInLibrary : ControlTemplate
    {
        IncludeInLibrary()
        {
            $This.Name        = "IncludeInLibrary"
            $This.DisplayName = "Include in Library"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to include a selection in library items"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry("HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location","(Default)")
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
                    $This.Output[0].Set("String","{3dad6c5d-2167-4cae-9914-f99e41c12cfa}")
                }
                2
                {
                    Write-Host "Disabling [~] 'Include in Library' context menu item"
                    $This.Output[0].Set("String","")
                }
            }
        }
    }

    Class PinToStart : ControlTemplate
    {
        PinToStart()
        {
            $This.Name        = "PinToStart"
            $This.DisplayName = "Pin to Start"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to pin an item to the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}','(Default)'),
            ('HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}','(Default)'),
            ('HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen','(Default)'),
            ('HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)'),
            ('HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen','(Default)'),
            ('HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] 'Pin to Start' context menu item"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] 'Pin to Start' context menu item"
                    $This.Output[0].Set("String","Taskband Pin")
                    $This.Output[1].Set("String","Start Menu Pin")
                    $This.Output[2].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[3].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[4].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[5].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                }
                2
                {
                    Write-Host "Disabling [~] 'Pin to Start' context menu item"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Set("String","")
                    $This.Output[3].Set("String","")
                    $This.Output[4].Set("String","")
                    $This.Output[5].Set("String","")
                }
            }
        }
    }

    Class PinToQuickAccess : ControlTemplate
    {
        PinToQuickAccess()
        {
            $This.Name        = "PinToQuickAccess"
            $This.DisplayName = "Pin to Quick Access"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to pin an item to the Quick Access bar"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\Folder\shell\pintohome','MUIVerb'),
            ('HKCR:\Folder\shell\pintohome','AppliesTo'),
            ('HKCR:\Folder\shell\pintohome\command','DelegateExecute'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','MUIVerb'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','AppliesTo'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command','DelegateExecute') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] 'Pin to Quick Access' context menu item"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] 'Pin to Quick Access' context menu item"
                    $This.Output[0].Set("String",'@shell32.dll,-51377')
                    $This.Output[1].Set("String",'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}" AND System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}" AND System.IsFolder:=System.StructuredQueryType.Boolean#True')
                    $This.Output[2].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                    $This.Output[3].Set("String",'@shell32.dll,-51377')
                    $This.Output[4].Set("String",'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}" AND System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}" AND System.IsFolder:=System.StructuredQueryType.Boolean#True')
                    $This.Output[5].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                }
                2
                {
                    Write-Host "Disabling [~] 'Pin to Quick Access' context menu item"
                    $This.Output[0].Name = $Null
                    $This.Output[0].Remove()
                    $This.Output[3].Name = $Null
                    $This.Output[3].Remove()
                }
            }
        }
    }

    Class ShareWith : ControlTemplate
    {
        ShareWith()
        {
            $This.Name        = "PinToQuickAccess"
            $This.DisplayName = "Pin to Quick Access"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to share a file with..."
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\*\shellex\ContextMenuHandlers\Sharing','(Default)'),
            ('HKCR:\Directory\shellex\ContextMenuHandlers\Sharing','(Default)'),
            ('HKCR:\Directory\shellex\CopyHookHandlers\Sharing','(Default)'),
            ('HKCR:\Drive\shellex\ContextMenuHandlers\Sharing','(Default)'),
            ('HKCR:\Directory\shellex\PropertySheetHandlers\Sharing','(Default)'),
            ('HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing','(Default)'),
            ('HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing','(Default)'),
            ('HKCR:\*\shellex\ContextMenuHandlers\ModernSharing','(Default)') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] 'Share with' context menu item"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] 'Share with' context menu item"
                    0..7 | % { $This.Output[$_].Set("String","{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}") }
                }
                2
                {
                    Write-Host "Disabling [~] 'Share with' context menu item"
                    0..7 | % { $This.Output[$_].Set("String","") }
                }
            }
        }
    }

    Class SendTo : ControlTemplate
    {
        SendTo()
        {
            $This.Name        = "SendTo"
            $This.DisplayName = "Send To"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to send an item to..."
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo","(Default)")
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
                    $This.Output[0].Set("String","{7BA4C740-9E81-11CF-99D3-00AA004AE837}")
                }
                2
                {
                    Write-Host "Disabling [~] 'Send to' context menu item"
                    $This.Output[0].Name = $Null
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Enum ContextType
    {
        CastToDevice
        PreviousVersions
        IncludeInLibrary
        PinToStart      
        PinToQuickAccess
        ShareWith       
        SendTo
    }

    Class ContextList
    {
        [Object]  $Output
        ContextList()
        {
            $This.Output      = @( )
            ForEach ($Name in [System.Enum]::GetNames([ContextType]))
            {
                $Item         = Switch ($Name)
                {
                    CastToDevice     { [CastToDevice]::New()     }
                    PreviousVersions { [PreviousVersions]::New() }
                    IncludeInLibrary { [IncludeInLibrary]::New() }
                    PinToStart       { [PinToStart]::New()       }
                    PinToQuickAccess { [PinToQuickAccess]::New() }
                    ShareWith        { [ShareWith]::New()        }
                    SendTo           { [SendTo]::New()           }
                }
                $Item.Source  = "Context"
                $This.Output += $Item
            }
        }
    }

    Class BatteryUIBar : ControlTemplate
    {
        BatteryUIBar()
        {
            $This.Name        = "BatteryUIBar"
            $This.DisplayName = "Battery UI Bar"
            $This.Value       = 1
            $This.Description = "Toggles the battery UI bar element style"
            $This.Options     = "Skip", "New*", "Classic"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32BatteryFlyout')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Setting [~] Battery UI Bar (Old)"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class ClockUIBar : ControlTemplate
    {
        ClockUIBar()
        {
            $This.Name        = "ClockUIBar"
            $This.DisplayName = "Clock UI Bar"
            $This.Value       = 1
            $This.Description = "Toggles the clock UI bar element style"
            $This.Options     = "Skip", "New*", "Classic"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32TrayClockExperience')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Setting [~] Clock UI Bar (Old)"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class VolumeControlBar : ControlTemplate
    {
        VolumeControlBar()
        {
            $This.Name        = "VolumeControlBar"
            $This.DisplayName = "Volume Control Bar"
            $This.Value       = 1
            $This.Description = "Toggles the volume control bar element style"
            $This.Options     = "Skip", "New (X-Axis)*", "Classic (Y-Axis)"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC','EnableMtcUvc')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Volume Control Bar (Vertical)"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskBarSearchBox : ControlTemplate
    {
        TaskBarSearchBox()
        {
            $This.Name        = "TaskBarSearchBox"
            $This.DisplayName = "Taskbar Search Box"
            $This.Value       = 1
            $This.Description = "Toggles the taskbar search box element"
            $This.Options     = "Skip", "Show*", "Hide"
            
            $This.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode")
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Taskbar 'Search Box' button"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskViewButton : ControlTemplate
    {
        TaskViewButton()
        {
            $This.Name        = "VolumeControlBar"
            $This.DisplayName = "Volume Control Bar"
            $This.Value       = 1
            $This.Description = "Toggles the volume control bar element style"
            $This.Options     = "Skip", "New (X-Axis)*", "Classic (Y-Axis)"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowTaskViewButton')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Task View button"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarIconSize : ControlTemplate
    {
        TaskbarIconSize()
        {
            $This.Name        = "TaskbarIconSize"
            $This.DisplayName = "Taskbar Icon Size"
            $This.Value       = 1
            $This.Description = "Toggles the taskbar icon size"
            $This.Options     = "Skip", "Normal*", "Small"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Icon size in taskbar"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskbarGrouping : ControlTemplate
    {
        TaskbarGrouping()
        {
            $This.Name        = "TaskbarGrouping"
            $This.DisplayName = "Taskbar Grouping"
            $This.Value       = 2
            $This.Description = "Toggles the grouping of icons in the taskbar"
            $This.Options     = "Skip", "Never", "Always*","When needed"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarGlomLevel')
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
                    $This.Output[0].Set(2)
                }
                2
                {
                    Write-Host "Setting [~] Group Taskbar Items (Always)"
                    $This.Output[0].Set(0)
                }
                3
                {
                    Write-Host "Setting [~] Group Taskbar Items (When needed)"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TrayIcons : ControlTemplate
    {
        TrayIcons()
        {
            $This.Name        = "TrayIcons"
            $This.DisplayName = "Tray Icons"
            $This.Value       = 1
            $This.Description = "Toggles whether the tray icons are shown or hidden"
            $This.Options     = "Skip", "Auto*", "Always show"
            
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray'),
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Tray Icons"
                    }
                }
                1
                {
                    Write-Host "Setting [~] Tray Icons (Hiding)"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Setting [~] Tray Icons (Showing)"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class SecondsInClock : ControlTemplate
    {
        SecondsInClock()
        {
            $This.Name        = "SecondsInClock"
            $This.DisplayName = "Seconds in clock"
            $This.Value       = 1
            $This.Description = "Toggles the clock/time shows the seconds"
            $This.Options     = "Skip", "Show", "Hide*"

            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSecondsInSystemClock')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Seconds in Taskbar clock"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class LastActiveClick : ControlTemplate
    {
        LastActiveClick()
        {
            $This.Name        = "LastActiveClick"
            $This.DisplayName = "Last Active Click"
            $This.Value       = 2
            $This.Description = "Makes taskbar buttons open the last active window"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LastActiveClick')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Last active click"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarOnMultiDisplay : ControlTemplate
    {
        TaskbarOnMultiDisplay()
        {
            $This.Name        = "TaskbarOnMultiDisplay"
            $This.DisplayName = "Taskbar on multiple displays"
            $This.Value       = 1
            $This.Description = "Displays the taskbar on each display if there are multiple screens"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarEnabled')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Taskbar on Multiple Displays"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarButtonDisplay : ControlTemplate
    {
        TaskbarButtonDisplay()
        {
            $This.Name        = "TaskbarButtonDisplay"
            $This.DisplayName = "Multi-display taskbar"
            $This.Value       = 2
            $This.Description = "Defines where the taskbar button should be if there are multiple screens"
            $This.Options     = "Skip", "All", "Current Window*","Main + Current Window"

            $This.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarMode')
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
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] Taskbar buttons on multiple displays (Taskbar where window is open)"
                    $This.Output[0].Set(2)
                }
                3
                {
                    Write-Host "Setting [~] Taskbar buttons on multiple displays (Main taskbar and where window is open)"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Enum TaskbarType
    {
        BatteryUIBar
        ClockUIBar
        VolumeControlBar
        TaskbarSearchBox
        TaskViewButton
        TaskbarIconSize
        TaskbarGrouping
        TrayIconsSecondsInClock
        LastActiveClick
    }

    Class TaskbarList
    {
        [Object]   $Output
        TaskbarList()
        {
            $This.Output       = @( ) 
            ForEach ($Name in [System.Enum]::GetNames([TaskbarType]))
            {
                $Item          = Switch ($Name)
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
                $This.Output += $Item
            }
            $This.Output | % { $_.Source = "Taskbar" }
        }
    }

    Class StartMenuWebSearch : ControlTemplate
    {
        StartMenuWebSearch()
        {
            $This.Name        = "StartMenuWebSearch"
            $This.DisplayName = "Start Menu Web Search"
            $This.Value       = 1
            $This.Description = "Allows the start menu search box to search the internet"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','BingSearchEnabled'),
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','DisableWebSearch') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Bing Search in Start Menu"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Bing Search in Start Menu"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Bing Search in Start Menu"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                }
            }
        }
    }

    Class StartSuggestions : ControlTemplate
    {
        StartSuggestions()
        {
            $This.Name        = "StartSuggestions"
            $This.DisplayName = "Start Menu Suggestions"
            $This.Value       = 1
            $This.Description = "Toggles the suggested apps in the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"

            $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            ($Path,"ContentDeliveryAllowed"),
            ($Path,"OemPreInstalledAppsEnabled"),
            ($Path,"PreInstalledAppsEnabled"),
            ($Path,"PreInstalledAppsEverEnabled"),
            ($Path,"SilentInstalledAppsEnabled"),
            ($Path,"SystemPaneSuggestionsEnabled"),
            ($Path,"Start_TrackProgs"),
            ($Path,"SubscribedContent-314559Enabled"),
            ($Path,"SubscribedContent-310093Enabled"),
            ($Path,"SubscribedContent-338387Enabled"),
            ($Path,"SubscribedContent-338388Enabled"),
            ($Path,"SubscribedContent-338389Enabled"),
            ($Path,"SubscribedContent-338393Enabled"),
            ($Path,"SubscribedContent-338394Enabled"),
            ($Path,"SubscribedContent-338396Enabled"),
            ($Path,"SubscribedContent-338398Enabled") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Start Menu Suggestions"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Start Menu Suggestions"
                    0..15 | % { $This.Output[$_].Set(1) }
                }
                2
                {
                    Write-Host "Disabling [~] Start Menu Suggestions"
                    0..15 | % { $This.Output[$_].Set(0) }
                    If ($This.GetWinVersion() -ge 1803) 
                    {
                        $Key = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Key.Data[0..15]
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }

    Class MostUsedAppStartMenu : ControlTemplate
    {
        MostUsedAppStartMenu()
        {
            $This.Name        = "MostUsedAppStartMenu"
            $This.DisplayName = "Most Used Applications"
            $This.Value       = 1
            $This.Description = "Toggles the most used applications in the start menu"
            $This.Options     = "Skip", "Show*", "Hide"
            
            $This.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Start_TrackProgs')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Most used apps in Start Menu"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class RecentItemsFrequent : ControlTemplate
    {
        RecentItemsFrequent()
        {
            $This.Name        = "RecentItemsFrequent"
            $This.DisplayName = "Recent Items Frequent"
            $This.Value       = 1
            $This.Description = "Toggles the most recent frequently used (apps/items) in the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu',"Start_TrackDocs")
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Recent items and frequent places"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class UnpinItems : ControlTemplate
    {
        UnpinItems()
        {
            $This.Name        = "UnpinItems"
            $This.DisplayName = "Unpin Items"
            $This.Value       = 0
            $This.Description = "Toggles the unpin (apps/items) from the start menu"
            $This.Options     = "Skip", "Enable"
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
    }

    Enum StartMenuType
    {
        StartMenuWebSearch
        StartSuggestions
        MostUsedAppStartMenu
        RecentItemsFrequent
        UnpinItems
    }

    Class StartMenuList
    {
        [Object]  $Output
        StartMenuList()
        {
            $This.Output      = @( )
            ForEach ($Name in [System.Enum]::GetNames([StartMenuType]))
            {
                $Item         = Switch ($Name)
                {
                    StartMenuWebSearch   { [StartMenuWebSearch]::New()   }
                    StartSuggestions     { [StartSuggestions]::New()     }
                    MostUsedAppStartMenu { [MostUsedAppStartMenu]::New() }
                    RecentItemsFrequent  { [RecentItemsFrequent]::New()  }
                    UnpinItems           { [UnpinItems]::New()           }
                }
                $Item.Source  = "StartMenu"
                $This.Output += $Item
            }
        }
    }

    Class AccessKeyPrompt : ControlTemplate
    {
        AccessKeyPrompt()
        {
            $This.Name        = "AccessKeyPrompt"
            $This.DisplayName = "Access Key Prompt"
            $This.Value       = 1
            $This.Description = "Toggles the accessibility keys (menus/prompts)"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\Control Panel\Accessibility\StickyKeys',"Flags"),
            ('HKCU:\Control Panel\Accessibility\ToggleKeys',"Flags"),
            ('HKCU:\Control Panel\Accessibility\Keyboard Response',"Flags") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Accessibility keys prompts"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Accessibility keys prompts"
                    $This.Output[0].Set("String",510)
                    $This.Output[1].Set("String",62)
                    $This.Output[2].Set("String",126)
                }
                2
                {
                    Write-Host "Disabling [~] Accessibility keys prompts"
                    $This.Output[0].Set("String",506)
                    $This.Output[1].Set("String",58)
                    $This.Output[2].Set("String",122)
                }
            }
        }
    }

    Class F1HelpKey : ControlTemplate
    {
        F1HelpKey()
        {
            $This.Name        = "F1HelpKey"
            $This.DisplayName = "F1 Help Key"
            $This.Value       = 1
            $This.Description = "Toggles the F1 help menu/prompt"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0"),
            ('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32',"(Default)"),
            ('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64',"(Default)") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] F1 Help Key"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] F1 Help Key"
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] F1 Help Key"
                    $This.Output[1].Set("String","")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                    $This.Output[2].Set("String","")  
                    }
                }
            }
        }
        [UInt32] GetWinVersion()
        {
            Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
        }
    }

    Class AutoPlay : ControlTemplate
    {
        AutoPlay()
        {
            $This.Name        = "AutoPlay"
            $This.DisplayName = "AutoPlay"
            $This.Value       = 1
            $This.Description = "Toggles autoplay for inserted discs or drives"
            $This.Options     = "Skip", "Enable*", "Disable"
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
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] Autoplay"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class AutoRun : ControlTemplate
    {
        AutoRun()
        {
            $This.Name        = "AutoRun"
            $This.DisplayName = "AutoRun"
            $This.Value       = 1
            $This.Description = "Toggles autorun for programs on an inserted discs or drives"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer','NoDriveTypeAutoRun')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Autorun"
                    $This.Output[0].Set(255)
                }
            }
        }
    }

    Class PidInTitleBar : ControlTemplate
    {
        PidInTitleBar()
        {
            $This.Name        = "PidInTitleBar"
            $This.DisplayName = "Process ID"
            $This.Value       = 2
            $This.Description = "Toggles the process ID in a window title bar"
            $This.Options     = "Skip", "Show", "Hide*"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowPidInTitle')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Process ID on Title bar"
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class AeroSnap : ControlTemplate
    {
        AeroSnap()
        {
            $This.Name        = "AeroSnap"
            $This.DisplayName = "AeroSnap"
            $This.Value       = 1
            $This.Description = "Toggles the ability to snap windows to the sides of the screen"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKCU:\Control Panel\Desktop','WindowArrangementActive')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Aero Snap"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AeroShake : ControlTemplate
    {
        AeroShake()
        {
            $This.Name        = "AeroShake"
            $This.DisplayName = "AeroShake"
            $This.Value       = 1
            $This.Description = "Toggles the ability to minimize all windows by jiggling the title bar of an active window"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKCU:\Software\Policies\Microsoft\Windows\Explorer','NoWindowMinimizingShortcuts')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Aero Shake"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class KnownExtensions : ControlTemplate
    {
        KnownExtensions()
        {
            $This.Name        = "KnownExtensions"
            $This.DisplayName = "Known File Extensions"
            $This.Value       = 2
            $This.Description = "Shows known (mime-types/file extensions)"
            $This.Options     = "Skip", "Show", "Hide*"

            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','HideFileExt')
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
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] Known File Extensions"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class HiddenFiles : ControlTemplate
    {
        HiddenFiles()
        {
            $This.Name        = "HiddenFiles"
            $This.DisplayName = "Show Hidden Files"
            $This.Value       = 2
            $This.Description = "Shows all hidden files"
            $This.Options     = "Skip", "Show", "Hide*"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Hidden')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Hidden Files"
                    $This.Output[0].Set(2)
                }
            }
        }
    }

    Class SystemFiles : ControlTemplate
    {
        SystemFiles()
        {
            $This.Name        = "SystemFiles"
            $This.DisplayName = "Show System Files"
            $This.Value       = 2
            $This.Description = "Shows all system files"
            $This.Options     = "Skip", "Show", "Hide*"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSuperHidden')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] System Files"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class ExplorerOpenLoc : ControlTemplate
    {
        ExplorerOpenLoc()
        {
            $This.Name        = "ExplorerOpenLoc"
            $This.DisplayName = "Explorer Open Location"
            $This.Value       = 1
            $This.Description = "Default path/location opened with a new explorer window"
            $This.Options     = "Skip", "Quick Access*", "This PC"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LaunchTo')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Default Explorer view to Quick Access"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class RecentFileQuickAccess : ControlTemplate
    {
        RecentFileQuickAccess()
        {
            $This.Name        = "RecentFileQuickAccess"
            $This.DisplayName = "Recent File Quick Access"
            $This.Value       = 1
            $This.Description = "Shows recent files in the Quick Access menu"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
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
                    $This.Output[0].Set(1)
                    $This.Output[1].Set("String","Recent Items Instance Folder")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[2].Set("String","Recent Items Instance Folder")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Recent Files in Quick Access (Hiding)"
                    $This.Output[0].Set(0)
                }
                3
                {
                    Write-Host "Setting [~] Recent Files in Quick Access (Removing)"
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[2].Remove()
                    }
                }
            }
        }
    }

    Class FrequentFoldersQuickAccess : ControlTemplate
    {
        FrequentFoldersQuickAccess()
        {
            $This.Name        = "FrequentFoldersQuickAccess"
            $This.DisplayName = "Frequent Folders Quick Access"
            $This.Value       = 1
            $This.Description = "Show frequently used folders in the Quick Access menu"
            $This.Options     = "Skip", "Show*", "Hide"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowFrequent')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Frequent folders in Quick Access"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class WinContentWhileDrag : ControlTemplate
    {
        WinContentWhileDrag()
        {
            $This.Name        = "WinContentWhileDrag"
            $This.DisplayName = "Window Content while dragging"
            $This.Value       = 1
            $This.Description = "Show the content of a window while it is being dragged/moved"
            $This.Options     = "Skip", "Show*", "Hide"

            $This.Registry('HKCU:\Control Panel\Desktop','DragFullWindows')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Window content while dragging"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class StoreOpenWith : ControlTemplate
    {
        StoreOpenWith()
        {
            $This.Name        = "StoreOpenWith"
            $This.DisplayName = "Store Open With..."
            $This.Value       = 1
            $This.Description = "Toggles the ability to use the Microsoft Store to open an unknown file/program"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer','NoUseStoreOpenWith')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Search Windows Store for Unknown Extensions"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class WinXPowerShell : ControlTemplate
    {
        WinXPowerShell()
        {
            $This.Name        = "WinXPowerShell"
            $This.DisplayName = "Win X PowerShell"
            $This.Value       = 1
            $This.Description = "Toggles whether (Win + X) opens PowerShell or a Command Prompt"
            $This.Options     = "Skip", "PowerShell*", "Command Prompt"

            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','DontUsePowerShellOnWinX')

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
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Disabling [~] (Win+X) PowerShell/Command Prompt"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskManagerDetails : ControlTemplate
    {
        TaskManagerDetails()
        {
            $This.Name        = "TaskManagerDetails"
            $This.DisplayName = "Task Manager Details"
            $This.Value       = 2
            $This.Description = "Toggles whether the task manager details are shown"
            $This.Options     = "Skip", "Show", "Hide*"
            
            $This.Registry('HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager',"Preferences")
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
                    $Path         = $This.Output[0].Path
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
                    $This.Output[0].Set("Binary",$TM)
                }
                2
                {
                    Write-Host "Disabling [~] Task Manager Details"
                    $TM           = $This.Output[0].Get().Preferences
                    $TM[28]       = 1
                    $This.Output[0].Set("Binary",$TM)
                }
            }
        }
    }

    Class ReopenAppsOnBoot : ControlTemplate
    {
        ReopenAppsOnBoot()
        {
            $This.Name        = "ReopenAppsOnBoot"
            $This.DisplayName = "Reopen apps at boot"
            $This.Value       = 1
            $This.Description = "Toggles applications to reopen at boot time"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','DisableAutomaticRestartSignOn')
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
                        $This.Output[0].Set(0)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Reopen applications at boot time"
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class Timeline : ControlTemplate
    {
        Timeline()
        {
            $This.Name        = "Timeline"
            $This.DisplayName = "Timeline"
            $This.Value       = 1
            $This.Description = "Toggles Windows Timeline, for recovery of items at a prior point in time"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System','EnableActivityFeed')
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
                        $This.Output[0].Set(1)
                    }
                    2
                    {
                        Write-Host "Disabling [~] Windows Timeline"
                        $This.Output[0].Set(0)
                    }
                }
            }
        }
    }

    Class LongFilePath : ControlTemplate
    {
        LongFilePath()
        {
            $This.Name        = "LongFilePath"
            $This.DisplayName = "Long File Path"
            $This.Value       = 1
            $This.Description = "Toggles whether file paths are longer, or not"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            ('HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem','LongPathsEnabled'),
            ('HKLM:\SYSTEM\ControlSet001\Control\FileSystem','LongPathsEnabled') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Long file path"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Long file path"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Long file path"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
            }
        }
    }

    Class AppHibernationFile : ControlTemplate
    {
        AppHibernationFile()
        {
            $This.Name        = "AppHibernationFile"
            $This.DisplayName = "App Hibernation File"
            $This.Value       = 1
            $This.Description = "Toggles the system swap file use"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management","SwapfileControl")
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] App Hibernation File (swapfile.sys)"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Enum ExplorerType
    {
        AccessKeyPrompt
        F1HelpKey
        AutoPlay
        AutoRun
        PidInTitleBar
        RecentFileQuickAccess
        FrequentFoldersQuickAccess
        WinContentWhileDrag
        StoreOpenWith
        LongFilePath
        ExplorerOpenLoc
        WinXPowerShell
        AppHibernationFile
        Timeline
        AeroSnap
        AeroShake
        KnownExtensions
        HiddenFiles
        SystemFiles
        TaskManager
        ReopenApps
    }

    Class ExplorerList
    {
        [Object]  $Output
        ExplorerList()
        {
            $This.Output = @( )
            ForEach ($Name in [System.Enum]::GetNames([ExplorerType]))
            {
                $Item = Switch ($Name)
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
                $This.Output += $Item
            }

            $This.Output | % { $_.Source = "Explorer" }
        }
    }

    Class DesktopIconInThisPC : ControlTemplate
    {
        DesktopIconInThisPC()
        {
            $This.Name        = "DesktopIconInThisPC"
            $This.DisplayName = "Desktop [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Desktop icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Desktop folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Desktop folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Set("String","Show")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[3].Get()
                        $This.Output[4].Get()
                        $This.Output[5].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Desktop folder in This PC (Hidden)"
                    $This.Output[2].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Desktop folder in This PC (None)"
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                    }
                }
            }
        }
    }

    Class DocumentsIconInThisPC : ControlTemplate
    {
        DocumentsIconInThisPC()
        {
            $This.Name        = "DocumentsIconInThisPC"
            $This.DisplayName = "Documents [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Documents icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"

            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Documents folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Documents folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{FDD39AD0-238F-46AF-ADB4-6C85480369C7}")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Documents folder in This PC (Hidden)"
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Documents folder in This PC (None)"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }

    Class DownloadsIconInThisPC : ControlTemplate
    {
        DownloadsIconInThisPC()
        {
            $This.Name        = "DownloadsIconInThisPC"
            $This.DisplayName = "Downloads [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Downloads icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Downloads folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Downloads folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{374DE290-123F-4565-9164-39C4925E467B}")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Downloads folder in This PC (Hidden)"
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Documents folder in This PC (None)"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }

    Class MusicIconInThisPC : ControlTemplate
    {
        MusicIconInThisPC()
        {
            $This.Name        = "MusicIconInThisPC"
            $This.DisplayName = "Music [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Music icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Music folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Music folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{4BD8D571-6D19-48D3-BE97-422220080E43}")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Music folder in This PC (Hidden)"
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Music folder in This PC (None)"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }

    Class PicturesIconInThisPC : ControlTemplate
    {
        PicturesIconInThisPC()
        {
            $This.Name        = "PicturesIconInThisPC"
            $This.DisplayName = "Pictures [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Pictures icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Pictures folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Pictures folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{33E28130-4E1E-4676-835A-98395C3BC3BB}")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Pictures folder in This PC (Hidden)"
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Pictures folder in This PC (None)"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }

    Class VideosIconInThisPC : ControlTemplate
    {
        VideosIconInThisPC()
        {
            $This.Name        = "VideosIconInThisPC"
            $This.DisplayName = "Videos [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Videos icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Videos folder in This PC"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Videos folder in This PC (Shown)"
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String","Show")
                    $This.Output[4].Set("String","{18989B1D-99B5-455B-841C-AB7C74E4DDFC}")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Get()
                        $This.Output[6].Get()
                        $This.Output[7].Get()
                        $This.Output[8].Set("String","Show")
                    }
                }
                2
                {
                    Write-Host "Setting [~] Videos folder in This PC (Hidden)"
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    Write-Host "Setting [~] Videos folder in This PC (None)"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Remove()
                        $This.Output[6].Remove()
                    }
                }
            }
        }
    }

    Class ThreeDObjectsIconInThisPC : ControlTemplate
    {
        ThreeDObjectsIconInThisPC()
        {
            $This.Name        = "ThreeDObjectsIconInThisPC"
            $This.DisplayName = "3D Objects [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the 3D Objects icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"),
            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy") | % {

                $This.Registry($_[0],$_[1])
            }
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
                        $This.Output[0].Get()
                        $This.Output[1].Get()
                        $This.Output[2].Set("String","Show")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Output[3].Get()
                            $This.Output[4].Get()
                            $This.Output[5].Set("String","Show")
                        }
                    }
                    2
                    {
                        Write-Host "Setting [~] 3D Objects folder in This PC (Hidden)"
                        $This.Output[2].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Output[5].Set("String","Hide")
                        }
                    }
                    3
                    {
                        Write-Host "Setting [~] 3D Objects folder in This PC (None)"
                        $This.Output[1].Remove()
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Output[5].Remove()
                        }
                    }
                }
            }
        }
    }

    Enum ThisPCIconType
    {
        DesktopIconInThisPC
        DocumentsIconInThisPC
        DownloadsIconInThisPC
        MusicIconInThisPC
        PicturesIconInThisPC
        VideosIconInThisPC
        ThreeDObjectsIconInThisPC
    }

    Class ThisPCIconList
    {
        [Object]  $Output
        ThisPCIconList()
        {
            $This.Output  = @( ) 
            ForEach ($Name in [System.Enum]::GetNames([ThisPCIconType]))
            {
                $Item = Switch ($Name)
                {
                    DesktopIconInThisPC       { [DesktopIconInThisPC]::New()       }
                    DocumentsIconInThisPC     { [DocumentsIconInThisPC]::New()     }
                    DownloadsIconInThisPC     { [DownloadsIconInThisPC]::New()     }
                    MusicIconInThisPC         { [MusicIconInThisPC]::New()         }
                    PicturesIconInThisPC      { [PicturesIconInThisPC]::New()      }
                    VideosIconInThisPC        { [VideosIconInThisPC]::New()        }
                    ThreeDObjectsIconInThisPC { [ThreeDObjectsIconInThisPC]::New() }
                }
                $Item.Source  = "ThisPC"
                $This.Output += $Item
            }
        }
    }

    Class ThisPCOnDesktop : ControlTemplate
    {
        ThisPCOnDesktop()
        {
            $This.Name        = "ThisPCOnDesktop"
            $This.DisplayName = "This PC [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'This PC' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}'),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] This PC Icon on desktop"
                    }
                }
                1
                {
                    Write-Host "Setting [~] This PC Icon on desktop (Shown)"
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] This PC Icon on desktop (Hidden)"
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class NetworkOnDesktop : ControlTemplate
    {
        NetworkOnDesktop()
        {
            $This.Name        = "NetworkOnDesktop"
            $This.DisplayName = "Network [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Network' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Network Icon on desktop"
                    }
                }
                1
                {
                    Write-Host "Setting [~] Network Icon on desktop (Shown)"
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] Network Icon on desktop (Hidden)"
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class RecycleBinOnDesktop : ControlTemplate
    {
        RecycleBinOnDesktop()
        {
            $This.Name        = "RecycleBinOnDesktop"
            $This.DisplayName = "Recycle Bin [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Recycle Bin' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{645FF040-5081-101B-9F08-00AA002F954E}'),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{645FF040-5081-101B-9F08-00AA002F954E}') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Recycle Bin Icon on desktop"
                    }
                }
                1
                {
                    Write-Host "Setting [~] Recycle Bin Icon on desktop (Shown)"
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] Recycle Bin Icon on desktop (Hidden)"
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class UsersFileOnDesktop : ControlTemplate
    {
        UsersFileOnDesktop()
        {
            $This.Name        = "UsersFileOnDesktop"
            $This.DisplayName = "My Documents [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Users File' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}'),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Users file Icon on desktop"
                    }
                }
                1
                {
                    Write-Host "Setting [~] Users file Icon on desktop (Shown)"
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] Users file Icon on desktop (Hidden)"
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class ControlPanelOnDesktop : ControlTemplate
    {
        ControlPanelOnDesktop()
        {
            $This.Name        = "ControlPanelOnDesktop"
            $This.DisplayName = "Control Panel [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Control Panel' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Control Panel Icon on desktop"
                    }
                }
                1
                {
                    Write-Host "Setting [~] Control Panel Icon on desktop (Shown)"
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    Write-Host "Setting [~] Control Panel Icon on desktop (Hidden)"
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Enum DesktopIconType
    {
        ThisPCOnDesktop
        NetworkOnDesktop
        RecycleBinOnDesktop
        UsersFileOnDesktop
        ControlPanelOnDesktop
    }

    Class DesktopIconList
    {
        [Object]  $Output
        DesktopIconList()
        {
            $This.Output = @( )
            ForEach ($Name in [System.Enum]::GetNames([DesktopIconType]))
            {
                $Item = Switch ($Name)
                {
                    ThisPCOnDesktop       { [ThisPCOnDesktop]::New()   }
                    NetworkOnDesktop      { [NetworkOnDesktop]::New()      }
                    RecycleBinOnDesktop   { [RecycleBinOnDesktop]::New()   }
                    UsersFileOnDesktop    { [UsersFileOnDesktop]::New()    }
                    ControlPanelOnDesktop { [ControlPanelOnDesktop]::New() }
                }
                $Item.Source  = "Desktop"
                $This.Output += $Item
            }
        }
    }

    Class LockScreen : ControlTemplate
    {
        LockScreen()
        {
            $This.Name        = "LockScreen"
            $This.DisplayName = "Lock Screen"
            $This.Value       = 1
            $This.Description = "Toggles the lock screen"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreen')
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
                        $This.Output[0].Remove()
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
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class LockScreenPassword : ControlTemplate
    {
        LockScreenPassword()
        {
            $This.Name        = "LockScreenPassword"
            $This.DisplayName = "Lock Screen Password"
            $This.Value       = 1
            $This.Description = "Toggles the lock screen password"
            $This.Options     = "Skip", "Enable*", "Disable"

            ("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure"),
            ("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Lock Screen Password"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Lock Screen Password"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Lock Screen Password"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class PowerMenuLockScreen : ControlTemplate
    {
        PowerMenuLockScreen()
        {
            $This.Name        = "PowerMenuLockScreen"
            $This.DisplayName = "Power Menu Lock Screen"
            $This.Value       = 1
            $This.Description = "Toggles the power menu on the lock screen"
            $This.Options     = "Skip", "Show*", "Hide"

            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','shutdownwithoutlogon')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Power Menu on Lock Screen"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class CameraOnLockScreen : ControlTemplate
    {
        CameraOnLockScreen()
        {
            $This.Name        = "CameraOnLockScreen"
            $This.DisplayName = "Camera On Lock Screen"
            $This.Value       = 1
            $This.Description = "Toggles the camera on the lock screen"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreenCamera')
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
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Camera at Lockscreen"
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Enum LockScreenType
    {
        LockScreen
        LockScreenPassword
        PowerMenuLockScreen
        CameraOnLockScreen
    }

    Class LockScreenList
    {
        [Object]  $Output
        LockScreenList()
        {
            $This.Output = @( ) 
            ForEach ($Name in [System.Enum]::GetNames([LockScreenType]))
            {
                $Item = Switch ($Name)
                {
                    LockScreen          { [LockScreen]::New()          }
                    LockScreenPassword  { [LockScreenPassword]::New()  }
                    PowerMenuLockScreen { [PowerMenuLockScreen]::New() }
                    CameraOnLockScreen  { [CameraOnLockScreen]::New()  }
                }
                $Item.Source  = "LockScreen"
                $This.Output += $Item
            }
        }
    }

    Class ScreenSaver : ControlTemplate
    {
        ScreenSaver()
        {
            $This.Name        = "ScreenSaver"
            $This.DisplayName = "Screen Saver"
            $This.Value       = 1
            $This.Description = "Toggles the screen saver"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry("HKCU:\Control Panel\Desktop","ScreenSaveActive")
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Screensaver"
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AccountProtectionWarn : ControlTemplate
    {
        AccountProtectionWarn()
        {
            $This.Name        = "AccountProtectionWarn"
            $This.DisplayName = "Account Protection Warning"
            $This.Value       = 1
            $This.Description = "Toggles system security account protection warning"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKCU:\SOFTWARE\Microsoft\Windows Security Health\State','AccountProtection_MicrosoftAccount_Disconnected')
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
                        $This.Output[0].Remove()
                    }
                    2
                    {
                        Write-Host "Disabling [~] Account Protection Warning"
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class ActionCenter : ControlTemplate
    {
        ActionCenter()
        {
            $This.Name        = "ActionCenter"
            $This.DisplayName = "Action Center"
            $This.Value       = 1
            $This.Description = "Toggles system action center"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer','DisableNotificationCenter'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications','ToastEnabled') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Action Center"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Action Center"
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Action Center"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class StickyKeyPrompt : ControlTemplate
    {
        StickyKeyPrompt()
        {
            $This.Name        = "StickyKeyPrompt"
            $This.DisplayName = "Sticky Key Prompt"
            $This.Value       = 1
            $This.Description = "Toggles the sticky keys prompt/dialog"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKCU:\Control Panel\Accessibility\StickyKeys','Flags')
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
                    $This.Output[0].Set("String",510)
                }
                2
                {
                    Write-Host "Disabling [~] Sticky Key Prompt"
                    $This.Output[0].Set("String",506)
                }
            }
        }
    }

    Class NumbLockOnStart : ControlTemplate
    {
        NumbLockOnStart()
        {
            $This.Name        = "NumbLockOnStart"
            $This.DisplayName = "Number lock on start"
            $This.Value       = 2
            $This.Description = "Toggles whether the number lock key is engaged upon start"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            $This.Registry('HKU:\.DEFAULT\Control Panel\Keyboard','InitialKeyboardIndicators')
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
                    $This.Output[0].Set(2147483650)
                }
                2
                {
                    Write-Host "Disabling [~] Num Lock on startup"
                    $This.Output[0].Set(2147483648)
                }
            }
        }
    }

    Class F8BootMenu : ControlTemplate
    {
        F8BootMenu()
        {
            $This.Name        = "F8BootMenu"
            $This.DisplayName = "F8 Boot Menu"
            $This.Value       = 2
            $This.Description = "Toggles whether the F8 boot menu can be access upon boot"
            $This.Options     = "Skip", "Enable", "Disable*"
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

    Class RemoteUACAcctToken : ControlTemplate
    {
        RemoteUACAcctToken()
        {
            $This.Name        = "RemoteUACAcctToken"
            $This.DisplayName = "Remote UAC Account Token"
            $This.Value       = 2
            $This.Description = "Toggles the local account token filter policy to mitigate remote connections"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','LocalAccountTokenFilterPolicy')
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
                    $This.Output[0].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] Remote UAC Local Account Token Filter"
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class HibernatePower : ControlTemplate
    {
        HibernatePower()
        {
            $This.Name        = "HibernatePower"
            $This.DisplayName = "Hibernate Power"
            $This.Value       = 0
            $This.Description = "Toggles the hibernation power option"
            $This.Options     = "Skip", "Enable", "Disable"
            
            ('HKLM:\SYSTEM\CurrentControlSet\Control\Power','HibernateEnabled'),
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings','ShowHibernateOption') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Hibernate Option"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Hibernate Option"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    powercfg /HIBERNATE ON
                }
                2
                {
                    Write-Host "Disabling [~] Hibernate Option"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    powercfg /HIBERNATE OFF
                }
            }
        }
    }

    Class SleepPower : ControlTemplate
    {
        SleepPower()
        {
            $This.Name        = "SleepPower"
            $This.DisplayName = "Sleep Power"
            $This.Value       = 1
            $This.Description = "Toggles the sleep power option"
            $This.Options     = "Skip", "Enable*", "Disable"

            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings',"ShowSleepOption")
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
                    $This.Output[0].Set(1)
                    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                }
                2
                {
                    Write-Host "Disabling [~] Sleep Option"
                    $This.Output[0].Set(0)
                    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                }
            }
        }
    }

    Enum MiscellaneousType
    {
        ScreenSaver
        AccountProtectionWarn
        ActionCenter
        StickyKeyPrompt
        NumblockOnStart
        F8BootMenu
        RemoteUACAcctToken
        HibernatePower
        SleepPower
    }

    Class MiscellaneousList
    {
        [Object]  $Output
        MiscellaneousList()
        {
            $This.Output = @( )
            ForEach ($Name in [System.Enum]::GetNames([MiscellaneousType]))
            {
                $Item = Switch ($Name)
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
                $Item.Source  = "Miscellaneous"
                $This.Output += $Item
            }
        }
    }
 
    Class PVFileAssociation : ControlTemplate
    {
        PVFileAssociation()
        {
            $This.Name        = "PVFileAssociation"
            $This.DisplayName = "Photo Viewer File Association"
            $This.Value       = 2
            $This.Description = "Associates common image types with Photo Viewer"
            $This.Options     = "Skip", "Enable", "Disable*"

            ("HKCR:\Paint.Picture\shell\open","MUIVerb"),
            ("HKCR:\giffile\shell\open","MUIVerb"),
            ("HKCR:\jpegfile\shell\open","MUIVerb"),
            ("HKCR:\pngfile\shell\open","MUIVerb"),
            ("HKCR:\Paint.Picture\shell\open\command","(Default)"),
            ("HKCR:\giffile\shell\open\command","(Default)"),
            ("HKCR:\jpegfile\shell\open\command","(Default)"),
            ("HKCR:\pngfile\shell\open\command","(Default)"),
            ("HKCR:\giffile\shell\open","CommandId"),
            ("HKCR:\giffile\shell\open\command","DelegateExecute") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Photo Viewer File Association"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Photo Viewer File Association"
                    0..3 | % { 

                        $This.Output[$_  ].Set("ExpandString","@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
                        $This.Output[$_+4].Set("ExpandString","%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1")
                    }
                }
                2
                {
                    Write-Host "Disabling [~] Photo Viewer File Association"
                    $This.Output[0] | % { $_.Clear(); $_.Remove() }
                    $This.Output[1].Remove()
                    $This.Output[2] | % { $_.Clear(); $_.Remove() }
                    $This.Output[3] | % { $_.Clear(); $_.Remove() }
                    $This.Output[5].Set("String","`"$Env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1")
                    $This.Output[8].Set("String","IE.File")
                    $This.Output[9].Set("String","{17FE9752-0B5A-4665-84CD-569794602F5C}")
                }
            }
        }
    }

    Class PVOpenWithMenu : ControlTemplate
    {
        PVOpenWithMenu()
        {
            $This.Name        = "PVOpenWithMenu"
            $This.DisplayName = "Photo Viewer 'Open with' Menu"
            $This.Value       = 2
            $This.Description = "Allows image files to be opened with Photo Viewer"
            $This.Options     = "Skip", "Enable", "Disable*"

            ('HKCR:\Applications\photoviewer.dll\shell\open'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\command'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget'),
            ('HKCR:\Applications\photoviewer.dll\shell\open','MuiVerb'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\command','(Default)'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget','Clsid') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] 'Open with Photo Viewer' context menu item"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] 'Open with Photo Viewer' context menu item"
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String",'@photoviewer.dll,-3043')
                    $This.Output[4].Set("ExpandString","%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1")
                    $This.Output[5].Set("String",'{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}')
                }
                2
                {
                    Write-Host "Disabling [~] 'Open with Photo Viewer' context menu item"
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Enum PhotoViewerType
    {
        PVFileAssociation
        PVOpenWithMenu
    }

    Class PhotoViewerList
    {
        [Object]  $Output
        PhotoViewerList()
        {
            $This.Output = @( )
            ForEach ($Name in [System.Enum]::GetNames([PhotoViewerType]))
            {
                $Item = Switch ($Name)
                {
                    PVFileAssociation { [PVFileAssociation]::New() }
                    PVOpenWithMenu    { [PVOpenWithMenu]::New()    }
                }
                $Item.Source  = "PhotoViewer"
                $This.Output += $Item
            }
        }
    }

    Class OneDrive : ControlTemplate
    {
        OneDrive()
        {
            $This.Name        = "OneDrive"
            $This.DisplayName = "OneDrive"
            $This.Value       = 1
            $This.Description = "Toggles Microsoft OneDrive, which comes with the operating system"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive','DisableFileSyncNGSC'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSyncProviderNotifications') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] OneDrive"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] OneDrive"
                    $This.Output[0].Remove()
                    $This.Output[1].Set(1)
                }
                2
                {
                    Write-Host "Disabling [~] OneDrive"
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class OneDriveInstall : ControlTemplate
    {
        OneDriveInstall()
        {
            $This.Name        = "OneDriveInstall"
            $This.DisplayName = "OneDriveInstall"
            $This.Value       = 1
            $This.Description = "Installs/Uninstalls Microsoft OneDrive, which comes with the operating system"
            $This.Options     = "Skip", "Installed*", "Uninstall"
            
            ("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"),
            ("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] OneDrive Install"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] OneDrive Install"
                    If ($This.TestPath()) 
                    {
                        Start-Process $This.GetOneDrivePath() -NoNewWindow 
                    }
                }
                2
                {
                    Write-Host "Disabling [~] OneDrive Install"
                    If ($This.TestPath())
                    {
                        Stop-Process -Name OneDrive -Force
                        Start-Sleep -Seconds 3
                        Start-Process $This.GetOneDrivePath() "/uninstall" -NoNewWindow -Wait
                        Start-Sleep -Seconds 3

                        ForEach ($Path in "$Env:USERPROFILE\OneDrive",
                                          "$Env:LOCALAPPDATA\Microsoft\OneDrive",
                                          "$Env:PROGRAMDATA\Microsoft OneDrive",
                                          "$Env:WINDIR\OneDriveTemp",
                                          "$Env:SYSTEMDRIVE\OneDriveTemp")
                        {    
                            Remove-Item $Path -Force -Recurse 
                        }

                        $This.Output[0].Remove()
                        $This.Output[1].Remove()
                    }
                }
            }
        }
        [String] GetOneDrivePath()
        {
            Return @("System32","SysWOW64")[[Environment]::Is64BitOperatingSystem] | % { "$Env:Windir\$_\OneDriveSetup.exe" }
        }
        [Bool] TestPath()
        {
            Return Test-Path $This.GetOneDrivePath() -PathType Leaf
        }
    }

    Class XboxDVR : ControlTemplate
    {
        XboxDVR()
        {
            $This.Name        = "XboxDVR"
            $This.DisplayName = "Xbox DVR"
            $This.Value       = 1
            $This.Description = "Toggles Microsoft Xbox DVR"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCU:\System\GameConfigStore','GameDVR_Enabled'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR','AllowGameDVR') | % {

                $This.Registry($_[0],$_[1])
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
                        Write-Host "Skipping [!] Xbox DVR"
                    }
                }
                1
                {
                    Write-Host "Enabling [~] Xbox DVR"
                    $This.Output[0].Set(1)
                    $This.Output[0].Remove()
                }
                2
                {
                    Write-Host "Disabling [~] Xbox DVR"
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class MediaPlayer : ControlTemplate
    {
        MediaPlayer([Object]$Features)
        {
            $This.Name        = "MediaPlayer"
            $This.DisplayName = "Windows Media Player"
            $This.Value       = 1
            $This.Description = "Toggles Microsoft Windows Media Player, which comes with the operating system"
            $This.Options     = "Skip", "Installed*", "Uninstall"

            $This.Output      = @($Features | ? FeatureName -match MediaPlayback)
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
                    $This.Output[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    Write-Host "Disabling [~] Windows Media Player"
                    $This.Output[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class WorkFolders : ControlTemplate
    {
        WorkFolders([Object]$Features)
        {
            $This.Name        = "WorkFolders"
            $This.DisplayName = "Work Folders"
            $This.Value       = 1
            $This.Description = "Toggles the WorkFolders-Client, which comes with the operating system"
            $This.Options     = "Skip", "Installed*", "Uninstall"

            $This.Output      = @($Features | ? FeatureName -match WorkFolders-Client)
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
                    $This.Output[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    Write-Host "Disabling [~] Work Folders Client"
                    $This.Output[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class FaxAndScan : ControlTemplate
    {
        FaxAndScan([Object]$Features)
        {
            $This.Name        = "FaxAndScan"
            $This.DisplayName = "Fax and Scan"
            $This.Value       = 1
            $This.Description = "Toggles the FaxServicesClientPackage, which comes with the operating system"
            $This.Options     = "Skip", "Installed*", "Uninstall"

            $This.Output      = @($Features | ? FeatureName -match FaxServicesClientPackage)
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
                    $This.Output[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    Write-Host "Disabling [~] Fax And Scan"
                    $This.Output[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart }
                    If ($? -eq $True)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class LinuxSubsystem : ControlTemplate
    {
        LinuxSubsystem([Object]$Features)
        {
            $This.Name        = "LinuxSubsystem"
            $This.DisplayName = "Linux Subsystem (WSL)"
            $This.Value       = 2
            $This.Description = "Toggles the Microsoft-Windows-Subsystem-Linux, which can be installed on Windows 1607 or later"
            $This.Options     = "Skip", "Installed", "Uninstall*"
            $This.Output      = @($Features | ? FeatureName -match Microsoft-Windows-Subsystem-Linux)

            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock','AllowDevelopmentWithoutDevLicense')
            $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock','AllowAllTrustedApps')
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
                        $This.Output[0] | ? State -ne Enabled | % { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Output[0].State = "Enabled"
                        }
                    }
                    2
                    {
                        Write-Host "Disabling [~] Linux Subsystem"
                        $This.Output[0] | ? State -eq Enabled | % { Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart }
                        If ($? -eq $True)
                        {
                            $This.Output[0].State = "Disabled"
                        }
                    }
                }
            }
            Else
            {
                Write-Host "Error [!] This version of Windows does not support (WSL/Windows Subsystem for Linux)"
            }
        }
    }

    Enum WindowsAppsType
    {
        OneDrive
        OneDriveInstall
        XboxDVR
        MediaPlayer
        WorkFolders
        FaxAndScan
        LinuxSubsystem
    }

    Class WindowsAppsList
    {
        [Object] $Features = [WindowsOptionalFeatures]::New().Output
        [Object]   $Output
        WindowsAppsList()
        {
            $This.Output      = @( )
            ForEach ($Name in [System.Enum]::GetNames([WindowsAppsType]))
            {
                $Item         = Switch ($Name)
                {
                    OneDrive        { [OneDrive]::New()                      }
                    OneDriveInstall { [OneDriveInstall]::New()               }
                    XboxDVR         { [XboxDVR]::New()                       }
                    MediaPlayer     { [MediaPlayer]::New($This.Features)     }
                    WorkFolders     { [WorkFolders]::New($This.Features)     }
                    FaxAndScan      { [FaxAndScan]::New($This.Features)      }
                    LinuxSubsystem  { [LinuxSubsystem]::New($This.Features)  }
                }
                $Item.Source  = "WindowsApps"
                $This.Output += $Item
            }
        }
    }

    Enum WindowsOptionalStateType
    {
        Disabled
        DisabledWithPayloadRemoved
        Enabled
    }

    Class WindowsOptionalStateSlot
    {
        [UInt32] $Index
        [String] $Type
        [String] $Description
        WindowsOptionalStateSlot([String]$Type)
        {
            $This.Type = [WindowsOptionalStateType]::$Type
            $This.Index = [UInt32][WindowsOptionalStateType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class WindowsOptionalStateList
    {
        [Object] $Output
        WindowsOptionalStateList()
        {
            $This.Output = @( ) 
            [System.Enum]::GetNames([WindowsOptionalStateType]) | % { $This.Add($_) }
        }
        Add([String]$Name)
        {
            $Item             = [WindowsOptionalStateSlot]::New($Name)
            $Item.Description = Switch ($Name)
            {
                Disabled                   { "Feature is disabled"                     }
                DisabledWithPayloadRemoved { "Feature is disabled, payload is removed" }
                Enabled                    { "Feature is enabled"                      }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output | ? Type -eq $Type
        }
    }

    Class WindowsOptionalFeature
    {
        [UInt32] $Index
        [String] $FeatureName
        [Object] $State
        Hidden [String] $Path
        Hidden [UInt32] $Online
        Hidden [String] $WinPath
        Hidden [String] $SysDrivePath
        Hidden [UInt32] $RestartNeeded
        Hidden [String] $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String] $LogLevel
        WindowsOptionalFeature([UInt32]$Index,[Object]$List,[Object]$Object)
        {
            $This.Index            = $Index
            $This.FeatureName      = $Object.FeatureName
            $This.State            = $List.Get($Object.State)
            $This.Path             = $Object.Path
            $This.Online           = $Object.Online
            $This.WinPath          = $Object.WinPath
            $This.SysDrivePath     = $Object.SysDrivePath
            $This.RestartNeeded    = $Object.RestartNeeded
            $This.LogPath          = $Object.LogPath
            $This.ScratchDirectory = $Object.ScratchDirectory
            $This.LogLevel         = $Object.LogLevel
        }
    }

    Class WindowsOptionalFeatures
    {
        [Object] $State
        [Object] $Output
        WindowsOptionalFeatures()
        {
            $This.State  = [WindowsOptionalStateList]::New()
            $This.Output = @( ) 
            Get-WindowsOptionalFeature -Online | Sort-Object FeatureName | % {

                $This.Output += [WindowsOptionalFeature]::New($This.Output.Count,$This.State,$_)
            }
        }
    }

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
        [UInt32]            $Index
        [UInt32]          $Profile
        Hidden [String]     $CName
        Hidden [String]   $VarName
        [Version]         $Version
        [String]      $PackageName
        [String]      $DisplayName
        [String]      $PublisherID
        [UInt32]     $MajorVersion
        [UInt32]     $MinorVersion
        [UInt32]            $Build
        [UInt32]         $Revision
        [UInt32]     $Architecture
        [String]       $ResourceID
        [String]  $InstallLocation
        [Object]          $Regions
        [String]             $Path
        [UInt32]           $Online
        [String]          $WinPath
        [string]     $SysDrivePath
        [UInt32]    $RestartNeeded
        [String]          $LogPath
        [String] $ScratchDirectory
        [String]         $LogLevel
        [Int32]              $Slot
        AppXObject([UInt32]$Index,[Object]$AppXProfile,[Object]$Object)
        {
            $This.Index            = $Index
            $This.Version          = $Object.Version
            $This.PackageName      = $Object.PackageName
            $This.DisplayName      = $Object.DisplayName
            $This.PublisherId      = $Object.PublisherId
            $This.MajorVersion     = $Object.MajorVersion
            $This.MinorVersion     = $Object.MinorVersion
            $This.Build            = $Object.Build
            $This.Revision         = $Object.Revision
            $This.Architecture     = $Object.Architecture
            $This.ResourceId       = $Object.ResourceId
            $This.InstallLocation  = $Object.InstallLocation
            $This.Regions          = $Object.Regions
            $This.Path             = $Object.Path
            $This.Online           = $Object.Online
            $This.WinPath          = $Object.WinPath
            $This.SysDrivePath     = $Object.SysDrivePath
            $This.RestartNeeded    = $Object.RestartNeeded
            $This.LogPath          = $Object.LogPath
            $This.ScratchDirectory = $Object.ScratchDirectory
            $This.LogLevel         = $Object.LogLevel

            If ($Object.DisplayName -in $AppXProfile.AppXName)
            {
                $Item              = $AppXProfile | ? AppXName -match $This.DisplayName
                $This.Profile      = 1
                $This.CName        = $Item.CName
                $This.VarName      = $Item.VarName
                $This.Slot         = 0
            }
            Else
            {
                    $This.Profile      = 0
                    $This.Slot         = -1
            }
        }
    }

    Class AppXList
    {
        [Object] $Profile = [AppXProfile]::New().Output
        [Object] $Output
        AppXList()
        {
            $This.Output   = @( )
            Get-AppxProvisionedPackage -Online | % { $This.Output += [AppXObject]::New($This.Output.Count,$This.Profile,$_) }
        }
    }

    Class DisableVariousTasks
    {
        [UInt32] $Mode
        [Object] $Stack
        DisableVariousTasks()
        {
            $This.Output = @()
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
            $This.Output = @([Registry]::New('HKLM:\Software\Policies\Microsoft\Windows','ScreensaveTimeout'))
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

    Class SystemControl
    {
        [Object]                     $Output
        [Object]                    $Feature
        [Object]                       $AppX
        SystemControl()
        {
            $This.Reset()
        }
        Reset()
        {
            $This.Output     = @( )
            $This.Output    += [PrivacyList]::New().Output
            $This.Output    += [WindowsUpdateList]::New().Output
            $This.Output    += [ServiceList]::New().Output
            $This.Output    += [ContextList]::New().Output
            $This.Output    += [TaskBarList]::New().Output
            $This.Output    += [StartMenuList]::New().Output
            $This.Output    += [ExplorerList]::New().Output
            $This.Output    += [ThisPCIconList]::New().Output
            $This.Output    += [DesktopIconList]::New().Output
            $This.Output    += [LockScreenList]::New().Output
            $This.Output    += [MiscellaneousList]::New().Output
            $This.Output    += [PhotoViewerList]::New().Output
            $This.Output    += [WindowsAppsList]::New().Output
            $This.Feature    = [WindowsOptionalFeatures]::New().Output
            $This.AppX       = [AppXList]::New().Output
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

    Enum XboxType
    {
        XblAuthManager
        XblGameSave
        XboxNetApiSvc
        XboxGipSvc
        xbgm
    }

    Enum NetTCPType
    {
        NetMsmqActivator
        NetPipeActivator
        NetTcpActivator
    }

    Enum PidType
    {
        BcastDVRUserService
        DevicePickerUserSvc
        DevicesFlowUserSvc
        PimIndexMaintenanceSvc
        PrintWorkflowUserSvc
        UnistoreSvc
        UserDataSvc
        WpnUserService
    }

    Enum SkipType
    {
        AppXSVC
        BrokerInfrastructure
        ClipSVC
        CoreMessagingRegistrar
        DcomLaunch
        EntAppSvc
        gpsvc
        LSM
        MpsSvc
        msiserver
        NgcCtnrSvc
        NgcSvc
        RpcEptMapper
        RpcSs
        Schedule
        SecurityHealthService
        sppsvc
        StateRepository
        SystemEventsBroker
        tiledatamodelsvc
        WdNisSvc
        WinDefend
    }

    Class SkipItem
    {
        [String] $Type
        [String] $Name
        SkipItem([String]$Type,[String]$Name)
        {
            $This.Type     = $Type
            $This.Name     = $Name
        }
    }

    Class SkipList
    {
        [Object] $Output
        SkipList()
        {
            $This.Output = @( )
            $ProcessID   = (Get-Service | ? ServiceType -eq 224)[-1].Name.Split("_")[1]

            ForEach ($Item in [System.Enum]::GetNames([XboxType]))
            {
                $This.SkipItem("Xbox",$Item) 
            }

            ForEach ($Item in [System.Enum]::GetNames([NetTCPType]))
            { 
                $This.SkipItem("NetTCP",$Item) 
            }

            ForEach ($Item in [System.Enum]::GetNames([PidType]))
            {
                $This.SkipItem( "Skip","$Item`_$ProcessID")
            }

            ForEach ($Item in [System.Enum]::GetNames([SkipType]))
            { 
                $This.SkipItem( "Skip",$Item)
            }
        }
        SkipItem([String]$Type,[String]$Name)
        {
            $This.Output += [SkipItem]::New($Type,$Name)
        }
    }

    Class ViperBombConfig
    {
        [UInt32]        $BypassBuild = 0
        [UInt32]      $BypassEdition = 0
        [UInt32]       $BypassLaptop = 0
        [UInt32]      $DisplayActive = 1
        [UInt32]    $DisplayInactive = 1
        [UInt32]     $DisplaySkipped = 1
        [UInt32]       $MiscSimulate = 0
        [UInt32]           $MiscXbox = 1
        [UInt32]         $MiscChange = 0
        [UInt32]   $MiscStopDisabled = 0
        [UInt32]          $DevErrors = 0
        [UInt32]             $DevLog = 0
        [UInt32]         $DevConsole = 0
        [UInt32]          $DevReport = 0
        [String]    $LogServiceLabel = "Service.log"
        [String]     $LogScriptLabel = "Script.log"
        [String]           $RegLabel = "Backup.reg"
        [String]           $CsvLabel = "Backup.csv"
        [Object]             $Filter = [SkipList]::New().Output
    }

    # // _______________________________________________________
    # // | Used to track console logging, similar to Stopwatch |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ViperBombTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        ViperBombTime([String]$Name)
        {
            $This.Name = $Name
            $This.Time = [DateTime]::MinValue
            $This.Set  = 0
        }
        Toggle()
        {
            $This.Time = [DateTime]::Now
            $This.Set  = 1
        }
        [String] ToString()
        {
            Return $This.Time.ToString()
        }
    }

    # // ________________________________________
    # // | Single object that displays a status |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ViperBombStatus
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        ViperBombStatus([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
        {
            $This.Index   = $Index
            $This.Elapsed = $Time
            $This.State   = $State
            $This.Status  = $Status
        }
        [String] ToString()
        {
            Return "[{0}] (State: {1}/Status: {2})" -f $This.Elapsed, $This.State, $This.Status
        }
    }

    # // _________________________________________________________________________
    # // | A collection of status objects, uses itself to create/update messages |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ViperBombStatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        ViperBombStatusBank()
        {
            $This.Reset()
        }
        [String] Elapsed()
        {
            Return @(Switch ($This.End.Set)
            {
                0 { [Timespan]([DateTime]::Now-$This.Start.Time) }
                1 { [Timespan]($This.End.Time-$This.Start.Time) }
            })         
        }
        [Void] SetStatus()
        {
            $This.Status = [ViperBombStatus]::New($This.Output.Count,$This.Elapsed(),$This.Status.State,$This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [ViperBombStatus]::New($This.Output.Count,$This.Elapsed(),$State,$Status)
        }
        Initialize()
        {
            If ($This.Start.Set -eq 1)
            {
                $This.Update(-1,"Start [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.Start.Toggle()
            $This.Update(0,"Running [~] ($($This.Start))")
        }
        Finalize()
        {
            If ($This.End.Set -eq 1)
            {
                $This.Update(-1,"End [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.End.Toggle()
            $This.Span = $This.Elapsed()
            $This.Update(100,"Complete [+] ($($This.End)), Total: ($($This.Span))")
        }
        Reset()
        {
            $This.Start  = [ViperBombTime]::New("Start")
            $This.End    = [ViperBombTime]::New("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.SetStatus($State,$Status)
            $This.Write()
            Return $This.Last()
        }
        [Object] Current()
        {
            $This.Update($This.Status.State,$This.Status.Status)
            Return $This.Last()
        }
        [Object] Last()
        {
            Return $This.Output[$This.Output.Count-1]
        }
        [String] ToString()
        {
            If (!$This.Span)
            {
                Return $This.Elapsed()
            }
            Else
            {
                Return $This.Span
            }
        }
    }

    Class ViperBombController
    {
        [Object] $Console
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
            $This.Console     = $This.StatusBank()
            $This.Update(0,"Loading [~] $($This.Label())")

            Import-Module FightingEntropy
            $This.Module      = Get-FEModule -Mode 1

            $This.Update(0,"Loading [~] AppX")
            Import-Module AppX
            
            $This.System      = $This.GetSystemDetails()

            $This.System.ComputerSystem | % { $_.Memory = "{0} GB" -f [Regex]::Matches($_.Memory,"\d+\.\d{2}").Value }
            $This.Caption     = $This.Module.OS.Caption
            $This.Platform    = $This.Module.OS.Platform
            $This.PSVersion   = $This.Module.OS.PSVersion
            $This.Type        = $This.Module.OS.Type

            $This.Control     = $This.GetSystemControl()

            $This.Xaml        = $This.GetViperBombXaml()

        }
        [Object] GetViperBombXaml()
        {
            $This.Update(0,"Gathering [~] Xaml Interface")
            Return [XamlWindow][ViperBombXaml]::Content
        }
        [Object] GetSystemControl()
        {
            $This.Update(0,"Gathering [~] System Control")
            Return [SystemControl]::New()
        }
        [Object] GetServices()
        {
            $This.Update(0,"Gathering [~] System Services")
            Return [ServiceControl]::New()
        }
        [Object] GetSystemDetails()
        {
            $This.Update(0,"Gathering [~] System Details")
            Return Get-SystemDetails
        }
        [String] Label()
        {
            Return "[FightingEntropy($([Char]960))][System Control Extension Utility]"
        }
        [Object] StatusBank()
        {
            $Item = [ViperBombStatusBank]::New()
            $Item.Initialize()
            Return $Item
        }
        Update([UInt32]$Mode,[String]$State)
        {
            $This.Console.Update($Mode,$State)
            Write-Host $This.Console.Last()
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
                $Ctrl.Service = $Ctrl.GetServices()
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
                $List      = Switch -Regex ($Text)
                {
                    ""
                    {
                        $Ctrl.Service.Output | ? $Property -match $Text
                    }
                    Default
                    {
                        $Ctrl.Service.Output
                    }
                }

                $Ctrl.Xaml.IO.Service.Items.Clear()
                ForEach ($Item in $List)
                {
                    $Ctrl.Xaml.IO.Service.Items.Add($Item)
                }
            })

            ################# Third Tab #########################
            # [Control Subtab]
            $Ctrl.Xaml.IO.ControlOutput.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Output)
            {
                $Ctrl.Xaml.IO.ControlOutput.Items.Add($Item)
            }

            $Ctrl.Xaml.IO.ControlOutput.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.ControlOutput.SelectedIndex
                $Ctrl.Xaml.IO.ControlOutputExtension.Items.Clear()
                If ($Index -ne -1)
                {
                    $Slot = $Ctrl.Xaml.IO.ControlOutput.SelectedItem
                    ForEach ($Property in "Name","DisplayName","Value","Description")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Slot.$Property)
                        $Ctrl.Xaml.IO.ControlOutputExtension.Items.Add($Item)
                    } 
                }
            })

            $Ctrl.Xaml.IO.ControlSlot.Add_SelectionChanged(
            {
                $Slot = $Ctrl.Xaml.IO.ControlSlot.SelectedItem.Content
                $List = Switch ($Slot)
                {
                    Default
                    {
                        $Ctrl.Control.Output | ? Source -eq $Slot
                    }
                    All
                    {
                        $Ctrl.Control.Output
                    }
                }

                $Ctrl.Xaml.IO.ControlOutput.Items.Clear()
                ForEach ($Item in $List)
                {
                    $Ctrl.Xaml.IO.ControlOutput.Items.Add($Item)
                }
            })

            $Ctrl.Xaml.IO.ControlFilter.Add_TextChanged(
            {
                Start-Sleep -Milliseconds 50
                $Property = $Ctrl.Xaml.IO.ControlProperty.SelectedItem.Content
                $Text     = $Ctrl.Xaml.IO.ControlFilter.Text
                $List     = Switch -Regex ($Text)
                {
                    ""
                    {
                        $Ctrl.Control.Output | ? $Property -match $Text
                    }
                    Default
                    {
                        $Ctrl.Control.Output
                    }
                }

                $Ctrl.Xaml.IO.ControlOutput.Items.Clear()
                ForEach ($Item in $List)
                {
                    $Ctrl.Xaml.IO.ControlOutput.Items.Add($Item)
                }
            })

            #[WindowsFeatures Subtab]
            $Ctrl.Xaml.IO.ControlFeature.Items.Clear()
            ForEach ($Item in $Ctrl.Control.Feature)
            {
                $Ctrl.Xaml.IO.ControlFeature.Items.Add($Item)
            }

            $Ctrl.Xaml.IO.ControlFeature.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.ControlFeature.SelectedIndex
                $Ctrl.Xaml.IO.ControlFeatureExtension.Items.Clear()
                If ($Index -ne -1)
                {
                    $Slot = $Ctrl.Xaml.IO.ControlFeature.SelectedItem

                    ForEach ($Property in "Index","FeatureName","State","Path","Online","WinPath","SysDrivePath","RestartNeeded","LogPath","ScratchDirectory","LogLevel")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Slot.$Property)
                        $Ctrl.Xaml.IO.ControlFeatureExtension.Items.Add($Item)
                    } 
                }
            })

            $Ctrl.Xaml.IO.ControlFeatureFilter.Add_TextChanged(
            {
                Start-Sleep -Milliseconds 50
                $Property = $Ctrl.Xaml.IO.ControlFeatureProperty.SelectedItem.Content
                $Text     = $Ctrl.Xaml.IO.ControlFeatureFilter.Text
                $List     = Switch -Regex ($Text)
                {
                    ""
                    {
                        $Ctrl.Control.Feature | ? $Property -match $Text
                    }
                    Default
                    {
                        $Ctrl.Control.Feature
                    }
                }

                $Ctrl.Xaml.IO.ControlFeature.Items.Clear()
                ForEach ($Item in $List)
                {
                    $Ctrl.Xaml.IO.ControlFeature.Items.Add($Item)
                }
            })

            #[AppX]
            $Ctrl.Xaml.IO.ControlAppX.Items.Clear()
            ForEach ($Item in $Ctrl.Control.AppX)
            {
                $Ctrl.Xaml.IO.ControlAppX.Items.Add($Item)
            }

            $Ctrl.Xaml.IO.ControlAppX.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.ControlAppX.SelectedIndex
                $Ctrl.Xaml.IO.ControlAppXExtension.Items.Clear()
                If ($Index -ne -1)
                {
                    $Slot = $Ctrl.Xaml.IO.ControlAppX.SelectedItem

                    ForEach ($Property in "PackageName","DisplayName","PublisherID","Version","Architecture","ResourceID","InstallLocation",
                    "RestartNeeded","LogPath","LogLevel")
                    {
                        $Item = [PSNoteProperty]::New($Property,$Slot.$Property)
                        $Ctrl.Xaml.IO.ControlAppXExtension.Items.Add($Item)
                    } 
                }
            })
    
            $Ctrl.Xaml.IO.ControlAppXFilter.Add_TextChanged(
            {
                Start-Sleep -Milliseconds 50
                $Property = $Ctrl.Xaml.IO.ControlAppXProperty.SelectedItem.Content
                $Text     = $Ctrl.Xaml.IO.ControlAppXFilter.Text
                $List     = Switch -Regex ($Text)
                {
                    ""
                    {
                        $Ctrl.Control.AppX | ? $Property -match $Text
                    }
                    Default
                    {
                        $Ctrl.Control.AppX
                    }
                }

                $Ctrl.Xaml.IO.ControlAppX.Items.Clear()
                ForEach ($Item in $List)
                {
                    $Ctrl.Xaml.IO.ControlAppX.Items.Add($Item)
                }
            })
        }

    }

    $Ctrl = [ViperBombController]::New()
    $Ctrl.StageXamlEvent()
    $Ctrl.Xaml.Invoke()
}
