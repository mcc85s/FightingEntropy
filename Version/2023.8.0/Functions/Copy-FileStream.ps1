<#
.SYNOPSIS
.DESCRIPTION
.LINK
    [Original]
    https://stackoverflow.com/questions/2434133/progress-during-large-file-copy-copy-item-write-progress
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-08 11:56:49                                                                  //
 \\==================================================================================================// 

    FileName   : Copy-FileStream.ps1
    Solution   : [FightingEntropy()][2023.8.0]
    Purpose    : For copying larger files with a progress indicator.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-08-08
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1.
    TODO       : Get working with SMB mapping and PS Drive for other computers

.Example
#>
Function Copy-FileStream
{
    [CmdLetBinding()]
    Param( 
        [Parameter(Mandatory,Position=0)][String]$Source, 
        [Parameter(Mandatory,Position=1)][String]$Destination)

    Class FileStream
    {
        [Object]      $Source
        [Object] $Destination
        [Byte[]]      $Buffer
        [Long]         $Total
        [UInt32]       $Count
        FileStream([Object]$Source,[Object]$Destination)
        {
            If (!(Test-Path $Source))
            {
                Throw "Invalid source file"
            }

            $This.Source      = [System.IO.File]::OpenRead($Source)
            $This.Destination = [System.IO.File]::OpenWrite($Destination)

            Write-Progress -Activity "Copying File" -Status "$Source -> $Destination" -PercentComplete 0
            Try 
            {
                $This.Buffer  = [Byte[]]::New(4096)
                $This.Total   = $This.Count = 0
                Do 
                {
                    $This.Count = $This.Source.Read($This.Buffer, 0, $This.Buffer.Length)
                    $This.Destination.Write($This.Buffer, 0, $This.Count)
                    $This.Total += $This.Count
                    If ($This.Total % 1mb -eq 0) 
                    {
                        Write-Progress -Activity "Copying File" -Status "$Source -> $Destination" -PercentComplete ([long]($This.Total * 100 / $This.Source.Length))
                    }
                } 
                While ($This.Count -gt 0)
            }
            Finally 
            {
                $This.Source.Dispose()
                $This.Destination.Dispose()
                Write-Progress -Activity "Copying File" -Status "Ready" -Completed
            }
        }
    }

    [FileStream]::New($Source,$Destination) | Out-Null
    Get-Item $Destination
}
