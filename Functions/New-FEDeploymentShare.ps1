Function FEDeploymentShare # https://github.com/mcc85sx/FightingEntropy/blob/master/FEDeploymentShare/FEDeploymentShare.ps1
{
    # Load Assemblies
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms

    # Check for server operating system
    If ( (Get-CimInstance Win32_OperatingSystem).Caption -notmatch "Server" )
    {
        Throw "Must use Windows Server operating system"
    }

    # Prime the classes
    $Base  = "github.com/mcc85sx/FightingEntropy/blob/master/FEDeploymentShare"
    $Order = Invoke-RestMethod "$Base/Classes/index.txt?raw=true" | % Split "`n" | ? Length -gt 0
    $Xaml  = Invoke-WebRequest "$Base/Xaml/DS.xaml?raw=true" | % Content
    $List  = @( )

    ForEach ($Item in $Order)
    {
        $List += (Invoke-RestMethod "$Base/Classes/$Item.ps1?raw=true" -Verbose)
    }

    # Instantiate the classes
    $List -join "`n" | Invoke-Expression

    # Controller class
    Class Main
    {
        Static [String]       $Base = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        Static [String]        $GFX = "$([Main]::Base)\Graphics"
        Static [String]       $Icon = "$([Main]::GFX)\icon.ico"
        Static [String]       $Logo = "$([Main]::GFX)\OEMLogo.bmp"
        Static [String] $Background = "$([Main]::GFX)\OEMbg.jpg"
        Static [String]        $Tab = (IWR github.com/mcc85sx/FightingEntropy/blob/master/FEDeploymentShare/Xaml/DS.xaml?raw=true | % Content)
        [Object]               $Win 
        [Object]               $Reg 
        [Object]                $SM
        Main()
        {
            $This.Win               = Get-WindowsFeature
            $This.Reg               = "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        }
    }
    
    # These two variables do most of the work
    $Main                           = [Main]::New()
    $Xaml                           = [XamlWindow][Main]::Tab

    # ---------------------- #
    # Variables and controls #
    # ---------------------- #

    # Configuration
        # Services[DataGrid]
        # IISInstall
        # IISServerName
        # IISAppPoolName
        # IISVirtualHostName

    # Domain
        # Organization
        # CommonName
        # GetSiteName()
        # SiteMap[DataGrid]
        # AddSitenameZip
        # AddSitenameTown
        # AddSitename()
        # Sitename[DataGrid]

    # Network
        # StackText
        # StackLoad()
        # Stack[DataGrid]
        # Control[DataGrid]
        # Subject[DataGrid]
        # NetBIOSName
        # DNSName

    # Imaging
        # IsoSelect()            
        # IsoPath
        # IsoScan()
        # IsoList[DataGrid]
        # IsoMount()
        # IsoDismount()
        # IsoView[DataGrid]
        # WimQueue()
        # WimDequeue()
        # WimIsoUp()
        # WimIsoDown()
        # WimIso[DataGrid]
        # WimSelect()
        # WimPath
        # WimExtract()

    # Updates
        # $Null

    # Branding
        # Collect()
        # Phone
        # Hours
        # Website
        # LogoSelect()
        # Logo
        # BackgroundSelect()
        # Background

    # Share
        # DSRootSelect()
        # DSRootPath
        # DSShareName
        # DSDescription
        # DSType
        # DSDCUsername
        # DSDCPassword
        # DSDCConfirm
        # DSLMUsername
        # DSLMPassword
        # DSLMConfirm
        # DSOrganizationalUnit
        # DSShare
        # DSInitialize()

    # --------------------------------------- #
    # DataGrid ItemsSource Array Declarations #
    # --------------------------------------- #

    # 1) Configuration
    $Xaml.IO.Services.ItemsSource  = @( )

    # 2) Domain
    $Xaml.IO.Sitemap.ItemsSource   = @( )
    $Xaml.IO.Sitename.ItemsSource  = @( )

    # 3) Network
    $Xaml.IO.Stack.ItemsSource     = @( )
    $Xaml.IO.Control.ItemsSource   = @( )
    # $Xaml.IO.Subject.ItemsSource   = @( )

    # 4) Imaging
    $Xaml.IO.WimIso.ItemsSource    = @( )
    $Xaml.IO.IsoView.ItemsSource   = @( )
    $Xaml.IO.IsoList.ItemsSource   = @( )

    # 7) Share
    $Xaml.IO.DSShare.ItemsSource   = @( )

    # ----------------- #
    # Configuration Tab #
    # ----------------- #

    $Xaml.IO.Services.ItemsSource  = @( 
        
        ForEach ( $Item in "DHCP","DNS","AD-Domain-Services","WDS","Web-WebServer")
        {
            [DGList]::New( $Item, [Bool]( $Main.Win | ? Name -eq $Item | % Installed ) )
        }
        
        ForEach ( $Item in "MDT","WinADK","WinPE")
        {
            $Slot = Switch($Item)
            {
                MDT    { $Main.Reg[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                WinADK { $Main.Reg[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                WinPE  { $Main.Reg[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
            }
                
            [DGList]::New( $Item, [Bool]( Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2] ) )
        }
    )

    # Domain Tab
    $Xaml.IO.GetSitename.Add_Click(
    {
        If (!$Xaml.IO.Organization.Text)
        {
            [System.Windows.MessageBox]::Show("Invalid/null organization entry","Error")
        }

        ElseIf (!$Xaml.IO.CommonName.Text)
        {
            [System.Windows.MessageBox]::Show("Invalid/null common name entry","Error")
        }

        Else
        {
            $Main.SM = [Control]::New($Xaml.IO.Organization.Text,$Xaml.IO.CommonName.Text)
            $Main.SM.Pull()
            $Xaml.IO.Sitemap.ItemsSource   += $Main.SM.Sitemap
            $Xaml.IO.GetSitename.IsEnabled  = 0
            $Xaml.IO.StackLoad.IsEnabled    = 1
        }
    })

    $Xaml.IO.AddSitename.Add_Click(
    {
        If (!$Xaml.IO.AddSitenameZip.Text)
        {
            [System.Windows.MessageBox]::Show("Zipcode text entry error","Error")
        }

        Else
        {
            $Tmp  = $Main.SM.NewCertificate()
            $Item = $Main.SM.ZipStack.ZipTown($Xaml.IO.AddSitenameZip.Text)

                $Tmp[0].Location = $Item.Name
                $Tmp[0].Postal   = $Item.Zip
                $Tmp[0].Region   = [States]::Name($Item.State)

                $Tmp.GetSiteLink()
            }

            $Xaml.IO.Sitemap.ItemsSource += $Tmp
            $Xaml.IO.AddSitenameZip.Text = ""
    })

    $Xaml.IO.SiteMap.Add_MouseDoubleClick(
    {
        $Object = $Xaml.IO.Sitemap.SelectedItem
        $Xaml.IO.Sitename.ItemsSource = $Null
        $Xaml.IO.Sitename.ItemsSource = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName" -Split " " )
        {
            [DGList]::New($Item,$Object.$Item)
        }
    })

    # Network Tab
    $Xaml.IO.StackLoad.Add_Click(
    {
        If ($Xaml.IO.StackText.Text -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
        }

        Else
        {
            $Main.SM.GetNetwork($Xaml.IO.StackText.Text)
            $Xaml.IO.Stack.ItemsSource   = $Null
            $Xaml.IO.Control.ItemsSource = $Null
            #$Xaml.IO.Subject.ItemsSource = $Null
            $Xaml.IO.Stack.ItemsSource   = $Main.SM.Stack
        }
    })

    $Xaml.IO.Stack.Add_MouseDoubleClick(
    {
        If ( $Xaml.IO.Stack.SelectedIndex -gt -1 )
        {
            $Network                         = $Main.SM.Stack | ? Network -match $Xaml.IO.Stack.SelectedItem.Network
            $Xaml.IO.Control.ItemsSource     = $Null
            $Xaml.IO.Control.ItemsSource     = @( $Network )

            #If ( $Control.Count -gt 1 )
            #{
            #    $Subject                     = $Main.SM.Stack | ? Network -notmatch $Network
            #    $Xaml.IO.Subject.ItemsSource = $Subject
            #}
        }
    })

    # Imaging Tab
    $Xaml.IO.IsoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.IsoPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.IsoPath.Add_TextChanged(
    {
        If ( $Xaml.IO.IsoPath.Text -ne "" )
        {
            $Xaml.IO.IsoScan.IsEnabled = 1
        }
    
        Else
        {
            $Xaml.IO.IsoScan.IsEnabled = 0
        }
    })
    
    $Xaml.IO.IsoScan.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.IsoPath.Text))
        {
            [System.Windows.MessageBox]::Show("Invalid image root path","Error")
        }
    
        $Tmp = Get-ChildItem $Xaml.IO.IsoPath.Text *.iso
    
        If (!$Tmp)
        {
            [System.Windows.MessageBox]::Show("No images detected","Error")
        }
        
        $Xaml.IO.IsoList.ItemsSource = $Tmp | Select-Object Name, Fullname
    })
    
    $Xaml.IO.IsoList.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -gt -1 )
        {
            $Xaml.IO.IsoMount.IsEnabled = 1
        }
    
        Else
        {
            $Xaml.IO.IsoMount.IsEnabled = 0
        }
    })
    
    $Xaml.IO.IsoMount.Add_Click(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -eq -1)
        {
            [System.Windows.MessageBox]::Show("No image selected","Error")
        }
    
        $ImagePath  = $Xaml.IO.IsoList.SelectedItem.FullName
        Write-Host "Mounting [~] [$ImagePath]"
    
        Mount-DiskImage -ImagePath $ImagePath -Verbose
    
        $Letter    = Get-DiskImage $ImagePath | Get-Volume | % DriveLetter
        
        If (!$Letter)
        {
            [System.Windows.MessageBox]::Show("Image failed mounting to drive letter","Error")
        }
    
        ElseIf (!(Test-Path "${Letter}:\sources\install.wim"))
        {
            [System.Windows.MessageBox]::Show("Not a valid Windows disc/image","Error")
            Dismount-Diskimage -ImagePath $ImagePath
        }
    
        Else
        {
            $Xaml.IO.IsoView.ItemsSource     = Get-WindowsImage -ImagePath "${Letter}:\sources\install.wim" | % { [WindowsImage]$_ }
            $Xaml.IO.IsoList.IsEnabled       = 0
            $Xaml.IO.IsoDismount.IsEnabled   = 1
            Write-Host "Mounted [+] [$ImagePath]"
        }
    })
    
    $Xaml.IO.IsoDismount.Add_Click(
    {
        $ImagePath                           = $Xaml.IO.IsoList.SelectedItem.FullName
        Dismount-DiskImage -ImagePath $ImagePath
        $Xaml.IO.IsoView.ItemsSource         = $Null
        $Xaml.IO.IsoList.IsEnabled           = 1
    
        Write-Host "Dismounted [+] [$ImagePath]"
        $ImagePath                           = $Null
    
        $Xaml.IO.IsoDismount.IsEnabled       = 0
    })
    
    $Xaml.IO.IsoView.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoView.Items.Count -eq 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 0
        }
    
        If ( $Xaml.IO.IsoView.Items.Count -gt 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 1
        }
    })
    
    $Xaml.IO.WimIso.Add_SelectionChanged(
    {
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled   = 0
            $Xaml.IO.WimIsoUp.IsEnabled     = 0
            $xaml.IO.WimIsoDown.IsEnabled   = 0
        }
    
        If ( $Xaml.IO.WimIso.Items.Count -gt 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled   = 1
            $Xaml.IO.WimIsoUp.IsEnabled     = 1
            $xaml.IO.WimIsoDown.IsEnabled   = 1
        }
    })
    
    $Xaml.IO.WimQueue.Add_Click(
    {
        If ($Xaml.IO.IsoList.SelectedItem.Fullname -in $Xaml.IO.WimIso.Items.Name)
        {
            [System.Windows.MessageBox]::Show("Image already selected","Error")
        }
    
        Else
        {
            $Indexes      = $Xaml.IO.IsoView.SelectedItems.Index -join ","
            $Descriptions = $Xaml.IO.IsoView.SelectedItems.Description -join ","
            $Xaml.IO.WimIso.ItemsSource += [ImageQueue]::New($Xaml.IO.IsoList.SelectedItem.Fullname,$Indexes,$Descriptions)
        }
    })
    
    $Xaml.IO.WimDequeue.Add_Click(
    {
        $Grid = $Xaml.IO.WimIso.ItemsSource
        $Items = @( )
    
        ForEach ( $Item in $Grid )
        {
            If ( $Item -ne $Xaml.IO.WimIso.SelectedItem )
            {
                $Items += $Item
            }
        }
    
        $Xaml.IO.WimIso.ItemsSource = @( )
        $Xaml.IO.WimIso.ItemsSource = $Items
        $Grid                       = $Null
        $Items                      = $Null
    
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled = 0
        }
    })
    
    $Xaml.IO.WimIsoUp.Add_Click(
    {
        If ( $Xaml.IO.WimIso.Items.Count -gt 1 )
        {
            $Rank  = $Xaml.IO.WimIso.SelectedIndex
            $Grid  = $Xaml.IO.WimIso.ItemsSource
            $Items = 0..($Grid.Count-1)
    
            If ($Rank -ne 0)
            {
                ForEach ($I in 0..($Grid.Count-1))
                {
                    If ( $I -eq $Rank - 1 )
                    {
                        $Items[$I] = $Grid[$I+1]
                    }
    
                    ElseIf ( $I -eq $Rank )
                    {
                        $Items[$I] = $Grid[$I-1]   
                    }
    
                    Else
                    {
                        $Items[$I] = $Grid[$I]
                    }
                }
    
                $Xaml.IO.WimIso.ItemsSource = @( )
                $Xaml.IO.WimIso.ItemsSource = $Items
                $Items = $Null
                $Rank  = $Null
                $Grid  = $Null
            }
        }
    })
    
    $Xaml.IO.WimIsoDown.Add_Click(
    {
        If ( $Xaml.IO.WimIso.Items.Count -gt 1 )
        {
            $Rank  = $Xaml.IO.WimIso.SelectedIndex
            $Grid  = $Xaml.IO.WimIso.ItemsSource
            $Items = 0..($Grid.Count - 1)
    
            If ($Rank -ne $Grid.Count - 1)
            {
                ForEach ($I in 0..($Grid.Count-1))
                {
                    If ( $I -eq $Rank )
                    {
                        $Items[$I] = $Grid[$I+1]   
                    }
    
                    ElseIf ( $I -eq $Rank + 1 )
                    {
                        $Items[$I] = $Grid[$I-1]
                    }
    
                    Else
                    {
                        $Items[$I] = $Grid[$I]
                    }
                }
                
                $Xaml.IO.WimIso.ItemsSource = @( )
                $Xaml.IO.WimIso.ItemsSource = $Items
                $Items = $Null
                $Rank  = $Null
                $Grid  = $Null
            }
        }
    })
    
    $Xaml.IO.WimExtract.Add_Click(
    {
        If (Test-Path $Xaml.IO.WimPath.Text)
        {
            $Children = Get-ChildItem $Xaml.IO.WimPath.Text *.wim -Recurse | % FullName

            If ($Children.Count -gt 0)
            {
                Switch([System.Windows.MessageBox]::Show("Wim files detected at provided path.","Purge and rebuild?","YesNo"))
                {
                    Yes
                    {
                        ForEach ( $Child in $Children )
                        {
                            Remove-Item $Child -Force -Verbose
                        }
                    }

                    No
                    {
                        Break
                    }
                }
            }
        }

        If (!(Test-Path $Xaml.IO.WimPath.Text))
        {
            New-Item -Path $Xaml.IO.WimPath.Text -ItemType Directory -Verbose
        }
    
        $Images = [ImageStore]::New($Xaml.IO.IsoPath.Text,$Xaml.IO.WimPath.Text)
    
        $X      = 0
        ForEach ( $Item in $Xaml.IO.WimIso.Items )
        {
            $Type = Switch -Regex ($Item.Description)
            {
                Server { "Server" } Default { "Client" }
            }
    
            $Images.AddImage($Type,$Item.Name)
            $Images.Store[$X].AddMap($Item.Index.Split(","))
            $X ++
        }
    
        $Images.GetSwap()
        $Images.GetOutput()
        Write-Theme "Complete [+] Images Collected"
    })
    
    $Xaml.IO.WimSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.WimPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.WimPath.Add_TextChanged(
    {
        If ( $Xaml.IO.WimPath.Text -ne "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 1
        }
    
        If ( $Xaml.IO.WimPath.Text -eq "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 0
        }
    })

    # Branding Tab
    $Xaml.IO.LogoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Logo
        }

        $Xaml.IO.Logo.Text = $Item.FileName
    })
    
    $Xaml.IO.BackgroundSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Background
        }

        $Xaml.IO.Background.Text = $Item.FileName
    })

    # Share Tab
    $Xaml.IO.DSInitialize.Add_Click(
    {
        If ( $Xaml.IO.Services.Items | ? Name -eq MDT | ? Value -ne $True )
        {
            Throw "Unable to initialize, MDT not installed"
        }

        If ( $PSVersionTable.PSEdition -ne "Desktop" )
        {
            Throw "Unable to initialize, use Windows PowerShell v5.1"
        }

        If (!$Xaml.IO.DSDCUsername.Text)
        {
            [System.Windows.MessageBox]::Show("Missing the deployment share domain account name","Error")
        }

        If ($Xaml.IO.DSDCPassword.Password -notmatch $Xaml.IO.DSDCConfirm.Password)
        {
            [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        } 

        If (!$Xaml.IO.DSLMUsername.Text)
        {
            [System.Windows.MessageBox]::Show("Missing the child item local account name","Error")
        }

        If ($Xaml.IO.DSLMPassword.Password -notmatch $Xaml.IO.DSLMConfirm.Password)
        {
            [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        }

        Write-Theme "Creating [~] Deployment Share"

        $MDT     = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \
        Import-Module "$MDT\Bin\MicrosoftDeploymentToolkit.psd1"

        If (Get-MDTPersistentDrive)
        {
            $Persist = Restore-MDTPersistentDrive
        }

        $SMB     = Get-SMBShare
        $PSD     = Get-PSDrive

        If ($Xaml.IO.DSRootPath.Text -in $Persist.Root)
        {
            [System.Windows.MessageBox]::Show("That path belongs to an existing deployment share","Error")
        }

        ElseIf($Xaml.IO.DSShareName.Text -in $SMB.Name)
        {
            [System.Windows.MessageBox]::Show("That share name belongs to an existing SMB share","Error")
        }

        ElseIf ($Xaml.IO.DSDriveName.Text -in $PSD.Name)
        {
            [System.Windows.MessageBox]::Show("That (DSDrive|PSDrive) label is already being used","Error")
        }

        Else
        {
            If (!(Test-Path $Xaml.IO.DSRootPath.Text))
            {
                New-Item $Xaml.IO.DSRootPath.Text -ItemType Directory -Verbose
            }

            $Hostname       = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()

            $SMB            = @{

                Name        = $Xaml.IO.DSShareName.Text
                Path        = $Xaml.IO.DSRootPath.Text
                Description = $Xaml.IO.DSDescription.Text
                FullAccess  = "Administrators"
            }

            $PSD            = @{ 

                Name        = $Xaml.IO.DSDriveName.Text
                PSProvider  = "MDTProvider"
                Root        = $Xaml.IO.DSRootPath.Text
                Description = $Xaml.IO.DSDescription.Text
                NetworkPath = ("\\{0}\{1}" -f $Hostname, $Xaml.IO.DSShareName.Text)
            }

            New-SMBShare @SMB
            New-PSDrive  @PSD -Verbose | Add-MDTPersistentDrive -Verbose

            # Load Module / Share Drive Mount
            $Module                = Get-FEModule
            $Root                  = "$($PSD.Name):\"
            $Control               = "$($PSD.Root)\Control"
            $Script                = "$($PSD.Root)\Scripts"

            # To propogate the environment keys to child item [server/client]
            $DS                    = @($PSD.NetworkPath,
                $Xaml.IO.Organization.Text,
                $Xaml.IO.CommonName.Text,
                $Xaml.IO.Background.Text,
                $Xaml.IO.Logo.Text,
                $Xaml.IO.Phone.Text,
                $Xaml.IO.Hours.Text,
                $Xaml.IO.Website.Text)
            $Key                   = [Key]$DS
            
            # Copies the background and logo if they were selected
            ForEach ($File in $Key.Background, $Key.Logo)
            {
                If (Test-Path $File)
                {
                    Copy-Item -Path $File -Destination $Script -Verbose

                    If ($File -eq $Key.Background)
                    {
                        $Key.Background = "$($Key.NetworkPath)\Scripts\$($Key.Background | Split-Path -Leaf)"
                    }

                    If ($File -eq $Key.Logo)
                    {
                        $Key.Logo       = "$($Key.NetworkPath)\Scripts\$($Key.Logo | Split-Path -Leaf)"
                    }
                }
            }

            # For the little computer icon in PXE
            ForEach ( $File in $Module.Control | ? Extension -eq .png )
            {
                Copy-Item -Path $File.Fullname -Destination $Script -Force -Verbose
            }

            # Copies custom template for FightingEntropy to post install/configure
            ForEach ( $File in $Module.Control | ? Name -match Mod.xml )
            {
                Copy-Item -Path $File.FullName -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
            }

            # Used to spawn the correct environment keys on child items
            Set-Content -Path "$($PSD.Root)\DSKey.csv" -Value ($Key | ConvertTo-CSV) -Verbose

            Write-Theme "Collecting [~] images"
            $Images      = @( )
            
            # Extract/order the WIM files and prime for MDT Injection
            Get-ChildItem -Path $Xaml.IO.WimPath.Text -Recurse *.wim | % { 
                
                Write-Host "Processing [$($_.FullName)]"
                $Images += [WimFile]::New($Images.Count,$_.FullName) 
            }

            # Import OS/TS to MDT Share
            $OS          = "$($PSD.Name):\Operating Systems"
            $TS          = "$($PSD.Name):\Task Sequences"
            $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]"

            # Create folders in the new MDT share
            ForEach ( $Type in "Server","Client" )
            {
                ForEach ( $Version in $Images | ? InstallationType -eq $Type | % Version | Select-Object -Unique )
                {
                    ForEach ( $Slot in $OS, $TS )
                    {
                        If (!(Test-Path "$Slot\$Type"))
                        {
                            New-Item -Path $Slot -Enable True -Name $Type -Comments $Comment -ItemType Folder -Verbose
                        }

                        If (!(Test-Path "$Slot\$Type\$Version"))
                        {
                            New-Item -Path "$Slot\$Type" -Enable True -Name $Version -Comments $comment -ItemType Folder -Verbose
                        }
                    }
                }
            }

            ForEach ( $Image in $Images )
            {
                $Type                   = $Image.InstallationType
                $Path                   = "$OS\$Type\$($Image.Version)"

                $OperatingSystem        = @{

                    Path                = $Path
                    SourceFile          = $Image.SourceImagePath
                    DestinationFolder   = $Image.Label
                }
                
                Import-MDTOperatingSystem @OperatingSystem -Move -Verbose

                $TaskSequence           = @{ 
                    
                    Path                = "$TS\$Type\$($Image.Version)"
                    Name                = $Image.ImageName
                    Template            = "FE{0}Mod.xml" -f $Type
                    Comments            = $Comment
                    ID                  = $Image.Label
                    Version             = "1.0"
                    OperatingSystemPath = Get-ChildItem -Path $Path | ? Name -match $Image.Label | % { "{0}\{1}" -f $Path, $_.Name }
                    FullName            = $Xaml.IO.DCLMUsername
                    OrgName             = $Xaml.IO.Organization
                    HomePage            = $Xaml.IO.Website
                    AdminPassword       = $Xaml.IO.DCLMPassword.Password
                }

                Import-MDTTaskSequence @TaskSequence -Verbose
            }

            Write-Theme "OS/TS [+] Imported, removing Wim Swap directory" 11,3,15,0
            Remove-Item -Path $Xaml.IO.WimPath.Text -Recurse -Force -Verbose

            # FightingEntropy(π) Installation propogation
            $Install = "[Net.ServicePointManager]::SecurityProtocol = 3072",
            "Invoke-RestMethod https://github.com/mcc85s/FightingEntropy/blob/master/Install.ps1?raw=true | Invoke-Expression",
            "`$Key = '$($Key | ConvertTo-Json)'",
            "New-EnvironmentKey -Key `$Key | % Apply `n"

            Set-Content -Path $Script\Install.ps1 -Value $Install -Force -Verbose

            Write-Theme "Setting [~] Share properties [($Root)]"

            # Share Settings
            Set-ItemProperty $Root -Name Comments    -Value $("[FightingEntropy({0})]{1}" -f [Char]960,(Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]") ) -Verbose
            Set-ItemProperty $Root -Name MonitorHost -Value $HostName -Verbose

            # Image Names/Background
            ForEach ($x in 64,86)
            {
                $Names  = $X | % { "Boot.x$_" } | % { "$_.Generate{0}ISO $_.{0}WIMDescription $_.{0}ISOName $_.BackgroundFile" -f "LiteTouch" -Split " " }
                $Values = $X | % { "$($Module.Name)[$($Module.Version)](x$_)" } | % { "True;$_;$_.iso;$($Xaml.IO.Background.Text)" -Split ";" }
                0..3         | % { Set-ItemProperty -Path $Root -Name $Names[$_] -Value $Values[$_] -Verbose } 
            }

            # Bootstrap.ini
            Export-Ini -Path $Control\Bootstrap.ini -Value @{ 

                Settings           = @{ Priority             = "Default"                      }
                Default            = @{ DeployRoot           = $Key.NetworkPath
                                        UserID               = $Xaml.IO.DSDCUserName.Text
                                        UserPassword         = $Xaml.IO.DSDCPassword.Password
                                        UserDomain           = $Xaml.IO.CommonName.Text
                                        SkipBDDWelcome       = "YES"                          }
            } | % Output

            # CustomSettings.ini
            Export-Ini -Path $Control\CustomSettings.ini -Value @{

                Settings           = @{ Priority             = "Default" 
                                        Properties           = "MyCustomProperty" }
                Default            = @{ _SMSTSOrgName        = $Xaml.IO.Organization.Text
                                        JoinDomain           = $Xaml.IO.CommonName.Text
                                        DomainAdmin          = $Xaml.IO.DSDCUserName.Text
                                        DomainAdminPassword  = $Xaml.IO.DSDCPassword.Password
                                        DomainAdminDomain    = $Xaml.IO.CommonName.Text
                                        SkipDomainMembership = "YES"
                                        OSInstall            = "Y"
                                        SkipCapture          = "NO"
                                        SkipAdminPassword    = "YES" 
                                        SkipProductKey       = "YES" 
                                        SkipComputerBackup   = "NO" 
                                        SkipBitLocker        = "YES" 
                                        KeyboardLocale       = "en-US" 
                                        TimeZoneName         = "$(Get-TimeZone | % ID)"
                                        EventService         = ("http://{0}:9800" -f $Key.NetworkPath.Split("\")[2]) }
            } | % Output

            # Update FEShare(MDT)
            Update-MDTDeploymentShare -Path $Root -Force -Verbose

            # Update/Flush FEShare(Images)
            $ImageLabel = Get-ItemProperty -Path $Root | % { 

                @{  64 = $_.'Boot.x64.LiteTouchWIMDescription'
                    86 = $_.'Boot.x86.LiteTouchWIMDescription' }
            }

            # Rename the Litetouch_ files
            Get-ChildItem -Path "$($Xaml.IO.DSRootPath.Text)\Boot" | ? Extension | % { 

                $Label          = $ImageLabel[$(Switch -Regex ($_.Name) { 64 {64} 86 {86}})]
                $Image          = @{ 

                    Path        = $_.FullName
                    Name        = $_.Name
                    NewName     = "{0}{1}" -f $Label,$_.Extension
                    Extension   = $_.Extension
                }

                If ( $Image.Name -match "LiteTouchPE_" )
                {
                    If ( Test-Path $Image.NewName )
                    {
                        Remove-Item -Path $Image.NewName -Force -Verbose
                    }

                    Rename-Item -Path $Image.Path -NewName $Image.NewName
                }
            }

            If (!(Get-Service | ? Name -eq WDSServer))
            {
                Throw "WDS Server not installed"
            }

            # Update/Flush FEShare(WDS)
            ForEach ( $Image in [BootImages]::New("$($Xaml.IO.DSRootPath.Text)\Boot").Images )
            {        
                If (Get-WdsBootImage -Architecture $Image.Type -ImageName $Image.Name -EA 0)
                {
                    Write-Theme "Detected [!] $($Image.Name), removing..." 12,4,15,0
                    Remove-WDSBootImage -Architecture $Image.Type -ImageName $Image.Name -Verbose
                }

                Write-Theme "Importing [~] $($Image.Name)" 11,3,15,0
                Import-WdsBootImage -Path $Image.Wim -NewDescription $Image.Name -Verbose
            }

            Restart-Service -Name WDSServer

            Write-Theme -Flag
        }
    })

    # Set initial TextBox values
    $Xaml.IO.NetBIOSName.Text = $Env:UserDomain
    $Xaml.IO.DNSName.Text     = @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
    
    $Xaml.Invoke()

}
