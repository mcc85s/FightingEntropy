<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Invoke-FEWizard.ps1
          Solution: FightingEntropy PowerShell Deployment for MDT
          Purpose: Preexisting Environment Graphical User Interface 
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s 
          Created: 2021-09-21
          Modified: 2021-09-23

          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Invoke-FEWizard
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][Object]$Root)

    Class DGList
    {
        [String] $Name
        [Object] $Value
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

    Class FEWizardGUI
    {
        Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://PowerShell Deployment Wizard (featuring DVR)" Width="800" Height="600" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Height" Value="28"/>',
        '            <Setter Property="Margin" Value="5"/>',
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
        '            <Setter Property="FontSize" Value="15"/>',
        '            <Setter Property="FontWeight" Value="Heavy"/>',
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
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Semibold"/>',
        '            <Setter Property="FontSize" Value="14"/>',
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
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" Value="0">',
        '                    <Setter Property="Background" Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '                <Trigger Property="IsMouseOver" Value="True">',
        '                    <Setter Property="ToolTip">',
        '                        <Setter.Value>',
        '                            <TextBlock TextWrapping="Wrap" Width="400" Background="#000000" Foreground="#00FF00"/>',
        '                        </Setter.Value>',
        '                    </Setter>',
        '                    <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="12"/>',
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Resources>',
        '            <Style TargetType="Grid">',
        '                <Setter Property="Background" Value="LightYellow"/>',
        '            </Style>',
        '        </Grid.Resources>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="45"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="45"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0" Name="Locale_Tab" Content="Locale"/>',
        '            <Button Grid.Column="1" Name="System_Tab" Content="System"/>',
        '            <Button Grid.Column="2" Name="Domain_Tab" Content="Domain"/>',
        '            <Button Grid.Column="3" Name="Network_Tab" Content="Network"/>',
        '            <Button Grid.Column="4" Name="Applications_Tab" Content="Applications"/>',
        '            <Button Grid.Column="5" Name="Control_Tab" Content="Control"/>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="Locale_Panel" Visibility="Collapsed">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="2*"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Grid.Row="0" Header="[Task Sequence] - (Select a task sequence to proceed)">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="125"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="125"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label     Grid.Column="0" Content="Task Sequence"/>',
        '                        <TextBox   Grid.Column="1" Name="Task_ID" IsReadOnly="True"/>',
        '                        <Label     Grid.Column="2" Content="Profile Name"/>',
        '                        <TextBox   Grid.Column="3" Name="Task_Profile"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="1" Name="Task_List" Margin="5">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Type"    Binding="{Binding Type}"    Width="80"/>',
        '                            <DataGridTextColumn Header="Version" Binding="{Binding Version}" Width="125"/>',
        '                            <DataGridTextColumn Header="ID"      Binding="{Binding ID}"      Width="80"/>',
        '                            <DataGridTextColumn Header="Name"    Binding="{Binding Name}"    Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </GroupBox>',
        '            <GroupBox Header="[Locale] - (Time Zone/Keyboard/Language)" Grid.Row="1">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="125"/>',
        '                            <ColumnDefinition Width="350"/>',
        '                            <ColumnDefinition Width="125"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label     Grid.Column="0" Content="Time Zone"/>',
        '                        <ComboBox  Grid.Column="1" Name="Locale_Timezone"/>',
        '                        <Label     Grid.Column="2" Content="Keyboard Layout"/>',
        '                        <ComboBox  Grid.Column="3" Name="Locale_Keyboard"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="125"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label     Grid.Row="0" Grid.Column="0" Content="Primary"/>',
        '                        <CheckBox  Grid.Row="1" Grid.Column="0" Content="Secondary" Name="Locale_SecondLanguage"/>',
        '                        <ComboBox  Grid.Row="0" Grid.Column="1" Name="Locale_Language1"/>',
        '                        <ComboBox  Grid.Row="1" Grid.Column="1" Name="Locale_Language2"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </GroupBox>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="System_Panel" Visibility="Collapsed">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="320"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Header="[System]" Grid.Row="0">',
        '                <Grid Margin="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="150"/>',
        '                        <ColumnDefinition Width="240"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <!-- Column 0 -->',
        '                    <Label       Grid.Row="0" Grid.Column="0" Content="Manufacturer:"/>',
        '                    <Label       Grid.Row="1" Grid.Column="0" Content="Model:"/>',
        '                    <Label       Grid.Row="2" Grid.Column="0" Content="Processor:"/>',
        '                    <Label       Grid.Row="3" Grid.Column="0" Content="Architecture:"/>',
        '                    <Label       Grid.Row="4" Grid.Column="0" Content="UUID:"/>',
        '                    <Label       Grid.Row="5" Grid.Column="0" Content="System Name:"     ToolTip="Enter a new system name"/>',
        '                    <Label       Grid.Row="6" Grid.Column="0" Content="System Password:" ToolTip="Enter a new system password"/>',
        '                    <!-- Column 1 -->',
        '                    <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>',
        '                    <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>',
        '                    <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>',
        '                    <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture"/>',
        '                    <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3"  Name="System_UUID"/>',
        '                    <TextBox     Grid.Row="5" Grid.Column="1" Name="System_Name"/>',
        '                    <PasswordBox Grid.Row="6" Grid.Column="1" Name="System_Password"/>',
        '                    <!-- Column 2 -->',
        '                    <Label       Grid.Row="0" Grid.Column="2" Content="Product:"/>',
        '                    <Label       Grid.Row="1" Grid.Column="2" Content="Serial:"/>',
        '                    <Label       Grid.Row="2" Grid.Column="2" Content="Memory:"/>',
        '                    <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">',
        '                        <Label    Content="Chassis:"/>',
        '                        <CheckBox Name="System_IsVM" Content="IsVM" IsEnabled="False"/>',
        '                    </StackPanel>',
        '                    <CheckBox    Grid.Row="5" Grid.Column="2" Name="System_UseSerial" Content="Use Serial #"/>',
        '                    <Label       Grid.Row="6" Grid.Column="2" Content="Confirm:"/>',
        '                    <!-- Column 3 -->',
        '                    <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>',
        '                    <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>',
        '                    <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>',
        '                    <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis"/>',
        '                    <StackPanel  Grid.Row="5" Grid.Column="3" Orientation="Horizontal">',
        '                        <Label   Content="BIOS/UEFI:"/>',
        '                        <ComboBox Name="System_BiosUefi" Width="150"/>',
        '                    </StackPanel>',
        '                    ',
        '                    <PasswordBox Grid.Row="6" Grid.Column="3" Name="System_Confirm"/>',
        '                </Grid>',
        '            </GroupBox>',
        '            <GroupBox Grid.Row="1" Header="[Disks]">',
        '                <DataGrid Name="System_Disk" Margin="5">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="50"/>',
        '                        <DataGridTextColumn Header="Label"      Binding="{Binding Label}" Width="150"/>',
        '                        <DataGridTextColumn Header="FileSystem" Binding="{Binding FileSystem}" Width="80"/>',
        '                        <DataGridTextColumn Header="Size"       Binding="{Binding Size}" Width="150"/>',
        '                        <DataGridTextColumn Header="Free"       Binding="{Binding Free}" Width="150"/>',
        '                        <DataGridTextColumn Header="Used"       Binding="{Binding Used}" Width="150"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '            </GroupBox>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="Domain_Panel" Visibility="Collapsed">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="*"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Header="[Domain]" Grid.Row="0">',
        '                <Grid Margin="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="150"/>',
        '                        <ColumnDefinition Width="240"/>',
        '                        <ColumnDefinition Width="150"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="80"/>',
        '                    </Grid.RowDefinitions>',
        '                    <!-- Column 0 -->',
        '                    <StackPanel Grid.Row="0" Grid.Column="0" Orientation="Horizontal">',
        '                        <Label Content="Organization:"/>',
        '                        <CheckBox Content="Edit" Name="Domain_OrgEdit" HorizontalAlignment="Left"/>',
        '                    </StackPanel>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="Organizational Unit:"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="Home Page:"/>',
        '                    <GroupBox Grid.Row="3" Grid.ColumnSpan="4" Header="[Credential (Username/Password/Confirm)]">',
        '                        <Grid Margin="4">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="1.25*"/>',
        '                                <ColumnDefinition Width="20"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <TextBox     Grid.Column="0" Name="Domain_Username"/>',
        '                            <PasswordBox Grid.Column="2" Name="Domain_Password"/>',
        '                            <PasswordBox Grid.Column="3" Name="Domain_Confirm"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <!-- Column 1 -->',
        '                    <TextBox  Grid.Row="0" Grid.Column="1" Name="Domain_OrgName"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_OU"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_HomePage"/>',
        '                    <!-- Column 2 -->',
        '                    <ComboBox Grid.Row="0" Grid.Column="2" Name="Domain_Type"/>',
        '                    <!-- Column 3 -->',
        '                    <TextBox  Grid.Row="0" Grid.Column="3" Name="Domain_Name"/>',
        '                </Grid>',
        '            </GroupBox>',
        '            <GroupBox Grid.Row ="1" Header="[Miscellaneous]">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <!-- Column 0 -->',
        '                    <Label    Grid.Row="0" Grid.Column="0" Content="Finish Action:"/>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="Event Service:"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="End Log Files:"/>',
        '                    <Label    Grid.Row="3" Grid.Column="0" Content="Real-Time Log:"/>',
        '                    <Label    Grid.Row="4" Grid.Column="0" Content="Product Key"/>',
        '                    <!-- Column 1 -->',
        '                    <ComboBox Grid.Row="0" Grid.Column="1" Name="Misc_Finish_Action"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="1" Name="Misc_EventService" ToolTip="For monitoring deployment process"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Name="Misc_LogsSLShare"/>',
        '                    <TextBox  Grid.Row="3" Grid.Column="1" Name="Misc_LogsSLShare_DynamicLogging"/>',
        '                    <ComboBox Grid.Row="4" Grid.Column="1" Name="Misc_Product_Key_Type"/>',
        '                    <!-- Column 2 -->',
        '                    <Label    Grid.Row="0" Grid.Column="2" Content="WSUS Server:"/>',
        '                    <CheckBox Grid.Row="2" Grid.Column="2" Content="Save in Root" Name="Misc_SLShare_DeployRoot" />',
        '                    <Label    Grid.Row="3" Grid.Column="2" Grid.ColumnSpan="2" Content="Enable Real-Time Task Sequence Logging" HorizontalAlignment="Left"/>',
        '                    <TextBox  Grid.Row="4" Grid.Column="2" Grid.ColumnSpan="2" Name="Misc_Product_Key"/>',
        '                    <!-- Column 3 -->',
        '                    <TextBox  Grid.Row="0" Grid.Column="3" Name="Misc_WSUSServer" ToolTip="Pull updates from Windows Server Update Services"/>',
        '                    <CheckBox Grid.Row="1" Grid.Column="3" Name="Misc_HideShell" Content="Hide explorer during deployment"/>',
        '                    <CheckBox Grid.Row="2" Grid.Column="3" Name="Misc_NoExtraPartition" Content="Do not create extra partition"/>',
        '                </Grid>',
        '            </GroupBox>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="Network_Panel" Visibility="Collapsed">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="*"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Header="[Adapter]" Grid.Row="0">',
        '                <DataGrid Name="Network_Adapter" Margin="5" ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="200"/>',
        '                        <DataGridTextColumn Header="Index"      Binding="{Binding Index}" Width="50"/>',
        '                        <DataGridTextColumn Header="IPAddress"  Binding="{Binding IPAddress}" Width="100"/>',
        '                        <DataGridTextColumn Header="SubnetMask" Binding="{Binding SubnetMask}" Width="100"/>',
        '                        <DataGridTextColumn Header="Gateway"    Binding="{Binding Gateway}" Width="100"/>',
        '                        <DataGridTemplateColumn Header="DNSServer" Width="125">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox ItemsSource="{Binding DNSServer}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        <DataGridTextColumn Header="DhcpServer" Binding="{Binding DhcpServer}" Width="100"/>',
        '                        <DataGridTextColumn Header="MacAddress" Binding="{Binding MacAddress}" Width="100"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '            </GroupBox>',
        '            <GroupBox Header="[Network]" Grid.Row="1">',
        '                <Grid Margin="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <!-- Column 0 -->',
        '                    <Label    Grid.Row="0" Grid.Column="0" Content="Selected Adapter:"/>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="Network Type:"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="IP Address:"/>',
        '                    <Label    Grid.Row="3" Grid.Column="0" Content="Subnet Mask:"/>',
        '                    <Label    Grid.Row="4" Grid.Column="0" Content="Gateway:"/>',
        '                    <!-- Column 1 -->',
        '                    <ComboBox Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Network_Selected" IsEnabled="False"/>',
        '                    <ComboBox Grid.Row="1" Grid.Column="1" Name="Network_Type"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Name="Network_IPAddress"/>',
        '                    <TextBox  Grid.Row="3" Grid.Column="1" Name="Network_SubnetMask"/>',
        '                    <TextBox  Grid.Row="4" Grid.Column="1" Name="Network_Gateway"/>',
        '                    <!-- Column 2 -->',
        '                    <Label    Grid.Row="1" Grid.Column="2" Content="Interface Index:"/>',
        '                    <Label    Grid.Row="2" Grid.Column="2" Content="DNS Server(s):"/>',
        '                    <Label    Grid.Row="3" Grid.Column="2" Content="DHCP Server:"/>',
        '                    <Label    Grid.Row="4" Grid.Column="2" Content="Mac Address:"/>',
        '                    <!-- Column 3 -->',
        '                    <TextBox  Grid.Row="1" Grid.Column="3" Name="Network_Index"/>',
        '                    <ComboBox Grid.Row="2" Grid.Column="3" Name="Network_DNS"/>',
        '                    <TextBox  Grid.Row="3" Grid.Column="3" Name="Network_DHCP"/>',
        '                    <TextBox  Grid.Row="4" Grid.Column="3" Name="Network_MacAddress"/>',
        '                </Grid>',
        '            </GroupBox>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="Applications_Panel" Visibility="Collapsed">',
        '            <GroupBox Header="[Applications]">',
        '                <DataGrid Name="Applications" Margin="10">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTemplateColumn Header="Select" Width="50">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="{Binding Select}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                        <ComboBoxItem Content="False"/>',
        '                                        <ComboBoxItem Content="True"/>',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                        <DataGridTextColumn Header="Name"      Binding="{Binding Name}"      Width="150"/>',
        '                        <DataGridTextColumn Header="Version"   Binding="{Binding Version}"   Width="75"/>',
        '                        <DataGridTextColumn Header="Publisher" Binding="{Binding Publisher}" Width="150"/>',
        '                        <DataGridTextColumn Header="GUID"      Binding="{Binding GUID}"      Width="*"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '            </GroupBox>',
        '        </Grid>',
        '        <Grid Grid.Row="1" Name="Control_Panel" Visibility="Collapsed">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="200"/>',
        '                <RowDefinition Height="*"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Grid.Row="0" Header="[Control]">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                        <ColumnDefinition Width="125"/>',
        '                        <ColumnDefinition Width="250"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <!-- Column 0 -->',
        '                    <Label        Grid.Row="0" Grid.Column="0" Content="Username:"/>',
        '                    <Label        Grid.Row="1" Grid.Column="0" Content="Password:" />',
        '                    <Label        Grid.Row="2" Grid.Column="0" Content="Mode:"/>',
        '                    <Label        Grid.Row="3" Grid.Column="0" Content="Description:"/>',
        '                    <!-- Column 1 -->',
        '                    <TextBox      Grid.Row="0" Grid.Column="1" Name="Control_Username"/>',
        '                    <PasswordBox  Grid.Row="1" Grid.Column="1" Name="Control_Password"/>',
        '                    <ComboBox     Grid.Row="2" Grid.Column="1" Name="Control_Mode"/>',
        '                    <TextBox      Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3"  Name="Control_Description"/>',
        '                    <!-- Column 1 -->',
        '                    <Label        Grid.Row="0" Grid.Column="2" Content="Domain:"/>',
        '                    <Label        Grid.Row="1" Grid.Column="2" Content="Confirm:"/>',
        '                    <Label        Grid.Row="2" Grid.Column="2" Content="Test:"/>',
        '                    <!-- Column 1 -->',
        '                    <TextBox      Grid.Row="0" Grid.Column="3" Name="Control_Domain"/>',
        '                    <PasswordBox  Grid.Row="1" Grid.Column="3" Name="Control_Confirm"/>',
        '                    <Button       Grid.Row="2" Grid.Column="3" Name="Control_Connect" Content="Connect"/>',
        '                </Grid>',
        '            </GroupBox>',
        '            <Grid Grid.Row="1">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <GroupBox Grid.Column="0" Header="[Computer]">',
        '                    <Grid Margin="5">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0" Height="200" Name="Computer_Backup" VerticalAlignment="Top" Visibility="Collapsed">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type" />',
        '                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Backup_Type"/>',
        '                            <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>',
        '                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Backup_Browse"/>',
        '                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Backup_Path"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="0" Height="200" Name="Computer_Capture" VerticalAlignment="Top" Visibility="Collapsed">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label      Grid.Row="0" Grid.Column="0" Content="Capture Type" />',
        '                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Capture_Type"/>',
        '                            <Label      Grid.Row="1" Grid.Column="0" Content="Capture Location" />',
        '                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Capture_Browse"/>',
        '                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Capture_Path"/>',
        '                            <Grid       Grid.Row="3" Grid.Column="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="70"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <TextBox  Grid.Column="0" Name="Computer_Capture_FileName"/>',
        '                                <ComboBox Grid.Column="1" Name="Computer_Capture_Extension"/>',
        '                            </Grid>',
        '                            <Label      Grid.Row="3" Grid.Column="0" Content="Capture name" />',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '                <GroupBox Grid.Column="1" Header="[User]">',
        '                    <Grid Margin="5">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0" Height="200" Name="User_Backup" VerticalAlignment="Top" Visibility="Collapsed">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type"/>',
        '                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Backup_Type" />',
        '                            <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>',
        '                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="User_Backup_Browse"/>',
        '                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Backup_Path"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="0" Height="200" Name="User_Restore" VerticalAlignment="Top" Visibility="Collapsed">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="2*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label      Grid.Row="0" Grid.Column="0" Content="Restore Type"/>',
        '                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Restore_Type"/>',
        '                            <Label      Grid.Row="1" Grid.Column="0" Content="Restore Location"/>',
        '                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse"/>',
        '                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Restore_Path"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </Grid>',
        '        </Grid>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0" Name="Start" Content="Start"/>',
        '            <Button Grid.Column="1" Name="Cancel" Content="Cancel"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n") 
    }

    Class Locale
    {
        [String]$ID
        [String]$Keyboard
        [String]$Culture
        [String]$Name
        Locale([Object]$Culture)
        {
            $This.ID       = $Culture.ID
            $This.Keyboard = $Culture.DefaultKeyboard
            $This.Culture  = $Culture.SSpecificCulture
            $This.Name     = $Culture.RefName
        }
    }

    Class Timezone
    {
        [String]$ID
        [String]$DisplayName
        Timezone([Object]$Timezone)
        {
            $This.ID          = $Timezone.ID
            $This.Displayname = $Timezone.DisplayName
        }
    }

    Class Network
    {
        [String]$Name
        [UInt32]$Index
        [String]$IPAddress
        [String]$SubnetMask
        [String]$Gateway
        [String[]] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([Object]$If)
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

    Class Disk
    {
        [String] $Name
        [String] $Label
        [String] $FileSystem
        [String] $Size
        [String] $Free
        [String] $Used
        Disk([Object]$Disk)
        {
            $This.Name       = $Disk.DeviceID
            $This.Label      = $Disk.VolumeName
            $This.FileSystem = $Disk.FileSystem
            $This.Size       = "{0:n2} GB" -f ($Disk.Size/1GB)
            $This.Free       = "{0:n2} GB" -f ($Disk.FreeSpace/1GB)
            $This.Used       = "{0:n2} GB" -f (($Disk.Size-$Disk.FreeSpace)/1GB)
        }
    }

    Class Processor
    {
        [String]$Name
        [String]$Caption
        [String]$DeviceID
        [String]$Manufacturer
        [UInt32]$Speed
        Processor([Object]$CPU)
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
            $This.Disk             = Get-WmiObject -Class Win32_LogicalDisk    | % {     [Disk]$_ }
            $This.Network          = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ? DefaultIPGateway | % { [Network]$_ }
            $This.Processor        = Get-WmiObject -Class Win32_Processor      | % { [Processor]$_ }
            Get-WmiObject Win32_ComputerSystem        | % { 

                $This.Manufacturer = $_.Manufacturer; 
                $This.Model        = $_.Model; 
                $This.Memory       = "{0}GB" -f [UInt32]($_.TotalPhysicalMemory/1GB)
            }

            Get-WmiObject Win32_ComputerSystemProduct | % { 
                $This.UUID         = $_.UUID 
            }

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

    Class TaskSequence
    {
        [String]$ID
        [String]$Type
        [String]$Version
        [String]$Name
        TaskSequence([Object]$TaskSequence)
        {
            $Path         = $TaskSequence.PSPath -Replace "^.+\:\\",""
            $This.ID      = $TaskSequence.ID
            $This.Type    = $Path.Split('\')[1]
            $This.Version = $Path.Split('\')[2]
            $This.Name    = $TaskSequence.Name
        }
    }

    Class Application
    {
        [Bool]$Select
        [String]$Name
        [String]$Version
        [String]$Publisher
        [String]$GUID
        Application([Object]$Application)
        {
            $Path           = $Application.PSPath -Replace "^.+\:\\",""
            $This.Select    = 0
            $This.Name      = $Application.ShortName
            $This.Version   = $Application.Version
            $This.Publisher = $Application.Publisher
            $This.GUID      = $Application.GUID
        }
    }

    Class Main
    {
        [Object] $Xaml
        [Object] $IO
        [Object] $Names
        Hidden [Object] $DeploymentShare
        [Object] $TSEnv
        Hidden [Object] $FileSystem
        [Object] $TaskSequences
        [Object] $Applications
        [Object] $Control
        [Object] $Scripts
        [Object] $System
        [Object] $Timezone
        [Object] $Locale
        Main([Object]$Root)
        {
            $This.DeploymentShare = $Root.DS
            $This.TaskSequences   = $Root.DS | ? PSPath -match Task        | ? { -not $_.PsIsContainer } | % { [TaskSequence]$_ }
            $This.Applications    = $Root.DS | ? PSPath -match Application | ? { -not $_.PSIsContainer } | % {  [Application]$_ }
            $This.TSEnv           = $Root.TSEnv
            $This.Control         = $Root.Control
            $This.Scripts         = $Root.Scripts
            $This.Xaml            = [XamlWindow][FEWizardGUI]::Tab
            $This.IO              = $This.Xaml.IO
            $This.Names           = $This.Xaml.Names | ? { $_ -notin "ContentPresenter","ContentSite","Border" } | % { [DGList]::New($_,$This.IO.$_.GetType().Name)}
            $This.System          = [System]::New()
            $This.Timezone        = [System.TimeZoneInfo]::GetSystemTimeZones() | % { [Timezone]$_ }
            $This.Locale          = [XML](Get-Content "$($Root.Scripts)\ListOfLanguages.xml") | % LocaleData | % Locale | % { [Locale]$_ }
        }
        View([UInt32]$Slot)
        {
            $This.Names | ? Name -match _Panel | % { $This.IO.$($_.Name).Visibility = "Collapsed" }
            $This.Names | ? Name -match _Tab   | % { 
                
                $Ix = $_.Name
                $This.IO.$Ix.Background  = "#DFFFBA"
                $This.IO.$Ix.Foreground  = "#000000"
                $This.IO.$Ix.BorderBrush = "#000000"
            }

            $Item = ("Locale System Domain Network Applications Control" -Split " ")[$Slot]
            $Tx   = "{0}_Tab"   -f $Item
            $Px   = "{0}_Panel" -f $Item

            $This.IO.$Tx.Background  = "#4444FF"
            $This.IO.$Tx.Foreground  = "#FFFFFF"
            $This.IO.$Tx.BorderBrush = "#111111"
            $This.IO.$Px.Visibility  = "Visible"
        }
        SetDomain([UInt32]$Slot)
        {
            $This.IO.Domain_OrgName.Text                      = $This.TSEnv["_SMSTSOrgName"]
            $This.IO.Domain_Name.Text                         = @($Null,$This.TSEnv["UserDomain"])[$Slot]
            $This.IO.Domain_OU.Text                           = @($Null,$This.IO.Domain_OU.Text,$Null)[$Slot]
            $This.IO.Domain_Username.Text                     = $This.TSEnv["UserId"]
            $This.IO.Domain_Password.Password                 = $This.TSEnv["UserPassword"]
            $This.IO.Domain_Confirm.Password                  = $This.TSEnv["UserPassword"]
        }
        SetNetwork([UInt32]$Index)
        {
            If ($This.System.Network.Count -eq 1)
            {
                $IPInfo                                       = $This.System.Network
            }
            Else
            {
                $IPInfo                                       = $This.System.Network[$Index]
            }

            $X                                                = $IPInfo.DhcpServer -eq ""
            # [Network Type]
            $This.IO.Network_Type.SelectedIndex               = $X

            # [Index]
            $This.IO.Network_Index.Text                       = $IPInfo.Index
            $This.IO.Network_Index.IsReadOnly                 = 1

            # [IPAddress]
            $This.IO.Network_IPAddress.Text                   = $IPInfo.IPAddress
            $This.IO.Network_IPAddress.IsReadOnly             = @(1,0)[$X]

            # [Subnetmask]
            $This.IO.Network_SubnetMask.Text                  = $IPInfo.SubnetMask
            $This.IO.Network_SubnetMask.IsReadOnly            = @(1,0)[$X]

            # [Gateway]
            $This.IO.Network_Gateway.Text                     = $IPInfo.Gateway
            $This.IO.Network_Gateway.IsReadOnly               = @(1,0)[$X]
            
            # [Dns]
            $This.IO.Network_Dns.ItemsSource                  = @( )
            $This.IO.Network_DNS.ItemsSource                  = @($IPInfo.DNSServer)
            $This.IO.Network_DNS.SelectedIndex                = 0

            # [Dhcp]
            $This.IO.Network_Dhcp.Text                        = $IPInfo.DhcpServer
            $This.IO.Network_Dhcp.IsReadOnly                  = @(1,0)[$X]

            # [MacAddress]
            $This.IO.Network_MacAddress.Text                  = $IPInfo.MacAddress
            $This.IO.Network_MacAddress.IsReadOnly            = 1
        }
        Browse([UInt32]$Slot)
        {

        }
        Invoke()
        {
            $This.Xaml.Invoke()
        }
    }

    $Xaml                                             = [Main]::New($Root)

    # [Locale Panel]
    # Task Sequence Panel
    $Xaml.IO.Task_List.ItemsSource                    = @( )
    $Xaml.IO.Task_List.ItemsSource                    = @( $Xaml.TaskSequences )
    $Xaml.IO.Task_List.Add_SelectionChanged(
    {
        If ( $Xaml.IO.Task_List.SelectedIndex -ne -1)
        {
            $Xaml.IO.Task_ID.Text                     = $Xaml.IO.Task_List.SelectedItem.ID
        }
    })

    # Timezone
    $Xaml.IO.Locale_Timezone.ItemsSource              = @( )
    $Xaml.IO.Locale_Timezone.ItemsSource              = @( $Xaml.TimeZone.DisplayName )
    If ($Xaml.TSEnv["TimeZoneName"] -ne $Null)
    {
        $Xaml.IO.Locale_Timezone.SelectedItem         = $Xaml.Timezone | ? ID -eq $Xaml.TSEnv["TimeZoneName"] | % DisplayName
    }

    Else
    {
        $Xaml.IO.Locale_Timezone.SelectedIndex        = 0
    }

    # Keyboard
    $Xaml.IO.Locale_Keyboard.ItemsSource              = @( )
    $Xaml.IO.Locale_Keyboard.ItemsSource              = @( $Xaml.Locale.Culture )
    If ($Xaml.TSEnv["KeyboardLocale"] -ne $Null)
    {
        $Xaml.IO.Locale_Keyboard.SelectedItem         = $Xaml.Locale | ? Culture -eq $Xaml.TSEnv["KeyboardLocale"] | Select-Object -Last 1 | % Culture
    }
    Else
    {
        $Xaml.IO.Locale_Keyboard.SelectedIndex        = 0
    }

    # Language1
    $Xaml.IO.Locale_Language1.ItemsSource             = @( )
    $Xaml.IO.Locale_Language1.ItemsSource             = @( $Xaml.Locale.Name )
    If ($Xaml.TSEnv["KeyboardLocale"] -ne $Null)
    {

        $Xaml.IO.Locale_Language1.SelectedItem        = $Xaml.Locale | ? Culture -eq $Xaml.TSEnv["KeyboardLocale"] | Select-Object -Last 1 | % Name
    }
    Else
    {
        $Xaml.IO.Locale_Timezone.SelectedIndex        = 0
    }

    $Xaml.IO.Locale_Language2.ItemsSource             = @( )
    $Xaml.IO.Locale_SecondLanguage.IsChecked          = $False
    $Xaml.IO.Locale_SecondLanguage.Add_Click(
    {
        $Item = $Xaml.IO.Locale_SecondLanguage
        If (!$Item.IsChecked)
        {
            $Xaml.IO.Locale_Language2.IsEnabled       = $False
            $Xaml.IO.Locale_Language2.ItemsSource     = @( )
        }
        If ($Item.IsChecked)
        {
            $Xaml.IO.Locale_Language2.IsEnabled       = $True
            $Xaml.IO.Locale_Language2.ItemsSource     = @( $Xaml.Locale.Name )
            $Xaml.IO.Locale_Language2.SelectedIndex   = 0
        }
    })

    # [System]
    $Xaml.IO.System_Manufacturer.Text                 = $Xaml.System.Manufacturer
    $Xaml.IO.System_Manufacturer.IsReadOnly           = 1

    $Xaml.IO.System_Model.Text                        = $Xaml.System.Model
    $Xaml.IO.System_Model.IsReadOnly                  = 1

    $Xaml.IO.System_Product.Text                      = $Xaml.System.Product
    $Xaml.IO.System_Product.IsReadOnly                = 1

    $Xaml.IO.System_Serial.Text                       = $Xaml.System.Serial
    $Xaml.IO.System_Serial.IsReadOnly                 = 1

    $Xaml.IO.System_Memory.Text                       = $Xaml.System.Memory
    $Xaml.IO.System_Memory.IsReadOnly                 = 1

    $Xaml.IO.System_UUID.Text                         = $Xaml.System.UUID
    $Xaml.IO.System_UUID.IsReadOnly                   = 1
    
    # Processor
    $Xaml.IO.System_Processor.ItemsSource             = @( )
    $Xaml.IO.System_Processor.ItemsSource             = @($Xaml.System.Processor.Name)
    $Xaml.IO.System_Processor.SelectedIndex           = 0

    $Xaml.IO.System_Architecture.ItemsSource          = @( )
    $Xaml.IO.System_Architecture.ItemsSource          = @("x86","x64")
    $Xaml.IO.System_Architecture.SelectedIndex        = $Xaml.System.Architecture -eq "x64"
    $Xaml.IO.System_Architecture.IsEnabled            = 0

    # Chassis
    $Xaml.IO.System_IsVM.IsChecked                    = $Xaml.TSEnv["IsVm"]
    $Xaml.IO.System_Chassis.ItemsSource               = @( )
    $Xaml.IO.System_Chassis.ItemsSource               = @("Desktop;Laptop;Small Form Factor;Server;Tablet" -Split ";")
    $X                                                = $Null
    If     ($Xaml.TSEnv["IsDesktop"] -eq $True)   {$X = 0}
    ElseIf ($Xaml.TsEnv["IsLaptop"]  -eq $True)   {$X = 1}
    ElseIf ($Xaml.TsEnv["IsSff"]     -eq $True)   {$X = 2}
    ElseIf ($Xaml.TsEnv["IsServer"]  -eq $True)   {$X = 3}
    ElseIf ($Xaml.TsEnv["IsTablet"]  -eq $True)   {$X = 4}
    $Xaml.IO.System_Chassis.SelectedIndex             = $X
    $Xaml.IO.System_Chassis.IsEnabled                 = 0

    $Xaml.IO.System_BiosUefi.ItemsSource              = @( )
    $Xaml.IO.System_BiosUefi.ItemsSource              = @("BIOS","UEFI")
    $Xaml.IO.System_BiosUefi.SelectedIndex            = $Xaml.System -eq "UEFI"
    $Xaml.IO.System_BiosUefi.IsEnabled                = 0

    $Xaml.IO.System_UseSerial.Add_Click(
    {
        If ($Xaml.IO.System_UseSerial.IsChecked)
        {
            $Xaml.IO.System_Name.Text                 = ($Xaml.System.Serial -Replace "\-","").ToCharArray()[0..14] -join ''
        }
        If (!$Xaml.IO.System_UseSerial.IsChecked)
        {
            $Xaml.IO.System_Name.Text                 = $Null
        }
    })
    $Xaml.IO.System_UseSerial.IsChecked               = 0

    # Disks
    $Xaml.IO.System_Disk.ItemsSource                  = @( )
    $Xaml.IO.System_Disk.ItemsSource                  = @($Xaml.System.Disk)

    # [Domain]
    $Xaml.IO.Domain_Type.ItemsSource                  = @( )
    $Xaml.IO.Domain_Type.ItemsSource                  = @("Domain","Workgroup")
    $Xaml.IO.Domain_Type.SelectedIndex                = 0
    $Xaml.IO.Domain_OrgEdit.IsChecked                 = 0
    $Xaml.IO.Domain_OrgEdit.Add_Click(
    {
        If ($Xaml.IO.Domain_OrgEdit.IsChecked)
        {
            $Xaml.IO.Domain_OrgName.IsReadOnly        = 0
            $Xaml.SetDomain(1)
        }
        If (!$Xaml.IO.Domain_OrgEdit.IsChecked)
        {
            $Xaml.IO.Domain_OrgName.IsReadOnly        = 1
        }
    })
    $Xaml.SetDomain(1)
    $Xaml.IO.Domain_Type.Add_SelectionChanged(
    {
        If ($Xaml.IO.Domain_Type.SelectedItem -eq "Domain")
        {
            $Xaml.SetDomain(1)
        }
        If ($Xaml.IO.Domain_Type.SelectedItem -eq "Workgroup")
        {
            $Xaml.SetDomain(0)
        }
    })

    # [Miscellaneous]
    $Xaml.IO.Misc_Finish_Action.ItemsSource           = @( )
    $Xaml.IO.Misc_Finish_Action.ItemsSource           = @("Do nothing","Reboot","Shutdown","LogOff")
    $Xaml.IO.Misc_Finish_Action.SelectedIndex         = 0
    
    $Xaml.IO.Misc_Product_Key_Type.ItemsSource        = @( )
    $Xaml.IO.Misc_Product_Key_Type.ItemsSource        = @("No product key is required","Activate with multiple activation key(MAK)","Use a specific product key")
    $Xaml.IO.Misc_Product_Key_Type.SelectedIndex      = 0

    # [Network]
    $Xaml.IO.Network_Adapter.ItemsSource              = @( )
    $Xaml.IO.Network_Selected.ItemsSource             = @( )
    $Xaml.IO.Network_Adapter.ItemsSource              = @($Xaml.System.Network)
    $Xaml.IO.Network_Adapter.Add_SelectionChanged(
    {
        If ($Xaml.IO.Network_Adapter.SelectedIndex -ne -1)
        {
            $Xaml.IO.Network_Selected.ItemsSource     = @( )
            $Xaml.IO.Network_Selected.ItemsSource     = @( $Xaml.IO.Network_Adapter.SelectedItem.Name )
            $Xaml.SetNetwork($Xaml.IO.Network_Adapter.SelectedIndex)
        }
    })

    $Xaml.IO.Network_Type.ItemsSource                 = @( )
    $Xaml.IO.Network_Type.ItemsSource                 = @("DHCP","Static")
    $Xaml.IO.Network_Type.SelectedIndex               = 0
    
    $Xaml.SetNetwork(0)

    $Xaml.IO.Network_Type.Add_SelectionChanged(
    {
        $Xaml.SetNetwork($Xaml.IO.Network_Type.SelectedIndex)
    })

    # [Applications]
    $Xaml.IO.Applications.ItemsSource                 = @( )
    $Xaml.IO.Applications.ItemsSource                 = @( $Xaml.Applications )

    # [Control]
    $Xaml.IO.Control_Mode.ItemsSource                 = @( )
    $Xaml.IO.Control_Mode.ItemsSource                 = @("New Computer","Refresh","Virtualize","Devirtualize")
    $Xaml.IO.Control_Mode.Add_SelectionChanged(
    {
        $Xaml.IO.Computer_Backup.Visibility           = "Collapsed"
        $Xaml.IO.Computer_Capture.Visibility          = "Collapsed"
        $Xaml.IO.User_Backup.Visibility               = "Collapsed"
        $Xaml.IO.User_Restore.Visibility              = "Collapsed"
        
        Switch ($Xaml.IO.Control_Mode.SelectedIndex)
        {
            0 
            { 
                $Description = "Perform a fresh installation of an operating system"
                $Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }

            1 
            { 
                $Description = "Perform an in-place upgrade, preserving the content"
                $Xaml.IO.Computer_Backup.Visibility   = "Visible"
                $Xaml.IO.User_Backup.Visibility       = "Visible"
            }

            2 
            { 
                $Description = "Convert a physical machine to a virtual machine"
                $Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }

            3 
            { 
                $Description = "Convert a virtual machine to a physical machine"
                $Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }
        }
        $Xaml.IO.Control_Description.Text             = $Description
    })

    $Xaml.IO.Control_Mode.SelectedIndex               = 0
    
    $Xaml.IO.Control_Username.Text                    = $Xaml.TSEnv["UserID"]
    $Xaml.IO.Control_Domain.Text                      = $Xaml.TSEnv["UserDomain"]
    $Xaml.IO.Control_Password.Password                = $Xaml.TSEnv["UserPassword"]
    $Xaml.IO.Control_Confirm.Password                 = $Xaml.TSEnv["UserPassword"]

    # [Backup]
    $Xaml.IO.Computer_Backup_Type.ItemsSource         = @( )
    $Xaml.IO.Computer_Backup_Type.ItemsSource         = @("Do not backup the existing computer","Automatically determine the location","Specify a location")
    $Xaml.IO.Computer_Backup_Type.SelectedIndex       = 0

    $Xaml.IO.Computer_Capture_Type.ItemsSource        = @( )
    $Xaml.IO.Computer_Capture_Type.ItemsSource        = @("Do not capture","Capture my computer","Sysprep this computer","Prepare to capture the machine")
    $Xaml.IO.Computer_Capture_Type.SelectedIndex      = 0

    $Xaml.IO.Computer_Capture_Extension.ItemsSource   = @( )
    $Xaml.IO.Computer_Capture_Extension.ItemsSource   = @("WIM","VHD")
    $Xaml.IO.Computer_Capture_Extension.SelectedIndex = 0

    $Xaml.IO.User_Backup_Type.ItemsSource             = @( )
    $Xaml.IO.User_Backup_Type.ItemsSource             = @("Do not save data and settings","Automatically determine the location","Specify a location")
    $Xaml.IO.User_Backup_Type.SelectedIndex           = 0

    $Xaml.IO.User_Restore_Type.ItemsSource            = @( )
    $Xaml.IO.User_Restore_Type.ItemsSource            = @("Specify a location","Specify an account")
    $Xaml.IO.User_Restore_Type.SelectedIndex          = 0

    # [Menu Selection]
    $Xaml.IO.Locale_Tab.Add_Click(
    {
        $Xaml.View(0)
    })

    $Xaml.IO.System_Tab.Add_Click(
    {
        $Xaml.View(1)
    })

    $Xaml.IO.Domain_Tab.Add_Click(
    {
        $Xaml.View(2)
    })

    $Xaml.IO.Network_Tab.Add_Click(
    {
        $Xaml.View(3)
    })

    $Xaml.IO.Applications_Tab.Add_Click(
    {
        $Xaml.View(4)
    })

    $Xaml.IO.Control_Tab.Add_Click(
    {
        $Xaml.View(5)
    })

    $Xaml.View(0)

    $Xaml.IO.Start.Add_Click(
    {
        $Xaml.IO.DialogResult = $True
        # Rules
        $Xaml.IO.Close()
    })
    
    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
        $Xaml.IO.Close()
    })

    $Xaml.Invoke()
    
    If ($Xaml.IO.DialogResult -eq $True)
    {
        Return $Xaml
    }
}
