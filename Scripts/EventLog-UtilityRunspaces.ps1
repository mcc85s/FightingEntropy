<#
.SYNOPSIS
        Allows for getting/viewing, exporting, or importing event viewer logs for a current
        or target Windows system.

.DESCRIPTION
        After many years of wondering how I could extract everything from *every* event log,
        this seems to do the trick. The utility takes a fair amount of time, but- it will
        collect every record in the event logs, as well as provide a way to export the files
        to an archive which can be loaded in far less time than it takes to build it.

        It performs a full cycle of stuff, to export logs on one system, to see a system
        snapshot on another system. I've been tweaking it over the last few weeks, and I do
        have a graphical user interface for it too.

        The newest feature writes out a very detailed master.txt file that can import all of
        the information it wrote in the primary scan/export, and, the thing formats itself.

        Not unlike Write-Theme.
        
        Still a work in progress.
.LINK
.NOTES
          FileName: EventLogs-Utility.ps1
          Solution: FightingEntropy Module
          Purpose: For exporting all of a systems event logs
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-04-08
          Modified: 2022-04-23
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression, System.IO.Compression.Filesystem, System.Windows.Forms, PresentationFramework

# UI classes
Class DGList
{
    [String]$Name
    [Object]$Value
    DGList([String]$Name,[Object]$Value)
    {
        $This.Name  = $Name
        $This.Value = Switch ($Value.Count) { 0 { "" } 1 { $Value } Default { $Value -join "`n" } }
    }
}

Class XamlWindow
{
    Hidden [Object]        $Xaml
    Hidden [Object]         $Xml
    [String[]]            $Names
    [Object[]]            $Types
    [Object]               $Node
    [Object]                 $IO
    [Object]         $Dispatcher
    [Object]          $Exception
    [String] FormatXaml([String]$Xaml)
    {
        $StringWriter          = [System.IO.StringWriter]::New()
        $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
        $XmlWriter.Formatting  = "indented"
        $XmlWriter.Indentation = 4
        ([Xml]$Xaml).WriteContentTo($XmlWriter)
        $XmlWriter.Flush()
        $StringWriter.Flush()
        Return $StringWriter.ToString()
    }
    [String[]] FindNames()
    {
        Return [Regex]::Matches($This.Xaml,"((\s*Name\s*=\s*)('|`")(\w+)('|`"))").Groups | ? Name -eq 4 | % Value | Select-Object -Unique
    }
    XamlWindow([String]$Xaml)
    {
        $This.Xaml               = $This.FormatXaml($Xaml)   
        If (!$This.Xaml)
        {
            Throw "Invalid Xaml Input"
        }
        
        [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        
        $This.Xml                = [Xml]$Xaml
        $This.Names              = $This.FindNames()
        $This.Types              = @( )
        $This.Node               = [System.Xml.XmlNodeReader]::New($This.Xml)
        $This.IO                 = [System.Windows.Markup.XamlReader]::Load($This.Node)
        $This.Dispatcher         = $This.IO.Dispatcher
    }
    ProcessNames()
    {
        ForEach ($I in 0..($This.Names.Count - 1))
        {
            $Name                = $This.Names[$I]
            $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
            If ($This.IO.$Name)
            {
                $This.Types     += [DGList]::New($Name,$This.IO.$Name.GetType().Name)
            }
        }
    }
    UpdateWindow([Object]$Control,[Object]$Property,[Object]$Value)
    {
        $Window = $This.IO
        $Window.$Control.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background,
        [Action]{$Window.$Control.$Property = $Value}, "Normal")
    }
    Invoke()
    {
        Try
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
        Catch
        {
            $This.Exception     = $PSItem
        }
        Finally
        {

        }
    }
}

# Get-Content $Home\Desktop\EventLogs.xaml | % { "        '$_'," } | Set-Clipboard
Class EventLogGUI
{
    Static [String] $Tab = @(        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Event Log Utility" Width="800" Height="650" HorizontalAlignment="Center" Topmost="False" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
    '    <Window.Resources>',
    '        <Style TargetType="GroupBox">',
    '            <Setter Property="Margin" Value="10"/>',
    '            <Setter Property="Padding" Value="10"/>',
    '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
    '            <Setter Property="Template">',
    '                <Setter.Value>',
    '                    <ControlTemplate TargetType="GroupBox">',
    '                        <Border CornerRadius="10" Background="White" BorderBrush="Black" BorderThickness="3">',
    '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
    '                        </Border>',
    '                    </ControlTemplate>',
    '                </Setter.Value>',
    '            </Setter>',
    '        </Style>',
    '        <Style TargetType="Button">',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="Padding" Value="5"/>',
    '            <Setter Property="Height" Value="30"/>',
    '            <Setter Property="FontWeight" Value="Semibold"/>',
    '            <Setter Property="FontSize" Value="12"/>',
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
    '        <Style TargetType="DataGridCell">',
    '            <Setter Property="TextBlock.TextAlignment" Value="Left" />',
    '        </Style>',
    '        <Style TargetType="DataGrid">',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="AutoGenerateColumns" Value="False"/>',
    '            <Setter Property="AlternationCount" Value="3"/>',
    '            <Setter Property="HeadersVisibility" Value="Column"/>',
    '            <Setter Property="CanUserResizeRows" Value="False"/>',
    '            <Setter Property="CanUserAddRows" Value="False"/>',
    '            <Setter Property="IsReadOnly" Value="True"/>',
    '            <Setter Property="IsTabStop" Value="True"/>',
    '            <Setter Property="IsTextSearchEnabled" Value="True"/>',
    '            <Setter Property="SelectionMode" Value="Extended"/>',
    '            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>',
    '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>',
    '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>',
    '        </Style>',
    '        <Style TargetType="DataGridRow">',
    '            <Setter Property="BorderBrush" Value="Black"/>',
    '            <Style.Triggers>',
    '                <Trigger Property="AlternationIndex" Value="0">',
    '                    <Setter Property="Background" Value="White"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex" Value="1">',
    '                    <Setter Property="Background" Value="#FFC5E5EC"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex" Value="2">',
    '                    <Setter Property="Background" Value="#FFFDE1DC"/>',
    '                </Trigger>',
    '            </Style.Triggers>',
    '        </Style>',
    '        <Style TargetType="DataGridColumnHeader">',
    '            <Setter Property="FontSize"   Value="10"/>',
    '            <Setter Property="FontWeight" Value="Medium"/>',
    '            <Setter Property="Margin" Value="2"/>',
    '            <Setter Property="Padding" Value="2"/>',
    '        </Style>',
    '        <Style TargetType="ComboBox">',
    '            <Setter Property="Height" Value="24"/>',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="FontSize" Value="12"/>',
    '            <Setter Property="FontWeight" Value="Normal"/>',
    '        </Style>',
    '        <Style TargetType="CheckBox">',
    '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
    '            <Setter Property="HorizontalAlignment" Value="Center"/>',
    '            <Setter Property="Height" Value="24"/>',
    '            <Setter Property="Margin" Value="5"/>',
    '        </Style>',
    '        <Style x:Key="DropShadow">',
    '            <Setter Property="TextBlock.Effect">',
    '                <Setter.Value>',
    '                    <DropShadowEffect ShadowDepth="1"/>',
    '                </Setter.Value>',
    '            </Setter>',
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
    '            <Setter Property="IsReadOnly" Value="True"/>',
    '            <Style.Resources>',
    '                <Style TargetType="Border">',
    '                    <Setter Property="CornerRadius" Value="2"/>',
    '                </Style>',
    '            </Style.Resources>',
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
    '        <Style TargetType="TabItem">',
    '            <Setter Property="Template">',
    '                <Setter.Value>',
    '                    <ControlTemplate TargetType="TabItem">',
    '                        <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">',
    '                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
    '                        </Border>',
    '                        <ControlTemplate.Triggers>',
    '                            <Trigger Property="IsSelected" Value="True">',
    '                                <Setter TargetName="Border" Property="Background" Value="#4444FF"/>',
    '                                <Setter Property="Foreground" Value="#FFFFFF"/>',
    '                            </Trigger>',
    '                            <Trigger Property="IsSelected" Value="False">',
    '                                <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>',
    '                                <Setter Property="Foreground" Value="#000000"/>',
    '                            </Trigger>',
    '                            <Trigger Property="IsEnabled" Value="False">',
    '                                <Setter TargetName="Border" Property="Background" Value="#6F6F6F"/>',
    '                                <Setter Property="Foreground" Value="#9F9F9F"/>',
    '                            </Trigger>',
    '                        </ControlTemplate.Triggers>',
    '                    </ControlTemplate>',
    '                </Setter.Value>',
    '            </Setter>',
    '        </Style>',
    '    </Window.Resources>',
    '    <Grid>',
    '        <Grid.Background>',
    '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
    '        </Grid.Background>',
    '        <GroupBox>',
    '            <Grid>',
    '                <Grid.RowDefinitions>',
    '                    <RowDefinition Height="40"/>',
    '                    <RowDefinition Height="*"/>',
    '                </Grid.RowDefinitions>',
    '                <Grid Grid.Row="0">',
    '                    <Grid.ColumnDefinitions>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                    </Grid.ColumnDefinitions>',
    '                    <Button Grid.Column="0" Name="MainTab"   Content="Main"/>',
    '                    <Button Grid.Column="1" Name="LogTab"    Content="Log(s)" IsEnabled="False"/>',
    '                    <Button Grid.Column="2" Name="OutputTab" Content="Output" IsEnabled="False"/>',
    '                    <Button Grid.Column="3" Name="ViewTab"   Content="View" IsEnabled="False"/>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="MainPanel" Visibility="Visible">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="80"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Mode]:"/>',
    '                        <ComboBox Grid.Column="1" Name="Mode" SelectedIndex="0">',
    '                            <ComboBoxItem Content="(Get/View) Event logs on this system"/>',
    '                            <ComboBoxItem Content="(Import/View) Event logs from an archive"/>',
    '                        </ComboBox>',
    '                        <Button Grid.Column="2" Content="Continue" Name="Continue"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Time]:"/>',
    '                        <TextBox Grid.Column="1" Name="Time" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Start]:"/>',
    '                        <TextBox Grid.Column="1" Name="Start" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[DisplayName]:"/>',
    '                        <TextBox Grid.Column="1" Name="DisplayName" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Destination]:"/>',
    '                        <TextBox Grid.Column="1" Name="Destination" IsEnabled="False"/>',
    '                        <Button Grid.Column="2" Content="Export" Name="Export" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="380"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Providers]:"/>',
    '                        <ComboBox Grid.Column="1" Name="Providers" IsEnabled="False"/>',
    '                        <Label Grid.Column="2" Content="[Count]:"/>',
    '                        <TextBox Grid.Column="3" Name="ProviderCount" IsEnabled="False"/>',
    '                        <CheckBox Grid.Column="4" IsEnabled="False" Content="Console" IsChecked="True"/>',
    '                    </Grid>',
    '                    <TextBox Grid.Row="6" Margin="5" Height="Auto" Name="Console" TextWrapping="NoWrap" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" TextAlignment="Left" VerticalContentAlignment="Top" FontFamily="Cascadia Code" FontSize="10"/>',
    '                    <DataGrid Grid.Row="7" Name="Archive" IsEnabled="False">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Mode"     Binding="{Binding Mode}"           Width="40"/>',
    '                            <DataGridTextColumn Header="Modified" Binding="{Binding Modified}"       Width="150"/>',
    '                            <DataGridTextColumn Header="Size"     Binding="{Binding Size}"           Width="75"/>',
    '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"           Width="225"/>',
    '                            <DataGridTextColumn Header="Path"     Binding="{Binding Path}"           Width="600"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="8">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[File Path]:"/>',
    '                        <TextBox Grid.Column="1" Name="FilePath" IsReadOnly="False" IsEnabled="False"/>',
    '                        <Button Grid.Column="2"  Name="FilePathBrowse" Content="Browse" IsEnabled="False"/>',
    '                    </Grid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="LogPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Log Main]:"/>',
    '                        <ComboBox Grid.Column="1" Name="LogMainProperty" SelectedIndex="1">',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Name"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Path"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="LogMainFilter"/>',
    '                        <Button Grid.Column="3" Name="LogMainRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Name="LogMainResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Rank"       Binding="{Binding Rank}"         Width="40"/>',
    '                            <DataGridTextColumn Header="Name"       Binding="{Binding LogName}"      Width="500"/>',
    '                            <DataGridTextColumn Header="Total"      Binding="{Binding Total}"        Width="100"/>',
    '                            <DataGridTextColumn Header="Type"       Binding="{Binding LogType}"      Width="100"/>',
    '                            <DataGridTextColumn Header="Isolation"  Binding="{Binding LogIsolation}" Width="100"/>',
    '                            <DataGridTextColumn Header="Enabled"    Binding="{Binding IsEnabled}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Classic"    Binding="{Binding IsClassicLog}" Width="50"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="50"/>',
    '                            <ColumnDefinition Width="50"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label   Grid.Column="0" Content="[Selected]:"/>',
    '                        <TextBox Grid.Column="1" Name="LogSelected"/>',
    '                        <Label   Grid.Column="2" Content="[Ct]:"/>',
    '                        <TextBox Grid.Column="3" Name="LogTotal"/>',
    '                        <Button Grid.Column="4" Name="LogClear" Content="Clear"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Output]:"/>',
    '                        <ComboBox Grid.Column="1" Name="LogOutputProperty" SelectedIndex="1">',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Log"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Provider"/>',
    '                            <ComboBoxItem Content="Id"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Message"/>',
    '                            <ComboBoxItem Content="Content"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="LogOutputFilter"/>',
    '                        <Button Grid.Column="3" Name="LogOutputRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="4" Name="LogOutputResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="350"/>',
    '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="OutputPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Output]:"/>',
    '                        <ComboBox Grid.Column="1" Name="OutputProperty" SelectedIndex="0">',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Log"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Provider"/>',
    '                            <ComboBoxItem Content="Id"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Message"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="OutputFilter"/>',
    '                        <Button Grid.Column="3" Name="OutputRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Name="OutputResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                            <DataGridTextColumn Header="Log"      Binding="{Binding Log}"      Width="50"/>',
    '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="350"/>',
    '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="ViewPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <DataGrid Grid.Row="0" Name="ViewResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="200"/>',
    '                            <DataGridTextColumn Header="Value"    Binding="{Binding Value}"    Width="*">',
    '                                <DataGridTextColumn.ElementStyle>',
    '                                    <Style TargetType="TextBlock">',
    '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                    </Style>',
    '                                </DataGridTextColumn.ElementStyle>',
    '                                <DataGridTextColumn.EditingElementStyle>',
    '                                    <Style TargetType="TextBox">',
    '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                        <Setter Property="AcceptsReturn" Value="True"/>',
    '                                    </Style>',
    '                                </DataGridTextColumn.EditingElementStyle>',
    '                            </DataGridTextColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0" Name="ViewCopy"  Content="Copy to clipboard"/>',
    '                        <Button Grid.Column="2" Name="ViewClear" Content="Clear"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </Grid>',
    '        </GroupBox>',
    '    </Grid>',
    '</Window>' -join "`n")
}

Function Get-EventLogConfigExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][UInt32]$Rank,
        [Parameter(Mandatory,ParameterSetName=0)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Config)

    Class EventLogConfigExtension
    {
        [UInt32] $Rank
        [String] $LogName
        [Object] $LogType
        [Object] $LogIsolation
        [Boolean] $IsEnabled
        [Boolean] $IsClassicLog
        Hidden [String] $SecurityDescriptor
        [String] $LogFilePath
        Hidden [Int64] $MaximumSizeInBytes
        [Object] $Maximum
        [Object] $Current
        [Object] $LogMode
        Hidden [String] $OwningProviderName
        [Object] $ProviderNames
        Hidden [Object] $ProviderLevel
        Hidden [Object] $ProviderKeywords
        Hidden [Object] $ProviderBufferSize
        Hidden [Object] $ProviderMinimumNumberOfBuffers
        Hidden [Object] $ProviderMaximumNumberOfBuffers
        Hidden [Object] $ProviderLatency
        Hidden [Object] $ProviderControlGuid
        Hidden [Object[]] $EventLogRecord
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Name)
        {
            $This.Rank                           = $Rank
            $Event                               = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($Name)
            $This.LogName                        = $Event.LogName 
            $This.LogType                        = $Event.LogType 
            $This.LogIsolation                   = $Event.LogIsolation 
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = "{0:n2} MB" -f ($Event.MaximumSizeInBytes/1MB) 
            $This.Current                        = If (!(Test-Path $This.LogFilePath)) { "0.00 MB" } Else { "{0:n2} MB" -f (Get-Item $This.LogFilePath | % { $_.Length/1MB }) }
            $This.LogMode                        = $Event.LogMode
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        EventLogConfigExtension([Object]$Event)
        {
            $This.Rank                           = $Event.Rank
            $This.Logname                        = $Event.LogName
            $This.LogType                        = $This.GetLogType($Event.LogType)
            $This.LogIsolation                   = $This.GetLogIsolation($Event.LogIsolation)
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath 
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = $Event.Maximum
            $This.Current                        = $Event.Current
            $This.LogMode                        = $This.GetLogMode($Event.LogMode)
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        GetEventLogRecord()
        {
            $This.Output = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
            $This.Total  = $This.Output.Count
            $Depth       = ([String]$This.Total.Count).Length
            If ($This.Total -gt 0)
            {
                $C = 0
                ForEach ($Record in $This.Output)
                {
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    Index -Value $Null
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Rank -Value $C 
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    LogId -Value $This.Rank
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name DateTime -Value $Record.TimeCreated
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Date -Value $Record.TimeCreated.ToString("yyyy-MMdd-HHMMss")
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Name -Value ("$($Record.Date)-$($This.Rank)-{0:d$Depth}" -f $C)
                    $C ++
                }
            }
        }
        [Object] GetLogType([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogType]::Administrative }
                1 { [System.Diagnostics.Eventing.Reader.EventLogType]::Operational }
                2 { [System.Diagnostics.Eventing.Reader.EventLogType]::Analytical }
                3 { [System.Diagnostics.Eventing.Reader.EventLogType]::Debug }  
            }
            Return $Return
        }
        [Object] GetLogIsolation([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Application }
                1 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::System }
                2 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Custom }
            }
            Return $Return
        }
        [Object] GetLogMode([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular   }
                1 { [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup }
                2 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain     }
            }
            Return $Return
        }
        [Object] Config()
        {
            Return $This | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,MaximumSizeInBytes,Maximum,Current,LogMode,
            OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,
            ProviderControlGuid
        }
    }
    
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogConfigExtension]::New($Rank,$Name) }
        1 { [EventLogConfigExtension]::New($Config)     }
    }
}

