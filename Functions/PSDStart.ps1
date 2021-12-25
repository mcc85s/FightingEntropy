<#
.SYNOPSIS
    Start or continue a PSD task sequence. 
.DESCRIPTION
    Start or continue a PSD task sequence.
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES
          FileName: PSDStart.ps1
          Solution: PowerShell Deployment for MDT
          Purpose:  Intializes a task sequence
          Author:   Original [PSD Development Team], 
                    Modified [mcc85s]
          Contact:  Original [@Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy]
                    Modified [@mcc85s]
          Primary:  Original [@Mikael_Nystrom]
                    Modofied [@mcc85s]
          Created: 
          Modified: 2021-12-25

          Version - 0.0.0 - () - Finalized functional version 1.
.Example
#>

Param ([Switch]$Start,[Switch]$Debug)

Function Write-PSDBootInfo
{
    Param([String]$Message,[UInt32]$SleepSec=0)

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
            If ((Test-Path "$($This.DriveLetter)\_SMSTaskSequence\TSEnv.dat") -and (Test-Path "$($This.DriveLetter)\Minint\Variables.dat"))
            {
                $This.TSDrive = 1
            }
        }
    }
    Get-WmiObject Win32_Volume | ? DriveType -eq 3 | ? DriveLetter | % { [PSDVolume]::New($_) }
}

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Initialize [+] Assembly, ScriptRoot, Modules, Ready to Import-Module ]________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Add PresentationFramework for GUI
    Add-Type -AssemblyName PresentationFramework

    # Set $ScriptRoot to the current script path
    $Env:ScriptRoot         = "$PSScriptRoot"
    Write-PSDBootInfo -Message "Found [~] ScriptRoot: [$Env:ScriptRoot]" -SleepSec 1

    # Set Bootstrap path to the Bootstrap.ini file
    $Env:Bootstrap          = Get-ChildItem $PSScriptRoot | ? Name -eq Bootstrap.ini | % FullName
    Write-PSDBootInfo -Message "Found [~] Bootstrap: [$Env:Bootstrap]" -SleepSec 1

    # Set $DeployRoot to the parent of Env:ScriptRoot
    $DeployRoot             = "$PSScriptRoot" | Split-Path

    If (!(Test-Path $DeployRoot)) # If it doesn't exist, look in bootstrap
    {
        $Line = Get-Content $Env:Bootstrap | ? { $_ -match "[PSD]*DeployRoot[s]*\=.+" }
        If ($Line)
        {
            $DeployRoot     = $Line -Replace "[PSD]*DeployRoot[s]*\=",''
        }

        # Class DGList {[String]$Name;[Object]$Value;DGList([String]$Name,[Object]$Value){$This.Name=$Name;$This.Value=$Value}}
        # $Group            = ForEach ($Line in $Content)
        # {
        #     If ($Line -match "\w+\=.+")
        #     {
        #         $Group   += [DGList]::New($Line.Split("=")[0],$Line.Substring($Line.Length+1))
        #     }
        # }
    }   
    
    $Env:DeployRoot         = $DeployRoot
    Write-PSDBootInfo -Message "Found [~] DeployRoot: [$Env:DeployRoot]" -SleepSec 1

    $Env:PsModulePath       = "$Env:PSModulePath;$Env:DeployRoot\Tools\Modules;$Env:SystemDrive\MININT\Tools\Modules;$Env:SystemDrive\MININT\Cache\Tools\Modules"
    
