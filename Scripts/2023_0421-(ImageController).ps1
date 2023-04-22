
Function ImageController
{
    Class ImageLabel
    {
        [UInt32]           $Index
        [String]            $Name
        [String]            $Type
        [String]         $Version
        [UInt32[]] $SelectedIndex
        [Object[]]       $Content
        ImageLabel([UInt32]$Index,[Object]$Selected,[UInt32[]]$Queue)
        {
            $This.Index         = $Index
            $This.Name          = $Selected.Fullname
            $This.Type          = $Selected.Type
            $This.Version       = $Selected.Version
            $This.SelectedIndex = $Queue
            $This.Content       = @($Selected.Content | ? Index -in $Index)
            ForEach ($Item in $This.Content)
            {
                $Item.Type      = $Selected.Type
                $Item.Version   = $Selected.Version
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Image[Label]>"
        }
    }

    Class ImageByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        ImageByteSize([String]$Name,[UInt64]$Bytes)
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
                ^Byte     {     "{0} B" -f  $This.Bytes/1    }
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

    Class ImageSlot
    {
        Hidden [Object] $ImageFile
        Hidden [Object]      $Arch
        [UInt32]            $Index
        [String]             $Type
        [String]          $Version
        [String]             $Name
        [String]      $Description
        [Object]             $Size
        [UInt32]     $Architecture
        [String]  $DestinationName
        [String]            $Label
        ImageSlot([Object]$Path,[Object]$Image,[Object]$Slot)
        {
            $This.ImageFile    = $Path
            $This.Arch         = $Image.Architecture
            $This.Type         = $Image.InstallationType
            $This.Version      = $Image.Version
            $This.Index        = $Slot.ImageIndex
            $This.Name         = $Slot.ImageName
            $This.Description  = $Slot.ImageDescription
            $This.Size         = $This.SizeBytes($Slot.ImageSize)
            $This.Architecture = @(86,64)[$This.Arch -eq 9]

            $This.GetLabel()
        }
        [Object] SizeBytes([UInt64]$Bytes)
        {
            Return [ImageByteSize]::New("Image",$Bytes)
        }
        GetLabel()
        {
            $Number = $Null
            $Tag    = $Null
            Switch -Regex ($This.Name)
            {
                Server
                {
                    $Number               = [Regex]::Matches($This.Name,"(\d{4})").Value
                    $Edition              = [Regex]::Matches($This.Name,"(Standard|Datacenter)").Value
                    $Tag                  = @{ Standard = "SD"; Datacenter = "DC" }[$Edition]

                    If ($This.Name -notmatch "Desktop")
                    {
                        $Tag += "X"
                    }

                    $This.DestinationName = "Windows Server $Number $Edition (x64)"
                }
                Default
                {
                    $Number               = [Regex]::Matches($This.Name,"(\d+)").Value
                    $Edition              = $This.Name -Replace "Windows \d+ ",''
                    $Tag                  = Switch -Regex ($Edition)
                    {
                        "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                        "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                        "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                        "^Pro N$"            { "PRO_N"      } "^Pro Education$"     { "PRO_EDUC" }
                        "^Pro Education N$"  { "PRO_EDUC_N" } "^Pro for Work.+$"    { "PRO_WS"   }
                        "^Pro N for Work.+$" { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                    }

                    $This.DestinationName = "{0} (x{1})" -f $This.Name, $This.Architecture
                }
            }

            $This.Label           = "{0}{1}{2}-{3}" -f $Number, $Tag, $This.Architecture, $This.Version
        }
        [String] ToString()
        {
            Return "<FEModule.Image[Slot]>"
        }
    }

    Class ImageFile
    {
        [UInt32]             $Index
        [String]              $Type
        [String]           $Version
        [String]              $Name
        [String]          $Fullname
        Hidden [String]     $Letter
        Hidden [Object[]]  $Content
        ImageFile([UInt32]$Index,[String]$Fullname)
        {
            $This.Index     = $Index
            $This.Name      = $Fullname | Split-Path -Leaf
            $This.Fullname  = $Fullname
            $This.Content   = @( )
        }
        [Object] GetDiskImage()
        {
            Return Get-DiskImage -ImagePath $This.Fullname
        }
        [String] DriveLetter()
        {
            Return $This.GetDiskImage() | Get-Volume | % DriveLetter
        }
        MountDiskImage()
        {
            If ($This.GetDiskImage() | ? Attached -eq 0)
            {
                Mount-DiskImage -ImagePath $This.Fullname
            }

            Do
            {
                Start-Sleep -Milliseconds 100
            }
            Until ($This.GetDiskImage() | ? Attached -eq 1)

            $This.Letter = $This.DriveLetter()
        }
        DismountDiskImage()
        {
            Dismount-DiskImage -ImagePath $This.Fullname
        }
        [Object[]] InstallWim()
        {
            Return ("{0}:\" -f $This.Letter | Get-ChildItem -Recurse | ? Name -match "^install\.(wim|esd)")
        }
        [String] ToString()
        {
            Return "<FEModule.Image[File]>"
        }
    }

    Class ImageController
    {
        [String]        $Source
        [String]        $Target
        [Int32]       $Selected
        [Object]         $Store
        [Object]         $Queue
        [Object]          $Swap
        [Object]        $Output
        Hidden [String] $Status
        ImageController()
        {
            $This.Source   = $Null
            $This.Target   = $Null
            $This.Selected = $Null
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        Clear()
        {
            $This.Selected = -1
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        [Object] ImageLabel([UInt32]$Index,[Object]$Selected,[UInt32[]]$Queue)
        {
            Return [ImageLabel]::New($Index,$Selected,$Queue)
        }
        [Object] ImageFile([UInt32]$Index,[String]$Fullname)
        {
            Return [ImageFile]::New($Index,$Fullname)
        }
        [Object] ImageSlot([Object]$Fullname,[Object]$Image,[Object]$Slot)
        {
            Return [ImageSlot]::New($Fullname,$Image,$Slot)
        }
        [Object[]] GetContent()
        {
            If (!$This.Source)
            {
                Throw "Source path not set"
            }

            Return Get-ChildItem -Path $This.Source *.iso
        }
        GetWindowsImage([String]$Path)
        {
            $File         = $This.Current()
            $Image        = Get-WindowsImage -ImagePath $Path -Index 1
            $File.Version = $Image.Version

            $File.Content = ForEach ($Item in Get-WindowsImage -ImagePath $Path)
            { 
                $This.ImageSlot($Path,$Image,$Item) 
            }
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Store.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        SetSource([String]$Source)
        {
            If (![System.IO.Directory]::Exists($Source))
            {
                Throw "Invalid source path"
            }

            $This.Source = $Source
        }
        SetTarget([String]$Target)
        {
            If (![System.IO.Directory]::Exists($Target))
            {
                $Parent = Split-Path $Target -Parent
                If (![System.IO.Directory]::Exists($Parent))
                {
                    Throw "Invalid target path"
                }
                
                [System.IO.Directory]::CreateDirectory($Target)
            }

            $This.Target = $Target
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Item in $This.GetContent())
            {
                $This.Add($Item.Fullname)
            }
        }
        Add([String]$File)
        {
            $This.Store += $This.ImageFile($This.Store.Count,$File)
        }
        [Object] Current()
        {
            If ($This.Selected -eq -1)
            {
                Throw "No image selected"
            }

            Return $This.Store[$This.Selected]
        }
        Load()
        {
            If (!$This.Current().GetDiskImage().Attached)
            {
                $This.Current().MountDiskImage()
            }
        }
        Unload()
        {
            If (!!$This.Current().GetDiskImage().Attached)
            {
                $This.Current().DismountDiskImage()
            }
        }
        ProcessSlot()
        {
            $Current         = $This.Current()
            $This.Status     = "Loading [~] {0}" -f $Current.Name
            $This.Load()

            $File            = $Current.InstallWim()
            $Current.Type    = @("Non-Windows","Windows")[$File.Count -ne 0]
            $This.Status     = "Type [+] {0}" -f $Current.Type

            If ($Current.Type -eq "Windows")
            {
                If ($File.Count -gt 1)
                {
                    $File        = $File | ? Fullname -match x64
                }

                $This.GetWindowsImage($File.Fullname)
            }
            
            $This.Status     = "Unloading [~] {0}" -f $Current.Name
            $This.Unload()
        }
        Chart()
        {
            Switch ($This.Store.Count)
            {
                0
                {
                    Throw "No images detected"
                }
                1
                {
                    $This.Select(0)
                    $This.ProcessSlot()
                }
                Default
                {
                    ForEach ($X in 0..($This.Store.Count-1))
                    {
                        $This.Select($X)
                        $This.ProcessSlot()
                    }
                }
            }
        }
        AddQueue([UInt32[]]$Queue)
        {
            If ($This.Current().Fullname -in $This.Queue.Name)
            {
                Throw "Image already in the queue, remove, and reindex"
            }

            $This.Queue += $This.ImageLabel($This.Queue.Count,$This.Current(),$Queue)
        }
        RemoveQueue([String]$Name)
        {
            If ($Name -in $This.Queue.Name)
            {
                $This.Queue = @($This.Queue | ? Name -ne $Name)
            }
        }
        Extract()
        {
            If (!$This.Target)
            {
                Throw "Must set target path"
            }
        
            ElseIf ($This.Queue.Count -eq 0)
            {
                Throw "No items queued"
            }
        
            $X = 0
            ForEach ($Queue in $This.Queue)
            {
                $Disc        = $This.Store | ? FullName -eq $Queue.Name
                If (!$Disc.GetDiskImage().Attached)
                {
                    $This.Status = "Mounting [~] {0}" -f $Disc.Name
                    $Disc.MountDiskImage()
                    $Disc.Letter = $Disc.DriveLetter()
                }
        
                $Path         = $Disc.InstallWim()
                If ($Path.Count -gt 1)
                {
                    $Path     = $Path | ? Name -match x64
                }
        
                ForEach ($File in $Disc.Content)
                {
                    $ISO                        = @{
        
                        SourceIndex             = $File.Index
                        SourceImagePath         = $Path.Fullname
                        DestinationImagePath    = "{0}\({1}){2}\{2}.wim" -f $This.Target, $X, $File.Label
                        DestinationName         = $File.DestinationName
                    }
                    
                    $Folder                     = $Iso.DestinationImagePath | Split-Path -Parent
                    # Check + create folder
                    If (![System.IO.Directory]::Exists($Folder))
                    {
                        [System.IO.Directory]::CreateDirectory($Folder)
                    }
        
                    # Check + remove file
                    If ([System.IO.File]::Exists($Iso.DestinationImagePath))
                    {
                        [System.IO.File]::Delete($Iso.DestinationImagePath)
                    }

                    # Create the file
                    $This.Status = "Extracting [~] $($File.DestinationName)"
        
                    Export-WindowsImage @ISO | Out-Null
                    $This.Status = "Extracted [~] $($This.DestinationName)"
        
                    $X ++
                }
        
                $This.Status = "Dismounting [~] {0}" -f $Disc.Name
                $Disc.DismountDiskImage()
            }
        
            $This.Status = "Complete [+] ($($This.Queue.SelectedIndex.Count)) *.wim files Extracted"
        }
        [String] ToString()
        {
            Return "<FEModule.Image[Controller]>"
        }
    }

    [ImageController]::New()
}
