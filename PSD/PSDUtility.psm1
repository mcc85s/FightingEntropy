<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : PSDUtility.psm1                                                                          //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : General utility calls for PSD (Logging/Pathing/Variables).                               //   
   \\        Author     : Original [PSD Development Team], Michael C. Cook Sr.                                     \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-08                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11/08/2022 19:40:13    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

# Import main module Microsoft.BDD.TaskSequenceModule
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global -Force -Verbose:$True

# Check for debug in PowerShell and TSEnv
If ($TSEnv:PSDDebug -eq "YES")
{
    $Global:PSDDebug = $True
}

If ($PSDDebug -eq $True)
{
    $verbosePreference = "Continue"
}

$Global:psuDataPath = $Null
$caller             = Split-Path -Path $MyInvocation.PSCommandPath -Leaf

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
        [UInt32] $Media
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
            If ((Test-Path "$($This.DriveLetter)\_SMSTaskSequence\TSEnv.dat") -and (Test-Path "$($This.DriveLetter)\Minint\Variables.dat"))
            {
                $This.TSDrive = 1
            }
        }
    }
    Get-WmiObject Win32_Volume | ? DriveType -eq 3 | ? DriveLetter | % { [PSDVolume]::New($_) }
}

Function Get-PSDLocalDataPath
{
    Param([Switch]$Move)

    # Return the cached local data path if possible
    If ($Global:psuDataPath -eq "" -and !($move))
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psuDataPath is $psuDataPath, testing access"
        If (Test-Path $global:psuDataPath)
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Returning data $global:psuDataPath"
            Return $global:psuDataPath
        }
    }

    # Always prefer the OS volume
    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Always prefer the OS volume"

    $LocalPath = ""
    If ($tsenv:OSVolumeGuid -ne "")
    {
        If ($tsenv:OSVolumeGuid -eq "MBR")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:OSVolumeGuid is now $($tsenv:OSVolumeGuid)"
            If ($tsenv:OSVersion -eq "WinPE")
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:OSVersion is now $($tsenv:OSVersion)"

                # If the OS volume GUID is not set, we use the fake volume guid value "MBR"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Get the OS image details (MBR)"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Using OS volume from tsenv:OSVolume: $($tsenv:OSVolume)."
                $LocalPath = "$($tsenv:OSVolume):\MININT"
            }
            Else
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:OSVersion is now $($tsenv:OSVersion)"
                # If the OS volume GUID is not set, we use the fake volume guid value "MBR"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Get the OS image details (MBR)"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Using OS volume from env:SystemDrive $($env:SystemDrive)."
                $LocalPath = "$($env:SystemDrive)\MININT"
            }
        }
        Else
        {
            # If the OS volume GUID is set, we should use that volume (UEFI)
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Get the OS image details (UEFI)"
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking for OS volume using $($tsenv:OSVolumeGuid)."
            $LocalPath = Get-PSDVolume | ? GUID -eq $tsenv:OSVolumeGUID | % { "$($_.DriveLetter)\MININT" }
        }
    }
    
    If ($LocalPath -eq "")
    {
        # Look on all other volumes 
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking other volumes for a MININT folder."
        $LocalPath = Get-PSDVolume | % { "$($_.DriveLetter)\MININT" } | ? { Test-Path $_ }
    }
    
    # Not found on any drive, create one on the current system drive
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Not found on any drive, create one on the current system drive"
    If ($LocalPath -eq "")
    {
        $LocalPath = "$($env:SYSTEMDRIVE)\MININT"
    }
    
    # Create the MININT folder if it doesn't exist
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Create the MININT folder if it doesn't exist"
    If (!(Test-Path $LocalPath))
    {
        New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
    }
    
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): localpath set to $LocalPath"
    $global:psuDataPath = $LocalPath
    Return $LocalPath
}

Function Initialize-PSDFolder
{
    Param($FolderPath) 

    If (!(Test-Path $FolderPath))
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating $FolderPath"
        New-Item -ItemType Directory -Force -Path $FolderPath | Out-Null
    }
}

Function Start-PSDLogging
{
    Param($Logpath="")
    
    If ($Logpath -eq "")
    {
        $LogPath = "$(Get-PSDLocalDataPath)\SMSOSD\OSDLOGS"
    }
    Initialize-PSDfolder $LogPath

    If ($PSDDeBug -eq $True)
    {
        Start-Transcript "$LogPath\$Caller.transcript.log" -Append
        $Global:PSDTranscriptLog = "$LogPath\$Caller.transcript.log"
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Logging Transcript to $Global:PSDTranscriptLog"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Logging Transcript to $Global:PSDTranscriptLog"
    }

    # Writing to CMtrace file
    # Set PSDLogPath
    $PSDLogFile = "$($($Caller).Substring(0,$($Caller).Length-4)).log"
    $Global:PSDLogPath = "$LogPath\$PSDLogFile"
    
    #Create logfile
    If (!(Test-Path $Global:PSDLogPath))
    {
        ## Create the log file
        New-Item $Global:PSDLogPath -Type File | Out-Null
    } 

    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Logging CMtrace logs to $Global:PSDLogPath"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Logging CMtrace logs to $Global:PSDLogPath"
}

Function Stop-PSDLogging
{
    If ($PSDDebug -ne $True)
    {
        Return
    }
    Try 
    {
        Stop-Transcript | Out-Null 
    } 
    Catch 
    { 

    }

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Stop Transcript Logging"
}

