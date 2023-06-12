<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-06-12 17:18:42                                                                  //
 \\==================================================================================================// 

    FileName   : Invoke-cimdb.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Launches the [FightingEntropy(p)] Company Inventory Management Database
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-06-12
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Implement the newer version of the classes and GUI

.Example
#>

# Xaml types
Class cimdbXaml
{
    Static [String] $Content = @(
    '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
    '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
    '        Title="[FightingEntropy]://(Company Information Management Database)"',
    '        Height="680"',
    '        Width="800"',
    '        Topmost="True"',
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
    '                            <Trigger Property="IsSelected"',
    '                                     Value="True">',
    '                                <Setter TargetName="Border"',
    '                                        Property="Background"',
    '                                        Value="#4444FF"/>',
    '                                <Setter Property="Foreground"',
    '                                        Value="#FFFFFF"/>',
    '                            </Trigger>',
    '                            <Trigger Property="IsSelected"',
    '                                     Value="False">',
    '                                <Setter TargetName="Border"',
    '                                        Property="Background"',
    '                                        Value="#DFFFBA"/>',
    '                                <Setter Property="Foreground"',
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
    '        <Style x:Key="DGCombo" TargetType="ComboBox">',
    '            <Setter Property="Margin" Value="0"/>',
    '            <Setter Property="Padding" Value="2"/>',
    '            <Setter Property="Height" Value="18"/>',
    '            <Setter Property="FontSize" Value="10"/>',
    '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
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
    '            <Setter Property="Height" Value="24"/>',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="FontSize" Value="12"/>',
    '            <Setter Property="FontWeight" Value="Normal"/>',
    '        </Style>',
    '        <Style TargetType="CheckBox">',
    '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
    '        </Style>',
    '        <Style TargetType="DataGrid">',
    '            <Setter Property="Margin"',
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
    '                <Trigger Property="AlternationIndex"',
    '                         Value="0">',
    '                    <Setter Property="Background"',
    '                            Value="#F8FFFFFF"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex"',
    '                         Value="1">',
    '                    <Setter Property="Background"',
    '                            Value="#FFF8FFFF"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex"',
    '                         Value="2">',
    '                    <Setter Property="Background"',
    '                            Value="#FFFFF8FF"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex"',
    '                         Value="3">',
    '                    <Setter Property="Background"',
    '                            Value="#F8F8F8FF"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex"',
    '                         Value="4">',
    '                    <Setter Property="Background"',
    '                            Value="#F8FFF8FF"/>',
    '                </Trigger>',
    '                <Trigger Property="IsMouseOver" Value="True">',
    '                    <Setter Property="ToolTip">',
    '                        <Setter.Value>',
    '                            <TextBlock TextWrapping="Wrap"',
    '                                       Width="400"',
    '                                       Background="#000000"',
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
    '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
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
    '        <Grid.ColumnDefinitions>',
    '            <ColumnDefinition Width="120"/>',
    '            <ColumnDefinition Width="*"/>',
    '        </Grid.ColumnDefinitions>',
    '        <!-- Pseudo Tab Control -->',
    '        <Grid Grid.Column="0">',
    '            <Grid.RowDefinitions>',
    '                <RowDefinition Height="120"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '            </Grid.RowDefinitions>',
    '            <Button Grid.Row="0" Name="UidPanel">',
    '                <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\sdplogo.png"/>',
    '            </Button>',
    '            <Button Grid.Row="1" Name="ClientPanel"    Content="[Client]"/>',
    '            <Button Grid.Row="2" Name="ServicePanel"   Content="[Service]"/>',
    '            <Button Grid.Row="3" Name="DevicePanel"    Content="[Device]"/>',
    '            <Button Grid.Row="4" Name="IssuePanel"     Content="[Issue]"/>',
    '            <Button Grid.Row="5" Name="PurchasePanel"  Content="[Purchase]"/>',
    '            <Button Grid.Row="6" Name="InventoryPanel" Content="[Inventory]"/>',
    '            <Button Grid.Row="7" Name="ExpensePanel"   Content="[Expense]"/>',
    '            <Button Grid.Row="8" Name="AccountPanel"   Content="[Account]"/>',
    '            <Button Grid.Row="9" Name="InvoicePanel"   Content="[Invoice]"/>',
    '        </Grid>',
    '        <!-- Pseudo Tab Panels -->',
    '        <Grid Grid.Column="1">',
    '            <Grid.RowDefinitions>',
    '                <RowDefinition Height="*"/>',
    '                <RowDefinition Height="40"/>',
    '            </Grid.RowDefinitions>',
    '            <Grid Grid.Row="0">',
    '                <!-- View UID Panel -->',
    '                <Grid Name="ViewUidPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewUidProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Slot"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewUidFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewUidRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Name="ViewUidOutput">',
    '                        <DataGrid.RowStyle>',
    '                            <Style TargetType="{x:Type DataGridRow}">',
    '                                <Style.Triggers>',
    '                                    <Trigger Property="IsMouseOver" Value="True">',
    '                                        <Setter Property="ToolTip">',
    '                                            <Setter.Value>',
    '                                                <TextBlock Text="{Binding Record}"',
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
    '                            <DataGridTextColumn Header="Index"',
    '                                                Binding="{Binding Index}"',
    '                                                Width="40"/>',
    '                            <DataGridTextColumn Header="Date"',
    '                                                Binding="{Binding Date}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="Time"',
    '                                                Binding="{Binding Time}"',
    '                                                Width="80"/>',
    '                            <DataGridTemplateColumn Header="Slot"',
    '                                                    Width="90">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Slot.Index}"',
    '                                                  Style="{StaticResource DGCombo}"',
    '                                                  IsEnabled="False">',
    '                                            <ComboBoxItem Content="Client"/>',
    '                                            <ComboBoxItem Content="Service"/>',
    '                                            <ComboBoxItem Content="Device"/>',
    '                                            <ComboBoxItem Content="Issue"/>',
    '                                            <ComboBoxItem Content="Purchase"/>',
    '                                            <ComboBoxItem Content="Inventory"/>',
    '                                            <ComboBoxItem Content="Expense"/>',
    '                                            <ComboBoxItem Content="Account"/>',
    '                                            <ComboBoxItem Content="Invoice"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Uid"',
    '                                                Binding="{Binding Uid}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit UID Panel -->',
    '                <Grid Name="EditUidPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <DataGrid Grid.Row="0" Name="EditUidOutput">',
    '                        <DataGrid.RowStyle>',
    '                            <Style TargetType="{x:Type DataGridRow}">',
    '                                <Style.Triggers>',
    '                                    <Trigger Property="IsMouseOver" Value="True">',
    '                                        <Setter Property="ToolTip">',
    '                                            <Setter.Value>',
    '                                                <TextBlock Text="{Binding Record}"',
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
    '                            <DataGridTextColumn Header="Index"',
    '                                                Binding="{Binding Index}"',
    '                                                Width="40"/>',
    '                            <DataGridTextColumn Header="Date"',
    '                                                Binding="{Binding Date}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="Time"',
    '                                                Binding="{Binding Time}"',
    '                                                Width="80"/>',
    '                            <DataGridTemplateColumn Header="Slot" Width="90">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Slot.Index}"',
    '                                                  Style="{StaticResource DGCombo}"',
    '                                                  IsEnabled="False">',
    '                                            <ComboBoxItem Content="Client"/>',
    '                                            <ComboBoxItem Content="Service"/>',
    '                                            <ComboBoxItem Content="Device"/>',
    '                                            <ComboBoxItem Content="Issue"/>',
    '                                            <ComboBoxItem Content="Purchase"/>',
    '                                            <ComboBoxItem Content="Inventory"/>',
    '                                            <ComboBoxItem Content="Expense"/>',
    '                                            <ComboBoxItem Content="Account"/>',
    '                                            <ComboBoxItem Content="Invoice"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Uid"',
    '                                                Binding="{Binding Uid}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Record]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Review selected record properties below&gt;"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="EditUidRecordRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditUidRecord">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Name}"',
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Value"',
    '                                                Binding="{Binding Value}"',
    '                                                Width="2*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Client Panel -->',
    '                <Grid Name="ViewClientPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewClientProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Slot"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="DisplayName"/>',
    '                            <ComboBoxItem Content="Email"/>',
    '                            <ComboBoxItem Content="Phone"/>',
    '                            <ComboBoxItem Content="Last"/>',
    '                            <ComboBoxItem Content="First"/>',
    '                            <ComboBoxItem Content="DOB"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewClientFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewClientRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewClientOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="400"/>',
    '                            <DataGridTemplateColumn Header="Email"',
    '                                                    Width="250">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Phone" Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Last"',
    '                                                Binding="{Binding Record.Last}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="First"',
    '                                                Binding="{Binding Record.First}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="MI"',
    '                                                Binding="{Binding Record.MI}"',
    '                                                Width="50"/>',
    '                            <DataGridTextColumn Header="DOB"',
    '                                                Binding="{Binding Record.DOB}"',
    '                                                Width="100"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="350"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Client Panel -->',
    '                <Grid Name="EditClientPanel" Visibility="Visible">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="45"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Name]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientFirst"',
    '                                 Text="&lt;First&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditClientInitial"',
    '                                 Text="&lt;Mi&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientLast"',
    '                                 Text="&lt;Last&gt;"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientOther"',
    '                                 Text="&lt;Other&gt;"/>',
    '                        <Image Grid.Column="5"',
    '                               Name="EditClientNameIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="2*"/>',
    '                            <ColumnDefinition Width="1*"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Location]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientAddress"',
    '                                 Text="&lt;Address&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditClientCity"',
    '                                 Text="&lt;City&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientRegion"',
    '                                 Text="&lt;State&gt;"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientPostal"',
    '                                 Text="&lt;Postal&gt;"/>',
    '                        <TextBox Grid.Column="5"',
    '                                 Name="EditClientCountry"',
    '                                 Text="&lt;Country&gt;"/>',
    '                        <Image Grid.Column="6"',
    '                               Name="EditClientLocationIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Gender]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditClientGender"',
    '                                  SelectedIndex="2">',
    '                            <ComboBoxItem Content="Male"/>',
    '                            <ComboBoxItem Content="Female"/>',
    '                            <ComboBoxItem Content="-"/>',
    '                        </ComboBox>',
    '                        <Label Grid.Column="2"',
    '                               Content="[D.O.B.]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientMonth"',
    '                                 Text="&lt;Month&gt;"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientDay"',
    '                                 Text="&lt;Day&gt;"/>',
    '                        <TextBox Grid.Column="5"',
    '                                 Name="EditClientYear"',
    '                                 Text="&lt;Year&gt;"/>',
    '                        <Image Grid.Column="6"',
    '                               Name="EditClientDobIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Phone]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                     Name="EditClientPhoneText"/>',
    '                        <Image Grid.Column="2"',
    '                                   Name="EditClientPhoneIcon"/>',
    '                        <Button Grid.Column="3"',
    '                                    Name="EditClientPhoneAdd"',
    '                                    Content="+"/>',
    '                        <ComboBox Grid.Column="4"',
    '                                      Name="EditClientPhoneList"/>',
    '                        <Button Grid.Column="5"',
    '                                Name="EditClientPhoneRemove"',
    '                                Content="-"/>',
    '                        <Button Grid.Column="6"',
    '                                Name="EditClientPhoneMoveUp">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\up.png"/>',
    '                        </Button>',
    '                        <Button Grid.Column="7"',
    '                                Name="EditClientPhoneMoveDown">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\down.png"/>',
    '                        </Button>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                                    Content="[Email]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                     Name="EditClientEmailText"/>',
    '                        <Image Grid.Column="2"',
    '                                   Name="EditClientEmailIcon"/>',
    '                        <Button Grid.Column="3"',
    '                                    Name="EditClientEmailAdd"',
    '                                    Content="+"/>',
    '                        <ComboBox Grid.Column="4"',
    '                                      Name="EditClientEmailList"/>',
    '                        <Button Grid.Column="5"',
    '                                    Name="EditClientEmailRemove"',
    '                                    Content="-"/>',
    '                        <Button Grid.Column="6"',
    '                                Name="EditClientEmailMoveUp">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\up.png"/>',
    '                        </Button>',
    '                        <Button Grid.Column="7"',
    '                                Name="EditClientEmailMoveDown">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\down.png"/>',
    '                        </Button>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="5">',
    '                        <TabItem Header="Device(s)">',
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
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0" Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientDeviceProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Chassis"/>',
    '                                        <ComboBoxItem Content="Vendor"/>',
    '                                        <ComboBoxItem Content="Model"/>',
    '                                        <ComboBoxItem Content="Specification"/>',
    '                                        <ComboBoxItem Content="Serial"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientDeviceFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditClientDeviceRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditClientDeviceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="400"/>',
    '                                        <DataGridTextColumn Header="Chassis"',
    '                                                            Binding="{Binding Record.Chassis}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                            Binding="{Binding Record.Vendor}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Binding="{Binding Record.Model}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Specification"',
    '                                                            Binding="{Binding Record.Specification}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Binding="{Binding Record.Serial}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Client"',
    '                                                            Binding="{Binding Record.Client}"',
    '                                                            Width="350"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditClientDeviceAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientDeviceList"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditClientDeviceRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Issue(s)">',
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
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0" Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientIssueProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="Status"/>',
    '                                        <ComboBoxItem Content="Description"/>',
    '                                        <ComboBoxItem Content="Client"/>',
    '                                        <ComboBoxItem Content="Device"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientIssueFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditClientIssueRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditClientIssueOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Status"',
    '                                                                Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Status}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="New"/>',
    '                                                        <ComboBoxItem Content="Diagnosed"/>',
    '                                                        <ComboBoxItem Content="Commit"/>',
    '                                                        <ComboBoxItem Content="Completed"/>',
    '                                                        <ComboBoxItem Content="-"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                            Binding="{Binding Record.Description}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Client"',
    '                                                            Binding="{Binding Record.Client}"',
    '                                                            Width="350"/>',
    '                                        <DataGridTextColumn Header="Device"',
    '                                                            Binding="{Binding Record.Device}"',
    '                                                            Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditClientIssueAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientIssueList"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditClientIssueRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Invoice(s)">',
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
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0" Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientInvoiceProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Phone"/>',
    '                                        <ComboBoxItem Content="Email"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientInvoiceFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditClientInvoiceSearch"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditClientInvoiceOutput"',
    '                                          ItemsSource="{Binding Invoice}"',
    '                                          Margin="5">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTextColumn Header="Mode"',
    '                                                            Binding="{Binding Record.Mode}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Date"',
    '                                                            Binding="{Binding Record.Date}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Record.Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Phone"',
    '                                                            Binding="{Binding Record.Phone}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTextColumn Header="Email"',
    '                                                            Binding="{Binding Record.Email}"',
    '                                                            Width="150"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditClientInvoiceAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientInvoiceList"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditClientInvoiceRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Service Panel -->',
    '                <Grid Name="ViewServicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewServiceProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="DisplayName"/>',
    '                            <ComboBoxItem Content="Name"/>',
    '                            <ComboBoxItem Content="Cost"/>',
    '                            <ComboBoxItem Content="Description"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewServiceFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewServiceRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewServiceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="400"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Record.Name}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Description"',
    '                                                Binding="{Binding Record.Description}"',
    '                                                Width="300"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Service Panel -->',
    '                <Grid Name="EditServicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                    </Grid.RowDefinitions>',
    '                    <GroupBox Grid.Row="0" Header="[Name]">',
    '                        <TextBox Name="EditServiceName"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="1" Header="[Description]">',
    '                        <TextBox Name="EditServiceDescription"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="2" Header="[Cost]">',
    '                        <TextBox Name="EditServiceCost"/>',
    '                    </GroupBox>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Device Panel -->',
    '                <Grid Name="ViewDevicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewDeviceProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="DisplayName"/>',
    '                            <ComboBoxItem Content="Chassis"/>',
    '                            <ComboBoxItem Content="Vendor"/>',
    '                            <ComboBoxItem Content="Model"/>',
    '                            <ComboBoxItem Content="Specification"/>',
    '                            <ComboBoxItem Content="Serial"/>',
    '                            <ComboBoxItem Content="Client"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewDeviceFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewDeviceRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewDeviceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="400"/>',
    '                            <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="150">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Desktop"/>',
    '                                            <ComboBoxItem Content="Laptop"/>',
    '                                            <ComboBoxItem Content="Smartphone"/>',
    '                                            <ComboBoxItem Content="Tablet"/>',
    '                                            <ComboBoxItem Content="Console"/>',
    '                                            <ComboBoxItem Content="Server"/>',
    '                                            <ComboBoxItem Content="Network"/>',
    '                                            <ComboBoxItem Content="Other"/>',
    '                                            <ComboBoxItem Content="-"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Specification"',
    '                                                Binding="{Binding Record.Specification}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Serial"',
    '                                                Binding="{Binding Record.Serial}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Client"',
    '                                                Binding="{Binding Record.Client}"',
    '                                                Width="350"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="350"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Device Panel -->',
    '                <Grid Name="EditDevicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="300"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="1.5*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Chassis]">',
    '                            <ComboBox Name="EditDeviceChassisList"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Vendor]">',
    '                            <TextBox Name="EditDeviceVendor"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="2" Header="[Model]">',
    '                            <TextBox Name="EditDeviceModel"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="3" Header="[Specification]">',
    '                            <TextBox Name="EditDeviceSpecification"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="2*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Serial]">',
    '                            <TextBox Name="EditDeviceSerial"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Display Name]">',
    '                            <TextBox Name="EditDeviceDisplayName"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="2">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditDeviceClientProperty"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditDeviceClientFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditDeviceClientRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Grid.Column="0"',
    '                                          Name="EditDeviceClientOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Email"',
    '                                                                Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Email}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Phone" Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Phone}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Last"',
    '                                                            Binding="{Binding Record.Last}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="First"',
    '                                                            Binding="{Binding Record.First}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="MI"',
    '                                                            Binding="{Binding Record.MI}"',
    '                                                            Width="50"/>',
    '                                        <DataGridTextColumn Header="DOB"',
    '                                                            Binding="{Binding Record.DOB}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditDeviceClientAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditDeviceClientList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditDeviceClientRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Issue Panel -->',
    '                <Grid Name="ViewIssuePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewIssueProperty">',
    '                            <ComboBoxItem Content="UID"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Status"/>',
    '                            <ComboBoxItem Content="Description"/>',
    '                            <ComboBoxItem Content="Client"/>',
    '                            <ComboBoxItem Content="Device"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewIssueFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewIssueRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewIssueOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="400"/>',
    '                            <DataGridTemplateColumn Header="Status"',
    '                                                    Width="150">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Status}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="New"/>',
    '                                            <ComboBoxItem Content="Diagnosed"/>',
    '                                            <ComboBoxItem Content="Commit"/>',
    '                                            <ComboBoxItem Content="Completed"/>',
    '                                            <ComboBoxItem Content="-"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Description"',
    '                                                Binding="{Binding Record.Description}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Client"',
    '                                                Binding="{Binding Record.Client}"',
    '                                                Width="350"/>',
    '                            <DataGridTextColumn Header="Device"',
    '                                                Binding="{Binding Record.Device}"',
    '                                                Width="350"/>',
    '                            <DataGridTemplateColumn Header="Service" Width="350">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Service}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="350"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Issue Panel -->',
    '                <Grid Name="EditIssuePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="180"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="2*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Status]">',
    '                            <ComboBox Name="EditIssueStatusList"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Description]">',
    '                            <TextBox Name="EditIssueDescription"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="1">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0" Margin="5">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditIssueClientProperty"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditIssueClientFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueClientRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueClientOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Email" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Email}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Phone" Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Phone}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Last"',
    '                                                            Binding="{Binding Record.Last}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="First"',
    '                                                            Binding="{Binding Record.First}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="MI"',
    '                                                            Binding="{Binding Record.MI}"',
    '                                                            Width="50"/>',
    '                                        <DataGridTextColumn Header="DOB"',
    '                                                            Binding="{Binding Record.DOB}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditIssueClientAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueClientList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.UID}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueClientRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Device">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0" Margin="5">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditIssueDeviceProperty"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditIssueDeviceFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueDeviceRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueDeviceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="250"/>',
    '                                        <DataGridTemplateColumn Header="Chassis" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Desktop"/>',
    '                                                        <ComboBoxItem Content="Laptop"/>',
    '                                                        <ComboBoxItem Content="Smartphone"/>',
    '                                                        <ComboBoxItem Content="Tablet"/>',
    '                                                        <ComboBoxItem Content="Console"/>',
    '                                                        <ComboBoxItem Content="Server"/>',
    '                                                        <ComboBoxItem Content="Network"/>',
    '                                                        <ComboBoxItem Content="Other"/>',
    '                                                        <ComboBoxItem Content="-"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                            Binding="{Binding Record.Vendor}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Binding="{Binding Record.Model}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Specification"',
    '                                                            Binding="{Binding Record.Specification}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Binding="{Binding Record.Serial}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Client"',
    '                                                            Binding="{Binding Record.Client}"',
    '                                                            Width="Auto"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditIssueDeviceAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueDeviceList" >',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.UID}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueDeviceRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Service">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0" Margin="5">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditIssueServiceProperty"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditIssueServiceFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueServiceRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueServiceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="250"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Record.Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Cost"',
    '                                                            Binding="{Binding Record.Cost}"',
    '                                                            Width="80"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                            Binding="{Binding Record.Description}"',
    '                                                            Width="300"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditIssueServiceAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueServiceList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.UID}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditIssueServiceRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                    <DataGrid Grid.Row="2" Name="EditIssueRecordList">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Name}"',
    '                                                Width="100"/>',
    '                            <DataGridTemplateColumn Header="Value" Width="*">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox ItemsSource="{Binding Value}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Purchase Panel -->',
    '                <Grid Name="ViewPurchasePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewPurchaseProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Distributor"/>',
    '                            <ComboBoxItem Content="Vendor"/>',
    '                            <ComboBoxItem Content="Serial"/>',
    '                            <ComboBoxItem Content="Model"/>',
    '                            <ComboBoxItem Content="Device"/>',
    '                            <ComboBoxItem Content="Cost"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewPurchaseFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewPurchaseRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewPurchaseOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Distributor"',
    '                                                Binding="{Binding Record.Distributor}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Specification"',
    '                                                Binding="{Binding Record.Specification}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Serial"',
    '                                                Binding="{Binding Record.Serial}"',
    '                                                Width="150"/>',
    '                            <DataGridTemplateColumn Header="IsDevice"',
    '                                                    Width="80">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.IsDevice}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="False"/>',
    '                                            <ComboBoxItem Content="True"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Device"',
    '                                                Binding="{Binding Record.Device}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Purchase Panel -->',
    '                <Grid Name="EditPurchasePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="110"/>',
    '                        <RowDefinition Height="70"/>',
    '                    </Grid.RowDefinitions>',
    '                    <GroupBox Grid.Row="0" Header="[Display Name]">',
    '                        <TextBox Name="EditPurchaseDisplayName"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="1" Header="[Distributor]">',
    '                        <TextBox Name="EditPurchaseDistributor"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="2" Header="[URL]">',
    '                        <TextBox Name="EditPurchaseURL"/>',
    '                    </GroupBox>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="2*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Vendor]">',
    '                            <TextBox Name="EditPurchaseVendor"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Model]">',
    '                            <TextBox Name="EditPurchaseModel"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="2" Header="[Specification]">',
    '                            <TextBox Name="EditPurchaseSpecification"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="4" Header="[Serial]">',
    '                        <TextBox Name="EditPurchaseSerial"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="5" Header="[Device]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="60"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditPurchaseIsDevice">',
    '                                    <ComboBoxItem Content="No"/>',
    '                                    <ComboBoxItem Content="Yes"/>',
    '                                </ComboBox>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditPurchaseDeviceProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditPurchaseDeviceFilter"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditPurchaseDeviceOutput"/>',
    '                                <Button Grid.Column="1"',
    '                                        Name="EditPurchaseDeviceAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="2"',
    '                                          Name="EditPurchaseDeviceList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditPurchaseDeviceRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="6" Header="[Cost]">',
    '                        <TextBox Name="EditPurchaseCost"/>',
    '                    </GroupBox>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Inventory Panel -->',
    '                <Grid Name="ViewInventoryPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewInventoryProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Vendor"/>',
    '                            <ComboBoxItem Content="Model"/>',
    '                            <ComboBoxItem Content="Serial"/>',
    '                            <ComboBoxItem Content="Title"/>',
    '                            <ComboBoxItem Content="Cost"/>',
    '                            <ComboBoxItem Content="Device"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewInventoryFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewInventoryRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Margin="5"',
    '                              Name="ViewInventoryOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Serial"',
    '                                                Binding="{Binding Record.Serial}"',
    '                                                Width="150"/>',
    '                            <DataGridTextColumn Header="Title"',
    '                                                Binding="{Binding Record.Title}"',
    '                                                Width="200"/>',
    '                            <DataGridTemplateColumn Header="IsDevice"',
    '                                                    Width="75">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.IsDevice}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="False"/>',
    '                                            <ComboBoxItem Content="True"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Device" Width="150">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox ItemsSource="{Binding Record.Device}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Inventory Panel -->',
    '                <Grid Name="EditInventoryPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="105"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Vendor]">',
    '                            <TextBox Name="EditInventoryVendor"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Model]">',
    '                            <TextBox Name="EditInventoryModel"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="2" Header="[Serial]">',
    '                            <TextBox Name="EditInventorySerial"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <GroupBox Grid.Column="0" Header="[Title]">',
    '                            <TextBox Name="EditInventoryTitle"/>',
    '                        </GroupBox>',
    '                        <GroupBox Grid.Column="1" Header="[Cost]">',
    '                            <TextBox Name="EditInventoryCost"/>',
    '                        </GroupBox>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="2" Header="[Device]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="60"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditInventoryIsDevice">',
    '                                    <ComboBoxItem Content="No"/>',
    '                                    <ComboBoxItem Content="Yes"/>',
    '                                </ComboBox>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditInventoryDeviceProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditInventoryDeviceFilter"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditInventoryDeviceOutput"/>',
    '                                <Button Grid.Column="1"',
    '                                        Name="EditInventoryDeviceAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="2"',
    '                                          Name="EditInventoryDeviceList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditInventoryDeviceRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </GroupBox>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Expense Panel -->',
    '                <Grid Name="ViewExpensePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewExpenseProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Recipient"/>',
    '                            <ComboBoxItem Content="Account"/>',
    '                            <ComboBoxItem Content="Cost"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewExpenseFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewExpenseRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Margin="5"',
    '                              Name="ViewExpenseOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Recipient"',
    '                                                Binding="{Binding Record.Recipient}"',
    '                                                Width="200"/>',
    '                            <DataGridTemplateColumn Header="IsAccount"',
    '                                                    Width="80">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding IsAccount}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="False"/>',
    '                                            <ComboBoxItem Content="True"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Account"',
    '                                                Binding="{Binding Record.Account}"',
    '                                                Width="100"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Expense Panel -->',
    '                <Grid Name="EditExpensePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="105"/>',
    '                        <RowDefinition Height="70"/>',
    '                    </Grid.RowDefinitions>',
    '                    <GroupBox Grid.Row="0" Header="[Display Name]">',
    '                        <TextBox Name="EditExpenseDisplayName"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="1" Header="[Recipient]">',
    '                        <TextBox Name="EditExpenseRecipient"/>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="2" Header="[Account]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditExpenseIsAccount">',
    '                                    <ComboBoxItem Content="No"/>',
    '                                    <ComboBoxItem Content="Yes"/>',
    '                                </ComboBox>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditExpenseAccountProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditExpenseAccountFilter"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditExpenseAccountOutput"/>',
    '                                <Button Grid.Column="1"',
    '                                        Name="EditExpenseAccountAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="2"',
    '                                          Name="EditExpenseAccountList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditExpenseAccountRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </GroupBox>',
    '                    <GroupBox Grid.Row="3" Header="[Cost]">',
    '                        <TextBox Name="EditExpenseCost"/>',
    '                    </GroupBox>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Account Panel -->',
    '                <Grid Name="ViewAccountPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewAccountProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Object"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewAccountFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewAccountRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Margin="5"',
    '                              Name="ViewAccountOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Object"',
    '                                                Binding="{Binding Record.Object}"',
    '                                                Width="300"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Account Panel -->',
    '                <Grid Name="EditAccountPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="105"/>',
    '                    </Grid.RowDefinitions>',
    '                    <GroupBox Grid.Column="0" Header="[Object]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditAccountObjectProperty"/>',
    '                                <TextBox Grid.Column="1"',
    '                                         Name="EditAccountObjectFilter"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <ComboBox Grid.Column="0"',
    '                                          Name="EditAccountObjectResult"/>',
    '                                <Button Grid.Column="1"',
    '                                        Name="EditAccountObjectAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="2"',
    '                                          Name="EditAccountObjectList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditAccountObjectRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </GroupBox>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="0">',
    '                <!-- View Invoice Panel -->',
    '                <Grid Name="ViewInvoicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="130"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ViewInvoiceProperty">',
    '                            <ComboBoxItem Content="Uid"/>',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="DisplayName"/>',
    '                            <ComboBoxItem Content="Mode"/>',
    '                            <ComboBoxItem Content="Phone"/>',
    '                            <ComboBoxItem Content="Email"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewInvoiceFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewInvoiceRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Margin="5"',
    '                              Name="ViewInvoiceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Date"',
    '                                                Binding="{Binding Record.Date}"',
    '                                                Width="250"/>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Record.Name}"',
    '                                                Width="250"/>',
    '                            <DataGridTextColumn Header="Phone"',
    '                                                Binding="{Binding Record.Last}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="Email"',
    '                                                Binding="{Binding Record.First}"',
    '                                                Width="200"/>',
    '                            <DataGridTextColumn Header="UID"',
    '                                                Binding="{Binding Record.UID}"',
    '                                                Width="250"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Invoice Panel -->',
    '                <Grid Name="EditInvoicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="70"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="180"/>',
    '                    </Grid.RowDefinitions>',
    '                    <GroupBox Grid.Row="0" Header="[Mode]">',
    '                        <ComboBox Name="EditInvoiceModeList"/>',
    '                    </GroupBox>',
    '                    <TabControl Grid.Row="1">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditInvoiceClientProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Email"/>',
    '                                        <ComboBoxItem Content="Phone"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditInvoiceClientFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceClientRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoiceClientOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayNameName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTemplateColumn Header="Email" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Email}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Phone" Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Phone}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Last"',
    '                                                            Binding="{Binding Record.Last}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="First"',
    '                                                            Binding="{Binding Record.First}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="MI"',
    '                                                            Binding="{Binding Record.MI}"',
    '                                                            Width="50"/>',
    '                                        <DataGridTextColumn Header="DOB"',
    '                                                            Binding="{Binding Record.DOB}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.Uid}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditInvoiceClientAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditInvoiceClientList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceClientRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Issue">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditInvoiceIssueProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="Status"/>',
    '                                        <ComboBoxItem Content="Description"/>',
    '                                        <ComboBoxItem Content="Client"/>',
    '                                        <ComboBoxItem Content="Device"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditInvoiceIssueFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceIssueRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoiceIssueOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTemplateColumn Header="Status"',
    '                                                                Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Status}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="New"/>',
    '                                                        <ComboBoxItem Content="Diagnosed"/>',
    '                                                        <ComboBoxItem Content="Commit"/>',
    '                                                        <ComboBoxItem Content="Completed"/>',
    '                                                        <ComboBoxItem Content="-"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                            Binding="{Binding Record.Description}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTemplateColumn Header="Client" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Client}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Device" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Device}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Service" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Service}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditInvoiceIssueAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditInvoiceIssueList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceIssueRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Purchase">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditInvoicePurchaseProperty">',
    '                                        <ComboBoxItem Content="UID"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="Distributor"/>',
    '                                        <ComboBoxItem Content="Vendor"/>',
    '                                        <ComboBoxItem Content="Serial"/>',
    '                                        <ComboBoxItem Content="Model"/>',
    '                                        <ComboBoxItem Content="Device"/>',
    '                                        <ComboBoxItem Content="Cost"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditInvoicePurchaseFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoicePurchaseRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoicePurchaseOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTextColumn Header="Distributor"',
    '                                                            Binding="{Binding Record.Distributor}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                            Binding="{Binding Record.Vendor}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Binding="{Binding Record.Model}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Specification"',
    '                                                            Binding="{Binding Record.Specification}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Binding="{Binding Record.Serial}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTemplateColumn Header="IsDevice"',
    '                                                                Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.IsDevice}">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Device"',
    '                                                            Binding="{Binding Record.Device}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTextColumn Header="Cost"',
    '                                                            Binding="{Binding Record.Cost}"',
    '                                                            Width="80"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditInvoicePurchaseAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditInvoicePurchaseList">',
    '                                        <ComboBox.ItemTemplate>',
    '                                            <DataTemplate>',
    '                                                <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                            </DataTemplate>',
    '                                        </ComboBox.ItemTemplate>',
    '                                    </ComboBox>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoicePurchaseRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Inventory">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Column="0"',
    '                                              Name="EditInvoiceInventoryProperty">',
    '                                        <ComboBoxItem Content="UID"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="Vendor"/>',
    '                                        <ComboBoxItem Content="Model"/>',
    '                                        <ComboBoxItem Content="Serial"/>',
    '                                        <ComboBoxItem Content="Title"/>',
    '                                        <ComboBoxItem Content="Cost"/>',
    '                                        <ComboBoxItem Content="Device"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="EditInvoiceInventoryFilter"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceInventoryRefresh"',
    '                                            Content="Search"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoiceInventoryOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                            Binding="{Binding Record.Vendor}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Binding="{Binding Record.Model}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Binding="{Binding Record.Serial}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Title"',
    '                                                            Binding="{Binding Record.Title}"',
    '                                                            Width="200"/>',
    '                                        <DataGridTemplateColumn Header="IsDevice"',
    '                                                                Width="75">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.IsDevice}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Device" Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Record.Device}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Cost"',
    '                                                            Binding="{Binding Record.Cost}"',
    '                                                            Width="80"/>',
    '                                        <DataGridTextColumn Header="UID"',
    '                                                            Binding="{Binding Record.UID}"',
    '                                                            Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="EditInvoiceInventoryAdd"',
    '                                            Content="+"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditInvoiceInventoryList"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="EditInvoiceInventoryRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                    <DataGrid Name="EditInvoiceRecordList" Grid.Row="2">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Name}"',
    '                                                Width="100"/>',
    '                            <DataGridTemplateColumn Header="Value"',
    '                                                    Width="*">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox ItemsSource="{Binding Value}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '            </Grid>',
    '            <Grid Grid.Row="1">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Button Grid.Column="0"',
    '                        Name="View"',
    '                        Content="View"/>',
    '                <Button Grid.Column="1"',
    '                        Name="New"',
    '                        Content="New"/>',
    '                <Button Grid.Column="2"',
    '                        Name="Edit"',
    '                        Content="Edit"/>',
    '                <Button Grid.Column="3"',
    '                        Name="Save"',
    '                        Content="Save"/>',
    '                <Button Grid.Column="4"',
    '                        Name="Delete"',
    '                        Content="Delete"/>',
    '            </Grid>',
    '        </Grid>',
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

# Database templates/types
Enum cimdbSlotType
{
    Client
    Service
    Device
    Issue
    Purchase
    Inventory
    Expense
    Account
    Invoice
}

Class cimdbSlotItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbSlotItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbSlotType]::$Name
        $This.Name  = [cimdbSlotType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbSlotList
{
    [Object] $Output
    cimdbSlotList()
    {
        $This.Refresh()
    }
    [Object] cimdbSlotItem([String]$Name)
    {
        Return [cimdbSlotItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear() 
        ForEach ($Name in [System.Enum]::GetNames([cimdbSlotType]))
        {
            $Item             = $This.cimdbSlotItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Client     { "Tracks identity, phone(s), email(s), device(s), issue(s), and invoice(s)"  }
                Service    { "Tracks the name, description, rate/price of labor"                         }
                Device     { "Information such as make, model, serial number, etc."                      }
                Issue      { "Particular notes and statuses about a particular device"                   }
                Purchase   { "Item or service required for an issue or sale"                             }
                Inventory  { "Item specifically meant for sale"                                          }
                Expense    { "Good(s), service(s), or bill(s)"                                           }
                Account    { "Monetary silo or information for a particular vendor or external business" }
                Invoice    { "Representation of a sale"                                                  }
            }

            $This.Output += $Item
        }
    }
    [Object] Get([String]$name)
    {
        Return $This.Output | ? Name -eq $Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdbSlot[List]>"
    }
}

Enum cimdbModeType
{
    ViewUid
    EditUid
    ViewClient
    EditClient 
    ViewService
    EditService
    ViewDevice 
    EditDevice
    ViewIssue
    EditIssue
    ViewPurchase
    EditPurchase
    ViewInventory
    EditInventory
    ViewExpense
    EditExpense
    ViewAccount
    EditAccount
    ViewInvoice
    EditInvoice
}

Class cimdbModeItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbModeItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbModeType]::$Name
        $This.Name  = [cimdbModeType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbModeList
{
    [Object] $Output
    cimdbModeList()
    {
        $This.Refresh()
    }
    [Object] cimdbModeItem([String]$Name)
    {
        Return [cimdbModeItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbModeType]))
        {
            $This.Output += $This.cimdbModeItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Mode[List]>"
    }
}

