Class StarCraftControllerXaml
{
    Static [String] $Content = @(
    '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
    '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
    '        Title="StarCraft Controller"',
    '        Height="500"',
    '        Width="800"',
    '        ResizeMode="NoResize"',
    '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico"',
    '        HorizontalAlignment="Center"',
    '        WindowStartupLocation="CenterScreen"',
    '        FontFamily="Consolas"',
    '        Background="LightYellow"',
    '        Name="StarCraftWindow">',
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
    '    <Grid Margin="5">',
    '        <Grid.RowDefinitions>',
    '            <RowDefinition Height="40"/>',
    '            <RowDefinition Height="40"/>',
    '            <RowDefinition Height="*"/>',
    '            <RowDefinition Height="40"/>',
    '            <RowDefinition Height="50"/>',
    '            <RowDefinition Height="40"/>',
    '        </Grid.RowDefinitions>',
    '        <Grid Grid.Row="0">',
    '            <Grid.ColumnDefinitions>',
    '                <ColumnDefinition Width="100"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="25"/>',
    '            </Grid.ColumnDefinitions>',
    '            <Label Grid.Column="0"',
    '                   Content="[Game]:"/>',
    '            <TextBox Grid.Column="1"',
    '                     Name="GamePath"/>',
    '            <Image Grid.Column="2"',
    '                   Name="GamePathIcon"/>',
    '        </Grid>',
    '        <Grid Grid.Row="1">',
    '            <Grid.ColumnDefinitions>',
    '                <ColumnDefinition Width="100"/>',
    '                <ColumnDefinition Width="200"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="25"/>',
    '            </Grid.ColumnDefinitions>',
    '            <Label Grid.Column="0"',
    '                   Content="[Selected]:"/>',
    '            <ComboBox Grid.Column="1"',
    '                      Name="GameSelection"/>',
    '            <TextBox Grid.Column="2"',
    '                     Name="GameSelectionDescription"',
    '                     IsEnabled="False"/>',
    '        </Grid>',
    '        <DataGrid Grid.Row="2"',
    '                  Name="GameLoadout"',
    '                  IsReadOnly="True">',
    '            <DataGrid.RowStyle>',
    '                <Style TargetType="{x:Type DataGridRow}">',
    '                    <Style.Triggers>',
    '                        <Trigger Property="IsMouseOver" Value="True">',
    '                            <Setter Property="ToolTip">',
    '                                <Setter.Value>',
    '                                    <TextBlock Text="&lt;Campaign Selection&gt;"',
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
    '                <DataGridTextColumn Header="#"',
    '                                    Binding="{Binding Index}"',
    '                                    Width="30"/>',
    '                <DataGridTextColumn Header="%"',
    '                                    Binding="{Binding Rank}"',
    '                                    Width="30"/>',
    '                <DataGridTextColumn Header="Race"',
    '                                    Binding="{Binding Race}"',
    '                                    Width="55"/>',
    '                <DataGridTextColumn Header="Title"',
    '                                    Binding="{Binding Title}"',
    '                                    Width="175"/>',
    '                <DataGridTextColumn Header="Start"',
    '                                    Binding="{Binding Start}"',
    '                                    Width="165"/>',
    '                <DataGridTextColumn Header="End"',
    '                                    Binding="{Binding End}"',
    '                                    Width="165"/>',
    '                <DataGridTextColumn Header="Duration"',
    '                                    Binding="{Binding Duration}"',
    '                                    Width="125"/>',
    '            </DataGrid.Columns>',
    '        </DataGrid>',
    '        <Grid Grid.Row="3">',
    '            <Grid.ColumnDefinitions>',
    '                <ColumnDefinition Width="60"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="60"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="60"/>',
    '                <ColumnDefinition Width="*"/>',
    '            </Grid.ColumnDefinitions>',
    '            <Label Grid.Column="0"',
    '                   Content="Start"',
    '                   Style="{StaticResource LabelGray}"/>',
    '            <TextBox Grid.Column="1"',
    '                     Name="GameDurationStart"',
    '                     IsReadOnly="True"/>',
    '            <Label Grid.Column="2"',
    '                   Content="End"',
    '                   Style="{StaticResource LabelGray}"/>',
    '            <TextBox Grid.Column="3"',
    '                     Name="GameDurationEnd"',
    '                     IsReadOnly="True"/>',
    '            <Label Grid.Column="4"',
    '                   Content="Span"',
    '                   Style="{StaticResource LabelGray}"/>',
    '            <TextBox Grid.Column="5"',
    '                     Name="GameDurationSpan"',
    '                     IsReadOnly="True"/>',
    '        </Grid>',
    '        <DataGrid Grid.Row="4"',
    '                  Name="GameCurrent"',
    '                  IsReadOnly="True">',
    '            <DataGrid.RowStyle>',
    '                <Style TargetType="{x:Type DataGridRow}">',
    '                    <Style.Triggers>',
    '                        <Trigger Property="IsMouseOver" Value="True">',
    '                            <Setter Property="ToolTip">',
    '                                <Setter.Value>',
    '                                    <TextBlock Text="&lt;Campaign Selection&gt;"',
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
    '                <DataGridTextColumn Header="#"',
    '                                    Binding="{Binding Index}"',
    '                                    Width="30"/>',
    '                <DataGridTextColumn Header="%"',
    '                                    Binding="{Binding Rank}"',
    '                                    Width="30"/>',
    '                <DataGridTextColumn Header="Race"',
    '                                    Binding="{Binding Race}"',
    '                                    Width="60"/>',
    '                <DataGridTextColumn Header="Title"',
    '                                    Binding="{Binding Title}"',
    '                                    Width="175"/>',
    '                <DataGridTextColumn Header="Start"',
    '                                    Binding="{Binding Start}"',
    '                                    Width="165"/>',
    '                <DataGridTextColumn Header="End"',
    '                                    Binding="{Binding End}"',
    '                                    Width="165"/>',
    '                <DataGridTextColumn Header="Duration"',
    '                                    Binding="{Binding Duration}"',
    '                                    Width="125"/>',
    '            </DataGrid.Columns>',
    '        </DataGrid>',
    '        <Grid Grid.Row="5">',
    '            <Grid.ColumnDefinitions>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="*"/>',
    '                <ColumnDefinition Width="*"/>',
    '            </Grid.ColumnDefinitions>',
    '            <Button Grid.Column="0"',
    '                    Content="Start"',
    '                    Name="GameStart"/>',
    '            <Button Grid.Column="1"',
    '                    Content="Next Level"',
    '                    Name="GameNextLevel"/>',
    '            <Button Grid.Column="2"',
    '                    Content="End"',
    '                    Name="GameEnd"/>',
    '            <Button Grid.Column="3"',
    '                    Content="Reset"',
    '                    Name="GameReset"/>',
    '            <Button Grid.Column="4"',
    '                    Content="Save"',
    '                    Name="GameSave"/>',
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
        Return "<StarCraft.Controller.XamlWindow>"
    }
}