Function Write-PSDLog
{
    Param([Parameter(Mandatory)]           [String]$Message,
          [Parameter()][ValidateSet(1,2,3)][UInt32]$LogLevel=1)

    # Don't log any lines containing the word password
    If ($Message -like '*password*')
    {
        $Message = "<Not allowed to see the password, boss man...>"
    }
    
    # Check if we have a logpath set
    If ($Global:PSDLogPath -ne $null)
    {
        If (!(Test-Path -Path $Global:PSDLogPath))
        {
            ## Create the log file
            New-Item $Global:PSDLogPath -Type File | Out-Null
        }

        $Time, $Date = (Get-Date -Format "HH:mm:ss.fff+000 MM-dd-yyyy") -Split " "
        $Component   = $MyInvocation | % { "{0}:{1}" -f ($_.ScriptName | Split-Path -Leaf), $_.ScriptLineNumber }
        $Line        = "<![LOG[$Message]LOG]!><time='$Time' date='$Date' component='$Component' context='' type='$LogLevel' thread='' file=''>".Replace("'",'"')

        # Log to scriptfile
        Add-Content -Value $Line -Path $Global:PSDLogPath

        # Log to masterfile
        Add-Content -Value $Line -Path (($Global:PSDLogPath | Split-Path) + "\PSD.log")
    }

    If ($PSDDebug -eq $True)
    {
        Switch ($LogLevel)
        {
            1 {Write-Verbose -Message $Message} 2 {Write-Warning -Message $Message} 3 {Write-Error -Message $Message} Default {}
        }
    }
}

Start-PSDLogging

Function Save-PSDVariables
{
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Running Save-PSDVariables"
    $PSDLocaldataPath = Get-PSDLocalDataPath
    $V                = [xml]"<?xml version=`"1.0`" ?><MediaVarList Version=`"4.00.5345.0000`"></MediaVarList>"

    ForEach ($Item in Get-ChildItem TSEnv:)
    {
        $Element      = $V.CreateElement("var")
        $Element.SetAttribute("name",$Item.Name) | Out-Null
        $Element.AppendChild($V.CreateCDATASection($Item.Value)) | Out-Null
        $V.DocumentElement.AppendChild($Element) | Out-Null
    }
    
    $Path             = "$PSDLocaldataPath\Variables.dat"
    $V.Save($Path)
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): PSDVariables are saved in: $Path"
    $Path
}

Function Restore-PSDVariables
{
    $Path = "$(Get-PSDLocaldataPath)\Variables.dat"

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Restore-PSDVariables from $Path"
    If (Test-Path -Path $Path)
    {
        [Xml]$V = Get-Content -Path $Path
        $V | Select-Xml -Xpath "//var" | % { Set-Item tsenv:$($_.Node.Name) -Value $_.Node.'#cdata-section' }
    }
    Return $Path
}

Function Clear-PSDInformation
{
    # Create a folder for the logs
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Create a folder for the logs"
    $LogDest = "$($env:SystemRoot)\Temp\DeploymentLogs"
    Initialize-PSDFolder $LogDest

    # Process each volume looking for MININT folders
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Process each volume looking for MININT folders"
    $Select   = Get-PSDVolume | ? { Test-Path "$($_.DriveLetter)\MININT" }

    $LocalPath = "$($Select.DriveLetter)\MININT"

    # Copy PSD logs
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy PSD logs"
    If (Test-Path "$localPath\SMSOSD\OSDLOGS")
    {
        Write-Verbose "Copy-Item $LocalPath\SMSOSD\OSDLOGS\* $LogDest"
        Copy-Item "$localPath\SMSOSD\OSDLOGS\*" $LogDest -Force
    }

    # Copy Panther,Debug and other logs
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy Panther,Debug and other logs"
    If (Test-Path "$env:SystemRoot\Panther")
    {
        New-Item -Path "$LogDest\Panther" -ItemType Directory -Force | Out-Null
        New-Item -Path "$LogDest\Debug"   -ItemType Directory -Force | Out-Null
        New-Item -Path "$LogDest\Panther\UnattendGC" -ItemType Directory -Force | Out-Null

        # Check for log files in different locations
        $Logfiles = @("wpeinit",
        "Debug\DCPROMO",
        "Debug\DCPROMOUI",
        "Debug\Netsetup",
        "Panther\cbs_unattend",
        "Panther\setupact",
        "Panther\setuperr",
        "Panther\UnattendGC\setupact",
        "Panther\UnattendGC\setuperr" | % { "$_.log" })

        ForEach ($Logfile in $Logfiles)
        {
            $Sources = "$env:TEMP\$Logfile","$env:SystemRoot\$Logfile","$env:SystemRoot\System32\$Logfile","$env:Systemdrive\`$WINDOWS.~BT\Sources"
            ForEach ($Source in $Sources)
            {
                If (Test-Path -Path "$Source")
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name): Copying $Source to $logDest\$Logfile"
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copying $Source to $logDest\$Logfile"
                    Copy-Item -Path "$Source" -Destination $logDest\$Logfile
                }
            }
        }
    }

    # Copy SMSTS log
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy SMSTS log"
    If (Test-Path "$env:LOCALAPPDATA\temp\smstslog\smsts.log")
    {
        Copy-Item -Path "$env:LOCALAPPDATA\temp\smstslog\smsts.log" -Destination $logDest
    }

    # Copy variables.dat (TODO: Password needs to be cleaned out)
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy variables.dat (TODO)"
    if (Test-Path "$localPath\Variables.dat")
    {
        Copy-Item "$localPath\Variables.dat" $logDest -Force
    }

    # Check if DEVRunCleanup is set to NO
    If ($($tsenv:DEVRunCleanup) -eq "NO")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:DEVRunCleanup is now $tsenv:DEVRunCleanup."
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Cleanup will not remove MININT or Drivers folder."
    }
    Else
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:DEVRunCleanup is now $tsenv:DEVRunCleanup."
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Cleanup will remove MININT and Drivers folder."
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): This will be the last log entry."

        # Remove the MININT folder
        If (Test-Path -Path "$localPath")
        {
            Remove-Item "$localPath" -Recurse -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        
        # Remove the Drivers folder
        If (Test-Path -Path "$($env:Systemdrive + "\Drivers")")
        {
            Remove-Item "$($env:Systemdrive + "\Drivers")" -Recurse -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }

    # Remove shortcut to PSDStart.ps1 if it exists
    $allUsersStartup = [Environment]::GetFolderPath('CommonStartup')
    $linkPath        = "$allUsersStartup\PSDStartup.lnk"
    If (Test-Path $linkPath)
    {
        $Null = Get-Item -Path $linkPath | Remove-Item -Force
    }

    # Cleanup AutoLogon
    $Null = New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 0 -Force
    $Null = New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "" -Force
    $Null = New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "" -Force
}

