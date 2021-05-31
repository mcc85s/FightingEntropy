Function Start-VMGroup
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String[]]$NamedVM)

    Class _VMObject
    {
        [Object] $Object
        [String] $Name
        [String] $State
        [String] $VMPath
        [String] $VHDPath
        [String] $VMSwitch

        _VMObject([Object]$VM,[String]$VMPath,[String]$VHDPath,[String]$VMSwitch)
        {
            $This.Object    = $VM 
            $This.Name      = $VM.Name
            $This.State     = $VM.State
            $This.VMPath    = $VMPath
            $This.VHDPath   = $VHDPath
            $This.VMSwitch  = $VMSwitch
        }
    }

    $VMHost      = Get-VMHost
    $VMSwitch    = Get-VMSwitch | % Name
    $VMPath      = $VMHost.VirtualMachinePath
    $AllVM       = @( )
    Get-VM       | % { 
    
        $VHDPath = "{0}\{1}.vhdx" -f $VMHost.VirtualHardDiskPath,$_.Name
        $AllVM  += [_VMObject]::New($_,$VMPath,$VHDPath,$VMSwitch)
    }
    
    $AllVM       | ? Name -in $NamedVM  | % { 
    
        Stop-VM -Name $_.Name -Force -EA 0 -Verbose
        Remove-VM -Name $_.Name -Force -EA 0 -Verbose
    }

    $AllVM       = $AllVM | ? Name -notin $NamedVM
    $NamedVM     | % { 

        $VHDPath = "{0}\{1}.vhdx" -f $VMHost.VirtualHardDiskPath,$_
        If (Test-Path $VHDPath)
        {
            Remove-Item -Path $VHDPath -Force -EA 0 -Verbose
        }

        New-VM -Name $_ -MemoryStartupBytes 4GB -Path $VMPath -NewVHDPath $VHDPath -NewVHDSizeBytes 40GB -Generation 2 -SwitchName $VMSwitch
        Set-VM -Name $_ -ProcessorCount 2
        $Item = Get-VM -Name $_
        $AllVM  += [_VMObject]::New($Item,$VMPath,$VHDPath,$VMSwitch)
    }
    
    $AllVM       = Get-VM       
    $VM          = $AllVM | ? Name -in $NamedVM 
    $VM          | ? State -ne Running | Start-VM -Verbose
}