Class cimdbUid
{
    [UInt32]  $Index
    [Object]   $Date
    [Object]   $Time
    [Object]   $Slot
    [String]    $Uid
    [Object] $Record
    cimdbUid([UInt32]$Index,[Object]$Slot)
    {
        $This.Index  = $Index
        $This.Main()
        $This.Uid    = $This.NewGuid()
        $This.Slot   = $Slot
    }
    Main()
    {
        $DateTime    = $This.GetDateTime() -Split " "
        $This.Date   = $DateTime[0]
        $This.Time   = $DateTime[1]
    }
    Insert([Object]$Record)
    {
        $This.Record = $Record
    }
    [String] NewGuid()
    {
        Return [Guid]::NewGuid()
    }
    [String] GetDateTime()
    {
        Return [DateTime]::Now.ToString("MM/dd/yyyy HH:mm:ss")
    }
    [String] ToString()
    {
        Return $This.Slot
    }
}

Class cimdbListTemplate
{
    [String]   $Name
    [UInt32]  $Count
    [Object] $Output
    cimdbListTemplate([String]$Name)
    {
        $This.Name = $Name
    }
    Clear()
    {
        $This.Output = @( )
        $This.GetCount()
    }
    GetCount()
    {
        $This.Count  = $This.Output.Count
    }
    Add([Object]$Item)
    {
        $This.Output += $Item
        $This.GetCount()
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.List[Template]>"
    }
}

