# Runspace Project Event logs
# Function Entries

Add-Type -Assembly System.IO.Compression, System.IO.Compression.Filesystem, System.Windows.Forms, PresentationFramework

Function Get-EventLogGUI
{
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
        '                        <TextBox Grid.Column="1" Name="FilePath" IsEnabled="False"/>',
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
    [EventLogGUI]::Tab
}

Function Get-EventLogArchive
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][String]$FilePath,
        [Parameter(ParameterSetName=1)][Switch]$Empty)

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
    Switch ($psCmdLet.ParameterSetName)
    {
        0 { [EventLogArchive]::New($FilePath) }
        1 { [EventLogArchive]::New() }
    }
}

Function Get-EventLogController
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)]
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Console,
        [Parameter(Mandatory,ParameterSetName=0)]
        [Parameter(Mandatory,ParameterSetName=1)][UInt32]$Mode,
        [Parameter(Mandatory,ParameterSetName=1)][String]$FilePath)

    Add-Type -Assembly System.IO.Compression.Filesystem

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
        EventLogRecordExtension([Object]$Event)
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
        EventLogRecordExtension([Object]$Entry,[UInt32]$Option)
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
        Hidden [Object] $Swap
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Event)
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
            ProviderControlGuid
        }
        [Void] Insert([UInt32]$Index)
        {
            $This.Swap.Add($This.Swap.Count,$Index)
        }
    }

    Class EventLogController
    {
        Hidden [Object] $Console
        [UInt32]           $Mode
        [Object]           $Time
        [Object]          $Start
        [Object]    $DisplayName
        [Object]    $Destination
        Hidden [Object]     $Zip
        [Object[]]    $Providers
        [Object]            $Log
        [Object]         $Output
        WriteOutput([String]$Line)
        {
            $This.Console.Dispatcher.Invoke([Action]{$This.Console.AppendText("$Line`n")},"Normal")
        }
        EventLogController([Object]$Console,[UInt32]$Mode)
        {
            $This.Console     = $Console
            $This.Mode        = $Mode
            $This.WriteOutput("(Get/View) Event logs on this system - Selected")

            $This.Time        = [System.Diagnostics.Stopwatch]::StartNew()
            $This.Start       = [DateTime]::Now

            $This.DisplayName = "{0}-{1}" -f $This.Start.ToString("yyyy_MMdd-HHmmss"), $Env:ComputerName
            $This.Destination = "$Env:Temp\$($This.DisplayName)"
            $This.Providers   = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
            $This.Log         = @( )
            $This.Output      = @( )
            $Hash             = @{ }
            $Swap             = @( )
            $Ct               = $This.Providers.Count
            $Depth            = ([String]$Ct).Length

            # Provider logs
            ForEach ($Provider in $This.Providers | % { [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($_) })
            {
                $Percent      = "{0:n2}" -f ($This.Log.Count/$This.Providers.Count*100)
                $Notice       = @(""," - this log takes several minutes to collect")[$Provider.LogName -eq "Security"]
                $This.WriteOutput("Collecting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Name: [$($Provider.LogName)$Notice]")
                $Item         = $This.GetEventLogConfigExtension($This.Log.Count,$Provider)
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
            $This.WriteOutput("Indexing (0.00%) [~] Elapsed: [$($This.Time.Elapsed)], (Please wait, this may take a while)")
            ForEach ($X in 0..($Swap.Count-1))
            {
                Add-Member -InputObject $Swap[$X] -MemberType NoteProperty -Name Index -Value $X
                Add-Member -InputObject $Swap[$X] -MemberType NoteProperty -Name Name -Value ("({0:d$Depth})-{1}-({2}-{3})" -f $X, $Swap[$X].TimeCreated.ToString("yyyy_MMdd-HHmmss"),$Swap[$X].LogId,$Swap[$X].Rank)
                $Item         = $This.GetEventLogRecordExtension($Swap[$X])
                $This.Log[$Item.Log].Insert($X)
                $Hash.Add($X,$Item)
                $Percent      = "{0:n2}" -f ($X * 100 / $Swap.Count)
                If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
                {
                    $Complete += $Percent
                    $This.WriteOutput("Indexing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Rank: ($X/$($Swap.Count))")
                }
            }
            $Phase.Stop()
            $This.WriteOutput("Indexed (100.00%) [+] Elapsed: [$($This.Time.Elapsed)]")

            $This.Output      = $Hash[0..($Hash.Count-1)]

            $Complete         = @( )
            $Complete        += "0.00"
            $Phase.Reset()
            $Phase.Start()
            $This.WriteOutput("Sorting (0.00%) [~] Elapsed: [$($This.Time.Elapsed)]")
            ForEach ($X in 0..($This.Log.Count-1))
            {
                $Temp         = @{ }
                $Item         = $This.Log[$X]
                $Percent      = "{0:n2}" -f ($X * 100 / $This.Log.Count)
                If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
                {
                    $Complete += $Percent
                    $This.WriteOutput("Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)]")
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
            $This.WriteOutput("Sorted (100.00%) [+] Elapsed: [$($This.Time.Elapsed)]")
            $This.Time.Stop()
        }
        EventLogController([Object]$Console,[UInt32]$Mode,[String]$ZipFile)
        {
            $This.Console     = $Console
            $This.Mode        = $Mode
            $This.WriteOutput("(Import/View) Event logs from an archive - Selected")

            $This.Time        = [System.Diagnostics.Stopwatch]::StartNew()
            $This.Destination = $ZipFile

            # Get zip content, pull master file
            $This.Zip         = [System.IO.Compression.Zipfile]::Open($Zipfile,"Read")
            $Manifest         = $This.Zip.Entries | ? Name -eq Master
            $ManifestPath     = "$Env:Temp\Master.txt"
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($Manifest,$ManifestPath,$True)
            $Master           = Get-Content $ManifestPath
            Remove-Item $ManifestPath

            # Apply variables from master file
            $This.DisplayName = $Master[0].Substring(9) 
            $This.Start       = [DateTime]$Master[1].Substring(9)
            $ProviderList     = @($Master[2].Substring(13);$Master[3..($Master.Count-1)]) | ConvertFrom-Json
            $This.Providers   = $ProviderList.LogName
            $This.Log         = @( )
            $This.Output      = @( )

            $Ct               = $This.Providers.Count
            $Depth            = ([String]$Ct).Length

            $ProviderList     = $This.Zip

            $Hash             = @{ }
            $LHash            = @{ }
            $RHash            = @{ }
            
            # Collect logs and sub items
            $Complete         = @( )
            $Complete        += "0.00"
            $This.WriteOutput("Restoring (0.00%) [~] Providers: ($Ct) found.")
            ForEach ($X in 0..($ProviderList.Count-1))
            {
                $Item         = $This.ExpandEventLogConfigExtension($ProviderList[$X])
                $LHash.Add($Item.LogName,@{ })
                $This.Log    += $Item
                $Percent      = "{0:n2}" -f ($X * 100 / $Ct)
                $This.WriteOutput("Restoring ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Provider: [$($Item.LogName)]")
            }
            $This.WriteOutput("Restored (100.00%) [+] Providers: ($Ct) found.")
    
            # Collect Files
            $Files            = $This.Zip.Entries | ? Name -notmatch Master
    
            $Complete         = @( )
            $Complete        += "0.00"
            $Phase            = [System.Diagnostics.Stopwatch]::StartNew()
            $This.WriteOutput("Importing (0.00%) [~] Files: ($($Files.Count)) found.")
            ForEach ($X in 0..($Files.Count-1))
            {
                $File         = $Files[$X]
                $Item         = $This.ExpandEventLogRecordExtension($File,0)
                $Hash.Add($X,$Item)
                $LHash["$($Item.LogName)"].Add($Item.Rank,$Item.Index)
                $Percent      = "{0:n2}" -f ($X * 100 / $Files.Count)
                If ($Percent -match "\d*(0|5)\.00" -and $Percent -notin $Complete)
                {
                    $Complete += $Percent
                    $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                    $This.WriteOutput("Importing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]")
                }
            }
            $Phase.Stop()
            $This.WriteOutput("Imported (100.00%) [+] Files: ($($Files.Count)) found.")
            $This.Output       = $Hash[0..($Hash.Count-1)]
    
            # Sort the logs
            $Complete          = @( )
            $Complete         += "0.00"
            $Phase             = [System.Diagnostics.Stopwatch]::StartNew()
            $This.WriteOutput("Sorting (0.00%) [~] Logs: ($($This.Log.Count)) found.")
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
                $This.WriteOutput("Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)]")
            }
            $This.WriteOutput("Sorted (100.00%) [+] Logs: ($($This.Log.Count)) found.")
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
            Set-Content -Path "$($This.Destination)\Master.txt" -Value @("[DisplayName]: $($This.DisplayName)`n[Start]: $($This.Start)`n[Providers]: $($This.Log.Config() | ConvertTo-Json)")
    
                           [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","Create").Dispose()
            $This.Zip    = [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","Update")
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,"$($This.Destination)\Master.txt","Master",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
    
            # Convert default event log classes to custom, set content, add to zip 
            $Complete    = @( )
            $Complete   += "0.00"
            $Phase       = [System.Diagnostics.Stopwatch]::StartNew()
            $This.WriteOutput("Exporting (0.00%) [~] Elapsed: [$($This.Time.Elapsed)]")
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
                    $This.WriteOutput("Exporting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]")
                    Write-Progress -Activity "Exporting ($Percent%)" -PercentComplete $Percent 
                }
            }
            Write-Progress -Activity "Exported (100.00%)" -Complete
            $Phase.Stop()
            $This.WriteOutput("Saving (0.00%) [~] Elapsed: [$($This.Time.Elapsed)], File: [$($This.Destination).zip] (Please wait, the process may appear to freeze while it is saving)")
            $This.Zip.Dispose()
    
            $Item = Get-Item "$($This.Destination).zip"
            Switch (!!$Item)
            {
                $True
                {
                    $This.WriteOutput("Saved (100.00%) [+] Elapsed [$($This.Time.Elapsed)], File: [$($This.Destination).zip], Size: [$("{0:n3}MB" -f ($Item.Length/1MB))]")
                }
                $False
                {
                    $This.WriteOutput("Failed (100.00%) [!] Elapsed [$($This.Time.Elapsed)], File: [$($This.Destination).zip], the file does not exist.")
                }
            }
            $This.WriteOutput("Purging [~] Elapsed: [$($This.Time.Elapsed)], Folder: [$($This.Destination)] (Please wait, the process is removing the swap folder)")
            Remove-Item $This.Destination -Recurse -Confirm:$False
            Switch (!!$Item)
            {
                $True
                {
                    $This.WriteOutput("Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive saved: [$($This.Destination).zip]")
                }
                $False
                {
                    $This.WriteOutput("Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive failed: [$($This.Destination).zip]")
                }
            }
            $This.Time.Stop()
        }
        [Object] GetEventLogArchive([String]$Fullname)
        {
            Return [EventLogArchive]::New($Fullname)
        }
        [Object] NoEventLogArchive()
        {
            Return [EventLogArchive]::New()
        }
        [Object] GetEventLogRecordExtension([Object]$Event)
        {
            Return [EventLogRecordExtension]::New($Event)
        }
        [Object] ExpandEventLogRecordExtension([Object]$Entry,[UInt32]$Option)
        {
            Return [EventLogRecordExtension]::New($Entry,$Option)
        }
        [Object] GetEventLogConfigExtension([UInt32]$Rank,[Object]$Config)
        {
            Return [EventLogConfigExtension]::New($Rank,$Config)
        }
        [Object] ExpandEventLogConfigExtension([Object]$Config)
        {
            Return [EventLogConfigExtension]::New($Config)
        }
    }
    
    Switch($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogController]::New($Console,$Mode) }
        1 { [EventLogController]::New($Console,$Mode,$FilePath) }
    }
}

