<#
.SYNOPSIS
        Allows for getting/viewing, exporting, or importing event viewer logs for a current
        or target Windows system.
.DESCRIPTION
        After many years of wondering how I could extract everything from *every* event log,
        this seems to do the trick. The utility takes a fair amount of time, but- it will
        collect every record in the event logs, as well as provide a way to export the files
        to an archive which can be loaded in far less time than it takes to build it.
        
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
          Modified: 2022-04-08
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression.Filesystem, PresentationFramework

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
    Hidden [Object]        $XAML
    Hidden [Object]         $XML
    [String[]]            $Names
    [Object[]]            $Types
    [Object]               $Node
    [Object]                 $IO
    [Object]         $Dispatcher
    [Object]          $Exception
    [String[]] FindNames()
    {
        Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 
            ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 
        } | Select-Object -Unique ) 
    }
    XamlWindow([String]$XAML)
    {           
        If (!$Xaml)
        {
            Throw "Invalid XAML Input"
        }
        [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        $This.Xaml               = $Xaml
        $This.XML                = [XML]$Xaml
        $This.Names              = $This.FindNames()
        $This.Types              = @( )
        $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
        $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)
        $This.Dispatcher         = $This.IO.Dispatcher
        ForEach ($I in 0..($This.Names.Count - 1))
        {
            $Name                = $This.Names[$I]
            $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
            If ($This.IO.$Name)
            {
                $This.Types    += [DGList]::New($Name,$This.IO.$Name.GetType().Name)
            }
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
            $This.Exception     = $PSItem
        }
    }
}

