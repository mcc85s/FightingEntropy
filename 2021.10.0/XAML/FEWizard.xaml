<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://PowerShell Deployment Wizard (featuring DVR)" Width="800" Height="600" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <Style TargetType="Label">
            <Setter Property="Height" Value="28"/>
            <Setter Property="Margin" Value="5"/>
        </Style>
        <Style x:Key="DropShadow">
            <Setter Property="TextBlock.Effect">
                <Setter.Value>
                    <DropShadowEffect ShadowDepth="1"/>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="{x:Type TextBox}" BasedOn="{StaticResource DropShadow}">
            <Setter Property="TextBlock.TextAlignment" Value="Left"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Height" Value="24"/>
            <Setter Property="Margin" Value="4"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Foreground" Value="#000000"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
            <Style.Resources>
                <Style TargetType="Border">
                    <Setter Property="CornerRadius" Value="2"/>
                </Style>
            </Style.Resources>
        </Style>
        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">
            <Setter Property="TextBlock.TextAlignment" Value="Left"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Margin" Value="4"/>
            <Setter Property="Height" Value="24"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Height" Value="24"/>
            <Setter Property="Margin" Value="5"/>
        </Style>
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="#000000"/>
            <Setter Property="Foreground" Value="#66D066"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="Heavy"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#4444FF"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="False">
                                <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>
                                <Setter Property="Foreground" Value="#000000"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
            <Setter Property="FontWeight" Value="Semibold"/>
            <Setter Property="FontSize" Value="14"/>
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
        <Style TargetType="ComboBox">
            <Setter Property="Height" Value="24"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Normal"/>
        </Style>
        <Style TargetType="DataGrid">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="AutoGenerateColumns" Value="False"/>
            <Setter Property="AlternationCount" Value="2"/>
            <Setter Property="HeadersVisibility" Value="Column"/>
            <Setter Property="CanUserResizeRows" Value="False"/>
            <Setter Property="CanUserAddRows" Value="False"/>
            <Setter Property="IsReadOnly" Value="True"/>
            <Setter Property="IsTabStop" Value="True"/>
            <Setter Property="IsTextSearchEnabled" Value="True"/>
            <Setter Property="SelectionMode" Value="Extended"/>
            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>
            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>
        </Style>
        <Style TargetType="DataGridRow">
            <Style.Triggers>
                <Trigger Property="AlternationIndex" Value="0">
                    <Setter Property="Background" Value="White"/>
                </Trigger>
                <Trigger Property="AlternationIndex" Value="1">
                    <Setter Property="Background" Value="#FFD6FFFB"/>
                </Trigger>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="ToolTip">
                        <Setter.Value>
                            <TextBlock TextWrapping="Wrap" Width="400" Background="#000000" Foreground="#00FF00"/>
                        </Setter.Value>
                    </Setter>
                    <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="DataGridColumnHeader">
            <Setter Property="FontSize"   Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>
        <Style TargetType="TabControl">
            <Setter Property="TabStripPlacement" Value="Top"/>
            <Setter Property="HorizontalContentAlignment" Value="Center"/>
            <Setter Property="Background" Value="LightYellow"/>
        </Style>
        <Style TargetType="GroupBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="BorderThickness" Value="2"/>
            <Setter Property="BorderBrush" Value="Gray"/>
        </Style>
    </Window.Resources>
    <Grid>
        <Grid.Resources>
            <Style TargetType="Grid">
                <Setter Property="Background" Value="LightYellow"/>
            </Style>
        </Grid.Resources>
        <Grid.RowDefinitions>
            <RowDefinition Height="45"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="45"/>
        </Grid.RowDefinitions>
        <Grid Grid.Row="0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button Grid.Column="0" Name="Locale_Tab" Content="Locale"/>
            <Button Grid.Column="1" Name="System_Tab" Content="System"/>
            <Button Grid.Column="2" Name="Domain_Tab" Content="Domain"/>
            <Button Grid.Column="3" Name="Network_Tab" Content="Network"/>
            <Button Grid.Column="4" Name="Applications_Tab" Content="Applications"/>
            <Button Grid.Column="5" Name="Control_Tab" Content="Control"/>
        </Grid>
        <Grid Grid.Row="1" Name="Locale_Panel" Visibility="Visible">
            <Grid.RowDefinitions>
                <RowDefinition Height="2*"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <GroupBox Grid.Row="0" Header="[Task Sequence] - (Select a task sequence to proceed)">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="125"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="125"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Label     Grid.Column="0" Content="Task Sequence"/>
                        <TextBox   Grid.Column="1" Name="Task_ID" IsReadOnly="True"/>
                        <Label     Grid.Column="2" Content="Profile Name"/>
                        <TextBox   Grid.Column="3" Name="Task_Profile"/>
                    </Grid>
                    <DataGrid Grid.Row="1" Name="Task_List" Margin="5">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Type"    Binding="{Binding Type}"    Width="80"/>
                            <DataGridTextColumn Header="Version" Binding="{Binding Version}" Width="125"/>
                            <DataGridTextColumn Header="ID"      Binding="{Binding ID}"      Width="80"/>
                            <DataGridTextColumn Header="Name"    Binding="{Binding Name}"    Width="*"/>
                        </DataGrid.Columns>
                    </DataGrid>
                </Grid>
            </GroupBox>
            <GroupBox Header="[Locale] - (Time Zone/Keyboard/Language)" Grid.Row="1">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="125"/>
                            <ColumnDefinition Width="350"/>
                            <ColumnDefinition Width="125"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Label     Grid.Column="0" Content="Time Zone"/>
                        <ComboBox  Grid.Column="1" Name="Locale_Timezone"/>
                        <Label     Grid.Column="2" Content="Keyboard Layout"/>
                        <ComboBox  Grid.Column="3" Name="Locale_Keyboard"/>
                    </Grid>
                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="125"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <Label     Grid.Row="0" Grid.Column="0" Content="Primary"/>
                        <CheckBox  Grid.Row="1" Grid.Column="0" Content="Secondary" Name="Locale_SecondLanguage"/>
                        <ComboBox  Grid.Row="0" Grid.Column="1" Name="Locale_Language1"/>
                        <ComboBox  Grid.Row="1" Grid.Column="1" Name="Locale_Language2"/>
                    </Grid>
                </Grid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="1" Name="System_Panel" Visibility="Collapsed">
            <Grid.RowDefinitions>
                <RowDefinition Height="320"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <GroupBox Header="[System]" Grid.Row="0">
                <Grid Margin="5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="150"/>
                        <ColumnDefinition Width="240"/>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                    </Grid.RowDefinitions>
                    <!-- Column 0 -->
                    <Label       Grid.Row="0" Grid.Column="0" Content="Manufacturer:"/>
                    <Label       Grid.Row="1" Grid.Column="0" Content="Model:"/>
                    <Label       Grid.Row="2" Grid.Column="0" Content="Processor:"/>
                    <Label       Grid.Row="3" Grid.Column="0" Content="Architecture:"/>
                    <Label       Grid.Row="4" Grid.Column="0" Content="UUID:"/>
                    <Label       Grid.Row="5" Grid.Column="0" Content="System Name:"     ToolTip="Enter a new system name"/>
                    <Label       Grid.Row="6" Grid.Column="0" Content="System Password:" ToolTip="Enter a new system password"/>
                    <!-- Column 1 -->
                    <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>
                    <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>
                    <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>
                    <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture"/>
                    <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3"  Name="System_UUID"/>
                    <TextBox     Grid.Row="5" Grid.Column="1" Name="System_Name"/>
                    <PasswordBox Grid.Row="6" Grid.Column="1" Name="System_Password"/>
                    <!-- Column 2 -->
                    <Label       Grid.Row="0" Grid.Column="2" Content="Product:"/>
                    <Label       Grid.Row="1" Grid.Column="2" Content="Serial:"/>
                    <Label       Grid.Row="2" Grid.Column="2" Content="Memory:"/>
                    <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">
                        <Label    Content="Chassis:"/>
                        <CheckBox Name="System_IsVM" Content="IsVM" IsEnabled="False"/>
                    </StackPanel>
                    <CheckBox    Grid.Row="5" Grid.Column="2" Name="System_UseSerial" Content="Use Serial #"/>
                    <Label       Grid.Row="6" Grid.Column="2" Content="Confirm:"/>
                    <!-- Column 3 -->
                    <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>
                    <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>
                    <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>
                    <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis"/>
                    <StackPanel  Grid.Row="5" Grid.Column="3" Orientation="Horizontal">
                        <Label   Content="BIOS/UEFI:"/>
                        <ComboBox Name="System_BiosUefi" Width="150"/>
                    </StackPanel>

                    <PasswordBox Grid.Row="6" Grid.Column="3" Name="System_Confirm"/>
                </Grid>
            </GroupBox>
            <GroupBox Grid.Row="1" Header="[Disks]">
                <DataGrid Name="System_Disk" Margin="5">
                    <DataGrid.Columns>
                        <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="50"/>
                        <DataGridTextColumn Header="Label"      Binding="{Binding Label}" Width="150"/>
                        <DataGridTextColumn Header="FileSystem" Binding="{Binding FileSystem}" Width="80"/>
                        <DataGridTextColumn Header="Size"       Binding="{Binding Size}" Width="150"/>
                        <DataGridTextColumn Header="Free"       Binding="{Binding Free}" Width="150"/>
                        <DataGridTextColumn Header="Used"       Binding="{Binding Used}" Width="150"/>
                    </DataGrid.Columns>
                </DataGrid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="1" Name="Domain_Panel" Visibility="Collapsed">
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <GroupBox Header="[Domain]" Grid.Row="0">
                <Grid Margin="5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="150"/>
                        <ColumnDefinition Width="240"/>
                        <ColumnDefinition Width="150"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="80"/>
                    </Grid.RowDefinitions>
                    <!-- Column 0 -->
                    <StackPanel Grid.Row="0" Grid.Column="0" Orientation="Horizontal">
                        <Label Content="Organization:"/>
                        <CheckBox Content="Edit" Name="Domain_OrgEdit" HorizontalAlignment="Left"/>
                    </StackPanel>
                    <Label    Grid.Row="1" Grid.Column="0" Content="Organizational Unit:"/>
                    <Label    Grid.Row="2" Grid.Column="0" Content="Home Page:"/>
                    <GroupBox Grid.Row="3" Grid.ColumnSpan="4" Header="[Credential (Username/Password/Confirm)]">
                        <Grid Margin="4">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="1.25*"/>
                                <ColumnDefinition Width="20"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <TextBox     Grid.Column="0" Name="Domain_Username"/>
                            <PasswordBox Grid.Column="2" Name="Domain_Password"/>
                            <PasswordBox Grid.Column="3" Name="Domain_Confirm"/>
                        </Grid>
                    </GroupBox>
                    <!-- Column 1 -->
                    <TextBox  Grid.Row="0" Grid.Column="1" Name="Domain_OrgName"/>
                    <TextBox  Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_OU"/>
                    <TextBox  Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_HomePage"/>
                    <!-- Column 2 -->
                    <ComboBox Grid.Row="0" Grid.Column="2" Name="Domain_Type"/>
                    <!-- Column 3 -->
                    <TextBox  Grid.Row="0" Grid.Column="3" Name="Domain_Name"/>
                </Grid>
            </GroupBox>
            <GroupBox Grid.Row ="1" Header="[Miscellaneous]">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                    </Grid.RowDefinitions>
                    <!-- Column 0 -->
                    <Label    Grid.Row="0" Grid.Column="0" Content="Finish Action:"/>
                    <Label    Grid.Row="1" Grid.Column="0" Content="Event Service:"/>
                    <Label    Grid.Row="2" Grid.Column="0" Content="End Log Files:"/>
                    <Label    Grid.Row="3" Grid.Column="0" Content="Real-Time Log:"/>
                    <Label    Grid.Row="4" Grid.Column="0" Content="Product Key"/>
                    <!-- Column 1 -->
                    <ComboBox Grid.Row="0" Grid.Column="1" Name="Misc_Finish_Action"/>
                    <TextBox  Grid.Row="1" Grid.Column="1" Name="Misc_EventService" ToolTip="For monitoring deployment process"/>
                    <TextBox  Grid.Row="2" Grid.Column="1" Name="Misc_LogsSLShare"/>
                    <TextBox  Grid.Row="3" Grid.Column="1" Name="Misc_LogsSLShare_DynamicLogging"/>
                    <ComboBox Grid.Row="4" Grid.Column="1" Name="Misc_Product_Key_Type"/>
                    <!-- Column 2 -->
                    <Label    Grid.Row="0" Grid.Column="2" Content="WSUS Server:"/>
                    <CheckBox Grid.Row="2" Grid.Column="2" Content="Save in Root" Name="Misc_SLShare_DeployRoot" />
                    <Label    Grid.Row="3" Grid.Column="2" Grid.ColumnSpan="2" Content="Enable Real-Time Task Sequence Logging" HorizontalAlignment="Left"/>
                    <TextBox  Grid.Row="4" Grid.Column="2" Grid.ColumnSpan="2" Name="Misc_Product_Key"/>
                    <!-- Column 3 -->
                    <TextBox  Grid.Row="0" Grid.Column="3" Name="Misc_WSUSServer" ToolTip="Pull updates from Windows Server Update Services"/>
                    <CheckBox Grid.Row="1" Grid.Column="3" Name="Misc_HideShell" Content="Hide explorer during deployment"/>
                    <CheckBox Grid.Row="2" Grid.Column="3" Name="Misc_NoExtraPartition" Content="Do not create extra partition"/>
                </Grid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="1" Name="Network_Panel" Visibility="Collapsed">
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <GroupBox Header="[Adapter]" Grid.Row="0">
                <DataGrid Name="Network_Adapter" Margin="5" ScrollViewer.HorizontalScrollBarVisibility="Visible">
                    <DataGrid.Columns>
                        <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="200"/>
                        <DataGridTextColumn Header="Index"      Binding="{Binding Index}" Width="50"/>
                        <DataGridTextColumn Header="IPAddress"  Binding="{Binding IPAddress}" Width="100"/>
                        <DataGridTextColumn Header="SubnetMask" Binding="{Binding SubnetMask}" Width="100"/>
                        <DataGridTextColumn Header="Gateway"    Binding="{Binding Gateway}" Width="100"/>
                        <DataGridTemplateColumn Header="DNSServer" Width="125">
                            <DataGridTemplateColumn.CellTemplate>
                                <DataTemplate>
                                    <ComboBox ItemsSource="{Binding DNSServer}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>
                                </DataTemplate>
                            </DataGridTemplateColumn.CellTemplate>
                        </DataGridTemplateColumn>
                        <DataGridTextColumn Header="DhcpServer" Binding="{Binding DhcpServer}" Width="100"/>
                        <DataGridTextColumn Header="MacAddress" Binding="{Binding MacAddress}" Width="100"/>
                    </DataGrid.Columns>
                </DataGrid>
            </GroupBox>
            <GroupBox Header="[Network]" Grid.Row="1">
                <Grid Margin="5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                        <RowDefinition Height="40"/>
                    </Grid.RowDefinitions>
                    <!-- Column 0 -->
                    <Label    Grid.Row="0" Grid.Column="0" Content="Selected Adapter:"/>
                    <Label    Grid.Row="1" Grid.Column="0" Content="Network Type:"/>
                    <Label    Grid.Row="2" Grid.Column="0" Content="IP Address:"/>
                    <Label    Grid.Row="3" Grid.Column="0" Content="Subnet Mask:"/>
                    <Label    Grid.Row="4" Grid.Column="0" Content="Gateway:"/>
                    <!-- Column 1 -->
                    <ComboBox Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Network_Selected" IsEnabled="False"/>
                    <ComboBox Grid.Row="1" Grid.Column="1" Name="Network_Type"/>
                    <TextBox  Grid.Row="2" Grid.Column="1" Name="Network_IPAddress"/>
                    <TextBox  Grid.Row="3" Grid.Column="1" Name="Network_SubnetMask"/>
                    <TextBox  Grid.Row="4" Grid.Column="1" Name="Network_Gateway"/>
                    <!-- Column 2 -->
                    <Label    Grid.Row="1" Grid.Column="2" Content="Interface Index:"/>
                    <Label    Grid.Row="2" Grid.Column="2" Content="DNS Server(s):"/>
                    <Label    Grid.Row="3" Grid.Column="2" Content="DHCP Server:"/>
                    <Label    Grid.Row="4" Grid.Column="2" Content="Mac Address:"/>
                    <!-- Column 3 -->
                    <TextBox  Grid.Row="1" Grid.Column="3" Name="Network_Index"/>
                    <ComboBox Grid.Row="2" Grid.Column="3" Name="Network_DNS"/>
                    <TextBox  Grid.Row="3" Grid.Column="3" Name="Network_DHCP"/>
                    <TextBox  Grid.Row="4" Grid.Column="3" Name="Network_MacAddress"/>
                </Grid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="1" Name="Applications_Panel" Visibility="Collapsed">
            <GroupBox Header="[Applications]">
                <DataGrid Name="Applications" Margin="10">
                    <DataGrid.Columns>
                        <DataGridTemplateColumn Header="Select" Width="50">
                            <DataGridTemplateColumn.CellTemplate>
                                <DataTemplate>
                                    <ComboBox SelectedIndex="{Binding Select}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">
                                        <ComboBoxItem Content="False"/>
                                        <ComboBoxItem Content="True"/>
                                    </ComboBox>
                                </DataTemplate>
                            </DataGridTemplateColumn.CellTemplate>
                        </DataGridTemplateColumn>
                        <DataGridTextColumn Header="Name"      Binding="{Binding Name}"      Width="150"/>
                        <DataGridTextColumn Header="Version"   Binding="{Binding Version}"   Width="75"/>
                        <DataGridTextColumn Header="Publisher" Binding="{Binding Publisher}" Width="150"/>
                        <DataGridTextColumn Header="GUID"      Binding="{Binding GUID}"      Width="*"/>
                    </DataGrid.Columns>
                </DataGrid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="1" Name="Control_Panel" Visibility="Collapsed">
            <Grid.RowDefinitions>
                <RowDefinition Height="200"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <GroupBox Grid.Row="0" Header="[Control]">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                        <ColumnDefinition Width="125"/>
                        <ColumnDefinition Width="250"/>
                    </Grid.ColumnDefinitions>
                    <!-- Column 0 -->
                    <Label        Grid.Row="0" Grid.Column="0" Content="Username:"/>
                    <Label        Grid.Row="1" Grid.Column="0" Content="Password:" />
                    <Label        Grid.Row="2" Grid.Column="0" Content="Mode:"/>
                    <Label        Grid.Row="3" Grid.Column="0" Content="Description:"/>
                    <!-- Column 1 -->
                    <TextBox      Grid.Row="0" Grid.Column="1" Name="Control_Username"/>
                    <PasswordBox  Grid.Row="1" Grid.Column="1" Name="Control_Password"/>
                    <ComboBox     Grid.Row="2" Grid.Column="1" Name="Control_Mode"/>
                    <TextBox      Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3"  Name="Control_Description"/>
                    <!-- Column 1 -->
                    <Label        Grid.Row="0" Grid.Column="2" Content="Domain:"/>
                    <Label        Grid.Row="1" Grid.Column="2" Content="Confirm:"/>
                    <Label        Grid.Row="2" Grid.Column="2" Content="Test:"/>
                    <!-- Column 1 -->
                    <TextBox      Grid.Row="0" Grid.Column="3" Name="Control_Domain"/>
                    <PasswordBox  Grid.Row="1" Grid.Column="3" Name="Control_Confirm"/>
                    <Button       Grid.Row="2" Grid.Column="3" Name="Control_Connect" Content="Connect"/>
                </Grid>
            </GroupBox>
            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <GroupBox Grid.Column="0" Header="[Computer]">
                    <Grid Margin="5">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <Grid Grid.Row="0" Height="200" Name="Computer_Backup" VerticalAlignment="Top" Visibility="Collapsed">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="2*"/>
                            </Grid.ColumnDefinitions>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                            </Grid.RowDefinitions>
                            <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type" />
                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Backup_Type"/>
                            <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>
                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Backup_Browse"/>
                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Backup_Path"/>
                        </Grid>
                        <Grid Grid.Row="0" Height="200" Name="Computer_Capture" VerticalAlignment="Top" Visibility="Collapsed">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="2*"/>
                            </Grid.ColumnDefinitions>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                            </Grid.RowDefinitions>
                            <Label      Grid.Row="0" Grid.Column="0" Content="Capture Type" />
                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Capture_Type"/>
                            <Label      Grid.Row="1" Grid.Column="0" Content="Capture Location" />
                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Capture_Browse"/>
                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Capture_Path"/>
                            <Grid       Grid.Row="3" Grid.Column="1">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="70"/>
                                </Grid.ColumnDefinitions>
                                <TextBox  Grid.Column="0" Name="Computer_Capture_FileName"/>
                                <ComboBox Grid.Column="1" Name="Computer_Capture_Extension"/>
                            </Grid>
                            <Label      Grid.Row="3" Grid.Column="0" Content="Capture name" />
                        </Grid>
                    </Grid>
                </GroupBox>
                <GroupBox Grid.Column="1" Header="[User]">
                    <Grid Margin="5">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <Grid Grid.Row="0" Height="200" Name="User_Backup" VerticalAlignment="Top" Visibility="Collapsed">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                            </Grid.RowDefinitions>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="2*"/>
                            </Grid.ColumnDefinitions>
                            <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type"/>
                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Backup_Type" />
                            <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>
                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="User_Backup_Browse"/>
                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Backup_Path"/>
                        </Grid>
                        <Grid Grid.Row="0" Height="200" Name="User_Restore" VerticalAlignment="Top" Visibility="Collapsed">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                                <RowDefinition Height="40"/>
                            </Grid.RowDefinitions>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="2*"/>
                            </Grid.ColumnDefinitions>
                            <Label      Grid.Row="0" Grid.Column="0" Content="Restore Type"/>
                            <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Restore_Type"/>
                            <Label      Grid.Row="1" Grid.Column="0" Content="Restore Location"/>
                            <Button     Grid.Row="1" Grid.Column="1" Content="Browse"/>
                            <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Restore_Path"/>
                        </Grid>
                    </Grid>
                </GroupBox>
            </Grid>
        </Grid>
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button Grid.Column="0" Name="Start" Content="Start"/>
            <Button Grid.Column="1" Name="Cancel" Content="Cancel"/>
        </Grid>
    </Grid>
</Window>
