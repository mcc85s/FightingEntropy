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
            
            Report()
            {
                $This.Prime()
                $This.HostInfo()
                $This.ProcessInfo()
                $This.NetworkInfo()
                $This.ServiceInfo()
            }
            
            HostInfo()
            {
                Write-Host "[Host Information]"
                $This.Role | Select-Object Name, DNS, NetBIOS, Hostname, Username, Principal, IsAdmin, Caption, Version, Build, ReleaseID, Code, SKU, Chassis
            }
            
            ProcessInfo()
            {
                Write-Host "[Process Information]"
                $This.Role.Process
            }
            
            NetworkInfo()
            {
                Write-Host "[Network Information]"
                $This.Role.Network.Interface | Format-Table
                
                Write-Host "[Active Network]"
                $This.Role.Network.Network | Format-Table
                
                Write-Host "[Network Statistics]"
                $This.Role.Network.Netstat | Format-Table
                
                Write-Host "[Network Host Map]"
                $This.Role.Network.Hostmap
            }
            
            ServiceInfo()
            {
                Write-Host "[Services Information]"
                $This.Role.Services.Output | Format-Table
            }
            
            Prime()
            {
                Write-Host "[~] Processes [~]"
                $This.Role.GetProcesses()

                Write-Host "[~] Network [~]"
                $This.Role.GetNetwork()

                Write-Host "[~] Services [~]"
                $This.Role.GetServices()
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