# Get-Content $Home\Desktop\EventLogs.xaml | % { "        '$_'," } | Set-Clipboard
Class EventLogsGUI
{
    Static [String] $Tab = @(        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Event Log Utility" Width="800" Height="650" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
    '                    <RowDefinition Height="40"/>',
    '                    <RowDefinition Height="*"/>',
    '                </Grid.RowDefinitions>',
    '                <Grid Grid.Row="0">',
    '                    <Grid.ColumnDefinitions>',
    '                        <ColumnDefinition Width="100"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="100"/>',
    '                    </Grid.ColumnDefinitions>',
    '                    <Label Grid.Column="0" Content="[Selection]:"/>',
    '                    <ComboBox Grid.Column="1" Name="ModeSelect" SelectedIndex="0">',
    '                        <ComboBoxItem Content="(Get/View) event logs on this system"/>',
    '                        <ComboBoxItem Content="Export event logs on this system, to a file"/>',
    '                        <ComboBoxItem Content="Import event logs from a file"/>',
    '                    </ComboBox>',
    '                    <Button Grid.Column="2" Content="Continue" Name="Continue"/>',
    '                </Grid>',
    '                <Grid Grid.Row="1">',
    '                    <Grid.ColumnDefinitions>',
    '                        <ColumnDefinition Width="100"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="100"/>',
    '                    </Grid.ColumnDefinitions>',
    '                    <Label Grid.Column="0" Content="[File Path]:"/>',
    '                    <TextBox Grid.Column="1" Name="FilePath"/>',
    '                    <Button Grid.Column="2"  Name="FilePathBrowse" Content="Browse"/>',
    '                </Grid>',
    '                <TabControl Grid.Row="2" Name="TabControl">',
    '                    <TabItem Header="Main">',
    '                        <Grid>',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="300"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Time]:"/>',
    '                                <TextBox Grid.Column="1" Name="Time"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="300"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Start]:"/>',
    '                                <TextBox Grid.Column="1" Name="Start"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="300"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Title]:"/>',
    '                                <TextBox Grid.Column="1" Name="Title"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="3">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Destination]:"/>',
    '                                <TextBox Grid.Column="1" Name="Destination"/>',
    '                                <Button Grid.Column="2" Content="Export" Name="Export" IsEnabled="False"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="4">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="380"/>',
    '                                    <ColumnDefinition Width="80"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Providers]:"/>',
    '                                <ComboBox Grid.Column="1" Name="Providers"/>',
    '                                <Label Grid.Column="2" Content="[Count]:"/>',
    '                                <TextBox Grid.Column="3" Name="ProviderCount"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </TabItem>',
    '                    <TabItem Header="Logs">',
    '                        <Grid Name="LogPanel">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="110"/>',
    '                                    <ColumnDefinition Width="150"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Log Main]:"/>',
    '                                <ComboBox Grid.Column="1" Name="LogMainProperty" SelectedIndex="1">',
    '                                    <ComboBoxItem Content="Rank"/>',
    '                                    <ComboBoxItem Content="Name"/>',
    '                                    <ComboBoxItem Content="Type"/>',
    '                                    <ComboBoxItem Content="Path"/>',
    '                                </ComboBox>',
    '                                <TextBox Grid.Column="2" Name="LogMainFilter"/>',
    '                                <Button Grid.Column="3" Name="LogMainRefresh" Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1" Name="LogMainResult">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Rank"       Binding="{Binding Rank}"         Width="40"/>',
    '                                    <DataGridTextColumn Header="Name"       Binding="{Binding LogName}"      Width="425"/>',
    '                                    <DataGridTextColumn Header="Total"      Binding="{Binding Total}"        Width="100"/>',
    '                                    <DataGridTextColumn Header="Type"       Binding="{Binding LogType}"      Width="100"/>',
    '                                    <DataGridTextColumn Header="Isolation"  Binding="{Binding LogIsolation}" Width="100"/>',
    '                                    <DataGridTextColumn Header="Enabled"    Binding="{Binding IsEnabled}"    Width="50"/>',
    '                                    <DataGridTextColumn Header="Classic"    Binding="{Binding IsClassicLog}" Width="50"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                            <Grid Grid.Row="2">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="110"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="110"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Log Selected]:"/>',
    '                                <TextBox Grid.Column="1" Name="LogSelected"/>',
    '                                <Label Grid.Column="2" Content="[Log Total]:"/>',
    '                                <TextBox Grid.Column="3" Name="LogTotal"/>',
    '                            </Grid>',
    '                            <Grid Grid.Row="3">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="110"/>',
    '                                    <ColumnDefinition Width="150"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Log Output]:"/>',
    '                                <ComboBox Grid.Column="1" Name="LogOutputProperty" SelectedIndex="1">',
    '                                    <ComboBoxItem Content="Index"/>',
    '                                    <ComboBoxItem Content="Date"/>',
    '                                    <ComboBoxItem Content="Log"/>',
    '                                    <ComboBoxItem Content="Rank"/>',
    '                                    <ComboBoxItem Content="Provider"/>',
    '                                    <ComboBoxItem Content="Id"/>',
    '                                    <ComboBoxItem Content="Type"/>',
    '                                    <ComboBoxItem Content="Message"/>',
    '                                    <ComboBoxItem Content="Content"/>',
    '                                </ComboBox>',
    '                                <TextBox Grid.Column="2" Name="LogOutputFilter"/>',
    '                                <Button Grid.Column="3" Name="LogOutputRefresh" Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="4" Name="LogOutputResult">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                                    <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                                    <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                                    <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="200"/>',
    '                                    <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                                    <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                                    <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                    </TabItem>',
    '                    <TabItem Header="Output">',
    '                        <Grid Name="OutputPanel">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="40"/>',
    '                                <RowDefinition Height="*"/>',
    '                            </Grid.RowDefinitions>',
    '                            <Grid Grid.Row="0">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="110"/>',
    '                                    <ColumnDefinition Width="150"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="100"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Label Grid.Column="0" Content="[Output]:"/>',
    '                                <ComboBox Grid.Column="1" Name="OutputProperty" SelectedIndex="0">',
    '                                    <ComboBoxItem Content="Index"/>',
    '                                    <ComboBoxItem Content="Date"/>',
    '                                    <ComboBoxItem Content="Log"/>',
    '                                    <ComboBoxItem Content="Rank"/>',
    '                                    <ComboBoxItem Content="Provider"/>',
    '                                    <ComboBoxItem Content="Id"/>',
    '                                    <ComboBoxItem Content="Type"/>',
    '                                    <ComboBoxItem Content="Message"/>',
    '                                </ComboBox>',
    '                                <TextBox Grid.Column="2" Name="OutputFilter"/>',
    '                                <Button Grid.Column="3" Name="OutputRefresh" Content="Refresh"/>',
    '                            </Grid>',
    '                            <DataGrid Grid.Row="1" Name="OutputResult">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                                    <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                                    <DataGridTextColumn Header="Log"      Binding="{Binding Log}"      Width="50"/>',
    '                                    <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                                    <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="200"/>',
    '                                    <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                                    <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                                    <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                        </Grid>',
    '                    </TabItem>',
    '                    <TabItem Header="Viewer">',
    '                        <Grid Name="ViewerPanel">',
    '                            <Grid.RowDefinitions>',
    '                                <RowDefinition Height="*"/>',
    '                                <RowDefinition Height="40"/>',
    '                            </Grid.RowDefinitions>',
    '                            <DataGrid Grid.Row="0" Name="ViewerResult">',
    '                                <DataGrid.Columns>',
    '                                    <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="200"/>',
    '                                    <DataGridTextColumn Header="Value"    Binding="{Binding Value}"    Width="*">',
    '                                        <DataGridTextColumn.ElementStyle>',
    '                                            <Style TargetType="TextBlock">',
    '                                                <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                            </Style>',
    '                                        </DataGridTextColumn.ElementStyle>',
    '                                        <DataGridTextColumn.EditingElementStyle>',
    '                                            <Style TargetType="TextBox">',
    '                                                <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                                <Setter Property="AcceptsReturn" Value="True"/>',
    '                                            </Style>',
    '                                        </DataGridTextColumn.EditingElementStyle>',
    '                                    </DataGridTextColumn>',
    '                                </DataGrid.Columns>',
    '                            </DataGrid>',
    '                            <Grid Grid.Row="1">',
    '                                <Grid.ColumnDefinitions>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                    <ColumnDefinition Width="*"/>',
    '                                </Grid.ColumnDefinitions>',
    '                                <Button Grid.Column="0" Name="ViewerCopy"  Content="Copy to clipboard"/>',
    '                                <Button Grid.Column="2" Name="ViewerClear" Content="Clear"/>',
    '                            </Grid>',
    '                        </Grid>',
    '                    </TabItem>',
    '                </TabControl>',
    '            </Grid>',
    '        </GroupBox>',
    '    </Grid>',
    '</Window>' -join "`n")
}