#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Debug [+] Settings ]__________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
    $Global:PSDDebug       = $false
    If (Test-Path -Path "C:\MININT\PSDDebug.txt")
    {
        $DeBug             = $true
        $Global:PSDDebug   = $True
    }

    If ($Global:PSDDebug -eq $false)
    {
        If ($DeBug -eq $true)
        {
            $Result        = Read-Host -Prompt "Press y and Enter to continue in debug mode, any other key to exit from debug..."
            If ($Result -eq "y")
            {
                $DeBug     = $True
            }
            Else
            {
                $DeBug     = $False
            }
        }
    }

    If ($DeBug -eq $true)
    {
        $Global:PSDDebug   = $True
        $verbosePreference = "Continue"
    }

    If ($PSDDeBug -eq $true)
    {
        Write-Verbose "PSDDeBug is now $PSDDeBug"
        Write-Verbose "verbosePreference is now $verbosePreference"
        Write-Verbose $env:PSModulePath
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Initialize [+] Powercfg, Import-Module(s)  ]__________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Make sure we run at full power
    Write-PSDBootInfo -Message "Setting Power plan to High performance" -SleepSec 1
    & powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Load Storage, BDD, PSDUtility (Necessary)
    Write-PSDBootInfo -SleepSec 1 -Message "Loading [~] Modules: [Storage, BDD, PSDUtility]"
    
    Try
    {
        Import-Module Storage -Force -Scope Global -Verbose:$False
        Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global -Force -Verbose:$False
        Import-Module PSDUtility -Force -Scope Global -Verbose:$False

        # Now Write-PSDLog and other PSDUtility functions can be used
        Write-PSDBootInfo -SleepSec 1 -Message "Initialized [+] [PSDUtility, PSDStart] -> Beginning"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DeployRoot is now [$Env:deployRoot]"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): env:PSModulePath is now [$env:PSModulePath]"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Loading [~] PSModules += Storage"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Loading [~] PSModules += PSDUtility"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Beginning initial process in [PSDStart.ps1]"
    }
    Catch
    {
        # An error occurred, module not loaded
        Write-PSDBootInfo "Failed [!] Import-Module(s)"
        Throw "Unable to load module [PSDUtility]"
    }

    If ($PSDDeBug -eq $true)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Imported Module: [PSDUtility, Storage]"
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Resolve [+] WinPE, Certificates    ]__________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Check if we booted from WinPE
    $Global:BootfromWinPE = $false
    If ($env:SYSTEMDRIVE -eq "X:")
    {
        $Global:BootfromWinPE = $true
    }
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): BootfromWinPE is now [$BootfromWinPE]"

    # Write Debug status to logfile
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): PSDDeBug is now [$PSDDeBug]"

    # Install PSDRoot certificate if exist in WinPE
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Looking for certificates..."

    # Certificate collection
    $Certificates = @()
    ForEach ($CertificateLocation in "Deploy","MININT" | % { "$($env:SYSTEMDRIVE)\$_\Certificates" })
    {
        If (Test-Path -Path $CertificateLocation)
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Looking for certificates in [$CertificateLocation]"
            $Certificates += Get-ChildItem -Path "$CertificateLocation" -Filter *.cer
        }
    }

    # Import each certificate in collection
    ForEach ($Certificate in $Certificates)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Found $($Certificate.FullName), trying to add as root certificate"

        # [OA]: Write-PSDBootInfo -SleepSec 1 -Message "Installing PSDRoot certificate"
        $Return = Import-PSDCertificate -Path $Certificate.FullName -CertStoreScope "LocalMachine" -CertStoreName "Root"
        If ($Return -eq "0")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Succesfully imported [$($Certificate.FullName)]"
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Failed to import [$($Certificate.FullName)]"
        }
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Stage [+] Command Window, WinPE Checks, (Remaining) Import-Module(s)   ]______________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Set Command Window size [OA]: "99 seems to use the screen in the best possible way, 100 is just one pixel to much"
    If ($Global:PSDDebug -ne $True)
    {
        Set-PSDCommandWindowsSize -Width 99 -Height 15
    }

    If ($BootfromWinPE -eq $true)
    {
        # [OA]: "Windows ADK v1809 could be missing certain files, we need to check for that."
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Check if we are running Windows ADK 10 v1809"
        If ([UInt32](Get-WmiObject Win32_OperatingSystem).BuildNumber -eq 17763)
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Check for BCP47Langs.dll and BCP47mrm.dll, needed for WPF"
            If (!(Test-Path -Path X:\Windows\System32\BCP47Langs.dll) -or !(Test-Path -Path X:\Windows\System32\BCP47mrm.dll))
            {
                Start-Process PowerShell -ArgumentList {
                    "Write-warning -Message 'We are missing the BCP47Langs.dll and BCP47mrm.dll files required for WinPE 1809.';Write-warning -Message 'Please check the PSD documentation on how to add those files.';Write-warning -Message 'Critical error, deployment can not continue..';Pause"
                } -Wait
                Exit 1
            }
        }

        # [OA]: "We need more than 1.5 GB (Testing for at least 1499MB of RAM)"
        Write-PSDBootInfo -SleepSec 2 -Message "Checking that we have at least 1.5 GB of RAM"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Check for minimum amount of memory in WinPE to run PSD"
        If ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -le 1499MB)
        {
            Show-PSDInfo -Message "Not enough memory to run PSD, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Exit 1
        }

        # [OA]: All tests succeded, log that info
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Completed WinPE prerequisite checks"
    }

    # Load more modules
    Write-PSDBootInfo -SleepSec 1 -Message "Loading [~] Modules: PSDDeploymentShare, PSDGather, PSDWizard"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Modules [~] PSDDeploymentShare, PSDGather, PSDWizard"

    Import-Module PSDDeploymentShare -ErrorAction Stop -Force -Verbose:$False
    Import-Module PSDGather -ErrorAction Stop -Force -Verbose:$False
    Import-Module PSDWizard -ErrorAction Stop -Force -Verbose:$False

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Check [~] tsenv:   ]__________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Set-PSDDebugPause -Prompt 182
    # Check if tsenv: works

    Try
    {
        Get-ChildItem -Path TSEnv:
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Able to read from TSEnv"
    }
    Catch
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to read from TSEnv"
        # Break
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Check [~] RunOnce  ]__________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # If running from RunOnce, create a startup folder item and then exit
    If ($start)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating a link to re-run $PSCommandPath from the all users Startup folder"

        # Create a shortcut to run this script
        $allUsersStartup     = [Environment]::GetFolderPath('CommonStartup')
        $linkPath            = "$allUsersStartup\PSDStartup.lnk"
        $wshShell            = New-Object -ComObject WScript.Shell
        $shortcut            = $WshShell.CreateShortcut($linkPath)
        $shortcut.TargetPath = "powershell.exe"
        
        If ($PSDDebug -eq $True)
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Command set to: PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Debug"
            $shortcut.Arguments = "-Noprofile -Executionpolicy Bypass -File $PSCommandPath -Debug"
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Command set to: PowerShell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $PSCommandPath"
            $shortcut.Arguments = "-Noprofile -Executionpolicy Bypass -Windowstyle Hidden -File $PSCommandPath"
        }
        $shortcut.Save()
        Exit 0
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Check [~] Gather Local Info, Task Sequence ]__________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Gather local info to make sure key variables are set (e.g. Architecture)
    Write-PSDBootInfo -Message "Running local gather" -SleepSec 1 
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run Get-PSDLocalInfo"
    Get-PSDLocalInfo

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking if there is an in-progress task sequence"

    # Check for an in-progress task sequence
    Write-PSDBootInfo -SleepSec 1 -Message "Check [~] Task sequence in progress..."

    $tsInProgress     = $False
    $Select           = Get-PSDVolume | ? TsDrive -eq 1

    If ($Select)
    {
        # Found it, save the location
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): In-progress task sequence found at $($Select.DriveLetter)\_SMSTaskSequence"
        $tsInProgress = $True
        $tsDrive      = $Select.DriveLetter

        # Set-PSDDebugPause -Prompt 240

        # Restore the task sequence variables
        $VariablesPath = Restore-PSDVariables
        Try
        {
            ForEach ($Item in Get-ChildItem -Path TSEnv:)
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Property $($Item.Name) is $($Item.Value)"
            }
        }
        Catch
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to restore variables from $variablesPath."
            Show-PSDInfo -Message "Unable to restore variables from $variablesPath." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Exit 1
        }

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Restored variables from $variablesPath."

        # Reconnect to the deployment share
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reconnecting to the deployment share at $($tsenv:DeployRoot)."
        If ($tsenv:UserDomain -ne "")
        {
            Get-PSDConnection -deployRoot $tsenv:DeployRoot -username "$($tsenv:UserDomain)\$($tsenv:UserID)" -password $tsenv:UserPassword
        }
        Else
        {
            Get-PSDConnection -deployRoot $tsenv:DeployRoot -username $tsenv:UserID -password $tsenv:UserPassword
        }
    }

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): If a task sequence is in progress, resume it. Otherwise, start a new one"

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Deployroot is now [$deployRoot]"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): env:PSModulePath is now [$env:PSModulePath]"

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Initialize [~] TS Engine, Scripts, Modules ]__________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # Sets the current directory to the SYSTEMDRIVE:\Windows\System32 path
    [Environment]::CurrentDirectory = "$($env:WINDIR)\System32"
        
    # If a task sequence is in progress, resume it
    If ($tsInProgress)
    {
        # Find the task sequence engine
        If (Test-Path -Path "X:\Deploy\Tools\$($tsenv:Architecture)\TSMBootstrap.exe")
        {
            $tsEngine = "X:\Deploy\Tools\$($tsenv:Architecture)"
        }
        Else
        {
            $tsEngine = Get-PSDContent "Tools\$($tsenv:Architecture)"
        }
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Task sequence engine located at $tsEngine."

        # Get full scripts location
        $Scripts           = Get-PSDContent -Content "Scripts"
        $env:ScriptRoot    = $scripts

        # Set the PSModulePath
        $Modules           = Get-PSDContent -Content "Tools\Modules"
        $env:PSModulePath += ";$Modules"

        # Resume task sequence
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DeployRoot is now $env:deployRoot"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): env:PSModulePath is now $env:PSModulePath"
        Stop-PSDLogging
        Write-PSDBootInfo -SleepSec 1 -Message "Resuming existing task sequence"
        $Result            = Start-Process -FilePath "$tsEngine\TSMBootstrap.exe" -ArgumentList "/env:SAContinue" -Wait -Passthru
    }
    # Otherwise, start a new task sequence
    If (!$tsInProgress)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No task sequence is in progress."

        # Process bootstrap
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing Bootstrap.ini"
        If ($env:SYSTEMDRIVE -eq "X:")
        {
            $mappingFile = "X:\Deploy\Tools\Modules\PSDGather\ZTIGather.xml"
            Invoke-PSDRules -FilePath "X:\Deploy\Scripts\Bootstrap.ini" -MappingFile $mappingFile
        }
        Else
        {
            $mappingFile = "$Env:deployRoot\Tools\Modules\PSDGather\ZTIGather.xml"
            Invoke-PSDRules -FilePath "$Env:deployRoot\Scripts\Bootstrap.ini" -MappingFile $mappingFile
        }

        # Determine the Deployroot
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Determine the Deployroot"

        # Check if we are deploying from media
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Check if we are deploying from media"

        $Select = Get-PSDVolume | ? Media -eq 1

        If ($Select)
        {
            # Found it, save the location
            $tsDrive                = $Select.DriveLetter
            $tsenv:DeployRoot       = "$tsDrive\Deploy"
            $tsenv:ResourceRoot     = "$tsDrive\Deploy"
            $tsenv:DeploymentMethod = "MEDIA"

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Found Media Tag $($tsDrive)\Deploy\Scripts\Media.tag"

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DeploymentMethod is $tsenv:DeploymentMethod, this solution does not currently support deploying from media, sorry, aborting"
            Show-PSDInfo -Message "No deployroot set, this solution does not currently support deploying from media, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Break
        }

        # Set-PSDDebugPause -Prompt 337
        Switch ($tsenv:DeploymentMethod)
        {
            'MEDIA'
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DeploymentMethod is $tsenv:DeploymentMethod, this solution does not currently support deploying from media, sorry, aborting"
                Show-PSDInfo -Message "No deployroot set, this solution does not currently support deploying from media, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
                Start-Process PowerShell -Wait
                Break
            }
            Default
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): We are deploying from Network, checking IPs,"
                
                # Check Network
                Write-PSDBootInfo -SleepSec 1 -Message "Checking for a valid network configuration"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Invoking DHCP refresh..."    
                $Null = Invoke-PSDexe -Executable ipconfig.exe -Arguments "/renew"

                $NICIPOK     = $False

                $ipList      = @()
                $ipListv4    = @()
                $macList     = @()
                $gwList      = @()
                $Config      = Get-WmiObject Win32_NetworkAdapterConfiguration | ? IPEnabled 
                
                $Config                     | % {
                    $_.IPAddress            | % {  $ipList += $_ }
                    $_.MacAddress           | % { $macList += $_ }
                    If ($_.DefaultIPGateway) 
                    {
                        $_.DefaultIPGateway | % {  $gwList += $_ }
                    }
                }
                $ipListv4 = $ipList         | ? { $_ -match "(\d+\.){3}\d+" }
                
                ForEach ($IPv4 in $ipListv4)
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Found IP address $IPv4"
                }

                If ($Config.Index.Count -ge 1)
                {
                    $NICIPOK = $True
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): We have at least one network adapter with a IP address, we should be able to continue"
                }
                

                If ($NICIPOK -ne $True)
                {
                    $Message = "Sorry, it seems that you don't have a valid IP, aborting..."
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $Message"
                    Show-PSDInfo -Message "$Message" -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
                    Start-Process PowerShell -Wait
                    break
                }

                # Log if we are running APIPA as warning
                # Log IP, Networkadapter name, if exist GW and DNS
                # Return Network as deployment method, with Yes we have network
            }
        }

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Looking for PSDeployRoots in the usual places..."

        # Set-PSDDebugPause -Prompt 398

        If ($tsenv:PSDDeployRoots -ne "")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): PSDeployRoots definition found!"
            ForEach ($item in $tsenv:PSDDeployRoots.Split(","))
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Testing PSDDeployRoots value: $item"
                Switch -Regex ($item)
                {
                    "(https\:\/\/.+)"
                    {
                        $ServerName = $item -Replace "^https\:\/\/",""
                        $Protocol   = "HTTPS"
                    }
                    "(http\:\/\/.+)"
                    {
                        $ServerName = $item -Replace "^http\:\/\/",""
                        $Protocol   = "HTTP"
                    }
                    "(\\\\.+)"
                    {
                        $ServerName = $item.Split("\\")[2]
                        $Protocol   = "SMB"
                    }
                }
                $Result             = Test-PSDNetCon -Hostname $ServerName -Protocol $Protocol

                If (!$Result)
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to access PSDDeployRoots value [$Item] using [$Protocol]"
                }
                If ($Result)
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Success [+] Access to PSDDeployRoots value [$Item] using [$Protocol]"

                    $tsenv:DeployRoot = $Item
                    $env:DeployRoot   = $Item
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): DeployRoot is now [$tsenv:DeployRoot]"
                    Break
                }
            }
        }
        Else
        {
            $deployRoot = $tsenv:DeployRoot
        }

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Validating network access to $tsenv:DeployRoot"
        Write-PSDBootInfo -SleepSec 2 -Message "Validating network access to $tsenv:DeployRoot"

        # Set-PSDDebugPause -Prompt 451

        If (!($tsenv:DeployRoot -notlike $null -or ""))
        {
            $Message = "Since we are deploying from network, we should be able to access the deploymentshare, but we can't, please check your network."
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $Message"
            Show-PSDInfo -Message "$Message" -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Break
        } 
        
        If ($NICIPOK -eq $False)
        {
            If ($deployRoot -notlike $null -or "")
            {
                $Message = "Since we are deploying from network, we should have network access but we don't, check networking"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $Message"
                Show-PSDInfo -Message "$Message" -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
                Start-Process PowerShell -Wait
                Break
            }
        }

        # Validate network route to $deployRoot
        If ($deployRoot -notlike $null -or "")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): New deploy root is $deployRoot."
            Switch -Regex ($DeployRoot)
            {
                "^https\:.+)"
                {
                    $ServerName = $deployRoot -Replace "^https\:\/\/",""
                    $Protocol   = "HTTPS"
                }
                "^http\:.+"
                {
                    $ServerName = $deployRoot -Replace "^http\:\/\/",""
                    $Protocol   = "HTTP"
                }
                "^\\\\\w+)"
                {
                    $ServerName = $deployRoot.Split("\\")[2]
                    $Protocol   = "SMB"
                }
            }

            $Result = Test-PSDNetCon -Hostname $ServerName -Protocol $Protocol
            If (!$Result)
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to access $ServerName"
                Show-PSDInfo -Message "Unable to access $ServerName, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
                Start-Process PowerShell -Wait
                Break
            }
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Deployroot is empty, this solution does not currently support deploying from media, sorry, aborting"
            Show-PSDInfo -Message "No deployroot set, this solution does not currently support deploying from media, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Break
        }

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): New deploy root is $deployRoot."
        Get-PSDConnection -DeployRoot $tsenv:DeployRoot -Username "$tsenv:UserDomain\$tsenv:UserID" -Password $tsenv:UserPassword

        # Set-PSDDebugPause -Prompt 518

        # Set time on client
        $Time = Get-Date
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Current time on computer is: $Time"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Set time on client"
        If ($tsenv:DeploymentMethod -ne "MEDIA")
        {
            Switch -Regex ($DeployRoot)
            {
                "^http"
                {
                    $NTPTime = @{ $False = Get-PSDNtpTime -Server Gunk.gunk.gunk; $True = Get-PSDNtpTime }[$DeployRoot -match "^https"]
                    If ($NTPTime)
                    {
                        Set-Date -Date $NTPTime.NtpTime
                    }
                    If (!$NtpTime)
                    {
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Failed to set time/date" -LogLevel 2
                    }
                }
                "^\\\\\w+"
                {
                    net time \\$ServerName /set /y
                }
            }
        }

        $Time = Get-Date
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): New time on computer is: $Time"

        # Process CustomSettings.ini
        $Control = Get-PSDContent -Content "Control"

        # Verify access to "$control\CustomSettings.ini" 
        If (!(Test-Path -Path "$control\CustomSettings.ini"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to access $control\CustomSettings.ini"
            Show-PSDInfo -Message "Unable to access $control\CustomSettings.ini, aborting..." -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Start-Process PowerShell -Wait
            Break    
        }
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing CustomSettings.ini"
        Invoke-PSDRules -FilePath "$control\CustomSettings.ini" -MappingFile $mappingFile

        If ($tsenv:EventService -notlike $null -or "")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Eventlogging is enabled"
        }
        Else
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Eventlogging is not enabled"
        }

        # Get full scripts location
        $scripts          = Get-PSDContent -Content "Scripts"
        $env:ScriptRoot   = $scripts

        # Set the PSModulePath
        $modules          = Get-PSDContent -Content "Tools\Modules"
        $env:PSModulePath = ";$modules"

        # Set-PSDDebugPause -Prompt "Process wizard"

        # Process wizard
        Write-PSDBootInfo -SleepSec 1 -Message "Loading the PSD Deployment Wizard"
        # $tsenv:TaskSequenceID = ""

        If ($tsenv:SkipWizard -ine "YES")
        {
            $Script:Wizard = Show-FEWizard (Get-PSDrive)
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Invoking [~] Get-FEWizard"
            $Wizard.Xaml.Invoke()

            If ($Wizard.Xaml.IO.DialogResult -eq $False)
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exception [!] Failed to complete wizard invocation"

                $Wizard.Xaml.Exception -Split "`n" | % {

                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exception [!] ($_)"
                }

                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Cancelling, aborting..."
                Show-PSDInfo -Message "Cancelling, aborting..." -Severity Information -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
                Stop-PSDLogging
                Clear-PSDInformation
                Start-Process PowerShell -Wait
                Exit 0
            }
            If ($Wizard.Xaml.IO.DialogResult -eq $True)
            {
                ForEach ($Item in $Wizard.TSEnv)
                {
                    $Name  = $Item.Name
                    $Value = $Item.Value
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Setting tsenv:\$Name to $Value"
                    If (Get-Item -Path tsenv:$Name)
                    {
                        Set-Item -Path tsenv:$Name -Value $Value -Verbose
                    }
                    Else
                    {
                        New-Item -Path tsenv:$Name -Value $Value -Verbose
                    }
                }
            }
        }

        If ($tsenv:TaskSequenceID -eq "")
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No TaskSequence selected, aborting..."
            Show-PSDInfo -Message "No TaskSequence selected, aborting..." -Severity Information -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
            Stop-PSDLogging
            Clear-PSDInformation
            Start-Process PowerShell -Wait
            Exit 0
        }

        If ($tsenv:OSDComputerName -eq "")
        {
            $tsenv:OSDComputerName = $env:COMPUTERNAME
        }

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Find the task sequence engine"

        # Find the task sequence engine
        If (Test-Path -Path "X:\Deploy\Tools\$($tsenv:Architecture)\tsmbootstrap.exe")
        {
            $tsEngine = "X:\Deploy\Tools\$($tsenv:Architecture)"
        }
        Else
        {
            $tsEngine = Get-PSDContent "Tools\$($tsenv:Architecture)"
        }
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Task sequence engine located at $tsEngine."

        # Transfer $PSDDeBug to TSEnv: for TS to understand
        If ($PSDDeBug -eq $true)
        {
            $tsenv:PSDDebug = "YES"
        }

        # Start task sequence
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): --------------------"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Start the task sequence"

        # Saving Variables
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Saving Variables"
        $variablesPath = Save-PSDVariables
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy Variables"
        Copy-Item -Path $variablesPath -Destination $tsEngine -Force
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copied $variablesPath to $tsEngine"
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy ts.xml"
        Copy-Item -Path "$control\$($tsenv:TaskSequenceID)\ts.xml" -Destination $tsEngine -Force
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copied $control\$($tsenv:TaskSequenceID)\ts.xml to $tsEngine"

        #Update TS.XML before using it, changing workbench specific .WSF scripts to PowerShell to avoid issues
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Update ts.xml before using it, changing workbench specific .WSF scripts to PowerShell to avoid issues"

        $TSxml = "$tsEngine\ts.xml"
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIDrivers.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDDrivers.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIGather.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDGather.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIValidate.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDValidate.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIBIOSCheck.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIDiskpart.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDPartition.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIUserState.wsf" /capture','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1" /capture') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIBackup.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTISetVariable.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDSetVariable.ps1"') | Set-Content -Path $TSxml
        # (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTINextPhase.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDNextPhase.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\LTIApply.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDApplyOS.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIWinRE.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIPatches.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIApplications.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDApplications.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIWindowsUpdate.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDWindowsUpdate.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIBde.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIBDE.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        (Get-Content -Path $TSxml).replace('cscript.exe "%SCRIPTROOT%\ZTIGroups.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"') | Set-Content -Path $TSxml
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Saving a copy of the updated TS.xml"
        Copy-Item -Path $tsEngine\ts.xml -Destination "$(Get-PSDLocalDataPath)\"

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Deployroot is now $deployRoot"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): env:PSModulePath is now $env:PSModulePath"
        Write-PSDEvent -MessageID 41016 -severity 4 -Message "PSD beginning deployment"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Done in PSDStart for now, handing over to Task Sequence by running $tsEngine\TSMBootstrap.exe /env:SAStart"
        Write-PSDBootInfo -SleepSec 0 -Message "Running Task Sequence"
        Stop-PSDLogging
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Looking for $tsEngine\TSMBootstrap.exe"
        If (!(Test-Path -Path "$tsEngine\TSMBootstrap.exe"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to access $tsEngine\TSMBootstrap.exe" -Loglevel 3
            Show-PSDInfo -Message "Unable to access $tsEngine\TSMBootstrap.exe" -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
        }
        $Result = Start-Process -FilePath "$tsEngine\TSMBootstrap.exe" -ArgumentList "/env:SAStart" -Wait -Passthru
    }

