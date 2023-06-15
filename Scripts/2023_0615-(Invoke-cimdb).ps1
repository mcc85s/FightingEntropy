<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-06-15 17:48:01                                                                  //
 \\==================================================================================================// 

    FileName   : Invoke-cimdb.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Launches the [FightingEntropy(p)] Company Inventory Management Database
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-06-15
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Implement the newer version of the classes and GUI

.Example
#>

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Xaml [+]                                                                                       ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

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
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[UID]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Scope out records by their UID&gt;"',
    '                                 IsReadOnly="True"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="2" Name="EditUidOutput">',
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
    '                    <Grid Grid.Row="3">',
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
    '                    <DataGrid Grid.Row="4"',
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
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Client Panel -->',
    '                <Grid Name="EditClientPanel" Visibility="Visible">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Client]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new client, or edit an existing client in the database&gt;"',
    '                                 IsReadOnly="True"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditClientOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditClientType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditClientStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="45"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="65"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Name]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientGivenName"',
    '                                 Text="&lt;First&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditClientInitials"',
    '                                 Text="&lt;Mi&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientSurname"',
    '                                 Text="&lt;Last&gt;"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientOtherName"',
    '                                 Text="&lt;Other&gt;"/>',
    '                        <Image Grid.Column="5"',
    '                               Name="EditClientNameIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="225"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Location]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientStreetAddress"',
    '                                 Text="&lt;Address&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                                <TextBox Grid.Column="1"',
    '                                 Name="EditClientCity"',
    '                                 Text="&lt;City&gt;"/>',
    '                                <TextBox Grid.Column="2"',
    '                                 Name="EditClientRegion"',
    '                                 Text="&lt;State&gt;"/>',
    '                                <TextBox Grid.Column="3"',
    '                                 Name="EditClientPostalCode"',
    '                                 Text="&lt;Postal&gt;"/>',
    '                                <TextBox Grid.Column="4"',
    '                                 Name="EditClientCountry"',
    '                                 Text="&lt;Country&gt;"/>',
    '                                <Image Grid.Column="6"',
    '                               Name="EditClientLocationIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="7">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
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
    '                            <ComboBoxItem Content="Unspecified"/>',
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
    '                    <Grid Grid.Row="8">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
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
    '                                 Name="EditClientPhoneText"',
    '                                 Text="&lt;Enter phone number&gt;"/>',
    '                        <Image Grid.Column="2"',
    '                               Name="EditClientPhoneIcon"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="EditClientPhoneAdd"',
    '                                Content="+"/>',
    '                        <ComboBox Grid.Column="4"',
    '                                  Name="EditClientPhoneList"/>',
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
    '                    <Grid Grid.Row="9">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Email]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientEmailText"',
    '                                 Text="&lt;Enter email address&gt;"/>',
    '                        <Image Grid.Column="2"',
    '                               Name="EditClientEmailIcon"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="EditClientEmailAdd"',
    '                                Content="+"/>',
    '                        <ComboBox Grid.Column="4"',
    '                                  Name="EditClientEmailList"/>',
    '                        <Button Grid.Column="5"',
    '                                Name="EditClientEmailRemove"',
    '                                Content="-"/>',
    '                        <Button Grid.Column="6"',
    '                                Name="EditClientEmailMoveUp">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\up.png"/>',
    '                        </Button>',
    '                        <Button Grid.Column="7"',
    '                                Name="EditClientEmailMoveDown">',
    '                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\down.png"/>',
    '                        </Button>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="10">',
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
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientDeviceProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Type"/>',
    '                                        <ComboBoxItem Content="Status"/>',
    '                                        <ComboBoxItem Content="Vendor"/>',
    '                                        <ComboBoxItem Content="Model"/>',
    '                                        <ComboBoxItem Content="Specification"/>',
    '                                        <ComboBoxItem Content="Serial"/>',
    '                                        <ComboBoxItem Content="Client"/>',
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
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Desktop"/>',
    '                                                        <ComboBoxItem Content="Laptop"/>',
    '                                                        <ComboBoxItem Content="Smartphone"/>',
    '                                                        <ComboBoxItem Content="Tablet"/>',
    '                                                        <ComboBoxItem Content="Console"/>',
    '                                                        <ComboBoxItem Content="Server"/>',
    '                                                        <ComboBoxItem Content="Network"/>',
    '                                                        <ComboBoxItem Content="Other"/>',
    '                                                        <ComboBoxItem Content="Unspecified"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
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
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientIssueProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Type"/>',
    '                                        <ComboBoxItem Content="Status"/>',
    '                                        <ComboBoxItem Content="Description"/>',
    '                                        <ComboBoxItem Content="Client"/>',
    '                                        <ComboBoxItem Content="Device"/>',
    '                                        <ComboBoxItem Content="Service"/>',
    '                                        <ComboBoxItem Content="Invoice"/>',
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
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Status"',
    '                                                    Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Status.Index}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="New"/>',
    '                                                        <ComboBoxItem Content="Diagnosed"/>',
    '                                                        <ComboBoxItem Content="Commit"/>',
    '                                                        <ComboBoxItem Content="Complete"/>',
    '                                                        <ComboBoxItem Content="NoGo"/>',
    '                                                        <ComboBoxItem Content="Fail"/>',
    '                                                        <ComboBoxItem Content="Transfer"/>',
    '                                                        <ComboBoxItem Content="Unspecified"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
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
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientInvoiceProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Type"/>',
    '                                        <ComboBoxItem Content="Status"/>',
    '                                        <ComboBoxItem Content="Client"/>',
    '                                        <ComboBoxItem Content="Issue"/>',
    '                                        <ComboBoxItem Content="Purchase"/>',
    '                                        <ComboBoxItem Content="Inventory"/>',
    '                                        <ComboBoxItem Content="Cost"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientInvoiceFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditClientInvoiceRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditClientInvoiceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Client"',
    '                                                Binding="{Binding Record.Name}"',
    '                                                Width="250"/>',
    '                                        <DataGridTemplateColumn Header="Status"',
    '                                                    Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Paid"/>',
    '                                                        <ComboBoxItem Content="Unpaid"/>',
    '                                                        <ComboBoxItem Content="Unspecified"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="100"/>',
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
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Service Panel -->',
    '                <Grid Name="EditServicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Service]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new service, or edit an existing service in the database&gt;"',
    '                                 IsReadOnly="True"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditServiceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditServiceType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditServiceStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Name]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditServiceName"',
    '                                 Text="&lt;Enter a name for the service&gt;"/>',
    '                        <Image Grid.Column="2"',
    '                               Name="EditServiceNameIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Description]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditServiceDescription"',
    '                                 Text="&lt;Enter description of the service&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditServiceCost"',
    '                                 Text="&lt;Enter cost&gt;"/>',
    '                    </Grid>',
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
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
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
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Device Panel -->',
    '                <Grid Name="EditDevicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Device]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new device, or edit an existing device in the database&gt;"',
    '                                 IsReadOnly="True"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditDeviceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
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
    '                                            <ComboBoxItem Content="Unspecified"/>',
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
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditDeviceType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditDeviceStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Specs]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditDeviceVendor"',
    '                                 Text="&lt;Vendor&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditDeviceModel"',
    '                                 Text="&lt;Model&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditDeviceSpecification"',
    '                                 Text="&lt;Specification&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Serial]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditDeviceSerial"',
    '                                 Text="&lt;Enter device serial number&gt;"/>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="6">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditDeviceClientProperty"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditDeviceClientFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditDeviceClientRefresh"',
    '                                            Content="Refresh"/>',
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
    '                                                Width="*"/>',
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
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Issue Panel -->',
    '                <Grid Name="EditIssuePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="220"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Issue]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new issue, or edit an existing issue in the database&gt;"',
    '                                 IsReadOnly="True"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditIssueOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
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
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                               Name="EditIssueType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditIssueStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Description]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditIssueDescription"',
    '                                 Text="&lt;Enter description of issue&gt;"/>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="5">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0" Margin="5">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueClientProperty"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditIssueClientFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditIssueClientRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueClientOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
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
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueDeviceProperty"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditIssueDeviceFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditIssueDeviceRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueDeviceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Desktop"/>',
    '                                                        <ComboBoxItem Content="Laptop"/>',
    '                                                        <ComboBoxItem Content="Smartphone"/>',
    '                                                        <ComboBoxItem Content="Tablet"/>',
    '                                                        <ComboBoxItem Content="Console"/>',
    '                                                        <ComboBoxItem Content="Server"/>',
    '                                                        <ComboBoxItem Content="Network"/>',
    '                                                        <ComboBoxItem Content="Other"/>',
    '                                                        <ComboBoxItem Content="Unspecified"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
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
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditIssueServiceProperty"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditIssueServiceFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditIssueServiceRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditIssueServiceOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
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
    '                        <TabItem Header="Purchase"/>',
    '                        <TabItem Header="Inventory"/>',
    '                    </TabControl>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="7" Name="EditIssueRecordList">',
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
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Distributor"',
    '                                                Binding="{Binding Record.Distributor}"',
    '                                                Width="150"/>',
    '                            <DataGridTemplateColumn Header="Status" Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Status.Index}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Deposit"/>',
    '                                            <ComboBoxItem Content="Paid"/>',
    '                                            <ComboBoxItem Content="Ordered"/>',
    '                                            <ComboBoxItem Content="Delivered"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Purchase Panel -->',
    '                <Grid Name="EditPurchasePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Purchase]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new purchase, or edit an existing purchase in the database&gt;"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditPurchaseOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Distributor"',
    '                                                Binding="{Binding Record.Distributor}"',
    '                                                Width="150"/>',
    '                            <DataGridTemplateColumn Header="Status" Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Status.Index}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Deposit"/>',
    '                                            <ComboBoxItem Content="Paid"/>',
    '                                            <ComboBoxItem Content="Ordered"/>',
    '                                            <ComboBoxItem Content="Delivered"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditPurchaseType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditPurchaseStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Distributor]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditPurchaseDistributor"',
    '                                 Text="&lt;Enter distributor&gt;"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditPurchaseCost"',
    '                                 Text="&lt;Cost&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[URL]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditPurchaseURL"',
    '                                 Text="&lt;Enter purchase URL&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Specs]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditPurchaseVendor"',
    '                                 Text="&lt;Vendor&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditPurchaseModel"',
    '                                 Text="&lt;Model&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditPurchaseSpecification"',
    '                                 Text="&lt;Specification&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="7">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Device]:"',
    '                               Style="{StaticResource LabelRed}"/>',
    '                        <CheckBox Grid.Column="1"',
    '                                  Name="EditPurchaseIsDevice"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditPurchaseSerial"',
    '                                 Text="&lt;Enter device serial number&gt;"/>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="8" Header="[Device]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="90"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Search]:"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditPurchaseDeviceProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditPurchaseDeviceFilter"/>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditPurchaseDeviceRefresh"',
    '                                        Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1"',
    '                                      Name="EditPurchaseDeviceOutput">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                    <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                    <ComboBoxItem Content="Desktop"/>',
    '                                                    <ComboBoxItem Content="Laptop"/>',
    '                                                    <ComboBoxItem Content="Smartphone"/>',
    '                                                    <ComboBoxItem Content="Tablet"/>',
    '                                                    <ComboBoxItem Content="Console"/>',
    '                                                    <ComboBoxItem Content="Server"/>',
    '                                                    <ComboBoxItem Content="Network"/>',
    '                                                    <ComboBoxItem Content="Other"/>',
    '                                                    <ComboBoxItem Content="-"/>',
    '                                                </ComboBox>',
    '                                            </DataTemplate>',
    '                                        </DataGridTemplateColumn.CellTemplate>',
    '                                    </DataGridTemplateColumn>',
    '                                    <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                                    <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Button Grid.Column="0"',
    '                                        Name="EditPurchaseDeviceAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditPurchaseDeviceList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="2"',
    '                                        Name="EditPurchaseDeviceRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
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
    '                            <ComboBoxItem Content="DisplayName"/>',
    '                            <ComboBoxItem Content="Vendor"/>',
    '                            <ComboBoxItem Content="Model"/>',
    '                            <ComboBoxItem Content="Specification"/>',
    '                            <ComboBoxItem Content="Serial"/>',
    '                            <ComboBoxItem Content="Cost"/>',
    '                            <ComboBoxItem Content="Device"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ViewInventoryFilter"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ViewInventoryRefresh"',
    '                                Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="ViewInventoryOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Device" Width="45">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <CheckBox IsChecked="{Binding Scope}"',
    '                                                          Margin="0"',
    '                                                          HorizontalAlignment="Center">',
    '                                            <CheckBox.LayoutTransform>',
    '                                                <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
    '                                            </CheckBox.LayoutTransform>',
    '                                        </CheckBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Specification"',
    '                                                Binding="{Binding Record.Specification}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="50"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Inventory Panel -->',
    '                <Grid Name="EditInventoryPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Inventory]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register new inventory, or edit existing inventory in the database&gt;"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditInventoryOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Device" Width="45">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <CheckBox IsChecked="{Binding Record.IsDevice}"',
    '                                                  Margin="0"',
    '                                                  HorizontalAlignment="Center">',
    '                                            <CheckBox.LayoutTransform>',
    '                                                <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
    '                                            </CheckBox.LayoutTransform>',
    '                                        </CheckBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Specification"',
    '                                                Binding="{Binding Record.Specification}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="50"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditInventoryType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditInventoryStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Specs]"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditInventoryVendor"',
    '                                 Text="&lt;Vendor&gt;"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditInventoryModel"',
    '                                 Text="&lt;Model&gt;"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditInventorySpecification"',
    '                                 Text="&lt;Specification&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Device]:"',
    '                               Style="{StaticResource LabelRed}"/>',
    '                        <CheckBox Grid.Column="1"',
    '                                  Name="EditInventoryIsDevice"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditInventorySerial"',
    '                                 Text="&lt;Enter device serial number&gt;"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditInventoryCost"',
    '                                 Text="&lt;Cost&gt;"/>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="7" Header="[Device]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="90"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Search]:"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditInventoryDeviceProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditInventoryDeviceFilter"/>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditInventoryDeviceRefresh"',
    '                                        Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1"',
    '                                      Name="EditInventoryDeviceOutput">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                    <DataGridTemplateColumn Header="Chassis"',
    '                                                    Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                    <ComboBoxItem Content="Desktop"/>',
    '                                                    <ComboBoxItem Content="Laptop"/>',
    '                                                    <ComboBoxItem Content="Smartphone"/>',
    '                                                    <ComboBoxItem Content="Tablet"/>',
    '                                                    <ComboBoxItem Content="Console"/>',
    '                                                    <ComboBoxItem Content="Server"/>',
    '                                                    <ComboBoxItem Content="Network"/>',
    '                                                    <ComboBoxItem Content="Other"/>',
    '                                                    <ComboBoxItem Content="Unspecified"/>',
    '                                                </ComboBox>',
    '                                            </DataTemplate>',
    '                                        </DataGridTemplateColumn.CellTemplate>',
    '                                    </DataGridTemplateColumn>',
    '                                    <DataGridTextColumn Header="Vendor"',
    '                                                Binding="{Binding Record.Vendor}"',
    '                                                Width="150"/>',
    '                                    <DataGridTextColumn Header="Model"',
    '                                                Binding="{Binding Record.Model}"',
    '                                                Width="150"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Button Grid.Column="0"',
    '                                        Name="EditInventoryDeviceAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditInventoryDeviceList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="2"',
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
    '                              Name="ViewExpenseOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Internal"/>',
    '                                            <ComboBoxItem Content="Payout"/>',
    '                                            <ComboBoxItem Content="Residual"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Recipient"',
    '                                                Binding="{Binding Record.Recipient}"',
    '                                                Width="200"/>',
    '                            <DataGridTemplateColumn Header="Account" Width="50">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <CheckBox IsChecked="{Binding Record.IsAccount}"',
    '                                                  Margin="0"',
    '                                                  HorizontalAlignment="Center">',
    '                                            <CheckBox.LayoutTransform>',
    '                                                <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
    '                                            </CheckBox.LayoutTransform>',
    '                                        </CheckBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Expense Panel -->',
    '                <Grid Name="EditExpensePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Expense]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new expense, or edit an existing expense in the database&gt;"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditExpenseOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Chassis}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Internal"/>',
    '                                            <ComboBoxItem Content="Payout"/>',
    '                                            <ComboBoxItem Content="Residual"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Recipient"',
    '                                                Binding="{Binding Record.Recipient}"',
    '                                                Width="200"/>',
    '                            <DataGridTemplateColumn Header="Account" Width="50">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <CheckBox IsChecked="{Binding Record.IsAccount}"',
    '                                                  Margin="0"',
    '                                                  HorizontalAlignment="Center">',
    '                                            <CheckBox.LayoutTransform>',
    '                                                <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
    '                                            </CheckBox.LayoutTransform>',
    '                                        </CheckBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="80"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditExpenseType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditExpenseStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Recipient]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditExpenseRecipient"',
    '                                 Text="&lt;Enter recipient&gt;"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditExpenseCost"',
    '                                 Text="&lt;Cost&gt;"/>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="5" Header="[Account]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="90"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Search]:"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditExpenseAccountProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditExpenseAccountFilter"/>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditExpenseAccountRefresh"',
    '                                        Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1"',
    '                                  Name="EditExpenseAccountOutput">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                    <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                    <ComboBoxItem Content="Bank"/>',
    '                                                    <ComboBoxItem Content="Creditor"/>',
    '                                                    <ComboBoxItem Content="Business"/>',
    '                                                    <ComboBoxItem Content="Supplier"/>',
    '                                                    <ComboBoxItem Content="Partner"/>',
    '                                                    <ComboBoxItem Content="Unspecified"/>',
    '                                                </ComboBox>',
    '                                            </DataTemplate>',
    '                                        </DataGridTemplateColumn.CellTemplate>',
    '                                    </DataGridTemplateColumn>',
    '                                    <DataGridTextColumn Header="Organization"',
    '                                                Binding="{Binding Record.Object}"',
    '                                                Width="200"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Button Grid.Column="0"',
    '                                        Name="EditExpenseAccountAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditExpenseAccountList">',
    '                                    <ComboBox.ItemTemplate>',
    '                                        <DataTemplate>',
    '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
    '                                        </DataTemplate>',
    '                                    </ComboBox.ItemTemplate>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="2"',
    '                                        Name="EditExpenseAccountRemove"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
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
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Bank"/>',
    '                                            <ComboBoxItem Content="Creditor"/>',
    '                                            <ComboBoxItem Content="Business"/>',
    '                                            <ComboBoxItem Content="Supplier"/>',
    '                                            <ComboBoxItem Content="Partner"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Organization"',
    '                                                Binding="{Binding Record.Object}"',
    '                                                Width="200"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Account Panel -->',
    '                <Grid Name="EditAccountPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Account]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new account, or edit an existing account in the database&gt;"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditAccountOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Bank"/>',
    '                                            <ComboBoxItem Content="Creditor"/>',
    '                                            <ComboBoxItem Content="Business"/>',
    '                                            <ComboBoxItem Content="Supplier"/>',
    '                                            <ComboBoxItem Content="Partner"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Organization"',
    '                                                Binding="{Binding Record.Object}"',
    '                                                Width="200"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditAccountType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditAccountStatus"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Org.]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditAccountOrganization"',
    '                                 Text="&lt;Enter Organization&gt;"/>',
    '                    </Grid>',
    '                    <GroupBox Grid.Row="5" Header="[Object]">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="90"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Search]:"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditAccountObjectProperty"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditAccountObjectFilter"/>',
    '                                <Button Grid.Column="3"',
    '                                        Name="EditAccountObjectRefresh"',
    '                                        Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1" Name="EditAccountObjectResult">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="100"/>',
    '                                    <DataGridTemplateColumn Header="Value" Width="*">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox ItemsSource="{Binding Value}"',
    '                                                          Style="{StaticResource DGCombo}"/>',
    '                                            </DataTemplate>',
    '                                        </DataGridTemplateColumn.CellTemplate>',
    '                                    </DataGridTemplateColumn>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Button Grid.Column="0"',
    '                                        Name="EditAccountObjectAdd"',
    '                                        Content="+"/>',
    '                                <ComboBox Grid.Column="1"',
    '                                          Name="EditAccountObjectList"/>',
    '                                <Button Grid.Column="2"',
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
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Client"',
    '                                                Binding="{Binding Record.Name}"',
    '                                                Width="250"/>',
    '                            <DataGridTemplateColumn Header="Status"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Paid"/>',
    '                                            <ComboBoxItem Content="Unpaid"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Cost"',
    '                                                Binding="{Binding Record.Cost}"',
    '                                                Width="100"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Invoice Panel -->',
    '                <Grid Name="EditInvoicePanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="180"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Invoice]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Text="&lt;Register a new invoice, or edit an existing invoice in the database&gt;"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1" Background="Black" Margin="4"/>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="EditInvoiceOutput">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                            <DataGridTextColumn Header="Client"',
    '                                                Binding="{Binding Record.Name}"',
    '                                                Width="250"/>',
    '                            <DataGridTemplateColumn Header="Status"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                            <ComboBoxItem Content="Paid"/>',
    '                                            <ComboBoxItem Content="Unpaid"/>',
    '                                            <ComboBoxItem Content="Unspecified"/>',
    '                                        </ComboBox>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Type]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditInvoiceType"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Status]:"/>',
    '                        <ComboBox Grid.Column="3"',
    '                                  Name="EditInvoiceStatus"/>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="4">',
    '                        <TabItem Header="Client">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                            Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditInvoiceClientProperty">',
    '                                        <ComboBoxItem Content="Uid"/>',
    '                                        <ComboBoxItem Content="Index"/>',
    '                                        <ComboBoxItem Content="Date"/>',
    '                                        <ComboBoxItem Content="Rank"/>',
    '                                        <ComboBoxItem Content="DisplayName"/>',
    '                                        <ComboBoxItem Content="Email"/>',
    '                                        <ComboBoxItem Content="Phone"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditInvoiceClientFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditInvoiceClientRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoiceClientOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
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
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                            Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
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
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditInvoiceIssueFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditInvoiceIssueRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoiceIssueOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Status"',
    '                                                    Width="150">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Status}"',
    '                                                  Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="New"/>',
    '                                                        <ComboBoxItem Content="Diagnosed"/>',
    '                                                        <ComboBoxItem Content="Commit"/>',
    '                                                        <ComboBoxItem Content="Completed"/>',
    '                                                        <ComboBoxItem Content="-"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
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
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                            Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
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
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditInvoicePurchaseFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditInvoicePurchaseRefresh"',
    '                                            Content="Refresh"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="EditInvoicePurchaseOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                Binding="{Binding Record.DisplayName}"',
    '                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Distributor"',
    '                                                Binding="{Binding Record.Distributor}"',
    '                                                Width="150"/>',
    '                                        <DataGridTemplateColumn Header="Status" Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Status.Index}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Deposit"/>',
    '                                                        <ComboBoxItem Content="Paid"/>',
    '                                                        <ComboBoxItem Content="Ordered"/>',
    '                                                        <ComboBoxItem Content="Delivered"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
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
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                            Content="[Search]:"/>',
    '                                    <ComboBox Grid.Column="1"',
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
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditInvoiceInventoryFilter"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="EditInvoiceInventoryRefresh"',
    '                                            Content="Refresh"/>',
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
    '                    <DataGrid Name="EditInvoiceRecordList" Grid.Row="5">',
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
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditInvoiceCost"/>',
    '                    </Grid>',
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
        Return "<FEModule.cimdb.XamlWindow[cimdbXaml]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Uid Category [+]                                                                               ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbUidPropertyType
{
    Index
    Slot
    Uid
    Date
    Time
    Record
}

