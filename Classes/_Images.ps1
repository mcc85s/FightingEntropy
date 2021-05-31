Class _Images # Testing
{
    [String]          $Root = ("{0}\Images" -f ( Get-FEModule | % Path ) )
    [String]         $Drive
    Hidden [String[]] $Tags = ("DC2016 10E64 10H64 10P64 10E86 10H86 10P86" -Split " ")
    [String[]]        $Tree
    Hidden [Object]  $Items
    [Object]         $Files

    _Images()
    {
        $This.Tree  = @( )
        $This.Items = @( )
        $This.Files = @( )

        Test-Path $This.Root | ? { $_ -eq $False } | New-Item $This.Root -ItemType Directory -Verbose

        $This.Tags | % { "$($This.Root)\$_" } | % { 
                
            If ( ! ( Test-Path $_ ) ) 
            {
                New-Item $_ -ItemType Directory -Verbose
            }

            $This.Tree += $_
        }

        $This.ExtractImages("Server","C:\Users\mcook85\Downloads\Windows Server 2016.iso")
        Start-Sleep -Seconds 1

        $This.ExtractImages("Client","C:\Users\mcook85\Downloads\Win10_20H2_English_x64.iso")
        Start-Sleep -Seconds 1
        
        $This.ExtractImages("Client","C:\Users\mcook85\Downloads\Win10_20H2_English_x32.iso")
        Start-Sleep -Seconds 1

        $This.Items | % { $This.Files += [_Image]::New($_.SourceIndex,$_.SourceImagePath,$_.DestinationImagePath,$_.DestinationName) }

        Write-Theme @("Image Extraction Complete"," ","Image Loadout --------------";$This.Files)
    }

    ExtractImages([String]$Type,[String]$ISO)
    {
        If ( ! ( Test-Path $ISO ) )
        {
            Throw "Invalid image path"
        }

        If ( Get-Item $ISO | ? Extension -ne .iso )
        {
            Throw "Invalid image file"
        }

        If ( $Type -notin "Client","Server" )
        {
            Throw "Not a valid image type"
        }

        Write-Theme "Mounting [~] $Iso"
        Get-DiskImage $ISO | Mount-DiskImage
        $This.Drive = Get-DiskImage $ISO | Get-Volume | % DriveLetter

        Switch ($Type)
        {
            Server 
            {
                $Splat                   = @{

                    SourceIndex          = 4
                    SourceImagePath      = "$($This.Drive):\sources\Install.wim"
                    DestinationImagePath = "$($This.Root)\DC2016\DC2016.wim"
                    DestinationName      = "Windows Server 2016 Datacenter x64"
                
                }
                
                Write-Theme @("Extracting...";$Splat) -Palette 11,15,10,0
                    
                Export-WindowsImage @Splat

                $This.Items             += $Splat
            }

            Client 
            {
                ForEach ( $I in 4,1,6 )
                {
                    $Label               = "10{0}{1}" -f @{ 1 = "H"; 4 = "E"; 6 = "P" }[$I],@(86,64)[[Int32]($Iso -match "x64")]

                    $DisplayName         = Switch ($Label) 
                    {
                        "10E64" { "Windows 10 Education x64" }
                        "10H64" { "Windows 10 Home x64"      }
                        "10P64" { "Windows 10 Pro x64"       }
                        "10E86" { "Windows 10 Education x86" }
                        "10H86" { "Windows 10 Home x86"      }
                        "10P86" { "Windows 10 Pro x86"       }
                    }

                    $Splat                   = @{

                        SourceIndex          = $I
                        SourceImagePath      = "$($This.Drive):\sources\Install.wim"
                        DestinationImagePath = "$($This.Root)\$Label\$Label.wim"
                        DestinationName      = $DisplayName

                    }

                    Write-Theme @("Extracting...";$Splat) -Palette 11,15,10,0
                    
                    Export-WindowsImage @Splat

                    $This.Items             += $Splat
                }
            }
        }
        
        Write-Theme "Unmounting [~] $Iso"
        Dismount-DiskImage -ImagePath $ISO -Verbose
    }
}
