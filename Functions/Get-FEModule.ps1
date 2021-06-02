Function Get-FEModule
{
    [CmdLetBinding( DefaultParameterSetName = "Default",
                    HelpUri                 = "http://www.github.com/mcc85sx/FightingEntropy" )]
    Param(                
        [Parameter( ParameterSetName        = "Default"     )][Switch]          $All ,
        [Parameter( ParameterSetName        = "Classes"     )][Switch]      $Classes , 
        [Parameter( ParameterSetName        = "Functions"   )][Switch]    $Functions , 
        [Parameter( ParameterSetName        = "Control"     )][Switch]      $Control , 
        [Parameter( ParameterSetName        = "Graphics"    )][Switch]     $Graphics , 
        [Parameter( ParameterSetName        = "Role"        )][Switch]         $Role )
        
        Class _Module
        {
            [String]        $Base
            [String]        $Name
            [String] $Description
            [String]      $Author
            [String]     $Company
            [String]   $Copyright
            [String]        $GUID
            [String]     $Version
            [String]        $Date
            [Object]          $OS
            [Object]    $Manifest
            [Object]     $RegPath
            [String]     $Default
            [String]        $Main
            [String]       $Trunk
            [String]     $ModPath
            [String]     $ManPath
            [String]        $Path
            [Object]        $Tree

            [Object[]]   $Classes
            [Object[]]   $Control
            [Object[]] $Functions
            [Object[]]  $Graphics

            [Object]      $Status
            [Object]        $Type
            [Object]        $Role

            _Module([Object]$ID)
            {
                $This.Base        = $ID.Base
                $This.Name        = $ID.Name
                $This.Description = $ID.Description
                $This.Author      = $ID.Author
                $This.Company     = $ID.Company
                $This.Copyright   = $ID.Copyright
                $This.GUID        = $ID.GUID
                $This.Version     = $ID.Version
                $This.Date        = $ID.Date
                $This.OS          = Get-FEOS
                $This.Manifest    = Get-FEManifest
                $This.RegPath     = $ID.RegPath
                $This.Default     = $ID.Default
                $This.Main        = $ID.Main
                $This.Trunk       = $ID.Trunk
                $This.ModPath     = $ID.ModPath
                $This.ManPath     = $ID.ManPath
                $This.Path        = $ID.Path
                $This.Status      = $ID.Status

                $This.Tree        = Get-ChildItem $This.Path | ? Name -in $This.Manifest.Names
                $This.Classes     = $This.Tree | ? Name -eq Classes  | Get-ChildItem
                $This.Control     = $This.Tree | ? Name -eq Control  | Get-ChildItem
                $This.Functions   = $This.Tree | ? Name -eq Functions| Get-ChildItem
                $This.Graphics    = $This.Tree | ? Name -eq Graphics | Get-ChildItem
                $This.Type        = $This.OS.Type
                $This.Role        = Get-FERole
            }
            
            Section([String]$Label)
            {
                Write-Host (@("-")*120 -join '')
                Write-Host "[$Label]"
                Write-Host (@("-")*120 -join '')
            }
            
            Report()
            {
                $Report = @{ 
                
                    HostInfo     = $This.Role | Select-Object Name, DNS, NetBIOS, Hostname, Username, Principal, IsAdmin, Caption, 
                                                              Version, Build, ReleaseID, Code, SKU, Chassis
                    ProcessInfo  = $This.Role | Select-Object Process
                    NetInterface = $This.Role.Network.Interface | Format-Table
                    NetActive    = $This.Role.Network.Network | Format-Table
                    NetStat      = $This.Role.Network.Netstat | Format-Table
                    Hostmap      = $This.Role.Network.Hostmap
                    ServiceInfo  = $This.Role.Service.Output | Format-Table
                }
                
                $This.Section("Host information")
                Write-Host $Report.HostInfo
                
                $This.Section("Process information")
                Write-Host $Report.ProcessInfo
                
                $This.Section("Network information")
                Write-Host $Report.NetInterface
                
                $This.Section("Active interface(s)")
                Write-Host $Report.NetActive
                
                $This.Section("Connection statistics")
                Write-Host $Report.NetStat
                
                $This.Section("Network host(s)")
                Write-Host $Report.Hostmap
                
                $This.Section("Services Information")
                Write-Host $Report.ServiceInfo
            }
            
            Prime()
            {
                $This.Section(
                Write-Host "[~] Processes [~]"
                $This.Role.GetProcesses()

                Write-Host "[~] Network [~]"
                $This.Role.GetNetwork()

                Write-Host "[~] Services [~]"
                $This.Role.GetServices()
                
                $This.Report()
            }
        }
        
        $Name      = "FightingEntropy"
        $Company   = "Secure Digits Plus LLC"
        $Default   = "HKLM:\Software\Policies\$Company\$Name"
        If (!(Test-Path $Default))
        {
            Throw "Installation not found"
        }
        
        $Item      = Get-Item $Default
        If (-not $Item)
        {
            Throw "Registry not found"
        }
        
        $Child     = Get-ChildItem $Default
        If (-not $Child)
        {
            Throw "No version detected"
        }
        
        If ($Child.Count -gt 1)
        {
            $Child = $Child[-1]
        }
        
        $RegPath   = Get-ItemProperty $Child.GetValue("RegPath")
        $Mod       = [_Module]::New($RegPath)
        
        Switch ($PSCmdLet.ParameterSetName)
        {   
            Default   {$Mod}
            Classes   {$Mod.Classes}
            Functions {$Mod.Functions}
            Control   {$Mod.Control}
            Graphics  {$Mod.Graphics}
            Role      {$Mod.Role}
        }
}
