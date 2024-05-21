
<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ DcomUtility+ [+] 05/21/2024                                                                    ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

    FileName    : Get-DcomSecurity.ps1 (Original)
    Solution    : [FightingEntropy()][2024+]
    Purpose     : (Enumerates + Maps) [Dcom (Access + Launch) ACL Settings]
    Author      : Michael C. Cook Sr. (Originally written by Matt Pichelmayer)
    Description : This script is used to enumerate security settings based on WMI information from:
                  [+] Win32_DcomApplication
                  [+] Win32_DcomApplicationAccessAllowedSetting
                  [+] Win32_DcomApplicationLaunchAllowedSetting

                  ...for detecting potential avenues of [lateral movement] or [persistence]

                  For more information on [Dcom-based lateral movement concept], refer to: 
                  https://enigma0x3.net/2017/01/23/lateral-movement-via-dcom-round-2/

                  For more information about [Known SID]'s, refer to:
                  https://support.microsoft.com/en-us/help/243330/
                  well-known-security-identifiers-in-windows-operating-systems
#>

# $DCOM = Get-DcomSecurity

Class DcomSecurityXaml
{
    Static [String] $Content = @(
    '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
    '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
    '        Title="[Get-DcomSecurity+]"',
    '        Height="550"',
    '        Width="720"',
    '        ResizeMode="NoResize"',
    '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2024.1.0\Graphics\icon.ico"',
    '        HorizontalAlignment="Center"',
    '        WindowStartupLocation="CenterScreen"',
    '        FontFamily="Consolas"',
    '        Background="LightGray">',
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
    '            <Setter Property="FontSize" Value="10"/>',
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
    '                        Value="5"/>',
    '            <Setter Property="AutoGenerateColumns"',
    '                        Value="False"/>',
    '            <Setter Property="AlternationCount"',
    '                        Value="2"/>',
    '            <Setter Property="HeadersVisibility"',
    '                        Value="Column"/>',
    '            <Setter Property="CanUserResizeRows"',
    '                        Value="False"/>',
    '            <Setter Property="CanUserAddRows"',
    '                        Value="False"/>',
    '            <Setter Property="IsReadOnly"',
    '                        Value="True"/>',
    '            <Setter Property="IsTabStop"',
    '                        Value="True"/>',
    '            <Setter Property="IsTextSearchEnabled"',
    '                        Value="True"/>',
    '            <Setter Property="SelectionMode"',
    '                        Value="Single"/>',
    '            <Setter Property="ScrollViewer.CanContentScroll"',
    '                        Value="True"/>',
    '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
    '                        Value="Auto"/>',
    '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
    '                        Value="Auto"/>',
    '        </Style>',
    '        <Style TargetType="DataGridRow">',
    '            <Setter Property="VerticalAlignment"',
    '                        Value="Center"/>',
    '            <Setter Property="VerticalContentAlignment"',
    '                        Value="Center"/>',
    '            <Setter Property="TextBlock.VerticalAlignment"',
    '                        Value="Center"/>',
    '            <Setter Property="Height"',
    '                        Value="20"/>',
    '            <Setter Property="FontSize"',
    '                        Value="12"/>',
    '            <Style.Triggers>',
    '                <Trigger Property="AlternationIndex"',
    '                         Value="0">',
    '                    <Setter Property="Background"',
    '                            Value="White"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex" Value="1">',
    '                    <Setter Property="Background"',
    '                            Value="#FFD6FFFB"/>',
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
    '                    <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
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
    '        <Grid.RowDefinitions>',
    '            <RowDefinition Height="40"/>',
    '            <RowDefinition Height="*"/>',
    '        </Grid.RowDefinitions>',
    '        <Grid Grid.Row="0">',
    '            <Grid.ColumnDefinitions>',
    '                <ColumnDefinition Width="80"/>',
    '                <ColumnDefinition Width="10"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="10"/>',
    '                <ColumnDefinition Width="80"/>',
    '            </Grid.ColumnDefinitions>',
    '            <ComboBox Grid.Column="0"',
    '                      Name="TabSlot">',
    '                <ComboBoxItem Content="Main"/>',
    '                <ComboBoxItem Content="AppId"/>',
    '                <ComboBoxItem Content="Sid"/>',
    '            </ComboBox>',
    '            <Border Grid.Column="1"',
    '                    Style="{StaticResource Line}"/>',
    '            <Grid Grid.Column="2"',
    '                  Name="TabMain"',
    '                  Visibility="Hidden">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="75"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="25"/>',
    '                    <ColumnDefinition Width="75"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                       Content="Target:"',
    '                       Style="{StaticResource LabelRed}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="MainTarget"',
    '                         FontSize="10"/>',
    '                <Image Grid.Column="2"',
    '                       Name="MainIcon"/>',
    '                <Button Grid.Column="3"',
    '                        Name="MainConnect"',
    '                        Content="Connect"/>',
    '            </Grid>',
    '            <Grid Grid.Column="2"',
    '                  Name="TabAppId"',
    '                  Visibility="Hidden">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="75"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                </Grid.ColumnDefinitions>',
    '                <ComboBox Grid.Column="0"',
    '                          Name="AppIdSearchProperty"',
    '                          SelectedIndex="0">',
    '                    <ComboBoxItem Content="AppId"/>',
    '                    <ComboBoxItem Content="Sid"/>',
    '                    <ComboBoxItem Content="Name"/>',
    '                </ComboBox>',
    '                <TextBox Grid.Column="1"',
    '                         Name="AppIdSearchFilter"',
    '                         FontSize="10"/>',
    '            </Grid>',
    '            <Grid Grid.Column="2"',
    '                  Name="TabSid"',
    '                  Visibility="Hidden">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="75"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                </Grid.ColumnDefinitions>',
    '                <ComboBox Grid.Column="0"',
    '                          Name="SidSearchProperty"',
    '                          SelectedIndex="0">',
    '                    <ComboBoxItem Content="Sid"/>',
    '                    <ComboBoxItem Content="Name"/>',
    '                </ComboBox>',
    '                <TextBox Grid.Column="1"',
    '                         Name="SidSearchFilter"',
    '                         FontSize="10"/>',
    '            </Grid>',
    '            <Border Grid.Column="3"',
    '                    Style="{StaticResource Line}"/>',
    '            <Button Grid.Column="4"',
    '                    Name="MainRefresh"',
    '                    Content="Refresh"/>',
    '        </Grid>',
    '        <Grid Grid.Row="1"',
    '              Name="PanelMain"',
    '              Visibility="Visible">',
    '            <DataGrid Name="MainConsole"',
    '                      SelectionMode="Single">',
    '                <DataGrid.RowStyle>',
    '                    <Style TargetType="{x:Type DataGridRow}">',
    '                        <Style.Triggers>',
    '                            <Trigger Property="IsMouseOver" Value="True">',
    '                                <Setter Property="ToolTip">',
    '                                    <Setter.Value>',
    '                                        <TextBlock Text="&lt;FEModule.Console.Item&gt;"',
    '                                               TextWrapping="Wrap"',
    '                                               FontFamily="Consolas"',
    '                                               Background="#000000"',
    '                                               Foreground="#00FF00"/>',
    '                                    </Setter.Value>',
    '                                </Setter>',
    '                            </Trigger>',
    '                        </Style.Triggers>',
    '                    </Style>',
    '                </DataGrid.RowStyle>',
    '                <DataGrid.Columns>',
    '                    <DataGridTextColumn Header="#"',
    '                                        Binding="{Binding Index}"',
    '                                        Width="40"/>',
    '                    <DataGridTextColumn Header="Elapsed"',
    '                                        Binding="{Binding Elapsed}"',
    '                                        Width="120"/>',
    '                    <DataGridTextColumn Header="State"',
    '                                        Binding="{Binding State}"',
    '                                        Width="40"/>',
    '                    <DataGridTextColumn Header="Status"',
    '                                        Binding="{Binding Status}"',
    '                                        Width="*"/>',
    '                </DataGrid.Columns>',
    '            </DataGrid>',
    '        </Grid>',
    '        <Grid Grid.Row="1"',
    '              Name="PanelAppId"',
    '              Visibility="Hidden">',
    '            <Grid.RowDefinitions>',
    '                <RowDefinition Height="200"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="10"/>',
    '                <RowDefinition Height="*"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '            </Grid.RowDefinitions>',
    '            <DataGrid Grid.Row="0"',
    '                  Name="AppIdOutput">',
    '                <DataGrid.RowStyle>',
    '                    <Style TargetType="{x:Type DataGridRow}">',
    '                        <Style.Triggers>',
    '                            <Trigger Property="IsMouseOver" Value="True">',
    '                                <Setter Property="ToolTip">',
    '                                    <Setter.Value>',
    '                                        <TextBlock Text="&lt;FEModule.DcomSecurity.Application&gt;"',
    '                                               TextWrapping="Wrap"',
    '                                               FontFamily="Consolas"',
    '                                               Background="#000000"',
    '                                               Foreground="#00FF00"/>',
    '                                    </Setter.Value>',
    '                                </Setter>',
    '                            </Trigger>',
    '                        </Style.Triggers>',
    '                    </Style>',
    '                </DataGrid.RowStyle>',
    '                <DataGrid.Columns>',
    '                    <DataGridTextColumn Header="#"',
    '                                    Binding="{Binding Index}"',
    '                                    Width="30"/>',
    '                    <DataGridTextColumn Header="AppId"',
    '                                    Binding="{Binding AppId}"',
    '                                    Width="260"/>',
    '                    <DataGridTextColumn Header="Ct."',
    '                                    Binding="{Binding Count}"',
    '                                    Width="30"/>',
    '                    <DataGridTextColumn Header="Name"',
    '                                    Binding="{Binding Name}"',
    '                                    Width="*"/>',
    '                </DataGrid.Columns>',
    '            </DataGrid>',
    '            <Border Grid.Row="2"',
    '                    Style="{StaticResource Line}"/>',
    '            <Grid Grid.Row="1">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="40"/>',
    '                    <ColumnDefinition Width="10"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                       Content="Name:"',
    '                       Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="AppIdName"/>',
    '                <Label Grid.Column="2"',
    '                       Content="Count:"',
    '                       Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="3"',
    '                         Name="AppIdCount"/>',
    '            </Grid>',
    '            <DataGrid Grid.Row="3"',
    '                      Name="AppIdProperty">',
    '                <DataGrid.RowStyle>',
    '                    <Style TargetType="{x:Type DataGridRow}">',
    '                        <Style.Triggers>',
    '                            <Trigger Property="IsMouseOver" Value="True">',
    '                                <Setter Property="ToolTip">',
    '                                    <Setter.Value>',
    '                                        <TextBlock Text="{Binding Sid}"',
    '                                               TextWrapping="Wrap"',
    '                                               FontFamily="Consolas"',
    '                                               Background="#000000"',
    '                                               Foreground="#00FF00"/>',
    '                                    </Setter.Value>',
    '                                </Setter>',
    '                            </Trigger>',
    '                        </Style.Triggers>',
    '                    </Style>',
    '                </DataGrid.RowStyle>',
    '                <DataGrid.Columns>',
    '                    <DataGridTextColumn Header="#"',
    '                                        Binding="{Binding Index}"',
    '                                        Width="25"/>',
    '                    <DataGridTextColumn Header="Type"',
    '                                        Binding="{Binding Type}"',
    '                                        Width="50"/>',
    '                    <DataGridTextColumn Header="Name"',
    '                                        Binding="{Binding Name}"',
    '                                        Width="*"/>',
    '                </DataGrid.Columns>',
    '            </DataGrid>',
    '            <Grid Grid.Row="4">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="10"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                       Content="String:"',
    '                       Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="AppIdSidString"',
    '                         IsReadOnly="True"/>',
    '                <Button Grid.Column="2"',
    '                        Name="AppIdSidCopy"',
    '                        Content="Copy"/>',
    '            </Grid>',
    '            <Grid Grid.Row="5">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="80"/>',
    '                    <ColumnDefinition Width="10"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                       Content="Name:"',
    '                       Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="AppIdSidName"',
    '                         IsReadOnly="True"/>',
    '                <CheckBox Grid.Column="2"',
    '                          Name="AppIdSidDefault"',
    '                          Content="Default"',
    '                          IsChecked="False"',
    '                          HorizontalAlignment="Center"/>',
    '            </Grid>',
    '        </Grid>',
    '        <Grid Grid.Row="1"',
    '              Name="PanelSid"',
    '              Visibility="Hidden">',
    '            <Grid.RowDefinitions>',
    '                <RowDefinition Height="200"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="40"/>',
    '                <RowDefinition Height="*"/>',
    '            </Grid.RowDefinitions>',
    '            <DataGrid Grid.Row="0"',
    '                      Name="SidOutput">',
    '                <DataGrid.RowStyle>',
    '                    <Style TargetType="{x:Type DataGridRow}">',
    '                        <Style.Triggers>',
    '                            <Trigger Property="IsMouseOver" Value="True">',
    '                                <Setter Property="ToolTip">',
    '                                    <Setter.Value>',
    '                                        <TextBlock Text="{Binding String}"',
    '                             TextWrapping="Wrap"',
    '                             FontFamily="Consolas"',
    '                             Background="#000000"',
    '                             Foreground="#00FF00"/>',
    '                                    </Setter.Value>',
    '                                </Setter>',
    '                            </Trigger>',
    '                        </Style.Triggers>',
    '                    </Style>',
    '                </DataGrid.RowStyle>',
    '                <DataGrid.Columns>',
    '                    <DataGridTextColumn Header="#"',
    '                  Binding="{Binding Index}"',
    '                  Width="30"/>',
    '                    <DataGridTextColumn Header="Default"',
    '                  Binding="{Binding Default}"',
    '                  Width="50"/>',
    '                    <DataGridTextColumn Header="Name"',
    '                  Binding="{Binding Name}"',
    '                  Width="*"/>',
    '                </DataGrid.Columns>',
    '            </DataGrid>',
    '            <Grid Grid.Row="1">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="100"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="100"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                   Content="String:"',
    '                   Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="SidString"',
    '                         IsReadOnly="True"/>',
    '                <Button Grid.Column="2"',
    '                        Name="SidCopy"',
    '                        Content="Copy"/>',
    '            </Grid>',
    '            <Grid Grid.Row="2">',
    '                <Grid.ColumnDefinitions>',
    '                    <ColumnDefinition Width="100"/>',
    '                    <ColumnDefinition Width="*"/>',
    '                    <ColumnDefinition Width="100"/>',
    '                </Grid.ColumnDefinitions>',
    '                <Label Grid.Column="0"',
    '                       Content="[Name]:"',
    '                       Style="{StaticResource LabelGray}"/>',
    '                <TextBox Grid.Column="1"',
    '                         Name="SidName"',
    '                         IsReadOnly="True"/>',
    '                <CheckBox Grid.Column="2"',
    '                          Name="SidDefault"',
    '                          Content="Default"',
    '                          IsChecked="False"',
    '                          HorizontalAlignment="Center"/>',
    '            </Grid>',
    '        </Grid>',
    '    </Grid>',
    '</Window>' -join "`n")
    static [String[]] Object()
    {
        $Lines   = [DcomSecurityXaml]::Content -Split "`n"
        $C       = $Lines.Count
        $D       = "$C".Length

        $Out     = @{ } 
        ForEach ($X in 0..($Lines.Count-1))
        {
            $Out.Add($Out.Count,("{0:d$D} {1}" -f $X, $Lines[$X]))
        }

        Return $Out[0..($Out.Count-1)]
    }
}

    Class DcomSecurityMaster
    {
        [Object]          $UI
        [Object]      $Module
        [Object]    $Runspace
        [Object]        $Main
        DcomSecurityMaster()
        {
            $This.Module = Get-FEModule -Mode 1
        }
        DcomSecurityMaster([Object]$Module)
        {
            $This.Module = $Module
        }
        [Object] CreateRunspaceFactory()
        {
            Return [RunspaceFactory]::CreateRunspace()
        }
        [Object] GetDcomSecurityXaml()
        {
            Return [DcomSecurityXaml]::Content
        }
        [Object] GetDcomSecurityXamlObject()
        {
            Return [DcomSecurityXaml]::Object()
        }
        OpenRunspace()
        {
            $This.Runspace                = $This.CreateRunspaceFactory()

            $This.Runspace.ApartmentState = "STA"
            $This.Runspace.ThreadOptions  = "ReuseThread"          
            $This.Runspace.Open()
        }
        [Object] NewInitialSessionState()
        {
            Return [InitialSessionState]::CreateDefault()
        }
        InitialSessionState([Object]$Object)
        {
            $This.Runspace.SessionStateProxy.SetVariable("UI",$Object)
        }
        [String] ToString()
        {
            Return "<FEModule.DcomSecurity.Master>"
        }
    }

    $Global:UI = [Hashtable]::Synchronized(@{})
    $Ctrl      = [DcomSecurityMaster]::New()
    $Ctrl.OpenRunspace()
    $Ctrl.Runspace.SessionStateProxy.SetVariable("UI",$Global:UI)
    $Ctrl.Runspace.SessionStateProxy.SetVariable("Module",$Ctrl.Module)
    $Ctrl.Runspace.SessionStateProxy.SetVariable("Xaml",$Ctrl.GetDcomSecurityXaml())

    $psCmd     = [PowerShell]::Create().AddScript(
    {
        $Global:UI.Error     = $Error

        Class DcomSecuritySidReferenceItem
        {
            [UInt32]       $Index
            [UInt32]     $Default
            [String]      $String
            [String]        $Name
            [String] $Description
            DcomSecuritySidReferenceItem([UInt32]$Index,[String]$String)
            {
                $This.Index   = $Index
                $This.String  = $String
                $This.Default = 0
            }
            DcomSecuritySidReferenceItem([UInt32]$Index,[String]$String,[String]$Name)
            {
                $This.Index   = $Index
                $This.String  = $String
                $This.Name    = $Name
                $This.Default = 1
            }
            SetDescription([String]$Description)
            {
                $This.Description = $Description
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.SidReference.Item>"
            }
        }

        Class DcomSecuritySidReferenceList
        {
            [Object] $Output
            DcomSecuritySidReferenceList()
            {
                $This.Refresh()
            }
            Clear()
            {
                $This.Output = @( )
            }
            [Object] DcomSecuritySidReferenceItem([UInt32]$Index,[String]$String)
            {
                Return [DcomSecuritySidReferenceItem]::New($Index,$String)
            }
            [Object] DcomSecuritySidReferenceItem([UInt32]$Index,[String]$String,[String]$Name)
            {
                Return [DcomSecuritySidReferenceItem]::New($Index,$String,$Name)
            }
            [Object] GetSid([String]$Sid)
            {
                Return [System.Security.Principal.SecurityIdentifier]::New($Sid)
            }
            [String] GetNameOfSid([String]$Sid)
            {
                Try
                {
                    $Item     = $This.GetSid($Sid)
                    If ($Item)
                    {
                        $Item = $Item.Translate([System.Security.Principal.NTAccount]) | % Value
                    }
                }
                Catch
                {
                    $Item     = "<unknown>"
                }
        
                Return $Item
            }
            Add([String]$String,[String]$Name)
            {
                $Item         = $This.DcomSecuritySidReferenceItem($This.Output.Count,$String,$Name)

                If ($String -notin $This.Output.String)
                {
                    $This.Output += $Item
                }
            }
            Add([String]$String)
            {
                $Item         = $This.DcomSecuritySidReferenceItem($This.Output.Count,$String)
                $Item.Name    = $This.GetNameOfSid($String)

                If ($String -notin $This.Output.String)
                {
                    $This.Output += $Item
                }
            }
            Refresh()
            {
                $This.Clear()

                ForEach ($Item in 
                ("S-1-0"                      , "Null Authority"),
                ("S-1-0-0"                    , "Nobody"),
                ("S-1-1"                      , "World Authority"),
                ("S-1-1-0"                    , "Everyone"),
                ("S-1-2"                      , "Local Authority"),
                ("S-1-2-0"                    , "Local"),
                ("S-1-2-1"                    , "Console Logon"),
                ("S-1-3"                      , "Creator Authority"),
                ("S-1-3-0"                    , "Creator Owner"),
                ("S-1-3-1"                    , "Creator Group"),
                ("S-1-3-2"                    , "Creator Owner Server"),
                ("S-1-3-3"                    , "Creator Group Server"),
                ("S-1-3-4 Name: Owner Rights" , "SID: S-1-3-4 Owner Rights"),
                ("S-1-5-80-0"                 , "All Services"),
                ("S-1-4"                      , "Non-unique Authority"),
                ("S-1-5"                      , "NT Authority"),
                ("S-1-5-1"                    , "Dialup"),
                ("S-1-5-2"                    , "Network"),
                ("S-1-5-3"                    , "Batch"),
                ("S-1-5-4"                    , "Interactive"),
                ("S-1-5-5-X-Y"                , "Logon Session"),
                ("S-1-5-6"                    , "Service"),
                ("S-1-5-7"                    , "Anonymous"),
                ("S-1-5-8"                    , "Proxy"),
                ("S-1-5-9"                    , "Enterprise Domain Controllers"),
                ("S-1-5-10"                   , "Principal Self"),
                ("S-1-5-11"                   , "Authenticated Users"),
                ("S-1-5-12"                   , "Restricted Code"),
                ("S-1-5-13"                   , "Terminal Server Users"),
                ("S-1-5-14"                   , "Remote Interactive Logon"),
                ("S-1-5-15"                   , "This Organization"),
                ("S-1-5-17"                   , "This Organization"),
                ("S-1-5-18"                   , "Local System"),
                ("S-1-5-19"                   , "NT Authority"),
                ("S-1-5-20"                   , "NT Authority"),
                ("S-1-5-21domain-500"         , "Administrator"),
                ("S-1-5-21domain-501"         , "Guest"),
                ("S-1-5-21domain-502"         , "KRBTGT"),
                ("S-1-5-21domain-512"         , "Domain Admins"),
                ("S-1-5-21domain-513"         , "Domain Users"),
                ("S-1-5-21domain-514"         , "Domain Guests"),
                ("S-1-5-21domain-515"         , "Domain Computers"),
                ("S-1-5-21domain-516"         , "Domain Controllers"),
                ("S-1-5-21domain-517"         , "Cert Publishers"),
                ("S-1-5-21root domain-518"    , "Schema Admins"),
                ("S-1-5-21root domain-519"    , "Enterprise Admins"),
                ("S-1-5-21domain-520"         , "Group Policy Creator Owners"),
                ("S-1-5-21domain-526"         , "Key Admins"),
                ("S-1-5-21domain-527"         , "Enterprise Key Admins"),
                ("S-1-5-21domain-553"         , "RAS and IAS Servers"),
                ("S-1-5-32-544"               , "Administrators"),
                ("S-1-5-32-545"               , "Users"),
                ("S-1-5-32-546"               , "Guests"),
                ("S-1-5-32-547"               , "Power Users"),
                ("S-1-5-32-548"               , "Account Operators"),
                ("S-1-5-32-549"               , "Server Operators"),
                ("S-1-5-32-550"               , "Print Operators"),
                ("S-1-5-32-551"               , "Backup Operators"),
                ("S-1-5-32-552"               , "Replicators"),
                ("S-1-5-64-10"                , "NTLM Authentication"),
                ("S-1-5-64-14"                , "SChannel Authentication"),
                ("S-1-5-64-21"                , "Digest Authentication"),
                ("S-1-5-80"                   , "NT Service"),
                ("S-1-5-83-0"                 , "NT VIRTUAL MACHINE\Virtual Machines"),
                ("S-1-16-0"                   , "Untrusted Mandatory Level"),
                ("S-1-16-4096"                , "Low Mandatory Level"),
                ("S-1-16-8192"                , "Medium Mandatory Level"),
                ("S-1-16-8448"                , "Medium Plus Mandatory Level"),
                ("S-1-16-12288"               , "High Mandatory Level"),
                ("S-1-16-16384"               , "System Mandatory Level"),
                ("S-1-16-20480"               , "Protected Process Mandatory Level"),
                ("S-1-16-28672"               , "Secure Process Mandatory Level"),
                ("S-1-5-32-554"               , "BUILTIN\Pre-Windows 2000 Compatible Access"),
                ("S-1-5-32-555"               , "BUILTIN\Remote Desktop Users"),
                ("S-1-5-32-556"               , "BUILTIN\Network Configuration Operators"),
                ("S-1-5-32-557"               , "BUILTIN\Incoming Forest Trust Builders"),
                ("S-1-5-32-558"               , "BUILTIN\Performance Monitor Users"),
                ("S-1-5-32-559"               , "BUILTIN\Performance Log Users"),
                ("S-1-5-32-560"               , "BUILTIN\Windows Authorization Access Group"),
                ("S-1-5-32-561"               , "BUILTIN\Terminal Server License Servers"),
                ("S-1-5-32-562"               , "BUILTIN\Distributed COM Users"),
                ("S-1-5- 21domain -498"       , "Enterprise Read-only Domain Controllers"),
                ("S-1-5- 21domain -521"       , "Read-only Domain Controllers"),
                ("S-1-5-32-569"               , "BUILTIN\Cryptographic Operators"),
                ("S-1-5-21 domain -571"       , "Allowed RODC Password Replication Group"),
                ("S-1-5- 21 domain -572"      , "Denied RODC Password Replication Group"),
                ("S-1-5-32-573"               , "BUILTIN\Event Log Readers"),
                ("S-1-5-32-574"               , "BUILTIN\Certificate Service Dcom Access"),
                ("S-1-5-21-domain-522"        , "Cloneable Domain Controllers"),
                ("S-1-5-32-575"               , "BUILTIN\RDS Remote Access Servers"),
                ("S-1-5-32-576"               , "BUILTIN\RDS Endpoint Servers"),
                ("S-1-5-32-577"               , "BUILTIN\RDS Management Servers"),
                ("S-1-5-32-578"               , "BUILTIN\Hyper-V Administrators"),
                ("S-1-5-32-579"               , "BUILTIN\Access Control Assistance Operators"),
                ("S-1-5-32-580"               , "BUILTIN\Remote Management Users"))
                {
                    $This.Add($Item[0],$Item[1])
                }

                $This.Sort()
            }
            Sort()
            {
                $This.Output  = $This.Output | Sort-Object Name

                $C = 0
                ForEach ($Item in $This.Output)
                {
                    $Item.Index = $C
                    $C ++
                }
            }
            Numerate()
            {
                $Unknown = $This.Output | ? Name -match "\<unknown(\[\d+\])*\>"
                $C       = 0
                $D       = ([String]$Unknown.Count).Length

                ForEach ($Item in $Unknown)
                {
                    $Item.Name = "<unknown[{0:d$D}]>" -f $C
                    $C ++
                }

                $This.Sort()
            }
            [Object] GetByString([String]$String)
            {
                $Item = $This.Output | ? String -eq $String

                Return @($Null,$Item)[[UInt32]!!$Item]
            }
            [Object] GetByName([String]$Name)
            {
                $Item = $This.Output | ? Name -eq $Name
                
                Return @($Null,$Item)[[UInt32]!!$Item]
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.SidReference.List>"
            }
        }

        Class DcomSecurityApplicationProperty
        {
            [UInt32] $Index
            [String]  $Type
            [UInt32]  $Rank
            [String]   $Sid
            [String]  $Name
            DcomSecurityApplicationProperty([UInt32]$Index,[Object]$Reference)
            {
                $This.Index     = $Index
                $This.Type      = $Reference.Type
                $This.Rank      = $Reference.Rank
                $This.Sid       = $Reference.Sid
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.Application.Property>"
            }
        }

        Class DcomSecurityApplication
        {
            [UInt32]       $Index
            [String]       $AppId
            [UInt32]       $Count
            [String]        $Name
            [Object]    $Property
            DcomSecurityApplication([UInt32]$Index,[Object]$Wmi)
            {
                $This.Index       = $Index
                $This.AppId       = $Wmi.AppId.ToLower()
                $This.Name        = @("<null>",$Wmi.Name)[[UInt32]!!$Wmi.Name]

                $This.Clear()
            }
            Clear()
            {
                $This.Property    = @( )
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.Application>"
            }
        }
    
        Enum DcomSecurityType
        {
            Win32_DcomApplication
            Win32_DcomApplicationAccessAllowedSetting
            Win32_DcomApplicationLaunchAllowedSetting
        }

        Class DcomSecurityReference
        {
            [String]     $Type
            [UInt32]     $Rank
            [String]    $AppId
            [String]      $Sid
            DcomSecurityReference([String]$Type,[UInt32]$Rank,[Object]$Wmi)
            {
                $This.Type        = $Type
                $This.Rank        = $Rank
                $This.AppId       = [Regex]::Matches($Wmi.Element,"\{.+\}").Value.ToLower()
                $This.Sid         = [Regex]::Matches($Wmi.Setting,'\".+\"').Value.Trim('"')
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.Reference>"
            }
        }

        Class DcomSecurityRunspace
        {
            [Object]       $Module
            [String] $ComputerName
            [Object]    $Reference
            [Object]  $Application
            [Object]       $Access
            [Object]       $Launch
            DcomSecurityRunspace([Object]$Module)
            {
                $This.Module       = $Module
                $This.ComputerName = $This.GetHostName()
            }
            Update([Int32]$State,[String]$Status)
            {
                $This.Module.Update($State,$Status)
            }
            [String] GetHostname()
            {
                Return [Environment]::MachineName.ToLower()
            }
            [String] GetPath([String]$Name)
            {
                Return "\\{0}\ROOT\CIMV2:$Name" -f $This.ComputerName
            }
            [Object[]] GetInstances([String]$Path)
            {
                Return @([WmiClass]::New($Path).GetInstances())
            }
            [Object] DcomSecuritySidReferenceList()
            {
                Return [DcomSecuritySidReferenceList]::New()
            }
            [Object] DcomSecurityApplication([UInt32]$Index,[Object]$Instance)
            {
                Return [DcomSecurityApplication]::New($Index,$Instance)
            }
            [Object] DcomSecurityApplicationProperty([UInt32]$Index,[Object]$Reference)
            {
                Return [DcomSecurityApplicationProperty]::New($Index,$Reference)
            }
            [Object] DcomSecurityReference([String]$Type,[UInt32]$Index,[Object]$Instance)
            {
                Return [DcomSecurityReference]::New($Type,$Index,$Instance)
            }
            [Object[]] GetDcomApplication()
            {
                $Name = [DcomSecurityType]0
                $Path = $This.GetPath($Name)
                $Out  = @{ }
        
                [Console]::WriteLine("Retrieving [~] $Name")
        
                $X    = 0
                ForEach ($Instance in $This.GetInstances($Path))
                {
                    $Item = $This.DcomSecurityApplication($Out.Count,$Instance)
        
                    If ($Item.Name -match "\<null(\[\d+\])*\>")
                    {
                        $Item.Name = "<null[{0}]>" -f $X
                        $X ++
                    }
        
                    $Out.Add($Out.Count,$Item)
                }
        
                Return $Out[0..($Out.Count-1)]
            }
            [Object[]] GetDcomApplicationAccessSetting()
            {
                $Name = [DcomSecurityType]1
                $Path = $This.GetPath($Name)
                $Out  = @{ }
        
                [Console]::WriteLine("Retrieving [~] $Name")
        
                ForEach ($Instance in $This.GetInstances($Path))
                {
                    $Item = $This.DcomSecurityReference("Access",$Out.Count,$Instance)
                    $Out.Add($Out.Count,$Item)
                }
        
                Return $Out[0..($Out.Count-1)]
            }
            [Object[]] GetDcomApplicationLaunchSetting()
            {
                $Name = [DcomSecurityType]2
                $Path = $This.GetPath($Name)
                $Out  = @{ }
        
                [Console]::WriteLine("Retrieving [~] $Name")
        
                ForEach ($Instance in $This.GetInstances($Path))
                {
                    $Item = $This.DcomSecurityReference("Launch",$Out.Count,$Instance)
                    $Out.Add($Out.Count,$Item)
                }
        
                Return $Out[0..($Out.Count-1)]
            }
            [String] TargetIcon([UInt32]$Value)
            {
                Return $This.Module._Control(@("success.png","warning.png")[$Value]).Fullname
            }
            AppIdSidSet([Object]$UI,[Object]$Item)
            {
                If (!!$Item.String)
                {
                    $UI.AppIdSidString.Text       = $Item.String
                    $UI.AppIdSidCopy.IsEnabled    = 1
        
                    $UI.AppIdSidName.Text         = $Item.Name
                    $UI.AppIdSidDefault.IsChecked = $Item.Default
                }
                Else
                {
                    $UI.AppIdSidString.Text       = ""
                    $UI.AppIdSidCopy.IsEnabled    = 0
        
                    $UI.AppIdSidName.Text         = ""
                    $UI.AppIdSidDefault.IsChecked = 0
                }
            }
            AppIdSearchFilter([Object]$UI)
            {
                $Text = $This.Escape($UI.AppIdSearchFilter.Text)
                    
                $List = Switch -Regex ($Text)
                {
                    "^$"
                    {
                        $This.Application
                    }
                    Default
                    {
                        Switch ($UI.AppIdSearchProperty.Text)
                        {
                            AppId
                            {
                                $This.Application | ? AppId -match $Text
                            }
                            Name
                            {
                                $This.Application | ? Name -match $Text
                            }
                            Sid
                            {
                                $This.Application | ? { $_.Property.Sid -match $Text }
                            }
                        }
                    }
                }
                
                $This.Reset($UI.AppIdOutput,$List)
                $This.Reset($UI.AppIdProperty,$Null)
                $This.AppIdSidSet($UI,$Null)
            }
            AppIdOutput([Object]$UI)
            {
                $Index = $UI.AppIdOutput.SelectedIndex
                $This.SidSet($UI,$Null)
        
                If ($Index -ne -1)
                {
                    $Item = $This.Application | ? AppId -eq $UI.AppIdOutput.SelectedItem.AppId
        
                    $UI.AppIdSidString.IsEnabled    = 1
                    $UI.AppIdSidCopy.IsEnabled      = 1
                    $UI.AppIdSidName.IsEnabled      = 1
                    $UI.AppIdSidDefault.IsEnabled   = 1
        
                    $UI.AppIdName.Text              = $Item.Name
                    $UI.AppIdCount.Text             = $Item.Count
        
                    $This.Reset($UI.AppIdProperty,$Item.Property)
                    $UI.AppIdProperty.SelectedIndex = 0
                }
                Else
                {
                    $UI.AppIdSidString.IsEnabled    = 0
                    $UI.AppIdSidCopy.IsEnabled      = 0
                    $UI.AppIdSidName.IsEnabled      = 0
                    $UI.AppIdSidDefault.IsEnabled   = 0
        
                    $UI.AppIdName.Text              = ""
                    $UI.AppIdCount.Text             = 0
        
                    $This.Reset($UI.AppIdProperty,$Null)
                }
            }
            AppIdProperty([Object]$UI)
            {
                If ($UI.AppIdProperty.SelectedIndex -ne -1)
                {
                    $Item = $This.Reference.Output | ? String -eq $UI.AppIdProperty.SelectedItem.Sid
        
                    $This.AppIdSidSet($UI,$Item)
                }
                Else
                {
                    $This.AppIdSidSet($UI,$Null)
                }
            }
            AppIdSidCopy([Object]$UI)
            {
                $UI.AppIdSidString.Text | Set-Clipboard
            }
            SidOutput([Object]$UI)
            {
                $Item = $This.Reference.Output | ? String -match $UI.SidOutput.SelectedItem.String
        
                $This.SidSet($UI,$Item)
            }
            SidSearchFilter([Object]$UI)
            {        
                $Text = $This.Escape($UI.SidSearchFilter.Text)
                    
                $List = Switch -Regex ($Text)
                {
                    "^$"
                    {
                        $This.Reference.Output
                    }
                    Default
                    {
                        Switch ($UI.SidSearchProperty.Text)
                        {
                            Name
                            {
                                $This.Reference.Output | ? Name -match $Text
                            }
                            Sid
                            {
                                $This.Reference.Output | ? String -match $Text
                            }
                        }
                    }
                }
                
                $This.Reset($UI.SidOutput,$List)
                $This.SidSet($UI,$Null)
            }
            SidSet([Object]$UI,[Object]$Item)
            {
                If (!!$Item.String)
                {
                    $UI.SidString.Text            = $Item.String
                    $UI.SidCopy.IsEnabled         = 1
        
                    $UI.SidName.Text              = $Item.Name
                    $UI.SidDefault.IsChecked      = $Item.Default
                }
                Else
                {
                    $UI.SidString.Text            = ""
                    $UI.SidCopy.IsEnabled         = 1
        
                    $UI.SidName.Text              = ""
                    $UI.SidDefault.IsChecked      = 0
                }
            }
            SidCopy([Object]$UI)
            {
                $UI.SidString.Text | Set-Clipboard
            }
            UpdateConsole([Object]$Global:UI)
            {
                $Ctrl = $This

                $Global:UI.Window.Dispatcher.Invoke(
                [Action]{

                    ForEach ($Item in $Ctrl.Module.Console.Output | ? Index -notin $Global:UI.MainConsole.Items.Index)
                    {
                        $Global:UI.MainConsole.Items.Add($Item)
                    }

                    $Global:UI.MainConsole.SelectedIndex = $Global:UI.MainConsole.Items.Count - 1
                    $Global:UI.MainConsole.ScrollIntoView($Global:UI.MainConsole.SelectedItem)

                }, "Background")
            }
            Resolve()
            {
                ForEach ($AppId in $This.Application)
                {
                    $Status = $This.ProgressString($AppId)
                    $This.Update(0,$Status)
        
                    $Hash   = @{ }
                    $Filter = @($This.Access;$This.Launch) | ? AppId -eq $AppId.AppId
                    ForEach ($Item in $Filter)
                    {
                        $Object      = $This.DcomSecurityApplicationProperty($Hash.Count,$Item)
                        $Object.Name = $This.Reference.GetByString($Object.Sid).Name
                        $Hash.Add($Hash.Count,$Object)
                    }
        
                    $AppId.Count     = $Hash.Count
                    $AppId.Property  = Switch ($Hash.Count)
                    {
                        0       { @( )                         }
                        1       { @($Hash[0])                  }
                        Default { @($Hash[0..($Hash.Count-1)]) }
                    }
                }
            }
            Reset([Object]$xSender,[Object[]]$Object)
            {
                $xSender.Items.Clear()
                ForEach ($Item in $Object)
                {
                    $xSender.Items.Add($Item)
                }
            }
            [String] Escape([String]$Entry)
            {
                Return [Regex]::Escape($Entry)
            }
            [String] ProgressString([Object]$AppId)
            {
                Return "Processing [~] {0} {1:p}" -f $AppId.AppId, (($AppId.Index+1)/$This.Application.Count)
            }
            [String] ToString()
            {
                Return "<FEModule.DcomSecurity.Runspace>"
            }
        }

        # Prime the (Xaml/Window)
        Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

        $Names               = [Regex]::Matches($Xaml,"( Name\=\`"\w+`")").Value -Replace "( Name=|`")",""
        $Node                = [System.Xml.XmlNodeReader]::New([Xml]$Xaml)
        $Global:UI.Window    = [Windows.Markup.XamlReader]::Load($Node)

        # Assign each UI component to the $Global:UI
        ForEach ($Name in $Names)
        {
            $Global:UI."$Name" = $Global:UI.Window.FindName($Name)
        }

        $Main = [DcomSecurityRunspace]::New($Module)
        # $Ctrl.Main = [DcomSecurityRunspace]::New($Module)

        # Add EventHandlers

        # <Main Tab Control>
        $Global:UI.TabSlot.Add_SelectionChanged(
        {
            $Global:UI.TabMain.Visibility    = "Hidden"
            $Global:UI.PanelMain.Visibility  = "Hidden"
                
            $Global:UI.TabAppId.Visibility   = "Hidden"
            $Global:UI.PanelAppId.Visibility = "Hidden"
                
            $Global:UI.TabSid.Visibility     = "Hidden"
            $Global:UI.PanelSid.Visibility   = "Hidden"
                
            Switch ($Global:UI.TabSlot.SelectedIndex)
            {
                0
                {
                    $Global:UI.TabMain.Visibility    = "Visible"
                    $Global:UI.PanelMain.Visibility  = "Visible"
                }
                1
                {
                    $Global:UI.TabAppId.Visibility   = "Visible"
                    $Global:UI.PanelAppId.Visibility = "Visible"
                }
                2
                {
                    $Global:UI.TabSid.Visibility     = "Visible"
                    $Global:UI.PanelSid.Visibility   = "Visible"
                }
            }
        })

        <# Main Tab
             2 MainTarget          TextBox  System.Windows.Controls.TextBox
             3 MainIcon            Image    System.Windows.Controls.Image
             4 MainConnect         Button   System.Windows.Controls.Button: Connect
            11 MainRefresh         Button   System.Windows.Controls.Button: Refresh #>
    
        $Global:UI.MainTarget.Add_TextChanged(
        {
            If ($Global:UI.MainTarget.Text -notmatch "^$")
            {
                Start-Sleep -Milliseconds 25
            }
    
            If ($Global:UI.MainTarget.Text -ne $Main.ComputerName)
            {
                $Main.ComputerName = $Global:UI.MainTarget.Text
            }
        })
    
        $Global:UI.MainConnect.Add_Click(
        {
            $Test = Test-Connection $Main.ComputerName -Count 1 -TimeToLive 250
            
            If ($Test)
            {
                $Global:UI.MainTarget.IsEnabled  = 0
                $Global:UI.MainConnect.IsEnabled = 0
                $Global:UI.MainIcon.Source       = $Main.TargetIcon(0)
                $Main.ComputerName               = [System.Net.Dns]::Resolve($Test.IPV4Address).HostName
            }
            Else
            {
                $Global:UI.MainTarget.IsEnabled  = 1
                $Global:UI.MainConnect.IsEnabled = 1
                $Global:UI.MainIcon.Source       = $Main.TargetIcon(1)
                $Main.ComputerName               = $Main.GetHostname()
            }
    
            $Global:UI.MainTarget.Text           = $Main.ComputerName
        })
    
        $Global:UI.MainRefresh.Add_Click(
        {
            # Initial
            $Main.Update(0,"Loading [~] Dcom properties for "[$($Main.ComputerName)])
            $Main.UpdateConsole($Global:UI)

            $Main.Update(0,"Getting [~] Sid Reference List")
            $Main.UpdateConsole($Global:UI)

            $Main.Reference    = $Main.DcomSecuritySidReferenceList()
        
            # Populate all properties
            $Main.Update(0,"Getting [~] DcomApplication")
            $Main.UpdateConsole($Global:UI)
            $Main.Application  = $Main.GetDcomApplication()

            $Main.Update(0,"Getting [~] DcomApplicationAccessAllowedSetting")
            $Main.UpdateConsole($Global:UI)
            $Main.Access       = $Main.GetDcomApplicationAccessSetting()

            $Main.Update(0,"Getting [~] DcomApplicationLaunchAllowedSetting")
            $Main.UpdateConsole($Global:UI)
            $Main.Launch       = $Main.GetDcomApplicationLaunchSetting()
        
            # Ensure that ALL unique SID references are resolved
            $Filter            = @($Main.Access;$Main.Launch) | % Sid | Select-Object -Unique | ? { $_ -notin $Main.Reference.Output.String } | Sort-Object
        
            ForEach ($Item in $Filter)
            {
                $Main.Reference.Add($Item)
            }
        
            $Main.Reference.Numerate()
            $Main.Reset($Global:UI.SidOutput,$Main.Reference.Output)

            ForEach ($AppId in $Main.Application)
            {
                $Status = $Main.ProgressString($AppId)
                $Main.Update(0,$Status)
                $Main.UpdateConsole($Global:UI)
    
                $Hash   = @{ }
                $Filter = @($Main.Access;$Main.Launch) | ? AppId -eq $AppId.AppId
                ForEach ($Item in $Filter)
                {
                    $Object      = $Main.DcomSecurityApplicationProperty($Hash.Count,$Item)
                    $Object.Name = $Main.Reference.GetByString($Object.Sid).Name
                    $Hash.Add($Hash.Count,$Object)
                }
    
                $AppId.Count     = $Hash.Count
                $AppId.Property  = Switch ($Hash.Count)
                {
                    0       { @( )                         }
                    1       { @($Hash[0])                  }
                    Default { @($Hash[0..($Hash.Count-1)]) }
                }
            }

            $Main.Reset($Global:UI.AppIdOutput,$Main.Application)
        
            $Global:UI.AppIdSearchProperty.IsEnabled = 1
            $Global:UI.AppIdSearchFilter.IsEnabled   = 1
            $Global:UI.AppIdOutput.IsEnabled         = 1
            $Global:UI.AppIdProperty.IsEnabled       = 1
    
            # AppIdOutput
            $Global:UI.AppIdOutput.Items.Clear()
            ForEach ($Item in $Main.Application)
            {
                $Global:UI.AppIdOutput.Items.Add($Item)
            }

            # AppIdProperty
            $Main.Reset($Global:UI.AppIdProperty,$Null)
            $Main.AppIdSidSet($Global:UI,$Null)
    
            $Global:UI.SidSearchProperty.IsEnabled   = 1
            $Global:UI.SidSearchFilter.IsEnabled     = 1
            $Global:UI.SidOutput.IsEnabled           = 1
    
            $Main.Reset($Global:UI.SidOutput,$Main.Reference.Output)
        })
    
        <# Main Panel
            12 MainPanel           Grid     System.Windows.Controls.Grid #>
    
        <# AppId Tab
             6 AppIdSearchProperty ComboBox System.Windows.Controls.ComboBox Items.Count:3
             7 AppIdSearchFilter   TextBox  System.Windows.Controls.TextBox #>
    
        $Global:UI.AppIdSearchFilter.Add_TextChanged(
        {
            $Main.AppIdSearchFilter($Global:UI)
        })
        
        $Global:UI.AppIdSearchProperty.Add_SelectionChanged(
        {
            $Global:UI.AppIdSearchFilter.Text = ""
        })
    
        <# AppId Panel
            13 AppIdPanel          Grid     System.Windows.Controls.Grid
            14 AppIdOutput         DataGrid System.Windows.Controls.DataGrid Items.Count:0
            15 AppIdName           TextBox  System.Windows.Controls.TextBox
            16 AppIdCount          TextBox  System.Windows.Controls.TextBox
            17 AppIdProperty       DataGrid System.Windows.Controls.DataGrid Items.Count:0
            18 AppIdSidString      TextBox  System.Windows.Controls.TextBox
            19 AppIdSidCopy        Button   System.Windows.Controls.Button: Copy
            20 AppIdSidName        TextBox  System.Windows.Controls.TextBox
            21 AppIdSidDefault     CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False #>
    
        $Global:UI.AppIdOutput.Add_SelectionChanged(
        {
            $Main.AppIdOutput($Global:UI)
        })
    
        $Global:UI.AppIdProperty.Add_SelectionChanged(
        {
            $Main.AppIdProperty($Global:UI)
        })
    
        $Global:UI.AppIdSidString.Add_TextChanged(
        {
            $Global:UI.AppIdSidCopy.IsEnabled = [UInt32]($Global:UI.AppIdSidString.Text -notmatch "^$")
        })
    
        $Global:UI.AppIdSidCopy.Add_Click(
        {
            $Main.AppIdSidCopy($Global:UI)
        })
    
        <# Sid Tab
             9 SidSearchProperty   ComboBox System.Windows.Controls.ComboBox Items.Count:2
            10 SidSearchFilter     TextBox  System.Windows.Controls.TextBox #>
            
        $Global:UI.SidSearchFilter.Add_TextChanged(
        {
            $Main.SidSearchFilter($Global:UI)
        })
        
        $Global:UI.SidSearchProperty.Add_SelectionChanged(
        {
            $Global:UI.AppIdSearchFilter.Text = ""
        })
    
        <#
           Sid Panel
            22 SidPanel            Grid     System.Windows.Controls.Grid
            23 SidOutput           DataGrid System.Windows.Controls.DataGrid Items.Count:0
            24 SidString           TextBox  System.Windows.Controls.TextBox
            25 SidCopy             Button   System.Windows.Controls.Button: Copy
            26 SidName             TextBox  System.Windows.Controls.TextBox
            27 SidDefault          CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False #>
    
        $Global:UI.SidOutput.Add_SelectionChanged(
        {
            $Main.SidOutput($Global:UI)
        })
            
        $Global:UI.SidString.Add_TextChanged(
        {
            $Global:UI.SidCopy.IsEnabled = [UInt32]($Global:UI.SidString.Text -notmatch "^$")
        })
    
        $Global:UI.SidCopy.Add_Click(
        {
            $Main.SidCopy($Global:UI)
        })

        # Add initial settings
        $Global:UI.MainTarget.Text       = $Main.ComputerName
        $Global:UI.TabSlot.SelectedIndex = 0

        $Global:UI.Window.ShowDialog() | Out-Null # <- Important that it is not using InvokeAsync({ $This.IO.ShowDialog() }).Wait()
    })

    $psCmd.Runspace = $Ctrl.Runspace
    $Handle         = $psCmd.BeginInvoke()

    <#
    $Runspace                = [RunspaceFactory]::CreateRunspace()
    $Runspace.ApartmentState = "STA"
    $Runspace.ThreadOptions  = "ReuseThread"          
    $Runspace.Open()
    $Runspace.SessionStateProxy.SetVariable("UI",$Global:UI)

    Class DcomSecurityController
    {
        [Object]       $Module
        [Object]         $Xaml
        [String] $ComputerName
        [Object]    $Reference
        [Object]  $Application
        [Object]       $Access
        [Object]       $Launch
        DcomSecurityController()
        {
            # Load module
            $This.Module = Get-FEModule -Mode 1
        }
        DcomSecurityController([Object]$Module)
        {
            # Set module
            $This.Module = $Module
        }
        [String] GetHostname()
        {
            Return [Environment]::MachineName.ToLower()
        }
        [Object] GetSidReferenceList()
        {
            Return [DcomSecuritySidReferenceList]::New()
        }
        [String[]] GetDcomSecurityType()
        {
            Return [System.Enum]::GetNames([DcomSecurityType])
        }
        [String] GetPath([String]$Name)
        {
            Return "\\{0}\ROOT\CIMV2:$Name" -f $This.ComputerName
        }
        [Object[]] GetInstances([String]$Path)
        {
            Return @([WmiClass]::New($Path).GetInstances())
        }
        [Object] DcomSecurityApplication([UInt32]$Index,[Object]$Wmi)
        {
            Return [DcomSecurityApplication]::New($Index,$Wmi)
        }
        [Object] DcomSecurityApplicationProperty([UInt32]$Index,[Object]$Reference)
        {
            Return [DcomSecurityApplicationProperty]::New($Index,$Reference)
        }
        [Object] DcomSecurityReference([String]$Type,[UInt32]$Rank,[Object]$Wmi)
        {
            Return [DcomSecurityReference]::New($Type,$Rank,$Wmi)
        }
        [Object] GetDcomSecurityXaml()
        {
            Return [RunspaceXaml][DcomSecurityXaml]::Content
        }
        Main()
        {
            # Initial
            $This.Reference    = $This.GetSidReferenceList()
    
            # Populate all properties
            $This.Application  = $This.GetDcomApplication()
            $This.Access       = $This.GetDcomApplicationAccessSetting()
            $This.Launch       = $This.GetDcomApplicationLaunchSetting()
    
            # Ensure that ALL unique SID references are resolved
            $Filter            = @($This.Access;$This.Launch) | % Sid | Select-Object -Unique | ? { $_ -notin $This.Reference.Output.String } | Sort-Object
    
            ForEach ($Item in $Filter)
            {
                $This.Reference.Add($Item)
            }
    
            $This.Reference.Numerate()
    
            $This.Resolve()
        }
        [Object[]] GetDcomApplication()
        {
            $Name = [DcomSecurityType]0
            $Path = $This.GetPath($Name)
            $Out  = @{ }
    
            [Console]::WriteLine("Retrieving [~] $Name")
    
            $X    = 0
            ForEach ($Instance in $This.GetInstances($Path))
            {
                $Item = $This.DcomSecurityApplication($Out.Count,$Instance)
    
                If ($Item.Name -match "\<null(\[\d+\])*\>")
                {
                    $Item.Name = "<null[{0}]>" -f $X
                    $X ++
                }
    
                $Out.Add($Out.Count,$Item)
            }
    
            Return $Out[0..($Out.Count-1)]
        }
        [Object[]] GetDcomApplicationAccessSetting()
        {
            $Name = [DcomSecurityType]1
            $Path = $This.GetPath($Name)
            $Out  = @{ }
    
            [Console]::WriteLine("Retrieving [~] $Name")
    
            ForEach ($Instance in $This.GetInstances($Path))
            {
                $Item = $This.DcomSecurityReference("Access",$Out.Count,$Instance)
                $Out.Add($Out.Count,$Item)
            }
    
            Return $Out[0..($Out.Count-1)]
        }
        [Object[]] GetDcomApplicationLaunchSetting()
        {
            $Name = [DcomSecurityType]2
            $Path = $This.GetPath($Name)
            $Out  = @{ }
    
            [Console]::WriteLine("Retrieving [~] $Name")
    
            ForEach ($Instance in $This.GetInstances($Path))
            {
                $Item = $This.DcomSecurityReference("Launch",$Out.Count,$Instance)
                $Out.Add($Out.Count,$Item)
            }
    
            Return $Out[0..($Out.Count-1)]
        }
        Resolve()
        {
            # Process each Application in order
            ForEach ($AppId in $This.Application)
            {
                $Status = $This.ProgressString($AppId)
                [Console]::WriteLine($Status)
    
                $Hash   = @{ }
                $Filter = @($This.Access;$This.Launch) | ? AppId -eq $AppId.AppId
                ForEach ($Item in $Filter)
                {
                    $Object      = $This.DcomSecurityApplicationProperty($Hash.Count,$Item)
                    $Object.Name = $This.Reference.GetByString($Object.Sid).Name
                    $Hash.Add($Hash.Count,$Object)
                }
    
                $AppId.Count     = $Hash.Count
                $AppId.Property  = Switch ($Hash.Count)
                {
                    0       { @( )                         }
                    1       { @($Hash[0])                  }
                    Default { @($Hash[0..($Hash.Count-1)]) }
                }
            }
        }
        Reset([Object]$xSender,[Object[]]$Object)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        [String] Escape([String]$Entry)
        {
            Return [Regex]::Escape($Entry)
        }
        [String] TargetIcon([UInt32]$Slot)
        {
            Return $This.Module._Control(@("success.png","warning.png")[$Slot]).Fullname
        }
        MainTarget()
        {
            If ($This.Xaml.IO.MainTarget.Text -notmatch "^$")
            {
                Start-Sleep -Milliseconds 25
            }
    
            If ($This.Xaml.IO.MainTarget.Text -ne $This.ComputerName)
            {
                $This.ComputerName = $This.Xaml.IO.MainTarget.Text
            }
        }
        MainConnect()
        {
            $Test = Test-Connection $This.ComputerName -Count 1 -TimeToLive 250
            
            If ($Test)
            {
                $This.Xaml.IO.MainTarget.IsEnabled  = 0
                $This.Xaml.IO.MainConnect.IsEnabled = 0
                $This.Xaml.IO.MainIcon.Source       = $This.TargetIcon(0)
                $This.ComputerName                  = [System.Net.Dns]::Resolve($Test.IPV4Address).HostName
            }
            Else
            {
                $This.Xaml.IO.MainTarget.IsEnabled  = 1
                $This.Xaml.IO.MainConnect.IsEnabled = 1
                $This.Xaml.IO.MainIcon.Source       = $This.TargetIcon(1)
                $This.ComputerName                  = $This.GetHostname()
            }
    
            $This.Xaml.IO.MainTarget.Text           = $This.ComputerName
        }
        MainRefresh()
        {
            $Ctrl = $This
    
            $Ctrl.Main()
        
            $Ctrl.Xaml.IO.AppIdSearchProperty.IsEnabled = 1
            $Ctrl.Xaml.IO.AppIdSearchFilter.IsEnabled   = 1
            $Ctrl.Xaml.IO.AppIdOutput.IsEnabled         = 1
            $Ctrl.Xaml.IO.AppIdProperty.IsEnabled       = 1
    
            $Ctrl.Reset($Ctrl.Xaml.IO.AppIdOutput,$Ctrl.Application)
            $Ctrl.Reset($Ctrl.Xaml.IO.AppIdProperty,$Null)
            $Ctrl.AppIdSidSet($Null)
    
            $Ctrl.Xaml.IO.SidSearchProperty.IsEnabled   = 1
            $Ctrl.Xaml.IO.SidSearchFilter.IsEnabled     = 1
            $Ctrl.Xaml.IO.SidOutput.IsEnabled           = 1
    
            $Ctrl.Reset($Ctrl.Xaml.IO.SidOutput,$Ctrl.Reference.Output)
        }
        AppIdSearchFilter()
        {
            $Ctrl = $This
    
            $Text = $Ctrl.Escape($Ctrl.Xaml.IO.AppIdSearchFilter.Text)
                
            $List = Switch -Regex ($Text)
            {
                "^$"
                {
                    $Ctrl.Application
                }
                Default
                {
                    Switch ($Ctrl.Xaml.IO.AppIdSearchProperty.Text)
                    {
                        AppId
                        {
                            $Ctrl.Application | ? AppId -match $Text
                        }
                        Name
                        {
                            $Ctrl.Application | ? Name -match $Text
                        }
                        Sid
                        {
                            $Ctrl.Application | ? { $_.Property.Sid -match $Text }
                        }
                    }
                }
            }
            
            $Ctrl.Reset($Ctrl.Xaml.IO.AppIdOutput,$List)
            $Ctrl.Reset($Ctrl.Xaml.IO.AppIdProperty,$Null)
            $Ctrl.AppIdSidSet($Null)
        }
        AppIdOutput()
        {
            $Ctrl  = $This
    
            $Index = $Ctrl.Xaml.IO.AppIdOutput.SelectedIndex
            $Ctrl.SidSet($Null)
    
            If ($Index -ne -1)
            {
                $Item = $Ctrl.Application | ? AppId -eq $Ctrl.Xaml.IO.AppIdOutput.SelectedItem.AppId
    
                $Ctrl.Xaml.IO.AppIdSidString.IsEnabled    = 1
                $Ctrl.Xaml.IO.AppIdSidCopy.IsEnabled      = 1
                $Ctrl.Xaml.IO.AppIdSidName.IsEnabled      = 1
                $Ctrl.Xaml.IO.AppIdSidDefault.IsEnabled   = 1
    
                $Ctrl.Xaml.IO.AppIdName.Text              = $Item.Name
                $Ctrl.Xaml.IO.AppIdCount.Text             = $Item.Count
    
                $Ctrl.Reset($Ctrl.Xaml.IO.AppIdProperty,$Item.Property)
                $Ctrl.Xaml.IO.AppIdProperty.SelectedIndex = 0
            }
            Else
            {
                $Ctrl.Xaml.IO.AppIdSidString.IsEnabled    = 0
                $Ctrl.Xaml.IO.AppIdSidCopy.IsEnabled      = 0
                $Ctrl.Xaml.IO.AppIdSidName.IsEnabled      = 0
                $Ctrl.Xaml.IO.AppIdSidDefault.IsEnabled   = 0
    
                $Ctrl.Xaml.IO.AppIdName.Text              = ""
                $Ctrl.Xaml.IO.AppIdCount.Text             = 0
    
                $Ctrl.Reset($Ctrl.Xaml.IO.AppIdProperty,$Null)
            }
        }
        AppIdProperty()
        {
            $Ctrl = $This
    
            If ($Ctrl.Xaml.IO.AppIdProperty.SelectedIndex -ne -1)
            {
                $Item = $Ctrl.Reference.Output | ? String -eq $Ctrl.Xaml.IO.AppIdProperty.SelectedItem.Sid
    
                $Ctrl.AppIdSidSet($Item)
            }
            Else
            {
                $Ctrl.AppIdSidSet($Null)
            }
        }
        AppIdSidSet([Object]$Item)
        {
            If (!!$Item.String)
            {
                $This.Xaml.IO.AppIdSidString.Text       = $Item.String
                $This.Xaml.IO.AppIdSidCopy.IsEnabled    = 1
    
                $This.Xaml.IO.AppIdSidName.Text         = $Item.Name
                $This.Xaml.IO.AppIdSidDefault.IsChecked = $Item.Default
            }
            Else
            {
                $This.Xaml.IO.AppIdSidString.Text       = ""
                $This.Xaml.IO.AppIdSidCopy.IsEnabled    = 0
    
                $This.Xaml.IO.AppIdSidName.Text         = ""
                $This.Xaml.IO.AppIdSidDefault.IsChecked = 0
            }
        }
        AppIdSidCopy()
        {
            $This.Xaml.IO.AppIdSidString.Text | Set-Clipboard
        }
        SidOutput()
        {
            $Ctrl = $This
    
            $Item = $Ctrl.Reference.Output | ? String -match $Ctrl.Xaml.IO.SidOutput.SelectedItem.String
    
            $Ctrl.SidSet($Item)
        }
        SidSearchFilter()
        {
            $Ctrl = $This
    
            $Text = $Ctrl.Escape($Ctrl.Xaml.IO.SidSearchFilter.Text)
                
            $List = Switch -Regex ($Text)
            {
                "^$"
                {
                    $Ctrl.Reference.Output
                }
                Default
                {
                    Switch ($Ctrl.Xaml.IO.SidSearchProperty.Text)
                    {
                        Name
                        {
                            $Ctrl.Reference.Output | ? Name -match $Text
                        }
                        Sid
                        {
                            $Ctrl.Reference.Output | ? String -match $Text
                        }
                    }
                }
            }
            
            $Ctrl.Reset($Ctrl.Xaml.IO.SidOutput,$List)
            $Ctrl.SidSet($Null)
        }
        SidSet([Object]$Item)
        {
            If (!!$Item.String)
            {
                $This.Xaml.IO.SidString.Text            = $Item.String
                $This.Xaml.IO.SidCopy.IsEnabled         = 1
    
                $This.Xaml.IO.SidName.Text              = $Item.Name
                $This.Xaml.IO.SidDefault.IsChecked      = $Item.Default
            }
            Else
            {
                $This.Xaml.IO.SidString.Text            = ""
                $This.Xaml.IO.SidCopy.IsEnabled         = 1
    
                $This.Xaml.IO.SidName.Text              = ""
                $This.Xaml.IO.SidDefault.IsChecked      = 0
            }
        }
        SidCopy()
        {
            $This.Xaml.IO.SidString.Text | Set-Clipboard
        }
        StageXaml()
        {
            $Ctrl = $This
    
            <# Tab Ctrl*
                 0 TabSlot         ComboBox System.Windows.Controls.ComboBox Items.Count:3
                 1 TabMain             Grid     System.Windows.Controls.Grid
                 5 TabAppId            Grid     System.Windows.Controls.Grid
                 8 TabSid              Grid     System.Windows.Controls.Grid #
    
            $Ctrl.Xaml.IO.TabSlot.Add_SelectionChanged(
            {
                $Ctrl.Xaml.IO.TabMain.Visibility    = "Hidden"
                $Ctrl.Xaml.IO.PanelMain.Visibility  = "Hidden"
            
                $Ctrl.Xaml.IO.TabAppId.Visibility   = "Hidden"
                $Ctrl.Xaml.IO.PanelAppId.Visibility = "Hidden"
            
                $Ctrl.Xaml.IO.TabSid.Visibility     = "Hidden"
                $Ctrl.Xaml.IO.PanelSid.Visibility   = "Hidden"
            
                Switch ($Ctrl.Xaml.IO.TabSlot.SelectedIndex)
                {
                    0
                    {
                        $Ctrl.Xaml.IO.TabMain.Visibility    = "Visible"
                        $Ctrl.Xaml.IO.PanelMain.Visibility  = "Visible"
                    }
                    1
                    {
                        $Ctrl.Xaml.IO.TabAppId.Visibility   = "Visible"
                        $Ctrl.Xaml.IO.PanelAppId.Visibility = "Visible"
                    }
                    2
                    {
                        $Ctrl.Xaml.IO.TabSid.Visibility     = "Visible"
                        $Ctrl.Xaml.IO.PanelSid.Visibility   = "Visible"
                    }
                }
            })
            
            <# Main Tab
                 2 MainTarget          TextBox  System.Windows.Controls.TextBox
                 3 MainIcon            Image    System.Windows.Controls.Image
                 4 MainConnect         Button   System.Windows.Controls.Button: Connect
                11 MainRefresh         Button   System.Windows.Controls.Button: Refresh #
    
            $Ctrl.Xaml.IO.MainTarget.Add_TextChanged(
            {
                $Ctrl.MainTarget()
            })
    
            $Ctrl.Xaml.IO.MainConnect.Add_Click(
            {
                $Ctrl.MainConnect()
            })
    
            $Ctrl.Xaml.IO.MainRefresh.Add_Click(
            {
                $Ctrl.MainRefresh()
            })
    
            <# Main Panel
                12 MainPanel           Grid     System.Windows.Controls.Grid #
    
            <# AppId Tab
                 6 AppIdSearchProperty ComboBox System.Windows.Controls.ComboBox Items.Count:3
                 7 AppIdSearchFilter   TextBox  System.Windows.Controls.TextBox #
    
            $Ctrl.Xaml.IO.AppIdSearchFilter.Add_TextChanged(
            {
                $Ctrl.AppIdSearchFilter()
            })
        
            $Ctrl.Xaml.IO.AppIdSearchProperty.Add_SelectionChanged(
            {
                $Ctrl.Xaml.IO.AppIdSearchFilter.Text = ""
            })
    
            <# AppId Panel
                13 AppIdPanel          Grid     System.Windows.Controls.Grid
                14 AppIdOutput         DataGrid System.Windows.Controls.DataGrid Items.Count:0
                15 AppIdName           TextBox  System.Windows.Controls.TextBox
                16 AppIdCount          TextBox  System.Windows.Controls.TextBox
                17 AppIdProperty       DataGrid System.Windows.Controls.DataGrid Items.Count:0
                18 AppIdSidString      TextBox  System.Windows.Controls.TextBox
                19 AppIdSidCopy        Button   System.Windows.Controls.Button: Copy
                20 AppIdSidName        TextBox  System.Windows.Controls.TextBox
                21 AppIdSidDefault     CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False #
    
            $Ctrl.Xaml.IO.AppIdOutput.Add_SelectionChanged(
            {
                $Ctrl.AppIdOutput()
            })
    
            $Ctrl.Xaml.IO.AppIdProperty.Add_SelectionChanged(
            {
                $Ctrl.AppIdProperty()
            })
    
            $Ctrl.Xaml.IO.AppIdSidString.Add_TextChanged(
            {
                $Ctrl.Xaml.IO.AppIdSidCopy.IsEnabled = [UInt32]($Ctrl.Xaml.IO.AppIdSidString.Text -notmatch "^$")
            })
    
            $Ctrl.Xaml.IO.AppIdSidCopy.Add_Click(
            {
                $Ctrl.AppIdSidCopy()
            })
    
            <# Sid Tab
                 9 SidSearchProperty   ComboBox System.Windows.Controls.ComboBox Items.Count:2
                10 SidSearchFilter     TextBox  System.Windows.Controls.TextBox #
            
            $Ctrl.Xaml.IO.SidSearchFilter.Add_TextChanged(
            {
                $Ctrl.SidSearchFilter()
            })
        
            $Ctrl.Xaml.IO.SidSearchProperty.Add_SelectionChanged(
            {
                $Ctrl.Xaml.IO.AppIdSearchFilter.Text = ""
            })
    
            <#
               Sid Panel
                22 SidPanel            Grid     System.Windows.Controls.Grid
                23 SidOutput           DataGrid System.Windows.Controls.DataGrid Items.Count:0
                24 SidString           TextBox  System.Windows.Controls.TextBox
                25 SidCopy             Button   System.Windows.Controls.Button: Copy
                26 SidName             TextBox  System.Windows.Controls.TextBox
                27 SidDefault          CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False #
    
            $Ctrl.Xaml.IO.SidOutput.Add_SelectionChanged(
            {
                $Ctrl.SidOutput()
            })
            
            $Ctrl.Xaml.IO.SidString.Add_TextChanged(
            {
                $Ctrl.Xaml.IO.SidCopy.IsEnabled = [UInt32]($Ctrl.Xaml.IO.SidString.Text -notmatch "^$")
            })
    
            $Ctrl.Xaml.IO.SidCopy.Add_Click(
            {
                $Ctrl.SidCopy()
            })
    
            $Ctrl.Initial()
        }
        Initial()
        {
            $Ctrl = $This
    
            $Ctrl.Xaml.IO.TabSlot.SelectedIndex         = 0
    
            $Ctrl.Xaml.IO.MainTarget.Text               = $Ctrl.GetHostName()
        }
        Invoke()
        {
            Try
            {
                $This.Xaml.Invoke()
            }
            Catch
            {
                $This.Xaml.Exception
            }
        }
        Reload()
        {
            # Xaml
            $This.Xaml = $This.GetDcomSecurityXaml()
    
            $This.StageXaml()
    
            $This.Invoke()
        }
        [String] ProgressString([Object]$AppId)
        {
            Return "Processing [~] {0} {1:p}" -f $AppId.AppId, (($AppId.Index+1)/$This.Application.Count)
        }
        [String] ToString()
        {
            Return "<FEModule.DcomSecurity.Controller>"
        }
    }

$Global:UI     = [Hashtable]::Synchronized(@{})
$Ctrl          = [DcomSecurityController]::New()
$Ctrl.Xaml     = [RunspaceXaml][DcomSecurityXaml]::Content
$Ctrl.Xaml.Reload()
$Ctrl.Xaml.Runspace = $Ctrl.Xaml.CreateRunspace()

$Ctrl.Xaml.Runspace.ApartmentState = "STA"
$Ctrl.Xaml.Runspace.ThreadOptions  = "ReuseThread"

$Ctrl.Xaml.Runspace.Open()
$Ctrl.Xaml.Runspace.SessionStateProxy.SetVariable("UI",$Global:UI)

# Adds the Xaml properties to the synchronized hashtable
ForEach ($Name in $Ctrl.Xaml.Names)
{
    $Global:UI."$Name" = $Ctrl.Xaml.IO.FindName($Name)
}

$Ctrl.UI       = $Global:UI

# Create the [PowerShell] object w/ scriptblock
$psCmd                   = [PowerShell]::Create()
.AddScript(
{
    $Global:UI.Error     = $Error
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

    #  TabSlot               ComboBox System.Windows.Controls.ComboBox Items.Count:3
    # TabMain                Grid     System.Windows.Controls.Grid
    # -> MainTarget          TextBox  System.Windows.Controls.TextBox
    #  4 MainIcon            Image    System.Windows.Controls.Image
    #  5 MainConnect         Button   System.Windows.Controls.Button: Connect
    # 12 MainRefresh         Button   System.Windows.Controls.Button: Refresh
    #  6 TabAppId            Grid     System.Windows.Controls.Grid
    #  9 TabSid              Grid     System.Windows.Controls.Grid

    # 13 PanelMain           Grid     System.Windows.Controls.Grid


    #  7 AppIdSearchProperty ComboBox System.Windows.Controls.ComboBox Items.Count:3
    #  8 AppIdSearchFilter   TextBox  System.Windows.Controls.TextBox
    # 10 SidSearchProperty   ComboBox System.Windows.Controls.ComboBox Items.Count:2
    # 11 SidSearchFilter     TextBox  System.Windows.Controls.TextBox
    
    
    # 14 PanelAppId          Grid     System.Windows.Controls.Grid
    # 15 AppIdOutput         DataGrid System.Windows.Controls.DataGrid Items.Count:0
    # 16 AppIdName           TextBox  System.Windows.Controls.TextBox
    # 17 AppIdCount          TextBox  System.Windows.Controls.TextBox
    # 18 AppIdProperty       DataGrid System.Windows.Controls.DataGrid Items.Count:0
    # 19 AppIdSidString      TextBox  System.Windows.Controls.TextBox
    # 20 AppIdSidCopy        Button   System.Windows.Controls.Button: Copy
    # 21 AppIdSidName        TextBox  System.Windows.Controls.TextBox
    # 22 AppIdSidDefault     CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False
    # 23 PanelSid            Grid     System.Windows.Controls.Grid
    # 24 SidOutput           DataGrid System.Windows.Controls.DataGrid Items.Count:0
    # 25 SidString           TextBox  System.Windows.Controls.TextBox
    # 26 SidCopy             Button   System.Windows.Controls.Button: Copy
    # 27 SidName             TextBox  System.Windows.Controls.TextBox
    # 28 SidDefault          CheckBox System.Windows.Controls.CheckBox Content:Default IsChecked:False

    $Global:UI.TabSlot.Add_SelectionChanged(
    {
        $Global:UI.TabMain.Visibility    = "Hidden"
        $Global:UI.PanelMain.Visibility  = "Hidden"
        
        $Global:UI.TabAppId.Visibility   = "Hidden"
        $Global:UI.PanelAppId.Visibility = "Hidden"
        
        $Global:UI.TabSid.Visibility     = "Hidden"
        $Global:UI.PanelSid.Visibility   = "Hidden"
        
        Switch ($Global:UI.TabSlot.SelectedIndex)
        {
            0
            {
                $Global:UI.TabMain.Visibility    = "Visible"
                $Global:UI.PanelMain.Visibility  = "Visible"
            }
            1
            {
                $Global:UI.TabAppId.Visibility   = "Visible"
                $Global:UI.PanelAppId.Visibility = "Visible"
            }
            2
            {
                $Global:UI.TabSid.Visibility     = "Visible"
                $Global:UI.PanelSid.Visibility   = "Visible"
            }
        }
    })

    $Global:UI.Window.ShowDialog() | Out-Null
})

$psCmd.Runspace = $Runspace
$Handle = $psCmd.BeginInvoke()

<#
$Global:UI.Button0.Add_Click(
{
    # Do work
    $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("00000000") }, "Normal")
})

