<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 17:47:02                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PsdLogGUI.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : For parsing the PowerShell Deployment log items into GUI objects
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-PsdLogGUI
{
    Param ($Path)

    Class PsdLogItem
    {
        [UInt32]     $Index
        [String]   $Message
        [String]      $Time
        [String]      $Date
        [String] $Component
        [String]   $Context
        [String]      $Type
        [String]    $Thread
        [String]      $File
        PsdLogItem([UInt32]$Index,[String]$Line)
        {
            $InputObject      = $Line -Replace "(\>\<)", ">`n<" -Split "`n"
            $This.Index       = $Index
            $This.Message     = $InputObject[0] -Replace "((\<!\[LOG\[)|(\]LOG\]!\>))",""
            $Body             = ($InputObject[1] -Replace "(\<|\>)", "" -Replace "(\`" )", "`"`n").Split("`n")
            $This.Time        = $Body[0] -Replace "(^time\=|\`")" ,""
            $This.Date        = $Body[1] -Replace "(^date\=|\`")" ,""
            $This.Component   = $Body[2] -Replace "(^component\=|\`")" ,""
            $This.Context     = $Body[3] -Replace "(^context\=|\`")" ,""
            $This.Type        = $Body[4] -Replace "(^type\=|\`")" ,""
            $This.Thread      = $Body[5] -Replace "(^thread\=|\`")" ,""
            $This.File        = $Body[6] -Replace "(^file\=|\`")" ,""
        }
        [String] ToString()
        {
            Return @( "{0}/{1}" -f $This.Index, $This.Component )
        }
    }
    
    Class PsdLog
    {
        [Object] $Output
        PsdLog([UInt32]$Index,[String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
    
            $This.Output = @( )
            $Swap = (Get-Content $Path) -join '' -Replace "><!",">`n<!" -Split "`n"
            ForEach ($Line in $Swap)
            {
                $This.Output += $This.Line($This.Output.Count,$Line)
            }
        }
        [Object] Line([Uint32]$Index,[String]$Line)
        {
            Return [PsdLogItem]::New($Index,$Line)
        }
    }

    Class PsdProcedure
    {
        [Object] $Output
        PsdProcedure([String]$Path)
        {
            $Swap        = @( )
            $Last        = @( )
            $This.Output = @( )

            # Fill up swap
            ForEach ($Item in Get-Childitem $Path *.Log)
            {
                Write-Host "Loading [~] ($($Item.Name))"
                $File = [PsdLog]::New($Swap.Count,$Item.FullName).Output
                ForEach ($Item in $File)
                {
                    $Swap += $Item
                }
            }

            # Rerank and filtrate
            Write-Host "Processing [~] ($($Swap.Count)) *.log lines(s), removing duplicates and reranking"
            $Swap = $Swap | Sort-Object Time | Select-Object Time, Date, Component, Message -Unique

            Write-Host "Complete [+] ($($Swap.Count)) *.log lines"
            $This.Output = $Swap
        }
    }

    If (!(Test-Path $Path))
    {
        Throw "Invalid path"
    }
    Else
    {
        [PsdProcedure]::New($Path)
    }
}

Function Publish-PsdLog
{
    Param([String]$Path)

    Class EntryList
    {
        [UInt32]   $Index
        [String]    $Path
        [Object] $Content
        EntryList([UInt32]$Index,[String]$Path)
        {
            $This.Index = $Index
            $This.Path  = $Path
        }
        SetContent([Object[]]$Content)
        {
            $This.Content = $Content
        }
    }

    $Stack = @( )
    # Get extract path
    ForEach ($Directory in Get-ChildItem $Path | ? PSIsContainer | ? Name -match "\d{4}_\d{4}")
    {
        Write-Host "[=] ($($Directory.Fullname))"
        ForEach ($Entry in Get-ChildItem $Directory.FullName)
        {
            "[+] $($Entry.Fullname)"
            $Stack += Get-PsdLog $Entry.Fullname
        }
    }

    $List = @( )
    ForEach ($Item in Get-ChildItem $Path -Recurse | ? FullName -match "\d{4}_\d{4}\\\d{4}$" | % FullName )
    {
        $List += [EntryList]::New($List.Count,$Item)
    }

    ForEach ($X in 0..($List.Count-1))
    {
        $List[$X].Content = @($Stack[$X].Output)
    }

    $List
}

Function Show-PsdLog
{
    Class DGList
    {
        [String]$Name
        [Object]$Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = @($Value;$Value -join ", ")[$Value.Count -gt 1]
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

    Class PsdLogsXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="PsdLogs"',
        '        Height="450"',
        '        Width="800">',
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
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="40"/>',
        '            <RowDefinition Height="40"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <Grid Grid.Row="0">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="150"/>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="150"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0" Content="Browse" Name="Browse"/>',
        '            <TextBox Grid.Column="1" Name="Path"/>',
        '            <Button Grid.Column="2" Content="Select" Name="Select"/>',
        '        </Grid>',
        '        <ComboBox Grid.Row="1" SelectedIndex="0" Name="List"/>',
        '        <DataGrid Grid.Row="2" Name="Output">',
        '            <DataGrid.Columns>',
        '                <DataGridTextColumn Header="Time"',
        '                                    Binding="{Binding Time}"',
        '                                    Width="120"/>',
        '                <DataGridTextColumn Header="Date"',
        '                                    Binding="{Binding Date}"',
        '                                    Width="120"/>',
        '                <DataGridTextColumn Header="Component"',
        '                                    Binding="{Binding Component}"',
        '                                    Width="120"/>',
        '                <DataGridTextColumn Header="Message"',
        '                                    Binding="{Binding Message}"',
        '                                    Width="*"/>',
        '            </DataGrid.Columns>',
        '        </DataGrid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class PsdLogsController
    {
        [Object] $Xaml
        [Object] $List
        PsdLogsController()
        {
            $This.Xaml = [XamlWindow][PsdLogsXaml]::Content
            $This.List = @( )
        }
        StageXaml()
        {
            $Ctrl = $This

            $Ctrl.Xaml.IO.List.Add_SelectionChanged(
            {
                If ($Xaml.IO.List.SelectedIndex -gt -1)
                {
                    $Xaml.IO.Output.Items.Clear()
                    ForEach ($Item in $Main.List[$Xaml.IO.List.SelectedIndex].Content)
                    {
                        $Xaml.IO.Output.Items.Add($Item)
                    }
                }
            })
            
            $Ctrl.Xaml.IO.Browse.Add_Click(
            {
                $Item                   = New-Object System.Windows.Forms.FolderBrowserDialog
                $Item.ShowDialog()
                
                If (!$Item.SelectedPath)
                {
                    $Item.SelectedPath  = ""
                }
        
                $Ctrl.Xaml.IO.Path.Text = $Item.SelectedPath
            })
            
            $Ctrl.Xaml.IO.Select.Add_Click(
            {
                Switch (Test-Path $Ctrl.Xaml.IO.Path.Text)
                {
                    $True
                    {
                        Try
                        {
                            $Ctrl.GetList($Ctrl.Xaml.IO.Path.Text)
                        }
                        Catch
                        {
                            Throw "Unable to retrieve the logs from the specified path"
                        }
                    }
        
                    $False
                    {
                        [System.Windows.MessageBox]::Show("Invalid path","Error")
                    }
                }
        
                If ($Ctrl.List)
                {
                    $Ctrl.Xaml.IO.List.Items.Clear()

                    ForEach ($Item in $Ctrl.List)
                    {
                        $Ctrl.Xaml.IO.List.Items.Add($Item.Path)
                    }
                }
            })
        }
        Invoke()
        {
            $This.Xaml.Invoke()
        }
        GetList([String]$Path)
        {
            $This.List = Publish-PsdLog $Path
        }
    }

    $Ctrl = [PsdLogsController]::New()
    $Ctrl.StageXaml()
    $Ctrl.Invoke()
}
