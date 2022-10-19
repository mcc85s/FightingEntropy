# // ___________________________________________________________________
# // | Get the Cisco Meraki IP Address from the wireless access point, |
# // | or else we won't receive any birthday party invitations         |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$String = ( "https://n137.network-auth.com/splash/?mac=88%3A15%3A44%3AA3%3AB7"+
            "%3A10&real_ip=192.168.0.81&client_ip=10.201.240.180&client_mac=9"+
            "C:B7:0D:20:08:FE&vap=0&a=a17554a0d2b15a664c0e73900184544f19e7022"+
            "7&b=17468474&auth_version=5&key=834c46c40a4248fae0dec59501aef3f0"+
            "327e6738&acl_ver=P4903858V2&continue_url=http%3A%2F%2Fwww.msftco"+
            "nnecttest.com%2Fredirect" -join '')

    # // _________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | $String is a really long string. Let's SPLIT it, so that it makes MORE SENSE                  |
    # // |_______________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Property             | Type    | Value                                                        |
    # // |______________________|_________|______________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Base                 | String  | https://n137.network-auth.com/splash/?                       |
    # // | Network Mac Address  | String  | mac=88%3A15%3A44%3AA3%3AB7%3A10&                             |
    # // | Network IP Address   | String+ | real_ip=192.168.0.81&                                        |
    # // | Client IP  Address   | String+ | client_ip=10.201.240.180&                                    |
    # // | Client Mac Address   | String  | client_mac=9C:B7:0D:20:08:FE&                                |
    # // | Virtual Access Point | Integer | vap=0&                                                       |
    # // | Private A Variable   | String+ | a=a17554a0d2b15a664c0e73900184544f19e70227&                  |
    # // | Private B Variable   | Integer | b=17468474&                                                  |
    # // | Auth. Version        | Integer | auth_version=5&                                              |
    # // | Auth. Key            | String+ | key=834c46c40a4248fae0dec59501aef3f0327e6738&                |
    # // | Access Control List  | String+ | acl_ver=P4903858V2&                                          |
    # // | Continue URL         | String+ | continue_url=http%3A%2F%2Fwww.msftconnecttest.com%2Fredirect |
    # // |______________________|_________|______________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _____________________________________________________________________
    # // | Create a verbatim copy of the class represented by the URL string |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class GolubCorpNetworkAuth
    {
        Hidden [String] $base
        [String] $mac
        [String] $real_ip
        [String] $client_ip
        [String] $client_mac
        [UInt32] $vap
        [String] $a
        [UInt32] $b
        [UInt32] $auth_version
        [String] $key
        [String] $acl_ver
        [String] $continue_url
        GolubCorpNetworkAuth([String]$String)
        {
            # https://n137.network-auth.com/splash/?
            # mac=88%3A15%3A44%3AA3%3AB7%3A10&
            # real_ip=192.168.0.81&
            # client_ip=10.201.240.180&
            # client_mac=9C:B7:0D:20:08:FE&
            # vap=0&
            # a=a17554a0d2b15a664c0e73900184544f19e70227&
            # b=17468474&
            # auth_version=5&
            # key=834c46c40a4248fae0dec59501aef3f0327e6738&
            # acl_ver=P4903858V2&
            # continue_url=http%3A%2F%2Fwww.msftconnecttest.com%2Fredirect
    
            # // ______________________________________________________________
            # // | Use the Regex base class to catch+trim+split the URL query |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $E             = [Regex]::Matches($String,"\?.+").Value.TrimStart("?").Split("&")
    
            # // _______________________________________________________________________
            # // | Test the input, if it does not have (11) components, throw an error |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($E.Count -ne 11)
            {
                Throw "Invalid entry"
            }
    
            $This.mac          = $This.Tx($E[0])
            $This.real_ip      = $This.Tx($E[1])
            $This.client_ip    = $This.Tx($E[2])
            $This.client_mac   = $This.Tx($E[3])
            $This.vap          = $This.Tx($E[4])
            $This.a            = $This.Tx($E[5])
            $This.b            = $This.Tx($E[6])
            $This.auth_version = $This.Tx($E[7])
            $This.key          = $This.Tx($E[8])
            $This.acl_ver      = $This.Tx($E[9])
            $This.continue_url = $This.Tx($E[10])
    
            $This.base         = [Regex]::Matches($String,".+\?").Value.TrimEnd("?")
        }
        [String] Tx([String]$Entry)
        {
            # Slice assignment
            $0, $1 = $Entry -Split "="
    
            # Property message
            Write-Host "Setting [~] Property: [$0], Value: [$1]" -ForegroundColor 10
                
            # Property assignment
            Return $1 
        }
        [String] Out()
        {
            Return @( $This.PSObject.Properties | % { $_.Name, $_.Value -join "=" } ) -join "&"
        }
        [String] ToString()
        {
            Return "{0}?{1}" -f $This.Base, $This.Out()
        }
    }
    
    # // ___________________________________________________________________________________________________
    # // | Now create an instantiation of the above class with the variable $String as it's only parameter |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    $Test = [GolubCorpNetworkAuth]$String
    
    # OR... you can use 
    # $Test = [GolubCorpNetworkAuth]::New($String)
    
    # // __________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $Test = [GolubCorpNetworkAuth]$String                                             |
    # // | Setting [~] Property: [mac], Value: [88%3A15%3A44%3AA3%3AB7%3A10]                              |
    # // | Setting [~] Property: [real_ip], Value: [192.168.0.81]                                         |
    # // | Setting [~] Property: [client_ip], Value: [10.201.240.180]                                     |
    # // | Setting [~] Property: [client_mac], Value: [9C:B7:0D:20:08:FE]                                 |
    # // | Setting [~] Property: [vap], Value: [0]                                                        |
    # // | Setting [~] Property: [a], Value: [a17554a0d2b15a664c0e73900184544f19e70227]                   |
    # // | Setting [~] Property: [b], Value: [17468474]                                                   |
    # // | Setting [~] Property: [auth_version], Value: [5]                                               |
    # // | Setting [~] Property: [key], Value: [834c46c40a4248fae0dec59501aef3f0327e6738]                 |
    # // | Setting [~] Property: [acl_ver], Value: [P4903858V2]                                           |
    # // | Setting [~] Property: [continue_url], Value: [http%3A%2F%2Fwww.msftconnecttest.com%2Fredirect] |
    # // |                                                                                                |
    # // | PS Prompt:\> $Test                                                                             |
    # // |                                                                                                |
    # // | mac          : 88%3A15%3A44%3AA3%3AB7%3A10                                                     |
    # // | real_ip      : 192.168.0.81                                                                    |
    # // | client_ip    : 10.201.240.180                                                                  |
    # // | client_mac   : 9C:B7:0D:20:08:FE                                                               |
    # // | vap          : 0                                                                               |
    # // | a            : a17554a0d2b15a664c0e73900184544f19e70227                                        |
    # // | b            : 17468474                                                                        |
    # // | auth_version : 5                                                                               |
    # // | key          : 834c46c40a4248fae0dec59501aef3f0327e6738                                        |
    # // | acl_ver      : P4903858V2                                                                      |
    # // | continue_url : http%3A%2F%2Fwww.msftconnecttest.com%2Fredirect                                 |
    # // |________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // __________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Cool. Now some of that information has to be processed into an object.                         |
    # // | It IS an object right now, but- it actually has some issues such as ...                        |
    # // | _____________________                                                                          |
    # // | | %3A = : | %2F = / |                                                                          |
    # // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                          |
    # // | Uh-oh. Those are gonna cause problems if we use them VERBATIM. Because...                      |
    # // | ...those are actually CHARACTER CODES so that the browser can process the input string.        |
    # // | If we were to REPLACE EVERY "%" symbol with a [char]0x, we can get back the actual character.  |
    # // |________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // __________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> [char]0x2f                                                                        |
    # // | /                                                                                              |
    # // | PS Prompt:\> [char]0x3a                                                                        |
    # // | :                                                                                              |
    # // |________________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | So, now what I'm going to do, is create MULTIPLE CLASSES so that I can cleanly organize the    |
    # // | components of the input string, in order to get a more complex object BACK from it.            |
    # // |________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    Class IpInterface
    {
        [String] $Type
        [Object]   $IP
        [String]  $Mac
        IpInterface([UInt32]$Type,[String]$IPAddress,[String]$MacAddress)
        {
            # // ________________________________________________________________
            # // | Tests whether we're specifying a NETWORK or CLIENT interface |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($Type -notin 0..1)
            {
                Throw "Invalid address type"
            }
    
            # // ______________________________________________________________________
            # // | Assign the type based on the input integer (0: Network, 1: Client) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Type = @("Network","Client")[$Type]
    
            # // _________________________________________________________
            # // | Tests whether the IP address matches IPv4 conventions |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($IPAddress -notmatch "(\d+\.\d+\.\d+\.\d+)")
            {
                Throw "Invalid IP Address"
            }
    
            # // ____________________________________________________________________________
            # // | Assigns the property "Ip", while also converting the string to an object |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Ip   = [IPAddress]$IPAddress
    
            # // _____________________________________________________
            # // | Tests whether the Mac address matches conventions |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($MacAddress -notmatch (@("[A-F0-9]{2}")*6 -join ":"))
            {
                Throw "Invalid Mac Address"
            }
    
            # // ______________________________
            # // | Assigns the property "Mac" |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.Mac  = $MacAddress
        }
        [String] ToString()
        {
            Return $This.Type, $This.Ip, $This.Mac -join "&"
        }
    }
    
    Class ApAuthenticationToken
    {
        [UInt32] $Index
        [String] $A
        [UInt32] $B
        [UInt32] $Version
        [String] $Key
        [String] $Acl
        ApAuthenticationToken([UInt32]$Index,[String]$A,[UInt32]$B,[UInt32]$Version,[String]$Key,[String]$Acl)
        {
            # // ______________________________________________________________________________________
            # // | Access Point Index is essentially "which access point is this being issued to...?" |
            # // | on the CISCO MERAKI WIRELESS LAN CONTROLLER...                                     |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Index = $Index
    
            # // _____________________________________________________________________________
            # // | A is a 40-digit HEXADECIMAL address, which is 8 digits longer than a GUID |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($A -notmatch "[a-f0-9]{40}")
            {
                Throw "Not a valid A"
            }
    
            # // ____________________________________
            # // | Now we can ASSIGN the property A |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.A = $A
    
            # // ____________________________________________________________________________________
            # // | B in the example, appears to be an 8-digit Integer/[UInt32], though it could be  |
            # // | LARGER or SMALLER. The parameter input will automatically test whether it is the |
            # // | correct type. Now we can ASSIGN the property B                                   |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.B = $B
    
            # // _____________________________________________________________________________________
            # // | Auth. Version in the example is a 1-digit integer, but perhaps it could be larger |
            # // | The parameter input will automatically test whether it is the correct type.       |
            # // | Now we can ASSIGN the property Version                                            |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Version = $Version
    
            # // _______________________________________________________________________________
            # // | Key is a 40-digit HEXADECIMAL address, which is 8 digits longer than a GUID |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            If ($Key -notmatch "[a-f0-9]{40}")
            {
                Throw "Not a valid key"
            }
            
            # // ___________________
            # // | Assigns the key |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Key = $Key
    
            # // ___________________________________________________________________________________
            # // | ACL stands for access control list, it's apparently a string, since P+V are NOT |
            # // | hexadecimal characters                                                          |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Acl = $Acl
        }
    }
    
    Class GolubCorpNetworkAuth2
    {
        [Object] $Network
        [Object] $Client
        [Object] $Token
        [String] $Continue
        [String] Cx([String]$String)
        {
            $A       = [Char[]]$String
            $X       = 0
            Return @( Do
            {
                Switch -Regex ($A[$X])
                {
                    "\%" 
                    { 
                        ("[Char]0x{0}{1}" -f $A[$X+1],$A[$X+2]) | Invoke-Expression; $X ++; $X ++ 
                    } 
                    Default 
                    { 
                        $A[$X] 
                    }
                }
                $X ++
            }
            Until ($X -eq $String.Length)) -join ''
        }
        GolubCorpNetworkAuth2([String]$String)
        {
            # // ________________________________________________________________
            # // | Here's the input, but split...                               |
            # // | https://n137.network-auth.com/splash/?                       |
            # // | mac=88%3A15%3A44%3AA3%3AB7%3A10&                             |
            # // | real_ip=192.168.0.81&                                        |
            # // | client_ip=10.201.240.180&                                    |
            # // | client_mac=9C:B7:0D:20:08:FE&                                |
            # // | vap=0&                                                       |
            # // | a=a17554a0d2b15a664c0e73900184544f19e70227&                  |
            # // | b=17468474&                                                  |
            # // | auth_version=5&                                              |
            # // | key=834c46c40a4248fae0dec59501aef3f0327e6738&                |
            # // | acl_ver=P4903858V2&                                          |
            # // | continue_url=http%3A%2F%2Fwww.msftconnecttest.com%2Fredirect |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            # // __________________________________________________________________
            # // | Use the method Cx to convert any % input to the full character |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $E = ForEach ($Item in [Regex]::Matches($String,"\?.+").Value.TrimStart("?").Split("&"))
            {
                $This.Cx($Item.Split("=")[1])
            }
    
            # // __________________________________
            # // | Assign the network information |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Network      = [IPInterface]::New(0,$E[1],$E[0])
    
            # // _________________________________
            # // | Assign the client information |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Client       = [IPInterface]::New(1,$E[2],$E[3])
    
            # // _________________________________
            # // | Compile the token information |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Token        = [ApAuthenticationToken]::New($E[4],$E[5],$E[6],$E[7],$E[8],$E[9])
    
            # // ________________________
            # // | Set the continue URL |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
            $This.Continue     = $E[10]
        }
    }
    
    # // _____________________________________________________
    # // | Alright, so now that all of the classes exist...? |
    # // | Time to put it into action.                       |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    $Test2 = [GolubCorpNetworkAuth2]::New($String)

    # // ______________________________________________________
    # // | PS Prompt:\> $Test2 | Format-List                  |
    # // |                                                    |
    # // |                                                    |
    # // | Network  : Network&192.168.0.81&88:15:44:A3:B7:10  |
    # // | Client   : Client&10.201.240.180&9C:B7:0D:20:08:FE |
    # // | Token    : ApAuthenticationToken                   |
    # // | Continue : http://www.msftconnecttest.com/redirect |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    # // ________________________________________________________
    # // | Let's look at the SUBPROPERTIES of these properties  |
    # // |                                                      |
    # // | PS Prompt:\> $Test2.Network; $Test2.Client           |
    # // |                                                      |
    # // | Type    IP             Mac                           |
    # // | ----    --             ---                           |
    # // | Network 192.168.0.81   88:15:44:A3:B7:10             |
    # // | Client  10.201.240.180 9C:B7:0D:20:08:FE             |
    # // |                                                      |
    # // | PS Prompt:\> $Test2.Token                            |
    # // |                                                      |
    # // | Index   : 0                                          |
    # // | A       : a17554a0d2b15a664c0e73900184544f19e70227   |
    # // | B       : 17468474                                   |
    # // | Version : 5                                          |
    # // | Key     : 834c46c40a4248fae0dec59501aef3f0327e6738   |
    # // | Acl     : P4903858V2                                 |
    # // |                                                      |
    # // | PS Prompt:\> $Test2.Continue                         |
    # // | http://www.msftconnecttest.com/redirect              |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-Comment @'
'@ -I 4 | Set-Clipboard 

    Search-WirelessNetwork