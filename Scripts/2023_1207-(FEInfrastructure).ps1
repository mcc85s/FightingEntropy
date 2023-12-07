
# [Xaml Classes]
Class XamlProperty
{
    [UInt32] $Index
    [String] $Name
    [Object] $Type
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
    Hidden [Object]        $XAML
    Hidden [Object]         $XML
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

        $This.Xaml               = $Xaml
        $This.Xml                = [XML]$Xaml
        $This.Names              = $This.FindNames()
        $This.Types              = @( )
        $This.Node               = [System.Xml.XmlNodeReader]::New($This.Xml)
        $This.IO                 = [System.Windows.Markup.XamlReader]::Load($This.Node)
        
        ForEach ($X in 0..($This.Names.Count-1))
        {
            $Name                = $This.Names[$X]
            $Object              = $This.IO.FindName($Name)
            $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
            If (!!$Object)
            {
                $This.Types     += $This.XamlProperty($This.Types.Count,$Name,$Object)
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
}

Class FEInfrastructureXaml
{
    Static [String] $Content = @(
    '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
    '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
    '        Title="[FightingEntropy]://Infrastructure Deployment System"',
    '        Width="800"',
    '        Height="600"',
    '        Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Graphics\icon.ico"',
    '        ResizeMode="NoResize"',
    '        HorizontalAlignment="Center"',
    '        WindowStartupLocation="CenterScreen"',
    '        FontFamily="Consolas"',
    '        Topmost="True">',
    '    <Window.Resources>',
    '        <Style x:Key="DropShadow">',
    '            <Setter Property="TextBlock.Effect">',
    '                <Setter.Value>',
    '                    <DropShadowEffect ShadowDepth="1"/>',
    '                </Setter.Value>',
    '            </Setter>',
    '        </Style>',
    '        <Style TargetType="ToolTip">',
    '            <Setter Property="Background"',
    '                    Value="#000000"/>',
    '            <Setter Property="Foreground"',
    '                    Value="#66D066"/>',
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
    '            <Setter Property="EnableRowVirtualization"',
    '                    Value="False"/>',
    '            <Setter Property="EnableColumnVirtualization"',
    '                    Value="False"/>',
    '            <Setter Property="ScrollViewer.CanContentScroll"',
    '                    Value="True"/>',
    '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
    '                    Value="Auto"/>',
    '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
    '                    Value="Auto"/>',
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
    '            <Setter Property="FontSize"',
    '                    Value="10"/>',
    '            <Setter Property="FontWeight"',
    '                    Value="Heavy"/>',
    '        </Style>',
    '        <Style TargetType="TabControl">',
    '            <Setter Property="TabStripPlacement"',
    '                    Value="Top"/>',
    '            <Setter Property="HorizontalContentAlignment"',
    '                    Value="Center"/>',
    '            <Setter Property="Background"',
    '                    Value="LightYellow"/>',
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
    '        <Grid.Resources>',
    '            <Style TargetType="Grid">',
    '                <Setter Property="Background" Value="LightYellow"/>',
    '            </Style>',
    '        </Grid.Resources>',
    '        <TabControl>',
    '            <TabItem Header="Module">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="240"/>',
    '                        <RowDefinition Height="50"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Border Grid.Row="0"',
    '                            Background="Black"',
    '                            Margin="4"/>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.Background>',
    '                            <ImageBrush Stretch="UniformToFill"',
    '                                        ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Graphics\background.jpg"/>',
    '                        </Grid.Background>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="*"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Image Grid.Row="0"',
    '                               Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.8.0\Graphics\banner.png"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="Module">',
    '                        <DataGrid.RowStyle>',
    '                            <Style TargetType="{x:Type DataGridRow}"',
    '                                   BasedOn="{StaticResource xDataGridRow}">',
    '                                <Style.Triggers>',
    '                                    <Trigger Property="IsMouseOver" Value="True">',
    '                                        <Setter Property="ToolTip">',
    '                                            <Setter.Value>',
    '                                                <TextBlock Text="{Binding Description}"',
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
    '                            <DataGridTextColumn Header="Company"',
    '                                                Binding="{Binding Company}"',
    '                                                Width="155"/>',
    '                            <DataGridTextColumn Header="Module Name"',
    '                                                Binding="{Binding Name}"',
    '                                                Width="140"/>',
    '                            <DataGridTextColumn Header="Version"',
    '                                                Binding="{Binding Version}"',
    '                                                Width="75"/>',
    '                            <DataGridTextColumn Header="Date"',
    '                                                Binding="{Binding Date}"',
    '                                                Width="135"/>',
    '                            <DataGridTextColumn Header="Guid"',
    '                                                Binding="{Binding Guid}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <TabControl Grid.Row="3">',
    '                        <TabItem Header="Extension">',
    '                            <DataGrid HeadersVisibility="None"',
    '                                      Name="ModuleExtension">',
    '                                <DataGrid.RowStyle>',
    '                                    <Style TargetType="{x:Type DataGridRow}"',
    '                                           BasedOn="{StaticResource xDataGridRow}">',
    '                                        <Style.Triggers>',
    '                                            <Trigger Property="IsMouseOver" Value="True">',
    '                                                <Setter Property="ToolTip">',
    '                                                    <Setter.Value>',
    '                                                        <TextBlock Text="[FightingEntropy()] Module Property"',
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
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="120"/>',
    '                                    <DataGridTextColumn Header="Value"',
    '                                                        Binding="{Binding Value}"',
    '                                                        Width="*"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </TabItem>',
    '                        <TabItem Header="Root">',
    '                            <DataGrid Name="ModuleRoot">',
    '                                <DataGrid.RowStyle>',
    '                                    <Style TargetType="{x:Type DataGridRow}"',
    '                                           BasedOn="{StaticResource xDataGridRow}">',
    '                                        <Style.Triggers>',
    '                                            <Trigger Property="IsMouseOver" Value="True">',
    '                                                <Setter Property="ToolTip">',
    '                                                    <Setter.Value>',
    '                                                        <TextBlock Text="[FightingEntropy()] Root Property"',
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
    '                                    <DataGridTextColumn Header="Type"',
    '                                                        Binding="{Binding Type}"',
    '                                                        Width="70"/>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="65"/>',
    '                                    <DataGridTextColumn Header="Fullname"',
    '                                                        Binding="{Binding Fullname}"',
    '                                                        Width="*"/>',
    '                                    <DataGridTextColumn Header="Exists"',
    '                                                        Binding="{Binding Exists}"',
    '                                                        Width="45"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </TabItem>',
    '                        <TabItem Header="Manifest">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <DataGrid Grid.Row="0"',
    '                                          Name="ModuleManifest">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="[FightingEntropy()] Module Manifest"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Source"',
    '                                                            Binding="{Binding Source}"',
    '                                                            Width="310"/>',
    '                                        <DataGridTextColumn Header="Resource"',
    '                                                                Binding="{Binding Resource}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="ModuleManifestList">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="{Binding Fullname}"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                            Binding="{Binding Type}"',
    '                                                            Width="60"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Name}"',
    '                                                            Width="175"/>',
    '                                        <DataGridTextColumn Header="Hash"',
    '                                                            Binding="{Binding Hash}"',
    '                                                            Width="*"/>',
    '                                        <DataGridTextColumn Header="Exists"',
    '                                                            Width="45"',
    '                                                            Binding="{Binding Exists}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="System">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
    '                    <TabControl Grid.Row="1">',
    '                        <TabItem Header="Snapshot">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Snapshot]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Provides host system + runtime information&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="SnapshotInformation"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Snapshot Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Binding="{Binding Value}"',
    '                                                            Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Bios">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="130"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Bios]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays system (BIOS/UEFI) information&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="BiosInformation">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Bios Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Manufacturer"',
    '                                                            Width="200"',
    '                                                            Binding="{Binding Manufacturer}"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding SerialNumber}"/>',
    '                                        <DataGridTextColumn Header="Version"',
    '                                                            Width="155"',
    '                                                            Binding="{Binding Version}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Extension]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays additional (BIOS/UEFI) information&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="3"',
    '                                          Name="BiosInformationExtension"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Bios Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Value}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Computer">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="50"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="90"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Computer]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays information about the computer system&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="ComputerSystem">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Computer System Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Manufacturer"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Manufacturer}"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Model}"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Width="200"',
    '                                                            Binding="{Binding Serial}"/>',
    '                                        <DataGridTextColumn Header="Memory"',
    '                                                            Width="100"',
    '                                                            Binding="{Binding Memory}"/>',
    '                                        <DataGridTextColumn Header="Arch."',
    '                                                            Width="50"',
    '                                                            Binding="{Binding Architecture}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Extension]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays additional computer system information&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="3"',
    '                                          Name="ComputerSystemExtension"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Computer System Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Value}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Processor">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="90"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Processor]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays information for each CPU&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="ProcessorOutput">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Processor Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Manufacturer"',
    '                                                            Width="75"',
    '                                                            Binding="{Binding Manufacturer}"/>',
    '                                        <DataGridTextColumn Header="Caption"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Caption}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Extension]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays additional properties for selected CPU&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="3"',
    '                                          Name="ProcessorExtension"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Processor Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="120"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Width= "*"',
    '                                                            Binding="{Binding Value}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Disk">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="80"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="80"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="80"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Disk]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays information for each (system disk/HDD)&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="DiskOutput"',
    '                                          RowHeaderWidth="0">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Disk Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                            Width= "40"',
    '                                                            Binding="{Binding Index}"/>',
    '                                        <DataGridTextColumn Header="Disk"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Disk}"/>',
    '                                        <DataGridTextColumn Header="Model"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Model}"/>',
    '                                        <DataGridTextColumn Header="Serial"',
    '                                                            Width="110"',
    '                                                            Binding="{Binding Serial}"/>',
    '                                        <DataGridTextColumn Header="Partition(s)"',
    '                                                            Width="75"',
    '                                                            Binding="{Binding Partition.Count}"/>',
    '                                        <DataGridTextColumn Header="Volume(s)"',
    '                                                            Width="75"',
    '                                                            Binding="{Binding Volume.Count}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Extension]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays additional properties for selected HDD&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="3"',
    '                                          Name="DiskExtension"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Disk Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Value}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="4">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Partition]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays partition information for selected HDD&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="5"',
    '                                          Name="DiskPartition">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Partition Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                            Width="200"',
    '                                                            Binding="{Binding Type}"/>',
    '                                        <DataGridTextColumn Header="Size"',
    '                                                            Width="85"',
    '                                                            Binding="{Binding Size}"/>',
    '                                        <DataGridTextColumn Header="Boot"',
    '                                                            Width="50"',
    '                                                            Binding="{Binding Boot}"/>',
    '                                        <DataGridTextColumn Header="Primary"',
    '                                                            Width="50"',
    '                                                            Binding="{Binding Primary}"/>',
    '                                        <DataGridTextColumn Header="Disk"',
    '                                                            Width="50"',
    '                                                            Binding="{Binding Disk}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="6">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Volume]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays volume information for selected HDD&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="7"',
    '                                          Name="DiskVolume">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Volume Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="DriveID"',
    '                                                            Width="50"',
    '                                                            Binding="{Binding DriveID}"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Description}"/>',
    '                                        <DataGridTextColumn Header="Filesystem"',
    '                                                            Width="70"',
    '                                                            Binding="{Binding Filesystem}"/>',
    '                                        <DataGridTextColumn Header="Partition"',
    '                                                            Width="200"',
    '                                                            Binding="{Binding Partition}"/>',
    '                                        <DataGridTextColumn Header="Freespace"',
    '                                                            Width= "75"',
    '                                                            Binding="{Binding Freespace}"/>',
    '                                        <DataGridTextColumn Header="Used"',
    '                                                            Width= "75"',
    '                                                            Binding="{Binding Used}"/>',
    '                                        <DataGridTextColumn Header="Size"',
    '                                                            Width= "75"',
    '                                                            Binding="{Binding Size}"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Network">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="135"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Network]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays information for each network interface&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="NetworkOutput">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Network Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                            Width="50"',
    '                                                            Binding="{Binding Index}"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="*"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTemplateColumn Header="State" Width="100">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding State.Index}"',
    '                                                              Style="{StaticResource DGCombo}">',
    '                                                        <ComboBoxItem Content="Disabled"/>',
    '                                                        <ComboBoxItem Content="Enabled"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Extension]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Text="&lt;Displays additional properties for selected network adapter&gt;"',
    '                                             IsReadOnly="True"/>',
    '                                </Grid>',
    '                                <DataGrid Grid.Row="3"',
    '                                          Name="NetworkExtension"',
    '                                          HeadersVisibility="None">',
    '                                    <DataGrid.RowStyle>',
    '                                        <Style TargetType="{x:Type DataGridRow}"',
    '                                               BasedOn="{StaticResource xDataGridRow}">',
    '                                            <Style.Triggers>',
    '                                                <Trigger Property="IsMouseOver" Value="True">',
    '                                                    <Setter Property="ToolTip">',
    '                                                        <Setter.Value>',
    '                                                            <TextBlock Text="Network Information"',
    '                                                                       Style="{StaticResource xTextBlock}"/>',
    '                                                        </Setter.Value>',
    '                                                    </Setter>',
    '                                                    <Setter Property="ToolTipService.ShowDuration"',
    '                                                            Value="360000000"/>',
    '                                                </Trigger>',
    '                                            </Style.Triggers>',
    '                                        </Style>',
    '                                    </DataGrid.RowStyle>',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Width="150"',
    '                                                            Binding="{Binding Name}"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Binding="{Binding Value}"',
    '                                                            Width="*">',
    '                                            <DataGridTextColumn.ElementStyle>',
    '                                                <Style TargetType="TextBlock">',
    '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                                </Style>',
    '                                            </DataGridTextColumn.ElementStyle>',
    '                                            <DataGridTextColumn.EditingElementStyle>',
    '                                                <Style TargetType="TextBox">',
    '                                                    <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                                    <Setter Property="AcceptsReturn" Value="True"/>',
    '                                                </Style>',
    '                                            </DataGridTextColumn.EditingElementStyle>',
    '                                        </DataGridTextColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Config" Height="32" VerticalAlignment="Top">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="0.33*"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="*"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0"',
    '                               Content="[Infrastructure Service Dependencies]:"/>',
    '                        <DataGrid Grid.Row="1"',
    '                                  Name="CfgServices"',
    '                                  IsReadOnly="True">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Display Name"',
    '                                                    Binding="{Binding DisplayName}"',
    '                                                    Width="*"/>',
    '                                <DataGridCheckBoxColumn Header="Installed"',
    '                                                        Binding="{Binding Installed}"',
    '                                                        Width="65"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                    </Grid>',
    '                    <Border Grid.Row="1"',
    '                            Background="Black"',
    '                            BorderThickness="0"',
    '                            Margin="4"/>',
    '                    <TabControl Grid.Row="2">',
    '                        <TabItem Header="Network">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="0.5*"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[FightingEntropy]://Network Adapter Information"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="Network_Adapter"',
    '                                              Margin="5"',
    '                                              ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="50"/>',
    '                                        <DataGridTextColumn Header="IPAddress"',
    '                                                                Binding="{Binding IPAddress}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="SubnetMask"',
    '                                                                Binding="{Binding SubnetMask}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="Gateway"',
    '                                                                Binding="{Binding Gateway}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTemplateColumn Header="DNSServer"',
    '                                                                    Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding DNSServer}"',
    '                                                                  SelectedIndex="0"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="DhcpServer"',
    '                                                                Binding="{Binding DhcpServer}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="MacAddress"',
    '                                                                Binding="{Binding MacAddress}"',
    '                                                                Width="125"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="125"/>',
    '                                        <ColumnDefinition Width="250"/>',
    '                                        <ColumnDefinition Width="125"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[Name]:"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="0"',
    '                                               Content="[Type]:"/>',
    '                                    <Label Grid.Row="2"',
    '                                               Grid.Column="0"',
    '                                               Content="[IP]:"/>',
    '                                    <Label Grid.Row="3"',
    '                                               Grid.Column="0"',
    '                                               Content="[Subnet]:"/>',
    '                                    <Label Grid.Row="4"',
    '                                               Grid.Column="0"',
    '                                               Content="[Gateway]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Grid.ColumnSpan="3"',
    '                                                 Name="Network_Name"/>',
    '                                    <ComboBox Grid.Row="1"',
    '                                                  Grid.Column="1"',
    '                                                  Name="Network_Type">',
    '                                        <ComboBoxItem Content="Static"/>',
    '                                        <ComboBoxItem Content="DHCP"/>',
    '                                    </ComboBox>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Network_IPAddress"/>',
    '                                    <TextBox Grid.Row="3"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Network_SubnetMask"/>',
    '                                    <TextBox Grid.Row="4"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Network_Gateway"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="2"',
    '                                               Content="[Index]:"/>',
    '                                    <Label Grid.Row="2"',
    '                                               Grid.Column="2"',
    '                                               Content="[DNS Server(s)]:"/>',
    '                                    <Label Grid.Row="3"',
    '                                               Grid.Column="2"',
    '                                               Content="[DHCP Server]:"/>',
    '                                    <Label Grid.Row="4"',
    '                                               Grid.Column="2"',
    '                                               Content="[Mac Address]:"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Network_Index"/>',
    '                                    <ComboBox Grid.Row="2"',
    '                                                  Grid.Column="3"',
    '                                                  Name="Network_DNS"/>',
    '                                    <TextBox Grid.Row="3"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Network_DHCP"/>',
    '                                    <TextBox Grid.Row="4"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Network_MacAddress"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Dhcp">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="0.75*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Dhcp ScopeID List]"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="CfgDhcpScopeID">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="ScopeID"',
    '                                                                Binding="{Binding ScopeID}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="SubnetMask"',
    '                                                                Binding="{Binding SubnetMask}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTemplateColumn Header="State"',
    '                                                                    Width="80">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding State}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="Inactive"/>',
    '                                                        <ComboBoxItem Content="Active"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="StartRange"',
    '                                                                Binding="{Binding StartRange}"',
    '                                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="EndRange"',
    '                                                                Binding="{Binding EndRange}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[Dhcp Reservations]"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="CfgDhcpScopeReservations">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="IPAddress"',
    '                                                                Binding="{Binding IPAddress}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="ClientID"',
    '                                                                Binding="{Binding ClientID}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                                Binding="{Binding Description}"',
    '                                                                Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="4"',
    '                                           Content="[Dhcp Scope Options]"/>',
    '                                <DataGrid Grid.Row="5"',
    '                                              Name="CfgDhcpScopeOptions">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="OptionID"',
    '                                                                Binding="{Binding OptionID}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="200"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                                Binding="{Binding Value}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Dns">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="2*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[DNS Server Zone List]"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="CfgDnsZone">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="50"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding ZoneName}"',
    '                                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding ZoneType}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Hosts"',
    '                                                                Binding="{Binding Hosts.Count}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[DNS Server Zone Hosts]"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="CfgDnsZoneHosts">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="HostName"',
    '                                                                Binding="{Binding HostName}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Record"',
    '                                                                Binding="{Binding RecordType}"',
    '                                                                Width="65"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="65"/>',
    '                                        <DataGridTextColumn Header="Data"',
    '                                                                Binding="{Binding RecordData}"',
    '                                                                Width="Auto"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Adds">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="160"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Active Directory Domain Information]"/>',
    '                                <Grid Grid.Row="1">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="125"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[Hostname]:"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="0"',
    '                                               Content="[DC Mode]:"/>',
    '                                    <Label Grid.Row="2"',
    '                                               Grid.Column="0"',
    '                                               Content="[Domain Mode]:"/>',
    '                                    <Label Grid.Row="3"',
    '                                               Grid.Column="0"',
    '                                               Content="[Forest Mode]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Grid.ColumnSpan="3"',
    '                                                 Name="Adds_Hostname"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Adds_DCMode"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Adds_DomainMode"/>',
    '                                    <TextBox Grid.Row="3"',
    '                                                 Grid.Column="1"',
    '                                                 Name="Adds_ForestMode"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="2"',
    '                                               Content="[Root]:"/>',
    '                                    <Label Grid.Row="2"',
    '                                               Grid.Column="2"',
    '                                               Content="[Config]:"/>',
    '                                    <Label Grid.Row="3"',
    '                                               Grid.Column="2"',
    '                                               Content="[Schema]:"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Adds_Root"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Adds_Config"/>',
    '                                    <TextBox Grid.Row="3"',
    '                                                 Grid.Column="3"',
    '                                                 Name="Adds_Schema"/>',
    '                                </Grid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[Active Directory Objects]"/>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="200"/>',
    '                                        <ColumnDefinition Width="200"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="0"',
    '                                                  Name="CfgAddsType"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="1"',
    '                                                  Name="CfgAddsProperty"/>',
    '                                    <TextBox  Grid.Row="0"',
    '                                                  Grid.Column="2"',
    '                                                  Name="CfgAddsFilter"/>',
    '                                    <DataGrid Grid.Row="1"',
    '                                                  Grid.Column="0"',
    '                                                  Grid.ColumnSpan="3"',
    '                                                  Name="CfgAddsObject">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="Name"',
    '                                                                    Binding="{Binding Name}"',
    '                                                                    Width="200"/>',
    '                                            <DataGridTextColumn Header="Class"',
    '                                                                    Binding="{Binding Class}"',
    '                                                                    Width="150"/>',
    '                                            <DataGridTextColumn Header="GUID"',
    '                                                                    Binding="{Binding GUID}"',
    '                                                                    Width="250"/>',
    '                                            <DataGridTextColumn Header="DistinguishedName"',
    '                                                                    Binding="{Binding DistinguishedName}"',
    '                                                                    Width="500"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Hyper-V">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="80"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0" Content="[(Veridian/Hyper-V) Host Settings]"/>',
    '                                <DataGrid Grid.Row="1" Name="CfgHyperV">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Processor"',
    '                                                                Binding="{Binding Processor}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="Memory"',
    '                                                                Binding="{Binding Memory}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="VMPath"',
    '                                                                Binding="{Binding VMPath}"',
    '                                                                Width="500"/>',
    '                                        <DataGridTextColumn Header="VHDPath"',
    '                                                                Binding="{Binding VHDPath}"',
    '                                                                Width="500"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[Virtual Switches] (Disabled)"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="CfgHyperV_Switch">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="40"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="ID"',
    '                                                                Binding="{Binding ID}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                                Binding="{Binding Description}"',
    '                                                                Width="200"/>',
    '                                        <DataGridTemplateColumn Header="Interface"',
    '                                                                    Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Interface.IPV4Address}"',
    '                                                                  SelectedIndex="0"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="4" Content="[Virtual Machines] (Disabled)"/>',
    '                                <DataGrid Grid.Row="5" Name="CfgHyperV_VM">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Index"',
    '                                                                Binding="{Binding Index}"',
    '                                                                Width="40"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="ID"',
    '                                                                Binding="{Binding ID}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Size"',
    '                                                                Binding="{Binding Size}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTemplateColumn Header="SwitchName" Width="125">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Network.SwitchName}"',
    '                                                                  SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Disk"',
    '                                                                Binding="{Binding Disk}"',
    '                                                                Width="500"/>',
    '                                        <DataGridTextColumn Header="Path"',
    '                                                                Binding="{Binding Path}"',
    '                                                                Width="500"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Wds">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0" Content="[Windows Deployment Services]"/>',
    '                                <Grid  Grid.Row="1">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                               Content="[Server]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                                 Name="WDS_Server"/>',
    '                                    <Label Grid.Column="2"',
    '                                               Content="[IPAddress]:"/>',
    '                                    <ComboBox Grid.Column="3"',
    '                                                  Name="WDS_IPAddress"/>',
    '                                </Grid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[Wds Images (Disabled)"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="Wds_Images">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Arch"',
    '                                                                Binding="{Binding Arch}"',
    '                                                                Width="40"/>',
    '                                        <DataGridTextColumn Header="Created"',
    '                                                                Binding="{Binding Created}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Language"',
    '                                                                Binding="{Binding Language}"',
    '                                                                Width="65"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                                Binding="{Binding Description}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTemplateColumn Header="Enabled"',
    '                                                                    Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Enabled}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="FileName"',
    '                                                                Binding="{Binding FileName}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="ID"',
    '                                                                Binding="{Binding ID}"',
    '                                                                Width="250"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Mdt/WinADK/WinPE">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="160"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Microsoft Deployment Toolkit (Top-Shelf)]"/>',
    '                                <Grid Grid.Row="1">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="150"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[Server]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="MDT_Server"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="2"',
    '                                               Content="[IPAddress]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="3"',
    '                                                  Name="MDT_IPAddress"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="0"',
    '                                               Content="[WinADK Version]:"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="1"',
    '                                                 Name="MDT_ADK_Version"/>',
    '                                    <Label Grid.Row="1"',
    '                                               Grid.Column="2"',
    '                                               Content="[WinPE Version]:"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="3"',
    '                                                 Name="MDT_PE_Version"/>',
    '                                    <Label Grid.Row="2"',
    '                                               Grid.Column="0"',
    '                                               Content="[MDT Version]:"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="MDT_Version"/>',
    '                                    <Label Grid.Row="3"',
    '                                               Grid.Column="0"',
    '                                               Content="[Installation Path]:"/>',
    '                                    <TextBox Grid.Row="3"',
    '                                                 Grid.Column="1"',
    '                                                 Grid.ColumnSpan="3"',
    '                                                 Name="MDT_Path"/>',
    '                                </Grid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[Mdt Shares] (Disabled)"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="Mdt_Shares">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Root"',
    '                                                                Binding="{Binding Root}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Share"',
    '                                                                Binding="{Binding Share}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                                Binding="{Binding Description}"',
    '                                                                Width="350"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="IIS">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[IIS Application Pools]"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="IIS_AppPools">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Status"',
    '                                                                Binding="{Binding Status}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="AutoStart"',
    '                                                                Binding="{Binding AutoStart}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="CLRVersion"',
    '                                                                Binding="{Binding CLRVersion}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="PipelineMode"',
    '                                                                Binding="{Binding PipelineMode}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="StartMode"',
    '                                                                Binding="{Binding StartMode}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Label Grid.Row="2"',
    '                                           Content="[IIS Sites]"/>',
    '                                <DataGrid Grid.Row="3"',
    '                                              Name="IIS_Sites">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="ID"',
    '                                                                Binding="{Binding ID}"',
    '                                                                Width="40"/>',
    '                                        <DataGridTextColumn Header="State"',
    '                                                                Binding="{Binding State}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="Path"',
    '                                                                Binding="{Binding Path}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTemplateColumn Header="Bindings"',
    '                                                                    Width="350">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox ItemsSource="{Binding Bindings}"',
    '                                                                  SelectedIndex="0"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center"/>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="BindCount"',
    '                                                                Binding="{Binding BindCount}"',
    '                                                                Width="60"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Domain">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="*"/>',
    '                            <RowDefinition Height="180"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="*"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0" Content="[Aggregate]: Provision (subdomain/site) list"/>',
    '                        <Grid Grid.Row="1">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="40"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Grid Grid.Column="0">',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Button Grid.Row="0"',
    '                                        Content="+"',
    '                                        Name="DcAggregateMoveUp"',
    '                                        Height="30"/>',
    '                                <Button Grid.Row="1"',
    '                                        Content="-"',
    '                                        Name="DcAggregateMoveDown"',
    '                                        Height="30"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Column="1"',
    '                                      Name="DcAggregate"',
    '                                      ScrollViewer.CanContentScroll="True"',
    '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding SiteLink}"',
    '                                                        Width="120"/>',
    '                                    <DataGridTextColumn Header="Location"',
    '                                                        Binding="{Binding Location}"',
    '                                                        Width="200"/>',
    '                                    <DataGridTextColumn Header="Region"',
    '                                                        Binding="{Binding Region}"',
    '                                                        Width="150"/>',
    '                                    <DataGridTextColumn Header="Country"',
    '                                                        Binding="{Binding Country}"',
    '                                                        Width="60"/>',
    '                                    <DataGridTextColumn Header="Postal"',
    '                                                        Binding="{Binding Postal}"',
    '                                                        Width="60"/>',
    '                                    <DataGridTextColumn Header="SiteName"',
    '                                                        Binding="{Binding SiteName}"',
    '                                                        Width="Auto"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                        <Grid Grid.Row="2">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="10"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Grid Grid.Column="0">',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="125"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                       Grid.Column="0"',
    '                                       Content="[Organization]:"/>',
    '                                <TextBox Grid.Row="0"',
    '                                         Grid.Column="1"',
    '                                         Name="DcOrganization"/>',
    '                                <Label Grid.Row="1"',
    '                                       Grid.Column="0"',
    '                                       Content="[CommonName]:"/>',
    '                                <TextBox Grid.Row="1"',
    '                                         Grid.Column="1"',
    '                                         Name="DcCommonName"/>',
    '                                <Button Grid.Row="2"',
    '                                        Grid.Column="0"',
    '                                        Grid.ColumnSpan="2"',
    '                                        Name="DcGetSitename"',
    '                                        Content="Get Sitename"/>',
    '                                <Label Grid.Row="3"',
    '                                       Grid.Column="0"',
    '                                       Content="[Zip Code]:"/>',
    '                                <Grid Grid.Row="3"',
    '                                      Grid.Column="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <TextBox Grid.Column="0"',
    '                                             Name="DcAddSitenameZip"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="DcAddSitename"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="DcRemoveSitename"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                            <Border Grid.Column="1"',
    '                                    Background="Black"',
    '                                    BorderThickness="0"',
    '                                    Margin="4"/>',
    '                            <DataGrid Grid.Column="2"',
    '                                      Name="DcViewer">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="150"/>',
    '                                    <DataGridTextColumn Header="Value"',
    '                                                        Binding="{Binding Value}"',
    '                                                        Width="*"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                        <Border Grid.Row="3"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Label Grid.Row="4"',
    '                               Content="[Topology]: Output/Existence validation"/>',
    '                        <DataGrid Grid.Row="5"',
    '                                  Name="DcTopology"',
    '                                  ScrollViewer.CanContentScroll="True"',
    '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Sitename"',
    '                                                    Binding="{Binding SiteName}"',
    '                                                    Width="250"/>',
    '                                <DataGridTemplateColumn Header="Exists"',
    '                                                        Width="50">',
    '                                    <DataGridTemplateColumn.CellTemplate>',
    '                                        <DataTemplate>',
    '                                            <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                      Margin="0"',
    '                                                      Padding="2"',
    '                                                      Height="18"',
    '                                                      FontSize="10"',
    '                                                      VerticalContentAlignment="Center">',
    '                                                <ComboBoxItem Content="False"/>',
    '                                                <ComboBoxItem Content="True"/>',
    '                                            </ComboBox>',
    '                                        </DataTemplate>',
    '                                    </DataGridTemplateColumn.CellTemplate>',
    '                                </DataGridTemplateColumn>',
    '                                <DataGridTextColumn Header="Distinguished Name"',
    '                                                    Binding="{Binding DistinguishedName}"',
    '                                                    Width="550"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="DcGetTopology"',
    '                                Content="Get"/>',
    '                        <Button Grid.Column="1"',
    '                                Name="DcNewTopology"',
    '                                Content="New"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="DcDeleteTopology"',
    '                                Content="Delete"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Network">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="*"/>',
    '                            <RowDefinition Height="180"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="*"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0"',
    '                               Content ="[Aggregate]: Provision (master address/prefix) &amp; independent subnets"/>',
    '                        <DataGrid Grid.Row="1"',
    '                                  Name="NwAggregate"',
    '                                  ScrollViewer.CanContentScroll="True"',
    '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Network}"',
    '                                                    Width="100"/>',
    '                                <DataGridTextColumn Header="Netmask"',
    '                                                    Binding="{Binding Netmask}"',
    '                                                    Width="100"/>',
    '                                <DataGridTextColumn Header="Host Ct."',
    '                                                    Binding="{Binding HostCount}"',
    '                                                    Width="60"/>',
    '                                <DataGridTextColumn Header="ReverseDNS"',
    '                                                    Binding="{Binding ReverseDNS}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Range"',
    '                                                    Binding="{Binding HostRange}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Start"',
    '                                                    Binding="{Binding Start}"',
    '                                                    Width="125"/>',
    '                                <DataGridTextColumn Header="End"',
    '                                                    Binding="{Binding End}"',
    '                                                    Width="125"/>',
    '                                <DataGridTextColumn Header="Broadcast"',
    '                                                    Binding="{Binding Broadcast}"',
    '                                                    Width="125"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Grid Grid.Row="2">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="10"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Grid Grid.Column="0">',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Scope]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="NwScope"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="NwScopeLoad"',
    '                                            Content="Load"',
    '                                            IsEnabled="False"/>',
    '                                </Grid>',
    '                                <Grid Grid.Row="1">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Subnet]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="NwSubnetName"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="NwAddSubnetName"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="NwRemoveSubnetName"',
    '                                            Content="-"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                            <Border Grid.Column="1"',
    '                                    Background="Black"',
    '                                    BorderThickness="0"',
    '                                    Margin="4"/>',
    '                            <DataGrid Grid.Column="2"',
    '                                      Name="NwViewer">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="150"/>',
    '                                    <DataGridTextColumn Header="Value"',
    '                                                        Binding="{Binding Value}"',
    '                                                        Width="*"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                        <Border Grid.Row="3"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Label Grid.Row="4"',
    '                               Content="[Topology]: (Output/Existence) validation"/>',
    '                        <DataGrid Grid.Row="5"',
    '                                  Name="NwTopology"',
    '                                  ScrollViewer.CanContentScroll="True"',
    '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Network"',
    '                                                    Binding="{Binding Network}"',
    '                                                    Width="200"/>',
    '                                <DataGridTemplateColumn Header="Exists"',
    '                                                        Width="50">',
    '                                    <DataGridTemplateColumn.CellTemplate>',
    '                                        <DataTemplate>',
    '                                            <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                      Margin="0"',
    '                                                      Padding="2"',
    '                                                      Height="18"',
    '                                                      FontSize="10"',
    '                                                      VerticalContentAlignment="Center">',
    '                                                <ComboBoxItem Content="False"/>',
    '                                                <ComboBoxItem Content="True"/>',
    '                                            </ComboBox>',
    '                                        </DataTemplate>',
    '                                    </DataGridTemplateColumn.CellTemplate>',
    '                                </DataGridTemplateColumn>',
    '                                <DataGridTextColumn Header="Distinguished Name"',
    '                                                    Binding="{Binding DistinguishedName}"',
    '                                                    Width="400"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="NwGetSubnetName"',
    '                                Content="Get"/>',
    '                        <Button Grid.Column="1"',
    '                                Name="NwNewSubnetName"',
    '                                Content="New"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="NwDeleteSubnetName"',
    '                                Content="Delete"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Sitemap">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="100"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="140"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="100"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="105"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0"',
    '                               Content="[Aggregate]: Sites to be generated"/>',
    '                        <DataGrid Grid.Row="1"',
    '                                  Name="SmAggregate">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="125"/>',
    '                                <DataGridTextColumn Header="Location"',
    '                                                    Binding="{Binding Location}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Sitename"',
    '                                                    Binding="{Binding SiteName}"',
    '                                                    Width="300"/>',
    '                                <DataGridTextColumn Header="Network"',
    '                                                    Binding="{Binding Network}"',
    '                                                    Width="*"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Grid Grid.Row="2">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="125"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="125"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Label   Grid.Column="0"',
    '                                     Content="[Site Count]:"/>',
    '                            <TextBox Grid.Column="1"',
    '                                     Name="SmSiteCount"/>',
    '                            <Label   Grid.Column="2"',
    '                                     Content="[Network Count]:"/>',
    '                            <TextBox Grid.Column="3"',
    '                                     Name="SmNetworkCount"/>',
    '                            <Button  Grid.Column="4"',
    '                                     Name="SmLoadSitemap"',
    '                                     Content="Load"/>',
    '                        </Grid>',
    '                        <Border Grid.Row="3"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Grid Grid.Row="4">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="10"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Grid Grid.Column="0">',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                       Content="[SiteLink]: Select main ISTG trunk"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="SmSiteLink">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Distinguished Name"',
    '                                                            Binding="{Binding DistinguishedName}"',
    '                                                            Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                            <Border Grid.Column="1"',
    '                                    Background="Black"',
    '                                    BorderThickness="0"',
    '                                    Margin="4"/>',
    '                            <Grid Grid.Column="2">',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                       Content="[Template]: Create these objects for each site"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="SmTemplate">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                            Binding="{Binding Type}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTemplateColumn Header="Create" Width="*">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Create}"',
    '                                                              Margin="0"',
    '                                                              Padding="2"',
    '                                                              Height="18"',
    '                                                              FontSize="10"',
    '                                                              VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </Grid>',
    '                        <Border Grid.Row="5"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Label Grid.Row="6"',
    '                               Content="[Viewer]: View each sites&apos; (properties/attributes)"/>',
    '                        <DataGrid Grid.Row="7"',
    '                                  Name="SmViewer">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Value"',
    '                                                    Binding="{Binding Value}"',
    '                                                    Width="*"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Border Grid.Row="8"',
    '                                Background="Black"',
    '                                BorderThickness="0" Margin="4"/>',
    '                        <Label Grid.Row="9"',
    '                               Content="[Topology]: (Output/Existence) Validation"/>',
    '                        <DataGrid Grid.Row="10"',
    '                                  Name="SmTopology">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="125"/>',
    '                                <DataGridTextColumn Header="Type"',
    '                                                    Binding="{Binding Type}"',
    '                                                    Width="100"/>',
    '                                <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                    <DataGridTemplateColumn.CellTemplate>',
    '                                        <DataTemplate>',
    '                                            <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                      Margin="0"',
    '                                                      Padding="2"',
    '                                                      Height="18"',
    '                                                      FontSize="10"',
    '                                                      VerticalContentAlignment="Center">',
    '                                                <ComboBoxItem Content="False"/>',
    '                                                <ComboBoxItem Content="True"/>',
    '                                            </ComboBox>',
    '                                        </DataTemplate>',
    '                                    </DataGridTemplateColumn.CellTemplate>',
    '                                </DataGridTemplateColumn>',
    '                                <DataGridTextColumn Header="DistinguishedName"',
    '                                                    Binding="{Binding DistinguishedName}"',
    '                                                    Width="*"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="SmGetSitemap"',
    '                                Content="Get"/>',
    '                        <Button Grid.Column="1"',
    '                                Name="SmNewSitemap"',
    '                                Content="New"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="SmDeleteSitemap"',
    '                                Content="Delete"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Adds">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="80"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="60"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Name]:"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="AddsSite"',
    '                                  ItemsSource="{Binding Name}"/>',
    '                        <Label Grid.Column="2"',
    '                               Content="[Site]:"/>',
    '                        <TextBox Grid.Column="3"',
    '                                 Name="AddsSiteName"',
    '                                 IsReadOnly="True"/>',
    '                        <Label Grid.Column="4"',
    '                               Content="[Subnet]:"/>',
    '                        <TextBox Grid.Column="5"',
    '                                 Name="AddsSubnetName"',
    '                                 IsReadOnly="True"/>',
    '                        <Button Grid.Column="6"',
    '                                Name="AddsSiteDefaults"',
    '                                Content="[All] Defaults"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="1"',
    '                            Background="Black"',
    '                            BorderThickness="0"',
    '                            Margin="4"/>',
    '                    <TabControl Grid.Row="2">',
    '                        <TabItem Header="Control">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="2*"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                       Content="[Viewer]"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                          Name="AddsViewer">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Value"',
    '                                                            Binding="{Binding Value}"',
    '                                                            Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Border Grid.Row="2"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <Label Grid.Row="3"',
    '                                       Content="[Children]"/>',
    '                                <DataGrid Grid.Row="4"',
    '                                          Name="AddsChildren">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                            Binding="{Binding Name}"',
    '                                                            Width="150"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                            Binding="{Binding Type}"',
    '                                                            Width="100"/>',
    '                                        <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                              Margin="0"',
    '                                                              Padding="2"',
    '                                                              Height="18"',
    '                                                              FontSize="10"',
    '                                                              VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="DistinguishedName"',
    '                                                            Binding="{Binding DistinguishedName}"',
    '                                                            Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Gateway">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="70"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="2*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Name]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="AddsGwName"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsGwAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="AddsGwDelete"',
    '                                            Content="-"/>',
    '                                    <Label Grid.Column="4"',
    '                                           Content="[List]:"/>',
    '                                    <TextBox Grid.Column="5"',
    '                                             Name="AddsGwFile"/>',
    '                                    <Button Grid.Column="6"',
    '                                            Name="AddsGwBrowse"',
    '                                            Content="Browse"/>',
    '                                    <Button Grid.Column="7"',
    '                                            Name="AddsGwAddList"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Border Grid.Row="1"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <TabControl Grid.Row="2">',
    '                                    <TabItem Header="Aggregate">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Aggregate]: Provision (gateway/router) items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsGwAggregate"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a gateways&apos; properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsGwAggregateViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Output">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Output]: Provisioned (gateway/router) items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsGwOutput"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Organization"',
    '                                                                        Binding="{Binding Organization}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="CommonName"',
    '                                                                        Binding="{Binding CommonName}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Site"',
    '                                                                        Binding="{Binding Site}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Location"',
    '                                                                        Binding="{Binding Location}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Region"',
    '                                                                        Binding="{Binding Region}"',
    '                                                                        Width="80"/>',
    '                                                    <DataGridTextColumn Header="Country"',
    '                                                                        Binding="{Binding Country}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Postal"',
    '                                                                        Binding="{Binding Postal}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Sitelink"',
    '                                                                        Binding="{Binding Sitelink}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Sitename"',
    '                                                                        Binding="{Binding Sitename}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Network"',
    '                                                                        Binding="{Binding Network}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Prefix"',
    '                                                                        Binding="{Binding Prefix}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Netmask"',
    '                                                                        Binding="{Binding Netmask}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Start"',
    '                                                                        Binding="{Binding Start}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="End"',
    '                                                                        Binding="{Binding End}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Range"',
    '                                                                        Binding="{Binding Range}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Broadcast"',
    '                                                                        Binding="{Binding Broadcast}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="ReverseDNS"',
    '                                                                        Binding="{Binding ReverseDNS}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Hostname"',
    '                                                                        Binding="{Binding Hostname}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="DnsName"',
    '                                                                        Binding="{Binding DnsName}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Computer"',
    '                                                                        Binding="{Binding Computer}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Guid"',
    '                                                                        Binding="{Binding Guid}"',
    '                                                                        Width="300"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a gateways&apos; properties/attributes"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsGwOutputViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="AddsGwGet"',
    '                                            Content="Get"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="AddsGwNew"',
    '                                            Content="New"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsGwRemove"',
    '                                            Content="Remove"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Server">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="70"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="2*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Name]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="AddsSrName"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsSrAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="AddsSrDelete"',
    '                                            Content="-"/>',
    '                                    <Label Grid.Column="4"',
    '                                           Content="[List]:"/>',
    '                                    <TextBox Grid.Column="5"',
    '                                             Name="AddsSrFile"/>',
    '                                    <Button Grid.Column="6"',
    '                                            Name="AddsSrBrowse"',
    '                                            Content="Browse"/>',
    '                                    <Button Grid.Column="7"',
    '                                            Name="AddsSrAddList"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Border Grid.Row="1"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <TabControl Grid.Row="2">',
    '                                    <TabItem Header="Aggregate">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Aggregate]: Provision (server/domain controller) items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsSrAggregate"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a servers&apos; properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsSrAggregateViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Output">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Output]: Provisioned (server/domain controller) items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsSrOutput"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Organization"',
    '                                                                        Binding="{Binding Organization}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="CommonName"',
    '                                                                        Binding="{Binding CommonName}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Site"',
    '                                                                        Binding="{Binding Site}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Location"',
    '                                                                        Binding="{Binding Location}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Region"',
    '                                                                        Binding="{Binding Region}"',
    '                                                                        Width="80"/>',
    '                                                    <DataGridTextColumn Header="Country"',
    '                                                                        Binding="{Binding Country}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Postal"',
    '                                                                        Binding="{Binding Postal}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Sitelink"',
    '                                                                        Binding="{Binding Sitelink}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Sitename"',
    '                                                                        Binding="{Binding Sitename}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Network"',
    '                                                                        Binding="{Binding Network}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Prefix"',
    '                                                                        Binding="{Binding Prefix}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Netmask"',
    '                                                                        Binding="{Binding Netmask}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Start"',
    '                                                                        Binding="{Binding Start}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="End"',
    '                                                                        Binding="{Binding End}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Range"',
    '                                                                        Binding="{Binding Range}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Broadcast"',
    '                                                                        Binding="{Binding Broadcast}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="ReverseDNS"',
    '                                                                        Binding="{Binding ReverseDNS}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Hostname"',
    '                                                                        Binding="{Binding Hostname}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="DnsName"',
    '                                                                        Binding="{Binding DnsName}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Computer"',
    '                                                                        Binding="{Binding Computer}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Guid"',
    '                                                                        Binding="{Binding Guid}"',
    '                                                                        Width="300"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a gateways&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4" Name="AddsSrOutputViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="AddsSrGet"',
    '                                            Content="Get"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="AddsSrNew"',
    '                                            Content="New"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsSrRemove"',
    '                                            Content="Remove"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Workstation">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="70"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="2*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label   Grid.Column="0"',
    '                                             Content="[Name]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="AddsWsName"/>',
    '                                    <Button  Grid.Column="2"',
    '                                             Name="AddsWsAdd"',
    '                                             Content="+"/>',
    '                                    <Button  Grid.Column="3"',
    '                                             Name="AddsWsDelete"',
    '                                             Content="-"/>',
    '                                    <Label   Grid.Column="4"',
    '                                             Content="[List]:"/>',
    '                                    <TextBox Grid.Column="5"',
    '                                             Name="AddsWsFile"/>',
    '                                    <Button  Grid.Column="6"',
    '                                             Name="AddsWsBrowse"',
    '                                             Content="Browse"/>',
    '                                    <Button  Grid.Column="7"',
    '                                             Name="AddsWsAddList"',
    '                                             Content="+"/>',
    '                                </Grid>',
    '                                <Border Grid.Row="1"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <TabControl Grid.Row="2">',
    '                                    <TabItem Header="Aggregate">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Aggregate]: Provision workstation items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsWsAggregate"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a workstation&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsWsAggregateViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Output">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Output]: Provisioned workstation items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsWsOutput"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Organization"',
    '                                                                        Binding="{Binding Organization}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="CommonName"',
    '                                                                        Binding="{Binding CommonName}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Site"',
    '                                                                        Binding="{Binding Site}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Location"',
    '                                                                        Binding="{Binding Location}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Region"',
    '                                                                        Binding="{Binding Region}"',
    '                                                                        Width="80"/>',
    '                                                    <DataGridTextColumn Header="Country"',
    '                                                                        Binding="{Binding Country}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Postal"',
    '                                                                        Binding="{Binding Postal}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Sitelink"',
    '                                                                        Binding="{Binding Sitelink}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Sitename"',
    '                                                                        Binding="{Binding Sitename}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Network"',
    '                                                                        Binding="{Binding Network}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Prefix"',
    '                                                                        Binding="{Binding Prefix}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Netmask"',
    '                                                                        Binding="{Binding Netmask}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Start"',
    '                                                                        Binding="{Binding Start}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="End"',
    '                                                                        Binding="{Binding End}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Range"',
    '                                                                        Binding="{Binding Range}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Broadcast"',
    '                                                                        Binding="{Binding Broadcast}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="ReverseDNS"',
    '                                                                        Binding="{Binding ReverseDNS}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Hostname"',
    '                                                                        Binding="{Binding Hostname}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="DnsName"',
    '                                                                        Binding="{Binding DnsName}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="400"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Computer"',
    '                                                                        Binding="{Binding Computer}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Guid"',
    '                                                                        Binding="{Binding Guid}"',
    '                                                                        Width="300"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a workstations&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4" Name="AddsWsOutputViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="AddsWsGet"',
    '                                            Content="Get"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="AddsWsNew"',
    '                                            Content="New"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsWsRemove"',
    '                                            Content="Remove"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="User">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="70"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="2*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Name]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="AddsUserName"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsUserAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="AddsUserDelete"',
    '                                            Content="-"/>',
    '                                    <Label Grid.Column="4"',
    '                                           Content="[List]:"/>',
    '                                    <TextBox Grid.Column="5"',
    '                                             Name="AddsUserFile"/>',
    '                                    <Button Grid.Column="6"',
    '                                            Name="AddsUserBrowse"',
    '                                            Content="Browse"/>',
    '                                    <Button Grid.Column="7"',
    '                                            Name="AddsUserAddList"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Border Grid.Row="1"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <TabControl Grid.Row="2">',
    '                                    <TabItem Header="Aggregate">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Aggregate]: Provision user items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsUserAggregate"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="350"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="350"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a users&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4 " Name="AddsUserAggregateViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Output">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Output]: Provisioned user items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsUserOutput"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Organization"',
    '                                                                        Binding="{Binding Organization}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="CommonName"',
    '                                                                        Binding="{Binding CommonName}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Site"',
    '                                                                        Binding="{Binding Site}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Location"',
    '                                                                        Binding="{Binding Location}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Region"',
    '                                                                        Binding="{Binding Region}"',
    '                                                                        Width="80"/>',
    '                                                    <DataGridTextColumn Header="Country"',
    '                                                                        Binding="{Binding Country}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Postal"',
    '                                                                        Binding="{Binding Postal}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Sitelink"',
    '                                                                        Binding="{Binding Sitelink}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Sitename"',
    '                                                                        Binding="{Binding Sitename}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Network"',
    '                                                                        Binding="{Binding Network}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Prefix"',
    '                                                                        Binding="{Binding Prefix}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Netmask"',
    '                                                                        Binding="{Binding Netmask}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Start"',
    '                                                                        Binding="{Binding Start}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="End"',
    '                                                                        Binding="{Binding End}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Range"',
    '                                                                        Binding="{Binding Range}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Broadcast"',
    '                                                                        Binding="{Binding Broadcast}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="ReverseDNS"',
    '                                                                        Binding="{Binding ReverseDNS}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Account"',
    '                                                                        Binding="{Binding Account}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="SamName"',
    '                                                                        Binding="{Binding SamName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="UserPrincipalName"',
    '                                                                        Binding="{Binding UserPrincipalName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Guid"',
    '                                                                        Binding="{Binding Guid}"',
    '                                                                        Width="300"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border   Grid.Row="2"',
    '                                                      Background="Black"',
    '                                                      BorderThickness="0"',
    '                                                      Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Output]: View a users&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsUserOutputViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="AddsUserGet"',
    '                                            Content="Get"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="AddsUserNew"',
    '                                            Content="New"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsUserRemove"',
    '                                            Content="Remove"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Service">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="10"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Grid Grid.Row="0">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="70"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="2*"/>',
    '                                        <ColumnDefinition Width="80"/>',
    '                                        <ColumnDefinition Width="40"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Column="0"',
    '                                           Content="[Name]:"/>',
    '                                    <TextBox Grid.Column="1"',
    '                                             Name="AddsSvcName"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsSvcAdd"',
    '                                            Content="+"/>',
    '                                    <Button Grid.Column="3"',
    '                                            Name="AddsSvcDelete"',
    '                                            Content="-"/>',
    '                                    <Label Grid.Column="4"',
    '                                           Content="[List]:"/>',
    '                                    <TextBox Grid.Column="5"',
    '                                             Name="AddsSvcFile"/>',
    '                                    <Button Grid.Column="6"',
    '                                            Name="AddsSvcBrowse"',
    '                                            Content="Browse"/>',
    '                                    <Button Grid.Column="7"',
    '                                            Name="AddsSvcAddList"',
    '                                            Content="+"/>',
    '                                </Grid>',
    '                                <Border Grid.Row="1"',
    '                                        Background="Black"',
    '                                        BorderThickness="0"',
    '                                        Margin="4"/>',
    '                                <TabControl Grid.Row="2">',
    '                                    <TabItem Header="Aggregate">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Aggregate]: Provision service items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsSvcAggregate"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="350"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="350"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a service&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4"',
    '                                                      Name="AddsSvcAggregateViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Output">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                                <RowDefinition Height="10"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0" Content="[Output]: Provisioned service items"/>',
    '                                            <DataGrid Grid.Row="1"',
    '                                                      Name="AddsSvcOutput"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Organization"',
    '                                                                        Binding="{Binding Organization}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="CommonName"',
    '                                                                        Binding="{Binding CommonName}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Site"',
    '                                                                        Binding="{Binding Site}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Location"',
    '                                                                        Binding="{Binding Location}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Region"',
    '                                                                        Binding="{Binding Region}"',
    '                                                                        Width="80"/>',
    '                                                    <DataGridTextColumn Header="Country"',
    '                                                                        Binding="{Binding Country}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Postal"',
    '                                                                        Binding="{Binding Postal}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Sitelink"',
    '                                                                        Binding="{Binding Sitelink}"',
    '                                                                        Width="120"/>',
    '                                                    <DataGridTextColumn Header="Sitename"',
    '                                                                        Binding="{Binding Sitename}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Network"',
    '                                                                        Binding="{Binding Network}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Prefix"',
    '                                                                        Binding="{Binding Prefix}"',
    '                                                                        Width="60"/>',
    '                                                    <DataGridTextColumn Header="Netmask"',
    '                                                                        Binding="{Binding Netmask}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Start"',
    '                                                                        Binding="{Binding Start}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="End"',
    '                                                                        Binding="{Binding End}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="Range"',
    '                                                                        Binding="{Binding Range}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Broadcast"',
    '                                                                        Binding="{Binding Broadcast}"',
    '                                                                        Width="125"/>',
    '                                                    <DataGridTextColumn Header="ReverseDNS"',
    '                                                                        Binding="{Binding ReverseDNS}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding Type}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Parent"',
    '                                                                        Binding="{Binding Parent}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="DistinguishedName"',
    '                                                                        Binding="{Binding DistinguishedName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                                        <DataGridTemplateColumn.CellTemplate>',
    '                                                            <DataTemplate>',
    '                                                                <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                          Margin="0"',
    '                                                                          Padding="2"',
    '                                                                          Height="18"',
    '                                                                          FontSize="10"',
    '                                                                          VerticalContentAlignment="Center">',
    '                                                                    <ComboBoxItem Content="False"/>',
    '                                                                    <ComboBoxItem Content="True"/>',
    '                                                                </ComboBox>',
    '                                                            </DataTemplate>',
    '                                                        </DataGridTemplateColumn.CellTemplate>',
    '                                                    </DataGridTemplateColumn>',
    '                                                    <DataGridTextColumn Header="Account"',
    '                                                                        Binding="{Binding Account}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="SamName"',
    '                                                                        Binding="{Binding SamName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="UserPrincipalName"',
    '                                                                        Binding="{Binding UserPrincipalName}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Guid"',
    '                                                                        Binding="{Binding Guid}"',
    '                                                                        Width="300"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                            <Border Grid.Row="2"',
    '                                                    Background="Black"',
    '                                                    BorderThickness="0"',
    '                                                    Margin="4"/>',
    '                                            <Label Grid.Row="3"',
    '                                                   Content="[Viewer]: View a users&apos; (properties/attributes)"/>',
    '                                            <DataGrid Grid.Row="4" Name="AddsSvcOutputViewer">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding Name}"',
    '                                                                        Width="150"/>',
    '                                                    <DataGridTextColumn Header="Value"',
    '                                                                        Binding="{Binding Value}"',
    '                                                                        Width="*"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                            Name="AddsSvcGet"',
    '                                            Content="Get"/>',
    '                                    <Button Grid.Column="1"',
    '                                            Name="AddsSvcNew"',
    '                                            Content="New"/>',
    '                                    <Button Grid.Column="2"',
    '                                            Name="AddsSvcRemove"',
    '                                            Content="Remove"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Virtual">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="220"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="60"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="40"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0"',
    '                               Content="[Controller]: VmHost Server, Service State, Credential"/>',
    '                        <DataGrid Grid.Row="1" Name="VmControl">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Status (Hyper-V Service)"',
    '                                                    Binding="{Binding Status}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Credential"',
    '                                                    Binding="{Binding Username}"',
    '                                                    Width="*"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Grid Grid.Row="2">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Label Grid.Column="0"',
    '                                   Content="[Hostname]:"/>',
    '                            <TextBox Grid.Column="1"',
    '                                     Name="VmHostName"/>',
    '                            <Button Grid.Column="2"',
    '                                    Name="VmHostConnect"',
    '                                    Content="Connect"/>',
    '                            <Button Grid.Column="3"',
    '                                    Name="VmHostChange"',
    '                                    Content="Change"',
    '                                    VerticalAlignment="Center"/>',
    '                        </Grid>',
    '                        <Grid Grid.Row="3">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Label    Grid.Column="0"',
    '                                      Content="[Switch]:"/>',
    '                            <ComboBox Grid.Column="1"',
    '                                      Name="VmControllerSwitch"/>',
    '                            <Label    Grid.Column="2"',
    '                                      Content="[Network]:"/>',
    '                            <TextBox  Grid.Column="3"',
    '                                      Name="VmControllerNetwork"/>',
    '                            <Label    Grid.Column="4"',
    '                                      Content="[Gateway]:"/>',
    '                            <TextBox  Grid.Column="5"',
    '                                      Name="VmControllerGateway"/>',
    '                        </Grid>',
    '                    </Grid>',
    '                    <TabControl Grid.Row="1">',
    '                        <TabItem Header="Control">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Adds Node]: (Output/Existence) Validation"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="VmSelect">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="*"/>',
    '                                        <DataGridTemplateColumn Header="Exists"',
    '                                                                    Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Create VM" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Create}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                                Content="[Import] Adds Host Nodes"',
    '                                                Name="VmLoadAddsNode"/>',
    '                                    <Button Grid.Column="1"',
    '                                                Content="[Delete] Existent Nodes"',
    '                                                Name="VmDeleteNodes"/>',
    '                                    <Button Grid.Column="2"',
    '                                                Content="[Create] Non-existent Nodes"',
    '                                                Name="VmCreateNodes"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Switch">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Provision]: Virtual Switches"/>',
    '                                <DataGrid Grid.Row="1" Name="VmDhcpReservations">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Switch"',
    '                                                                Binding="{Binding SwitchName}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTemplateColumn Header="Sw. Exists" Width="80">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding SwitchExists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTemplateColumn Header="Res. Exists" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Sitename"',
    '                                                                Binding="{Binding IPAddress}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="ScopeID"',
    '                                                                Binding="{Binding ScopeID}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="MacAddress"',
    '                                                                Binding="{Binding MacAddress}"',
    '                                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="*"/>',
    '                                        <DataGridTextColumn Header="Description"',
    '                                                                Binding="{Binding Description}"',
    '                                                                Width="*"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label    Grid.Column="0"',
    '                                                  Content="[Scope ID]:"/>',
    '                                    <ComboBox Grid.Column="1"',
    '                                                  Name="VmDhcpScopeID"/>',
    '                                    <Label    Grid.Column="2"',
    '                                                  Content="[Start]:"/>',
    '                                    <TextBox  Grid.Column="3"',
    '                                                  Name="VmDhcpStart"/>',
    '                                    <Label    Grid.Column="4"',
    '                                                  Content="[End]:"/>',
    '                                    <TextBox  Grid.Column="5"',
    '                                                  Name="VmDhcpEnd"/>',
    '                                </Grid>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button Grid.Column="0"',
    '                                                Name="VmGetSwitch"',
    '                                                Content="[Get] Switch + Reservations"/>',
    '                                    <Button Grid.Column="1"',
    '                                                Name="VmDeleteSwitch"',
    '                                                Content="[Delete] Existent"/>',
    '                                    <Button Grid.Column="2"',
    '                                                Name="VmCreateSwitch"',
    '                                                Content="[Create] Non-existent"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Gateway">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Provision]: (Physical/Virtual) Gateways]"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="VmGateway">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Organization"',
    '                                                                Binding="{Binding Organization}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="CommonName"',
    '                                                                Binding="{Binding CommonName}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Site"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Location"',
    '                                                                Binding="{Binding Location}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Region"',
    '                                                                Binding="{Binding Region}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="Country"',
    '                                                                Binding="{Binding Country}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Postal"',
    '                                                                Binding="{Binding Postal}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Sitelink"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Sitename"',
    '                                                                Binding="{Binding Sitename}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Network"',
    '                                                                Binding="{Binding Network}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Prefix"',
    '                                                                Binding="{Binding Prefix}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Netmask"',
    '                                                                Binding="{Binding Netmask}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Start"',
    '                                                                Binding="{Binding Start}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="End"',
    '                                                                Binding="{Binding End}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Range"',
    '                                                                Binding="{Binding Range}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Broadcast"',
    '                                                                Binding="{Binding Broadcast}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="ReverseDNS"',
    '                                                                Binding="{Binding ReverseDNS}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Hostname"',
    '                                                                Binding="{Binding Hostname}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="DnsName"',
    '                                                                Binding="{Binding DnsName}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Parent"',
    '                                                                Binding="{Binding Parent}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTextColumn Header="DistinguishedName"',
    '                                                                Binding="{Binding DistinguishedName}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Computer"',
    '                                                                Binding="{Binding Computer.Name}"',
    '                                                                Width="200"/>',
    '                                        <DataGridTextColumn Header="Guid"',
    '                                                                Binding="{Binding Guid}"',
    '                                                                Width="300"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label    Grid.Row="0"',
    '                                                  Grid.Column="0"',
    '                                                  Content="[RAM/MB]:"/>',
    '                                    <TextBox  Grid.Row="0"',
    '                                                  Grid.Column="1"',
    '                                                  Name="VmGatewayMemory"/>',
    '                                    <Label    Grid.Row="0"',
    '                                                  Grid.Column="2"',
    '                                                  Content="[HDD/GB]:"/>',
    '                                    <TextBox  Grid.Row="0"',
    '                                                  Grid.Column="3"',
    '                                                  Name="VmGatewayDrive"/>',
    '                                    <Label    Grid.Row="0"',
    '                                                  Grid.Column="4"',
    '                                                  Content="[Generation]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="5"',
    '                                                  Name="VmGatewayGeneration"',
    '                                                  SelectedIndex="0">',
    '                                        <ComboBoxItem Content="1"/>',
    '                                        <ComboBoxItem Content="2"/>',
    '                                    </ComboBox>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="6"',
    '                                               Content="[Core]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="7"',
    '                                                 Name="VmGatewayCore"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="8"',
    '                                               Content="[Type]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="9"',
    '                                                  Name="VmGatewayInstallType">',
    '                                        <ComboBoxItem Content="ISO"/>',
    '                                        <ComboBoxItem Content="Network"/>',
    '                                    </ComboBox>',
    '                                </Grid>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button  Grid.Row="0"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmGatewayPathSelect"',
    '                                                 Content="Path"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmGatewayPath"/>',
    '                                    <Button  Grid.Row="1"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmGatewayImageSelect"',
    '                                                 Content="Image"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmGatewayImage"/>',
    '                                    <Button  Grid.Row="2"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmGatewayScriptSelect"',
    '                                                 Content="Script"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmGatewayScript"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Server">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Provision]: (Physical/Virtual) Servers"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="VmServer">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Organization"',
    '                                                                Binding="{Binding Organization}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="CommonName"',
    '                                                                Binding="{Binding CommonName}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Site"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Location"',
    '                                                                Binding="{Binding Location}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Region"',
    '                                                                Binding="{Binding Region}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="Country"',
    '                                                                Binding="{Binding Country}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Postal"',
    '                                                                Binding="{Binding Postal}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Sitelink"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Sitename"',
    '                                                                Binding="{Binding Sitename}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Network"',
    '                                                                Binding="{Binding Network}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Prefix"',
    '                                                                Binding="{Binding Prefix}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Netmask"',
    '                                                                Binding="{Binding Netmask}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Start"',
    '                                                                Binding="{Binding Start}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="End"',
    '                                                                Binding="{Binding End}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Range"',
    '                                                                Binding="{Binding Range}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Broadcast"',
    '                                                                Binding="{Binding Broadcast}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="ReverseDNS"',
    '                                                                Binding="{Binding ReverseDNS}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Hostname"',
    '                                                                Binding="{Binding Hostname}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="DnsName"',
    '                                                                Binding="{Binding DnsName}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Parent"',
    '                                                                Binding="{Binding Parent}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTextColumn Header="DistinguishedName"',
    '                                                                Binding="{Binding DistinguishedName}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Computer"',
    '                                                                Binding="{Binding Computer.Name}"',
    '                                                                Width="200"/>',
    '                                        <DataGridTextColumn Header="Guid"',
    '                                                                Binding="{Binding Guid}"',
    '                                                                Width="300"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[RAM/MB]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmServerMemory"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="2"',
    '                                               Content="[HDD/GB]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="3"',
    '                                                 Name="VmServerDrive"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="4"',
    '                                               Content="[Generation]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="5"',
    '                                                  Name="VmServerGeneration"',
    '                                                  SelectedIndex="1">',
    '                                        <ComboBoxItem Content="1"/>',
    '                                        <ComboBoxItem Content="2"/>',
    '                                    </ComboBox>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="6"',
    '                                               Content="[Core]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="7"',
    '                                                 Name="VmServerCore"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="8"',
    '                                               Content="[Type]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="9"',
    '                                                  Name="VmServerInstallType">',
    '                                        <ComboBoxItem Content="ISO"/>',
    '                                        <ComboBoxItem Content="Network"/>',
    '                                    </ComboBox>',
    '                                </Grid>',
    '                                <Grid Grid.Row="3">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button  Grid.Row="0"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmServerPathSelect"',
    '                                                 Content="Path"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmServerPath"/>',
    '                                    <Button  Grid.Row="1"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmServerImageSelect"',
    '                                                 Content="Image"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmServerImage"/>',
    '                                    <Button  Grid.Row="2"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmServerScriptSelect"',
    '                                                 Content="Script"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmServerScript"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                        <TabItem Header="Workstation">',
    '                            <Grid>',
    '                                <Grid.RowDefinitions>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="*"/>',
    '                                    <RowDefinition Height="40"/>',
    '                                    <RowDefinition Height="120"/>',
    '                                </Grid.RowDefinitions>',
    '                                <Label Grid.Row="0"',
    '                                           Content="[Provision]: (Physical/Virtual) Workstations"/>',
    '                                <DataGrid Grid.Row="1"',
    '                                              Name="VmWorkstation">',
    '                                    <DataGrid.Columns>',
    '                                        <DataGridTextColumn Header="Organization"',
    '                                                                Binding="{Binding Organization}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="CommonName"',
    '                                                                Binding="{Binding CommonName}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Site"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Location"',
    '                                                                Binding="{Binding Location}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Region"',
    '                                                                Binding="{Binding Region}"',
    '                                                                Width="80"/>',
    '                                        <DataGridTextColumn Header="Country"',
    '                                                                Binding="{Binding Country}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Postal"',
    '                                                                Binding="{Binding Postal}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Sitelink"',
    '                                                                Binding="{Binding Sitelink}"',
    '                                                                Width="120"/>',
    '                                        <DataGridTextColumn Header="Sitename"',
    '                                                                Binding="{Binding Sitename}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Network"',
    '                                                                Binding="{Binding Network}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Prefix"',
    '                                                                Binding="{Binding Prefix}"',
    '                                                                Width="60"/>',
    '                                        <DataGridTextColumn Header="Netmask"',
    '                                                                Binding="{Binding Netmask}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Start"',
    '                                                                Binding="{Binding Start}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="End"',
    '                                                                Binding="{Binding End}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Range"',
    '                                                                Binding="{Binding Range}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Broadcast"',
    '                                                                Binding="{Binding Broadcast}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="ReverseDNS"',
    '                                                                Binding="{Binding ReverseDNS}"',
    '                                                                Width="150"/>',
    '                                        <DataGridTextColumn Header="Type"',
    '                                                                Binding="{Binding Type}"',
    '                                                                Width="125"/>',
    '                                        <DataGridTextColumn Header="Hostname"',
    '                                                                Binding="{Binding Hostname}"',
    '                                                                Width="100"/>',
    '                                        <DataGridTextColumn Header="DnsName"',
    '                                                                Binding="{Binding DnsName}"',
    '                                                                Width="250"/>',
    '                                        <DataGridTextColumn Header="Parent"',
    '                                                                Binding="{Binding Parent}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTextColumn Header="DistinguishedName"',
    '                                                                Binding="{Binding DistinguishedName}"',
    '                                                                Width="400"/>',
    '                                        <DataGridTemplateColumn Header="Exists" Width="60">',
    '                                            <DataGridTemplateColumn.CellTemplate>',
    '                                                <DataTemplate>',
    '                                                    <ComboBox SelectedIndex="{Binding Exists}"',
    '                                                                  Margin="0"',
    '                                                                  Padding="2"',
    '                                                                  Height="18"',
    '                                                                  FontSize="10"',
    '                                                                  VerticalContentAlignment="Center">',
    '                                                        <ComboBoxItem Content="False"/>',
    '                                                        <ComboBoxItem Content="True"/>',
    '                                                    </ComboBox>',
    '                                                </DataTemplate>',
    '                                            </DataGridTemplateColumn.CellTemplate>',
    '                                        </DataGridTemplateColumn>',
    '                                        <DataGridTextColumn Header="Computer"',
    '                                                                Binding="{Binding Computer.Name}"',
    '                                                                Width="200"/>',
    '                                        <DataGridTextColumn Header="Guid"',
    '                                                                Binding="{Binding Guid}"',
    '                                                                Width="300"/>',
    '                                    </DataGrid.Columns>',
    '                                </DataGrid>',
    '                                <Grid Grid.Row="2">',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="60"/>',
    '                                        <ColumnDefinition Width="65"/>',
    '                                        <ColumnDefinition Width="90"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[RAM/MB]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmWorkstationMemory"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="2"',
    '                                               Content="[HDD/GB]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="3"',
    '                                                 Name="VmWorkstationDrive"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="4"',
    '                                               Content="[Generation]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="5"',
    '                                                  Name="VmWorkstationGeneration"',
    '                                                  SelectedIndex="1">',
    '                                        <ComboBoxItem Content="1"/>',
    '                                        <ComboBoxItem Content="2"/>',
    '                                    </ComboBox>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="6"',
    '                                               Content="[Core]:"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="7"',
    '                                                 Name="VmWorkstationCore"/>',
    '                                    <Label Grid.Row="0"',
    '                                               Grid.Column="8"',
    '                                               Content="[Type]:"/>',
    '                                    <ComboBox Grid.Row="0"',
    '                                                  Grid.Column="9"',
    '                                                  Name="VmWorkstationInstallType">',
    '                                        <ComboBoxItem Content="ISO"/>',
    '                                        <ComboBoxItem Content="Network"/>',
    '                                    </ComboBox>',
    '                                </Grid>',
    '                                <Grid Grid.Row="4">',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="120"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Button  Grid.Row="0"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmWorkstationPathSelect"',
    '                                                 Content="Path"/>',
    '                                    <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmWorkstationPath"/>',
    '                                    <Button  Grid.Row="1"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmWorkstationImageSelect"',
    '                                                 Content="Image"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmWorkstationImage"/>',
    '                                    <Button  Grid.Row="2"',
    '                                                 Grid.Column="0"',
    '                                                 Name="VmWorkstationScriptSelect"',
    '                                                 Content="Script"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="VmWorkstationScript"/>',
    '                                </Grid>',
    '                            </Grid>',
    '                        </TabItem>',
    '                    </TabControl>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="VmGetArchitecture"',
    '                                Content="Get"/>',
    '                        <Button Grid.Column="1"',
    '                                Name="VmNewArchitecture"',
    '                                Content="New"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Imaging">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid>',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="120"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="120"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="120"/>',
    '                            <RowDefinition Height="40"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0" Content="[Images (*.iso) files found in source directory]"/>',
    '                        <Grid Grid.Row="2">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="110"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Label Grid.Column="0"',
    '                                   Content="[Image Path]:"/>',
    '                            <TextBox Grid.Column="1"',
    '                                     Name="IsoPath"/>',
    '                            <Button Name="IsoSelect"',
    '                                    Grid.Column="2"',
    '                                    Content="Select"/>',
    '                        </Grid>',
    '                        <DataGrid Grid.Row="1" Name="IsoList">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="*"/>',
    '                                <DataGridTextColumn Header="Path"',
    '                                                    Binding="{Binding Path}"',
    '                                                    Width="2*"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Grid Grid.Row="3">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Button Grid.Column="0"',
    '                                    Name="IsoMount"',
    '                                    Content="Mount"',
    '                                    IsEnabled="False"/>',
    '                            <Button Grid.Column="1"',
    '                                    Name="IsoDismount"',
    '                                    Content="Dismount"',
    '                                    IsEnabled="False"/>',
    '                        </Grid>',
    '                        <Border Grid.Row="4"',
    '                                Background="Black"',
    '                                BorderThickness="0" Margin="4"/>',
    '                        <Label Grid.Row="5"',
    '                               Content="[Image Viewer/Wim file selector]"/>',
    '                        <DataGrid Grid.Row="6"',
    '                                  Name="IsoView">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Index"',
    '                                                    Binding="{Binding Index}"',
    '                                                    Width="40"/>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="*"/>',
    '                                <DataGridTextColumn Header="Size"',
    '                                                    Binding="{Binding Size}"',
    '                                                    Width="100"/>',
    '                                <DataGridTextColumn Header="Architecture"',
    '                                                    Binding="{Binding Architecture}"',
    '                                                    Width="100"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Grid Grid.Row="7">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Button Grid.Column="0"',
    '                                    Name="WimQueue"',
    '                                    Content="Queue"',
    '                                    IsEnabled="False"/>',
    '                            <Button Grid.Column="1"',
    '                                    Name="WimDequeue"',
    '                                    Content="Dequeue"',
    '                                    IsEnabled="False"/>',
    '                        </Grid>',
    '                        <Border Grid.Row="8"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Label Grid.Row="9"',
    '                               Content="[Queued (*.wim) file extraction]"/>',
    '                        <Grid Grid.Row="10">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="40"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Button Grid.Row="0"',
    '                                    Name="WimIsoUp"',
    '                                    Content="+"/>',
    '                            <Button Grid.Row="1"',
    '                                    Name="WimIsoDown"',
    '                                    Content="-"/>',
    '                            <DataGrid Grid.Column="1"',
    '                                      Grid.Row="0"',
    '                                      Grid.RowSpan="2"',
    '                                      Name="WimIso">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"',
    '                                                        Binding="{Binding Name}"',
    '                                                        Width="*"/>',
    '                                    <DataGridTextColumn Header="SelectedIndex"',
    '                                                        Binding="{Binding SelectedIndex}"',
    '                                                        Width="100"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                        <Grid Grid.Row="11">',
    '                            <Grid.ColumnDefinitions>',
    '                                <ColumnDefinition Width="100"/>',
    '                                <ColumnDefinition Width="*"/>',
    '                                <ColumnDefinition Width="100"/>',
    '                            </Grid.ColumnDefinitions>',
    '                            <Button Name="WimSelect"',
    '                                    Grid.Column="0"',
    '                                    Content="Select"/>',
    '                            <TextBox Grid.Column="1"',
    '                                     Name="WimPath"/>',
    '                            <Button Grid.Column="2"',
    '                                    Name="WimExtract"',
    '                                    Content="Extract"/>',
    '                        </Grid>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Updates">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Label Grid.Row="0"',
    '                           Content="[Aggregate]: Update file source directory"/>',
    '                    <DataGrid Grid.Row="1"',
    '                              Name="UpdAggregate">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="KB"',
    '                                                Binding="{Binding KB}"',
    '                                                Width="100"/>',
    '                            <DataGridTextColumn Header="Type"',
    '                                                Binding="{Binding Type}"',
    '                                                Width="100"/>',
    '                            <DataGridTemplateColumn Header="Applicability"',
    '                                                    Width="350">',
    '                                <DataGridTemplateColumn.CellTemplate>',
    '                                    <DataTemplate>',
    '                                        <ComboBox ItemsSource="{Binding Applicability}"',
    '                                                  SelectedIndex="0"',
    '                                                  Margin="0"',
    '                                                  Padding="2"',
    '                                                  Height="18"',
    '                                                  FontSize="10"',
    '                                                  VerticalContentAlignment="Center"/>',
    '                                    </DataTemplate>',
    '                                </DataGridTemplateColumn.CellTemplate>',
    '                            </DataGridTemplateColumn>',
    '                            <DataGridTextColumn Header="Directory" Binding="{Binding Directory}" Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid     Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="60"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                            <ColumnDefinition Width="40"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="UpdSelect"',
    '                                Content="Path"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="UpdPath"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="UpdAddUpdate"',
    '                                Content="+"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="UpdRemoveUpdate"',
    '                                Content="-"/>',
    '                    </Grid>',
    '                    <Border Grid.Row="3"',
    '                            Background="Black"',
    '                            BorderThickness="0"',
    '                            Margin="4"/>',
    '                    <Label Grid.Row="4"',
    '                           Content="[Viewer]: View (properties/attributes) of update files"/>',
    '                    <DataGrid Grid.Row="5"',
    '                              Name="UpdViewer">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding Name}"',
    '                                                Width="175"/>',
    '                            <DataGridTextColumn Header="Value"',
    '                                                Binding="{Binding Value}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Border Grid.Row="6"',
    '                            Background="Black"',
    '                            BorderThickness="0"',
    '                            Margin="4"/>',
    '                    <Label Grid.Row="7"',
    '                           Content="[Update]: Selected (*.wim) file(s) to inject the update(s)"/>',
    '                    <DataGrid Grid.Row="8" Name="UpdWim">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"',
    '                                                Binding="{Binding ImageName}"',
    '                                                Width="250"/>',
    '                            <DataGridTextColumn Header="Type"',
    '                                                Binding="{Binding InstallationType}"',
    '                                                Width="50"/>',
    '                            <DataGridTextColumn Header="Path"',
    '                                                Binding="{Binding SourceImagePath}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="9">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="60"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="UpdWimSelect"',
    '                                Content="Path"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="UpdWimPath"/>',
    '                        <Button Grid.Column="2"',
    '                                Name="UpdInstallUpdate"',
    '                                Content="Install"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="UpdUninstallUpdate"',
    '                                Content="Uninstall"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Share">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.RowDefinitions>',
    '                            <RowDefinition Height="40"/>',
    '                            <RowDefinition Height="140"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="80"/>',
    '                            <RowDefinition Height="10"/>',
    '                            <RowDefinition Height="*"/>',
    '                        </Grid.RowDefinitions>',
    '                        <Label Grid.Row="0"',
    '                               Content="[Aggregate]: (Existent/Provisioned) Deployment Shares &amp; FileSystem, PSDrive, (MDT/PSD), SMB Share, Description"/>',
    '                        <DataGrid Grid.Row="1"',
    '                                  Name="DsAggregate"',
    '                                  SelectionMode="Single"',
    '                                  ScrollViewer.CanContentScroll="True"',
    '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                            <DataGrid.Columns>',
    '                                <DataGridTextColumn Header="Name"',
    '                                                    Binding="{Binding Name}"',
    '                                                    Width="60"/>',
    '                                <DataGridTextColumn Header="Type"',
    '                                                    Binding="{Binding Type}"',
    '                                                    Width="60"/>',
    '                                <DataGridTextColumn Header="Root"',
    '                                                    Binding="{Binding Root}"',
    '                                                    Width="250"/>',
    '                                <DataGridTextColumn Header="Share"',
    '                                                    Binding="{Binding Share}"',
    '                                                    Width="150"/>',
    '                                <DataGridTextColumn Header="Description"',
    '                                                    Binding="{Binding Description}"',
    '                                                    Width="350"/>',
    '                            </DataGrid.Columns>',
    '                        </DataGrid>',
    '                        <Border Grid.Row="2"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <Grid Grid.Row="3">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="80"/>',
    '                                    <ColumnDefinition Width="60"/>',
    '                                    <ColumnDefinition Width="80"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="80"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Name]:"/>',
    '                                <TextBox Grid.Column="1"',
    '                                         Name="DsDriveName"/>',
    '                                <Label Grid.Column="2"',
    '                                       Content="[Type]:"/>',
    '                                <ComboBox Grid.Column="3"',
    '                                          Name="DsType">',
    '                                    <ComboBoxItem Content="MDT"/>',
    '                                    <ComboBoxItem Content="PSD"/>',
    '                                    <ComboBoxItem Content="-"/>',
    '                                </ComboBox>',
    '                                <Button Grid.Column="4"',
    '                                        Name="DsRootSelect"',
    '                                        Content="Root"/>',
    '                                <TextBox Grid.Column="5"',
    '                                         Name="DsRootPath"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="80"/>',
    '                                    <ColumnDefinition Width="140"/>',
    '                                    <ColumnDefinition Width="120"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                    <ColumnDefinition Width="40"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0"',
    '                                       Content="[Share]:"/>',
    '                                <TextBox Grid.Column="1"',
    '                                         Name="DsShareName"/>',
    '                                <Label Grid.Column="2"',
    '                                       Content="[Description]:"/>',
    '                                <TextBox Grid.Column="3"',
    '                                         Name="DsDescription"/>',
    '                                <Button Grid.Column="4"',
    '                                        Name="DsAddShare"',
    '                                        Content="+"/>',
    '                                <Button Grid.Column="5"',
    '                                        Name="DsRemoveShare"',
    '                                        Content="-"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                        <Border Grid.Row="4"',
    '                                Background="Black"',
    '                                BorderThickness="0"',
    '                                Margin="4"/>',
    '                        <TabControl Grid.Row="5"',
    '                                    Name="DsShareConfig">',
    '                            <TabItem Header="Properties">',
    '                                <Grid>',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                           Content="[Properties]: To make changes, select an item from the list, enter the desired value, and click apply"/>',
    '                                    <Grid Grid.Row="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[Value]:"/>',
    '                                        <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="DsPropertyValue"/>',
    '                                        <Button Grid.Row="0"',
    '                                                Grid.Column="2"',
    '                                                Name="DsPropertyApply"',
    '                                                Content="Apply"/>',
    '                                    </Grid>',
    '                                    <DataGrid Grid.Row="2"',
    '                                              Name="DsProperty"',
    '                                              SelectionMode="Single"',
    '                                              ScrollViewer.CanContentScroll="True"',
    '                                              ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                              ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                        <DataGrid.Columns>',
    '                                            <DataGridTextColumn Header="Name"',
    '                                                                Binding="{Binding Name}"',
    '                                                                Width="200"/>',
    '                                            <DataGridTextColumn Header="Value"',
    '                                                                Binding="{Binding Value}"',
    '                                                                Width="*"/>',
    '                                        </DataGrid.Columns>',
    '                                    </DataGrid>',
    '                                </Grid>',
    '                            </TabItem>',
    '                            <TabItem Header="Branding">',
    '                                <Grid>',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="*"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                           Grid.ColumnSpan="4"',
    '                                           Content="[Branding]: Company/Support Information"/>',
    '                                    <Button Grid.Row="1"',
    '                                            Grid.Column="0"',
    '                                            Name="DsBrCollect"',
    '                                            Content="Collect"/>',
    '                                    <Grid Grid.Row="1"',
    '                                          Grid.Column="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Phone]:"/>',
    '                                        <TextBox Grid.Column="1"',
    '                                                 Name="DsBrPhone"/>',
    '                                    </Grid>',
    '                                    <Button Grid.Row="1"',
    '                                            Grid.Column="2"',
    '                                            Content="Apply"',
    '                                            Name="DsBrandApply"/>',
    '                                    <Grid Grid.Row="2"',
    '                                          Grid.Column="1">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Hours]:"/>',
    '                                        <TextBox Grid.Column="1"',
    '                                                 Name="DsBrHours"/>',
    '                                    </Grid>',
    '                                    <Label Grid.Row="2"',
    '                                           Grid.Column="2"',
    '                                           Content="[Org. Name]:"/>',
    '                                    <TextBox Grid.Row="2"',
    '                                             Grid.Column="3"',
    '                                             Name="DsBrOrganization"',
    '                                             ToolTip="Name of the organization"/>',
    '                                    <Grid Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3">',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Column="0"',
    '                                               Content="[Website]:"/>',
    '                                        <TextBox Grid.Column="1"',
    '                                                 Grid.ColumnSpan="3"',
    '                                                 Name="DsBrWebsite"/>',
    '                                    </Grid>',
    '                                    <Button Grid.Row="4"',
    '                                            Grid.Column="0"',
    '                                            Name="DsBrLogoSelect"',
    '                                            Content="Logo"/>',
    '                                    <TextBox Grid.Row="4"',
    '                                             Grid.Column="1"',
    '                                             Grid.ColumnSpan="3"',
    '                                             Name="DsBrLogo"/>',
    '                                    <Button Grid.Row="5"',
    '                                            Grid.Column="0"',
    '                                            Name="DsBrBackgroundSelect"',
    '                                            Content="Background"/>',
    '                                    <TextBox Grid.Row="5"',
    '                                             Grid.Column="1"',
    '                                             Grid.ColumnSpan="3"',
    '                                             Name="DsBrBackground"/>',
    '                                </Grid>',
    '                            </TabItem>',
    '                            <TabItem Header="Local">',
    '                                <Grid>',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="40"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Grid.ColumnDefinitions>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                        <ColumnDefinition Width="100"/>',
    '                                        <ColumnDefinition Width="*"/>',
    '                                    </Grid.ColumnDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                           Grid.ColumnSpan="4"',
    '                                           Content="[Local]: Local Administrator"/>',
    '                                    <Label Grid.Row="1"',
    '                                           Grid.Column="0"',
    '                                           Content="[Username]:"/>',
    '                                    <TextBox Grid.Row="1"',
    '                                             Grid.Column="1"',
    '                                             Name="DsLmUsername"/>',
    '                                    <Button Grid.Row="1"',
    '                                            Grid.Column="2"',
    '                                            Content="Apply"',
    '                                            Name="DsLocalApply"/>',
    '                                    <Label Grid.Row="2"',
    '                                           Grid.Column="0"',
    '                                           Content="[Password]:"/>',
    '                                    <PasswordBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Name="DsLmPassword"',
    '                                                 HorizontalContentAlignment="Left"/>',
    '                                    <Label Grid.Row="2"',
    '                                           Grid.Column="2"',
    '                                           Content="[Confirm]:"/>',
    '                                    <PasswordBox Grid.Row="2"',
    '                                                 Grid.Column="3"',
    '                                                 Name="DsLmConfirm"/>',
    '                                </Grid>',
    '                            </TabItem>',
    '                            <TabItem Header="Domain">',
    '                                <Grid>',
    '                                    <Grid.RowDefinitions>',
    '                                        <RowDefinition Height="40"/>',
    '                                        <RowDefinition Height="80"/>',
    '                                        <RowDefinition Height="10"/>',
    '                                        <RowDefinition Height="120"/>',
    '                                    </Grid.RowDefinitions>',
    '                                    <Label Grid.Row="0"',
    '                                           Content="[Domain/Network]: Credential &amp; (Server/Share) Information"/>',
    '                                    <Grid  Grid.Row="1">',
    '                                        <Grid.RowDefinitions>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                        </Grid.RowDefinitions>',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Button Grid.Row="0"',
    '                                                Grid.Column="2"',
    '                                                Content="Apply"',
    '                                                Name="DsDomainApply"/>',
    '                                        <Button Grid.Row="0"',
    '                                                Grid.Column="3"',
    '                                                Name="DsLogin"',
    '                                                Content="Login [Enters all fields except Machine OU]"/>',
    '                                        <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[Username]:"/>',
    '                                        <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="DsDcUsername"/>',
    '                                        <Label Grid.Row="1"',
    '                                               Grid.Column="0"',
    '                                               Content="[Password]:"/>',
    '                                        <PasswordBox Grid.Row="1"',
    '                                                     Grid.Column="1"',
    '                                                     Name="DsDcPassword"',
    '                                                     HorizontalContentAlignment="Left"/>',
    '                                        <Label Grid.Row="1"',
    '                                               Grid.Column="2"',
    '                                               Content="[Confirm]:"/>',
    '                                        <PasswordBox Grid.Row="1"',
    '                                                     Grid.Column="3"',
    '                                                     Name="DsDcConfirm"',
    '                                                     HorizontalContentAlignment="Left"/>',
    '                                    </Grid>',
    '                                    <Border Grid.Row="2"',
    '                                            Grid.ColumnSpan="4"',
    '                                            Background="Black"',
    '                                            BorderThickness="0"',
    '                                            Margin="4"/>',
    '                                    <Grid Grid.Row="3">',
    '                                        <Grid.RowDefinitions>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="10"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                            <RowDefinition Height="40"/>',
    '                                        </Grid.RowDefinitions>',
    '                                        <Grid.ColumnDefinitions>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="225"/>',
    '                                            <ColumnDefinition Width="100"/>',
    '                                            <ColumnDefinition Width="*"/>',
    '                                        </Grid.ColumnDefinitions>',
    '                                        <Label Grid.Row="0"',
    '                                               Grid.Column="0"',
    '                                               Content="[NetBios]:"/>',
    '                                        <TextBox Grid.Row="0"',
    '                                                 Grid.Column="1"',
    '                                                 Name="DsNetBiosName"',
    '                                                 ToolTip="NetBIOS name of the deployment share (server/domain)"/>',
    '                                        <Label Grid.Row="0"',
    '                                               Grid.Column="2"',
    '                                               Content="[Dns]:"/>',
    '                                        <TextBox Grid.Row="0"',
    '                                                 Grid.Column="3"',
    '                                                 Name="DsDnsName"',
    '                                                 ToolTip="Dns name of the deployment share (server/domain)"/>',
    '                                        <Button Grid.Row="2"',
    '                                                Grid.Column="0"',
    '                                                Name="DsMachineOUSelect"',
    '                                                Content="Machine OU"/>',
    '                                        <TextBox Grid.Row="2"',
    '                                                 Grid.Column="1"',
    '                                                 Grid.ColumnSpan="3"',
    '                                                 Name="DsMachineOu"',
    '                                                 ToolTip="Adds Organizational Unit where the nodes are installed"/>',
    '                                    </Grid>',
    '                                </Grid>',
    '                            </TabItem>',
    '                            <TabItem Header="OS/TS">',
    '                                <TabControl>',
    '                                    <TabItem Header="Current">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Current]: Operating Systems &amp; Task Sequences"/>',
    '                                            <Button Grid.Row="1"',
    '                                                    Content="Remove" Name="DsCurrentWimFileRemove"/>',
    '                                            <DataGrid Grid.Row="2"',
    '                                                      Name="DsCurrentWimFiles"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Rank"',
    '                                                                        Binding="{Binding Rank}"',
    '                                                                        Width="30"/>',
    '                                                    <DataGridTextColumn Header="Label"',
    '                                                                        Binding="{Binding Label}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding ImageName}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Description"',
    '                                                                        Binding="{Binding ImageDescription}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Version"',
    '                                                                        Binding="{Binding Version}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="Arch"',
    '                                                                        Binding="{Binding Architecture}"',
    '                                                                        Width="30"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding InstallationType}"',
    '                                                                        Width="50"/>',
    '                                                    <DataGridTextColumn Header="Path"',
    '                                                                        Binding="{Binding SourceImagePath}"',
    '                                                                        Width="Auto"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Import">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0" Content="[Import]: Operating Systems &amp; Task Sequences"/>',
    '                                            <Grid  Grid.Row="1">',
    '                                                <Grid.ColumnDefinitions>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="*"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                </Grid.ColumnDefinitions>',
    '                                                <Button Grid.Row="0"',
    '                                                        Grid.Column="0"',
    '                                                        Name="DsImportSelect"',
    '                                                        Content="Select"/>',
    '                                                <TextBox Grid.Row="0"',
    '                                                         Grid.Column="1"',
    '                                                         Name="DsImportPath"',
    '                                                         IsEnabled="False"/>',
    '                                                <ComboBox Grid.Row="0"',
    '                                                          Grid.Column="2"',
    '                                                          Name="DsImportMode"',
    '                                                          SelectedIndex="0">',
    '                                                    <ComboBoxItem Content="Copy"/>',
    '                                                    <ComboBoxItem Content="Move"/>',
    '                                                </ComboBox>',
    '                                                <Button Grid.Row="0"',
    '                                                        Grid.Column="3"',
    '                                                        Name="DsImport"',
    '                                                        Content="Import"/>',
    '                                            </Grid>',
    '                                            <DataGrid Grid.Row="2"',
    '                                                      Name="DsImportWimFiles"',
    '                                                      ScrollViewer.CanContentScroll="True"',
    '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
    '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
    '                                                <DataGrid.Columns>',
    '                                                    <DataGridTextColumn Header="Rank"',
    '                                                                        Binding="{Binding Rank}"',
    '                                                                        Width="30"/>',
    '                                                    <DataGridTextColumn Header="Label"',
    '                                                                        Binding="{Binding Label}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="Name"',
    '                                                                        Binding="{Binding ImageName}"',
    '                                                                        Width="250"/>',
    '                                                    <DataGridTextColumn Header="Description"',
    '                                                                        Binding="{Binding ImageDescription}"',
    '                                                                        Width="200"/>',
    '                                                    <DataGridTextColumn Header="Version"',
    '                                                                        Binding="{Binding Version}"',
    '                                                                        Width="100"/>',
    '                                                    <DataGridTextColumn Header="Arch"',
    '                                                                        Binding="{Binding Architecture}"',
    '                                                                        Width="30"/>',
    '                                                    <DataGridTextColumn Header="Type"',
    '                                                                        Binding="{Binding InstallationType}"',
    '                                                                        Width="50"/>',
    '                                                    <DataGridTextColumn Header="Path"',
    '                                                                        Binding="{Binding SourceImagePath}"',
    '                                                                        Width="Auto"/>',
    '                                                </DataGrid.Columns>',
    '                                            </DataGrid>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                            </TabItem>',
    '                            <TabItem Header="Content">',
    '                                <TabControl>',
    '                                    <TabItem Header="Task Sequence"/>',
    '                                    <TabItem Header="Application"/>',
    '                                    <TabItem Header="Driver"/>',
    '                                    <TabItem Header="Package"/>',
    '                                    <TabItem Header="Profile"/>',
    '                                    <TabItem Header="Operating System"/>',
    '                                    <TabItem Header="Linked Shares"/>',
    '                                    <TabItem Header="Media"/>',
    '                                </TabControl>',
    '                            </TabItem>',
    '                            <TabItem Header="Config">',
    '                                <TabControl>',
    '                                    <TabItem Header="Bootstrap">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Bootstrap]: Directly edit (Bootstrap.ini)"/>',
    '                                            <Grid Grid.Row="1">',
    '                                                <Grid.ColumnDefinitions>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="*"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                </Grid.ColumnDefinitions>',
    '                                                <Button Grid.Column="0"',
    '                                                        Name="DsGenerateBootstrap"',
    '                                                        Content="Generate"/>',
    '                                                <TextBox Grid.Column="1"',
    '                                                         Name="DsBootstrapPath" />',
    '                                                <Button Grid.Column="2"',
    '                                                        Name="DsApplyBootstrap"',
    '                                                        Content="Apply"/>',
    '                                            </Grid>',
    '                                            <TextBox Grid.Row="2"',
    '                                                     Background="White"',
    '                                                     Name="DsBootstrap"/>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Custom">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Custom Settings]: Directly edit (CustomSettings.ini)"/>',
    '                                            <Grid Grid.Row="1">',
    '                                                <Grid.ColumnDefinitions>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="*"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                </Grid.ColumnDefinitions>',
    '                                                <Button Grid.Column="0"',
    '                                                        Name="DsGenerateCustomSettings"',
    '                                                        Content="Generate"/>',
    '                                                <TextBox Grid.Column="1"',
    '                                                         Name="DsCustomSettingsPath"/>',
    '                                                <Button Grid.Column="2"',
    '                                                        Name="DsApplyCustomSettings"',
    '                                                        Content="Apply"/>',
    '                                            </Grid>',
    '                                            <TextBox Grid.Row="2"',
    '                                                     Height="200"',
    '                                                     Background="White"',
    '                                                     Name="DsCustomSettings"/>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Post">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Post Configuration]: Directly edit (Install-FightingEntropy.ps1)"/>',
    '                                            <Grid Grid.Row="1">',
    '                                                <Grid.ColumnDefinitions>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="*"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                </Grid.ColumnDefinitions>',
    '                                                <Button Grid.Column="0"',
    '                                                        Name="DsGeneratePostConfig"',
    '                                                        Content="Generate"/>',
    '                                                <TextBox Grid.Column="1"',
    '                                                         Name="DsPostConfigPath"/>',
    '                                                <Button  Grid.Column="2"',
    '                                                         Name="DsApplyPostConfig"',
    '                                                         Content="Apply"/>',
    '                                            </Grid>',
    '                                            <TextBox Grid.Row="2"',
    '                                                     Height="200"',
    '                                                     Background="White"',
    '                                                     Name="DsPostConfig"/>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                    <TabItem Header="Key">',
    '                                        <Grid>',
    '                                            <Grid.RowDefinitions>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="40"/>',
    '                                                <RowDefinition Height="*"/>',
    '                                            </Grid.RowDefinitions>',
    '                                            <Label Grid.Row="0"',
    '                                                   Content="[Deployment Share Key]: Directly edit (DSKey.csv)"/>',
    '                                            <Grid Grid.Row="1">',
    '                                                <Grid.ColumnDefinitions>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                    <ColumnDefinition Width="*"/>',
    '                                                    <ColumnDefinition Width="100"/>',
    '                                                </Grid.ColumnDefinitions>',
    '                                                <Button Grid.Column="0"',
    '                                                        Name="DsGenerateDSKey"',
    '                                                        Content="Generate"/>',
    '                                                <TextBox Grid.Column="1"',
    '                                                         Name="DsDSKeyPath"/>',
    '                                                <Button Grid.Column="2"',
    '                                                        Name="DsApplyDSKey"',
    '                                                        Content="Apply"/>',
    '                                            </Grid>',
    '                                            <TextBox Grid.Row="2"',
    '                                                     Height="200"',
    '                                                     Background="White"',
    '                                                     Name="DsDSKey"/>',
    '                                        </Grid>',
    '                                    </TabItem>',
    '                                </TabControl>',
    '                            </TabItem>',
    '                        </TabControl>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0"',
    '                                Name="DsUpdate"',
    '                                Content="Update"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="DsUpdateMode"',
    '                                  SelectedIndex="0">',
    '                            <ComboBoxItem Content="Full"/>',
    '                            <ComboBoxItem Content="Fast"/>',
    '                            <ComboBoxItem Content="Compress"/>',
    '                        </ComboBox>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '            <TabItem Header="Console">',
    '                <Grid>',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="10"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Search]:"',
    '                               Style="{StaticResource LabelRed}"',
    '                               HorizontalContentAlignment="Left"/>',
    '                        <ComboBox Grid.Column="1"',
    '                                  Name="ConsoleProperty"',
    '                                  SelectedIndex="3">',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Elapsed"/>',
    '                            <ComboBoxItem Content="State"/>',
    '                            <ComboBoxItem Content="Status"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2"',
    '                                 Name="ConsoleFilter"/>',
    '                        <Button  Grid.Column="3"',
    '                                 Name="ConsoleRefresh"',
    '                                 Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="2"',
    '                              Name="ConsoleOutput"',
    '                              SelectionMode="Extended">',
    '                        <DataGrid.RowStyle>',
    '                            <Style TargetType="{x:Type DataGridRow}"',
    '                                   BasedOn="{StaticResource xDataGridRow}">',
    '                                <Style.Triggers>',
    '                                    <Trigger Property="IsMouseOver" Value="True">',
    '                                        <Setter Property="ToolTip">',
    '                                            <Setter.Value>',
    '                                                <TextBlock Text="{Binding String}"',
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
    '                                                Binding="{Binding Index}"',
    '                                                Width="50"/>',
    '                            <DataGridTextColumn Header="Elapsed"',
    '                                                Binding="{Binding Elapsed}"',
    '                                                Width="125"/>',
    '                            <DataGridTextColumn Header="State"',
    '                                                Binding="{Binding State}"',
    '                                                Width="50"/>',
    '                            <DataGridTextColumn Header="Status"',
    '                                                Binding="{Binding Status}"',
    '                                                Width="*"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="120"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="25"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                            <ColumnDefinition Width="90"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0"',
    '                               Content="[Path]:"',
    '                               Style="{StaticResource LabelGray}"',
    '                               HorizontalContentAlignment="Left"/>',
    '                        <TextBox Grid.Column="1"',
    '                                 Name="ConsolePath"/>',
    '                        <Image Grid.Column="2"',
    '                               Name="ConsolePathIcon"/>',
    '                        <Button Grid.Column="3"',
    '                                Name="ConsoleBrowse"',
    '                                Content="Browse"/>',
    '                        <Button Grid.Column="4"',
    '                                Name="ConsoleSave"',
    '                                Content="Save"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </TabItem>',
    '        </TabControl>',
    '    </Grid>',
    '</Window>' -join "`n")
}