Class EventLogRec
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
    EventLogRec([Object]$Event)
    {
        $This.Index       = $Event.Index
        $This.Name        = $Event.Name
        $This.Rank        = $Event.Rank
        $This.Provider    = $Event.ProviderName
        $This.DateTime    = $Event.TimeCreated
        $This.Date        = $Event.TimeCreated.ToString("yyyy_MMdd-HHmmss")
        $This.Log         = $Event.LogId
        $This.Id          = $Event.Id
        $This.Type        = $Event.LevelDisplayName
        $This.InsertEvent($Event)
    }
    EventLogRec([Object]$Entry,[UInt32]$Option)
    {
        $Stream           = $Entry.Open()
        $Reader           = [System.IO.StreamReader]::New($Stream)
        $Event            = $Reader.ReadToEnd() | ConvertFrom-Json
        $Reader.Close()
        $Stream.Close()
        $This.Index       = $Event.Index
        $This.Name        = $Event.Name
        $This.DateTime    = [DateTime]$Event.DateTime
        $This.Date        = $Event.Date
        $This.Log         = $Event.Log
        $This.Rank        = $Event.Rank
        $This.Provider    = $Event.Provider
        $This.Id          = $Event.Id
        $This.Type        = $Event.Type
        $This.InsertEvent($Event)
    }
    InsertEvent([Object]$Event)
    {
        $FullMessage   = $Event.Message -Split "`n"
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
        $This.Version              = $Event.Version
        $This.Qualifiers           = $Event.Qualifiers
        $This.Level                = $Event.Level
        $This.Task                 = $Event.Task
        $This.Opcode               = $Event.Opcode
        $This.Keywords             = $Event.Keywords
        $This.RecordId             = $Event.RecordId
        $This.ProviderId           = $Event.ProviderId
        $This.LogName              = $Event.LogName
        $This.ProcessId            = $Event.ProcessId
        $This.ThreadId             = $Event.ThreadId
        $This.MachineName          = $Event.MachineName
        $This.UserID               = $Event.UserId
        $This.ActivityID           = $Event.ActivityId
        $This.RelatedActivityID    = $Event.RelatedActivityID
        $This.ContainerLog         = $Event.ContainerLog
        $This.MatchedQueryIds      = @($Event.MatchedQueryIds)
        $This.Bookmark             = $Event.Bookmark
        $This.OpcodeDisplayName    = $Event.OpcodeDisplayName
        $This.TaskDisplayName      = $Event.TaskDisplayName
        $This.KeywordsDisplayNames = @($Event.KeywordsDisplayNames)
        $This.Properties           = @($Event.Properties.Value)
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

Class EventLogCfg
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
    Hidden [Object] $Swap
    [Object[]] $Output
    [UInt32] $Total
    EventLogCfg([UInt32]$Rank,[Object]$Event)
    {
        $This.Rank                           = $Rank
        $This.LogName                        = $Event.LogName 
        $This.LogType                        = $Event.LogType 
        $This.LogIsolation                   = $Event.LogIsolation 
        $This.IsEnabled                      = $Event.IsEnabled 
        $This.IsClassicLog                   = $Event.IsClassicLog 
        $This.SecurityDescriptor             = $Event.SecurityDescriptor
        $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", $Env:SystemRoot 
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
        $This.GetEventLogRecord()
        $This.Swap                           = @{ }
        $This.Output                         = @( )
    }
    EventLogCfg([Object]$Event)
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
        $This.Swap                           = @{ }
        $This.Output                         = @( )
    }
    GetEventLogRecord()
    {
        $This.EventLogRecord                 = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
        If ($This.EventLogRecord.Count -gt 0)
        {
            $C = 0
            ForEach ($Record in $This.EventLogRecord)
            {
                Add-Member -InputObject $Record -MemberType NoteProperty -Name Rank  -Value $C
                Add-Member -InputObject $Record -MemberType NoteProperty -Name LogId -Value $This.Rank
                $C ++
            }
        }
        $This.Total                           = $This.EventLogRecord.Count
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
        ProvicerControlGuid
    }
    [Void] Insert([UInt32]$Index)
    {
        $This.Swap.Add($This.Swap.Count,$Index)
    }
}

