<#
.SYNOPSIS
    Module for the PSD Wizard
.DESCRIPTION
    Module for the PSD Wizard
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES
          FileName: PSDWizard.psm1
          Solution: PowerShell Deployment for MDT
          Author: (Original) PSD Development Team, (Modified) Michael C. Cook Sr.
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2021-11-29

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:

.Example
#>

Add-Type -AssemblyName PresentationFramework
# Check for debug in PowerShell and TSEnv
If ($TSEnv:PSDDebug -eq "YES")
{
    $Global:PSDDebug = $True
}

If ($PSDDebug -eq $True)
{
    $verbosePreference = "Continue"
}

$Script:Wizard = $null
$Script:Xaml   = $null

Function Get-PSDWizard
{
    Param ($XamlPath) 

    # Load the XAML
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml] $Script:Xaml = Get-Content $XamlPath
 
    # Process XAML
    $Node              = [System.Xml.XmlNodeReader]$script:Xaml
    $Script:Wizard     = [Windows.Markup.XamlReader]::Load($Node)

    # Store objects in PowerShell variables
    $script:Xaml.SelectNodes("//*[@Name]") | % {

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating variable $($_.Name)"
        Set-Variable -Name ($_.Name) -Value $script:Wizard.FindName($_.Name) -Scope Global
    }

    # Attach event handlers
    $WizFinishButton.Add_Click(
    {
        If ($TS_AdminPassword.Password -notmatch $AdminConfirm.Password)
        {
            Return [System.Windows.MessageBox]::Show("Invalid admin password/confirm","Error")
        }

        ElseIf ($TS_DomainAdminPassword.Password -notmatch $DomainAdminConfirm.Password)
        {
            Return [System.Windows.MessageBox]::Show("Invalid admin password/confirm","Error")
        }

        Else
        {
            $Script:Wizard.DialogResult = $True
            $Script:Wizard.Close()
        }
    })

    # Attach event handlers
    $WizCancelButton.Add_Click(
    {
        $Script:Wizard.DialogResult = $False
        $Script:Wizard.Close()
    })

    # Load wizard script and execute it
    $Init = $XamlPath -Replace "Mod",""
    Invoke-Expression "$Init.Initialize.ps1" | Out-Null

    # Return the form to the caller
    Return $script:Wizard
}

Function Save-PSDWizardResult
{
    $script:Xaml.SelectNodes("//*[@Name]") | ? { $_.Name -like "TS_*" } | % {
        
        $Name        = $_.Name.Substring(3)
        $Control     = $script:Wizard.FindName($_.Name)
        
        $Value       = @($Control.Text,$Control.Password)[[UInt32]($_.Name -eq "TS_DomainAdminPassword" -or $_.Name -eq "TS_AdminPassword")]
        Set-Item -Path tsenv:$Name -Value $Value 
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Set variable [$Name] using form value [$Value]"
        
        If ($Name -eq "TaskSequenceID")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking TaskSequenceID value"
            
            If ($Value -eq "")
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TaskSequenceID is empty!!!"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Re-Running Wizard, TaskSequenceID must not be empty..."
                Show-PSDSimpleNotify -Message "No Task Sequence selected, restarting wizard..."
                Show-PSDWizard "$Scripts\PSDWizardMod.xaml"
            }
        }
    }
}

Function Set-PSDWizardDefault
{
    $Script:Xaml.SelectNodes("//*[@Name]") | ? { $_.Name -like "TS_*" } | % {
        
        $Name                 = $_.Name.Substring(3)
        $Control              = $Script:Wizard.FindName($_.Name)
        
        If ($_.Name -eq "TS_DomainAdminPassword" -or $_.Name -eq "TS_AdminPassword")
        {
            $Value            = $Control.Password
            $Control.Password = (Get-Item tsenv:$Name).Value
        }
        Else
        {
            $Value            = $Control.Text
            $Control.Text     = (Get-Item tsenv:$Name).Value
        }
    }
}

Function Show-PSDWizard
{
    Param ($xamlPath)

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing wizard from [$XamlPath]"
    $Wizard = Get-PSDWizard $XamlPath
    Set-PSDWizardDefault
    $Result = $Wizard.ShowDialog()
    Save-PSDWizardResult
    Return $Wizard
}