Class cimdbClientTemplate
{
    [UInt32]          $Rank
    [String]   $DisplayName
    [Object]          $Name
    [Object]           $Dob
    [String]        $Gender
    [Object]      $Location
    [Object]         $Image
    [Object]         $Phone
    [Object]         $Email
    [Object]        $Device
    [Object]         $Issue
    [Object]       $Invoice
    cimdbClientTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client[Template]>"
    }
}

Class cimdbServiceTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [String]        $Name
    [String] $Description
    [Float]         $Cost
    cimdbServiceTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service[Template]>"
    }
}

Class cimdbDeviceTemplate
{
    [UInt32]          $Rank
    [String]   $DisplayName
    [String]       $Chassis
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [String]        $Client
    cimdbDeviceTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device[Template]>"
    }
}

Class cimdbIssueTemplate
{
    [UInt32]        $Rank
    [Object] $DisplayName
    [Object]      $Status
    [String] $Description
    [String]      $Client
    [String]      $Device
    [Object]     $Service
    [Object]     $Invoice
    cimdbIssueTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue[Template]>"
    }
}

Class cimdbPurchaseTemplate
{
    [UInt32]          $Rank
    [Object]   $DisplayName
    [Object]   $Distributor
    [Object]           $URL
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [Bool]        $IsDevice
    [String]        $Device
    [Object]          $Cost
    cimdbPurchaseTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase[Template]>"
    }
}