Function Get-EventLogRecordExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][Object]$Record,
        [Parameter(Mandatory,ParameterSetName=1)][UInt32]$Index,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Entry)

    Class EventLogRecordExtension
    {
        [UInt32]   $Index
        Hidden [String] $Name
        Hidden [Object] $DateTime
        [String]   $Date
        [String]   $Log
        [UInt32]   $Rank
        [String]   $Provider
        [UInt32]   $Id
        [String]   $Type
        [String]   $Message
        Hidden [String[]] $Content
        Hidden [Object] $Version
        Hidden [Object] $Qualifiers
        Hidden [Object] $Level
        Hidden [Object] $Task
        Hidden [Object] $Opcode
        Hidden [Object] $Keywords
        Hidden [Object] $RecordId
        Hidden [Object] $ProviderId
        Hidden [Object] $LogName
        Hidden [Object] $ProcessId
        Hidden [Object] $ThreadId
        Hidden [Object] $MachineName
        Hidden [Object] $UserID
        Hidden [Object] $ActivityID
        Hidden [Object] $RelatedActivityID
        Hidden [Object] $ContainerLog
        Hidden [Object] $MatchedQueryIds
        Hidden [Object] $Bookmark
        Hidden [Object] $OpcodeDisplayName
        Hidden [Object] $TaskDisplayName
        Hidden [Object] $KeywordsDisplayNames
        Hidden [Object] $Properties
        EventLogRecordExtension([Object]$Record)
        {
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.ProviderName
            $This.DateTime    = $Record.TimeCreated
            $This.Date        = $Record.Date
            $This.Log         = $Record.LogId
            $This.Id          = $Record.Id
            $This.Type        = $Record.LevelDisplayName
            $This.InsertEvent($Record)
        }
        EventLogRecordExtension([UInt32]$Index,[Object]$Entry)
        {
            $Stream           = $Entry.Open()
            $Reader           = [System.IO.StreamReader]::New($Stream)
            $RecordEntry      = $Reader.ReadToEnd() 
            $Record           = $RecordEntry | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.DateTime    = [DateTime]$Record.DateTime
            $This.Date        = $Record.Date
            $This.Log         = $Record.Log
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.Provider
            $This.Id          = $Record.Id
            $This.Type        = $Record.Type
            $This.InsertEvent($Record)
        }
        InsertEvent([Object]$Record)
        {
            $FullMessage   = $Record.Message -Split "`n"
            Switch ($FullMessage.Count)
            {
                {$_ -gt 1}
                {
                    $This.Message  = $FullMessage[0] -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 1}
                {
                    $This.Message  = $FullMessage -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 0}
                {
                    $This.Message  = "-"
                    $This.Content  = "-"
                }
            }
            $This.Version              = $Record.Version
            $This.Qualifiers           = $Record.Qualifiers
            $This.Level                = $Record.Level
            $This.Task                 = $Record.Task
            $This.Opcode               = $Record.Opcode
            $This.Keywords             = $Record.Keywords
            $This.RecordId             = $Record.RecordId
            $This.ProviderId           = $Record.ProviderId
            $This.LogName              = $Record.LogName
            $This.ProcessId            = $Record.ProcessId
            $This.ThreadId             = $Record.ThreadId
            $This.MachineName          = $Record.MachineName
            $This.UserID               = $Record.UserId
            $This.ActivityID           = $Record.ActivityId
            $This.RelatedActivityID    = $Record.RelatedActivityID
            $This.ContainerLog         = $Record.ContainerLog
            $This.MatchedQueryIds      = @($Record.MatchedQueryIds)
            $This.Bookmark             = $Record.Bookmark
            $This.OpcodeDisplayName    = $Record.OpcodeDisplayName
            $This.TaskDisplayName      = $Record.TaskDisplayName
            $This.KeywordsDisplayNames = @($Record.KeywordsDisplayNames)
            $This.Properties           = @($Record.Properties.Value)
        }
        [Object] Export()
        {
            Return @( $This | ConvertTo-Json )
        }
        [Object] Config()
        {
            Return $This | Select-Object Index,Name,DateTime,Date,Log,Rank,Provider,Id,Type,Message,Content,
            Version,Qualifiers,Level,Task,Opcode,Keywords,RecordId,ProviderId,LogName,ProcessId,ThreadId,MachineName,
            UserID,ActivityID,RelatedActivityID,ContainerLog,MatchedQueryIds,Bookmark,OpcodeDisplayName,TaskDisplayName,
            KeywordsDisplayNames,Properties
        }
        [Void] SetContent([String]$Path)
        {
            [System.IO.File]::WriteAllLines($Path,$This.Export())
        }
        [Object] ToString()
        {
            Return @( $This.Export() | ConvertFrom-Json )
        }
    }
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogRecordExtension]::New($Record) }
        1 { [EventLogRecordExtension]::New(0,$Entry) }
    }
}

