Function New-FEImage
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory)][String]$Source,
    [Parameter(Mandatory)][String]$Target)
    
    Class _ImageIndex
    {
        Hidden [UInt32] $Rank
        Hidden [UInt32] $SourceIndex
        Hidden [String] $SourceImagePath
        Hidden [String] $Path
        Hidden [String] $DestinationImagePath
        Hidden [String] $DestinationName
        Hidden [Object] $Disk
        [Object] $Label
        [UInt32] $ImageIndex            = 1
        [String] $ImageName
        [String] $ImageDescription
        [String] $Version
        [String] $Architecture
        [String] $InstallationType

        _ImageIndex([Object]$Iso)
        {
            $This.SourceIndex           = $Iso.SourceIndex
            $This.SourceImagePath       = $Iso.SourceImagePath
            $This.DestinationImagePath  = $Iso.DestinationImagePath
            $This.DestinationName       = $Iso.DestinationName
            $This.Disk                  = Get-DiskImage -ImagePath $This.SourceImagePath
        }

        Load([String]$Target)
        {
            Get-WindowsImage -ImagePath $This.Path -Index $This.SourceIndex | % {

                $This.ImageName         = $_.ImageName
                $This.ImageDescription  = $_.ImageDescription
                $This.Architecture      = Switch ([UInt32]($_.Architecture -eq 9)) { 0 { 86 } 1 { 64 } }
                $This.Version           = $_.Version
                $This.InstallationType  = $_.InstallationType.Split(" ")[0]
            }

            Switch($This.InstallationType)
            {
                Server
                {
                    $Year    = [Regex]::Matches($This.ImageName,"(\d{4})").Value
                    $Edition = Switch -Regex ($This.ImageName) { STANDARD { "Standard" } DATACENTER { "Datacenter" } }
                    $This.DestinationName = "Windows Server $Year $Edition (x64)"
                    $This.Label           = "{0}{1}" -f $(Switch -Regex ($This.ImageName){Standard{"SD"}Datacenter{"DC"}}),[Regex]::Matches($This.ImageName,"(\d{4})").Value
                }

                Client
                {
                    $This.DestinationName = "{0} (x{1})" -f $This.ImageName, $This.Architecture
                    $This.Label           = "10{0}{1}"   -f $(Switch -Regex ($This.ImageName) { Pro {"P"} Edu {"E"} Home {"H"} }),$This.Architecture
                }
            }

            $This.DestinationImagePath    = "{0}\({1}){2}\{2}.wim" -f $Target,$This.Rank,$This.Label

            $Folder                       = $This.DestinationImagePath | Split-Path -Parent

            If (!(Test-Path $Folder))
            {
                New-Item -Path $Folder -ItemType Directory -Verbose
            }
        }
    }

    Class _ImageFile
    {
        [ValidateSet("Client","Server")]
        [String]        $Type
        [String]        $Name
        [String] $DisplayName
        [String]        $Path
        [UInt32[]]     $Index

        _ImageFile([String]$Type,[String]$Path)
        {
            $This.Type  = $Type
        
            If ( ! ( Test-Path $Path ) )
            {
                Throw "Invalid Path"
            }

            $This.Name        = ($Path -Split "\\")[-1]
            $This.DisplayName = "($Type)($($This.Name))"
            $This.Path        = $Path
            $This.Index       = @( )
        }

        AddMap([UInt32[]]$Index)
        {
            ForEach ( $I in $Index )
            {
                $This.Index  += $I
            }
        }
    }

    Class _ImageStore
    {
        [String]   $Source
        [String]   $Target
        [Object[]]  $Store
        [Object[]]   $Swap
        [Object[]] $Output

        _ImageStore([String]$Source,[String]$Target)
        {
            If ( ! ( Test-Path $Source ) )
            {
                Throw "Invalid image base path"
            }

            If ( !(Test-Path $Target) )
            {
                New-Item -Path $Target -ItemType Directory -Verbose
            }

            $This.Source = $Source
            $This.Target = $Target
            $This.Store  = @( )
        }

        AddImage([String]$Type,[String]$Name)
        {
            $This.Store += [_ImageFile]::New($Type,"$($This.Source)\$Name")
        }

        GetSwap()
        {
            $This.Swap = @( )
            $Ct        = 0

            ForEach ( $Image in $This.Store )
            {
                ForEach ( $Index in $Image.Index )
                {
                    $Iso                     = @{ 

                        SourceIndex          = $Index
                        SourceImagePath      = $Image.Path
                        DestinationImagePath = ("{0}\({1}){2}({3}).wim" -f $This.Target, $Ct, $Image.DisplayName, $Index)
                        DestinationName      = "{0}({1})" -f $Image.DisplayName,$Index
                    }

                    $Item                    = [_ImageIndex]::New($Iso)
                    $Item.Rank               = $Ct
                    $This.Swap              += $Item
                    $Ct                     ++
                }
            }
        }

        GetOutput()
        {
            $Last = $Null

            ForEach ( $X in 0..( $This.Swap.Count - 1 ) )
            {
                $Image       = $This.Swap[$X]

                If ( $Last -ne $Null -and $Last -ne $Image.SourceImagePath )
                {
                    Write-Theme "Dismounting... $Last" 12,4,15,0
                    Dismount-DiskImage -ImagePath $Last -Verbose
                }

                If (!(Get-DiskImage -ImagePath $Image.SourceImagePath).Attached)
                {
                    Write-Theme ("Mounting [+] {0}" -f $Image.SourceImagePath) 14,6,15,0
                    Mount-DiskImage -ImagePath $Image.SourceImagePath
                }
                
                $Image.Path = "{0}:\sources\install.wim" -f (Get-DiskImage -ImagePath $Image.SourceImagePath | Get-Volume | % DriveLetter)
                
                $Image.Load($This.Target)

                $ISO                        = @{
        
                    SourceIndex             = $Image.SourceIndex
                    SourceImagePath         = $Image.Path
                    DestinationImagePath    = $Image.DestinationImagePath
                    DestinationName         = $Image.DestinationName
                }
                
                Write-Theme "Extracting [~] $($Iso.DestinationImagePath)" 11,7,15,0
                Export-WindowsImage @ISO
                Write-Theme "Extracted [+] $($Iso.DestinationName)" 10,10,15,0

                $Last                       = $Image.SourceImagePath
                $This.Output               += $Image
            }

            Dismount-DiskImage -ImagePath $Last
        }
    }

    $Images = [_ImageStore]::New($Source,$Target)

    $Index  = 0
    $Images.AddImage("Server","Windows Server 2016.iso")
    $Images.Store[$Index].AddMap(4)
    $Index ++

    $Images.AddImage("Client","Win10_20H2_English_x64.iso")
    $Images.Store[$Index].AddMap((4,1,6))
    $Index ++

    $Images.AddImage("Client","Win10_20H2_English_x32.iso")
    $Images.Store[$Index].AddMap((4,1,6))
    $Index ++

    $Images.GetSwap()
    $Images.GetOutput()
    Write-Theme "Complete [+] Images Collected"
}
