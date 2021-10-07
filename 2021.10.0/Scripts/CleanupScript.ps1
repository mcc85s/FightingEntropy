# ADDS Cleanup Script
# -------------------
If ($Host.Version.Major -le 5)
{
    Switch($Host.UI.PromptForChoice("Lab removal","This will remove all of the lab issued VM/ADDS instances",@("&Yes","&No"),1))
    {
        0 
        {   # Master Server/OU Variables
            $Master     = @{ 
                
                Zone     = "securedigitsplus.com"
                Base     = "DC=securedigitsplus,DC=com"
                CFG      = "CN=Configuration,DC=securedigitsplus,DC=com"
                OU       = "CP-NY-US-12065"
                Subnet   = "172.16.0.0/19"
                Sitelink = Get-ADReplicationSiteLink -Filter * | ? name -match "default"
                IP       = Get-NetIPAddress | % IPAddress
                ScopeID  = Get-DhcpServerv4Scope | % ScopeID
                VMHost   = Get-VMHost
            }

            # Regex Lab Tags
            $Gateway    = "(\w{2}\-){3}\d{5}"
            $Server     = "dc\d\-\d{5}"
            $Client     = "ws\d\-\d{5}"
            $All        = "$Gateway|$Server|$Client"

            # Flush Lab ADDS computer objects
            Get-ADObject -LDAPFilter "(objectClass=Computer)" | ? Name -match "($All)" | ? DistinguishedName -notmatch $Master.OU | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0

            # Flush Lab ADDS OUs
            Get-ADObject -LDAPFilter "(objectClass=organizationalUnit)" -SearchBase $Master.Base | ? DistinguishedName -match "($All)" | % { 
                
                Set-ADObject -Identity $_.DistinguishedName -ProtectedFromAccidentalDeletion 0 -Verbose 
            
            } | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0

            # Flush Lab ADDS Subnets
            Get-ADObject -LDAPfilter "(objectClass=subnet)" -SearchBase $Master.CFG | ? Name -notmatch $Master.Subnet | Remove-ADObject -Confirm:$False -Verbose

            # Flush Lab ADDS Sites/SiteLinks
            Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase $Master.CFG | ? Name -notmatch $Master.OU | % { 
                
                Set-ADReplicationSiteLink -Identity $Master.Sitelink -SitesIncluded @{Add=$_.DistinguishedName} -Verbose
                #Remove-ADObject -Confirm:$False -Recursive -Verbose
            }

            # Flush Lab ADDS DHCP Objects 
            Get-ADObject -LDAPFilter "(objectClass=dhcpclass)" -SearchBase $Master.CFG | ? Name -match $Server | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0
            
            Get-ADObject -LDAPFilter "(objectClass=SiteLink)" -SearchBase $Master.CFG -Properties * |
            
            # Flush Lab DHCPv4 Reservation Objects
            Get-DhcpServerv4Reservation -ScopeID $Master.ScopeID | ? Name -match "($All|OPNsense)" | ? Name -notmatch $Master.OU | Remove-DHCPServerV4Reservation -Verbose -EA 0
            
            # Flush Lab DNS Main Zone Objects
            @( ForEach ( $Item in Get-DNSServerResourceRecord -ZoneName $Master.Zone )
            {
                Switch ($Item.RecordType)
                {
                    A    { $Item | ? { $_.RecordData.IPV4Address -notmatch "172.16.0." }}
                    AAAA { $Item | ? RecordName -match $Server }
                    SRV  { $Item | ? { $_.RecordData.DomainName  -match $Server }}
                }
            } ) | Remove-DNSServerResourceRecord -ZoneName $Master.Zone -Verbose -EA 0 -Confirm:$False -Force

            # Flush Lab MSDCS DNS Zone Objects
            @( ForEach ( $Item in Get-DNSServerResourceRecord -ZoneName "_msdcs.$($Master.Zone)" )
            {
                Switch($Item.RecordType)
                {
                    NS     { $Item | ? { $_.RecordData.NameServer    -match $Server } } # Nameservers
                    CNAME  { $Item | ? { $_.RecordData.HostnameAlias -match $Server } } # CName
                    SRV    { $Item | ? { $_.RecordData.DomainName    -match $Server } } # SRV
                    A      { $Item | ? { $_.RecordData.IPV4Address   -notin $Master.IP } } # Host A Record
                    AAAA   { $Item | ? { $_.RecordData.IPV6Address   -notin $Master.IP } } # Host AAAA Record
                }
            } ) | Remove-DNSServerResourceRecord -ZoneName "_msdcs.$($Master.Zone)" -Verbose -EA 0 -Confirm:$False -Force

            # Flush Lab VM Objects
            Get-VM | ? Name -match "($All|OPNsense)" | % { 

                If ( $_.State -ne "Off" )
                {
                    Stop-VM -Name $_.Name -Confirm:$False -Verbose -Force
                }
                Remove-VM -Name $_.Name -Confirm:$false -Verbose -Force
            }

            # Flush Lab VHDX Objects
            Get-ChildItem @( $Master.VMHost | % { $_.VirtualHardDiskPath,$_.VirtualMachinePath }) | ? Name -match $All | Remove-Item -Verbose -Force -Confirm:$False -EA 0 
            
            # Flush Lab VMSwitch Objects
            Get-VMSwitch | ? Name -match $Gateway | Remove-VMSwitch -Confirm:$False -Verbose -Force
        } 
        
        1 
        { 
            Write-Host "Breaking"
            Break 
        }
    }
}
