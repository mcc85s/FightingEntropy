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
   //        FileName   : Get-ViperBomb.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : For managing Windows services.                                                           //   
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
    ¯¯¯\\__[ 2022-10-10 16:25:44    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-ViperBomb
{
    Add-Type -AssemblyName PresentationFramework

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
    
    Class ViperBombGUI
    {
        Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Name="Window" Title="[FightingEntropy]://ViperBomb Services" Height="800" Width="800" Topmost="True" BorderBrush="Black" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="NoResize" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="Label">',
        '            <Setter Property="HorizontalAlignment" Value="Center"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="LightGreen"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox" x:Key="xGroupBox">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Foreground" Value="LightYellow"/>',
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
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
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
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="HorizontalAlignment" Value="Left"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="Label" x:Key="xLabel">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="FontSize" Value="18"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="Label">',
        '                        <Border CornerRadius="5" Background="#FF0080FF" BorderBrush="Black" BorderThickness="3">',
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
        '        <Style TargetType="Label" x:Key="Config">',
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
        '        <Style TargetType="Grid">',
        '            <Setter Property="Background" Value="LightYellow"/>',
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
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="UniformToFill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="20"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="105"/>',
        '        </Grid.RowDefinitions>',
        '        <Menu Grid.Row="0" IsMainMenu="True">',
        '            <MenuItem Header="Configuration">',
        '                <MenuItem Name="Profile_0" Header="0 - Windows 10 Home / Default Max"/>',
        '                <MenuItem Name="Profile_1" Header="1 - Windows 10 Home / Default Min"/>',
        '                <MenuItem Name="Profile_2" Header="2 - Windows 10 Pro / Default Max"/>',
        '                <MenuItem Name="Profile_3" Header="3 - Windows 10 Pro / Default Min"/>',
        '                <MenuItem Name="Profile_4" Header="4 - Desktop / Default Max"/>',
        '                <MenuItem Name="Profile_5" Header="5 - Desktop / Default Min"/>',
        '                <MenuItem Name="Profile_6" Header="6 - Desktop / Default Max"/>',
        '                <MenuItem Name="Profile_7" Header="7 - Desktop / Default Min"/>',
        '                <MenuItem Name="Profile_8" Header="8 - Laptop / Default Max"/>',
        '                <MenuItem Name="Profile_9" Header="9 - Laptop / Default Min"/>',
        '            </MenuItem>',
        '            <MenuItem Header="Info">',
        '                <MenuItem Name="URL" Header="Resources"/>',
        '                <MenuItem Name="About" Header="About"/>',
        '                <MenuItem Name="Copyright" Header="Copyright"/>',
        '                <MenuItem Name="MadBomb" Header="MadBomb122"/>',
        '                <MenuItem Name="BlackViper" Header="BlackViper"/>',
        '                <MenuItem Name="Site" Header="Company Website"/>',
        '                <MenuItem Name="Help" Header="Help"/>',
        '            </MenuItem>',
        '        </Menu>',
        '        <GroupBox Grid.Row="1" Style="{StaticResource xGroupBox}">',
        '            <Grid>',
        '                <TabControl BorderBrush="Gainsboro" Name="TabControl">',
        '                    <TabItem Header="Main">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="70"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="0.3*"/>',
        '                                    <ColumnDefinition Width="0.5*"/>',
        '                                    <ColumnDefinition Width="0.3*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <GroupBox Grid.Column="0" Header="[Operating System]">',
        '                                    <Label Name="Caption"/>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Column="1" Header="[Release ID]">',
        '                                    <Label Name="ReleaseID"/>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Column="2" Header="[Version]">',
        '                                    <Label Name="Version"/>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Column="3" Header="[Chassis]">',
        '                                    <Label Name="Chassis"/>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="340"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <TextBox Grid.Column="0" Margin="5" Name="Service_Filter"/>',
        '                                <ComboBox Grid.Column="1" Margin="5" Name="Service_Property" VerticalAlignment="Center">',
        '                                    <ComboBoxItem Content="Checked"/>',
        '                                    <ComboBoxItem Content="DisplayName" IsSelected="True"/>',
        '                                    <ComboBoxItem Content="Name"/>',
        '                                </ComboBox>',
        '                                <Label Grid.Column="2" Background="#66FF66" BorderBrush="Black" BorderThickness="2" Content="Compliant"/>',
        '                                <Label Grid.Column="3" Background="#FFFF66" BorderBrush="Black" BorderThickness="2" Content="Unspecified"/>',
        '                                <Label Grid.Column="4" Background="#FF6666" BorderBrush="Black" BorderThickness="2" Content="Non Compliant"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="2" Grid.Column="0" Name="Service_Result"',
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
        '                                                    <Condition Binding="{Binding Scope}"   Value="True"/>',
        '                                                    <Condition Binding="{Binding Matches}" Value="False"/>',
        '                                                </MultiDataTrigger.Conditions>',
        '                                                <Setter Property="Background" Value="#F08080"/>',
        '                                            </MultiDataTrigger>',
        '                                            <MultiDataTrigger>',
        '                                                <MultiDataTrigger.Conditions>',
        '                                                    <Condition Binding="{Binding Scope}"   Value="False"/>',
        '                                                    <Condition Binding="{Binding Matches}" Value="False"/>',
        '                                                </MultiDataTrigger.Conditions>',
        '                                                <Setter Property="Background" Value="#FFFFFF64"/>',
        '                                            </MultiDataTrigger>',
        '                                            <MultiDataTrigger>',
        '                                                <MultiDataTrigger.Conditions>',
        '                                                    <Condition Binding="{Binding Scope}"   Value="True"/>',
        '                                                    <Condition Binding="{Binding Matches}" Value="True"/>',
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
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Preferences">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="0.8*"/>',
        '                                    <RowDefinition Height="0.4*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[Bypass]">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <CheckBox Grid.Row="1" Name="Bypass_Build"   Content="Skip Build/Version Check"/>',
        '                                        <ComboBox Grid.Row="0" Name="Bypass_Edition" VerticalAlignment="Center">',
        '                                            <ComboBoxItem Content="Override Edition Check" IsSelected="True"/>',
        '                                            <ComboBoxItem Content="Windows 10 Home"/>',
        '                                            <ComboBoxItem Content="Windows 10 Pro"/>',
        '                                        </ComboBox>',
        '                                        <CheckBox Grid.Row="2" Name="Bypass_Laptop" Content="Enable Laptop Tweaks"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="1" Header="[Display Services]" Margin="5">',
        '                                    <Grid>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <CheckBox Grid.Column="0" Name="Display_Active" Content="Active"/>',
        '                                        <CheckBox Grid.Column="1" Name="Display_Inactive" Content="Inactive"/>',
        '                                        <CheckBox Grid.Column="2" Name="Display_Skipped" Content="Skipped"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Miscellaneous]" Margin="5">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <CheckBox Grid.Row="0" Name="Misc_Simulate" Content="Simulate Changes [Dry Run]" />',
        '                                        <CheckBox Grid.Row="1" Name="Misc_Xbox" Content="Skip All Xbox Services" />',
        '                                        <CheckBox Grid.Row="2" Name="Misc_Change" Content="Allow Change of Service State" />',
        '                                        <CheckBox Grid.Row="3" Name="Misc_StopDisabled" Content="Stop Disabled Services" />',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="3" Header="[Development]" Margin="5">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <CheckBox Grid.Row="0" Name="Dev_Errors" Content="Diagnostic Output [On Error]"/>',
        '                                        <CheckBox Grid.Row="1" Name="Dev_Log" Content="Enable Development Logging"/>',
        '                                        <CheckBox Grid.Row="2" Name="Dev_Console" Content="Enable Console"/>',
        '                                        <CheckBox Grid.Row="3" Name="Dev_Report" Content="Enable Diagnostic"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                            <Grid Grid.Column="1">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="3*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[Logging] - Create logs for all changes made via this utility">',
        '                                    <Grid>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <CheckBox Grid.Row="0" Grid.Column="0" Name="Log_Service_Switch" Content="Services"/>',
        '                                        <Button   Grid.Row="0" Grid.Column="1" Name="Log_Service_Browse" Content="Browse"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="2" Name="Log_Service_File" IsEnabled="False"/>',
        '                                        <CheckBox Grid.Row="1" Grid.Column="0" Name="Log_Script_Switch" Content="Script"/>',
        '                                        <Button   Grid.Row="1" Grid.Column="1" Name="Log_Script_Browse" Content="Browse"/>',
        '                                        <TextBox  Grid.Row="1" Grid.Column="2" Name="Log_Script_File" IsEnabled="False"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="1" Header="[Backup] - Save your current Service Configuration">',
        '                                    <Grid>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="5*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <CheckBox  Grid.Row="0" Grid.Column="0" Name="Reg_Switch" Content="*.reg"/>',
        '                                        <Button    Grid.Row="0" Grid.Column="1" Name="Reg_Browse" Content="Browse"/>',
        '                                        <TextBox   Grid.Row="0" Grid.Column="2" Name="Reg_File" IsEnabled="False"/>',
        '                                        <CheckBox  Grid.Row="1" Grid.Column="0" Name="Csv_Switch" Content="*.csv"/>',
        '                                        <Button    Grid.Row="1" Grid.Column="1" Name="Csv_Browse" Content="Browse"/>',
        '                                        <TextBox   Grid.Row="1" Grid.Column="2" Name="Csv_File" IsEnabled="False"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Console/Diagnostics]">',
        '                                    <TextBlock Name="Console" TextAlignment="Left" Text="Not yet implemented"/>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                </TabControl>',
        '            </Grid>',
        '        </GroupBox>',
        '        <GroupBox Grid.Row="2" Style="{StaticResource xGroupBox}">',
        '            <Grid>',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="2*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="2*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <GroupBox Grid.Column="0" Header="[Service Configuration]" Foreground="Black" Margin="5">',
        '                    <ComboBox Name="Service_Config" SelectedIndex="0" IsEnabled="False"/>',
        '                </GroupBox>',
        '                <Button Grid.Column="1" Name="Start" Content="Start"/>',
        '                <Button Grid.Column="2" Name="Cancel" Content="Cancel"/>',
        '                <GroupBox Grid.Column="3" Header="[Module Version]" Foreground="Black" Margin="5">',
        '                    <ComboBox Name="Module_Config" SelectedIndex="0" IsEnabled="False"/>',
        '                </GroupBox>',
        '            </Grid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>' -join "`n")
    }
    
    Class ViperBombConfig
    {
        [String]               $Name = "FightingEntropy/ViperBomb"
        [String]            $Version = "2021.10.0"
        [String]            $Release = "Development"
        [String]           $Provider = "Secure Digits Plus LLC"
        [String]                $URL = "https://github.com/mcc85sx/FightingEntropy"
        [String]            $MadBomb = "https://github.com/madbomb122/BlackViperScript"
        [String]         $BlackViper = "http://www.blackviper.com"
        [String]               $Site = "https://www.securedigitsplus.com"
        Hidden [String[]] $Copyright = ("Copyright (c) 2019 Zero Rights Reserved;Services Configuration by Charles 'Black Viper' Sparks;;The MIT Licens" + 
                                        "e (MIT) + an added Condition;;Copyright (c) 2017-2019 Madbomb122;;[Black Viper Service Script];Permission is her" + 
                                        "eby granted, free of charge, to any person obtaining a ;copy of this software and associated documentation files" + 
                                        " (the Software),;to deal in the Software without restriction, including w/o limitation;the rights to: use/copy/m" + 
                                        "odify/merge/publish/distribute/sublicense,;and/or sell copies of the Software, and to permit persons to whom the" + 
                                        ";Software is furnished to do so, subject to the following conditions:;;The above copyright notice(s), this permi" + 
                                        "ssion notice and ANY original;donation link shall be included in all copies or substantial portions of;the Softw" + 
                                        "are.;;The software is provided 'As Is', without warranty of any kind, express;or implied, including but not limi" + 
                                        "ted to warranties of merchantibility,;or fitness for a particular purpose and noninfringement. In no event;shall" + 
                                        " the authors or copyright holders be liable for any claim, damages;or other liability, whether in an action of c" + 
                                        "ontract, tort or otherwise,;arising from, out of or in connection with the software or the use or;other dealings" + 
                                        " in the software.;;In other words, these terms of service must be accepted in order to use,;and in no circumstan" + 
                                        "ce may the author(s) be subjected to any liability;or damage resultant to its use.").Split(";")
        Hidden [String[]]     $About = ("This utility provides an interface to load and customize;service configuration profiles, such as:;;    Default" + 
                                        ": Black Viper (Sparks v1.0);    Custom: If in proper format;    Backup: Created via this utility").Split(";")
        Hidden [String[]]      $Help = (("[Basic];;_-atos___Accepts ToS;_-auto___Automates Process | Aborts upon user input/errors;;[Profile];;_-defaul" + 
                                        "t__Standard;_-safe___Sparks/Safe;_-tweaked__Sparks/Tweaked;_-lcsc File.csv  Loads Custom Service Configuration, " + 
                                        "File.csv = Name of your backup/custom file;;[Template];;_-all___ Every windows services will change;_-min___ Jus" + 
                                        "t the services different from the default to safe/tweaked list;_-sxb___ Skips changes to all XBox Services;;[Upd" + 
                                        "ate];;_-usc___ Checks for Update to Script file before running;_-use___ Checks for Update to Service file before" + 
                                        " running;_-sic___ Skips Internet Check, if you can't ping GitHub.com for some reason;;[Logging];;_-log___ Makes " + 
                                        "a log file named using default name Script.log;_-log File.log_Makes a log file named File.log;_-baf___ Log File " + 
                                        "of Services Configuration Before and After the script;;[Backup];;_-bscc___Backup Current Service Configuration C" + 
                                        "sv File;_-bscr___Backup Current Service Configuration, Reg File;_-bscb___Backup Current Service Configuration, C" + 
                                        "sv and Reg File;;[Display];;_-sas___ Show Already Set Services;_-snis___Show Not Installed Services;_-sss___ Sho" + 
                                        "wSkipped Services;;[Miscellaneous];;_-dry___ Runs the Script and Shows what services will be changed;_-css___ Ch" + 
                                        "ange State of Service;_-sds___ Stop Disabled Service;;[Experimental];;_-secp___Skips Edition Check by Setting Ed" + 
                                        "ition as Pro;_-sech___Skips Edition Check by Setting Edition as Home;_-sbc___ Skips Build Check;;[Development];;" + 
                                        "_-devl___Makes a log file with various Diagnostic information, Nothing is Changed;_-diag___Shows diagnostic info" + 
                                        "rmation, Stops -auto;_-diagf__   Forced diagnostic information, Script does nothing else;;[Help];;_-help___Shows" +
                                        " list of switches, then exits script.. alt -h;_-copy___Shows Copyright/License Information, then exits script" + 
                                        ";").Replace("_","    ")).Split(";")
        Hidden [String[]]      $Type = "10H:D+ 10H:D- 10P:D+ 10P:D- DT:S+ DT:S- DT:T+ DT:T- LT:S+ LT:S-".Split(" ")
        Hidden [String[]]     $Title = (("{0} Home | {1};{0} Pro | {1};{2} | Safe;{2} | Tweaked;Laptop | Safe" -f "Windows 10","Default","Desktop" -Split ";") | % { "$_ Max" , "$_ Min" })
        Hidden [Hashtable]  $Display = @{ 
                                Xbox = ("XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc xbgm" -Split " ")
                              NetTCP = ("Msmq Pipe Tcp" -Split " " | % { "Net$_`Activator" })
                                Skip = (@(("AppXSVC BrokerInfrastructure ClipSVC CoreMessagingRegistrar DcomLaunch EntAppSvc gpsvc LSM MpsSvc msiserver NgcCt" + 
                                           "nrSvc NgcSvc RpcEptMapper RpcSs Schedule SecurityHealthService sppsvc StateRepository SystemEventsBroker tiledata" + 
                                           "modelsvc WdNisSvc WinDefend") -Split " ";("BcastDVRUserService DevicePickerUserSvc DevicesFlowUserSvc PimIndexMai" +
                                           "ntenanceSvc PrintWorkflowUserSvc UnistoreSvc UserDataSvc WpnUserService") -Split " " | % { 
                                               "{0}_{1}" -f $_,(( Get-Service *_* | ? ServiceType -eq 224 )[0].Name -Split '_')[-1] }) | Sort-Object )
        }
        [String]         $PassedArgs = $Null
        [Int32]      $TermsOfService = 0
        [Int32]        $Bypass_Build = 0
        [Int32]      $Bypass_Edition = 0
        [Int32]       $Bypass_Laptop = 0
        [Int32]      $Display_Active = 1
        [Int32]    $Display_Inactive = 1
        [Int32]     $Display_Skipped = 1
        [Int32]       $Misc_Simulate = 0
        [Int32]           $Misc_Xbox = 1
        [Int32]         $Misc_Change = 0
        [Int32]   $Misc_StopDisabled = 0
        [Int32]          $Dev_Errors = 0
        [Int32]             $Dev_Log = 0
        [Int32]         $Dev_Console = 0
        [Int32]          $Dev_Report = 0
        [String]  $Log_Service_Label = "Service.log"
        [String]   $Log_Script_Label = "Script.log"
        [String]          $Reg_Label = "Backup.reg"
        [String]          $Csv_Label = "Backup.csv"
        [String]      $Service_Label = "Black Viper (Sparks v1.0)"
        [String]       $Script_Label = "DevOPS (MC/SDP v1.0)"
        [Object]            $Service
        ViperBombConfig()
        {

        }
    }

    Class Main
    {
        [Object]               $Info
        [Object]             $Config
        [Object]            $Service
        Main()
        {
            $This.Info    = Get-FERole
            $This.Config  = [ViperBombConfig]::New()
            $This.Service = Get-FEService
        }
        [Void] SetProfile([UInt32]$Slot)
        {
            ForEach ( $Service in $This.Service )
            {
                $Service.SetProfile($Slot)
            }
        }
        [Object[]] GetServices()
        {
            Return @( $This.Service )
        }
        [Object[]] FilterServices([Object]$Field,[Object]$String)
        {
            Return @( $This.Service | ? $Field -match $String )
        }
    }

    $Xaml                                = [XamlWindow][ViperBombGUI]::Tab
    $Main                                = [Main]::New()
    $Xaml.IO.Service_Result.ItemsSource  = $Main.Service

    $Xaml.IO.Profile_0.Add_Click({ $Main.SetProfile(0) })
    $Xaml.IO.Profile_1.Add_Click({ $Main.SetProfile(1) })
    $Xaml.IO.Profile_2.Add_Click({ $Main.SetProfile(2) })
    $Xaml.IO.Profile_3.Add_Click({ $Main.SetProfile(3) })
    $Xaml.IO.Profile_4.Add_Click({ $Main.SetProfile(4) })
    $Xaml.IO.Profile_5.Add_Click({ $Main.SetProfile(5) })    
    $Xaml.IO.Profile_6.Add_Click({ $Main.SetProfile(6) })
    $Xaml.IO.Profile_7.Add_Click({ $Main.SetProfile(7) })    
    $Xaml.IO.Profile_8.Add_Click({ $Main.SetProfile(8) })
    $Xaml.IO.Profile_9.Add_Click({ $Main.SetProfile(9) })

    $Xaml.IO.Title                         = "{0} v{1}" -f $Xaml.IO.Title, $Main.Config.Version

    $Xaml.IO.URL.Add_Click({        Start $Main.Config.URL        })
    $Xaml.IO.MadBomb.Add_Click({    Start $Main.Config.MadBomb    })
    $Xaml.IO.BlackViper.Add_Click({ Start $Main.Config.BlackViper })
    $Xaml.IO.Site.Add_Click({       Start $Main.Config.Site       })
    $Xaml.IO.About.Add_Click({      [System.Windows.MessageBox]::Show(($Main.Config.About     -join "`n"),    "About")})
    $Xaml.IO.Copyright.Add_Click({  [System.Windows.MessageBox]::Show(($Main.Config.Copyright -join "`n"),"Copyright")})
    $Xaml.IO.Help.Add_Click({       [System.Windows.MessageBox]::Show(($Main.Config.Help      -join "`n"),     "Help")})

    $Xaml.IO.Caption.Content                   = $Main.Info.Caption
    $Xaml.IO.ReleaseID.Content                 = $Main.Info.ReleaseID
    $Xaml.IO.Version.Content                   = $Main.Info.Version
    $Xaml.IO.Caption.Content                   = $Main.Info.Caption

    ForEach ( $Item in ("Display_Active Display_Inactive Display_Skipped Misc_Simulate Misc_Xbox Misc_Change Misc_StopDisabled " +
    "Dev_Errors Dev_Log Dev_Console Dev_Report Bypass_Build").Split(" ") )
    { 
        $Xaml.IO.$Item.IsChecked               = $Main.Config.$Item
    } 

    $Xaml.IO.Bypass_Edition.SelectedItem       = $Main.Config.ByEdition
    $Xaml.IO.Bypass_Laptop.IsChecked           = $Main.Config.ByLaptop 
    $Xaml.IO.Log_Service_Switch.IsChecked      = 0
    $Xaml.IO.Log_Service_Browse.IsEnabled      = 0

    If ($Xaml.IO.Log_Service_Switch.IsChecked -eq 0) 
    { 
        $Xaml.IO.Log_Service_Browse.IsEnabled  = 0 
    }
    If ($Xaml.IO.Log_Service_Switch.IsChecked -eq 1) 
    { 
        $Xaml.IO.Log_Service_Browse.IsEnabled  = 1 
    }
        
    $Xaml.IO.Log_Script_Switch.IsChecked       = 0
    $Xaml.IO.Log_Script_Browse.IsEnabled       = 0
        
    If ($Xaml.IO.Log_Script_Switch.IsChecked -eq 1) 
    { 
        $Xaml.IO.Log_Script_Browse.IsEnabled   = 1 
    }
    If ($Xaml.IO.Log_Script_Switch.IsChecked -eq 0) 
    { 
        $Xaml.IO.Log_Script_Browse.IsEnabled   = 0 
    }
            
    $Xaml.IO.Reg_Switch.IsChecked              = 0
    $Xaml.IO.Reg_Browse.IsEnabled              = 0
        
    If ($Xaml.IO.Reg_Switch.IsChecked    -eq 0) 
    { 
        $Xaml.IO.Reg_Browse.IsEnabled          = 0 
    }
    If ($Xaml.IO.Reg_Switch.IsChecked    -eq 1) 
    { 
        $Xaml.IO.Reg_Browse.IsEnabled          = 1 
    }
        
    $Xaml.IO.Csv_Switch.IsChecked              = 0
    $Xaml.IO.Csv_Browse.IsEnabled              = 0
        
    If ($Xaml.IO.Csv_Switch.IsChecked    -eq 1) 
    { 
        $Xaml.IO.Csv_Browse.IsEnabled          = 1 
    }
    If ($Xaml.IO.Csv_Switch.IsChecked    -eq 0) 
    { 
        $Xaml.IO.Csv_Browse.IsEnabled          = 0 
    }
        
    $Xaml.IO.Log_Service_File.Text             = $Main.Config.Log_Service_Label
    $Xaml.IO.Log_Script_File.Text              = $Main.Config.Log_Script_Label
    $Xaml.IO.Reg_File.Text                     = $Main.Config.Reg_Label
    $Xaml.IO.Csv_File.Text                     = $Main.Config.Csv_Label 
        
    $Xaml.IO.Log_Service_Browse.IsEnabled      = 0
    $Xaml.IO.Log_Script_Browse.IsEnabled       = 0
    $Xaml.IO.Reg_Browse.IsEnabled              = 0
    $Xaml.IO.Csv_Browse.IsEnabled              = 0

    $Xaml.IO.Search.Add_TextChanged(
    {
        $Xaml.IO.Service_Result.ItemsSource    = $Main.FilterServices($Main.IO.Service_Property.SelectedItem,$Main.IO.Service_Filter.Text)    
    })

    $Xaml.IO.Start.Add_Click(
    {        
        [Console]::WriteLine("Dialog Successful")
        $Xaml.IO.DialogResult                      = $True
    })
    
    $Xaml.IO.Cancel.Add_Click(
    {
        [Console]::WriteLine("User Cancelled")
        $Xaml.IO.DialogResult                      = $False
    })

    $Xaml.Invoke()
}

