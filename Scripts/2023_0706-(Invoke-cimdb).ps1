<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-07-06 18:09:47                                                                  //
 \\==================================================================================================// 

    FileName   : Invoke-cimdb.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Launches the [FightingEntropy(p)] Company Information Management Database
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-07-06
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
    '                                  Name="ViewUidProperty"/>',
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
    '                                                <TextBlock Text="{Binding Record.Uid}"',
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
    '                                                Width="75"/>',
    '                            <DataGridTextColumn Header="Time"',
    '                                                Binding="{Binding Time}"',
    '                                                Width="75"/>',
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
    '                                                Width="75"/>',
    '                            <DataGridTextColumn Header="Time"',
    '                                                Binding="{Binding Time}"',
    '                                                Width="75"/>',
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
    '                                  Name="ViewClientProperty"/>',
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
    '                            <DataGridTextColumn Header="D.O.B."',
    '                                                Binding="{Binding Record.Dob.Dob}"',
    '                                                Width="75"/>',
    '                            <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone.Output}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email.Output}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <!-- Edit Client Panel -->',
    '                <Grid Name="EditClientPanel" Visibility="Collapsed">',
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
    '                            <DataGridTextColumn Header="D.O.B."',
    '                                                Binding="{Binding Record.Dob.Dob}"',
    '                                                Width="75"/>',
    '                            <DataGridTemplateColumn Header="Phone"',
    '                                                    Width="125">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Phone.Output}"',
    '                                                  Style="{StaticResource DGCombo}"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTemplateColumn Header="Email"',
    '                                                    Width="175">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="0"',
    '                                                  ItemsSource="{Binding Record.Email.Output}"',
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
    '                                 Name="EditClientGivenName"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditClientInitials"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientSurname"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientOtherName"/>',
    '                        <Image Grid.Column="5"',
    '                               Name="EditClientNameIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Location]:"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="EditClientStreetAddress"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="6">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="75"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                                <TextBox Grid.Column="1"',
    '                                         Name="EditClientCity"/>',
    '                                <TextBox Grid.Column="2"',
    '                                         Name="EditClientRegion"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientPostalCode"/>',
    '                        <Image Grid.Column="6"',
    '                               Name="EditClientLocationIcon"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="7">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Country]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="EditClientCountry"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="8">',
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
    '                                  Name="EditClientGender"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[D.O.B.]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditClientMonth"/>',
    '                        <TextBox Grid.Column="4"',
    '                                 Name="EditClientDay"/>',
    '                        <TextBox Grid.Column="5"',
    '                                 Name="EditClientYear"/>',
    '                        <Image Grid.Column="6"',
    '                               Name="EditClientDobIcon"/>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="9">',
    '                        <TabItem Header="Phone">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                </Grid.RowDefinitions>',
    '                                <DataGrid Grid.Row="0" Name="EditClientPhoneOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Phone"',
    '                                                                Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Phone.Output}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Email"',
    '                                                                Width="175">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Email.Output}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="1">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="25"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Type]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientPhoneType"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientPhoneText"/>',
    '                                    <Image Grid.Column="3"',
    '                                           Name="EditClientPhoneIcon"/>',
    '                                    <Button Grid.Column="4"',
    '                                            Name="EditClientPhoneAdd"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <DataGrid Grid.Column="0"',
    '                                              Name="EditClientPhoneList">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="40"/>',
    '                                            <DataGridTemplateColumn Header="Type"',
    '                                                                    Width="100">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Type}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="Home"/>',
    '                                                            <ComboBoxItem Content="Mobile"/>',
    '                                                            <ComboBoxItem Content="Office"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                            <DataGridTextColumn Header="Number"',
    '                                                                Binding="{Binding Number}"',
    '                                                                Width="*"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                    <Grid Grid.Column="1">',
    '                                        <Grid.RowDefinitions>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="*"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="*"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                        </Grid.RowDefinitions>',
    '                                        <Button Grid.Row="0"',
    '                                                    Name="EditClientPhoneRemove"',
    '                                                    Content="-"/>',
    '                                        <Button Grid.Row="2"',
    '                                                    Name="EditClientPhoneMoveUp">',
    '                                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\up.png"/>',
    '                                        </Button>',
    '                                        <Button Grid.Row="4"',
    '                                                    Name="EditClientPhoneMoveDown">',
    '                                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\down.png"/>',
    '                                        </Button>',
    '                                    </Grid>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Email">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                </Grid.RowDefinitions>',
    '                                <DataGrid Grid.Row="0" Name="EditClientEmailOutput">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DisplayName"',
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Phone"',
    '                                                                Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Phone.Output}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Email"',
    '                                                                Width="175">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="0"',
    '                                                              ItemsSource="{Binding Record.Email.Output}"',
    '                                                              Style="{StaticResource DGCombo}"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="1">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="25"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Type]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                              Name="EditClientEmailType"/>',
    '                                    <TextBox Grid.Column="2"',
    '                                             Name="EditClientEmailText"/>',
    '                                    <Image Grid.Column="3"',
    '                                           Name="EditClientEmailIcon"/>',
    '                                    <Button Grid.Column="4"',
    '                                            Name="EditClientEmailAdd"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <DataGrid Grid.Column="0"',
    '                                              Name="EditClientEmailList">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="40"/>',
    '                                            <DataGridTemplateColumn Header="Type"',
    '                                                                    Width="100">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Type}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="Personal"/>',
    '                                                            <ComboBoxItem Content="Office"/>',
    '                                                            <ComboBoxItem Content="Company"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                            <DataGridTextColumn Header="Handle"',
    '                                                                Binding="{Binding Handle}"',
    '                                                                Width="*"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                    <Grid Grid.Column="1">',
    '                                        <Grid.RowDefinitions>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="*"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="*"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                        </Grid.RowDefinitions>',
    '                                        <Button Grid.Row="0"',
    '                                                Name="EditClientEmailRemove"',
    '                                                Content="-"/>',
    '                                        <Button Grid.Row="2"',
    '                                                Name="EditClientEmailMoveUp">',
    '                                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\up.png"/>',
    '                                        </Button>',
    '                                        <Button Grid.Row="4"',
    '                                                Name="EditClientEmailMoveDown">',
    '                                            <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Control\down.png"/>',
    '                                        </Button>',
    '                                    </Grid>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Device(s)">',
    '                            <Grid>',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Grid Grid.Column="0">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <DataGrid Grid.Row="0"',
    '                                              Name="EditClientDeviceOutput">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTemplateColumn Header="Type"',
    '                                                                    Width="100">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="Desktop"/>',
    '                                                            <ComboBoxItem Content="Laptop"/>',
    '                                                            <ComboBoxItem Content="Smartphone"/>',
    '                                                            <ComboBoxItem Content="Tablet"/>',
    '                                                            <ComboBoxItem Content="Console"/>',
    '                                                            <ComboBoxItem Content="Server"/>',
    '                                                            <ComboBoxItem Content="Network"/>',
    '                                                            <ComboBoxItem Content="Other"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                            <DataGridTextColumn Header="Vendor"',
    '                                                                Binding="{Binding Record.Vendor}"',
    '                                                                Width="150"/>',
    '                                            <DataGridTextColumn Header="Model"',
    '                                                                Binding="{Binding Record.Model}"',
    '                                                                Width="150"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                    <Grid Grid.Row="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="90"/>',
    '                                            <ColumnDefinition Width="120"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Search]:"/>',
    '                                        <ComboBox Grid.Column="1"',
    '                                                  Name="EditClientDeviceProperty"/>',
    '                                        <TextBox Grid.Column="2"',
    '                                                 Name="EditClientDeviceFilter"/>',
    '                                    </Grid>',
    '                                    <DataGrid Grid.Row="2"',
    '                                              Name="EditClientDeviceList">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTemplateColumn Header="Type"',
    '                                                                    Width="100">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="Desktop"/>',
    '                                                            <ComboBoxItem Content="Laptop"/>',
    '                                                            <ComboBoxItem Content="Smartphone"/>',
    '                                                            <ComboBoxItem Content="Tablet"/>',
    '                                                            <ComboBoxItem Content="Console"/>',
    '                                                            <ComboBoxItem Content="Server"/>',
    '                                                            <ComboBoxItem Content="Network"/>',
    '                                                            <ComboBoxItem Content="Other"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                            <DataGridTextColumn Header="Vendor"',
    '                                                                Binding="{Binding Record.Vendor}"',
    '                                                                Width="150"/>',
    '                                            <DataGridTextColumn Header="Model"',
    '                                                                Binding="{Binding Record.Model}"',
    '                                                                Width="150"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                </Grid>',
    '                                <Grid Grid.Column="1">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Button Grid.Row="0"',
    '                                            Name="EditClientDeviceAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Row="1"',
    '                                            Name="EditClientDeviceRefresh"',
    '                                            Content="~"/>',
    '                                    <Button Grid.Row="2"',
    '                                            Name="EditClientDeviceRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Issue(s)">',
    '                            <Grid>',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Grid Grid.Column="0">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <DataGrid Grid.Row="0"',
    '                                              Name="EditClientIssueOutput">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTemplateColumn Header="Status"',
    '                                                                    Width="150">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Status.Index}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="New"/>',
    '                                                            <ComboBoxItem Content="Diagnosed"/>',
    '                                                            <ComboBoxItem Content="Commit"/>',
    '                                                            <ComboBoxItem Content="Complete"/>',
    '                                                            <ComboBoxItem Content="NoGo"/>',
    '                                                            <ComboBoxItem Content="Fail"/>',
    '                                                            <ComboBoxItem Content="Transfer"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                    <Grid Grid.Row="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="90"/>',
    '                                            <ColumnDefinition Width="120"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Search]:"/>',
    '                                        <ComboBox Grid.Column="1"',
    '                                                  Name="EditClientIssueProperty"/>',
    '                                        <TextBox Grid.Column="2"',
    '                                                 Name="EditClientIssueFilter"/>',
    '                                    </Grid>',
    '                                    <DataGrid Grid.Row="2"',
    '                                              Name="EditClientIssueList">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTemplateColumn Header="Status"',
    '                                                                    Width="150">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Status.Index}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="New"/>',
    '                                                            <ComboBoxItem Content="Diagnosed"/>',
    '                                                            <ComboBoxItem Content="Commit"/>',
    '                                                            <ComboBoxItem Content="Complete"/>',
    '                                                            <ComboBoxItem Content="NoGo"/>',
    '                                                            <ComboBoxItem Content="Fail"/>',
    '                                                            <ComboBoxItem Content="Transfer"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                </Grid>',
    '                                <Grid Grid.Column="1">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Button Grid.Row="0"',
    '                                            Name="EditClientIssueAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Row="1"',
    '                                            Name="EditClientIssueRefresh"',
    '                                            Content="~"/>',
    '                                    <Button Grid.Row="2"',
    '                                            Name="EditClientIssueRemove"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Invoice(s)">',
    '                            <Grid>',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Grid Grid.Column="0">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <DataGrid Grid.Row="0"',
    '                                              Name="EditClientInvoiceOutput">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTextColumn Header="Client"',
    '                                                                Binding="{Binding Record.Name}"',
    '                                                                Width="250"/>',
    '                                            <DataGridTemplateColumn Header="Status"',
    '                                                                Width="100">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="Paid"/>',
    '                                                            <ComboBoxItem Content="Unpaid"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                            <DataGridTextColumn Header="Cost"',
    '                                                                Binding="{Binding Record.Cost}"',
    '                                                                Width="100"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                    <Grid Grid.Row="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="90"/>',
    '                                            <ColumnDefinition Width="120"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Search]:"/>',
    '                                        <ComboBox Grid.Column="1"',
    '                                                  Name="EditClientInvoiceProperty"/>',
    '                                        <TextBox Grid.Column="2"',
    '                                                 Name="EditClientInvoiceFilter"/>',
    '                                    </Grid>',
    '                                    <DataGrid Grid.Row="2"',
    '                                              Name="EditClientInvoiceList">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="DisplayName"',
    '                                                                Binding="{Binding Record.DisplayName}"',
    '                                                                Width="*"/>',
    '                                            <DataGridTemplateColumn Header="Status"',
    '                                                                    Width="150">',
    '                                                <DataGridTemplateColumn.CellTemplate>',
    '                                                    <DataTemplate>',
    '                                                        <ComboBox SelectedIndex="{Binding Record.Status.Index}"',
    '                                                                  Style="{StaticResource DGCombo}">',
    '                                                            <ComboBoxItem Content="New"/>',
    '                                                            <ComboBoxItem Content="Diagnosed"/>',
    '                                                            <ComboBoxItem Content="Commit"/>',
    '                                                            <ComboBoxItem Content="Complete"/>',
    '                                                            <ComboBoxItem Content="NoGo"/>',
    '                                                            <ComboBoxItem Content="Fail"/>',
    '                                                            <ComboBoxItem Content="Transfer"/>',
    '                                                            <ComboBoxItem Content="Unspecified"/>',
    '                                                        </ComboBox>',
    '                                                    </DataTemplate>',
    '                                                </DataGridTemplateColumn.CellTemplate>',
    '                                            </DataGridTemplateColumn>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                </Grid>',
    '                                <Grid Grid.Column="1">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="*"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Button Grid.Row="0"',
    '                                            Name="EditClientInvoiceAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Row="1"',
    '                                            Name="EditClientInvoiceRefresh"',
    '                                            Content="~"/>',
    '                                    <Button Grid.Row="2"',
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
    '                                  Name="ViewServiceProperty"/>',
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
    '                                 Name="EditServiceName"/>',
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
    '                                 Name="EditServiceDescription"/>',
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
    '                                 Name="EditServiceCost"/>',
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
    '                                  Name="ViewDeviceProperty"/>',
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
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                  Style="{StaticResource DGCombo}"',
    '                                                  IsReadOnly="True">',
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
    '                            <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
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
    '                                 Name="EditDeviceVendor"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditDeviceModel"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditDeviceSpecification"/>',
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
    '                                 Name="EditDeviceSerial"/>',
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
    '                                  Name="ViewIssueProperty"/>',
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
    '                            <ColumnDefinition Width="*"/>',
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
    '                                 Name="EditIssueDescription"/>',
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
    '                                        <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                              Style="{StaticResource DGCombo}">',
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
    '                                  Name="ViewPurchaseProperty"/>',
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
    '                                                  Style="{StaticResource DGCombo}">',
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
    '                                 Name="EditPurchaseDistributor"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditPurchaseCost"/>',
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
    '                                 Name="EditPurchaseURL"/>',
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
    '                                 Name="EditPurchaseVendor"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditPurchaseModel"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditPurchaseSpecification"/>',
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
    '                                 Name="EditPurchaseSerial"/>',
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
    '                                    <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                          Style="{StaticResource DGCombo}">',
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
    '                                  Name="ViewInventoryProperty"/>',
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
    '                                 Name="EditInventoryVendor"/>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="EditInventoryModel"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditInventorySpecification"/>',
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
    '                                 Name="EditInventorySerial"/>',
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
    '                                 Name="EditInventoryCost"/>',
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
    '                                    <DataGridTemplateColumn Header="Type"',
    '                                                            Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Type}"',
    '                                                          Style="{StaticResource DGCombo}">',
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
    '                                  Name="ViewExpenseProperty"/>',
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
    '                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
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
    '                                        <ComboBox SelectedIndex="{Binding Record.Type}"',
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
    '                                 Name="EditExpenseRecipient"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Cost]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="EditExpenseCost"/>',
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
    '                                      Name="EditExpenseAccountOutput">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="DisplayName"',
    '                                                        Binding="{Binding Record.DisplayName}"',
    '                                                        Width="*"/>',
    '                                    <DataGridTemplateColumn Header="Type"',
    '                                                    Width="100">',
    '                                        <DataGridTemplateColumn.CellTemplate>',
    '                                            <DataTemplate>',
    '                                                <ComboBox SelectedIndex="{Binding Record.Type.Index}"',
    '                                                          Style="{StaticResource DGCombo}">',
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
    '                                  Name="ViewAccountProperty"/>',
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
    '                                 Name="EditAccountOrganization"/>',
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
    '                            <DataGrid Grid.Row="1" Name="EditAccountObjectOutput">',
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
    '                                  Name="ViewInvoiceProperty"/>',
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
    '                                              Name="EditInvoiceClientProperty"/>',
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
    '                                              Name="EditInvoiceIssueProperty"/>',
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
    '                                                            Binding="{Binding Record.DisplayName}"',
    '                                                            Width="*"/>',
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
    '                                              Name="EditInvoicePurchaseProperty"/>',
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
    '                                              Name="EditInvoiceInventoryProperty"/>',
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
   \\__//¯¯¯ Generic [+]                                                                                    ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbListTemplate
{
    [String]   $Name
    [UInt32]  $Count
    [Object] $Output
    cimdbListTemplate([String]$Name)
    {
        $This.Name = $Name
        $This.Clear()
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
    Remove([UInt32]$Index)
    {
        If ($Index -le $This.Count)
        {
            $This.Output = $This.Output | ? Index -ne $Index
            $This.Rerank()
            $This.GetCount()
        }
    }
    MoveUp([UInt32]$Index)
    {
        If ($Index -gt 0 -and $This.Count -gt 1)
        {
            $This.Output[$Index-1].Index ++
            $This.Output[$Index].Index --
        }
    }
    MoveDown([UInt32]$Index)
    {
        If ($Index -lt ($This.Count-1) -and $This.Count -gt 1)
        {
            $This.Output[$Index].Index ++
            $This.Output[$Index+1].Index --
        }
    }
    Rerank()
    {
        $X = 0
        ForEach ($Item in $This.Output)
        {
            $Item.Index = $X
            $X ++
        }

        $This.Output = $This.Output | Sort-Object Index
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.{0}.List[Template]>" -f $This.Name
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
   \\__//¯¯¯ Client Property, Record, Status, Validation [+]                                                ___//¯¯\\   
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
    Location
    Gender
    Dob
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
        $This.DisplayName = "{0}, {1}" -f $Surname, $GivenName

        If ($Initials -ne "")
        {
            $This.DisplayName = "{0} {1}" -f $This.DisplayName, $Initials
        }

        If ($OtherName -ne "")
        {
            $This.DisplayName = "{0} {1}" -f $This.DisplayName, $OtherName
        }
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
    [UInt32]   $Day
    [UInt32]  $Year
    cimdbClientDob([UInt32]$Month,[UInt32]$Day,[UInt32]$Year)
    {
        $Item = $Null
        Try
        {
            $Item = [DateTime]"$Month/$Day/$Year"
            If (!!$Item)
            {
                $This.Month = $Month
                $This.Day   = $Day
                $This.Year  = $Year
                $This.Dob   = "{0:d2}/{1:d2}/{2:d4}" -f $This.Month, $This.Day, $This.Year
            }
        }
        Catch
        {

        }
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
    [UInt32]       $Country
    cimdbClientLocation([String]$StreetAddress,[String]$City,[String]$Region,[String]$PostalCode,[UInt32]$Country)
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
    [UInt32]   $Type
    [String] $Number
    [String] $Client
    cimdbClientPhone([Object]$Client,[UInt32]$Type,[String]$Number)
    {
        $This.Index  = $Client.Phone.Count
        $This.Type   = $Type
        $This.Number = $Number
        $This.Client = $Client.DisplayName
    }
    [String] ToString()
    {
        Return $This.Number
    }
}

Class cimdbClientEmail
{
    [UInt32]  $Index
    [UInt32]   $Type
    [String] $Handle
    [String] $Client
    cimdbClientEmail([Object]$Client,[UInt32]$Type,[String]$Handle)
    {
        $This.Index  = $Client.Email.Count
        $This.Type   = $Type
        $This.Handle = $Handle
        $This.Client = $Client.DisplayName
    }
    [String] ToString()
    {
        Return $This.Handle
    }
}

Class cimdbClientValidation
{
    [Object]         $Uid
    [Int32]         $Pass
    [UInt32]        $Rank
    [String] $DisplayName
    [UInt32]        $Type
    [UInt32]      $Status
    [Object]        $Name
    [Object]    $Location
    [Object]      $Gender
    [Object]         $Dob
    [Object]       $Phone
    [Object]       $Email
    [Object]      $Device
    [Object]       $Issue
    [Object]     $Invoice
    cimdbClientValidation()
    {

    }
    SetUid([Object]$Uid)
    {
        $This.Uid                    = $Uid
        $This.Uid.Record.Rank        = $Uid.Record.Rank
        $This.Uid.Record.Type        = $This.Type
        $This.Uid.Record.Status      = $This.Status
        $This.Uid.Record.Name        = $This.Name
        $This.Uid.Record.DisplayName = $This.Name.DisplayName
        $This.Uid.Record.Location    = $This.Location
        $This.Uid.Record.Gender      = $This.Gender
        $This.Uid.Record.Dob         = $This.Dob
        $This.Uid.Record.Phone       = $This.Phone
        $This.Uid.Record.Email       = $This.Email
        $This.Uid.Record.Device      = $This.Device
        $This.Uid.Record.Issue       = $This.Issue
        $This.Uid.Record.Invoice     = $This.Invoice
    }
    [String] StringName()
    {
        Return "{0}, {1}" -f $This.Name.Surname, $This.Name.GivenName
    }
    [String] StringEmail()
    {
        Return "({0})" -f ($This.Email.Output.Handle -join "|")
    }
    [String] StringPhone()
    {
        Return "({0})" -f ($This.Phone.Output.Handle -join "|")
    }
    SetName([Object]$Name)
    {
        $This.Name        = $Name
        $This.DisplayName = $Name.DisplayName
    }
    SetLocation([Object]$Location)
    {
        $This.Location    = $Location
    }
    SetGender([UInt32]$Gender)
    {
        $This.Gender      = $Gender
    }
    SetDob([Object]$Dob)
    {
        $This.Dob = $Dob
    }
    AddPhone([Object]$Phone)
    {
        $This.Phone.Add($Phone)
    }
    RemovePhone([UInt32]$Index)
    {
        If ($Index -le $This.Phone.Count)
        {
            $This.Phone.Remove($Index)
        }
    }
    AddEmail([Object]$Email)
    {
        $This.Email.Add($Email)
    }
    RemoveEmail([UInt32]$Index)
    {
        If ($Index -le $This.Email.Count)
        {
            $This.Email.Remove($Index)
        }
    }
    AddDevice([Object]$Device)
    {
        $This.Device.Add($Device)
    }
    RemoveDevice([UInt32]$Index)
    {
        If ($Index -le $This.Device.Count)
        {
            $This.Device.Remove($Index)
        }
    }
    AddIssue([Object]$Issue)
    {
        $This.Issue.Add($Issue)
    }
    RemoveIssue([UInt32]$Index)
    {
        If ($Index -le $This.Issue.Count)
        {
            $This.Issue.Remove($Index)
        }
    }
    AddInvoice([Object]$Invoice)
    {
        $This.Invoice.Add($Invoice)
    }
    RemoveInvoice([UInt32]$Index)
    {
        If ($Index -le $This.Invoice.Count)
        {
            $This.Invoice.Remove($Index)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client[Validation]>"
    }
}

Class cimdbClientIdentity
{
    [UInt32]          $Type     
    [UInt32]        $Status   
    [String]     $GivenName
    [String]      $Initials 
    [String]       $Surname  
    [String]     $OtherName
    [String] $StreetAddress
    [String]          $City
    [String]        $Region
    [String]    $PostalCode
    [UInt32]       $Country
    [UInt32]        $Gender
    [UInt32]         $Month
    [UInt32]           $Day
    [UInt32]          $Year
    [Object]         $Phone
    [Object]         $Email
    [Object]        $Device
    [Object]         $Issue
    [Object]       $Invoice
    cimdbClientIdentity([Object]$Xaml)
    {
        $This.Type          = $Xaml.IO.EditClientType.SelectedIndex
        $This.Status        = $Xaml.IO.EditClientStatus.SelectedIndex
        $This.GivenName     = $Xaml.IO.EditClientGivenName.Text
        $This.Initials      = $Xaml.IO.EditClientInitials.Text
        $This.Surname       = $Xaml.IO.EditClientSurname.Text
        $This.OtherName     = $Xaml.IO.EditClientOtherName.Text
        $This.StreetAddress = $Xaml.IO.EditClientStreetAddress.Text
        $This.City          = $Xaml.IO.EditClientCity.Text
        $This.Region        = $Xaml.IO.EditClientRegion.Text
        $This.PostalCode    = $Xaml.IO.EditClientPostalCode.Text
        $This.Country       = $Xaml.IO.EditClientCountry.SelectedIndex
        $This.Gender        = $Xaml.IO.EditClientGender.SelectedIndex
        $This.Month         = $Xaml.IO.EditClientMonth.Text
        $This.Day           = $Xaml.IO.EditClientDay.Text
        $This.Year          = $Xaml.IO.EditClientYear.Text
        $This.Phone         = $Xaml.IO.EditClientPhoneList.Items
        $This.Email         = $Xaml.IO.EditClientEmailList.Items
        $This.Device        = $Xaml.IO.EditClientDeviceList.Items
        $This.Issue         = $Xaml.IO.EditClientIssueList.Items
        $This.Invoice       = $Xaml.IO.EditClientInvoiceList.Items
    }
    cimdbClientIdentity([Switch]$Flags,[Object]$Uid)
    {
        $This.Type          = $Uid.Record.Type
        $This.Status        = $Uid.Record.Status
        $This.GivenName     = $Uid.Record.Name.GivenName
        $This.Initials      = $Uid.Record.Name.Initials
        $This.Surname       = $Uid.Record.Name.Surname
        $This.OtherName     = $Uid.Record.Name.OtherName
        $This.StreetAddress = $Uid.Record.Location.StreetAddress
        $This.City          = $Uid.Record.Location.City
        $This.Region        = $Uid.Record.Location.Region
        $This.PostalCode    = $Uid.Record.Location.PostalCode
        $This.Country       = $Uid.Record.Location.Country
        $This.Gender        = $Uid.Record.Gender
        $This.Month         = $Uid.Record.Dob.Month
        $This.Day           = $Uid.Record.Dob.Day
        $This.Year          = $Uid.Record.Dob.Year
        $This.Phone         = $Uid.Record.Phone.Output
        $This.Email         = $Uid.Record.Email.Output
        $This.Device        = $Uid.Record.Device.Output
        $This.Issue         = $Uid.Record.Issue.Output
        $This.Invoice       = $Uid.Record.Invoice.Output
    }
    [Object] GetHash()
    {
        $Value              = $This | ConvertTo-Json 
        $Stream             = [System.IO.MemoryStream]::new()
        $Writer             = [System.IO.StreamWriter]::new($Stream)
        $Writer.Write($Value)
        $Writer.Flush()
        $Stream.Position = 0

        Return Get-FileHash -InputStream $Stream
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client[Identity]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Service Property, Record, Status, Validation [+]                                               ___//¯¯\\   
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

Class cimdbServiceValidation
{
    [Object]         $Uid
    [Int32]         $Pass
    [UInt32]        $Rank
    [String] $DisplayName
    [UInt32]        $Type
    [UInt32]      $Status
    [String]        $Name
    [String] $Description
    [Float]         $Cost
    cimdbServiceValidation()
    {

    }
    SetUid([Object]$Uid)
    {
        $This.Uid                    = $Uid
        $This.Rank                   = $Uid.Record.Rank
        $This.Uid.Record.DisplayName = $This.DisplayName
        $This.Uid.Record.Type        = $This.Type
        $This.Uid.Record.Status      = $This.Status
        $This.Uid.Record.Name        = $This.Name
        $This.Uid.Record.Description = $This.Description
        $This.Uid.Record.Cost        = $This.Cost
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Service[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Device Property, Record, Status, Validation [+]                                                ___//¯¯\\   
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

Class cimdbDeviceValidation
{
    [Object]           $Uid
    [Int32]           $Pass
    [UInt32]          $Rank
    [String]   $DisplayName
    [UInt32]          $Type
    [UInt32]        $Status
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [Object]        $Client
    cimdbDeviceValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Device[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Issue Property, Record, Status, Validation [+]                                                 ___//¯¯\\   
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

Class cimdbIssueValidation
{
    [Object]         $Uid
    [Int32]         $Pass
    [UInt32]        $Rank
    [Object] $DisplayName
    [UInt32]        $Type
    [UInt32]      $Status
    [String] $Description
    [Object]      $Client
    [Object]      $Device
    [Object]     $Service
    [Object]        $List
    cimdbIssueValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Issue[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Purchase Property, Record, Status, Validation [+]                                              ___//¯¯\\   
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
    Unspecified
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

Class cimdbPurchaseValidation
{
    [Object]           $Uid
    [Int32]           $Pass
    [UInt32]          $Rank
    [Object]   $DisplayName
    [UInt32]          $Type
    [UInt32]        $Status
    [Object]   $Distributor
    [String]           $Url
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [UInt32]      $IsDevice
    [Object]        $Device
    [Float]           $Cost
    cimdbPurchaseValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Purchase[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Inventory Property, Record, Status, Validation [+]                                             ___//¯¯\\   
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

Class cimdbInventoryValidation
{
    [Object]           $Uid
    [Int32]           $Pass
    [UInt32]          $Rank
    [String]   $DisplayName
    [UInt32]          $Type
    [UInt32]        $Status
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
    [String]        $Serial
    [Object]          $Cost
    [UInt32]      $IsDevice
    [Object]        $Device
    cimdbInventoryValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Inventory[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Expense Property, Record, Status, Validation [+]                                               ___//¯¯\\   
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

Class cimdbExpenseValidation
{
    [Object]         $Uid
    [Int32]         $Pass
    [UInt32]        $Rank
    [Object] $DisplayName
    [UInt32]        $Type
    [UInt32]      $Status
    [Object]   $Recipient
    [UInt32]   $IsAccount
    [Object]     $Account
    [Float]         $Cost
    cimdbExpenseValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Expense[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Account Property, Record, Status, Validation [+]                                               ___//¯¯\\   
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

Class cimdbAccountValidation
{
    [Object]          $Uid
    [Int32]          $Pass
    [UInt32]         $Rank
    [String]  $DisplayName
    [UInt32]         $Type
    [UInt32]       $Status
    [String] $Organization
    [Object]       $Object
    cimdbAccountValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Account[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Invoice Property, Record, Status, Validation [+]                                               ___//¯¯\\   
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

Class cimdbInvoiceValidation
{
    [Object]         $Uid
    [Int32]         $Pass
    [UInt32]        $Rank
    [String] $DisplayName
    [UInt32]        $Mode
    [Object]      $Client
    [Object]       $Issue
    [Object]    $Purchase
    [Object]   $Inventory
    cimdbInvoiceValidation()
    {

    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Invoice[Validation]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Property/Record Type/Status [+]                                                                ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbRecordPropertyItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbRecordPropertyItem([UInt32]$Index,[String]$Name)
    {
        $This.Index = $Index
        $This.Name  = $Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Record.Property[Item]>"
    }
}

Class cimdbRecordPropertyList
{
    Hidden [String] $Name
    Hidden [Object] $Type
    [Object]      $Output
    cimdbRecordPropertyList([String]$Name)
    {
        $This.Name = $Name
        $This.Type = [Type]"cimdb$Name`PropertyType"
        $This.Refresh()
    }
    [Object] cimdbRecordPropertyItem([UInt32]$Index,[String]$Name)
    {
        Return [cimdbRecordPropertyItem]::New($Index,$Name)
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
            $This.Output += $This.cimdbRecordPropertyItem($This.Output.Count,$Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.{0}.RecordProperty[List]>" -f $This.Name
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
        $This.Property    = $This.cimdbRecordPropertyList()
        $This.Record      = $Record
        $This.Status      = $Status
    }
    [Object] cimdbRecordPropertyList()
    {
        Return [cimdbRecordPropertyList]::New($This.Name)
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
    [UInt32]    $Index
    [String]     $Name
    [String] $Category
    cimdbModeItem([String]$Name)
    {
        $This.Index    = [UInt32][cimdbModeType]::$Name
        $This.Name     = [cimdbModeType]::$Name
        $This.Category = $Name -Replace "View|Edit",""
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
   \\__//¯¯¯ Property List [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbPropertyItem
{
    [UInt32]  $Index
    [String] $Source
    [UInt32]   $Mode
    [UInt32]   $Leaf
    [String]   $Name
    cimdbPropertyItem([UInt32]$Index,[String]$Source,[UInt32]$Mode,[UInt32]$Leaf,[String]$Name)
    {
        $This.Index  = $Index
        $This.Source = $Source
        $This.Mode   = $Mode
        $This.Leaf   = $Leaf
        $This.Name   = $Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbPropertyList
{
    [Object] $Output
    cimdbPropertyList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbPropertyItem([UInt32]$Index,[String]$Source,[UInt32]$Mode,[UInt32]$Leaf,[String]$Name)
    {
        Return [cimdbPropertyItem]::New($Index,$Source,$Mode,$Leaf,$Name)
    }
    [Object] New([UInt32]$Source,[UInt32]$Mode,[UInt32]$Leaf,[String]$Name)
    {
        Return $This.cimdbPropertyItem($This.Output.Count,$This.GetSource($Source),$Mode,$Leaf,$Name)
    }
    [String] GetSource([UInt32]$Index)
    {
        $Item = Switch ($Index)
        {
            0 { "Uid"       }
            1 { "Client"    }
            2 { "Service"   }
            3 { "Device"    }
            4 { "Issue"     }
            5 { "Purchase"  }
            6 { "Inventory" }
            7 { "Expense"   }
            8 { "Account"   }
            9 { "Invoice"   }
        }

        Return $Item
    }
    Refresh()
    {
        $This.Clear()

        # Category, Mode, Leaf, Name
        (0,1,0,"Index"),
        (0,1,0,"Date"),
        (0,0,0,"Time"),
        (0,1,0,"Slot"),
        (0,1,0,"Uid"),
        (0,1,1,"Record"),
        (1,1,0,"Index"),
        (1,1,0,"Date"),
        (1,0,0,"Time"),
        (1,0,0,"Slot"),
        (1,1,0,"Uid"),
        (1,0,0,"Record"),
        (1,1,1,"Rank"),
        (1,1,1,"DisplayName"),
        (1,1,1,"Type"),
        (1,1,1,"Status"),
        (1,1,1,"Name"),
        (1,1,1,"Location"),
        (1,0,1,"Gender"),
        (1,1,1,"Dob"),
        (1,0,1,"Image"),
        (1,1,1,"Phone"),
        (1,1,1,"Email"),
        (1,1,1,"Device"),
        (1,1,1,"Issue"),
        (1,1,1,"Invoice"),
        (2,1,0,"Index"),
        (2,1,0,"Date"),
        (2,0,0,"Time"),
        (2,0,0,"Slot"),
        (2,1,0,"Uid"),
        (2,0,0,"Record"),
        (2,1,1,"Rank"),
        (2,1,1,"DisplayName"),
        (2,1,1,"Type"),
        (2,1,1,"Status"),
        (2,1,1,"Name"),
        (2,1,1,"Description"),
        (2,1,1,"Cost"),
        (3,1,0,"Index"),
        (3,1,0,"Date"),
        (3,0,0,"Time"),
        (3,0,0,"Slot"),
        (3,1,0,"Uid"),
        (3,0,0,"Record"),
        (3,1,1,"Rank"),
        (3,1,1,"DisplayName"),
        (3,1,1,"Type"),
        (3,1,1,"Status"),
        (3,1,1,"Vendor"),
        (3,1,1,"Model"),
        (3,1,1,"Specification"),
        (3,1,1,"Serial"),
        (3,1,1,"Client"),
        (4,1,0,"Index"),
        (4,1,0,"Date"),
        (4,0,0,"Time"),
        (4,0,0,"Slot"),
        (4,1,0,"Uid"),
        (4,0,0,"Record"),
        (4,1,1,"Rank"),
        (4,1,1,"DisplayName"),
        (4,1,1,"Type"),
        (4,1,1,"Status"),
        (4,1,1,"Description"),
        (4,1,1,"Client"),
        (4,1,1,"Device"),
        (4,1,1,"Service"),
        (4,1,1,"Invoice"),
        (5,1,0,"Index"),
        (5,1,0,"Date"),
        (5,0,0,"Time"),
        (5,0,0,"Slot"),
        (5,1,0,"Uid"),
        (5,0,0,"Record"),
        (5,1,1,"Rank"),
        (5,1,1,"DisplayName"),
        (5,1,1,"Type"),
        (5,1,1,"Status"),
        (5,1,1,"Distributor"),
        (5,0,1,"URL"),
        (5,1,1,"Vendor"),
        (5,1,1,"Model"),
        (5,1,1,"Specification"),
        (5,1,1,"Serial"),
        (5,0,1,"IsDevice"),
        (5,1,1,"Device"),
        (5,1,1,"Cost"),
        (6,1,0,"Index"),
        (6,1,0,"Date"),
        (6,0,0,"Time"),
        (6,0,0,"Slot"),
        (6,1,0,"Uid"),
        (6,0,0,"Record"),
        (6,1,1,"Rank"),
        (6,1,1,"DisplayName"),
        (6,1,1,"Type"),
        (6,1,1,"Status"),
        (6,1,1,"Vendor"),
        (6,1,1,"Model"),
        (6,1,1,"Specification"),
        (6,1,1,"Serial"),
        (6,1,1,"Cost"),
        (6,0,1,"IsDevice"),
        (6,1,1,"Device"),
        (7,1,0,"Index"),
        (7,1,0,"Date"),
        (7,0,0,"Time"),
        (7,0,0,"Slot"),
        (7,1,0,"Uid"),
        (7,0,0,"Record"),
        (7,1,1,"Rank"),
        (7,1,1,"DisplayName"),
        (7,1,1,"Type"),
        (7,1,1,"Status"),
        (7,1,1,"Recipient"),
        (7,0,1,"IsAccount"),
        (7,1,1,"Account"),
        (7,1,1,"Cost"),
        (8,1,0,"Index"),
        (8,1,0,"Date"),
        (8,0,0,"Time"),
        (8,0,0,"Slot"),
        (8,1,0,"Uid"),
        (8,0,0,"Record"),
        (8,1,1,"Rank"),
        (8,1,1,"DisplayName"),
        (8,1,1,"Type"),
        (8,1,1,"Status"),
        (8,1,1,"Organization"),
        (8,0,1,"Object"),
        (9,1,0,"Index"),
        (9,1,0,"Date"),
        (9,0,0,"Time"),
        (9,0,0,"Slot"),
        (9,1,0,"Uid"),
        (9,0,0,"Record"),
        (9,1,1,"Rank"),
        (9,1,1,"DisplayName"),
        (9,1,1,"Type"),
        (9,1,1,"Status"),
        (9,1,1,"Client"),
        (9,1,1,"Issue"),
        (9,1,1,"Purchase"),
        (9,1,1,"Inventory"),
        (9,1,1,"Cost") | % { 

            $This.Output += $This.New($_[0],$_[1],$_[2],$_[3])
        }
    }
    [Object[]] Get([String]$Name)
    {
        Return $This.Output | ? Source -eq $Name
    }
    [Object[]] Box([String]$Name)
    {
        Return $This.Get($Name) | ? Mode -eq 1
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Property[List]>"
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
   \\__//¯¯¯ Country [~]                                                                                    ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbCountryItem
{
    [UInt32] $Index
    [String]  $Name
    cimdbCountryItem([UInt32]$Index,[String]$Name)
    {
        $This.Index = $Index
        $This.Name  = $Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbCountryList
{
    [Object] $Output
    cimdbCountryList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbCountryItem([UInt32]$Index,[String]$Name)
    {
        Return [cimdbCountryItem]::New($Index,$Name)
    }
    Add([String]$Name)
    {
        $This.Output += $This.cimdbCountryItem($This.Output.Count,$Name)
    }
    [String[]] Enumerate()
    {
        Return ("Afghanistan;Åland Islands;Albania;Algeria;American Samoa;Andorra;"+
        "Angola;Anguilla;Antarctica;Antigua and Barbuda;Argentina;Armenia;Aruba;Au"+
        "stralia;Austrai;Azerbaijan;Bahamas, The;Bahrain;Bangladesh;Barbados;Belar"+
        "us;Belgium;Belize;Benin;Bermuda;Bhutan;Bolivia;Bonaire, Sint Eustatis and"+
        " Saba;Bosnia and Herzegovina;Botswana;Bouvet Island;Brazil;British Indian"+
        " Ocean Territory;British Virgin Islands;Brunei;Bulgaria;Burkina Faso;Buru"+
        "ndi;Cabo Verde;Cambodia;Cameroon;Canada;Cayman Islans;Central African Rep"+
        "ublic;Chad;Chile;China;Christmas Island;Cocos (Keeling) Islands;Colombia;"+
        "Comoros;Congo;Congo (DRC);Cook Islands;Costa Rica;Côte d'Ivoire;Croatia;C"+
        "uba;Curaçao;Cyprus;Czech Republic;Denmark;Djibouti;Dominica;Dominican Rep"+
        "ublic;Ecuador;Egypt;El Salvador;Equatorial Guinea;Eritrea;Estonia;Eswatin"+
        "i;Ethiopia;Falkland Islands;Faroe Islands;Fiji;Finland;France;French Guia"+
        "na;French Polynesia;French Southern Territoes;Gabon;Gambia;Georgia;German"+
        "y;Ghana;Gibraltar;Greece;Greenland;Grenada;Guadeloupe;Guam;Guatemala;Guer"+
        "nsey;Guinea;Guinea-Bissau;Guyana;Haiti;Heard Island and McDonald Islands;"+
        "Honduras;Hong Kong SAR;Hungary;Iceland;India;Indonesia;Iran;Iraq;Ireland;"+
        "Isle of Man;Israel;Italy;Jamaica;Japan;Jersey;Jordan;Kazakhstan;Kenya;Kir"+
        "ibati;Korea;Kosovo;Kuwait;Kyrgyzstan;Laos;Latvia;Lebanon;Lesotho;Liberia;"+
        "Libya;Liechtenstein;Lithuania;Luxembourg;Macao SAR;Madagascar;Malawi;Mala"+
        "ysia;Maldives;Mali;Malta;Marshall Islands;Martinique;Mauritania;Mauritius"+
        ";Mayotte;Mexico;Micronesia;Moldova;Monaco;Mongolia;Montenegro;Montserrat;"+
        "Morocco;Mozambique;Myanmar;Namibia;Nauru;Nepal;Netherlands;New Caledonia;"+
        "New Zealand;Nicaragua;Niger;Nigeria;Niue;Norfolk Island;North Korea;North"+
        " Macedonia;Northern Mariana Islands;Norway;Oman;Pakistan;Palau;Palestinia"+
        "n Authority;Panama;Papua New Guinea;Paraguay;Peru;Philippines;Pitcairn Is"+
        "lands;Poland;Portugal;Puerto Rico;Qatar;Reuincion;Romania;Russia;Rwanda;S"+
        "aint Barthélemy;Saint Kiits and Nevis;Saint Lucia;Saint Martin;Saint Pier"+
        "re and Miquelon;Saint Vincent and the Grenadines;Samoa;San Marino;São Tom"+
        "é and Príncipe;Saudi Arabia;Senegal;Serbia;Seychelles;Sierra Leone;Singap"+
        "ore;Sint Maarten;Slovakia;Slovenia;Soloman Islands;Somalia;South Africa;S"+
        "outh Georgia and the South Sandwich Islands;South Sudan;Spain;Sri Lankda;"+
        "St Kelena, Ascension and Tristan da Cunha;Sudan;Suriname;Svalbard;Sweden;"+
        "Switzerland;Syria;Taiwan;Tajikistan;Tanzania;Thailand;Timor-Leste;Togo;To"+
        "kelau;Tonga;Trinidad and Tobago;Tunisia;Turkey;Turkmenistan;Turks and Cai"+
        "cos Islands;Tuvalu;U.S. Minor Outlying Islands;U.S. Virgin Islands;Uganda"+
        ";Ukraine;United Arab Emirates;United Kingdom;United States;Uruguay;Uzbeki"+
        "stan;Vanuatu;Vatican City;Venezuela;Vietnam;Wallis and Futuna;Yemen;Zambi"+
        "a;Zimbabwe") -Split ";"
    }
    Refresh()
    {
        $This.Clear()
        ForEach ($Item in $This.Enumerate())
        {
            $This.Add($Item)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Country[List]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Ad Node [~]                                                                                    ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbAdNodeType
{
    BuiltInDomain
    ClassStore
    Computer
    Container
    DFSConfiguration
    DNSNode
    DNSZone
    DomainDNS
    DomainPolicy
    FileLinkTracking
    ForeignSecurityPrincipal
    Group
    GroupPolicyContainer
    InfrastructureUpdate
    IPSecFilter
    IPSecISAKMPPolicy
    IPSecNegotiationPolicy
    IPSecNFA
    IPSecPolicy
    LinkTrackObjectMoveTable
    LinkTrackVolumeTable
    LostAndFound
    MSDFSR_Content
    MSDFSR_ContentSet
    MSDFSR_GlobalSettings
    MSDFSR_LocalSettings
    MSDFSR_Member
    MSDFSR_ReplicationGroup
    MSDFSR_Subscriber
    MSDFSR_Subscription
    MSDFSR_Topology
    MSDS_PasswordSettingsContainer
    MSDS_QuotaContainer
    MSImaging_PSPs
    MSTPM_InformationObjectsContainer
    NTFRSSettings
    OrganizationalUnit
    RIDManager
    RIDSet
    RPCContainer
    SamServer
    User
}

Class cimdbAdNodeItem
{
    [UInt32]              $Index
    [Object]               $Name
    Hidden [String] $DisplayName
    [String]        $Description
    cimdbAdNodeItem([String]$Name)
    {
        $This.Index       = [UInt32][cimdbAdNodeType]::$Name
        $This.Name        = [cimdbAdNodeType]::$Name
        $This.DisplayName = $This.Name -Replace "_","-"
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

Class cimdbAdNodeList
{
    [Object] $Output
    cimdbAdNodeList()
    {
        $This.Refresh()
    }
    [Object] cimdbAdNodeItem([String]$Name)
    {
        Return [cimdbAdNodeItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbAdNodeType]))
        {
            $Item             = $This.cimdbAdNodeItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                BuiltInDomain
                {
                    "Built in domain"
                }
                ClassStore
                {
                    "Class store"
                }
                Computer
                {
                    "Computer object"
                }
                Container
                {
                    "Container object"
                }
                DFSConfiguration
                {
                    "Distributed Filesystem Configuration"
                }
                DNSNode
                {
                    "Domain Name Service Node"
                }
                DNSZone
                {
                    "Domain Name Service Zone"
                }
                DomainDNS
                {
                    "Domain level DNS record(s)"
                }
                DomainPolicy
                {
                    "Domain level policy"
                }
                FileLinkTracking
                {
                    "File link tracking"
                }
                ForeignSecurityPrincipal
                {
                    "Foreign Security Principal (remote domain principal)"
                }
                Group
                {
                    "Active Directory Group object"
                }
                GroupPolicyContainer
                {
                    "Active Directory Group Policy container"
                }
                InfrastructureUpdate
                {
                    "Active Directory Infrastructure Update"
                }
                IPSecFilter
                {
                    "Internet Protocol Security Filter"
                }
                IPSecISAKMPPolicy
                {
                    "Internet Protocol Security (ISAKMP)"
                }
                IPSecNegotiationPolicy
                {
                    "Internet Protocol Security Negotiation Policy"
                }
                IPSecNFA
                {
                    "Internet Protocol Security (NFA)"
                }
                IPSecPolicy
                {
                    "Internet Protocol Security Policy"
                }
                LinkTrackObjectMoveTable
                {
                    "Link track object move table"
                }
                LinkTrackVolumeTable
                {
                    "Link track volume table"
                }
                LostAndFound
                {
                    "Lost and found"
                }
                MSDFSR_Content
                {
                    "Microsoft Distributed File System Replication content"
                }
                MSDFSR_ContentSet
                {
                    "Microsoft Distributed File System Replication content set"
                }
                MSDFSR_GlobalSettings
                {
                    "Microsoft Distributed File System Replication global settings"
                }
                MSDFSR_LocalSettings
                {
                    "Microsoft Distributed File System Replication local settings"
                }
                MSDFSR_Member
                {
                    "Microsoft Distributed File System Replication member"
                }
                MSDFSR_ReplicationGroup
                {
                    "Microsoft Distributed File System Replication Replication group"
                }
                MSDFSR_Subscriber
                {
                    "Microsoft Distributed File System Replication subscriber"
                }
                MSDFSR_Subscription
                {
                    "Microsoft Distributed File System Replication subscription"
                }
                MSDFSR_Topology
                {
                    "Microsoft Distributed File System Replication topology"
                }
                MSDS_PasswordSettingsContainer
                {
                    "Microsoft (DS) password settings container"
                }
                MSDS_QuotaContainer
                {
                    "Microsoft (DS) quota container"
                }
                MSImaging_PSPs
                {
                    "Microsoft Imaging (PSP)s"
                }
                MSTPM_InformationObjectsContainer
                {
                    "Microsoft (Trusted Platform Module?) information objects container"
                }
                NTFRSSettings
                {
                    "New Technology File Replication System settings"
                }
                OrganizationalUnit
                {
                    "Active Directory Organizational Unit"
                }
                RIDManager
                {
                    "Replication ID manager"
                }
                RIDSet
                {
                    "Replication ID set"
                }
                RPCContainer
                {
                    "Remote Procedure Call container"
                }
                SamServer
                {
                    "Security Access Manager Server"
                }
                User
                {
                    "Active Directory User object"
                }
            }

            $This.Output += $Item
        }
    }
    [Object] Get([String]$Name)
    {
        Return $This.Output | ? DisplayName -eq $Name
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.AdNode[List]>"
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
    [Object] $Property
    [Object]   $Gender
    [Object]    $Phone
    [Object]    $Email
    [Object]  $Country
    [Object]   $AdNode
    [Object]   $Output
    cimdbSlotController()
    {
        $This.Category = $This.New("Category")
        $This.Mode     = $This.New("Mode")
        $This.Panel    = $This.New("Panel")
        $This.Property = $This.New("Property")
        $This.Gender   = $This.New("Gender")
        $This.Phone    = $This.New("Phone")
        $This.Email    = $This.New("Email")
        $This.Country  = $This.New("Country")
        $This.AdNode   = $This.New("AdNode")

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
            Property {    [cimdbPropertyList]::New() }
            Gender   {      [cimdbGenderList]::New() }
            Phone    {       [cimdbPhoneList]::New() }
            Email    {       [cimdbEmailList]::New() }
            Country  {     [cimdbCountryList]::New() }
            AdNode   {      [cimdbAdNodeList]::New() }
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
    [Object[]] GetProperty([String]$Name)
    {
        Return $This.Property.Get($Name)
    }
    [Object[]] GetComboBox([String]$Name)
    {
        Return $This.Property.Box($Name)
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
    [String]    $Source
    [String]      $Name
    [Object]   $Control
    [String]   $Default
    [String]   $Current
    [Int32]     $Status
    cimdbValidationItem([String]$Name)
    {
        $This.Index   = [UInt32][cimdbValidationType]::$Name
        $This.Name    = [cimdbValidationType]::$Name
        $This.Source  = $This.GetSource()
    }
    [String] GetSource()
    {
        $Item = Switch -Regex ($This.Name)
        {
            Client    { "Client"    }
            Service   { "Service"   }
            Device    { "Device"    }
            Issue     { "Issue"     }
            Purchase  { "Purchase"  }
            Inventory { "Inventory" }
            Expense   { "Expense"   }
            Account   { "Account"   }
            Invoice   { "Invoice"   }
        }

        Return $Item
    }
    SetControl([Object]$Control)
    {
        $This.Control = $Control.Control
        $This.Check()
    }
    Check()
    {
        $This.Current     = $This.Control.Text

        If ($This.Current -eq $This.Default)
        {
            $This.Status  = -1
        }
        Else
        {
            $This.Status  = 0
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
               EditInvoiceCost            { "<Cost>"                             }
            }

            $This.Output += $Item
        }
    }
    [Object] Get([String]$Name)
    {
        Return $This.Output | ? Name -eq $Name
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
    [UInt32]       $Index
    [Object]        $Date
    [Object]        $Time
    [Object]        $Slot
    [String]         $Uid
    Hidden [Int32]  $Mode
    [Object]      $Record
    cimdbUid([UInt32]$Index,[Object]$Slot)
    {
        $This.Index  = $Index
        $This.Main()
        $This.Uid    = $This.NewGuid()
        $This.Slot   = $Slot
        $This.Mode   = 0
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

Class cimdbClientTemplate
{
    [UInt32]        $Rank
    [String] $DisplayName
    [UInt32]        $Type
    [UInt32]      $Status
    [Object]        $Name
    [Object]    $Location
    [UInt32]      $Gender
    [Object]         $Dob
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
    [UInt32]        $Type
    [UInt32]      $Status
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
    [UInt32]          $Type
    [UInt32]        $Status
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
    [UInt32]        $Type
    [UInt32]      $Status
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
    [UInt32]          $Type
    [UInt32]        $Status
    [String]   $Distributor
    [String]           $Url
    [String]        $Vendor
    [String]         $Model
    [String] $Specification
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
    [UInt32]          $Type
    [UInt32]        $Status
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
    [UInt32]        $Type
    [UInt32]      $Status
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
    [UInt32]         $Type
    [UInt32]       $Status
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
    [UInt32]        $Type
    [UInt32]      $Status
    [Object]      $Client
    [Object]       $Issue
    [Object]    $Purchase
    [Object]   $Inventory
    [Object]        $List
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
    [Object]     $History
    [Object]      $Output
    cimdbDatabaseController([Object]$Slot)
    {
        $This.Slot    = $Slot
        $This.Clear()
    }
    Clear()
    {
        $This.History = @( )
        $This.Output  = @( )
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
        $Uid.Mode      = -1
        $This.History += $Uid
        $This.Output   = $This.Output | ? Uid -notin $This.History.Uid
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
    [Object] Get([Object]$Uid)
    {
        Return $This.Database.Output | ? Uid -match $Uid.Uid
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
   \\__//¯¯¯ Active Directory Integration [+]                                                               ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class cimdbClientAdUser
{
    [Object]                                 $Client
    [String]                            $DisplayName
    [String]                              $GivenName
    [String]                               $Initials
    [String]                                $Surname
    [String]                              $OtherName
    [String]                                   $Name
    [String]                          $StreetAddress
    [String]                                   $City
    [String]                                  $State
    [String]                             $PostalCode
    [String]                                $Country
    [String]                                  $POBox
    [String]                           $EmailAddress
    [String]                              $HomePhone
    [String]                            $MobilePhone
    [String]                            $OfficePhone
    [String]                           $Organization
    [String]                                  $Title
    [String]                                $Company
    [String]                               $Division
    [String]                             $Department
    [Object]                                $Manager
    [String]                             $EmployeeID
    [String]                         $EmployeeNumber
    [String]                            $Description
    [DateTime]                $AccountExpirationDate
    [UInt32]                    $AccountNotDelegated
    [SecureString]                  $AccountPassword
    [UInt32]      $AllowReversiblePasswordEncryption
    [Object]                   $AuthenticationPolicy
    [Object]               $AuthenticationPolicySilo
    [Switch]                               $AuthType
    [UInt32]                   $CannotChangePassword
    [Object[]]                         $Certificates
    [UInt32]                  $ChangePasswordAtLogon
    [UInt32]              $CompoundIdentitySupported
    [Object]                             $Credential
    [UInt32]                                $Enabled
    [String]                                    $Fax
    [String]                          $HomeDirectory
    [String]                              $HomeDrive
    [String]                               $HomePage
    [Object]                               $Instance
    [Switch]                 $KerberosEncryptionType
    [String]                      $LogonWorkstations
    [String]                                 $Office
    [Hashtable]                     $OtherAttributes
    [Switch]                               $PassThru
    [UInt32]                   $PasswordNeverExpires
    [UInt32]                    $PasswordNotRequired
    [String]                                   $Path
    [Object[]] $PrincipalsAllowedToDelegateToAccount
    [String]                            $ProfilePath
    [String]                         $SamAccountName
    [String]                             $ScriptPath
    [String]                                 $Server
    [String[]]                $ServicePrincipalNames
    [UInt32]                 $SmartcardLogonRequired
    [UInt32]                   $TrustedForDelegation
    [String]                                   $Type
    [String]                      $UserPrincipalName
    [Object]                                    $Dob
    [UInt32]                                 $Exists
    [String]                      $DistinguishedName
    cimdbClientAdUser([Object]$Client)
    {
        # Record
        $This.Client          = $Client

        # Name
        $This.DisplayName     = $Client.Record.Name.DisplayName
        $This.GivenName       = $Client.Record.Name.GivenName
        $This.Initials        = $Client.Record.Name.Initials
        $This.Surname         = $Client.Record.Name.Surname
        $This.OtherName       = $Client.Record.Name.OtherName
        $This.Name            = $Client.Record.Name.DisplayName

        # Location
        $This.StreetAddress   = $Client.Record.Location.StreetAddress
        $This.City            = $Client.Record.Location.City
        $This.State           = $Client.Record.Location.Region
        $This.PostalCode      = $Client.Record.Location.PostalCode
        $This.Country         = $Client.Record.Location.Country
        $This.POBox           = $Null

        # Gender <In @{OtherAttributes}> Do not implement for now
        # Dob <In @{OtherAttributes}>
        $This.Dob             = $Client.Record.Dob

        # Contact
        If (0 -in $Client.Record.Phone.Output.Type)
        {
            $This.HomePhone   = ($Client.Record.Phone.Output | ? Type -eq 0)[0].Number
        }

        If (1 -in $Client.Record.Phone.Output.Type)
        {
            $This.OfficePhone = ($Client.Record.Phone.Output | ? Type -eq 1)[0].Number
        }

        If (2 -in $Client.Record.Phone.Output.Type)
        {
            $This.MobilePhone = ($Client.Record.Phone.Output | ? Type -eq 2)[0].Number
        }

        $This.EmailAddress    = ($Client.Record.Email.Output)[0].Handle

        # Company <Yet to implement>
        $This.Organization    = $Null
        $This.Title           = $Null
        $This.Company         = $Null
        $This.Division        = $Null
        $This.Department      = $Null
        $This.Manager         = $Null
        $This.EmployeeID      = $Null
        $This.EmployeeNumber  = $Null
    }
    Irrelevant()
    {
        $This.Description                          = $Null
        $This.AccountExpirationDate                = $Null
        $This.AccountNotDelegated                  = $Null
        $This.AccountPassword                      = $Null
        $This.AllowReversiblePasswordEncryption    = $Null
        $This.AuthenticationPolicy                 = $Null
        $This.AuthenticationPolicySilo             = $Null
        $This.AuthType                             = $Null
        $This.CannotChangePassword                 = $Null
        $This.Certificates                         = $Null
        $This.ChangePasswordAtLogon                = $Null
        $This.CompoundIdentitySupported            = $Null
        $This.Credential                           = $Null
        $This.Enabled                              = $Null
        $This.Fax                                  = $Null
        $This.HomeDirectory                        = $Null
        $This.HomeDrive                            = $Null
        $This.HomePage                             = $Null
        $This.Instance                             = $Null
        $This.KerberosEncryptionType               = $Null
        $This.LogonWorkstations                    = $Null
        $This.Office                               = $Null
        $This.OtherAttributes                      = $Null
        $This.PassThru                             = $Null
        $This.PasswordNeverExpires                 = $Null
        $This.PasswordNotRequired                  = $Null
        $This.Path                                 = $Null
        $This.PrincipalsAllowedToDelegateToAccount = $Null
        $This.ProfilePath                          = $Null
        $This.SamAccountName                       = $Null
        $This.ScriptPath                           = $Null
        $This.Server                               = $Null
        $This.ServicePrincipalNames                = $Null
        $This.SmartcardLogonRequired               = $Null
        $This.TrustedForDelegation                 = $Null
        $This.Type                                 = $Null
        $This.UserPrincipalName                    = $Null
    }
    [String] ToString()
    {
        Return "<FEModule.cimdb.Client[AdUser]>"
    }
}

Class cimdbAdObject
{
    [String]              $Name
    Hidden [Object]     $Object
    [Object]              $Slot
    [String]    $SamAccountName
    [String] $UserPrincipalName
    [Object] $DistinguishedName
    [String]       $Description
    cimdbAdObject([Object]$Object)
    {
        $This.Name              = $Object.Name
        $This.Object            = $Object
        $This.SamAccountName    = $object.SamAccountName
        $This.UserPrincipalName = $Object.UserPrincipalName
        $This.DistinguishedName = $Object.DistinguishedName
        $This.Description       = $Object.Description
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbAddsController
{
    [Object]      $Module
    [Object]        $Slot
    [Object]   $Directory
    [String]        $Path
    [Object]      $Import
    cimdbAddsController([Object]$Module,[Object]$Slot)
    {
        $This.Module = $Module
        $This.Slot   = $Slot
    }
    Update([Int32]$State,[String]$Status)
    {
        $This.Module.Update($State,$Status)
    }
    [String] Domain()
    {
        Return [Environment]::GetEnvironmentVariable("USERDNSDOMAIN").ToLower()
    }
    [Object] cimdbAdObject([Object]$Object)
    {
        Return [cimdbAdObject]::New($Object)
    }
    [Object] cimdbClientAdUser([Object]$Client)
    {
        Return [cimdbClientAdUser]::New($Client)
    }
    [String[]] OtherAttributes()
    {
        # Could use enum types for this
        Return "Description",
               "StreetAddress",
               "City",
               "State",
               "PostalCode",
               "Country",
               "HomePhone",
               "MobilePhone",
               "OfficePhone",
               "EmailAddress"
    }
    [Object[]] GetObject()
    {
        Return Get-AdObject -Properties * -Filter * | Sort-Object Name
    }
    Clear()
    {
        $This.Directory = @( )
    }
    Refresh()
    {
        $This.Update(0,"Refreshing [~] Directory[]")

        $This.Clear()

        # Using a hashtable instead of an array is a LOT faster
        $Hash = @{ }

        ForEach ($Object in $This.GetObject())
        {
            $Item         = $This.cimdbAdObject($Object)
            $Item.Slot    = $This.Slot.AdNode.Output | ? DisplayName -eq $Item.Object.ObjectClass
            $Hash.Add($Hash.Count,$Item)
        }

        # Assign the hashtable entries to the array
        $This.Directory   = $Hash[0..($Hash.Count-1)]
        $This.Path        = $This.Directory | ? Slot -match Org | ? Name -eq Client | % DistinguishedName
    }
    GenerateSam([Object]$Item)
    {
        # [Attempt #1]
        $Hash = @{ }
        $Hash.Add(0,$Item.Client.Record.Name.GivenName.ToLower().SubString(0,1))
        $Hash.Add(1,$Item.Client.Record.Name.Surname.ToLower())
        $Hash.Add(2,$Item.Client.Record.Dob.Dob.Substring(8,2))

        $String = $Hash[0..2] -join ""
        $Ad     = $This.Directory | ? SamAccountName -match $String

        If (!$Ad)
        {
            $Item.Exists            = 0
            $Item.SamAccountName    = $String
            $Item.UserPrincipalName = "{0}@{1}" -f $String, $This.Domain()
        }
        ElseIf (!!$Ad)
        {
            $Item.Exists            = 1
            $Item.SamAccountName    = $Ad.SamAccountName
            $Item.UserPrincipalName = $Ad.UserPrincipalName
            $Item.DistinguishedName = $Ad.DistinguishedName
        }
        Else
        {
            Throw "Probable conflict with an existing user account"
        }
    }
    Check([Object]$Item)
    {
        If (!$Item.UserPrincipalName)
        {
            Throw "No user principal name set"
        }

        $Item.Exists = [UInt32]($This.UserPrincipalName -in $This.Directory.UserPrincipalName)
    }
    Create([Object]$Item)
    {
        If (!$Item.Exists)
        {
            $Splat                  = @{

                Name                = $Item.Name
                DisplayName         = $Item.DisplayName
                GivenName           = $Item.GivenName
                Initials            = $Item.Initials
                Surname             = $Item.Surname
                SamAccountName      = $Item.SamAccountName
                UserPrincipalName   = $Item.UserPrincipalName
                Path                = $This.Path
            }

            $Result = New-AdUser @Splat -PassThru -Verbose
            If ($?)
            {
                $Item.Exists            = 1
                $Item.DistinguishedName = $Result.DistinguishedName

                $Splat                  = @{ }
                ForEach ($Property in $This.OtherAttributes())
                {
                    $Splat.Add($Property,$Item.$Property)
                }
                
                Set-AdUser -Identity $Item.DistinguishedName @Splat -Verbose -EA 0
            }

        }
    }
    ImportList([Object[]]$ClientList)
    {
        $This.Import = @( )

        $This.Refresh()

        ForEach ($Client in $ClientList)
        {
            $This.Update(0,"Processing [~] $($Client.Record.DisplayName)")

            $Item         = $This.cimdbClientAdUser($Client)
            $Item.Country = $This.Slot.Country.Output[$Item.Country]
            $This.GenerateSam($Item)

            $Item.Exists  = [UInt32]($Item.UserPrincipalName -in $This.Directory.UserPrincipalName)

            Switch ($Item.Exists)
            {
                0
                {
                    $This.Import += $Item
                } 
                1
                {
                    [Console]::WriteLine("[$($Item.Name)] [!] Exists")
                }
            }
        }
    }
    CreateList()
    {
        $This.Refresh()

        ForEach ($Client in $This.Import)
        {
            $This.Create($Client)

            $This.Update($Client.Exists,("{0} [{1}]" -f @("Failed [!]","Success [+]")[$Client.Exists], $Client.DisplayName))
        }

        $This.Import = @($This.Import | ? Exists -eq 0)

        $This.Refresh()
    }
    RemoveList([String[]]$ClientList)
    {
        $This.Refresh()

        ForEach ($Client in $This.Directory | ? Name -in $ClientList)
        {
            Remove-AdUser -Identity $Client.DistinguishedName -Confirm:0 -Verbose
            $This.Update([UInt32]$?,$Client.Name)
        }
    }
    [String] ToString()
    {
        Return "<FEModule.AdObject[Controller]>"
    }
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Controller [+]                                                                                 ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Enum cimdbCurrentRecordStateType
{
    New
    View
    Edit
    Save
    Delete
}

Class cimdbCurrentRecordStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String] $Description
    cimdbCurrentRecordStateItem([String]$Name)
    {
        $This.Index = [UInt32][cimdbCurrentRecordStateType]::$Name
        $This.Name  = [cimdbCurrentRecordStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class cimdbCurrentRecordStateList
{
    [Object] $Output
    cimdbCurrentRecordStateList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] cimdbCurrentRecordStateItem([String]$Name)
    {
        Return [cimdbCurrentRecordStateItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([cimdbCurrentRecordStateType]))
        {
            $Item             = $This.cimdbCurrentRecordStateItem($Name)
            $Item.Description = Switch ($Name)
            {
                New    { "Record does not exist, and is being created"    }
                View   { "Record does exist, and is being viewed"         }
                Edit   { "Record does exist, and is being edited"         }
                Save   { "Regardless of existence, record is being saved" }
                Delete { "Record does exist, and is being deleted"        }
            }

            $This.Output      += $Item
        }
    }
}

Class cimdbCurrentController
{
    Hidden [Object]  $StateList
    [Object]             $State
    [Object]              $Mode
    [Object]               $Uid
    [Object]            $Source
    [Object]            $Target
    [Object]          $Validate
    cimdbCurrentController()
    {
        $This.StateList = $This.cimdbCurrentRecordStateList()
    }
    SetState([UInt32]$Index)
    {
        $This.State = $This.StateList.Output[$Index]
    }
    SetMode([Object]$Mode)
    {
        $This.Mode       = $Mode
    }
    SetUid([Object]$Uid)
    {
        $This.Uid        = $Uid
    }
    SetValidate([Object]$Validate)
    {
        $This.Validate   = $Validate
    }
    [Object] cimdbCurrentRecordStateList()
    {
        Return [cimdbCurrentRecordStateList]::New()
    }
    [String] Slot()
    {
        $Item = Switch -Regex ($This.Validate.GetType().Name)
        {
            Client    { "Client"    }
            Service   { "Service"   }
            Device    { "Device"    }
            Issue     { "Issue"     }
            Purchase  { "Purchase"  }
            Inventory { "Inventory" }
            Expense   { "Expense"   }
            Account   { "Account"   }
            Invoice   { "Invoice"   }
        }

        Return $Item
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
    [UInt32]       $Mode
    [Object]       $Xaml
    [Object]       $Slot
    [Object] $Validation
    [Object]   $Database
    [Object]    $Current
    [Object]       $Adds
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

        # Load the Adds Controller
        $This.Adds       = $This.Get("Adds")
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
    [String] Regex([String]$Slot)
    {
        $Item = Switch ($Slot)
        {
            FirstLast
            {
                "^[\p{L} ,.'-]+$"
            }
            InitialsOther
            {
                "(^$|^[\p{L} ,.'-]+$)"
            }
            StreetAddress
            {
                "[0-9A-Za-z]{1,}(\s{1}\w{1,})(\s{1}?\w{1,})+"
            }
            CityRegion
            {
                "^[a-zA-Z]+(?:(?:\s+|-)[a-zA-Z]+)*$"
            }
            PostalCode
            {
                "(\d{5}|[A-Za-z0-9]{1,})"
            }
            Email
            {
                "^([\w\.\-]+)@([\w\-]+)((\.(\w){2,})+)$"
            }
            Phone
            {
                "(\d{3}\-\d{3}\-\d{4}|^\+[1-9]{1}[0-9]{3,14}$)"
            }
        }

        Return $Item
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
            Adds
            {
                $This.Update(0,"Getting [~] Adds Controller")
                $Item = [cimdbAddsController]::New($This.Module,$This.Slot)
            }
            Default
            {
                $This.Update(0,"Getting [!] Invalid <$Name>")
                $Item = $Null
            }
        }

        Return $Item
    }
    [Object] cimdbListTemplate([String]$Name)
    {
        Return [cimdbListTemplate]::New($Name)
    }
    [Object] cimdbControllerProperty([Object]$Property)
    {
        Return [cimdbControllerProperty]::New($Property)
    }
    [Object] cimdbClientName([String]$GivenName,[String]$Initials,[String]$Surname,[String]$OtherName)
    {
        Return [cimdbClientName]::New($GivenName,$Initials,$Surname,$OtherName)
    }
    [Object] cimdbClientLocation([String]$StreetAddress,[String]$City,[String]$Region,[String]$PostalCode,[UInt32]$Country)
    {
        Return [cimdbClientLocation]::New($StreetAddress,$City,$Region,$PostalCode,$Country)
    }
    [Object] cimdbClientDob([UInt32]$Month,[UInt32]$Date,[UInt32]$Year)
    {
        Return [cimdbClientDob]::New($Month,$Date,$Year)
    }
    [Object] cimdbClientPhone([Object]$Client,[UInt32]$Type,[String]$Number)
    {
        Return [cimdbClientPhone]::New($Client,$Type,$Number)
    }
    [Object] cimdbClientEmail([Object]$Client,[UInt32]$Type,[String]$Email)
    {
        Return [cimdbClientEmail]::New($Client,$Type,$Email)
    }
    [Object] ClientIdentity()
    {
        $List = $This.Validation.Output | ? Source -eq Client
        $List.Check()
        If ($This.Current.Validate.Phone.Count -ne 0)
        {
            $List[11].Status = 1
        }
        If ($This.Current.Validate.Email.Count -gt 0)
        {
            $List[12].Status = 1
        }

        If (-1 -in $List.Status)    
        {
            Return $Null
        }
        Else
        {
            Return [cimdbClientIdentity]::New($This.Xaml)
        }
    }
    [Object] ClientIdentity([Object]$Uid)
    {
        Return [cimdbClientIdentity]::New([Switch]$False,$Uid)
    }
    [Object] cimdbClientValidation()
    {
        Return [cimdbClientValidation]::New()
    }
    [Object] cimdbServiceValidation()
    {
        Return [cimdbServiceValidation]::New()
    }
    [Object] cimdbDeviceValidation()
    {
        Return [cimdbDeviceValidation]::New()
    }
    [Object] cimdbIssueValidation()
    {
        Return [cimdbIssueValidation]::New()
    }
    [Object] cimdbPurchaseValidation()
    {
        Return [cimdbPurchaseValidation]::New()
    }
    [Object] cimdbInventoryValidation()
    {
        Return [cimdbInventoryValidation]::New()
    }
    [Object] cimdbExpenseValidation()
    {
        Return [cimdbExpenseValidation]::New()
    }
    [Object] cimdbAccountValidation()
    {
        Return [cimdbAccountValidation]::New()
    }
    [Object] cimdbInvoiceValidation()
    {
        Return [cimdbInvoiceValidation]::New()
    }
    SetCurrentState([UInt32]$Index)
    {
        $This.Current.SetState($Index)
    }
    SetCurrentMode([String]$Mode)
    {
        $This.Current.SetMode($This.CurrentMode($Mode))
    }
    SetCurrentUid([Object]$Uid)
    {
        $This.Current.SetUid($Uid)
    }
    [Object] CurrentMode([String]$Mode)
    {
        Return $This.Slot.Mode.Output | ? Name -eq $Mode
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
        $Prop = $This.Slot.Property.Output | ? Source -eq $This.Current.Mode.Category | ? Name -eq $Property.SelectedItem.Replace(" ","")
        $Text = $Filter.Text

        Start-Sleep -Milliseconds 20
        $Hash   = @{ }

        If ($This.Module.Mode -eq 2)
        {
            $This.Update(0,"Searching [~] $($Prop.Name)")
        }
        
        Switch -Regex ($Text)
        {
            Default 
            {
                Switch ($Prop.Leaf)
                {
                    0
                    {
                        ForEach ($Object in $Item | ? $Prop -match $This.Escape($Text))
                        {
                            $Hash.Add($Hash.Count,$Object)
                        }
                    }
                    1
                    {
                        ForEach ($Object in $Item.Record | ? $Prop -match $This.Escape($Text))
                        {
                            $Hash.Add($Hash.Count,$Object)
                        }
                    }
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
    [Object] Validate([String]$Type)
    {
        $Item = $Null
        Switch ($Type)
        {
            Client
            {
                $Item         = $This.cimdbClientValidation()
                $Item.Phone   = $This.cimdbListTemplate("Phone")
                $Item.Email   = $This.cimdbListTemplate("Email")
                $Item.Device  = $This.cimdbListTemplate("Device")
                $Item.Issue   = $This.cimdbListTemplate("Issue")
                $Item.Invoice = $This.cimdbListTemplate("Invoice")
            }
            Service
            {
                $Item         = $This.cimdbServiceValidation()
            }
            Device
            {
                $Item         = $This.cimdbDeviceValidation()
            }
            Issue
            {
                $Item         = $This.cimdbIssueValidation()
                $Item.Client  = $This.cimdbListTemplate("Client")
                $Item.Device  = $This.cimdbListTemplate("Device")
                $Item.Service = $This.cimdbListTemplate("Service")
                $Item.List    = $This.cimdbListTemplate("List")
            }
            Purchase
            {
                $Item         = $This.cimdbPurchaseValidation()
                $Item.Device  = $This.cimdbListTemplate("Device")
            }
            Inventory
            {
                $Item         = $This.cimdbInventoryValidation()
                $Item.Device  = $This.cimdbListTemplate("Device")
            }
            Expense
            {
                $Item         = $This.cimdbExpenseValidation()
            }
            Account
            {
                $Item         = $This.cimdbAccountValidation()
            }
            Invoice
            {
                $Item         = $This.cimdbInvoiceValidation()
                $Item.Client    = $This.cimdbListTemplate("Client")
                $Item.Issue     = $This.cimdbListTemplate("Issue")
                $Item.Purchase  = $This.cimdbListTemplate("Purchase")
                $Item.Inventory = $This.cimdbListTemplate("Inventory")
                $Item.List      = $This.cimdbListTemplate("List")
            }
        }

        Return $Item
    }
    ClientCheckEntry([Object]$Client)
    {
        If ($Client.GetType().Name -notmatch "(cimdbClientValidation|cimdbClientTemplate)")
        {
            Throw "Invalid client template"
        }
    }
    ClientSetName([Object]$Client,[String]$GivenName,[String]$Initials,[String]$Surname,[String]$Othername)
    {
        $This.ClientCheckEntry($Client)

        $Name = $This.cimdbClientName($GivenName,$Initials,$Surname,$OtherName)

        If (!!$Name)
        {
            # Set name
            $Client.SetName($Name)
        }
    }
    ClientSetLocation([Object]$Client,[String]$StreetAddress,[String]$City,[String]$Region,[String]$PostalCode,[UInt32]$Country)
    {
        $This.ClientCheckEntry($Client)

        $Location = $This.cimdbClientLocation($StreetAddress,$City,$Region,$PostalCode,$Country)

        If (!!$Location)
        {
            # Set location
            $Client.SetLocation($Location)
        }
    }
    ClientSetGender([Object]$Client,[UInt32]$Index)
    {
        $This.ClientCheckEntry($Client)

        If ($Index -notin 0..2)
        {
            Throw "Invalid gender type"
        }

        # Set Gender
        $Client.SetGender($Index)
    }
    ClientSetDob([Object]$Client,[UInt32]$Month,[UInt32]$Day,[UInt32]$Year)
    {
        $This.ClientCheckEntry($Client)

        $Dob = $This.cimdbClientDob($Month,$Day,$Year)

        If (!!$Dob)
        {
            # Set DOB
            $Client.SetDob($Dob)
        }
    }
    ClientAddPhone([Object]$Client,[UInt32]$Type,[String]$Number)
    {
        $This.ClientCheckEntry($Client)

        $Phone = $This.cimdbClientPhone($Client,$Type,$Number)

        If (!!$Phone)
        {
            # Add phone
            $Client.AddPhone($Phone)
        }
    }
    ClientRemovePhone([Object]$Client,[UInt32]$Index)
    {
        $This.ClientCheckEntry($Client)

        If ($Index -gt $Client.Phone.Count)
        {
            Throw "Invalid index"
        }

        ElseIf ($Client.Phone.Count -eq 1)
        {
            Throw "Cannot remove the only phone number"
        }

        $Client.Phone.Remove($Index)
    }
    ClientAddEmail([Object]$Client,[UInt32]$Type,[String]$Address)
    {
        $This.ClientCheckEntry($Client)

        $Email = $This.cimdbClientEmail($Client,$Type,$Address)

        If (!!$Email)
        {
            # Add Email
            $Client.Email.Add($Email)
        }
    }
    ClientRemoveEmail([Object]$Client,[UInt32]$Index)
    {
        $This.ClientCheckEntry($Client)

        If ($Index -gt $Client.Phone.Count)
        {
            Throw "Invalid index"
        }

        ElseIf ($Client.Phone.Count -eq 1)
        {
            Throw "Cannot remove the only phone number"
        }

        $Client.Email.Remove($Index)
    }
    ClientValidate()
    {
        $Ctrl        = $This
        $ValidateSet = $Ctrl.Validation.Output | ? Source -eq Client

        # Client validation
        ForEach ($Item in $ValidateSet)
        {
            $Item.Check()

            If ($Item.Status -eq 0)
            {
                Switch ($Item.Name)
                {
                    EditClientGivenName
                    {
                        If ($Item.Current -match $Ctrl.Regex("FirstLast"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientInitials
                    {
                        If ($Item.Current -match $Ctrl.Regex("InitialsOther"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientSurname
                    {
                        If ($Item.Current -match $Ctrl.Regex("FirstLast"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientOtherName
                    {
                        If ($Item.Current -match $Ctrl.Regex("InitialsOther"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientStreetAddress
                    {
                        If ($Item.Current -match $Ctrl.Regex("StreetAddress"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientCity
                    {
                        If ($Item.Current -match $Ctrl.Regex("CityRegion"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientRegion
                    {
                        If ($Item.Current -match $Ctrl.Regex("CityRegion"))
                        {
                            $Item.Status = 1
                        }
    
                    }
                    EditClientPostalCode
                    {
                        If ($Item.Current -match $Ctrl.Regex("PostalCode"))
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientMonth
                    {
                        If ($Item.Current -match "\d{1,}")
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientDay
                    {
                        If ($Item.Current -match "\d{1,}")
                        {
                            $Item.Status = 1
                        }
                    }
                    EditClientYear
                    {
                        If ($Item.Current -match "\d{1,}")
                        {
                            $Item.Status = 1
                        }
                    }
                }
            }
        }

        # [Phone/Email]
        ForEach ($Item in "Phone","Email")
        {
            If ($Ctrl.Current.Validate.$Item.Count -gt 0)
            {
                $ValidateSet | ? Name -match $Item | % { $_.Status = 1 }
            }
        }

        If (0 -notin $ValidateSet.Status)
        {
            # [Check identity]
            $Person = $Ctrl.Database.GetRecordSlot("Client") | ? { $_.Record.DisplayName -match $Ctrl.Current.Validate.StringName() }
            If (!!$Person)
            {
                If ($Ctrl.Current.Validate.Dob.Dob -in $Person.Record.Dob.Dob)
                {
                    $Ctrl.Current.Validate.Pass --
                }
            }
        }

        # [Final]
        If ($Ctrl.Current.Validate.Pass -ge 0)
        {
            $Ctrl.Current.Validate.Pass = 1
        }
    }
    CheckIdentity()
    {
        $Item = $This.ClientIdentity()

        If (!$Item)
        {
            $This.Current.Target         = $Null
            $This.Xaml.IO.Save.IsEnabled = 0
        }
        Else
        {
            $This.Current.Target         = $Item.GetHash().Hash
            $this.Xaml.IO.Save.IsEnabled = [UInt32]($This.Current.Source -ne $This.Current.Target)
        }
    }
    ClientToggleSave([Object]$Client)
    {
        $This.ClientValidate($Client)
        If ($Client.Pass -eq 1)
        {
            $This.Xaml.IO.Save.IsEnabled = 1
        }
    }
    New()
    {
        $Ctrl = $This
        $Ctrl.SetCurrentUid($Null)
        $Ctrl.SetCurrentState(0)

        $Ctrl.Update(0,"New [~] $($Ctrl.Current.Mode.Name)")

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {
                $Ctrl.Handle("EditClient")

                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientOutput,$Ctrl.Current.Uid)

                $Ctrl.Current.SetValidate($Ctrl.Validate("Client"))

                # Type
                $Ctrl.Xaml.IO.EditClientType.IsEnabled            = 1

                # Status
                $Ctrl.Xaml.IO.EditClientStatus.IsEnabled          = 1

                # Name
                $Ctrl.Xaml.IO.EditClientGivenName.IsReadOnly      = 0
                $Ctrl.Xaml.IO.EditClientInitials.IsReadOnly       = 0
                $Ctrl.Xaml.IO.EditClientSurname.IsReadOnly        = 0
                $Ctrl.Xaml.IO.EditClientOtherName.IsReadOnly      = 0

                # Location
                $Ctrl.Xaml.IO.EditClientStreetAddress.IsReadOnly  = 0
                $Ctrl.Xaml.IO.EditClientCity.IsReadOnly           = 0
                $Ctrl.Xaml.IO.EditClientRegion.IsReadOnly         = 0
                $Ctrl.Xaml.IO.EditClientPostalCode.IsReadOnly     = 0

                $Ctrl.Xaml.IO.EditClientCountry.IsEnabled         = 1

                # Gender
                $Ctrl.Xaml.IO.EditClientGender.IsEnabled          = 1

                # D.O.B.
                $Ctrl.Xaml.IO.EditClientMonth.IsReadOnly          = 0
                $Ctrl.Xaml.IO.EditClientDay.IsReadOnly            = 0
                $Ctrl.Xaml.IO.EditClientYear.IsReadOnly           = 0

                # Phone
                $Ctrl.Xaml.IO.EditClientPhoneType.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientPhoneText.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientPhoneAdd.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientPhoneRemove.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientPhoneMoveUp.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientPhoneMoveDown.IsEnabled   = 1

                # DataGrid [Output]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneOutput,$Null)

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneList,$Null)

                # Email
                $Ctrl.Xaml.IO.EditClientEmailType.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientEmailText.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientEmailAdd.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientEmailRemove.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientEmailMoveUp.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientEmailMoveDown.IsEnabled   = 1

                # DataGrid [Output]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailOutput,$Null)

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailList,$Null)

                # Device
                $Ctrl.Xaml.IO.EditClientDeviceProperty.IsEnabled  = 1
                $Ctrl.Xaml.IO.EditClientDeviceFilter.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientDeviceRefresh.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientDeviceOutput.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientDeviceList.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientDeviceAdd.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientDeviceRemove.IsEnabled    = 1

                # DataGrid [Output]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceOutput,$Null)

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceList,$Null)
                
                # Issue
                $Ctrl.Xaml.IO.EditClientIssueProperty.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientIssueFilter.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientIssueRefresh.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientIssueOutput.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientIssueList.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientIssueAdd.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientIssueRemove.IsEnabled     = 1

                # DataGrid [Output]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueOutput,$Null)

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueList,$Null)

                # Invoice
                $Ctrl.Xaml.IO.EditClientInvoiceProperty.IsEnabled = 1
                $Ctrl.Xaml.IO.EditClientInvoiceFilter.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientInvoiceRefresh.IsEnabled  = 1
                $Ctrl.Xaml.IO.EditClientInvoiceOutput.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientInvoiceList.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientInvoiceAdd.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientInvoiceRemove.IsEnabled   = 1

                # DataGrid [Output]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceOutput,$Null)

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceList,$Null)
            }
            Service
            {
                $Ctrl.Handle("EditService")
            }
            Device
            {
                $Ctrl.Handle("EditDevice")
            }
            Issue
            {
                $Ctrl.Handle("EditIssue")
            }
            Purchase
            {
                $Ctrl.Handle("EditPurchase")
            }
            Inventory
            {
                $Ctrl.Handle("EditInventory")
            }
            Expense
            {
                $Ctrl.Handle("EditExpense")
            }
            Account
            {
                $Ctrl.Handle("EditAccount")
            }
            Invoice
            {
                $Ctrl.Handle("EditInvoice")
            }
        }

        $Ctrl.Update(0,"New [+] $($Ctrl.Current.Mode.Name)")

        $Ctrl.Xaml.IO.New.IsEnabled = 0
    }
    View()
    {
        $Ctrl = $This
        $Ctrl.Current.SetState(1)

        $Ctrl.Update(0,"View [~] $($Ctrl.Current.Mode.Name)")

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
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientOutput,$Ctrl.Current.Uid)

                # Type
                $Ctrl.Xaml.IO.EditClientType.IsEnabled            = 0

                # Status
                $Ctrl.Xaml.IO.EditClientStatus.IsEnabled          = 0

                # Name
                $Ctrl.Xaml.IO.EditClientGivenName.IsReadOnly      = 1
                $Ctrl.Xaml.IO.EditClientInitials.IsReadOnly       = 1
                $Ctrl.Xaml.IO.EditClientSurname.IsReadOnly        = 1
                $Ctrl.Xaml.IO.EditClientOtherName.IsReadOnly      = 1

                # Location
                $Ctrl.Xaml.IO.EditClientStreetAddress.IsReadOnly  = 1
                $Ctrl.Xaml.IO.EditClientCity.IsReadOnly           = 1
                $Ctrl.Xaml.IO.EditClientRegion.IsReadOnly         = 1
                $Ctrl.Xaml.IO.EditClientPostalCode.IsReadOnly     = 1

                $Ctrl.Xaml.IO.EditClientCountry.IsEnabled         = 0

                # Gender
                $Ctrl.Xaml.IO.EditClientGender.IsEnabled          = 0

                # D.O.B.
                $Ctrl.Xaml.IO.EditClientMonth.IsReadOnly          = 1
                $Ctrl.Xaml.IO.EditClientDay.IsReadOnly            = 1
                $Ctrl.Xaml.IO.EditClientYear.IsReadOnly           = 1

                # Phone
                $Ctrl.Xaml.IO.EditClientPhoneType.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientPhoneText.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientPhoneAdd.IsEnabled        = 0
                $Ctrl.Xaml.IO.EditClientPhoneRemove.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientPhoneMoveUp.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientPhoneMoveDown.IsEnabled   = 0

                # Email
                $Ctrl.Xaml.IO.EditClientEmailType.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientEmailText.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientEmailAdd.IsEnabled        = 0
                $Ctrl.Xaml.IO.EditClientEmailRemove.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientEmailMoveUp.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientEmailMoveDown.IsEnabled   = 0

                # Device
                $Ctrl.Xaml.IO.EditClientDeviceProperty.IsEnabled  = 0
                $Ctrl.Xaml.IO.EditClientDeviceFilter.IsEnabled    = 0
                $Ctrl.Xaml.IO.EditClientDeviceRefresh.IsEnabled   = 0
                $Ctrl.Xaml.IO.EditClientDeviceOutput.IsEnabled    = 0
                $Ctrl.Xaml.IO.EditClientDeviceList.IsEnabled      = 0
                $Ctrl.Xaml.IO.EditClientDeviceAdd.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientDeviceRemove.IsEnabled    = 0
                
                # Issue
                $Ctrl.Xaml.IO.EditClientIssueProperty.IsEnabled   = 0
                $Ctrl.Xaml.IO.EditClientIssueFilter.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientIssueRefresh.IsEnabled    = 0
                $Ctrl.Xaml.IO.EditClientIssueOutput.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientIssueList.IsEnabled       = 0
                $Ctrl.Xaml.IO.EditClientIssueAdd.IsEnabled        = 0
                $Ctrl.Xaml.IO.EditClientIssueRemove.IsEnabled     = 0

                # Invoice
                $Ctrl.Xaml.IO.EditClientInvoiceProperty.IsEnabled = 0
                $Ctrl.Xaml.IO.EditClientInvoiceFilter.IsEnabled   = 0
                $Ctrl.Xaml.IO.EditClientInvoiceRefresh.IsEnabled  = 0
                $Ctrl.Xaml.IO.EditClientInvoiceOutput.IsEnabled   = 0
                $Ctrl.Xaml.IO.EditClientInvoiceList.IsEnabled     = 0
                $Ctrl.Xaml.IO.EditClientInvoiceAdd.IsEnabled      = 0
                $Ctrl.Xaml.IO.EditClientInvoiceRemove.IsEnabled   = 0
            }
            Service
            {
                $Ctrl.Handle("EditService")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditServiceOutput,$Ctrl.Current.Uid)
            }
            Device
            {
                $Ctrl.Handle("EditDevice")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceOutput,$Ctrl.Current.Uid)
            }
            Issue
            {
                $Ctrl.Handle("EditIssue")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueOutput,$Ctrl.Current.Uid)
            }
            Purchase
            {
                $Ctrl.Handle("EditPurchase")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseOutput,$Ctrl.Current.Uid)
            }
            Inventory
            {
                $Ctrl.Handle("EditInventory")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryOutput,$Ctrl.Current.Uid)
            }
            Expense
            {
                $Ctrl.Handle("EditExpense")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseOutput,$Ctrl.Current.Uid)
            }
            Account
            {
                $Ctrl.Handle("EditAccount")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountOutput,$Ctrl.Current.Uid)
            }
            Invoice
            {
                $Ctrl.Handle("EditInvoice")
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceOutput,$Ctrl.Current.Uid)
            }
        }

        $Ctrl.Update(0,"View [+] $($Ctrl.Current.Mode.Name)")

        $Ctrl.Xaml.IO.View.IsEnabled = 0
        $Ctrl.Xaml.IO.Edit.IsEnabled = 1
    }
    Edit()
    {
        $Ctrl = $This
        $Ctrl.Current.SetState(2)

        $Ctrl.Update(0,"Edit [~] $($Ctrl.Current.Mode.Name)")

        $Ctrl.Mode = 0

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {
                $Ctrl.Current.Source = $Ctrl.ClientIdentity($Ctrl.Current.Uid).GetHash().Hash

                # Type
                $Ctrl.Xaml.IO.EditClientType.IsEnabled             = 1

                # Status
                $Ctrl.Xaml.IO.EditClientStatus.IsEnabled           = 1

                # Name
                $Ctrl.Xaml.IO.EditClientGivenName.IsReadOnly       = 0
                $Ctrl.Xaml.IO.EditClientInitials.IsReadOnly        = 0
                $Ctrl.Xaml.IO.EditClientSurname.IsReadOnly         = 0
                $Ctrl.Xaml.IO.EditClientOtherName.IsReadOnly       = 0

                # Location
                $Ctrl.Xaml.IO.EditClientStreetAddress.IsReadOnly   = 0
                $Ctrl.Xaml.IO.EditClientCity.IsReadOnly            = 0
                $Ctrl.Xaml.IO.EditClientRegion.IsReadOnly          = 0
                $Ctrl.Xaml.IO.EditClientPostalCode.IsReadOnly      = 0

                $Ctrl.Xaml.IO.EditClientCountry.IsEnabled          = 1

                # Gender
                $Ctrl.Xaml.IO.EditClientGender.IsEnabled           = 1

                # D.O.B.
                $Ctrl.Xaml.IO.EditClientMonth.IsReadOnly           = 0
                $Ctrl.Xaml.IO.EditClientDay.IsReadOnly             = 0
                $Ctrl.Xaml.IO.EditClientYear.IsReadOnly            = 0

                # Phone
                $Ctrl.Xaml.IO.EditClientPhoneType.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientPhoneText.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientPhoneAdd.IsEnabled         = 1
                $Ctrl.Xaml.IO.EditClientPhoneRemove.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientPhoneMoveUp.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientPhoneMoveDown.IsEnabled    = 1

                # Email
                $Ctrl.Xaml.IO.EditClientEmailType.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientEmailText.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientEmailAdd.IsEnabled         = 1
                $Ctrl.Xaml.IO.EditClientEmailRemove.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientEmailMoveUp.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientEmailMoveDown.IsEnabled    = 1

                # Device
                $Ctrl.Xaml.IO.EditClientDeviceProperty.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientDeviceFilter.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientDeviceRefresh.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientDeviceOutput.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientDeviceList.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientDeviceAdd.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientDeviceRemove.IsEnabled     = 1

                # Issue
                $Ctrl.Xaml.IO.EditClientIssueProperty.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientIssueFilter.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientIssueRefresh.IsEnabled     = 1
                $Ctrl.Xaml.IO.EditClientIssueOutput.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientIssueList.IsEnabled        = 1
                $Ctrl.Xaml.IO.EditClientIssueAdd.IsEnabled         = 1
                $Ctrl.Xaml.IO.EditClientIssueRemove.IsEnabled      = 1

                # Invoice
                $Ctrl.Xaml.IO.EditClientInvoiceProperty.IsEnabled  = 1
                $Ctrl.Xaml.IO.EditClientInvoiceFilter.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientInvoiceRefresh.IsEnabled   = 1
                $Ctrl.Xaml.IO.EditClientInvoiceOutput.IsEnabled    = 1
                $Ctrl.Xaml.IO.EditClientInvoiceList.IsEnabled      = 1
                $Ctrl.Xaml.IO.EditClientInvoiceAdd.IsEnabled       = 1
                $Ctrl.Xaml.IO.EditClientInvoiceRemove.IsEnabled    = 1
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

        $Ctrl.Mode = 1

        $Ctrl.Update(0,"Edit [+] $($Ctrl.Current.Mode.Name)")

        $Ctrl.Xaml.IO.Edit.IsEnabled = 0
    }
    Save()
    {
        $Ctrl = $This
        $Ctrl.Current.SetState(3)

        $Ctrl.Update(0,"Save [~] $($Ctrl.Current.Mode.Name)")

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                
            }
            Client
            {
                $Ctrl.Current.SetValidate($Ctrl.Validate("Client"))

                # Set up event handlers for all of the [EditClient] text fields
                $Ctrl.Current.Validate.Type     = $Ctrl.Xaml.IO.EditClientType.SelectedIndex
                $Ctrl.Current.Validate.Status   = $Ctrl.Xaml.IO.EditClientStatus.SelectedIndex

                # [Name]
                $Ctrl.ClientSetName($Ctrl.Current.Validate,
                                    $Ctrl.Xaml.IO.EditClientGivenName.Text,
                                    $Ctrl.Xaml.IO.EditClientInitials.Text,
                                    $Ctrl.Xaml.IO.EditClientSurname.Text,
                                    $Ctrl.Xaml.IO.EditClientOtherName.Text)

                # [Location]
                $Ctrl.ClientSetLocation($Ctrl.Current.Validate,
                                        $Ctrl.Xaml.IO.EditClientStreetAddress.Text,
                                        $Ctrl.Xaml.IO.EditClientCity.Text,
                                        $Ctrl.Xaml.IO.EditClientRegion.Text,
                                        $Ctrl.Xaml.IO.EditClientPostalCode.Text,
                                        $Ctrl.Xaml.IO.EditClientCountry.SelectedIndex)

                # [Gender]
                $Ctrl.ClientSetGender($Ctrl.Current.Validate,
                                      $Ctrl.Xaml.IO.EditClientGender.SelectedIndex)

                # [Date of birth]
                $Ctrl.ClientSetDob($Ctrl.Current.Validate,
                                   $Ctrl.Xaml.IO.EditClientMonth.Text,
                                   $Ctrl.Xaml.IO.EditClientDay.Text,
                                   $Ctrl.Xaml.IO.EditClientYear.Text)

                # [Phone]
                ForEach ($Item in $Ctrl.Xaml.IO.EditClientPhoneList.Items)
                {
                    $Ctrl.ClientAddPhone($Ctrl.Current.Validate,
                                         $Item.Type,
                                         $Item.Number)
                }

                # [Email]
                ForEach ($Item in $Ctrl.Xaml.IO.EditClientEmailList.Items)
                {
                    $Ctrl.ClientAddEmail($Ctrl.Current.Validate,
                                         $Item.Type,
                                         $Item.Handle)
                }

                # [Device]
                ForEach ($Item in $Ctrl.Xaml.IO.EditClientDeviceList.Items)
                {
                    $Ctrl.ClientAddDevice($Ctrl.Current.Validate,$Item)
                }
                
                # [Issue]
                ForEach ($Item in $Ctrl.Xaml.IO.EditClientIssueList.Items)
                {
                    $Ctrl.ClientAddIssue($Ctrl.Current.Validate,$Item)
                }

                # [Inventory]
                ForEach ($Item in $Ctrl.Xaml.IO.EditClientInventoryList.Items)
                {
                    $Ctrl.ClientAddInventory($Ctrl.Current.Validate,$Item)
                }

                # Validation
                $Ctrl.ClientValidate()

                If ($Ctrl.Current.Validate.Pass)
                {
                    If ($Ctrl.Current.Source -ne "")
                    {
                        # // [Retrieve old record]
                        # $Item = $Ctrl.Database.Get($Ctrl.Current.Uid)

                        # // [Set the mode to -1 (Delete old iteration)]
                        # $Item.Mode = -1
                    }

                    # // [Create blank record]
                    $Ctrl.Database.Add(0)

                    # // [Set current Uid to that blank record]
                    $Ctrl.SetCurrentUid($Ctrl.Database.Output[-1])

                    # // [Assign the values to the client object]
                    $Ctrl.Current.Validate.SetUid($Ctrl.Current.Uid)

                    # // [Switch to ViewClient]
                    $Ctrl.Handle("ViewClient")

                    # // [Select last]
                    $Ctrl.Xaml.IO.ViewClientOutput.ScrollIntoView($Ctrl.Current.Uid)
                }
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

        # // [Clear the current validation object]
        $Ctrl.Current.Validate = $Null

        $Ctrl.Update(0,"Save [+] $($Ctrl.Current.Mode.Name)")

        $Ctrl.Xaml.IO.Save.IsEnabled = 0
    }
    Delete()
    {
        $Ctrl = $This
        $Ctrl.Current.SetState(4)

        $Ctrl.Update(0,"Delete [~] $($Ctrl.Current.Mode.Name)")

        # Implement further logic for record deletion so that it goes to crypt category
        $Ctrl.Database.Delete($Ctrl.Current.Uid)

        Switch -Regex ($Ctrl.Current.Mode.Name)
        {
            Uid
            {
                # [Changes the panel to ViewUid]
                $Ctrl.Handle("ViewUid")

                # [Resets the ViewUid DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,
                            $Ctrl.Database.Output)
            }
            Client
            {
                # [Changes the panel to ViewClient]
                $Ctrl.Handle("ViewClient")

                # [Resets the ViewClient DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,
                            $Ctrl.Database.GetRecordSlot("Client"))
            }
            Service
            {
                # [Changes the panel to ViewService]
                $Ctrl.Handle("ViewService")

                # [Resets the ViewService DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceOutput,
                            $Ctrl.Database.GetRecordSlot("Service"))
            }
            Device
            {
                # [Changes the panel to ViewDevice]
                $Ctrl.Handle("ViewDevice")

                # [Resets the ViewDevice DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceOutput,
                            $Ctrl.Database.GetRecordSlot("Device"))
            }
            Issue
            {
                # [Changes the panel to ViewIssue]
                $Ctrl.Handle("ViewIssue")

                # [Resets the ViewIssue DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueOutput,
                            $Ctrl.Database.GetRecordSlot("Issue"))
            }
            Purchase
            {
                # [Changes the panel to ViewPurchase]
                $Ctrl.Handle("ViewPurchase")

                # [Resets the ViewPurchase DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseOutput,
                            $Ctrl.Database.GetRecordSlot("Purchase"))
            }
            Inventory
            {
                # [Changes the panel to ViewInventory]
                $Ctrl.Handle("ViewInventory")

                # [Resets the ViewInventory DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryOutput,
                            $Ctrl.Database.GetRecordSlot("Inventory"))
            }
            Expense
            {
                # [Changes the panel to ViewExpense]
                $Ctrl.Handle("ViewExpense")

                # [Resets the ViewExpense DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseOutput,
                            $Ctrl.Database.GetRecordSlot("Expense"))
            }
            Account
            {
                # [Changes the panel to ViewAccount]
                $Ctrl.Handle("ViewAccount")

                # [Resets the ViewAccount DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountOutput,
                            $Ctrl.Database.GetRecordSlot("Account"))
            }
            Invoice
            {
                # [Changes the panel to ViewInvoice]
                $Ctrl.Handle("ViewInvoice")

                # [Resets the ViewInvoice DataGrid]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceOutput,
                            $Ctrl.Database.GetRecordSlot("Invoice"))
            }
        }

        $Ctrl.Update(0,"Delete [+] $($Ctrl.Current.Mode.Name)")

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
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidProperty,$Ctrl.Slot.GetComboBox("Uid").Name)
                $Ctrl.Xaml.IO.ViewUidProperty.SelectedIndex = 3

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewUidFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,$Null)
            }
            EditUid
            {
                # DataGrid [Upper] 
                $Ctrl.Reset($Ctrl.Xaml.IO.EditUidOutput,$Null)

                # DataGrid [Lower]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditUidRecord,$Null)
            }
            ViewClient
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientProperty,$Ctrl.Slot.GetComboBox("Client").Name)
                $Ctrl.Xaml.IO.ViewClientProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewClientFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,$Null)
            }
            EditClient
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientType,$Ctrl.Slot.Get("Client","Record").Name)
                $Ctrl.Xaml.IO.EditClientType.SelectedIndex = 2

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientStatus,$Ctrl.Slot.Get("Client","Status").Name)
                $Ctrl.Xaml.IO.EditClientStatus.SelectedIndex = 2

                # TextBox[] [Name]
                $Ctrl.Xaml.IO.EditClientGivenName.Text     = "<First>"
                $Ctrl.Xaml.IO.EditClientInitials.Text      = "<Mi>"
                $Ctrl.Xaml.IO.EditClientSurname.Text       = "<Last>"
                $Ctrl.Xaml.IO.EditClientOtherName.Text     = "<Other>"

                # TextBox[] [Location]
                $Ctrl.Xaml.IO.EditClientStreetAddress.Text = "<Address>"
                $Ctrl.Xaml.IO.EditClientCity.Text          = "<City>"
                $Ctrl.Xaml.IO.EditClientRegion.Text        = "<State>"
                $Ctrl.Xaml.IO.EditClientPostalCode.Text    = "<Postal>"

                # ComboBox [Country]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientCountry,$Ctrl.Slot.Country.Output.Name)
                $Ctrl.Xaml.IO.EditClientCountry.SelectedIndex = 238

                # ComboBox [Gender]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientGender,$Ctrl.Slot.Gender.Output.Name)
                $Ctrl.Xaml.IO.EditClientGender.SelectedIndex = 2

                # TextBox[] [D.O.B./Date of birth]
                $Ctrl.Xaml.IO.EditClientMonth.Text         = "<Month>"
                $Ctrl.Xaml.IO.EditClientDay.Text           = "<Day>"
                $Ctrl.Xaml.IO.EditClientYear.Text          = "<Year>"

                # ComboBox [Phone Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneType,$Ctrl.Slot.Phone.Output.Name)
                $Ctrl.Xaml.IO.EditClientPhoneType.SelectedIndex = 3

                # TextBox [Phone Number]
                $Ctrl.Xaml.IO.EditClientPhoneText.Text     = "<Enter phone number>"

                # ComboBox [Email Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailType,$Ctrl.Slot.Email.Output.Name)
                $Ctrl.Xaml.IO.EditClientEmailType.SelectedIndex = 3

                # TextBox [Email]
                $Ctrl.Xaml.IO.EditClientEmailText.Text     = "<Enter email address>"

                # // =================
                # // | Client/Device |
                # // =================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceProperty,$Ctrl.Slot.GetComboBox("Device").Name)
                $Ctrl.Xaml.IO.EditClientDeviceProperty.SelectedIndex = 2
                
                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditClientDeviceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceList,$Null)

                # // ================
                # // | Client/Issue |
                # // ================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueProperty,$Ctrl.Slot.GetComboBox("Issue").Name)
                $Ctrl.Xaml.IO.EditClientIssueProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditClientIssueFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueList,$Null)

                # // ==================
                # // | Client/Invoice |
                # // ==================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceProperty,$Ctrl.Slot.GetComboBox("Invoice").Name)
                $Ctrl.Xaml.IO.EditClientInvoiceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditClientInvoiceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceList,$Null)
            }
            ViewService
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceProperty,$Ctrl.Slot.GetComboBox("Service").Name)
                $Ctrl.Xaml.IO.ViewServiceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewServiceFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceOutput,$Null)
            }
            EditService
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditServiceOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditServiceType,$Ctrl.Slot.Get("Service","Record").Name)
                $Ctrl.Xaml.IO.EditServiceType.SelectedIndex = 3

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditServiceStatus,$Ctrl.Slot.Get("Service","Status").Name)
                $Ctrl.Xaml.IO.EditServiceStatus.SelectedIndex = 2

                # TextBox[] [Name, Description, Cost]
                $Ctrl.Xaml.IO.EditServiceName.Text          = "<Enter a name for the service>"
                $Ctrl.Xaml.IO.EditServiceDescription.Text   = "<Enter description of the service>"
                $Ctrl.Xaml.IO.EditServiceCost.Text          = "<Enter cost>"
            }
            ViewDevice
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceProperty,$Ctrl.Slot.GetComboBox("Device").Name)
                $Ctrl.Xaml.IO.ViewDeviceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewDeviceFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceOutput,$Null)
            }
            EditDevice
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceType,$Ctrl.Slot.Get("Device","Record").Name)
                $Ctrl.Xaml.IO.EditDeviceType.SelectedIndex = 7

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceStatus,$Ctrl.Slot.Get("Device","Status").Name)
                $Ctrl.Xaml.IO.EditDeviceStatus.SelectedIndex = 2

                # TextBox[] [Specs]
                $Ctrl.Xaml.IO.EditDeviceVendor.Text          = "<Vendor>"
                $Ctrl.Xaml.IO.EditDeviceModel.Text           = "<Model>"
                $Ctrl.Xaml.IO.EditDeviceSpecification.Text   = "<Specification>"
                $Ctrl.Xaml.IO.EditDeviceSerial.Text          = "<Enter device serial number>"

                # // =================
                # // | Device/Client |
                # // =================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceClientProperty,$Ctrl.Slot.GetComboBox("Client").Name)
                $Ctrl.Xaml.IO.EditDeviceClientProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditDeviceClientFilter.Text    = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceClientOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceClientList,$Null)
            }
            ViewIssue
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueProperty,$Ctrl.Slot.GetComboBox("Issue").Name)
                $Ctrl.Xaml.IO.ViewIssueProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewIssueFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueOutput,$Null)
            }
            EditIssue
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueType,$Ctrl.Slot.Get("Issue","Record").Name)
                $Ctrl.Xaml.IO.EditIssueType.SelectedIndex = 7

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueStatus,$Ctrl.Slot.Get("Issue","Status").Name)
                $Ctrl.Xaml.IO.EditIssueStatus.SelectedIndex = 7

                # TextBox [Description]
                $Ctrl.Xaml.IO.EditIssueDescription.Text = "<Enter description of issue>"

                # TabControl [Start]

                # // ================
                # // | Issue/Client |
                # // ================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueClientProperty,$Ctrl.Slot.GetComboBox("Issue").Name)
                $Ctrl.Xaml.IO.EditIssueClientProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditIssueClientFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueClientOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueClientList,$Null)
                
                # // ================
                # // | Issue/Device |
                # // ================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueDeviceProperty,$Ctrl.Slot.GetComboBox("Device").Name)
                $Ctrl.Xaml.IO.EditIssueDeviceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditIssueDeviceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueDeviceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueDeviceList,$Null)

                # // =================
                # // | Issue/Service |
                # // =================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueServiceProperty,$Ctrl.Slot.GetComboBox("Service").Name)
                $Ctrl.Xaml.IO.EditIssueServiceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditIssueServiceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueServiceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueServiceList,$Null)

                # // ==================
                # // | Issue/Purchase |
                # // ==================

                # Currently unused

                # // ===================
                # // | Issue/Inventory |
                # // ===================

                # Currently unused

                # TabControl [End]
            
                # DataGrid [Bottom]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueRecordList,$Null)
            }
            ViewPurchase
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseProperty,$Ctrl.Slot.GetComboBox("Purchase").Name)
                $Ctrl.Xaml.IO.ViewPurchaseProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewPurchaseFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseOutput,$Null)
            }
            EditPurchase
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseType,$Ctrl.Slot.Get("Purchase","Record").Name)
                $Ctrl.Xaml.IO.EditPurchaseType.SelectedIndex = 2

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseStatus,$Ctrl.Slot.Get("Purchase","Status").Name)
                $Ctrl.Xaml.IO.EditPurchaseStatus.SelectedIndex = 4

                # TextBox [Distributor, Cost, URL, Specs, Serial]
                $Ctrl.Xaml.IO.EditPurchaseDistributor.Text     = "<Enter distributor>"
                $Ctrl.Xaml.IO.EditPurchaseCost.Text            = "<Cost>"
                $Ctrl.Xaml.IO.EditPurchaseURL.Text             = "<Enter purchase URL>"
                $Ctrl.Xaml.IO.EditPurchaseVendor.Text          = "<Vendor>"
                $Ctrl.Xaml.IO.EditPurchaseModel.Text           = "<Model>"
                $Ctrl.Xaml.IO.EditPurchaseSpecification.Text   = "<Specification>"
                $Ctrl.Xaml.IO.EditPurchaseSerial.Text          = "<Enter device serial number>"

                # CheckBox [IsDevice]
                $Ctrl.Xaml.IO.EditPurchaseIsDevice.IsChecked   = 0

                # // ===================
                # // | Purchase/Device |
                # // ===================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseDeviceProperty,$Ctrl.Slot.GetComboBox("Device").Name)
                $Ctrl.Xaml.IO.EditPurchaseDeviceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditPurchaseDeviceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseDeviceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseDeviceList,$Null)
            }
            ViewInventory
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryProperty,$Ctrl.Slot.GetComboBox("Inventory").Name)
                $Ctrl.Xaml.IO.ViewInventoryProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewInventoryFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryOutput,$Null)
            }
            EditInventory
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryType,$Ctrl.Slot.Get("Inventory","Record").Name)
                $Ctrl.Xaml.IO.EditInventoryType.SelectedIndex = 3

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryStatus,$Ctrl.Slot.Get("Inventory","Status").Name)
                $Ctrl.Xaml.IO.EditInventoryStatus.SelectedIndex = 2

                # TextBox [Specs, Serial, Cost]
                $Ctrl.Xaml.IO.EditInventoryVendor.Text          = "<Vendor>"
                $Ctrl.Xaml.IO.EditInventoryModel.Text           = "<Model>"
                $Ctrl.Xaml.IO.EditInventorySpecification.Text   = "<Specification>"
                $Ctrl.Xaml.IO.EditInventorySerial.Text          = "<Enter device serial number>"
                $Ctrl.Xaml.IO.EditInventoryCost.Text            = "<Cost>"

                # CheckBox [IsDevice]
                $Ctrl.Xaml.IO.EditInventoryIsDevice.IsChecked   = 0

                # // ===================
                # // | Purchase/Device |
                # // ===================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryDeviceProperty,$Ctrl.Slot.GetComboBox("Device").Name)
                $Ctrl.Xaml.IO.EditInventoryDeviceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditInventoryDeviceFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryDeviceOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryDeviceList,$Null)
            }
            ViewExpense
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseProperty,$Ctrl.Slot.GetComboBox("Expense").Name)
                $Ctrl.Xaml.IO.ViewExpenseProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewExpenseFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseOutput,$Null)
            }
            EditExpense
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseType,$Ctrl.Slot.Get("Expense","Record").Name)
                $Ctrl.Xaml.IO.EditExpenseType.SelectedIndex = 3

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseStatus,$Ctrl.Slot.Get("Expense","Status").Name)
                $Ctrl.Xaml.IO.EditExpenseStatus.SelectedIndex = 2

                # TextBox [Recipient, Cost]
                $Ctrl.Xaml.IO.EditExpenseRecipient.Text = "<Enter recipient>"
                $Ctrl.Xaml.IO.EditExpenseCost.Text      = "<Cost>"

                # // ===================
                # // | Expense/Account |
                # // ===================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseAccountProperty,$Ctrl.Slot.GetComboBox("Account").Name)
                $Ctrl.Xaml.IO.EditExpenseAccountProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditExpenseAccountFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseAccountOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseAccountList,$Null)
            }
            ViewAccount
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountProperty,$Ctrl.Slot.GetComboBox("Account").Name)
                $Ctrl.Xaml.IO.ViewAccountProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewAccountFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountOutput,$Null)
            }
            EditAccount
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountType,$Ctrl.Slot.Get("Account","Record").Name)
                $Ctrl.Xaml.IO.EditAccountType.SelectedIndex = 5

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountStatus,$Ctrl.Slot.Get("Account","Status").Name)
                $Ctrl.Xaml.IO.EditAccountStatus.SelectedIndex = 2

                # TextBox [Org.]
                $Ctrl.Xaml.IO.EditAccountOrganization.Text = "<Enter Organization>"

                # // ==================
                # // | Account/Object |
                # // ==================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountObjectProperty,"<Null>")
                $Ctrl.Xaml.IO.EditAccountObjectProperty.SelectedIndex = 0

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditAccountObjectFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountObjectOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountObjectList,$Null)

            }
            ViewInvoice
            {
                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceProperty,$Ctrl.Slot.GetComboBox("Invoice").Name)
                $Ctrl.Xaml.IO.ViewInvoiceProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewInvoiceFilter.Text            = ""

                # DataGrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceOutput,$Null)
            }
            EditInvoice
            {
                # DataGrid [Top]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceOutput,$Null)

                # ComboBox [Record Type]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceType,$Ctrl.Slot.Get("Invoice","Record").Name)
                $Ctrl.Xaml.IO.EditInvoiceType.SelectedIndex = 7

                # ComboBox [Status]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceStatus,$Ctrl.Slot.Get("Invoice","Status").Name)
                $Ctrl.Xaml.IO.EditInvoiceStatus.SelectedIndex = 2

                # Start [TabControl]

                # // ==================
                # // | Invoice/Client |
                # // ==================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceClientProperty,$Ctrl.Slot.GetComboBox("Client").Name)
                $Ctrl.Xaml.IO.EditInvoiceClientProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditInvoiceClientFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceClientOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceClientList,$Null)

                # // =================
                # // | Invoice/Issue |
                # // =================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceIssueProperty,$Ctrl.Slot.GetComboBox("Issue").Name)
                $Ctrl.Xaml.IO.EditInvoiceIssueProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditInvoiceIssueFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceIssueOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceIssueList,$Null)

                # // ====================
                # // | Invoice/Purchase |
                # // ====================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoicePurchaseProperty,$Ctrl.Slot.GetComboBox("Purchase").Name)
                $Ctrl.Xaml.IO.EditInvoicePurchaseProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditInvoicePurchaseFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoicePurchaseOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoicePurchaseList,$Null)

                # // =====================
                # // | Invoice/Inventory |
                # // =====================

                # ComboBox [Property]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceInventoryProperty,$Ctrl.Slot.GetComboBox("Inventory").Name)
                $Ctrl.Xaml.IO.EditInvoiceInventoryProperty.SelectedIndex = 2

                # TextBox [Filter]
                $Ctrl.Xaml.IO.EditInvoiceInventoryFilter.Text = ""

                # DataGrid [TabControl]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceInventoryOutput,$Null)

                # ComboBox [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceInventoryList,$Null)

                # End [TabControl]

                # DataGrid [List]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceRecordList,$Null)

                # TextBox [Cost]
                $Ctrl.Xaml.IO.EditInvoiceCost.Text = "<Cost>"
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
                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewUidFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewUidProperty,
                                        $Ctrl.Xaml.IO.ViewUidFilter,
                                        $Ctrl.Database.Output,
                                        $Ctrl.Xaml.IO.ViewUidOutput)
                })

                # DataGrid [Main]
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

                # DataGrid [View]
                $Ctrl.Xaml.IO.ViewUidOutput.Add_MouseDoubleClick(
                {
                    $Index = $Ctrl.Xaml.IO.ViewUidOutput.SelectedIndex
                    If ($Index -ne -1)
                    {
                        $Ctrl.SetCurrentUid($Ctrl.Xaml.IO.ViewUidOutput.SelectedItem)
                        $Ctrl.View()
                    }
                })

                # Button [Refresh]
                $Ctrl.Xaml.IO.ViewUidRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,$Ctrl.Database.Output)
                })
            }
            EditUid
            {
                # Button [Refresh]
                $Ctrl.Xaml.IO.EditUidRecordRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.EditUidRecord,
                                $Ctrl.Property($Ctrl.Xaml.IO.EditUidOutput.Items.Record))
                })
            }
            ViewClient
            {
                # TextBox [Filter]
                $Ctrl.Xaml.IO.ViewClientFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.ViewClientProperty,
                                        $Ctrl.Xaml.IO.ViewClientFilter,
                                        $Ctrl.Database.GetRecordSlot("Client"),
                                        $Ctrl.Xaml.IO.ViewClientOutput)
                })

                # Button [Refresh]
                $Ctrl.Xaml.IO.ViewClientRefresh.Add_Click(
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,$Ctrl.Database.GetRecordSlot("Client"))
                })

                # DataGrid [Output/Single Click]
                $Ctrl.Xaml.IO.ViewClientOutput.Add_SelectionChanged(
                {
                    $Index = $Ctrl.Xaml.IO.ViewClientOutput.SelectedIndex
                    If ($Index -ne -1)
                    {
                        $Uid  = $Ctrl.Xaml.IO.ViewClientOutput.SelectedItem
                        $Item = $Ctrl.Database.Output | ? Uid -eq $Uid.Uid
                        $Ctrl.SetCurrentUid($Item)
                        
                        $Ctrl.Xaml.IO.View.IsEnabled   = 1
                        $Ctrl.Xaml.IO.Delete.IsEnabled = 1
                    }
                })

                # DataGrid [Output/Double Click]
                $Ctrl.Xaml.IO.ViewClientOutput.Add_MouseDoubleClick(
                {
                    $Index = $Ctrl.Xaml.IO.ViewClientOutput.SelectedIndex
                    If ($Index -ne -1)
                    {
                        $Ctrl.SetCurrentUid($Ctrl.Xaml.IO.ViewClientOutput.SelectedItem)
                        $Ctrl.View()
                    }
                })
            }
            EditClient
            {
                # [Type]
                $Ctrl.Xaml.IO.EditClientType.Add_SelectionChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                # [Status]
                $Ctrl.Xaml.IO.EditClientStatus.Add_SelectionChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                # [GivenName]
                $Ctrl.Xaml.IO.EditClientGivenName.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientGivenName.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientGivenName")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientGivenName.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientGivenName")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [Initials]
                $Ctrl.Xaml.IO.EditClientInitials.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientInitials.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientInitials")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                # [Surname]
                $Ctrl.Xaml.IO.EditClientSurname.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientSurname.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientSurname")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientSurname.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientSurname")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [OtherName]
                $Ctrl.Xaml.IO.EditClientOtherName.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientOtherName.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientOtherName")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                # [Street Address]
                $Ctrl.Xaml.IO.EditClientStreetAddress.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientStreetAddress.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientStreetAddress")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientStreetAddress.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientStreetAddress")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [City]
                $Ctrl.Xaml.IO.EditClientCity.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientCity.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientCity")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientCity.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientCity")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [Region]
                $Ctrl.Xaml.IO.EditClientRegion.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientRegion.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientRegion")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientRegion.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientRegion")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [Postal code]
                $Ctrl.Xaml.IO.EditClientPostalCode.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientPostalCode.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientPostalCode")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientPostalCode.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientPostalCode")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [Gender]
                $Ctrl.Xaml.IO.EditClientGender.Add_SelectionChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                # [DOB Month]
                $Ctrl.Xaml.IO.EditClientMonth.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientMonth.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientMonth")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientMonth.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientMonth")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [DOB Day]
                $Ctrl.Xaml.IO.EditClientDay.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientDay.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientDay")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientDay.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientDay")
                    If ($Ctrl.Xaml.IO.EditClientDay.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # [DOB Year]
                $Ctrl.Xaml.IO.EditClientYear.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Ctrl.CheckIdentity()
                    }
                })

                $Ctrl.Xaml.IO.EditClientYear.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientYear")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientYear.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientYear")
                    If ($Ctrl.Xaml.IO.EditClientYear.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                # Phone event handlers
                $Ctrl.Xaml.IO.EditClientPhoneText.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Item  = $Ctrl.Validation.Get("EditClientPhoneText")
                        $Item.Check()
                        $Phone = $Item.Control.Text

                        If ($Phone -match $Ctrl.Regex("Phone"))
                        {
                            $Item.Status = 1
                        }

                        If ($Item.Status -eq 1)
                        {
                            $List  = $Ctrl.Database.GetRecordSlot("Client") | ? { $_.Record.Phone.Output.Number -match $Phone }
                            $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneOutput,$List)

                            If ($Phone -notin $Ctrl.Xaml.IO.EditClientPhoneOutput)
                            {
                                If ($Phone -notin $Ctrl.Xaml.IO.EditClientPhoneList.Number)
                                {
                                    $Ctrl.Xaml.IO.EditClientPhoneAdd.IsEnabled = 1
                                }
                            }
                        }
                    }
                })

                $Ctrl.Xaml.IO.EditClientPhoneText.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientPhoneText")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientPhoneText.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientPhoneText")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientPhoneAdd.Add_Click(
                {
                    $Item = $Ctrl.Validation.Get("EditClientPhoneText")

                    $Ctrl.ClientAddPhone($Ctrl.Current.Validate,
                                         $Ctrl.Xaml.IO.EditClientPhoneType.SelectedIndex,
                                         $Item.Control.Text)
                    
                    $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneList,$Ctrl.Current.Validate.Phone.Output)

                    $Ctrl.Mode         = 0
                    $Item.Control.Text = $Item.Default
                    $Ctrl.Mode         = 1

                    If ($Ctrl.Xaml.IO.EditClientPhoneList.Items.Count -gt 0)
                    {
                        $Ctrl.Xaml.IO.EditClientPhoneRemove.IsEnabled = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientPhoneRemove.Add_Click(
                {
                    $Index = $Ctrl.Xaml.IO.EditClientPhoneList.SelectedIndex
                    If ($Index -gt -1)
                    {
                        If ($Ctrl.Xaml.IO.EditClientPhoneList.Items.Count -lt 2)
                        {
                            [System.Windows.MessageBox]::Show("Must have at least (1) phone number","Phone number [+] Error")
                        }
                        Else
                        {
                            $Ctrl.ClientRemovePhone($Ctrl.Current.Validate,$Index)
                            
                            $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneList,
                                        $Ctrl.Current.Validate.Phone.Output)
                        }
                    }
                })

                # Email event handlers
                $Ctrl.Xaml.IO.EditClientEmailText.Add_TextChanged(
                {
                    If ($Ctrl.Mode -gt 0)
                    {
                        $Item  = $Ctrl.Validation.Get("EditClientEmailText")
                        $Item.Check()
                        $Email = $Item.Control.Text

                        If ($Email -match $Ctrl.Regex("Email"))
                        {
                            $Item.Status = 1
                        }

                        If ($Item.Status -eq 1)
                        {
                            $List  = $Ctrl.Database.GetRecordSlot("Client") | ? { $_.Record.Email.Output.Number -match $Email }
                            $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailOutput,$List)

                            If ($Email -notin $Ctrl.Xaml.IO.EditClientEmailOutput)
                            {
                                If ($Email -notin $Ctrl.Xaml.IO.EditClientEmailList.Number)
                                {
                                    $Ctrl.Xaml.IO.EditClientEmailAdd.IsEnabled = 1
                                }
                            }
                        }
                    }
                })

                $Ctrl.Xaml.IO.EditClientEmailText.Add_GotFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientEmailText")
                    If ($Item.Control.Text -eq $Item.Default)
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = ""
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientEmailText.Add_LostFocus(
                {
                    $Item                  = $Ctrl.Validation.Get("EditClientEmailText")
                    If ($Item.Control.Text -eq "")
                    {
                        $Ctrl.Mode         = 0
                        $Item.Control.Text = $Item.Default
                        $Ctrl.Mode         = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientEmailAdd.Add_Click(
                {
                    $Item = $Ctrl.Validation.Get("EditClientEmailText")

                    $Ctrl.ClientAddEmail($Ctrl.Current.Validate,
                                         $Ctrl.Xaml.IO.EditClientEmailType.SelectedIndex,
                                         $Item.Control.Text)
                    
                    $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailList,$Ctrl.Current.Validate.Email.Output)

                    $Ctrl.Mode         = 0
                    $Item.Control.Text = $Item.Default
                    $Ctrl.Mode         = 1

                    If ($Ctrl.Xaml.IO.EditClientEmailList.Items.Count -gt 0)
                    {
                        $Ctrl.Xaml.IO.EditClientEmailRemove.IsEnabled = 1
                    }
                })

                $Ctrl.Xaml.IO.EditClientEmailRemove.Add_Click(
                {
                    $Index = $Ctrl.Xaml.IO.EditClientEmailList.SelectedIndex
                    If ($Index -gt -1)
                    {
                        If ($Ctrl.Xaml.IO.EditClientEmailList.Items.Count -lt 2)
                        {
                            [System.Windows.MessageBox]::Show("Must have at least (1) phone number","Email address [+] Error")
                        }
                        Else
                        {
                            $Ctrl.ClientRemoveEmail($Ctrl.Current.Validate,$Index)
                            
                            $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailList,
                                        $Ctrl.Current.Validate.Email.Output)
                        }
                    }
                })

                # [Device]
                $Ctrl.Xaml.IO.EditClientDeviceFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.EditClientDeviceProperty,
                                        $Ctrl.Xaml.IO.EditClientDeviceFilter,
                                        $Ctrl.Database.GetRecordSlot("Device"),
                                        $Ctrl.Xaml.IO.EditClientDeviceOutput)
                })

                $Ctrl.Xaml.IO.EditClientIssueFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.EditClientIssueProperty,
                                        $Ctrl.Xaml.IO.EditClientIssueFilter,
                                        $Ctrl.Database.GetRecordSlot("Issue"),
                                        $Ctrl.Xaml.IO.EditClientIssueOutput) 
                })

                $Ctrl.Xaml.IO.EditClientInvoiceFilter.Add_TextChanged(
                {
                    $Ctrl.SearchControl($Ctrl.Xaml.IO.EditClientInvoiceProperty,
                                        $Ctrl.Xaml.IO.EditClientInvoiceFilter,
                                        $Ctrl.Database.GetRecordSlot("Invoice"),
                                        $Ctrl.Xaml.IO.EditClientInvoiceOutput)
                })


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

            }
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

            }
            EditPurchase
            {

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

            }
            EditInventory
            {

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

            }
            EditExpense
            {

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

            }
            EditAccount
            {

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

            }
            EditInvoice
            {

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
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewUidPanel.Visibility       = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewUidOutput,$Ctrl.Database.Output)
            }
            EditUid
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditUidPanel.Visibility       = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditUidOutput,$Ctrl.Current.Uid)
            }
            ViewClient
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewClientPanel.Visibility    = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewClientOutput,$Ctrl.Database.GetRecordSlot("Client"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditClient
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditClientPanel.Visibility    = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditClientOutput,$Ctrl.Current.Uid)

                Switch ([UInt32]!!$Ctrl.Current.Uid)
                {
                    0
                    {
                        $Ctrl.Initial("EditClient")
                    }
                    1
                    {
                        # Select record
                        $Item = $Ctrl.Current.Uid.Record

                        # ComboBox [Record Type]
                        $Ctrl.Xaml.IO.EditClientType.SelectedIndex    = $Item.Type

                        # ComboBox [Status]
                        $Ctrl.Xaml.IO.EditClientStatus.SelectedIndex  = $Item.Status

                        # TextBox[] [Name]
                        $Ctrl.Xaml.IO.EditClientGivenName.Text        = $Item.Name.GivenName
                        $Ctrl.Xaml.IO.EditClientInitials.Text         = $Item.Name.Initials
                        $Ctrl.Xaml.IO.EditClientSurname.Text          = $Item.Name.Surname
                        $Ctrl.Xaml.IO.EditClientOtherName.Text        = $Item.Name.OtherName

                        # TextBox[] [Location]
                        $Ctrl.Xaml.IO.EditClientStreetAddress.Text    = $Item.Location.StreetAddress
                        $Ctrl.Xaml.IO.EditClientCity.Text             = $Item.Location.City
                        $Ctrl.Xaml.IO.EditClientRegion.Text           = $Item.Location.Region
                        $Ctrl.Xaml.IO.EditClientPostalCode.Text       = $Item.Location.PostalCode

                        # ComboBox [Country]
                        $Ctrl.Xaml.IO.EditClientCountry.SelectedIndex = $Item.Location.Country

                        # ComboBox [Gender]
                        $Ctrl.Xaml.IO.EditClientGender.SelectedIndex  = $Item.Gender

                        # TextBox[] [D.O.B./Date of birth]
                        $Ctrl.Xaml.IO.EditClientMonth.Text            = $Item.Dob.Dob.Substring(0,2)
                        $Ctrl.Xaml.IO.EditClientDay.Text              = $Item.Dob.Dob.Substring(3,2)
                        $Ctrl.Xaml.IO.EditClientYear.Text             = $Item.Dob.Dob.Substring(6,4)

                        # ComboBox [Phone Type]
                        $Ctrl.Xaml.IO.EditClientPhoneType.SelectedIndex = $Item.Phone.Output[0].Type

                        # DataGrid [Phone List]
                        $Ctrl.Reset($Ctrl.Xaml.IO.EditClientPhoneList,$Item.Phone.Output)

                        # ComboBox [Email Type]
                        $Ctrl.Xaml.IO.EditClientEmailType.SelectedIndex = $Item.Email.Output[0].Type

                        # DataGrid [Email List]
                        $Ctrl.Reset($Ctrl.Xaml.IO.EditClientEmailList,$Item.Email.Output)

                        # // =================
                        # // | Client/Device |
                        # // =================

                        # ComboBox [Property]
                        # $Ctrl.Xaml.IO.EditClientDeviceProperty.SelectedIndex = 2
                        
                        # TextBox [Filter]
                        # $Ctrl.Xaml.IO.EditClientDeviceFilter.Text = ""

                        # DataGrid [TabControl]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceOutput,$Null)

                        # ComboBox [List]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientDeviceList,$Null)

                        # // ================
                        # // | Client/Issue |
                        # // ================

                        # ComboBox [Property]
                        # $Ctrl.Xaml.IO.EditClientIssueProperty.SelectedIndex = 2

                        # TextBox [Filter]
                        # $Ctrl.Xaml.IO.EditClientIssueFilter.Text = ""

                        # DataGrid [TabControl]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueOutput,$Null)

                        # ComboBox [List]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientIssueList,$Null)

                        # // ==================
                        # // | Client/Invoice |
                        # // ==================

                        # ComboBox [Property]
                        # $Ctrl.Xaml.IO.EditClientInvoiceProperty.SelectedIndex = 2

                        # TextBox [Filter]
                        # $Ctrl.Xaml.IO.EditClientInvoiceFilter.Text = ""

                        # DataGrid [TabControl]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceOutput,$Null)

                        # ComboBox [List]
                        # $Ctrl.Reset($Ctrl.Xaml.IO.EditClientInvoiceList,$Null)
                    }
                }
            }
            ViewService
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewServicePanel.Visibility   = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewServiceOutput,$Ctrl.Database.GetRecordSlot("Service"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditService
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditServicePanel.Visibility   = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditServiceOutput,$Ctrl.Current.Uid)
            }
            ViewDevice
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewDevicePanel.Visibility    = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewDeviceOutput,$Ctrl.Database.GetRecordSlot("Device"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditDevice
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditDevicePanel.Visibility    = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditDeviceOutput,$Ctrl.Current.Uid)
            }
            ViewIssue
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewIssuePanel.Visibility     = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewIssueOutput,$Ctrl.Database.GetRecordSlot("Issue"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditIssue
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditIssuePanel.Visibility     = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditIssueOutput,$Ctrl.Current.Uid)
            }
            ViewPurchase
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewPurchasePanel.Visibility  = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewPurchaseOutput,$Ctrl.Database.GetRecordSlot("Purchase"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditPurchase
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditPurchasePanel.Visibility  = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditPurchaseOutput,$Ctrl.Current.Uid)
            }
            ViewInventory
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewInventoryPanel.Visibility = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInventoryOutput,$Ctrl.Database.GetRecordSlot("Inventory"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditInventory
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditInventoryPanel.Visibility = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInventoryOutput,$Ctrl.Current.Uid)
            }
            ViewExpense
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewExpensePanel.Visibility   = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewExpenseOutput,$Ctrl.Database.GetRecordSlot("Expense"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditExpense
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditExpensePanel.Visibility   = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditExpenseOutput,$Ctrl.Current.Uid)
            }
            ViewAccount
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewAccountPanel.Visibility   = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewAccountOutput,$Ctrl.Database.GetRecordSlot("Account"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditAccount
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditAccountPanel.Visibility   = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditAccountOutput,$Ctrl.Current.Uid)
            }
            ViewInvoice
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.ViewInvoicePanel.Visibility   = "Visible"

                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.ViewInvoiceOutput,$Ctrl.Database.GetRecordSlot("Invoice"))

                # Button [Menu]
                $Ctrl.Xaml.IO.New.IsEnabled                 = 1
            }
            EditInvoice
            {
                # Grid [Panel]
                $Ctrl.Xaml.IO.EditInvoicePanel.Visibility   = "Visible"
                
                # Datagrid [Main]
                $Ctrl.Reset($Ctrl.Xaml.IO.EditInvoiceOutput,$Ctrl.Current.Uid)
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
    [String] ToString()
    {
        Return "<FEModule.cimdb[Controller]>"
    }
}

