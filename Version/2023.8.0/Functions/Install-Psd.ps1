<#
.SYNOPSIS
    To install the PowerShell Deployment modification for the Michaelsoft Deployment Toolkit
    This is an extension of the modification by FriendsOfMdt.
.DESCRIPTION
    When you want to be taken seriously...? 
    The Michaelsoft Deployment Toolkit doesn't play around.
    This PowerShell Deployment modification doesn't play around either. 
    For more information, visit the friends of the Michaelsoft Deployment Toolkit link, below.
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-08-08 15:27:45                                                                  //
 \\==================================================================================================// 

    FileName   : Install-Psd.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Installer for Psd
    Author     : Original [PSD Development Team], Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-08-08
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Consider changing this process

.Example
#>
Function Install-Psd
{
    [CmdLetBinding()]Param(
    [Parameter()][String] $Psdolder    =                   "NA" ,
    [Parameter()][String] $PsdShare    =                   "NA" ,
    [Parameter()][String] $Description = "Psd Deployment Share" ,
    [Parameter()][Switch] $Upgrade)

    $OS = Get-CimInstance Win32_OperatingSystem
    If ($OS.Caption -notmatch "Windows Server")
    {
        Throw "Not a valid Windows Server operating system"
    }

    Function Start-PsdLog
    {
        [CmdLetBinding()]
        Param([Parameter(Mandatory)][String]$FilePath)

        Try
        {
            $Parent = Split-Path $Filepath -Parent 
            If(!(Test-Path $Parent))
            {
                New-Item $Parent -Type Directory | Out-Null
            }

            # // =============================================
            # // | (Confirm/create) destination logging path |
            # // =============================================

            If (!(Test-Path $FilePath))
            {
                New-Item $FilePath -Type File | Out-Null
            }
            Else
            {
                Remove-Item -Path $FilePath -Force
            }
            # // ===========================================================================
            # // | Set the global variable to be used as the FilePath for all subsequent   |
            # // | Write-PSDInstallLog calls in this session                               |
            # // ===========================================================================

            $global:ScriptLogFilePath = $FilePath
        }
        Catch
        {
            # // ======================================
            # // | Write exception if error is caught |
            # // ======================================

            Write-Error $_.Exception.Message
        }
    }

    Function Write-PsdInstallLog
    {
        [CmdLetBinding()]
        Param([Parameter(Mandatory,Position=0)][String]$Message,
            [Parameter(Position=1)][ValidateSet(1,2,3)][String]$LogLevel=1,
            [Parameter()][Bool]$WriteToScreen=1)

        $Time, $Date = (Get-Date -Format "HH:mm:ss.fff+000 MM-dd-yyyy") -Split " "
        $Component   = $MyInvocation | % { "{0}:{1}" -f ($_.ScriptName | Split-Path -Leaf), $_.ScriptLineNumber }

        $Line        = "<![LOG[$Message]LOG]!><time='$Time' date='$Date' component='$Component' context='' type='$LogLevel' thread='' file=''>".Replace("'",'"')
        [System.GC]::Collect()
        Add-Content -Value $Line -Path $global:ScriptLogFilePath
        If ($WriteToScreen)
        {
            Switch ($LogLevel)
            {
                1 { Write-Verbose -Message $Message } 2 { Write-Warning -Message $Message } 3 { Write-Error   -Message $Message } Default {}
            }
        }
        If ($WriteToListbox)
        {
            $Result1.Items.Add("$Message")
        }
    }

    Function Set-PsdDefaultLogPath
    {
        [CmdLetBinding()]
        Param([Parameter()][Bool]$DefaultLogLocation=1,
            [Parameter()][String]$LogLocation)

        $Cmd     = $Script:MyInvocation.MyCommand
        $LogPath = @((Split-Path $Cmd.Path),$LogLocation)[$DefaultLogLocation]
        $LogFile = "{0}.log" -f $Cmd.Name.Substring(0,$Cmd.Name.Length-4)
        Start-PSDLog -FilePath "$LogPath\$LogFile"
    }

    Function Copy-PsdFolder
    {
        [CmdLetBinding()]Param(
            [Parameter(Mandatory,Position=1)][String]$Source,
            [Parameter(Mandatory,Position=2)][String]$Destination)

        $S = $Source.TrimEnd("\")
        $D = $Destination.TrimEnd("\")
        Write-Verbose "Copying folder $Source to $Destination using XCopy"
        & xcopy $s $d /s /e /v /y /i | Out-Null
    }

    If ($PSVersionTable.PSEdition -ne "Desktop")
    {
        Throw "Must use PowerShell v5"
    }

    # // =================
    # // | Start logging |
    # // =================

    Set-PsdDefaultLogPath

    If ($PsdFolder -eq "NA")
    {
        Write-PSDInstallLog "You have not specified the -PsdFolder" 3
    }

    If ($PsdShare -eq "NA")
    {
        Write-PSDInstallLog "You have not specified the -PsdShare" 3
    }

    If ($Upgrade)
    {
        Write-PSDInstallLog "Installer running in upgrade mode"
    }

    # // =================
    # // | Pull registry |
    # // =================

    $Registry =  "","\WOW6432Node" | % { Get-ItemProperty "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }

    # // ==================================
    # // | Check (ADK/WinPE/MDT) Versions |
    # // ==================================

    ForEach ($Item in $Registry)
    {
        Switch -Regex ($Item.DisplayName)
        {
            "Windows Assessment and Deployment Kit - Windows 10"
            {
                $MdtAdk   = $Item.DisplayVersion
                Write-PSDInstallLog "ADK installed version: $mdtADK"
            }
            "Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10"
            {
                $MdtAdkPe = $Item.DisplayVersion
                Write-PSDInstallLog "WinPE Addon for ADK(only for ADK1809 or above): $mdtADKPE"
            }
            "Microsoft Deployment Toolkit"
            {
                $MdtVer   = $Item.DisplayVersion 
                Write-PSDInstallLog "MDT installed version: $mdtVer"
            }
        }
    }

    # // ===============================
    # // | Create the folder and share |
    # // ===============================

    If (Test-Path $PsdFolder)
    {
        If (Get-SmbShare | ? Path -eq $PsdFolder)
        {
            If (!$Upgrade)
            {
                Write-PSDInstallLog "The deployment share already exists" 3
                Break
            }
        }
        ElseIf(!(Get-SMBShare | ? Path -eq $PsdFolder))
        {
            Write-PSDInstallLog "Deployment folder was NOT shared already, now attempting to share the folder"
            $Result     = New-SMBShare -Name $PsdShare -Path $PsdFolder -FullAccess Administrators
            Write-PSDInstallLog "Deployment folder has now been shared as $PsdShare"
        }
    }
    Else
    {
        Write-PSDInstallLog "Creating [~] Deployment share in $PsdShare"
        $Result         = New-Item $PsdFolder -ItemType Directory

        Write-PSDInstallLog "Sharing $PsdFolder as $PsdShare"
        $Result         = New-SMBShare -Name $PsdShare -Path $PsdFolder -FullAccess Administrators
    }

    # // ====================================
    # // | Load the MDT PowerShell Provider |
    # // ====================================

    $MdtDir = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \

    Write-PsdInstallLog "Importing [~] MDT PowerShell module from ($MdtDir)"
    Import-Module $dtDir\Bin\MicrosoftDeploymentToolkit.psd1

    # // ======================
    # // | Restore MDT Drives |
    # // ======================

    Restore-MdtPersistentDrive -EA 0
    
    # // ==========================================================
    # // | Collect List of PSDrives to check for existing PSDrive |
    # // ==========================================================

    $List = Get-PSDrive | ? PSProvider -eq MDTProvider

    # // =====================================================
    # // | Create the deployment share at the specified path |
    # // =====================================================

    If (!$Upgrade -and $PsdFolder -notin $List.Root)
    {
        Write-PSDInstallLog "Create PSdrive using MDTProvider with the name of PSD:"
        $Splat          = @{

            Name        = "PSD"
            PSProvider  = "MDTProvider"
            Root        = $PsdFolder
            Description = $Description
            NetworkPath = "\\$Env:ComputerName\$PsdShare"
        }

        $Result         = New-PSDrive @Splat | add-MDTPersistentDrive
    }

    # // ========================
    # // | Create backup folder |
    # // ========================

    Write-PSDInstallLog "Creating backup folder"

    $Backup             = "$psdFolder\Backup\Scripts"
    $Result             = New-Item $Backup -ItemType Directory -Force

    # // =========================
    # // | Remove specific files |
    # // =========================

    Write-PSDInstallLog "Moving unneeded files to backup location"
    ForEach ( $Item in "UDIWizard_Config.xml.app Wizard.hta Wizard.ico Wizard.css Autorun.inf BDD_Welcome_ENU.xml Credentials_ENU.xml Summary_Definition_ENU.xml DeployWiz_Roles.xsl" -Split " ")
    {   
        $Path           = "$PsdFolder\Scripts\$Item"

        If (Test-Path $Path)
        {
            Write-PSDInstallLog "Moving $Path"
            Move-Item -Path $Path -Destination "$Backup\$Item"
        }
    }

    # // ==========================================
    # // | Cleanup old stuff from DeploymentShare |
    # // ==========================================

    ForEach ($Item in Get-ChildItem "$PsdFolder\Scripts" | ? Name -match "(vbs|wsf|DeployWiz|UDI|WelcomeWiz_)")
    {
        Write-PSDInstallLog "Moving $($Item.FullName)"
        Move-Item -Path $Item.FullName -Destination "$Backup\$($Item.Name)"
    }

    # // ==========================
    # // | Copy/Unblock PS1 Files |
    # // ==========================

    Copy-PSDFolder "$PSScriptRoot\Scripts\*.ps1" "$PsdFolder\Scripts"
    Get-ChildItem "$PsdFolder\Scripts\*.ps1" | Unblock-File 

    # // ===========================
    # // | Copy/Unblock XAML Files |
    # // ===========================

    Copy-PSDFolder "$PSScriptRoot\Scripts\*.xaml" "$PsdFolder\Scripts"
    Get-ChildItem "$PsdFolder\Scripts\*.xaml" | Unblock-File 

    # // ==========================
    # // | Copy/Unblock templates |
    # // ==========================

    Copy-PSDFolder "$PSScriptRoot\Templates" "$PsdFolder\Templates"
    Get-ChildItem "$PsdFolder\Templates\*" | Unblock-File

    # // ============================
    # // | Copy/Unblock the modules |
    # // ============================

    Write-PSDInstallLog "Copying PSD Modules to $Psdolder......."
    ForEach ($File in "PSDGather PSDDeploymentShare PSDUtility PSDWizard" -Split " ")
    {
        If (!(Test-Path "$PsdFolder\Tools\Modules\$File"))
        {
            $Result = New-Item "$PsdFolder\Tools\Modules\$File" -ItemType Directory
        }

        Write-PSDInstallLog "Copying module $File to $PsdFolder\Tools\Modules"
        Copy-Item "$PSScriptRoot\Scripts\$File.psm1" "$PsdFolder\Tools\Modules\$File"
        Get-ChildItem -Path "$PsdFolder\Tools\Modules\$File\*" | Unblock-File
    }

    # // ====================================
    # // | Copy the PSProvider module files |
    # // ====================================

    Write-PSDInstallLog "Copying MDT provider files to $PsdFolder\Tools\Modules"
    If (!(Test-Path "$PsdFolder\Tools\Modules\Microsoft.BDD.PSSnapIn"))
    {
        $Result = New-Item "$PsdFolder\Tools\Modules\Microsoft.BDD.PSSnapIn" -ItemType Directory
    }

    ForEach ($Item in "PSSnapIn" | % { "$_.dll $_.dll.config $_.dll-help.xml $_.Format.ps1xml $_.Types.ps1xml Core.dll Core.dll.config ConfigManager.dll" -Split " " } ) 
    {
        Copy-Item "$MdtDir\Bin\Microsoft.BDD.$Item" "$PsdFolder\Tools\Modules\Microsoft.BDD.PSSnapIn"
    }

    # // ====================================
    # // | Copy the provider template files |
    # // ====================================

    Write-PSDInstallLog "Copying PSD templates to $PsdFolder\Templates"
    If (!(Test-Path "$PsdFolder\Templates"))
    {
        $Result = New-Item "$PsdFolder\Templates"
    }

    ForEach ($Item in "Groups Medias OperatingSystems Packages SelectionProfiles TaskSequences Applications Drivers Groups LinkedDeploymentShares" -Split " ")
    {
        Copy-Item "$MdtDir\Templates\$Item.xsd" "$PsdFolder\Templates"
    }

    # // =========================
    # // | Restore ZTIGather.XML |
    # // =========================

    Write-PSDInstallLog -Message "Adding ZTIGather.XML to correct folder"
    Copy-Item "$MdtDir\Templates\Distribution\Scripts\ZTIGather.xml" "$PsdFolder\Tools\Modules\PSDGather"

    # // ==========================================================
    # // | Verify/Correct missing UNC path in BootStrap.ini (TBA) |
    # // ==========================================================

    # // ==================
    # // | Create folders |
    # // ==================

    ForEach ($Item in "Autopilot BootImageFiles\X86 BootImageFiles\X64 Branding Certificates CustomScripts DriverPackages DriverSources UserExitScripts BGInfo Prestart" -Split " ")
    {
        Write-PsdInstallLog -Message "Creating $Item folder in $PsdShare\PSDResources"
        $Result = New-Item "$PsdFolder\PSDResources\$Item" -ItemType Directory -Force
    }

    # // =========================================
    # // | Copy PSDBackground to Branding folder |
    # // =========================================

    Copy-Item -Path $PSScriptRoot\Branding\PSDBackground.bmp -Destination $PsdFolder\PSDResources\Branding\PSDBackground.bmp -Force

    # // ================================
    # // | Copy PSDBGI to BGInfo folder |
    # // ================================

    Copy-Item -Path $PSScriptRoot\Branding\PSD.bgi -Destination $PsdFolder\PSDResources\BGInfo\PSD.bgi -Force

    # // ===================================
    # // | Copy BGInfo64.exe to BGInfo.exe |
    # // ===================================

    Copy-Item -Path $PsdFolder\Tools\x64\BGInfo64.exe -Destination $PsdFolder\Tools\x64\BGInfo.exe

    # // ==============
    # // | PSDRestart |
    # // ==============

    Copy-PsdFolder -Source $PSScriptRoot\PSDResources\Prestart -Destination $PsdFolder\PSDResources\Prestart
    
    # // =================================
    # // | Write Install-FightingEntropy |
    # // =================================

    $Source = "https://github.com/mcc85s/FightingEntropy/blob/main/Version/2023.8.0/FightingEntropy.ps1?raw=true"
    Set-Content $PsdFolder\Scripts\Install-FightingEntropy.ps1 -Value "Invoke-RestMethod $Source | Invoke-Expression"

    # // =========================================
    # // | Update the DeploymentShare properties |
    # // =========================================

    If (!$Upgrade)
    {
        Write-PSDInstallLog "Update the DeploymentShare properties"
        86,64 | % { 

            Set-ItemProperty PSD: -Name "Boot.x$_.LiteTouchISOName" -Value "PSDLiteTouch_x$_.iso"
            Set-ItemProperty PSD: -Name "Boot.x$_.LiteTouchWIMDescription" -Value "PowerShell Deployment Boot Image (x$_)"
            Set-ItemProperty PSD: -Name "Boot.x$_.BackgroundFile" -Value "%DEPLOYROOT%\PSDResources\Branding\PSDBackground.bmp"
        }

        # // ===========================
        # // | Disable support for x86 |
        # // ===========================

        Write-PsdInstallLog -Message "Disable support for x86"
        Set-ItemProperty PSD: -Name SupportX86 -Value "False"
    }

    # // =============================================================
    # // | Relax Permissions on Deploymentfolder and DeploymentShare |
    # // =============================================================

    If (!$Upgrade)
    {
        Write-PSDInstallLog "Relaxing permissons on $PsdShare"
        ForEach ($Item in "Users Administrators SYSTEM" -Split " ")
        {
            $Result = icacls $PsdFolder /grant "`"$Item`":(OI)(CI)(RX)"
        }

        $Result = Grant-SmbShareAccess -Name $PsdShare -AccountName "EVERYONE" -AccessRight Change -Force
        $Result = Revoke-SmbShareAccess -Name $PsdShare -AccountName "CREATOR OWNER" -Force
    }

    Get-ChildItem $PsdFolder -Recurse | Unblock-File
}
