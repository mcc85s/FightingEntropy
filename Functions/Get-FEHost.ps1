<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEHost.ps1
          Solution: FightingEntropy Module
          Purpose: For retrieving basic information about a system and the current user
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEHost
{
    Class Host
    {
        [String]                $Name = [Environment]::MachineName.ToLower()
        [String]                 $DNS
        [String]             $NetBIOS = [Environment]::UserDomainName.ToLower()
        [String]            $Hostname
        [String]            $Username = [Environment]::UserName
        [Object]           $Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        [Bool]               $IsAdmin
        [Object]             $Network
        Host()
        {
            $This.DNS                 = @($Env:UserDNSDomain,"-")[!$env:USERDNSDOMAIN]
            $This.Hostname            = @($This.Name;"{0}.{1}" -f $This.Name, $This.DNS)[(Get-CimInstance Win32_ComputerSystem).PartOfDomain].ToLower()
            $This.IsAdmin             = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
            If ($This.IsAdmin -eq 0)
            {
                Throw "Must run as administrator"
            }
        }
        Network()
        {
            $This.Network             = Get-FENetwork
        }
    }
    [Host]::New()
}
