# Date: 3/25/2022 | Originally wrote this a few days ago, I just got sidetracked.
# Allows an ability to display the content of multiple certificates of a (certificate/chain), similar to how the GUI does.

Class CertSlot
{
    Hidden [Object] $Cert
    [String] $FriendlyName
    [Object] $Thumbprint
    [String] $Issuer
    [String] $SerialNumber
    [Object] $Version
    [Object] $SignatureAlgorithm
    Hidden [Object[]] $Extensions
    [Object] $ValidFrom
    [Object] $ValidTo
    [Object] $Subject
    [Object] $PublicKey
    [Object] $SubjectKeyIdentifier
    [Object] $AuthorityKeyIdentifier
    [Object] $KeyUsage
    [Object] $EnhancedKeyUsage
    [Object] $CRLDistributionPoints 
    [Object] $AuthorityInformationAccess
    [Object] $SubjectAlternateName
    [Object] $BasicContraints
    CertSlot([Object]$Cert)
    {    
        $This.Cert                       = $Cert
        $This.FriendlyName               = $Cert.FriendlyName
        If (!$Cert.Friendlyname)
        {
            $This.FriendlyName           = $Cert.DnsNameList | Select-Object -First 1
        }
        $This.Version                    = $Cert.Version
        $This.SerialNumber               = $Cert.SerialNumber
        $This.Extensions                 = $Cert.Extensions
        $This.SignatureAlgorithm         = $Cert.SignatureAlgorithm.FriendlyName
        $This.Issuer                     = $Cert.Issuer
        $This.ValidFrom                  = $Cert.NotBefore
        $This.ValidTo                    = $Cert.NotAfter
        $This.Subject                    = $Cert.Subject
        $This.PublicKey                  = $This.GetPublicKeyString()
        $This.KeyUsage                   = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Key Usage"                    } | % { $_.Format(0) }
        $This.SubjectKeyIdentifier       = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Subject Key Identifier"       } | % { $_.Format(0) }
        $This.SubjectAlternateName       = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Subject Alternative Name"     } | % { $_.Format(1) }
        $This.AuthorityKeyIdentifier     = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Authority Key Identifier"     } | % { $_.Format(0) }
        $This.CRLDistributionPoints      = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "CRL Distribution Points"      } | % { $_.Format(1) }
        $This.AuthorityInformationAccess = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Authority Information Access" } | % { $_.Format(1) }
        $This.EnhancedKeyUsage           = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Enhanced Key Usage"           } | % { $_.Format(1) }
        $This.BasicContraints            = $Cert.Extensions | ? { $_.Oid.FriendlyName -eq "Basic Constraints"            } | % { $_.Format(1) }
        $This.Thumbprint                 = $Cert.Thumbprint
    }
    [String] GetPublicKeyString()
    {
        $Key    = @( )
        $Page   = @( )
        $This.Cert.RawData | % { "{0:X}" -f $_ } | % { 
            
            $X = $_
            If ($X.ToCharArray().Count -eq 1)
            {
                $X = "0$_"
            }
            $Key += $X
            If ($Key.Count -eq 14)
            {
                $Page += "{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12} {13}" -f $Key[0..13]
                $Key  = @( )
            }
        }

        Return ($Page -join "`n")
    }
}
