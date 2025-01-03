<#
.SYNOPSIS
    To install the PowerShell Deployment modification for the Microsoft Deployment Toolkit
    This is an extension of the modification by FriendsOfMdt.
.DESCRIPTION
    When you want to be taken seriously...? 
    The Microsoft Deployment Toolkit doesn't play around.
    This PowerShell Deployment modification doesn't play around either. 
    For more information, visit the link below.
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\
   //¯¯¯                                                                                                           //
   \\                                                                                                              \\
   //        FileName   : Install-PSD.ps1                                                                          //
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\
   //        Purpose    : Installer for PSD                                                                        //
   \\        Author     : Original [PSD Development Team], Michael C. Cook Sr.                                     \\
   //        Contact    : @mcc85s                                                                                  //
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //
   \\        Modified   : 2022-11-10                                                                               \\
   //        Demo       : N/A                                                                                      //
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\
   //        TODO       : N/A                                                                                      //
   \\                                                                                                              \\
   //                                                                                                           ___//
   \\___                                                                                                    ___//¯¯\\
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯
    ¯¯¯\\__[ 11-10-2022 11:48:22    ]______________________________________________________________________//¯¯¯
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
.Example
#>
Function Install-PSD
{
    [CmdLetBinding()]Param(
    [Parameter()][String]$PSDeploymentFolder =                   "NA" ,
    [Parameter()][String]$PSDeploymentShare  =                   "NA" ,
    [Parameter()][String]$Description        = "PSD Deployment Share" ,
    [Parameter()][Switch]$Upgrade)

    $OS = Get-CimInstance Win32_OperatingSystem
    If ($OS.Caption -notmatch "Windows Server")
    {
        Throw "Not a valid Windows Server operating system"
    }

    Function Start-PSDLog
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

            # // _____________________________________________
            # // | (Confirm/create) destination logging path |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (!(Test-Path $FilePath))
            {
                New-Item $FilePath -Type File | Out-Null
            }
            Else
            {
                Remove-Item -Path $FilePath -Force
            }
            # // ___________________________________________________________________________
            # // | Set the global variable to be used as the FilePath for all subsequent   |
            # // | Write-PSDInstallLog calls in this session                               |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $global:ScriptLogFilePath = $FilePath
        }
        Catch
        {
            # // ______________________________________
            # // | Write exception if error is caught |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Write-Error $_.Exception.Message
        }
    }

    Function Write-PSDInstallLog
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

    Function Set-PSDDefaultLogPath
    {
        [CmdLetBinding()]
        Param([Parameter()][Bool]$DefaultLogLocation=1,
            [Parameter()][String]$LogLocation)

        $Cmd     = $Script:MyInvocation.MyCommand
        $LogPath = @((Split-Path $Cmd.Path),$LogLocation)[$DefaultLogLocation]
        $LogFile = "{0}.log" -f $Cmd.Name.Substring(0,$Cmd.Name.Length-4)
        Start-PSDLog -FilePath "$LogPath\$LogFile"
    }

    Function Copy-PSDFolder
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

    # // _________________
    # // | Start logging |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Set-PSDDefaultLogPath

    If ($PSDeploymentFolder -eq "NA")
    {
        Write-PSDInstallLog "You have not specified the -PSDeploymentFolder" 3
    }

    If ($PSDeploymentShare -eq "NA")
    {
        Write-PSDInstallLog "You have not specified the -PSDeploymentShare" 3
    }

    If ($Upgrade)
    {
        Write-PSDInstallLog "Installer running in upgrade mode"
    }

    # // _________________
    # // | Pull registry |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $Registry =  "","\WOW6432Node" | % { Get-ItemProperty "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }

    # // __________________________________
    # // | Check (ADK/WinPE/MDT) Versions |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    ForEach ( $Item in $Registry )
    {
        Switch -Regex ($Item.DisplayName)
        {
            "Windows Assessment and Deployment Kit - Windows 10"
            {
                $MDTADK   = $Item.DisplayVersion
                Write-PSDInstallLog "ADK installed version: $mdtADK"
            }
            "Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10"
            {
                $MDTADKPE = $Item.DisplayVersion
                Write-PSDInstallLog "WinPE Addon for ADK(only for ADK1809 or above): $mdtADKPE"
            }
            "Microsoft Deployment Toolkit"
            {
                $MDTVer   = $Item.DisplayVersion 
                Write-PSDInstallLog "MDT installed version: $mdtVer"
            }
        }
    }

    # // _______________________________
    # // | Create the folder and share |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If (Test-Path $PSDeploymentFolder)
    {
        If (Get-SmbShare | ? Path -eq $PSDeploymentFolder)
        {
            If (!$Upgrade)
            {
                Write-PSDInstallLog "The deployment share already exists" 3
                Break
            }
        }
        ElseIf(!(Get-SMBShare | ? Path -eq $PSDeploymentFolder))
        {
            Write-PSDInstallLog "Deployment folder was NOT shared already, now attempting to share the folder"
            $Result     = New-SMBShare -Name $PSDeploymentShare -Path $PSdeploymentFolder -FullAccess Administrators
            Write-PSDInstallLog "Deployment folder has now been shared as $PSDeploymentShare"
        }
    }
    Else
    {
        Write-PSDInstallLog "Creating [~] Deployment share in $PSDeploymentShare"
        $Result         = New-Item $PSDeploymentFolder -ItemType Directory

        Write-PSDInstallLog "Sharing $PSDeploymentFolder as $PSDeploymentShare"
        $Result         = New-SMBShare -Name $PSDeploymentShare -Path $PSDeploymentFolder -FullAccess Administrators
    }

    # // ____________________________________
    # // | Load the MDT PowerShell Provider |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $MDTDir             = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \

    Write-PSDInstallLog "Importing [~] MDT PowerShell module from ($mdtDir)"
    Import-Module $MDTDir\Bin\MicrosoftDeploymentToolkit.psd1

    # // ______________________
    # // | Restore MDT Drives |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Restore-MDTPersistentDrive -EA 0
    
    # // __________________________________________________________
    # // | Collect List of PSDrives to check for existing PSDrive |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    $List               = Get-PSDrive | ? PSProvider -eq MDTProvider

    # // _____________________________________________________
    # // | Create the deployment share at the specified path |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If (!$Upgrade -and $PSDeploymentFolder -notin $List.Root)
    {
        Write-PSDInstallLog "Create PSdrive using MDTProvider with the name of PSD:"
        $Splat          = @{

            Name        = "PSD"
            PSProvider  = "MDTProvider"
            Root        = $PSDeploymentFolder
            Description = $Description
            NetworkPath = "\\$Env:ComputerName\$PSDeploymentShare"
        }
        $Result         = New-PSDrive @Splat | add-MDTPersistentDrive
    }

    # // ________________________
    # // | Create backup folder |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog "Creating backup folder"
    $Backup             = "$psDeploymentFolder\Backup\Scripts"
    $Result             = New-Item $Backup -ItemType Directory -Force

    # // _________________________
    # // | Remove specific files |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog "Moving unneeded files to backup location"
    ForEach ( $Item in "UDIWizard_Config.xml.app Wizard.hta Wizard.ico Wizard.css Autorun.inf BDD_Welcome_ENU.xml Credentials_ENU.xml Summary_Definition_ENU.xml DeployWiz_Roles.xsl" -Split " ")
    {   
        $Path           = "$psDeploymentFolder\Scripts\$Item"

        If (Test-Path $Path)
        {
            Write-PSDInstallLog "Moving $Path"
            Move-Item -Path $Path -Destination "$Backup\$Item"
        }
    }

    # // __________________________________________
    # // | Cleanup old stuff from DeploymentShare |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    ForEach ($Item in Get-ChildItem "$psDeploymentFolder\Scripts" | ? Name -match "(vbs|wsf|DeployWiz|UDI|WelcomeWiz_)")
    {
        Write-PSDInstallLog "Moving $($Item.FullName)"
        Move-Item -Path $Item.FullName -Destination "$Backup\$($Item.Name)"
    }

    # // __________________________
    # // | Copy/Unblock PS1 Files |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-PSDFolder "$PSScriptRoot\Scripts\*.ps1" "$PSDeploymentFolder\Scripts"
    Get-ChildItem "$PSDeploymentFolder\Scripts\*.ps1" | Unblock-File 

    # // ___________________________
    # // | Copy/Unblock XAML Files |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-PSDFolder "$PSScriptRoot\Scripts\*.xaml" "$PSDeploymentFolder\Scripts"
    Get-ChildItem "$PSDeploymentFolder\Scripts\*.xaml" | Unblock-File 

    # // __________________________
    # // | Copy/Unblock templates |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-PSDFolder "$PSScriptRoot\Templates" "$PSDeploymentFolder\Templates"
    Get-ChildItem "$PSDeploymentFolder\Templates\*" | Unblock-File

    # // ____________________________
    # // | Copy/Unblock the modules |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog "Copying PSD Modules to $PSDeploymentfolder......."
    ForEach ($File in "PSDGather PSDDeploymentShare PSDUtility PSDWizard" -Split " ")
    {
        If (!(Test-Path "$PSDeploymentFolder\Tools\Modules\$File"))
        {
            $Result = New-Item "$PSDeploymentFolder\Tools\Modules\$File" -ItemType Directory
        }

        Write-PSDInstallLog "Copying module $File to $PSDeploymentFolder\Tools\Modules"
        Copy-Item "$PSScriptRoot\Scripts\$File.psm1" "$PSDeploymentFolder\Tools\Modules\$File"
        Get-ChildItem -Path "$psDeploymentFolder\Tools\Modules\$File\*" | Unblock-File
    }

    # // ____________________________________
    # // | Copy the PSProvider module files |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog "Copying MDT provider files to $PSDeploymentFolder\Tools\Modules"
    If (!(Test-Path "$PSDeploymentFolder\Tools\Modules\Microsoft.BDD.PSSnapIn"))
    {
        $Result = New-Item "$psDeploymentFolder\Tools\Modules\Microsoft.BDD.PSSnapIn" -ItemType Directory
    }

    ForEach ( $Item in "PSSnapIn" | % { "$_.dll $_.dll.config $_.dll-help.xml $_.Format.ps1xml $_.Types.ps1xml Core.dll Core.dll.config ConfigManager.dll" -Split " " } ) 
    {
        Copy-Item "$MdtDir\Bin\Microsoft.BDD.$Item" "$PSDeploymentFolder\Tools\Modules\Microsoft.BDD.PSSnapIn"
    }

    # // ____________________________________
    # // | Copy the provider template files |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog "Copying PSD templates to $PSDeploymentFolder\Templates"
    If (!(Test-Path "$PSDeploymentFolder\Templates"))
    {
        $Result = New-Item "$PSDeploymentFolder\Templates"
    }

    ForEach ($Item in "Groups Medias OperatingSystems Packages SelectionProfiles TaskSequences Applications Drivers Groups LinkedDeploymentShares" -Split " ")
    {
        Copy-Item "$MDTDir\Templates\$Item.xsd" "$PSDeploymentFolder\Templates"
    }

    # // _________________________
    # // | Restore ZTIGather.XML |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-PSDInstallLog -Message "Adding ZTIGather.XML to correct folder"
    Copy-Item "$MDTDir\Templates\Distribution\Scripts\ZTIGather.xml" "$PSDeploymentFolder\Tools\Modules\PSDGather"

    # // __________________________________________________________
    # // | Verify/Correct missing UNC path in BootStrap.ini (TBA) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // __________________
    # // | Create folders |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    ForEach ($Item in "Autopilot BootImageFiles\X86 BootImageFiles\X64 Branding Certificates CustomScripts DriverPackages DriverSources UserExitScripts BGInfo Prestart" -Split " ")
    {
        Write-PSDInstallLog -Message "Creating $Item folder in $PSdeploymentshare\PSDResources"
        $Result = New-Item "$PSDeploymentFolder\PSDResources\$Item" -ItemType Directory -Force
    }

    # // _________________________________________
    # // | Copy PSDBackground to Branding folder |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-Item -Path $PSScriptRoot\Branding\PSDBackground.bmp -Destination $PSDeploymentFolder\PSDResources\Branding\PSDBackground.bmp -Force

    # // ________________________________
    # // | Copy PSDBGI to BGInfo folder |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-Item -Path $PSScriptRoot\Branding\PSD.bgi -Destination $PSDeploymentFolder\PSDResources\BGInfo\PSD.bgi -Force

    # // ___________________________________
    # // | Copy BGInfo64.exe to BGInfo.exe |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-Item -Path $PSDeploymentFolder\Tools\x64\BGInfo64.exe -Destination $PSDeploymentFolder\Tools\x64\BGInfo.exe

    # // ______________
    # // | PSDRestart |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Copy-PSDFolder -Source $PSScriptRoot\PSDResources\Prestart -Destination $PSDeploymentFolder\PSDResources\Prestart
    
    # // _________________________________
    # // | Write Install-FightingEntropy |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Set-Content $PSDeploymentFolder\Scripts\Install-FightingEntropy.ps1 -Value "Invoke-RestMethod github.com/mcc85s/FightingEntropy/blob/main/Install.ps1?raw=true | Invoke-Expression"

    # // _________________________________________
    # // | Update the DeploymentShare properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If (!$Upgrade)
    {
        Write-PSDInstallLog "Update the DeploymentShare properties"
        86,64 | % { 

            Set-ItemProperty PSD: -Name "Boot.x$_.LiteTouchISOName" -Value "PSDLiteTouch_x$_.iso"
            Set-ItemProperty PSD: -Name "Boot.x$_.LiteTouchWIMDescription" -Value "PowerShell Deployment Boot Image (x$_)"
            Set-ItemProperty PSD: -Name "Boot.x$_.BackgroundFile" -Value "%DEPLOYROOT%\PSDResources\Branding\PSDBackground.bmp"
        }

        # // ___________________________
        # // | Disable support for x86 |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Write-PSDInstallLog -Message "Disable support for x86"
        Set-ItemProperty PSD: -Name "SupportX86" -Value "False"
    }

    # // _____________________________________________________________
    # // | Relax Permissions on Deploymentfolder and DeploymentShare |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If(!$Upgrade)
    {
        Write-PSDInstallLog "Relaxing permissons on $PSDeploymentShare"
        ForEach ($Item in "Users Administrators SYSTEM" -Split " ")
        {
            $Result = icacls $PSDeploymentFolder /grant "`"$Item`":(OI)(CI)(RX)"
        }
        $Result = Grant-SmbShareAccess -Name $PSDeploymentShare -AccountName "EVERYONE" -AccessRight Change -Force
        $Result = Revoke-SmbShareAccess -Name $PSDeploymentShare -AccountName "CREATOR OWNER" -Force
    }

    Get-ChildItem $PSDeploymentFolder -Recurse | Unblock-File
}
