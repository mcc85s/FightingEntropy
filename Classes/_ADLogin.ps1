Class _ADLogin
    {
        [Object]                              $Window
        [Object]                                  $IO

        [String]                           $IPAddress
        [String]                             $DNSName
        [String]                              $Domain
        [String]                             $NetBIOS
        [UInt32]                                $Port

        [Object]                          $Credential
        [String]                            $Username
        [Object]                            $Password
        [Object]                             $Confirm

        [Object]                                $Test
        [String]                                  $DC
        [String]                           $Directory

        [Object]                            $Searcher
        [Object]                              $Result

        _ADLogin([Object]$Target)
        {
            $This.Window       = Get-XamlWindow -Type ADLogin
            $This.IO           = $This.Window.IO
            $This.IPAddress    = $Target.IPAddress
            $This.DNSName      = $Target.Hostname
            $This.NetBIOS      = $Target.NetBIOS
            $This.Port         = 389
            $This.DC           = $This.DNSName.Split(".")[0]
            $This.Domain       = $This.DNSName.Replace($This.DC + '.','')
        }

        ClearADCredential()
        {
            $This.Credential   = $Null
            $This.Username     = $Null
            $This.Password     = $Null
            $This.Confirm      = $Null
        }

        CheckADCredential()
        {
            $This.Port         = $This.IO.Port.Text
            $This.Username     = $This.IO.Username.Text
            $This.Password     = $This.IO.Password.Password
            $This.Confirm      = $This.IO.Confirm.Password

            If (!$This.Port)
            {
                [System.Windows.Messagebox]::Show("Port missing...","Error")
                $This.ClearADCredential()
            }

            ElseIf (!$This.Username)
            {
                [System.Windows.Messagebox]::Show("Username","Error")
                $This.ClearADCredential()
            }
        
            ElseIf (!$This.Password)
            {
                [System.Windows.MessageBox]::Show("Password","Error")
                $This.ClearADCredential()
            }
        
            ElseIf ($This.Password -ne $This.Confirm)
            {
                [System.Windows.Messagebox]::Show("Confirm","Error")
                $This.ClearADCredential()
            }

            Else
            {
                If ( $This.DNSName -notmatch $This.Domain )
                {
                    $This.DNSName  = ("{0}.{1}" -f $This.DNSName, $This.Domain)
                }
                
                $This.Credential   = [System.Management.Automation.PSCredential]::New($This.Username,$This.IO.Password.SecurePassword)
                $This.Directory    = "LDAP://$($This.DNSName):$($This.Port)/CN=Partitions,CN=Configuration,DC=$($This.Domain.Split('.') -join ',DC=')"

                Try 
                {
                    $This.Test                = [System.DirectoryServices.DirectoryEntry]::New($This.Directory,$This.Credential.Username,$This.Credential.GetNetworkCredential().Password)
                }

                Catch
                {
                    [System.Windows.Messagebox]::Show("Login","Error")
                    $This.ClearADCredential()
                }
            }
        }

        [Object] Search([String]$Field)
        {
            Return @( ForEach ( $Item in $This.Result ) { $Item.Properties | ? $Field.ToLower() } )
        }

        [String] GetSiteName()
        {
            Return @( $This.Search("fsmoroleowner").fsmoroleowner.Split(",")[3].Split("=")[1] )
        }

        [String] GetNetBIOSName()
        {
            Return @( $This.Search("netbiosname").netbiosname )
        }
    }
