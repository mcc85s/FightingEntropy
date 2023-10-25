<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-10-24 23:27:39                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PsdNtpTime.ps1
    Solution   : [FightingEntropy()][2023.8.0]
    Purpose    : Obtains time information from NTP (for PSD deployment, or more)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-10-24
    Modified   : 2023-10-24
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

    Notes      : Unable to access the code on either of these links: 
    
    1) https://gallery.technet.microsoft.com/scriptcenter/Get-Network-NTP-Time-with-07b216ca
    2) https://www.mathewjbray.com/powershell/powershell-get-ntp-time/
    
    Anyway, the source code is from lines 1235-1473, function (Get-PsdNtpTime).

    /¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    \ Date       | Name               | Link                                                                       /
    / 09/19/2022 | PSDUtility.psm1    | https://github.com/FriendsOfMDT/PSD/blob/master/Scripts/PSDUtility.psm1    \
    \____________|____________________|____________________________________________________________________________/

    I used a few classes to provide more [flexibility] and [control], eventually this will have a new logging
    strategy for the whole PSD module manifest suite, and it will be part of:
    
    /¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    \ Date       | Name               | Link                                                                       /
    / 11/08/2022 | PSDController.psm1 | https://github.com/mcc85s/FightingEntropy/blob/main/PSD/PSDController.psm1 \
    \____________|____________________|____________________________________________________________________________/

    [Ntp Packet Reference Info]
    00 28  | Version Numer
    01 2   | Stratum
    02 1   | Poll Interval
    03 231 | Precision Bits
    04 0   | Root Delay
    05 0   | Root Delay
    06 5   | Root Delay
    07 59  | Root Delay
    08 0   | Root Dispersion
    09 0   | Root Dispersion
    10 0   | Root Dispersion
    11 43  | Root Dispersion
    12 130 | Reference Identifier
    13 207 | Reference Identifier
    14 244 | Reference Identifier
    15 240 | Reference Identifier
    16 232
    17 226
    18 237
    19 0
    20 211
    21 252
    22 43
    23 202
    24 0
    25 0
    26 0
    27 0
    28 0
    29 0
    30 0
    31 0
    32 232 | Int T2
    33 226 | Int T2
    34 239 | Int T2
    35 72  | Int T2
    36 30  | Frac T2
    37 184 | Frac T2
    38 110 | Frac T2
    39 95  | Frac T2
    40 232 | Int T3
    41 226 | Int T3
    42 239 | Int T3
    43 72  | Int T3
    44 30  | Frac T3
    45 188 | Frac T3
    46 255 | Frac T3
    47 232 | Frac T3
#>

Class NtpTimeObject
{
    [String]                $Server
    [DateTime]                $Time
    [Double]                $Offset
    [Double]         $OffsetSeconds
    [Double]                 $Delay
    [Double]                  $T1ms
    [Double]                  $T2ms
    [Double]                  $T3ms
    [Double]                  $T4ms
    [DateTime]                  $T1
    [DateTime]                  $T2
    [DateTime]                  $T3
    [DateTime]                  $T4
    [Object]                    $LI
    Hidden [String]        $LI_text
    [UInt32]               $Version
    [UInt32]                  $Mode
    Hidden [String]      $Mode_text
    [UInt16]               $Stratum
    Hidden [String]   $Stratum_text
    [Byte]         $PollIntervalRaw
    [TimeSpan] $PollIntervalSeconds
    [Int32]              $Precision
    [Double]      $PrecisionSeconds
    [String]   $ReferenceIdentifier
    [Double]             $RootDelay
    [Double]        $RootDispersion
    [Byte[]]                   $Raw
    NtpTimeObject([Object]$Control,[Double]$T1,[Double]$T2,[Double]$T3,[Double]$T4,[Double]$Offset,[Double]$Delay)
    {
        $This.Server              = $Control.Server
        $This.Time                = $Control.Origin.AddMilliseconds($T4 + $Offset).ToLocalTime()
        $This.Offset              = $Offset
        $This.OffsetSeconds       = [Math]::Round($Offset/1000, 3)
        $This.Delay               = $Delay
        $This.T1ms                = $T1
        $This.T2ms                = $T2
        $This.T3ms                = $T3
        $This.T4ms                = $T4
        $This.T1                  = $Control.Origin.AddMilliseconds($T1).ToLocalTime()
        $This.T2                  = $Control.Origin.AddMilliseconds($T2).ToLocalTime()
        $This.T3                  = $Control.Origin.AddMilliseconds($T3).ToLocalTime()
        $This.T4                  = $Control.Origin.AddMilliseconds($T4).ToLocalTime()
        $This.Raw                 = $Control.Data
    }
    [String] ToString()
    {
        Return "<NtpTime.Object>"
    }
}

