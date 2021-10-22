Function Get-MadBomb
{
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
    
    # (Get-Content $Home\Desktop\MadBomb.Xaml) | % { "'$_'," } | Set-Clipboard
    Class MadBombGUI
    {
    	Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://MadBomb122&apos;s Windows 10 (Settings/Tweaks) [Modified]" Height="620" Width="800" BorderBrush="Black">',
        '    <Window.Resources>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="HorizontalAlignment" Value="Left"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Semibold"/>',
        '            <Setter Property="Height" Value="30"/>',
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
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox" x:Key="xGroupBox">',
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
        '            <Setter Property="TextBlock.HorizontalAlignment" Value="Left"/>',
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
        '        <Style TargetType="ComboBox" x:Key="DGCombo">',
        '            <Setter Property="Margin" Value="0"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="18"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid Background="LightYellow">',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="20"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <Menu Grid.Row="0" VerticalAlignment="Top" Background="LightYellow">',
        '            <MenuItem Header="Help">',
        '                <MenuItem Name="MenuFeedback"  Header="Feedback/Bug Report (MadBomb122)"/>',
        '                <MenuItem Name="MenuFAQ"       Header="FAQ (MadBomb122)"/>',
        '                <MenuItem Name="MenuAbout"     Header="About (MadBomb122)"/>',
        '                <MenuItem Name="MenuCopyright" Header="Copyright"/>',
        '                <MenuItem Name="MenuContact"   Header="Contact Me (MadBomb122)"/>',
        '            </MenuItem>',
        '            <MenuItem Name="MenuDonation" Header="Donate to (MadBomb122)"  Background="#FFFFAD2F" FontWeight="Bold"/>',
        '            <MenuItem Name="MenuMadbomb" Header="Madbomb122&apos;s GitHub" Background="#FFFFDF4F" FontWeight="Bold"/>',
        '        </Menu>',
        '        <TabControl Name="TabControl" Grid.Row="1" TabStripPlacement="Left" BorderBrush="LightYellow" Background="LightYellow">',
        '            <TabItem Header="Preferences">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="90"/>',
        '                        <RowDefinition Height="90"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Global]" Margin="5">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <CheckBox Grid.Row="0" Name="GlobalRestorePoint" Content="Create Restore Point"/>',
        '                            <CheckBox Grid.Row="1" Name="GlobalShowSkipped" Content="Show Skipped Items"/>',
        '                            <CheckBox Grid.Row="2" Name="GlobalRestart" Content="Restart When Done (Restart is Recommended)"/>',
        '                            <CheckBox Grid.Row="3" Name="GlobalVersionCheck" Content="Check for Update (If found, will run with current settings)"/>',
        '                            <CheckBox Grid.Row="4" Name="GlobalInternetCheck" Content="Skip Internet Check"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="1" Header="[Backup]" Margin="5">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Button Grid.Column="0" Name="BackupSave" Content="Save Settings"/>',
        '                            <Button Grid.Column="1" Name="BackupLoad" Content="Load Settings"/>',
        '                            <Button Grid.Column="2" Name="BackupWinDefault" Content="Windows Default"/>',
        '                            <Button Grid.Column="3" Name="BackupResetDefault" Content="Reset All Items"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[Script]" Margin="5">',
        '                        <ComboBox Margin="5" Height="24" IsEnabled="False">',
        '                            <ComboBoxItem Content="Rewrite Module Version" IsSelected="True"/>',
        '                        </ComboBox>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Privacy">',
        '                <GroupBox Header="[Privacy]">',
        '                    <DataGrid Name="Privacy">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Service">',
        '                <GroupBox Header="[Service]">',
        '                    <DataGrid Name="Service">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Context Menu">',
        '                <GroupBox Header="[Context Menu]">',
        '                    <DataGrid Name="Context">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Taskbar">',
        '                <GroupBox Header="[Taskbar]">',
        '                    <DataGrid Name="Taskbar">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Explorer">',
        '                <GroupBox Header="[Explorer]">',
        '                    <DataGrid Name="Explorer">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Start Menu">',
        '                <GroupBox Header="[Start Menu]">',
        '                    <DataGrid Name="StartMenu">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Paths">',
        '                <GroupBox Header="[Paths]">',
        '                    <DataGrid Name="Paths">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Icons">',
        '                <GroupBox Header="[Icons]">',
        '                    <DataGrid Name="Icons">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Lock Screen">',
        '                <GroupBox Header="[Lock Screen]">',
        '                    <DataGrid Name="LockScreen">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Miscellaneous">',
        '                <GroupBox Header="[Miscellaneous]">',
        '                    <DataGrid Name="Miscellaneous">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Photo Viewer">',
        '                <GroupBox Header="[Photo Viewer]">',
        '                    <DataGrid Name="PhotoViewer">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Windows Store">',
        '                <GroupBox Header="[Windows Store]">',
        '                    <DataGrid Name="WindowsStore">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Windows Update">',
        '                <GroupBox Header="[Windows Update]">',
        '                    <DataGrid Name="WindowsUpdate">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name" Width="300" Binding="{Binding Name}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Value" Width="*">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Value, Mode=TwoWay, NotifyOnTargetUpdated=True}" Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Enable"/>',
        '                                            <ComboBoxItem Content="Disable"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="AppX">',
        '                <GroupBox Header="[AppX Catalog]">',
        '                    <DataGrid Name="AppX">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="#"            Binding="{Binding Index}"        Width="40"/>',
        '                            <DataGridTextColumn Header="Cfg"          Binding="{Binding Profile}"      Width="40"/>',
        '                            <DataGridTextColumn Header="DisplayName"  Binding="{Binding DisplayName}"  Width="250"/>',
        '                            <DataGridTextColumn Header="CName"        Binding="{Binding CName}"        Width="200"/>',
        '                            <DataGridTextColumn Header="VarName"      Binding="{Binding VarName}"      Width="200"/>',
        '                            <DataGridTextColumn Header="Version"      Binding="{Binding Version}"      Width="150"/>',
        '                            <DataGridTextColumn Header="Arch"         Binding="{Binding Architecture}" Width="40"/>',
        '                            <DataGridTextColumn Header="ResID"        Binding="{Binding ResourceID}"   Width="40"/>',
        '                            <DataGridTextColumn Header="PackageName"  Binding="{Binding PackageName}"  Width="400"/>',
        '                            <DataGridTemplateColumn Header="Slot" Width="80">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Path=Selected, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                            <ComboBoxItem Content="Skip"/>',
        '                                            <ComboBoxItem Content="Unhide"/>',
        '                                            <ComboBoxItem Content="Hide"/>',
        '                                            <ComboBoxItem Content="Uninstall"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Button Name="Start" Grid.Row="2" Width="200" Content="Run Script"/>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ListControl
    {
        [String] $Name
        [UInt32] $Value
        [String[]] $Options
        [String] $Description
        [Object] $Reference
        ListControl([String]$Name,[UInt32]$Value)
        {
            $This.Name        = $Name
            $This.Value       = $Value
        }
        SetDescription([String]$Description)
        {
            $This.Description = $Description
        }
        SetOptionsList([String[]]$Options)
        {
            $This.Options     = $Options
        }
        SetControl([String]$Name,)
    }

    # Action Classes
    Class Reg
    {
        [String] $Path
        [String] $Name
        Reg([String]$Path)
        {
            $This.Path  = $Path
        }
        Reg([String]$Path,[String]$Name)
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

    Class DisableVariousTasks
    {
        [UInt32] $Mode
        [Object] $Stack
        DisableVariousTasks([UInt32]$Mode,[UInt32]$ShowSkipped,[Object]$Tasklist)
        {
            $This.Stack = @()
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
        ScreenSaverWaitTime([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\Software\Policies\Microsoft\Windows','ScreensaveTimeout')
            )
    
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
    
    Class DGList
    {
        [String] $Name
        [UInt32] $Value
        [String] $Description
        Hidden [Object] $Action
        DGList([String]$Name,[UInt32]$Value)
        {
            $This.Name        = $Name
            $This.Value       = $Value
        }
        DGList([String]$Name,[UInt32]$Value,[String]$Description)
        {
            $This.Name        = $Name
            $This.Value       = $Value
            $this.Description = $Description 
        }
    }

    # Privacy Tab Classes
    Class PrivacyList
    {
        Hidden [String[]]       $Names = ("Telemetry WiFiSense SmartScreen LocationTracking Feedback AdvertisingID " +
                                        "Cortana CortanaSearch ErrorReporting AutoLogging DiagnosticsTracking Win" + 
                                        "dowsApp WindowsAppAutoDL").Split(" ")
        [UInt32]            $Telemetry = 1
        [UInt32]            $WiFiSense = 1
        [UInt32]          $SmartScreen = 1
        [UInt32]     $LocationTracking = 1
        [UInt32]             $Feedback = 1
        [UInt32]        $AdvertisingID = 1
        [UInt32]              $Cortana = 1
        [UInt32]        $CortanaSearch = 1
        [UInt32]       $ErrorReporting = 1
        [UInt32]          $AutoLogging = 1
        [UInt32]  $DiagnosticsTracking = 1
        [UInt32]           $WindowsApp = 1
        [UInt32]     $WindowsAppAutoDL = 0
        [Object]               $Output
        PrivacyList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class Telemetry
    {
        [Object] $Stack
        Telemetry([UInt32]$Mode,[UInt32]$ShowSkipped,[Object]$TelemetryTask)
        {
            $This.Stack = @( 
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection','AllowTelemetry'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',               'AllowTelemetry'),
            # 64 bit only
            [Reg]::New('HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection','AllowTelemetry'),
            # Remove
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds','AllowBuildPreview'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform','NoGenTicket'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows','CEIPEnable'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat','AITEnable'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat','DisableInventory'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP','CEIPEnable'),
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC','PreventHandwritingDataSharing'),
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput','AllowLinguisticDataCollection')
            )

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
                    $TelemetryTask | % { Enable-ScheduledTask -TaskName $_ | Out-Null }
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
                    $TelemetryTask | % { Disable-ScheduledTask -TaskName $_ | Out-Null }
                }
            }
        }
    }

    Class WiFiSense
    {
        [Object] $Stack
        WiFiSense([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @( 
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting','Value')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowConnectToWiFiSenseHotspots','Value')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','AutoConnectAllowedOEM')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config','WiFiSenseAllowed')
            )

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
        [Object] $Stack
        SmartScreen([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $Path = Switch($This.GetWinVersion() -ge 1703)
            { 
                $False { $Null }
                $True  { Get-AppxPackage -AllUsers Microsoft.MicrosoftEdge | % PackageFamilyName | Select-Object -Unique }
            }

            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","SmartScreenEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost","EnableWebContentEvaluation")
            [Reg]::New("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","EnabledV9")
            [Reg]::New("HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$Path\MicrosoftEdge\PhishingFilter","PreventOverride")
            )
    
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
        [Object] $Stack
        LocationTracking([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}','SensorPermissionState')
            [Reg]::New('HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration','Status')
            )

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
        [Object] $Stack
        Feedback([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Siuf\Rules','NumberOfSIUFInPeriod')
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','DoNotShowFeedbackNotifications')
            )

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
        [Object] $Stack
        AdvertisingID([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo','Enabled')
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy','TailoredExperiencesWithDiagnosticDataEnabled')
            )

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
        [Object] $Stack
        Cortana([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortanaAboveLock")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchPrivacy")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Preferences","VoiceActivationEnableAboveLockscreen")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization","AllowInputPersonalization")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton")
            )

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
        [Object] $Stack
        CortanaSearch([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana")
            )

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
        [Object] $Stack
        ErrorReporting([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting","Disabled")
            )

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
        [Object] $Stack
        AutoLoggerFile([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener","Start")
            [Reg]::New("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}","Start")
            )

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
        [String] $Stack
        DiagTrack([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @( )

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
        [UInt32] $Mode
        [Object] $Stack
        WAPPush([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart")
            )

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
    # End Privacy

    # Windows Update
    Class WindowsUpdateList
    {
        Hidden [String[]]             $Names = ('CheckForWinUpdate WinUpdateType WinUpdateDownload UpdateMSRT UpdateDriver ' + 
                                                'RestartOnUpdate AppAutoDownload UpdateAvailablePopup').Split(" ")
        
        [UInt32]          $CheckForWinUpdate = 1
        [UInt32]              $WinUpdateType = 3
        [UInt32]          $WinUpdateDownload = 1
        [UInt32]                 $UpdateMSRT = 1
        [UInt32]               $UpdateDriver = 1
        [UInt32]            $RestartOnUpdate = 1
        [UInt32]            $AppAutoDownload = 1
        [UInt32]       $UpdateAvailablePopup = 1
        [Object]                     $Output
        WindowsUpdateList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class UpdateMSProducts
    {
        [UInt32] $Mode
        [Object] $Stack
        UpdateMSProducts([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @()

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
        [UInt32] $Mode
        [Object] $Stack
        CheckForWindowsUpdate([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","SetDisableUXWUAccess")
            )

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
        [UInt32] $Mode
        [Object] $Stack
        WinUpdateType([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions")
            )

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
        [UInt32] $Mode
        [Object] $Stack
        WinUpdateDownload([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config","DODownloadMode")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","SystemSettingsDownloadMode")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization","SystemSettingsDownloadMode")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization","DODownloadMode")
            )

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
        [UInt32] $Mode
        [Object] $Stack
        UpdateMSRT([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\MRT","DontOfferThroughWUAU")
            )
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
        [UInt32] $Mode
        [Object] $Stack
        UpdateDriver([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching","SearchOrderConfig")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","ExcludeWUDriversInQualityUpdate")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata","PreventDeviceMetadataFromNetwork")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RestartOnUpdate([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings","UxOption")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","NoAutoRebootWithLoggOnUsers")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUPowerManagement")
            )

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
        [UInt32] $Mode
        [Object] $Stack
        AppAutoDownload([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate","AutoDownload")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsConsumerFeatures")
            )

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
        [Uint32] GetWinVersion()
        {
            Return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % ReleaseID
        }
    }

    Class UpdateAvailablePopup
    {
        [UInt32] $Mode
        [Object] $Stack
        UpdateAvailablePopup([UInt32]$Mode,[UInt32]$ShowSkipped,[Object]$MUSNotification_Files)
        {
            $This.Stack = @()
    
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
                    $MUSNotification_Files | % { 
                        ICACLS $_ /remove:d '"Everyone"'
                        ICACLS $_ /grant ('Everyone' + ':(OI)(CI)F')
                        ICACLS $_ /setowner 'NT SERVICE\TrustedInstaller'
                        ICACLS $_ /remove:g '"Everyone"'
                    }
                }
                2
                {
                    Write-Host "Disabling [~] Update Available Popup"
                    $MUSNotification_Files | % {
                        
                        Takeown /f $File
                        ICACLS $File /deny '"Everyone":(F)'
                    }
                }
            }
        }
    }
    # End Windows Update

    # Service List Classes
    Class ServiceList
    {
        Hidden [String[]]             $Names = ("UAC SMBDrives AdminShares Firewall WinDefender HomeGroups" + 
                                                " RemoteAssistance RemoteDesktop").Split(" ")
        [UInt32]                        $UAC = 2
        [UInt32]                  $SMBDrives = 2
        [UInt32]                $AdminShares = 1
        [UInt32]                   $Firewall = 1
        [UInt32]                $WinDefender = 1
        [UInt32]                 $HomeGroups = 1
        [UInt32]           $RemoteAssistance = 1
        [UInt32]              $RemoteDesktop = 2
        [Object]                     $Output
        ServiceList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class UAC
    {
        [UInt32] $Mode
        [Object] $Stack
        UAC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","ConsentPromptBehaviorAdmin")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop")
        )
    
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
        [UInt32] $Mode
        [Object] $Stack
        SharingMappedDrives([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLinkedConnections")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AdminShares([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters","AutoShareWks")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        Firewall([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile','EnableFirewall')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        WinDefender([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender","DisableAntiSpyware")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","WindowsDefender")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","SecurityHealth")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SpynetReporting")
            [Reg]::New("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet","SubmitSamplesConsent")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        HomeGroups([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
    
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RemoteAssistance([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp") 
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RemoteDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server","fDenyTSConnections")
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp","UserAuthentication")
            )
    
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
    # End Service List Classes

    # Context Menu Classes
    Class ContextList
    {
        Hidden [String[]]             $Names = ("CastToDevice PreviousVersions IncludeInLibrary PinToStart PinToQuickAccess ShareWith SendTo").Split(" ") 
        [UInt32]               $CastToDevice = 1
        [UInt32]           $PreviousVersions = 1
        [UInt32]           $IncludeinLibrary = 1
        [UInt32]                 $PinToStart = 1
        [UInt32]           $PinToQuickAccess = 1
        [UInt32]                  $ShareWith = 1
        [UInt32]                     $SendTo = 1
        [Object]                     $Output
        ContextList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class CastToDevice
    {
        [UInt32] $Mode
        [Object] $Stack
        CastToDevice([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked","{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PreviousVersions([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
            [Reg]::New("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
            [Reg]::New("HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
            [Reg]::New("HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        IncludeInLibrary([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location","(Default)")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PinToStart([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}','(Default)')
            [Reg]::New('HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}','(Default)')
            [Reg]::New('HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
            [Reg]::New('HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
            [Reg]::New('HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
            [Reg]::New('HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen','(Default)')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PinToQuickAccess([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCR:\Folder\shell\pintohome','MUIVerb')
            [Reg]::New('HKCR:\Folder\shell\pintohome','AppliesTo')
            [Reg]::New('HKCR:\Folder\shell\pintohome\command','DelegateExecute')
            [Reg]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','MUIVerb')
            [Reg]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome','AppliesTo')
            [Reg]::New('HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command','DelegateExecute')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ShareWith([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCR:\*\shellex\ContextMenuHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\Directory\shellex\ContextMenuHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\Directory\shellex\CopyHookHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\Drive\shellex\ContextMenuHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\Directory\shellex\PropertySheetHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing','(Default)')
            [Reg]::New('HKCR:\*\shellex\ContextMenuHandlers\ModernSharing','(Default)')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        SendTo([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo","(Default)")
            )
    
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
    # End Context Menu Classes

    # Task Bar Classes
    Class TaskbarList
    {
        Hidden [String[]] $Names = ("BatteryUIBar ClockUIBar VolumeControlBar TaskbarSearchBox " +
                                    "TaskViewButton TaskbarIconSize TaskbarGrouping TrayIcons S" + 
                                    "econdsInClock LastActiveClick").Split(" ")
        [UInt32]               $BatteryUIBar = 1
        [UInt32]                 $ClockUIBar = 1
        [UInt32]           $VolumeControlBar = 1
        [UInt32]           $TaskbarSearchBox = 1
        [UInt32]             $TaskViewButton = 1
        [UInt32]            $TaskbarIconSize = 1
        [UInt32]            $TaskbarGrouping = 2
        [UInt32]                  $TrayIcons = 1
        [UInt32]             $SecondsInClock = 2
        [UInt32]            $LastActiveClick = 2
        [UInt32]      $TaskBarOnMultiDisplay = 1
        [Object]                     $Output
        TaskbarList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class BatteryUIBar
    {
        [UInt32] $Mode
        [Object] $Stack
        BatteryUIBar([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32BatteryFlyout')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ClockUIBar([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell','UseWin32TrayClockExperience')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        VolumeControlBar([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC','EnableMtcUvc')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskBarSearchBox([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskViewButton([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowTaskViewButton')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskbarIconSize([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskbarGrouping([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarGlomLevel')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TrayIcons([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','EnableAutoTray')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        SecondsInClock([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSecondsInSystemClock')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        LastActiveClick([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LastActiveClick')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskbarOnMultiDisplay([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarEnabled')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        TaskbarButtonDisplay([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','MMTaskbarMode')
            )
    
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
    # End Task Bar

    # Start Menu Classes
    Class StartMenuList
    {
        Hidden [String[]] $Names = ("StartMenuWebSearch StartSuggestions MostUsedAppStartMenu RecentItemsFrequent UnpinItems").Split(" ")
        [UInt32]         $StartMenuWebSearch = 1
        [UInt32]           $StartSuggestions = 1
        [UInt32]       $MostUsedAppStartMenu = 1
        [UInt32]        $RecentItemsFrequent = 1
        [UInt32]                 $UnpinItems = 0
        [Object]                     $Output
        StartMenuList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }
	
    Class StartMenuWebSearch
    {
        [UInt32] $Mode
        [Object] $Stack
        StartMenuWebSearch([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','BingSearchEnabled')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search','DisableWebSearch')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        StartSuggestions([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","ContentDeliveryAllowed")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","OemPreInstalledAppsEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","PreInstalledAppsEverEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SilentInstalledAppsEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SystemPaneSuggestionsEnabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","Start_TrackProgs")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-314559Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-310093Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338387Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338388Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338389Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338393Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338394Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338396Enabled")
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager","SubscribedContent-338398Enabled")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        MostUsedAppStartMenu([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Start_TrackProgs')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RecentItemsFrequent([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu',"Start_TrackDocs")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        UnpinItems([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @()
    
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
    # End Start Menu Classes

    # Explorer Classes
    Class ExplorerList
    {
        Hidden [String[]]             $Names = ("RecentFileQuickAccess FrequentFoldersQuickAccess WinContentWhileDrag " + 
                                                "StoreOpenWith LongFilePath ExplorerOpenLoc WinXPowerShell AppHibernat" + 
                                                "ionFile PidTitleBar AccessKeyPrompt Timeline AeroSnap AeroShake Known" + 
                                                "Extensions HiddenFiles SystemFiles AutoPlay AutoRun TaskManager F1Hel" + 
                                                "pKey ReopenApps").Split(" ")
        [UInt32]      $RecentFileQuickAccess = 1
        [UInt32] $FrequentFoldersQuickAccess = 1
        [UInt32]        $WinContentWhileDrag = 1
        [UInt32]              $StoreOpenWith = 1
        [UInt32]               $LongFilePath = 2
        [UInt32]            $ExplorerOpenLoc = 1
        [UInt32]             $WinXPowerShell = 1
        [UInt32]         $AppHibernationFile = 1
        [UInt32]                $PidTitleBar = 2
        [UInt32]            $AccessKeyPrompt = 1
        [UInt32]                   $Timeline = 1
        [UInt32]                   $AeroSnap = 1
        [UInt32]                  $AeroShake = 1
        [UInt32]            $KnownExtensions = 2
        [UInt32]                $HiddenFiles = 2
        [UInt32]                $SystemFiles = 2
        [UInt32]                   $AutoPlay = 1
        [UInt32]                    $AutoRun = 1
        [UInt32]                $TaskManager = 2
        [UInt32]                  $F1HelpKey = 1
        [UInt32]                 $ReopenApps = 1
        [Object]                     $Output
        ExplorerList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class AccessKeyPrompt
    {
        [UInt32] $Mode
        [Object] $Stack
        AccessKeyPrompt([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Control Panel\Accessibility\StickyKeys',"Flags")
            [Reg]::New('HKCU:\Control Panel\Accessibility\ToggleKeys',"Flags")
            [Reg]::New('HKCU:\Control Panel\Accessibility\Keyboard Response',"Flags")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        F1HelpKey([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0")
            [Reg]::New('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32',"(Default)")
            [Reg]::New('HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64',"(Default)")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AutoPlay([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
    
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AutoRun([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer','NoDriveTypeAutoRun')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PidInTitleBar([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowPidInTitle')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AeroSnap([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Control Panel\Desktop','WindowArrangementActive')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AeroShake([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Software\Policies\Microsoft\Windows\Explorer','NoWindowMinimizingShortcuts')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        KnownExtensions([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','HideFileExt')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        HiddenFiles([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','Hidden')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        SystemFiles([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','ShowSuperHidden')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ExplorerOpenLoc([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','LaunchTo')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RecentFileQuickAccess([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
    
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        FrequentFoldersQuickAccess([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer','ShowFrequent')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        WinContentWhileDrag([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Control Panel\Desktop','DragFullWindows')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        StoreOpenWith([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer','NoUseStoreOpenWith')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        WinXPowerShell([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','DontUsePowerShellOnWinX')
            )
    
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
    }

    Class TaskManagerDetails
    {
        [UInt32] $Mode
        [Object] $Stack
        TaskManagerDetails([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager',"Preferences")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ReopenAppsOnBoot([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','DisableAutomaticRestartSignOn')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        Timeline([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System','EnableActivityFeed')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        LongFilePath([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem','LongPathsEnabled')
            [Reg]::New('HKLM:\SYSTEM\ControlSet001\Control\FileSystem','LongPathsEnabled')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AppHibernationFile([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management","SwapfileControl")
            )
    
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
    # End Explorer Classes

    # This PC Classes
    Class ThisPCList
    {
        Hidden [String[]]             $Names = "Desktop Documents Downloads Music Pictures Videos 3DObjects".Split(" ")
        [UInt32]                    $Desktop = 1
        [UInt32]                  $Documents = 1
        [UInt32]                  $Downloads = 1
        [UInt32]                      $Music = 1
        [UInt32]                   $Pictures = 1
        [UInt32]                     $Videos = 1
        [UInt32]                  $3DObjects = 1
        [Object]                     $Output
        ThisPCList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class DesktopIconInThisPC
    {
        [UInt32] $Mode
        [Object] $Stack
        DesktopIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag","ThisPCPolicy")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        DocumentsIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag","BaseFolderID")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        DownloadsIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag","BaseFolderID")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        MusicIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag","BaseFolderID")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PicturesIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag","BaseFolderID")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        VideosIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag","BaseFolderID")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ThreeDObjectsIconInThisPC([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")
            [Reg]::New("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag","ThisPCPolicy")
            )
    
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
    # End This PC Classes

    # Desktop Icon Classes
    Class DesktopIconList
    {
        Hidden [String[]]             $Names = "MyComputer Network RecycleBin Documents ControlPanel".Split(" ")
        [UInt32]                 $MyComputer = 2
        [UInt32]                    $Network = 2
        [UInt32]                 $RecycleBin = 1
        [UInt32]                  $Documents = 2
        [UInt32]               $ControlPanel = 2
        [Object]                     $Output
        DesktopIconList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class ThisPCOnDesktop
    {
        [UInt32] $Mode
        [Object] $Stack
        ThisPCOnDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        NetworkOnDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}')
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RecycleBinOnDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{645FF040-5081-101B-9F08-00AA002F954E}')
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{645FF040-5081-101B-9F08-00AA002F954E}')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        UsersFileOnDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}')
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{59031a47-3f72-44a7-89c5-5595fe6b30ee}')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ControlPanelOnDesktop([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}')
            [Reg]::New("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",'{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}')
            )
    
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
    # End Desktop Icon Classes

    # Lock Screen Classes
    Class LockScreenList
    {
        Hidden [String[]]             $Names = 'LockScreen PowerMenuLockScreen CameraOnLockScreen'.Split(" ")
        [UInt32]                 $LockScreen = 1
        [UInt32]        $PowerMenuLockScreen = 1
        [UInt32]         $CameraOnLockScreen = 1
        [Object]                     $Output
        LockScreenList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class LockScreen
    {
        [UInt32] $Mode
        [Object] $Stack
        LockScreen([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreen')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        LockScreenPassword([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure")
            [Reg]::New("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop","ScreenSaverIsSecure")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PowerMenuLockScreen([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','shutdownwithoutlogon')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        CameraOnLockScreen([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization','NoLockScreenCamera')
            )
    
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
    # End Lock Screen Classes

    # Miscellaneous Classes
    Class MiscellaneousList
    {
        Hidden [String[]]             $Names = 'AccountProtectionWarn ActionCenter StickyKeyPrompt NumblockOnStart F8BootMenu RemoteUACAccountToken SleepPower'.Split(" ")
        [UInt32]      $AccountProtectionWarn = 1
        [UInt32]               $ActionCenter = 1
        [UInt32]            $StickyKeyPrompt = 1
        [UInt32]            $NumblockOnStart = 2
        [UInt32]                 $F8BootMenu = 1
        [UInt32]      $RemoteUACAccountToken = 2
        [UInt32]                 $SleepPower = 1
        [Object]                     $Output
        MiscellaneousList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class ScreenSaver
    {
        [UInt32] $Mode
        [Object] $Stack
        ScreenSaver([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCU:\Control Panel\Desktop","ScreenSaveActive")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        AccountProtectionWarn([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows Security Health\State','AccountProtection_MicrosoftAccount_Disconnected')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        ActionCenter([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer','DisableNotificationCenter')
            [Reg]::New('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications','ToastEnabled')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        StickyKeyPrompt([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCU:\Control Panel\Accessibility\StickyKeys','Flags')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        NumbLockOnStart([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKU:\.DEFAULT\Control Panel\Keyboard','InitialKeyboardIndicators')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        F8BootMenu([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
    
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        RemoteUACAcctToken([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','LocalAccountTokenFilterPolicy')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        HibernatePower([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SYSTEM\CurrentControlSet\Control\Power','HibernateEnabled')
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings','ShowHibernateOption')
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        SleepPower([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings',"ShowSleepOption")
            )
    
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
    # End Miscellaneous Classes

    # Photo Viewer Classes
    Class PhotoViewerList
    {
        Hidden [String[]]             $Names = "PhotoViewerFileAssociation PhotoViewerOpenWithMenu".Split(" ")
      	[UInt32] $PhotoViewerFileAssociation = 2
        [UInt32]    $PhotoViewerOpenWithMenu = 2
        [Object]                     $Output
        PhotoViewerList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
            }
        }
    }

    Class PVFileAssociation
    {
        [UInt32] $Mode
        [Object] $Stack
        PVFileAssociation([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New("HKCR:\Paint.Picture\shell\open","MUIVerb")
            [Reg]::New("HKCR:\giffile\shell\open","MUIVerb")
            [Reg]::New("HKCR:\jpegfile\shell\open","MUIVerb")
            [Reg]::New("HKCR:\pngfile\shell\open","MUIVerb")
            [Reg]::New("HKCR:\Paint.Picture\shell\open\command","(Default)")
            [Reg]::New("HKCR:\giffile\shell\open\command","(Default)")
            [Reg]::New("HKCR:\jpegfile\shell\open\command","(Default)")
            [Reg]::New("HKCR:\pngfile\shell\open\command","(Default)")
            [Reg]::New("HKCR:\giffile\shell\open","CommandId")
            [Reg]::New("HKCR:\giffile\shell\open\command","DelegateExecute")
            )
    
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
        [UInt32] $Mode
        [Object] $Stack
        PVOpenWithMenu([UInt32]$Mode,[UInt32]$ShowSkipped)
        {
            $This.Stack = @(
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open')
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open\command')
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget')
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open','MuiVerb')
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open\command','(Default)')
            [Reg]::New('HKCR:\Applications\photoviewer.dll\shell\open\DropTarget','Clsid')
            )
    
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
    # End Photo Viewer Classes


    Class WindowsAppsList
    {
        Hidden [String[]] $Names = 'OneDrive OneDriveInstall XboxDVR MediaPlayer WorkFolders FaxAndScan LinuxSubsystem'.Split(" ")
        [UInt32]                   $OneDrive = 1
        [UInt32]            $OneDriveInstall = 1
        [UInt32]                    $XboxDVR = 1
        [UInt32]                $MediaPlayer = 1
        [UInt32]                $WorkFolders = 1
        [UInt32]                 $FaxAndScan = 1
        [UInt32]             $LinuxSubsystem = 2
        [Object]                     $Output
        WindowsAppsList()
        {
            $This.Output = @( )
            ForEach ($Name in $This.Names)
            {
                $This.Output += [DGList]::New($Name,$This.$($Name))
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
        Hidden [Object] $Object
        [UInt32]         $Index
        [UInt32]       $Profile
        [String]         $CName
        [String]       $VarName
        [String]   $DisplayName
        [String]       $Version
        [String]  $Architecture
        [String]    $ResourceID
        [String]   $PackageName
        [UInt32]          $Slot
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
                $This.Profile      = 1
                $This.CName        = $Item.CName
                $This.VarName      = $Item.VarName
                $This.Slot         = 0
            }
            Else
            {
                    $This.Profile      = 0
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

    Class Config
    {
        [Object]                    $Privacy
    	[Object]                    $Service
        [Object]                    $Context
        [Object]                    $Taskbar
        [Object]                   $Explorer
        [Object]                  $StartMenu
        [Object]                      $Paths
        [Object]                      $Icons
        [Object]                 $LockScreen
        [Object]              $Miscellaneous
        [Object]                $PhotoViewer
        [Object]                $WindowsApps
        [Object]              $WindowsUpdate
        [Object]                       $AppX
        Config()
        {
            $This.Reset()
        }
        Reset()
        {
            $This.Privacy                    = [PrivacyList]::New().Output
            $This.Service                    = [ServiceList]::New().Output
            $This.Context                    = [ContextList]::New().Output
            $This.Taskbar                    = [TaskbarList]::New().Output
            $This.Explorer                   = [ExplorerList]::New().Output
            $This.StartMenu                  = [StartMenuList]::New().Output
            $This.Paths                      = [PathList]::New().Output
            $This.Icons                      = [IconList]::New().Output
            $This.LockScreen                 = [LockScreenList]::New().Output
            $This.Miscellaneous              = [MiscellaneousList]::New().Output
            $This.PhotoViewer                = [PhotoViewerList]::New().Output
            $This.WindowsApps                = [WindowsAppsList]::New().Output
            $This.WindowsUpdate              = [WindowsUpdateList]::New().Output
            $This.AppX                       = [AppXStack]::New().Output
        }
    }

    Class Script
    {
        # Script Revised by mcc85sx
        [String] $Author  = 'MadBomb122|mcc85sx'
        [String] $Version = '4.0.0'
        [String] $Date    = 'Feb-08-2021'
        [String] $Release = 'Test'
        [String] $Site    = 'tbd'
        [String] $URL
        Script()
        {

        }
    }

    Class Control
    {
        [Object] $RestorePoint
        [Object] $ShowSkipped
        [Object] $Restart
        [Object] $VersionCheck
        [Object] $InternetCheck
        [Object] $Save
        [Object] $Load
        [Object] $WinDefault
        [Object] $ResetDefault
        Control()
        {

        }
    }

    Class Main
    {
        [Object]                     $Config
        [Object]                     $Script
        [Object]                    $Control
        Main()
        {
            $This.Config                     = [Config]::New()
            $This.Script                     = [Script]::New()
            $This.Control                    = [Control]::New()
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

    $Main   = [Main]::New()
    $Xaml   = [XamlWindow][MadBombGUI]::Tab

    $Xaml.IO.AppX.ItemsSource = @( )
    $Xaml.IO.AppX.ItemsSource = @($Main.Config.AppX)

    $Xaml.IO.MenuFeedback.Add_Click(
    {      
        Start https://github.com/madbomb122/Win10Script/issues 
    })

    $Xaml.IO.MenuFAQ.Add_Click(
    {           
        Start https://github.com/madbomb122/Win10Script/blob/master/README.md 
    })

    $Xaml.IO.MenuAbout.Add_Click(
    {         
        [System.Windows.Messagebox]::Show('This script performs various settings/tweaks for Windows 10.','About','OK') 
    })

    $Xaml.IO.MenuCopyright.Add_Click(
    {     
        [System.Windows.Messagebox]::Show($Copyright) 
    })

    $Xaml.IO.MenuContact.Add_Click(
    { 

    })

    $Xaml.IO.MenuDonation.Add_Click(
    {      
        Start https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/ 
    })

    $Xaml.IO.MenuMadbomb.Add_Click(
    {       
        Start https://github.com/madbomb122/ 
    })
    
    $Xaml.IO.GlobalRestorePoint.Add_Click(
    {  
        $Main.Toggle($Main.Control.RestorePoint)  
    })

    $Xaml.IO.GlobalShowSkipped.Add_Click(
    {   
        $Main.Toggle($Main.Control.ShowSkipped)   
    })

    $Xaml.IO.GlobalRestart.Add_Click(
    {       
        $Main.Toggle($Main.Control.Restart)       
    })

    $Xaml.IO.GlobalVersionCheck.Add_Click(
    {  
        $Main.Toggle($Main.Control.VersionCheck)  
    })

    $Xaml.IO.GlobalInternetCheck.Add_Click(
    { 
        $Main.Toggle($Main.Control.InternetCheck) 
    })

    $Xaml.IO.BackupSave.Add_Click(
    {          
        $Main.Toggle($Main.Control.Save)          
    })

    $Xaml.IO.BackupLoad.Add_Click(
    {          
        $Main.Toggle($Main.Control.Load)          
    }) 

    $Xaml.IO.BackupWinDefault.Add_Click(
    {    
        $Main.Toggle($Main.Control.WinDefault)    
    })

    $Xaml.IO.BackupResetDefault.Add_Click(
    {  
        $Main.Toggle($Main.Control.ResetDefault)  
    }) 

    $Xaml.IO.Privacy.ItemsSource       = @($Main.Config.Privacy)
    $Xaml.IO.Service.ItemsSource       = @($Main.Config.Service)
    $Xaml.IO.Context.ItemsSource       = @($Main.Config.Context)
    $Xaml.IO.Taskbar.ItemsSource       = @($Main.Config.Taskbar)
    $Xaml.IO.Explorer.ItemsSource      = @($Main.Config.Explorer)
    $Xaml.IO.StartMenu.ItemsSource     = @($Main.Config.StartMenu)
    $Xaml.IO.Paths.ItemsSource         = @($Main.Config.Paths)
    $Xaml.IO.Icons.ItemsSource         = @($Main.Config.Icons)
    $Xaml.IO.LockScreen.ItemsSource    = @($Main.Config.LockScreen)
    $Xaml.IO.Miscellaneous.ItemsSource = @($Main.Config.Miscellaneous)
    $Xaml.IO.PhotoViewer.ItemsSource   = @($Main.Config.PhotoViewer)
    $Xaml.IO.WindowsStore.ItemsSource  = @($Main.Config.WindowsApps)
    $Xaml.IO.WindowsUpdate.ItemsSource = @($Main.Config.WindowsUpdate)

    $Xaml.Invoke()
}
