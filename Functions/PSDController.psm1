Function Write-PSDBootInfo
{
    Param ([String]$Message,[UInt32]$SleepSec=0)

    # Check for BGInfo
    If (!(Test-Path -Path "$env:SystemRoot\system32\bginfo.exe"))
    {
        Return
    }

    # Check for BGinfo file
    If (!(Test-Path -Path "$env:SystemRoot\system32\psd.bgi"))
    {
        Return
    }

    # Update background
    $Result = New-Item -Path HKLM:\SOFTWARE\PSD -ItemType Directory -Force
    $Result = New-ItemProperty -Path HKLM:\SOFTWARE\PSD -Name PSDBootInfo -PropertyType MultiString -Value $Message -Force
    & bginfo.exe "$env:SystemRoot\system32\psd.bgi" /timer:0 /NOLICPROMPT /SILENT
    
    If ($SleepSec -gt 0)
    {
        Start-Sleep -Seconds $SleepSec
    }
}

Function Get-PSDVolume
{
    # Shape volume class
    Class PSDVolume
    {
        Hidden [Object] $Volume
        [String] $GUID
        [String] $DriveType
        [String] $DriveLetter
        [UInt32] $WinPE
        [UInt32] $TSDrive
        [Uint32] $Media
        [String] $DeviceID
        PSDVolume([Object]$Volume)
        {
            $This.Volume      = $Volume
            $This.GUID        = [Regex]::Matches($Volume.DeviceID,"{$((8,4,4,4,12|%{"[a-f0-9]{$_}"}) -join "-")}")
            $This.DriveType   = $Volume.DriveType
            $This.DriveLetter = $Volume.DriveLetter
            $This.DeviceID    = $Volume.DeviceID
            
            # Checks if running WinPE
            If ($This.DriveLetter -eq "X:" -and $Env:SystemDrive -eq "X:")
            {
                $This.WinPE   = 1
            }

            # Checks if task sequence and variable data files exist
            If ((Test-Path "$($This.DriveLetter)\_SMSTaskSequence\TSEnv.dat") -or (Test-Path "$($This.DriveLetter)\Minint\Variables.dat"))
            {
                $This.TSDrive = 1
            }
        }
        [String] ToString()
        {
            Return @( "{0} # {1}" -f $This.DriveLetter, $This.DeviceID )
        }
    }
    Get-WmiObject Win32_Volume | ? DriveType -eq 3 | ? DriveLetter | % { [PSDVolume]::New($_) }
}

