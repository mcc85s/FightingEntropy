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
        
        Class _Process
        {
            [String]      $NPM
            [String]       $PM
            [String]       $WS
            [String]      $CPU
            [String]       $ID
            [String]       $SI
            [String]     $Name
            
            _Process([Object]$Process)
            {
                $This.NPM  = "{0:n2}" -f ($Process.NonpagedSystemMemorySize/1KB)
                $This.PM   = "{0:n2}" -f ($Process.PagedMemorySize/1MB)
                $This.WS   = "{0:n2}" -f ($Process.WorkingSet/1MB)
                $This.CPU  = "{0:n2}" -f $Process.TotalProcessorTime.TotalSeconds
                $This.ID   = $Process.Id
                $This.SI   = $Process.SessionID
                $This.Name = $Process.ProcessName
            }
        }
        
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
            Hidden [Object] $Report
            Hidden [Object] $Line = (@(" ")*120 -join '')

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
                Write-Host " "
                Write-Host (@("-")*120 -join '')
                Write-Host "[$Label]"
                Write-Host (@("-")*120 -join '')
                Write-Host " "
            }
            
            HostInfo()
            {
                Write-Theme "Host info"
                Write-Host $This.Line
                
                $This.Report.HostInfo = @( )

                ForEach ( $Item in "Name DNS NetBIOS Hostname Username Principal IsAdmin Caption Version Build ReleaseID Code SKU Chassis" -Split " " )
                {
                    $Info = ("{0}{1}: {2}" -f $Item, (@(" ")*(20-$Item.Length) -join ''), $This.Role.$Item)
                    Write-Host $Info
                    $This.Report.HostInfo += $Info
                }
                Write-Host " "
            }
            
            ProcessInfo()
            {
                Write-Theme "Process info"
                Write-Host $This.Line
                
                $This.Report.ProcessInfo = @( )

                Write-Host "[     NPM] [      PM] [      WS] [       CPU] [     ID] [  SI] [                        ProcessName]"
                Write-Host (@("-") * 120 -join '' )
                Get-Process | % { [_Process]::New($_) } | % { 

                    $0 = ( @(" ") * (  8 -  $_.NPM.ToString().Length ) -join '' )
                    $1 = ( @(" ") * (  8 -   $_.PM.ToString().Length ) -join '' )
                    $2 = ( @(" ") * (  8 -   $_.WS.ToString().Length ) -join '' )
                    $3 = ( @(" ") * ( 10 -  $_.CPU.ToString().Length ) -join '' )
                    $4 = ( @(" ") * (  7 -   $_.ID.ToString().Length ) -join '' )
                    $5 = ( @(" ") * (  4 -   $_.SI.ToString().Length ) -join '' )
                    $6 = ( @(" ") * ( 35 - $_.Name.ToString().Length ) -join '' )

                    $Info = ("[$0{0}] [$1{1}] [$2{2}] [$3{3}] [$4{4}] [$5{5}] [$6{6}]" -f $_.NPM,$_.PM,$_.WS,$_.CPU,$_.ID,$_.SI,$_.Name )
                    Write-Host $Info
                    $This.Report.ProcessInfo += $Info
                }
                Write-Host " "
            }
            
            NetInterfaceInfo()
            {
                Write-Theme "Network interface(s)"
                Write-Host $This.Line
                
                $This.Report.NetInterfaceInfo = @( )

                ForEach ( $Interface in $This.Role.Network.Interface )
                {
                    Write-Host "[ ($($Interface.Description)) ]"
                    Write-Host " "
                    ForEach ( $Item in "Hostname Alias Index Description Status MacAddress Vendor" -Split " " )
                    {
                        Write-Host ("{0}{1}: {2}" -f $Item, (@(" ")*(20-$Item.Length) -join ''), $Interface.$Item)
                    }
                    Write-Host " "
                }
                Write-Host " "
            }

            NetActiveInfo()
            {
                Write-Theme "Active interface(s)"
                Write-Host $This.Line
                
                ForEach ( $Interface in $This.Role.Network.Active )
                {
                    Write-Host "[ ($($Interface.Description)) ]"
                    Write-Host " "
                    ForEach ( $Item in "Hostname Alias Index Description Status MacAddress Vendor" -Split " " )
                    {
                        Write-Host ("{0}{1}: {2}" -f $Item, (@(" ")*(20-$Item.Length) -join ''), $Interface.$Item)
                    }
                    Write-Host " "
                }
                Write-Host " "
            }

            NetStatInfo()
            {
                Write-Theme "Connection statistics"
                Write-Host $This.Line
                
                $This.Report.NetstatInfo = @( )

                $This.Role.Network.RefreshNetStat()
                Write-Host "[ Proto] [                LocalAddress] [    LPort] [               RemoteAddress] [    RPort] [     State] [ Direction]"
                $This.Role.Network.Netstat | % { 
                    
                    $0 = (@(" ")*(7-$_.Protocol.ToString().Length) -join '')
                    $1 = (@(" ")*(30-$_.LocalAddress.ToString().Length) -join '')
                    $2 = (@(" ")*(11-$_.LocalPort.ToString().Length) -join '')
                    $3 = (@(" ")*(30-$_.RemoteAddress.ToString().Length) -join '')
                    $4 = (@(" ")*(11-$_.RemotePort.ToString().Length) -join '')
                    $5 = (@(" ")*(12-$_.State.ToString().Length) -join '')
                    $6 = (@(" ")*(12-$_.Direction.ToString().Length) -join '')

                    $Info = ("$0{0} $1{1} $2{2} $3{3} $4{4} $5{5} $6{6}" -f $_.Protocol,$_.LocalAddress,$_.LocalPort,$_.RemoteAddress,$_.RemotePort,$_.State,$_.Direction)
                    Write-Host $Info
                    $This.Report.NetStatInfo += $Info
                }
                Write-Host " "
            }

            NetHostmapInfo()
            {
                Write-Theme "Network host(s)"
                Write-Host $This.Line
                
                $This.Report.NetHostmapInfo      = @( )
                ForEach ( $X in 0..($This.Role.Network.Hostmap.Count - 1) )
                { 
                    $Item = $This.Role.Network.Hostmap[$X]
                    If (!$Item.Hostname)
                    {
                        $Item.Hostname = "<host unknown/unnamed>"
                    }
                    
                    $Info = ("{0}{1}: {2}" -f (@(" ")*(30-$Item.IPAddress.ToString().Length) -join ''), $Item.IPAddress, $Item.Hostname)
                    Write-Host $Info
                    $This.Report.NetHostmapInfo += $Info
                }
            }

            ServiceInfo()
            {
                Write-Theme "Service info"
                Write-Host $This.Line
                
                $This.Report.ServiceInfo         = @( )

                $This.Role.Service.Output        | % {

                    $IDName = $_.Name
                    $IDInfo = $_.DisplayName

                    If ( $IDName.Length -gt 44 )
                    {
                        $IDName = "$($IDName[0..41] -join '')..."
                    }

                    If ( $IDInfo.Length -gt 44 )
                    {
                        $IDInfo = "$($IDInfo[0..41] -join '')..."
                    }

                    $0 = (@(" ")*( 3-$_.Index.ToString().Length) -join "")
                    $1 = (@(" ")*(45- $IDName.Length) -join "")
                    $2 = (@(" ")* 2 -join "")
                    $3 = (@(" ")*(8-$_.StartMode.ToString().Length) -join "")
                    $4 = (@(" ")*(8-$_.State.ToString().Length) -join "")
                    $5 = (@(" ")*(45-$IDInfo.Length) -join "")

                    $Info = ("[$0{0}] $1{1} $2{2} $3{3} $4{4} $5{5}" -f $_.Index, $IDName, [Int]$_.Scope, $_.StartMode, $_.State, $IDInfo)
                    Write-Host $Info
                    $This.Report.ServiceInfo += $Info
                }
            }
            
            Prime()
            {                
                Write-Theme "Priming FEModule API [(Processes, Network, Services)]"
                Write-Host $This.Line

                $This.Report         = @{

                    HostInfo         = @( )
                    ProcessInfo      = @( )
                    NetInterfaceInfo = @( )
                    NetActiveInfo    = @( )
                    NetStatInfo      = @( )
                    NetHostmapInfo   = @( )
                    ServiceInfo      = @( )
                }
                
                Write-Host "[~] Processes [~]"
                $This.Role.GetProcesses()

                Write-Host "[~] Network [~]"
                $This.Role.GetNetwork()

                Write-Host "[~] Services [~]"
                $This.Role.GetServices()

                $This.HostInfo()
                Start-Sleep 1
                
                $This.ProcessInfo()
                Start-Sleep 1
                
                $This.NetInterfaceInfo()
                Start-Sleep 1

                $This.NetActiveInfo()
                Start-Sleep 1
                
                $This.NetStatInfo()
                Start-Sleep 1
                
                $This.NetHostmapInfo()
                Start-Sleep 1
                
                $This.ServiceInfo()
                Start-Sleep 1
                
                Write-Host " "
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