Function Copy-PSDFolder
{
    Param (
    [Parameter(Mandatory,Position=0)][String]$Source,
    [Parameter(Mandatory,Position=1)][String]$Destination)

    $s = $source.TrimEnd("\")
    $d = $destination.TrimEnd("\")
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copying folder [$source] to [$destination] using XCopy"
    & xcopy $s $d /s /e /v /d /y /i | Out-Null
}

Function Test-PSDNetCon
{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory)][String]$Hostname,
        [Parameter(Mandatory)][String]$Protocol)

    $Port = Switch ($Protocol)
    {
        SMB { 445 } HTTP { 80 } HTTPS { 443 } WINRM { 5985 } Default { Exit }
    }

    Try
    {
        $ips = [System.Net.Dns]::GetHostAddresses($hostname) | ? AddressFamily -eq InterNetwork | % IPAddressToString
        If ($ips.GetType().Name -eq "Object[]")
        {
            $ips
        }
    }
    Catch
    {
        Write-Verbose "Possibly $hostname is wrong hostname or IP"
        $ips = "NA"
    }

    $maxAttempts = 5
    $attempts    = 0

    ForEach ($ip in $ips)
    {
        While($true)
        {
            $Attempts++
            $TcpClient = New-Object Net.Sockets.TcpClient
            Try
            {
                Write-Verbose "Testing $ip,$port, attempt $attempts"
                $TcpClient.Connect($ip,$port)
            }
            Catch
            {
                Write-Verbose "Attempt $attempts of $maxAttempts failed"
                If ($attempts -ge $maxAttempts)
                {
                    Throw
                }
                Else
                {
                    Start-Sleep -Seconds 2
                }
            }
            If ($TcpClient.Connected)
            {
                $TcpClient.Close()
                $Result = $True
                Return $Result
                Break
            }
            Else
            {
                $Result = $False
            }
        }
        Return $Result
    }
}

Function Get-PSDDriverInfo
{
    Param($Path=$Driver.FullName)

    # Get filename
    $InfName          = $Path | Split-Path -Leaf

    $Pattern          = 'DriverVer'
    $Content          = Get-Content -Path $Path
    #$DriverVer       = $Content | Select-String -Pattern $Pattern
    $DriverVer        = (($Content | Select-String -Pattern $Pattern -CaseSensitive) -Replace '.*=(.*)','$1') -Replace ' ','' -Replace ',','-' -Split "-"

    $DriverVersion    = ($DriverVer[1] -Split ";")[0]

    $Pattern          = 'Class'
    $Content          = Get-Content -Path $Path
    $Class            = ((($Content | Select-String -Pattern $Pattern) -notlike "ClassGUID*"))[0] -Replace " ","" -Replace '.*=(.*)','$1' -Replace '"',''

    $Provider         = ($Content | Select-String '^\s*Provider\s*=.*') -Replace '.*=(.*)','$1'
    If ($Provider.Length -eq 0) 
    {
        $Provider     = ""
    }
    ElseIf ($Provider.Length -gt 0 -And $Provider -is [System.Array]) 
    {
        If ($Provider.Length -gt 1 -And $Provider[0].Trim(" ").StartsWith("%")) 
        {
            $Provider = $Provider[1];
        } 
        Else 
        {
            $Provider = $Provider[0]
        }
    }
    $Provider         = $Provider.Trim(' ')

    If ($Provider.StartsWith("%")) 
    {
        $Provider = $Provider.Trim('%')
        $Manufacter = ($Content | Select-String "^$Provider\s*=") -Replace '.*=(.*)','$1'
    }
    Else 
    {
        $Manufacter = ""
    }    

    If ($Manufacter.Length -eq 0) 
    {
        $Manufacter = $Provider
    } 
    ElseIf ($Manufacter.Length -gt 0 -And $Manufacter -is [system.array]) 
    {
        If ($Manufacter.Length -gt 1 -And $Manufacter[0].Trim(" ").StartsWith("%"))
        {
            $Manufacter = $Manufacter[1];
        }
        Else 
        {
            $Manufacter = $Manufacter[0];
        }
    }
    $Manufacter         = $Manufacter.Trim(' ').Trim('"')

    $HashTable          = [Ordered]@{
        Name            = $InfName
        Manufacturer    = $Manufacter
        Class           = $Class
        Date            = $DriverVer[0]
        Version         = $DriverVersion
    }
    
    New-Object -TypeName PSObject -Property $HashTable
}

