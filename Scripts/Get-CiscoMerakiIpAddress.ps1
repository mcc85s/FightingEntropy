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

    # // ____________________________________________________________________________________________
    # // | Now, we have some stuff to play around with, particularly the assemblies and types       |
    # // | available in the function Search-WirelessNetwork in [FightingEntropy(π)]                 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ____________________________________________________________________________________________
    # // | What I'm going to do, is to call the Use-Wlanapi function, in order to pull some of the  |
    # // | type information so I can access the RADIOS from the PowerShell console.                 |
    # // | Calling the function only assembles the code, it doesn't instantiate it.                 |
    # // |                                                                                          |
    # // | So, we will do that below with the function Add-Type with various additional parameters. |
    # // |                                                                                          |
    # // | I'm going to pick apart the function Search-WirelessNetwork, and paste the content       | 
    # // | of its' several classes, and then use those classes to examine some of input/output.     |
    # // |                                                                                          |
    # // | By the time the lesson plan is over with...? Some people will probably say to themselves |
    # // | "This dude is a legitimate expert that knows what the hell he's doing..."                |
    # // |                                                                                          |
    # // | That's the point of all of this. If I want to CONVINCE somebody who's a PHILANTHROPIST,  |
    # // | that a couple dudes like CHRISTOPHER MURPHY and DANIEL PICKETT have been REMOTELY        |
    # // | INTERACTING with my DEVICES...? Then I have to find a way to BYPASS people in society    |
    # // | who think that stuff sounds INSANE. Right...? Cause, I gotta tell ya...                  |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | (Michael Edward Cook + Jesse Pickett + Husdon Valley Community College)    [Correlation] |
    # // | https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2021_0414-(Jesse%20Pickett).pdf |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | (Nfrastructure + FBI Investigator Murphy + Golub Corporation)              [Correlation] |
    # // | 05/23/20 0133 | https://youtu.be/3twiZEsyQf0                                             |
    # // | 05/23/20 0203 | https://youtu.be/V-_YqedKZb8                                             |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | (Nfrastructure + Shenendehowa + Golub Corporation + etc.)                                |
    # // | 05/23/20 1200 | https://youtu.be/HT4p28bRhqc                                             |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Uh-oh. I'm an actual expert that knows what he's saying/doing, whether it's with the     |
    # // | TECHNOLOGY or it's the PEOPLE I just mentioned. Sometimes people such as myself are SO   | 
    # // | INTELLIGENT, that when I SAY STUFF THAT HAS SUPPORTING EVIDENCE for my THEORIES...?      |
    # // | They'll be like "But such-and-such told me...", like LAURA HUGHES from SARATOGA COUNTY.  |
    # // |                                                                                          |
    # // | That's the power of PEOPLE WHO LIE...                                                    |
    # // | If such-and-such told you (1) thing...                                                   |
    # // | But the SUPPORTING EVIDENCE tells you (1) OTHER thing...?                                |
    # // | *squinting* ...what do you think that means...?                                          |
    # // | It means this: such-and-such lied to you, and you just blindly followed along.           |
    # // | Oh boy. Whatever will we do if everybody lies to one another...?
    # // |                                                                                          |
    # // | People think that what I say sounds INSANE, because they don't make what's otherwise     |
    # // | referred to as an "EFFORT", to review the SUPPORTING EVIDENCE, in order to UNDERSTAND my |
    # // | "THEORIES".                                                                              |
    # // |                                                                                          |
    # // | That's pretty important, ESPECIALLY if you're a POLICE OFFICER or an INVESTIGATOR.       |
    # // | Unfortunately, the INVESTIGATORS at (SCSO/NYSP), they are not that intelligent.          |
    # // | Neither are half of the people who work for SARATOGA COUNTY.                             |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | (SCSO Captain Jeffrey Brown)                                                             |
    # // | 02/02/21 | https://drive.google.com/file/d/1JECZXhwpXFO5B8fvFnLftESp578PFVF8             |
    # // |__________________________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | If they WERE...? They would have been able to make the SAME CORRELATIONS I have made,    |
    # // | over the last 2.5 years since I recorded that content up above. The CORRELATIONS are...  |
    # // |                                                                                          |    
    # // | My dad + Jesse Pickett -> studied PROGRAMMING @ HVCC in 88/89 -> Nfrastructure 92 ->     |
    # // | My dad murdered by GANG/MAFIA/KGB in 95 -> also Sammy Santa Cassaro ** in 96 ->          |
    # // | Same cab company + Same radio dispatcher + Lived in the same neighborhood + Both murders |
    # // | APPEAR to have been MONEY/DRUG related, but APPEARNCES CAN BE DECEIVING -> I could go on |
    # // |                                                                                          |
    # // | How those 26-27 year old murder cases became RELEVANT AGAIN, is because:                 |
    # // | I believe that someone had my father murdered, and that they tried to have ME murdered,  |
    # // | after my NETWORK at (Computer Answers - 1602 US-9, Clifton Park NY 12065) was subjected  |
    # // | to an extremely sophisticated cyberattack on 01/15/2019 involving:                       |
    # // |                                                                                          |
    # // | CVE-2019-8936, DDOS, WannaCry derivative, and I also believe that my Apple iPhone 8+ had |
    # // | a DANGEROUS PROGRAM CALLED PHANTOM/PEGASUS DEPLOYED TO IT TO SPY ON ME...                |
    # // | ...and that AFTER I recorded those ABOVE exhibits from 05/23/20...?                      |
    # // | 2x 25-30 year old white males attempted to murder me outside of COMPUTER ANSWERS between |
    # // | 05/25/20 2343 -> 05/26/20 0130 leading to SCSO-2020-028501.                              |
    # // |                                                                                          |
    # // | I visually confirmed that I RECORDED A VIDEO, of these 2 guys, using Pegasus/Phantom,    |
    # // | that appeared to be KNEE DEEP in attempting to: MURDER ME.                               |
    # // | I told SCSO SCOTT SCHELLING about this (event/video) and my 2x 911 calls were subjected  |
    # // | to what's otherwise known as a TELEPHONY DENIAL OF SERVICE attack, (feature of Pegasus), |
    # // | and for whatever reason...? Someone in the government disabled my iPhone 8+ after this.  |
    # // | Oh boy. Whatever will I do...?                                                           |
    # // |                                                                                          |
    # // | At some point in history, planet Earth was overrun by morons who can't think real hard.  |
    # // | I think I've been saying that for like *checks watch* 2.5 years now.                     |
    # // |                                                                                          |
    # // | I'm just, surrounded by people that think I'm making ALL of that stuff up, right...?     |
    # // | And that's ok. Sometimes people are SLOW ON THE UPTAKE.                                  |
    # // |                                                                                          |
    # // | I'm not gonna go around and shake my finger in people's faces if they don't UNDERSTAND   |
    # // | what I've been saying...? However, uh- given the detail of what I've discussed so far in |
    # // | this LESSON PLAN, as well as links to the several pieces of "SUPPORTING EVIDENCE", I'm   |
    # // | fairly certain that ANYBODY WITH AN ACTUAL BRAIN, may be able to LOGICALLY DEDUCE that   |
    # // | what I'm SUGGESTING has a PLAUSIBILITY FACTOR AFTER ALL.                                 |
    # // |                                                                                          |
    # // | That said, let's proceed with the lesson plan.                                           |
    # // |__________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _______________________________________________________________________________
    # // | Load the types from the function Use-Wlanapi                                |
    # // | Since the command is rather long, I'll perform what's called "SPLATTING"... |
    # // | by assigning a variable named $Splat to a hashtable.                        |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $Splat               = @{ 

        MemberDefinition = Use-Wlanapi       # <- Install [FightingEntropy(π)] to use this
        Using            = "System.Text"
        Namespace        = "WiFi"
        Name             = "ProfileManagement"
    }

    Add-Type @Splat -Passthru | Out-Null

    # // _____________________________________________________________________________________________
    # // | Provides an accurate representation of the information collected by the wireless radio(s) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Ssid
    {
        [UInt32] $Index
        Hidden [Object] $Ssid
        [String] $Name
        [Object] $Bssid
        [String] $Type
        Hidden [UInt32] $TypeSlot
        Hidden [String] $TypeDescription
        [Object] $Uptime
        [String] $NetworkType
        [String] $Authentication
        Hidden [UInt32] $AuthenticationSlot
        Hidden [String] $AuthenticationDescription
        [String] $Encryption
        Hidden [UInt32] $EncryptionSlot
        Hidden [String] $EncryptionDescription
        [UInt32] $Strength
        [String] $BeaconInterval
        [Double] $ChannelFrequency
        [Bool]   $IsWifiDirect
        Ssid([UInt32]$Index,[Object]$Object)
        {
            $This.Index              = $Index
            $This.Ssid               = $Object
            $This.Name               = $Object.Ssid
            $This.Bssid              = $Object.Bssid.ToUpper()
            $This.GetPhyType($Object.PhyKind)
            $This.Uptime             = $This.GetUptime($Object.Uptime)
            $This.NetworkType        = $Object.NetworkKind
            $This.Authentication     = $Object.SecuritySettings.NetworkAuthenticationType
            $This.GetNetAuthType($This.Authentication)
            $This.Encryption         = $Object.SecuritySettings.NetworkEncryptionType
            $This.GetNetEncType($This.Encryption)
            $This.Strength           = $Object.SignalBars
            $This.BeaconInterval     = $Object.BeaconInterval
            $This.ChannelFrequency   = $Object.ChannelCenterFrequencyInKilohertz
            $This.IsWiFiDirect       = $Object.IsWiFiDirect
        }
        [String] ToString()
        {
            Return $This.Name
        }
        [String] GetUptime([String]$Uptime)
        {
            $Slot      = @( )
            $Total     = $Uptime -Split "(\:|\.)" | ? { $_ -match "\d+" }
            $Ticks     = $Total[-1].Substring(0,3)
            $Seconds   = "{0}s" -f $Total[-2]
            $Minutes   = "{0}m" -f $Total[-3]
            $Hours     = "{0}h" -f $Total[-4]
            If ($Total[-5])
            {
                $Days  = "{0}d" -f $Total[-5]
                $Slot += $Days
            }

            If ($Total[-4])
            {
                $Slot += $Hours
            }

            If ($Total[-3])
            {
                $Slot += $Minutes
            }

            If ($Total[-2])
            {
                $Slot += $Seconds
            }

            If ($Total[-1])
            {
                $Slot += $Ticks
            }
            Return @( $Slot -join " " )
        }
        GetPhyType([String]$PhyKind)
        {
            $Types         = "Unknown","Fhss","Dsss","IRBaseband","Ofdm",
                             "Hrdsss","Erp","HT","Vht","Dmg","HE"
            $This.TypeSlot = $Types.IndexOf($PhyKind)
            $This.TypeDescription = Switch ($PhyKind)
            {
                Unknown     { "Unspecified physical type"                      }
                Fhss        { "(FHSS/Frequency-Hopping Spread-Spectrum)"       }
                Dsss        { "(DSSS/Direct Sequence Spread-Spectrum)"         }
                IRBaseband  { "(IR/Infrared baseband)"                         }
                Ofdm        { "(OFDM/Orthogonal Frequency Division Multiplex)" }
                Hrdsss      { "(HRDSSS/High-rated DSSS)"                       }
                Erp         { "(ERP/Extended Rate)"                            }
                HT          { "(HT/High Throughput [802.11n])"                 }
                Vht         { "(VHT/Very High Throughput [802.11ac])"          }
                Dmg         { "(DMG/Directional Multi-Gigabit [802.11ad])"     }
                HE          { "(HEW/High-Efficiency Wireless [802.11ax])"      }
            }
            $Regex         = [Regex]::Matches($this.TypeDescription,"(802\.11\w+)").Value
            $This.Type     = @("Unknown",$Regex)[$This.TypeDescription -match 802.11]
        }
        GetNetAuthType([String]$Auth)
        {
            $Types         = "None","Unknown","Open80211","SharedKey80211","Wpa",
                             "WpaPsk","WpaNone","Rsna","RsnaPsk","Ihv","Wpa3",
                             "Wpa3Enterprise192Bits","Wpa3Sae","Owe","Wpa3Enterprise"
            $This.AuthenticationSlot = $Types.IndexOf($Auth)
            $This.AuthenticationDescription = Switch -Regex ($Auth)
            {
                ^None$ 
                {
                    "No authentication enabled."
                }
                ^Unknown$ 
                {
                    "Authentication method unknown."
                }
                ^Open80211$ 
                {
                    "Open authentication over 802.11 wireless.",("Devices are authenticated and can connect"+
                    " to an access point."),("Communication w/ network requires matching (WEP/Wired Equival"+
                    "ent Privacy) key.")
                }
                ^SharedKey80211$ 
                { 
                    "Specifies an IEEE 802.11 Shared Key authentication algorithm.",("Requires pre-shared ("+
                    "WEP/Wired Equivalent Privacy) key for 802.11 authentication.")
                }
                ^Wpa$            
                { 
                    "Specifies a (WPA/Wi-Fi Protected Access) algorithm.",("IEEE 802.1X port authorization "+
                    "is performed by the supplicant, authenticator, and authentication server."),("Cipher k"+
                    "eys are dynamically derived through the authentication process.")
                }
                ^WpaPsk$ 
                {
                    "Specifies a (WPA/Wi-Fi Protected Access) algorithm that uses (PSK/pre-shared key).",
                    "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                    ("Cipher keys are dynamically derived through a PSK that is used on both the supplicant"+
                    " and authenticator.")
                }
                ^WpaNone$ 
                {
                    "Wi-Fi Protected Access."
                }
                ^Rsna$
                {
                    "Specifies an IEEE 802.11i (RSNA/Robust Security Network Association) algorithm.",("IEE"+
                    "E 802.1X port authorization is performed by the supplicant, authenticator, and authent"+
                    "ication server."),"Cipher keys are dynamically derived through the auth. process."
                }
                ^RsnaPsk$ 
                {
                    "Specifies an IEEE 802.11i RSNA algorithm that uses (PSK/pre-shared key).",
                    "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                    ("Cipher keys are dynamically derived through a PSK that is used on both the supplican"+
                    "t and authenticator.")
                }
                ^Ihv$ 
                {
                    "Specifies an authentication type defined by an (IHV/Independent Hardware Vendor)."
                }
                "(^Wpa3$|^Wpa3Enterprise192Bits$)" 
                {
                    ("Specifies a 192-bit encryption mode for (WPA3-Enterprise/Wi-Fi Protected Access 3 Ent"+
                    "erprise) networks.")
                }
                ^Wpa3Sae$ 
                {
                    ("Specifies (WPA3 SAE/Wi-Fi Protected Access 3 Simultaneous Authentication of Equals) "+
                    "algorithm."),("WPA3 SAE is the consumer version of WPA3. SAE is a secure key establis"+
                    "hment protocol between devices;"),("SAE provides: synchronous authentication, and str"+
                    "onger protections for users against password-guessing attempts by third parties.")
                }
                ^Owe$ 
                {
                    "Specifies an (OWE/Opportunistic Wireless Encryption) algorithm.",
                    "OWE provides opportunistic encryption over 802.11 wireless networks.",
                    "Cipher keys are dynamically derived through a (DH/Diffie-Hellman) key exchange-",
                    "Enabling data protection without authentication."
                }
                ^Wpa3Enterprise$ 
                {
                    "Specifies a (WPA3-Enterprise/Wi-Fi Protected Access 3 Enterprise) algorithm.",("WPA3-E"+
                    "nterprise uses IEEE 802.1X in a similar way as (RSNA/Robust Security Network Associati"+
                    "on)-"),("However, it provides increased security through the use of mandatory certific"+
                    "ate validation and protected management frames.")
                }
            }
        }
        GetNetEncType([String]$Enc)
        {
            $Types = "None","Unknown","Wep","Wep40","Wep104","Tkip","Ccmp","WpaUseGroup","RsnUseGroup",
                     "Ihv","Gcmp","Gcmp256" 
            $This.EncryptionSlot = $Types.IndexOf($Enc)
            $This.EncryptionDescription = Switch ($Enc)
            {
                None
                { 
                    "No encryption enabled."
                }
                Unknown
                {
                    "Encryption method unknown."
                }
                Wep
                {
                    "Specifies a WEP cipher algorithm with a cipher key of any length."
                }
                Wep40
                {
                    ("Specifies an RC4-based (WEP/Wired Equivalent Privacy) algorithm specified in IEEE 802"+
                    ".11-1999."),"This enumerator specifies the WEP cipher algorithm with a 40-bit cipher key."
                }
                Wep104
                {
                    "Specifies a (WEP/Wired Equivalent Privacy) cipher algorithm with a 104-bit cipher key."
                }
                Tkip
                {
                    "Specifies an RC4-based cipher (TKIP/Temporal Key Integrity Protocol) algorithm",("This"+
                    " cipher suite that is based on algorithms defined in WPA + IEEE 802.11i-2004 standards."),
                    "This cipher also uses the (MIC/Message Integrity Code) algorithm for forgery protection."
                }
                Ccmp
                {
                    "Specifies an [IEEE 802.11i-2004 & RFC 3610] AES-CCMP algorithm standard.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
                WpaUseGroup
                {
                    "Specifies a (WPA/Wifi Protected Access) Use Group Key cipher suite.",
                    "For more information about the Use Group Key cipher suite, refer to:",
                    "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
                }
                RsnUseGroup
                {
                    "Specifies a (RSN/Robust Security Network) Use Group Key cipher suite.",
                    "For more information about the Use Group Key cipher suite, refer to:",
                    "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
                }
                Ihv
                {
                    "Specifies an encryption type defined by an (IHV/Independent Hardware Vendor)."
                }
                Gcmp
                {
                    "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 128-bit key.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
                Gcmp256
                { 
                    "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 256-bit key.",
                    "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
                }
            }
        }
    }

    # // _______________________________
    # // | Handles the profile objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WiFiProfile
    {
        [Object] $Interface
        [String] $Name
        [String] $Flags
        [Object] $Detail
        WiFiProfile([Object]$Interface,[Object]$ProfileInfo)
        {
            $This.Interface = $Interface
            $This.Name      = $ProfileInfo.strProfileName
            $This.Flags     = $ProfileInfo.ProfileFlags
            $This.Detail    = $Null
        }
        [String[]] ToString()
        {
            Return @(
            " ",
            "Interface       : $($This.Interface.Name)",
            "Guid            : $($This.Interface.Guid)",
            "Description     : $($This.Interface.Description)",
            "IfIndex         : $($This.Interface.ifIndex)",
            "Status          : $($This.Interface.Status)",
            "MacAddress      : $($This.Interface.MacAddress)",
            "LinkSpeed       : $($This.Interface.LinkSpeed)",
            "State           : $($This.Interface.State)",
            "----"
            "SSID            : $($This.Name)",
            "Flags           : $($This.Flags)",
            "ProfileName     : $($This.Detail.ProfileName)",
            "ConnectionMode  : $($This.Detail.ConnectionMode)",
            "Authentication  : $($This.Detail.Authentication)",
            "Encryption      : $($This.Detail.Encryption)",
            "Password        : $($This.Detail.Password)",
            "HiddenSSID      : $($This.Detail.ConnectHiddenSSID)",
            "EAPType         : $($This.Detail.EAPType)",
            "ServerNames     : $($This.Detail.ServerNames)",
            "TrustedRootCA   : $($This.Detail.TrustedRootCA)",
            "----",
            "XML             : $($This.Detail.Xml)",
            " "
            )
        }
    }

    # // ____________________________________________________________
    # // | Represents an individual wireless interface on the host. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class InterfaceObject
    {
        [String] $Name
        [String] $Guid
        [String] $Description
        [UInt32] $ifIndex 
        [String] $Status
        [String] $MacAddress
        [String] $LinkSpeed
        [String] $State
        InterfaceObject([Object]$Info,[Object]$Interface)
        {
            $This.Name        = $Interface.Name
            $This.Guid        = $Info.Guid
            $This.Description = $Info.Description
            $This.ifIndex     = $Interface.ifIndex
            $This.Status      = $Interface.Status
            $This.MacAddress  = $Interface.MacAddress.Replace("-",":")
            $This.LinkSpeed   = $Interface.LinkSpeed
            $This.State       = $Info.State
        }
    }

    # // ____________________________________________________________
    # // | Parses WLAN adapter information returned from the netsh. |
    # // | Not nearly as CLEAN as accessing wlanapi.dll...?         |
    # // | But- it is included as a FALLBACK MECHANISM.             |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class WlanInterface
    {
        Hidden [String[]] $Select
        [String] $Name
        [String] $Description
        [String] $Guid
        [String] $MacAddress
        [String] $InterfaceType
        [String] $State
        [String] $Ssid
        [String] $Bssid
        [String] $NetworkType
        [String] $RadioType
        [String] $Authentication
        [String] $Cipher
        [String] $Connection
        [String] $Band
        [UInt32] $Channel
        [Float]  $Receive
        [Float]  $Transmit
        [String] $Signal
        [String] $Profile
        WlanInterface([String[]]$Select)
        {
            $This.Select                 = $Select
            $This.Name                   = $This.Find("Name")
            $This.Description            = $This.Find("Description")
            $This.GUID                   = $This.Find("GUID")
            $This.MacAddress             = $This.Find("Physical address")
            $This.InterfaceType          = $This.Find("Interface type")
            $This.State                  = $This.Find("State")
            $This.Ssid                   = $This.Find("SSID")
            $This.Bssid                  = $This.Find("BSSID") | % ToUpper
            $This.NetworkType            = $This.Find("Network type")
            $This.RadioType              = $This.Find("Radio type")
            $This.Authentication         = $This.Find("Authentication")
            $This.Cipher                 = $This.Find("Cipher")
            $This.Connection             = $This.Find("Connection mode")
            $This.Band                   = $This.Find("Band")
            $This.Channel                = $This.Find("Channel")
            $This.Receive                = $This.Find("Receive rate \(Mbps\)")
            $This.Transmit               = $This.Find("Transmit rate \(Mbps\)")
            $This.Signal                 = $This.Find("Signal")
            $This.Profile                = $This.Find("Profile")
        }
        [String] Find([String]$String)
        {
            Return @(($This.Select | ? { $_ -match "(^\s+$String\s+\:)" }).Substring(29))
        }
    }

    # // _____________________________________________________________
    # // | Specifically for selecting/filtering a Runtime IAsyncTask |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class RtMethod
    {
        [String] $Name
        [Object] $Params
        [Object] $Count
        [Object] $Object
        RtMethod([Object]$Object)
        {
            $This.Object = $Object
            $This.Params = $Object.GetParameters()
            $This.Count  = $This.Params.Count
            $This.Name   = $This.Params[0].ParameterType.Name
        }
    }

    # // ___________________________
    # // | Better than a hashtable |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ConnectionModeResolver
    {
        [String] $Profile           = "WLAN_CONNECTION_MODE_PROFILE"
        [String] $TemporaryProfile  = "WLAN_CONNECTION_MODE_TEMPORARY_PROFILE"
        [String] $DiscoverySecure   = "WLAN_CONNECTION_MODE_DISCOVERY_SECURE"
        [String] $Auto              = "WLAN_CONNECTION_MODE_AUTO"
        [String] $DiscoveryUnsecure = "WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE"
    }

    # // __________________________________________________________________________________
    # // | Controller class for the function, this encapsulates the XAML/GUI, as well as  |
    # // | ALL of the various classes and functions necessary to access the radios.       |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Wireless
    {
        Hidden [Object] $Module
        Hidden [String] $OEMLogo
        [Object] $Adapters
        [Object] $Request
        [Object] $Radios
        [Object] $List
        [Object] $Output
        [Object] $Selected
        [Object] $Connected
        [Object] Task()
        {
            Return [System.WindowsRuntimeSystemExtensions].GetMethods() | ? Name -eq AsTask | % { 
                   [RtMethod]$_ } | ? Count -eq 1 | ? Name -eq IAsyncOperation``1 | % Object
        }
        [Object] RxStatus()
        {
            Return [Windows.Devices.Radios.RadioAccessStatus]
        }
        [Object[]] RxAsync()
        {
            Return [Windows.Devices.Radios.Radio]::RequestAccessAsync()
        }
        [Object] RsList()
        {
            Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]
        }
        [Object[]] RsAsync()
        {
            Return [Windows.Devices.Radios.Radio]::GetRadiosAsync()
        }
        [Object] RaList()
        {
            Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]]
        }
        [Object[]] RaAsync()
        {
            Return [Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync()
        }
        [Object] RadioRequestAccess()
        {
            Return $This.Task().MakeGenericMethod($This.RxStatus()).Invoke($Null,$This.RxAsync())
        }        
        [Object] RadioSynchronization()
        {
            Return $This.Task().MakeGenericMethod($This.RsList()).Invoke($Null, $This.RsAsync())
        }
        [Object] RadioFindAllAdaptersAsync()
        {
            Return $This.Task().MakeGenericMethod($This.RaList()).Invoke($Null, $This.RaAsync())
        }
        [Object] NetshShowInterface([String]$Name)
        {
            Return [WlanInterface]::New((netsh wlan show interface $Name))
        }
        [String] Win32Exception([UInt32]$RC)
        {
            # // __________________
            # // | RC: ReasonCode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[System.ComponentModel.Win32Exception]::new($RC)" | IEX
        }
        [Object] WlanReasonCodeToString([UInt32]$RC,[UInt32]$BS,[Object]$SB,[IntPtr]$Res)
        {
            # // _______________________________________________________________________
            # // | RC: ReasonCode | BS: BufferSize | SB: StringBuilder | Res: Reserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanReasonCodeToString($RC,$BS,$SB,$Res)" | IEX
        }
        [Void] WlanFreeMemory([IntPtr]$P)
        {
            # // ______________
            # // | P: Pointer |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "[WiFi.ProfileManagement]::WlanFreeMemory($P)" | IEX
        }
        [Object] WlanOpenHandle([UInt32]$CV,[IntPtr]$PR,[UInt32]$NV,[IntPtr]$CH)
        {
            # // ________________________________________________________________________________
            # // | CV: ClientVersion | PR: pReserved | NV: NegotiatedVersion | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanOpenHandle($CV, $PR, $NV, $CH)" | IEX
        }
        [Object] WlanCloseHandle([IntPtr]$CH,[IntPtr]$Res)
        {
            # // ____________________________________
            # // | CH: ClientHandle | Res: Reserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanCloseHandle($CH, $Res)" | IEX
        }
        [Object] WlanEnumInterfaces([IntPtr]$CH,[IntPtr]$PR,[IntPtr]$IL)
        {
            # // __________________________________________________________
            # // | CH: ClientHandle | PR: pReserved | IL: ppInterfaceList |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanEnumInterfaces($CH, $PR, $IL)" | IEX
        }
        [Object] WlanInterfaceList([IntPtr]$IIL)
        {
            # // ____________________________
            # // | IIL: ppInterfaceInfoList |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+WLAN_INTERFACE_INFO_LIST]::new($IIL)" | IEX
        }
        [Object] WlanInterfaceInfo([Object]$II)
        {
            # // _________________________
            # // | II: WlanInterfaceInfo |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+WLAN_INTERFACE_INFO]$II" | IEX
        }
        [Object] WlanGetProfileList([IntPtr]$CH,[guid]$IG,[IntPtr]$PR,[IntPtr]$PL)
        {
            # // __________________________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | PR: pReserved | PL: ProfileList |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanGetProfileList($CH,$IG,$PR,$PL)" | IEX
        }
        [Object[]] WlanGetProfileListFromPtr([IntPtr]$PLP)
        {
            # // ___________________________
            # // | PLP: ProfileListPointer |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+WLAN_PROFILE_INFO_LIST]::new($PLP).ProfileInfo" | IEX
        }
        [Object] WlanGetProfile([IntPtr]$CH,[Guid]$IG,[String]$PN,[IntPtr]$PR,[String]$X,[UInt32]$F,[UInt32]$A)
        {
            # // __________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | PN: ProfileName |
            # // | PR: pReserved | X: Xml | F: Flags | A: Access          |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanGetProfile($CH,$IG,$PN,$PR,$X,$F,$A)" | IEX
        }
        [Object] WlanProfileInfoObject()
        {
            Return "[WiFi.ProfileManagement+ProfileInfo]::New()" | IEX
        }
        [Object] WlanConnectionParams()
        {
            Return "[WiFi.ProfileManagement+WLAN_CONNECTION_PARAMETERS]::new()" | IEX
        }
        [Object] WlanConnectionMode([String]$CM)
        {
            # // ______________________
            # // | CM: ConnectionMode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+WLAN_CONNECTION_MODE]::$CM" | IEX
        }
        [Object] WlanDot11BssType([String]$D)
        {
            # // ___________________
            # // | D: Dot11BssType |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+DOT11_BSS_TYPE]::$D" | IEX
        }
        [Object] WlanConnectionFlag([String]$F)
        {
            # // ___________
            # // | F: Flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement+WlanConnectionFlag]::$F" | IEX
        }
        [Object] WlanSetProfile([UInt32]$CH,[Guid]$IG,[UInt32]$F,[IntPtr]$PX,[IntPtr]$PS,
                                [Bool]$O,[IntPtr]$PR,[IntPtr]$pdw)
        {
            # // ___________________________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | F: Flags | PX: ProfileXml        |
            # // | PS: ProfileSecurity | O: Overwrite | PR: pReserved | PDW: pdwReasonCode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return "[WiFi.ProfileManagement]::WlanSetProfile($CH,$IG,$F,$PX,$PS,$O,$PR,$PDW)" | IEX
        }
        [Void] WlanDeleteProfile([IntPtr]$CH,[Guid]$IG,[String]$PN,[IntPtr]$PR)
        {
            # // __________________________________________________________________________
            # // | CH: ClientHandle | IG: InterfaceGuid | PN: ProfileName | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "[WiFi.ProfileManagement]::WlanDeleteProfile($CH,$IG,$PN,$PR)" | IEX
        }
        [Void] WlanDisconnect([IntPtr]$HCH,[Guid]$IG,[IntPtr]$PR)
        {
            # // __________________________________________________________
            # // | HCH: hClientHandle | IG: InterfaceGuid | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "[WiFi.ProfileManagement]::WlanDisconnect($HCH,$IG,$PR)" | IEX
        }
        [Void] WlanConnect([IntPtr]$HCH,[Guid]$IG,[Object]$CP,[IntPtr]$PR)
        {
            # // _____________________________________________________________________________________
            # // | HCH: hClientHandle | IG: InterfaceGuid | CP: ConnectionParameters | PR: pReserved |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "[WiFi.ProfileManagement]::WlanConnect($HCH,$IG,$CP,$PR" | IEX
        }
        [String] WiFiReasonCode([IntPtr]$RC)
        {
            # // __________________
            # // | RC: ReasonCode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $SB          = [Text.StringBuilder]::New(1024)
            $result      = $This.WlanReasonCodeToString($RC.ToInt32(),$SB.Capacity,$SB,[IntPtr]::zero)

            If ($result -ne 0)
            {
                Return $This.Win32Exception($result)
            }

            Return $SB.ToString()
        }
        [IntPtr] NewWifiHandle()
        {
            # // ____________________________________________________________
            # // | MC: MaxClient | NV: NegotiatedVersion | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $MC       = 2
            [Ref] $NV = 0
            $CH       = [IntPtr]::zero
            $result   = $This.WlanOpenHandle($MC,[IntPtr]::Zero,$NV,[Ref]$CH)

            If ($result -eq 0)
            {
                Return $CH
            }
            Else
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Void] RemoveWifiHandle([IntPtr]$CH)
        {
            # // ____________________
            # // | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Result = $This.WlanCloseHandle($CH,[IntPtr]::zero)

            If ($Result -ne 0)
            {
                Throw $This.Win32Exception($Result)
            }
        }
        [Object] GetWiFiInterfaceGuid([String]$WFAN)
        {
            # // _____________________________________________________________________
            # // | WFAN: WiFiAdapterName | IG: InterfaceGuid | WFAI: WiFiAdapterInfo |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $IG   = $Null
            Switch ([Environment]::OSVersion.Version -ge [Version]6.2)
            {
                $True
                {
                    $IG   = Get-NetAdapter -Name $WFAN -EA 0 | % InterfaceGuid
                }
                $False
                {
                    $WFAI = Get-WmiObject Win32_NetworkAdapter | ? NetConnectionID -eq $WFAN
                    $IG   = Get-WmiObject Win32_NetworkAdapterConfiguration | ? { 

                        $_.Description -eq $WFAI.Name | % SettingID
                    }
                }
            }
    
            Return [System.Guid]$IG
        }
        [Object[]] GetWiFiInterface()
        {
            # // _____________________________________________________________________________________
            # // | IL: InterfaceListPtr | CH: ClientHandle | WFIL: WiFiInterfaceList | IF: Interface |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $IL            = 0
            $CH            = $This.NewWiFiHandle()
            $This.Adapters = $This.RefreshAdapterList()
            $Return        = @( )
            Try
            {
                [Void]$This.WlanEnumInterfaces($CH,[IntPtr]::zero,[ref]$IL)
                $WFIL = $This.WlanInterfaceList($IL)
                ForEach ($wlanInterfaceInfo in $WFIL.wlanInterfaceInfo)
                {
                    $Info      = $this.WlanInterfaceInfo($wlanInterfaceInfo)
                    $Interface = $This.Adapters | ? InterfaceDescription -eq $Info.Description
                    $Return   += [InterfaceObject]::New($Info,$Interface)
                }
            }
            Catch
            {
                Write-Host "No wireless interface(s) found"
                $Return += $Null
            }
            Finally
            {
                $This.RemoveWiFiHandle($CH)
            }

            Return @($Return)
        }
        [Object[]] GetWiFiProfileList([String]$Name)
        {
            # // ________________________________________________________________________________
            # // | PLP: ProfileListPointer | IF: Interface | CH: ClientHandle | PL: ProfileList |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $PLP    = 0
            $IF     = $This.GetWifiInterface() | ? Name -match $Name
            $CH     = $This.NewWifiHandle()
            $Return = @( )

            $This.WlanGetProfileList($CH,$IF.GUID,[IntPtr]::zero,[Ref]$PLP)
            
            $PL     = $This.WlanGetProfileListFromPtr($PLP)

            ForEach ($ProfileName in $PL)
            {
                $Item           = [WiFiProfile]::New($IF,$ProfileName)
                $Item.Detail    = $This.GetWiFiProfileInfo($Item.Name,$IF.Guid)
                $Return        += $Item
            }

            $This.RemoveWiFiHandle($CH)

            Return $Return
        }
        [Object] GetWiFiProfileInfo([String]$PN,[Guid]$IG,[Int16]$WPF)
        {
            # // __________________________________________________________________________________
            # // | PN: ProfileName | IG: InterfaceGuid | WPF: WlanProfileFlags | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            [IntPtr]$CH              = $This.NewWifiHandle()
            $WlanProfileFlagsInput   = $WPF
            $Return                  = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($CH)
            Return $Return
        }
        [Object] GetWifiProfileInfo([String]$PN,[Guid]$IG)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | IG: InterfaceGuid | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            [IntPtr]$CH            = $This.NewWifiHandle()
            $WlanProfileFlagsInput = 0
            $Return                = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
            $This.RemoveWiFiHandle($CH)
            Return $Return
        }
        [Object] WiFiProfileInfo([String]$PN,[Guid]$IG,[IntPtr]$CH,[Int16]$WPFI)
        {
            # // __________________________________________________________________________________
            # // | PN: ProfileName | IG: IntGuid | CH: ClientHandle | WPFI: WlanProfileFlagsInput |
            # // | PS: pstrProfileXml | WA: WlanAccess | WlanPF: WlanProfileFlags | PW: Password  | 
            # // | CHSSID: ConnectHiddenSSID | EAP: EapType | X: XmlPtr | SN: ServerNames         |
            # // | TRCA: TrustedRootCA | WP: WlanProfile
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            [String] $PS = $null
            $WA          = 0
            $WlanPF      = $WPFI
            $result      = $This.WlanGetProfile($CH,$IG,$PN,[IntPtr]::Zero,[Ref]$PS,[Ref]$WlanPF,[Ref]$WA)
            $PW          = $Null
            $CHSSID      = $Null
            $Eap         = $Null
            $xmlPtr      = $Null
            $SN          = $Null
            $TRCA        = $Null
            $Return      = $Null

            If ($result -ne 0)
            {
                Return $This.Win32Exception($Result)
            }

            $WP          = [Xml]$PS

            # // __________________
            # // | Parse password |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($WPFI -eq 13)
            {
                $PW      = $WP.WLANProfile.MSM.security.sharedKey.keyMaterial
            }
            If ($WPFI -ne 13)
            {
                $PW            = $Null
            }

            # // ___________________________
            # // | Parse nonBroadcast flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ([bool]::TryParse($WP.WLANProfile.SSIDConfig.nonBroadcast,[Ref]$null))
            {
                $CHSSID = [bool]::Parse($WP.WLANProfile.SSIDConfig.nonBroadcast)
            }
            Else
            {
                $CHSSID = $false
            }

            # // __________________
            # // | Parse EAP type |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($WP.WLANProfile.MSM.security.authEncryption.useOneX -eq $true)
            {
                $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.EapMethod.Type.InnerText | % { 

                    $EAP   = Switch ($_) { 13 { 'TLS'  } 25 { 'PEAP' }  Default { 'Unknown' } }
                                             # 13: EAP-TLS | 25: EAP-PEAP (MSCHAPv2)
                }
            }
            Else
            {
                $EAP = $null
            }

            # // ________________________________
            # // | Parse Validation Server Name |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (!!$Eap)
            {
                $Cfg = $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config 
                Switch ($Eap)
                {
                    PEAP
                    {

                        $SN   = $Cfg.Eap.EapType.ServerValidation.ServerNames
                    } 

                    TLS
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                        $SN   = $Node[0].InnerText
                    }
                }
            }

            # // __________________________________
            # // | Parse Validation TrustedRootCA |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (!!$EAP)
            {
                $Cfg = $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config
                Switch ($EAP)
                {
                    PEAP
                    {
                        $TRCA = $Cfg.Eap.EapType.ServerValidation.TrustedRootCA.Replace(' ','') | % ToLower
                    }
                    TLS
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $TRCA = $Node[0].InnerText.Replace(' ','') | % ToLower
                    }
                }
            }

            $Return                   = $This.WlanProfileInfoObject()
            $Return.ProfileName       = $WP.WlanProfile.SSIDConfig.SSID.name
            $Return.ConnectionMode    = $WP.WlanProfile.ConnectionMode
            $Return.Authentication    = $WP.WlanProfile.MSM.Security.AuthEncryption.Authentication
            $Return.Encryption        = $WP.WlanProfile.MSM.Security.AuthEncryption.Encryption
            $Return.Password          = $PW
            $Return.ConnectHiddenSSID = $CHSSID
            $Return.EAPType           = $EAP
            $Return.ServerNames       = $SN
            $Return.TrustedRootCA     = $TRCA
            $Return.Xml               = $PS

            $xmlPtr                   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($PS)
            $This.WlanFreeMemory($xmlPtr)

            Return $Return
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
        {
            # // ____________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType | F: Flag |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return $This.WifiConnectionParameter($PN,$CM,$D,$F)
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return $This.WifiConnectionParameter($PN,$CM,$D,"Default")
        }
        [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM)
        {
            # // ________________________________________
            # // | PN: ProfileName | CM: ConnectionMode |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return $This.WifiConnectionParameter($PN,$CM,"Any","Default")
        }
        [Object] GetWiFiConnectionParameter([String]$PN)
        {
            # // ___________________
            # // | PN: ProfileName |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return $This.WifiConnectionParameter($PN,"Profile","Any","Default")
        }
        [Object] WifiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
        {
            # // __________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
            # // | F: Flag | CMR: ConnectionModeResolver | P: Profile     |
            # // | CP: ConnectionParameters                               |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            Try
            {

                $CMR                   =  [ConnectionModeResolver]::New()

                $CP                    = $This.WlanConnectionParams()
                $CP.StrProfile         = $PN
                $CP.WlanConnectionMode = $This.WlanConnectionMode($CMR[$CM])
                $CP.Dot11BssType       = $This.WlanDot11BssType($D)
                $CP.dwFlags            = $This.WlanConnectionFlag($F)
            }
            Catch
            {
                Throw "An error occurred while setting connection parameters"
            }

            Return $CP
        }
        [Object] FormatXml([Object]$Content)
        {
            $StringWriter          = [System.IO.StringWriter]::New()
            $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
            $XmlWriter.Formatting  = "Indented"
            $XmlWriter.Indentation = 4
            ([Xml]$Content).WriteContentTo($XmlWriter)
            $XmlWriter.Flush()
            $StringWriter.Flush()
            Return $StringWriter.ToString()
        }
        [Object] XmlTemplate([UInt32]$Type)
        {
            $xList = (0,"Personal"),(1,"EapPeap"),(2,"EapTls") | % { "($($_[0]): $($_[1]))" }

            If ($Type -notin 0..2)
            {
                Throw "Select a valid type: [$($xList -join ", ")]"
            }
        
            $P = "http://www.microsoft.com/provisioning"
            
            $xProfile = Switch ($Type)
            {
                0 # WiFiProfileXmlPersonal
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                    '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                    'uthentication>'),'<encryption>{4}</encryption>','<useOneX>false</useOneX>',('</authEncry'+
                    'ption>'),'<sharedKey>','<keyType>passPhrase</keyType>','<protected>false</protected>',
                    '<keyMaterial>{5}</keyMaterial>','</sharedKey>','</security>','</MSM>',('<MacRandomizatio'+
                    'n xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">'),('<enableRandomization>'+
                    'false</enableRandomization>'),"</MacRandomization>",'</WLANProfile>'
                }
                1 # WiFiProfileXmlEapPeap
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>',('</SSIDConfig>'),'<connectionType>ESS</connectionType>',('<connectionMo'+
                    'de>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}<'+
                    '/authentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncr'+
                    'yption>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMK'+
                    'CacheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http'+
                    '://www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPC'+
                    'onfig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapH"+
                    "ostConfig'>25</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns"+
                    "='$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMe'+
                    'thod>'),"<Config xmlns='$P/EapHostConfig'>",("<Eap xmlns='$P/BaseEapConnectionProperties"+
                    "V1'>"),'<Type>25</Type>',"<EapType xmlns='$P/MsPeapConnectionPropertiesV1'>",('<ServerVa'+
                    'lidation>'),('<DisableUserPromptForServerValidation>false</DisableUserPromptForServerVal'+
                    'idation>'),'<ServerNames></ServerNames>','<TrustedRootCA></TrustedRootCA>',('</ServerVal'+
                    'idation>'),'<FastReconnect>true</FastReconnect>',('<InnerEapOptional>false</InnerEapOpti'+
                    'onal>'),"<Eap xmlns='$P/BaseEapConnectionPropertiesV1'>",'<Type>26</Type>',("<EapType xm"+
                    "lns='$P/MsChapV2ConnectionPropertiesV1'>"),('<UseWinLogonCredentials>false</UseWinLogonC'+
                    'redentials>'),'</EapType>','</Eap>',('<EnableQuarantineChecks>false</EnableQuarantineChe'+
                    'cks>'),'<RequireCryptoBinding>false</RequireCryptoBinding>','<PeapExtensions>',("<Perfor"+
                    "mServerValidation xmlns='$P/MsPeapConnectionPropertiesV2'>true</PerformServerValidation>"+
                    ""),"<AcceptServerName xmlns='$P/MsPeapConnectionPropertiesV2'>true</AcceptServerName>",
                    "<PeapExtensionsV2 xmlns='$P/MsPeapConnectionPropertiesV2'>",("<AllowPromptingWhenServerC"+
                    "ANotFound xmlns='$P/MsPeapConnectionPropertiesV3'>true</AllowPromptingWhenServerCANotFou"+
                    "nd>"),'</PeapExtensionsV2>','</PeapExtensions>','</EapType>','</Eap>','</Config>',('</Ea'+
                    'pHostConfig>'),'</EAPConfig>','</OneX>','</security>','</MSM>',('<MacRandomization xmlns'+
                    '="http://www.microsoft.com/networking/WLAN/profile/v3">'),("<enableRandomization>false</"+
                    "enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
                }
                2 # WiFiProfileXmlEapTls
                {
                    '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                    'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                    'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                    '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                    'uthentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncryp'+
                    'tion>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMKCa'+
                    'cheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http:/'+
                    '/www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPCon'+
                    'fig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapHos"+
                    "tConfig'>13</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns='"+
                    "$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMeth'+
                    'od>'),("<Config xmlns:baseEap='$P/BaseEapConnectionPropertiesV1' xmlns:eapTls='$P/EapTls"+
                    "ConnectionPropertiesV1'>"),'<baseEap:Eap>','<baseEap:Type>13</baseEap:Type>',('<eapTls:E'+
                    'apType>'),'<eapTls:CredentialsSource>','<eapTls:CertificateStore />',('</eapTls:Credenti'+
                    'alsSource>'),'<eapTls:ServerValidation>',('<eapTls:DisableUserPromptForServerValidation>'+
                    'false</eapTls:DisableUserPromptForServerValidation>'),('<eapTls:ServerNames></eapTls:Ser'+
                    'verNames>'),'<eapTls:TrustedRootCA></eapTls:TrustedRootCA>','</eapTls:ServerValidation>',
                    '<eapTls:DifferentUsername>false</eapTls:DifferentUsername>','</eapTls:EapType>',('</base'+
                    'Eap:Eap>'),'</Config>','</EapHostConfig>','</EAPConfig>','</OneX>','</security>','</MSM>',
                    '<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',("<enabl"+
                    "eRandomization>false</enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
                }
            }
        
            Return $This.FormatXml($xProfile)
        }
        [String] Hex([String]$PN)
        {
            # // ___________________
            # // | PN: ProfileName |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return ([Char[]]$PN | % { '{0:X}' -f [Int]$_ }) -join ''
        }
        [String] NewWiFiProfileXmlPsk([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                      [SecureString]$PW)
        {
            # // ___________________________________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | PW: Password |
            # // | PP: PlainPassword | PX: ProfileXml | SS: SecureStringToBstr | RN: RefNode | XN: XmlNode | 
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $PP           = $Null
            $PX           = $Null
            $Hex          = $This.Hex($PN)
            Try
            {
                If ($PW)
                {
                    $SS   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PW)
                    $PW   = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SS)
                }
                
                $PX       = [XML]($This.XmlTemplate(0) -f $PN, $Hex, $CM, $A, $E, $PP)
                If (!$PP)
                {
                    $Null = $PX.WLANProfile.MSM.security.RemoveChild($PX.WLANProfile.MSM.security.sharedKey)
                }

                If ($A -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $N  = [System.Xml.XmlNamespaceManager]::new($PX.NameTable)
                    $N.AddNamespace('WLANProfile',$PX.DocumentElement.GetAttribute('xmlns'))
                    $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                    $XN = $PX.CreateElement('transitionMode', 
                                            'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XN.InnerText = 'True'
                    $null         = $RN.AppendChild($XN)
                }

                Return $This.FormatXml($PX.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [String] NewWifiProfileXmlEap([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                      [String]$Eap,[String[]]$SN,[String]$TRCA)
        {
            # // ___________________________________________________________________________________________
            # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | EAP: EapType |
            # // | SN: ServerNames | TRCA: TrustedRootCa | PX: ProfileXml |  RN: RefNode | XN: XmlNode     | 
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Px  = $Null
            $Hex = $This.Hex($PN)
            Try
            {
                If ($Eap -eq 'PEAP')
                {
                    $Px = [Xml]($This.XmlTemplate(1) -f $PN, $Hex, $CM, $A, $E)
                    $Cfg = $PX.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config

                    If ($SN)
                    {
                        $Cfg.Eap.EapType.ServerValidation.ServerNames = $SN
                    }

                    If ($TRCA)
                    {
                        $Cfg.Eap.EapType.ServerValidation.TrustedRootCA = $TRCA.Replace('..','$& ')
                    }
                }
                ElseIf ($Eap -eq 'TLS')
                {
                    $PX  = [Xml]($This.XmlTemplate(2) -f $PN, $Hex, $CM, $A, $E)
                    $Cfg = $PX.WLANProfile.MSM.security.OneX.EapConfig.EapHostConfig.Config

                    If ($SN)
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                        $Node[0].InnerText = $SN
                    }

                    If ($TRCA)
                    {
                        $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                        $Node[0].InnerText = $TRCA.Replace('..','$& ')
                    }
                }

                If ($A -eq 'WPA3SAE')
                {
                    # // ____________________________________________
                    # // | Set transition mode as true for WPA3-SAE |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $N = [System.Xml.XmlNamespaceManager]::new($PX.NameTable)
                    $N.AddNamespace('WLANProfile', $PX.DocumentElement.GetAttribute('xmlns'))
                    $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                    $XN = $PX.CreateElement('transitionMode', 'http://www.microsoft.com/networking/WLAN/profile/v4')
                    $XN.InnerText = 'true'
                    $null = $RN.AppendChild($XN)
                }

                Return $This.FormatXml($PX.OuterXml)
            }
            Catch
            {
                Throw "Failed to create a new profile"
            }
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $CM = 'auto'
            $A  = 'WPA2PSK'
            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$PW)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $A  = 'WPA2PSK'
            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$WFAN)
        {
            # // _______________________________________________________________________________
            # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
            # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $E  = 'AES'
            $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$E,[String]$WFAN)
        {
            # // ___________________________________________________________________________
            # // | PN: ProfileName | PW: Password | CM: ConnectionMode | A: Authentication |
            # // | E: Encryption | WFAN: WiFiAdapterName | PT: ProfileTemp                 |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $PT     = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $CM   = 'Auto'
            $A    = 'WPA2PSK'
            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $A    = 'WPA2PSK'
            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $E    = 'AES'
            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$EAP,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $SN   = ''
            $TRCA = $Null
            $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                                   [String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $TRCA     = $Null
            $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                                   [String]$TRCA,[String]$WFAN)
        {
            # // ________________________________________________________________________________
            # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
            # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
            # // | PT: ProfileTemp                                                              |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
            Return $This.NewWifiProfile($PT,$WFAN)
        }
        [Object] NewWifiProfileXml([String]$PX,[String]$WFAN,[Bool]$O)
        {
            # // _________________________________________________________
            # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Return $This.NewWifiProfile($PX,$WFAN)
        }
        NewWifiProfile([String]$PX,[String]$WFAN,[Bool]$O)
        {
            # // _____________________________________________________________________________
            # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite | IG: InterfaceGuid |
            # // | CH: ClientHandle | F: Flags | PP: ProfilePointer                          |
            # // | RSC: ReasonCode | RSCM: ReasonCodeMessage                                 |
            # // | RTC: ReturnCode | RTCM: ReturnCodeMessage                                 |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Try
            {
                $IG   = $This.GetWiFiInterfaceGuid($WFAN)
                $CH   = $This.NewWiFiHandle()
                $F    = 0
                $RSC  = [IntPtr]::Zero
                $PP   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($PX)    
                $RTC  = $This.WlanSetProfile($CH,[Ref]$IG,$F,$PP,[IntPtr]::Zero,$O,[IntPtr]::Zero,[Ref]$RSC)
                $RTCM = $This.Win32Exception($RTC)
                $RSCM = $This.WiFiReasonCode($RSC)

                If ($RTC -eq 0)
                {
                    Write-Verbose -Message $RTCM
                }
                Else
                {
                    Throw $RTCM
                }

                Write-Verbose -Message $RSCM
            }
            Catch
            {
                Throw "Failed to create the profile"
            }
            Finally
            {
                If ($CH)
                {
                    $This.RemoveWiFiHandle($CH)
                }
            }
        }
        RemoveWifiProfile([String]$PN)
        {
            # // ______________________________________
            # // | PN: ProfileName | CH: ClientHandle |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $CH = $This.NewWiFiHandle()
            $This.WlanDeleteProfile($CH,[Ref]$This.Selected.Guid,$PN,[IntPtr]::Zero)
            $This.RemoveWifiHandle($CH)
        }
        Select([String]$D)
        {
            # // __________________
            # // | D: Description |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            # // ___________________________________________
            # // | Select the adapter from its description |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Selected = $This.GetWifiInterface() | ? Description -eq $D
            $This.Update()
        }
        Unselect()
        {
            $This.Selected = $Null
            $This.Update()
        }
        Disconnect()
        {
            If (!$This.Selected)
            {
                Write-Host "No network selected"
            }
            If ($This.Selected.State -eq "CONNECTED")
            {
                $CH                      = $This.NewWiFiHandle()
                $This.WlanDisconnect($CH,[Ref]$This.Selected.Guid,[IntPtr]::Zero)
                $This.RemoveWifiHandle($CH)

                $This.Connected                    = $Null

                $Splat                             = @{

                    Type    = "Image"
                    Mode    = 2
                    Image   = $This.OEMLogo
                    Message = "Disconnected: $($This.Selected.SSID)"
                }

                Show-ToastNotification @Splat

                $Link                              = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)
            }
        }
        Connect([String]$SSID)
        {
            If (!$This.Selected)
            {
                Write-Host "Must select an active interface"
            }

            If ($This.Selected)
            {
                $Link                              = $This.Selected.Description
                $This.Unselect()
                $This.Select($Link)

                If ($This.Selected.State -ne "CONNECTED")
                {
                    $Result = $This.GetWifiProfileInfo($SSID,$This.Selected.Guid)
                    If ($Result)
                    {
                        $Param = $This.GetWiFiConnectionParameter($SSID)
                        $CH    = $This.NewWiFiHandle()
                        $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                        $This.RemoveWifiHandle($CH)

                        $Link   = $This.Selected.Description
                        $This.Unselect()
                        $This.Select($Link)
                        
                        $This.Update()

                        $Splat                             = @{

                            Type    = "Image"
                            Mode    = 2
                            Image   = $This.OEMLogo
                            Message = "Connected: $SSID"
                        }

                        Show-ToastNotification @Splat
                    }
                    If (!$Result)
                    {
                        $Network = $This.Output.SelectedItem
                        If ($Network.Authentication -match "psk")
                        {
                            $This.Passphrase($Network)
                        }
                        Else
                        {
                            Write-Host "Eas/Peap not yet implemented"
                        }
                    }
                }
            }
        }
        Passphrase([Object]$NW)
        {
            $PW    = Read-Host -AsSecureString -Prompt "Enter passphrase for Network: [$($NW.SSID)]"
            $A     = $Null
            $E     = $Null

            If ($NW.Authentication -match "RsnaPsk")
            {
                $A = "WPA2PSK"
            }
            If ($NW.Encryption -match "Ccmp")
            {
                $E = "AES"
            }

            $PX    = $This.NewWifiProfileXmlPsk($NW.Name,"Manual",$A,$E,$PW)
            $This.NewWifiProfile($PX,$This.Selected.Name,$True)
                
            $Param = $This.GetWiFiConnectionParameter($NW.Name)
            $CH    = $This.NewWiFiHandle()
            $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
            $This.RemoveWifiHandle($CH)

            Start-Sleep 3
            $Link  = $This.Selected.Description
            $This.Unselect()
            $This.Select($Link)

            $This.Update()
            If ($This.Connected)
            {
                $Splat                             = @{

                    Type    = "Image"
                    Mode    = 2
                    Image   = $This.OEMLogo
                    Message = "Connected: $($NW.Name)"
                }

                Show-ToastNotification @Splat
            }
            If (!$This.Connected)
            {
                $This.RemoveWifiProfile($NW.Name)

                $Splat                             = @{

                    Type    = "Image"
                    Mode    = 2
                    Image   = $This.OEMLogo
                    Message = "Unsuccessful: Passphrase failure"
                }
                Show-ToastNotification @Splat
            }
        }
        Update()
        {
            "Determine/Set connection state" | Write-Comment -I 12 | Set-Clipboard
            Switch -Regex ($This.Selected.Status)
            {
                Up
                {
                    $This.Connected = $This.NetshShowInterface($This.Selected.Name)
                }
                Default
                {
                    $This.Connected = $Null
                }
            }
        }
        Wireless()
        {
            # // ____________________________
            # // | Load the module location |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Module  = Get-FEModule
            $This.OEMLogo = $This.Module.Graphics | ? Name -eq OEMLogo.bmp | % Fullname

            # // __________________________
            # // | Load the runtime types |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            ForEach ($X in "","AccessStatus","State")
            { 
                $Item = "[Windows.Devices.Radios.Radio$X, Windows.System.Devices, ContentType=WindowsRuntime]"
                "$Item > `$Null" | Invoke-Expression
            }

            # // _______________________________________
            # // | Get access to any wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Adapters = $This.RefreshAdapterList()

            # // __________________________________________
            # // | Throw if no existing wireless adapters |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Adapters.Count -eq 0)
            {
                Throw "No existing wireless adapters on this system"
            }

            # // ___________________________
            # // | Requesting Radio Access |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Request = $This.RadioRequestAccess()
            $This.Request.Wait(-1) > $Null

            # // _______________________________________
            # // | Throw if unable to ascertain access |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Request.Result -ne "Allowed")
            {
                Throw "Unable to request radio access"
            }

            # // ___________________________________
            # // | Establish radio synchronization |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Radios = $This.RadioSynchronization()
            $This.Radios.Wait(-1) > $Null

            # // _________________________________________
            # // | Throw if unable to synchronize radios |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (!($This.Radios.Result | ? Kind -eq WiFi))
            {
                Throw "Unable to synchronize wireless radio(s)"
            }

            $This.Refresh()
        }
        [Object[]] RefreshAdapterList()
        {
            Return Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)"
        }
        Scan()
        {
            $This.List   = @( )
            $This.Output = @( )

            [Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime] > $Null
            $This.List   = $This.RadioFindAllAdaptersAsync()
            $This.List.Wait(-1) > $Null
            $This.List.Result

            $This.List.Result.NetworkReport.AvailableNetworks | % {

                $This.Output += [Ssid]::New($This.Output.Count,$_) 
            }

            $This.Output = $This.Output | Sort-Object Strength -Descending
            Switch ($This.Output.Count)
            {
                {$_ -gt 1}
                { 
                    ForEach ($X in 0..($This.Output.Count-1))
                    {
                        $This.Output[$X].Index = $X
                    }
                }
                {$_ -eq 1}
                {
                    $This.Output[0].Index = 0
                }
                {$_ -eq 0}
                {
                    Throw "No networks detected"
                }
            }
        }
        Refresh()
        {
            Start-Sleep -Milliseconds 150
            $This.Scan()

            Write-Progress -Activity Scanning -Status Starting -PercentComplete 0  

            $C = 0
            $This.Output | % { 
                
                $Status  = "($C/$($This.Output.Count-1)"
                $Percent =  ([long]($C * 100 / $This.Output.Count))

                Write-Progress -Activity Scanning -Status $Status -PercentComplete $Percent
                
                $C ++
            }

            Write-Progress -Activity Scanning -Status Complete -Completed
            Start-Sleep -Milliseconds 50
        }
    }

    # // ________________________________________________________________________________
    # // | Alright, so now it is time to capture the class a process it into an object. |
    # // | Here we go.                                                                  |
    # // | Go ahead and capture the [Wireless] class to a variable named $Wifi          |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $WiFi = [Wireless]::New()

    # // ___________________________________________________________________________________________
    # // | If the device you're using has wirelss radios in it...? You probably just saw the       |
    # // | Write-Progress function calculate all of the available wireless networks nearby.        |
    # // |                                                                                         |
    # // | Don't take my word for it... let's test the output.                                     |
    # // | What do we get back from this object if we start playing around with it in the console? |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________________________________________________________
    # // | PS Prompt:\> $Wifi                                                                                         |
    # // | Adapters  : {MSFT_NetAdapter (CreationClassName = "MSFT_NetAdapter", DeviceID = "{E3A47A46-9920-469E-99... |
    # // | Request   : System.Threading.Tasks.Task1[Windows.Devices.Radios.RadioAccessStatus]                         |
    # // | Radios    : System.Threading.Tasks.Task1[System.Collections.Generic.IReadOnlyList1[Windows.Devices.Ra...   |
    # // | List      : System.Threading.Tasks.Task1[System.Collections.Generic.IReadOnlyList1[Windows.Devices.Wi...   |
    # // | Output    : {, , Market 32, ...}                                                                           |
    # // | Selected  :                                                                                                |
    # // | Connected :                                                                                                |
    # // |                                                                                                            |
    # // | PS Prompt:\>                                                                                               |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ________________________________________________________________________________________
    # // | Well, that's a fair amount of information right there at our fingertips.             |
    # // | To be blunt, the information we want to see is in the property, Output               |
    # // | If we access that property, we will see a list that has items that look like this... |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ________________________________________
    # // | PS Prompt:\> $WiFi.Output            |
    # // |                                      |
    # // | Index            : 0                 |
    # // | Name             :                   |
    # // | Bssid            : 8A:15:04:A2:44:F4 |
    # // | Type             : 802.11n           |
    # // | Uptime           : 11h 22m 41s 027   |
    # // | NetworkType      : Infrastructure    |
    # // | Authentication   : Rsna              |
    # // | Encryption       : Ccmp              |
    # // | Strength         : 3                 |
    # // | BeaconInterval   : 00:00:00.1024000  |
    # // | ChannelFrequency : 2437000           |
    # // | IsWifiDirect     : False             |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _____________________________________________________________________
    # // | Now, there are many other entries in this particular list, but... |
    # // | The LIST format doesn't show them all the best way.               |
    # // |                                                                   |
    # // | So let's try to use $WiFi.Output | Format-Table                   |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ________________________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $Wifi.Output | Format-Table                                                                     |
    # // | Index Name               Bssid             Type     Uptime              Netw. Auth.     Enc. Str. Beacon Int |
    # // | ----- ----               -----             ----     ------              ----- --------- ---- ---- ---------- |
    # // |     0                    8A:15:04:A2:44:F4 802.11n  11h 22m 41s 027     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     1                    8A:15:04:A2:44:F7 802.11n  11h 22m 41s 028     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     2                    8A:15:04:A2:44:F3 802.11n  11h 22m 41s 027     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     3                    8A:15:04:A2:44:FF 802.11n  11h 22m 41s 024     Infr. Open80211 Wep     3 00:00:00~  |
    # // |     4 Market 32          8A:15:04:A2:44:F0 802.11n  11h 22m 40s 981     Infr. Open80211 None    3 00:00:00~  |
    # // |     5                    8A:15:04:A2:E3:44 802.11n  19h 38m 30s 275     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     6                    8A:15:04:A2:96:5F 802.11n  2d 13h 57m 15s 904  Infr. Open80211 Wep     3 00:00:00~  |
    # // |     7                    8A:15:04:A2:F0:27 802.11n  4d 08h 11m 17s 380  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     8                    8A:15:04:A2:CC:37 802.11n  1d 09h 05m 17s 111  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |     9                    8A:15:04:A2:44:F6 802.11n  11h 22m 41s 027     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    10 Market 32          8A:15:04:A3:A8:10 802.11n  1d 07h 30m 06s 865  Infr. Open80211 None    3 00:00:00~  |
    # // |    11 HP-Print-71-Off... 80:CE:62:93:8B:71 Unknown  10d 04h 27m 11s 766 Infr. RsnaPsk   Ccmp    3 00:00:00~  |
    # // |    12                    8A:15:04:A3:B7:13 802.11n  2d 07h 17m 33s 111  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    13                    8A:15:04:A3:B7:14 802.11n  2d 07h 17m 33s 111  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    14                    8A:15:04:A3:B7:1F 802.11n  2d 07h 17m 33s 108  Infr. Open80211 Wep     3 00:00:00~  |
    # // |    15 Market 32          8A:15:04:A3:B7:10 802.11n  2d 07h 17m 33s 029  Infr. Open80211 None    3 00:00:00~  |
    # // |    16                    8A:15:04:A3:B7:11 802.11n  2d 07h 17m 33s 110  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    17                    8A:15:04:A2:E3:4F 802.11n  19h 38m 30s 886     Infr. Open80211 Wep     3 00:00:00~  |
    # // |    18                    8A:15:04:A2:E3:46 802.11n  19h 38m 30s 275     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    19                    8A:15:04:A2:44:F1 802.11n  11h 22m 41s 026     Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    20                    8A:15:04:A3:B7:16 802.11n  2d 07h 17m 33s 111  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    21                    8A:15:04:A3:B7:17 802.11n  2d 07h 17m 33s 112  Infr. Rsna      Ccmp    3 00:00:00~  |
    # // |    22 Marks Car          00:6F:F2:31:0E:66 802.11n  00h 29m 23s 581     Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |    23 JOY                E4:71:85:17:7C:80 802.11n  37d 05h 07m 17s 427 Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |    24 MarksAutomotive... E6:F4:C6:08:DA:43 802.11n  6d 23h 33m 16s 214  Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |    25                    00:30:44:39:FC:01 802.11n  15h 29m 38s 201     Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |    26                    8A:15:04:A2:E3:40 802.11n  19h 38m 30s 274     Infr. Open80211 None    2 00:00:00~  |
    # // |    27 TheShop            C0:56:27:3D:6D:F4 802.11ac 37d 05h 07m 35s 966 Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |    28 DIRECT-epson-se... E2:BB:9E:56:AC:F4 802.11n  1d 07h 08m 19s 032  Infr. RsnaPsk   Ccmp    2 00:00:00~  |
    # // |______________________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    # // _________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Sorta looks like I know what I'm doing, doesn't it...?                        |
    # // | There's plenty more that can be done with this particular radio class.        |
    # // |                                                                               |
    # // | The point of this, is to exhibit the following statement:                     |
    # // | I'm an actual expert who knows what he is doing/saying.                       |
    # // |     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                        |
    # // | Sometimes I even know how to EXPOSE people who either KNOW they're lying...   |
    # // | ...or DON'T KNOW they're lying. That's the quality that causes me to be...    |
    # // | ...a CUT ABOVE THE REST.                                                      |
    # // |                                                                               |
    # // | Before I came along...? You had people giving each other high fives, a real   |
    # // | comfortable pat on the back, or a thumbs up. George W. Bush inspired Facebook |
    # // | and Google to adopt the "thumbs up" button, as a direct result of this:       |
    # // |                                                                               |
    # // | [Mission Accomplished]                                                        |
    # // | 05/01/03 | https://drive.google.com/file/d/1EDBRJHxcPKOkbJ75hfPik7rxD2zERtt3  |
    # // |                                                                               |
    # // | I realize that some people will look at that picture or read my commentary,   |
    # // | and they'll just casually pretend as if they don't see how much sense I make, |
    # // | in THAT PICTURE, as well as the rest of the lesson plan, and the videos that  |
    # // | some guys talk about in the following dialog...                               |
    # // |_______________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Guy[1]: Maybe if we just pretend like we can't HEAR him, he'll go away.       |
    # // | Guy[2]: That is a splendid plan, Guy[1].                                      |
    # // | Guy[1]: Heh heh heh...                                                        |
    # // |         Indubitubly, my good friend...                                        |
    # // |         Indubitubly indeed.                                                   |
    # // | Guy[2]: Yeah, well...                                                         |
    # // |         This dude would have to have like THOUSANDS of videos to catch US.    |
    # // |         https://youtu.be/LfZW-s0BMow                                          |
    # // | Guy[1]: Heh heh heh...                                                        |
    # // |         You basically read my mind there, Guy[2].                             |
    # // | Guy[3]: What the hell are you guys talking about...?                          |
    # // | Guy[2]: Heh, this MICHAEL C. COOK SR. from CLIFTON PARK, NY...                |
    # // |         Thinks he's hot s***.                                                 |
    # // | Guy[1]: Yeh, LOL.                                                             |
    # // |         Dude doesn't even have his CISCO CERTIFICATIONS...                    |
    # // | Guy[3]: What exactly is this video, anyway...?                                |
    # // |         https://youtu.be/LfZW-s0BMow                                          |
    # // | Guy[1]: Oh, it's this MICHAEL C. COOK SR. guy from CLIFTON PARK, NY...        |
    # // |         Trying to go around teaching people how to reset a cable modem.       |
    # // |         And like, managing the CLIFTON PARK COMPUTER ANSWERS shop.            |
    # // | Guy[3]: He looks like he's quite the professional...                          |
    # // |         He knows how to use IPCONFIG.                                         |
    # // | Guy[1]: Yeah, but look at how messy the shop is in the background...          |
    # // |         THAT AUTOMATICALLY MEANS, what he's sayin' is stupid.                 |
    # // |         And, so is HE.                                                        |
    # // | Guy[2]: Yyyyyyyyyyup.                                                         |
    # // |         Dude needs to go back in time to when he recorded this video...?      |
    # // |         And then just clean the shop and make the video AGAIN.                |
    # // |         THEN he would have our respect...                                     |
    # // |         So...                                                                 |
    # // | Guy[3]: ...are you serious...?                                                |
    # // | Guy[1]: Yep.                                                                  |
    # // | Guy[2]: Absolutely.                                                           |
    # // |         Can't go around calling yourself an expert if stuff isn't organized.  |
    # // | Guy[3]: What about this video...?                                             |
    # // |         https://youtu.be/0nEiGijjOEY                                          |
    # // | Guy[1]: WOW.                                                                  |
    # // |         Dude goes around wearing a vest and stuff...?                         |
    # // |         That's pretty dumb.                                                   |
    # // | Guy[2]: It is pretty dumb, isn't it...?                                       |
    # // | Guy[3]: Did your like, mom and dad teach you that wearing a vest and managing |
    # // |         network equipment is dumb...?                                         |
    # // | Guy[1]: Uh, no.                                                               |
    # // | Guy[2]: ...                                                                   |
    # // | Guy[3]: Guy[2]...?                                                            |
    # // | Guy[2]: Yeah man, my mom and dad DID teach me that stuff is dumb.             |
    # // | Guy[3]: Wow.                                                                  |
    # // |         You know...                                                           |
    # // |         *wearing a vest* I'm wearin' a black vest that looks like-            |
    # // | Guy[1]: ...the one he's wearing in that video...                              |
    # // | Guy[2]: ...                                                                   |
    # // | Guy[3]: So, you think I've ALWAYS looked pretty dumb in this vest that        |
    # // |         I wear all the time, huh...?                                          |
    # // | Guy[2]: ...                                                                   |
    # // | Guy[3]: Wow, dude.                                                            |
    # // |         *shaking head, walking away* Unbelievable...                          |
    # // |_______________________________________________________________________________|
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Look, that's a fictional skit that I just made up on the fly.                 |
    # // | I'm not sure if that's READILY APPARENT with some of my rhetoric...?          |
    # // | But, I gotta TRY and make the MATERIAL interesting to read.                   |
    # // |                                                                               |
    # // | Believe it or not, but there ARE some experts in the field, that do this too. |
    # // | For instance, Kevlin Henney, Robert Sopolsky, Jeremy Rifkin, Jordan Peterson, |
    # // | they're not ALL professors, however, they all have INTERESTING CONJECTURE, or |
    # // | RHETORIC. Perhaps they may not write up fictional stories like I do, but that |
    # // | is just a technique that I like to use, as it is part of my STYLE.            |
    # // |_______________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ___________________________________________________________________________________
    # // | I just mentioned a bunch of really cool dudes who happen to be experts at:      |
    # // | knowing what the hell they're (saying/doing).                                   |
    # // |                                                                                 |
    # // | Kevlin Henney has a series of videos that I've seen once upon a time...         |
    # // | one of the most notable is this one in particular, about the ol' FizzBuzz game. |
    # // | https://youtu.be/LueeMTTDePg?t=645                                              |
    # // |                                                                                 |
    # // | Here is the code in that specific video at that specific time...                |
    # // |                                                                                 |
    # // | # // C Sharp | Verbatim                                                         |
    # // | for (var i = 1; 1 <= 100; i++) {                                                |
    # // |     // For each iteration,                                                      |
    # // |     // initialize an empty string                                               |
    # // |     var string = '';                                                            |
    # // |                                                                                 |
    # // |     // If 'i' is divisible through 3                                            |
    # // |     // without a rest, append 'Fizz'                                            |
    # // |     if (i % 3 == 0) {                                                           |
    # // |         string += 'Fizz';                                                       |
    # // |     }                                                                           |
    # // |                                                                                 |
    # // |     // If 'i' is divisible through 5                                            |
    # // |     // without a rest, append 'Buzz'                                            |
    # // |     if (i % 5 == 0) {                                                           |
    # // |         string += 'Buzz';                                                       |
    # // |     }                                                                           |
    # // |                                                                                 |
    # // |     // If 'string is still empty,                                               |
    # // |     // 'i' is not divisible by 3 or 5,                                          |
    # // |     // so use the number instead                                                |
    # // |     if (string == '') {                                                         |
    # // |         string += i;                                                            |
    # // |     }                                                                           |
    # // |                                                                                 |
    # // |     // At the end of this iteration, print the string                           |
    # // |     console.log(string);                                                        |
    # // | }                                                                               |
    # // |                                                                                 |
    # // | Before I continue with the lesson plan, I'm going to CONVERT all of             |
    # // | that C Sharp into PowerShell, since it's basically the same thing.              |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _______________________________________________________________________________________________
    # // | Now I'm about to take things to the next level by making this thing far more complicated,   |
    # // | but also...? More manageable, and able to be interacted with, as well as providing a        |
    # // | Write-Progress indicator, so that people can throw whatever number they want at this thing. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________________________________________________
    # // | This right here, is your regular, ordinary, every-day-at-the-park, standard-issue FizzBuzz object. |
    # // | Basically, the console output is saved here, and each object will calculate whether it is:         |
    # // | 1) a Fizz object,                                                                                  |
    # // | 2) a Buzz object,                                                                                  |
    # // | 3) a Fizz Buzz object,                                                                             |
    # // | 4) or a number if it's none of those objects/items...                                              |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FizzBuzzObject
    {
        [UInt32] $Index
        [String] $String
        FizzBuzzObject([UInt32]$Index)
        {
            $This.Index   = $Index
            $This.String += @( Switch ($Index)
            {
                {$_ % 3 -eq 0} { "Fizz" } {$_ % 5 -eq 0} { "Buzz" } Default { $Index }
            })
        }
        [String] ToString()
        {
            Return $This.String
        }
    } 

    # // _____________________________________________________________________________________________________
    # // | This is basically a stacking of the chips, a container for each individual FizzBuzzObject.        |
    # // | With it, you can totally mess up some bad guy's days... without putting a lot of thought into it. |
    # // |                                                                                                   |
    # // | In all seriousness, this keeps track of total, depth, and the output.                             |
    # // | You can ALSO insert a number that is HIGHER or LOWER than 100 (but no less than 1)                |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FizzBuzzContainer
    {
        [UInt32] $Total
        [UInt32] $Depth
        [Object] $Output
        FizzBuzzContainer([UInt32]$Total)
        {
            If ($Total -le 1)
            {
                Throw "Must provide a total higher than 1"
            }
            
            $This.Total    = $Total
            $This.Depth    = ([String]$Total).Length
            $Stage         = [Math]::Round($Total/20)
            $Slot          = 0..($Total) | ? { $_ % $Stage -eq 0 }
            $Slot[-1]      = $Total
            $Hash          = @{ }

            Write-Progress -Activity "Calc. [FizzBuzz]" -Status $This.Status(0) -PercentComplete 0
            ForEach ($X in 1..$Total)
            { 
                $Hash.Add($Hash.Count,[FizzBuzzObject]::New($X))
                If ($X -in $Slot)
                {
                    Write-Progress -Activity "Calc." -Status $This.Status($X) -PercentComplete $This.Percent($X)
                }
            }
            Write-Progress -Activity "Calc. [FizzBuzz]" -Status $This.Status($This.Total) -Complete

            $This.Output = $Hash[0..($Hash.Count-1)]
        }
        [String] Status([UInt32]$Rank)
        {
            Return "({0:d$($This.Depth)}/$($This.Total))" -f $Rank
        }
        [Double] Percent([UInt32]$Rank)
        {
            Return ($Rank*100)/$This.Total
        }
        [Object[]] Factor([UInt32]$Mode)
        {
            If ($Mode -notin 0,1)
            {
                Throw "Invalid mode"
            }

            Return @( Switch ($Mode)
            {
                0 { $This.Output | ? String -notmatch \d+ } 1 { $This.Output | ? String -match \d+ }
            
            })
        }
    }

    # // ________________________________________________________________________________________
    # // | Lets instantiate this PowerShell representation of Kevlin Henney's C# code.          |
    # // | Might not have been HIS, but it's whatever.                                          |
    # // |                                                                                      |
    # // | I'm pretty sure that the original author won't care if I EXAMINE it.                 |
    # // | If they do...? Well, feel free to get a hold of me, and I will take this educational |
    # // | lesson on the sacred Fizz Buzz object, offline.                                      |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $List = [FizzBuzzContainer]::New(10000)

    # // ________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $List = [FizzBuzzContainer]::New(10000) |
    # // | PS Prompt:\> $List                                   |
    # // |                                                      |
    # // | Total Depth Output                                   |
    # // | ----- ----- ------                                   |
    # // | 10000     5 {1, 2, Fizz, 4...}                       |
    # // |                                                      |
    # // | PS Prompt:\>                                         |
    # // |______________________________________________________|
    # // 
    

    # // ______________________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $WiFi                                                                                         |
    # // |                                                                                                            |
    # // | Adapters  : {MSFT_NetAdapter (CreationClassName = "MSFT_NetAdapter", DeviceID = "{E3A47A46-9920-469E-9...} |
    # // | Request   : System.Threading.Tasks.Task`1[Windows.Devices.Radios.RadioAccessStatus]                        |
    # // | Radios    : System.Threading.Tasks.Task`1[System.Collections.Generic.IReadOnlyList`1[Windows.Devices.R...  |
    # // | List      : System.Threading.Tasks.Task`1[System.Collections.Generic.IReadOnlyList`1[Windows.Devices...    |
    # // | Output    : {Subway, SubSecure, Uncommon Grounds, SKMW...}                                                 |
    # // | Selected  :                                                                                                |
    # // | Connected :                                                                                                |
    # // |                                                                                                            |
    # // | PS Prompt:\>                                                                                               |
    # // |____________________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ________________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $WiFi.Adapters                                                                          |
    # // |                                                                                                      |
    # // | Name   InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed |
    # // | ----   --------------------                    ------- ------       ----------             --------- |
    # // | Wi-Fi  1x1 11bgn Wireless LAN PCI Express H...      22 Disconnected 9C-B7-0D-20-08-FE        72 Mbps |
    # // |______________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // __________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | So, this is covering an adapter in my laptop which isn't integrated into the motherboard.      |
    # // | That means at any time, I can swap it out with another wireless adapter and not have to worry. |
    # // |                                                                                                |
    # // | Doesn't necessarily mean that I'm PARANOID and feel a need to swap out the WiFi adapter...     |
    # // | ...I'm just saying, with a SMARTPHONE that MOST PEOPLE HAVE...                                 |
    # // | Then, uh-oh. Chances are, if someone's got your MAC ADDRESS...?                                |
    # // | You'll need a brand new phone/adapter, and someone to service it, if someone has your device   |
    # // | address pegged.                                                                                |
    # // |                                                                                                |
    # // | Uh-oh. What can anybody do if that's the case...?                                              |
    # // | That's actually a real problem.                                                                |
    # // | Most people will think NOTHING OF IT, and be like "Whatever bro... Nobody's watchin' me."      |
    # // |________________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $WiFi.Request                                 |
    # // |                                                            |
    # // | Result                 : Allowed                           |
    # // | Id                     : 841                               |
    # // | Exception              :                                   |
    # // | Status                 : RanToCompletion                   |
    # // | IsCanceled             : False                             |
    # // | IsCompleted            : True                              |
    # // | CreationOptions        : None                              |
    # // | AsyncState             :                                   |
    # // | IsFaulted              : False                             |
    # // | AsyncWaitHandle        : System.Threading.ManualResetEvent |
    # // | CompletedSynchronously : False                             |
    # // |                                                            |
    # // | PS Prompt:\>                                               |
    # // |____________________________________________________________|
    # // 
    
    # // _________________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | This is essentially a task object, it is not all that different from a PowerShell runspace... |
    # // | or, IDK how to explain the concept of MULTITHREADING, but when a processor is focused on      |
    # // | a particular TASK...? That's the OBJECT that the system uses, in order to accomplish its'     |
    # // | multiple goals, in tandem.                                                                    |
    # // |                                                                                               |
    # // | Asynchronous operations are basically like this...                                            |
    # // |                                                                                               |
    # // | Suppose you have (8) friends, right...?                                                       |
    # // | They all live somewhere.                                                                      |
    # // | If you tell them ALL, to:                                                                     |
    # // | 1) Go home                                                                                    |
    # // | 2) change their clothes                                                                       |
    # // | 3) come right back...                                                                         |
    # // |                                                                                               |
    # // | Chances are that they will NOT all return at the same exact time.                             |
    # // | That's because they all have different routes to travel, and they may all                     |
    # // | encounter different circumstances...                                                          |
    # // | Yeah, the ACTIVITY that they are all doing is the same...?                                    |
    # // | But- the actual work they each individually have to do, is NOT the same.                      |
    # // |                                                                                               |
    # // | That's the idea behind asynchronous operations.                                               |
    # // |                                                                                               |
    # // | That's what this is, right here.                                                              |
    # // |_______________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $Wifi.Radios                                  |
    # // |                                                            |
    # // | Result                 : System.__ComObject                |
    # // | Id                     : 668                               |
    # // | Exception              :                                   |
    # // | Status                 : RanToCompletion                   |
    # // | IsCanceled             : False                             |
    # // | IsCompleted            : True                              |
    # // | CreationOptions        : None                              |
    # // | AsyncState             :                                   |
    # // | IsFaulted              : False                             |
    # // | AsyncWaitHandle        : System.Threading.ManualResetEvent |
    # // | CompletedSynchronously : False                             |
    # // |                                                            |
    # // | PS Prompt:\>                                               |
    # // |____________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ________________________________________________________________________________
    # // | This is the same type of object as up above. However, the TASK is different. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $Wifi.List                                    |
    # // |                                                            |
    # // | Result                 : System.__ComObject                |
    # // | Id                     : 669                               |
    # // | Exception              :                                   |
    # // | Status                 : RanToCompletion                   |
    # // | IsCanceled             : False                             |
    # // | IsCompleted            : True                              |
    # // | CreationOptions        : None                              |
    # // | AsyncState             :                                   |
    # // | IsFaulted              : False                             |
    # // | AsyncWaitHandle        : System.Threading.ManualResetEvent |
    # // | CompletedSynchronously : False                             |
    # // |                                                            |
    # // | PS Prompt:\>                                               |
    # // |____________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ___________________________________________________________________________
    # // | Again, this is the same type of object. However, the TASK is different. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ____________________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | Index Name                Bssid       Type     Uptime          Netw. Auth.     Enc. Str. |
    # // | ----- ----                -----       ----     ------          ----- --------- ---- ---- |
    # // |     0 Subway          ... CE:2D:E0... 802.11n  7d 18h 57m 59s  Infr. Open80211 None    4 |
    # // |     1 SubSecure       ... CC:2D:E0... 802.11n  7d 18h 57m 59s  Infr. RsnaPsk   Ccmp    4 |
    # // |     2 Uncommon Grounds... F0:9F:C2... 802.11n  7d 19h 04m 12s  Infr. Open80211 None    4 |
    # // |     3 SKMW            ... E2:CB:FC... 802.11n  13h 23m 38s     Infr. RsnaPsk   Ccmp    3 |
    # // |     4                 ... E2:CB:FC... 802.11n  13h 23m 39s     Infr. RsnaPsk   Ccmp    3 |
    # // |     5 CCR's Wi-Fi Netw... C4:B3:01... 802.11n  7d 18h 57m 52s  Infr. RsnaPsk   Ccmp    3 |
    # // |     6 Continuum       ... 38:4C:90... 802.11n  7d 18h 54m 02s  Infr. RsnaPsk   Ccmp    3 |
    # // |     7 SK-Guest        ... E2:CB:FC... 802.11n  13h 23m 38s     Infr. Open80211 None    3 |
    # // |     8                 ... F8:ED:A5... 802.11n  7d 18h 57m 08s  Infr. RsnaPsk   Ccmp    3 |
    # // |     9                 ... 6C:B0:CE... 802.11ac 7d 18h 56m 53s  Infr. RsnaPsk   Ccmp    3 |
    # // |    10 Uncommon Grounds... D4:05:98... 802.11n  7d 18h 53m 25s  Infr. RsnaPsk   Ccmp    3 |
    # // |    11 YANE100         ... BE:75:36... 802.11n  00h 09m 51s     Infr. RsnaPsk   Ccmp    3 |
    # // |    12 iCryo           ... 14:59:C0... 802.11ac 26d 00h 11m 04s Infr. RsnaPsk   Ccmp    2 |
    # // |    13 hum07823        ... B8:9F:09... 802.11n  01h 38m 31s     Infr. RsnaPsk   Ccmp    2 |
    # // |__________________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ____________________________________________________________________
    # // | Here, we've got the same information that I posted WAY up above. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // ______________________________________________________________________________________
    # // |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    # // | PS Prompt:\> $Wifi | Get-Member                                                    |
    # // |                                                                                    |
    # // | TypeName: Wireless                                                                 |
    # // |                                                                                    |
    # // | Name                       MemberType Definition                                   |
    # // | ----                       ---------- ----------                                   |
    # // | Connect                    Method     void Connect(string SSID)                    |
    # // | Disconnect                 Method     void Disconnect()                            |
    # // | Equals                     Method     bool Equals(System.Object obj)               |
    # // | FormatXml                  Method     System.Object FormatXml(System.Object Co     |
    # // | GetHashCode                Method     int GetHashCode()                            |
    # // | GetType                    Method     type GetType()                               |
    # // | GetWiFiConnectionParameter Method     System.Object GetWiFiConnectionParameter     |
    # // | GetWiFiInterface           Method     System.Object[] GetWiFiInterface()           |
    # // | GetWiFiInterfaceGuid       Method     System.Object GetWiFiInterfaceGuid(strin     |
    # // | GetWiFiProfileInfo         Method     System.Object GetWiFiProfileInfo(string      |
    # // | GetWiFiProfileList         Method     System.Object[] GetWiFiProfileList(strin     |
    # // | Hex                        Method     string Hex(string PN)                        |
    # // | NetshShowInterface         Method     System.Object NetshShowInterface(string      |
    # // | NewWifiHandle              Method     System.IntPtr NewWifiHandle()                |
    # // | NewWifiProfile             Method     void NewWifiProfile(string PX, string WF     |
    # // | NewWifiProfileEap          Method     System.Object NewWifiProfileEap(string P     |
    # // | NewWiFiProfilePsk          Method     System.Object NewWiFiProfilePsk(string P     |
    # // | NewWifiProfileXml          Method     System.Object NewWifiProfileXml(string P     |
    # // | NewWifiProfileXmlEap       Method     string NewWifiProfileXmlEap(string PN, s     |
    # // | NewWiFiProfileXmlPsk       Method     string NewWiFiProfileXmlPsk(string PN, s     |
    # // | Passphrase                 Method     void Passphrase(System.Object NW)            |
    # // | RaAsync                    Method     System.Object[] RaAsync()                    |
    # // | RadioFindAllAdaptersAsync  Method     System.Object RadioFindAllAdaptersAsync(     |
    # // | RadioRequestAccess         Method     System.Object RadioRequestAccess()           |
    # // | RadioSynchronization       Method     System.Object RadioSynchronization()         |
    # // | RaList                     Method     System.Object RaList()                       |
    # // | Refresh                    Method     void Refresh()                               |
    # // | RefreshAdapterList         Method     System.Object[] RefreshAdapterList()         |
    # // | RemoveWifiHandle           Method     void RemoveWifiHandle(System.IntPtr CH)      |
    # // | RemoveWifiProfile          Method     void RemoveWifiProfile(string PN)            |
    # // | RsAsync                    Method     System.Object[] RsAsync()                    |
    # // | RsList                     Method     System.Object RsList()                       |
    # // | RxAsync                    Method     System.Object[] RxAsync()                    |
    # // | RxStatus                   Method     System.Object RxStatus()                     |
    # // | Scan                       Method     void Scan()                                  |
    # // | Select                     Method     void Select(string D)                        |
    # // | Task                       Method     System.Object Task()                         |
    # // | ToString                   Method     string ToString()                            |
    # // | Unselect                   Method     void Unselect()                              |
    # // | Update                     Method     void Update()                                |
    # // | WifiConnectionParameter    Method     System.Object WifiConnectionParameter(st     |
    # // | WiFiProfileInfo            Method     System.Object WiFiProfileInfo(string PN,     |
    # // | WiFiReasonCode             Method     string WiFiReasonCode(System.IntPtr RC)      |
    # // | Win32Exception             Method     string Win32Exception(uint32 RC)             |
    # // | WlanCloseHandle            Method     System.Object WlanCloseHandle(System.Int     |
    # // | WlanConnect                Method     void WlanConnect(System.IntPtr HCH, guid     |
    # // | WlanConnectionFlag         Method     System.Object WlanConnectionFlag(string      |
    # // | WlanConnectionMode         Method     System.Object WlanConnectionMode(string      |
    # // | WlanConnectionParams       Method     System.Object WlanConnectionParams()         |
    # // | WlanDeleteProfile          Method     void WlanDeleteProfile(System.IntPtr CH,     |
    # // | WlanDisconnect             Method     void WlanDisconnect(System.IntPtr HCH, g     |
    # // | WlanDot11BssType           Method     System.Object WlanDot11BssType(string D)     |
    # // | WlanEnumInterfaces         Method     System.Object WlanEnumInterfaces(System.     |
    # // | WlanFreeMemory             Method     void WlanFreeMemory(System.IntPtr P)         |
    # // | WlanGetProfile             Method     System.Object WlanGetProfile(System.IntP     |
    # // | WlanGetProfileList         Method     System.Object WlanGetProfileList(System.     |
    # // | WlanGetProfileListFromPtr  Method     System.Object[] WlanGetProfileListFromPt     |
    # // | WlanInterfaceInfo          Method     System.Object WlanInterfaceInfo(System.O     |
    # // | WlanInterfaceList          Method     System.Object WlanInterfaceList(System.I     |
    # // | WlanOpenHandle             Method     System.Object WlanOpenHandle(uint32 CV,      |
    # // | WlanProfileInfoObject      Method     System.Object WlanProfileInfoObject()        |
    # // | WlanReasonCodeToString     Method     System.Object WlanReasonCodeToString(uin     |
    # // | WlanSetProfile             Method     System.Object WlanSetProfile(uint32 CH,      |
    # // | XmlTemplate                Method     System.Object XmlTemplate(uint32 Type)       |
    # // | Adapters                   Property   System.Object Adapters {get;set;}            |
    # // | Connected                  Property   System.Object Connected {get;set;}           |
    # // | List                       Property   System.Object List {get;set;}                |
    # // | Output                     Property   System.Object Output {get;set;}              |
    # // | Radios                     Property   System.Object Radios {get;set;}              |
    # // | Request                    Property   System.Object Request {get;set;}             |
    # // | Selected                   Property   System.Object Selected {get;set;}            |
    # // |                                                                                    |
    # // | PS Prompt:\>                                                                       |
    # // |____________________________________________________________________________________|
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

<#
#---------------------------------------------------------------------------------------------------------------
@'

'@ | Write-Comment -I 4 | Set-Clipboard
#>
