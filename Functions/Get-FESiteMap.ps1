<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-MadBomb.ps1
          Solution: FightingEntropy Module
          Purpose: For populating a control object that removes all traces of specified Adds/Dhcp/Dns/Vm/VmSwitch instances 
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-23
          Modified: 2021-10-23
          
          Version - 2021.10.0 - () - Finalized functional version 1.

.Example
$Zone     = "securedigitsplus.com"
$Base     = "DC=securedigitsplus,DC=com"
$Config   = "CN=Configuration,DC=securedigitsplus,DC=com"
$OU       = "CP-NY-US-12065"
$Subnet   = "172.16.0.0/19"
$Gateway  = "(\w{2}\-){3}\d{5}"
$Server   = "dc\d\-\d{5}"
$Client   = "ws\d\-\d{5}"
$Master   = Get-FESitemap $Zone $Base $Config $OU $Subnet $Gateway $Server $Client 
#>
Function Get-FESitemap
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory,Position=0)][String]    $Zone,
        [Parameter(Mandatory,Position=1)][String]    $Base,
        [Parameter(Mandatory,Position=2)][String]  $Config,
        [Parameter(Mandatory,Position=3)][String]      $OU,
        [Parameter(Mandatory,Position=4)][String]  $Subnet,
        [Parameter(Mandatory,Position=5)][String] $Gateway,
        [Parameter(Mandatory,Position=6)][String]  $Server,
        [Parameter(Mandatory,Position=7)][String]  $Client)

    Class ADDSObject
    {
        [String] $Name
        [String] $DistinguishedName
        [String] $ObjectClass
        [String] $ObjectGUID
        ADDSObject([Object]$Object)
        {
            $This.Name              = $Object.Name
            $This.DistinguishedName = $Object.DistinguishedName
            $This.ObjectClass       = $Object.ObjectClass
            $This.ObjectGUID        = $Object.ObjectGUID
        }
    }

    Class DhcpObject
    {
        [IPAddress] $IPAddress
        [String]      $ScopeID
        [String]     $ClientID
        [String]         $Name
        [String]         $Type
        [String]  $Description
        DhcpObject([Object]$Object)
        {
            $This.IPAddress   = $Object.IPAddress
            $This.ScopeID     = $Object.ScopeID
            $This.ClientID    = $Object.ClientID
            $This.Name        = $Object.Name
            $This.Type        = $Object.Type
            $This.Description = $Object.Description
        }
    }

    Class DnsObject
    {
        [String] $ZoneName
        [UInt32] $DS
        [UInt32] $Reverse
        [String] $Hostname
        [String] $RecordType
        Hidden [Object] $RecordData
        [Object] $DisplayName
        DnsObject([Object]$Zone,[Object]$Object)
        {
            $This.ZoneName     = $Zone.ZoneName
            $This.DS           = $Zone.IsDsIntegrated
            $This.Reverse      = $Zone.IsReverseLookupZone
            $This.Hostname     = $Object.Hostname
            $This.RecordType   = $Object.RecordType
            $This.RecordData   = $Object.RecordData
            $This.DisplayName  = @{A="IPV4Address";AAAA="IPV6Address";SRV="DomainName";NS="NameServer";CNAME="HostnameAlias";PTR="PtrDomainName"}[$Object.RecordType] | % { $Object.RecordData.$_ }
        }
        [String] ToString()
        {
            Return $This.DisplayName
        }
    }

    Class VmObject
    {
        [String]    $Name
        [String]   $State
        [String] $VMXPath
        [String] $VHDPath
        VmObject([Object]$VM)
        {
            $This.Name    = $Vm.Name
            $This.State   = $Vm.State
            $This.VmxPath = $Vm.Path
            $This.VhdPath = Get-VMHardDiskDrive -VMName $Vm.Name | % Path
        }
        Stop()
        {
            Stop-VM -Name $This.Name -Verbose -Force -Confirm:$False
        }
    }

    Class VMSwitch
    {
        [String] $Name
        [String] $SwitchType
        VmSwitch([Object]$VMSwitch)
        {
            $This.Name       = $VMSwitch.Name
            $This.SwitchType = $VMSwitch.SwitchType
        }
    }

    Class Master
    {
        [String]       $Zone
        [String]       $Base
        [String]     $Config
        [String]         $OU
        [String]     $Subnet
        [Object]   $SiteLink
        [String[]]       $IP
        [String]    $ScopeID
        [Object]     $VMHost
        [String]    $Gateway
        [String]     $Server
        [String]     $Client
        [String]        $All
        [Object]       $ADDS
        [Object]       $DHCP
        [Object]        $DNS
        [Object]         $VM
        [Object]   $VMSwitch
        Master([String]$Zone,[String]$Base,[String]$Config,[String]$OU,[String]$Subnet,[String]$Gateway,[String]$Server,[String]$Client)
        {
            $This.Zone      = $Zone
            $This.Base      = $Base
            $This.Config    = $Config
            $This.OU        = $OU
            $This.Subnet    = $Subnet

            Write-Host "Getting [~] Sitelink"
            $This.Sitelink  = Get-ADReplicationSiteLink -Filter * | ? name -match "default"
            
            Write-Host "Getting [~] IP"
            $This.IP        = Get-WMIObject -Class Win32_NetworkAdapterConfiguration | ? DefaultIPGateway | % IPAddress | Sort-object
            
            Write-Host "Getting [~] Dhcp ScopeID"
            $This.ScopeID   = Get-DhcpServerv4Scope | % ScopeID

            Write-Host "Getting [~] VMHost"
            $This.VMHost    = Get-VMHost
            $This.Gateway   = $Gateway
            $This.Server    = $Server
            $This.Client    = $Client
            $This.All       = "$Gateway|$Server|$Client"
            $This.ADDS      = @( )
            $This.DHCP      = @( )
            $This.DNS       = @( )
            $This.VM        = @( )
            $This.VMSwitch  = @( )

            $This.GetADDS()
            $This.GetDHCP()
            $This.GetDNS()
            $This.GetVm()
            $This.GetVmSwitch()
        }
        [String] GetNetmask([UInt32]$CIDR)
        {
            Return @( @( 0,8,16,24 | % {[Convert]::ToInt32(("{0}{1}" -f ("1" * $CIDR -join ''),("0" * (32-$CIDR) -join '')).Substring($_,8),2)} ) -join '.' )
        }
        [String[]] GetSubnetRange()
        {
            # Split Network and CIDR
            $Network, $CIDR = $This.Subnet.Split("/")

            # Get netmask
            $Netmask        = @( 0,8,16,24 | % {[Convert]::ToInt32(("{0}{1}" -f ("1" * $CIDR -join ''),("0" * (32-$CIDR) -join '')).Substring($_,8),2)} ) -join '.'

            # Get Hostrange string
            $X              = [UInt32[]]$Network.Split("/")[0].Split(".")
            $Y              = [UInt32[]]$Netmask.Split(".") | % { (256 - $_) - 1 }
            $HostRange      = @( ForEach ($I in 0..3 )
            {
                Switch($Y[$I])
                {
                    0 { $X[$I] } Default { "{0}..{1}" -f $X[$I],($X[$I]+$Y[$I]) }
                }
            } ) -join '/'

            # Expand hostrange string
            $I              = $HostRange.Split("/")
            $X              = @{ }
            ForEach ( $0 in $I[0] | Invoke-Expression)
            {
                ForEach ( $1 in $I[1] | Invoke-Expression)
                {
                    ForEach ( $2 in $I[2] | Invoke-Expression) 
                    {
                        ForEach ( $3 in $I[3] | Invoke-Expression)
                        {
                            $X.Add($X.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            # Sort in proper order
            $X               = $X | % GetEnumerator | Sort-Object Name | % Value

            # Return
            Return $X
        }
        GetADDS()
        {
            $This.ADDS = @( )
            Write-Theme "Getting [~] Adds Objects"
            0..4 | % { 

                Switch ($_)
                {
                    0 # ADDS computer objects
                    {
                        ForEach ($Item in Get-ADObject -LDAPFilter "(objectClass=Computer)" -SearchBase $This.Base | ? Name -match "($($This.All))" | ? DistinguishedName -notmatch $This.OU)
                        {
                            Write-Host "Getting [~] Adds Objects ($($Item.DistinguishedName))"
                            $This.ADDS += [ADDSObject]::New($Item) 
                        }
                    }
                    1 # ADDS OUs
                    {
                        ForEach ($Item in Get-ADObject -LDAPFilter "(objectClass=organizationalUnit)" -SearchBase $This.Base | ? DistinguishedName -match "($($This.All))" | ? DistinguishedName -notmatch $This.OU)
                        { 
                            Write-Host "Getting [~] Adds Objects ($($Item.DistinguishedName))"
                            $This.ADDS += [ADDSObject]::New($Item) 
                        }
                    }
                    2 # ADDS Subnets
                    {
                        ForEach ($Item in Get-ADObject -LDAPfilter "(objectClass=subnet)" -SearchBase $This.Config | ? Name -notmatch $This.Subnet)
                        {
                            Write-Host "Getting [~] Adds Objects ($($Item.DistinguishedName))"
                            $This.ADDS += [ADDSObject]::New($Item) 
                        }
                    }
                    3 # ADDS Sites
                    {
                        ForEach ($Item in Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase $This.Config | ? Name -notmatch $This.OU)
                        {
                            Write-Host "Getting [~] Adds Objects ($($Item.DistinguishedName))"
                            $This.ADDS += [ADDSObject]::New($Item) 
                        }
                    }
                    4 # ADDS DHCP
                    {
                        ForEach ($Item in Get-ADObject -LDAPFilter "(objectClass=dhcpclass)" -SearchBase $This.Config | ? Name -match $This.Server)
                        { 
                            Write-Host "Getting [~] Adds Objects ($($Item.DistinguishedName))"
                            $This.ADDS += [ADDSObject]::New($Item) 
                        }
                    }
                }
            }
        }
        RemoveADDS()
        {
            Write-Theme "Removing [~] Adds Objects"

            ForEach ($Item in $This.ADDS | ? ObjectClass -ne Sitelink)
            {
                Write-Host "Removing [~] Adds Object ($($Item.DistinguishedName))"
                Switch ($Item.ObjectClass)
                {
                    Computer
                    {
                        $Item | Remove-ADObject -Confirm:$False -Recursive -Verbose -EA 0
                    }
                    OrganizationalUnit
                    {
                        $Item | Set-ADObject -ProtectedFromAccidentalDeletion 0 -Verbose | Remove-ADObject -Confirm:$False -Recursive -Verbose
                    }
                    Subnet
                    {
                        $Item | Remove-ADObject -Confirm:$False 
                    }
                    Site
                    {
                        Remove-ADObject -DistinguishedName $Item.DistinguishedName -Confirm:$False -Recursive -Verbose -EA 0
                        Set-ADReplicationSiteLink -Identity $This.Sitelink -SitesIncluded @{ Remove = $Item.DistinguishedName } -Verbose
                    }
                }
            }
        }
        GetDHCP()
        {
            $This.DHCP = @( )
            Write-Theme "Getting [~] Dhcp Reservations"

            ForEach ($Item in Get-DhcpServerv4Reservation -ScopeID $This.ScopeID | ? Name -match "($($This.All))" | ? Name -notmatch $This.OU)
            {
                Write-Host "Getting [~] Dhcp Reservation ($($Item.Name))"
                $This.Dhcp += [DhcpObject]::New($Item)
            }
        }
        RemoveDHCP()
        {
            Write-Theme "Removing [~] Dhcp Reservations"

            ForEach ($Item in $This.DHCP)
            {
                Write-Host "Removing [~] Dhcp Reservation ($($Item.Description))"
                $Item | Remove-DHCPServerV4Reservation -Verbose -EA 0
            }
        }
        GetDNS()
        {
            $This.DNS = @( )
            Write-Theme "Getting [~] Dns Entries"

            $List = ForEach ($Zone in Get-DNSServerZone | ? IsDsIntegrated)
            {
                Write-Host "Getting [~] DNS Zone ($($Zone.ZoneName))"
                Get-DNSServerResourceRecord -ZoneName $Zone.ZoneName | % { [DnsObject]::New($Zone,$_) }
            }

            # DNS Main Zone Objects
            @( ForEach ($Item in $List | ? ZoneName -eq $This.Zone)
            {
                Switch ($Item.RecordType)
                {
                    A    { $Item | ? {$_.RecordData.IPV4Address -notin $X } }
                    AAAA { $Item | ? RecordName  -match $This.Server }
                    SRV  { $Item | ? {$_.RecordData.DomainName -match $This.Server } }
                }
            } ) | % { $This.DNS += $_ }

            # MSDCS DNS Zone Objects
            @( ForEach ( $Item in $List | ? ZoneName -eq "_msdcs.$($This.Zone)" )
            {
                Switch($Item.RecordType)
                {
                    NS     { $Item | ? { $_.RecordData.NameServer    -match $This.Server } } # Nameservers
                    CNAME  { $Item | ? { $_.RecordData.HostnameAlias -match $This.Server } } # CName
                    SRV    { $Item | ? { $_.RecordData.DomainName    -match $This.Server } } # SRV
                    A      { $Item | ? { $_.RecordData.IPV4Address   -notin $This.IP     } } # Host A Record
                    AAAA   { $Item | ? { $_.RecordData.IPV6Address   -notin $This.IP     } } # Host AAAA Record
                
                }
            } ) | % { $This.DNS += $_ }

            # Reverse DNS Zones
            $Main = $List | ? DS | ? Reverse | ? DisplayName -match $This.OU | % ZoneName
            $List         | ? DS | ? Reverse | ? ZoneName -ne $Main | % { $This.DNS += $_ }
        }
        RemoveDns()
        {
            Write-Theme "Removing [~] Dns Entries"
            ForEach ($Item in $This.Dns)
            {
                Write-Host "Removing [~] Dns Entry ($($Item.DisplayName))"
                $Item | Remove-DNSServerResourceRecord -ZoneName $Item.ZoneName -Verbose -EA 0 -Confirm:$False -Force
            }
        }
        GetVM()
        {
            $This.VM = @( )
            Write-Theme "Getting [~] Vm Stack"

            ForEach ($Item in Get-VM | ? Name -match $This.All)
            {
                Write-Host "Getting [~] VM ($($Item.Name))" 
                $This.VM += [VmObject]::New($Item)
            }
        }
        RemoveVM()
        {
            ForEach ($Item in $This.VM)
            {
                If ($This.Vm.State -ne "Off")
                {
                    Write-Host "Stopping [~] Vm $($Item.Name)"
                    Stop-VM -Name $Item.Name -Force -Confirm:$False -Verbose
                }
                Write-Host "Removing [~] Vm $($Item.Name)"
                Remove-VM -Name $Item.Name -Force -Confirm:$False -Verbose

                Write-Host "Removing [~] Vmx ($($Item.VMXPath))"
                Remove-Item $Item.VMXPath -Force -Confirm:$False -Verbose

                Write-Host "Removing [~] Vhd ($($Item.VHDPath))"
                Remove-Item $Item.VHDPath -Force -Confirm:$False -Verbose
            }
        }
        GetVMSwitch()
        {
            $This.VmSwitch = @( )
            Write-Theme "Getting [~] Vm Switch Stack"

            ForEach ($Item in Get-VMSwitch | ? Name -match $This.Gateway | ? Name -notmatch $This.OU)
            {
                Write-Host "Getting [~] Vm Switch ($($Item.Name))"
                $This.VMSwitch += [VmSwitch]::New($Item) 
            }
        }
        RemoveVmSwitch()
        {
            ForEach ($Item in $This.VmSwitch)
            {
                Write-Host "Removing [~] Vm Switch ($($Item.Name))"
                Remove-VMSwitch -Name $Item.Name -Force -Confirm:$False -Verbose
            }
        }

    }
    [Master]::New($Zone,$Base,$Config,$OU,$Subnet,$Gateway,$Server,$Client)
}