Function Show-PSDInfo
{
    Param($Message,[ValidateSet("Information","Warning","Error")]$Severity="Information",$OSDComputername,$Deployroot)

    $File = {
    Param($Message,$Severity="Information",$OSDComputername,$Deployroot)
    
    $BackColor, $Label1Text = Switch ($Severity)
    {
        Error {"salmon","Error"} 
        Warning {"yellow","Warning"} 
        Information {"#F0F0F0","Information"} 
        Default {"#F0F0F0","Information"}
    }

    Get-WmiObject Win32_ComputerSystem        | % { $Manufacturer = $_.Manufacturer; 
                                                    $Model        = $_.Model; 
                                                    $Memory       = [int]($_.TotalPhysicalMemory/1024/1024)}
    Get-WmiObject Win32_ComputerSystemProduct | % { $UUID         = $_.UUID }
    Get-WmiObject Win32_BaseBoard             | % { $Product      = $_.Product;
                                                    $SerialNumber = $_.SerialNumber }
    Try
    {
        Get-SecureBootUEFI -Name SetupMode | Out-Null 
        $BIOSUEFI = "UEFI"
    }
    Catch
    {
        $BIOSUEFI = "BIOS"
    }

    Get-WmiObject Win32_SystemEnclosure | % {
        $AssetTag    = $_.SMBIOSAssetTag.Trim()
        $ChassisType = Switch([UInt32]$_.ChassisTypes[0])
        {
            {$_ -in 8..12+14,18,21} {"Laptop"}
            {$_ -in 3..7+15,16}     {"Desktop"}
            {$_ -in 23}             {"Server"}
            {$_ -in 34..36}         {"Small Form Factor"}
            {$_ -in 30..32+13}      {"Tablet"}
        }
    }

    $ipList  = @()
    $macList = @()
    $gwList  = @()

    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | % {
        $_.IPAddress            | % { $ipList  += $_ }
        $_.MacAddress           | % { $macList += $_ }
        If ($_.DefaultIPGateway) 
        {
            $_.DefaultIPGateway | % { $gwList  += $_ }
        }
    }
    $IPAddress      = $ipList
    $MacAddress     = $macList
    $DefaultGateway = $gwList

    Try
    {
        Add-Type -AssemblyName System.Windows.Forms -IgnoreWarnings
        [System.Windows.Forms.Application]::EnableVisualStyles()
    }
    Catch [System.UnauthorizedAccessException] {
        # This should never happen, but we're catching if it does anyway.
        Start-Process PowerShell -ArgumentList {
            Write-warning -Message 'Access denied when trying to load required assemblies, cannot display the summary window.'
            Pause
        } -Wait
        Exit 1
    }
    Catch [System.Exception] {
        # This should never happen either, but we're catching if it does anyway.
        Start-Process PowerShell -ArgumentList {
            Write-warning -Message 'Unable to load required assemblies, cannot display the summary window.'
            Pause
        } -Wait
        Exit 1
    }

    $Form                        = New-Object System.Windows.Forms.Form
    $Form.ClientSize             = '600,390'
    $Form.text                   = "PowerShell Deployment"
    $Form.StartPosition          = "CenterScreen"
    $Form.BackColor              = $BackColor
    $Form.TopMost                = $true
    $Form.Icon                   = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")

    $Label                       = @( )
    $Text                        = @($Label1Text,"OSDComputername: $OSDComputername","DeployRoot: $Deployroot","Model: $Model",
                                    "Manufacturer: $Manufacturer","Memory(MB): $Memory","BIOS/UEFI: $BIOSUEFI","SerialNumber: $SerialNumber",
                                    "UUID: $UUID","ChassisType: $ChassisType")
    $Location                    = @(10,180,200,220,240,260,280,300,320,340)

    0..9                         | % { 
        $Item                    = [System.Windows.Forms.Label]::New()
        $Item.Text               = $Text[$_]
        $Item.AutoSize           = $True
        $Item.Width              = 25
        $Item.Height             = 10
        $Item.Location           = New-Object System.Drawing.Point(25,$Location[$_])
        $Item.Font               = ("Segoe UI,{0}" -f @(10,14)[$_ -eq 0])
        $Label                  += $Item
    }

    $TextBox1                        = New-Object System.Windows.Forms.TextBox
    $TextBox1.MultiLine              = $True
    $TextBox1.Width                  = 550
    $TextBox1.Height                 = 100
    $TextBox1.Location               = New-Object System.Drawing.Point(25,60)
    $TextBox1.Font                   = 'Segoe UI,12'
    $TextBox1.Text                   = $Message
    $TextBox1.ReadOnly               = $True

    $Button1                         = New-Object System.Windows.Forms.Button
    $Button1.text                    = "Ok"
    $Button1.width                   = 60
    $Button1.height                  = 30
    $Button1.location                = New-Object System.Drawing.Point(500,300)
    $Button1.Font                    = 'Segoe UI,12'

    $Form.Controls.AddRange(@($Label[0..9];$TextBox1,$Button1))

    $Button1.Add_Click({ Ok })
    
    Function Ok ()
    {
        $Form.Close()
    }

    [void]$Form.ShowDialog()
    }

    $ScriptFile = "$Env:Temp\Show-PSDInfo.ps1"
    $File | Out-File -Width 255 -FilePath $ScriptFile

    If (($OSDComputername -eq "") -or ($OSDComputername -eq $null))
    {
        $OSDComputername = $env:COMPUTERNAME
    }
    If (($Deployroot -eq "") -or ($Deployroot -eq $null))
    {
        $Deployroot = "NA"
    }

    Start-Process -FilePath PowerShell.exe -ArgumentList $ScriptFile, "'$Message'", $Severity, $OSDComputername, $Deployroot

    #$ScriptFile = $env:TEMP + "\Show-PSDInfo.ps1"
    #$RunFile = $env:TEMP + "\Show-PSDInfo.cmd"
    #$File | Out-File -Width 255 -FilePath $ScriptFile
    #Set-Content -Path $RunFile -Force -Value "PowerShell.exe -File $ScriptFile -Message ""$Message"" -Severity $Severity -OSDComputername $OSDComputername -Deployroot $Deployroot"
    #Start-Process -FilePath $RunFile
}