Class EventLogs
{
    [Object]          $Time
    [Object]         $Start
    [String]         $Title
    [String]   $Destination
    Hidden [Object]    $Zip
    [String[]]   $Providers
    [Object]           $Log
    [Object]        $Output
    EventLogs()
    {
        # Starting variables
        $This.Time        = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Start       = [DateTime]::Now
        $This.Title       = "{0}-{1}" -f $This.Start.ToString("yyyy_MMdd-HHmmss"), $Env:ComputerName
        $This.Destination = "$Env:Temp\$($This.Title)"
        $This.Providers   = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object

        # Grouping variables
        $Hash             = @{ }
        $Swap             = @( )
        $This.Log         = @( )
        $This.Output      = @( )

        # Formatting variables
        $Ct               = $This.Providers.Count
        $Depth            = ([String]$Ct).Length

        # Provider logs
        ForEach ($Provider in $This.Providers | % { [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($_) })
        {
            $Percent      = "{0:n2}" -f ($This.Log.Count/$This.Providers.Count*100)
            $Notice       = @(""," - this log takes several minutes to collect")[$Provider.LogName -eq "Security"]
            Write-Host "Collecting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Name: [$($Provider.LogName)$Notice]"
            $Item         = [EventLogCfg]::New($This.Log.Count,$Provider)
            ForEach ($EventLogRecord in $Item.EventLogRecord)
            {
                $Hash.Add($Hash.Count,$EventLogRecord)
            }
            $This.Log         += $Item
        }

        # Individual events, index and rank
        $Swap             = $Hash[0..($Hash.Count-1)] | Sort-Object TimeCreated
        $Hash             = @{ }

        $Ct               = $Swap.Count
        $Depth            = ([String]$Ct).Length

        $Complete         = @( )
        $Complete        += "0.00"
        $Phase            = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Indexing (0.00%) [~] Elapsed: [$($This.Time.Elapsed)], (Please wait, this may take a while)"
        ForEach ($X in 0..($Swap.Count-1))
        {
            Add-Member -InputObject $Swap[$X] -MemberType NoteProperty -Name Index -Value $X
            Add-Member -InputObject $Swap[$X] -MemberType NoteProperty -Name Name -Value ("({0:d$Depth})-{1}-({2}-{3})" -f $X, $Swap[$X].TimeCreated.ToString("yyyy_MMdd-HHmmss"),$Swap[$X].LogId,$Swap[$X].Rank)
            $Item         = [EventLogRec]::New($Swap[$X])
            $This.Log[$Item.Log].Insert($X)
            $Hash.Add($X,$Item)
            $Percent      = "{0:n2}" -f ($X * 100 / $Swap.Count)
            If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                Write-Host "Indexing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Rank: ($X/$($Swap.Count))"
            }
        }
        $Phase.Stop()
        Write-Host "Indexed (100.00%) [+] Elapsed: [$($This.Time.Elapsed)]"

        $This.Output      = $Hash[0..($Hash.Count-1)]

        $Complete         = @( )
        $Complete        += "0.00"
        $Phase            = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Sorting (0.00%) [~] Elapsed: [$($This.Time.Elapsed)]"
        ForEach ($X in 0..($This.Log.Count-1))
        {
            $Temp         = @{ }
            $Item         = $This.Log[$X]
            $Percent      = "{0:n2}" -f ($X * 100 / $This.Log.Count)
            If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                Write-Host "Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)]"
            }
            Switch ($Item.Total)
            {
                {$_ -eq 0}
                {
                    $Item.Output = @( )
                }
                {$_ -eq 1}
                {
                    $Temp.Add(0,$This.Output[$Item.Swap[0]])
                    $Item.Output = @($Temp[0])
                }
                {$_ -gt 1}
                {
                    ForEach ($I in 0..($Item.Swap.Count-1))
                    {
                        $Temp.Add($I,$This.Output[$Item.Swap[$I]])
                    }
                    $Item.Output = @($Temp[0..($Temp.Count-1)])
                }
            }
        }
        Write-Host "Sorted (100.00%) [+] Elapsed: [$($This.Time.Elapsed)]"
        $This.Time.Stop()
    }
    EventLogs([String]$ZipFile)
    {
        If (!(Test-Path $Zipfile) -or $ZipFile.Split(".")[-1] -notmatch "zip")
        {
            Throw "Invalid Path"
        }
        
        $This.Time        = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Destination = $ZipFile

        # Get zip content, pull master file
        $This.Zip         = [System.IO.Compression.Zipfile]::Open($Zipfile,"Read")
        $Manifest         = $This.Zip.Entries | ? Name -eq Master
        $ManifestPath     = "$Env:Temp\Master.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($Manifest,$ManifestPath,$True)
        $Master           = (Get-Content $ManifestPath).Split(";").TrimStart(" ")
        Remove-Item $ManifestPath

        # Apply variables from master file
        $This.Title       = $Master[0].Substring(9) 
        $This.Start       = [DateTime]$Master[1].Substring(9)
        $ProviderList     = @($Master[2].Substring(13);$Master[3..($Master.Count-1)]) | ConvertFrom-Json
        $This.Providers   = $ProviderList.LogName
        $Ct               = $This.Providers.Count
        $Depth            = ([String]$Ct).Length

        $This.Log         = @( )
        $This.Output      = @( )
        $Hash             = @{ }
        $LHash            = @{ }
        $RHash            = @{ }
        
        # Collect logs and sub items
        $Complete         = @( )
        $Complete        += "0.00"
        Write-Host "Restoring (0.00%) [~] Providers: ($Ct) found."
        ForEach ($X in 0..($ProviderList.Count-1))
        {
            $Item         = [EventLogCfg]::New($ProviderList[$X])
            $LHash.Add($Item.LogName,@{ })
            $This.Log    += $Item
            $Percent      = "{0:n2}" -f ($X * 100 / $Ct)
            Write-Host "Restoring ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Provider: [$($Item.LogName)]"
        }
        Write-Host "Restored (100.00%) [+] Providers: ($Ct) found."

        # Collect Files
        $Files            = $This.Zip.Entries | ? Name -notmatch Master

        $Complete         = @( )
        $Complete        += "0.00"
        $Phase            = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Importing (0.00%) [~] Files: ($($Files.Count)) found."
        ForEach ($X in 0..($Files.Count-1))
        {
            $File         = $Files[$X]
            $Item         = [EventLogRec]::New($File,0)
            $Hash.Add($X,$Item)
            $LHash["$($Item.LogName)"].Add($Item.Rank,$Item.Index)
            $Percent      = "{0:n2}" -f ($X * 100 / $Files.Count)
            If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                Write-Host "Importing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        $Phase.Stop()
        Write-Host "Imported (100.00%) [+] Files: ($($Files.Count)) found."
        $This.Output       = $Hash[0..($Hash.Count-1)]

        # Sort the logs
        $Complete          = @( )
        $Complete         += "0.00"
        $Phase             = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Sorting (0.00%) [~] Logs: ($($This.Log.Count)) found."
        ForEach ($X in 0..($This.Providers.Count-1))
        {
            $LogName       = $This.Providers[$X]
            $LogItem       = $This.Log | ? LogName -eq $LogName
            $Slot          = $LHash["$($LogName)"].GetEnumerator() | Sort-Object Name | % Value
            Switch ($Slot.Count)
            {
                {$_ -eq 0} 
                {
                    $LogItem.Output = @( )
                } 
                {$_ -eq 1} 
                { 
                    $RHash = @{ }
                    $RHash.Add(0,$This.Output[$Slot[0]])
                    $LogItem.Output = @($RHash[0])
                }
                {$_ -gt 1}
                {
                    $RHash = @{ }
                    ForEach ($I in 0..($Slot.Count-1))
                    {
                        $RHash.Add($I,$This.Output[$Slot[$I]])
                    }
                    $LogItem.Output = @($RHash[0..($RHash.Count-1)])
                }
            }
            $LogItem.Total  = $LogItem.Output.Count
            $Percent        = "{0:n2}" -f ($X * 100 / $This.Providers.Count)
            Write-Host "Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)]"
        }
        Write-Host "Sorted (100.00%) [+] Logs: ($($This.Log.Count)) found."
        $This.Time.Stop()
    }
    Export()
    {
        $This.Time.Start()

        # Export
        If (Test-Path $This.Destination)
        {
            Throw "The path exists, manually (move/delete) first."
        }
        If (Test-Path "$($This.Destination).zip")
        {
            Throw "The file exists, manually (move/delete) first."
        }

        # Directory/Master
        New-Item -Path $This.Destination -ItemType Directory
        Set-Content -Path "$($This.Destination)\Master.txt" -Value @("[Title]: $($This.Title)`n[Start]: $($This.Start)`n[Providers]: $($This.Log.Config() | ConvertTo-Json)")

                       [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","Create").Dispose()
        $This.Zip    = [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","Update")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,"$($This.Destination)\Master.txt","Master",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

        # Convert default event log classes to custom, set content, add to zip 
        $Complete    = @( )
        $Complete   += "0.00"
        $Phase       = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Exporting (0.00%) [~] Elapsed: [$($This.Time.Elapsed)]"
        Write-Progress -Activity "Exporting (0.00%)" -PercentComplete 0
        ForEach ($X in 0..($This.Output.Count-1))
        {
            $Item    = $This.Output[$X]
            $Target  = "$($This.Destination)\$($Item.Name).log"
            $Item.SetContent($Target)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,$Target,$Item.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

            $Percent = "{0:n2}" -f ($X * 100 / $This.Output.Count)
            If ($Percent -match "\d+(0|5)\.00" -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                Write-Host "Exporting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
                Write-Progress -Activity "Exporting ($Percent%)" -PercentComplete $Percent 
            }
        }
        Write-Progress -Activity "Exported (100.00%)" -Complete
        $Phase.Stop()
        Write-Host "Saving (0.00%) [~] Elapsed: [$($This.Time.Elapsed)], File: [$($This.Destination).zip] (Please wait, the process may appear to freeze while it is saving)"
        $This.Zip.Dispose()

        $Item = Get-Item "$($This.Destination).zip"
        Switch (!!$Item)
        {
            $True
            {
                Write-Host "Saved (100.00%) [+] Elapsed [$($This.Time.Elapsed)], File: [$($This.Destination).zip], Size: [$("{0:n3}MB" -f ($Item.Length/1MB))]"
            }
            $False
            {
                Write-Host "Failed (100.00%) [!] Elapsed [$($This.Time.Elapsed)], File: [$($This.Destination).zip], the file does not exist."
            }
        }
        Write-Host "Purging [~] Elapsed: [$($This.Time.Elapsed)], Folder: [$($This.Destination)] (Please wait, the process is removing the swap folder)"
        Remove-Item $This.Destination -Recurse -Confirm:$False
        Switch (!!$Item)
        {
            $True
            {
                Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive saved: [$($This.Destination).zip]"
            }
            $False
            {
                Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive failed: [$($This.Destination).zip]"
            }
        }
        $This.Time.Stop()
    }
}

Class EventControl
{
    [Object] $Xaml
    [Object] $Event
    Hidden [String] $LogMainFilter
    Hidden [Int32] $LogMainIndex   = -1
    Hidden [String] $LogOutputFilter
    Hidden [Int32] $LogOutputIndex = -1
    Hidden [String] $OutputFilter
    Hidden [Int32] $OutputIndex    = -1
    Hidden [UInt32] $Toggle        = 0
    EventControl()
    {
        $This.Xaml = [XamlWindow][EventLogsGUI]::Tab
    }
    Initialize()
    {
        $This.Xaml.IO.Time.Text          = $This.Event.Time.Elapsed
        $This.Xaml.IO.Start.Text         = $This.Event.Start.ToString()
        $This.Xaml.IO.Title.Text         = $This.Event.Title
        $This.Xaml.IO.Destination.Text   = $This.Event.Destination
        $This.Reset($This.Xaml.IO.Providers.Items,$This.Event.Providers)
        $This.Xaml.IO.ProviderCount.Text = $This.Event.Providers.Count
        If ($This.Event.Providers.Count -gt 0)
        {
            $This.Xaml.IO.Providers.SelectedIndex = 0
        }

        $This.Reset($This.Xaml.IO.LogMainResult.Items,$This.Event.Log)
        $This.Reset($This.Xaml.IO.OutputResult.Items,$This.Event.Output)
    }
    InsertEventLogs([Object]$EventLogObject)
    {
        $This.Event = $EventLogObject
        $This.Xaml.IO.ModeSelect.SelectedIndex = 0
        $This.Initialize()
    }
    GetEventLogs()
    {
        $This.Event = [EventLogs]::New()
        $This.Xaml.IO.ModeSelect.SelectedIndex = 0
        $This.Initialize()
    }
    ExportEventLogs()
    {
        If (!$This.Event)
        {
            $This.Event = [EventLogs]::New()
        }
        $This.Xaml.IO.ModeSelect.SelectedIndex = 1
        $This.Initialize()

        $This.Event.Export()
    }
    ExportEventLogs([String]$Path)
    {
        If (!$This.Event)
        {
            $This.Event = [EventLogs]::New()
        }
        $This.Xaml.IO.ModeSelect.SelectedIndex = 1
        $This.Event.Destination = "$Path\$($This.Title)"
        $This.Initialize()

        $This.Event.Export()
    }
    ImportEventLogs([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }
        $This.Event = [EventLogs]::New($Path)
        $This.Xaml.IO.ModeSelect.SelectedIndex = 2
        $This.Initialize()
    }
    Reset([Object]$Sender,[Object[]]$Content)
    {
        $Sender.Clear()
        ForEach ($Item in $Content)
        {
            $Sender.Add($Item)
        }
    }
    [Object[]] ViewProperties([Object]$Object)
    {
        Return @( $Object.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) } )
    }
    [String] CleanString([String]$String)
    {
        Return "({0})" -f [Regex]::Escape($String) 
    }
    [String] LogProperty([String]$Slot)
    {
        Return @( Switch ($Slot)
        {
            Rank { "Rank" } Name { "LogName" } Type { "LogType" } Path { "LogFilePath" }
        })
    }
    [Object] ViewCopy()
    {
        $Return = @( )
        $Buffer = ($This.Xaml.IO.ViewerResult.Items | % Name | Sort-Object Length)[-1].Length
        ForEach ($Item in $This.Xaml.IO.ViewerResult.Items)
        {
            $Split  = $Item.Value -Split "`n"
            If ($Split.Count -eq 1)
            {
                $Return += "{0}{1}: {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''),$Item.Value
            }
            If ($Split.Count -gt 1)
            {
                ForEach ($X in 0..($Split.Count-1))
                {
                    If ($X -eq 0)
                    {
                        $Return += "{0}{1}: {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''),$Split[$X]
                    }
                    Else
                    {
                        $Return += "{0}  {1}" -f ( " " * $Buffer -join ""), $Split[$X]
                    }
                }
            }
        }
        Return $Return
    }
    [Void] ViewClear()
    {
        $This.Xaml.IO.ViewerResult.Items.Clear()
    }
}

