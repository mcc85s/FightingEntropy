Function Get-FEModule
{
    [CmdLetBinding( DefaultParameterSetName = "Default",
                    HelpUri                 = "http://www.github.com/mcc85s/FightingEntropy" )]
    Param(                
        [Parameter(ParameterSetName =   "Default" )][Switch]       $All ,
        [Parameter(ParameterSetName =   "Classes" )][Switch]   $Classes , 
        [Parameter(ParameterSetName = "Functions" )][Switch] $Functions , 
        [Parameter(ParameterSetName =   "Control" )][Switch]   $Control , 
        [Parameter(ParameterSetName =  "Graphics" )][Switch]  $Graphics , 
        [Parameter(ParameterSetName =      "Role" )][Switch]      $Role ,
        [Parameter(ParameterSetName =       "GUI" )][Switch]       $GUI )
        
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
        [String] X([UInt32]$Width,[Object]$Value)
        {
            If ( $Value.Length -le 0 )
            {
                $Value = "0"
            }

            Return ("[{0}{1}]" -f ( @(" ") * ( $Width - $Value.Length ) -join '' ), $Value)
        }
        [String] ToString()
        {
            Return @($This.X(10,$This.NPM),$This.X(10,$This.PM),$This.X(10,$This.WS),
                     $This.X(10,$This.CPU),$This.X(6,$This.ID),$This.X( 6,$This.SI),
                     $This.X(44,$This.Name))
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
            
            Get-Process | % { 
                
                $Info = [_Process]::New($_)
                Write-Host $Info.ToString()
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
                $1 = (@(" ")*(45-$_.LocalAddress.ToString().Length) -join '')
                $2 = (@(" ")*(6-$_.LocalPort.ToString().Length) -join '')
                $3 = (@(" ")*(45-$_.RemoteAddress.ToString().Length) -join '')
                $4 = (@(" ")*(6-$_.RemotePort.ToString().Length) -join '')
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

                $0 = (@(" ")*( 4-$_.Index.ToString().Length) -join "")
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
        
    Class _NVList
    {
        [String]$Name
        [String]$Value
        _NVList([String]$Name,[String]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }
        
    Class _GUI
    {
        [Object] $Window
        [Object]     $IO
        [Object] $Module
        _GUI([String]$RegPath)
        {
            $This.Window                 = Get-XamlWindow -Type FEModule
            $This.IO                     = $This.Window.IO
            $This.IO.Title               = "[FightingEntropy({0})][(2021.6.0)]" -f [Char]960
            $This.Module                 = [_Module]::New((Get-ItemProperty $RegPath))

            $This.Prime()
        }
        ModuleInfo()
        {
            $This.IO.ModuleInfo.ItemsSource = @( )

            ForEach ( $Item in "Base Name Description Author Company Copyright GUID Version Date".Split(" ") )
            {
                $This.IO.ModuleInfo.ItemsSource += [_NVList]::New($Item,$This.Module.$Item)
            }
        }
        OSInfo()
        {
            $This.IO.OSInfo.ItemsSource = @( )

            ForEach ( $Item in "Ver Major Type" -Split " " )
            {
                $This.IO.OSInfo.ItemsSource += [_NVList]::New($Item,$This.Module.OS.$Item)
            }

            $This.IO.OSInfo.ItemsSource | ? Name -match Ver | % { $_.Name = "PSVersion" }
        }
        ManifestInfo()
        {
            ForEach ( $Item in "Classes Control Functions Graphics" -Split " " )
            {
                $This.IO."Manifest$Item".ItemsSource  = @( )

                ForEach ( $Object in $This.Module.Manifest.$Item )
                {
                    $This.IO."Manifest$Item".ItemsSource += [_NVList]::New($Object,"$($This.Module.Base)/$Item/$Object")
                }
            }
        }
        RegistryInfo()
        {
            $This.IO.RegistryInfo.ItemsSource = @( )
            $Reg = Get-ItemProperty $This.Module.RegPath

            ForEach ( $Item in "Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status Type" -Split " ")
            {
                $This.IO.RegistryInfo.ItemsSource += [_NVList]::New($Item,$Reg.$Item)
            }
        }
        TreeInfo()
        {
            ForEach ( $Item in "Classes Control Functions Graphics" -Split " " )
            {
                $This.IO."Tree$Item".ItemsSource  = @( )

                ForEach ( $Object in $This.Module.$Item )
                {
                    $This.IO."Tree$Item".ItemsSource += $Object
                }
            }
        }
        RoleInfo()
        {
            $This.IO.RoleInfo.ItemsSource = @( )

            ForEach ( $Item in "Name DNS NetBIOS Hostname Username Principal IsAdmin Caption Version Build ReleasedID Code SKU Chassis" -Split " " )
            {
                $This.IO.RoleInfo.ItemsSource += [_NVList]::New($Item,$This.Module.Role.$Item)
            }
        }
        ProcessInfo()
        {
            $This.IO.ProcessInfo.ItemsSource = @( )

            ForEach ( $Item in Get-Process | % { [_Process]::New($_) } )
            {
                $This.IO.ProcessInfo.ItemsSource += $Item
            }
        }
        InterfaceListInfo()
        {
            $This.IO.InterfaceList.ItemsSource = @( )

            ForEach ( $Item in $This.Module.Role.Network.Interface )
            {
                $This.IO.InterfaceList.ItemsSource += $Item
            }
        }
        ActiveListInfo()
        {
            $This.IO.ActiveList.ItemsSource = @( )

            ForEach ( $Item in $This.Module.Role.Network.Active )
            {
                $This.IO.ActiveList.ItemsSource += $Item
            }
        }
        ConnectionListInfo()
        {
            $This.IO.ConnectionList.ItemsSource = @( )

            ForEach ( $Item in $This.Module.Role.Network.Netstat )
            {
                $This.IO.ConnectionList.ItemsSource += $Item
            }
        }
        HostListInfo()
        {
            $This.IO.HostList.ItemsSource = @( )

            ForEach ( $Item in $This.Module.Role.Network.Hostmap )
            {
                $This.IO.HostList.ItemsSource += $Item
            }
        }
        ServiceListInfo()
        {
            $This.IO.ServiceList.ItemsSource = @( ) 

            ForEach ( $Item in $This.Module.Role.Service.Output )
            {
                $This.IO.ServiceList.ItemsSource += $Item
            }
        }
        Prime()
        {
            $This.Module.Role | % { 

                $_.GetProcesses()
                $_.GetNetwork()
                $_.GetServices()
            }

            $This.ModuleInfo()
            $This.OSInfo()
            $This.ManifestInfo()
            $This.RegistryInfo()
            $This.TreeInfo()
            $This.RoleInfo()
            $This.ProcessInfo()
            $This.InterfaceListInfo()
            $This.ActiveListInfo()
            $This.ConnectionListInfo()
            $This.HostListInfo()
            $This.ServiceListInfo()
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
    
    Switch($PSCmdLet.ParameterSetName)
    {
        Default   {[_Module]::New($RegPath)}
        Classes   {[_Module]::New($RegPath).Classes}
        Functions {[_Module]::New($RegPath).Functions}
        Control   {[_Module]::New($RegPath).Control}
        Graphics  {[_Module]::New($RegPath).Graphics}
        Role      {[_Module]::New($RegPath).Role}
        GUI       {[_GUI]::New($RegPath.RegPath).Window.Invoke()}
    }
}