Enum StarCraftCampaignSelectionType
{
    StarCraftTerran
    StarCraftZerg
    StarCraftProtoss
    StarCraftAll
    BroodWarProtoss
    BroodWarTerran
    BroodWarZerg
    BroodWarAll
    StarCraftBroodWarTerran
    StarCraftBroodWarZerg
    StarCraftBroodWarProtoss
    StarCraftBroodWarAll
}

Class StarCraftCampaignSelectionItem
{
    [UInt32] $Index
    [String] $Name
    [String] $Description
    StarCraftCampaignSelectionItem([String]$Name)
    {
        $This.Index = [UInt32][StarCraftCampaignSelectionType]::$Name
        $This.Name  = [StarCraftCampaignSelectionType]::$Name
    }
    [String] ToString()
    {
        Return "<StarCraft.Campaign.Selection>"
    }
}

Class StarCraftCampaignSelectionList
{
    [Object] $Output
    StarcraftCampaignSelectionList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] StarCraftCampaignSelectionItem([String]$Name)
    {
        Return [StarCraftCampaignSelectionItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([StarCraftCampaignSelectionType]))
        {
            $Item = $This.StarCraftCampaignSelectionItem($Name)
            $Item.Description = Switch ($Item.Name)
            {
                StarCraftTerran
                {
                    "Original StarCraft as Terran"
                }
                StarCraftZerg
                {
                    "Original StarCraft as Zerg"
                }
                StarCraftProtoss
                {
                    "Original StarCraft as Protoss"
                }
                StarCraftAll
                {
                    "Original StarCraft as all races"
                }
                BroodWarProtoss
                {
                    "StarCraft: Brood War as Protoss"
                }
                BroodWarTerran
                {
                    "StarCraft: Brood War as Terran"
                }
                BroodWarZerg
                {
                    "StarCraft: Brood War as Zerg"
                }
                BroodWarAll
                {
                    "StarCraft: Brood War as all races"
                }
                StarCraftBroodWarTerran
                {
                    "StarCraft + Brood War as Terran"
                }
                StarCraftBroodWarZerg
                {
                    "StarCraft + Brood War as Zerg"
                }
                StarCraftBroodWarProtoss
                {
                    "StarCraft + Brood War as Protoss"
                }
                StarCraftBroodWarAll
                {
                    "StarCraft + Brood War as all races"
                }
            }

            $This.Output += $Item
        }
    }
}

