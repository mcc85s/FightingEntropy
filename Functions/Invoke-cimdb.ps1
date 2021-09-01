Function Invoke-cimdb
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

    Class cimdbGUI
    {
        Static [String]$Tab = @(
            '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://(Company Information Management Database)" Height="680" Width="800" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen" FontFamily="Consolas" Background="LightYellow">',
            '        <Window.Resources>',
            '            <Style TargetType="ToolTip">',
            '                <Setter Property="Background" Value="#000000"/>',
            '                <Setter Property="Foreground" Value="#66D066"/>',
            '            </Style>',
            '            <Style TargetType="TabItem">',
            '                <Setter Property="FontSize" Value="15"/>',
            '                <Setter Property="FontWeight" Value="Heavy"/>',
            '                <Setter Property="Template">',
            '                    <Setter.Value>',
            '                        <ControlTemplate TargetType="TabItem">',
            '                            <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">',
            '                                <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
            '                            </Border>',
            '                            <ControlTemplate.Triggers>',
            '                                <Trigger Property="IsSelected" Value="True">',
            '                                    <Setter TargetName="Border" Property="Background" Value="#4444FF"/>',
            '                                    <Setter Property="Foreground" Value="#FFFFFF"/>',
            '                                </Trigger>',
            '                                <Trigger Property="IsSelected" Value="False">',
            '                                    <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>',
            '                                    <Setter Property="Foreground" Value="#000000"/>',
            '                                </Trigger>',
            '                            </ControlTemplate.Triggers>',
            '                        </ControlTemplate>',
            '                    </Setter.Value>',
            '                </Setter>',
            '            </Style>',
            '            <Style TargetType="Button">',
            '                <Setter Property="Margin" Value="5"/>',
            '                <Setter Property="Padding" Value="5"/>',
            '                <Setter Property="FontSize" Value="15"/>',
            '                <Setter Property="FontWeight" Value="Heavy"/>',
            '                <Setter Property="Foreground" Value="Black"/>',
            '                <Setter Property="Background" Value="#DFFFBA"/>',
            '                <Setter Property="BorderThickness" Value="2"/>',
            '                <Setter Property="VerticalContentAlignment" Value="Center"/>',
            '                <Style.Resources>',
            '                    <Style TargetType="Border">',
            '                        <Setter Property="CornerRadius" Value="2"/>',
            '                    </Style>',
            '                </Style.Resources>',
            '            </Style>',
            '            <Style TargetType="TextBox">',
            '                <Setter Property="Height" Value="24"/>',
            '                <Setter Property="Margin" Value="4"/>',
            '                <Setter Property="FontSize" Value="12"/>',
            '                <Setter Property="VerticalContentAlignment" Value="Center"/>',
            '                <Setter Property="BorderThickness" Value="2"/>',
            '                <Setter Property="Foreground" Value="#000000"/>',
            '                <Style.Resources>',
            '                    <Style TargetType="Border">',
            '                        <Setter Property="CornerRadius" Value="2"/>',
            '                    </Style>',
            '                </Style.Resources>',
            '            </Style>',
            '            <Style TargetType="ComboBox">',
            '                <Setter Property="Height" Value="24"/>',
            '                <Setter Property="Margin" Value="5"/>',
            '                <Setter Property="FontSize" Value="12"/>',
            '                <Setter Property="FontWeight" Value="Normal"/>',
            '            </Style>',
            '            <Style TargetType="DataGrid">',
            '                <Setter Property="AutoGenerateColumns" Value="False"/>',
            '                <Setter Property="AlternationCount" Value="2"/>',
            '                <Setter Property="HeadersVisibility" Value="Column"/>',
            '                <Setter Property="CanUserResizeRows" Value="False"/>',
            '                <Setter Property="CanUserAddRows" Value="False"/>',
            '                <Setter Property="IsTabStop" Value="True" />',
            '                <Setter Property="IsTextSearchEnabled" Value="True"/>',
            '                <Setter Property="IsReadOnly" Value="True"/>',
            '            </Style>',
            '            <Style TargetType="DataGridRow">',
            '                <Style.Triggers>',
            '                    <Trigger Property="AlternationIndex" Value="0">',
            '                        <Setter Property="Background" Value="White"/>',
            '                    </Trigger>',
            '                    <Trigger Property="AlternationIndex" Value="1">',
            '                        <Setter Property="Background" Value="#FFD6FFFB"/>',
            '                    </Trigger>',
            '                    <Trigger Property="IsMouseOver" Value="True">',
            '                        <Setter Property="ToolTip">',
            '                            <Setter.Value>',
            '                                <TextBlock TextWrapping="Wrap" Width="400" Background="#000000" Foreground="#00FF00"/>',
            '                            </Setter.Value>',
            '                        </Setter>',
            '                        <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
            '                    </Trigger>',
            '                </Style.Triggers>',
            '            </Style>',
            '            <Style TargetType="DataGridColumnHeader">',
            '                <Setter Property="FontSize"   Value="12"/>',
            '                <Setter Property="FontWeight" Value="Normal"/>',
            '            </Style>',
            '            <Style TargetType="TabControl">',
            '                <Setter Property="TabStripPlacement" Value="Top"/>',
            '                <Setter Property="HorizontalContentAlignment" Value="Center"/>',
            '                <Setter Property="Background" Value="LightYellow"/>',
            '            </Style>',
            '            <Style TargetType="GroupBox">',
            '                <Setter Property="Foreground" Value="Black"/>',
            '                <Setter Property="Margin" Value="5"/>',
            '                <Setter Property="FontSize" Value="12"/>',
            '                <Setter Property="FontWeight" Value="Normal"/>',
            '            </Style>',
            '        </Window.Resources>',
            '        <Grid>',
            '            <Grid.ColumnDefinitions>',
            '                <ColumnDefinition Width="120"/>',
            '                <ColumnDefinition Width="*"/>',
            '            </Grid.ColumnDefinitions>',
            '            <Grid Grid.Column="0">',
            '                <Grid.RowDefinitions>',
            '                    <RowDefinition Height="120"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="40"/>',
            '                </Grid.RowDefinitions>',
            '                <Button Grid.Row="0" Name="t0">',
            '                    <Image Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\sdplogo.png"/>',
            '                </Button>',
            '                <Button Grid.Row="1" Name="t1" HorizontalContentAlignment="Right" Content="Client"/>',
            '                <Button Grid.Row="2" Name="t2" HorizontalContentAlignment="Right" Content="Service"/>',
            '                <Button Grid.Row="3" Name="t3" HorizontalContentAlignment="Right" Content="Device"/>',
            '                <Button Grid.Row="4" Name="t4" HorizontalContentAlignment="Right" Content="Issue"/>',
            '                <Button Grid.Row="5" Name="t5" HorizontalContentAlignment="Right" Content="Inventory"/>',
            '                <Button Grid.Row="6" Name="t6" HorizontalContentAlignment="Right" Content="Purchase"/>',
            '                <Button Grid.Row="7" Name="t7" HorizontalContentAlignment="Right" Content="Expense"/>',
            '                <Button Grid.Row="8" Name="t8" HorizontalContentAlignment="Right" Content="Account"/>',
            '                <Button Grid.Row="9" Name="t9" HorizontalContentAlignment="Right" Content="Invoice"/>',
            '            </Grid>',
            '            <Grid Grid.Column="1">',
            '                <Grid.RowDefinitions>',
            '                    <RowDefinition Height="40"/>',
            '                    <RowDefinition Height="*"/>',
            '                </Grid.RowDefinitions>',
            '                <Grid Grid.Row="0">',
            '                    <Grid.ColumnDefinitions>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                        <ColumnDefinition Width="*"/>',
            '                    </Grid.ColumnDefinitions>',
            '                    <Button Grid.Column="0" Name="New" Content="New"/>',
            '                    <Button Grid.Column="1" Name="Edit" Content="Edit"/>',
            '                    <Button Grid.Column="2" Name="Save" Content="Save"/>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p0" Visibility="Collapsed">',
            '                    <Grid Name="p0_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p0_x0_UID_______SP"/>',
            '                            <TextBox Grid.Column="1" Name="p0_x0_UID_______SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p0_x0_UID_______SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="UID"    Binding="{Binding UID}"    Width="200"/>',
            '                                <DataGridTextColumn Header="Index"  Binding="{Binding Index}"  Width="50"/>',
            '                                <DataGridTextColumn Header="Slot"   Binding="{Binding Slot}"   Width="50"/>',
            '                                <DataGridTextColumn Header="Date"   Binding="{Binding Date}"   Width="100"/>',
            '                                <DataGridTextColumn Header="Time"   Binding="{Binding Time}"   Width="100"/>',
            '                                <DataGridTextColumn Header="Record" Binding="{Binding Record}" Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p0_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="200"/>',
            '                                <ColumnDefinition Width="120"/>',
            '                                <ColumnDefinition Width="60"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[UID]">',
            '                                <TextBox Name="p0_x1_UID_______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Index]">',
            '                                <TextBox Name="p0_x1_Index_____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Slot]">',
            '                                <TextBox Name="p0_x1_Slot______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Type]">',
            '                                <TextBox Name="p0_x1_Type______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Date]">',
            '                                <TextBox Name="p0_x1_Date______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Time]">',
            '                                <TextBox Name="p0_x1_Time______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="2" Margin="5" Name="p0_x1_Record____LI">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
            '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="2*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p1" Visibility="Collapsed">',
            '                    <Grid Name="p1_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p1_x0_Client____SP"/>',
            '                            <TextBox Grid.Column="1" Name="p1_x0_Client____SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p1_x0_Client____SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="0.25*"/>',
            '                                <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p1_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="0.5*"/>',
            '                                <ColumnDefinition Width="120"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Last]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_Last______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[First]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_First_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[MI]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_MI________TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Gender]" IsEnabled="False">',
            '                                <ComboBox Name="p1_x1_Gender____LI" SelectedIndex="2">',
            '                                    <ComboBoxItem Content="Male"/>',
            '                                    <ComboBoxItem Content="Female"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Address]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_Address___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[DOB(MM/DD/YYYY)]" IsEnabled="False">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <TextBox Grid.Column="0" Name="p1_x1_Month_____TB"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x1_Day_______TB"/>',
            '                                    <TextBox Grid.Column="2" Name="p1_x1_Year______TB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[City]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_City______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Region]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_Region____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Country]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_Country___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Postal]" IsEnabled="False">',
            '                                <TextBox Name="p1_x1_Postal____TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Header="[Phone Number(s)]" Grid.Row="3">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x1_Phone_____TB" IsEnabled="False"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x1_Phone_____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x1_Phone_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x1_Phone_____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Header="[Email Address(es)]" Grid.Row="4">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x1_Email_____TB" IsEnabled="False"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x1_Email_____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x1_Email_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x1_Email_____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="5">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Device(s)" Name="p1_x1_Device____TC" IsEnabled="False"/>',
            '                                <Button Grid.Column="1" Content="Invoice(es)" Name="p1_x1_Invoice___TC" IsEnabled="False"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x1_Device____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x1_Device____SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x1_Device____SF"  IsEnabled="False"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p1_x1_Device____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor"        Binding="{Binding Record.Vendor}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"         Binding="{Binding Record.Model}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="Specification" Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial"        Binding="{Binding Record.Serial}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"         Binding="{Binding Record.Title}"         Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x1_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x1_Invoice___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x1_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Margin="5" Name="p1_x1_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Date" Binding="{Binding Record.Date}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Email" Binding="{Binding Record.First}" Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <Grid Grid.Row="6">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Device(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x1_Device____AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x1_Device____LI"/>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x1_Device____RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Invoice(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x1_Invoice___AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x1_Invoice___LI"/>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x1_Invoice___RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                    </Grid>',
            '                    <Grid Name="p1_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="0.5*"/>',
            '                                <ColumnDefinition Width="120"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Last]">',
            '                                <TextBox Name="p1_x2_Last______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[First]">',
            '                                <TextBox Name="p1_x2_First_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[MI]">',
            '                                <TextBox Name="p1_x2_MI________TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Gender]">',
            '                                <ComboBox Name="p1_x2_Gender____LI" SelectedIndex="2">',
            '                                    <ComboBoxItem Content="Male"/>',
            '                                    <ComboBoxItem Content="Female"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Address]">',
            '                                <TextBox Name="p1_x2_Address___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[DOB(MM/DD/YYYY)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <TextBox Grid.Column="0" Name="p1_x2_Month_____TB"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x2_Day_______TB"/>',
            '                                    <TextBox Grid.Column="2" Name="p1_x2_Year______TB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[City]">',
            '                                <TextBox Name="p1_x2_City______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Region]">',
            '                                <TextBox Name="p1_x2_Region____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Country]">',
            '                                <TextBox Name="p1_x2_Country___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Postal]">',
            '                                <TextBox Name="p1_x2_Postal____TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Header="[Phone Number(s)]" Grid.Row="3">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x2_Phone_____TB"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x2_Phone_____AB"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x2_Phone_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x2_Phone_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Header="[Email Address(es)]" Grid.Row="4">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x2_Email_____TB"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x2_Email_____AB"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x2_Email_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x2_Email_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="5">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Device(s)" Name="p1_x2_Device____TC"/>',
            '                                <Button Grid.Column="1" Content="Invoice(es)" Name="p1_x2_Invoice___TC"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x2_Device____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x2_Device____SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x2_Device____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p1_x2_Device____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor"        Binding="{Binding Record.Vendor}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"         Binding="{Binding Record.Model}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="Specification" Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial"        Binding="{Binding Record.Serial}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"         Binding="{Binding Record.Title}"         Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x2_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x2_Invoice___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x2_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Margin="5" Name="p1_x2_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Date" Binding="{Binding Record.Date}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Email" Binding="{Binding Record.First}" Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <Grid Grid.Row="6">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Device(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x2_Device____AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x2_Device____LI"/>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x2_Device____RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Invoice(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x2_Invoice___AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x2_Invoice___LI"/>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x2_Invoice___RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                    </Grid>',
            '                    <Grid Name="p1_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="0.5*"/>',
            '                                <ColumnDefinition Width="120"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Last]">',
            '                                <TextBox Name="p1_x3_Last______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[First]">',
            '                                <TextBox Name="p1_x3_First_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[MI]">',
            '                                <TextBox Name="p1_x3_MI________TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Gender]">',
            '                                <ComboBox Name="p1_x3_Gender____LI" SelectedIndex="2">',
            '                                    <ComboBoxItem Content="Male"/>',
            '                                    <ComboBoxItem Content="Female"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Address]">',
            '                                <TextBox Name="p1_x3_Address___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[DOB(MM/DD/YYYY)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="0.6*"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <TextBox Grid.Column="0" Name="p1_x3_Month_____TB"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x3_Day_______TB"/>',
            '                                    <TextBox Grid.Column="2" Name="p1_x3_Year______TB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="3*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[City]">',
            '                                <TextBox Name="p1_x3_City______TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Region]">',
            '                                <TextBox Name="p1_x3_Region____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Country]">',
            '                                <TextBox Name="p1_x3_Country___TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Postal]">',
            '                                <TextBox Name="p1_x3_Postal____TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Header="[Phone Number(s)]" Grid.Row="3">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x3_Phone_____TB"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x3_Phone_____AB"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x3_Phone_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x3_Phone_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Header="[Email Address(es)]" Grid.Row="4">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <TextBox Grid.Column="0" Name="p1_x3_Email_____TB"/>',
            '                                <Button Grid.Column="1" Margin="5" Content="+" Name="p1_x3_Email_____AB"/>',
            '                                <ComboBox Grid.Column="2" Name="p1_x3_Email_____LI"/>',
            '                                <Button Grid.Column="3" Margin="5" Content="-" Name="p1_x3_Email_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="5">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="160"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Device(s)" Name="p1_x3_Device____TC"/>',
            '                                <Button Grid.Column="1" Content="Invoice(es)" Name="p1_x3_Invoice___TC"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x3_Device____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x3_Device____SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x3_Device____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p1_x3_Device____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor"        Binding="{Binding Record.Vendor}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"         Binding="{Binding Record.Model}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="Specification" Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial"        Binding="{Binding Record.Serial}"        Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"         Binding="{Binding Record.Title}"         Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p1_x3_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="50"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p1_x3_Invoice___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p1_x3_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Margin="5" Name="p1_x3_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Date" Binding="{Binding Record.Date}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Email" Binding="{Binding Record.First}" Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <Grid Grid.Row="6">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Device(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x3_Device____AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x3_Device____LI">',
            '                                        <ComboBox.ItemTemplate>',
            '                                            <DataTemplate>',
            '                                                <TextBlock Text="{Binding Record.Name}"/>',
            '                                            </DataTemplate>',
            '                                        </ComboBox.ItemTemplate>',
            '                                    </ComboBox>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x3_Device____RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Invoice(s)]">',
            '                                <Grid>',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <Button Grid.Column="0" Content="+" Name="p1_x3_Invoice___AB"/>',
            '                                    <ComboBox Grid.Column="1" Name="p1_x3_Invoice___LI">',
            '                                        <ComboBox.ItemTemplate>',
            '                                            <DataTemplate>',
            '                                                <TextBlock Text="{Binding Record.Rank}"/>',
            '                                            </DataTemplate>',
            '                                        </ComboBox.ItemTemplate>',
            '                                    </ComboBox>',
            '                                    <Button Grid.Column="2" Content="-" Name="p1_x3_Invoice___RB"/>',
            '                                </Grid>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p2" Visibility="Collapsed">',
            '                    <Grid Name="p2_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p2_x0_Service___SP"/>',
            '                            <TextBox Grid.Column="1" Name="p2_x0_Service___SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p2_x0_Service___SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Name"        Binding="{Binding Record.Name}" Width="*"/>',
            '                                <DataGridTextColumn Header="Description" Binding="{Binding Record.Description}" Width="*"/>',
            '                                <DataGridTextColumn Header="Cost"        Binding="{Binding Record.Cost}" Width="0.5*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p2_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Name]">',
            '                            <TextBox Name="p2_x1_Name______TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Description]">',
            '                            <TextBox Name="p2_x1_Descript__TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Cost]">',
            '                            <TextBox Name="p2_x1_Cost______TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p2_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Name]">',
            '                            <TextBox Name="p2_x2_Name______TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Description]">',
            '                            <TextBox Name="p2_x2_Descript__TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Cost]">',
            '                            <TextBox Name="p2_x2_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p2_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Name]">',
            '                            <TextBox Name="p2_x3_Name______TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Description]">',
            '                            <TextBox Name="p2_x3_Descript__TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Cost]">',
            '                            <TextBox Name="p2_x3_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p3" Visibility="Collapsed">',
            '                    <Grid Name="p3_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p3_x0_Device____SP"/>',
            '                            <TextBox Grid.Column="1" Name="p3_x0_Device____SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p3_x0_Device____SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Vendor"        Binding="{Binding Record.Vendor}"        Width="*"/>',
            '                                <DataGridTextColumn Header="Model"         Binding="{Binding Record.Model}"         Width="*"/>',
            '                                <DataGridTextColumn Header="Specification" Binding="{Binding Record.Specification}" Width="*"/>',
            '                                <DataGridTextColumn Header="Serial"        Binding="{Binding Record.Serial}"        Width="*"/>',
            '                                <DataGridTextColumn Header="Title"         Binding="{Binding Record.Title}"         Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p3_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Chassis]">',
            '                                <ComboBox Name="p3_x1_Chassis___LI" SelectedIndex="8" IsEnabled="False">',
            '                                    <ComboBoxItem Content="Desktop"/>',
            '                                    <ComboBoxItem Content="Laptop"/>',
            '                                    <ComboBoxItem Content="Smartphone"/>',
            '                                    <ComboBoxItem Content="Tablet"/>',
            '                                    <ComboBoxItem Content="Console"/>',
            '                                    <ComboBoxItem Content="Server"/>',
            '                                    <ComboBoxItem Content="Network"/>',
            '                                    <ComboBoxItem Content="Other"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Vendor]">',
            '                                <TextBox Name="p3_x1_Vendor____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Model]">',
            '                                <TextBox Name="p3_x1_Model_____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Specification]">',
            '                                <TextBox Name="p3_x1_Spec______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Serial]">',
            '                                <TextBox Name="p3_x1_Serial____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Display Name]">',
            '                                <TextBox Name="p3_x1_Display___TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Client"   Name="p3_x1_Client____TC" IsEnabled="False"/>',
            '                                <Button Grid.Column="1" Content="Issue"    Name="p3_x1_Issue_____TC" IsEnabled="False"/>',
            '                                <Button Grid.Column="2" Content="Purchase" Name="p3_x1_Purchase__TC" IsEnabled="False"/>',
            '                                <Button Grid.Column="3" Content="Invoice"  Name="p3_x1_Invoice___TC" IsEnabled="False"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x1_Client____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x1_Client____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x1_Client____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Grid.Column="0" Name="p3_x1_Client____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.DisplayName}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                        <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}" Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x1_Issue_____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x1_Issue_____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x1_Issue_____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x1_Issue_____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x1_Purchase__TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x1_Purchase__SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x1_Purchase__SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x1_Purchase__SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Name"   Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"   Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"   Width="*"/>',
            '                                        <DataGridTextColumn Header="Device" Binding="{Binding Record.Device}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"  Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x1_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x1_Invoice___SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x1_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x1_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x1_Client____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x1_Client____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x1_Client____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Issue(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x1_Issue_____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x1_Issue_____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x1_Issue_____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Purchase(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x1_Purchase__AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x1_Purchase__LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x1_Purchase__RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x1_Invoice___AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x1_Invoice___LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x1_Invoice___RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p3_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Chassis]">',
            '                                <ComboBox Name="p3_x2_Chassis___LI" SelectedIndex="8">',
            '                                    <ComboBoxItem Content="Desktop"/>',
            '                                    <ComboBoxItem Content="Laptop"/>',
            '                                    <ComboBoxItem Content="Smartphone"/>',
            '                                    <ComboBoxItem Content="Tablet"/>',
            '                                    <ComboBoxItem Content="Console"/>',
            '                                    <ComboBoxItem Content="Server"/>',
            '                                    <ComboBoxItem Content="Network"/>',
            '                                    <ComboBoxItem Content="Other"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Vendor]">',
            '                                <TextBox Name="p3_x2_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Model]">',
            '                                <TextBox Name="p3_x2_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Specification]">',
            '                                <TextBox Name="p3_x2_Spec______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Serial]">',
            '                                <TextBox Name="p3_x2_Serial____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Display Name]">',
            '                                <TextBox Name="p3_x2_Display___TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Client"   Name="p3_x2_Client____TC"/>',
            '                                <Button Grid.Column="1" Content="Issue"    Name="p3_x2_Issue_____TC"/>',
            '                                <Button Grid.Column="2" Content="Purchase" Name="p3_x2_Purchase__TC"/>',
            '                                <Button Grid.Column="3" Content="Invoice"  Name="p3_x2_Invoice___TC"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x2_Client____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x2_Client____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x2_Client____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Grid.Column="0" Name="p3_x2_Client____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.DisplayName}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                        <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x2_Issue_____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x2_Issue_____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x2_Issue_____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x2_Issue_____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x2_Purchase__TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x2_Purchase__SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x2_Purchase__SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x2_Purchase__SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.First}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        <DataGridTextColumn Header="Device" Binding="{Binding Record.IsDevice}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x2_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x2_Invoice___SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x2_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x2_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x2_Client____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x2_Client____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x2_Client____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Issue(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x2_Issue_____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x2_Issue_____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x2_Issue_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Purchase(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x2_Purchase__AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x2_Purchase__LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x2_Purchase__RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x2_Invoice___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x2_Invoice___LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x2_Invoice___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p3_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="1.5*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Chassis]">',
            '                                <ComboBox Name="p3_x3_Chassis___LI" SelectedIndex="8">',
            '                                    <ComboBoxItem Content="Desktop"/>',
            '                                    <ComboBoxItem Content="Laptop"/>',
            '                                    <ComboBoxItem Content="Smartphone"/>',
            '                                    <ComboBoxItem Content="Tablet"/>',
            '                                    <ComboBoxItem Content="Console"/>',
            '                                    <ComboBoxItem Content="Server"/>',
            '                                    <ComboBoxItem Content="Network"/>',
            '                                    <ComboBoxItem Content="Other"/>',
            '                                    <ComboBoxItem Content="-"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Vendor]">',
            '                                <TextBox Name="p3_x3_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Model]">',
            '                                <TextBox Name="p3_x3_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="3" Header="[Specification]">',
            '                                <TextBox Name="p3_x3_Spec______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Serial]">',
            '                                <TextBox Name="p3_x3_Serial____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Display Name]">',
            '                                <TextBox Name="p3_x3_Display___TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.RowDefinitions>',
            '                                <RowDefinition Height="40"/>',
            '                                <RowDefinition Height="*"/>',
            '                            </Grid.RowDefinitions>',
            '                            <Grid Grid.Row="0">',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="Client"   Name="p3_x3_Client____TC"/>',
            '                                <Button Grid.Column="1" Content="Issue"    Name="p3_x3_Issue_____TC"/>',
            '                                <Button Grid.Column="2" Content="Purchase" Name="p3_x3_Purchase__TC"/>',
            '                                <Button Grid.Column="3" Content="Invoice"  Name="p3_x3_Invoice___TC"/>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x3_Client____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x3_Client____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x3_Client____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Grid.Column="0" Name="p3_x3_Client____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.DisplayName}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"         Width="*"/>',
            '                                        <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                        <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x3_Issue_____TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x3_Issue_____SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x3_Issue_____SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x3_Issue_____SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x3_Purchase__TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x3_Purchase__SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x3_Purchase__SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x3_Purchase__SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Vendor" Binding="{Binding Record.First}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Serial"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        <DataGridTextColumn Header="Device" Binding="{Binding Record.IsDevice}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                            <Grid Grid.Row="1" Name="p3_x3_Invoice___TI" Visibility="Collapsed">',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="40"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="150"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Row="0" Grid.Column="0" Name="p3_x3_Invoice___SP"/>',
            '                                    <TextBox Grid.Row="0" Grid.Column="1" Name="p3_x3_Invoice___SF"/>',
            '                                </Grid>',
            '                                <DataGrid Grid.Row="1" Name="p3_x3_Invoice___SR">',
            '                                    <DataGrid.Columns>',
            '                                        <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                        <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                        <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                    </DataGrid.Columns>',
            '                                </DataGrid>',
            '                            </Grid>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x3_Client____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x3_Client____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x3_Client____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Issue(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x3_Issue_____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x3_Issue_____LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x3_Issue_____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Purchase(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x3_Purchase__AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x3_Purchase__LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x3_Purchase__RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice(s)]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p3_x3_Invoice___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p3_x3_Invoice___LI">',
            '                                    <ComboBox.ItemTemplate>',
            '                                        <DataTemplate>',
            '                                            <TextBlock Text="{Binding Record.DisplayName}"/>',
            '                                        </DataTemplate>',
            '                                    </ComboBox.ItemTemplate>',
            '                                </ComboBox>',
            '                                <Button Grid.Column="2" Content="-" Name="p3_x3_Invoice___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p4" Visibility="Collapsed">',
            '                    <Grid Name="p4_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p4_x0_Issue_____SP"/>',
            '                            <TextBox Grid.Column="1" Name="p4_x0_Issue_____SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p4_x0_Issue_____SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Client"   Binding="{Binding Record.Client}"   Width="*"/>',
            '                                <DataGridTextColumn Header="Device"   Binding="{Binding Record.Device}"   Width="*"/>',
            '                                <DataGridTextColumn Header="Status"   Binding="{Binding Record.Status}"   Width="*"/>',
            '                                <DataGridTextColumn Header="Purchase" Binding="{Binding Record.Purchase}" Width="*"/>',
            '                                <DataGridTextColumn Header="Service"  Binding="{Binding Record.Service}"  Width="*"/>',
            '                                <DataGridTextColumn Header="Invoice"  Binding="{Binding Record.Invoice}"  Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p4_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Status]" IsEnabled="False">',
            '                                <ComboBox Name="p4_x1_Status____LI">',
            '                                    <ComboBoxItem Content="New"/>',
            '                                    <ComboBoxItem Content="Diagnosed"/>',
            '                                    <ComboBoxItem Content="Commit"/>',
            '                                    <ComboBoxItem Content="Complete"/>',
            '                                </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Description]" IsEnabled="False">',
            '                                <TextBox Name="p4_x1_Descript__TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <TabControl Grid.Row="1" Name="p4_x1_Issue_____TC" IsEnabled="False">',
            '                            <TabItem Header="Client">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x1_Client____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x1_Client____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x1_Client____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Device">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x1_Device____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x1_Device____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x1_Device____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Purchase">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x1_Purchase__SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x1_Purchase__SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x1_Purchase__SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                            <DataGridTextColumn Header="Device" Binding="{Binding Record.IsDevice}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Service">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x1_Service___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x1_Service___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x1_Service___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Description"  Binding="{Binding Record.Description}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Cost" Binding="{Binding Record.Cost}" Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Invoice">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x1_Invoice___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x1_Invoice___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x1_Invoice___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                        </TabControl>',
            '                        <GroupBox Grid.Row="2" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x1_Client____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x1_Client____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x1_Client____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x1_Device____AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x1_Device____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x1_Device____RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x1_Purchase__AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x1_Purchase__LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x1_Purchase__RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x1_Service___AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x1_Service___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x1_Service___RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x1_Invoice___AB" IsEnabled="False"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x1_Invoice___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x1_Invoice___RB" IsEnabled="False"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p4_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Status]">',
            '                                <ComboBox Name="p4_x2_Status____LI">',
            '                                    <ComboBoxItem Content="New"/>',
            '                                        <ComboBoxItem Content="Diagnosed"/>',
            '                                        <ComboBoxItem Content="Commit"/>',
            '                                        <ComboBoxItem Content="Complete"/>',
            '                                    </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Description]">',
            '                                <TextBox Name="p4_x2_Descript__TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <TabControl Grid.Row="1" Name="p4_x2_Issue_____TC">',
            '                            <TabItem Header="Client">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x2_Client____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x2_Client____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x2_Client____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Device">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x2_Device____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x2_Device____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x2_Device____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Purchase">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x2_Purchase__SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x2_Purchase__SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x2_Purchase__SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                            <DataGridTextColumn Header="Device" Binding="{Binding Record.IsDevice}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Service">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x2_Service___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x2_Service___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x2_Service___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Description"  Binding="{Binding Record.Description}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Cost" Binding="{Binding Record.Cost}" Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Invoice">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x2_Invoice___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x2_Invoice___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x2_Invoice___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                        </TabControl>',
            '                        <GroupBox Grid.Row="2" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x2_Client____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x2_Client____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x2_Client____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x2_Device____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x2_Device____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x2_Device____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x2_Purchase__AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x2_Purchase__LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x2_Purchase__RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x2_Service___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x2_Service___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x2_Service___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x2_Invoice___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x2_Invoice___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x2_Invoice___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p4_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="200"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Status]">',
            '                                <ComboBox Name="p4_x3_Status____LI">',
            '                                    <ComboBoxItem Content="New"/>',
            '                                        <ComboBoxItem Content="Diagnosed"/>',
            '                                        <ComboBoxItem Content="Commit"/>',
            '                                        <ComboBoxItem Content="Complete"/>',
            '                                    </ComboBox>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Description]">',
            '                                <TextBox Name="p4_x3_Descript__TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <TabControl Grid.Row="1" Name="p4_x3_Issue_____TC">',
            '                            <TabItem Header="Client">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x3_Client____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x3_Client____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x3_Client____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Last"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="First" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="MI"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="DOB"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Device">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x3_Device____SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x3_Device____SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x3_Device____SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.Vendor}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"  Binding="{Binding Record.Model}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Spec."  Binding="{Binding Record.Specification}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial" Binding="{Binding Record.Serial}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Title"  Binding="{Binding Record.Title}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Purchase">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x3_Purchase__SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x3_Purchase__SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x3_Purchase__SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Vendor" Binding="{Binding Record.First}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Serial"    Binding="{Binding Record.MI}"    Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                            <DataGridTextColumn Header="Device" Binding="{Binding Record.IsDevice}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Model"   Binding="{Binding Record.DOB}"   Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Service">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x3_Service___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x3_Service___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x3_Service___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Description"  Binding="{Binding Record.Description}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Cost" Binding="{Binding Record.Cost}" Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                            <TabItem Header="Invoice">',
            '                                <Grid>',
            '                                    <Grid.RowDefinitions>',
            '                                        <RowDefinition Height="50"/>',
            '                                        <RowDefinition Height="*"/>',
            '                                    </Grid.RowDefinitions>',
            '                                    <Grid Grid.Row="0" Margin="5">',
            '                                        <Grid.ColumnDefinitions>',
            '                                            <ColumnDefinition Width="150"/>',
            '                                            <ColumnDefinition Width="*"/>',
            '                                        </Grid.ColumnDefinitions>',
            '                                        <ComboBox Grid.Column="0" Name="p4_x3_Invoice___SP"/>',
            '                                        <TextBox Grid.Column="1" Name="p4_x3_Invoice___SF"/>',
            '                                    </Grid>',
            '                                    <DataGrid Grid.Row="1" Name="p4_x3_Invoice___SR">',
            '                                        <DataGrid.Columns>',
            '                                            <DataGridTextColumn Header="UID"   Binding="{Binding Record.UID}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Date"  Binding="{Binding Record.Date}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                            <DataGridTextColumn Header="Phone" Binding="{Binding Record.Phone}" Width="*"/>',
            '                                            <DataGridTextColumn Header="Email"  Binding="{Binding Record.Email}"  Width="*"/>',
            '                                        </DataGrid.Columns>',
            '                                    </DataGrid>',
            '                                </Grid>',
            '                            </TabItem>',
            '                        </TabControl>',
            '                        <GroupBox Grid.Row="2" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x3_Client____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x3_Client____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x3_Client____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x3_Device____AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x3_Device____LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x3_Device____RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x3_Purchase__AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x3_Purchase__LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x3_Purchase__RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x3_Service___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x3_Service___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x3_Service___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="6" Header="[Invoice]">',
            '                            <Grid>',
            '                                <Grid.ColumnDefinitions>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                    <ColumnDefinition Width="*"/>',
            '                                    <ColumnDefinition Width="40"/>',
            '                                </Grid.ColumnDefinitions>',
            '                                <Button Grid.Column="0" Content="+" Name="p4_x3_Invoice___AB"/>',
            '                                <ComboBox Grid.Column="1" Name="p4_x3_Invoice___LI"/>',
            '                                <Button Grid.Column="2" Content="-" Name="p4_x3_Invoice___RB"/>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p5" Visibility="Collapsed">',
            '                    <Grid Name="p5_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p5_x0_Inventory_SP"/>',
            '                            <TextBox Grid.Column="1" Name="p5_x0_Inventory_SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p5_x0_Inventory_SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Vendor"     Binding="{Binding Record.Vendor}"   Width="*"/>',
            '                                <DataGridTextColumn Header="Serial"     Binding="{Binding Record.Serial}"   Width="*"/>',
            '                                <DataGridTextColumn Header="Model"      Binding="{Binding Record.Model}"    Width="*"/>',
            '                                <DataGridTextColumn Header="Title"      Binding="{Binding Record.Title}"    Width="2*"/>',
            '                                <DataGridTemplateColumn Header="Device" Width="60">',
            '                                    <DataGridTemplateColumn.CellTemplate>',
            '                                        <DataTemplate>',
            '                                            <ComboBox SelectedIndex="{Binding Record.IsDevice}">',
            '                                                <ComboBoxItem Content="N"/>',
            '                                                <ComboBoxItem Content="Y"/>',
            '                                                <ComboBoxItem Content="-"/>',
            '                                            </ComboBox>',
            '                                        </DataTemplate>',
            '                                    </DataGridTemplateColumn.CellTemplate>',
            '                                </DataGridTemplateColumn>',
            '                                <DataGridTextColumn Header="Cost"  Binding="{Binding Record.Cost}" Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p5_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p5_x1_Vendor____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p5_x1_Model_____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Serial]">',
            '                                <TextBox Name="p5_x1_Serial____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Title]">',
            '                                <TextBox Name="p5_x1_Title_____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Cost]">',
            '                                <TextBox Name="p5_x1_Cost______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="2" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p5_x1_IsDevice__LI" IsEnabled="False">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p5_x1_Device____SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="2" Name="p5_x1_Device____SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p5_x1_Device____SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p5_x1_Device____AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p5_x1_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p5_x1_Device____RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p5_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p5_x2_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p5_x2_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Serial]">',
            '                                <TextBox Name="p5_x2_Serial____TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Title]">',
            '                                <TextBox Name="p5_x2_Title_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Cost]">',
            '                                <TextBox Name="p5_x2_Cost______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="2" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p5_x2_IsDevice__LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p5_x2_Device____SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p5_x2_Device____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p5_x2_Device____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p5_x2_Device____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p5_x2_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p5_x2_Device____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p5_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p5_x3_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p5_x3_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Serial]">',
            '                                <TextBox Name="p5_x3_Serial____TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <Grid Grid.Row="1">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Title]">',
            '                                <TextBox Name="p5_x3_Title_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Cost]">',
            '                                <TextBox Name="p5_x3_Cost______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="2" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p5_x3_IsDevice__LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p5_x3_Device____SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p5_x3_Device____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p5_x3_Device____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p5_x3_Device____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p5_x3_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p5_x3_Device____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p6" Visibility="Collapsed">',
            '                    <Grid Name="p6_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p6_x0_Purchase__SP"/>',
            '                            <TextBox Grid.Column="1" Name="p6_x0_Purchase__SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p6_x0_Purchase__SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Distributor"  Binding="{Binding Record.Distributor}" Width="*"/>',
            '                                <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.DisplayName}" Width="*"/>',
            '                                <DataGridTextColumn Header="Vendor"       Binding="{Binding Record.Vendor}"      Width="*"/>',
            '                                <DataGridTextColumn Header="Serial"       Binding="{Binding Record.Serial}"      Width="2*"/>',
            '                                <DataGridTextColumn Header="Model"        Binding="{Binding Record.Model}"       Width="*"/>',
            '                                <DataGridTemplateColumn Header="Device"   Width="60">',
            '                                    <DataGridTemplateColumn.CellTemplate>',
            '                                        <DataTemplate>',
            '                                            <ComboBox SelectedIndex="{Binding Record.IsDevice}">',
            '                                                <ComboBoxItem Content="N"/>',
            '                                                <ComboBoxItem Content="Y"/>',
            '                                                <ComboBoxItem Content="-"/>',
            '                                            </ComboBox>',
            '                                        </DataTemplate>',
            '                                    </DataGridTemplateColumn.CellTemplate>',
            '                                </DataGridTemplateColumn>',
            '                                <DataGridTextColumn Header="Cost"  Binding="{Binding Record.Cost}" Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p6_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Distributor]">',
            '                            <TextBox Name="p6_x1_Dist______TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p6_x1_Display___TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p6_x1_Vendor____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p6_x1_Model_____TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Specification]">',
            '                                <TextBox Name="p6_x1_Spec______TB" IsEnabled="False"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Serial]">',
            '                            <TextBox Name="p6_x1_Serial____TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p6_x1_IsDevice__LI" IsEnabled="False">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p6_x1_Device____SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="2" Name="p6_x1_Device____SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p6_x1_Device____SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p6_x1_Device____AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p6_x1_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p6_x1_Device____RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Cost]">',
            '                            <TextBox Name="p6_x1_Cost______TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p6_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Distributor]">',
            '                            <TextBox Name="p6_x2_Dist______TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p6_x2_Display___TB"/>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p6_x2_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p6_x2_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Specification]">',
            '                                <TextBox Name="p6_x2_Spec______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Serial]">',
            '                            <TextBox Name="p6_x2_Serial____TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p6_x2_IsDevice__LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p6_x2_Device____SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p6_x2_Device____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p6_x2_Device____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p6_x2_Device____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p6_x2_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p6_x2_Device____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Cost]">',
            '                            <TextBox Name="p6_x2_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p6_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Distributor]">',
            '                            <TextBox Name="p6_x3_Dist______TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p6_x3_Display___TB"/>',
            '                        </GroupBox>',
            '                        <Grid Grid.Row="2">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="2*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <GroupBox Grid.Column="0" Header="[Vendor]">',
            '                                <TextBox Name="p6_x3_Vendor____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="1" Header="[Model]">',
            '                                <TextBox Name="p6_x3_Model_____TB"/>',
            '                            </GroupBox>',
            '                            <GroupBox Grid.Column="2" Header="[Specification]">',
            '                                <TextBox Name="p6_x3_Spec______TB"/>',
            '                            </GroupBox>',
            '                        </Grid>',
            '                        <GroupBox Grid.Row="3" Header="[Serial]">',
            '                            <TextBox Name="p6_x3_Serial____TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Device]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="60"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="1" Name="p6_x3_IsDevice__LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p6_x3_Device____SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p6_x3_Device____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p6_x3_Device____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p6_x3_Device____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p6_x3_Device____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p6_x3_Device____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="5" Header="[Cost]">',
            '                            <TextBox Name="p6_x3_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p7" Visibility="Collapsed">',
            '                    <Grid Name="p7_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p7_x0_Expense___SP"/>',
            '                            <TextBox Grid.Column="1" Name="p7_x0_Expense___SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p7_x0_Expense___SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Recipient"    Binding="{Binding Record.Recipient}"   Width="*"/>',
            '                                <DataGridTextColumn Header="DisplayName"  Binding="{Binding Record.DisplayName}" Width="1.5*"/>',
            '                                <DataGridTextColumn Header="Account"      Binding="{Binding Record.Account}"     Width="*"/>',
            '                                <DataGridTextColumn Header="Cost"         Binding="{Binding Record.Cost}"        Width="0.5*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p7_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Recipient]">',
            '                            <TextBox Name="p7_x1_Recipient_TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p7_x1_Display___TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Account]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>                                    ',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p7_x1_IsAccount_LI" IsEnabled="False">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p7_x1_Account___SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="2" Name="p7_x1_Account___SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p7_x1_Account___SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p7_x1_Account___AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p7_x1_Account___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p7_x1_Account___RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Cost]">',
            '                            <TextBox Name="p7_x1_Cost______TB" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p7_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Recipient]">',
            '                            <TextBox Name="p7_x2_Recipient_TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p7_x2_Display___TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Account]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p7_x2_IsAccount_LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p7_x2_Account___SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p7_x2_Account___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p7_x2_Account___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p7_x2_Account___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p7_x2_Account___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p7_x2_Account___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Cost]">',
            '                            <TextBox Name="p7_x2_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p7_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="70"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Recipient]">',
            '                            <TextBox Name="p7_x3_Recipient_TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Display Name]">',
            '                            <TextBox Name="p7_x3_Display___TB"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Account]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" SelectedIndex="0" Name="p7_x3_IsAccount_LI">',
            '                                        <ComboBoxItem Content="No"/>',
            '                                        <ComboBoxItem Content="Yes"/>',
            '                                    </ComboBox>',
            '                                    <ComboBox Grid.Column="1" Name="p7_x3_Account___SP"/>',
            '                                    <TextBox Grid.Column="2" Name="p7_x3_Account___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p7_x3_Account___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p7_x3_Account___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p7_x3_Account___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p7_x3_Account___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Cost]">',
            '                            <TextBox Name="p7_x3_Cost______TB"/>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p8" Visibility="Collapsed">',
            '                    <Grid Name="p8_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p8_x0_Account___SP"/>',
            '                            <TextBox Grid.Column="1" Name="p8_x0_Account___SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p8_x0_Account___SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Object"  Binding="{Binding Record.Object}" Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p8_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Column="0" Header="[Object]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x1_AcctObj___SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p8_x1_AcctObj___SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x1_AcctObj___SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p8_x1_AcctObj___AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p8_x1_AcctObj___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p8_x1_AcctObj___RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p8_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Column="0" Header="[Object]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x2_AcctObj___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p8_x2_AcctObj___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x2_AcctObj___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p8_x2_AcctObj___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p8_x2_AcctObj___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p8_x2_AcctObj___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p8_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Column="0" Header="[Object]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x3_AcctObj___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p8_x3_AcctObj___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p8_x3_AcctObj___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p8_x3_AcctObj___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p8_x3_AcctObj___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p8_x3_AcctObj___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '                <Grid Grid.Row="1" Name="p9" Visibility="Collapsed">',
            '                    <Grid Name="p9_x0" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="40"/>',
            '                            <RowDefinition Height="*"/>',
            '                        </Grid.RowDefinitions>',
            '                        <Grid Grid.Row="0">',
            '                            <Grid.ColumnDefinitions>',
            '                                <ColumnDefinition Width="*"/>',
            '                                <ColumnDefinition Width="4*"/>',
            '                            </Grid.ColumnDefinitions>',
            '                            <ComboBox Grid.Column="0" Name="p9_x0_Invoice___SP"/>',
            '                            <TextBox Grid.Column="1" Name="p9_x0_Invoice___SF"/>',
            '                        </Grid>',
            '                        <DataGrid Grid.Row="1" Margin="5" Name="p9_x0_Invoice___SR">',
            '                            <DataGrid.Columns>',
            '                                <DataGridTextColumn Header="Date" Binding="{Binding Record.Date}" Width="*"/>',
            '                                <DataGridTextColumn Header="Name"  Binding="{Binding Record.Name}"  Width="*"/>',
            '                                <DataGridTextColumn Header="Phone"  Binding="{Binding Record.Last}"  Width="*"/>',
            '                                <DataGridTextColumn Header="Email" Binding="{Binding Record.First}" Width="*"/>',
            '                            </DataGrid.Columns>',
            '                        </DataGrid>',
            '                    </Grid>',
            '                    <Grid Name="p9_x1" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Mode]">',
            '                            <ComboBox Name="p9_x1_Mode______LI" IsEnabled="False"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Client____SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x1_Client____SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Client____SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x1_Client____AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x1_Client____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x1_Client____RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Inventory]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Inventory_SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x1_Inventory_SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Inventory_SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x1_Inventory_AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x1_Inventory_LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x1_Inventory_RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Service___SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x1_Service___SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Service___SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x1_Service___AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x1_Service___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x1_Service___RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Purchase__SP" IsEnabled="False"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x1_Purchase__SF" IsEnabled="False"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x1_Purchase__SR" IsEnabled="False"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x1_Purchase__AB" IsEnabled="False"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x1_Purchase__LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x1_Purchase__RB" IsEnabled="False"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p9_x2" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Mode]">',
            '                            <ComboBox Name="p9_x2_Mode______LI"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Client____SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x2_Client____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Client____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x2_Client____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x2_Client____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x2_Client____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Inventory]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Inventory_SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x2_Inventory_SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Inventory_SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x2_Inventory_AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x2_Inventory_LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x2_Inventory_RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Service___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x2_Service___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Service___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x2_Service___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x2_Service___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x2_Service___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Purchase__SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x2_Purchase__SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x2_Purchase__SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x2_Purchase__AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x2_Purchase__LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x2_Purchase__RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                    <Grid Name="p9_x3" Visibility="Collapsed">',
            '                        <Grid.RowDefinitions>',
            '                            <RowDefinition Height="70"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                            <RowDefinition Height="105"/>',
            '                        </Grid.RowDefinitions>',
            '                        <GroupBox Grid.Row="0" Header="[Mode]">',
            '                            <ComboBox Name="p9_x3_Mode______LI"/>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="1" Header="[Client]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Client____SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x3_Client____SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Client____SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x3_Client____AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x3_Client____LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x3_Client____RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="2" Header="[Inventory]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Inventory_SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x3_Inventory_SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Inventory_SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x3_Inventory_AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x3_Inventory_LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x3_Inventory_RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="3" Header="[Service]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Service___SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x3_Service___SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Service___SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x3_Service___AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x3_Service___LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x3_Service___RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                        <GroupBox Grid.Row="4" Header="[Purchase]">',
            '                            <Grid>',
            '                                <Grid.RowDefinitions>',
            '                                    <RowDefinition Height="*"/>',
            '                                    <RowDefinition Height="*"/>',
            '                                </Grid.RowDefinitions>',
            '                                <Grid Grid.Row="0">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="120"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Purchase__SP"/>',
            '                                    <TextBox Grid.Column="1" Name="p9_x3_Purchase__SF"/>',
            '                                </Grid>',
            '                                <Grid Grid.Row="1">',
            '                                    <Grid.ColumnDefinitions>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                        <ColumnDefinition Width="*"/>',
            '                                        <ColumnDefinition Width="40"/>',
            '                                    </Grid.ColumnDefinitions>',
            '                                    <ComboBox Grid.Column="0" Name="p9_x3_Purchase__SR"/>',
            '                                    <Button Grid.Column="1" Content="+" Name="p9_x3_Purchase__AB"/>',
            '                                    <ComboBox Grid.Column="2" Name="p9_x3_Purchase__LI"/>',
            '                                    <Button Grid.Column="3" Content="-" Name="p9_x3_Purchase__RB"/>',
            '                                </Grid>',
            '                            </Grid>',
            '                        </GroupBox>',
            '                    </Grid>',
            '                </Grid>',
            '            </Grid>',
            '        </Grid>',
            '    </Window>' -join "`n" )
    }

    Class DGList
    {
        [String] $Name
        [Object] $Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value -join ", "
        }
    }

    Class Postal
    {
        Hidden [Object] $Line
        [String] $Postal
        [String] $City
        [String] $County
        Postal([String]$Line)
        {
            $This.Line  = $Line -Split "\t"
            $This.Postal = $This.Line[0]
            $This.City   = $This.Line[1]
            $This.County = $This.Line[2]
        }
    }

    Class UID
    {
        [Object] $UID
        [UInt32] $Index
        [Object] $Slot
        [Object] $Type
        [Object] $Date
        [Object] $Time
        [Object] $Record
        UID([UInt32]$Slot)
        {
            $This.UID    = New-GUID | % GUID
            $This.Slot   = $Slot
            $This.Date   = Get-Date -UFormat "%m/%d/%Y"
            $This.Time   = Get-Date -UFormat "%H:%M:%S"
        }
        [String] ToString()
        {
            Return $This.Slot
        }
    }

    Class Client
    {
        [Object]         $UID
        [Object]       $Index
        [Object]        $Slot
        [Object]        $Type
        [Object]        $Date
        [Object]        $Time
        [UInt32]        $Rank
        [String] $DisplayName
        [String]       $First
        [String]          $MI
        [String]        $Last
        [Object]     $Address
        [Object]        $City
        [Object]      $Region
        [Object]     $Country
        [Object]      $Postal
        [UInt32]       $Month
        [UInt32]         $Day
        [UInt32]        $Year
        [String]         $DOB
        [String]      $Gender
        [Object]       $Image
        [Object[]]     $Phone
        [Object[]]     $Email
        [Object[]]    $Device
        [Object[]]   $Invoice
        Client([Object]$UID)
        {
            $This.UID  = $UID.UID
            $This.Slot = 0
            $This.Type = "Client"
            $This.Date = $UID.Date
            $This.Time = $UID.Time

            $This.Phone   = @( )
            $This.Email   = @( )
            $This.Device  = @( )
            $This.Invoice = @( )
        }
        [String] ToString()
        {
            Return "Client"
        }
    }

    Class Service
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [String]   $DisplayName
        [String]          $Name
        [String]   $Description
        [Object]          $Cost
        Service([Object]$UID) 
        { 
            $This.UID  = $UID.UID
            $This.Slot = 1
            $This.Type = "Service"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Service"
        }
    }

    Class Device
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [String]          $Rank
        [String]   $DisplayName
        [String]       $Chassis
        [String]        $Vendor
        [String]         $Model
        [String] $Specification
        [String]        $Serial
        [Object]        $Client
        [Object[]]       $Issue
        [Object[]]    $Purchase
        [Object[]]     $Invoice
        Device([Object]$UID) 
        { 
            $This.UID  = $UID.UID
            $This.Slot = 2
            $This.Type = "Device"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Device"
        }
    }

    Class Issue
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [Object]   $DisplayName
        [Object]        $Status
        [String[]] $Description
        [Object]        $Client
        [Object]        $Device
        [Object[]]    $Purchase
        [Object[]]     $Service
        [Object[]]     $Invoice
        Issue([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 3
            $This.Type = "Issue"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Issue"
        }
    }

    Class Inventory
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [String]   $DisplayName
        [String]        $Vendor
        [String]        $Serial
        [String]         $Model
        [Object]         $Title
        [Bool]        $IsDevice
        [Object[]]      $Device
        [Object]          $Cost
        Inventory([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 4
            $This.Type = "Inventory"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Inventory"
        }
    }

    Class Purchase
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [Object]   $DisplayName
        [Object]           $URL
        [String]        $Vendor
        [String]         $Model
        [String] $Specification
        [String]        $Serial
        [Bool]        $IsDevice
        [Object]        $Device
        [Object]          $Cost
        Purchase([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 5
            $This.Type = "Purchase"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Purchase"
        }
    }

    Class Expense
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [Object]   $DisplayName
        [Object]     $Recipient
        [Object]     $IsAccount
        [Object]       $Account
        [Object]          $Cost
        Expense([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 6
            $This.Type = "Expense"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Expense"
        }
    }

    Class Account
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [String]   $DisplayName
        [Object]        $Object
        Account([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 7
            $This.Type = "Account"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Account"
        }
    }

    Class Invoice
    {
        [Object]           $UID
        [UInt32]         $Index
        [Object]          $Slot
        [Object]          $Type
        [Object]          $Date
        [Object]          $Time
        [UInt32]          $Rank
        [String]   $DisplayName
        [UInt32]          $Mode
        [Object]        $Client
        [Object]     $Inventory
        [Object]       $Service
        [Object]      $Purchase
        Invoice([Object]$UID) 
        {
            $This.UID  = $UID.UID
            $This.Slot = 8
            $This.Type = "Invoice"
            $This.Date = $UID.Date
            $This.Time = $UID.Time
        }
        [String] ToString()
        {
            Return "Invoice"
        }
    }

    Class DB
    {
        [Object[]]         $UID
        [Object[]]      $Client
        [Object[]]     $Service
        [Object[]]      $Device
        [Object[]]       $Issue
        [Object[]]   $Inventory
        [Object[]]    $Purchase
        [Object[]]     $Expense
        [Object[]]     $Account
        [Object[]]     $Invoice
        DB()
        {
            $This.UID       = @( )
            $This.Client    = @( )
            $This.Service   = @( )
            $This.Device    = @( )
            $This.Issue     = @( )
            $This.Inventory = @( )
            $This.Purchase  = @( )
            $This.Expense   = @( )
            $This.Account   = @( )
            $This.Invoice   = @( )  
        }
        [UInt32] GetCount([UInt32]$X)
        {
            Return ( $X + 1 )
        }
        [UInt32] GetIndex()
        {
            Return ($This.GetCount($This.UID.Count) - 1)
        }
        [UInt32] GetRank([UInt32]$Slot)
        {
            Return $This.GetCount(
            @(  
                $This.Client.Count    ,
                $This.Service.Count   ,
                $This.Device.Count    ,
                $This.Issue.Count     , 
                $This.Inventory.Count ,
                $This.Purchase.Count  ,
                $This.Expense.Count   ,
                $This.Account.Count   ,
                $This.Invoice.Count   
            
            )[$Slot]) - 1
        }
        [Object] NewUID([Object]$Slot)
        {
            If ($Slot -notin 0..8)
            {
                Throw "Invalid entry"
            }

            $Item                = [UID]::New($Slot)
            $Item.Type           = @("Client Service Device Issue Inventory Purchase Expense Account Invoice" -Split " ")[$Slot]
            $Item.Index          = $This.GetIndex()
            $Item.Record         = Switch ($Slot)
            {
                0 { [Client]::New($Item)    } 1 { [Service]::New($Item)   } 2 { [Device]::New($Item)    }
                3 { [Issue]::New($Item)     } 4 { [Inventory]::New($Item) } 5 { [Purchase]::New($Item)  }
                6 { [Expense]::New($Item)   } 7 { [Account]::New($Item)   } 8 { [Invoice]::New($Item)   }
            }

            $Item.Record.Index   = $Item.Index
            $Item.Record.Rank    = $This.GetRank($Slot)

            Switch($Slot)
            {
                0 { $This.Client     += $Item } 1 { $This.Service    += $Item } 2 { $This.Device     += $Item }
                3 { $This.Issue      += $Item } 4 { $This.Inventory  += $Item } 5 { $This.Purchase   += $Item } 
                6 { $This.Expense    += $Item } 7 { $This.Account    += $Item } 8 { $This.Invoice    += $Item }
            }

            $This.UID           += $Item

            Return $Item
        }
        [Object] GetUID([Object]$UID)
        {
            Return $This.UID | ? UID -match $UID
        }
    }

    Class Template
    {
        [String[]] $UID
        [String[]] $Client
        [String[]] $Service
        [String[]] $Device
        [String[]] $Issue
        [String[]] $Inventory
        [String[]] $Purchase
        [String[]] $Expense
        [String[]] $Account
        [String[]] $Invoice
        Template()
        {
            $This.UID          = @("UID","Index","Date","Rank","DisplayName")
            $This.Client       = @($This.UID; "DOB", "Phone", "Email")
            $This.Service      = @($This.UID; "Description")
            $This.Device       = @($This.UID; "Vendor", "Model", "Specification", "Serial", "Title")
            $This.Issue        = @($This.UID; "Status","Description","Client","Device","Purchase","Service","Invoice")
            $This.Inventory    = @($This.UID; "Vendor","Model","Serial","Title","Cost","IsDevice","Device")
            $This.Purchase     = @($This.UID; "Distributor","Vendor","Serial","Model","IsDevice","Device","Cost")
            $This.Expense      = @($This.UID; "Recipient","Account","Cost")
            $This.Account      = @($This.UID; "Object")
            $This.Invoice      = @($This.UID; "Client","Inventory","Service","Purchase")
            $This.UID          = $This.UID[0..3]
        }
    }

    Class cimdb
    {
        [Object]  $Window
        [Object]      $IO
        [Object]    $Temp
        [Object]     $Tab = ("UID Client Service Device Issue Inventory Purchase Expense Account Invoice" -Split " ")
        [Object]    $Date = (Get-Date -uformat %m/%d/%Y)
        [UInt32]    $Slot
        [UInt32]     $New
        [Object]      $DB
        [Object]      $DG
        [Object] NewUID([UInt32]$Slot)
        {
            Return @( $This.DB.NewUID($Slot) )
        }
        [Object] GetUID([String]$UID)
        {
            Return @( $This.DB.UID | ? UID -match $UID )
        }
        [Void] Populate([Object]$Record,[Object]$Control)
        {
            $Control.ItemsSource = $Null

            If ( $Record.Count -ne 0 )
            {
                ForEach ( $Item in $Record )
                {
                    $Control.Items.Add($Item)
                }
            }

            $Control.SelectedIndex = $Control.Items.Count - 1
        }
        [Void] Relinquish([Object]$Control)
        {
            If ( $Control.ItemsSource.Count -ne 0 )
            {
                ForEach ( $Item in $Control.ItemsSource )
                {
                    $Control.Items.Remove($Item)
                }

                $Control.SelectedIndex = -1
            }
        }
        [String[]] GetSearchNames()
        {
            Return @("p0_x0_UID_______","p1_x0_Client____","p1_x1_Device____","p1_x1_Invoice___","p1_x2_Device____","p1_x2_Invoice___",
                     "p1_x3_Device____","p1_x3_Invoice___","p2_x0_Service___","p3_x0_Device____","p3_x1_Client____","p3_x1_Issue_____",
                     "p3_x1_Purchase__","p3_x1_Invoice___","p3_x2_Client____","p3_x2_Issue_____","p3_x2_Purchase__","p3_x2_Invoice___",
                     "p3_x3_Client____","p3_x3_Issue_____","p3_x3_Purchase__","p3_x3_Invoice___","p4_x0_Issue_____","p4_x1_Client____",
                     "p4_x1_Device____","p4_x1_Purchase__","p4_x1_Service___","p4_x1_Invoice___","p4_x2_Client____","p4_x2_Device____",
                     "p4_x2_Purchase__","p4_x2_Service___","p4_x2_Invoice___","p4_x3_Client____","p4_x3_Device____","p4_x3_Purchase__",
                     "p4_x3_Service___","p4_x3_Invoice___","p5_x0_Inventory_","p5_x1_Device____","p5_x2_Device____","p5_x3_Device____",
                     "p6_x0_Purchase__","p6_x1_Device____","p6_x2_Device____","p6_x3_Device____","p7_x0_Expense___","p7_x1_Account___",
                     "p7_x2_Account___","p7_x3_Account___","p8_x0_Account___","p8_x1_AcctObj___","p8_x2_AcctObj___","p8_x3_AcctObj___",
                     "p9_x0_Invoice___","p9_x1_Client____","p9_x1_Inventory_","p9_x1_Service___","p9_x1_Purchase__","p9_x2_Client____",
                     "p9_x2_Inventory_","p9_x2_Service___","p9_x2_Purchase__","p9_x3_Client____","p9_x3_Inventory_","p9_x3_Service___",
                     "p9_x3_Purchase__")
        }
        [String[]] GetControlNames()
        {
            Return @(
            "p0_x1_UID_______TB","p0_x1_Index_____TB","p0_x1_Slot______TB","p0_x1_Type______TB","p0_x1_Date______TB","p0_x1_Time______TB",
            "p1_x1_Last______TB","p1_x1_First_____TB","p1_x1_MI________TB","p1_x1_Gender____LI","p1_x1_Address___TB","p1_x1_Month_____TB",
            "p1_x1_Day_______TB","p1_x1_Year______TB","p1_x1_City______TB","p1_x1_Region____TB","p1_x1_Country___TB","p1_x1_Postal____TB",
            "p1_x1_Phone_____TB","p1_x1_Phone_____AB","p1_x1_Phone_____LI","p1_x1_Phone_____RB","p1_x1_Email_____TB","p1_x1_Email_____AB",
            "p1_x1_Email_____LI","p1_x1_Email_____RB","p1_x1_Device____SP","p1_x1_Device____SF","p1_x1_Device____SR","p1_x1_Device____AB",
            "p1_x1_Device____LI","p1_x1_Device____RB","p1_x1_Invoice___SP","p1_x1_Invoice___SF","p1_x1_Invoice___SR","p1_x1_Invoice___AB",
            "p1_x1_Invoice___LI","p1_x1_Invoice___RB","p1_x2_Last______TB","p1_x2_First_____TB","p1_x2_MI________TB","p1_x2_Gender____LI",
            "p1_x2_Address___TB","p1_x2_Month_____TB","p1_x2_Day_______TB","p1_x2_Year______TB","p1_x2_City______TB","p1_x2_Region____TB",
            "p1_x2_Country___TB","p1_x2_Postal____TB","p1_x2_Phone_____TB","p1_x2_Phone_____AB","p1_x2_Phone_____LI","p1_x2_Phone_____RB",
            "p1_x2_Email_____TB","p1_x2_Email_____AB","p1_x2_Email_____LI","p1_x2_Email_____RB","p1_x2_Device____SP","p1_x2_Device____SF",
            "p1_x2_Device____SR","p1_x2_Device____AB","p1_x2_Device____LI","p1_x2_Device____RB","p1_x2_Invoice___SP","p1_x2_Invoice___SF",
            "p1_x2_Invoice___SR","p1_x2_Invoice___AB","p1_x2_Invoice___LI","p1_x2_Invoice___RB","p1_x3_Last______TB","p1_x3_First_____TB",
            "p1_x3_MI________TB","p1_x3_Gender____LI","p1_x3_Address___TB","p1_x3_Month_____TB","p1_x3_Day_______TB","p1_x3_Year______TB",
            "p1_x3_City______TB","p1_x3_Region____TB","p1_x3_Country___TB","p1_x3_Postal____TB","p1_x3_Phone_____TB","p1_x3_Phone_____AB",
            "p1_x3_Phone_____LI","p1_x3_Phone_____RB","p1_x3_Email_____TB","p1_x3_Email_____AB","p1_x3_Email_____LI","p1_x3_Email_____RB",
            "p1_x3_Device____SP","p1_x3_Device____SF","p1_x3_Device____SR","p1_x3_Device____AB","p1_x3_Device____LI","p1_x3_Device____RB",
            "p1_x3_Invoice___SP","p1_x3_Invoice___SF","p1_x3_Invoice___SR","p1_x3_Invoice___AB","p1_x3_Invoice___LI","p1_x3_Invoice___RB",
            "p2_x0_Service___SP","p2_x0_Service___SF","p2_x0_Service___SR","p2_x1_Name______TB","p2_x1_Descript__TB","p2_x1_Cost______TB",
            "p2_x2_Name______TB","p2_x2_Descript__TB","p2_x2_Cost______TB","p2_x3_Name______TB","p2_x3_Descript__TB","p2_x3_Cost______TB",
            "p3_x0_Device____SP","p3_x0_Device____SF","p3_x0_Device____SR","p3_x1_Chassis___LI","p3_x1_Vendor____TB","p3_x1_Model_____TB",
            "p3_x1_Spec______TB","p3_x1_Serial____TB","p3_x1_Display___TB","p3_x1_Client____SP","p3_x1_Client____SF","p3_x1_Client____SR",
            "p3_x1_Client____AB","p3_x1_Client____LI","p3_x1_Client____RB","p3_x1_Issue_____SP","p3_x1_Issue_____SF","p3_x1_Issue_____SR",
            "p3_x1_Issue_____AB","p3_x1_Issue_____LI","p3_x1_Issue_____RB","p3_x1_Purchase__SP","p3_x1_Purchase__SF","p3_x1_Purchase__SR",
            "p3_x1_Purchase__AB","p3_x1_Purchase__LI","p3_x1_Purchase__RB","p3_x1_Invoice___SP","p3_x1_Invoice___SF","p3_x1_Invoice___SR",
            "p3_x1_Invoice___AB","p3_x1_Invoice___LI","p3_x1_Invoice___RB","p3_x2_Chassis___LI","p3_x2_Vendor____TB","p3_x2_Model_____TB",
            "p3_x2_Spec______TB","p3_x2_Serial____TB","p3_x2_Display___TB","p3_x2_Client____SP","p3_x2_Client____SF","p3_x2_Client____SR",
            "p3_x2_Client____AB","p3_x2_Client____LI","p3_x2_Client____RB","p3_x2_Issue_____SP","p3_x2_Issue_____SF","p3_x2_Issue_____SR",
            "p3_x2_Issue_____AB","p3_x2_Issue_____LI","p3_x2_Issue_____RB","p3_x2_Purchase__SP","p3_x2_Purchase__SF","p3_x2_Purchase__SR",
            "p3_x2_Purchase__AB","p3_x2_Purchase__LI","p3_x2_Purchase__RB","p3_x2_Invoice___SP","p3_x2_Invoice___SF","p3_x2_Invoice___SR",
            "p3_x2_Invoice___AB","p3_x2_Invoice___LI","p3_x2_Invoice___RB","p3_x3_Chassis___LI","p3_x3_Vendor____TB","p3_x3_Model_____TB",
            "p3_x3_Spec______TB","p3_x3_Serial____TB","p3_x3_Display___TB","p3_x3_Client____SP","p3_x3_Client____SF","p3_x3_Client____SR",
            "p3_x3_Client____AB","p3_x3_Client____LI","p3_x3_Client____RB","p3_x3_Issue_____SP","p3_x3_Issue_____SF","p3_x3_Issue_____SR",
            "p3_x3_Issue_____AB","p3_x3_Issue_____LI","p3_x3_Issue_____RB","p3_x3_Purchase__SP","p3_x3_Purchase__SF","p3_x3_Purchase__SR",
            "p3_x3_Purchase__AB","p3_x3_Purchase__LI","p3_x3_Purchase__RB","p3_x3_Invoice___SP","p3_x3_Invoice___SF","p3_x3_Invoice___SR",
            "p3_x3_Invoice___AB","p3_x3_Invoice___LI","p3_x3_Invoice___RB","p4_x0_Issue_____SP","p4_x0_Issue_____SF","p4_x0_Issue_____SR",
            "p4_x1_Status____LI","p4_x1_Descript__TB","p4_x1_Issue_____TC","p4_x1_Client____SP","p4_x1_Client____SF","p4_x1_Client____SR",
            "p4_x1_Device____SP","p4_x1_Device____SF","p4_x1_Device____SR","p4_x1_Purchase__SP","p4_x1_Purchase__SF","p4_x1_Purchase__SR",
            "p4_x1_Service___SR","p4_x1_Service___SF","p4_x1_Service___SR","p4_x1_Invoice___SR","p4_x1_Invoice___SF","p4_x1_Invoice___SR",
            "p4_x1_Client____AB","p4_x1_Client____LI","p4_x1_Client____RB","p4_x1_Device____AB","p4_x1_Device____LI","p4_x1_Device____RB",
            "p4_x1_Purchase__AB","p4_x1_Purchase__LI","p4_x1_Purchase__RB","p4_x1_Service___AB","p4_x1_Service___LI","p4_x1_Service___RB",
            "p4_x1_Invoice___AB","p4_x1_Invoice___LI","p4_x1_Invoice___RB","p4_x2_Status____LI","p4_x2_Descript__TB","p4_x2_Issue_____TC",
            "p4_x2_Client____SP","p4_x2_Client____SF","p4_x2_Client____SR","p4_x2_Device____SP","p4_x2_Device____SF","p4_x2_Device____SR",
            "p4_x2_Purchase__SP","p4_x2_Purchase__SF","p4_x2_Purchase__SR","p4_x2_Service___SR","p4_x2_Service___SF","p4_x2_Service___SR",
            "p4_x2_Invoice___SR","p4_x2_Invoice___SF","p4_x2_Invoice___SR","p4_x2_Client____AB","p4_x2_Client____LI","p4_x2_Client____RB",
            "p4_x2_Device____AB","p4_x2_Device____LI","p4_x2_Device____RB","p4_x2_Purchase__AB","p4_x2_Purchase__LI","p4_x2_Purchase__RB",
            "p4_x2_Service___AB","p4_x2_Service___LI","p4_x2_Service___RB","p4_x2_Invoice___AB","p4_x2_Invoice___LI","p4_x2_Invoice___RB",
            "p4_x3_Status____LI","p4_x3_Descript__TB","p4_x3_Issue_____TC","p4_x3_Client____SP","p4_x3_Client____SF","p4_x3_Client____SR",
            "p4_x3_Device____SP","p4_x3_Device____SF","p4_x3_Device____SR","p4_x3_Purchase__SP","p4_x3_Purchase__SF","p4_x3_Purchase__SR",
            "p4_x3_Service___SR","p4_x3_Service___SF","p4_x3_Service___SR","p4_x3_Invoice___SR","p4_x3_Invoice___SF","p4_x3_Invoice___SR",
            "p4_x3_Client____AB","p4_x3_Client____LI","p4_x3_Client____RB","p4_x3_Device____AB","p4_x3_Device____LI","p4_x3_Device____RB",
            "p4_x3_Purchase__AB","p4_x3_Purchase__LI","p4_x3_Purchase__RB","p4_x3_Service___AB","p4_x3_Service___LI","p4_x3_Service___RB",
            "p4_x3_Invoice___AB","p4_x3_Invoice___LI","p4_x3_Invoice___RB","p4_x0_Inventory_SP","p4_x0_Inventory_SF","p4_x0_Inventory_SR",
            "p5_x1_Vendor____TB","p5_x1_Model_____TB","p5_x1_Serial____TB","p5_x1_Title_____TB","p5_x1_Cost______TB","p5_x1_IsDevice__CB",
            "p5_x1_Device____SP","p5_x1_Device____SF","p5_x1_Device____SR","p5_x1_Device____AB","p5_x1_Device____LI","p5_x1_Device____RB",
            "p5_x2_Vendor____TB","p5_x2_Model_____TB","p5_x2_Serial____TB","p5_x2_Title_____TB","p5_x2_Cost______TB","p5_x2_IsDevice__CB",
            "p5_x2_Device____SP","p5_x2_Device____SF","p5_x2_Device____SR","p5_x2_Device____AB","p5_x2_Device____LI","p5_x2_Device____RB",
            "p5_x3_Vendor____TB","p5_x3_Model_____TB","p5_x3_Serial____TB","p5_x3_Title_____TB","p5_x3_Cost______TB","p5_x3_IsDevice__CB",
            "p5_x3_Device____SP","p5_x3_Device____SF","p5_x3_Device____SR","p5_x3_Device____AB","p5_x3_Device____LI","p5_x3_Device____RB",
            "p4_x0_Purchase__SP","p4_x0_Purchase__SF","p4_x0_Purchase__SR","p6_x1_Dist______TB","p6_x1_Display___TB","p6_x1_Vendor____TB",
            "p6_x1_Model_____TB","p6_x1_Spec______TB","p6_x1_Serial____TB","p6_x1_IsDevice__CB","p6_x1_Device____SP","p6_x1_Device____SF",
            "p6_x1_Device____SR","p6_x1_Device____AB","p6_x1_Device____LI","p6_x1_Device____RB","p6_x1_Cost______TB","p6_x2_Dist______TB",
            "p6_x2_Display___TB","p6_x2_Vendor____TB","p6_x2_Model_____TB","p6_x2_Spec______TB","p6_x2_Serial____TB","p6_x2_IsDevice__CB",
            "p6_x2_Device____SP","p6_x2_Device____SF","p6_x2_Device____SR","p6_x2_Device____AB","p6_x2_Device____LI","p6_x2_Device____RB",
            "p6_x2_Cost______TB","p6_x3_Dist______TB","p6_x3_Display___TB","p6_x3_Vendor____TB","p6_x3_Model_____TB","p6_x3_Spec______TB",
            "p6_x3_Serial____TB","p6_x3_IsDevice__CB","p6_x3_Device____SP","p6_x3_Device____SF","p6_x3_Device____SR","p6_x3_Device____AB",
            "p6_x3_Device____LI","p6_x3_Device____RB","p6_x3_Cost______TB","p7_x0_Expense___SP","p7_x0_Expense___SF","p7_x0_Expense___SR",
            "p7_x1_Recipient_TB","p7_x1_Display___TB","p7_x1_IsAccount_LI","p7_x1_Account___SP","p7_x1_Account___SF","p7_x1_Account___SR",
            "p7_x1_Account___AB","p7_x1_Account___LI","p7_x1_Account___RB","p7_x1_Cost______TB","p7_x2_Recipient_TB","p7_x2_Display___TB",
            "p7_x2_IsAccount_LI","p7_x2_Account___SP","p7_x2_Account___SF","p7_x2_Account___SR","p7_x2_Account___AB","p7_x2_Account___LI",
            "p7_x2_Account___RB","p7_x2_Cost______TB","p7_x3_Recipient_TB","p7_x3_Display___TB","p7_x3_IsAccount_LI","p7_x3_Account___SP",
            "p7_x3_Account___SF","p7_x3_Account___SR","p7_x3_Account___AB","p7_x3_Account___LI","p7_x3_Account___RB","p7_x3_Cost______TB",
            "p8_x0_Account___SP","p8_x0_Account___SF","p8_x0_Account___SR","p8_x1_AcctObj___SP","p8_x1_AcctObj___SF","p8_x1_AcctObj___SR",
            "p8_x1_AcctObj___AB","p8_x1_AcctObj___LI","p8_x1_AcctObj___RB","p8_x2_AcctObj___SP","p8_x2_AcctObj___SF","p8_x2_AcctObj___SR",
            "p8_x2_AcctObj___AB","p8_x2_AcctObj___LI","p8_x2_AcctObj___RB","p8_x3_AcctObj___SP","p8_x3_AcctObj___SF","p8_x3_AcctObj___SR",
            "p8_x3_AcctObj___AB","p8_x3_AcctObj___LI","p8_x3_AcctObj___RB","p9_x0_Invoice___SP","p9_x0_Invoice___SF","p9_x0_Invoice___SR",
            "p9_x1_Mode______LI","p9_x1_Client____SP","p9_x1_Client____SF","p9_x1_Client____SR","p9_x1_Client____AB","p9_x1_Client____LI",
            "p9_x1_Client____RB","p9_x1_Inventory_SP","p9_x1_Inventory_SF","p9_x1_Inventory_SR","p9_x1_Inventory_AB","p9_x1_Inventory_LI",
            "p9_x1_Inventory_RB","p9_x1_Service___SP","p9_x1_Service___SF","p9_x1_Service___SR","p9_x1_Service___AB","p9_x1_Service___LI",
            "p9_x1_Service___RB","p9_x1_Purchase__SP","p9_x1_Purchase__SF","p9_x1_Purchase__SR","p9_x1_Purchase__AB","p9_x1_Purchase__LI",
            "p9_x1_Purchase__RB")
        }
        SetDefaults()
        {
            ForEach ( $Name in $This.GetSearchNames() )
            {
                $Type   = Switch -Regex ($Name)
                {
                    UID       {       "UID" } Client    {    "Client" } Service   {   "Service" }
                    Device    {    "Device" } Issue     {     "Issue" } Inventory { "Inventory" }
                    Purchase  {  "Purchase" } Expense   {   "Expense" } Account   {   "Account" }
                    Invoice   {   "Invoice" } AcctObj   {   "AcctObj" }
                }

                $This.IO."$Name`SP".ItemsSource   = $This.Temp.$Type
                $This.IO."$Name`SP".SelectedIndex = 2
                $This.IO."$Name`SR".ItemsSource   = New-Object System.Collections.ObjectModel.Collection[Object]
                $This.IO."$Name`SF".Text          = @($Null,$This.Date)[($This.IO."$Name`SP".SelectedItem -eq 'Date')]
                
                $This.IO."$Name`SF".Add_TextChanged(
                {
                    If ( $This.IO."$Name`SF".Text -ne "" )
                    {
                        $This.IO."$Name`SR".ItemsSource = $Null
                
                        $This.DG = $This.DB.$Type | ? $This.IO."$Name`SP".SelectedItem -match $This.IO."$Name`SF".Text
                
                        If ( $This.DG.Count -gt 0 )
                        {
                            $This.IO."$Name`SR".ItemsSource = @( $This.DG )
                        }
                    }
                
                    Else
                    {
                        $This.IO."$Name`SR".ItemsSource = $This.DB.$Type
                    }
                            
                    Start-Sleep -Milliseconds 50
                })
                
                $This.IO."$Name`SP".Add_SelectionChanged(
                {
                    If ( $This.IO."$Name`SP".SelectedItem -eq "Date" )
                    {
                        $This.IO."$Name`SF".Text = $This.Date
                    }

                    Else
                    {
                        $This.IO."$Name`SF".Text = ""
                    }
                })
            }
        }
        [Void] Collapse()
        {   
            $This.IO."p0_x0".Visibility = "Collapsed"
            $This.IO."p0_x1".Visibility = "Collapsed"
            $This.IO."p1_x0".Visibility = "Collapsed"
            $This.IO."p1_x1".Visibility = "Collapsed"
            $This.IO."p1_x2".Visibility = "Collapsed"
            $This.IO."p1_x3".Visibility = "Collapsed"
            $This.IO."p2_x0".Visibility = "Collapsed"
            $This.IO."p2_x1".Visibility = "Collapsed"
            $This.IO."p2_x2".Visibility = "Collapsed"
            $This.IO."p2_x3".Visibility = "Collapsed"
            $This.IO."p3_x0".Visibility = "Collapsed"
            $This.IO."p3_x1".Visibility = "Collapsed"
            $This.IO."p3_x2".Visibility = "Collapsed"
            $This.IO."p3_x3".Visibility = "Collapsed"
            $This.IO."p4_x0".Visibility = "Collapsed"
            $This.IO."p4_x1".Visibility = "Collapsed"
            $This.IO."p4_x2".Visibility = "Collapsed"
            $This.IO."p4_x3".Visibility = "Collapsed"
            $This.IO."p5_x0".Visibility = "Collapsed"
            $This.IO."p5_x1".Visibility = "Collapsed"
            $This.IO."p5_x2".Visibility = "Collapsed"
            $This.IO."p5_x3".Visibility = "Collapsed"
            $This.IO."p6_x0".Visibility = "Collapsed"
            $This.IO."p6_x1".Visibility = "Collapsed"
            $This.IO."p6_x2".Visibility = "Collapsed"
            $This.IO."p6_x3".Visibility = "Collapsed"
            $This.IO."p7_x0".Visibility = "Collapsed"
            $This.IO."p7_x1".Visibility = "Collapsed"
            $This.IO."p7_x2".Visibility = "Collapsed"
            $This.IO."p7_x3".Visibility = "Collapsed"
            $This.IO."p8_x0".Visibility = "Collapsed"
            $This.IO."p8_x1".Visibility = "Collapsed"
            $This.IO."p8_x2".Visibility = "Collapsed"
            $This.IO."p8_x3".Visibility = "Collapsed"
            $This.IO."p9_x0".Visibility = "Collapsed"
            $This.IO."p9_x1".Visibility = "Collapsed"
            $This.IO."p9_x2".Visibility = "Collapsed"
            $This.IO."p9_x3".Visibility = "Collapsed"
        }
        SlotCollapse([UInt32]$Slot)
        {
            $This.IO.p0.Visibility = "Collapsed"
            $This.IO.p1.Visibility = "Collapsed"
            $This.IO.p2.Visibility = "Collapsed"
            $This.IO.p3.Visibility = "Collapsed"
            $This.IO.p4.Visibility = "Collapsed"
            $This.IO.p5.Visibility = "Collapsed"
            $This.IO.p6.Visibility = "Collapsed"
            $This.IO.p7.Visibility = "Collapsed"
            $This.IO.p8.Visibility = "Collapsed"
            $This.IO.p9.Visibility = "Collapsed"

            $This.IO."p$Slot".Visibility = "Visible"
        }
        _ViewUID()
        {
            $This.IO.p0_x1_UID_______TB.Text         = $Null
            $This.IO.p0_x1_Index_____TB.Text         = $Null
            $This.IO.p0_x1_Slot______TB.Text         = $Null
            $This.IO.p0_x1_Type______TB.Text         = $Null
            $This.IO.p0_x1_Date______TB.Text         = $Null
            $This.IO.p0_x1_Time______TB.Text         = $Null

            $This.Relinquish($This.IO.p0_x1_Record____LI)
        }
        ViewUID([String]$UID)
        {
            $This._ViewUID()

            $Item = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid UID"
            }

            $This.IO.p0_x1_UID_______TB.Text         = $Item.UID
            $This.IO.p0_x1_Index_____TB.Text         = $Item.Index
            $This.IO.p0_x1_Slot______TB.Text         = $Item.Slot
            $This.IO.p0_x1_Type______TB.Text         = $Item.Type
            $This.IO.p0_x1_Date______TB.Text         = $Item.Date
            $This.IO.p0_x1_Time______TB.Text         = $Item.Time
 
            $Collect = @( )

            ForEach ( $Object in $Item.Record | Get-Member | ? MemberType -eq Property | % Name )
            {
                
                $Collect += [DGList]::New($Object,$Item.Record.$Object)
            }

            $This.IO.p0_x1_Record____LI.ItemsSource  = $Collect
        }
        _ViewClient()
        {
            $This.IO.p1_x1_Last______TB.Text         = $Null
            $This.IO.p1_x1_First_____TB.Text         = $Null
            $This.IO.p1_x1_MI________TB.Text         = $Null
            $This.IO.p1_x1_Gender____LI.SelectedItem = 2
            $This.IO.p1_x1_Address___TB.Text         = $Null
            $This.IO.p1_x1_Month_____TB.Text         = $Null
            $This.IO.p1_x1_Day_______TB.Text         = $Null
            $This.IO.p1_x1_Year______TB.Text         = $Null
            $This.IO.p1_x1_City______TB.Text         = $Null
            $This.IO.p1_x1_Region____TB.Text         = $Null
            $This.IO.p1_x1_Country___TB.Text         = $Null
            $This.IO.p1_x1_Postal____TB.Text         = $Null

            $This.Relinquish($This.IO.p1_x1_Phone_____LI)
            $This.Relinquish($This.IO.p1_x1_Email_____LI)
            $This.Relinquish($This.IO.p1_x1_Device____LI)
            $This.Relinquish($This.IO.p1_x1_Invoice___LI)
        }
        ViewClient([Object]$UID)
        {
            $This._ViewClient()

            $Item                                        = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Client UID"
            }

            $This.IO.p1_x1_Last______TB.Text         = $Item.Record.Last
            $This.IO.p1_x1_First_____TB.Text         = $Item.Record.First
            $This.IO.p1_x1_MI________TB.Text         = $Item.Record.MI
            $This.IO.p1_x1_Gender____LI.SelectedItem = @{ Male = 0; Female = 1; "-" = 2 }[$Item.Record.Gender]
            $This.IO.p1_x1_Address___TB.Text         = $Item.Record.Address
            $This.IO.p1_x1_Month_____TB.Text         = $Item.Record.Month
            $This.IO.p1_x1_Day_______TB.Text         = $Item.Record.Day
            $This.IO.p1_x1_Year______TB.Text         = $Item.Record.Year
            $This.IO.p1_x1_City______TB.Text         = $Item.Record.City
            $This.IO.p1_x1_Region____TB.Text         = $Item.Record.Region
            $This.IO.p1_x1_Country___TB.Text         = $Item.Record.Country
            $This.IO.p1_x1_Postal____TB.Text         = $Item.Record.Postal

            $This.Populate( $Item.Record.Phone       , $This.IO.p1_x1_Phone_____LI )
            $This.Populate( $Item.Record.Email       , $This.IO.p1_x1_Email_____LI )
            $This.Populate( $Item.Record.Device      , $This.IO.p1_x1_Device____LI )
            $This.Populate( $Item.Record.Invoice     , $This.IO.p1_x1_Invoice___LI )
        }
        _EditClient()
        {
            $This.IO.p1_x2_Last______TB.Text         = $Null
            $This.IO.p1_x2_First_____TB.Text         = $Null
            $This.IO.p1_x2_MI________TB.Text         = $Null
            $This.IO.p1_x2_Gender____LI.SelectedItem = 2
            $This.IO.p1_x2_Address___TB.Text         = $Null
            $This.IO.p1_x2_Month_____TB.Text         = $Null
            $This.IO.p1_x2_Day_______TB.Text         = $Null
            $This.IO.p1_x2_Year______TB.Text         = $Null
            $This.IO.p1_x2_City______TB.Text         = $Null
            $This.IO.p1_x2_Region____TB.Text         = $Null
            $This.IO.p1_x2_Country___TB.Text         = $Null
            $This.IO.p1_x2_Postal____TB.Text         = $Null

            $This.Relinquish( $This.IO.p1_x2_Phone_____LI )
            $This.Relinquish( $This.IO.p1_x2_Email_____LI )
            $This.Relinquish( $This.IO.p1_x2_Device____LI )
            $This.Relinquish( $This.IO.p1_x2_Invoice___LI )
        }
        EditClient([Object]$UID)
        {
            $This._EditClient()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Client UID"
            }

            $This.IO.p1_x2_Last______TB.Text         = $Item.Record.Last
            $This.IO.p1_x2_First_____TB.Text         = $Item.Record.First
            $This.IO.p1_x2_MI________TB.Text         = $Item.Record.MI
            $This.IO.p1_x2_Gender____LI.SelectedIndex = @{ Male = 0; Female = 1; "-" = 2 }[$Item.Record.Gender]
            $This.IO.p1_x2_Address___TB.Text         = $Item.Record.Address
            $This.IO.p1_x2_Month_____TB.Text         = $Item.Record.Month
            $This.IO.p1_x2_Day_______TB.Text         = $Item.Record.Day
            $This.IO.p1_x2_Year______TB.Text         = $Item.Record.Year
            $This.IO.p1_x2_City______TB.Text         = $Item.Record.City
            $This.IO.p1_x2_Region____TB.Text         = $Item.Record.Region
            $This.IO.p1_x2_Country___TB.Text         = $Item.Record.Country
            $This.IO.p1_x2_Postal____TB.Text         = $Item.Record.Postal

            $This.Populate( $Item.Record.Phone       , $This.IO.p1_x2_Phone_____LI)
            $This.Populate( $Item.Record.Email       , $This.IO.p1_x2_Email_____LI)
            $This.Populate( $Item.Record.Device      , $This.IO.p1_x2_Device____LI)
            $This.Populate( $Item.Record.Invoice     , $This.IO.p1_x2_Invoice___LI)
        }
        _NewClient()
        {
            $This.IO.p1_x3_Last______TB.Text         = $Null
            $This.IO.p1_x3_First_____TB.Text         = $Null
            $This.IO.p1_x3_MI________TB.Text         = $Null
            $This.IO.p1_x3_Gender____LI.SelectedItem = 2
            $This.IO.p1_x3_Address___TB.Text         = $Null
            $This.IO.p1_x3_Month_____TB.Text         = $Null
            $This.IO.p1_x3_Day_______TB.Text         = $Null
            $This.IO.p1_x3_Year______TB.Text         = $Null
            $This.IO.p1_x3_City______TB.Text         = $Null
            $This.IO.p1_x3_Region____TB.Text         = $Null
            $This.IO.p1_x3_Country___TB.Text         = $Null
            $This.IO.p1_x3_Postal____TB.Text         = $Null

            $This.Relinquish( $This.IO.p1_x3_Phone_____LI )
            $This.Relinquish( $This.IO.p1_x3_Email_____LI )
            $This.Relinquish( $This.IO.p1_x3_Device____LI )
            $This.Relinquish( $This.IO.p1_x3_Invoice___LI )
        }
        NewClient()
        {
            $This._NewClient()
            $This.IO.p1_x3.Visibility                = "Visible"
        }
        _ViewService()
        {
            $This.IO.p2_x1_Name______TB.Text         = $Null
            $This.IO.p2_x1_Descript__TB.Text         = $Null
            $This.IO.p2_x1_Cost______TB.Text         = $Null
        }
        ViewService([Object]$UID)
        {
            $This._ViewService()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Service UID"
            }

            $This.IO.p2_x1_Name______TB.Text         = $Item.Record.Name
            $This.IO.p2_x1_Descript__TB.Text         = $Item.Record.Description
            $This.IO.p2_x1_Cost______TB.Text         = $Item.Record.Cost
        }
        _EditService()
        {
            $This.Collapse()

            $This.IO.p2_x2_Name______TB.Text         = $Null
            $This.IO.p2_x2_Descript__TB.Text         = $Null
            $This.IO.p2_x2_Cost______TB.Text         = $Null
        }
        EditService([Object]$UID)
        {
            $This._EditService()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Service UID"
            }

            $This.IO.p2_x2_Name______TB.Text         = $Item.Record.Name
            $This.IO.p2_x2_Descript__TB.Text         = $Item.Record.Description
            $This.IO.p2_x2_Cost______TB.Text         = $Item.Record.Cost
        }
        _NewService()
        {
            $This.IO.p2_x3_Name______TB.Text         = $Null
            $This.IO.p2_x3_Descript__TB.Text         = $Null
            $This.IO.p2_x3_Cost______TB.Text         = $Null
        }
        NewService()
        {
            $This._NewService()

            $This.IO.p2_x3.Visibility                = "Visible"
        }
        _ViewDevice()
        {
            $This.IO.p3_x1_Chassis___LI.SelectedIndex = 8
            $This.IO.p3_x1_Vendor____TB.Text         = $Null
            $This.IO.p3_x1_Model_____TB.Text         = $Null
            $This.IO.p3_x1_Spec______TB.Text         = $Null
            $This.IO.p3_x1_Serial____TB.Text         = $Null
            $This.IO.p3_x1_Display___TB.Text         = $Null

            $This.Relinquish($This.IO.p3_x1_Client____LI)
            $This.Relinquish($This.IO.p3_x1_Issue_____LI)
            $This.Relinquish($This.IO.p3_x1_Purchase__LI)
            $This.Relinquish($This.IO.p3_x1_Invoice___LI)
        }
        ViewDevice([Object]$UID)
        {
            $This._ViewDevice()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Device UID"
            }

            $This.IO.p3_x1_Chassis___LI.SelectedIndex = Switch($Item.Record.Chassis)
            {
                Desktop    {0} Laptop     {1} Smartphone {2} Tablet     {3} Console    {4} 
                Server     {5} Network    {6} Other      {7} "-"        {8}
            }

            $This.IO.p3_x1_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p3_x1_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p3_x1_Spec______TB.Text         = $Item.Record.Specification
            $This.IO.p3_x1_Serial____TB.Text         = $Item.Record.Serial
            $This.IO.p3_x1_Display___TB.Text         = $Item.Record.Title

            $This.Populate( $Item.Record.Client      , $This.IO.p3_x1_Client____LI )
            $This.Populate( $Item.Record.Issue       , $This.IO.p3_x1_Issue_____LI )
            $This.Populate( $Item.Record.Purchase    , $This.IO.p3_x1_Purchase__LI )
            $This.Populate( $Item.Record.Invoice     , $This.IO.p3_x1_Invoice___LI )
        }
        _EditDevice()
        {
            $This.IO.p3_x2_Chassis___LI.SelectedItem = 8
            $This.IO.p3_x2_Vendor____TB.Text         = $Null
            $This.IO.p3_x2_Model_____TB.Text         = $Null
            $This.IO.p3_x2_Spec______TB.Text         = $Null
            $This.IO.p3_x2_Serial____TB.Text         = $Null
            $This.IO.p3_x2_Display___TB.Text         = $Null

            $This.Relinquish($This.IO.p3_x2_Client____LI)
            $This.Relinquish($This.IO.p3_x2_Issue_____LI)
            $This.Relinquish($This.IO.p3_x2_Purchase__LI)
            $This.Relinquish($This.IO.p3_x2_Invoice___LI)
        }
        EditDevice([Object]$UID)
        {
            $This._EditDevice()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Device UID"
            }

            $This.IO.p3_x2_Chassis___LI.SelectedIndex = Switch($Item.Record.Chassis)
            {
                Desktop    {0} Laptop     {1} Smartphone {2} Tablet     {3} Console    {4} 
                Server     {5} Network    {6} Other      {7} -          {8}
            }

            $This.IO.p3_x2_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p3_x2_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p3_x2_Spec______TB.Text         = $Item.Record.Specification
            $This.IO.p3_x2_Serial____TB.Text         = $Item.Record.Serial
            $This.IO.p3_x2_Display___TB.Text         = $Item.Record.Title

            $This.Populate( $Item.Record.Client      , $This.IO.p3_x2_Client____LI )
            $This.Populate( $Item.Record.Issue       , $This.IO.p3_x2_Issue_____LI )
            $This.Populate( $Item.Record.Purchase    , $This.IO.p3_x2_Purchase__LI )
            $This.Populate( $Item.Record.Invoice     , $This.IO.p3_x2_Invoice___LI )
        }
        _NewDevice()
        {
            $This.Collapse()

            $This.IO.p3_x3_Chassis___LI.SelectedItem = 8
            $This.IO.p3_x3_Vendor____TB.Text         = $Null
            $This.IO.p3_x3_Model_____TB.Text         = $Null
            $This.IO.p3_x3_Spec______TB.Text         = $Null
            $This.IO.p3_x3_Serial____TB.Text         = $Null
            $This.IO.p3_x3_Display___TB.Text         = $Null

            $This.Relinquish($This.IO.p3_x3_Client____LI)
            $This.Relinquish($This.IO.p3_x3_Issue_____LI)
            $This.Relinquish($This.IO.p3_x3_Purchase__LI)
            $This.Relinquish($This.IO.p3_x3_Invoice___LI)
        }
        NewDevice()
        {
            $This._NewDevice()

            $This.IO.p3_x3.Visibility                = "Visible"
        }
        _ViewIssue()
        {
            $This.IO.p4_x1_Status____LI.SelectedIndex = $Null
            $This.IO.p4_x1_Descript__TB.Text          = $Null

            $This.Relinquish($This.IO.p4_x1_Client____LI)
            $This.Relinquish($This.IO.p4_x1_Device____LI)
            $This.Relinquish($This.IO.p4_x1_Purchase__LI)
            $This.Relinquish($This.IO.p4_x1_Service___LI)
            $This.Relinquish($This.IO.p4_x1_Invoice___LI)
        }
        ViewIssue([Object]$UID)
        {
            $This._ViewIssue()

            $Item                                         = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Issue UID"
            }

            If ( $Item.Record.Status -notin 0..3 )
            {
                $Item.Record.Status = 0
            }

            $This.IO.p4_x1_Status____LI.SelectedIndex     = Switch($Item.Record.Status)
            {
                0 { "New" } 1 { "Diagnosed" } 2 { "Commit" } 3 { "Complete" }
            }

            $This.IO.p4_x1_Descript__TB.SelectedIndex     = $Item.Record.Description

            $This.Populate( $Item.Record.Client           , $This.IO.p4_x1_Client____LI )
            $This.Populate( $Item.Record.Device           , $This.IO.p4_x1_Device____LI )
            $This.Populate( $Item.Record.Purchase         , $This.IO.p4_x1_Purchase__LI )
            $This.Populate( $Item.Record.Service          , $This.IO.p4_x1_Service___LI )
            $This.Populate( $Item.Record.Invoice          , $This.IO.p4_x1_Invoice___LI )
        }
        _EditIssue()
        {
            $This.IO.p4_x2_Status____LI.SelectedIndex = $Null
            $This.IO.p4_x2_Descript__TB.Text         = $Null

            $This.Relinquish($This.IO.p4_x2_Client____LI)
            $This.Relinquish($This.IO.p4_x2_Device____LI)
            $This.Relinquish($This.IO.p4_x2_Purchase__LI)
            $This.Relinquish($This.IO.p4_x2_Service___LI)
            $This.Relinquish($This.IO.p4_x2_Invoice___LI)
        }
        EditIssue([Object]$UID)
        {
            $This._EditIssue()

            $Item                                         = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Issue UID"
            }

            $This.IO.p4_x2_Status____LI.SelectedIndex     = $Item.Record.Status
            $This.IO.p4_x2_Descript__TB.SelectedIndex     = $Item.Record.Description

            $This.Populate( $Item.Record.Client           , $This.IO.p4_x2_Client____LI )
            $This.Populate( $Item.Record.Device           , $This.IO.p4_x2_Device____LI )
            $This.Populate( $Item.Record.Purchase         , $This.IO.p4_x2_Purchase__LI )
            $This.Populate( $Item.Record.Service          , $This.IO.p4_x2_Service___LI )
            $This.Populate( $Item.Record.Invoice          , $This.IO.p4_x2_Invoice___LI )
        }
        _NewIssue()
        {
            $This.IO.p4_x3_Status____LI.SelectedItem = -1
            $This.IO.p4_x3_Descript__TB.Text         = $Null

            $This.Relinquish($This.IO.p4_x3_Client____LI)
            $This.Relinquish($This.IO.p4_x3_Device____LI)
            $This.Relinquish($This.IO.p4_x3_Purchase__LI)
            $This.Relinquish($This.IO.p4_x3_Service___LI)
            $This.Relinquish($This.IO.p4_x3_Invoice___LI)
        }
        NewIssue()
        {
            $This._NewDevice()

            $This.IO.p4_x3.Visibility                = "Visible"
        }
        _ViewInventory()
        {
            $This.IO.p5_x1_Vendor____TB.Text         = $Null
            $This.IO.p5_x1_Model_____TB.Text         = $Null
            $This.IO.p5_x1_Serial____TB.Text         = $Null
            $This.IO.p5_x1_Title_____TB.Text         = $Null
            $This.IO.p5_x1_Cost______TB.Text         = $Null
            $This.IO.p5_x2_IsDevice__LI.SelectedIndex = 0

            $This.Relinquish($This.IO.p5_x1_Device____LI)
        }
        ViewInventory([Object]$UID)
        {
            $This._ViewInventory()

            $Item = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Inventory UID"
            }

            $This.IO.p5_x1_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p5_x1_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p5_x1_Serial____TB.Text         = $Item.Record.Serial
            $This.IO.p5_x1_Title_____TB.Text         = $Item.Record.Title
            $This.IO.p5_x1_Cost______TB.Text         = $Item.Record.Cost
            $This.IO.p5_x1_IsDevice__LI.SelectedIndex = @(0,1)[$Item.Record.IsDevice]

            $This.Populate( $Item.Record.Device      , $This.IO.p5_x1_Device____LI )
        }
        _EditInventory()
        {
            $This.IO.p5_x2_Vendor____TB.Text         = $Null
            $This.IO.p5_x2_Model_____TB.Text         = $Null
            $This.IO.p5_x2_Serial____TB.Text         = $Null
            $This.IO.p5_x2_Title_____TB.Text         = $Null
            $This.IO.p5_x2_Cost______TB.Text         = $Null
            $This.IO.p5_x2_IsDevice__LI.SelectedIndex = 0

            $This.Relinquish($This.IO.p5_x2_Device____LI)
        }
        EditInventory([Object]$UID)
        {
            $This._EditInventory()

            $Item = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Inventory UID"
            }

            $This.IO.p5_x2_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p5_x2_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p5_x2_Serial____TB.Text         = $Item.Record.Serial
            $This.IO.p5_x2_Title_____TB.Text         = $Item.Record.Title
            $This.IO.p5_x2_Cost______TB.Text         = $Item.Record.Cost
            $This.IO.p5_x2_IsDevice__LI.SelectedIndex = @(0,1)[$Item.Record.IsDevice]

            $This.Populate( $Item.Record.Device      , $This.IO.p5_x2_Device____LI )
        }
        _NewInventory()
        {
            $This.IO.p5_x3_Vendor____TB.Text         = $Null
            $This.IO.p5_x3_Model_____TB.Text         = $Null
            $This.IO.p5_x3_Serial____TB.Text         = $Null
            $This.IO.p5_x3_Title_____TB.Text         = $Null
            $This.IO.p5_x3_Cost______TB.Text         = $Null
            $This.IO.p5_x3_IsDevice__LI.SelectedIndex = 0

            $This.Relinquish($This.IO.p5_x3_Device____LI)
        }
        NewInventory()
        {
            $This._NewInventory()

            $This.IO.p5_x3.Visibility                = "Visible"
        }
        _ViewPurchase()
        {
            $This.IO.p6_x1_Dist______TB.Text         = $Null
            $This.IO.p6_x1_Display___TB.Text         = $Null
            $This.IO.p6_x1_Vendor____TB.Text         = $Null
            $This.IO.p6_x1_Model_____TB.Text         = $Null
            $This.IO.p6_x1_Spec______TB.Text         = $Null
            $This.IO.p6_x1_Serial____TB.Text         = $Null

            $This.IO.p6_x1_IsDevice__LI.SelectedItem = 0
            $This.Relinquish($This.IO.p6_x1_Device____LI)

            $This.IO.p6_x1_Cost______TB.Text         = $Null
        }
        ViewPurchase([Object]$UID)
        {
            $This._ViewPurchase()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Purchase UID"
            }

            $This.IO.p6_x1_Dist______TB.Text         = $Item.Record.Distributor
            $This.IO.p6_x1_Display___TB.Text         = $Item.Record.DisplayName
            $This.IO.p6_x1_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p6_x1_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p6_x1_Spec______TB.Text         = $Item.Record.Specification
            $This.IO.p6_x1_Serial____TB.Text         = $Item.Record.Serial

            $This.IO.p6_x1_IsDevice__LI.SelectedIndex = @(0,1)[$Item.Record.IsDevice]
            $This.Populate( $Item.Record.Device      , $This.IO.p6_x1_Device____LI )

            $This.IO.p6_x1_Cost______TB.Text         = $Item.Record.Cost
        }
        _EditPurchase()
        {
            $This.IO.p6_x2_Display___TB.Text         = $Null
            $This.IO.p6_x2_Dist______TB.Text         = $Null
            $This.IO.p6_x2_Model_____TB.Text         = $Null
            $This.IO.p6_x2_Serial____TB.Text         = $Null
            $This.IO.p6_x2_Spec______TB.Text         = $Null
            $This.IO.p6_x2_Vendor____TB.Text         = $Null

            $This.IO.p6_x2_IsDevice__LI.ItemsSource  = $Null
            $This.Relinquish($This.IO.p6_x2_Device____LI)

            $This.IO.p6_x2_Cost______TB.Text         = $Null
        }
        EditPurchase([Object]$UID)
        {
            $This._EditPurchase()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Purchase UID"
            }

            $This.IO.p6_x2_Dist______TB.Text         = $Item.Record.Distributor
            $This.IO.p6_x2_Display___TB.Text         = $Item.Record.DisplayName
            $This.IO.p6_x2_Vendor____TB.Text         = $Item.Record.Vendor
            $This.IO.p6_x2_Model_____TB.Text         = $Item.Record.Model
            $This.IO.p6_x2_Spec______TB.Text         = $Item.Record.Specification
            $This.IO.p6_x2_Serial____TB.Text         = $Item.Record.Serial

            $This.IO.p6_x2_IsDevice__LI.SelectedIndex = @(0,1)[$Item.Record.IsDevice]

            $This.Populate( $Item.Record.Device      , $This.IO.p6_x2_Device____LI )

            $This.IO.p6_x2_Cost______TB.Text         = $Item.Record.Cost
        }
        _NewPurchase()
        {
            $This.IO.p6_x3_Display___TB.Text         = $Null
            $This.IO.p6_x3_Dist______TB.Text         = $Null
            $This.IO.p6_x3_Model_____TB.Text         = $Null
            $This.IO.p6_x3_Serial____TB.Text         = $Null
            $This.IO.p6_x3_Spec______TB.Text         = $Null
            $This.IO.p6_x3_Vendor____TB.Text         = $Null

            $This.IO.p6_x3_IsDevice__LI.ItemsSource  = $Null
            $This.Relinquish($This.IO.p6_x3_Device____LI)

            $This.IO.p6_x3_Cost______TB.Text         = $Null
        }
        NewPurchase()
        {
            $This._NewPurchase()

            $This.IO.p6_x3.Visibility                = "Visible"
        }
        _ViewExpense()
        {
            $This.IO.p7_x1_Display___TB.Text         = $Null
            $This.IO.p7_x1_Recipient_TB.Text         = $Null

            $This.IO.p7_x1_IsAccount_LI.SelectedIndex = 0
            $This.Relinquish($This.IO.p7_x1_Account___LI)

            $This.IO.p7_x1_Cost______TB.Text         = $Null
        }
        ViewExpense([Object]$UID)
        {
            $This._ViewExpense()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Expense UID"
            }

            $This.IO.p7_x1_Display___TB.Text         = $Item.Record.Recipient
            $This.IO.p7_x1_Recipient_TB.Text         = $Item.Record.DisplayName
            $This.IO.p7_x1_IsAccount_LI.SelectedIndex = @(0,1)[$Item.Record.IsAccount]

            $This.Populate( $Item.Record.Account     , $This.IO._ViewExpenseAccountList  )

            $This.IO._ViewExpenseCost.Text           = $Item.Record.Cost
        }
        _EditExpense()
        {
            $This.IO.p7_x2_Display___TB.Text         = $Null
            $This.IO.p7_x2_Recipient_TB.Text         = $Null

            $This.IO.p7_x2_IsAccount_LI.SelectedIndex = 0
            $This.Relinquish($This.IO.p7_x2_Account___LI)

            $This.IO.p7_x2_Cost______TB.Text         = $Null
        }
        EditExpense([Object]$UID)
        {
            $This._EditExpense()

            $Item                                    = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Expense UID"
            }

            $This.IO.p7_x2_Display___TB.Text         = $Item.Record.Recipient
            $This.IO.p7_x2_Recipient_TB.Text         = $Item.Record.DisplayName

            $This.IO.p7_x2_IsAccount_LI.IsChecked    = $False
            $This.Populate( $Item.Record.Account     , $This.IO.p7_x2_Account___LI)

            $This.IO.p7_x2_Cost______TB.Text           = $Item.Record.Cost
        }
        _NewExpense()
        {
            $This.IO.p7_x3_Display___TB.Text         = $Null
            $This.IO.p7_x3_Recipient_TB.Text         = $Null

            $This.IO.p7_x3_IsAccount_LI.SelectedIndex = 0
            $This.Relinquish($This.IO.p7_x3_Account___LI)

            $This.IO.p7_x3_Cost______TB.Text         = $Null
        }
        NewExpense()
        {
            $This._NewExpense()

            $This.IO.p7_x3.Visibility                = "Visible"
        }
        _ViewAccount()
        {
            $This.Relinquish($This.IO.p8_x1_AcctObj___LI)
        }
        ViewAccount([Object]$UID)
        {
            $This._ViewAccount()

            $Item                                      = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Account UID"
            }

            $This.Populate( $Item.Record.Object        , $This.IO.p8_x1_AcctObj___LI )
        }
        _EditAccount()
        {

            $This.Relinquish($This.IO.p8_x2_AcctObj___LI)
        }
        EditAccount([Object]$UID)
        {
            $This._EditAccount()

            $Item                                      = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Account UID"
            }

            $This.Populate( $Item.Record.Object        , $This.IO.p8_x2_AcctObj___LI    )
        }
        _NewAccount()
        {
            $This.Relinquish($This.IO.p8_x3_AcctObj___LI)
        }
        NewAccount()
        {
            $This._NewAccount()

            $This.IO.p8_x3.Visibility                = "Visible"
        }
        _ViewInvoice()
        {
            $This.Collapse()

            $This.IO.p9_x1_Mode______LI.SelectedIndex = 0

            $This.Relinquish($This.IO.p9_x1_Client_____LI)
            $This.Relinquish($This.IO.p9_x1_Inventory__LI)
            $This.Relinquish($This.IO.p9_x1_Service____LI)
            $This.Relinquish($This.IO.p9_x1_Purchase___LI)
        }
        ViewInvoice([Object]$UID)
        {
            $This._ViewInvoice()

            $Item                                      = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Inventory UID"
            }

            $This.IO.p9_x1_Mode______LI.SelectedIndex  = $Item.Record.Mode

            $This.Populate( $Item.Record.Client        , $This.IO.p9_x1_Client_____LI )
            $This.Populate( $Item.Record.Inventory     , $This.IO.p9_x1_Inventory__LI )
            $This.Populate( $Item.Record.Service       , $This.IO.p9_x1_Service____LI )
            $This.Populate( $Item.Record.Purchase      , $This.IO.p9_x1_Purchase___LI )
        }
        _EditInvoice()
        {
            $This.IO.p9_x2_Mode______LI.SelectedIndex = 0

            $This.Relinquish($This.IO.p9_x2_Client_____LI)
            $This.Relinquish($This.IO.p9_x2_Inventory__LI)
            $This.Relinquish($This.IO.p9_x2_Service____LI)
            $This.Relinquish($This.IO.p9_x2_Purchase___LI)
        }
        EditInvoice([Object]$UID)
        {
            $This._EditInvoice()

            $Item                                      = $This.GetUID($UID)
            
            If (!$Item)
            {
                Throw "Invalid Inventory UID"
            }

            $This.IO._EditInvoiceMode.SelectedIndex    = $Item.Record.Mode

            $This.Populate( $Item.Record.Client        , $This.IO.p9_x2_Client_____LI )
            $This.Populate( $Item.Record.Inventory     , $This.IO.p9_x2_Inventory__LI )
            $This.Populate( $Item.Record.Service       , $This.IO.p9_x2_Service____LI )
            $This.Populate( $Item.Record.Purchase      , $This.IO.p9_x2_Purchase___LI )
        }
        _NewInvoice()
        {
            $This.IO.p9_x2_Mode______LI.SelectedIndex  = 0

            $This.Relinquish($This.IO.p9_x3_Client_____LI)
            $This.Relinquish($This.IO.p9_x3_Inventory__LI)
            $This.Relinquish($This.IO.p9_x3_Service____LI)
            $This.Relinquish($This.IO.p9_x3_Purchase___LI)
        }
        NewInvoice()
        {
            $This._NewInvoice()

            $This.IO.p9_x3.Visibility                = "Visible"
        }
        Stage()
        {
            $This._ViewUID()
            $This._ViewClient()
            $This._EditClient()
            $This._NewClient()
            $This._ViewService()
            $This._EditService()
            $This._NewService()
            $This._ViewDevice()
            $This._EditDevice()
            $This._NewDevice()
            $This._ViewIssue()
            $This._EditIssue()
            $This._NewIssue()
            $This._ViewInventory()
            $This._EditInventory()
            $This._NewInventory()
            $This._ViewPurchase()
            $This._EditPurchase()
            $This._NewPurchase()
            $This._ViewExpense()
            $This._EditExpense()
            $This._NewExpense()
            $This._ViewAccount()
            $This._EditAccount()
            $This._NewAccount()
            $This._ViewInvoice()
            $This._EditInvoice()
            $This._NewInvoice()
        }
        Refresh()
        {
            $This.DB.Client                         = $This.DB.UID | ? Type -eq Client
            $This.DB.Service                        = $This.DB.UID | ? Type -eq Service
            $This.DB.Device                         = $This.DB.UID | ? Type -eq Device
            $This.DB.Issue                          = $This.DB.UID | ? Type -eq Issue
            $This.DB.Inventory                      = $This.DB.UID | ? Type -eq Inventory
            $This.DB.Purchase                       = $This.DB.UID | ? Type -eq Purchase
            $This.DB.Expense                        = $This.DB.UID | ? Type -eq Expense
            $This.DB.Account                        = $This.DB.UID | ? Type -eq Account
            $This.DB.Invoice                        = $This.DB.UID | ? Type -eq Invoice

            $This.IO.p0_x0_UID_______SR.ItemsSource = $This.DB.UID
            $This.IO.p1_x0_Client____SR.ItemsSource = $This.DB.Client
            $This.IO.p2_x0_Service___SR.ItemsSource = $This.DB.Service
            $This.IO.p3_x0_Device____SR.ItemsSource = $This.DB.Device
            $This.IO.p4_x0_Issue_____SR.ItemsSource = $This.DB.Issue
            $This.IO.p5_x0_Inventory_SR.ItemsSource = $This.DB.Inventory
            $This.IO.p6_x0_Purchase__SR.ItemsSource = $This.DB.Purchase
            $This.IO.p7_x0_Expense___SR.ItemsSource = $This.DB.Expense
            $This.IO.p8_x0_Account___SR.ItemsSource = $This.DB.Account
            $This.IO.p9_x0_Invoice___SR.ItemsSource = $This.DB.Invoice
        }
        cimdb([String]$Xaml)
        {
            $This.Window                                    = [XamlWindow]::New($Xaml)
            $This.IO                                        = $This.Window.IO
            $This.Temp                                      = [Template]::New()
            $This.DB                                        = [DB]::New()

            $This.SetDefaults()
            $This.Collapse()
            $This.SlotCollapse(0)
            $This.Stage()
            $This.Refresh()

            $This.IO.New.Visibility                         = "Hidden"
            $This.IO.Edit.Visibility                        = "Hidden"
            $This.IO.Save.Visibility                        = "Hidden"

            # UID
            # Client
            # Service
            # Device
            # Issue
            # Inventory
            # Purchase
            # Expense
            # Account
            # Invoice
        }
        GetTab([UInt32]$Slot)
        {
            $This.Slot = $Slot

            $This.Collapse()
            $This.SlotCollapse($Slot)
            $This.Stage()
           
            If ( $Slot -eq 0 )
            {
                $This.IO.New.Visibility                = "Hidden"
                $This.IO.New.IsEnabled                 = 0
            }

            If ( $Slot -ne 0 )
            {
                $This.IO.New.Visibility                = "Visible"
                $This.IO.New.IsEnabled                 = 1
            }

            $This.IO.Edit.Visibility                   = "Hidden"
            $This.IO.Edit.IsEnabled                    = 0

            $This.IO.Save.Visibility                   = "Hidden"
            $This.IO.Save.IsEnabled                    = 0
            
            ForEach ( $X in 0..9 )
            {
                $Tab__                                 = "t$X"
                $Panel                                 = "p$X"

                If ( $X -ne $This.Slot )
                {
                    $This.IO.$Tab__.Background         = "#DFFFBA"
                    $This.IO.$Tab__.Foreground         = "#000000"
                    $This.IO.$Tab__.BorderBrush        = "#000000"
                    $This.IO.$Panel.Visibility         = "Collapsed"
                }

                If ( $X -eq $This.Slot )
                {
                    $This.IO.$Tab__.Background         = "#4444FF"
                    $This.IO.$Tab__.Foreground         = "#FFFFFF"
                    $This.IO.$Tab__.BorderBrush        = "#111111"

                    $This.IO.$Panel.Visibility         = "Visible"
                    $This.IO."$($Panel)_x0".Visibility = "Visible"
                    $This.IO."$($Panel)_x1".Visibility = "Collapsed"

                    If ( $Slot -ne 0 )
                    {
                        $This.IO."$($Panel)_x2".Visibility = "Collapsed"
                        $This.IO."$($Panel)_x3".Visibility = "Collapsed"
                    }
                }
            }

            Write-Host $This.Tab[$Slot]

            $This.Refresh()
        }
        ViewTab([UInt32]$Slot)
        {
            $This.Slot = $Slot
            $This.Collapse()
            $This.SlotCollapse($This.Slot)

            $This.IO."p$Slot".Visibility               = "Visible"
            $This.IO."p$Slot`_x1".Visibility           = "Visible"

            $This.IO.New.IsEnabled                     = 1
            $This.IO.Edit.IsEnabled                    = 1
            $This.IO.Save.IsEnabled                    = 0

            $This.IO.New.Visibility                    = "Visible"
            $This.IO.Edit.Visibility                   = "Visible"
            $This.IO.Save.Visibility                   = "Visible"
        }
        EditTab([UInt32]$Slot)
        {
            $This.Slot = $Slot
            $This.Collapse()
            $This.SlotCollapse($This.Slot)

            $This.IO."p$Slot".Visibility               = "Visible"
            $This.IO."p$Slot`_x2".Visibility           = "Visible"

            $This.IO.New.IsEnabled                     = 1
            $This.IO.Edit.IsEnabled                    = 0
            $This.IO.Save.IsEnabled                    = 1

            $This.IO.New.Visibility                    = "Visible"
            $This.IO.Edit.Visibility                   = "Visible"
            $This.IO.Save.Visibility                   = "Visible"
        }
        NewTab([UInt32]$Slot)
        {
            $This.Slot = $Slot
            $This.Collapse()
            $This.SlotCollapse($This.Slot)

            $This.IO."p$Slot".Visibility               = "Visible"
            $This.IO."p$Slot`_x3".Visibility           = "Visible"

            $This.IO.New.IsEnabled                     = 1
            $This.IO.Edit.IsEnabled                    = 0
            $This.IO.Save.IsEnabled                    = 1

            $This.IO.New.Visibility                    = "Visible"
            $This.IO.Edit.Visibility                   = "Visible"
            $This.IO.Save.Visibility                   = "Visible"
            
            Switch([UInt32]$This.Slot)
            {
                0 
                {
                    $Null               
                }

                1 
                { 
                    $This.NewClient()
                }

                2 
                { 
                    $This.NewService()
                }

                3 
                { 
                    $This.NewDevice()
                }

                4 
                { 
                    $This.NewIssue()
                }

                5 
                { 
                    $This.NewInventory()
                }

                6 
                { 
                    $This.NewPurchase()
                }

                7 
                { 
                    $This.NewExpense()
                }

                8 
                { 
                    $This.NewAccount()
                }

                9 
                { 
                    $This.NewInvoice()
                }
            }
        }
    }

    #$Xaml = [XamlWindow][cimdbGUI]::Tab
    # Add-Type -AssemblyName PresentationFramework; ( Get-Content $Home\Desktop\cimdb.ps1 ) -join "`n" | IEX
    $Cim  = [Cimdb]::New([cimdbGUI]::Tab)

    # ---- #
    # Menu #
    # ---- #
    
    $Cim.IO.t0.Add_Click{ $Cim.GetTab(0) }
    $Cim.IO.t1.Add_Click{ $Cim.GetTab(1) }
    $Cim.IO.t2.Add_Click{ $Cim.GetTab(2) }
    $Cim.IO.t3.Add_Click{ $Cim.GetTab(3) }
    $Cim.IO.t4.Add_Click{ $Cim.GetTab(4) }
    $Cim.IO.t5.Add_Click{ $Cim.GetTab(5) }
    $Cim.IO.t6.Add_Click{ $Cim.GetTab(6) }
    $Cim.IO.t7.Add_Click{ $Cim.GetTab(7) }
    $Cim.IO.t8.Add_Click{ $Cim.GetTab(8) }
    $Cim.IO.t9.Add_Click{ $Cim.GetTab(9) }

    # --- #
    # UID #
    # --- #

    $Cim.IO.p0_x0_UID_______SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(0)
        $Cim.ViewUID($Cim.IO.p0_x0_UID_______SR.SelectedItem.UID)
    })

    # ------ #
    # Client #
    # ------ #

    $Cim.IO.p1_x0_Client____SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(1)
        $Cim.ViewClient($Cim.IO.p1_x0_Client____SR.SelectedItem.UID)
    })

    # Edit
    $Cim.IO.p1_x2_Device____TC.Add_Click(
    {
        $Cim.IO.p1_x2_Device____TI.Visibility = "Visible"
        $Cim.IO.p1_x2_Invoice___TI.Visibility = "Collapsed"
    })

    $Cim.IO.p1_x2_Invoice___TC.Add_Click(
    {
        $Cim.IO.p1_x2_Device____TI.Visibility = "Collapsed"
        $Cim.IO.p1_x2_Invoice___TI.Visibility = "Visible"
    })

    # New
    $Cim.IO.p1_x3_Device____TC.Add_Click(
    {
        $Cim.IO.p1_x3_Device____TI.Visibility = "Visible"
        $Cim.IO.p1_x3_Invoice___TI.Visibility = "Collapsed"

        $Cim.Populate($Cim.DB.Device,$Cim.IO.p1_x3_Device____SR)
    })

    $Cim.IO.p1_x3_Invoice___TC.Add_Click(
    {
        $Cim.IO.p1_x3_Device____TI.Visibility = "Collapsed"
        $Cim.IO.p1_x3_Invoice___TI.Visibility = "Visible"
        
        $Cim.Populate($Cim.DB.Device,$Cim.IO.p1_x3_Invoice___SR)
    })


    # Service #
    
    $Cim.IO.p2_x0_Service___SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(2)
        $Cim.ViewService($Cim.IO.p2_x0_Service___SR.SelectedItem.UID)
    })

    # ------ #
    # Device #
    # ------ #

    # View # 

    $Cim.IO.p3_x0_Device____SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(3)
        $Cim.ViewDevice($Cim.IO.p3_x0_Device____SR.SelectedItem.UID)
    })

    # Edit #

    $Cim.IO.p3_x2_Client____TC.Add_Click(
    {
        $Cim.IO.p3_x2_Client____TI.Visibility = "Visible"
        $Cim.IO.p3_x2_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x2_Client____SR.ItemsSource = $Cim.DB.Client
    })

    $Cim.IO.p3_x2_Issue_____TC.Add_Click(
    {
        $Cim.IO.p3_x2_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Issue_____TI.Visibility = "Visible"
        $Cim.IO.p3_x2_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x2_Issue_____SR.ItemsSource = $Cim.DB.Issue
    })

    $Cim.IO.p3_x2_Purchase__TC.Add_Click(
    {
        $Cim.IO.p3_x2_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Purchase__TI.Visibility = "Visible"
        $Cim.IO.p3_x2_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x2_Purchase___SR.ItemsSource = $Cim.DB.Purchase
    })

    $Cim.IO.p3_x2_Invoice___TC.Add_Click(
    {
        $Cim.IO.p3_x2_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x2_Invoice___TI.Visibility = "Visible"

        $Cim.IO.p3_x2_Invoice___SR.ItemsSource = $Cim.DB.Invoice
    })

    # Client Add/Remove

    $Cim.IO.p3_x2_Client____AB.Add_Click(
    {
        If ( $Cim.IO.p3_x2_Client____SR.SelectedItem.UID -in $Cim.IO.p3_x2_Client____LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ($Cim.IO.p3_x2_Client____SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Client____LI.Items.Add($Cim.IO.p3_x2_Client____SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Client____RB.Add_Click(
    {
        If ( $Cim.IO.p3_x2_Client____LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No client to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Client____LI.Items.Remove($Cim.IO.p3_x2_Client____LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Issue_____AB.Add_Click(
    {
        If ($Cim.IO.p3_x2_Issue_____SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x2_Issue_____SR.SelectedItem.UID -in $Cim.IO.p3_x2_Issue_____LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Issue_____LI.Items.Add($Cim.IO.p3_x2_Issue_____SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Issue_____RB.Add_Click(
    {
        If ( $Cim.IO.p3_x2_Issue_____LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Issue_____LI.Items.Remove($Cim.IO.p3_x2_Issue_____LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Purchase__AB.Add_Click(
    {
        If ($Cim.IO.p3_x2_Purchase__SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x2_Purchase__SR.SelectedItem.UID -in $Cim.IO.p3_x2_Purchase__LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Purchase__LI.Items.Add($Cim.IO.p3_x2_Purchase__SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Purchase__RB.Add_Click(
    {
        If ( $Cim.IO.p3_x2_Purchase__LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Purchase__LI.Items.Remove($Cim.IO.p3_x2_Purchase__LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Invoice___AB.Add_Click(
    {
        If ($Cim.IO.p3_x2_Invoice___SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x2_Invoice___SR.SelectedItem.UID -in $Cim.IO.p3_x2_Invoice___LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Invoice___LI.Items.Add($Cim.IO.p3_x2_Invoice___SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x2_Invoice___RB.Add_Click(
    {
        If ( $Cim.IO.p3_x2_Invoice___LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x2_Invoice___LI.Items.Remove($Cim.IO.p3_x2_Invoice___LI.SelectedItem)
        }
    })

    # New #
    $Cim.IO.p3_x3_Client____TC.Add_Click(
    {
        $Cim.IO.p3_x3_Client____TI.Visibility = "Visible"
        $Cim.IO.p3_x3_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x3_Client____SR.ItemsSource = $Cim.DB.Client
    })

    $Cim.IO.p3_x3_Issue_____TC.Add_Click(
    {
        $Cim.IO.p3_x3_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Issue_____TI.Visibility = "Visible"
        $Cim.IO.p3_x3_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x3_Issue_____SR.ItemsSource = $Cim.DB.Issue
    })

    $Cim.IO.p3_x3_Purchase__TC.Add_Click(
    {
        $Cim.IO.p3_x3_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Purchase__TI.Visibility = "Visible"
        $Cim.IO.p3_x3_Invoice___TI.Visibility = "Collapsed"

        $Cim.IO.p3_x3_Purchase__SR.ItemsSource = $Cim.DB.Purchase
    })

    $Cim.IO.p3_x3_Invoice___TC.Add_Click(
    {
        $Cim.IO.p3_x3_Client____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Issue_____TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Purchase__TI.Visibility = "Collapsed"
        $Cim.IO.p3_x3_Invoice___TI.Visibility = "Visible"

        $Cim.IO.p3_x3_Invoice___SR.ItemsSource = $Cim.DB.Invoice
    })

    # Client Add/Remove
    $Cim.IO.p3_x3_Client____AB.Add_Click(
    {
        If ( $Cim.IO.p3_x3_Client____SR.SelectedItem -in $Cim.IO.p3_x3_Client____LI.Items)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ($Cim.IO.p3_x3_Client____SR.Items.Count -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Client____LI.Items.Add($Cim.IO.p3_x3_Client____SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Client____RB.Add_Click(
    {
        If ( $Cim.IO.p3_x3_Client____LI.Items.Count -le 0)
        {
            [System.Windows.MessageBox]::Show("No client to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Client____LI.Items.Remove($Cim.IO.p3_x3_Client____LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Issue_____AB.Add_Click(
    {
        If ($Cim.IO.p3_x3_Issue_____SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x3_Issue_____SR.SelectedItem.UID -in $Cim.IO.p3_x3_Issue_____LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Issue_____LI.Items.Add($Cim.IO.p3_x3_Issue_____SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Issue_____RB.Add_Click(
    {
        If ( $Cim.IO.p3_x3_Issue_____LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Issue_____LI.Items.Remove($Cim.IO.p3_x3_Issue_____LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Purchase__AB.Add_Click(
    {
        If ($Cim.IO.p3_x3_Purchase__SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x3_Purchase__SR.SelectedItem.UID -in $Cim.IO.p3_x3_Purchase__LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Purchase__LI.Items.Add($Cim.IO.p3_x3_Purchase__SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Purchase__RB.Add_Click(
    {
        If ( $Cim.IO.p3_x3_Purchase__LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Purchase__LI.Items.Remove($Cim.IO.p3_x3_Purchase__LI.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Invoice___AB.Add_Click(
    {
        If ($Cim.IO.p3_x3_Invoice___SR.SelectedItem -le 0)
        {
            [System.Windows.MessageBox]::Show("Invalid entry selected","Error")
        }

        ElseIf ( $Cim.IO.p3_x3_Invoice___SR.SelectedItem.UID -in $Cim.IO.p3_x3_Invoice___LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Entry is already selected","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Invoice___LI.Items.Add($Cim.IO.p3_x3_Invoice___SR.SelectedItem)
        }
    })

    $Cim.IO.p3_x3_Invoice___RB.Add_Click(
    {
        If ( $Cim.IO.p3_x3_Invoice___LI.Items.Count -le 0 )
        {
            [System.Windows.MessageBox]::Show("No issue to remove","Error")
        }

        Else
        {
            $Cim.IO.p3_x3_Invoice___LI.Items.Remove($Cim.IO.p3_x3_Invoice___LI.SelectedItem)
        }
    })

    # ----- #
    # Issue #
    # ----- #

    $Cim.IO.p4_x0_Issue_____SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(4)
        $Cim.ViewIssue($Cim.IO.p4_x0_Issue_____SR.SelectedItem.UID)
    })

    # --------- #
    # Inventory #
    # --------- #

    $Cim.IO.p5_x0_Inventory_SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(5)
        $Cim.ViewInventory($Cim.IO.p5_x0_Inventory_SR.SelectedItem.UID)
    })

    # -------- #
    # Purchase #
    # -------- #

    $Cim.IO.p6_x0_Purchase__SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(6)
        $Cim.ViewPurchase($Cim.IO.p6_x0_Purchase__SR.SelectedItem.UID)
    })

    # ------- #
    # Expense #
    # ------- #

    $Cim.IO.p7_x0_Expense___SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(7)
        $Cim.ViewExpense($Cim.IO.p7_x0_Expense___SR.SelectedItem.UID)
    })
    
    # Account #

    $Cim.IO.p8_x0_Account___SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(8)
        $Cim.ViewAccount($Cim.IO.p8_x0_Account___SR.SelectedItem.UID)
    })

    # Invoice # 

    $Cim.IO.p9_x0_Invoice___SR.Add_MouseDoubleClick(
    {    
        $Cim.ViewTab(9)
        $Cim.ViewInvoice($Cim.IO.p9_x0_Invoice___SR.SelectedItem.UID)
    })

    $Cim.IO.Edit.Add_Click(
    {
        $Cim.Collapse()
        $Cim.SlotCollapse($Cim.Slot)

        $Cim.New  = 0

        $Cim.IO.Edit.IsEnabled = 0
        $Cim.IO.New.IsEnabled  = 1
        $Cim.IO.Save.IsEnabled = 1

        $Cim.IO.New.Visibility                         = "Visible"        
        $Cim.IO.Save.Visibility                        = "Visible"
        $Cim.IO.Edit.Visibility                        = "Visible"

        $Cim.EditTab($Cim.Slot)

        Switch([UInt32]$Cim.Slot)
        {
            0 
            { 
                $Null
            }

            1 
            { 
                $Cim.EditClient($Cim.IO.p1_x0_Client____SR.SelectedItem.UID)
            }

            2 
            { 
                $Cim.EditService($Cim.IO.p2_x0_Service___SR.SelectedItem.UID)
            }
            
            3 
            { 
                $Cim.EditDevice($Cim.IO.p3_x0_Device____SR.SelectedItem.UID)
            }

            4 
            { 
                $Cim.EditIssue($Cim.IO.p4_x0_Issue_____SR.SelectedItem.UID)
            }

            5 
            { 
                $Cim.EditInventory($Cim.IO.p5_x0_Inventory_SR.SelectedItem.UID)
            }

            6 
            { 
                $Cim.EditPurchase($Cim.IO.p6_x0_Purchase__SR.SelectedItem.UID)
            }

            7 
            { 
                $Cim.EditExpense($Cim.IO.p7_x0_Expense___SR.SelectedItem.UID)
            }

            8 
            { 
                $Cim.EditAccount($Cim.IO.p8_x0_Account___SR.SelectedItem.UID)
            }

            9 
            { 
                $Cim.EditInvoice($Cim.IO.p9_x0_Invoice___SR.SelectedItem.UID)
            }
        }
    })

    $Cim.IO.New.Add_Click(
    {
        $Cim.Collapse()
        $Cim.SlotCollapse($Cim.Slot)

        $Cim.New  = 1
        $Cim.IO.Edit.IsEnabled                         = 0
        $Cim.IO.New.IsEnabled                          = 0
        $Cim.IO.Save.IsEnabled                         = 1

        $Cim.IO.New.Visibility                         = "Visible"        
        $Cim.IO.Save.Visibility                        = "Visible"
        $Cim.IO.Edit.Visibility                        = "Visible"

        $Cim.NewTab($Cim.Slot)
    })

    $Cim.IO.Save.Add_Click(
    {
        Switch([UInt32]$Cim.Slot)
        {
            0 
            { 
                $Null 
            }

            1 # Client
            {
                If ( $Cim.New -eq 0 )
                {
                    $Name = "{0}, {1}" -f $Cim.IO.p1_x2_Last______TB.Text, $Cim.IO.p1_x2_First_____TB.Text 
            
                    If ( $Cim.IO.p1_x2_MI________TB.Text -eq "" )
                    {
                        $Full = $Name
                    }

                    If ( $Cim.IO.p1_x2_MI________TB.Text -ne "" )
                    {
                        $Full = "{0} {1}." -f $Name, $Cim.IO.p1_x2_MI________TB.Text.TrimEnd(".")
                    }

                    $DOB  = "{0:d2}/{1:d2}/{2:d4}" -f $Cim.IO.p1_x2_Month_____TB.Text, $Cim.IO.p1_x2_Day_______TB.Text, $Cim.IO.p1_x2_Year______TB.Text

                    If ($Cim.IO.p1_x2_Last______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Last name missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_First_____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("First name missing","Error")
                    }

                    ElseIf ($Full -in $Cim.DB.Client.Record.Name -and $DOB -in $Cim.DB.Client.Record.DOB)
                    {
                        [System.Windows.MessageBox]::Show("Client account exists","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Address___TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Address missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_City______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("City missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Postal____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Zip code missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Month_____TB.Text -notin 1..12)
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Month","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Day_______TB.Text -notin 1..31)
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Day","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Year______TB.Text.Length -lt 4 )
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Year","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Gender____LI.SelectedIndex -notin 0..1)
                    {
                        [System.Windows.MessageBox]::Show("Invalid Gender","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Phone_____LI.Items.Count -eq 0)
                    {
                        [System.Windows.MessageBox]::Show("No phone number","Error")
                    }

                    ElseIf ($Cim.IO.p1_x2_Email_____LI.Items.Count -eq 0)
                    {
                        [System.Windows.MessageBox]::Show("No email","Error")
                    }

                    Else
                    {
                        $Item                 = $Cim.NewUID(0)
                        $Cim.Refresh()
                        $Item.Record.Last     = $Cim.IO.p1_x2_Last______TB.Text.ToUpper()
                        $Item.Record.First    = $Cim.IO.p1_x2_First_____TB.Text.ToUpper()
                        $Item.Record.MI       = $Cim.IO.p1_x2_MI________TB.Text.ToUpper()
                        $Item.Record.Name     = $Full.ToUpper()
                        $Item.Record.Address  = $Cim.IO.p1_x2_Address___TB.Text.ToUpper()
                        $Item.Record.City     = $Cim.IO.p1_x2_City______TB.Text.ToUpper()
                        $Item.Record.Region   = $Cim.IO.p1_x2_Region____TB.Text.ToUpper()
                        $Item.Record.Country  = $Cim.IO.p1_x2_Country___TB.Text.ToUpper()
                        $Item.Record.Postal   = $Cim.IO.p1_x2_Postal____TB.Text
                        $Item.Record.Month    = $Cim.IO.p1_x2_Month_____TB.Text
                        $Item.Record.Day      = $Cim.IO.p1_x2_Day_______TB.Text
                        $Item.Record.Year     = $Cim.IO.p1_x2_Year______TB.Text
                        $Item.Record.DOB      = $DOB
                        $Item.Record.Gender   = $Cim.IO.p1_x2_Gender____LI.SelectedItem.Content
                        $Item.Record.Phone    = $Cim.IO.p1_x2_Phone_____LI.Items
                        $Item.Record.Email    = $Cim.IO.p1_x2_Email_____LI.Items
                        $Item.Record.Device   = $Cim.IO.p1_x2_Device____LI.Items
                        $Item.Record.Invoice  = $Cim.IO.p1_x2_Invoice___LI.Items

                        [System.Windows.MessageBox]::Show("Client [$($Item.Record.Name)] added to database","Success")

                        $Cim.GetTab(1)
                    }
                }

                If ( $Cim.New -eq 1 )
                {
                    $Name = "{0}, {1}" -f $Cim.IO.p1_x3_Last______TB.Text, $Cim.IO.p1_x3_First_____TB.Text 
            
                    If ( $Cim.IO.p1_x3_MI________TB.Text -eq "" )
                    {
                        $Full = $Name
                    }

                    If ( $Cim.IO.p1_x3_MI________TB.Text -ne "" )
                    {
                        $Full = "{0} {1}." -f $Name, $Cim.IO.p1_x3_MI________TB.Text.TrimEnd(".")
                    }

                    $DOB  = "{0:d2}/{1:d2}/{2:d4}" -f $Cim.IO.p1_x3_Month_____TB.Text, $Cim.IO.p1_x3_Day_______TB.Text, $Cim.IO.p1_x3_Year______TB.Text

                    If ($Cim.IO.p1_x3_Last______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Last name missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_First_____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("First name missing","Error")
                    }

                    ElseIf ($Full -in $Cim.DB.Client.Record.Name -and $DOB -in $Cim.DB.Client.Record.DOB)
                    {
                        [System.Windows.MessageBox]::Show("Client account exists","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Address___TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Address missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_City______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("City missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Postal____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Zip code missing","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Month_____TB.Text -notin 1..12)
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Month","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Day_______TB.Text -notin 1..31)
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Day","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Year______TB.Text.Length -lt 4 )
                    {
                        [System.Windows.MessageBox]::Show("Invalid DOB.Year","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Gender____LI.SelectedIndex -notin 0..1)
                    {
                        [System.Windows.MessageBox]::Show("Invalid Gender","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Phone_____LI.Items.Count -eq 0)
                    {
                        [System.Windows.MessageBox]::Show("No phone number","Error")
                    }

                    ElseIf ($Cim.IO.p1_x3_Email_____LI.Items.Count -eq 0)
                    {
                        [System.Windows.MessageBox]::Show("No email","Error")
                    }

                    Else
                    {
                        $Item                 = $Cim.NewUID(0)
                        $Cim.Refresh()
                        $Item.Record.Last     = $Cim.IO.p1_x3_Last______TB.Text.ToUpper()
                        $Item.Record.First    = $Cim.IO.p1_x3_First_____TB.Text.ToUpper()
                        $Item.Record.MI       = $Cim.IO.p1_x3_MI________TB.Text.ToUpper()
                        $Item.Record.Name     = $Full.ToUpper()
                        $Item.Record.Address  = $Cim.IO.p1_x3_Address___TB.Text.ToUpper()
                        $Item.Record.City     = $Cim.IO.p1_x3_City______TB.Text.ToUpper()
                        $Item.Record.Region   = $Cim.IO.p1_x3_Region____TB.Text.ToUpper()
                        $Item.Record.Country  = $Cim.IO.p1_x3_Country___TB.Text.ToUpper()
                        $Item.Record.Postal   = $Cim.IO.p1_x3_Postal____TB.Text
                        $Item.Record.Month    = $Cim.IO.p1_x3_Month_____TB.Text
                        $Item.Record.Day      = $Cim.IO.p1_x3_Day_______TB.Text
                        $Item.Record.Year     = $Cim.IO.p1_x3_Year______TB.Text
                        $Item.Record.DOB      = $DOB
                        $Item.Record.Gender   = $Cim.IO.p1_x3_Gender____LI.SelectedItem.Content
                        $Item.Record.Phone    = $Cim.IO.p1_x3_Phone_____LI.Items
                        $Item.Record.Email    = $Cim.IO.p1_x3_Email_____LI.Items
                        $Item.Record.Device   = $Cim.IO.p1_x3_Device____LI.Items
                        $Item.Record.Invoice  = $Cim.IO.p1_x3_Invoice___LI.Items

                        [System.Windows.MessageBox]::Show("Client [$($Item.Record.Name)] added to database","Success")

                        $Cim.GetTab(1)
                    }
                }
            }

            2 # Service
            { 
                If ( $Cim.New -eq 0 )
                {
                    If ( $Cim.IO.p2_x2_Name______TB.Text -eq "" )
                    {
                        [System.Windows.MessageBox]::Show("Invalid service name","Error")
                    }

                    ElseIf ( $Cim.IO.p2_x2_Cost______TB.Text -eq "" )
                    {
                        [System.Windows.MessageBox]::Show("Service cost undefined","Error")
                    }

                    ElseIf ( $Cim.IO.p2_x2_Name______TB.Text -in $Cim.DB.Service.Record.Name )
                    {
                        [System.Windows.MessageBox]::Show("Service exists","Error")
                    }

                    Else
                    {
                        $Item                    = $Cim.NewUID(1)
                        $Cim.Refresh()
                        $Item.Record.Name        = $Cim.IO.p2_x2_Name______TB.Text
                        $Item.Record.Description = $Cim.IO.p2_x2_Descript__TB.Text
                        $Item.Record.Cost        = "{0:C}" -f [UInt32]$Cim.IO.p2_x2_Cost______TB.Text

                        [System.Windows.MessageBox]::Show("Service [$($Item.Record.Name)] added to database","Success")

                        $Cim.IO.p2_x2_Name______TB.Text = $Null
                        $Cim.IO.p2_x2_Descript__TB.Text = $Null
                        $Cim.IO.p2_x2_Cost______TB.Text = $Null

                        $Cim.GetTab(2)
                    }
                }

                ElseIf ( $Cim.New -eq 1 )
                {
                    If ( $Cim.IO.p2_x3_Name______TB.Text -eq "" )
                    {
                        [System.Windows.MessageBox]::Show("Invalid service name","Error")
                    }

                    ElseIf ( $Cim.IO.p2_x3_Cost______TB.Text -eq "" )
                    {
                        [System.Windows.MessageBox]::Show("Service cost undefined","Error")
                    }

                    ElseIf ( $Cim.IO.p2_x3_Name______TB.Text -in $Cim.DB.Service.Record.Name )
                    {
                        [System.Windows.MessageBox]::Show("Service exists","Error")
                    }

                    Else
                    {
                        $Item                    = $Cim.NewUID(1)
                        $Cim.Refresh()
                        $Item.Record.Name        = $Cim.IO.p2_x3_Name______TB.Text
                        $Item.Record.Description = $Cim.IO.p2_x3_Descript__TB.Text
                        $Item.Record.Cost        = "{0:C}" -f [UInt32]$Cim.IO.p2_x3_Cost______TB.Text

                        [System.Windows.MessageBox]::Show("Service [$($Item.Record.Name)] added to database","Success")

                        $Cim.IO.p2_x3_Name______TB.Text = $Null
                        $Cim.IO.p2_x3_Descript__TB.Text = $Null
                        $Cim.IO.p2_x3_Cost______TB.Text = $Null

                        $Cim.GetTab(2)
                    }
                }

                Else
                {
                    [System.Windows.MessageBox]::Show("The entry was not saved","Error")
                }
            }

            3 # Device
            {
                If ( $Cim.New -eq 0 )
                {        
                    If ($Cim.IO.p3_x2_Chassis___LI.SelectedIndex -eq 8)
                    {
                        [System.Windows.MessageBox]::Show("Select a valid chassis type","Error")
                    }

                    ElseIf($Cim.IO.p3_x2_Vendor____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a vendor","Error")
                    }

                    ElseIf($Cim.IO.p3_x2_Model_____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a model","Error")
                    }

                    ElseIf($Cim.IO.p3_x2_Spec______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a model specification OR enter N/A","Error")
                    }

                    ElseIf($Cim.IO.p3_x2_Serial____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a serial number","Error")
                    }

                    Else
                    {
                        $Item                          = $Cim.NewUID(2)
                        $Cim.Refresh()
                        $Item.Record.Chassis           = $Cim.IO.p3_x2_Chassis___LI.SelectedIndex
                        $Item.Record.Vendor            = $Cim.IO.p3_x2_Vendor____TB.Text
                        $Item.Record.Specification     = $Cim.IO.p3_x2_Spec______TB.Text
                        $Item.Record.Serial            = $Cim.IO.p3_x2_Serial____TB.Text
                        $Item.Record.Model             = $Cim.IO.p3_x2_Model_____TB.Text
                        $Item.Record.Title             = $Cim.IO.p3_x2_Display___TB.Text
                        $Item.Record.Client            = $Cim.IO.p3_x2_Client____LI.Items
                        $Item.Record.Issue             = $Cim.IO.p3_x2_Issue_____LI.Items
                        $Item.Record.Purchase          = $Cim.IO.p3_x2_Purchase__LI.Items
                        $Item.Record.Invoice           = $Cim.IO.p3_x2_Invoice___LI.Items

                        [System.Windows.MessageBox]::Show("Device [$($Item.Record.Title)] added to database","Success")

                        $Cim.GetTab(3)
                    }
                }

                If ( $Cim.New -eq 1 )
                {        
                    If ($Cim.IO.p3_x3_Chassis___LI.SelectedIndex -eq 8)
                    {
                        [System.Windows.MessageBox]::Show("Select a valid chassis type","Error")
                    }

                    ElseIf($Cim.IO.p3_x3_Vendor____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a vendor","Error")
                    }

                    ElseIf($Cim.IO.p3_x3_Model_____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a model","Error")
                    }

                    ElseIf($Cim.IO.p3_x3_Spec______TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a model specification OR enter N/A","Error")
                    }

                    ElseIf($Cim.IO.p3_x3_Serial____TB.Text -eq "")
                    {
                        [System.Windows.MessageBox]::Show("Must enter a serial number","Error")
                    }

                    Else
                    {
                        $Item                          = $Cim.NewUID(2)
                        $Cim.Refresh()
                        $Item.Record.Chassis           = $Cim.IO.p3_x3_Chassis___LI.SelectedIndex
                        $Item.Record.Vendor            = $Cim.IO.p3_x3_Vendor____TB.Text
                        $Item.Record.Model             = $Cim.IO.p3_x3_Model_____TB.Text
                        $Item.Record.Specification     = $Cim.IO.p3_x3_Spec______TB.Text
                        
                        $Item.Record.Serial            = $Cim.IO.p3_x3_Serial____TB.Text
                        $Item.Record.DisplayName       = $Cim.IO.p3_x3_Display___TB.Text
                        $Item.Record.Client            = $Cim.IO.p3_x3_Client____LI.Items
                        $Item.Record.Issue             = $Cim.IO.p3_x3_Issue_____LI.Items
                        $Item.Record.Purchase          = $Cim.IO.p3_x3_Purchase__LI.Items
                        $Item.Record.Invoice           = $Cim.IO.p3_x3_Invoice___LI.Items

                        [System.Windows.MessageBox]::Show("Device [$($Item.Record.DisplayName)] added to database","Success")

                        $Cim.GetTab(3)
                    }
                }
            }

            4 # Issue
            {
                If ( $Cim.New -eq 0 )
                {
                    If ( $Cim.IO.p4_x2_Client____LI.Items.Count -lt 1 )
                    {
                        [System.Windows.MessageBox]::Show("No services specified","Error")
                    }

                    ElseIf ( $Cim.IO.p4_x2_Device____LI.Items.Count -lt 1 )
                    {
                        [System.Windows.MessageBox]::Show("No services specified","Error")
                    }

                    ElseIf ( $Cim.IO.p4_x2_Service___LI.Items.Count -lt 1 )
                    {
                        [System.Windows.MessageBox]::Show("No services specified","Error")
                    }

                    Switch($Cim.IO.p4_x2_Status____LI.SelectedIndex)
                    {
                        0 # New
                        {
                            [System.Windows.MessageBox]::Show("This option should be unreachable","Error")
                        }
                        
                        1 # Diagnosed
                        { 
                            If ( $Cim.IO.p4_x2_Service___LI.Items.Count -lt 1 )
                            {
                                [System.Windows.MessageBox]::Show("No services specified","Error")
                            }
                        } 
                        
                        2 # Commit
                        { 
                            If ( $Cim.IO.p4_x2_Service___LI.Items.Count -lt 1 )
                            {
                                [System.Windows.MessageBox]::Show("No services specified","Error")
                            }
                        } 
                        
                        3 # Complete
                        { 
                            If ( $Cim.IO.p4_x2_Service___LI.Items.Count -lt 1 )
                            {
                                [System.Windows.MessageBox]::Show("No services specified","Error")
                            }
                        }
                    }
                }

                If ( $Cim.New -eq 1 )
                {
                    If ( $Cim.IO.p4_x3_Client____LI.Items.Count -lt 1 )
                    {
                        [System.Windows.MessageBox]::Show("No client listed","Error")
                    }

                    ElseIf ( $Cim.IO.p4_x3_Device____LI.Items.Count -lt 1 )
                    {
                        [System.Windows.MessageBox]::Show("No client listed","Error")
                    }

                    Else
                    {
                        $Item                          = $Cim.NewUID(3)
                        $Cim.Refresh()
                    }
                }
            }
        }  

        $Cim.IO.Edit.IsEnabled = 0
        $Cim.IO.New.IsEnabled  = 1
        $Cim.IO.Save.IsEnabled = 0
        $Cim.GetTab($Cim.Slot)
    })

    $Cim.IO.p1_x2_Device____TC.Add_Click(
    {
        $Cim.IO.p1_x2_Device____TI.Visibility = "Visible"
        $Cim.IO.p1_x2_Invoice___TI.Visibility = "Collapsed"
    })

    $Cim.IO.p1_x2_Invoice___TC.Add_Click(
    {
        $Cim.IO.p1_x2_Device____TI.Visibility = "Collapsed"
        $Cim.IO.p1_x2_Invoice___TI.Visibility = "Visible"
    })

    $Cim.IO.p1_x2_Phone_____AB.Add_Click(
    {
        $Item   = $Cim.IO.p1_x2_Phone_____TB.Text.ToString() -Replace "-",""
        $String = "{0}{1}{2}-{3}{4}{5}-{6}{7}{8}{9}" -f $Item[0..9]

        If ( $Item.Length -ne 10 -or $Item -notmatch "(\d{10})" )
        {
            [System.Windows.MessageBox]::Show("Invalid phone number","Error")
        }

        ElseIf ( $String -in $Cim.IO.p1_x2_Phone_____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Duplicate phone number","Error")
        }

        ElseIf ($String -in $Cim.DB.Client.Record.Phone)
        {
            [System.Windows.MessageBox]::Show("Phone number belongs to another record","Error")
        }

        Else
        {
            $Cim.IO.p1_x2_Phone_____LI.Items.Add($String)
            $Cim.IO.p1_x2_Phone_____LI.SelectedIndex = ($Cim.IO.p1_x2_Phone_____LI.Items.Count - 1)
            $Cim.IO.p1_x2_Phone_____TB.Text = $Null
            $Item                           = $Null 
            $String                         = $Null
        }
    })

    $Cim.IO.p1_x2_Phone_____RB.Add_Click(
    {
        If ( $Cim.IO.p1_x2_Phone_____LI.Items.Count -eq 0)
        {
            [System.Windows.MessageBox]::Show("No phone number to remove","Error")
        }

        ElseIf( $Cim.IO.p1_x2_Phone_____LI.Items.Count -eq 1)
        {
            [System.Windows.MessageBox]::Show("Add another phone number before removing","Error")
        }

        Else
        {
            $Cim.IO.p1_x2_Phone_____LI.Items.Remove($Cim.IO.p1_x2_Phone_____LI.SelectedItem)
        }
    })

    $Cim.IO.p1_x2_Email_____AB.Add_Click(
    {
        
        $Item = $Cim.IO.p1_x2_Email_____TB.Text.ToString()

        If ( $Item -notmatch "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        {
            [System.Windows.MessageBox]::Show("Invalid Email Address","Error")
        }

        ElseIf ( $Item -in $Cim.IO.p1_x2_Email_____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Duplicate email address","Error")
        }

        ElseIf ($Item -in $Cim.DB.Client.Record.Email)
        {
            [System.Windows.MessageBox]::Show("Phone number belongs to another record","Error")
        }

        Else
        {
            $Cim.IO.p1_x2_Email_____LI.Items.Add($Item)
            $Cim.IO.p1_x2_Email_____LI.SelectedIndex = ($Cim.IO.p1_x2_Email_____LI.Count - 1)
            $Cim.IO.p1_x2_Email_____TB.Text,$Item = $Null
        }
    })

    $Cim.IO.p1_x2_Email_____RB.Add_Click(
    {    
        If ( $Cim.IO.p1_x2_Email_____LI.Items.Count -eq 0)
        {
            [System.Windows.MessageBox]::Show("No email address to remove","Error")
        }

        ElseIf( $Cim.IO.p1_x2_Email_____LI.Items.Count -eq 1)
        {
            [System.Windows.MessageBox]::Show("Add another email address before removing","Error")
        }

        Else
        {
            $Cim.IO.p1_x2_Email_____LI.Items.Remove($Cim.IO.p1_x2_Email_____LI.SelectedItem)
        }
    })

    $Cim.IO.p1_x2_Device____AB.Add_Click(
    {
        If ( $Cim.IO.p1_x2_Device____SR.Items.Count -eq 0 )
        {
            [System.Windows.MessageBox]::Show("No device listed to add","Error")
        }

        ElseIf( $Cim.IO.p1_x2_Device____SR.SelectedItem.UID -in $Cim.IO.p1_x2_Device____LI.Items)
        {
            [System.Windows.MessageBox]::Show("Device is already selected","Error")
        }

        $Cim.IO.p1_x2_Device____LI.Items.Add($Cim.IO.p1_x2_Device____SR.SelectedItem.UID)
    })

    $Cim.IO.p1_x2_Device____RB.Add_Click(
    {
        If ($Cim.IO.p1_x2_Device____LI.SelectedIndex -eq -1 -or $Cim.IO.p1_x2_Device____LI.Items.Count -eq 0 )
        {
            [System.Windows.MessageBox]::Show("No device listed to remove","Error")
        }

        $Cim.IO.p1_x2_Device____LI.Items.Remove($Cim.IO.p1_x2_Device____SR.SelectedItem.UID)
    })

    $Cim.IO.p1_x3_Phone_____AB.Add_Click(
    {
        $Item   = $Cim.IO.p1_x3_Phone_____TB.Text.ToString() -Replace "-",""
        $String = "{0}{1}{2}-{3}{4}{5}-{6}{7}{8}{9}" -f $Item[0..9]

        If ( $Item.Length -ne 10 -or $Item -notmatch "(\d{10})" )
        {
            [System.Windows.MessageBox]::Show("Invalid phone number","Error")
        }

        ElseIf ( $String -in $Cim.IO.p1_x3_Phone_____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Duplicate phone number","Error")
        }

        ElseIf ($String -in $Cim.DB.Client.Record.Phone)
        {
            [System.Windows.MessageBox]::Show("Phone number belongs to another record","Error")
        }

        Else
        {
            $Cim.IO.p1_x3_Phone_____LI.Items.Add($String)
            $Cim.IO.p1_x3_Phone_____LI.SelectedIndex = ($Cim.IO.p1_x3_Phone_____LI.Items.Count - 1)
            $Cim.IO.p1_x3_Phone_____TB.Text = $Null
            $Item                           = $Null 
            $String                         = $Null
        }
    })

    $Cim.IO.p1_x3_Phone_____RB.Add_Click(
    {
        If ( $Cim.IO.p1_x3_Phone_____LI.Items.Count -eq 0)
        {
            [System.Windows.MessageBox]::Show("No phone number to remove","Error")
        }

        ElseIf( $Cim.IO.p1_x3_Phone_____LI.Items.Count -eq 1)
        {
            [System.Windows.MessageBox]::Show("Add another phone number before removing","Error")
        }

        Else
        {
            $Cim.IO.p1_x3_Phone_____LI.Items.Remove($Cim.IO.p1_x3_Phone_____LI.SelectedItem)
        }
    })

    $Cim.IO.p1_x3_Email_____AB.Add_Click(
    {
        
        $Item = $Cim.IO.p1_x3_Email_____TB.Text.ToString()

        If ( $Item -notmatch "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        {
            [System.Windows.MessageBox]::Show("Invalid Email Address","Error")
        }

        ElseIf ( $Item -in $Cim.IO.p1_x3_Email_____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Duplicate email address","Error")
        }

        ElseIf ($Item -in $Cim.DB.Client.Record.Email)
        {
            [System.Windows.MessageBox]::Show("Phone number belongs to another record","Error")
        }

        Else
        {
            $Cim.IO.p1_x3_Email_____LI.Items.Add($Item)
            $Cim.IO.p1_x3_Email_____LI.SelectedIndex = ($Cim.IO.p1_x3_Email_____LI.Count - 1)
            $Cim.IO.p1_x3_Email_____TB.Text,$Item = $Null
        }
    })

    $Cim.IO.p1_x3_Email_____RB.Add_Click(
    {    
        If ( $Cim.IO.p1_x3_Email_____LI.Items.Count -eq 0)
        {
            [System.Windows.MessageBox]::Show("No email address to remove","Error")
        }

        ElseIf( $Cim.IO.p1_x3_Email_____LI.Items.Count -eq 1)
        {
            [System.Windows.MessageBox]::Show("Add another email address before removing","Error")
        }

        Else
        {
            $Cim.IO.p1_x3_Email_____LI.Items.Remove($Cim.IO.p1_x3_Email_____LI.SelectedItem)
        }
    })

    $Cim.IO.p1_x3_Device____AB.Add_Click(
    {
        If ( $Cim.IO.p1_x3_Device____SR.Items.Count -eq 0 )
        {
            [System.Windows.MessageBox]::Show("No device listed to add","Error")
        }

        ElseIf( $Cim.IO.p1_x3_Device____SR.SelectedItem.UID -in $Cim.IO.p1_x3_Device____LI.Items.UID)
        {
            [System.Windows.MessageBox]::Show("Device is already selected","Error")
        }

        $Cim.IO.p1_x3_Device____LI.Items.Add($Cim.IO.p1_x3_Device____SR.SelectedItem)
    })

    $Cim.IO.p1_x3_Device____RB.Add_Click(
    {
        If ($Cim.IO.p1_x3_Device____LI.SelectedIndex -eq -1 -or $Cim.IO.p1_x3_Device____LI.Items.Count -eq 0 )
        {
            [System.Windows.MessageBox]::Show("No device listed to remove","Error")
        }

        Else
        {
            $Cim.IO.p1_x3_Device____LI.Items.Remove($Cim.IO.p1_x3_Device____SR.SelectedItem)
        }
    })

    $Cim.IO.p4_x2_Client____RB.IsEnabled = 0
    $Cim.IO.p4_x2_Device____RB.IsEnabled = 0
    $Cim.IO.p4_x2_Purchase__RB.IsEnabled = 0
    $Cim.IO.p4_x2_Service___RB.IsEnabled = 0
    $Cim.IO.p4_x2_Invoice___RB.IsEnabled = 0

    $Cim.IO.p4_x2_Client____LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x2_Client____LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x2_Client____AB.IsEnabled = 1
                $Cim.IO.p4_x2_Client____RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x2_Client____AB.IsEnabled = 0 
                $Cim.IO.p4_x2_Client____RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x2_Device____LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x2_Device____LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x2_Device____AB.IsEnabled = 1
                $Cim.IO.p4_x2_Device____RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x2_Device____AB.IsEnabled = 0 
                $Cim.IO.p4_x2_Device____RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x2_Purchase__LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x2_Purchase__LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x2_Purchase__AB.IsEnabled = 1
                $Cim.IO.p4_x2_Purchase__RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x2_Purchase__AB.IsEnabled = 0 
                $Cim.IO.p4_x2_Purchase__RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x2_Client____AB.Add_Click(
    {
        If ( $Cim.IO.p4_x2_Client____SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x2_Client____SR.SelectedItem -in $Cim.IO.p4_x2_Client____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x2_Client____LI.Items.Add($Cim.IO.p4_x2_Client____SR.SelectedItem.UID)
            $Cim.IO.p4_x2_Client____AB.IsEnabled = 0
            $Cim.IO.p4_x2_Client____RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x2_Client____RB.Add_Click(
    {
        $Cim.IO.p4_x2_Client____LI($Cim.IO.p4_x2_Client____SR.SelectedItem.UID)
        $Cim.IO.p4_x2_Client____AB.IsEnabled = 1
        $Cim.IO.p4_x2_Client____RB.IsEnabled = 0
    })

    $Cim.IO.p4_x2_Device____AB.Add_Click(
    {
        If ( $Cim.IO.p4_x2_Device____SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x2_Device____SR.SelectedItem -in $Cim.IO.p4_x2_Device____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x2_Device____LI.Items.Add($Cim.IO.p4_x2_Device____SR.SelectedItem.UID)
            $Cim.IO.p4_x2_Device____AB.IsEnabled = 0
            $Cim.IO.p4_x2_Device____RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x2_Device____RB.Add_Click(
    {
        $Cim.IO.p4_x2_Device____LI($Cim.IO.p4_x2_Device____SR.SelectedItem.UID)
        $Cim.IO.p4_x2_Device____AB.IsEnabled = 1
        $Cim.IO.p4_x2_Device____RB.IsEnabled = 0
    })

    $Cim.IO.p4_x2_Purchase__AB.Add_Click(
    {
        If ( $Cim.IO.p4_x2_Purchase__SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x2_Purchase__SR.SelectedItem -in $Cim.IO.p4_x2_Purchase__LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x2_Purchase__LI.Items.Add($Cim.IO.p4_x2_Purchase__SR.SelectedItem.UID)
            $Cim.IO.p4_x2_Purchase__AB.IsEnabled = 0
            $Cim.IO.p4_x2_Purchase__RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x2_Purchase__RB.Add_Click(
    {
        $Cim.IO.p4_x2_Purchase__LI($Cim.IO.p4_x2_Purchase__SR.SelectedItem.UID)
        $Cim.IO.p4_x2_Purchase__AB.IsEnabled = 1
        $Cim.IO.p4_x2_Purchase__RB.IsEnabled = 0
    })

    $Cim.IO.p4_x2_Service___AB.Add_Click(
    {
        If ( $Cim.IO.p4_x2_Service___SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x2_Service___SR.SelectedItem -in $Cim.IO.p4_x2_Service___LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x2_Service___LI.Items.Add($Cim.IO.p4_x2_Service___SR.SelectedItem.UID)
            $Cim.IO.p4_x2_Service___AB.IsEnabled = 0
            $Cim.IO.p4_x2_Service___RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x2_Service___RB.Add_Click(
    {
        $Cim.IO.p4_x2_Service___LI($Cim.IO.p4_x2_Service___SR.SelectedItem.UID)
        $Cim.IO.p4_x2_Service___AB.IsEnabled = 1
        $Cim.IO.p4_x2_Service___RB.IsEnabled = 0
    })

    $Cim.IO.p4_x2_Invoice___AB.Add_Click(
    {
        If ( $Cim.IO.p4_x2_Invoice___SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x2_Invoice___SR.SelectedItem -in $Cim.IO.p4_x2_Invoice___LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x2_Invoice___LI.Items.Add($Cim.IO.p4_x2_Invoice___SR.SelectedItem.UID)
            $Cim.IO.p4_x2_Invoice___AB.IsEnabled = 0
            $Cim.IO.p4_x2_Invoice___RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x2_Invoice___RB.Add_Click(
    {
        $Cim.IO.p4_x2_Invoice___LI($Cim.IO.p4_x2_Invoice___SR.SelectedItem.UID)
        $Cim.IO.p4_x2_Invoice___AB.IsEnabled = 1
        $Cim.IO.p4_x2_Invoice___RB.IsEnabled = 0
    })

    $Cim.IO.p4_x3_Client____RB.IsEnabled = 0
    $Cim.IO.p4_x3_Device____RB.IsEnabled = 0
    $Cim.IO.p4_x3_Purchase__RB.IsEnabled = 0
    $Cim.IO.p4_x3_Service___RB.IsEnabled = 0
    $Cim.IO.p4_x3_Invoice___RB.IsEnabled = 0

    $Cim.IO.p4_x3_Client____LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x3_Client____LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x3_Client____AB.IsEnabled = 1
                $Cim.IO.p4_x3_Client____RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x3_Client____AB.IsEnabled = 0 
                $Cim.IO.p4_x3_Client____RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x3_Device____LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x3_Device____LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x3_Device____AB.IsEnabled = 1
                $Cim.IO.p4_x3_Device____RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x3_Device____AB.IsEnabled = 0 
                $Cim.IO.p4_x3_Device____RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x3_Purchase__LI.Add_DataContextChanged(
    {
        Switch($Cim.IO.p4_x3_Purchase__LI.Items.Count)
        {
            0 
            { 
                $Cim.IO.p4_x3_Purchase__AB.IsEnabled = 1
                $Cim.IO.p4_x3_Purchase__RB.IsEnabled = 0 
            } 

            1 
            { 
                $Cim.IO.p4_x3_Purchase__AB.IsEnabled = 0 
                $Cim.IO.p4_x3_Purchase__RB.IsEnabled = 1
            }
        }
    })

    $Cim.IO.p4_x3_Client____AB.Add_Click(
    {
        If ( $Cim.IO.p4_x3_Client____SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x3_Client____SR.SelectedItem -in $Cim.IO.p4_x3_Client____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x3_Client____LI.Items.Add($Cim.IO.p4_x3_Client____SR.SelectedItem.UID)
            $Cim.IO.p4_x3_Client____AB.IsEnabled = 0
            $Cim.IO.p4_x3_Client____RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x3_Client____RB.Add_Click(
    {
        $Cim.IO.p4_x3_Client____LI($Cim.IO.p4_x3_Client____SR.SelectedItem.UID)
        $Cim.IO.p4_x3_Client____AB.IsEnabled = 1
        $Cim.IO.p4_x3_Client____RB.IsEnabled = 0
    })

    $Cim.IO.p4_x3_Device____AB.Add_Click(
    {
        If ( $Cim.IO.p4_x3_Device____SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x3_Device____SR.SelectedItem -in $Cim.IO.p4_x3_Device____LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x3_Device____LI.Items.Add($Cim.IO.p4_x3_Device____SR.SelectedItem.UID)
            $Cim.IO.p4_x3_Device____AB.IsEnabled = 0
            $Cim.IO.p4_x3_Device____RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x3_Device____RB.Add_Click(
    {
        $Cim.IO.p4_x3_Device____LI($Cim.IO.p4_x3_Device____SR.SelectedItem.UID)
        $Cim.IO.p4_x3_Device____AB.IsEnabled = 1
        $Cim.IO.p4_x3_Device____RB.IsEnabled = 0
    })

    $Cim.IO.p4_x3_Purchase__AB.Add_Click(
    {
        If ( $Cim.IO.p4_x3_Purchase__SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x3_Purchase__SR.SelectedItem -in $Cim.IO.p4_x3_Purchase__LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x3_Purchase__LI.Items.Add($Cim.IO.p4_x3_Purchase__SR.SelectedItem.UID)
            $Cim.IO.p4_x3_Purchase__AB.IsEnabled = 0
            $Cim.IO.p4_x3_Purchase__RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x3_Purchase__RB.Add_Click(
    {
        $Cim.IO.p4_x3_Purchase__LI($Cim.IO.p4_x3_Purchase__SR.SelectedItem.UID)
        $Cim.IO.p4_x3_Purchase__AB.IsEnabled = 1
        $Cim.IO.p4_x3_Purchase__RB.IsEnabled = 0
    })

    $Cim.IO.p4_x3_Service___AB.Add_Click(
    {
        If ( $Cim.IO.p4_x3_Service___SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x3_Service___SR.SelectedItem -in $Cim.IO.p4_x3_Service___LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x3_Service___LI.Items.Add($Cim.IO.p4_x3_Service___SR.SelectedItem.UID)
            $Cim.IO.p4_x3_Service___AB.IsEnabled = 0
            $Cim.IO.p4_x3_Service___RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x3_Service___RB.Add_Click(
    {
        $Cim.IO.p4_x3_Service___LI($Cim.IO.p4_x3_Service___SR.SelectedItem.UID)
        $Cim.IO.p4_x3_Service___AB.IsEnabled = 1
        $Cim.IO.p4_x3_Service___RB.IsEnabled = 0
    })

    $Cim.IO.p4_x3_Invoice___AB.Add_Click(
    {
        If ( $Cim.IO.p4_x3_Invoice___SR.SelectedIndex -eq -1 )
        {
            [System.Windows.MessageBox]::Show("No client selected","Error")
        }

        ElseIf ( $Cim.IO.p4_x3_Invoice___SR.SelectedItem -in $Cim.IO.p4_x3_Invoice___LI.Items )
        {
            [System.Windows.MessageBox]::Show("Client is already specified","Error")
        }

        Else
        {
            $Cim.IO.p4_x3_Invoice___LI.Items.Add($Cim.IO.p4_x3_Invoice___SR.SelectedItem.UID)
            $Cim.IO.p4_x3_Invoice___AB.IsEnabled = 0
            $Cim.IO.p4_x3_Invoice___RB.IsEnabled = 1
        }
    })

    $Cim.IO.p4_x3_Invoice___RB.Add_Click(
    {
        $Cim.IO.p4_x3_Invoice___LI($Cim.IO.p4_x3_Invoice___SR.SelectedItem.UID)
        $Cim.IO.p4_x3_Invoice___AB.IsEnabled = 1
        $Cim.IO.p4_x3_Invoice___RB.IsEnabled = 0
    })

    <#
    $Cim.IO._EditIssueTab.Add_Click(
    {
        $Cim.EditTab(4)
        $Cim.EditIssue($Cim.IO._GetIssueSearchResult.SelectedItem.UID)

        $Cim.Populate($Cim.DB.Service.Record,$Cim.IO._EditIssueServiceSearchResult)

        $Cim.IO._EditIssueTab.IsEnabled = 0
        $Cim.IO._NewIssueTab.IsEnabled  = 1
        $Cim.IO._SaveIssueTab.IsEnabled = 1
    })

    $Cim.IO._NewIssueTab.Add_Click(
    { 
        $Cim.NewTab(4)

        $Cim.Relinquish($Cim.IO._NewIssueClientSearchResult)
        $Cim.Relinquish($Cim.IO._NewIssueDeviceSearchResult)
        $Cim.Relinquish($Cim.IO._NewIssuePurchaseSearchResult)
        $Cim.Relinquish($Cim.IO._NewIssueServiceSearchResult)
        $Cim.Relinquish($Cim.IO._NewIssueInvoiceSearchResult)

        $Cim.IO._NewIssueClientList.ItemsSource = $Null
        $Cim.IO._NewIssueDeviceList.ItemsSource = $Null
        $Cim.IO._NewIssuePurchaseList.ItemsSource = $Null
        $Cim.IO._NewIssueServiceList.ItemsSource = $Null
        $Cim.IO._NewIssueInvoiceList.ItemsSource = $Null

        $Cim.Populate($Cim.DB.Client,$Cim.IO._NewIssueClientSearchResult)
        $Cim.Populate($Cim.DB.Device,$Cim.IO._NewIssueDeviceSearchResult)
        $Cim.Populate($Cim.DB.Purchase,$Cim.IO._NewIssuePurchaseSearchResult)
        $Cim.Populate($Cim.DB.Service,$Cim.IO._NewIssueServiceSearchResult)
        $Cim.Populate($Cim.DB.Invoice,$Cim.IO._NewIssueInvoiceSearchResult)

        $Cim.IO._EditIssueTab.IsEnabled = 0
        $Cim.IO._NewIssueTab.IsEnabled  = 0
        $Cim.IO._SaveIssueTab.IsEnabled = 1
    })

    $Cim.IO._NewIssueAddService.Add_Click(
    {
        $Item = $Cim.DB.Service | ? { $_.Record.Name -eq $Cim.IO._NewIssueServiceSearchResult.SelectedItem }
        
        If ( $Item -in $Cim.IO._NewIssueServiceList.Items )
        {
            [System.Windows.MessageBox]::Show("Service is already selected","Error")
        }   
            
        Else
        {
            $Cim.IO._NewIssueServiceList.Items.Add($Item.Record.Name)
        }

    })

    $Cim.IO._NewIssueRemoveService.Add_Click(
    {
        $Item = $Cim.DB.Service | ? { $_.Record.Name -eq $Cim.IO._NewIssueServiceSearchResult.SelectedItem }

        If ( $Item -in $Cim.IO._NewIssueServiceList.Items )
        {
            $Cim.IO._NewIssueServiceList.Items.Remove($Item.Record.Name)
        }
    })

    $Cim.IO._EditInventoryTab.Add_Click(
    {
        $Cim.EditTab(5)
        $Cim.EditInventory($Cim.IO._GetInventorySearchResult.SelectedItem.UID)
        $Cim.IO._EditInventoryTab.IsEnabled = 0
        $Cim.IO._NewInventoryTab.IsEnabled  = 1
        $Cim.IO._SaveInventoryTab.IsEnabled = 1
    })

    $Cim.IO._NewInventoryTab.Add_Click(
    { 
        $Cim.NewTab(5)
        $Cim.IO._EditInventoryTab.IsEnabled = 0
        $Cim.IO._NewInventoryTab.IsEnabled  = 0
        $Cim.IO._SaveInventoryTab.IsEnabled = 1
    })

    $Cim.IO._EditPurchaseTab.Add_Click(
    {
        $Cim.EditTab(6)
        $Cim.EditPurchase($Cim.IO._GetPurchaseSearchResult.SelectedItem.UID)
        $Cim.IO._EditPurchaseTab.IsEnabled = 0
        $Cim.IO._NewPurchaseTab.IsEnabled  = 1
        $Cim.IO._SavePurchaseTab.IsEnabled = 1
    })

    $Cim.IO._NewPurchaseTab.Add_Click(
    { 
        $Cim.NewTab(6)
        $Cim.IO._EditPurchaseTab.IsEnabled = 0
        $Cim.IO._NewPurchaseTab.IsEnabled  = 0
        $Cim.IO._SavePurchaseTab.IsEnabled = 1
    })
    }

    $Cim.IO._EditExpenseTab.Add_Click(
    {
        $Cim.EditTab(7)
        $Cim.EditExpense($Cim.IO._GetExpenseSearchResult.SelectedItem.UID)
        $Cim.IO._EditExpenseTab.IsEnabled = 0
        $Cim.IO._NewExpenseTab.IsEnabled  = 1
        $Cim.IO._SaveExpenseTab.IsEnabled = 1
    })

    $Cim.IO._NewExpenseTab.Add_Click(
    { 
        $Cim.NewTab(7)
        $Cim.IO._EditExpenseTab.IsEnabled = 0
        $Cim.IO._NewExpenseTab.IsEnabled  = 0
        $Cim.IO._SaveExpenseTab.IsEnabled = 1
    })

    $Cim.IO._EditAccountTab.Add_Click(
    {
        $Cim.EditTab(8)
        $Cim.EditAccount($Cim.IO._GetAccountSearchResult.SelectedItem.UID)
        $Cim.IO._EditAccountTab.IsEnabled = 0
        $Cim.IO._NewAccountTab.IsEnabled  = 1
        $Cim.IO._SaveAccountTab.IsEnabled = 1
    })

    $Cim.IO._NewAccountTab.Add_Click(
    { 
        $Cim.NewTab(8)
        $Cim.IO._EditAccountTab.IsEnabled = 0
        $Cim.IO._NewAccountTab.IsEnabled  = 0
        $Cim.IO._SaveAccountTab.IsEnabled = 1
    })

    $Cim.IO._EditInvoiceTab.Add_Click(
    {
        $Cim.EditTab(9)
        $Cim.EditInvoice($Cim.IO._GetInvoiceSearchResult.SelectedItem.UID)
        $Cim.IO._EditInvoiceTab.IsEnabled = 0
        $Cim.IO._NewInvoiceTab.IsEnabled  = 1
        $Cim.IO._SaveInvoiceTab.IsEnabled = 1
    })

    $Cim.IO._NewInvoiceTab.Add_Click(
    { 
        $Cim.NewTab(9)
        $Cim.IO._EditInvoiceTab.IsEnabled = 0
        $Cim.IO._NewInvoiceTab.IsEnabled  = 0
        $Cim.IO._SaveInvoiceTab.IsEnabled = 1
    })
    #>
    $Cim.Window.Invoke()
}
