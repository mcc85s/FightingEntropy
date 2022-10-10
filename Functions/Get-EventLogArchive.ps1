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
   //        FileName   : Get-EventLogArchive.ps1                                                                  //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : This basically compiles an archive of the event logs (like a PK3 file) so                //   
   \\                     they can be (imported/exported).                                                         \\   
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
    ¯¯¯\\__[ 2022-10-10 11:01:29    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Get-EventLogArchive
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][ValidateScript({Test-Path $_})][String]$Path,
        [Parameter(Mandatory,ParameterSetName=1)][Switch]$New,
        [Parameter(Mandatory,ParameterSetName=2)][Object]$InputObject
    )

    Add-Type -Assembly System.IO.Compression, System.IO.Compression.Filesystem

    Class EventLogArchive
    {
        [String]           $Mode
        [String]       $Modified
        [UInt32]         $Length
        [String]           $Size 
        [String]           $Name
        [String]           $Path
        Hidden [Int32]    $State
        Hidden [String]  $Status
        Hidden [Object]     $Zip
        Hidden [Hashtable] $Hash
        EventLogArchive([String]$Fullname)
        {
            $File          = Get-Item $Fullname
            $This.Mode     = $File.Mode
            $This.Modified = $File.LastWriteTime.ToString()
            $This.Length   = $File.Length
            $This.Size     = "{0:n2} MB" -f ($File.Length/1MB)
            $This.Name     = $File.Name
            $This.Path     = $File.Fullname
            $This.TestPath() | Out-Null
        }
        EventLogArchive()
        {
            $This.Mode     = "-"
            $This.Modified = "-"
            $This.Length   = 0
            $This.Size     = "0.00 MB"
            $This.Name     = "-"
            $This.Path     = "<New>"
            $This.State    = -1
            $This.Status   = "Template archive"
        }
        EventLogArchive([Object]$Object)
        {
            If ($Object.GetType().Name -ne "EventLogArchive")
            {
                Throw "The entry is not an EventLogArchive"
            }

            $This.Mode     = $Object.Mode
            $This.Modified = $Object.Modified
            $This.Length   = $Object.Length
            $This.Size     = $Object.Size
            $This.Name     = $Object.Name
            $This.Path     = $Object.Path
        }
        [String] Success([String]$Result)
        {
            Return "Success [+] $Result"
        }
        [String] Error([String]$Result)
        {
            Return "Exception [!] $Result"
        }
        [Void] Open()
        {
            Try 
            {
                $This.Zip    = [System.IO.Compression.ZipFile]::Open($This.Path,"Read")
                $This.State  = 1
                $This.Status = $This.Success("File: [$($This.Path)] - Opened, and can extract existing entries")
            } 
            Catch 
            {
                $This.Zip     = $Null
                $This.State   = -1
                $This.Status  = $This.Error("File: [$($This.Path)] - Invalid zip file")
            }
        }
        [Void] Create()
        {
            Try
            {
                $This.Zip     = [System.IO.Compression.ZipFile]::Open($This.Path,"Create")
                $This.Zip.Dispose()
                $This.State   = 0
                $This.Status  = $This.Success("File: [$($This.Path)] - Created, and was properly disposed")
            }
            Catch
            {
                $This.Zip     = $Null
                $This.State   = -1
                $This.Status  = $This.Error($PSItem)
            }
        }
        [Void] Update()
        {
            Try
            {
                $This.Zip     = [System.IO.Compression.ZipFile]::Open($This.Path,"Update")
                $This.State   = 2
                $This.Status  = $This.Success("File: [$($This.Path)] - Opened, and can now be updated")
                $This.Hash    = @{ }
            }
            Catch
            {
                $This.Zip     = $Null
                $This.State   = -1
                $This.Status  = $This.Error($PSItem)
            }
        }
        [Void] Write([Object]$File)
        {
            If ($This.State -eq 2 -and !$This.Hash["$($File.Name)"])
            {
                $Item = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,$File.Fullname,$File.Name,[System.IO.Compression.CompressionLevel]::Fastest)
                $This.Hash.Add($File.Name,$Item)
            }
            Else
            {
                $This.Status  = $This.Error("File: [$($This.Path)] - Not yet available for updating")
            }
        }
        [Void] GetEntries()
        {
            If ($This.State -eq 1)
            {
                $This.PopulateEntryTable()
            }

            ElseIf ($This.State -ne 1)
            {
                $This.Open()
                $This.PopulateEntryTable()
            }
        }
        [Void] PopulateEntryTable()
        {
            $This.Hash    = @{ }
            ForEach ($X in 0..($This.Zip.Entries.Count-1))
            {
                $This.Hash.Add($This.Zip.Entries[$X].Name,$This.Zip.Entries[$X])
            }
        }
        [Object] File([String]$Name)
        {
            Return $This.Hash["$Name"]
        }
        TestPath()
        {
            If ($This.Path -eq "<New>")
            {
                $This.State  = -1
                $This.Status = $This.Error("File: [$($This.Path)] - Template zip file, archive needs to be populated with (base directory/files)")
            }
            ElseIf (![System.IO.File]::Exists($This.Path))
            {
                $This.State  = -1
                $This.Status = $This.Error("File: [$($This.Path)] - Invalid file path")
            }
            ElseIf ([System.IO.FileInfo]::New($This.Path).Extension -ne ".zip")
            {
                $This.State  = -1
                $This.Status = $This.Error("File: [$($This.Path)] - Invalid (*.zip) file entry")
            }
            Else
            {
                $This.State  = 0
                $This.Status = $This.Success("File: [$($This.Path)] - Successfully validated")
            }
        }
        SetPath([String]$Path)
        {
            $Parent          = $Path | Split-Path -Parent
            If (![System.IO.Directory]::Exists($Parent))
            {
                $This.State  = -1
                $This.Status = $This.Error("Invalid path provided")
            }
            ElseIf ([System.IO.File]::Exists($Path))
            {
                $This.State  = -1
                $This.Status = $This.Error("File already exists")
            }
            Else
            {
                $This.State  = 0
                $This.Path   = $Path
                $This.Status = $This.Success("File: [$($This.Path)] - Path validated, and set to allow file creation")
            }
        }
        [Void] GetState()
        {
            $This.TestPath()

        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogArchive]::New($Path) }
        1 { [EventLogArchive]::New()      }
        2 { [EventLogArchive]::New($InputObject)}
    }
}