Class cimdbInventoryTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [String]      $Vendor
    [String]       $Model
    [String]      $Serial
    [Object]       $Title
    [Object]        $Cost
    [Bool]      $IsDevice
    [Object]      $Device
    cimdbInventoryTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory[Template]>"
    }
}

Class cimdbExpenseTemplate
{
    [UInt32]        $Rank
    [Object] $DisplayName
    [Object]   $Recipient
    [Object]   $IsAccount
    [Object]     $Account
    [Object]        $Cost
    cimdbExpenseTemplate()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense[Template]>"
    }
}

Class cimdbAccountTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [Object]      $Object
    cimdbAccountTemplate()
    {
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account[Template]>"
    }
}

Class cimdbInvoiceTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [UInt32]        $Mode
    [Object]      $Client
    [Object]       $Issue
    [Object]    $Purchase
    [Object]   $Inventory
    cimdbInvoiceTemplate()
    {
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice[Template]>"
    }
}

Class cimdbDatabaseController
{
    [Object]   $Slot
    [Object]   $Mode
    [Object] $Output
    cimdbDatabaseController()
    {
        $This.Slot = $This.cimdbSlotList()
        $This.Mode = $This.cimdbModeList()
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbSlotList()
    {
        Return [cimdbSlotList]::New()
    }
    [Object] cimdbModeList()
    {
        Return [cimdbModeList]::New()
    }
    [Object] cimdbUid([UInt32]$Index,[Object]$Slot)
    {
        Return [cimdbUid]::New($Index,$Slot)
    }
    [Object] cimdbClientTemplate()
    {
        Return [cimdbClientTemplate]::New()
    }
    [Object] cimdbServiceTemplate()
    {
        Return [cimdbServiceTemplate]::New()
    }
    [Object] cimdbDeviceTemplate()
    {
        Return [cimdbDeviceTemplate]::New()
    }
    [Object] cimdbIssueTemplate()
    {
        Return [cimdbIssueTemplate]::New()
    }
    [Object] cimdbPurchaseTemplate()
    {
        Return [cimdbPurchaseTemplate]::New()
    }
    [Object] cimdbInventoryTemplate()
    {
        Return [cimdbInventoryTemplate]::New()
    }
    [Object] cimdbExpenseTemplate()
    {
        Return [cimdbExpenseTemplate]::New()
    }
    [Object] cimdbAccountTemplate()
    {
        Return [cimdbAccountTemplate]::New()
    }
    [Object] cimdbInvoiceTemplate()
    {
        Return [cimdbInvoiceTemplate]::New()
    }
    [Object] Entry([String]$Name)
    {
        Return $This.cimdbUid($This.Output.Count,$This.Slot.Output[$This.GetIndex($Name)])
    }
    [String] GetName([UInt32]$Index)
    {
        Return [cimdbSlotType]$Index
    }
    [Uint32] GetIndex([String]$Name)
    {
        Return [UInt32][cimdbSlotType]::$Name
    }
    [Object[]] GetSlot([String]$Name)
    {
        Return @($This.Output | ? Slot -match $Name)
    }
    [Object] New([String]$Name)
    {
        $Uid        = $This.Entry($Name)
        $Uid.Record = Switch ($Name)
        {
            Client    {    $This.cimdbClientTemplate() }
            Service   {   $This.cimdbServiceTemplate() }
            Device    {    $This.cimdbDeviceTemplate() }
            Issue     {     $This.cimdbIssueTemplate() }
            Purchase  {  $This.cimdbPurchaseTemplate() }
            Inventory { $This.cimdbInventoryTemplate() }
            Expense   {   $This.cimdbExpenseTemplate() }
            Account   {   $This.cimdbAccountTemplate() }
            Invoice   {   $This.cimdbInvoiceTemplate() }
        }

        $Uid.Record.Rank = $This.GetSlot($Name).Count

        Return $Uid
    }
    Delete([Object]$Uid)
    {
        $This.Output = $This.Output | ? Uid -notmatch $Uid.Uid
        $This.Rerank()
    }
    Add([Object]$String)
    {
        Switch -Regex ($String)
        {
            "^\d$"
            {
                $This.Output += $This.New($This.GetName([UInt32]$String))
            }
            Default
            {
                $This.Output += $This.New($String)
            }
        }
    }
    Rerank()
    {
        Switch ($This.Output.Count)
        {
            0
            {

            }
            1
            {
                $This.Output[0].Index = 0
            }
            Default
            {
                ForEach ($X in 0..($This.Output.Count-1))
                {
                    $This.Output[$X].Index = $X
                }
            }
        }
    }
    Generate([UInt32]$Length)
    {
        ForEach ($X in 0..($Length-1))
        {
            $This.Add($This.GetRandom())
        }
    }
    [UInt32] GetRandom()
    {
        Return Get-Random -Max 9
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Database[Controller]>"
    }
}

# GUI Enums
Enum UidPropertyType
{
    Index
    Slot
    Uid
    Date
    Time
    Record
}

Enum ClientPropertyType
{
    Rank
    DisplayName
    Name
    Dob
    Gender
    Location
    Image
    Phone
    Email
    Device
    Issue
    Invoice
}

Enum ServicePropertyType
{
    Rank
    DisplayName
    Name
    Description
    Cost
}

Enum DevicePropertyType
{
    Rank
    DisplayName
    Chassis
    Vendor
    Model
    Specification
    Serial
    Client
}

Enum IssuePropertyType
{
    Rank
    DisplayName
    Status
    Description
    Client
    Device
    Service
    Invoice
}

Enum PurchasePropertyType
{
    Rank
    DisplayName
    Distributor
    URL
    Vendor
    Model
    Specification
    Serial
    IsDevice
    Device
    Cost
}

Enum InventoryPropertyType
{
    Rank
    DisplayName
    Vendor
    Model
    Serial
    Title
    Cost
    IsDevice
    Device
}

Enum ExpensePropertyType
{
    Rank
    DisplayName
    Recipient
    IsAccount
    Account
    Cost
}

Enum AccountPropertyType
{
    Rank
    DisplayName
    Object
}

Enum InvoicePropertyType
{
    Rank
    DisplayName
    Mode
    Client
    Issue
    Purchase
    Inventory
}

Enum ButtonPanelType
{
    UidPanel
    ClientPanel
    ServicePanel
    DevicePanel
    IssuePanel
    PurchasePanel
    InventoryPanel
    ExpensePanel
    AccountPanel
    InvoicePanel
}

Class cimdbControllerProperty
{
    [String]  $Name
    [Object] $Value
    cimdbControllerProperty([Object]$Property)
    {
        $This.Name  = $Property.Name
        $This.Value = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Controller[Property]>"
    }
}

Class cimdbCurrentController
{
    [Object]   $Mode
    [Object]    $Uid
    cimdbCurrentController()
    {

    }
    SetMode([Object]$Mode)
    {
        $This.Mode = $Mode
    }
    SetUid([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Current[Controller]>"
    }
}

Class cimdbController
{
    [Object]   $Module
    [Object]     $Xaml
    [Object] $Database
    [Object]  $Current
    cimdbController([Object]$Module)
    {
        # Assign FEModule, this will allow module/console to be imported
        $This.Module = $Module
        $This.Main()
    }
    cimdbController()
    {
        # Load FEModule, this will instantiate the module/console
        $This.Module = $This.Get("Module")
        $This.Main()
    }
    Main()
    {
        # Load the Xaml interface
        $This.Xaml     = $This.Get("Xaml")

        # Load the database controller + template
        $This.Database = $This.Get("Database")

        # Load current object
        $This.Current  = $This.Get("Current")
        
        # Set Default Mode
        $This.SetCurrentMode("ViewUid")
    }
    Update([Int32]$State,[String]$Status)
    {
        # Updates the console
        $This.Module.Update($State,$Status)
        $Last = $This.Module.Console.Last()
        If ($This.Module.Mode -ne 0)
        {
            [Console]::WriteLine($Last.String)
        }
    }
    Error([UInt32]$State,[String]$Status)
    {
        $This.Module.Update($State,$Status)
        Throw $This.Module.Console.Last().Status
    }
    DumpConsole()
    {
        $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
        $This.Update(100,"[+] Dumping console: [$xPath]")
        $This.Console.Finalize()
        
        $Value = $This.Console.Output | % ToString

        [System.IO.File]::WriteAllLines($xPath,$Value)
    }
    [String] LogPath()
    {
        $xPath = $This.ProgramData()

        ForEach ($Folder in $This.Author(), "cimdb")
        {
            $xPath = $xPath, $Folder -join "\"
            If (![System.IO.Directory]::Exists($xPath))
            {
                [System.IO.Directory]::CreateDirectory($xPath)
            }
        }

        Return $xPath
    }
    [String] Now()
    {
        Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
    }
    [String] ProgramData()
    {
        Return [Environment]::GetEnvironmentVariable("ProgramData")
    }
    [String] Author()
    {
        Return "Secure Digits Plus LLC"
    }
    [Object] Get([String]$Name)
    {
        $Item = $Null

        Switch ($Name)
        {
            Module
            {
                $Item = Get-FEModule -Mode 1
            }
            Xaml
            {
                $This.Update(0,"Getting [~] Xaml Controller")
                $Item = [XamlWindow][cimdbXaml]::Content
            }
            Database
            {
                $This.Update(0,"Getting [~] Database Controller")
                $Item = [cimdbDatabaseController]::New()
            }
            Current
            {
                $This.Update(0,"Getting [~] Current Controller")
                $Item = [cimdbCurrentController]::New()
            }
            Default
            {
                $This.Update(0,"Getting [!] Invalid <$Name>")
                $Item = $Null
            }
        }

        Return $Item
    }
    [Object] cimdbControllerProperty([Object]$Property)
    {
        Return [cimdbControllerProperty]::New($Property)
    }
    SetCurrentMode([String]$Mode)
    {
        $This.Current.Mode = $This.CurrentMode($Mode)
    }
    SetCurrentUid([Object]$Uid)
    {
        $This.Current.Uid  = $Uid
    }
    [Object] CurrentMode([String]$Mode)
    {
        Return $This.Database.Mode.Output | ? Name -eq $Mode
    }
    [String] Escape([String]$String)
    {
        Return [Regex]::Escape($String)
    }
    [String] Graphic([String]$Name)
    {
        $Item = Switch ($Name)
        {
            up       { "up.png"      }
            down     { "down.png"    }
            failure  { "failure.png" }
            success  { "success.png" }
            warning  { "warning.png" }
        }

        Return $This.Module._Control($Item).Fullname
    }
    Generate([UInt32]$Length)
    {
        ForEach ($X in 0..($Length-1))
        {
            $This.Database.Add($This.GetRandom())
        }
    }
    [UInt32] GetRandom()
    {
        Return Get-Random -Max 9
    }
    Reset([Object]$xSender,[Object]$Object)
    {
        If ($This.Module.Mode -eq 2)
        {
            $This.Update(0,$xSender.Name)
        }

        $xSender.Items.Clear()
        ForEach ($Item in $Object)
        {
            $xSender.Items.Add($Item)
        }
    }
    [Object[]] Property([Object]$Object)
    {
        Return $Object.PSObject.Properties | % { $This.cimdbControllerProperty($_) }
    }
    [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
    {
        $Item = Switch ($Mode)
        {
            0 { $Object.PSObject.Properties | ? Name -notin $Property }
            1 { $Object.PSObject.Properties | ? Name    -in $Property }
        }

        Return $Item | % { $This.cimdbControllerProperty($_) }
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
    View()
    {
        $Ctrl = $This

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                $Ctrl.Handle("EditUid")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditUidOutput,$Ctrl.Current.Uid)
                $Ctrl.Reset($Ctrl.Xaml.IO.EditUidRecord,$Ctrl.Property($Ctrl.Current.Uid.Record))
            }
            Client
            {
                $Ctrl.Handle("EditClient")
            }
            Service
            {

            }
            Device
            {

            }
            Issue
            {

            }
            Purchase
            {

            }
            Inventory
            {

            }
            Expense
            {

            }
            Account
            {

            }
            Invoice
            {

            }
        }

        $Ctrl.Xaml.IO.View.IsEnabled = 0
    }
    New()
    {
        $Ctrl = $This
        $Ctrl.SetCurrentUid($Null)

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {
                $Ctrl.Handle("EditClient")
            }
            Service
            {

            }
            Device
            {

            }
            Issue
            {

            }
            Purchase
            {

            }
            Inventory
            {

            }
            Expense
            {

            }
            Account
            {

            }
            Invoice
            {

            }
        }

        $Ctrl.Xaml.IO.New.IsEnabled = 0
    }
    Edit()
    {
        $Ctrl = $This

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {

            }
            Service
            {

            }
            Device
            {

            }
            Issue
            {

            }
            Purchase
            {

            }
            Inventory
            {

            }
            Expense
            {

            }
            Account
            {

            }
            Invoice
            {

            }
        }

        $Ctrl.Xaml.IO.Edit.IsEnabled = 0
    }
    Save()
    {
        $Ctrl = $This

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {

            }
            Service
            {

            }
            Device
            {

            }
            Issue
            {

            }
            Purchase
            {

            }
            Inventory
            {

            }
            Expense
            {

            }
            Account
            {

            }
            Invoice
            {

            }
        }

        $Ctrl.Xaml.IO.Save.IsEnabled = 0
    }
    Delete()
    {
        $Ctrl = $This

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                $Ctrl.Database.Delete($Ctrl.Current.Uid)
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,$Ctrl.Database.Output)
            }
            Client
            {

            }
            Service
            {

            }
            Device
            {

            }
            Issue
            {

            }
            Purchase
            {

            }
            Inventory
            {

            }
            Expense
            {

            }
            Account
            {

            }
            Invoice
            {

            }
        }

        # Clear record cache
        $Ctrl.SetCurrentUid($Null)

        # Clear buttons
        $Ctrl.Xaml.IO.View.IsEnabled   = 0
        $Ctrl.Xaml.IO.Delete.IsEnabled = 0
    }
    Initial([String]$Name)
    {
        $Ctrl = $This

        Switch ($Name)
        {
            ViewUid
            {
                $Ctrl.Xaml.IO.ViewUidProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewUidFilter.Text            = ""
            }
            EditUid
            {

            }
            ViewClient
            {
                $Ctrl.Xaml.IO.ViewClientProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewClientFilter.Text            = ""
            }
            EditClient
            {
                If ($Ctrl.Current.Uid)
                {

                }

                $Ctrl.Xaml.IO.EditClientFirst              = 
                $Ctrl.Xaml.IO.EditClientInitial            = 
                $Ctrl.Xaml.IO.EditClientLast               = 
                $Ctrl.Xaml.IO.EditClientOther              = 
                $Ctrl.Xaml.IO.EditClientNameIcon           = 
                $Ctrl.Xaml.IO.EditClientAddress            = 
                $Ctrl.Xaml.IO.EditClientCity               = 
                $Ctrl.Xaml.IO.EditClientRegion             = 
                $Ctrl.Xaml.IO.EditClientPostal             = 
                $Ctrl.Xaml.IO.EditClientCountry            = 
                $Ctrl.Xaml.IO.EditClientLocationIcon       = 
                $Ctrl.Xaml.IO.EditClientGender             = 
                $Ctrl.Xaml.IO.EditClientMonth              = 
                $Ctrl.Xaml.IO.EditClientDay                = 
                $Ctrl.Xaml.IO.EditClientYear               = 
                $Ctrl.Xaml.IO.EditClientDobIcon            = 
                $Ctrl.Xaml.IO.EditClientPhoneText          = 
                $Ctrl.Xaml.IO.EditClientPhoneAdd           = 
                $Ctrl.Xaml.IO.EditClientPhoneList          = 
                $Ctrl.Xaml.IO.EditClientPhoneRemove        = 
                $Ctrl.Xaml.IO.EditClientEmailText          = 
                $Ctrl.Xaml.IO.EditClientEmailAdd           = 
                $Ctrl.Xaml.IO.EditClientEmailList          = 
                $Ctrl.Xaml.IO.EditClientEmailRemove        = 
                $Ctrl.Xaml.IO.EditClientDeviceProperty     = 
                $Ctrl.Xaml.IO.EditClientDeviceFilter       = 
                $Ctrl.Xaml.IO.EditClientDeviceRefresh      = 
                $Ctrl.Xaml.IO.EditClientDeviceOutput       = 
                $Ctrl.Xaml.IO.EditClientDeviceAdd          = 
                $Ctrl.Xaml.IO.EditClientDeviceList         = 
                $Ctrl.Xaml.IO.EditClientDeviceRemove       = 
                $Ctrl.Xaml.IO.EditClientIssueProperty      = 
                $Ctrl.Xaml.IO.EditClientIssueFilter        = 
                $Ctrl.Xaml.IO.EditClientIssueRefresh       = 
                $Ctrl.Xaml.IO.EditClientIssueOutput        = 
                $Ctrl.Xaml.IO.EditClientIssueAdd           = 
                $Ctrl.Xaml.IO.EditClientIssueList          = 
                $Ctrl.Xaml.IO.EditClientIssueRemove        = 
                $Ctrl.Xaml.IO.EditClientInvoiceProperty    = 
                $Ctrl.Xaml.IO.EditClientInvoiceFilter      = 
                $Ctrl.Xaml.IO.EditClientInvoiceSearch      = 
                $Ctrl.Xaml.IO.EditClientInvoiceOutput      = 
                $Ctrl.Xaml.IO.EditClientInvoiceAdd         = 
                $Ctrl.Xaml.IO.EditClientInvoiceList        = 
                $Ctrl.Xaml.IO.EditClientInvoiceRemove      = 
            }
            ViewService
            {
                $Ctrl.Xaml.IO.ViewServiceProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewServiceFilter.Text            = ""
            }
            EditService
            {

            }
            ViewDevice
            {
                $Ctrl.Xaml.IO.ViewDeviceProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewDeviceFilter.Text            = ""
            }
            EditDevice
            {

            }
            ViewIssue
            {
                $Ctrl.Xaml.IO.ViewIssueProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewIssueFilter.Text            = ""
            }
            EditIssue
            {

            }
            ViewPurchase
            {
                $Ctrl.Xaml.IO.ViewPurchaseProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewPurchaseFilter.Text            = ""
            }
            EditPurchase
            {

            }
            ViewInventory
            {
                $Ctrl.Xaml.IO.ViewInventoryProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewInventoryFilter.Text            = ""
            }
            EditInventory
            {

            }
            ViewExpense
            {
                $Ctrl.Xaml.IO.ViewAccountProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewAccountFilter.Text            = ""
            }
            EditExpense
            {

            }
            ViewAccount
            {
                $Ctrl.Xaml.IO.ViewAccountProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewAccountFilter.Text            = ""
            }
            EditAccount
            {

            }
            ViewInvoice
            {
                $Ctrl.Xaml.IO.ViewInvoiceProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewInvoiceFilter.Text            = ""
            }
            EditInvoice
            {

            }
        }
    }
    Stage([String]$Name)
    {
        $Ctrl = $This

        Switch ($Name)
        {
            ViewUid
            {
                $Ctrl.Xaml.IO.ViewUidFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewUidProperty,
                                        $Ctrl.Xaml.IO.ViewUidFilter,
                                        $Ctrl.Database.Output,
                                        $Ctrl.Xaml.IO.ViewUidOutput)
                })

                $Ctrl.Xaml.IO.ViewUidOutput.Add_SelectionChanged(
                {
                    $Index = $Ctrl.Xaml.IO.ViewUidOutput.SelectedIndex
                    If ($Index -ne -1)
                    {
                        $Ctrl.Xaml.IO.View.IsEnabled   = 1
                        $Ctrl.Xaml.IO.Delete.IsEnabled = 1
                        $Ctrl.SetCurrentUid($Ctrl.Xaml.IO.ViewUidOutput.SelectedItem)
                    }
                })

                $Ctrl.Xaml.IO.ViewUidOutput.Add_MouseDoubleClick(
                {
                    $Index = $Ctrl.Xaml.IO.ViewUidOutput.SelectedIndex
                    If ($Index -ne -1)
                    {
                        $Ctrl.SetCurrentUid($Ctrl.Xaml.IO.ViewUidOutput.SelectedItem)
                        $Ctrl.View()
                    }
                })

                $Ctrl.Xaml.IO.ViewUidRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,$Ctrl.Database.Output)
                })
            }
            EditUid
            {
                $Ctrl.Xaml.IO.EditUidRecordRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.EditUidRecord,
                                $Ctrl.Property($Ctrl.Xaml.IO.EditUidOutput.Items.Record))
                })
            }
            ViewClient
            {
                $Ctrl.Xaml.IO.ViewClientFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewClientProperty,
                                        $Ctrl.Xaml.IO.ViewClientFilter,
                                        $Ctrl.Database.GetSlot("Client"),
                                        $Ctrl.Xaml.IO.ViewClientOutput)
                })

                $Ctrl.Xaml.IO.ViewClientRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,$Ctrl.Database.GetSlot("Client"))
                })
            }
            EditClient
            {
            <#
                $Ctrl.Xaml.IO.EditClientFirst              = 
                $Ctrl.Xaml.IO.EditClientInitial            = 
                $Ctrl.Xaml.IO.EditClientLast               = 
                $Ctrl.Xaml.IO.EditClientOther              = 
                $Ctrl.Xaml.IO.EditClientNameIcon           = 
                $Ctrl.Xaml.IO.EditClientAddress            = 
                $Ctrl.Xaml.IO.EditClientCity               = 
                $Ctrl.Xaml.IO.EditClientRegion             = 
                $Ctrl.Xaml.IO.EditClientPostal             = 
                $Ctrl.Xaml.IO.EditClientCountry            = 
                $Ctrl.Xaml.IO.EditClientLocationIcon       = 
                $Ctrl.Xaml.IO.EditClientGender             = 
                $Ctrl.Xaml.IO.EditClientMonth              = 
                $Ctrl.Xaml.IO.EditClientDay                = 
                $Ctrl.Xaml.IO.EditClientYear               = 
                $Ctrl.Xaml.IO.EditClientDobIcon            = 
                $Ctrl.Xaml.IO.EditClientPhoneText          = 
                $Ctrl.Xaml.IO.EditClientPhoneAdd           = 
                $Ctrl.Xaml.IO.EditClientPhoneList          = 
                $Ctrl.Xaml.IO.EditClientPhoneRemove        = 
                $Ctrl.Xaml.IO.EditClientEmailText          = 
                $Ctrl.Xaml.IO.EditClientEmailAdd           = 
                $Ctrl.Xaml.IO.EditClientEmailList          = 
                $Ctrl.Xaml.IO.EditClientEmailRemove        = 
                $Ctrl.Xaml.IO.EditClientDeviceProperty     = 
                $Ctrl.Xaml.IO.EditClientDeviceFilter       = 
                $Ctrl.Xaml.IO.EditClientDeviceRefresh      = 
                $Ctrl.Xaml.IO.EditClientDeviceOutput       = 
                $Ctrl.Xaml.IO.EditClientDeviceAdd          = 
                $Ctrl.Xaml.IO.EditClientDeviceList         = 
                $Ctrl.Xaml.IO.EditClientDeviceRemove       = 
                $Ctrl.Xaml.IO.EditClientIssueProperty      = 
                $Ctrl.Xaml.IO.EditClientIssueFilter        = 
                $Ctrl.Xaml.IO.EditClientIssueRefresh       = 
                $Ctrl.Xaml.IO.EditClientIssueOutput        = 
                $Ctrl.Xaml.IO.EditClientIssueAdd           = 
                $Ctrl.Xaml.IO.EditClientIssueList          = 
                $Ctrl.Xaml.IO.EditClientIssueRemove        = 
                $Ctrl.Xaml.IO.EditClientInvoiceProperty    = 
                $Ctrl.Xaml.IO.EditClientInvoiceFilter      = 
                $Ctrl.Xaml.IO.EditClientInvoiceSearch      = 
                $Ctrl.Xaml.IO.EditClientInvoiceOutput      = 
                $Ctrl.Xaml.IO.EditClientInvoiceAdd         = 
                $Ctrl.Xaml.IO.EditClientInvoiceList        = 
                $Ctrl.Xaml.IO.EditClientInvoiceRemove      = 
            #>
            }
            ViewService
            {
                $Ctrl.Xaml.IO.ViewServiceFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewServiceProperty,
                                        $Ctrl.Xaml.IO.ViewServiceFilter,
                                        $Ctrl.Database.GetSlot("Service"),
                                        $Ctrl.Xaml.IO.ViewServiceOutput)
                })
    
                $Ctrl.Xaml.IO.ViewServiceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceOutput,$Ctrl.Database.GetSlot("Service"))
                })
            }
            EditService
            {
            <#
                $Ctrl.Xaml.IO.EditServiceName              = 
                $Ctrl.Xaml.IO.EditServiceDescription       = 
                $Ctrl.Xaml.IO.EditServiceCost              = 
            #>
            }
            ViewDevice
            {
                $Ctrl.Xaml.IO.ViewDeviceFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewDeviceProperty,
                                        $Ctrl.Xaml.IO.ViewDeviceFilter,
                                        $Ctrl.Database.GetSlot("Device"),
                                        $Ctrl.Xaml.IO.ViewDeviceOutput)
                })

                $Ctrl.Xaml.IO.ViewDeviceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceOutput,$Ctrl.Database.GetSlot("Device"))
                })
            }
            EditDevice
            {
            <#
                $Ctrl.Xaml.IO.EditDeviceChassisList        = 
                $Ctrl.Xaml.IO.EditDeviceVendor             = 
                $Ctrl.Xaml.IO.EditDeviceModel              = 
                $Ctrl.Xaml.IO.EditDeviceSpecification      = 
                $Ctrl.Xaml.IO.EditDeviceSerial             = 
                $Ctrl.Xaml.IO.EditDeviceDisplayName        = 
                $Ctrl.Xaml.IO.EditDeviceClientProperty     = 
                $Ctrl.Xaml.IO.EditDeviceClientFilter       = 
                $Ctrl.Xaml.IO.EditDeviceClientRefresh      = 
                $Ctrl.Xaml.IO.EditDeviceClientOutput       = 
                $Ctrl.Xaml.IO.EditDeviceClientAdd          = 
                $Ctrl.Xaml.IO.EditDeviceClientList         = 
                $Ctrl.Xaml.IO.EditDeviceClientRemove       = 
            #>
            }
            ViewIssue
            {
                $Ctrl.Xaml.IO.ViewIssueFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewIssueProperty,
                                        $Ctrl.Xaml.IO.ViewIssueFilter,
                                        $Ctrl.Database.GetSlot("Issue"),
                                        $Ctrl.Xaml.IO.ViewIssueOutput)
                })

                $Ctrl.Xaml.IO.ViewIssueRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueOutput,$Ctrl.Database.GetSlot("Issue"))
                })
            }
            EditIssue
            {
            <#
                $Ctrl.Xaml.IO.EditIssueStatusList          = 
                $Ctrl.Xaml.IO.EditIssueDescription         = 
                $Ctrl.Xaml.IO.EditIssueClientProperty      = 
                $Ctrl.Xaml.IO.EditIssueClientFilter        = 
                $Ctrl.Xaml.IO.EditIssueClientRefresh       = 
                $Ctrl.Xaml.IO.EditIssueClientOutput        = 
                $Ctrl.Xaml.IO.EditIssueClientAdd           = 
                $Ctrl.Xaml.IO.EditIssueClientList          = 
                $Ctrl.Xaml.IO.EditIssueClientRemove        = 
                $Ctrl.Xaml.IO.EditIssueDeviceProperty      = 
                $Ctrl.Xaml.IO.EditIssueDeviceFilter        = 
                $Ctrl.Xaml.IO.EditIssueDeviceRefresh       = 
                $Ctrl.Xaml.IO.EditIssueDeviceOutput        = 
                $Ctrl.Xaml.IO.EditIssueDeviceAdd           = 
                $Ctrl.Xaml.IO.EditIssueDeviceList          = 
                $Ctrl.Xaml.IO.EditIssueDeviceRemove        = 
                $Ctrl.Xaml.IO.EditIssueServiceProperty     = 
                $Ctrl.Xaml.IO.EditIssueServiceFilter       = 
                $Ctrl.Xaml.IO.EditIssueServiceRefresh      = 
                $Ctrl.Xaml.IO.EditIssueServiceOutput       = 
                $Ctrl.Xaml.IO.EditIssueServiceAdd          = 
                $Ctrl.Xaml.IO.EditIssueServiceList         = 
                $Ctrl.Xaml.IO.EditIssueServiceRemove       = 
                $Ctrl.Xaml.IO.EditIssueRecordList          = 
            #>}
            ViewPurchase
            {
                $Ctrl.Xaml.IO.ViewPurchaseFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewPurchaseProperty,
                                        $Ctrl.Xaml.IO.ViewPurchaseFilter,
                                        $Ctrl.Database.GetSlot("Purchase"),
                                        $Ctrl.Xaml.IO.ViewPurchaseOutput)
                })

                $Ctrl.Xaml.IO.ViewPurchaseRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseOutput,$Ctrl.Database.GetSlot("Purchase"))
                })
            <#
                $Ctrl.Xaml.IO.ViewPurchaseProperty         = 
                $Ctrl.Xaml.IO.ViewPurchaseFilter           = 
                $Ctrl.Xaml.IO.ViewPurchaseRefresh          = 
                $Ctrl.Xaml.IO.ViewPurchaseOutput           = 
            #>
            }
            EditPurchase
            {
            <#
                $Ctrl.Xaml.IO.EditPurchaseDisplayName      = 
                $Ctrl.Xaml.IO.EditPurchaseDistributor      = 
                $Ctrl.Xaml.IO.EditPurchaseURL              = 
                $Ctrl.Xaml.IO.EditPurchaseVendor           = 
                $Ctrl.Xaml.IO.EditPurchaseModel            = 
                $Ctrl.Xaml.IO.EditPurchaseSpecification    = 
                $Ctrl.Xaml.IO.EditPurchaseSerial           = 
                $Ctrl.Xaml.IO.EditPurchaseIsDevice         = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceProperty   = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceFilter     = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceOutput     = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceAdd        = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceList       = 
                $Ctrl.Xaml.IO.EditPurchaseDeviceRemove     = 
                $Ctrl.Xaml.IO.EditPurchaseCost             = 
            #>
            }
            ViewInventory
            {
                $Ctrl.Xaml.IO.ViewInventoryFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewInventoryProperty,
                                        $Ctrl.Xaml.IO.ViewInventoryFilter,
                                        $Ctrl.Database.GetSlot("Inventory"),
                                        $Ctrl.Xaml.IO.ViewInventoryOutput)
                })

                $Ctrl.Xaml.IO.ViewInventoryRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryOutput,$Ctrl.Database.GetSlot("Inventory"))
                })
            <#
                $Ctrl.Xaml.IO.ViewInventoryProperty        = 
                $Ctrl.Xaml.IO.ViewInventoryFilter          = 
                $Ctrl.Xaml.IO.ViewInventoryRefresh         = 
                $Ctrl.Xaml.IO.ViewInventoryOutput          = 
            #>
            }
            EditInventory
            {
            <#
                $Ctrl.Xaml.IO.EditInventoryVendor          = 
                $Ctrl.Xaml.IO.EditInventoryModel           = 
                $Ctrl.Xaml.IO.EditInventorySerial          = 
                $Ctrl.Xaml.IO.EditInventoryTitle           = 
                $Ctrl.Xaml.IO.EditInventoryCost            = 
                $Ctrl.Xaml.IO.EditInventoryIsDevice        = 
                $Ctrl.Xaml.IO.EditInventoryDeviceProperty  = 
                $Ctrl.Xaml.IO.EditInventoryDeviceFilter    = 
                $Ctrl.Xaml.IO.EditInventoryDeviceOutput    = 
                $Ctrl.Xaml.IO.EditInventoryDeviceAdd       = 
                $Ctrl.Xaml.IO.EditInventoryDeviceList      = 
                $Ctrl.Xaml.IO.EditInventoryDeviceRemove    = 
            #>
            }
            ViewExpense
            {
                $Ctrl.Xaml.IO.ViewExpenseFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewExpenseProperty,
                                        $Ctrl.Xaml.IO.ViewExpenseFilter,
                                        $Ctrl.Database.GetSlot("Expense"),
                                        $Ctrl.Xaml.IO.ViewExpenseOutput)
                })

                $Ctrl.Xaml.IO.ViewExpenseRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseOutput,$Ctrl.Database.GetSlot("Expense"))
                })
            <#
                $Ctrl.Xaml.IO.ViewExpenseProperty          = 
                $Ctrl.Xaml.IO.ViewExpenseFilter            = 
                $Ctrl.Xaml.IO.ViewExpenseRefresh           = 
                $Ctrl.Xaml.IO.ViewExpenseOutput            = 
            #>
            }
            EditExpense
            {
            <#
                $Ctrl.Xaml.IO.EditExpenseDisplayName       = 
                $Ctrl.Xaml.IO.EditExpenseRecipient         = 
                $Ctrl.Xaml.IO.EditExpenseIsAccount         = 
                $Ctrl.Xaml.IO.EditExpenseAccountProperty   = 
                $Ctrl.Xaml.IO.EditExpenseAccountFilter     = 
                $Ctrl.Xaml.IO.EditExpenseAccountOutput     = 
                $Ctrl.Xaml.IO.EditExpenseAccountAdd        = 
                $Ctrl.Xaml.IO.EditExpenseAccountList       = 
                $Ctrl.Xaml.IO.EditExpenseAccountRemove     = 
                $Ctrl.Xaml.IO.EditExpenseCost              = 
            #>
            }
            ViewAccount
            {
                $Ctrl.Xaml.IO.ViewAccountFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewAccountProperty,
                                        $Ctrl.Xaml.IO.ViewAccountFilter,
                                        $Ctrl.Database.GetSlot("Account"),
                                        $Ctrl.Xaml.IO.ViewAccountOutput)
                })

                $Ctrl.Xaml.IO.ViewAccountRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountOutput,$Ctrl.Database.GetSlot("Account"))
                })
            <#
                $Ctrl.Xaml.IO.ViewAccountProperty          = 
                $Ctrl.Xaml.IO.ViewAccountFilter            = 
                $Ctrl.Xaml.IO.ViewAccountRefresh           = 
                $Ctrl.Xaml.IO.ViewAccountOutput            = 
            #>
            }
            EditAccount
            {
            <#
                $Ctrl.Xaml.IO.EditAccountObjectProperty    = 
                $Ctrl.Xaml.IO.EditAccountObjectFilter      = 
                $Ctrl.Xaml.IO.EditAccountObjectResult      = 
                $Ctrl.Xaml.IO.EditAccountObjectAdd         = 
                $Ctrl.Xaml.IO.EditAccountObjectList        = 
                $Ctrl.Xaml.IO.EditAccountObjectRemove      = 
            #>
            }
            ViewInvoice
            {
                $Ctrl.Xaml.IO.ViewInvoiceFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewInvoiceProperty,
                                        $Ctrl.Xaml.IO.ViewInvoiceFilter,
                                        $Ctrl.Database.GetSlot("Invoice"),
                                        $Ctrl.Xaml.IO.ViewInvoiceOutput)
                })

                $Ctrl.Xaml.IO.ViewInvoiceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceOutput,$Ctrl.Database.GetSlot("Invoice"))
                })
            <#
                $Ctrl.Xaml.IO.ViewInvoiceProperty          = 
                $Ctrl.Xaml.IO.ViewInvoiceFilter            = 
                $Ctrl.Xaml.IO.ViewInvoiceRefresh           = 
                $Ctrl.Xaml.IO.ViewInvoiceOutput            = 
            #>
            }
            EditInvoice
            {
            <#
                $Ctrl.Xaml.IO.EditInvoiceModeList          = 
                $Ctrl.Xaml.IO.EditInvoiceClientProperty    = 
                $Ctrl.Xaml.IO.EditInvoiceClientFilter      = 
                $Ctrl.Xaml.IO.EditInvoiceClientRefresh     = 
                $Ctrl.Xaml.IO.EditInvoiceClientOutput      = 
                $Ctrl.Xaml.IO.EditInvoiceClientAdd         = 
                $Ctrl.Xaml.IO.EditInvoiceClientList        = 
                $Ctrl.Xaml.IO.EditInvoiceClientRemove      = 
                $Ctrl.Xaml.IO.EditInvoiceIssueProperty     = 
                $Ctrl.Xaml.IO.EditInvoiceIssueFilter       = 
                $Ctrl.Xaml.IO.EditInvoiceIssueRefresh      = 
                $Ctrl.Xaml.IO.EditInvoiceIssueOutput       = 
                $Ctrl.Xaml.IO.EditInvoiceIssueAdd          = 
                $Ctrl.Xaml.IO.EditInvoiceIssueList         = 
                $Ctrl.Xaml.IO.EditInvoiceIssueRemove       = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseProperty  = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseFilter    = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseRefresh   = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseOutput    = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseAdd       = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseList      = 
                $Ctrl.Xaml.IO.EditInvoicePurchaseRemove    = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryProperty = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryFilter   = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryRefresh  = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryOutput   = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryAdd      = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryList     = 
                $Ctrl.Xaml.IO.EditInvoiceInventoryRemove   = 
                $Ctrl.Xaml.IO.EditInvoiceRecordList        = 
            #>
            }
        }
    }
    Handle([String]$Name)
    {
        $Ctrl = $This

        # [Sets current mode]
        $Ctrl.SetCurrentMode($Name)

        # [Set all panel to default value]
        ForEach ($Item in $Ctrl.Xaml.Types | ? Name -match "(View|Edit)\w+Panel$")
        {
            $Item.Control.Visibility = "Collapsed"
        }
        <#
        $Ctrl.Xaml.IO.ViewUidPanel.Visibility       = "Collapsed"
        $Ctrl.Xaml.IO.EditUidPanel.Visibility       = "Collapsed"
        $Ctrl.Xaml.IO.ViewClientPanel.Visibility    = "Collapsed"
        $Ctrl.Xaml.IO.EditClientPanel.Visibility    = "Collapsed"
        $Ctrl.Xaml.IO.ViewServicePanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.EditServicePanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.ViewDevicePanel.Visibility    = "Collapsed"
        $Ctrl.Xaml.IO.EditDevicePanel.Visibility    = "Collapsed"
        $Ctrl.Xaml.IO.ViewIssuePanel.Visibility     = "Collapsed"
        $Ctrl.Xaml.IO.EditIssuePanel.Visibility     = "Collapsed"
        $Ctrl.Xaml.IO.ViewPurchasePanel.Visibility  = "Collapsed"
        $Ctrl.Xaml.IO.EditPurchasePanel.Visibility  = "Collapsed"
        $Ctrl.Xaml.IO.ViewInventoryPanel.Visibility = "Collapsed"
        $Ctrl.Xaml.IO.EditInventoryPanel.Visibility = "Collapsed"
        $Ctrl.Xaml.IO.ViewExpensePanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.EditExpensePanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.ViewAccountPanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.EditAccountPanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.ViewInvoicePanel.Visibility   = "Collapsed"
        $Ctrl.Xaml.IO.EditInvoicePanel.Visibility   = "Collapsed"
        #>

        # [Set all side buttons to default style]
        ForEach ($Item in [System.Enum]::GetNames([ButtonPanelType]))
        {
            $Ctrl.Xaml.IO.$Item.Background          = "#DFFFBA"
            $Ctrl.Xaml.IO.$Item.Foreground          = "#000000"
            $Ctrl.Xaml.IO.$Item.BorderBrush         = "#000000"
        }

        # [Set current button to selected style]
        $Item                                       = "{0}Panel" -f ($Name -Replace "(View|Edit)","")
        $Ctrl.Xaml.IO.$Item.Background              = "#4444FF"
        $Ctrl.Xaml.IO.$Item.Foreground              = "#FFFFFF"
        $Ctrl.Xaml.IO.$Item.BorderBrush             = "#111111" 

        # [Set bottom buttons to default value]
        $Ctrl.Xaml.IO.View.IsEnabled                = 0
        $Ctrl.Xaml.IO.New.IsEnabled                 = 0
        $Ctrl.Xaml.IO.Edit.IsEnabled                = 0
        $Ctrl.Xaml.IO.Save.IsEnabled                = 0
        $Ctrl.Xaml.IO.Delete.IsEnabled              = 0

        # [Restores visibility on correct item, sets state on objects]
        Switch -Regex ($Name)
        {
            ViewUid
            {
                $Ctrl.Xaml.IO.ViewUidPanel.Visibility       = "Visible"
            }
            EditUid
            {
                $Ctrl.Xaml.IO.EditUidPanel.Visibility       = "Visible"
            }
            ViewClient
            {
                $Ctrl.Xaml.IO.ViewClientPanel.Visibility    = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditClient
            {
                $Ctrl.Xaml.IO.EditClientPanel.Visibility    = "Visible"
            }
            ViewService
            {
                $Ctrl.Xaml.IO.ViewServicePanel.Visibility   = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditService
            {
                $Ctrl.Xaml.IO.EditServicePanel.Visibility   = "Visible"
            }
            ViewDevice
            {
                $Ctrl.Xaml.IO.ViewDevicePanel.Visibility    = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditDevice
            {
                $Ctrl.Xaml.IO.EditDevicePanel.Visibility    = "Visible"
            }
            ViewIssue
            {
                $Ctrl.Xaml.IO.ViewIssuePanel.Visibility     = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditIssue
            {
                $Ctrl.Xaml.IO.EditIssuePanel.Visibility     = "Visible"
            }
            ViewPurchase
            {
                $Ctrl.Xaml.IO.ViewPurchasePanel.Visibility  = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditPurchase
            {
                $Ctrl.Xaml.IO.EditPurchasePanel.Visibility  = "Visible"
            }
            ViewInventory
            {
                $Ctrl.Xaml.IO.ViewInventoryPanel.Visibility = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditInventory
            {
                $Ctrl.Xaml.IO.EditInventoryPanel.Visibility = "Visible"
            }
            ViewExpense
            {
                $Ctrl.Xaml.IO.ViewExpensePanel.Visibility   = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditExpense
            {
                $Ctrl.Xaml.IO.EditExpensePanel.Visibility   = "Visible"
            }
            ViewAccount
            {
                $Ctrl.Xaml.IO.ViewAccountPanel.Visibility   = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditAccount
            {
                $Ctrl.Xaml.IO.EditAccountPanel.Visibility   = "Visible"
            }
            ViewInvoice
            {
                $Ctrl.Xaml.IO.ViewInvoicePanel.Visibility   = "Visible"
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditInvoice
            {
                $Ctrl.Xaml.IO.EditInvoicePanel.Visibility   = "Visible"
            }
        }
    }
    StageXaml()
    {
        $Ctrl = $This

        # [View Uid Panel]
        $Ctrl.Initial("ViewUid")
        $Ctrl.Stage("ViewUid")
        $Ctrl.Xaml.IO.UidPanel.Add_Click(
        {
            $Ctrl.Handle("ViewUid")
        })

        # [Edit Uid Panel]
        $Ctrl.Initial("EditUid")
        $Ctrl.Stage("EditUid")
    
        # [View Client Panel]
        $Ctrl.Initial("ViewClient")
        $Ctrl.Stage("ViewClient")
        $Ctrl.Xaml.IO.ClientPanel.Add_Click(
        {
            $Ctrl.Handle("ViewClient")
        })

        # [Edit Client Panel]
        $Ctrl.Initial("EditClient")
        $Ctrl.Stage("EditClient")
    
        # [View Service Panel]
        $Ctrl.Initial("ViewService")
        $Ctrl.Stage("ViewService")
        $Ctrl.Xaml.IO.ServicePanel.Add_Click(
        {
            $Ctrl.Handle("ViewService")
        })

        # [Edit Service Panel]
        $Ctrl.Initial("EditService")
        $Ctrl.Stage("EditService")

        # [View Device Panel]
        $Ctrl.Initial("ViewDevice")
        $Ctrl.Stage("ViewDevice")
        $Ctrl.Xaml.IO.DevicePanel.Add_Click(
        {
            $Ctrl.Handle("ViewDevice")
        })

        # [Edit Device Panel]
        $Ctrl.Initial("EditDevice")
        $Ctrl.Stage("EditDevice")
    
        # [View Issue Panel]
        $Ctrl.Initial("ViewIssue")
        $Ctrl.Stage("ViewIssue")
        $Ctrl.Xaml.IO.IssuePanel.Add_Click(
        {
            $Ctrl.Handle("ViewIssue")
        })

        # [Edit Issue Panel]
        $Ctrl.Initial("EditIssue")
        $Ctrl.Stage("EditIssue")
    
        # [View Purchase Panel]
        $Ctrl.Initial("ViewPurchase")
        $Ctrl.Stage("ViewPurchase")
        $Ctrl.Xaml.IO.PurchasePanel.Add_Click(
        {
            $Ctrl.Handle("ViewPurchase")
        })

        # [Edit Purchase Panel]
        $Ctrl.Initial("EditPurchase")
        $Ctrl.Stage("EditPurchase")
    
        # [View Inventory Panel]
        $Ctrl.Initial("ViewInventory")
        $Ctrl.Stage("ViewInventory")
        $Ctrl.Xaml.IO.InventoryPanel.Add_Click(
        {
            $Ctrl.Handle("ViewInventory")
        })

        # [Edit Inventory Panel]
        $Ctrl.Initial("EditInventory")
        $Ctrl.Stage("EditInventory")
    
        # [View Expense Panel]
        $Ctrl.Initial("ViewExpense")
        $Ctrl.Stage("ViewExpense")
        $Ctrl.Xaml.IO.ExpensePanel.Add_Click(
        {
            $Ctrl.Handle("ViewExpense")
        })

        # [Edit Expense Panel]
        $Ctrl.Initial("EditExpense")
        $Ctrl.Stage("EditExpense")

        # [View Account Panel]
        $Ctrl.Initial("ViewAccount")
        $Ctrl.Stage("ViewAccount")
        $Ctrl.Xaml.IO.AccountPanel.Add_Click(
        {
            $Ctrl.Handle("ViewAccount")
        })

        # [Edit Account Panel]
        $Ctrl.Initial("EditAccount")
        $Ctrl.Stage("EditAccount")
    
        # [View Invoice Panel]
        $Ctrl.Initial("ViewInvoice")
        $Ctrl.Stage("ViewInvoice")
        $Ctrl.Xaml.IO.InvoicePanel.Add_Click(
        {
            $Ctrl.Handle("ViewInvoice")
        })

        # [Edit Invoice Panel]
        $Ctrl.Initial("EditInvoice")
        $Ctrl.Stage("EditInvoice")

        # [Bottom panel buttons]
        $Ctrl.Xaml.IO.View.Add_Click(
        {
            $Ctrl.View()
        })

        $Ctrl.Xaml.IO.New.Add_Click(
        {
            $Ctrl.New()
        })

        $Ctrl.Xaml.IO.Edit.Add_Click(
        {
            $Ctrl.Edit()
        })

        $Ctrl.Xaml.IO.Save.Add_Click(
        {
            $Ctrl.Save()
        })

        $Ctrl.Xaml.IO.Delete.Add_Click(
        {
            $Ctrl.Delete()
        })
    }
    Invoke()
    {
        Try
        {
            $This.Xaml.Invoke()
        }
        Catch
        {
            $This.Module.Write(-1,"Exception [!] Either the user cancelled, or the dialog failed")
        }
    }
}

$Ctrl = [cimdbController]::New()
$Ctrl.Generate(100)
$Ctrl.StageXaml()
$Ctrl.Invoke()


<#
Class DatabaseClient
{
    [Object]           $Uid
    [UInt32]          $Rank
    [String]   $DisplayName
    [Object]          $Name
    [Object]           $Dob
    [String]        $Gender
    [Object]      $Location
    [Object]         $Image
    [Object]         $Phone
    [Object]         $Email
    [Object]        $Device
    [Object]         $Issue
    [Object]       $Invoice
    DatabaseClient([Object]$Uid)
    {
        $This.Uid    = $Uid
        $This.Clear() 
    }
    Clear()
    {
        $This.Phone   = $This.DatabaseItemList("Phone")
        $This.Email   = $This.DatabaseItemList("Email")
        $This.Device  = $This.DatabaseItemList("Device")
        $This.Issue   = $This.DatabaseItemList("Issue")
        $This.Invoice = $This.DatabaseItemList("Invoice")
    }
    [Object] DatabaseItemList([String]$Name)
    {
        Return [DatabaseItemList]::New($Name)
    }
    Apply([Object]$Template)
    {
        If ($Template.GetType().Name -ne "TemplateClient")
        {
            Throw "Invalid client template"
        }

        $This.Name        = $Template.Person
        $This.Dob         = $Template.Dob
        $This.Gender      = $Template.Gender
        $This.Location    = $Template.Location
        $This.Phone       = $Template.Phone
        $This.Email       = $Template.Email
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $ID               = $This.Name
        $Return           = $Null
        If ($ID.Initials -eq "" -and $ID.OtherName -eq "")
        {
            $Return       = "{0}, {1}" -f $This.Surname, $This.GivenName
        }

        ElseIf ($ID.Initials -eq "" -and $ID.OtherName -ne "")
        {
            $Return       = "{0} {1}, {2}" -f $ID.Surname, $ID.OtherName, $ID.GivenName
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -eq "")
        {
            $Return       = "{0} {1} {2}." -f $ID.Surname, $ID.GivenName, $ID.Initials
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -ne "")
        {
            $Return       = "{0} {1}, {2} {3}." -f  $ID.Surname, $ID.OtherName, $ID.GivenName, $ID.Initials
        }

        Return $Return
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseClient>"
    }
}

Class DatabasePerson
{
    [String] $DisplayName
    [String]   $GivenName
    [String]    $Initials
    [String]     $Surname
    [String]   $OtherName
    DatabasePerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.GivenName   = $GivenName
        $This.Initials    = $Initials
        $This.Surname     = $Surname
        $This.OtherName   = $OtherName
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $Return = $Null
        If ($This.Initials -eq "" -and $This.OtherName -eq "")
        {
            $Return = "{0} {1}" -f $This.GivenName, $This.Surname
        }

        ElseIf ($This.Initials -eq "" -and $This.OtherName -ne "")
        {
            $Return = "{0} {1} {2}" -f $This.GivenName, $This.Surname, $This.OtherName
        }

        ElseIf ($This.Initials -ne "" -and $This.Othername -eq "")
        {
            $Return = "{0} {1}. {2}" -f $This.GivenName, $This.Initials, $This.Surname
        }

        ElseIf ($This.Initials -ne "" -and $This.Othername -ne "")
        {
            $Return = "{0} {1}. {2} {3}" -f $This.GivenName, $This.Initials, $This.Surname, $This.OtherName
        }

        Return $Return
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

Class DatabaseDob
{
    [String]   $Dob
    [UInt32] $Month
    [UInt32]  $Date
    [UInt32]  $Year
    DatabaseDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        $This.Month = $Month
        $This.Date  = $Date
        $This.Year  = $Year
        $This.Dob   = "{0:d2}/{1:d2}/{2:d4}" -f $This.Month, $This.Date, $This.Year
    }
    [String] ToString()
    {
        Return $This.Dob
    }
}

Class DatabaseLocation
{
    [String] $StreetAddress
    [String]          $City
    [String]         $State
    [String]    $PostalCode
    [String]       $Country
    DatabaseLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        $This.StreetAddress = $StreetAddress
        $This.City          = $City
        $This.State         = $State
        $This.PostalCode    = $PostalCode
        $This.Country       = $Country
    }
    [String] ToString()
    {
        Return "{0}`n{1}, {2} {3}" -f $This.StreetAddress, $This.City, $This.State, $This.PostalCode
    }
}

Class DatabasePhone
{
    [UInt32]  $Index
    [String]   $Type
    [String] $Number
    DatabasePhone([UInt32]$Index,[String]$Type,[String]$Number)
    {
        $This.Index  = $Index
        $This.Type   = $Type
        $This.Number = $Number
    }
    [String] ToString()
    {
        Return $This.Number
    }
}

Class DatabaseEmail
{
    [UInt32] $Index
    [String]  $Type
    [String] $Email
    DatabaseEmail([UInt32]$Index,[String]$Type,[String]$Email)
    {
        $This.Index = $Index
        $This.Type  = $Type
        $This.Email = $Email
    }
    [String] ToString()
    {
        Return $This.Email
    }
}

Class TemplateClient
{
    [Object]   $Person
    [Object]      $Dob
    [String]   $Gender
    [Object] $Location
    [Object]    $Phone
    [Object]    $Email
    TemplateClient()
    {
        $This.Phone = $This.DatabaseItemList("Phone")
        $This.Email = $This.DatabaseItemList("Email")
    }
    [Object] DatabasePerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        Return [DatabasePerson]::New($GivenName,$Initials,$Surname,$OtherName)
    }
    [Object] DatabaseDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        Return [DatabaseDob]::New($Month,$Date,$Year)
    }
    [Object] DatabaseLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        Return [DatabaseLocation]::New($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    [Object] DatabaseItemList([String]$Name)
    {
        Return [DatabaseItemList]::New($Name)
    }
    [Object] DatabasePhone([UInt32]$Index,[String]$Type,[String]$Number)
    {
        Return [DatabasePhone]::New($Index,$Type,$Number)
    }
    [Object] DatabaseEmail([UInt32]$Index,[String]$Type,[String]$Email)
    {
        Return [DatabaseEmail]::New($Index,$Type,$Email)
    }
    [UInt32] Status()
    {
        $C = 0
        If (!!$This.Person)
        {
            $C ++
        }

        If (!!$This.Dob)
        {
            $C ++
        }

        If (!!$This.Gender)
        {
            $C ++
        }

        If (!!$This.Location)
        {
            $C ++
        }
        
        If ($This.Phone.Count -gt 0)
        {
            $C ++
        }

        If ($This.Email.Count -gt 0)
        {
            $C ++
        }

        Return [UInt32]($C -eq 6)
    }
    SetPerson([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.Person   = $This.DatabasePerson($GivenName,$Initials,$Surname,$OtherName)
    }
    SetDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        If ($Date -gt [DateTime]::DaysInMonth($Year,$Month))
        {
            Throw "Invalid date"
        }

        $This.Dob      = $This.DatabaseDob($Month,$Date,$Year)
    }
    SetGender([UInt32]$Slot)
    {
        $This.Gender   = @("Male","Female")[$Slot]
    }
    SetLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        $This.Location = $This.DatabaseLocation($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    AddPhone([String]$Type,[String]$Number)
    {
        If ($Number -in $This.Phone.Output.Number)
        {
            Throw "Number already exists"
        }

        $This.Phone.Add($This.DatabasePhone($This.Phone.Count,$Type,$Number))
    }
    AddEmail([String]$Type,[String]$Email)
    {
        If ($Email -in $This.Email.Output.Email)
        {
            Throw "Number already exists"
        }

        $This.Email.Add($This.DatabaseEmail($This.Email.Count,$Type,$Email))
    }
}

Class DatabaseClient2
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # Numerical index in all client objects
    [String]   $DisplayName # Certain formula for displaying the unique content of the object
    [Object]          $Name # Object -> (DisplayName, GivenName, Initials, Surname, OtherName)
    [Object]           $Dob # Object -> (Dob , Month , Date , Year)
    [String]        $Gender # Might make this an object, not sure.
    [Object]      $Location # Object -> (StreetAddress, City, State, PostalCode, Country)
    [Object]         $Image # Bitmap/Jpg/Graphic
    [Object]         $Phone # Object -> List of phone numbers, with name, type, etc. (requires at least 1) 
    [Object]         $Email # Object -> List of Email addresses, name, type, etc.    (requires at least 1)
    [Object]        $Device # Object -> List of devices, may be empty                (no requirements)
    [Object]         $Issue # Object -> List of issues, may be empty                 (no requirements)
    [Object]       $Invoice # Object -> List of invoices, may be empty               (no requirements)
    DatabaseClient([Object]$Uid)
    {
        $This.Uid    = $Uid.Uid
        $This.Clear() 
    }
    Clear()
    {
        $This.Phone   = $This.DatabaseItemList("Phone")
        $This.Email   = $This.DatabaseItemList("Email")
        $This.Device  = $This.DatabaseItemList("Device")
        $This.Issue   = $This.DatabaseItemList("Issue")
        $This.Invoice = $This.DatabaseItemList("Invoice")
    }
    [Object] DatabaseItemList([String]$Name)
    {
        Return [DatabaseItemList]::New($Name)
    }
    Apply([Object]$Template)
    {
        If ($Template.GetType().Name -ne "TemplateClient")
        {
            Throw "Invalid client template"
        }

        $This.Name        = $Template.Person
        $This.Dob         = $Template.Dob
        $This.Gender      = $Template.Gender
        $This.Location    = $Template.Location
        $This.Phone       = $Template.Phone
        $This.Email       = $Template.Email
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $ID               = $This.Name
        $Return           = $Null
        If ($ID.Initials -eq "" -and $ID.OtherName -eq "")
        {
            $Return       = "{0}, {1}" -f $This.Surname, $This.GivenName
        }

        ElseIf ($ID.Initials -eq "" -and $ID.OtherName -ne "")
        {
            $Return       = "{0} {1}, {2}" -f $ID.Surname, $ID.OtherName, $ID.GivenName
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -eq "")
        {
            $Return       = "{0} {1} {2}." -f $ID.Surname, $ID.GivenName, $ID.Initials
        }

        ElseIf ($ID.Initials -ne "" -and $ID.Othername -ne "")
        {
            $Return       = "{0} {1}, {2} {3}." -f  $ID.Surname, $ID.OtherName, $ID.GivenName, $ID.Initials
        }

        Return $Return
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseClient>"
    }
}

Class TemplateService
{
    [String]        $Name
    [String] $Description
    [Float]         $Cost
    TemplateService()
    {

    }
}

Class DatabaseService
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # Numerical index in all client objects
    [String]   $DisplayName # Certain formula for displaying the unique content of the object
    [String]          $Name # Service name
    [String]   $Description # Description
    [Float]           $Cost # How much the service costs
    DatabaseService([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseService>"
    }
}

Class DatabaseDevice
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [String]   $DisplayName # 
    [String]       $Chassis # 
    [String]        $Vendor # 
    [String]         $Model # 
    [String] $Specification # 
    [String]        $Serial # 
    [String]        $Client # Uid/reference to the client object
    DatabaseDevice([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseDevice>"
    }
}

Class DatabaseIssue
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [Object]   $DisplayName # 
    [Object]        $Status # 
    [String]   $Description # 
    [String]        $Client # Uid/reference to the client object
    [String]        $Device # Uid/reference to the client object
    [Object]       $Service # Object -> List of services,  may be empty               (no requirements)
    [Object]          $List # Object -> List of purchases, may be empty               (no requirements)
    DatabaseIssue([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseIssue>"
    }
}

Class DatabasePurchase
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank # 
    [Object]   $DisplayName # 
    [Object]   $Distributor # 
    [Object]           $URL # 
    [String]        $Vendor # 
    [String]         $Model # 
    [String] $Specification # 
    [String]        $Serial # 
    [Bool]        $IsDevice # 
    [String]        $Device # 
    [Object]          $Cost # 
    DatabasePurchase([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabasePurchase>"
    }
}

Class DatabaseInventory
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [String]        $Vendor #
    [String]         $Model #
    [String]        $Serial #
    [Object]         $Title #
    [Object]          $Cost #
    [Bool]        $IsDevice #
    [Object]        $Device #
    DatabaseInventory([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseInventory>"
    }
}

Class DatabaseExpense
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [Object]   $DisplayName #
    [Object]     $Recipient #
    [Object]     $IsAccount #
    [Object]       $Account #
    [Object]          $Cost #
    DatabaseExpense([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseExpense>"
    }
}

Class DatabaseAccount
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [Object]        $Object #
    DatabaseAccount([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseAccount>"
    }
}

Class DatabaseInvoice
{
    [Object]           $Uid # (Uid, Type, Index, Date, Time, Sort, Record will be this object)
    [UInt32]          $Rank #
    [String]   $DisplayName #
    [UInt32]          $Mode #
    [Object]        $Client #
    [Object]         $Issue #
    [Object]      $Purchase #
    [Object]     $Inventory #
    DatabaseInvoice([Object]$Uid)
    {
        $This.Uid = $Uid
    }
    [String] ToString()
    {
        Return "<FEModule.DatabaseInvoice>"
    }
}

Class DatabaseUid
{
    [Object]    $Uid
    [Object]   $Type
    [UInt32]  $Index
    [Object]   $Date
    [Object]   $Time
    [UInt32]   $Sort
    [UInt32]   $Rank
    [Object] $Record
    DatabaseUid([Object]$Slot,[UInt32]$Index)
    {
        $This.Uid    = $This.NewGuid()
        $This.Type   = $Slot
        $This.Index  = $Index
        $This.Date   = $This.GetDate()
        $This.Time   = $This.GetTime()
        $This.Sort   = 0
    }
    [Object] GetDate()
    {
        Return [DateTime]::Now.ToString("MM/d/yyyy")
    }
    [Object] GetTime()
    {
        Return [DateTime]::Now.ToString("HH:mm:ss")
    }
    [Object] NewGuid()
    {
        Return [Guid]::NewGuid()
    }
    [String] ToString()
    {
        Return $This.Uid
    }
}

# [Start development controller]

Class DevelController
{
    [Object]   $List
    [Object] $Output
    DevelController()
    {
        $This.List = $This.DatabaseList()
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @()
    }
    [Object] DatabaseList()
    {
        Return DatabaseList
    }
    [Object] Uid([UInt32]$Slot,[UInt32]$Index)
    {
        If ($Slot -notin $This.List.Index)
        {
            Throw "Invalid slot"
        }

        Return [DatabaseUid]::New($This.List[$Slot],$Index)
    }
    [Object] DatabaseClient([Object]$Uid)
    {
        Return [DatabaseClient]::New($Uid)
    }
    [Object] TemplateClient()
    {
        Return [TemplateClient]::New()
    }
    [Object] DatabaseService([Object]$Uid)
    {
        Return [DatabaseService]::New($Uid)
    }
    [Object] DatabaseDevice([Object]$Uid)
    {
        Return [DatabaseDevice]::New($Uid)
    }
    [Object] DatabaseIssue([Object]$Uid)
    {
        Return [DatabaseIssue]::New($Uid)
    }
    [Object] DatabasePurchase([Object]$Uid)
    {
        Return [DatabasePurchase]::New($Uid)
    }
    [Object] DatabaseInventory([Object]$Uid)
    {
        Return [DatabaseInventory]::New($Uid)
    }
    [Object] DatabaseExpense([Object]$Uid)
    {
        Return [DatabaseExpense]::New($Uid)
    }
    [Object] DatabaseAccount([Object]$Uid)
    {
        Return [DatabaseAccount]::New($Uid)
    }
    [Object] DatabaseInvoice([Object]$Uid)
    {
        Return [DatabaseInvoice]::New($Uid)
    }
    [Object] GetUid([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        Return $This.Output[$Index]
    }
    [Object] GetUid([String]$Uid)
    {
        If ($Uid -notin $This.Output.Uid)
        {
            Throw "Invalid UID"
        }

        Return $This.Output | ? Uid -eq $Uid
    }
    [UInt32] GetCount([String]$Type)
    {
        Return ($This.Output | ? Type -match $Type).Count
    }
    NewUid([UInt32]$Slot)
    {
        If ($Slot -gt $This.List.Count)
        {
            Throw "Invalid slot"
        }

        $Item         = $This.Uid($Slot,$This.Count)
        $This.Output += $Item
        $This.Count   = $This.Output.Count
    }
    New([Object]$Uid)
    {
        $Slot         = $Uid.Type
        $Uid.Record   = $This.$Slot($Uid)
    }
    NewClient([Object]$Client)
    {
        If ($Client.Status() -ne 1)
        {
            Throw "Client template status not complete"
        }

        $Count        = $This.GetCount("Client")
        $Uid          = $This.Uid(0,$Count)
        $Uid.Record   = $This.DatabaseClient($Uid)
        $Uid.Record.Apply($Client)

        $This.Output += $Uid
    }
    NewService([Object]$Uid)
    {

    }
    NewDevice([Object]$Uid)
    {

    }
    NewIssue([Object]$Uid)
    {

    }
    NewPurchase([Object]$Uid)
    {

    }
    NewInventory([Object]$Uid)
    {

    }
    NewExpense([Object]$Uid)
    {

    }
    NewAccount([Object]$Uid)
    {

    }
    NewInvoice([Object]$Uid)
    {

    }
}

    $Ctrl     = [DevelController]::New()
    $Template = $Ctrl.TemplateClient()
    $Template.SetPerson("Michael","C","Cook","Sr.")
    $Template.SetDob(5,24,1985)
    $Template.SetGender(0)
    $Template.SetLocation("201D Halfmoon Circle","Clifton Park","NY",12065,"US")
    $Template.AddPhone("Home","518-406-8569")
    $Template.AddEmail("Personal","michael.c.cook.85@gmail.com")
    $Ctrl.NewClient($Template)

#>
