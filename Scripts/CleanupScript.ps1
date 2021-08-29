# ADDS Cleanup Script
# -------------------
$Zone       = "securedigitsplus.com"
$Base       = "DC=securedigitsplus,DC=com"
$Code       = "(\w{2}\-){3}\d{5}"
$SafeOU     = "CP-NY-US-12065"
$SafeSubnet = "172.16.0.0/19"
$Gateway    = Get-ADObject -Filter * | ? ObjectClass -eq Computer | ? Name -match "(dc\d\-\d{5}|(\w{2}\-){3}\d{5})"
$Gateway    | ? Name -notmatch $SafeOU | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0
$OUList     = Get-ADObject -LDAPFilter "(objectClass=organizationalUnit)" -SearchBase $Base | ? Name -match "(\w{2}\-){3}\d{5}"
$OUList     | ? Name -ne $SafeOU | % { Set-ADObject -Identity $_.DistinguishedName -ProtectedFromAccidentalDeletion 0 -Verbose }
$OUList     | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0
$Subnet     = Get-ADObject -LDAPfilter "(objectClass=subnet)" -SearchBase "CN=Configuration,$Base"
$Subnet     | ? Name -ne $SafeSubnet  | Remove-ADObject -Confirm:$False -Verbose
$SiteList   = Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase "CN=Configuration,$Base"
$SiteList   | ? Name -ne $SafeOU | Remove-ADObject -Confirm:$False -Recursive -Verbose

# DHCP Cleanup Script
# -------------------
$ScopeID    = Get-DhcpServerv4Scope | % ScopeID
$DHCP       = Get-DhcpServerv4Reservation -ScopeID $ScopeID | ? Name -match "((\w{2}-){3}(\d{5})|OPNsense)" | ? Name -notmatch $SafeOU

If ($DHCP.Count -gt 0)
{
    $DHCP   | Remove-DHCPServerV4Reservation -Verbose -EA 0
}

$DNS        = Get-DNSServerResourceRecord -ZoneName $Zone | ? HostName -match "((\w{2}-){3}(\d{5})|OPNsense)" | ? Hostname -notmatch $SafeOU
If ($DNS.Count -gt 0)
{
    $DNS    | Remove-DNSServerResourceRecord -ZoneName $Zone -Verbose -EA 0 -Confirm:$False -Force
}

# VM Cleanup Script
# -----------------
$VM         = Get-VM | ? Name -match "((\w{2}-){3}(\d{5})|OPNsense|dc\d\-\d{5})"
If ( $VM.Count -gt 0 )
{
    $VM     | Stop-VM -Confirm:$False -Verbose -Force
    $VM     | Remove-VM -Confirm:$false -Verbose -Force
}

# VM Switch Cleanup
# -----------------
$VMS        = Get-VMSwitch | ? Name -match "(\w{2}-){3}(\d{5})"
If ( $VMS.Count -gt 0 )
{
    $VMS    | Remove-VMSwitch -Confirm:$False -Verbose -Force
}
