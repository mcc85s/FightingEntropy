
    # V1 - netsh parse approach
    <#
    Class BSSID
    {
        [UInt32] $Index
        [String] $MacAddress
        [UInt32] $Signal
        [String] $RadioType
        [UInt32] $Channel
        [String[]] $Basic
        [String[]] $Other
        BSSID([Object]$Sub)
        {
            $This.Index      = [UInt32][Regex]::Matches($Sub[0],"BSSID \d+").Value.Split(" ")[1]
            $This.MacAddress = [String][Regex]::Matches($Sub[0],"([a-f0-9]{2}\:){5}([a-f0-9]{2})").Value
            $This.Signal     = ($Sub | ? { $_ -match "^\s+Signal"  }).Substring(30) -Replace "%",""
            $This.RadioType  = ($Sub | ? { $_ -match "^\s+Radio"   }).Substring(30)
            $This.Channel    = ($Sub | ? { $_ -match "^\s+Channel" }).Substring(30)
            $This.Basic      = $Sub | ? { $_ -match "^\s+Basic"   } | ? Length -gt 30 | % Substring 30
            $This.Other      = $Sub | ? { $_ -match "^\s+Other"   } | ? Length -gt 30 | % Substring 30
        }
    }

    Class SSID
    {
        Hidden [Object] $Body
        [UInt32] $Index
        [String] $Name
        [String] $NetworkType
        [String] $Authentication
        [String] $Encryption
        [Object] $BSSID
        SSID([String[]]$Section)
        {
            $This.Index          = ($Section | ? { $_ -Match "^SSID" } | % Split " ")[1]
            $This.Name           = ($Section | ? { $_ -Match "^SSID" } | % Split " ")[3]
            $This.NetworkType    = ($Section | ? { $_ -match "Network type" }).Substring(30)
            $This.Authentication = ($Section | ? { $_ -match "Authentication" }).Substring(30)
            $This.Encryption     = ($Section | ? { $_ -match "Encryption" }).Substring(30)
            $This.Body           = $Section[(0..($Section.Count-1) | ? { $Section[$_] -match "BSSID" } | Select-Object -First 1)..($Section.Count-1)]
            $THis.BSSID          = @( )

            $Ct = @{ }
            ForEach ($Line in $This.Body)
            {
                If ($Line -match "\s+BSSID")
                {
                    $Ct.Add($Ct.Count,@())
                }
                $Ct[$Ct.Count-1] += $Line
            }
            
            $X = 0
            Do
            {
                If ($Ct[$X])
                {
                    $This.BSSID += [BSSID]::New($Ct[$X])
                }
                $X ++
            }
            Until ($X -ge $Ct.Count)
        }
    }

    Class WiFi
    {
        [String] $Name
        [Object] $Interface
        [Object[]] $Network
        WiFi()
        {
            $Swap           = netsh wlan sh net mode=bssid
            $This.Name      = $Swap | ? { $_ -match "Interface name" } | % Substring 17 | % TrimEnd " "
            $This.Interface = Get-NetIPInterface | ? InterfaceAlias -match $This.Name
            $This.Network   = @( )
            $X = 0
            Do
            {
                If ($Swap[$X] -match "^SSID \d+")
                {
                    Write-Host "Detected [+] Network: ($($Swap[$X]))"
                    $Section = @( )
                    Do 
                    {
                        $Section += $Swap[$X]
                        $X ++
                    } 
                    Until ($Swap[$X] -eq "")
                    $This.AddNetwork($Section)
                }
                $X ++
            }
            Until ($X -ge ($Swap.Count - 1))
        }
        AddNetwork([String[]]$Section)
        {
            $This.Network += [SSID]::New($Section)
        }
    }
    #>
