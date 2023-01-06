# 2023-01-06 15:40:30

Function Get-ConsoleGUI
{
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
            Return "<FightingEntropy.XamlWindow>"
        }
    }

    Class TestUI
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="TestUI" Height="450" Width="800">',
        '    <Window.Resources>',
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
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="FontWeight" Value="Heavy"/>',
        '            <Setter Property="Background" Value="Yellow"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="IsEnabled" Value="False"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
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
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="8"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="40"/>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="40"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="100"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="100"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="100"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button  Grid.Column="0" Name="Initialize" Content="Initialize" IsEnabled="True"/>',
        '            <TextBox Grid.Column="1" Name="StartTime"/>',
        '            <Button  Grid.Column="2" Name="Finalize" Content="Finalize"/>',
        '            <TextBox Grid.Column="3" Name="EndTime"/>',
        '            <Button  Grid.Column="4" Content="Span"/>',
        '            <TextBox Grid.Column="5" Name="SpanTime"/>',
        '        </Grid>',
        '        <DataGrid Grid.Row="1" Name="Output" Margin="5">',
        '            <DataGrid.Columns>',
        '                <DataGridTextColumn Header="Index"   Width="40"  Binding="{Binding Index}"/>',
        '                <DataGridTextColumn Header="Elapsed" Width="100" Binding="{Binding Elapsed}"/>',
        '                <DataGridTextColumn Header="State"   Width="40"  Binding="{Binding State}"/>',
        '                <DataGridTextColumn Header="Status"  Width="*"   Binding="{Binding Status}"/>',
        '            </DataGrid.Columns>',
        '        </DataGrid>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="100"/>',
        '                <ColumnDefinition Width="100"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0" Content="Do stuff" Name="Action"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ConsoleController
    {
        [Object] $Console
        [Object] $Output
        [Object] $Xaml
        ConsoleController()
        {
            $This.Console = New-FEConsole
            $This.Xaml    = [XamlWindow][TestUI]::Content

            $This.StageXaml()
        }
        Initialize()
        {
            If ($This.Console.Start.Set -eq 0)
            {
                $This.Console.Initialize()
                $This.Push()
            }
        }
        Finalize()
        {
            If ($This.Console.End.Set -eq 0)
            {
                $This.Console.Finalize()
                $This.Push()
            }
        }
        Update([Int32]$State,[String]$Status)
        {
            $This.Console.Update($State,$Status)
            $This.Push()
        }
        Push()
        {
            $This.Xaml.IO.Output.Items.Add($This.Console.Output[-1])
            $This.Xaml.IO.Output.ScrollIntoView($This.Xaml.IO.Output.Items[-1])
        }
        StageXaml()
        {
            $Ctrl = $This

            $Ctrl.Xaml.IO.Initialize.Add_Click(
            {
                $Ctrl.Initialize()
                $Ctrl.Xaml.IO.Initialize.IsEnabled = 0
                $Ctrl.Xaml.IO.Finalize.IsEnabled   = 1
                $Ctrl.Xaml.IO.Action.IsEnabled     = 1
                $Ctrl.Xaml.IO.StartTime.Text       = $Ctrl.Console.Start.Time.ToString()
            })

            $Ctrl.Xaml.IO.Finalize.Add_Click(
            {
                $Ctrl.Finalize()
                $Ctrl.Xaml.IO.Finalize.IsEnabled   = 0
                $Ctrl.Xaml.IO.Action.IsEnabled     = 0
                $Ctrl.Xaml.IO.EndTime.Text         = $Ctrl.Console.End.Time.ToString()
                $Ctrl.Xaml.IO.SpanTime.Text        = $Ctrl.Console.Span
            })

            $Ctrl.Xaml.IO.Action.Add_Click(
            {
                ForEach ($X in 0..(Get-Random -Minimum 1 -Maximum 100))
                {
                    $Ctrl.Update(0,"Testing [~] Console output[$X]")
                }

                
            })

            # 0 Initialize Button   System.Windows.Controls.Button: Initialize
            # 1 StartTime  TextBox  System.Windows.Controls.TextBox
            # 2 Finalize   Button   System.Windows.Controls.Button: Finalize
            # 3 EndTime    TextBox  System.Windows.Controls.TextBox
            # 4 SpanTime   TextBox  System.Windows.Controls.TextBox
            # 5 Output     DataGrid System.Windows.Controls.DataGrid Items.Count:0
        }
    }

    $Ctrl = [ConsoleController]::New()
    $Ctrl.Xaml.Invoke()
}
