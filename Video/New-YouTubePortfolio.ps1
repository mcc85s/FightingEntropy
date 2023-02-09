
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
        [String]     $Name
        [TimeSpan] $Length
        [String]      $Url
        VideoItem([UInt32]$Index,[String]$Date,[String]$Name,[String]$Length,[String]$Hash)
        {
            $This.Index   = $Index
            $This.Date    = ([DateTime]$Date).ToString("MM-dd-yyyy")
            $This.Name    = $Name
            $This.Length  = Switch -Regex ($Length)
            {
                ^\d+\:\d+$
                {
                    "00:$Length"
                }
                Default
                {
                    $Length
                }
            }

            $This.Url     = Switch -Regex ($Hash)
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
        [String] $DisplayName
        [TimeSpan]    $Length
        [Object]       $Video
        [UInt32]       $Count
        ChannelItem([String]$Name,[String]$DisplayName)
        {
            $This.Index       = [UInt32][ChannelType]::$Name
            $This.Name        = $Name
            $This.DisplayName = $DisplayName
            $This.Clear()
        }
        Clear()
        {
            $This.Length      = [TimeSpan]::FromSeconds(0)
            $This.Video       = @( )
            $This.Count       = 0
        }
        [Object] VideoItem([UInt32]$Index,[String]$Date,[String]$Name,[String]$Length,[String]$Hash)
        {
            Return [VideoItem]::New($Index,$Date,$Name,$Length,$Hash)
        }
        Add([String]$Date,[String]$Name,[String]$Length,[String]$Hash)
        {
            $This.Video      += $This.VideoItem($This.Count,$Date,$Name,$Length,$Hash)
            $This.Count       = $This.Video.Count
            $This.Length      = $This.Length + $This.Video[-1].Length
        }
        [String] ToString()
        {
            Return $This.DisplayName
        }
    }

    Class Portfolio
    {
        [String]    $Name
        [String] $Company
        [UInt32]   $Count
        [Object] $Channel
        Portfolio([String]$Name,[String]$Company)
        {
            $This.Name    = $Name
            $This.Company = $Company
            $This.Clear()
        }
        Clear()
        {
            $This.Channel = @( )
            $This.Count   = 0
        }
        [Object] ChannelItem([String]$Name,[String]$DisplayName)
        {
            Return [ChannelItem]::New($Name,$DisplayName)
        }
        Add([String]$Name,[String]$DisplayName)
        {
            $This.Channel += $This.ChannelItem($Name,$DisplayName)
            $This.Count    = $This.Channel.Count
            Write-Host "Added [+] [$Name] : $DisplayName"
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Channel[$Index]
        }
        AddVideo([UInt32]$Index,[String]$Date,[String]$Name,[String]$Length,[String]$Hash)
        {
            $xChannel = $This.Get($Index)
            $xChannel.Add($Date,$Name,$Length,$Hash)

            Write-Host ("Added [+] [{0}] [{1}]" -f $xChannel.Video[-1].Length, $Name)
        }
    }

    [Portfolio]::New($Name,$Company)
}
