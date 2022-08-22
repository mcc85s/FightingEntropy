<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName: Backup-KaliLinunx.ps1
          Solution: For backing up a profil in Kali Linux
          Purpose: 
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-08-22
          Modified: 2022-08-22
          Version - 0.0.0 - () - Finalized functional version 1.
          TODO:
.Example
#>

Function Backup-KaliLinux
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory,Position=0)][String]$Drive,
        [Parameter(Mandatory,Position=1)][String]$Base,
        [Parameter(Mandatory,Position=2)][String]$User
        )

    Class FileStream
    {
        [Object] $Source
        [Object] $Destination
        [Byte[]] $Buffer
        [Long]   $Total
        [UInt32] $Count
        FileStream([String]$Source,[String]$Destination)
        {
            If (!(Test-Path $Source))
            {
                Throw "Invalid source file"
            }

            $This.Source      = [System.IO.File]::OpenRead($Source)
            $This.Destination = [System.IO.File]::OpenWrite($Destination)
            
            Write-Progress -Activity Copying -Status "$Source -> $Destination" -PercentComplete 0
            Try 
            {
                $This.Buffer = [Byte[]]::New(4096)
                $This.Total  = $This.Count = 0
                Do
                {
                    $This.Count = $This.Source.Read($This.Buffer,0,$This.Buffer.Length)
                    $This.Destination.Write($This.Buffer,0,$This.Count)
                    $This.Total += $This.Count
                    If ($This.Total % 1mb -eq 0)
                    {
                        Write-Progress -Activity Copying -Status "$Source -> $Destination" -PercentComplete ([long]($This.Total * 100/$This.Source.Length))
                    }
                }
                While ($This.Count -gt 0)
            }
            Finally
            {
                $This.Source.Dispose()
                $THis.Destination.Dispose()
                Write-Progress -Activity Copying -Status $Destination -Completed
            }
        }
    }

    Class KaliFile
    {
        [UInt32] $Index
        Hidden [Object] $Object
        [String] $Name
        [String] $Parent
        [String] $FullName
        [UInt64] $Size
        [String] $LastWriteTime
        KaliFile([UInt32]$Index,[Object]$Object)
        {
            $This.Index         = $Index
            $This.Object        = $Object
            $This.Name          = $Object.Name
            $This.Parent        = $Object.Fullname | Split-Path -Parent
            $This.Fullname      = $Object.Fullname
            $This.Size          = $Object.Size
            $This.LastWriteTime = $Object.LastWriteTime
        }
        [String] Destination([String]$Source,[String]$Destination)
        {
            Return @( $This.Fullname -Replace $Source, $Destination )
        }
    }

    Class KaliProfile
    {
        [String] $Drive 
        [String] $Base
        [String] $Date
        [String] $User
        [String] $Source
        [String] $Destination
        [Object] $Profile
        Hidden [UInt64] $SizeGb
        [String] $Size
        Hidden [Object] $Error
        KaliProfile([String]$Drive,[String]$Base,[String]$User,[String]$XHome)
        {
            $This.Drive        = $Drive
            $This.Base         = $Base
            $This.Source       = $XHome
            $This.Date         = Get-Date -UFormat "(%m-%Y)"
            $This.Destination  = "$Drive/$Base/$($This.Date)"

            If (!(Test-Path $This.Drive))
            {
                Throw "Drive not available"
            }

            ElseIf (!(Test-Path "$Drive/$Base"))
            {
                Throw "Base not available"
            }

            ElseIf (!(Test-Path $This.Destination))
            {
                New-Item $This.Destination -ItemType Directory -Verbose
            }

            $This.User         = $User
            $Hash              = @{ }
            
            ForEach ($File in Get-ChildItem $This.Source -Recurse -File)
            {
                Write-Host ("[+] ({0}) {1}" -f $Hash.Count, $File.Name)
                $This.SizeGb   = $This.SizeGb + $File.Length
                $Hash.Add($Hash.Count,[KaliFile]::New($File))
            }

            $This.Profile     = $Hash[0..($Hash.Count-1)]
            $This.Size        = "{0:n3} GB" -f ($This.SizeGb/1GB)
            $This.Error       = @( )
        }
        [Object] Folder([String]$Name)
        {
            Return @( $This.Profile | ? { $_.Object.PSParentPath -match $Name } )
        }
        Directories()
        {
            Write-Host "Collecting [~] Paths"

            $Paths  = Get-ChildItem $This.Source -Recurse -Directory | Select-Object -Unique | % FullName

            Write-Host "Generating [~] Paths"
            ForEach ($Path in $Paths)
            {
                $Path = $Path -Replace $This.Source, $This.Destination
                If (!(Test-Path $Path))
                {
                    Try
                    {
                        New-Item $Path -ItemType Directory -Verbose
                    }
                    Catch
                    {
                        $Swap = $Path | Split-Path -Parent
                        If (!(Test-Path $Swap))
                        {
                            New-Item $Swap -ItemType Directory -Verbose
                            New-Item $Path -ItemType Directory -Verbose
                        }
                    }
                }
            }

            Write-Host "Generated [+] Paths, ready for transfer"
        }
        Copy()
        {
            $This.Directories()

            $Track  = 1..100 | % { $This.SizeGB/$_ }
            $Index  = 0
            $Step   = 0
            $Ct     = $This.Profile.Count
            $Label  = "{0} -> {1}" -f $This.Source, $This.Destination
            Write-Host "Migrating [~] $Label"
            Write-Progress -Activity Migrating -Status $Label -PercentComplete 0
            ForEach ($X in 0..($This.Profile.Count-1))
            {
                $File  = $This.Profile[$X]
                $Step  = $Step + $File.Object.Size

                $Dest = $File.Fullname.Replace($This.Source,$This.Destination)
                If (Test-Path $Dest)
                {
                    Remove-Item $Dest -Verbose
                }
        
                Try 
                {
                    [FileStream]::New($File.FullName,$Dest)   
                }
                
                Catch 
                {
                    $This.Error += $File
                }

                If ($Step -gt $Track[$Index])
                {
                    Write-Host ("{0:n2}%" -f [Math]::Round(($X/$Ct)*100))
                    $Index ++
                }
            }
            Write-Progress -Activity Migrating -Status $Label
        }
    }

    $File  = [KaliLinux]::New($Drive,$Base,$User,$Home)

    $File.Copy()
    $List = $File.Error

    If ($List.Count -gt 0)
    {
        ForEach ($Item in $List)
        {
            $Dest = $Item.FullName.Replace($File.Source,$File.Destination) | Split-Path -Parent
            Copy-Item -LiteralPath $Item.Fullname -Destination $Dest -Verbose
        }
    }
}