Enum cimdbUidCategoryType
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

Class cimdbUidCategoryItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbUidCategoryItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbUidCategoryType]::$Name
        $This.Name  = [cimdbUidCategoryType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbUidCategoryList
{
    [Object]      $Output
    cimdbUidCategoryList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbUidCategoryItem([String]$Name)
    {
        Return [cimdbUidCategoryItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbUidCategoryType]))
        {
            $Item             = $This.cimdbUidCategoryItem($Name)
            $Item.Description = Switch ($Name)
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
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Uid.Category[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Client Property, Record, Status [+]                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbClientPropertyType
{
    Rank
    DisplayName
    Type
    Status
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

Enum cimdbClientRecordType
{
    Individual
    Business
    Unspecified
}

Class cimdbClientRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbClientRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbClientRecordType]::$Name
        $This.Name  = [cimdbClientRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbClientRecordList
{
    [Object] $Output
    cimdbClientRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbClientRecordItem([String]$Name)
    {
        Return [cimdbClientRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbClientRecordType]))
        {
            $Item             = $This.cimdbClientRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Individual  { "Client is an individual, or a non-business entity" }
                Business    { "Client is a company/business entity"               }
                Unspecified { "Client falls into another category"                }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client.Record[List]>"
    }
}

Enum cimdbClientStatusType
{
    Registered
    Unregistered
    Unspecified
}

Class cimdbClientStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbClientStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbClientStatusType]::$Name
        $This.Name  = [cimdbClientStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbClientStatusList
{
    [Object]      $Output
    cimdbClientStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbClientStatusItem([String]$Name)
    {
        Return [cimdbClientStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbClientStatusType]))
        {
            $Item             = $This.cimdbClientStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Registered   { "Client is registered"               }
                Unregistered { "Client is unregistered"             }
                Unspecified  { "Client falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Service Property, Record, Status [+]                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbServicePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Name
    Description
    Cost
}

Enum cimdbServiceRecordType
{
    Rate
    Task
    Onsite
    Unspecified
}

Class cimdbServiceRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbServiceRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbServiceRecordType]::$Name
        $This.Name  = [cimdbServiceRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbServiceRecordList
{
    [Object] $Output
    cimdbServiceRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbServiceRecordItem([String]$Name)
    {
        Return [cimdbServiceRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbServiceRecordType]))
        {
            $Item             = $This.cimdbServiceRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Rate        { "Service is based on a paid rate"     }
                Task        { "Service is based on task completion" }
                Onsite      { "Service is based at a job site"      }
                Unspecified { "Service falls into another category" }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service.Record[List]>"
    }
}

Enum cimdbServiceStatusType
{
    Authorized
    Unauthorized
    Unspecified
}

Class cimdbServiceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbServiceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbServiceStatusType]::$Name
        $This.Name  = [cimdbServiceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbServiceStatusList
{
    [Object] $Output
    cimdbServiceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbServiceStatusItem([String]$Name)
    {
        Return [cimdbServiceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbServiceStatusType]))
        {
            $Item             = $This.cimdbServiceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Authorized   { "Service is authorized"               }
                Unauthorized { "Service is unauthorized"             }
                Unspecified  { "Service falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Device Property, Record, Status [+]                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbDevicePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Vendor
    Model
    Specification
    Serial
    Client
}

Enum cimdbDeviceRecordType
{
    Desktop
    Laptop
    Smartphone
    Tablet
    Console
    Server
    Network
    Unspecified
}

Class cimdbDeviceRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbDeviceRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbDeviceRecordType]::$Name
        $This.Name  = [cimdbDeviceRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbDeviceRecordList
{
    [Object] $Output
    cimdbDeviceRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbDeviceRecordItem([String]$Name)
    {
        Return [cimdbDeviceRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbDeviceRecordType]))
        {
            $Item             = $This.cimdbDeviceRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Desktop      { "Device is a desktop form factor"        }
                Laptop       { "Device is a laptop/netbook."            }
                Smartphone   { "Device is a smartphone or derivative"   }
                Tablet       { "Device is a tablet"                     }
                Console      { "Device is a gaming console"             }
                Server       { "Device is a server form factor"         }
                Network      { "Device is networking related"           }
                Unspecified  { "Device falls within another category"   }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device.Record[List]>"
    }
}

Enum cimdbDeviceStatusType
{
    Possessed
    Released
    Unspecified
}

Class cimdbDeviceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbDeviceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbDeviceStatusType]::$Name
        $This.Name  = [cimdbDeviceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbDeviceStatusList
{
    [Object] $Output
    cimdbDeviceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbDeviceStatusItem([String]$Name)
    {
        Return [cimdbDeviceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbDeviceStatusType]))
        {
            $Item             = $This.cimdbDeviceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Possessed   { "Device is currently in possession"  }
                Released    { "Device has been released"           }
                Unspecified { "Device falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Issue Property, Record, Status [+]                                                             ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbIssuePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Description
    Client
    Device
    Service
    Invoice
}

Enum cimdbIssueRecordType
{
    Hardware
    Software
    Application
    Network
    Design
    Account
    Contract
    Unspecified
}

Class cimdbIssueRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbIssueRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbIssueRecordType]::$Name
        $This.Name  = [cimdbIssueRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbIssueRecordList
{
    [Object] $Output
    cimdbIssueRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbIssueRecordItem([String]$Name)
    {
        Return [cimdbIssueRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbIssueRecordType]))
        {
            $Item             = $This.cimdbIssueRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Hardware     { "Issue is hardware related"              }
                Software     { "Issue is (software/OS) related"         }
                Application  { "Issue is strictly an application"       }
                Network      { "Issue is network related"               }
                Design       { "Issue is design related"                }
                Account      { "Issue is account related"               }
                Contract     { "Issue is resolvable through a contract" }
                Unspecified  { "Issue falls into another category"      }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue.Record[List]>"
    }
}

Enum cimdbIssueStatusType
{
    New      
    Diagnosed
    Commit
    Complete
    NoGo
    Fail
    Transfer
    Unspecified
}

Class cimdbIssueStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbIssueStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbIssueStatusType]::$Name
        $This.Name  = [cimdbIssueStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbIssueStatusList
{
    [Object] $Output
    cimdbIssueStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbIssueStatusItem([String]$Name)
    {
        Return [cimdbIssueStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbIssueStatusType]))
        {
            $Item             = $This.cimdbIssueStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                New         { "Issue is brand new, or has not yet been processed" }
                Diagnosed   { "Issue has been diagnosed"                          }
                Commit      { "Issue has been submitted for service commitment"   }
                Complete    { "Issue has been completed"                          }
                NoGo        { "Issue was diagnosed, but was a no-go"              }
                Fail        { "Issue was diagnosed, but failed to be resolved"    }
                Transfer    { "Issue met a condition where it was transferred"    }
                Unspecified { "Issue falls into another category"                 }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Purchase Property, Record, Status [+]                                                          ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPurchasePropertyType
{
    Rank
    DisplayName
    Type
    Status
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

Enum cimdbPurchaseRecordType
{
    Issue
    Sale
    Unspecified
}

Class cimdbPurchaseRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPurchaseRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPurchaseRecordType]::$Name
        $This.Name  = [cimdbPurchaseRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPurchaseRecordList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbPurchaseRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbPurchaseRecordItem([String]$Name)
    {
        Return [cimdbPurchaseRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPurchaseRecordType]))
        {
            $Item             = $This.cimdbPurchaseRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Issue       { "Purchase is for a designated issue"   }
                Sale        { "Purchase is strictly for resale"      }
                Unspecified { "Purchase falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Record[List]>"
    }
}

Enum cimdbPurchaseStatusType
{
    Deposit
    Paid
    Ordered
    Delivered
}

Class cimdbPurchaseStatusItem
{
    [Uint32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPurchaseStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPurchaseStatusType]::$Name
        $This.Name  = [cimdbPurchaseStatusType]::$Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Status[Item]>"
    }
}

Class cimdbPurchaseStatusList
{
    [Object] $Output
    cimdbPurchaseStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbPurchaseStatusItem([String]$Name)
    {
        Return [cimdbPurchaseStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPurchaseStatusType]))
        {
            $Item             = $This.cimdbPurchaseStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Deposit     { "Item requires a deposit to be made"  }
                Paid        { "Item has made a deposit"             }
                Ordered     { "Item has been ordered"               }
                Delivered   { "Item has been delivered"             }
                Unspecified { "Item falls into some other category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase.Status[List]>"
    }
}


<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Inventory Property, Record, Status [+]                                                         ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInventoryPropertyType
{
    Rank
    DisplayName
    Type
    Status
    Vendor
    Model
    Specification
    Serial
    Cost
    IsDevice
    Device
}

Enum cimdbInventoryRecordType
{
    Stock
	Purchase
	Salvage
	Unspecified
}

Class cimdbInventoryRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInventoryRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInventoryRecordType]::$Name
        $This.Name  = [cimdbInventoryRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInventoryRecordList
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]      $Output
    cimdbInventoryRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbInventoryRecordItem([String]$Name)
    {
        Return [cimdbInventoryRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInventoryRecordType]))
        {
            $Item             = $This.cimdbInventoryRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Stock       { "Inventory is a stock item"             }
                Purchase    { "Inventory is a purchased item"         }
                Salvage     { "Inventory was created from salvage"    }
                Unspecified { "Inventory falls into another category" }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory.Record[List]>"
    }
}

