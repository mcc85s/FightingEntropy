
Function Set-AdminAccount
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory,Position=0)][String] $Domain ,
    [Parameter(Mandatory,Position=1)][String]   $Name ,
    [Parameter(Mandatory,Position=2)][String]   $Pass ,
    [Parameter(Mandatory,Position=3)][Bool]    $State )

    Enum WinlogonType
    {
        AutoAdminLogon
        AutoLogonCount
        DefaultUserName
        DefaultDomainName
        DefaultPassword
        ForceAutoLogon
        DisableCAD
    }

    Class WinlogonItem
    {
        [UInt32] $Index
        [String]  $Name
        [Object] $Value
        WinLogonItem([String]$Name)
        {
            $This.Index = [UInt32][WinLogonType]::$Name
            $This.Name  = $Name
        }
        Set([Object]$Value)
        {
            $This.Value = $Value
        }
    }

    Class WinLogonController
    {
        [String]     $Name
        [String]     $Path
        [String]   $Domain
        [String] $Username
        [String] $Password
        [Object] $Property
        WinLogonController([String]$Domain,[String]$Username,[String]$Pass)
        {
            $This.Name     = "WinLogon"
            $This.Path     = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
            $This.Domain   = $Domain
            $This.Username = $Username
            $This.Password = $Pass

            $This.Refresh()
        }
        [Object] WinLogonItem([String]$Name)
        {
            Return [WinLogonItem]::New($Name)
        }
        Clear()
        {
            $This.Property = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([WinLogonType]))
            {
                $This.Add($Name)
            }
        }
        Add([String]$Name)
        {
            $This.Property += $This.WinLogonItem($Name)
        }
        Slot([UInt32]$Mode)
        {
            $Item = Switch ($Mode)
            {
                0 { 0,   0, $This.Username, $This.Domain, $This.Password, 0, 0 }
                1 { 1, 999, $This.Username, $This.Domain, $This.Password, 1, 1 }
            }

            ForEach ($X in 0..($Item.Count-1))
            {
                $This.Property[$X].Set($Item[$X])
            }
        }
        [String] Status()
        {
            Return "[+] Admin account: [{0}/{1}]" -f $This.Domain, $This.Username
        }
        Set([UInt32]$Mode)
        {
            If ($Mode -notin 0,1)
            {
                Throw "Invalid mode"
            }
            $This.Slot($Mode)
        
            Write-Host ("{0} {1}" -f @("Disabling","Enabling")[$Mode], $This.Status())
        
            ForEach ($Property in $This.Property)
            {
                Set-ItemProperty -Path $This.Path -Name $Property.Name -Value $Property.Value -Verbose
            }
        }
    }

    [WinLogonController]::New($Domain,$Name,$Pass).Set($State)

}

Set-AdminAccount -Domain NETBIOS -Name Administrator -Pass [passworD1] -State 1