# $Event = [EventLogs]::New()
# Event handlers often crash when they're written within the class itself.
$Ctrl    = [EventControl]::New()
If ($Event)
{
    $Ctrl.InsertEventLogs($Event)   
}
$Xaml    = $Ctrl.Xaml
$Xaml.IO.ModeSelect.Add_SelectionChanged(
{
    Switch ($Xaml.IO.ModeSelect.SelectedIndex)
    {
        0 # (Get/View event logs on this system)
        {
            $Xaml.IO.FilePath.Text            = ""
            $Xaml.IO.FilePath.IsEnabled       = 0
            $Xaml.IO.FilePathBrowse.IsEnabled = 0
        }
        1 # Export event logs on this system, to a file
        {
            $Xaml.IO.FilePath.Text            = ""
            $Xaml.IO.FilePath.IsEnabled       = 1
            $Xaml.IO.FilePathBrowse.IsEnabled = 1
        }
        2 # Import event logs from a file
        {
            $Xaml.IO.FilePath.Text            = ""
            $Xaml.IO.FilePath.IsEnabled       = 1
            $Xaml.IO.FilePathBrowse.IsEnabled = 1
        }
    }
})

$Xaml.IO.FilePathBrowse.Add_Click(
{
    $Item                            = New-Object System.Windows.Forms.FolderBrowserDialog
    $Item.ShowDialog()
        
    If (!$Item.SelectedPath)
    {
        $Item.SelectedPath           = ""
    }

    $Xaml.IO.FilePath.Text           = $Item.SelectedPath
})

