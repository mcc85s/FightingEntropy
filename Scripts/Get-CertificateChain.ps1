<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-04-07 09:51:34                                                                  //
 \\==================================================================================================// 

   FileName   : Get-CertificateChain.ps1
   Solution   : [FightingEntropy()][2023.4.0]
   Purpose    : Collects information within a particular certificate file
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2023-04-06
   Modified   : 2023-04-07
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : Have the hash values restore themselves from registry
                Now includes the console logger by default

.Example
#>
Function Get-CertificateChain
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(ParameterSetName=0,Mandatory)][String]$Path,
    [Parameter(ParameterSetName=1,Mandatory)][Object]$Certificate)

    Class CertificateFile
    {
        Hidden [Object]   $File
        [String]          $Name
        [String]          $Size
        Hidden [UInt64] $Length
        [String]      $Fullname
        CertificateFile([String]$Path)
        {
            $This.File     = Get-Item $Path
            $This.Name     = $This.File.Name
            $This.Fullname = $This.File.Fullname
            $This.Length   = $This.File.Length
            $This.Size     = "{0:n2} KB" -f ($This.Length/1KB)
        }
        [String] ToString()
        {
            Return $This.Fullname
        }
    }

    Class CertificateName
    {
        [String]         $Type
        [String]        $Entry
        [String]   $CommonName
        [String] $Organization
        [String]     $Location
        [String]        $State
        [String]      $Country
        CertificateName([String]$Type,[String]$Entry)
        {
            $This.Type         = $Type
            $This.Entry        = $Entry
            $List              = $Entry -Split "," | % Substring 3
            $This.CommonName   = $List[0]
            $This.Organization = $List[1]
            $This.Location     = $List[2]
            $This.State        = $List[3]
            $This.Country      = $List[4]
        }
        [String] ToString()
        {
            Return $This.Entry
        }
    }

    Class CertificateControl
    {
        [Object]                       $File
        [Object]                $Certificate
        [String]               $FriendlyName
        [Object]                 $Thumbprint
        [String]                     $Issuer
        [String]               $SerialNumber
        [Object]                    $Version
        [Object]         $SignatureAlgorithm
        Hidden [Object[]]        $Extensions
        [Object]                  $ValidFrom
        [Object]                    $ValidTo
        [Object]                    $Subject
        [Object]                  $PublicKey
        [Object]       $SubjectKeyIdentifier
        [Object]     $AuthorityKeyIdentifier
        [Object]                   $KeyUsage
        [Object]           $EnhancedKeyUsage
        [Object]      $CRLDistributionPoints 
        [Object] $AuthorityInformationAccess
        [Object]       $SubjectAlternateName
        [Object]            $BasicContraints
        CertificateControl([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.File        = $This.CertificateFile($Path)
            $This.Certificate = $This.CertificateObject($Path)
            $This.Main()
        }
        CertificateControl([Object]$Cert)
        {    
            $This.Certificate = $Cert
            $This.Main()
        }
        Main()
        {
            $This.FriendlyName = $This.Certificate.FriendlyName
            If (!$This.Certificate.FriendlyName)
            {
                $This.FriendlyName           = $This.DnsNameList | Select-Object -First 1
            }
            $This.Thumbprint                 = $This.Certificate.Thumbprint
            $This.Version                    = $This.Certificate.Version
            $This.SerialNumber               = $This.Certificate.SerialNumber
            $This.Extensions                 = $This.Certificate.Extensions
            $This.SignatureAlgorithm         = $This.Certificate.SignatureAlgorithm.FriendlyName
            $This.Issuer                     = $This.Certificate.Issuer
            $This.ValidFrom                  = $This.Certificate.NotBefore
            $This.ValidTo                    = $This.Certificate.NotAfter
            $This.Subject                    = $This.Certificate.Subject
            $This.PublicKey                  = $This.GetPublicKeyString()
            $This.KeyUsage                   = $This.Property("Key Usage",0)
            $This.SubjectKeyIdentifier       = $This.Property("Subject Key Identifier",0)
            $This.SubjectAlternateName       = $This.Property("Subject Alternative Name",1)
            $This.AuthorityKeyIdentifier     = $This.Property("Authority Key Identifier",0)
            $This.CRLDistributionPoints      = $This.Property("CRL Distribution Points",1)
            $This.AuthorityInformationAccess = $This.Property("Authority Information Access",1)
            $This.EnhancedKeyUsage           = $This.Property("Enhanced Key Usage",1)
            $This.BasicContraints            = $This.Property("Basic Constraints",1)
        }
        [Object] CertificateFile([String]$Path)
        {
            Return [CertificateFile]::New($Path)
        }
        [Object] X509Certificate([String]$Path)
        {
            Return [System.Security.Cryptography.X509Certificates.X509Certificate]::CreateFromCertFile($Path)
        }
        [Object] X509Certificate2([Object]$Object)
        {
            Return [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($Object)
        }
        [Object] CertificateObject([String]$Path)
        {
            Return $This.X509Certificate2($This.X509Certificate($Path))
        }
        [Object] Property([String]$Label,[UInt32]$Format)
        {
            $Prop = $This.Extensions | ? { $_.Oid.FriendlyName -eq $Label } 
            
            If ($Prop)
            {
                Return $Prop.Format($Format)
            }
            Else
            {
                Return $Null
            }
        }
        [String] GetPublicKeyString()
        {
            $Key    = @( )
            $Page   = @( )
            $This.Certificate.RawData | % { "{0:X}" -f $_ } | % { 
                
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

    Switch ($pscmdlet.ParameterSetName)
    {
        0 { [CertificateControl]::New($Path) }
        1 { [CertificateControl]::New($Certificate) }
    }
}
