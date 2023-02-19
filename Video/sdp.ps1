
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

$Ctrl = New-YouTubePortfolio -Name "Michael C. Cook Sr." -Company "Secure Digits Plus LLC"

("Secure Digits Plus LLC","securedigitsplus@gmail.com","securedigitsplusllc3084"),
("Michael C. Cook","michael.c.cook.85@gmail.com","michaelcook7389"),
("Michael Cook","mykalcook@gmail.com","mykalcook"),
("Secure Digits Plus","sdp12065@gmail.com","securedigitsplus2892") | % { 

    $Ctrl.Add($_[0],$_[1],$_[2])
}

# 0 / [Secure Digits Plus LLC (securedigitsplusllc3084)]
("02-19-2023","01:51:25","u3y4NHD_svUz","Russia - Crushing Defeat")
("02-18-2023","01:28:24","CPJmWpzEDBE","Wrongful Robert"),
("02-17-2023","00:11:53","1s-qefkOjXQ","Malta Tech Park"),
("02-15-2023","04:41:01","p4MPjtd2vpw","Halfmoon Historic"),
("02-14-2023","00:44:09","Ev97ifWx-L8","Hive Mentality"),
("02-13-2023","02:12:00","MI2imvb-4Vg","Invoke-Cimdb"),
("02-12-2023","00:38:09","ENpIkuIbqZU","NYSP Mafiosos"),
("02-11-2023","00:20:17","SGKypOeZuX4","Build-Discography"),
("02-10-2023","00:06:24","Ua1r_7o5BpI","Weeping Angel"),
("02-10-2023","00:06:40","4V6Wwzxlqzw","Track 20 (Original Music)"),
("02-10-2023","00:06:31","23d9VPFr0u4","Futile Intent (Original Music)"),
("02-09-2023","01:14:32","sqSMw4JzQoM","New-YouTubeProfile"),
("02-07-2023","00:17:25","zIDnV1BsiCA","rastructure"),
("02-07-2023","01:59:05","Dj9E-eNe4Tg","Golub Corp. - Empire State Plaza"),
("02-04-2023","00:27:53","aejBB77d_oA","Why William Moak is stupid"),
("02-04-2023","03:04:48","j58BO1p_EJ8","Write-Element (Demonstration)"),
("02-01-2023","02:01:57","nqTOmNIilxw","New-VmController [Flight Test v2.0] Part I"),
("01-12-2023","01:14:43","9v7uJHF-cGQ","PowerShell | Virtualization Lab + FEDCPromo"),
("11-22-2022","01:15:56","Y7wEiuNJhN0","Search-WirelessNetwork"),
("10-28-2022","01:22:26","S7k4lZdPE-I","[FightingEntropy()][2022.10.1]"),
("10-15-2022","00:13:33","-GScIS_PlOo","Intellectual Property Theft"),
("10-14-2022","00:15:03","ZiTVgtg68Jc","Indicative Behaviors"),
("10-04-2022","00:00:20","dU_5rdVkCD8","God Mode Cursor"),
("10-03-2022","00:31:32","xhMQbOoDvOc","Behavioral Analysis"),
("09-29-2022","00:02:15","K738wZSKcjo","Write Progress Extension"),
("09-26-2022","00:01:12","tW80Zj_H6Fw","God Mode Cursor"),
("09-27-2022","00:57:04","1ABQ6rfRg8Y","Correlations"),
("09-08-2022","02:11:03","z6_GeVYbcC4","Developing a GUI with style"),
("08-11-2022","00:05:18","QSuge7p5_I8","PowerShell Resume"),
("08-03-2022","00:08:43","vY2fIhS9ruo","Scribbles locking ANY word editor"),
("04-15-2022","09:52:39","CCOTI6_Veoo","Event Logs Utility (Work in progress)"),
("04-05-2022","00:05:18","35EabWfh8dQ","Wireless Network Scanner Utility (PowerShell/Xaml)"),
("02-15-2022","00:20:27","e4VnZObiez8","A Matter of National Security"),
("12-05-2021","01:49:57","6yQr06_rA4I","[FightingEntropy(π)] FEInfrastructure Preview/Demo"),
("10-25-2021","01:56:00","1E-3POI29Jo","Ambitious Automation"),
("10-14-2021","00:38:23","4q3fWhTOuFk","DCPromo and Networking"),
("10-14-2021","00:09:32","AdAilZe1EJ4","FEInfrastructure (Alpha/Beta)"),
("10-02-2021","02:43:44","vbAH4l6Bm7A","Cross Platform Development"),
("09-23-2021","00:08:17","lZX5fAgczz0","[FightingEntropy(π)]://FEWizard PowerShell Deployment feat. DVR"),
("09-16-2021","04:05:38","m84TElKgAFg","PowerShell Deployment Wizard (featuring DVR) [WIP]"),
("09-10-2021","00:12:25","_i2bPQT1ZtU","Resolve-LogAddressList"),
("05-23-2020","01:35:44","HT4p28bRhqc","Virtual Tour"),
("01-25-2019","00:32:39","5Cyp3pqIMRs","Computer Answers - MDT") | % {

    $Ctrl.AddVideo(0,$_[0],$_[1],$_[2],$_[3])
}

