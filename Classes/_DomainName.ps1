Class _DomainName
{
    [String]             $String
    [String]               $Type
    
    Hidden [Object]        $Slot = @{ NetBIOS = @{ Min = 1; Max = 15 }; Domain = @{ Min = 2; Max = 63 }; SiteName = @{ Min = 2; Max = 63 } }
    Hidden [Char[]]       $Allow = [Char[]]@(45,46;48..57;65..90;97..122)
    Hidden [Char[]]        $Deny = [Char[]]@(32..44;47;58..64;91..96;123..126)
    Hidden [Hashtable] $Reserved = @{
    
        Words             = ( "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GROUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;" + 
                              "DIALUP;DIGEST AUTH;INTERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN;NTLM AU" + 
                              "TH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZ" + 
                              "ATION;USERS;WORLD") -Split ";"
        DNSHost           = ( "-GATEWAY","-GW","-TAC" )
        SDDL              = ( "AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS," + 
                              "RU,SA,SI,SO,SU,SY,WD") -Split ','
    }

    _DomainName([String]$Type,[String]$String)
    {
        If ( $Type -notin $This.Slot.Keys )
        {
            Throw "Invalid type"
        }

        $This.String = $String
        $This.Type   = $Type
        $This.Slot   = $This.Slot["$($Type)"]

        If ( $This.String -in $This.Reserved.Words )
        {
            Throw "Entry is reserved"
        }

        If ( $This.String.Length -le $This.Slot.Min )
        {
            Throw "Input does not meet minimum length"
        }

        If ( $This.String.Length -ge $This.Slot.Max )
        {
            Throw "Input exceeds maximum length"
        }

        If ( $This.String.ToCharArray() | ? { $_ -notin $This.Allow -or $_ -in $This.Deny } )
        { 
            Throw "Name has invalid characters"
        }
        
        If ( $This.String[0,-1] -notmatch "(\w)" )
        {
            Throw "First/Last Character not alphanumeric" 
        }

        Switch($This.Type)
        {
            NetBIOS  
            { 
                If ( "." -in $This.String.ToCharArray() ) 
                { 
                    Throw "Period found in NetBIOS Domain Name, breaking" 
                }
            }

            Domain
            { 
                If ( $This.String.Split('.').Count -lt 2 )
                {
                    Throw "Not a valid domain name, single label domain names are disabled"
                }
                
                If ( $This.String -in $This.Reserved.SDDL )
                { 
                    Throw "Name is reserved" 
                }

                If ( ( $This.String.Split('.')[-1].ToCharArray() | ? { $_ -match "(\D)" } ).Count -eq 0 )
                {
                    Throw "Top Level Domain must contain a non-numeric."   
                }
            }

            Default {}
        }
    }
}