Function Get-SystemDetails
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=1)][Object]$Result)

    # Formatting classes
    Class DGList
    {
        [String] $Name
        [Object] $Value
        Hidden [UInt32] $Buffer
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name = $Name
            $This.Value = Switch ($Value.Count) { 0 { $Null } 1 { $Value } Default { $Value -join "`n" } }
        }
        SetBuffer([UInt32]$MaxLength)
        {
            $This.Buffer = $MaxLength
        }
        [String] ToString()
        {
            If ($This.Buffer)
            {
                Return ("{0}{1} {2}" -f $This.Name, (" " * ($This.Buffer-$This.Name.Length) -join ""), $This.Value)
            }
            ElseIf (!$This.Buffer)
            {
                Return "{0} {1}" -f $This.Name, $This.Value
            }
            Else
            {
                Return $Null
            }
        }
    }

    # Allows for group management of property/values
    Class PropertyItem
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Value
        Hidden [String] $Type
        Hidden [UInt32] $Buffer
        Hidden [UInt32] $Slot
        PropertyItem([UInt32]$Index,[Object]$Property)
        {
            $This.Index  = $Index
            $This.Name   = $Property.Name
            $This.Value  = $Property.Value
            $This.Type   = $Property.TypeNameOfValue
            $This.Buffer = $Property.Name.Length
            $This.Slot   = 0
        }
        PropertyItem([UInt32]$Index,[Object]$Object,[Bool]$Flag)
        {
            $This.Index  = $Index
            $This.Name   = $Object.Name
            If ($Flag)
            {
                $This.Value = $Object.Value
                $This.Type  = $Object.GetType().Name
                $This.Slot  = 1
            }
            If (!$Flag)
            {
                $This.Value = $Null
                $This.Type  = $Null
                $This.Slot  = 2
            }
            
            $This.Buffer = $This.Name.Length
        }
        SetBuffer([UInt32]$X)
        {
            If ($X -ge $This.Name.Length)
            {
                $This.Buffer = $X
            }
        }
        [String] Buff()
        {
            Return (" " * ($This.Buffer - $This.Name.Length) -join '')
        }
        [String] ToString()
        {
            If ($This.Buffer -gt $This.Name.Length)
            {
                Return "{0}{1} {2}" -f $This.Name, $This.Buff(), $This.Value
            }
            Else
            {
                Return "{0} {1}" -f $This.Name, $This.Value
            }
        }
    }

    # Also allows for having multiple items within a particular index
    Class PropertySlot
    {
        [UInt32] $Index
        [UInt32] $Rank
        [Object] $Content
        [UInt32] $MaxLength
        PropertySlot([UInt32]$Index,[UInt32]$Rank)
        {
            $This.Index   = $Index
            $This.Rank    = $Rank
            $This.Content = @( )
        }
        AddProperty([Object]$Property)
        {
            $This.Content += [PropertyItem]::New($This.Content.Count,$Property)
        }
        AddProperty([Object]$Object,[Bool]$Flag=$True)
        {
            $This.Content += [PropertyItem]::New($This.Content.Count,$Object,$Flag)
        }
        AddProperty([String]$Name,[String]$Value,[Bool]$Flag)
        {
            $This.Content += [PropertyItem]::New($This.Content.Count,$Name,$Value,$Flag)
        }
        GetMaxLength()
        {
            $This.MaxLength = ($This.Content.Name | Sort-Object Length)[-1].Length
        }
        SetBuffer([UInt32]$Width)
        {
            ForEach ($Item in $This.Content)
            {
                $Item.SetBuffer($Width)
            }
        }
        [String[]] GetOutput()
        {
            Return @( $This.Content | % ToString )
        }
    }

    # All in an effort...
    Class PropertySet
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Slot
        [UInt32] $Quantity
        [UInt32] $MaxLength
        PropertySet([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Slot     = @( )
            $This.AddPropertySlot(0)
            $This.AddObject(0,$Object)
            $This.Quantity = 1
        }
        PropertySet([UInt32]$Index,[String]$Name,[Object[]]$Object)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Slot     = @( )
            ForEach ($X in 0..($Object.Count-1))
            {
                $This.AddPropertySlot($This.Slot.Count)
                $This.AddObject($X,$Object[$X])
            }
            $This.Quantity = $Object.Count
        }
        PropertySet([UInt32]$Index,[String]$Name,[Object[]]$Object,[UInt32]$Array)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Slot     = @( )
            $This.AddPropertySlot(0)
            $This.AddArray(0,$Object)
            $This.Quantity = $Object.Count
        }
        AddPropertySlot([UInt32]$Rank)
        {
            $This.Slot += [PropertySlot]::New($This.Index,$Rank)
        }
        AddProperty([UInt32]$Rank,[Object]$Property)
        {
            $This.Slot[$Rank].AddProperty($Property)
        }
        AddProperty([UInt32]$Rank,[String]$Name,[Object]$Value,[Bool]$Flag=$False)
        {
            $Object        = $This.NewObject($Name,$Value)
            $This.Slot[$Rank].AddProperty($Object,$Flag)
        }
        [Object] NewObject([String]$Name,[Object]$Value)
        {
            Return [PSCustomObject]@{ Name = $Name; Value = $Value }
        }
        AddArray([UInt32]$Rank,[Object[]]$Object)
        {
            ForEach ($Item in $Object)
            {
                $This.AddProperty($Rank,$Item)
            }
        }
        AddObject([UInt32]$Rank,[Object]$Object)
        {
            ForEach ($Property in $Object.PSObject.Properties)
            {
                Switch -Regex ($Property.TypeNameOfValue)
                {
                    Default 
                    { 
                        $This.AddProperty($Rank,$Property) 
                    }
                    "\[\]"
                    {   
                        # Sets anchor for nested items
                        $Parent = $Property.Name
                        $Values = $Property.Value

                        # Sets label for nested items
                        $This.AddProperty($Rank,"$Parent`s",$Values.Count, 1)

                        # Drills down into the sets of values
                        ForEach ($X in 0..($Values.Count-1))
                        {
                            $This.AddProperty($Rank,$Parent + $X, $Null, 0)

                            # Sets each item accoring to higher scope
                            ForEach ($Item in $Values[$X].PSObject.Properties)
                            {
                                $This.AddProperty($Rank,$Parent + $X + $Item.Name, $Item.Value, 1)
                            }
                        }
                    }
                }
            }
            $This.GetMaxLength()
            $This.SetBuffer($This.MaxLength)
        }
        GetMaxLength()
        {
            ForEach ($Item in $This.Slot)
            {
                $Item.GetMaxLength()
            }

            $This.MaxLength = ($This.Slot.MaxLength | Sort-Object)[-1]
        }
        SetBuffer([UInt32]$Width)
        {
            $This.GetMaxLength()

            If ($Width -gt $This.MaxLength)
            {
                $This.Buffer = $Width
                ForEach ($Item in $This.Slot)
                {
                    $Item.SetBuffer($Width)
                }
            }
        }
        [String] Frame([String]$String)
        {
            If ($String.Length -gt 1)
            {
                Throw "Only one character"
            }
            Return @($String) * 120 -join ''
        }
        [String] Sublabel([UInt32]$Count)
        {
            Return $This.Name -Replace "\(s\)", $Count
        }
        [String[]] GetOutput()
        {
            $Return  = @( )
            $Return += $This.Frame("-")
            $Return += $This.Name
            $Return += $This.Frame("-")
            $Return += $This.Frame(" ")
            If ($This.Name -match "(^Processor\(s\)$|^Disk\(s\)$|^Network\(s\)$)")
            {
                $AltName = $This.Name -Replace "(\(|\))",""
                $Return += ("{0}{1} {2}" -f $AltName, (" " * ($This.MaxLength-$AltName.Length) -join ""), $This.Quantity)
                $Return += $This.Frame(" ")
                $C       = 0
                ForEach ($Slot in $This.Slot)
                {
                    $Return += $This.Sublabel($C)
                    ForEach ($Line in $Slot.GetOutput())
                    {
                        $Return += $Line
                    }
                    $Return += $This.Frame(" ")
                    $C ++
                }
            }
            Else
            {
                If ($This.Name -match "(^Log Providers$)")
                {
                    $Alt     = "Logs"
                    $Return += ("{0}{1} {2}" -f $Alt, (" " * ($This.MaxLength-$Alt.Length) -join ""), $This.Quantity)
                    $Return += $This.Frame(" ")
                }
                ForEach ($Line in $This.Slot.GetOutput())
                {
                    $Return += $Line
                }
                $Return += $This.Frame(" ")
            }
            Return $Return
        }
    }

    # To provide the cleanest format possible...
    Class PropertyControl
    {
        [Object] $Content
        [UInt32] $Count
        [UInt32] $MaxLength
        PropertyControl()
        {
            $This.Content   = @( )
        }
        Add([String]$Name,[Object[]]$Object)
        {
            $This.Content += [PropertySet]::New($This.Content.Count,$Name,$Object)
            $This.Count    = $This.Content.Count
            $This.GetMaxLength()
            $This.SetBuffer($This.MaxLength)
        }
        Add([String]$Name,[Object]$Object)
        {
            $This.Content  += [PropertySet]::New($This.Content.Count,$Name,$Object)
            $This.MaxLength = @( $This.Content.MaxLength | Sort-Object )[-1]
            $This.Count     = $This.Content.Count
            $This.GetMaxLength()
            $This.SetBuffer($This.MaxLength)
        }
        Add([String]$Name,[Object]$Object,[UInt32]$Flag)
        {
            $This.Content += [PropertySet]::New($This.Content.Count,$Name,$Object,1)
            $This.MaxLength = @( $This.Content.MaxLength | Sort-Object )[-1]
            $This.Count     = $This.Content.Count
            $This.GetMaxLength()
            $This.SetBuffer($This.MaxLength)
        }
        GetMaxLength()
        {
            ForEach ($Content in $This.Content)
            {
                ForEach ($Slot in $Content.Slot)
                {
                    $Slot.GetMaxLength()
                }
            }

            $This.MaxLength = @( $This.Content.Slot.MaxLength | Sort-Object )[-1]
        }
        SetBuffer([UInt32]$Width)
        {
            If ($This.MaxLength -ne 0 -and $Width -ge $This.MaxLength)
            {
                ForEach ($Item in $This.Content)
                {
                    $Item.MaxLength     = $Width
                    ForEach ($Slot in $Item.Slot)
                    {
                        $Slot.MaxLength = $Width
                        $Slot.SetBuffer($Width)
                    }
                }
            }
        }
        [Object] GetOutput()
        {
            Return @( ForEach ($X in 0..($This.Content.Count-1))
            {
                $This.Content[$X].GetOutput()
            })
        }
    }

    # This takes a snapshot of the system with date/time, guid, etc.
    Class Snapshot
    {
        [String] $Start
        [String] $ComputerName
        [String] $DisplayName
        [String] $Guid
        [UInt32] $Complete
        [String] $Elapsed
        Snapshot()
        {
            $Current           = [DateTime]::Now
            $This.Start        = $Current
            $This.ComputerName = [Environment]::MachineName
            $This.DisplayName  = "{0}-{1}" -f $Current.ToString("yyyy-mmdd-HHMMss"), $This.ComputerName
            $This.Guid         = [Guid]::NewGuid().ToString()
        }
        Snapshot([String[]]$S)
        {
            $This.Start        = $This.X("Start")
            $This.ComputerName = $This.X("ComputerName")
            $This.DisplayName  = $This.X("DisplayName")
            $This.Guid         = $This.X("Guid")
            $This.Complete     = $This.X("Complete")
            $This.Elapsed      = $This.X("Elapsed")
        }
        Snapshot([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        MarkComplete()
        {
            $This.Complete     = 1 
            $This.Elapsed      = [String][Timespan]([DateTime]::Now-[DateTime]$This.Start)
        }
        [Object] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Snapshot",$This)
        }
    }

    # Bios Information for the system this tool is run on
    Class BiosInformation
    {
        [String] $Name
        [String] $Manufacturer
        [String] $SerialNumber
        [String] $Version
        [String] $ReleaseDate
        [Bool]   $SmBiosPresent
        [String] $SmBiosVersion
        [String] $SmBiosMajor
        [String] $SmBiosMinor
        [String] $SystemBiosMajor
        [String] $SystemBiosMinor
        BiosInformation()
        {
            $Bios                 = Get-CimInstance Win32_Bios
            $This.Name            = $Bios.Name
            $This.Manufacturer    = $Bios.Manufacturer
            $This.SerialNumber    = $Bios.SerialNumber
            $This.Version         = $Bios.Version
            $This.ReleaseDate     = $Bios.ReleaseDate
            $This.SmBiosPresent   = $Bios.SmBiosPresent
            $This.SmBiosVersion   = $Bios.SmBiosBiosVersion
            $This.SmBiosMajor     = $Bios.SmBiosMajorVersion
            $This.SmBiosMinor     = $Bios.SmBiosMinorVersion
            $This.SystemBiosMajor = $Bios.SystemBiosMajorVersion
            $This.SystemBIosMinor = $Bios.SystemBiosMinorVersion
        }
        BiosInformation([String[]]$S)
        {
            $This.Name            = $This.X($S,"Name")
            $This.Manufacturer    = $This.X($S,"Manufacturer")
            $This.SerialNumber    = $This.X($S,"SerialNumber")
            $This.Version         = $This.X($S,"Version")
            $This.ReleaseDate     = $This.X($S,"ReleaseDate")
            $This.SmBiosPresent   = $This.X($S,"SmBiosPresent")
            $This.SmBiosVersion   = $This.X($S,"SmBiosVersion")
            $This.SmBiosMajor     = $This.X($S,"SmBiosMajor")
            $This.SmBiosMinor     = $This.X($S,"SmBiosMinor")
            $This.SystemBiosMajor = $This.X($S,"SystemBiosMajor")
            $This.SystemBiosMinor = $This.X($S,"SystemBiosMinor")
        }
        BiosInformation([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Bios Information",$This)
        }
    }

    # Operating system information for the system this tool is run on
    Class OperatingSystem
    {
        [String] $Caption
        [String] $Version
        [String] $Build
        [String] $Serial
        [UInt32] $Language
        [UInt32] $Product
        [UInt32] $Type
        OperatingSystem()
        {
            $OS            = Get-WmiObject Win32_OperatingSystem
            $This.Caption  = $OS.Caption
            $This.Version  = $OS.Version
            $This.Build    = $OS.BuildNumber
            $This.Serial   = $OS.SerialNumber
            $This.Language = $OS.OSLanguage
            $This.Product  = $OS.OSProductSuite
            $This.Type     = $OS.OSType
        }
        OperatingSystem([String[]]$S)
        {
            $This.Caption  = $This.X($S,"Caption")
            $This.Version  = $This.X($S,"Version")
            $This.Build    = $This.X($S,"Build")
            $This.Serial   = $This.X($S,"Serial")
            $This.Language = $This.X($S,"Language")
            $This.Product  = $This.X($S,"Product")
            $This.Type     = $This.X($S,"Type")
        }
        OperatingSystem([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Operating System",$This)
        }
    }

    # Computer system information for the system this tool is run on
    Class ComputerSystem
    {
        [String] $Manufacturer
        [String] $Model
        [String] $Product
        [String] $Serial
        [String] $Memory
        [String] $Architecture
        [String] $UUID
        [String] $Chassis
        [String] $BiosUefi
        [Object] $AssetTag
        ComputerSystem()
        {
            $Sys               = Get-WmiObject Win32_ComputerSystem 
            $This.Manufacturer = $Sys.Manufacturer
            $This.Model        = $Sys.Model
            $This.Memory       = "{0} GB" -f ($Sys.TotalPhysicalMemory/1GB)
            $This.UUID         = (Get-WmiObject Win32_ComputerSystemProduct).UUID 
            
            $Sys               = Get-WmiObject Win32_BaseBoard
            $This.Product      = $Sys.Product
            $This.Serial       = $Sys.SerialNumber -Replace "\.",""
            
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }

            $Sys               = Get-WmiObject Win32_SystemEnclosure
            $This.AssetTag     = $Sys.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$Sys.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[[Environment]::GetEnvironmentVariable("Processor_Architecture")]
        }
        ComputerSystem([String[]]$S)
        {
            $this.Manufacturer = $This.X($S,"Manufacturer")
            $This.Model        = $This.X($S,"Model")
            $This.Product      = $This.X($S,"Product")
            $This.Serial       = $This.X($S,"Serial")
            $This.Memory       = $This.X($S,"Memory")
            $This.Architecture = $This.X($S,"Architecture")
            $This.UUID         = $This.X($S,"UUID")
            $This.Chassis      = $This.X($S,"Chassis")
            $This.BiosUefi     = $This.X($S,"BiosUefi")
            $This.AssetTag     = $This.X($S,"AssetTag")
        }
        ComputerSystem([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Computer System",$This)
        }
    }

    # Processor information for the system this tool is run on
    Class Processor
    {
        [String] $Manufacturer
        [String] $Name
        [String] $Caption
        [UInt32] $Cores
        [UInt32] $Used
        [UInt32] $Logical
        [UInt32] $Threads
        [String] $ProcessorId
        [String] $DeviceId
        [UInt32] $Speed
        Processor([Object]$CPU,[UInt32]$Mode)
        {
            $This.Manufacturer = Switch -Regex ($CPU.Manufacturer) { Intel { "Intel" } Amd { "AMD" } }
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.Cores        = $CPU.NumberOfCores
            $This.Used         = $CPU.NumberOfEnabledCore
            $This.Logical      = $CPU.NumberOfLogicalProcessors 
            $This.Threads      = $CPU.ThreadCount
            $This.ProcessorID  = $CPU.ProcessorId
            $This.DeviceID     = $CPU.DeviceID
            $This.Speed        = $CPU.MaxClockSpeed
        }
        Processor([String[]]$S)
        {
            $This.Manufacturer  = $This.X($S,"Manufacturer")
            $This.Name          = $This.X($S,"Name")
            $This.Caption       = $This.X($S,"Caption")
            $This.Cores         = $This.X($S,"Cores")
            $This.Used          = $This.X($S,"Used")
            $This.Logical       = $This.X($S,"Logical")
            $This.Threads       = $This.X($S,"Threads")
            $This.ProcessorId   = $This.X($S,"ProcessorId")
            $This.DeviceId      = $This.X($S,"DeviceId")
            $This.Speed         = $This.X($S,"Speed")
        }
        Processor([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Processor(s)",$This)
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    # Drive/file formatting information, for the system this tool is run on.
    Class Drive
    {
        [String] $Name
        [String] $DriveLetter
        [String] $Description
        [String] $Filesystem
        [String] $VolumeName
        [String] $VolumeSerial
        Hidden [UInt64] $FreespaceBytes
        [String] $Freespace
        Hidden [UInt64] $UsedBytes
        [String] $Used
        Hidden [UInt64] $SizeBytes
        [String] $Size
        [Bool]   $Compressed
        Drive([Object]$Drive)
        {
            $This.Name           = $Drive.Name
            $This.DriveLetter    = $Drive.Name.Trim(":")
            $This.Description    = $Drive.Description
            $This.VolumeName     = $Drive.VolumeName
            $This.VolumeSerial   = $Drive.VolumeSerial
            $This.FreespaceBytes = $Drive.Freespace
            $This.Freespace      = $This.GetSize($This.FreespaceBytes)
            $This.UsedBytes      = $Drive.Size - $Drive.Freespace
            $This.Used           = $This.GetSize($This.UsedBytes)
            $This.SizeBytes      = $Drive.Size
            $This.Size           = $This.GetSize($This.SizeBytes)
            $This.Compressed     = $Drive.Compressed
            $This.Filesystem     = $Drive.Filesystem
        }
        [String] GetSize([Int64]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -lt 1GB}
                {
                    "{0:n2} MB" -f ($Size/1MB)
                }
                {$_ -ge 1GB -and $_ -lt 1TB}
                {
                    "{0:n2} GB" -f ($Size/1GB)
                }
                {$_ -ge 1TB}
                {
                    "{0:n2} TB" -f ($Size/1TB)
                }
            })
        }
    }

    # Drive/partition information for the system this tool is run on.
    Class Partition
    {
        [String] $Type
        [String] $Name
        Hidden [BigInt] $SizeBytes
        [String] $Size
        [Bool] $Boot
        [Bool] $Primary
        [UInt32] $Disk
        [UInt32] $Partition
        Partition([Object]$Partition)
        {
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.SizeBytes  = $Partition.Size
            $This.Size       = Switch ($Partition.Size)
            {
                {$_ -lt 1GB}
                {
                    "{0:n2} MB" -f ($Partition.Size/1MB)
                }
                {$_ -ge 1GB -and $_ -lt 1TB}
                {
                    "{0:n2} GB" -f ($Partition.Size/1GB)
                }
                {$_ -ge 1TB}
                {
                    "{0:n2} TB" -f ($Partition.Size/1TB)
                }
            }
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.Partition  = $Partition.Index
        }
        Partition([String[]]$S)
        {
            $This.Type       = $This.X($S,"Type")
            $This.Name       = $This.X($S,"Name")
            $This.Size       = $This.X($S,"Size")
            $This.Boot       = $This.X($S,"Boot")
            $This.Primary    = $This.X($S,"Primary")
            $This.Disk       = $This.X($S,"Disk")
            $This.Partition  = $This.X($S,"Partition")
        }
        Partition([Object[]]$Pairs,[UInt32]$Disk)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Partitions",$This)
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    # Extended information for hard drives
    Class DiskDrive
    {
        [Object] $Disk
        [Object] $Meta
        [Object[]] $Partition
        [Object]   $Drive
        DiskDrive([Object]$Disk)
        {
            $This.Disk      = $Disk
            $This.Meta      = Get-CimInstance -ClassName MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $This.Disk.Index
            $This.Partition = Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition -InputObject $This.Disk
            $This.Drive     = $This.Partition | % { Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk -InputObject $_ -EA 0 }
        }
    }

    # Hard drive information
    Class Disk
    {
        [UInt32] $Index
        [String] $Name
        [String] $DriveLetter
        [String] $Description
        [String] $Filesystem
        [String] $VolumeName
        [String] $VolumeSerial 
        [String] $Freespace
        [String] $Used
        [String] $Size
        [Bool] $Compressed
        [String] $Disk
        [String] $Model
        [String] $Serial
        [String] $PartitionStyle
        [String] $ProvisioningType
        [String] $OperationalStatus
        [String] $HealthStatus
        [String] $BusType
        [String] $UniqueId
        [String] $Location
        [UInt32] $Partitions
        [Object[]] $Partition
        Hidden [Object] $Drive
        Disk([DiskDrive]$DD)
        {
            $This.Index             = $DD.Disk.Index
            $This.Drive             = $DD.Drive | % { [Drive]$_ }
            $This.Name              = $This.Drive.Name
            $This.DriveLetter       = $This.Drive.DriveLetter
            $This.Description       = $This.Drive.Description
            $This.Filesystem        = $This.Drive.Filesystem
            $This.VolumeName        = $This.Drive.VolumeName
            $This.VolumeSerial      = $This.Drive.VolumeSerial
            $This.Freespace         = $This.Drive.Freespace
            $This.Used              = $This.Drive.Used
            $This.Size              = $This.Drive.Size
            $This.Compressed        = $This.Drive.Compressed
            $This.Disk              = $DD.Disk.DeviceID
            $This.Model             = $DD.Disk.Model
            $This.Serial            = $DD.Disk.SerialNumber
            $This.PartitionStyle    = $DD.Meta.PartitionStyle
            $This.ProvisioningType  = $DD.Meta.ProvisioningType
            $This.OperationalStatus = $DD.Meta.OperationalStatus
            $This.HealthStatus      = $DD.Meta.HealthStatus
            $This.BusType           = $DD.Meta.BusType
            $This.UniqueId          = $DD.Meta.UniqueId
            $This.Location          = $DD.Meta.Location
            $This.Partitions        = $DD.Partition.Count
            $This.Partition         = $DD.Partition
        }
        Disk([Object[]]$Pairs,[UInt32]$Slot)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Disk(s)",$This)
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    # Connected/Online Network adapter information
    Class Network
    {
        [String] $Name
        [UInt32] $Index
        [String] $IPAddress
        [String] $SubnetMask
        [String] $Gateway
        [String] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([Object]$If)
        {
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway     | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = ($IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}) -join ", "
            $This.DhcpServer = $IF.DhcpServer           | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
        Network([String[]]$S)
        {
            $This.Name       = $This.X($S,"Name")
            $This.Index      = $This.X($S,"Index")
            $This.IPAddress  = $This.X($S,"IPAddress")
            $This.SubnetMask = $This.X($S,"SubnetMask")
            $This.Gateway    = $This.X($S,"Gateway")
            $This.DnsServer  = $This.X($S,"DnsServer").Split(",")
            $This.DhcpServer = $This.X($S,"DhcpServer")
            $This.MacAddress = $This.X($S,"MacAddress")
        }
        [String] X([Object]$Stack,[String]$Label)
        {
            Return $Stack -match "^$Label" -Replace "$Label\s+",""
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Network",$This)
        }
        [Object[]] ToString()
        {
            Return @( $This.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    }

    # List of the event log providers
    Class LogProviders
    {
        [String] $Name  = "Log Providers"
        [Object] $Output
        LogProviders()
        {
            $Logs        = Get-WinEvent -ListLog * | % Logname | Select-Object -Unique | Sort-Object
            $Depth       = ([String]$Logs.Count).Length
            $This.Output = @( )
            
            ForEach ($X in 0..($Logs.Count-1))
            {
                $This.Output += [DGList]::New(("Provider{0:d$Depth}" -f $X),$Logs[$X])
            }
        }
        SetBuffer([UInt32]$Buffer)
        {
            $This.Output | % SetBuffer $Buffer
        }
        [Object] GetOutput([UInt32]$Index)
        {
            Return [PropertySet]::New($Index,"Log Providers",$This)
        }
        [String[]] ToString()
        {
            Return @( $This.Output | % ToString )
        }
    }

    # System snapshot, the primary focus of the utility.
    Class System
    {
        [Object] $Snapshot
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object] $ComputerSystem
        [Object[]] $Processor
        [Object[]] $Disk
        [Object[]] $Network
        [Object]  $LogProviders
        Hidden [Object] $Output
        System()
        {
            $This.Snapshot         = [Snapshot]::New()
            $This.BiosInformation  = [BiosInformation]::New()
            $This.OperatingSystem  = [OperatingSystem]::New() 
            $This.ComputerSystem   = [ComputerSystem]::New()
            $This.Processor        = @(Get-WmiObject Win32_Processor | % { [Processor]::New($_,0) })
            $This.Disk             = @(Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed | % { [DiskDrive]::New($_) } | % { [Disk]::New($_) })
            $This.Network          = @(Get-CimInstance Win32_NetworkAdapterConfiguration | ? IPEnabled | ? DefaultIPGateway | % { [Network]::New($_) })
        }
        System([Object]$System)
        {
            $This.Snapshot        = $System.Snapshot
            $This.BiosInformation = $System.BiosInformation
            $This.OperatingSystem = $System.OperatingSystem
            $This.ComputerSystem  = $System.ComputerSystem
            $This.Processor       = $System.Processor
            $This.Disk            = $System.Disk
            $This.Network         = $System.Network
        }
        System([Object]$Snapshot,[Object]$BiosInformation,[Object]$OperatingSystem,[Object]$ComputerSystem,[Object[]]$Processor,[Object[]]$Disk,[Object[]]$Network)
        {
            $This.Snapshot         = $Snapshot
            $This.BiosInformation  = $BiosInformation
            $This.OperatingSystem  = $OperatingSystem
            $This.ComputerSystem   = $ComputerSystem
            $This.Processor        = $Processor
            $This.Disk             = $Disk
            $This.Network          = $Network
        }
        LoadLogProviders([Object]$LogProviders)
        {
            $This.LogProviders     = $LogProviders
        }
        GetLogProviders()
        {
            $This.LogProviders     = [LogProviders]::New()
        }
        [Object[]] GetOutput()
        {
            If ($This.Snapshot.Complete -eq 0)
            {
                $This.Snapshot.Elapsed = [String][Timespan]([DateTime]::Now-[DateTime]$This.Snapshot.Start)
            }
            $This.Output           = $Prop = [PropertyControl]::New()
            $Prop.Add(           "Snapshot", $This.Snapshot)
            $Prop.Add(   "Bios Information", $This.BiosInformation)
            $Prop.Add(   "Operating System", $This.OperatingSystem)
            $Prop.Add(    "Computer System", $This.ComputerSystem)
            
            Switch ($This.Processor.Count)
            {
                1       { $Prop.Add(    "Processor(s)", $This.Processor[0]) }
                Default { $Prop.Add(    "Processor(s)", $This.Processor)    }
            }
            Switch ($This.Disk.Count)
            {
                1       { $Prop.Add(          "Disk(s)", $This.Disk[0]) }
                Default { $Prop.Add(          "Disk(s)", $This.Disk)    }
            }
            Switch ($This.Network.Count)
            {
                1       { $Prop.Add(       "Network(s)", $This.Network[0]) }
                Default { $Prop.Add(       "Network(s)", $This.Network)    }
            }
            
            If ($This.LogProviders)
            {
                $Prop.Add( "Log Providers", $This.LogProviders.Output,0)
            }

            Return $Prop.GetOutput()
        }
    }

    <#
    $System = [System]::New()
    $System.GetLogProviders()
    $System.Snapshot.Start = "04/23/2022 03:45:43"
    Set-Content $Home\Desktop\SystemOutput.txt $System.GetOutput()
    #>

    # Parses the outputfile back into the system object above.
    Class ParseSystem
    {
        [Object] $Snapshot
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object] $ComputerSystem
        [Object[]] $Processor
        [Object[]] $Disk
        [Object[]] $Network
        [Object[]] $LogProviders
        ParseSystem()
        {
            $This.Processor    = @( )
            $This.Disk         = @( )
            $This.Network      = @( )
            $This.LogProviders = @( )
        }
        AddSnapshot([Object]$Snapshot)
        {
            $This.Snapshot = [Snapshot]::New($Snapshot)
        }
        AddBiosInformation([Object]$BiosInformation)
        {
            $This.BiosInformation = [BiosInformation]::New($BiosInformation)
        }   
        AddOperatingSystem([Object]$OperatingSystem)
        {
            $This.OperatingSystem = [OperatingSystem]::New($OperatingSystem)
        }
        AddComputerSystem([Object]$ComputerSystem)
        {
            $This.ComputerSystem = [ComputerSystem]::New($ComputerSystem)
        }
        AddProcessor([Object]$Processor)
        {
            $This.Processor += [Processor]::New($Processor)
        }
        AddProcessor([Processor]$Processor)
        {
            If ($Processor.ID -in $This.Processor.Id)
            {
                Throw "Processor already exists"
            }
            Else
            {
                $This.Processor += $Processor
            }
        }
        AddDisk([Object]$Disk)
        {
            $This.Disk += [Disk]::New($Disk)
        }
        AddNetwork([Object]$Network)
        {
            $This.Network += $Network
        }
        AddLogProviders([Object]$LogProviders)
        {
            $This.LogProviders = $LogProviders
        }
        AddObject([UInt32]$Rank,[Object]$Section)
        {
            Switch ($Rank)
            {
                0 { $This.AddSnapshot($Section)        }
                1 { $This.AddBiosInformation($Section) }
                2 { $This.AddOperatingSystem($Section) }
                3 { $This.AddComputerSystem($Section)  }
                4 { $This.AddProcessor($Section)       }
                5 { $This.AddDisk($Section) }
                6 { $This.AddNetwork($Section) }
                7 { $This.AddLogProviders($Section)  }
            }
        }
    }

    # Parses each section of the outputfile
    # Duplicate class, sometimes I keep the old versions
    Class ParseSection2
    {
        Hidden [UInt32] $Mode
        [UInt32] $Rank
        [Object] $Title
        [Object] $Content
        [Object] $Names
        [Object] $Values
        [Object] $Output
        Hidden [UInt32] $MaxKeyLength 
        ParseSection2([UInt32]$Rank,[Object]$Title,[Object]$Object)
        {
            $This.Mode    = 0
            $This.Rank    = $Rank
            $This.Title   = $Title
            $This.Content = $Object
        }
        ParseSection([UInt32]$Rank,[Object]$Title,[Object[]]$Content)
        {
            $This.Mode    = 1
            $This.Rank    = $Rank
            $This.Title   = $Title
            $This.Content = $Content
        }
        SetBuffer([UInt32]$X)
        {
            $This.Content | % SetBuffer $X
        }
        GetMaxKeyLength()
        {
            $This.MaxKeyLength = ($This.Content.PSObject.Properties.Name | Sort-Object Length | Select-Object -Last 1).Length
        }
        GetOutput()
        {
            $This.Output = @($This.Frame();$This.Title;$This.Frame();"")
        }
        [String] Frame()
        {
            Return "-" * 120 -join ''
        }
    }

    # Parses keys from the outputfile, might not be necessary
    Class ParseKey
    {
        [UInt32] $Index
        [UInt32] $Rank
        Hidden [String] $Line
        Hidden [UInt32] $Length
        [String] $Name
        [String] $Value
        ParseKey([UInt32]$Index,[UInt32]$Rank,[Object]$Groups)
        { 
            $This.Rank      = $Rank
            $This.Line      = $Groups.Groups[0].Value
            $This.Length    = $Groups.Groups[1].Length
            $This.Name      = $Groups.Groups[1].Value
            $This.Value     = $Groups.Groups[2].Value
        }
    }

    # Parses each individual line of the outputfile
    Class ParseLine
    {
        [UInt32] $Index
        [Int32] $Rank
        Hidden [UInt32] $Total
        [Int32] $Type
        Hidden [String] $Slot
        [String] $Line
        ParseLine([UInt32]$Index,[UInt32]$Total,[String]$Line)
        {
            $This.Index = $Index
            $This.Total = $Total
            $This.Line  = $Line.TrimEnd(" ")

            If ($This.Line.Length -eq 0 -or $This.Line -match "\-{20,}")
            {
                $This.Type  = 0
                $This.Slot  = "Format"
                Return
            }

            If ($Line -match "(^Snapshot$|^Bios Information$|^Operating System$|^Computer System$|^Processor\(s\)$|^Disk\(s\)$|^Network$|^Log Providers$)")
            {
                $This.Type  = 1
                $This.Slot  = "Title"
                Return
            }

            If ($Line -match "^(\w+|\d+)+[^\s]$")
            {
                $This.Type  = 2
                $This.Slot  = "Label"
                Return
            }

            If ($Line -match "^(\w+|\d+)+\s+(.+)$")
            {
                $This.Type  = 3
                $This.Slot  = "Key"
                Return
            }
        }
        [String] ToString()
        {
            Return ("[{0:d$($This.Total)}] {1}" -f $This.Index, $This.Line)
        }
    }

    # Parses keys from the log and sends them to system object
    Class ParseSection
    {
        [UInt32] $Rank
        [Object] $Title
        Hidden [Object] $Names
        Hidden [Object] $Values
        [Object] $Output
        ParseSection([UInt32]$Rank,[String]$Title)
        {
            $This.Rank    = $Rank
            $This.Title   = $Title
            $This.Names   = @( )
            $This.Values  = @( )
            $This.Output  = @( )
        }
        AddArray([Object[]]$Content)
        {
            ForEach ($X in 0..($Content.Count-1))
            {
                $Content[$X] -Match "(\w+|\d+)\s+(.+)"
                $This.Names   += $Matches[1]
                $This.Values  += $Matches[2]
                $This.Output  += [DGList]::New($Matches[1],$Matches[2])
            }
        }
        Clear()
        {
            $This.Names  = @( )
            $THis.Values = @( )
            $This.Output = @( )
        }
    }

    # Basically does a lot of math.
    Class ParseTable
    {
        Hidden [String[]]   $Input
        [UInt32]     $Total
        Hidden [Object] $Keys
        Hidden [UInt32] $MaxKeyLength
        [Object]   $Content
        [Object]   $Section
        ParseTable([String]$Path)
        {
            $This.Input   = (Get-Content $Path).TrimEnd(" ")
            $This.Total   = $This.Input.Count
            $This.Keys    = @( )
            $This.Content = @( )
            $This.Section = @( )
            ForEach ($X in 0..($This.Input.Count-1))
            {
                $This.Content +=  $This.Line($This.Input[$X].TrimEnd(" "))
            }
            $This.RankSections()
        }
        [UInt32] X([String]$Match)
        {
            $Escape = [Regex]::Escape($Match)
            Return 0..($This.Content.Line.Count-1) | ? { $This.Content.Line[$_] -match "^$Escape" } 
        }
        RankSections()
        {
            $C = -1
            ForEach ($X in 0..($This.Content.Count-1))
            {
                $Item = $This.Content[$X]
                If ($Item.Line -match "^Snapshot$|^Bios Information$|^Operating System$|^Computer System$|^Processor\(s\)$|^Disk\(s\)$|^Network\(s\)$|^Log Providers$")
                {
                    $C ++
                    $This.Content[$X-1].Rank = $C
                }
                $Item.Rank = $C
            }
        }
        ParseSections()
        {
            $Index                  = $This.Content | % Rank | Select-Object -Unique
            $Body                   = [ParseSystem]::New()
            #$Index                  = $Px.Content | % Rank | Select-Object -Unique 
            $Disk                   = $Null
            $Master                 = $Null
            $Tag                    = $Null
            $xContent               = $Null
            $xLabel                 = $Null
            $Slot                   = $Null
            $Title                  = $Null
            $Label                  = $Null
            $Count                  = $Null
            $Id                     = $Null
            $Rank                   = 0
            ForEach ($Rank in $Index)
            {
                 $Slot              = $This.Content | ? Rank -eq $Rank
               # $Slot               = $Px.Content   | ? Rank -eq $Rank
                $Title              = $Slot | ? Type -eq 1 | % Line
                $Item               = [ParseSection]::New($Rank,$Title)
                Switch -Regex ($Title)
                {
                    "(^Snapshot$|^Bios Information$|^Operating System$|^Computer System$)"
                    {
                        $xContent        = $Slot | ? Type -eq 3 | % Line
                        $Item.AddArray($xContent)
                        $Body.AddObject($Rank,$Item.Output)
                        $Rank          ++
                    }
                    "(^Processor\(s\)$|^Disk\(s\)$|^Network\(s\)|^Log Providers$)"
                    {
                        $First          = $Slot | ? Type -eq 3 | Select-Object -First 1
                        If ($First.Line -match "(\w+|\d+)\s+(\d+)")
                        {
                            $Count      = [UInt32]$Matches[2]
                            $First.Type = 4
                            $Id         = Switch -Regex ([String]$Matches[1])
                            {
                                Processor { "Processor" }
                                Disk      {      "Disk" }
                                Network   {   "Network" }
                                Log       {      "Logs" }
                            }
                        }
                        $Label                = $Slot | ? Type -eq 2 
                        ForEach ($Object in  $Slot | ? Type -eq 2 )
                        {
                            If ($Object.Line -notmatch "(^\w+\d+$)")
                            {
                                $Object.Type  = 3
                            }
                        }
                        $Label                = $Slot | ? Type -eq 2
                        Switch -Regex ($Id)
                        {
                            Default
                            {
                                If ($Label.Count -eq 0)
                                {
                                    $xContent = ($Slot | ? Type -eq 3).Line
                                    $Item.AddArray($xContent)
                                    $Body.AddObject($Rank,$Item.Output)
                                    $Item.Clear()
                                    $Rank ++
                                    Return
                                }
                                If ($Label.Count -eq 1)
                                {
                                    $X            = $Label.Index
                                    $C            = @( )
                                    Do
                                    {
                                        $X        ++
                                        $C        += $Slot | ? Index -eq $X
                                    }
                                    Until ($C[-1].Type -eq 0 -or $X -eq $Slot[-1].Index)
                                    $xContent       = $C[0..($C.Count-2)].Line
                                    $Item.AddArray($xContent)
                                    $Body.AddObject($Rank,$Item.Output)
                                    $Item.Clear()
                                    $Rank ++
                                    Return
                                }
                                If ($Label.Count -gt 1)
                                {
                                    ForEach ($L in 0..($Label.Count-1)) 
                                    {
                                        $X       = $Label[$L].Index
                                        $C       = @( )
                                        Do
                                        {
                                            $X     ++
                                            $C     += $Slot | ? Index -eq $X
                                        }
                                        Until ($C[-1].Type -eq 0 -or $X -eq $Slot[-1].Index)
                                        $xContent       = $C[0..($C.Count-2)].Line
                                        $Item.AddArray($xContent)
                                        $Body.AddObject($Rank,$Item.Output)
                                    }
                                    $Rank         ++
                                    Return
                                }
                            }
                            Disk
                            {
                                ForEach ($L in 0..($Label.Count-1))
                                {
                                    If ($Label[$L].Line -match "Disk\d+")
                                    {
                                        $Master = $Label[$L].Line
                                        $Tag    = [UInt32]($Master -Replace "\D+","")
                                    }
                                    $Z          = 0
                                    $X          = $Label[$L].Index
                                    $C          = @( )
                                    Do
                                    {
                                        $X     ++
                                        $C     += $Slot | ? Index -eq $X
                                        If ($X -eq $Slot[-1].Index)
                                        {
                                            $Z  = 1
                                        }
                                    }
                                    Until ($C[-1].Type -eq 2 -or $Z -eq 1)
                                    $xContent = $C[0..($C.Count-2)].Line
                                    If ($Label[$L].Line -match "Partition")
                                    {
                                        $Key       = [Regex]::Matches($xContent,"^(\w+)+(\s+)+(\w+)+").Groups
                                        $KeyLength = $Key.Groups[1].Length + $Key.Groups[2].Length
                                        $Sub       = $Label[$L].Line.Length
                                        $Space     = " " * $Sub -join ""
                                        ForEach ($X in 0..($xContent.Count-1))
                                        {
                                            $Line  = $xContent[$X]
                                            $Line -match "^(\w+)" | Out-Null
                                            $Key   = $Matches[1] -Replace $Label[$L].Line ,""
                                            $Line -match "^(\w+)+(\s+)+(.+)+" | Out-Null
                                            $xContent[$X] = $Key + $Space + $Matches[2] + $Matches[3]
                                        }
                                        $xContent += "SizeBytes" + (" " * ($KeyLength - 9) -join '') + [Float][Regex]::Matches($xContent,"(\d+\.\d+\w+)").Value*1MB
                                    }
                                    $Item.AddArray($xContent)
                                    Switch -Regex ($Label[$L].Line)
                                    {
                                        $Master
                                        {
                                            $Disk = [Disk]::New($Item.Output,$Tag)
                                        }
                                        Default
                                        {
                                            $Partition = [Partition]::New($Item.Output,$Tag)
                                            $Disk.Partition += $Partition
                                        }
                                    }
                                    If ($Z -eq 1)
                                    {

                                        $Body.AddDisk($Disk)
                                    }
                                    $Item.Clear()
                                }

                                $Rank ++
                                Return
                            }
                        }
                    }
                }
            }
        }
        [Object] Line([String]$Line)
        {
            Return [ParseLine]::New($This.Content.Count,$This.Total,$Line)
        }
    }

    $Result = "$Home\Desktop\SystemOutput.txt"
    $Px     = [ParseTable]::New($Result)
}

Function Get-EventLogArchive
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][ValidateScript({Test-Path $_})][String]$Path,
        [Parameter(Mandatory,ParameterSetName=1)][Switch]$New
    )

    Class EventLogArchive
    {
        [String]     $Mode
        [String] $Modified
        [UInt32]   $Length
        [String]     $Size 
        [String]     $Name
        [String]     $Path
        EventLogArchive([String]$Fullname)
        {
            $File          = Get-Item $Fullname
            $This.Mode     = $File.Mode
            $This.Modified = $File.LastWriteTime.ToString()
            $This.Length   = $File.Length
            $This.Size     = "{0:n2} MB" -f ($File.Length/1MB)
            $This.Name     = $File.Name
            $This.Path     = $File.Fullname
        }
        EventLogArchive()
        {
            $This.Mode     = "-"
            $This.Modified = "-"
            $This.Length   = 0
            $This.Size     = "0.00 MB"
            $This.Name     = "-"
            $This.Path     = "-"
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogArchive]::New($Path) }
        1 { [EventLogArchive]::New()      }
    }

}

