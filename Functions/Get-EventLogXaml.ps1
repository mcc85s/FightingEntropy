<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-EventLogXaml.ps1                                                                     //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : The graphical user interface for the EventLog Utility.                                   //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-10-10                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:41    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Get-EventLogXaml
{
    Class EventLogGui
    {
        Static [String] $Tab = @(

        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Event Log Utility" Width="1100" Height="650" HorizontalAlignment="Center" Topmost="False" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
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
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/> ',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox>',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Column="0" Name="MainTab"   Content="Main"/>',
        '                    <Button Grid.Column="1" Name="LogTab"    Content="Logs" IsEnabled="False"/>',
        '                    <Button Grid.Column="2" Name="OutputTab" Content="Output" IsEnabled="False"/>',
        '                    <Button Grid.Column="3" Name="ViewTab"   Content="View" IsEnabled="False"/>',
        '                </Grid>',
        '                <Grid Grid.Row="1" Name="MainPanel" Visibility="Visible">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="280"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="70"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="70"/>',
        '                            <ColumnDefinition Width="140"/>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="50"/>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="60"/>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="60"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="0" Content="[Time]:"/>',
        '                        <TextBox  Grid.Column="1"    Name="Time"/>',
        '                        <Label    Grid.Column="2" Content="[Start]:"/>',
        '                        <TextBox  Grid.Column="3"    Name="Start"/>',
        '                        <Label    Grid.Column="4" Content="[System]:"/>',
        '                        <ComboBox Grid.Column="5"    Name="Section" SelectedIndex="0">',
        '                            <ComboBoxItem Content="Snapshot"/>',
        '                            <ComboBoxItem Content="Bios Information"/>',
        '                            <ComboBoxItem Content="Operating System"/>',
        '                            <ComboBoxItem Content="Computer System"/>',
        '                            <ComboBoxItem Content="Processor(s)"/>',
        '                            <ComboBoxItem Content="Disks(s)"/>',
        '                            <ComboBoxItem Content="Network(s)"/>',
        '                            <ComboBoxItem Content="Log Providers"/>',
        '                        </ComboBox>',
        '                        <ComboBox Grid.Column="6"    Name="Slot"/>',
        '                        <Label    Grid.Column="7" Content="[Throttle]:"/>',
        '                        <ComboBox Grid.Column="8"    Name="Throttle"/>',
        '                        <CheckBox Grid.Column="9"    Name="AutoThrottle" Content="Auto"/>',
        '                        <Label    Grid.Column="10" Content="[Threads]:"/>',
        '                        <ComboBox Grid.Column="11"   Name="Threads" IsEnabled="False"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="400"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Grid Grid.Column="0">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="70"/>',
        '                                    <ColumnDefinition Width="330"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                <TextBox Grid.Column="1" Name="DisplayName"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="70"/>',
        '                                    <ColumnDefinition Width="330"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label    Grid.Column="0" Content="[Guid]:"/>',
        '                                <TextBox  Grid.Column="1" Name="Guid"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="Archive" ScrollViewer.HorizontalScrollBarVisibility="Visible" >',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Binding="{Binding Name}"  Width="100"/>',
        '                                        <DataGridTextColumn Binding="{Binding Value}" Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="70"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0" Content="[Base]:"/>',
        '                                    <ComboBox Grid.Column="1" Name="Base"/>',
        '                                    <Button   Grid.Column="2" Name="Browse" Content="Browse"/>',
        '                                    <Button   Grid.Column="2" Name="Export" Content="Export"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </Grid>',
        '                        <DataGrid Grid.Column="2" Name="System">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Binding="{Binding Name}"  Width="100"/>',
        '                                <DataGridTextColumn Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="1" Name="ConsoleSlot" Visibility="Visible">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <TextBox Margin="5" Height="Auto" Name="Console" TextWrapping="NoWrap" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" TextAlignment="Left" VerticalContentAlignment="Top" FontFamily="Cascadia Code" FontSize="10"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1" Name="TableSlot" Visibility="Collapsed">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <DataGrid Name="Table">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index"   Binding="{Binding Index}"   Width="40"/>',
        '                                    <DataGridTextColumn Header="Phase"   Binding="{Binding Phase}"   Width="175"/>',
        '                                    <DataGridTextColumn Header="Type"    Binding="{Binding Type}"    Width="40"/>',
        '                                    <DataGridTextColumn Header="Time"    Binding="{Binding Time}"    Width="75"/>',
        '                                    <DataGridTextColumn Header="Message" Binding="{Binding Message}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="70"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                                <ColumnDefinition Width="80"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="200"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label       Grid.Column="0" Content="[Mode]:"/>',
        '                            <ComboBox    Grid.Column="1" Name="Mode" SelectedIndex="0">',
        '                                <ComboBoxItem Content="Get event logs on this system"/>',
        '                                <ComboBoxItem Content="Import event logs from a file"/>',
        '                            </ComboBox>',
        '                            <Button      Grid.Column="2" Content="Continue" Name="Continue"/>',
        '                            <ProgressBar Grid.Column="3" Name="Progress" Margin="5" Height="20" Width="Auto"/>',
        '                            <Button      Grid.Column="4" Name="ConsoleSet" Content="Console"/>',
        '                            <Button      Grid.Column="5" Name="TableSet"   Content="Table"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </Grid>',
        '                <Grid Grid.Row="1" Name="LogPanel" Visibility="Collapsed">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="150"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label    Grid.Column="0" Content="[Main]:"/>',
        '                        <ComboBox Grid.Column="1" Name="LogMainProperty" SelectedIndex="1">',
        '                            <ComboBoxItem Content="Rank"/>',
        '                            <ComboBoxItem Content="Name"/>',
        '                            <ComboBoxItem Content="Type"/>',
        '                            <ComboBoxItem Content="Path"/>',
        '                        </ComboBox>',
        '                        <TextBox  Grid.Column="2" Name="LogMainFilter"/>',
        '                        <Button   Grid.Column="3" Name="LogMainRefresh" Content="Refresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="1" Name="LogMainResult">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Rank"       Binding="{Binding Rank}"         Width="40"/>',
        '                            <DataGridTextColumn Header="Name"       Binding="{Binding LogName}"      Width="425"/>',
        '                            <DataGridTextColumn Header="Total"      Binding="{Binding Total}"        Width="100"/>',
        '                            <DataGridTextColumn Header="Type"       Binding="{Binding LogType}"      Width="100"/>',
        '                            <DataGridTextColumn Header="Isolation"  Binding="{Binding LogIsolation}" Width="100"/>',
        '                            <DataGridTextColumn Header="Enabled"    Binding="{Binding IsEnabled}"    Width="50"/>',
        '                            <DataGridTextColumn Header="Classic"    Binding="{Binding IsClassicLog}" Width="50"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="65"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label   Grid.Column="0" Content="[Selected]:"/>',
        '                        <TextBox Grid.Column="1"    Name="LogSelected"/>',
        '                        <Label   Grid.Column="2" Content="[Total]:"/>',
        '                        <TextBox Grid.Column="3"    Name="LogTotal"/>',
        '                        <Button  Grid.Column="4"    Name="LogClear" Content="Clear"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="3">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="80"/>',
        '                            <ColumnDefinition Width="150"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0" Content="[Output]:"/>',
        '                        <ComboBox Grid.Column="1" Name="LogOutputProperty" SelectedIndex="1">',
        '                            <ComboBoxItem Content="Index"/>',
        '                            <ComboBoxItem Content="Date"/>',
        '                            <ComboBoxItem Content="Log"/>',
        '                            <ComboBoxItem Content="Rank"/>',
        '                            <ComboBoxItem Content="Provider"/>',
        '                            <ComboBoxItem Content="Id"/>',
        '                            <ComboBoxItem Content="Type"/>',
        '                            <ComboBoxItem Content="Message"/>',
        '                            <ComboBoxItem Content="Content"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2" Name="LogOutputFilter"/>',
        '                        <Button Grid.Column="3" Name="LogOutputRefresh" Content="Refresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="4" Name="LogOutputResult">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
        '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
        '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
        '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="200"/>',
        '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
        '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
        '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="1" Name="OutputPanel" Visibility="Collapsed">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="110"/>',
        '                            <ColumnDefinition Width="150"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0" Content="[Output]:"/>',
        '                        <ComboBox Grid.Column="1" Name="OutputProperty" SelectedIndex="0">',
        '                            <ComboBoxItem Content="Index"/>',
        '                            <ComboBoxItem Content="Date"/>',
        '                            <ComboBoxItem Content="Log"/>',
        '                            <ComboBoxItem Content="Rank"/>',
        '                            <ComboBoxItem Content="Provider"/>',
        '                            <ComboBoxItem Content="Id"/>',
        '                            <ComboBoxItem Content="Type"/>',
        '                            <ComboBoxItem Content="Message"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2" Name="OutputFilter"/>',
        '                        <Button Grid.Column="3" Name="OutputRefresh" Content="Refresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="1" Name="OutputResult">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
        '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
        '                            <DataGridTextColumn Header="Log"      Binding="{Binding Log}"      Width="50"/>',
        '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
        '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="200"/>',
        '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
        '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
        '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="1" Name="ViewPanel" Visibility="Collapsed">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Grid.Row="0" Name="ViewResult">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="200"/>',
        '                            <DataGridTextColumn Header="Value"    Binding="{Binding Value}"    Width="*">',
        '                                <DataGridTextColumn.ElementStyle>',
        '                                    <Style TargetType="TextBlock">',
        '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                    </Style>',
        '                                </DataGridTextColumn.ElementStyle>',
        '                                <DataGridTextColumn.EditingElementStyle>',
        '                                    <Style TargetType="TextBox">',
        '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                        <Setter Property="AcceptsReturn" Value="True"/>',
        '                                    </Style>',
        '                                </DataGridTextColumn.EditingElementStyle>',
        '                            </DataGridTextColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="ViewCopy"  Content="Copy to clipboard"/>',
        '                        <Button Grid.Column="2" Name="ViewClear" Content="Clear"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </Grid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>' -join "`n"
        )
    }

    $Str1             = [System.IO.StringWriter]::New()
    $Xml1             = [System.Xml.XmlTextWriter]::New($Str1)
    $Xml1.Formatting  = "Indented"
    $Xml1.Indentation = 4
    ([Xml][EventLogGui]::Tab).WriteContentTo($Xml1)
    $Xml1.Flush()
    $Str1.Flush()
    $Str1.ToString() 
    
}