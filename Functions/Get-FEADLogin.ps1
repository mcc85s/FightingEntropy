<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEADLogin.ps1
          Solution: FightingEntropy Module
          Purpose: For validating an ADDS login, and then accessing NTDS information
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-14
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

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

    Add-Type -AssemblyName PresentationFramework

    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object]               $Node
        [Object]                 $IO
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 

                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If ( !$Xaml )
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ( $I in 0..( $This.Names.Count - 1 ) )
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }

    Class DGList
    {
        [String]$Name
        [Object]$Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    # (Get-Content $Home\Desktop\FEADLogin.xaml) | % { "'$_'," } | Set-Clipboard
    Class FEADLoginGUI
    {
        Static [String] $Tab = ('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://AD Login" Width="640" Height="400" Topmost="True" ResizeMode="NoResize" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox Margin="10">',
        '            <Grid>',
        '                <Grid.Resources>',
        '                    <Style TargetType="Grid">',
        '                        <Setter Property="Background" Value="LightYellow"/>',
        '                    </Style>',
        '                </Grid.Resources>',
        '                ',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="80"/>',
        '                    <RowDefinition Height="80"/>',
        '                    <RowDefinition Height="120"/>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <GroupBox Grid.Row="0" Header="[Username (NetBIOS/Name, or Username@Domain)]">',
        '                    <TextBox Name="UserName"/>',
        '                </GroupBox>',
        '                <GroupBox Grid.Row="1" Header="[Password / Confirm]">',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <PasswordBox Grid.Column="0" Name="Password"/>',
        '                        <PasswordBox Grid.Column="1" Name="Confirm"/>',
        '                    </Grid>',
        '                </GroupBox>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Grid.Column="0" Header="[Server (IP Address, NetBIOS or DNS Name)">',
        '                        <TextBox Name="Server"/>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1" Grid.Column="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <RadioButton Name="Switch" Content="Change Login Port" VerticalAlignment="Center" HorizontalAlignment="Center"/>',
        '                    <TextBox Name="Port" Grid.Row="0" Grid.Column="1" VerticalAlignment="Center" HorizontalAlignment="Center" TextAlignment="Left" Width="120" IsEnabled="False">389</TextBox>',
        '                    </Grid>',
        '                    <DataGrid Grid.Row="0" Grid.Column="1" Grid.RowSpan="2" Name="ServerList">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="100"/>',
        '                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="4">',
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

    Class Main
    {
        Hidden [String] $DnsDomain
        [String]                           $IPAddress
        [String]                             $DNSName
        [String]                              $Domain
        [String]                             $NetBIOS
        [UInt32]                                $Port
        [Object]                          $Credential
        [String]                            $Username
        [Object]                            $Password
        [Object]                             $Confirm
        [Object]                                $Test
        [String]                                  $DC
        [String]                           $Directory
        [Object]                            $Searcher
        [Object]                              $Result
        Main()                            # ParamSet0
        {
            $This.DNSDomain         = $Null
            $TestDnsServer     = $Null
            If ($Env:UserDNSDomain)
            {
                $This.DNSDomain   = $Env:UserDNSDomain.ToLower()
            }
            If (!$Env:UserDNSDomain)
            {
                $This.DNSDomain   = Get-WMIObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True' AND DHCPEnabled='True'" | % DNSDomain
                If ($This.DNSDomain.Count -gt 1)
                {
                    ForEach ($Server in $This.DnsDomain)
                    {
                        $TestDnsServer = [System.Net.Dns]::Resolve($Server)
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
            $This.IPAddress    = [System.Net.Dns]::Resolve($This.Domain).AddressList | Select-Object -First 1 | % IPAddressToString
            $This.DNSName      = [System.Net.Dns]::Resolve($This.IPAddress).Hostname
            $This.NetBIOS      = $Null
            $This.Port         = 389
        }
        Main([IPAddress]$IPAddress)       # ParamSet1
        {
            $This.IPAddress    = $IPAddress
            $This.DNSName      = [System.Net.Dns]::Resolve($This.IPAddress).HostName
            $This.Domain       = $This.PullDomain($This.DNSName)
            $This.NetBIOS      = $Null
            $This.Port         = 389
        }
        Main([String]$Domain)             # ParamSet2
        {
            $This.Domain       = $Domain.ToString()
            $This.IPAddress    = [System.Net.Dns]::Resolve($Domain).AddressList      | Select-Object -First 1 | % IPAddressToString
            $This.DNSName      = [System.Net.Dns]::Resolve($This.IPAddress).HostName
            $This.NetBIOS      = $Null
            $This.Port         = 389
        }
        Main([Object]$Target)             # ParamSet3
        {
            $This.IPAddress    = $Target.IPAddress
            $This.DNSName      = $Target.Hostname
            $This.Domain       = $This.PullDomain($Target.Hostname)
            $This.NetBIOS      = $Target.NetBIOS
            $This.Port         = 389
        }
        [String] PullDomain([String]$Hostname)
        {
            Return $Hostname.Replace($Hostname.Split(".")[0],'').TrimStart(".")
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
                [System.Windows.Messagebox]::Show("Port missing...","Error")
                $This.ClearADCredential()
            }

            ElseIf (!$This.Username)
            {
                [System.Windows.Messagebox]::Show("Username","Error")
                $This.ClearADCredential()
            }
        
            ElseIf (!$This.Password)
            {
                [System.Windows.MessageBox]::Show("Password","Error")
                $This.ClearADCredential()
            }
        
            ElseIf ($This.Password -notmatch $This.Confirm)
            {
                [System.Windows.Messagebox]::Show("Confirm","Error")
                $This.ClearADCredential()
            }
            
            Else
            {
                $This.Credential   = [System.Management.Automation.PSCredential]::New($This.Username,$This.Password)
            }
        }
        CheckADServer([Object]$Xaml)
        {
            $Resolve = [System.Net.Dns]::Resolve($Xaml.IO.Server.Text)

            If (!$Resolve)
            {
                [System.Windows.MessageBox]::Show("Invalid server address defined","Error") 
                $This.DC       = $Null
            }
            ElseIf ($Resolve.Hostname -inotmatch $This.DnsDomain)
            {
                [System.Windows.MessageBox]::Show("Unable to resolve the domain name","Error")
                $This.DC       = $Null
            }
            ElseIf ($Resolve.Hostname -ieq $This.DnsDomain)
            {
                $This.Domain   = $Resolve.HostName
                $This.DNSName  = [System.Net.DNS]::Resolve($Resolve.AddressList[0]).HostName
                $This.DC       = $This.DNSName
            }
            Else
            {
                $HostID        = $Resolve.Hostname.Replace($This.DnsDomain,"")
                $This.Domain   = [System.Net.DNS]::Resolve($Resolve.HostName).HostName.Replace($HostID,"")
                $This.DNSName  = [System.Net.DNS]::Resolve($Resolve.HostName).Hostname
                $This.DC       = $This.DNSName
            }
        }
        TestADCredential()
        {       
            $This.Directory    = "LDAP://$($This.DNSName):$($This.Port)/CN=Partitions,CN=Configuration,DC=$($This.Domain.Split('.') -join ',DC=')"
            $This.Test         = [System.DirectoryServices.DirectoryEntry]::New($This.Directory,$This.Credential.Username,$This.Credential.GetNetworkCredential().Password)
            Try 
            {
                $This.Test
                $This.Searcher            = [System.DirectoryServices.DirectorySearcher]::New()
                $This.Searcher            | % { 
                    
                    $_.SearchRoot       = [System.DirectoryServices.DirectoryEntry]::New($This.Directory,$This.Credential.Username,$This.Credential.GetNetworkCredential().Password)
                    $_.PageSize         = 1000
                    $_.PropertiestoLoad.Clear()
                }

                $This.Result              = $This.Searcher | % FindAll
                If (!$This.NetBIOS)
                {
                    $This.NetBIOS         = $This.GetNetBIOSName()
                }
            }

            Catch
            {
                [System.Windows.Messagebox]::Show("Login","Error")
                $This.ClearADCredential()
                $This.Directory = $Null
                $This.DC        = $Null
                $This.Test      = $Null
            }
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
    }

    $Xaml = [XamlWindow][FEADLoginGUI]::Tab
    $Main = Switch($PSCmdLet.ParameterSetName)
    {
        0 { [Main]::New() }
        1 { [Main]::New([IPAddress]$IPAddress) }
        2 { [Main]::New([String]$Domain) }
        3 { [Main]::New([Object]$Target) }
    }

    $Xaml.IO.ServerList.ItemsSource = @( )
    ForEach ($Item in "IPAddress DNSName Domain NetBIOS" -Split " ")
    {
        $Xaml.IO.ServerList.ItemsSource += [DGList]::New($Item,$Main.$Item)
    }

    $Xaml.IO.ServerList.Add_SelectionChanged(
    {
        $Item                            = $Xaml.IO.ServerList.SelectedItem
        $Xaml.IO.Server.Text             = $Item.Value 
    })

    $Xaml.IO.Switch.Add_Checked(
    {
        $Xaml.IO.Port.IsEnabled          = 1
    })
    
    $Xaml.IO.Ok.Add_Click(
    {
        $Main.CheckADCredential($Xaml)
        If ($Main.Credential)
        {
            $Main.CheckADServer($Xaml)
        }
        If ($Main.DC)
        {
            $Main.TestADCredential()
        }
        If (!$Main.Test.DistinguishedName)
        {
            [System.Windows.MessageBox]::Show("Invalid login","Error")
        }
        If ($Main.Test.DistinguishedName)
        {
            $Xaml.IO.DialogResult = $True
        }
    })

    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })

    $Xaml.Invoke()
    If ($Xaml.IO.DialogResult)
    {
        $Main
    }

    If (!$Xaml.IO.DialogResult)
    {
        Write-Theme "Error [!] Either the user cancelled or the dialog failed" 12,4,15,0
    }
}
