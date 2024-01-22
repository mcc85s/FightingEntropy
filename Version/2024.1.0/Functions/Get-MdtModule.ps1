<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 19:30:33                                                                  //
 \\==================================================================================================// 

    FileName   : Get-MdtModule.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : Retrieves the location of the MicrosoftDeploymentToolkit.psd1 file,
                 (and/or) (installs/uninstalls) (MDT/WinADK/WinPE) if they are not present
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Get-MdtModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
    [Parameter(ParameterSetName=1)][Switch]$Install,
    [Parameter(ParameterSetName=2)][Switch]$Uninstall,
    [Parameter(ParameterSetName=3)][Switch]$Toolkit)

    Class MdtByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        MdtByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes        
            $This.GetUnit() 
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Enum MdtDependencyType
    {
        Mdt
        WinAdk
        WinPe
    }

    Class MdtDependencyItem
    {
        [UInt32]            $Index
        [String]             $Name
        [String]      $DisplayName
        [Version]         $Version
        [Object]             $Size
        [UInt32]        $Installed
        Hidden [String]  $Resource
        Hidden [String]      $Path
        Hidden [String]      $File
        Hidden [String] $Arguments
        MdtDependencyItem([String]$Name)
        {
            $This.Index = [UInt32][MdtDependencyType]::$Name
            $This.Name  = [MdtDependencyType]::$Name
        }
        Load([String[]]$List)
        {
            $This.DisplayName = $List[0]
            $This.Version     = $List[1]
            $This.Size        = $This.MdtByteSize($List[2])
            $This.Resource    = $List[3]
            $This.Path        = $List[4]
            $This.File        = $List[5]
            $This.Arguments   = $List[6]
        }
        [String] FilePath()
        {
            Return "{0}\{1}" -f $This.Path, $This.File
        }
        [Object] MdtByteSize([UInt64]$Bytes)
        {
            Return [MdtByteSize]::New($This.Name,$Bytes)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class MdtDependencyController
    {
        Hidden [UInt32] $Server
        Hidden [UInt32]  $Admin
        [UInt32]        $Status
        [String]          $Path
        [Object]        $Output
        MdtDependencyController()
        {
            $This.GetOs()
            $This.GetIdentity()

            If (!$This.Server)
            {
                Throw "[!] Invalid operating system (Must use Windows Server)"
            }

            ElseIf (!$This.Admin)
            {
                Throw "[!] Invalid administrator account (Must run as administrator)"
            }
            
            $This.Populate()
            $This.Refresh()
        }
        GetOs()
        {
            $Caption     = Get-CimInstance Win32_OperatingSystem | % Caption
            $This.Server = $Caption -match "Server"
        }
        GetIdentity()
        {
            $Principal   = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            $Roles       = "Administrator","Administrators" | % { [UInt32]$Principal.IsInRole($_) }

            $This.Admin  = $True -in $Roles
        }
        [Object] MdtDependencyItem([String]$Name)
        {
            Return [MdtDependencyItem]::New($Name)
        }
        [UInt32] Arch()
        {
            Return @{x86 = 86; AMD64 = 64}[$Env:Processor_Architecture]
        }
        [String[]] RegistryString()
        {
            Return "", "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        }
        [String] InstallPath()
        {
            $RegPath = "HKLM:\Software\Microsoft\Deployment 4"

            If (Test-Path $RegPath)
            {
                Return Get-ItemProperty $RegPath | % Install_Dir | % TrimEnd \ 
            }
            Else
            {
                Return $Null
            }
        }
        [String] ToolkitPath()
        {
            Return $This.InstallPath() | Get-ChildItem -Filter *Toolkit.psd1 -Recurse | % FullName
        }
        Clear()
        {
            $This.Output   = @( )
        }
        [Object] RefreshRegistry()
        {
            Return $This.RegistryString() | Get-ItemProperty
        }
        Populate()
        {
            $This.Clear()
            $Arch = $This.Arch()

            ForEach ($Name in [System.Enum]::GetNames([MdtDependencyType]))
            {
                $Item = $This.MdtDependencyItem($Name)
                $X    = Switch ($Name)
                {
                    Mdt
                    {
                        "Microsoft Deployment Toolkit",
                        "6.3.8450.0000",
                        "80530636.8"
                        "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x$Arch.msi",
                        "$Env:ProgramData\Tools\Mdt",
                        "MicrosoftDeploymentToolkit_x$Arch.msi",
                        "/quiet /norestart"
                    }
                    WinAdk
                    {
                        "Windows Assessment and Deployment Kit - Windows 10",
                        "10.1.17763.1",
                        "1256277934.08",
                        "https://go.microsoft.com/fwlink/?linkid=2086042",
                        "$Env:ProgramData\Tools\WinAdk",
                        "winadk1903.exe",
                        "/quiet /norestart /log $Env:temp\winadk.log /features +"
                    }
                    WinPe
                    {
                        "Windows Preinstallation Environment",
                        "10.1.17763.1",
                        "6163278069.76",
                        "https://go.microsoft.com/fwlink/?linkid=2087112",
                        "$Env:ProgramData\Tools\WinPe",
                        "winpe1903.exe",
                        "/quiet /norestart /log $Env:temp\winpe.log /features +"
                    }
                }

                $Item.Load($X)
                $This.Output += $Item
            }
        }
        Refresh()
        {
            $Registry = $This.RefreshRegistry()

            ForEach ($Item in $This.Output)
            {
                $Object         = $Registry | ? DisplayName -match $Item.DisplayName
                $Item.Installed = [UInt32]!!$Object
            }

            $This.Status = [UInt32](0 -notin $This.Output.Installed)

            Switch ($This.Status)
            {
                0
                {
                    $This.Path = $Null
                }
                1
                {
                    $This.Path = $This.ToolkitPath()
                }
            }
        }
        [UInt32] CheckInternet()
        {
            Return !!(Test-Connection -Count 1 -ComputerName 1.1.1.1)
        }
        [String] Activity([String]$Action,[Object]$Item)
        {
            Return "$Action : {0} ({1}) / {2} v{3}" -f $Item.Name, $Item.Size, $Item.DisplayName, $Item.Version
        }
        Install()
        {
            $This.Refresh()

            If (!$This.Status)
            {
                $List = $This.Output | ? Installed -eq 0

                If (!$This.CheckInternet())
                {
                    Throw "Internet connection required to install"
                }

                If ($List.Count -gt 0)
                {
                    [Net.ServicePointManager]::SecurityProtocol = 3072

                    ForEach ($Item in $List)
                    {
                        If (![System.IO.Directory]::Exists($Item.Path))
                        {
                            [System.IO.Directory]::CreateDirectory($Item.Path)
                        }
    
                        If (![System.IO.File]::Exists($Item.FilePath()))
                        {
                            Start-BitsTransfer -Source $Item.Resource -Destination $Item.FilePath()
                        }
    
                        $Start = [DateTime]::Now

                        Start-Process -FilePath $Item.FilePath() -ArgumentList $Item.Arguments -PassThru
                        Start-Sleep 2

                        # [EXE]
                        $Flag = Switch ($Item.Name)
                        {
                            Mdt
                            {
                                "(MicrosoftDeploymentToolkit)"
                            }
                            WinAdk
                            {
                                "(adksetup|winadk1903)"
                            }
                            WinPe
                            {
                                "(adkwinpesetup|winpe1903)"
                            }
                        }

                        $Process = $Null

                        # [Activity]
                        $Activity  = $This.Activity("Installing",$Item)
                        Write-Progress -Activity $Activity -PercentComplete 0

                        # [Loop]
                        $X = -1
                        Do
                        {
                            If ($X -in -1,100)
                            {
                                $X        = 0
                                $Process = Get-Process | ? Name -match $Flag
                            }

                            Write-Progress -Activity $Activity -PercentComplete $X
                            Start-Sleep -Milliseconds 125

                            $X ++
                        }
                        Until ($Process.Count -eq 0)

                        Write-Progress -Activity $Activity -Complete
                        $Elapsed = "{0} [{1}]" -f $Activity, [TimeSpan]([DateTime]::Now - $Start)
                        [Console]::WriteLine($Elapsed)

                        $This.Refresh()
                    }
                }
            }
        }
        Uninstall()
        {
            $Registry = $This.RefreshRegistry()

            ForEach ($Item in $This.Output)
            {
                $Object         = $Registry | ? DisplayName -match $Item.DisplayName
                $Item.Installed = [UInt32]!!$Object
            
                If ($Item.Installed)
                {            
                    If (!$Object.QuietUninstallString)
                    {
                        $FilePath = "msiexec.exe"
                        $ArgumentList = "/x $($Object.PSChildName) /qn"
            
                        $Process = Get-Process | ? Name -eq msiexec
                    }
                    Else
                    {
                        $Object.QuietUninstallString -match "^\`".+\`"" > $Null
                        $FilePath     = $Matches[0]
                        $ArgumentList = $Object.QuietUninstallString.Replace($FilePath,"").TrimStart(" ")
                    }
            
                    $Start = [DateTime]::Now
                    Start-Process -FilePath $FilePath -ArgumentList $ArgumentList
                    Start-Sleep 2
            
                    # [EXE]
                    $Flag = Switch ($Item.Name)
                    {
                        Mdt
                        {
                            "(MicrosoftDeploymentToolkit)"
                        }
                        WinAdk
                        {
                            "(adksetup|winadk1903)"
                        }
                        WinPe
                        {
                            "(adkwinpesetup|winpe1903)"
                        }
                    }

                    $Process   = $Null
            
                    # [Activity]
                    $Activity  = $This.Activity("Uninstalling",$Item)
            
                    Write-Progress -Activity $Activity -PercentComplete 0
            
                    $X = -1
                    Do
                    {
                        If ($X -in -1,100)
                        {
                            $X        = 0
                            $Process = Get-Process | ? Name -match $Flag
                        }
            
                        Write-Progress -Activity $Activity -PercentComplete $X
                        Start-Sleep -Milliseconds 125
            
                        $X ++
                    }
                    Until ($Process.Count -eq 0)
            
                    Write-Progress -Activity $Activity -Complete
                    $Elapsed = "{0} [{1}]" -f $Activity, [TimeSpan]([DateTime]::Now - $Start)
                    [Console]::WriteLine($Elapsed)
            
                    $This.Refresh()
                }
            }
        }
        MdtModXml()
        {
            If ($This.Status)
            {
                $Module    = Get-FEModule -Mode 1
                $Install   = $This.InstallPath()
                ForEach ($File in $Module.GetFolder("Control").Item | ? Name -match mod.xml)
                {
                    [System.IO.File]::Copy($File.Fullname,"$Install\Templates\$($File.Name)")
                }
            }
        }
        [String] ToString()
        {
            Return "<FEModule.MdtDependency[Controller]>"
        }
    }

    $Mdt = [MdtDependencyController]::New()
    Switch ($PSCmdlet.ParameterSetName)
    {
        0
        {
            $Mdt
        }
        1
        {
            Switch (!$Mdt.Status)
            {
                0 { $Mdt.Install() } 1 { Throw "(Mdt/WinAdk/WinPe) already installed" }
            }
        }
        2
        {
            Switch ($Mdt.Status)
            {
                0 { Throw "(Mdt/WinAdk/WinPe) not installed" } 1 { $Mdt.Uninstall() }
            }
        }
        3
        {
            Switch ($Mdt.Status)
            {
                0 { $Null } 1 { $Mdt.Path }
            }
        }
    }
}