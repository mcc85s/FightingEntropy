<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-12 21:35:11                                                                  //
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
    Modified   : 2024-01-12
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Get-MdtModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1)][Switch]$Install)

    Class WindowsPackageExtension
    {
        [UInt32]           $Index
        [String]            $Name
        [String]         $Version
        WindowsPackageExtension([UInt32]$Index,[Object]$Package)
        {
            $This.Index    = $Index
            $This.Name     = $Package.Name
            $This.Version  = $Package.Version
        }
        [String] ToString()
        {
            Return "<FEModule.Windows.Package.Extension>"
        }
    }

    Class WindowsPackageList
    {
        [Object] $Output
        WindowsPackageList()
        {
            $This.Refresh()
        }
        [Object] WindowsPackageExtension([UInt32]$Index,[Object]$Package)
        {
            Return [WindowsPackageExtension]::New($Index,$Package)
        }
        [Object[]] GetPackage()
        {
            Return Get-Package | Sort-Object Name
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            $Package = $This.GetPackage()

            ForEach ($Item in $Package)
            {
                $This.Output += $This.WindowsPackageExtension($This.Output.Count,$Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Windows.Package.List>"
        }
    }

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
        [Object] WindowsPackageList()
        {
            Return [WindowsPackageList]::New()
        }
        [String[]] WinPEPackages()
        {
            Return "Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10",
            "Windows PE ARM ARM64",
            "Windows PE ARM ARM64 wims",  
            "Windows PE x86 x64",         
            "Windows PE x86 x64 wims"
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
        Install()
        {
            $This.Refresh()
            $Complete = $Null

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
                    $Package = $This.WindowsPackageList()

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
                                        If ($Item.Index -ne 2)
                                        {
                                            $Complete = $Process.HasExited -or $Item.Installed
                                        }
                                        If ($Item.Index -eq 2)
                                        {
                                            $Package.Refresh()
                                            $Complete = $This.WinPEPackages() -in $Package.Output.Name
                                        }
                                    }
                                }
                            }
                        }
                        Until ($Complete)
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

<#
"Application Compatibility Toolkit",                                                             "10.1.18362.1"
"Imaging And Configuration Designer",                                                            "10.1.18362.1"
"Imaging Designer",                                                                              "10.1.18362.1"
"Imaging Tools Support",                                                                         "10.1.18362.1"
"Kits Configuration Installer",                                                                  "10.1.18362.1"
"Microsoft Deployment Toolkit (6.3.8456.1000)",                                                   "6.3.8456.1000"
"MXAx64",                                                                                        "10.1.18362.1"
"OEM Test Certificates",                                                                         "10.1.18362.1"
"Toolkit Documentation",                                                                         "10.1.18362.1"
"UEV Tools on amd64",                                                                            "10.1.18362.1"
"User State Migration Tool",                                                                     "10.1.18362.1"
"Volume Activation Management Tool",                                                             "10.1.18362.1"
"Windows Assessment and Deployment Kit - Windows 10",                                            "10.1.18362.1"
"Windows Deployment Customizations",                                                             "10.1.18362.1"
"Windows Deployment Tools",                                                                      "10.1.18362.1"
"Windows System Image Manager",                                                                  "10.1.18362.1"
"WPT Redistributables",                                                                          "10.1.18362.1"
"WPTx64",                                                                                        "10.1.18362.1"
"Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10","10.1.18362.1"
"Windows PE ARM ARM64",                                                                          "10.1.18362.1"
"Windows PE ARM ARM64 wims",                                                                     "10.1.18362.1"
"Windows PE x86 x64",                                                                            "10.1.18362.1"
"Windows PE x86 x64 wims",                                                                       "10.1.18362.1"
#>