Enum cimdbInventoryStatusType
{
    Ready
    Await
    Unspecified
}

Class cimdbInventoryStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInventoryStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInventoryStatusType]::$Name
        $This.Name  = [cimdbInventoryStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInventoryStatusList
{
    [Object] $Output
    cimdbInventoryStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbInventoryStatusItem([String]$Name)
    {
        Return [cimdbInventoryStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInventoryStatusType]))
        {
            $Item             = $This.cimdbInventoryStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Ready       { "Inventory is ready for sale"      }
                Await       { "Inventory is waiting for <X>"     }
                Unspecified { "Inventory is in another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Expense Property, Record, Status [+]                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbExpensePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Recipient
    IsAccount
    Account
    Cost
}

Enum cimdbExpenseRecordType
{
    Internal
    Payout
    Residual
    Unspecified
}

Class cimdbExpenseRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbExpenseRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbExpenseRecordType]::$Name
        $This.Name  = [cimdbExpenseRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbExpenseRecordList
{
    [Object] $Output
    cimdbExpenseRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbExpenseRecordItem([String]$Name)
    {
        Return [cimdbExpenseRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbExpenseRecordType]))
        {
            $Item             = $This.cimdbExpenseRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Internal    { "Expense is internal and to be used in accounting" }
                Payout      { "Expense is a refund or a cash/check payment"      }
                Residual    { "Expense is a planned expense"                     }
                Unspecified { "Expense falls into some other category"           }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense.Record[List]>"
    }
}

Enum cimdbExpenseStatusType
{
    Paid
    Unpaid
    Unspecified
}

Class cimdbExpenseStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbExpenseStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbExpenseStatusType]::$Name
        $This.Name  = [cimdbExpenseStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbExpenseStatusList
{
    [Object] $Output
    cimdbExpenseStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbExpenseStatusItem([String]$Name)
    {
        Return [cimdbExpenseStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbExpenseStatusType]))
        {
            $Item             = $This.cimdbExpenseStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Paid        { "Expense has been paid"               }
                Unpaid      { "Expense remains unpaid"              }
                Unspecified { "Expense falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Account Property, Record, Status [+]                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbAccountPropertyType
{
    Rank
    DisplayName
    Type
    Status
    Organization
    Object
}

Enum cimdbAccountRecordType
{
    Bank
    Creditor
    Business
    Supplier
    Partner
    Unspecified
}

Class cimdbAccountRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbAccountRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbAccountRecordType]::$Name
        $This.Name  = [cimdbAccountRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbAccountRecordList
{
    [Object] $Output
    cimdbAccountRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbAccountRecordItem([String]$Name)
    {
        Return [cimdbAccountRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbAccountRecordType]))
        {
            $Item             = $This.cimdbAccountRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Bank        { "Account is specifically for a bank"   }
                Creditor    { "Account is a creditor"                }
                Business    { "Account is for a general business"    }
                Supplier    { "Account is for a supplier"            }
                Partner     { "Account is for a business partner"    }
                Unspecified { "Account falls in some other category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account.Record[List]>"
    }
}

Enum cimdbAccountStatusType
{
    Active
    Inactive
    Unspecified
}

Class cimdbAccountStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbAccountStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbAccountStatusType]::$Name
        $This.Name  = [cimdbAccountStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbAccountStatusList
{
    [Object] $Output
    cimdbAccountStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbAccountStatusItem([String]$Name)
    {
        Return [cimdbAccountStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbAccountStatusType]))
        {
            $Item             = $This.cimdbAccountStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Active      { "Account is currently active"                      }
                Inactive    { "Account is (currently inactive/no longer active)" }
                Unspecified { "Account falls into another category"              }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Invoice Property, Record, Status [+]                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbInvoicePropertyType
{
    Rank
    DisplayName
    Type
    Status
    Client
    Issue
    Purchase
    Inventory
    Cost
}

Enum cimdbInvoiceRecordType
{
    Issue
	Purchase
	Inventory
	IssuePurchase
	IssueInventory
	PurchaseInventory
	All
	Unspecified
}

Class cimdbInvoiceRecordItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInvoiceRecordItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInvoiceRecordType]::$Name
        $This.Name  = [cimdbInvoiceRecordType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInvoiceRecordList
{
    [Object] $Output
    cimdbInvoiceRecordList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbInvoiceRecordItem([String]$Name)
    {
        Return [cimdbInvoiceRecordItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInvoiceRecordType]))
        {
            $Item             = $This.cimdbInvoiceRecordItem($Name)
            $Item.Description = Switch ($Name)
            {
                Issue                  { "Sale was a resolved issue"                  }
                Purchase               { "Sale was a purchased item"                  }
                Inventory              { "Sale was from inventory"                    }
                IssuePurchase          { "Sale was an issue and a purchase"           }
                IssueInventory         { "Sale was an issue and inventory"            }
                PurchaseInventory      { "Sale was a purchase, and inventory"         }
                All                    { "Sale was an issue, purchase, and inventory" }
                Unspecified            { "Sale falls into some other category"        }
            }
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice.Record[List]>"
    }
}

Enum cimdbInvoiceStatusType
{
    Paid
    Unpaid
    Unspecified
}

Class cimdbInvoiceStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbInvoiceStatusItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbInvoiceStatusType]::$Name
        $This.Name  = [cimdbInvoiceStatusType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbInvoiceStatusList
{
    [Object] $Output
    cimdbInvoiceStatusList()
    {
        $This.Refresh()
    }
    [Object] cimdbInvoiceStatusItem([String]$Name)
    {
        Return [cimdbInvoiceStatusItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbInvoiceStatusType]))
        {
            $Item             = $This.cimdbInvoiceStatusItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Paid        { "Invoice has been paid"               }
                Unpaid      { "Invoice has not been paid"           }
                Unspecified { "Invoice falls into another category" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice.Status[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Property/Record Type/Status [+]                                                                ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbPropertyItem
{
    [UInt32] $Index
    [String] $Name
    cimdbPropertyItem([UInt32]$Index,[String]$Name)
    {
        $This.Index = $Index
        $This.Name  = $Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Property[Item]>"
    }
}

Class cimdbPropertyList
{
    Hidden [String] $Name
    Hidden [Object] $Type
    [Object]      $Output
    cimdbPropertyList([String]$Name)
    {
        $This.Name = $Name
        $This.Type = [Type]"cimdb$Name`PropertyType"
        $This.Refresh()
    }
    [Object] cimdbPropertyItem([UInt32]$Index,[String]$Name)
    {
        Return [cimdbPropertyItem]::New($Index,$Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames($This.Type))
        {
            $This.Output += $This.cimdbPropertyItem($This.Output.Count,$Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.{0}.Property[List]>" -f $This.Name
    }
}

Class cimdbRecordTypeStatusItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    [Object]    $Property
    [Object]      $Record
    [Object]      $Status
    cimdbRecordTypeStatusItem([UInt32]$Index,[String]$Name,[Object]$Record,[Object]$Status)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.Property    = $This.cimdbPropertyList()
        $This.Record      = $Record
        $This.Status      = $Status
    }
    [Object] cimdbPropertyList()
    {
        Return [cimdbPropertyList]::New($This.Name)
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Mode [+]                                                                                       ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

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

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Panel [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPanelType
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

Class cimdbPanelItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]        $Type
    cimdbPanelItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPanelType]::$Name
        $This.Name  = [cimdbPanelType]::$Name
        $This.Type  = $This.Name -Replace "Panel",""
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPanelList
{
    [Object] $Output
    cimdbPanelList()
    {
        $This.Refresh()
    }
    [Object] cimdbPanelItem([String]$Name)
    {
        Return [cimdbPanelItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPanelType]))
        {
            $This.Output += $This.cimdbPanelItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Panel[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Gender [+]                                                                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbGenderType
{
    Male
    Female
    Unspecified
}

Class cimdbGenderItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbGenderItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbGenderType]::$Name
        $This.Name  = [cimdbGenderType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbGenderList
{
    [Object] $Output
    cimdbGenderList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbGenderItem([String]$Name)
    {
        Return [cimdbGenderItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbGenderType]))
        {
            $This.Output += $This.cimdbGenderItem($Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Gender[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Phone [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbPhoneType
{
    Home
    Mobile
    Office
    Unspecified
}

Class cimdbPhoneItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbPhoneItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbPhoneType]::$Name
        $This.Name  = [cimdbPhoneType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPhoneList
{
    [Object] $Output
    cimdbPhoneList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbPhoneItem([String]$Name)
    {
        Return [cimdbPhoneItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbPhoneType]))
        {
            $Item             = $This.cimdbPhoneItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Home        { "Phone number that constitutes a clients home" }
                Mobile      { "Client's mobile phone"                        }
                Office      { "Client's office or work phone"                }
                Unspecified { "Falls under some other phone number type"     }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Phone[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Email [+]                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbEmailType
{
    Personal
    Office
    Company
    Unspecified
}

Class cimdbEmailItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbEmailItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbEmailType]::$Name
        $This.Name  = [cimdbEmailType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbEmailList
{
    [Object] $Output
    cimdbEmailList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbEmailItem([String]$Name)
    {
        Return [cimdbEmailItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbEmailType]))
        {
            $Item             = $This.cimdbEmailItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Personal    { "Indicates a clients personal email address"   }
                Office      { "Email address when in the office or at work"  }
                Company     { "Generally applicable for work related emails" }
                Unspecified { "Falls under some other category"              }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Email[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Slot Controller [+]                                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbSlotController
{
    [Object] $Category
    [Object]     $Mode
    [Object]    $Panel
    [Object]   $Gender
    [Object]    $Phone
    [Object]    $Email
    [Object]   $Output
    cimdbSlotController()
    {
        $This.Category = $This.New("Category")
        $This.Mode     = $This.New("Mode")
        $This.Panel    = $This.New("Panel")
        $This.Gender   = $This.New("Gender")
        $This.Phone    = $This.New("Phone")
        $This.Email    = $This.New("Email")

        $This.Refresh()
    }
    [String[]] Uid()
    {
        Return [System.Enum]::GetNames([cimdbUidPropertyType])
    }
    [Object] cimdbRecordTypeStatusItem([UInt32]$Index,[String]$Name,[Object]$Record,[Object]$Status)
    {
        Return [cimdbRecordTypeStatusItem]::New($Index,$Name,$Record,$Status)
    }
    [Object] AddRecordList([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Client    {    [cimdbClientRecordList]::New() }
            Service   {   [cimdbServiceRecordList]::New() }
            Device    {    [cimdbDeviceRecordList]::New() }
            Issue     {     [cimdbIssueRecordList]::New() }
            Purchase  {  [cimdbPurchaseRecordList]::New() }
            Inventory { [cimdbInventoryRecordList]::New() }
            Expense   {   [cimdbExpenseRecordList]::New() }
            Account   {   [cimdbAccountRecordList]::New() }
            Invoice   {   [cimdbInvoiceRecordList]::New() }
        }

        Return $Item
    }
    [Object] AddStatusList([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Client    {    [cimdbClientStatusList]::New() }
            Service   {   [cimdbServiceStatusList]::New() }
            Device    {    [cimdbDeviceStatusList]::New() }
            Issue     {     [cimdbIssueStatusList]::New() }
            Purchase  {  [cimdbPurchaseStatusList]::New() }
            Inventory { [cimdbInventoryStatusList]::New() }
            Expense   {   [cimdbExpenseStatusList]::New() }
            Account   {   [cimdbAccountStatusList]::New() }
            Invoice   {   [cimdbInvoiceStatusList]::New() }
        }

        Return $Item
    }
    [Object] NewSlot([String]$Name)
    {
        Return $This.cimdbRecordTypeStatusItem($This.Output.Count,
                                               $Name,
                                               $This.AddRecordList($Name),
                                               $This.AddStatusList($Name))
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Category { [cimdbUidCategoryList]::New() }
            Mode     {        [cimdbModeList]::New() }
            Panel    {       [cimdbPanelList]::New() }
            Gender   {      [cimdbGenderList]::New() }
            Phone    {       [cimdbPhoneList]::New() }
            Email    {       [cimdbEmailList]::New() }
        }

        Return $Item
    }
    [Object] Get([String]$Name,[String]$Type)
    {
        $xSlot = $This.Output | ? Name -eq $Name
        $Item  = Switch ($Type)
        {
            Full     { $xSlot                 }
            Property { $xSlot.Property.Output }
            Record   { $xSlot.Record.Output   }
            Status   { $xSlot.Status.Output   }
        }

        Return $Item
    }
    [Object] GetCategory([Object]$String)
    {
        $Item = Switch -Regex ($String)
        {
            "^\d+$"
            {
                $This.Category.Output | ? Index -match $String
            }
            Default
            {
                $This.Category.Output | ? Name -match $String
            }
        }

        Return $Item
    }
    Refresh()
    {
        $This.Output     = @( )

        ForEach ($Name in $This.Category.Output.Name)
        {
            $Item             = $This.NewSlot($Name)
            $Item.Description = Switch ($Item.Name)
            {
                Client    { "Client (property/record/status) types"    } 		
                Service   { "Service (property/record/status) types"   }
                Device    { "Device (property/record/status) types"    }
                Issue     { "Issue (property/record/status) types"     }
                Purchase  { "Purchase (property/record/status) types"  }
                Inventory { "Inventory (property/record/status) types" }
                Expense   { "Expense (property/record/status) types"   }		
                Account   { "Account (property/record/status) types"   }		
                Invoice   { "Invoice (property/record/status) types"   }
            }

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Slot[Controller]>"
    }
}


<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Valiation [+]                                                                                  ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbValidationType
{
    EditClientGivenName
    EditClientInitials
    EditClientSurname
    EditClientOtherName
    EditClientStreetAddress
    EditClientCity
    EditClientRegion
    EditClientPostalCode
    EditClientCountry
    EditClientMonth
    EditClientDay
    EditClientYear
    EditClientPhoneText
    EditClientEmailText
    EditServiceName
    EditServiceDescription
    EditServiceCost
    EditDeviceVendor
    EditDeviceModel
    EditDeviceSpecification
    EditDeviceSerial
    EditIssueDescription
    EditPurchaseDistributor
    EditPurchaseCost
    EditPurchaseURL
    EditPurchaseVendor
    EditPurchaseModel
    EditPurchaseSpecification
    EditPurchaseSerial
    EditInventoryVendor
    EditInventoryModel
    EditInventorySpecification
    EditInventorySerial
    EditInventoryCost
    EditExpenseRecipient
    EditExpenseCost
    EditAccountOrganization
}

Class cimdbValidationItem
{
    [UInt32]     $Index
    [String]      $Name
    [Object]   $Control
    [String]   $Default
    [String]   $Current
    [Int32]     $Status
    cimdbValidationItem([String]$Name)
    {
        $This.Index   = [UInt32][cimdbValidationType]::$Name
        $This.Name    = [cimdbValidationType]::$Name
    }
    SetControl([Object]$Control)
    {
        $This.Control = $Control.Control
        $This.Check()
    }
    Check()
    {
        $This.Current = $This.Control.Text
        If ($This.Current -eq $This.Default)
        {
            $This.Status = -1
        }
        If ($This.Current -match "^$")
        {
            $This.Current = $This.Default
            $This.Status = -1
        }
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbValidationController
{
    Hidden [Object] $Xaml
    [Object]      $Output
    cimdbValidationController([Object]$Xaml)
    {
        $This.Xaml = $Xaml
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbValidationItem([Object]$Type)
    {
        Return [cimdbValidationItem]::New($Type)
    }
    Add([Object]$Type)
    {
        $This.Output += $Type
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbValidationType]))
        {
            $Item         = $This.cimdbValidationItem($Name)
            $Item.Control = $This.Xaml.Get($Name)
            $Item.Default = Switch ($Name)
            {
               EditClientGivenName        { "<First>"                            }
               EditClientInitials         { "<Mi>"                               }
               EditClientSurname          { "<Last>"                             }
               EditClientOtherName        { "<Other>"                            }
               EditClientStreetAddress    { "<Address>"                          }
               EditClientCity             { "<City>"                             }
               EditClientRegion           { "<State>"                            }
               EditClientPostalCode       { "<Postal>"                           }
               EditClientCountry          { "<Country>"                          }
               EditClientMonth            { "<Month>"                            }
               EditClientDay              { "<Day>"                              }
               EditClientYear             { "<Year>"                             }
               EditClientPhoneText        { "<Enter phone number>"               }
               EditClientEmailText        { "<Enter email address>"              }
               EditServiceName            { "<Enter a name for the service>"     }
               EditServiceDescription     { "<Enter description of the service>" }
               EditServiceCost            { "<Enter cost>"                       }
               EditDeviceVendor           { "<Vendor>"                           }
               EditDeviceModel            { "<Model>"                            }
               EditDeviceSpecification    { "<Specification>"                    }
               EditDeviceSerial           { "<Enter device serial number>"       }
               EditIssueDescription       { "<Enter description of issue>"       }
               EditPurchaseDistributor    { "<Enter distributor>"                }
               EditPurchaseCost           { "<Cost>"                             }
               EditPurchaseURL            { "<Enter purchase URL>"               }
               EditPurchaseVendor         { "<Vendor>"                           }
               EditPurchaseModel          { "<Model>"                            }
               EditPurchaseSpecification  { "<Specification>"                    }
               EditPurchaseSerial         { "<Enter device serial number>"       }
               EditInventoryVendor        { "<Vendor>"                           }
               EditInventoryModel         { "<Model>"                            }
               EditInventorySpecification { "<Specification>"                    }
               EditInventorySerial        { "<Enter device serial number>"       }
               EditInventoryCost          { "<Cost>"                             }
               EditExpenseRecipient       { "<Enter recipient>"                  }
               EditExpenseCost            { "<Cost>"                             }
               EditAccountOrganization    { "<Enter Organization>"               }
            }

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Validation[Controller]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Database [+]                                                                                   ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

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
        Return "<FEModule.cimdb.List[{0}]>" -f $This.Name
    }
}

Class cimdbClientTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [Object]        $Type
    [Object]      $Status
    [Object]        $Name
    [Object]         $Dob
    [String]      $Gender
    [Object]    $Location
    [Object]       $Image
    [Object]       $Phone
    [Object]       $Email
    [Object]      $Device
    [Object]       $Issue
    [Object]     $Invoice
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
    [Object]        $Type
    [Object]      $Status
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
    [Object]          $Type
    [Object]        $Status
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [Object]        $Client
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
    [Object]        $Type
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
    [Object]          $Type
    [Object]        $Status
    [String]   $Distributor
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [Object]           $URL
    [String]        $Serial
    [UInt32]      $IsDevice
    [String]        $Device
    [Float]           $Cost
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
    [UInt32]          $Rank
    [String]   $DisplayName
    [Object]          $Type
    [Object]        $Status
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [Object]          $Cost
    [UInt32]      $IsDevice
    [Object]        $Device
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
    [Object]        $Type
    [Object]      $Status
    [Object]   $Recipient
    [UInt32]   $IsAccount
    [Object]     $Account
    [Float]         $Cost
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
    [UInt32]         $Rank
    [String]  $DisplayName
    [Object]         $Type
    [Object]       $Status
    [Object] $Organization
    [Object]       $Object
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
    [Object]        $Type
    [Object]      $Status
    [Object]      $Client
    [Object]       $Issue
    [Object]    $Purchase
    [Object]   $Inventory
    [Float]         $Cost
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
    Hidden [Object] $Slot
    [Object]      $Output
    cimdbDatabaseController([Object]$Slot)
    {
        $This.Slot = $Slot
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
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
        Return $This.cimdbUid($This.Output.Count,$This.Slot.Category.Output[$This.GetIndex($Name)])
    }
    [String] GetName([UInt32]$Index)
    {
        Return $This.Slot.Category.Output[$Index].Name
    }
    [UInt32] GetIndex([String]$Name)
    {
        Return [UInt32][cimdbUidCategoryType]::$Name
    }
    [Object[]] GetRecordSlot([String]$Name)
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

        $Uid.Record.Rank = $This.GetRecordSlot($Name).Count

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

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Controller [+]                                                                                 ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbCurrentController
{
    [Object] $Mode
    [Object]  $Uid
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

Class cimdbController
{
    [Object]     $Module
    [Object]       $Xaml
    [Object]       $Slot
    [Object] $Validation
    [Object]   $Database
    [Object]    $Current
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

        # Load slot and enum types
        $This.Slot     = $This.Get("Slot")

        # Load the database controller + template
        $This.Database = $This.Get("Database")

        # Load current object
        $This.Current  = $This.Get("Current")
        
        # Set Default Mode
        $This.SetCurrentMode("ViewUid")

        # Load the validation controller
        $This.Validation = $This.Get("Validation")
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
            Slot
            {
                $This.Update(0,"Getting [~] Slot Controller")
                $Item = [cimdbSlotController]::New()
            }
            Database
            {
                $This.Update(0,"Getting [~] Database Controller")
                $Item = [cimdbDatabaseController]::New($This.Slot)
            }
            Current
            {
                $This.Update(0,"Getting [~] Current Controller")
                $Item = [cimdbCurrentController]::New()
            }
            Validation
            {
                $This.Update(0,"Getting [~] Validation Controller")
                $Item = [cimdbValidationController]::New($This.Xaml)
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
        Return $This.Slot.Mode.Output | ? Name -eq $Mode
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
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidProperty,$Ctrl.Slot.Uid())
                $Ctrl.Xaml.IO.ViewUidProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewUidFilter.Text            = ""
            }
            EditUid
            {
                <# 
                    N/A, placeholder
                    - may add "copy to clipboard" or something
                #>
            }
            ViewClient
            {
                $List = @($Ctrl.Slot.Uid();$Ctrl.Slot.Get("Client","Property").Name)
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientProperty,$List)

                $Ctrl.Xaml.IO.ViewClientProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewClientFilter.Text            = ""
            }
            EditClient
            {

            }
            ViewService
            {
                $Ctrl.Xaml.IO.ViewServiceProperty.SelectedIndex = 0
                $Ctrl.Xaml.IO.ViewServiceFilter.Text            = ""
            }
            EditService
            {
                <#

                $Ctrl.Xaml.IO.EditClientPanel
                $Ctrl.Xaml.IO.EditClientOutput
                $Ctrl.Xaml.IO.EditClientType
                $Ctrl.Xaml.IO.EditClientStatus
                $Ctrl.Xaml.IO.EditClientGivenName
                $Ctrl.Xaml.IO.EditClientInitials
                $Ctrl.Xaml.IO.EditClientSurname
                $Ctrl.Xaml.IO.EditClientOtherName
                $Ctrl.Xaml.IO.EditClientNameIcon
                $Ctrl.Xaml.IO.EditClientStreetAddress
                $Ctrl.Xaml.IO.EditClientCity
                $Ctrl.Xaml.IO.EditClientRegion
                $Ctrl.Xaml.IO.EditClientPostalCode
                $Ctrl.Xaml.IO.EditClientCountry
                $Ctrl.Xaml.IO.EditClientLocationIcon
                $Ctrl.Xaml.IO.EditClientGender
                $Ctrl.Xaml.IO.EditClientMonth
                $Ctrl.Xaml.IO.EditClientDay
                $Ctrl.Xaml.IO.EditClientYear
                $Ctrl.Xaml.IO.EditClientDobIcon
                $Ctrl.Xaml.IO.EditClientPhoneText
                $Ctrl.Xaml.IO.EditClientPhoneIcon
                $Ctrl.Xaml.IO.EditClientPhoneAdd
                $Ctrl.Xaml.IO.EditClientPhoneList
                $Ctrl.Xaml.IO.EditClientPhoneRemove
                $Ctrl.Xaml.IO.EditClientPhoneMoveUp
                $Ctrl.Xaml.IO.EditClientPhoneMoveDown
                $Ctrl.Xaml.IO.EditClientEmailText
                $Ctrl.Xaml.IO.EditClientEmailIcon
                $Ctrl.Xaml.IO.EditClientEmailAdd
                $Ctrl.Xaml.IO.EditClientEmailList
                $Ctrl.Xaml.IO.EditClientEmailRemove
                $Ctrl.Xaml.IO.EditClientEmailMoveUp
                $Ctrl.Xaml.IO.EditClientEmailMoveDown
                $Ctrl.Xaml.IO.EditClientDeviceProperty
                $Ctrl.Xaml.IO.EditClientDeviceFilter
                $Ctrl.Xaml.IO.EditClientDeviceRefresh
                $Ctrl.Xaml.IO.EditClientDeviceOutput
                $Ctrl.Xaml.IO.EditClientDeviceAdd
                $Ctrl.Xaml.IO.EditClientDeviceList
                $Ctrl.Xaml.IO.EditClientDeviceRemove
                $Ctrl.Xaml.IO.EditClientIssueProperty
                $Ctrl.Xaml.IO.EditClientIssueFilter
                $Ctrl.Xaml.IO.EditClientIssueRefresh
                $Ctrl.Xaml.IO.EditClientIssueOutput
                $Ctrl.Xaml.IO.EditClientIssueAdd
                $Ctrl.Xaml.IO.EditClientIssueList
                $Ctrl.Xaml.IO.EditClientIssueRemove
                $Ctrl.Xaml.IO.EditClientInvoiceProperty
                $Ctrl.Xaml.IO.EditClientInvoiceFilter
                $Ctrl.Xaml.IO.EditClientInvoiceRefresh
                $Ctrl.Xaml.IO.EditClientInvoiceOutput
                $Ctrl.Xaml.IO.EditClientInvoiceAdd
                $Ctrl.Xaml.IO.EditClientInvoiceList
                $Ctrl.Xaml.IO.EditClientInvoiceRemove

                #>
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
                                        $Ctrl.Database.GetRecordSlot("Client"),
                                        $Ctrl.Xaml.IO.ViewClientOutput)
                })

                $Ctrl.Xaml.IO.ViewClientRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,$Ctrl.Database.GetRecordSlot("Client"))
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
                                        $Ctrl.Database.GetRecordSlot("Service"),
                                        $Ctrl.Xaml.IO.ViewServiceOutput)
                })
    
                $Ctrl.Xaml.IO.ViewServiceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceOutput,$Ctrl.Database.GetRecordSlot("Service"))
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
                                        $Ctrl.Database.GetRecordSlot("Device"),
                                        $Ctrl.Xaml.IO.ViewDeviceOutput)
                })

                $Ctrl.Xaml.IO.ViewDeviceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceOutput,$Ctrl.Database.GetRecordSlot("Device"))
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
                                        $Ctrl.Database.GetRecordSlot("Issue"),
                                        $Ctrl.Xaml.IO.ViewIssueOutput)
                })

                $Ctrl.Xaml.IO.ViewIssueRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueOutput,$Ctrl.Database.GetRecordSlot("Issue"))
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
                                        $Ctrl.Database.GetRecordSlot("Purchase"),
                                        $Ctrl.Xaml.IO.ViewPurchaseOutput)
                })

                $Ctrl.Xaml.IO.ViewPurchaseRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseOutput,$Ctrl.Database.GetRecordSlot("Purchase"))
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
                                        $Ctrl.Database.GetRecordSlot("Inventory"),
                                        $Ctrl.Xaml.IO.ViewInventoryOutput)
                })

                $Ctrl.Xaml.IO.ViewInventoryRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryOutput,$Ctrl.Database.GetRecordSlot("Inventory"))
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
                                        $Ctrl.Database.GetRecordSlot("Expense"),
                                        $Ctrl.Xaml.IO.ViewExpenseOutput)
                })

                $Ctrl.Xaml.IO.ViewExpenseRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseOutput,$Ctrl.Database.GetRecordSlot("Expense"))
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
                                        $Ctrl.Database.GetRecordSlot("Account"),
                                        $Ctrl.Xaml.IO.ViewAccountOutput)
                })

                $Ctrl.Xaml.IO.ViewAccountRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountOutput,$Ctrl.Database.GetRecordSlot("Account"))
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
                                        $Ctrl.Database.GetRecordSlot("Invoice"),
                                        $Ctrl.Xaml.IO.ViewInvoiceOutput)
                })

                $Ctrl.Xaml.IO.ViewInvoiceRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceOutput,$Ctrl.Database.GetRecordSlot("Invoice"))
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

        # [Set all side buttons to default style]
        ForEach ($Item in $Ctrl.Slot.Panel.Output)
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

