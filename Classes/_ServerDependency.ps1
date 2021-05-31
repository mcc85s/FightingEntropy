Class _ServerDependency
{
    [Object]         $Registry = @( "" , "\WOW6432Node" | % { "HKLM:\SOFTWARE$_\Microsoft\Windows\CurrentVersion\Uninstall\*"  } )
    [Object]             $Root = (Get-FEModule | % Path)
    [Object[]]       $Packages = @(@{
        
        Name                   = "MDT"
        DisplayName            = "Microsoft Deployment Toolkit"
        Version                = "6.3.8450.0000"
        Resource               = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x{0}.msi" -f @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
        Path                   = "{0}\Tools\MDT"
        File                   = "MicrosoftDeploymentToolkit_x{0}.msi" -f @{x86 = 86; AMD64 = 64 }[$Env:Processor_Architecture]
        Arguments              = "/quiet /norestart"
    
    };@{  

        Name                   = "WinADK"
        DisplayName            = "Windows Assessment and Deployment Kit"
        Version                = "10.1.17763.1"
        Resource               = "https://go.microsoft.com/fwlink/?linkid=2086042"
        Path                   = "{0}\Tools\WinADK"
        File                   = "winadk1903.exe"
        Arguments              = "/quiet /norestart /log $env:temp\winadk.log /features +" 
        
    };@{  
        
        Name                   = "WinPE"
        DisplayName            = "Windows Preinstallation Environment"
        Version                = "10.1.17763.1"
        Resource               = "https://go.microsoft.com/fwlink/?linkid=2087112"
        Path                   = "{0}\Tools\WinPE"
        File                   = "winpe1903.exe"
        Arguments              = "/quiet /norestart /log $env:temp\winpe.log /features +" 
    })

    _ServerDependency()
    { 
        If ( ! ( Test-Path "$($This.Root)\Tools" ) ) 
        { 
            New-Item "$($This.Root)\Tools" -ItemType Directory -Verbose 
        }

        $Uninstall             = Get-ItemProperty $This.Registry

        ForEach ( $Package in $This.Packages )
        {
            $Item              = $Uninstall | ? DisplayName -match $Package.DisplayName

            If ( $Item -eq $Null -or $Item.DisplayVersion -lt $Package.Version )
            {
                Write-Host ( "Installing {0}" -f $Package.DisplayName )

                $Name        = $Package.Name
                $DisplayName = $Package.DisplayName
                $Version     = $Package.Version
                $Resource    = $Package.Resource
                $Path        = $Package.Path -f (Get-FEModule | % Path)
                $File        = $Package.File
                $Arguments   = $Package.Arguments

                [Net.ServicePointManager]::SecurityProtocol = 3072

                If ( ! ( Test-Path $Path ) )
                {
                    New-Item $Path -ItemType Directory -Verbose
                }

                Invoke-RestMethod -URI $Resource -OutFile "$Path\$File"

                $Process          = Start-Process -FilePath "$Path\$File" -ArgumentList $Arguments -PassThru

                While ( ! ( $Process.HasExited ) )
                {
                    For ( $X = 0; $X -le 100; $X++ )
                    {
                        Write-Progress -Activity "[Installing] @: $($Name)" -PercentComplete $X
                        Start-Sleep -Milliseconds 50
                    }
                }
            }

            Else
            {
                Write-Host ( "{0} is installed, and meets version requirements." -f $Package.DisplayName )
            }
        }
    }
}