# Sample file for the experiment
Class ExperimentFile
{
    [String] $Name
    [String] $Fullname
    [Object] $Content
    ExperimentFile([String]$Base,[String]$Name)
    {
        $This.Name     = $Name
        $This.Fullname = "$Base\$Name"
        If (!(Test-Path $This.Fullname))
        {
            New-Item $This.Fullname -ItemType File
        }
        $This.Content  = @( )
    }
    AddContent([String]$Line)
    {
        $This.Content += $Line
        Add-Content -Path $This.Fullname -Value $Line
    }
}

# Experiment container
Class Experiment
{
    Hidden [Object] $Timer
    [String]         $Time
    [DateTime]      $Start
    [Object]       $System
    [String]  $DisplayName
    [UInt32]      $Threads
    [String]         $Guid
    [String]         $Path
    [Object]        $Files
    [Object]       $Object
    [Object]         $Logs
    [Object]       $Output
    Experiment()
    {
        # Start timer, count threads / max runspace pool size
        $This.Timer       = [System.Diagnostics.Stopwatch]::StartNew()

        # Set initial date/time
        $This.Start       = [DateTime]::Now
        $This.System      = Get-SystemDetails
        $This.DisplayName = "{0}-{1}" -f $This.Start.ToString("yyyy-MMdd-HHMMss"), $This.System.Name

        # Check thread count
        $This.Threads     = $This.System.Processor.Threads | Measure-Object -Sum | % Sum
        If ($This.Threads -lt 2)
        {
            Throw "CPU only has (1) thread"
        }

        # Use a GUID to create a new folder for the threads
        $This.Guid        = [GUID]::newGuid().GUID.ToUpper()
        $This.Path        = "{0}\{1}" -f [Environment]::GetEnvironmentVariable("temp"), $This.Guid

        # Test path and create (it shouldn't exist)
        If (!(Test-Path $This.Path))
        {
            New-Item $This.Path -ItemType Directory -Verbose

            # Create a subfolder for each stage
            ForEach ($Item in "Master","Logs","Events")
            {
                New-Item "$($This.Path)\$Item" -ItemType Directory -Verbose
            }
        }

        # Create an individual file for each thread, to evenly distribute the workload among the max threads 
        $This.Files      = 0..($This.Threads-1) | % { [ExperimentFile]::New($This.Path,"$_.txt") }
        $This.Object     = @( )
        $This.Logs       = @( )
        $This.Output     = @( )
    }
    Load([Object[]]$Object)
    {
        # Loads the provider names, but may be reusable
        ForEach ($X in 0..($Object.Count-1))
        {
            $File             = $This.Files[$X%$This.Threads]
            $Name             = $Object[$X]
            $Value            = "$X,$Name"
            $File.AddContent($Value)
            $This.Object     += $Name
        }
    }
    Delete()
    {
        $This.Path        | Remove-Item -Recurse -Verbose
        $This.Start       = [DateTime]::FromOADate(1)
        $This.System      = $Null
        $This.DisplayName = $Null
        $This.Timer       = $Null
        $This.Threads     = $Null
        $This.Guid        = $Null
        $This.Path        = $Null
        $This.Files       = $Null
        $This.Object      = $Null
        $This.Logs        = $Null
        $This.Output      = $Null
    }
    Master()
    {
        $Value  = @( )
        $Value += "[Start]: $($This.Start)"
        $Value += "[DisplayName]: $($This.DisplayName)"
        $Value += "[Guid]: $($This.Guid)"
        $Depth  = ([String]$This.Object.Count).Length
        ForEach ($X in 0..($This.Object.Count-1))
        {
            $Value += ("[Provider {0:d$Depth}]: {1}" -f $X, $This.Object[$X])
        }
        $SystemInfo = $This.System.ToString()
        ForEach ($X in 0..($SystemInfo.Count-1))
        {
            $Value += $SystemInfo[$X]
        }
        Set-Content "$($This.Path)\Master\Master.txt" -Value $Value -Force
    }
}

