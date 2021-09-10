Function Resolve-LogAddressList
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$LogPath)

    If (!(Test-Path $LogPath))
    {
        Throw "Invalid path"
    }

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
    
    # ( Get-Content $home\Desktop\LogAddressList.xaml ).Replace("'",'"') | % { "        '$_'," } | Set-Clipboard
    Class LogAddressListGUI
    {
        Static [String] $Tab = @(        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Log Address List" Width="800" Height="480" Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="CanResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="BorderBrush" Value="DarkBlue"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="HorizontalAlignment" Value="Center"/>',
        '            <Setter Property="AutoGenerateColumns" Value="False"/>',
        '            <Setter Property="AlternationCount" Value="2"/>',
        '            <Setter Property="HeadersVisibility" Value="Column"/>',
        '            <Setter Property="CanUserResizeRows" Value="False"/>',
        '            <Setter Property="CanUserAddRows" Value="False"/>',
        '            <Setter Property="IsTabStop" Value="True" />',
        '            <Setter Property="IsTextSearchEnabled" Value="True"/>',
        '            <Setter Property="IsReadOnly" Value="True"/>',
        '            <Setter Property="TextBlock.HorizontalAlignment" Value="Left"/>',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="TextBlock.HorizontalAlignment" Value="Left"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" Value="0">',
        '                    <Setter Property="Background" Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" Value="Azure"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '        </Style>',
        '        <Style TargetType="DataGridCell">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <GroupBox Header="[Address List]">',
        '            <DataGrid Name="AddressList">',
        '                <DataGrid.Columns>',
        '                    <DataGridTextColumn Header="Index"   Binding="{Binding Index}"  Width="60"/>',
        '                    <DataGridTextColumn Header="Date"    Binding="{Binding Date}"   Width="100"/>',
        '                    <DataGridTextColumn Header="Time"    Binding="{Binding Time}"   Width="100"/>',
        '                    <DataGridTextColumn Header="Type"    Binding="{Binding Type}"   Width="100"/>',
        '                    <DataGridTextColumn Header="IP"      Binding="{Binding IP}"     Width="120"/>',
        '                    <DataGridTextColumn Header="Status"  Binding="{Binding Status}" Width="40"/>',
        '                    <DataGridTextColumn Header="Name"    Binding="{Binding Name}"   Width="150"/>',
        '                    <DataGridTextColumn Header="Tag"     Binding="{Binding Tag}"    Width="100"/>',
        '                    <DataGridTextColumn Header="Org"     Binding="{Binding Org}"    Width="300"/>',
        '                    <DataGridTextColumn Header="City"    Binding="{Binding City}"   Width="100"/>',
        '                </DataGrid.Columns>',
        '            </DataGrid>',
        '        </GroupBox>',
        '    </Grid>',
        '</Window>')
    }

    Class LogType
    {
        Hidden [Object] $Line
        [UInt32] $Index
        [Object] $Date
        [Object] $Time
        [Object] $Type
        [String] $Message
        [Object] $IP
        [Object] $Whois
        LogType([UInt32]$Index,[String]$Line)
        {
            $This.Line    = $Line -Split "\t"
            $This.Index   = $Index
            $This.Date    = $This.Line[0].Split("T")[0]
            $This.Time    = $This.Line[0].Split("T")[1]
            $This.Type    = $This.Line[1]
            $This.Message = $This.Line[2]
            $This.IP      = [Regex]::Matches($This.Message,"(\d+\.){3}\d+").Value
        }
    }

    Class IPResult
    {
        Hidden [Object] $Object
        [String] $IPAddress
        [String] $Status
        [String] $Name
        [String] $Tag
        [String] $Org
        [String] $City
        [String] $Date
        [String] $Time
        [String] $Offset
        IPResult([Object]$IPAddress)
        {
            $Obj                = Invoke-RestMethod "http://whois.arin.net/rest/ip/$Ipaddress" -Headers @{ Accept = "application/xml" } -EA 0
            $This.Object        = $Obj

            If ($Obj -ne $Null)
            {
                $Obj.Net         | % {

                    $This.IPAddress = $IPAddress
                    $This.Status    = "+"
                    $This.Name      = $_.Name
                    $This.Tag       = $_.OrgRef.Handle
                    $This.Org       = $_.OrgRef.Name
                    $This.Date      = $_.Updatedate.Split("T")[0]
                    $This.Time      = $_.UpdateDate.Split("T")[1]
                    $This.Offset    = $This.Time.Split("-")[1]
                }
            }

            If ($Obj -eq $Null)
            {
                $This.IPAddress     = $IPAddress
                $This.Status        = "-"
            }
        }
    }

    Class LogLine
    {
        [UInt32]$Index
        [String]$Date
        [String]$Time
        [String]$Type
        [String]$IP
        [String]$Status
        [String]$Name
        [String]$Tag
        [String]$Org
        [String]$City
        LogLine([Object]$Line)
        {
            $This.Index  = $Line.Index
            $This.Date   = $Line.Date
            $This.Time   = $Line.Time
            $This.Type   = $Line.Type
            $This.IP     = $Line.IP
            $Obj         = $Line.Whois
            $This.Status = $Obj.Status
            $This.Name   = $Obj.Name
            $This.Tag    = $Obj.Tag
            $This.Org    = $Obj.Org
            $This.City   = $Obj.City
        }
    }

    Class SystemLog
    {
        Hidden [Object] $Content
        [UInt32] $Count
        [Object] $Stack
        [Object] $IPList
        [Object] $Swap
        [Object] $Output
        SystemLog([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            $This.Content    = Get-Content $Path
            $This.Count      = $This.Content.Count
            $This.Stack      = @{ } 
            
            ForEach ( $X in 0..($This.Count-1))
            {
                $This.Stack.Add($X,[LogType]::New($X,$This.Content[$X])) 
            }

            $This.IPList     = $This.Stack[0..($This.Stack.Count-1)].IP | Select-Object -Unique

            $Ct              = $This.IPList.Count
            $This.Swap       = @{ }

            Write-Progress -Activity "Processing [~] system.log" -Status "Scanning -> (0/$Ct)" -PercentComplete 0
        
            ForEach ( $X in 0..($This.IPList.Count-1))
            {
                $IP          = $This.IPList[$X]
                Write-Progress -Activity "Processing [~] system.log" -Status "Scanning -> ($X/$Ct)" -PercentComplete (($X*100)/$Ct)

                $Obj         = [IPResult]$IP
                $Obj.Object.Net.OrgRef | ? '#text' | % { $Obj.City =  (Invoke-RestMethod $_.'#text' -EA 0).org.city }

                $This.Swap.Add($IP,$Obj)
            }

            Write-Progress -Activity "Processing [~] system.log" -Status "Complete" -Completed

            ForEach ($X in 0..($This.Stack.Count-1))
            {
                $This.Stack[$X].Whois = $This.Swap["$($This.Stack[$X].IP)"]
            }

            $Log = $This.Stack[0..($This.Stack.Count-1)] | % { [LogLine]$_ }

            $Y   = 0

            ForEach ( $X in ($Log.Count-1)..0 )
            {
                $Log[$X].Index = $Y
                $Y ++
            }

            $This.Output = $Log[($Log.Count-1)..0]
        }
    }

    $Log = ([SystemLog]$LogPath).Output

    $Xaml = [XamlWindow][LogAddressListGUI]::Tab

    $Xaml.IO.AddressList.ItemsSource = @( $Log )

    $Xaml.Invoke()
}
