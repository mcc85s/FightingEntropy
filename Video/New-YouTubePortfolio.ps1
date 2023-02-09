Function New-YouTubePortfolio
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory,Position=0)][String]$Name,
        [Parameter(Mandatory,Position=1)][String]$Company
    )

    Class VideoItem
    {
        [UInt32]    $Index
        [String]     $Date
        [TimeSpan]   $Time
        [String]      $Url
        [String]     $Name
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

    Enum ChannelType
    {
        securedigitsplusllc3084
        michaelcook7389
        mykalcook
        securedigitsplus2892
    }

    Class ChannelItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Email
        [String]          $Id
        [TimeSpan]      $Time
        [UInt32]       $Total
        [Object]       $Video
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
