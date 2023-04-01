<#
.SYNOPSIS
.DESCRIPTION
.LINK
https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener?view=net-7.0
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-04-01 14:45:34                                                                  //
 \\==================================================================================================// 

    FileName   : Start-TCPSession.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : Creates a TCP session between a (server + client)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-03-30
    Modified   : 2023-04-01
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
    [Parameter(ParameterSetName=1,Mandatory)][String]$Message)

    Class SocketTcpMessage
    {
        [String]    $Type
        [Byte[]]    $Byte
        [UInt32]  $Length
        [String] $Message
        SocketTcpMessage([String]$Message)
        {
            $This.Type    = "Send"
            $This.Byte    = [Byte[]][Char[]]$Message
            $This.Length  = $This.Byte.Length
            $This.Message = $Message
        }
        SocketTcpMessage([String]$Type,[Object]$Stream)
        {
            $This.Type         = $Type
            $This.Byte         = [Byte[]]::New($Stream.Length)
            $This.Length       = $Stream.Length
            $X                 = -1
            Do
            {
                $xByte         = $Stream.ReadByte()
                $This.Byte[$X] = $xByte
                $X            ++
            }
            Until ($X -eq $This.Length)

            $This.Message      = $This.GetString()
        }
        SocketTcpMessage([Bool]$Flags,[Byte[]]$Byte)
        {
            $This.Type         = @("Send","Receive")[$Flags]
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
        [Object]   $Server
        [Object]   $Client
        [Object]   $Stream
        [String]   $Source
        [UInt32]     $Port
        [Object]  $Receive
        [Object]     $Send
        SocketTcpServer([String]$IPAddress,[UInt32]$Port)
        {
            $This.Server    = $Null
            $This.Source    = $IPAddress
            $This.Port      = $Port
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
        Listen()
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
    
                # // Write receive message stream
                $This.Receive = $This.TcpMessage("Receive",$This.Stream)

                # // Show receive message in console
                $This.Write("[Received]:")
                ForEach ($Line in $This.Receive.Message -Split "`n")
                {
                    $This.Write($Line)
                }
    
                # // Write send message stream
                $This.Send    = $This.TcpMessage("Send",$This.Receive.Byte)

                $This.Stream.Write($This.Send.Byte,0,$This.Send.Length)

                # // Show sent in console
                $This.Write("[Sent]:")
                ForEach ($Line in $This.Message -Split "`n")
                {
                    $This.Write($Line)
                }
            }
            Catch
            {
                $This.Write("SocketException")
            }
            Finally
            {
                $This.Stop()
            }
        }
        [Object] TcpMessage([String]$Type,[Object]$Stream)
        {
            Return [SocketTcpMessage]::New($Type,$Stream)
        }
        [Object] TcpMessage([Bool]$Flags,[Byte[]]$Byte)
        {
            Return [SocketTcpMessage]::New($Flags,$Byte)
        }
        [Object] TcpMessage([String]$Message)
        {
            Return [SocketTcpMessage]::New($Message)
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
        [Object]     $Send
        [Object]  $Receive
        SocketTcpClient([String]$Source,[UInt32]$Port,[String]$Message)
        {
            # // Assign the source (IP address + port)
            $This.Source  = $Source
            $This.Port    = $Port
    
            # // Set the server endpoint
            $This.SetServer()
    
            # // Convert the input to a TcpMessage object
            $This.Send   = $This.TcpMessage($Message)
        }
        Connect()
        {
            # // Create the client object
            $This.Client    = $This.TcpClient($This.Source,$This.Port)
        
            # // Get a client stream for (reading + writing)
            $This.Stream    = $This.Client.GetStream()
    
            # // Write send message stream
            $This.Stream.Write($This.Send.Byte,0,$This.Send.Length)
        
            # // Show send message in console
            $This.Write("[Sent]:") 
            ForEach ($Line in $This.Send.Message -Split "`n")
            {
                $This.Write($Line)
            }                            
        
            # // Read receive message stream
            $This.Receive = $This.TcpMessage("Receive",$This.Stream)

            # // Show receive message in console
            $This.Write("[Received]:")
            ForEach ($Line in $This.Receive.Message -Split "`n")
            {
                $This.Write($Line)
            }
        
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
        [Object] TcpMessage([String]$Type,[Object]$Stream)
        {
            Return [SocketTcpMessage]::New($Type,$Stream)
        }
        [Object] TcpMessage([Bool]$Flags,[Byte[]]$Byte)
        {
            Return [SocketTcpMessage]::New($Flags,$Byte)
        }
        [Object] TcpMessage([String]$Message)
        {
            Return [SocketTcpMessage]::New($Message)
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
        1 { [SocketTcpClient]::New($Source,$Port,$Message) }
    }
}

<# [Server]

    . C:\Users\mcadmin\Documents\Start-TCPSession.ps1

    $Server = "192.168.42.2"
    $Port   = 13000

    $Test   = Start-TCPSession -Server -Source $Server -Port $Port
    $Test.Listen()
#>

<# [Client]

    $Server = "192.168.42.2"
    $Port   = 13000

    $Test   = Start-TCPSession -Client -Source $Server -Port $Port -Message Testing
    $Test.Connect()
#>
