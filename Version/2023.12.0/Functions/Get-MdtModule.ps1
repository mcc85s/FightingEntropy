<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.12.0]                                                       \\
\\  Date       : 2023-12-07 14:55:20                                                                  //
 \\==================================================================================================// 

    FileName   : Get-MDTModule.ps1
    Solution   : [FightingEntropy()][2023.12.0]
    Purpose    : Retrieves the location of the main MDTToolkit.psd file, and installs
                 (MDT/WinADK/WinPE) if they are not present
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-12-07
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Get-MdtModule
{
    Enum MdtDependencyType
    {
        Mdt
        WinAdk
        WinPe
    }

    Class MdtDependencyItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $DisplayName
        [Version]    $Version
        [String]    $Resource
        [String]        $Path
        [String]        $File
        [String]   $Arguments
        [UInt32] $IsInstalled
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
        Hidden [Object] $Registry
        Hidden [UInt32]   $Status
        [Object]          $Output
        MdtDependencyController()
        {
            $Cim = Get-CimInstance Win32_OperatingSystem
            If ($Cim.Caption -notmatch "Server")
            {
                Throw "Invalid operating system"
            }
            
            $This.GetStatus()
        }
        [Object] MdtDependencyItem([String]$Name)
        {
            Return [MdtDependencyItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()
            $Arch          = $This.Arch()
            $This.Registry = $This.RegistryString() | Get-ItemProperty

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
        [UInt32] Arch()
        {
            Return @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
        }
        [String[]] RegistryString()
        {
            Return "", "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        }
        GetStatus()
        {
            $This.Status = 0

            If ($This.Output.Count -eq 0)
            {
                $This.Refresh()
            }

            ForEach ($Item in $This.Output)
            {
                $Package          = $This.Registry | ? DisplayName -match $Item.DisplayName
                $Item.IsInstalled = !!$Package
            }

            If (0 -notin $This.Output.IsInstalled)
            {
                $This.Status = 1
            }
        }
        Install()
        {
            $This.GetStatus()

            $List = $This.Output | ? IsInstalled -eq 0

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
                        Invoke-RestMethod -URI $Item.Resource -OutFile $Item.FilePath()
                    }
    
                    $Process = Start-Process -FilePath $Item.FilePath() -ArgumentList $Item.Arguments -PassThru
    
                    While (!$Process.HasExited)
                    {
                        For ($X = 0; $X -le 100; $X++)
                        {
                            Write-Progress -Activity "[Installing] @: $($Item.Name)" -PercentComplete $X
                            Start-Sleep -Milliseconds 50
                        }
                    }
    
                    $Item.IsInstalled ++
                }
            }
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
        [String] ToolkitPath()
        {
            Return $This.InstallPath() | Get-ChildItem -Filter *Toolkit.psd1 -Recurse | % FullName
        }
        [String] ToString()
        {
            Return "<FEModule.MdtDependency[Controller]>"
        }
    }

    $Mdt = [MdtDependencyController]::New()
    If (!$Mdt.Status)
    {
        $Mdt.Install()
    }

    $Mdt.ToolkitPath()
}
