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
          Purpose:  Initializes the (MDT Task Sequence Wizard [UI/User Interface])
          Author:   Original [PSD Development Team], 
                    Modified [mcc85s]
          Contact:  Original [@Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy]
                    Modified [@mcc85s]
          Primary:  Original [@Mikael_Nystrom]
                    Modofied [@mcc85s]
          Created: 
          Modified: 2021-12-29

          Version - 0.0.0 - () - Finalized functional version 1.
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

Function Get-PSDWizardGUI
{
    Class PSDWizardGUI
    {
        Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://PowerShell Deployment Wizard (v1)" Width="750" Height="480" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="BorderBrush" Value="DarkBlue"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Margin" Value="10,0,10,0"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="Button">',
        '                        <Border CornerRadius="10" Background="#007bff" BorderBrush="Black" BorderThickness="3">',
        '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
        '                        </Border>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="HorizontalAlignment" Value="Left"/>',
        '            <Setter Property="VerticalAlignment" Value="Center"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Padding" Value="5"/>',
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
        '            <Setter Property="Margin" Value="10,0,10,0"/>',
        '            <Setter Property="TextWrapping" Value="Wrap"/>',
        '            <Setter Property="Height" Value="24"/>',
        '        </Style>',
        '        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Margin" Value="10,0,10,0"/>',
        '            <Setter Property="Height" Value="24"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.ColumnDefinitions>',
        '            <ColumnDefinition Width="*"/>',
        '            <ColumnDefinition Width="1.25*"/>',
        '        </Grid.ColumnDefinitions>',
        '        <Grid Grid.Column="0">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="260"/>',
        '                <RowDefinition Height="150"/>',
        '                <RowDefinition Height="50"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Grid.Row="0" Header="[Task Sequence List]">',
        '                <TreeView  Name="tsTree" Margin="5" ScrollViewer.VerticalScrollBarVisibility="Visible" ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                    <TreeView.Effect>',
        '                        <DropShadowEffect ShadowDepth="1"/>',
        '                    </TreeView.Effect>',
        '                </TreeView>',
        '            </GroupBox>',
        '            <GroupBox Grid.Row="1" Header="[MDT Info]">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label   Grid.Row="0" Grid.Column="0" Content="[Deploy Root]:"/>',
        '                    <TextBox Grid.Row="0" Grid.Column="1" Name="TS_Deployroot" Text="1234567890" IsReadOnly="True"/>',
        '                    <Label   Grid.Row="1" Grid.Column="0" Content="[Task Sequence]:"/>',
        '                    <TextBox Grid.Row="1" Grid.Column="1" Name="TS_TaskSequenceID"/>',
        '                    <Label   Grid.Row="2" Grid.Column="0" Content="[OSDRnD]:"/>',
        '                    <TextBox Grid.Row="2" Grid.Column="1" Name="TS_OSDRnD"/>',
        '                </Grid>',
        '            </GroupBox>',
        '            <Grid Grid.Row="2">',
        '                <Grid.ColumnDefinitions>',
        '                    <ColumnDefinition Width="*"/>',
        '                    <ColumnDefinition Width="*"/>',
        '                </Grid.ColumnDefinitions>',
        '                <Button Grid.Column="0" Name="wizFinishButton" Content="Start" />',
        '                <Button Grid.Column="1" Name="wizCancelButton" Content="Cancel" />',
        '            </Grid>',
        '        </Grid>',
        '        <Grid Grid.Column="1">',
        '            <Grid.RowDefinitions>',
        '                <RowDefinition Height="230"/>',
        '                <RowDefinition Height="230"/>',
        '            </Grid.RowDefinitions>',
        '            <GroupBox Grid.Row="0" Header="[Asset Info]">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="80"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label       Grid.Row="0" Grid.Column="0" Content="[Model]:"/>',
        '                    <TextBox     Grid.Row="0" Grid.Column="1" Name="TS_Model" IsReadOnly="True" Text="1234567890"/>',
        '                    <Label       Grid.Row="1" Grid.Column="0" Content="[Serial Number]:"/>',
        '                    <TextBox     Grid.Row="1" Grid.Column="1" Name="TS_SerialNumber" IsReadOnly="True" Text="1234567890"/>',
        '                    <Label       Grid.Row="2" Grid.Column="0" Content="[Computer Name]:"/>',
        '                    <TextBox     Grid.Row="2" Grid.Column="1" Name="TS_OSDComputerName"/>',
        '                    <GroupBox Grid.Row ="3" Grid.Column="0" Grid.ColumnSpan="2"  Header="[Local Admin (Password/Confirm)]">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <PasswordBox Grid.Column="0" Name="TS_AdminPassword"/>',
        '                            <PasswordBox Grid.Column="1" Name="AdminConfirm"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </GroupBox>',
        '            <GroupBox Grid.Row="1" Header="[Domain Info]">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="80"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label    Grid.Row="0" Grid.Column="0" Content="[NetBIOS]:"/>',
        '                    <TextBox  Grid.Row="0" Grid.Column="1" Name="TS_JoinDomain"/>',
        '                    <Label    Grid.Row="1" Grid.Column="0" Content="[DNS Name]:"/>',
        '                    <TextBox  Grid.Row="1" Grid.Column="1" Name="TS_DomainAdminDomain"/>',
        '                    <Label    Grid.Row="2" Grid.Column="0" Content="[Username]"/>',
        '                    <TextBox  Grid.Row="2" Grid.Column="1" Name="TS_DomainAdmin"/>',
        '                    <GroupBox Grid.Row ="3" Grid.Column="0" Grid.ColumnSpan="2"  Header="[Domain Admin (Password/Confirm)]">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <PasswordBox Grid.Column="0" Name="TS_DomainAdminPassword"/>',
        '                            <PasswordBox Grid.Column="1" Name="DomainAdminConfirm"/>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </GroupBox>',
        '        </Grid>',
        '    </Grid>',
        '</Window>' -join "`n")
    }
    [PSDWizardGUI]::Tab
}