# // [Instantiate the controller]
$Ctrl = [cimdbController]::New()

# // [Set to debugging mode]
$Ctrl.Module.Mode = 2

# // [Generate random client names]
ForEach ($X in 0..47)
{
    $P = $Out[$X]

    # // [Create a client object]
    $Ctrl.Current.SetValidate($Ctrl.Validate("Client"))

    # // [Set shortcut to validation object]
    $Client = $Ctrl.Current.Validate

    # // [Set up event handlers for all of the [EditClient] text fields]
    $Client.Type     = 0
    $Client.Status   = 0

    # // [Set name]
    $N = $P.Name
    $Ctrl.ClientSetName($Client,$N[0],$N[1],$N[2],$Null)

    # // [Set location]
    $A = $P.StreetAddress
    $Ctrl.ClientSetLocation($Client,$A[0],$A[1],$A[2],$A[3],$A[4])

    # // [Set gender]
    $Ctrl.ClientSetGender($Client,$P.Gender)

    # // [Set DOB]
    $D = $P.Dob
    $Ctrl.ClientSetDob($Client,$D[0],$D[1],$D[2])

    # // [Set Phone]
    $Ctrl.ClientAddPhone($Client,0,$P.Phone)

    # // [Set Email]
    $Ctrl.ClientAddEmail($Client,0,$P.Email)

    # // [Validate]
    $Ctrl.ClientValidate()

    # // [Create blank record]
    $Ctrl.Database.Add(0)

    # // [Set current Uid to that blank record]
    $Ctrl.SetCurrentUid($Ctrl.Database.Output[-1])

    # // [Insert valid properties into the record]
    $Client.SetUid($Ctrl.Current.Uid)

    # // [Clear the current UID object]
    $Ctrl.Current.Uid      = $Null

    # // [Clear the current validation object]
    $Ctrl.Current.Validate = $Null
}

$Ctrl.StageXaml()
$Ctrl.Invoke()

<#
# // [Prompts for choice to import client list into Active Directory]
$Import = (Host).UI.PromptForChoice("Import clients","Do you wish to import client list into Active Directory?",@("&No","&Yes"),0)

If ($Import)
{
    # // [Import the client list]
    $Ctrl.Adds.ImportList($Ctrl.Database.GetRecordSlot("Client"))

    # // [Create the client list]
    $Ctrl.Adds.CreateList()
}

If ($Import)
{
    # // [Prompts for choice to delete client list from Active Directory]
    $Delete = (Host).UI.PromptForChoice("Delete clients","Do you wish to delete client list from Active Directory?",@("&No","&Yes"),0)
}

If ($Delete)
{
    # // [Removes the client list from Active Directory]
    $Ctrl.Adds.RemoveList($Ctrl.Database.GetRecordSlot("Client").Record.DisplayName)
}
#>
