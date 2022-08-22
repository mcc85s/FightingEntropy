
<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName: Backup-AndroidPhone.ps1
          Solution: For backing up the content of an android device on LINUX
          Purpose: 
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-08-22
          Modified: 2022-08-22
          Version - 0.0.0 - () - Finalized functional version 1.
          TODO:
.Example
_________________________________________________________________________________________________________________
| Original instructions from https://www.linuxexperten.com/content/connect-any-android-device-linux-kali-2019xx |
|---------------------------------------------------------------------------------------------------------------|
| For Windows, use (New-Object -ComObject Shell.Application)                                                    |
| https://github.com/nosalan/powershell-mtp-file-transfer/blob/master/phone_backup.ps1                          |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________
| Install MTP Tools |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo apt-get update && sudo apt-get install mtp-tools
________________________________
| Check for other installation |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo dpkg --get-selections | grep -v deinstall | grep -i mtp
_____________________________________________
| Remove current, if any installation found |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo apt-get remove mtp-server
___________________________________
| Open a terminal window and type |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo apt-get install jmtpfs
________________________________
| Assign label for device path |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$Label = "moto_g7"
$Root  = "/media/$Label"
__________________________________________
| Make a mount folder, and assign rights |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo mkdir $Root
sudo chmod 777 $Root
______________________
| Mount using jmtpfs |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sudo jmtpfs $Root
ls $Root
sudo fusermount -u $Root

#>

Function Backup-AndroidPhone
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory,Position=0)][String]$Drive,
        [Parameter(Mandatory,Position=1)][String]$Base,
        [Parameter(Mandatory,Position=2)][String]$Source)

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
                $This.Destination.Dispose()
                Write-Progress -Activity Copying -Status $Destination -Completed
            }
        }
    }

    Class AndroidFile
    {
        [UInt32] $Index
        Hidden [Object] $Object
        [String] $Name
        [String] $Parent
        [String] $FullName
        [UInt64] $Size
        [String] $LastWriteTime
        AndroidFile([UInt32]$Index,[Object]$Object)
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

    Class AndroidPhone
    {
        [String] $Drive 
        [String] $Base
        [String] $Date
        [String] $Source
        [String] $Destination
        [Object] $Profile
        Hidden [UInt64] $SizeGb
        [String] $Size
        Hidden [Object] $Error
        AndroidPhone([String]$Drive,[String]$Base,[String]$Source)
        {
            If (!(Test-Path $Drive))
            {
                Throw "Drive not available"
            }

            ElseIf (!(Test-Path "$Drive/$Base"))
            {
                Throw "Base not available"
            }

            $This.Drive        = $Drive
            $This.Base         = $Base
            $This.Source       = $Source
            $This.Date         = Get-Date -UFormat "(%m-%Y)"
            $This.Destination  = "$Drive/$Base/$($This.Date)"

            If (!(Test-Path $This.Destination))
            {
                New-Item $This.Destination -ItemType Directory -Verbose
            }

            $Hash              = @{ }
            $Names             = Get-ChildItem $This.Source

            ForEach ($Name in $Names)
            {
                Write-Host $Name
                Get-ChildItem $Name -Recurse | % { 
                
                    $Item        = [AndroidFile]::New($Hash.Count,$_)
                    $This.SizeGb = $This.SizeGb + $Item.Size
                    Write-Host ("[{0:d6}] {1}" -f $Item.Index,$Item.FullName)
                    $Hash.Add($Hash.Count,$Item)
                }
            }

            $This.Profile     = $Hash[0..($Hash.Count-1)]
            $This.Size        = "{0:n3} GB" -f ($This.SizeGb/1GB)
            $This.Error       = @( )
        }
        Directories()
        {
            Write-Host "Collecting [~] Paths"

            $Paths            = $This.Profile.Parent | Select-Object -Unique | Sort-Object

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
                $Step  = $Step + $File.Size
                $Dest  = $File.Destination($This.Source,$This.Destination)
        
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

    $File = [AndroidPhone]::New($Drive,$Base,$Source)
    $File.Copy()
}
