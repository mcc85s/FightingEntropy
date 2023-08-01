<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-07-31 23:34:37                                                                  //
 \\==================================================================================================// 

    FileName   : Invoke-ShoppingMaul.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For managing Michael C. "<|3FG20K>" Cook's [Quake III] mapping portfolio
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-07-30
    Modified   : 2023-07-31
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
.Example
#>

Function Invoke-ShoppingMaul
{

    # // ======================================
    # // | Represents a single news post/item |
    # // ======================================

    Class NewsEntryItem
    {
        [UInt32]         $Index
        Hidden [DateTime] $Real
        [String]          $Date
        [String]         $Title
        [String]       $Content
        NewsEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Content)
        {
            $This.Index   = $Index
            $This.Real    = [DateTime]$Date
            $This.Date    = $Date
            $This.Title   = $Title
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.NewsEntry[Item]>"
        }
    }

    # // =============================================
    # // | Represents a list of all news posts/items |
    # // =============================================

    Class NewsEntryList
    {
        [String] $Path
        [Object] $Output
        NewsEntryList([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewsEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Content)
        {
            Return [NewsEntryItem]::New($Index,$Date,$Title,$Content)
        }
        Add([String]$Date,[String]$Title,[String]$Content)
        {
            $This.Output += $This.NewsEntryItem($This.Output.Count,$Date,$Title,$Content)
        }
        Export([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            $Item    = $This.Output[$Index]
            $Target  = "{0}\{1}.txt" -f $This.Path, $Item.Real.ToString("yyyyMMdd")
            $Content = $Item | ConvertTo-Json

            [System.IO.File]::WriteAllLines($Target,$Content)
        }
        ExportAll()
        {
            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Export($X)
            }
        }
        Import([String]$Fullname)
        {
            If ($Fullname -notmatch ".+\.txt")
            {
                Throw "Invalid file type"
            }

            $Content = [System.IO.File]::ReadAllLines($Fullname) | ConvertFrom-Json

            $This.Add($Content.Date,$Content.Title,$Content.Content)

            $This.Rerank()
        }
        ImportAll()
        {
            $This.Clear()

            $List = Get-ChildItem $This.Path *.txt

            For ($X = 0; $X -lt $List.Count; $X ++)
            {
                $This.Import($List[$X].Fullname)
            }
        }
        Rerank()
        {
            $This.Output     = @($This.Output | Sort-Object Real -Descending)

            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Output[$X].Index = $X
            }
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.NewsEntry[List]>"
        }
    }

    # // =======================
    # // | Enumerates all maps |
    # // =======================

    Enum MapEntryName
    {
        _bfgdm1
        _bfgdm2
        _bfgdm3
        _bfgdm4
        _bfgdm3a
        _20kdm1
        _hellra3map1
        _20kdm2
        _20kctf1
        _20kdm3
        _20230717
    }

    # // ===================================================
    # // | Provides a map description and other properties |
    # // ===================================================

    Class MapEntryDescription
    {
        [String[]] $Content
        [String]      $Load
        [String]     $Modes
        [String]    $Custom
        [String]       $Mod
        MapEntryDescription([String[]]$Content,[String]$Load,[String]$Modes,[String]$Custom,[String]$Mod)
        {
            $This.Content = $Content
            $This.Load    = $Load
            $This.Modes   = $Modes
            $This.Custom  = $Custom
            $This.Mod     = $Mod
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }

    # // ===================================================================
    # // | Effectively links the code behind to individual map screenshots |
    # // ===================================================================

    Class MapEntryImageItem
    {
        [UInt32] $Index
        [String] $Name
        [String] $Fullname
        MapEntryImageItem([UInt32]$Index,[String]$Fullname)
        {
            $This.Index    = $Index
            $This.Name     = Split-Path -Leaf $Fullname
            $This.Fullname = $Fullname
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // =====================================================
    # // | Scours and collects all available map screenshots |
    # // =====================================================

    Class MapEntryImageList
    {
        Hidden [String] $Path
        [Object]      $Output
        MapEntryImageList([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] MapEntryImageItem([UInt32]$Index,[String]$Fullname)
        {
            Return [MapEntryImageItem]::New($Index,$Fullname)
        }
        Add([String]$Fullname)
        {
            $This.Output += $This.MapEntryImageItem($This.Output.Count,$Fullname)
        }
        Import()
        {
            $List = Get-ChildItem $This.Path *.jpg

            For ($X = 0; $X -lt $List.Count; $X ++)
            {
                $This.Add($List[$X].Fullname)
            }
        }
        Reindex()
        {
            ForEach ($Item in $This.Output)
            {
                $Name = "{0}\{1:d2}.jpg" -f $This.Path, $Item.Index
                [System.IO.File]::Move($Item.Fullname,$Name)
            }
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Output.Count, (Split-Path -Leaf $This.Path)
        }
    }

    # // =================================================================
    # // | Acts as a controller for (creation/export/import) map entries |
    # // =================================================================

    Class MapEntryItem
    {
        [UInt32]         $Index
        [String]          $Name
        [String]         $Title
        Hidden [DateTime] $Date
        [String]         $Build
        [TimeSpan]        $Time
        [String]           $Age
        Hidden [String]   $Path
        [Object]   $Description
        Hidden [Object] $Readme
        [Object]       $Archive
        [Object]         $Image
        MapEntryItem([UInt32]$Index,[String]$Name)
        {
            $This.Index       = [UInt32][MapEntryName]::$Name
            $This.Name        = $Name.TrimStart("_")
        }
        MapEntryItem([Object]$Item)
        {
            $This.Index       = $Item.Index
            $This.Name        = $Item.Name

            $This.SetDateTitle($Item.Date,$Item.Title)
            $This.SetPath($Item.Path)

            $Info             = $Item.Description
            $This.SetDescription($Info.Content,$Info.Load,$Info.Modes,$Info.Custom,$Info.Mod)
        }
        SetDateTitle([String]$Date,[String]$Title)
        {
            $This.Title       = $Title
            $This.Date        = $Date
            $This.Build       = $This.Date.ToString("MM/dd/yyyy HHmm")
            $This.Time        = [TimeSpan]([DateTime]::Now-$This.Date)
            $This.GetAge()
        }
        SetPath([String]$Fullname)
        {
            $This.Path        = $Fullname
            $This.Image       = $This.MapEntryImageList($Fullname)
            $This.Image.Import()

            ForEach ($Item in Get-ChildItem $Fullname | ? Name -match ".+\.(pk3|txt)")
            {
                Switch ($Item.Extension)
                {
                    .pk3 { $This.SetArchive($Item.Fullname) }
                    .txt { $This.SetReadme($Item.Fullname)  }
                }
            }

            If (!$This.Readme)
            {
                $This.Readme  = "N/A"
            }
        }
        SetDescription([String[]]$Content,[String]$Load,[String]$Modes,[String]$Custom,[String]$Mod)
        {
            $This.Description = $This.MapEntryDescription($Content,$Load,$Modes,$Custom,$Mod)
        }
        SetArchive([String]$Fullname)
        {
            $This.Archive     = $Fullname
        }
        SetReadme([String]$Fullname)
        {
            $This.Readme      = [System.IO.File]::ReadAllLines($Fullname)
        }
        [Object] MapEntryDescription([String[]]$Content,[String]$Load,[String]$Modes,[String]$Custom,[String]$Mod)
        {
            Return [MapEntryDescription]::New($Content,$Load,$Modes,$Custom,$Mod)
        }
        [Object] MapEntryImageList([String]$Path)
        {
            Return [MapEntryImageList]::New($Path)
        }
        GetAge()
        {
            # Actual floating point value of a [year] in [days]
            $Year     = 365.2425  

            # Actual floating point value of a [month] in [days]
            $Month    = 30.436875 

            $Years    = $Null
            $Months   = $Null
            $Days     = $Null

            # Year -> Returns remainder
            $RemYear  = $This.Time.Days % $Year 

            # Year -> Removes remainder, then divides
            $Years    = ($This.Time.Days-$RemYear)/$Year

            # Month -> Returns remainder
            $RemMonth = $RemYear % $Month

            If ($RemMonth -match "NaN")
            {
                $Months = 0
            }
            Else
            {
                $Months = ($RemYear-$RemMonth)/$Month
                $Days   = [Math]::Round(($RemYear-($Months*$Month)))
            }

            $This.Age    = "{0}y {1}m {2}d {3}h {4}m {5}s" -f $Years, 
                            $Months, 
                            $Days,
                            $This.Time.Hours,
                            $This.Time.Minutes,
                            $This.Time.Seconds
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Name, $This.Title
        }
    }

    # // ======================================
    # // | Controls all of the available maps |
    # // ======================================

    Class MapEntryList
    {
        [String] $Path
        [Object] $Output
        MapEntryList([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] MapEntryItem([UInt32]$Index,[String]$Name)
        {
            Return [MapEntryItem]::New($Index,$Name)
        }
        [Object] MapEntryItem([Object]$Item)
        {
            Return [MapEntryItem]::New($Item)
        }
        [Object] New([String]$Name)
        {
            Return $This.MapEntryItem($This.Output.Count,$Name)
        }
        Export([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            $Item    = $This.Output[$Index]
            $Target  = "{0}\{1}.txt" -f $This.Path, $Item.Date.ToString("yyyyMMdd")
            $Content = $Item | ConvertTo-Json

            [System.IO.File]::WriteAllLines($Target,$Content)
        }
        ExportAll()
        {
            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Export($X)
            }
        }
        Import([String]$Fullname)
        {
            If ($Fullname -notmatch ".+\.txt")
            {
                Throw "Invalid file type"
            }

            $Content      = [System.IO.File]::ReadAllLines($Fullname) | ConvertFrom-Json

            $This.Output += $This.MapEntryItem($Content)

            $This.Rerank()
        }
        ImportAll()
        {
            $This.Clear()

            $List = Get-ChildItem $This.Path *.txt

            For ($X = 0; $X -lt $List.Count; $X ++)
            {
                $This.Import($List[$X].Fullname)
            }
        }
        Refresh()
        {
            $This.Clear()

            $List = Get-ChildItem $This.Path -Directory

            ForEach ($Name in [System.Enum]::GetNames([MapEntryName]))
            {
                $Item = $This.New($Name)
                Switch ($Item.Name)
                {
                    bfgdm1      { $Item.SetDateTitle("05/28/2000 09:07","Crossfire")                     }
                    bfgdm2      { $Item.SetDateTitle("08/20/2000 14:42","Breakthru")                     }
                    bfgdm3      { $Item.SetDateTitle("04/06/2001 18:01","Space Station 1138 (Original)") }
                    bfgdm4      { $Item.SetDateTitle("05/04/2001 18:37","Suspended Animation")           }
                    bfgdm3a     { $Item.SetDateTitle("05/05/2001 15:43","Space Station 1138 (Color)")    }
                    20kdm1      { $Item.SetDateTitle("07/20/2001 23:52","Tempered Graveyard")            }
                    hellra3map1 { $Item.SetDateTitle("07/26/2001 15:13","Dude, You Can Go To Hell")      }
                    20kdm2      { $Item.SetDateTitle("02/01/2002 23:16","Return to Castle: Quake")       }
                    20kctf1     { $Item.SetDateTitle("03/08/2003 05:12","Out of My Head")                }
                    20kdm3      { $Item.SetDateTitle("09/09/2005 00:17","Insane Products")               }
                    20230717    { $Item.SetDateTitle("07/17/2023 20:26","07/17/2023 Test Map")           }
                }

                If ($Item.Name -in $List.Name)
                {
                    $List | ? Name -eq $Item.Name | % { $Item.SetPath($_.Fullname) }
                }

                $This.Output += $Item
            }
        }
        ReindexAll()
        {
            ForEach ($Item in $This.Output)
            {
                $Item.Reindex()
            }
        }
        Rerank()
        {
            $This.Output     = @($This.Output | Sort-Object Date)

            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Output[$X].Index = $X
            }
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.MapEntry[List]>"
        }
    }

    # // ===========================================================
    # // | Provides a description and other properties for a video |
    # // ===========================================================

    Class VideoEntryItem
    {
        [UInt32]         $Index
        Hidden [DateTime] $Real
        [String]          $Date
        [String]         $Title
        [String]      $Resource
        Hidden [String]     $Id
        [TimeSpan]    $Duration
        [String]     $Thumbnail
        [String[]] $Description
        VideoEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Resource,[String]$Duration)
        {
            $This.Index    = $Index
            $This.Real     = [DateTime]$Date
            $This.Date     = $Date
            $This.Title    = $Title
            $This.SetId($Resource)
            $This.Duration = [TimeSpan]$Duration
        }
        VideoEntryItem([Object]$Item)
        {
            $This.Index    = $Item.Index
            $This.Real     = [DateTime]$Item.Date
            $This.Date     = $Item.Date
            $This.Title    = $Item.Title
            $This.SetId($Item.Resource)
            $This.Duration = [TimeSpan]::FromSeconds($Item.Duration.TotalSeconds)

            If ($Item.Thumbnail)
            {
                $This.SetThumbnail($Item.Thumbnail)
            }

            If ($Item.Description)
            {
                $This.SetDescription($Item.Description)
            }
        }
        SetId([String]$Resource)
        {
            $This.Resource = $Resource
            $This.Id       = Split-Path -Leaf $Resource
        }
        SetThumbnail([String]$Fullname)
        {
            $This.Thumbnail = $Fullname
        }
        SetDescription([String[]]$Description)
        {
            $This.Description = $Description
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.VideoEntry[Item]>"
        }
    }

    # // ===================================================================
    # // | Acts as a controller for (creation/export/import) video entries |
    # // ===================================================================

    Class VideoEntryList
    {
        [String] $Path
        [Object] $Output
        VideoEntryList([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VideoEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Resource,[String]$Duration)
        {
            Return [VideoEntryItem]::New($Index,$Date,$Title,$Resource,$Duration)
        }
        [Object] VideoEntryItem([Object]$Item)
        {
            Return [VideoEntryItem]::New($Item)
        }
        Add([String]$Date,[String]$Title,[String]$Resource,[String]$Duration)
        {
            $This.Output += $This.VideoEntryItem($This.Output.Count,$Date,$Title,$Resource,$Duration)
        }
        Export([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            $Item    = $This.Output[$Index]
            $Target  = "{0}\{1}-{2}.txt" -f $This.Path, ([DateTime]$Item.Date).ToString("yyyyMMdd"), $Item.Id
            $Content = $Item | ConvertTo-Json

            [System.IO.File]::WriteAllLines($Target,$Content)
        }
        ExportAll()
        {
            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Export($X)
            }
        }
        Import([String]$Fullname)
        {
            If ($Fullname -notmatch ".+\.txt")
            {
                Throw "Invalid file type"
            }

            $Content      = [System.IO.File]::ReadAllLines($Fullname) | ConvertFrom-Json

            $This.Output += $This.VideoEntryItem($Content)

            $This.Rerank()
        }
        ImportAll()
        {
            $This.Clear()

            $List = Get-ChildItem $This.Path *.txt

            For ($X = 0; $X -lt $List.Count; $X ++)
            {
                $This.Import($List[$X].Fullname)
            }
        }
        Rerank()
        {
            $This.Output     = @($This.Output | Sort-Object Real -Descending)

            For ($X = 0; $X -lt $This.Output.Count; $X ++)
            {
                $This.Output[$X].Index = $X
            }
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.VideoEntry[List]>"
        }
    }

    # // ===================================================================
    # // | Contains (access+control) over a particular named Xaml property |
    # // ===================================================================

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

    # // =========================================================================
    # // | Controls the (Xaml+Window) objects and various development properties |
    # // =========================================================================

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
            Return "<FEModule.XamlWindow[ShoppingMaulXaml]>"
        }
    }

    # // ======================================================================================
    # // | A chunk of Xaml that was chiseled into granite, and then realized in Visual Studio |
    # // ======================================================================================

    Class ShoppingMaulXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="&lt;|3FG20K&gt;&apos;s Shopping Maul"',
        '        Height="680"',
        '        Width="800"',
        '        Topmost="True"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen"',
        '        FontFamily="Consolas"',
        '        Background="LightYellow">',
        '    <Window.Resources>',
        '        <Style x:Key="DropShadow">',
        '        <Setter Property="TextBlock.Effect">',
        '            <Setter.Value>',
        '                <DropShadowEffect ShadowDepth="1"/>',
        '            </Setter.Value>',
        '        </Setter>',
        '    </Style>',
        '    <Style TargetType="ToolTip">',
        '        <Setter Property="Background" Value="#000000"/>',
        '        <Setter Property="Foreground" Value="#66D066"/>',
        '    </Style>',
        '    <Style TargetType="TabItem">',
        '        <Setter Property="Template">',
        '            <Setter.Value>',
        '                <ControlTemplate TargetType="TabItem">',
        '                    <Border Name="Border"',
        '                                BorderThickness="2"',
        '                                BorderBrush="Black"',
        '                                CornerRadius="5"',
        '                                Margin="2">',
        '                        <ContentPresenter x:Name="ContentSite"',
        '                                              VerticalAlignment="Center"',
        '                                              HorizontalAlignment="Right"',
        '                                              ContentSource="Header"',
        '                                              Margin="5"/>',
        '                    </Border>',
        '                    <ControlTemplate.Triggers>',
        '                        <Trigger Property="IsSelected"',
        '                                     Value="True">',
        '                            <Setter TargetName="Border"',
        '                                        Property="Background"',
        '                                        Value="#4444FF"/>',
        '                            <Setter Property="Foreground"',
        '                                        Value="#FFFFFF"/>',
        '                        </Trigger>',
        '                        <Trigger Property="IsSelected"',
        '                                     Value="False">',
        '                            <Setter TargetName="Border"',
        '                                        Property="Background"',
        '                                        Value="#DFFFBA"/>',
        '                            <Setter Property="Foreground"',
        '                                        Value="#000000"/>',
        '                        </Trigger>',
        '                    </ControlTemplate.Triggers>',
        '                </ControlTemplate>',
        '            </Setter.Value>',
        '        </Setter>',
        '    </Style>',
        '    <Style TargetType="Button">',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="Padding" Value="5"/>',
        '        <Setter Property="FontWeight" Value="Heavy"/>',
        '        <Setter Property="Foreground" Value="Black"/>',
        '        <Setter Property="Background" Value="#DFFFBA"/>',
        '        <Setter Property="BorderThickness" Value="2"/>',
        '        <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="5"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style x:Key="DGCombo" TargetType="ComboBox">',
        '        <Setter Property="Margin" Value="0"/>',
        '        <Setter Property="Padding" Value="2"/>',
        '        <Setter Property="Height" Value="18"/>',
        '        <Setter Property="FontSize" Value="10"/>',
        '        <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '    </Style>',
        '    <Style TargetType="{x:Type TextBox}" BasedOn="{StaticResource DropShadow}">',
        '        <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '        <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '        <Setter Property="Height" Value="24"/>',
        '        <Setter Property="Margin" Value="4"/>',
        '        <Setter Property="FontSize" Value="12"/>',
        '        <Setter Property="Foreground" Value="#000000"/>',
        '        <Setter Property="TextWrapping" Value="Wrap"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="2"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '        <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '        <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '        <Setter Property="Margin" Value="4"/>',
        '        <Setter Property="Height" Value="24"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="2"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style TargetType="ComboBox">',
        '        <Setter Property="Height" Value="24"/>',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="FontSize" Value="12"/>',
        '        <Setter Property="FontWeight" Value="Normal"/>',
        '    </Style>',
        '    <Style TargetType="CheckBox">',
        '        <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '    </Style>',
        '    <Style TargetType="DataGrid">',
        '        <Setter Property="Margin"',
        '                    Value="5"/>',
        '        <Setter Property="AutoGenerateColumns"',
        '                    Value="False"/>',
        '        <Setter Property="AlternationCount"',
        '                    Value="2"/>',
        '        <Setter Property="HeadersVisibility"',
        '                    Value="Column"/>',
        '        <Setter Property="CanUserResizeRows"',
        '                    Value="False"/>',
        '        <Setter Property="CanUserAddRows"',
        '                    Value="False"/>',
        '        <Setter Property="IsReadOnly"',
        '                    Value="True"/>',
        '        <Setter Property="IsTabStop"',
        '                    Value="True"/>',
        '        <Setter Property="IsTextSearchEnabled"',
        '                    Value="True"/>',
        '        <Setter Property="SelectionMode"',
        '                    Value="Single"/>',
        '        <Setter Property="ScrollViewer.CanContentScroll"',
        '                    Value="True"/>',
        '        <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '        <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '    </Style>',
        '    <Style TargetType="DataGridRow">',
        '        <Setter Property="VerticalAlignment"',
        '                    Value="Center"/>',
        '        <Setter Property="VerticalContentAlignment"',
        '                    Value="Center"/>',
        '        <Setter Property="TextBlock.VerticalAlignment"',
        '                    Value="Center"/>',
        '        <Setter Property="Height" Value="20"/>',
        '        <Setter Property="FontSize" Value="12"/>',
        '        <Style.Triggers>',
        '            <Trigger Property="AlternationIndex"',
        '                         Value="0">',
        '                <Setter Property="Background"',
        '                            Value="#F8FFFFFF"/>',
        '            </Trigger>',
        '            <Trigger Property="AlternationIndex"',
        '                         Value="1">',
        '                <Setter Property="Background"',
        '                            Value="#FFF8FFFF"/>',
        '            </Trigger>',
        '            <Trigger Property="AlternationIndex"',
        '                         Value="2">',
        '                <Setter Property="Background"',
        '                            Value="#FFFFF8FF"/>',
        '            </Trigger>',
        '            <Trigger Property="AlternationIndex"',
        '                         Value="3">',
        '                <Setter Property="Background"',
        '                            Value="#F8F8F8FF"/>',
        '            </Trigger>',
        '            <Trigger Property="AlternationIndex"',
        '                         Value="4">',
        '                <Setter Property="Background"',
        '                            Value="#F8FFF8FF"/>',
        '            </Trigger>',
        '            <Trigger Property="IsMouseOver" Value="True">',
        '                <Setter Property="ToolTip">',
        '                    <Setter.Value>',
        '                        <TextBlock TextWrapping="Wrap"',
        '                                       Width="400"',
        '                                       Background="#000000"',
        '                                       Foreground="#00FF00"/>',
        '                    </Setter.Value>',
        '                </Setter>',
        '                <Setter Property="ToolTipService.ShowDuration"',
        '                            Value="360000000"/>',
        '            </Trigger>',
        '        </Style.Triggers>',
        '    </Style>',
        '    <Style TargetType="DataGridColumnHeader">',
        '        <Setter Property="FontSize"   Value="10"/>',
        '        <Setter Property="FontWeight" Value="Normal"/>',
        '    </Style>',
        '    <Style TargetType="TabControl">',
        '        <Setter Property="TabStripPlacement" Value="Top"/>',
        '        <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '        <Setter Property="Background" Value="LightYellow"/>',
        '    </Style>',
        '    <Style TargetType="GroupBox">',
        '        <Setter Property="Foreground" Value="Black"/>',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="FontSize" Value="12"/>',
        '        <Setter Property="FontWeight" Value="Normal"/>',
        '    </Style>',
        '    <Style TargetType="Label">',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="FontWeight" Value="Bold"/>',
        '        <Setter Property="Background" Value="Black"/>',
        '        <Setter Property="Foreground" Value="White"/>',
        '        <Setter Property="BorderBrush" Value="Gray"/>',
        '        <Setter Property="BorderThickness" Value="2"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="5"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style x:Key="LabelGray" TargetType="Label">',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="FontWeight" Value="Bold"/>',
        '        <Setter Property="Background" Value="DarkSlateGray"/>',
        '        <Setter Property="Foreground" Value="White"/>',
        '        <Setter Property="BorderBrush" Value="Black"/>',
        '        <Setter Property="BorderThickness" Value="2"/>',
        '        <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="5"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style x:Key="LabelRed" TargetType="Label">',
        '        <Setter Property="Margin" Value="5"/>',
        '        <Setter Property="FontWeight" Value="Bold"/>',
        '        <Setter Property="Background" Value="IndianRed"/>',
        '        <Setter Property="Foreground" Value="White"/>',
        '        <Setter Property="BorderBrush" Value="Black"/>',
        '        <Setter Property="BorderThickness" Value="2"/>',
        '        <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '        <Style.Resources>',
        '            <Style TargetType="Border">',
        '                <Setter Property="CornerRadius" Value="5"/>',
        '            </Style>',
        '        </Style.Resources>',
        '    </Style>',
        '    <Style x:Key="Line" TargetType="Border">',
        '        <Setter Property="Background" Value="Black"/>',
        '        <Setter Property="BorderThickness" Value="0"/>',
        '        <Setter Property="Margin" Value="4"/>',
        '    </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="80"/>',
        '            <RowDefinition Height="*"/>',
        '        </Grid.RowDefinitions>',
        '        <Image Source="C:\ShoppingMaul\graphics\banner.jpg"/>',
        '        <TabControl Grid.Row="1">',
        '            <TabItem Header="News">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Content="[Entry]:"/>',
        '                        <DataGrid Grid.Row="1"',
        '                                  Name="NewsList"',
        '                                  HeadersVisibility="None"',
        '                                  HorizontalScrollBarVisibility="Hidden">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Title}"',
        '                                                               TextWrapping="Wrap"',
        '                                                               FontFamily="Consolas"',
        '                                                               Background="#000000"',
        '                                                               Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Date"',
        '                                                    Binding="{Binding Date}"',
        '                                                    Width="100"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Column="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <TextBox Grid.Row="0"',
        '                                     Name="NewsTitle"/>',
        '                        <TextBox Grid.Row="1"',
        '                                 Name="NewsContent"',
        '                                 Height="470"',
        '                                 IsReadOnly="True"',
        '                                 TextWrapping="Wrap"',
        '                                 VerticalAlignment="Top"',
        '                                 VerticalContentAlignment="Top"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Maps">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Content="[Entry]:"/>',
        '                        <DataGrid Grid.Row="1"',
        '                                  Name="MapList"',
        '                                  HeadersVisibility="None"',
        '                                  HorizontalScrollBarVisibility="Hidden">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Title}"',
        '                                                               TextWrapping="Wrap"',
        '                                                               FontFamily="Consolas"',
        '                                                               Background="#000000"',
        '                                                               Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"',
        '                                                    Binding="{Binding Name}"',
        '                                                    Width="100"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Column="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="90"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Title]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="MapTitle"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Build]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="MapBuild"/>',
        '                            <Label Grid.Column="2"',
        '                                   Content="[Age]:"/>',
        '                            <TextBox Grid.Column="3"',
        '                                     Name="MapAge"/>',
        '                        </Grid>',
        '                        <TextBox Grid.Row="2"',
        '                                 Name="MapContent"',
        '                                 Height="80"',
        '                                 IsReadOnly="True"',
        '                                 TextWrapping="NoWrap"',
        '                                 VerticalAlignment="Top"',
        '                                 VerticalContentAlignment="Top"/>',
        '                        <Grid Grid.Row="3">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Load]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="MapLoad"/>',
        '                            <Label Grid.Column="2"',
        '                                   Content="[Modes]:"/>',
        '                            <TextBox Grid.Column="3"',
        '                                     Name="MapModes"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="4">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="300"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Custom]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="MapCustom"/>',
        '                            <Label Grid.Column="2"',
        '                                   Content="[Mod]:"/>',
        '                            <TextBox Grid.Column="3"',
        '                                     Name="MapMod"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="5">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Archive]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="MapArchive"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="6">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid Grid.Column="0"',
        '                                  Height="40"',
        '                                  VerticalAlignment="Top">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0"',
        '                                       Content="[Image]:"/>',
        '                                <ComboBox Grid.Column="1"',
        '                                          Name="MapImageList"/>',
        '                            </Grid>',
        '                            <Image Grid.Column="1"',
        '                                   Name="MapImage"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Videos">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Content="[Entry]:"/>',
        '                        <DataGrid Grid.Row="1"',
        '                                  Name="VideoList"',
        '                                  HeadersVisibility="None"',
        '                                  HorizontalScrollBarVisibility="Hidden">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Title}"',
        '                                                               TextWrapping="Wrap"',
        '                                                               FontFamily="Consolas"',
        '                                                               Background="#000000"',
        '                                                               Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Date"',
        '                                                    Binding="{Binding Date}"',
        '                                                    Width="100"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                    <Grid Grid.Column="1">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="90"/>',
        '                            <RowDefinition Height="350"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Title]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="VideoTitle"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="[Resource]:"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="VideoResource"/>',
        '                            <Label Grid.Column="2"',
        '                                   Content="[Duration]:"/>',
        '                            <TextBox Grid.Column="3"',
        '                                     Name="VideoDuration"/>',
        '                            <Button  Grid.Column="4"',
        '                                     Name="VideoLaunch"',
        '                                     Content="Launch"/>',
        '                        </Grid>',
        '                        <TextBox Grid.Row="2"',
        '                                 Name="VideoDescription"',
        '                                 Height="80"',
        '                                 Padding="5"',
        '                                 IsReadOnly="True"',
        '                                 TextWrapping="NoWrap"',
        '                                 VerticalAlignment="Top"',
        '                                 VerticalContentAlignment="Top"/>',
        '                        <Image Grid.Row="3"',
        '                               Name="VideoThumbnail"',
        '                               Margin="10"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="About">',
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
        '                                                <TextBlock Text="{Binding Author}"',
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
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    # // =========================================================================
    # // | Orchestrates all of the above classes like a symphony conductor would |
    # // =========================================================================

    Class ShoppingMaulController
    {
        [Object] $Module
        [String] $Base
        [Object] $Xaml
        [Object] $News
        [Object] $Maps
        [Object] $Videos
        [Object] $Contact
        ShoppingMaulController([String]$Base)
        {
            $This.Base    = $Base
            $This.Main()
        }
        ShoppingMaulController()
        {
            $This.Base    = "C:\ShoppingMaul"
            $This.Main()
        }
        Main()
        {
            If (![System.IO.Directory]::Exists($This.Base))
            {
                Throw "Invalid path"
            }

            $This.Module  = Get-FEModule -Mode 1
            $This.Xaml    = $This.New("Xaml")
            $This.News    = $This.New("News")
            $This.Maps    = $This.New("Maps")
            $This.Videos  = $This.New("Videos")
        }
        Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Module.Update($State,$Status)
            $Last = $This.Module.Console.Last()
            If ($This.Module.Mode -ne 0)
            {
                [Console]::WriteLine($Last.String)
            }
        }
        Error([UInt32]$State,[String]$Status)
        {
            $This.Module.Update($State,$Status)
            Throw $This.Module.Console.Last().Status
        }
        DumpConsole()
        {
            $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
            $This.Update(100,"[+] Dumping console: [$xPath]")
            $This.Console.Finalize()
            
            $Value = $This.Console.Output | % ToString
    
            [System.IO.File]::WriteAllLines($xPath,$Value)
        }
        [String] LogPath()
        {
            $xPath = $This.ProgramData()
    
            ForEach ($Folder in $This.Author(), "ShoppingMaul")
            {
                $xPath = $xPath, $Folder -join "\"
                If (![System.IO.Directory]::Exists($xPath))
                {
                    [System.IO.Directory]::CreateDirectory($xPath)
                }
            }
    
            Return $xPath
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [Object] New([String]$Name)
        {
            $Item = $Null

            Switch ($Name)
            {
                Xaml
                {
                    $This.Update(0,"Getting [~] Xaml Controller")
                    $Item = [XamlWindow][ShoppingMaulXaml]::Content
                }
                News
                {
                    $This.Update(0,"Getting [~] News List")
                    $Path = "{0}\news" -f $This.Base
                    $Item = [NewsEntryList]::New($Path)
                }
                Maps
                {
                    $This.Update(0,"Getting [~] Map List")
                    $Path = "{0}\maps" -f $This.Base
                    $Item = [MapEntryList]::New($Path)
                }
                Videos
                {
                    $This.Update(0,"Getting [~] Video List")
                    $Path = "{0}\videos" -f $This.Base
                    $Item = [VideoEntryList]::New($Path)
                }
                Default
                {
                    $This.Update(0,"Getting [~] <Null item...>")
                }
            }

            Return $Item
        }
        AddNews([String]$Date,[String]$Title,[String]$Content)
        {
            $This.News.Add($Date,$Title,$Content)
            $This.Update(1,"Added [+] <News: ($Date/$Title)>")
        }
        AddMap([String]$Date,[String]$Title,[String]$Image,[String]$Resource)  
        {
            $This.Maps.Add($Date,$Title,$Image,$Resource)
            $This.Update(1,"Added [+] <Map: ($Date/$Title)>")
        }
        AddVideo([String]$Date,[String]$Title,[String]$Resource,[String]$Duration)
        {
            $This.Videos.Add($Date,$Title,$Resource,$Duration)
            $This.Update(1,"Added [+] <Video: ($Date/$Title)>")
        }
        Reset([Object]$xSender,[Object]$List)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $List)
            {
                $xSender.Items.Add($Item)
            }
        }
        StageXaml()
        {
            # [Assign $This to $Ctrl]
            $Ctrl = $This

            # [News]
            $Ctrl.Reset($Ctrl.Xaml.IO.NewsList,$Ctrl.News.Output)

            $Ctrl.Xaml.IO.NewsList.Add_SelectionChanged(
            {
                $Index                         = $Ctrl.Xaml.IO.NewsList.SelectedIndex
                $Ctrl.Xaml.IO.NewsTitle.Text   = $Null
                $Ctrl.Xaml.IO.NewsContent.Text = $Null

                If ($Index -ne -1)
                {
                    $Item = $Ctrl.News.Output[$Index]
                    $Ctrl.Xaml.IO.NewsTitle.Text   = $Item.Title
                    $Ctrl.Xaml.IO.NewsContent.Text = $Item.Content
                }
            })

            # [Maps]
            $Ctrl.Reset($Ctrl.Xaml.IO.MapList,$Ctrl.Maps.Output)

            $Ctrl.Xaml.IO.MapList.Add_SelectionChanged(
            {
                $Index                         = $Ctrl.Xaml.IO.MapList.SelectedIndex
                $Ctrl.Xaml.IO.MapTitle.Text    = $Null
                $Ctrl.Xaml.IO.MapBuild.Text    = $Null
                $Ctrl.Xaml.IO.MapAge.Text      = $Null
                $Ctrl.Xaml.IO.MapContent.Text  = $Null
                $Ctrl.Xaml.IO.MapLoad.Text     = $Null
                $Ctrl.Xaml.IO.MapModes.Text    = $Null
                $Ctrl.Xaml.IO.MapCustom.Text   = $Null
                $Ctrl.Xaml.IO.MapMod.Text      = $Null
                $Ctrl.Xaml.IO.MapArchive.Text  = $Null

                $Ctrl.Reset($Ctrl.Xaml.IO.MapImageList,$Null)

                If ($Index -ne -1)
                {
                    $Item = $Ctrl.Maps.Output[$Index]
                    $Ctrl.Xaml.IO.MapTitle.Text     = $Item.Title
                    $Ctrl.Xaml.IO.MapBuild.Text     = $Item.Build
                    $Ctrl.Xaml.IO.MapAge.Text       = $Item.Age
                    $Ctrl.Xaml.IO.MapContent.Text   = $Item.Description.Content -join "`n"
                    $Ctrl.Xaml.IO.MapLoad.Text      = $Item.Description.Load
                    $Ctrl.Xaml.IO.MapModes.Text     = $Item.Description.Modes
                    $Ctrl.Xaml.IO.MapCustom.Text    = $Item.Description.Custom
                    $Ctrl.Xaml.IO.MapMod.Text       = $Item.Description.Mod
                    $Ctrl.Xaml.IO.MapArchive.Text   = $Item.Archive

                    $Ctrl.Reset($Ctrl.Xaml.IO.MapImageList,$Item.Image.Output.Index)
                    $Ctrl.Xaml.IO.MapImageList.SelectedIndex = 0
                }
            })

            $Ctrl.Xaml.IO.MapImageList.Add_SelectionChanged(
            {
                $Item      = $Ctrl.Maps.Output[$Ctrl.Xaml.IO.MapList.SelectedIndex]
                If ($Ctrl.Xaml.IO.MapImageList.SelectedIndex -ne -1)
                {
                    $Index = $Ctrl.Xaml.IO.MapImageList.SelectedIndex
                    $Ctrl.Xaml.IO.MapImage.Source = $Item.Image.Output[$Index].Fullname
                }
                Else
                {
                    $Ctrl.Xaml.IO.MapImage.Source = $Null
                }
            })

            # [Videos]
            $Ctrl.Reset($Ctrl.Xaml.IO.VideoList,$Ctrl.Videos.Output)

            $Ctrl.Xaml.IO.VideoList.Add_SelectionChanged(
            {
                $Index                              = $Ctrl.Xaml.IO.VideoList.SelectedIndex
                $Ctrl.Xaml.IO.VideoTitle.Text       = $Null
                $Ctrl.Xaml.IO.VideoResource.Text    = $Null
                $Ctrl.Xaml.IO.VideoDuration.Text    = $Null
                $Ctrl.Xaml.IO.VideoLaunch.IsEnabled = 0
                $Ctrl.Xaml.IO.VideoDescription.Text = $Null
                $Ctrl.Xaml.IO.VideoThumbnail.Source = $Null

                If ($Index -ne -1)
                {
                    $Item                               = $Ctrl.Videos.Output[$Index]
                    $Ctrl.Xaml.IO.VideoTitle.Text       = $Item.Title
                    $Ctrl.Xaml.IO.VideoResource.Text    = $Item.Resource
                    $Ctrl.Xaml.IO.VideoDuration.Text    = $Item.Duration
                    $Ctrl.Xaml.IO.VideoLaunch.IsEnabled = 1
                    $Ctrl.Xaml.IO.VideoDescription.Text = $Item.Description -join "`n"
                    $Ctrl.Xaml.IO.VideoThumbnail.Source = $Item.Thumbnail
                }
            })

            $Ctrl.Xaml.IO.VideoLaunch.Add_Click(
            {
                $Item = $Ctrl.Xaml.IO.VideoList.SelectedItem
                Start-Process $Item.Resource
            })

            # [About]
            $Ctrl.Reset($Ctrl.Xaml.IO.Module,$Ctrl.Module)
        }
        Invoke()
        {
            $This.Xaml.Invoke()
        }
        [String] ToString()
        {
            Return "<ShoppingMaul[Controller]>"
        }
    }

    # // ============================================================================
    # // | Returns the controller class with all of the embedded classes as methods |
    # // ============================================================================

    [ShoppingMaulController]::New()
}

