Function Get-Certificate
{
    [CmdLetBinding()]Param(
        [String]$Organization = "Default",
        [String]$CommonName   = "test.localhost"
    )

    If ( ! ( Test-Connection 1.1.1.1 -Count 1 ) ) 
    { 
        Throw "Unable to verify internet connection" 
    }

    [Net.ServicePointManager]::SecurityProtocol = 3072
    
    # This (2) lines from Chrissie Lamaire's script, 
    # https://gallery.technet.microsoft.com/scriptcenter/Get-ExternalPublic-IP-c1b601bb

    $ExternalIP       = Invoke-RestMethod http://ifconfig.me/ip 
    $Ping             = Invoke-RestMethod "http://ipinfo.io/$ExternalIP"

    If ( $Host.Major.Version -gt 5 )
    {
        Throw "PS6/7 not working"
    }

    [_Certificate]::New($ExternalIP,$Ping,$Organization,$CommonName)

}