Function Get-PSDInputFromScreen
{
    Param($Header,$Message,[ValidateSet("Ok","Yes")]$ButtonText,[switch]$PasswordText)

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $Form                     = New-Object System.Windows.Forms.Form
    $Form.Text                = $Header
    $Form.Size                = New-Object System.Drawing.Size(400,200)
    $Form.StartPosition       = 'CenterScreen'

    $Button1                  = New-Object System.Windows.Forms.Button
    $Button1.Location         = New-Object System.Drawing.Point(290,110)
    $Button1.Size             = New-Object System.Drawing.Size(80,30)
    $Button1.Text             = $ButtonText
    $Button1.DialogResult     = [System.Windows.Forms.DialogResult]::OK
    $Form.AcceptButton        = $Button1
    $Form.Controls.Add($Button1)

    $Label1                   = New-Object System.Windows.Forms.Label
    $Label1.Location          = New-Object System.Drawing.Point(10,20)
    $Label1.Size              = New-Object System.Drawing.Size(360,20)
    $Label1.Text              = $Message
    $Form.Controls.Add($Label1)

    If ($PasswordText)
    {
        $TextBox              = New-Object System.Windows.Forms.MaskedTextBox
        $TextBox.Location     = New-Object System.Drawing.Point(10,60)
        $TextBox.Size         = New-Object System.Drawing.Size(360,20)
        $TextBox.PasswordChar = '*'
        $Form.Controls.Add($TextBox)
    }
    Else
    {
        $TextBox              = New-Object System.Windows.Forms.TextBox
        $TextBox.Location     = New-Object System.Drawing.Point(10,60)
        $TextBox.Size         = New-Object System.Drawing.Size(360,20)
        $Form.Controls.Add($TextBox)
    }

    $Form.Topmost             = $True
    $Form.Add_Shown({$TextBox.Select()})
    $Result                   = $Form.ShowDialog()

    Return $TextBox.Text
}

Function Show-PSDSimpleNotify
{
    Param($Message)

    $Header                   = "PSD"
    $ButtonText               = "Ok"

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $Form                     = New-Object System.Windows.Forms.Form
    $Form.Text                = $Header
    $Form.Size                = New-Object System.Drawing.Size(400,200)
    $Form.StartPosition       = 'CenterScreen'

    $Button1                  = New-Object System.Windows.Forms.Button
    $Button1.Location         = New-Object System.Drawing.Point(290,110)
    $Button1.Size             = New-Object System.Drawing.Size(80,30)
    $Button1.Text             = $ButtonText
    $Button1.DialogResult     = [System.Windows.Forms.DialogResult]::OK
    $Form.AcceptButton        = $Button1
    $Form.Controls.Add($Button1)

    $Label1                   = New-Object System.Windows.Forms.Label
    $Label1.Location          = New-Object System.Drawing.Point(10,20)
    $Label1.Size              = New-Object System.Drawing.Size(360,20)
    $Label1.Text              = $Message
    $Form.Controls.Add($Label1)
    $Form.Topmost             = $True
    $result                   = $Form.ShowDialog()
}

Function Invoke-PSDHelper
{
    Param($MDTDeploySharePath,$UserName,$Password)

    # Connect
    & net use $MDTDeploySharePath $Password /USER:$UserName

    # Import Env
    Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global -Force -Verbose:$False
    Import-Module PSDUtility                                     -Force -Verbose:$False
    Import-Module PSDDeploymentShare                             -Force -Verbose:$False
    Import-Module PSDGather                                      -Force -Verbose:$False

    dir tsenv: | Out-File "$($env:SystemDrive)\DumpVars.log"
    Get-Content -Path "$($env:SystemDrive)\DumpVars.log"
}