# Thread object for runspace invocation 
Class ThreadObject
{
    [UInt32] $Id 
    Hidden [Object] $Timer
    Hidden [Object] $PowerShell
    Hidden [Object] $Handle
    [String] $Time
    [UInt32] $Complete
    Hidden [Object] $Data
    ThreadObject([UInt32]$Id,[Object]$PowerShell)
    {
        $This.Id             = $Id
        $This.Timer          = [System.Diagnostics.Stopwatch]::StartNew()
        $This.PowerShell     = $PowerShell
        $This.Handle         = $PowerShell.BeginInvoke()
        $This.Time           = $This.Timer.Elapsed.ToString()
        $This.Complete       = 0
        $This.Data           = $Null
    }
    IsComplete()
    {
        If ($This.Handle.IsCompleted)
        {
            $This.Complete   = 1
            $This.Data       = $This.PowerShell.EndInvoke($This.Handle)
            $This.Timer.Stop()
            $This.PowerShell.Dispose()
        }
        $This.Time           = $This.Timer.Elapsed.ToString() 
    }
}

# Thread collection object to track and chart progress of all thread objects
Class ThreadCollection
{
    Hidden [Object] $Timer
    [String] $Time
    [UInt32] $Complete
    [UInt32] $Total
    [Object] $Threads
    ThreadCollection()
    {
        $This.Timer    = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Time     = $This.Timer.Elapsed.ToString()
        $This.Threads  = @( )
    }
    [Bool] Query()
    {
        Return @( $False -in $This.Threads.Handle.IsCompleted )
    }
    AddThread([UInt32]$Index,[Object]$PowerShell)
    {
        $This.Threads += [ThreadObject]::New($_,$PowerShell)
        $This.Total    = $This.Threads.Count
    }
    IsComplete()
    {
        $This.Threads.IsComplete()
        $This.Complete = ($This.Threads | ? Complete -eq $True ).Count

        If ($This.Complete -eq $This.Total)
        {
            $This.Timer.Stop()
        }
        $This.Time     = $This.Timer.Elapsed.ToString()
        $This.ToString()
    }
    [String] ToString()
    {
        Return ( "Elapsed: [{0}], Completed ({1}/{2})" -f $This.Timer.Elapsed, $This.Complete, $This.Total )
    }
}