Function Get-PSDController
{
    Param([Object]$ScriptRoot)

    # PSD Controller object
    Class PSDConnection
    {
        [String] $DeployRoot
        [String] $UserID
        [String] $UserPassword
        PSDConnection([String]$DeployRoot,[String]$UserID,[String]$UserPassword)
        {
            $This.DeployRoot   = $DeployRoot
            $This.UserID       = $UserID
            $This.UserPassword = $UserPassword
        }
    }

    Class PSDProperty
    {
        [String] $Type
        [String] $Name
        [Object] $Value
        PSDProperty([UInt32]$Type,[String]$Name,[Object]$Value)
        {
            $This.Type  = @("Section","Comment","Key")[$Type]
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class PSDTestConnection
    {
        [String] $Protocol
        [UInt32] $Port
        [String] $ServerName
        [String] $RemotePath
        [String] $Status
        PSDTestConnection([String]$DeployRoot)
        {
            $This.RemotePath = $DeployRoot
            Switch -Regex ($DeployRoot)
            {
                "^http[s]*"
                {
                    $This.Protocol   = @("HTTP","HTTPS")[$DeployRoot -match "^https"]
                    $This.ServerName = $DeployRoot.Split("//")[2]
                }
                "^\\\\\w.+"
                {
                    $This.Protocol   = "SMB"
                    $This.ServerName = $DeployRoot.Split("\\")[2]
                }
            }

            $This.Port = Switch ($This.Protocol)
            {
                SMB { 445 } HTTP { 80 } HTTPS { 443 } WINRM { 5985 }
            }

            Try
            {
                $ips = [System.Net.Dns]::GetHostAddresses($This.ServerName) | ? AddressFamily -eq InterNetwork | % IPAddressToString
                If ($ips.GetType().Name -eq "Object[]")
                {
                    $ips
                }
            }
            Catch
            {
                Write-Verbose "DeployRoot: [$($This.ServerName)] may be misconfigured"
                $ips = "NA"
            }

            $maxAttempts = 5
            $attempts    = 0

            ForEach ($ip in $ips)
            {
                While ($true)
                {
                    $Attempts++
                    $TcpClient = New-Object Net.Sockets.TcpClient
                    Try
                    {
                        Write-Verbose "Testing $ip,$($This.Port), attempt $attempts"
                        $TcpClient.Connect($ip,$This.Port)
                    }
                    Catch
                    {
                        Write-Verbose "Attempt $attempts of $maxAttempts failed"
                        If ($attempts -ge $maxAttempts)
                        {
                            $This.Status = "Failed [!]"
                            Break
                        }
                        Else
                        {
                            Start-Sleep -Seconds 2
                        }
                    }
                    If ($TcpClient.Connected)
                    {
                        $TcpClient.Close()
                        $This.Status = "Success [+]"
                        Break
                    }
                    Else
                    {
                        $This.Status = "Failed [!]"
                        Break
                    }
                }
            }
        }
        [String] ToString()
        {
            Return $This.RemotePath
        }
    }

    Class PSDBootstrap
    {
        [String] $Path
        [Object] $Content
        PSDBootstrap([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            $This.Path     = $Path
            $This.GetContent()
        }
        [String] ToString()
        {
            Return $This.Path
        }
        GetContent()
        {
            $This.Content  = @( )
            $Slot          = $Null
            $Name          = $Null
            $Value         = $Null
            ForEach ($Line in Get-Content $This.Path)
            {
                Switch -Regex ($Line)
                {
                    "^\[(.+)\]$" # Section
                    {
                        $Name   = $Line -Replace "(\]|\[)",""
                        $Value  = "[]"
                        $This.Content += [PSDProperty]::New(0,$Name,$Value)
                    }
                    "^(;.*)$" # Comment
                    {
                        $Name   = $Line.TrimStart(";")
                        $Value  = "##"
                        $This.Content += [PSDProperty]::New(1,$Name,$Value)
                    }
                    "(.+?)\s*=\s*(.*)" # Key
                    {
                        $Name   = $Line.Split("=")[0]
                        $Value  = $Line.Substring(($Name.Length+1))
                        $This.Content += [PSDProperty]::New(2,$Name,$Value)
                    }
                    Default
                    {

                    }
                }
            } 
        }
        [Object] GetConnection()
        {
            $UserDomain   = $This.Content | ? Name -eq UserDomain   | % Value
            $UserID       = $This.Content | ? Name -eq UserID       | % Value
            $UserPassword = $This.Content | ? Name -eq UserPassword | % Value
            $UserName     = $Null
            If ($UserDomain -and $UserID) 
            { 
                $Username = "$UserDomain\$UserID" 
            }

            $DeployRoot   = $This.Content | ? Name -match "([PSD]*DeployRoot[s]*)" | % Value
            $ServerNames  = $DeployRoot -Split "," | % { [PSDTestConnection]::New($_) } | ? Status -match Success
            $Connections  = @(Get-SMBConnection)
            $Return       = @($ServerNames | ? ServerName -in $Connections.ServerName)
            If (!$Return)
            {
                $Return   = @( )
                ForEach ($Item in $ServerNames) 
                {
                    If ($Username -and $UserPassword)
                    {
                        New-SmbMapping -RemotePath $Item.RemotePath -Username $Username -Password $UserPassword
                        If ($? -eq $True)
                        {
                            $Return += (Get-SMBConnection | ? { "$($_.ServerName)\$($_.ShareName)" -match $Item.RemotePath })
                        }
                    }
                }
            }
            Return $Return
        }
    }

    Class PSDController
    {
        [String]   $Location
        [Object[]]   $Volume
        [Object] $ScriptRoot
        [Object] $DeployRoot
        [Object] $ModuleRoot
        [Object]  $Bootstrap
        [Object] $Connection
        [Object] $ModuleList
        [Object]    $Scripts
        [Object]    $Control
        [Object]      $Tools
        [Object]    $Modules
        PSDController([String]$ScriptRoot)
        {
            $This.Location       = Get-Location | % Path
            $This.Volume         = Get-PSDVolume
            If ($ScriptRoot)
            {
                $This.ScriptRoot = $ScriptRoot
            }
            $This.DeployRoot     = $This.ScriptRoot | Split-Path
            $This.ModuleRoot     = @("\Cache","" | % { "$($This.DeployRoot)$_\Tools\Modules" }) -join ";"
        }
        [String] GetBootstrap()
        {
            Return @(Get-Childitem $This.DeployRoot -Recurse | ? Name -eq Bootstrap.ini | % FullName | Select-Object -First 1)
        }
        StartBootstrap([String]$Path)
        {
            $This.Bootstrap      = [PSDBootstrap]::New($Path)
            $This.Connection     = $This.Bootstrap.GetConnection()
        }
    }

    $PSD       = [PSDController]::New($ScriptRoot)
    $Bootstrap = $PSD.GetBootstrap()
    If ($Bootstrap)
    {
        $PSD.StartBootstrap($Bootstrap)
    }
    $PSD
}