Function Get-PSDWizard # Left for legacy purposes, unused
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
    Param ([String]$xamlPath)

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing wizard from [$XamlPath]"
    $Script:Wizard = Get-PSDWizard $XamlPath
    Set-PSDWizardDefault
    $Result = $Wizard.ShowDialog()
    Save-PSDWizardResult
    Return $Script:Wizard
}

Function Get-FEWizard
{
    Param ([Object[]]$Drive)

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
    Class FEWizardGUI # Get-Content $Home\Desktop\FEWizard.xaml | % { "        '$_'," } | Set-Clipboard
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
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label       Grid.Row="0" Grid.Column="0" Content="[System Name]:"     ToolTip="Enter a new system name"/>',
        '                            <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Name"/>',
        '                            <CheckBox    Grid.Row="0" Grid.Column="2" Name="System_UseSerial" Content="Name w/ Serial #" HorizontalAlignment="Center"/>',
        '                            <Label       Grid.Row="1" Grid.Column="0" Content="[System Password]:" ToolTip="Enter a new system password"/>',
        '                            <PasswordBox Grid.Row="1" Grid.Column="1" Name="System_Password"/>',
        '                            <Label       Grid.Row="1" Grid.Column="2" Content="[Confirm]:"/>',
        '                            <PasswordBox Grid.Row="1" Grid.Column="3" Name="System_Confirm"/>',
        '                            <Border      Grid.Row="2" Grid.ColumnSpan="4" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label       Grid.Row="3" Grid.Column="0" Content="[Manufacturer]:"/>',
        '                            <TextBox     Grid.Row="3" Grid.Column="1" Name="System_Manufacturer"/>',
        '                            <Label       Grid.Row="3" Grid.Column="2" Content="[Product]:"/>',
        '                            <TextBox     Grid.Row="3" Grid.Column="3" Name="System_Product"/>',
        '                            <Label       Grid.Row="4" Grid.Column="0" Content="[Model]:"/>',
        '                            <TextBox     Grid.Row="4" Grid.Column="1" Name="System_Model"/>',
        '                            <Label       Grid.Row="4" Grid.Column="2" Content="[Serial]:"/>',
        '                            <TextBox     Grid.Row="4" Grid.Column="3" Name="System_Serial"/>',
        '                            <Label       Grid.Row="5" Grid.Column="0" Content="[Processor]:"/>',
        '                            <ComboBox    Grid.Row="5" Grid.Column="1" Name="System_Processor"/>',
        '                            <Label       Grid.Row="5" Grid.Column="2" Content="[Memory]:"/>',
        '                            <TextBox     Grid.Row="5" Grid.Column="3" Name="System_Memory"/>',
        '                            <Label       Grid.Row="6" Grid.Column="0" Content="[Architecture]:"/>',
        '                            <ComboBox    Grid.Row="6" Grid.Column="1" Name="System_Architecture">',
        '                                <ComboBoxItem Content="x86"/>',
        '                                <ComboBoxItem Content="x64"/>',
        '                            </ComboBox>',
        '                            <StackPanel  Grid.Row="6" Grid.Column="2" Orientation="Horizontal">',
        '                                <Label    Content="[Chassis]:"/>',
        '                                <CheckBox Name="System_IsVM" Content="VM" IsEnabled="False"/>',
        '                            </StackPanel>',
        '                            <ComboBox    Grid.Row="6" Grid.Column="3" Name="System_Chassis">',
        '                                <ComboBoxItem Content="Desktop"/>',
        '                                <ComboBoxItem Content="Laptop"/>',
        '                                <ComboBoxItem Content="Small Form Factor"/>',
        '                                <ComboBoxItem Content="Server"/>',
        '                                <ComboBoxItem Content="Tablet"/>',
        '                            </ComboBox>',
        '                            <Label       Grid.Row="7" Grid.Column="0" Content="[UUID]:"/>',
        '                            <TextBox     Grid.Row="7" Grid.Column="1" Grid.ColumnSpan="2" Name="System_UUID"/>',
        '                            <StackPanel  Grid.Row="7" Grid.Column="3" Orientation="Horizontal">',
        '                                <Label   Content="[BIOS/UEFI]:"/>',
        '                                <ComboBox Name="System_BiosUefi" Width="150">',
        '                                    <ComboBoxItem Content="BIOS"/>',
        '                                    <ComboBoxItem Content="UEFI"/>',
        '                                </ComboBox>',
        '                            </StackPanel>',
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
        '                                        <ComboBoxItem Content="Specify a location"/>',
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
            Return Get-ChildItem tsenv: | ? Name -eq $Name | % Value
        }
        SetTSEnv([String]$Name,[Object]$Value)
        {
            If (!(Get-Item tsenv:\$Name))
            {
                New-Item -Path tsenv:\$Name -Value $Value -Verbose
            }
            Else
            {
                Set-Item -Path tsenv:\$Name -Value $Value -Verbose
            }
        }
        SetDomain([UInt32]$Slot)
        {
            $This.Xaml.IO.Domain_OrgName.Text                      = $tsenv:_SMSTSOrgName
            $This.Xaml.IO.Domain_Name.Text                         = $tsenv:UserDomain
            $This.Xaml.IO.Domain_OU.Text                           = $tsenv:MachineObjectOU
            $This.Xaml.IO.Domain_Username.Text                     = $tsenv:UserId
            $This.Xaml.IO.Domain_Password.Password                 = $tsenv:UserPassword
            $This.Xaml.IO.Domain_Confirm.Password                  = $tsenv:UserPassword
        }
        SetNetwork([UInt32]$Index)
        {
            If ($This.Network.Count -eq 0)
            {
                Throw "Invalid network count (0) - cannot proceed"
            }
            $IPInfo                                           = @($This.Network,$This.Network[$Index])[$This.Network.Count -gt 1]
            $X                                                = $IPInfo.DhcpServer.Count
            # [Network Type]
            $This.Xaml.IO.Network_Type.SelectedIndex               = $X
            # [Index]
            $This.Xaml.IO.Network_Index.Text                       = $IPInfo.Index
            $This.Xaml.IO.Network_Index.IsReadOnly                 = 1
            # [IPAddress]
            $This.Xaml.IO.Network_IPAddress.Text                   = $IPInfo.IPAddress
            $This.Xaml.IO.Network_IPAddress.IsReadOnly             = @(1,0)[$X]
            # [Subnetmask]
            $This.Xaml.IO.Network_SubnetMask.Text                  = $IPInfo.SubnetMask
            $This.Xaml.IO.Network_SubnetMask.IsReadOnly            = @(1,0)[$X]
            # [Gateway]
            $This.Xaml.IO.Network_Gateway.Text                     = $IPInfo.Gateway
            $This.Xaml.IO.Network_Gateway.IsReadOnly               = @(1,0)[$X]
            
            # [Dns]
            $This.Reset($This.Xaml.IO.Network_DNS.Items,$IPInfo.DNSServer)
            $This.Xaml.IO.Network_DNS.SelectedIndex                = 0
            # [Dhcp]
            $This.Xaml.IO.Network_Dhcp.Text                        = $IPInfo.DhcpServer
            $This.Xaml.IO.Network_Dhcp.IsReadOnly                  = @(1,0)[$X]
            # [MacAddress]
            $This.Xaml.IO.Network_MacAddress.Text                  = $IPInfo.MacAddress
            $This.Xaml.IO.Network_MacAddress.IsReadOnly            = 1
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
        LoadXaml([Object]$Xaml)
        {
            $This.Xaml = $Xaml
        }
    }

    $Script:Wizard = [Main]::New($Drive)
    $Script:Xaml   = [XamlWindow][FEWizardGUI]::Tab
    $Wizard.LoadXaml($Xaml)
    $Script:Xaml   = $Wizard.Xaml

    # [Set Defaults]

    # [Locale Panel/TimeZone()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Locale Panel/TimeZone()]"
    $Wizard.Reset($Wizard.Xaml.IO.Locale_TimeZone.Items,$Wizard.TimeZone.DisplayName)
    $TimeZoneName = Get-Item tsenv:\TimeZoneName | % Value
    If ($TimeZoneName)
    {
        $Wizard.Xaml.IO.Locale_TimeZone.SelectedItem = $Wizard.TimeZone | ? ID -eq $TimeZoneName | % DisplayName
    }
    Else
    {
        $Wizard.Xaml.IO.Locale_TimeZone.SelectedIndex = 0
    }
    
    # [Locale Panel/Keyboard()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Locale Panel/Keyboard()]"
    $Wizard.Reset($Wizard.Xaml.IO.Locale_Keyboard.Items,$Wizard.Locale.Culture)
    $KeyboardLocale = (Get-Item tsenv:\KeyboardLocale).Value
    If ($KeyboardLocale)
    {
        $Wizard.Xaml.IO.Locale_Keyboard.SelectedItem   = $Wizard.Locale | ? Culture -eq $KeyboardLocale | Select-Object -Last 1 | % Culture
    }
    Else
    {
        $Wizard.Xaml.IO.Locale_Keyboard.SelectedIndex  = 0
    }

    # [Locale Panel/Language()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Locale Panel/Language()]"
    $Wizard.Reset($Wizard.Xaml.IO.Locale_Language1.Items,$Wizard.Locale.Name)
    $KeyboardLocale = (Get-Item tsenv:\KeyboardLocale).Value
    If ($KeyboardLocale)
    {
        $Wizard.Xaml.IO.Locale_Language1.SelectedItem         = $Wizard.Locale | ? Culture -eq $KeyboardLocale | Select-Object -Last 1 | % Name
    }
    Else
    {
        $Wizard.Xaml.IO.Locale_Language1.SelectedIndex        = 0
    }

    # [Locale Panel/SecondLanguage()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Locale Panel/SecondLanguage()]"
    $Wizard.Xaml.IO.Locale_SecondLanguage.IsChecked          = 0
    $Wizard.Xaml.IO.Locale_SecondLanguage.Add_Checked(
    {
        If ($Wizard.Xaml.IO.Locale_SecondLanguage.IsChecked)
        {
            $Wizard.Xaml.IO.Locale_Language2.IsEnabled       = 1
            $Wizard.Reset($Wizard.Xaml.IO.Locale_Language2.Items,$Wizard.Locale.Name)
            $Wizard.Xaml.IO.Locale_Language2.SelectedIndex   = 0
        }
        Else
        {
            $Wizard.Xaml.IO.Locale_Language2.IsEnabled       = 0
            $Wizard.Xaml.IO.Locale_Language2.Items.Clear()
            $Wizard.Xaml.IO.Locale_Language2.SelectedIndex   = 0
        }
    })

    # [Misc Panel/FinishAction()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Misc Panel/FinishAction()]"
    $Finish = (Get-Item tsenv:\FinishAction).Value
    If ($Finish)
    {
        $Wizard.Xaml.IO.Misc_Finish_Action.SelectedIndex = @{""=0;"REBOOT"=1;"SHUTDOWN"=2;"LOGOFF"=3}[$Finish]
    }

    # [Misc Panel/WSUSServer()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Misc Panel/WSUSServer()]"
    $WSUS = (Get-Item tsenv:\WSUSServer).Value
    If ($WSUS)
    {
        $Wizard.Xaml.IO.Misc_WSUSServer.Text = $WSUS
    }

    # [Misc Panel/EventService()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Misc Panel/EventService()]"
    $EventService = (Get-Item tsenv:\EventService).Value
    If ($EventService)
    {
        $Wizard.Xaml.IO.Misc_EventService.Text = $EventService
    }

    # [Misc Panel/ProductKey()]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Misc Panel/ProductKey()]"
    $Wizard.Xaml.IO.Misc_Product_Key_Type.Add_SelectionChanged(
    {
        $Wizard.Xaml.IO.Misc_Product_Key.Text      = ""
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
    
    # [Root Panel/TaskSequence (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/TaskSequence (Items)]"
    $Wizard.Cycle(4,$Wizard.Xaml.IO.TaskSequence.Items)

    # [Root Panel/TaskSequence (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/TaskSequence (SearchBox)]"
    $Wizard.Xaml.IO.TaskSequenceFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.TaskSequenceFilter.Text -ne "")
            {
                $Wizard.Cycle(4,$Wizard.Xaml.IO.TaskSequence.Items,$Wizard.Xaml.IO.TaskSequenceProperty.SelectedItem.Content,$Wizard.Xaml.IO.TaskSequenceFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(4,$Wizard.Xaml.IO.TaskSequence.Items)
            }
        }
    })

    # [Root Panel/TaskSequence (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/TaskSequence (Refresh)]"
    $Wizard.Xaml.IO.TaskSequenceRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.TaskSequenceFilter.Text)
        $Wizard.Cycle(4,$Wizard.Xaml.IO.TaskSequence.Items)
    })

    # [Root Panel/TaskSequence (Changed)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/TaskSequence (Changed)]"
    $Wizard.Xaml.IO.TaskSequence.Add_SelectionChanged(
    {
        If ($Wizard.Xaml.IO.TaskSequence.SelectedIndex -gt -1)
        {
            $Wizard.Xaml.IO.Task_ID.Text               = $Wizard.Xaml.IO.TaskSequence.SelectedItem.ID
        }
    })
    
    # [Root Panel/Application (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Application (Items)]"
    $Wizard.Cycle(0,$Wizard.Xaml.IO.Application.Items)

    # [Root Panel/Application (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Application (SearchBox)]"
    $Wizard.Xaml.IO.ApplicationFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.ApplicationFilter.Text -ne "")
            {
                $Wizard.Cycle(0,$Wizard.Xaml.IO.Application.Items,$Wizard.Xaml.IO.ApplicationProperty.SelectedItem.Content,$Wizard.Xaml.IO.ApplicationFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(0,$Wizard.Xaml.IO.Application.Items)
            }
        }
    })
    # [Root Panel/Application (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Application (Refresh)]"
    $Wizard.Xaml.IO.ApplicationRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.ApplicationFilter.Text)
        $Wizard.Cycle(0,$Wizard.Xaml.IO.Application.Items)
    })

    # [Root Panel/Driver (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Driver (Items)]"
    $Wizard.Cycle(2,$Wizard.Xaml.IO.Driver.Items)

    # [Root Panel/Driver (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Driver (SearchBox)]"
    $Wizard.Xaml.IO.DriverFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.DriverFilter.Text -ne "")
            {
                $Wizard.Cycle(2,$Wizard.Xaml.IO.Driver.Items,$Wizard.Xaml.IO.DriverProperty.SelectedItem.Content,$Wizard.Xaml.IO.DriverFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(2,$Wizard.Xaml.IO.Driver.Items)
            }
        }
    })

    # [Root Panel/Driver (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Driver (Refresh)]"
    $Wizard.Xaml.IO.DriverRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.DriverFilter.Text)
        $Wizard.Cycle(2,$Wizard.Xaml.IO.Driver.Items)
    })

    # [Root Panel/Package (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Package (Items)]"
    $Wizard.Cycle(3,$Wizard.Xaml.IO.Package.Items)

    # [Root Panel/Package (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Package (SearchBox)]"
    $Wizard.Xaml.IO.PackageFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.PackageFilter.Text -ne "")
            {
                $Wizard.Cycle(3,$Wizard.Xaml.IO.Package.Items,$Wizard.Xaml.IO.PackageProperty.SelectedItem.Content,$Wizard.Xaml.IO.PackageFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(3,$Wizard.Xaml.IO.Package.Items)
            }
        }
    })

    # [Root Panel/Package (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Package (Refresh)]"
    $Wizard.Xaml.IO.PackageRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.PackageFilter.Text)
        $Wizard.Cycle(3,$Wizard.Xaml.IO.Package.Items)
    })

    # [Root Panel/Profile (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Profile (Items)]"
    $Wizard.Cycle(5,$Wizard.Xaml.IO.Profile.Items)

    # [Root Panel/Profile (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Profile (SearchBox)]"
    $Wizard.Xaml.IO.ProfileFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.ProfileFilter.Text -ne "")
            {   
                $Wizard.Cycle(5,$Wizard.Xaml.IO.Profile.Items,$Wizard.Xaml.IO.ProfileProperty.SelectedItem.Content,$Wizard.Xaml.IO.ProfileFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(5,$Wizard.Xaml.IO.Profile.Items)
            }
        }
    })

    # [Root Panel/Profile (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Profile (Refresh)]"
    $Wizard.Xaml.IO.ProfileRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.ProfileFilter.Text)
        $Wizard.Cycle(5,$Wizard.Xaml.IO.Profile.Items)
    })

    # [Root Panel/OperatingSystem (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/OperatingSystem (Items)]"
    $Wizard.Cycle(1,$Wizard.Xaml.IO.OperatingSystem.Items)

    # [Root Panel/OperatingSystem (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/OperatingSystem (SearchBox)]"
    $Wizard.Xaml.IO.OperatingSystemFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.OperatingSystemFilter.Text -ne "")
            {
                $Wizard.Cycle(1,$Wizard.Xaml.IO.OperatingSystem.Items,$Wizard.Xaml.IO.OperatingSystemProperty.SelectedItem.Content,$Wizard.Xaml.IO.OperatingSystemFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(1,$Wizard.Xaml.IO.OperatingSystem.Items)
            }
        }
    })

    # [Root Panel/OperatingSystem (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/OperatingSystem (Refresh)]"
    $Xaml.IO.OperatingSystemRefresh.Add_Click(
    {    
        $Wizard.SafeClear($Wizard.Xaml.IO.OperatingSystemFilter.Text)
        $Wizard.Cycle(1,$Wizard.Xaml.IO.OperatingSystem.Items)
    })

    # [Root Panel/LinkedShare (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/LinkedShare (Items)]"
    $Wizard.Cycle(6,$Wizard.Xaml.IO.LinkedShare.Items)

    # [Root Panel/LinkedShare (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/LinkedShare (SearchBox)]"
    $Wizard.Xaml.IO.LinkedShareFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.LinkedShareFilter.Text -ne "")
            {
                $Wizard.Cycle(6,$Wizard.Xaml.IO.LinkedShare.Items,$Wizard.Xaml.IO.LinkedShareProperty.SelectedItem.Content,$Wizard.Xaml.IO.LinkedShareFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(6,$Wizard.Xaml.IO.LinkedShare.Items)
            }
        }
    })

    # [Root Panel/LinkedShare (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/LinkedShare (Refresh)]"
    $Wizard.Xaml.IO.LinkedShareRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.LinkedShareFilter.Text)
        $Wizard.Cycle(6,$Wizard.Xaml.IO.LinkedShare.Items)
    })

    # [Root Panel/Media (Items)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Media (Items)]"
    $Wizard.Cycle(7,$Wizard.Xaml.IO.Media.Items)

    # [Root Panel/Media (SearchBox)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Media (SearchBox)]"
    $Wizard.Xaml.IO.MediaFilter.Add_TextChanged(
    {
        If ($Wizard.Lock -eq 0)
        {
            If ($Wizard.Xaml.IO.MediaFilter.Items -ne "")
            {
                $Wizard.Cycle(7,$Wizard.Xaml.IO.Media.Items,$Wizard.Xaml.IO.MediaProperty.SelectedItem.Content,$Wizard.Xaml.IO.MediaFilter.Text)
            }
            Else
            {
                $Wizard.Cycle(7,$Wizard.Xaml.IO.Media.Items)
            }
        }
    })

    # [Root Panel/Media (Refresh)]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Root Panel/Media (Refresh)]"
    $Wizard.Xaml.IO.MediaRefresh.Add_Click(
    {
        $Wizard.SafeClear($Wizard.Xaml.IO.MediaFilter.Text)
        $Wizard.Cycle(7,$Wizard.Xaml.IO.Media.Items)
    })

    # [System/All]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [System/All]"
    $Wizard.Xaml.IO.System_Manufacturer | % { $_.Text = $Wizard.System.Manufacturer; $_.IsReadOnly = 1 }
    $Wizard.Xaml.IO.System_Model        | % { $_.Text = $Wizard.System.Model;        $_.IsReadOnly = 1 }
    $Wizard.Xaml.IO.System_Product      | % { $_.Text = $Wizard.System.Product;      $_.IsReadOnly = 1 } 
    $Wizard.Xaml.IO.System_Serial       | % { $_.Text = $Wizard.System.Serial;       $_.IsReadOnly = 1 }
    $Wizard.Xaml.IO.System_Memory       | % { $_.Text = $Wizard.System.Memory;       $_.IsReadOnly = 1 }
    $Wizard.Xaml.IO.System_UUID         | % { $_.Text = $Wizard.System.UUID;         $_.IsReadOnly = 1 }

    # [Processor]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Processor]"
    $Wizard.Reset($Wizard.Xaml.IO.System_Processor.Items,$Wizard.System.Processor.Name)
    $Wizard.Xaml.IO.System_Processor.SelectedIndex           = 0
    $Wizard.Xaml.IO.System_Architecture.SelectedIndex        = $Wizard.System.Architecture -eq "x64"
    $Wizard.Xaml.IO.System_Architecture.IsEnabled            = 0
    
    # [Chassis]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Chassis]"
    $Wizard.Xaml.IO.System_IsVM.IsChecked                    = $Wizard.GetTsEnv("IsVm")    
    $Wizard.Xaml.IO.System_Chassis.SelectedIndex             = $Wizard.MachineType()
    $Wizard.Xaml.IO.System_Chassis.IsEnabled                 = 0
    $Wizard.Xaml.IO.System_BiosUefi.SelectedIndex            = $Wizard.System.BiosUefi -eq "UEFI"
    $Wizard.Xaml.IO.System_BiosUefi.IsEnabled                = 0
    $Wizard.Xaml.IO.System_UseSerial.Add_Checked(
    {
        Switch ($Wizard.Xaml.IO.System_UseSerial.IsChecked)
        {
            $False
            { 
                $Wizard.Xaml.IO.System_Name.Text = $Null 
            }
            $True
            { 
                $Wizard.Xaml.IO.System_Name.Text = ($Wizard.System.Serial -Replace "\-","").ToCharArray()[0..14] -join '' 
            } 
        }
    })
    $Wizard.Xaml.IO.System_UseSerial.IsChecked               = $False
    $Wizard.Xaml.IO.System_Name.Text                         = $Env:ComputerName

    # [Disks]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Disks]"
    $Wizard.Reset($Wizard.Xaml.IO.System_Disk.Items,$Wizard.System.Disk)

    # [Domain/All]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Domain/All]"
    $Wizard.Xaml.IO.Domain_Type.SelectedIndex                = 0
    $Wizard.Xaml.IO.Domain_OrgEdit.IsChecked                 = 0
    $Wizard.Xaml.IO.Domain_OrgEdit.Add_Checked(
    {
        Switch ($Wizard.Xaml.IO.Domain_OrgEdit.IsChecked)
        {
            $False
            {
                $Wizard.Xaml.IO.Domain_OrgName.IsReadOnly    = 1
            }
            $True
            {
                $Wizard.Xaml.IO.Domain_OrgName.IsReadOnly    = 0
                $Wizard.SetDomain(1)
            }
        }
    })
    $Wizard.SetDomain(1)
    $Wizard.Xaml.IO.Domain_Type.Add_SelectionChanged(
    {
        Switch ($Wizard.Xaml.IO.Domain_Type.SelectedItem)
        {
            Domain { $Wizard.SetDomain(1) } Workgroup { $Wizard.SetDomain(0) }
        }
    })
    If ($tsenv:MachineObjectOU)
    {
        $Wizard.Xaml.IO.Domain_OU.Text = $tsenv:MachineObjectOU
    }
    If ($tsenv:Home_Page)
    {
        $Wizard.Xaml.IO.Domain_HomePage.Text = $tsenv:Home_Page
    }

    # [Network]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Network/All]"
    $Wizard.Reset($Wizard.Xaml.IO.Network_Adapter.Items,$Wizard.System.Network.Name)
    $Wizard.Xaml.IO.Network_Adapter.Add_SelectionChanged(
    {
        If ($Wizard.Xaml.IO.Network_Adapter.SelectedIndex -ne -1)
        {
            $Wizard.SetNetwork($Wizard.Xaml.IO.Network_Adapter.SelectedIndex)
        }
    })
    $Wizard.SetNetwork(0)
    $Wizard.Xaml.IO.Network_Adapter.SelectedIndex = 0

    # [Control]
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Default [~] [Control/All]"
    $Wizard.Xaml.IO.Control_Mode.Add_SelectionChanged(
    {
        $Wizard.Xaml.IO.Computer_Backup.Visibility           = "Collapsed"
        $Wizard.Xaml.IO.Computer_Capture.Visibility          = "Collapsed"
        $Wizard.Xaml.IO.User_Backup.Visibility               = "Collapsed"
        $Wizard.Xaml.IO.User_Restore.Visibility              = "Collapsed"
        
        Switch ($Wizard.Xaml.IO.Control_Mode.SelectedIndex)
        {
            0 
            { 
                $Description = "Perform a fresh installation of an operating system"
                $Wizard.Xaml.IO.User_Restore.Visibility      = "Visible"
            }
            1 
            { 
                $Description = "Perform an in-place upgrade, preserving the content"
                $Wizard.Xaml.IO.Computer_Backup.Visibility   = "Visible"
                $Wizard.Xaml.IO.User_Backup.Visibility       = "Visible"
            }
            2 
            { 
                $Description = "Convert a physical machine to a virtual machine"
                $Wizard.Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Wizard.Xaml.IO.User_Restore.Visibility      = "Visible"
            }
            3 
            { 
                $Description = "Convert a virtual machine to a physical machine"
                $Wizard.Xaml.IO.Computer_Capture.Visibility  = "Visible"
                $Wizard.Xaml.IO.User_Restore.Visibility      = "Visible"
            }
        }
        $Wizard.Xaml.IO.Control_Description.Text             = $Description
    })
    $Wizard.Xaml.IO.Control_Mode.SelectedIndex               = 0
    
    $Wizard.Xaml.IO.Control_Username.Text                    = $Wizard.GetTsEnv("UserID")
    $Wizard.Xaml.IO.Control_Domain.Text                      = $Wizard.GetTsEnv("UserDomain")
    $Wizard.Xaml.IO.Control_Password.Password                = $Wizard.GetTsEnv("UserPassword")
    $Wizard.Xaml.IO.Control_Confirm.Password                 = $Wizard.GetTsEnv("UserPassword")

    Return $Wizard
}

