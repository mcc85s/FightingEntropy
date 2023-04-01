<#
.SYNOPSIS
.DESCRIPTION
.LINK
https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener?view=net-7.0
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-04-01 11:28:46                                                                  //
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

    Class SocketTcpServer
    {
        [Object]    $Server
        [Object]    $Client
        [String] $IPAddress
        [UInt32]      $Port
        [Byte[]]      $Byte
        [String]      $Data
        [Object]    $Stream
        [Byte[]]   $Message
        SocketTcpServer([String]$IPAddress,[UInt32]$Port)
        {
            $This.Server    = $Null
            $This.IPAddress = $IPAddress
            $This.Port      = $Port
        }
        SetServer()
        {
            $This.Server    = $This.TcpListener($This.IPAddress,$This.Port)
        }
        Start()
        {
            $This.Server.Start()
        }
        Stop()
        {
            $This.Server.Stop()
        }
        Buffer()
        {
            $This.Byte      = [Byte[]]::New(256)
            $This.Clear()
        }
        Clear()
        {
            $This.Data      = $Null
        }
        Listen()
        {
            # // TcpListener
            $This.SetServer()

            # // Starts listening for clients
            $This.Start()
            
            # // Buffer for reading data
            $This.Buffer()

            Try
            {
                $This.Write("Waiting for a connection... ")

                # // Perform a blocking call to accept requests.
                $This.Client = $This.Server.AcceptTcpClient()
                $This.Write("Connected!")

                # // Clears the data
                $This.Clear()

                # // Get a stream object for reading and writing
                $This.Stream = $This.Client.GetStream()

                # // Loop to receive all the data sent by the client.
                $I = 0
                    
                While ($This.Read($I) -ne 0)
                {
                    # // Translate data bytes to a ASCII string.
                    $This.Data    = $This.GetString($This.Byte,0,$I)
                    $This.Write("Received: $($This.Data)")

                    # // Process the data sent by the client.
                    $This.Data    = $This.Data.ToUpper()
                    $This.Message = $This.GetBytes($This.Data)

                    # // Send back a response
                    $This.Stream.Write($This.Message,0,$This.Message.Length)
                    $This.Write("Sent: $($This.Data)")
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
        [Object] TcpListener([String]$IpAddress,[UInt32]$Port)
        {
            Return [System.Net.Sockets.TcpListener]::New($IPAddress,$Port)
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        [String] GetString([Byte[]]$Bytes,[UInt32]$Index,[UInt32]$Count)
        {
            Return [System.Text.Encoding]::ASCII.GetString($Bytes,$Index,$Count)
        }
        [Byte[]] GetBytes([String]$Data)
        {
            Return [System.Text.Encoding]::ASCII.GetBytes($Data)
        }
        [UInt32] Read([UInt32]$Token)
        {
            $Token = $This.Stream.Read($This.Byte,0,$This.Byte.Length)
            Return $Token
        }
        [String] ToString()
        {
            Return "<SocketTcpServer>"
        }
    }

    Class SocketTcpClient
    {
        [String]  $Server
        [UInt32]    $Port
        [String] $Message
        [Object]  $Client
        [Byte[]]    $Data
        [Object]  $Stream
        SocketTcpClient([String]$Server,[UInt32]$Port,[String]$Message)
        {
            $This.Server  = $Server
            $This.Port    = $Port
            $This.Message = $Message
        }
        Connect()
        {
            # // Create the client object
            $This.Client = $This.TcpClient($This.Server,$This.Port)

            # // Assign message to a [byte[]] array
            $This.Data   = $This.GetBytes($This.Message)

            # // Get a client stream for reading and writing.
            $This.Stream = $This.Client.GetStream()

            # // Send the message to the connected TcpServer.
            $This.Stream.Write($This.Data,0,$This.Data.Length)
        
            $This.Write("Sent: $($This.Message)")
        
            # // Receive the server response.
        
            # // Buffer to store the response bytes.
            $This.Data = [Byte[]]::New(256)
        
            # // String to store the response ASCII representation.
            $responseData = ""
        
            #// Read the first batch of the TcpServer response bytes.
            $Bytes        = $This.Stream.Read($This.Data,0,$This.Data.Length)
            $responseData = $This.GetString($This.Data,0,$Bytes)
            $This.Write("Received: $responseData")
        
            # // Explicit close is not necessary since TcpClient.Dispose() will be
            # // called automatically.
            # // stream.Close();
            # // client.Close();
        }
        SetClient()
        {
            $This.Client = $This.TcpClient($This.Server,$This.Port)
        }
        [Object] TcpClient([String]$Server,[UInt32]$Port)
        {
            Return [System.Net.Sockets.TcpClient]::New($Server,$Port)
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        [String] GetString([Byte[]]$Bytes,[UInt32]$Index,[UInt32]$Count)
        {
            Return [System.Text.Encoding]::ASCII.GetString($Bytes,$Index,$Count)
        }
        [Byte[]] GetBytes([String]$Data)
        {
            Return [System.Text.Encoding]::ASCII.GetBytes($Data)
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