$Xaml.IO.Continue.Add_Click(
{
    Switch ($Xaml.IO.ModeSelect.SelectedIndex)
    {
        0 # (Get/View event logs on this system)
        { 
            $Ctrl.GetEventLogs()
            $Ctrl.Initialize()
        }
        1 # Export event logs on this system, to a file
        {
            If ($Xaml.IO.FilePath.Text -eq "")
            {
                Switch([System.Windows.MessageBox]::Show("Directory selected not found, use default?","Warning","YesNo"))
                {
                    Yes 
                    { 
                        $Ctrl.ExportEventLogs() 
                    } 
                    No 
                    { 
                        Return "User cancelled" 
                    }
                } 
            }
            If ($Xaml.IO.FilePath.Text -ne "" -and (Test-Path $Xaml.IO.FilePath.Text))
            {
                $Ctrl.ExportEventLogs($Xaml.IO.FilePath.Text)
                $Ctrl.Initialize()
            }
        }
        2 # Import event logs from a file
        { 
            If ($Xaml.IO.FilePath.Text -eq "")
            {
                Return [System.Windows.MessageBox]::Show("An invalid directory was found in the input field","Error")
            }
            If ($Xaml.IO.FilePath.Text -ne "" -and (Test-Path $Xaml.IO.FilePath.Text))
            {
                $Ctrl.ImportEventLogs($Xaml.IO.FilePath.Text)
                $Ctrl.Initialize()
            }
        }
    }
})

