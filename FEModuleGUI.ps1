Function FEModuleGUI
{
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

    Class _FEModuleGUI
    {
        [Object] $Window
        [Object]     $IO
        [Object] $Module

        _FEModuleGUI()
        {
            $This.Window                 = Get-XamlWindow -Type FEModule
            $This.IO                     = $This.Window.IO
            $This.Module                 = Get-FEModule

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

    $FE = [_FEModuleGUI]::New()

    $FE.Window.Invoke()
}