# All of these versions do the same thing. I wrote it several ways to show how they all achieve the same end result.
# Version 1
# $Objects    = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
# $Ctrl       = [Experiment]::New()
# $Ctrl.Load($Objects)                                                                        # Reset the lab -> # $Ctrl.Remove() 

# Version 2
# $Ctrl       = [Experiment]::New()
# $Ctrl.Load((Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object))     # Reset the lab -> # $Ctrl.Remove()

# Version 3
# $Ctrl       = New-Object Experiment
# $Ctrl | % Load (Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object)  # Reset the lab -> # $Ctrl.Remove()

# Version 4
$Ctrl  = New-Object Experiment
$Names = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
$Ctrl.Load($Names)
$Ctrl.Master()

# -------------------------------------
# Output of the custom experiment class
# -------------------------------------
# PS C:\Users\admin> $Ctrl
# 
# Time         : 00:08:06.8751525
# Start        : 4/20/2022 06:48:05 AM
# System       : Get-SystemDetails
# DisplayName  : 2022_0420-064805-coolstorybro-x64
# Threads      : 8
# Guid         : E43750A8-FB88-434F-8418-99D7E6171DB6
# Path         : C:\Users\admin\AppData\Local\Temp\E43750A8-FB88-434F-8418-99D7E6171DB6
# Files        : {0.txt, 1.txt, 2.txt, 3.txt...}
# Object       : {Application, ForwardedEvents, HardwareEvents, Internet Explorer...}
# ----------------------------------------------------------------------------------------------