# 1 / [Michael C. Cook (michaelcook7389)]
("06-29-2022","00:00:19","W0SZ9Iby3VY","SCSO and NYSP trying to be sneaky"),
("08-30-2021","02:33:21","vg359UlYVp8","FEDeploymentShare Part 2"),
("08-11-2021","00:10:44","70NJcRFTZo8","New-FEDeploymentShare"),
("07-26-2021","00:38:48","eaAyCJ7zsZw","FEDeploymentShare (Part 1)"),
("07-26-2021","01:13:13","jmvzDV4RCQY","2021 07 26 12 24 59"),
("06-06-2021","01:17:43","9zjQqQ0sKPg","[FightingEntropy(π)][(2021.6.0)]@[FEModule GUI (Part 2)]"),
("06-06-2021","02:42:22","Zc8Fq4E3Nc0","[FightingEntropy(π)][(2021.6.0)]@[FEModule GUI (Part 1)]"),
("03-09-2021","00:57:16","NK4NuQrraCI","A Deep Dive: Demonstration - Building XAML/WPF via PowerShell"),
("02-15-2021","00:53:26","45U1qFlU_74","FightingEntropy (π) Testing..."),
("12-13-2020","00:02:15","SmsqBv200B8","About 'My Briefcase' from (Windows 95/98)"),
("12-12-2020","01:05:26","51Ymdd9XqQ","PowerShell XAML/WPF Classes"),
("11-07-2020","00:11:40","RZ1SEUwSb9Q","FightingEntropy - New Deployment Share GUI"),
("11-05-2020","00:06:45","KI0-V5OGy5w","FightingEntropy - (Windows Image Extraction)"),
("10-14-2020","00:21:57","MRcLWQCJwt4","Drafting and Design meets Programming"),
("09-30-2020","00:15:11","bOpZIeQF5KQ","NMap Vendor List"),
("09-16-2020","00:16:00","dBpfRazxAi0","Write-Theme (Update/[FEObject])"),
("09-05-2020","01:25:34","6SubeX4gvD0","(Cruise Control) 2/2"),
("09-05-2020","00:56:36","afLnNLdG2PU","(Cruise Control) 1/2"),
("09-03-2020","00:11:05","nFijaWGytnA","FightingEntropy [FEModule/FERoot]"),
("08-13-2020","00:10:17","QGtzvsGSUak","Write-Theme & Show-ToastNotification (Source Code/Lesson Plan/Resume in desc.)"),
("08-09-2020","00:32:35","EQXRrPQ-iOw","PowerShell/C# Classes"),
("05-21-2020","00:29:25","hbBVNerI_Qk","Service Configuration Tool"),
("11-28-2019","00:43:48","bZuSgBK36CE","Some Powershell scripting/programming methodologies"),
("08-28-2019","01:47:16","v6RrrzR5v2E","Education/Exhibition of Programming/Design/Engineering with Powershell/C#/.Net"),
("05-28-2019","01:02:43","C8NYaaqJAlI","Hybrid | Desired State Controller | Process Exhibition (The long version)"),
("03-24-2019","00:47:24","qiZcHqkAzbs","Hybrid(Server+Client)"),
("08-19-2018","00:02:00","bPdWt7kcd3M","News 10 - Smart TV report"),
("01-16-2018","00:23:55","pi1DIQWuce8","Driving in Snow (feat. Audi A4 Quattro)") | % { 

    $Ctrl.AddVideo(1,$_[0],$_[1],$_[2],$_[3])
}