Function Invoke-PSDEXE
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param([Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()]
          [String]$Executable,
          [Parameter(Position=1)]
          [String]$Arguments)

    If ($Arguments -eq "")
    {
        Write-Verbose "Running Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -NoNewWindow -Wait -Passthru -RedirectStandardError "RedirectStandardError" -RedirectStandardOutput "RedirectStandardOutput"
    }
    Else
    {
        Write-Verbose "Running Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru -RedirectStandardError "RedirectStandardError" -RedirectStandardOutput "RedirectStandardOutput"
    }
    Write-Verbose "Returncode is $($ReturnFromEXE.ExitCode)"
    Return $ReturnFromEXE.ExitCode
}

Function Set-PSDCommandWindowsSize
{
    <#
    .Synopsis
    Resets the size of the current console window
    .Description
    Set-myConSize resets the size of the current console window. By default, it
    sets the windows to a height of 40 lines, with a 3000 line buffer, and sets the 
    the width and width buffer to 120 characters. 
    .Example
    Set-myConSize
    Restores the console window to 120x40
    .Example
    Set-myConSize -Height 30 -Width 180
    Changes the current console to a height of 30 lines and a width of 180 characters. 
    .Parameter Height
    The number of lines to which to set the current console. The default is 40 lines. 
    .Parameter Width
    The number of characters to which to set the current console. Default is 120. Also sets the buffer to the same value
    .Inputs
    [int]
    [int]
    .Notes
        Author: Charlie Russel
     Copyright: 2017 by Charlie Russel
              : Permission to use is granted but attribution is appreciated
       Initial: 28 April, 2017 (cpr)
       ModHist:
              :
    #>
    Param([UInt32]$Height=40,[UInt32]$Width=120)
    
    $Console = $Host.UI.RawUI
    $Buffer  = $Console.BufferSize
    $ConSize = $Console.WindowSize

    # If the Buffer is wider than the new console setting, first reduce the buffer, then do the resize
    If ($Buffer.Width -gt $Width ) 
    {
       $ConSize.Width      = $Width
       $Console.WindowSize = $ConSize
    }
    $Buffer.Width          = $Width
    $ConSize.Width         = $Width
    $Buffer.Height         = 3000
    $Console.BufferSize    = $Buffer
    $ConSize               = $Console.WindowSize
    $ConSize.Width         = $Width
    $ConSize.Height        = $Height
    $Console.WindowSize    = $ConSize
}

