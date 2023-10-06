# Script: This requires [imagemagick] in order to convert (*.tga) -> (*.jpg) for the GUI

Function Get-Q3AController
{
    [CmdLetBinding()]Param(
    [Parameter()][ValidateSet(0,1)][UInt32]$Mode=0,
    [Parameter()][Object[]]$List)

    # // ===================================
    # // | Q3A Controller Xaml for the GUI |
    # // ===================================

    Class Q3AControllerXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[FightingEntropy()]://Quake III Arena Configuration Utility"',
        '        Height="640"',
        '        Width="800"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Graphics\icon.ico"',
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
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="20"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style x:Key="DGCombo" TargetType="ComboBox">',
        '            <Setter Property="Margin" Value="0"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="18"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalAlignment" Value="Center"/>',
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
        '            <Setter Property="Height"   Value="20"/>',
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
        '                            <TextBlock Text="{Binding Description}"',
        '                                       TextWrapping="Wrap"',
        '                                       FontFamily="Consolas"',
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
        '        <Style x:Key="xTextBlock" TargetType="TextBlock">',
        '            <Setter Property="TextWrapping"',
        '                    Value="WrapWithOverflow"/>',
        '            <Setter Property="FontFamily"',
        '                    Value="Consolas"/>',
        '            <Setter Property="FontWeight"',
        '                    Value="Heavy"/>',
        '            <Setter Property="Background"',
        '                    Value="#000000"/>',
        '            <Setter Property="Foreground"',
        '                    Value="#00FF00"/>',
        '        </Style>',
        '        <Style x:Key="xDataGridRow"',
        '               TargetType="DataGridRow">',
        '            <Setter Property="VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="VerticalContentAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="TextBlock.VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="Height"',
        '                    Value="20"/>',
        '            <Setter Property="FontSize"',
        '                    Value="12"/>',
        '            <Setter Property="FontWeight"',
        '                    Value="Heavy"/>',
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
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
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
        '            <RowDefinition Height="140"/>',
        '            <RowDefinition Height="280"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="200"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Grid Grid.Column="0">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Game]:"/>',
        '                    <TextBox Name="Game"',
        '                             Grid.Column="1"/>',
        '                    <Image Name="GameIcon"',
        '                           Grid.Column="2"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1"',
        '                          Name="Property"',
        '                          HeadersVisibility="None">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Width="60"',
        '                                            Binding="{Binding Name}"/>',
        '                        <DataGridTextColumn Header="Value"',
        '                                            Width="*"',
        '                                            Binding="{Binding Value}"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
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
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Name="Browse"',
        '                            Content="Browse"',
        '                            Grid.Column="0"/>',
        '                    <Button Name="Set"',
        '                            Grid.Column="1"',
        '                            IsEnabled="False"',
        '                            Content="Set"/>',
        '                </Grid>',
        '                <Grid Grid.Row="1">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="10"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="10"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="10"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="[Archive(s)]:"/>',
        '                        <TextBox Name="ArchiveCount"',
        '                                 Grid.Column="2"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="10"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="10"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="1"',
        '                               Content="[Level(s)]:"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="LevelCount"/>',
        '                    </Grid>',
        '                    <Border Grid.Row="3" Background="Black" Margin="4"/>',
        '                </Grid>',
        '            </Grid>',
        '        </Grid>',
        '        <TabControl Grid.Row="1">',
        '            <TabItem Header="Archive(s)">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Name="Archive">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}"',
        '                               BasedOn="{StaticResource xDataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding Fullname}"',
        '                                                           Style="{StaticResource xTextBlock}"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                        <Setter Property="ToolTipService.ShowDuration"',
        '                                                Value="360000000"/>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Width="40"',
        '                                                Binding="{Binding Index}"/>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Width="*"',
        '                                                Binding="{Binding Name}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Level(s)">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="2*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Level]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="LevelName"/>',
        '                        </Grid>',
        '                        <DataGrid Grid.Row="1"',
        '                                  Name="Level">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}"',
        '                                       BasedOn="{StaticResource xDataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Fullname}"',
        '                                                               Style="{StaticResource xTextBlock}"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                            <Setter Property="ToolTipService.ShowDuration"',
        '                                                    Value="360000000"/>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="#"',
        '                                                Width="40"',
        '                                                Binding="{Binding Index}"/>',
        '                                <DataGridTextColumn Header="Date"',
        '                                                Binding="{Binding Date}"',
        '                                                Width="75"/>',
        '                                <DataGridTextColumn Header="Time"',
        '                                                Binding="{Binding Time}"',
        '                                                Width="90"/>',
        '                                <DataGridTextColumn Header="Name"',
        '                                                Width="*"',
        '                                                Binding="{Binding Name}"/>',
        '                                <DataGridTemplateColumn Header="[+]" Width="25">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <CheckBox IsChecked="{Binding Profile,',
        '                                                                  Mode=TwoWay,',
        '                                                                  NotifyOnSourceUpdated=True,',
        '                                                                  NotifyOnTargetUpdated=True,',
        '                                                                  UpdateSourceTrigger=PropertyChanged}">',
        '                                                <CheckBox.LayoutTransform>',
        '                                                    <ScaleTransform ScaleX="0.9" ScaleY="0.9"/>',
        '                                                </CheckBox.LayoutTransform>',
        '                                            </CheckBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="25"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Config]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="ConfigName"/>',
        '                            <Image Grid.Column="2"',
        '                                   Name="ConfigNameIcon"/>',
        '                            <Button Grid.Column="3"',
        '                                    Name="Create"',
        '                                    Content="Create"',
        '                                    IsEnabled="False"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                    <Grid Grid.Column="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Image Grid.Column="0"',
        '                               Name="Image"/>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Button Grid.Column="1"',
        '                                    Name="Clear"',
        '                                    Content="Clear"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Config">',
        '                <TabControl>',
        '                    <TabItem Header="Queue">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <DataGrid Grid.Row="0"',
        '                                      Name="Config">',
        '                                <DataGrid.RowStyle>',
        '                                    <Style TargetType="{x:Type DataGridRow}"',
        '                                           BasedOn="{StaticResource xDataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="{Binding Title}"',
        '                                                                   Style="{StaticResource xTextBlock}"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
        '                                                <Setter Property="ToolTipService.ShowDuration"',
        '                                                        Value="360000000"/>',
        '                                            </Trigger>',
        '                                        </Style.Triggers>',
        '                                    </Style>',
        '                                </DataGrid.RowStyle>',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="#"',
        '                                                        Width="40"',
        '                                                        Binding="{Binding Index}"/>',
        '                                    <DataGridTextColumn Header="Date"',
        '                                                        Binding="{Binding Date}"',
        '                                                        Width="75"/>',
        '                                    <DataGridTextColumn Header="Time"',
        '                                                        Binding="{Binding Time}"',
        '                                                        Width="90"/>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                        Width="150"',
        '                                                        Binding="{Binding Name}"/>',
        '                                    <DataGridTextColumn Header="Title"',
        '                                                        Width="*"',
        '                                                        Binding="{Binding Title}"/>',
        '                                    <DataGridTextColumn Header="Mode"',
        '                                                        Width="60"',
        '                                                        Binding="{Binding ModeStr}"/>',
        '                                    <DataGridTextColumn Header="Rating"',
        '                                                        Width="60"',
        '                                                        Binding="{Binding Rating}"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="160"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="90"/>',
        '                                    <ColumnDefinition Width="90"/>',
        '                                    <ColumnDefinition Width="60"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0"',
        '                                       Content="[Title/Mode/Rating]:"/>',
        '                                <TextBox Grid.Column="1"',
        '                                         Name="MapTitle"/>',
        '                                <TextBox Grid.Column="2"',
        '                                         Name="MapMode"/>',
        '                                <TextBox Grid.Column="3"',
        '                                         Name="MapRating"/>',
        '                                <Button Grid.Column="4"',
        '                                        Name="Apply"',
        '                                        Content="Apply"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0"',
        '                                        Name="Randomize"',
        '                                        Content="Randomize"/>',
        '                                <Button Grid.Column="1"',
        '                                        Name="Export"',
        '                                        Content="Export"/>',
        '                                <Button Grid.Column="2"',
        '                                        Name="Import"',
        '                                        Content="Import"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Content">',
        '                        <TextBox Name="Content"',
        '                         Height="220"/>',
        '                    </TabItem>',
        '                </TabControl>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <DataGrid Grid.Row="2"',
        '                      Name="Console"',
        '                      SelectionMode="Extended">',
        '                <DataGrid.RowStyle>',
        '                    <Style TargetType="{x:Type DataGridRow}"',
        '                           BasedOn="{StaticResource xDataGridRow}">',
        '                        <Style.Triggers>',
        '                            <Trigger Property="IsMouseOver" Value="True">',
        '                                <Setter Property="ToolTip">',
        '                                    <Setter.Value>',
        '                                        <TextBlock Text="{Binding String}"',
        '                                                   Style="{StaticResource xTextBlock}"/>',
        '                                    </Setter.Value>',
        '                                </Setter>',
        '                                <Setter Property="ToolTipService.ShowDuration"',
        '                                        Value="360000000"/>',
        '                            </Trigger>',
        '                        </Style.Triggers>',
        '                    </Style>',
        '                </DataGrid.RowStyle>',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="#"',
        '                                        Binding="{Binding Index}"',
        '                                        Width="50"/>',
        '                    <DataGridTextColumn Header="Elapsed"',
        '                                        Binding="{Binding Elapsed}"',
        '                                        Width="125"/>',
        '                    <DataGridTextColumn Header="State"',
        '                                        Binding="{Binding State}"',
        '                                        Width="50"/>',
        '                    <DataGridTextColumn Header="Status"',
        '                                        Binding="{Binding Status}"',
        '                                        Width="*"/>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '        </Grid>',
        '        <Grid Grid.Row="3">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="90"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="1"',
        '                    Name="Launch"',
        '                    Content="Launch"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    # // ===========================================================
    # // | Provides an individual Xaml property access to controls |
    # // ===========================================================

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

    # // ==================================================================
    # // | Creates an object that (processes/controls) the Xaml +  Window |
    # // ==================================================================
    
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
            Return "<FEModule.XamlWindow[Q3AControllerXaml]>"
        }
    }

    # // =====================================================
    # // | Meant to contain DataGrid properties for the game |
    # // =====================================================

    Class Q3AProperty
    {
        [String] $Name
        [String] $Value
        Q3AProperty([String]$Name,[String]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }    

    # // ===================================================================
    # // | Used as a template for any (*.bsp) to populate (Level + Config) |
    # // ===================================================================

    Class Pk3FileBsp
    {
        [UInt32]         $Index
        Hidden [DateTime] $Real
        [String]          $Date
        [String]          $Time
        [String]          $Name
        [UInt32]       $Profile
        [String]         $Image
        Pk3FileBsp([UInt32]$Index,[Object]$Bsp)
        {
            $This.Index   = $Index
            $This.Real    = $Bsp.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Date    = $This.Real.ToString("MM/dd/yyyy")
            $This.Time    = $This.Real.ToString("HH:mm:ss")
            $This.Name    = $Bsp.Name -ireplace "\.bsp",""
        }
        SetProfile([UInt32]$xProfile)
        {
            $This.Profile = $xProfile
        }
        SetImage([String]$Image)
        {
            $This.Image  = $Image
        }
        [String] ToString()
        {
            Return "{0} {1} {2}" -f $This.Date, $This.Time, $This.Name
        }
    }

    # // =======================================================
    # // | Represents the compressed size of a particular file |
    # // =======================================================

    Class Pk3FileEntrySize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        Pk3FileEntrySize([UInt64]$Bytes)
        {
            $This.Name   = "Compressed"
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    # // ====================================================================
    # // | Template for each individual entry in all selected (*.pk3) files |
    # // ====================================================================

    Class Pk3FileEntry
    {
        [UInt32]         $Index
        Hidden [DateTime] $Real
        [String]          $Date
        [Object]          $Size
        [String]          $Name
        [String]      $Fullname
        Pk3FileEntry([UInt32]$Index,[Object]$Entry)
        {
            $This.Index    = $Index
            $This.Real     = $Entry.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Date     = $This.Real.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Size     = $This.Pk3FileEntrySize($Entry.CompressedLength)
            $This.Name     = $Entry.Name
            $This.Fullname = $Entry.Fullname
        }
        [Object] Pk3FileEntrySize([UInt64]$Bytes)
        {
            Return [Pk3FileEntrySize]::New($Bytes)
        }
    }

    # // ==============================================================
    # // | Template for each individual (*.pk3) file in the base path |
    # // ==============================================================

    Class Pk3FileArchive
    {
        [UInt32]    $Index
        [String]     $Name
        [String] $Fullname
        [Object]  $Archive
        [Object]   $Output
        Pk3FileArchive([UInt32]$Index,[Object]$File)
        {
            $This.Index    = $Index
            $This.Name     = $File.Name
            $This.Fullname = $File.Fullname
            $This.Archive  = [System.IO.Compression.ZipFile]::Open($This.Fullname,"Read")
            $This.Refresh()
        }
        Clear()
        {
            $This.Output   = @( )
        }
        [Object] Pk3FileEntry([UInt32]$Index,[Object]$Entry)
        {
            Return [Pk3FileEntry]::New($Index,$Entry)
        }
        Refresh()
        {   
            $This.Clear()

            ForEach ($Entry in $This.Archive.Entries | Sort-Object Fullname)
            {
                $This.Output += $This.Pk3FileEntry($This.Output.Count,$Entry)
            }
        }
    }

    # // ===========================================================================
    # // | Template for all (queued/selected) maps to include in the configuration |
    # // ===========================================================================

    Class Q3AMapItem
    {
        [UInt32]          $Index
        Hidden [DateTime]  $Real
        [String]           $Date
        [String]           $Time
        [String]           $Name
        [String]          $Title
        [Int32[]]          $Mode
        Hidden [String] $ModeStr
        [Float]          $Rating
        Q3AMapItem([UInt32]$Index,[Object]$Map)
        {
            $This.Index  = $Index
            $This.Real   = $Map.Real.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Date   = $Map.Date
            $This.Time   = $Map.Time
            $This.Name   = $Map.Name

            $This.SetTitle("<Not set>")
            $This.SetMode(-1)
            $This.Rating = 0.00
        }
        SetTitle([String]$Title)
        {
            $This.Title  = $Title
        }
        SetMode([String]$Mode)
        {
            $This.Mode    = @(Invoke-Expression $Mode)
            $This.ModeStr = $This.Mode -join ","
        }
        SetRating([String]$Rating)
        {
            If ($Rating -match "\d+\.\d+")
            {
                $This.Rating = $Rating
            }
            If ($Rating -match "\d+\/\d+")
            {
                $This.Rating = Invoke-Expression $Rating
            }
        }
        [String] ToString()
        {
            Return "{0} {1} {2}" -f $This.Date, $This.Time, $This.Name
        }
    }
    
    # // ==================================================================
    # // | Template for a newly created configuration, or an existing one |
    # // ==================================================================

    Class Q3AMapConfig
    {
        [String]    $Name
        [String]    $Path
        [Object] $Content
        [Object]  $Output
        Q3AMapConfig([String]$Name,[String]$Path)
        {
            $This.Name    = $Name
            $This.Path    = $Path
            $This.Content = $Null
            $This.Clear()
        }
        Clear()
        {
            $This.Output  = @( )
        }
        [Object] Q3AMapItem([UInt32]$Index,[Object]$Map)
        {
            Return [Q3AMapItem]::New($Index,$Map)
        }
        [UInt32] GetRandom([UInt32]$Max)
        {
            Return Get-Random -Maximum $Max
        }
        Randomize()
        {
            $Total = $This.Output.Count
            $Out   = @( )
            ForEach ($X in 0..($Total-1))
            {
                Do
                {
                    $Number = $This.GetRandom($Total)
                }
                Until ($Number -notin $Out)
    
                $Out += $Number
            }
    
            ForEach ($X in 0..($Total-1))
            {
                $This.Output[$X].Index = $Out[$X]
            }
    
            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Map)
        {
            $Item         = $This.Q3AMapItem($This.Output.Count,$Map)

            $This.Output += $Item
        }
        Remove([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            $This.Output = $This.Output | ? Index -ne $Index
            $This.Rerank()
        }
        Rerank()
        {
            $X = 0
            ForEach ($Item in $This.Output)
            {
                $Item.Index = $X
                $X ++
            }
        }
        WriteConfig()
        {
            # [Write Config]
            $Total        = $This.Output.Count
            $D            = ([String]$Total).Length

            $This.Content = @("set g_gametype 0;","set fraglimit 10;","set timelimit 0;")

            ForEach ($X in 0..($Total-1))
            {
                $Item      = $This.Output[$X]
                $Label     = "lvl{0}" -f $X
                $Next      = @("lvl{0}" -f ($X + 1);"lvl0")[$X -eq ($Total-1)]

                $Template  = "echo $Label [Name]: {0}, [Rank]: ({1:d$D}/{2}), [Build]: {3} {4}"
                $Say       = $Template -f $Item.Name, ($X+1), $Total, $Item.Date, $Item.Time
                $This.Content += "seta $Label `"$Say;wait 500;map $($Item.Name); kick allbots; addbot hunter 5; set nextmap vstr $Next`""
            }

            $This.Content += "vstr lvl0"

            [System.IO.File]::WriteAllLines($This.Path,$This.Content)
        }
        ReadConfig()
        {
            $This.Content = [System.IO.File]::ReadAllLines($This.Path)
        }
        [String] ToString()
        {
            Return "<Q3A.Map.Config>"
        }
    }

    # // =========================================================================
    # // | Simply meant to validate a given path, and which object is referenced |
    # // =========================================================================

    Class Q3AValidatePath
    {
        [UInt32]   $Status
        [String]     $Type
        [String]     $Name
        [Object] $Fullname
        Q3AValidatePath([String]$Entry)
        {
            $This.Status       = [UInt32]($Entry -match "^\w+\:\\")
            $This.Fullname     = $Entry
            If ($This.Status -eq 1)
            {
                Try
                {
                    If ([System.IO.FileInfo]::new($Entry).Attributes -match "Directory")
                    {
                        $This.Type   = "Directory" 
                    }
                    Else
                    {
                        $This.Type   = "File"
                    }
                    
                    $This.Name       = Split-Path -Leaf $Entry

                    If (!(Test-Path $This.Fullname))
                    {
                        $This.Status = 2
                    }
                }
                Catch
                {
                    
                }
            }
        }
        [String] ToString()
        {
            Return $This.Fullname
        }
    }

    # // ==================================================
    # // | Only meant to categorize Xaml testing criteria |
    # // ==================================================

    Class Q3AControllerFlag
    {
        [UInt32] $Index
        [String] $Name
        [UInt32] $Status
        Q3AControllerFlag([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.SetStatus(0)
        }
        SetStatus([UInt32]$Status)
        {
            $This.Status = $Status
        }
    }
    
    # // ====================================================================
    # // | Provides the option to import map information as an input object |
    # // ====================================================================

    Class Q3AInputObject
    {
        [UInt32]  $Index
        [String]   $Name
        [String]  $Title
        [Int32[]]  $Mode
        [String] $Rating
        Q3AInputObject([UInt32]$Index,[Object]$Entry)
        {
            $This.Index  = $Index
            $This.Name   = $Entry[0]
            $This.Title  = $Entry[1]
            $This.Mode   = $Entry[2]
            $This.Rating = $Entry[3]
        }
        [String] ToString()
        {
            Return "<Q3A.Input.Object>"
        }
    }

    # // ====================================================================================
    # // | Controller of the entire utility and all of the above classes, acts as a factory |
    # // ====================================================================================

    Class Q3AController
    {
        [Object]      $Module
        [Object]        $Xaml
        [Object]    $Property
        [Object]     $Archive
        [Object]       $Level
        [Object]      $Config
        Hidden [Object] $Flag
        Hidden [Object] $List
        Q3AController()
        {
            $This.Initialize()

            $This.List = @( )
        }
        Q3AController([Object[]]$List)
        {
            $This.Initialize()

            $This.List = @( )
            
            ForEach ($Item in $List)
            {
                $This.List += $This.Q3AInputObject($This.List.Count,$Item)
            }
        }
        Initialize()
        {
            $This.Module    = Get-FEModule -Mode 1
            $This.Module.Console.Reset()
            $This.Module.Console.Initialize()
            $This.Xaml      = [XamlWindow][Q3AControllerXaml]::Content
            $This.Property  = @( )
            $This.Flag      = @( )
            $This.Flag     += $This.Q3AControllerFlag($This.Flag.Count,"Game")
            $This.Flag     += $This.Q3AControllerFlag($This.Flag.Count,"ConfigName")
        }
        Update([Int32]$Status,[String]$Message)
        {
            $This.Module.Update($Status,$Message)
            $Last = $This.Module.Console.Status
            If ($This.Module.Mode -ne 0)
            {
                [Console]::WriteLine($Last)
            }

            $This.Xaml.IO.Console.Items.Add($Last)
        }
        Main([String]$Game)
        {
            # [Validate existence of game directory]
            If (![System.IO.Directory]::Exists($Game))
            {
                Throw "Invalid directory"
            }

            $This.Property += $This.Q3AProperty(   "Game","$Game")
            $This.Property += $This.Q3AProperty(   "Base","$Game\baseq3")
            $This.Property += $This.Q3AProperty( "Engine","$Game\quake3.exe")

            # [Validate quake3.exe hash value]
            $Engine         = $This.GetProperty("Engine")
            If ((Get-FileHash $Engine).Hash -ne $This.Q3AHash())
            {
                Throw "Invalid game engine"
            }

            # [Validate/create temporary directory]
            $This.Property += $This.Q3AProperty( "Temp","$Env:Temp\Q3A")

            $Temp           = $This.GetProperty("Temp")

            If (![System.IO.Directory]::Exists($Temp))
            {
                [System.IO.Directory]::CreateDirectory($Temp)
            }

            # [Populate the class with archives and maps]
            $This.Refresh()
        }
        [Object] Q3AProperty([String]$Name,[String]$Value)
        {
            Return [Q3AProperty]::New($Name,$Value)
        }
        [Object] Pk3FileArchive([UInt32]$Index,[Object]$File)
        {
            Return [Pk3FileArchive]::New($Index,$File)
        }
        [Object] Pk3FileBsp([UInt32]$Index,[Object]$Bsp)
        {
            Return [Pk3FileBsp]::New($Index,$Bsp)
        }
        [Object] Q3AMapConfig([String]$Name,[String]$Path)
        {
            Return [Q3AMapConfig]::New($Name,$Path)
        }
        [String] Q3AHash()
        {
            Return "1DDF68B5B5314A39325A9362B1564D417A18B2B111BE7F8728CD808353829CC0"
        }
        [Object] Q3AValidatePath([String]$Entry)
        {
            Return [Q3AValidatePath]::New($Entry)
        }
        [Object] Q3AControllerFlag([UInt32]$Index,[String]$Name)
        {
            Return [Q3AControllerFlag]::New($Index,$Name)
        }
        [Object] Q3AInputObject([UInt32]$Index,[Object]$Entry)
        {
            Return [Q3AInputObject]::New($Index,$Entry)
        }
        [String] IconStatus([UInt32]$Flag)
        {
            Return $This.Module._Control(@("failure.png","success.png","warning.png")[$Flag]).Fullname
        }
        [String] GetProperty([String]$Name)
        {
            Return $This.Property | ? Name -eq $Name | % Value
        }
        Clear()
        {
            $This.Archive = @( )
            $This.Level   = @( )
            $This.Config  = @( )
        }
        Refresh()
        {
            $This.Clear()
            $Base = $This.GetProperty("Base")
            $xList = Get-ChildItem $Base | ? Extension -eq .pk3 | ? Name -notmatch ^pak\d

            $This.Update(0,"Archive [~] ($($xList.Count)) files found")

            ForEach ($File in $xList)
            {
                $This.Update(0,"Archive [~] $($File.Name)")

                $This.Archive += $This.Pk3FileArchive($This.Archive.Count,$File)
            }

            $This.Update(1,"Archive [+] Complete")

            $This.ExtractBsp()
        }
        ExtractBsp()
        {
            $This.Level = @( )

            $Magick     = Get-ChildItem $Env:ProgramFiles | ? Name -match ImageMagick | % { "{0}\magick.exe" -f $_.Fullname }

            $Filter     = $This.Archive.Archive.Entries | ? Fullname -match "(^maps/.+\.bsp$|^levelshots/.+\.(jpg|tga)$)"
            $Bsp        = $Filter | ? Fullname -match ^maps\/.+$      | Sort-Object Name | Select-Object -Unique
            $Image      = $Filter | ? Fullname -match ^levelshots/.+$ | Sort-Object Name | Select-Object -Unique
            $Temp       = $This.GetProperty("Temp")

            $This.Update(0,"Level [~] ($($Bsp.Count)) maps detected")

            ForEach ($Entry in $Bsp)
            {
                $Item   = $This.Pk3FileBsp($This.Level.Count,$Entry)
                $String = "\/{0}\." -f [Regex]::Escape($Item.Name)
                $Shot   = $Image | ? Fullname -imatch $String
                $Target = "{0}\{1}" -f $Temp, $Shot.Name

                $This.Update(0,"Level [~] Name: $($Item.Name)")

                If (![System.IO.File]::Exists($Target))
                {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($Shot,$Target)

                    Switch -Regex ($Target)
                    {
                        \.jpg$
                        {                            
                            $Splat = @{ 
                            
                                FilePath         = $Magick
                                ArgumentList     = "{0} -size 640x480" -f $Target
                                WorkingDirectory = Split-Path $Magick
                            }
                            
                            Start-Process @Splat -Wait -WindowStyle Hidden
                        }
                        \.tga$
                        {
                            $Source = $Target
                            $Target = $Target -Replace "tga","jpg"
                            
                            If (![System.IO.File]::Exists($Target))
                            {
                                $Splat = @{ 
                                
                                    FilePath         = $Magick
                                    ArgumentList     = "{0} -size 640x480 {1}" -f $Source, $Target
                                    WorkingDirectory = Split-Path $Magick
                                }
                                
                                Start-Process @Splat -Wait -WindowStyle Hidden
        
                                If ([System.IO.File]::Exists($Target))
                                {
                                    [System.IO.File]::Delete($Source)
                                }
                            }
                        }
                    }
                }

                If ($Target -match "\.tga")
                {
                    $Target = $Target -Replace "tga","jpg"
                }

                $Item.SetImage($Target)

                $This.Level += $Item
            }

            $This.Update(1,"Level [+] Complete")
        }
        StartProcess()
        {
            If (!$This.Config)
            {
                Throw "Invalid configuration"
            }

            $Splat     = @{

                Filepath         = $This.GetProperty("Engine")
                ArgumentList     = "+exec {0}" -f $This.Config.Name
                WorkingDirectory = $This.GetProperty("Game")
            }
            
            Start-Process @Splat -NoNewWindow
        }
        NewConfig([String]$Name)
        {
            If ($Name -match ".cfg$")
            {
                $Name = $Name -Replace "\.cfg", ""
            }

            $Base  = $This.GetProperty("Base")
            $xPath = "{0}\{1}.cfg" -f $Base, $Name

            $This.Config = $This.Q3AMapConfig($Name,$xPath)
        }
        Selection()
        {
            $xList = $This.Level | ? Profile | Sort-Object Real

            $This.Update(0,"Configuring [~] ($($xList.Count)) map(s)")

            ForEach ($Map in $xList)
            {
                If ($Map.Name -notin $This.Config.Output)
                {
                    $This.Config.Add($Map)

                    $This.Update(1,"Config/Map [+] $($Map.Name)")
                }

                If ($Map.Name -in $This.List.Name)
                {
                    $Item   = $This.Config.Output | ? Name -eq $Map.Name
                    $Object = $This.List | ? Name -eq $Map.Name
                    $Item.SetTitle($Object.Title)
                    $Item.SetMode($Object.Mode)
                    $Item.SetRating($Object.Rating)
                }
            }

            $This.Update(1,"Configured [+] ($($xList.Count)) map(s)")
        }
        Randomize()
        {
            If (!$This.Config)
            {
                Throw "Invalid configuration"
            }

            $This.Config.Randomize()
        }
        WriteConfig()
        {
            If (!$This.Config)
            {
                Throw "Invalid configuration"
            }

            $This.Config.WriteConfig()
        }
        ReadConfig()
        {
            If (!$This.Config)
            {
                Throw "Invalid configuration"
            }

            $This.Config.ReadConfig()
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        FolderBrowse([String]$Name)
        {
            $This.Update(0,"Browsing [~] Folder: [$Name]")

            $Object            = $This.Xaml.Get($Name)
            $Item              = [System.Windows.Forms.FolderBrowserDialog]::New()
            $Item.SelectedPath = [Environment]::GetFolderPath("ProgramFilesX86")
            $Item.ShowDialog()
        
            $Object.Text       = @("<Select a path>",$Item.SelectedPath)[!!$Item.SelectedPath]
        }
        CheckPath()
        {
            $Item         = $This.Xaml.Get("Game")
            $Icon         = $This.Xaml.Get("GameIcon")
            $xFlag        = $This.Flag | ? Name -eq Game

            $xFlag.Status = $This.Q3AValidatePath($Item.Text).Status
    
            $Icon.Source  = $This.IconStatus($xFlag.Status)
        }
        CheckConfig()
        {
            $Item         = $This.Xaml.Get("ConfigName")
            $Icon         = $This.Xaml.Get("ConfigNameIcon")
            $xFlag        = $This.Flag | ? Name -eq ConfigName
            $xText        = $Item.Text -Replace "\.cfg", ""
            $xList         = $This.Level | ? Profile

            If ($xText -eq "")
            {
                $xFlag.Status = 0
                $Icon.Source  = $This.IconStatus(0)
                $This.Xaml.IO.Create.IsEnabled = 0
            }
            Else
            {
                $xPath        = "{0}/{1}.cfg" -f $This.GetProperty("Base"), $xText
                $xFlag.Status = $This.Q3AValidatePath($xPath).Status
                $Icon.Source  = $This.IconStatus($xFlag.Status)
                $This.Xaml.IO.Create.IsEnabled = [UInt32]($xList.Count -gt 0)
            }
        }
        StageXaml()
        {
            $Ctrl = $This

            $Ctrl.Xaml.IO.Browse.Add_Click(
            {
                $Ctrl.FolderBrowse("Game")
            })

            $Ctrl.Xaml.IO.Game.Add_TextChanged(
            {
                $Ctrl.CheckPath()
                $xFlag                      = $Ctrl.Flag | ? Name -eq Game
                $Ctrl.Xaml.IO.Set.IsEnabled = $xFlag.Status
            })

            $Ctrl.Xaml.IO.Game.Text = "${env:ProgramFiles(x86)}\Quake III Arena"

            $Ctrl.Xaml.IO.Set.Add_Click(
            {
                $Ctrl.Main($Ctrl.Xaml.IO.Game.Text)
                $Ctrl.Reset($Ctrl.Xaml.IO.Property,$Ctrl.Property)

                # [Archive]
                $Ctrl.Reset($Ctrl.Xaml.IO.Archive,$Ctrl.Archive)
                $Ctrl.Xaml.IO.ArchiveCount.Text = $Ctrl.Archive.Count

                # [Level]
                $Ctrl.Reset($Ctrl.Xaml.IO.Level,$Ctrl.Level)
                $Ctrl.Xaml.IO.LevelCount.Text   = $Ctrl.Level.Count
            })

            $Ctrl.Xaml.IO.Level.Add_SelectionChanged(
            {
                $Ctrl.Xaml.IO.Image.Source = $Ctrl.Xaml.IO.Level.SelectedItem.Image
                $Ctrl.CheckConfig()
            })

            $Ctrl.Xaml.IO.LevelName.Add_TextChanged(
            {
                $Text   = $Ctrl.Xaml.IO.LevelName.Text
                Start-Sleep -Milliseconds 25

                $Result = $Ctrl.Level | ? Name -match ([Regex]::Escape($Text))
                $Ctrl.Reset($Ctrl.Xaml.IO.Level,$Result)
            })

            $Ctrl.Xaml.IO.ConfigName.Add_TextChanged(
            {
                $Ctrl.CheckConfig()
            })

            $Ctrl.Xaml.IO.Create.Add_Click(
            {
                $Ctrl.NewConfig($Ctrl.Xaml.IO.ConfigName.Text)
                $Ctrl.Selection()
                $Ctrl.Reset($Ctrl.Xaml.IO.Config,$Ctrl.Config.Output)
                $Ctrl.Xaml.IO.Launch.IsEnabled = 1
            })

            $Ctrl.Xaml.IO.Clear.Add_Click(
            {
                $Ctrl.Level | % { $_.Profile = 0 }
                $Ctrl.Reset($Ctrl.Xaml.IO.Level,$Ctrl.Level)
            })

            $Ctrl.Xaml.IO.Config.Add_SelectionChanged(
            {
                $Index                            = $Ctrl.Xaml.IO.Config.SelectedIndex
                If ($Index -gt -1)
                {
                    $Item                             = $Ctrl.Xaml.IO.Config.SelectedItem
                    
                    $Ctrl.Xaml.IO.MapTitle.Text       = $Item.Title
                    $Ctrl.Xaml.IO.MapTitle.IsEnabled  = 1

                    $Ctrl.Xaml.IO.MapMode.Text        = $Item.ModeStr
                    $Ctrl.Xaml.IO.MapMode.IsEnabled   = 1

                    $Ctrl.Xaml.IO.MapRating.Text      = $Item.Rating
                    $Ctrl.Xaml.IO.MapRating.IsEnabled = 1

                    $Ctrl.Xaml.IO.Apply.IsEnabled     = 1
                }
                Else
                {
                    $Ctrl.Xaml.IO.MapTitle.Text       = $Null
                    $Ctrl.Xaml.IO.MapTitle.IsEnabled  = 0

                    $Ctrl.Xaml.IO.MapMode.Text        = $Null
                    $Ctrl.Xaml.IO.MapMode.IsEnabled   = 0

                    $Ctrl.Xaml.IO.MapRating.Text      = $Null
                    $Ctrl.Xaml.IO.MapRating.IsEnabled = 0

                    $Ctrl.Xaml.IO.Apply.IsEnabled     = 0
                }
            })

            $Ctrl.Xaml.IO.Apply.Add_Click(
            {
                $Item        = $Ctrl.Xaml.IO.Config.SelectedItem
                $Item.SetTitle($Ctrl.Xaml.IO.MapTitle.Text)
                $Item.SetMode($Ctrl.Xaml.IO.MapMode.Text)
                $Item.SetRating($Ctrl.Xaml.IO.MapRating.Text)

                $Ctrl.Reset($Ctrl.Xaml.IO.Config,$Ctrl.Config.Output)
            })

            $Ctrl.Xaml.IO.Randomize.Add_Click(
            {
                $Ctrl.Randomize()
                $Ctrl.Reset($Ctrl.Xaml.IO.Config,$Ctrl.Config.Output)
            })

            $Ctrl.Xaml.IO.Export.Add_Click(
            {
                $Ctrl.WriteConfig()
                $Ctrl.Xaml.IO.Content.Text = $Ctrl.Config.Content -join "`n"
            })

            $Ctrl.Xaml.IO.Import.Add_Click(
            {
                $Ctrl.ReadConfig()
                $Ctrl.Xaml.IO.Content.Text = $Ctrl.Config.Content -join "`n"
            })

            $Ctrl.Xaml.IO.Launch.Add_Click(
            {
                $Ctrl.StartProcess()
            })
        }
        [String] ToString()
        {
            Return "<Q3A.Controller>"
        }
    }

    # [Determine whether or not a list was provided as a parameter]
    If ($List)
    {
        $Ctrl = [Q3AController]::New($List)
    }
    Else
    {
        $Ctrl = [Q3AController]::New()
    }

    # [Initialize GUI, or return object]
    Switch ($Mode)
    {
        0 # initializes the GUI
        {
            $Ctrl.StageXaml()
            $Ctrl.Xaml.Invoke()
        }
        1 # 1 returns the object which can still initialize the GUI
        {
            $Ctrl
        }
    }
}
