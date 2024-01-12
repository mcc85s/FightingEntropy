<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-11 19:00:25                                                                  //
 \\==================================================================================================// 

    FileName   : Get-MdtModule.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : Retrieves the location of the MicrosoftDeploymentToolkit.psd1 file,
                 (and/or) installs:
                  (MDT/WinADK/WinPE) if they are not present
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-11
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Get-MdtModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1)][Switch]$Install)

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
            $This.Resource    = $List[2]
            $This.Path        = $List[3]
            $This.File        = $List[4]
            $This.Arguments   = $List[5]
        }
        [String] FilePath()
        {
            Return "{0}\{1}" -f $This.Path, $This.File
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class MdtDependencyController
    {
        [String]            $Path
        [UInt32]          $Status
        [Object]          $Output
        MdtDependencyController()
        {
            $Cim = Get-CimInstance Win32_OperatingSystem
            If ($Cim.Caption -notmatch "Server")
            {
                Throw "Invalid operating system"
            }
            
            $This.Populate()
            $This.Refresh()
        }
        [Object] MdtDependencyItem([String]$Name)
        {
            Return [MdtDependencyItem]::New($Name)
        }
        [UInt32] Arch()
        {
            Return @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
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
                        "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x$Arch.msi",
                        "$Env:ProgramData\Tools\Mdt",
                        "MicrosoftDeploymentToolkit_x$Arch.msi",
                        "/quiet /norestart"
                    }
                    WinAdk
                    {
                        "Windows Assessment and Deployment Kit",
                        "10.1.17763.1",
                        "https://go.microsoft.com/fwlink/?linkid=2086042",
                        "$Env:ProgramData\Tools\WinAdk",
                        "winadk1903.exe",
                        "/quiet /norestart /log $Env:temp\winadk.log /features +"
                    }
                    WinPe
                    {
                        "Windows Preinstallation Environment",
                        "10.1.17763.1",
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

            If ($This.Status)
            {
                $This.Path = $This.ToolkitPath()
            }
        }
        Install()
        {
            $This.Refresh()

            If (!$This.Status)
            {
                $List = $This.Output | ? Installed -eq 0

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
    
                        $Process = Start-Process -FilePath $Item.FilePath() -ArgumentList $Item.Arguments -PassThru
                        
                        Do
                        {
                            $C = 0
                            For ($X = 0; $X -le 100; $X++)
                            {
                                Write-Progress -Activity "Installing : $($Item.Name)/$($Item.DisplayName) $($Item.Version)" -PercentComplete $X

                                Switch ($C)
                                {
                                    {$_ -lt 5}
                                    {
                                        Start-Sleep 1
                                        $C ++
                                    }
                                    {$_ -ge 5}
                                    {
                                        $C = 0
                                        $This.Refresh()
                                    }
                                }
                            }
                        }
                        Until ($Process.HasExited -and $Item.Installed)
                    }
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
            If (!$Mdt.Status)
            {
                $Mdt.Install()
            }
        }
    }
}
