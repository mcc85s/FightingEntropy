<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-04-07 09:53:07                                                                  //
 \\==================================================================================================// 

   FileName   : New-RawTranscription.ps1
   Solution   : [FightingEntropy()][2023.4.0]
   Purpose    : Processes a raw transcription into prepared format for New-TranscriptionCollection
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2023-04-06
   Modified   : 2023-04-07
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : 

.Example
#>

Function New-RawTranscription
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$Content)

    Class TimeContent
    {
        [UInt32]   $Index
        [String] $Content
        TimeContent([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }
    
    Class Time
    {
        [UInt32]      $Index
        [TimeSpan] $Position
        [TimeSpan]      $End
        [Object]    $Content
        Time([UInt32]$Index,[String]$Position)
        {
            $This.Index    = $Index
            $This.Position = $Position
            $This.Content  = @( )
        }
        [Object] TimeContent([UInt32]$Index,[String]$Content)
        {
            Return [TimeContent]::New($Index,$Content)
        }
        Add([String]$Content)
        {
            $This.Content += $This.TimeContent($This.Content.Count,$Content)
        }
        SetEnd([String]$End)
        {
            $This.End = $End
            If ($This.Content[-1].Content -match [char]13)
            {
                $This.Content = $This.Content[0..($This.Content.Count-2)]
            }
    
            $This.Content[0].Content = ":{0}" -f $This.Content[0].Content
        }
        [String] Code()
        {
            $Out  = @( )
            $Out += '$T.X(0,"{0}","{1}",@{2}' -f $This.Position, $This.End, "'"
            ForEach ($Line in $This.Content)
            {
                $Out += $Line.Content
            }
            $Out += "'@)"
            $Out += ""
    
            Return $Out -join "`n"
        }
    }

    Class TimeControl
    {
        [Object] $Content
        [Object]  $Output
        TimeControl([String]$Content)
        {
            $This.Content = $Content -Split "`n"
            $This.Refresh()
        }
        [Object] Time([UInt32]$Index,[String]$Position)
        {
            Return [Time]::New($Index,$Position)
        }
        Clear()
        {
            $This.Output   = @( )
        }
        Add([String]$Line)
        {
            $This.Output += $This.Time($This.Output.Count,$Line)
        }
        Refresh()
        {
            $This.Output = @( )

            # Process each line
            ForEach ($X in 0..($This.Content.Count-1))
            {
                $Line = $This.Content[$X]
                If ($Line -match "\d{2}\:\d{2}\:\d{2}")
                {
                    $This.Add($Line)
                }

                Else
                {
                    $This.Output[-1].Add($Line)
                }
            }
        }
        Finalize([String]$Duration)
        {
            ForEach ($X in 0..($This.Output.Count-2))
            {
                $This.Output[$X].SetEnd($This.Output[$X+1].Position)
            }

            $This.Output[-1].SetEnd($Duration)
        }
    }

    [TimeControl]::New($Content)
}
