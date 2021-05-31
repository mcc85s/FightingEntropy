Class _Share
    {
        [Object]         $Module = (Get-FEModule)
        [Object]         $Shares = (Get-SMBShare)
        [String]      $ShareName
        [String]      $SharePath
        [String] $FileSystemPath
        [String]   $ProviderPath
        [String]           $Name
        [String]     $PSProvider = "MDTProvider"
        [String]           $Root
        [String]    $Description = $Null
        [String]    $NetworkPath
        [Object]        $Company

        [Object]            $MDT = @{

            Name        = "Microsoft Deployment Toolkit" 
            Path        = ( Get-ChildItem ( Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" ).Install_Dir -Filter *Toolkit.psd1 -Recurse ).FullName
            Description = ("The [Microsoft Deployment Toolkit]\\_It is *the* toolkit...\_...that Microsoft themselves uses...\" +
                            "_...to deploy additional toolkits.\\_It's not that weird.\_You're just thinking way too far into it" +
                            ", honestly.\\_Regardless... it is quite a fearsome toolkit to have in one's pocket.\_Or, wherever " +
                            "really...\_...at any given time.\\_When you need to be taken seriously...?\_Well, it *should* be t" +
                            "he first choice on one's agenda.\_But that's up to you.\\_The [Microsoft Deployment Toolkit].\_Eve" +
                            "n Mr. Gates thinks it's awesome." ).Replace("_","    ").Split('\')
        }

        _Share([String]$ShareName,[String]$SharePath,[String]$FilesystemPath,[String]$Description)
        {
            $This.ShareName            = "{0}$" -f $ShareName.TrimEnd("$")
            $This.SharePath            = $SharePath
            $This.FileSystemPath       = $FileSystemPath
            $This.Description          = $Description
        }

        Get()
        {
            If ( ! ( Test-Path $This.MDT.Path ) )
            {
                Throw "Microsoft Deployment Toolkit not installed"
            }

            Import-Module $This.MDT.Path -Verbose

            $This.Shares       = Get-MDTPersistentDrive
        }

        New()
        {
            If ( Test-Path $This.FileSystemPath )
            {
                Throw "Path exists"
            }

            If ( $This.ShareName -in $This.Shares.Name -or $This.FileSystemPath -in $This.Shares.Path )
            {
                Throw "SMB Share exists"
            }

            $This.Get()

            If ( $This.ShareName -in $This.Shares.Name -or $This.FileSystemPath -in $This.Shares.Path )
            {
                Throw "MDT/FE Share exists"
            }

            If ( !! $This.Names )
            {
                $This.Name     = $This.Shares.Name | % { @($_,$_[-1])[[Int32]($_.Count -gt 1)].Replace("DS","") } | % { "FE{0:d3}" -f ( [Int32]$_ + 1 ) }
            }

            @{  Path           = $This.FileSystemPath
                ItemType       = "Directory"       } | % { New-Item @_ -Verbose }

            @{  Name           = $This.ShareName
                Path           = $This.FileSystemPath
                FullAccess     = "Administrators"  } | % { New-SMBShare @_ -Verbose }

            @{  Name           = $This.Name
                PSProvider     = $This.PSProvider
                Root           = $This.FileSystemPath
                Description    = $This.Description
                NetworkPath    = $This.SharePath
                Verbose        = $True            } | % { New-PSDrive @_ | Add-MDTPersistentDrive -Verbose }

        If ( $? -eq $True )
        {
            $This.Module   | ? Status -eq Initialized | % { 
                
                Set-ItemProperty -Path $_.Registry -Name Status -Value Installed -Verbose
                New-Item         -Path $_.Registry -Name Shares -Verbose
            }

            Get-MDTPersistentDrive | ? Name -eq $This.Name | % {  

                New-Item         -Path $Path\Shares            -Name $_.Name                           -Verbose
                New-ItemProperty -Path $Path\Shares\$($_.Name) -Name Name        -Value $_.Name        -Verbose
                New-ItemProperty -Path $Path\Shares\$($_.Name) -Name Path        -Value $_.Path        -Verbose
                New-ItemProperty -Path $Path\Shares\$($_.Name) -Name Description -Value $_.Description -Verbose
            }
        }
    }

    Remove()
    {
        $This.Get()

        If ( $This.FileSystemPath -in $This.Shares.Path )
        {
            Get-MDTPersistentDrive | ? Path -eq C:\FightingEntropy | % { 
                
                If ( $_.Name -in ( $Module.Shares | % PSChildName ) )
                {
                    "Removing {0}" -f $_.Name

                    Remove-Item -Path $($This.Module.Registry)\Shares\$($_.Name) -Recurse -Force

                    Remove-MDTPersistentDrive -Name $_.Name -Verbose
                }
            }
        }
    }
}