###########

$Ctrl = [cimdbController]::New()
$Ctrl.Generate(100)
$Ctrl.StageXaml()
$Ctrl.Invoke()

###########

<#
Class cimdbClientName
{
    [String] $DisplayName
    [String]   $GivenName
    [String]    $Initials
    [String]     $Surname
    [String]   $OtherName
    cimdbClientName([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.GivenName   = $GivenName
        $This.Initials    = $Initials
        $This.Surname     = $Surname
        $This.OtherName   = $OtherName
        $This.DisplayName = $This.ToDisplayName()
    }
    [String] ToDisplayName()
    {
        $Item = $Null

        # Last, First, Middle, Other
        If ($This.Initials -ne "" -and $This.OtherName -ne "")
        {
            $Item = "{0}, {1} {2} {3}" -f $This.Surname,
                                           $This.GivenName,
                                           $This.Initials,
                                            $This.OtherName
        }

        # Last, First, Other
        ElseIf ($This.Initials -eq "" -and $This.Othername -ne "")
        {
            $Item = "{0}, {1} {2}" -f $This.Surname,
                                       $This.GivenName,
                                       $This.OtherName
        }
        # Last, First, Middle
        ElseIf ($This.Initials -ne "" -and $This.Othername -eq "")
        {
            $Item = "{0}, {1} {2}" -f $This.Surname,
                                       $This.GivenName,
                                       $This.Initials
        }
        # Last, First
        Else
        {
            $Item = "{0}, {1}" -f $This.Surname, 
                                  $This.GivenName
        }

        Return $Item
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

Class cimdbClientDob
{
    [String]   $Dob
    [UInt32] $Month
    [UInt32]  $Date
    [UInt32]  $Year
    cimdbClientDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
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

Class cimdbClientLocation
{
    [String] $StreetAddress
    [String]          $City
    [String]        $Region
    [String]    $PostalCode
    [String]       $Country
    cimdbClientLocation([String]$StreetAddress,[String]$City,[String]$Region,[String]$PostalCode,[String]$Country)
    {
        $This.StreetAddress = $StreetAddress
        $This.City          = $City
        $This.Region        = $Region
        $This.PostalCode    = $PostalCode
        $This.Country       = $Country
    }
    [String] ToString()
    {
        Return "{0}`n{1}, {2} {3}" -f $This.StreetAddress, $This.City, $This.Region, $This.PostalCode
    }
}

Class cimdbClientPhone
{
    [UInt32]  $Index
    [String]   $Type
    [String] $Number
    cimdbClientPhone([UInt32]$Index,[String]$Type,[String]$Number)
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

Class cimdbClientEmail
{
    [UInt32] $Index
    [String]  $Type
    [String] $Email
    cimdbClientEmail([UInt32]$Index,[String]$Type,[String]$Email)
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

Class cimdbClient
{
    Hidden [String]    $Uid
    Hidden [Object] $Record
    [UInt32]          $Rank
    [String]   $DisplayName
    [Object]          $Name
    [Object]      $Location
    [Object]        $Gender
    [Object]           $Dob
    [Object]         $Phone
    [Object]         $Email
    [Object]        $Device
    [Object]         $Issue
    [Object]       $Invoice
    cimdbClient([Object]$Uid)
    {
        $This.Uid     = $Uid.Uid
        $This.Prime()
    }
    Prime()
    {
        $This.Phone   = $This.cimdbListTemplate("Phone")
        $This.Email   = $This.cimdbListTemplate("Email")
        $This.Device  = $This.cimdbListTemplate("Device")
        $This.Issue   = $This.cimdbListTemplate("Issue")
        $This.Invoice = $This.cimdbListTemplate("Invoice")
    }
    [Object] cimdbListTemplate([String]$Name)
    {
        Return [cimdbListTemplate]::New($Name)
    }
    [Object] cimdbClientName([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        Return [cimdbClientName]::New($GivenName,$Initials,$Surname,$OtherName)
    }
    [Object] cimdbClientLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        Return [cimdbClientLocation]::New($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    [Object] cimdbClientDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        Return [cimdbClientDob]::New($Month,$Date,$Year)
    }
    [Object] cimdbClientPhone([UInt32]$Index,[String]$Type,[String]$Number)
    {
        Return [cimdbClientPhone]::New($Index,$Type,$Number)
    }
    [Object] cimdbClientEmail([UInt32]$Index,[String]$Type,[String]$Email)
    {
        Return [cimdbClientEmail]::New($Index,$Type,$Email)
    }
    SetName([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        $This.Name        = $This.cimdbClientName($GivenName,$Initials,$Surname,$OtherName)
        $This.DisplayName = $This.Name.DisplayName
    }
    SetLocation([String]$StreetAddress,[String]$City,[String]$State,[String]$PostalCode,[String]$Country)
    {
        $This.Location    = $This.cimdbClientLocation($StreetAddress,$City,$State,$PostalCode,$Country)
    }
    SetGender([Object]$Gender)
    {
        $This.Gender      = $Gender
    }
    SetDob([UInt32]$Month,[UInt32]$Day,[UInt32]$Year)
    {
        # [Validation]
        $Item = $Null
        
        Try
        {
            $Item = [DateTime]"$Month/$Day/$Year"
        }
        Catch
        {
            [System.Windows.MessageBox]::Show("Invalid date entered","Exception [!] Date Entry")
        }

        # [Assignment]
        If (!!$Item)
        {
            $This.Dob = $This.cimdbClientDob($Month,$Day,$Year)
        }
    }
    AddPhone([String]$Type,[String]$Number)
    {
        
    }
    RemovePhone([UInt32]$Index)
    {
        
    }
    AddEmail([String]$Type,[String]$Email)
    {

    }
    RemoveEmail([UInt32]$Index)
    {
        
    }
    AddDevice([Object]$Device)
    {
        
    }
    RemoveDevice([UInt32]$Index)
    {

    }
    AddIssue([Object]$Issue)
    {
        
    }
    RemoveIssue([UInt32]$Index)
    {
        
    }
    AddInvoice([Object]$Invoice)
    {
        
    }
    RemoveInvoice([UInt32]$Index)
    {

    }
}

$Client = [cimdbClient]$Uid

$Client.SetName("Michael","C","Cook","Sr")
$Client.SetDob(5,24,1985)
$Client.SetGender(0)
$Client.SetLocation("201D Halfmoon Circle","Clifton Park","NY",12065,"US")
$Client.AddPhone("Home","518-406-8569")
$Client.AddEmail("Personal","michael.c.cook.85@gmail.com")


$List = $Ctrl.Database.GetRecordSlot("Inventory")
$List[0].Record | Format-Table

<#

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
    [UInt32]          $Rank
    [String]   $DisplayName
    [String]       $Chassis
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [String]        $Client
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
