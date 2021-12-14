<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: FEModule.psm1
          Solution: FightingEntropy PSDModification
          Purpose:  Providing utilities for PXE Environment
          Author: Michael C. Cook Sr.
          Contact: 
          Primary: 
          Created: 
          Modified: 2021-12-13

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:

.Example
#>

Function Get-FENtpTime 
{
    [CmdletBinding()]
    [OutputType("Object")]
    Param ([String]$Server='pool.ntp.org'
        # [Switch]$NoDns    # Do not attempt to lookup V3 secondary-server referenceIdentifier
    )

    # --------------------------------------------------------------------
    # From https://gallery.technet.microsoft.com/scriptcenter/Get-Network-NTP-Time-with-07b216ca
    # Modifications via https://www.mathewjbray.com/powershell/powershell-get-ntp-time/
    # --------------------------------------------------------------------

    # NTP Times are all UTC and are relative to midnight on 1/1/1900
    $StartOfEpoch = New-Object DateTime(1900,1,1,0,0,0,[DateTimeKind]::Utc)   

    Function OffsetToLocal ([Object]$Offset) 
    {
        # Convert milliseconds since midnight on 1/1/1900 to local time
        $StartOfEpoch.AddMilliseconds($Offset).ToLocalTime()
    }

    Function Socket
    {
        $Item = [Net.Sockets.Socket]::New(
                [Net.Sockets.AddressFamily]::InterNetwork,
                [Net.Sockets.SocketType]::DGram,
                [Net.Sockets.ProtocolType]::Udp)
        $Item.SendTimeOut    = 2000 # ms
        $Item.ReceiveTimeOut = 2000 # ms
        Return $Item
    }

    Function Time ([String]$Server,[Object]$StartOfEpoch)
    {
        Class List
        {
            [String] $Server
            [Object] $Socket
            [Object] $StartOfEpoch
            [Byte[]] $Raw
            [Object] $Time
            [Double] $t1ms
            [Double] $t2ms
            [Double] $t3ms
            [Double] $t4ms
            [Double] $Offset
            [Object] $OffsetSeconds
            [Object] $Delay
            [Object] $t1
            [Object] $t2
            [Object] $t3
            [Object] $t4
            [Object] $VN
            [Object] $LI
            [String] $LI_Text
            [Object] $Mode
            [String] $Mode_Text
            [UInt32] $Stratum
            [String] $Stratum_Text
            [UInt32] $PollInterval
            [Object] $PollIntervalRaw
            [Object] $PollIntervalSeconds
            [Object] $Precision
            [Object] $PrecisionBits
            [Object] $PrecisionSeconds
            [Object] $ReferenceIdentifier
            [Object] $RootDelay
            [Object] $RootDispersion
            List([String]$Server,[Object]$StartOfEpoch)
            {
                $This.Server        = $Server
                $This.StartOfEpoch  = $StartOfEpoch

                # Construct a 48-byte client NTP time packet to send to the specified server
                # (Request Header: [00=No Leap Warning; 011=Version 3; 011=Client Mode]; 00011011 = 0x1B)
                
                $This.Raw      = ,0 * 48
                $This.Raw[0]   = 0x1B # NTP Request header in first byte
                
                # Open Socket --------------------------------------------------------
                $This.Socket       = Socket
                Try 
                {
                    $This.Socket.Connect($This.Server,123)
                }
                Catch 
                {
                    Write-Warning "Failed to connect to server $($This.Server)"
                    Return 
                }
            
                $This._T1((Get-Date)) # NTP Transaction Start
                Try 
                {
                    $This.Socket.Send($This.Raw)
                    $This.Socket.Receive($This.Raw)  
                }
                Catch 
                {
                    Write-Warning "Failed to communicate with server $Server"
                    Return
                }
                $This._T4((Get-Date)) # NTP transaction End

                $This.Socket.Shutdown("Both") 
                $This.Socket.Close()
                # Close Socket ---------------------------------------------------------

                # We now have an NTP response packet in $NtpData to decode.  Start with the LI flag
                # as this is used to indicate errors as well as leap-second information

                # Decode the 64-bit NTP times
                $This._T2()
                $This._T3()

                # Calculate the Ntp.Offset/Seconds and Ntp.Delay values
                $This.Offset              = (($This.t2ms - $This.t1ms) + ($This.t3ms-$This.t4ms))/2
                $This.OffsetSeconds       = [Math]::Round($This.Offset/1000, 3)
                $This.Delay               = ($This.t4ms - $This.t1ms) - ($This.t3ms - $This.t2ms)

                # NtpTime
                $This.Time                = OffsetToLocal($This.t4ms + $This.Offset)

                $This.VN                  = ($This.Raw[0] -band 0x38) -shr 3
                $This.Mode                = ($This.Raw[0] -band 0x07)
                $This.Stratum             = [UInt16]$This.Raw[1]
                $This.PollInterval        = $This.Raw[2]
                $This.PollIntervalRaw     = [Math]::Pow(2, $This.PollInterval)
                $This.PrecisionBits       = $This.Raw[3] 
                If (!$This.PrecisionBits -band 0x80)
                {    
                    [Int]$This.Precision  = $This.PrecisionBits
                } 
                If ($This.PrecisionBits -band 0x80)
                {
                    [Int]$This.Precision  = $This.PrecisionBits -bor 0xFFFFFFE0
                }
                $This.PrecisionSeconds    = [Math]::Pow(2, $This.Precision)
            
                # Determine the format of the ReferenceIdentifier field and decode
                If ($this.Stratum -le 1) 
                {
                    # Response from Primary Server.  RefId is ASCII string describing source
                    $This.ReferenceIdentifier = [String]([Char[]]$This.Raw[12..15] -join '')
                }
                If ($This.Stratum -gt 1)
                {
                    Switch ($This.VN) 
                    {
                        3   # Version 3 Secondary Server, RefId = IPv4 address of reference source 
                        {
                            $This.ReferenceIdentifier = $This.Raw[12..15] -join '.'
                        }
            
                        4   # Version 4 Secondary Server, RefId = low-order 32-bits of  
                        {
                            $This.ReferenceIdentifier = [BitConverter]::ToUInt32($This.Raw[15..12],0) * 1000 / 0x100000000
                            Break
                        }
            
                        Default
                        {
                            $This.ReferenceIdentifier = $Null
                        }
                    }
                }
                # Calculate Root Delay and Root Dispersion values
                $This.RootDelay              = [BitConverter]::ToInt32($This.Raw[7..4],0) / 0x10000
                $This.RootDispersion         = [BitConverter]::ToUInt32($This.Raw[11..8],0) / 0x10000

                $This.T1 = OffSetToLocal($This.t1ms)
                $This.T2 = OffSetToLocal($This.t2ms)
                $This.T3 = OffSetToLocal($This.t3ms)
                $This.T4 = OffSetToLocal($This.t4ms)

                $This.LI_text             = Switch ($This.LI) 
                {
                    0    {'no warning'}
                    1    {'last minute has 61 seconds'}
                    2    {'last minute has 59 seconds'}
                    3    {'alarm condition (clock not synchronized)'}
                }

                $This.Mode_text           = Switch ($This.Mode) 
                {
                    0    {'reserved'}
                    1    {'symmetric active'}
                    2    {'symmetric passive'}
                    3    {'client'}
                    4    {'server'}
                    5    {'broadcast'}
                    6    {'reserved for NTP control message'}
                    7    {'reserved for private use'}
                }

                $This.Stratum_text        = Switch ($This.Stratum) 
                {
                    0                            {'unspecified or unavailable'}
                    1                            {'primary reference (e.g., radio clock)'}
                    {$_ -ge 2 -and $_ -le 15}    {'secondary reference (via NTP or SNTP)'}
                    {$_ -ge 16}                  {'reserved'}
                }

                $This.PollIntervalSeconds = New-Object TimeSpan(0,0,$This.PollIntervalRaw)
            }
            _T1([Object]$T1) 
            {
                # Calculate values for t1 since 1/1/1900 (NTP format)
                $This.t1ms = ([TimeZoneInfo]::ConvertTimeToUtc($t1) - $This.StartOfEpoch).TotalMilliseconds
            }
            _T2() # Convert Int and Fract parts of [Byte[]](x64-t2 NTP) byte array
            {
                $X    = [BitConverter]::ToUInt32($This.Raw[35..32],0)
                $Y    = [BitConverter]::ToUInt32($This.Raw[39..36],0)
                $This.t2ms = $X * 1000 + ($Y * 1000 / 0x100000000)
            }
            _T3() # Convert Int and Fract parts of [Byte[]](x64-t3 NTP) byte array
            {
                $X    = [BitConverter]::ToUInt32($This.Raw[43..40],0)
                $Y    = [BitConverter]::ToUInt32($This.Raw[47..44],0)
                $This.t3ms = $X * 1000 + ($Y * 1000 / 0x100000000)
            }
            _T4([Object]$T4)
            {
                # Calculate values for t4 since 1/1/1900 (NTP format)
                $This.t4ms = ([TimeZoneInfo]::ConvertTimeToUtc($t4) - $This.StartOfEpoch).TotalMilliseconds
            }
        }
        [List]::New($Server,$StartOfEpoch)
    }

    $Time = Time $Server $StartOfEpoch 
    $Time | Select-Object Server, Time, OffsetSeconds, VN, Mode_text, Stratum, ReferenceIdentifier
}

