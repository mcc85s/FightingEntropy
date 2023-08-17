# About (2023/08/17)
# Get-ViperBomb takes a fair amount of time to load. Not to mention, the ControlTemplate classes each require the
# $Console variable to be present, which is effectively duplicating that object, whereby making the process take
# a lot longer to load. Merging the following class types and then relocating the SetMode method to the outside
# ViperBombController scope WILL allow this function to work a LOT faster.

    # // ===================
    # // | Generic Objects |
    # // ===================    

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
            Return "<FEModule.ViperBomb.Generic[Property]>"
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
            Return "<FEModule.ViperBomb.GenericProfile[Property]>"
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
            $This.Fullname = $Fullname
        }
        [String] ToString()
        {
            Return "<FEModule.GenericProfile[{0}]>" -f $This.Name
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
            Return "<FEModule.GenericProfile[Controller]>"
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
            Return "<FEModule.ViperBomb.System.Generic[List][{0}]>" -f $This.Name
        }
    }
    
    # // ===============
    # // | Xaml assets |
    # // ===============

    Class ViperBombXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[FightingEntropy]://System Control Extension Utility"',
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
        '            <RowDefinition Height="50"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <DataGrid Grid.Row="0"',
        '                  Name="OS">',
        '            <DataGrid.RowStyle>',
        '                <Style TargetType="{x:Type DataGridRow}">',
        '                    <Style.Triggers>',
        '                        <Trigger Property="IsMouseOver" Value="True">',
        '                            <Setter Property="ToolTip">',
        '                                <Setter.Value>',
        '                                    <TextBlock Text="{Binding Name}"',
        '                                               TextWrapping="Wrap"',
        '                                               FontFamily="Consolas"',
        '                                               Background="#000000"',
        '                                               Foreground="#00FF00"/>',
        '                                </Setter.Value>',
        '                            </Setter>',
        '                        </Trigger>',
        '                    </Style.Triggers>',
        '                </Style>',
        '            </DataGrid.RowStyle>',
        '            <DataGrid.Columns>',
        '                <DataGridTextColumn Header="Caption"',
        '                                    Width="300"',
        '                                    Binding="{Binding Caption}"/>',
        '                <DataGridTextColumn Header="Platform"',
        '                                    Width="150"',
        '                                    Binding="{Binding Platform}"/>',
        '                <DataGridTextColumn Header="PSVersion"',
        '                                    Width="150"',
        '                                    Binding="{Binding PSVersion}"/>',
        '                <DataGridTextColumn Header="Type"',
        '                                    Width="*"',
        '                                    Binding="{Binding Type}"/>',
        '            </DataGrid.Columns>',
        '        </DataGrid>',
        '        <TabControl Grid.Row="1">',
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
        '                                        ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2022.12.0\Graphics\background.jpg"/>',
        '                        </Grid.Background>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Image Grid.Row="0"',
        '                               Source="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\banner.png"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="2"',
        '                              Name="Module">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding Description}"',
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
        '                                    <Style TargetType="{x:Type DataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="[FightingEntropy()] Module Property"',
        '                                                                   TextWrapping="Wrap"',
        '                                                                   FontFamily="Consolas"',
        '                                                                   Background="#000000"',
        '                                                                   Foreground="#00FF00"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
        '                                            </Trigger>',
        '                                        </Style.Triggers>',
        '                                    </Style>',
        '                                </DataGrid.RowStyle>',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="120"/>',
        '                                    <DataGridTextColumn Header="Value"',
        '                                                            Binding="{Binding Value}"',
        '                                                            Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </TabItem>',
        '                        <TabItem Header="Root">',
        '                            <DataGrid Name="ModuleRoot">',
        '                                <DataGrid.RowStyle>',
        '                                    <Style TargetType="{x:Type DataGridRow}">',
        '                                        <Style.Triggers>',
        '                                            <Trigger Property="IsMouseOver" Value="True">',
        '                                                <Setter Property="ToolTip">',
        '                                                    <Setter.Value>',
        '                                                        <TextBlock Text="[FightingEntropy()] Root Property"',
        '                                                                   TextWrapping="Wrap"',
        '                                                                   FontFamily="Consolas"',
        '                                                                   Background="#000000"',
        '                                                                   Foreground="#00FF00"/>',
        '                                                    </Setter.Value>',
        '                                                </Setter>',
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
        '                                              Name="ModuleManifest">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="[FightingEntropy()] Module Manifest"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Fullname}"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Provides host system + runtime information&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1"',
        '                                          Name="SnapshotInformation"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Snapshot Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays system (BIOS/UEFI) information&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1" Name="BiosInformation">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Bios Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays additional (BIOS/UEFI) information&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          Name="BiosInformationExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Bios Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays information about the computer system&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1" Name="ComputerSystem">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Computer System Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays additional computer system information&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          Name="ComputerSystemExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Computer System Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                        <TabItem Header="Edition">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="50"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Edition]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Text="&lt;Displays operating system edition information&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1"',
        '                                          Name="EditionCurrent">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Edition Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index"',
        '                                                            Binding="{Binding Index}"',
        '                                                            Width="50"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="100"/>',
        '                                        <DataGridTextColumn Header="Build"',
        '                                                            Binding="{Binding Build}"',
        '                                                            Width="100"/>',
        '                                        <DataGridTextColumn Header="Codename"',
        '                                                            Binding="{Binding Codename}"',
        '                                                            Width="*"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Property]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Text="&lt;Displays operating system edition properties&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          Name="EditionProperty"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Edition Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                </Trigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Binding="{Binding Name}"',
        '                                                            Width="180"/>',
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
        '                                             Text="&lt;Displays information for each CPU&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1"',
        '                                          Name="ProcessorOutput">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Processor Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays additional properties for selected CPU&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          Name="ProcessorExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Processor Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="80"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Disk]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Text="&lt;Displays information for each (system disk/HDD)&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1"',
        '                                          RowHeaderWidth="0"',
        '                                          Name="DiskOutput">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Disk Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays additional properties for selected HDD&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          Name="DiskExtension"',
        '                                          HeadersVisibility="None">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Disk Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays partition information for selected HDD&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="5" Name="DiskPartition">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Partition Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays volume information for selected HDD&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="7" Name="DiskVolume">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Volume Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays information for each network interface&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1" Name="NetworkOutput">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Network Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '                                             Text="&lt;Displays additional properties for selected network adapter&gt;"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="3"',
        '                                          HeadersVisibility="None"',
        '                                          Name="NetworkExtension">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="Network Information"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
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
        '            <TabItem Header="OS/HotFix">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="50"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[OS/HotFix]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profiles + information for (installed/desired) Hot Fix packages&gt;"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="2" Name="OperatingSystem">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="Operating System Information"',
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
        '                            <DataGridTextColumn Header="Edition"',
        '                                                Width="*"',
        '                                                Binding="{Binding Caption}"/>',
        '                            <DataGridTextColumn Header="Version"',
        '                                                Width="100"',
        '                                                Binding="{Binding Version}"/>',
        '                            <DataGridTextColumn Header="Build"',
        '                                                Width="50"',
        '                                                Binding="{Binding Build}"/>',
        '                            <DataGridTextColumn Header="Serial"',
        '                                                Width="180"',
        '                                                Binding="{Binding Serial}"/>',
        '                            <DataGridTextColumn Header="Lang."',
        '                                                Width="35"',
        '                                                Binding="{Binding Language}"/>',
        '                            <DataGridTextColumn Header="Prod."',
        '                                                Width="35"',
        '                                                Binding="{Binding Product}"/>',
        '                            <DataGridTextColumn Header="Type"',
        '                                                Width="35"',
        '                                                Binding="{Binding Type}"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="3">',
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
        '                                  Name="HotFixSearchProperty"',
        '                                  SelectedIndex="1">',
        '                            <ComboBoxItem Content="Description"/>',
        '                            <ComboBoxItem Content="HotFix ID"/>',
        '                            <ComboBoxItem Content="Installed By"/>',
        '                            <ComboBoxItem Content="Installed On"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="HotFixSearchFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Content="Refresh"',
        '                                Name="HotFixRefresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="4"',
        '                              Name="HotFixOutput">',
        '                        <DataGrid.Columns>',
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="Source"',
        '                                                Binding="{Binding Source}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="HotFix ID"',
        '                                                Binding="{Binding HotFixID}"',
        '                                                Width="80"/>',
        '                            <DataGridTextColumn Header="Installed By"',
        '                                                Binding="{Binding InstalledBy}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Installed On"',
        '                                                Binding="{Binding InstalledOn}"',
        '                                                Width="120"/>',
        '                            <DataGridTemplateColumn Header="State" Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="100">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="HotFixProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="HotFixProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="HotFixProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="HotFixProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="6">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="HotFixProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="HotFixProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="HotFixProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Feature">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Feature]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profiles + information for (installed/desired) Windows optional features&gt;"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
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
        '                                  Name="FeatureProperty"',
        '                                  SelectedIndex="0">',
        '                            <ComboBoxItem Content="Feature Name"/>',
        '                            <ComboBoxItem Content="Description"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="FeatureFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Content="Refresh"',
        '                                Name="FeatureRefresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="3"',
        '                              Name="FeatureOutput">',
        '                        <DataGrid.Columns>',
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Width="40"',
        '                                                Binding="{Binding Index}"/>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Width="*"',
        '                                                Binding="{Binding FeatureName}"/>',
        '                            <DataGridTemplateColumn Header="State" Width="160">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="DisabledWithPayloadRemoved"/>',
        '                                            <ComboBoxItem Content="Enabled"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="160">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="DisabledWithPayloadRemoved"/>',
        '                                            <ComboBoxItem Content="Enabled"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="FeatureProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="FeatureProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="FeatureProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="FeatureProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="FeatureProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="FeatureProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="FeatureProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="AppX">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[AppX]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profiles + information for (provisioned/desired) DISM packages&gt;"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
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
        '                                  Name="AppXProperty"',
        '                                  SelectedIndex="0">',
        '                            <ComboBoxItem Content="Package Name"/>',
        '                            <ComboBoxItem Content="Display Name"/>',
        '                            <ComboBoxItem Content="Description"/>',
        '                            <ComboBoxItem Content="Publisher ID"/>',
        '                            <ComboBoxItem Content="Install Location"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="AppXFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Name="AppXRefresh"',
        '                                Content="Refresh" />',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="3"',
        '                              Name="AppXOutput">',
        '                        <DataGrid.Columns>',
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="DisplayName"',
        '                                                Binding="{Binding DisplayName}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="PublisherID"',
        '                                                Binding="{Binding PublisherID}"',
        '                                                Width="100"/>',
        '                            <DataGridTextColumn Header="Version"',
        '                                                Binding="{Binding Version}"',
        '                                                Width="150"/>',
        '                            <DataGridTemplateColumn Header="State" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="AppXProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="AppXProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="AppXProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="AppXProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="AppXProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="AppXProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="AppXProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Application">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Application]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profiles + information for (installed/desired) applications&gt;"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="130"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Search]:"',
        '                               Style="{StaticResource LabelRed}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <ComboBox Grid.Column="1"',
        '                                  Name="ApplicationProperty"',
        '                                  SelectedIndex="1">',
        '                            <ComboBoxItem Content="Display Name"/>',
        '                            <ComboBoxItem Content="Display Version"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="ApplicationFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Content="Refresh"',
        '                                Name="ApplicationRefresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="3"',
        '                              Name="ApplicationOutput">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding DisplayVersion}"',
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
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="DisplayName"',
        '                                                Binding="{Binding DisplayName}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Type"',
        '                                                Binding="{Binding Type}"',
        '                                                Width="40"/>',
        '                            <DataGridTemplateColumn Header="State" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Installed"/>',
        '                                            <ComboBoxItem Content="Remove"/>',
        '                                            <ComboBoxItem Content="Install"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="ApplicationProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="ApplicationProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="ApplicationProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="ApplicationProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="ApplicationProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="ApplicationProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="ApplicationProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Event">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Event Logs]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profile + information for event log (settings/content)&gt;"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="130"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Search]:"',
        '                               Style="{StaticResource LabelRed}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <ComboBox Grid.Column="1"',
        '                                  Name="EventProperty"',
        '                                  SelectedIndex="0">',
        '                            <ComboBoxItem Content="Name"/>',
        '                            <ComboBoxItem Content="Fullname"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="EventFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Content="Refresh"',
        '                                Name="EventRefresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="3"',
        '                              Name="EventOutput">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding Fullname}"',
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
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Size"',
        '                                                Binding="{Binding Size}"',
        '                                                Width="60"/>',
        '                            <DataGridTextColumn Header="Max"',
        '                                                Binding="{Binding Max}"',
        '                                                Width="60"/>',
        '                            <DataGridTextColumn Header="%"',
        '                                                Binding="{Binding Percent}"',
        '                                                Width="60"/>',
        '                            <DataGridTextColumn Header="Ct"',
        '                                                Binding="{Binding Count}"',
        '                                                Width="40"/>',
        '                            <DataGridTemplateColumn Header="State" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="Enabled"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="Enabled"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="EventProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="EventProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="EventProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="EventProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="EventProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="EventProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="EventProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Task">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Task]:"/>',
        '                        <TextBox Grid.Column="1"',
        '                                 Text="&lt;Manages profile + information for (current/desired) scheduled tasks&gt;"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="130"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Search]:"',
        '                               Style="{StaticResource LabelRed}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <ComboBox Grid.Column="1"',
        '                                  Name="TaskProperty"',
        '                                  SelectedIndex="0">',
        '                            <ComboBoxItem Content="Name"/>',
        '                            <ComboBoxItem Content="Author"/>',
        '                            <ComboBoxItem Content="State"/>',
        '                        </ComboBox>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="TaskFilter"/>',
        '                        <Button Grid.Column="3"',
        '                                Content="Refresh"',
        '                                Name="TaskRefresh"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="3"',
        '                              Name="TaskOutput">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding Author}"',
        '                                                           TextWrapping="Wrap"',
        '														   FontFamily="Consolas"',
        '                                                           Background="#000000"',
        '                                                           Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                        <Setter Property="ToolTipService.ShowDuration"',
        '                                                Value="360000000"/>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridCheckBoxColumn Header="[+]"',
        '                                                    Width="25"',
        '                                                    Binding="{Binding Profile}"/>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Action"',
        '                                                Binding="{Binding Actions}"',
        '                                                Width="50"/>',
        '                            <DataGridTextColumn Header="Trigger"',
        '                                                Binding="{Binding Triggers}"',
        '                                                Width="50"/>',
        '                            <DataGridTemplateColumn Header="State" Width="75">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding State.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="Ready"/>',
        '                                            <ComboBoxItem Content="Running"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                            <DataGridTemplateColumn Header="Target" Width="50">',
        '                                <DataGridTemplateColumn.CellTemplate>',
        '                                    <DataTemplate>',
        '                                        <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                  Style="{StaticResource DGCombo}">',
        '                                            <ComboBoxItem Content="Disabled"/>',
        '                                            <ComboBoxItem Content="Ready"/>',
        '                                            <ComboBoxItem Content="Running"/>',
        '                                        </ComboBox>',
        '                                    </DataTemplate>',
        '                                </DataGridTemplateColumn.CellTemplate>',
        '                            </DataGridTemplateColumn>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="120"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="25"/>',
        '                            <ColumnDefinition Width="90"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Label Grid.Column="0"',
        '                               Content="[Profile]:"',
        '                               Style="{StaticResource LabelGray}"',
        '                               HorizontalContentAlignment="Left"/>',
        '                        <CheckBox Grid.Column="1"',
        '                                  Name="TaskProfileSwitch"/>',
        '                        <TextBox Grid.Column="2"',
        '                                 Name="TaskProfilePath"/>',
        '                        <Image Grid.Column="3"',
        '                               Name="TaskProfilePathIcon"/>',
        '                        <Button Grid.Column="4"',
        '                                Name="TaskProfileBrowse"',
        '                                Content="Browse"/>',
        '                    </Grid>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0"',
        '                                Name="TaskProfileLoad"',
        '                                Content="Load"/>',
        '                        <Button Grid.Column="1"',
        '                                Name="TaskProfileSave"',
        '                                Content="Save"/>',
        '                        <Button Grid.Column="2"',
        '                                Name="TaskProfileApply"',
        '                                Content="Apply"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Service">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Configuration">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Service]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Text="&lt;Manages profile + information for (current/desired) service (states/start modes)&gt;"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Search]:"',
        '                                           Style="{StaticResource LabelRed}"',
        '                                           HorizontalContentAlignment="Left"/>',
        '                                    <ComboBox Grid.Column="1"',
        '                                              Margin="5"',
        '                                              Name="ServiceProperty"',
        '                                              VerticalAlignment="Center"',
        '                                              SelectedIndex="1">',
        '                                        <ComboBoxItem Content="Name"/>',
        '                                        <ComboBoxItem Content="Display Name"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="2"',
        '                                             Margin="5"',
        '                                             Name="ServiceFilter"/>',
        '                                    <Button Grid.Column="3"',
        '                                            Content="Refresh"',
        '                                            Name="ServiceRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="2"',
        '                                          Grid.Column="0"',
        '                                          Name="ServiceOutput">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Description}"',
        '                                                                       TextWrapping="Wrap"',
        '                                                                       Width="800"',
        '                                                                       FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
        '                                                        </Setter.Value>',
        '                                                    </Setter>',
        '                                                    <Setter Property="ToolTipService.ShowDuration"',
        '                                                            Value="360000000"/>',
        '                                                </Trigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}"',
        '                                                                   Value="1"/>',
        '                                                        <Condition Binding="{Binding Match}"',
        '                                                                   Value="0"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background"',
        '                                                            Value="#F08080"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}"',
        '                                                                   Value="0"/>',
        '                                                        <Condition Binding="{Binding Match}"',
        '                                                                   Value="0"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background"',
        '                                                            Value="#FFFFFF64"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}"',
        '                                                                   Value="0"/>',
        '                                                        <Condition Binding="{Binding Match}"',
        '                                                                   Value="1"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background"',
        '                                                            Value="#FFFFFF64"/>',
        '                                                </MultiDataTrigger>',
        '                                                <MultiDataTrigger>',
        '                                                    <MultiDataTrigger.Conditions>',
        '                                                        <Condition Binding="{Binding Scope}"',
        '                                                                   Value="1"/>',
        '                                                        <Condition Binding="{Binding Match}"',
        '                                                                   Value="1"/>',
        '                                                    </MultiDataTrigger.Conditions>',
        '                                                    <Setter Property="Background"',
        '                                                            Value="LightGreen"/>',
        '                                                </MultiDataTrigger>',
        '                                            </Style.Triggers>',
        '                                        </Style>',
        '                                    </DataGrid.RowStyle>',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTemplateColumn Header="[+]" Width="25">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <CheckBox IsChecked="{Binding Profile}"',
        '                                                              Margin="0"',
        '                                                              HorizontalAlignment="Center">',
        '                                                        <CheckBox.LayoutTransform>',
        '                                                            <ScaleTransform ScaleX="0.75" ScaleY="0.75" />',
        '                                                        </CheckBox.LayoutTransform>',
        '                                                    </CheckBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTextColumn Header="#"',
        '                                                            Width="30"',
        '                                                            Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="175"',
        '                                                            Binding="{Binding Name}"/>',
        '                                        <DataGridTemplateColumn Header="StartType" Width="90">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding StartMode.Index}"',
        '                                                              Style="{StaticResource DGCombo}">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="Manual"/>',
        '                                                        <ComboBoxItem Content="Auto"/>',
        '                                                        <ComboBoxItem Content="Auto Delayed"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTemplateColumn Header="Target" Width="90">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Target.Index}"',
        '                                                              Style="{StaticResource DGCombo}">',
        '                                                        <ComboBoxItem Content="Skip"/>',
        '                                                        <ComboBoxItem Content="Disabled"/>',
        '                                                        <ComboBoxItem Content="Manual"/>',
        '                                                        <ComboBoxItem Content="Auto"/>',
        '                                                        <ComboBoxItem Content="Auto Delayed"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                        <DataGridTextColumn Header="DisplayName"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding DisplayName}"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="105"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                        <ColumnDefinition Width="45"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Profile]:"',
        '                                           Style="{StaticResource LabelGray}"',
        '                                           HorizontalContentAlignment="Left"/>',
        '                                    <ComboBox Grid.Column="1"',
        '                                              Name="ServiceSlot"',
        '                                              SelectedIndex="0"/>',
        '                                    <DataGrid Grid.Column="2"',
        '                                              Name="ServiceDescription"',
        '                                              HeadersVisibility="None"',
        '                                              Margin="10">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"',
        '                                                                Binding="{Binding Type}"',
        '                                                                Width="120"/>',
        '                                            <DataGridTextColumn Header="Description"',
        '                                                                Binding="{Binding Description}"',
        '                                                                Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Border Grid.Column="3"',
        '                                            Background="Black"',
        '                                            Margin="4"/>',
        '                                    <Label Grid.Column="4"',
        '                                           Content="[Compliant]:"/>',
        '                                    <Label Grid.Column="5"',
        '                                           Background="#66FF66"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="Yes"/>',
        '                                    <Label Grid.Column="6"',
        '                                           Background="#FFFF66"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="N/A"/>',
        '                                    <Label Grid.Column="7"',
        '                                           Background="#FF6666"',
        '                                           Foreground="Black"',
        '                                           HorizontalContentAlignment="Center"',
        '                                           Content="No"/>',
        '                                </Grid>',
        '                                <Button Grid.Row="4"',
        '                                        Name="ServiceSet"',
        '                                        Content="Apply"',
        '                                        IsEnabled="False"/>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Preferences">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Options]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Text="&lt;Manages options for the service configuration tool&gt;"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="300"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Grid Grid.Column="0">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid Grid.Row="0">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="110"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Label Grid.Column="0"',
        '                                                   Content="[Slot]:"',
        '                                                   Style="{StaticResource LabelRed}"',
        '                                                   HorizontalContentAlignment="Left"/>',
        '                                            <ComboBox Grid.Column="1"',
        '                                                      Name="ServiceOptionSlot">',
        '                                                <ComboBoxItem Content="0"/>',
        '                                                <ComboBoxItem Content="1"/>',
        '                                                <ComboBoxItem Content="2"/>',
        '                                                <ComboBoxItem Content="3"/>',
        '                                                <ComboBoxItem Content="4"/>',
        '                                            </ComboBox>',
        '                                            <DataGrid Grid.Column="2"',
        '                                                      Height="20"',
        '                                                      Name="ServiceOptionDescription"',
        '                                                      HeadersVisibility="None">',
        '                                                <DataGrid.Columns>',
        '                                                    <DataGridTextColumn Binding="{Binding Name}"',
        '                                                                        Width="100"/>',
        '                                                    <DataGridTextColumn Binding="{Binding Description}"',
        '                                                                        Width="*"/>',
        '                                                </DataGrid.Columns>',
        '                                            </DataGrid>',
        '                                        </Grid>',
        '                                        <DataGrid Grid.Row="1"',
        '                                                  Name="ServiceOptionList">',
        '                                            <DataGrid.Columns>',
        '                                                <DataGridTextColumn Header="Type"',
        '                                                                    Binding="{Binding Type}"',
        '                                                                    Width="40"/>',
        '                                                <DataGridTextColumn Header="Description"',
        '                                                                    Binding="{Binding Description}"',
        '                                                                    Width="*"/>',
        '                                                <DataGridTemplateColumn Header="Value" Width="40">',
        '                                                    <DataGridTemplateColumn.CellTemplate>',
        '                                                        <DataTemplate>',
        '                                                            <CheckBox IsChecked="{Binding Value}"/>',
        '                                                        </DataTemplate>',
        '                                                    </DataGridTemplateColumn.CellTemplate>',
        '                                                </DataGridTemplateColumn>',
        '                                            </DataGrid.Columns>',
        '                                        </DataGrid>',
        '                                    </Grid>',
        '                                    <Border Grid.Column="1" Background="Black" Margin="4"/>',
        '                                    <TabControl Grid.Column="2">',
        '                                        <TabItem Header="BlackViper">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <TextBox Grid.Row="0"',
        '                                                         Text="https://www.blackviper.com"/>',
        '                                                <TextBox Grid.Row="1"',
        '                                                         Name="ServiceBlackViper"',
        '                                                         Height="110"',
        '                                                         Padding="2"',
        '                                                         VerticalAlignment="Top"',
        '                                                         VerticalContentAlignment="Top"/>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="MadBomb122">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <TextBox Grid.Column="1"',
        '                                                         Text="https://www.github.com/MadBomb122"/>',
        '                                                <TextBox Grid.Row="1"',
        '                                                         Name="ServiceMadBomb122"',
        '                                                         Height="110"',
        '                                                         Padding="2"',
        '                                                         VerticalAlignment="Top"',
        '                                                         VerticalContentAlignment="Top"/>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Path]:"/>',
        '                                    <TextBox Grid.Column="1"',
        '                                             Name="ServiceOptionPath"/>',
        '                                    <Image Grid.Column="2"',
        '                                           Name="ServiceOptionPathIcon"/>',
        '                                    <Button Grid.Column="3"',
        '                                            Name="ServiceOptionPathBrowse"',
        '                                            Content="Browse"/>',
        '                                    <Button Grid.Column="4"',
        '                                            Name="ServiceOptionPathSet"',
        '                                            Content="Set"/>',
        '                                </Grid>',
        '                                <Button Grid.Row="3"',
        '                                        Name="ServiceOptionApply"',
        '                                        Content="Apply"/>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Options">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Settings">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="130"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Category]:"/>',
        '                                    <ComboBox Grid.Column="1"',
        '                                              Name="SettingSlot"',
        '                                              SelectedIndex="0">',
        '                                        <ComboBoxItem Content="All"/>',
        '                                        <ComboBoxItem Content="Privacy"/>',
        '                                        <ComboBoxItem Content="Windows Update"/>',
        '                                        <ComboBoxItem Content="Service"/>',
        '                                        <ComboBoxItem Content="Context"/>',
        '                                        <ComboBoxItem Content="Taskbar"/>',
        '                                        <ComboBoxItem Content="Start Menu"/>',
        '                                        <ComboBoxItem Content="Explorer"/>',
        '                                        <ComboBoxItem Content="This PC"/>',
        '                                        <ComboBoxItem Content="Desktop"/>',
        '                                        <ComboBoxItem Content="Lock Screen"/>',
        '                                        <ComboBoxItem Content="Miscellaneous"/>',
        '                                        <ComboBoxItem Content="Photo Viewer"/>',
        '                                        <ComboBoxItem Content="Windows Apps"/>',
        '                                    </ComboBox>',
        '                                    <Border Grid.Column="2"',
        '                                            Margin="4"',
        '                                            Background="Black"/>',
        '                                    <Label Grid.Column="3"',
        '                                           Content="[Search]:"',
        '                                           Style="{StaticResource LabelRed}"',
        '                                           HorizontalContentAlignment="Left"/>',
        '                                    <ComboBox Grid.Column="4"',
        '                                              Name="SettingProperty"',
        '                                              SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Name"/>',
        '                                        <ComboBoxItem Content="Description"/>',
        '                                    </ComboBox>',
        '                                    <TextBox Grid.Column="5"',
        '                                             Name="SettingFilter"/>',
        '                                    <Button Grid.Column="6"',
        '                                            Content="Refresh"',
        '                                            Name="SettingRefresh"/>',
        '                                </Grid>',
        '                                <DataGrid Grid.Row="1"',
        '                                          Name="SettingOutput">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridCheckBoxColumn Header="[+]"',
        '                                                                Width="25"',
        '                                                                Binding="{Binding Profile}"/>',
        '                                        <DataGridTextColumn Header="#"',
        '                                                            Width="40"',
        '                                                            Binding="{Binding Index}"/>',
        '                                        <DataGridTextColumn Header="Type"',
        '                                                            Width="100"',
        '                                                            Binding="{Binding Source}"',
        '                                                            IsReadOnly="True"/>',
        '                                        <DataGridTextColumn Header="Name"',
        '                                                            Width="*"',
        '                                                            Binding="{Binding DisplayName}"',
        '                                                            IsReadOnly="True"/>',
        '                                        <DataGridTemplateColumn Header="Value" Width="150">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Value}"',
        '                                                              ItemsSource="{Binding Options}"',
        '                                                              Style="{StaticResource DGCombo}"/>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="90"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="[Profile]:"',
        '                                           Style="{StaticResource LabelGray}"',
        '                                           HorizontalContentAlignment="Left"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="SettingProfileSwitch"/>',
        '                                    <TextBox Grid.Column="2"',
        '                                             Name="SettingProfilePath"/>',
        '                                    <Image Grid.Column="3"',
        '                                           Name="SettingProfilePathIcon"/>',
        '                                    <Button Grid.Column="4"',
        '                                            Name="SettingProfileBrowse"',
        '                                            Content="Browse"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="4">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="SettingOutputApply"',
        '                                            Content="Apply"',
        '                                            IsEnabled="False"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="SettingOutputDontApply"',
        '                                            Content="Do not apply..."',
        '                                            IsEnabled="False"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Options">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[Global]:"/>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="Create Restore Point"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="OptionGlobalRestorePoint"/>',
        '                                    <Border Grid.Column="2"',
        '                                            Margin="4"',
        '                                            Background="Black"/>',
        '                                    <Label Grid.Column="3"',
        '                                           Content="Restart When Done"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="4"',
        '                                              Name="OptionGlobalRestart"/>',
        '                                    <Label Grid.Column="6"',
        '                                           Content="Restart recommended"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="10"/>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="300"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="Show Skipped Items"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="OptionGlobalShowSkipped"/>',
        '                                    <Border Grid.Column="2"',
        '                                            Margin="4"',
        '                                            Background="Black"/>',
        '                                    <Label Grid.Column="3"',
        '                                           Content="Check for Update"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="4"',
        '                                              Name="OptionGlobalVersionCheck"/>',
        '                                    <Label Grid.Column="6"',
        '                                           Content="If found, will run with [current settings]"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="175"/>',
        '                                        <ColumnDefinition Width="25"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0"',
        '                                           Content="Skip Internet Check"',
        '                                           Style="{StaticResource LabelRed}"/>',
        '                                    <CheckBox Grid.Column="1"',
        '                                              Name="OptionGlobalInternetCheck"/>',
        '                                </Grid>',
        '                                <Label Grid.Row="4" Content="[Backup]:" Margin="5"/>',
        '                                <Grid Grid.Row="5">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0"',
        '                                            Name="OptionBackupSave"',
        '                                            Content="Save Settings"/>',
        '                                    <Button Grid.Column="1"',
        '                                            Name="OptionBackupLoad"',
        '                                            Content="Load Settings"/>',
        '                                    <Button Grid.Column="2"',
        '                                            Name="OptionBackupWinDefault"',
        '                                            Content="Windows Default"/>',
        '                                    <Button Grid.Column="3"',
        '                                            Name="OptionBackupResetDefault"',
        '                                            Content="Reset All Items"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Profile">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="10"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Border Grid.Row="0" Background="Black" Margin="4"/>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="120"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="10"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="90"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0" Content="[Profile]:"/>',
        '                            <ComboBox Grid.Column="1"',
        '                                      Name="ProfileType">',
        '                                <ComboBoxItem Content="All"/>',
        '                                <ComboBoxItem Content="System"/>',
        '                                <ComboBoxItem Content="Service"/>',
        '                                <ComboBoxItem Content="User"/>',
        '                            </ComboBox>',
        '                            <Border Grid.Column="2" Background="Black" Margin="4"/>',
        '                            <Label Grid.Column="3"',
        '                                   Content="[Search]:"',
        '                                   Style="{StaticResource LabelRed}"',
        '                                   HorizontalContentAlignment="Left"/>',
        '                            <ComboBox Grid.Column="4"',
        '                                      Name="ProfileSearchProperty"',
        '                                      SelectedIndex="0">',
        '                                <ComboBoxItem Content="Name"/>',
        '                                <ComboBoxItem Content="Sid"/>',
        '                                <ComboBoxItem Content="Account"/>',
        '                                <ComboBoxItem Content="Path"/>',
        '                            </ComboBox>',
        '                            <TextBox Grid.Column="5"',
        '                                     Name="ProfileSearchFilter"/>',
        '                            <Button Grid.Column="6"',
        '                                    Content="Refresh"',
        '                                    Name="ProfileRefresh"/>',
        '                        </Grid>',
        '                        <DataGrid Grid.Row="1"',
        '                                  Name="ProfileOutput">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Sid.Name}"',
        '                                                               TextWrapping="Wrap"',
        '															   FontFamily="Consolas"',
        '                                                               Background="#000000"',
        '                                                               Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                            <Setter Property="ToolTipService.ShowDuration"',
        '                                                    Value="360000000"/>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Account"',
        '                                                    Binding="{Binding Account}"',
        '                                                    Width="200"/>',
        '                                <DataGridTextColumn Header="Path"',
        '                                                    Binding="{Binding Path}"',
        '                                                    Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="120"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Mode]:"/>',
        '                            <ComboBox Grid.Column="1"',
        '                                      Name="ProfileMode">',
        '                                <ComboBoxItem Content="0"/>',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                            </ComboBox>',
        '                            <DataGrid Grid.Column="2"',
        '                                      HeadersVisibility="None"',
        '                                      Name="ProfileModeDescription"',
        '                                      Margin="10">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                        Binding="{Binding Name}"',
        '                                                        Width="80"/>',
        '                                    <DataGridTextColumn Header="Description"',
        '                                                        Binding="{Binding Description}"',
        '                                                        Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <ComboBox Grid.Column="3" Name="ProfileProcess">',
        '                                <ComboBoxItem Content="0"/>',
        '                                <ComboBoxItem Content="1"/>',
        '                            </ComboBox>',
        '                            <DataGrid Grid.Column="4"',
        '                                      HeadersVisibility="None"',
        '                                      Name="ProfileProcessDescription"',
        '                                      Margin="10">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"',
        '                                                        Binding="{Binding Name}"',
        '                                                        Width="80"/>',
        '                                    <DataGridTextColumn Header="Description"',
        '                                                        Binding="{Binding Description}"',
        '                                                        Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                        <TabControl Grid.Row="3">',
        '                            <TabItem Header="Sid">',
        '                                <DataGrid Name="ProfileSid">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Value}"',
        '                                                                       TextWrapping="Wrap"',
        '															           FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
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
        '                                                            Width="100"/>',
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
        '                            </TabItem>',
        '                            <TabItem Header="Property">',
        '                                <DataGrid Name="ProfileProperty">',
        '                                    <DataGrid.RowStyle>',
        '                                        <Style TargetType="{x:Type DataGridRow}">',
        '                                            <Style.Triggers>',
        '                                                <Trigger Property="IsMouseOver" Value="True">',
        '                                                    <Setter Property="ToolTip">',
        '                                                        <Setter.Value>',
        '                                                            <TextBlock Text="{Binding Value}"',
        '                                                                       TextWrapping="Wrap"',
        '															           FontFamily="Consolas"',
        '                                                                       Background="#000000"',
        '                                                                       Foreground="#00FF00"/>',
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
        '                                                            Width="300"/>',
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
        '                            </TabItem>',
        '                            <TabItem Header="Content">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="110"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="10"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label Grid.Column="0"',
        '                                               Content="[Path]:"',
        '                                               Style="{StaticResource LabelGray}"',
        '                                               HorizontalContentAlignment="Left"/>',
        '                                        <TextBox Grid.Column="1"',
        '                                                 Name="ProfilePath"/>',
        '                                        <Label Grid.Column="2"',
        '                                               Content="[Count/Size]:"/>',
        '                                        <TextBox Grid.Column="3"',
        '                                                 Name="ProfileCount"/>',
        '                                        <TextBox Grid.Column="4"',
        '                                                 Name="ProfileSize"/>',
        '                                        <Border Grid.Column="5"',
        '                                                Background="Black"',
        '                                                Margin="4"/>',
        '                                        <Button Grid.Column="6"',
        '                                                Name="ProfileLoad"',
        '                                                Content="Load"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1"',
        '                                              Name="ProfileContent">',
        '                                        <DataGrid.RowStyle>',
        '                                            <Style TargetType="{x:Type DataGridRow}">',
        '                                                <Style.Triggers>',
        '                                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                                        <Setter Property="ToolTip">',
        '                                                            <Setter.Value>',
        '                                                                <TextBlock Text="{Binding Fullname}"',
        '                                                                           TextWrapping="Wrap"',
        '                                                                           FontFamily="Consolas"',
        '                                                                           Background="#000000"',
        '                                                                           Foreground="#00FF00"/>',
        '                                                            </Setter.Value>',
        '                                                        </Setter>',
        '                                                        <Setter Property="ToolTipService.ShowDuration"',
        '                                                                Value="360000000"/>',
        '                                                    </Trigger>',
        '                                                </Style.Triggers>',
        '                                            </Style>',
        '                                        </DataGrid.RowStyle>',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"',
        '                                                                Binding="{Binding Type}"',
        '                                                                Width="75"/>',
        '                                            <DataGridTextColumn Header="Created"',
        '                                                                Binding="{Binding Created}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Accessed"',
        '                                                                Binding="{Binding Accessed}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Modified"',
        '                                                                Binding="{Binding Modified}"',
        '                                                                Width="135"/>',
        '                                            <DataGridTextColumn Header="Size"',
        '                                                                Binding="{Binding Size}"',
        '                                                                Width="75"/>',
        '                                            <DataGridTextColumn Header="Name"',
        '                                                                Binding="{Binding Name}"',
        '                                                                Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="25"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label Grid.Column="0"',
        '                                               Content="[Target]:"',
        '                                               Style="{StaticResource LabelGray}"',
        '                                               HorizontalContentAlignment="Left"/>',
        '                                        <TextBox Grid.Column="1"',
        '                                                 Name="ProfileTarget"/>',
        '                                        <Image Grid.Column="2"',
        '                                               Name="ProfileTargetIcon"/>',
        '                                        <Button Grid.Column="3"',
        '                                                Name="ProfileBrowse"',
        '                                                Content="Browse"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
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
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="{Binding String}"',
        '                                                           TextWrapping="Wrap"',
        '                                                           FontFamily="Consolas"',
        '                                                           Background="#000000"',
        '                                                           Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                        <Setter Property="ToolTipService.ShowDuration"',
        '                                                Value="360000000"/>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Index"',
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
            Return "<FEModule.ViperBomb.XamlWindow>"
        }
    }

    # // ==================
    # // | System Objects |
    # // ==================

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
            Return "<FEModule.ViperBomb.System.Snapshot>"
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
            Return "<FEModule.ViperBomb.System.BiosInformation>"
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
            Return "<FEModule.ViperBomb.System.OperatingSystem>"
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
            Return "<FEModule.ViperBomb.System.ComputerSystem>"
        }
    }

    Enum SystemEditionType
    {
        v1507
        v1511
        v1607
        v1703
        v1709
        v1803
        v1903
        v1909
        v2004
        v20H2
        v21H1
        v21H2
        v22H2
    }

    Class SystemEditionItem
    {
        [UInt32]       $Index
        [String]        $Name
        [UInt32]       $Build
        [String]    $Codename
        [String] $Description
        SystemEditionItem([String]$Name)
        {
            $This.Index = [UInt32][SystemEditionType]::$Name
            $This.Name  = [SystemEditionType]::$Name
        }
        Inject([String]$Line)
        {
            $Split            = $Line -Split ","
            $This.Build       = $Split[0]
            $This.Codename    = $Split[1]
            $This.Description = $Split[2]
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class SystemEditionController
    {
        [String]            $Id
        [String]         $Label
        [Object]       $Current
        [Object]      $Property
        Hidden [Object] $Output
        SystemEditionController()
        {
            $This.Refresh()
        }
        [Object] GenericProperty([UInt32]$Index,[Object]$Property)
        {
            Return [GenericProperty]::New($Index,$Property)
        }
        [Object] SystemEditionItem([String]$Name)
        {
            Return [SystemEditionItem]::New($Name)
        }
        [Object] GetCurrentVersion()
        {
            Return Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        }
        Clear()
        {
            $This.Property = @( )
            $This.Output   = @( )
        }
        Refresh()
        {
            $This.Clear()
            
            ForEach ($Name in [System.Enum]::GetNames([SystemEditionType]))
            {
                $Item = $This.SystemEditionItem($Name)
                $Line = Switch ($Item.Name)
                {
                    v1507 { "10240,Threshold 1,Release To Manufacturing"  }
                    v1511 { "10586,Threshold 2,November Update"           }
                    v1607 { "14393,Redstone 1,Anniversary Update"         }
                    v1703 { "15063,Redstone 2,Creators Update"            }
                    v1709 { "16299,Redstone 3,Fall Creators Update"       }
                    v1803 { "17134,Redstone 4,April 2018 Update"          }
                    v1809 { "17763,Redstone 5,October 2018 Update"        }
                    v1903 { "18362,19H1,May 2019 Update"                  }
                    v1909 { "18363,19H2,November 2019 Update"             }
                    v2004 { "19041,20H1,May 2020 Update"                  }
                    v20H2 { "19042,20H2,October 2020 Update"              }
                    v21H1 { "19043,21H1,May 2021 Update"                  }
                    v21H2 { "19044,21H2,November 2021 Update"             }
                    v22H2 { "19045,22H2,2022 Update"                      }
                }

                $Item.Inject($Line)
                $This.Output += $Item
            }

            ForEach ($Property in $This.GetCurrentVersion().PSObject.Properties | ? Name -notmatch ^PS)
            {
                $This.Add($Property)
            }

            $This.Id      = $This.Get("DisplayVersion") | % Value
            $This.Label   = "v{0}" -f $This.Id
            $This.Current = $This.Output | ? Codename -eq $This.Id
        }
        Add([Object]$Property)
        {
            $This.Property += $this.GenericProperty($This.Property.Count,$Property)
        }
        [Object] Get([String]$Name)
        {
            Return $This.Property | ? Name -eq $Name
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.System.Edition.Controller>"
        }
    }

    # // ======================
    # // | Processor Controls |
    # // ======================

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
            Return "<FEModule.ViperBomb.System.Processor.Controller>"
        }
    }

    # // =================
    # // | Disk Controls |
    # // =================

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
            Return "<FEModule.ViperBomb.System..Partition[Item]>"
        }
    }

    Class SystemPartitionList : GenericList
    {
        SystemPartitionList([Switch]$Flags,[String]$Name) : base($Name)
        {
            
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.System.Partition[List]>"
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
            Return "<FEModule.ViperBomb.System.Volume[Item]>"
        }
    }

    Class SystemVolumeList : GenericList
    {
        SystemVolumeList([Switch]$Flags,[String]$Name) : base($Name)
        {
            
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.System.Volume[List]>"
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
            Return "<FEModule.ViperBomb.System.Disk[Item]>"
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
            Return "<FEModule.ViperBomb.System.Disk.Controller>"
        }
    }

    # // ====================
    # // | Network Controls |
    # // ====================

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
            Return "<FEModule.ViperBomb.System.NetworkState[List]>"
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
            Return "<FEModule.ViperBomb.System.Network[Item]>"
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
            Return "<FEModule.ViperBomb.System.Network.Controller>"
        }
    }

    Class SystemController
    {
        Hidden [Object] $Module
        [Object]      $Snapshot
        [Object]          $Bios
        [Object]            $OS
        [Object]      $Computer
        [Object]       $Edition
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
            $This.Edition   = $This.Get("Edition")
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
                Edition
                {
                    [SystemEditionController]::New()
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
            Return "<FEModule.ViperBomb.System.Controller>"
        }
    }

    # // ===================
    # // | HotFix Controls |
    # // ===================

    Enum HotFixStateType
    {
        Installed
        Remove
        Install
    }

    Class HotFixStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        HotFixStateItem([String]$Name)
        {
            $This.Index = [UInt32][HotFixStateType]::$Name
            $This.Name  = [HotFixStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class HotFixStateList
    {
        [Object] $Output
        HotFixStateList()
        {
            $This.Refresh()
        }
        [Object] HotFixStateItem([String]$Name)
        {
            Return [HotFixStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([HotFixStateType]))
            {
                $Item             = $This.HotFixStateItem($Name)
                $Item.Label       = @("[X]","[!]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    Installed { "HotFix is currently installed" }
                    Remove    { "HotFix will be removed"        }
                    Install   { "HotFix will be installed"      }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.HotFix.State[List]>"
        }
    }

    Class HotFixItem
    {
        [UInt32]         $Index
        [UInt32]       $Profile
        [String]        $Source
        [String]      $HotFixID
        [String]   $Description
        [String]   $InstalledBy
        [String]   $InstalledOn
        [Object]         $State
        [Object]        $Target
        [String]        $Status
        HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            $This.Index       = $Index
            $This.Source      = $HotFix.PSComputerName
            $This.Description = $HotFix.Description
            $This.HotFixID    = $HotFix.HotFixID
            $This.InstalledBy = $HotFix.InstalledBy
            $This.InstalledOn = ([DateTime]$HotFix.InstalledOn).ToString("MM/dd/yyyy")

            $This.SetStatus()
        }
        SetState([Object]$State)
        {
            $This.State       = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile     = $xProfile
            $This.Target      = $Target
        }
        SetStatus()
        {
            $This.Status      = "[HotFix]: {0} {1}" -f $This.InstalledOn, $This.HotFixId
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.HotFix[Item]>"
        }
    }

    Class HotFixController : GenericProfileController
    {
        Hidden [Object] $State
        HotFixController([String]$Name) : Base($Name)
        {
            $This.State = $This.HotFixStateList()
        }
        [Object[]] GetObject()
        {
            Return Get-HotFix | Sort-Object InstalledOn
        }
        [Object] HotFixStateList()
        {
            Return [HotFixStateList]::New()
        }
        [Object] HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            Return [HotFixItem]::New($Index,$Hotfix)
        }
        [Object] New([Object]$Hotfix)
        {
            $Item   = $This.HotFixItem($This.Output.Count,$HotFix)

            $Item.SetState($This.State.Output[0])

            $Target = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$This.State.Output[0])
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()
            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($HotFix in $This.GetObject())
            {
                $Item = $This.New($HotFix)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.HotFix.Controller>"
        }
    }

    # // =============================
    # // | Optional Feature Controls |
    # // =============================

    Enum FeatureStateType
    {
        Disabled
        DisabledWithPayloadRemoved
        Enabled
    }

    Class FeatureStateSlot
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        FeatureStateSlot([String]$Name)
        {
            $This.Index = [UInt32][FeatureStateType]::$Name
            $This.Name  = [FeatureStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class FeatureStateList
    {
        [Object] $Output
        FeatureStateList()
        {
            $This.Refresh()
        }
        [Object] FeatureStateSlot([String]$Name)
        {
            Return [FeatureStateSlot]::New($Name)
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([FeatureStateType]))
            {
                $Item             = $This.FeatureStateSlot($Name)
                $Item.Label       = @("[_]","[X]","[+]")[$Item.Index]
                $Item.Description = Switch ($Name)
                {
                    Disabled                   { "Feature is disabled"                     }
                    DisabledWithPayloadRemoved { "Feature is disabled, payload is removed" }
                    Enabled                    { "Feature is enabled"                      }
                }

                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Feature.State[List]>"
        }
    }

    Class FeatureItem
    {
        [UInt32]                   $Index
        [UInt32]                 $Profile
        [String]             $FeatureName
        [Object]                   $State
        [String]             $Description
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [String]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        [Object]                  $Target
        [String]                  $Status
        FeatureItem([UInt32]$Index,[Object]$Feature)
        {
            $This.Index            = $Index
            $This.FeatureName      = $Feature.FeatureName
            $This.Path             = $Feature.Path
            $This.Online           = $Feature.Online
            $This.WinPath          = $Feature.WinPath
            $This.SysDrivePath     = $Feature.SysDrivePath
            $This.RestartNeeded    = $Feature.RestartNeeded
            $This.LogPath          = $Feature.LogPath
            $This.ScratchDirectory = $Feature.ScratchDirectory
            $This.LogLevel         = $Feature.LogLevel
        }
        SetStatus()
        {
            $This.Status  = "[Feature]: {0} {1}" -f $This.State.Label, $This.FeatureName
        }
        SetState([Object]$State)
        {
            $This.State   = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile = $xProfile
            $This.Target  = $Target
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Feature[Item]>"
        }
    }

    Class FeatureController : GenericProfileController
    {
        Hidden [Object] $State
        FeatureController([String]$Name) : Base($Name)
        {
            $This.State   = $This.FeatureStateList()
        }
        [Object[]] GetObject()
        {
            Return Get-WindowsOptionalFeature -Online | Sort-Object FeatureName 
        }
        [Object] FeatureStateList()
        {
            Return [FeatureStateList]::New()
        }
        [Object] FeatureItem([UInt32]$Index,[Object]$Feature)
        {
            Return [FeatureItem]::New($Index,$Feature)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Feature in $This.GetObject())
            {
                $Item = $This.New($Feature)

                $This.Add($Item)
            }
        }
        [Object] New([Object]$Feature)
        {
            $Item             = $This.FeatureItem($This.Output.Count,$Feature)
            $Item.State       = $This.State.Output | ? Name -eq $Feature.State
            $Item.Description = Switch ($Item.FeatureName)
            {
                AppServerClient
                {
                    "Apparently this is related to [Parallels], which is a virtualization pack"+
                    "age related to MacOS."
                }
                Client-DeviceLockdown
                {
                    "Allows supression of Windows elements that appear when Windows starts or r"+
                    "esumes."
                }
                Client-EmbeddedBootExp
                {
                    "Allows supression of Windows elements that appear when Windows starts or re"+
                    "sumes."
                }
                Client-EmbeddedLogon
                {
                    "Allows use of custom logon feature to suppress Windows 10 UI elements relat"+
                    "ed to (Welcome/shutdown) screen."
                }
                Client-EmbeddedShellLauncher
                {
                    "Enables OEMs to set a (classic/non-UWP) app as the [system shell]."
                }
                ClientForNFS-Infrastructure
                {
                    "Client for (NFS/Network File System) allowing file transfers between (W"+
                    "indows Server/UNIX)."
                }
                Client-KeyboardFilter
                {
                    "Enables controls that you can use to suppress undesirable key presses or ke"+
                    "y combinations."
                }
                Client-ProjFS
                {
                    "Windows Projected File System (ProjFS) allows user-mode application provi"+
                    "der(s) to project hierarchical data from a backing data store into the fi"+
                    "le system, making it [appear] as files and directories in the file system."
                }
                Client-UnifiedWriteFilter
                {
                    "Helps to protect device configuration by (intercepting/redirecting) any wri"+
                    "tes to the drive (app installations, settings changes, saved data) to a vir"+
                    "tual overlay."
                }
                Containers
                {
                    "Required to provide (services/tools) to (create/manage) [Windows Server"+
                    " Containers]."
                }
                Containers-DisposableClientVM
                {
                    "Windows Sandbox provides a lightweight desktop environment to safely run "+
                    "applications in isolation."
                }
                DataCenterBridging
                {
                    "Standards developed by IEEE for data centers."
                }
                DirectoryServices-ADAM-Client
                {
                    "(ADAM/Active Directory Application Mode)"
                }
                DirectPlay
                {
                    "DirectPlay is part of Microsoft's DirectX API. It is a network communication"+
                    " library intended for computer game development, although it can be used for"+
                    " other purposes."
                }
                HostGuardian
                {
                    "(HGS/Host Guardian Service) is the centerpiece of the guarded fabric soluti"+
                    "on. It ensures that Hyper-V hosts in the fabric are known to the [hoster/en"+
                    "terprise], running [trusted software], and [managing key protectors] for [s"+
                    "hielded VMs]."
                }
                HypervisorPlatform
                {
                    "Used for Hyper-V and/or other virtualization software, allows hardware ba"+
                    "sed virtualization components to be used."
                }
                IIS-ApplicationDevelopment
                {
                    "(IIS/Internet Information Services) for application development."
                }
                IIS-ApplicationInit
                {
                    "(IIS/Internet Information Services) for allowing application initialization."
                }
                IIS-ASP
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages)."
                }
                IIS-ASPNET
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                    "that use the .NET Framework prior to v4.5."
                }
                IIS-ASPNET45
                {
                    "(IIS/Internet Information Services) for enabling (ASP/Active Server Pages) "+
                    "that use .NET Framework v4.5+."
                }
                IIS-BasicAuthentication
                {
                    "(IIS/Internet Information Services) for enabling basic-authentication."
                }
                IIS-CertProvider
                {
                    "(IIS/Internet Information Services) for enabling the certificate provider."
                }
                IIS-CGI
                {
                    "(IIS/Internet Information Services) for enabling (CGI/Common Gateway Interface)."
                }
                IIS-ClientCertificateMappingAuthentication
                {
                    "(IIS/Internet Information Services) for enabling client-based certificate "+
                    "mapping authentication."
                }
                IIS-CommonHttpFeatures
                {
                    "(IIS/Internet Information Services) for common HTTP features."
                }
                IIS-CustomLogging
                {
                    "(IIS/Internet Information Services) for enabling custom logging."
                }
                IIS-DefaultDocument
                {
                    "(IIS/Internet Information Services) for allowing default (website/document) "+
                    "model."
                }
                IIS-DigestAuthentication
                {
                    "(IIS/Internet Information Services) for enabling digest authentication."
                }
                IIS-DirectoryBrowsing
                {
                    "(IIS/Internet Information Services) for allowing directory browsing to be used."
                }
                IIS-FTPExtensibility
                {
                    "(IIS/Internet Information Services) for enabling the FTP service/server ext"+
                    "ensions."
                }
                IIS-FTPServer
                {
                    "(IIS/Internet Information Services) for enabling the FTP server."
                }
                IIS-FTPSvc
                {
                    "(IIS/Internet Information Services) for enabling the FTP service."
                }
                IIS-HealthAndDiagnostics
                {
                    "(IIS/Internet Information Services) for health and diagnostics."
                }
                IIS-HostableWebCore
                {
                    "(WAS/Windows Activation Service) for the hostable web core package."
                }
                IIS-HttpCompressionDynamic
                {
                    "(IIS/Internet Information Services) for dynamic compression components."
                }
                IIS-HttpCompressionStatic
                {
                    "(IIS/Internet Information Services) for enabling static HTTP compression."
                }
                IIS-HttpErrors
                {
                    "(IIS/Internet Information Services) for handling HTTP errors."
                }
                IIS-HttpLogging
                {
                    "(IIS/Internet Information Services) for HTTP logging."
                }
                IIS-HttpRedirect
                {
                    "(IIS/Internet Information Services) for HTTP redirection, similar to [WebDAV]."
                }
                IIS-HttpTracing
                {
                    "(IIS/Internet Information Services) for tracing HTTP requests/etc."
                }
                IIS-IIS6ManagementCompatibility
                {
                    "(IIS/Internet Information Services) for compatibility with IIS6*"
                }
                IIS-IISCertificateMappingAuthentication
                {
                    "(IIS/Internet Information Services) for enabling IIS-based certificate map"+
                    "ping authentication."
                }
                IIS-IPSecurity
                {
                    "(IIS/Internet Information Services) for Internet Protocol security."
                }
                IIS-ISAPIExtensions
                {
                    "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                    "ication Programming Interface) extensions."
                }
                IIS-ISAPIFilter
                {
                    "(IIS/Internet Information Services) for enabling (ISAPI/Internet Server Appl"+
                    "ication Programming Interface) filters."
                }
                IIS-LegacyScripts
                {
                    "(IIS/Internet Information Services) for enabling legacy scripts."
                }
                IIS-LegacySnapIn
                {
                    "(IIS/Internet Information Services) for enabling legacy snap-ins."
                }
                IIS-LoggingLibraries
                {
                    "(IIS/Internet Information Services) for logging libraries."
                }
                IIS-ManagementConsole
                {
                    "(IIS/Internet Information Services) for enabling the management console."
                }
                IIS-ManagementScriptingTools
                {
                    "(IIS/Internet Information Services) for webserver management scripting."
                }
                IIS-ManagementService
                {
                    "(IIS/Internet Information Services) for enabling the management service."
                }
                IIS-Metabase
                {
                    "(IIS/Internet Information Services) for (metadata/metabase)."
                }
                IIS-NetFxExtensibility
                {
                    "(IIS/Internet Information Services) for .NET Framework extensibility."
                }
                IIS-NetFxExtensibility45
                {
                    "(IIS/Internet Information Services) for .NET Framework v4.5+ extensibility."
                }
                IIS-ODBCLogging
                {
                    "(IIS/Internet Information Services) for enabling (ODBC/Open Database Conne"+
                    "ctivity) logging."
                }
                IIS-Performance
                {
                    "(IIS/Internet Information Services) for performance-related components."
                }
                IIS-RequestFiltering
                {
                    "(IIS/Internet Information Services) for request-filtering."
                }
                IIS-RequestMonitor
                {
                    "(IIS/Internet Information Services) for monitoring HTTP requests."
                }
                IIS-Security
                {
                    "(IIS/Internet Information Services) for security-related functions."
                }
                IIS-ServerSideIncludes
                {
                    "(IIS/Internet Information Services) for enabling server-side includes."
                }
                IIS-StaticContent
                {
                    "(IIS/Internet Information Services) for enabling static webserver content."
                }
                IIS-URLAuthorization
                {
                    "(IIS/Internet Information Services) for authorizing (URL/Universal Resource"+
                    " Locator)(s)"
                }
                IIS-WebDAV
                {
                    "(IIS/Internet Information Services) for enabling the (WebDAV/Web Distributed"+
                    " Authoring and Versioning) interface."
                }
                IIS-WebServer
                {
                    "(IIS/Internet Information Services) [Web Server], installs the prerequisites"+
                    " to run an IIS web server."
                }
                IIS-WebServerManagementTools
                {
                    "(IIS/Internet Information Services) for webserver management tools."
                }
                IIS-WebServerRole
                {
                    "(IIS/Internet Information Services) [Web Server Role], enables the role for "+
                    "running an IIS web server."
                }
                IIS-WebSockets
                {
                    "(IIS/Internet Information Services) for enabling web-based sockets."
                }
                IIS-WindowsAuthentication
                {
                    "(IIS/Internet Information Services) for enabling Windows account authentication."
                }
                IIS-WMICompatibility
                {
                    "(IIS/Internet Information Services) for (WMI/Windows Management Instrumenta"+
                    "tion) compatibility/interop."
                }
                Internet-Explorer-Optional-amd64
                {
                    "Internet Explorer"
                }
                LegacyComponents
                {
                    "[DirectPlay] - Part of the [DirectX] application programming interface."
                }
                MediaPlayback
                {
                    "(WMP/Windows Media Player) allows media playback."
                }
                Microsoft-Hyper-V
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-All
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Hypervisor
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Management-Clients
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Management-PowerShell
                {
                    "(Hyper-V/Veridian) + [PowerShell]"
                }
                Microsoft-Hyper-V-Services
                {
                    "(Hyper-V/Veridian)"
                }
                Microsoft-Hyper-V-Tools-All
                {
                    "(Hyper-V/Veridian)"
                }
                MicrosoftWindowsPowerShellV2
                {
                    "[PowerShell]"
                }
                MicrosoftWindowsPowerShellV2Root
                {
                    "[PowerShell]"
                }
                Microsoft-Windows-Subsystem-Linux
                {
                    "Installs prerequisites for installing console-based Linux vitual machines."
                }
                MSMQ-ADIntegration
                {
                    "(MSMQ/Microsoft Message Queue Server) for (AD/Active Directory) integration."
                }
                MSMQ-Container
                {
                "(MSMQ/Microsoft Message Queue Server) for enabling the container."
                }
                MSMQ-DCOMProxy
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling the (DCOM/Distributed CO"+
                    "M) proxy."
                }
                MSMQ-HTTP
                {
                    "(MSMQ/Microsoft Message Queue Server) for HTTP integration."
                }
                MSMQ-Multicast
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling multicast."
                }
                MSMQ-Server
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling the server."
                }
                MSMQ-Triggers
                {
                    "(MSMQ/Microsoft Message Queue Server) for enabling (trigger events/tasks)."
                }
                MSRDC-Infrastructure
                {
                    "(MSRDC/Microsoft Remote Desktop Client)."
                }
                MultiPoint-Connector
                {
                    "(Connector) MultiPoint Services allows multiple users to simultaneously sh"+
                    "are one computer."
                }
                MultiPoint-Connector-Services
                {
                    "(Services) MultiPoint Services allows multiple users to simultaneously sha"+
                    "re one computer."
                }
                MultiPoint-Tools
                {
                    "(Tools) MultiPoint Services allows multiple users to simultaneously share "+
                    "one computer."
                }
                NetFx3
                {
                    "(.NET Framework v3.*) This feature is needed to run applications that are wr"+
                    "itten for various versions of .NET. Windows automatically installs them when"+
                    " required."
                }
                NetFx4-AdvSrvs
                {
                    "(.NET Framework v4.*)."
                }
                NetFx4Extended-ASPNET45
                {
                    "(.NET Framework v4.*) with extensions for ASP.NET Framework v4.5+."
                }
                NFS-Administration
                {
                    "(NFS/Network File System)"
                }
                Printing-Foundation-Features
                {
                    "Allows use of (IPC/Internet Printing Client), (LPD/Line printer daemon), a"+
                    "nd (LPR/Line printer remote) for using printers over the (internet/LAN)."
                }
                Printing-Foundation-InternetPrinting-Client
                {
                    "(IPC/Internet Printing Client) helps you print files from a web browser us"+
                    "ing a (connected/shared) printer on the (internet/LAN)."
                }
                Printing-Foundation-LPDPrintService
                {
                    "(LPD/Line printer daemon) printer sharing service."
                }
                Printing-Foundation-LPRPortMonitor
                {
                    "(LPR/Line printer remote) port monitor service."
                }
                Printing-PrintToPDFServices-Features
                {
                    "Allows documents to be printed to (*.pdf) file(s)"
                }
                Printing-XPSServices-Features
                {
                    "Allows documents to be printed to (*.xps) file(s)"
                }
                SearchEngine-Client-Package
                {
                    "Windows searching & indexing."
                }
                ServicesForNFS-ClientOnly
                {
                    "Services for (NFS/Network File System) allowing file transfers between "+
                    "(Windows Server/UNIX)."
                }
                SimpleTCP
                {
                    "Collection of old command-line tools that include character generator, dayti"+
                    "me, discard, echo, etc."
                }
                SMB1Protocol
                {
                    "(SMB/Server Message Block) network protocol."
                }
                SMB1Protocol-Client
                {
                    "(SMB/Server Message Block) client network protocol."
                }
                SMB1Protocol-Deprecation
                {
                    "(SMB/Server Message Block)."
                }
                SMB1Protocol-Server
                {
                    "(SMB/Server Message Block) server network protocol."
                }
                SmbDirect
                {
                    "(SMB/Server Message Block)."
                }
                TelnetClient
                {
                    "Installs the [TELNET] legacy application."
                }
                TFTP
                {
                    "A command-line tool that can be used to transfer files via the [Trivial File"+
                    " Transfer Protocol]."
                }
                TIFFIFilter
                {
                    "Index-and-search (TIFF/Tagged Image File Format) used for Optional Charact"+
                    "er Recognition."
                }
                VirtualMachinePlatform
                {
                    "Used for Hyper-V and managing individual virtual machines."
                }
                WAS-ConfigurationAPI
                {
                    "(WAS/Windows Activation Service) for using the configuration API."
                }
                WAS-NetFxEnvironment
                {
                    "(WAS/Windows Activation Service) for using .NET Framework elements."
                }
                WAS-ProcessModel
                {
                    "(WAS/Windows Activation Service) for the process model WAS uses."
                }
                WAS-WindowsActivationService
                {
                    "(WAS/Windows Activation Service) Used for message-based applications and co"+
                    "mponents that are related to Internet Information Services (IIS)."
                }
                WCF-HTTP-Activation
                {
                    "(WCF/Windows Communication Foundation) for [HTTP Activation], used for messa"+
                    "ge-based applications and components that are related to Internet Informatio"+
                    "n Services (IIS)."
                }
                WCF-HTTP-Activation45
                {
                    "(WCF/Windows Communication Foundation) for HTTP activation that use .NET Fra"+
                    "mework v4.5+."
                }
                WCF-MSMQ-Activation45
                {
                    "(WCF/Windows Communication Foundation) for MSMQ activation that use .NET Fra"+
                    "mework v4.5+."
                }
                WCF-NonHTTP-Activation
                {
                    "Windows Communication Foundation [Non-HTTP Activation], used for message-bas"+
                    "ed applications and components that are related to Internet Information Serv"+
                    "ices (IIS)."
                }
                WCF-Pipe-Activation45
                {
                    "(WCF/Windows Communication Foundation) for named-pipe activation that use .N"+
                    "ET Framework v4.5+."
                }
                WCF-Services45
                {
                    "(WCF/Windows Communication Foundation) services that use .NET Framework v4.5+"
                }
                WCF-TCP-Activation45
                {
                    "(WCF/Windows Communication Foundation) for TCP activation that use .NET Fram"+
                    "ework v4.5+."
                }
                WCF-TCP-PortSharing45
                {
                    "(WCF/Windows Communication Foundation) for TCP port sharing that use .NET Fr"+
                    "amework v4.5+."
                }
                Windows-Defender-ApplicationGuard
                {
                    "(WDAG/Windows Defender Application Guard) uses [Hyper-V] to run [Micros"+
                    "oft Edge] in an isolated container."
                }
                Windows-Defender-Default-Definitions
                {
                    "Default [Windows Defender] definitions."
                }
                Windows-Identity-Foundation
                {
                    "A software framework for building identity-aware applications. The .NET Fram"+
                    "ework 4.5 includes a newer version of this framework."
                }
                WindowsMediaPlayer
                {
                    "(WMP/Windows Media Player) enables the integrated media player."
                }
                WorkFolders-Client
                {
                    "Windows Server role service for file servers."
                }
                Default
                {
                    "Unknown"
                }
            }

            $xState = $This.State.Output | ? Name -eq $Feature.State
            $Item.SetState($xState)

            $Target = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$xState)
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()

            Return $Item
        }
        [String[]] ResourceLinks()
        {
            Return "https://www.thewindowsclub.com/windows-10-optional-features-explained",
            "https://en.wikipedia.org/wiki/"
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Feature.Controller>"
        }
    }
    
    # // =================
    # // | AppX Controls |
    # // =================

    Enum AppXStateType
    {
        Installed
        Remove
        Install
    }
        
    Class AppXStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        AppXStateItem([String]$Name)
        {
            $This.Index  = [UInt32][AppXStateType]::$Name
            $This.Name   = [AppXStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
        
    Class AppXStateList
    {
        [Object] $Output
        AppXStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] AppXStateItem([String]$Name)
        {
            Return [AppXStateItem]::New($Name)
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([AppXStateType]))
            {
                $Item             = $This.AppXStateItem($Name)
                $Item.Label       = @("[X]","[!]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Index)
                {
                    0 { "[AppX] application is installed." }
                    1 { "Remove this [AppX] application."  }
                    2 { "Install this [AppX] applicaiton." }
                }

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.AppX.State[List]>"
        }
    }

    Class AppXItem
    {
        [UInt32]                   $Index
        [UInt32]                 $Profile
        [String]             $DisplayName
        [String]             $Description
        [String]             $PackageName
        [String]                 $Version
        [String]             $PublisherID
        [Object]                   $State
        Hidden [UInt32]     $MajorVersion
        Hidden [UInt32]     $MinorVersion
        Hidden [UInt32]            $Build
        Hidden [UInt32]         $Revision
        Hidden [UInt32]     $Architecture
        Hidden [String]       $ResourceID
        Hidden [String]  $InstallLocation
        Hidden [Object]          $Regions
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [String]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        [Object]                  $Target
        [String]                  $Status
        AppXItem([UInt32]$Index,[Object]$AppX)
        {
            $This.Index            = $Index
            $This.Version          = $AppX.Version
            $This.PackageName      = $AppX.PackageName
            $This.DisplayName      = $AppX.DisplayName
            $This.PublisherId      = $AppX.PublisherId
            $This.MajorVersion     = $AppX.MajorVersion
            $This.MinorVersion     = $AppX.MinorVersion
            $This.Build            = $AppX.Build
            $This.Revision         = $AppX.Revision
            $This.Architecture     = $AppX.Architecture
            $This.ResourceId       = $AppX.ResourceId
            $This.InstallLocation  = $AppX.InstallLocation
            $This.Regions          = $AppX.Regions
            $This.Path             = $AppX.Path
            $This.Online           = $AppX.Online
            $This.WinPath          = $AppX.WinPath
            $This.SysDrivePath     = $AppX.SysDrivePath
            $This.RestartNeeded    = $AppX.RestartNeeded
            $This.LogPath          = $AppX.LogPath
            $This.ScratchDirectory = $AppX.ScratchDirectory
            $This.LogLevel         = $AppX.LogLevel
        }
        SetState([Object]$State)
        {
            $This.State            = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile          = $xProfile
            $This.Target           = $Target
        }
        SetStatus()
        {
            $This.Status           = "[AppX]: {0}" -f $This.DisplayName
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.AppX[Item]>"
        }
    }

    Class AppXController : GenericProfileController
    {
        Hidden [Object] $State
        AppXController([String]$Name) : Base($Name)
        {
            $This.State   = $This.AppXStateList()
        }
        [Object[]] GetObject()
        {
            Return Get-AppxProvisionedPackage -Online | Sort-Object DisplayName
        }
        [Object] AppXItem([UInt32]$Index,[Object]$AppX)
        {
            Return [AppXItem]::New($Index,$AppX)
        }
        [Object] AppXStateList()
        {
            Return [AppXStateList]::New()
        }
        [Object] New([Object]$AppX)
        {
            $Item             = $This.AppXItem($This.Output.Count,$AppX)
            $Item.Description = Switch ($Item.DisplayName)
            {
                "Microsoft.549981C3F5F10"
                {
                    "[Cortana], your personal productivity assistant, helps you stay on"+
                    " top of what matters and save time finding what you need."
                }
                "Microsoft.BingWeather"
                {
                    "[MSN Weather], get a [Microsoft Edge] on the latest weather condit"+
                    "ions, see (10-day/hourly) forecasts."
                }
                "Microsoft.DesktopAppInstaller"
                {
                    "[WinGet Package Manager], allows developers to install (*.appx/*.a"+
                    "ppxbundle) files on their [Windows PC] without (PowerShell/CMD)."
                }
                "Microsoft.GetHelp"
                {
                    "[Get-Help] command for [PowerShell], but also GUI driven help."
                }
                "Microsoft.Getstarted"
                {
                    "In order to get down to business with [Office 365], you can use th"+
                    "is to get started."
                }
                "Microsoft.HEIFImageExtension"
                {
                    "Allows users to view [HEIF images] on [Windows]."
                }
                "Microsoft.Microsoft3DViewer"
                {
                    "Allows users to (view/interact) with 3D models on your device."
                }
                "Microsoft.MicrosoftEdge.Stable"
                {
                    "[Microsoft Edge] is a [Chromium]-based web browser, which offers m"+
                    "any improvements over [Internet Explorer]."
                }
                "Microsoft.MicrosoftOfficeHub"
                {
                    "Central location for all your [Microsoft Office] apps."
                }
                "Microsoft.MicrosoftSolitaireCollection"
                {
                    "Collection of card games including [Klondike], [Spider], [FreeCell"+
                    "], [Pyramid], and [TriPeaks]."
                }
                "Microsoft.MicrosoftStickyNotes"
                {
                    "Note-taking application that allows users to create [notes], [typ"+
                    "e], [ink], or [add a picture], [text formatting], stick them to t"+
                    "he desktop, move them around freely, close them to the notes list"+
                    ", and sync them across devices and apps like [OneNote Mobile], [M"+
                    "icrosoft Launcher for Android], and [Outlook for Windows]."
                }
                "Microsoft.MixedReality.Portal"
                {
                    "Provides main Windows Mixed Reality experience in [Windows 10] ver"+
                    "sions (1709/1803) and is a key component of the [Windows 10] opera"+
                    "ting system updated via [Windows Update]."
                }
                "Microsoft.MSPaint"
                {
                    "Simple graphics editor that allows users to create and edit images"+
                    " using various tools such as brushes, pencils, shapes, text, and m"+
                    "ore."
                }
                "Microsoft.Office.OneNote"
                {
                    "OneNote is a digital note-taking app that allows users to create a"+
                    "nd organize notes, drawings, audio recordings, and more."
                }
                "Microsoft.People"
                {
                    "Contact management app that allows users to store and manage their"+
                    " contacts in one place."
                }
                "Microsoft.ScreenSketch"
                {
                    "Screen Sketch is a screen capture and annotation tool that allows "+
                    "users to take screenshots and annotate them with a pen or highligh"+
                    "ter."
                }
                "Microsoft.SkypeApp"
                {
                    "Skype is a communication app that allows users to make voice and v"+
                    "ideo calls, send instant messages, and share files with other Skyp"+
                    "e users."
                }
                "Microsoft.StorePurchaseApp"
                {
                    "[Microsoft Store Purchase] app is used to purchase apps and games "+
                    "from the [Microsoft Store]."
                }
                "Microsoft.VCLibs.140.00"
                {
                    "Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 "+
                    "nd 2019 version 14. Installs runtime components of Visual C++ Libr"+
                    "aries required to run applications developed with Visual Studio."
                }
                "Microsoft.VP9VideoExtensions"
                {
                    "VP9 Video Extensions for [Microsoft Edge]. These extensions are de"+
                    "signed to take advantage of hardware capabilities on newer devices"+
                    " and are used for streaming over the internet."
                }
                "Microsoft.Wallet"
                {
                    "Microsoft Wallet is a mobile payment and digital wallet service by"+
                    " Microsoft."
                }
                "Microsoft.WebMediaExtensions"
                {
                    "Utilities & Tools App (UWP App/Microsoft Store Edition) that exten"+
                    "s [Microsoft Edge] and [Windows] to support open source formats co"+
                    "mmonly encountered on the web."
                }
                "Microsoft.WebpImageExtension"
                {
                    "Enables viewing WebP images in [Microsoft Edge]. WebP provides (lo"+
                    "ssless/lossy) compression for images."
                }
                "Microsoft.Windows.Photos"
                {
                    "Easy to use (photo/video) management and editing application that "+
                    "integrates well with [OneDrive]."
                }
                "Microsoft.WindowsAlarms"
                {
                    "Alarm clock app that comes with [Windows] that allows setting (ala"+
                    "rms/timers/reminders) for important events."
                }
                "Microsoft.WindowsCalculator"
                {
                    "Calculator app that comes with [Windows], and provides standard, s"+
                    "cientific, and programmer calculator functionality, as well as a s"+
                    "et of converters between various units of measurement and currenci"+
                    "es."
                }
                "Microsoft.WindowsCamera"
                {
                    "Camera app that comes with [Windows], allows (taking photos/record"+
                    "ing videos) using built-in camera or an external webcam."
                }
                "Microsoft.WindowsCommunicationsApps"
                {
                    "(Email/calendar) app that comes with [Windows]."
                }
                "Microsoft.WindowsFeedbackHub"
                {
                    "App that comes with [Windows] and allows providing feedback about "+
                    "[Windows] and its features."
                }
                "Microsoft.WindowsMaps"
                {
                    "App that comes with [Windows] and allows search navigation, voice "+
                    "navigation, driving, transit, and walking directions."
                }
                "Microsoft.WindowsSoundRecorder"
                {
                    "Audio recording program included in [Windows], allows recording au"+
                    "dio for up to three hours per recording."
                }
                "Microsoft.WindowsStore"
                {
                    "Official app store for [Windows], and allowing the download of app"+
                    "s, games, music, movies, TV shows and more."
                }
                "Microsoft.Xbox.TCUI"
                {
                    "Component of the [Xbox Live] in-game experience or [Xbox TCUI], al"+
                    "lows playing games on PC, connecting with friends, and sharing gam"+
                    "ing experiences."
                }
                "Microsoft.XboxApp"
                {
                    "[Xbox Console Companion] is an app that allows you to play games o"+
                    "n your PC, connect with friends, and share your gaming experiences."
                }
                "Microsoft.XboxGameOverlay"
                {
                    "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                    "ws] that allows you to access widgets and tools without leaving yo"+
                    "ur game."
                }
                "Microsoft.XboxGamingOverlay"
                {
                    "[Xbox Game Bar] is a customizable gaming overlay built into [Windo"+
                    "ws] that allows you to access widgets and tools without leaving yo"+
                    "ur game."
                }
                "Microsoft.XboxIdentityProvider"
                {
                    "[Xbox Console Companion] is an app that allows you to play games o"+
                    "n your PC, connect with friends, and share your gaming experiences."
                }
                "Microsoft.XboxSpeechToTextOverlay"
                {
                    "[Xbox Game Bar], converts speech to text."
                }
                "Microsoft.YourPhone"
                {
                    "App that allows directly connecting a smartphone to a PC."
                }
                "Microsoft.ZuneMusic"
                {
                    "Zune Music is a discontinued music streaming service and software"+
                    " from Microsoft."
                }
                "Microsoft.ZuneVideo"
                {
                    "Zune Video is a discontinued video streaming service and software "+
                    "from Microsoft."
                }
                Default
                {
                    "Unknown"
                }
            }

            $xState           = $This.State.Output[0]
            $Item.SetState($xState)

            $Target           = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$xState)
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()

            Return $Item
        }
        Clear()
        {
            $This.Output  = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($AppX in $This.GetObject())
            {
                $Item = $This.New($AppX)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.AppX.Controller>"
        }
    }

    # // ========================
    # // | Application Controls |
    # // ========================

    Enum ApplicationStateType
    {
        Installed
        Remove
        Install
    }

    Class ApplicationStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        ApplicationStateItem([String]$Name)
        {
            $This.Index = [UInt32][ApplicationStateType]::$Name
            $This.Name  = [ApplicationStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ApplicationStateList
    {
        [Object] $Output
        ApplicationStateList()
        {
            $This.Refresh()
        }
        [Object] ApplicationStateItem([String]$Name)
        {
            Return [ApplicationStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ApplicationStateType]))
            {
                $Item = $This.ApplicationStateItem($Name)
                $Item.Label = @("[X]","[!]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    Installed { "Application is installed." }
                    Remove    { "Remove this application."  }
                    Install   { "Install this application." }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Application.State[List]>"
        }
    }

    Class ApplicationItem
    {
        [UInt32]                  $Index
        [UInt32]                $Profile
        [String]            $DisplayName
        [String]         $DisplayVersion
        [String]                   $Type
        [Object]                  $State
        Hidden [String]         $Version
        Hidden [Int32]         $NoRemove
        Hidden [String]      $ModifyPath
        Hidden [String] $UninstallString
        Hidden [String] $InstallLocation
        Hidden [String]     $DisplayIcon
        Hidden [Int32]         $NoRepair
        Hidden [String]       $Publisher
        Hidden [String]     $InstallDate
        Hidden [Int32]     $VersionMajor
        Hidden [Int32]     $VersionMinor
        [Object]                 $Target
        [String]                 $Status
        ApplicationItem([UInt32]$Index,[Object]$App)
        {
            $This.Index            = $Index
            $This.DisplayName      = @("-",$App.DisplayName)[!!$App.DisplayName]
            $This.DisplayVersion   = @("-",$App.DisplayVersion)[!!$App.DisplayVersion]
            $This.Type             = @("MSI","WMI")[$App.UninstallString -imatch "msiexec"]
            $This.Version          = @("-",$App.Version)[!!$App.Version]
            $This.NoRemove         = $App.NoRemove
            $This.ModifyPath       = $App.ModifyPath
            $This.UninstallString  = $App.UninstallString
            $This.InstallLocation  = $App.InstallLocation
            $This.DisplayIcon      = $App.DisplayIcon
            $This.NoRepair         = $App.NoRepair
            $This.Publisher        = $App.Publisher
            $This.InstallDate      = $App.InstallDate
            $This.VersionMajor     = $App.VersionMajor
            $This.VersionMinor     = $App.VersionMinor
        }
        SetState([Object]$State)
        {
            $This.State            = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile          = $xProfile
            $This.Target           = $Target
        }
        SetStatus()
        {
            $This.Status = "[Application]: [{0}] {1}" -f $This.Type, $This.DisplayName
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Application[Item]>"
        }
    }

    Class ApplicationController : GenericProfileController
    {
        Hidden [Object] $State
        ApplicationController([String]$Name) : Base($Name)
        {
            $This.State = $This.ApplicationStateList()
        }
        [Object] ApplicationItem([UInt32]$Index,[Object]$Application)
        {
            Return [ApplicationItem]::New($Index,$Application)
        }
        [Object] ApplicationStateList()
        {
            Return [ApplicationStateList]::New()
        }
        [Object] New([Object]$Application)
        {
            $Item = $This.ApplicationItem($This.Output.Count,$Application)

            $xState           = $This.State.Output[0]
            $Item.SetState($xState)

            $Target           = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$xState)
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()

            Return $Item
        }
        [Object[]] GetObject()
        {
            $Item = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
            $Slot = Switch ([Environment]::GetEnvironmentVariable("Processor_Architecture"))
            {
                AMD64   { 0,1 } Default { 0 }
            }

            Return $Item[$Slot] | % { Get-ItemProperty $_ } | ? DisplayName | Sort-Object DisplayName
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Application in $This.GetObject())
            {
                $Item = $This.New($Application)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Application.Controller>"
        }
    }

    # // ======================
    # // | Event Log Controls |
    # // ======================

    Enum EventLogProviderStateType
    {
        Disabled
        Enabled
    }

    Class EventLogProviderStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        EventLogProviderStateItem([String]$Name)
        {
            $This.Index = [UInt32][EventLogProviderStateType]::$Name
            $This.Name  = [EventLogProviderStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class EventLogProviderStateList
    {
        [Object] $Output
        EventLogProviderStateList()
        {
            $This.Refresh()
        }
        [Object] EventLogProviderStateItem([String]$Name)
        {
            Return [EventLogProviderStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([EventLogProviderStateType]))
            {
                $Item       = $This.EventLogProviderStateItem($Name)
                $Item.Label = @("[_]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    Disabled { "Event log config is NOT collecting logs." }
                    Enabled  { "Event log config is collecting logs."     }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.EventLogProvider[List]>"
        }
    }

    Class EventLogProviderItem
    {
        [UInt32]           $Index
        [UInt32]         $Profile
        [String]            $Name
        Hidden [UInt32]  $Enabled
        Hidden [String] $Fullname
        [Object]            $Size
        [Object]             $Max
        [String]         $Percent
        [UInt64]           $Count
        [Object]           $State
        [Object]          $Target
        [String]          $Status
        EventLogProviderItem([UInt32]$Index,[Object]$Config)
        {
            $This.Index       = $Index
            $This.Name        = $Config.LogName
            $This.Enabled     = $Config.IsEnabled
            $This.Fullname    = $This.Expand($Config.LogFilePath)
            $This.Size        = $This.ByteSize("File",$Config.FileSize)
            $This.Max         = $This.ByteSize("Max",$Config.MaximumSizeInBytes)
            $This.Percent     = "{0:n2}%" -f (($This.Size.Bytes*100)/$This.Max.Bytes)
            $This.Count       = $Config.RecordCount
        }
        SetState([Object]$State)
        {
            $This.State       = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile     = $xProfile
            $This.Target      = $Target
        }
        SetStatus()
        {
            $This.Status      = "[Event Log]: ({0}) {1}" -f $This.Count, $This.Name
        }
        [String] Expand([String]$Path)
        {
            Return $Path -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
        }
        [Object] ByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [ByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.EventLogProvider[Item]>"
        }
    }

    Class EventLogProviderController : GenericProfileController
    {
        Hidden [Object] $State
        EventLogProviderController([String]$Name) : Base($Name)
        {
            $This.State = $This.EventLogProviderStateList()
        }
        [Object] EventLogProviderItem([UInt32]$Index,[Object]$Config)
        {
            Return [EventLogProviderItem]::New($Index,$Config)
        }
        [Object] EventLogProviderStateList()
        {
            Return [EventLogProviderStateList]::New()
        }
        [Object[]] GetObject()
        {
            Return Get-WinEvent -ListLog * | Sort-Object LogName
        }
        [Object] New([Object]$Config)
        {
            $Item   = $This.EventLogProviderItem($This.Output.Count,$Config)

            $xState = $This.State.Output[$Item.Enabled]

            $Item.SetState($xState)

            $Target = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$xState)
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()
            
            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Config in $This.GetObject())
            {
                $Item = $This.New($Config)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.EventLogProvider.Controller>"
        }
    }

    # // ===========================
    # // | Scheduled Task Controls |
    # // ===========================

    Enum ScheduledTaskStateType
    {
        Disabled
        Ready
        Running
    }

    Class ScheduledTaskStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        ScheduledTaskStateItem([String]$Name)
        {
            $This.Index = [UInt32][ScheduledTaskStateType]::$Name
            $This.Name  = [ScheduledTaskStateType]::$Name        
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ScheduledTaskStateList
    {
        [Object] $Output
        ScheduledTaskStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] ScheduledTaskStateItem([String]$Name)
        {
            Return [ScheduledTaskStateItem]::New($Name)
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ScheduledTaskStateType]))
            {
                $Item             = $This.ScheduledTaskStateItem($Name)
                $Item.Label       = @("[_]","[~]","[+]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    Disabled { "The scheduled task is currently disabled."        }
                    Ready    { "The scheduled task is enabled, and ready to run." }
                    Running  { "The scheduled task is currently running."         }
                }
        
                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.ScheduledTask.State[List]>"
        }
    }

    Class ScheduledTaskItem
    {
        [UInt32]         $Index
        [UInt32]       $Profile
        [String]          $Name
        Hidden [String] $xState
        [String]        $Author
        [UInt32]       $Actions
        [UInt32]      $Triggers
        [Object]         $State
        Hidden [String]   $Path
        [Object]        $Target
        [String]        $Status
        ScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            $This.Index    = $Index
            $This.Name     = $Task.TaskName
            $This.xState   = $Task.State
            $This.Author   = $Task.Author
            $This.Actions  = $Task.Actions.Count
            $This.Triggers = $Task.Triggers.Count
            $This.Path     = $Task.TaskPath
        }
        SetState([Object]$State)
        {
            $This.State    = $State
        }
        SetProfile([UInt32]$xProfile,[Object]$Target)
        {
            $This.Profile = $xProfile
            $This.Target  = $Target
        }
        SetStatus()
        {
            $This.Status   = "[Task]: {0} {1}" -f $This.State.Label, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.ScheduledTask[Item]>"
        }
    }

    Class ScheduledTaskController : GenericProfileController
    {
        Hidden [Object] $State
        ScheduledTaskController([String]$Name) : Base($Name)
        {
            $This.State  = $This.ScheduledTaskStateList()
        }
        [Object] ScheduledTaskStateList()
        {
            Return [ScheduledTaskStateList]::New()
        }
        [Object[]] GetObject()
        {
            Return Get-ScheduledTask
        }
        [Object] GetScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            Return [ScheduledTaskItem]::New($Index,$Task)
        }
        [Object] New([Object]$Task)
        {
            $Item   = $This.GetScheduledTaskItem($This.Output.Count,$Task)

            $xState = $This.State.Output | ? Name -eq $Item.Task.State

            $Item.SetState($xState)

            $Target = $This.Profile.Output | ? Name -eq $Item.Name
            If (!$Target)
            {
                $Item.SetProfile(0,$xState)
            }
            Else
            {
                $Item.SetProfile(1,$This.State.Output[$Target.Value])
            }

            $Item.SetStatus()

            $Item.State = $This.State.Output | ? Name -eq $Task.State

            $Item.SetStatus()

            Return $Item
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Task in $This.GetObject())
            {
                $Item = $This.New($Task)

                $This.Add($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.ScheduledTask.Controller>"
        }
    }

    # // ======================
    # // | Service Controller |
    # // ======================

    Enum ServiceStateType
    {
        Running
        Stopped
    }

    Class ServiceStateSlot
    {
        [UInt32]       $Index
        [String]        $Type
        [String]       $Label
        [String] $Description
        ServiceStateSlot([String]$Type)
        {
            $This.Type  = [ServiceStateType]::$Type
            $This.Index = [UInt32][ServiceStateType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ServiceStateList
    {
        [Object] $Output
        ServiceStateList()
        {
            $This.Refresh()
        }
        [Object] ServiceStateSlot([String]$Type)
        {
            Return [ServiceStateSlot]::New($Type)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([ServiceStateType]))
            {
                $Item             = $This.ServiceStateSlot($Name)
                $Item.Label       = @("[+]","[ ]")[$Item.Index]
                $Item.Description = Switch ($Name)
                {
                    Running  { "The service is currently running"     }
                    Stopped  { "The service is NOT currently running" }
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Item)
        {   
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStateType]::$Type]
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceState[List]>"
        }
    }

    Enum ServiceStartModeType
    {
        Skip
        Disabled
        Manual
        Auto
        AutoDelayed
    }

    Class ServiceStartModeSlot
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        ServiceStartModeSlot([String]$Type)
        {
            $This.Type  = [ServiceStartModeType]::$Type
            $This.Index = [UInt32][ServiceStartModeType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ServiceStartModeList
    {
        [Object] $Output
        ServiceStartModeList()
        {
            $This.Refresh()
        }
        [Object] ServiceStartModeSlot([String]$Type)
        {
            Return [ServiceStartModeSlot]::New($Type)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Type in [System.Enum]::GetNames([ServiceStartModeType]))
            {
                $Item             = $This.ServiceStartModeSlot($Type)
                $Item.Description = Switch ($Type)
                {
                    Skip        { "The service is skipped"                           }
                    Disabled    { "The service is totally disabled"                  }
                    Manual      { "The service requires a manual start"              }
                    Auto        { "The service automatically starts"                 }
                    AutoDelayed { "The service automatically starts, but is delayed" } 
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Item)
        {
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output[[UInt32][ServiceStartModeType]::$Type]
        }
        [String] ToString()
        {
            Return "<FEModule.ServiceStartMode[List]>"
        }
    }

    Class ServiceItem
    {
        [UInt32]            $Index
        [UInt32]          $Profile
        [String]             $Name
        [Object]        $StartMode
        [Object]            $State
        [UInt32] $DelayedAutoStart
        [String]      $DisplayName
        Hidden [String]  $PathName
        [String]      $Description
        [String]           $Status
        ServiceItem([Int32]$Index,[Object]$Wmi)
        {
            $This.Index              = $Index
            $This.Name               = $Wmi.Name
            $This.DelayedAutoStart   = $Wmi.DelayedAutoStart
            $This.DisplayName        = $Wmi.DisplayName
            $This.PathName           = $Wmi.PathName
            $This.Description        = $Wmi.Description
        }
        SetStartMode([Object]$StartMode)
        {
            $This.StartMode          = $StartMode
        }
        SetState([Object]$State)
        {
            $This.State              = $State
        }
        SetStatus()
        {
            $This.Status             = "[Service]: {0} {1}" -f $This.State.Label, $This.Name
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Service[Item]>"
        }
    }

    Class ServiceController : GenericProfileController
    {
        Hidden [Object] $StartMode
        Hidden [Object]     $State
        ServiceController([String]$Name) : Base($Name)
        {
            $This.StartMode = $This.ServiceStartModeList()
            $This.State     = $This.ServiceStateList()
        }
        [Object] ServiceStartModeList()
        {
            Return [ServiceStartModeList]::New()
        }
        [Object] ServiceStateList()
        {
            Return [ServiceStateList]::New()
        }
        [Object] ServiceItem([UInt32]$Index,[Object]$Wmi)
        {
            Return [ServiceItem]::New($Index,$Wmi)
        }
        [Object[]] GetObject()
        {
            Return Get-WMIObject -Class Win32_Service | Sort-Object Name
        }
        [String] Pid()
        {
            Return (Get-Service | ? ServiceType -eq 224)[0].Name.Split('_')[-1]
        }
        [Object] New([Object]$Service)
        {
            $Item       = $This.ServiceItem($This.Output.Count,$Service)

            $xStartMode = $This.StartMode.Output | ? Type -eq $Service.StartMode
            $Item.SetStartMode($xStartMode)

            $xState     = $This.State.Output | ? Type -eq $Service.State
            $Item.SetState($xState)

            $Item.SetStatus()

            Return $Item
        }
        Refresh()
        {
            $This.Clear()

            $List = $This.GetObject()

            ForEach ($Service in $List)
            {
                $This.Output += $This.New($Service)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Service.Controller>"
        }
    }

    # // =====================
    # // | Settings Controls |
    # // =====================

    Enum PrivacyType
    {
        Telemetry
        WifiSense
        SmartScreen
        LocationTracking
        Feedback
        AdvertisingID
        Cortana
        CortanaSearch
        ErrorReporting
        AutologgerFile
        DiagTrack
        WAPPush
    }

    Enum WindowsUpdateType
    {
        UpdateMSProducts
        CheckForWindowsUpdate
        WinUpdateType
        WinUpdateDownload
        UpdateMSRT
        UpdateDriver
        RestartOnUpdate
        AppAutoDownload
        UpdateAvailablePopup
    }

    Enum ServiceType
    {
        UAC
        SharingMappedDrives
        AdminShares
        Firewall
        WinDefender
        HomeGroups
        RemoteAssistance
        RemoteDesktop
    }

    Enum ContextType
    {
        CastToDevice
        PreviousVersions
        IncludeInLibrary
        PinToStart      
        PinToQuickAccess
        ShareWith       
        SendTo
    }

    Enum TaskbarType
    {
        BatteryUIBar
        ClockUIBar
        VolumeControlBar
        TaskbarSearchBox
        TaskViewButton
        TaskbarIconSize
        TaskbarGrouping
        TrayIcons
        SecondsInClock
        LastActiveClick
        TaskbarOnMultiDisplay
        TaskbarButtonDisplay
    }

    Enum StartMenuType
    {
        StartMenuWebSearch
        StartSuggestions
        MostUsedAppStartMenu
        RecentItemsFrequent
        UnpinItems
    }

    Enum ExplorerType
    {
        AccessKeyPrompt
        F1HelpKey
        AutoPlay
        AutoRun
        PidInTitleBar
        RecentFileQuickAccess
        FrequentFoldersQuickAccess
        WinContentWhileDrag
        StoreOpenWith
        LongFilePath
        ExplorerOpenLoc
        WinXPowerShell
        AppHibernationFile
        Timeline
        AeroSnap
        AeroShake
        KnownExtensions
        HiddenFiles
        SystemFiles
        TaskManagerDetails
        ReopenAppsOnBoot
    }

    Enum ThisPCIconType
    {
        Desktop
        Documents
        Downloads
        Music
        Pictures
        Videos
        ThreeDObjects
    }

    Enum DesktopIconType
    {
        ThisPC
        Network
        RecycleBin
        Profile
        ControlPanel
    }

    Enum LockScreenType
    {
        Toggle
        Password
        PowerMenu
        Camera
    }

    Enum MiscellaneousType
    {
        ScreenSaver
        AccountProtectionWarn
        ActionCenter
        StickyKeyPrompt
        NumlockOnStart
        F8BootMenu
        RemoteUACAcctToken
        HibernatePower
        SleepPower
    }

    Enum PhotoViewerType
    {
        FileAssociation
        OpenWithMenu
    }

    Enum WindowsAppsType
    {
        OneDrive
        OneDriveInstall
        XboxDVR
        MediaPlayer
        WorkFolders
        FaxAndScan
        LinuxSubsystem
    }

    Enum ListItemType
    {
        PrivacyType
        WindowsUpdateType
        ServiceType
        ContextType
        TaskbarType
        StartMenuType
        ExplorerType
        ThisPCIconType
        DesktopIconType
        LockScreenType
        MiscellaneousType
        PhotoViewerType
        WindowsAppsType
    }

    Class RegistryItem
    {
        [String]  $Path
        [String]  $Name
        [Object] $Value
        RegistryItem([String]$Path)
        {
            $This.Path  = $Path
        }
        RegistryItem([String]$Path,[String]$Name)
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
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class SettingItem
    {
        [UInt32]         $Index
        [UInt32]       $Profile
        [String]        $Source
        [String]          $Name
        [String]   $DisplayName
        [UInt32]         $Value
        [String]   $Description
        [String[]]     $Options
        [Object]        $Output
        Hidden [String] $Status
        SettingItem([UInt32]$Index,[String]$Source,[String]$Name,[String]$DisplayName,[UInt32]$Value,[String]$Description,[String[]]$Options)
        {
            $This.Index       = $Index
            $This.Source      = $Source
            $This.Name        = $Name
            $This.DisplayName = $DisplayName
            $This.Value       = $Value
            $This.Description = $Description
            $This.Options     = $Options
            
            $This.Clear()

            $This.SetStatus()
        }
        Clear()
        {
            $This.Output      = @( ) 
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [Object] RegistryItem([String]$Path)
        {
            Return [RegistryItem]::New($Path)
        }
        [Object] RegistryItem([String]$Path,[String]$Name)
        {
            Return [RegistryItem]::New($Path,$Name)
        }
        Registry([String]$Path,[String]$Name)
        {
            $This.Output += $This.RegistryItem($Path,$Name)
        }
        SetStatus()
        {
            $This.Status = "[Control]: {0}: {1}" -f $This.Source, $This.Name
        }
        [String] ToString()
        {
            Return $This.Status
        }
    }

    Class SettingController : GenericProfileController
    {
        Hidden [UInt32]                     $x64Bit
        Hidden [UInt32]                    $Version
        Hidden [String]         $AutoLoggerRegistry
        Hidden [String]             $AutoLoggerPath
        Hidden [String]          $AppAutoCloudCache
        Hidden [String]         $AppAutoPlaceholder
        Hidden [String[]]                $MUSNotify
        Hidden [String]       $QuickAccessParseName
        Hidden [String] $StartSuggestionsCloudCache
        Hidden [String]         $LockscreenArgument
        SettingController([String]$Name) : Base($Name)
        {
            $This.x64Bit                     = [Environment]::Is64BitProcess
            $This.Version                    = $This.GetVersion()
            $This.AutoLoggerRegistry         = "HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener"
            $This.AutoLoggerPath             = "{0}\Microsoft\Diagnosis\ETLLogs\AutoLogger" -f [Environment]::GetEnvironmentVariable("ProgramData")
            $This.AppAutoCloudCache          = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
            $This.AppAutoPlaceholder         = "*windows.data.placeholdertilecollection\Current"
            $This.MUSNotify                  = $This.GetMUSNotify()
            $This.QuickAccessParseName       = $This.GetQuickAccessParseName()
            $This.StartSuggestionsCloudCache = $This.GetStartSuggestionsCloudCache()
            $This.LockscreenArgument         = $This.GetLockscreenArgument()
        }
        [UInt32] GetVersion()
        {
            Return Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | % ReleaseID
        }
        [String[]] GetMUSNotify()
        {
            Return @("","ux" | % { "$Env:windir\System32\musnotification$_.exe" })
        }
        [String] GetQuickAccessParseName()
        {
            Return 'System.ParsingName:<>"::{679f85cb-0220-4080-b29b-5540cc05aab6}"', 
                   'System.ParsingName:<>"::{645FF040-5081-101B-9F08-00AA002F954E}"', 
                   'System.IsFolder:=System.StructuredQueryType.Boolean#True' -join " AND "
        }
        [String] GetStartSuggestionsCloudCache()
        {
            Return "HKCU:","SOFTWARE","Microsoft","Windows","CurrentVersion","CloudStore","Store",
            "Cache","DefaultAccount","*windows.data.placeholdertilecollection","Current" -join '\'
        }
        [String] GetLockscreenArgument()
        {
            $Item = "HKLM","SOFTWARE","Microsoft","Windows","CurrentVersion","Authentication",
                    "LogonUI","SessionData" -join "\"
    
            Return "add $Item /t REG_DWORD /v AllowLockScreen /d 0 /f"
        }
        [Object] SettingItem([UInt32]$Index,[String]$Source,[String]$Name,[String]$DisplayName,[UInt32]$Value,[String]$Description,[String[]]$Options)
        {
            Return [SettingItem]::New($Index,$Source,$Name,$DisplayName,$Value,$Description,$Options)
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb.Setting.Controller>"
        }
    }

    Enum RefreshType
    {
        Processor
        Disk
        Network
        HotFix
        Feature
        AppX
        Application
        EventLog
        Task
        Service
    }

    Class ViperBombProperty
    {
        [String]  $Name
        [Object] $Value
        ViperBombProperty([Object]$Property)
        {
            $This.Name  = $Property.Name
            $This.Value = $Property.Value -join ", "
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmController[Property]>"
        }
    }
    Class ViperBombValidatePath
    {
        [UInt32]   $Status
        [String]     $Type
        [String]     $Name
        [Object] $Fullname
        ViperBombValidatePath([String]$Entry)
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

    Class ViperBombFlag
    {
        [UInt32] $Index
        [String] $Name
        [UInt32] $Status
        ViperBombFlag([UInt32]$Index,[String]$Name)
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
            Return "<FEModule.ViperBomb[Flag]>"
        }
    }

    Enum ModuleExtensionType
    {
        Bios
        OperatingSystem
        ComputerSystem
        Product
        Baseboard
        Enclosure
    }

    Class ViperBombController
    {
        [Object]      $Module
        [Object]        $Xaml
        [Object]      $System
        [Object]      $HotFix
        [Object]     $Feature
        [Object]        $AppX
        [Object] $Application
        [Object]    $EventLog
        [Object]        $Task
        [Object]     $Service
        [Object]     $Setting
        [Object]     $Profile
        ViperBombController()
        {
            $This.Module = Get-FEModule -Mode 1
            $This.Main()
        }
        ViperBombController([Object]$Module)
        {
            $This.Module = $Module
            $This.Main()
        }
        Main()
        {
            $This.AddModuleProperties()

            $This.Xaml        = $This.New("Xaml")
            $This.System      = $This.New("System")
            $This.HotFix      = $This.New("HotFix")
            $This.Feature     = $This.New("Feature")
            $This.AppX        = $This.New("AppX")
            $This.Application = $This.New("Application")
            $This.EventLog    = $This.New("EventLog")
            $This.Task        = $This.New("Task")
            $This.Service     = $This.New("Service")
            $This.Setting     = $This.New("Setting")
            $This.Profile     = $This.New("Profile")
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
        Clear()
        {
            $This.Output = @( )
        }
        [Object] New([String]$Name)
        {
            $This.Update(0,"Getting [~] $Name Controller")

            $Item = Switch ($Name)
            {
                Xaml
                {
                    [XamlWindow][ViperBombXaml]::Content
                }
                System
                {
                    [SystemController]::New($This.Module)
                }
                HotFix
                {
                    [HotFixController]::New($Name)
                }
                Feature
                {
                    [FeatureController]::New($Name)
                }
                AppX
                {
                    [AppXController]::New($Name)
                }
                Application
                {
                    [ApplicationController]::New($Name)
                }
                EventLog
                {
                    [EventLogProviderController]::New($Name)
                }
                Task
                {
                    [ScheduledTaskController]::New($Name)
                }
                Service
                {
                    [ServiceController]::New($Name)
                }
                Setting
                {
                    [SettingController]::New($Name)
                }
                Profile
                {
                    Get-UserProfile
                }
            }

            Return $Item
        }
        Refresh([String]$Property)
        {
            If ($Property -in [System.Enum]::GetNames([RefreshType]))
            {
                $Branch = $This.$Property

                $This.Update(0,"Refreshing [~] $Property Controller")

                ForEach ($Object in $Branch.GetObject())
                {
                    $Item = $Branch.New($Object)
                    $Branch.Add($Item)

                    $This.Update(1,$Item.Status)
                }

                $This.Update(1,"Refreshed [+] $Property Controller")
            }
            ElseIf ($Property -eq "Setting")
            {
                $Branch = $This.Setting

                $Branch.Clear()

                $This.Update(0,"Refreshing [~] Setting Controller")

                ForEach ($xSource in [System.Enum]::GetNames([ListItemType]))
                {
                    $Source = $xSource.Replace("Type","")
                    ForEach ($Name in [System.Enum]::GetNames($xSource))
                    {
                        $X = Switch ($Source)
                        {
                                Privacy
                                {
                                    Switch ($Name)
                                    {
                                        Telemetry
                                        {
                                            "Telemetry",
                                            "Telemetry",
                                            1,
                                            "Various location and tracking features",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        WifiSense
                                        {
                                            "WifiSense",
                                            "Wi-Fi Sense",
                                            1,
                                            "Lets devices more easily connect to a WiFi network",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        SmartScreen
                                        {
                                            "SmartScreen",
                                            "SmartScreen",
                                            1,
                                            "Cloud-based anti-phishing and anti-malware component",
                                            @("Skip","Enable*","Disable")
                                        }
                                        LocationTracking
                                        {
                                            "LocationTracking",
                                            "Location Tracking",
                                            1,
                                            "Monitors the current location of the system and manages geofences",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        Feedback
                                        {
                                            "Feedback",
                                            "Feedback",
                                            1,
                                            "System Initiated User Feedback",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AdvertisingID
                                        {
                                            "AdvertisingID",
                                            "Advertising ID",
                                            1,
                                            "Allows Microsoft to display targeted ads",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        Cortana
                                        {
                                            "Cortana",
                                            "Cortana",
                                            1,
                                            "(Master Chief/Microsoft)'s personal voice assistant",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        CortanaSearch
                                        {
                                            "CortanaSearch",
                                            "Cortana Search",
                                            1,
                                            "Allows Cortana to create search indexing for faster system search results",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        ErrorReporting
                                        {
                                            "ErrorReporting",
                                            "Error Reporting",
                                            1,
                                            "If Windows has an issue, it sends Microsoft a detailed report",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AutologgerFile
                                        {
                                            "AutoLoggerFile",
                                            "Automatic Logger File",
                                            1,
                                            "Lets you track trace provider actions while Windows is booting",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        DiagTrack
                                        {
                                            "DiagTracking",
                                            "Diagnostics Tracking",
                                            1,
                                            "Connected User Experiences and Telemetry",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        WAPPush
                                        {
                                            "WAPPush",
                                            "WAP Push",
                                            1,
                                            "Device Management Wireless Application Protocol",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                WindowsUpdate
                                {
                                    Switch ($Name)
                                    {
                                        UpdateMSProducts
                                        {
                                            "UpdateMSProducts",
                                            "Update MS Products",
                                            2,
                                            "Searches Windows Update for Microsoft Products",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        CheckForWindowsUpdate
                                        {
                                            "CheckForWindowsUpdate",
                                            "Check for Windows Updates",
                                            1,
                                            "Allows Windows Update to work automatically",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        WinUpdateType
                                        {
                                            "WinUpdateType",
                                            "Windows Update Type",
                                            3,
                                            "Allows Windows Update to work automatically",
                                            @("Skip", "Notify", "Auto DL", "Auto DL+Install*", "Manual")
                                        }
                                        WinUpdateDownload
                                        {
                                            "WinUpdateDownload",
                                            "Windows Update Download",
                                            1,
                                            "Selects a source from which to pull Windows Updates",
                                            @("Skip", "P2P*", "Local Only", "Disable")
                                        }
                                        UpdateMSRT
                                        {
                                            "UpdateMSRT",
                                            "Update MSRT",
                                            1,
                                            "Allows updates for the Malware Software Removal Tool",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        UpdateDriver
                                        {
                                            "UpdateDriver",
                                            "Update Driver",
                                            1,
                                            "Allows drivers to be downloaded from Windows Update",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        RestartOnUpdate
                                        {
                                            "RestartOnUpdate",
                                            "Restart on Update",
                                            1,
                                            "Reboots the machine when an update is installed and requires it",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AppAutoDownload
                                        {
                                            "AppAutoDownload",
                                            "Consumer App Auto Download",
                                            1,
                                            "Provisioned Windows Store applications are downloaded",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        UpdateAvailablePopup
                                        {
                                            "UpdateAvailablePopup",
                                            "Update Available Pop-up",
                                            1,
                                            "If an update is available, a (pop-up/notification) will appear",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                Service
                                {
                                    Switch ($Name)
                                    {
                                        UAC
                                        {
                                            "UAC",
                                            "User Access Control",
                                            2,
                                            "Sets restrictions/permissions for programs",
                                            @("Skip", "Lower", "Normal*", "Higher")
                                        }
                                        SharingMappedDrives
                                        {
                                            "SharingMappedDrives",
                                            "Share Mapped Drives",
                                            2,
                                            "Shares any mapped drives to all users on the machine",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        AdminShares
                                        {
                                            "AdminShares",
                                            "Administrative File Shares",
                                            1,
                                            "Reveals default system administration file shares",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        Firewall
                                        {
                                            "Firewall",
                                            "Firewall",
                                            1,
                                            "Enables the default firewall profile",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        WinDefender
                                        {
                                            "WinDefender",
                                            "Windows Defender",
                                            1,
                                            "Toggles Windows Defender, system default anti-virus/malware utility",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        HomeGroups
                                        {
                                            "HomeGroups",
                                            "Home Groups",
                                            1,
                                            "Toggles the use of home groups, essentially a home-based workgroup",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        RemoteAssistance
                                        {
                                            "RemoteAssistance",
                                            "Remote Assistance",
                                            1,
                                            "Toggles the ability to use Remote Assistance",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        RemoteDesktop
                                        {
                                            "RemoteDesktop",
                                            "Remote Desktop",
                                            2,
                                            "Toggles the ability to use Remote Desktop",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                    }
                                }
                                Context
                                {
                                    Switch ($Name)
                                    {
                                        CastToDevice
                                        {
                                            "CastToDevice",
                                            "Cast To Device",
                                            1,
                                            "Adds a context menu item for casting to a device",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        PreviousVersions
                                        {
                                            "PreviousVersions",
                                            "Previous Versions",
                                            1,
                                            "Adds a context menu item to select a previous version of a file",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        IncludeInLibrary
                                        {
                                            "IncludeInLibrary",
                                            "Include in Library",
                                            1,
                                            "Adds a context menu item to include a selection in library items",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        PinToStart      
                                        {
                                            "PinToStart",
                                            "Pin to Start",
                                            1,
                                            "Adds a context menu item to pin an item to the start menu",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        PinToQuickAccess
                                        {
                                            "PinToQuickAccess",
                                            "Pin to Quick Access",
                                            1,
                                            "Adds a context menu item to pin an item to the Quick Access bar",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        ShareWith       
                                        {
                                            "ShareWith",
                                            "Share (a) file(s) with...",
                                            1,
                                            "Adds a context menu item to share a file with...",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        SendTo
                                        {
                                            "SendTo",
                                            "Send To",
                                            1,
                                            "Adds a context menu item to send an item to...",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                Taskbar
                                {
                                    Switch ($name)
                                    {
                                        BatteryUIBar
                                        {
                                            "BatteryUIBar",
                                            "Battery UI Bar",
                                            1,
                                            "Toggles the battery UI bar element style",
                                            @("Skip", "New*", "Classic")
                                        }
                                        ClockUIBar
                                        {
                                            "ClockUIBar",
                                            "Clock UI Bar",
                                            1,
                                            "Toggles the clock UI bar element style",
                                            @("Skip", "New*", "Classic")
                                        }
                                        VolumeControlBar
                                        {
                                            "VolumeControlBar",
                                            "Volume Control Bar",
                                            1,
                                            "Toggles the volume control bar element style",
                                            @("Skip", "New (X-Axis)*", "Classic (Y-Axis)")
                                        }
                                        TaskbarSearchBox
                                        {
                                            "TaskBarSearchBox",
                                            "Taskbar Search Box",
                                            1,
                                            "Toggles the taskbar search box element",
                                            @("Skip", "Show*", "Hide")
                                        }
                                        TaskViewButton
                                        {
                                            "VolumeControlBar",
                                            "Volume Control Bar",
                                            1,
                                            "Toggles the volume control bar element style",
                                            @("Skip", "New (X-Axis)*", "Classic (Y-Axis)")
                                        }
                                        TaskbarIconSize
                                        {
                                            "TaskbarIconSize",
                                            "Taskbar Icon Size",
                                            1,
                                            "Toggles the taskbar icon size",
                                            @("Skip", "Normal*", "Small")
                                        }
                                        TaskbarGrouping
                                        {
                                            "TaskbarGrouping",
                                            "Taskbar Grouping",
                                            2,
                                            "Toggles the grouping of icons in the taskbar",
                                            @("Skip", "Never", "Always*","When needed")
                                        }
                                        TrayIcons
                                        {
                                            "TrayIcons",
                                            "Tray Icons",
                                            1,
                                            "Toggles whether the tray icons are shown or hidden",
                                            @("Skip", "Auto*", "Always show")
                                        }
                                        SecondsInClock
                                        {
                                            "SecondsInClock",
                                            "Seconds in clock",
                                            1,
                                            "Toggles the clock/time shows the seconds",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        LastActiveClick
                                        {
                                            "LastActiveClick",
                                            "Last Active Click",
                                            2,
                                            "Makes taskbar buttons open the last active window",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        TaskbarOnMultiDisplay
                                        {
                                            "TaskbarOnMultiDisplay",
                                            "Taskbar on multiple displays",
                                            1,
                                            "Displays the taskbar on each display if there are multiple screens",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        TaskbarButtonDisplay
                                        {
                                            "TaskbarButtonDisplay",
                                            "Multi-display taskbar",
                                            2,
                                            "Defines where the taskbar button should be if there are multiple screens",
                                            @("Skip", "All", "Current Window*","Main + Current Window")
                                        }
                                    }
                                }
                                StartMenu
                                {
                                    Switch ($Name)
                                    {
                                        StartMenuWebSearch
                                        {
                                            "StartMenuWebSearch",
                                            "Start Menu Web Search",
                                            1,
                                            "Allows the start menu search box to search the internet",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        StartSuggestions
                                        {
                                            "StartSuggestions",
                                            "Start Menu Suggestions",
                                            1,
                                            "Toggles the suggested apps in the start menu",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        MostUsedAppStartMenu
                                        {
                                            "MostUsedAppStartMenu",
                                            "Most Used Applications",
                                            1,
                                            "Toggles the most used applications in the start menu",
                                            @("Skip", "Show*", "Hide")
                                        }
                                        RecentItemsFrequent
                                        {
                                            "RecentItemsFrequent",
                                            "Recent Items Frequent",
                                            1,
                                            "Toggles the most recent frequently used (apps/items) in the start menu",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        UnpinItems
                                        {
                                            "UnpinItems",
                                            "Unpin Items",
                                            0,
                                            "Toggles the unpin (apps/items) from the start menu",
                                            @("Skip", "Enable")
                                        }
                                    }
                                }
                                Explorer
                                {
                                    Switch ($Name)
                                    {
                                        AccessKeyPrompt
                                        {
                                            "AccessKeyPrompt",
                                            "Access Key Prompt",
                                            1,
                                            "Toggles the accessibility keys (menus/prompts)",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        F1HelpKey
                                        {
                                            "F1HelpKey",
                                            "F1 Help Key",
                                            1,
                                            "Toggles the F1 help menu/prompt",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AutoPlay
                                        {
                                            "AutoPlay",
                                            "AutoPlay",
                                            1,
                                            "Toggles autoplay for inserted discs or drives",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AutoRun
                                        {
                                            "AutoRun",
                                            "AutoRun",
                                            1,
                                            "Toggles autorun for programs on an inserted discs or drives",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        PidInTitleBar
                                        {
                                            "PidInTitleBar",
                                            "Process ID",
                                            2,
                                            "Toggles the process ID in a window title bar",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        RecentFileQuickAccess
                                        {
                                            "RecentFileQuickAccess",
                                            "Recent File Quick Access",
                                            1,
                                            "Shows recent files in the Quick Access menu",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        FrequentFoldersQuickAccess
                                        {
                                            "FrequentFoldersQuickAccess",
                                            "Frequent Folders Quick Access",
                                            1,
                                            "Show frequently used folders in the Quick Access menu",
                                            @("Skip", "Show*", "Hide")
                                        }
                                        WinContentWhileDrag
                                        {
                                            "WinContentWhileDrag",
                                            "Window Content while dragging",
                                            1,
                                            "Show the content of a window while it is being dragged/moved",
                                            @("Skip", "Show*", "Hide")
                                        }
                                        StoreOpenWith
                                        {
                                            "StoreOpenWith",
                                            "Store Open With...",
                                            1,
                                            "Toggles the ability to use the Microsoft Store to open an unknown file/program",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        LongFilePath
                                        {
                                            "LongFilePath",
                                            "Long File Path",
                                            1,
                                            "Toggles whether file paths are longer, or not",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        ExplorerOpenLoc
                                        {
                                            "ExplorerOpenLoc",
                                            "Explorer Open Location",
                                            1,
                                            "Default path/location opened with a new explorer window",
                                            @("Skip", "Quick Access*", "This PC")
                                        }
                                        WinXPowerShell
                                        {
                                            "WinXPowerShell",
                                            "Win X PowerShell",
                                            1,
                                            "Toggles whether (Win + X) opens PowerShell or a Command Prompt",
                                            @("Skip", "PowerShell*", "Command Prompt")
                                        }
                                        AppHibernationFile
                                        {
                                            "AppHibernationFile",
                                            "App Hibernation File",
                                            1,
                                            "Toggles the system swap file use",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        Timeline
                                        {
                                            "Timeline",
                                            "Timeline",
                                            1,
                                            "Toggles Windows Timeline, for recovery of items at a prior point in time",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AeroSnap
                                        {
                                            "AeroSnap",
                                            "AeroSnap",
                                            1,
                                            "Toggles the ability to snap windows to the sides of the screen",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AeroShake
                                        {
                                            "AeroShake",
                                            "AeroShake",
                                            1,
                                            "Toggles ability to minimize ALL windows by jiggling the active window title bar",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        KnownExtensions
                                        {
                                            "KnownExtensions",
                                            "Known File Extensions",
                                            2,
                                            "Shows known (mime-types/file extensions)",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        HiddenFiles
                                        {
                                            "HiddenFiles",
                                            "Show Hidden Files",
                                            2,
                                            "Shows all hidden files",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        SystemFiles
                                        {
                                            "SystemFiles",
                                            "Show System Files",
                                            2,
                                            "Shows all system files",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        TaskManagerDetails
                                        {
                                            "TaskManagerDetails",
                                            "Task Manager Details",
                                            2,
                                            "Toggles whether the task manager details are shown",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        ReopenAppsOnBoot
                                        {
                                            "ReopenAppsOnBoot",
                                            "Reopen apps at boot",
                                            1,
                                            "Toggles applications to reopen at boot time",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                ThisPCIcon
                                {
                                    Switch ($Name)
                                    {
                                        Desktop
                                        {
                                            "Desktop",
                                            "Desktop [Explorer]",
                                            1,
                                            "Toggles the Desktop icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        Documents
                                        {
                                            "Documents",
                                            "Documents [Explorer]",
                                            1,
                                            "Toggles the Documents icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        Downloads
                                        {
                                            "Downloads",
                                            "Downloads [Explorer]",
                                            1,
                                            "Toggles the Downloads icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        Music
                                        {
                                            "Music",
                                            "Music [Explorer]",
                                            1,
                                            "Toggles the Music icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        Pictures
                                        {
                                            "Pictures",
                                            "Pictures [Explorer]",
                                            1,
                                            "Toggles the Pictures icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        Videos
                                        {
                                            "Videos",
                                            "Videos [Explorer]",
                                            1,
                                            "Toggles the Videos icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                        ThreeDObjects
                                        {
                                            "ThreeDObjects",
                                            "3D Objects [Explorer]",
                                            1,
                                            "Toggles the 3D Objects icon in 'This PC'",
                                            @("Skip", "Show/Add*", "Hide", "Remove")
                                        }
                                    }
                                }
                                DesktopIcon
                                {
                                    Switch ($Name)
                                    {
                                        ThisPC
                                        {
                                            "ThisPC",
                                            "This PC [Desktop]",
                                            2,
                                            "Toggles the 'This PC' icon on the desktop",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        Network
                                        {
                                            "Network",
                                            "Network [Desktop]",
                                            2,
                                            "Toggles the 'Network' icon on the desktop",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        RecycleBin
                                        {
                                            "RecycleBin",
                                            "Recycle Bin [Desktop]",
                                            2,
                                            "Toggles the 'Recycle Bin' icon on the desktop",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        Profile
                                        {
                                            "Profile",
                                            "My Documents [Desktop]",
                                            2,
                                            "Toggles the 'Users File' icon on the desktop",
                                            @("Skip", "Show", "Hide*")
                                        }
                                        ControlPanel
                                        {
                                            "ControlPane",
                                            "Control Panel [Desktop]",
                                            2,
                                            "Toggles the 'Control Panel' icon on the desktop",
                                            @("Skip", "Show", "Hide*")
                                        }
                                    }
                                }
                                LockScreen
                                {
                                    Switch ($Name)
                                    {
                                        Toggle
                                        {
                                            "Toggle",
                                            "Toggle [Lock Screen]",
                                            1,
                                            "Toggles the lock screen",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        Password
                                        {
                                            "Password",
                                            "Password [Lock Screen]",
                                            1,
                                            "Toggles the lock screen password",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        PowerMenu
                                        {
                                            "PowerMenu",
                                            "Power Menu [Lock Screen]",
                                            1,
                                            "Toggles the power menu on the lock screen",
                                            @("Skip", "Show*", "Hide")
                                        }
                                        Camera
                                        {
                                            "Camera",
                                            "Camera [Lock Screen]",
                                            1,
                                            "Toggles the camera on the lock screen",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                Miscellaneous
                                {
                                    Switch ($Name)
                                    {
                                        ScreenSaver
                                        {
                                            "ScreenSaver",
                                            "Screen Saver",
                                            1,
                                            "Toggles the screen saver",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        AccountProtectionWarn
                                        {
                                            "AccountProtectionWarn",
                                            "Account Protection Warning",
                                            1,
                                            "Toggles system security account protection warning",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        ActionCenter
                                        {
                                            "ActionCenter",
                                            "Action Center",
                                            1,
                                            "Toggles system action center",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        StickyKeyPrompt
                                        {
                                            "StickyKeyPrompt",
                                            "Sticky Key Prompt",
                                            1,
                                            "Toggles the sticky keys prompt/dialog",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        NumlockOnStart
                                        {
                                            "NumlockOnStart",
                                            "Number lock on start",
                                            2,
                                            "Toggles whether the number lock key is engaged upon start",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        F8BootMenu
                                        {
                                            "F8BootMenu",
                                            "F8 Boot Menu",
                                            2,
                                            "Toggles whether the F8 boot menu can be access upon boot",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        RemoteUACAcctToken
                                        {
                                            "RemoteUACAcctToken",
                                            "Remote UAC Account Token",
                                            2,
                                            "Toggles the local account token filter policy to mitigate remote connections",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        HibernatePower
                                        {
                                            "HibernatePower",
                                            "Hibernate Power",
                                            0,
                                            "Toggles the hibernation power option",
                                            @("Skip", "Enable", "Disable")
                                        }
                                        SleepPower
                                        {
                                            "SleepPower",
                                            "Sleep Power",
                                            1,
                                            "Toggles the sleep power option",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                    }
                                }
                                PhotoViewer
                                {
                                    Switch ($Name)
                                    {
                                        FileAssociation
                                        {
                                            "FileAssociation",
                                            "Set file association [Photo Viewer]",
                                            2,
                                            "Associates common image types with Photo Viewer",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                        OpenWithMenu
                                        {
                                            "OpenWithMenu",
                                            "Set 'Open with' in context menu [Photo Viewer]",
                                            2,
                                            "Allows image files to be opened with Photo Viewer",
                                            @("Skip", "Enable", "Disable*")
                                        }
                                    }
                                }
                                WindowsApps
                                {
                                    Switch ($Name)
                                    {
                                        OneDrive
                                        {
                                            "OneDrive",
                                            "OneDrive",
                                            1,
                                            "Toggles Microsoft OneDrive, which comes with the operating system",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        OneDriveInstall
                                        {
                                            "OneDriveInstall",
                                            "OneDriveInstall",
                                            1,
                                            "Installs/Uninstalls Microsoft OneDrive, which comes with the operating system",
                                            @("Skip", "Installed*", "Uninstall")
                                        }
                                        XboxDVR
                                        {
                                            "XboxDVR",
                                            "Xbox DVR",
                                            1,
                                            "Toggles Microsoft Xbox DVR",
                                            @("Skip", "Enable*", "Disable")
                                        }
                                        MediaPlayer
                                        {
                                            "MediaPlayer",
                                            "Windows Media Player",
                                            1,
                                            "Toggles Microsoft Windows Media Player, which comes with the operating system",
                                            @("Skip", "Installed*", "Uninstall")
                                        }
                                        WorkFolders
                                        {
                                            "WorkFolders",
                                            "Work Folders",
                                            1,
                                            "Toggles the WorkFolders-Client, which comes with the operating system",
                                            @("Skip", "Installed*", "Uninstall")
                                        }
                                        FaxAndScan
                                        {
                                            "FaxAndScan",
                                            "Fax and Scan",
                                            1,
                                            "Toggles the FaxServicesClientPackage, which comes with the operating system",
                                            @("Skip", "Installed*", "Uninstall")
                                        }
                                        LinuxSubsystem
                                        {
                                            "LinuxSubsystem",
                                            "Linux Subsystem (WSL)",
                                            2,
                                            "For Windows 1607+, this toggles the Microsoft-Windows-Subsystem-Linux",
                                            @("Skip", "Installed", "Uninstall*")
                                        }
                                    }
                                }
                        }
                    
                        $Item   = $Branch.SettingItem($Branch.Output.Count,$Source,$X[0],$X[1],$X[2],$X[3],$X[4])
                    
                        # Populate registry items
                        Switch ($Item.Source)
                        {
                                Privacy
                                {
                                    Switch ($Item.Name)
                                    {
                                        Telemetry
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",
                                            "AllowTelemetry"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
                                            "AllowTelemetry"),
                                            ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection",
                                            "AllowTelemetry"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds",
                                            "AllowBuildPreview"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform",
                                            "NoGenTicket"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows",
                                            "CEIPEnable"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat",
                                            "AITEnable"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat",
                                            "DisableInventory"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP",
                                            "CEIPEnable"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC",
                                            "PreventHandwritingDataSharing"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput",
                                            "AllowLinguisticDataCollection") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        WifiSense
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting","Value"),
                                            ("HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowConnectToWiFiSenseHotspots","Value"),
                                            ("HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config","AutoConnectAllowedOEM"),
                                            ("HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config","WiFiSenseAllowed") | % {
                                                 
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        SmartScreen
                                        {

                                            $String   = @($Null;"\"+$This.GetAppX("DisplayName","Microsoft.MicrosoftEdge").PackageName)[$Branch.Version -ge 1703]
                                            $Phishing = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage{0}\MicrosoftEdge\PhishingFilter" -f $String
                                
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
                                            "SmartScreenEnabled"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost",
                                            "EnableWebContentEvaluation"),
                                            ($Phishing,
                                            "EnabledV9"),
                                            ($Phishing,
                                            "PreventOverride") | % {
                                            
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        LocationTracking
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}","SensorPermissionState"),
                                            ("HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration","Status") | % {
                                            
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Feedback
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Siuf\Rules","NumberOfSIUFInPeriod"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","DoNotShowFeedbackNotifications") | % {
                                        
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        AdvertisingID
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
                                            "Enabled"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy",
                                            "TailoredExperiencesWithDiagnosticDataEnabled") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Cortana
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Personalization\Settings","AcceptedPrivacyPolicy"),
                                            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore","HarvestContacts"),
                                            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection"),
                                            ("HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortanaAboveLock"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchPrivacy"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch"),
                                            ("HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Preferences","VoiceActivationEnableAboveLockscreen"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization","AllowInputPersonalization"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        CortanaSearch
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana")
                                        }
                                        ErrorReporting
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting","Disabled")
                                        }
                                        AutologgerFile
                                        {
                                            ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener",
                                            "Start"),
                                            ("HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener\{DD17FA14-CDA6-7191-9B61-37A28F7A10DA}",
                                            "Start") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        DiagTrack
                                        {
                                            # (Null/No Registry)
                                        }
                                        WAPPush
                                        {
                                            $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice","DelayedAutoStart")
                                        }
                                    }
                                }
                                WindowsUpdate
                                {
                                    Switch ($Item.Name)
                                    {
                                        UpdateMSProducts
                                        {
                                            # (Null/No Registry)
                                        }
                                        CheckForWindowsUpdate
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","SetDisableUXWUAccess")
                                        }
                                        WinUpdateType
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU","AUOptions")
                                        }
                                        WinUpdateDownload
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config",
                                            "DODownloadMode"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
                                            "SystemSettingsDownloadMode"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization",
                                            "SystemSettingsDownloadMode"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization",
                                            "DODownloadMode") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        UpdateMSRT
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\MRT","DontOfferThroughWUAU")
                                        }
                                        UpdateDriver
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching",
                                            "SearchOrderConfig"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
                                            "ExcludeWUDriversInQualityUpdate"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata",
                                            "PreventDeviceMetadataFromNetwork") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        RestartOnUpdate
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings",
                                            "UxOption"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
                                            "NoAutoRebootWithLoggOnUsers"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
                                            "AUPowerManagement") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        AppAutoDownload
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate",
                                            "AutoDownload"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
                                            "DisableWindowsConsumerFeatures") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        UpdateAvailablePopup
                                        {
                                            # (Null/No Registry)
                                        }
                                    }
                                }
                                Service
                                {
                                    Switch ($Item.Name)
                                    {
                                        UAC
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","ConsentPromptBehaviorAdmin"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","PromptOnSecureDesktop") | % { 
                                            
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        SharingMappedDrives
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLinkedConnections")
                                        }
                                        AdminShares
                                        {
                                            $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters","AutoShareWks")
                                        }
                                        Firewall
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile","EnableFirewall")
                                        }
                                        WinDefender
                                        {
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
                                            "DisableAntiSpyware"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                                            "WindowsDefender"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                                            "SecurityHealth"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                                            "SpynetReporting"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet",
                                            "SubmitSamplesConsent") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        HomeGroups
                                        {
                                            # (Null/No Registry)
                                        }
                                        RemoteAssistance
                                        {
                                            $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance","fAllowToGetHelp")
                                        }
                                        RemoteDesktop
                                        {
                                            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server",
                                            "fDenyTSConnections"),
                                            ("HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp",
                                            "UserAuthentication") | % {
                                            
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                    }
                                }
                                Context
                                {
                                    Switch ($Item.Name)
                                    {
                                        CastToDevice
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked",
                                            "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}") | % { 
                                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        PreviousVersions
                                        {
                                            ("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                                            $Null),
                                            ("HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                                            $Null),
                                            ("HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                                            $Null),
                                            ("HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}",
                                            $Null) | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        IncludeInLibrary
                                        {
                                            $Item.Registry("HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location","(Default)")
                                        }
                                        PinToStart      
                                        {
                                            ("HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}",
                                            "(Default)"),
                                            ("HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}",
                                            "(Default)"),
                                            ("HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen",
                                            "(Default)"),
                                            ("HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen",
                                            "(Default)"),
                                            ("HKCR:\Microsoft.Website\shellex\ContextMenuHandlers\PintoStartScreen",
                                            "(Default)"),
                                            ("HKCR:\mscfile\shellex\ContextMenuHandlers\PintoStartScreen",
                                            "(Default)") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        PinToQuickAccess
                                        {
                                            ("HKCR:\Folder\shell\pintohome",
                                            "MUIVerb"),
                                            ("HKCR:\Folder\shell\pintohome",
                                            "AppliesTo"),
                                            ("HKCR:\Folder\shell\pintohome\command",
                                            "DelegateExecute"),
                                            ("HKLM:\SOFTWARE\Classes\Folder\shell\pintohome",
                                            "MUIVerb"),
                                            ("HKLM:\SOFTWARE\Classes\Folder\shell\pintohome",
                                            "AppliesTo"),
                                            ("HKLM:\SOFTWARE\Classes\Folder\shell\pintohome\command",
                                            "DelegateExecute") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        ShareWith
                                        {
                                            ("HKCR:\*\shellex\ContextMenuHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\Directory\shellex\ContextMenuHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\Directory\shellex\CopyHookHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\Drive\shellex\ContextMenuHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\Directory\shellex\PropertySheetHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing",
                                            "(Default)"),
                                            ("HKCR:\*\shellex\ContextMenuHandlers\ModernSharing",
                                            "(Default)") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        SendTo
                                        {
                                            $Item.Registry("HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo","(Default)")
                                        }
                                    }
                                }
                                Taskbar
                                {
                                    Switch ($Item.Name)
                                    {
                                        BatteryUIBar
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell","UseWin32BatteryFlyout")
                                        }
                                        ClockUIBar
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell",
                                            "UseWin32TrayClockExperience") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        VolumeControlBar
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC","EnableMtcUvc")
                                        }
                                        TaskbarSearchBox
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode")
                                        }
                                        TaskViewButton
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowTaskViewButton")
                                        }
                                        TaskbarIconSize
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","TaskbarSmallIcons")
                                        }
                                        TaskbarGrouping
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","TaskbarGlomLevel")
                                        }
                                        TrayIcons
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","EnableAutoTray"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","EnableAutoTray") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        SecondsInClock
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowSecondsInSystemClock")
                                        }
                                        LastActiveClick
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","LastActiveClick")
                                        }
                                        TaskbarOnMultiDisplay
                                        {
                                            $Item.Registry("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","MMTaskbarEnabled")
                                        }
                                        TaskbarButtonDisplay
                                        {
                                            $Item.Registry("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","MMTaskbarMode")
                                        }
                                    }
                                }
                                StartMenu
                                {
                                    Switch ($Item.Name)
                                    {
                                        StartMenuWebSearch
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","BingSearchEnabled"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","DisableWebSearch") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        StartSuggestions
                                        {
                                            $xPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
                                            
                                            ($xPath,"ContentDeliveryAllowed"),
                                            ($xPath,"OemPreInstalledAppsEnabled"),
                                            ($xPath,"PreInstalledAppsEnabled"),
                                            ($xPath,"PreInstalledAppsEverEnabled"),
                                            ($xPath,"SilentInstalledAppsEnabled"),
                                            ($xPath,"SystemPaneSuggestionsEnabled"),
                                            ($xPath,"Start_TrackProgs"),
                                            ($xPath,"SubscribedContent-314559Enabled"),
                                            ($xPath,"SubscribedContent-310093Enabled"),
                                            ($xPath,"SubscribedContent-338387Enabled"),
                                            ($xPath,"SubscribedContent-338388Enabled"),
                                            ($xPath,"SubscribedContent-338389Enabled"),
                                            ($xPath,"SubscribedContent-338393Enabled"),
                                            ($xPath,"SubscribedContent-338394Enabled"),
                                            ($xPath,"SubscribedContent-338396Enabled"),
                                            ($xPath,"SubscribedContent-338398Enabled") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        MostUsedAppStartMenu
                                        {
                                            $Item.Registry("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced","Start_TrackProgs")
                                        }
                                        RecentItemsFrequent
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "Start_TrackDocs") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        UnpinItems
                                        {
                                            # (Null/No Registry)
                                        }
                                    }
                                }
                                Explorer
                                {
                                    Switch ($Item.Name)
                                    {
                                        AccessKeyPrompt
                                        {
                                            ("HKCU:\Control Panel\Accessibility\StickyKeys",
                                            "Flags"),
                                            ("HKCU:\Control Panel\Accessibility\ToggleKeys",
                                            "Flags"),
                                            ("HKCU:\Control Panel\Accessibility\Keyboard Response",
                                            "Flags") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        F1HelpKey
                                        {
                                            ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0",
                                            $Null),
                                            ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32",
                                            "(Default)"),
                                            ("HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64",
                                            "(Default)") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        AutoPlay
                                        {
                                            # (Null/No Registry)
                                        }
                                        AutoRun
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoDriveTypeAutoRun")
                                        }
                                        PidInTitleBar
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","ShowPidInTitle")
                                        }
                                        RecentFileQuickAccess
                                        {
                                            # (Null/No Registry)
                                        }
                                        FrequentFoldersQuickAccess
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer","ShowFrequent")
                                        }
                                        WinContentWhileDrag
                                        {
                                            $Item.Registry("HKCU:\Control Panel\Desktop","DragFullWindows")
                                        }
                                        StoreOpenWith
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer","NoUseStoreOpenWith")
                                        }
                                        LongFilePath
                                        {
                                            ("HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem",
                                            "LongPathsEnabled"),
                                            ("HKLM:\SYSTEM\ControlSet001\Control\FileSystem",
                                            "LongPathsEnabled") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        ExplorerOpenLoc
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","LaunchTo")
                                        }
                                        WinXPowerShell
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","DontUsePowerShellOnWinX")
                                        }
                                        AppHibernationFile
                                        {
                                            $Item.Registry("HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management","SwapfileControl")
                                        }
                                        KnownExtensions
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","HideFileExt")
                                        }
                                        HiddenFiles
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","Hidden")
                                        }
                                        SystemFiles
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowSuperHidden")
                                        }
                                        Timeline
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System","EnableActivityFeed")
                                        }
                                        AeroSnap
                                        {
                                            $Item.Registry("HKCU:\Control Panel\Desktop","WindowArrangementActive")
                                        }
                                        AeroShake
                                        {
                                            $Item.Registry("HKCU:\Software\Policies\Microsoft\Windows\Explorer","NoWindowMinimizingShortcuts")     
                                        }
                                        TaskManagerDetails
                                        {
                                            $Item.Registry("HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager","Preferences")
                                        }
                                        ReopenAppsOnBoot
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","DisableAutomaticRestartSignOn")
                                        }
                                    }
                                }
                                ThisPCIcon
                                {
                                    Switch ($Item.Name)
                                    {
                                        Desktop
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag",
                                            "ThisPCPolicy") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Documents
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            "BaseFolderID"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag",
                                            "BaseFolderID") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Downloads
                                        {
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            "BaseFolderID"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag",
                                            "BaseFolderID") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Music
                                        {
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            "BaseFolderID"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag",
                                            "BaseFolderID") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Pictures
                                        {
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            "BaseFolderID"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag",
                                            "BaseFolderID") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Videos
                                        {
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            "BaseFolderID"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag",
                                            "BaseFolderID") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        ThreeDObjects
                                        {
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                                            "ThisPCPolicy"),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                                            $Null),
                                            ("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag",
                                            "ThisPCPolicy") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                    }
                                }
                                DesktopIcon
                                {
                                    Switch ($Item.Name)
                                    {
                                        ThisPC
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                                            "{20D04FE0-3AEA-1069-A2D8-08002B30309D}") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Network
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                                            "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        RecycleBin
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "{645FF040-5081-101B-9F08-00AA002F954E}"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                                            "{645FF040-5081-101B-9F08-00AA002F954E}") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        Profile
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                                            "{59031a47-3f72-44a7-89c5-5595fe6b30ee}") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        ControlPanel
                                        {
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
                                            "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
                                            "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}") | % { 
                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                    }
                                }
                                LockScreen
                                {
                                    Switch ($Item.Name)
                                    {
                                        LockScreen
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization","NoLockScreen")
                                        }
                                        Password
                                        {
                                            ("HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
                                            "ScreenSaverIsSecure"),
                                            ("HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop",
                                            "ScreenSaverIsSecure") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        PowerMenu
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","shutdownwithoutlogon")
                                        }
                                        Camera
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization","NoLockScreenCamera")
                                        }
                                    }
                                }
                                Miscellaneous
                                {
                                    Switch ($Item.Name)
                                    {
                                        ScreenSaver
                                        {
                                            $Item.Registry("HKCU:\Control Panel\Desktop","ScreenSaveActive")
                                        }
                                        AccountProtectionWarn
                                        {
                                            $Item.Registry("HKCU:\SOFTWARE\Microsoft\Windows Security Health\State","AccountProtection_MicrosoftAccount_Disconnected")
                                        }
                                        ActionCenter
                                        {
                                            ("HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer",
                                            "DisableNotificationCenter"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications",
                                            "ToastEnabled") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        StickyKeyPrompt
                                        {
                                            $Item.Registry("HKCU:\Control Panel\Accessibility\StickyKeys","Flags")
                                        }
                                        NumlockOnStart
                                        {
                                            $Item.Registry("HKU:\.DEFAULT\Control Panel\Keyboard","InitialKeyboardIndicators")
                                        }
                                        F8BootMenu
                                        {
                                            # (Null/No Registry)
                                        }
                                        RemoteUACAcctToken
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","LocalAccountTokenFilterPolicy")
                                        }
                                        HibernatePower
                                        {
                                            ("HKLM:\SYSTEM\CurrentControlSet\Control\Power","HibernateEnabled"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings","ShowHibernateOption") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        SleepPower
                                        {
                                            $Item.Registry("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings","ShowSleepOption")
                                        }
                                    }
                                }
                                PhotoViewer
                                {
                                    Switch ($Item.Name)
                                    {
                                        FileAssociation
                                        {
                                            ("HKCR:\Paint.Picture\shell\open",
                                            "MUIVerb"),
                                            ("HKCR:\giffile\shell\open",
                                            "MUIVerb"),
                                            ("HKCR:\jpegfile\shell\open",
                                            "MUIVerb"),
                                            ("HKCR:\pngfile\shell\open",
                                            "MUIVerb"),
                                            ("HKCR:\Paint.Picture\shell\open\command",
                                            "(Default)"),
                                            ("HKCR:\giffile\shell\open\command",
                                            "(Default)"),
                                            ("HKCR:\jpegfile\shell\open\command",
                                            "(Default)"),
                                            ("HKCR:\pngfile\shell\open\command",
                                            "(Default)"),
                                            ("HKCR:\giffile\shell\open",
                                            "CommandId"),
                                            ("HKCR:\giffile\shell\open\command",
                                            "DelegateExecute") | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        OpenWithMenu
                                        {
                                            ("HKCR:\Applications\photoviewer.dll\shell\open",
                                            $Null),
                                            ("HKCR:\Applications\photoviewer.dll\shell\open\command",
                                            $Null),
                                            ("HKCR:\Applications\photoviewer.dll\shell\open\DropTarget",
                                            $Null),
                                            ("HKCR:\Applications\photoviewer.dll\shell\open",
                                            "MuiVerb"),
                                            ("HKCR:\Applications\photoviewer.dll\shell\open\command",
                                            "(Default)"),
                                            ("HKCR:\Applications\photoviewer.dll\shell\open\DropTarget",
                                            "Clsid") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                    }
                                }
                                WindowsApps
                                {
                                    Switch ($Item.Name)
                                    {
                                        OneDrive
                                        {
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive",
                                            "DisableFileSyncNGSC"),
                                            ("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
                                            "ShowSyncProviderNotifications") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        OneDriveInstall
                                        {
                                            ("HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
                                            $Null),
                                            ("HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
                                            $Null) | % {
                                    
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        XboxDVR
                                        {
                                            ("HKCU:\System\GameConfigStore",
                                            "GameDVR_Enabled"),
                                            ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR",
                                            "AllowGameDVR") | % {
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                        MediaPlayer
                                        {
                                            # (Null/No Registry)
                                        }
                                        WorkFolders
                                        {
                                            # (Null/No Registry)
                                        }
                                        FaxAndScan
                                        {
                                            # (Null/No Registry)
                                        }
                                        LinuxSubsystem
                                        {
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowDevelopmentWithoutDevLicense"),
                                            ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowAllTrustedApps") | % { 
                                
                                                $Item.Registry($_[0],$_[1])
                                            }
                                        }
                                    }
                                }
                        }

                        $Branch.Output += $Item

                        $This.Update(1,$Item.Status)
                    }
                }

                $This.Update(0,"Refreshed [+] Setting Controller")
            }
            ElseIf ($Property -eq "Profile")
            {
                $This.Update(0,"Refreshing [~] User Profile Controller")

                $This.Profile.Refresh()

                $This.Update(1,"Refreshed [+] User Profile Controller")
            }
            Else
            {
                $This.Update(-1,"Error [!] Invalid property: $Property")
            }
        }
        RefreshAll()
        {
            $This.Update(0,"Refreshing [~] All items")

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

                        $This.Update(0,$Disk.Status)
        
                        $Branch.Output += $Disk
                    }

                    $This.Update(1,"Refreshed [+] Disk Controller")
                }
                Else
                {
                    $This.Refresh($Name)
                }
            }

            $This.Refresh("Setting")
            $This.Refresh("Profile")

            $This.Update(1,"Refreshed [+] All items")
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            $xSender.Items.Clear()

            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        [String] Escape([String]$String)
        {
            Return [Regex]::Escape($String)
        }
        [String] Runtime()
        {
            Return [DateTime]::Now.ToString("yyyyMMdd_HHmmss")
        }
        [Object] ViperBombProperty([Object]$Property)
        {
            Return [ViperBombProperty]::New($Property)
        }
        [Object] ViperBombFlag([UInt32]$Index,[String]$Name)
        {
            Return [ViperBombFlag]::New($Index,$Name)
        }
        [Object] ViperBombValidatePath([String]$Entry)
        {
            Return [ViperBombValidatePath]::New($Entry)
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
                Option
                {
                    "DevErrors",
                    "DevLog",
                    "DevConsole",
                    "DevReport",
                    "BypassBuild",
                    "BypassEdition",
                    "BypassLaptop",
                    "DisplayActive",
                    "DisplayInactive",
                    "DisplaySkipped",
                    "MiscSimulate",
                    "MiscXbox",
                    "MiscChange",
                    "MiscStopDisabled",
                    "LogService",
                    "LogScript",
                    "BackupRegistry",
                    "BackupConfig"
                }
                Control
                {
                    "Name",
                    "DisplayName",
                    "Value",
                    "Description"
                }
                Feature
                {
                    "Index",
                    "FeatureName",
                    "State",
                    "Path",
                    "Online",
                    "WinPath",
                    "SysDrivePath",
                    "RestartNeeded",
                    "LogPath",
                    "ScratchDirectory",
                    "LogLevel"
                }
                AppX
                {
                    "PackageName",
                    "DisplayName",
                    "PublisherID",
                    "Version",
                    "Architecture",
                    "ResourceID",
                    "InstallLocation",
                    "RestartNeeded",
                    "LogPath",
                    "LogLevel"
                }
            }

            Return $Item
        }
        [Object[]] Property([Object]$Object)
        {
            Return $Object.PSObject.Properties | % { $This.ViperBombProperty($_) }
        }
        [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
        {
            $List = $Object.PSObject.Properties
            $Item = Switch ($Mode)
            {
                0 { $List | ? Name -notin $Property } 1 { $List | ? Name -in $Property }
            }
    
            Return $Item | % { $This.ViperBombProperty($_) }
        }
        [String] LogPath()
        {
            Return "{0}\{1}\ViperBomb" -f $This.Module.ProgramData(), $This.Module.Company
        }
        [String] TargetPath([String]$Path,[String]$Name)
        {
            Return "{0}\{1}-{2}.txt" -f $Path, $This.Config.Time, $Name
        }
        [String] Label()
        {
            Return "{0}[System Control Extension Utility]" -f $This.Module.Label()
        }
        [String] AboutBlackViper()
        {
            Return ("BlackViper is the original author of the Black Viper "+
            "Service Configuration featured on his website. `nThe original"+
            " utility dealt with (*.bat) files to provide a service config"+
            "uration template for Windows services, dating back to the day"+
            "s of Windows (2000/XP).")
        }
        [String] AboutMadBomb122()
        {
            Return ("MadBomb122 is the author of the Windows PowerShell (G"+
            "UI/graphical user interface) tool that adopted Black Viper&ap"+
            "os;s service configuration (*.bat) files in a prior version o"+
            "f this utility, which is featured on his [GitHub] repository "+
            "above.")
        }
        [String] IconStatus([UInt32]$Flag)
        {
            $File = @("failure.png","success.png","warning.png")[$Flag]

            Return $This.Module._Control($File).Fullname
        }
        StageXaml()
        {
            $This.ModulePanel()
            $This.SystemPanel()
            $This.HotFixPanel()
            $This.FeaturePanel()
            $This.AppXPanel()
            $This.ApplicationPanel()
            $This.EventPanel()
            $This.TaskPanel()
            $This.ServicePanel()
            $This.SettingPanel()
            $This.ProfilePanel()
        }
        ModulePanel()
        {
            $This.Update(0,"Staging [~] Module Panel")

            $Ctrl = $This

            # [OS]
            $Ctrl.Reset($Ctrl.Xaml.IO.OS,$Ctrl.Module.OS)

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

            # [Edition Panel]
            $Ctrl.Reset($Ctrl.Xaml.IO.EditionCurrent,$Ctrl.System.Edition.Current)

            # [Current Panel, Current Properties]
            $Ctrl.Reset($Ctrl.Xaml.IO.EditionProperty,$Ctrl.System.Edition.Property)

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
        HotFixPanel()
        {
            $This.Update(0,"Staging [~] HotFix Panel")

            $Ctrl = $This

            # [Operating System]
            $Ctrl.Reset($Ctrl.Xaml.IO.OperatingSystem,$Ctrl.System.OS)

            # [Hot Fix]
            $Ctrl.Reset($Ctrl.Xaml.IO.HotFixOutput,$Ctrl.HotFix.Output)

            $Ctrl.Xaml.IO.HotFixSearchFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.HotFixSearchProperty,
                                    $Ctrl.Xaml.IO.HotFixSearchFilter,
                                    $Ctrl.HotFix.Output,
                                    $Ctrl.Xaml.IO.HotFixOutput)
            })
            
            $Ctrl.Xaml.IO.HotFixRefresh.Add_Click(
            {
                $Ctrl.Refresh("HotFix")
                $Ctrl.Reset($Ctrl.Xaml.IO.HotFixOutput,$Ctrl.HotFix.Output)
            })
            
            $Ctrl.Xaml.IO.HotFixProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("HotFix")
            })
            
            $Ctrl.Xaml.IO.HotFixProfileLoad.Add_Click(
            {
                $Ctrl.HotFix.Profile.SetPath($Ctrl.Xaml.IO.HotFixProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.HotFixProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("HotFixProfilePath")
            })
            
            $Ctrl.Xaml.IO.HotFixProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.HotFixProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("HotFixProfilePath")
                }
            })

            # $Ctrl.Panel("HotFix")

            $This.Update(1,"Staged [+] HotFix Panel")
        }
        FeaturePanel()
        {
            $This.Update(0,"Staging [~] Feature Panel")

            $Ctrl = $This

            # [Feature]
            $Ctrl.Reset($Ctrl.Xaml.IO.FeatureOutput,$Ctrl.Feature.Output)

            $Ctrl.Xaml.IO.FeatureFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.FeatureProperty,
                                    $Ctrl.Xaml.IO.FeatureFilter,
                                    $Ctrl.Feature.Output,
                                    $Ctrl.Xaml.IO.FeatureOutput)
            })
            
            $Ctrl.Xaml.IO.FeatureRefresh.Add_Click(
            {
                $Ctrl.Refresh("Feature")
                $Ctrl.Reset($Ctrl.Xaml.IO.FeatureOutput,$Ctrl.Feature.Output)
            })
            
            $Ctrl.Xaml.IO.FeatureProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("Feature")
            })
            
            $Ctrl.Xaml.IO.FeatureProfileLoad.Add_Click(
            {
                $Ctrl.Feature.Profile.SetPath($Ctrl.Xaml.IO.FeatureProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.FeatureProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("FeatureProfilePath")
            })
            
            $Ctrl.Xaml.IO.FeatureProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.FeatureProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("FeatureProfilePath")
                }
            })

            # $Ctrl.Panel("Feature")

            $This.Update(1,"Staged [+] Feature Panel")
        }
        AppXPanel()
        {
            $This.Update(0,"Staging [~] AppX Panel")

            $Ctrl = $This

            # [AppX]
            $Ctrl.Reset($Ctrl.Xaml.IO.AppXOutput,$Ctrl.AppX.Output)

            $Ctrl.Xaml.IO.AppXFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.AppXProperty,
                                    $Ctrl.Xaml.IO.AppXFilter,
                                    $Ctrl.AppX.Output,
                                    $Ctrl.Xaml.IO.AppXOutput)
            })
            
            $Ctrl.Xaml.IO.AppXRefresh.Add_Click(
            {
                $Ctrl.Refresh("AppX")
                $Ctrl.Reset($Ctrl.Xaml.IO.AppXOutput,$Ctrl.AppX.Output)
            })
            
            $Ctrl.Xaml.IO.AppXProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("AppX")
            })
            
            $Ctrl.Xaml.IO.AppXProfileLoad.Add_Click(
            {
                $Ctrl.AppX.Profile.SetPath($Ctrl.Xaml.IO.AppXProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.AppXProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("AppXProfilePath")
            })
            
            $Ctrl.Xaml.IO.AppXProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.AppXProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("AppXProfilePath")
                }
            })

            # $Ctrl.Panel("AppX")

            $This.Update(1,"Staged [+] AppX Panel")
        }
        ApplicationPanel()
        {
            $This.Update(0,"Staging [~] Application Panel")

            $Ctrl = $This

            # [Application]
            $Ctrl.Reset($Ctrl.Xaml.IO.ApplicationOutput,$Ctrl.Application.Output)

            $Ctrl.Xaml.IO.ApplicationFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ApplicationProperty,
                                    $Ctrl.Xaml.IO.ApplicationFilter,
                                    $Ctrl.Application.Output,
                                    $Ctrl.Xaml.IO.ApplicationOutput)
            })
            
            $Ctrl.Xaml.IO.ApplicationRefresh.Add_Click(
            {
                $Ctrl.Refresh("Application")
                $Ctrl.Reset($Ctrl.Xaml.IO.ApplicationOutput,$Ctrl.Application.Output)
            })
            
            $Ctrl.Xaml.IO.ApplicationProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("Application")
            })
            
            $Ctrl.Xaml.IO.ApplicationProfileLoad.Add_Click(
            {
                $Ctrl.System.Application.Profile.SetPath($Ctrl.Xaml.IO.ApplicationProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.ApplicationProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("ApplicationProfilePath")
            })
            
            $Ctrl.Xaml.IO.ApplicationProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.ApplicationProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("ApplicationProfilePath")
                }
            })

            # $Ctrl.Panel("Application")

            $This.Update(1,"Staged [+] Application Panel")
        }
        EventPanel()
        {
            $This.Update(0,"Staging [~] EventLog Panel")

            $Ctrl = $This

            # [Event]
            $Ctrl.Reset($Ctrl.Xaml.IO.EventOutput,$Ctrl.EventLog.Output)

            $Ctrl.Xaml.IO.EventFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.EventProperty,
                                    $Ctrl.Xaml.IO.EventFilter,
                                    $Ctrl.EventLog.Output,
                                    $Ctrl.Xaml.IO.EventOutput)
            })
            
            $Ctrl.Xaml.IO.EventRefresh.Add_Click(
            {
                $Ctrl.Refresh("EventLog")
                $Ctrl.Reset($Ctrl.Xaml.IO.EventOutput,$Ctrl.EventLog.Output)
            })
            
            $Ctrl.Xaml.IO.EventProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("EventLog")
            })
            
            $Ctrl.Xaml.IO.EventProfileLoad.Add_Click(
            {
                $Ctrl.System.Event.Profile.SetPath($Ctrl.Xaml.IO.EventProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.EventProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("EventProfilePath")
            })
            
            $Ctrl.Xaml.IO.EventProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.EventProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("EventProfilePath")
                }
            })

            # $Ctrl.Panel("EventLog")

            $This.Update(1,"Staged [+] EventLog Panel")
        }
        TaskPanel()
        {
            $This.Update(0,"Staging [~] Task Panel")

            $Ctrl = $This

            # [Task]
            $Ctrl.Reset($Ctrl.Xaml.IO.TaskOutput,$Ctrl.Task.Output)

            $Ctrl.Xaml.IO.TaskFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.TaskProperty,
                                    $Ctrl.Xaml.IO.TaskFilter,
                                    $Ctrl.Task.Output,
                                    $Ctrl.Xaml.IO.TaskOutput)
            })
            
            $Ctrl.Xaml.IO.TaskRefresh.Add_Click(
            {
                $Ctrl.Refresh("Task")
                $Ctrl.Reset($Ctrl.Xaml.IO.TaskOutput,$Ctrl.Task.Output)
            })
            
            $Ctrl.Xaml.IO.TaskProfileSwitch.Add_Click(
            {
                # $Ctrl.Panel("Task")
            })
            
            $Ctrl.Xaml.IO.TaskProfileLoad.Add_Click(
            {
                $Ctrl.System.Task.Profile.SetPath($Ctrl.Xaml.IO.TaskProfilePath.Text)
            })
            
            $Ctrl.Xaml.IO.TaskProfileBrowse.Add_Click(
            {
                $Ctrl.FileBrowse("TaskProfilePath")
            })
            
            $Ctrl.Xaml.IO.TaskProfilePath.Add_TextChanged(
            {
                If ($Ctrl.Xaml.IO.TaskProfileSwitch.IsChecked)
                {
                    $Ctrl.CheckPath("TaskProfilePath")
                }
            })

            # $Ctrl.Panel("Task")

            $This.Update(1,"Staged [+] Task Panel")
        }
        ServicePanel()
        {
            $This.Update(0,"Staging [~] Service Panel")
            
            $Ctrl = $This

            # [Service]
            # $Ctrl.Reset($Ctrl.Xaml.IO.ServiceSlot,$Ctrl.Service.Output.Index)

            <#
            $Ctrl.Xaml.IO.ServiceSlot.Add_SelectionChanged(
            {
                $Index = $Ctrl.Xaml.IO.ServiceSlot.SelectedItem
                $Ctrl.Reset($Ctrl.Xaml.IO.ServiceDescription,$Ctrl.Config.Service.Output[$Index])
                $Ctrl.SetSlot($Index)
            })
            
            $Ctrl.Config.SetDefault($Ctrl.System.OS.Caption)

            $Ctrl.Xaml.IO.ServiceSlot.SelectedIndex = $Ctrl.Config.Slot.Index

            $Ctrl.Xaml.IO.ServiceFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.ServiceProperty,
                                    $Ctrl.Xaml.IO.ServiceFilter,
                                    $Ctrl.Service.Output,
                                    $Ctrl.Xaml.IO.ServiceOutput)
            })
            #>

            $Ctrl.Reset($Ctrl.Xaml.IO.ServiceOutput,$Ctrl.Service.Output)

            $Ctrl.Xaml.IO.ServiceBlackViper.Text = $Ctrl.AboutBlackViper()
            $Ctrl.Xaml.IO.ServiceMadBomb122.Text = $Ctrl.AboutMadBomb122()

            <#
            # [Set Option Defaults]
            ForEach ($String in $Ctrl.Grid("Option"))
            {
                $Item = $Ctrl.Option($String)
                $Item.SetValue($Ctrl.Config.$String)
            }

            If (!(Test-Path $Ctrl.LogPath()))
            {
                $Ctrl.BuildPath($Ctrl.LogPath())
            }

            $Ctrl.Xaml.IO.ServiceOptionPath.Add_TextChanged(
            {
                $Ctrl.CheckPath("ServiceOptionPath")
                $Ctrl.Xaml.IO.ServiceOptionPathSet.IsEnabled = [UInt32]$Ctrl.Flag.ServiceOptionPath.Value -ne 0
            })

            $Ctrl.Xaml.IO.ServiceOptionPath.Text = $Ctrl.LogPath()

            $Ctrl.Xaml.IO.ServiceOptionPathBrowse.Add_Click(
            {
                $Ctrl.FolderBrowse("ServiceOptionPath")
            })

            $Ctrl.Xaml.IO.ServiceOptionPathSet.Add_Click(
            {
                $Ctrl.BuildPath($Ctrl.LogPath())
                $Ctrl.Config.SetPath($Ctrl.Xaml.IO.ServiceOptionPath.Text)
            })

            $Ctrl.Xaml.IO.ServiceOptionApply.Add_Click(
            {
                ForEach ($Item in $Ctrl.Xaml.IO.ServiceOptionList.Items)
                {
                    $Item = $Ctrl.Option($Item.Name)
                    $Item.SetValue($Item.Value)
                }
            })

            $Ctrl.Reset($Ctrl.Xaml.IO.ServiceOptionList,$Ctrl.Option.Output)

            $Ctrl.Xaml.IO.ServiceOptionSlot.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Preference.Output[$Ctrl.Xaml.IO.ServiceOptionSlot.SelectedIndex]
                $Ctrl.Reset($Ctrl.Xaml.IO.ServiceOptionDescription,$Item)
            })

            $Ctrl.Xaml.IO.ServiceOptionSlot.SelectedIndex = 0
            #>

            $This.Update(1,"Staged [~] Service Panel")
        }
        SettingPanel()
        {
            $This.Update(0,"Staging [~] Settings Panel")
            
            $Ctrl = $This

            # [Control Subtab]
            $Ctrl.Reset($Ctrl.Xaml.IO.SettingOutput,$Ctrl.Setting.Output)

            $Ctrl.Xaml.IO.SettingSlot.Add_SelectionChanged(
            {
                $Slot = $Ctrl.Xaml.IO.SettingSlot.SelectedItem.Content.Replace(" ","")
                $Item = $Ctrl.Setting.Output
                $List = Switch ($Slot)
                {
                    Default { $Item | ? Source -eq $Slot } All { $Item }
                }

                $Ctrl.Reset($Ctrl.Xaml.IO.SettingOutput,$List)
            })

            $Ctrl.Xaml.IO.SettingFilter.Add_TextChanged(
            {
                $Ctrl.SearchControl($Ctrl.Xaml.IO.SettingProperty,
                                    $Ctrl.Xaml.IO.SettingFilter,
                                    $Ctrl.Setting.Output,
                                    $Ctrl.Xaml.IO.SettingOutput)
            })

            $This.Update(1,"Staged [+] Settings Panel")
        }
        ProfilePanel()
        {
            $This.Update(0,"Staging [~] Profile Panel")
            
            $Ctrl = $This

            $Ctrl.Xaml.IO.ProfileType.Add_SelectionChanged(
            {
                $Item = Switch ($Ctrl.Xaml.IO.ProfileType.SelectedIndex)
                {
                    0  { $Ctrl.Profile.Output         }
                    1  { $Ctrl.Profile.System.Output  }
                    2  { $Ctrl.Profile.Service.Output }
                    3  { $Ctrl.Profile.User.Output    }
                }

                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileOutput,$Item)
            })

            $Ctrl.Xaml.IO.ProfileType.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileSearchFilter.Add_TextChanged(
            {
                $Item = Switch ($Ctrl.Xaml.IO.ProfileType.SelectedIndex)
                {
                    0 { $Ctrl.Profile.Output }
                    1 { $Ctrl.Profile.$($Ctrl.Xaml.IO.ProfileType.SelectedItem.Content).Output }
                }

                $Ctrl.SearchControl($Ctrl.Xaml.IO.ProfileSearchProperty,
                                    $Ctrl.Xaml.IO.ProfileSearchFilter,
                                    $Item,
                                    $Ctrl.Xaml.IO.ProfileOutput)
            })

            $Ctrl.Xaml.IO.ProfileMode.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Profile.Output | ? Index -eq $Ctrl.Xaml.IO.ProfileMode.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileModeDescription,$Item)
            })

            $Ctrl.Xaml.IO.ProfileMode.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileProcess.Add_SelectionChanged(
            {
                $Item = $Ctrl.Config.Process.Output | ? Index -eq $Ctrl.Xaml.IO.ProfileProcess.SelectedIndex
                $Ctrl.Reset($Ctrl.Xaml.IO.ProfileProcessDescription,$Item)
            })

            $Ctrl.Xaml.IO.ProfileProcess.SelectedIndex = 0

            $Ctrl.Xaml.IO.ProfileLoad.Add_Click(
            {
                $Item = $Ctrl.Xaml.IO.ProfileOutput.SelectedItem

                Switch ($Item.Type)
                {
                    Default
                    {
                        [System.Windows.MessageBox]::Show("Cannot load a system or service account","Account Selection Error")
                    }
                    User
                    {
                        $Ctrl.Update(0,"Loading [~] User Profile [$($Item.Account)]")
                        $Item.GetContent()
                        $Ctrl.SetProfile()
                    }
                }
            })

            $Ctrl.Xaml.IO.ProfileOutput.Add_SelectionChanged(
            {
                $Ctrl.SetProfile()
            })

            $Ctrl.Xaml.IO.ProfileTarget.Add_TextChanged(
            {
                $Ctrl.CheckPath("ProfileTarget")
            })

            $Ctrl.Xaml.IO.ProfileBrowse.Add_Click(
            {
                $Ctrl.FolderBrowse("ProfileTarget")
            })

            $This.Update(1,"Staged [+] Profile Panel")
        }
        SetProfile()
        {
            $Item = $This.Xaml.IO.ProfileOutput.SelectedItem

            Switch ($Item.Type)
            {
                Default
                {
                    $This.Xaml.IO.ProfileLoad.IsEnabled   = 0
                    $This.Xaml.IO.ProfileSize.Text        = "N/A"
                    $This.Xaml.IO.ProfileCount.Text       = "N/A"
                    $This.Xaml.IO.ProfileBrowse.IsEnabled = 0
                }
                User
                {
                    $This.Xaml.IO.ProfileLoad.IsEnabled   = 1
                    $This.Xaml.IO.ProfileSize.Text        = $Item.Size.Size
                    $This.Xaml.IO.ProfileCount.Text       = $Item.Content.Count
                    $This.Xaml.IO.ProfileBrowse.IsEnabled = 1
                }
            }

            # Sid panel
            $This.Reset($This.Xaml.IO.ProfileSid,$This.Property($Item.Sid,0,"Property"))

            # Property panel
            $This.Reset($This.Xaml.IO.ProfileProperty,$Item.Sid.Property)

            # Content Panel
            $This.Xaml.IO.ProfilePath.Text = $Item.Path
            $This.Reset($This.Xaml.IO.ProfileContent,$Item.Content)
        }
        [Object] GetHotFix([String]$HotFixID)
        {
            Return $This.HotFix.Output | ? HotFixID -eq $HotFixID
        }
        [Object] GetHotFix([String]$Property,[String]$Value)
        {
            Return $This.HotFix.Output | ? $Property -match $Value
        }
        [Object] GetFeature([String]$FeatureName)
        {
            Return $This.Feature.Output | ? FeatureName -eq $FeatureName
        }
        [Object] GetFeature([String]$Property,[String]$Value)
        {
            Return $This.Feature.Output | ? $Property -match $Value
        }
        [Object] GetAppX([String]$DisplayName)
        {
            Return $This.AppX.Output | ? DisplayName -eq $DisplayName
        }
        [Object] GetAppX([String]$Property,[String]$Value)
        {
            Return $This.AppX.Output | ? $Property -match $Value
        }
        [Object] GetApplication([String]$DisplayName)
        {
            Return $This.Application.Output | ? DisplayName -eq $DisplayName
        }
        [Object] GetApplication([String]$Property,[String]$Value)
        {
            Return $This.Application.Output | ? $Property -match $Value
        }
        [Object] GetEventLog([String]$EventLogName)
        {
            Return $This.EventLog.Output | ? Name -eq $EventLogName
        }
        [Object] GetEventLog([String]$Property,[String]$Value)
        {
            Return $This.EventLog.Output | ? $Property -match $Value
        }
        [Object] GetTask([String]$TaskName)
        {
            Return $This.Task | ? TaskName -eq $TaskName
        }
        [Object] GetTask([String]$Property,[String]$Value)
        {
            Return $This.Task.Output | ? $Property -match $Value
        }
        [Object] GetService([String]$ServiceName)
        {
            Return $This.Service.Output | ? Name -eq $ServiceName
        }
        [Object] GetService([String]$Property,[String]$Value)
        {
            Return $This.Service.Output | ? $Property -match $Value
        }
        [Object] GetSetting([String]$SettingName)
        {
            Return $This.Setting.Output | ? Name -eq $SettingName
        }
        [Object] GetSetting([String]$Property,[String]$value)
        {
            Return $This.Setting.Output | ? $Property -match $Value
        }
        EnableTask([String]$TaskName)
        {
            $xTask = $This.GetTask($TaskName)
            If ($xTask -and $xTask.State -ne "Ready")
            {
                Enable-ScheduledTask -TaskName $TaskName -Verbose
            }
        }
        DisableTask([String]$TaskName)
        {
            $xTask = $This.GetTask($TaskName)
            If ($xTask -and $xTask.State -ne "Disabled")
            {
                Disable-ScheduledTask -TaskName $TaskName -Verbose
            }
        }
        EnableFeature([String]$FeatureName)
        {
            $xFeature = $This.GetFeature($FeatureName)
            If ($xFeature)
            {
                Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -Verbose
            }
        }
        DisableFeature([String]$FeatureName)
        {
            $xFeature = $This.GetFeature($FeatureName)
            If ($xFeature)
            {
                Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -Verbose
            }
        }
        StartService([String]$ServiceName)
        {
            $xService = $This.GetService($ServiceName)
            If ($xService -and $xService.Status -ne "Running")
            {
                Start-Service -Name $ServiceName -Verbose
            }
        }
        StopService([String]$ServiceName)
        {
            $xService = $This.GetService($ServiceName)
            If ($xService -and $xService.Status -ne "Stopped")
            {
                Stop-Service -Name $ServiceName -Verbose
            }
        }
        SetService([String]$ServiceName,[String]$StartupType)
        {
            $xService = $This.GetService($ServiceName)
            If ($xService -and $xService.StartupType -ne $StartupType)
            {
                Set-Service -Name $ServiceName -StartupType $StartupType -Verbose
            }
        }
        ApplySetting([Object]$SettingName,[UInt32]$Mode)
        {
            $Item = $This.GetSetting($SettingName)

            Switch ($Item.Source)
            {
                Privacy
                {
                    Switch ($Item.Name)
                    {
                        Telemetry
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Telemetry")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Telemetry")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[2].Set(0)
                                    }
                                    3..10 | % { $Item.Output[$_].Remove() }
                                    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                                    "Microsoft\Windows\Application Experience\ProgramDataUpdater",
                                    "Microsoft\Windows\Autochk\Proxy",
                                    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                                    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                                    "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                                    "Microsoft\Office\Office ClickToRun Service Monitor",
                                    "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
                                    "Microsoft\Office\OfficeTelemetryAgentLogOn2016" | % { $This.EnableTask($_) }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Telemetry")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[2].Set(0)
                                    }
                                    $Item.Output[ 3].Set(0)
                                    $Item.Output[ 4].Set(1)
                                    $Item.Output[ 5].Set(0)
                                    $Item.Output[ 6].Set(0)
                                    $Item.Output[ 7].Set(1)
                                    $Item.Output[ 8].Set(0)
                                    $Item.Output[ 9].Set(1)
                                    $Item.Output[10].Set(0)
                                    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                                    "Microsoft\Windows\Application Experience\ProgramDataUpdater",
                                    "Microsoft\Windows\Autochk\Proxy",
                                    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                                    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                                    "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                                    "Microsoft\Office\Office ClickToRun Service Monitor",
                                    "Microsoft\Office\OfficeTelemetryAgentFallBack2016",
                                    "Microsoft\Office\OfficeTelemetryAgentLogOn2016" | % { $This.DisableTask($_) }
                                }
                            }
                        }
                        WiFiSense
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [-] Wi-Fi Sense")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Wi-Fi Sense")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                    $Item.Output[2].Set(0)
                                    $Item.Output[3].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Wi-Fi Sense")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                    $Item.Output[2].Remove()
                                    $Item.Output[3].Remove()
                                }
                            }
                        }
                        SmartScreen
                        {    
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [-] SmartScreen Filter")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] SmartScreen Filter")
                                    $Item.Output[0].Set("String","RequireAdmin")
                                    1..3 | % { $Item.Output[$_].Remove() }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] SmartScreen Filter")
                                    $Item.Output[0].Set("String","Off")
                                    1..3 | % { $Item.Output[$_].Set(0) }
                                }
                            }
                        }
                        LocationTracking
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Location Tracking")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Location Tracking")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Location Tracking")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        Feedback
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Feedback")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Feedback")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                                    {
                                        $This.EnableTask($Item)
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Feedback")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(1)
                                    ForEach ($Item in "Microsoft\Windows\Feedback\Siuf\DmClient",
                                                      "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload")
                                    {
                                        $This.DisableTask($Item)
                                    }
                                }
                            }
                        }
                        AdvertisingID
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Advertising ID")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Advertising ID")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Set(2)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Advertising ID")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        Cortana
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0, "Skipping [!] Cortana")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Cortana")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    $Item.Output[2].Set(0)
                                    $Item.Output[3].Set(0)
                                    $Item.Output[4].Remove()
                                    $Item.Output[5].Remove()
                                    $Item.Output[6].Remove()
                                    $Item.Output[7].Set(1)
                                    $Item.Output[8].Remove()
                                    $Item.Output[9].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Cortana")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(1)
                                    $Item.Output[2].Set(1)
                                    $Item.Output[3].Set(0)
                                    $Item.Output[4].Set(0)
                                    $Item.Output[5].Set(1)
                                    $Item.Output[6].Set(3)
                                    $Item.Output[7].Set(0)
                                    $Item.Output[8].Set(0)
                                    $Item.Output[9].Set(1)
                                }
                            }
                        }
                        CortanaSearch
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Cortana Search")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Cortana Search")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Cortana Search")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        ErrorReporting
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Error Reporting")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Error Reporting")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Error Reporting")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        AutoLoggerFile
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] AutoLogger")
                                }
                                1
                                {
                                    $Item.Update(1,"Unrestricting [~] AutoLogger")
                                    $This.SetAcl("/grant:r SYSTEM:`(OI`)`(CI`)F")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Removing [~] AutoLogger, and restricting directory")
                                    $This.SetAcl("/deny SYSTEM:`(OI`)`(CI`)F")
                                    Remove-Item "$($This.Setting.AutoLoggerPath)\AutoLogger-Diagtrack-Listener.etl" -EA 0 -Verbose
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        DiagTrack
                        {
                            $Name = "DiagTrack"
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Diagnostics Tracking")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Diagnostics Tracking")
                                    $This.SetService($Name,"Automatic")
                                    $This.StartService($Name)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Diagnostics Tracking")
                                    $This.StopService($Name)
                                    $This.SetService($Name,"Disabled")
                                }
                            }
                        }
                        WAPPush
                        {
                            $Name = "dmwapppushservice"
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] WAP Push")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] WAP Push Service")
                                    $This.SetService($Name,"Automatic")
                                    $This.StartService($Name)
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] WAP Push Service")
                                    $This.StopService($Name)
                                    $This.SetService($Name,"Disabled")
                                }
                            }
                        }
                    }
                }
                WindowsUpdate
                {
                    Switch ($Item.Name)
                    {
                        UpdateMSProducts
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Update Microsoft Products")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Update Microsoft Products")
                                    $This.ComMusm().AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Update Microsoft Products")
                                    $This.ComMusm().RemoveService("7971f918-a847-4430-9279-4a52d1efe18d")
                                }
                            }
                        }
                        CheckForWindowsUpdate
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Check for Windows Updates")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Check for Windows Updates")
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Check for Windows Updates")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        WinUpdateType
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Windows Update Check Type")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Notify for Windows Update downloads, notify to install")
                                    $Item.Output[0].Set(2)
                                }
                                2
                                {
                                    $Item.Update(2,"Enabling [~] Automatically download Windows Updates, notify to install")
                                    $Item.Output[0].Set(3)
                                }
                                3
                                {
                                    $Item.Update(3,"Enabling [~] Automatically download Windows Updates, schedule to install")
                                    $Item.Output[0].Set(4)
                                }
                                4
                                {
                                    $Item.Update(4,"Enabling [~] Allow local administrator to choose automatic updates")
                                    $Item.Output[0].Set(5)
                                }
                            }
                        }
                        WinUpdateDownload
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] ")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Unrestricting Windows Update P2P to Internet")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Enabling [~] Restricting Windows Update P2P only to local network")
                                    $Item.Output[1].Set(3)
                                    Switch ($This.Setting.Version)
                                    {
                                        1507
                                        {
                                            $Item.Output[0]
                                        }
                                        {$_ -gt 1507 -and $_ -le 1607}
                                        {
                                            $Item.Output[0].Set(1)
                                        }
                                        Default
                                        {
                                            $Item.Output[0].Remove()
                                        }
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Disabling [~] Windows Update P2P")
                                    $Item.Output[1].Set(3)
                                    Switch ($This.Setting.Version)
                                    {
                                        1507
                                        {
                                            $Item.Output[0].Set(0)
                                        }
                                        Default
                                        {
                                            $Item.Output[3].Set(100)
                                        }
                                    }
                                }
                            }
                        }
                        UpdateMSRT
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Malicious Software Removal Tool Update")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Malicious Software Removal Tool Update")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Malicious Software Removal Tool Update")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        UpdateDriver
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Driver update through Windows Update")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Driver update through Windows Update")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    $Item.Output[2].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Driver update through Windows Update")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(1)
                                    $Item.Output[2].Set(1)
                                }
                            }
                        }
                        RestartOnUpdate
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Windows Update Automatic Restart")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Windows Update Automatic Restart")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Remove()
                                    $Item.Output[2].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Windows Update Automatic Restart")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                    $Item.Output[2].Set(0)
                                }
                            }
                        }
                        AppAutoDownload
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] App Auto Download")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] App Auto Download")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] App Auto Download")
                                    $Item.Output[0].Set(2)
                                    $Item.Output[1].Set(1)
                                    If ($This.Setting.Version -le 1803)
                                    {
                                        $Key  = Get-ChildItem $This.Setting.AppAutoCloudCache -Recurse | ? Name -like $This.Setting.AppAutoPlaceholder
                                        $Data = (Get-ItemProperty -Path $Key.PSPath).Data
                                        Set-ItemProperty -Path $Key -Name Data -Type Binary -Value $Data[0..15] -Verbose
                                        Stop-Process -Name ShellExperienceHost -Force
                                    }
                                }
                            }
                        }
                        UpdateAvailablePopup
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Update Available Popup")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Update Available Popup")
                                    $This.Setting.MUSNotify | % {
                
                                        $This.SetAcl("$_ /remove:d '`"Everyone`"'")
                                        $This.SetAcl("$_ /grant ('Everyone' + ':(OI)(CI)F')")
                                        $This.SetAcl("$_ /setowner 'NT SERVICE\TrustedInstaller'")
                                        $This.SetAcl("$_ /remove:g '`"Everyone`"'")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Update Available Popup")
                                    $Item.MUSNotify() | % {
                                        
                                        $This.SetOwnership("/f $_")
                                        $This.SetAcl("$_ /deny '`"Everyone`":(F)'")
                                    }
                                }
                            }
                        }
                    }
                }
                Service
                {
                    Switch ($Item.Name)
                    {
                        UAC
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] UAC Level")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] UAC Level (Low)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] UAC Level (Default)")
                                    $Item.Output[0].Set(5)
                                    $Item.Output[1].Set(1)
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] UAC Level (High)")
                                    $Item.Output[0].Set(2)
                                    $Item.Output[1].Set(1)
                                }
                            }
                        }
                        SharingMappedDrives
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Sharing mapped drives between users")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Sharing mapped drives between users")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Sharing mapped drives between users")
                                    $Item.Output[0].Remove()
                                }
                            }
                        }
                        AdminShares
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Hidden administrative shares")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Hidden administrative shares")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Hidden administrative shares")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        Firewall
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Firewall Profile")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Firewall Profile")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Firewall Profile")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        WinDefender
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Windows Defender")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Windows Defender")
                                    $Item.Output[0].Remove()
                                    Switch ($This.Setting.Version)
                                    {
                                        {$_ -lt 1703}
                                        {
                                            $Item.Output[1].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")
                                        }
                                        Default
                                        {
                                            $Item.Output[2].Set("ExpandString","`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"")     
                                        }
                                    }
                                    $Item.Output[3].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Windows Defender")
                                    Switch ($This.Setting.Version)
                                    {
                                        {$_ -lt 1703}
                                        {
                                            $Item.Output[1].Remove()
                                        }
                                        Default
                                        {
                                            $Item.Output[2].Remove()    
                                        }
                                    }
                                    $Item.Output[0].Set(1)
                                    $Item.Output[4].Set(0)
                                    $Item.Output[5].Set(2)
                                }
                            }
                        }
                        HomeGroups
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Home groups services")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Home groups services")
                                    $This.SetService("HomeGroupListener","Manual")
                                    $This.SetService("HomeGroupProvider","Manual")
                                    $This.StartService("HomeGroupProvider")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Home groups services")
                                    $This.StopService("HomeGroupListener")
                                    $This.SetService("HomeGroupListener","Disabled")
                                    $This.StopService("HomeGroupProvider")
                                    $This.SetService("HomeGroupProvider","Disabled")
                                }
                            }
                        }
                        RemoteAssistance
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Remote Assistance")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Remote Assistance")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Remote Assistance")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        RemoteDesktop
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Remote Desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Remote Desktop")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Remote Desktop")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                            }
                        }
                    }
                }
                Context
                {
                    Switch ($Item.Name)
                    {
                        CastToDevice
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Cast to device' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Cast to device' context menu item")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Cast to device' context menu item")
                                    $Item.Output[0].Set("String","Play to Menu")
                                }
                            }
                        }
                        PreviousVersions
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Previous versions' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Previous versions' context menu item")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Get()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Previous versions' context menu item")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    $Item.Output[2].Remove()
                                    $Item.Output[3].Remove()
                                }
                            }
                        }
                        IncludeInLibrary
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Include in Library' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Include in Library' context menu item")
                                    $Item.Output[0].Set("String","{3dad6c5d-2167-4cae-9914-f99e41c12cfa}")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Include in Library' context menu item")
                                    $Item.Output[0].Set("String","")
                                }
                            }
                        }
                        PinToStart
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Pin to Start' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Pin to Start' context menu item")
                                    $Item.Output[0].Set("String","Taskband Pin")
                                    $Item.Output[1].Set("String","Start Menu Pin")
                                    $Item.Output[2].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                                    $Item.Output[3].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                                    $Item.Output[4].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                                    $Item.Output[5].Set("String","{470C0EBD-5D73-4d58-9CED-E91E22E23282}")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Pin to Start' context menu item")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    $Item.Output[2].Set("String","")
                                    $Item.Output[3].Set("String","")
                                    $Item.Output[4].Set("String","")
                                    $Item.Output[5].Set("String","")
                                }
                            }
                        }
                        PinToQuickAccess
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Pin to Quick Access' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Pin to Quick Access' context menu item")
                                    $Item.Output[0].Set("String",'@shell32.dll,-51377')
                                    $Item.Output[1].Set("String",$This.Setting.QuickAccessParseName)
                                    $Item.Output[2].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                                    $Item.Output[3].Set("String",'@shell32.dll,-51377')
                                    $Item.Output[4].Set("String",$This.Setting.QuickAccessParseName)
                                    $Item.Output[5].Set("String","{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Pin to Quick Access' context menu item")
                                    $Item.Output[0].Name = $Null
                                    $Item.Output[0].Remove()
                                    $Item.Output[3].Name = $Null
                                    $Item.Output[3].Remove()
                                }
                            }
                        }
                        ShareWith
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Share with' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Share with' context menu item")
                                    0..7 | % { $Item.Output[$_].Set("String","{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}") }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Share with' context menu item")
                                    0..7 | % { $Item.Output[$_].Set("String","") }
                                }
                            }
                        }
                        SendTo
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Send to' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Send to' context menu item")
                                    $Item.Output[0].Set("String","{7BA4C740-9E81-11CF-99D3-00AA004AE837}")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Send to' context menu item")
                                    $Item.Output[0].Name = $Null
                                    $Item.Output[0].Remove()
                                }
                            }
                        }
                    }
                }
                Taskbar
                {
                    Switch ($Item.Name)
                    {
                        BatteryUIBar
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Battery UI Bar")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Battery UI Bar (New)")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Battery UI Bar (Old)")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        ClockUIBar
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Clock UI Bar")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Clock UI Bar (New)")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Clock UI Bar (Old)")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        VolumeControlBar
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Volume Control Bar")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Volume Control Bar (Horizontal)")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Volume Control Bar (Vertical)")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        TaskBarSearchBox
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Taskbar 'Search Box' button")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Taskbar 'Search Box' button")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Taskbar 'Search Box' button")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        TaskViewButton
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Task View button")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Task View button")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Task View button")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        TaskbarIconSize
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Icon size in taskbar")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Icon size in taskbar")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Icon size in taskbar")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        TaskbarGrouping
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Group Taskbar Items")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Group Taskbar Items (Never)")
                                    $Item.Output[0].Set(2)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Group Taskbar Items (Always)")
                                    $Item.Output[0].Set(0)
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Group Taskbar Items (When needed)")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        TrayIcons
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Tray Icons")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Tray Icons (Hiding)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Tray Icons (Showing)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        SecondsInClock
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Seconds in Taskbar clock")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Seconds in Taskbar clock")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Seconds in Taskbar clock")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        LastActiveClick
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Last active click")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Last active click")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Last active click")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        TaskbarOnMultiDisplay
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Taskbar on Multiple Displays")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Taskbar on Multiple Displays")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Taskbar on Multiple Displays")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        TaskbarButtonDisplay
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Taskbar buttons on multiple displays")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Taskbar buttons, multi-display (All taskbars)")
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Taskbar buttons, multi-display (Taskbar where window is open)")
                                    $Item.Output[0].Set(2)
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Taskbar buttons, multi-display (Main taskbar + where window is open)")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                    }
                }
                StartMenu
                {
                    Switch ($Item.Name)
                    {
                        StartMenuWebSearch
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Bing Search in Start Menu")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Bing Search in Start Menu")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Bing Search in Start Menu")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(1)
                                }
                            }
                        }
                        StartSuggestions
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Start Menu Suggestions")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Start Menu Suggestions")
                                    0..15 | % { $Item.Output[$_].Set(1) }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Start Menu Suggestions")
                                    0..15 | % { $Item.Output[$_].Set(0) }
                                    If ($This.Setting.Version -ge 1803) 
                                    {
                                        $Key = Get-ItemProperty -Path $This.Setting.StartSuggestionsCloudCache
                                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Key.Data[0..15]
                                        Stop-Process -Name ShellExperienceHost -Force
                                    }
                                }
                            }
                        }
                        MostUsedAppStartMenu
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Most used apps in Start Menu")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Most used apps in Start Menu")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Most used apps in Start Menu")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        RecentItemsFrequent
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Recent items and frequent places")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Recent items and frequent places")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Recent items and frequent places")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        UnpinItems
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Unpinning Items")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Unpinning Items")
                                    $xPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"
                                    $xColl = "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
                                    If ($This.Setting.Version -le 1709) 
                                    {
                                        ForEach ($Item in Get-ChildItem $xPath -Include *.group -Recurse)
                                        {
                                            $Path = "{0}\Current" -f $Item.PsPath
                                            $Data = (Get-ItemProperty $Path -Name Data).Data -join ","
                                            $Data = $Data.Substring(0, $Data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
                                            Set-ItemProperty $Path -Name Data -Type Binary -Value $Data.Split(",")
                                        }
                                    }
                                    Else 
                                    {
                                        $Key     = Get-ItemProperty -Path "$xPath\$xColl"
                                        $Data    = $Key.Data[0..25] + ([Byte[]](202,50,0,226,44,1,1,0,0))
                                        Set-ItemProperty -Path $Key.PSPath -Name Data -Type Binary -Value $Data
                                        Stop-Process -Name ShellExperienceHost -Force
                                    }
                                }
                            }
                        }
                    }
                }
                Explorer
                {
                    Switch ($Item.Name)
                    {
                        AccessKeyPrompt
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Accessibility keys prompts")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Accessibility keys prompts")
                                    $Item.Output[0].Set("String",510)
                                    $Item.Output[1].Set("String",62)
                                    $Item.Output[2].Set("String",126)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Accessibility keys prompts")
                                    $Item.Output[0].Set("String",506)
                                    $Item.Output[1].Set("String",58)
                                    $Item.Output[2].Set("String",122)
                                }
                            }
                        }
                        F1HelpKey
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] F1 Help Key")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] F1 Help Key")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] F1 Help Key")
                                    $Item.Output[1].Set("String","")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[2].Set("String","")  
                                    }
                                }
                            }
                        }
                        AutoPlay
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Autoplay")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Autoplay")
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Autoplay")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        AutoRun
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Autorun")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Autorun")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Autorun")
                                    $Item.Output[0].Set(255)
                                }
                            }
                        }
                        PidInTitleBar
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Process ID on Title bar")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Process ID on Title bar")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Process ID on Title bar")
                                    $Item.Output[0].Remove()
                                }
                            }
                        }
                        RecentFileQuickAccess
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Recent Files in Quick Access")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Recent Files in Quick Access (Showing)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set("String","Recent Items Instance Folder")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[2].Set("String","Recent Items Instance Folder")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Recent Files in Quick Access (Hiding)")
                                    $Item.Output[0].Set(0)
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Recent Files in Quick Access (Removing)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[2].Remove()
                                    }
                                }
                            }
                        }
                        FrequentFoldersQuickAccess
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Frequent folders in Quick Access")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Frequent folders in Quick Access")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Frequent folders in Quick Access")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        WinContentWhileDrag
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Window content while dragging")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Window content while dragging")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Window content while dragging")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        StoreOpenWith
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Search Windows Store for Unknown Extensions")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Search Windows Store for Unknown Extensions")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Search Windows Store for Unknown Extensions")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        LongFilePath
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Long file path")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Long file path")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Long file path")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                }
                            }
                        }
                        ExplorerOpenLoc
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Default Explorer view to Quick Access")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Default Explorer view to Quick Access")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Default Explorer view to Quick Access")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        WinXPowerShell
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] (Win+X) PowerShell/Command Prompt")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] (Win+X) PowerShell/Command Prompt")
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] (Win+X) PowerShell/Command Prompt")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        AppHibernationFile
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] App Hibernation File (swapfile.sys)")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] App Hibernation File (swapfile.sys)")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] App Hibernation File (swapfile.sys)")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        KnownExtensions
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Known File Extensions")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Known File Extensions")
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Known File Extensions")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        HiddenFiles
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Hidden Files")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Hidden Files")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Hidden Files")
                                    $Item.Output[0].Set(2)
                                }
                            }
                        }
                        SystemFiles
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] System Files")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] System Files")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] System Files")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        Timeline
                        {
                            If ($This.Setting.Version -ge 1803)
                            {
                                Switch ($Mode)
                                {
                                    0
                                    {
                                        $Item.Update(0,"Skipping [!] Windows Timeline")
                                    }
                                    1
                                    {
                                        $Item.Update(1,"Enabling [~] Windows Timeline")
                                        $Item.Output[0].Set(1)
                                    }
                                    2
                                    {
                                        $Item.Update(2,"Disabling [~] Windows Timeline")
                                        $Item.Output[0].Set(0)
                                    }
                                }
                            }
                        }
                        AeroSnap
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Aero Snap")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Aero Snap")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Aero Snap")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        AeroShake
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Aero Shake")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Aero Shake")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Aero Shake")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        TaskManagerDetails
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Task Manager Details")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Task Manager Details")
                                    $Path         = $Item.Output[0].Path
                                    $xTask        = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
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
                                    Stop-Process $xTask
                                    $TM[28]       = 0
                                    $Item.Output[0].Set("Binary",$TM)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Task Manager Details")
                                    $TM           = $Item.Output[0].Get().Preferences
                                    $TM[28]       = 1
                                    $Item.Output[0].Set("Binary",$TM)
                                }
                            }
                        }
                        ReopenAppsOnBoot
                        {
                            If ($This.Setting.Version -eq 1709)
                            {
                                Switch ($Mode)
                                {
                                    0
                                    {
                                        $Item.Update(0,"Skipping [!] Reopen applications at boot time")
                                    }
                                    1
                                    {
                                        $Item.Update(1,"Enabling [~] Reopen applications at boot time")
                                        $Item.Output[0].Set(0)
                                    }
                                    2
                                    {
                                        $Item.Update(2,"Disabling [~] Reopen applications at boot time")
                                        $Item.Output[0].Set(1)
                                    }
                                }
                            }
                        }
                    }
                }
                ThisPCIcon
                {
                    Switch ($Item.Name)
                    {
                        Desktop
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Desktop folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Desktop folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Set("String","Show")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[3].Get()
                                        $Item.Output[4].Get()
                                        $Item.Output[5].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Desktop folder in This PC (Hidden)")
                                    $Item.Output[2].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Desktop folder in This PC (None)")
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                    }
                                }
                            }
                        }
                        Documents
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Documents folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Documents folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String","Show")
                                    $Item.Output[4].Set("String","{FDD39AD0-238F-46AF-ADB4-6C85480369C7}")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Get()
                                        $Item.Output[6].Get()
                                        $Item.Output[7].Get()
                                        $Item.Output[8].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Documents folder in This PC (Hidden)")
                                    $Item.Output[3].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[8].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Documents folder in This PC (None)")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                        $Item.Output[6].Remove()
                                    }
                                }
                            }
                        }
                        Downloads
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Downloads folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Downloads folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String","Show")
                                    $Item.Output[4].Set("String","{374DE290-123F-4565-9164-39C4925E467B}")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Get()
                                        $Item.Output[6].Get()
                                        $Item.Output[7].Get()
                                        $Item.Output[8].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Downloads folder in This PC (Hidden)")
                                    $Item.Output[3].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[8].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Documents folder in This PC (None)")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                        $Item.Output[6].Remove()
                                    }
                                }
                            }
                        }
                        Music
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Music folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Music folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String","Show")
                                    $Item.Output[4].Set("String","{4BD8D571-6D19-48D3-BE97-422220080E43}")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Get()
                                        $Item.Output[6].Get()
                                        $Item.Output[7].Get()
                                        $Item.Output[8].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Music folder in This PC (Hidden)")
                                    $Item.Output[3].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[8].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Music folder in This PC (None)")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                        $Item.Output[6].Remove()
                                    }
                                }
                            }
                        }
                        Pictures
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Pictures folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Pictures folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String","Show")
                                    $Item.Output[4].Set("String","{33E28130-4E1E-4676-835A-98395C3BC3BB}")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Get()
                                        $Item.Output[6].Get()
                                        $Item.Output[7].Get()
                                        $Item.Output[8].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Pictures folder in This PC (Hidden)")
                                    $Item.Output[3].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[8].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Pictures folder in This PC (None)")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                        $Item.Output[6].Remove()
                                    }
                                }
                            }
                        }
                        Videos
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Videos folder in This PC")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Videos folder in This PC (Shown)")
                                    $Item.Output[0].Get()
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String","Show")
                                    $Item.Output[4].Set("String","{18989B1D-99B5-455B-841C-AB7C74E4DDFC}")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Get()
                                        $Item.Output[6].Get()
                                        $Item.Output[7].Get()
                                        $Item.Output[8].Set("String","Show")
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Videos folder in This PC (Hidden)")
                                    $Item.Output[3].Set("String","Hide")
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[8].Set("String","Hide")
                                    }
                                }
                                3
                                {
                                    $Item.Update(3,"Setting [~] Videos folder in This PC (None)")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                    If ($This.Setting.x64Bit)
                                    {
                                        $Item.Output[5].Remove()
                                        $Item.Output[6].Remove()
                                    }
                                }
                            }
                        }
                        ThreeDObjects
                        {
                            If ($This.Setting.Version -ge 1709)
                            {
                                Switch ($Mode)
                                {
                                    0
                                    {
                                        $Item.Update(0,"Skipping [!] 3D Objects folder in This PC")    
                                    }
                                    1
                                    {
                                        $Item.Update(1,"Enabling [~] 3D Objects folder in This PC (Shown)")
                                        $Item.Output[0].Get()
                                        $Item.Output[1].Get()
                                        $Item.Output[2].Set("String","Show")
                                        If ($This.Setting.x64Bit)
                                        {
                                            $Item.Output[3].Get()
                                            $Item.Output[4].Get()
                                            $Item.Output[5].Set("String","Show")
                                        }
                                    }
                                    2
                                    {
                                        $Item.Update(2,"Setting [~] 3D Objects folder in This PC (Hidden)")
                                        $Item.Output[2].Set("String","Hide")
                                        If ($This.Setting.x64Bit)
                                        {
                                            $Item.Output[5].Set("String","Hide")
                                        }
                                    }
                                    3
                                    {
                                        $Item.Update(3,"Setting [~] 3D Objects folder in This PC (None)")
                                        $Item.Output[1].Remove()
                                        If ($This.Setting.x64Bit)
                                        {
                                            $Item.Output[5].Remove()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                DesktopIcon
                {
                    Switch ($Item.Name)
                    {
                        ThisPC
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] This PC Icon on desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] This PC Icon on desktop (Shown)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] This PC Icon on desktop (Hidden)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        Network
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Network Icon on desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Network Icon on desktop (Shown)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Network Icon on desktop (Hidden)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        RecycleBin
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Recycle Bin Icon on desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Recycle Bin Icon on desktop (Shown)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Recycle Bin Icon on desktop (Hidden)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        Profile
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Users file Icon on desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Users file Icon on desktop (Shown)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Users file Icon on desktop (Hidden)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                        ControlPanel
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Control Panel Icon on desktop")
                                }
                                1
                                {
                                    $Item.Update(1,"Setting [~] Control Panel Icon on desktop (Shown)")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[0].Set(0)
                                }
                                2
                                {
                                    $Item.Update(2,"Setting [~] Control Panel Icon on desktop (Hidden)")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                    }
                }
                LockScreen
                {
                    Switch ($Item.Name)
                    {
                        Toggle
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Lock Screen")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Lock Screen")
                                    If ($This.Setting.Version -ge 1607)
                                    {
                                        Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$False -Verbose
                                    }
                                    Else
                                    {
                                        $Item.Output[0].Remove()
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Lock Screen")
                                    If ($This.Setting.Version -ge 1607)
                                    {
                                        $xService             = New-Object -ComObject Schedule.Service
                                        $xService.Connect()
                                        $xTask                = $xService.NewTask(0)
                                        $xTask.Settings.DisallowStartIfOnBatteries = $False
                                        $Trigger             = $xTask.Triggers.Create(9)
                                        $Trigger             = $xTask.Triggers.Create(11)
                                        $Trigger.StateChange = 8
                                        $Action              = $xTask.Actions.Create(0)
                                        $Action.Path         = 'Reg.exe'
                                        $Action.Arguments    = $Item.LockscreenArgument()
                                        $xService.GetFolder('\').RegisterTaskDefinition('Disable LockScreen',$xTask,6,
                                                                                       'NT AUTHORITY\SYSTEM',$Null,4)
                                    }
                                    Else
                                    {
                                        $Item.Output[0].Set(1)
                                    }
                                }
                            }
                        }
                        Password
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Lock Screen Password")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Lock Screen Password")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Lock Screen Password")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        PowerMenu
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Power Menu on Lock Screen")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Power Menu on Lock Screen")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Power Menu on Lock Screen")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        Camera
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Camera at Lockscreen")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Camera at Lockscreen")
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Camera at Lockscreen")
                                    $Item.Output[0].Set(1)
                                }
                            }
                        }
                    }
                }
                Miscellaneous
                {
                    Switch ($Item.Name)
                    {
                        ScreenSaver
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Screensaver")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Screensaver")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Screensaver")
                                    $Item.Output[0].Set(0)
                                }
                            }
                        }
                        AccountProtectionWarn
                        {
                            If ($This.Setting.Version -ge 1803)
                            {
                                Switch ($Mode)
                                {
                                    0
                                    {
                                        $Item.Update(0,"Skipping [!] Account Protection Warning")
                                    }
                                    1
                                    {
                                        $Item.Update(1,"Enabling [~] Account Protection Warning")
                                        $Item.Output[0].Remove()
                                    }
                                    2
                                    {
                                        $Item.Update(2,"Disabling [~] Account Protection Warning")
                                        $Item.Output[0].Set(1)
                                    }
                                }
                            }
                        }
                        ActionCenter
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Action Center")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Action Center")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Action Center")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        StickyKeyPrompt
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Sticky Key Prompt")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Sticky Key Prompt")
                                    $Item.Output[0].Set("String",510)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Sticky Key Prompt")
                                    $Item.Output[0].Set("String",506)
                                }
                            }
                        }
                        NumlockOnStart
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Num Lock on startup")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Num Lock on startup")
                                    $Item.Output[0].Set(2147483650)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Num Lock on startup")
                                    $Item.Output[0].Set(2147483648)
                                }
                            }
                        }
                        F8BootMenu
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] F8 Boot menu options")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] F8 Boot menu options")
                                    $Item.SetBcdEdit('/set {current} bootmenupolicy Legacy')
                                }
                                2
                                {
                                    $Item.Update(0,"Disabling [~] F8 Boot menu options")
                                    $Item.SetBcdEdit('/set {current} bootmenupolicy Standard')
                                }
                            }
                        }
                        RemoteUACAcctToken
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Remote UAC Local Account Token Filter")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Remote UAC Local Account Token Filter")
                                    $Item.Output[0].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Remote UAC Local Account Token Filter")
                                    $Item.Output[0].Remove()
                                }
                            }
                        }
                        HibernatePower
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Hibernate Option")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Hibernate Option")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(1)
                                    $Item.SetPowerCfg("/HIBERNATE ON")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Hibernate Option")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                    $Item.SetPowerCfg("/HIBERNATE OFF")
                                }
                            }
                        }
                        SleepPower
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Sleep Option")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Sleep Option")
                                    $Item.Output[0].Set(1)
                                    $Item.SetPowerCfg("/SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1")
                                    $Item.SetPowerCfg("/SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Sleep Option")
                                    $Item.Output[0].Set(0)
                                    $Item.SetPowerCfg("/SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0")
                                    $Item.SetPowerCfg("/SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0")
                                }
                            }
                        }
                    }
                }
                PhotoViewer
                {
                    Switch ($Item.Name)
                    {
                        FileAssociation
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Photo Viewer File Association")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Photo Viewer File Association")
                                    0..3 | % { 
                    
                                        $Item.Output[$_  ].Set("ExpandString",
                                                               "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
                                        $Item.Output[$_+4].Set("ExpandString",
                                                               '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1')
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Photo Viewer File Association")
                                    $iExplore = '"{0}\{1}" %1' -f [Environment]::GetEnvironmentVariable("ProgramFiles"),"Internet Explorer\iexplore.exe"
                
                                    $Item.Output[0] | % { $_.Clear(); $_.Remove() }
                                    $Item.Output[1].Remove()
                                    $Item.Output[2] | % { $_.Clear(); $_.Remove() }
                                    $Item.Output[3] | % { $_.Clear(); $_.Remove() }
                                    $Item.Output[5].Set("String",$IExplore)
                                    $Item.Output[8].Set("String","IE.File")
                                    $Item.Output[9].Set("String","{17FE9752-0B5A-4665-84CD-569794602F5C}")
                                }
                            }
                        }
                        OpenWithMenu
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] 'Open with Photo Viewer' context menu item")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] 'Open with Photo Viewer' context menu item")
                                    $Item.Output[1].Get()
                                    $Item.Output[2].Get()
                                    $Item.Output[3].Set("String",
                                                        "@photoviewer.dll,-3043")
                                    $Item.Output[4].Set("ExpandString",
                                                        '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1')
                                    $Item.Output[5].Set("String",
                                                        "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}")
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] 'Open with Photo Viewer' context menu item")
                                    $Item.Output[0].Remove()
                                }
                            }
                        }
                    }
                }
                WindowsApps
                {
                    Switch ($Item.Name)
                    {
                        OneDrive
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] OneDrive")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] OneDrive")
                                    $Item.Output[0].Remove()
                                    $Item.Output[1].Set(1)
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] OneDrive")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        OneDriveInstall
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] OneDrive Install")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] OneDrive Install")
                                    $xPath = "$Env:Windir\{0}\OneDriveSetup.exe" -f ,@("System32","SysWOW64")[$This.Setting.x64Bit]
                
                                    If ([System.IO.File]::Exists($xPath)) 
                                    {
                                        Start-Process $xPath -NoNewWindow 
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] OneDrive Install")
                                    $xPath = "$Env:Windir\{0}\OneDriveSetup.exe" -f ,@("System32","SysWOW64")[$This.Setting.x64Bit]
                                    If ([System.IO.File]::Exists($xPath))
                                    {
                                        Stop-Process -Name OneDrive -Force
                                        Start-Sleep -Seconds 3
                                        Start-Process $xPath "/uninstall" -NoNewWindow -Wait
                                        Start-Sleep -Seconds 3
                    
                                        ForEach ($Path in "$Env:USERPROFILE\OneDrive",
                                                          "$Env:LOCALAPPDATA\Microsoft\OneDrive",
                                                          "$Env:PROGRAMDATA\Microsoft OneDrive",
                                                          "$Env:WINDIR\OneDriveTemp",
                                                          "$Env:SYSTEMDRIVE\OneDriveTemp")
                                        {    
                                            Remove-Item $Path -Force -Recurse 
                                        }
                    
                                        $Item.Output[0].Remove()
                                        $Item.Output[1].Remove()
                                    }
                                }
                            }
                        }
                        XboxDVR
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Xbox DVR")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Xbox DVR")
                                    $Item.Output[0].Set(1)
                                    $Item.Output[0].Remove()
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Xbox DVR")
                                    $Item.Output[0].Set(0)
                                    $Item.Output[1].Set(0)
                                }
                            }
                        }
                        MediaPlayer
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Windows Media Player")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Windows Media Player")
                                    $Name     = "WindowsMediaPlayer"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -ne "Enabled")
                                    {
                                        $Item.EnableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Enabled"
                                        }
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Windows Media Player")
                                    $Name     = "WindowsMediaPlayer"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -eq "Enabled")
                                    {
                                        $Item.DisableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Disabled"
                                        }
                                    }
                                }
                            }
                        }
                        WorkFolders
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Work Folders Client")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Work Folders Client")
                                    $Name     = "WorkFolders-Client"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -ne "Enabled")
                                    {
                                        $Item.EnableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Enabled"
                                        }
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Work Folders Client")
                                    $Name     = "WorkFolders-Client"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -eq "Enabled")
                                    {
                                        $Item.DisableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Disabled"
                                        }
                                    }
                                }
                            }
                        }
                        FaxAndScan
                        {
                            Switch ($Mode)
                            {
                                0
                                {
                                    $Item.Update(0,"Skipping [!] Fax And Scan")
                                }
                                1
                                {
                                    $Item.Update(1,"Enabling [~] Fax And Scan")
                                    $Name     = "FaxServicesClientPackage"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -ne "Enabled")
                                    {
                                        $Item.EnableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Enabled"
                                        }
                                    }
                                }
                                2
                                {
                                    $Item.Update(2,"Disabling [~] Fax And Scan")
                                    $Name     = "FaxServicesClientPackage"
                                    $xFeature = $Item.GetFeature($Name)
                                    If ($xFeature.State -eq "Enabled")
                                    {
                                        $Item.DisableFeature($Name)
                                        If (!!$?)
                                        {
                                            $xFeature.State = "Disabled"
                                        }
                                    }
                                }
                            }
                        }
                        LinuxSubsystem
                        {
                            If ($This.Setting.Version -gt 1607)
                            {
                                Switch ($Mode)
                                {
                                    0
                                    {
                                        $Item.Update(0,"Skipping [!] Linux Subsystem")
                                    }
                                    1
                                    {
                                        $Item.Update(1,"Enabling [~] Linux Subsystem")
                                        $Name     = "Microsoft-Windows-Subsystem-Linux"
                                        $xFeature = $Item.GetFeature($Name)
                                        If ($xFeature.State -ne "Enabled")
                                        {
                                            $Item.EnableFeature($Name)
                                            If (!!$?)
                                            {
                                                $xFeature.State = "Enabled"
                                            }
                                        }
                                    }
                                    2
                                    {
                                        $Item.Update(2,"Disabling [~] Linux Subsystem")
                                        $Name     = "Microsoft-Windows-Subsystem-Linux"
                                        $xFeature = $Item.GetFeature($Name)
                                        If ($xFeature.State -eq "Enabled")
                                        {
                                            $Item.DisableFeature($Name)
                                            If (!!$?)
                                            {
                                                $xFeature.State = "Disabled"
                                            }
                                        }
                                    }
                                }
                            }
                            Else
                            {
                                $Item.Update(-1,"Error [!] This version of Windows does not support (WSL/Windows Subsystem for Linux)")
                            }
                        }
                    }
                }
            }
        }
        SetAcl([String]$Params)
        {
            $This.StartProcess("icacls",$Params)
        }
        SetOwnership([String]$Params)
        {
            $This.StartProcess("takeown",$Params)
        }
        SetBcdEdit([String]$Params)
        {
            $FilePath     = "bcdedit"
            $This.StartProcess($FilePath,$Params)
        }
        SetPowerCfg([String]$Params)
        {
            $FilePath     = "powercfg"
            $This.StartProcess($FilePath,$Params)
        }
        StartProcess([String]$FilePath,[String]$ArgumentList)
        {
            Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process
        }
        Invoke()
        {
            $This.Xaml.Invoke()
        }
        [String] ToString()
        {
            Return "<FEModule.ViperBomb[Controller]>"
        }
    }

$Ctrl = [ViperBombController]::New()
$Ctrl.RefreshAll()

$Ctrl.StageXaml()
$Ctrl.Invoke()