# Declare functions to memory, for each runspace to have access to
Function Get-EventLogConfigExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][UInt32]$Rank,
        [Parameter(Mandatory,ParameterSetName=0)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Config)

    Class EventLogConfigExtension
    {
        [UInt32] $Rank
        [String] $LogName
        [Object] $LogType
        [Object] $LogIsolation
        [Boolean] $IsEnabled
        [Boolean] $IsClassicLog
        Hidden [String] $SecurityDescriptor
        [String] $LogFilePath
        Hidden [Int64] $MaximumSizeInBytes
        [Object] $Maximum
        [Object] $Current
        [Object] $LogMode
        Hidden [String] $OwningProviderName
        [Object] $ProviderNames
        Hidden [Object] $ProviderLevel
        Hidden [Object] $ProviderKeywords
        Hidden [Object] $ProviderBufferSize
        Hidden [Object] $ProviderMinimumNumberOfBuffers
        Hidden [Object] $ProviderMaximumNumberOfBuffers
        Hidden [Object] $ProviderLatency
        Hidden [Object] $ProviderControlGuid
        Hidden [Object[]] $EventLogRecord
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Name)
        {
            $This.Rank                           = $Rank
            $Event                               = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($Name)
            $This.LogName                        = $Event.LogName 
            $This.LogType                        = $Event.LogType 
            $This.LogIsolation                   = $Event.LogIsolation 
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = "{0:n2} MB" -f ($Event.MaximumSizeInBytes/1MB) 
            $This.Current                        = If (!(Test-Path $This.LogFilePath)) { "0.00 MB" } Else { "{0:n2} MB" -f (Get-Item $This.LogFilePath | % { $_.Length/1MB }) }
            $This.LogMode                        = $Event.LogMode
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        EventLogConfigExtension([Object]$Event)
        {
            $This.Rank                           = $Event.Rank
            $This.Logname                        = $Event.LogName
            $This.LogType                        = $This.GetLogType($Event.LogType)
            $This.LogIsolation                   = $This.GetLogIsolation($Event.LogIsolation)
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath 
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = $Event.Maximum
            $This.Current                        = $Event.Current
            $This.LogMode                        = $This.GetLogMode($Event.LogMode)
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        GetEventLogRecord()
        {
            $This.Output = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
            $This.Total  = $This.Output.Count
            $Depth       = ([String]$This.Total.Count).Length
            If ($This.Total -gt 0)
            {
                $C = 0
                ForEach ($Record in $This.Output)
                {
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    Index -Value $Null
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Rank -Value $C 
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    LogId -Value $This.Rank
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name DateTime -Value $Record.TimeCreated
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Date -Value $Record.TimeCreated.ToString("yyyy-MMdd-HHMMss")
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Name -Value ("$($Record.Date)-$($This.Rank)-{0:d$Depth}" -f $C)
                    $C ++
                }
            }
        }
        [Object] GetLogType([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogType]::Administrative }
                1 { [System.Diagnostics.Eventing.Reader.EventLogType]::Operational }
                2 { [System.Diagnostics.Eventing.Reader.EventLogType]::Analytical }
                3 { [System.Diagnostics.Eventing.Reader.EventLogType]::Debug }  
            }
            Return $Return
        }
        [Object] GetLogIsolation([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Application }
                1 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::System }
                2 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Custom }
            }
            Return $Return
        }
        [Object] GetLogMode([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular   }
                1 { [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup }
                2 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain     }
            }
            Return $Return
        }
        [Object] Config()
        {
            Return $This | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,MaximumSizeInBytes,Maximum,Current,LogMode,
            OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,
            ProviderControlGuid
        }
    }
    
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogConfigExtension]::New($Rank,$Name) }
        1 { [EventLogConfigExtension]::New($Config)     }
    }
}

# This function is used to export the event logs from the system
Function Get-EventLogRecordExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][Object]$Record,
        [Parameter(Mandatory,ParameterSetName=1)][UInt32]$Index,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Entry)

    Class EventLogRecordExtension
    {
        [UInt32]   $Index
        Hidden [String] $Name
        Hidden [Object] $DateTime
        [String]   $Date
        [String]   $Log
        [UInt32]   $Rank
        [String]   $Provider
        [UInt32]   $Id
        [String]   $Type
        [String]   $Message
        Hidden [String[]] $Content
        Hidden [Object] $Version
        Hidden [Object] $Qualifiers
        Hidden [Object] $Level
        Hidden [Object] $Task
        Hidden [Object] $Opcode
        Hidden [Object] $Keywords
        Hidden [Object] $RecordId
        Hidden [Object] $ProviderId
        Hidden [Object] $LogName
        Hidden [Object] $ProcessId
        Hidden [Object] $ThreadId
        Hidden [Object] $MachineName
        Hidden [Object] $UserID
        Hidden [Object] $ActivityID
        Hidden [Object] $RelatedActivityID
        Hidden [Object] $ContainerLog
        Hidden [Object] $MatchedQueryIds
        Hidden [Object] $Bookmark
        Hidden [Object] $OpcodeDisplayName
        Hidden [Object] $TaskDisplayName
        Hidden [Object] $KeywordsDisplayNames
        Hidden [Object] $Properties
        EventLogRecordExtension([Object]$Record)
        {
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.ProviderName
            $This.DateTime    = $Record.TimeCreated
            $This.Date        = $Record.Date
            $This.Log         = $Record.LogId
            $This.Id          = $Record.Id
            $This.Type        = $Record.LevelDisplayName
            $This.InsertEvent($Record)
        }
        EventLogRecordExtension([UInt32]$Index,[Object]$Entry)
        {
            $Stream           = $Entry.Open()
            $Reader           = [System.IO.StreamReader]::New($Stream)
            $RecordEntry      = $Reader.ReadToEnd() 
            $Record           = $RecordEntry | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.DateTime    = [DateTime]$Record.DateTime
            $This.Date        = $Record.Date
            $This.Log         = $Record.Log
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.Provider
            $This.Id          = $Record.Id
            $This.Type        = $Record.Type
            $This.InsertEvent($Record)
        }
        InsertEvent([Object]$Record)
        {
            $FullMessage   = $Record.Message -Split "`n"
            Switch ($FullMessage.Count)
            {
                {$_ -gt 1}
                {
                    $This.Message  = $FullMessage[0] -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 1}
                {
                    $This.Message  = $FullMessage -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 0}
                {
                    $This.Message  = "-"
                    $This.Content  = "-"
                }
            }
            $This.Version              = $Record.Version
            $This.Qualifiers           = $Record.Qualifiers
            $This.Level                = $Record.Level
            $This.Task                 = $Record.Task
            $This.Opcode               = $Record.Opcode
            $This.Keywords             = $Record.Keywords
            $This.RecordId             = $Record.RecordId
            $This.ProviderId           = $Record.ProviderId
            $This.LogName              = $Record.LogName
            $This.ProcessId            = $Record.ProcessId
            $This.ThreadId             = $Record.ThreadId
            $This.MachineName          = $Record.MachineName
            $This.UserID               = $Record.UserId
            $This.ActivityID           = $Record.ActivityId
            $This.RelatedActivityID    = $Record.RelatedActivityID
            $This.ContainerLog         = $Record.ContainerLog
            $This.MatchedQueryIds      = @($Record.MatchedQueryIds)
            $This.Bookmark             = $Record.Bookmark
            $This.OpcodeDisplayName    = $Record.OpcodeDisplayName
            $This.TaskDisplayName      = $Record.TaskDisplayName
            $This.KeywordsDisplayNames = @($Record.KeywordsDisplayNames)
            $This.Properties           = @($Record.Properties.Value)
        }
        [Object] Export()
        {
            Return @( $This | ConvertTo-Json )
        }
        [Object] Config()
        {
            Return $This | Select-Object Index,Name,DateTime,Date,Log,Rank,Provider,Id,Type,Message,Content,
            Version,Qualifiers,Level,Task,Opcode,Keywords,RecordId,ProviderId,LogName,ProcessId,ThreadId,MachineName,
            UserID,ActivityID,RelatedActivityID,ContainerLog,MatchedQueryIds,Bookmark,OpcodeDisplayName,TaskDisplayName,
            KeywordsDisplayNames,Properties
        }
        [Void] SetContent([String]$Path)
        {
            [System.IO.File]::WriteAllLines($Path,$This.Export())
        }
        [Object] ToString()
        {
            Return @( $This.Export() | ConvertFrom-Json )
        }
    }
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogRecordExtension]::New($Record) }
        1 { [EventLogRecordExtension]::New(0,$Entry) }
    }
}

