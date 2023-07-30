    
# Function Invoke-ShoppingMaul
# {
    Class NewsEntryItem
    {
        [UInt32]   $Index
        [String]    $Date
        [String]   $Title
        [String] $Content
        NewsEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Content)
        {
            $This.Index   = $Index
            $This.Date    = $Date
            $This.Title   = $Title
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.NewsEntry[Item]>"
        }
    }

    Class NewsEntryList
    {
        [Object] $Output
        NewsEntryList()
        {
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
        [String] ToString()
        {
            Return "<ShoppingMaul.NewsEntry[List]>"
        }
    }

    Class MapEntryItem
    {
        [UInt32]    $Index
        [String]     $Date
        [String]    $Title
        [String]    $Image
        [String] $Resource
        MapEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Image,[String]$Resource)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Title    = $Title
            $This.Image    = $Image
            $This.Resource = $Resource
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.MapEntry[Item]>"
        }
    }

    Class MapEntryList
    {
        [Object] $Output
        MapEntryList()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] MapEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Image,[String]$Resource)
        {
            Return [MapEntryItem]($Index,$Date,$Title,$Image,$Resource)
        }
        Add([String]$Date,[String]$Title,[String]$Image,[String]$Resource)
        {
            $This.Output += $This.MapEntryItem($This.Output.Count,$Date,$Title,$Image,$Resource)
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.MapEntry[List]>"
        }
    }

    Class VideoEntryItem
    {
        [UInt32]    $Index
        [String]     $Date
        [String]    $Title
        [String] $Resource
        NewsEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Resource)
        {
            $This.Index   = $Index
            $This.Date    = $Date
            $This.Title   = $Title
            $This.Resource = $Resource
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.VideoEntry[Item]>"
        }
    }

    Class VideoEntryList
    {
        [Object] $Output
        VideoEntryList()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VideoEntryItem([UInt32]$Index,[String]$Date,[String]$Title,[String]$Resource)
        {
            Return [VideoEntryItem]::New($Index,$Date,$Title,$Resource)
        }
        Add([String]$Date,[String]$Title,[String]$Resource)
        {
            $This.Output += $This.VideoEntryItem($This.Output.Count,$Date,$Title,$Resource)
        }
        [String] ToString()
        {
            Return "<ShoppingMaul.VideoEntry[List]>"
        }
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
            Return "<FEModule.XamlWindow[VmControllerXaml]>"
        }
    }

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
        '        <Image Source="C:\Users\mcadmin\Documents\20230728-(Xaml)\banner1.jpg"/>',
        '        <TabControl Grid.Row="1">',
        '            <TabItem Header="News">',
        '                <Grid>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="85"/>',
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
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Date"',
        '                                                    Binding="{Binding Date}"',
        '                                                    Width="85"/>',
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
        '                                 TextWrapping="Wrap"',
        '                                 VerticalAlignment="Top"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Maps">',
        '            </TabItem>',
        '            <TabItem Header="Videos">',
        '            </TabItem>',
        '            <TabItem Header="About">',
        '            </TabItem>',
        '        </TabControl>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ShoppingMaulController
    {
        [Object] $Xaml
        [Object] $News
        [Object] $Maps
        [Object] $Videos
        [Object] $Contact
        ShoppingMaulController()
        {
            $This.Xaml    = [XamlWindow][ShoppingMaulXaml]::Content
            $This.News    = [NewsEntryList]::New()
            $This.Maps    = [MapEntryList]::New()
            $This.Videos  = [VideoEntryList]::New()
            $This.Contact = Get-FEModule -Mode 1
        }
        Reset([Object]$xSender,[Object]$List)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $List)
            {
                $xSender.Items.Add($Item)
            }
        }
    }

 #   [ShoppingMaulController]::New()
#}

#$Ctrl = Invoke-ShoppingMaul

$Ctrl = [ShoppingMaulController]::New()

# Load object
$Ctrl.News.Add("07/29/2023","Shopping Maul [Xaml]",@"
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
"@)

$Ctrl.Reset($Ctrl.Xaml.IO.NewsList,$Ctrl.News.Output)

$Ctrl.Xaml.IO.NewsList.Add_SelectionChanged(
{
    $Index                         = $Ctrl.Xaml.IO.NewsList.SelectedIndex
    $Ctrl.Xaml.IO.NewsTitle.Text   = $Null
    $Ctrl.Xaml.IO.NewsContent.Text = $Null

    If ($Index -ne -1)
    {
        $Item = $Ctrl.News.Output[$Index]
        $Ctrl.Xaml.IO.NewsTitle.Text   = $Item.Title
        $Ctrl.Xaml.IO.NewsContent.Text = $Item.Content
    }
})

$Ctrl.Xaml.Invoke()