Function Show-FEWizard
{
    Param ([Object[]]$Drive)

    $Script:Wizard = Get-FEWizard $Drive

    $Wizard.Xaml.IO.Start.Add_Click(
    {
        # CheckTaskSequenceID()
        If ($Wizard.Xaml.IO.Task_ID.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("Task sequence not selected","Error") 
        }
        ElseIf ($Wizard.Xaml.IO.Task_ID.Text -notin $Wizard.Tree | ? Name -match Task | % { $_.Children.ID })
        {
            Return [System.Windows.MessageBox]::Show("Invalid task sequence selected","Error")
        }
        Else
        {
            $Wizard.SetTsEnv("TaskSequenceID",$Wizard.Xaml.IO.Task_ID.Text)
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TaskSequenceID [+] [$($Wizard.Xaml.IO.Task_ID.Text)]"
        }

        # CheckOSDComputerName()
        If ($Wizard.Xaml.IO.System_Name.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("Must designate a target computer name","Error")
        }
        Else
        {
            Switch -Regex ((Test-Connection $Wizard.Xaml.IO.System_Name.Text -Count 1 -EA 0).Address)
            {
                $Null
                { 
                    $Wizard.SetTSEnv("OSDComputerName",$Wizard.Xaml.IO.System_Name.Text)
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SystemName [+] [$($Wizard.Xaml.IO.System_Name.Text)]" 
                }
                
                Default 
                { 
                    Return [System.Windows.MessageBox]::Show("Designated ComputerName already exists","Error")
                }
            }
        }

        # CheckFinishAction()
        If ($Wizard.Xaml.IO.Misc_Finish_Action.SelectedIndex -ne -1)
        {
            Switch ($Wizard.Xaml.IO.Misc_Finish_Action.SelectedIndex)
            {
                0
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): FinishAction [+] [null]"
                }
                1 
                {
                    $Wizard.SetTSEnv("FinishAction","REBOOT")
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): FinishAction [+] [Reboot]"
                } 
                2 
                {
                    $Wizard.SetTSEnv("FinishAction","SHUTDOWN")
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): FinishAction [+] [Shutdown]"
                } 
                3 
                {
                    $Wizard.SetTSEnv("FinishAction","LOGOFF")
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): FinishAction [+] [Logoff]"
                }
            }
        }

        # CheckWSUSServer()
        If ($Wizard.Xaml.IO.Misc_WSUSServer.Text -ne "")
        {
            Try
            {
                Test-Connection $Wizard.Xaml.IO.Misc_WSUSServer.Text -Count 1 -EA 0
                $Wizard.SetTSEnv("WSUSServer", $Wizard.Xaml.IO.Misc_WSUSServer.Text)
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): WSUSServer [+] [$($Wizard.Xaml.IO.Misc_WSUSServer.Text)]"
            }
            Catch
            {
                $Wizard.SetTSEnv("WSUSServer", $Null)
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): WSUSServer [+] [null]"
            }
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): WSUSServer [+] [null]"
        }

        # Check_EventService()
        If ($Wizard.Xaml.IO.Misc_EventService.Text -ne "")
        {
            If ($Wizard.Xaml.IO.Misc_EventService.Text -ne $tsenv:EventService)
            {
                $Server = @( Switch -Regex ($Wizard.Xaml.IO.Misc_EventService.Text)
                {
                    "http[s]*://"
                    {
                        $Wizard.Xaml.IO.Misc_EventService.Text -Replace "http[s]*://", ""
                    }
                    Default
                    {
                        $Wizard.Xaml.IO.Misc_EventService.Text
                    }

                }).Split(":")[0]

                Try
                {
                    Test-Connection $Server -Count 1 -EA 0
                    $Wizard.SetTSEnv("EventService",$Wizard.Xaml.IO.Misc_EventService.Text)
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): EventService [+] [$($Wizard.Xaml.IO.Misc_EventService.Text)]"
                }
                Catch
                {
                    $Wizard.SetTSEnv("EventService",$Null)
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): EventService [+] [null]"
                }
            }
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): EventService [+] [null]"
        }

        # Check_SLShare()
        If ($Wizard.Xaml.IO.Misc_LogsSLShare_DynamicLogging.Text -ne "")
        {
            $Logging = $Wizard.Xaml.IO.Misc_LogsSLShare_DynamicLogging.Text
            Try 
            {
                Test-Path $Logging
                $Wizard.SetTSEnv("SLShareDynamicLogging",$Logging)
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SLShareDynamicLogging [+] [$Logging]"
            }
            Catch
            {
                $Wizard.SetTSEnv("SLShareDynamicLogging",$Null)
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SLShareDynamicLogging [+] [null]"
            }
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SLShareDynamicLogging [+] [null]"
        }

        # Check_SLShareDeployRoot()
        If ($Wizard.Xaml.IO.Misc_SLShare_DeployRoot.IsChecked -eq $True)
        {
            $Wizard.SetTSEnv("SLShare","%DeployRoot%\Logs\$tsenv:OSDComputerName")
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SLShare [+] [%DeployRoot%\Logs\$tsenv:OSDComputerName]"
        }
        Else
        {
            $Wizard.SetTSEnv("SLShare","%OSD_Logs_SLShare%")
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SLShare [+] [%OSD_Logs_SLShare%]"		
        }

        # Check_HideShell()
        If ($Wizard.Xaml.IO.Misc_HideShell.IsChecked -eq $True)
        {
            $Wizard.SetTSEnv("HideShell","YES")
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): HideShell [+] [YES]"
        }

        # Check_NoExtraPartition()
        If ($Wizard.Xaml.IO.Misc_NoExtraPartition.IsChecked -eq $True)
        {
            $Wizard.SetTSEnv("DoNotCreateExtraPartition","YES")
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DoNotCreateExtraPartition [+] [YES]"
        }	

        # Check_ProductKey()
        If ($Wizard.Xaml.IO.Misc_Product_Key_Type.SelectedIndex -gt 0)
        {
            1 
            { 
                $Key = $Wizard.Xaml.IO.Misc_Product_Key.Text -Replace "-",""
                If ($Key -match "((\w|\d){25}")
                {
                    $Wizard.SetTSEnv("ProductKey",$Key) 
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): ProductKey [+] [$Key]"
                }
            }
            2 
            {  
                $Key = $Wizard.Xaml.IO.Misc_Product_Key.Text -Replace "-",""
                If ($Key -match "((\w|\d){25}")
                {
                    $Wizard.SetTSEnv("OverrideProductKey",$Key) 
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): OverrideProductKey [+] [$Key]"
                }
            }
        }

        $Wizard.Xaml.IO.DialogResult = $True
    })
    
    $Wizard.Xaml.IO.Cancel.Add_Click(
    {
        $Wizard.Xaml.IO.DialogResult = $False
    })

    Return $Wizard
}

Export-ModuleMember -Function Show-PSDWizard, Show-FEWizard
