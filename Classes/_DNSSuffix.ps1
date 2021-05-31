Class _DNSSuffix
{
    [String] $Path         = "HKLM:\System\CurrentControlSet\Services\TCPIP\Parameters"
    [UInt32] $IsDomain     = ([WMIClass]"\\.\ROOT\CIMV2:Win32_ComputerSystem" | % GetInstances | % PartOfDomain)
    [String] $ComputerName
    [String] $Domain
    [String] $NVDomain
    [UInt32] $Sync

    _DNSSuffix()
    {
        Get-ItemProperty $This.Path | % { 

            $This.ComputerName = $_.HostName
            $This.Domain       = $_.Domain
            $This.NVDomain     = $_.'NV Domain'
            $This.Sync         = $_.SyncDomainWithMembership
        }
    }

    SetDomain([String]$Domain)
    {
        $This.Domain           = $Domain
    }

    SetComputerName([String]$ComputerName)
    {
        $This.ComputerName     = $ComputerName
    }

    SetSync()
    {
        If ( ! ( $This.IsDomain ) )
        {
            ForEach ( $Item in "Domain","NV Domain" )
            {
                Set-ItemProperty -Path $This.Path -Name $Item -Value $This.Domain -Verbose
            }
        }

        Else
        {
            [System.Windows.MessageBox]::Show("System is part of a domain","Exception")
        }
    }
}