# 2 / [Michael Cook (mykalcook)]
("08-13-2022","00:41:08","eD0-VQ2y_yg","2018_1220-(OPNsense Configuration)"),
("09-08-2021","00:05:52","vA8_HLZ--mQ","cimdb2"),
("06-05-2021","00:05:16","xN53K9oGCME","[Q3A] 20KDM2 - Return to Castle: Quake (2002)"),
("06-05-2021","00:10:33","dyHwm9AdkQs","[Q3A] 20KDM1 - Tempered Graveyard (2001)"),
("06-05-2021","00:16:16","rwyHCNnwlkM","[Q3A] 20KCTF1 - Out Of My Head (2002)"),
("06-05-2021","00:11:25","EG8UyJSMK3Y","[Q3A] 20KDM3 - Insane Products (2005)"),
("02-17-2021","00:01:02","ApEqOjAoAfM","2017_0831-(Threadripper Gen1)"),
("10-23-2020","01:08:20","iOKOkJJ1ZbQ","CentOS 7 Setup"),
("10-20-2020","00:56:33","YDWm-f7WEWs","2019_1004-AsusQ504UA301(tilted)"),
("10-20-2020","00:41:08","eYEESvPOWh4","Configuring pfSense/Hardened BSD"),
("10-20-2020","00:01:38","0nEiGijjOEY","Network Troubleshooting"),
("10-20-2020","00:03:34","LfZW-s0BMow","Spectrum Cable Modem Reset"),
("05-16-2019","00:41:01","jplOHy_b1bA","Secure Digits Plus LLC @ Hybrid | Desired State Controller ( Beta Preview )"),
("03-02-2019","01:01:30","RypW9xbClJo","2019 03 01 23 35 05"),
("07-28-2018","00:09:55","joioy6bIyPE","Trickshot - Wicked") | % {

    $Ctrl.AddVideo(2,$_[0],$_[1],$_[2],$_[3])
}

# 3 / [Secure Digits Plus (sdp12065)]
("10-20-2021","00:17:10","O8A2PDfQOBs","[FightingEntropy]://Domain Controller Promotion"),
("06-30-2021","00:10:09","G10EuwlNAyo","PowerShell - (Xaml/WPF GUI) Windows Image Extraction"),
("06-27-2021","00:40:28","xgffIccX1eg","PowerShell - Advanced System Administration Lab"),
("06-20-2021","00:10:03","E_uFbzS0blQ","Install-pfSense (Auto)"),
("06-06-2021","00:03:58","acYldTcKUAs","[FightingEntropy(π)][(2021.6.0)] Installation + FEModule GUI"),
("06-04-2021","00:07:05","UYnCj5Hcq6o","[FightingEntropy(π)][(2021.6.0)]"),
("03-16-2021","01:38:47","4yFKeK9CzU0","FightingEntropy (π) v2021.3.1 | New-FEDeploymentShare GUI") | % { 

    $Ctrl.AddVideo(3,$_[0],$_[1],$_[2],$_[3])
}
