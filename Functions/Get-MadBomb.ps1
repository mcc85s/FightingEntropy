<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-MadBomb.ps1
          Solution: FightingEntropy Module
          Purpose: For tweaking various Windows settings, featuring MadBomb122's customization script (not complete)
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.
	  
          TODO: 10/17/2021 - Get items bound to the class structures

.Example
#>
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
    
    Class MadBombGUI
    {
    	Static [String] $Tab = (        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Windows 10 Settings/Tweaks Script By Madbomb122" Height="600" Width="800" BorderBrush="Black" Background="White">',
        '    <Window.Resources>',
        '        <Style x:Key="SeparatorStyle1" TargetType="{x:Type Separator}">',
        '            <Setter Property="SnapsToDevicePixels" Value="True"/>',
        '            <Setter Property="Margin" Value="0,0,0,0"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="{x:Type Separator}">',
        '                        <Border Height="24" SnapsToDevicePixels="True" Background="#FF4D4D4D" BorderBrush="#FF4D4D4D" BorderThickness="0,0,0,1"/>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="{x:Type ToolTip}">',
        '            <Setter Property="Background" Value="#FFFFFFBF"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox" x:Key="xCheckBox">',
        '            <Setter Property="HorizontalAlignment" Value="Left"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="Button" x:Key="xButton">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="10"/>',
        '            <Setter Property="Padding" Value="10"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="Button">',
        '                        <Border CornerRadius="5" Background="#FF0080FF" BorderBrush="Black" BorderThickness="3">',
        '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
        '                        </Border>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
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
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="20"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <Menu Grid.Row="0" VerticalAlignment="Top">',
        '            <MenuItem Header="Help">',
        '                <MenuItem Name="_Feedback" Header="Feedback/Bug Report"/>',
        '                <MenuItem Name="_FAQ" Header="FAQ"/>',
        '                <MenuItem Name="_About" Header="About"/>',
        '                <MenuItem Name="_Copyright" Header="Copyright"/>',
        '                <MenuItem Name="_Contact" Header="Contact Me"/>',
        '            </MenuItem>',
        '            <MenuItem Name="_Donation" Header="Donate to Me" Background="#FFFFAD2F" FontWeight="Bold"/>',
        '            <MenuItem Name="_Madbomb" Header="Madbomb122&apos;s GitHub" Background="#FFFFDF4F" FontWeight="Bold"/>',
        '        </Menu>',
        '        <TabControl Name="TabControl" Grid.Row="1" BorderBrush="Gainsboro" TabStripPlacement="Left">',
        '            <TabControl.Resources>',
        '                <Style TargetType="TabItem">',
        '                    <Setter Property="Template">',
        '                        <Setter.Value>',
        '                            <ControlTemplate TargetType="TabItem">',
        '                                <Border Name="Border" BorderThickness="1,1,1,0" BorderBrush="Gainsboro" CornerRadius="4" Margin="2">',
        '                                    <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
        '                                </Border>',
        '                                <ControlTemplate.Triggers>',
        '                                    <Trigger Property="IsSelected" Value="True">',
        '                                        <Setter TargetName="Border" Property="Background" Value="LightSkyBlue" />',
        '                                    </Trigger>',
        '                                    <Trigger Property="IsSelected" Value="False">',
        '                                        <Setter TargetName="Border" Property="Background" Value="GhostWhite" />',
        '                                    </Trigger>',
        '                                </ControlTemplate.Triggers>',
        '                            </ControlTemplate>',
        '                        </Setter.Value>',
        '                    </Setter>',
        '                </Style>',
        '            </TabControl.Resources>',
        '            <TabItem Header="Preferences">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="160"/>',
        '                            <RowDefinition Height="90"/>',
        '                            <RowDefinition Height="90"/>',
        '                        </Grid.RowDefinitions>',
        '                        <GroupBox Grid.Row="0" Header="Global" Margin="5">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <CheckBox Grid.Row="0" Style="{StaticResource xCheckBox}" Name="_RestorePoint" Content="Create Restore Point"/>',
        '                                <CheckBox Grid.Row="1" Style="{StaticResource xCheckBox}" Name="_ShowSkipped" Content="Show Skipped Items"/>',
        '                                <CheckBox Grid.Row="2" Style="{StaticResource xCheckBox}" Name="_Restart" Content="Restart When Done (Restart is Recommended)"/>',
        '                                <CheckBox Grid.Row="3" Style="{StaticResource xCheckBox}" Name="_VersionCheck" Content="Check for Update (If found, will run with current settings)"/>',
        '                                <CheckBox Grid.Row="4" Style="{StaticResource xCheckBox}" Name="_InternetCheck" Content="Skip Internet Check"/>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Row="1" Header="Backup" Margin="5">',
        '                            <Grid>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Style="{StaticResource xButton}" Name="_Save" Content="Save Settings"/>',
        '                                <Button Grid.Column="1" Style="{StaticResource xButton}" Name="_Load" Content="Load Settings"/>',
        '                                <Button Grid.Column="2" Style="{StaticResource xButton}" Name="_WinDefault" Content="Windows Default"/>',
        '                                <Button Grid.Column="3" Style="{StaticResource xButton}" Name="_ResetDefault" Content="Reset All Items"/>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Row="2" Header="Script" Margin="5">',
        '                            <ComboBox Margin="5" Height="24" IsEnabled="False">',
        '                                <ComboBoxItem Content="Rewrite Module Version" IsSelected="True"/>',
        '                            </ComboBox>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Privacy">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <DataGrid Name="_Privacy" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                                <DataGridTemplateColumn Width="100">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
        '                                                <ComboBoxItem Content="Skip"/>',
        '                                                <ComboBoxItem Content="Enable"/>',
        '                                                <ComboBoxItem Content="Disable"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Service">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <DataGrid Name="_Service" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                                <DataGridTemplateColumn Width="100">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
        '                                                <ComboBoxItem Content="Skip"/>',
        '                                                <ComboBoxItem Content="Enable"/>',
        '                                                <ComboBoxItem Content="Disable"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Context">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <DataGrid Name="_Context" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                                <DataGridTemplateColumn Width="100">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
        '                                                <ComboBoxItem Content="Skip"/>',
        '                                                <ComboBoxItem Content="Enable"/>',
        '                                                <ComboBoxItem Content="Disable"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Taskbar">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <DataGrid Name="_Taskbar" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                                <DataGridTemplateColumn Width="100">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
        '                                                <ComboBoxItem Content="Skip"/>',
        '                                                <ComboBoxItem Content="Enable"/>',
        '                                                <ComboBoxItem Content="Disable"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Explorer">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_Explorer" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '            <TabItem Header="StartMenu">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_StartMenu" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_Paths" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_Icons" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_LockScreen" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_Miscellaneous" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '            <TabItem Header="PhotoViewer">',
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_PhotoViewer" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_WindowsStore" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_WindowsUpdate" Margin="5" AutoGenerateColumns="False" AlternationCount="2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Width="150" Binding="{Binding ID}" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Slot, Mode=TwoWay, NotifyOnTargetUpdated=True}">',
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
        '                <GroupBox Style="{StaticResource xGroupBox}">',
        '                    <DataGrid Name="_AppX" FrozenColumnCount="2" AutoGenerateColumns="False" AlternationCount="2" HeadersVisibility="Column" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended" Margin="5">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="AlternationIndex" Value="0">',
        '                                        <Setter Property="Background" Value="White"/>',
        '                                    </Trigger>',
        '                                    <Trigger Property="AlternationIndex" Value="1">',
        '                                        <Setter Property="Background" Value="#FFD8D8D8"/>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Display Name" Width="150" Binding="{Binding CName}" CanUserSort="True" IsReadOnly="True"/>',
        '                            <DataGridTemplateColumn Header="Option" Width="80" SortMemberPath="AppSelected" CanUserSort="True">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox ItemsSource="{Binding AppOptions}" Text="{Binding Path=AppSelected, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}"/>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTextColumn Header="Appx Name" Width="180" Binding="{Binding AppxName}" IsReadOnly="True"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </GroupBox>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Button Name="_Start" Grid.Row="2" Width="200" Content="Run Script" VerticalAlignment="Center" Height="20" FontWeight="Bold"/>',
        '    </Grid>',
        '</Window>' -join "`n")
    }
    
    Class ListItem
    {
        [String] $ID
        [Object] $Slot
        ListItem([String]$ID,[Object]$Slot)
        {
            $This.ID   = $ID
            $This.Slot = $Slot
        }
    }
    Class Privacy
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
        Privacy()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Service
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
        Service()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Context
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
        Context()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class StartMenu 
    {
        Hidden [String[]] $Names = ("StartMenuWebSearch StartSuggestions MostUsedAppStartMenu RecentItemsFrequent UnpinItems").Split(" ")
        [UInt32]         $StartMenuWebSearch = 1
        [UInt32]           $StartSuggestions = 1
        [UInt32]       $MostUsedAppStartMenu = 1
        [UInt32]        $RecentItemsFrequent = 1
        [UInt32]                 $UnpinItems = 0
        [Object]                     $Output
        StartMenu()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Taskbar
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
        Taskbar()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }
	
    Class Explorer
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
        Explorer()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Icons
    {
        Hidden [String[]]             $Names = "MyComputer Network RecycleBin Documents ControlPanel".Split(" ")

        [UInt32]                 $MyComputer = 2
        [UInt32]                    $Network = 2
        [UInt32]                 $RecycleBin = 1
        [UInt32]                  $Documents = 2
        [UInt32]               $ControlPanel = 2
        [Object]                     $Output
        Icons()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Paths
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
        Paths()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class PhotoViewer 
    {
        Hidden [String[]]             $Names = "PhotoViewerFileAssociation PhotoViewerOpenWithMenu".Split(" ")
      	[UInt32] $PhotoViewerFileAssociation = 2
        [UInt32]    $PhotoViewerOpenWithMenu = 2
        [Object]                     $Output
        PhotoViewer()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class LockScreen
    {
        Hidden [String[]]             $Names = 'LockScreen PowerMenuLockScreen CameraOnLockScreen'.Split(" ")
        [UInt32]                 $LockScreen = 1
        [UInt32]        $PowerMenuLockScreen = 1
        [UInt32]         $CameraOnLockScreen = 1
        [Object]                     $Output
        LockScreen()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class Miscellaneous
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
        Miscellaneous()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class WindowsApps
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
        WindowsApps()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }

    Class WindowsUpdate
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
        WindowsUpdate()
        {
            $This.Output = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Output += [ListItem]::New($Name,$This.$($Name))
            }
        }
    }
    
    Class AppXObject
    {
        Hidden [String[]] $Line
        [String] $AppXName
        [String] $CName
        [String] $VarName
        AppXObject([String]$Line)
        {
            $This.Line     = $Line.Split(";")
            $This.AppXName = $This.Line[0]
            $This.CName    = $This.Line[1]
            $This.VarName  = "`${0}" -f $This.Line[2]
        }
    }

    Class AppXCollection
    {
        [String] $List     = ('Microsoft.3DBuilder;3DBuilder;APP_3DBuilder,Microsoft.Microsoft3DViewer;3DViewer;APP_3DViewer,Microsoft' +
                              '.BingWeather;Bing Weather;APP_BingWeather,Microsoft.CommsPhone;Phone;APP_CommsPhone,Microsoft.windowsco' +
                              'mmunicationsapps;Calendar & Mail;APP_Communications,Microsoft.GetHelp;Microsofts Self-Help;APP_GetHelp,' +
                              'Microsoft.Getstarted;Get Started Link;APP_Getstarted,Microsoft.Messaging;Messaging;APP_Messaging,Micros' + 
                              'oft.MicrosoftOfficeHub;Get Office Link;APP_MicrosoftOffHub,Microsoft.MovieMoments;Movie Moments;APP_Mov' + 
                              'ieMoments,4DF9E0F8.Netflix;Netflix;APP_Netflix,Microsoft.Office.OneNote;Office OneNote;APP_OfficeOneNot' + 
                              'e,Microsoft.Office.Sway;Office Sway;APP_OfficeSway,Microsoft.OneConnect;One Connect;APP_OneConnect,Micr' + 
                              'osoft.People;People;APP_People,Microsoft.Windows.Photos;Photos;APP_Photos,Microsoft.SkypeApp;Skype;APP_' + 
                              'SkypeApp1,Microsoft.MicrosoftSolitaireCollection;Microsoft Solitaire;APP_SolitaireCollect,Microsoft.Mic' + 
                              'rosoftStickyNotes;Sticky Notes;APP_StickyNotes,Microsoft.WindowsSoundRecorder;Voice Recorder;APP_VoiceR' + 
                              'ecorder,Microsoft.WindowsAlarms;Alarms and Clock;APP_WindowsAlarms,Microsoft.WindowsCalculator;Calculat' +
                              'or;APP_WindowsCalculator,Microsoft.WindowsCamera;Camera;APP_WindowsCamera,Microsoft.WindowsFeedback;Win' + 
                              'dows Feedback;APP_WindowsFeedbak1,Microsoft.WindowsFeedbackHub;Windows Feedback Hub;APP_WindowsFeedbak2' +
                              ',Microsoft.WindowsMaps;Maps;APP_WindowsMaps,Microsoft.WindowsPhone;Phone Companion;APP_WindowsPhone,Mic' +
                              'rosoft.WindowsStore;Microsoft Store;APP_WindowsStore,Microsoft.Wallet;Stores Credit and Debit Card Info' +
                              'rmation;APP_WindowsWallet,$Xbox_Apps;Xbox Apps (All);APP_XboxApp,Microsoft.ZuneMusic;Groove Music;APP_Z' +
                              'uneMusic,Microsoft.ZuneVideo;Groove Video;APP_ZuneVideo')
        [Object] $Output
        AppXCollection()
        {
            $This.Output = @( )

            ForEach ( $Item in $This.List -Split "," )
            {
                $This.Output += [AppxObject]::New($Item)
            }
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
            $This.Privacy                    = [Privacy]::New().Output
            $This.Service                    = [Service]::New().Output
            $This.Context                    = [Context]::New().Output
            $This.Taskbar                    = [Taskbar]::New().Output
            $This.Explorer                   = [Explorer]::New().Output
            $This.StartMenu                  = [StartMenu]::New().Output
            $This.Paths                      = [Paths]::New().Output
            $This.Icons                      = [Icons]::New().Output
            $This.LockScreen                 = [LockScreen]::New().Output
            $This.Miscellaneous              = [Miscellaneous]::New().Output
            $This.PhotoViewer                = [PhotoViewer]::New().Output
            $This.WindowsApps                = [WindowsApps]::New().Output
            $This.WindowsUpdate              = [WindowsUpdate]::New().Output
            $This.AppX                       = [AppXCollection]::New().Output
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

    $Xaml.IO._Feedback.Add_Click({      Start https://github.com/madbomb122/Win10Script/issues })
    $Xaml.IO._FAQ.Add_Click({           Start https://github.com/madbomb122/Win10Script/blob/master/README.md })
    $Xaml.IO._About.Add_Click({         [System.Windows.Messagebox]::Show('This script performs various settings/tweaks for Windows 10.','About','OK') })
    $Xaml.IO._Copyright.Add_Click({     [System.Windows.Messagebox]::Show($Copyright) })
    $Xaml.IO._Contact.Add_Click({ })
    $Xaml.IO._Donation.Add_Click({      Start https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/ })
    $Xaml.IO._Madbomb.Add_Click({       Start https://github.com/madbomb122/ })
    
    $Xaml.IO._RestorePoint.Add_Click({  $Main.Toggle($Main.Control.RestorePoint)  })  
    $Xaml.IO._ShowSkipped.Add_Click({   $Main.Toggle($Main.Control.ShowSkipped)   }) 
    $Xaml.IO._Restart.Add_Click({       $Main.Toggle($Main.Control.Restart)       }) 
    $Xaml.IO._VersionCheck.Add_Click({  $Main.Toggle($Main.Control.VersionCheck)  }) 
    $Xaml.IO._InternetCheck.Add_Click({ $Main.Toggle($Main.Control.InternetCheck) }) 
    $Xaml.IO._Save.Add_Click({          $Main.Toggle($Main.Control.Save)          }) 
    $Xaml.IO._Load.Add_Click({          $Main.Toggle($Main.Control.Load)          }) 
    $Xaml.IO._WinDefault.Add_Click({    $Main.Toggle($Main.Control.WinDefault)    }) 
    $Xaml.IO._ResetDefault.Add_Click({  $Main.Toggle($Main.Control.ResetDefault)  }) 

    $Xaml.IO._Privacy.ItemsSource       = $Main.Config.Privacy
    $Xaml.IO._Service.ItemsSource       = $Main.Config.Service
    $Xaml.IO._Context.ItemsSource       = $Main.Config.Context
    $Xaml.IO._Taskbar.ItemsSource       = $Main.Config.Taskbar
    $Xaml.IO._Explorer.ItemsSource      = $Main.Config.Explorer
    $Xaml.IO._StartMenu.ItemsSource     = $Main.Config.StartMenu
    $Xaml.IO._Paths.ItemsSource         = $Main.Config.Paths
    $Xaml.IO._Icons.ItemsSource         = $Main.Config.Icons
    $Xaml.IO._LockScreen.ItemsSource    = $Main.Config.LockScreen
    $Xaml.IO._Miscellaneous.ItemsSource = $Main.Config.Miscellaneous
    $Xaml.IO._PhotoViewer.ItemsSource   = $Main.Config.PhotoViewer
    $Xaml.IO._WindowsStore.ItemsSource  = $Main.Config.WindowsApps
    $Xaml.IO._WindowsUpdate.ItemsSource = $Main.Config.WindowsUpdate
    $Xaml.IO._AppX.ItemsSource          = $Main.Config.AppX

    $Xaml.Invoke()
}