# <Log panel>
#   [Log Main] 
$Xaml.IO.LogMainFilter.Add_TextChanged(
{
    $Ctrl.LogMainFilter = $Xaml.IO.LogMainFilter.Text
    If ($Xaml.IO.LogMainResult.SelectedIndex -ne -1 -and $Ctrl.LogMainFilter -ne "")
    {
        $Result = @( $Ctrl.Event.Log | ? $Ctrl.LogProperty($Xaml.IO.LogMainProperty.Text) -match $Ctrl.CleanString($Ctrl.LogMainFilter) )
        If ($Result)
        {
            $Ctrl.Reset($Xaml.IO.LogMainResult.Items,$Result)
        }
        Else
        {
            $Xaml.IO.LogMainResult.Items.Clear()
        }
    }
    Else
    {
        If ($Ctrl.Event.Log.Count -notmatch $Xaml.IO.LogMainResult.Items.Count)
        {
            $Ctrl.Reset($Xaml.IO.LogMainResult.Items,$Ctrl.Event.Log)
        }
    }
})

$Xaml.IO.LogMainRefresh.Add_Click(
{
    $Ctrl.Reset($Xaml.IO.LogMainResult.Items,$Ctrl.Event.Log)
})

$Xaml.IO.LogMainResult.Add_SelectionChanged(
{
    $Ctrl.LogMainIndex = $Xaml.IO.LogMainResult.SelectedIndex
    If ($Ctrl.LogMainIndex -gt -1)
    {
        $Xaml.IO.LogSelected.Text            = $Ctrl.Event.Log[$Ctrl.LogMainIndex].LogName
        $Xaml.IO.LogTotal.Text               = $Ctrl.Event.Log[$Ctrl.LogMainIndex].Total
        $Flag                                = @(0,1)[$Xaml.IO.LogTotal.Text -gt 0]
        $Ctrl.Reset($Xaml.IO.LogOutputResult.Items,$Ctrl.Event.Log[$Ctrl.LogMainIndex].Output)
        $Xaml.IO.LogOutputProperty.IsEnabled = $Flag
        $Xaml.IO.LogOutputFilter.IsEnabled   = $Flag
        $Xaml.IO.LogOutputRefresh.IsEnabled  = $Flag
        $Xaml.IO.LogOutputResult.IsEnabled   = $Flag
    }
})