Function Get-PSDNtpTime 
{
    [CmdletBinding()]
    [OutputType()]
    Param ([String]$Server='pool.ntp.org'
        # [Switch]$NoDns    # Do not attempt to lookup V3 secondary-server referenceIdentifier
    )

    # --------------------------------------------------------------------
    # From https://gallery.technet.microsoft.com/scriptcenter/Get-Network-NTP-Time-with-07b216ca
    # Modifications via https://www.mathewjbray.com/powershell/powershell-get-ntp-time/
    # --------------------------------------------------------------------

    # NTP Times are all UTC and are relative to midnight on 1/1/1900
    $StartOfEpoch = New-Object DateTime(1900,1,1,0,0,0,[DateTimeKind]::Utc)   

    Function OffsetToLocal($Offset) 
    {
        # Convert milliseconds since midnight on 1/1/1900 to local time
        $StartOfEpoch.AddMilliseconds($Offset).ToLocalTime()
    }

    # Construct a 48-byte client NTP time packet to send to the specified server
    # (Request Header: [00=No Leap Warning; 011=Version 3; 011=Client Mode]; 00011011 = 0x1B)

    [Byte[]]$NtpData       = ,0 * 48
    $NtpData[0]            = 0x1B # NTP Request header in first byte

    $Socket                = New-Object Net.Sockets.Socket([Net.Sockets.AddressFamily]::InterNetwork,[Net.Sockets.SocketType]::Dgram,[Net.Sockets.ProtocolType]::Udp)
    $Socket.SendTimeOut    = 2000 # ms
    $Socket.ReceiveTimeOut = 2000 # ms

    Try 
    {
        $Socket.Connect($Server,123)
    }
    Catch 
    {
        Write-Warning "Failed to connect to server $Server"
        Return 
    }

    # NTP Transaction -------------------------------------------------------

    $t1 = Get-Date # t1, Start time of transaction... 
    
    Try 
    {
        [Void]$Socket.Send($NtpData)
        [Void]$Socket.Receive($NtpData)  
    }
    Catch 
    {
        Write-Warning "Failed to communicate with server $Server"
        Return
    }

    $t4 = Get-Date # End of NTP transaction time

    # End of NTP Transaction ------------------------------------------------

    $Socket.Shutdown("Both") 
    $Socket.Close()

# We now have an NTP response packet in $NtpData to decode.  Start with the LI flag
# as this is used to indicate errors as well as leap-second information

    # Decode the 64-bit NTP times

    # The NTP time is the number of seconds since 1/1/1900 and is split into an 
    # integer part (top 32 bits) and a fractional part, multipled by 2^32, in the 
    # bottom 32 bits.

    # Convert Integer and Fractional parts of the (64-bit) t3 NTP time from the byte array
    $IntPart            = [BitConverter]::ToUInt32($NtpData[43..40],0)
    $FracPart           = [BitConverter]::ToUInt32($NtpData[47..44],0)

    # Convert to Millseconds (convert fractional part by dividing value by 2^32)
    $t3ms               = $IntPart * 1000 + ($FracPart * 1000 / 0x100000000)

    # Perform the same calculations for t2 (in bytes [32..39]) 
    $IntPart            = [BitConverter]::ToUInt32($NtpData[35..32],0)
    $FracPart           = [BitConverter]::ToUInt32($NtpData[39..36],0)
    $t2ms               = $IntPart * 1000 + ($FracPart * 1000 / 0x100000000)

    # Calculate values for t1 and t4 as milliseconds since 1/1/1900 (NTP format)
    $t1ms               = ([TimeZoneInfo]::ConvertTimeToUtc($t1) - $StartOfEpoch).TotalMilliseconds
    $t4ms               = ([TimeZoneInfo]::ConvertTimeToUtc($t4) - $StartOfEpoch).TotalMilliseconds
 
    # Calculate the NTP Offset and Delay values
    $Offset             = (($t2ms - $t1ms) + ($t3ms-$t4ms))/2
    $Delay              = ($t4ms - $t1ms) - ($t3ms - $t2ms)

    # Make sure the result looks sane...
    # If ([Math]::Abs($Offset) -gt $MaxOffset) {
    #     # Network server time is too different from local time
    #     Throw "Network time offset exceeds maximum ($($MaxOffset)ms)"
    # }

    # Decode other useful parts of the received NTP time packet

    # We already have the Leap Indicator (LI) flag.  Now extract the remaining data
    # flags (NTP Version, Server Mode) from the first byte by masking and shifting (dividing)

    $LI_text             = Switch ($LI) 
    {
        0    {'no warning'}
        1    {'last minute has 61 seconds'}
        2    {'last minute has 59 seconds'}
        3    {'alarm condition (clock not synchronized)'}
    }
    $VN                  = ($NtpData[0] -band 0x38) -shr 3    # Server version number
    $Mode                = ($NtpData[0] -band 0x07)           # Server mode (probably 'server')
    $Mode_text           = Switch ($Mode) 
    {
        0    {'reserved'}
        1    {'symmetric active'}
        2    {'symmetric passive'}
        3    {'client'}
        4    {'server'}
        5    {'broadcast'}
        6    {'reserved for NTP control message'}
        7    {'reserved for private use'}
    }

    # Other NTP information (Stratum, PollInterval, Precision)

    $Stratum             = [UInt16]$NtpData[1]   # Actually [UInt8] but we don't have one of those...
    $Stratum_text        = Switch ($Stratum) 
    {
        0                            {'unspecified or unavailable'}
        1                            {'primary reference (e.g., radio clock)'}
        {$_ -ge 2 -and $_ -le 15}    {'secondary reference (via NTP or SNTP)'}
        {$_ -ge 16}                  {'reserved'}
    }

    $PollInterval        = $NtpData[2]              # Poll interval - to neareast power of 2
    $PollIntervalSeconds = [Math]::Pow(2, $PollInterval)

    $PrecisionBits       = $NtpData[3]      # Precision in seconds to nearest power of 2
                                      # ...this is a signed 8-bit int

    If ($PrecisionBits -band 0x80)    # ? negative (top bit set)
    {    
        [Int]$Precision  = $PrecisionBits -bor 0xFFFFFFE0    # Sign extend
    } 
    Else 
    {
        # ..this is unlikely - indicates a precision of less than 1 second
        [Int]$Precision  = $PrecisionBits   # top bit clear - just use positive value
    }
    $PrecisionSeconds    = [Math]::Pow(2, $Precision)

    # Determine the format of the ReferenceIdentifier field and decode
    
    If ($Stratum -le 1) 
    {
        # Response from Primary Server.  RefId is ASCII string describing source
        $ReferenceIdentifier = [String]([Char[]]$NtpData[12..15] -join '')
    }
    Else 
    {
        # Response from Secondary Server; determine server version and decode

        Switch ($VN) 
        {
            3   # Version 3 Secondary Server, RefId = IPv4 address of reference source 
            {
                $ReferenceIdentifier = $NtpData[12..15] -join '.'
                # If (-Not $NoDns) 
                # {
                #     If ($DnsLookup =  Resolve-DnsName $ReferenceIdentifier -QuickTimeout -ErrorAction SilentlyContinue) 
                #     {
                #         $ReferenceIdentifier = "$ReferenceIdentifier <$($DnsLookup.NameHost)>"
                #     }
                # }
                # Break
            }

            4   # Version 4 Secondary Server, RefId = low-order 32-bits of  
            {
                # latest transmit time of reference source
                $ReferenceIdentifier = [BitConverter]::ToUInt32($NtpData[15..12],0) * 1000 / 0x100000000
                Break
            }

            Default # Unhandled NTP version...
            {
                $ReferenceIdentifier = $Null
            }
        }
    }

    # Calculate Root Delay and Root Dispersion values
    $RootDelay              = [BitConverter]::ToInt32($NtpData[7..4],0) / 0x10000
    $RootDispersion         = [BitConverter]::ToUInt32($NtpData[11..8],0) / 0x10000

    # Finally, create output object and return
    $NtpTimeObj             = [PSCustomObject]@{
        NtpServer           = $Server
        NtpTime             = OffsetToLocal($t4ms + $Offset)
        Offset              = $Offset
        OffsetSeconds       = [Math]::Round($Offset/1000, 3)
        Delay               = $Delay
        t1ms                = $t1ms
        t2ms                = $t2ms
        t3ms                = $t3ms
        t4ms                = $t4ms
        t1                  = OffsetToLocal($t1ms)
        t2                  = OffsetToLocal($t2ms)
        t3                  = OffsetToLocal($t3ms)
        t4                  = OffsetToLocal($t4ms)
        LI                  = $LI
        LI_text             = $LI_text
        NtpVersionNumber    = $VN
        Mode                = $Mode
        Mode_text           = $Mode_text
        Stratum             = $Stratum
        Stratum_text        = $Stratum_text
        PollIntervalRaw     = $PollInterval
        PollInterval        = New-Object TimeSpan(0,0,$PollIntervalSeconds)
        Precision           = $Precision
        PrecisionSeconds    = $PrecisionSeconds
        ReferenceIdentifier = $ReferenceIdentifier
        RootDelay           = $RootDelay
        RootDispersion      = $RootDispersion
        Raw                 = $NtpData   # The undecoded bytes returned from the NTP server
    }

    # Set the default display properties for the returned object
    [String[]]$DefaultProperties =  'NtpServer', 'NtpTime', 'OffsetSeconds', 'NtpVersionNumber', 
                                    'Mode_text', 'Stratum', 'ReferenceIdentifier'

    # Create the PSStandardMembers.DefaultDisplayPropertySet member
    $ddps                        = New-Object Management.Automation.PSPropertySet('DefaultDisplayPropertySet',$DefaultProperties)

    # Attach default display property set and output object
    $PSStandardMembers           = [Management.Automation.PSMemberInfo[]]$ddps 
    $NtpTimeObj                  | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -PassThru
}

