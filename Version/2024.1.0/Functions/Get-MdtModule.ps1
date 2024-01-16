<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-15 23:50:17                                                                  //
 \\==================================================================================================// 

    FileName   : Get-MdtModule.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : Retrieves the location of the MicrosoftDeploymentToolkit.psd1 file,
                 (and/or) installs (MDT/WinADK/WinPE) if they are not present
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-15
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Get-MdtModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1)][Switch]$Install)

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
    
                        $Process = Start-Process -FilePath $Item.FilePath() -ArgumentList $Item.Arguments -PassThru
                        While (!$Process.HasExited)
                        {
                            For ($X = 0; $X -le 100; $X++)
                            {
                                Write-Progress -Activity "Installing : $($Item.Name)/$($Item.DisplayName) $($Item.Version)" -PercentComplete $X
                                Start-Sleep -Milliseconds 50
                            }
                        }

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
                    [Console]::WriteLine("Uninstalling [~] $($Item.DisplayName)")

                    If (!$Object.QuietUninstallString)
                    {
                        $FilePath = "msiexec.exe"
                        $ArgumentList = "/x $($Object.PSChildName) /qn"
                    }
                    Else
                    {
                        $Object.QuietUninstallString -match "^\`".+\`"" > $Null
                        $FilePath     = $Matches[0]
                        $ArgumentList = $Object.QuietUninstallString.Replace($FilePath,"").TrimStart(" ")
                    }

                    Start-Process -FilePath $FilePath -ArgumentList $ArgumentList
                    Write-Progress -Activity "Uninstalling : $($Item.Name)/$($Item.DisplayName) $($Item.Version)" -PercentComplete 100

                    $Item.Installed = 0
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
