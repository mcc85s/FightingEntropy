Function Search-WirelessNetwork
{
    Add-Type -AssemblyName System.Runtime.WindowsRuntime,PresentationFramework

    Function Await ([Object]$WinRtTask,[Object]$ResultType)
    {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }

    Class TxSsid
    {
        [UInt32] $Index
        Hidden [Object] $Ssid
        [String] $Name
        [Object] $Bssid
        [String] $Type
        Hidden [UInt32] $TypeSlot
        Hidden [String] $TypeDescription
        [Object] $Uptime
        [String] $NetworkType
        [String] $Authentication
        Hidden [UInt32] $AuthenticationSlot
        Hidden [String] $AuthenticationDescription
        [String] $Encryption
        Hidden [UInt32] $EncryptionSlot
        Hidden [String] $EncryptionDescription
        [UInt32] $Strength
        [String] $BeaconInterval
        [Double] $ChannelFrequency
        [Bool]   $IsWifiDirect
        TxSsid([UInt32]$Index,[Object]$Object)
        {
            $This.Index              = $Index
            $This.Ssid               = $Object
            $This.Name               = $Object.Ssid
            $This.Bssid              = $Object.Bssid
            $This.GetPhyType($Object.PhyKind)
            $This.Uptime             = $Object.Uptime
            $This.NetworkType        = $Object.NetworkKind
            $This.Authentication     = $Object.SecuritySettings.NetworkAuthenticationType
            $This.GetNetAuthType($This.Authentication)
            $This.Encryption         = $Object.SecuritySettings.NetworkEncryptionType
            $This.GetNetEncType($This.Encryption)
            $This.Strength           = $Object.SignalBars
            $This.BeaconInterval     = $Object.BeaconInterval
            $This.ChannelFrequency   = $Object.ChannelCenterFrequencyInKilohertz
            $This.IsWiFiDirect       = $Object.IsWiFiDirect
        }
        GetPhyType([String]$PhyKind)
        {
            $This.TypeSlot           = ("Unknown Fhss Dsss IRBaseband Ofdm Hrdsss Erp HT Vht Dmg HE" -Split " ").IndexOf($PhyKind)
            $This.TypeDescription    = Switch ($PhyKind)
            {
                Unknown    { "Unspecified PHY type"                                }
                Fhss       { "Frequency-hopping, spread-spectrum (FHSS) PHY."      }
                Dsss       { "Direct sequence, spread-spectrum (DSSS) PHY."        }
                IRBaseband { "Infrared (IR) baseband PHY."                         }
                Ofdm       { "Orthogonal frequency division multiplex (OFDM) PHY." }
                Hrdsss     { "High-rated DSSS (HRDSSS) PHY."                       }
                Erp        { "Extended Rate (ERP) PHY." }
                HT         { "High Throughput (HT) PHY for 802.11n PHY." }
                Vht        { "Very High Throughput (VHT) PHY for 802.11ac PHY." }
                Dmg        { "Directional multi-gigabit (DMG) PHY for 802.11ad." }
                HE         { "High-Efficiency Wireless (HEW) PHY for 802.11ax." }
            }

            $This.Type               = @("Unknown",[Regex]::Matches($this.TypeDescription,"(802\.11\w+)").Value)[$This.TypeDescription -match 802.11]
        }
        GetNetAuthType([String]$Auth)
        {
            $This.AuthenticationSlot = ("None Unknown Open80211 SharedKey80211 Wpa WpaPsk WpaNone Rsna RsnaPsk Ihv Wpa3 Wpa3Enterprise192Bits Wpa3Sae Owe Wpa3Enterprise" -Split " ").IndexOf($Auth)
            $This.AuthenticationDescription = Switch -Regex ($Auth)
            {
                "(^None$)" {"No authentication enabled."}
                "(^Unknown$)" {"Authentication method unknown."}
                "(^Open80211$)" {"Open authentication over 802.11 wireless.Devices are authenticated and can connect to an access point, but communication with the network requires a matching Wired Equivalent Privacy (WEP) key."}
                "(^SharedKey80211$)" { "Specifies an IEEE 802.11 Shared Key authentication algorithm that requires the use of a pre-shared Wired Equivalent Privacy (WEP) key for the 802.11 authentication."}
                "(^Wpa$)"            { "Specifies a Wi-Fi Protected Access (WPA) algorithm. IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server. Cipher keys are dynamically derived through the authentication process."}
                "(^WpaPsk$)" {"Specifies a Wi-Fi Protected Access (WPA) algorithm that uses pre-shared keys (PSK). IEEE 802.1X port authorization is performed by the supplicant and authenticator. Cipher keys are dynamically derived through a pre-shared key that is used on both the supplicant and authenticator."}
                "(^WpaNone$)" {"Wi-Fi Protected Access."}
                "(^Rsna$)" {"Specifies an IEEE 802.11i Robust Security Network Association (RSNA) algorithm. IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server. Cipher keys are dynamically derived through the authentication process."}
                "(^RsnaPsk$)" {"Specifies an IEEE 802.11i RSNA algorithm that uses PSK. IEEE 802.1X port authorization is performed by the supplicant and authenticator. Cipher keys are dynamically derived through a pre-shared key that is used on both the supplicant and authenticator."}
                "(^Ihv$)" {"Specifies an authentication type defined by an independent hardware vendor (IHV)."}
                "(^Wpa3$|^Wpa3Enterprise192Bits$)" { "Specifies a 192-bit encryption mode for Wi-Fi Protected Access 3 Enterprise (WPA3-Enterprise) networks."}
                "(^Wpa3Sae$)" {"Specifies a Wi-Fi Protected Access 3 Simultaneous Authentication of Equals (WPA3 SAE) algorithm. WPA3 SAE is the consumer version of WPA3. Simultaneous Authentication of Equals (SAE) is a secure key establishment protocol between devices; it provides synchronous authentication, and stronger protections for users against password-guessing attempts by third parties."}
                "(^Owe$)" {"Specifies an opportunistic wireless encryption (OWE) algorithm. OWE provides opportunistic encryption over 802.11 wireless, where cipher keys are dynamically derived through a Diffie-Hellman key exchange; enabling data protection without authentication."}
                "(^Wpa3Enterprise$)" {"Specifies a Wi-Fi Protected Access 3 Enterprise (WPA3-Enterprise) algorithm. WPA3-Enterprise uses IEEE 802.1X in a similar way as RSNA, but provides increased security through the use of mandatory certificate validation and protected management frames."}
            }
        }
        GetNetEncType([String]$Enc)
        {
            $This.EncryptionSlot = ("None Unknown Wep Wep40 Wep104 Tkip Ccmp WpaUseGroup RsnUseGroup Ihv Gcmp Gcmp256" -Split " ").IndexOf($Enc)
            $This.EncryptionDescription = Switch ($Enc)
            {
                None        { "No encryption enabled."   }
                Unknown     {"Encryption method unknown."}
                Wep         {"Specifies a WEP cipher algorithm with a cipher key of any length."}
                Wep40       {"Specifies a Wired Equivalent Privacy (WEP) algorithm, which is the RC4-based algorithm that is specified in the IEEE 802.11-1999 standard. This enumerator specifies the WEP cipher algorithm with a 40-bit cipher key."}
                Wep104      {"Specifies a WEP cipher algorithm with a 104-bit cipher key."}
                Tkip        {"Specifies a Temporal Key Integrity Protocol (TKIP) algorithm, which is the RC4-based cipher suite that is based on the algorithms that are defined in the WPA specification and IEEE 802.11i-2004 standard. This cipher also uses the Michael Message Integrity Code (MIC) algorithm for forgery protection."}
                Ccmp        {"Specifies an AES-CCMP algorithm, as specified in the IEEE 802.11i-2004 standard and RFC 3610. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197."}
                WpaUseGroup {"Specifies a Wifi Protected Access (WPA) Use Group Key cipher suite. For more information about the Use Group Key cipher suite, refer to Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."}
                RsnUseGroup {"Specifies a Robust Security Network (RSN) Use Group Key cipher suite. For more information about the Use Group Key cipher suite, refer to Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."}
                Ihv         {"Specifies an encryption type defined by an independent hardware vendor (IHV)."}
                Gcmp        {"Specifies an AES-GCMP algorithm, as specified in the IEEE 802.11-2016 standard, with a 128-bit key. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197."}
                Gcmp256     { "Specifies an AES-GCMP algorithm, as specified in the IEEE 802.11-2016 standard, with a 256-bit key. Advanced Encryption Standard (AES) is the encryption algorithm defined in FIPS PUB 197." }
            }
        }
    }

    Class Wireless
    {
        [Object] $WiFi
        [Object] $Output
        Wireless()
        {
            $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'})[0]
            Add-Type -AssemblyName System.Runtime.WindowsRuntime

            # Radios, RadioAccess
            [Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType=WindowsRuntime] | Out-Null
            [Windows.Devices.Radios.RadioAccessStatus, Windows.System.Devices, ContentType=WindowsRuntime] | Out-Null
            Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus])
            $This.WiFi = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]) | ? Kind -eq WiFi
            [Windows.Devices.Radios.RadioState, Windows.System.Devices, ContentType=WindowsRuntime] | Out-Null
        }
        [Object[]] Scan()
        {
            $Res = $Null
            $This.Output = @( )
            $This.Wifi | ? State -eq On | % {

                [Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, Contenttype=WindowsRuntime] | Out-Null
                $Res = Await ([Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync())([System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]])
                $Res.NetworkReport.AvailableNetworks | % { $This.Output += [TxSsid]::New($This.Output.Count,$_) }
            
            } | Sort-Object Strength -Descending

            ForEach ($X in 0..($This.Output.Count-1))
            {
                $This.Output[$X].Index = $X
            }

            Return $This.Output
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

    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object[]]            $Types
        [Object]               $Node
        [Object]                 $IO
        [String]          $Exception
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

            ForEach ($I in 0..($This.Names.Count - 1))
            {
                $Name                = $This.Names[$I]
                $Object              = $This.IO.FindName($Name)
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If ($Object -ne $Null)
                {
                    $This.Types         += [DGList]::New($Name,$This.IO.FindName($Name).GetType().Name)
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
                $This.Exception = $PSItem
            }
        }
    }

    # (Get-Content $home\Desktop\Wireless.xaml).Split("`n") | % { "        '$_'," } | Set-Clipboard
    Class WirelessGUI
    {
        Static [String] $Tab = (        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Wireless Network Scanner" Width="800" Height="650" HorizontalAlignment="Center" Topmost="True" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
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
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Background>',
        '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
        '        </Grid.Background>',
        '        <GroupBox>',
        '            <Grid Margin="5">',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="50"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="80"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <ComboBox Grid.Column="0" Name="Type" SelectedIndex="0">',
        '                        <ComboBoxItem Content="Name"/>',
        '                    </ComboBox>',
        '                    <TextBox  Grid.Column="1" Name="Filter"/>',
        '                    <Button Grid.Column="2" Content="Refresh" Name="Refresh"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1" Grid.Column="0" Name="Output">',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Index"  Width="40"  Binding="{Binding Index}"/>',
        '                        <DataGridTextColumn Header="Name"   Width="150" Binding="{Binding Name}"/>',
        '                        <DataGridTextColumn Header="Bssid"  Width="100" Binding="{Binding Bssid}"/>',
        '                        <DataGridTextColumn Header="Type"   Width="75"   Binding="{Binding Type}"/>',
        '                        <DataGridTextColumn Header="Uptime" Width="125"   Binding="{Binding Uptime}"/>',
        '                        <DataGridTemplateColumn Header="Authentication" Width="80">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="{Binding AuthenticationSlot}"  ToolTip="{Binding AuthenticationDescription}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                        <ComboBoxItem Content="None"/>',
        '                                        <ComboBoxItem Content="Unknown"/>',
        '                                        <ComboBoxItem Content="Open80211"/>',
        '                                        <ComboBoxItem Content="SharedKey80211"/>',
        '                                        <ComboBoxItem Content="Wpa"/>',
        '                                        <ComboBoxItem Content="WpaPsk"/>',
        '                                        <ComboBoxItem Content="WpaNone"/>',
        '                                        <ComboBoxItem Content="Rsna"/>',
        '                                        <ComboBoxItem Content="RsnaPsk"/>',
        '                                        <ComboBoxItem Content="Ihv"/>',
        '                                        <ComboBoxItem Content="Wpa3Enterprise192Bits"/>',
        '                                        <ComboBoxItem Content="Wpa3Sae"/>',
        '                                        <ComboBoxItem Content="Owe"/>',
        '                                        <ComboBoxItem Content="Wpa3Enterprise"/>',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                        <DataGridTemplateColumn Header="Encryption" Width="80">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="{Binding EncryptionSlot}" ToolTip="{Binding EncryptionDescription}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                        <ComboBoxItem Content="None"/>',
        '                                        <ComboBoxItem Content="Unknown"/>',
        '                                        <ComboBoxItem Content="Wep"/>',
        '                                        <ComboBoxItem Content="Wep40"/>',
        '                                        <ComboBoxItem Content="Wep104"/>',
        '                                        <ComboBoxItem Content="Tkip"/>',
        '                                        <ComboBoxItem Content="Ccmp"/>',
        '                                        <ComboBoxItem Content="WpaUseGroup"/>',
        '                                        <ComboBoxItem Content="RsnUseGroup"/>',
        '                                        <ComboBoxItem Content="Ihv"/>',
        '                                        <ComboBoxItem Content="Gcmp"/>',
        '                                        <ComboBoxItem Content="Gcmp256"/>',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                        <DataGridTemplateColumn Header="Strength" Width="50">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="{Binding Strength}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center" IsEnabled="False">',
        '                                        <ComboBoxItem Content="0"/>',
        '                                        <ComboBoxItem Content="1"/>',
        '                                        <ComboBoxItem Content="2"/>',
        '                                        <ComboBoxItem Content="3"/>',
        '                                        <ComboBoxItem Content="4"/>',
        '                                        <ComboBoxItem Content="5"/>',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Row="1" Grid.Column="0" Name="Ok"        Content="Ok" />',
        '                    <Button Grid.Row="1" Grid.Column="1" Content="Cancel" Name="Cancel"/>',
        '                </Grid>',
        '            </Grid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    # V1 | netsh wlan sh net mode=bssid | [WiFi]::New().Network
    # V2 | $WiFi = [Wireless]::New() | $WiFi.Scan()

    $Xaml = [XamlWindow][WirelessGUI]::Tab
    $WiFi = [Wireless]::New()
    
    $Xaml.IO.Refresh.Add_Click(
    {
        $Xaml.IO.Output.Items.Clear()
        $WiFi.Scan() | % { $Xaml.IO.Output.Items.Add($_) }
        Start-Sleep -Milliseconds 25
    })

    $Xaml.IO.Filter.Add_TextChanged(
    {
        $Xaml.IO.Output.Items.Clear()

        If ($WiFi.Output.Count -gt 0)
        {
            If ($Xaml.IO.Filter.Text -ne "")
            {
                $WiFi.Output | ? Name -match $Xaml.IO.Filter.Text | % { $Xaml.IO.Output.Items.Add($_) }
            }
            If ($Xaml.IO.Filter.Text -eq "")
            {
                $Wifi.Output | % { $Xaml.IO.Output.Items.Add($_) }
            }
        }
        Start-Sleep -Milliseconds 25
    })

    $Xaml.IO.Ok.Add_Click(
    {
        If ($Xaml.IO.Output.SelectedIndex -ne -1)
        {
            $Select = $Xaml.IO.Output.SelectedItem
            Switch ([System.Windows.MessageBox]::Show($Select.Name,"Use this network?","YesNo"))
            {
                Yes 
                { 
                    $Xaml.IO.DialogResult = $True
                }
                No  
                {  
                    Return "Returning..."
                }
            }
        }
    })

    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
    })
    
    $Xaml.Invoke()
    If ($Xaml.IO.DialogResult)
    {
        Return $Xaml.IO.Output.SelectedItem
    }
}