# Primary Runspace for the GUI
$PrimarySession   = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
ForEach ($Item in "Get-EventLogGUI","Get-EventLogArchive","Get-EventLogController")
{
    "System.Windows.Forms","PresentationFramework","System.IO.Compression","System.IO.Compression.Filesystem" | % {

        $Object = [System.Management.Automation.Runspaces.SessionStateAssemblyEntry]::New($_)
        $PrimarySession.Assemblies.Add($Object)
    }
    $Content = Get-Content "Function:\$Item" -ErrorAction Stop
    $Object  = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Item,$Content)
    $PrimarySession.Commands.Add($Object) 
}

# Secondary Runspace for the GUI
$SecondarySession = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
ForEach ($Item in "Get-EventLogController" )
{
    "System.IO.Compression","System.IO.Compression.Filesystem" | % { 

        $Object = [System.Management.Automation.Runspaces.SessionStateAssemblyEntry]::New($_)
        $SecondarySession.Assemblies.Add($Object)
    }
    $Content  = Get-Content "Function:\$Item" -ErrorAction Stop
    $Object   = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Item,$Content)
    $SecondarySession.Commands.Add($Object)
}

$Global:SyncHash                = [Hashtable]::Synchronized(@{})
$Runspace1                      = [RunspaceFactory]::CreateRunspace($PrimarySession)
$Runspace1.ApartmentState       = "STA"
$Runspace1.ThreadOptions        = "ReuseThread"          
$Runspace1.Open()
$Runspace1.SessionStateProxy.SetVariable("SyncHash",$SyncHash)