# If we are in WinPE and we have deployed an operating system, we should write logfiles to the new drive
If ($BootfromWinPE -eq $True)
{
    # Assuming that the first Volume having mspaint.exe is the correct OS volume
    ForEach ($Drive in Get-PSDrive | ? Provider -like *filesystem)
    {
        # TODO: Need to find a better file for detection of running OS
        If (Test-Path -Path "$($Drive.Name):\Windows\System32\mspaint.exe")
        {
            Start-PSDLogging -Logpath "$($Drive.Name):\MININT\SMSOSD\OSDLOGS"
            Break
        }
    }
}

Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): logPath is now $logPath"
Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Task Sequence is done, PSDStart.ps1 is now in charge.."

# Make sure variables.dat is in the current local directory
If (Test-Path -Path "$(Get-PSDLocalDataPath)\Variables.dat")
{
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Variables.dat found in the correct location, $(Get-PSDLocalDataPath)\Variables.dat, no need to copy."
}
Else
{
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copying Variables.dat to the current location, $(Get-PSDLocalDataPath)\Variables.dat."
    Copy-Item $variablesPath "$(Get-PSDLocalDataPath)\"
}

Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Deployroot is now $deployRoot"
Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): env:PSModulePath is now $env:PSModulePath"

# Process the exit code from the task sequence
# Start-PSDLogging

