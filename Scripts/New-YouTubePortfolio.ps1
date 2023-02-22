Function New-YouTubePortfolio
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory,Position=0)][String]$Name,
        [Parameter(Mandatory,Position=1)][String]$Company
    )

    Class DrawLine
    {
        [String] $Rank
        [String] $Line
        DrawLine([UInt32]$Rank,[String]$Line)
        {
            $This.Rank = $Rank
            $This.Line = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    Class DrawColumn
    {
        [UInt32]   $Index
        [String]    $Name
        [UInt32]   $Width
        [Object] $Content
        DrawColumn([UInt32]$Index,[String]$Name)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Width   = $Name.Length
            $This.Content = @( )
        }
        [Object] DrawLine([UInt32]$Rank,[String]$Line)
        {
            Return [DrawLine]::New($Rank,$Line)
        }
        Add([String]$Line)
        {
            If ($Line.Length -gt $This.Width)
            {
                $This.Width = $Line.Length
            }

            $This.Content += $This.DrawLine($This.Content.Count,$Line)
        }
    }

    Class DrawRow
    {
        [UInt32]         $Depth
        [UInt32]        $Height
        [Object]        $Output
        DrawRow([Object]$Object,[String[]]$Names)
        {
            $This.Output = @( )

            # Properties/Values
            ForEach ($Name in $Names)
            {
                $This.AddProperty($Name)
                $Slot = $This.Output | ? Name -eq $Name
                ForEach ($Item in $Object.$Name)
                {
                    $Slot.Add($Item)
                }
            }

            $This.Height = $This.Output[0].Content.Count
        }
        [Object] DrawColumn([UInt32]$Rank,[String]$Content)
        {
            Return [DrawColumn]::New($Rank,$Content)
        }
        AddProperty([String]$Name)
        {
            $This.Output += $This.DrawColumn($This.Output.Count,$Name)
            $This.Depth   = $This.Output.Count
        }
        [String[]] Draw([UInt32]$Index)
        {
            $H            = @{

                Content   = $This.Output.Content | ? Rank -eq $Index | % Line
                Width     = $This.Output.Width
                Name      = $This.Output.Name
            }

            $Hash         = @{ 0 = @( ); 1 = @( ); 2 = @( ) }

            ForEach ($X in 0..($This.Depth-1))
            {
                $Hash[0] += "{0}" -f $H.Name[$X].PadRight($H.Width[$X]," ")
                $Hash[1] += "{0}" -f "-".PadRight($H.Width[$X],"-")
                $Hash[2] += "{0}" -f $H.Content[$X].PadRight($H.Width[$X]," ")
            }

            $Out         = @( )
            $Out        += "| {0} |" -f ($Hash[0] -join " | ")
            $Out        += ("|-{0}-|" -f ($Hash[1] -join "-|-")).Replace("|-","|:")
            $Out        += "| {0} |" -f ($Hash[2] -join " | ")

            Return $Out
        }
        [String[]] DrawAll()
        {
            $Swap = @( )
            ForEach ($X in 0..($This.Height-1))
            {
                $This.Draw($X) | % { $Swap += $_ }
            }

            $Out  = @( )
            ForEach ($Line in $Swap)
            {
                If ($Line -notin $Out)
                {
                    $Out += $Line
                }
            }

            Return $Out
        }
    }

    # // =================================
    # // | Single video with information |
    # // =================================

    Class VideoItem
    {
        [UInt32]  $Index
        [String]   $Date
        [TimeSpan] $Time
        [String]    $Url
        [String]   $Name
        VideoItem([UInt32]$Index,[String]$Date,[String]$Time,[String]$Hash,[String]$Name)
        {
            $This.Index = $Index
            $This.Date  = ([DateTime]$Date).ToString("MM-dd-yyyy")
            $This.Time  = Switch -Regex ($Time)
            {
                ^\d+\:\d+$
                {
                    "00:$Time"
                }
                Default
                {
                    $Time
                }
            }

            $This.Url   = Switch -Regex ($Hash)
            {
                ^https\:\/\/youtu\.be\/.+
                {
                    $Hash
                }
                Default
                {
                    "https://youtu.be/{0}" -f $Hash
                }
            }

            $This.Name  = $Name
        }
    }

    Class VideoString
    {
        [String] $Index
        [String]  $Date
        [String]  $Time
        [String]  $Name
        VideoString([Object]$Video)
        {
            $This.Index = $Video.Index
            $This.Date  = "``{0}``" -f $Video.Date
            $This.Time  = "``{0}``" -f $Video.Time
            $This.Name  = "[[{0}]({1})]" -f $Video.Name, $Video.Url
        }
    }

    # // ============================================
    # // | Enumeration type for individual accounts |
    # // ============================================

    Enum ChannelType
    {
        securedigitsplusllc3084
        michaelcook7389
        mykalcook
        securedigitsplus2892
    }

    # // =============================
    # // | Single individual account |
    # // =============================

    Class ChannelItem
    {
        [UInt32]  $Index
        [String]   $Name
        [String]  $Email
        [String]     $Id
        [TimeSpan] $Time
        [UInt32]  $Total
        [Object]  $Video
        ChannelItem([String]$Name,[String]$Email,[String]$Id)
        {
            $This.Index  = [UInt32][ChannelType]::$Id
            $This.Name   = $Name
            $This.Email  = $Email
            $This.Id     = $Id
            $This.Clear()
        }
        Clear()
        {
            $This.Time   = [TimeSpan]::FromSeconds(0)
            $This.Video  = @( )
            $This.Total  = 0
        }
        [Object] VideoItem([UInt32]$Index,[String]$Date,[String]$Length,[String]$Hash,[String]$Name)
        {
            Return [VideoItem]::New($Index,$Date,$Length,$Hash,$Name)
        }
        Add([String]$Date,[String]$Length,[String]$Hash,[String]$Name)
        {
            $This.Video += $This.VideoItem($This.Total,$Date,$Length,$Hash,$Name)
            $This.Total  = $This.Video.Count
            $This.Time   = $This.Time + $This.Video[-1].Time
        }
        [String] ToString()
        {
            Return $This.Id
        }
    }

    Class ChannelString
    {
        [String] $Index
        [String] $Name
        [String] $Email
        [String] $Id
        [String] $Time
        [String] $Total
        ChannelString([Object]$Channel)
        {
            $This.Index  = $Channel.Index
            $This.Name   = "**{0}**" -f $Channel.Name
            $This.Email  = "[{0}]" -f $Channel.Email
            $This.Id     = "[[{0}](https://www.youtube.com/@{0})]" -f $Channel.Id
            $This.Time   = $Channel.Time
            $This.Total  = $Channel.Total
        }
    }

    # // =====================================
    # // | Container object for all channels |
    # // =====================================

    Class Portfolio
    {
        [String]     $Name
        [String]  $Company
        [TimeSpan]   $Time
        [UInt32]    $Total
        [Object]  $Channel
        Portfolio([String]$Name,[String]$Company)
        {
            $This.Name    = $Name
            $This.Company = $Company
            $This.Clear()
        }
        Clear()
        {
            $This.Channel = @( )
            $This.Total   = 0
            $This.Time    = [TimeSpan]::FromSeconds(0)
        }
        [Object] ChannelItem([String]$Name,[String]$Email,[String]$Id)
        {
            Return [ChannelItem]::New($Name,$Email,$Id)
        }
        [Object] ChannelString([Object]$Channel)
        {
            Return [ChannelString]::New($Channel)
        }
        [Object] VideoString([Object]$Video)
        {
            Return [VideoString]::New($Video)
        }
        [Object] DrawRow([Object]$Object,[String[]]$Property)
        {
            Return [DrawRow]::New($Object,$Property)
        }
        [Object] ChannelRow([UInt32]$Index)
        {
            $Object = $This.ChannelString($This.Channel[$Index])
            $Names  = "Index","Name","Email","Id","Time","Total"
            Return [DrawRow]::New($Object,$Names).Draw(0)
        }
        [Object] VideoRow([UInt32]$Index)
        {
            $Object = $This.Channel[$Index].Video | % { $This.VideoString($_) }
            $Names  = "Index","Date","Time","Name" 
            Return [DrawRow]::New($Object,$Names).DrawAll()
        }
        Add([String]$Name,[String]$Email,[String]$Id)
        {
            $This.Channel += $This.ChannelItem($Name,$Email,$Id)
            $This.Total    = $This.Channel.Count
            Write-Host "Added [+] [$Name/$Email] : $Id"
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Total)
            {
                Throw "Invalid index"
            }

            Return $This.Channel[$Index]
        }
        AddVideo([UInt32]$Index,[String]$Date,[String]$Time,[String]$Hash,[String]$Name)
        {
            $xChannel    = $This.Get($Index)
            $xChannel.Add($Date,$Time,$Hash,$Name)
            $xTime       = $xChannel.Video[-1].Time
            $This.Time   = $This.Time + $xTime
            Write-Host ("Added [+] [{0}] [{1}]" -f $xTime, $Name)
        }
    }

    [Portfolio]::New($Name,$Company)
}
