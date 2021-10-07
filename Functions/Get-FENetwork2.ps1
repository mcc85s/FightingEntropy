Function Get-FENetwork2
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=1)][Switch]$Adapter,
        [Parameter(ParameterSetName=2)][Switch]$Interface,
        [ValidateSet(4,6)]
        [Parameter(ParameterSetName=2)][UInt32]$Version,
        [Parameter(ParameterSetName=2)][Switch]$Online,
        [Parameter(ParameterSetName=1)]
        [Parameter(ParameterSetName=2)][Switch]$Text)

    Class FENetworkAdapter
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [String] $MacAddress
        FENetworkAdapter([Object]$Adapter)
        {
            $This.Index       = $Adapter.InterfaceIndex
            $This.Name        = $Adapter.Name
            $This.Description = $Adapter.InterfaceDescription
            $This.MacAddress  = $Adapter.MacAddress.Replace("-","")
        }
    }

    Class FENetworkAdapters
    {
        [Object] $Output
        FENetworkAdapters()
        {
            $This.Output = @( Get-NetAdapter | % { [FENetworkAdapter]$_ })
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Index { 3 } Name { 28 } Description { 40 } MacAddress { 13 }
            }
            If ( $String.Length -gt $Buffer)
            {
                Return $String.Substring(0,($Buffer-3)) + "..."
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @(
            "#   Name                         Description                              MacAddress  "
            "--  ----                         -----------                              ----------  "
            ForEach ($Item in $This.Output)
            {
                $This.Buffer("Index",$Item.Index),
                $This.Buffer("Name",$Item.Name),
                $This.Buffer("Description",$Item.Description),
                $This.Buffer("MacAddress",$Item.MacAddress) -join ' '
            })
        }
    }

    Class FENetworkInterface
    {
        [UInt32] $Index
        [String] $Alias
        [UInt32] $Version
        Hidden [UInt32] $Dhcp
        Hidden [UInt32] $Online
        [Object[]] $IPAddress
        FENetworkInterface([Object]$IF)
        {
            $This.Index       = $IF.InterfaceIndex
            $This.Alias       = $IF.InterfaceAlias
            $This.Version     = @(4,6)[$IF.AddressFamily -eq 23]
            $This.Dhcp        = $IF.Dhcp -eq "Enabled"
            $This.Online      = $IF.ConnectionState -eq "Connected"
            $This.IPAddress   = $IF | Get-NetIPAddress | % { $_.IPAddress -Replace "\%\d+","" }
        }
    }

    Class FENetworkInterfaces
    {
        [Object] $Output
        FENetworkInterfaces()
        {
            $This.Output = @( Get-NetIPInterface | % { [FENetworkInterface]$_ })
        }
        FENetworkInterfaces([UInt32]$Version)
        {
            $This.Output = @( Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Version -eq $Version)
        }
        FENetworkInterfaces([Bool]$All)
        {
            $This.Output = @(Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Online -eq $All)
        }
        FENetworkInterfaces([UInt32]$Version,[Bool]$All)
        {
            $This.Output = @(Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Version -eq $Version | ? Online -eq $All)
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Index { 3 } Alias { 28 } V { 1 } Qty { 3 } IPAddress { 47 }
            }
            If ($String.Length -gt $Buffer)
            {
                Return $String.Substring(0,($Buffer-3)) + "..."
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @(
            "#   Alias                        V Qty IPAddress                                      "
            "--  -----                        - --- ---------                                      "
            ForEach ($Item in $This.Output)
            {
                $Qty = $Item.IPAddress.Count
                If ($Item.IPAddress.Count -gt 1)
                {
                    $Item.IPAddress = $Item.IPAddress -join ", "
                }

                $This.Buffer("Index",$Item.Index),
                $This.Buffer("Alias",$Item.Alias),
                $This.Buffer("V",$Item.Version),
                $This.Buffer("Qty",$Qty),
                $This.Buffer("IPAddress",$Item.IPAddress),
                $This.Buffer("IPAddress",$Item.MacAddress) -join ' '
            })
        }
    }

    Switch($PSCmdLet.ParameterSetName)
    {
        # 0 { $Object = [_Controller]::New() } 
        1 
        { 
            $Object = [FeNetworkAdapters]::New()
            If (!$Text)
            {
                $Object.Output
            }
            If ($Text)
            {
                $Object.ToString()
            }
        }
        2
        {
            If (!$Version -and !$Online)
            {
                $Object = [FENetworkInterfaces]::New()
            }
            If ($Version -and !$Online)
            {
                $Object = [FeNetworkInterfaces]::New($Version)
            }
            If ($Online -and !$Version)
            {
                $Object = [FeNetworkInterfaces]::New($Online)
            }
            If ($Online -and $Version)
            {
                $Object = [FENetworkInterfaces]::New($Version,$Online)
            }
            If ($Text)
            {
                $Object.ToString()
            }
            If (!$Text)
            {
                $Object.Output
            }
        }
    }
}
