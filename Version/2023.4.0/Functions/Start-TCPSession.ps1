<#
.SYNOPSIS
.DESCRIPTION
.LINK
https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener?view=net-7.0
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 10:20:37                                                                  //
 \\==================================================================================================// 

    FileName   : Start-TCPSession.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Creates a TCP session between a (server + client)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : 

.Example
#>
Function Start-TCPSession
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
    [Parameter(ParameterSetName=0,Mandatory)][Switch]$Server,
    [Parameter(ParameterSetName=1,Mandatory)][Switch]$Client,
    [Parameter(ParameterSetName=0)]
    [Parameter(ParameterSetName=1,Mandatory)][String]$Source,
    [Parameter(ParameterSetName=0)]
    [Parameter(ParameterSetName=1,Mandatory)][UInt32]$Port,
    [Parameter(ParameterSetName=1,Mandatory)][Object]$Content)

    Class SocketTcpMessage
    {
        [UInt32]   $Index
        [Byte[]]    $Byte
        [UInt32]  $Length
        [String] $Message
        SocketTcpMessage([UInt32]$Index,[Byte[]]$Byte)
        {
            $This.Index        = $Index
            $This.Byte         = $Byte
            $This.Length       = $Byte.Length
            $This.Message      = $This.GetString()
        }
        [String] GetString()
        {
            Return [System.Text.Encoding]::UTF8.GetString($This.Byte,0,$This.Length)
        }
        [Byte[]] GetBytes()
        {
            Return [System.Text.Encoding]::UTF8.GetBytes($This.Message)
        }
    }

    Class SocketTcpServer
    {
        [Object]  $Server
        [Object]  $Client
        [Object]  $Stream
        [String]  $Source
        [UInt32]    $Port
        [UInt32]    $Mode
        [Object]   $Total
        [Object] $Content
        SocketTcpServer([String]$IPAddress,[UInt32]$Port)
        {
            $This.Server    = $Null
            $This.Source    = $IPAddress
            $This.Port      = $Port
            $This.Content   = @( )
        }
        SetServer()
        {
            $This.Server    = $This.TcpListener($This.Source,$This.Port)
        }
        Start()
        {
            $This.Server.Start()
        }
        Stop()
        {
            $This.Server.Stop()
        }
        Initialize()
        {
            # // TcpListener
            $This.SetServer()
    
            # // Starts listening for clients
            $This.Start()
    
            Try
            {
                $This.Write("Waiting for a connection... ")
    
                # // Perform a blocking call to accept requests
                $This.Client  = $This.Server.AcceptTcpClient()
    
                # // Show connection to remote IP endpoint
                $Ip           = $This.RemoteIp()
                $This.Write("Connected [$IP]")
    
                # // Get a stream object for (reading + writing)
                $This.Stream  = $This.Client.GetStream()

                # // Read initial message stream
                $This.Total   = $This.Rx(0)

                # // Write initial message stream
                $This.Tx($This.Total)

                # // Assign total to integer
                $Max          = [UInt32]$This.Total.Message

                Switch ($Max)
                {
                    {$_ -eq 1}
                    {
                        # // Read continuation
                        $Message       = $This.Rx(0)
                        $This.Content += $Message

                        # // Transmit Content
                        $This.Tx($Message)
                    }
                    {$_ -gt 1}
                    {
                        # // Loop through all content
                        ForEach ($X in 0..($Max-1))
                        {
                            # // Read continuation
                            $Message       = $This.Rx($X)
                            $This.Content += $Message

                            # // Transmit Content
                            $This.Tx($Message)
                        }
                    }
                }
            }
            Catch
            {
                $This.Write("Socket Exception")
                $This.Finalize()
            }
            Finally
            {
                $This.Finalize()
            }
        }
        Tx([Object]$Message)
        {
            # // Set the mode to 1
            $This.Mode = 1

            # // Write send message stream
            $This.Stream.Write($Message.Byte,0,$Message.Length)
        }
        [Object] Rx([UInt32]$Index)
        {
            # // Set the mode to 0
            $This.Mode = 0

            # // Write receive message stream
            $Array      = @( )
            Do
            {
                $Array += $This.Stream.ReadByte()
            }
            Until ($Array[-1] -eq 10)

            Return $This.TcpMessage($Index,$Array)
        }
        Finalize()
        {
            # // Explicitly close
            $This.Stop()
            $This.Stream.Close()
            $This.Client.Close()
        }
        [Object] TcpMessage([UInt32]$Index,[Byte[]]$Byte)
        {
            Return [SocketTcpMessage]::New($Index,$Byte)
        }
        [Object] TcpListener([String]$IpAddress,[UInt32]$Port)
        {
            Return [System.Net.Sockets.TcpListener]::New($IPAddress,$Port)
        }
        [String] RemoteIp()
        {
            Return $This.Client.Client.RemoteEndPoint.Address.ToString()
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        [String] GetString([Byte[]]$Bytes,[UInt32]$Index,[UInt32]$Count)
        {
            Return [System.Text.Encoding]::UTF8.GetString($Bytes,$Index,$Count)
        }
        [Byte[]] GetBytes([String]$Data)
        {
            Return [System.Text.Encoding]::UTF8.GetBytes($Data)
        }
        [String] ToString()
        {
            Return "<SocketTcpServer>"
        }
    }
    
    Class SocketTcpClient
    {
        [Object]   $Server
        [Object]   $Client
        [Object]   $Stream
        [String]   $Source
        [UInt32]     $Port
        [UInt32]     $Mode
        [Object]    $Total
        [Object]  $Content
        SocketTcpClient([String]$Source,[UInt32]$Port,[Object]$Content)
        {
            # // Assign the source (IP address + port)
            $This.Source  = $Source
            $This.Port    = $Port
    
            # // Set the server endpoint
            $This.SetServer()

            # // Set the content
            $This.SetContent($Content)
        }
        SetContent([Object]$Content)
        {
            $This.Content      = @( )
            ForEach ($Line in $Content)
            {
                $Bytes         = $This.GetBytes("$Line`n")
                $This.Content += $This.TcpMessage($This.Content.Count,$Bytes)
            }

            $Bytes          = $This.GetBytes("$($This.Content.Count)`n")

            # // Prepare initial line count
            $This.Total     = $This.TcpMessage(0,$Bytes)
        }
        Initialize()
        {
            # // Create the client object
            $This.Client    = $This.TcpClient($This.Source,$This.Port)
                    
            # // Get a client stream for (reading + writing)
            $This.Stream    = $This.Client.GetStream()

            # // Transmit first
            $This.Tx($This.Total)

            # // Receive
            $Check = $This.Rx(0)

            # // Check
            If ($Check.Message -ne $This.Total.Message)
            {
                $This.Finalize()
                Throw "The transmission was invalid"
            }

            ForEach ($Message in $This.Content)
            {
                # // Transmit Content
                $This.Tx($Message)

                # // Receive
                $Check = $This.Rx($Message.Index)

                If ($Check.Message -ne $Message.Message)
                {
                    $This.Finalize()
                    Throw "The transmission was invalid"
                }
            }

            $This.Write("Transmission complete")
        }
        Tx([Object]$Message)
        {
            # // Set the mode to 1
            $This.Mode = 1

            # // Write send message stream
            $This.Stream.Write($Message.Byte,0,$Message.Length)
        }
        [Object] Rx([UInt32]$Index)
        {
            # // Set the mode to 0
            $This.Mode = 0

            # // Write receive message stream
            $Array      = @( )
            Do
            {
                $Array += $This.Stream.ReadByte()
            }
            Until ($Array[-1] -eq 10)

            Return $This.TcpMessage($Index,[Byte[]]$Array)
        }
        Finalize()
        {
            # // Explicitly close
            $This.Stream.Close()
            $This.Client.Close()
        }
        SetServer()
        {
            $This.Server = $This.TcpEndpoint(([IPAddress]$This.Source).Address,$This.Port)
        }
        SetClient()
        {
            $This.Client = $This.TcpClient($This.Source,$This.Port)
        }
        [Byte[]] TotalBytes()
        {
            Return [Byte[]][Char[]]($This.Content.Count.ToString() + "`n")
        }
        [Object] GetTotalBytes()
        {
            Return $This.TcpMessage(0,$This.TotalBytes())
        }
        [Object] TcpMessage([UInt32]$Index,[Byte[]]$Byte)
        {
            Return [SocketTcpMessage]::New($Index,$Byte)
        }
        [Object] TcpClient([String]$Server,[UInt32]$Port)
        {
            Return [System.Net.Sockets.TcpClient]::New($Server,$Port)
        }
        [Object] TcpEndpoint([String]$Source,[UInt32]$Port)
        {
            Return [System.Net.IPEndpoint]::New($Source,$Port)
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        [String] GetString([Byte[]]$Bytes,[UInt32]$Index,[UInt32]$Count)
        {
            Return [System.Text.Encoding]::UTF8.GetString($Bytes,$Index,$Count)
        }
        [Byte[]] GetBytes([String]$Data)
        {
            Return [System.Text.Encoding]::UTF8.GetBytes($Data)
        }
        [String] ToString()
        {
            Return "<SocketTcpClient>"
        }
    }

    Switch ($pscmdlet.ParameterSetName)
    {
        0 { [SocketTcpServer]::New($Source,$Port) }
        1 { [SocketTcpClient]::New($Source,$Port,$Content) }
    }
}