$Xaml.IO.LogMainResult.Add_MouseDoubleClick(
{
    $Ctrl.LogMainIndex = $Xaml.IO.LogMainResult.SelectedIndex
    If ($Ctrl.LogMainIndex -gt -1)
    {
        $Ctrl.Reset($Xaml.IO.ViewerResult.Items,$Ctrl.ViewProperties($Ctrl.Event.Log[$Ctrl.LogMainIndex].Config()))
        $Xaml.IO.TabControl.Items[-1].IsSelected = 1
        $Xaml.IO.TabControl.UpdateLayout()
    }
})

#   [Log Output]
$Xaml.IO.LogOutputFilter.Add_TextChanged(
{
    If ($Ctrl.LogMainIndex -eq -1)
    {
        If ($Ctrl.Toggle -eq 0)
        {
            $Ctrl.Toggle = 1
            $Xaml.IO.LogOutputFilter.Text = ""
            $Ctrl.Toggle = 0
            [System.Windows.MessageBox]::Show("Select an entry in the log output list first")
        }
    }
    Else
    {
        $Ctrl.LogOutputFilter = $Xaml.IO.LogOutputFilter.Text
        $Anchor               = $Ctrl.Event.Log[$Ctrl.LogMainIndex].Output
        If ($Anchor.Count -gt 0 -and $Ctrl.LogOutputFilter -ne "")
        {
            $Result = @( $Ctrl.Event.Log[$Ctrl.LogMainIndex].Output | ? $Xaml.IO.LogOutputProperty.Text -match $Ctrl.CleanString($Ctrl.LogOutputFilter) )
            If ($Result)
            {
                $Ctrl.Reset($Xaml.IO.LogOutputResult.Items,$Result)
            }
            Else
            {
                $Xaml.IO.LogOutputResult.Items.Clear()
            }
        }
        Else
        {
            If ($Anchor.Count -notmatch $Xaml.IO.LogOutputResult.Items.Count)
            {
                $Ctrl.Reset($Xaml.IO.LogOutputResult.Items,$Anchor)
            }
        }
    }
})

$Xaml.IO.LogOutputRefresh.Add_Click(
{
    If ($Ctrl.LogOutputIndex -ne -1)
    {
        $Ctrl.Reset($Xaml.IO.LogOutputResult.Items,$Ctrl.Event.Log[$Ctrl.LogOutputIndex].Output)
    }
})

$Xaml.IO.LogOutputResult.Add_MouseDoubleClick(
{
    $Ctrl.LogOutputIndex = $Xaml.IO.LogOutputResult.SelectedIndex
    If ($Ctrl.LogOutputIndex -gt -1)
    {
        $Ctrl.Reset($Xaml.IO.ViewerResult.Items,$Ctrl.ViewProperties($Ctrl.Event.Log[$Ctrl.LogMainIndex].Output[$Ctrl.LogOutputIndex].Config()))
        $Xaml.IO.TabControl.Items[-1].IsSelected = 1
        $Xaml.IO.TabControl.UpdateLayout()
    }
})

# <Output panel>
#   [Output]

$Xaml.IO.OutputFilter.Add_TextChanged(
{
    $Ctrl.OutputFilter = $Xaml.IO.OutputFilter.Text
    If ($Ctrl.Event.Output.Count -gt 0 -and $Ctrl.OutputFilter -ne "")
    {
        $Result = @( $Ctrl.Event.Output | ? $Xaml.IO.OutputProperty.Text -match $Ctrl.CleanString($Ctrl.OutputFilter) )
        If ($Result)
        {
            $Ctrl.Reset($Xaml.IO.OutputResult.Items,$Result)
        }
        Else
        {
            $Xaml.IO.OutputResult.Items.Clear()
        }
    }
    Else
    {
        If ($Ctrl.Event.Output.Count -notmatch $Xaml.IO.OutputResult.Items.Count)
        {
            $Ctrl.Reset($Xaml.IO.OutputResult.Items,$Ctrl.Event.Output)
        }
    }
})

$Xaml.IO.OutputRefresh.Add_Click(
{
    $Ctrl.Reset($Xaml.IO.OutputResult.Items,$Ctrl.Event.Output)
})

$Xaml.IO.OutputResult.Add_MouseDoubleClick(
{
    $Ctrl.OutputIndex = $Xaml.IO.OutputResult.SelectedIndex
    If ($Ctrl.OutputIndex -gt 1)
    {
        $Ctrl.Reset($Xaml.IO.ViewerResult.Items,$Ctrl.ViewProperties($Ctrl.Event.Output[$Ctrl.OutputIndex].Config()))
        $Xaml.IO.TabControl.Items[-1].IsSelected = 1
        $Xaml.IO.TabControl.UpdateLayout()
    }
})

# Viewer Panel

$Xaml.IO.ViewerCopy.Add_Click(
{
    $Ctrl.ViewCopy() | Set-Clipboard
})

$Xaml.IO.ViewerClear.Add_Click(
{
    $Ctrl.ViewClear()
})

# Initial ComboBox Selection
$Xaml.Invoke()

# Begin