# If ($result.ExitCode -eq $null)
# {
#    $result.ExitCode = 0
# }

# Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Return code from TSMBootstrap.exe is $($result.ExitCode)"

Switch ($Result.ExitCode)
{
    0 
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): SUCCESS!"
        Write-PSDEvent -MessageID 41015 -Severity 4 -Message "PSD deployment completed successfully."
        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reset HKLM:\Software\Microsoft\Deployment 4"
        Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | Remove-Item -Force -Recurse

        $Executable      = "regsvr32.exe"
        $Arguments       = "/u /s $tools\tscore.dll"
        If (!(Test-Path -Path "$tools\tscore.dll"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
            $return      = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
        }

        $Executable      = "$Tools\TSProgressUI.exe"
        $Arguments       = "/Unregister"
        If (!(Test-Path -Path "$Tools\TSProgressUI.exe"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
            $return      = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
        }

        # TODO Reboot for finishaction
        # Read-Host -Prompt "Check for FinishAction and cleanup leftovers"
        Write-Verbose "tsenv:FinishAction is $tsenv:FinishAction"
        
        If ($tsenv:FinishAction -eq "Reboot" -or $tsenv:FinishAction -eq "Restart")
        {
            $Global:RebootAfterTS = $True
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Will reboot for finishaction"
        }

        # Set-PSDDebugPause -Prompt "Before PSDFinal.ps1"
        Stop-PSDLogging

        $LogPath = "$Env:SystemDrive\OSDLOGS($(Get-Date -UFormat %Y_%m%d))"
        If (!(Test-Path $LogPath))
        {
            New-Item $LogPath -ItemType Directory
        }

        ForEach ($Item in Get-ChildItem "$Env:SystemDrive\MININT\SMSOSD\OSDLOGS")
        {
            Copy-Item $Item.FullName $LogPath
        }

        Copy-Item -Path "$env:SystemDrive\MININT\Cache\Scripts\PSDFinal.ps1" -Destination $env:TEMP
        Clear-PSDInformation
                
        # Checking for FinalSummary
        If (!($tsenv:SkipFinalSummary -eq "YES"))
        {
            Show-PSDInfo -Message "OSD SUCCESS!" -Severity Information -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot
        }

        If ($tsenv:PSDPause -eq "YES")
        {
            Read-Host -Prompt "Exit 0"
        }

        # Read-Host -Prompt "Check for finish action and cleanup leftovers"
        # Check for finish action and cleanup leftovers
        
        If ($RebootAfterTS -eq $True)
        {
            Start-Process powershell -ArgumentList "$env:TEMP\PSDFinal.ps1 -Restart $true -ParentPID $PID" -WindowStyle Hidden -Wait
        }
        Else
        {
            Start-Process powershell -ArgumentList "$env:TEMP\PSDFinal.ps1 -Restart $false -ParentPID $PID" -WindowStyle Hidden -Wait
        }

        # Done
        Exit 0
    }
    -2147021886
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): REBOOT!"
        $variablesPath = Restore-PSDVariables

        Try
        {
            ForEach ($item in (Get-ChildItem -Path TSEnv:))
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Property $($item.Name) is $($item.Value)"
            }
        }
        Catch
        {
        }

        If ($env:SYSTEMDRIVE -eq "X:")
        {
            # We are running in WinPE and need to reboot, if we have a hard disk, then we need files to continute the TS after reboot, copy files...
            # Exit with a zero return code and let Windows PE reboot

            # Assuming that the first Volume having mspaint.exe is the correct OS volume
            Foreach ($Drive in Get-PSDrive | ? Provider -match filesystem)
            {
                # TODO: Need to find a better file for detection of running OS
                If (Test-Path -Path "$($Drive.Name):\Windows\System32\mspaint.exe")
                {
                    # Copy files needed for full OS
                    Write-PSDLog -Message "Copy-Item $scripts\PSDStart.ps1 $($Drive.Name):\MININT\Scripts"
                    Initialize-PSDFolder "$($Drive.Name):\MININT\Scripts"
                    Copy-Item "$scripts\PSDStart.ps1" "$($Drive.Name):\MININT\Scripts"

                    Try
                    {
                        $drvcache = "$($Drive.Name):\MININT\Cache"
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy-Item X:\Deploy\Tools -Destination $drvcache"
                        $cres = Copy-Item -Path "X:\Deploy\Tools" -Destination "$drvcache" -Recurse -Force -Verbose -PassThru
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $cres"
                        
                        # Simulate download to x:\MININT\Cache\Tools
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy-Item X:\Deploy\Tools -Destination X:\MININT\Cache\Tools"
                        $cres = Copy-Item -Path "X:\Deploy\Tools" -Destination "X:\MININT\Cache" -Recurse -Force -Verbose -PassThru
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $cres"

                        # Copies from x:\MININT\Cache to target drive
                        $Modules = Get-PSDContent "Tools\Modules"
                        Write-PSDLog -Message "Copy-PSDFolder $Modules $($Drive.Name):\MININT\Tools\Modules"
                        Copy-PSDFolder "$Modules" "$($Drive.Name):\MININT\Tools\Modules"
                        
                        # Copies from x:\MININT\Cache\Tools\<arc> to target drive
                        $Tools = Get-PSDContent "Tools\$($tsenv:Architecture)"
                        Write-PSDLog -Message "Copy-PSDFolder $Tools $($Drive.Name):\MININT\Tools\$($tsenv:Architecture)"
                        Copy-PSDFolder "$Tools" "$($Drive.Name):\MININT\Tools\$($tsenv:Architecture)"

                    }
                    Catch
                    {
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy failed"
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $_"
                    }

                    Write-PSDLog -Message "Copy-PSDFolder $Certificates $($Drive.Name):\MININT\Certificates"
                    $Certificates = Get-PSDContent "PSDResources\Certificates"
                    Copy-PSDFolder "$Certificates" "$($Drive.Name):\MININT\Certificates"

                    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copy items from X:\Deploy\Tools to $($tsenv:OSVolume):\MININT\Cache\Tools"
                    # Copy-PSDFolder -Source X:\Deploy\Tools -Destination "$($tsenv:OSVolume):\MININT\Cache\Tools"
                    # Get-ChildItem -Path "$($tsenv:OSVolume):\MININT\Cache\Tools" -Filter ts.xml -Recurse | Remove-Item -Force
                    # Get-ChildItem -Path "$($tsenv:OSVolume):\MININT\Cache\Tools" -Filter variables.dat -Recurse | Remove-Item -Force

                    If ($PSDDeBug -eq $True)
                    {
                        New-Item -Path "$($Drive.Name):\MININT\PSDDebug.txt" -ItemType File -Force
                    }

                    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): We are now on line 775 and we are doing a break on line 776..."
                    # Break
                }
            }

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exit with a zero return code and let Windows PE reboot"
            Stop-PSDLogging

            If ($tsenv:PSDPause -eq "YES")
            {
                Read-Host -Prompt "Exit -2147021886 (WinPE)"
            }

            Exit 0
        }
        Else
        {
            # In full OS, need to initiate a reboot
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): In full OS, need to initiate a reboot"

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Saving Variables"
            $variablesPath = Save-PSDVariables

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Finding out where the tools folder is..."
            $Tools         = Get-PSDContent -Content "Tools\$($tsenv:Architecture)"
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Tools is now $Tools"
            
            $Executable    = "regsvr32.exe"
            $Arguments     = "/u /s $tools\tscore.dll"
            If (!(Test-Path -Path "$tools\tscore.dll"))
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
                $return    = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
            }
            If ($Return -ne 0)
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to unload $tools\tscore.dll" -Loglevel 2
            }

            $Executable    = "$Tools\TSProgressUI.exe"
            $Arguments     = "/Unregister"
            If (!(Test-Path -Path "$Tools\TSProgressUI.exe"))
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
                $return    = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
            }
            If ($return -ne 0)
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to unload $Tools\TSProgressUI.exe" -Loglevel 2
            }

            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Restart, see you on the other side... (Shutdown.exe /r /t 30 /f)"
            
            If ($tsenv:PSDPause -eq "YES")
            {
                Read-Host -Prompt "Exit -2147021886 (Windows)"
            }
            
            # Restart-Computer -Force
            Shutdown.exe /r /t 30 /f | Out-Null

            Stop-PSDLogging
            Exit 0
        }
    }
    Default 
    {
        # Exit with a non-zero return code
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Task sequence failed, rc = $($result.ExitCode)"

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reset HKLM:\Software\Microsoft\Deployment 4"
        Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4"  -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reset HKLM:\Software\Microsoft\SMS"
        Get-ItemProperty "HKLM:\Software\Microsoft\SMS" -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Findig out where the tools folder is..."
        $Tools          = Get-PSDContent -Content "Tools\$($tsenv:Architecture)"

        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Tools is now $Tools"

        $Executable     = "regsvr32.exe"
        $Arguments      = "/u /s $tools\tscore.dll"
        If (!(Test-Path -Path "$tools\tscore.dll"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
            $return     = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
        }

        $Executable     = "$Tools\TSProgressUI.exe"
        $Arguments      = "/Unregister"
        If (!(Test-Path -Path "$Tools\TSProgressUI.exe"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $Executable $Arguments"
            $return     = Invoke-PSDEXE -Executable $Executable -Arguments $Arguments
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Exitcode: $return"
        }

        Clear-PSDInformation
        Stop-PSDLogging

        # Invoke-PSDInfoGather
        Write-PSDEvent -MessageID 41014 -severity 1 -Message "PSD deployment failed, Return Code is $($result.ExitCode)"
        Show-PSDInfo -Message "Task sequence failed, Return Code is $($result.ExitCode)" -Severity Error -OSDComputername $OSDComputername -Deployroot $global:psddsDeployRoot

        Exit $result.ExitCode
    }
}
