<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-MDTModule.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Retrieves the location of the main MDTToolkit.psd file, and installs                     //   
   \\                     (MDT/WinADK/WinPE) if they are not present.                                              \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-10-10                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:43    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-MDTModule
{
    Class MDTDependency
    {
        [String]        $Name
        [String] $DisplayName
        [String]     $Version
        [String]    $Resource
        [String]        $Path
        [String]        $File
        [String]   $Arguments
        [UInt32] $IsInstalled
        MDTDependency([Object]$Item)
        {
            $This.Name        = $Item.Name
            $This.DisplayName = $Item.DisplayName
            $This.Version     = $Item.Version
            $This.Resource    = $Item.Resource
            $This.Path        = $Item.Path
            $This.File        = $Item.File
            $This.Arguments   = $Item.Arguments
        }
    }

    Class MDTStatus
    {
        [Object]           $Output
        [Object]              $MDT = @{ 

            Name                   = "MDT"
            DisplayName            = "Microsoft Deployment Toolkit"
            Version                = "6.3.8450.0000"
            Resource               = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x{0}.msi" -f @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
            Path                   = "{0}\Tools\MDT"
            File                   = "MicrosoftDeploymentToolkit_x{0}.msi" -f @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
            Arguments              = "/quiet /norestart"
        }
        [Object]           $WinADK = @{ 

            Name                   = "WinADK"
            DisplayName            = "Windows Assessment and Deployment Kit"
            Version                = "10.1.17763.1"
            Resource               = "https://go.microsoft.com/fwlink/?linkid=2086042"
            Path                   = "{0}\Tools\WinADK"
            File                   = "winadk1903.exe"
            Arguments              = "/quiet /norestart /log $env:temp\winadk.log /features +" 
        }
        [Object]            $WinPE = @{  
        
            Name                   = "WinPE"
            DisplayName            = "Windows Preinstallation Environment"
            Version                = "10.1.17763.1"
            Resource               = "https://go.microsoft.com/fwlink/?linkid=2087112"
            Path                   = "{0}\Tools\WinPE"
            File                   = "winpe1903.exe"
            Arguments              = "/quiet /norestart /log $env:temp\winpe.log /features +" 
        }
        MDTStatus([Object]$Path)
        {
            $This.Output           = @( )

            ForEach ( $Tool in $This.MDT, $This.WinADK, $This.WinPE )
            {
                $Item              = [MDTDependency]::New($Tool)
                $Item.Path         = $Item.Path -f $Path
                $This.Output      += $Item
            }
        }
    }

    Class MDTControl
    {
        Hidden [Object] $Registry
        [Object]          $Module = (Get-FEModule)
        [String]           $Tools
        [Object]          $Status
        MDTControl()
        {
            $This.Registry = "" , "\WOW6432Node" | % { "HKLM:\SOFTWARE$_\Microsoft\Windows\CurrentVersion\Uninstall\*"  } | Get-ItemProperty
            $This.Tools    =  $Env:ProgramData,"Role" -join "\"
            $This.Status   = @( )

            ForEach ($Package in [MDTStatus]::New($This.Role).Output)
            {
                $Item      = $This.Registry | ? DisplayName -match $Package.DisplayName

                If ( $Item -eq $Null -or $Item.DisplayVersion -lt $Package.Version )
                {
                    Write-Host ( "Installing [~] {0}" -f $Package.DisplayName )

                    $Name        = $Package.Name
                    $DisplayName = $Package.DisplayName
                    $Version     = $Package.Version
                    $Resource    = $Package.Resource
                    $Path        = $Package.Path
                    $File        = $Package.File
                    $Arguments   = $Package.Arguments

                    [Net.ServicePointManager]::SecurityProtocol = 3072

                    If (!(Test-Path $Path))
                    {
                        New-Item $Path -ItemType Directory -Verbose
                    }

                    Invoke-RestMethod -URI $Resource -OutFile "$Path\$File"

                    $Process          = Start-Process -FilePath "$Path\$File" -ArgumentList $Arguments -PassThru

                    While (!$Process.HasExited)
                    {
                        For ($X = 0; $X -le 100; $X++)
                        {
                            Write-Progress -Activity "[Installing] @: $($Name)" -PercentComplete $X
                            Start-Sleep -Milliseconds 50
                        }
                    }

                    $Package.IsInstalled = 1
                }

                Else
                {
                    $Package.IsInstalled = 1
                }

                $This.Status        += $Package
            }
        }
    }

    $MDT = [MDTControl]::New()

    If (0 -in $MDT.Status.IsInstalled)
    {
        $MDT.Status | ? IsInstalled -eq 0
    }

    Else
    {
        If ($MDT.Registry | ? DisplayName -match "Microsoft Deployment Toolkit")
        {
            $Install   = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \
            $Templates = Get-FEModule -Control | ? Name -match Mod.xml

            ForEach ($Template in Get-FEModule -Control | ? Name -match Mod.xml)
            {
                If (!(Test-Path $Install\Templates\$($Template.Name)))
                {
                    Copy-Item -Path $Template.FullName -Destination $Install\Templates
                }
            }

            $Install | Get-ChildItem -Filter *Toolkit.psd1 -Recurse | % FullName
        }
    }
}

