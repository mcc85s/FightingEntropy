<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Programmatic Arithmetic [~] 09/18/2023                                                         ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

\______________________________________________________________________________________________________________________/
  Introduction /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                         

    [Objective]: My system hard drive on my laptop is nearly full. Use some of the classes I've written
    in other (functions/classes) to transfer files that are NOT already in my storage backup drive, to the
    storage backup drive.
                                                                                                         ______________/
\_______________________________________________________________________________________________________/ Introduction  
#>

# // ================================================
# // | Converts a byte size to a descriptive object |
# // ================================================

Class VideoFileSize
{
    [String]   $Type
    [UInt64]  $Bytes
    [String]   $Unit
    [String]   $Size
    VideoFileSize([String]$Type,[UInt64]$Bytes)
    {
        $This.Type   = $Type
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
    [String] GetLabel()
    {
        $Label = Switch ($This.Unit)
        {
            Byte     { "1"   }
            Kilobyte { "1KB" }
            Megabyte { "1MB" }
            Gigabyte { "1GB" }
            Terabyte { "1TB" }
        }
        Return $Label
    }
    [String] ToString()
    {
        Return $This.Size
    }
}

# // =======================================================
# // | Converts a [DateTime] object to a consumable format |
# // =======================================================

Class VideoFileDate
{
    [String] $Type
    Hidden [DateTime] $Real
    [String] $Date
    VideoFileDate([String]$Type,[DateTime]$Real)
    {
        $This.Type = $Type
        $This.Real = $Real
        $This.Date = $Real.ToString("MM/dd/yyyy HH:mm:ss")
    }
    [String] ToString()
    {
        Return $This.Date
    }
}

# // =========================================================
# // | Converts an index and rounded input to progress index |
# // =========================================================

Class VideoFileProgress
{
        [UInt32]  $Index
        [UInt32]   $Slot
        [String] $Status
        VideoFileProgress([UInt32]$Index,[Object]$Slot)
        {
            $This.Index  = $Index
            $This.Slot   = $Slot
            $This.Status = "{0:p}" -f ($Index/100)
        }
        [String] ToString()
        {
            Return $This.Status
        }
}

# // =================================================================
# // | Represents a file system object with the above nested classes |
# // =================================================================

Class VideoFileEntry
{
    [UInt32] $Index
    [String] $Source
    [Object] $Size
    Hidden [UInt32] $Folder
    Hidden [Object] $Create
    Hidden [Object] $Access
    Hidden [Object] $Write
    [String] $Name
    [String] $Fullname
    [String] $Hash
    VideoFileEntry([UInt32]$Index,[String]$Source,[Object]$Item)
    {
        $This.Index    = $Index
        $This.Source   = $Source
        $This.Size     = $This.VideoFileSize("File",$Item.Length)
        $This.Folder   = $Item.PSIsContainer
        $This.Create   = $This.VideoFileDate("Created",$Item.CreationTime)
        $This.Access   = $This.VideoFileDate("Accessed",$Item.LastAccessTime)
        $This.Write    = $This.VideoFileDate("Modified",$Item.LastWriteTime)
        $This.Name     = $Item.Name
        $This.Fullname = $Item.Fullname
    }
    [Object] VideoFileDate([String]$Type,[DateTime]$Real)
    {
        Return [VideoFileDate]::New($Type,$Real)   
    }
    [Object] VideoFileSize([String]$Name,[UInt64]$Bytes)
    {
        Return [VideoFileSize]::New($Name,$Bytes)
    }
    [String] GetFileHash()
    {
        Return Get-FileHash $This.Fullname | % Hash
    }
    [Object] Full()
    {
        Return $This | Select-Object Index, Source, Folder, Create, Access, Write, Name, Fullname, Size, Hash
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

# // ==================================================================
# // | Represents a file system object list, as well as type and path |
# // ==================================================================

Class VideoFileIndex
{
    [String] $Type
    [String] $Path
    [Object] $Output
    VideoFileIndex([String]$Type,[String]$Path)
    {
        $This.Type   = $Type
        $This.Path   = $Path
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] VideoFileEntry([UInt32]$Index,[String]$Source,[Object]$Item)
    {
        Return [VideoFileEntry]::New($Index,$Source,$Item)
    }
    [Object] VideoFileProgress([UInt32]$Index,[Object]$Slot)
    {
        Return [VideoFileProgress]::New($Index,$Slot)
    }
    Refresh()
    {
        $Hash     = @{ }
        $List     = Get-ChildItem $This.Path -Recurse | Sort-Object Fullname
        $Step     = $List.Count/100
        $Track    = 0..100 | ? {$_ % 5 -eq 0} | % { $This.VideoFileProgress($_,[Math]::Round($_*$Step)) }
        $Slot     = $Track[0]
        $Activity = "Processing <{0}> files [~] Total: ({1})" -f $This.Type, $List.Count

        Write-Progress -Activity $Activity -Status $Slot.Status -PercentComplete $Slot.Index

        ForEach ($X in 0..($List.Count-1))
        {
            $Hash.Add($X,$This.VideoFileEntry($X,$This.Type,$List[$X]))

            If ($X -in $Track.Slot)
            {
                $Slot = $Track | ? Slot -eq $X
                Write-Progress -Activity $Activity -Status $Slot.Status -PercentComplete $Slot.Index
            }
        }

        $This.Output = $Hash[0..($Hash.Count-1)]

        Write-Progress -Activity $Activity -Status Complete -Completed
    }
}

# // =========================================================================
# // | Converts an index, floating point, and total size to a progress index |
# // =========================================================================

Class VideoFileTransferProgress
{
    [UInt32]  $Index
    [Object]   $Size
    [String] $Status
    VideoFileTransferProgress([UInt32]$Index,[Float]$Step,[Object]$Total)
    {
        $This.Index  = $Index

        If ($Index -eq 0)
        {
            $Bytes = 0

        }
        Else
        {
            $Bytes = ($Total.Bytes*$Index)/100
        }

        $This.Size   = $This.VideoFileSize($Bytes)
        $This.Status = "{0:p}" -f ($Index/100)
    }
    [Object] VideoFileSize([UInt64]$Bytes)
    {
        Return [VideoFileSize]::New($This.Index,$Bytes)
    }
    [String] ToString()
    {
        Return $This.Status
    }
}

# // =======================================================================================
# // | Tracks start time, and allows percentage input to adjust ETA of transfer completion |
# // =======================================================================================

Class VideoFileTransferPercent
{
    [DateTime]   $Start
    [DateTime]     $Now
    [DateTime]     $End
    [Float]    $Percent
    [TimeSpan] $Elapsed
    [TimeSpan]  $Remain
    [TimeSpan]   $Total
    VideoFileTransferPercent([String]$Start)
    {
        $This.Start = [DateTime]$Start
    }
    VideoFilePercent([DateTime]$Start)
    {
        $This.Start = $Start
    }
    [Object] GetPercent([Float]$Percent)
    {
        $This.Now     = [DateTime]::Now
        $This.Elapsed = [TimeSpan]($This.Now-$This.Start)
        $This.Percent = $Percent
        $This.Total   = [TimeSpan]::FromSeconds(($This.Elapsed.TotalSeconds/$This.Percent)*100)
        $This.Remain  = $This.Total - $This.Elapsed
        $This.End     = [DateTime]($This.Now + $This.Remain)

        Return $This
    }
}

# // ======================================================
# // | For copying larger files with a progress indicator |
# // ======================================================

Class VideoFileTransferStream
{
    Hidden [UInt32] $Id
    [String]      $Name
    [Object]    $Source
    [Object]    $Target
    [Byte[]]    $Buffer
    [Long]       $Total
    [UInt32]     $Count
    VideoFileTransferStream([UInt32]$Id,[String]$Source,[String]$Target)
    {
        $This.Id     = $Id
        $This.Name   = $Source | Split-Path -Leaf
        $This.Source = [System.IO.File]::OpenRead($Source)
        $This.Target = [System.IO.File]::OpenWrite($Target)

        $Splat            = @{

            Activity        = "Copying File [{0}]" -f $This.Name
            ParentId        = $This.Id
            Id              = 1
            Status          = "$Source -> $Target"
            PercentComplete = 0
        }

        Write-Progress @Splat
        Try 
        {
            $This.Buffer  = [Byte[]]::New(4096)
            $This.Total   = $This.Count = 0
            Do 
            {
                $This.Count = $This.Source.Read($This.Buffer,0,$This.Buffer.Length)
                $This.Target.Write($This.Buffer,0,$This.Count)
                $This.Total += $This.Count
                If ($This.Total % 1MB -eq 0) 
                {
                    $Splat              = @{
                        
                        Activity        = "Copying File [{0}]" -f $This.Name
                        ParentId        = $This.Id
                        Id              = 1
                        Status          = "$Source -> $Target"
                        PercentComplete = ([Long]($This.Total*100/$This.Source.Length))
                    }

                    Write-Progress @Splat
                }
            } 
            While ($This.Count -gt 0)
        }
        Finally 
        {
            $This.Source.Dispose()
            $This.Target.Dispose()

            $Splat            = @{

                Activity        = "Copying File [{0}]" -f $This.Name
                ParentId        = $This.Id
                Id              = 1
                Status          = "$Source -> $Target"
                PercentComplete = 100
            }

            Write-Progress @Splat
        }
    }
}

# // ====================
# // | Controller class |
# // ====================

Class VideoFileTransfer
{
    [Object]    $Source
    [Object]    $Target
    Hidden [UInt32] $Id
    [Object]  $Progress
    VideoFileTransfer([String]$Source,[String]$Target)
    {
        If (!$This.TestPath($Source))
        {
            Throw "Invalid <source> path"
        }

        ElseIf (!$This.TestPath($Target))
        {
            Throw "Invalid <target> path"
        }

        $This.Source = $This.VideoFileIndex("Source",$Source)
        $This.Target = $This.VideoFileIndex("Target",$Target)
        $This.Id     = Get-Random -Max 2147483647
    }
    [UInt32] TestPath([String]$Path)
    {
        Return [System.IO.Directory]::Exists($Path)
    }
    [Object] VideoFileIndex([String]$Type,[String]$Path)
    {
        Return [VideoFileIndex]::New($Type,$Path)
    }
    [Object] VideoFileProgress([UInt32]$Index,[Object]$Slot)
    {
        Return [VideoFileProgress]::New($Index,$Slot)
    }
    [Object] VideoFileTransferPercent()
    {
        Return [VideoFileTransferPercent]::New([DateTime]::Now)
    }
    [Object] VideoFileTransferProgress([UInt32]$Index,[Float]$Step,[Object]$Total)
    {
        Return [VideoFileTransferProgress]::New($Index,$Step,$Total)
    }
    [Object] VideoFileTransferStream([String]$Source,[String]$Target)
    {
        Return [VideoFileTransferStream]::New($This.Id,$Source,$Target)
    }
    [String] GetActivity([UInt32]$Count,[String]$Size)
    {
        $Item = "Transferring <Source -> Target> files [~] Total: ({0}), Size: ({1}), ETA: ({2})"
        Return $Item -f $Count, $Size, $This.Progress.Remain
    }
    Transfer()
    {
        $List          = $This.Source.Output | ? Name -notin $This.Target.Output.Name
        $Bytes         = ($List.Size.Bytes -join "+" | Invoke-Expression)
        $Total         = $This.VideoFileSize("Transfer",$Bytes)
        $Step          = $Total.Bytes/100
        $Track         = 0..100 | % { $This.VideoFileTransferProgress($_,$Step,$Total) }
        $Slot          = $Track[0]

        $This.Progress = $This.VideoFileTransferPercent()

        $Transferred   = 0

        $Splat         = @{

            Activity        = $This.GetActivity($List.Count,$Total.Size)
            Id              = $This.Id
            Status          = $Slot.Status
            PercentComplete = $Slot.Index
        }

        Write-Progress @Splat

        ForEach ($X in 0..($List.Count-1))
        {
            $File = $List[$X]
            If (!$File.Folder)
            {
                $xSource = $File.Fullname
                $xTarget = $xSource.Replace($This.Source.Path,$This.Target.Path)

                # Test parent path
                $xParent = $xTarget | Split-Path -Parent
                If (![System.IO.Directory]::Exists($xParent))
                {
                    [System.IO.Directory]::CreateDirectory($xParent)
                }

                $This.VideoFileTransferStream($xSource,$xTarget)

                $Transferred = $Transferred + $File.Size.Bytes
            }

            If ($Transferred -gt $Slot.Size.Bytes)
            {
                $Slot = $Track | ? { $_.Size.Bytes -gt $Transferred } | Select-Object -First 1

                If ($Slot.Index -gt 0)
                {
                    $This.Progress.GetPercent($Slot.Index)
                }

                $Splat         = @{

                    Activity        = $This.GetActivity($List.Count,$Total.Size)
                    Id              = $This.Id
                    Status          = $Slot.Status
                    PercentComplete = $Slot.Index
                }

                Write-Progress @Splat -EA 0
            }
        }

        Write-Progress -Activity Complete -Id $This.Id -Status Complete -Completed
    }
    [Object] VideoFileSize([String]$Type,[UInt64]$Bytes)
    {
        Return [VideoFileSize]::New($Type,$Bytes)
    }
    [String] ToString()
    {
        Return "<VideoFileTransfer>"
    }
}

<#
    $Source = "C:\Users\mcadmin\Videos"
    $Target = "E:\Videos"
    $Ctrl   = [VideoFileTransfer]::New($Source,$Target)
    $Ctrl.Transfer()
#>