Class StarCraftLevelEntry
{
    [UInt32]           $Index
    [UInt32]            $Rank
    [String]            $Race
    [String]           $Title
    [String]           $Start
    [String]             $End
    [String]        $Duration
    Hidden [UInt32] $Selected
    StarCraftLevelEntry([UInt32]$Rank,[String]$Race,[String]$Title)
    {
        $This.Rank     = $Rank
        $This.Race     = $Race
        $This.Title    = $Title
    }
    LevelBegin()
    {
        $This.Start    = $This.Now()
    }
    LevelEnd()
    {
        $This.End      = $This.Now()
        $This.Duration = [DateTime]$This.End - [DateTime]$This.Start
    }
    [String] Now()
    {
        Return [DateTime]::Now.ToString("MM/dd/yyyy HH:mm:ss.fff")
    }
    [String] ToString()
    {
        Return $This.Title
    }
}

Class StarCraftCampaign
{
    [UInt32] $Index
    [String] $Race
    [String] $Mode
    [Object] $Level
    StarCraftCampaign([UInt32]$Index,[String]$Race,[String]$Mode)
    {
        $This.Index = $Index
        $This.Race  = $Race
        $This.Mode  = $Mode
        $This.Level = @( )
    }
    [Object] StarCraftLevelEntry([UInt32]$Index,[String]$Race,[String]$Title)
    {
        Return [StarCraftLevelEntry]::New($Index,$Race,$Title)
    }
    Add([String]$Title)
    {
        $This.Level += $This.StarCraftLevelEntry($This.Level.Count,$This.Race,$Title)
    }
    [String] ToString()
    {
        Return "<StarCraft.Campaign>"
    }
}

Class StarCraftDuration
{
    [String] $Start
    [String]   $End
    [String]  $Span
    StarCraftDuration()
    {

    }
    DurationStart()
    {
        $This.Start = $This.Now()
    }
    DurationUpdate()
    {
        $This.Span = [DateTime]$This.Now() - [DateTime]$This.Start
    }
    DurationEnd()
    {
        $This.End  = $This.Now()
        $This.DurationUpdate()
    }
    [String] Now()
    {
        Return [DateTime]::Now.ToString("MM/dd/yyyy HH:mm:ss.fff")
    }
    [String] ToString()
    {
        Return "<StarCraft.Duration>"
    }
}

Class StarCraftOutputFile
{
    [String] $Selection
    [String] $Completed
    [String] $Start
    [String] $End
    [String] $Duration
    StarCraftOutputFile([String]$Selection,[Object]$Loadout,[Object]$Duration)
    {
        $This.Selection = $Selection
        $This.Completed = "({0}/{1}) levels" -f ($Loadout | ? Duration).Count, $Loadout.Count
        $This.Start     = $Duration.Start
        $This.End       = $Duration.End
        $This.Duration  = $Duration.Span
    }
    [String] ToString()
    {
        Return "<StarCraft.Output.File>"
    }
}