# [Generic/Overall]
Class ByteSize
{
    [String]   $Name
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    ByteSize([String]$Name,[UInt64]$Bytes)
    {
        $This.Name   = $Name
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

Class GenericProperty
{
    [UInt32]  $Index
    [String]   $Name
    [Object]  $Value
    GenericProperty([UInt32]$Index,[Object]$Property)
    {
        $This.Index  = $Index
        $This.Name   = $Property.Name
        $This.Value  = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Generic[Property]>"
    }
}

Class GenericProfileProperty
{
    [UInt32] $Index
    [String]  $Name
    [String] $Value
    GenericProfileProperty([UInt32]$Index,[Object]$Property)
    {
        $This.Index    = $Index
        $This.Name     = $Property.Name
        $This.Property = $Property.Value
    }
    GenericProfileProperty([UInt32]$Index,[String]$Name,[Object]$Value)
    {
        $This.Index    = $Index
        $This.Name     = $Name
        $This.Value    = $Value
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.GenericProfile[Property]>"
    }
}

Class GenericProfileItem
{
    [String]     $Name
    [UInt32]  $Enabled
    [String] $Fullname
    [UInt32]   $Exists
    [Object]  $Content
    [Object]   $Output
    GenericProfileItem([String]$Name)
    {
        $This.Name     = $Name
    }
    [Object] GenericProfileProperty([UInt32]$Index,[Object]$Property)
    {
        Return [GenericProfileProperty]::New($Index,$Property)
    }
    [Object] GenericProfileProperty([UInt32]$Index,[String]$Name,[Object]$Value)
    {
        Return [GenericProfileProperty]::New($Index,$Name,$Value)
    }
    TestPath()
    {
        $This.Exists   = [UInt32](Test-Path $This.Fullname)
    }
    SetPath([String]$Fullname)
    {
        $This.Enabled  = 1
        $This.Fullname = $Fullname
        $This.TestPath()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.GenericProfile[{0}]>" -f $This.Name
    }
}

Class GenericProfileController
{
    [String]    $Name
    [Object] $Profile
    [Object]  $Output
    GenericProfileController([String]$Name)
    {
        $This.Name    = $Name
        $This.Profile = $This.GenericProfileItem()
        $This.Clear()
    }
    GenericProfileController([Switch]$Flags,[String]$Name)
    {
        $This.Name    = $Name
        $This.Profile = "<Nullified>"
        $This.Clear()
    }
    Clear()
    {
        $This.Output  = @( )
    }
    Add([Object]$Item)
    {
        $This.Output += $Item
    }
    [Object] GenericProfileItem()
    {
        Return [GenericProfileItem]::New($This.Name)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.GenericProfile[Controller]>"
    }
}

Class GenericList
{
    [String]    $Name
    [Object] $Profile
    [UInt32]   $Count
    [Object]  $Output
    GenericList([String]$Name)
    {
        $This.Name    = $Name
        $This.Profile = $This.GenericProfileController()
        $This.Clear()
    }
    GenericList([Switch]$Flags,[String]$Name)
    {
        $This.Name    = $Name
        $This.Profile = "<Nullified>"
        $This.Clear()
    }
    Clear()
    {
        $This.Count   = 0
        $This.Output  = @( )
    }
    Add([Object]$Item)
    {
        $This.Output += $Item
        $This.Count   = $This.Output.Count
    }
    [Object] GenericProfileController()
    {
        Return [GenericProfileController]::New($This.Name)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Generic[List][{0}]>" -f $This.Name
    }
}

# [System classes]
Class SystemSnapshot
{
    [DateTime]      $Start
    [String] $ComputerName
    [String]         $Name
    [String]  $DisplayName
    [UInt32] $PartOfDomain
    [String]          $Dns
    [String]      $NetBios
    [String]     $Hostname
    [String]     $Username
    [Object]    $Principal
    [Bool]        $IsAdmin
    [String]      $Caption
    [String]         $Guid
    SystemSnapshot([Object]$Module)
    {
        $This.Start         = $Module.Console.Start.Time
        $This.ComputerName  = $Module.OS.Tx("Environment","ComputerName")
        $This.Name          = $This.ComputerName.ToLower()
        $This.DisplayName   = "{0}-{1}" -f $This.Start.ToString("yyyy-MMdd-HHmmss"), $This.ComputerName
        $This.PartOfDomain  = $Module.OS.Tx("ComputerSystem","PartOfDomain")
        $This.Dns           = @($Env:UserDnsDomain,"-")[!$env:UserDnsDomain]
        $This.NetBIOS       = $Module.OS.Tx("Environment","UserDomain").ToLower()
        $This.Hostname      = @($This.Name;"{0}.{1}" -f $This.Name, $This.Dns)[$This.PartOfDomain].ToLower()
        $This.Username      = $Module.OS.Tx("Environment","Username")
        $This.Principal     = $This.GetPrincipal()
        $This.IsAdmin       = $This.GetIsAdmin()
        $This.Caption       = $Module.OS.Tx("OperatingSystem","Caption")
        $This.Guid          = $This.NewGuid()
    }
    [Object] GetPrincipal()
    {
        Return [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() 
    }
    [UInt32] GetIsAdmin()
    {
        Return $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
    }
    [Guid] NewGuid()
    {
        Return [Guid]::NewGuid()
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Snapshot>"
    }
}

Class SystemBiosInformation
{
    [String]            $Name
    [String]    $Manufacturer
    [String]    $SerialNumber
    [String]         $Version
    [String]     $ReleaseDate
    [Bool]     $SmBiosPresent
    [String]   $SmBiosVersion
    [String]     $SmBiosMajor
    [String]     $SmBiosMinor
    [String] $SystemBiosMajor
    [String] $SystemBiosMinor
    SystemBiosInformation([Object]$Module)
    {
        $This.Name            = $Module.OS.Tx("Bios","Name")
        $This.Manufacturer    = $Module.OS.Tx("Bios","Manufacturer")
        $This.SerialNumber    = $Module.OS.Tx("Bios","SerialNumber")
        $This.Version         = $Module.OS.Tx("Bios","Version")
        $This.ReleaseDate     = $Module.OS.Tx("Bios","ReleaseDate")
        $This.SmBiosPresent   = $Module.OS.Tx("Bios","SmBiosPresent")
        $This.SmBiosVersion   = $Module.OS.Tx("Bios","SmBiosBiosVersion")
        $This.SmBiosMajor     = $Module.OS.Tx("Bios","SmBiosMajorVersion")
        $This.SmBiosMinor     = $Module.OS.Tx("Bios","SmBiosMinorVersion")
        $This.SystemBiosMajor = $Module.OS.Tx("Bios","SystemBiosMajorVersion")
        $This.SystemBIosMinor = $Module.OS.Tx("Bios","SystemBiosMinorVersion")
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.BiosInformation>"
    }
}

Class SystemOperatingSystem
{
    [String]  $Caption
    [String]  $Version
    [String]    $Build
    [String]   $Serial
    [UInt32] $Language
    [UInt32]  $Product
    [UInt32]     $Type
    SystemOperatingSystem([Object]$Module)
    {
        $This.Caption       = $Module.OS.Tx("OperatingSystem","Caption")
        $This.Version       = $Module.OS.Tx("OperatingSystem","Version")
        $This.Build         = $Module.OS.Tx("OperatingSystem","BuildNumber")
        $This.Serial        = $Module.OS.Tx("OperatingSystem","SerialNumber")
        $This.Language      = $Module.OS.Tx("OperatingSystem","OSLanguage")
        $This.Product       = $Module.OS.Tx("OperatingSystem","OSProductSuite")
        $This.Type          = $Module.OS.Tx("OperatingSystem","OSType")

    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.OperatingSystem>"
    }
}

Class SystemComputerSystem
{
    [String] $Manufacturer
    [String]        $Model
    [String]      $Product
    [String]       $Serial
    [Object]       $Memory
    [String] $Architecture
    [String]         $UUID
    [String]      $Chassis
    [String]     $BiosUefi
    [Object]     $AssetTag
    SystemComputerSystem([Object]$Module)
    {
        $This.Manufacturer = $Module.OS.Tx("ComputerSystem","Manufacturer")
        $This.Model        = $Module.OS.Tx("ComputerSystem","Model")
        $This.Memory       = $This.ByteSize("Memory",$Module.OS.Tx("ComputerSystem","TotalPhysicalMemory"))
        $This.UUID         = $Module.OS.Tx("Product","UUID") 
        $This.Product      = $Module.OS.Tx("Product","Version")
        $This.Serial       = $Module.OS.Tx("Baseboard","SerialNumber") -Replace "\.",""
        $This.BiosUefi     = $This.GetSecureBootUEFI()

        $This.AssetTag     = $Module.OS.Tx("Enclosure","SMBIOSAssetTag").Trim()
        $This.Chassis      = Switch ([UInt32]$Module.OS.Tx("Enclosure","ChassisTypes")[0])
        {
            {$_ -in 8..12+14,18,21} {"Laptop"}
            {$_ -in 3..7+15,16}     {"Desktop"}
            {$_ -in 23}             {"Server"}
            {$_ -in 34..36}         {"Small Form Factor"}
            {$_ -in 30..32+13}      {"Tablet"}
        }

        $This.Architecture = @{x86="x86";AMD64="x64"}[$Module.OS.Tx("Environment","Processor_Architecture")]
    }
    [String] GetSecureBootUEFI()
    {
        Try
        {
            Get-SecureBootUEFI -Name SetupMode -EA 0
            Return "UEFI"
        }
        Catch
        {
            Return "BIOS"
        }
    }
    [Object] ByteSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.ComputerSystem>"
    }
}

Class SystemProcessorItem
{
    [UInt32]            $Index
    Hidden [Object] $Processor
    [String]     $Manufacturer
    [String]             $Name
    [String]          $Caption
    [UInt32]            $Cores
    [UInt32]             $Used
    [UInt32]          $Logical
    [UInt32]          $Threads
    [String]      $ProcessorId
    [String]         $DeviceId
    [UInt32]            $Speed
    [String]           $Status
    SystemProcessorItem([UInt32]$Index,[Object]$Processor)
    {
        $This.Index        = $Index
        $This.Processor    = $Processor
        $This.Manufacturer = Switch -Regex ($Processor.Manufacturer) 
        {
        Intel { "Intel" } Amd { "AMD" } Default { $Processor.Manufacturer }
        }
        $This.Name         = $Processor.Name -Replace "\s+"," "
        $This.Caption      = $Processor.Caption
        $This.Cores        = $Processor.NumberOfCores
        $This.Used         = $Processor.NumberOfEnabledCore
        $This.Logical      = $Processor.NumberOfLogicalProcessors 
        $This.Threads      = $Processor.ThreadCount
        $This.ProcessorID  = $Processor.ProcessorId
        $This.DeviceID     = $Processor.DeviceID
        $This.Speed        = $Processor.MaxClockSpeed
    }
    SetStatus()
    {
        $This.Status       = "[Processor]: ({0}) {1}" -f $This.Index, $This.Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class SystemProcessorController : GenericList
{
    SystemProcessorController([String]$Name) : Base($Name)
    {

    }
    [Object[]] GetObject()
    {
        Return Get-CimInstance Win32_Processor
    }
    [Object] SystemProcessorItem([UInt32]$Index,[Object]$Processor)
    {
        Return [SystemProcessorItem]::New($Index,$Processor)
    }
    [Object] New([Object]$Processor)
    {
        $Item = $This.SystemProcessorItem($This.Output.Count,$Processor)

        $Item.SetStatus()

        Return $Item
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Processor in $This.GetObject())
        {
            $Item = $This.New($Processor)

            $This.Add($Item)
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Processor.Controller>"
    }
}

Class SystemPartitionItem
{
    [UInt32]            $Index
    Hidden [Object] $Partition
    Hidden [String]     $Label
    [String]             $Type
    [String]             $Name
    [Object]             $Size
    [UInt32]             $Boot
    [UInt32]          $Primary
    [UInt32]             $Disk
    [UInt32]        $PartIndex
    SystemPartitionItem([UInt32]$Index,[Object]$Partition)
    {
        $This.Index      = $Index
        $This.Partition  = $Partition
        $This.Type       = $Partition.Type
        $This.Name       = $Partition.Name
        $This.Size       = $This.GetSize($Partition.Size)
        $This.Boot       = $Partition.BootPartition
        $This.Primary    = $Partition.PrimaryPartition
        $This.Disk       = $Partition.DiskIndex
        $This.PartIndex  = $Partition.Index
    }
    [Object] GetSize([UInt64]$Bytes)
    {
        Return [ByteSize]::New("Partition",$Bytes)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Partition[Item]>"
    }
}

Class SystemPartitionList : GenericList
{
    SystemPartitionList([Switch]$Flags,[String]$Name) : base($Name)
    {
        
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Partition[List]>"
    }
}

Class SystemVolumeItem
{
    [UInt32]            $Index
    Hidden [Object]     $Drive
    Hidden [Object] $Partition
    Hidden [String]     $Label
    [UInt32]             $Rank
    [String]          $DriveID
    [String]      $Description
    [String]       $Filesystem
    [String]       $VolumeName
    [String]     $VolumeSerial
    [Object]             $Size
    [Object]        $Freespace
    [Object]             $Used
    SystemVolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
    {
        $This.Index             = $Index
        $This.Drive             = $Drive
        $This.Partition         = $Partition
        $This.DriveID           = $Drive.Name
        $This.Description       = $Drive.Description
        $This.Filesystem        = $Drive.Filesystem
        $This.VolumeName        = $Drive.VolumeName
        $This.VolumeSerial      = $Drive.VolumeSerialNumber
        $This.Size              = $This.GetSize("Total",$Drive.Size)
        $This.Freespace         = $This.GetSize("Free",$Drive.Freespace)
        $This.Used              = $This.GetSize("Used",($This.Size.Bytes - $This.Freespace.Bytes))
    }
    [Object] GetSize([String]$Name,[UInt64]$Bytes)
    {
        Return [ByteSize]::New($Name,$Bytes)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Volume[Item]>"
    }
}

Class SystemVolumeList : GenericList
{
    SystemVolumeList([Switch]$Flags,[String]$Name) : base($Name)
    {
        
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Volume[List]>"
    }
}

Class SystemDiskItem
{
    [UInt32]             $Index
    Hidden [Object]  $DiskDrive
    [String]              $Disk
    [String]             $Model
    [String]            $Serial
    [String]    $PartitionStyle
    [String]  $ProvisioningType
    [String] $OperationalStatus
    [String]      $HealthStatus
    [String]           $BusType
    [String]          $UniqueId
    [String]          $Location
    [Object]         $Partition
    [Object]            $Volume
    Hidden [String]     $Status
    SystemDiskItem([Object]$Disk)
    {
        $This.Index             = $Disk.Index
        $This.DiskDrive         = $Disk
        $This.Disk              = $Disk.DeviceId
        $This.Partition         = $This.New("Partition")
        $This.Volume            = $This.New("Volume")
    }
    MsftDisk([Object]$MsftDisk)
    {
        $This.Model             = $MsftDisk.Model
        $This.Serial            = $MsftDisk.SerialNumber -Replace "^\s+",""
        $This.PartitionStyle    = $MsftDisk.PartitionStyle
        $This.ProvisioningType  = $MsftDisk.ProvisioningType
        $This.OperationalStatus = $MsftDisk.OperationalStatus
        $This.HealthStatus      = $MsftDisk.HealthStatus
        $This.BusType           = $MsftDisk.BusType
        $This.UniqueId          = $MsftDisk.UniqueId
        $This.Location          = $MsftDisk.Location
    }
    [String] GetSize()
    {
        $Size = 0
        ForEach ($Partition in $This.Partition)
        {
            $Size = $Size + $Partition.Size.Bytes
        }

        Return "{0:n2} GB" -f ($Size/1GB)
    }
    SetStatus()
    {
        $This.Status            = "[Disk]: ({0}) {1} {2}" -f $This.Index, $This.Model, $This.GetSize()
    }
    [Object] New([String]$Name)
    {
        $Item = Switch ($Name)
        {
            Partition { [SystemPartitionList]::New($False,"Partition") }
            Volume    {    [SystemVolumeList]::New($False,"Volume")    }
        }

        Return $Item
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Disk[Item]>"
    }
}

Class SystemDiskController : GenericList
{
    SystemDiskController([String]$Name) : Base($Name)
    {

    }
    Refresh()
    {
        $DiskDrive         = $This.Get("DiskDrive")
        $MsftDisk          = $This.Get("MsftDisk")
        $DiskPartition     = $This.Get("DiskPartition")
        $LogicalDisk       = $This.Get("LogicalDisk")
        $LogicalDiskToPart = $This.Get("LogicalDiskToPart")

        ForEach ($Drive in $DiskDrive | ? MediaType -match Fixed)
        {
            # [Disk Template]
            $Disk     = $This.SystemDiskItem($Drive)

            # [MsftDisk]
            $Msft     = $MsftDisk | ? Number -eq $Disk.Index
            If ($Msft)
            {
                $Disk.MsftDisk($Msft)
            }

            # [Partitions]
            ForEach ($Partition in $DiskPartition | ? DiskIndex -eq $Disk.Index)
            {
                $Disk.Partition.Add($This.SystemPartitionItem($Disk.Partition.Count,$Partition))
            }

            # [Volumes]
            ForEach ($Logical in $LogicalDiskToPart | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name })
            {
                $Drive      = $LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                $Partition  = $DiskPartition | ?     Name -eq $Logical.Antecedent.DeviceID
                If ($Drive -and $Partition)
                {
                    $Disk.Volume.Add($This.SystemVolumeItem($Disk.Volume.Count,$Drive,$Partition))
                }
            }

            $This.Output += $Disk
        }
    }
    [Object[]] Get([String]$Name)
    {
        $Item = Switch ($Name)
        {
            DiskDrive         { Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed          }
            MsftDisk          { Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage }
            DiskPartition     { Get-CimInstance Win32_DiskPartition                                 }
            LogicalDisk       { Get-CimInstance Win32_LogicalDisk                                   }
            LogicalDiskToPart { Get-CimInstance Win32_LogicalDiskToPartition                        }
        }

        Return $Item
    }
    [Object] New([Object]$Disk)
    {
        $Item = $This.DiskItem($Disk)

        Return $Item
    }
    [Object] SystemDiskItem([Object]$Disk)
    {
        Return [SystemDiskItem]::New($Disk)
    }
    [Object] SystemPartitionItem([UInt32]$Index,[Object]$Partition)
    {
        Return [SystemPartitionItem]::New($Index,$Partition)
    }
    [Object] SystemVolumeItem([UInt32]$Index,[Object]$Drive,[Object]$Partition)
    {
        Return [SystemVolumeItem]::New($Index,$Drive,$Partition)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Disk.Controller>"
    }
}

Enum SystemNetworkStateType
{
    Disconnected
    Connected
}

Class SystemNetworkStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]       $Label
    [String] $Description
    SystemNetworkStateItem([String]$Name)
    {
        $This.Index = [UInt32][SystemNetworkStateType]::$Name
        $This.Name  = [SystemNetworkStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class SystemNetworkStateList
{
    [Object] $Output
    SystemNetworkStateList()
    {
        $This.Refresh()
    }
    [Object] SystemNetworkStateItem([String]$Name)
    {
        Return [SystemNetworkStateItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([SystemNetworkStateType]))
        {
            $Item             = $This.SystemNetworkStateItem($Name)
            $Item.Label       = @("[ ]","[+]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                Disconnected { "Adapter is not connected" }
                Connected    { "Adapter is connected"     }
            }
            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.NetworkState[List]>"
    }
}

Class SystemNetworkItem
{
    [UInt32]            $Index
    Hidden [Object] $Interface
    [String]             $Name
    [Object]            $State
    [String]        $IPAddress
    [String]       $SubnetMask
    [String]          $Gateway
    [String]        $DnsServer
    [String]       $DhcpServer
    [String]       $MacAddress
    [String]           $Status
    SystemNetworkItem([UInt32]$Index,[Object]$Interface)
    {
        $This.Index               = $Index
        $This.Name                = $Interface.Description
        Switch ([UInt32]$Interface.IPEnabled)
        {
            0
            {
                $This.IPAddress   = "-"
                $This.SubnetMask  = "-"
                $This.Gateway     = "-"
                $This.DnsServer   = "-"
                $This.DhcpServer  = "-"
            }
            1
            {
                $This.IPAddress   = $This.Ip($Interface.IPAddress)
                $This.SubnetMask  = $This.Ip($Interface.IPSubnet)
                If ($Interface.DefaultIPGateway)
                {
                    $This.Gateway = $This.Ip($Interface.DefaultIPGateway)
                }

                $This.DnsServer   = ($Interface.DnsServerSearchOrder | % { $This.Ip($_) }) -join ", "
                $This.DhcpServer  = $This.Ip($Interface.DhcpServer)
            }     
        }

        $This.MacAddress          = ("-",$Interface.MacAddress)[!!$Interface.MacAddress]
    }
    SetState([Object]$State)
    {
        $This.State               = $State 
    }
    SetStatus()
    {
        $This.Status              = "[Network]: {0} {1}" -f $This.State.Label, $This.Name
    }
    [String] Ip([Object]$Property)
    {
        Return $Property | ? {$_ -match "(\d+\.){3}\d+"}
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Network[Item]>"
    }
}

Class SystemNetworkController : GenericList
{
    Hidden [Object] $State
    SystemNetworkController([String]$Name) : Base($Name)
    {
        $This.State = $This.SystemNetworkStateList()
    }
    [Object[]] GetObject()
    {
        Return Get-CimInstance Win32_NetworkAdapterConfiguration
    }
    [Object] SystemNetworkStateList()
    {
        Return [SystemNetworkStateList]::New()
    }
    [Object] SystemNetworkItem([UInt32]$Index,[Object]$Network)
    {
        Return [SystemNetworkItem]::New($Index,$Network)
    }
    [Object] New([Object]$Network)
    {
        $Item       = $This.SystemNetworkItem($This.Output.Count,$Network)
        $xState     = $This.State.Output | ? Index -eq ([UInt32]$Network.IPEnabled)
        $Item.SetState($xState)
        $Item.SetStatus()

        Return $Item
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Network in $This.GetObject())
        {
            $Item = $This.New($Network)

            $This.Add($Item)
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Network.Controller>"
    }
}

Class SystemController
{
    Hidden [Object] $Module
    [Object]      $Snapshot
    [Object]          $Bios
    [Object]            $OS
    [Object]      $Computer
    [Object]     $Processor
    [Object]          $Disk
    [Object]       $Network
    SystemController([Object]$Module)
    {
        $This.Module    = $Module
        $This.Snapshot  = $This.Get("Snapshot")
        $This.Bios      = $This.Get("Bios")
        $This.OS        = $This.Get("OS")
        $This.Computer  = $This.Get("Computer")
        $This.Processor = $This.Get("Processor")
        $This.Disk      = $This.Get("Disk")
        $This.Network   = $This.Get("Network")
    }
    [Object] Get([String]$Name)
    {
        $This.Module.Update(0,"Getting [~] $Name")
        $Item = Switch ($Name)
        {
            Snapshot
            {
                [SystemSnapshot]::New($This.Module)
            }
            Bios
            {
                [SystemBiosInformation]::New($This.Module)
            }
            OS
            {
                [SystemOperatingSystem]::New($This.Module)
            }
            Computer
            {
                [SystemComputerSystem]::New($This.Module)
            }
            Processor
            {
                [SystemProcessorController]::New("Processor")
            }
            Disk
            {
                [SystemDiskController]::New("Disk")
            }
            Network
            {
                [SystemNetworkController]::New("Network")
            }
        }

        Return $Item
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.System.Controller>"
    }
}

# [Features]
Class FeatureItem
{
    [UInt32]          $Index
    [String]           $Name
    [String]    $DisplayName
    [UInt32]      $Installed
    FeatureItem([UInt32]$Index,[String]$Name,[String]$DisplayName)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.DisplayName = $DisplayName
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Feature[Item]>"
    }
}

Class FeatureList
{
    [Object] $Output
    FeatureList([Object]$Module)
    {
        $This.Prime()

        $Feature  = $This.GetWindowsFeature()
        $Registry = $This.GetWindowsRegistry()

        ForEach ($Item in $This.Output)
        {
            Switch ($Item.Index)
            {
                {$_ -in 0..5}
                {
                    $Item.Installed = [UInt32]($Feature | ? Name -eq $Item.Name | % Installed)
                }
                Default
                {
                    $Slot = Switch ($Item.Name)
                    {
                        MDT    { $Registry[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                        WinADK { $Registry[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                        WinPE  { $Registry[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
                    }

                    $Installed      = Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2]
                    $Item.Installed = [UInt32](!!$Installed)
                }
            }
        }
    }
    [Object[]] GetWindowsFeature()
    {
        Return Get-WindowsFeature
    }
    [String[]] GetWindowsRegistry()
    {
        Return "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
    }
    Prime()
    {
        If ($This.Output.Count -ne 0)
        {
            Throw "Already primed"
        }

        $This.Output = @( )

        ("DHCP","Dynamic Host Control Protocol"),
        ("DNS","Domain Name Service"),
        ("AD-Domain-Services","Active Directory Domain Services"),
        ("Hyper-V","Microsoft Virtualization Hypervisor"),
        ("WDS","Windows Deployment Services"),
        ("Web-WebServer","Internet Information Services"),
        ("MDT","Microsoft Deployment Toolkit"),
        ("WinADK","Windows Assessment and Deployment Kit"),
        ("WinPE","Windows Preinstallation Environment") | % { 

            $This.Add($_[0],$_[1])
        }
    }
    Add([String]$Name,[String]$DisplayName)
    {
        $This.Output += $This.FeatureItem($This.Output.Count,$Name,$DisplayName)
    }
    [Object] FeatureItem([UInt32]$Index,[String]$Name,[String]$DisplayName)
    {
        Return [FeatureItem]::New($Index,$Name,$DisplayName)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Feature[List]>"
    }
}

# [Config classes]
Class IPConfigItem
{
    [String]   $Alias
    [UInt32]   $Index
    [String]   $Type
    [String]   $Description
    [String]   $Profile
    [String[]] $IPV4Address
    [String]   $IPV4Gateway
    [String[]] $IPV6Address
    [String]   $IPV6Gateway
    [String[]] $DnsServer
    IPConfigItem([Object]$Ip)
    {
        $This.Alias       = $IP.InterfaceAlias
        $This.Index       = $IP.InterfaceIndex
        $This.Description = $IP.InterfaceDescription
        $This.Profile     = $IP.NetProfile.Name
        $This.IPV4Address = $IP.IPV4Address | % IPAddress
        $This.IPV4Gateway = $IP.IPV4DefaultGateway | % NextHop
        $This.IPV6Address = $IP.IPV6Address | % IPAddress
        $This.IPV6Address = $IP.IPV6DefaultGateway | % NextHop
        $This.DNSServer   = $IP.DNSServer | % ServerAddresses
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.IPConfig[Item]>"
    }
}

Class IPAddressItem
{
    [UInt32]     $Index
    [String]      $Type
    [String] $IPAddress
    IPAddressItem([UInt32]$Index,[String]$IPAddress)
    {
        $This.Index = $Index
        $This.Type  = @("4","6")[[UInt32]($IPAddress -match "\d{1,}\.\d{1,}\.\d{1,}\.\d{1,}")]
        $This.IPAddress = $IPAddress
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.IPAddress[Item]>"
    }
}

# [Dhcp Classes]
Class DhcpServerv4Reservation
{
    [String] $IPAddress
    [String] $ClientID
    [String] $Name
    [String] $Description
    DhcpServerv4Reservation([Object]$Reservation)
    {
        $This.IPAddress   = $Reservation.IPAddress
        $This.ClientID    = $Reservation.ClientID
        $This.Name        = $Reservation.Name
        $This.Description = $Reservation.Description
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServerV4Reservation>"
    }
}

Class DhcpServerV4OptionValue
{
    [UInt32] $OptionID
    [String] $Name
    [String] $Type
    [String] $Value
    DhcpServerV4OptionValue([Object]$Option)
    {
        $This.OptionID = $Option.OptionID
        $This.Name     = $Option.Name
        $This.Type     = $Option.Type
        $This.Value    = $Option.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServerV4Reservation>"
    }
}

Class DhcpServerv4Scope
{
    [String] $ScopeID
    [String] $SubnetMask
    [String] $Name
    [UInt32] $State
    [String] $StartRange
    [String] $EndRange
    [Object[]] $Reservations
    [Object[]] $Options
    DhcpServerv4Scope([Object]$Scope)
    {
        $This.ScopeID      = $Scope.ScopeID
        $This.SubnetMask   = $Scope.SubnetMask
        $This.Name         = $Scope.Name
        $This.State        = @(0,1)[$Scope.State -eq "Active"]
        $This.StartRange   = $Scope.StartRange
        $This.EndRange     = $Scope.EndRange
        $This.Reservations = Get-DhcpServerV4Reservation -ScopeID $Scope.ScopeID | % { [DhcpServerv4Reservation]$_ }
        $This.Options      = Get-DhcpServerV4OptionValue -ScopeID $Scope.ScopeID | % { [DhcpServerV4OptionValue]$_ }
    }
}

Class DhcpServer
{
    [Object]$Scope
    DhcpServer()
    {
        $This.Scope = Get-DhcpServerV4Scope | % { [DhcpServerv4Scope]$_ }
    }
}

# [Dns Classes]
Class DnsServerResourceRecord
{
    [Object] $Record
    [String] $Type
    [String] $Name
    DnsServerResourceRecord([Object]$Type,[Object]$Record)
    {
        $This.Record = $Record
        $This.Type   = $Type
        $This.Name   = Switch($Type)
        {
            NS    { $Record.NameServer      } SOA   { $Record.PrimaryServer   }
            MX    { $Record.MailExchange    } CNAME { $Record.HostNameAlias   }
            SRV   { $Record.DomainName      } A     { $Record.IPV4Address     }
            AAAA  { $Record.IPV6Address     } PTR   { $Record.PTRDomainName   }
            TXT   { $Record.DescriptiveText } DHCID { $Record.DHCID           }
        }
    }
    [String] ToString()
    {
        Return ( $This.Name )
    }
}

Class DnsServerHostRecord
{
    [String] $HostName
    [String] $RecordType
    [UInt32] $Type
    [Object] $RecordData
    DnsServerHostRecord([Object]$Record)
    {
        $This.HostName   = $Record.HostName
        $This.RecordType = $Record.RecordType
        $This.Type       = $Record.Type
        $This.RecordData = [DnsServerResourceRecord]::New($Record.RecordType,$Record.RecordData).Name
    }
}

Class DnsServerZone
{
    [String] $Index
    [String] $ZoneName
    [String] $ZoneType
    [UInt32] $IsReverseLookupZone
    [Object[]] $Hosts
    DnsServerZone([UInt32]$Index,[Object]$Zone)
    {
        $This.Index               = $Index
        $This.ZoneName            = $Zone.ZoneName
        $This.ZoneType            = $Zone.ZoneType
        $This.IsReverseLookupZone = $Zone.IsReverseLookupZone
        $This.Hosts               = Get-DNSServerResourceRecord -ZoneName $Zone.Zonename | % { [DnsServerHostRecord]::New($_) }
    }
}

Class DnsServer
{
    [Object] $Zone
    DnsServer()
    {
        $This.Zone = @( )
        ForEach ($Zone in Get-DnsServerZone)
        {
            $This.Zone += [DnsServerZone]::New($This.Zone.Count,$Zone)
            Write-Host "[+] ($($Zone.Zonename))"
        }
    }
}

# [Adds Classes]
Class AddsObject
{
    Hidden [Object] $Object
    [String] $Name
    [String] $Class
    [String] $GUID
    [String] $DistinguishedName
    AddsObject([Object]$Object)
    {
        $This.Object            = $Object
        $This.Name              = $Object.Name
        $This.Class             = $Object.ObjectClass
        $This.GUID              = $Object.ObjectGUID
        $This.DistinguishedName = $Object.DistinguishedName
    }
    [String] ToString()
    {
        Return @( $This.Name )
    }
}

Class AddsDomain
{
    [String] $HostName
    [String] $DCMode
    [String] $DomainMode
    [String] $ForestMode
    [String] $Root
    [String] $Config
    [String] $Schema
    [Object[]] $Site
    [Object[]] $SiteLink
    [Object[]] $Subnet
    [Object[]] $DHCP
    [Object[]] $OU
    [Object[]] $Computer
    AddsDomain()
    {
        Import-Module ActiveDirectory
        $Domain          = Get-Item AD:
        $This.Hostname   = $Domain.DNSHostName
        $This.DCMode     = $Domain.domainControllerFunctionality
        $This.DomainMode = $Domain.domainFunctionality
        $This.ForestMode = $Domain.forestFunctionality
        $This.Root       = $Domain.rootDomainNamingContext
        $This.Config     = $Domain.configurationNamingContext
        $This.Schema     = $Domain.schemaNamingContext
        $Cfg             = Get-ADObject -Filter * -SearchBase $This.Config | ? ObjectClass -match "(Site|Sitelink|Subnet|Dhcpclass)" | % { [AddsObject]$_ }
        $Base            = Get-ADObject -Filter * -SearchBase $This.Root   | ? ObjectClass -match "(OrganizationalUnit|Computer)"    | % { [AddsObject]$_ }
        $This.Site       = $Cfg  | ? Class -eq Site
        $This.SiteLink   = $Cfg  | ? Class -eq Sitelink
        $This.Subnet     = $Cfg  | ? Class -eq Subnet
        $This.Dhcp       = $Cfg  | ? Class -eq DhcpClass
        $This.OU         = $Base | ? Class -eq OrganizationalUnit
        $This.Computer   = $Base | ? Class -eq Computer
    }
}

# [HyperV]
Class VmHost
{
    [String] $Name
    [UInt32] $Processor
    [String] $Memory
    [String] $VHDPath
    [String] $VMPath
    [UInt32] $Switch
    [UInt32] $Vm
    VmHost([Object]$IP)
    {
        $VMHost         = Get-VMHost
        $This.Name      = @($VMHost.ComputerName,"$($VMHost.ComputerName).$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
        $This.Processor = $VMHost.LogicalProcessorCount
        $This.Memory    = "{0:n2} GB" -f [Float]($VMHost.MemoryCapacity/1GB)
    }
}

# [WDS Classes]
Class WdsServer
{
    [String] $Server
    [Object[]] $IPAddress
    WdsServer([Object]$IP)
    {
        $This.Server    = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
        $This.IPAddress = @($IP)
    }
}

# [Mdt Classes]
Class MdtServer
{
    [String]      $Server
    [Object[]] $IPAddress
    [String]        $Path
    [String]     $Version
    [String]  $AdkVersion
    [String]   $PEVersion
    MdtServer([Object]$IP,[Object]$Registry)
    {
        $This.Server     = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
        $This.IPAddress  = @($IP)
        $This.Path       = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment*" | % Install_Dir
        $This.Version    = Get-ItemProperty $Registry | ? DisplayName -match "Microsoft Deployment Toolkit" | % DisplayVersion | % TrimEnd \
        $This.AdkVersion = Get-ItemProperty $Registry | ? DisplayName -match "Windows Assessment and Deployment Kit - Windows 10" | % DisplayVersion
        $This.PeVersion  = Get-ItemProperty $Registry | ? DisplayName -match "Preinstallation Environment Add-ons - Windows 10"   | % DisplayVersion
    }
}

# [IIS Classes]
Class IISSiteBinding
{
    [UInt32]      $Index
    [String]   $Protocol
    [String]    $Binding
    [String]   $SslFlags
    IISSiteBinding([UInt32]$Index,[Object]$Bind)
    {
        $This.Index    = $Index
        $This.Protocol = $Bind.Protocol
        $This.Binding  = $Bind.BindingInformation
        $This.SslFlags = $Bind.SslFlags
    }
    [String] ToString()
    {
        Return @( $This.Binding)
    }
}

Class IISSite
{
    [String]        $Name
    [UInt32]          $ID
    [String]       $State
    [String]        $Path
    [Object[]]  $Bindings
    [UInt32]   $BindCount
    IISSite([Object]$Site)
    {
        $This.Name     = $Site.Name
        $This.ID       = $Site.ID
        $This.State    = $Site.State
        $This.Path     = $Site.Applications[0].VirtualDirectories[0].PhysicalPath
        $This.Bindings = @( )
        If ( $Site.Bindings.Count -gt 1 )
        {
            ForEach ( $Binding in $Site.Bindings)
            {
                $This.Bindings += [IISSiteBinding]::New($This.Bindings.Count,$Binding)
            }
        }
        Else
        {
            $This.Bindings += [IISSiteBinding]::New(0,$Site.Bindings)
        }
        $This.BindCount = $This.Bindings.Count
    }
}

Class IISAppPool
{
    [String]         $Name
    [String]       $Status
    [String]    $AutoStart
    [String]   $CLRVersion
    [String] $PipelineMode
    [String]    $StartMode
    IISAppPool([Object]$AppPool)
    {
        $This.Name         = $AppPool.Name
        $This.Status       = $AppPool.State
        $This.AutoStart    = $AppPool.Attributes | ? Name -eq autoStart             | % Value
        $This.CLRVersion   = $AppPool.Attributes | ? Name -eq managedRuntimeVersion | % Value
        $This.PipelineMode = $AppPool.ManagedPipelineMode
        $This.StartMode    = $AppPool.StartMode
    }
}

Class IISServer
{
    [Object]     $AppDefaults
    [Object] $AppPoolDefaults
    [Object]    $SiteDefaults
    [Object] $VirtualDefaults
    [Object[]]      $AppPools
    [Object[]]         $Sites
    IISServer()
    {
        Import-Module WebAdministration
        $IIS                  = Get-IISServerManager
        $This.AppDefaults     = $IIS.ApplicationDefaults
        $This.AppPoolDefaults = $IIS.ApplicationPoolDefaults
        $This.AppPools        = $IIS.ApplicationPools | % { [IISAppPool]$_ }
        $This.SiteDefaults    = $IIS.SiteDefaults
        $This.Sites           = $IIS.Sites | % { [IISSite]$_ }
    }
}

Class FEInfrastructureConfig
{
    [Object] $IPConfig
    [Object]       $IP
    [Object]     $Dhcp
    [Object]      $Dns
    [Object]     $Adds
    [Object]   $HyperV
    [Object]      $Wds
    [Object]      $Mdt
    [Object]      $IIS
    FEInfrastructureConfig()
    {
        $This.IPConfig = @( )
        $This.IP       = @( )
    }
    AddIpConfig([Object]$Config)
    {
        $This.IPConfig += $This.IPConfigItem($Config)
    }
    AddIpAddress([String]$IPAddress)
    {
        $This.IP       += $This.IPAddressItem($This.IP.Count,$IPAddress)
    }
    [Object] IPConfigItem([Object]$Config)
    {
        Return [IPConfigItem]::New($Config)
    }
    [Object] IPAddressItem([UInt32]$Index,[String]$IPAddress)
    {
        Return [IPAddressItem]::New($Index,$IPAddress)
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.Config>"
    }
}

# [Controller Enums]

Enum ModuleExtensionType
{
    Bios
    OperatingSystem
    ComputerSystem
    Product
    Baseboard
    Enclosure
}

Enum RefreshType
{
    Processor
    Disk
    Network
}

# [Controller objects]

Class FEInfrastructureProperty
{
    [String]  $Name
    [Object] $Value
    FEInfrastructureProperty([Object]$Property)
    {
        $This.Name  = $Property.Name
        $This.Value = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEInfrastructure[Property]>"
    }
}

Class FEInfrastructureValidatePath
{
    [UInt32]   $Status
    [String]     $Type
    [String]     $Name
    [Object] $Fullname
    FEInfrastructureValidatePath([String]$Entry)
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

Class FEInfrastructureFlag
{
    [UInt32] $Index
    [String] $Name
    [UInt32] $Status
    FEInfrastructureFlag([UInt32]$Index,[String]$Name)
    {
        $This.Index  = $Index
        $This.Name   = $Name
        $This.SetStatus(0)
    }
    SetStatus([UInt32]$Status)
    {
        $This.Status = $Status
    }
    [String] ToString()
    {
        Return "<FEInfrastructure[Flag]>"
    }
}

Class FEInfrastructureController
{
    [Object]      $Module
    [Object]        $Xaml
    [Object]      $System
    [Object]     $Feature
    [Object]      $Config
    FEInfrastructureController()
    {
        $This.Module = Get-FEModule -Mode 1
        $This.AddModuleProperties()

        $This.GetXaml()

        $This.GetSystem()

        $This.GetFeature()
        
        $This.GetConfig()
    }
    GetXaml()
    {
        $This.Update(0,"Loading [~] Xaml Controller")

        $This.Xaml    = $This.GetFEInfrastructureXaml()

        $This.Update(1,"Loaded [+] Xaml Controller")
    }
    GetSystem()
    {
        $This.Update(0,"Loading [~] System")

        $This.System  = $This.GetSystemController()
        $This.RefreshSystem()

        $This.Update(1,"Loaded [+] System")
    }
    GetFeature()
    {
        $This.Update(0,"Loading [~] Features")

        $This.Feature = $This.GetFeatureList()

        $This.Update(1,"Loaded [+] Features")
    }
    GetConfig()
    {
        $This.Update(0,"Loading [~] Server Configuration")

        $This.Config = $This.FEInfrastructureConfig()

        # [IP Configurations]
        $This.Update(0,"Getting [~] Network IP Configuration(s)")

        $IPConfig             = Get-NetIPConfiguration
        ForEach ($Item in $IPConfig)
        {
            $Line    = "({0}) {1}: {2}" -f $Item.InterfaceIndex, $Item.InterfaceAlias, $Item.InterfaceDescription
            $This.Update(1,"IP Config [+] $Line")
            $This.Config.AddIPConfig($Item)
        }

        $This.Update(1,"Retrieved [+] Network IP Configuration(s)")

        # [IP Addresses]
        $This.Update(0,"Getting [~] Network IP Address(es)")
        $IP                   = Get-NetIPAddress | % IPAddress
        ForEach ($Item in $IP)
        {
            $This.Update(1,"IP [+] $Item")
            $This.Config.AddIpAddress($Item)
        }

        $This.Update(1,"Retrieved [+] Network IP Address(es)")

        <# [DHCP]
        If ($This.Output | ? Name -match DHCP | ? Value -eq 1)
        {
            $This.Dhcp              = [DhcpServer]::New().Scope
            Write-Host "[+] Dhcp"
        }

        If ($This.Output | ? Name -match DNS | ? Value -eq 1)
        {
            $This.Dns               = [DnsServer]::New().Zone
            Write-Host "[+] Dns"
        }
        If ($This.Output | ? Name -match AD-Domain-Services | ? Value -eq 1)
        {
            $This.Adds              = [AddsDomain]::New()
            Write-Host "[+] Adds"
        }
        If ($This.Output | ? Name -match Hyper-V | ? Value -eq 1)
        {
            $This.HyperV            = [VmHost]::New($This.IPConfig)
            Write-Host "[+] Veridian"
        }
        If ($This.Output | ? Name -match WDS | ? Value -eq 1)
        {
            $This.WDS               = [WDSServer]::New($This.System.Network.Output.IPAddress)
            Write-Host "[+] Wds"
        }
        If ($This.Output | ? Name -match MDT | ? Value -eq 1)
        {
            $This.MDT               = [MdtServer]::New($This.System.Network.Output.IPAddress,$Registry)
            Write-Host "[+] Mdt/WinPE/WinAdk"
        }
        If ($This.Output | ? Name -match Web-WebServer | ? Value -eq 1)
        {
            $This.IIS               = [IISServer]::New()
            Write-Host "[+] IIS"
        }
        #>

        $This.Update(1,"Loaded [+] Server Configuration")
    }
    AddModuleProperty([String]$Name)
    {
        $This.Update(0,"Module [~] $Name")

        $Item = Switch ($Name)
        {
            Bios             { Get-CimInstance Win32_Bios                  }
            OperatingSystem  { Get-CimInstance Win32_OperatingSystem       }
            ComputerSystem   { Get-CimInstance Win32_ComputerSystem        }
            Product          { Get-CimInstance Win32_ComputerSystemProduct }
            Baseboard        { Get-CimInstance Win32_Baseboard             }
            Enclosure        { Get-CimInstance Win32_SystemEnclosure       }
        }

        $This.Module.OS.AddPropertySet($Name)
        $Slot = $This.Module.OS.Property($Name)
        $Item.PSObject.Properties | % { $This.Module.OS.Add($Slot.Index,$_.Name,$_.Value)}

        $This.Update(1,"Module [+] $Name")
    }
    AddModuleProperties()
    {
        ForEach ($Name in [System.Enum]::GetNames([ModuleExtensionType]))
        {
            $This.AddModuleProperty($Name)
        }
    }
    Update([Int32]$State,[String]$Status)
    {
        $This.Module.Update($State,$Status)
        $Last = $This.Module.Console.Last()
        If ($This.Module.Mode -ne 0)
        {
            [Console]::WriteLine($Last.String)
            If ($This.Xaml)
            {
                $This.Xaml.IO.ConsoleOutput.Items.Add($Last)
            }
        }
    }
    [String] Start()
    {
        Return $This.Module.Console.Start.Time.ToString("yyyy-MMdd-HHmmss")
    }
    [String] GetTime()
    {
        Return [DateTime]::Now.ToString("yyyyMMdd-HHmmss")
    }
    [String] Escape([String]$String)
    {
        Return [Regex]::Escape($String)
    }
    [String] TargetPath([String]$Path,[String]$Name)
    {
        Return "{0}\{1}-{2}.txt" -f $Path, $This.Start(), $Name
    }
    [String] Label()
    {
        Return "{0}[Infrastructure Deployment System]" -f $This.Module.Label()
    }
    [Object] GetFEInfrastructureXaml()
    {
        Return [XamlWindow][FEInfrastructureXaml]::Content
    }
    [Object] GetSystemController()
    {
        Return [SystemController]::New($This.Module)
    }
    [Object] GetFeatureList()
    {
        Return [FeatureList]::New($This.Module)
    }
    [Object] FEInfrastructureConfig()
    {
        Return [FEInfrastructureConfig]::New()
    }
    [String] LogPath()
    {
        Return "{0}\{1}\FEInfrastructure" -f $This.Module.ProgramData(), $This.Module.Company
    }
    Reset([Object]$xSender,[Object]$Object)
    {
        $xSender.Items.Clear()

        ForEach ($Item in $Object)
        {
            $xSender.Items.Add($Item)
        }
    }
    [Object] FEInfrastructureProperty([Object]$Property)
    {
        Return [FEInfrastructureProperty]::New($Property)
    }
    [Object] FEInfrastructureFlag([UInt32]$Index,[String]$Name)
    {
        Return [FEInfrastructureFlag]::New($Index,$Name)
    }
    [Object] FEInfrastructureValidatePath([String]$Entry)
    {
        Return [FEInfrastructureValidatePath]::New($Entry)
    }
    [String[]] Grid([String]$Slot)
    {
        $Item = Switch ($Slot)
        {
            Module
            {
                "Source",
                "Description",
                "Author",
                "Copyright"
            }
            Snapshot
            {
                "Start",
                "ComputerName",
                "Name",
                "DisplayName",
                "PartOfDomain",
                "Dns",
                "NetBios",
                "Hostname",
                "Username",
                "Principal",
                "IsAdmin",
                "Caption",
                "Guid"
            }
            Bios
            {
                "ReleaseDate",
                "SmBiosPresent",
                "SmBiosVersion",
                "SmBiosMajor",
                "SmBiosMinor",
                "SystemBiosMajor",
                "SystemBiosMinor"
            }
            Computer
            {
                "UUID",
                "Chassis",
                "BiosUefi",
                "AssetTag"
            }
            Processor
            {
                "ProcessorId",
                "DeviceId",
                "Speed",
                "Cores",
                "Used",
                "Logical",
                "Threads"
            }
            Disk
            {
                "PartitionStyle",
                "ProvisioningType",
                "OperationalStatus",
                "HealthStatus",
                "BusType",
                "UniqueId",
                "Location"
            }
            Network
            {
                "IPAddress",
                "SubnetMask",
                "Gateway",
                "DnsServer",
                "DhcpServer",
                "MacAddress"
            }
        }

        Return $Item
    }
    [Object[]] Property([Object]$Object)
    {
        Return $Object.PSObject.Properties | % { $This.FEInfrastructureProperty($_) }
    }
    [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
    {
        $List = $Object.PSObject.Properties
        $Item = Switch ($Mode)
        {
            0 { $List | ? Name -notin $Property } 1 { $List | ? Name -in $Property }
        }

        Return $Item | % { $This.FEInfrastructureProperty($_) }
    }
    RefreshSystem()
    {
        $This.Update(0,"Refreshing [~] System")

        ForEach ($Name in [System.Enum]::GetNames([RefreshType]))
        {
            If ($Name -in "Processor","Network")
            {
                $Branch = $This.System.$Name

                $This.Update(0,"Refreshing [~] $Name Controller")

                ForEach ($Object in $Branch.GetObject())
                {
                    $Item = $Branch.New($Object)
                    $Branch.Add($Item)

                    $This.Update(1,$Item.Status)
                }

                $This.Update(1,"Refreshed [+] $Name Controller")
            }
            ElseIf ($Name -eq "Disk")
            {
                $Branch            = $This.System.Disk

                $This.Update(0,"Refreshing [~] Disk Controller")

                $DiskDrive         = $Branch.Get("DiskDrive")
                $MsftDisk          = $Branch.Get("MsftDisk")
                $DiskPartition     = $Branch.Get("DiskPartition")
                $LogicalDisk       = $Branch.Get("LogicalDisk")
                $LogicalDiskToPart = $Branch.Get("LogicalDiskToPart")
    
                ForEach ($Drive in $DiskDrive | ? MediaType -match Fixed)
                {
                    # [Disk Template]
                    $Disk     = $Branch.SystemDiskItem($Drive)
    
                    # [MsftDisk]
                    $Msft     = $MsftDisk | ? Number -eq $Disk.Index
                    If ($Msft)
                    {
                        $Disk.MsftDisk($Msft)
                    }
    
                    # [Partitions]
                    ForEach ($Partition in $DiskPartition | ? DiskIndex -eq $Disk.Index)
                    {
                        $Disk.Partition.Add($Branch.SystemPartitionItem($Disk.Partition.Count,$Partition))
                    }
    
                    # [Volumes]
                    ForEach ($Logical in $LogicalDiskToPart | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name })
                    {
                        $Drive      = $LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                        $Partition  = $DiskPartition | ?     Name -eq $Logical.Antecedent.DeviceID
                        If ($Drive -and $Partition)
                        {
                            $Disk.Volume.Add($Branch.SystemVolumeItem($Disk.Volume.Count,$Drive,$Partition))
                        }
                    }

                    $Disk.SetStatus()

                    $This.Update(0,$Disk.Status)
    
                    $Branch.Output += $Disk
                }

                $This.Update(1,"Refreshed [+] Disk Controller")
            }
        }

        $This.Update(1,"Refreshed [+] System")
    }
    ModulePanel()
    {
        $This.Update(0,"Staging [~] Module Panel")

        $Ctrl = $This

        # [Module]
        $Ctrl.Reset($Ctrl.Xaml.IO.Module,$Ctrl.Module)

        # [Module Extension]
        $Ctrl.Reset($Ctrl.Xaml.IO.ModuleExtension,$Ctrl.Property($Ctrl.Module,1,$Ctrl.Grid("Module")))

        # [Module Root]
        $Ctrl.Reset($Ctrl.Xaml.IO.ModuleRoot,$Ctrl.Module.Root.List())

        # [Module Manifest]
        $Ctrl.Reset($Ctrl.Xaml.IO.ModuleManifest,$Ctrl.Module.Manifest)

        # [Module Manifest List]
        $Ctrl.Reset($Ctrl.Xaml.IO.ModuleManifestList,$Ctrl.Module.Manifest.Full())
    }
    SystemPanel()
    {
        $This.Update(0,"Staging [~] System Panel")

        $Ctrl = $This

        # [Snapshot Information]
        $Ctrl.Reset($Ctrl.Xaml.IO.SnapshotInformation,$Ctrl.Property($Ctrl.System.Snapshot,1,$Ctrl.Grid("Snapshot")))

        # [Bios Information]
        $Ctrl.Reset($Ctrl.Xaml.IO.BiosInformation,$Ctrl.System.Bios)

        # [Bios Information Extension]
        $List = $Ctrl.Property($Ctrl.System.Bios,1,$Ctrl.Grid("Bios"))
        $Ctrl.Reset($Ctrl.Xaml.IO.BiosInformationExtension,$List)

        # [Computer System]
        $Ctrl.Reset($Ctrl.Xaml.IO.ComputerSystem,$Ctrl.System.Computer)

        # [Computer System Extension]
        $List = $Ctrl.Property($Ctrl.System.Computer,1,$Ctrl.Grid("Computer"))
        $Ctrl.Reset($Ctrl.Xaml.IO.ComputerSystemExtension,$List)

        # [Processor]
        $Ctrl.Reset($Ctrl.Xaml.IO.ProcessorOutput,$Ctrl.System.Processor.Output)

        # [Processor Event Trigger(s)]
        $Ctrl.Xaml.IO.ProcessorOutput.Add_SelectionChanged(
        {
            $Index = $Ctrl.Xaml.IO.ProcessorOutput.SelectedIndex
            Switch ($Index)
            {
                -1
                {
                    $Ctrl.Xaml.IO.ProcessorExtension.Items.Clear()
                }
                Default
                {
                    $List = $Ctrl.Property($Ctrl.System.Processor.Output[$Index],1,$Ctrl.Grid("Processor"))
                    $Ctrl.Reset($Ctrl.Xaml.IO.ProcessorExtension,$List)
                }
            }
        })

        # [Disk]
        $Ctrl.Reset($Ctrl.Xaml.IO.DiskOutput,$Ctrl.System.Disk.Output)

        # [Disk Event Trigger(s)]
        $Ctrl.Xaml.IO.DiskOutput.Add_SelectionChanged(
        {
            $Index = $Ctrl.Xaml.IO.DiskOutput.SelectedIndex
            Switch ($Index)
            {
                -1
                {
                    $Ctrl.Xaml.IO.DiskExtension.Items.Clear()   
                }
                Default
                {
                    # [Disk Extension]
                    $List = $Ctrl.Property($Ctrl.System.Disk.Output[$Index],1,$Ctrl.Grid("Disk"))
                    $Ctrl.Reset($Ctrl.Xaml.IO.DiskExtension,$List)

                    # [Disk Partition(s)]
                    $Ctrl.Reset($Ctrl.Xaml.IO.DiskPartition,
                                $Ctrl.System.Disk.Output[$Index].Partition.Output)

                    # [Disk Volume(s)]
                    $Ctrl.Reset($Ctrl.Xaml.IO.DiskVolume,
                                $Ctrl.System.Disk.Output[$Index].Volume.Output)
                }
            }
        })

        # [Network]
        $Ctrl.Reset($Ctrl.Xaml.IO.NetworkOutput,$Ctrl.System.Network.Output)

        # [Network Event Trigger(s)]
        $Ctrl.Xaml.IO.NetworkOutput.Add_SelectionChanged(
        {
            $Index = $Ctrl.Xaml.IO.NetworkOutput.SelectedIndex
            Switch ($Index)
            {
                -1
                {
                    $Ctrl.Xaml.IO.NetworkExtension.Items.Clear()
                }
                Default
                {
                    $List = $Ctrl.Property($Ctrl.System.Network.Output[$Index],1,$Ctrl.Grid("Network"))
                    $Ctrl.Reset($Ctrl.Xaml.IO.NetworkExtension,$List)
                }
            }
        })

        $This.Update(1,"Staged [+] System Panel")
    }
    ConfigPanel()
    {
        $This.Update(0,"Staging [~] Config Panel")

        # [Features]
        $Ctrl = $This

        $Ctrl.Reset($Ctrl.Xaml.IO.CfgServices,$Ctrl.Feature.Output)

        $Adapters = $Ctrl.System.Network.Output | ? State -notmatch Disconnected 
        $Ctrl.Reset($Ctrl.Xaml.IO.Network_Adapter,$Adapters)

        $Ctrl.Xaml.IO.Network_Adapter.Add_SelectionChanged(
        {
            $Index = $Ctrl.Xaml.IO.Network_Adapter.SelectedIndex
            If ($Index -ne -1)
            {
                $Ctrl.SelectNetworkAdapter($Index)
            }
            Else
            {
                $This.Xaml.IO.Network_Name.Text          = ""
                $This.Xaml.IO.Network_Type.SelectedIndex = 0
                $This.Xaml.IO.Network_IPAddress.Text     = ""
                $This.Xaml.IO.Network_SubnetMask.Text    = ""
                $This.Xaml.IO.Network_Gateway.Text       = ""
                $This.Xaml.IO.Network_Index.Text         = ""

                $This.Reset($This.Xaml.IO.Network_DNS,$Null)

                $This.Xaml.IO.Network_DHCP.Text          = ""
                $This.Xaml.IO.Network_MacAddress.Text    = ""
            }
        })
        
        $This.Update(1,"Staged [+] Config Panel")
    }
    SelectNetworkAdapter([Object]$Index)
    {
        If ($Index -gt $This.Xaml.IO.Network_Adapter.Count)
        {
            Throw "Invalid index"
        }

        $Item = $This.Xaml.IO.Network_Adapter.Items[$Index]

        $This.Xaml.IO.Network_Name.Text          = $Item.Name
        $This.Xaml.IO.Network_Type.SelectedIndex = [UInt32]($Item.DhcpServer -match "\d{1,}\.\d{1,}\.\d{1,}\.\d{1,}")
        $This.Xaml.IO.Network_IPAddress.Text     = $Item.IPAddress
        $This.Xaml.IO.Network_SubnetMask.Text    = $Item.SubnetMask
        $This.Xaml.IO.Network_Gateway.Text       = $Item.Gateway
        $This.Xaml.IO.Network_Index.Text         = $Item.Index

        $This.Reset($This.Xaml.IO.Network_DNS,($Item.DnsServer -Split ", "))

        $This.Xaml.IO.Network_DHCP.Text          = $Item.DhcpServer
        $This.Xaml.IO.Network_MacAddress.Text    = $Item.MacAddress
    }
    StageXaml()
    {
        $This.ModulePanel()
        $This.SystemPanel()
        $This.ConfigPanel()
    }
}

$Ctrl = [FEInfrastructureController]::New()
$Ctrl.StageXaml()
$Ctrl.Xaml.Invoke()