Function Invoke-FERules
{
    [CmdletBinding()]
    Param ([ValidateNotNullOrEmpty()]
           [Parameter(ValueFromPipeline,Mandatory)]
           [String]$FilePath,
           [ValidateNotNullOrEmpty()]
           [Parameter(ValueFromPipeline,Mandatory)] 
           [String]$MappingFile)

    Class Variable
    {
        [String] $ID
        [String] $Type
        [String] $Overwrite
        [String] $Description
        Variable([Object]$Var)
        {
            $This.ID          = $Var.ID
            $This.Type        = $Var.Type
            $This.Overwrite   = Switch -Regex ($Var.Overwrite) { true { $True } false { $False } Default { "" } }
            $This.Description = $Var.Description
        }
    }

    Class Property
    {
        [String] $Property
        [Object] $Value
        Property([String]$Line)
        {
            $This.Property = $Line.Split("=")[0]
            $This.Value    = $Line.Substring($This.Property.Length+1)
        }
        [String] ToString()
        {
            Return "$($This.Property)=$($This.Value)"
        }
    }

    Class Section
    {
        [Object] $Name
        [Object] $Property
        Section([String]$Name)
        {
            $This.Name      = $Name
            $This.Property  = @( )
        }
        AddProperty([String]$Line)
        {
            $This.Property += [Property]::New($Line) 
        }
        [Object] GetProperty([String]$Name)
        {
            Return @( $This.Property | ? Property -eq $Name )
        }
    }

    Class Rules
    {
        [String] $FilePath
        [Object] $Content
        [Object] $Section
        Rules([String]$FilePath)
        {
            If (!(Test-Path $FilePath))
            {
                Throw "Invalid filepath"
            }

            $This.FilePath = $FilePath
            $This.Content  = Get-Content $FilePath
            $This.Section  = @( )
            ForEach ($Line in $This.Content)
            {
                Switch -Regex ($Line)
                {
                    "^\[(.+)\]$" # Section 
                    { 
                        $Name          = $Line -Replace "(\[|\])",""
                        $This.Section += [Section]::New($Name)
                    }
                    "(.+?)\s*=\s*(.*)" # Key 
                    {
                        $Item          = $This.Section | Select-Object -Last 1
                        If ($Item)
                        {
                            $Item.AddProperty($Line)
                        }
                    }
                }
            }
        }
        [Object] GetSection([String]$Name)
        {
            Return @( $This.Section | ? Name -eq $Name)
        }
        [Void] AddSection([String]$Name)
        {
            If (!$This.GetSection($Name))
            {
                $This.Section.Add($Name,[Section]::New($Name).Property)
            }
        }
        [Object] GetProperty([String]$Section,[String]$Name)
        {
            $Item = $This.GetSection($Section)
            If ($Item)
            {
                Return $Item.GetProperty($Name)
            }
                
            Else
            {
                Return "Invalid section"
            }
        }
        [Void] AddProperty([String]$Section,[String]$Name)
        {
            $Item = $This.GetProperty($Section)
            If (!$Item.GetProperty($Name))
            {
                $Item.AddProperty($Name)
            }
        }
        [String] ToString()
        {
            Return (Get-Item $This.Filepath | % Name)
        }
    }

    Class Connect
    {
        [UInt32] $maxAttempts = 5
        [UInt32]    $Attempts = 0
        [UInt32]      $Result = 0
        [String[]]       $Ips
        [UInt32]        $Port
        [Object]      $Output
        Connect([String]$Ips,[UInt32]$Port)
        {
            $This.Ips      = $Ips
            $This.Port     = $Port
            $This.Output   = @( )

            ForEach ($IP in $This.IPS)
            {
                $This.Attempts ++
                $TcpClient      = New-Object Net.Sockets.TcpClient
                Try
                {
                    Write-Verbose ("Testing {0}:{1} attempt ({2})" -f $IP,$Port,$This.Attempts)
                    $TcpClient.Connect($IP,$Port)
                    If ($TCPClient.Connected)
                    {
                        $This.Result = 1
                    }
                    Else
                    {
                        $This.Result = 0
                    }
                }
                Catch
                {
                    If ($This.Attempts -le $This.MaxAttempts)
                    {
                        Write-Verbose ("Failed {0}:{1}, attempt ({2})" -f $IP,$Port,$This.Attempts)
                        Start-Sleep -Seconds 2
                        $This.Result = 0
                    }
                    Else
                    {
                        $This.Result = 0
                    }
                }

                If ($This.Result -eq 1)
                {
                    $This.Output += ("{0}:{1}" -f $IP,$Port)
                    Break
                }
            }
        }
    }

    Class Connection
    {
        [Object] $SmbMapping
        [Object] $SmbConnection
        [String] $UserDomain
        [String] $UserID
        [String] $UserPassword
        [String] $DeployRoot
        [String] $ServerName
        [String] $ShareName
        [String] $Protocol
        [UInt32] $Port
        Connection([Object]$Bootstrap)
        {
            ForEach ($Item in $Bootstrap)
            {
                Switch -Regex ($Item.Property)
                {
                    ^UserDomain
                    { 
                        $This.UserDomain   = $Item.Value 
                    }
                    ^UserID
                    { 
                        $This.UserID       = $Item.Value 
                    }
                    ^UserPassword
                    { 
                        $This.UserPassword = $Item.Value 
                    }
                    ^DeployRoot
                    { 
                        $This.DeployRoot   = $Item.Value 
                    } 
                    ^PSDDeployRoots
                    { 
                        $This.DeployRoot   = $Item.Value -Split ','
                    }
                }
            }

            # ForEach ($Item in $Connect.DeployRoot)
            ForEach ($Item in $This.DeployRoot)
            {
                Switch -Regex ($Item)
                {
                    "^https\:.+" 
                    { 
                        $This.ServerName = $Item.Replace("https://","") | Split-Path
                        $This.Protocol   = "HTTPS" 
                    }
                    "^http\:.+"  
                    { 
                        $This.ServerName = $Item.Replace("http://","") | Split-Path
                        $This.Protocol   = "HTTP"  
                    }
                    "\\\w.+"     
                    { 
                        $This.ServerName = $Item.Split("\\")[2]
                        $This.Protocol   = "SMB"   
                    }
                }

                $This.ShareName  = $Item.Split("\")[-1]
                $This.Port       = Switch ($This.Protocol) { SMB {445} HTTP {80} HTTPS {443} WINRM {5985} Default {Throw "Invalid"} }
                $Item            = $This.TestConnection($This.ServerName,$This.Port)
                If ($Item.Result -eq 1)
                {
                    $This.SmbMapping     =  Get-SmbMapping | ? RemotePath -eq $This.DeployRoot
                    If (!$This.SmbMapping)
                    {
                        $This.SmbMapping = New-SMBMapping -RemotePath $This.DeployRoot
                    }
                }
                If ($This.SmbMapping)
                {
                    $This.SmbConnection = Get-SmbConnection | ? ServerName -eq $This.ServerName | ? ShareName -eq $This.ShareName
                    If (!$This.SmbConnection)
                    {
                        $This.SmbConnection = New-SmbConnection 
                    }
                }
            }
        }
        [Object] TestConnection([String]$IP,[UInt32]$Port)
        {
            Return @( [Connect]::New($IP,$Port))
        }
    }

    Class Main
    {
        [Object] $Var
        [Object] $Cfg
        [Object] $Con
        Main([String]$Path,[String]$MappingFile)
        {
            $This.Var  = ([XML](Get-Content $MappingFile)).Properties.Property | % { [Variable]::New($_) }
            $This.Cfg  = [Rules]::New($Path)
            $This.Con  = [Connection]::New($This.Cfg.GetSection("Default").Property)
            If (!$This.Con)
            {
                Throw "Bootstrap failure"
            }
            If ($This.Con)
            {
                
            }
        }
    }

    [Main]::New($Path,$MappingFile)
}

Export-ModuleMember -Function Get-FENtpTime, Invoke-FERules
