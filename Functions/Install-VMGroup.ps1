Function Install-VMGroup
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory)][String]    $Server ,
        [Parameter(Mandatory)][UInt32]      $Port ,    
        [Parameter(Mandatory)][String[]] $NamedVM )

    Class _VMObject
    {
        Hidden [Object] $Object
        [String] $Name
        [Object] $HostName
        [String] $VMState
        [String] $VMStatus
        [String] $VMId
        [Object] $MdtPercent
        [String] $MdtStatus
        [String] $MdtId

        _VMObject([Object]$VM,[Object]$Mdt)
        {
            $This.Object     = $VM
            $This.Name       = $VM.Name 
            $This.HostName   = $This.ResolveDNS() 
            $This.VmState    = $VM.State
            $This.VmStatus   = $VM.Status
            $This.VmId       = $VM.Id.Guid
            $This.MdtPercent = $Mdt.PercentComplete
            $This.MdtStatus  = $Mdt.DeploymentStatus
        }

        [String] ResolveDNS()
        {
            Return @( Resolve-DNSName $This.Name | % Name )
        }
    }

    Class _VMGroup
    {
        [String]           $Server
        [UInt32]             $Port
        [String[]]        $NamedVM
        [Object]               $VM
        [Object]              $MDT
        [Object]           $Output
        
        _VMGroup([String]$Server,[UInt32]$Port,[String[]]$NamedVM)
        {
            $This.Server   = $Server
            $This.Port     = $Port
            $This.NamedVM  = $NamedVM
        }

        Refresh()
        {
            $This.VM        = Get-VM | ? Name -in $This.NamedVM
            $This.MDT       = Get-MDTOData -Server $This.Server -Port $This.Port | ? Name -in $This.NamedVM
            $This.Output    = @( )

            ForEach ( $Item in $This.NamedVM )
            {
                $xVM         = $This.VM  | ? Name -eq $Item
                $xMDT        = $This.MDT | ? Name -eq $Item
                $This.Output += [_VMObject]::New($xVM,$xMDT)
            }
        }
    }
    
    $VM      = [_VMGroup]::New($Server,$Port,$NamedVM)

    Do
    {
        $VM.Refresh()
        $Status = $VM.Output | ? MdtPercent -ne 100
        Start-Sleep -Seconds 5
    }
    Until (!$Status)
}