# Create initial session state object, function above is immediately available to any thread in the runspace pool
$Session         = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
ForEach ($Item in "Get-EventLogConfigExtension","Get-EventLogRecordExtension")
{
    $Content     = Get-Content "Function:\$Item" -ErrorAction Stop
    $Object      = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Item,$Content)
    $Session.Commands.Add($Object) 
}

# Open the runspacepool
$RunspacePool    = [RunspaceFactory]::CreateRunspacePool(1,$Ctrl.Threads,$Session,$Host)
$RunspacePool.Open()

# Declare the scriptblock each runspace will run independently
$ScriptBlock     = {
    Param ($Fullname)
    $List        = Get-Content $Fullname
    $Return      = @( )
    ForEach ($X in 0..($List.Count-1))
    {
        $Rank    = $List[$X].Split(",")[0]
        $Name    = $List[$X].Split(",")[1]
        $Item    = Get-EventLogConfigExtension -Rank $Rank -Name $Name
        $Item.GetEventLogRecord()
        $Return += $Item
    }
    Return $Return 
}

# Declare the thread collection object
$List1            = New-Object ThreadCollection

# Initialize the threads, add the scriptblock, insert an argument for filepath
0..($Ctrl.Threads-1) | % {

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($scriptblock).AddArgument($Ctrl.Files[$_].Fullname) | Out-Null
    $PowerShell.RunspacePool = $RunspacePool

    $List1.AddThread($_,$PowerShell)
}

# Code to run while waiting for threads to finish
While ($List1.Query())
{
    $List1.Threads | Format-Table
    Write-Host $List1
    Start-Sleep 5
    Clear-Host
    $List1.IsComplete()
}
Write-Host $List1
$List1.IsComplete()

# (Sort -> Write) log config file
Write-Host "Sorting [~] Logs: (Index/Rank), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Ctrl.Logs      = $List1.Threads.Data | Sort-Object Rank
Set-Content "$($Ctrl.Path)\Logs\Logs.txt" -Value ($Ctrl.Logs.Config() | ConvertTo-Json)

# Now we have all of the log entries on the system 1) ranked, and also 2) sorted by TimeCreated
Write-Host "Sorting (Events by TimeCreated) [~] (Logs/Output), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Ctrl.Output   = $Ctrl.Logs.Output | Sort-Object TimeCreated
$RunspacePool.Dispose()

# Almost time to index the files...
Write-Host "Indexing [~] (Output), Elapsed: [$($Ctrl.Timer.Elapsed)]"
$Count          = $Ctrl.Output.Count
$Depth          = ([String]$Count).Length

# Set up hashtable for threads and $T variable for threads (an error kept occurring) 
$Load           = @{ }
$T              = [Environment]::GetEnvironmentVariable("Number_of_processors")

# Autocalc the # of hashtables respective to cores available
ForEach ($X in 0..($T-1))
{
    $Load.Add($X,[Hashtable]@{ })
}

# Now perform indexing as well as dividing the workload to separate hashtables
ForEach ($X in 0..($Ctrl.Output.Count-1))
{
    $Item       = $Ctrl.Output[$X]
    $Item.Index = $X
    $Item.Name  = "{0:d$Depth}-{1}" -f $X, $Item.Name

    # The index ($X % $T) switches the corresponding hashtable per iteration
    $Load[$X%$T].Add($Load[$X%$T].Count,$Ctrl.Output[$X])
}

# Open the runspacepool
$RunspacePool    = [RunspaceFactory]::CreateRunspacePool(1,$Ctrl.Threads,$Session,$Host)
$RunspacePool.Open()

# Scriptblock instructs each thread to get the event log record extension, then sets the content
$ScriptBlock     = {

    Param ($Target,$Load,$Threads,$Step)
    ForEach ($X in 0..($Load.Count-1))
    {
        $Item = Get-EventLogRecordExtension -Record $Load[$X]
        $Item.SetContent("$Target\$($Item.Name).log")
    }
}

# Declare new thread collection object
$List2            = New-Object ThreadCollection

# Initialize the threads, add the scriptblock, insert an argument for filepath
0..($Ctrl.Threads-1) | % {

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($scriptblock).AddArgument("$($Ctrl.Path)\Events").AddArgument($Load[$_]).AddArgument($Ctrl.Threads).AddArgument($_) | Out-Null
    $PowerShell.RunspacePool = $RunspacePool

    $List2.AddThread($_,$PowerShell)
}

# Code to run while waiting for threads to finish
While ($List2.Query())
{
    $List2.Threads | Format-Table
    Write-Host $List2
    Start-Sleep 5
    Clear-Host
    $List2.IsComplete()
}
Write-Host $List2
$List2.IsComplete()

# Dispose the runspace
$RunspacePool.Dispose()

# Get ready to archive the files
Add-Type -Assembly System.IO.Compression.Filesystem

$Phase       = [System.Diagnostics.Stopwatch]::StartNew()
$Destination = "$($Ctrl.Path)\$($Ctrl.DisplayName).zip"
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Create").Dispose()
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Update")

# Inject master file
$MasterPath  = "$($Ctrl.Path)\Master\Master.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$MasterPath,"Master.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Inject logs file
$LogPath     = "$($Ctrl.Path)\Logs\Logs.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$LogPath,"Logs.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Prepare event files
$EventPath   = "$($Ctrl.Path)\Events"
$EventFiles  = Get-ChildItem $EventPath

# Create progress loop
$Complete   = @( )
$Count      = $EventFiles.Count
ForEach ($X in 0..($EventFiles.Count-1))
{
    $File    = $EventFiles[$X]
    $Percent = [Math]::Round($X*100/$Count)
    If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
    {
        $Complete += $Percent
        If ($Percent -ne 0)
        {
            $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
        }
        
        Write-Host "Exporting ($Percent.00%) [~] Elapsed: [$($Phase.Elapsed)], Remain: [$Remain]"
    }
    # Inject event files
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$File.Fullname,$File.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
}

# Archive creation just about complete
Write-Host "Saving (100.00%) [~] Elapsed: $($Phase.Elapsed), (Please wait, the program is writing the file to disk)"
$Zip.Dispose()

# Get the zip file information
$Zip = Get-Item $Destination
Switch (!!$Zip)
{
    $True
    {
        Write-Host ("Saved (100.00%) [+] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], Size: [$("{0:n3}MB" -f ($Zip.Length/1MB))]")
    }
    $False
    {
        Write-Host ("Failed (100.00%) [!] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], the file does not exist.")
    }
}

# At this point, deleting the makeshift directories/files might be a good idea outside of development


# This is specifically for restoring an archive of another machine, or the current machine.
Class RestoreArchive
{
    [Object] $Time
    [Object] $Start
    [Object] $System
    [Object] $DisplayName
    [UInt32] $Threads
    [String] $Guid
    [String] $Path
    [Object] $Files
    [Object] $Object
    [Object] $Logs
    [Object] $Output
    Hidden [Object] $Zip
    RestoreArchive([String]$ZipPath)
    {
        # Restore the zip file
        If (!(Test-Path $ZipPath) -or $ZipPath.Split(".")[-1] -notmatch "zip")
        {
            Throw "Invalid Path"
        }

        $This.Time         = [System.Diagnostics.Stopwatch]::StartNew()

        # Get zip content, pull master file
        $This.Zip          = [System.IO.Compression.Zipfile]::Open($ZipPath,"Read")
        $This.Path         = $ZipPath | Split-Path -Parent

        # Extract Master file
        $MasterEntry       = $This.Zip.GetEntry("Master.txt")
        $MasterPath        = "$($This.Path)\Master.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($MasterEntry,$MasterPath,$True)
        $MasterFile        = Get-Content $MasterPath

        # Extract Logs file
        $LogEntry          = $This.Zip.GetEntry("Logs.txt")
        $LogPath           = "$($This.Path)\Logs.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($LogEntry,$LogPath,$True)
        $LogFile           = Get-Content $LogPath | ConvertFrom-Json

        # Parse Master.txt
        $This.Start        = $MasterFile[0].Substring(9)
        $This.DisplayName  = $MasterFile[1].Substring(15)
        $Lines             = @( )
        ForEach ($X in 0..($MasterFile.Count-1))
        {
            $Line = [Regex]::Matches($MasterFile[$X],"\[Provider \d+\].+").Value
            If (!!$Line)
            { 
                $Lines    += $Line.Substring(16)
            }
        }
        $This.Object       = $Lines
        $This.System       = $MasterFile[($Lines.Count + 2)..($MasterFile.Count-1)]
        $This.Threads      = ($This.System | ? { $_ -match "Threads" }).Substring(18)

        # Parse Logs.txt
        $This.Logs         = @( )
        $Stash             = @{ }
        ForEach ($X in 0..($LogFile.Count-1))
        {
            $Item          = $LogFile[$X]
            $This.Logs    += Get-EventLogConfigExtension -Config $Item
            $Stash.Add($Item.LogName,@{ })
        }

        $Hash              = @{ }
        $Remain            = $Null

        # Collect Files
        $FileEntry            = $This.Zip.Entries | ? Name -notmatch "(Master|Logs).txt"

        # Create progress loop
        $Complete             = @( )
        $Phase                = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Importing (0.00%) [~] Files: ($($FileEntry.Count)) found."
        ForEach ($X in 0..($FileEntry.Count-1))
        {
            $Item             = Get-EventLogRecordExtension -Index $X -Entry $FileEntry[$X]
            $Hash.Add($X,$Item)

            $Stash[$Item.LogName].Add($Stash[$Item.LogName].Count,$X)
            
            $Percent          = [Math]::Round($X*100/$FileEntry.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain= ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Importing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        $Phase.Stop()
        Write-Host "Imported (100.00%) [+] Files: ($($FileEntry.Count)) found."
        $This.Output      = $Hash[0..($Hash.Count-1)]

        # Sort the logs
        $Complete          = @( )
        $Phase.Reset()
        Write-Host "Sorting (0.00%) [~] Logs: ($($This.Logs.Count)) found."
        ForEach ($X in 0..($This.Logs.Count-1))
        {
            $Name = $This.Logs[$X].LogName
            Switch ($Stash[$Name].Count)
            {
                0 
                {  
                    $This.Logs[$X].Output = @( )
                }
                1 
                {  
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0]])
                }
                Default
                { 
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0..($Stash[$Name].Count-1)]])
                }
            }
            $This.Logs[$X].Total          = $This.Logs[$X].Output.Count

            $Percent                      = [Math]::Round($X*100/$This.Logs.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        Write-Host "Sorted (100.00%) [+] Logs: ($($This.Logs.Count)) found."
        $This.Time.Stop()
    }
}