$Out.Add($Out.Count,"------------------------------------------------------------------")
$Out.Add($Out.Count,"Selection : {0}" -f $Ctrl.Xaml.IO.GameSelection.SelectedItem)
$Out.Add($Out.Count,("Completed : ({0}/{1}) levels" -f ($Ctrl.Loadout | ? Duration).Count,$Ctrl.Loadout.Count))
$Out.Add($Out.Count,"Start     : {0}" -f $Ctrl.Duration.Start)
$Out.Add($Out.Count,"End       : {0}" -f $Ctrl.Duration.End)
$Out.Add($Out.Count,"Duration  : {0}" -f $Ctrl.Duration.Span)
$Out.Add($Out.Count,"------------------------------------------------------------------")
$Out.Add($Out.Count,"")

Class StarCraftController
{
    [String]           $Title
    [Object]          $Module
    [Object]            $Xaml
    [Object]       $Selection
    [Object]        $Campaign
    [Object]         $Loadout
    Hidden [Int32]   $Current
    [Object]        $Duration
    StarCraftController()
    {
        $This.Title     = "StarCraft"
        $This.Xaml      = $This.StarCraftControllerXaml()

        $This.Xaml.IO.GamePath.Text      = $This.Bootstrap()
        $This.Xaml.IO.GamePath.IsEnabled = 0

        $This.Module = Get-FEModule -Mode 1

        $This.Xaml.IO.GamePathIcon.Source = $This.Module._Control("success.png").Fullname

        $This.Main()
    }
    [String] Bootstrap()
    {
        $Registry = "", "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        $Game     = Get-ItemProperty $Registry | ? DisplayName -match Starcraft
        If (!$Game)
        {
            Throw "StarCraft is not installed"
        }

        Return "{0}\x86_64\StarCraft.exe" -f $Game.InstallLocation
    }
    Main()
    {
        $This.Selection = $This.StarcraftCampaignSelectionList()
        $This.Campaign  = @( )
        $This.Refresh()
        $This.Duration  = $This.StarCraftDuration()
    }
    [Object] StarCraftCampaign([UInt32]$Index,[String]$Race,[String]$Mode)
    {
        Return [StarCraftCampaign]::New($Index,$Race,$Mode)
    }
    [Object] StarCraftCampaignSelectionList()
    {
        Return [StarcraftCampaignSelectionList]::New()
    }
    [Object] StarCraftControllerXaml()
    {
        Return [XamlWindow][StarCraftControllerXaml]::Content
    }
    [Object] StarCraftDuration()
    {
        Return [StarCraftDuration]::New()
    }
    [Object] StarCraftOutputFile([String]$Selection,[Object]$Loadout,[Object]$Duration)
    {
        Return [StarCraftOutputFile]::New($Selection,$Loadout,$Duration)
    }
    Add([String]$Race,[String]$Mode)
    {
        $This.Campaign += $This.StarCraftCampaign($This.Campaign.Count,$Race,$Mode)
    }
    Select([UInt32]$Index)
    {
        $This.Loadout = @( )

        ForEach ($Item in $This.Campaign.Level)
        {
            $Item.Selected = 0
        }

        $xCampaign = Switch ($Index)
        {
            0 # StarCraftTerran
            {
                $This.Campaign | ? Race -eq Terran | ? Mode -eq StarCraft
            }
            1 # StarCraftZerg
            {
                $This.Campaign | ? Race -eq Zerg | ? Mode -eq StarCraft
            }
            2 # StarCraftProtoss
            {
                $This.Campaign | ? Race -eq Terran | ? Mode -eq StarCraft
            }
            3 # StarCraftAll
            {
                $This.Campaign | ? Mode -eq StarCraft
            }
            4 # BroodWarProtoss
            {
                $This.Campaign | ? Race -eq Protoss | ? Mode -eq "Brood War"
            }
            5 # BroodWarTerran
            {
                $This.Campaign | ? Race -eq Terran | ? Mode -eq "Brood War"
            }
            6 # BroodWarZerg
            {
                $This.Campaign | ? Race -eq Zerg | ? Mode -eq "Brood War"
            }
            7 # BroodWarAll
            {
                $This.Campaign | ? Mode -eq "Brood War"
            }
            8 # StarCraftBroodWarTerran
            {
                $This.Campaign | ? Race -eq Terran
            }
            9 # StarCraftBroodWarZerg
            {
                $This.Campaign | ? Race -eq Zerg
            }
            10 # StarCraftBroodWarProtoss
            {
                $This.Campaign | ? Race -eq Protoss
            }
            11 # StarCraftBroodWarAll
            {
                $This.Campaign
            }
        }

        $List = $xCampaign.Level

        ForEach ($X in 0..($List.Count-1))
        {
            $Item          = $List[$X]
            $Item.Index    = $X
            $Item.Selected = 1
        }

        $This.Loadout = $This.Campaign.Level | ? Selected
    }
    Refresh()
    {
        $This.Campaign = @( )

        # // ====================
        # // | Terran/StarCraft |
        # // ====================

        $This.Add("Terran","StarCraft")
        $Item = $This.Campaign[0]

        "Boot Camp",
        "Wasteland",
        "Backwater Station",
        "Desperate Alliance",
        "The Jacobs Installation",
        "Revolution",
        "Norad II",
        "The Trump Card",
        "The Big Push",
        "New Gettysburg",
        "The Hammer Falls" | % { 

            $Item.Add($_)
        }
        
        # // ==================
        # // | Zerg/StarCraft |
        # // ==================

        $This.Add("Zerg","StarCraft")
        $Item = $This.Campaign[1]

        "Among the Ruins",
        "Egression",
        "The New Dominion",
        "Agent of the Swarm",
        "The Amerigo",
        "The Dark Templar",
        "The Culling",
        "Eye for an Eye",
        "The Invasion of Aiur",
        "Full Circle" | % { 

            $Item.Add($_)
        }

        # // =====================
        # // | Protoss/StarCraft |
        # // =====================

        $This.Add("Protoss","StarCraft")
        $Item = $This.Campaign[2]

        "First Strike",
        "Into the Flames",
        "Higher Ground",
        "The Hunt for Tassadar",
        "Choosing Sides",
        "Into the Darkness",
        "Homeland",
        "The Trial of Tassadar",
        "Shadow Hunters",
        "Eye of the Storm" | % { 

            $Item.Add($_)
        }

        # // =====================
        # // | Protoss/Brood War |
        # // =====================

        $This.Add("Protoss","Brood War")
        $Item = $This.Campaign[3]

        "Escape from Aiur",
        "Dunes of Shakuras",
        "Legacy of the Xel'Naga",
        "The Quest for Uraj",
        "The Battle of Braxis",
        "Return to Char",
        "The Insurgent",
        "Countdown" | % { 

            $Item.Add($_)
        }

        # // ====================
        # // | Terran/Brood War |
        # // ====================

        $This.Add("Terran","Brood War")
        $Item = $This.Campaign[4]

        "First Strike",
        "The Dylarian Shipyards",
        "Ruins of Tarsonis",
        "Assault on Korhal",
        "Emperor's Fall",
        "Emperor's Flight",
        "Patriot's Blood",
        "To Chain the Beast" | % { 

            $Item.Add($_)
        }

        # // ==================
        # // | Zerg/Brood War |
        # // ==================

        $This.Add("Zerg","Brood War")
        $Item = $This.Campaign[5]

        "Vile Disruption",
        "Reign of Fire",
        "The Kel Morian Combine",
        "The Liberation of Korhal",
        "True Colors",
        "Fury of the Swarm",
        "Drawing of the Web",
        "To Slay the Beast",
        "The Reckoning",
        "Omega" | % {

            $Item.Add($_)
        }
    }
    Reset([Object]$xSender,[Object]$Object)
    {
        $xSender.Items.Clear()

        ForEach ($Item in $Object)
        {
            $xSender.Items.Add($Item)
        }
    }
    DurationUpdate()
    {
        $This.Duration.DurationUpdate()
        $This.Xaml.IO.GameDurationStart.Text = $This.Duration.Start
        $This.Xaml.IO.GameDurationEnd.Text   = $This.Duration.End
        $This.Xaml.IO.GameDurationSpan.Text  = $This.Duration.Span
    }
    GameSelection()
    {
        $Index = $This.Xaml.IO.GameSelection.SelectedIndex

        $xSelection = $This.Selection.Output[$Index]
        $This.Xaml.IO.GameSelectionDescription.Text = $xSelection.Description
        
        $This.Select($Index)
        $This.Reset($This.Xaml.IO.GameLoadout,$This.Loadout)
    }
    GameStart()
    {
        $This.Current = 0
        $This.Duration.DurationStart()
        $This.DurationUpdate()
        
        $Item = $This.Loadout[$This.Current]
        $Item.LevelBegin()

        $This.Xaml.IO.GameSelection.IsEnabled = 0
        $This.Xaml.IO.GameStart.IsEnabled     = 0
        $This.Xaml.IO.GameNextLevel.IsEnabled = 1
        $This.Xaml.IO.GameEnd.IsEnabled       = 1
        $This.Xaml.IO.GameSave.IsEnabled      = 0

        # Reset current
        $This.Reset($This.Xaml.IO.GameCurrent,$Item)

        # Reset list
        $This.Reset($This.Xaml.IO.GameLoadout,$This.Loadout)
    }
    GameNextLevel()
    {
        $Item = $This.Loadout[$This.Current]
        $Item.LevelEnd()

        $This.Current ++

        If ($This.Current -eq $This.Loadout.Count-1)
        {
            $This.Xaml.IO.GameNextLevel.IsEnabled = 0
        }

        $Item = $This.Loadout[$This.Current]
        $Item.LevelBegin()
        $This.DurationUpdate()

        # Reset current
        $This.Reset($This.Xaml.IO.GameCurrent,$Item)

        # Reset list
        $This.Reset($This.Xaml.IO.GameLoadout,$This.Loadout)
    }
    GameEnd()
    {
        $Item = $This.Loadout[$This.Current]
        $Item.LevelEnd()
        $This.Duration.DurationEnd()
        $This.DurationUpdate()

        $This.Xaml.IO.GameEnd.IsEnabled       = 0
        $This.Xaml.IO.GameNextLevel.IsEnabled = 0
        $This.Xaml.IO.GameSave.IsEnabled      = 1

        # Reset current
        $This.Reset($This.Xaml.IO.GameCurrent,$Null)

        # Reset list
        $This.Reset($This.Xaml.IO.GameLoadout,$This.Loadout)
    }
    GameReset()
    {
        $This.Main()

        # Reset current
        $This.Reset($This.Xaml.IO.GameCurrent,$Null)

        # Reset list
        $This.Reset($This.Xaml.IO.GameLoadout,$This.Loadout)
    }
    GameSave()
    {
        $Dialog                  = [System.Windows.Forms.SaveFileDialog]::New()
        $Dialog.InitialDirectory = [System.Environment]::GetEnvironmentVariable("UserProfile")
        $Dialog.Filename         = "StarCraft-{0}.log" -f [DateTime]::Now.ToString("yyyy_MMdd-HHmmss")
        $Dialog.Filter           = "Log file (.log)|*.log"
        $Result                  = $Dialog.ShowDialog()

        If ($Result -eq "OK")
        {
            $Content = $This.GameExport()
            [System.IO.File]::WriteAllLines($Dialog.Filename,$Content)
        }
    }
    [String[]] GameExport()
    {
        If (!$This.Loadout)
        {
            Throw "Must have a loadout"
        }

        $Max = @{ 

            Index    = ($This.Loadout.Index    | % ToString | Sort-Object Length)[-1].Length + 1
            Rank     = ($This.Loadout.Rank     | % ToString | Sort-Object Length)[-1].Length + 1
            Race     = ($This.Loadout.Race     | Sort-Object Length)[-1].Length + 1
            Title    = ($This.Loadout.Title    | Sort-Object Length)[-1].Length + 1
        }

        If ($Max.Index -lt 5)
        {
            $Max.Index = 5
        }

        If ($Max.Rank -lt 4)
        {
            $Max.Rank = 4
        }

        $File = $This.StarCraftOutputFile($This.Xaml.IO.GameSelection.SelectedItem,
                                          $This.Loadout,
                                          $This.Duration)

        $Out  = @{ }

        $Content = (Write-Theme $File -Text) -Replace "^#",""
        ForEach ($Line in $Content)
        {
            $Out.Add($Out.Count,$Line)
        }

        $Out.Add($Out.Count,"")

        $Line = "Index".PadRight($Max.Index," "),
                "Rank".PadRight($Max.Rank," "),
                "Race".PadRight($Max.Race," "),
                "Title".PadRight($Max.Title," "),
                "Start".PadRight(24," "),
                "End".PadRight(24," "),
                "Duration".PadRight(17," ") -join " "

        $Out.Add($Out.Count,$Line)

        $Line = "-----".PadRight($Max.Index," "),
                "----".PadRight($Max.Rank," "),
                "----".PadRight($Max.Race," "),
                "-----".PadRight($Max.Title," "),
                "-----".PadRight(24," "),
                "---".PadRight(24," "),
                "--------".PadRight(17," ") -join " "

        $Out.Add($Out.Count,$Line)

        ForEach ($Item in $This.Loadout)
        {
            $xIndex    = $Item.Index.ToString()
            $xRank     = $Item.Rank.ToString()
            $xRace     = $Item.Race
            $xTitle    = $Item.Title
            $xStart    = @($Item.Start;" ")[!$Item.Start]
            $xEnd      = @($Item.End;" ")[!$Item.End]
            $xDuration = @($Item.Duration;" ")[!$Item.Duration]

            $Line      = $xIndex.PadLeft($Max.Index," "),
                         $xRank.PadLeft($Max.Rank," "),
                         $xRace.PadRight($Max.Race," "),
                         $xTitle.PadRight($Max.Title," "),
                         $xStart.PadRight(24," "),
                         $xEnd.PadRight(24," "),
                         $xDuration.PadRight(17," ") -join " "

            $Out.Add($Out.Count,$Line)
        }

        Return $Out[0..($Out.Count-1)]
    }
    StageXaml()
    {
        $Ctrl = $This

        $Ctrl.Xaml.IO.GameStart.IsEnabled     = 1
        $Ctrl.Xaml.IO.GameNextLevel.IsEnabled = 0
        $Ctrl.Xaml.IO.GameEnd.IsEnabled       = 0

        $Ctrl.Reset($Ctrl.Xaml.IO.GameSelection,$Ctrl.Selection.Output.Name)

        $Ctrl.Xaml.IO.GameSelection.Add_SelectionChanged(
        {
            $Ctrl.GameSelection()
        })

        $Ctrl.Xaml.IO.GameStart.Add_Click(
        {
            $Ctrl.GameStart()
        })

        $Ctrl.Xaml.IO.GameNextLevel.Add_Click(
        {
            $Ctrl.GameNextLevel()
        })

        $Ctrl.Xaml.IO.GameEnd.Add_Click(
        {
            $Ctrl.GameEnd()
        })

        $Ctrl.Xaml.IO.GameSave.Add_Click(
        {
            $Ctrl.GameSave()
        })

        $Ctrl.Xaml.IO.GameReset.Add_Click(
        {
            $Ctrl.GameReset()
        })

        $Ctrl.Xaml.IO.GameSelection.SelectedIndex = 11
    }
    Invoke()
    {
        $This.Xaml.Invoke()
    }
}

$Ctrl = [StarCraftController]::New()
$Ctrl.StageXaml()
$Ctrl.Invoke()