Function Write-PSDEvent
{
    Param($MessageID,$Severity,$Message)

    If ($tsenv:EventService -eq "")
    {
        Return
    }
    
    # a Deployment has started (EventID 41016)
    # a Deployment completed successfully (EventID 41015)
    # a Deployment failed (EventID 41014)
    # an error occurred (EventID 3)
    # a warning occurred (EventID 2)

    If ($tsenv:LTIGUID -eq "")
    {
        $LTIGUID           = ([Guid]::NewGuid()).Guid
        New-Item -Path TSEnv: -Name "LTIGUID" -Value "$LTIGUID" -Force
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:LTIGUID is now: $tsenv:LTIGUID"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Saving Variables"
        $variablesPath     = Save-PSDVariables
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Variables was saved to $variablesPath"
    }

    $MacAddress            = $tsenv:MacAddress001
    $Lguid                 = $tsenv:LTIGUID
    $id                    = $tsenv:UUID
    $vmhost                = 'NA'
    $ComputerName          = $tsenv:OSDComputerName
    $CurrentStep           = $tsenv:_SMSTSNextInstructionPointer
	If ($CurrentStep -eq "")
    {
        $CurrentStep       = '0'
    }

	$TotalSteps            = $tsenv:_SMSTSInstructionTableSize
	If ($TotalSteps -eq "")
    {
        $TotalSteps        = '0'
    }
    $Return                = Invoke-WebRequest "$tsenv:EventService/MDTMonitorEvent/PostEvent?uniqueID=$Lguid&computerName=$ComputerName&messageID=$messageID&severity=$severity&stepName=$CurrentStep&totalSteps=$TotalSteps&id=$id,$macaddress&message=$Message&dartIP=&dartPort=&dartTicket=&vmHost=$vmhost&vmName=$ComputerName" -UseBasicParsing
}

Function Show-PSDActionProgress 
{
    Param ($Message,$Step,$MaxStep)

    $ts                    = New-Object -ComObject Microsoft.SMS.TSEnvironment
    $tsui                  = New-Object -ComObject Microsoft.SMS.TSProgressUI
    $tsui.ShowActionProgress(
        $ts.Value("_SMSTSOrgName"),
        $ts.Value("_SMSTSPackageName"),
        $ts.Value("_SMSTSCustomProgressDialogMessage"),
        $ts.Value("_SMSTSCurrentActionName"),
        [Convert]::ToUInt32($ts.Value("_SMSTSNextInstructionPointer")),
        [Convert]::ToUInt32($ts.Value("_SMSTSInstructionTableSize")),
        $Message,
        $Step,
        $MaxStep
    )
}

Function Import-PSDCertificate
{
    Param($Path,$CertStoreScope,$CertStoreName)

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Adding $Path to Certificate Store: $CertStoreName in Certificate Scope: $CertStoreScope"
    # Create Object
    $CertStore             = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $CertStoreName,$CertStoreScope
    $Cert                  = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 

    # Import Certificate
    $CertStore.Open('ReadWrite')
    $Cert.Import($Path)
    $CertStore.Add($Cert)
    $Result                = $CertStore.Certificates | ? Subject -eq $Cert.Subject
    $CertStore.Close()
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Certificate Subject    : $($Result.Subject)"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Certificate Issuer     : $($Result.Issuer)"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Certificate Thumbprint : $($Result.Thumbprint)"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Certificate NotAfter   : $($Result.NotAfter)"
    Return "0"
}

Function Set-PSDDebugPause
{
    Param($Prompt)

    If ($Global:PSDDebug -eq $True)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name)"
        Read-Host -Prompt "$Prompt"
    }
}
