<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:47:54                                                                  //
 \\==================================================================================================// 

    FileName   : Get-FEADLogin.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For validating an ADDS login, and then accessing NTDS information
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-FEADLogin
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [ValidatePattern("(\d+\.){3}\d+")]
        [Parameter(ParameterSetName=1)][IPAddress]$IPAddress,
        [ValidatePattern("^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2, 6}$")]
        [Parameter(ParameterSetName=2)][String]$DNSName,
        [ValidateScript({$_.IPAddress,$_.Hostname,$_.NetBIOS})]
        [Parameter(ParameterSetName=3)][Object]$Target
    )

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

    Enum ServerType
    {
        IPAddress
        DNSName
        Domain
        NetBIOS
    }

    Class ServerTypeItem
    {
        [UInt32] $Index
        [String]  $Name
        [String] $Value
        ServerTypeItem([String]$Name,[String]$Value)
        {
            $This.Index = [UInt32][ServerType]::$Name
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class ServerTypeList
    {
        [Object] $Output
        ServerTypeList()
        {
            $This.Output = @( )
        }
        [Object] ServerTypeItem([String]$Name,[String]$Value)
        {
            Return [ServerTypeItem]::New($Name,$Value)
        }
        Add([String]$Name,[String]$Value)
        {
            $This.Output += $This.ServerTypeItem($Name,$Value)
        }
    }

    Class FEADLoginXaml
    {
        Static [String] $Content = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://AD Login" Width="640" Height="390" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="Height" Value="24"/>',
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
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="FontWeight" Value="SemiBold"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="TextBox" x:Key="Block">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="170"/>',
        '            <Setter Property="FontFamily" Value="System"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '            <Setter Property="AcceptsReturn" Value="True"/>',
        '            <Setter Property="VerticalAlignment" Value="Top"/>',
        '            <Setter Property="TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Top"/>',
        '            <Setter Property="VerticalScrollBarVisibility" Value="Visible"/>',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="AutoGenerateColumns" Value="False"/>',
        '            <Setter Property="AlternationCount" Value="2"/>',
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
        '                    <Setter Property="Background" Value="#FFD6FFFB"/>',
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
        '        <Grid.Background>',
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox Margin="10">',
        '            <Grid>',
        '                <Grid.Resources>',
        '                    <Style TargetType="Grid">',
        '                        <Setter Property="Background" Value="LightYellow"/>',
        '                    </Style>',
        '                </Grid.Resources>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="120"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Label   Grid.Row="0" Content="[Login]: Access Active Directory Resources"/>',
        '                <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                <Grid    Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label   Grid.Column="0" Content="[Username]:"/>',
        '                    <TextBox Grid.Column="1" Name="UserName"/>',
        '                </Grid>',
        '                <Grid    Grid.Row="3">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label       Grid.Column="0" Content="[Password]:"/>',
        '                    <PasswordBox Grid.Column="1" Name="Password"/>',
        '                    <Label       Grid.Column="2" Content="[Confirm]:"/>',
        '                    <PasswordBox Grid.Column="3" Name="Confirm"/>',
        '                </Grid>',
        '                <Border   Grid.Row="4" Background="Black" BorderThickness="0" Margin="4"/>',
        '                <Grid     Grid.Row="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="10"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label   Grid.Row="0" Content="[Connection]: IP Address/DNS Name &amp; Port"/>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="80"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label   Grid.Column="0" Content="[Server]:"/>',
        '                            <TextBox Grid.Column="1" Name="Server"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="2" Grid.Column="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <RadioButton Name="Switch" Content="Change Login Port" VerticalAlignment="Center" HorizontalAlignment="Center"/>',
        '                            <TextBox Name="Port" Grid.Row="0" Grid.Column="1" VerticalAlignment="Center" HorizontalAlignment="Center" TextAlignment="Left" Width="120" IsEnabled="False">389</TextBox>',
        '                        </Grid>',
        '                    </Grid>',
        '                    <Border   Grid.Column="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                    <DataGrid Grid.Column="2" Grid.RowSpan="2" Name="ServerList">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="100"/>',
        '                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Border   Grid.Row="6" Background="Black" BorderThickness="0" Margin="4"/>',
        '                <Grid Grid.Row="7">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Name="Ok" Content="Ok" Grid.Column="0" Grid.Row="1" Margin="5"/>',
        '                    <Button Name="Cancel" Content="Cancel" Grid.Column="1" Grid.Row="1" Margin="5"/>',
        '                </Grid>',
        '            </Grid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class FEADLoginController
    {
        [Object]             $Xaml
        [Object]       $ServerList
        Hidden [String] $DnsDomain
        [String]        $IPAddress
        [String]          $DNSName
        [String]           $Domain
        [String]          $NetBIOS
        [UInt32]             $Port
        [Object]       $Credential
        [String]         $Username
        [Object]         $Password
        [Object]          $Confirm
        [Object]             $Test
        [String]               $DC
        [String]        $Directory
        [Object]         $Searcher
        [Object]           $Result
        FEADLoginController()
        {
            $This.DnsDomain    = $Null
            $TestDnsServer     = $Null
            If ($This.UserDnsDomain())
            {
                $This.DnsDomain   = $This.UserDnsDomain().ToLower()
            }
            If (!$This.UserDnsDomain())
            {
                $This.DnsDomain   = $This.Config()| ? IPEnabled | ? DhcpEnabled | % DnsDomain
                If ($This.DNSDomain.Count -gt 1)
                {
                    ForEach ($Server in $This.DnsDomain)
                    {
                        $TestDnsServer = $This.Resolve($Server)
                        If ($TestDnsServer)
                        {
                            $This.DnsDomain = $TestDnsServer.Hostname
                            Break
                        }
                    }
                }
                If ($This.DnsDomain.Count -eq 0)
                {
                    Throw "Could not locate a valid server"
                }
            }
            $This.Domain       = $This.DnsDomain
            $This.IPAddress    = $This.Resolve($This.Domain).AddressList | Select-Object -First 1 | % IPAddressToString
            $This.DNSName      = $This.Resolve($This.IPAddress).Hostname
            $This.NetBIOS      = $Null
            $This.Port         = 389
            $This.StageXaml()
        }
        FEADLoginController([IPAddress]$IPAddress)
        {
            $This.IPAddress    = $IPAddress
            $This.DNSName      = $This.Resolve($This.IPAddress).HostName
            $This.Domain       = $This.PullDomain($This.DNSName)
            $This.DnsDomain    = $This.DnsDomain
            $This.NetBIOS      = $Null
            $This.Port         = 389
            $This.StageXaml()
        }
        FEADLoginController([String]$Domain)
        {
            $This.Domain       = $Domain.ToString()
            $This.IPAddress    = $This.Resolve($Domain).AddressList | Select-Object -First 1 | % IPAddressToString
            $This.DNSName      = $This.Resolve($This.IPAddress).HostName
            $This.DnsDomain    = $This.DnsName
            $This.NetBIOS      = $Null
            $This.Port         = 389
            $This.StageXaml()
        }
        FEADLoginController([Object]$Target)
        {
            $This.IPAddress    = $Target.IPAddress
            $This.DNSName      = $Target.Hostname
            $This.Domain       = $This.PullDomain($Target.Hostname)
            $This.DnsDomain    = $This.Domain
            $This.NetBIOS      = $Target.NetBIOS
            $This.Port         = 389
            $This.StageXaml()
        }
        [Object] Resolve([String]$Target)
        {
            Return [System.Net.Dns]::Resolve($Target)
        }
        [Object] Config()
        {
            Return Get-WMIObject Win32_NetworkAdapterConfiguration
        }
        [String] UserDnsDomain()
        {
            Return [Environment]::UserDNSDomain
        }
        [Object] Message([String]$Title)
        {
            Return [System.Windows.Messagebox]::Show($Title,"Error [!]")
        }
        [Object] Credential([String]$Username,[SecureString]$Password)
        {
            Return [System.Management.Automation.PSCredential]::New($Username,$Password)
        }
        [Object] DirectoryEntry([String]$Directory,[PSCredential]$Credential)
        {
            Return [System.DirectoryServices.DirectoryEntry]::New($This.Directory,
                                                                  $Credential.Username,
                                                                  $Credential.GetNetworkCredential().Password)
        }
        [Object] DirectorySearcher()
        {
            Return [System.DirectoryServices.DirectorySearcher]::New()
        }
        [Object] GetFEADLoginXaml()
        {
            Return [XamlWindow][FEADLoginXaml]::Content
        }
        [Object] GetServerTypeList()
        {
            Return [ServerTypeList]::New()
        }
        [String] PullDomain([String]$Hostname)
        {
            Return $Hostname.Replace($Hostname.Split(".")[0],'').TrimStart(".")
        }
        [String] GetDomain([String]$Hostname)
        {
            $Node         = $This.Resolve($Hostname)
            $HostID       = $Null
            $DomainID     = $Null
            $Temp         = $Null
            If ($Node)
            {
                $Temp     = $Node.Hostname.Split(".")[0]
                $HostID   = $This.Resolve($Temp)
                If ($HostID)
                {
                    $DomainID = $Hostname.Replace($Temp,"").TrimStart(".")
                }
                If (!$HostID)
                {
                    $DomainID = $HostID.Hostname
                }
            }
            Return $DomainID
        }
        [Object] Search([String]$Field)
        {
            Return @( ForEach ( $Item in $This.Result ) { $Item.Properties | ? $Field.ToLower() } )
        }
        [String] GetSiteName()
        {
            Return @( $This.Search("fsmoroleowner").fsmoroleowner.Split(",")[3].Split("=")[1] )
        }
        [String] GetNetBIOSName()
        {
            Return @( $This.Search("netbiosname").netbiosname )
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            $xSender.Items.Clear()
            ForEach ($item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        ClearADCredential()
        {
            $This.Credential   = $Null
            $This.Username     = $Null
            $This.Password     = $Null
            $This.Confirm      = $Null
        }
        CheckADCredential([Object]$Xaml)
        {
            $This.Port         = $Xaml.IO.Port.Text
            $This.Username     = $Xaml.IO.Username.Text
            $This.Password     = $Xaml.IO.Password.SecurePassword
            $This.Confirm      = $Xaml.IO.Confirm.SecurePassword

            If (!$This.Port)
            {
                $This.Message("Port missing...")
                $This.ClearADCredential()
            }
            ElseIf (!$This.Username)
            {
                $This.Message("Username")
                $This.ClearADCredential()
            }
            ElseIf (!$This.Password)
            {
                $This.Message("Password")
                $This.ClearADCredential()
            }
            ElseIf ($This.Password -notmatch $This.Confirm)
            {
                $This.Message("Confirm")
                $This.ClearADCredential()
            }
            Else
            {
                $This.Credential   = $This.Credential($This.Username,$This.Password)
            }
        }
        CheckADServer([Object]$Xaml)
        {
            $xResolve = $This.Resolve($Xaml.IO.Server.Text)

            If (!$xResolve)
            {
                $This.Message("Invalid server address defined") 
                $This.DC       = $Null
            }
            ElseIf ($xResolve.Hostname -inotmatch $This.DnsDomain)
            {
                $This.Message("Unable to resolve the domain name")
                $This.DC       = $Null
            }
            ElseIf ($xResolve.Hostname -ieq $This.DnsDomain)
            {
                $This.Domain   = $xResolve.HostName
                $This.DNSName  = $This.Resolve($xResolve.AddressList[0]).HostName
                $This.DC       = $This.DNSName
            }
            Else
            {
                $HostID        = $xResolve.Hostname.Replace($This.DnsDomain,"")
                $This.Domain   = $This.Resolve($xResolve.HostName).HostName.Replace($HostID,"")
                $This.DNSName  = $This.Resolve($xResolve.HostName).Hostname
                $This.DC       = $This.DNSName
            }
        }
        TestADCredential()
        {       
            $This.Directory    = "LDAP://$($This.DNSName):$($This.Port)/CN=Partitions,CN=Configuration,DC=$($This.Domain.Split('.') -join ',DC=')"
            $This.Test         = $This.DirectoryEntry($This.Directory,$This.Credential)
            Try 
            {
                $This.Test.DistinguishedName
            }

            Catch
            {
                $This.Message("Login")
                $This.ClearADCredential()
                $This.Directory = $Null
                $This.DC        = $Null
                $This.Test      = $Null
            }
            
            Finally
            {
                If ($This.Test.DistinguishedName)
                {
                    $This.Searcher  = $Item = $This.DirectorySearcher()
                    $Item.SearchRoot        = $This.DirectoryEntry($This.Directory,$This.Credential)
                    $Item.PageSize          = 1000
                    $Item.PropertiestoLoad.Clear()
                    $This.Result              = $This.Searcher | % FindAll

                    If (!$This.NetBIOS)
                    {
                        $This.NetBIOS         = $This.GetNetBIOSName()
                    }
                }
            }
        }
        StageXaml()
        {
            $Ctrl              = $This
            $This.Xaml         = $This.GetFEADLoginXaml()
            $This.ServerList   = $This.GetServerTypeList()
            
            ForEach ($Name in [System.Enum]::GetNames([ServerType]))
            {
                $This.ServerList.Add($Name,$This.$Name)
            }

            $This.Reset($This.Xaml.IO.ServerList,$This.ServerList.Output)

            $Ctrl.Xaml.IO.ServerList.Add_SelectionChanged(
            {
                $Item                            = $Ctrl.Xaml.IO.ServerList.SelectedItem
                $Ctrl.Xaml.IO.Server.Text        = $Item.Value 
            })
        
            $Ctrl.Xaml.IO.Switch.Add_Checked(
            {
                $Ctrl.Xaml.IO.Port.IsEnabled          = 1
            })
            
            $Ctrl.Xaml.IO.Ok.Add_Click(
            {
                Switch -Regex ($Ctrl.Xaml.IO.Server.Text)
                {
                    "(\d+\.){3}\d+"
                    {
                        $Ctrl.IPAddress          = $Ctrl.Xaml.IO.Server.Text
                        $Ctrl.Xaml.IO.ServerList | ? Name -eq IPAddress | % { $_.Value = $Ctrl.IPAddress }
                        $Node                    = $Ctrl.Resolve($Ctrl.IPAddress)
                        $Ctrl.DnsDomain          = $Ctrl.GetDomain($Node.Hostname)
                    }
                    "^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2, 6}$"
                    {
                        $Node                    = $Ctrl.Resolve($Ctrl.Xaml.IO.Server.Text)
                        $Ctrl.DnsDomain          = $Ctrl.GetDomain($Node.Hostname)
                    }
                }

                $Ctrl.CheckADCredential($Ctrl.Xaml)

                If ($Ctrl.Credential)
                {
                    $Ctrl.CheckADServer($Ctrl.Xaml)
                }
                If ($Ctrl.DC)
                {
                    $Ctrl.TestADCredential()
                }
                If (!$Ctrl.Test.DistinguishedName)
                {
                    $Ctrl.Message("Invalid login")
                }
                If ($Ctrl.Test.DistinguishedName)
                {
                    $Ctrl.Xaml.IO.DialogResult = 1
                }
            })
        
            $Ctrl.Xaml.IO.Cancel.Add_Click(
            {
                $Ctrl.Xaml.IO.DialogResult = 0
            })
        }
        [String] ToString()
        {
            Return @($This.Directory.Replace("CN=Partitions,CN=Configuration,",""))
        }
    }

    $Ctrl = Switch ($PSCmdLet.ParameterSetName)
    {
        0 { [FEADLoginController]::New()                      }
        1 { [FEADLoginController]::New([IPAddress]$IPAddress) }
        2 { [FEADLoginController]::New([String]$Domain)       }
        3 { [FEADLoginController]::New([Object]$Target)       }
    }
            
    $Ctrl.Xaml.Invoke()

    If (!$Ctrl.Xaml.IO.DialogResult)
    {
        Write-Theme "Error [!] Either the user cancelled or the dialog failed" 1
    }
    Else
    {
        $Ctrl
    }
}