$Global:UI.Button1.Add_Click(
{
    $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("11111111") }, "Normal")
})

    $Global:UI.Button2.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("22222222") }, "Normal")
    })

    $Global:UI.Button3.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("33333333") }, "Normal")
    })

    $Global:UI.Window.ShowDialog() | Out-Null

$Xaml.UI       = $Global:UI


$Ctrl         = [RunspaceWindow]::New($Sync,[XamlWindow][DcomSecurityXaml]::Content)

$Runspace                = [RunspaceFactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions  = "ReuseThread"          
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable("UI",$Global:UI)

# $psCmd = [PowerShell]::Create()
# .AddParameter([String]$Name,[Object]$Value)
# .AddArgument([Object]$Value)
# .AddScript([Object]$ScriptBlock)

$psCmd                   = [PowerShell]::Create().AddScript(
{
    $Global:UI.Error     = $Error

    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
    [XML]$Xaml = @"
    <Window 
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            ResizeMode="NoResize"
            Title="PowerShell (Runspace + Sync:UI) Test"
            Height="350"
            Width="500">
            <Window.Resources>
                <Style x:Key="DropShadow">
                    <Setter Property="TextBlock.Effect">
                        <Setter.Value>
                            <DropShadowEffect ShadowDepth="1"/>
                        </Setter.Value>
                    </Setter>
                </Style>
                <Style TargetType="Button">
                    <Setter Property="Margin" Value="5"/>
                    <Setter Property="Padding" Value="5"/>
                    <Setter Property="FontWeight" Value="Heavy"/>
                    <Setter Property="Foreground" Value="Black"/>
                    <Setter Property="Background" Value="#DFFFBA"/>
                    <Setter Property="BorderThickness" Value="2"/>
                    <Setter Property="VerticalContentAlignment" Value="Center"/>
                    <Style.Resources>
                        <Style TargetType="Border">
                            <Setter Property="CornerRadius" Value="5"/>
                        </Style>
                    </Style.Resources>
                </Style>
                <Style TargetType="Label">
                    <Setter Property="Margin" Value="5"/>
                    <Setter Property="FontWeight" Value="Bold"/>
                    <Setter Property="Background" Value="Black"/>
                    <Setter Property="Foreground" Value="White"/>
                    <Setter Property="BorderBrush" Value="Gray"/>
                    <Setter Property="BorderThickness" Value="2"/>
                    <Style.Resources>
                        <Style TargetType="Border">
                            <Setter Property="CornerRadius" Value="5"/>
                        </Style>
                    </Style.Resources>
                </Style>
            </Window.Resources>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="200"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Grid Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="200"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="100"/>
                </Grid.ColumnDefinitions>
                <GroupBox Grid.Column="0" Name="GroupBox0" Header="[GroupBox Header]">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <Button Grid.Row="0" Name="Button0" Content="Button(0)"/>
                        <Button Grid.Row="1" Name="Button1" Content="Button(1)"/>
                        <Button Grid.Row="2" Name="Button2" Content="Button(2)"/>
                        <Button Grid.Row="3" Name="Button3" Content="Button(3)"/>
                    </Grid>
                </GroupBox>
                <Label Grid.Column="2" Name="Label0" Content="60"/>
            </Grid>
            <TextBox Grid.Row="1" Name="TextBox0" TextWrapping="Wrap"/>
        </Grid>
    </Window>
"@

    $Node                = [System.Xml.XmlNodeReader]::New($Xaml)
    $Global:UI.Window    = [Windows.Markup.XamlReader]::Load($Node)

    # Associate controls to sync hashtable
    $Global:UI.Button0   = $Global:UI.Window.FindName("Button0")
    $Global:UI.Button1   = $Global:UI.Window.FindName("Button1")
    $Global:UI.Button2   = $Global:UI.Window.FindName("Button2")
    $Global:UI.Button3   = $Global:UI.Window.FindName("Button3")
    $Global:UI.TextBox0  = $Global:UI.Window.FindName("TextBox0")
    $Global:UI.GroupBox0 = $Global:UI.Window.FindName("GroupBox0")
    $Global:UI.Label0    = $Global:UI.Window.FindName("Label0")

    # Event Handlers
    $Global:UI.Button0.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("00000000") }, "Normal")
    })

    $Global:UI.Button1.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("11111111") }, "Normal")
    })

    $Global:UI.Button2.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("22222222") }, "Normal")
    })

    $Global:UI.Button3.Add_Click(
    {
        $Global:UI.Window.Dispatcher.Invoke([Action]{ $Global:UI.TextBox0.AppendText("33333333") }, "Normal")
    })

    $Global:UI.Window.ShowDialog() | Out-Null # <- Important that it is not using InvokeAsync({ $This.IO.ShowDialog() }).Wait()
})

$psCmd.Runspace = $Runspace
$Handle = $psCmd.BeginInvoke()