$PowerShell1                    = [PowerShell]::Create().AddScript({

    $XamlString                 = Get-EventLogGUI
    $XamlNames                  = [Regex]::Matches($XamlString,"((\s*Name\s*=\s*)('|`")(\w+)('|`"))").Groups | ? Name -eq 4 | % Value | Select-Object -Unique
    [Xml]$Xaml                  = $XamlString
    ForEach ($Attrib in 'x:Class','mc:Ignorable') 
    {
        If ($Xaml.Window.GetAttribute($Attrib)) 
        {
             $Xaml.Window.RemoveAttribute($Attrib)
        }
    }
    $Reader                     = [System.Xml.XmlNodeReader]::New($Xaml)
    $SyncHash.Window            = [System.Windows.Markup.XamlReader]::Load($Reader)
    [Xml]$Xaml                  = $Xaml
    ForEach ($Item in $XamlNames)
    {
        $SyncHash.Add($Item,$SyncHash.Window.FindName($Item))
    }

    $SyncHash.Mode.Add_SelectionChanged(
    {
        $SyncHash.FilePath.Text                    = ""
        $SyncHash.Archive.Items.Clear()

        Switch ($SyncHash.Mode.SelectedIndex)
        {
            0
            {
                $SyncHash.Archive.IsEnabled        = 0
                $SyncHash.FilePath.IsEnabled       = 0
                $SyncHash.FilePathBrowse.IsEnabled = 0
            }
            1
            {
                $SyncHash.Archive.IsEnabled        = 1
                $SyncHash.FilePath.IsEnabled       = 1
                $SyncHash.FilePathBrowse.IsEnabled = 1
            }
        }
    })

    $SyncHash.FilePathBrowse.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:Temp
        $Item.Filter                     = "zip files (*.zip)|*.zip"

        $Item.ShowDialog()
            
        If (!$Item.FileName)
        {
            $SyncHash.FilePath.Text      = ""
            $SyncHash.Archive.Items.Clear()
            $SyncHash.Archive.Items.Add((Get-EventLogArchive -Empty))

        }
        Else
        {
            $SyncHash.FilePath.Text      = $Item.Filename
            $SyncHash.Archive.Items.Clear()
            $SyncHash.Archive.Items.Add((Get-EventLogArchive -FilePath $Item.Filename))
        }
    })

    # Event Handlers
    $SyncHash.Console.Add_TextChanged(
    {
        $SyncHash.Console.ScrollToEnd()
    })

    $SyncHash.Continue.Add_Click(
    {
        If ($SyncHash.Mode.SelectedIndex -eq 1)
        {
            If (!(Test-Path $SyncHash.FilePath.Text))
            {
                Return [System.Windows.MessageBox]::Show("Invalid path","Error")
            }
        }
        Else
        {
            $SyncHash.Console.AppendText("Selected ($($SyncHash.Mode.SelectedIndex))`n")
            $Runspace2                      = [RunspaceFactory]::CreateRunspace($SecondarySession)
            $Runspace2.ApartmentState       = "STA"
            $Runspace2.ThreadOptions        = "ReuseThread"          
            $Runspace2.Open()
            $Runspace2.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
            $PowerShell2                    = [PowerShell]::Create()
            Switch ($SyncHash.Mode.SelectedIndex)
            {
                0 
                { 
                    $PowerShell2.AddScript(
                    {
                        Param ($Console,$Mode)
                        Get-EventLogController -Console $Console -Mode $Mode
                    })
                    $PowerShell2.AddArgument($SyncHash.Console)
                    $PowerShell2.AddArgument(0)
                }
                1    
                { 
                    $PowerShell2.AddScript(
                    { 
                        Param ($Console,$Mode,$FilePath)
                        Get-EventLogController -Console $Console -Mode $Mode -FilePath $FilePath 
                    })
                    $PowerShell2.AddArgument($SyncHash.Console)
                    $PowerShell2.AddArgument(1) 
                    $PowerShell2.AddArgument($Synchash.Filepath.Text)
                }
            }
            $PowerShell2.Runspace           = $Runspace2
            $PowerShell2.BeginInvoke()
        }
    })

    $SyncHash.Window.Add_Closed(
    {
        $SyncHash.Window.DialogResult = $True
    })

    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})

$PowerShell1.Runspace = $Runspace1
$Data                 = $PowerShell1.BeginInvoke()

<#
    $Event                      = [Hashtable]::Synchronized(@{})
    $NewRunspace                = [RunspaceFactory]::CreateRunspace($SecondarySession)
    $NewRunspace.ApartmentState = "STA"
    $NewRunspace.ThreadOptions  = "ReuseThread"
    $NewRunspace.Open()
    $NewRunspace.SessionStateProxy.SetVariable("Event",$Event)

    $Event.PowerShell           = [PowerShell]::Create().AddScript({

        $Event.Names            = Get-EventLogNames
        $Event.Logs             = @( )
        ForEach ($Name in $EventLog.Names)
        {
            $Item               = Get-EventLog -Index $Event.Logs.Count -Name $Name
            $Event.Logs        += Get-EventLogConfigExtension -EventLog $Item
        }
    })
    $Event.PowerShell.Runspace  = $NewRunspace
    $Event.Thread               = $Event.PowerShell.BeginInvoke()
})

$PsCmd.Runspace = $NewRunspace
$Data           = $psCmd.BeginInvoke()
#>