<# [Instantiate the function]
    _______________________________
    | $Ctrl = Invoke-ShoppingMaul |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ...which would be the same as using:
    ___________________________________________
    | $Ctrl = [ShoppingMaulController]::New() |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ...if it were called within the [scope] of the [above function].
#>

$Ctrl = Invoke-ShoppingMaul

<# [News -> Commentary]

    ...gonna leave all of this stuff [commented], but here is a list of all of the [news entries]
    from the [Wayback Machine] under the URL [http://planetquake.com/bfg20k] prior to (2006/2007)
    because thats when the crawler began to fail.

    The following entries are all formatted in a way where they only take up a maximum number of
    characters across. I could use [TextWrapping] in order to keep everything formatted the way
    I would prefer. However, I could also use (methods/functions) that could subdivide words and
    provide (horizontal+veritcal) spacing so that the words don't extend beyond the edge of the
    window.
    
    However, I'm keeping things [relatively simple] so that I can [explain] what the [classes]
    and [methods] do, so [it is all spaced manually]. The following [comment block] extends 
    from (1596-2563), and the [instructions within the block] are [necessary] to build the
    information from [scratch].
#>

<# [News -> Create mode]

$Ctrl.AddNews("09/12/2005","End of summer (2005)",@"
With the summer of (2005) ending, and a decade halfway gone, I want to take a look back and reflect
upon the time that has passed ever so diligently. In doing so, I can remember being (15) years old
just drawing out maps on pieces of paper for [q2] and [q3], hoping that some of them may see the
light of day.

Indeed some of them have, where many of them have fallen through the cracks of reality unable to reach
out to players halfway around the world which make them say "this map rocks".
That should be the aim of any game developer.

It seems that people who make games these days just take advantage of hype, sell (200K) copies, and
then go home and buy a [Ferrari]. What happened to the jam packed games like [Super Mario Brothers],
[Road Rash], and [Warcraft 2]?

I'll tell you what happened, developers sold out.
I'll be the first to admit, I know people who play [MMORPG]'s, [Counterstrike], and I know people who
play Gamecube, Xbox, and PS2. When they say they play this or that, I think, how much fun are you
having overall?

I realized one day when I was playing [Counterstrike] that I didn't like the fact that I was playing
the friggen game over, and over, and over again. Sure the game is great, the maps and content are
great, but it's just a game that becomes addicting - smokers smoke cigarettes because they put it
into their brain that they should have a cigarette when they want to have a little fun.

However, when they smoke that cigarette, they feel empty like nothing is actually happening... even
though they're taking a drag and spitting out mucous.

Why can't games be great and not be addicting? Like, I if I want to be able to play Quake for (10)
minutes, and actually get somewhere and have fun in that period of time, I don't want to have to be
reeled in to play for another few hours and skip out on the rest of my life.

That's where the glory of [Quake 3] comes around.

The single player game wasn't all that and a bag of chips, but at least if you knew that you had
something to do, you could just say 'Ok, I'm playing this level and that's it'. 

In [Counterstrike] and [WoW], you have to get into the game, get yourself set up, and then when you
die or something, you end up getting pissed off because you're waiting for other people to allow you
to continue your fun experience.

[Quake] is so unlike any other game or shooter out there.
You load a map up, you pick up weapons, and you shoot people.

If you die, you spawn somewhere else and you don't have to wait on anybody else.
The game happens so fast.

The greatest thing about it is that you can play this game over and over and in the game there are
always new strategies you can use, AND even though [Quake 3] is (6) years old, it still looks more
beautiful to me than [Half Life 2].

I'm serious here, when you play [Half Life 2], you are addicted to the game, and that's the only real
impact it has. Just like [Doom 3], I got to a point in [HL2] where I just wanted to beat the game and
I wasn't having any fun playing it.

In [Quake], your objective has always been to have the most frags while the game's colors just jump
out at you and say 'I'm just as good looking as [Carmen Electra] naked.' It all happens in the midst
of rockets flying in and out of your face.

It's turning into these days that a lot of people are computer leeches, stuck to the computer, unable
to get off their ass and do something productive. These games act upon sour self indulgence, and it's
sickening.

[Quake] has always been a game where you could play and not necessarily be addicted.
Don't get me wrong, this is all a matter of opinion.
My opinion.

I've seen [Counterstrike] turn into such an overwhelming success ever since I started playing beta 3.
I had a lot more fun back then than I do playing the game now, even though it is still quite good to
play.

I remember playing [Quake 2] on my old [Packard Bell] back on the [Christmas of 1997], saying to
myself, this game rocks. I ended up beating the game and didn't touch it for almost a whole year
where some of my friends at school were like 'Oh hell yeah, we play this game online.'

I started playing it online, one match, each night.
Eventually I got good at the game and I started playing it more, but anytime I wanted to stop,
or start again, it was all instantaneous, it wasn't like I had to set this up, then set that up and
make sure that my upkeep was all complicated or anything. Just clean, simple, fun.

This should be a challenge for game developers;
There needs to be [very simple goals], not [one goal] that is elongated by a series of imps jumping
out of doors clawing at your face, or driving a dune buggy along the coast of the ocean for 15 hours
at a time, something simple.

My idea of a game is one where you can have fun at any given time - be it through fragging some
people, or making a shitload of ogres and sending them over to your enemies' town, instead of solving
puzzles and running through hallways, then running all the way back through the level again, that's
just not fun in my opinion...

Games that are fast, and furious, are the ones that people enjoy the most, even if they're not
playing them all the time.

[Quake 4] is going to be the answer.
[Quake 4] is going to be the best game ever made for a long time, I swear to god it will be.
(^ It wasn't...)

<|3FG20K>
"@) 

$Ctrl.AddNews("09/09/2005","Insane Products (Release)",@"
Ladies and gentlemen, children of all ages, take a look inside the most bastardly level ever to be
brought forth from the [Shopping Maul], only known as [Insane Products].

That's right everybody, this map is [done].
Finished.
Made.
Complete.
Ready for your stamp of approval.

If there's anybody that would like to host this map on their server(s) please let me know so that I
can get a bunch of my friends connected if there aren't a lot already - my email address is 
[mykalcook@gmail.com].

Here is a direct download link that skips past the coolest screenshots ever to be seen on the
[Shopping Maul] to your fingertips! "Insane Products - 20kdm3.zip."
<|3FG20K>
"@)

$Ctrl.AddNews("09/04/2005","Insane Products (second beta)",@"
I've updated the map a little bit, (heres the second beta) mostly lighting and some gameplay bits here
and there, and I've been able to take some pretty solid screenshots throughout the entire level.

You tell me, do these screenshots look good?
*previous link deleted, all old photos have been deleted*, all pictures add up to 4.5mb.
Download link above ^ - have fun.

<|3FG20K>
"@)

$Ctrl.AddNews("09/03/2005","Q3Map2.exe",@"
For all you people who like great lighting, I have a surprise in store for you all when the final
version of the map comes out. The beta version of [Insane Products] was compiled using ID's qmap.exe.

I decided to install the q3map2 by ydnar at [Shaderlab] and *whistles* how friggen candylike can you
make a game look?

I previously compiled this map with this utility, but with the gap of time made it slip my mind.
The whole level is just about finished but i'm just waiting on the communities' input on how to make
it better:

[+] [gameplay]
[+] [item placement] (should I swap item positions) 
[+] [brush improvements] (geometry)...

...before I give it the OK for removing that 'beta' in the name.

<|3FG20K>
"@)

$Ctrl.AddNews("09/02/2005","Insane Products (Back to work)",@"
Ok, ladies and gentlemen.
Following the wake of the yearly [Quakecon] (which did not make me decide to work on this),
I have a brand new present for all of you.

After being thoroughly impressed by the footage from [Quake 4], I have decided to polish up this
little gem of a map.

I previously released this map before on this site and felt that it needed a bit of improvement,
so here it is. This is the most killer map I have ever made - so the name suits it well.

[Insane Products - 20kdm3beta.zip] 
For some obsolete screenshots, you can check the map's (95%) unchanged layout here in these pictures:
[20kdm3beta]

<|3FG20K>
"@)

$Ctrl.AddNews("05/14/2005","Doom 3 + Resurrection of Evil",@"
The long awaited game, [Doom 3] has come to store shelves and rocked the world with:
[+] [stunning lighting]
[+] [stellar shadows]
[+] [obscene graphics]
[+] [wicked sound]

With that having been said, is has left a [deep impression] in the gaming community, leaving disputes
to be made about whether it really does hold true that it is the best rendering engine ever released
by anyone.

Well, it is. It's not a matter of opinion, [Valve]'s [Half Life 2] has a very cool engine as well,
but it comes down to the actual rendering, not little tricks behind the rendering scene.

[Half Life 2] DOES contain more interactive features and realistic details, however, when reverting
back to [Doom 3], please remember, these graphics have been taken above and beyond what people can
call [realistic].

With the release of [Doom 3] in [August 2004], millions of gamers have witnessed the energy it
harnesses. Some people playing the game lack the machinery to maintain a 'fun' experience from this
game, while others have no complaints...

In either scenario, the impression the game has left upon it's gamers is very deep - this game is
obscenely revolutionary.
         
The storyline of the original [Doom] was simple - you are the only marine left alive and you want to
know why, so you start running around picking up weapons and destroying demons.

The storyline of [Doom 3] is that you are able to see what happens behind the scenes before anything
happens. Released as an addition to [Doom 3], is [Resurrection of Evil], the first expansion for this
killer thriller.

While [RoE] makes an overall improvement over [Doom 3], it still leaves the gamer wanting more.
Now lets not jump to conclusions and call this a bad thing, usually when a game is made very well,
people want to have 'stuff' to venture through for the next few decades and very few people realize
the limitations of making a game.

Well all I'm saying is that I was thoroughly impressed with [Doom 3].
I thought the game flowed rather nicely and the only thing really 'wrong' with the game was that
there were definitely too many imps jumping at me through the door...

There's nothing you can friggen do about it at some doors and that becomes a [nightmare] in... 
[Nightmare] skill. Alright, back to [RoE]. The reason I felt that [RoE] made an overall improvement
over [Doom 3] was because it added so much more to the game.

I found that the new little grabber gun gave me a one up on all those friggen imps and flying skulls,
and it gives you an advantage because you don't have to waste all that necessary ammo.

The double barreled shotgun was also a nice touch - except I kept getting angry when I wanted to use
the single shotgun and it kept going to my double.

The new enemies are definitely a cool element, the new imps are alot smarter and for some reason they
have a bigger scratching distance... If you get to a certain point in the expansion, you will not see
one single original imp for the several next levels.

(Do not read this paragraph if you have not played the game yet)
The artifact is definitely the coolest addition to the game. While it is not an actual weapon itself,
the features it gives you are priceless in many points in this game. There are three features that the
artifact gives the player once you eliminate each of the special demons from hell.

The first one slows down time so slow that everything sounds and looks very slow but your speed
remains the same. 

The second feature is berserk, you can kill almost everything with one fist punch and it acts like
the quad damage from Quake.

The third and most-definitely-the-biggest-bitch-to-get is invulnerability... 

Once you ascertain all (3) of these seals you can use the [human souls] scattered through all of the
levels to bring these features to your demand. Let me get this straight, you cannot beat this game
without the artifact, it IS impossible.

There is no way you can beat this game without it and if anyone tells you, they are lying.
(^ Well, maybe there's a glitch or something that'll allow a speedrunner to bypass via any%...)

(You can start reading again)
Now, onto the game depiction. One of the main reasons I found this more exciting than the original
[Doom 3] was that there were so many things that were streamlined. I wasn't wasting any time trying
to figure things out, they were all right there and I didn't really have to backtrack like we all did
in [Doom 3].

A lot of the flow is generally built with the same direction in mind, there's no 'oh I gotta find
the [PDA] then get the code, then go back through the whole level to activate the switch to then go
back all the way through the level and then be able to activate another switch to go back to the
beginning of the map...'

No, none of that, it's actually logical.
Maybe I'm pointing out the flaws of [Doom 3], but that's ok because I felt that [RoE] really picked
up where [Doom 3] left off. Another cool thing is that [RoE] actually uses alot of the old materials
from the original [Doom 3], like the airlocks, elevators, bits and pieces of the levels, etc.

I found that the maps looked and played a lot better than they did on the original [Doom 3].
If you get to the end of [RoE], you'll see how extreme they really went in making this...

The last level is just insane...
The ending boss is modelled so exponentially better than in any game I've ever seen, and I was
honored to see the [ending cinematic] and actually understand what had happened.

To sum it all up, I think that the actual ending should have been extruded quite a bit, at least show
what happened had happened instead of leaving me the ability to fill in the blank. It's cool though,
and I suggest to any gamer who is a fan of doom and didn't really like [Doom 3], that even though you
may not have liked it, [RoE] definitely picks up where [Doom 3] left off on so many tangents.

A lot of people feel that the game has been extruded all in the same, but there are alot more
elements to deal with, and alot more weapon switching. In fact, you'll find that the actual gunning
down of the enemies is useless with just one weapon, because you have so many different tactics at
your disposal, and plenty of ammo at several points in the game.

You don't have to worry about 'oh my god, I have to use the assault rifle because I'm out of shotgun
shells and this and that and .....' blah. [RoE] definitely fed my appetite for more [Doom 3] and it
did more than make me full, it made me want seconds.
 
Hopefully [Quake 4] will pick up where [RoE] AND [Quake 2] left off...
I will explode from all of the [1337n3ss]!!!

<|3FG20K>
"@) 

$Ctrl.AddNews("04/03/2005","Long Time Away",@"
Wow. I have not updated my site for a very long time!

My apologies, I have been going to school and working full time with no time to spend on making maps.
With that said, I would like to inform everybody, that I, Michael <|3FG20K>, have devised a plan that
extrudes into [Quake 4].

Upon the release of [Quake 4], I will unleash upon the [Quake Community], this new map which has been
pretty much complete for some time - I have not released it due to this lame error which prevents the
bots from being able to navigate and provide any fun for playing against.

SO, like I said, I have a brand new map waiting to be released as soon as [Quake 4] is complete.
[Doom 3] is a good game,- which is at your local [Walmart] or [Target].

I played it and beat it on [nightmare] which was a bitch and a half, your life drains to (25) all the
time but at least you get to use the [Soul Cube] from the very beginning of the game.

I suggest that if anyone who is reading this has [Doom 3] and hasn't beaten it on [Nightmare], you
should invest at least (20) minutes a day in trying to do just that because [Nightmare] is definitely
possible.

On a side note, not that this is in any way related to [Quake], but I bought my cousin who is (8)
months older than me a copy of [Halo 2] for Christmas. He beat it on [regular], than [heroic], and I
finally talked him into playing it on [legendary].

Well, he beat the game on [legendary] and I don't know many people who had the time to do that so if
you have, drop me a note at [BFG20K@HOTMAIL.COM] and I will congratulate you.

To spoil his fun, I have become so competent at [Halo 2] that my cousin cannot beat me when we play
against each other - go figure.

Ok. I've said a bunch of stuff, I have more to say, but not right now.
Like I said, i'm sorry for the lack of updates but I have schooling to complete then you can all see
what it is I'm going to school for.... Muhahaha! =)

Ok, have fun.
Stay in school, don't be a fool... and don't get caught playing pocket pool.

<|3FG20K>
"@)

$Ctrl.AddNews("01/11/2004","20kdm3 (Beta)",@"
Brand new map is ready for beta. I have to tell everybody that there are no bots supported in this
map because they are just really dumb.

[RAILMEAT's RA3 Server] may probably be hosting this map file soon, and already hosts [HELLRA3MAP1].

Stop on by and get the fragging going on at [RAILMEAT]. [20kdm3beta.zip]

<|3FG20K>
"@)

$Ctrl.AddNews("01/01/2004","New Year (2004) + [Doom 3] anticipation",@"
Great news folks.
Since the new year is here, I wanted to release this project I've been working on 'indefinitely'?

This year is going to be great because we've got [Doom 3] coming out really soon and computers will
be able to run it and all, oh I really am crapping my pants in waiting for this son of a bitch to be
born!

So, without further ado, I have for you to take a look at these screenshots of this level which is
technically finished. I've done alot of tinkering to the map and feel that it supports the gameplay
I want it to have.

I suggest anyone running a decent system can have it run rather flowish, anyone with a lower end
computer will definitely be able to run it.

<|3FG20K>
"@)

$Ctrl.AddNews("10/19/2003","(2003) Summary",@"
This years been a flop for game design in my opinion.

I've decided to halt all of my projects until a newer game comes out so that instead of investing the
time I've put into some of these maps I'm making for an older game, it would be much more appreciated,
not only by me, but to you as well, for me to hold off on these plans...

Ya know what I'm saying, DUDES...?

Well anyway, besides all of that, I have been away working full time ever since I turned (18) back in
[May], so that has halted much of my activity around the [PQ] Hood but hey, what can I say?

I know [Doom 3] and [Quake 4] are just around the corner, and when they come out, we will surely see
not only a spur of new mods, games, and maps, but a new mode of fun as well.

<|3FG20K>

P.S. I've written a little collaboration of imagination into a scripted out idea for something that
might actually be god damned cool if brought to life. You're welcome to read it =P

[DUEL Operations Prologue]
"@)

$Ctrl.AddNews("03/06/2003","BFGCTF1 or 20KCTF1...?",@"
Great news... [BFGCTF1] has crapped out on me but I fixed it.

Since the [bfg] maps I are old, and I already have a consistent quality in the [20k] series,
I have altered the maps format to be [20KCTF1].

There are virtually no changes anyone will notice, but they seem to fix the problems encountered
by some [sermianto] guy or something on [..::LvL] who's never reviewed a map before.

Since I have no other beef, I have fixed what he bitched about and am willing to put it in the past.
Because frankly, I will not get held up over just one of my maps...

That's right folks, I'm making [Tower of Oblivion] completely "cool".

As one of my friends said when he saw the preview, he said it was totally radical and he wanted it
on his hard drive immediately. It's not ready to play yet, and it uses an extensive array of jaw
dropping textures, made by none other than [Sock] himself.

Like no other time, I know what I'm doing with this map and this could potentially mark [Q3] history
as far as my expectations go (it's getting there...).

[ZTN], [Charon], [Luneran], mind moving over a lil bit? =P

<|3FG20K>
"@)

$Ctrl.AddNews("02/28/2003","Insane Product AKA Tower of Oblivion",@"
Level is almost ready for pre-beta, post-alpha testing and I will load the level's screenshots and
preview (*.pk3) very soon.

Chill out for a little while so I can get some things straightened out.
I'll make it nice, clean, and smooth, which is what everyone really wants when they play a new quake
map right?

This is all for now...
Prepare to see a very monstrous beast...an [Insane Product by <|3FG20K>, Tower of Oblivion]!

<|3FG20K>
"@)

$Ctrl.AddNews("02/08/2003","Tower of Oblivion (Short update)",@"
[Tower of Oblivion], still in the works.
Looking great so far, need more time to construct.

I will keep informed until release of a beta form.

<|3FG20K>
"@)

$Ctrl.AddNews("01/30/2003","Tower of Oblivion (50%)",@"
I've got a new map in the works called [Tower of Oblivion].

Currently it is approximately (50%) done structurally, but when it is done I need to tinker with the
other stuff:
[+] [lighting]
[+] [item placement]
[+] [ambient sounds]... etc.

I'm going to bet that this is going to be an awesome [tourney map] because the layout of the map
promotes the players to keep moving in a smallish-medium sized arena.

I should post some screenshots when it is done, but to keep you wondering, I'm using [Sock]'s base
textures to create this incarnation and there will be a lot of balanced aesthetics and brushwork...
...as if there isn't enough already...

<|3FG20K>
"@)

$Ctrl.AddNews("12/28/2002","Out of My Head (Release)",@"
Guess what folks?
New map, finally released out of beta, is my first CTF map, [Out of My Head].

I've included lots of new features, more eye candy, and more routes for the [Capture the Flag]
experience that everyone is going to leave as a winner.

I created it with [Threewave] in mind, but despite this it is still a good level for [Free-For-All],
and [Team Deathmatch]. Overall, I enjoyed making this level and it was a good experience for me to
make a fully functional level for my favorite mod.

I can't wait to see it on servers =P
Here is the map... [Out of My Head]

<|3FG20K>
"@)

$Ctrl.AddNews("11/21/2002","Out of My Head (Beta 2)",@"
I have drastically updated the [CTF] map which is still in BETA, but may not be for very long.
This version is slightly smaller than [Beta 1], and packs a few more features as well as a major jump
in [performance] and [detail].

Have fun fraggin in this one folks!
[Out of My Head (BETA 2)]

<|3FG20K>
"@)

$Ctrl.AddNews("11/17/2002","Return to Castle: Quake",@"
All of my maps are on the maps page.
I have added [Return to Castle: Quake].

This compile is the same as the one distributed in [February] as [rtcq-test].

There's nothing wrong with it, I just don't have the (*.map) file anymore and I wanted to save myself
some time rather than just [decompile] it and [retexture] everything.

Anyway, here's the map (you can also get it on the maps page).
This puts the total map amount at (11) maps!

I will pump out more!
So, just stay tuned folks.

By the way, I would like to introduce my friend, [Alex Welsh], to the site.
He has efforts in mapping as well, not as well developed yet, but I am helping him out in polishing
his maps, so hopefully the map stream will double up. Until next time! Latez =P

Second Update: There's some very minor problems with the [RTCQ] map that I can't fix, but there is
one missing texture that I forgot to extract from [mapmedia.pk3].

Here is the fix, it is very small.
Put this in the same directory as [map-20kdm2.pk3]

<|3FG20K>
"@)

$Ctrl.AddNews("11/16/2002","Quad Machine",@"
WE LOVE THE QUAD!
WE NEED THE QUAD!
WE BREATHE THE QUAD!
Download [QUADMACHINE]!

It is over (3mb), because of the [COOL MUSIC] that is included.
But we all love [Sonic Mayhem], and we ALL LOVE THE QUAD, so download this map, extract it, run it,
[set /g_quadfactor] to (100) or something REALLY CRAZY, GET SOME FRAGBAIT... 
...AND BLAST THE HELL OUT OF EVERYBODY!

Second Update: I have modified the maps page.
Visitors may now traverse through each level's screenshot gallery to see whether or not the download
is worth their effort. I will soon add more features to the page, particularly ones that are user
friendly and expand their functionality.

Last Update: Due to increasing demand, I will revive the [Return to Castle: Quake] map, as soon as I
get a chance. I am deciding whether or not to expand the map, or leave it as is and push for a final.

You decide folks, drop me a line: [bfg20k@nycap.rr.com]

<|3FG20K>
"@)

$Ctrl.AddNews("11/13/2002","Out of My Head (Beta)",@"
Ok. After some minor adjustments and a recompile...
...my screen saver screwed up the compilation, go figure...

I believe the map is ready to roll out. I have tested all that could go wrong, and if there are any
more problems, please let me know immediately.

Anyway, here is [Out of My Head]. 
To lessen the confusion from earlier, I have renamed the map without a '1'
If you need an alternative... (= Haha =)
Then you can download the file [here](<no download link>) too.

<|3FG20K>
"@)

$Ctrl.AddNews("11/09/2002","Collaboration",@"
I'm working hard putting brushes together and stuff, I almost have my CTF map completed.
Shortly after, me and [Zer0_Co0l] will co-release a map that I think is the most fun [Quake III Arena]
has to offer.
[+] Small arena
[+] Quad respawn (10) seconds
[+] G_quadfactor (9999)

With that being said, I must now make a departure for WORK!
I'm trying to put a (P4) system together, if anyone has any motherboards or processors they want to
get rid of, e-mail me at [bfg20k@nycap.rr.com]

<|3FG20K>
"@)

$Ctrl.AddNews("11/02/2002","Zer0_Co0l",@"
Good News: I have been hanging out with my buddy [Zer0_Co0l], and I must say that he may eventually
be making some of the maps here!

He has a bunch of various computer skills:
[+] [coding]
[+] [playing games]
[+] [content]
[+] [graphics], etc...
...and I would like to welcome him aboard.

I am also going to finish a [ctf] level I have been working on for a while as a [free for all] map
and tourney, but it will have (2) bases because as of right now I have a version ready for people
to play. I need to make some adjustments, and recompile, then I will load it up.

See you real soon folks.

<|3FG20K>
"@)

$Ctrl.AddNews("10/27/2002","Revisions",@"
I haven't made anything since the other day, but I have been editing this web page and making
[revisations (meant revisions)] of the layout...

I plan to revamp this after I get a few maps finished.
I plan on moving on from [Quake III Arena], but hopefully that won't be for a few more months until
I get my new computer up and running, I need a bunch of parts for a new one.

By all means folks, stick around and I'll give you some entertainment you'll enjoy.
Thanks!

<|3FG20K>
"@)

$Ctrl.AddNews("10/25/2002","Absent",@"
Hi ladies and gentlemen, I am back.
I cannot promise that I will make another distant leave, but I can say that what I've done today has
really opened my mind about the possibilities of ideas I can have if I just open up my mind a little
bit and follow through. 

So I say to you, that I have returned to make some maps!
I don't know what I will build because I have nothing in mind, I will get an idea though.

I had some maps over the summer I was working on ready to release, but some really bad mishaps took
place and I prefer to not explain.

([Jeff Truesell] and [Zach Temme] kept destroying stuff in my house, I kept calling the police, they
did nothing, and then I took the law into my own hands and assaulted [Jeff] with a baseball bat, then
they stopped breaking into my house and destroying stuff.)

Anyway, consider this site as a continuing work effort.

<|3FG20K>
"@)

$Ctrl.AddNews("05/18/2002","Temporary Withdrawal",@"
Yeah, it's been a while since I've updated anything, so alas here is my update.
I have done NOTHING for the past few months.

Yeah, that's right - I haven't touched [Q3Radiant] with any good feeling or ideas for a while.
I will get [RTCQ] out of the door.

After that is whatever I had written down, or drawn down,
or maybe I'll just improvise the whole thing.

Anyway, just let it be known I'm not dead and being a disciple might not be a bad thing if I can
release some promising material =O

<|3FG20K>
"@)

$Ctrl.AddNews("02/01/2002","Return to Castle: Quake",@"
Awesome news indeed!
[Return to Castle: Quake] is a finished for testing form!

You can grab it here... [Return to Castle: Quake (Test)]
As it is, you can play [Free-For-All] with up to (4) players, or you could play in Tourney mode.
I've had to rebuild the entire map, with help from [q3map.exe] of course, so I haven't gotten to
placing any detail outside of the castle.

Anyway, it's promising as it is - It's not [ZTN], or [Charon], but maybe the next best thing.
Have fun fraggers!

Alternate download site: [Return to Castle: Quake (Test)]

<|3FG20K>
"@)

$Ctrl.AddNews("01/29/2002","Hard Drives",@"
I know, I know, it's been more than half a year since i've updated the page.
Well, no more worries.

The reason I've been left behind in updating the page is because of real life things that just kept
getting in the way. Back in October, I planned to release a map for [Urban Terror] for the UT contest.

Unfortunately, as I upgraded my [hard drive], I made the stupid mistake of shorting the [old one] that
had all of my stuff on it, as well as the [new hard drive]. So I waited for a while to get a
replacement, and I've just been trying to get my computer up and running like it used to be.

At that point, I just didn't feel like mapping for a little while.
Now I am definitely up and running, so I would like to spread the good news that I have a few maps
that I plan to push out the door. The first is a map called [Return to Castle: Quake]. It is a simple
level with basic solid architecture (this is the map I intended on releasing for the UT contest) and
solid tournament gameplay, with the [Evil 7] Texture set.

Secondly, is a map called [Tower of Oblivion] that I've finished making plans for and only started
mapping. Lastly, I don't know if I will make it, but I did pump out a beta on LvL called [The Level],
if all goes well with the former maps, then I'll consider finishing that one.

Also, my friend Zer0_Co0l is making maps now, and I hope to add his maps to my page...
If you play HELLRA3MAP1 and play [Tranquil Equilibrium], you'll probably notice a separate style from
the other four, that's because he is the one that originally made the stairwell areas.

Finally, my favorite map, [20KDM1] was reviewed on [..::LvL] a little while ago, and it got a pretty
decent review =).

Here's the little extra work I put in during that long wait [Return To Castle: Quake].
So until the next update, so long chums.

<|3FG20K>
"@)

$Ctrl.AddNews("07/26/2001","Dude, You Can Go To Hell",@"
[hellra3map1] is finally complete.
After (10) months of construction, it's a great relief to know that finally the map is finished.

There are (3) [Rocket Arenas], (1) [Red Rover Arena], and (1) [Clan Arena].

The main selection room has a few extra goodies I decided to throw in for a few brownie points =)
Anyway, go have fun with [hellra3map1.zip] 

Some guy on the [MAHQ] team asked me to do a [recompile] on the map, so if you downloaded the [RA3]
map earlier today, you're gonna have to download it again.

[BREMAN] of clan [PoT] is hosting the new [RA3] map at this kick ass server: [63.162.63.19:27965]

<|3FG20K>
"@)

$Ctrl.AddNews("07/21/2001","Tempered Graveyard",@"
Great news everyone!
[Tempered Graveyard] is a finished DM level!

You can grab it here... [map-20kdm1.zip]
As it is, you can play [Free-For-All] with (7) other players and still have a normal game,
or (11) other players and have a blast...

You can have a nice game of [TDM] with (4) player teams pitted against each other...
Or you can try it out as a [Tournament map] - It is a very big tourney map =)

<|3FG20K>
"@)

$Ctrl.AddNews("07/15/2001","hellra3map1 Beta",@"
Good news everyone... [hell-ra3map1-beta5.zip] is available to download.
Have fun playing it =)

Bad news...
There are some minor problems in some of the arena's so it may not look finished...
(which is why it is BETA)

<|3FG20K>
"@)

$Ctrl.AddNews("06/29/2001","Updated Screenshots",@"
I updated the screenshots yet again.
Try not to have too much fun looking at the screenshots, it might ruin the entertainment of the actual
map when I finish up (35%) of the level =)

[BFGDM2A/The Clan Arena]

<|3FG20K>
"@)

$Ctrl.AddNews("06/27/2001","Silence and Wisdom",@"
I mapped a little something while I was getting stressed with the [Clan Arena], and here it is...
[Silence and Wisdom] [arena5.zip]. 

It's a (1v1) arena I will place in the [hell-ra3map1] multi-arena so it will contain a total of (5)
arenas! Anyway, have fun with that, let me finish building the clan arena.

<|3FG20K>
"@)

$Ctrl.AddNews("06/14/2001","End of 10th grade",@"
Sorry for the severe lack of updates...
It's been the end of the school year, hectic and uninspiring.

Anyway, I want everyone to know that I haven't forgotten about my mapping duties,
although I have broken the promises about having some maps done when I said they'd be...

Right now I have [bfgdm2a/the clan arena] for [hell-ra3map1] (50%) finished...
It looks pretty good in some spots, here's a link to some screenshots I took.

I'm trying to recapture the feel of [q3dm6], so don't feel like you're an idiot if the map feels
reminiscent of it =)

<|3FG20K>
"@)

$Ctrl.AddNews("05/24/2001","16th Birthday",@"
I felt it was my duty to proclaim...
IT IS MY BIRTHDAY!

I know, I know, I'm not important enough for anyone to care...
However, I just needed to let everyone know instead of having a blank for a news update.

I haven't mapped in a week, and you can blame it all on my friends and my NOW ex-girlfriend.

I'm going to a LAN party this weekend so I will probably get back into mapping heavily next week.

<|3FG20K>
"@)

$Ctrl.AddNews("05/18/2001","BFGDM2A",@"
I am heavily reconstructing [BFGDM2A], which will be large enough to fit in my Gothic themed RA3 map,
[HELL-RA3MAP1] as a [clan arena]. 

Right now it is approximately (25-30%) completed, and I want to say I'll finish it by the end of May,
but I'm not too sure. I have plans for releasing [HELL-RA3MAP2] (The space map) sometime within the
next month, and what's this...?

[HELL-RA3MAP3]?
Yep.
That's right.
You heard me.

I'm going to make yet a third and probably final ra3 map with a base texture theme.
After this I'm going to chill by making a few DM maps...

But be aware, I am making no promises that they will all be released when I say they'll be...
There might be some unknown problems along the way, for instance if I get too carried away, my
girlfriend might have a kid (I'd have to have a girlfriend first, right?) and I might O/D on
Minocycline!

Anyway, be prepared for some good stuff to emerge.

<|3FG20K>
"@)

$Ctrl.AddNews("05/05/2001","BFGDM4",@"
Just a quick little rundown of what's done and what I'm working on...
[BFGDM4] is now FINISHED, you can check it out on the maps page.

For a little twist on making it a *little* more interesting, I've optimized the lighting in [BFGDM3],
and a few other things to make up [BFGDM3A].

Feel free to check that out too.
I'm trying to figure out what kind of additions I can make to [BFGDM1], and it should not be too long
until I release that. [BFGDM2A] is kind of one of those projects I don't really want to finish but I
know I have to...

I'll probably finish that sometime soon. [HELL-RA3MAP1-BETA5] will be released next month... and
[HELL-RA3MAP2-BETA1] will be released sometime this weekend. Note that this map will only have two
arenas, [Suspended Animation], and [Space Station 1138].

The multi-arena as I'm thinking it should be, will probably be [Q3DM17]...
Go figure =)

<|3FG20K>
"@)

$Ctrl.AddNews("05/04/2001","Website Launched",@"
Hurrah!
It's launched!
The site is launched!

For you people who are just wondering who the hell I am, if you don't already know me...
I'm a (15) year old who will be (16) on the (24th) of this month...
...and I play [Quake III Arena] to no end.

Not only do I [play] the game, but I [map] for it too.
Yes, some people say, it's [difficult] to be a [great mapper] and a [great player], well, forget it.
I'd rather be a [jack of all trades] than someone who's [consistently doing the same thing]...

I get bored quickly =(.
Anything else you want to know you might find on this site...
If not, just e-mail me at [bfg20k@planetquake.com].

Finally, if anyone wants to play [hell-ra3map1-beta4], there's a healthy server with a [T3] running
it at [208.136.2.13:27960] - [Crunch-N-Munch RA3 1.5].

Be sure to check in often though, I try to pump out a map every week or two =).

Later Update: [bfgdm4] is ready to roll.
Go to the maps section to get it =)
If you were here earlier today, there was a previous post which said I would release this later...

Well, later is now, so if you really want the final version which clocks around (2mb), go ahead and
have fun d/lin' this fine map.

<|3FG20K>
"@)

$Ctrl.AddNews("04/30/2001","Website Online",@"
Yes!
The site is up!
Hurray for PQ!

Right now, I have about (10) pages of graph paper with level plans on them...
Every project that I have on beta, or if finished, I'll leave it up for grabs.

Right now, my collection may not seem impressive.
That will change quickly when I get the five maps I'm working on completed.
To make things even more interesting, I'm going to start naming my maps like so... 
- [20kdm1]
- [20kdm2]
- [20kdm3], etc... 

The reason being is that my upcoming work will be a lot better, and I don't want people to think that
by releasing [bfgdm5], I have previously released (4) equally efficient maps.

That is all I must say for now...
This begins the dawn of a new generation of cool maps for [Q3A].
Prepare to be rocked!

Later Update: I have [hell-ra3map1-beta4] ready for everyone to play!
It has three [Rocket Arena]'s...
That's it for now.
I hope you like those shaders that I made, it took me a little while to come up with them all.
Grab it here!
[hell-ra3map1-beta4.zip]

Just to let anyone who wants to know, know... I will transfer the files from my friend [Malakili]'s
server to [Fileplanet] as soon as [Gamespy] fixes the [directory permissions].

<|3FG20K>
"@)

$Ctrl.AddNews("04/23/2001","Introduction to PlanetQuake",@"
Time to show people everything I've got... Lemme see here... Where should I begin?

First of all, I'd like to introduce myself.
My name is Mike Cook, I'm 15, and I map a lot.

I don't just map a lot, but I like to keep in particular, [Quake III Arena].

I've done several projects over the last (11) months, with my first few completely sucking...
I'll try to pump out some remakes of them or something.

Lately, I have been trying to complete a clan arena for a gothic themed [RA3] map that I might
just throw out of the window because who wants another gothic map...?

I have began to think that maybe I could catch the eye of a few with a space [RA3] map...
Yeah, that's the ticket...

Imagine playing a [Space RA3] map - Yeah, I know what you're thinking though... 
"That's going to be mad gay because people will fall off of the edges easily, and the guys
that are wicked good with the Railgun will own."

Don't worry about it, I've got it covered.
So far, the past two DM levels I've been working on:
[+] [Space Station 1138]
[+] [Suspended Animation] 
...will be included, and I'm *probably* going to stick in [Q3DM17 - The Longest Yard], 
with credits to [ID Software] that is =)

I'm going to keep my [Counter-Strike] mapping to a minimum because my friend [Malakili]
whom I've helped learned how to map is probably going to take over all of the projects we've
worked on together, 100%.

If you've got any questions for me, you [Quake Community] you, go ahead and e-mail me at:
[bfg20k@nycap.rr.com]. 

Thanks.

<|3FG20K>
"@)

$Ctrl.AddNews("07/29/2023","Shopping Maul [Xaml]",@"
So, it is currently [07/29/23 @ 2113 EST], and I've been working to build a Xaml based application
that shows off my mapping portfolio from [Quake III Arena]. I have been accumulating a bunch of
mapping related content as well as general [Q3A] play over the last couple weeks.

Today, I said to myself... "I could totally make an application that hosts all of the map information
as well as videos and stuff, couldn't I...?"

Nobody was in eyesight or earshot to respond "Yeh man. You totally could. So, why don't you...?"

Anyway, yeh. Sometimes... people have stuff to do.
Other times, stuff gets done after it's conceptualized and made.
In rare instances, stuff does itself... and people just sit around watching stuff happen.

If that sounds vague...?
That's because it's meant to sound pretty vague, and comedic.
If [you can't just blow a hole in Mars]...?

Then you can't just talk about stuff in a [non-descript manner] whereby causing people to wonder what
the hell is really going on, or what is really being said.

Nah. Gotta keep people in [suspense] and stuff, that's why being [vague] is pretty important.

You don't wanna just [let the cat out of the bag], whereby allowing everybody to see what the cat
looks like.

...you have to talk about the [shape] of the cat...
...the [personality] of the cat...
...what color fur the cat has...
...what the cat sounds like...
...what the cat doesn't like...
...and whether or not the cat in question, has an air of [sassiness] or [snarkiness] about it.

Once all is said and done...?
The cat will eventually come out of the bag in entirety for all to see.

Until then...?
The cool cat is going to take it's time waiting for the perfect moment, to come out of the bag.

<|3FG20K>
"@)
#>

<# [News -> Export mode]
$Ctrl.News.ExportAll()
#>

<# [News -> Import mode]
$Ctrl.News.ImportAll()
#>

<# [Maps -> Commentary]

    In this section, to build the map information from [scratch], the [Refresh()] method
    will pull from the [Enumeration type] in order to create a bunch of [MapEntryItem]'s
    from within the [MapEntryList] object.

    That's what $Ctrl.Maps object is.

    I'll cover more about what things do or whatever in the document, not the script area.
#>

<# [Maps -> Enumerate mode (Default)]
$Ctrl.Maps.Refresh()
#>

<# [Maps -> Set Description (Default)]
ForEach ($Item in $Ctrl.Maps.Output)
{
    $X = Switch ($Item.Name)
    {
        bfgdm1
        {
            @("I don't believe this was a horrible first effort...",
            "",
            "Basically, the map is symmetrical with armor on the [Right] sides",
            "(depends on if you're looking in the proper direction) and the [Left]",
            "sides have [Shotgun] and [Railgun].",
            "",
            "On the [north] side, is a [Rocket Launcher], and on the south side is a [Plasma Gun]."
            "In the center, like a ton of other maps, is the [Quad Damage].",
            "",
            "There are many flaws in the map, and I'm not going to bother going into detail,",
            "but mainly this was my first experiment with curves."),
            "2-3",
            "Free-For-All",
            "Textures: No | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        bfgdm2
        {
            @("My second map, featuring a great layout, but not very pretty texture selections.",
            "",
            "The theme is gothic with a touch of base here and there.",
            "There are two main areas, the Rocket Launcher area, and the Lightning Gun/Haste area.",
            "",
            "The map is right on spot for tourney play, and free for all."),
            "2-5",
            "Free-For-All, Tournament",
            "Textures: No | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        bfgdm3
        {
            @("Finally, my professional map skills have surfaced with the creation of my (3rd)",
            "publicly released map, [Space Station 1138].",
            "",
            "I submitted this map to the [Q3 Geometry Challenge], hosted by [Nunuk].",
            "",
            "This is a deathmatch level, but can easily be played in Tournament mode,",
            "although [Railwhores] may end up owning anyone."),
            "2-6",
            "Free-For-All, Tournament",
            "Textures: Yes | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        bfgdm4
        {
            @("Reminiscent to [Doom 2]'s [Dead Simple] as one commenter said,",
            "this map sports chaotic deathmatch while still looking good and hosting fair gameplay."),
            "2-4",
            "Free-For-all",
            "Textures: Yes | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        bfgdm3a
        {
            @("Modified version of BFGDM3.",
            "Finally, my professional map skills have surfaced with the creation of my (3rd)",
            "publicly released map, [Space Station 1138].",
            "",
            "I submitted this map to the [Q3 Geometry Challenge], hosted by [Nunuk].",
            "",
            "This is a deathmatch level, but can easily be played in Tournament mode,",
            "although [Railwhores] may end up owning anyone."),
            "2-6",
            "Free-For-All, Tournament",
            "Textures: Yes | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        20kdm1
        {
            @("This is a somewhat Medium/Large [FFA] and [TDM] level I made originally for",
            "my [RA3] map, [RA3MAP1] which turned out to be so much more."),
            "6-12",
            "Free-For-All, Team Deathmatch",
            "Textures: No | Sounds: No | Graphics: No",
            "Any DM/TDM mod"
        }
        hellra3map1
        {
            @("There are (3) [Rocket Arenas], (1) [Red Rover Arena], and (1) [Clan Arena].",
            "The main selection room has a few extra goodies I decided to throw in for a",
            "few brownie points =)"),
            "2-32",
            "All",
            "Textures: Yes | Sounds: Yes | Graphics: No",
            "RA3"
        }
        20kdm2
        {
            @("My favorite tournament level, which consists of the [Evil7] Texture set,",
            "and tight chaotic gameplay. There are (3) tiers, and as an added feature you can rocket jump",
            "on top of and over the battlements; I want players to have freedom."),
            "2-8",
            "Free-For-All",
            "Textures: Yes | Sounds: No | Graphics: No",
            "Any DM mod"
        }
        20kctf1
        {
            @("There are many combinations of attempting to retrieve the flag, and returning to your base",
            "in this one. Most [CTF] maps have several routes in which one may bring the flag back, but not",
            "many have unique passageways, streamlined with [Threewave CTF] textures forged only by the",
            "texture god himself, [HFX Evil].",
            "",
            "With a combination of [snow], [fog], [concrete], [jumppads], and [teleporters], this map is",
            "sure to fuel the fire of many hardcore [Quake III Capture The Flag/Threewave Capturestrike] players."),
            "8-16",
            "Free-For-All, Team Deathmatch, Capture The Flag",
            "Textures: Yes | Sounds: No | Graphics: No",
            "CTF/Threewave CTF"
        }
        20kdm3
        {
            @("This level is a compilation of a bunch of influences among the [Quake Community].",
            "I'd like to thank [Tim Willits], [ZTN], [Charon], and bunches of other mappers that",
            "helped me create such a rich [Quake] experience.",
            "This level's premise is a [Slime factory].",
            "Since slime has never had such a really cool setting, I decided to make a slime factory",
            "in its' entirety. There are so many routes to take in this map it will make your head spin."),
            "2-16",
            "Free-For-All, Team Deathmatch, Tournament, forms like 'The Edge'",
            "Textures: Yes | Sounds: Yes | Graphics: No",
            "Any DM/TDM mod, RA3"
        }
        20230717
        {
            @("This is a level that I made demonstrating the capabilities of [GtkRadiant] in (2023).",
            "There is plenty more that could be done to this map, but that will probably be part of",
            "an anthology of how to use [GtkRadiant], and the map can be seen being built in this",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant"),
            "2-4",
            "Free-For-All, Tournament",
            "Textures: Yes | Sounds: No | Graphics: No",
            "Any DM mod"
        }
    }

    $Item.SetDescription($X[0],$X[1],$X[2],$X[3],$X[4])
}
#>

<# [Maps -> Export mode]
$Ctrl.Maps.ExportAll()
#>

<# [Videos -> Commentary]

    So, in this section, [YouTube] didn't exist until after the website I once hosted had existed
    and was relinquished from existence by the change in ownership between [GameSpy] and [IGN].

    Many sites remained, but I explicitly remember when people at [PlanetQuake] were like:
    [PlanetQuake]: HEY~!
                   BRO.
    [Me]         : Sup...?
    [PlanetQuake]: We're basically tearing down a bunch of sites.
                   We're lettin' ya know so you can get your data and stuff.
    [Me]         : Oh ok.
                   I mean, it is what it is.
    [PlanetQuake]: Nah, look.
                   When you get older, you're gonna realize how important this data actually is.
                   So...
    [Me]         : Alright, so...?
    [PlanetQuake]: We're gonna give you a way to download your data, and then...
                   You just gotta download it and hang onto it, dude.
                   Or else you'll... *shakes head* you'll regret it, buddy...
    [Me]         : Is that a threat...?
    [PlanetQuake]: Nah, I'm just sayin' you'll look back and be like:
                   [You]: Damn, should've downloaded my data...
    [Me]         : Alright, fine.
    [PlanetQuake]: Anyway, [..::LvL] will still be around too.
                   So, there's that.
    [Me]         : [..::LvL] is awesome.
    [PlanetQuake]: *nodding* Yup.
                   It is.
                   Anyway, take care dude.
    [Me]         : You too.
    [PlanetQuake]: Bye.
    [Me]         : Bye.

    The conversation wasn't verbatim, but the context is pretty accurate.

    Anyway, [YouTube] didn't exist back then, or it was in its infancy.
    So, I wasn't able to record videos of my maps and upload them to [PlanetQuake].
    
    This might've even been before [James Rolfe/Angry Video Game Nerd]'s time...
    I don't know.

    [YouTube] did exist in like (2005/2006), but in order to get a [YouTube] account,
    you had to travel all the way around the world in a boat with a herd of goats, and
    they had to all survive the trip, as well as you. 
    
    Then after you traveled all the way around the world, you had to take the herd of
    goats to the heart of the [Himilayan mountains], and meet with [Tibetan monks] who
    study the holy sacred art, of tellin' it like it really is at all times.
    
    Once you met with the monks, you had to convince them to take the herd of goats.

    Typically they would be pleased by seeing a new herd of goats, but they would
    get pissed if [any] of the goats died, and then they wouldn't issue a note on a
    scroll meant to be read by a machine in the first world, that verified the
    authenticity of the scroll.

    Anyway, if all of your goats survived as well as you, and you managed to charm the
    [Tibetan monks], they would issue a genuinely written [Tibetan monk] scroll that stated:
    "This person should be allowed to have a [YouTube] account..."

    And then, the machine in the first world would be able to read that scroll, and
    determine the true nature as to whether or not a [Tibetan monk] had written that.
    Once it was determined by the machine in the first world that an actual [Tibetan monk]
    had written that statement on a scroll...?

    That is when [YouTube] allowed that person to have an account on their platform.

    I am [slightly exaggerating] how difficult it was to get a [YouTube] account back
    in it's infancy... but- make no mistake. The [Tibetan monks] have spiritual powers,
    and they are quite skilled at convincing people to do stuff.
#>

<# [Videos -> Create mode]
$Ctrl.AddVideo("07/28/2023",
               "2023_0728-(Q3A Practice)",
               "https://youtu.be/2376LUpG3_0",
               "01:50:16")
$Ctrl.AddVideo("07/29/2023",
               "2023_0729-(Q3A Practice)",
               "https://youtu.be/F4HvOosnnG4",
               "01:37:17")
$Ctrl.AddVideo("07/28/2023",
               "2023_0728-(Q3A Practice - Test Map)",
               "https://youtu.be/efn3SmNPWS8",
               "00:15:35")
$Ctrl.AddVideo("07/17/2023",
               "2023_0717-(GtkRadiant)",
               "https://youtu.be/-tGdz6oxXZI",
               "06:05:05")
$Ctrl.AddVideo("07/17/2023",
               "2023_0717-(Test Map)",
               "https://youtu.be/cbdJ-rWJbVI",
               "00:03:45")
$Ctrl.AddVideo("07/16/2023",
               "2023_0716-(Q3A Practice)",
               "https://youtu.be/OpDG2mYlYM8",
               "02:22:36")
$Ctrl.AddVideo("07/15/2023",
               "2023_0715-(Q3A + GtkRadiant)",
               "https://youtu.be/aoS1HEDay4o",
               "00:32:07")
$Ctrl.AddVideo("07/10/2023",
               "2023_0710-(Q3A Practice (Custom Maps 2/2))",
               "https://youtu.be/_siuaph1_vc",
               "00:28:34")
$Ctrl.AddVideo("07/10/2023",
               "2023_0710-(Q3A Practice (Custom Maps 1/2))",
               "https://youtu.be/bQ46Pvp0tOo",
               "00:44:15")
$Ctrl.AddVideo("07/08/2023",
               "2023_0708-(Q3A Practice)",
               "https://youtu.be/RCkI2OFtCB4",
               "03:13:28")
$Ctrl.AddVideo("05/28/2021",
               "2021 05 28 06 01 57",
               "https://youtu.be/Hj8TaUgUh64",
               "00:34:44")
$Ctrl.AddVideo("06/05/2021",
               "2021_0605-(20KDM2 - Return to Castle: Quake (2002))",
               "https://youtu.be/xN53K9oGCME",
               "00:05:16")
$Ctrl.AddVideo("06/05/2021",
               "2021_0605-(20KDM1 - Tempered Graveyard (2001))",
               "https://youtu.be/dyHwm9AdkQs",
               "00:10:33")
$Ctrl.AddVideo("06/05/2021",
               "2021_0605-(20KCTF1 - Out Of My Head (2002))",
               "https://youtu.be/rwyHCNnwlkM",
               "00:16:16")
$Ctrl.AddVideo("06/05/2021",
               "2021_0605-(20KDM3 - Insane Products (2006))",
               "https://youtu.be/EG8UyJSMK3Y",
               "00:11:25")

ForEach ($Item in $Ctrl.Videos.Output)
{
    $Description = Switch ($Item.Id)
    {
        F4HvOosnnG4 # 2023_0729-(Q3A Practice)
        {
            "Practicing running through Q3A in the least time."
        }
        efn3SmNPWS8 # 2023_0728-(Q3A Practice - Test Map)
        {
            "Practicing running through Q3A in the least time."
        }
        2376LUpG3_0 # 2023_0728-(Q3A Practice)
        {
            @("Quick video with commentary regarding the map built on [07/17/2023]",
            "which can be found in this GitHub repo link:",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant")
        }
        cbdJ-rWJbVI # 2023_0717-(Test Map)
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant")
        }
        -tGdz6oxXZI # 2023_0717-(GtkRadiant)
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant")
        }
        OpDG2mYlYM8 # 2023_0716-(Q3A Practice)
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant",
            "",
            "[Quake III Arena] beaten on Nightmare difficulty in 2h 26m etc.",
            "Not even close to the world record or anything like that, but I'm practicing"
            "in order to develop a guide to building levels for [Quake III Arena].")
        }
        aoS1HEDay4o # 2023_0715-(Q3A + GtkRadiant)
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant",
            "",
            "[Document Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Docs/20230710")
        }
        bQ46Pvp0tOo # 2023_0710-(Q3A Practice (Custom Maps 1/2))
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant",
            "",
            "[Document Information]",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Docs/20230710",
            "",
            "This video will be part of another video that provides commentary and",
            "documentation in relation to Quake III Arena, and its gameplay and mapping,",
            "GtkRadiant, game design, and programming.")
        }
        _siuaph1_vc # 2023_0710-(Q3A Practice (Custom Maps 2/2))
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant",
            "",
            "[Document Information]",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Docs/20230710",
            "",
            "This video will be part of another video that provides commentary and",
            "documentation in relation to Quake III Arena, and its gameplay and mapping,",
            "GtkRadiant, game design, and programming.")
        }
        RCkI2OFtCB4 # 2023_0708-(Q3A Practice)
        {
            @("[Video Information]",
            "https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant",
            "",
            "[Document Information]",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Docs/20230710",
            "",
            "This video will be part of another video that provides commentary and",
            "documentation in relation to Quake III Arena, and its gameplay and mapping,",
            "GtkRadiant, game design, and programming.")
        }
        rwyHCNnwlkM # 2021_0605-(20KCTF1 - Out Of My Head (2002))
        {
            "Recorded [06/05/2021]"
        }
        EG8UyJSMK3Y # 2021_0605-(20KDM3 - Insane Products (2006))
        {
            "Recorded [06/05/2021]"
        }
        dyHwm9AdkQs # 2021_0605-(20KDM1 - Tempered Graveyard (2001))
        {
            "Recorded [06/05/2021]"
        }
        xN53K9oGCME # 2021_0605-(20KDM2 - Return to Castle: Quake (2002))
        {
            "Recorded [06/05/2021]"
        }
        Hj8TaUgUh64 # 2021 05 28 06 01 57
        {
            @("Playing Q3A on several custom maps that I created about (20) years ago.",
            "I also briefly talk about these maps in this document:",
            "https://github.com/mcc85sx/FightingEntropy/blob/master/Documentation/2021_0128-A_Deep_Dive.pdf")
        }
    }

    $Item.SetDescription($Description)

    $Thumbnail = "{0}\{1}\thumbnail.jpg" -f $Ctrl.Videos.Path, $Item.Id
    $Item.SetThumbnail($Thumbnail)
}
#>

<# Videos -> Export Mode
$Ctrl.Videos.ExportAll()
#>

<# [News + Maps + Videos -> Import (files must exist)] #>
$Ctrl.News.ImportAll()
$Ctrl.Maps.ImportAll()
$Ctrl.Videos.ImportAll()

<# [Xaml -> Staging Event Handlers] #>
$Ctrl.StageXaml()

# [Invoke the GUI]
$Ctrl.Invoke()
