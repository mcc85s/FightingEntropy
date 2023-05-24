<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-05-23 20:48:00                                                                  //
 \\==================================================================================================// 

    FileName   : Get-ViperBomb.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For managing system details, Windows services, and controls
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-05-23
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : AKA "System Control Extension Utility"
                 [-] Add stuff from the function [Get-FENetwork]
                 [+] [FightingEntropy()][Development]
                     https://youtu.be/VUkZ1YLzyn8 (6h 30m 16s)
                 [+] 2023_0511-(Get-ViperBomb Development (Part 1)) 
                     https://youtu.be/iCk-7IRfVqc (3h 01m 07s)
                 [+] 2023_0515-(Get-ViperBomb Development (Part 2))
                     https://youtu.be/qcbTe2wGdUY (6h 10m 17s)
.Example
#>
Function Get-ViperBomb
{
    [CmdLetBinding()]Param(
        [ValidateSet(0,1,2)]
        [Parameter()][UInt32]$Mode=0)

    # // ===============
    # // | Xaml assets |
    # // ===============

    Class ViperBombXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" ',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ',
        '        Title="[FightingEntropy]://System Control Extension Utility" ',
        '        Height="640" ',
        '        Width="800"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen"',
        '        FontFamily="Consolas"',
        '        Background="LightYellow">',
        '    <Window.Resources>',
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="TabItem">',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="TabItem">',
        '                        <Border Name="Border"',
        '                                BorderThickness="2"',
        '                                BorderBrush="Black"',
        '                                CornerRadius="5"',
        '                                Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite"',
        '                                              VerticalAlignment="Center"',
        '                                              HorizontalAlignment="Right"',
        '                                              ContentSource="Header"',
        '                                              Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected" ',
        '                                     Value="True">',
        '                                <Setter TargetName="Border" ',
        '                                        Property="Background" ',
        '                                        Value="#4444FF"/>',
        '                                <Setter Property="Foreground" ',
        '                                        Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected" ',
        '                                     Value="False">',
        '                                <Setter TargetName="Border" ',
        '                                        Property="Background" ',
        '                                        Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground" ',
        '                                        Value="#000000"/>',
        '                            </Trigger>',
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Heavy"/>',
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
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="20"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style x:Key="DGCombo" TargetType="ComboBox">',
        '            <Setter Property="Margin" Value="0"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="18"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" ',
        '                    Value="5"/>',
        '            <Setter Property="AutoGenerateColumns"',
        '                    Value="False"/>',
        '            <Setter Property="AlternationCount"',
        '                    Value="2"/>',
        '            <Setter Property="HeadersVisibility"',
        '                    Value="Column"/>',
        '            <Setter Property="CanUserResizeRows"',
        '                    Value="False"/>',
        '            <Setter Property="CanUserAddRows"',
        '                    Value="False"/>',
        '            <Setter Property="IsReadOnly"',
        '                    Value="True"/>',
        '            <Setter Property="IsTabStop"',
        '                    Value="True"/>',
        '            <Setter Property="IsTextSearchEnabled"',
        '                    Value="True"/>',
        '            <Setter Property="SelectionMode"',
        '                    Value="Single"/>',
        '            <Setter Property="ScrollViewer.CanContentScroll"',
        '                    Value="True"/>',
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="VerticalContentAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="TextBlock.VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="Height" Value="20"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" ',
        '                         Value="0">',
        '                    <Setter Property="Background" ',
        '                            Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex"',
        '                         Value="1">',
        '                    <Setter Property="Background" ',
        '                            Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '                <Trigger Property="IsMouseOver" Value="True">',
        '                    <Setter Property="ToolTip">',
        '                        <Setter.Value>',
        '                            <TextBlock Text="{Binding Description}" ',
        '                                       TextWrapping="Wrap"',
        '                                       FontFamily="Consolas"',
        '                                       Width="400" ',
        '                                       Background="#000000" ',
        '                                       Foreground="#00FF00"/>',
        '                        </Setter.Value>',
        '                    </Setter>',
        '                    <Setter Property="ToolTipService.ShowDuration"',
        '                            Value="360000000"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
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
        '        <Style x:Key="LabelGray" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="DarkSlateGray"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="LabelRed" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="IndianRed"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="Line" TargetType="Border">',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="0"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="50"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <DataGrid Grid.Row="0" Name="OS">',
        '            <DataGrid.RowStyle>',
        '                <Style TargetType="{x:Type DataGridRow}">',
        '                    <Style.Triggers>',
        '                        <Trigger Property="IsMouseOver" Value="True">',
        '                            <Setter Property="ToolTip">',
        '                                <Setter.Value>',
        '                                    <TextBlock Text="{Binding Name}"',
        '                                               TextWrapping="Wrap"',
        '                                               FontFamily="Consolas"',
        '                                               Background="#000000" ',
        '                                               Foreground="#00FF00"/>',
        '                                </Setter.Value>',
        '                            </Setter>',
        '                        </Trigger>',
        '                    </Style.Triggers>',
        '                </Style>',
        '            </DataGrid.RowStyle>',
        '            <DataGrid.Columns>',
        '                <DataGridTextColumn Header="Caption"',
        '                                    Width="300"',
        '                                    Binding="{Binding Caption}"/>',
        '                <DataGridTextColumn Header="Platform"',
        '                                    Width="150"',
        '                                    Binding="{Binding Platform}"/>',
        '                <DataGridTextColumn Header="PSVersion" ',
        '                                    Width="150"',
        '                                    Binding="{Binding PSVersion}"/>',
        '                <DataGridTextColumn Header="Type"',
        '                                    Width="*"',
        '                                    Binding="{Binding Type}"/>',
        '            </DataGrid.Columns>',
        '        </DataGrid>',
        '        <TabControl Grid.Row="1">',
        '            <TabItem Header="Module">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="240"/>',
        '                        <RowDefinition Height="50"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0"',
        '                            Background="Black"',
        '                            Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.Background>',
        '                            <ImageBrush Stretch="UniformToFill"',
        '                                        ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\background.jpg"/>',
        '                        </Grid.Background>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Image Grid.Row="0" ',
        '                               Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\banner.png"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="2" Name="Module">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding Description}"',
        '                                                           TextWrapping="Wrap"',
        '                                                           FontFamily="Consolas"',
        '                                                           Background="#000000"',
        '                                                           Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Company"',
        '                                                Binding="{Binding Company}"',
        '                                                Width="155"/>',
        '                            <DataGridTextColumn Header="Module Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="140"/>',
        '                            <DataGridTextColumn Header="Version"',
        '                                                Binding="{Binding Version}"',
        '                                                Width="75"/>',
        '                            <DataGridTextColumn Header="Date"',
        '                                                Binding="{Binding Date}"',
        '                                                Width="135"/>',
        '                            <DataGridTextColumn Header="Guid"',
        '                                                Binding="{Binding Guid}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <TabControl Grid.Row="3">',
        '                            <TabItem Header="Extension">',
        '                                <DataGrid HeadersVisibility="None"',
        '                                          Name="ModuleExtension">',
        '                                <DataGrid.RowStyle>',
        '                                    <Style TargetType="{x:Type DataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="[FightingEntropy()] Module Property"',
        '                                                                   TextWrapping="Wrap"',
        '                                                                   FontFamily="Consolas"',
        '                                                                   Background="#000000"',
        '                                                                   Foreground="#00FF00"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
        '                                            </Trigger>',
        '                                        </Style.Triggers>',
        '                                    </Style>',
        '                                </DataGrid.RowStyle>',
        '                                <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="120"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Binding="{Binding Value}"',
        '                                                            Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </TabItem>',
        '                            <TabItem Header="Root">',
        '                                <DataGrid Name="ModuleRoot">',
        '                                <DataGrid.RowStyle>',
        '                                    <Style TargetType="{x:Type DataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="[FightingEntropy()] Root Property"',
        '                                                                   TextWrapping="Wrap"',
        '                                                                   FontFamily="Consolas"',
        '                                                                   Background="#000000" ',
        '                                                                   Foreground="#00FF00"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
        '                                            </Trigger>',
        '                                        </Style.Triggers>',
        '                                    </Style>',
        '                                </DataGrid.RowStyle>',
        '                                <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Type"',
        '                                                            Binding="{Binding Type}"',
        '                                                            Width="70"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="65"/>',
        '                                        <DataGridTextColumn Header="Fullname"',
        '                                                            Binding="{Binding Fullname}"',
        '                                                            Width="*"/>',
        '                                        <DataGridTextColumn Header="Exists"',
        '                                                            Binding="{Binding Exists}"',
        '                                                            Width="45"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </TabItem>',
        '                            <TabItem Header="Manifest">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="50"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <DataGrid Grid.Row="0"',
        '                                              Name="ModuleManifest">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="[FightingEntropy()] Module Manifest"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Source"',
        '                                                                Binding="{Binding Source}"',
        '                                                                Width="310"/>',
        '                                            <DataGridTextColumn Header="Resource"',
        '                                                                Binding="{Binding Resource}"',
        '                                                                Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <DataGrid Grid.Row="1"',
        '                                              Name="ModuleManifestList">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Fullname}"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"',
        '                                                                Binding="{Binding Type}"',
        '                                                                Width="60"/>',
        '                                            <DataGridTextColumn Header="Name"',
        '                                                                Binding="{Binding Name}"',
        '                                                                Width="175"/>',
        '                                            <DataGridTextColumn Header="Hash"',
        '                                                                Binding="{Binding Hash}"',
        '                                                                Width="*"/>',
        '                                            <DataGridTextColumn Header="Exists"',
        '                                                                Width="45"',
        '                                                                Binding="{Binding Exists}"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
        '                    </Grid>',
        '                </TabItem>',
        '            <TabItem Header="System">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Bios Information">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="50"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="130"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="BiosInformation">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Bios Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Manufacturer"',
        '                                                            Width="200"',
        '                                                            Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Serial"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding SerialNumber}"/>',
        '                                        <DataGridTextColumn Header="Version"',
        '                                                            Width="155"',
        '                                                            Binding="{Binding Version}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="1" Content="[Extension]:"/>',
        '                                <DataGrid Grid.Row="2"',
        '                                          Name="BiosInformationExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Bios Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Operating System">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="50"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="OperatingSystem">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Operating System Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Edition"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Caption}"/>',
        '                                        <DataGridTextColumn Header="Version"',
        '                                                            Width="100"',
        '                                                            Binding="{Binding Version}"/>',
        '                                        <DataGridTextColumn Header="Build"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Build}"/>',
        '                                        <DataGridTextColumn Header="Serial"',
        '                                                            Width="180"',
        '                                                            Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="Lang."',
        '                                                            Width="35"',
        '                                                            Binding="{Binding Language}"/>',
        '                                        <DataGridTextColumn Header="Prod."',
        '                                                            Width="35"',
        '                                                            Binding="{Binding Product}"/>',
        '                                        <DataGridTextColumn Header="Type"',
        '                                                            Width="35"',
        '                                                            Binding="{Binding Type}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0" Content="[Hot Fix]:"/>',
        '                                    <Border   Grid.Column="1" Background="Black" Margin="4"/>',
        '                                    <Label    Grid.Column="2" Content="[Search]:"/>',
        '                                    <ComboBox Grid.Column="3"',
        '                                              Name="HotFixSearchProperty"',
        '                                              SelectedIndex="1">',
        '                                        <ComboBoxItem Content="Description"/>',
        '                                        <ComboBoxItem Content="HotFix ID"/>',
        '                                        <ComboBoxItem Content="Installed By"/>',
        '                                        <ComboBoxItem Content="Installed On"/>',
        '                                    </ComboBox>',
        '                                    <TextBox  Grid.Column="4"',
        '                                              Name="HotFixSearchFilter"/>',
        '                                    <Button   Grid.Column="5"',
        '                                              Content="Refresh"',
        '                                              Name="HotFixRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="2" Name="HotFix">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Source"',
        '                                                            Binding="{Binding Source}"',
        '                                                            Width="*"/>',
        '                                        <DataGridTextColumn Header="Description"',
        '                                                            Binding="{Binding Description}"',
        '                                                            Width="*"/>',
        '                                        <DataGridTextColumn Header="HotFix ID"',
        '                                                            Binding="{Binding HotFixID}"',
        '                                                            Width="80"/>',
        '                                        <DataGridTextColumn Header="Installed By"',
        '                                                            Binding="{Binding InstalledBy}"',
        '                                                            Width="*"/>',
        '                                        <DataGridTextColumn Header="Installed On"',
        '                                                            Binding="{Binding InstalledOn}"',
        '                                                            Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Computer System">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="50"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="ComputerSystem">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Computer System Information"                                                      TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Manufacturer"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Model"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Model}"/>',
        '                                        <DataGridTextColumn Header="Serial"',
        '                                                            Width="200"',
        '                                                            Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="Memory"',
        '                                                            Width="100"',
        '                                                            Binding="{Binding Memory}"/>',
        '                                        <DataGridTextColumn Header="Arch."',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Architecture}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="1" Content="[Extension]:"/>',
        '                                <DataGrid Grid.Row="2"',
        '                                          Name="ComputerSystemExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Computer System Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Processor">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="150"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="Processor">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Processor Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Manufacturer"',
        '                                                            Width="75"',
        '                                                            Binding="{Binding Manufacturer}"/>',
        '                                        <DataGridTextColumn Header="Caption"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Caption}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="1" Content="[Extension]:"/>',
        '                                <DataGrid Grid.Row="2"',
        '                                          Name="ProcessorExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Processor Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="120"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Width= "*"',
        '                                                            Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Disk">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="80"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0"',
        '                                          RowHeaderWidth="0"',
        '                                          Name="Disk">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Disk Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index"',
        '                                                            Width= "40"',
        '                                                            Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Disk"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Disk}"/>',
        '                                        <DataGridTextColumn Header="Model"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Model}"/>',
        '                                        <DataGridTextColumn Header="Serial"',
        '                                                            Width="110"',
        '                                                            Binding="{Binding Serial}"/>',
        '                                        <DataGridTextColumn Header="Partition(s)"',
        '                                                            Width="75"',
        '                                                            Binding="{Binding Partition.Count}"/>',
        '                                        <DataGridTextColumn Header="Volume(s)"',
        '                                                            Width="75"',
        '                                                            Binding="{Binding Volume.Count}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="1" Content="[Extension]:"/>',
        '                                <DataGrid Grid.Row="2"',
        '                                          Name="DiskExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Disk Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="3" Content="[Partition]:"/>',
        '                                <DataGrid Grid.Row="4" Name="DiskPartition">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Partition Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Type"',
        '                                                            Width="200"',
        '                                                            Binding="{Binding Type}"/>',
        '                                        <DataGridTextColumn Header="Size"',
        '                                                            Width="85"',
        '                                                            Binding="{Binding Size}"/>',
        '                                        <DataGridTextColumn Header="Boot"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Boot}"/>',
        '                                        <DataGridTextColumn Header="Primary"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Primary}"/>',
        '                                        <DataGridTextColumn Header="Disk"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Disk}"/>',
        '                                        <DataGridTextColumn Header="Partition"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Partition}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="5" Content="[Volume]:"/>',
        '                                <DataGrid Grid.Row="6" Name="DiskVolume">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Volume Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="DriveID"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding DriveID}"/>',
        '                                        <DataGridTextColumn Header="Description"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Description}"/>',
        '                                        <DataGridTextColumn Header="Filesystem"',
        '                                                            Width="70"',
        '                                                            Binding="{Binding Filesystem}"/>',
        '                                        <DataGridTextColumn Header="Partition"',
        '                                                            Width="200"',
        '                                                            Binding="{Binding Partition}"/>',
        '                                        <DataGridTextColumn Header="Freespace"',
        '                                                            Width= "75"',
        '                                                            Binding="{Binding Freespace}"/>',
        '                                        <DataGridTextColumn Header="Used"',
        '                                                            Width= "75"',
        '                                                            Binding="{Binding Used}"/>',
        '                                        <DataGridTextColumn Header="Size"',
        '                                                            Width= "75"',
        '                                                            Binding="{Binding Size}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Network">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="120"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="135"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="Network">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Network Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Rank"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Rank}"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTemplateColumn Header="Status" Width="100">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Status}"',
        '                                                          Margin="0"',
        '                                                          Padding="2"',
        '                                                          Height="18"',
        '                                                          FontSize="10"',
        '                                                          VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="Enabled"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Label Grid.Row="1" Content="[Extension]:"/>',
        '                                <DataGrid Grid.Row="2" ',
        '                                          HeadersVisibility="None"',
        '                                          Name="NetworkExtension">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Network Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="150"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding Value}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Service">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Configuration">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label  Grid.Column="0"',
        '                                            Content="[Services]:"/>',
        '                                    <Border Grid.Column="1"',
        '                                            Background="Black"',
        '                                            Margin="4"/>',
        '                                    <Label  Grid.Column="2"',
        '                                            Content="[Search]:"/>',
        '                                    <ComboBox Grid.Column="3"',
        '                                          Margin="5"',
        '                                          Name="ServiceProperty"',
        '                                          VerticalAlignment="Center"',
        '                                          SelectedIndex="1">',
        '                                        <ComboBoxItem Content="Name"/>',
        '                                        <ComboBoxItem Content="Display Name"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="4"',
        '                                             Margin="5"',
        '                                             Name="ServiceFilter"/>',
        '                                    <Button Grid.Column="5"',
        '                                            Content="Refresh"',
        '                                            Name="ServiceRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1" ',
        '                                          Grid.Column="0" ',
        '                                          Name="ServiceOutput" ',
        '                                          RowHeaderWidth="0"',
        '                                          ScrollViewer.CanContentScroll="True"',
        '                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="AlternationIndex" Value="0">',
        '                                                    <Setter Property="Background" Value="White"/>',
        '                                                </Trigger>',
        '                                                <Trigger Property="AlternationIndex" Value="1">',
        '                                                    <Setter Property="Background" Value="SkyBlue"/>',
        '                                                </Trigger>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Description}" ',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       Width="800"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                    <Setter Property="ToolTipService.ShowDuration" ',
        '                                                        Value="360000000"/>',
        '                                                </Trigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}" Value="1"/>',
        '                                                        <Condition Binding="{Binding Match}" Value="0"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background" Value="#F08080"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}" Value="0"/>',
        '                                                        <Condition Binding="{Binding Match}" Value="0"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background" Value="#FFFFFF64"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}" Value="0"/>',
        '                                                        <Condition Binding="{Binding Match}" Value="1"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background" Value="#FFFFFF64"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}" Value="1"/>',
        '                                                        <Condition Binding="{Binding Match}" Value="1"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background" Value="LightGreen"/>',
        '                                                </MultiDataTrigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="#"',
        '                                                        Width="30"',
        '                                                        Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                        Width="175"',
        '                                                        Binding="{Binding Name}"/>',
        '                                        <DataGridTextColumn Header="Status"',
        '                                                        Width="50"',
        '                                                        Binding="{Binding Status}"/>',
        '                                        <DataGridTemplateColumn Header="StartType" Width="90">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding StartMode.Index}"',
        '                                                          Margin="0"',
        '                                                          Padding="2"',
        '                                                          Height="18"',
        '                                                          FontSize="10"',
        '                                                          VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="Manual"/>',
        '                                                        <ComboBoxItem Content="Auto"/>',
        '                                                        <ComboBoxItem Content="Auto Delayed"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTemplateColumn Header="[+]" Width="25">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <CheckBox IsChecked="{Binding Scope}"',
        '                                                          Margin="0"',
        '                                                          HorizontalAlignment="Center">',
        '                                                        <CheckBox.LayoutTransform>',
        '                                                            <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
        '                                                        </CheckBox.LayoutTransform>',
        '                                                    </CheckBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTemplateColumn Header="Target" Width="90">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                          Margin="0"',
        '                                                          Padding="2"',
        '                                                          Height="18"',
        '                                                          FontSize="10"',
        '                                                          VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="Manual"/>',
        '                                                        <ComboBoxItem Content="Auto"/>',
        '                                                        <ComboBoxItem Content="Auto Delayed"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTextColumn Header="DisplayName"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding DisplayName}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="105"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Profile]:"/>',
        '                                    <ComboBox Grid.Column="1" ',
        '                                              Name="ServiceSlot"',
        '                                              SelectedIndex="0"/>',
        '                                    <DataGrid Grid.Column="2" ',
        '                                          Name="ServiceDisplay" ',
        '                                          HeadersVisibility="None"',
        '                                          Margin="10">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"',
        '                                                                Binding="{Binding Type}"',
        '                                                                Width="120"/>',
        '                                            <DataGridTextColumn Header="Description"',
        '                                                                Binding="{Binding Description}"',
        '                                                                Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Border Grid.Column="3"',
        '                                            Background="Black"',
        '                                            Margin="4"/>',
        '                                    <Label Grid.Column="4"',
        '                                           Content="[Compliant]:"/>',
        '                                    <Label Grid.Column="5" ',
        '                                           Background="#66FF66"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="Yes"/>',
        '                                    <Label Grid.Column="6"',
        '                                           Background="#FFFF66"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="N/A"/>',
        '                                    <Label Grid.Column="7"',
        '                                           Background="#FF6666"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="No"/>',
        '                                </Grid>',
        '                                <Button Grid.Row="4" ',
        '                                        Name="ServiceSet" ',
        '                                        Content="Apply" ',
        '                                        IsEnabled="False"/>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Preferences">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="300"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Grid Grid.Column="0">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid Grid.Row="0">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="70"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Label Grid.Column="0" Content="[Slot]:"/>',
        '                                            <ComboBox Grid.Column="1" Name="ServiceOptionSlot">',
        '                                                <ComboBoxItem Content="0"/>',
        '                                                <ComboBoxItem Content="1"/>',
        '                                                <ComboBoxItem Content="2"/>',
        '                                                <ComboBoxItem Content="3"/>',
        '                                                <ComboBoxItem Content="4"/>',
        '                                            </ComboBox>',
        '                                            <DataGrid Grid.Column="2"',
        '                                          Height="20"',
        '                                          Name="ServiceOptionDescription"',
        '                                          HeadersVisibility="None">',
        '                                                <DataGrid.Columns>',
        '                                                    <DataGridTextColumn Binding="{Binding Name}"',
        '                                                                        Width="100"/>',
        '                                                    <DataGridTextColumn Binding="{Binding Description}"',
        '                                                                        Width="*"/>',
        '                                                </DataGrid.Columns>',
        '                                            </DataGrid>',
        '                                        </Grid>',
        '                                        <DataGrid Grid.Row="1" Name="ServiceOptionList">',
        '                                            <DataGrid.Columns>',
        '                                                <DataGridTextColumn Header="Type"',
        '                                                                    Binding="{Binding Type}"',
        '                                                                    Width="40"/>',
        '                                                <DataGridTextColumn Header="Description"',
        '                                                                    Binding="{Binding Description}"',
        '                                                                    Width="*"/>',
        '                                                <DataGridTemplateColumn Header="Value" Width="40">',
        '                                                    <DataGridTemplateColumn.CellTemplate>',
        '                                                        <DataTemplate>',
        '                                                            <CheckBox IsChecked="{Binding Value}"/>',
        '                                                        </DataTemplate>',
        '                                                    </DataGridTemplateColumn.CellTemplate>',
        '                                                </DataGridTemplateColumn>',
        '                                            </DataGrid.Columns>',
        '                                        </DataGrid>',
        '                                    </Grid>',
        '                                    <Border Grid.Column="1" Background="Black" Margin="4"/>',
        '                                    <TabControl Grid.Column="2">',
        '                                        <TabItem Header="BlackViper">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <TextBox Grid.Row="0"',
        '                                                         Text="https://www.blackviper.com"/>',
        '                                                <TextBox Grid.Row="1"',
        '                                                         Name="ServiceBlackViper"',
        '                                                         Height="110" ',
        '                                                         Padding="2" ',
        '                                                         VerticalAlignment="Top"',
        '                                                         VerticalContentAlignment="Top"/>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="MadBomb122">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <TextBox Grid.Column="1"',
        '                                                         Text="https://www.github.com/MadBomb122"/>',
        '                                                <TextBox Grid.Row="1" ',
        '                                                         Name="ServiceMadBomb122"',
        '                                                         Height="110" ',
        '                                                         Padding="2" ',
        '                                                         VerticalAlignment="Top"',
        '                                                         VerticalContentAlignment="Top"/>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label   Grid.Column="0"',
        '                                             Content="[Path]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Name="ServiceOptionPath"/>',
        '                                    <Image   Grid.Column="2"',
        '                                             Name="ServiceOptionPathIcon"/>',
        '                                    <Button  Grid.Column="3"',
        '                                             Name="ServiceOptionPathBrowse"',
        '                                             Content="Browse"/>',
        '                                    <Button  Grid.Column="4"',
        '                                             Name="ServiceOptionPathSet"',
        '                                             Content="Set"/>',
        '                                </Grid>',
        '                                <Button Grid.Row="2"',
        '                                        Name="ServiceOptionApply"',
        '                                        Content="Apply"/>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Control">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Settings">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="130"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Category]:"/>',
        '                                    <ComboBox Grid.Column="1" Name="ControlSlot" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="All"/>',
        '                                        <ComboBoxItem Content="Privacy"/>',
        '                                        <ComboBoxItem Content="Windows Update"/>',
        '                                        <ComboBoxItem Content="Service"/>',
        '                                        <ComboBoxItem Content="Context"/>',
        '                                        <ComboBoxItem Content="Taskbar"/>',
        '                                        <ComboBoxItem Content="Start Menu"/>',
        '                                        <ComboBoxItem Content="Explorer"/>',
        '                                        <ComboBoxItem Content="This PC"/>',
        '                                        <ComboBoxItem Content="Desktop"/>',
        '                                        <ComboBoxItem Content="Lock Screen"/>',
        '                                        <ComboBoxItem Content="Miscellaneous"/>',
        '                                        <ComboBoxItem Content="Photo Viewer"/>',
        '                                        <ComboBoxItem Content="Windows Apps"/>',
        '                                    </ComboBox>',
        '                                    <Border Grid.Column="2" Margin="4" Background="Black"/>',
        '                                    <Label    Grid.Column="3" Content="[Search]:"/>',
        '                                    <ComboBox Grid.Column="4" Name="ControlProperty" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Name"/>',
        '                                        <ComboBoxItem Content="Description"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="5" Name="ControlFilter"/>',
        '                                    <Button Grid.Column="6" Content="Refresh" Name="ControlRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1" Name="ControlOutput">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Type"',
        '                                                            Width="100"',
        '                                                            Binding="{Binding Source}"',
        '                                                            IsReadOnly="True"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding DisplayName}"',
        '                                                            IsReadOnly="True"/>',
        '                                        <DataGridTemplateColumn Header="Value" Width="150">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Value}" ',
        '                                                              ItemsSource="{Binding Options}" ',
        '                                                              Style="{StaticResource DGCombo}"/>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="ControlOutputApply"',
        '                                            Content="Apply"',
        '                                            IsEnabled="False"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="ControlOutputDontApply"',
        '                                            Content="Do not apply..."',
        '                                            IsEnabled="False"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Optional">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Search]:"/>',
        '                                    <ComboBox Grid.Column="1"',
        '                                              Name="ControlFeatureProperty"',
        '                                              SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Feature Name"/>',
        '                                        <ComboBoxItem Content="State"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="2"',
        '                                             Name="ControlFeatureFilter"/>',
        '                                    <Button Grid.Column="3"',
        '                                            Content="Refresh"',
        '                                            Name="ControlFeatureRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Name="ControlFeature" Grid.Row="1">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index"',
        '                                                            Width="50"',
        '                                                            Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding FeatureName}"/>',
        '                                        <DataGridTemplateColumn Header="State" Width="150">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                              Style="{StaticResource DGCombo}">',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="DisabledWithPayloadRemoved"/>',
        '                                                        <ComboBoxItem Content="Enabled"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridCheckBoxColumn Header="Profile"',
        '                                                                Width="50"',
        '                                                                Binding="{Binding Profile}"/>',
        '                                        <DataGridTemplateColumn Header="Target" Width="150">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                              Style="{StaticResource DGCombo}">',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="DisabledWithPayloadRemoved"/>',
        '                                                        <ComboBoxItem Content="Enabled"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="ControlFeatureApply"',
        '                                            Content="Apply"',
        '                                            IsEnabled="False"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="ControlFeatureDontApply"',
        '                                            Content="Do not apply..."',
        '                                            IsEnabled="False"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="AppX">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Search]:"/>',
        '                                    <ComboBox Grid.Column="1"',
        '                                          Name="ControlAppXProperty"',
        '                                          SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Package Name"/>',
        '                                        <ComboBoxItem Content="Display Name"/>',
        '                                        <ComboBoxItem Content="Publisher ID"/>',
        '                                        <ComboBoxItem Content="Install Location"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="2"',
        '                                         Name="ControlAppXFilter"/>',
        '                                    <Button Grid.Column="3" Content="Refresh" Name="ControlAppXRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Name="ControlAppX" Grid.Row="1">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index"',
        '                                                            Binding="{Binding Index}"',
        '                                                            Width="50"/>',
        '                                        <DataGridTextColumn Header="DisplayName"',
        '                                                            Binding="{Binding DisplayName}"',
        '                                                            Width="2*"/>',
        '                                        <DataGridTextColumn Header="PublisherID"',
        '                                                            Binding="{Binding PublisherID}"',
        '                                                            Width="125"/>',
        '                                        <DataGridTextColumn Header="Version"',
        '                                                            Binding="{Binding Version}"',
        '                                                            Width="150"/>',
        '                                        <DataGridTemplateColumn Header="State" Width="60">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Slot}"',
        '                                                              Margin="0"',
        '                                                              Padding="2"',
        '                                                              Height="18"',
        '                                                              FontSize="10"',
        '                                                              VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Unhide"/>',
        '                                                        <ComboBoxItem Content="Hide"/>',
        '                                                        <ComboBoxItem Content="Uninstall"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridCheckBoxColumn Header="Profile"',
        '                                                                Width="50"',
        '                                                                Binding="{Binding Profile}"/>',
        '                                        <DataGridTemplateColumn Header="Target" Width="60">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Profile}"',
        '                                                              Margin="0"',
        '                                                              Padding="2"',
        '                                                              Height="18"',
        '                                                              FontSize="10"',
        '                                                              VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Unhide"/>',
        '                                                        <ComboBoxItem Content="Hide"/>',
        '                                                        <ComboBoxItem Content="Uninstall"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="ControlAppXApply"',
        '                                            Content="Apply"',
        '                                            IsEnabled="False"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="ControlAppXDontApply"',
        '                                            Content="Do not apply..."',
        '                                            IsEnabled="False"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Preferences">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[Global]:"/>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0"',
        '                                              Content="Create Restore Point"',
        '                                              Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="ControlGlobalRestorePoint"/>',
        '                                    <Border   Grid.Column="2"',
        '                                              Margin="4"',
        '                                              Background="Black"/>',
        '                                    <Label    Grid.Column="3"',
        '                                              Content="Restart When Done"',
        '                                              Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="4"',
        '                                              Name="ControlGlobalRestart"/>',
        '                                    <Label    Grid.Column="6"',
        '                                              Content="Restart recommended"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="300"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0"',
        '                                              Content="Show Skipped Items"',
        '                                              Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="ControlGlobalShowSkipped"/>',
        '                                    <Border   Grid.Column="2"',
        '                                              Margin="4"',
        '                                              Background="Black"/>',
        '                                    <Label    Grid.Column="3"',
        '                                              Content="Check for Update"',
        '                                              Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="4"',
        '                                              Name="ControlGlobalVersionCheck"/>',
        '                                    <Label    Grid.Column="6"',
        '                                              Content="If found, will run with [current settings]"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="Skip Internet Check"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="ControlGlobalInternetCheck"/>',
        '                                </Grid>',
        '                                <Label Grid.Row="4" Content="[Backup]:" Margin="5"/>',
        '                                <Grid Grid.Row="5">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="ControlBackupSave"',
        '                                            Content="Save Settings"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="ControlBackupLoad"',
        '                                            Content="Load Settings"/>',
        '                                    <Button Grid.Column="2"',
        '                                            Name="ControlBackupWinDefault"',
        '                                            Content="Windows Default"/>',
        '                                    <Button Grid.Column="3"',
        '                                            Name="ControlBackupResetDefault"',
        '                                            Content="Reset All Items"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Profile" Height="32" VerticalAlignment="Top">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="120"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="10"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label    Grid.Column="0" Content="[Profile]:"/>',
        '                            <ComboBox Grid.Column="1"',
        '                                      Name="ProfileType">',
        '                                <ComboBoxItem Content="All"/>',
        '                                <ComboBoxItem Content="System"/>',
        '                                <ComboBoxItem Content="Service"/>',
        '                                <ComboBoxItem Content="User"/>',
        '                            </ComboBox>',
        '                            <Border   Grid.Column="2" Background="Black" Margin="4"/>',
        '                            <Label    Grid.Column="3" Content="[Search]:"/>',
        '                            <ComboBox Grid.Column="4"',
        '                                      Name="ProfileSearchProperty"',
        '                                      SelectedIndex="0">',
        '                                <ComboBoxItem Content="Name"/>',
        '                                <ComboBoxItem Content="Sid"/>',
        '                                <ComboBoxItem Content="Account"/>',
        '                                <ComboBoxItem Content="Path"/>',
        '                            </ComboBox>',
        '                            <TextBox  Grid.Column="5"',
        '                                      Name="ProfileSearchFilter"/>',
        '                            <Button   Grid.Column="6"',
        '                                      Content="Refresh"',
        '                                      Name="ProfileRefresh"/>',
        '                        </Grid>',
        '                        <DataGrid Grid.Row="1" Name="ProfileOutput">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Sid.Name}" ',
        '                                                               TextWrapping="Wrap"',
        '															   FontFamily="Consolas"',
        '                                                               Background="#000000" ',
        '                                                               Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                            <Setter Property="ToolTipService.ShowDuration" ',
        '                                                            Value="360000000"/>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Account"',
        '                                                    Binding="{Binding Account}"',
        '                                                    Width="200"/>',
        '                                <DataGridTextColumn Header="Path"',
        '                                                    Binding="{Binding Path}"',
        '                                                    Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Mode/Process]:"/>',
        '                            <ComboBox Grid.Column="1"',
        '                                      Name="ProfileMode">',
        '                                <ComboBoxItem Content="0"/>',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                            </ComboBox>',
        '                            <DataGrid Grid.Column="2"',
        '                                      HeadersVisibility="None"',
        '                                      Name="ProfileModeDescription"',
        '                                      Margin="10">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                        Binding="{Binding Name}"',
        '                                                        Width="80"/>',
        '                                    <DataGridTextColumn Header="Description"',
        '                                                        Binding="{Binding Description}"',
        '                                                        Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <ComboBox Grid.Column="3" Name="ProfileProcess">',
        '                                <ComboBoxItem Content="0"/>',
        '                                <ComboBoxItem Content="1"/>',
        '                            </ComboBox>',
        '                            <DataGrid Grid.Column="4"',
        '                                      HeadersVisibility="None"',
        '                                      Name="ProfileProcessDescription"',
        '                                      Margin="10">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                        Binding="{Binding Name}"',
        '                                                        Width="80"/>',
        '                                    <DataGridTextColumn Header="Description"',
        '                                                        Binding="{Binding Description}"',
        '                                                        Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                        <TabControl Grid.Row="3">',
        '                            <TabItem Header="Sid">',
        '                                <DataGrid Name="ProfileSid">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Value}" ',
        '                                                                       TextWrapping="Wrap"',
        '															           FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                    <Setter Property="ToolTipService.ShowDuration" ',
        '                                                            Value="360000000"/>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="100"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Binding="{Binding Value}"',
        '                                                            Width="*">',
        '                                            <DataGridTextColumn.ElementStyle>',
        '                                                <Style TargetType="TextBlock">',
        '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                                </Style>',
        '                                            </DataGridTextColumn.ElementStyle>',
        '                                            <DataGridTextColumn.EditingElementStyle>',
        '                                                <Style TargetType="TextBox">',
        '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                                    <Setter Property="AcceptsReturn" Value="True"/>',
        '                                                </Style>',
        '                                            </DataGridTextColumn.EditingElementStyle>',
        '                                        </DataGridTextColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </TabItem>',
        '                            <TabItem Header="Property">',
        '                                <DataGrid Name="ProfileProperty">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Value}" ',
        '                                                                       TextWrapping="Wrap"',
        '															           FontFamily="Consolas"',
        '                                                                       Background="#000000" ',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                    <Setter Property="ToolTipService.ShowDuration" ',
        '                                                            Value="360000000"/>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="300"/>',
        '                                        <DataGridTextColumn Header="Value"',
        '                                                            Binding="{Binding Value}"',
        '                                                            Width="*">',
        '                                            <DataGridTextColumn.ElementStyle>',
        '                                                <Style TargetType="TextBlock">',
        '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                                </Style>',
        '                                            </DataGridTextColumn.ElementStyle>',
        '                                            <DataGridTextColumn.EditingElementStyle>',
        '                                                <Style TargetType="TextBox">',
        '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
        '                                                    <Setter Property="AcceptsReturn" Value="True"/>',
        '                                                </Style>',
        '                                            </DataGridTextColumn.EditingElementStyle>',
        '                                        </DataGridTextColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </TabItem>',
        '                            <TabItem Header="Content">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="110"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="10"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0"',
        '                                                 Content="[Path]:"/>',
        '                                        <TextBox Grid.Column="1"',
        '                                                 Name="ProfilePath"/>',
        '                                        <Label   Grid.Column="2"',
        '                                                 Content="[Count/Size]:"/>',
        '                                        <TextBox Grid.Column="3"',
        '                                                 Name="ProfileCount"/>',
        '                                        <TextBox Grid.Column="4"',
        '                                                 Name="ProfileSize"/>',
        '                                        <Border  Grid.Column="5"',
        '                                                 Background="Black"',
        '                                                 Margin="4"/>',
        '                                        <Button  Grid.Column="6"',
        '                                                 Name="ProfileLoad"',
        '                                                 Content="Load"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="ProfileContent">',
        '                                        <DataGrid.RowStyle>',
        '                                            <Style TargetType="{x:Type DataGridRow}">',
        '                                                <Style.Triggers>',
        '                                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                                        <Setter Property="ToolTip">',
        '                                                            <Setter.Value>',
        '                                                                <TextBlock Text="{Binding Fullname}" ',
        '                                                                           TextWrapping="Wrap"',
        '                                                                           FontFamily="Consolas"',
        '                                                                           Background="#000000" ',
        '                                                                           Foreground="#00FF00"/>',
        '                                                            </Setter.Value>',
        '                                                        </Setter>',
        '                                                        <Setter Property="ToolTipService.ShowDuration" ',
        '                                                                Value="360000000"/>',
        '                                                    </Trigger>',
        '                                                </Style.Triggers>',
        '                                            </Style>',
        '                                        </DataGrid.RowStyle>',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"',
        '                                                                Binding="{Binding Type}"',
        '                                                                Width="75"/>',
        '                                            <DataGridTextColumn Header="Created"',
        '                                                                Binding="{Binding Created}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Accessed"',
        '                                                                Binding="{Binding Accessed}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Modified"',
        '                                                                Binding="{Binding Modified}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Size"',
        '                                                                Binding="{Binding Size}"',
        '                                                                Width="75"/>',
        '                                            <DataGridTextColumn Header="Name"',
        '                                                                Binding="{Binding Name}"',
        '                                                                Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="25"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label Grid.Column="0" ',
        '                                               Content="[Target]:"/>',
        '                                        <TextBox Grid.Column="1"',
        '                                                 Name="ProfileTarget"/>',
        '                                        <Image Grid.Column="2"',
        '                                               Name="ProfileTargetIcon"/>',
        '                                        <Button Grid.Column="3"',
        '                                                Name="ProfileBrowse"',
        '                                                Content="Browse"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Console">',
        '                <DataGrid Name="Console">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="{Binding String}"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                    <Setter Property="ToolTipService.ShowDuration" ',
        '                                            Value="360000000"/>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Index"',
        '                                            Binding="{Binding Index}"',
        '                                            Width="50"/>',
        '                        <DataGridTextColumn Header="Elapsed"',
        '                                            Binding="{Binding Elapsed}"',
        '                                            Width="125"/>',
        '                        <DataGridTextColumn Header="State"',
        '                                            Binding="{Binding State}"',
        '                                            Width="50"/>',
        '                        <DataGridTextColumn Header="Status"',
        '                                            Binding="{Binding Status}"',
        '                                            Width="*"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '            </TabItem>',
        '        </TabControl>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class XamlProperty
    {
        [UInt32]   $Index
        [String]    $Name
        [Object]    $Type
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
        Hidden [Object]        $Xaml
        Hidden [Object]         $Xml
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
    
            $This.Xaml           = $Xaml
            $This.Xml            = [XML]$Xaml
            $This.Names          = $This.FindNames()
            $This.Types          = @( )
            $This.Node           = [System.Xml.XmlNodeReader]::New($This.Xml)
            $This.IO             = [System.Windows.Markup.XamlReader]::Load($This.Node)
            
            ForEach ($X in 0..($This.Names.Count-1))
            {
                $Name            = $This.Names[$X]
                $Object          = $This.IO.FindName($Name)
                $This.IO         | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If (!!$Object)
                {
                    $This.Types += $This.XamlProperty($This.Types.Count,$Name,$Object)
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
        [Object] Get([String]$Name)
        {
            $Item = $This.Types | ? Name -eq $Name
            If ($Item)
            {
                Return $Item.Control
            }
            Else
            {
                Return $Null
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
        [String] ToString()
        {
            Return "<FEModule.XamlWindow[VmControllerXaml]>"
        }
    }

    # // ===================
    # // | Generic classes |
    # // ===================

    Class ByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        ByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Class GenericProperty
    {
        [UInt32]  $Index
        [String]   $Name
        [Object]  $Value
        GenericProperty([UInt32]$Index,[Object]$Property)
        {
            $This.Index  = $Index
            $This.Name   = $Property.Name
            $This.Value  = $Property.Value -join ", "
        }
        [String] ToString()
        {
            Return "<FESystem.Property>"
        }
    }

    Class GenericProfileProperty
    {
        [UInt32] $Index
        [String] $Name
        [String] $Value
        GenericProfileProperty([UInt32]$Index,[Object]$Property)
        {
            $This.Index    = $Index
            $This.Name     = $Property.Name
            $This.Property = $Property.Value
        }
        GenericProfileProperty([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Value    = $Value
        }
        [String] ToString()
        {
            Return "<FESystem.GenericProfile[Property]>"
        }
    }

    Class GenericProfile
    {
        [String]     $Name
        [String] $Fullname
        [UInt32]   $Exists
        [Object]  $Content
        [Object]   $Output
        GenericProfile([String]$Name)
        {
            $This.Name     = $Name
        }
        [Object] GenericProfileProperty([UInt32]$Index,[Object]$Property)
        {
            Return [GenericProfileProperty]::New($Index,$Property)
        }
        [Object] GenericProfileProperty([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            Return [GenericProfileProperty]::New($Index,$Name,$Value)
        }
        TestPath()
        {
            $This.Exists   = [UInt32](Test-Path $This.Fullname)
        }
        SetPath([String]$Fullname)
        {
            $This.Fullname = $Fullname
        }
        [String] ToString()
        {
            Return "<FESystem.Profile[{0}]>" -f $This.Name
        }
    }

    Class GenericList
    {
        [String]    $Name
        [Object] $Profile
        [UInt32]   $Count
        [Object]  $Output
        GenericList([String]$Name)
        {
            $This.Name    = $Name
            $This.Profile = $This.GenericProfile()
            $This.Clear()
        }
        GenericList([Switch]$Flags,[String]$Name)
        {
            $This.Name    = $Name
            $This.Profile = "<Nullified>"
            $This.Clear()
        }
        Clear()
        {
            $This.Count   = 0
            $This.Output  = @( )
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
            $This.Count   = $This.Output.Count
        }
        [Object] GenericProfile()
        {
            Return [GenericProfile]::New($This.Name)
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.{1}[List]>" -f $This.Count, $This.Name
        }
    }

    Class RegistryItem
    {
        [String] $Path
        [String] $Name
        RegistryItem([String]$Path)
        {
            $This.Path  = $Path
        }
        RegistryItem([String]$Path,[String]$Name)
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
        Hidden [Object] $Console
        Hidden [Guid]      $Guid
        [String]         $Source
        [String]           $Name
        [String]    $DisplayName
        [UInt32]          $Value
        [String]    $Description
        [String[]]      $Options
        [Object]         $Output
        Hidden [String]  $Status
        ControlTemplate([Object]$Console)
        {
            $This.Console = $Console
            $This.Guid    = $This.NewGuid()
            $This.Output  = @( )
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [Object] RegistryItem([String]$Path,[String]$Name)
        {
            Return [RegistryItem]::New($Path,$Name)
        }
        Registry([String]$Path,[String]$Name)
        {
            $This.Output += $This.RegistryItem($Path,$Name)
        }
        SetStatus()
        {
            $This.Status = "[Control]: {0}: {1}" -f $This.Source, $This.Name
        }
        Update([UInt32]$State,[String]$Status)
        {
            $This.Console.Update($State,"[Control/$($This.Guid)]: $Status")
        }
        [UInt32] GetWinVersion()
        {
            Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
        }
    }

    # // ========================
    # // | Cim Instance Objects |
    # // ========================

    Class BiosInformation
    {
        Hidden [Object]     $Bios
        [String]            $Name
        [String]    $Manufacturer
        [String]    $SerialNumber
        [String]         $Version
        [String]     $ReleaseDate
        [Bool]     $SmBiosPresent
        [String]   $SmBiosVersion
        [String]     $SmBiosMajor
        [String]     $SmBiosMinor
        [String] $SystemBiosMajor
        [String] $SystemBiosMinor
        BiosInformation()
        {
            $This.Bios            = $This.GetBios()

            $This.Name            = $This.Bios.Name
            $This.Manufacturer    = $This.Bios.Manufacturer
            $This.SerialNumber    = $This.Bios.SerialNumber
            $This.Version         = $This.Bios.Version
            $This.ReleaseDate     = $This.Bios.ReleaseDate
            $This.SmBiosPresent   = $This.Bios.SmBiosPresent
            $This.SmBiosVersion   = $This.Bios.SmBiosBiosVersion
            $This.SmBiosMajor     = $This.Bios.SmBiosMajorVersion
            $This.SmBiosMinor     = $This.Bios.SmBiosMinorVersion
            $This.SystemBiosMajor = $This.Bios.SystemBiosMajorVersion
            $This.SystemBIosMinor = $This.Bios.SystemBiosMinorVersion
        }
        [Object] GetBios()
        {
            Return Get-CimInstance Win32_Bios
        }
        [String] ToString()
        {
            Return "<FESystem.BiosInformation>"
        }
    }

    Class OperatingSystem
    {
        Hidden [Object]       $Os
        [String]         $Caption
        [String]         $Version
        [String]           $Build
        [String]          $Serial
        [UInt32]        $Language
        [UInt32]         $Product
        [UInt32]            $Type
        OperatingSystem()
        {
            $This.OS            = $This.GetOperatingSystem()

            $This.Caption       = $This.OS.Caption
            $This.Version       = $This.OS.Version
            $This.Build         = $This.OS.BuildNumber
            $This.Serial        = $This.OS.SerialNumber
            $This.Language      = $This.OS.OSLanguage
            $This.Product       = $This.OS.OSProductSuite
            $This.Type          = $This.OS.OSType

        }
        [Object] GetOperatingSystem()
        {
            Return Get-CimInstance Win32_OperatingSystem
        }
        [String] ToString()
        {
            Return "<FESystem.OperatingSystem>"
        }
    }

    Class ComputerSystem
    {
        Hidden [Object] $Computer
        [String]    $Manufacturer
        [String]           $Model
        [String]         $Product
        [String]          $Serial
        [Object]          $Memory
        [String]    $Architecture
        [String]            $UUID
        [String]         $Chassis
        [String]        $BiosUefi
        [Object]        $AssetTag
        ComputerSystem()
        {
            $This.Computer     = @{ 
            
                System         = $This.Get("ComputerSystem")
                Product        = $This.Get("ComputerSystemProduct")
                Board          = $This.Get("BaseBoard")
                Form           = $This.Get("SystemEnclosure")
            }

            $This.Manufacturer = $This.Computer.System.Manufacturer
            $This.Model        = $This.Computer.System.Model
            $This.Memory       = $This.ByteSize("Memory",$This.Computer.System.TotalPhysicalMemory)
            $This.UUID         = $This.Computer.Product.UUID 
            $This.Product      = $This.Computer.Product.Version
            $This.Serial       = $This.Computer.Board.SerialNumber -Replace "\.",""
            $This.BiosUefi     = $This.Get("SecureBootUEFI")

            $This.AssetTag     = $This.Computer.Form.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$This.Computer.Form.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[$This.Get("Architecture")]
        }
        [Object] ByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [ByteSize]::New($Name,$Bytes)
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                ComputerSystem
                {
                    Get-CimInstance Win32_ComputerSystem 
                }
                ComputerSystemProduct
                {
                    Get-CimInstance Win32_ComputerSystemProduct
                }
                Baseboard
                {
                    Get-CimInstance Win32_Baseboard
                }
                SystemEnclosure
                {
                    Get-CimInstance Win32_SystemEnclosure
                }
                SecureBootUEFI
                {
                    Try
                    {
                        Get-SecureBootUEFI -Name SetupMode -EA 0
                        "UEFI"
                    }
                    Catch
                    {
                        "BIOS"
                    }
                }
                Architecture
                {
                    [Environment]::GetEnvironmentVariable("Processor_Architecture")
                }
            }

            Return $Item
        }
        [String] ToString()
        {
            Return "<FESystem.ComputerSystem>"
        }
    }

    Class CurrentVersion
    {
        Hidden [Object] $Current
        [String]             $Id
        [String]          $Label
        [Object]       $Property
        CurrentVersion()
        {
            $This.Refresh()
        }
        [Object] GenericProperty([UInt32]$Index,[Object]$Property)
        {
            Return [GenericProperty]::New($Index,$Property)
        }
        [Object] GetCurrentVersion()
        {
            Return Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        }
        Clear()
        {
            $This.Property = @( )
        }
        Refresh()
        {
            $This.Current  = $This.GetCurrentVersion()
            $This.Clear()

            ForEach ($Property in $This.Current.PSObject.Properties | ? Name -notmatch ^PS)
            {
                $This.Add($Property)
            }

            $This.Id    = $This.Get("DisplayVersion") | % Value
            $This.Label = "v{0}" -f $This.Id
        }
        Add([Object]$Property)
        {
            $This.Property += $this.GenericProperty($This.Property.Count,$Property)
        }
        [Object] Get([String]$Name)
        {
            Return $This.Property | ? Name -eq $Name
        }
        [String] ToString()
        {
            Return "<FESystem.CurrentVersion>"
        }
    }

    Enum EditionType
    {
        v1507
        v1511
        v1607
        v1703
        v1709
        v1803
        v1903
        v1909
        v2004
        v20H2
        v21H1
        v21H2
        v22H2
    }

    Class EditionItem
    {
        [UInt32]       $Index
        [String]        $Name
        [UInt32]       $Build
        [String]    $Codename
        [String] $Description
        EditionItem([String]$Name)
        {
            $This.Index = [UInt32][EditionType]::$Name
            $This.Name  = [EditionType]::$Name
        }
        Inject([String]$Line)
        {
            $Split            = $Line -Split ","
            $This.Build       = $Split[0]
            $This.Codename    = $Split[1]
            $This.Description = $Split[2]
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class EditionController
    {
        [Object] $Current
        [Object] $Output
        EditionController([Object]$Current)
        {
            $This.Refresh()
            $This.Current = $This.Output | ? Name -eq $Current.Label
        }
        [Object] EditionItem([String]$Name)
        {
            Return [EditionItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()
            
            ForEach ($Name in [System.Enum]::GetNames([EditionType]))
            {
                $Item = $This.EditionItem($Name)
                $Line = Switch ($Item.Name)
                {
                    v1507 { "10240,Threshold 1,Release To Manufacturing"  }
                    v1511 { "10586,Threshold 2,November Update"           }
                    v1607 { "14393,Redstone 1,Anniversary Update"         }
                    v1703 { "15063,Redstone 2,Creators Update"            }
                    v1709 { "16299,Redstone 3,Fall Creators Update"       }
                    v1803 { "17134,Redstone 4,April 2018 Update"          }
                    v1809 { "17763,Redstone 5,October 2018 Update"        }
                    v1903 { "18362,19H1,May 2019 Update"                  }
                    v1909 { "18363,19H2,November 2019 Update"             }
                    v2004 { "19041,20H1,May 2020 Update"                  }
                    v20H2 { "19042,20H2,October 2020 Update"              }
                    v21H1 { "19043,21H1,May 2021 Update"                  }
                    v21H2 { "19044,21H2,November 2021 Update"             }
                    v22H2 { "19045,22H2,2022 Update"                      }
                }

                $Item.Inject($Line)
                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FESystem.Edition[Controller]>"
        }
    }

    Class Snapshot
    {
        [String]               $Start
        [String]        $ComputerName
        [String]                $Name
        [String]         $DisplayName
        Hidden [UInt32] $PartOfDomain
        [String]                 $DNS
        [String]             $NetBIOS
        [String]            $Hostname
        [String]            $Username
        [Object]           $Principal
        [UInt32]             $IsAdmin
        [String]             $Caption
        [Version]            $Version
        [String]           $ReleaseID
        [UInt32]               $Build
        [String]         $Description
        [String]                 $SKU
        [String]             $Chassis
        [String]                $Guid
        [UInt32]            $Complete
        [String]             $Elapsed
        [String] ToString()
        {
            Return "<FESystem.Snapshot>"
        }
        [UInt32] CheckAdmin()
        {
            $Collect = ForEach ($Item in "Administrator","Administrators")
            {
                $This.Principal.IsInRole($Item)
            }

            Return $True -in $Collect
        }
    }

    # // ===================
    # // | HotFix Controls |
    # // ===================

    Class HotFixItem
    {
        [UInt32]         $Index
        Hidden [Object] $HotFix
        [String]        $Source
        [String]      $HotFixID
        [String]   $Description
        [String]   $InstalledBy
        [String]   $InstalledOn
        Hidden [String] $Status
        HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            $This.Index       = $Index
            $This.HotFix      = $HotFix
            $This.Source      = $HotFix.PSComputerName
            $This.Description = $HotFix.Description
            $This.HotFixID    = $HotFix.HotFixID
            $This.InstalledBy = $HotFix.InstalledBy
            $This.InstalledOn = ([DateTime]$HotFix.InstalledOn).ToString("MM/dd/yyyy")

            $This.SetStatus()
        }
        SetStatus()
        {
            $This.Status      = "[HotFix]: {0} {1}" -f $This.InstalledOn, $This.HotFixId
        }
        [String] ToString()
        {
            Return "<FESystem.HotFix[Item]>"
        }
    }

    Class HotFixController : GenericList
    {
        HotFixController([String]$Name) : Base($Name)
        {

        }
        [Object[]] GetObject()
        {
            Return Get-HotFix | Sort-Object InstalledOn
        }
        [Object] HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            Return [HotFixItem]::New($Index,$Hotfix)
        }
        [Object] New([Object]$Hotfix)
        {
            $Item = $This.HotFixItem($This.Output.Count,$HotFix)
            $Item.SetStatus()
            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($HotFix in $This.GetObject())
            {
                $Item = $This.New($HotFix)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.HotFix[Controller]>"
        }
    }

    # // =============================
    # // | Optional Feature Controls |
    # // =============================

    Enum FeatureStateType
    {
        Disabled
        DisabledWithPayloadRemoved
        Enabled
    }

    Class FeatureStateSlot
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        FeatureStateSlot([String]$Name)
        {
            $This.Index = [UInt32][FeatureStateType]::$Name
            $This.Name  = [FeatureStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class FeatureStateList
    {
        [Object] $Output
        FeatureStateList()
        {
            $This.Refresh()
        }
        [Object] FeatureStateSlot([String]$Name)
        {
            Return [FeatureStateSlot]::New($Name)
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([FeatureStateType]))
            {
                $Item             = $This.FeatureStateSlot($Name)
                $Item.Label       = @("[_]","[X]","[+]")[$Item.Index]
                $Item.Description = Switch ($Name)
                {
                    Disabled                   { "Feature is disabled"                     }
                    DisabledWithPayloadRemoved { "Feature is disabled, payload is removed" }
                    Enabled                    { "Feature is enabled"                      }
                }

                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FESystem.FeatureState[List]>"
        }
    }

    Class FeatureItem
    {
        [UInt32]                   $Index
        Hidden [Object]          $Feature
        [String]             $FeatureName
        [Object]                   $State
        [String]             $Description
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [String]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        [UInt32]                 $Profile
        [Object]                  $Target
        Hidden [String]           $Status
        FeatureItem([UInt32]$Index,[Object]$Feature)
        {
            $This.Index            = $Index
            $This.Feature          = $Feature
            $This.FeatureName      = $Feature.FeatureName
            $This.Path             = $Feature.Path
            $This.Online           = $Feature.Online
            $This.WinPath          = $Feature.WinPath
            $This.SysDrivePath     = $Feature.SysDrivePath
            $This.RestartNeeded    = $Feature.RestartNeeded
            $This.LogPath          = $Feature.LogPath
            $This.ScratchDirectory = $Feature.ScratchDirectory
            $This.LogLevel         = $Feature.LogLevel
        }
        SetStatus()
        {
            $This.Status = "[Feature]: {0} {1}" -f $This.State.Label, $This.FeatureName
        }
        [String] ToString()
        {
            Return "<FESystem.Feature[Item]>"
        }
    }

    Class FeatureController : GenericList
    {
        Hidden [Object] $State
        FeatureController([String]$Name) : Base($Name)
        {
            $This.State   = $This.FeatureStateList()
        }
        [Object[]] GetObject()
        {
            Return Get-WindowsOptionalFeature -Online | Sort-Object FeatureName 
        }
        [Object] FeatureStateList()
        {
            Return [FeatureStateList]::New()
        }
        [Object] FeatureItem([UInt32]$Index,[Object]$Feature)
        {
            Return [FeatureItem]::New($Index,$Feature)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Feature in $This.GetObject())
            {
                $Item = $This.New($Feature)

                $This.Add($Item)
            }
        }
        [Object] New([Object]$Feature)
        {
            $Item             = $This.FeatureItem($This.Output.Count,$Feature)
            $Item.State       = $This.State.Output | ? Name -eq $Feature.State
            $Item.Description = Switch ($Item.FeatureName)
            {
                AppServerClient
                {
                    "Apparently this is related to [Parallels], which is a virtualization pack"+
                    "age related to MacOS."
                }
                Client-DeviceLockdown
                {
                    "Allows supression of Windows elements that appear when Windows starts or r"+
                    "esumes."
                }
                Client-EmbeddedBootExp
                {
                    "Allows supression of Windows elements that appear when Windows starts or re"+
                    "sumes."
                }
                Client-EmbeddedLogon
                {
                    "Allows use of custom logon feature to suppress Windows 10 UI elements relat"+
                    "ed to (Welcome/shutdown) screen."
                }
                Client-EmbeddedShellLauncher
                {
                    "Enables OEMs to set a (classic/non-UWP) app as the [system shell]."
                }
                ClientForNFS-Infrastructure
                {
                    "Client for (NFS/Network File System) allowing file transfers between (W"+
                    "indows Server/UNIX)."
                }
                Client-KeyboardFilter
                {
                    "Enables controls that you can use to suppress undesirable key presses or ke"+
                    "y combinations."
                }
                Client-ProjFS
                {
                    "Windows Projected File System (ProjFS) allows user-mode application provi"+
                    "der(s) to project hierarchical data from a backing data store into the fi"+
                    "le system, making it [appear] as files and directories in the file system."
                }
                Client-UnifiedWriteFilter
                {
                    "Helps to protect device configuration by (intercepting/redirecting) any wri"+
                    "tes to the drive (app installations, settings changes, saved data) to a vir"+
                    "tual overlay."
                }
                Containers
                {
                    "Required to provide (services/tools) to (create/manage) [Windows Server"+
                    " Containers]."
                }
                Containers-DisposableClientVM
                {
                    "Windows Sandbox provides a lightweight desktop environment to safely run "+
                    "applications in isolation."
                }
                DataCenterBridging
                {
                    "Standards developed by IEEE for data centers."
                }
                DirectoryServices-ADAM-Client
                {
                    "(ADAM/Active Directory Application Mode)"
                }
                DirectPlay
                {
                    "DirectPlay is part of Microsoft's DirectX API. It is a network communication"+
                    " library intended for computer game development, although it can be used for"+
                    " other purposes."
                }
                HostGuardian
                {
                    "(HGS/Host Guardian Service) is the centerpiece of the guarded fabric soluti"+
                    "on. It ensures that Hyper-V hosts in the fabric are known to the [hoster/en"+
                    "terprise], running [trusted software], and [managing key protectors] for [s"+
                    "hielded VMs]."
                }
                HypervisorPlatform
                {
                    "Used for Hyper-V and/or other virtualization software, allows hardware ba"+
                    "sed virtualization components to be used."
                }
                IIS-ApplicationDevelopment
                {
                    "(IIS/Internet Information Services) for application development."
                }
                IIS-ApplicationInit
                {
                    "(IIS/Internet Information Services) for allowing application initialization."
                }
                IIS-ASP
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages)."
                }
                IIS-ASPNET
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                    "that use the .NET Framework prior to v4.5."
                }
                IIS-ASPNET45
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                    "that use .NET Framework v4.5+."
                }
                IIS-BasicAuthentication
                {
                    "(IIS/Internet Information Services) for enabling basic-authentication."
                }
                IIS-CertProvider
                {
                    "(IIS/Internet Information Services) for enabling the certificate provider."
                }
                IIS-CGI
                {
                    "(IIS/Internet Information Services) for enabling (CGI/Common Gateway Interface)."
                }
                IIS-ClientCertificateMappingAuthentication
                {
                    "(IIS/Internet Information Services) for enabling client-based certificate "+
                    "mapping authentication."
                }
                IIS-CommonHttpFeatures
                {
                    "(IIS/Internet Information Services) for common HTTP features."
                }
                IIS-CustomLogging
                {
                    "(IIS/Internet Information Services) for enabling custom logging."
                }
                IIS-DefaultDocument
                {
                    "(IIS/Internet Information Services) for allowing default (website/document) "+
                    "model."
                }
                IIS-DigestAuthentication
                {
                    "(IIS/Internet Information Services) for enabling digest authentication."
                }
                IIS-DirectoryBrowsing
                {
                    "(IIS/Internet Information Services) for allowing directory browsing to be used."
                }
                IIS-FTPExtensibility
                {
                    "(IIS/Internet Information Services) for enabling the FTP service/server ext"+
                    "ensions."
                }
                IIS-FTPServer
                {
                    "(IIS/Internet Information Services) for enabling the FTP server."
                }
                IIS-FTPSvc
                {
                    "(IIS/Internet Information Services) for enabling the FTP service."
                }
                IIS-HealthAndDiagnostics
                {
                    "(IIS/Internet Information Services) for health and diagnostics."
                }
                IIS-HostableWebCore
                {
                    "(WAS/Windows Activation Service) for the hostable web core package."
                }
                IIS-HttpCompressionDynamic
                {
                    "(IIS/Internet Information Services) for dynamic compression components."
                }
                IIS-HttpCompressionStatic
                {
                    "(IIS/Internet Information Services) for enabling static HTTP compression."
                }
                IIS-HttpErrors
                {
                    "(IIS/Internet Information Services) for handling HTTP errors."
                }
                IIS-HttpLogging
                {
                    "(IIS/Internet Information Services) for HTTP logging."
                }
                IIS-HttpRedirect
                {
                    "(IIS/Internet Information Services) for HTTP redirection, similar to [WebDAV]."
                }
                IIS-HttpTracing
                {
                    "(IIS/Internet Information Services) for tracing HTTP requests/etc."
                }
                IIS-IIS6ManagementCompatibility
                {
                    "(IIS/Internet Information Services) for compatibility with IIS6*"
                }
                IIS-IISCertificateMappingAuthentication
                {
                    "(IIS/Internet Information Services) for enabling IIS-based certificate map"+
                    "ping authentication."
                }
                IIS-IPSecurity
                {
                    "(IIS/Internet Information Services) for Internet Protocol security."
                }
                IIS-ISAPIExtensions
                {
                    "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                    "ication Programming Interface) extensions."
                }
                IIS-ISAPIFilter
                {
                    "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                    "ication Programming Interface) filters."
                }
                IIS-LegacyScripts
                {
                    "(IIS/Internet Information Services) for enabling legacy scripts."
                }
                IIS-LegacySnapIn
                {
                    "(IIS/Internet Information Services) for enabling legacy snap-ins."
                }
                IIS-LoggingLibraries
                {
                    "(IIS/Internet Information Services) for logging libraries."
                }
                IIS-ManagementConsole
                {
                    "(IIS/Internet Information Services) for enabling the management console."
                }
                IIS-ManagementScriptingTools
                {
                    "(IIS/Internet Information Services) for webserver management scripting."
                }
                IIS-ManagementService
                {
                    "(IIS/Internet Information Services) for enabling the management service."
                }
                IIS-Metabase
                {
                    "(IIS/Internet Information Services) for (metadata/metabase)."
                }
                IIS-NetFxExtensibility
                {
                    "(IIS/Internet Information Services) for .NET Framework extensibility."
                }
                IIS-NetFxExtensibility45
                {
                    "(IIS/Internet Information Services) for .NET Framework v4.5+ extensibility."
                }
                IIS-ODBCLogging
                {
                    "(IIS/Internet Information Services) for enabling (ODBC/Open Database Conne"+
                    "ctivity) logging."
                }
                IIS-Performance
                {
                    "(IIS/Internet Information Services) for performance-related components."
                }
                IIS-RequestFiltering
                {
                    "(IIS/Internet Information Services) for request-filtering."
                }
                IIS-RequestMonitor
                {
                    "(IIS/Internet Information Services) for monitoring HTTP requests."
                }
                IIS-Security
                {
                    "(IIS/Internet Information Services) for security-related functions."
                }
                IIS-ServerSideIncludes
                {
                    "(IIS/Internet Information Services) for enabling server-side includes."
                }
                IIS-StaticContent
                {
                    "(IIS/Internet Information Services) for enabling static webserver content."
                }
                IIS-URLAuthorization
                {
                    "(IIS/Internet Information Services) for authorizing (URL/Universal Resource"+
                    " Locator)(s)"
                }
                IIS-WebDAV
                {
                    "(IIS/Internet Information Services) for enabling the (WebDAV/Web Distributed"+
                    " Authoring and Versioning) interface."
                }
                IIS-WebServer
                {
                    "(IIS/Internet Information Services) [Web Server], installs the prerequisites"+
                    " to run an IIS web server."
                }
                IIS-WebServerManagementTools
                {
                    "(IIS/Internet Information Services) for webserver management tools."
                }
                IIS-WebServerRole
                {
                    "(IIS/Internet Information Services) [Web Server Role], enables the role for "+
                    "running an IIS web server."
                }
                IIS-WebSockets
                {
                    "(IIS/Internet Information Services) for enabling web-based sockets."
                }
                IIS-WindowsAuthentication
                {
                    "(IIS/Internet Information Services) for enabling Windows account authentication."
                }
                IIS-WMICompatibility
                {
                    "(IIS/Internet Information Services) for (WMI/Windows Management Instrumenta"+
                    "tion) compatibility/interop."
                }
                Internet-Explorer-Optional-amd64
                {
                    "Internet Explorer"
                }
                LegacyComponents
                {
                    "[DirectPlay] - Part of the [DirectX] application programming interface."
                }
                MediaPlayback
                {
                    "(WMP/Windows Media Player) allows media playback."
                }
                Microsoft-Hyper-V
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-All
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Hypervisor
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Management-Clients
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Management-PowerShell
                {
                    "(Hyper-V/Veridian) + [PowerShell]"
                }
                Microsoft-Hyper-V-Services
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Tools-All
                {
                    "(Hyper-V/Veridian)"
                }
                MicrosoftWindowsPowerShellV2
                {
                    "[PowerShell]"
                }
                MicrosoftWindowsPowerShellV2Root
                {
                    "[PowerShell]"
                }
                Microsoft-Windows-Subsystem-Linux
                {
                    "Installs prerequisites for installing console-based Linux vitual machines."
                }
                MSMQ-ADIntegration
                {
                    "(MSMQ/Microsoft Message Queue Server) for (AD/Active Directory) integration."
                }
                MSMQ-Container
                {
                "(MSMQ/Microsoft Message Queue Server) for enabling the container."
                }
                MSMQ-DCOMProxy
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling the (DCOM/Distributed CO"+
                    "M) proxy."
                }
                MSMQ-HTTP
                {
                    "(MSMQ/Microsoft Message Queue Server) for HTTP integration."
                }
                MSMQ-Multicast
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling multicast."
                }
                MSMQ-Server
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling the server."
                }
                MSMQ-Triggers
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling (trigger events/tasks)."
                }
                MSRDC-Infrastructure
                {
                    "(MSRDC/Microsoft Remote Desktop Client)."
                }
                MultiPoint-Connector
                {
                    "(Connector) MultiPoint Services allows multiple users to simultaneously sh"+
                    "are one computer."
                }
                MultiPoint-Connector-Services
                {
                    "(Services) MultiPoint Services allows multiple users to simultaneously sha"+
                    "re one computer."
                }
                MultiPoint-Tools
                {
                    "(Tools) MultiPoint Services allows multiple users to simultaneously share "+
                    "one computer."
                }
                NetFx3
                {
                    "(.NET Framework v3.*) This feature is needed to run applications that are wr"+
                    "itten for various versions of .NET. Windows automatically installs them when"+
                    " required."
                }
                NetFx4-AdvSrvs
                {
                    "(.NET Framework v4.*)."
                }
                NetFx4Extended-ASPNET45
                {
                    "(.NET Framework v4.*) with extensions for ASP.NET Framework v4.5+."
                }
                NFS-Administration
                {
                    "(NFS/Network File System)"
                }
                Printing-Foundation-Features
                {
                    "Allows use of (IPC/Internet Printing Client), (LPD/Line printer daemon), a"+
                    "nd (LPR/Line printer remote) for using printers over the (internet/LAN)."
                }
                Printing-Foundation-InternetPrinting-Client
                {
                    "(IPC/Internet Printing Client) helps you print files from a web browser us"+
                    "ing a (connected/shared) printer on the (internet/LAN)."
                }
                Printing-Foundation-LPDPrintService
                {
                    "(LPD/Line printer daemon) printer sharing service."
                }
                Printing-Foundation-LPRPortMonitor
                {
                    "(LPR/Line printer remote) port monitor service."
                }
                Printing-PrintToPDFServices-Features
                {
                    "Allows documents to be printed to (*.pdf) file(s)"
                }
                Printing-XPSServices-Features
                {
                    "Allows documents to be printed to (*.xps) file(s)"
                }
                SearchEngine-Client-Package
                {
                    "Windows searching & indexing."
                }
                ServicesForNFS-ClientOnly
                {
                    "Services for (NFS/Network File System) allowing file transfers between "+
                    "(Windows Server/UNIX)."
                }
                SimpleTCP
                {
                    "Collection of old command-line tools that include character generator, dayti"+
                    "me, discard, echo, etc."
                }
                SMB1Protocol
                {
                    "(SMB/Server Message Block) network protocol."
                }
                SMB1Protocol-Client
                {
                    "(SMB/Server Message Block) client network protocol."
                }
                SMB1Protocol-Deprecation
                {
                    "(SMB/Server Message Block)."
                }
                SMB1Protocol-Server
                {
                    "(SMB/Server Message Block) server network protocol."
                }
                SmbDirect
                {
                    "(SMB/Server Message Block)."
                }
                TelnetClient
                {
                    "Installs the [TELNET] legacy application."
                }
                TFTP
                {
                    "A command-line tool that can be used to transfer files via the [Trivial File"+
                    " Transfer Protocol]."
                }
                TIFFIFilter
                {
                    "Index-and-search (TIFF/Tagged Image File Format) used for Optional Charact"+
                    "er Recognition."
                }
                VirtualMachinePlatform
                {
                    "Used for Hyper-V and managing individual virtual machines."
                }
                WAS-ConfigurationAPI
                {
                    "(WAS/Windows Activation Service) for using the configuration API."
                }
                WAS-NetFxEnvironment
                {
                    "(WAS/Windows Activation Service) for using .NET Framework elements."
                }
                WAS-ProcessModel
                {
                    "(WAS/Windows Activation Service) for the process model WAS uses."
                }
                WAS-WindowsActivationService
                {
                    "(WAS/Windows Activation Service) Used for message-based applications and co"+
                    "mponents that are related to Internet Information Services (IIS)."
                }
                WCF-HTTP-Activation
                {
                    "(WCF/Windows Communication Foundation) for [HTTP Activation], used for messa"+
                    "ge-based applications and components that are related to Internet Informatio"+
                    "n Services (IIS)."
                }
                WCF-HTTP-Activation45
                {
                    "(WCF/Windows Communication Foundation) for HTTP activation that use .NET Fra"+
                    "mework v4.5+."
                }
                WCF-MSMQ-Activation45
                {
                    "(WCF/Windows Communication Foundation) for MSMQ activation that use .NET Fra"+
                    "mework v4.5+."
                }
                WCF-NonHTTP-Activation
                {
                    "Windows Communication Foundation [Non-HTTP Activation], used for message-bas"+
                    "ed applications and components that are related to Internet Information Serv"+
                    "ices (IIS)."
                }
                WCF-Pipe-Activation45
                {
                    "(WCF/Windows Communication Foundation) for named-pipe activation that use .N"+
                    "ET Framework v4.5+."
                }
                WCF-Services45
                {
                    "(WCF/Windows Communication Foundation) services that use .NET Framework v4.5+"
                }
                WCF-TCP-Activation45
                {
                    "(WCF/Windows Communication Foundation) for TCP activation that use .NET Fram"+
                    "ework v4.5+."
                }
                WCF-TCP-PortSharing45
                {
                    "(WCF/Windows Communication Foundation) for TCP port sharing that use .NET Fr"+
                    "amework v4.5+."
                }
                Windows-Defender-ApplicationGuard
                {
                    "(WDAG/Windows Defender Application Guard) uses [Hyper-V] to run [Micros"+
                    "oft Edge] in an isolated container."
                }
                Windows-Defender-Default-Definitions
                {
                    "Default [Windows Defender] definitions."
                }
                Windows-Identity-Foundation
                {
                    "A software framework for building identity-aware applications. The .NET Fram"+
                    "ework 4.5 includes a newer version of this framework."
                }
                WindowsMediaPlayer
                {
                    "(WMP/Windows Media Player) enables the integrated media player."
                }
                WorkFolders-Client
                {
                    "Windows Server role service for file servers."
                }
                Default
                {
                    "Unknown"
                }
            }

            $Item.SetStatus()

            Return $Item
        }
        [String[]] ResourceLinks()
        {
            Return "https://www.thewindowsclub.com/windows-10-optional-features-explained",
            "https://en.wikipedia.org/wiki/"
        }
        [String] ToString()
        {
            Return "<FEModule.WindowsOptionalFeature[Controller]>"
        }
    }

    # // =================
    # // | AppX Controls |
    # // =================

    Enum AppXStateType
    {
        Skip
        Unhide
        Hide
        Uninstall
        Null
    }
        
    Class AppXStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        AppXStateItem([String]$Name)
        {
            $This.Index  = [UInt32][AppXStateType]::$Name
            $This.Name   = [AppXStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
        
    Class AppXStateList
    {
        [Object] $Output
        AppXStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] AppXStateItem([String]$Name)
        {
            Return [AppXStateItem]::New($Name)
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([AppXStateType]))
            {
                $Item             = $This.AppXStateItem($Name)
                $Item.Label       = @("[_]","[+]","[ ]","[X]","[?]")[$Item.Index]
                $Item.Description = Switch ($Item.Index)
                {
                    0 { "Skip this particular AppX application."      }
                    1 { "Hide this particular AppX application."      }
                    2 { "Unhide this particular AppX application."    }
                    3 { "Uninstall this particular AppX application." }
                    4 { "Null, or not applicable."                    }
                }

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.AppXState[List]>"
        }
    }
        
    Class AppXItem
    {
        [UInt32]                   $Index
        Hidden [Object]             $AppX
        [String]             $DisplayName
        [String]             $Description
        [String]             $PackageName
        [String]                 $Version
        [String]             $PublisherID
        [Object]                   $State
        [UInt32]            $MajorVersion
        [UInt32]            $MinorVersion
        [UInt32]                   $Build
        [UInt32]                $Revision
        [UInt32]            $Architecture
        [String]              $ResourceID
        [String]         $InstallLocation
        [Object]                 $Regions
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [String]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        [UInt32]                 $Profile
        [Object]                  $Target
        Hidden [String]           $Status
        AppXItem([UInt32]$Index,[Object]$AppX)
        {
            $This.Index            = $Index
            $This.AppX             = $AppX
            $This.Version          = $AppX.Version
            $This.PackageName      = $AppX.PackageName
            $This.DisplayName      = $AppX.DisplayName
            $This.PublisherId      = $AppX.PublisherId
            $This.MajorVersion     = $AppX.MajorVersion
            $This.MinorVersion     = $AppX.MinorVersion
            $This.Build            = $AppX.Build
            $This.Revision         = $AppX.Revision
            $This.Architecture     = $AppX.Architecture
            $This.ResourceId       = $AppX.ResourceId
            $This.InstallLocation  = $AppX.InstallLocation
            $This.Regions          = $AppX.Regions
            $This.Path             = $AppX.Path
            $This.Online           = $AppX.Online
            $This.WinPath          = $AppX.WinPath
            $This.SysDrivePath     = $AppX.SysDrivePath
            $This.RestartNeeded    = $AppX.RestartNeeded
            $This.LogPath          = $AppX.LogPath
            $This.ScratchDirectory = $AppX.ScratchDirectory
            $This.LogLevel         = $AppX.LogLevel
        }
        SetStatus()
        {
            $This.Status           = "[AppX]: {0}" -f $This.DisplayName
        }
        [String] ToString()
        {
            Return "<FESystem.AppX[Item]>"
        }
    }

    Class AppXController : GenericList
    {
        Hidden [Object] $State
        AppXController([String]$Name) : Base($Name)
        {
            $This.State   = $This.AppXStateList()
        }
        [Object[]] GetObject()
        {
            Return Get-AppxProvisionedPackage -Online | Sort-Object DisplayName
        }
        [Object] AppXItem([UInt32]$Index,[Object]$AppX)
        {
            Return [AppXItem]::New($Index,$AppX)
        }
        [Object] AppXStateList()
        {
            Return [AppXStateList]::New()
        }
        [Object] New([Object]$AppX)
        {
            $Item             = $This.AppXItem($This.Output.Count,$AppX)
            $Item.Description = Switch ($Item.DisplayName)
            {
                "Microsoft.549981C3F5F10"
                {
                    "[Cortana], your personal productivity assistant, helps you stay on"+
                    " top of what matters and save time finding what you need."
                }
                "Microsoft.BingWeather"
                {
                    "[MSN Weather], get a [Microsoft Edge] on the latest weather condit"+
                    "ions, see (10-day/hourly) forecasts."
                }
                "Microsoft.DesktopAppInstaller"
                {
                    "[WinGet Package Manager], allows developers to install (*.appx/*.a"+
                    "ppxbundle) files on their [Windows PC] without (PowerShell/CMD)."
                }
                "Microsoft.GetHelp"
                {
                    "[Get-Help] command for [PowerShell], but also GUI driven help."
                }
                "Microsoft.Getstarted"
                {
                    "In order to get down to business with [Office 365], you can use th"+
                    "is to get started."
                }
                "Microsoft.HEIFImageExtension"
                {
                    "Allows users to view [HEIF images] on [Windows]."
                }
                "Microsoft.Microsoft3DViewer"
                {
                    "Allows users to (view/interact) with 3D models on your device."
                }
                "Microsoft.MicrosoftEdge.Stable"
                {
                    "[Microsoft Edge] is a [Chromium]-based web browser, which offers m"+
                    "any improvements over [Internet Explorer]."
                }
                "Microsoft.MicrosoftOfficeHub"
                {
                    "Central location for all your [Microsoft Office] apps."
                }
                "Microsoft.MicrosoftSolitaireCollection"
                {
                    "Collection of card games including [Klondike], [Spider], [FreeCell"+
                    "], [Pyramid], and [TriPeaks]."
                }
                "Microsoft.MicrosoftStickyNotes"
                {
                    "Note-taking application that allows users to create [notes], [typ"+
                    "e], [ink], or [add a picture], [text formatting], stick them to t"+
                    "he desktop, move them around freely, close them to the notes list"+
                    ", and sync them across devices and apps like [OneNote Mobile], [M"+
                    "icrosoft Launcher for Android], and [Outlook for Windows]."
                }
                "Microsoft.MixedReality.Portal"
                {
                    "Provides main Windows Mixed Reality experience in [Windows 10] ver"+
                    "sions (1709/1803) and is a key component of the [Windows 10] opera"+
                    "ting system updated via [Windows Update]."
                }
                "Microsoft.MSPaint"
                {
                    "Simple graphics editor that allows users to create and edit images"+
                    " using various tools such as brushes, pencils, shapes, text, and m"+
                    "ore."
                }
                "Microsoft.Office.OneNote"
                {
                    "OneNote is a digital note-taking app that allows users to create a"+
                    "nd organize notes, drawings, audio recordings, and more."
                }
                "Microsoft.People"
                {
                    "Contact management app that allows users to store and manage their"+
                    " contacts in one place."
                }
                "Microsoft.ScreenSketch"
                {
                    "Screen Sketch is a screen capture and annotation tool that allows "+
                    "users to take screenshots and annotate them with a pen or highligh"+
                    "ter."
                }
                "Microsoft.SkypeApp"
                {
                    "Skype is a communication app that allows users to make voice and v"+
                    "ideo calls, send instant messages, and share files with other Skyp"+
                    "e users."
                }
                "Microsoft.StorePurchaseApp"
                {
                    "[Microsoft Store Purchase] app is used to purchase apps and games "+
                    "from the [Microsoft Store]."
                }
                "Microsoft.VCLibs.140.00"
                {
                    "Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 "+
                    "nd 2019 version 14. Installs runtime components of Visual C++ Libr"+
                    "aries required to run applications developed with Visual Studio."
                }
                "Microsoft.VP9VideoExtensions"
                {
                    "VP9 Video Extensions for [Microsoft Edge]. These extensions are de"+
                    "signed to take advantage of hardware capabilities on newer devices"+
                    " and are used for streaming over the internet."
                }
                "Microsoft.Wallet"
                {
                    "Microsoft Wallet is a mobile payment and digital wallet service by"+
                    " Microsoft."
                }
                "Microsoft.WebMediaExtensions"
                {
                    "Utilities & Tools App (UWP App/Microsoft Store Edition) that exten"+
                    "s [Microsoft Edge] and [Windows] to support open source formats co"+
                    "mmonly encountered on the web."
                }
                "Microsoft.WebpImageExtension"
                {
                    "Enables viewing WebP images in [Microsoft Edge]. WebP provides (lo"+
                    "ssless/lossy) compression for images."
                }
                "Microsoft.Windows.Photos"
                {
                    "Easy to use (photo/video) management and editing application that "+
                    "integrates well with [OneDrive]."
                }
                "Microsoft.WindowsAlarms"
                {
                    "Alarm clock app that comes with [Windows] that allows setting (ala"+
                    "rms/timers/reminders) for important events."
                }
                "Microsoft.WindowsCalculator"
                {
                    "Calculator app that comes with [Windows], and provides standard, s"+
                    "cientific, and programmer calculator functionality, as well as a s"+
                    "et of converters between various units of measurement and currenci"+
                    "es."
                }
                "Microsoft.WindowsCamera"
                {
                    "Camera app that comes with [Windows], allows (taking photos/record"+
                    "ing videos) using built-in camera or an external webcam."
                }
                "Microsoft.WindowsCommunicationsApps"
                {
                    "(Email/calendar) app that comes with [Windows]."
                }
                "Microsoft.WindowsFeedbackHub"
                {
                    "App that comes with [Windows] and allows providing feedback about "+
                    "[Windows] and its features."
                }
                "Microsoft.WindowsMaps"
                {
                    "App that comes with [Windows] and allows search navigation, voice "+
                    "navigation, driving, transit, and walking directions."
                }
                "Microsoft.WindowsSoundRecorder"
                {
                    "Audio recording program included in [Windows], allows recording au"+
                    "dio for up to three hours per recording."
                }
                "Microsoft.WindowsStore"
                {
                    "Official app store for [Windows], and allowing the download of app"+
                    "s, games, music, movies, TV shows and more."
                }
                "Microsoft.Xbox.TCUI"
                {
                    "Component of the [Xbox Live] in-game experience or [Xbox TCUI], al"+
                    "lows playing games on PC, connecting with friends, and sharing gam"+
                    "ing experiences."
                }
                "Microsoft.XboxApp"
                {
                    "[Xbox Console Companion] is an app that allows you to play games o"+
                    "n your PC, connect with friends, and share your gaming experiences."
                }
                "Microsoft.XboxGameOverlay"
                {
                    "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                    "ws] that allows you to access widgets and tools without leaving yo"+
                    "ur game."
                }
                "Microsoft.XboxGamingOverlay"
                {
                    "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                    "ws] that allows you to access widgets and tools without leaving yo"+
                    "ur game."
                }
                "Microsoft.XboxIdentityProvider"
                {
                    "[Xbox Console Companion] is an app that allows you to play games o"+
                    "n your PC, connect with friends, and share your gaming experiences."
                }
                "Microsoft.XboxSpeechToTextOverlay"
                {
                    "[Xbox Game Bar], converts speech to text."
                }
                "Microsoft.YourPhone"
                {
                    "App that allows directly connecting a smartphone to a PC."
                }
                "Microsoft.ZuneMusic"
                {
                    "Zune Music is a discontinued music streaming service and software"+
                    " from Microsoft."
                }
                "Microsoft.ZuneVideo"
                {
                    "Zune Video is a discontinued video streaming service and software "+
                    "from Microsoft."
                }
                Default
                {
                    "Unknown"
                }
            }

            $Item.SetStatus()

            Return $Item
        }
        Clear()
        {
            $This.Output  = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($AppX in $This.GetObject())
            {
                $Item = $This.New($AppX)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.AppX[Controller]>"
        }
    }

    # // ========================
    # // | Application Controls |
    # // ========================

    Class ApplicationItem
    {
        [UInt32]                  $Index
        Hidden [Object]     $Application
        [String]            $DisplayName
        [String]         $DisplayVersion
        [String]                   $Type
        Hidden [String]         $Version
        Hidden [Int32]         $NoRemove
        Hidden [String]      $ModifyPath
        Hidden [String] $UninstallString
        Hidden [String] $InstallLocation
        Hidden [String]     $DisplayIcon
        Hidden [Int32]         $NoRepair
        Hidden [String]       $Publisher
        Hidden [String]     $InstallDate
        Hidden [Int32]     $VersionMajor
        Hidden [Int32]     $VersionMinor
        Hidden [String]          $Status
        ApplicationItem([UInt32]$Index,[Object]$App)
        {
            $This.Index            = $Index
            $This.Type             = @("MSI","WMI")[$App.UninstallString -imatch "msiexec"]
            $This.DisplayVersion   = @("-",$App.DisplayVersion)[!!$App.DisplayVersion]
            $This.DisplayName      = @("-",$App.DisplayName)[!!$App.DisplayName]
            $This.Version          = @("-",$App.Version)[!!$App.Version]
            $This.NoRemove         = $App.NoRemove
            $This.ModifyPath       = $App.ModifyPath
            $This.UninstallString  = $App.UninstallString
            $This.InstallLocation  = $App.InstallLocation
            $This.DisplayIcon      = $App.DisplayIcon
            $This.NoRepair         = $App.NoRepair
            $This.Publisher        = $App.Publisher
            $This.InstallDate      = $App.InstallDate
            $This.VersionMajor     = $App.VersionMajor
            $This.VersionMinor     = $App.VersionMinor
        }
        SetStatus()
        {
            $This.Status = "[Application]: [{0}] {1}" -f $This.Type, $This.DisplayName
        }
        [String] ToString()
        {
            Return "<FESystem.Application[Item]>"
        }
    }

    Class ApplicationController : GenericList
    {
        ApplicationController([String]$Name) : Base($Name)
        {

        }
        [Object] ApplicationItem([UInt32]$Index,[Object]$Application)
        {
            Return [ApplicationItem]::New($Index,$Application)
        }
        [Object] New([Object]$Application)
        {
            $Item = $This.ApplicationItem($This.Output.Count,$Application)

            $Item.SetStatus()

            Return $Item
        }
        [Object[]] GetObject()
        {
            $Item = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
            $Slot = Switch ([Environment]::GetEnvironmentVariable("Processor_Architecture"))
            {
                AMD64   { 0,1 } Default { 0 }
            }

            Return $Item[$Slot] | % { Get-ItemProperty $_ } | ? DisplayName | Sort-Object DisplayName
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Application in $This.GetObject())
            {
                $Item = $This.New($Application)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.Application[Controller]>"
        }
    }

    # // ======================
    # // | Event Log Controls |
    # // ======================

    Class EventLogProviderItem
    {
        [UInt32]           $Index
        Hidden [Object]   $Config
        [String]            $Name
        Hidden [String] $Fullname
        [Object]            $Size
        [Object]             $Max
        [String]         $Percent
        [UInt64]           $Count
        Hidden [String]   $Status
        EventLogProviderItem([UInt32]$Index,[Object]$Config)
        {
            $This.Index       = $Index
            $This.Config      = $Config
            $This.Name        = $This.Config.LogName
            $This.Fullname    = $This.Expand($This.Config.LogFilePath)
            $This.Size        = $This.ByteSize("File",$This.Config.FileSize)
            $This.Max         = $This.ByteSize("Max",$This.Config.MaximumSizeInBytes)
            $This.Percent     = "{0:n2}%" -f (($This.Size.Bytes*100)/$This.Max.Bytes)
            $This.Count       = $This.Config.RecordCount
        }
        SetStatus()
        {
            $This.Status      = "[Event Log]: ({0}) {1}" -f $This.Count, $This.Name
        }
        [String] Expand([String]$Path)
        {
            Return $Path -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [Object] ByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [ByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return "<FESystem.EventLogProvider[Item]>"
        }
    }

    Class EventLogProviderController : GenericList
    {
        EventLogProviderController([String]$Name) : Base($Name)
        {

        }
        [Object] EventLogProviderItem([UInt32]$Index,[Object]$Config)
        {
            Return [EventLogProviderItem]::New($Index,$Config)
        }
        [Object[]] GetObject()
        {
            Return Get-WinEvent -ListLog * | Sort-Object LogName
        }
        [Object] New([Object]$Config)
        {
            $Item = $This.EventLogProviderItem($This.Output.Count,$Config)

            $Item.SetStatus()
            
            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Config in $This.GetObject())
            {
                $Item = $This.New($Config)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.EventLogProvider[Controller]>"
        }
    }

    # // ===========================
    # // | Scheduled Task Controls |
    # // ===========================

    Enum ScheduledTaskStateType
    {
        Disabled
        Ready
        Running
    }

    Class ScheduledTaskStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        ScheduledTaskStateItem([String]$Name)
        {
            $This.Index = [UInt32][ScheduledTaskStateType]::$Name
            $This.Name  = [ScheduledTaskStateType]::$Name        
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ScheduledTaskStateList
    {
        [Object] $Output
        ScheduledTaskStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] ScheduledTaskStateItem([String]$Name)
        {
            Return [ScheduledTaskStateItem]::New($Name)
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ScheduledTaskStateType]))
            {
                $Item             = $This.ScheduledTaskStateItem($Name)
                $Item.Label       = @("[_]","[~]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    Disabled { "The scheduled task is currently disabled."        }
                    Ready    { "The scheduled task is enabled, and ready to run." }
                    Running  { "The scheduled task is currently running."         }
                }
        
                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ScheduledTaskState[List]>"
        }
    }

    Class ScheduledTaskItem
    {
        [UInt32]         $Index
        Hidden [Object]   $Task
        [String]          $Name
        [String]        $Author
        [Object]         $State
        [UInt32]       $Actions
        [UInt32]      $Triggers
        Hidden [String]   $Path
        Hidden [String] $Status
        ScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            $This.Index    = $Index
            $This.Task     = $Task
            $This.Author   = $This.Task.Author
            $This.Actions  = $This.Task.Actions.Count
            $This.Triggers = $This.Task.Triggers.Count
            $This.Name     = $This.Task.TaskName
            $This.Path     = $This.Task.TaskPath
        }
        SetStatus()
        {
            $This.Status   = "[Task]: {0} {1}" -f $This.State.Label, $This.Name
        }
        [String] ToString()
        {
            Return "<FESystem.ScheduledTask[Item]>"
        }
    }

    Class ScheduledTaskController : GenericList
    {
        Hidden [Object] $State
        ScheduledTaskController([String]$Name) : Base($Name)
        {
            $This.State  = $This.ScheduledTaskStateList()
        }
        [Object] ScheduledTaskStateList()
        {
            Return [ScheduledTaskStateList]::New()
        }
        [Object[]] GetObject()
        {
            Return Get-ScheduledTask
        }
        [Object] GetScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            Return [ScheduledTaskItem]::New($Index,$Task)
        }
        [Object] New([Object]$Task)
        {
            $Item       = $This.GetScheduledTaskItem($This.Output.Count,$Task)           
            $Item.State = $This.State.Output | ? Name -eq $Task.State

            $Item.SetStatus()

            Return $Item
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Task in $This.GetObject())
            {
                $Item = $This.New($Task)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.ScheduledTask[Controller]>"
        }
    }

    # // ======================
    # // | Processor Controls |
    # // ======================

    Class ProcessorItem
    {
        [UInt32]            $Index
        Hidden [Object] $Processor
        [String]     $Manufacturer
        [String]             $Name
        [String]          $Caption
        [UInt32]            $Cores
        [UInt32]             $Used
        [UInt32]          $Logical
        [UInt32]          $Threads
        [String]      $ProcessorId
        [String]         $DeviceId
        [UInt32]            $Speed
        Hidden [String]    $Status
        ProcessorItem([UInt32]$Index,[Object]$Processor)
        {
            $This.Index        = $Index
            $This.Processor    = $Processor
            $This.Manufacturer = Switch -Regex ($Processor.Manufacturer) 
            {
            Intel { "Intel" } Amd { "AMD" } Default { $Processor.Manufacturer }
            }
            $This.Name         = $Processor.Name -Replace "\s+"," "
            $This.Caption      = $Processor.Caption
            $This.Cores        = $Processor.NumberOfCores
            $This.Used         = $Processor.NumberOfEnabledCore
            $This.Logical      = $Processor.NumberOfLogicalProcessors 
            $This.Threads      = $Processor.ThreadCount
            $This.ProcessorID  = $Processor.ProcessorId
            $This.DeviceID     = $Processor.DeviceID
            $This.Speed        = $Processor.MaxClockSpeed
        }
        SetStatus()
        {
            $This.Status       = "[Processor]: ({0}) {1}" -f $This.Index, $This.Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ProcessorController : GenericList
    {
        ProcessorController([Switch]$Flags,[String]$Name) : Base($Flags,$Name)
        {

        }
        [Object[]] GetObject()
        {
            Return Get-CimInstance Win32_Processor
        }
        [Object] ProcessorItem([UInt32]$Index,[Object]$Processor)
        {
            Return [ProcessorItem]::New($Index,$Processor)
        }
        [Object] New([Object]$Processor)
        {
            $Item = $This.ProcessorItem($This.Output.Count,$Processor)

            $Item.SetStatus()

            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Processor in $This.GetObject())
            {
                $Item = $This.New($Processor)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.Processor[Controller]>"
        }
    }

    # // =================
    # // | Disk Controls |
    # // =================

    Class PartitionItem
    {
        [UInt32]            $Index
        Hidden [Object] $Partition
        Hidden [String]     $Label
        [String]             $Type
        [String]             $Name
        [Object]             $Size
        [UInt32]             $Boot
        [UInt32]          $Primary
        [UInt32]             $Disk
        [UInt32]        $PartIndex
        PartitionItem([UInt32]$Index,[Object]$Partition)
        {
            $This.Index      = $Index
            $This.Partition  = $Partition
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.Size       = $This.GetSize($Partition.Size)
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.PartIndex  = $Partition.Index
        }
        [Object] GetSize([UInt64]$Bytes)
        {
            Return [ByteSize]::New("Partition",$Bytes)
        }
        [String] ToString()
        {
            Return "<FESystem.Partition[Item]>"
        }
    }

    Class PartitionList : GenericList
    {
        PartitionList([Switch]$Flags,[String]$Name) : base($Name)
        {
            
        }
    }

    Class VolumeItem
    {
        [UInt32]            $Index
        Hidden [Object]     $Drive
        Hidden [Object] $Partition
        Hidden [String]     $Label
        [UInt32]             $Rank
        [String]          $DriveID
        [String]      $Description
        [String]       $Filesystem
        [String]       $VolumeName
        [String]     $VolumeSerial
        [Object]             $Size
        [Object]        $Freespace
        [Object]             $Used
        VolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
        {
            $This.Index             = $Index
            $This.Drive             = $Drive
            $This.Partition         = $Partition
            $This.DriveID           = $Drive.Name
            $This.Description       = $Drive.Description
            $This.Filesystem        = $Drive.Filesystem
            $This.VolumeName        = $Drive.VolumeName
            $This.VolumeSerial      = $Drive.VolumeSerialNumber
            $This.Size              = $This.GetSize("Total",$Drive.Size)
            $This.Freespace         = $This.GetSize("Free",$Drive.Freespace)
            $This.Used              = $This.GetSize("Used",($This.Size.Bytes - $This.Freespace.Bytes))
        }
        [Object] GetSize([String]$Name,[UInt64]$Bytes)
        {
            Return [ByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return "<FESystem.Volume[Item]>"
        }
    }

    Class VolumeList : GenericList
    {
        VolumeList([Switch]$Flags,[String]$Name) : base($Name)
        {
            
        }
    }

    Class DiskItem
    {
        [UInt32]             $Index
        Hidden [Object]  $DiskDrive
        [String]              $Disk
        [String]             $Model
        [String]            $Serial
        [String]    $PartitionStyle
        [String]  $ProvisioningType
        [String] $OperationalStatus
        [String]      $HealthStatus
        [String]           $BusType
        [String]          $UniqueId
        [String]          $Location
        [Object]         $Partition
        [Object]            $Volume
        Hidden [String]     $Status
        DiskItem([Object]$Disk)
        {
            $This.Index             = $Disk.Index
            $This.DiskDrive         = $Disk
            $This.Disk              = $Disk.DeviceId
            $This.Partition         = $This.New("Partition")
            $This.Volume            = $This.New("Volume")
        }
        MsftDisk([Object]$MsftDisk)
        {
            $This.Model             = $MsftDisk.Model
            $This.Serial            = $MsftDisk.SerialNumber -Replace "^\s+",""
            $This.PartitionStyle    = $MsftDisk.PartitionStyle
            $This.ProvisioningType  = $MsftDisk.ProvisioningType
            $This.OperationalStatus = $MsftDisk.OperationalStatus
            $This.HealthStatus      = $MsftDisk.HealthStatus
            $This.BusType           = $MsftDisk.BusType
            $This.UniqueId          = $MsftDisk.UniqueId
            $This.Location          = $MsftDisk.Location
        }
        [String] GetSize()
        {
            $Size = 0
            ForEach ($Partition in $This.Partition)
            {
                $Size = $Size + $Partition.Size.Bytes
            }

            Return "{0:n2} GB" -f ($Size/1GB)
        }
        SetStatus()
        {
            $This.Status            = "[Disk]: ({0}) {1} {2}" -f $This.Index, $This.Model, $This.GetSize()
        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Partition { [PartitionList]::New($False,"Partition") }
                Volume    {    [VolumeList]::New($False,"Volume")    }
            }

            Return $Item
        }
        [String] ToString()
        {
            Return "<FESystem.Disk[Item]>"
        }
    }

    Class DiskController : GenericList
    {
        DiskController([Switch]$Flags,[String]$Name) : Base($Flags,$Name)
        {

        }
        Refresh()
        {
            $DiskDrive         = $This.Get("DiskDrive")
            $MsftDisk          = $This.Get("MsftDisk")
            $DiskPartition     = $This.Get("DiskPartition")
            $LogicalDisk       = $This.Get("LogicalDisk")
            $LogicalDiskToPart = $This.Get("LogicalDiskToPart")

            ForEach ($Drive in $DiskDrive | ? MediaType -match Fixed)
            {
                # [Disk Template]
                $Disk     = $This.DiskItem($Drive)

                # [MsftDisk]
                $Msft     = $MsftDisk | ? Number -eq $Disk.Index
                If ($Msft)
                {
                    $Disk.MsftDisk($Msft)
                }

                # [Partitions]
                ForEach ($Partition in $DiskPartition | ? DiskIndex -eq $Disk.Index)
                {
                    $Disk.Partition.Add($This.PartitionItem($Disk.Partition.Count,$Partition))
                }

                # [Volumes]
                ForEach ($Logical in $LogicalDiskToPart | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name })
                {
                    $Drive      = $LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                    $Partition  = $DiskPartition | ?     Name -eq $Logical.Antecedent.DeviceID
                    If ($Drive -and $Partition)
                    {
                        $Disk.Volume.Add($This.VolumeItem($Disk.Volume.Count,$Drive,$Partition))
                    }
                }

                $This.Output += $Disk
            }
        }
        [Object[]] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                DiskDrive         { Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed          }
                MsftDisk          { Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage }
                DiskPartition     { Get-CimInstance Win32_DiskPartition                                 }
                LogicalDisk       { Get-CimInstance Win32_LogicalDisk                                   }
                LogicalDiskToPart { Get-CimInstance Win32_LogicalDiskToPartition                        }
            }

            Return $Item
        }
        [Object] New([Object]$Disk)
        {
            $Item = $This.DiskItem($Disk)

            Return $Item
        }
        [Object] DiskItem([Object]$Disk)
        {
            Return [DiskItem]::New($Disk)
        }
        [Object] PartitionItem([UInt32]$Index,[Object]$Partition)
        {
            Return [PartitionItem]::New($Index,$Partition)
        }
        [Object] VolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
        {
            Return [VolumeItem]::New($Index,$Drive,$Partition)
        }
        [String] ToString()
        {
            Return "<FESystem.Disk[Controller]>"
        }
    }

    # // ====================
    # // | Network Controls |
    # // ====================

    Class NetworkItem
    {
        [UInt32]            $Index
        Hidden [Object] $Interface
        [String]             $Name
        [UInt32]            $State
        [String]        $IPAddress
        [String]       $SubnetMask
        [String]          $Gateway
        [String]        $DnsServer
        [String]       $DhcpServer
        [String]       $MacAddress
        Hidden [String]    $Status
        NetworkItem([UInt32]$Index,[Object]$Interface)
        {
            $This.Index               = $Index
            $This.Name                = $Interface.Description
            $This.State               = $Interface.IPEnabled
            Switch ($This.State)
            {
                0
                {
                    $This.IPAddress   = "-"
                    $This.SubnetMask  = "-"
                    $This.Gateway     = "-"
                    $This.DnsServer   = "-"
                    $This.DhcpServer  = "-"
                }
                1
                {
                    $This.IPAddress   = $this.Ip($Interface.IPAddress)
                    $This.SubnetMask  = $This.Ip($Interface.IPSubnet)
                    If ($Interface.DefaultIPGateway)
                    {
                        $This.Gateway = $This.Ip($Interface.DefaultIPGateway)
                    }

                    $This.DnsServer   = ($Interface.DnsServerSearchOrder | % { $This.Ip($_) }) -join ", "
                    $This.DhcpServer  = $This.Ip($Interface.DhcpServer)
                }     
            }

            $This.MacAddress          = ("-",$Interface.MacAddress)[!!$Interface.MacAddress]
        }
        SetStatus()
        {
            $This.Status = "[Network]: [{0}] {1}" -f @(" ","+")[$This.State], $This.Name
        }
        [String] Ip([Object]$Property)
        {
            Return $Property | ? {$_ -match "(\d+\.){3}\d+"}
        }
        [String] ToString()
        {
            Return "<FESystem.Network[Item]>"
        }
    }

    Class NetworkController : GenericList
    {
        NetworkController([Switch]$Flags,[String]$Name) : Base($Flags,$Name)
        {

        }
        [Object[]] GetObject()
        {
            Return Get-CimInstance Win32_NetworkAdapterConfiguration
        }
        [Object] NetworkItem([UInt32]$Index,[Object]$Network)
        {
            Return [NetworkItem]::New($Index,$Network)
        }
        [Object] New([Object]$Network)
        {
            $Item = $This.NetworkItem($This.Output.Count,$Network)
            
            $Item.SetStatus()

            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Network in $This.GetObject())
            {
                $This.Add($Network)
            }
        }
        [String] ToString()
        {
            Return "<FESystem.Network[Controller]>"
        }
    }

    # // =============================
    # // | Services Controller Types |
    # // =============================

    Enum ServicePreferenceSlotType
    {
        Bypass
        Display
        Miscellaneous
        Development
        LoggingBackup
    }

    Class ServicePreferenceSlotItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        ServicePreferenceSlotItem([String]$Name)
        {
            $This.Index = [UInt32][ServicePreferenceSlotType]::$Name
            $This.Name  = [ServicePreferenceSlotType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ServicePreferenceSlotList
    {
        [Object] $Output
        ServicePreferenceSlotList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] ServicePreferenceSlotItem([String]$Name)
        {
            Return [ServicePreferenceSlotItem]::New($Name)
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ServicePreferenceSlotType]))
            {
                $Item             = $This.ServicePreferenceSlotItem($Name)
                $Item.Description = Switch ($Item.Index)
                {
                    0 { "For skipping certain OS limitations" }
                    1 { "Hides/displays certain services"     }
                    2 { "Options w/ their own context"        }
                    3 { "Specific options for development"    }
                    4 { "Logging/backup options"              }
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        [String] ToString()
        {
            Return "<FEModule.ServicePreferenceSlot[List]>"
        }
    }

    Class ServicePreferenceOptionItem
    {
        [UInt32]       $Index
        [UInt32]        $Rank
        [UInt32]        $Type
        [String]        $Name
        [String] $Description
        [UInt32]       $Value
        ServicePreferenceOptionItem([UInt32]$Index,[UInt32]$Rank,[UInt32]$Type,[String]$Name,[String]$Description)
        {
            $This.Index       = $Index
            $This.Rank        = $Rank
            $This.Type        = $Type
            $This.Name        = $Name
            $This.Description = $Description
        }
        SetValue([UInt32]$Value)
        {
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return "<FEModule.ServicePreferenceOption[Item]>"
        }
    }

    Class ServicePreferenceOptionList
    {
        [Object] $Output
        ServicePreferenceOptionList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] ServicePreferenceOptionItem(
        [UInt32]       $Index,
        [UInt32]        $Rank,
        [UInt32]        $Type,
        [String]        $Name,
        [String] $Description)
        {
            Return [ServicePreferenceOptionItem]::New($Index,
                                                    $Rank,
                                                    $Type,
                                                    $Name,
                                                    $Description)
        }
        Refresh()
        {
            $This.Clear()

            # Development
            (0,0,"DevErrors"        , "Diagnostic output [On Error]"),
            (1,0,"DevLog"           , "Enable development logging"),
            (2,0,"DevConsole"       , "Enable console"),
            (3,0,"DevReport"        , "Enable diagnostic") | % { 

                $This.Add($_[0],$_[1],$_[2],$_[3])
            }

            # Bypass
            (0,1,"BypassBuild"      , "Skip build/version check"),
            (1,1,"BypassEdition"    , "Override edition [Home/Pro/Server]"),
            (2,1,"BypassLaptop"     , "Enable laptop tweaks") | % { 

                $This.Add($_[0],$_[1],$_[2],$_[3])
            }

            # Display
            (0,2,"DisplayActive"    , "Display [Active] services"),
            (1,2,"DisplayInactive"  , "Display [Inactive] services"),
            (2,2,"DisplaySkipped"   , "Display [Skipped] services") | % { 

                $This.Add($_[0],$_[1],$_[2],$_[3])
            }

            # Miscellaneous
            (0,3,"MiscSimulate"     , "Simulate changes [Dry Run]"),
            (1,3,"MiscXbox"         , "Skip all [Xbox] Services"),
            (2,3,"MiscChange"       , "Allow changing service [State]"),
            (3,3,"MiscStopDisabled" , "Stop [disabled] service(s)") | % { 

                $This.Add($_[0],$_[1],$_[2],$_[3])
            }

            # Logging
            (0,4,"LogService"       , "Log service events to [(*.log) file]"),
            (1,4,"LogScript"        , "Log script events to [(*.log) file]"),
            (2,4,"BackupRegistry"   , "Backup registry to [(*.reg) file]"),
            (3,4,"BackupConfig"     , "Backup service configuration to [(*.csv) file]") | % {

                $This.Add($_[0],$_[1],$_[2],$_[3])
            }

        }
        Add([UInt32]$Rank,[UInt32]$Type,[String]$Name,[String]$Description)
        {
            $This.Output += $This.ServicePreferenceOptionItem($This.Output.Count,
                                                            $Rank,
                                                            $Type,
                                                            $Name,
                                                            $Description)
        }
        [String] ToString()
        {
            Return "<FEModule.ServicePreferenceOption[List]>"
        }
    }

    Enum ServiceStateType
    {
        Running
        Stopped
    }

    Class ServiceStateSlot
    {
        [UInt32]       $Index
        [String]        $Type
        [String]       $Label
        [String] $Description
        ServiceStateSlot([String]$Type)
        {
            $This.Type  = [ServiceStateType]::$Type
            $This.Index = [UInt32][ServiceStateType]::$Type
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
            $This.Refresh()
        }
        [Object] ServiceStateSlot([String]$Type)
        {
            Return [ServiceStateSlot]::New($Type)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ServiceStateType]))
            {
                $Item             = $This.ServiceStateSlot($Name)
                $Item.Label       = @("[+]","[ ]")[$Item.Index]
                $Item.Description = Switch ($Name)
                {
                    Running  { "The service is currently running"     }
                    Stopped  { "The service is NOT currently running" }
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Item)
        {   
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStateType]::$Type]
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceState[List]>"
        }
    }

    Enum ServiceStartModeType
    {
        Skip
        Disabled
        Manual
        Auto
        AutoDelayed
    }

    Class ServiceStartModeSlot
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        ServiceStartModeSlot([String]$Type)
        {
            $This.Type  = [ServiceStartModeType]::$Type
            $This.Index = [UInt32][ServiceStartModeType]::$Type
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
            $This.Refresh()
        }
        [Object] ServiceStartModeSlot([String]$Type)
        {
            Return [ServiceStartModeSlot]::New($Type)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Type in [System.Enum]::GetNames([ServiceStartModeType]))
            {
                $Item             = $This.ServiceStartModeSlot($Type)
                $Item.Description = Switch ($Type)
                {
                    Skip        { "The service is skipped"                           }
                    Disabled    { "The service is totally disabled"                  }
                    Manual      { "The service requires a manual start"              }
                    Auto        { "The service automatically starts"                 }
                    AutoDelayed { "The service automatically starts, but is delayed" } 
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStartModeType]::$Type]
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceStartMode[List]>"
        }
    }
	
	Enum ServiceProfileType
    {
        HomeMax
        HomeMin
        ProMax
        ProMin
        DesktopSafeMax
        DesktopSafeMin
        DesktopTweakedMax
        DesktopTweakedMin
        LaptopSafeMax
        LaptopSafeMin
    }

    Class ServiceProfileItem
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        ServiceProfileItem([String]$Type)
        {
            $This.Type  = [ServiceProfileType]::$Type
            $This.Index = [UInt32][ServiceProfileType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ServiceProfileList
    {
        [Object] $Output
        ServiceProfileList()
        {
            $This.Output = @( )
            ForEach ($Name in [System.Enum]::GetNames([ServiceProfileType]))
            {
                $Item             = [ServiceProfileItem]::New($Name)
                $Item.Description = Switch ($Name)
                {
                    HomeMax           { "Windows (10|11) Home, Default/Maximum" }
                    HomeMin           { "Windows (10|11) Home, Default/Minimum" }
                    ProMax            { "Windows (10|11) Pro, Default/Maximum"  }
                    ProMin            { "Windows (10|11) Pro, Default/Minimum"  }
                    DesktopSafeMax    { "Desktop (General), Safe Maximum"       }
                    DesktopSafeMin    { "Desktop (General), Safe Minimum"       }
                    DesktopTweakedMax { "Desktop (General), Tweaked Maximum"    }
                    DesktopTweakedMin { "Desktop (General), Tweaked Minimum"    }
                    LaptopSafeMax     { "Laptop (General), Safe Maximum"        }
                    LaptopSafeMin     { "Laptop (General), Safe Minimum"        }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceProfile[List]>"
        }
    }

    Enum ServiceXboxType
    {
        XblAuthManager
        XblGameSave
        XboxNetApiSvc
        XboxGipSvc
        xbgm
    }

    Enum ServiceNetTCPType
    {
        NetMsmqActivator
        NetPipeActivator
        NetTcpActivator
    }

    Enum ServicePidType
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

    Enum ServiceCommonType
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

    Class ServiceFilterItem
    {
        [UInt32] $Index
        [String]  $Type
        [String]  $Name
        [UInt32] $Value
        ServiceFilterItem([UInt32]$Index,[String]$Type,[String]$Name)
        {
            $This.Index    = $Index
            $This.Type     = $Type
            $This.Name     = $Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ServiceFilterList
    {
        [Object] $Output
        ServiceFilterList()
        {
            $This.Output = @( )
            $ProcessID   = $This.GetProcessId()

            ForEach ($Item in [System.Enum]::GetNames([ServiceXboxType]))
            {
                $This.Add("Xbox",$Item) 
            }

            ForEach ($Item in [System.Enum]::GetNames([ServiceNetTCPType]))
            { 
                $This.Add("NetTCP",$Item) 
            }

            ForEach ($Item in [System.Enum]::GetNames([ServicePidType]))
            {
                $This.Add("Pid","$Item`_$ProcessID")
            }

            ForEach ($Item in [System.Enum]::GetNames([ServiceCommonType]))
            { 
                $This.Add("Common",$Item)
            }
        }
        [String] GetProcessId()
        {
            Return (Get-Service | ? ServiceType -eq 224)[-1].Name.Split("_")[1]
        }
        [Object] ServiceFilterItem([UInt32]$Index,[String]$Type,[String]$Name)
        {
            Return [ServiceFilterItem]::New($Index,$Type,$Name)
        }
        Add([String]$Type,[String]$Name)
        {
            $This.Output += $This.ServiceFilterItem($This.Output.Count,$Type,$Name)
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceFilter[List]>"
        }
    }

    # // =============================
    # // | Service controller assets |
    # // =============================

    Class ServiceSubcontroller
    {
        [Object] $StartMode
        [Object]     $State
        ServiceSubcontroller()
        {
            $This.StartMode = $This.New("Start")
            $This.State     = $This.New("State")
        }
        [Object] New([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Start { [ServiceStartModeList]::New() }
                State {     [ServiceStateList]::New() }
            }

            Return $Item
        }
        Load([Object]$Service)
        {
            $Service.StartMode = $This.StartMode.Get($Service.Wmi.StartMode)
            $Service.State     = $This.State.Get($Service.Wmi.State)
        }
        [String] ToString()
        {
            Return "<FEModule.Service[Subcontroller]>"
        }
    }

    Class ServiceProfile
    {
        [String]      $Name
        [UInt32[]] $Profile
        ServiceProfile([String]$Name,[String]$Value)
        {
            $This.Name    = $Name
            $This.Profile = $Value -Split ","
        }
        ServiceProfile([Switch]$Flag,[String]$Name,[UInt32]$Value)
        {
            $This.Name    = $Name
            $This.Profile = @($Value)*10
        }
        [String] ToString()
        {
            Return "<FEModule.Service[Profile]>"
        }
    }

    Class ServiceTemplate
    {
        [UInt32]              $Index
        Hidden [Object]         $Wmi
        [String]               $Name 
        [UInt32[]]          $Profile 
        [Object]          $StartMode
        [Object]             $Target
        [UInt32]              $Scope
        [UInt32]              $Match
        [Object]              $State
        [UInt32]   $DelayedAutoStart
        [String]        $DisplayName
        [String]           $PathName 
        [String]        $Description
        Hidden [String]      $Status
        ServiceTemplate([Int32]$Index,[Object]$Wmi)
        {
            $This.Index              = $Index
            $This.Wmi                = $Wmi
            $This.Name               = $Wmi.Name
            $This.DelayedAutoStart   = $Wmi.DelayedAutoStart
            $This.DisplayName        = $Wmi.DisplayName
            $This.PathName           = $Wmi.PathName
            $This.Description        = $Wmi.Description
        }
        SetStatus()
        {
            $This.Status             = "[Service]: [{0}] {1}" -f $This.State.Label, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.Service[Template]>"
        }
    }

    Class ServiceController
    {
        Hidden [Object] $Console
        [UInt32]           $Slot
        [Object]            $Sub
        [Object]         $Config
        [Object]         $Output
        ServiceController([Object]$Console)
        {
            $This.Console  = $Console
            $This.Sub      = $This.GetServiceSubcontroller()
            $This.Config   = $This.GetServiceConfig()
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Object in $This.GetWmiService())
            {
                $Item                  = $This.GetServiceTemplate($This.Output.Count,$Object)
                $Item.Scope            = $Item.Name -in $This.Config.Name
                $This.Load($Item)
                $Item.Profile          = Switch ($Item.Scope)
                {
                    0
                    {
                        @($Item.StartMode.Index) * 10
                    }
                    1
                    {
                        $This.Config | ? Name -eq $Item.Name | % Profile
                    }
                }

                $Item.Target           = $Item.StartMode

                $Item.SetStatus()

                $This.Update($Item.StartMode.Index,$Item.Status)

                $This.Output          += $Item
            }
        }
        [Object[]] GetWmiService()
        {
            Return Get-WMIObject -Class Win32_Service | Sort-Object Name
        }
        Update([Int32]$State,[String]$Status)
        {
            $This.Console.Update($State,"[Service]: $Status")
        }
        [String] Pid()
        {
            Return (Get-Service | ? ServiceType -eq 224)[0].Name.Split('_')[-1]
        }
        [String[]] ConfigNames()
        {
            $Out = "AJRouter;ALG;AppHostSvc;AppIDSvc;Appinfo;AppMgmt;AppReadiness;AppVClient;aspnet"+
            "_state;AssignedAccessManagerSvc;AudioEndpointBuilder;AudioSrv;AxInstSV;BcastDVRUserSer"+
            "vice_{0};BDESVC;BFE;BITS;BluetoothUserService_{0};Browser;BTAGService;BthAvctpSvc;BthH"+
            "FSrv;bthserv;c2wts;camsvc;CaptureService_{0};CDPSvc;CDPUserSvc_{0};CertPropSvc;COMSysA"+
            "pp;CryptSvc;CscService;defragsvc;DeviceAssociationService;DeviceInstall;DevicePickerUs"+
            "erSvc_{0};DevQueryBroker;Dhcp;diagnosticshub.standardcollector.service;diagsvc;DiagTra"+
            "ck;DmEnrollmentSvc;dmwappushsvc;Dnscache;DoSvc;dot3svc;DPS;DsmSVC;DsRoleSvc;DsSvc;Dusm"+
            "Svc;EapHost;EFS;embeddedmode;EventLog;EventSystem;Fax;fdPHost;FDResPub;fhsvc;FontCache"+
            ";FontCache3.0.0.0;FrameServer;ftpsvc;GraphicsPerfSvc;hidserv;hns;HomeGroupListener;Hom"+
            "eGroupProvider;HvHost;icssvc;IKEEXT;InstallService;iphlpsvc;IpxlatCfgSvc;irmon;KeyIso;"+
            "KtmRm;LanmanServer;LanmanWorkstation;lfsvc;LicenseManager;lltdsvc;lmhosts;LPDSVC;LxssM"+
            "anager;MapsBroker;MessagingService_{0};MSDTC;MSiSCSI;MsKeyboardFilter;MSMQ;MSMQTrigger"+
            "s;NaturalAuthentication;NcaSVC;NcbService;NcdAutoSetup;Netlogon;Netman;NetMsmqActivato"+
            "r;NetPipeActivator;netprofm;NetSetupSvc;NetTcpActivator;NetTcpPortSharing;NlaSvc;nsi;O"+
            "neSyncSvc_{0};p2pimsvc;p2psvc;PcaSvc;PeerDistSvc;PerfHost;PhoneSvc;pla;PlugPlay;PNRPAu"+
            "toReg;PNRPsvc;PolicyAgent;Power;PrintNotify;PrintWorkflowUserSvc_{0};ProfSvc;PushToIns"+
            "tall;QWAVE;RasAuto;RasMan;RemoteAccess;RemoteRegistry;RetailDemo;RmSvc;RpcLocator;SamS"+
            "s;SCardSvr;ScDeviceEnum;SCPolicySvc;SDRSVC;seclogon;SEMgrSvc;SENS;Sense;SensorDataServ"+
            "ice;SensorService;SensrSvc;SessionEnv;SgrmBroker;SharedAccess;SharedRealitySvc;ShellHW"+
            "Detection;shpamsvc;smphost;SmsRouter;SNMPTRAP;spectrum;Spooler;SSDPSRV;ssh-agent;SstpS"+
            "vc;StiSvc;StorSvc;svsvc;swprv;SysMain;TabletInputService;TapiSrv;TermService;Themes;Ti"+
            "eringEngineService;TimeBroker;TokenBroker;TrkWks;TrustedInstaller;tzautoupdate;UevAgen"+
            "tService;UI0Detect;UmRdpService;upnphost;UserManager;UsoSvc;VaultSvc;vds;vmcompute;vmi"+
            "cguestinterface;vmicheartbeat;vmickvpexchange;vmicrdv;vmicshutdown;vmictimesync;vmicvm"+
            "session;vmicvss;vmms;VSS;W32Time;W3LOGSVC;W3SVC;WaaSMedicSvc;WalletService;WarpJITSvc;"+
            "WAS;wbengine;WbioSrvc;Wcmsvc;wcncsvc;WdiServiceHost;WdiSystemHost;WebClient;Wecsvc;WEP"+
            "HOSTSVC;wercplsupport;WerSvc;WFDSConSvc;WiaRpc;WinHttpAutoProxySvc;Winmgmt;WinRM;wisvc"+
            ";WlanSvc;wlidsvc;wlpasvc;wmiApSrv;WMPNetworkSvc;WMSVC;workfolderssvc;WpcMonSvc;WPDBusE"+
            "num;WpnService;WpnUserService_{0};wscsvc;WSearch;wuauserv;wudfsvc;WwanSvc;xbgm;XblAuth"+
            "Manager;XblGameSave;XboxGipSvc;XboxNetApiSvc"

            Return $Out -f $This.Pid() -Split ";"
        }
        [UInt32[]] ConfigMasks()
        {
            Return "0;1;2;3;3;4;3;5;3;6;2;2;3;3;3;2;7;3;3;0;0;0;0;3;3;4;7;2;0;3;2;8;3;3;3;3;3;2;3;3"+
            ";2;3;1;2;7;3;2;3;3;3;2;3;3;3;2;2;1;3;3;3;2;3;1;2;3;3;6;3;3;1;1;3;3;9;0;1;3;3;2;2;1;3;3"+
            ";3;2;3;1;0;3;3;1;11;2;2;0;3;3;0;0;3;2;2;3;3;2;1;2;2;7;3;3;2;8;3;1;3;3;3;3;3;2;3;3;2;3;"+
            "3;3;3;12;12;1;3;1;2;12;1;1;3;3;1;2;6;13;13;13;0;7;1;3;2;12;3;1;1;3;2;3;3;3;3;3;3;3;2;1"+
            "3;3;0;2;3;3;3;2;3;12;5;3;0;3;2;3;3;3;6;1;1;1;1;1;1;1;1;14;3;3;3;2;3;3;3;3;3;3;2;0;3;3;"+
            "0;3;3;3;3;13;3;3;2;1;1;15;3;3;3;1;3;1;1;3;2;2;7;7;3;3;1;3;1;1;3;1" -Split ";"
        }
        [String[]] ConfigValues()
        {
            Return "2,2,2,2,2,2,1,1,2,2;2,2,2,2,1,1,1,1,1,1;3,0,3,0,3,0,3,0,3,0;2,0,2,0,2,0,2,0,2,0"+
            ";0,0,2,2,2,2,1,1,2,2;0,0,1,0,1,0,1,0,1,0;0,0,2,0,2,0,2,0,2,0;4,0,4,0,4,0,4,0,4,0;0,0,2"+
            ",2,1,1,1,1,1,1;3,3,3,3,3,3,1,1,3,3;4,4,4,4,1,1,1,1,1,1;0,0,0,0,0,0,0,0,0,0;1,0,1,0,1,0"+
            ",1,0,1,0;2,2,2,2,1,1,1,1,2,2;0,0,3,0,3,0,3,0,3,0;3,3,3,3,2,2,2,2,3,3" -Split ";"
        }
        SetSlot([UInt32]$Slot)
        {
            ForEach ($X in 0..($This.Output.Count-1))
            {
                $Item           = $This.Output[$X]
                $Item.Target    = $This.Sub.StartMode.Output[$Item.Profile[$Slot]]
                $Item.Match     = [UInt32]($Item.StartMode.Index -eq $Item.Target.Index)
            }
        }
        [Object] GetServiceTemplate([UInt32]$Index,[Object]$Object)
        {
            Return [ServiceTemplate]::New($Index,$Object)
        }
        [Object] GetServiceSubcontroller()
        {
            $This.Update(0,"Getting [~] Service subcontroller")
            Return [ServiceSubcontroller]::New()
        }
        [Object] GetServiceProfile([String]$Name,[String]$Values)
        {
            Return [ServiceProfile]::New($Name,$Values)
        }
        [Object] GetServiceConfig()
        {
            $This.Update(0,"Getting [~] Service configuration")
            $Hash                      = @{ }
            $Names                     = $This.ConfigNames()
            $Masks                     = $This.ConfigMasks()
            $Values                    = $This.ConfigValues()

            ForEach ($X in 0..($Names.Count-1))
            {
                $Hash.Add($Hash.Count,$This.GetServiceProfile($Names[$X],$Values[$Masks[$X]]))
            }

            Return @($Hash[0..($Hash.Count-1)])
        }
        Load([Object]$Service)
        {
            $This.Sub.Load($Service)
        }
        [String] ToString()
        {
            Return "<FEModule.Service[Controller]>"
        }
    }

    # // ================
    # // | Privacy (12) |
    # // ================

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

    Class Telemetry : ControlTemplate
    {
        Telemetry([Object]$Console) : Base($Console)
        {
            $This.Name        = "Telemetry"
            $This.DisplayName = "Telemetry"
            $This.Value       = 1
            $This.Description = "Various location and tracking features"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
            'AllowTelemetry'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
            'AllowTelemetry'),
            ('HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
            'AllowTelemetry'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds',
            'AllowBuildPreview'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform',
            'NoGenTicket'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows',
            'CEIPEnable'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
            'AITEnable'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat',
            'DisableInventory'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP',
            'CEIPEnable'),
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC',
            'PreventHandwritingDataSharing'),
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput',
            'AllowLinguisticDataCollection') | % {
    
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
                        $This.Update(0,"Skipping [!] Telemetry")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Telemetry")
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
                    $This.Update(2,"Disabling [~] Telemetry")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    If ([Environment]::Is64BitProcess)
                    {
                        $This.Output[2].Set(0)
                    }
                    $This.Output[ 3].Set(0)
                    $This.Output[ 4].Set(1)
                    $This.Output[ 5].Set(0)
                    $This.Output[ 6].Set(0)
                    $This.Output[ 7].Set(1)
                    $This.Output[ 8].Set(0)
                    $This.Output[ 9].Set(1)
                    $This.Output[10].Set(0)
                    $This.TelemetryTask() | % { Disable-ScheduledTask -TaskName $_ }
                }
            }
        }
        [String[]] TelemetryTask()
        {
            Return "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                   "Microsoft\Windows\Application Experience\ProgramDataUpdater",
                   "Microsoft\Windows\Autochk\Proxy",
                   "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                   "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                   "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                   "Microsoft\Office\Office ClickToRun Service Monitor",
                   "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
                   "Microsoft\Office\OfficeTelemetryAgentLogOn2016"
        }
    }
    
    Class WiFiSense : ControlTemplate
    {
        WiFiSense([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [-] Wi-Fi Sense")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Wi-Fi Sense")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                    $This.Output[3].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Wi-Fi Sense")
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
        SmartScreen([Object]$Console) : base($Console)
        {
            $This.Name        = "SmartScreen"
            $This.DisplayName = "SmartScreen"
            $This.Value       = 1
            $This.Description = "Cloud-based anti-phishing and anti-malware component"
            $This.Options     = "Skip","Enable*","Disable"
    
            $Path             = Switch ([UInt32]($This.GetWinVersion() -ge 1703))
            { 
                0 { $Null } 1 { Get-AppxPackage | ? Name -eq Microsoft.MicrosoftEdge | % PackageFamilyName }
            }
    
            $Phishing = "HKCU:","SOFTWARE","Classes","Local Settings","Software",
                        "Microsoft","Windows","CurrentVersion","AppContainer",
                        "Storage",$Path,"MicrosoftEdge","PhishingFilter" -join "\"

            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
            "SmartScreenEnabled"),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost",
            "EnableWebContentEvaluation"),
            ($Phishing,
            "EnabledV9"),
            ($Phishing,
            "PreventOverride") | % {
            
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
                        $This.Update(0,"Skipping [-] SmartScreen Filter")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] SmartScreen Filter")
                    $This.Output[0].Set("String","RequireAdmin")
                    1..3 | % { $This.Output[$_].Remove() }
                }
                2
                {
                    $This.Update(2,"Disabling [~] SmartScreen Filter")
                    $This.Output[0].Set("String","Off")
                    1..3 | % { $This.Output[$_].Set(0) }
                }
            }
        }
    }
    
    Class LocationTracking : ControlTemplate
    {
        LocationTracking([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Location Tracking")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Location Tracking")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Location Tracking")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Feedback : ControlTemplate
    {
        Feedback([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Feedback")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Feedback")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                    {
                        Enable-ScheduledTask -TaskName $Item | Out-Null 
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Feedback")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                    {
                        Disable-ScheduledTask -TaskName $Item | Out-Null 
                    }
                }
            }
        }
    }
    
    Class AdvertisingID : ControlTemplate
    {
        AdvertisingID([Object]$Console) : base($Console)
        {
            $This.Name        = "AdvertisingID"
            $This.DisplayName = "Advertising ID"
            $This.Value       = 1
            $This.Description = "Allows Microsoft to display targeted ads"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
            'Enabled'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy',
            'TailoredExperiencesWithDiagnosticDataEnabled') | % {
    
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
                        $This.Update(0,"Skipping [!] Advertising ID")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Advertising ID")
                    $This.Output[0].Remove()
                    $This.Output[1].Set(2)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Advertising ID")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class Cortana : ControlTemplate
    {
        Cortana([Object]$Console) : base($Console)
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
                        $This.Update(0, "Skipping [!] Cortana")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Cortana")
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
                    $This.Update(2,"Disabling [~] Cortana")
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
        CortanaSearch([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Cortana Search")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Cortana Search")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Cortana Search")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class ErrorReporting : ControlTemplate
    {
        ErrorReporting([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Error Reporting")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Error Reporting")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Error Reporting")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class AutoLoggerFile : ControlTemplate
    {
        AutoLoggerFile([Object]$Console) : base($Console)
        {
            $This.Name        = "AutoLoggerFile"
            $This.DisplayName = "Automatic Logger File"
            $This.Value       = 1
            $This.Description = "Lets you track trace provider actions while Windows is booting"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ($This.WmiRegistry(),
            "Start"),
            ("$($This.WmiRegistry())\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}",
            "Start") | % {
    
                $This.Registry($_[0],$_[1])
            }
        }
        [String] WmiRegistry()
        {
            Return "HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener"
        }
        [String] AutoLogger()
        {
            Return "$Env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] AutoLogger")
                    }
                }
                1
                {
                    $This.Update(1,"Unrestricting [~] AutoLogger")
                    icacls $This.AutoLogger() /grant:r SYSTEM:`(OI`)`(CI`)F
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Removing [~] AutoLogger, and restricting directory")
                    icacls $This.AutoLogger() /deny SYSTEM:`(OI`)`(CI`)F
                    Remove-Item "$($This.AutoLogger())\AutoLogger-Diagtrack-Listener.etl" -EA 0 -Verbose
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class DiagTrack : ControlTemplate
    {
        DiagTrack([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Diagnostics Tracking")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Diagnostics Tracking")
                    Get-Service -Name DiagTrack
                    Set-Service -Name DiagTrack -StartupType Automatic
                    Start-Service -Name DiagTrack
                }
                2
                {
                    $This.Update(2,"Disabling [~] Diagnostics Tracking")
                    Stop-Service -Name DiagTrack
                    Set-Service -Name DiagTrack -StartupType Disabled
                    Get-Service -Name DiagTrack
                }
            }
        }
    }
    
    Class WAPPush : ControlTemplate
    {
        WAPPush([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] WAP Push")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] WAP Push Service")
                    Set-Service -Name dmwappushservice -StartupType Automatic
                    Start-Service -Name dmwappushservice
                    $This.Output[0].Set(1)
                    Get-Service -Name dmwappushservice
                }
                2
                {
                    $This.Update(2,"Disabling [~] WAP Push Service")
                    Stop-Service -Name dmwappushservice
                    Set-Service -Name dmwappushservice -StartupType Disabled
                    Get-Service -Name dmwappushservice
                }
            }
        }
    }

    # // ======================
    # // | Windows Update (8) |
    # // ======================
    
    Enum WindowsUpdateType
    {
        UpdateMSProducts
        CheckForWindowsUpdate
        WinUpdateType
        WinUpdateDownload
        UpdateMSRT
        UpdateDriver
        RestartOnUpdate
        AppAutoDownload
        UpdateAvailablePopup
    }

    Class UpdateMSProducts : ControlTemplate
    {
        UpdateMSProducts([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Update Microsoft Products")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Update Microsoft Products")
                    $This.ComMusm().AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
                }
                2
                {
                    $This.Update(2,"Disabling [~] Update Microsoft Products")
                    $This.ComMusm().RemoveService("7971f918-a847-4430-9279-4a52d1efe18d")
                }
            }
        }
        [Object] ComMusm()
        {
            Return New-Object -ComObject Microsoft.Update.ServiceManager
        }
    }
    
    Class CheckForWindowsUpdate : ControlTemplate
    {
        CheckForWindowsUpdate([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Check for Windows Updates")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Check for Windows Updates")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Check for Windows Updates")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class WinUpdateType : ControlTemplate
    {
        WinUpdateType([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Windows Update Check Type")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Notify for Windows Update downloads, notify to install")
                    $This.Output[0].Set(2)
                }
                2
                {
                    $This.Update(2,"Enabling [~] Automatically download Windows Updates, notify to install")
                    $This.Output[0].Set(3)
                }
                3
                {
                    $This.Update(3,"Enabling [~] Automatically download Windows Updates, schedule to install")
                    $This.Output[0].Set(4)
                }
                4
                {
                    $This.Update(4,"Enabling [~] Allow local administrator to choose automatic updates")
                    $This.Output[0].Set(5)
                }
            }
        }
    }
    
    Class WinUpdateDownload : ControlTemplate
    {
        WinUpdateDownload([Object]$Console) : base($Console)
        {
            $This.Name        = "WinUpdateDownload"
            $This.DisplayName = "Windows Update Download"
            $This.Value       = 1
            $This.Description = "Selects a source from which to pull Windows Updates"
            $This.Options     = "Skip", "P2P*", "Local Only", "Disable"
    
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config",
            "DODownloadMode"),
            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
            "SystemSettingsDownloadMode"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization",
            "SystemSettingsDownloadMode"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
            "DODownloadMode") | % {
    
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
                        $This.Update(0,"Skipping [!] ")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Unrestricting Windows Update P2P to Internet")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Enabling [~] Restricting Windows Update P2P only to local network")
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
                    $This.Update(3,"Disabling [~] Windows Update P2P")
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
        UpdateMSRT([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Malicious Software Removal Tool Update")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Malicious Software Removal Tool Update")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Malicious Software Removal Tool Update")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class UpdateDriver : ControlTemplate
    {
        UpdateDriver([Object]$Console) : base($Console)
        {
            $This.Name        = "UpdateDriver"
            $This.DisplayName = "Update Driver"
            $This.Value       = 1
            $This.Description = "Allows drivers to be downloaded from Windows Update"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching",
            "SearchOrderConfig"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
            "ExcludeWUDriversInQualityUpdate"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata",
            "PreventDeviceMetadataFromNetwork") | % {
    
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
                        $This.Update(0,"Skipping [!] Driver update through Windows Update")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Driver update through Windows Update")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Driver update through Windows Update")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(1)
                }
            }
        }
    }
    
    Class RestartOnUpdate : ControlTemplate
    {
        RestartOnUpdate([Object]$Console) : base($Console)
        {
            $This.Name        = "RestartOnUpdate"
            $This.DisplayName = "Restart on Update"
            $This.Value       = 1
            $This.Description = "Reboots the machine when an update is installed and requires it"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings",
            "UxOption"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
            "NoAutoRebootWithLoggOnUsers"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
            "AUPowerManagement") | % {
    
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
                        $This.Update(0,"Skipping [!] Windows Update Automatic Restart")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Update Automatic Restart")
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                    $This.Output[2].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Windows Update Automatic Restart")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    $This.Output[2].Set(0)
                }
            }
        }
    }
    
    Class AppAutoDownload : ControlTemplate
    {
        AppAutoDownload([Object]$Console) : base($Console)
        {
            $This.Name        = "AppAutoDownload"
            $This.DisplayName = "Consumer App Auto Download"
            $This.Value       = 1
            $This.Description = "Provisioned Windows Store applications are downloaded"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate",
            "AutoDownload"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
            "DisableWindowsConsumerFeatures") | % {
    
                $This.Registry($_[0],$_[1])
            }
        }
        [String] CloudCache()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
        }
        [String] PlaceHolder() 
        {
            Return "*windows.data.placeholdertilecollection\Current"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] App Auto Download")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] App Auto Download")
                    $This.Output[0].Set(0)
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] App Auto Download")
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
                    If ($This.GetWinVersion() -le 1803)
                    {
                        $Key  = Get-ChildItem $This.CloudCache() -Recurse | ? Name -like $This.Placeholder()
                        $Data = (Get-ItemProperty -Path $Key.PSPath).Data
                        Set-ItemProperty -Path $Key -Name Data -Type Binary -Value $Data[0..15] -Verbose
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }
    
    Class UpdateAvailablePopup : ControlTemplate
    {
        UpdateAvailablePopup([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Update Available Popup")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Update Available Popup")
                    $This.MUSNotify()  | % { 
                        ICACLS $_ /remove:d '"Everyone"'
                        ICACLS $_ /grant ('Everyone' + ':(OI)(CI)F')
                        ICACLS $_ /setowner 'NT SERVICE\TrustedInstaller'
                        ICACLS $_ /remove:g '"Everyone"'
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Update Available Popup")
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
    
    # // ===============
    # // | Service (8) |
    # // ===============

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

    Class UAC : ControlTemplate
    {
        UAC([Object]$Console) : base($Console)
        {
            $This.Name        = "UAC"
            $This.DisplayName = "User Access Control"
            $This.Value       = 2
            $This.Description = "Sets restrictions/permissions for programs"
            $This.Options     = "Skip", "Lower", "Normal*", "Higher"
            
            ($This.RegPath(),"ConsentPromptBehaviorAdmin"),
            ($This.RegPath(),"PromptOnSecureDesktop") | % { 
            
                $This.Registry($_[0],$_[1])
            }
        }
        [String] RegPath()
        {
            Return "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] UAC Level")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] UAC Level (Low)")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set
                }
                2
                {
                    $This.Update(2,"Setting [~] UAC Level (Default)")
                    $This.Output[0].Set(5)
                    $This.Output[1].Set(1)
                }
                3
                {
                    $This.Update(3,"Setting [~] UAC Level (High)")
                    $This.Output[0].Set(2)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
    
    Class SharingMappedDrives : ControlTemplate
    {
        SharingMappedDrives([Object]$Console) : base($Console)
        {
            $This.Name        = "SharingMappedDrives"
            $This.DisplayName = "Share Mapped Drives"
            $This.Value       = 2
            $This.Description = "Shares any mapped drives to all users on the machine"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            $This.Registry($This.RegPath(),"EnableLinkedConnections")
        }
        [String] RegPath()
        {
            Return "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Sharing mapped drives between users")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sharing mapped drives between users")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sharing mapped drives between users")
                    $This.Output[0].Remove()
                }
            }
        }
    }
    
    Class AdminShares : ControlTemplate
    {
        AdminShares([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Hidden administrative shares")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hidden administrative shares")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hidden administrative shares")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class Firewall : ControlTemplate
    {
        Firewall([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Firewall Profile")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Firewall Profile")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Firewall Profile")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class WinDefender : ControlTemplate
    {
        WinDefender([Object]$Console) : base($Console)
        {
            $This.Name        = "WinDefender"
            $This.DisplayName = "Windows Defender"
            $This.Value       = 1
            $This.Description = "Toggles Windows Defender, system default anti-virus/malware utility"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
            "DisableAntiSpyware"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "WindowsDefender"),
            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "SecurityHealth"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
            $Null),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
            "SpynetReporting"),
            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
            "SubmitSamplesConsent") | % {
    
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
                        $This.Update(0,"Skipping [!] Windows Defender")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Defender")
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
                    $This.Update(2,"Disabling [~] Windows Defender")
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
        HomeGroups([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Home groups services")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Home groups services")
                    Set-Service   -Name HomeGroupListener -StartupType Manual
                    Set-Service   -Name HomeGroupProvider -StartupType Manual
                    Start-Service -Name HomeGroupProvider
                }
                2
                {
                    $This.Update(2,"Disabling [~] Home groups services")
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
        RemoteAssistance([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Remote Assistance")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote Assistance")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote Assistance")
                    $This.Output[0].Set(0)
                }
            }
        }
    }
    
    Class RemoteDesktop : ControlTemplate
    {
        RemoteDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "RemoteDesktop"
            $This.DisplayName = "Remote Desktop"
            $This.Value       = 2
            $This.Description = "Toggles the ability to use Remote Desktop"
            $This.Options     = "Skip", "Enable", "Disable*"
    
            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server",
            "fDenyTSConnections"),
            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp",
            "UserAuthentication") | % {
            
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
                        $This.Update(0,"Skipping [!] Remote Desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote Desktop")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote Desktop")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
            }
        }
    }
    
    # // ===============
    # // | Context (7) |
    # // ===============
	
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

    Class CastToDevice : ControlTemplate
    {
        CastToDevice([Object]$Console) : base($Console)
        {
            $This.Name        = "CastToDevice"
            $This.DisplayName = "Cast To Device"
            $This.Value       = 1
            $This.Description = "Adds a context menu item for casting to a device"
            $This.Options     = "Skip", "Enable*", "Disable"

            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked",
            "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}") | % { 
                
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
                        $This.Update(0,"Skipping [!] 'Cast to device' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Cast to device' context menu item")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Cast to device' context menu item")
                    $This.Output[0].Set("String","Play to Menu")
                }
            }
        }
    }

    Class PreviousVersions : ControlTemplate
    {
        PreviousVersions([Object]$Console) : base($Console)
        {
            $This.Name        = "PreviousVersions"
            $This.DisplayName = "Previous Versions"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to select a previous version of a file"
            $This.Options     = "Skip", "Enable*", "Disable"

            ("HKCR:\AllFilesystemObjects\$($This.ShellEx())",
            $Null),
            ("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\$($This.ShellEx())",
            $Null),
            ("HKCR:\Directory\$($This.ShellEx())",
            $Null),
            ("HKCR:\Drive\$($This.ShellEx())",
            $Null) | % {

                $This.Registry($_[0],$_[1])
            }
        }
        [String] ShellEx()
        {
            Return "shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Previous versions' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Previous versions' context menu item")
                    $This.Output[0].Get()
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Get()
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Previous versions' context menu item")
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
        IncludeInLibrary([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] 'Include in Library' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Include in Library' context menu item")
                    $This.Output[0].Set("String","{3dad6c5d-2167-4cae-9914-f99e41c12cfa}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Include in Library' context menu item")
                    $This.Output[0].Set("String","")
                }
            }
        }
    }

    Class PinToStart : ControlTemplate
    {
        PinToStart([Object]$Console) : base($Console)
        {
            $This.Name        = "PinToStart"
            $This.DisplayName = "Pin to Start"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to pin an item to the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}',
            '(Default)'),
            ('HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}',
            '(Default)'),
            ('HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen',
            '(Default)'),
            ('HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen',
            '(Default)'),
            ('HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen',
            '(Default)'),
            ('HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen',
            '(Default)') | % {

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
                        $This.Update(0,"Skipping [!] 'Pin to Start' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Pin to Start' context menu item")
                    $This.Output[0].Set("String","Taskband Pin")
                    $This.Output[1].Set("String","Start Menu Pin")
                    $This.Output[2].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[3].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[4].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                    $This.Output[5].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Pin to Start' context menu item")
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
        PinToQuickAccess([Object]$Console) : base($Console)
        {
            $This.Name        = "PinToQuickAccess"
            $This.DisplayName = "Pin to Quick Access"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to pin an item to the Quick Access bar"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\Folder\shell\pintohome',
            'MUIVerb'),
            ('HKCR:\Folder\shell\pintohome',
            'AppliesTo'),
            ('HKCR:\Folder\shell\pintohome\command',
            'DelegateExecute'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome',
            'MUIVerb'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome',
            'AppliesTo'),
            ('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command',
            'DelegateExecute') | % {

                $This.Registry($_[0],$_[1])
            }
        }
        [String] ParseName()
        {
            Return 'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}"', 
                   'System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}"', 
                   'System.IsFolder:=System.StructuredQueryType.Boolean#True' -join " AND "
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Pin to Quick Access' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Pin to Quick Access' context menu item")
                    $This.Output[0].Set("String",'@shell32.dll,-51377')
                    $This.Output[1].Set("String",$This.ParseName())
                    $This.Output[2].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                    $This.Output[3].Set("String",'@shell32.dll,-51377')
                    $This.Output[4].Set("String",$This.ParseName())
                    $This.Output[5].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Pin to Quick Access' context menu item")
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
        ShareWith([Object]$Console) : base($Console)
        {
            $This.Name        = "PinToQuickAccess"
            $This.DisplayName = "Pin to Quick Access"
            $This.Value       = 1
            $This.Description = "Adds a context menu item to share a file with..."
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCR:\*\shellex\ContextMenuHandlers\Sharing',
            '(Default)'),
            ('HKCR:\Directory\shellex\ContextMenuHandlers\Sharing',
            '(Default)'),
            ('HKCR:\Directory\shellex\CopyHookHandlers\Sharing',
            '(Default)'),
            ('HKCR:\Drive\shellex\ContextMenuHandlers\Sharing',
            '(Default)'),
            ('HKCR:\Directory\shellex\PropertySheetHandlers\Sharing',
            '(Default)'),
            ('HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing',
            '(Default)'),
            ('HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing',
            '(Default)'),
            ('HKCR:\*\shellex\ContextMenuHandlers\ModernSharing',
            '(Default)') | % {

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
                        $This.Update(0,"Skipping [!] 'Share with' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Share with' context menu item")
                    0..7 | % { $This.Output[$_].Set("String","{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}") }
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Share with' context menu item")
                    0..7 | % { $This.Output[$_].Set("String","") }
                }
            }
        }
    }

    Class SendTo : ControlTemplate
    {
        SendTo([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] 'Send to' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Send to' context menu item")
                    $This.Output[0].Set("String","{7BA4C740-9E81-11CF-99D3-00AA004AE837}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Send to' context menu item")
                    $This.Output[0].Name = $Null
                    $This.Output[0].Remove()
                }
            }
        }
    }

    # // ================
    # // | Taskbar (12) |
    # // ================
	
    Enum TaskbarType
    {
        BatteryUIBar
        ClockUIBar
        VolumeControlBar
        TaskbarSearchBox
        TaskViewButton
        TaskbarIconSize
        TaskbarGrouping
        TrayIcons
        SecondsInClock
        LastActiveClick
        TaskbarOnMultiDisplay
        TaskbarButtonDisplay
    }

    Class BatteryUIBar : ControlTemplate
    {
        BatteryUIBar([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Battery UI Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Battery UI Bar (New)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Setting [~] Battery UI Bar (Old)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class ClockUIBar : ControlTemplate
    {
        ClockUIBar([Object]$Console) : base($Console)
        {
            $This.Name        = "ClockUIBar"
            $This.DisplayName = "Clock UI Bar"
            $This.Value       = 1
            $This.Description = "Toggles the clock UI bar element style"
            $This.Options     = "Skip", "New*", "Classic"
            
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell',
            'UseWin32TrayClockExperience') | % { 

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
                        $This.Update(0,"Skipping [!] Clock UI Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Clock UI Bar (New)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Setting [~] Clock UI Bar (Old)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class VolumeControlBar : ControlTemplate
    {
        VolumeControlBar([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Volume Control Bar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Volume Control Bar (Horizontal)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Volume Control Bar (Vertical)")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskBarSearchBox : ControlTemplate
    {
        TaskBarSearchBox([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Taskbar 'Search Box' button")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Taskbar 'Search Box' button")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Taskbar 'Search Box' button")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskViewButton : ControlTemplate
    {
        TaskViewButton([Object]$Console) : base($Console)
        {
            $This.Name        = "VolumeControlBar"
            $This.DisplayName = "Volume Control Bar"
            $This.Value       = 1
            $This.Description = "Toggles the volume control bar element style"
            $This.Options     = "Skip", "New (X-Axis)*", "Classic (Y-Axis)"
            
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
            'ShowTaskViewButton') | % { 

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
                        $This.Update(0,"Skipping [!] Task View button")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Task View button")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Task View button")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarIconSize : ControlTemplate
    {
        TaskbarIconSize([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Icon size in taskbar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Icon size in taskbar")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Icon size in taskbar")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskbarGrouping : ControlTemplate
    {
        TaskbarGrouping([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Group Taskbar Items")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Group Taskbar Items (Never)")
                    $This.Output[0].Set(2)
                }
                2
                {
                    $This.Update(2,"Setting [~] Group Taskbar Items (Always)")
                    $This.Output[0].Set(0)
                }
                3
                {
                    $This.Update(3,"Setting [~] Group Taskbar Items (When needed)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TrayIcons : ControlTemplate
    {
        TrayIcons([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Tray Icons")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Tray Icons (Hiding)")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Setting [~] Tray Icons (Showing)")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class SecondsInClock : ControlTemplate
    {
        SecondsInClock([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Seconds in Taskbar clock")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Seconds in Taskbar clock")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Seconds in Taskbar clock")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class LastActiveClick : ControlTemplate
    {
        LastActiveClick([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Last active click")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Last active click")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Last active click")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarOnMultiDisplay : ControlTemplate
    {
        TaskbarOnMultiDisplay([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Taskbar on Multiple Displays")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Taskbar on Multiple Displays")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Taskbar on Multiple Displays")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class TaskbarButtonDisplay : ControlTemplate
    {
        TaskbarButtonDisplay([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Taskbar buttons on multiple displays")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Taskbar buttons, multi-display (All taskbars)")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Taskbar buttons, multi-display (Taskbar where window is open)")
                    $This.Output[0].Set(2)
                }
                3
                {
                    $This.Update(3,"Setting [~] Taskbar buttons, multi-display (Main taskbar + where window is open)")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    # // =================
    # // | StartMenu (5) |
    # // =================
	
    Enum StartMenuType
    {
        StartMenuWebSearch
        StartSuggestions
        MostUsedAppStartMenu
        RecentItemsFrequent
        UnpinItems
    }

    Class StartMenuWebSearch : ControlTemplate
    {
        StartMenuWebSearch([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Bing Search in Start Menu")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Bing Search in Start Menu")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Bing Search in Start Menu")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(1)
                }
            }
        }
    }

    Class StartSuggestions : ControlTemplate
    {
        StartSuggestions([Object]$Console) : base($Console)
        {
            $This.Name        = "StartSuggestions"
            $This.DisplayName = "Start Menu Suggestions"
            $This.Value       = 1
            $This.Description = "Toggles the suggested apps in the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"
    
            ($This.RegPath(),"ContentDeliveryAllowed"),
            ($This.RegPath(),"OemPreInstalledAppsEnabled"),
            ($This.RegPath(),"PreInstalledAppsEnabled"),
            ($This.RegPath(),"PreInstalledAppsEverEnabled"),
            ($This.RegPath(),"SilentInstalledAppsEnabled"),
            ($This.RegPath(),"SystemPaneSuggestionsEnabled"),
            ($This.RegPath(),"Start_TrackProgs"),
            ($This.RegPath(),"SubscribedContent-314559Enabled"),
            ($This.RegPath(),"SubscribedContent-310093Enabled"),
            ($This.RegPath(),"SubscribedContent-338387Enabled"),
            ($This.RegPath(),"SubscribedContent-338388Enabled"),
            ($This.RegPath(),"SubscribedContent-338389Enabled"),
            ($This.RegPath(),"SubscribedContent-338393Enabled"),
            ($This.RegPath(),"SubscribedContent-338394Enabled"),
            ($This.RegPath(),"SubscribedContent-338396Enabled"),
            ($This.RegPath(),"SubscribedContent-338398Enabled") | % {
    
                $This.Registry($_[0],$_[1])
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        }
        [String] CloudCache()
        {
            Return "HKCU:","SOFTWARE","Microsoft","Windows","CurrentVersion","CloudStore","Store",
            "Cache","DefaultAccount","*windows.data.placeholdertilecollection","Current" -join '\'
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Start Menu Suggestions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Start Menu Suggestions")
                    0..15 | % { $This.Output[$_].Set(1) }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Start Menu Suggestions")
                    0..15 | % { $This.Output[$_].Set(0) }
                    If ($This.GetWinVersion() -ge 1803) 
                    {
                        $Key = Get-ItemProperty -Path $This.CloudCache()
                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Key.Data[0..15]
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }

    Class MostUsedAppStartMenu : ControlTemplate
    {
        MostUsedAppStartMenu([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Most used apps in Start Menu")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Most used apps in Start Menu")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Most used apps in Start Menu")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class RecentItemsFrequent : ControlTemplate
    {
        RecentItemsFrequent([Object]$Console) : base($Console)
        {
            $This.Name        = "RecentItemsFrequent"
            $This.DisplayName = "Recent Items Frequent"
            $This.Value       = 1
            $This.Description = "Toggles the most recent frequently used (apps/items) in the start menu"
            $This.Options     = "Skip", "Enable*", "Disable"

            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu',
            "Start_TrackDocs") | % { 

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
                        $This.Update(0,"Skipping [!] Recent items and frequent places")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Recent items and frequent places")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Recent items and frequent places")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class UnpinItems : ControlTemplate
    {
        UnpinItems([Object]$Console) : base($Console)
        {
            $This.Name        = "UnpinItems"
            $This.DisplayName = "Unpin Items"
            $This.Value       = 0
            $This.Description = "Toggles the unpin (apps/items) from the start menu"
            $This.Options     = "Skip", "Enable"
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
        }
        [String] Collection()
        {
            Return "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Unpinning Items")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Unpinning Items")
                    If ($This.GetWinVersion() -le 1709) 
                    {
                        ForEach ($Item in Get-ChildItem $This.RegPath() -Include *.group -Recurse)
                        {
                            $Path = "{0}\Current" -f $Item.PsPath
                            $Data = (Get-ItemProperty $Path -Name Data).Data -join ","
                            $Data = $Data.Substring(0, $Data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
                            Set-ItemProperty $Path -Name Data -Type Binary -Value $Data.Split(",")
                        }
                    }
                    Else 
                    {
                        $Key     = Get-ItemProperty -Path "$($This.RegPath())\$($This.Collection())"
                        $Data    = $Key.Data[0..25] + ([Byte[]](202,50,0,226,44,1,1,0,0))
                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Data
                        Stop-Process -Name ShellExperienceHost -Force
                    }
                }
            }
        }
    }

    # // =================
    # // | Explorer (21) |
    # // =================
	
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
        TaskManagerDetails
        ReopenAppsOnBoot
    }

    Class AccessKeyPrompt : ControlTemplate
    {
        AccessKeyPrompt([Object]$Console) : base($Console)
        {
            $This.Name        = "AccessKeyPrompt"
            $This.DisplayName = "Access Key Prompt"
            $This.Value       = 1
            $This.Description = "Toggles the accessibility keys (menus/prompts)"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\Control Panel\Accessibility\StickyKeys',
            "Flags"),
            ('HKCU:\Control Panel\Accessibility\ToggleKeys',
            "Flags"),
            ('HKCU:\Control Panel\Accessibility\Keyboard Response',
            "Flags") | % {

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
                        $This.Update(0,"Skipping [!] Accessibility keys prompts")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Accessibility keys prompts")
                    $This.Output[0].Set("String",510)
                    $This.Output[1].Set("String",62)
                    $This.Output[2].Set("String",126)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Accessibility keys prompts")
                    $This.Output[0].Set("String",506)
                    $This.Output[1].Set("String",58)
                    $This.Output[2].Set("String",122)
                }
            }
        }
    }

    Class F1HelpKey : ControlTemplate
    {
        F1HelpKey([Object]$Console) : base($Console)
        {
            $This.Name        = "F1HelpKey"
            $This.DisplayName = "F1 Help Key"
            $This.Value       = 1
            $This.Description = "Toggles the F1 help menu/prompt"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ($This.RegPath(),
            $Null),
            ("$($This.RegPath()))\win32",
            "(Default)"),
            ("$($This.RegPath())\win64",
            "(Default)") | % {

                $This.Registry($_[0],$_[1])
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] F1 Help Key")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] F1 Help Key")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] F1 Help Key")
                    $This.Output[1].Set("String","")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                    $This.Output[2].Set("String","")  
                    }
                }
            }
        }
    }

    Class AutoPlay : ControlTemplate
    {
        AutoPlay([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Autoplay")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Autoplay")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Autoplay")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class AutoRun : ControlTemplate
    {
        AutoRun([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Autorun")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Autorun")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Autorun")
                    $This.Output[0].Set(255)
                }
            }
        }
    }

    Class PidInTitleBar : ControlTemplate
    {
        PidInTitleBar([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Process ID on Title bar")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Process ID on Title bar")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Process ID on Title bar")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class RecentFileQuickAccess : ControlTemplate
    {
        RecentFileQuickAccess([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Recent Files in Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Recent Files in Quick Access (Showing)")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set("String","Recent Items Instance Folder")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[2].Set("String","Recent Items Instance Folder")
                    }
                }
                2
                {
                    $This.Update(2,"Setting [~] Recent Files in Quick Access (Hiding)")
                    $This.Output[0].Set(0)
                }
                3
                {
                    $This.Update(3,"Setting [~] Recent Files in Quick Access (Removing)")
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
        FrequentFoldersQuickAccess([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Frequent folders in Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Frequent folders in Quick Access")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Frequent folders in Quick Access")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class WinContentWhileDrag : ControlTemplate
    {
        WinContentWhileDrag([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Window content while dragging")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Window content while dragging")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Window content while dragging")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class StoreOpenWith : ControlTemplate
    {
        StoreOpenWith([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Search Windows Store for Unknown Extensions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Search Windows Store for Unknown Extensions")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Search Windows Store for Unknown Extensions")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class LongFilePath : ControlTemplate
    {
        LongFilePath([Object]$Console) : base($Console)
        {
            $This.Name        = "LongFilePath"
            $This.DisplayName = "Long File Path"
            $This.Value       = 1
            $This.Description = "Toggles whether file paths are longer, or not"
            $This.Options     = "Skip", "Enable", "Disable*"
            
            ('HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem',
            'LongPathsEnabled'),
            ('HKLM:\SYSTEM\ControlSet001\Control\FileSystem',
            'LongPathsEnabled') | % {

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
                        $This.Update(0,"Skipping [!] Long file path")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Long file path")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Long file path")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
            }
        }
    }

    Class ExplorerOpenLoc : ControlTemplate
    {
        ExplorerOpenLoc([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Default Explorer view to Quick Access")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Default Explorer view to Quick Access")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Default Explorer view to Quick Access")
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class WinXPowerShell : ControlTemplate
    {
        WinXPowerShell([Object]$Console) : base($Console)
        {
            $This.Name        = "WinXPowerShell"
            $This.DisplayName = "Win X PowerShell"
            $This.Value       = 1
            $This.Description = "Toggles whether (Win + X) opens PowerShell or a Command Prompt"
            $This.Options     = "Skip", "PowerShell*", "Command Prompt"

            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
            'DontUsePowerShellOnWinX') | % { 

                $This.Registry($_[0],$_[1])
            }

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
                        $This.Update(0,"Skipping [!] (Win+X) PowerShell/Command Prompt")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] (Win+X) PowerShell/Command Prompt")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] (Win+X) PowerShell/Command Prompt")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class AppHibernationFile : ControlTemplate
    {
        AppHibernationFile([Object]$Console) : base($Console)
        {
            $This.Name        = "AppHibernationFile"
            $This.DisplayName = "App Hibernation File"
            $This.Value       = 1
            $This.Description = "Toggles the system swap file use"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management",
            "SwapfileControl") | % { 

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
                        $This.Update(0,"Skipping [!] App Hibernation File (swapfile.sys)")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] App Hibernation File (swapfile.sys)")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] App Hibernation File (swapfile.sys)")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class KnownExtensions : ControlTemplate
    {
        KnownExtensions([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Known File Extensions")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Known File Extensions")
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Known File Extensions")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class HiddenFiles : ControlTemplate
    {
        HiddenFiles([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Hidden Files")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hidden Files")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hidden Files")
                    $This.Output[0].Set(2)
                }
            }
        }
    }

    Class SystemFiles : ControlTemplate
    {
        SystemFiles([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] System Files")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] System Files")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] System Files")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class Timeline : ControlTemplate
    {
        Timeline([Object]$Console) : base($Console)
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
                            $This.Update(0,"Skipping [!] Windows Timeline")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Windows Timeline")
                        $This.Output[0].Set(1)
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Windows Timeline")
                        $This.Output[0].Set(0)
                    }
                }
            }
        }
    }

    Class AeroSnap : ControlTemplate
    {
        AeroSnap([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Aero Snap")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Aero Snap")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Aero Snap")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AeroShake : ControlTemplate
    {
        AeroShake([Object]$Console) : base($Console)
        {
            $This.Name        = "AeroShake"
            $This.DisplayName = "AeroShake"
            $This.Value       = 1
            $This.Description = "Toggles ability to minimize ALL windows by jiggling the active window title bar"
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
                        $This.Update(0,"Skipping [!] Aero Shake")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Aero Shake")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Aero Shake")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    Class TaskManagerDetails : ControlTemplate
    {
        TaskManagerDetails([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Task Manager Details")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Task Manager Details")
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
                    $This.Update(2,"Disabling [~] Task Manager Details")
                    $TM           = $This.Output[0].Get().Preferences
                    $TM[28]       = 1
                    $This.Output[0].Set("Binary",$TM)
                }
            }
        }
    }

    Class ReopenAppsOnBoot : ControlTemplate
    {
        ReopenAppsOnBoot([Object]$Console) : base($Console)
        {
            $This.Name        = "ReopenAppsOnBoot"
            $This.DisplayName = "Reopen apps at boot"
            $This.Value       = 1
            $This.Description = "Toggles applications to reopen at boot time"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
            'DisableAutomaticRestartSignOn') | % { 

                $This.Registry($_[0],$_[1])
            }
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
                            $This.Update(0,"Skipping [!] Reopen applications at boot time")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Reopen applications at boot time")
                        $This.Output[0].Set(0)
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Reopen applications at boot time")
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    # // ==================
    # // | ThisPCIcon (7) |
    # // ==================
	
    Enum ThisPCType
    {
        DesktopIconInThisPC
        DocumentsIconInThisPC
        DownloadsIconInThisPC
        MusicIconInThisPC
        PicturesIconInThisPC
        VideosIconInThisPC
        ThreeDObjectsIconInThisPC
    }

    Class DesktopIconInThisPC : ControlTemplate
    {
        DesktopIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "DesktopIconInThisPC"
            $This.DisplayName = "Desktop [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Desktop icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ForEach ($X in 0,1)
            {
                ($This.Path($X),$Null),
                ("$($This.Path($X))\PropertyBag",$Null),
                ("$($This.Path($X))\PropertyBag","ThisPCPolicy") | % {
        
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows","CurrentVersion",
            "Explorer","FolderDescriptions","{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -join "\"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Desktop folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Desktop folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Desktop folder in This PC (Hidden)")
                    $This.Output[2].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[5].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Desktop folder in This PC (None)")
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
        DocumentsIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "DocumentsIconInThisPC"
            $This.DisplayName = "Documents [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Documents icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
    
            ForEach ($X in 0,1)
            {
                ($This.Path($X,0,0),$Null),
                ($This.Path($X,0,1),$Null),
                ("$($This.Path($X,1,2))\PropertyBag",$Null),
                ("$($This.Path($X,1,2))\PropertyBag","ThisPCPolicy"),
                ("$($This.Path($X,1,2))\PropertyBag","BaseFolderID") | % { 
    
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot,[UInt32]$Base,[UInt32]$Guid)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows",
            "CurrentVersion","Explorer",@("MyComputer\NameSpace","FolderDescriptions")[$Base],
            $This.xGuid($Guid) -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
                     "{d3162b92-9365-467a-956b-92703aca08af}",
                     "{f42ee2d3-909f-4907-8871-4c22fc0bf756}")[$Slot]
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Documents folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Documents folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Documents folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Documents folder in This PC (None)")
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
        DownloadsIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "DownloadsIconInThisPC"
            $This.DisplayName = "Downloads [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Downloads icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ForEach ($X in 0,1)
            {
                ($This.Path($X,0,0),$Null),
                ($This.Path($X,0,1),$Null),
                ("$($This.Path($X,1,2))\PropertyBag",$Null),
                ("$($This.Path($X,1,2))\PropertyBag","ThisPCPolicy"),
                ("$($This.Path($X,1,2))\PropertyBag","BaseFolderID") | % { 
    
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot,[UInt32]$Base,[UInt32]$Guid)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows",
            "CurrentVersion","Explorer",@("MyComputer\NameSpace","FolderDescriptions")[$Base],
            $This.xGuid($Guid) -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{374DE290-123F-4565-9164-39C4925E467B}",
                     "{088e3905-0323-4b02-9826-5d99428e115f}",
                     "{7d83ee9b-2244-4e70-b1f5-5393042af1e4}")[$Slot]
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Downloads folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Downloads folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Downloads folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Documents folder in This PC (None)")
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
        MusicIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "MusicIconInThisPC"
            $This.DisplayName = "Music [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Music icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
    
            ForEach ($X in 0,1)
            {
                ($This.Path($X,0,0),$Null),
                ($This.Path($X,0,1),$Null),
                ("$($This.Path($X,1,2))\PropertyBag",$Null),
                ("$($This.Path($X,1,2))\PropertyBag","ThisPCPolicy"),
                ("$($This.Path($X,1,2))\PropertyBag","BaseFolderID") | % { 
    
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot,[UInt32]$Base,[UInt32]$Guid)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows",
            "CurrentVersion","Explorer",@("MyComputer\NameSpace","FolderDescriptions")[$Base],
            $This.xGuid($Guid) -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
                     "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
                     "{a0c69a99-21c8-4671-8703-7934162fcf1d}")[$Slot]
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Music folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Music folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Music folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Music folder in This PC (None)")
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
        PicturesIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "PicturesIconInThisPC"
            $This.DisplayName = "Pictures [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Pictures icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
    
            ForEach ($X in 0,1)
            {
                ($This.Path($X,0,0),$Null),
                ($This.Path($X,0,1),$Null),
                ("$($This.Path($X,1,2))\PropertyBag",$Null),
                ("$($This.Path($X,1,2))\PropertyBag","ThisPCPolicy"),
                ("$($This.Path($X,1,2))\PropertyBag","BaseFolderID") | % { 
    
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot,[UInt32]$Base,[UInt32]$Guid)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows",
            "CurrentVersion","Explorer",@("MyComputer\NameSpace","FolderDescriptions")[$Base],
            $This.xGuid($Guid) -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
                     "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
                     "{0ddd015d-b06c-45d5-8c4c-f59713854639}")[$Slot]
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Pictures folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Pictures folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Pictures folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Pictures folder in This PC (None)")
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
        VideosIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "VideosIconInThisPC"
            $This.DisplayName = "Videos [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the Videos icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
    
            ForEach ($X in 0,1)
            {
                ($This.Path($X,0,0),$Null),
                ($This.Path($X,0,1),$Null),
                ("$($This.Path($X,1,2))\PropertyBag",$Null),
                ("$($This.Path($X,1,2))\PropertyBag","ThisPCPolicy"),
                ("$($This.Path($X,1,2))\PropertyBag","BaseFolderID") | % { 
    
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot,[UInt32]$Base,[UInt32]$Guid)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows",
            "CurrentVersion","Explorer",@("MyComputer\NameSpace","FolderDescriptions")[$Base],
            $This.xGuid($Guid) -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
                     "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
                     "{35286a68-3c57-41a1-bbb1-0eae73d76c95}")[$Slot]
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Videos folder in This PC")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Videos folder in This PC (Shown)")
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
                    $This.Update(2,"Setting [~] Videos folder in This PC (Hidden)")
                    $This.Output[3].Set("String","Hide")
                    If ([Environment]::Is64BitOperatingSystem)
                    {
                        $This.Output[8].Set("String","Hide")
                    }
                }
                3
                {
                    $This.Update(3,"Setting [~] Videos folder in This PC (None)")
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
        ThreeDObjectsIconInThisPC([Object]$Console) : base($Console)
        {
            $This.Name        = "ThreeDObjectsIconInThisPC"
            $This.DisplayName = "3D Objects [Explorer]"
            $This.Value       = 1
            $This.Description = "Toggles the 3D Objects icon in 'This PC'"
            $This.Options     = "Skip", "Show/Add*", "Hide", "Remove"
            
            ForEach ($X in 0,1)
            {
                ("$($This.Path($X))\$($This.xGuid(0))",$Null),
                ("$($This.Path($X))\$($This.xGuid(1))\PropertyBag",$Null),
                ("$($This.Path($X))\$($This.xGuid(1))\PropertyBag","ThisPCPolicy") | % {
        
                    $This.Registry($_[0],$_[1])
                }
            }
        }
        [String] Path([UInt32]$Slot)
        {
            Return "HKLM:","SOFTWARE",@($Null,"WOW6432Node")[$Slot],"Microsoft","Windows","CurrentVersion",
            "Explorer","FolderDescriptions" -join "\"
        }
        [String] xGuid([UInt32]$Slot)
        {
            Return @("{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                     "{31C0DD25-9439-4F12-BF41-7FF4EDA38722}")[$Slot]
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
                            $This.Update(0,"Skipping [!] 3D Objects folder in This PC")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] 3D Objects folder in This PC (Shown)")
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
                        $This.Update(2,"Setting [~] 3D Objects folder in This PC (Hidden)")
                        $This.Output[2].Set("String","Hide")
                        If ([Environment]::Is64BitOperatingSystem)
                        {
                            $This.Output[5].Set("String","Hide")
                        }
                    }
                    3
                    {
                        $This.Update(3,"Setting [~] 3D Objects folder in This PC (None)")
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

    # // ===================
    # // | DesktopIcon (5) |
    # // ===================
	
    Enum DesktopType
    {
        ThisPCOnDesktop
        NetworkOnDesktop
        RecycleBinOnDesktop
        UsersFileOnDesktop
        ControlPanelOnDesktop
    }

    Class ThisPCOnDesktop : ControlTemplate
    {
        ThisPCOnDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "ThisPCOnDesktop"
            $This.DisplayName = "This PC [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'This PC' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ForEach ($Item in "ClassicStartMenu","NewStartPanel")
            {
                $This.Registry("$($This.RegPath())\$Item",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] This PC Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] This PC Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] This PC Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class NetworkOnDesktop : ControlTemplate
    {
        NetworkOnDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "NetworkOnDesktop"
            $This.DisplayName = "Network [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Network' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ForEach ($Item in "ClassicStartMenu","NewStartPanel")
            {
                $This.Registry("$($This.RegPath())\$Item",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}')
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Network Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Network Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Network Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class RecycleBinOnDesktop : ControlTemplate
    {
        RecycleBinOnDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "RecycleBinOnDesktop"
            $This.DisplayName = "Recycle Bin [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Recycle Bin' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ForEach ($Item in "ClassicStartMenu","NewStartPanel")
            {
                $This.Registry("$($This.RegPath())\$Item",'{645FF040-5081-101B-9F08-00AA002F954E}')
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Recycle Bin Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Recycle Bin Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Recycle Bin Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class UsersFileOnDesktop : ControlTemplate
    {
        UsersFileOnDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "UsersFileOnDesktop"
            $This.DisplayName = "My Documents [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Users File' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ForEach ($Item in "ClassicStartMenu","NewStartPanel")
            {
                $This.Registry("$($This.RegPath())\$Item",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}')
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Users file Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Users file Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Users file Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }
    
    Class ControlPanelOnDesktop : ControlTemplate
    {
        ControlPanelOnDesktop([Object]$Console) : base($Console)
        {
            $This.Name        = "ControlPanelOnDesktop"
            $This.DisplayName = "Control Panel [Desktop]"
            $This.Value       = 2
            $This.Description = "Toggles the 'Control Panel' icon on the desktop"
            $This.Options     = "Skip", "Show", "Hide*"
            
            ForEach ($Item in "ClassicStartMenu","NewStartPanel")
            {
                $This.Registry("$($This.RegPath())\$Item",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}')
            }
        }
        [String] RegPath()
        {
            Return "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Control Panel Icon on desktop")
                    }
                }
                1
                {
                    $This.Update(1,"Setting [~] Control Panel Icon on desktop (Shown)")
                    $This.Output[0].Set(0)
                    $This.Output[0].Set(0)
                }
                2
                {
                    $This.Update(2,"Setting [~] Control Panel Icon on desktop (Hidden)")
                    $This.Output[0].Set(1)
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    # // ==================
    # // | LockScreen (4) |
    # // ==================
	
    Enum LockScreenType
    {
        LockScreen
        LockScreenPassword
        PowerMenuLockScreen
        CameraOnLockScreen
    }

    Class LockScreen : ControlTemplate
    {
        LockScreen([Object]$Console) : base($Console)
        {
            $This.Name        = "LockScreen"
            $This.DisplayName = "Lock Screen"
            $This.Value       = 1
            $This.Description = "Toggles the lock screen"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            $This.Registry('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreen')
        }
        [String] Argument()
        {
            $Item = "HKLM","SOFTWARE","Microsoft","Windows","CurrentVersion","Authentication",
                    "LogonUI","SessionData" -join "\"
            Return "add $Item /t REG_DWORD /v AllowLockScreen /d 0 /f"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Lock Screen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Lock Screen")
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
                    $This.Update(2,"Disabling [~] Lock Screen")
                    If ($This.GetWinVersion() -ge 1607)
                    {
                        $Service             = New-Object -ComObject Schedule.Service
                        $Service.Connect()
                        $Task                = $Service.NewTask(0)
                        $Task.Settings.DisallowStartIfOnBatteries = $False
                        $Trigger             = $Task.Triggers.Create(9)
                        $Trigger             = $Task.Triggers.Create(11)
                        $Trigger.StateChange = 8
                        $Action              = $Task.Actions.Create(0)
                        $Action.Path         = 'Reg.exe'
                        $Action.Arguments    = $This.Argument()
                        $Service.GetFolder('\').RegisterTaskDefinition('Disable LockScreen',$Task,6,
                                                                       'NT AUTHORITY\SYSTEM',$Null,4)
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
        LockScreenPassword([Object]$Console) : base($Console)
        {
            $This.Name        = "LockScreenPassword"
            $This.DisplayName = "Lock Screen Password"
            $This.Value       = 1
            $This.Description = "Toggles the lock screen password"
            $This.Options     = "Skip", "Enable*", "Disable"

            ("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
            "ScreenSaverIsSecure"),
            ("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
            "ScreenSaverIsSecure") | % {

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
                        $This.Update(0,"Skipping [!] Lock Screen Password")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Lock Screen Password")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Lock Screen Password")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class PowerMenuLockScreen : ControlTemplate
    {
        PowerMenuLockScreen([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Power Menu on Lock Screen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Power Menu on Lock Screen")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Power Menu on Lock Screen")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class CameraOnLockScreen : ControlTemplate
    {
        CameraOnLockScreen([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Camera at Lockscreen")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Camera at Lockscreen")
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Camera at Lockscreen")
                    $This.Output[0].Set(1)
                }
            }
        }
    }

    # // =====================
    # // | Miscellaneous (9) |
    # // =====================
	
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

    Class ScreenSaver : ControlTemplate
    {
        ScreenSaver([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Screensaver")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Screensaver")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Screensaver")
                    $This.Output[0].Set(0)
                }
            }
        }
    }

    Class AccountProtectionWarn : ControlTemplate
    {
        AccountProtectionWarn([Object]$Console) : base($Console)
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
                            $This.Update(0,"Skipping [!] Account Protection Warning")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Account Protection Warning")
                        $This.Output[0].Remove()
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Account Protection Warning")
                        $This.Output[0].Set(1)
                    }
                }
            }
        }
    }

    Class ActionCenter : ControlTemplate
    {
        ActionCenter([Object]$Console) : base($Console)
        {
            $This.Name        = "ActionCenter"
            $This.DisplayName = "Action Center"
            $This.Value       = 1
            $This.Description = "Toggles system action center"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer',
            'DisableNotificationCenter'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications',
            'ToastEnabled') | % {

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
                        $This.Update(0,"Skipping [!] Action Center")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Action Center")
                    $This.Output[0].Remove()
                    $This.Output[1].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Action Center")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class StickyKeyPrompt : ControlTemplate
    {
        StickyKeyPrompt([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Sticky Key Prompt")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sticky Key Prompt")
                    $This.Output[0].Set("String",510)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sticky Key Prompt")
                    $This.Output[0].Set("String",506)
                }
            }
        }
    }

    Class NumbLockOnStart : ControlTemplate
    {
        NumbLockOnStart([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Num Lock on startup")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Num Lock on startup")
                    $This.Output[0].Set(2147483650)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Num Lock on startup")
                    $This.Output[0].Set(2147483648)
                }
            }
        }
    }

    Class F8BootMenu : ControlTemplate
    {
        F8BootMenu([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] F8 Boot menu options")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] F8 Boot menu options")
                    bcdedit /set `{current`} bootmenupolicy Legacy
                }
                2
                {
                    $This.Update(0,"Disabling [~] F8 Boot menu options")
                    bcdedit /set `{current`} bootmenupolicy Standard
                }
            }
        }
    }

    Class RemoteUACAcctToken : ControlTemplate
    {
        RemoteUACAcctToken([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Remote UAC Local Account Token Filter")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Remote UAC Local Account Token Filter")
                    $This.Output[0].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] Remote UAC Local Account Token Filter")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    Class HibernatePower : ControlTemplate
    {
        HibernatePower([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Hibernate Option")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Hibernate Option")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(1)
                    powercfg /HIBERNATE ON
                }
                2
                {
                    $This.Update(2,"Disabling [~] Hibernate Option")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                    powercfg /HIBERNATE OFF
                }
            }
        }
    }

    Class SleepPower : ControlTemplate
    {
        SleepPower([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Sleep Option")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Sleep Option")
                    $This.Output[0].Set(1)
                    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
                }
                2
                {
                    $This.Update(2,"Disabling [~] Sleep Option")
                    $This.Output[0].Set(0)
                    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
                }
            }
        }
    }

    # // ===================
    # // | PhotoViewer (2) |
    # // ===================
	
	Enum PhotoViewerType
    {
        PVFileAssociation
        PVOpenWithMenu
    }

    Class PVFileAssociation : ControlTemplate
    {
        PVFileAssociation([Object]$Console) : base($Console)
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
        [String] RunDll32()
        {
            Return "{0} `"{1}`", {2}" -f "%SystemRoot%\System32\rundll32.exe",
                                         "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll",
                                         "ImageView_Fullscreen %1"
        }
        [String] IExplore()
        {
            $Item = "$Env:SystemDrive\Program Files\Internet Explorer\iexplore.exe"
            Return "`"$Item`" %1"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] Photo Viewer File Association")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Photo Viewer File Association")
                    0..3 | % { 
    
                        $This.Output[$_  ].Set("ExpandString",
                                               "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
                        $This.Output[$_+4].Set("ExpandString",
                                               $This.RunDll32())
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Photo Viewer File Association")
                    $This.Output[0] | % { $_.Clear(); $_.Remove() }
                    $This.Output[1].Remove()
                    $This.Output[2] | % { $_.Clear(); $_.Remove() }
                    $This.Output[3] | % { $_.Clear(); $_.Remove() }
                    $This.Output[5].Set("String",
                                        $This.IExplore())
                    $This.Output[8].Set("String",
                                        "IE.File")
                    $This.Output[9].Set("String",
                                        "{17FE9752-0B5A-4665-84CD-569794602F5C}")
                }
            }
        }
    }

    Class PVOpenWithMenu : ControlTemplate
    {
        PVOpenWithMenu([Object]$Console) : base($Console)
        {
            $This.Name        = "PVOpenWithMenu"
            $This.DisplayName = "Photo Viewer 'Open with' Menu"
            $This.Value       = 2
            $This.Description = "Allows image files to be opened with Photo Viewer"
            $This.Options     = "Skip", "Enable", "Disable*"

            ('HKCR:\Applications\photoviewer.dll\shell\open',$Null),
            ('HKCR:\Applications\photoviewer.dll\shell\open\command',$Null),
            ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget',$Null),
            ('HKCR:\Applications\photoviewer.dll\shell\open','MuiVerb'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\command','(Default)'),
            ('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget','Clsid') | % {

                $This.Registry($_[0],$_[1])
            }
        }
        [String] RunDll32()
        {
            Return "{0} `"{1}`", {2}" -f "%SystemRoot%\System32\rundll32.exe",
                                         "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll",
                                         "ImageView_Fullscreen %1"
        }
        SetMode([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            Switch ($Mode)
            {
                0
                {
                    If ($ShowSkipped)
                    {
                        $This.Update(0,"Skipping [!] 'Open with Photo Viewer' context menu item")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] 'Open with Photo Viewer' context menu item")
                    $This.Output[1].Get()
                    $This.Output[2].Get()
                    $This.Output[3].Set("String",
                                        "@photoviewer.dll,-3043")
                    $This.Output[4].Set("ExpandString",
                                        $This.RunDll32())
                    $This.Output[5].Set("String",
                                        "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}")
                }
                2
                {
                    $This.Update(2,"Disabling [~] 'Open with Photo Viewer' context menu item")
                    $This.Output[0].Remove()
                }
            }
        }
    }

    <#
    Class DisableVariousTasks
    {
        [UInt32] $Mode
        [Object] $Output
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
                        $This.Update(0,"Skipping [!] Various Scheduled Tasks"
                    }
                }
                1
                {
                    $This.Update(0,"Enabling [~] Various Scheduled Tasks"
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Enable-ScheduledTask }
                }
                2
                {
                    $This.Update(0,"Disabling [~] Various Scheduled Tasks"
                    $TaskList | % { Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask }
                }
            }
        }
    }
    
    Class ScreenSaverWaitTime
    {
        [UInt32] $Mode
        [Object] $Output
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
                        $This.Update(0,"Skipping [!] ScreenSaver Wait Time")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] ScreenSaver Wait Time")
                }
                2
                {
                    $This.Update(0,"Disabling [~] ScreenSaver Wait Time"
                }
            }
        }
    }
    #>

    # // ===================
    # // | WindowsApps (7) |
    # // ===================
	
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

    Class OneDrive : ControlTemplate
    {
        OneDrive([Object]$Console) : base($Console)
        {
            $This.Name        = "OneDrive"
            $This.DisplayName = "OneDrive"
            $This.Value       = 1
            $This.Description = "Toggles Microsoft OneDrive, which comes with the operating system"
            $This.Options     = "Skip", "Enable*", "Disable"
            
            ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive',
            'DisableFileSyncNGSC'),
            ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
            'ShowSyncProviderNotifications') | % {

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
                        $This.Update(0,"Skipping [!] OneDrive")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] OneDrive")
                    $This.Output[0].Remove()
                    $This.Output[1].Set(1)
                }
                2
                {
                    $This.Update(2,"Disabling [~] OneDrive")
                    $This.Output[0].Set(1)
                    $This.Output[1].Set(0)
                }
            }
        }
    }

    Class OneDriveInstall : ControlTemplate
    {
        OneDriveInstall([Object]$Console) : base($Console)
        {
            $This.Name        = "OneDriveInstall"
            $This.DisplayName = "OneDriveInstall"
            $This.Value       = 1
            $This.Description = "Installs/Uninstalls Microsoft OneDrive, which comes with the operating system"
            $This.Options     = "Skip", "Installed*", "Uninstall"
            
            ("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",$Null),
            ("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",$Null) | % {
    
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
                        $This.Update(0,"Skipping [!] OneDrive Install")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] OneDrive Install")
                    If ($This.TestPath()) 
                    {
                        Start-Process $This.GetOneDrivePath() -NoNewWindow 
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] OneDrive Install")
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
            $Item = @("System32","SysWOW64")[[Environment]::Is64BitOperatingSystem] 
            Return "$Env:Windir\$Item\OneDriveSetup.exe"
        }
        [Bool] TestPath()
        {
            Return Test-Path $This.GetOneDrivePath() -PathType Leaf
        }
    }

    Class XboxDVR : ControlTemplate
    {
        XboxDVR([Object]$Console) : base($Console)
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
                        $This.Update(0,"Skipping [!] Xbox DVR")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Xbox DVR")
                    $This.Output[0].Set(1)
                    $This.Output[0].Remove()
                }
                2
                {
                    $This.Update(2,"Disabling [~] Xbox DVR")
                    $This.Output[0].Set(0)
                    $This.Output[1].Set(0)
                }
            }
        }
    }
    
    Class MediaPlayer : ControlTemplate
    {
        MediaPlayer([Object]$Console,[Object]$Features) : base($Console)
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
                        $This.Update(0,"Skipping [!] Windows Media Player")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Windows Media Player")
                    $This.Output[0] | ? State -ne Enabled | % { 
                        
                        Enable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart 
                    }
                    
                    If (!!$?)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Windows Media Player")
                    $This.Output[0] | ? State -eq Enabled | % { 
                        
                        Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart 
                    }

                    If (!!$?)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class WorkFolders : ControlTemplate
    {
        WorkFolders([Object]$Console,[Object]$Features) : base($Console)
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
                        $This.Update(0,"Skipping [!] Work Folders Client")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Work Folders Client")
                    $This.Output[0] | ? State -ne Enabled | % { 
                        
                        Enable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart 
                    }

                    If (!!$?)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Work Folders Client")
                    $This.Output[0] | ? State -eq Enabled | % { 
                        
                        Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart 
                    }

                    If (!!$?)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class FaxAndScan : ControlTemplate
    {
        FaxAndScan([Object]$Console,[Object]$Features) : base($Console)
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
                        $This.Update(0,"Skipping [!] Fax And Scan")
                    }
                }
                1
                {
                    $This.Update(1,"Enabling [~] Fax And Scan")
                    $This.Output[0] | ? State -ne Enabled | % {
                        
                        Enable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart 
                    }

                    If (!!$?)
                    {
                        $This.Output[0].State = "Enabled"
                    }
                }
                2
                {
                    $This.Update(2,"Disabling [~] Fax And Scan")
                    $This.Output[0] | ? State -eq Enabled | % { 
                        
                        Disable-WindowsOptionalFeature -Online -FeatureName FaxServicesClientPackage -NoRestart 
                    }

                    If (!!$?)
                    {
                        $This.Output[0].State = "Disabled"
                    }
                }
            }
        }
    }

    Class LinuxSubsystem : ControlTemplate
    {
        LinuxSubsystem([Object]$Console,[Object]$Features) : base($Console)
        {
            $This.Name        = "LinuxSubsystem"
            $This.DisplayName = "Linux Subsystem (WSL)"
            $This.Value       = 2
            $This.Description = "For Windows 1607+, this toggles the $($This.Feature())"
            $This.Options     = "Skip", "Installed", "Uninstall*"
    
            $This.Output      = @($Features | ? FeatureName -match $This.Feature())
    
            'AllowDevelopmentWithoutDevLicense','AllowAllTrustedApps' | % {
    
                $This.Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',$_)
            }
        }
        [String] Feature()
        {
            Return "Microsoft-Windows-Subsystem-Linux"
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
                            $This.Update(0,"Skipping [!] Linux Subsystem")
                        }
                    }
                    1
                    {
                        $This.Update(1,"Enabling [~] Linux Subsystem")
                        $This.Output[0] | ? State -ne Enabled | % { 
                            
                            Enable-WindowsOptionalFeature -Online -FeatureName $This.Feature() -NoRestart 
                        }
    
                        If (!!$?)
                        {
                            $This.Output[0].State = "Enabled"
                        }
                    }
                    2
                    {
                        $This.Update(2,"Disabling [~] Linux Subsystem")
                        $This.Output[0] | ? State -eq Enabled | % { 
                            
                            Disable-WindowsOptionalFeature -Online -FeatureName $This.Feature() -NoRestart 
                        }
    
                        If (!!$?)
                        {
                            $This.Output[0].State = "Disabled"
                        }
                    }
                }
            }
            Else
            {
                $This.Update(-1,"Error [!] This version of Windows does not support (WSL/Windows Subsystem for Linux)")
            }
        }
    }

    # // =======================
    # // | Controls Controller |
    # // =======================


    Class ControlController : GenericList
    {
        Hidden [Object] $Module
        ControlController([String]$Name,[Object]$Module) : Base($Name)
        {
            $This.Module = $Module
        }
        Update([Int32]$State,[String]$Status)
        {
            $This.Module.Update($State,$Status)
            $Last = $This.Module.Console.Last()
            If ($This.Module.Mode -ne 0)
            {
                [Console]::WriteLine($Last.String)
            }
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Source in $This.GetSourceList())
            {
                $This.Update(0,"[~] Controls: $Source")
                ForEach ($Name in [System.Enum]::GetNames("$Source`Type"))
                {
                    $Item = $This.New($Source,$Name)

                    $This.Update(1,$Item.Status)

                    $This.Add($Item)
                }
                $This.Update(1,"[+] Controls: $Source")
            }
        }
        [String[]] GetSourceList()
        {
            Return "Privacy",
                   "WindowsUpdate",
                   "Service",
                   "Context",
                   "Taskbar",
                   "StartMenu",
                   "Explorer",
                   "ThisPC",
                   "Desktop",
                   "Lockscreen",
                   "Miscellaneous",
                   "PhotoViewer"
        }
        [Object] New([String]$Source,[String]$Name)
        {
            $Item         = ([Type]$Name)::New($This.Module.Console)
            $Item.Source  = $Source
            $Item.SetStatus()

            Return $Item
        }
    }

    # // =====================
    # // | System Controller |
    # // =====================

    Class SystemController
    {
        [Object]          $Module
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object]  $ComputerSystem
        [Object]         $Current
        [Object]         $Edition
        [Object]        $Snapshot
        [Object]          $HotFix
        [Object]         $Feature
        [Object]            $AppX
        [Object]     $Application
        [Object]           $Event
        [Object]            $Task
        [Object]       $Processor
        [Object]            $Disk
        [Object]         $Network
        [Object]         $Control
        SystemController()
        {
            $This.Module = $This.Get("Module")
            $This.Main()
        }
        SystemController([Object]$Module)
        {
            $This.Module = $Module
            $This.Main()
        }
        Update([Int32]$State,[String]$Status)
        {
            $This.Module.Update($State,$Status)
            $Last = $This.Module.Console.Last()
            If ($This.Module.Mode -ne 0)
            {
                [Console]::WriteLine($Last.String)
            }
        }
        [String] Start()
        {
            Return $This.Module.Console.Start.Time.ToString("yyyy-MMdd-HHmmss")
        }
        [String] CurrentVersion()
        {
            Return "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        }
        Main()
        {
            $This.Module.Mode     = 1

            # [Firmware/System]
            $This.BiosInformation = $This.Get("Bios")
            $This.OperatingSystem = $This.Get("OS")
            $This.ComputerSystem  = $This.Get("CS")
            $This.Current         = $This.Get("Current")
            $This.Edition         = $This.Get("Edition")
            $This.Snapshot        = $This.Get("Snapshot")

            # [Software]
            $This.HotFix          = $This.Get("HotFix")
            $This.Feature         = $This.Get("Feature")
            $This.AppX            = $This.Get("AppX")
            $This.Application     = $This.Get("Application")
            $This.Event           = $This.Get("Event")
            $This.Task            = $This.Get("Task")
            
            # [Hardware]
            $This.Processor       = $This.Get("Processor")
            $This.Disk            = $This.Get("Disk")
            $This.Network         = $This.Get("Network")

            # [Controls]
            $This.Control         = $This.Get("Control")

            $This.Refresh()
        }
        Refresh()
        {
            ForEach ($Item in "Snapshot",
                              "HotFix",
                              "Feature",
                              "AppX",
                              "Application",
                              "Event",
                              "Task",
                              "Processor",
                              "Disk",
                              "Network",
                              "Control")
            {
                $This.Refresh($Item)
            }
        }
        Refresh([String]$Name)
        {
            Switch ($Name)
            {
                Snapshot
                {
                    $This.Update(0,"Populating [~] Snapshot")

                    $This.Snapshot.Start        = $This.Start()
                    $This.Snapshot.ComputerName = $This.Env("MachineName")
                    $This.Snapshot.Name         = $This.Snapshot.ComputerName.ToLower()
                    $This.Snapshot.DisplayName  = "{0}-{1}" -f $This.Snapshot.Start, $This.Snapshot.ComputerName
                    $This.Snapshot.PartOfDomain = $This.ComputerSystem.Computer.System.PartOfDomain
                    $This.Snapshot.NetBIOS      = $This.Env("UserDomainName").ToLower()
                    $This.Snapshot.Dns          = [Environment]::GetEnvironmentVariable("UserDNSDomain")
                    $This.Snapshot.Hostname     = @($This.Snapshot.Name;"{0}.{1}" -f $This.Snapshot.Name, $This.Snapshot.Dns)[$This.Snapshot.PartOfDomain].ToLower()
                    $This.Snapshot.Username     = $This.Env("UserName")
                    $This.Snapshot.Principal    = $This.Get("Principal")
                    $This.Snapshot.IsAdmin      = $This.Snapshot.CheckAdmin()
                    $This.Snapshot.Caption      = $This.OperatingSystem.Caption
                    $This.Snapshot.Version      = $This.Module.OS.Tx("Host","Version").ToString()
                    $This.Snapshot.ReleaseId    = $This.Edition.Current.Codename
                    $This.Snapshot.Build        = $This.Edition.Current.Build
                    $This.Snapshot.Description  = $This.Edition.Current.Description
                    $This.Snapshot.SKU          = $This.GetSKU()
                    $This.Snapshot.Chassis      = $This.ComputerSystem.Chassis
                    $This.Snapshot.Guid         = $This.Get("Guid")
        
                    $This.Update(1,"Snapshot [+] $($This.Snapshot.Guid)")
                }
                HotFix      
                { 
                    $This.Update(0,"[~] Hot Fixes")

                    $Object = $This.HotFix
                    $Object.Clear()

                    ForEach ($HotFix in $Object.GetObject())
                    {
                        $Item = $Object.New($HotFix)

                        $This.Update(1,$Item.Status)

                        $Object.Add($HotFix)
                    }

                    $This.Update(1,"[+] Hot Fixes")
                }
                Feature
                {
                    $This.Update(0,"[~] Optional Features")

                    $Object = $This.Feature
                    $Object.Clear()
                
                    ForEach ($Feature in $Object.GetObject())
                    {
                        $Item = $Object.New($Feature)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }
                    
                    $This.Update(0,"[+] Optional Features")
                }
                AppX
                { 
                    $This.Update(0,"[~] Provisioned AppX Packages")

                    $Object = $This.AppX
                    $Object.Clear()
        
                    ForEach ($AppX in $Object.GetObject())
                    {
                        $Item = $Object.New($AppX)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Provisioned AppX Packages")
                }
                Application
                { 
                    $This.Update(0,"[~] Applications")

                    $Object = $This.Application 
                    $Object.Clear()

                    ForEach ($Application in $Object.GetObject())
                    {
                        $Item = $Object.New($Application)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Applications")
                }
                Event
                {
                    $This.Update(0,"[~] Event Logs")

                    $Object = $This.Event
                    $Object.Clear()

                    ForEach ($WinEvent in $Object.GetObject())
                    {
                        $Item = $Object.New($WinEvent)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Event Logs")
                }
                Task
                {
                    $This.Update(0,"[~] Scheduled Tasks")

                    $Object = $This.Task
                    $Object.Clear()

                    ForEach ($Task in $Object.GetObject())
                    {
                        $Item = $Object.New($Task)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Scheduled Tasks")
                }
                Processor
                {
                    $This.Update(0,"[~] Processor(s)")

                    $Object = $This.Processor
                    $Object.Clear()

                    ForEach ($CPU in $Object.GetObject())
                    {
                        $Item = $Object.New($Cpu)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Processor(s)")
                }
                Disk
                {
                    $This.Update(0,"[~] Disk(s)")

                    $Object = $This.Disk
                    $Object.Clear()

                    $DiskDrive         = $Object.Get("DiskDrive")
                    $MsftDisk          = $Object.Get("MsftDisk")
                    $DiskPartition     = $Object.Get("DiskPartition")
                    $LogicalDisk       = $Object.Get("LogicalDisk")
                    $LogicalDiskToPart = $Object.Get("LogicalDiskToPart")
            
                    ForEach ($Drive in $DiskDrive | ? MediaType -match Fixed)
                    {
                        # [Disk Template]
                        $Item     = $Object.New($Drive)
            
                        # [MsftDisk]
                        $Msft     = $MsftDisk | ? Number -eq $Item.Index
                        If ($Msft)
                        {
                            $Item.MsftDisk($Msft)
                        }
            
                        # [Partitions]
                        ForEach ($Partition in $DiskPartition | ? DiskIndex -eq $Item.Index)
                        {
                            $Item.Partition.Add($Object.PartitionItem($Item.Partition.Count,$Partition))
                        }
            
                        # [Volumes]
                        ForEach ($Logical in $LogicalDiskToPart | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name })
                        {
                            $Drive      = $LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                            $Partition  = $DiskPartition | ?     Name -eq $Logical.Antecedent.DeviceID
                            If ($Drive -and $Partition)
                            {
                                $Item.Volume.Add($Object.VolumeItem($Item.Volume.Count,$Drive,$Partition))
                            }
                        }

                        $Item.SetStatus()
            
                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Disk(s)")
                }
                Network
                {
                    $This.Update(0,"[~] Network Adapter(s)")

                    $Object = $This.Network
                    $Object.Clear()

                    ForEach ($Network in $Object.GetObject())
                    {
                        $Item = $Object.New($Network)

                        $This.Update(1,$Item.Status)

                        $Object.Add($Item)
                    }

                    $This.Update(1,"[+] Network Adapter(s)")
                }
                Control
                {
                    $This.Update(0,"[~] System Controls")

                    $Object = $This.Control
                    $Object.Clear()

                    ForEach ($Source in $Object.GetSourceList())
                    {
                        $This.Update(0,"[~] Controls: $Source")

                        ForEach ($Name in [System.Enum]::GetNames("$Source`Type"))
                        {
                            $Item = $Object.New($Source,$Name)
        
                            $This.Update(1,$Item.Status)
        
                            $Object.Add($Item)
                        }

                        $This.Update(1,"[+] Controls: $Source")
                    }
                }
            }
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Module
                {
                    Get-FEModule -Mode 1
                }
                Bios
                {
                    $This.Update(0,"Getting [~] Bios Information")
                    [BiosInformation]::New()
                }
                OS
                {
                    $This.Update(0,"Getting [~] Operating System")
                    [OperatingSystem]::New()
                }
                CS
                {
                    $This.Update(0,"Getting [~] Computer System")
                    [ComputerSystem]::New()
                }
                Current
                {
                    $This.Update(0,"Getting [~] Current Version")
                    [CurrentVersion]::New()
                }
                Edition
                {
                    $This.Update(0,"Getting [~] Edition")
                    [EditionController]::New($This.Current)
                }
                Snapshot
                {
                    $This.Update(0,"Getting [~] Snapshot")
                    [Snapshot]::New()
                }
                Principal
                {
                    $This.Update(0,"Getting [~] Windows Principal")
                    [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                }
                Guid
                {
                    $This.Update(0,"Getting [~] GUID")
                    [Guid]::NewGuid()
                }
                HotFix
                {
                    $This.Update(0,"Getting [~] HotFix")
                    [HotFixController]::New("HotFix")
                }
                Feature
                {
                    $This.Update(0,"Getting [~] Windows Optional Features")
                    [FeatureController]::New("Feature")
                }
                AppX
                {
                    $This.Update(0,"Getting [~] AppX")
                    [AppXController]::New("AppX")
                }
                Application
                {
                    $This.Update(0,"Getting [~] Applications")
                    [ApplicationController]::New("Application")
                }
                Task
                {
                    $This.Update(0,"Getting [~] Scheduled Tasks")
                    [ScheduledTaskController]::New("Task")
                }
                Event
                {
                    $This.Update(0,"Getting [~] Event Logs")
                    [EventLogProviderController]::New("Event")
                }
                Processor
                {
                    $This.Update(0,"Getting [~] Processor(s)")
                    [ProcessorController]::New($False,"Processor")
                }
                Disk
                {
                    $This.Update(0,"Getting [~] System Disk(s)")
                    [DiskController]::New($False,"Disk")
                }
                Network
                {
                    $This.Update(0,"Getting [~] Network Adapter(s)")
                    [NetworkController]::New($False,"Network")
                }
                Control
                {
                    $This.Update(0,"Getting [~] System Controls")
                    [ControlController]::New("Control",$This.Module)
                }
            }

            Return $Item
        }
        [String] GetSku()
        {
            $Out = ("Undefined,Ultimate {0},Home Basic {0},Home Premium {0},{3} {0},Home Basic N {"+
            "0},Business {0},Standard {2} {0},Datacenter {2} {0},Small Business {2} {0},{3} {2} {0"+
            "},Starter {0},Datacenter {2} Core {0},Standard {2} Core {0},{3} {2} Core {0},{3} {2} "+
            "IA64 {0},Business N {0},Web {2} {0},Cluster {2} {0},Home {2} {0},Storage Express {2} "+
            "{0},Storage Standard {2} {0},Storage Workgroup {2} {0},Storage {3} {2} {0},{2} For Sm"+
            "all Business {0},Small Business {2} Premium {0},TBD,{1} {3},{1} Ultimate,Web {2} Core"+
            ",-,-,-,{2} Foundation,{1} Home {2},-,{1} {2} Standard No Hyper-V Full,{1} {2} Datacen"+
            "ter No Hyper-V Full,{1} {2} {3} No Hyper-V Full,{1} {2} Datacenter No Hyper-V Core,{1"+
            "} {2} Standard No Hyper-V Core,{1} {2} {3} No Hyper-V Core,Microsoft Hyper-V {2},Stor"+
            "age {2} Express Core,Storage {2} Standard Core,{2} Workgroup Core,Storage {2} {3} Cor"+
            "e,Starter N,Professional,Professional N,{1} Small Business {2} 2011 Essentials,-,-,-,"+
            "-,-,-,-,-,-,-,-,-,Small Business {2} Premium Core,{1} {2} Hyper Core V,-,-,-,-,-,-,-,"+
            "-,-,-,-,-,-,-,-,-,-,-,--,-,-,{1} Thin PC,-,{1} Embedded Industry,-,-,-,-,-,-,-,{1} RT"+
            ",-,-,Single Language N,{1} Home,-,{1} Professional with Media Center,{1} Mobile,-,-,-"+
            ",-,-,-,-,-,-,-,-,-,-,{1} Embedded Handheld,-,-,-,-,{1} IoT Core") -f "Edition",("Wind"+
            "ows"),"Server","Enterprise"
                
            Return $Out.Split(",")[$This.OperatingSystem.OS.OperatingSystemSku]
        }
        [String] Env([String]$Name)
        {
            Return [Environment]::$Name
        }
        [String] ToString()
        {
            Return "<FEModule.System[Controller]>"
        }
    }

    # // ====================
    # // | Profile Controls |
    # // ====================

    Enum ProfileModeType
    {
        View
        Export
        Import
    }

    Class ProfileModeItem
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        ProfileModeItem([String]$Name)
        {
            $This.Index = [UInt32][ProfileModeType]::$Name
            $This.Name  = [ProfileModeType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ProfileModeList
    {
        [Object] $Output
        ProfileModeList()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([ProfileModeType]))
            {
                $Item = [ProfileModeItem]::New($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    View   { "View the current profile"  }
                    Export { "Prepare to export profile" }
                    Import { "Prepare to import profile" }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ProfileMode[List]>"
        }
    }

    Enum ProfileProcessType
    {
        File
        Transfer
    }

    Class ProfileProcessItem
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        ProfileProcessItem([String]$Name)
        {
            $This.Index = [UInt32][ProfileProcessType]::$Name
            $This.Name  = [ProfileProcessType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ProfileProcessList
    {
        [Object] $Output
        ProfileProcessList()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([ProfileProcessType]))
            {
                $Item             = [ProfileProcessItem]::New($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    File     { "Import/export via file"     }
                    Transfer { "Import/export via transfer" }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ProfileProcess[List]>"
        }
    }

    # // ===================================
    # // | ViperBomb Configuration Classes |
    # // ===================================

    Class ViperBombConfigFile
    {
        [String] $Type
        [String] $Name
        [String] $Fullname
        [UInt32] $Value
        ViperBombConfigFile([String]$Type,[String]$Time,[String]$Path)
        {
            $This.Type     = $Type
            $This.Name     = $This.GetName($Time)
            $This.Fullname = $This.GetFullname($Path)
        }
        SetValue([UInt32]$Value)
        {
            $This.Value    = $Value
        }
        [String] GetName([String]$Time)
        {
            $Extension = Switch ($This.Type)
            {
                Service  { "log" }
                Script   { "log" }
                Registry { "reg" }
                Config   { "csv" }
            }

            Return "{0}-{1}.{2}" -f $Time, $This.Type, $Extension
        }
        [String] GetFullname([String]$Path)
        {
            Return "{0}\{1}" -f $Path, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBombConfig[File]>"
        }
    }

    Class ViperBombConfig
    {
        [Object]             $Slot
        [String]             $Time
        [String]             $Path
        [Object]             $File
        [UInt32]        $DevErrors = 0
        [UInt32]           $DevLog = 0
        [UInt32]       $DevConsole = 0
        [UInt32]        $DevReport = 0
        [UInt32]      $BypassBuild = 0
        [UInt32]    $BypassEdition = 0
        [UInt32]     $BypassLaptop = 0
        [UInt32]    $DisplayActive = 1
        [UInt32]  $DisplayInactive = 1
        [UInt32]   $DisplaySkipped = 1
        [UInt32]     $MiscSimulate = 0
        [UInt32]         $MiscXbox = 1
        [UInt32]       $MiscChange = 0
        [UInt32] $MiscStopDisabled = 0
        [UInt32]       $LogService = 0
        [UInt32]        $LogScript = 0
        [UInt32]   $BackupRegistry = 0
        [UInt32]     $BackupConfig = 0
        [Object]       $Preference
        [Object]           $Option
        [Object]          $Service
        [Object]           $Filter
        [Object]          $Profile
        [Object]          $Process
        ViperBombConfig()
        {
            $This.Time       = $This.GetTime()
            $This.File       = @( )
            $This.Preference = $This.Get("Preference")
            $This.Option     = $This.Get("Option")
            $This.Service    = $This.Get("Service")
            $This.Filter     = $This.Get("Filter")
            $This.Profile    = $This.Get("Profile")
            $This.Process    = $This.Get("Process")
        }
        [String] GetTime()
        {
            Return [DateTime]::Now.ToString("yyyyMMdd-HHmmss")
        }
        [String[]] FileType()
        {
            Return "Service Script Registry Config" -Split " "
        }
        [Object] ViperBombConfigFile([String]$Type)
        {
            Return [ViperBombConfigFile]::New($Type,$This.Time,$This.Path)
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Preference {   [ServicePreferenceSlotList]::New() }
                Option     { [ServicePreferenceOptionList]::New() }
                Service    {          [ServiceProfileList]::New() }
                Filter     {           [ServiceFilterList]::New() }
                Profile    {             [ProfileModeList]::New() }
                "Process"  {          [ProfileProcessList]::New() }
            }

            Return $Item
        }
        SetPath([String]$Path)
        {
            If (Test-Path $Path)
            {
                $This.Path = $Path
                $This.SetFile()
            }
        }
        SetFile()
        {
            $This.File = @( )
            ForEach ($Name in $This.FileType())
            {
                $This.File += $This.ViperBombConfigFile($Name)
            }
        }
        SetOption([String]$Name,[UInt32]$Value)
        {
            $Item       = $This.Option.Output | ? Name -eq $Name
            $Item.SetValue($Value)
        }
        SetDefault([String]$Caption)
        {
            $Name = Switch -Regex ($Caption)
            {
                Default { "HomeMax" } "(Pro|Server)" { "ProMax" }
            }

            $Item = $This.GetSlot($Name)
            $This.SetSlot($Item.Index)
        }
        SetSlot([UInt32]$Index)
        {
            $This.Slot = $This.Service.Output | ? Index -eq $Index
        }
        [Object] GetSlot([String]$Name)
        {
            Return $This.Service.Output | ? Type -eq $Name
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb[Config]>"
        }
    }

    # // ================================
    # // | ViperBomb Controller Classes |
    # // ================================

    Class ViperBombProperty
    {
        [String]  $Name
        [Object] $Value
        ViperBombProperty([Object]$Property)
        {
            $This.Name  = $Property.Name
            $This.Value = $Property.Value -join ", "
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmController[Property]>"
        }
    }

    Class ViperBombFlag
    {
        [UInt32] $Index
        [String] $Name
        [UInt32] $Status
        ViperBombFlag([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.SetStatus(0)
        }
        SetStatus([UInt32]$Status)
        {
            $This.Status = $Status
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb[Flag]>"
        }
    }

    Class ViperBombController
    {
        [Object] $Module
        [Object] $Xaml
        [Object] $Config
        [Object] $System
        [Object] $Service
        [Object] $Control
        [Object] $Profile
        [Object] $Flag
        ViperBombController()
        {
            $This.Module      = Get-FEModule -Mode 1
            $This.Module.Mode = 0
            $This.Xaml        = $This.Get("Xaml")
            $This.System      = $This.Get("System")
            $This.Service     = $This.Get("Service")
            $This.Config      = $This.Get("Config")
            $This.Control     = $This.Get("Control")
            $This.Control.Reset()

            $This.Profile     = $This.Get("Profile")
            $This.Flag        = @( )

            ForEach ($Name in "ServiceOptionPath",
                              "ProfileTarget")
            {
                $This.Flag += $This.ViperBombFlag($This.Flag.Count,$Name)
            }

            $This.Flush()
        }
        Update([UInt32]$Mode,[String]$State)
        {
            $This.Module.Console.Update($Mode,$State)
            $Last = $This.Module.Console.Last()
            If ($This.Xaml)
            {
                $This.Xaml.IO.Console.Items.Add($Last)
            }

            If ($This.Module.Mode -eq 0)
            {
                [Console]::WriteLine($Last.ToString())
            }
        }
        Flush()
        {
            $This.Reset($This.Xaml.IO.Console,$This.Module.Console.Output)
        }
        [Void] Reset([Object]$xSender,[Object]$Content)
        {
            If ($This.Module.Mode -eq 2)
            {
                $This.Update(0,"Resetting [~] $($xSender.Name)")
            }

            $xSender.Items.Clear()
            ForEach ($Object in $Content)
            {
                $xSender.Items.Add($Object) | Out-Null
            }
        }
        [Object] Get([String]$Name)
        {
            $Item = Switch ($Name)
            {
                Xaml
                {
                    $This.Update(0,"Gathering [~] Xaml Interface")
                    [XamlWindow][ViperBombXaml]::Content
                }
                System
                {
                    $This.Update(0,"Gathering [~] System Snapshot")
                    [SnapshotController]::New($This.Module)
                }
                Config
                {
                    $This.Update(0,"Gathering [~] Default Config")
                    [ViperBombConfig]::New()
                }
                Service
                {
                    $This.Update(0,"Gathering [~] System Services")
                    [ServiceController]::New($This.Module.Console)
                }
                Control
                {
                    $This.Update(0,"Gathering [~] System Controls")
                    [SystemController]::New($This.Module.Console)
                }
                Profile
                {
                    $This.Update(0,"Gathering [~] User Profiles")
                    Get-UserProfile
                }
            }

            Return $Item
        }
        [String] Escape([String]$String)
        {
            Return [Regex]::Escape($String)
        }
        [String] Runtime()
        {
            Return [DateTime]::Now.ToString("yyyyMMdd_HHmmss")
        }
        [Object] ViperBombProperty([Object]$Property)
        {
            Return [ViperBombProperty]::New($Property)
        }
        [Object] ViperBombFlag([UInt32]$Index,[String]$Name)
        {
            Return [ViperBombFlag]::New($Index,$Name)
        }
        [Object] Option([String]$Name)
        {
            Return $This.Config.Option.Output | ? Name -eq $Name
        }
        [String] LogPath()
        {
            Return "{0}\{1}\ViperBomb" -f $This.Module.ProgramData(), $This.Module.Company
        }
        [String] Label()
        {
            Return "{0}[System Control Extension Utility]" -f $This.Module.Label()
        }
        [String] AboutBlackViper()
        {
            Return ("BlackViper is the original author of the Black Viper "+
            "Service Configuration featured on his website. `nThe original"+
            " utility dealt with (*.bat) files to provide a service config"+
            "uration template for Windows services, dating back to the day"+
            "s of Windows (2000/XP).")
        }
        [String] AboutMadBomb122()
        {
            Return ("MadBomb122 is the author of the Windows PowerShell (G"+
            "UI/graphical user interface) tool that adopted Black Viper&ap"+
            "os;s service configuration (*.bat) files in a prior version o"+
            "f this utility, which is featured on his [GitHub] repository "+
            "above.")
        }
        [String] IconStatus([UInt32]$Flag)
        {
            $File = @("failure.png","success.png","warning.png")[$Flag]
            Return $This.Module._Control($File).Fullname
        }
        [Object[]] Property([Object]$Object)
        {
            Return $Object.PSObject.Properties | % { $This.ViperBombProperty($_) }
        }
        [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
        {
            $List = $Object.PSObject.Properties
            $Item = Switch ($Mode)
            {
                0 { $List | ? Name -notin $Property } 1 { $List | ? Name -in $Property }
            }
    
            Return $Item | % { $This.ViperBombProperty($_) }
        }
        FolderBrowse([String]$Name)
        {
            $This.Update(0,"Browsing [~] Folder: [$Name]")
            $Object      = $This.Xaml.IO.$Name
            $Item        = New-Object System.Windows.Forms.FolderBrowserDialog
            $Item.ShowDialog()
        
            $Object.Text = @("<Select a path>",$Item.SelectedPath)[!!$Item.SelectedPath]
        }
        CheckPath([String]$Name)
        {
            $Item        = $This.Xaml.Get($Name)
            $Icon        = $This.Xaml.Get("$Name`Icon")
            $xFlag       = $This.Flag | ? Name -eq $Name
            
            If ([System.IO.Directory]::Exists($Item.Text))
            {
                $xFlag.SetStatus(1)
            }
            ElseIf ([System.IO.Directory]::Exists((Split-Path $Item.Text)))
            {
                $xFlag.SetStatus(2)
            }
            Else
            {
                $xFlag.SetStatus(0)
            }
    
            $Icon.Source = $This.IconStatus($xFlag.Status)
        }
        ConstructPath([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                New-Item $Path -ItemType Directory -Verbose
            }
        }
        BuildPath([String]$Path)
        {
            $Split = $Path.Split("\")
            $Base  = $Split[0]
            $Count = $Split.Count - 1
            Switch ($Count)
            {
                {$_ -gt 1}
                {
                    ForEach ($X in $Split[1..$Count])
                    {
                        $Base = "{0}\{1}" -f $Base, $Split[$X]
                        $This.ConstructPath($Base)
                    }
                }
                {$_ -eq 1}
                {
                    $Base = "{0}\{1}" -f $Base, $Split[1]
                    $This.ConstructPath($Base)
                }
            }
        }
        SetSlot([UInt32]$Slot)
        {
            If (!$This.Service)
            {
                $This.Service = $This.GetServices()
            }

            $This.Service.SetSlot($Slot)
            $This.Reset($This.Xaml.IO.ServiceOutput,$This.Service.Output)
        }
        [String[]] Grid([String]$Slot)
        {
            $Item = Switch ($Slot)
            {
                Module
                {
                    "Source",
                    "Description",
                    "Author",
                    "Copyright"
                }
                Bios
                {
                    "ReleaseDate",
                    "SmBiosPresent",
                    "SmBiosVersion",
                    "SmBiosMajor",
                    "SmBiosMinor",
                    "SystemBiosMajor",
                    "SystemBiosMinor"
                }
                Computer
                {
                    "UUID",
                    "Chassis",
                    "BiosUefi",
                    "AssetTag"
                }
                Processor
                {
                    "ProcessorId",
                    "DeviceId",
                    "Speed",
                    "Cores",
                    "Used",
                    "Logical",
                    "Threads"
                }
                Disk
                {
                    "PartitionStyle",
                    "ProvisioningType",
                    "OperationalStatus",
                    "HealthStatus",
                    "BusType",
                    "UniqueId",
                    "Location"
                }
                Network
                {
                    "IPAddress",
                    "SubnetMask",
                    "Gateway",
                    "DnsServer",
                    "DhcpServer",
                    "MacAddress"
                }
                Option
                {
                    "DevErrors",
                    "DevLog",
                    "DevConsole",
                    "DevReport",
                    "BypassBuild",
                    "BypassEdition",
                    "BypassLaptop",
                    "DisplayActive",
                    "DisplayInactive",
                    "DisplaySkipped",
                    "MiscSimulate",
                    "MiscXbox",
                    "MiscChange",
                    "MiscStopDisabled",
                    "LogService",
                    "LogScript",
                    "BackupRegistry",
                    "BackupConfig"
                }
                Control
                {
                    "Name",
                    "DisplayName",
                    "Value",
                    "Description"
                }
                Feature
                {
                    "Index",
                    "FeatureName",
                    "State",
                    "Path",
                    "Online",
                    "WinPath",
                    "SysDrivePath",
                    "RestartNeeded",
                    "LogPath",
                    "ScratchDirectory",
                    "LogLevel"
                }
                AppX
                {
                    "PackageName",
                    "DisplayName",
                    "PublisherID",
                    "Version",
                    "Architecture",
                    "ResourceID",
                    "InstallLocation",
                    "RestartNeeded",
                    "LogPath",
                    "LogLevel"
                }
            }

            Return $Item
        }
        SearchControl([Object]$Property,[Object]$Filter,[Object]$Item,[Object]$Control)
        {
            $Prop = $Property.SelectedItem.Content.Replace(" ","")
            $Text = $Filter.Text

            Start-Sleep -Milliseconds 20
            
            $Hash = @{ }
            Switch -Regex ($Text)
            {
                Default 
                { 
                    ForEach ($Object in $Item | ? $Prop -match $This.Escape($Text))
                    {
                        $Hash.Add($Hash.Count,$Object)
                    }
                } 
                "^$" 
                { 
                    ForEach ($Object in $Item)
                    {
                        $Hash.Add($Hash.Count,$Object)
                    }
                }
            }

            $List = Switch ($Hash.Count)
            {
                0 { $Null } 1 { $Hash[0] } Default { $Hash[0..($Hash.Count-1)]}
            }

            $This.Reset($Control,$List)
        }
        ModulePanel()
        {
            $This.Update(0,"Staging [~] Module Panel")

            $Ctrl = $This

            # [Module]
            $Ctrl.Reset($Ctrl.Xaml.IO.Module,$Ctrl.Module)

            # [Module Extension]
            $Ctrl.Reset($Ctrl.Xaml.IO.ModuleExtension,$Ctrl.Property($Ctrl.Module,1,$Ctrl.Grid("Module")))

            # [Module Root]
            $Ctrl.Reset($Ctrl.Xaml.IO.ModuleRoot,$Ctrl.Module.Root.List())

            # [Module Manifest]
            $Ctrl.Reset($Ctrl.Xaml.IO.ModuleManifest,$Ctrl.Module.Manifest)

            # [Module Manifest List]
            $Ctrl.Reset($Ctrl.Xaml.IO.ModuleManifestList,$Ctrl.Module.Manifest.Full())
        }
        SystemPanel()
        {
            $This.Update(0,"Staging [~] System Panel")

            $Ctrl = $This

            # [Bios Information]
            $Ctrl.Reset($Ctrl.Xaml.IO.BiosInformation,$Ctrl.System.BiosInformation)

            # [Bios Information Extension]
            $List = $Ctrl.Property($Ctrl.System.BiosInformation,1,$Ctrl.Grid("Bios"))
            $Ctrl.Reset($Ctrl.Xaml.IO.BiosInformationExtension,$List)

            # [Operating System]
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystem,$Ctrl.System.OperatingSystem)

            # [Hot Fix]
            $Ctrl.Reset($Ctrl.Xaml.IO.HotFix,$Ctrl.System.HotFix.Output)

            $Ctrl.Xaml.IO.HotFixSearchFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.HotFixSearchProperty,
                                    $Ctrl.Xaml.IO.HotFixSearchFilter,
                                    $Ctrl.System.HotFix.Output,
                                    $Ctrl.Xaml.IO.HotFix)
            })

            # [Computer System]
            $Ctrl.Reset($Ctrl.Xaml.IO.ComputerSystem,$Ctrl.System.ComputerSystem)

            # [Computer System Extension]
            $List = $Ctrl.Property($Ctrl.System.ComputerSystem,1,$Ctrl.Grid("Computer"))
            $Ctrl.Reset($Ctrl.Xaml.IO.ComputerSystemExtension,$List)

            # [Processor]
            $Ctrl.Reset($Ctrl.Xaml.IO.Processor,$Ctrl.System.Processor.Output)

            # [Processor Event Trigger(s)]
            $Ctrl.Xaml.IO.Processor.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Processor.SelectedIndex
                Switch ($Index)
                {
                    -1
                    {
                        $Ctrl.Xaml.IO.ProcessorExtension.Items.Clear()
                    }
                    Default
                    {
                        $List = $Ctrl.Property($Ctrl.System.Processor.Output[$Index],1,$Ctrl.Grid("Processor"))
                        $Ctrl.Reset($Ctrl.Xaml.IO.ProcessorExtension,$List)
                    }
                }
            })

            # [Disk]
            $Ctrl.Reset($Ctrl.Xaml.IO.Disk,$Ctrl.System.Disk.Output)

            # [Disk Event Trigger(s)]
            $Ctrl.Xaml.IO.Disk.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Disk.SelectedIndex
                Switch ($Index)
                {
                    -1
                    {
                        $Ctrl.Xaml.IO.DiskExtension.Items.Clear()   
                    }
                    Default
                    {
                        # [Disk Extension]
                        $List = $Ctrl.Property($Ctrl.System.Disk.Output[$Index],1,$Ctrl.Grid("Disk"))
                        $Ctrl.Reset($Ctrl.Xaml.IO.DiskExtension,$List)

                        # [Disk Partition(s)]
                        $Ctrl.Reset($Ctrl.Xaml.IO.DiskPartition,
                                    $Ctrl.System.Disk.Output[$Index].Partition.Output)

                        # [Disk Volume(s)]
                        $Ctrl.Reset($Ctrl.Xaml.IO.DiskVolume,
                                    $Ctrl.System.Disk.Output[$Index].Volume.Output)
                    }
                }
            })

            # [Network]
            $Ctrl.Reset($Ctrl.Xaml.IO.Network,$Ctrl.System.Network.Output)

            # [Network Event Trigger(s)]
            $Ctrl.Xaml.IO.Network.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.Network.SelectedIndex
                Switch ($Index)
                {
                    -1
                    {
                        $Ctrl.Xaml.IO.NetworkExtension.Items.Clear()
                    }
                    Default
                    {
                        $List = $Ctrl.Property($Ctrl.System.Network.Output[$Index],1,$Ctrl.Grid("Network"))
                        $Ctrl.Reset($Ctrl.Xaml.IO.NetworkExtension,$List)
                    }
                }
            })
        }
        ServicePanel()
        {
            $This.Update(0,"Staging [~] Service Panel")
            
            $Ctrl = $This

            # [Configuration tab]
            $Ctrl.Reset($Ctrl.Xaml.IO.ServiceSlot,$Ctrl.Config.Service.Output.Index)

            $Ctrl.Xaml.IO.ServiceSlot.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.ServiceSlot.SelectedItem
                $Ctrl.Reset($Ctrl.Xaml.IO.ServiceDisplay,$Ctrl.Config.Service.Output[$Index])
                $Ctrl.SetSlot($Index)
            })
            
            $Ctrl.Config.SetDefault($Ctrl.System.OperatingSystem.Caption)

            $Ctrl.Xaml.IO.ServiceSlot.SelectedIndex = $Ctrl.Config.Slot.Index

            $Ctrl.Xaml.IO.ServiceFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ServiceProperty,
                                    $Ctrl.Xaml.IO.ServiceFilter,
                                    $Ctrl.Service.Output,
                                    $Ctrl.Xaml.IO.ServiceOutput)
            })

            $Ctrl.Xaml.IO.ServiceBlackViper.Text = $Ctrl.AboutBlackViper()
            $Ctrl.Xaml.IO.ServiceMadBomb122.Text = $Ctrl.AboutMadBomb122()

            # [Set Option Defaults]
            ForEach ($String in $Ctrl.Grid("Option"))
            {
                $Item = $Ctrl.Option($String)
                $Item.SetValue($Ctrl.Config.$String)
            }

            If (!(Test-Path $Ctrl.LogPath()))
            {
                $Ctrl.BuildPath($Ctrl.LogPath())
            }

            $Ctrl.Xaml.IO.ServiceOptionPath.Add_TextChanged(
            {
                $Ctrl.CheckPath("ServiceOptionPath")
                $Ctrl.Xaml.IO.ServiceOptionPathSet.IsEnabled = [UInt32]$Ctrl.Flag.ServiceOptionPath.Value -ne 0
            })

            $Ctrl.Xaml.IO.ServiceOptionPath.Text = $Ctrl.LogPath()

            $Ctrl.Xaml.IO.ServiceOptionPathBrowse.Add_Click(
            {
                $Ctrl.FolderBrowse("ServiceOptionPath")
            })

            $Ctrl.Xaml.IO.ServiceOptionPathSet.Add_Click(
            {
                $Ctrl.BuildPath($Ctrl.LogPath())
                $Ctrl.Config.SetPath($Ctrl.Xaml.IO.ServiceOptionPath.Text)
            })

            $Ctrl.Xaml.IO.ServiceOptionApply.Add_Click(
            {
                ForEach ($Item in $Ctrl.Xaml.IO.ServiceOptionList.Items)
                {
                    $Item = $Ctrl.Option($Item.Name)
                    $Item.SetValue($Item.Value)
                }
            })

            $Ctrl.Reset($Ctrl.Xaml.IO.ServiceOptionList,$Ctrl.Config.Option.Output)

            $Ctrl.Xaml.IO.ServiceOptionSlot.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Preference.Output[$Ctrl.Xaml.IO.ServiceOptionSlot.SelectedIndex]
                $Ctrl.Reset($Ctrl.Xaml.IO.ServiceOptionDescription,$Item)
            })

            $Ctrl.Xaml.IO.ServiceOptionSlot.SelectedIndex = 0
        }
        ControlPanel()
        {
            $This.Update(0,"Staging [~] Control Panel")
            
            $Ctrl = $This

            # [Control Subtab]
            $Ctrl.Reset($Ctrl.Xaml.IO.ControlOutput,$Ctrl.Control.Output)

            $Ctrl.Xaml.IO.ControlSlot.Add_SelectionChanged(
            {
                $Slot = $Ctrl.Xaml.IO.ControlSlot.SelectedItem.Content.Replace(" ","")
                $Item = $Ctrl.Control.Output
                $List = Switch ($Slot)
                {
                    Default { $Item | ? Source -eq $Slot } All { $Item }
                }

                $Ctrl.Reset($Ctrl.Xaml.IO.ControlOutput,$List)
            })

            $Ctrl.Xaml.IO.ControlFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ControlProperty,
                                    $Ctrl.Xaml.IO.ControlFilter,
                                    $Ctrl.Control.Output,
                                    $Ctrl.Xaml.IO.ControlOutput)
            })

            # [Windows Features Subtab]
            $Ctrl.Reset($Ctrl.Xaml.IO.ControlFeature,$Ctrl.Control.Feature.Output)

            $Ctrl.Xaml.IO.ControlFeatureFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ControlFeatureProperty,
                                    $Ctrl.Xaml.IO.ControlFeatureFilter,
                                    $Ctrl.Control.Feature.Output,
                                    $Ctrl.Xaml.IO.ControlFeature)
            })

            # [AppX]
            $Ctrl.Reset($Ctrl.Xaml.IO.ControlAppX,$Ctrl.Control.AppX.Output)

            $Ctrl.Xaml.IO.ControlAppXFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ControlAppXProperty,
                                    $Ctrl.Xaml.IO.ControlAppXFilter,
                                    $Ctrl.Control.AppX.Output,
                                    $Ctrl.Xaml.IO.ControlAppX)
            })
        }
        ProfilePanel()
        {
            $This.Update(0,"Staging [~] Profile Panel")
            
            $Ctrl = $This

            $Ctrl.Xaml.IO.ProfileType.Add_SelectionChanged(
            {
                $Item = Switch ($Ctrl.Xaml.IO.ProfileType.SelectedIndex)
                {
                    0  { $Ctrl.Profile.Output         }
                    1  { $Ctrl.Profile.System.Output  }
                    2  { $Ctrl.Profile.Service.Output }
                    3  { $Ctrl.Profile.User.Output    }
                }

                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileOutput,$Item)
            })

            $Ctrl.Xaml.IO.ProfileType.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileSearchFilter.Add_TextChanged(
            {
                $Item = Switch ($Ctrl.Xaml.IO.ProfileType.SelectedIndex)
                {
                    0 { $Ctrl.Profile.Output }
                    1 { $Ctrl.Profile.$($Ctrl.Xaml.IO.ProfileType.SelectedItem.Content).Output }
                }

                $Ctrl.SearchControl($Ctrl.Xaml.IO.ProfileSearchProperty,
                                    $Ctrl.Xaml.IO.ProfileSearchFilter,
                                    $Item,
                                    $Ctrl.Xaml.IO.ProfileOutput)
            })

            $Ctrl.Xaml.IO.ProfileMode.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Profile.Output | ? Index -eq $Ctrl.Xaml.IO.ProfileMode.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileModeDescription,$Item)
            })

            $Ctrl.Xaml.IO.ProfileMode.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileProcess.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Process.Output | ? Index -eq $Ctrl.Xaml.IO.ProfileProcess.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileProcessDescription,$Item)
            })

            $Ctrl.Xaml.IO.ProfileProcess.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileLoad.Add_Click(
            {
                $Item = $Ctrl.Xaml.IO.ProfileOutput.SelectedItem

                Switch ($Item.Type)
                {
                    Default
                    {
                        [System.Windows.MessageBox]::Show("Cannot load a system or service account","Account Selection Error")
                    }
                    User
                    {
                        $Ctrl.Update(0,"Loading [~] User Profile [$($Item.Account)]")
                        $Item.GetContent()
                        $Ctrl.SetProfile()
                    }
                }
            })

            $Ctrl.Xaml.IO.ProfileOutput.Add_SelectionChanged(
            {
                $Ctrl.SetProfile()
            })

            $Ctrl.Xaml.IO.ProfileTarget.Add_TextChanged(
            {
                $Ctrl.CheckPath()
            })

            $Ctrl.Xaml.IO.ProfileBrowse.Add_Click(
            {
                $Ctrl.FolderBrowse()
            })
        }
        SetProfile()
        {
            $Item = $This.Xaml.IO.ProfileOutput.SelectedItem

            Switch ($Item.Type)
            {
                Default
                {
                    $This.Xaml.IO.ProfileLoad.IsEnabled   = 0
                    $This.Xaml.IO.ProfileSize.Text        = "N/A"
                    $This.Xaml.IO.ProfileCount.Text       = "N/A"
                    $This.Xaml.IO.ProfileBrowse.IsEnabled = 0
                }
                User
                {
                    $This.Xaml.IO.ProfileLoad.IsEnabled   = 1
                    $This.Xaml.IO.ProfileSize.Text        = $Item.Size.Size
                    $This.Xaml.IO.ProfileCount.Text       = $Item.Content.Count
                    $This.Xaml.IO.ProfileBrowse.IsEnabled = 1
                }
            }

            # Sid panel
            $This.Reset($This.Xaml.IO.ProfileSid,$This.Property($Item.Sid,0,"Property"))

            # Property panel
            $This.Reset($This.Xaml.IO.ProfileProperty,$Item.Sid.Property)

            # Content Panel
            $This.Xaml.IO.ProfilePath.Text = $Item.Path
            $This.Reset($This.Xaml.IO.ProfileContent,$Item.Content)
        }
        StageXaml()
        {
            $This.Update(0,"Staging [~] Xaml Interface")
            
            # [Module OS items]
            $This.Reset($This.Xaml.IO.OS,$This.Module.OS)

            $This.ModulePanel()
            $This.SystemPanel()
            $This.ServicePanel()
            $This.ControlPanel()
            $This.ProfilePanel()

            $This.Update(1,"Staged [+] Xaml Interface")
        }
    }

    Switch ($Mode)
    {
        0
        {
            [ViperBombController]::New()
        }
        1
        {
            $Ctrl = [ViperBombController]::New()
            $Ctrl.StageXaml()
            $Ctrl.Xaml.Invoke()
        }
        2
        {
            $Console = New-FEConsole
            $Console.Initialize()
            $Ctrl    = [ServiceController]::New($Console)
            $Ctrl.Console.Finalize()
            $Ctrl
        }
    }
}