Function Get-FEWizard
{
    Param ($Drive)

    Class DGList
    {
        [String] $Name
        [Object] $Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = If ($Value.Count -le 1) {$Value} Else {$Value -join ", "}
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
        [Object[]]            $Types
        [Object]               $Node
        [Object]                 $IO
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

            ForEach ($I in 0..( $This.Names.Count - 1))
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
                If ($This.IO.$Name)
                {
                    $This.Types     += [DGList]::New($Name,$This.IO.$Name.GetType().Name)
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
        [String] ToString()
        {
            Return "<Window>"
        }
    }

    # (Get-Content $home\desktop\FEWizard.xaml) | % { "'$_',"} | Set-Clipboard
    Class FEWizardGUI
    {
        Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Deployment Wizard" Width="800" Height="640" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
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
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
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
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '        </Style>',
        '        <Style TargetType="TextBox" x:Key="Block">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontFamily" Value="Consolas"/>',
        '            <Setter Property="Height" Value="180"/>',
        '            <Setter Property="FontSize" Value="10"/>',
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
        '        <Grid.Resources>',
        '            <Style TargetType="Grid">',
        '                <Setter Property="Background" Value="LightYellow"/>',
        '            </Style>',
        '        </Grid.Resources>',
        '        <Grid.RowDefinitions>',
        '            <RowDefinition Height="*"/>',
        '            <RowDefinition Height="45"/>',
        '        </Grid.RowDefinitions>',
        '        <TabControl Grid.Row="0">',
        '            <TabItem Header="Locale">',
        '                <GroupBox Header="[Locale/Miscellaneous]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="120"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="200"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label    Grid.Row="0" Content="[Locale]: Time Zone/Keyboard/Language"/>',
        '                        <Grid     Grid.Row="1">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid     Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="350"/>',
        '                                    <ColumnDefinition Width="135"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label     Grid.Column="0" Content="[Time Zone]:"/>',
        '                                <ComboBox  Grid.Column="1" Name="Locale_Timezone"/>',
        '                                <Label     Grid.Column="2" Content="[Keyboard Layout]:"/>',
        '                                <ComboBox  Grid.Column="3" Name="Locale_Keyboard"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label     Grid.Row="0" Grid.Column="0" Content="[Primary]:"/>',
        '                                <Grid Grid.Row="1" Grid.Column="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label Grid.Column="0" Content="[Secondary]:"/>',
        '                                    <CheckBox Grid.Column="1" Name="Locale_SecondLanguage"/>',
        '                                </Grid>',
        '                                ',
        '                                <ComboBox  Grid.Row="0" Grid.Column="1" Name="Locale_Language1"/>',
        '                                <ComboBox  Grid.Row="1" Grid.Column="1" Name="Locale_Language2"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                        <Border Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Label  Grid.Row="3" Content="[Miscellaneous]: Alter/amend various deployment settings"/>',
        '                        <Grid   Grid.Row="4">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Row 0 -->',
        '                            <Label    Grid.Row="0" Grid.Column="0" Content="[Finish Action]:"/>',
        '                            <ComboBox Grid.Row="0" Grid.Column="1" Name="Misc_Finish_Action" SelectedIndex="1">',
        '                                <ComboBoxItem Content="Do nothing"/>',
        '                                <ComboBoxItem Content="Reboot"/>',
        '                                <ComboBoxItem Content="Shutdown"/>',
        '                                <ComboBoxItem Content="LogOff"/>',
        '                            </ComboBox>',
        '                            <Label    Grid.Row="0" Grid.Column="2" Content="[WSUS Server]:"/>',
        '                            <TextBox  Grid.Row="0" Grid.Column="3" Name="Misc_WSUSServer" ToolTip="Pull updates from Windows Server Update Services"/>',
        '                            <!-- Row 1 -->',
        '                            <Label    Grid.Row="1" Grid.Column="0" Content="[Event Service]:"/>',
        '                            <TextBox  Grid.Row="1" Grid.Column="1" Name="Misc_EventService" ToolTip="For monitoring deployment process"/>',
        '                            <!-- Row 2 -->',
        '                            <Label    Grid.Row="2" Grid.Column="0" Content="[Script Log Path]:"/>',
        '                            <TextBox  Grid.Row="2" Grid.Column="1" Name="Misc_LogsSLShare"/>',
        '                            <CheckBox Grid.Row="2" Grid.Column="2" Content="Save in Root" Name="Misc_SLShare_DeployRoot"/>',
        '                            <!-- Row 3 -->',
        '                            <Label    Grid.Row="3" Grid.Column="0" Content="[Realtime SL Dir.]:"/>',
        '                            <TextBox  Grid.Row="3" Grid.Column="1" Name="Misc_LogsSLShare_DynamicLogging"/>',
        '                            <Label    Grid.Row="4" Grid.Column="0" Content="[Product Key]:"/>',
        '                            <ComboBox Grid.Row="4" Grid.Column="1" Name="Misc_Product_Key_Type" SelectedIndex="0">',
        '                                <ComboBoxItem Content="No product key is required"/>',
        '                                <ComboBoxItem Content="Activate with multiple activation key (MAK)"/>',
        '                                <ComboBoxItem Content="Use a specific product key"/>',
        '                            </ComboBox>',
        '                            <TextBox  Grid.Row="4" Grid.Column="2" Grid.ColumnSpan="2" Name="Misc_Product_Key"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="5">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="50"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <CheckBox Grid.Column="0" Name="Misc_HideShell" Content="Hide explorer during deployment" HorizontalAlignment="Right"/>',
        '                            <CheckBox Grid.Column="2" Name="Misc_NoExtraPartition" Content="Do not create extra partition" HorizontalAlignment="Left"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Root">',
        '                <GroupBox Header="[Root/Deployment Share]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Grid.Row="0" Content="[Root]: Deployment Share Information/Properties"/>',
        '                        <TabControl Grid.Row="1">',
        '                            <TabItem Header="Task Sequence">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="TaskSequenceProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="ID"/>',
        '                                            <ComboBoxItem Content="Version"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="TaskSequenceFilter"/>',
        '                                        <Button   Grid.Column="3" Name="TaskSequenceRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="TaskSequence" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"                 Width="250"/>',
        '                                            <DataGridTextColumn Header="ID"       Binding="{Binding ID}"                   Width="100"/>',
        '                                            <DataGridTextColumn Header="Version"  Binding="{Binding Version}"              Width="50"/>',
        '                                            <DataGridTextColumn Header="Template" Binding="{Binding TaskSequenceTemplate}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Enable"   Binding="{Binding Enable}"               Width="100"/>',
        '                                            <DataGridTextColumn Header="Guid"     Binding="{Binding GUID}"                 Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Application">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="ApplicationProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Shortname"/>',
        '                                            <ComboBoxItem Content="Version"/>',
        '                                            <ComboBoxItem Content="Publisher"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="ApplicationFilter"/>',
        '                                        <Button   Grid.Column="3" Name="ApplicationRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="Application" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"             Binding="{Binding Name}"             Width="200"/>',
        '                                            <DataGridTextColumn Header="Shortname"        Binding="{Binding Shortname}"        Width="125"/>',
        '                                            <DataGridTextColumn Header="Version"          Binding="{Binding Version}"          Width="100"/>',
        '                                            <DataGridTextColumn Header="Publisher"        Binding="{Binding Publisher}"        Width="60"/>',
        '                                            <DataGridTextColumn Header="Language"         Binding="{Binding Language}"         Width="100"/>',
        '                                            <DataGridTextColumn Header="CommandLine"      Binding="{Binding CommandLine}"      Width="100"/>',
        '                                            <DataGridTextColumn Header="WorkingDirectory" Binding="{Binding WorkingDirectory}" Width="150"/>',
        '                                            <DataGridTextColumn Header="UninstallKey"     Binding="{Binding UninstallKey}"     Width="100"/>',
        '                                            <DataGridTextColumn Header="Reboot"           Binding="{Binding Reboot}"           Width="60"/>',
        '                                            <DataGridTextColumn Header="Hide"             Binding="{Binding Hide}"             Width="100"/>',
        '                                            <DataGridTextColumn Header="Enable"           Binding="{Binding Enable}"           Width="60"/>',
        '                                            <DataGridTextColumn Header="Guid"             Binding="{Binding Guid}"             Width="60"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Driver">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="DriverProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Manufacturer"/>',
        '                                            <ComboBoxItem Content="Version"/>',
        '                                            <ComboBoxItem Content="Date"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="DriverFilter"/>',
        '                                        <Button   Grid.Column="3" Name="DriverRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="Driver" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"         Binding="{Binding Name}"         Width="200"/>',
        '                                            <DataGridTextColumn Header="Manufacturer" Binding="{Binding Manufacturer}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Version"      Binding="{Binding Version}"      Width="100"/>',
        '                                            <DataGridTextColumn Header="Date"         Binding="{Binding Date}"         Width="100"/>',
        '                                            <DataGridTextColumn Header="Platform"     Binding="{Binding Platform}"     Width="100"/>',
        '                                            <DataGridTextColumn Header="Class"        Binding="{Binding Class}"        Width="100"/>',
        '                                            <DataGridTextColumn Header="WHQL"         Binding="{Binding WHQLSigned}"   Width="60"/>',
        '                                            <DataGridTextColumn Header="Enable"       Binding="{Binding Enable}"       Width="60"/>',
        '                                            <DataGridTextColumn Header="Hash"         Binding="{Binding Hash}"         Width="100"/>',
        '                                            <DataGridTextColumn Header="Guid"         Binding="{Binding GUID}"         Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Package">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="PackageProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="PackageType"/>',
        '                                            <ComboBoxItem Content="Arch"/>',
        '                                            <ComboBoxItem Content="Date"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="PackageFilter"/>',
        '                                        <Button   Grid.Column="3" Name="PackageRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1"  Name="Package" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"         Width="200"/>',
        '                                            <DataGridTextColumn Header="PackageType" Binding="{Binding PackageType}"  Width="150"/>',
        '                                            <DataGridTextColumn Header="Arch"        Binding="{Binding Architecture}" Width="100"/>',
        '                                            <DataGridTextColumn Header="Language"    Binding="{Binding Language}"     Width="100"/>',
        '                                            <DataGridTextColumn Header="Version"     Binding="{Binding Version}"      Width="100"/>',
        '                                            <DataGridTextColumn Header="Keyword"     Binding="{Binding Keyword}"      Width="100"/>',
        '                                            <DataGridTextColumn Header="Enable"      Binding="{Binding Enable}"       Width="60"/>',
        '                                            <DataGridTextColumn Header="Guid"        Binding="{Binding GUID}"         Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Profile">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="ProfileProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Comments"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="ProfileFilter"/>',
        '                                        <Button   Grid.Column="3" Name="ProfileRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="Profile" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"      Binding="{Binding Name}"     Width="175"/>',
        '                                            <DataGridTextColumn Header="Comments"  Binding="{Binding Comments}" Width="175"/>',
        '                                            <DataGridTextColumn Header="ReadOnly"  Binding="{Binding ReadOnly}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Guid"      Binding="{Binding Guid}"     Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Operating System">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="OperatingSystemProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Description"/>',
        '                                            <ComboBoxItem Content="Platform"/>',
        '                                            <ComboBoxItem Content="Build"/>',
        '                                            <ComboBoxItem Content="OSType"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="OperatingSystemFilter"/>',
        '                                        <Button   Grid.Column="3" Name="OperatingSystemRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="OperatingSystem" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"          Binding="{Binding Name}"        Width="250"/>',
        '                                            <DataGridTextColumn Header="Description"   Binding="{Binding Description}" Width="250"/>',
        '                                            <DataGridTextColumn Header="Platform"      Binding="{Binding Platform}"    Width="60"/>',
        '                                            <DataGridTextColumn Header="Build"         Binding="{Binding Build}"       Width="100"/>',
        '                                            <DataGridTextColumn Header="OSType"        Binding="{Binding OSType}"      Width="100"/>',
        '                                            <DataGridTextColumn Header="Flags"         Binding="{Binding Flags}"       Width="150"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Linked Shares">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="LinkedShareProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Root"/>',
        '                                            <ComboBoxItem Content="Profile"/>',
        '                                            <ComboBoxItem Content="Comments"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="LinkedShareFilter"/>',
        '                                        <Button   Grid.Column="3" Name="LinkedShareRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1"  Name="LinkedShare" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"             Width="200"/>',
        '                                            <DataGridTextColumn Header="Root"       Binding="{Binding Root}"             Width="100"/>',
        '                                            <DataGridTextColumn Header="Profile"    Binding="{Binding SelectionProfile}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Replace"    Binding="{Binding Replace}"          Width="150"/>',
        '                                            <DataGridTextColumn Header="SingleUser" Binding="{Binding SingleUser}"       Width="60"/>',
        '                                            <DataGridTextColumn Header="Comments"   Binding="{Binding Comments}"         Width="150"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Media">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Search]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="MediaProperty" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="Name"/>',
        '                                            <ComboBoxItem Content="Root"/>',
        '                                            <ComboBoxItem Content="Profile"/>',
        '                                            <ComboBoxItem Content="Comments"/>',
        '                                        </ComboBox>',
        '                                        <TextBox  Grid.Column="2" Name="MediaFilter"/>',
        '                                        <Button   Grid.Column="3" Name="MediaRefresh" Content="Refresh"/>',
        '                                    </Grid>',
        '                                    <DataGrid Grid.Row="1" Name="Media" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"             Width="200"/>',
        '                                            <DataGridTextColumn Header="Root"       Binding="{Binding Root}"             Width="100"/>',
        '                                            <DataGridTextColumn Header="Profile"    Binding="{Binding SelectionProfile}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Comments"   Binding="{Binding Comments}"         Width="150"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
        '                        <Grid  Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label     Grid.Column="0" Content="[Task Sequence]:"/>',
        '                            <TextBox   Grid.Column="1" Name="Task_ID"/>',
        '                            <Label     Grid.Column="2" Content="[Profile Name]:"/>',
        '                            <TextBox   Grid.Column="3" Name="Task_Profile"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="System">',
        '                <GroupBox Header="[System]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="290"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Grid.Row="0" Content="[System/Disk]: System Information Panel"/>',
        '                        <Grid  Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="150"/>',
        '                                <ColumnDefinition Width="240"/>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Column 0 -->',
        '                            <Label       Grid.Row="0" Grid.Column="0" Content="[Manufacturer]:"/>',
        '                            <Label       Grid.Row="1" Grid.Column="0" Content="[Model]:"/>',
        '                            <Label       Grid.Row="2" Grid.Column="0" Content="[Processor]:"/>',
        '                            <Label       Grid.Row="3" Grid.Column="0" Content="[Architecture]:"/>',
        '                            <Label       Grid.Row="4" Grid.Column="0" Content="[UUID]:"/>',
        '                            <Label       Grid.Row="5" Grid.Column="0" Content="[System Name]:"     ToolTip="Enter a new system name"/>',
        '                            <Label       Grid.Row="6" Grid.Column="0" Content="[System Password]:" ToolTip="Enter a new system password"/>',
        '                            <!-- Column 1 -->',
        '                            <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>',
        '                            <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>',
        '                            <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture">',
        '                                <ComboBoxItem Content="x86"/>',
        '                                <ComboBoxItem Content="x64"/>',
        '                            </ComboBox>',
        '                            <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3" Name="System_UUID"/>',
        '                            <TextBox     Grid.Row="5" Grid.Column="1" Name="System_Name"/>',
        '                            <PasswordBox Grid.Row="6" Grid.Column="1" Name="System_Password"/>',
        '                            <!-- Column 2 -->',
        '                            <Label       Grid.Row="0" Grid.Column="2" Content="[Product]:"/>',
        '                            <Label       Grid.Row="1" Grid.Column="2" Content="[Serial]:"/>',
        '                            <Label       Grid.Row="2" Grid.Column="2" Content="[Memory]:"/>',
        '                            <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">',
        '                                <Label    Content="[Chassis]:"/>',
        '                                <CheckBox Name="System_IsVM" Content="VM" IsEnabled="False"/>',
        '                            </StackPanel>',
        '                            <CheckBox    Grid.Row="5" Grid.Column="2" Name="System_UseSerial" Content="Name w/ Serial #" HorizontalAlignment="Center"/>',
        '                            <Label       Grid.Row="6" Grid.Column="2" Content="[Confirm]:"/>',
        '                            <!-- Column 3 -->',
        '                            <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>',
        '                            <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>',
        '                            <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>',
        '                            <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis">',
        '                                <ComboBoxItem Content="Desktop"/>',
        '                                <ComboBoxItem Content="Laptop"/>',
        '                                <ComboBoxItem Content="Small Form Factor"/>',
        '                                <ComboBoxItem Content="Server"/>',
        '                                <ComboBoxItem Content="Tablet"/>',
        '                            </ComboBox>',
        '                            <StackPanel  Grid.Row="5" Grid.Column="3" Orientation="Horizontal">',
        '                                <Label   Content="[BIOS/UEFI]:"/>',
        '                                <ComboBox Name="System_BiosUefi" Width="150">',
        '                                    <ComboBoxItem Content="BIOS"/>',
        '                                    <ComboBoxItem Content="UEFI"/>',
        '                                </ComboBox>',
        '                            </StackPanel>',
        '                            <PasswordBox Grid.Row="6" Grid.Column="3" Name="System_Confirm"/>',
        '                        </Grid>',
        '                        <DataGrid Grid.Row="2" Name="System_Disk">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"       Binding="{Binding Name}" Width="50"/>',
        '                                <DataGridTextColumn Header="Label"      Binding="{Binding Label}" Width="150"/>',
        '                                <DataGridTextColumn Header="FileSystem" Binding="{Binding FileSystem}" Width="80"/>',
        '                                <DataGridTextColumn Header="Size"       Binding="{Binding Size}" Width="150"/>',
        '                                <DataGridTextColumn Header="Free"       Binding="{Binding Free}" Width="150"/>',
        '                                <DataGridTextColumn Header="Used"       Binding="{Binding Used}" Width="150"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Domain">',
        '                <GroupBox Header="[Domain/Network]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="160"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label Grid.Row="0" Content="[Domain/Network]: Enter Domain Information, and Credential"/>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="1.5*"/>',
        '                                <ColumnDefinition Width="2.25*"/>',
        '                                <ColumnDefinition Width="1.5*"/>',
        '                                <ColumnDefinition Width="2.25*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Column 0 -->',
        '                            <StackPanel Grid.Row="0" Grid.Column="0" Orientation="Horizontal">',
        '                                <Label Content="[Org Name]:"/>',
        '                                <CheckBox Content="Edit" Name="Domain_OrgEdit" HorizontalAlignment="Left"/>',
        '                            </StackPanel>',
        '                            <Label    Grid.Row="1" Grid.Column="0" Content="[Org. Unit]:"/>',
        '                            <Label    Grid.Row="2" Grid.Column="0" Content="[Home Page]:"/>',
        '                            <Grid     Grid.Row="3" Grid.ColumnSpan="4">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="200"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label       Grid.Column="0" Content="[Username]:"/>',
        '                                <TextBox     Grid.Column="1" Name="Domain_Username"/>',
        '                                <Label       Grid.Column="2" Content="[Confirm]:"/>',
        '                                <PasswordBox Grid.Column="3" Name="Domain_Password"/>',
        '                                <PasswordBox Grid.Column="4" Name="Domain_Confirm"/>',
        '                            </Grid>',
        '                            <!-- Column 1 -->',
        '                            <TextBox  Grid.Row="0" Grid.Column="1" Name="Domain_OrgName"/>',
        '                            <TextBox  Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_OU"/>',
        '                            <TextBox  Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="3" Name="Domain_HomePage"/>',
        '                            <!-- Column 2 -->',
        '                            <ComboBox Grid.Row="0" Grid.Column="2" Name="Domain_Type" SelectedIndex="0">',
        '                                <ComboBoxItem Content="Domain"/>',
        '                                <ComboBoxItem Content="Workgroup"/>',
        '                            </ComboBox>',
        '                            <!-- Column 3 -->',
        '                            <TextBox  Grid.Row="0" Grid.Column="3" Name="Domain_Name"/>',
        '                        </Grid>',
        '                        <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Label Grid.Row="3" Content="[Network]: Adapter(s) Information"/>',
        '                        <Grid  Grid.Row="4" Margin="5">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="135"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="135"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <!-- Column 0 -->',
        '                            <Label    Grid.Row="0" Grid.Column="0" Content="[Selected Adapter]:"/>',
        '                            <Label    Grid.Row="1" Grid.Column="0" Content="[Network Type]:"/>',
        '                            <Label    Grid.Row="2" Grid.Column="0" Content="[IP Address]:"/>',
        '                            <Label    Grid.Row="3" Grid.Column="0" Content="[Subnet Mask]:"/>',
        '                            <Label    Grid.Row="4" Grid.Column="0" Content="[Gateway]:"/>',
        '                            <!-- Column 1 -->',
        '                            <ComboBox Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Network_Adapter"/>',
        '                            <ComboBox Grid.Row="1" Grid.Column="1" Name="Network_Type">',
        '                                <ComboBoxItem Content="DHCP"/>',
        '                                <ComboBoxItem Content="Static"/>',
        '                            </ComboBox>',
        '                            <TextBox  Grid.Row="2" Grid.Column="1" Name="Network_IPAddress"/>',
        '                            <TextBox  Grid.Row="3" Grid.Column="1" Name="Network_SubnetMask"/>',
        '                            <TextBox  Grid.Row="4" Grid.Column="1" Name="Network_Gateway"/>',
        '                            <!-- Column 2 -->',
        '                            <Label    Grid.Row="1" Grid.Column="2" Content="[Interface Index]:"/>',
        '                            <Label    Grid.Row="2" Grid.Column="2" Content="[DNS Server(s)]:"/>',
        '                            <Label    Grid.Row="3" Grid.Column="2" Content="[DHCP Server]:"/>',
        '                            <Label    Grid.Row="4" Grid.Column="2" Content="[Mac Address]:"/>',
        '                            <!-- Column 3 -->',
        '                            <TextBox  Grid.Row="1" Grid.Column="3" Name="Network_Index"/>',
        '                            <ComboBox Grid.Row="2" Grid.Column="3" Name="Network_DNS"/>',
        '                            <TextBox  Grid.Row="3" Grid.Column="3" Name="Network_DHCP"/>',
        '                            <TextBox  Grid.Row="4" Grid.Column="3" Name="Network_MacAddress"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Control">',
        '                <GroupBox Grid.Row="0" Header="[Control]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="160"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                                <ColumnDefinition Width="125"/>',
        '                                <ColumnDefinition Width="250"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <!-- Column 0 -->',
        '                            <Label        Grid.Row="0" Grid.Column="0" Content="[Username]:"/>',
        '                            <Label        Grid.Row="1" Grid.Column="0" Content="[Password]:" />',
        '                            <Label        Grid.Row="2" Grid.Column="0" Content="[Mode]:"/>',
        '                            <Label        Grid.Row="3" Grid.Column="0" Content="[Description]:"/>',
        '                            <!-- Column 1 -->',
        '                            <TextBox      Grid.Row="0" Grid.Column="1" Name="Control_Username"/>',
        '                            <PasswordBox  Grid.Row="1" Grid.Column="1" Name="Control_Password"/>',
        '                            <ComboBox     Grid.Row="2" Grid.Column="1" Name="Control_Mode">',
        '                                <ComboBoxItem Content="New Computer"/>',
        '                                <ComboBoxItem Content="Refresh"/>',
        '                                <ComboBoxItem Content="Virtualize"/>',
        '                                <ComboBoxItem Content="Devirtualize"/>',
        '                            </ComboBox>',
        '                            <TextBox      Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3"  Name="Control_Description"/>',
        '                            <!-- Column 1 -->',
        '                            <Label        Grid.Row="0" Grid.Column="2" Content="[Domain]:"/>',
        '                            <Label        Grid.Row="1" Grid.Column="2" Content="[Confirm]:"/>',
        '                            <Label        Grid.Row="2" Grid.Column="2" Content="[Test]:"/>',
        '                            <!-- Column 1 -->',
        '                            <TextBox      Grid.Row="0" Grid.Column="3" Name="Control_Domain"/>',
        '                            <PasswordBox  Grid.Row="1" Grid.Column="3" Name="Control_Confirm"/>',
        '                            <Button       Grid.Row="2" Grid.Column="3" Name="Control_Connect" Content="Connect"/>',
        '                        </Grid>',
        '                        <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Grid Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid Grid.Column="0">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Column="0" Content="[Computer]: Backup/Capture"/>',
        '                                <Grid Grid.Row="1" Height="200" Name="Computer_Backup" VerticalAlignment="Top" Visibility="Collapsed">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="2*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type" />',
        '                                    <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Backup_Type" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Do not backup the existing computer"/>',
        '                                        <ComboBoxItem Content="Automatically determine the location"/>',
        '                                        <ComboBoxItem Content="Specify a location"/>',
        '                                    </ComboBox>',
        '                                    <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>',
        '                                    <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Backup_Browse"/>',
        '                                    <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Backup_Path"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1" Height="200" Name="Computer_Capture" VerticalAlignment="Top" Visibility="Collapsed">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="2*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label      Grid.Row="0" Grid.Column="0" Content="Capture Type" />',
        '                                    <ComboBox   Grid.Row="0" Grid.Column="1" Name="Computer_Capture_Type" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Do not capture"/>',
        '                                        <ComboBoxItem Content="Capture my computer"/>',
        '                                        <ComboBoxItem Content="Sysprep this computer"/>',
        '                                        <ComboBoxItem Content="Prepare to capture the machine"/>',
        '                                    </ComboBox>',
        '                                    <Label      Grid.Row="1" Grid.Column="0" Content="Capture Location" />',
        '                                    <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="Computer_Capture_Browse"/>',
        '                                    <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="Computer_Capture_Path"/>',
        '                                    <Grid       Grid.Row="3" Grid.Column="1">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <TextBox  Grid.Column="0" Name="Computer_Capture_FileName"/>',
        '                                        <ComboBox Grid.Column="1" Name="Computer_Capture_Extension" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="WIM"/>',
        '                                            <ComboBoxItem Content="VHD"/>',
        '                                        </ComboBox>',
        '                                    </Grid>',
        '                                    <Label      Grid.Row="3" Grid.Column="0" Content="Capture name" />',
        '                                </Grid>',
        '                            </Grid>',
        '                            <Grid Grid.Column="1">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[User]: Backup/Restore"/>',
        '                                <Grid Grid.Row="1" Height="200" Name="User_Backup" VerticalAlignment="Top" Visibility="Collapsed">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="2*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label      Grid.Row="0" Grid.Column="0" Content="Backup Type"/>',
        '                                    <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Backup_Type" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Do not save data and settings"/>',
        '                                        <ComboBoxItem Content="Automatically determine the location"/>',
        '                                        <ComboBoxItem Content="Specify a location"/>    ',
        '                                    </ComboBox>',
        '                                    <Label      Grid.Row="1" Grid.Column="0" Content="Backup Location"/>',
        '                                    <Button     Grid.Row="1" Grid.Column="1" Content="Browse" Name="User_Backup_Browse"/>',
        '                                    <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Backup_Path"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1" Height="200" Name="User_Restore" VerticalAlignment="Top" Visibility="Collapsed">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="2*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label      Grid.Row="0" Grid.Column="0" Content="Restore Type"/>',
        '                                    <ComboBox   Grid.Row="0" Grid.Column="1" Name="User_Restore_Type" SelectedIndex="0">',
        '                                        <ComboBoxItem Content="Specify a location"/>',
        '                                        <ComboBoxItem Content="Specify an account"/>',
        '                                    </ComboBox>',
        '                                    <Label      Grid.Row="1" Grid.Column="0" Content="Restore Location"/>',
        '                                    <Button     Grid.Row="1" Grid.Column="1" Content="Browse"/>',
        '                                    <TextBox    Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Name="User_Restore_Path"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '        </TabControl>',
        '        <Grid Grid.Row="2">',
        '            <Grid.ColumnDefinitions>',
        '                <ColumnDefinition Width="*"/>',
        '                <ColumnDefinition Width="*"/>',
        '            </Grid.ColumnDefinitions>',
        '            <Button Grid.Column="0" Name="Start" Content="Start"/>',
        '            <Button Grid.Column="1" Name="Cancel" Content="Cancel"/>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n") 
    }

    # Locale/Timezone classes
    Class Locale
    {
        [String] $ID
        [String] $Keyboard
        [String] $Culture
        [String] $Name
        Locale([Object]$Culture)
        {
            $This.ID       = $Culture.ID
            $This.Keyboard = $Culture.DefaultKeyboard
            $This.Culture  = $Culture.SSpecificCulture
            $This.Name     = $Culture.RefName
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class TimeZone
    {
        [String] $ID
        [String] $DisplayName
        TimeZone([Object]$Timezone)
        {
            $This.ID          = $Timezone.ID
            $This.Displayname = $Timezone.DisplayName
        }
        [String] ToString()
        {
            Return $This.DisplayName
        }
    }

    # System classes
    Class Network
    {
        [String]$Name
        [UInt32]$Index
        [String]$IPAddress
        [String]$SubnetMask
        [String]$Gateway
        [String[]] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([Object]$If)
        {
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway     | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = $IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DhcpServer = $IF.DhcpServer           | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    Class Disk
    {
        [String] $Name
        [String] $Label
        [String] $FileSystem
        [String] $Size
        [String] $Free
        [String] $Used
        Disk([Object]$Disk)
        {
            $This.Name       = $Disk.DeviceID
            $This.Label      = $Disk.VolumeName
            $This.FileSystem = $Disk.FileSystem
            $This.Size       = "{0:n2} GB" -f ($Disk.Size/1GB)
            $This.Free       = "{0:n2} GB" -f ($Disk.FreeSpace/1GB)
            $This.Used       = "{0:n2} GB" -f (($Disk.Size-$Disk.FreeSpace)/1GB)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class Processor
    {
        [String]$Name
        [String]$Caption
        [String]$DeviceID
        [String]$Manufacturer
        [UInt32]$Speed
        Processor([Object]$CPU)
        {
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.DeviceID     = $CPU.DeviceID
            $This.Manufacturer = $CPU.Manufacturer
            $This.Speed        = $CPU.MaxClockSpeed
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class System
    {
        [Object] $Manufacturer
        [Object] $Model
        [Object] $Product
        [Object] $Serial
        [Object[]] $Processor
        [String] $Memory
        [String] $Architecture
        [Object] $UUID
        [Object] $Chassis
        [Object] $BiosUEFI
        [Object] $AssetTag
        [Object[]] $Disk
        [Object[]] $Network
        System()
        {
            $This.Disk             = Get-WmiObject -Class Win32_LogicalDisk    | % {     [Disk]$_ }
            $This.Network          = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ? DefaultIPGateway | % { [Network]$_ }
            $This.Processor        = Get-WmiObject -Class Win32_Processor      | % { [Processor]$_ }
            Get-WmiObject Win32_ComputerSystem        | % { 

                $This.Manufacturer = $_.Manufacturer;
                $This.Model        = $_.Model; 
                $This.Memory       = "{0}GB" -f [UInt32]($_.TotalPhysicalMemory/1GB)
            }

            Get-WmiObject Win32_ComputerSystemProduct | % { 
                $This.UUID         = $_.UUID 
            }

            Get-WmiObject Win32_BaseBoard             | % { 
                $This.Product      = $_.Product
                $This.Serial       = $_.SerialNumber -Replace "\.",""
            }
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }
        
            Get-WmiObject Win32_SystemEnclosure | % {
                $This.AssetTag    = $_.SMBIOSAssetTag.Trim()
                $This.Chassis     = Switch([UInt32]$_.ChassisTypes[0])
                {
                    {$_ -in 8..12+14,18,21} {"Laptop"}
                    {$_ -in 3..7+15,16}     {"Desktop"}
                    {$_ -in 23}             {"Server"}
                    {$_ -in 34..36}         {"Small Form Factor"}
                    {$_ -in 30..32+13}      {"Tablet"}
                }
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[$Env:PROCESSOR_ARCHITECTURE]
        }
        [String] ToString()
        {
            Return "<System>"
        }
    }

    # MDT Object Classes
    Class Application
    {
        Hidden [Object] $App
        [String] $Name
        [String] $Shortname
        [String] $Version
        [String] $Publisher
        [String] $Language
        [String] $CommandLine
        [String] $WorkingDirectory
        [String] $UninstallKey
        [Bool]   $Reboot
        [Bool]   $Hide
        [Bool]   $Enable
        [String] $Guid
        Application([Object]$App)
        {
            $This.App              = $App
            $This.Name             = $App.Name
            $This.Shortname        = $App.ShortName
            $This.Version          = $App.Version
            $This.Publisher        = $App.Publisher
            $This.Language         = $App.Language
            $This.CommandLine      = $App.CommandLine
            $This.WorkingDirectory = $App.WorkingDirectory
            $This.UninstallKey     = $App.UninstallKey
            $This.Reboot           = $App.Reboot
            $This.Hide             = $App.Hide
            $This.Enable           = $App.Enable
            $This.Guid             = $App.Guid

            If (!$App) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<App:$($This.Name)>"
        }
    }

    Class OperatingSystem
    {
        Hidden [Object] $OS
        [String] $Name         
        [String] $Description   
        [String] $Platform      
        [String] $Build        
        [String] $OSType        
        [String] $Flags         
        OperatingSystem([Object]$OS)
        {
            $This.OS          = $OS
            $This.Name        = $OS.Name
            $This.Description = $OS.Description
            $This.Platform    = $OS.Platform
            $This.Build       = $OS.Build
            $This.OSType      = $OS.OSType
            $This.Flags       = $OS.Flags

            If (!$OS) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<OS:$($This.Name)>"
        }
    }

    Class Driver
    {
        Hidden [Object] $Driver
        [String] $Name
        [String] $Manufacturer
        [String] $Version
        [String] $Date
        [String] $Platform
        [String] $Class
        [String] $WHQLSigned
        [String] $Enable
        [String] $Hash
        [String] $Guid
        Driver([Object]$Driver)
        {
            $This.Driver       = $Driver
            $This.Name         = $Driver.Name
            $This.Manufacturer = $Driver.Manufacturer
            $This.Version      = $Driver.Version
            $This.Date         = $Driver.Date
            $This.Platform     = $Driver.Platform
            $This.Class        = $Driver.Class
            $This.WHQLSigned   = $Driver.WHQLSigned
            $This.Enable       = $Driver.Enable
            $This.Hash         = $Driver.Hash
            $This.Guid         = $Driver.Guid

            If (!$Driver) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<Driver:$($This.Name)>"
        }
    }

    Class Package
    {
        Hidden [Object] $Package
        [String] $Name
        [String] $PackageType
        [String] $Architecture
        [String] $Language
        [String] $Version
        [String] $Keyword
        [String] $Enable
        [String] $Guid
        Package([Object]$Package)
        {
            $This.Package      = $Package
            $This.Name         = $Package.Name
            $This.PackageType  = $Package.PackageType
            $This.Architecture = $Package.Architecture
            $This.Language     = $Package.Language
            $This.Version      = $Package.Version
            $This.Keyword      = $Package.Keyword
            $This.Enable       = $Package.Enable
            $This.Guid         = $Package.Guid

            If (!$Package) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<Pkg:$($This.Name)>"
        }
    }

    Class TaskSequence
    {
        Hidden [Object] $TS
        [String] $Name
        [String] $ID
        [String] $Version
        [String] $Template
        [String] $Enable
        [String] $Guid
        TaskSequence([Object]$TS)
        {
            $This.TS       = $TS
            $This.Name     = $TS.Name
            $This.ID       = $TS.ID
            $This.Version  = $TS.Version
            $This.Template = $TS.Template
            $This.Enable   = $TS.Enable
            $This.Guid     = $TS.Guid

            If (!$TS) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<TS:$($This.Name)>"
        }
    }

    Class SelectionProfile
    {
        Hidden [Object] $Selection
        [String] $Name
        [String] $Comments
        [String] $ReadOnly
        [String] $Guid
        SelectionProfile([Object]$Selection)
        {
            $This.Selection = $Selection
            $This.Name      = $Selection.Name
            $This.Comments  = $Selection.Comments
            $This.ReadOnly  = $Selection.ReadOnly
            $This.Guid      = $Selection.Guid

            If (!$Selection) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<SelectPro:$($This.Name)>"
        }
    }

    Class LinkedShare
    {
        Hidden [Object] $Link
        [String] $Name
        [String] $Root
        [String] $Profile
        [String] $Replace
        [String] $SingleUser
        [String] $Comments
        LinkedShare([Object]$Link)
        {
            $This.Link       = $Link
            $This.Name       = $Link.Name
            $This.Root       = $Link.Root
            $This.Profile    = $Link.Profile
            $This.Replace    = $Link.Replace
            $This.SingleUser = $Link.SingleUser
            $This.Comments   = $Link.Comments

            If (!$Link) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<LinkedShare:$($This.Name)>"
        }
    }
    
    Class Media
    {
        Hidden [Object] $Media
        [String] $Name
        [String] $Root
        [String] $Profile
        [String] $Comments
        Media([Object]$Media)
        {
            $This.Media    = $Media
            $This.Name     = $Media.Name
            $This.Root     = $Media.Root
            $This.Profile  = $Media.Profile
            $This.Comments = $Media.Comments

            If (!$Media) { $This.PSObject.Properties | % { $_.Value = "-" } }
        }
        [String] ToString()
        {
            Return "<Media:$($This.Name)>"
        }
    }

    Class Trunk
    {
        [UInt32] $Index
        [String] $Name
        [String] $Path
        [Object] $Children
        Trunk([Object]$Object)
        {
            $This.Name     = $Object.PSChildName
            $This.Path     = $Object.PSPath.Replace($Object.PSProvider,"").TrimStart("::")
            $This.Index    = Switch ($This.Name)
            {
                "Applications"             { 0 }
                "Operating Systems"        { 1 }
                "Out-of-Box Drivers"       { 2 } 
                "Packages"                 { 3 } 
                "Task Sequences"           { 4 } 
                "Selection Profiles"       { 5 }
                "Linked Deployment Shares" { 6 } 
                "Media"                    { 7 }
            }
            $This.Refresh()
        }
        Refresh()
        {
            $This.Children = @( ForEach ($Object in Get-ChildItem $This.Path -Recurse | ? { !$_.PsIsContainer })
            {
                Switch ($This.Index)
                {
                    0 {      $This.Application($Object) }
                    1 {  $This.OperatingSystem($Object) }
                    2 {           $This.Driver($Object) }
                    3 {          $This.Package($Object) }
                    4 {     $This.TaskSequence($Object) }
                    5 { $This.SelectionProfile($Object) }
                    6 {      $This.LinkedShare($Object) }
                    7 {            $This.Media($Object) }
                }
            })

            If ($This.Children.Count -eq 0)
            {
                $This.Children = @($This.Template($This.Slot))
            }
        }
        [Object] Template([UInt32]$Slot)
        {
            Return @( Switch ($This.Index)
            {
                0 {      $This.Application($Null) }
                1 {  $This.OperatingSystem($Null) }
                2 {           $This.Driver($Null) }
                3 {          $This.Package($Null) }
                4 {     $This.TaskSequence($Null) }
                5 { $This.SelectionProfile($Null) }
                6 {      $This.LinkedShare($Null) }
                7 {            $This.Media($Null) }
            })
        }
        [Object[]] Query([String]$Property,[Object]$Value)
        {
            $Query = $This.Children | ? $Property -match $Value
            If (!$Query)
            {
                $Query = $This.Template($This.Slot)
            }
            Return $Query
        }
        [Object[]] Query()
        {
            $Query = $This.Children
            If (!$Query)
            {
                $Query = $This.Template($This.Slot)
            }
            Return $Query
        }
        [Object] Application([Object]$Object)
        {
            Return [Application]::New($Object)
        }
        [Object] OperatingSystem([Object]$Object)
        {
            Return [OperatingSystem]::New($Object)
        }
        [Object] Driver([Object]$Object)
        {
            Return [Driver]::New($Object)
        }
        [Object] Package([Object]$Object)
        {
            Return [Package]::New($Object)
        }
        [Object] TaskSequence([Object]$Object)
        {
            Return [TaskSequence]::New($Object)
        }
        [Object] SelectionProfile([Object]$Object)
        {
            Return [SelectionProfile]::New($Object)
        }
        [Object] LinkedShare([Object]$Object)
        {
            Return [LinkedShare]::New($Object)
        }
        [Object] Media([Object]$Object)
        {
            Return [Media]::New($Object)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class Main
    {
        Hidden [Object] $Xaml
        [Object]        $Base
        [Object]        $Tree
        [Object]       $TSEnv
        [Object[]]    $Locale
        [Object[]]  $TimeZone
        [Object]      $System
        [Object]      $Domain
        [Object]     $Network
        [Object]     $Control
        [UInt32]        $Lock
        Main([Object[]]$Drive)
        {
            $This.Base            = $Drive | ? Name -eq DeploymentShare
            $This.Tree            = $This.GetTree()
            $This.TSEnv           = $Drive | ? Name -eq TSEnv | % { Get-ChildItem "$_`:" } | % { $This.Pair($_.Name,$_.Value)}
            $This.Locale          = $This.GetLocale("$($This.Base.Root)\Scripts\ListOfLanguages.xml")
            $This.Timezone        = $This.GetTimeZone([System.TimeZoneInfo]::GetSystemTimeZones())
            $This.System          = $This.GetSystem()
            $This.Network         = $This.System.Network
            $This.Control         = "$($This.Base.Root)\Control"
            $This.Lock            = 0
        }
        [Object] GetTree()
        {
            Return @( Get-ChildItem DeploymentShare: | % { [Trunk]::New($_) })
        }
        [Object] GetSystem()
        {
            Return [System]::New()
        }
        Refresh([UInt32]$Slot)
        {
            $This.Tree[$Slot].Refresh()
        }
        [Object[]] Query([UInt32]$Slot)
        {
            Return @( $This.Tree[$Slot].Query() )
        }
        [Object[]] Query([UInt32]$Slot,[String]$Property,[String]$Filter)
        {
            Return @( $This.Tree[$Slot].Query($Property,$Filter) )
        }
        [Object[]] GetTree([Object[]]$Object)
        {
            Return $Object | % { [Trunk]::New($_) }
        }
        [Object[]] GetTimeZone([Object[]]$Object)
        {
            Return $Object | % { [TimeZone]::New($_) }
        }
        [Object[]] GetLocale([String]$Path)
        {
            Return @( [XML](Get-Content $Path) | % LocaleData | % Locale | % { [Locale]$_ })
        }
        [Object] GetTSEnv([String]$Name)
        {
            Return $This.TSEnv | ? Name -eq $Name | % Value
        }
        SetTSEnv([String]$Name,[Object]$Value)
        {
            If (!(Get-item tsenv:\$Name))
            {
                New-Item -Path tsenv:\$Name -Value $Value -Verbose
            }
            ElseIf (Get-Item tsenv:\$Name)
            {
                Set-Item -Path tsenv:\$Name -Value $Value -Verbose
            }
            
            $This.TSEnv = Get-ChildItem tsenv:
        }
        SetDomain([Object]$Xaml,[UInt32]$Slot)
        {
            $Xaml.IO.Domain_OrgName.Text                      = $tsenv:_SMSTSOrgName
            $Xaml.IO.Domain_Name.Text                         = $tsenv:UserDomain
            $Xaml.IO.Domain_OU.Text                           = $tsenv:MachineObjectOU
            $Xaml.IO.Domain_Username.Text                     = $tsenv:UserId
            $Xaml.IO.Domain_Password.Password                 = $tsenv:UserPassword
            $Xaml.IO.Domain_Confirm.Password                  = $tsenv:UserPassword
        }
        SetNetwork([Object]$Xaml,[UInt32]$Index)
        {
            If ($This.Network.Count -eq 0)
            {
                Throw "Invalid network count (0) - cannot proceed"
            }

            $IPInfo                                           = @($This.Network,$This.Network[$Index])[$This.Network.Count -gt 1]
            $X                                                = $IPInfo.DhcpServer.Count

            # [Network Type]
            $Xaml.IO.Network_Type.SelectedIndex               = $X

            # [Index]
            $Xaml.IO.Network_Index.Text                       = $IPInfo.Index
            $Xaml.IO.Network_Index.IsReadOnly                 = 1

            # [IPAddress]
            $Xaml.IO.Network_IPAddress.Text                   = $IPInfo.IPAddress
            $Xaml.IO.Network_IPAddress.IsReadOnly             = @(1,0)[$X]

            # [Subnetmask]
            $Xaml.IO.Network_SubnetMask.Text                  = $IPInfo.SubnetMask
            $Xaml.IO.Network_SubnetMask.IsReadOnly            = @(1,0)[$X]

            # [Gateway]
            $Xaml.IO.Network_Gateway.Text                     = $IPInfo.Gateway
            $Xaml.IO.Network_Gateway.IsReadOnly               = @(1,0)[$X]
            
            # [Dns]
            $This.Reset($Xaml.IO.Network_DNS.Items,$IPInfo.DNSServer)
            $Xaml.IO.Network_DNS.SelectedIndex                = 0

            # [Dhcp]
            $Xaml.IO.Network_Dhcp.Text                        = $IPInfo.DhcpServer
            $Xaml.IO.Network_Dhcp.IsReadOnly                  = @(1,0)[$X]

            # [MacAddress]
            $Xaml.IO.Network_MacAddress.Text                  = $IPInfo.MacAddress
            $Xaml.IO.Network_MacAddress.IsReadOnly            = 1
        }
        [UInt32] MachineType()
        {
            Return ($tsenv:IsDesktop,$tsenv:IsLaptop,$tsenv:IsSff,$tsenv:IsServer,$tsenv:IsTablet).IndexOf("True")
        }
        [Object] Pair([String]$Name,[Object]$Value)
        {
            Return [DGList]::New($Name,$Value)
        }
        SafeClear([Object]$Sender)
        {
            $This.Lock = 1
            $Sender    = ""
            $This.Lock = 0
        }
        Cycle([UInt32]$Slot,[Object]$Sender)
        {
            $Object = @($This.Query($Slot))
            $This.Reset($Sender,$Object)
        }
        Cycle([UInt32]$Slot,[Object]$Sender,[String]$Property,[String]$Filter)
        {
            $Object = @($This.Query($Slot,$Property,$Filter))
            $This.Reset($Sender,$Object)
        }
        Reset([Object]$Sender,[Object[]]$Content)
        {
            If ($Content.Count -gt 0)
            {
                $Sender.Clear()
                ForEach ($Item in $Content)
                {
                    $Sender.Add($Item)
                }
            }
        }
        [String] ToString()
        {
            Return "<FEWizard.Main>"
        }
    }

    If (!$Drive)
    {
        $Drive = Get-PSDrive
    } 

    $Script:Main = [Main]::New($Drive)
    $Script:Xaml = [XamlWindow][FEWizardGUI]::Tab

    # [Locale Panel]
    # TimeZone
    $Main.Reset($Xaml.IO.Locale_TimeZone.Items,$Main.TimeZone.DisplayName)
    If ($Main.GetTsEnv("TimeZoneName"))
    {
        $Xaml.IO.Locale_TimeZone.SelectedItem   = $Main.TimeZone | ? ID -eq $Main.GetTsEnv("TimeZoneName") | % DisplayName
    }

    Else
    {
        $Xaml.IO.Locale_TimeZone.SelectedIndex  = 0
    }

    # Keyboard
    $Main.Reset($Xaml.IO.Locale_Keyboard.Items,$Main.Locale.Culture)
    If ($Main.GetTsEnv("KeyboardLocale"))
    {
        $Xaml.IO.Locale_Keyboard.SelectedItem   = $Main.Locale | ? Culture -eq $Main.GetTsEnv("KeyboardLocale") | Select-Object -Last 1 | % Culture
    }
    Else
    {
        $Xaml.IO.Locale_Keyboard.SelectedIndex  = 0
    }

    # Language1
    $Main.Reset($Xaml.IO.Locale_Language1.Items,$Main.Locale.Name)
    If ($Main.GetTsEnv("KeyboardLocale"))
    {
        $Xaml.IO.Locale_Language1.SelectedItem  = $Main.Locale | ? Culture -eq $Main.GetTsEnv("KeyboardLocale") | Select-Object -Last 1 | % Name
    }
    Else
    {
        $Xaml.IO.Locale_TimeZone.SelectedIndex        = 0
    }

    $Xaml.IO.Locale_SecondLanguage.IsChecked          = 0
    $Xaml.IO.Locale_SecondLanguage.Add_Checked(
    {
        If (!$Xaml.IO.Locale_SecondLanguage.IsChecked)
        {
            $Xaml.IO.Locale_Language2.IsEnabled       = 0
            $Xaml.IO.Locale_Language2.Items.Clear()
            $Xaml.IO.Locale_Language2.SelectedIndex   = 0
        }
        If ($Xaml.IO.Locale_SecondLanguage.IsChecked)
        {
            $Xaml.IO.Locale_Language2.IsEnabled       = 1
            $Main.Reset($Xaml.IO.Locale_Language2.Items,$Main.Locale.Name)
            $Xaml.IO.Locale_Language2.SelectedIndex   = 0
        }
    })

    # [Misc Panel]
    # Misc_Finish_Action
    If ($tsenv:FinishAction)
    {
        $Xaml.IO.Misc_Finish_Action.SelectedIndex = @{""=0;"REBOOT"=1;"SHUTDOWN"=2;"LOGOFF"=3}[$tsenv:FinishAction]
    }

    # Misc_WSUSServer
    If ($tsenv:WSUSServer)
    {
        $Xaml.IO.Misc_WSUSServer.Text = $tsenv:WSUSServer
    }

    # Misc_EventService
    If ($tsenv:EventService)
    {
        $Xaml.IO.Misc_EventService.Text = $tsenv:EventService
    }
    # Misc_LogsSLShare
    # Misc_SLShare_DeployRoot
    # Misc_LogsSLShare_DynamicLogging
    # Misc_Product_Key_Type
    # Misc_HideShell
    # Misc_NoExtraPartition
    $Xaml.IO.Misc_Product_Key_Type.Add_SelectionChanged(
    {
        $Xaml.IO.Misc_Product_Key.Text      = ""
        Switch ($Xaml.IO.Misc_Product_Key_Type.SelectedIndex)
        {
            0 # [No product key is required]
            {
                $Xaml.IO.Misc_Product_Key.IsEnabled = 0
            }
            1 # [Activate with multiple activation key]
            {
                $Xaml.IO.Misc_Product_Key.IsEnabled = 1
            }
            2 # [Use a specific product key]
            {
                $Xaml.IO.Misc_Product_Key.IsEnabled = 1
            }
        }
    })

    # [Root Panel]
    $Xaml.IO.TaskSequence.Add_SelectionChanged(
    {
        If ($Xaml.IO.TaskSequence.SelectedIndex -gt -1)
        {
            $Xaml.IO.Task_ID.Text               = $Xaml.IO.TaskSequence.SelectedItem.ID
        }
    })

    # [Root.Init] - Loads the Root drive children items into the gui panels
    $Main.Cycle(4,$Xaml.IO.TaskSequence.Items)
    $Main.Cycle(0,$Xaml.IO.Application.Items)
    $Main.Cycle(2,$Xaml.IO.Driver.Items)
    $Main.Cycle(3,$Xaml.IO.Package.Items)
    $Main.Cycle(5,$Xaml.IO.Profile.Items)
    $Main.Cycle(1,$Xaml.IO.OperatingSystem.Items)
    $Main.Cycle(6,$Xaml.IO.LinkedShare.Items)
    $Main.Cycle(7,$Xaml.IO.Media.Items)

    # [Root.TaskSequence]
    $Xaml.IO.TaskSequenceFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.TaskSequenceFilter.Text -ne "")
            {
                $Main.Cycle(4,$Xaml.IO.TaskSequence.Items,$Xaml.IO.TaskSequenceProperty.SelectedItem.Content,$Xaml.IO.TaskSequenceFilter.Text)
            }
            Else
            {
                $Main.Cycle(4,$Xaml.IO.TaskSequence.Items)
            }
        }
    })

    $Xaml.IO.TaskSequenceRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.TaskSequenceFilter.Text)
        $Main.Cycle(4,$Xaml.IO.TaskSequence.Items)
    })

    # [Root.Application]
    $Xaml.IO.ApplicationFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.ApplicationFilter.Text -ne "")
            {
                $Main.Cycle(0,$Xaml.IO.Application.Items,$Xaml.IO.ApplicationProperty.SelectedItem.Content,$Xaml.IO.ApplicationFilter.Text)
            }
            Else
            {
                $Main.Cycle(0,$Xaml.IO.Application.Items)
            }
        }
    })

    $Xaml.IO.ApplicationRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.ApplicationFilter.Text)
        $Main.Cycle(0,$Xaml.IO.Application.Items)
    })

    # [Root.Driver]
    $Xaml.IO.DriverFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.DriverFilter.Text -ne "")
            {
                $Main.Cycle(2,$Xaml.IO.Driver.Items,$Xaml.IO.DriverProperty.SelectedItem.Content,$Xaml.IO.DriverFilter.Text)
            }
            Else
            {
                $Main.Cycle(2,$Xaml.IO.Driver.Items)
            }
        }
    })

    $Xaml.IO.DriverRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.DriverFilter.Text)
        $Main.Cycle(2,$Xaml.IO.Driver.Items)
    })

    # [Root.Package]
    $Xaml.IO.PackageFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.PackageFilter.Text -ne "")
            {
                $Main.Cycle(3,$Xaml.IO.Package.Items,$Xaml.IO.PackageProperty.SelectedItem.Content,$Xaml.IO.PackageFilter.Text)
            }
            Else
            {
                $Main.Cycle(3,$Xaml.IO.Package.Items)
            }
        }
    })

    $Xaml.IO.PackageRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.PackageFilter.Text)
        $Main.Cycle(3,$Xaml.IO.Package.Items)
    })

    # [Root.Profile]
    $Xaml.IO.ProfileFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.ProfileFilter.Text -ne "")
            {   
                $Main.Cycle(5,$Xaml.IO.Profile.Items,$Xaml.IO.ProfileProperty.SelectedItem.Content,$Xaml.IO.ProfileFilter.Text)
            }
            Else
            {
                $Main.Cycle(5,$Xaml.IO.Profile.Items)
            }
        }
    })

    $Xaml.IO.ProfileRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.ProfileFilter.Text)
        $Main.Cycle(5,$Xaml.IO.Profile.Items)
    })

    # [Root.OperatingSystem]
    $Xaml.IO.OperatingSystemFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.OperatingSystemFilter.Text -ne "")
            {
                $Main.Cycle(1,$Xaml.IO.OperatingSystem.Items,$Xaml.IO.OperatingSystemProperty.SelectedItem.Content,$Xaml.IO.OperatingSystemFilter.Text)
            }
            Else
            {
                $Main.Cycle(1,$Xaml.IO.OperatingSystem.Items)
            }
        }
    })

    $Xaml.IO.OperatingSystemRefresh.Add_Click(
    {    
        $Main.SafeClear($Xaml.IO.OperatingSystemFilter.Text)
        $Main.Cycle(1,$Xaml.IO.OperatingSystem.Items)
    })
    
    # [Root.LinkedShare]
    $Xaml.IO.LinkedShareFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.LinkedShareFilter.Text -ne "")
            {
                $Main.Cycle(6,$Xaml.IO.LinkedShare.Items,$Xaml.IO.LinkedShareProperty.SelectedItem.Content,$Xaml.IO.LinkedShareFilter.Text)
            }
            Else
            {
                $Main.Cycle(6,$Xaml.IO.LinkedShare.Items)
            }
        }
    })

    $Xaml.IO.LinkedShareRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.LinkedShareFilter.Text)
        $Main.Cycle(6,$Xaml.IO.LinkedShare.Items)
    })

    # [Root.Media]
    $Xaml.IO.MediaFilter.Add_TextChanged(
    {
        If ($Main.Lock -eq 0)
        {
            If ($Xaml.IO.MediaFilter.Items -ne "")
            {
                $Main.Cycle(7,$Xaml.IO.Media.Items,$Xaml.IO.MediaProperty.SelectedItem.Content,$Xaml.IO.MediaFilter.Text)
            }
            Else
            {
                $Main.Cycle(7,$Xaml.IO.Media.Items)
            }
        }
    })

    $Xaml.IO.MediaRefresh.Add_Click(
    {
        $Main.SafeClear($Xaml.IO.MediaFilter.Text)
        $Main.Cycle(7,$Xaml.IO.Media.Items)
    })

    # [System]
    $Xaml.IO.System_Manufacturer | % { $_.Text = $Main.System.Manufacturer; $_.IsReadOnly = 1 }
    $Xaml.IO.System_Model        | % { $_.Text = $Main.System.Model;        $_.IsReadOnly = 1 }
    $Xaml.IO.System_Product      | % { $_.Text = $Main.System.Product;      $_.IsReadOnly = 1 } 
    $Xaml.IO.System_Serial       | % { $_.Text = $Main.System.Serial;       $_.IsReadOnly = 1 }
    $Xaml.IO.System_Memory       | % { $_.Text = $Main.System.Memory;       $_.IsReadOnly = 1 }
    $Xaml.IO.System_UUID         | % { $_.Text = $Main.System.UUID;         $_.IsReadOnly = 1 }
    
    # Processor
    $Main.Reset($Xaml.IO.System_Processor.Items,$Main.System.Processor.Name)
    $Xaml.IO.System_Processor.SelectedIndex           = 0

    $Xaml.IO.System_Architecture.SelectedIndex        = $Main.System.Architecture -eq "x64"
    $Xaml.IO.System_Architecture.IsEnabled            = 0

    # Chassis
    $Xaml.IO.System_IsVM.IsChecked                    = $Main.GetTsEnv("IsVm")    
    $Xaml.IO.System_Chassis.SelectedIndex             = $Main.MachineType()
    $Xaml.IO.System_Chassis.IsEnabled                 = 0

    $Xaml.IO.System_BiosUefi.SelectedIndex            = $Main.System.BiosUefi -eq "UEFI"
    $Xaml.IO.System_BiosUefi.IsEnabled                = 0

    $Xaml.IO.System_UseSerial.Add_Checked(
    {
        Switch ($Xaml.IO.System_UseSerial.IsChecked)
        {
            0
            { 
                $Xaml.IO.System_Name.Text = $Null 
            }

            1
            { 
                $Xaml.IO.System_Name.Text = ($Main.System.Serial -Replace "\-","").ToCharArray()[0..14] -join '' 
            } 
        }
    })

    $Xaml.IO.System_UseSerial.IsChecked               = 0
    $Xaml.IO.System_Name.Text = $Env:ComputerName

    # Disks
    $Main.Reset($Xaml.IO.System_Disk.Items,$Main.System.Disk)

    # [Domain]
    $Xaml.IO.Domain_Type.SelectedIndex                = 0
    $Xaml.IO.Domain_OrgEdit.IsChecked                 = 0
    $Xaml.IO.Domain_OrgEdit.Add_Checked(
    {
        Switch ([UInt32]($Xaml.IO.Domain_OrgEdit.IsChecked))
        {
            0
            {
                $Xaml.IO.Domain_OrgName.IsReadOnly    = 1
            }

            1
            {
                $Xaml.IO.Domain_OrgName.IsReadOnly        = 0
                $Main.SetDomain($Xaml,1)
            }
        }
    })

    $Main.SetDomain($Xaml,1)
    $Xaml.IO.Domain_Type.Add_SelectionChanged(
    {
        Switch ($Xaml.IO.Domain_Type.SelectedItem)
        {
            Domain { $Main.SetDomain($Xaml,1) } Workgroup { $Main.SetDomain($Xaml,0) }
        }
    })

    If ($tsenv:MachineObjectOU)
    {
        $Xaml.IO.Domain_OU.Text = $tsenv:MachineObjectOU
    }

    If ($tsenv:Home_Page)
    {
        $xaml.IO.Domain_HomePage.Text = $tsenv:Home_Page
    }

    # [Network]
    $Main.Reset($Xaml.IO.Network_Adapter.Items,$Main.System.Network.Name)
    $Xaml.IO.Network_Adapter.Add_SelectionChanged(
    {
        If ($Xaml.IO.Network_Adapter.SelectedIndex -ne -1)
        {
            $Main.SetNetwork($Xaml,$Xaml.IO.Network_Adapter.SelectedIndex)
        }
    })

    $Main.SetNetwork($Xaml,0)
    $Xaml.IO.Network_Adapter.SelectedIndex = 0

    # [Control]
    $Xaml.IO.Control_Mode.Add_SelectionChanged(
    {
        $Xaml.IO.Computer_Backup.Visibility           = "Collapsed"
        $Xaml.IO.Computer_Capture.Visibility          = "Collapsed"
        $Xaml.IO.User_Backup.Visibility               = "Collapsed"
        $Xaml.IO.User_Restore.Visibility              = "Collapsed"
        
        Switch ($Xaml.IO.Control_Mode.SelectedIndex)
        {
            0 
            { 
                $Description = "Perform a fresh installation of an operating system"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }

            1 
            { 
                $Description = "Perform an in-place upgrade, preserving the content"
                $Xaml.IO.Computer_Backup.Visibility   = "Visible"
                $Xaml.IO.User_Backup.Visibility       = "Visible"
            }

            2 
            { 
                $Description = "Convert a physical machine to a virtual machine"
                $Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }

            3 
            { 
                $Description = "Convert a virtual machine to a physical machine"
                $Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Xaml.IO.User_Restore.Visibility      = "Visible"
            }
        }
        $Xaml.IO.Control_Description.Text             = $Description
    })

    $Xaml.IO.Control_Mode.SelectedIndex               = 0
    
    $Xaml.IO.Control_Username.Text                    = $Main.GetTsEnv("UserID")
    $Xaml.IO.Control_Domain.Text                      = $Main.GetTsEnv("UserDomain")
    $Xaml.IO.Control_Password.Password                = $Main.GetTsEnv("UserPassword")
    $Xaml.IO.Control_Confirm.Password                 = $Main.GetTsEnv("UserPassword")

    $Xaml.IO.Start.Add_Click(
    {
        # Task Sequence Selection
        If ($Xaml.IO.Task_ID.Text -eq "")
        {
            [System.Windows.MessageBox]::Show("Task sequence not selected","Error")
            Break
        }
        ElseIf ($Xaml.IO.Task_ID.Text -in $Main.Tree | ? Name -match Task | % { $_.Children.ID } )
        {
            [System.Windows.MessageBox]::Show("Invalid task sequence selected","Error")
            Break
        }
        Else
        { 
            $Main.SetTsEnv("TaskSequenceID",$Xaml.IO.Task_ID.Text)
            Write-Host "Task sequence [$($Xaml.IO.Task_ID.Text)] selected"
        }

        # [System Name]
        If ($Xaml.IO.System_Name.Text -eq "")
        {
            [System.Windows.MessageBox]::Show("Must designate a target computer name","Error")
            Break
        }
        ElseIf ($Xaml.IO.System_Name.Text -ne "")
        {
            Try
            {
                Test-Connection $Xaml.IO.System_Name.Text -Count 1 -EA 0
            }
            Catch
            {
                $Main.SetTSEnv("OSDComputerName",$Xaml.IO.System_Name.Text)
                Write-Host "Set [+] System Name [$($Main.GetTSEnv("OSDComputerName"))]"
            }
        }

        # Misc Variables
        # [Finish action]
        If ($Xaml.IO.Misc_Finish_Action.SelectedIndex -gt 0)
        {
            $Main.SetTSEnv("FinishAction", @("","REBOOT","SHUTDOWN","LOGOFF")[$Xaml.IO.Misc_Finish_Action.SelectedIndex])
        }

        # [WSUS Server]
        If ($Xaml.IO.Misc_WSUSServer.Text -ne "")
        {
            Try
            {
                Test-Connection $Xaml.IO.Misc_WSUSServer.Text -Count 1 -EA 0
                $Main.SetTSEnv("WSUSServer", $Xaml.IO.Misc_WSUSServer.Text)
            }
            Catch
            {
                $Main.SetTSEnv("WSUSServer", $Null)
            }
            Write-Host "WSUS Server variable set"
        }
		
        # [Event Service]
        If ($Xaml.IO.Misc_EventService.Text -ne "")
        {
            If ($Xaml.IO.Misc_EventService.Text -ne $tsenv:EventService)
            {
                $Server = @( Switch -Regex ($Xaml.IO.Misc_EventService.Text)
                {
                    "http[s]*://"
                    {
                        $Xaml.IO.Misc_EventService.Text -Replace "http[s]*://", ""
                    }
                    Default
                    {
                        $Xaml.IO.Misc_EventService.Text
                    }

                }).Split(":")[0]

                Try
                {
                    Test-Connection $Server -Count 1 -EA 0
                    $Main.SetTSEnv("EventService",$Xaml.IO.Misc_EventService.Text)
                }
                Catch
                {
                    $Main.SetTSEnv("EventService",$Null)
                }
                Write-Host "Event Service variable set"
            }
        }	

        # [SLShare]
	    If ($Xaml.IO.Misc_LogsSLShare_DynamicLogging.Text -ne "")
		{
            Try 
            {
                Test-Path $Xaml.IO.Misc_LogsSLShare_DynamicLogging.Text
    		    $Main.SetTSEnv("SLShareDynamicLogging",$Xaml.IO.Misc_LogsSLShare_DynamicLogging.Text)
            }
            Catch
            {
                $Main.SetTSEnv("SLShareDynamicLogging",$Null)
            }
            Write-Host "Script Log Share: Dynamic Logging"
		}		

	    Switch ([UInt32]($Xaml.IO.Misc_SLShare_DeployRoot.IsChecked))
		{
            0
            {
                $Main.SetTSEnv("SLShare","%OSD_Logs_SLShare%")
            }
            1
            {
	    		$Main.SetTSEnv("SLShare","%DeployRoot%\Logs\$tsenv:OSDComputerName")
            }		
		}
        
        If ($Xaml.IO.Misc_HideShell.IsChecked)
        {
            $Main.SetTSEnv("HideShell","YES")
        }
			
	    If ($Xaml.IO.Misc_NoExtraPartition.IsChecked)
		{
			$Main.SetTSEnv("DoNotCreateExtraPartition","YES")
		}		

        Switch ($Xaml.IO.Misc_Product_Key_Type.SelectedIndex)
        {
            0 
            { 
                $Main.SetTSEnv("ProductKey",$Null)
            }
            1 
            { 
                $Key = $Xaml.IO.Misc_Product_Key.Text -Replace "-",""
                If ($Key -match "((\w|\d){25}")
                {
                    $Main.SetTSEnv("ProductKey",$Key) 
                }
            }
            2 
            {  
                $Key = $Xaml.IO.Misc_Product_Key.Text -Replace "-",""
                If ($Key -match "((\w|\d){25}")
                {
                    $Main.SetTSEnv("OverrideProductKey",$Key) 
                }
            }
        }

        $Main.SetTSEnv("Wizard_Complete",$True)
        $Xaml.IO.DialogResult = $True
        $Xaml.IO.Close()
    })
    
    $Xaml.IO.Cancel.Add_Click(
    {
        $Xaml.IO.DialogResult = $False
        $Xaml.IO.Close()
    })

    $Main.Xaml = $Xaml

    Return $Main
}

Function Show-FEWizard
{
    Param ($Drive)
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing wizard from [Get-FEWizard]"
    Return Get-FEWizard $Drive
}

Export-ModuleMember -Function Show-FEWizard, Show-PSDWizard