Class NtpTimeOutput
{
    [String]    $Server
    [DateTime]    $Time
    [Double]    $Offset
    [UInt32]   $Version
    [String]      $Mode
    [UInt16]   $Stratum
    [String] $Reference
    NtpTimeOutput([Object]$Object)
    {
        $This.Server    = $Object.Server
        $This.Time      = $Object.Time
        $This.Offset    = $Object.Offset
        $This.Version   = $Object.Version
        $This.Mode      = $Object.Mode_Text
        $This.Stratum   = $Object.Stratum
        $This.Reference = $Object.ReferenceIdentifier
    }
    [String] ToString()
    {
        Return "<NtpTime.Output>"
    }
}

Class NtpTimeController
{
    [String]   $Server
    [DateTime] $Origin
    [Byte[]]     $Data
    [Object]   $Socket
    [Object]   $Object
    NtpTimeController([String]$Server)
    {
        $This.Server = $Server
        $This.SetOrigin()
        $This.SetData()
        $This.SetSocket()
    }
    SetOrigin()
    {
        $This.Origin = [DateTime]::New(599266080000000000,"Utc")
    }
    SetData()
    {
        $This.Data    = [Byte[]]::New(48)
        $This.Data[0] = 27
    }
    [Object] TimeConvert([UInt32[]]$Bits)
    {
        Return [BitConverter]::ToUInt32($Bits,0)
    }
    [Object] TimeTranslate([UInt32[]]$Data1,[UInt32[]]$Data2)
    {
        Return $This.TimeConvert($Data1) * 1000 + ($This.TimeConvert($Data2) * 1000 / 0x100000000)
    }
    [Object] TimeMilliseconds([DateTime]$Time)
    {
        Return ([TimeZoneInfo]::ConvertTimeToUtc($Time) - $This.Origin).TotalMilliseconds
    }
    [Object] NtpTimeObject([Double]$T1,[Double]$T2,[Double]$T3,[Double]$T4,[Double]$Offset,[Double]$Delay)
    {
        Return [NtpTimeObject]::New($This,$T1,$T2,$T3,$T4,$Offset,$Delay)
    }
    [Object] NtpTimeOutput()
    {
        Return [NtpTimeOutput]::New($This.Object)
    }
    SetSocket()
    {
        # [Ntp Session] -> Open
        $This.Socket                = [Net.Sockets.Socket]::New("Internetwork","Dgram","Udp")
        $This.Socket.SendTimeOut    = 2000
        $This.Socket.ReceiveTimeOut = 2000

        Try 
        {
            $This.Socket.Connect($This.Server,123)
        }
        Catch 
        {
            Write-Warning "Failed to connect to server $($This.Server)"
            Return 
        }

        # [Ntp Transaction] -> Start time
        $t1          = [DateTime]::Now
            
        Try 
        {
            $This.Socket.Send($This.Data) > $Null
            $This.Socket.Receive($This.Data) > $Null
        }
        Catch 
        {
            Write-Warning "Failed to communicate with server $($This.Server)"
            Return
        }

        # [Ntp Transaction] -> End time
        $t4          = [DateTime]::Now

        # [Ntp Session] -> Close
        $This.Socket.Shutdown("Both") 
        $This.Socket.Close()
            
        # [Convert] -> (Integer + Fractional) parts of T3 Ntp time
        $t3ms        = $This.TimeTranslate($This.Data[43..40],$This.Data[47..44])

        # [Convert] -> (Integer + Fractional) parts of T2 Ntp time
        $t2ms        = $This.TimeTranslate($This.Data[35..32],$This.Data[39..36])

        # [Calculate] -> (t1 + t4) in milliseconds since [1/1/1900 00:00:00]
        $t1ms        = $This.TimeMilliseconds($t1)
        $t4ms        = $This.TimeMilliseconds($t4)
        
        # [Calculate] -> [Ntp (Offset + Delay)]
        $Offset      = (($t2ms - $t1ms) + ($t3ms-$t4ms))/2
        $Delay       = ($t4ms - $t1ms) - ($t3ms - $t2ms)

        $This.Object = $This.NtpTimeObject($T1ms,$T2ms,$T3ms,$T4ms,$Offset,$Delay)

        # Make sure the result looks sane...
        # If ([Math]::Abs($Offset) -gt $MaxOffset) {
        #     # Network server time is too different from local time
        #     Throw "Network time offset exceeds maximum ($($MaxOffset)ms)"
        # }

        # [Decode] -> Other useful parts of the received [Ntp time packet]

        # We already have the [Leap Indicator/LI] flag.

        # Now extract the remaining data flags (NTP Version, Server Mode)
        # from the first byte by (masking + shifting)

        # Force to 0 until I can figure out what info in the byte array is the leap indicator
        $LI = 0
        $This.Object.LI_text   = Switch ($LI) 
        {
            0 { 'No warning'                               }
            1 { 'Last minute has (61) seconds'             }
            2 { 'Last minute has (59) seconds'             }
            3 { 'Alarm condition (clock not synchronized)' }
        }
        
        # [Server version number]
        $This.Object.Version   = ($This.Data[0] -band 0x38) -shr 3

        # [Server mode]
        $This.Object.Mode      = ($This.Data[0] -band 0x07)
        $This.Object.Mode_text = Switch ($This.Object.Mode) 
        {
            0 { 'Reserved'                        }
            1 { 'Symmetric [Active]'              }
            2 { 'Symmetric [Passive]'             }
            3 { 'Client'                          }
            4 { 'Server'                          }
            5 { 'Broadcast'                       }
            6 { 'Reserved, [Ntp Control Message]' }
            7 { 'Reserved, [Private use]'         }
        }

        # [Stratum]
        $This.Object.Stratum      = [UInt16]$This.Data[1]
        $This.Object.Stratum_text = Switch ($This.Object.Stratum) 
        {
            0                            { '(Unspecified/unavailable)'             }
            1                            { 'Primary reference (e.g., radio clock)' }
            {$_ -ge 2 -and $_ -le 15}    { 'Secondary reference (via NTP or SNTP)' }
            {$_ -ge 16}                  { 'Reserved'                              }
        }

        # [Poll interval] -> nearest power of 2
        $This.Object.PollIntervalRaw     = $This.Data[2]
        $PISeconds                       = [Math]::Pow(2,$This.Object.PollIntervalRaw)
        $This.Object.PollIntervalSeconds = [TimeSpan]::FromSeconds($PISeconds)

        # [Precision] -> in seconds, nearest power of 2
        $PrecisionBits                   = $This.Data[3]

        # ? negative (top bit set)
        If ($PrecisionBits -band 0x80)
        {
            # Sign extend
            [Int]$This.Object.Precision  = $PrecisionBits -bor 0xFFFFFFE0
        } 
        Else 
        {
            # ...this is unlikely -> precision < 1s
            # Top bit clear, use positive value
            [Int]$This.Object.Precision  = $PrecisionBits
        }

        $This.Object.PrecisionSeconds    = [Math]::Pow(2,$This.Object.Precision)

        # [Reference Identifier] -> determine format of [ReferenceIdentifier] field, and decode
        If ($This.Object.Stratum -le 1) 
        {
            # Response from [Primary Server], [RefId] is [ASCII string] describing source
            $This.Object.ReferenceIdentifier = [String]([Char[]]$This.Data[12..15] -join '')
        }
        Else 
        {
            # Response from [Secondary Server] -> determine [server version], and decode

            Switch ($This.Object.Version)
            {
                3
                {
                    # [Secondary Server, Version 3]
                    # RefId = [IPv4 address] of [reference source]

                    $This.Object.ReferenceIdentifier = $This.Data[12..15] -join '.'
                    # If (-Not $NoDns) 
                    # {
                    #     If ($DnsLookup = Resolve-DnsName $ReferenceIdentifier -QuickTimeout -ErrorAction SilentlyContinue) 
                    #     {
                    #         $ReferenceIdentifier = "$ReferenceIdentifier <$($DnsLookup.NameHost)>"
                    #     }
                    # }
                    # Break
                }

                4
                {
                    # [Secondary Server, Version 4]
                    # RefId = low-order 32-bits of [latest transmit time] of [reference source]
                    $This.Object.ReferenceIdentifier = [BitConverter]::ToUInt32($This.Data[15..12],0) * 1000 / 0x100000000
                    Break
                }

                Default
                {
                    # [Secondary Server, Unhandled NTP version]
                    $This.Object.ReferenceIdentifier = $Null
                }
            }
        }

        # Calculate Root Delay and Root Dispersion values
        $This.Object.RootDelay      = [BitConverter]::ToInt32($This.Data[7..4],0) / 0x10000
        $This.Object.RootDispersion = [BitConverter]::ToUInt32($This.Data[11..8],0) / 0x10000
    }
    [String] ToString()
    {
        Return "<NtpTime.Controller>"
    }
}

# Creates object
$Ctrl = [NtpTimeController]::New('pool.ntp.org')

# Returns output
$Ctrl.NtpTimeOutput()
